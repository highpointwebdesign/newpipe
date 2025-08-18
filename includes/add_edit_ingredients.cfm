<h4>Create Meal</h4>
        <form id="addMealForm">
          <div id="addMealSection" class="mb-3">
            <div class="card">
              <div class="card-header">
                <h5 class="card-title text-white">Add Meal Card</h5>
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
                          <option value="">Select Meal Type</option>
                          <option value="breakfast" class="primary">Breakfast</option>
                          <option value="lunch" class="secondary">Lunch</option>
                          <option value="dinner" selected class="success">Dinner</option>
                          <option value="dessert" class="danger">Dessert</option>
                          <option value="sss" class="warning">Sides, Sauces, and Spices</option>
                          <option value="snack" class="warning">Snack</option>
                        </select>
                      </div>
                    </div>
                  </div>
                  <div class="mb-3">
                    <div class="row">
                      <div class="col-md-12">
                        <label for="details" class="form-label">Directions</label>
                        <!--- <div class="card-body custom-ekeditor">
                          <div id="ckeditor"></div>
                        </div>    --->                     
                        <textarea class="form-control summernote" id="details"></textarea>
                      </div>
                      
                    </div>
                  </div>
                  <div id="ingredientsContainer">
                    <!-- <label class="form-label">Ingredients</label> -->
                    <label class="form-label">Ingredients</label>
                    <div class="ingredient-row row mb-2">
                      <div class="col-md-4">
                        <input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />
                      </div>
                      <div class="col-md-3">
                        <input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />
                      </div>
                      <div class="col-md-3">
                        <input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" required  />
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