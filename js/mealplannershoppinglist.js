// new
// Configuration
const CONFIG = {
  calendarId: "d13bc429760b3feaa0e8ca2f1b50ea9e9e25cf3a7d966e46120b09ccdff295ac@group.calendar.google.com",
  selectors: {
    dateFilter: "#datefilter",
    generateListBtn: "#generateListBtn",
    mealListContainer: "#mealListContainer",
    shoppingList: "#shoppingList",
    alertContainer: "#alertContainer"
  }
};

// State
let userAccessToken = sessionStorage.getItem("userAccessToken");
if (!userAccessToken) {
  console.error("Authentication required. Please log in.");
}

$(function() {
  // Initialize date picker
  const start = moment().add(1, 'days');
  const end = moment().add(14, 'days');
  
  $(CONFIG.selectors.dateFilter).daterangepicker({
    autoUpdateInput: true,
    showDropdowns: true,
    autoApply: true,
    startDate: start,
    endDate: end
  });

  // Set up button click handler
  $(CONFIG.selectors.generateListBtn).click(function() {
    const picker = $(CONFIG.selectors.dateFilter).data("daterangepicker");
    const startDate = picker.startDate.format("YYYY-MM-DD");
    const endDate = picker.endDate.format("YYYY-MM-DD");
    
    loadMealEvents(startDate, endDate);
  });
});

$(CONFIG.selectors.dateFilter).on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format('MM/DD/YYYY') + ' - ' + picker.endDate.format('MM/DD/YYYY'));
    
    // Update hidden fields with ISO formatted dates
    $('#startDate').val(picker.startDate.format('YYYY-MM-DD'));
    $('#endDate').val(picker.endDate.format('YYYY-MM-DD'));
});





/**
 * Main function to load and process meal events
 */
async function loadMealEvents(startDate, endDate) {
  try {
    // Fetch raw events
    const rawData = await getRecipesForDateRange(startDate, endDate);
    
    // Process the data
    const processedData = processRecipeData(rawData);
    
    console.log('Processed meals:', processedData.meals);
    console.log('Processed ingredients by unit:', processedData.ingredientsByUnit);
    
    // Now you can use processedData.meals and processedData.ingredientsByUnit
    // to update your UI or perform other operations
    
    return processedData;
  } catch (error) {
    console.error("Error loading meal events:", error);

    // Show a SweetAlert with the error info
    Swal.fire({
      title: "Error loading data",
      html: "An error occurred while loading meal data",
      icon: "warning",
      showCancelButton: false,
      confirmButtonText: "Okay"
    });
  }
}

function getRecipesForDateRange(startDate, endDate) {
  // Return a Promise that resolves with the AJAX response
  return new Promise((resolve, reject) => {
    $.ajax({
      url: 'api/mealplanner.cfc?method=getRecipesForDateRange',
      method: 'POST',
      data: {
        startDate: startDate,
        endDate: endDate
      },
      dataType: 'json',
      success: function(response) {
        console.log('response');
        console.log(response);
        resolve(response); // Return the raw data
      },
      error: function(xhr, status, error) {
        console.error('Error fetching recipes:', error);
        reject(error);
      }
    });
  });
}

// Your process function as defined earlier
function processRecipeData(data) {
  // Create meals array with titles and other meal info
  const mealsArray = data.map(meal => ({
    mealID: meal.mealID,
    title: meal.title,
    servings: meal.servings,
    startDate: meal.startDate,
    mealTypeID: meal.mealTypeID,
    charmName: meal.charmName
  }));
  
  // Create ingredients array with combined ingredients by unitID
  const ingredientsByUnit = {};
  
  // Process all meals and their ingredients
  data.forEach(meal => {
    meal.ingredients.forEach(ingredient => {
      const unitID = ingredient.unitID;
      
      // If this unitID doesn't exist in our map yet, create it
      if (!ingredientsByUnit[unitID]) {
        ingredientsByUnit[unitID] = {
          unitID: unitID,
          unitName: ingredient.unitName,
          unitType: ingredient.unitType,
          baseUnit: ingredient.baseUnit,
          isIndivisible: ingredient.isIndivisible,
          items: []
        };
      }
      
      // Check if this ingredient name already exists in this unit group
      const existingItem = ingredientsByUnit[unitID].items.find(item => 
        item.name === ingredient.name
      );
      
      if (existingItem) {
        // If ingredient already exists, add to its quantity
        existingItem.optionValue += ingredient.optionValue;
        existingItem.meals.push({
          mealID: meal.mealID,
          title: meal.title,
          amount: ingredient.optionValue,
          textValue: ingredient.textValue
        });
      } else {
        // If ingredient doesn't exist yet, add it
        ingredientsByUnit[unitID].items.push({
          name: ingredient.name,
          optionValue: ingredient.optionValue,
          textValue: ingredient.textValue,
          meals: [{
            mealID: meal.mealID,
            title: meal.title,
            amount: ingredient.optionValue,
            textValue: ingredient.textValue
          }]
        });
      }
    });
  });
  
  // Convert the ingredients object to an array
  const ingredientsArray = Object.values(ingredientsByUnit);
  
  return {
    meals: mealsArray,
    ingredientsByUnit: ingredientsArray
  };
}

// Example usage
// const processedData = processRecipeData(yourJsonData);
// console.log("Meals:", processedData.meals);
// console.log("Ingredients by Unit:", processedData.ingredientsByUnit);