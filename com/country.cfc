component displayname="country" output="false"{

    public query function getTotalCountriesSearch(required string search){

        local.qTotalCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 1
                AND MATCH (
                    countries.strCountryName,
                    countries.strLocale,
                    countries.strISO1,
                    countries.strISO2,
                    countries.strCurrency,
                    countries.strRegion,
                    countries.strSubRegion
                )
                #arguments.search#
            "
        );

        return local.qTotalCountries;
    }

    public query function getTotalCountries(){

        local.qTotalCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 1
            "
        );

        return local.qTotalCountries;
    }

    public query function getTotalCountriesImport(){

        local.qTotalCountries = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 0
            "
        );

        return local.qTotalCountries;
    }

    public query function getCountriesSearch(required string search, required numeric start){

        local.entries = 10;

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                AND MATCH (countries.strCountryName, countries.strLocale, countries.strISO1, countries.strISO2, countries.strCurrency, countries.strRegion, countries.strSubRegion)
                #arguments.search#
                ORDER BY #session.c_sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCountries;
    }

    public query function getCountries(required numeric start){

        local.entries = 10;

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                ORDER BY #session.c_sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCountries;
    }

    public query function getCountriesImportSearch(required string search){
        
        local.qCountries = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM countries
                WHERE blnActive = 0
                AND MATCH (
                    countries.strCountryName,
                    countries.strLocale,
                    countries.strISO1,
                    countries.strISO2,
                    countries.strCurrency,
                    countries.strRegion,
                    countries.strSubRegion
                )
                #arguments.search#
                ORDER BY #session.ci_sort#
            "
        );

        return local.qCountries;
    }

    public query function getCountriesImport(){

        local.qCountries = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM countries
                WHERE blnActive = 0
                ORDER BY #session.ci_sort#
            "
        );

        return local.qCountries;
    }

}