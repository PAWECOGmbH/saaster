
component displayname="Application" output="false" extends="backend.myapp.ownApplication" {

    // Datasource and custom variables
    include template="config.cfm";

    // Dynamic values
    this.name = variables.applicationname;
    this.sessiontimeout = variables.sessiontimeout;
    this.pdf.type = variables.pdf_type;
    setting requesttimeout = variables.requesttimeout;

    // Fixed values
    this.sessionmanagement = true;
    this.setdomaincookies = true;
    processingdirective pageEncoding="utf-8";
    this.mappings["/"] = getDirectoryFromPath(getCurrentTemplatePath());
    setTimezone("UTC+00:00"); // Do NOT change the standard timezone!!!


    public boolean function onApplicationStart() {

        application.datasource = variables.datasource;

        // Dynamic values
        application.projectName = variables.appName;
        application.appOwner = variables.appOwner;
        application.fromEmail = variables.fromEmail;
        application.toEmail = variables.toEmail;
        application.errorMail = variables.errorEmail;
        application.mainURL = variables.mainURL;
        application.environment = variables.environment;

        // Payrexx initialising
        local.payrexxStruct = structNew();
        local.payrexxStruct['payrexxAPIurl'] = variables.payrexxAPIurl;
        local.payrexxStruct['payrexxAPIinstance'] = variables.payrexxAPIinstance;
        local.payrexxStruct['payrexxAPIkey'] = variables.payrexxAPIkey;
        application.payrexxStruct = local.payrexxStruct;

        // Object initialising
        application.objLog = new backend.core.com.log();
        application.objGlobal = new backend.core.com.global();
        application.objLanguage = new backend.core.com.language();
        application.objSettings = new backend.core.com.settings();
        application.objUser = new backend.core.com.user();
        application.objCustomer = new backend.core.com.customer();
        application.objLayout = new backend.core.com.layout();
        application.objNotifications = new backend.core.com.notifications();
        application.objSysadmin = new backend.core.com.sysadmin();
        application.objMeta = new backend.core.com.meta();

        // Save all choosable languages into a list
        local.qLanguages = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT CONCAT(strLanguageISO, '|', strLanguage) as lang
                FROM languages
                WHERE blnChooseable = 1
                ORDER BY intPrio
            "
        )
        application.allLanguages = ValueList(local.qLanguages.lang);

        // Load language struct and save it into the application scope
        application.langStruct = application.objLanguage.initLanguages();

        // Load system setting struct and save it into the application scope
        application.systemSettingStruct = application.objSettings.initSystemSettings();

        // Load layout setting struct and save it into the application scope
        application.layoutStruct = application.objLayout.layoutSetting(application.systemSettingStruct.settingLayout);

        ownApplicationStart();

        return true;

    }


    public void function onSessionStart() {

        // Check browser language
        local.browserLng = application.objLanguage.getBrowserLng(cgi.http_accept_language).lng;

        // Check whether the language is active in project
        local.checkLng = findNoCase(local.browserLng, application.allLanguages);

        // Save the language into the session
        session.lng = local.checkLng ? local.browserLng : application.objLanguage.getDefaultLanguage().iso;

        if (application.environment eq "dev") {
            session.usersIP = variables.usersIP;
        } else {
            session.usersIP = cgi.remote_addr;
        }

        // Custom code
        ownSessionStart();

        return;

    }



    public boolean function onRequestStart(required string TargetPage) {

        // Reinit Application
        if (structKeyExists(url, "reinit") and url.reinit eq 1) {
            structClear(APPLICATION);
            onApplicationStart();
            application.langStruct = application.objLanguage.initLanguages();
        }

        // Reinit Session
        if (structKeyExists(url, "reinit") and url.reinit eq 2) {
            structClear(SESSION);
            onSessionStart();
        }

        // Reinit languages
        if (structKeyExists(url, "reinit") and url.reinit eq 3) {
            structDelete(session, "langStruct");
            application.langStruct = application.objLanguage.initLanguages();
        }

        // Reinit Session AND Application AND languages
        if (structKeyExists(url, "reinit") and url.reinit eq 4) {
            structClear(SESSION);
            structClear(APPLICATION);
            onApplicationStart();
            onSessionStart();
            application.langStruct = application.objLanguage.initLanguages();
        }


        // Set the locale of the browser
        local.browserLocale = application.objLanguage.getBrowserLng(cgi.http_accept_language).code;

        // Set customers locale using his browser
        setLocale(application.objLanguage.toLocale(language=local.browserLocale));

        // Custom code
        ownRequestStart();

        return true;

    }


    public boolean function onRequest(required string TargetPage) {

        // Create SEF URL
        thiscontent = application.objGlobal.getSEF(replace(cgi.path_info,'/','','one'));

        // Change language
        if (structKeyExists(url, "l")) {
            qCheckLanguage = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    thisLng: {type: "nvarchar", value: url.l}
                },
                sql = "
                    SELECT COUNT(*) as cnt
                    FROM languages
                    WHERE strLanguageISO = :thisLng
                "
            )
            if (qCheckLanguage.cnt gt 0) {
                session.lng = url.l;
                application.langStruct = application.objLanguage.initLanguages();
                if (structKeyExists(session, "customer_id")) {
                    application.objCustomer.setProductSessions(session.customer_id, session.lng);
                }
            }

        }


        // Global variables
        getTrans = application.objLanguage.getTrans;
        getAlert = application.objGlobal.getAlert;
        getLayout = application.layoutStruct;
        logWrite = application.objLog.logWrite;
        getMeta = application.objMeta.getMeta;


        // Is there a redirect coming in url?
        if (structKeyExists(url, "redirect")) {
            session.redirect = application.mainURL & "/" & url.redirect;
        } else if (structKeyExists(url, "del_redirect")) {
            structDelete(session, "redirect");
        }


        // Check whether the user has access to corresponding sections
        if (structKeyExists(session, "customer_id")) {

            // More global variables (with customer session)
            getTime = new backend.core.com.time(session.customer_id);
            getCustomerData = application.objCustomer.getCustomerData(session.customer_id);

            local.no_access = false;

            if (thiscontent.noaccess) {

                local.no_access = true;

            } else {

                if (structKeyExists(session, "admin") and !session.admin) {
                    if (thiscontent.onlyAdmin) {
                        getAlert('msgNoAccess', 'danger');
                        local.no_access = true;
                    }
                }
                if (structKeyExists(session, "superadmin") and !session.superadmin) {
                    if (thiscontent.onlySuperAdmin) {
                        getAlert('msgNoAccess', 'danger');
                        local.no_access = true;
                    }
                }
                if (structKeyExists(session, "sysadmin") and !session.sysadmin) {
                    if (thiscontent.onlySysAdmin) {
                        getAlert('msgNoAccess', 'danger');
                        local.no_access = true;
                    }
                }

            }

            if (local.no_access) {
                location url="#application.mainURL#/dashboard" addtoken="false";
            }

        } else {

            // Protect the 'backend' folder excluding the pdf print page
            if (listFirst(thiscontent.thisPath, "/") eq "backend" and !structKeyExists(session, "user_id")) {
                if (structKeyExists(url, "pdf")) {
                    location url="#application.mainURL#/backend/core/views/invoices/print.cfm?pdf=#url.pdf#" addtoken="false";
                } else {
                    getAlert('alertSessionExpired', 'warning');
                    location url="#application.mainURL#/login" addtoken="false";
                }
            }


            // If someone is trying to call a .cfm file directly
            if (thiscontent.noaccess) {
                location url="#application.mainURL#" addtoken="false";
            }

        }

        // Custom code
        ownRequest();

        include template="\#ARGUMENTS.TargetPage#";
        return true;

    }

    public void function onError(struct exception, string eventName) {

        if (application.environment eq "dev") {

            writeOutput(arguments.exception);

        } else {

            // Send email with error
            mail to="#application.errorMail#" from="#application.fromEmail#" subject="ERROR - #application.projectName#" type="html" {
                writeOutput("<h2>An error occured!</h2>");
                writeOutput(arguments.exception);
            }

            location url="/error.cfm" addtoken="false";

        }

    }

    setting enablecfoutputonly = false;

}

