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
  //  const start = moment().add(1, 'days');
  const start = '09/03/2025';
  //  const end = moment().add(14, 'days');;
  const end = moment().add(120, 'days');
  
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

/**
 * Main function to load and process meal events
 */
async function loadMealEvents(startDate, endDate) {
  try {
    // 1. Fetch raw events
    const raw = await fetchCalendarEvents(startDate, endDate);

    // 2. Merge consecutive same-MealID events
    const events = mergeConsecutiveEvents(raw);

    // 3. Calculate multipliers on merged list
    const { mealMultipliers, mealNames } =
      calculateMealMultipliers(events, startDate, endDate);

    //  console.log("mealMultipliers after merge:", mealMultipliers);

    // 4. Render UI and shopping list as before…
    updateMealListUI(mealNames);
    const ingredients = await fetchMealIngredients(
      Object.keys(mealMultipliers).join(",")
    );
    const shoppingList = calculateShoppingList(ingredients, mealMultipliers);
    updateShoppingListUI(shoppingList);

  } catch (error) {
    console.error("Error loading meal events:", error);

    // Decide what message to show
    let alertMsg;
    // jQuery XHR object has .status & .responseJSON, but adapt if yours looks different
    const code = error.status || error.responseJSON?.error?.code;
    const apiMsg = error.responseJSON?.error?.message;
    
    if (code === 401) {
      alertMsg = `Invalid or expired credentials.<br/>Click on <a href="/calendar.cfm">Meal Planner</a> to reauthenticate.`;
    } else {
      alertMsg = "Error loading meal events. Please try again. Error: " + error;
    }

    // Render into your alert container
    // $(CONFIG.selectors.alertContainer).html(
    //   `<div class="alert alert-danger">${alertMsg}</div>`
    // );

    // Show a SweetAlert with the same info (use html so link works)
    Swal.fire({
      title: "Error loading data",
      html: alertMsg,
      icon: "warning",
      showCancelButton: false,
      confirmButtonText: "Okay"
    });
  }
}

/**
 * Fetch events from Google Calendar API
 */
async function fetchCalendarEvents(startDate, endDate) {
  const timeMin = `${startDate}T00:00:00Z`;
  const timeMax = `${endDate}T23:59:59Z`;

  return new Promise((resolve, reject) => {
    $.ajax({
      url: `https://www.googleapis.com/calendar/v3/calendars/${CONFIG.calendarId}/events`,
      method: "GET",
      headers: {
        Authorization: `Bearer ${userAccessToken}`
      },
      data: {
        timeMin: timeMin,
        timeMax: timeMax,
        singleEvents: true
      },
      success: function(response) {
// console.log(response.items);
        resolve(response.items);
      },
      error: function(err) {
        reject(err);
      }
    });
  });
}

/**
 * Coalesces consecutive all-day events with the same MealID
 */
function mergeConsecutiveEvents(events) {
  // Group events by MealID
  const byMeal = events.reduce((acc, ev) => {
    const match = (ev.description||"").match(/MealID:\s*(\d+)/);
    if (!match) return acc;
    const id = match[1];
    acc[id] = acc[id] || [];
    acc[id].push(ev);
    return acc;
  }, {});

  // For each group, sort and merge touching ranges
  return Object.values(byMeal).flatMap(list => {
    const sorted = list.sort(
      (a, b) => new Date(a.start.date) - new Date(b.start.date)
    );
    const merged = [];
    let cursor = { ...sorted[0] };

    for (let i = 1; i < sorted.length; i++) {
      const next = sorted[i];
      // If cursor ends exactly when next starts, extend cursor
      if (moment(cursor.end.date).isSame(next.start.date, "day")) {
        cursor.end = { date: next.end.date };
      } else {
        merged.push(cursor);
        cursor = { ...next };
      }
    }
    merged.push(cursor);
    return merged;
  });
}


/**
 * Calculate meal multipliers based on event overlaps
 */
function calculateMealMultipliers(events, startDate, endDate) {
  const mealMultipliers = {};
  const mealNames       = {};

  events.forEach(event => {
    const match = (event.description||"").match(/MealID:\s*(\d+)/);
    if (!match) return;
    const mealId = match[1];

    // parse dates
    const eventStart = moment(event.start.date);
    const eventEnd   = moment(event.end.date);
    const tripStart  = moment(startDate);
    const tripEnd    = moment(endDate).add(1, "day");

    // compute overlap
    const effectiveStart = moment.max(eventStart, tripStart);
    const effectiveEnd   = moment.min(eventEnd,   tripEnd);
    let   effectiveDays  = effectiveEnd.diff(effectiveStart, "days");

    // count same-day starts properly
    if (
      effectiveDays === 0 &&
      effectiveStart.isSame(effectiveEnd, "day") &&
      effectiveStart.isSame(eventStart, "day")
    ) {
      effectiveDays = 1;
    }

    if (effectiveDays > 0) {
      // register name once
      if (!mealNames[mealId]) {
        mealNames[mealId] = event.summary + ' ('+ event.extendedProperties.private.mealType + ')';
      }

      // calculate fraction of a recipe
      const fullEventDuration = eventEnd.diff(eventStart, "days") || 1;
      const factor = effectiveDays / fullEventDuration;

      mealMultipliers[mealId] = 
        (mealMultipliers[mealId] || 0) + factor;
    }
  });

  return { mealMultipliers, mealNames };
}


/**
 * Update UI with meal list
 */
function updateMealListUI(mealNames) {
  const ids = Object.keys(mealNames);
  
  if (ids.length > 0) {
    // sort IDs by their corresponding meal name
    const sortedIds = ids.sort((a, b) =>
      mealNames[a].localeCompare(mealNames[b])
    );
    
    let mealListHtml = "<ul class='list-group'>";
    
    sortedIds.forEach(mealId => {
      mealListHtml += `<li class='list-group-item'>${mealNames[mealId]}</li>`;
    });
    
    mealListHtml += "</ul>";
    $(CONFIG.selectors.mealListContainer).html(mealListHtml);
    $('#bordered_no-gutter_collapseOne').collapse('show');
    $('[data-bs-target="#bordered_no-gutter_collapseOne"]').removeClass('collapsed');    
  } else {
    $(CONFIG.selectors.mealListContainer).html("");
  }
}


/**
 * Fetch meal ingredients from API
 */
async function fetchMealIngredients(mealIds) {
  if (!mealIds) return [];
  
  return new Promise((resolve, reject) => {
    let attempts = 0;
    
    function makeAjaxRequest() {
      $.ajax({
        url: "/api/mealplanner.cfc",
        method: "GET",
        data: {
          method: "getMealIngredients",
          mealIds: mealIds
        },
        dataType: "json",
        success: function(response) {
          // resolve(response || []);
          populateIngredientsList(response);
        },
        error: function(xhr, textStatus, errorThrown) {
          if (attempts === 0) {
            attempts++;
            console.warn("Ajax call failed on first attempt, retrying...", errorThrown);
            makeAjaxRequest();
          } else {
            reject(errorThrown);
          }
        }
      });
    }
    
    makeAjaxRequest();
  });
}

function populateIngredientsList(ingredients) {
  // Assuming you have a container element with id "ingredientsList"
  const listContainer = $("#shoppingList");
  
  // Clear existing content
  listContainer.empty();
  
  // Create and append list items
  ingredients.forEach(item => {
    // console.log(item);
    const listItem = $("<li>").addClass("list-group-item");
    
    // Format the quantity and unit
    const quantityText = `${item.totalQuantityFraction} ${item.baseUnit}${item.quantity !== 1 && item.baseUnit.toLowerCase() !== 'unit' ? 's' : ''}`;
    
    listItem.html(`<span class="ingredient-quantity">${quantityText}</span> of <span class="ingredient-name">${item.ingredient_name}</span> `);
    // console.log(listItem);

    listContainer.append(listItem);
    $('#bordered_no-gutter_collapseTwo').collapse('show');
    $('[data-bs-target="#bordered_no-gutter_collapseTwo"]').removeClass('collapsed');
  });
}


/**
 * Build a shopping list, rounding up ‘each’-type items to whole numbers
 */
function calculateShoppingList(ingredients, mealMultipliers) {
  const shoppingList = {};

// console.log(ingredients);
// console.log(mealMultipliers);

  // 1) Sum adjusted quantities, normalizing ingredient keys
  ingredients.forEach(item => {
    // Normalize the key to lowercase & trim whitespace
    const key = item.ingredient.trim().toLowerCase();
    // Store a display name (Title Case) on first sighting
    const displayName = item.ingredient.trim()
      .toLowerCase()
      .split(' ')
      .map(w => w[0].toUpperCase() + w.slice(1))
      .join(' ');
    
    const factor = mealMultipliers[item.meal_id] || 0;
    const adjustedQty = item.quantity * factor;

    if (shoppingList[key]) {
      shoppingList[key].quantity += adjustedQty;
    } else {
      shoppingList[key] = {
        name:     displayName,
        quantity: adjustedQty,
        unit:     item.unit
      };
    }
  });

  // 2) Round up indivisible units
  const indivisible = new Set([ "each", "ea", "pcs", "piece", "can", "cans" ]);
  Object.values(shoppingList).forEach(entry => {
    if (indivisible.has(entry.unit.toLowerCase())) {
      entry.quantity = Math.ceil(entry.quantity);
    }
  });

  return shoppingList;
}



/**
 * Update UI with shopping list
 */
function updateShoppingListUIXXX(shoppingList) {

  //    console.log(shoppingList);


  if (Object.keys(shoppingList).length > 0) {
    let listHTML = "<ul class='list-group'>";
    
    for (const ingredient in shoppingList) {
      const qty = shoppingList[ingredient].quantity.toFixed(2);
      const unit = shoppingList[ingredient].unit;
      listHTML += `<li class='list-group-item'><label><input type='checkbox'></input> ${ingredient}: ${qty} ${unit}</label></li>`;
    }
    
    listHTML += "</ul>";
    $(CONFIG.selectors.shoppingList).html(listHTML);
    $('#bordered_no-gutter_collapseTwo').collapse('show');
    $('[data-bs-target="#bordered_no-gutter_collapseTwo"]').removeClass('collapsed');
  } else {
    $(CONFIG.selectors.alertContainer).html('<div class="alert alert-warning solid alert-dismissible fade show"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="me-2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg><strong>Warning!</strong> No meals planned within the specified date range.<button type="button" class="close h-100" data-bs-dismiss="alert" aria-label="Close"><span><i class="mdi mdi-close"></i></span></button></div>');
    $(CONFIG.selectors.shoppingList).html("");
  }
}

function updateShoppingListUI(shoppingList) {

  //    console.log(shoppingList);


  if (Object.keys(shoppingList).length > 0) {
    let listHTML = "<ul class='list-group'><div class='checkbox-info'>";
    
    for (const ingredient in shoppingList) {
      const qty = shoppingList[ingredient].quantity.toFixed(2);
      const unit = shoppingList[ingredient].unit;
      listHTML += `<li class='list-group-item'><label class='form-check-label'><input type="checkbox" class="form-check-input" value=""><span style='padding-left:10px'>${ingredient}: ${qty} ${unit}</span></label></li>`;
    }
    
    listHTML += "</div></ul>";
    $(CONFIG.selectors.shoppingList).html(listHTML);
    $('#bordered_no-gutter_collapseTwo').collapse('show');
    $('[data-bs-target="#bordered_no-gutter_collapseTwo"]').removeClass('collapsed');
  } else {
    $(CONFIG.selectors.alertContainer).html('<div class="alert alert-warning solid alert-dismissible fade show"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="me-2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg><strong>Warning!</strong> No meals planned within the specified date range.<button type="button" class="close h-100" data-bs-dismiss="alert" aria-label="Close"><span><i class="mdi mdi-close"></i></span></button></div>');
    $(CONFIG.selectors.shoppingList).html("");
  }
}


