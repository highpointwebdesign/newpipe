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
		            quantityIDArray = listToArray(form.quantityID);
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
							    "INSERT INTO meal_ingredients (mealID, ingredientID, quantityID, unit)
							     SELECT :mealId, :ingredientID, :quantityID, :unit
							     WHERE :ingredientID > 0",
							    {
							        mealId      : form.mealId,
							        ingredientID: ingredientIDArray[i],
							        quantityID  : quantityIDArray[i],
							        unit        : uomArray[i]
							    },
							    { datasource = 'sg' }
							);
							} catch (any e) {
							    // Log the error but continue with the next iteration
							    writeLog(file="mealplanner", text="Error inserting ingredient #i#: #e.message#");							    
							    result.status=0;
							    result.msg = 'We dropped the fork on this one. The Chef has been notified.'; 
							    location url="/meal_crud.cfm?id=#form.mealID#&action=#form.action#&status=#result.status#&msg=#result.msg###bottom" addtoken="false";
							}
						}
			        }
			</cfscript>
			
			
			<cfif form.action eq 'addIngredient'>
				<cfset result.msg ="Ingredient added.">
				<cfset result.status = 1>
				<cflocation url="meal_crud.cfm?id=#form.mealID#&action=#form.action#&status=#result.status#&msg=#result.msg###bottom" addtoken="false">
			<cfelse>
				<cfset result.msg ="Meal has been saved.">
				<cfset result.status = 1>
				<cflocation url="/?action=#form.action#&status=#result.status#&msg=#result.msg#" addtoken="false">
			</cfif>



	</cfcase>

	<cfcase value="removeIngredient">
		<!--- remove --->
		
		<cfscript>
		try{

			queryExecute(
                "delete from meal_ingredients WHERE mealId = :mealId and miID = :miID",
                { 
                    miID = url.miID, 
                    mealID = url.id
                },
                { datasource = 'sg' }
            );

		} catch (any e) {
		    // Log the error but continue with the next iteration
		    writeLog(file="mealplanner", text="Error removing ingredient #i#: #e.message#");							    
		    result.status=0;
		    result.msg = 'We forked this up and were not able to remove the ingredient. The Chef has been notified.'; 
		}
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
	<a href="meal_crud.cfm?id=#form.mealID#&status=1&action=#form.action#&status=#result.status#&msg=#result.msg###bottom">continue.</a>
	<cflocation url="meal_crud.cfm?id=#form.mealID#&status=1&action=#form.action#&status=#result.status#&msg=#result.msg###bottom" addtoken="false">
<cfif structKeyExists(form, 'action') && form.action eq 'savemeal'>
<br/>
<a href="/?status=1&action=#form.action#&status=#result.status#&msg=#result.msg#">save meal and done</a>
</cfif>
</cfoutput>