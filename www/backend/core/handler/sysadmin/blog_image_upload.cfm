
<!---
This file is used to handle image uploads for blog posts via the hugerte editor.
It accepts POST requests with a file field named 'file' and uploads the image to
a structured directory based on the current date.
It returns a JSON response with the success status and the URL of the uploaded image.
 --->

<cfcontent type="application/json">

<cfscript>

    // Only accept POST requests with a file field named 'file'

    if (structKeyExists(form, "file")) {

        allowedFileTypes = ["jpg", "jpeg", "png", "gif", "webp"];

        // Build folder path by date: /userdata/images/blog/YYYY/MM/DD
        now = now();
        year = dateFormat(now, "yyyy");
        month = dateFormat(now, "mm");
        day = dateFormat(now, "dd");
        relPath = "/userdata/images/blog/" & year & "/" & month & "/" & day;
        absPath = expandPath(relPath);

        // Create the directory if it doesn't exist
        if (!directoryExists(absPath)) {
            directoryCreate(absPath, true);
        }

        uploadArgs = {
            filePath: absPath,
            fileNameOrig: "file",
            makeUnique: true
        };

        globalObj = new backend.core.com.global();
        result = globalObj.uploadFile(uploadArgs, allowedFileTypes);
        
        if (result.success) {
                imageUrl = relPath & "/" & result.fileName;
                writeOutput(serializeJSON({
                    'location': imageUrl
                }));
        } else {
            writeOutput(serializeJSON({
                'success': false,
                'message': result.message
            }));
        }
    } else {
        writeOutput(serializeJSON({
            'success': false,
            'message': "No file uploaded."
        }));
    }
    

</cfscript>
