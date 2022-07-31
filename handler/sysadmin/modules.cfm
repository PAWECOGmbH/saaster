<cfscript>


if (structKeyExists(form, "new_module")) {

    qNexPrio = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COALESCE(MAX(intPrio),0)+1 as nextPrio
            FROM modules
        "
    )

    param name="form.module_name" default="";

    try {

        // Insert module
        queryExecute(
            options = {datasource = application.datasource, result="newID"},
            params = {
                module_name: {type: "nvarchar", value: form.module_name},
                active: {type: "boolean", value: 0},
                bookable: {type: "boolean", value: 0},
                test_days: {type: "numeric", value: 30},
                nextPrio: {type: "numeric", value: qNexPrio.nextPrio}
            },
            sql = "
                INSERT INTO modules (strModuleName, blnActive, blnBookable, intNumTestDays, intPrio)
                VALUES (:module_name, :active, :bookable, :test_days, :nextPrio)
            "
        )

        newModuleID = newID.generatedkey;

        // Get default values
        standardVatType = application.objGlobal.getSetting('settingStandardVatType');
        invoiceNet = application.objGlobal.getSetting('settingInvoiceNet');

        // Get active currencies
        qCurrencies = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intCurrencyID
                FROM currencies
                WHERE blnActive = 1
            "
        )

        // Looping all active currencies
        loop query="qCurrencies" {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    moduleID: {type: "numeric", value: newModuleID},
                    currencyID: {type: "numeric", value: qCurrencies.intCurrencyID},
                    standardVatType: {type: "numeric", value: standardVatType},
                    invoiceNet: {type: "boolean", value: invoiceNet},
                },
                sql = "
                    INSERT INTO modules_prices (intModuleID, intCurrencyID, decPriceMonthly, decPriceYearly, decPriceOneTime, decVat, blnIsNet, intVatType)
                    VALUES (:moduleID, :currencyID, 0, 0, 0, 0, :invoiceNet, :standardVatType)
                "
            )

        }

        getAlert('Module saved. Please complete your data now.');
        location url="#application.mainURL#/sysadmin/modules/edit/#newModuleID#" addtoken="false";

    } catch (any e) {

        getAlert(e.message, 'danger');
        location url="#application.mainURL#/sysadmin/modules" addtoken="false";

    }

}


if (structKeyExists(form, "edit_module")) {

    if (isNumeric(form.edit_module)) {

        picSuccess = true;

        if (structKeyExists(form, "pic") and len(trim(form.pic))) {

            fileStruct = structNew();
            fileStruct.filePath = expandPath('/userdata/images/modules'); //absolute path
            fileStruct.maxSize = "500"; // empty or kb
            fileStruct.maxWidth = "1000"; // empty or pixels
            fileStruct.maxHeight = "1000"; // empty or pixels
            fileStruct.makeUnique = true; // true or false (default true)
            fileStruct.fileName = lcase(replace(createUUID(),"-", "", "all")); // empty or any name; ex. uuid (without extension)

            fileStruct.fileNameOrig = form.pic;

            // Check if file is a valid image
            try {
                ImageRead(ExpandPath("#fileStruct.fileNameOrig#"));
            }
            catch("java.io.IOException" e){
                getAlert( "msgFileUploadError", 'danger');
                location url="#application.mainURL#/sysadmin/modules/edit/#form.edit_module#" addtoken="false";
            }
            catch(any e){
                getAlert( e.message, 'danger');
                location url="#application.mainURL#/account-settings/my-profile" addtoken="false";
            }

            <!--- Sending the data into a function --->
            fileUpload = application.objGlobal.uploadFile(fileStruct, variables.imageFileTypes);

            if (fileUpload.success) {

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        thisPicName: {type: "varchar", value: fileUpload.fileName},
                        thisID: {type: "numeric", value: form.edit_module}
                    },
                    sql = "
                        UPDATE modules
                        SET strPicture = :thisPicName
                        WHERE intModuleID = :thisID
                    "
                )

            } else {

                getAlert(fileUpload.message, 'danger');
                picSuccess = false;

            }

        }

        if (structKeyExists(form, "bookable")) {
            bookable = 1;
        } else {
            bookable = 0;
        }
        if (structKeyExists(form, "active")) {
            active = 1;
        } else {
            active = 0;
        }

        param name="form.module_name" default="";
        param name="form.short_desc" default="";
        param name="form.prefix" default="";
        param name="form.pic" default="";
        param name="form.desc" default="";
        param name="form.test_days" default="0";
        param name="form.path" default="";

        mapping = "modules/" & form.prefix & "/settings";
        path =  "modules/" & form.prefix & "/settings.cfm";

        // Is there already an entry in the custom mappings?
        qMappings = queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: form.edit_module}
            },
            sql = "
                SELECT intModuleID
                FROM custom_mappings
                WHERE intModuleID = :moduleID
            "
        )

        if (qMappings.recordCount) {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    mapping: {type: "varchar", value: mapping},
                    thispath: {type: "varchar", value: path},
                    moduleID: {type: "numeric", value: form.edit_module}
                },
                sql = "
                    UPDATE custom_mappings
                    SET strMapping = :mapping,
                        strPath = :thispath
                    WHERE intModuleID = :moduleID
                "
            )

        } else {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    mapping: {type: "varchar", value: mapping},
                    thispath: {type: "varchar", value: path},
                    admin: {type: "boolean", value: 1},
                    superadmin: {type: "boolean", value: 0},
                    sysadmin: {type: "boolean", value: 0},
                    moduleID: {type: "numeric", value: form.edit_module}
                },
                sql = "
                    INSERT INTO custom_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin, intModuleID)
                    VALUES (:mapping, :thispath, :admin, :superadmin, :sysadmin, :moduleID)
                "
            )

        }

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                module_name: {type: "nvarchar", value: form.module_name},
                short_desc: {type: "nvarchar", value: form.short_desc},
                prefix: {type: "varchar", value: form.prefix},
                active: {type: "boolean", value: active},
                bookable: {type: "boolean", value: bookable},
                test_days: {type: "numeric", value: form.test_days},
                description: {type: "nvarchar", value: form.desc},
                moduleID: {type: "numeric", value: form.edit_module},
                modulePath: {type: "varchar", value: mapping}
            },
            sql = "
                UPDATE modules
                SET strModuleName = :module_name,
                    strShortDescription = :short_desc,
                    strDescription = :description,
                    blnActive = :active,
                    strTabPrefix = :prefix,
                    blnBookable = :bookable,
                    intNumTestDays = :test_days,
                    strSettingPath = :modulePath
                WHERE intModuleID = :moduleID

            "
        )

        <!--- Create the folder specified --->
        createFolderSuccess = true;
        if (!directoryExists(expandPath('/modules/#form.prefix#'))) {
            try {
                directoryCreate(expandPath('/modules/#form.prefix#'));
            } catch (any e) {
                createFolderSuccess = false;
                getAlert('Could not create the folder!');
            }
        }


        <!--- Create the file for the navigation (the savecontent must be completely to the left, otherwise we have spaces...) --->
        createFileSuccess = true;
        if (!fileExists(expandPath('/modules/#form.prefix#/navigation.cfm'))) {
savecontent variable="naviContent" {
writeOutput("
<a href='' class='dropdown-item'>Your page 1</a>
<a href='' class='dropdown-item'>Your page 2</a>
<a href='' class='dropdown-item'>Your page 3</a>
");
}
            try {
                fileWrite(expandPath('/modules/#form.prefix#/navigation.cfm'), naviContent);
            } catch (any e) {
                createFileSuccess = false;
                getAlert(e.message, 'danger');
            }
        }


        <!--- Create the file for settings --->
        createSettingFileSuccess = true;
        if (!fileExists(expandPath('/modules/#form.prefix#/settings.cfm'))) {
savecontent variable="settingContent" {
writeOutput("
<cfscript>
dump('Hello settings!');
</cfscript>
");
}
            try {
                fileWrite(expandPath('/modules/#form.prefix#/settings.cfm'), settingContent);
            } catch (any e) {
                createSettingFileSuccess = false;
                getAlert(e.message, 'danger');
            }
        }


        if (picSuccess and createFolderSuccess and createSettingFileSuccess) {
            getAlert('Module saved.');
        }

        <!--- Refresh the session in order to see the changes --->
        checkModules = new com.modules(language=session.lng).getBookedModules(session.customer_id);
        session.currentModules = checkModules;

        location url="#application.mainURL#/sysadmin/modules/edit/#form.edit_module#" addtoken="false";

    }

}



if (structKeyExists(url, "delete_pic")) {

    if (isNumeric(url.delete_pic)) {

        qPicture = queryExecute(
            options = {datasource = application.datasource},
            params = {
                modulID: {type: "numeric", value: url.delete_pic}
            },
            sql="
                SELECT strPicture
                FROM modules
                WHERE intModuleID = :modulID
            "
        )

        if (qPicture.recordCount and len(trim(qPicture.strPicture))) {

            <!--- Delete picture using a function --->
            application.objGlobal.deleteFile(expandPath("/userdata/images/modules/#qPicture.strPicture#"));

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    modulID: {type: "numeric", value: url.delete_pic}
                },
                sql="
                    UPDATE modules
                    SET strPicture = ''
                    WHERE intModuleID = :modulID
                "
            )

        }

        location url="#application.mainURL#/sysadmin/modules/edit/#url.delete_pic#" addtoken="false";

    }

}



if (structKeyExists(url, "delete_module")) {

    if (isNumeric(url.delete_module)) {

        // Delete picture first
        qPicture = queryExecute(
            options = {datasource = application.datasource},
            params = {
                modulID: {type: "numeric", value: url.delete_module}
            },
            sql="
                SELECT strPicture
                FROM modules
                WHERE intModuleID = :modulID
            "
        )

        if (qPicture.recordCount and len(trim(qPicture.strPicture))) {

            <!--- Delete picture using a function --->
            application.objGlobal.deleteFile(expandPath("/userdata/images/modules/#qPicture.strPicture#"));

        }

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                modulID: {type: "numeric", value: url.delete_module}
            },
            sql="
                DELETE FROM modules
                WHERE intModuleID = :modulID
            "
        )

        getAlert('Module deleted');
        location url="#application.mainURL#/sysadmin/modules" addtoken="false";

    }


}


if (structKeyExists(form, "edit_prices")) {

    if (isNumeric(form.edit_prices)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: form.edit_prices}
            },
            sql = "
                UPDATE modules_prices
                SET blnIsNet = 0
                WHERE intModuleID = :moduleID
            "
        )

        itsOneTimePricing = false;

        cfloop( list = form.fieldnames, index = "f" ) {

            thisCurrencyID = listLast(f, "_");
            thisField = listFirst(f, "_");

            if (thisField eq "pricemonthly" or thisField eq "priceyearly" or thisField eq "onetime") {

                // Look whether we find an entry in the table
                qCheckPrice = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        moduleID: {type: "numeric", value: form.edit_prices},
                        thisCurrencyID: {type: "numeric", value: thisCurrencyID}
                    },
                    sql = "
                        SELECT intCurrencyID
                        FROM modules_prices
                        WHERE intModuleID = :moduleID
                        AND intCurrencyID = :thisCurrencyID
                    "
                )

                if (!qCheckPrice.recordCount) {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            moduleID: {type: "numeric", value: form.edit_prices},
                            thisCurrencyID: {type: "numeric", value: thisCurrencyID}
                        },
                        sql = "
                            INSERT INTO modules_prices (intModuleID, intCurrencyID)
                            VALUES (:moduleID, :thisCurrencyID)
                        "
                    )

                }

                pricemonthly = 0;
                priceyearly = 0;
                onetime = 0;

                if (thisField eq "onetime") {
                    onetime = evaluate("onetime_#thisCurrencyID#");
                    if (isNumeric(onetime)) {
                        if (onetime gt 0) {
                            itsOneTimePricing = true;
                        }
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                moduleID: {type: "numeric", value: form.edit_prices},
                                thisCurrencyID: {type: "numeric", value: thisCurrencyID},
                                onetime: {type: "decimal", value: onetime, scale: 2}
                            },
                            sql = "
                                UPDATE modules_prices
                                SET decPriceOneTime = :onetime
                                WHERE intModuleID = :moduleID
                                AND intCurrencyID = :thisCurrencyID
                            "
                        )
                    }
                }

                if (thisField eq "pricemonthly") {
                    pricemonthly = evaluate("pricemonthly_#thisCurrencyID#");
                    if (isNumeric(pricemonthly) and onetime eq 0) {
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                moduleID: {type: "numeric", value: form.edit_prices},
                                thisCurrencyID: {type: "numeric", value: thisCurrencyID},
                                pricemonthly: {type: "decimal", value: pricemonthly, scale: 2}
                            },
                            sql = "
                                UPDATE modules_prices
                                SET decPriceMonthly = :pricemonthly
                                WHERE intModuleID = :moduleID
                                AND intCurrencyID = :thisCurrencyID
                            "
                        )
                    }
                }

                if (thisField eq "priceyearly") {
                    priceyearly = evaluate("priceyearly_#thisCurrencyID#");
                    if (isNumeric(priceyearly) and onetime eq 0) {
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                moduleID: {type: "numeric", value: form.edit_prices},
                                thisCurrencyID: {type: "numeric", value: thisCurrencyID},
                                priceyearly: {type: "decimal", value: priceyearly, scale: 2}
                            },
                            sql = "
                                UPDATE modules_prices
                                SET decPriceYearly = :priceyearly
                                WHERE intModuleID = :moduleID
                                AND intCurrencyID = :thisCurrencyID
                            "
                        )
                    }
                }

            }
        }

        vat = 0;
        type = 1;
        isNetto = 0;
        onRequest = 0;
        updateSQL = "";

        if (isNumeric(form.vat)) {
            vat = form.vat;
        }
        if (isNumeric(form.type)) {
            type = form.type;
        }
        if (structKeyExists(form, "netto")) {
            isNetto = 1;
        }
        if (structKeyExists(form, "request")) {
            onRequest = 1;
        }
        if (itsOneTimePricing) {
            updateSQL = "
                ,decPriceMonthly = 0, decPriceYearly = 0
            ";
        }

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: form.edit_prices},
                vat: {type: "decimal", value: vat, scale: 2},
                type: {type: "numeric", value: type},
                isNetto: {type: "boolean", value: isNetto}
            },
            sql = "
                UPDATE modules_prices
                SET decVat = :vat,
                    intVatType = :type,
                    blnIsNet = :isNetto
                    #updateSQL#
                WHERE intModuleID = :moduleID
            "
        )

        getAlert('Prices saved.');
        location url="#application.mainURL#/sysadmin/modules/edit/#form.edit_prices#?tab=prices" addtoken="false";

    }

}



</cfscript>