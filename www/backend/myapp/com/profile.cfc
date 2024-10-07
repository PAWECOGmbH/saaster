component displayname="profile" output="false" extends="backend.myapp.com.init" {

    public struct function saveDescription(required struct company) {

        // Security
        local.cleanedDesc = cleanUpTrumbowyg(arguments.company.description);

        // Generate URL slug
        local.urlString = arguments.company.companyName & "-" & arguments.company.companyCity & "-" & arguments.company.companyID;
        local.urlSlug = "arbeitgeber/" & application.objGlobal.beautifyString(local.urlString);

        local.mapping = {};
        local.mapping['createdByApp'] = true;
        local.mapping['path'] = 'frontend/company.cfm';
        local.mapping['metaTitle'] = arguments.company.companyName & ' - Stellenangebote auf Stellensuche.ch';
        local.mapping['metaDescription'] = 'Offene Stellen bei ' & arguments.company.companyName & ' - Jetzt via Stellensuche.ch bewerben!';
        local.mapping['mapping'] = local.urlSlug;

        local.objMapping = new backend.core.com.mappings();

        // Double check
        local.qCompany = queryExecute(
            options = {datasource = application.datasource},
            params = {
                companyID: {type: "numeric", value = arguments.company.companyID}
            },
            sql = "
                SELECT intCompanyID, intMappingID
                FROM ss_company
                WHERE intCompanyID = :companyID
            "
        );

        try {

            if (local.qCompany.recordCount) {

                local.companyID = arguments.company.companyID;

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        companyID: {type: "numeric", value = arguments.company.companyID},
                        description: {type: "nvarchar", value = local.cleanedDesc},
                    },
                    sql = "
                        UPDATE ss_company
                        SET strCompanyDescription = :description
                        WHERE intCompanyID = :companyID
                    "
                );

                local.objMapping.editFrontendMapping(local.mapping, local.qCompany.intMappingID);


            } else {

                queryExecute(
                    options = {datasource = application.datasource, result="local.resCompany"},
                    params = {
                        companyID: {type: "numeric", value = arguments.company.companyID},
                        description: {type: "nvarchar", value = local.cleanedDesc}
                    },
                    sql = "
                        INSERT INTO ss_company (intCompanyID, strCompanyDescription)
                        VALUES (:companyID, :description)
                    "
                );

                local.companyID = local.resCompany.generated_key;
                local.newMapping = local.objMapping.newFrontendMapping(local.mapping);

                if (structKeyExists(local.newMapping, "id")) {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            companyID: {type: "numeric", value = arguments.company.companyID},
                            mappingID: {type: "numeric", value = local.newMapping.id}
                        },
                        sql = "
                            UPDATE ss_company
                            SET intMappingID = :mappingID
                            WHERE intCompanyID = :companyID
                        "
                    );

                }

            }

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Der Firmenbeschrieb wurde erfolgreich gespeichert.";


        } catch (any e) {

            variables.argsReturnValue.message = "Der Firmenbeschrieb konnte nicht gespeichert werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function getProfileData(required numeric companyID) {

        local.qProfileData = queryExecute(
            options = {datasource = application.datasource},
            params = {
                companyID: {type: "numeric", value = arguments.companyID}
            },
            sql = "
                SELECT strCompanyDescription,
                (
                    SELECT strMapping
                    FROM frontend_mappings
                    WHERE intFrontendMappingsID = ss_company.intMappingID
                ) AS mapping
                FROM ss_company
                WHERE intCompanyID = :companyID
            "
        );

        local.profileStruct = {};
        local.profileStruct['description'] = "";
        local.profileStruct['url_slug'] = "";

        if (local.qProfileData.recordCount) {

            local.profileStruct['description'] = local.qProfileData.strCompanyDescription;
            local.profileStruct['url_slug'] = local.qProfileData.mapping;

        }

        return local.profileStruct;

    }


    public struct function getProfileAccess(required numeric userID) {

        local.profileStruct = {};
        local.profileStruct['public'] = 0;
        local.profileStruct['adID'] = 0;
        local.profileStruct['showSalutation'] = 0;
        local.profileStruct['showFirstName'] = 0;
        local.profileStruct['showLastName'] = 0;
        local.profileStruct['showEmail'] = 0;
        local.profileStruct['showTel'] = 0;
        local.profileStruct['showMobile'] = 0;
        local.profileStruct['showstreet'] = 0;
        local.profileStruct['showZipCity'] = 0;
        local.profileStruct['showPhoto'] = 0;
        local.profileStruct['planGroupID'] = 0;

        local.qProfile = queryExecute(
            options = {datasource = application.datasource},
            params = {
                userID: {type: "numeric", value = arguments.userID}
            },
            sql = "
                SELECT *
                FROM ss_worker_profiles
                WHERE intUserID = :userID
            "
        );

        if (local.qProfile.recordCount) {

            local.profileStruct['public'] = local.qProfile.blnPublic;
            local.profileStruct['adID'] = local.qProfile.intAdID;
            local.profileStruct['showSalutation'] = local.qProfile.blnShowSalutation;
            local.profileStruct['showFirstName'] = local.qProfile.blnShowFirstName;
            local.profileStruct['showLastName'] = local.qProfile.blnShowLastName;
            local.profileStruct['showEmail'] = local.qProfile.blnShowEmail;
            local.profileStruct['showTel'] = local.qProfile.blnShowTel;
            local.profileStruct['showMobile'] = local.qProfile.blnShowMobile;
            local.profileStruct['showstreet'] = local.qProfile.blnShowStreet;
            local.profileStruct['showZipCity'] = local.qProfile.blnShowZipCity;
            local.profileStruct['showPhoto'] = local.qProfile.blnShowPhoto;
            local.profileStruct['planGroupID'] = 2;

        }


        return local.profileStruct;


    }


    public struct function updateProfileStatus(required numeric customerID, required numeric userID, required numeric adID, required boolean public) {

        queryExecute(
            options = {datasource = application.datasource, result="local.status"},
            params = {
                userID: {type: "numeric", value: arguments.userID},
                adID: {type: "numeric", value: arguments.adID},
                public: {type: "boolean", value: arguments.public}
            },
            sql = "
                UPDATE ss_worker_profiles
                SET blnPublic = :public
                WHERE intUserID = :userID
                AND intAdID = :adID
            "
        );

        if (local.status.recordCount) {
            if (arguments.public eq 1) {
                addHistory(arguments.adID, "Jobprofil publiziert", arguments.customerID, arguments.userID);
                variables.argsReturnValue['message'] = "Das Jobprofil wurde publiziert.";
            } else {
                addHistory(arguments.adID, "Jobprofil deaktiviert", arguments.customerID, arguments.userID);
                variables.argsReturnValue['message'] = "Das Jobprofil wurde deaktiviert.";
            }
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Der Status des Jobprofils konnte nicht geändert werden";
        }

        return variables.argsReturnValue;

    }


    public void function insertProfileAccess(required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                userID: {type: "numeric", value: arguments.userID}
            },
            sql = "
                INSERT IGNORE INTO ss_worker_profiles (intUserID)
                VALUES (:userID)
            "
        )


    }


    public struct function updateProfileAccess(required numeric customerID, required numeric userID, required struct access) {

        local.adID = structKeyExists(arguments.access, "adID") ? arguments.access.adID : 0;
        local.showSalutation = structKeyExists(arguments.access, "showSalutation") ? 1 : 0;
        local.showFirstName = structKeyExists(arguments.access, "showFirstName") ? 1 : 0;
        local.showLastName = structKeyExists(arguments.access, "showLastName") ? 1 : 0;
        local.showEmail = structKeyExists(arguments.access, "showEmail") ? 1 : 0;
        local.showTel = structKeyExists(arguments.access, "showTel") ? 1 : 0;
        local.showMobile = structKeyExists(arguments.access, "showMobile") ? 1 : 0;
        local.showstreet = structKeyExists(arguments.access, "showstreet") ? 1 : 0;
        local.showZipCity = structKeyExists(arguments.access, "showZipCity") ? 1 : 0;
        local.showPhoto = structKeyExists(arguments.access, "showPhoto") ? 1 : 0;

        queryExecute(
            options = {datasource = application.datasource, result="local.update"},
            params = {
                userID: {type: "numeric", value: arguments.userID},
                adID: {type: "numeric", value: local.adID},
                showSalutation: {type: "boolean", value: local.showSalutation},
                showFirstName: {type: "boolean", value: local.showFirstName},
                showLastName: {type: "boolean", value: local.showLastName},
                showEmail: {type: "boolean", value: local.showEmail},
                showTel: {type: "boolean", value: local.showTel},
                showMobile: {type: "boolean", value: local.showMobile},
                showstreet: {type: "boolean", value: local.showstreet},
                showZipCity: {type: "boolean", value: local.showZipCity},
                showPhoto: {type: "boolean", value: local.showPhoto}
            },
            sql = "
                UPDATE ss_worker_profiles
                SET blnShowSalutation = :showSalutation,
                    blnShowFirstName = :showFirstName,
                    blnShowLastName = :showLastName,
                    blnShowEmail = :showEmail,
                    blnShowTel = :showTel,
                    blnShowMobile = :showMobile,
                    blnShowStreet = :showstreet,
                    blnShowZipCity = :showZipCity,
                    blnShowPhoto = :showPhoto
                WHERE intUserID = :userID
                AND intAdID = :adID
            "
        );

        if (local.update.recordCount) {
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Der Status des Jobprofils konnte nicht geändert werden";
        }

        return variables.argsReturnValue;

    }


    public struct function insertFileData(required string filename, required string userID, required string customerID) {

        local.getTime = new backend.core.com.time(arguments.customerID);

        queryExecute(
            options = {datasource = application.datasource, result="local.insFile"},
            params = {
                userID: {type: "numeric", value: arguments.userID},
                customerID: {type: "numeric", value: arguments.customerID},
                fileName: {type: "nvarchar", value: arguments.fileName},
                insertDate: {type: "datetime", value: local.getTime.utc2local(now())}
            },
            sql = "
                INSERT INTO ss_uploads (intCustomerID, intUserID, strFile, dtmUploadDate)
                VALUES (:customerID, :userID, :fileName, :insertDate)

            "
        )

        if (local.insFile.recordCount) {
            variables.argsReturnValue['success'] = true;
            variables.argsReturnValue['message'] = local.insFile.generated_key;
        }

        return variables.argsReturnValue;

    }


    public query function getUploadedFiles(required string userID, required string customerID) {

        local.qFiles = queryExecute(
            options = {datasource = application.datasource},
            params = {
                userID: {type: "numeric", value: arguments.userID},
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT *
                FROM ss_uploads
                WHERE intUserID = :userID
                AND intCustomerID = :customerID

            "
        )

        return local.qFiles;

    }


    public struct function deleteFile(required numeric fileID, required string userID, required string customerID) {

        local.qFile = queryExecute(
            options = {datasource = application.datasource},
            params = {
                fileID: {type: "numeric", value: arguments.fileID},
                userID: {type: "numeric", value: arguments.userID},
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT strFile
                FROM ss_uploads
                WHERE intUploadID = :fileID
                AND intUserID = :userID
                AND intCustomerID = :customerID
            "
        )

        if (!local.qFile.recordCount) {

            variables.argsReturnValue['message'] = "Die gewünschte Datei wurde nicht gefunden!";
            return variables.argsReturnValue;

        } else {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    fileID: {type: "numeric", value: arguments.fileID},
                    userID: {type: "numeric", value: arguments.userID},
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    DELETE
                    FROM ss_uploads
                    WHERE intUploadID = :fileID
                    AND intUserID = :userID
                    AND intCustomerID = :customerID
                "
            )

            local.fileToDelete = expandPath("userdata/profiledata/#arguments.userID#/#local.qFile.strFile#");

            if (fileExists(local.fileToDelete)) {
                fileDelete(local.fileToDelete);
            }

        }

        variables.argsReturnValue['success'] = true;
        variables.argsReturnValue['message'] = "Die Datei wurde gelöscht.";
        return variables.argsReturnValue;

    }


    public void function workerAdjustment(required numeric userID, required struct currentPlan) {

        local.objProfile = new backend.myapp.com.profile();
        local.objPlans = new backend.core.com.plans();

        // Insert the workers profile, if its group 2
        local.itsWorker = false;
        local.planGroupID = local.objPlans.getPlanDetail(arguments.currentPlan.planID).planGroupID;
        if (local.planGroupID eq 2) {
            objProfile.insertProfileAccess(arguments.userID);
        }

        // Is it a worker?
        local.planGroupFromProfile = getProfileAccess(arguments.userID).planGroupID;
        if (local.planGroupFromProfile eq 2) {
            local.itsWorker = true;
        }

        // We only need to update, if the current plan is a free plan with group id 1
        if (local.itsWorker and arguments.currentPlan.status eq "free" and local.planGroupID eq 1) {

            // Get planID of the correct plan
            local.planID = 0;
            local.planArray = local.objPlans.getPlans(2);
            loop array=local.planArray index="local.i" {
                if (local.i.itsFree eq 1) {
                    local.planID = local.i.planID;
                    break;
                }
            }

            if (local.planID gt 0) {

                // Update booking
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        planID: {type: "numeric", value: local.planID},
                        bookingID: {type: "numeric", value: arguments.currentPlan.bookingID}
                    },
                    sql = "
                        UPDATE bookings
                        SET intPlanID = :planID
                        WHERE intBookingID = :bookingID
                    "
                )

            }

        }


    }


}