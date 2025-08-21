<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dropdown Options Management</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- DataTables CSS -->
    <link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .color-preview {
            display: inline-block;
            width: 24px;
            height: 24px;
            border-radius: 4px;
            margin-right: 8px;
            vertical-align: middle;
            border: 1px solid #ddd;
        }
        .nav-tabs .nav-link.active {
            font-weight: bold;
        }
        .table-container {
            margin-top: 20px;
        }
        .action-buttons .btn {
            margin-right: 5px;
        }
        .select2-container {
            width: 100% !important;
        }
    </style>
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
                    Categories
                </button>

                <a href="manageoptions.cfm" class="btn btn-outline-primary">Manage Options</a>
                
                <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#manageTagsModal">
                    Tags
                </button>

                <a href="reviewrecipes.htm" class="btn btn-outline-primary">Review Recipes</a>
                <a href="/" class="btn btn-outline-primary">Meal Planner</a>
            </div>
        </div>


        <div class="container-fluid py-4">
            <h1 class="mb-4">Dropdown Options Management</h1>
            
            <!-- Navigation Tabs -->
            <ul class="nav nav-tabs" id="optionsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="meals-tab" data-bs-toggle="tab" data-bs-target="#meals" type="button" role="tab">
						Meal Types
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="units-tab" data-bs-toggle="tab" data-bs-target="#units" type="button" role="tab">
						Measurement Units
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="quantities-tab" data-bs-toggle="tab" data-bs-target="#quantities" type="button" role="tab">
						Quantity Options
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="tags-tab" data-bs-toggle="tab" data-bs-target="#tags" type="button" role="tab">
						Tags
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="tags-tab" data-bs-toggle="tab" data-bs-target="#categories" type="button" role="tab">
						Categories
                    </button>
                </li>
            </ul>
            
            <!-- Tab Content -->
            <div class="tab-content" id="optionsTabContent">
                <!-- Measurement Units Tab -->
                <div class="tab-pane fade " id="units" role="tabpanel">
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <h3>Measurement Units</h3>
                        <button class="btn btn-primary" id="addUnitBtn">
                            <i class="fas fa-plus"></i> Add Unit
                        </button>
                    </div>
                    <div class="table-container">
                        <table id="unitsTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Unit Name</th>
                                    <th>Base Unit</th>
                                    <th>Unit Type</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Meal Types Tab -->
                <div class="tab-pane fade show active" id="meals" role="tabpanel">
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <h3>Meal Types</h3>
                        <button class="btn btn-primary" id="addMealBtn">
                            <i class="fas fa-plus"></i> Add Meal Type
                        </button>
                    </div>
                    <div class="table-container">
                        <table id="mealsTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Type Name</th>
                                    <th>Color</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Quantity Options Tab -->
                <div class="tab-pane fade" id="quantities" role="tabpanel">
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <h3>Quantity Options</h3>
                        <button class="btn btn-primary" id="addQuantityBtn">
                            <i class="fas fa-plus"></i> Add Quantity
                        </button>
                    </div>
                    <div class="table-container">
                        <table id="quantitiesTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Option Value</th>
                                    <th>Text Value</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Tags Tab -->
                <div class="tab-pane fade" id="tags" role="tabpanel">
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <h3>Tags</h3>
                        <button class="btn btn-primary" id="addTagBtn">
                            <i class="fas fa-plus"></i> Add Tag
                        </button>
                    </div>
                    <div class="table-container">
                        <table id="tagsTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Color</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>

                <!-- Categories Tab -->
                <div class="tab-pane fade" id="categories" role="tabpanel">
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <h3>Categories</h3>
                        <button class="btn btn-primary" id="addTagBtn">
                            <i class="fas fa-plus"></i> Add Category
                        </button>
                    </div>
                    <div class="table-container">
                        <table id="categoriesTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Description</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>
    
    <!-- Modals -->
    <!-- Measurement Unit Modal -->
    <div class="modal fade" id="unitModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="unitModalTitle">Add Measurement Unit</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="unitForm">
                        <input type="hidden" id="unitId">
                        <div class="mb-3">
                            <label for="unitName" class="form-label">Unit Name</label>
                            <input type="text" class="form-control" id="unitName" required>
                        </div>
                        <div class="mb-3">
                            <label for="baseUnit" class="form-label">Base Unit</label>
                            <input type="text" class="form-control" id="baseUnit" required>
                        </div>
                        <div class="mb-3">
                            <label for="unitType" class="form-label">Unit Type</label>
                            <select class="form-select" id="unitType" required>
                                <option value="volume">Volume</option>
                                <option value="weight">Weight</option>
                                <option value="length">Length</option>
                                <option value="count">Count</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveUnitBtn">Save</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Meal Type Modal -->
    <div class="modal fade" id="mealModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="mealModalTitle">Add Meal Type</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="mealForm">
                        <input type="hidden" id="mealId">
                        <div class="mb-3">
                            <label for="mealName" class="form-label">Type Name</label>
                            <input type="text" class="form-control" id="mealName" required>
                        </div>
                        <div class="mb-3">
                            <label for="mealColor" class="form-label">Color</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <div id="mealColorPreview" class="color-preview"></div>
                                </span>
                                <input type="color" class="form-control form-control-color" id="mealColor" value="#563d7c">
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveMealBtn">Save</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Quantity Option Modal -->
    <div class="modal fade" id="quantityModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="quantityModalTitle">Add Quantity Option</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="quantityForm">
                        <input type="hidden" id="quantityId">
                        <div class="mb-3">
                            <label for="optionValue" class="form-label">Option Value</label>
                            <input type="number" class="form-control" id="optionValue" step="0.001" min="0" max="9.999" required>
                            <div class="form-text">Decimal value (max 4 digits with 3 decimal places)</div>
                        </div>
                        <div class="mb-3">
                            <label for="textValue" class="form-label">Text Value</label>
                            <input type="text" class="form-control" id="textValue" maxlength="10" required>
                            <div class="form-text">Display text (max 10 characters)</div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveQuantityBtn">Save</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Tag Modal -->
    <div class="modal fade" id="tagModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="tagModalTitle">Add Tag</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="tagForm">
                        <input type="hidden" id="tagId">
                        <div class="mb-3">
                            <label for="tagName" class="form-label">Tag Name</label>
                            <input type="text" class="form-control" id="tagName" maxlength="100" required>
                        </div>
                        <div class="mb-3">
                            <label for="tagColor" class="form-label">Color</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <div id="tagColorPreview" class="color-preview"></div>
                                </span>
                                <input type="color" class="form-control form-control-color" id="tagColor" value="#28a745">
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveTagBtn">Save</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirm Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this item? This action cannot be undone.</p>
                    <input type="hidden" id="deleteItemId">
                    <input type="hidden" id="deleteItemType">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
                </div>
            </div>
        </div>
    </div>

<!-- Toast Notifications -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3">
        <div id="notificationToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="toast-header">
                <strong class="me-auto" id="toastTitle">Notification</strong>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body" id="toastMessage">
                Operation completed successfully.
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <!-- Bootstrap 5 JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <!-- Select2 -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    
    <script>
        $(document).ready(function() {
            // Initialize DataTables
            const unitsTable = $('#unitsTable').DataTable({
                ajax: {
                    url: '/api/mealplanner.cfc?method=measurementunits',
                    dataSrc: ''
                },
                columns: [
                    { data: 'unitID' },
                    { data: 'name' },
                    { data: 'baseUnit' },
                    { data: 'unitType' },
                    {
                        data: null,
                        render: function(data) {
                            return `
                                <div class="action-buttons">
                                    <button class="btn btn-sm btn-primary edit-unit" data-id="${data.unitID}">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-danger delete-unit" data-id="${data.unitID}">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            `;
                        }
                    }
                ],
                responsive: true
            });
            
            const mealsTable = $('#mealsTable').DataTable({
                ajax: {
                    url: '/api/mealplanner.cfc?method=mealtypes',
                    dataSrc: ''
                },
                columns: [
                    { data: 'mealTypeID' },
                    { data: 'mealTypeName' },
                    { 
                        data: 'mealTypeColor',
                        render: function(data) {
                            return `<div class="d-flex align-items-center">
                                <div class="color-preview" style="background-color: ${data}"></div>
                                ${data}
                            </div>`;
                        }
                    },
                    {
                        data: null,
                        render: function(data) {
                            return `
                                <div class="action-buttons">
                                    <button class="btn btn-sm btn-primary edit-meal" data-id="${data.mealTypeID}">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-danger delete-meal" data-id="${data.mealTypeID}">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            `;
                        }
                    }
                ],
                responsive: true
            });
            
            const quantitiesTable = $('#quantitiesTable').DataTable({
                ajax: {
                    url: '/api/mealplanner.cfc?method=quantity_options',
                    dataSrc: ''
                },
                columns: [
                    { data: 'id' },
                    { data: 'optionValue' },
                    { data: 'textValue' },
                    {
                        data: null,
                        render: function(data) {
                            return `
                                <div class="action-buttons">
                                    <button class="btn btn-sm btn-primary edit-quantity" data-id="${data.id}">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-danger delete-quantity" data-id="${data.id}">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            `;
                        }
                    }
                ],
                responsive: true
            });
            
            const tagsTable = $('#tagsTable').DataTable({
                ajax: {
                    url: '/api/mealplanner.cfc?method=tags',
                    dataSrc: ''
                },
                columns: [
                    { data: 'tag_id' },
                    { data: 'name' },
                    { 
                        data: 'color',
                        render: function(data) {
                            return data ? `<div class="d-flex align-items-center">
                                <div class="color-preview" style="background-color: ${data}"></div>
                                ${data}
                            </div>` : '';
                        }
                    },
                    {
                        data: null,
                        render: function(data) {
                            return `
                                <div class="action-buttons">
                                    <button class="btn btn-sm btn-primary edit-tag" data-id="${data.tag_id}">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-danger delete-tag" data-id="${data.tag_id}">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            `;
                        }
                    }
                ],
                responsive: true
            });

            // const categoriesTable2 = $('#categoriesTable').DataTable({
			//     ajax: {
			//         url: '/api/mealplanner.cfc?method=categories',
			//         dataSrc: ''
			//     },
            //     responsive: true
			// });


            const categoriesTable = $('#categoriesTable').DataTable({
                ajax: {
                    url: '/api/mealplanner.cfc?method=categories',
                    dataSrc: ''
                },
                columns: [
				    { data: 'id' },
				    { data: 'catname' },
				    { data: 'description' },
				    {
				        data: null,
				        render: function(data, type, row, meta) {
				            // Using row instead of data to ensure we have the full row data
				            return `
				                <div class="action-buttons">
				                    <button class="btn btn-sm btn-primary edit-tag" data-id="${row.id}">
				                        <i class="fas fa-edit"></i>
				                    </button>
				                    <button class="btn btn-sm btn-danger delete-tag" data-id="${row.id}">
				                        <i class="fas fa-trash"></i>
				                    </button>
				                </div>
				            `;
				        }
				    }
				],
                responsive: true
            });            
            
            // Initialize Select2
            $('.form-select').select2({
                theme: 'bootstrap-5'
            });
            
            // Color picker preview updates
            $('#mealColor').on('input', function() {
                $('#mealColorPreview').css('background-color', $(this).val());
            });
            
            $('#tagColor').on('input', function() {
                $('#tagColorPreview').css('background-color', $(this).val());
            });
            
            // Show notification toast
            function showNotification(title, message, type = 'success') {
                $('#toastTitle').text(title);
                $('#toastMessage').text(message);
                
                const toast = $('#notificationToast');
                toast.removeClass('bg-success bg-danger bg-warning');
                
                if (type === 'success') {
                    toast.addClass('bg-success text-white');
                } else if (type === 'error') {
                    toast.addClass('bg-danger text-white');
                } else if (type === 'warning') {
                    toast.addClass('bg-warning');
                }
                
                const bsToast = new bootstrap.Toast(toast);
                bsToast.show();
            }
            
            // MEASUREMENT UNITS CRUD
            
            // Add Unit
            $('#addUnitBtn').on('click', function() {
                $('#unitModalTitle').text('Add Measurement Unit');
                $('#unitForm')[0].reset();
                $('#unitId').val('');
                $('#unitModal').modal('show');
            });
            
            // Edit Unit
            $(document).on('click', '.edit-unit', function() {
                const id = $(this).data('id');
                
                $.ajax({
                    url: `api/measurementunits/${id}`,
                    method: 'GET',
                    success: function(data) {
                        $('#unitModalTitle').text('Edit Measurement Unit');
                        $('#unitId').val(data.id);
                        $('#unitName').val(data.unit_name);
                        $('#baseUnit').val(data.base_unit);
                        $('#unitType').val(data.unit_type).trigger('change');
                        $('#unitModal').modal('show');
                    },
                    error: function() {
                        showNotification('Error', 'Failed to load unit data', 'error');
                    }
                });
            });
            
            // Save Unit
            $('#saveUnitBtn').on('click', function() {
                if (!$('#unitForm')[0].checkValidity()) {
                    $('#unitForm')[0].reportValidity();
                    return;
                }
                
                const id = $('#unitId').val();
                const unitData = {
                    unit_name: $('#unitName').val(),
                    base_unit: $('#baseUnit').val(),
                    unit_type: $('#unitType').val()
                };
                
                const method = id ? 'PUT' : 'POST';
                const url = id ? `api/measurementunits/${id}` : 'api/measurementunits';
                
                $.ajax({
                    url: url,
                    method: method,
                    contentType: 'application/json',
                    data: JSON.stringify(unitData),
                    success: function() {
                        $('#unitModal').modal('hide');
                        unitsTable.ajax.reload();
                        showNotification('Success', `Measurement unit ${id ? 'updated' : 'added'} successfully`);
                    },
                    error: function() {
                        showNotification('Error', `Failed to ${id ? 'update' : 'add'} measurement unit`, 'error');
                    }
                });
            });
            
            // Delete Unit
            $(document).on('click', '.delete-unit', function() {
                const id = $(this).data('id');
                $('#deleteItemId').val(id);
                $('#deleteItemType').val('unit');
                $('#deleteModal').modal('show');
            });
            
            // MEAL TYPES CRUD
            
            // Add Meal Type
            $('#addMealBtn').on('click', function() {
                $('#mealModalTitle').text('Add Meal Type');
                $('#mealForm')[0].reset();
                $('#mealId').val('');
                $('#mealColorPreview').css('background-color', $('#mealColor').val());
                $('#mealModal').modal('show');
            });
            
            // Edit Meal Type
            $(document).on('click', '.edit-meal', function() {
                const id = $(this).data('id');
                
                $.ajax({
                    url: `api/mealtype/${id}`,
                    method: 'GET',
                    success: function(data) {
                        $('#mealModalTitle').text('Edit Meal Type');
                        $('#mealId').val(data.typeID);
                        $('#mealName').val(data.typeName);
                        $('#mealColor').val(data.typeColor || '#563d7c');
                        $('#mealColorPreview').css('background-color', data.typeColor || '#563d7c');
                        $('#mealModal').modal('show');
                    },
                    error: function() {
                        showNotification('Error', 'Failed to load meal type data', 'error');
                    }
                });
            });
            
            // Save Meal Type
            $('#saveMealBtn').on('click', function() {
                if (!$('#mealForm')[0].checkValidity()) {
                    $('#mealForm')[0].reportValidity();
                    return;
                }
                
                const id = $('#mealId').val();
                const mealData = {
                    typeName: $('#mealName').val(),
                    typeColor: $('#mealColor').val()
                };
                
                const method = id ? 'PUT' : 'POST';
                const url = id ? `api/mealtype/${id}` : 'api/mealtype';
                
                $.ajax({
                    url: url,
                    method: method,
                    contentType: 'application/json',
                    data: JSON.stringify(mealData),
                    success: function() {
                        $('#mealModal').modal('hide');
                        mealsTable.ajax.reload();
                        showNotification('Success', `Meal type ${id ? 'updated' : 'added'} successfully`);
                    },
                    error: function() {
                        showNotification('Error', `Failed to ${id ? 'update' : 'add'} meal type`, 'error');
                    }
                });
            });
            
            // Delete Meal Type
            $(document).on('click', '.delete-meal', function() {
                const id = $(this).data('id');
                $('#deleteItemId').val(id);
                $('#deleteItemType').val('meal');
                $('#deleteModal').modal('show');
            });
            
            // QUANTITY OPTIONS CRUD
            
            // Add Quantity Option
            $('#addQuantityBtn').on('click', function() {
                $('#quantityModalTitle').text('Add Quantity Option');
                $('#quantityForm')[0].reset();
                $('#quantityId').val('');
                $('#quantityModal').modal('show');
            });
            
            // Edit Quantity Option
            $(document).on('click', '.edit-quantity', function() {
                const id = $(this).data('id');
                
                $.ajax({
                    url: `api/quantity_options/${id}`,
                    method: 'GET',
                    success: function(data) {
                        $('#quantityModalTitle').text('Edit Quantity Option');
                        $('#quantityId').val(data.id);
                        $('#optionValue').val(data.optionValue);
                        $('#textValue').val(data.textValue);
                        $('#quantityModal').modal('show');
                    },
                    error: function() {
                        showNotification('Error', 'Failed to load quantity option data', 'error');
                    }
                });
            });
            
            // Save Quantity Option
            $('#saveQuantityBtn').on('click', function() {
                if (!$('#quantityForm')[0].checkValidity()) {
                    $('#quantityForm')[0].reportValidity();
                    return;
                }
                
                const id = $('#quantityId').val();
                const quantityData = {
                    optionValue: parseFloat($('#optionValue').val()),
                    textValue: $('#textValue').val()
                };
                
                const method = id ? 'PUT' : 'POST';
                const url = id ? `api/quantity_options/${id}` : 'api/quantity_options';
                
                $.ajax({
                    url: url,
                    method: method,
                    contentType: 'application/json',
                    data: JSON.stringify(quantityData),
                    success: function() {
                        $('#quantityModal').modal('hide');
                        quantitiesTable.ajax.reload();
                        showNotification('Success', `Quantity option ${id ? 'updated' : 'added'} successfully`);
                    },
                    error: function() {
                        showNotification('Error', `Failed to ${id ? 'update' : 'add'} quantity option`, 'error');
                    }
                });
            });
            
            // Delete Quantity Option
            $(document).on('click', '.delete-quantity', function() {
                const id = $(this).data('id');
                $('#deleteItemId').val(id);
                $('#deleteItemType').val('quantity');
                $('#deleteModal').modal('show');
            });
            
            // TAGS CRUD
            
            // Add Tag
            $('#addTagBtn').on('click', function() {
                $('#tagModalTitle').text('Add Tag');
                $('#tagForm')[0].reset();
                $('#tagId').val('');
                $('#tagColorPreview').css('background-color', $('#tagColor').val());
                $('#tagModal').modal('show');
            });
            
            // Edit Tag
    });
</script>