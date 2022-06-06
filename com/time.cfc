
component displayname="sysadmin" output="false" {


    public any function init(numeric customerID) {

        variables.customerID = 0;
        variables.timezoneID = 0;
        variables.timezone = "UTC+00:00";

        if (structKeyExists(arguments, "customerID") and arguments.customerID gt 0) {

            variables.customerID = arguments.customerID;
            local.countryID = application.objCustomer.getCustomerData(arguments.customerID).intCountryID;

            if (local.countryID gt 0) {
                variables.timezoneID = application.objGlobal.getCountry(local.countryID).intTimezoneID;
            } else {
                variables.timezoneID = application.objCustomer.getCustomerData(arguments.customerID).intTimezoneID;
            }

            variables.timezone = getTimezones(tzID=variables.timezoneID)[1].utc;

        }

        return this;

    }


    // Get users current date using the timezone
    public date function currentDate() {

        local.userDate = now();

        if (variables.customerID gt 0) {
            local.userDate = utc2local(now(), variables.timezone, variables.customerID);

        }

        return local.userDate;

    }


    public array function getTimezones(numeric tzID, string timezone) {

        if (structKeyExists(arguments, "tzID") and arguments.tzID gt 0) {
            local.whereSQL = "WHERE intTimeZoneID = " & arguments.tzID;
        } else if (structKeyExists(arguments, "timezone")) {
            local.whereSQL = "WHERE strUTC = '#arguments.timezone#'";
        } else {
            local.whereSQL = "";
        }


        // We set summer time for the corresponding countries from the last Sunday in March to the last Sunday in October.
        // Yes, some countries have different days, but we ignore that for now.

        // Get the last Sunday in March this Year
        local.monthMarch = createDate(year(now()),3,1);
        local.lastDayOfMarch = dateAdd("m",1, monthMarch) - 1;
        local.theLastSundayInMarch = (lastDayOfMarch - dayOfWeek( lastDayOfMarch ) + 1);
        if (month( theLastSundayInMarch ) neq month( monthMarch )) {
            local.theLastSundayInMarch = (theLastSundayInMarch - 7);

        }
        local.theLastSundayInMarch = createODBCDate(local.theLastSundayInMarch);

        // Get the last Sunday in October this Year
        local.monthOctober = createDate(year(now()),10,1);
        local.lastDayOfOctober = dateAdd("m",1, monthOctober) - 1;
        local.theLastSundayInOctober = (lastDayOfOctober - dayOfWeek( lastDayOfOctober ) + 1);
        if (month( theLastSundayInOctober ) neq month( monthOctober )) {
            local.theLastSundayInOctober = (theLastSundayInOctober - 7);

        }
        local.theLastSundayInOctober = createODBCDate(local.theLastSundayInOctober);

        if ((local.theLastSundayInMarch <= createODBCDate(currentDate())) and (local.theLastSundayInOctober >= createODBCDate(currentDate()))) {
            local.getColumn = "strUTCSummer";
        } else {
            local.getColumn = "strUTCWinter";
        }

        local.qTimezones = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intTimeZoneID, strCity, strCountry, strUTCSummer, #local.getColumn# as strUTC
                FROM timezones
                #local.whereSQL#
                ORDER BY strCountry
            "
        )

        local.arrayTimezone = arrayNew(1);

        loop query="local.qTimezones" {
            local.structTimezone = structNew();
            local.structTimezone['id'] = local.qTimezones.intTimeZoneID;
            local.structTimezone['utc'] = local.qTimezones.strUTC;
            local.structTimezone['city'] = local.qTimezones.strCity;
            local.structTimezone['country'] = local.qTimezones.strCountry;
            arrayAppend(local.arrayTimezone, local.structTimezone);
        }

        return local.arrayTimezone;

    }


    public date function local2utc(required date localDate) {

        if (isDate(arguments.localDate)) {
            local.utcDate = dateTimeFormat(date:arguments.localDate,timezone:'UTC+00:00');
        } else {
            local.utcDate = dateTimeFormat(date:now(),timezone:'UTC+00:00');
        }

        return createODBCDateTime(local.utcDate);

    }


    public date function utc2local(required date utcDate, required string timezone) {

        local.hourDiff = replace(replace(arguments.timezone, "UTC", ""), ":00", "");
        local.newDate = dateAdd("h", local.hourDiff, arguments.utcDate);

        return createODBCDateTime(local.newDate);


    }



}