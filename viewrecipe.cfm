<!--- index.cfm --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Management</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <!-- Summernote -->
        <script src="vendor/ckeditor/ckeditor.js"></script>
        
        <!-- Summernote library -->
        <script src="/vendor/summernote/js\summernote.min.js"></script>
        <!-- Summernote init -->
        <!--- <script src="js/summernote-init.js"></script> --->
    <!--- select2 --->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <!--- datatables --->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/dataTables.bootstrap5.min.css">
    <!-- Summernote -->
    <link href="vendor/summernote/summernote.css" rel="stylesheet">

    <style>
        .recipe-ingredients {
    margin: 20px 0;
}

.ingredients-list {
    list-style: none;
    padding: 0;
}

.ingredient-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px solid #eee;
}

.ingredient-text {
    flex-grow: 1;
}

.btn-add-ingredient, .btn-add-directions {
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 4px;
    padding: 5px 10px;
    cursor: pointer;
    font-size: 12px;
    transition: all 0.3s;
}

.btn-add-ingredient:hover, .btn-add-directions:hover {
    background-color: #45a049;
}

.btn-add-ingredient.added, .btn-add-directions.added {
    background-color: #888;
    cursor: default;
}

.notification {
    position: fixed;
    bottom: 20px;
    right: 20px;
    padding: 15px 20px;
    border-radius: 4px;
    color: white;
    opacity: 0;
    transform: translateY(20px);
    transition: all 0.3s;
    z-index: 1000;
}

.notification.show {
    opacity: 1;
    transform: translateY(0);
}

.notification.success {
    background-color: #4CAF50;
}

.notification.error {
    background-color: #f44336;
}</style>
</head>
<body>
    <div class="container mt-5">
        <h1 class="sb-4">Inventory Management</h1>
        <div class="sb-3">
            <div class="btn-group" role="group" aria-label="Inventory actions">
                <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#addItemModal">
                    Add New Item
                </button>
                <a href="shoppingList.htm" class="btn btn-outline-primary">View Shopping List</a>
                <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#manageCategoriesModal">
                    Manage Categories
                </button>
                <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#manageMealTypesModal">
                    Manage Meal Types
                </button>
                <a href="reviewrecipes.htm" class="btn btn-outline-primary">Review Recipes</a>
                <a href="/" class="btn btn-outline-primary">Meal Planner</a>
            </div>
        </div>

        <table>
            <tr valign="top">
                <td width="50%"><div id="recipe-content-trello"></div></td>
                <td style="border-left: 1px solid black; padding: 5px"></td>
                <td width="50%"><div id="recipe-content-form"><cfinclude template="/includes/add_edit_ingredients.cfm"></div></td>
            </tr>
        </table>

    </div>




    <!-- Bootstrap 5 JS Bundle (includes Popper) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Your custom JS -->
    <script>
        alert('i don\'t believe this page is used');
        function loadInventory() {

            const urlParams = new URLSearchParams(window.location.search);
          const recipeId = urlParams.get('id');

          $.ajax({
            url: "api/mealplanner.cfc?method=getRecipeDetails&recipe_id=" + recipeId,
                method: 'GET',
                dataType: 'json',
                success: function(response) {
                    $('#mealTitle').val(response[0].name);
                        const recipe = response[0];
console.log(recipe.name);                        
                        // Format the last activity date
                    
                        
                        // Parse the description to extract ingredients and directions
                        const { ingredients, directions } = parseRecipeContent(recipe.description);
                        
                        // Build the HTML content
                        let html = `
                            <div class="recipe-header">
                                <h1>${recipe.name}</h1>
                            </div>
                            <div class="recipe-meta">
                                <p><strong>Recipe ID:</strong> ${recipe.recipe_id}</p>
                            </div>
                            <div class="recipe-ingredients">
                                <h2>Ingredients</h2>
                                <ul class="ingredients-list">
                                    ${ingredients.map(ingredient => `
                                        <li class="ingredient-item">
                                            <span class="ingredient-text">${ingredient}</span>
                                            <button class="btn-add-ingredient" data-recipe-id="${recipe.recipe_id}" data-ingredient="${encodeURIComponent(ingredient)}">
                                                Add
                                            </button>
                                        </li>
                                    `).join('')}
                                </ul>
                            </div>
                            <div class="recipe-directions">
                                <h2>Directions</h2>
                                <div>${directions}</div>
                                    <button class="btn-add-directions" data-directions="${encodeURIComponent(directions)}">
                                    Add
                                    </button>
                            </div>
                        `;
                        
                        $('#recipe-content-trello').html(html);

                        
                        // Add event listeners for the add ingredient buttons
                        $('.btn-add-ingredient').on('click', function() {
                            const recipeId = $(this).data('recipe-id');
                            const ingredient = decodeURIComponent($(this).data('ingredient'));
                            // addIngredientToDatabase(recipeId, ingredient, $(this));
                        });
                        $('.btn-add-directions').on('click', function() {
                            console.log('clicked');
                            const directions = decodeURIComponent($(this).data('directions'));
                            $('#details').summernote({
                                placeholder: directions,
                                tabsize: 2,
                                height: 100
                            })
                            // addIngredientToDatabase(recipeId, ingredient, $(this));
                        });
                    
                },

                error: function(xhr, status, error) {
                    console.error('Error loading inventory:', error);
                }
            });
        }

// Function to parse recipe content
function parseRecipeContent(description) {
    if (!description) {
        return { ingredients: [], directions: '<p>No directions available.</p>' };
    }
    
    // Split by "Directions" keyword to separate ingredients and directions
    const parts = description.split(/Directions\s*(?:\d+\.)?/i);
    
    let ingredientsText = parts[0] || '';
    let directionsText = parts[1] || '';
    
    // Extract ingredients (lines starting with dash)
    const ingredientLines = ingredientsText.split('-').map(line => line.trim()).filter(line => line);
    
    // Remove "Ingredients" header if present
    let ingredients = ingredientLines;
    if (ingredients.length > 0 && ingredients[0].toLowerCase().includes('ingredients')) {
        ingredients = ingredients.slice(1);
    }
    
    // Format directions as paragraphs
    let directions = '';
    if (directionsText) {
        // Try to identify numbered steps
        const directionSteps = directionsText.split(/\d+\./).filter(step => step.trim());
        
        if (directionSteps.length > 1) {
            // If we have numbered steps, format them as an ordered list
            directions = '<ol>' + directionSteps.map(step => `<li>${step.trim()}</li>`).join('') + '</ol>';
        } else {
            // Otherwise just use paragraphs
            directions = '<p>' + directionsText.replace(/\n/g, '</p><p>') + '</p>';
        }
    } else {
        directions = '<p>No directions available.</p>';
    }
    
    return { ingredients, directions };
}

// Function to add ingredient to database
function addIngredientToDatabase(recipeId, ingredient, buttonElement) {
    $.ajax({
        url: 'api/mealplanner.cfc?method=addIngredient',
        method: 'POST',
        dataType: 'json',
        data: {
            recipe_id: recipeId,
            ingredient: ingredient
        },
        success: function(response) {
            if (response && response.success) {
                // Visual feedback
                buttonElement.addClass('added');
                buttonElement.text('Added');
                buttonElement.prop('disabled', true);
                
                // Optional: Show a toast or notification
                showNotification('Ingredient added successfully!', 'success');
            } else {
                showNotification('Failed to add ingredient: ' + (response.message || 'Unknown error'), 'error');
            }
        },
        error: function(xhr, status, error) {
            showNotification('Error adding ingredient: ' + error, 'error');
        }
    });
}

// Simple notification function
function showNotification(message, type) {
    const notification = $(`<div class="notification ${type}">${message}</div>`);
    $('body').append(notification);
    
    setTimeout(function() {
        notification.addClass('show');
        
        setTimeout(function() {
            notification.removeClass('show');
            setTimeout(function() {
                notification.remove();
            }, 300);
        }, 3000);
    }, 100);
}

$(document).ready(function() {
    loadInventory();
});
    </script>
    <!--- sweet alert --->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!--- datables --->
    <script type="text/javascript" src="https://cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/1.10.24/js/dataTables.bootstrap5.min.js"></script>

    

</body>
</html>