function getRecipeIdFromUrl() {
  const params = new URLSearchParams(window.location.search);
  return params.get('id'); // Returns the ID from the query string
}


function fetchRecipeDetails(recipeId) {
  $.post('api/inventory.cfc?method=getRecipe', { id: recipeId }, function (data) {
  	// console.log(data);
    if (data[0].success) {
      updateRecipePage(data);
    } else {
      console.error('Failed to load recipe');
    }
  }, 'json');
}


// function updateRecipePage(recipe) {
// 	console.log(recipe);

//   $('.post__title').text(recipe[0].meal_name);
//   $('#ingredientsList').empty(); // Clear previous ingredients
//   recipe[0].ingredients.forEach(item => {
//     $('#ingredientsList').append(`<li>${item.ingredient} - ${item.quantity} ${item.unit}</li>`);
//   });
// }

function updateRecipePage(recipe) {
    console.log(recipe);

    // Remove skeleton class once data is loaded
    $('.post__title').removeClass('skeleton skeleton-text').text(recipe[0].meal_name);
    $('#ingredientsList').empty();

    recipe[0].ingredients.forEach(item => {
        $('#ingredientsList').append(`<li>${item.ingredient} - ${item.quantity} ${item.unit}</li>`);
    });
}



const conversionFactors = {
    "tsp": { "tbsp": 1 / 3, "cup": 1 / 48 },
    "tbsp": { "tsp": 3, "cup": 1 / 16 },
    "cup": { "tsp": 48, "tbsp": 16 }
};

// Example: Convert 3 tsp to tbsp
// console.log(convertMeasurement(3, "tsp", "tbsp")); // Output: 1
function convertMeasurement(quantity, fromUnit, toUnit) {
    if (conversionFactors[fromUnit] && conversionFactors[fromUnit][toUnit]) {
        return quantity * conversionFactors[fromUnit][toUnit];
    }
    return null; // No valid conversion
}





$(document).ready(function () {
  const recipeId = getRecipeIdFromUrl();
  if (recipeId) {
    fetchRecipeDetails(recipeId);
  } else {
    console.error('No recipe ID provided in the URL');
  }
});
