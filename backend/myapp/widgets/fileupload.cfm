

<cfscript>

    if (structKeyExists(form, "data")) {

        fileStruct = structNew();
        fileStruct.filePath = expandPath('userdata/profiledata/#session.user_ID#'); //absolute path
        fileStruct.maxSize = "5000"; // empty or kb
        fileStruct.maxWidth = ""; // empty or pixels
        fileStruct.maxHeight = ""; // empty or pixels
        fileStruct.makeUnique = true; // true or false (default true)
        fileStruct.fileName = ""; // empty or any name; ex. uuid (without extension)
        fileStruct.fileNameOrig = form.data;
        fileStruct.user_id = session.user_id;
        fileStruct.customer_id = session.customer_id;

        // Upload the file using a function
        fileUpload = application.objGlobal.uploadFile(fileStruct, variables.imageFileTypes);

        dump(fileUpload);
        abort;

    }

</cfscript>

<form action="/backend/myapp/widgets/fileupload" method="post" enctype="multipart/form-data">
    <input type="file" name="data">
    <input type="submit" value="upload">
</form>