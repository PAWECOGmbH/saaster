
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


    // Covert a given date to local timezone
    public date function utc2local(date utcDate, string timezone) {

        local.utcDate = isDate(arguments.utcDate) ? arguments.utcDate : now();
        local.utcDate = parseDateTime(local.utcDate);

        local.timezone = arguments.timezone ?: variables.timezone;

        // Init Java TimeZone object
        local.objJAVATimezone = createObject("java", "java.util.TimeZone");
        local.zoneInfos = local.objJAVATimezone.getTimeZone(local.timezone);

        // Calculate offset including daylight saving time
        local.offsetHours = local.zoneInfos.getOffset(local.utcDate.getTime()) / 3600000;

        // Convert to local time
        return dateAdd("h", local.offsetHours, local.utcDate);

    }

    // Covert a given date to UTC timezone
    public date function local2utc(required date givenDate, string timezone) {

        local.givenDate = isDate(arguments.givenDate) ? arguments.givenDate : now();
        local.givenDate = parseDateTime(local.givenDate);

        local.timeZone = arguments.timezone ?: variables.timezone;

        // Init Java TimeZone object
        local.objJAVATimezone = createObject("java", "java.util.TimeZone");
        local.zoneInfos = local.objJAVATimezone.getTimeZone(local.timeZone);

        // Calculate offset including daylight saving time
        local.offsetHours = local.zoneInfos.getOffset(local.givenDate.getTime()) / 3600000;

        // Convert to UTC (only subtract offset!)
        return dateAdd("h", -local.offsetHours, local.givenDate);

    }


}