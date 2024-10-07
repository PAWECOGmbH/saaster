component displayname="profilesFrontend" output="false" extends="frontend.com.ads" {

    public array function getProfiles(string orderBy="", numeric maxRows=99999, numeric startRow=0, any search) {

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
                local.sFreeText = local.sFreeText & " OR u.strFirstName LIKE '%#local.cleanText#%'";
                local.sFreeText = local.sFreeText & " OR u.strLastName LIKE '%#local.cleanText#%'";
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

        local.qWorkerProfiles = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT  wp.*,
                        u.strSalutation,
                        u.strFirstName,
                        u.strLastName,
                        u.strEmail,
                        u.strPhone,
                        u.strMobile,
                        u.strPhoto,

                        c.intCustomerID,
                        c.strAddress,
                        c.strZIP,
                        c.strCity,

                        b.strStatus,

                        ss_ads.strUUID,
                        ss_ads.strJobTitle,
                        ss_ads.strJobDescription,
                        ss_ads.lngMinWorkload,
                        ss_ads.lngMaxWorkload,
                        ss_ads.intContractTypeID,
                        ss_ads.intJobPositionID,
                        ss_ads.strJobStarting,
                        ss_ads.strVideoLink,
                        (
                            SELECT strMapping
                            FROM frontend_mappings
                            WHERE intFrontendMappingsID = ss_ads.intMappingID
                        ) AS mapping

                FROM ss_worker_profiles wp

                INNER JOIN users u ON 1=1
                AND wp.intUserID = u.intUserID

                INNER JOIN customers c ON 1=1
                AND u.intCustomerID = c.intCustomerID

                INNER JOIN bookings b ON 1=1
                AND c.intCustomerID = b.intCustomerID
                AND (b.strStatus = 'active' OR b.strStatus = 'canceled' OR b.strStatus = 'payment')

                INNER JOIN ss_ads ON 1=1
                AND ss_ads.intCustomerID = c.intCustomerID
                AND ss_ads.blnAdTypeID = 2

                #local.sLocation#

                #local.sIndustry#

                WHERE wp.blnPublic = 1

                #local.sCType#

                #local.sFreeText#

                #local.orderBy#

                GROUP BY u.intCustomerID

                LIMIT #arguments.startRow#, #arguments.maxRows#

            "
        )

        local.arrayProfiles = [];
        loop query=local.qWorkerProfiles {

            local.structProfile = {};

            // Workload
            if (local.qWorkerProfiles.lngMinWorkload eq local.qWorkerProfiles.lngMaxWorkload) {
                local.workload = local.qWorkerProfiles.lngMinWorkload & "%";
            } else {
                local.workload = local.qWorkerProfiles.lngMinWorkload & " - " & local.qWorkerProfiles.lngMaxWorkload & "%";
            }

            // Profile information
            local.structProfile['id'] = local.qWorkerProfiles.intAdID;
            local.structProfile['uuid'] = local.qWorkerProfiles.strUUID;
            local.structProfile['mapping'] = local.qWorkerProfiles.mapping;
            local.structProfile['jobTitle'] = local.qWorkerProfiles.strJobTitle;
            local.structProfile['jobDescription'] = local.qWorkerProfiles.strJobDescription;
            local.structProfile['minWorkload'] = local.qWorkerProfiles.lngMinWorkload;
            local.structProfile['maxWorkload'] = local.qWorkerProfiles.intContractTypeID;
            local.structProfile['workloadSet'] = local.workload;
            local.structProfile['jobStarting'] = local.qWorkerProfiles.strJobStarting;
            local.structProfile['videoLink'] = local.qWorkerProfiles.strVideoLink;

            // Personal
            local.structProfile['salutation'] = local.qWorkerProfiles.blnShowSalutation ? local.qWorkerProfiles.strSalutation : "";
            local.structProfile['firstName'] = local.qWorkerProfiles.blnShowFirstName ? local.qWorkerProfiles.strFirstName : "";
            local.structProfile['lasttName'] = local.qWorkerProfiles.blnShowLastName ? local.qWorkerProfiles.strLastName : "";
            local.structProfile['address'] = local.qWorkerProfiles.blnShowStreet ? local.qWorkerProfiles.strAddress : "";
            local.structProfile['zipCity'] = local.qWorkerProfiles.blnShowZipCity ? local.qWorkerProfiles.strZIP & " " & local.qWorkerProfiles.strCity : "";
            local.structProfile['email'] = local.qWorkerProfiles.blnShowEmail ? local.qWorkerProfiles.strEmail : "";
            local.structProfile['phone'] = local.qWorkerProfiles.blnShowTel ? local.qWorkerProfiles.strPhone : "";
            local.structProfile['mobile'] = local.qWorkerProfiles.blnShowMobile ? local.qWorkerProfiles.strMobile : "";
            local.structProfile['photo'] = local.qWorkerProfiles.blnShowPhoto ? local.qWorkerProfiles.strPhoto : "";

            // Locations
            local.structProfile['locations'] = getLocations(local.qWorkerProfiles.intAdID);

            // Job position
            local.structProfile['jobPosition'] = getJobPosition(local.qWorkerProfiles.intJobPositionID);

            // Industries
            local.structProfile['industries'] = getIndustries(local.qWorkerProfiles.intAdID);

            // Contract Type
            local.structProfile['contractType'] = getContractType(local.qWorkerProfiles.intContractTypeID);

            arrayAppend(local.arrayProfiles, local.structProfile);

        }

        return local.arrayProfiles;

    }


    public struct function getCompanyProfile(required numeric companyID) {

        local.qCompanyProfile = queryExecute(
            options = {datasource = application.datasource},
            params = {
                companyID: {type: "numeric", value: arguments.companyID}
            },
            sql = "
                SELECT ss_company.strCompanyDescription,
                customers.strCompanyName, customers.strContactPerson, customers.strAddress, customers.strAddress2, customers.strZIP,
                customers.strCity, customers.strPhone, customers.strEmail, customers.strWebsite, customers.strLogo
                FROM ss_company
                INNER JOIN customers ON 1=1
                AND ss_company.intCompanyID = customers.intCustomerID
                AND ss_company.intCompanyID = :companyID
                AND customers.blnActive = 1
            "
        )

        local.cpStruct = {};

        if (local.qCompanyProfile.recordCount) {

            local.cpStruct['name'] = local.qCompanyProfile.strCompanyName;
            local.cpStruct['contact'] = local.qCompanyProfile.strContactPerson;
            local.cpStruct['address'] = local.qCompanyProfile.strAddress;
            local.cpStruct['address2'] = local.qCompanyProfile.strAddress2;
            local.cpStruct['zip'] = local.qCompanyProfile.strZIP;
            local.cpStruct['city'] = local.qCompanyProfile.strCity;
            local.cpStruct['phone'] = local.qCompanyProfile.strPhone;
            local.cpStruct['email'] = local.qCompanyProfile.strEmail;
            local.cpStruct['website'] = local.qCompanyProfile.strWebsite;
            local.cpStruct['logo'] = local.qCompanyProfile.strLogo;
            local.cpStruct['description'] = local.qCompanyProfile.strCompanyDescription;

        }

        return local.cpStruct;

    }

    public struct function getWorkerProfile(required string uuid, boolean backend=false) {

        local.publicSql1 = "b.strStatus,";
        local.publicSql2 = "INNER JOIN bookings b ON 1=1 AND c.intCustomerID = b.intCustomerID AND (b.strStatus = 'active' OR b.strStatus = 'canceled' OR b.strStatus = 'payment')";
        local.publicSql3 = "AND wp.blnPublic = 1";
        if (arguments.backend) {
            local.publicSql1 = "";
            local.publicSql2 = "";
            local.publicSql3 = "";
        }

        local.qWorkerProfile = queryExecute(
            options = {datasource = application.datasource},
            params = {
                uuid: {type: "varchar", value: arguments.uuid}
            },
            sql = "
                SELECT  wp.*,
                        u.strSalutation,
                        u.strFirstName,
                        u.strLastName,
                        u.strEmail,
                        u.strPhone,
                        u.strMobile,
                        u.strPhoto,

                        c.intCustomerID,
                        c.strAddress,
                        c.strZIP,
                        c.strCity,

                        #local.publicSql1#

                        ss_ads.strUUID,
                        ss_ads.strJobTitle,
                        ss_ads.strJobDescription,
                        ss_ads.lngMinWorkload,
                        ss_ads.lngMaxWorkload,
                        ss_ads.intContractTypeID,
                        ss_ads.intJobPositionID,
                        ss_ads.strJobStarting,
                        ss_ads.strVideoLink

                FROM ss_worker_profiles wp

                INNER JOIN users u ON 1=1
                AND wp.intUserID = u.intUserID

                INNER JOIN customers c ON 1=1
                AND u.intCustomerID = c.intCustomerID

                #local.publicSql2#

                INNER JOIN ss_ads ON 1=1
                AND ss_ads.intCustomerID = c.intCustomerID
                AND ss_ads.blnAdTypeID = 2

                WHERE ss_ads.strUUID = :uuid
                #local.publicSql3#


            "
        )


        local.wpStruct = {};

        if (local.qWorkerProfile.recordCount) {

            local.wpStruct['profileID'] = local.qWorkerProfile.intWorkerProfileID;

            // Workload
            if (local.qWorkerProfile.lngMinWorkload eq local.qWorkerProfile.lngMaxWorkload) {
                local.workload = local.qWorkerProfile.lngMinWorkload & "%";
            } else {
                local.workload = local.qWorkerProfile.lngMinWorkload & " - " & local.qWorkerProfile.lngMaxWorkload & "%";
            }

            // Personal
            local.wpStruct['salutation'] = local.qWorkerProfile.blnShowSalutation ? local.qWorkerProfile.strSalutation : "";
            local.wpStruct['firstName'] = local.qWorkerProfile.blnShowFirstName ? local.qWorkerProfile.strFirstName : "";
            local.wpStruct['lasttName'] = local.qWorkerProfile.blnShowLastName ? local.qWorkerProfile.strLastName : "";
            local.wpStruct['address'] = local.qWorkerProfile.blnShowStreet ? local.qWorkerProfile.strAddress : "";
            local.wpStruct['zipCity'] = local.qWorkerProfile.blnShowZipCity ? local.qWorkerProfile.strZIP & " " & local.qWorkerProfile.strCity : "";
            local.wpStruct['email'] = local.qWorkerProfile.blnShowEmail ? local.qWorkerProfile.strEmail : "";
            local.wpStruct['phone'] = local.qWorkerProfile.blnShowTel ? local.qWorkerProfile.strPhone : "";
            local.wpStruct['mobile'] = local.qWorkerProfile.blnShowMobile ? local.qWorkerProfile.strMobile : "";
            local.wpStruct['photo'] = local.qWorkerProfile.blnShowPhoto ? local.qWorkerProfile.strPhoto : "";

            // Profile
            local.wpStruct['adID'] = local.qWorkerProfile.intAdID;
            local.wpStruct['public'] = local.qWorkerProfile.blnPublic;
            local.wpStruct['jobTitle'] = local.qWorkerProfile.strJobTitle;
            local.wpStruct['jobDescription'] = local.qWorkerProfile.strJobDescription;
            local.wpStruct['minWorkload'] = local.qWorkerProfile.lngMinWorkload;
            local.wpStruct['maxWorkload'] = local.qWorkerProfile.intContractTypeID;
            local.wpStruct['workloadSet'] = local.workload;
            local.wpStruct['jobStarting'] = local.qWorkerProfile.strJobStarting;
            local.wpStruct['videoLink'] = local.qWorkerProfile.strVideoLink;

            // Restrictions
            local.wpStruct['showSalutation'] = local.qWorkerProfile.blnShowSalutation;
            local.wpStruct['showFirstName'] = local.qWorkerProfile.blnShowFirstName;
            local.wpStruct['showLastName'] = local.qWorkerProfile.blnShowLastName;
            local.wpStruct['showEmail'] = local.qWorkerProfile.blnShowEmail;
            local.wpStruct['showTel'] = local.qWorkerProfile.blnShowTel;
            local.wpStruct['showMobile'] = local.qWorkerProfile.blnShowMobile;
            local.wpStruct['showStreet'] = local.qWorkerProfile.blnShowStreet;
            local.wpStruct['showZipCity'] = local.qWorkerProfile.blnShowZipCity;
            local.wpStruct['showPhoto'] = local.qWorkerProfile.blnShowPhoto;

            // Locations
            local.wpStruct['locations'] = getLocations(local.qWorkerProfile.intAdID);

            // Job position
            local.wpStruct['jobPosition'] = getJobPosition(local.qWorkerProfile.intJobPositionID);

            // Industries
            local.wpStruct['industries'] = getIndustries(local.qWorkerProfile.intAdID);

            // Contract Type
            local.wpStruct['contractType'] = getContractType(local.qWorkerProfile.intContractTypeID);


        }

        return local.wpStruct;

    }

}