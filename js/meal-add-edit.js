$(document).ready(function () {

      $('#ingredientID').focus();

      const urlParams = new URLSearchParams(window.location.search);
      const status = urlParams.get('status');
      const msg = urlParams.get('msg');
console.log(status);
console.log(msg);
      if status === 1 {
            Swal.fire({
                  title: "Oh Fork!",
                  text: msg,
                  icon: "danger",
                  showCancelButton: false
            })

      } else if status === 0 {
            Swal.fire({
                  title: "Now you are cooking!",
                  text: msg,
                  icon: "success",
                  showCancelButton: false
            })
      }
      // Load meals when the page loads.
      // loadMeals();
      // $('#details').summernote();

    // $("#addIngredientBtn").click(function() {

    //   var ingredientRow =
    //   '<div class="ingredient-row row mb-2">'+
    //       '<div class="col-md-2">' +
    //         '<input type="number" step="0.25" class="form-control ingredient-quantity" placeholder="Enter Quantity" required />' +
    //       '</div>' +
    //       '<div class="col-md-3">' +
    //         '<select class="form-control" required>' +
    //           '<option>Select Unit (e.g., Cup, tsp)</option> <!-- Empty option for placeholder -->' +
    //           '<cfoutput query="UoM">' +
    //             '<option value="#UoM.id#">#UoM.unit_name# (#UoM.base_unit#/#UoM.unit_type#)</option>' +
    //           '</cfoutput>' +
    //         '</select>' +
    //       '</div>' +
    //       '<div class="col-md-5">                        ' +
    //         '<select class="form-control" placeholder="Ingredient Name" required>' +
    //           '<option>Select Ingredient Name</option> <!-- Empty option for placeholder -->' +
    //           '<cfoutput query="ingredients">' +
    //             '<option value="#ingredients.ingredientID#">#ingredients.ingredient_name#</option>' +
    //           '</cfoutput>                           ' +
    //         '</select>' +
    //       '</div>' +
    //       '<div class="col-md-2">' +
    //         '<button type="button" class="btn btn-danger btn-remove-ingredient">Remove</button>' +
    //       '</div>' +
    //     '</div>' +
    //   '</div>';

    // // Append the row
    // $("#ingredientsContainer").append(ingredientRow);
    // });

    
});