<cfscript>

if (structKeyExists(form, "edit_sysadmin_settings")) {

    settingsResult = new backend.core.com.sysadmin().saveSystemSettings(form);
    if (!settingsResult.success) {
        session.qrSettingsError = settingsResult;
        location url="#application.mainURL#/sysadmin/system-settings" addtoken="false";
    }

    structDelete(session, "qrSettingsError");
    getAlert('Settings saved!');
    location url="#application.mainURL#/sysadmin/system-settings?reinit=1" addtoken="false";

}


</cfscript>
