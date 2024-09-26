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
        standardVatType = application.objSettings.getSetting('settingStandardVatType');
        invoiceNet = application.objSettings.getSetting('settingInvoiceNet');

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

            // Sending the data into a function
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

        bookable = structKeyExists(form, "bookable") ? 1 : 0;
        active = structKeyExists(form, "active") ? 1 : 0;

        param name="form.module_name" default="";
        param name="form.short_desc" default="";
        param name="form.prefix" default="";
        param name="form.pic" default="";
        param name="form.desc" default="";
        param name="form.test_days" default="0";
        param name="form.path" default="";

        mapping = "backend/modules/" & form.prefix & "/settings";
        path =  "backend/modules/" & form.prefix & "/settings.cfm";

        // Is there already an entry in the custom mappings?
        qMappings = queryExecute(
            options = {datasource = application.datasource},
            params = {
                mapping: {type: "varchar", value: mapping}
            },
            sql = "
                SELECT intModuleID
                FROM custom_mappings
                WHERE strMapping = :mapping
            "
        )

        try {

            if (!qMappings.recordCount) {

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

        } catch (any e) {

            getAlert(e.message, 'danger');
            location url="#application.mainURL#/sysadmin/modules/edit/#form.edit_module#" addtoken="false";

        }

        if (structKeyExists(form, "free")) {

            form.free = 1;
            form.test_days = 0;

            // Set all prices to 0
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    moduleID: {type: "numeric", value: form.edit_module}
                },
                sql = "
                    UPDATE modules_prices
                    SET decPriceMonthly = 0,
                        decPriceYearly = 0,
                        decPriceOneTime = 0,
                        decVat = 0,
                        intVatType = 1,
                        blnIsNet = 1
                    WHERE intModuleID = :moduleID
                "
            )

        } else {

            form.free = 0;

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
                modulePath: {type: "varchar", value: mapping},
                free: {type: "boolean", value: form.free},
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
                    strSettingPath = :modulePath,
                    blnFree = :free
                WHERE intModuleID = :moduleID

            "
        )

        // Create the folder specified
        createFolderSuccess = true;
        if (!directoryExists(expandPath('/backend/modules/#form.prefix#'))) {
            try {
                directoryCreate(expandPath('/backend/modules/#form.prefix#'));
            } catch (any e) {
                createFolderSuccess = false;
                getAlert('Could not create the folder!');
            }
        }


        // Create the file for the navigation (the savecontent must be completely to the left, otherwise we have spaces...)
        createFileSuccess = true;
        if (!fileExists(expandPath('/backend/modules/#form.prefix#/navigation.cfm'))) {
savecontent variable="naviContent" {
writeOutput("
<a href='' class='dropdown-item'>Your page 1</a>
<a href='' class='dropdown-item'>Your page 2</a>
<a href='' class='dropdown-item'>Your page 3</a>
");
}
            try {
                fileWrite(expandPath('/backend/modules/#form.prefix#/navigation.cfm'), naviContent);
            } catch (any e) {
                createFileSuccess = false;
                getAlert(e.message, 'danger');
            }
        }


        // Create the file for settings
        createSettingFileSuccess = true;
        if (!fileExists(expandPath('/backend/modules/#form.prefix#/settings.cfm'))) {
savecontent variable="settingContent" {
writeOutput("
<cfscript>
dump('Hello settings!');
</cfscript>
");
}
            try {
                fileWrite(expandPath('/backend/modules/#form.prefix#/settings.cfm'), settingContent);
            } catch (any e) {
                createSettingFileSuccess = false;
                getAlert(e.message, 'danger');
            }
        }

        // Create the file for the login inlude
        createLoginFileSuccess = true;
        if (!fileExists(expandPath('/backend/modules/#form.prefix#/login_include.cfm'))) {
savecontent variable="loginContent" {
writeOutput("<!--- This file will be included while users login --->");
}
            try {
                fileWrite(expandPath('/backend/modules/#form.prefix#/login_include.cfm'), loginContent);
            } catch (any e) {
                createLoginFileSuccess = false;
                getAlert(e.message, 'danger');
            }
        }

        if (picSuccess and createFolderSuccess and createSettingFileSuccess and createLoginFileSuccess) {
            getAlert('Module saved.');
        }

        // Refresh the session in order to see the changes
        checkModules = new backend.core.com.modules(language=session.lng).getBookedModules(session.customer_id);
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

            // Delete picture using a function
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

            // Delete picture using a function
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


if (structKeyExists(form, "new_scheduletask")) {

    if (isNumeric(form.new_scheduletask)) {

        scheduleTime = createDateTime(
            dateFormat(form.start_date, 'yyyy'),
            dateFormat(form.start_date, 'mm'),
            dateFormat(form.start_date, 'dd'),
            timeFormat(form.start_time, 'HH'),
            timeFormat(form.start_time, 'MM'),
            timeFormat(form.start_time, 'SS'));

        startDateTime = new backend.core.com.time(session.customer_id).local2utc(givenDate=scheduleTime);

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                task_name: {type: "nvarchar", value: form.schedule_name},
                moduleID: {type: "numeric", value: form.new_scheduletask},
                starttime: {type: "datetime", value: startDateTime},
                task_path: {type: "nvarchar", value: form.path},
                it_minute: {type: "numeric", value: form.iteration}
            },
            sql = "
                INSERT INTO scheduletasks (strName, intModuleID, dtmStartTime, strPath, intIterationMinutes, blnActive)
                VALUES (:task_name, :moduleID, :starttime, :task_path, :it_minute, 1)
            "
        )

        // In case there are bookings already
        qGetBookings = queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: form.new_scheduletask}
            },
            sql = "
                SELECT intModuleID, intCustomerID, strStatus
                FROM bookings
                WHERE intModuleID = :moduleID
            "
        )

        if (qGetBookings.recordCount) {
            objModule = new backend.core.com.modules();
            loop query="qGetBookings" {
                objModule.distributeScheduler(moduleID=qGetBookings.intModuleID, customerID=qGetBookings.intCustomerID, status=qGetBookings.strStatus);
            }
        }

        getAlert('Scheduletask added and activated for all bookings (if any).');
        location url="#application.mainURL#/sysadmin/modules/edit/#form.new_scheduletask#?tab=scheduletasks" addtoken="false";

    }

}


if (structKeyExists(form, "edit_scheduletask")) {

    if (isNumeric(form.edit_scheduletask)) {

        param name="url.moduleID" default="0" type="numeric";

        if (structKeyExists(url, "overview")) {

            Activated = structKeyExists(form, "active") ? 1 : 0;

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    taskID: {type: "numeric", value: form.edit_scheduletask},
                    isAcive: {type: "boolean", value: Activated}
                },
                sql = "
                    UPDATE scheduletasks
                    SET blnActive = :isAcive
                    WHERE intScheduletaskID = :taskID
                "
            )

            if (Activated) {
                getAlert('Scheduletask activated.');
            } else {
                getAlert('Scheduletask stopped.');
            }

            location url="#application.mainURL#/sysadmin/modules/edit/#url.moduleID#?tab=scheduletasks" addtoken="false";


        } else {

            scheduleTime = createDateTime(
                dateFormat(form.start_date, 'yyyy'),
                dateFormat(form.start_date, 'mm'),
                dateFormat(form.start_date, 'dd'),
                timeFormat(form.start_time, 'HH'),
                timeFormat(form.start_time, 'MM'),
                timeFormat(form.start_time, 'SS'));

            startDateTime = new backend.core.com.time(session.customer_id).local2utc(givenDate=scheduleTime);

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    task_name: {type: "nvarchar", value: form.schedule_name},
                    taskID: {type: "numeric", value: form.edit_scheduletask},
                    starttime: {type: "datetime", value: startDateTime},
                    task_path: {type: "nvarchar", value: form.path},
                    it_minute: {type: "numeric", value: form.iteration}
                },
                sql = "
                    UPDATE scheduletasks
                    SET strName = :task_name,
                        dtmStartTime = :starttime,
                        strPath = :task_path,
                        intIterationMinutes = :it_minute
                    WHERE intScheduletaskID = :taskID
                "
            )

            // Set LastRun to NULL
            loop from="1" to="20" index="i" {
                if (i lt 10) {
                    i = "0" & i;
                }
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        taskID: {type: "numeric", value: form.edit_scheduletask}
                    },
                    sql = "
                        UPDATE scheduler_#i#
                        SET dtmLastRun = NULL
                        WHERE intScheduletaskID = :taskID
                    "
                )
            }

            // Update scheduler
            objModule = new backend.core.com.modules();
            objModule.distributeScheduler(moduleID=url.moduleID, customerID=0, status="active");

            getAlert('Scheduletask saved.');
            location url="#application.mainURL#/sysadmin/modules/edit/#url.moduleID#?tab=scheduletasks" addtoken="false";

        }

    }

}


if (structKeyExists(url, "delete_scheduletask")) {

    if (isNumeric(url.delete_scheduletask)) {

        param name="url.moduleID" default="0" type="numeric";

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                taskID: {type: "numeric", value: url.delete_scheduletask}
            },
            sql = "
                DELETE FROM scheduletasks
                WHERE intScheduletaskID = :taskID
            "
        )

        // Delete all scheduletask entries
        loop from="1" to="20" index="i" {
            if (i lt 10) {
                i = "0" & i;
            }
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    taskID: {type: "numeric", value: url.delete_scheduletask}
                },
                sql = "
                    DELETE FROM scheduler_#i#
                    WHERE intScheduletaskID = :taskID
                "
            )
        }


        getAlert('Scheduletask deleted.');
        location url="#application.mainURL#/sysadmin/modules/edit/#url.moduleID#?tab=scheduletasks" addtoken="false";

    }

}






// ---- Edit booked modules or book via sysadmin

if (structKeyExists(url, "booking")) {

    param name="url.b" default=0;
    param name="url.c" default=0;
    param name="url.m" default=0;
    param name="url.r" default="";

    // Get some customer data
    customerData = application.objCustomer.getCustomerData(url.c);
    custLanguage = customerData.language;
    custCurrency = customerData.currencyStruct.iso;
    custCurrencyID = customerData.currencyStruct.id;


    // Edit a booked period
    if (structKeyExists(url, "period")) {

        bookingStruct = structNew();
        bookingStruct['bookingID'] = url.b;

        bookingStruct['dateStart'] = form.start_date;
        if (dateFormat(form.end_date, "yyyy-mm-dd") >= dateFormat(form.start_date, "yyyy-mm-dd")) {
            bookingStruct['dateEnd'] = form.end_date;
        }

        updateBooking = new backend.core.com.book('module', custLanguage).updateBooking(bookingStruct);

        getAlert('Module period saved.');
        location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";

    }


    // Cancel a booked module
    if (structKeyExists(url, "cancel")) {

        // Cancel module
        cancelModule = new backend.core.com.cancel(customerID=url.c, thisID=url.m, what='module').cancel();

        if (cancelModule.success) {
            getAlert('Module canceled. The schedule task will do the rest.');
        } else {
            getAlert(cancelModule.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";

    }


    // Revoke cancellation
    if (structKeyExists(url, "revoke")) {

        // Cancel module
        revoke = new backend.core.com.cancel(customerID=url.c, thisID=url.m, what='module').revoke();

        if (revoke.success) {
            getAlert('Cancellation revoked. Please do not forget to reset the expiry date!', 'info');
        } else {
            getAlert(revoke.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";

    }


    // Book module right now (for free)
    if (structKeyExists(url, "free")) {

        // Get module infos of the module to be booked
        moduleDetails = new backend.core.com.modules(language=custLanguage, currencyID=custCurrencyID).getModuleData(url.m);

        structUpdate(moduleDetails, "priceMonthly", 0);
        structUpdate(moduleDetails, "priceMonthlyAfterVAT", 0);
        structUpdate(moduleDetails, "priceYearly", 0);
        structUpdate(moduleDetails, "priceYearlyAfterVAT", 0);
        structUpdate(moduleDetails, "priceOnetime", 0);
        structUpdate(moduleDetails, "priceOneTimeAfterVAT", 0);
        structUpdate(moduleDetails, "testDays", 0);

        // Make booking right now
        makeBooking = new backend.core.com.book('module', custLanguage).checkBooking(customerID=url.c, bookingData=moduleDetails, recurring='onetime', makeBooking=true);

        if (makeBooking.success) {
            getAlert('Module activated for free.');
        } else {
            getAlert(makeBooking.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";

    }


    // Make invoice which the client can then pay to activate the module
    if (structKeyExists(url, "invoice")) {

        // Get module infos of the module to be booked
        moduleDetails = new backend.core.com.modules(language=custLanguage, currencyID=custCurrencyID).getModuleData(url.m);

        // Set the test days to 0 in order to make the invoice immediately
        structUpdate(moduleDetails, "testDays", 0);

        // Make booking and invoice right now
        makeBooking = new backend.core.com.book('module', custLanguage).checkBooking(customerID=url.c, bookingData=moduleDetails, recurring=url.r, makeBooking=true, makeInvoice=true, chargeInvoice=false);

        if (makeBooking.success) {
            getAlert('The invoice was successfully created. You can now make changes if you wish. If all is well, you can send it to the customer by clicking on the email button.');
            session.comingfrom = "sysadmin_modules";
            location url="#application.mainURL#/sysadmin/invoice/edit/#makeBooking.invoiceID#" addtoken="false";
        } else {
            getAlert(makeBooking.message, 'danger');
            location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";
        }

    }


    // Activate the test time
    if (structKeyExists(url, "test")) {

        // Get module infos of the module to be booked
        moduleDetails = new backend.core.com.modules(language=custLanguage, currencyID=custCurrencyID).getModuleData(url.m);

        // Make booking with test phase
        makeBooking = new backend.core.com.book('module', custLanguage).checkBooking(customerID=url.c, bookingData=moduleDetails, recurring=url.r, makeBooking=true, makeInvoice=false, chargeInvoice=false);

        if (makeBooking.success) {
            getAlert('The module has been successfully activated.');
        } else {
            getAlert(makeBooking.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";


    }


    // Change the cycle of a module
    if (structKeyExists(url, "change")) {

        // Get module infos of the module to be booked
        moduleDetails = new backend.core.com.modules(language=custLanguage, currencyID=custCurrencyID).getModuleData(url.m);

        objBooking = new backend.core.com.book('module', custLanguage);

        // Check booking
        checkBooking = objBooking.checkBooking(customerID=url.c, bookingData=moduleDetails, recurring=url.r, makeBooking=false);


        // If the amount to pay is greater than 0, make invoice
        if (checkBooking.amountToPay gt 0) {

            // Make booking and invoice right now
            makeBooking = objBooking.checkBooking(customerID=url.c, bookingData=moduleDetails, recurring=url.r, makeBooking=true, makeInvoice=true, chargeInvoice=false);

        } else {

            // Save the new module
            makeBooking = objBooking.checkBooking(customerID=url.c, bookingData=moduleDetails, recurring=url.r, makeBooking=true, makeInvoice=false, chargeInvoice=false);

        }

        if (makeBooking.success) {
            getAlert('The cycle was changed.');
        } else {
            getAlert(makeBooking.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";


    }


    // Delete the module (the booking)
    if (structKeyExists(url, "delete")) {

        deleteModule = new backend.core.com.cancel(customerID=url.c, thisID=url.m, what='module').delete(url.b, url.m, url.c);

        getAlert('The module was withdrawn from the customer.');

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###modules" addtoken="false";


    }




}


location url="#application.mainURL#/dashboard" addtoken="false";


</cfscript>