
<cfscript>

// This code generates an SQL script that formats all entries from the given table

if (structKeyExists(session, "sysadmin") and session.sysadmin) {

    if (structKeyExists(url, "sql_table")) {

        param name="url.prim_key" default="strVariable";
        writeOutput(application.objSettings.generateSqlCode(url.sql_table, url.prim_key));

        // For frontend mappings we also need the table frontend_mappings_trans
        if (url.sql_table eq "frontend_mappings") {

            writeOutput(application.objSettings.generateSqlCode("frontend_mappings_trans", "strMapping"));

        }

    }

}

</cfscript>