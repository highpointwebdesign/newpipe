<cfquery name="mealTypes" datasource="sg">
Select
    mt.mealTypeID,
    mt.mealTypeName,
    mt.mealTypeColor,
    m.mealID,
    m.title,
    m.servings,
    m.mealTypeID As mealTypeID1
From
    meal_types mt Left Join
    meals m On mt.mealTypeID = m.mealTypeID
Order By
    mt.orderby, m.title
</cfquery>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Meal Planner</title>
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" />
  <!-- jQuery UI (Required for Draggable functionality) -->
  <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/smoothness/jquery-ui.css">

  <!-- FullCalendar CSS -->
  <link href="css/full_calendar_main.css?verion=1" rel="stylesheet">
  <link href="css/styles.css?verion=1" rel="stylesheet">
  <!-- FullCalendar JS -->
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.17/index.global.min.js"></script>
  
  <!-- Google OAuth Client Library -->
  <script src="https://accounts.google.com/gsi/client" async defer></script>


  <!-- keen theme scroll plug in -->
  <link href="vendor/keen/css/style.bundle.css" rel="stylesheet" type="text/css"/>
  
  <link href="css/styles.css?verion=1" rel="stylesheet">
  <link href="css/mealplanner.css" rel="stylesheet" type="text/css"/>

</head>
<body data-typography="roboto" data-theme-version="light" data-layout="horizontal">
  <!-- Login Prompt -->
  <div id="login-prompt">
    <h2>Please log in to access your calendar</h2>
    <button id="login-button" class="btn btn-primary">Login with Google</button>
  </div>
  
  <!-- Main content: Hidden until login is successful -->
  <div id="main-wrapper">

    <!--**********************************  Sidebar start ***********************************-->
          <div class="dlabnav">
            <div class="dlabnav-scroll">
                <ul class="metismenu" id="menu">
                  <li><a href="/">RV MEAL PLANNER</a></li>
                  <li><a class="nav-link" href="/" id="menu-recipes">MEAL CARDS</a></li>
                  <li><a class="nav-link" href="calendar.cfm" id="menu-calendar">MEAL PLANNER</a></li>
                  <li><a class="nav-link" href="mealplannershoppinglist.htm" id="menu-shopping_list">SHOPPING LIST</a></li>
                  <li><a class="nav-link" href="inventoryMgmt.htm" id="menu-shopping_list">INVENTORY MGMT (Beta)</a></li>
                  <li><a class="nav-link" href="javascript:;" id="logout-button">LOGOUT</a></li>                
                </ul>
            </div>
          </div>
    <!--********************************** Sidebar end ***********************************-->

    <!--********************************** Content body start ***********************************-->
        <div class="content-body" style="margin:0px !important">
            <div class="container-fluid">
    
              <div class="row">
                <div class="col-sm-3">
                  <div class="card">
                    <div class="card-body">
                      <h4 class="card-intro-title">MEALS</h4>
                      <!-- <div class=""> -->
                        
                        <div id="accordion-four" class="accordion accordion-no-gutter">
                          <cfoutput query="mealTypes" group="mealtypeID">
                            <div class="accordion__item" >
                                <div class="accordion__header collapsed" data-bs-toggle="collapse" data-bs-target="##bordered_no-gutter_collapse#mealTypes.mealTypeID#" style="background-color: #mealTypes.mealTypeColor#; color: ##ffffff;">
                                <span class="accordion__header--text">#mealTypes.mealTypeName#</span>
                                    <span class="accordion__header--indicator style_two"></span>
                                </div>

                                <div id="bordered_no-gutter_collapse#mealTypes.mealTypeID#" class="collapse accordion__body" data-bs-parent="##accordion-four" style="background-color: ##ffffff;">  
                                  <div class="accordion__body--text">                                        
                                    <div class="hover-scroll h-300px">                                        
                                      <cfoutput>
                                        <div
                                            data-meal-mealid="#mealTypes.mealID#"
                                            data-mealtypeid="#mealTypes.mealTypeID#"
                                            data-servings="#mealTypes.servings#"
                                            data-meal-color="#mealTypes.mealTypeColor#"
                                            class="external-event fc-event"
                                            style="background-color: #mealTypes.mealTypeColor#; color: white;"
                                        >
                                            <i class="fa fa-move"></i> #mealTypes.title#
                                        </div>
                                      </cfoutput>
                                    </div>
                                  </div>
                                </div>
                            </div>
                          </cfoutput>
                        </div>

                      <!-- </div> -->
                    </div>
                  </div>
                </div>

                <div class="col-sm-9">
                  <!-- <div id="calendar" class="app-fullcalendar fc fc-media-screen fc-theme-standard" ></div> -->

                     
                        <div class="card">
                            <div class="card-body">
                                <div id="calendar" class="app-fullcalendar"></div>
                            </div>
                        </div>
                    
                  
                </div>
              </div>

            </div>    
        </div>
    </div>

  
  <!-- jQuery, Bootstrap, and SweetAlert2 Scripts -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

  
  <script src="js/mealplanner.js"></script>
</body>
</html>
