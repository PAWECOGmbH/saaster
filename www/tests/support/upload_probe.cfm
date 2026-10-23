<cfsetting showdebugoutput="false">
<cfscript>
/*
    Receives a multipart upload for specs/integration/upload_spec.cfc and hands it
    to objGlobal.uploadFile() - the same call the logo and avatar handlers make.

    A file upload only exists inside a real HTTP request, so the spec posts to this
    page instead of calling uploadFile() directly. The target folder is a fresh
    folder in the temp directory, never /userdata. The answer reports what
    uploadFile() returned, which files ended up in the target and how many
    temporary upload folders are left, then the target is removed again.

    It only lives inside the test application, which refuses to start outside of
    development.
*/
target = getTempDirectory() & "saaster-upload-probe/" & createUUID();
tempRoot = getTempDirectory() & "saaster-uploads";

uploadArgs = {
    filePath: target,
    fileNameOrig: "file",
    maxSize: structKeyExists(form, "maxSize") ? form.maxSize : ""
};
allowed = listToArray(structKeyExists(form, "allowed") ? form.allowed : "png,jpg");

try {
    result = application.objGlobal.uploadFile(uploadArgs, allowed);
} catch (any e) {
    result = { success: false, message: e.message, fileName: "" };
}

answer = {
    "success": result.success,
    "message": result.message,
    "fileName": result.fileName,
    "targetFiles": directoryExists(target) ? directoryList(target, false, "name") : [],
    "tempFolders": directoryExists(tempRoot) ? arrayLen(directoryList(tempRoot, false, "name")) : 0
};

if (directoryExists(target)) {
    directoryDelete(target, true);
}

content type="application/json" reset="true";
writeOutput(serializeJSON(answer));
</cfscript>
