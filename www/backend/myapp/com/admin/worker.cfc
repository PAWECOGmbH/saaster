component displayname="profiles" output="false" extends="backend.myapp.com.init" {

    public query function getProfiles(string orderBy="", string search="") {

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
                    users.strFirstName = '#local.searchTerm#' OR
                    users.strLastName = '#local.searchTerm#' OR
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

        if (len(trim(arguments.orderBy))) {

            cfsavecontent (variable="local.orderBy") {
                echo("ORDER BY " & arguments.orderBy);
            };

        }

        local.qAds = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT ss_ads.intAdID, ss_ads.blnPaused, ss_ads.strJobTitle,
                customers.intCustomerID, wp.blnPublic,
                CONCAT(users.strFirstName, ' ', users.strLastName) AS customerName,
                bookings.dteStartDate as dteStart, bookings.dteEndDate as dteEnd,
                invoices.intInvoiceID,
                (
                    SELECT strMapping
                    FROM frontend_mappings
                    WHERE intFrontendMappingsID = ss_ads.intMappingID
                ) as mapping

                FROM ss_ads
                INNER JOIN customers ON 1=1
                AND ss_ads.intCustomerID = customers.intCustomerID

                INNER JOIN ss_worker_profiles wp ON 1=1
                AND ss_ads.intAdID = wp.intAdID

                INNER JOIN users ON 1=1
                AND wp.intUserID = users.intUserID

                INNER JOIN bookings ON 1=1
                AND ss_ads.intCustomerID = bookings.intCustomerID
                AND (bookings.strStatus = 'active' OR bookings.strStatus = 'canceled')

                INNER JOIN invoices ON 1=1
                AND bookings.intBookingID = invoices.intBookingID

                WHERE ss_ads.blnAdTypeID = 2
                #local.searchSql#
                #local.orderBy#
                LIMIT 20
            "
        )

        return local.qAds;



    }

    public numeric function getProfilesTotal() {

        local.qAds = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intAdID) as cntAds
                FROM ss_ads
                INNER JOIN bookings ON 1=1
                AND ss_ads.intCustomerID = bookings.intCustomerID
                AND (bookings.strStatus = 'active' OR bookings.strStatus = 'canceled')
                WHERE ss_ads.blnAdTypeID = 2
            "
        )

        return local.qAds.cntAds;

    }

}