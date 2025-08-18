<cfscript>
mealName = url.mealName ?: "Untitled Meal";
ingredientsJson = url.ingredients ?: "[]";
ingredients = deserializeJSON(ingredientsJson);

// Insert the meal
insertMealQuery = new Query();
insertMealQuery.setDatasource("sg");
insertMealQuery.setSQL("INSERT INTO Meals (meal_name) VALUES (?)");
insertMealQuery.addParam(name="meal_name", value=mealName, cfsqltype="cf_sql_varchar");
result = insertMealQuery.execute();
mealId = result.getPrefix().getGeneratedKey();

dump(insertMealQuery);
abort;

// Insert each ingredient
for (ingredient in ingredients) {
    insertIngredientQuery = new Query();
    insertIngredientQuery.setDatasource("sg");
    insertIngredientQuery.setSQL("
        INSERT INTO Ingredients (meal_id, name, quantity, unit)
        VALUES (?, ?, ?, ?)
    ");
    insertIngredientQuery.addParam(name="meal_id", value=mealId, cfsqltype="cf_sql_integer");
    insertIngredientQuery.addParam(name="name", value=ingredient.name, cfsqltype="cf_sql_varchar");
    insertIngredientQuery.addParam(name="quantity", value=ingredient.quantity, cfsqltype="cf_sql_decimal");
    insertIngredientQuery.addParam(name="unit", value=ingredient.unit, cfsqltype="cf_sql_varchar");
    insertIngredientQuery.execute();
}

// Return JSON response
writeOutput(serializeJSON({ "status": "success" }));
</cfscript>
