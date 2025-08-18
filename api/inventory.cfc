component {

    // GET /api/Inventory.cfc?method=list
    remote function list() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
            "SELECT i.id, i.name, i.desired_quantity, i.current_quantity, i.reorder_threshold, c.name AS category_name
             FROM items i
             JOIN categories c ON i.category_id = c.id
             ORDER BY category_name, i.name",
            {},
            { datasource = "sg" }
        );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                id = row.id
                , name = row.name
                , category_name = row.category_name
                , current_quantity = row.current_quantity
                , desired_quantity = row.desired_quantity
                , reorder_threshold = row.reorder_threshold
            });
        }

        return results;
    }

    // GET /api/Inventory.cfc?method=get&id=1
    remote function getItem(required numeric id) httpmethod="GET" returnformat="JSON" {
        var item = queryExecute(
            "SELECT id, name, category_id, desired_quantity, reorder_threshold, current_quantity
             FROM items
             WHERE id = :id",
            { id = arguments.id },
            { datasource = "sg" }
        );
        
        if (item.recordCount == 1) {
            return item.getRow(1);
        } else {
            return { error = "Item not found" };
        }
    }

    // POST /api/Inventory.cfc?method=add
    remote function add(
        required string name,
        required numeric category_id,
        numeric current_quantity = 0,
        numeric desired_quantity = 0,
        numeric reorder_threshold = 0
    ) httpmethod="POST" returnformat="JSON" {
        var result = {};
        
        transaction {
            try {
                // Insert into items table
                queryExecute(
                    "INSERT INTO items (name, category_id, desired_quantity, reorder_threshold, current_quantity)
                     VALUES (:name, :category_id, :desired_quantity, :reorder_threshold, :current_quantity)",
                    {
                        name = arguments.name,
                        category_id = arguments.category_id,
                        desired_quantity = arguments.desired_quantity,
                        reorder_threshold = arguments.reorder_threshold,
                        current_quantity = arguments.current_quantity
                    },
                    { datasource = "sg" }
                );

                // Get the last insert ID
                var qLastId = queryExecute(
                    "SELECT LAST_INSERT_ID() AS id",
                    {},
                    { datasource = "sg" }
                );
                var itemId = qLastId.id[1];

                result = { success = true, id = itemId };
            } catch (any e) {
                transaction action="rollback";
                result = { success = false, error = e.message };
            }
        }

        return result;
    }

    // POST /api/Inventory.cfc?method=update&id=1
    remote function updateItem(
        required numeric id,
        required string name,
        required numeric category_id,
        required numeric current_quantity,
        required numeric desired_quantity,
        required numeric reorder_threshold
    ) httpmethod="POST" returnformat="JSON" {
        var result = {};
        
        transaction {
            try {
                // Update items table
                queryExecute(
                    "UPDATE items
                     SET name = :name, category_id = :category_id, desired_quantity = :desired_quantity, 
                         reorder_threshold = :reorder_threshold, current_quantity = :current_quantity
                     WHERE id = :id",
                    {
                        id = arguments.id,
                        name = arguments.name,
                        category_id = arguments.category_id,
                        desired_quantity = arguments.desired_quantity,
                        reorder_threshold = arguments.reorder_threshold,
                        current_quantity = arguments.current_quantity
                    },
                    { datasource = "sg" }
                );

                result = { success = true };
            } catch (any e) {
                transaction action="rollback";
                result = { success = false, error = e.message };
            }
        }

        return result;
    }

    // POST /api/Inventory.cfc?method=delete&id=1
    remote function deleteItem(required numeric id) httpmethod="POST" returnformat="JSON" {
        queryExecute(
            "DELETE FROM items WHERE id = :id",
            { id = arguments.id },
            { datasource = "sg" }
        );

        return { success = true };
    }

    remote function getCategories() httpmethod="GET" returnformat="JSON" {
        var categories = queryExecute(
            "SELECT id, name FROM categories ORDER BY name",
            {},
            { datasource = "sg" }
        );
        
        return categories;
    }    

    remote function loadMealTypes() httpmethod="GET" returnformat="JSON" {
        var categories = queryExecute(
            "SELECT typeID, typeName, typeColor FROM mealtype ORDER BY typeName",
            {},
            { datasource = "sg" }
        );
        
        return categories;
    }

    // shopping list
    remote function getShoppingList() httpmethod="GET" returnformat="JSON" {
        var shoppingList = queryExecute(
            "SELECT 
                c.name AS category_name, 
                i.id, 
                i.name, 
                i.desired_quantity, 
                i.current_quantity,
                CASE 
                    WHEN i.current_quantity < i.desired_quantity THEN i.desired_quantity - i.current_quantity
                    ELSE 0
                END AS quantity_to_buy
            FROM items i
            JOIN categories c ON i.category_id = c.id
            HAVING quantity_to_buy > 0
            ORDER BY c.name, i.name",
            {},
            {datasource = "sg"}
        );
        return shoppingList;
    }

    // CATEGORIES
    remote function addCategory(
        required string name
    ) httpmethod="POST" returnformat="JSON" {
        var result = {};
        
        transaction {
            try {
                // Insert into categories table
                queryExecute(
                    "INSERT INTO categories (name) VALUES (:name)",
                        { name: { value: arguments.name, cfsqltype: "cf_sql_varchar" } },
                        {datasource = "sg"}
                );

                result = { success = true};
            } catch (any e) {
                transaction action="rollback";
                result = { success = false, error = e.message };
            }
        }

        return result;
    }    

    remote function addMealType(
        required string name
    ) httpmethod="POST" returnformat="JSON" {
        var result = {};
        
        transaction {
            try {
                // Insert into categories table
                queryExecute(
                    "INSERT INTO mealtype (typeName) VALUES (:name)",
                        { name: { value: arguments.name, cfsqltype: "cf_sql_varchar" } },
                        {datasource = "sg"}
                );

                result = { success = true};
            } catch (any e) {
                transaction action="rollback";
                result = { success = false, error = e.message };
            }
        }

        return result;
    }

    // POST /api/Inventory.cfc?method=delete&id=1
    remote function deleteCategory(required numeric id) httpmethod="POST" returnformat="JSON" {
        queryExecute(
            "DELETE FROM categories WHERE id = :id",
            { id: { value: arguments.id, cfsqltype: "cf_sql_integer" } },
            { datasource = "sg" }
        );       

        return { success = true };
    }

    remote function deleteMealType(required numeric id) httpmethod="POST" returnformat="JSON" {
        queryExecute(
            "DELETE FROM mealtype WHERE typeID = :id",
            { id: { value: arguments.id, cfsqltype: "cf_sql_integer" } },
            { datasource = "sg" }
        );       

        return { success = true };
    }

    // get /api/Inventory.cfc?method=updateQuantity
    remote struct function updateInventoryFromShoppingList(
        required numeric itemId,
        required boolean isChecked,
        required numeric quantityToBuy
        ) returnformat="json" access="remote" {

        // Local variables container
        var local = {
          success: false,
          message: "",
          currentQty: 0,
          newQty: 0
        };

        try {
          // Fetch current_quantity
          var getQ = queryExecute(
            "SELECT current_quantity FROM items WHERE id=:id",
            { id = arguments.itemId },
            { datasource = "sg" }
          );

          if (getQ.recordCount == 0) {
            local.message = "Item not found";
            return local;
          }

          local.currentQty = getQ.current_quantity[1];

          // Compute new quantity
          if (arguments.isChecked) {
            local.newQty = local.currentQty + arguments.quantityToBuy;
          } else {
            local.newQty = local.currentQty - arguments.quantityToBuy;
            if (local.newQty < 0) {
              local.message = "Cannot reduce inventory below zero";
              return local;
            }
          }

          // Update in a transaction to prevent races
          transaction {
            queryExecute(
              "UPDATE items SET current_quantity = :newQty WHERE id = :id",
              {
                newQty = local.newQty,
                id     = arguments.itemId
              },
              { datasource = "sg" }
            );
          }

          local.success = true;
          local.message = "Inventory updated successfully";
        }
        catch (any e) {
          local.message = "Error updating inventory: " & e.message;
        }

        return local;
    }


    remote function deleteMeal(required string meal_id) httpmethod="POST" returnformat="JSON" {
        try {
            queryExecute(
                "DELETE FROM Meals WHERE meal_id = :meal_id",
                { meal_id = arguments.meal_id },
                { datasource = "sg" }
            );
            transaction action="commit";
            return { success = true };
        } catch (any e) {
            // Rollback everything if any error occurs
            transaction action="rollback";
            result = { success = false, error = e.message };
        }
    }

    remote function saveMeal(required string meal_name, required string ingredients) httpmethod="POST" returnformat="JSON" {
        var result = {};

        transaction {
            try {
                // Insert the meal into Meals table
                var qMealInsert = queryExecute(
                    "INSERT INTO Meals (meal_name) VALUES (:meal_name)",
                    { meal_name = arguments.meal_name },
                    { datasource = "sg" }
                );

                // Retrieve the last inserted meal ID
                var qLastId = queryExecute(
                    "SELECT LAST_INSERT_ID() AS meal_ID",
                    {},
                    { datasource = "sg" }
                );
                var meal_ID = qLastId.meal_ID[1];

                // Deserialize ingredients JSON
                var ingredientList = deserializeJSON(arguments.ingredients);

                // Insert ingredients for this meal within the same transaction
                for (var ingredient in ingredientList) {
                    queryExecute(
                        "INSERT INTO Ingredients (meal_id, ingredient, quantity, unit)
                         VALUES (:meal_id, :ingredient, :quantity, :unit)",
                        {
                            meal_id = meal_ID,
                            ingredient = ingredient.ingredient,
                            quantity = ingredient.quantity,
                            unit = ingredient.unit
                        },
                        { datasource = "sg" }
                    );
                }

                // If all operations succeed, return success
                result = {
                    success = true,
                    meal_ID = meal_ID,
                    ingredientStatus = { mealIngredientSuccess: true, count: arrayLen(ingredientList) }
                };
            } catch (any e) {
                // Rollback everything if any error occurs
                transaction action="rollback";
                result = { success = false, error = e.message };
            }
        }

        return result;
    }
   
   //  // meal planning functions
   //  remote function saveMealName(required string meal_name, required string ingredients) httpmethod="POST" returnformat="JSON" {
   //      var result = {};

   //      transaction {
   //          try {
   //              // Insert into Meals table
   //              queryExecute(
   //                  "INSERT INTO Meals (meal_name) VALUES (:meal_name)",
   //                  { meal_name = arguments.meal_name },
   //                  { datasource = "sg" }
   //              );

   //              // Get the last inserted meal ID
   //              var qLastId = queryExecute(
   //                  "SELECT LAST_INSERT_ID() AS meal_ID",
   //                  {},
   //                  { datasource = "sg" }
   //              );
   //              var meal_ID = qLastId.meal_ID[1];

   //              // Save ingredients and capture result
   //              var ingredientResult = saveMealIngredients(meal_ID = meal_ID, ingredients = arguments.ingredients);

   //              // Return success
   //              result = {
   //                  success = true,
   //                  meal_ID = meal_ID,
   //                  ingredientStatus = ingredientResult
   //              };
   //          } catch (any e) {
   //              transaction action="rollback";
   //              result = { success = false, error = e.message };
   //          }
   //      }

   //      return result;
   //  }


   // public struct function saveMealIngredients(required numeric meal_ID, required string ingredients) {
   //      try {
   //          var ingredientList = deserializeJSON(arguments.ingredients);
   //          // writeOutput(arguments.ingredients);
            


   //          for (ingredient in ingredientList) {
   //              // writeOutput(ingredient.ingredient);

   //              queryExecute(
   //                  "INSERT INTO Ingredients (meal_id, ingredient, quantity, unit)
   //                   VALUES (:meal_id, :ingredient, :quantity, :unit)",
   //                  {
   //                      meal_id = arguments.meal_ID,
   //                      ingredient = ingredient.ingredient,
   //                      quantity = ingredient.quantity,
   //                      unit = ingredient.unit
   //                  },
   //                  { datasource = "sg" }
   //              );
   //          }
   //          return { mealIngredientSuccess = true, count = arrayLen(ingredientList) };
   //      } catch (any e) {
   //          return { mealIngredientSuccess = false, error = e.message };
   //      }
   //  }


    // GET /api/Inventory.cfc?method=getMeals
    remote function getMeals() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
            "SELECT meal_id, meal_name FROM Meals
                ORDER BY meal_name",
            {},
            { datasource = "sg" }
        );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                meal_id = row.meal_id
                , meal_name = row.meal_name
            });
        }

        return results;
    }

    remote function getRecipe(required numeric id) httpmethod="POST" returnformat="JSON" {
    var q = queryExecute(
        "Select
            m.meal_name,
            m.meal_id,
            i.ingredient,
            i.quantity,
            i.unit,
            i.ingredient_id
        From
            dbrhzbrqhhlw5g.Meals m Inner Join
            dbrhzbrqhhlw5g.Ingredients i On i.meal_id = m.meal_id
        WHERE
            m.meal_id = :id
        ORDER BY
            i.ingredient",
        { id = arguments.id },
        { datasource = "sg" }
    );

    var results = {};

    for (var row in q) {
        if (!structKeyExists(results, row.meal_id)) {
            results[row.meal_id] = {
                meal_id = row.meal_id,
                success = true,
                meal_name = row.meal_name,
                ingredients = []
            };
        }

        // Append ingredient as an object with quantity & unit
        arrayAppend(results[row.meal_id].ingredients, {
            ingredient = row.ingredient,
            quantity = row.quantity,
            unit = row.unit
        });
    }

    // Convert struct to array manually
    var resultArray = [];
    for (var key in results) {
        arrayAppend(resultArray, results[key]);
    }

    return resultArray;
    }

    remote function getMeasurementUnits() httpmethod="GET" returnformat="JSON" {
        var q = queryExecute(
            "SELECT id, unit_name, base_unit, unit_type FROM measurementunits ORDER BY unit_type, unit_name",
            {},
            { datasource = "sg" }
        );

        var results = [];
        for (var row in q) {
            arrayAppend(results, {
                id = row.id
                , unit_name = row.unit_name
                , base_unit = row.base_unit
                , unit_type = row.unit_type
            });
        }

        return results;

    }




}