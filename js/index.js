$(document).ready(function () {
      // Load meals when the page loads.
      loadMeals();
      // $('#details').summernote();



    function filterCards() {
      const searchInput = $('#cardSearchInput').val().toLowerCase().trim();
      
      // If search is empty, show all cards
      if (searchInput === '') {
        $('#mealCards .col').show();
        return;
      }
      
      // Split search input into individual terms
      const searchTerms = searchInput.split(/\s+/).filter(term => term.length > 0);
      
      $('#mealCards .col').each(function() {
        const $card = $(this).find('.card');
        const cardTitle = $card.find('.card-title').text().toLowerCase();
        
        // Get all ingredients text
        const ingredients = $card.find('.list-group-item').map(function() {
          return $(this).text().toLowerCase();
        }).get();
        
        // Combine title and ingredients into one searchable text
        const cardContent = [cardTitle, ...ingredients].join(' ');
        
        // Check if ANY of the search terms match the card content
        const isMatch = searchTerms.some(term => cardContent.includes(term));
        
        // Show or hide based on match
        $(this).toggle(isMatch);
      });
    };

      // Add event listeners
      $('#cardSearchInput').on('input', filterCards);
      
      // Clear search function
      $('#clearSearchBtn').on('click', function() {
        $('#cardSearchInput').val('').focus();
        filterCards();
      });

       function initializeSearch() {
          // This can be called after your AJAX content is loaded
          filterCards();
        }


      
        $("#menu-add").click(function (e) {
          e.preventDefault();

          // If visible and we're clicking the add button, reset the form first
          if ($("#addMealSection").is(":visible")) {
            resetAddMealForm(); // Switch from editing mode to add mode
          }

          // Use toggle instead of show
          $("#addMealSection").collapse("toggle");
        });

        // Function to fully reset the meal form
        function resetAddMealForm() {
          $("#addMealForm")[0].reset();

          // Clear stored meal ID and reset button labels
          $("#mealId").val("");
          $("#addMealForm button[type='submit']").text("Save Meal");

          // Reset ingredients container with one blank row
          $("#ingredientsContainer").empty().append(
            '<label class="form-label">Ingredients</label>' +
            '<div class="ingredient-row row mb-2">' +
              '<div class="col-md-4">' +
                 '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />' +
              '</div>' +
              '<div class="col-md-3">' +
                 '<input type="number" step="0.01" class="form-control ingredient-quantity" placeholder="Quantity" required />' +
              '</div>' +
              '<div class="col-md-3">' +
                 '<input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" required />' +
              '</div>' +
              '<div class="col-md-2">' +
                 '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
              '</div>' +
            '</div>'
          );

          // Keep the section open, but ensure it's displaying the blank add form
        }

      
      // Show Dashboard (and hide shopping list).
      $("#menu-home").click(function (e) {
        e.preventDefault();
        $("#shoppingListSection").collapse("hide");
        $("#dashboard").show();
        $("#addMealSection").collapse("hide");
      });
      
      // Load the Shopping List.
      // $("#menu-shopping").click(function (e) {
      //     e.preventDefault();

      //     // Gather meal IDs from checked checkboxes.
      //     var selectedMealIds = [];
      //     $(".meal-checkbox:checked").each(function () {
      //       selectedMealIds.push($(this).data("meal-id"));
      //     });

      //     if (selectedMealIds.length === 0) {
      //       Swal.fire("No meals selected", "Please select one or more meals using the checkboxes on the meal cards.", "info");
      //       return;
      //     }

      //     // AJAX call to get the aggregated shopping list and servings summary.
      //     $.ajax({
      //       url: "api/mealplanner.cfc?method=getShoppingList",
      //       method: "POST",
      //       data: { mealIds: JSON.stringify(selectedMealIds) },
      //       dataType: "json",
      //       success: function (res) {
      //         // Display the summary above the ingredients list.
      //         $("#shoppingSummary").html(
      //           "<strong>Total Servings:</strong> " + res.summary.totalServings +
      //           " | <strong>Meals:</strong> " + res.summary.meals
      //         );
              
      //         // Populate the shopping list.
      //         $("#shoppingList").empty();
      //         $.each(res.ingredients, function (i, item) {
      //           $("#shoppingList").append(
      //             '<li class="list-group-item">' +
      //               item.ingredient + "  " + item.quantity + " " + item.unit +
      //             "</li>"
      //           );
      //         });
      //         $("#dashboard").hide();
      //         $("#addMealSection").collapse("hide");
      //         $("#shoppingListSection").collapse("show");
      //       },
      //       error: function () {
      //         Swal.fire("Error", "Could not fetch shopping list.", "error");
      //       }
      //     });
      // });

      // Global variable to cache units of measurement
      let unitsOfMeasurement = [];

      // 1. Load units of measurement when page loads
        // Ajax call to load units of measurement
        $.ajax({
          url: '/api/mealplanner.cfc?method=measurementunits',
          dataType: 'json',
          success: function(data) {
            // Cache the data
            unitsOfMeasurement = data;
            console.log('Units of measurement loaded:', unitsOfMeasurement);
            populateUoMDropdown()
          },
          error: function(xhr, status, error) {
            console.error('Error loading units of measurement:', error);
          }
        });

      let ingredientsList = [];
         $.ajax({
          url: '/api/mealplanner.cfc?method=ingredients',
          dataType: 'json',
          success: function(data) {
            // Cache the data
            ingredientsList = data;
            console.log('ingredientsList loaded:', ingredientsList);
            populateIngredientsDropdown();
          },
          error: function(xhr, status, error) {
            console.error('Error retrieving ingredientsList:', error);
          }
        });
console.log('ingredientsList');
console.log(ingredientsList);


      // // Add a new ingredient input row.
      // $("#addIngredientBtn").click(function () {
      //   var ingredientRow =
      //     '<div class="ingredient-row row mb-2">' +
      //       '<div class="col-md-4">' +
      //         '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />' +
      //       "</div>" +
      //       '<div class="col-md-3">' +
      //         '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />' +
      //       "</div>" +
      //       '<div class="col-md-3">' +
      //         '<input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" required />' +
      //       "</div>" +
      //       '<div class="col-md-2">' +
      //         '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
      //       "</div>" +
      //     "</div>";
      //   $("#ingredientsContainer").append(ingredientRow);
      // });

      $("#addIngredientBtn").click(function() {
        var ingredientRow =
          '<div class="ingredient-row row mb-2">' +
            '<div class="col-md-4">' +
              '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />' +
            "</div>" +
            '<div class="col-md-3">' +
              '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />' +
            "</div>" +
            '<div class="col-md-3">' +
              '<select class="form-control ingredient-unit" required></select>' +
            "</div>" +
            '<div class="col-md-2">' +
              '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
            "</div>" +
          "</div>";
        
        // Append the row
        $("#ingredientsContainer").append(ingredientRow);
        
       
        // // Initialize Select2
        // $newUnitSelect.select2({
        //   placeholder: 'Select Unit',
        //   dropdownParent: $newUnitSelect.parent(),
        //   allowClear: false,
        //   data: unitsOfMeasurement.map(unit => ({
        //     id: unit.id || unit.value,
        //     text: unit.name || unit.text
        //   }))
        // });

        // $newNameSelect.select2({
        //   placeholder: 'Select Unit',
        //   dropdownParent: $newNameSelect.parent(),
        //   allowClear: false,
        //   data: ingredientsList.map(unit => ({
        //     id: unit.id || unit.value,
        //     text: unit.name || unit.text
        //   }))
        // });
      });
   // Initialize Select2 on the newly added unit dropdown
        const $newUnitSelect = $("#ingredientsContainer .ingredient-unit").last();
        const $newNameSelect = $("#ingredientsContainer .ingredient-name").last();
        
      function populateUoMDropdown() {    
          $(".ingredient-unit").select2({
            placeholder: 'Select Unit',
            allowClear: false,
            tags: true,
            data: unitsOfMeasurement.map(unit => ({
              id: unit.id || unit.value,
              text: unit.name || unit.text
            }))
          });
      }
  
      function populateIngredientsDropdown() {
          $(".ingredient-name").select2({
            placeholder: 'Enter Ingredient',
            allowClear: false,
            tags: true,
            data: ingredientsList.map(name => ({
              id: name.id || name.value,
              text: name.name || name.text
            }))
          });
      }      



      // Remove an ingredient row.
      $(document).on("click", ".btn-remove-ingredient", function () {
        $(this).closest(".ingredient-row").remove();
      });
      
      // Handle form submission to save a meal.
      $("#addMealForm").submit(function (e) {
          e.preventDefault();
          
          var mealId = $("#mealId").val();
          var title = $("#mealTitle").val();
          var servings = $("#servings").val();
          var mealType = $("#mealType").val();
          var details = $("#details").val();
          var ingredients = [];
        
          $("#ingredientsContainer .ingredient-row").each(function () {
            var name = $(this).find(".ingredient-name").val();
            var quantity = $(this).find(".ingredient-quantity").val();
            var unit = $(this).find(".ingredient-unit").val();
            if (name && quantity && unit) {
              ingredients.push({
                ingredientName: name,
                quantity: parseFloat(quantity),
                unit: unit
              });
            }
          });
          
          // Determine which method to call based on the existence of a mealId.
          var methodURL = mealId && mealId.trim() !== ""
            ? "api/mealplanner.cfc?method=updateMeal"
            : "api/mealplanner.cfc?method=addMeal";
            
          // Build the data payload.
          var payload = {
            details: details,
            title: title,
            servings: servings,
            mealType: mealType,
            ingredients: JSON.stringify(ingredients)
          };
          
          if (mealId && mealId.trim() !== "") {
            payload.mealId = mealId;
          }
          
          $.ajax({
            url: methodURL,
            method: "POST",
            data: payload,
            dataType: "json",
            success: function (res) {
              if (res.success) {
                var msg = mealId && mealId.trim() !== "" ? "Meal Updated" : "Meal Added";
                Swal.fire(msg, "Your meal has been saved.", "success");
                
                // Reset the form.
                $("#addMealForm")[0].reset();
                // Recreate one blank ingredient row.
                $("#ingredientsContainer").empty().append('<label class="form-label">Ingredients</label>' +
                  '<div class="ingredient-row row mb-2">' +
                    '<div class="col-md-4">' +
                      '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />' +
                    '</div>' +
                    '<div class="col-md-3">' +
                      '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />' +
                    '</div>' +
                    '<div class="col-md-3">' +
                      '<input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" required />' +
                    '</div>' +
                    '<div class="col-md-2">' +
                      '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
                    '</div>' +
                  '</div>');
                  
                // Clear the hidden mealId field and reset the button label.
                $("#mealId").val("");
                $("#addMealForm button[type='submit']").text("Save Meal");
                $("#addMealSection").collapse("hide");
                loadMeals();
              } else {
                Swal.fire("Error", "Could not save meal.", "error");
              }
            },
            error: function () {
              Swal.fire("Error", "Could not save meal.", "error");
            }
          });
        });

          var colorMapping = {
            "1": "#5C3799",
            "2": "#7ae7bf",
            "3": "#fdadad",
            "4": "#ff887c",
            "5": "#fbd75b",
            "6": "#ffb878",
            "7": "#46d6db",
            "8": "#e1e1e1",
            "9": "#2953E8",
            "10":"#1ab5ac",
            "11":"#dc2127"
          };
      // Load meals from the server and update the dashboard.
      function loadMeals() {
        let attempts = 0; // track the number of attempts

        function makeAjaxRequest(){
          $.ajax({
            url: "api/mealplanner.cfc?method=getMeals",
            method: "GET",
            cache: false,
            dataType: "json",
            success: function (data) {


              $("#mealCards").empty();
              $.each(data, function (index, meal) {
             
              var customColor = "#dc2127"; // Example custom color
              var calendarColorId = colorMapping[customColor] || "1"

              // build the ingredients list first
              var listGroup = '<div class="list-group">';
              $.each(meal.ingredients, function(i, ing) {
                listGroup +=
                  '<a href="javascript:void(0);" ' +
                    'class="list-group-item list-group-item-action">' +
                    ing.quantity + ' ' +
                    ing.unit + ' ' +
                    ing.ingredient_name + 
                  '</a>';
              });
              listGroup += '</div>';

              // now build the card in one go
              var card =
                '<div class="col">' +
                  '<div class="card">' +
                    '<div class="card-header">' +
                      '<h5 class="card-title"><i class="fa-regular" style="border-radius: 50%;background-color:#ff887c;display: inline-block;width: 10px;height: 10px;margin-right: 5px;position: relative;top:-1px;background-color:' + meal.typeColor + '"></i>' + meal.title + '</h5>' +
                    '</div>' +
                    '<div class="card-body">' +
                      '<div id="mealCard_' + meal.mealID + '" class="accordion accordion-no-gutter">' +
                        '<div class="accordion__item">' +
                          '<div class="accordion__header collapsed" ' +
                               'data-bs-toggle="collapse" ' +
                               'data-bs-target="#ingredientList_' + meal.mealID + '" ' +
                               'aria-expanded="false">' +
                            '<span class="accordion__header--text">Ingredients</span>' +
                            '<span class="accordion__header--indicator style_two"></span>' +
                          '</div>' +
                          '<div id="ingredientList_' + meal.mealID + '" ' +
                               'class="accordion__body collapse" ' +
                               'data-bs-parent="#mealCard_' + meal.mealID + '">' +
                            '<div class="accordion__body--text">' +
                              listGroup +
                            '</div>' +
                          '</div>' +
                        '</div>' +
                      '</div>' +
                      '<div id="mealCard_Desc_' + meal.mealID + '>' + meal.description +                        
                      '</div>' +
                    '</div>' +
                    '<div class="card-footer">' +
                      '<p class="card-text d-inline">Servings: ' + meal.servings + '</p>' +
                      '<div class="float-end">' +
                        // '<a href="javascript:void(0);" class="btn btn-primary btn-sm light btn-card btn-edit" data-meal_id="' + meal.mealID + '">Edit</a> ' +
                        '<a href="meal_crud.cfm?id=' + meal.mealID + '" class="btn btn-primary btn-sm light btn-card">Edit</a> ' +
                        '<a href="javascript:void(0);" class="btn btn-danger btn-sm light btn-card me-1 btn-archive" data-meal-id="' + meal.mealID + '">Archive</a>' +
                      '</div>' +
                    '</div>' +
                  '</div>' +
                '</div>';
             

                $("#mealCards").append(card);


              });
            },
            error: function(xhr, textStatus, errorThrown) {
              if (attempts === 0) {
                attempts++;
                console.warn("Ajax call failed on first attempt, retrying...", errorThrown);
                makeAjaxRequest(); // Retry one additional time
              } else {
                console.error("Ajax call failed after retry:", errorThrown);
                Swal.fire("Error", "Could not load meals.", "error");
              }
            }
          });
        }

        makeAjaxRequest();
        initializeSearch();
      }

      // Initialize Select2 without AJAX (for short list)
      $(document).ready(function() {
        $('#mealType').select2({
          placeholder: 'Select Meal Type',
          dropdownParent:$('#mealType').parent(),
          allowClear: false,
          templateResult: formatMealType
        });
        
        // Load data once and populate Select2
        $.ajax({
          url: '/api/mealplanner.cfc?method=mealtypesForSelectOption',
          dataType: 'json',
          success: function(data) {
            // Clear existing options
            $('#mealType').empty().append('<option></option>');
            
            // Add new options
            $.each(data, function(i, item) {
              $('#mealType').append(new Option(item.text, item.id, false, false));
            });
            
            // Trigger change to refresh Select2
            $('#mealType').trigger('change');
          }
        });
      });

      // Function to format the dropdown items with classes
      function formatMealType(mealType) {
        if (!mealType.id) return mealType.text; // Skip placeholder
        
        // Find the original option data
        var originalOption = $('#mealType option[value="' + mealType.id + '"]');
        var data = $(originalOption).data();
        
        // Create styled option
        var $option = $(
          '<span class="meal-type-option ' + data.class + '">' + 
            mealType.text + 
          '</span>'
        );
        
        return $option;
      }


      $("#menu-importFromTrello").on("click", function() {
        Swal.fire({
          title: 'Confirm Update',
          text: "This will update the database and may take 20-30 seconds to complete. Do you want to proceed?",
          icon: 'warning',
          showCancelButton: true,
          confirmButtonText: 'Yes, update it!',
          cancelButtonText: 'No, cancel'
        }).then((result) => {
          if (result.isConfirmed) {
            // Show a loading alert while the request is processing.
            Swal.fire({
              title: 'Processing...',
              text: 'Please wait while the database is updated.',
              allowOutsideClick: false,
              didOpen: () => {
                Swal.showLoading();
              }
            });

            // AJAX call to the CFC method
            // get meal cards
            $.ajax({
              url: "api/mealplanner.cfc?method=updateMeals",
              method: "POST",
              dataType: "json",
              success: function(response) {
                // Hide the loading alert and show the result.
                // Swal.fire({
                //   position: "center-start",
                //   title: response.status === "success" ? "Success" : "Error",
                //   text: response.msg + " The recipe Meal cards have been refreshed.",
                //   icon: response.status
                // });
                // $.ajax({
                //   url: "api/mealplanner.cfc?method=updateSides",
                //   method: "POST",
                //   dataType: "json",
                //   success: function(response) {
                //     // Hide the loading alert and show the result.
                //     loadMeals();
                //     Swal.fire({
                //       position: "center",
                //       title: response.status === "success" ? "Success" : "Error",
                //       text: response.msg + " The recipe cards have been refreshed.",
                //       icon: response.status
                //     });
                //   },
                //   error: function() {
                //     Swal.fire("Error", "The database update failed!", "error");
                //   }
                // });
              },
              error: function() {
                Swal.fire("Error", "The database update failed!", "error");
              }
            });
            
          }
        });
      });

     function loadMealsFromTrello() {
        $.ajax({
          // url: "data/recipes.json", // Path to your local JSON file
          url: "https://api.trello.com/1/lists/65e35da372dfea5154f193f1/cards?key=ca06daaf6537b74a874e324dcc045ee0&token=ATTAeaf7252662f97d5e4de5e1b7fcb53d1bf31c7789c4c3d0abf5cdf8a30b5f6eb44FEF2E71",
          method: "GET",
          cache: false,
          dataType: "json",
          success: function(data) {
            $("#mealCards").empty();
            $.each(data, function(index, meal) {
              // Construct the card markup using only name and desc
              var card =
                '<div class="col-md-4 mb-3">' +
                  '<div class="card meal-card position-relative" data-meal-id="'+ meal.mealID +'">' +
                    '<div class="card-body">' +
                      '<h5 class="card-title">' + meal.name + '</h5>' +
                      '<p class="card-text">' + meal.desc + '</p>' +
                    '</div>' +
                  '</div>' +
                '</div>';
              $("#mealCards").append(card);

              expander();
            });
          },
          error: function() {
            Swal.fire("Error", "Could not load meals.", "error");
          }
        });
      }


    // $(document).on("click", ".btn-edit", function () {
    //   var mealId = $(this).closest(".meal-card").data("meal-id");
    //   var mealId = $(this).data("meal_id");
      
    //   // Fetch meal details using the new getMealById method.
    //   $.ajax({
    //     url: "api/mealplanner.cfc?method=getMealById",
    //     method: "GET",
    //     data: { mealId: mealId },
    //     dataType: "json",
    //     success: function (data) {
    //       // Populate the form fields.
    //       $("#mealId").val(data.id);
    //       $("#mealTitle").val(data.title);
    //       $("#servings").val(data.servings);
    //       $("#mealType").val(data.mealType).trigger('change');
    //       // $("#mealType").select2('val', data.mealType);

    //       $("#details").val(data.details);
          
    //       // Clear and then populate ingredients.
    //       $("#ingredientsContainer").empty();
    //       $("#ingredientsContainer").append('<label class="form-label">Ingredients</label>');
          
    //       if (data.ingredients.length > 0) {
    //         $.each(data.ingredients, function (i, ingredient) {
    //           var ingredientRow =
    //             '<div class="ingredient-row row mb-2">' +
    //               '<div class="col-md-4">' +
    //                 '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" value="'+ ingredient.ingredientName +'" required />' +
    //               "</div>" +
    //               '<div class="col-md-3">' +
    //                 '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" value="'+ ingredient.quantity +'" required />' +
    //               "</div>" +
    //               '<div class="col-md-3">' +
    //                 '<input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" value="'+ ingredient.unit +'" required />' +
    //               "</div>" +
    //               '<div class="col-md-2">' +
    //                 '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
    //               "</div>" +
    //             "</div>";
    //           $("#ingredientsContainer").append(ingredientRow);
    //         });
    //       } else {
    //         // If no ingredients exist, add one empty row.
    //         var blankRow =
    //             '<div class="ingredient-row row mb-2">' +
    //               '<div class="col-md-4">' +
    //                 '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />' +
    //               "</div>" +
    //               '<div class="col-md-3">' +
    //                 '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />' +
    //               "</div>" +
    //               '<div class="col-md-3">' +
    //                 '<input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" required />' +
    //               "</div>" +
    //               '<div class="col-md-2">' +
    //                 '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
    //               "</div>" +
    //             "</div>";
    //         $("#ingredientsContainer").append(blankRow);
    //       }
          
    //       // Change the submit button text to "Update Meal".
    //       $("#addMealForm button[type='submit']").text("Update Meal");
          
    //       // Show the Add Meal Section.
    //       $("#addMealSection").collapse("show");
    //       // Optionally scroll to the form.
    //       $("html, body").animate({ scrollTop: $("#addMealSection").offset().top }, 600);
    //     },
    //     error: function () {
    //       Swal.fire("Error", "Could not load meal details", "error");
    //     }
    //   });
    // });

      $(document).on("click", ".btn-edit", function () {
  var mealId = $(this).closest(".meal-card").data("meal-id");
  var mealId = $(this).data("meal_id");
  
  // Fetch meal details using the new getMealById method.
  $.ajax({
    url: "api/mealplanner.cfc?method=getMealById",
    method: "GET",
    data: { mealId: mealId },
    dataType: "json",
    success: function (data) {
      // Populate the form fields.
      $("#mealId").val(data.id);
      $("#mealTitle").val(data.title);
      $("#servings").val(data.servings);
      $("#mealType").val(data.mealType).trigger('change');
      $("#details").val(data.details);
      
      // Clear and then populate ingredients.
      $("#ingredientsContainer").empty();
      $("#ingredientsContainer").append('<label class="form-label">Ingredients</label>');
      
      if (data.ingredients.length > 0) {
            $.each(data.ingredients, function (i, ingredient) {
              var ingredientRow =
                '<div class="ingredient-row row mb-2">' +
                  '<div class="col-md-4">' +
                    '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" value="'+ ingredient.ingredientName +'" required />' +
                  "</div>" +
                  '<div class="col-md-3">' +
                    '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" value="'+ ingredient.quantity +'" required />' +
                  "</div>" +
                  '<div class="col-md-3">' +
                    '<select class="form-control ingredient-unit" required></select>' +
                  "</div>" +
                  '<div class="col-md-2">' +
                    '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
                  "</div>" +
                "</div>";
              $("#ingredientsContainer").append(ingredientRow);
              
              // Initialize Select2 on the newly added unit dropdown
              var $unitSelect = $("#ingredientsContainer .ingredient-row").last().find(".ingredient-unit");
              
              $unitSelect.select2({
                placeholder: 'Select Unit',
                dropdownParent: $unitSelect.parent(),
                allowClear: false,
                data: unitsOfMeasurement.map(unit => ({
                  id: unit.id || unit.value,
                  text: unit.name || unit.text
                }))
              });
              
              // Set the selected value
              $unitSelect.val(ingredient.unit).trigger('change');
            });
          } else {
            // If no ingredients exist, add one empty row.
            var blankRow =
                '<div class="ingredient-row row mb-2">' +
                  '<div class="col-md-4">' +
                    '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />' +
                  "</div>" +
                  '<div class="col-md-3">' +
                    '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />' +
                  "</div>" +
                  '<div class="col-md-3">' +
                    '<select class="form-control ingredient-unit" required></select>' +
                  "</div>" +
                  '<div class="col-md-2">' +
                    '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
                  "</div>" +
                "</div>";
            $("#ingredientsContainer").append(blankRow);
            
            // Initialize Select2 on the blank row
            var $unitSelect = $("#ingredientsContainer .ingredient-row").last().find(".ingredient-unit");
            
            $unitSelect.select2({
              placeholder: 'Select Unit',
              dropdownParent: $unitSelect.parent(),
              allowClear: false,
              data: unitsOfMeasurement.map(unit => ({
                id: unit.id || unit.value,
                text: unit.name || unit.text
              }))
            });
          }
          
          // Change the submit button text to "Update Meal".
          $("#addMealForm button[type='submit']").text("Update Meal");
          
          // Show the Add Meal Section.
          $("#addMealSection").collapse("show");
          // Optionally scroll to the form.
          $("html, body").animate({ scrollTop: $("#addMealSection").offset().top }, 600);
        },
        error: function () {
          Swal.fire("Error", "Could not load meal details", "error");
        }
      });
    });
    
function expander(){
  // console.log('expander','expander init')
  $('.card-text').expander({
        slicePoint: 50
      });
}


    function adjustCardHeight($card) {
      // Based on whether the card is flipped or not, set the container's height to the current face's outerHeight.
      var newHeight = $card.hasClass('flipped')
        ? $card.find('.card-back').outerHeight()
        : $card.find('.card-front').outerHeight();
      $card.animate({ height: newHeight }, 400); // Animate over 400ms
    }

    // When flipping to view ingredients
    $(document).on('click', '.btn-view', function () {
      var $cardFlip = $(this).closest('.card-flip');
      // Set the container height to the front side (current height)
      $cardFlip.height($cardFlip.find('.card-front').outerHeight());
      
      // Flip the card by adding the "flipped" class
      $cardFlip.addClass('flipped');
      
      // Adjust the height to match the back side
      adjustCardHeight($cardFlip);
    });

    // When flipping back to front side
    $(document).on('click', '.btn-flip-back', function () {
      var $cardFlip = $(this).closest('.card-flip');
      // Set the container height to the back side (current height)
      $cardFlip.height($cardFlip.find('.card-back').outerHeight());
      
      // Remove the flip class to show the front
      $cardFlip.removeClass('flipped');
      
      // Adjust the height to match the front side
      adjustCardHeight($cardFlip);
    });

    // Cancel button event handler in your document ready function.
    $("#cancelMeal").click(function () {
      // Reset the form.
      $("#addMealForm")[0].reset();
      
      // Clear any stored meal ID and reset button labels.
      $("#mealId").val("");
      $("#addMealForm button[type='submit']").text("Save Meal");
      
      // Rebuild a default ingredient row.
      $("#ingredientsContainer").empty().append(
        '<label class="form-label">Ingredients</label>' +
        '<div class="ingredient-row row mb-2">' +
          '<div class="col-md-4">' +
             '<input type="text" class="form-control ingredient-name" placeholder="Ingredient Name" required />' +
          '</div>' +
          '<div class="col-md-3">' +
             '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Quantity" required />' +
          '</div>' +
          '<div class="col-md-3">' +
             '<input type="text" class="form-control ingredient-unit" placeholder="Unit (e.g., Cup, tsp)" required />' +
          '</div>' +
          '<div class="col-md-2">' +
             '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
          '</div>' +
        '</div>'
      );

      // Collapse the form (if you are using Bootstrap's collapse component).
      $("#addMealSection").collapse("hide");
    });


      
      // Card flip to show ingredients.
      $(document).on("click", ".btn-view", function () {
        $(this).closest(".card-flip").addClass("flipped");
      });
      // Flip back to the front side.
      $(document).on("click", ".btn-flip-back", function () {
        $(this).closest(".card-flip").removeClass("flipped");
      });
      
      // Delete a meal when the trash can is clicked.
      $(document).on("click", ".btn-archive", function() {
        var mealId = $(this).data("meal-id");
        Swal.fire({
          title: 'Are you sure?',
          text: "This meal will be archived! If the meal is already planned, it will remain on the calendar and shopping list.",
          icon: 'warning',
          showCancelButton: true,
          confirmButtonColor: '#3085d6',
          cancelButtonColor: '#d33',
          confirmButtonText: 'Yes, archive it!'
        }).then((result) => {
          if (result.isConfirmed) {
            $.ajax({
              url: "api/mealplanner.cfc?method=archiveMeal",
              method: "POST",
              data: { mealId: mealId },
              dataType: "json",
              success: function(res) {
                if (res.success) {
                  Swal.fire("Archived!", "Meal has been archived.", "success");
                  loadMeals();
                  $('#cardSearchInput').val('');
                } else {
                  Swal.fire("Error", "Could not archive the meal.", "error");
                }
              },
              error: function() {
                Swal.fire("Error", "Could not archive the meal.", "error");
              }
            });
          }
        });
      });
    });