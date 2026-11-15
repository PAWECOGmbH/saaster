
component displayname="Application" output="false" extends="backend.myapp.ownApplication" {

    // Datasource and custom variables
    include template="config.cfm";

    // Dynamic values
    this.name = variables.applicationname;
    this.sessiontimeout = variables.sessiontimeout;
    // Lucee 7 ships the "classic" engine (PD4ML) only as demo with a watermark on every page,
    // so the PDF templates (invoices, Swiss QR-bill) are made for "modern". variables.pdf_type
    // in older config.cfm files is ignored.
    this.pdf.type = "modern";
    this.requesttimeout = variables.requesttimeout;

    // Fixed values
    this.sessionmanagement = true;
    this.setdomaincookies = true;

    // Session cookie: never readable by JavaScript, not sent along with cross-site requests, and
    // only sent over HTTPS when the application runs on HTTPS (mainURL in config.cfm). Locally on
    // http the Secure flag would stop the browser from sending the cookie at all.
    this.sessionCookie = {
        httpOnly: true,
        sameSite: "lax",
        secure: left(lCase(trim(variables.mainURL)), 8) eq "https://"
    };
    this.processingdirective.pageEncoding = "utf-8";
    this.mappings["/"] = getDirectoryFromPath(getCurrentTemplatePath());
    this.timezone = "UTC+00:00"; // Do NOT change the standard timezone!!!

    // Load java files
    this.javaSettings = {
        loadPaths = [expandPath("/assets/java")],
        reloadOnChange = false
    };


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
        application.activeTheme = variables.activeTheme;

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
        application.objAccessRegistry = new backend.core.com.access_registry().load();
        application.objAuthorization = new backend.core.com.authorization();
        application.objMembership = new backend.core.com.membership();
        application.objOrganizationInvitation = new backend.core.com.organization_invitation();
        application.objMembershipMigration = new backend.core.com.membership_migration();
        application.objMembershipAccess = new backend.core.com.membership_access();
        application.objRequestAccess = new backend.core.com.request_access();
        application.objCustomer = new backend.core.com.customer();
        application.objLayout = new backend.core.com.layout();
        application.objNotifications = new backend.core.com.notifications();
        application.objSysadmin = new backend.core.com.sysadmin();
        application.objMeta = new backend.core.com.meta();
        application.objModules = new backend.core.com.modules();
        application.objModuleBlocks = new backend.core.com.module_blocks();
        application.objCoreUtil = new frontend.core.com.coreutility();

        // Save all choosable languages into a list
        local.qLanguages = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT CONCAT(LOWER(strLanguageISO), '|', strLanguage) as lang
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

        // Load JS and CSS path
        application.assetFiles = application.objCoreUtil.getAssets(variables.activeTheme);

        ownApplicationStart();

        return true;

    }


    public void function onSessionStart() {

        // Check browser language
        local.browserLng = application.objLanguage.getBrowserLng(cgi.http_accept_language).lng;

        // Check whether the language is active in project
        local.checkLng = findNoCase(local.browserLng, application.allLanguages);

        // Save the language into the session
        session.lng = lCase(local.checkLng ? local.browserLng : application.objLanguage.getDefaultLanguage().iso);

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

        // Revalidate membership before routing, including existing sessions.
        local.supportReturn = (session.supportLogin ?: false) and structKeyExists(url, "sysadmin") and reFindNoCase("^/?customer/?$", cgi.path_info);
        lock scope="session" type="exclusive" timeout="60" {
            if (structKeyExists(application, "objMembershipAccess") and not local.supportReturn and not application.objMembershipAccess.refreshSession()) {
                location url=application.objGlobal.getLink("templates/login.cfm") addtoken=false;
            }
        }

        // Check if the user is logged in as a sysadmin
        if (structKeyExists(session, "sysadmin") and session.sysadmin) {

            // Reinit Application
            if (structKeyExists(url, "reinit") and url.reinit eq 1) {
                structClear(APPLICATION);
                onApplicationStart();
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

            // Reinit Session and Application
            if (structKeyExists(url, "reinit") and url.reinit eq 4) {
                structClear(SESSION);
                structClear(APPLICATION);
                onApplicationStart();
                onSessionStart();
            }

        } else if (structKeyExists(url, "reinit")) {

            // Only a logged-in sysadmin may reinit - say so instead of silently ignoring it
            local.reinitIP = new backend.core.com.loginthrottle().clientIP();
            application.objLog.logWrite("system", "warning", "Unauthorized reinit attempt [IP: #local.reinitIP#, Path: #cgi.script_name#]", false);
            writeOutput("Unauthorized reinit attempt by IP " & encodeForHTML(local.reinitIP) & ". Log in as sysadmin to reinitialize the application.");
            structDelete(url, "reinit");
            abort;

        }


        // Set the locale of the browser
        local.browserLocale = application.objLanguage.getBrowserLng(cgi.http_accept_language).code;

        // Set customers locale using his browser
        try {
            setLocale(application.objLanguage.toLocale(language=local.browserLocale));
        } catch (any e) {
            setLocale("english (united states)");
        }

        // Custom code
        ownRequestStart();

        return true;

    }


    public boolean function onRequest(required string TargetPage) {
        // Serialize context switches and mutations from tabs sharing this session.
        lock scope="session" type="exclusive" timeout="60" {
            local.supportReturn = (session.supportLogin ?: false) and structKeyExists(url, "sysadmin") and reFindNoCase("^/?customer/?$", cgi.path_info);
            if (not local.supportReturn and not application.objMembershipAccess.refreshSession()) {
                location url=application.objGlobal.getLink("templates/login.cfm") addtoken=false;
            }
            return dispatchRequest(arguments.TargetPage);
        }
    }

    private boolean function dispatchRequest(required string TargetPage) {

        local.route = application.objRequestAccess.resolve(arguments.TargetPage, replace(cgi.path_info, "/", "", "one"), cgi.request_method);
        thiscontent = local.route.content;
        enforceAccess(local.route.decision);
        local.headers = getHTTPRequestData(false).headers;
        enforceAccess(application.objRequestAccess.checkContext(thiscontent, cgi.request_method, form, url, local.headers));

        // Change language
        if (structKeyExists(url, "l") and session.lng neq url.l) {
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
        csrfToken = application.objGlobal.csrfToken;
        csrfField = application.objGlobal.csrfField;
        csrfParam = application.objGlobal.csrfParam;


        // Is there a redirect coming in url?
        if (structKeyExists(url, "redirect")) {
            session.redirect = application.mainURL & "/" & url.redirect;
        } else if (structKeyExists(url, "del_redirect")) {
            structDelete(session, "redirect");
        }


        enforceAccess(application.objRequestAccess.checkPage(thiscontent, cgi.request_method, url));
        // Payrexx authenticates webhook POSTs with its URL secret, not a browser CSRF token.
        local.authenticatedPayrexxWebhook = thiscontent.thisPath eq "frontend/core/handler/payrexx_webhook.cfm"
            and cgi.request_method eq "POST"
            and len(trim(variables.payrexxWebhookPassword)) gt 0
            and structKeyExists(url, "pass")
            and url.pass eq variables.payrexxWebhookPassword;
        if (not local.authenticatedPayrexxWebhook) {
            enforceAccess(application.objRequestAccess.checkCsrf(thiscontent, cgi.request_method, url, local.headers));
        }

        local.operation = "";
        if (left(thiscontent.thisPath, 8) eq "backend/" and structKeyExists(session, "customer_id")) {
            local.operation = new backend.core.com.account_lifecycle().beginOperation(session.customer_id, "request");
            if (!len(local.operation)) {
                enforceAccess({access:false, reason:"accountDeletion", statusCode:403, statusText:"Forbidden", messageKey:"msgAccountDeletionPending"});
            }
            request.accountOperation = local.operation;
        }
        try {
            // More global variables (with customer session).
            if (structKeyExists(session, "customer_id")) {
                getTime = new backend.core.com.time(session.customer_id);
                getCustomerData = application.objCustomer.getCustomerData(session.customer_id);
            }

            // Custom code
            ownRequest();

            include template="\#ARGUMENTS.TargetPage#";
            return true;
        } finally {
            if (len(local.operation)) new backend.core.com.account_lifecycle().finishOperation(local.operation);
            structDelete(request, "accountOperation");
        }

    }

    // Apply the shared policy's decision without duplicating its access rules.
    private void function enforceAccess(required struct decision) {
        if (arguments.decision.access) {
            return;
        }
        if ((arguments.decision.reason ?: "") eq "csrf") {
            application.objLog.logWrite("system", "warning", "CSRF token missing or invalid [Path: #thiscontent.thisPath#, Method: #cgi.request_method#, IP: #cgi.remote_addr#]");
        }
        if (structKeyExists(arguments.decision, "alertKey")) {
            application.objGlobal.getAlert(arguments.decision.alertKey, arguments.decision.alertType);
        }
        if (structKeyExists(arguments.decision, "redirect")) {
            location url=application.mainURL & arguments.decision.redirect addtoken=false;
        }
        header statuscode=arguments.decision.statusCode statustext=arguments.decision.statusText;
        writeOutput(encodeForHTML(structKeyExists(arguments.decision, "messageKey")
            ? application.objLanguage.getTrans(arguments.decision.messageKey) : (arguments.decision.message ?: "")));
        abort;
    }

    public void function onError(struct exception, string eventName) {

        if (application.environment eq "dev") {

            dump(arguments.exception);
            abort;

        } else {

            // Send email with error, but only if its not of type missinginclude (bots)
            local.errPath = "/frontend/" & variables.activeTheme & "/templates/error/";
            if (arguments.exception.type eq "missinginclude") {
                location url=local.errPath & "404.cfm" addtoken="false";
            } else {
                mail to="#application.errorMail#" from="#application.fromEmail#" subject="ERROR - #application.projectName#" type="html" {
                    writeOutput(arguments.exception);
                }
                location url=local.errPath & "error.cfm" addtoken="false";
            }



        }

    }

}

