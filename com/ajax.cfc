component displayname="ajax" output="false" {

    public query function getCountry(required numeric countryID){

        local.qCountry = queryExecute(
            options = {datasource = application.datasource},
            params = {
                countryID: {type: "numeric", value: arguments.countryID}
            },
            sql = "
                SELECT *
                FROM countries
                WHERE intCountryID = :countryID
            "
        )

        return local.qCountry;
    }

    public query function getCountries(){

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 1
            "
        )

        return local.qCountries;
    }

    public query function getCustomer(required string search){

        local.qCustomer = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intCustomerID, strZIP, strCity,
                    IF(
                        LENGTH(customers.strCompanyName),
                        customers.strCompanyName,
                        customers.strContactPerson
                    ) as customerName
                FROM customers
                WHERE blnActive = 1
                AND (
                    strCompanyName LIKE '%#arguments.search#%' OR
                    strContactPerson LIKE '%#arguments.search#%' OR
                    strZIP LIKE '%#arguments.search#%' OR
                    strCity LIKE '%#arguments.search#%'
                )
                ORDER BY strCompanyName
                LIMIT 10
            "
        )

        return local.qCustomer;
    }

}