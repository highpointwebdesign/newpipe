<cfscript>

mealplanner = createObject("component", "api.mealplanner");
getMealCard = mealplanner.getMealById(url.id);
// dump(getMealCard);
</cfscript>

<cfquery name="ingredients" datasource="sg">
Select
    i.ingredientID,
    i.ingredient_name
From
    raw_ingredients i
Order By
    i.ingredient_name
</cfquery>

<cfquery name="UoM" datasource="sg">
Select
    uom.unitID,
    uom.unitName,
    uom.baseUnit,
    uom.unitType
From
    measurementunits uom
Order By
    uom.unitName
</cfquery>

<cfquery name="mealtype" datasource="sg">
Select
    m.mealTypeID,
    m.mealTypeName,
    m.mealTypeColor
From
    meal_types m
Order By
    m.mealTypeName
</cfquery>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Meal Planner</title>
  <!--- select2 --->
  <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <!-- Bootstrap Icons (for trash can icon) -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" />
  <!-- <link href="css/main.css?verion=1" rel="stylesheet"> -->
  <link href="css/styles.css?verion=1" rel="stylesheet">
  <link href="css/index.css?verion=1" rel="stylesheet">



  <style>
    #mealType {
      line-height:3.0 !important
    }
  </style>
</head>
<body data-typography="roboto" data-theme-version="light" data-layout="horizontal">
  
    <!--**********************************
            Sidebar start
        ***********************************-->
          <div class="dlabnav">
            <div class="dlabnav-scroll">
                <ul class="metismenu" id="menu">
                  <li><a href="index.htm">RV MEAL PLANNER</a></li>
                  <li><a class="nav-link" href="/" id="menu-recipes">MEAL CARDS</a></li>
                  <li><a class="nav-link" href="calendar.cfm" id="menu-calendar">MEAL PLANNER</a></li>
                  <li><a class="nav-link" href="mealplannershoppinglist.htm" id="menu-shopping_list">SHOPPING LIST</a></li>
                  <li><a class="nav-link" href="inventoryMgmt.htm" id="menu-shopping_list">INVENTORY MGMT (Beta)</a></li>
                </ul>
            </div>
          </div>
    <!--**********************************
            Sidebar end
        ***********************************-->
  <div class="content-body">

    <div class="row">
      <div class="col-sm-2">
        <!--- <div class="position-sticky" style="top: 2rem;">
          <div class="p-4">
            <h3 class="mb-4 border-bottom">
              Actions
            </h3>            
              <div class="d-grid gap-2">
              <!-- <li><a href="#">April 2020</a></li> -->
                <a class="btn btn-primary" href="#" id="menu-add">Toggle Meal Form</a>
                <!-- <a class="btn btn-primary" href="#" id="menu-shopping">Shopping List</a> -->
                <a class="btn btn-secondary" href="#" id="menu-importFromTrello">Update Database</a>
              </div>
          </div>        
        </div> --->
      </div>
      <div class="col-sm-9">
        <h3 class="mb-4 border-bottom" style="padding-top: 20px;">
          <cfif structKeyExists(url, 'id')>
          	Edit
          <cfelse>
          	Add 
          </cfif>
          Meal Card
        </h3>            
        <!-- main content here -->

        <!-- Collapsible Add Meal Section -->
        <form id="MealFormAddEdit" action="meal_crud_process.cfm" method="post">
          <div id="addMealSection" class="mb-3">
            <div class="card">
              <div class="card-header">
                <h5 class="card-title">Meal Details</h5>
              </div>
              <div class="card-body">
                  <input type="hidden" id="mealId" value="">
                  <div class="mb-3">
                    <label for="mealTitle" class="form-label">Meal Title</label>
                    <cfoutput><input type="text" class="form-control" id="mealTitle" name="mealTitle" required value="#getMealCard.title#" /></cfoutput>
                  </div>
                  <!-- New row for Servings and Meal Type -->
                  <div class="mb-3">
                    <div class="row">
                      <div class="col-md-6">
                        <label for="servings" class="form-label">Servings</label>
                        <cfoutput>
                        	<input type="number" class="form-control" id="servings" name="servings" value="#getMealCard.servings#" step="2" required/>
                        </cfoutput>
                      </div>
                      <div class="col-md-6">
                        <label for="mealTypeID" class="form-label">Meal Type</label>
                        <select id="mealTypeID" name="mealTypeID" class="form-control" required>
                          <option value="0">Select Meal Type</option> <!-- Empty option for placeholder -->
                          <cfoutput query="mealtype">
                          	<option value="#mealType.mealTypeID#" <cfif mealType.mealTypeID eq getMealCard.mealTypeID>selected</cfif>  >#mealType.mealTypeName#</option>
                          </cfoutput>
                        </select>
                      </div>
                    </div>
                    <div class="row">
                      <div class="col-md-12">
                          <label for="details" class="form-label">Directions</label>
                          <!-- https://rohanyeole.com/ray-editor/ for future WYSIWYG -->
                         <cfoutput><textarea class="form-control" rows="9" id="details" spellcheck="false" name="details">#getMealCard.details#</textarea></cfoutput>
                      </div>
                    </div>
                  </div>

                  <div id="ingredientsContainer">
                    <!-- <label class="form-label">Ingredients</label> -->
                    <label class="form-label">Ingredients</label>
                    <cfoutput query="getMealCard">
	                    <div class="ingredient-row row mb-2">
	                      <div class="col-md-2">
	                        <input type="number" step="0.25" class="form-control ingredient-quantity" name="ingredient_quantity" placeholder="Enter Quantity" required value="#getMealCard.quantity#" />
	                      </div>
	                      <div class="col-md-3">
	                        <select class="form-control" required name="uom">
	                          <option value="0">Select Unit (e.g., Cup, tsp)</option>
	                          <cfloop query="UoM">
	                          	<option value="#UoM.unitID#" <cfif uom.unitID eq getMealCard.unit>selected</cfif> >#UoM.unitName# (#UoM.baseUnit#/#UoM.unitType#)</option>
	                          </cfloop>
	                        </select>
	                      </div>
	                      <div class="col-md-5">                        
	                        <select class="form-control" placeholder="Ingredient Name" required name="ingredientID">
	                          <option value="0">Select Ingredient Name</option> <!-- Empty option for placeholder -->
	                          <cfloop query="ingredients">
	                          	<option value="#ingredients.ingredientID#" <cfif ingredients.ingredientID eq getMealCard.ingredientID>selected</cfif>>#ingredients.ingredient_name#</option>
	                          </cfloop>                           
	                        </select>
	                      </div>
	                      <div class="col-md-2">
	                        <a href="meal_crud_process.cfm?id=#url.id#&action=removeIngredient&miID=#getMealCard.miID#" class="btn btn-danger">Remove</a>
	                      </div>
	                    </div>
	                </cfoutput>

	                <!--- <cfif structKeyExists(url, 'action')> --->
	                	<div class="ingredient-row row mb-2">
	                      <!--- quantity --->
	                      <div class="col-md-2">
	                        <cfoutput><input type="number" step="0.25" class="form-control" name="ingredient_quantity" placeholder="Enter Quantity"  value="" /></cfoutput>
	                      </div>

	                      <!--- unit of measurement --->
	                      <div class="col-md-3">
	                        <select class="form-control"  name="uom">
	                          <option value="0">Select Unit (e.g., Cup, tsp)</option>
	                          <cfoutput query="UoM">
	                          	<option value="#UoM.unitID#">#UoM.unitName# (#UoM.baseUnit#/#UoM.unitType#)</option>
	                          </cfoutput>
	                        </select>
	                      </div>
	                      
	                      <!--- Ingredient Name --->
	                      <div class="col-md-5">                        
	                        <select class="form-control" placeholder="Ingredient Name"  name="ingredientID">
	                          <option value="0">Select Ingredient Name</option> <!-- Empty option for placeholder -->
	                          <cfoutput query="ingredients">
	                          	<option value="#ingredients.ingredientID#">#ingredients.ingredient_name#</option>
	                          </cfoutput>                           
	                        </select>
	                      </div>
	                      <div class="col-md-2">
	                        <button type="submit" name="action" value="addIngredient" class="btn btn-secondary btn-add-ingredient">Add</button>
	                      </div>
	                    </div>
	                <!--- </cfif> --->

                  </div>
                  
                  <!--- <div>
                    <div style="float: left;">
                      <button type="submit" id="addIngredientBtn" class="btn btn-rounded btn-secondary" name="action" value="addingredient"><span class="btn-icon-left text-secondary"><i class="fa fa-plus color-secondary"></i>
                                      </span>Add Ingredient</button>                    
                    </div>
                  </div> --->
              </div>
              <div class="card-footer">
                <!-- <a href="javascript:void(0);" class="card-link d-inline btn btn-primary">Save</a> -->
                <div class="toolbar toolbar-bottom" role="toolbar" style="text-align: right;">
                  <button id="cancelMeal" class="btn btn-light" type="button">Cancel</button>
                  <button type="submit" class="btn btn-primary" name="action" value="savemeal">Save Meal</button>
                </div>
              </div>
            </div>
          </div>
		  <cfoutput>
      	  	<input type="hidden" name="mealID" value="#url.id#">
      	  </cfoutput>
        </form>

      </div>    
    </div>
  </div>

  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <!-- Bootstrap Bundle JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <!-- SweetAlert2 -->
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <!--- select2 --->
  <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
  <!-- show more -->
  <script src="js/jquery.expander.js"></script>

  <!-- include summernote css/js -->
  <!-- <link href="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote.min.js"></script> -->

  
  <script src="js/meal-add-edit.js">
    
  </script>
</body>
</html>
