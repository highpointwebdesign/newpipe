<cfparam name="result.status" default="0">
<cfparam name="result.msg" default="Unable to provide a status update at this time.">
<cfparam name="url.action" default="error">
<cfparam name="form.action" default="#url.action#">

<cfparam name="form.mealID" default="0">

<cfdump var="#form#" label="form">
<cfdump var="#url#" label="url">

<cfif structKeyExists(url, 'ID')>
	<cfset form.mealID = url.iD>
</cfif>


<cfswitch expression="#form.action#">
	<cfcase value="addIngredient,savemeal">
		<!--- add --->
			<cfscript>	
		        // Insert each ingredient.
		            ingredient_quantityArray = listToArray(form.ingredient_quantity);
		            ingredientIDArray = listToArray(form.ingredientID);
		            uomArray = listToArray(form.uom);
        
			        transaction {
			            // Update the meal record.
			            queryExecute(
			                "UPDATE meals SET title = :title, servings = :servings,  mealTypeID = :mealTypeID, details = :details WHERE mealId = :mealId",
			                { 
			                    title = form.mealTitle, 
			                    servings = form.servings, 
			                    mealTypeID = form.mealTypeID, 
			                    details = form.details, 
			                    mealId = form.mealId },
			                { datasource = 'sg' }
			            );
			            
			            // Remove all existing ingredients for this meal.
			            queryExecute(
			                "DELETE FROM meal_ingredients WHERE mealID = :mealId",
			                { mealId = form.mealId },
			                { datasource = 'sg' }
			            );
			            
						// Insert each ingredient
			            	// ENHANCEMENT: Create a query batch for better performance
						for (i = 1; i <= arrayLen(ingredientIDArray); i++) {
						 try {
						    queryExecute(
						        "INSERT INTO meal_ingredients (mealID, ingredientID, quantity, unit) VALUES (:mealId, :ingredientID, :quantity, :unit)",
						        {
						            mealId      : form.mealId,
						            ingredientID: ingredientIDArray[i],
						            quantity    : ingredient_quantityArray[i],
						            unit        : uomArray[i]
						        },
						        { datasource = 'sg' }
						    );
							} catch (any e) {
							    // Log the error but continue with the next iteration
							    writeLog(file="mealplanner", text="Error inserting ingredient #i#: #e.message#");
							}
						}
			        }
			</cfscript>
			<cfset result.msg ="Ingredient added...">
			<cfif form.action eq 'addIngredient'>
				<cflocation url="meal_crud.cfm?id=#form.mealID#&status=1&action=#form.action#&status=#result.status#&msg=#result.msg#" addtoken="false">
			<cfelse>
				<cflocation url="/?status=1&action=#form.action#&status=#result.status#&msg=#result.msg#" addtoken="false">
			</cfif>



	</cfcase>

	<cfcase value="removeIngredient">
		<!--- remove --->
		
		<cfscript>
			queryExecute(
                "delete from meal_ingredients WHERE mealId = :mealId and miID = :miID",
                { 
                    miID = url.miID, 
                    mealID = url.id
                },
                { datasource = 'sg' }
            );
		</cfscript>

	</cfcase>

	<cfcase value="refire">
		<!--- edit --->

	</cfcase>

	<cfdefaultcase>
		<!--- do nothing --->

	</cfdefaultcase>

</cfswitch>


<!--- <cflocation url="meal_crud.cfm?id=#form.id#&status=1&action=#form.action#&status=#result.status#&msg=#result.msg#" addtoken="false"> --->
<cfoutput>
<a href="meal_crud.cfm?id=#form.mealID#&status=1&action=#form.action#&status=#result.status#&msg=#result.msg#">continue.</a>

<cfif structKeyExists(form, 'action') && form.action eq 'savemeal'>
<br/>
<a href="/?status=1&action=#form.action#&status=#result.status#&msg=#result.msg#">save meal and done</a>
</cfif>
</cfoutput>