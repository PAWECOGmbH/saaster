
component displayname="sysadmin" output="false" {


    public any function init(numeric customerID) {

        variables.customerID = 0;
        variables.timezoneID = 0;
        variables.timezone = "";

        if (structKeyExists(arguments, "customerID") and arguments.customerID gt 0) {

            variables.customerID = arguments.customerID;
            local.countryID = application.objCustomer.getCustomerData(arguments.customerID).intCountryID;

            if (local.countryID gt 0) {
                variables.timezoneID = application.objGlobal.getCountry(local.countryID).intTimezoneID;
            } else {
                variables.timezoneID = application.objCustomer.getCustomerData(arguments.customerID).intTimezoneID;
            }

            variables.timezone = getTheTimezone(variables.timezoneID).timezone;

        }

        return this;

    }


    private struct function getTheTimezone(required any timezone) {

        local.structTimezone = structNew();

        if (isNumeric(arguments.timezone)) {
            local.qryWhere = "WHERE intTimeZoneID = " & arguments.timezone;
        } else {
            local.qryWhere = "WHERE strTimezone = '#arguments.timezone#'";
        }

        local.qTimezone = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intTimeZoneID, strUTC, strTimezone, strCity
                FROM timezones
                #local.qryWhere#
            "
        )

        if (local.qTimezone.recordCount) {

            local.structTimezone = structNew();
            local.structTimezone['id'] = local.qTimezone.intTimeZoneID;
            local.structTimezone['utc'] = local.qTimezone.strUTC;
            local.structTimezone['city'] = local.qTimezone.strCity;
            local.structTimezone['timezone'] = local.qTimezone.strTimezone;

        }

        return local.structTimezone;

    }



    public array function getTimezones() {

        local.qTimezones = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intTimeZoneID, strUTC, strTimezone, strCity
                FROM timezones
                ORDER BY strTimezone
            "
        )

        local.arrayTimezone = arrayNew(1);

        loop query="local.qTimezones" {
            local.structTimezone = structNew();
            local.structTimezone['id'] = local.qTimezones.intTimeZoneID;
            local.structTimezone['utc'] = local.qTimezones.strUTC;
            local.structTimezone['city'] = local.qTimezones.strCity;
            local.structTimezone['timezone'] = local.qTimezones.strTimezone;
            arrayAppend(local.arrayTimezone, local.structTimezone);
        }

        return local.arrayTimezone;

    }


    public date function utc2local(date utcDate) {

        if (structKeyExists(arguments, "utcDate")) {
            local.utcDate = arguments.utcDate;
        } else {
            local.utcDate = now();
        }

        // Init the Java object
        local.objJAVATimezone = createObject( "java", "java.util.TimeZone" );

        // Get infos of the corresponding timezone
        local.zoneInfos = local.objJAVATimezone.getTimeZone(variables.timezone);

        // Get utc offset of timezone
        local.offsetHours = local.zoneInfos.getOffset(0)/3600000;

        // Are we having dst time?
        local.inDST = local.zoneInfos.observesDaylightTime();

        // Add hours to time if dst
        if (local.inDST) {
            local.localDate = dateAdd("h", local.offsetHours+1, local.utcDate);
        } else {
            local.localDate = dateAdd("h", local.offsetHours, local.utcDate);
        }

        return local.localDate;

    }


}