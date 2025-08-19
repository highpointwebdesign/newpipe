component {
    <!--- Set your datasource name here --->
    property name="datasource" default="sg";
    
    /**
     * getMeals()
     * Returns a list of meals along with their ingredients.
     */
    remote any function getMeals() {
        var result = [];
        var mealsQ = queryExecute(
            "Select
                m.mealID,
                m.title,
                m.servings,
                m.mealTypeID,
                m.created_at,
                t.mealTypeName,
                t.mealTypeColor
            From
                meals m Left Join
                meal_types t On t.mealTypeID = m.mealTypeID
            Where
                m.isDeleted = 0
            Order By
                m.title,
                m.title;
",
            {},
            { datasource = variables.datasource }
        );
        
        for (var i = 1; i <= mealsQ.recordCount; i++) {
            var meal = {
                mealID          : mealsQ.mealID[i],
                title       : mealsQ.title[i],
                servings    : mealsQ.servings[i],
                mealTypeID    : mealsQ.mealTypeID[i],
                created_at  : mealsQ.created_at[i],
                mealTypeName    : mealsQ.mealTypeName[i],
                mealTypeColor    : mealsQ.mealTypeColor[i],
                // googleColorCodeID    : mealsQ.googleColorCodeID[i],
                // borderColor    : mealsQ.typeColor[i],
                ingredients : []
            };
            var ingrQ = queryExecute(
                "Select
                    mi.miID,
                    mi.mealID,
                    mi.ingredientID,
                    mi.quantity,
                    mi.unit,
                    r.ingredient_name,
                    uom.unitName,
                    uom.baseUnit,
                    uom.unitType
                From
                    meal_ingredients mi Left Join
                    raw_ingredients r On r.ingredientID = mi.ingredientID Left Join
                    measurementunits uom On uom.unitID = mi.unit
                Where
                    mi.mealID = :mealId
                Order By
                    r.ingredient_name",
                { mealId = meal.mealID },
                { datasource = variables.datasource }
            );
            for (var j = 1; j <= ingrQ.recordCount; j++) {
                arrayAppend(meal.ingredients, {
                    miID              : ingrQ.miID[j],
                    mealID : ingrQ.mealID[j],
                    ingredientID : ingrQ.ingredientID[j],
                    ingredient_name : ingrQ.ingredient_name[j],
                    quantity        : ingrQ.quantity[j],
                    unit            : ingrQ.unitName[j]
                });
            }
            arrayAppend(result, meal);
        }
        return result;
    }
    
    /**
     * addMeal()
     * Inserts a new meal with one or more ingredients.
     * @param title       – The meal title.
     * @param servings    – Number of servings.
     * @param ingredients – A JSON string representing an array of ingredient objects.
     */
    remote any function addMeal(required string title, required numeric servings, required string ingredients) {
        var ingredientsArray = deserializeJSON(arguments.ingredients);
        var mealId = 0;
        
        transaction {
            // Insert the meal and capture the generated key.
            var insertMeal = queryExecute(
                "INSERT INTO meals (title, servings, mealType, details) VALUES (:title, :servings, :mealType, :details)",
                { 
                    title = arguments.title, 
                    servings = arguments.servings,
                    details = arguments.details,
                    mealType = arguments.mealType 
                },
                { datasource = variables.datasource}
            );

            // Get the last insert ID
                var qLastId = queryExecute(
                    "SELECT LAST_INSERT_ID() AS id",
                    {},
                    { datasource = "sg" }
                );
            mealId = qLastId.id[1];
            
            // Insert each ingredient.
            for (var ingredient in ingredientsArray) {
                queryExecute(
                    "INSERT INTO meal_ingredients (mealID, ingredient_name, quantity, unit) VALUES (:mealId, :ingName, :quantity, :unit)",
                    {
                        mealId   : mealId,
                        ingName  : ingredient.ingredientName,
                        quantity : ingredient.quantity,
                        unit     : ingredient.unit
                    },
                    { datasource = variables.datasource }
                );
            }
        }
        return { success = true, mealId = mealId };
    }
    
    /**
     * archiveMeal()
     * Deletes a meal (and thanks to ON DELETE CASCADE, its ingredients too).
     */
    remote any function archiveMeal(required numeric mealId) {
        queryExecute(
            "UPDATE meals SET isDeleted = 1 WHERE id = :mealId",
            { mealId = arguments.mealId },
            { datasource = variables.datasource }
        );
        return { success = true };
    }
    
    /**
     * getShoppingList()
     * Aggregates ingredients from selected meals.
     * @param mealIds – JSON string representing an array of selected meal IDs.
     * Performs a simple conversion: if the aggregated quantity of teaspoons reaches 3 or more, it converts to tablespoons.
     */
    remote any function getShoppingList(required string mealIds) {

        // Deserialize the provided JSON of meal IDs.
        var mealIdsArr = deserializeJSON(arguments.mealIds);
        var mealIDArr = [];
        
        // Build dynamic placeholders for the IN clause.
        for (var i = 1; i <= arrayLen(mealIdsArr); i++) {
            mealIDArr.append(mealIdsArr[i]);
        }
        
        // Aggregate ingredients by name and unit.
        // This query groups ingredients and sums up their quantities.
        // var querySQL = "
        //     Select
        //         m.ingredient_name,
        //         m.unit,
        //         Sum(m.quantity) As totalQuantity
        //     From
        //         dbrhzbrqhhlw5g.meal_ingredients m
        //     WHERE 
        //         m.mealID IN (" & placeholderList & ")         
        //     Group By
        //         m.ingredient_name,
        //         m.unit
        //     Order By
        //         m.ingredient_name,
        //         m.unit,
        //         totalQuantity";
        var querySQL = "
        Select
            i.ingredient_name,
            i.unit,
            Sum(i.quantity) As totalQuantity,
            m.title,
            i.mealID
        From
            meal_ingredients i Inner Join
            meals m On i.mealID = m.miID
        Where
            i.mealID In ( #arrayToList(mealIDArr)# )
        Group By
            i.ingredient_name,
            i.unit,
            m.title,
            i.mealID
        Order By
            i.ingredient_name,
            i.unit,
            totalQuantity,
            m.title";

        var ingrList = queryExecute(querySQL, {}, { datasource = variables.datasource });
        
        // Use a structure to aggregate rows that differ only by unit formatting.
        var aggregated = {};
        for (var i = 1; i <= ingrList.recordCount; i++) {
            var name     = trim(ingrList.ingredient_name[i]);
            var quantity = ingrList.totalQuantity[i];
            var unit     = lcase(trim(ingrList.unit[i]));
            
            // Normalize cup units so that "cup" and "cups" are treated the same.
            if ( listFindNoCase("cup,cups", unit) ) {
                unit = "cup";
            }
            // Example conversion: if unit is teaspoon(s) and 3 or more are combined, convert to tablespoon(s)
            if ( listFindNoCase("tsp,teaspoon,teaspoons", unit) ) {
                if (quantity >= 3) {
                    var Tbsp = decimalformat(int(quantity / 3) + ((quantity mod 3) / 3));
                    unit = "Tbsp";
                    quantity = Tbsp;
                }
            }
            // Use a composite key of ingredient name and normalized unit.
            var key = name & "|" & unit;
            if (structKeyExists(aggregated, key)) {
                aggregated[key].quantity += quantity;
            } else {
                aggregated[key] = { ingredient = name, quantity = quantity, unit = unit };
            }
        }
        
        // Convert the aggregated structure into an array.
        var outputIngredients = [];
        for (var key in aggregated) {
            arrayAppend(outputIngredients, aggregated[key]);
        }
        arraySort(
            outputIngredients, 
            function (e1, e2){
                return compare(e1.ingredient, e2.ingredient);
            }
        );
        
        // Additionally, sum the total servings for selected meal IDs.
        var servingsQuery = queryExecute(
             "SELECT SUM(servings) AS totalServings FROM meals WHERE id IN (#arrayToList(mealIDArr)#)",
             {},
             { datasource = variables.datasource }
        );
        var totalServings = (servingsQuery.recordCount > 0) ? servingsQuery.totalServings[1] : 0;
        var mealsCount = totalServings / 2;
        
        // Return an object with a summary and the ingredients list.
        return { 
            summary: { 
                totalServings: totalServings, 
                meals: mealsCount ,
                ingredients: ingrList.recordCount()
            },
            ingredients: outputIngredients ,
            placeholderList: #arrayToList(mealIDArr)#
        };
    }

    /**
     * getMealById()
     * Retrieves the meal details for selected meal.
     * @param mealIds – JSON string representing an array of selected meal IDs.
     * Performs a database retrieval of the meal and its ingredients.
     */
    remote query function getMealById(required numeric mealId) {
        var mealData = {};

        var mealsQ = queryExecute(
            "Select
                mi.miID,
                mi.mealID,
                mi.ingredientID,
                mi.quantity,
                mi.unit,
                r.ingredient_name,
                uom.unitName,
                uom.baseUnit,
                uom.unitType,
                m.title,
                m.servings,
                m.mealTypeID,
                mt.mealTypeName,
                mt.mealTypeColor,
                m.fav,
                m.details
            From
                meal_ingredients mi Left Join
                raw_ingredients r On r.ingredientID = mi.ingredientID Left Join
                measurementunits uom On uom.unitID = mi.unit Right Join
                meals m On mi.mealID = m.mealID Left Join
                meal_types mt On m.mealTypeID = mt.mealTypeID
            Where
                mi.mealID = :mealID
            Order By
                mi.miID;",
            { mealId = arguments.mealId },
            { datasource = variables.datasource }
        );
        
        return mealsQ;
    }

    remote any function updateMeal(required numeric mealId, required string title, required numeric servings, required string ingredients) {
        var ingredientsArray = deserializeJSON(arguments.ingredients);
        
        transaction {
            // Update the meal record.
            queryExecute(
                "UPDATE meals SET title = :title, servings = :servings,  mealType = :mealType, details = :details WHERE id = :mealId",
                { 
                    title = arguments.title, 
                    servings = arguments.servings, 
                    mealType = arguments.mealType, 
                    details = arguments.details, 
                    mealId = arguments.mealId },
                { datasource = variables.datasource }
            );
            
            // Remove all existing ingredients for this meal.
            queryExecute(
                "DELETE FROM meal_ingredients WHERE mealID = :mealId",
                { mealId = arguments.mealId },
                { datasource = variables.datasource }
            );
            
            // Insert each ingredient again.
            for (var ingredient in ingredientsArray) {
                queryExecute(
                    "INSERT INTO meal_ingredients (mealID, ingredient_name, quantity, unit) VALUES (:mealId, :ingName, :quantity, :unit)",
                    {
                        mealId   : arguments.mealId,
                        ingName  : ingredient.ingredientName,
                        quantity : ingredient.quantity,
                        unit     : ingredient.unit
                    },
                    { datasource = variables.datasource }
                );
            }
        }
        return { success = true };
    }

    // remote any function getMealIngredients(required numeric mealId) {
    //     var result = [];
    //     var ingredientQry = queryExecute(
    //         "SELECT id, mealID, ingredient_name, quantity, unit order by ingredient_name asc",
    //         {},
    //         { datasource = variables.datasource }
    //     );
        
    //     for (var i = 1; i <= ingredientQry.recordCount; i++) {
    //         var ingredients = {
    //             id          : ingredientQry.id[i],
    //             mealID       : ingredientQry.mealID[i],
    //             ingredient_name    : ingredientQry.ingredient_name[i],
    //             quantity    : ingredientQry.quantity[i],
    //             unit  : ingredientQry.unit[i]
    //         };

    //         arrayAppend(ingredients);
    //     }
    //     return result;
    // }

    remote any function getMealIngredients(required string mealIds) {
        var result = []; // Initialize an empty array
        // Build the SQL using the IN clause.
        // The list attribute in the options ensures that the mealIds parameter (a comma-separated list)
        // is properly expanded into multiple values.
        var sql = "
            SELECT id, mealID, ingredient_name, quantity, unit
            FROM meal_ingredients
            WHERE mealID IN (:mealIds)
            ORDER BY ingredient_name ASC
        ";
        
        var ingredientQry = queryExecute(
            sql,
            { mealIds: { value: arguments.mealIds, cfsqltype: "cf_sql_integer", list:"true" }},
            { datasource = variables.datasource, list = true }
        );

        for (var i = 1; i <= ingredientQry.recordCount; i++) {
            var ingredientData = {
                id              : ingredientQry.id[i],
                mealID         : ingredientQry.mealID[i],
                ingredient : ingredientQry.ingredient_name[i],
                quantity        : ingredientQry.quantity[i],
                unit            : ingredientQry.unit[i]
            };
            arrayAppend(result, ingredientData);
        }

        return result;
    }


    // trello integration
        /**
     * Updates the Recipes, Tags, and RecipeTags tables using the provided meals data.
     * 
     * @param meals An array of meal structures from the JSON dataset.
     */
    // remote void function updateMeals(required array meals) {
    //     // Loop over each meal from the JSON data.
    //     for (var meal in arguments.meals) {

    //         // Convert the ISO date string to a ColdFusion date, if available.
    //         var lastActivity = "";
    //         if (structKeyExists(meal, "dateLastActivity") && len(trim(meal.dateLastActivity)) > 0) {
    //             try {
    //                 lastActivity = parseDateTime(meal.dateLastActivity);
    //             } catch(e) {
    //                 lastActivity = null;
    //             }
    //         }
            
    //         // Insert or update the recipe record.
    //         // Uses MySQL's ON DUPLICATE KEY UPDATE to update if a record with this recipe_id exists.
    //         var sqlRecipe = "
    //             INSERT INTO Recipes (recipe_id, name, description, date_last_activity)
    //             VALUES (:recipe_id, :name, :description, :date_last_activity)
    //             ON DUPLICATE KEY UPDATE 
    //                 name = VALUES(name),
    //                 description = VALUES(description),
    //                 date_last_activity = VALUES(date_last_activity)
    //         ";
    //         var paramsRecipe = {
    //             recipe_id       = meal.id,
    //             name            = meal.name,
    //             description     = meal.desc,
    //             date_last_activity = lastActivity
    //         };
    //         queryExecute(sqlRecipe, paramsRecipe, {datasource="sg"});
            
    //         // If the meal has labels (which we treat as tags), loop over each one.
    //         if (structKeyExists(meal, "labels") && isArray(meal.labels) && arrayLen(meal.labels) > 0) {
    //             for (var label in meal.labels) {
    //                 // Assume each label is a structure with properties "name" and "color".
    //                 var tagName = "";
    //                 var tagColor = "";
                    
    //                 if (isStruct(label)) {
    //                     tagName  = (structKeyExists(label, "name") ? label.name : "");
    //                     tagColor = (structKeyExists(label, "color") ? label.color : "");
    //                 }
                    
    //                 // Skip if tag name is empty.
    //                 if (len(trim(tagName)) == 0) {
    //                     continue;
    //                 }
                    
    //                 // Insert or update into the Tags table.
    //                 var sqlTag = "
    //                     INSERT INTO Tags (name, color)
    //                     VALUES (:name, :color)
    //                     ON DUPLICATE KEY UPDATE color = VALUES(color)
    //                 ";
    //                 var paramsTag = { name = tagName, color = tagColor };
    //                 queryExecute(sqlTag, paramsTag, {datasource="sg"});
                    
    //                 // Retrieve the tag_id for this tag.
    //                 var sqlGetTag = "SELECT tag_id FROM Tags WHERE name = :name";
    //                 var tagResult = queryExecute(sqlGetTag, { name = tagName }, {datasource="sg"});
    //                 if (tagResult.recordCount > 0) {
    //                     var tagId = tagResult.tag_id[1];
                        
    //                     // Insert mapping into the RecipeTags table.
    //                     // The ON DUPLICATE KEY UPDATE clause here avoids duplicate key errors.
    //                     var sqlMapping = "
    //                         INSERT INTO RecipeTags (recipe_id, tag_id)
    //                         VALUES (:recipe_id, :tag_id)
    //                         ON DUPLICATE KEY UPDATE recipe_id = recipe_id
    //                     ";
    //                     var paramsMapping = { recipe_id = meal.id, tag_id = tagId };
    //                     queryExecute(sqlMapping, paramsMapping, {datasource="sg"});
    //                 }
    //             }
    //         }
    //     }
    // }

    /**
     * Fetches the Trello API data using cfhttp, processes each meal,
     * and updates/inserts the records into the Recipes, Tags, and RecipeTags tables.
     * Returns a structure with a status ("success" or "error") and a message.
     */
    remote struct function updateMeals() returnformat="json" {
        var result = { status = "", msg = "" };
        try {
            // Use CFHTTP to retrieve the API data from Trello.
            // Entrees = 65e35da372dfea5154f193f1
            // cfhttp(
            //     url = "https://api.trello.com/1/lists/65e35da372dfea5154f193f1/cards?key=ca06daaf6537b74a874e324dcc045ee0&token=ATTAeaf7252662f97d5e4de5e1b7fcb53d1bf31c7789c4c3d0abf5cdf8a30b5f6eb44FEF2E71",
            //     method = "GET",
            //     result = "apiResponse"
            // );
            // Arkansas Trip 68a0ac562a660c81da09b5b3
            cfhttp(
                url = "https://api.trello.com/1/lists/68a0ac562a660c81da09b5b3/cards?key=ca06daaf6537b74a874e324dcc045ee0&token=ATTAeaf7252662f97d5e4de5e1b7fcb53d1bf31c7789c4c3d0abf5cdf8a30b5f6eb44FEF2E71",
                method = "GET",
                result = "apiResponse"
            );
            
            // Check for a successful response.
            // if (apiResponse.statusCode != 200) {
            //     throw "CFHTTP call to Trello API failed with status code " & apiResponse.statusCode;
            // }
            
            // Deserialize the returned JSON content.
            var meals = deserializeJSON(apiResponse.fileContent);
            if (!isArray(meals)) {
                throw "Trello API data is not an array as expected.";
            }


            // Loop over each meal from the API data.
            for (var meal in meals) {
                
                // Parse dateLastActivity if available.
                var lastActivity = "";
                if (structKeyExists(meal, "dateLastActivity") && len(trim(meal.dateLastActivity)) > 0) {
                    try {
                        lastActivity = parseDateTime(meal.dateLastActivity);
                    } catch (any e) {
                        lastActivity = null;
                    }
                }
                
                // Insert or update the recipe record.
                var sqlRecipe = "
                    INSERT INTO recipes (recipe_id, name, description, date_last_activity)
                    VALUES (:recipe_id, :name, :description, :date_last_activity)
                    ON DUPLICATE KEY UPDATE 
                        name = VALUES(name),
                        description = VALUES(description),
                        date_last_activity = VALUES(date_last_activity)
                ";
                // Assume lastActivity is already a valid ColdFusion date object.
                var formattedDate = formatTrelloDate(lastActivity);

                var paramsRecipe = {
                    recipe_id         = meal.id,
                    name              = meal.name,
                    description       = meal.desc,
                    date_last_activity = formattedDate  // e.g., 2025-05-14 09:27:23
                };

                queryExecute(sqlRecipe, paramsRecipe, { datasource = "sg" });

                // Insert or update the meal description/meal details

                //  NO LONGER NEEDED, TRELLO DETAILS ARE STORED IN THE RECIPE TABLES

                    // var desc = "";
                    // var sqlMeal_Description = "
                    //     INSERT INTO meal_description (recipe_id, meal_details, date_last_activity)
                    //     VALUES (:recipe_id, :meal_details, :date_last_activity)
                    //     ON DUPLICATE KEY UPDATE 
                    //         meal_details = CASE 
                    //             WHEN DATEDIFF(NOW(), date_last_activity) > 2 
                    //             THEN VALUES(meal_details) 
                    //             ELSE meal_details 
                    //         END,
                    //         date_last_activity = CASE 
                    //             WHEN DATEDIFF(NOW(), date_last_activity) > 2 
                    //             THEN VALUES(date_last_activity)
                    //             ELSE date_last_activity
                    //         END";

                    // var paramsMealDescription = {
                    //     meal_details = meal.desc, 
                    //     recipe_id = meal.id,
                    //     date_last_activity = formattedDate
                    // };
                    // queryExecute(sqlMeal_Description, paramsMealDescription, { datasource = "sg" });
                
                // addLogEntry("meal.label");
                // addLogEntry(meal.labels);
                // Process associated labels (which map to tags) if they exist.
                if (structKeyExists(meal, "labels") && isArray(meal.labels) && arrayLen(meal.labels) > 0) {

                    for (var label in meal.labels) {
                        // Expect each label to be a structure with properties "name" and "color".
                        var tagName = "";
                        var tagColor = "";

                        if (isStruct(label)) {
                            tagName  = structKeyExists(label, "name") ? label.name : "";
                            tagColor = structKeyExists(label, "color") ? label.color : "";
                        }
                        // Skip tags with an empty name.
                        if (len(trim(tagName)) == 0) {
                            continue;
                        }
                        
                        // Insert or update the tag in the Tags table.
                        var sqlTag = "
                            INSERT INTO tags (name, color)
                            VALUES (:name, :color)
                            ON DUPLICATE KEY UPDATE color = VALUES(color)
                        ";
                        var paramsTag = { name = tagName, color = tagColor };
                        queryExecute(sqlTag, paramsTag, { datasource = "sg" });

                        
                        
                        // Retrieve the tag_id for the tag.
                        var sqlGetTag = "SELECT tag_id FROM tags WHERE name = :name";
                        var tagResult = queryExecute(sqlGetTag, { name = tagName }, { datasource = "sg" });
                        if (tagResult.recordCount > 0) {
                            var tagId = tagResult.tag_id[1];
                            
                            // Insert the mapping into RecipeTags.
                            var sqlMapping = "
                                INSERT INTO recipetags (recipe_id, tag_id)
                                VALUES (:recipe_id, :tag_id)
                                ON DUPLICATE KEY UPDATE recipe_id = recipe_id
                            ";
                            var paramsMapping = { recipe_id = meal.id, tag_id = tagId };
                            queryExecute(sqlMapping, paramsMapping, { datasource = "sg" });
                        }
                    }
                }
            }
            
            result.status = "success";
            result.msg = "Meal updates processed successfully.";
        } catch (any e) {
            result.status = "error";
            result.msg = "Error processing meal updates: " & e.message;
        }
        // abort;
        return result;
    }

    remote struct function updateSides() returnformat="json" {
        var result = { status = "", msg = "" };
        try {
            // Use CFHTTP to retrieve the API data from Trello.
            cfhttp(
                url = "https://api.trello.com/1/lists/65e35db89f0b47e383050e8f/cards?key=ca06daaf6537b74a874e324dcc045ee0&token=ATTAeaf7252662f97d5e4de5e1b7fcb53d1bf31c7789c4c3d0abf5cdf8a30b5f6eb44FEF2E71",
                method = "GET",
                result = "apiResponse"
            );
            
            // Check for a successful response.
            // if (apiResponse.statusCode != 200) {
            //     throw "CFHTTP call to Trello API failed with status code " & apiResponse.statusCode;
            // }
            
            // Deserialize the returned JSON content.
            var meals = deserializeJSON(apiResponse.fileContent);
            if (!isArray(meals)) {
                throw "Trello API data is not an array as expected.";
            }


            // Loop over each meal from the API data.
            for (var meal in meals) {
                
                // Parse dateLastActivity if available.
                var lastActivity = "";
                if (structKeyExists(meal, "dateLastActivity") && len(trim(meal.dateLastActivity)) > 0) {
                    try {
                        lastActivity = parseDateTime(meal.dateLastActivity);
                    } catch (any e) {
                        lastActivity = null;
                    }
                }
                
                // Insert or update the recipe record.
                var sqlRecipe = "
                    INSERT INTO recipes (recipe_id, name, description, date_last_activity)
                    VALUES (:recipe_id, :name, :description, :date_last_activity)
                    ON DUPLICATE KEY UPDATE 
                        name = VALUES(name),
                        description = VALUES(description),
                        date_last_activity = VALUES(date_last_activity)
                ";
                // Assume lastActivity is already a valid ColdFusion date object.
                var formattedDate = formatTrelloDate(lastActivity);

                var paramsRecipe = {
                    recipe_id         = meal.id,
                    name              = meal.name,
                    description       = meal.desc,
                    date_last_activity = formattedDate  // e.g., 2025-05-14 09:27:23
                };

                queryExecute(sqlRecipe, paramsRecipe, { datasource = "sg" });

                // Insert or update the meal description/meal details
                    // var desc = "";
                    // var sqlMeal_Description = "
                    //     INSERT INTO meal_description (recipe_id, meal_details, date_last_activity)
                    //     VALUES (:recipe_id, :meal_details, :date_last_activity)
                    //     ON DUPLICATE KEY UPDATE 
                    //         meal_details = CASE 
                    //             WHEN DATEDIFF(NOW(), date_last_activity) > 2 
                    //             THEN VALUES(meal_details) 
                    //             ELSE meal_details 
                    //         END,
                    //         date_last_activity = CASE 
                    //             WHEN DATEDIFF(NOW(), date_last_activity) > 2 
                    //             THEN VALUES(date_last_activity)
                    //             ELSE date_last_activity
                    //         END";

                    // var paramsMealDescription = {
                    //     meal_details = meal.desc, 
                    //     recipe_id = meal.id,
                    //     date_last_activity = formattedDate
                    // };
                    // queryExecute(sqlMeal_Description, paramsMealDescription, { datasource = "sg" });
                
                // addLogEntry("meal.label");
                // addLogEntry(meal.labels);
                // Process associated labels (which map to tags) if they exist.
                if (structKeyExists(meal, "labels") && isArray(meal.labels) && arrayLen(meal.labels) > 0) {

                    for (var label in meal.labels) {
                        // Expect each label to be a structure with properties "name" and "color".
                        var tagName = "";
                        var tagColor = "";

                        if (isStruct(label)) {
                            tagName  = structKeyExists(label, "name") ? label.name : "";
                            tagColor = structKeyExists(label, "color") ? label.color : "";
                        }
                        // Skip tags with an empty name.
                        if (len(trim(tagName)) == 0) {
                            continue;
                        }
                        
                        // Insert or update the tag in the Tags table.
                        var sqlTag = "
                            INSERT INTO tags (name, color)
                            VALUES (:name, :color)
                            ON DUPLICATE KEY UPDATE color = VALUES(color)
                        ";
                        var paramsTag = { name = tagName, color = tagColor };
                        queryExecute(sqlTag, paramsTag, { datasource = "sg" });

                        
                        
                        // Retrieve the tag_id for the tag.
                        var sqlGetTag = "SELECT tag_id FROM tags WHERE name = :name";
                        var tagResult = queryExecute(sqlGetTag, { name = tagName }, { datasource = "sg" });
                        if (tagResult.recordCount > 0) {
                            var tagId = tagResult.tag_id[1];
                            
                            // Insert the mapping into RecipeTags.
                            var sqlMapping = "
                                INSERT INTO recipetags (recipe_id, tag_id)
                                VALUES (:recipe_id, :tag_id)
                                ON DUPLICATE KEY UPDATE recipe_id = recipe_id
                            ";
                            var paramsMapping = { recipe_id = meal.id, tag_id = tagId };
                            queryExecute(sqlMapping, paramsMapping, { datasource = "sg" });
                        }
                    }
                }
            }
            
            result.status = "success";
            result.msg = "Sides updates processed successfully.";
        } catch (any e) {
            result.status = "error";
            result.msg = "Error processing meal updates: " & e.message;
        }
        // abort;
        return result;
    }

    /**
     * Converts a ColdFusion date object into a MySQL datetime string.
     * If you ever need to adjust time zones or validation logic, it’s all in one place.
     *
     * @param trelloDate A ColdFusion date object.
     * @return A string in the format "yyyy-mm-dd HH:mm:ss".
     */
    private string function formatTrelloDate(required date trelloDate) {
        return dateFormat(trelloDate, "yyyy-mm-dd") & " " & timeFormat(trelloDate, "HH:mm:ss");
    }

    public void function addLogEntry(required any logItem) {
        var logMessage = "";
        try {
            // If the logItem is an array or a structure, convert it to a JSON string.
            if (isArray(arguments.logItem) || isStruct(arguments.logItem)) {
                logMessage = serializeJSON(arguments.logItem);
            } else {
                logMessage = arguments.logItem;
            }
            
            // Build the insert query.
            var sql = "INSERT INTO log (entry) VALUES (:logMessage)";
            var params = { logMessage = logMessage };

            // Execute the query. Replace "sg" with your actual datasource name.
            queryExecute(sql, params, { datasource = "sg" });
        } catch (any ex) {
            // Optionally log the error or rethrow.
            writeLog(type="error", text="addLogEntry failed: " & ex.message);
        }
    }

// ingredientInventory 
    /**
     * Remote function to get the ingredient inventory as an array-of-structures.
     */
    remote any function getInventory() {
        var sql = "SELECT id, ingredient_name, quantity_on_hand, desired_inventory_level, sort_order  FROM ingredient_inventory order by sort_order";
        var params = {};
        var options = { datasource = variables.datasource };
        // Execute the query.
        var qInventory = queryExecute(sql, params, options);
        
        // Convert the query object to an array of structures.
        var result.data = [];
        for (var i = 1; i <= qInventory.recordCount; i++) {
            arrayAppend(result.data, {
                sort_order: qInventory.sort_order[i],
                id: qInventory.id[i],
                ingredient_name: qInventory.ingredient_name[i],
                quantity_on_hand: qInventory.quantity_on_hand[i],
                desired_inventory_level: qInventory.desired_inventory_level[i]
            });
        }

        // Return the array; when serializing to JSON this will produce an array of objects.
        return result;
    }
    
    /**
     * Remote function to update an inventory field.
     * Only 'quantity_on_hand' or 'desired_inventory_level' are allowed.
     */
    remote void function updateInventory(required numeric id, required string field, required numeric value) returnformat="json" {
        // Validate the allowed field names.
        if ( listFindNoCase("quantity_on_hand,desired_inventory_level", arguments.field) EQ 0 ) {
            throw(type="InvalidField", message="Invalid field specified for update.");
        }
        var sql = "UPDATE ingredient_inventory SET " & arguments.field & " = :val WHERE id = :id";
        var params = { 
            val = arguments.value, 
            id = arguments.id 
        };
        var options = { datasource = variables.datasource };
        queryExecute(sql, params, options);
    }

    /**
     * Remote function to update the order of inventory items.
     * Expects a JSON string representing an array of objects, each with properties:
     *    { "id": <id>, "order": <newSortOrder> }
     * For example: [ { "id": 2, "order": 1 }, { "id": 5, "order": 2 }, ... ]
     */
    // remote string function updateOrder(required string order) returnformat="json"{
    //     // writeOutput(arguments.order);
    //     // abort;
    //     try {
    //         // Convert the incoming JSON string to an array of structures.
    //         orderData = deserializeJSON(arguments.order);
    //         for (i=1; i <= arrayLen(orderData); i++) {
    //             // dump(orderData[i]);
    //             // Update each record's sort_order based on the newOrder field.
    //             queryExecute(
    //                 "UPDATE ingredient_inventory SET sort_order = :newOrder WHERE id = :id",
    //                 { newOrder = orderData[i].newOrder, id = orderData[i].id },
    //                 {datasource = variables.datasource}
    //             );

        
    //         }
            
    //     //     return "Order updated successfully";
    //         return order;
    //     } catch(e) {
    //         return "Error updating order: " & e.message;
    //     }
    // }
    remote any function updateOrder(required string order) {

        try {
            
            // Deserialize the JSON string from the arguments scope
            var orderData = deserializeJSON(arguments.order);
            
            // Loop through the array and update each record's sort_order in the database
            for (var i = 1; i <= arrayLen(orderData); i++) {
                // Use queryExecute with parameter binding for security
                queryExecute(
                    "UPDATE ingredient_inventory SET sort_order = :newOrder WHERE id = :id",
                    {
                        newOrder: { value = orderData[i].newOrder, cfsqltype = "cf_sql_integer" },
                        id:       { value = orderData[i].id,       cfsqltype = "cf_sql_integer" }
                    },
                    { datasource = "sg" } 
                );
            }

            msg = 'Order updated successfully';
            
            return orderData;
        } catch (any e) {
            return "Error updating order: " & e.message;
        }
    }



    /**
     * Method to retrieve recipes for review
     * @access remote
     * @returntype string
     */
    // GET /api/Inventory.cfc?method=getMeals
    //  remote function reviewrecipes() httpmethod="GET" returnformat="JSON" {
    //     var categories = queryExecute(
    //         "SELECT recipe_id, name, description, date_last_activity 
    //              FROM recipes 
    //              ORDER BY name",
    //         {},
    //         { datasource = "sg" }
    //     );
        
    //     return categories;
    // } 

    remote function reviewrecipes() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
            "SELECT recipe_id, name, description, date_last_activity, isAdded
             FROM recipes 
             ORDER BY isAdded asc, name",
            {},
            { datasource = "sg" }
        );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                recipe_id = row.recipe_id
                , name = row.name
                , description = row.description
                , date_last_activity = row.date_last_activity                
                , isAdded = row.isAdded                
            });
        }

        return results;
    }
    
    /**
     * Method to add a recipe to meals
     * @access remote
     * @recipe_id The ID of the recipe to add
     * @name The name of the recipe to add
     * @returntype string
     */
    remote string function addToMeals(required string recipe_id, required string name) returnformat="JSON" {
        try {
            var insertedId = 0;
            
            // First check if the recipe already exists in meals
            var existingCheck = queryExecute(
                "SELECT id FROM meals WHERE recipe_id = :recipe_id",
                {
                    recipe_id: {value=arguments.recipe_id, cfsqltype="cf_sql_varchar"}
                },
                {datasource="sg"}
            );
            
            // If recipe already exists, return early with that information
            if (existingCheck.recordCount > 0) {
                return serializeJSON({
                    success: true,
                    message: "#arguments.name# was already in your meal plan",
                    id: existingCheck.id,
                    alreadyExists: true
                });
            }
            
            // If we get here, the recipe doesn't exist yet, so add it
            transaction {
                // Insert into meals table and get the ID
                var qInsert = queryExecute(
                    "INSERT INTO meals (recipe_id, title, details)
                     SELECT recipe_id, name, description
                     FROM recipes
                     WHERE recipe_id = :recipe_id",
                    {
                        recipe_id: {value=arguments.recipe_id, cfsqltype="cf_sql_varchar"}
                    },
                    {datasource="sg", result="insertResult"}
                );
                
                // Get the inserted ID from the result
                insertedId = insertResult.generatedKey;
                
                // Update recipes table
                queryExecute(
                    "UPDATE RECIPES SET isAdded = 1 WHERE recipe_id = :recipe_id",
                    {
                        recipe_id: {value=arguments.recipe_id, cfsqltype="cf_sql_varchar"}
                    },
                    {datasource="sg"}
                );
            }
            
            return serializeJSON({
                success: true,
                message: "#arguments.name# added successfully",
                id: insertedId,
                alreadyExists: false
            });
            
        } catch (any e) {
            return serializeJSON({
                success: false,
                message: "Error adding recipe: " & e.message
            });
        }
    }

    // remote function getRecipeDetails() returnformat="JSON" {
    //     param name="recipeId";
        
    //     var result = {
    //         "success" = false,
    //         "message" = "",
    //         "data" = {}
    //     };
        
    //     try {
    //         if (len(url.recipe_id) == 0) {
    //             result.message = "Recipe ID is required";
    //             return serializeJSON(result);
    //         }
            
    //         var qRecipe = queryExecute(
    //             "SELECT 
    //                 recipe_id,
    //                 name,
    //                 description,
    //                 date_last_activity,
    //                 isAdded
    //             FROM 
    //                 recipes
    //             WHERE 
    //                 recipe_id = :recipe_id",
    //             { recipe_id = { value = url.recipe_id, cfsqltype = "cf_sql_varchar" } },
    //             { datasource = "sg" }
    //         );
            
    //         if (qRecipe.recordCount > 0) {
    //             result.success = true;
    //             result.data = {
    //                 "recipe_id" = qRecipe.recipe_id,
    //                 "name" = qRecipe.name,
    //                 "description" = qRecipe.description,
    //                 "date_last_activity" = qRecipe.date_last_activity,
    //                 "isAdded" = qRecipe.isAdded
    //             };
    //         } else {
    //             result.message = "Recipe not found";
    //         }
    //     } catch (any e) {
    //         result.message = "Error retrieving recipe: " & e.message;
    //     }
        
    //     return serializeJSON(result);
    // }

    remote function getRecipeDetails() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT 
                    recipe_id,
                    name,
                    description,
                    date_last_activity,
                    isAdded
                FROM 
                    recipes
                WHERE 
                    recipe_id = :recipe_id",
                { recipe_id = { value = url.recipe_id, cfsqltype = "cf_sql_varchar" } },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                recipe_id = row.recipe_id
                , name = row.name
                , description = row.description
            });
        }

        return results;
    }


    remote function measurementunits() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT id, CONCAT(unit_name, ' (', base_unit, ')') AS unit_name, base_unit, unit_type
                FROM measurementunits
                ORDER BY unit_name",
                {  },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                id = row.id
                , name = row.unit_name
                , base_unit = row.base_unit
                , unit_type = row.unit_type
            });
        }

        return results;
    }


    remote function ingredients() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT ingredient_name, ingredientID
                    FROM raw_ingredients
                    ORDER BY ingredient_name",
                {  },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                id = row.ingredientID
                , name = row.ingredient_name
            });
        }

        return results;
    }

    remote function mealtypes() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT typeID, typeName, typeColor
                FROM mealtype
                ORDER BY typeName",
                {  },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                typeID = row.typeID
                , typeName = row.typeName
                , typeColor = row.typecolor                
            });
        }

        return results;
    }

    remote function mealtypesForSelectOption() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT typeID, typeName
                FROM mealtype
                ORDER BY typeName",
                {  },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                id = row.typeID,
                text = row.typeName,
                value = row.typeID
            });
        }

        return results;
    }

    remote function quantity_options() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT id, optionValue, textValue
                FROM quantity_options
                ORDER BY textValue",
                {  },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                id = row.id
                , optionValue = row.optionValue
                , textValue = row.textValue                
            });
        }

        return results;
    }

    remote function tags() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT tag_id, NAME, color
                FROM tags
                ORDER BY name",
                {  },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                tag_id = row.tag_id
                , name = row.NAME
                , color = row.color                
            });
        }

        return results;
    }

    remote function categories() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
                "SELECT id, NAME as catname, description
                FROM categories
                ORDER BY name",
                {  },
                { datasource = "sg" }
            );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                id = row.id
                , catname = row.catname
                , description = row.description                
            });
        }

        return results;
    }






}
