$(document).ready(function() {
  // Event delegation for add buttons
  $('#addItemBtn').click(function() {
    $('#addItemModal').modal('show');
  });
  // Event delegation for edit buttons
  $('#inventoryTable').on('click', '.edit-item', function() {
    var itemId = $(this).data('id');
    openEditModal(itemId);
  });
  // Event delegation for delete buttons
  $('#saveEditButton').on('click', function() {
    saveEditedItem();
  });
  // Event delegation for delete buttons
  $('#inventoryTable').on('click', '.delete-item', function() {
    var itemId = $(this).data('id');
    if (confirm('Are you sure you want to delete this item?')) {
      deleteItem(itemId);
    }
  }); 
  
  // Event delegation for Add Category
  $('#addCategoryBtn').on('click', function() {
    addCategory();
  });
  // Event delegation for Delete Category
  $('#categoryList').on('click', '.delete-category', function() {
    var categoryId = $(this).data('id');
    deleteCategory(categoryId);
  });
  // Event listener for when the Manage Categories modal is about to be shown
  $('#manageCategoriesModal').on('show.bs.modal', function (e) {
    loadCategories();
  });

  // Event delegation for Add Category
  $('#addmealTypeBtn').on('click', function() {
    addMealType();
  });
  // Event delegation for Delete Category
  $('#mealTypesList').on('click', '.delete-mealType', function() {
    var mealTypeID = $(this).data('id');
    deleteMealType(mealTypeID);
  });
  // Event listener for when the Manage Categories modal is about to be shown
  $('#manageMealTypesModal').on('show.bs.modal', function (e) {
    loadMealTypes();
  });



  // populate category select2 
  $('.category-select').select2({
    theme: 'bootstrap-5',
    ajax: {
      url: 'api/inventory.cfc?method=getCategories',
      dataType: 'json',
      processResults: function (data) {
        return {
          results: data.DATA.map(function(item) {
            return {id: item[0], text: item[1]};
          })
        };
      }
    }
  });  

  // datatables init
  $(document).ready(function() {
    var table = $('#inventoryTable').DataTable({
        "pageLength": 10,
        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
        "order": [[0, "asc"], [1, "asc"]], // Sort by Category then Item
        "columnDefs": [
            { "orderable": false, "targets": 5 } // Disable sorting on Actions column
        ],
        "language": {
            "search": "Search:",
            "lengthMenu": "Show _MENU_ entries",
            "info": "Showing _START_ to _END_ of _TOTAL_ entries",
            "infoEmpty": "Showing 0 to 0 of 0 entries",
            "infoFiltered": "(filtered from _MAX_ total entries)",
            "paginate": {
                "first": "First",
                "last": "Last",
                "next": "Next",
                "previous": "Previous"
            }
        }
    });
  });
  


  $('#addItemModal').on('hidden.bs.modal', function (e) {
    $(this).find('button, input, textarea, select').blur();
  });
  $('#editItemModal').on('hidden.bs.modal', function (e) {
    $(this).find('button, input, textarea, select').blur();
  });
  $('#manageCategoriesModal').on('hidden.bs.modal', function (e) {
    $(this).find('button, input, textarea, select').blur();
  });
  
  // Handle form submission
  $('#saveNewItem').click(function() {
      var newItem = {
          name: $('#itemName').val(),
          current_quantity: parseInt($('#currentQuantity').val()),
          desired_quantity: parseInt($('#desiredQuantity').val()),
          reorder_threshold: parseInt($('#reorderThreshold').val()),
          category_id: parseInt($('#itemCategory').val())
      };

      $.ajax({
          url: 'api/inventory.cfc?method=add',
          method: 'POST',
          data: newItem,
          dataType: 'json',
          success: function(response) {
              if (response.success) {
                  $('#addItemModal').modal('hide');
                  loadInventory(); // Reload the inventory table
                  // Clear the form
                  $('#addItemForm')[0].reset();
              } else {
                  // alert('Error adding item');
                  // Success message with SweetAlert
                  Swal.fire({
                      title: 'Error!',
                      text: 'Error adding the item',
                      icon: 'error',
                      confirmButtonText: 'OK'
                  });
              }
          },
          error: function(xhr, status, error) {
              // console.error('Error adding item:', error);
              // alert('Error adding item');
              Swal.fire({
                      title: 'Error!',
                      text: 'Error adding the item.',
                      icon: 'error',
                      confirmButtonText: 'OK'
                  });
          }
      });
  });

  $('#addItemModal').on('show.bs.modal', function (e) {
      // Fetch categories and populate the select box
      $.ajax({
          url: 'api/inventory.cfc?method=getCategories',
          method: 'GET',
          dataType: 'json',
          success: function(response) {
              var categorySelect = $('#itemCategory');
              categorySelect.find('option:not(:first)').remove(); // Clear existing options
              
              // Check if response has the expected structure
              if (response.COLUMNS && response.DATA) {
                  var idIndex = response.COLUMNS.indexOf("id");
                  var nameIndex = response.COLUMNS.indexOf("name");
                  
                  if (idIndex !== -1 && nameIndex !== -1) {
                      response.DATA.forEach(function(category) {
                          categorySelect.append($('<option>', {
                              value: category[idIndex],
                              text: category[nameIndex]
                          }));
                      });
                  }
              }
          },
          error: function(xhr, status, error) {
              console.error('Error fetching categories:', error);
          }
      });
  });

  function openEditModal(itemId) {
      console.log('Opening edit modal for item ID:', itemId);
      
      // First, fetch categories
      $.ajax({
          url: 'api/inventory.cfc?method=getCategories',
          method: 'GET',
          dataType: 'json',
          success: function(response) {
              console.log('Categories received:', response);
              
              // Parse the ColdFusion query result structure
              var categories = response.DATA.map(function(row, index) {
                  return {
                      id: row[0],
                      name: row[1]
                  };
              });
              
              // Populate category dropdown
              var categorySelect = $('#editItemCategory');
              categorySelect.empty();
              categorySelect.append('<option value="">Select a category</option>');
              $.each(categories, function(index, category) {
                  categorySelect.append($('<option></option>').val(category.id).text(category.name));
              });
              
              // Now fetch the item details
              $.ajax({
                  url: 'api/inventory.cfc?method=getItem',
                  method: 'GET',
                  data: { id: itemId },
                  dataType: 'json',
                  success: function(response) {
                      console.log('Item data received:', response);
                      
                      $('#editItemId').val(response.id);
                      $('#editItemName').val(response.name);
                      $('#editItemCategory').val(response.category_id);
                      $('#editCurrentQuantity').val(response.current_quantity);
                      $('#editDesiredQuantity').val(response.desired_quantity);
                      $('#editReorderThreshold').val(response.reorder_threshold);
                      
                      // Open the modal
                      var editModal = new bootstrap.Modal(document.getElementById('editItemModal'));
                      editModal.show();
                      console.log('Modal should be visible now');
                  },
                  error: function(xhr, status, error) {
                      console.error('Error fetching item details:', error);
                  }
              });
          },
          error: function(xhr, status, error) {
              console.error('Error fetching categories:', error);
          }
      });
  }

  function saveEditedItem() {
      var updatedItem = {
          id: $('#editItemId').val(),
          name: $('#editItemName').val(),
          category_id: $('#editItemCategory').val(),
          current_quantity: $('#editCurrentQuantity').val(),
          desired_quantity: $('#editDesiredQuantity').val(),
          reorder_threshold: $('#editReorderThreshold').val()
      };

      $.ajax({
          url: 'api/inventory.cfc?method=updateItem',
          method: 'POST',
          data: updatedItem,
          dataType: 'json',
          success: function(response) {
              console.log('Item updated successfully:', response);
              
              // Close the modal
              var editModal = bootstrap.Modal.getInstance(document.getElementById('editItemModal'));
              editModal.hide();

              // Refresh the main display
              loadInventory();

              // Optionally, show a success message
              // alert('Item updated successfully!');
              Swal.fire({
                      title: 'Success!',
                      text: 'Item updated successfully',
                      icon: 'success',
                      confirmButtonText: 'OK'
                  });
          },
          error: function(xhr, status, error) {
              // console.error('Error updating item:', error);
              // alert('Error updating item. Please try again.');
              Swal.fire({
                      title: 'Error!',
                      text: 'Error updating the item.',
                      icon: 'error',
                      confirmButtonText: 'OK'
                  });
          }
      });
  } 

  function deleteItem(itemId) {
      $.ajax({
          url: 'api/inventory.cfc?method=deleteItem',
          method: 'POST',
          data: { id: itemId },
          dataType: 'json',
          success: function(response) {
              console.log('Item deleted successfully:', response);
              
              // Remove the item from the display
              $(`#inventoryTable button[data-id="${itemId}"]`).closest('tr').remove();
              
              // Alternatively, refresh the entire list
              // loadInventory();

              // Optionally, show a success message
              // alert('Item deleted successfully!');
              Swal.fire({
                      title: 'Success!',
                      text: 'Item deleted successfully',
                      icon: 'success',
                      confirmButtonText: 'OK'
                  });
          },
          error: function(xhr, status, error) {
              // console.error('Error deleting item:', error);
              // alert('Error deleting item. Please try again.');
              Swal.fire({
                  title: 'Error!',
                  text: 'Error deleting the item',
                  icon: 'error',
                  confirmButtonText: 'OK'
              });
          }
      });
  }   

  // function loadInventory() {
  //   $.ajax({
  //       url: 'api/inventory.cfc?method=list',
  //       method: 'GET',
  //       dataType: 'json',
  //       success: function(response) {
  //           const tbody = $('#inventoryTable tbody');
  //           tbody.empty();
            
            // response.forEach(item => {
            //     const row = `
            //         <tr>
            //             <td>${item.category_name}</td>
            //             <td>${item.name}</td>
            //             <td>${item.current_quantity}</td>
            //             <td>${item.desired_quantity}</td>
            //             <td>${item.reorder_threshold}</td>
            //             <td>
            //                 <button class="btn btn-sm btn-primary edit-item" data-id="${item.id}">Edit</button>
            //                 <button class="btn btn-sm btn-danger delete-item" data-id="${item.id}">Delete</button>
            //             </td>
            //         </tr>
            //     `;
            //     tbody.append(row);
            // });
  //       },
  //       error: function(xhr, status, error) {
  //           console.error('Error fetching inventory:', error);
  //           Swal.fire({
  //               title: 'Error!',
  //               text: 'Error fetching the data',
  //               icon: 'error',
  //               confirmButtonText: 'OK'
  //           });
  //       }
  //   });
  // }
function loadInventory() {
    $.ajax({
        url: 'api/inventory.cfc?method=list',
        method: 'GET',
        dataType: 'json',
        success: function(data) {
            if (Array.isArray(data)) {
                // Destroy existing DataTable if it exists
                if ($.fn.DataTable.isDataTable('#inventoryTable')) {
                    $('#inventoryTable').DataTable().destroy();
                }

                // Initialize DataTable with data
                $('#inventoryTable').DataTable({
                    data: data,
                    columns: [
                        { data: 'category_name' },
                        { data: 'name' },
                        { data: 'current_quantity' },
                        { data: 'desired_quantity' },
                        { data: 'reorder_threshold' },
                        {
                            data: 'id',
                            render: function(data, type, row) {
                                return `
                                    <button class="btn btn-sm btn-primary edit-item" data-id="${data}">Edit</button>
                                    <button class="btn btn-sm btn-danger delete-item" data-id="${data}">Delete</button>
                                `;
                            }
                        }
                    ],
                    columnDefs: [
                        { targets: -1, orderable: false } // Make the last column (actions) not sortable
                    ],
                    paging: false,
                    ordering: true,
                    info: false,
                    searching: true
                });

                console.log('DataTable initialized successfully');
            } else {
                console.error('Data is not an array:', data);
            }
        },
        error: function(xhr, status, error) {
            console.error('Error loading inventory:', error);
        }
    });
}

$(document).ready(function() {
    loadInventory();
});






  function updateItem() {
      var itemId = $('#editItemId').val();
      var itemName = $('#editItemName').val();
      var categoryId = $('#editItemCategory').val();
      var currentQuantity = $('#editCurrentQuantity').val();
      var desiredQuantity = $('#editDesiredQuantity').val();
      var reorderThreshold = $('#editReorderThreshold').val();

      $.ajax({
          url: '/api/inventory.cfc?method=update',
          method: 'POST',
          data: {
              id: itemId,
              name: itemName,
              category_id: categoryId,
              current_quantity: currentQuantity,
              desired_quantity: desiredQuantity,
              reorder_threshold: reorderThreshold
          },
          dataType: 'json',
          success: function(response) {
              if (response.success) {
                  $('#editItemModal').modal('hide');
                  loadInventory(); // Refresh the item list
              } else {
                  // alert('Error updating item: ' + response.error);
                  Swal.fire({
                      title: 'Error!',
                      text: 'Error udpating the item',
                      icon: 'error',
                      confirmButtonText: 'OK'
                  });
              }
          },
          error: function(xhr, status, error) {
              // alert('Error updating item: ' + error);
              Swal.fire({
                  title: 'Error!',
                  text: 'Error adding the item',
                  icon: 'error',
                  confirmButtonText: 'OK'
              });
          }
      });
  }

  function updateTable(newData) {
    var table = $('#inventoryTable').DataTable();
    table.clear();
    table.rows.add(newData);
    table.draw();
  }

  // Generic function to load items
function loadItems(config) {
    $.ajax({
        url: `api/inventory.cfc?method=${config.loadMethod}`,
        method: 'GET',
        dataType: 'json',
        success: function(response) {
            const listElement = $(`#${config.listId}`);
            listElement.empty();
            response.DATA.forEach(item => {
                listElement.append(`
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        ${item[1]}
                        <button class="btn btn-sm btn-danger delete-${config.itemType}" data-id="${item[0]}">Delete</button>
                    </li>
                `);
            });
        },
        error: function(xhr, status, error) {
            Swal.fire({
                title: 'Error!',
                text: `Error fetching ${config.displayName}`,
                icon: 'error',
                confirmButtonText: 'OK'
            });
        }
    });
}

// Generic function to add an item
function addItem(config) {
    const newItemName = $(`#${config.inputId}`).val().trim();
    if (newItemName) {
        $.ajax({
            url: `api/inventory.cfc?method=${config.addMethod}`,
            method: 'POST',
            data: { name: newItemName },
            dataType: 'json',
            success: function(response) {
                $(`#${config.inputId}`).val('');
                config.loadFunction();
            },
            error: function(xhr, status, error) {
                Swal.fire({
                    title: 'Error!',
                    text: `Error adding the ${config.displayName}`,
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
            }
        });
    }
}

// Generic function to delete an item
function deleteItem(config, itemId) {
    if (confirm(`Are you sure you want to delete this ${config.displayName}?`)) {
        $.ajax({
            url: `api/inventory.cfc?method=${config.deleteMethod}`,
            method: 'POST',
            data: { id: itemId },
            dataType: 'json',
            success: function(response) {
                config.loadFunction();
            },
            error: function(xhr, status, error) {
                Swal.fire({
                    title: 'Error!',
                    text: `Error deleting the ${config.displayName}`,
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
            }
        });
    }
}

// Configuration objects for each entity type
const categoryConfig = {
    itemType: 'category',
    displayName: 'category',
    listId: 'categoryList',
    inputId: 'newCategoryName',
    loadMethod: 'getCategories',
    addMethod: 'addCategory',
    deleteMethod: 'deleteCategory',
    loadFunction: function() { loadItems(categoryConfig); }
};

const mealTypeConfig = {
    itemType: 'mealType',
    displayName: 'meal type',
    listId: 'mealTypesList',
    inputId: 'newMealTypeName',
    loadMethod: 'loadMealTypes',
    addMethod: 'addMealType',
    deleteMethod: 'deleteMealType',
    loadFunction: function() { loadItems(mealTypeConfig); }
};

const quantityOptionsConfig = {
    itemType: 'quantityOptions',
    displayName: 'quantity option',
    listId: 'quantityOptionsList',
    inputId: 'newquantityOptionsName',
    loadMethod: 'loadQuantityOptions',
    addMethod: 'addquantityOptions',
    deleteMethod: 'deletequantityOptions',
    loadFunction: function() { loadItems(quantityOptionsConfig); }
};

const uomOptionsConfig = {
    itemType: 'uomOptions',
    displayName: 'UOM option',
    listId: 'uomOptionsList',
    inputId: 'newuomOptionsName',
    loadMethod: 'loaduomOptions',
    addMethod: 'adduomOptions',
    deleteMethod: 'deleteuomOptions',
    loadFunction: function() { loadItems(uomOptionsConfig); }
};

// Wrapper functions to maintain the original API
function loadCategories() {
    loadItems(categoryConfig);
}

function addCategory() {
    addItem(categoryConfig);
}

function deleteCategory(categoryId) {
    deleteItem(categoryConfig, categoryId);
}

function loadMealTypes() {
    loadItems(mealTypeConfig);
}

function addMealType() {
    addItem(mealTypeConfig);
}

function deleteMealType(mealTypeId) {
    deleteItem(mealTypeConfig, mealTypeId);
}

function loadQuantityOptions() {
    loadItems(quantityOptionsConfig);
}

function addquantityOptions() {
    addItem(quantityOptionsConfig);
}

function deletequantityOptions(quantityOptionsId) {
    deleteItem(quantityOptionsConfig, quantityOptionsId);
}

function loaduomOptions() {
    loadItems(uomOptionsConfig);
}

function adduomOptions() {
    addItem(uomOptionsConfig);
}

function deleteuomOptions(uomOptionsId) {
    deleteItem(uomOptionsConfig, uomOptionsId);
}

  // //    CATEGORIES
  // function loadCategories() {
  //   $.ajax({
  //       url: 'api/inventory.cfc?method=getCategories',
  //       method: 'GET',
  //       dataType: 'json',
  //       success: function(response) {
  //           const categoryList = $('#categoryList');
  //           categoryList.empty();
  //           response.DATA.forEach(category => {
  //               categoryList.append(`
  //                   <li class="list-group-item d-flex justify-content-between align-items-center">
  //                       ${category[1]}
  //                       <button class="btn btn-sm btn-danger delete-category" data-id="${category[0]}">Delete</button>
  //                   </li>
  //               `);
  //           });
  //       },
  //       error: function(xhr, status, error) {
  //           // console.error('Error fetching categories:', error);
  //           Swal.fire({
  //               title: 'Error!',
  //               text: 'Error fetching categories',
  //               icon: 'error',
  //               confirmButtonText: 'OK'
  //           });
  //       }
  //   });
  // }  

  // function addCategory() {
  //     const newCategoryName = $('#newCategoryName').val().trim();
  //     if (newCategoryName) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=addCategory',
  //             method: 'POST',
  //             data: { name: newCategoryName },
  //             dataType: 'json',
  //             success: function(response) {
  //                 $('#newCategoryName').val('');
  //                 loadCategories();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error adding category:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error adding the category',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }  

  // function deleteCategory(categoryId) {
  //     if (confirm('Are you sure you want to delete this category?')) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=deleteCategory',
  //             method: 'POST',
  //             data: { id: categoryId },
  //             dataType: 'json',
  //             success: function(response) {
  //                 loadCategories();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error deleting category:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error deleting the category',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }  

  // function loadMealTypes() {
  //   $.ajax({
  //       url: 'api/inventory.cfc?method=loadMealTypes',
  //       method: 'GET',
  //       dataType: 'json',
  //       success: function(response) {
  //           const mealTypesList = $('#mealTypesList');
  //           mealTypesList.empty();
  //           response.DATA.forEach(category => {
  //               mealTypesList.append(`
  //                   <li class="list-group-item d-flex justify-content-between align-items-center">
  //                       ${category[1]}
  //                       <button class="btn btn-sm btn-danger delete-mealType" data-id="${category[0]}">Delete</button>
  //                   </li>
  //               `);
  //           });
  //       },
  //       error: function(xhr, status, error) {
  //           // console.error('Error fetching loadMealTypes:', error);
  //           Swal.fire({
  //               title: 'Error!',
  //               text: 'Error fetching loadMealTypes',
  //               icon: 'error',
  //               confirmButtonText: 'OK'
  //           });
  //       }
  //   });
  // }

  // function addMealType() {
  //     const newMealTypeName = $('#newMealTypeName').val().trim();
  //     if (newMealTypeName) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=addMealType',
  //             method: 'POST',
  //             data: { name: newMealTypeName },
  //             dataType: 'json',
  //             success: function(response) {
  //                 $('#newMealTypeName').val('');
  //                 loadMealTypes();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error adding MealType:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error adding the MealType',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }

  // function deleteMealType(MealTypeId) {
  //     if (confirm('Are you sure you want to delete this MealType?')) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=deleteMealType',
  //             method: 'POST',
  //             data: { id: MealTypeId },
  //             dataType: 'json',
  //             success: function(response) {
  //                 loadMealTypes();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error deleting MealType:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error deleting the MealType',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }

  // function loadQuantityOptions() {
  //   $.ajax({
  //       url: 'api/inventory.cfc?method=loadQuantityOptions',
  //       method: 'GET',
  //       dataType: 'json',
  //       success: function(response) {
  //           const quantityOptionsList = $('#quantityOptionsList');
  //           quantityOptionsList.empty();
  //           response.DATA.forEach(option => {
  //               quantityOptionsList.append(`
  //                   <li class="list-group-item d-flex justify-content-between align-items-center">
  //                       ${option[1]}
  //                       <button class="btn btn-sm btn-danger delete-quantityOptions" data-id="${option[0]}">Delete</button>
  //                   </li>
  //               `);
  //           });
  //       },
  //       error: function(xhr, status, error) {
  //           // console.error('Error fetching loadQuantityOptions:', error);
  //           Swal.fire({
  //               title: 'Error!',
  //               text: 'Error fetching Quantity Options',
  //               icon: 'error',
  //               confirmButtonText: 'OK'
  //           });
  //       }
  //   });
  // }

  // function addquantityOptions() {
  //     const newquantityOptionsName = $('#newquantityOptionsName').val().trim();
  //     if (newquantityOptionsName) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=addquantityOptions',
  //             method: 'POST',
  //             data: { name: newquantityOptionsName },
  //             dataType: 'json',
  //             success: function(response) {
  //                 $('#newquantityOptionsName').val('');
  //                 loadQuantityOptions();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error adding quantityOptions:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error adding the quantityOptions',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }

  // function deletequantityOptions(quantityOptionsId) {
  //     if (confirm('Are you sure you want to delete this quantityOptions?')) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=deletequantityOptions',
  //             method: 'POST',
  //             data: { id: quantityOptionsId },
  //             dataType: 'json',
  //             success: function(response) {
  //                 loadQuantityOptions();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error deleting quantityOptions:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error deleting the quantityOptions',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }

  // function loaduomOptions() {
  //   $.ajax({
  //       url: 'api/inventory.cfc?method=loaduomOptions',
  //       method: 'GET',
  //       dataType: 'json',
  //       success: function(response) {
  //           const uomOptionsList = $('#uomOptionsList');
  //           uomOptionsList.empty();
  //           response.DATA.forEach(option => {
  //               uomOptionsList.append(`
  //                   <li class="list-group-item d-flex justify-content-between align-items-center">
  //                       ${option[1]}
  //                       <button class="btn btn-sm btn-danger delete-uomOptions" data-id="${option[0]}">Delete</button>
  //                   </li>
  //               `);
  //           });
  //       },
  //       error: function(xhr, status, error) {
  //           // console.error('Error fetching loaduomOptions:', error);
  //           Swal.fire({
  //               title: 'Error!',
  //               text: 'Error fetching uom Options',
  //               icon: 'error',
  //               confirmButtonText: 'OK'
  //           });
  //       }
  //   });
  // }

  // function adduomOptions() {
  //     const newuomOptionsName = $('#newuomOptionsName').val().trim();
  //     if (newuomOptionsName) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=adduomOptions',
  //             method: 'POST',
  //             data: { name: newuomOptionsName },
  //             dataType: 'json',
  //             success: function(response) {
  //                 $('#newuomOptionsName').val('');
  //                 loaduomOptions();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error adding uomOptions:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error adding the uomOptions',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }

  // function deleteuomOptions(uomOptionsId) {
  //     if (confirm('Are you sure you want to delete this uomOptions?')) {
  //         $.ajax({
  //             url: 'api/inventory.cfc?method=deleteuomOptions',
  //             method: 'POST',
  //             data: { id: uomOptionsId },
  //             dataType: 'json',
  //             success: function(response) {
  //                 loaduomOptions();
  //             },
  //             error: function(xhr, status, error) {
  //                 // console.error('Error deleting uomOptions:', error);
  //                 Swal.fire({
  //                     title: 'Error!',
  //                     text: 'Error deleting the uomOptions',
  //                     icon: 'error',
  //                     confirmButtonText: 'OK'
  //                 });
  //             }
  //         });
  //     }
  // }


  // Initial load
  loadInventory();

  // Additional event handlers (e.g., for editing items) can be added here
});