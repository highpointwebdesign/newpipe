<cfscript>
    directoryPath = "C:/Users/daryl.lackey/Music/";
    oldName = form.id;
    newNameBase = form.value;

    // Get the file extension from the old name
    oldExtension = listLast(oldName, ".");
    
    // Construct the new full name with the original extension
    newName = newNameBase & "." & oldExtension;

    result = {};

    if (fileExists(directoryPath & oldName)) {
        // Check if the new filename already exists
        if (fileExists(directoryPath & newName) && compareNoCase(oldName, newName) != 0) {
            result.status = "error";
            result.message = "A file with this name already exists. Please choose a different name.";
        } else {
            try {
                fileMove(directoryPath & oldName, directoryPath & newName);
                result.status = "success";
                result.newName = newNameBase;
            } catch (any e) {
                result.status = "error";
                result.message = "Error: " & e.message;
            }
        }
    } else {
        result.status = "error";
        result.message = "Original file not found";
    }

    writeOutput(serializeJSON(result));
</cfscript>