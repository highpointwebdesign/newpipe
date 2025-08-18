$(document).ready(function() {
  loadShoppingList();

  // Delegate a single change handler on all future .item-checkbox elements
  $('#shoppingList').on('change', '.item-checkbox', onCheckboxChange);
});

function loadShoppingList() {
  $.ajax({
    url: 'api/inventory.cfc?method=getShoppingList',
    method: 'GET',
    dataType: 'json'
  })
  .done(function(response) {
    const container = $('#shoppingList');
    container.empty();

    let currentCategory = '';
    let categoryList = null;

    response.DATA.forEach(item => {
      const [category, itemId, itemName, , currentQty, quantityToBuy] = item;

      if (category !== currentCategory) {
        currentCategory = category;
        container.append(`<h2>${category}</h2>`);
        categoryList = $('<ul class="list-group mb-3"></ul>');
        container.append(categoryList);
      }

      const listItem = $(`
        <li class="list-group-item">
          <div class="form-check d-flex justify-content-between align-items-center">
            <div>
              <input
                class="form-check-input item-checkbox"
                type="checkbox"
                id="item-${itemId}"
                data-id="${itemId}"
                data-quantity="${quantityToBuy}"
                data-current-quantity="${currentQty}"
              >
              <label class="form-check-label" for="item-${itemId}">
                ${itemName} (${quantityToBuy})
              </label>
            </div>
            <span class="text-muted">Inventory: ${currentQty}</span>
          </div>
        </li>
      `);

      categoryList.append(listItem);
    });
  })
  .fail(function(xhr, status, err) {
    console.error('Error loading shopping list:', err);
  });
}

function onCheckboxChange() {
  const $cb = $(this);
  const itemId       = $cb.data('id');
  const isChecked    = $cb.prop('checked');
  const quantityToBuy = parseInt($cb.data('quantity'), 10);

  // prevent rapid toggles
  $cb.prop('disabled', true);

  $.ajax({
    url: 'api/inventory.cfc?method=updateInventoryFromShoppingList',
    method: 'POST',
    data: {
      itemId:         itemId,
      isChecked:      isChecked,
      quantityToBuy:  quantityToBuy
    },
    dataType: 'json'
  })
  .done(function(response) {
    if (response.success) {
      // Refresh UI class + quantity display
      updateUI(itemId, isChecked, response.newQty);

      // Store the new "current" value for the next toggle
      $cb.data('current-quantity', response.newQty);
    } else {
      Swal.fire('Error', response.message, 'error');
      // rollback checkbox
      $cb.prop('checked', !isChecked);
    }
  })
  .fail(function(xhr, status, err) {
    Swal.fire('Error', 'Unable to update inventory. Please try again.', 'error');
    $cb.prop('checked', !isChecked);
  })
  .always(function() {
    $cb.prop('disabled', false);
  });
}

function updateUI(itemId, isChecked, newQty) {
  const $item = $(`#item-${itemId}`).closest('.list-group-item');

  // Toggle completed class
  $item.toggleClass('completed', isChecked);

  // Update the inventory display
  $item.find('.text-muted').text(`Inventory: ${newQty}`);
}
