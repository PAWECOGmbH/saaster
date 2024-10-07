component displayname="adsFrontend" output="false" extends="backend.myapp.com.init" {

    public array function getAds(string orderBy="", numeric maxRows=99999, numeric startRow=0, any search) {

        local.orderBy = "";
        if (len(trim(arguments.orderBy))) {
            local.orderBy = "ORDER BY " & arguments.orderBy;
        }

        local.sFreeText = "";
        local.sLocation = "";
        local.sIndustry = "";
        local.sCType = "";

        if (structKeyExists(arguments, "search") and isStruct(arguments.search)) {

            if (structKeyExists(arguments.search, "ctypeID") and isNumeric(arguments.search.ctypeID)) {

                local.sCType = "AND ss_ads.intContractTypeID = " & arguments.search.ctypeID;

            }

            if (structKeyExists(arguments.search, "searchQuery") and len(trim(arguments.search.searchQuery))) {

                local.cleanText = application.objGlobal.cleanUpText(arguments.search.searchQuery);

                local.sFreeText = "AND (";
                local.sFreeText = local.sFreeText & "ss_ads.strJobTitle LIKE '%#local.cleanText#%'";
                local.sFreeText = local.sFreeText & " OR ss_ads.strJobDescription LIKE '%#local.cleanText#%'";
                local.sFreeText = local.sFreeText & " OR customers.strCompanyName LIKE '%#local.cleanText#%'";
                local.sFreeText = local.sFreeText & ")";

            }

            if (structKeyExists(arguments.search, "locationID") and listLen(arguments.search.locationID)) {

                local.sLocation = "INNER JOIN ss_ads_locations ON 1=1";
                local.sLocation = local.sLocation & " AND ss_ads.intAdID = ss_ads_locations.intAdID";
                local.sLocation = local.sLocation & " AND ss_ads_locations.intLocationID IN " & "(" & arguments.search.locationID & ")";

            }

            if (structKeyExists(arguments.search, "industryID") and listLen(arguments.search.industryID)) {

                local.sIndustry = "INNER JOIN ss_industries_ads ON 1=1";
                local.sIndustry = local.sIndustry & " AND ss_ads.intAdID = ss_industries_ads.intAdID";
                local.sIndustry = local.sIndustry & " AND ss_industries_ads.intIndustryID IN " & "(" & arguments.search.industryID & ")";

            }

        }

        local.arrayAds = [];

        try {

            local.qAds = queryExecute(
                options = {datasource = application.datasource},
                sql = "

                    SELECT ss_ads.*,
                    (
                        SELECT strMapping
                        FROM frontend_mappings
                        WHERE intFrontendMappingsID = ss_ads.intMappingID
                    ) AS mapping
                    FROM ss_ads

                    INNER JOIN customers ON 1=1
                    AND ss_ads.intCustomerID = customers.intCustomerID
                    AND ss_ads.blnAdTypeID = 1
                    AND ss_ads.blnActive = 1
                    AND ss_ads.blnPaused = 0
                    AND ss_ads.blnArchived = 0
                    AND DATE(ss_ads.dteEnd) >= DATE(NOW())

                    #local.sCType#

                    #local.sFreeText#

                    #local.sLocation#

                    #local.sIndustry#

                    #local.orderBy#

                    LIMIT #arguments.startRow#, #arguments.maxRows#

                "
            )

            loop query=local.qAds {

                local.structAd = {};

                // Workload
                if (local.qAds.lngMinWorkload eq local.qAds.lngMaxWorkload) {
                    local.workload = local.qAds.lngMinWorkload & "%";
                } else {
                    local.workload = local.qAds.lngMinWorkload & " - " & local.qAds.lngMaxWorkload & "%";
                }

                // Main information
                local.structAd['id'] = local.qAds.intAdID;
                local.structAd['uuid'] = local.qAds.strUUID;
                local.structAd['mapping'] = local.qAds.mapping;
                local.structAd['dateStart'] = dateFormat(local.qAds.dteStart, 'yyyy-mm-dd');
                local.structAd['dateEnd'] = dateFormat(local.qAds.dteEnd, 'yyyy-mm-dd');
                local.structAd['jobTitle'] = local.qAds.strJobTitle;
                local.structAd['jobDescription'] = local.qAds.strJobDescription;
                local.structAd['minWorkload'] = local.qAds.lngMinWorkload;
                local.structAd['maxWorkload'] = local.qAds.intContractTypeID;
                local.structAd['workloadSet'] = local.workload;
                local.structAd['jobStarting'] = local.qAds.strJobStarting;
                local.structAd['showApplication'] = local.qAds.blnShowApplication;
                local.structAd['videoLink'] = local.qAds.strVideoLink;

                // Company
                local.structAd['company'] = getCompany(local.qAds.intCustomerID);

                // Locations
                local.structAd['locations'] = getLocations(local.qAds.intAdID);

                // Job position
                local.structAd['jobPosition'] = getJobPosition(local.qAds.intJobPositionID);

                // Industries
                local.structAd['industries'] = getIndustries(local.qAds.intAdID);

                // Contract Type
                local.structAd['contractType'] = getContractType(local.qAds.intContractTypeID);

                arrayAppend(local.arrayAds, local.structAd);

            }

        } catch (any) {
        }

        return local.arrayAds;

    }

    public struct function getAdDetail(required string uuid, boolean backend=false) {

        if (arguments.backend) {
            savecontent variable="adSQL" {
                writeOutput("
                    SELECT *,
                    (
                        SELECT strMapping
                        FROM frontend_mappings
                        WHERE intFrontendMappingsID = ss_ads.intMappingID
                    ) AS mapping
                    FROM ss_ads
                    WHERE blnAdTypeID = 1
                    AND strUUID = :uuid
                ");
            }
        } else {
            savecontent variable="adSQL" {
                writeOutput("
                    SELECT *,
                    (
                        SELECT strMapping
                        FROM frontend_mappings
                        WHERE intFrontendMappingsID = ss_ads.intMappingID
                    ) AS mapping
                    FROM ss_ads
                    WHERE blnAdTypeID = 1
                    AND blnActive = 1
                    AND blnPaused = 0
                    AND blnArchived = 0
                    AND DATE(dteEnd) >= DATE(NOW())
                    AND strUUID = :uuid
                ");
            }
        }

        try {

            local.qAd = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    uuid: {type: "string", value: arguments.uuid}
                },
                sql = "
                    #adSQL#
                "
            )

            local.structAd = {};

            // Workload
            if (local.qAd.lngMinWorkload eq local.qAd.lngMaxWorkload) {
                local.workload = local.qAd.lngMinWorkload & "%";
            } else {
                local.workload = local.qAd.lngMinWorkload & " - " & local.qAd.lngMaxWorkload & "%";
            }

            // Main information
            local.structAd['id'] = local.qAd.intAdID;
            local.structAd['uuid'] = local.qAd.strUUID;
            local.structAd['mapping'] = local.qAd.mapping;
            local.structAd['dateStart'] = dateFormat(local.qAd.dteStart, 'yyyy-mm-dd');
            local.structAd['dateEnd'] = dateFormat(local.qAd.dteEnd, 'yyyy-mm-dd');
            local.structAd['jobTitle'] = local.qAd.strJobTitle;
            local.structAd['jobDescription'] = local.qAd.strJobDescription;
            local.structAd['minWorkload'] = local.qAd.lngMinWorkload;
            local.structAd['maxWorkload'] = local.qAd.lngMaxWorkload;
            local.structAd['workloadSet'] = local.workload;
            local.structAd['jobStarting'] = local.qAd.strJobStarting;
            local.structAd['showApplication'] = local.qAd.blnShowApplication;
            local.structAd['videoLink'] = local.qAd.strVideoLink;

            // Company
            local.structAd['company'] = getCompany(local.qAd.intCustomerID);

            // User
            local.structAd['user'] = getUser(local.qAd.intUserID);

            // Locations
            local.structAd['locations'] = getLocations(local.qAd.intAdID);

            // Job position
            local.structAd['jobPosition'] = getJobPosition(local.qAd.intJobPositionID);

            // Industries
            local.structAd['industries'] = getIndustries(local.qAd.intAdID);

            // Contract Type
            local.structAd['contractType'] = getContractType(local.qAd.intContractTypeID);

        } catch(any e) {

            local.structAd = {};

        }

        return local.structAd;

    }

    private array function getLocations(required numeric adID) {

        local.qLocations = queryExecute(
            options = {datasource = application.datasource},
            params = {
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                SELECT l.strName, l.intLocationID, l.strCanton
                FROM ss_ads_locations al
                INNER JOIN ss_locations l ON 1=1
                AND al.intLocationID = l.intLocationID
                AND al.intAdID = :adID
                WHERE l.blnActive = 1
                ORDER BY l.strName
            "
        )

        local.arrayLocations = [];
        loop query=local.qLocations {
            local.structLocation = {};
            local.structLocation['id'] = local.qLocations.intLocationID;
            local.structLocation['name'] = local.qLocations.strName;
            local.structLocation['canton'] = local.qLocations.strCanton;
            arrayAppend(local.arrayLocations, local.structLocation);
        }

        return local.arrayLocations;


    }

    private struct function getCompany(required numeric customerID) {

        local.qCustomer = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT
                    intCustomerID, strCompanyName, strAddress, strAddress2, strZIP, strCity,
                    strWebsite, strLogo, strPhone,
                    (
                        SELECT strMapping
                        FROM frontend_mappings
                        WHERE intFrontendMappingsID = ss_company.intMappingID
                    ) AS strURLSlug
                FROM customers
                LEFT JOIN ss_company ON customers.intCustomerID = ss_company.intCompanyID
                WHERE customers.intCustomerID = :customerID
            "
        )

        local.structCompany = {};
        local.structCompany['id'] = local.qCustomer.intCustomerID;
        local.structCompany['companyName'] = local.qCustomer.strCompanyName;
        local.structCompany['address'] = local.qCustomer.strAddress;
        local.structCompany['address2'] = local.qCustomer.strAddress2;
        local.structCompany['zip'] = local.qCustomer.strZIP;
        local.structCompany['city'] = local.qCustomer.strCity;
        local.structCompany['website'] = local.qCustomer.strWebsite;
        local.structCompany['logo'] = local.qCustomer.strLogo;
        local.structCompany['phone'] = local.qCustomer.strPhone;
        local.structCompany['url_slug'] = local.qCustomer.strURLSlug;

        return local.structCompany;

    }

    private struct function getUser(required numeric userID) {

        local.qUser = queryExecute(
            options = {datasource = application.datasource},
            params = {
                userID: {type: "numeric", value: arguments.userID}
            },
            sql = "
                SELECT intUserID, strSalutation, strFirstName, strLastName, strEmail, strPhone
                FROM users
                WHERE intUserID = :userID
            "
        )

        local.structUser = {};
        local.structUser['id'] = local.qUser.intUserID;
        local.structUser['salutation'] = local.qUser.strSalutation;
        local.structUser['firstName'] = local.qUser.strFirstName;
        local.structUser['lastName'] = local.qUser.strLastName;
        local.structUser['phone'] = local.qUser.strPhone;
        local.structUser['email'] = local.qUser.strEmail;

        return local.structUser;

    }

    private struct function getJobPosition(required numeric jposID) {

        local.qJobPosition = queryExecute(
            options = {datasource = application.datasource},
            params = {
                jposID: {type: "numeric", value: arguments.jposID}
            },
            sql = "
                SELECT intJobPositionID, strName
                FROM ss_job_positions
                WHERE intJobPositionID = :jposID
                AND blnActive = 1
            "
        )

        local.structPosition = {};
        local.structPosition['id'] = local.qJobPosition.intJobPositionID;
        local.structPosition['name'] = local.qJobPosition.strName;

        return local.structPosition;

    }

    private array function getIndustries(required numeric adID) {

        local.qIndusries = queryExecute(
            options = {datasource = application.datasource},
            params = {
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                SELECT i.strName, i.intIndustryID
                FROM ss_industries_ads ia
                INNER JOIN ss_industries i ON 1=1
                AND ia.intIndustryID = i.intIndustryID
                AND ia.intAdID = :adID
                WHERE i.blnActive = 1
                ORDER BY i.strName
            "
        )

        local.arrayIndustries = [];
        loop query=local.qIndusries {
            local.structIndustries = {};
            local.structIndustries['id'] = local.qIndusries.intIndustryID;
            local.structIndustries['name'] = local.qIndusries.strName;
            arrayAppend(local.arrayIndustries, local.structIndustries);
        }

        return local.arrayIndustries;


    }

    private struct function getContractType(required numeric typeID) {

        local.qContractType = queryExecute(
            options = {datasource = application.datasource},
            params = {
                typeID: {type: "numeric", value: arguments.typeID}
            },
            sql = "
                SELECT intContractTypeID, strName
                FROM ss_contract_types
                WHERE intContractTypeID = :typeID
                AND blnActive = 1
            "
        )

        local.structContractType = {};
        local.structContractType['id'] = local.qContractType.intContractTypeID;
        local.structContractType['name'] = local.qContractType.strName;

        return local.structContractType;

    }

    public string function generateEmbedCode(string link="") {

        local.embedCode = "";
        local.videoId = extractVideoId(arguments.link);

        if (findNoCase("youtube.com", arguments.link) or findNoCase("youtu.be", arguments.link)) {
            local.embedCode = '<iframe class="video-frame" src="https://www.youtube.com/embed/' & local.videoId & '" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
        } else if (findNoCase("vimeo.com", arguments.link)) {
            local.embedCode = '<iframe class="video-frame" src="https://player.vimeo.com/video/' & local.videoId & '" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>';
        }

        return local.embedCode;

    }

    private string function extractVideoId(string link="") {

        local.videoId = "";

        if (findNoCase("youtu.be/", arguments.link)) {

            // Short YouTube-Link
            local.videoId = listLast(arguments.link, "/");

        } else if (findNoCase("youtube.com/watch", arguments.link)) {

            // Long YouTube-Link
            local.videoId = listGetAt(listLast(arguments.link, "?"), 1, "&");
            local.videoId = listGetAt(local.videoId, 2, "=");

        } else if (findNoCase("vimeo.com/", arguments.link)) {

            // Short or long Vimeo-Link
            local.videoId = listLast(arguments.link, "/");

            if (findNoCase("?", local.videoId)) {
                local.videoId = listFirst(local.videoId, "?");
            }
            if (findNoCase("h=", local.videoId)) {
                local.videoId = listFirst(local.videoId, "?");
            }
        }

        return local.videoId;

    }

    public string function getMotivationPatternText(required string uuid, required numeric workerID) {

        local.jobDetail = application.objAdsFrontend.getAdDetail(url.job);
        local.salutation = "Guten Tag " & local.jobDetail.user.firstName & " " & local.jobDetail.user.lastName;
        if (len(trim(local.jobDetail.user.salutation))) {
            if ((trim(local.jobDetail.user.salutation)) eq "Herr") {
                local.salutation = "Sehr geehrter Herr ";
                local.salutation = local.salutation & local.jobDetail.user.lastName;
            } else if (trim(local.jobDetail.user.salutation) eq "Frau") {
                local.salutation = "Sehr geehrte Frau ";
                local.salutation = local.salutation & local.jobDetail.user.lastName;
            }
        }

        local.workerQuery = application.objCustomer.getUserDataByID(arguments.workerID);
        local.workerName = local.workerQuery.strFirstName & " " & local.workerQuery.strLastName;

        local.patternText = local.salutation & "#chr(13)##chr(10)##chr(13)##chr(10)#";
        local.patternText = local.patternText & "Ich habe Ihre Stellenausschreibung für die Position als ";
        local.patternText = local.patternText & '"' & local.jobDetail.jobTitle & '" ' & "gelesen und bin sehr interessiert. Hiermit bewerbe ich mich auf diese Stelle. Meine Bewerbungsunterlagen sind im Portal von Stellensuche.ch hinterlegt.#chr(13)##chr(10)##chr(13)##chr(10)#";
        local.patternText = local.patternText & "Ich freue mich auf Ihre Rückmeldung und ein mögliches Bewerbungsgespräch.#chr(13)##chr(10)##chr(13)##chr(10)#";
        local.patternText = local.patternText & "Mit freundlichen Grüssen#chr(13)##chr(10)#";
        local.patternText = local.patternText & local.workerName;

        return local.patternText;

    }

    public any function sendApplication(required struct appData) {

        local.jobDetail = application.objAdsFrontend.getAdDetail(arguments.appData.jobID);
        local.employerData = local.jobDetail.user;
        local.workerData = application.objCustomer.getUserDataByID(arguments.appData.workerID);

        // Insert application to db
        queryExecute(
            options = {datasource = application.datasource, result="local.newApp"},
            params = {
                workerID: {type: "numeric", value: local.workerData.intUserID},
                adID: {type: "numeric", value: local.jobDetail.id},
                appDate: {type: "datetime", value: now()},
                letter: {type: "nvarchar", value: arguments.appData.motivationText}
            },
            sql = "
                INSERT INTO ss_applications
                (
                    intUserID,
                    intAdID,
                    dtmApplieted,
                    blnDone,
                    strAppLetter
                )
                VALUE (
                    :workerID,
                    :adID,
                    :appDate,
                    0,
                    :letter
                )
            "
        )

        if (local.newApp.recordCount) {

            // Send info to employer
            mailTitle = "Neue Bewerbung zu " & local.jobDetail.jobTitle;
            mailType = "html";

            cfsavecontent (variable = "mailContent") {
                echo("
                    Guten Tag #local.employerData.firstName# #local.employerData.lastName#<br><br>
                    Sie haben eine neue Bewerbung für die Stelle <b>#local.jobDetail.jobTitle#</b> erhalten:<br>
                    <hr>
                    #replace(arguments.appData.motivationText, '#chr(13)#', '<br>', 'all')#
                    <hr>
                    Hier können Sie die Bewerbung ansehen:<br>
                    <a href='#application.mainURL#/login' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>Bewerbung ansehen</a>
                    <br><br>
                    Mit freundlichem Gruss<br>
                    Ihr Stellensuche.ch Team
                ");
            }

            getTrans = application.objLanguage.getTrans;

            mail to="#local.employerData.email#" from="#application.fromEmail#" subject="#mailTitle#" type="html" {
                include template="/config.cfm";
                include template="/frontend/core/mail_design.cfm";
            }

            variables.argsReturnValue['message'] = "Ihre Bewerbung wurde erfolgreich versendet. Wir wünschen Ihnen viel Erfolg!";
            variables.argsReturnValue['success'] = true;

        } else {

            variables.argsReturnValue['message'] = "Leider hat das Versenden der Bewerbung nicht funktioniert. Bitte versuchen Sie später nochmal.";

        }

        return variables.argsReturnValue;

    }


}