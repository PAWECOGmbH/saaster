<cfscript>

objProfile = new backend.myapp.com.profile();
getProfileAccess = objProfile.getProfileAccess(session.user_id);

// Company description
if (structKeyExists(form, "description")) {

    saveDescription = objProfile.saveDescription(form);

    if (saveDescription.success) {
       getAlert(saveDescription.message);
    } else {
       getAlert(saveDescription.message, "danger");
    }

    location url="#application.mainURL#/employer/profile" addtoken="false";

}

// Upload file
if (structKeyExists(form, "upload_btn")) {

    if (structKeyExists(form, "data") and len(trim(form.data))) {

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
        fileUpload = application.objGlobal.uploadFile(fileStruct, variables.documentsFileTypes);

        if (fileUpload.success) {

            // Write data into db
            insertFile = objProfile.insertFileData(fileUpload.fileName, session.user_id, session.customer_id);

            if (insertFile.success) {
                getAlert('Die Datei wurde erfolgreich hochgeladen.');
            } else {
                getAlert('Die Datei konnte nicht hochgeladen werden!', 'danger');
            }

        } else {
            getAlert(fileUpload.message, 'danger');
        }

        location url="#application.mainURL#/employee/profile" addtoken="false";


    }

}

// Delete file
if (structKeyExists(url, "del")) {

    if (isNumeric(url.del)) {

      delFile = objProfile.deleteFile(url.del, session.user_id, session.customer_id);

      if (delFile.success) {
         getAlert(delFile.message);
      } else {
         getAlert(delFile.message, "danger");
      }

      location url="#application.mainURL#/employee/profile" addtoken="false";

   }

}

// Profile status
if (structKeyExists(form, "status")) {

    if (structKeyExists(form, "adID") and isNumeric(form.adID)) {

        if (session.currentPlan.status neq "free") {

            if (structKeyExists(form, "public")) {
                public = 1;
            } else {
                public = 0;
            }

            updateProfileStatus = objProfile.updateProfileStatus(session.customer_id, session.user_id, form.adID, public);

            if (updateProfileStatus.success) {
                getAlert(updateProfileStatus.message);
            } else {
                getAlert(updateProfileStatus.message, "danger");
            }

        }

        location url="#application.mainURL#/employee/ads/settings" addtoken="false";

    }

}

// Profile access
if (structKeyExists(form, "access")) {

    if (structKeyExists(form, "adID") and isNumeric(form.adID)) {

        updateProfileAccess = objProfile.updateProfileAccess(session.customer_id, session.user_id, form);

        if (!updateProfileAccess.success) {
            getAlert(updateProfileAccess.message, "danger");
        }

        location url="#application.mainURL#/employee/ads/settings" addtoken="false";

    }

}


location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>