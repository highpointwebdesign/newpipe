<!--- meal_types.cfm --->
<!--- meal_types_manager.cfm --->
<cfif structKeyExists(form, "action") AND form.action EQ "updateOrder">
    <cfset orderData = deserializeJSON(form.orderData)>
    
    <cftransaction>
        <cfloop array="#orderData#" index="item">
            <cfquery datasource="sg">
                UPDATE meal_types
                SET orderby = <cfqueryparam value="#item.order#" cfsqltype="cf_sql_integer">
                WHERE mealTypeID = <cfqueryparam value="#item.id#" cfsqltype="cf_sql_integer">
            </cfquery>
        </cfloop>
    </cftransaction>
    
    <cfoutput>{"status": "success", "message": "Order updated successfully"}</cfoutput>
    <cfabort>
</cfif>

<!--- Get meal types ordered by the orderby field --->
<cfquery name="getMealTypes" datasource="sg">
    SELECT mealTypeID, mealTypeName, mealTypeColor, orderby
    FROM meal_types
    ORDER BY orderby ASC, mealTypeName ASC
</cfquery>
<!--- meal_types.cfm --->


<!DOCTYPE html>
<html>
<head>
    <title>Meal Types Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.13.2/themes/base/jquery-ui.min.css" rel="stylesheet">
    <style>
        .meal-type-item {
            padding: 10px 15px;
            margin-bottom: 5px;
            border-radius: 4px;
            cursor: move;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .meal-type-item:hover {
            opacity: 0.9;
        }
        .color-preview {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 10px;
        }
        .ui-sortable-helper {
            box-shadow: 0 5px 10px rgba(0,0,0,0.2);
        }
        .ui-sortable-placeholder {
            visibility: visible !important;
            background-color: #f9f9f9;
            border: 1px dashed #ccc;
            height: 45px;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4>Manage Meal Types</h4>
                        <button id="saveOrder" class="btn btn-primary">Save Order</button>
                    </div>
                    <div class="card-body">
                        <div id="orderMessage" class="alert" style="display: none;"></div>
                        
                        <ul id="mealTypesList" class="list-unstyled">
                            <cfoutput query="getMealTypes">
                                <li class="meal-type-item" data-id="#mealTypeID#" style="background-color: ##f8f9fa;">
                                    <div>
                                        <span class="color-preview" style="background-color: #mealTypeColor#;"></span>
                                        <span class="meal-name">#mealTypeName#</span>
                                    </div>
                                    <div class="handle">
                                        <i class="bi bi-grip-vertical"></i>
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-grip-vertical" viewBox="0 0 16 16">
                                            <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 11a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 14a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z"/>
                                        </svg>
                                    </div>
                                </li>
                            </cfoutput>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        $(document).ready(function() {
            // Initialize sortable
            $("#mealTypesList").sortable({
                handle: ".handle",
                placeholder: "ui-sortable-placeholder",
                update: function(event, ui) {
                    // Enable save button when order changes
                    $("#saveOrder").removeClass("btn-primary").addClass("btn-success").text("Save Changes");
                }
            });
            
            // Save order button click
            $("#saveOrder").click(function() {
                const button = $(this);
                button.prop("disabled", true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...');
                
                // Collect the new order
                const orderData = [];
                $("#mealTypesList li").each(function(index) {
                    orderData.push({
                        id: $(this).data("id"),
                        order: index + 1
                    });
                });
                
                // Send to server
                $.ajax({
                    url: "meal_types_manager.cfm",
                    type: "POST",
                    data: {
                        action: "updateOrder",
                        orderData: JSON.stringify(orderData)
                    },
                    dataType: "json",
                    success: function(response) {
                        $("#orderMessage")
                            .removeClass("alert-danger")
                            .addClass("alert-success")
                            .text("Order updated successfully!")
                            .slideDown();
                            
                        button.removeClass("btn-success").addClass("btn-primary").text("Save Order");
                        
                        setTimeout(function() {
                            $("#orderMessage").slideUp();
                        }, 3000);
                    },
                    error: function() {
                        $("#orderMessage")
                            .removeClass("alert-success")
                            .addClass("alert-danger")
                            .text("Error updating order. Please try again.")
                            .slideDown();
                    },
                    complete: function() {
                        button.prop("disabled", false);
                    }
                });
            });
        });
    </script>
</body>
</html>