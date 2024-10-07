component displayname="ads" output="false" extends="backend.myapp.com.init" {

    public query function getAds(string orderBy="", string search="", numeric status="0") {

        local.searchSql;
        local.orderBy;

        if (len(trim(arguments.search))) {

            local.searchTerm = ReplaceList(trim(arguments.search),'##,<,>,/,{,},[,],(,),+,,{,},?,*,",'',',',,,,,,,,,,,,,,,');

            if (isNumeric(local.searchTerm)) {
                local.searchSql = "ss_ads.intAdID = #local.searchTerm#";
            } else {
                local.searchSql = "
                    ss_ads.strJobTitle LIKE '%#local.searchTerm#%' OR
                    ss_ads.strUUID = '#local.searchTerm#' OR
                    customers.strCompanyName LIKE '%#local.searchTerm#%' OR
                    customers.strContactPerson LIKE '%#local.searchTerm#%' OR
                    customers.strAddress LIKE '%#local.searchTerm#%' OR
                    customers.strAddress2 LIKE '%#local.searchTerm#%' OR
                    customers.strZIP LIKE '%#local.searchTerm#%' OR
                    customers.strCity LIKE '%#local.searchTerm#%' OR
                    customers.strEmail = '#local.searchTerm#'
                ";

            }

            cfsavecontent (variable="local.searchSql") {
                echo("AND (" & local.searchSql & ")");
            };

        }

        if (arguments.status gt 0) {

            switch(arguments.status) {

                case "1":
                local.filterStatus = " AND DATE(ss_ads.dteEnd) >= DATE(NOW()) AND ss_ads.blnActive = 1 AND ss_ads.blnPaused = 0 AND ss_ads.blnArchived = 0";
                break;

                case "2":
                local.filterStatus = "AND ss_ads.blnActive = 0";
                break;

                case "3":
                local.filterStatus = " AND DATE(ss_ads.dteEnd) >= DATE(NOW()) AND ss_ads.blnActive = 1 AND ss_ads.blnPaused = 1 AND ss_ads.blnArchived = 0";
                break;

                case "4":
                local.filterStatus = " AND DATE(ss_ads.dteEnd) < DATE(NOW()) AND ss_ads.blnActive = 1 AND ss_ads.blnPaused = 0 AND ss_ads.blnArchived = 0";
                break;

                case "5":
                local.filterStatus = "AND ss_ads.blnArchived = 1";
                break;

            }

            local.searchSql = local.searchSql & local.filterStatus;

        }

        if (len(trim(arguments.orderBy))) {

            cfsavecontent (variable="local.orderBy") {
                echo("ORDER BY " & arguments.orderBy);
            };

        }

        local.qAds = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT ss_ads.*,
                CASE
                    WHEN ss_ads.blnArchived = 1 THEN 'Archiviert'
                    WHEN ss_ads.blnActive = 0 THEN 'Deaktiviert'
                    WHEN ss_ads.dteStart IS NOT NULL AND ss_ads.blnPaused = 1 THEN 'Pausiert'
                    WHEN ss_ads.dteEnd IS NOT NULL AND ss_ads.blnActive = 1 AND DATE(ss_ads.dteEnd) < DATE(NOW()) THEN 'Beendet'
                    WHEN ss_ads.dteEnd IS NOT NULL AND ss_ads.blnActive = 1 AND DATE(ss_ads.dteEnd) >= DATE(NOW()) THEN 'Aktiv'
                    WHEN ss_ads.dteStart IS NULL AND ss_ads.blnActive = 0 THEN 'Entwurf'
                    ELSE ''
                END AS status,
                CASE
                    WHEN ss_ads.blnArchived = 1 THEN 'orange'
                    WHEN ss_ads.blnActive = 0 THEN 'red'
                    WHEN ss_ads.dteStart IS NOT NULL AND ss_ads.blnPaused = 1 THEN 'blue'
                    WHEN ss_ads.dteEnd IS NOT NULL AND ss_ads.blnActive = 1 AND DATE(ss_ads.dteEnd) < DATE(NOW()) THEN 'purple'
                    WHEN ss_ads.dteEnd IS NOT NULL AND ss_ads.blnActive = 1 AND DATE(ss_ads.dteEnd) >= DATE(NOW()) THEN 'green'
                    WHEN ss_ads.dteStart IS NULL AND ss_ads.blnActive = 0 THEN 'secondary'
                    ELSE ''
                END AS class,
                CASE
                    WHEN LENGTH(customers.strCompanyName) THEN customers.strCompanyName
                    WHEN LENGTH(customers.strContactPerson) THEN customers.strContactPerson
                    ELSE ''
                END AS customerName,
                (
                    SELECT strMapping
                    FROM frontend_mappings
                    WHERE intFrontendMappingsID = ss_ads.intMappingID
                ) as mapping
                FROM ss_ads
                INNER JOIN customers ON 1=1
                AND ss_ads.intCustomerID = customers.intCustomerID
                WHERE ss_ads.blnAdTypeID = 1
                #local.searchSql#
                #local.orderBy#
                LIMIT 20
            "
        )

        return local.qAds;

    }

    public numeric function getTotalAds() {

        local.qAds = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intAdID) as cntAds
                FROM ss_ads
                WHERE blnAdTypeID = 1
            "
        )

        return local.qAds.cntAds;

    }

    public struct function activateAd(required numeric adID, required numeric customerID, required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource, result="activateAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                UPDATE ss_ads
                SET blnActive = 1,
                    blnPaused = 0
                WHERE intAdID = :adID
            "
        );

        if (activateAd.recordCount) {
            addHistory(arguments.adID, "Inserat durch Admin reaktiviert", arguments.customerID, arguments.userID);
            variables.argsReturnValue['message'] = "Das Inserat wurde reaktiviert und wird in der Stellensuche wieder gefunden.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Es wurde kein Inserat reaktiviert!";
        }

        return variables.argsReturnValue;

    }

    public struct function deactivateAd(required numeric adID, required numeric customerID, required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource, result="deactivateAd"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                UPDATE ss_ads
                SET blnActive = 0
                WHERE intAdID = :adID
            "
        );

        if (deactivateAd.recordCount) {
            addHistory(arguments.adID, "Inserat durch Admin deaktiviert", arguments.customerID, arguments.userID);
            variables.argsReturnValue['message'] = "Das Inserat wurde deaktiviert.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Es wurde kein Inserat deaktiviert!";
        }

        return variables.argsReturnValue;

    }

    public struct function editDate(required date toDate, required numeric adID, required numeric customerID, required numeric userID) {

        local.qStartDate = queryExecute(
            options = {datasource = application.datasource},
            params = {
                adID: {type: "numeric", value: arguments.adID}
            },
            sql = "
                SELECT dteStart
                FROM ss_ads
                WHERE intAdID = :adID
            "
        );

        local.start = dateFormat(local.qStartDate.dteStart, 'yyyy-mm-dd');
        local.end = dateFormat(arguments.toDate, 'yyyy-mm-dd');
        local.diff = dateDiff("d", local.start, local.end);

        if (local.diff lte 0) {
            variables.argsReturnValue['message'] = "Das Enddatum darf nicht kleiner sein als das Startdatum!";
            variables.argsReturnValue['success'] = "date";
            return variables.argsReturnValue;
        }

        queryExecute(
            options = {datasource = application.datasource, result="editDate"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                adID: {type: "numeric", value: arguments.adID},
                date: {type: "date", value: arguments.toDate}
            },
            sql = "
                UPDATE ss_ads
                SET dteEnd = :date
                WHERE intAdID = :adID
            "
        );

        if (editDate.recordCount) {
            addHistory(arguments.adID, "Enddatum durch Admin geändert", arguments.customerID, arguments.userID);
            variables.argsReturnValue['message'] = "Das Datum wurde geändert.";
            variables.argsReturnValue['success'] = true;
        } else {
            variables.argsReturnValue['message'] = "Das Datum konnte nicht geändert werden!";
        }

        return variables.argsReturnValue;

    }


}