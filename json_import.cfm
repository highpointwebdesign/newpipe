<cfscript>
// Read the JSON file
jsonFilePath = expandPath("./data/calendar_data.json");
jsonContent = fileRead(jsonFilePath);
calendarData = deserializeJSON(jsonContent);

// Get the items array from the JSON
calendarItems = calendarData.items;

// Database connection parameters
dsn = "yourDatasourceName";

// Process each calendar event
for (item in calendarItems) {
    try {
        // Extract mealID from description or extendedProperties
        mealID = 0;
        if (structKeyExists(item, "extendedProperties") && 
            structKeyExists(item.extendedProperties, "private") && 
            structKeyExists(item.extendedProperties.private, "mealId")) {
            mealID = val(item.extendedProperties.private.mealId);
        } else if (structKeyExists(item, "description")) {
            // Parse description for MealID
            descriptionParts = listToArray(item.description, "|");
            for (part in descriptionParts) {
                if (findNoCase("MealID:", part)) {
                    mealID = val(replace(part, "MealID:", ""));
                    break;
                }
            }
        }
        
        // Skip if no valid mealID found
        if (mealID <= 0) {
            writeOutput("Skipping event #item.id# - No valid mealID found<br>");
            continue;
        }
        
        // Extract userID (you'll need to map email to userID)
        userID = "NULL";
        if (structKeyExists(item, "creator") && structKeyExists(item.creator, "email")) {
            // You might need to look up the userID based on email
            // For now, we'll set it to NULL
            // userID = getUserIDFromEmail(item.creator.email);
        }
        
        // Extract title
        title = item.summary;
        
        // Extract dates
        startDate = "";
        endDate = "";
        
        if (structKeyExists(item, "start")) {
            if (structKeyExists(item.start, "date")) {
                // All-day event
                startDate = parseDateTime(item.start.date);
                all_day = 1;
            } else if (structKeyExists(item.start, "dateTime")) {
                // Timed event
                startDate = parseDateTime(item.start.dateTime);
                all_day = 0;
            }
        }
        
        if (structKeyExists(item, "end")) {
            if (structKeyExists(item.end, "date")) {
                // All-day event - subtract 1 day from end date (Google Calendar quirk)
                endDate = dateAdd("d", -1, parseDateTime(item.end.date));
            } else if (structKeyExists(item.end, "dateTime")) {
                endDate = parseDateTime(item.end.dateTime);
            }
        }
        
        // Extract colors if available
        background_color = "NULL";
        if (structKeyExists(item, "extendedProperties") && 
            structKeyExists(item.extendedProperties, "private") && 
            structKeyExists(item.extendedProperties.private, "mealTypeColor")) {
            background_color = item.extendedProperties.private.mealTypeColor;
        }
        
        // Extract description
        description = structKeyExists(item, "description") ? item.description : "";
        
        // Insert into database
        queryExecute(
            "INSERT INTO meal_calendar_events (
                mealID, userID, title, startDate, endDate, all_day, 
                background_color, description
            ) VALUES (
                :mealID, :userID, :title, :startDate, :endDate, :all_day,
                :background_color, :description
            )",
            {
                mealID: {value: mealID, cfsqltype: "cf_sql_integer"},
                userID: {value: userID, cfsqltype: "cf_sql_integer", null: (userID == "NULL")},
                title: {value: title, cfsqltype: "cf_sql_varchar"},
                startDate: {value: startDate, cfsqltype: "cf_sql_timestamp"},
                endDate: {value: endDate, cfsqltype: "cf_sql_timestamp", null: (endDate == "")},
                all_day: {value: all_day, cfsqltype: "cf_sql_tinyint"},
                background_color: {value: background_color, cfsqltype: "cf_sql_varchar", null: (background_color == "NULL")},
                description: {value: description, cfsqltype: "cf_sql_longvarchar"}
            },
            {datasource: 'sg'}
        );
        
        writeOutput("Imported event: #title#<br>");
        
    } catch (any e) {
        writeOutput("Error importing event #item.id#: #e.message#<br>");
        writeDump(e);
        writeDump(item);
    }
}

writeOutput("Import complete!");
</cfscript>