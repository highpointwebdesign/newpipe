let measurementUnitsData = [];


$(document).ready(function () {

    // Add new ingredient group
    $('#addIngredient').on('click', function () {
        const ingredientGroup = $(`
            <div class="ingredient-group row mb-3 align-items-end">
                <div class="col-md-5">
                    <input type="text" class="form-control" placeholder="Ingredient" name="ingredientName">
                </div>
                <div class="col-md-2">
                    <input type="text" class="form-control" placeholder="Measurement" name="ingredientQuantity">
                </div>
                <div class="col-md-3">
                    <select class="form-select ingredient-unit" name="ingredientUnit">
                        <option value="-1">Unit</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-danger btn-sm remove-ingredient">Remove</button>
                </div>
            </div>
        `);
        
        $('#ingredientsContainer').append(ingredientGroup);




        populateUnitsDropdown(); // Populate dropdown without resetting selections
        ingredientGroup.find('.ingredient-unit').select2({ width: '100%' }).trigger('change'); // Ensure new dropdown gets initialized properly
        $('.ingredient-unit').select2({ dropdownParent: $('#createMealModal') });
    });


    // Handle form submission
    $('#mealForm').on('submit', function (e) {
        e.preventDefault();

        const meal_name = $('#mealName').val();
        const ingredients = [];

        $('.ingredient-group').each(function () {
            const ingredient = $(this).find('[name="ingredientName"]').val();
            const quantity = $(this).find('[name="ingredientQuantity"]').val();
            const unit = $(this).find('[name="measurementUnits"]').val();
    
            if (ingredient && quantity && unit) {
                ingredients.push({ ingredient, quantity, unit });
            }
        });


        // Save meal name via POST
        $.post('api/inventory.cfc?method=saveMeal', {
            meal_name: meal_name,
            ingredients: JSON.stringify(ingredients)
        }, function (result) {
            if (result.success === true && result.ingredientStatus.mealIngredientSuccess === true) {
              // Close the modal
              const modal = bootstrap.Modal.getInstance(document.getElementById('createMealModal'));
              if (modal){
                modal.hide();
                $('.modal-backdrop').remove();  //fix for the backdrop not being removed properly
              };

              // Clear the form (optional)
              $('#mealForm')[0].reset();
              $('#ingredientsContainer').html('');

              // Refresh the meal cards
              $('#mealCards').empty();
              loadInventory();
            } else {
              Swal.fire({
                title: 'Error!',
                text: result.message || 'Something went wrong while saving the meal.',
                icon: 'error',
                confirmButtonText: 'OK'
              });
            }
        }, 'json');
    });

    // Remove ingredient group
    $(document).on('click', '.remove-ingredient', function () {
        $(this).closest('.ingredient-group').remove();
    });

    


    loadInventory();
    getMeasurementUnits(); // Load units once globally
    initSelect2(); // Apply Select2 to existing dropdowns

});

function initSelect2(){
    $('.ingredient-unit').select2({
        width: '100%',
        dropdownParent: $('#createMealModal') // Ensures dropdown appears properly inside modals
    });
}

function handleDeleteCard(){
    $('body').on('click', '.delete-icon', function() {
        
        var meal_id = $(this).data('meal_id');
        var mealCard = $(this).closest('.card'); // Find the meal card
        var mealName = mealCard.find('.card-title').text(); // Get meal name

        Swal.fire({
            title: "Delete Meal?",
            text: `Are you sure you want to delete "${mealName}"?`,
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, delete it",
            cancelButtonText: "Cancel"
        }).then((result) => {
            if (result.isConfirmed) {
                mealCard.remove(); // Remove meal card from UI
                $.post('api/inventory.cfc?method=deleteMeal', { meal_name: mealName, meal_id: meal_id }, function(response) {
                    console.log('Deleted meal:', response);
                });
            }
        });

    });
}


function parseQuantity(value) {
    value = value.trim();
    if (value.includes(' ')) {
      // Handle mixed numbers like "1 1/2"
      const [whole, fraction] = value.split(' ');
      const [num, denom] = fraction.split('/');
      return parseFloat(whole) + (parseFloat(num) / parseFloat(denom));
    } else if (value.includes('/')) {
      // Handle simple fractions like "1/4"
      const [num, denom] = value.split('/');
      return parseFloat(num) / parseFloat(denom);
    } else {
      // Handle decimals or whole numbers
      return parseFloat(value);
    }
}

function getMeasurementUnits() {
    $.ajax({
        url: 'api/inventory.cfc?method=getMeasurementUnits',
        method: 'GET',
        dataType: 'json',
        success: function(data) {
            measurementUnitsData = data; // Store globally
            populateUnitsDropdown(); // Populate existing dropdowns
        },
        error: function(xhr, status, error) {
            console.error("Error loading measurement units:", error);
        }
    });
}

function populateUnitsDropdown() {
    $('.ingredient-group select[name="ingredientUnit"]').each(function () {
        var dropdown = $(this);

        // Preserve the previously selected value
        var previousValue = dropdown.val();

        // Clear existing options and repopulate
        dropdown.empty();
        dropdown.append(`<option value="-1">Select</option>`);

        measurementUnitsData.forEach(unit => {
            dropdown.append(`<option value="${unit.id}">${unit.unit_name} (${unit.base_unit})</option>`);
        });

        // Restore the previous selection after reinitialization
        dropdown.val(previousValue).trigger('change');
    });
}



function loadInventory() {
    $.post('api/inventory.cfc?method=getMeals', function (data) {
      if (Array.isArray(data)) {
        data.forEach(meal => {
          const card = `
            <div class="col-md-4">
              <div class="card h-100 shadow-sm">
                <div class="card-body">
                  <h5 class="card-title">${meal.meal_name}</h5>
                  <a href="recipe.htm?id=${meal.meal_id}" class="btn btn-outline-primary">View</a>
                  <i class="fas fa-trash-alt delete-icon" data-meal_id=${meal.meal_id}></i>
                </div>
              </div>
            </div>
          `;
          $('#mealCards').append(card);
        });
      } else {
        console.error("Unexpected response format:", data);
      }

    handleDeleteCard();

    }, 'json');
}