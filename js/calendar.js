$(document).ready(function() {

  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
  return new bootstrap.Tooltip(tooltipTriggerEl)
})


      // Load meals for dragging
      $.ajax({
        url: "api/mealplanner.cfc?method=getMeals",
        method: "GET",
        dataType: "json",
        success: function(meals) {
          $("#mealList").empty();
          $.each(meals, function(i, meal) {
            $("#mealList").append(
              '<div class="meal-item" data-meal-id="' + meal.id + '" data-servings="' + meal.servings + '">' +
              meal.title +
              '</div>'
            );
          });

          // Make meals draggable with FullCalendar event data
          $(".meal-item").each(function() {
            $(this).draggable({
              revert: "invalid",
              helper: "clone",
              appendTo: "body",
              start: function(event, ui) {
                ui.helper.data("event", {
                  title: $(this).text(),
                  extendedProps: {
                    mealId: $(this).data("meal-id"),
                    servings: $(this).data("servings")
                  }
                });
              }
            });
          });
        }
      });

      // Initialize FullCalendar
      var calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
        initialView: "dayGridMonth",
        editable: true,
        droppable: true,
        eventReceive: function(info) {
          var eventData = info.draggedEl.data("event");

          if (!eventData) {
            console.error("Dropped event data is missing!");
            return;
          }

          var numMeals = Math.ceil(eventData.extendedProps.servings / 2); // Determine meal span

          // Assign meal details to the event
          info.event.setProp("title", eventData.title);
          info.event.setExtendedProp("mealId", eventData.extendedProps.mealId);
          info.event.setEnd(new Date(info.event.start.getTime() + (numMeals * 24 * 60 * 60 * 1000)));

          // Save meal placement
          saveMealPlacement(eventData.extendedProps.mealId, info.event.startStr, info.event.endStr);
        },
        eventDrop: function(info) {
          var mealId = info.event.extendedProps.mealId;
          saveMealPlacement(mealId, info.event.startStr, info.event.endStr);
        }
      });

      calendar.render();

      // Function to store meal placements
      function saveMealPlacement(mealId, startDate, endDate) {
        $.ajax({
          url: "api/mealplanner.cfc?method=saveMealPlacement",
          method: "POST",
          data: { mealId: mealId, startDate: startDate, endDate: endDate },
          success: function() {
            console.log("Meal placement saved!");
          },
          error: function() {
            console.error("Error saving meal placement");
          }
        });
      }
    });