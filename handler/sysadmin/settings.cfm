<cfscript>

if (structKeyExists(form, "edit_sysadmin_settings")) {

    loop list="#fieldnames#" index="i" {

        if (i neq "edit_sysadmin_settings") {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    variable: {type: "varchar", value: i},
                    value: {type: "varchar", value: evaluate(i)}
                },
                sql = "
                    UPDATE system_settings
                    SET strDefaultValue = :value
                    WHERE strSettingVariable = :variable
                "
            )

        }

    }

    getAlert('Settings saved!');
    location url="#application.mainURL#/sysadmin/system-settings?reinit=1" addtoken="false";

}


</cfscript>