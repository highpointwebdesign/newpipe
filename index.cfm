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
                  <li><a class="nav-link" href="calendar.htm" id="menu-calendar">MEAL PLANNER</a></li>
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
        <div class="position-sticky" style="top: 2rem;">
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
        </div>
      </div>
      <div class="col-sm-10">
        <h3 class="mb-4 border-bottom" style="padding-top: 20px;">
          Meal Cards
        </h3>            
        <!-- main content here -->

        <!-- Collapsible Add Meal Section -->
        <form id="addMealForm">
          <div id="addMealSection" class="collapse mb-3">
            <div class="card">
              <div class="card-header">
                <h5 class="card-title">Meal Details</h5>
              </div>
              <div class="card-body">
                  <input type="hidden" id="mealId" value="">
                  <div class="mb-3">
                    <label for="mealTitle" class="form-label">Meal Title</label>
                    <input type="text" class="form-control" id="mealTitle" required />
                  </div>
                  <!-- New row for Servings and Meal Type -->
                  <div class="mb-3">
                    <div class="row">
                      <div class="col-md-6">
                        <label for="servings" class="form-label">Servings</label>
                        <input type="number" class="form-control" id="servings" value="4" step="2" required/>
                      </div>
                      <div class="col-md-6">
                        <label for="mealType" class="form-label">Meal Type</label>
                        <select id="mealType" class="form-select" required>
                          <option></option> <!-- Empty option for placeholder -->
                        </select>
                      </div>
                    </div>
                    <div class="row">
                      <div class="col-md-12">
                          <label for="details" class="form-label">Directions</label>
                          <!-- https://rohanyeole.com/ray-editor/ for future WYSIWYG -->
                          <textarea class="form-control" rows="9" id="details" spellcheck="false"></textarea>
                      </div>
                    </div>
                  </div>
                  <div id="ingredientsContainer">
                    <!-- <label class="form-label">Ingredients</label> -->
                    <label class="form-label">Ingredients</label>
                    <div class="ingredient-row row mb-2">
                      <div class="col-md-4">
                        <!--- <input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required /> --->
                        <select class="form-control ingredient-name" placeholder="Ingredient Name" required>
                          <option></option>
                        </select>
                      </div>
                      <div class="col-md-3">
                        <input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />
                      </div>
                      <div class="col-md-3">
                        <!--- <input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" required  /> --->
                        <select class="form-select ingredient-unit" required>
                          <option></option> 
                        </select>
                      </div>
                      <div class="col-md-2">
                        <button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>
                      </div>
                    </div>
                  </div>
                  
                  <div>
                    <div style="float: left;">
                      <button type="button" id="addIngredientBtn" class="btn btn-rounded btn-secondary"><span class="btn-icon-left text-secondary"><i class="fa fa-plus color-secondary"></i>
                                      </span>Add Ingredient</button>                    
                    </div>
                  </div>
              </div>
              <div class="card-footer">
                <!-- <a href="javascript:void(0);" class="card-link d-inline btn btn-primary">Save</a> -->
                <div class="toolbar toolbar-bottom" role="toolbar" style="text-align: right;">
                  <button id="cancelMeal" class="btn btn-light" type="button">Cancel</button>
                  <button type="submit" class="btn btn-primary">Save Meal</button>
                </div>
              </div>
            </div>
          </div>
        </form>

        <!-- Dashboard: Meal Cards -->

        <div class="mb-3">
          <div class="input-group">
            <span class="input-group-text"><i class="fa fa-search"></i></span>
            <input type="text" class="form-control" id="cardSearchInput" placeholder="Search meals or ingredients...">
            <button class="btn btn-outline-secondary" type="button" id="clearSearchBtn">Clear</button>
          </div>
        </div>
        <div id="dashboard">
          <div class="
            row
            row-cols-1            
            row-cols-sm-2         
            row-cols-md-3         
            row-cols-lg-4         
            row-cols-xl-5
            align-items-start         
            g-3" id="mealCards"><!-- Meal cards will be injected here via AJAX -->
            <div class="col">            
              <div class="card">
                <div class="card-header">
                  <div class="skeleton title"></div>
                </div>
                <div class="card-body">
                  <div id="skeleton_1" class="accordion accordion-no-gutter">
                    <div class="accordion__item">
                      <div class="accordion__header collapsed"
                           data-bs-toggle="collapse"
                           data-bs-target="#ingredientList_1"
                           aria-expanded="false">
                        <span class="accordion__header--text"><div class="skeleton text-line short"></div></span>
                        <span class="accordion__header--indicator style_two"></span>
                      </div>
                      <div id="ingredientList_1"
                           class="accordion__body collapse"
                           data-bs-parent="#skeleton_1">
                        <div class="accordion__body--text">
                            <div class="skeleton title"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card-footer">
                  <p class="card-text d-inline"><div class="skeleton text-line short"></div></p>
                </div>
              </div>
            </div>

            <div class="col">            
              <div class="card">
                <div class="card-header">
                  <div class="skeleton title"></div>
                </div>
                <div class="card-body">
                  <div id="skeleton_1" class="accordion accordion-no-gutter">
                    <div class="accordion__item">
                      <div class="accordion__header collapsed"
                           data-bs-toggle="collapse"
                           data-bs-target="#ingredientList_1"
                           aria-expanded="false">
                        <span class="accordion__header--text"><div class="skeleton text-line short"></div></span>
                        <span class="accordion__header--indicator style_two"></span>
                      </div>
                      <div id="ingredientList_1"
                           class="accordion__body collapse"
                           data-bs-parent="#skeleton_1">
                        <div class="accordion__body--text">
                            <div class="skeleton title"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card-footer">
                  <p class="card-text d-inline"><div class="skeleton text-line short"></div></p>
                </div>
              </div>
            </div>

            <div class="col">            
              <div class="card">
                <div class="card-header">
                  <div class="skeleton title"></div>
                </div>
                <div class="card-body">
                  <div id="skeleton_1" class="accordion accordion-no-gutter">
                    <div class="accordion__item">
                      <div class="accordion__header collapsed"
                           data-bs-toggle="collapse"
                           data-bs-target="#ingredientList_1"
                           aria-expanded="false">
                        <span class="accordion__header--text"><div class="skeleton text-line short"></div></span>
                        <span class="accordion__header--indicator style_two"></span>
                      </div>
                      <div id="ingredientList_1"
                           class="accordion__body collapse"
                           data-bs-parent="#skeleton_1">
                        <div class="accordion__body--text">
                            <div class="skeleton title"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card-footer">
                  <p class="card-text d-inline"><div class="skeleton text-line short"></div></p>
                </div>
              </div>
            </div>

            <div class="col">            
              <div class="card">
                <div class="card-header">
                  <div class="skeleton title"></div>
                </div>
                <div class="card-body">
                  <div id="skeleton_1" class="accordion accordion-no-gutter">
                    <div class="accordion__item">
                      <div class="accordion__header collapsed"
                           data-bs-toggle="collapse"
                           data-bs-target="#ingredientList_1"
                           aria-expanded="false">
                        <span class="accordion__header--text"><div class="skeleton text-line short"></div></span>
                        <span class="accordion__header--indicator style_two"></span>
                      </div>
                      <div id="ingredientList_1"
                           class="accordion__body collapse"
                           data-bs-parent="#skeleton_1">
                        <div class="accordion__body--text">
                            <div class="skeleton title"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card-footer">
                  <p class="card-text d-inline"><div class="skeleton text-line short"></div></p>
                </div>
              </div>
            </div>

            <div class="col">            
              <div class="card">
                <div class="card-header">
                  <div class="skeleton title"></div>
                </div>
                <div class="card-body">
                  <div id="skeleton_1" class="accordion accordion-no-gutter">
                    <div class="accordion__item">
                      <div class="accordion__header collapsed"
                           data-bs-toggle="collapse"
                           data-bs-target="#ingredientList_1"
                           aria-expanded="false">
                        <span class="accordion__header--text"><div class="skeleton text-line short"></div></span>
                        <span class="accordion__header--indicator style_two"></span>
                      </div>
                      <div id="ingredientList_1"
                           class="accordion__body collapse"
                           data-bs-parent="#skeleton_1">
                        <div class="accordion__body--text">
                            <div class="skeleton title"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card-footer">
                  <p class="card-text d-inline"><div class="skeleton text-line short"></div></p>
                </div>
              </div>
            </div>

            
          </div>
        </div>
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

  
  <script src="js/index.js">
    
  </script>
</body>
</html>
