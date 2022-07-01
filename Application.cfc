
component displayname="Application" output="false" hint="Handle the application." {

    // Datasource and custom variables
    include template="config.cfm";

    // Dynamic values (table)
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
        application.userTempImg = variables.userTempImg;
        if (variables.devDomain eq cgi.server_name) {
            application.environment = "dev";
            application.usersIP = variables.usersIP;
            application.mainURL = "http://" & variables.devDomain;
        } else {
            application.environment = "prod";
            application.usersIP = cgi.remote_addr;
            application.mainURL = variables.mainURL;
        }

        <!--- Payrexx initialising --->
        local.payrexxStruct = structNew();
        local.payrexxStruct['payrexxAPIurl'] = variables.payrexxAPIurl;
        local.payrexxStruct['payrexxAPIinstance'] = variables.payrexxAPIinstance;
        local.payrexxStruct['payrexxAPIkey'] = variables.payrexxAPIkey;
        application.payrexxStruct = local.payrexxStruct;


        <!--- Object initialising --->
        application.objGlobal = new com.global();
        application.objUser = new com.user();
        application.objCustomer = new com.customer();
        application.objLanguage = new com.language();

        <!--- Save all choosable languages into a list --->
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

        <!--- Load language struct and save it into the application scope --->
        application.langStruct = application.objGlobal.initLanguages();

        <!--- Load system setting struct and save it into the application scope
        (hint: the custom variables we save into a session while login) --->
        application.systemSettingStruct = application.objGlobal.initSystemSettings();

        return true;

    }


    public void function onSessionStart() {

        <!--- Check browser language --->
        local.browserLng = application.objLanguage.getBrowserLng(cgi.http_accept_language).lng;

        <!--- Check whether the language is active in project --->
        local.checkLng = findNoCase(local.browserLng, application.allLanguages);

        <!--- Save the language into the session --->
        session.lng = local.checkLng ? local.browserLng : application.objGlobal.getDefaultLanguage().iso;

        return;

    }



    public boolean function onRequestStart(required string TargetPage) {

        <!--- Reinit Application --->
        if (structKeyExists(url, "reinit") and url.reinit eq 1) {
            structClear(APPLICATION);
            onApplicationStart();
            application.langStruct = application.objGlobal.initLanguages();
        }

        <!--- Reinit Session --->
        if (structKeyExists(url, "reinit") and url.reinit eq 2) {
            structClear(SESSION);
            onSessionStart();
        }

        <!--- Reinit languages --->
        if (structKeyExists(url, "reinit") and url.reinit eq 3) {
            structDelete(session, "langStruct");
            application.langStruct = application.objGlobal.initLanguages();
        }

        <!--- Reinit Session AND Application AND languages --->
        if (structKeyExists(url, "reinit") and url.reinit eq 4) {
            structClear(SESSION);
            structClear(APPLICATION);
            onApplicationStart();
            onSessionStart();
            application.langStruct = application.objGlobal.initLanguages();
        }


        <!--- Set the locale of the browser --->
        local.browserLocale = application.objLanguage.getBrowserLng(cgi.http_accept_language).code;

        <!--- Set customers locale using his browser --->
        setLocale(application.objLanguage.toLocale(language=local.browserLocale));

        return true;

    }


    public boolean function onRequest(required string TargetPage) {

        <!--- Create SEF URL --->
        thiscontent = application.objGlobal.getSEF(replace(cgi.path_info,'/','','one'));

        <!--- Change language --->
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
                application.langStruct = application.objGlobal.initLanguages();
            }

        }


        <!--- Global variables --->
        getTrans = application.objGlobal.getTrans;
        getAlert = application.objGlobal.getAlert;
        getLanguage = application.objGlobal.getDefaultLanguage();
        getAnyLanguage = application.objGlobal.getAnyLanguage;

        <!--- Is there a redirect coming in url? --->
        if (structKeyExists(url, "redirect")) {
            session.redirect = application.mainURL & "/" & url.redirect;
        }

        <!--- If there is no session, send to login --->
        if (!findNoCase("setup", cgi.script_name)
            and !findNoCase("frontend", thiscontent.thisPath)
            and !findNoCase("register", thiscontent.thisPath)
            and !findNoCase("ajax", thiscontent.thisPath)
            and !structKeyExists(url, "u") and !structKeyExists(url, "p")) {
            if (!structKeyExists(session, "user_id")) {
                getAlert('alertSessionExpired', 'warning');
                location url="#application.mainURL#/login" addtoken="false";
            }
        }


        <!--- Check whether the user has access to corresponding sections --->
        if (structKeyExists(session, "user_id")) {

            // Init the time.cfc (its here because we need a user session)
            application.getTime = new com.time(session.customer_id);

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

        }


        include template="\#ARGUMENTS.TargetPage#";
        return true;

    }


    setting enablecfoutputonly = false;

}


