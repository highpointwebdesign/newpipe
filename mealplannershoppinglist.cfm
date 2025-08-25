<cfparam name="local.isFormSubmit" default="0">

<cfif (structKeyExists(form, "generateShoppingList") && structKeyExists(form, "datefilter"))>
  
  <cfset local.formDataStruct = {}>
  <cfloop list="#form.fieldNames#" index="fieldNames">
      <cfset local.formDataStruct[fieldNames] = form[fieldNames]>
  </cfloop>

  <cfdump var="#local.formDataStruct#">

  <cfif len(local.formDataStruct.startDate)>

    <cfquery name="mealsQry" datasource="sg">
      Select
          c.mealID,
          c.startDate,
          m.title,
          m.servings,
          r.ingredient_name,
          r.ingredientID,
          q.optionValue,
          q.textValue,
          u.unitName,
          u.baseUnit,
          u.unitType,
          u.isIndivisible
      From
          meal_calendar_events c Left Join
          meals m On c.mealID = m.mealID Left Join
          meal_ingredients i On i.mealID = m.mealID Left Join
          raw_ingredients r On i.ingredientID = r.ingredientID Left Join
          quantity_options q On i.quantityID = q.quantityID Left Join
          measurementunits u On u.unitID = i.unitID
      Where
          c.startDate 
            Between <cfqueryparam value="#local.formDataStruct.startDate#" cfsqltype="cf_sql_date"> And <cfqueryparam value="#local.formDataStruct.endDate#" cfsqltype="cf_sql_date">
      Order By
          m.title,
          r.ingredient_name
    </cfquery>

    <cfquery name="ingredientQry" datasource="sg">
      Select
        r.ingredient_name,
        Sum(q.optionValue) As totalQuantity,
        u.unitName,
        i.ingredientID,
        u.baseUnit,
        u.unitType,
        u.isIndivisible,
        q.textValue
    From
        meal_calendar_events c Left Join
        meals m On c.mealID = m.mealID Left Join
        meal_ingredients i On i.mealID = m.mealID Left Join
        raw_ingredients r On i.ingredientID = r.ingredientID Left Join
        quantity_options q On i.quantityID = q.quantityID Left Join
        measurementunits u On u.unitID = i.unitID
    Where
       c.startDate 
            Between <cfqueryparam value="#local.formDataStruct.startDate#" cfsqltype="cf_sql_date"> And <cfqueryparam value="#local.formDataStruct.endDate#" cfsqltype="cf_sql_date">
    Group By
        r.ingredient_name,
        u.unitName,
        i.ingredientID,
        u.baseUnit,
        u.unitType,
        u.isIndivisible,
        q.textValue
    Order By
        i.ingredientID,
        u.unitName,
        totalQuantity
    </cfquery>  

    <cfquery name="distinctMeals" dbtype="query">
      Select 
        distinct title
        From
          mealsQry
        Order By
            title
    </cfquery>
    <cfdump var="#mealsQry#">
    <cfdump var="#ingredientQry#">
    <cfdump var="#distinctMeals#">

    <cfset local.msg = ''>
    <cfset local.isFormSubmit = 1>

  <cfelse>
    <!--- issue with date so pretend form was not submitted --->
    <cfset local.isFormSubmit = 0>
    <cfset local.msg = 'There are no meals in the selected date range.'>
    <cfset local.alert = 'warning'>
  </cfif>


</cfif>

<!--- <cfscript>
  if (structKeyExists(form, "generateShoppingList") && structKeyExists(form, "datefilter")) {
    local.formDataStruct = {};
    for( fieldNames in form.fieldNames ){
        local.formDataStruct[fieldNames] = form[fieldNames];
    }
    dump(local.formDataStruct);

    local.result = {};
    
    local.mealsQry = queryExecute(
        "Select
            c.mealID,
            c.startDate,
            m.title,
            m.servings,
            r.ingredient_name,
            q.optionValue,
            q.textValue,
            u.unitName,
            u.baseUnit,
            u.unitType,
            u.isIndivisible
        From
            meal_calendar_events c Left Join
            meals m On c.mealID = m.mealID Left Join
            meal_ingredients i On i.mealID = m.mealID Left Join
            raw_ingredients r On i.ingredientID = r.ingredientID Left Join
            quantity_options q On i.quantityID = q.quantityID Left Join
            measurementunits u On u.unitID = i.unitID
        Where
            c.startDate Between :startDate And :endDate
        Order By
            m.title,
            r.ingredient_name",
        { 
            startDate: { value: local.formDataStruct.startDate, cfsqltype: "CF_SQL_VARCHAR", list:"false" },
            endDate: { value: local.formDataStruct.endDate, cfsqltype: "CF_SQL_VARCHAR", list:"false" }
        },
        { datasource = 'sg' }
        );

      local.ingredientsQry = queryExecute(
        "Select
            r.ingredient_name,
            Sum(q.optionValue) As totalQuantity,
            u.unitName,
            i.ingredientID,
            u.baseUnit,
            u.unitType,
            u.isIndivisible
        From
            meal_calendar_events c Left Join
            meals m On c.mealID = m.mealID Left Join
            meal_ingredients i On i.mealID = m.mealID Left Join
            raw_ingredients r On i.ingredientID = r.ingredientID Left Join
            quantity_options q On i.quantityID = q.quantityID Left Join
            measurementunits u On u.unitID = i.unitID
        Where
            c.startDate Between :startDate And :endDate
        Group By
            r.ingredient_name,
            u.unitName,
            i.ingredientID,
            u.baseUnit,
            u.unitType,
            u.isIndivisible
        Order By
            i.ingredientID,
            u.unitName,
            totalQuantity",
        { 
            startDate: { value: local.formDataStruct.startDate, cfsqltype: "CF_SQL_VARCHAR", list:"false" },
            endDate: { value: local.formDataStruct.endDate, cfsqltype: "CF_SQL_VARCHAR", list:"false" }
        },
        { datasource = 'sg' }
        );

        dump(local.ingredientsQry);
  }
</cfscript> --->

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Meal Planner</title>
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <!-- Bootstrap Icons (for trash can icon) -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" />
  <!-- Date Range Picker CSS -->
  <link
    rel="stylesheet"
    type="text/css"
    href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css"
  />  
  <!-- <link href="css/main.css?verion=1" rel="stylesheet"> -->
  <link href="css/styles.css?verion=1" rel="stylesheet">
  <link href="css/index.css?verion=1" rel="stylesheet">
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
                  <li><a class="nav-link" href="calendar.htm" id="menu-calendar">MEAL PLANNER</a></li>
                  <li><a class="nav-link" href="mealplannershoppinglist.cfm" id="menu-shopping_list">SHOPPING LIST</a></li>
                  <li><a class="nav-link" href="inventoryMgmt.htm" id="menu-shopping_list">INVENTORY MGMT (Beta)</a></li>
                </ul>
            </div>
          </div>
    <!--**********************************
            Sidebar end
        ***********************************-->
  <div class="content-body">
     <div class="container-fluid">

          <div class="card">
              <div class="card-body">
                  <div class="row">
                      <div class="col-sm-12">
                          <form action="mealplannershoppinglist.cfm" name="mealplanner_form" method="post">
                            <h3 class="mb-4 border-bottom" style="padding-top: 20px;">
                                Meal Cards
                            </h3>            
                            <!-- main content here start -->
                            <p>
                                Select the start and end dates of your RV trip below and then click the
                                <strong>Generate Shopping List</strong> button to view the ingredients
                                you'll need.
                            </p>
                            
                            <div class="row">
                                <div class="col-md-2 col-sm-6">
                                    <!-- Date range input with smaller width -->
                                    <input type="text" id="datefilter" name="datefilter" value="" class="form-control mb-2" />
                                      <input type="hidden" id="startDate" name="startDate">
                                      <input type="hidden" id="endDate" name="endDate">
                                </div>
                            </div>
                            
                            <!-- Button to trigger shopping list generation -->
                            <button id="generateListBtn" type="submit" name="generateShoppingList" value="generateShoppingList" class="btn btn-primary mb-3">
                                Generate Shopping List
                            </button>

                            
                            <div id="alertContainer">
                              <cfif len(local.msg)><cfoutput>
                                <div class="alert alert-#local.alert# solid alert-dismissible fade show">
                                  <svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="me-2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                  <strong>Warning!</strong> #local.msg#
                                  <button type="button" class="close h-100" data-bs-dismiss="alert" aria-label="Close"><span><i class="mdi mdi-close"></i></span>
                                                    </button>
                                </div>        
                              </cfoutput></cfif>                      

                            </div>                            

                          </form>
                      </div>    
                  </div>
              </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div id="accordion-ShoppingList" class="accordion accordion-no-gutter">
                <div class="accordion__item">
                  <div class="accordion__header <cfif local.isFormSubmit eq 1> <cfelse>collapsed></cfif>" data-bs-toggle="collapse" data-bs-target="#bordered_no-gutter_collapseShoppingList" style="background-color: #1ab5ac; color: #ffffff">
                    <span class="accordion__header--text">SHOPPING LIST</span>
                    <span class="accordion__header--indicator style_two"></span>
                  </div>
                  <div id="bordered_no-gutter_collapseShoppingList" class="collapse accordion__body <cfif local.isFormSubmit eq 1>collapse show</cfif>" data-bs-parent="#accordion-ShoppingList" style="background-color: #ffffff;">
                    <div class="accordion__body--text">
                      <div id="shoppingList">
                        <cfif local.isFormSubmit eq 1>
                          <ul>
                          <cfoutput query="ingredientQry">
                            <li>#ingredientQry.textValue# #ingredientQry.baseUnit# of #ingredientQry.ingredient_name#</li>
                          </cfoutput>
                          </ul>
                        </cfif>
                      </div>
                      <div id="eachNoteContainer" class="">
                        <div class="alert alert-outline-info alert-dismissible fade show">
                            <strong>NOTE:</strong> Ingredients sold in indivisible units (e.g. each, piece) are rounded up to the next whole number.  
                        </div>                            
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div id="accordion-MealList" class="accordion accordion-no-gutter">
                <div class="accordion__item">
                  <div class="accordion__header <cfif local.isFormSubmit eq 1> <cfelse>collapsed></cfif>" data-bs-toggle="collapse" data-bs-target="#bordered_no-gutter_collapseMealList" style="background-color: #5C3799; color: #ffffff;">
                    <span class="accordion__header--text">MEALS</span>
                    <span class="accordion__header--indicator style_two"></span>
                        
                  </div>
                  <div id="bordered_no-gutter_collapseMealList" class="collapse accordion__body <cfif local.isFormSubmit eq 1>collapse show</cfif>"  data-bs-parent="#accordion-MealList" style="background-color: #ffffff;">  
                    <div class="accordion__body--text">
                      <div id="mealListContainer">
                        <cfif local.isFormSubmit eq 1>
                          <ul>
                          <cfoutput query="distinctMeals">
                            <li>#distinctMeals.title#</li>
                          </cfoutput>
                          </ul>
                        </cfif>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>


          
          </div>

    </div>
  </div>
                    <!-- Container where the shopping list (or a message) will be rendered -->
                    
                    

  <!-- jQuery, Bootstrap, SweetAlert, Moment, DateRangePicker -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"
  ></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script type="text/javascript" src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
  <script
    type="text/javascript"
    src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"
  ></script>
  <script src="js/mealplannershoppingList.js"></script>

</body>
</html>
