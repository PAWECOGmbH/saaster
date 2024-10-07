component displayname="ads" output="false" extends="backend.myapp.com.init" {

    public query function getLocations() {

        local.qLocations = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM ss_locations
                WHERE blnActive = 1
                ORDER BY strName
            "
        )

        return local.qLocations;

    }

    public query function getContractTypes() {

        local.qTypes = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM ss_contract_types
                WHERE blnActive = 1
                ORDER BY strName
            "
        )

        return local.qTypes;

    }

    public query function getIndustries() {

        local.qIndustries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM ss_industries
                WHERE blnActive = 1
                AND blnProposal = 0
                ORDER BY strName
            "
        )

        return local.qIndustries;

    }

    public query function getJobPositions() {

        local.qPositions = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM ss_job_positions
                WHERE blnActive = 1
                ORDER BY strName
            "
        )

        return local.qPositions;

    }

    public query function getAds(numeric customerID, string where="") {

        local.customer;

        if (structKeyExists(arguments, "customerID")) {
            local.customer = "AND intCustomerID = " & arguments.customerID;
        }

        local.qAds = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *,
                (
                    SELECT COUNT(intApplicationID)
                    FROM ss_applications
                    WHERE intAdID = ss_ads.intAdID
                ) as applications,
                CASE
                    WHEN dteStart IS NULL AND blnActive = 0 THEN 'Entwurf'
                    WHEN blnActive = 0 THEN 'Deaktiviert'
                    WHEN dteStart IS NOT NULL AND blnPaused = 1 THEN 'Pausiert'
                    WHEN dteEnd IS NOT NULL AND blnActive = 1 AND DATE(dteEnd) >= DATE(NOW()) THEN 'Aktiv'
                    WHEN dteEnd IS NOT NULL AND blnActive = 1 AND DATE(dteEnd) < DATE(NOW()) THEN 'Beendet'

                    ELSE ''
                END AS status,
                CASE
                    WHEN dteStart IS NULL AND blnActive = 0 THEN 'secondary'
                    WHEN blnActive = 0 THEN 'red'
                    WHEN dteStart IS NOT NULL AND blnPaused = 1 THEN 'blue'
                    WHEN dteEnd IS NOT NULL AND blnActive = 1 AND DATE(dteEnd) >= DATE(NOW()) THEN 'green'
                    WHEN dteEnd IS NOT NULL AND blnActive = 1 AND DATE(dteEnd) < DATE(NOW()) THEN 'purple'
                    ELSE ''
                END AS class
                FROM ss_ads
                WHERE 1=1
                #local.customer#
                #arguments.where#
                ORDER BY intAdID DESC
            "
        )

        return local.qAds;

    }

    public query function getAdDetails(required numeric adID, required numeric typeID) {

        local.qAdDetail = queryExecute(
            options = {datasource = application.datasource},
            params = {
                adID: {type: "numeric", value: arguments.adID},
                typeID: {type: "numeric", value: arguments.typeID}
            },
            sql = "
                SELECT *,
                (
                    SELECT GROUP_CONCAT(intIndustryID)
                    FROM ss_industries_ads
                    WHERE intAdID = ss_ads.intAdID
                ) as industryIDs,
                (
                    SELECT GROUP_CONCAT(intLocationID)
                    FROM ss_ads_locations
                    WHERE intAdID = ss_ads.intAdID
                ) as locationIDs,
                (
                    SELECT strMapping
                    FROM frontend_mappings
                    WHERE intFrontendMappingsID = ss_ads.intMappingID
                ) as mapping
                FROM ss_ads
                WHERE intAdID = :adID
                AND blnAdTypeID = :typeID
            "
        )

        return local.qAdDetail;

    }

    public struct function newJob(required struct jobData) {

        if (arguments.jobData.typeID eq 1) {
            local.adType = "Inserat";
        } else {
            local.adType = "Jobprofil";
        }

        local.evaluatedData = evalAdData(arguments.jobData);
        if (structKeyExists(local.evaluatedData, "success") and local.evaluatedData.success eq false) {
            return local.evaluatedData;
        }

        try {

            queryExecute(
                options = {datasource = application.datasource, result="local.newAd"},
                params = {
                    customerID: {type: "numeric", value: local.evaluatedData.customerID},
                    userID: {type: "numeric", value: local.evaluatedData.userID},
                    typeID: {type: "numeric", value: arguments.jobData.typeID},
                    title: {type: "nvarchar", value: local.evaluatedData.title},
                    positionID: {type: "numeric", value: local.evaluatedData.positionID},
                    ctypeID: {type: "numeric", value: local.evaluatedData.ctypeID},
                    min: {type: "numeric", value: local.evaluatedData.minWorkload},
                    max: {type: "numeric", value: local.evaluatedData.maxWorkload},
                    jobstarting: {type: "nvarchar", value: local.evaluatedData.jobstarting},
                    description: {type: "nvarchar", value: local.evaluatedData.description},
                    video: {type: "varchar", value: local.evaluatedData.video},
                    application: {type: "boolean", value: local.evaluatedData.application}
                },
                sql = "
                    INSERT INTO ss_ads (
                        strUUID,
                        intCustomerID,
                        intUserID,
                        blnAdTypeID,
                        blnActive,
                        dteStart,
                        dteEnd,
                        strJobTitle,
                        strJobDescription,
                        lngMinWorkload,
                        lngMaxWorkload,
                        intContractTypeID,
                        intJobPositionID,
                        strJobStarting,
                        blnShowApplication,
                        strVideoLink,
                        blnPaused,
                        blnArchived,
                        intInvoiceID,
                        intMappingID
                    )
                    VALUES (
                        UUID(),
                        :customerID,
                        :userID,
                        :typeID,
                        0,
                        NULL,
                        NULL,
                        :title,
                        :description,
                        :min,
                        :max,
                        :ctypeID,
                        :positionID,
                        :jobstarting,
                        :application,
                        :video,
                        0,
                        0,
                        NULL,
                        NULL
                    )
                "
            );

            local.adID = local.newAd.generated_key;

            loop list=local.evaluatedData.industryID index="local.i" {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        industryID: {type: "numeric", value: local.i},
                        adID: {type: "numeric", value: local.adID}
                    },
                    sql = "
                        INSERT INTO ss_industries_ads (intIndustryID, intAdID)
                        VALUES (:industryID, :adID)
                    "
                );
            }

            loop list=local.evaluatedData.locationID index="local.i" {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        adID: {type: "numeric", value: local.adID},
                        locationID: {type: "numeric", value: local.i}
                    },
                    sql = "
                        INSERT INTO ss_ads_locations (intAdID, intLocationID)
                        VALUES (:adID, :locationID)
                    "
                );
            }

            if (arguments.jobData.typeID eq 2) {

                queryExecute(
                    options = {datasource = application.datasource, result="local.newWorker"},
                    params = {
                        userID: {type: "numeric", value: local.evaluatedData.userID},
                        adID: {type: "numeric", value: local.adID}
                    },
                    sql = "
                        INSERT IGNORE INTO ss_worker_profiles (intUserID, intAdID)
                        VALUES (:userID, :adID)
                    "
                );

                if (!local.newWorker.recordCount) {
                    queryExecute(
                        options = {datasource = application.datasource, result="local.newWorker"},
                        params = {
                            userID: {type: "numeric", value: local.evaluatedData.userID},
                            adID: {type: "numeric", value: local.adID}
                        },
                        sql = "
                            UPDATE ss_worker_profiles
                            SET intAdID = :adID
                            WHERE intUserID = :userID
                        "
                    );
                }


            }


            // Insert URL slug
            local.objMapping = new backend.core.com.mappings();
            local.beautyTitle = application.objGlobal.beautifyString(local.evaluatedData.title);

            local.mapping = {};
            local.mapping['createdByApp'] = true;


            if (arguments.jobData.typeID eq 1) {

                local.companyName = application.objCustomer.getCustomerData(local.evaluatedData.customerID).companyName;

                local.urlSlug = "stelle/" & local.beautyTitle & "-" & local.adID;
                local.mapping['path'] = 'frontend/job.cfm';
                local.mapping['metaTitle'] = local.evaluatedData.title & ' bei ' & local.companyName & ' - Stellensuche.ch';
                local.mapping['metaDescription'] = local.companyName & ' hat eine offene Stelle als ' & local.evaluatedData.title & ' ausgeschrieben. Jetzt direkt via Stellensuche.ch bewerben!';

            } else {

                local.urlSlug = "fachkraft/" & local.beautyTitle & "-" & local.adID;
                local.mapping['path'] = 'frontend/profile.cfm';
                local.mapping['metaTitle'] = local.evaluatedData.title & ' - Stellensuche.ch';
                local.mapping['metaDescription'] = 'Gesuchte Stelle als ' & local.evaluatedData.title & ' - Jetzt direkt via Stellensuche.ch Kontakt aufnehmen!';

            }

            local.mapping['mapping'] = local.urlSlug;

            local.newMapping = local.objMapping.newFrontendMapping(local.mapping);

            if (structKeyExists(local.newMapping, "id")) {
                queryExecute(
                    options = {datasource = application.datasource, result="local.newWorker"},
                    params = {
                        mappingID: {type: "numeric", value: local.newMapping.id},
                        adID: {type: "numeric", value: local.adID}
                    },
                    sql = "
                        UPDATE ss_ads
                        SET intMappingID = :mappingID
                        WHERE intAdID = :adID
                    "
                );
            }

            addHistory(local.adID, 'Neues #local.adType# erstellt', local.evaluatedData.customerID, local.evaluatedData.userID);


        } catch (any e) {
            variables.argsReturnValue['message'] = "Das #local.adType# konnte nicht gespeichert werden: " & e.message;
            return variables.argsReturnValue;
        }

        variables.argsReturnValue['message'] = "Das #local.adType# wurde erfolgreich gespeichert.";
        variables.argsReturnValue['success'] = true;
        return variables.argsReturnValue;

    }

    public struct function editJob(required numeric adID, required struct jobData) {

        if (arguments.jobData.typeID eq 1) {
            local.adType = "Inserat";
        } else {
            local.adType = "Jobprofil";
        }

        local.evaluatedData = evalAdData(arguments.jobData);
        if (structKeyExists(local.evaluatedData, "success") and local.evaluatedData.success eq false) {
            return local.evaluatedData;
        }

        try {

            queryExecute(
                options = {datasource = application.datasource, result="local.newAd"},
                params = {
                    adID: {type: "numeric", value: arguments.adID},
                    customerID: {type: "numeric", value: local.evaluatedData.customerID},
                    title: {type: "nvarchar", value: local.evaluatedData.title},
                    positionID: {type: "numeric", value: local.evaluatedData.positionID},
                    ctypeID: {type: "numeric", value: local.evaluatedData.ctypeID},
                    min: {type: "numeric", value: local.evaluatedData.minWorkload},
                    max: {type: "numeric", value: local.evaluatedData.maxWorkload},
                    jobstarting: {type: "nvarchar", value: local.evaluatedData.jobstarting},
                    description: {type: "nvarchar", value: local.evaluatedData.description},
                    video: {type: "varchar", value: local.evaluatedData.video},
                    application: {type: "boolean", value: local.evaluatedData.application}
                },
                sql = "
                    UPDATE ss_ads
                    SET strJobTitle = :title,
                        strJobDescription = :description,
                        lngMinWorkload = :min,
                        lngMaxWorkload = :max,
                        intContractTypeID = :ctypeID,
                        intJobPositionID = :positionID,
                        strJobStarting = :jobstarting,
                        blnShowApplication = :application,
                        strVideoLink = :video
                    WHERE intAdID = :adID
                    AND intCustomerID = :customerID;

                    DELETE FROM ss_industries_ads
                    WHERE intAdID = :adID;

                    DELETE FROM ss_ads_locations
                    WHERE intAdID = :adID;

                "
            );

            loop list=local.evaluatedData.industryID index="local.i" {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        industryID: {type: "numeric", value: local.i},
                        adID: {type: "numeric", value: arguments.adID}
                    },
                    sql = "
                        INSERT INTO ss_industries_ads (intIndustryID, intAdID)
                        VALUES (:industryID, :adID)
                    "
                );
            }

            loop list=local.evaluatedData.locationID index="local.i" {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        adID: {type: "numeric", value: arguments.adID},
                        locationID: {type: "numeric", value: local.i}
                    },
                    sql = "
                        INSERT INTO ss_ads_locations (intAdID, intLocationID)
                        VALUES (:adID, :locationID)
                    "
                );
            }

            // Insert URL slug
            local.objMapping = new backend.core.com.mappings();
            local.beautyTitle = application.objGlobal.beautifyString(local.evaluatedData.title);

            local.mapping = {};
            local.mapping['createdByApp'] = true;


            if (arguments.jobData.typeID eq 1) {

                local.companyName = application.objCustomer.getCustomerData(local.evaluatedData.customerID).companyName;

                local.urlSlug = "stelle/" & local.beautyTitle & "-" & arguments.adID;
                local.mapping['path'] = 'frontend/job.cfm';
                local.mapping['metaTitle'] = local.evaluatedData.title & ' bei ' & local.companyName & ' - Stellensuche.ch';
                local.mapping['metaDescription'] = local.companyName & ' hat eine offene Stelle als ' & local.evaluatedData.title & ' ausgeschrieben. Jetzt direkt via Stellensuche.ch bewerben!';

            } else {

                local.urlSlug = "fachkraft/" & local.beautyTitle & "-" & arguments.adID;
                local.mapping['path'] = 'frontend/profile.cfm';
                local.mapping['metaTitle'] = local.evaluatedData.title & ' - Stellensuche.ch';
                local.mapping['metaDescription'] = 'Gesuchte Stelle als ' & local.evaluatedData.title & ' - Jetzt direkt via Stellensuche.ch Kontakt aufnehmen!';

            }

            local.mapping['mapping'] = local.urlSlug;

            local.objMapping.editFrontendMapping(local.mapping, local.evaluatedData.mappingID);

            addHistory(arguments.adID, '#local.adType# bearbeitet', local.evaluatedData.customerID, local.evaluatedData.userID);


        } catch (any e) {
            variables.argsReturnValue['message'] = "Das #local.adType# konnte nicht gespeichert werden: " & e.message;
            return variables.argsReturnValue;
        }

        variables.argsReturnValue['message'] = "Das #local.adType# wurde erfolgreich gespeichert.";
        variables.argsReturnValue['success'] = true;
        return variables.argsReturnValue;

    }

    private struct function evalAdData(required struct jobData) {

        if (structKeyExists(arguments.jobData, "customerID") and isNumeric(arguments.jobData.customerID)) {
            local.customerID = arguments.jobData.customerID;
        } else {
            variables.argsReturnValue['message'] = "CustomerID is missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "userID") and isNumeric(arguments.jobData.userID)) {
            local.userID = arguments.jobData.userID;
        } else {
            variables.argsReturnValue['message'] = "UserID is missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "title") and len(trim(arguments.jobData.title))) {
            local.title = application.objGlobal.cleanUpText(arguments.jobData.title, 250);
        } else {
            variables.argsReturnValue['message'] = "Job title missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "positionID") and isNumeric(arguments.jobData.positionID)) {
            local.positionID = arguments.jobData.positionID;
        } else {
            variables.argsReturnValue['message'] = "Position is missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "industryID") and listLen(arguments.jobData.industryID)) {
            local.industryID = arguments.jobData.industryID;
        } else {
            variables.argsReturnValue['message'] = "Industry is missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "ctypeID") and isNumeric(arguments.jobData.ctypeID)) {
            local.ctypeID = arguments.jobData.ctypeID;
        } else {
            variables.argsReturnValue['message'] = "Contract type is missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "min") and isNumeric(arguments.jobData.min) and structKeyExists(arguments.jobData, "max") and isNumeric(arguments.jobData.max)) {
            local.minWorkload = arguments.jobData.min;
            local.maxWorkload = arguments.jobData.max;
            if (local.minWorkload gt local.maxWorkload) {
                local.minWorkload = local.maxWorkload;
            }
        } else {
            variables.argsReturnValue['message'] = "Workload is missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "locationID") and listLen(arguments.jobData.locationID)) {
            local.locationID = arguments.jobData.locationID;
        } else {
            variables.argsReturnValue['message'] = "Location is missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "jobstarting") and len(trim(arguments.jobData.jobstarting))) {
            local.jobstarting = application.objGlobal.cleanUpText(arguments.jobData.jobstarting, 100);
        } else {
            variables.argsReturnValue['message'] = "Job starting missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "description") and len(trim(arguments.jobData.description))) {
            local.description = cleanUpTrumbowyg(arguments.jobData.description);
        } else {
            variables.argsReturnValue['message'] = "Description missing!";
            return variables.argsReturnValue;
        }

        if (structKeyExists(arguments.jobData, "video") and len(trim(arguments.jobData.video))) {
            local.video = application.objGlobal.cleanUpText(arguments.jobData.video, 250);
        } else {
            local.video = "";
        }

        if (structKeyExists(arguments.jobData, "application")) {
            local.application = 1;
        } else {
            local.application = 0;
        }

        if (structKeyExists(arguments.jobData, "mappingID")) {
            local.mappingID = arguments.jobData.mappingID;
        } else {
            local.mappingID = 0;
        }

        return local;

    }

    public struct function delAd(required numeric adID, required numeric customerID, required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource, result="delAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "

                DELETE FROM frontend_mappings
                WHERE intFrontendMappingsID =
                (
                    SELECT intMappingID
                    FROM ss_ads
                    WHERE intAdID = :adID
                    AND intCustomerID = :customerID
                );

                DELETE FROM ss_ads
                WHERE intAdID = :adID
                AND intCustomerID = :customerID

            "
        );

        if (delAd.recordCount) {
            variables.argsReturnValue['message'] = "Das Inserat wurde erfolgreich gelöscht.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Es wurde kein Inserat gelöscht!";
        }

        return variables.argsReturnValue;

    }

    public struct function activateAd(required numeric adID, required numeric customerID, required numeric userID, required numeric planID) {

        local.qAd = queryExecute(
            options = {datasource = application.datasource, result="delAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                SELECT *
                FROM ss_ads
                WHERE intAdID = :adID
                AND intCustomerID = :customerID
            "
        );

        if (local.qAd.recordCount) {

            local.objInvoices = new backend.core.com.invoices();

            local.startDate = dateFormat(now(), 'yyyy-mm-dd');
            local.getAdDuring = application.objSettings.getSetting('varAdDuringDays', arguments.planID);

            local.endDate = dateAdd("d", local.getAdDuring, local.startDate);

            // Create invoice
            local.planDetails = new backend.core.com.plans().getPlanDetail(arguments.planID);
            local.invoiceStruct = {};
            local.invoiceStruct['customerID'] = arguments.customerID;
            local.invoiceStruct['userID'] = arguments.userID;
            local.invoiceStruct['title'] = "Ihr Inserat auf Stellensuche.ch";
            local.invoiceStruct['invoiceDate'] = local.startDate;
            local.invoiceStruct['dueDate'] = dateAdd("d", 10, local.startDate);
            local.invoiceStruct['currency'] = "CHF";
            local.invoiceStruct['isNet'] = local.planDetails.isNet;
            local.invoiceStruct['paymentStatusID'] = 2;
            local.invoiceStruct['vatType'] = local.planDetails.vatType;
            local.invoiceStruct['language'] = "de";

            local.createInvoice = local.objInvoices.createInvoice(local.invoiceStruct);

            if (structKeyExists(local.createInvoice, "newInvoiceID")) {
                local.invcoiceID = local.createInvoice.newInvoiceID;
            } else {
                variables.argsReturnValue['message'] = "Konnte Rechnung nicht anlegen: " & local.createInvoice.message;
                return local.createInvoice;
            }

            // Insert position
            local.posStruct = {};
            local.posStruct['invoiceID'] = local.invcoiceID;
            local.posStruct['append'] = false;

            local.posArray = [];
            local.position['title'] = local.qAd.strJobTitle;
            local.position['description'] = "Inserat vom " & dateFormat(local.startDate, 'dd.mm.yyyy') & "bis " & dateFormat(local.endDate, 'dd.mm.yyyy');
            local.position['price'] = application.objSettings.getSetting('varAdCosts', arguments.planID);
            local.position['quantity'] = 1;
            local.position['unit'] = "";
            local.position['discountPercent'] = 0;
            local.position['vat'] = "8.1";
            arrayAppend(local.posArray, local.position);

            local.posStruct['positions'] = local.posArray;

            local.insertPos = local.objInvoices.insertInvoicePositions(local.posStruct);

            if (!local.insertPos.success) {
                variables.argsReturnValue['message'] = "Konnte Position nicht anlegen: " & local.insertPos.message;
                return local.insertPos;
            }

            queryExecute(
                options = {datasource = application.datasource, result="delAd"},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    adID: {type: "numeric", value: arguments.adID},
                    start: {type: "date", value: createODBCDate(local.startDate)},
                    end: {type: "date", value: createODBCDate(local.endDate)},
                    invoiceID: {type: "numeric", value: local.invcoiceID}
                },
                sql = "
                    UPDATE ss_ads
                    SET dteStart = :start,
                        dteEnd = :end,
                        blnActive = 1,
                        intInvoiceID = :invoiceID
                    WHERE intAdID = :adID
                    AND intCustomerID = :customerID
                "
            );

            addHistory(arguments.adID, "Inserat aktiviert (#dateFormat(local.startDate, 'dd.mm.yyyy')# bis #dateFormat(local.endDate, 'dd.mm.yyyy')#)", arguments.customerID, arguments.userID);

            variables.argsReturnValue['success'] = true;
            variables.argsReturnValue['invoiceID'] = local.invcoiceID;
            variables.argsReturnValue['message'] = "Ihr Inserat wurde aktiviert. Bitte begleichen Sie die Rechnung innert 10 Tagen. Sie können unten die gewünschte Zahlungsart wählen oder nutzen Sie den QR-Code im PDF.";

        } else {

            variables.argsReturnValue['message'] = "Das Inserat wurde nicht gefunden!";

        }

        return variables.argsReturnValue;


    }

    public struct function pauseAd(required numeric adID, required numeric customerID, required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource, result="pauseAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                UPDATE ss_ads
                SET blnPaused = 1
                WHERE intAdID = :adID
                AND intCustomerID = :customerID
            "
        );

        if (pauseAd.recordCount) {
            addHistory(arguments.adID, "Inserat pausiert", arguments.customerID, arguments.userID);
            variables.argsReturnValue['message'] = "Das Inserat wurde pausiert. Denken Sie bitte daran, dass die Zeit weiterläuft!";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Es wurde kein Inserat pausiert!";
        }

        return variables.argsReturnValue;

    }

    public struct function reactiveAd(required numeric adID, required numeric customerID, required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource, result="pauseAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                UPDATE ss_ads
                SET blnPaused = 0
                WHERE intAdID = :adID
                AND intCustomerID = :customerID
            "
        );

        if (pauseAd.recordCount) {
            addHistory(arguments.adID, "Inserat reaktiviert", arguments.customerID, arguments.userID);
            variables.argsReturnValue['message'] = "Das Inserat wurde reaktiviert und wird in der Stellensuche wieder gefunden.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Es wurde kein Inserat reaktiviert!";
        }

        return variables.argsReturnValue;

    }

    public struct function endAd(required numeric adID, required numeric customerID, required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource, result="endAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                UPDATE ss_ads
                SET blnPaused = 0,
                    blnActive = 0,
                    blnArchived = 1,
                    dteEnd = DATE(NOW())
                WHERE intAdID = :adID
                AND intCustomerID = :customerID
            "
        );

        if (endAd.recordCount) {
            addHistory(arguments.adID, "Inserat beendet", arguments.customerID, arguments.userID);
            variables.argsReturnValue['message'] = "Das Inserat wurde beendet und archiviert.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Es wurde kein Inserat beendet!";
        }

        return variables.argsReturnValue;

    }

    public struct function copyAd(required numeric adID, required numeric customerID, required numeric userID) {

        // Get data of archieved ad
        local.qOldData = getAdDetails(arguments.adID, 1);

        if (local.qOldData.recordCount) {

            local.adTitle = local.qOldData.strJobTitle & " (Kopie)";

            queryExecute(
                options = {datasource = application.datasource, result="local.copyAd"},
                params = {
                    customerID: {type: "numeric", value: local.qOldData.intCustomerID},
                    userID: {type: "numeric", value: local.qOldData.intUserID},
                    typeID: {type: "numeric", value: local.qOldData.blnAdTypeID},
                    title: {type: "nvarchar", value: local.adTitle},
                    description: {type: "nvarchar", value: local.qOldData.strJobDescription},
                    minW: {type: "numeric", value: local.qOldData.lngMinWorkload},
                    maxW: {type: "numeric", value: local.qOldData.lngMaxWorkload},
                    cType: {type: "numeric", value: local.qOldData.intContractTypeID},
                    jobPos: {type: "numeric", value: local.qOldData.intJobPositionID},
                    starting: {type: "nvarchar", value: local.qOldData.strJobStarting},
                    showAppl: {type: "boolean", value: local.qOldData.blnShowApplication},
                    video: {type: "varchar", value: local.qOldData.strVideoLink},
                },
                sql = "
                    INSERT INTO ss_ads
                    (
                        strUUID,
                        intCustomerID,
                        intUserID,
                        blnAdTypeID,
                        blnActive,
                        blnPaused,
                        blnArchived,
                        dteStart,
                        dteEnd,
                        strJobTitle,
                        strJobDescription,
                        lngMinWorkload,
                        lngMaxWorkload,
                        intContractTypeID,
                        intJobPositionID,
                        strJobStarting,
                        blnShowApplication,
                        strVideoLink,
                        intInvoiceID,
                        intMappingID
                    )
                    VALUES (
                        UUID(),
                        :customerID,
                        :userID,
                        :typeID,
                        0,
                        0,
                        0,
                        NULL,
                        NULL,
                        :title,
                        :description,
                        :minW,
                        :maxW,
                        :cType,
                        :jobPos,
                        :starting,
                        :showAppl,
                        :video,
                        NULL,
                        NULL
                    )
                "
            );

            if (local.copyAd.recordCount) {

                local.newAdID = local.copyAd.generated_key;

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        oldAdID: {type: "numeric", value: arguments.adID},
                        newAdID: {type: "numeric", value: local.newAdID}
                    },
                    sql = "

                        INSERT INTO ss_industries_ads (intIndustryID, intAdID)
                        SELECT intIndustryID, :newAdID
                        FROM ss_industries_ads
                        WHERE intAdID = :oldAdID;

                        INSERT INTO ss_ads_locations (intLocationID, intAdID)
                        SELECT intLocationID, :newAdID
                        FROM ss_ads_locations
                        WHERE intAdID = :oldAdID

                    "
                );

                // Insert URL slug
                local.objMapping = new backend.core.com.mappings();
                local.beautyTitle = application.objGlobal.beautifyString(local.adTitle);

                local.mapping = {};
                local.mapping['createdByApp'] = true;

                local.companyName = application.objCustomer.getCustomerData(local.qOldData.intCustomerID).companyName;

                local.urlSlug = "stelle/" & local.beautyTitle & "-" & local.newAdID;
                local.mapping['path'] = 'frontend/job.cfm';
                local.mapping['metaTitle'] = local.adTitle & ' bei ' & local.companyName & ' - Stellensuche.ch';
                local.mapping['metaDescription'] = local.companyName & ' hat eine offene Stelle als ' & local.adTitle & ' ausgeschrieben. Jetzt direkt via Stellensuche.ch bewerben!';
                local.mapping['mapping'] = local.urlSlug;

                local.newMapping = local.objMapping.newFrontendMapping(local.mapping);

                if (structKeyExists(local.newMapping, "id")) {
                    queryExecute(
                        options = {datasource = application.datasource, result="local.newWorker"},
                        params = {
                            mappingID: {type: "numeric", value: local.newMapping.id},
                            adID: {type: "numeric", value: local.newAdID}
                        },
                        sql = "
                            UPDATE ss_ads
                            SET intMappingID = :mappingID
                            WHERE intAdID = :adID
                        "
                    );
                }

                addHistory(arguments.adID, "Inserat mit ID #arguments.adID# kopiert", arguments.customerID, arguments.userID);
                variables.argsReturnValue['message'] = "Das Inserat wurde erfolgreich kopiert. Sie können es nun bearbeiten.";
                variables.argsReturnValue['success'] = true;

            } else {

                variables.argsReturnValue['message'] = "Das Inserat konnte nicht kopiert werden!";

            }

        } else {

            variables.argsReturnValue['message'] = "Das Inserat konnte nicht kopiert werden!";

        }

        return variables.argsReturnValue;

    }

    public struct function archiveAd(required numeric adID, required numeric customerID, required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource, result="pauseAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                UPDATE ss_ads
                SET blnArchived = 1
                WHERE intAdID = :adID
                AND intCustomerID = :customerID
            "
        );

        if (pauseAd.recordCount) {
            addHistory(arguments.adID, "Inserat archiviert", arguments.customerID, arguments.userID);
            variables.argsReturnValue['message'] = "Das Inserat wurde archiviert.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Es wurde kein Inserat archiviert!";
        }

        return variables.argsReturnValue;

    }

    public query function getApplications(required numeric adID, required numeric customerID) {

        local.qApplications = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                SELECT  a.dtmApplieted, a.blnDone, a.intApplicationID,
                        u.intUserID, u.strFirstName, u.strLastName,
                        c.strAddress, c.strZIP, c.strCity
                FROM ss_applications a
                INNER JOIN ss_ads ON 1=1
                AND a.intAdID = ss_ads.intAdID

                INNER JOIN users u ON 1=1
                AND a.intUserID = u.intUserID

                INNER JOIN customers c ON 1=1
                AND u.intCustomerID = c.intCustomerID

                WHERE a.intAdID = :adID
                AND ss_ads.intCustomerID = :customerID
                ORDER BY a.dtmApplieted DESC
            "
        );

        return local.qApplications;

    }

    public struct function getAppDetails(required numeric appID, required numeric customerID) {

        local.qApplication = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                appID: {type: "numeric", value: arguments.appID}
            },
            sql = "

                SELECT  a.*,
                        u.strSalutation, u.strFirstName, u.strLastName, u.strEmail, u.strPhone, u.strMobile, u.intUserID,
                        c.strAddress, c.strZIP, c.strCity, c.intCustomerID,
                        ss_ads.strJobTitle
                FROM ss_applications a

                INNER JOIN ss_ads ON 1=1
                AND a.intAdID = ss_ads.intAdID
                AND ss_ads.intCustomerID = :customerID

                INNER JOIN users u ON 1=1
                AND a.intUserID = u.intUserID

                INNER JOIN customers c ON 1=1
                AND u.intCustomerID = c.intCustomerID

                WHERE a.intApplicationID = :appID

            "
        );

        local.appStruct = {};
        if (local.qApplication.recordCount) {
            local.appStruct['id'] = local.qApplication.intApplicationID;
            local.appStruct['customerID'] = local.qApplication.intCustomerID;
            local.appStruct['userID'] = local.qApplication.intUserID;
            local.appStruct['adID'] = local.qApplication.intAdID;
            local.appStruct['jobTitle'] = local.qApplication.strJobTitle;
            local.appStruct['dateApplieted'] = local.qApplication.dtmApplieted;
            local.appStruct['isDone'] = local.qApplication.blnDone;
            local.appStruct['appLetter'] = local.qApplication.strAppLetter;
            local.appStruct['salutation'] = local.qApplication.strSalutation;
            local.appStruct['firstName'] = local.qApplication.strFirstName;
            local.appStruct['lastName'] = local.qApplication.strLastName;
            local.appStruct['address'] = local.qApplication.strAddress;
            local.appStruct['zip'] = local.qApplication.strZIP;
            local.appStruct['city'] = local.qApplication.strCity;
            local.appStruct['phone'] = local.qApplication.strPhone;
            local.appStruct['mobile'] = local.qApplication.strMobile;
            local.appStruct['email'] = local.qApplication.strEmail;
        }

        local.appStruct['uploads'] = getUploads(local.qApplication.intCustomerID, local.qApplication.intUserID);

        return local.appStruct;

    }

    public array function getUploads(required numeric customerID, required numeric userID) {

        local.qUploads = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                userID: {type: "numeric", value: arguments.userID}
            },
            sql = "
                SELECT *
                FROM ss_uploads
                WHERE intCustomerID = :customerID
                AND intUserID = :userID
            "
        );

        local.uploadArray = [];
        if (local.qUploads.recordCount) {
            loop query=local.qUploads {
                local.uploadStruct = {};
                local.uploadStruct['id'] = local.qUploads.intUploadID;
                local.uploadStruct['fileName'] = local.qUploads.strFile;
                local.uploadStruct['filePath'] = "/userdata/profiledata/" & local.qUploads.intUserID & "/" & local.qUploads.strFile;
                local.uploadStruct['uploadDate'] = local.qUploads.dtmUploadDate;
                arrayAppend(local.uploadArray, local.uploadStruct);
            }
        }

        return local.uploadArray;

    }

    public void function changeAppStatus(required struct status, required numeric customerID) {

        local.done = 0;
        if (structKeyExists(arguments.status, "done")) {
            local.done = 1;
        }

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                appID: {type: "numeric", value: arguments.status.app},
                done: {type: "boolean", value: local.done}
            },
            sql = "
                UPDATE ss_applications a
                INNER JOIN ss_ads ON a.intAdID = ss_ads.intAdID
                SET blnDone = :done
                WHERE ss_ads.intCustomerID = :customerID
                AND a.intApplicationID = :appID
            "
        );

    }

    public struct function delApplication(required numeric appID, required numeric customerID) {

        queryExecute(
            options = {datasource = application.datasource, result="local.delApp"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                appID: {type: "numeric", value: arguments.appID}
            },
            sql = "
                DELETE ss_applications
                FROM ss_applications
                INNER JOIN ss_ads ON ss_applications.intAdID = ss_ads.intAdID
                WHERE ss_ads.intCustomerID = :customerID
                AND ss_applications.intApplicationID = :appID
            "
        );

        if (local.delApp.recordCount) {
            variables.argsReturnValue['message'] = "Die Bewerbung wurde gelöscht.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Die Bewerbung konnte nicht gelöscht werden!";
        }

        return variables.argsReturnValue;


    }

}