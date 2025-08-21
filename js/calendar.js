
// Encapsulated in IIFE to avoid global scope pollution
(function() {
    // Configuration constants
    const CONFIG = {
        calendarId: "d13bc429760b3feaa0e8ca2f1b50ea9e9e25cf3a7d966e46120b09ccdff295ac@group.calendar.google.com",
        clientId: "766423868069-r6bs3kidv59orndc4icgfv4sus2k4o7e.apps.googleusercontent.com",
        scopes: "https://www.googleapis.com/auth/calendar.events"
    };

    // State variables
    let userAccessToken;
    let calendar; // Store calendar instance for later use

    // DOM Elements cache
    const elements = {
        loginPrompt: document.getElementById("login-prompt"),
        mainWrapper: document.getElementById("main-wrapper"),
        loginButton: document.getElementById("login-button"),
        logoutButton: document.getElementById("logout-button"),
        calendar: document.getElementById("calendar")
    };

    // Initialize authentication
    function initializeAuth() {
        google.accounts.oauth2.initTokenClient({
            client_id: CONFIG.clientId,
            scope: CONFIG.scopes,
            callback: handleAuthResponse
        }).requestAccessToken();
    }

    // Handle authentication response
    function handleAuthResponse(tokenResponse) {
        userAccessToken = tokenResponse.access_token;
        const expiresIn = tokenResponse.expires_in * 1000; // Convert to milliseconds
        const tokenExpiry = Date.now() + expiresIn;

        // Store in sessionStorage
        sessionStorage.setItem("userAccessToken", userAccessToken);
        sessionStorage.setItem("tokenExpiry", tokenExpiry.toString());

        // Update UI
        elements.loginPrompt.style.display = "none";
        elements.mainWrapper.style.opacity = 1;
        
        // initializeCalendar();
    }

    // Logout handler
    function logoutUser() {
        sessionStorage.removeItem("userAccessToken");
        sessionStorage.removeItem("tokenExpiry");
        userAccessToken = null;
        
        // Reset UI
        elements.mainWrapper.style.opacity = 0;
        elements.loginPrompt.style.display = "flex";
        
        console.log("User logged out successfully");
    }

    // Initialize calendar
    function initializeCalendar() {
        const Calendar = FullCalendar.Calendar;
        const Draggable = FullCalendar.Draggable;
        
        calendar = new Calendar(elements.calendar, {
            headerToolbar: {
                left: "prev,today,next",
                center: "title",
                right: ""
            },
            editable: true,
            droppable: true,
            eventDataTransform: transformEventData,
            eventReceive: handleEventReceive,
            eventDrop: handleEventDrop,
            eventContent: renderEventContent,
            eventDidMount: setupEventDelete
        });

        calendar.render();
        // loadExternalMeals();

        loadExistingEvents(calendar);
        initializeDraggables();
    }

    // may not need this any more
        // loadMealTypesData();

    // Global variable to store meal types data
    window.mealTypesData = [];

    /**
     * Fetches meal types data from the server and stores it in the global scope
     * @param {string} cfcPath - Path to the CFC file (e.g., "components/MealService.cfc")
     * @returns {Promise} - Promise that resolves when data is loaded
     */
    function loadMealTypesData() {
        return new Promise((resolve, reject) => {
            $.ajax({
                url: '/api/mealplanner.cfc',
                type: "GET",
                dataType: "json",
                data: {
                    method: "mealtypes", 
                    returnformat: "json"
                },
                success: function(response) {
                    // Store the data in the global scope
                    window.mealTypesData = response;
                    console.log("Meal types data loaded successfully:", window.mealTypesData);
                    resolve(window.mealTypesData);
                },
                error: function(xhr, status, error) {
                    console.error("Error loading meal types data:", error);
                    reject(error);
                }
            });
        });
    }


    // Transform event data for display
    function transformEventData(eventData) {
        
        if (!eventData?.extendedProps) return eventData;

        const mealTypeColor = eventData.extendedProps.mealTypeColor;

        eventData.color = mealTypeColor;
        return eventData;
    }

    // Handle new event drop
    function handleEventReceive(info) {
        console.log('info');
        console.log(info);
        const { mealId, servings, mealType, mealTypeColor } = info.event.extendedProps;
        
        if (!mealId) {
            console.error("Missing mealId");
            return;
        }
        else if (!servings){
            console.error("Missing servings");
            return;
        }
        else if (!mealType) {
            console.error("Missing mealType");
            return;
        }
        else if (!mealTypeColor) {
            console.error("Missing mealTypeColor");
            return;
        }

        const startDate = info.event.start;
        const numMeals = Math.ceil(servings / 2);
        const endDate = new Date(startDate);
        endDate.setDate(endDate.getDate() + numMeals);
        
        // Update the event's end date in the calendar UI
        info.event.setEnd(endDate);

        saveMealPlacement(
            mealId,
            startDate.toISOString().split("T")[0],
            endDate.toISOString().split("T")[0],
            info.event,
            servings,
            mealType,
            mealTypeColor
        );
    }

    // Handle event drag & drop
    function handleEventDrop(info) {
        const googleEventId = info.event.extendedProps.googleEventId;
        if (!googleEventId) return;

        const payload = {
            summary: info.event.title,
            start: { date: info.event.startStr },
            end: { date: info.event.endStr },
            extendedProperties: {
                private: {
                    mealType: info.event.extendedProps.mealType,
                    mealTypeColor: info.event.extendedProps.mealTypeColor,
                    mealId: info.event.extendedProps.mealId,
                    servings: info.event.extendedProps.servings
                }
            }
        };

        $.ajax({
            url: `https://www.googleapis.com/calendar/v3/calendars/${CONFIG.calendarId}/events/${googleEventId}`,
            method: "PATCH",
            headers: { Authorization: `Bearer ${userAccessToken}` },
            data: JSON.stringify(payload),
            contentType: "application/json",
            success: () => console.log("Event updated"),
            error: (err) => console.error("Update error:", err)
        });
    }

    // Render event content
    function renderEventContent(info) {
        return {
            html: `
                <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
                    <span class="meal-title" style="overflow: hidden; white-space: nowrap; text-overflow: ellipsis;">
                        ${info.event.title}
                    </span>
                    <span class="delete-event" style="color: white; margin-left: 5px; font-size: 1.2em;">X</span>
                </div>
            `
        };
    }

    // Setup event deletion
    function setupEventDelete(info) {
        $(info.el).on("click", ".delete-event", () => {
            Swal.fire({
                title: "Delete Meal?",
                text: "This will remove the meal from the calendar",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "Yes, delete it"
            }).then(result => {
                if (result.isConfirmed) {
                    deleteMealPlacement(info);
                    info.event.remove();
                }
            });
        });
    }

    // Load external meals
    function loadExternalMeals() {
    let attempts = 0; 

      // function makeAjaxRequest() {
      //     $.ajax({
      //         url: "api/mealplanner.cfc?method=getMeals",
      //         method: "GET",
      //         dataType: "json",
      //         success: meals => {
      //             const mealTypes = ["breakfast", "lunch", "dinner", "dessert"];
                  
      //             mealTypes.forEach(type => {
      //                 const filtered = meals.filter(meal => 
      //                     meal.mealTypeID.toLowerCase() === type
      //                 );
                      
      //                 const elements = filtered.map(meal => 
      //                     $(`<div class="external-events-${type}">`).append(`
      //                         <div 
      //                             data-meal-id="${meal.id}"
      //                             data-mealtype="${meal.mealTypeID}"
      //                             data-servings="${meal.servings}"
      //                             data-meal-color="${meal.typeColor}"
      //                             class="external-event fc-event"
      //                             style="background-color: ${meal.typeColor}; color: white;"
      //                         >
      //                             <i class="fa fa-move"></i>${meal.title}
      //                         </div>
      //                     `)
      //                 );
                      
      //                 $(`#external-events-${type}`).empty().append(elements);
      //                 initializeDraggable(type);
      //             });
      //         },
      //         error: (xhr, status, err) => {
      //       if (attempts === 0) {
      //         attempts++; 
      //         console.warn("Ajax call failed on first attempt, retrying...", err); 
      //         makeAjaxRequest(); // Retry once
      //       } else {
      //         console.error("Ajax call failed after retry:", err);
      //       }
      //      }
      //   });
      // } 
        function makeAjaxRequest() {
          return new Promise((resolve, reject) => {
            let attempts = 0;
            
            $.ajax({
              url: "/api/mealplanner.cfc",
              method: "GET",
              data: {
                method: "getMeals"
              },
              dataType: "json",
              success: function(response) {
                console.log(response.meals);
                
                // Access the separate datasets
                const meals = response.meals;
                // const mealTypes = response.mealTypes;
                
                // Use the data as needed
                populateMealTypesList(response);
                // populateIngredientsList(meals);
                
                resolve(response);
              },
              error: function(xhr, textStatus, errorThrown) {
                if (attempts === 0) {
                  attempts++;
                  console.warn("Ajax call failed on first attempt, retrying...", errorThrown);
                  makeAjaxRequest().then(resolve).catch(reject);
                } else {
                  reject(errorThrown);
                }
              }
            });
          });
        }
      makeAjaxRequest();
   }

   function populateMealTypesList(response) {
        console.log('populateMealTypesList')
        console.log(response.meals)
        const elements = filtered.map(meal => 
              $(`<div class="external-events-${type}">`).append(`
                  <div 
                      data-meal-mealid="${meal.mealID}"
                      data-mealtype="${meal.mealTypeID}"
                      data-servings="${meal.servings}"
                      data-mealtypecolor="${meal.mealTypeColor}"
                      class="external-event fc-event"
                      style="background-color: ${meal.mealTypeColor}; color: white;"
                  >
                      <i class="fa fa-move"></i>${meal.title} ${meal.mealTypeColor}
                  </div>
              `)
          );
      
        $(`#external-events-${type}`).empty().append(elements);
        // initializeDraggable(type);
   }

   // function populateIngredientsList(meals) {
   //  console.log('populateIngredientsList')
   //  console.log(meals)
   // }

    // Initialize draggable elements
    function initializeDraggables() {
    // Get all containers that might contain draggable events
    const containers = document.querySelectorAll('.accordion__body--text');
    
    containers.forEach(container => {
        new FullCalendar.Draggable(container, {
            itemSelector: ".external-event.fc-event",
            eventData: eventEl => {
                const $el = $(eventEl);
                return {
                    title: $el.text().trim(),
                    color: $el.data("mealtypecolor"),
                    extendedProps: {
                        mealId: $el.data("meal-mealid"),
                        mealType: $el.data("mealtypeid"),
                        mealTypeColor: $el.data("mealtypecolor"),
                        servings: $el.data("servings")
                    }
                };
            }
        });
    });
}

    // Load existing events from calendar
    function loadExistingEvents(calendarInstance) {
      // Set broader time range to ensure we capture all events
      const timeMin = new Date();
      timeMin.setMonth(timeMin.getMonth() - 1); // 1 months back
      const timeMax = new Date();
      timeMax.setMonth(timeMax.getMonth() + 6); // 6 months ahead

      $.ajax({
        url: `https://www.googleapis.com/calendar/v3/calendars/${CONFIG.calendarId}/events`,
        method: "GET",
        headers: { Authorization: `Bearer ${userAccessToken}` },
        data: {
          timeMin: timeMin.toISOString(),
          timeMax: timeMax.toISOString(),
          maxResults: 2500,
          singleEvents: true,
          orderBy: "startTime"
        },
        dataType: "json",
        success: function(response) {
        //          console.log("API Response:", response); // Debug full response
         
          if (!response.items || response.items.length === 0) {
            console.warn("No events found in response");
                Swal.fire({
                    title: "No Meals Planned",
                    text: "Let's do this!",
                    icon: "info",
                    showCancelButton: false,
                    confirmButtonText: "Let's Go!"
                });
            return;
          }

          //    console.log(`Found ${response.items.length} events`);

          const events = response.items.map(item => {
            // Handle both date and dateTime formats
            const startDate = item.start.date ||
                             (item.start.dateTime ? item.start.dateTime.split('T')[0] : null);
            const endDate = item.end.date ||
                           (item.end.dateTime ? item.end.dateTime.split('T')[0] : null);

            if (!startDate || !endDate) {
              console.warn("Skipping event with missing dates:", item.id);
              return null;
            }

            return {
              id: item.id,
              title: item.summary,
              start: startDate,
              end: endDate,
              extendedProps: {
                googleEventId: item.id,
                ...(item.extendedProperties?.private || {})
              }
            };
          }).filter(Boolean);

          if (events.length === 0) {
            console.warn("No valid events to add");
            return;
          }

          console.log(`Adding ${events.length} events to calendar`);
          calendarInstance.addEventSource(events);
        },
        error: function(xhr, status, err) {
          console.error("API Error:", {
            status: xhr.status,
            statusText: xhr.statusText,
            response: xhr.responseText
          });
        }
      });
    }

    // Save meal to calendar
    function saveMealPlacement(mealId, start, end, event, servings, mealType, mealTypeColor) {
        console.log(mealTypeColor);

        const payload = {
            summary: event.title,
            description: `MealID:${mealId}|Servings:${servings}|MealType:${mealType}|MealTypeColor:${mealTypeColor}`,
            start: { date: start },
            end: { date: end },
            extendedProperties: {
                private: {
                    mealId,
                    servings,
                    mealType,
                    mealTypeColor
                }
            }
        };

        $.ajax({
            url: `https://www.googleapis.com/calendar/v3/calendars/${CONFIG.calendarId}/events`,
            method: "POST",
            headers: { Authorization: `Bearer ${userAccessToken}` },
            data: JSON.stringify(payload),
            contentType: "application/json",
            success: response => {
                event.setExtendedProp("googleEventId", response.id);
            },
            error: err => console.error("Save error:", err)
        });
    }

    // Delete meal from calendar
    function deleteMealPlacement(info) {
        const googleEventId = info.event.extendedProps.googleEventId;
        if (!googleEventId) return;

        $.ajax({
            url: `https://www.googleapis.com/calendar/v3/calendars/${CONFIG.calendarId}/events/${googleEventId}`,
            method: "DELETE",
            headers: { Authorization: `Bearer ${userAccessToken}` },
            success: () => console.log("Event deleted"),
            error: err => console.error("Delete error:", err)
        });
    }

    // Initialization
    function init() {
        // Set up DOM elements cache
        elements.loginButton.addEventListener("click", initializeAuth);
        elements.logoutButton.addEventListener("click", logoutUser);

        // Check existing session
        const storedToken = sessionStorage.getItem("userAccessToken");
        const tokenExpiry = sessionStorage.getItem("tokenExpiry");

        if (storedToken && tokenExpiry && Date.now() < parseInt(tokenExpiry)) {
            userAccessToken = storedToken;
            elements.loginPrompt.style.display = "none";
            elements.mainWrapper.style.opacity = 1;
            initializeCalendar();
        }
    }

    // Start everything
    document.addEventListener("DOMContentLoaded", init);
})();