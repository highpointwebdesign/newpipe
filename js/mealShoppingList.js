$(document).ready(function() {
    loadShoppingList();
});

$(document).on('change', '.item-checkbox', function() {
    const itemId = $(this).data('id');
    const isChecked = $(this).prop('checked');
    const quantityToBuy = $(this).data('quantity');
    updateInventoryAndShoppingList(itemId, isChecked, quantityToBuy);
});

function updateInventoryAndShoppingList(itemId, isChecked, quantityToBuy) {
    $.ajax({
        url: 'api/inventory.cfc?method=updateInventoryFromShoppingList',
        method: 'POST',
        data: {
            itemId: itemId,
            isChecked: isChecked,
            quantityToBuy: quantityToBuy
        },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                console.log('Inventory updated successfully');
                // Update the UI to reflect the change
                updateShoppingListUI(itemId, isChecked);
                updateUIQuantity(itemId, response.newQuantity)
            } else {
                console.error('Error updating inventory:', response.message);
                // Revert the checkbox state if the update failed
                $('.item-checkbox[data-id="' + itemId + '"]').prop('checked', !isChecked);
            }
        },
        error: function(xhr, status, error) {
            console.error('Error updating inventory:', error);
            // Revert the checkbox state if the update failed
            $('.item-checkbox[data-id="' + itemId + '"]').prop('checked', !isChecked);
        }
    });
}

function updateShoppingListUI(itemId, isChecked) {
    const listItem = $('.item-checkbox[data-id="' + itemId + '"]').closest('li');
    if (isChecked) {
        listItem.addClass('completed');
    } else {
        listItem.removeClass('completed');
    }
}

function updateUIQuantity(itemId, newQuantity) {
    $(`#item-${itemId}`).closest('.list-group-item').find('.text-muted').text(`Inventory: ${newQuantity}`);
}

function loadShoppingList() {
    $.ajax({
        url: 'api/inventory.cfc?method=getShoppingList',
        method: 'GET',
        dataType: 'json',
        success: function(response) {
            const shoppingListContainer = $('#shoppingList');
            shoppingListContainer.empty();

            let currentCategory = '';
            let categoryList = null;

            response.DATA.forEach((item, index) => {
                const category = item[0];
                const itemId = item[1];
                const itemName = item[2];
                const current_quantity = item[4];
                const quantityToBuy = item[5];

                if (category !== currentCategory) {
                    currentCategory = category;
                    shoppingListContainer.append(`<h2>${category}</h2>`);
                    categoryList = $('<ul class="list-group mb-3"></ul>');
                    shoppingListContainer.append(categoryList);
                }

                const listItem = $(`
                    <li class="list-group-item">
                        <div class="form-check d-flex justify-content-between align-items-center">
                            <div>
                                <input class="form-check-input item-checkbox" type="checkbox" id="item-${itemId}" data-id="${itemId}" data-quantity="${quantityToBuy}">
                                <label class="form-check-label" for="item-${itemId}">
                                    ${itemName} (${quantityToBuy})
                                </label>
                            </div>
                            <span class="text-muted">
                                Inventory: ${current_quantity}
                            </span>
                        </div>
                    </li>
                `);

                categoryList.append(listItem);
            });

            // Add event listener for checkboxes
            $('.form-check-input').on('change', function() {
                $(this).closest('.list-group-item').toggleClass('completed', this.checked);
            });
        },
        error: function(xhr, status, error) {
            console.error('Error fetching shopping list:', error);
        }
    });
}