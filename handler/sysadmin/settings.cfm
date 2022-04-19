<cfscript>


if (structKeyExists(form, "new_setting")) {

    param name="form.variable" default="";
    param name="form.value" default="";
    param name="form.desc" default="";

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            variable: {type: "varchar", value: form.variable},
            value: {type: "varchar", value: form.value},
            description: {type: "nvarchar", value: form.desc}
        },
        sql = "
            INSERT INTO custom_settings (strSettingVariable, strDefaultValue, strDescription)
            VALUES (:variable, :value, :description)
        "
    )

    getAlert('New setting saved!');
    location url="#application.mainURL#/sysadmin/settings" addtoken="false";

}


if (structKeyExists(form, "edit_setting")) {

    if (isNumeric(form.edit_setting)) {

        if (structKeyExists(form, "delete")) {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    settingID: {type: "numeric", value: form.edit_setting}
                },
                sql = "
                    DELETE FROM custom_settings WHERE intCustomSettingID = :settingID
                "
            )

            getAlert('Setting deleted!');

        } else {

            param name="form.variable" default="";
            param name="form.value" default="";
            param name="form.desc" default="";

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    variable: {type: "varchar", value: form.variable},
                    value: {type: "varchar", value: form.value},
                    description: {type: "nvarchar", value: form.desc},
                    settingID: {type: "numeric", value: form.edit_setting}
                },
                sql = "
                    UPDATE custom_settings
                    SET strSettingVariable = :variable,
                        strDefaultValue = :value,
                        strDescription = :description
                    WHERE intCustomSettingID = :settingID
                "
            )

            getAlert('Setting saved!');

        }

    }


    location url="#application.mainURL#/sysadmin/settings" addtoken="false";

}


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
    location url="#application.mainURL#/sysadmin/system-settings" addtoken="false";

}


</cfscript>