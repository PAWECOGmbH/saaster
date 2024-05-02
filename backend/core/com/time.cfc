
component displayname="time" output="false" {


    public any function init(numeric customerID) {

        variables.customerID = 0;
        variables.timezoneID = 31;

        if (structKeyExists(arguments, "customerID") and arguments.customerID gt 0) {

            variables.customerID = arguments.customerID;
            local.countryID = application.objCustomer.getCustomerData(arguments.customerID).countryID;

            if (local.countryID gt 0) {
                variables.timezoneID = application.objGlobal.getCountry(local.countryID).intTimezoneID;
            } else {
                variables.timezoneID = application.objCustomer.getCustomerData(arguments.customerID).timezoneID;
            }

            if (!isNumeric(variables.timezoneID) or variables.timezoneID eq 0) {
                variables.timezoneID = 31;
            }

        }

        local.timezoneStruct = getTimezoneByID(variables.timezoneID);

        variables.timezone = local.timezoneStruct.timezone ?: "Etc/GMT";

        return this;

    }


    public struct function getTimezoneByID(timezoneID) {

        local.structTimezone = structNew();

        local.timezoneID = structKeyExists(arguments, "timezoneID") and isNumeric(arguments.timezoneID) ? arguments.timezoneID : variables.timezoneID;

        if (local.timezoneID eq 0) {
            local.timezoneID = 31;
        }

        local.qTimezone = queryExecute (
            options = {datasource = application.datasource},
            params = {
                timezoneID: {type: "numeric", value: local.timezoneID}
            },
            sql = "
                SELECT intTimeZoneID, strUTC, strTimezone, strCity
                FROM timezones
                WHERE intTimeZoneID = :timezoneID
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


    public date function utc2local(date utcDate, string timezone) {

        local.utcDate = arguments.utcDate ?: now();
        local.timezone = arguments.timezone ?: variables.timezone;

        // Init the Java object
        local.objJAVATimezone = createObject( "java", "java.util.TimeZone" );

        // Get infos of the corresponding timezone
        local.zoneInfos = local.objJAVATimezone.getTimeZone(local.timezone);

        // Get utc offset of timezone
        local.offsetHours = local.zoneInfos.getOffset(0)/3600000;

        // Are we having dst time?
        local.inDST = local.zoneInfos.inDayLightTime(local.utcDate);

        // Add 1 hour to offsetHours if dst
        if (local.inDST) {
            local.offsetHours = local.offsetHours+1;
        }

        // Add hours to time
        local.localDate = dateAdd("h", local.offsetHours, local.utcDate);

        return local.localDate;

    }


    // Convert a given date with the timezone to utc
    public date function local2utc(required date givenDate, string timezone) {

        local.givenDate = arguments.givenDate ?: now();
        local.timeZone = arguments.timezone ?: variables.timezone;

        // Init the Java object
        local.objJAVATimezone = createObject( "java", "java.util.TimeZone" );

        // Get infos of the corresponding timezone
        local.zoneInfos = local.objJAVATimezone.getTimeZone(local.timeZone);

        // Get utc offset of timezone
        local.offsetHours = local.zoneInfos.getOffset(0)/3600000;

        // Are we having dst time?
        local.inDST = local.zoneInfos.inDayLightTime(local.givenDate);

        // Add 1 hour to offsetHours if dst
        if (local.inDST) {
            local.offsetHours = local.offsetHours+1;
        }

        // Substract hours to time
        local.utcDate = dateAdd("h", -local.offsetHours, local.givenDate);

        return local.utcDate;

    }


}