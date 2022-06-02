
component displayname="Application" output="false" hint="Handle the application." {

    this.name = "saaster.io";
    this.sessionmanagement = true;
    this.sessiontimeout = CreateTimeSpan(00,03,00,00);
    this.setdomaincookies = true;
    this.pdf.type = "classic";
    this.mappings["/"] = getDirectoryFromPath(getCurrentTemplatePath());
    setting enablecfoutputonly = true;
    setting showdebugoutput = true;
    setting requesttimeout = 60;
    processingdirective pageEncoding="utf-8";

    <!--- onApplicationStart fires when the application is first created --->
    public boolean function onApplicationStart() {


        <!--- ####### APPLICATION SETTINGS -> please update for your project --->
        include template="includes/settings.cfm";

        <!--- Object initialising --->
        application.objGlobal = new com.global();
        application.objUser = new com.user();
        application.objCustomer = new com.customer();

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
        if (local.qLanguages.recordCount) {
            application.allLanguages = ValueList(local.qLanguages.lang);
        }

        <!--- Load language struct and save it into the application scope --->
        application.langStruct = application.objGlobal.initLanguages();

        <!--- Load system setting struct and save it into the application scope
        (hint: the custom variables we save into a session while login) --->
        application.systemSettingStruct = application.objGlobal.initSystemSettings();

        return true;

    }


    public void function onSessionStart() {

        <!--- Check browser language --->
        local.firstString = listFirst(cgi.http_accept_language, ";");
        local.checkLeft = listFirst(firstString, ",");
        if (find("-", local.checkLeft)) {
            local.client_lang = listFirst(local.firstString, ",");
        } else {
            local.client_lang = listLast(local.firstString, ",");
        }
        local.client_lang = replace(listfirst(client_lang), "-", "_", "ALL");

        <!--- Save into the session --->
        session.lng = left(local.client_lang, 2);

        return;

    }


    <!--- onRequestStart fires at first part of page processing --->
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

        <!--- Set locale --->
        if (structKeyExists(session, "user_locale")) {
            setLocale(session.user_locale);
        } else {
            setLocale(getLocale());
        }

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


