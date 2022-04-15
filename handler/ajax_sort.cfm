<cfsetting showdebugoutput="no">

<cfscript>

if (!structKeyExists(session, "user_id")) {
    getAlert('alertSessionExpired', 'warning');
    location url="#application.mainURL#/login" addtoken="false";
}

if (structKeyExists(url, "extend")) {
    sqlExtend = url.extend;
} else {
    sqlExtend = "";
}

if (structKeyExists(url, "languages")) {
    thisTable = "languages";
}
if (structKeyExists(url, "countries")) {
    thisTable = "countries";
}
if (structKeyExists(url, "modules")) {
    thisTable = "modules";
}
if (structKeyExists(url, "currencies")) {
    thisTable = "currencies";
}
if (structKeyExists(url, "plangroups")) {
    thisTable = "plan_groups";
}
if (structKeyExists(url, "plangroups")) {
    thisTable = "plan_groups";
}
if (structKeyExists(url, "plans")) {
    thisTable = "plans";
}
if (structKeyExists(url, "planfeatures")) {
    thisTable = "plan_features";
}

param name="response" default="ok";

requestBody = toString( getHttpRequestData().content );

if (isJSON(requestBody)) {

    data = deserializeJSON(requestBody);
    datax = deserializeJSON(data);

    thisPrimKey = application.objGlobal.getPrimaryKey(thisTable);

    loop array=datax index="i" {
        try {
            if (isArray(i)) {
                loop array=i index="j" {
                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            thisPrio: {type: "numeric", value: j.prio},
                            thisID: {type: "numeric", value: evaluate('j.#thisPrimKey#')}
                        },
                        sql = "
                            UPDATE #thisTable#
                            SET intPrio = :thisPrio
                            WHERE #thisPrimKey# = :thisID
                            #sqlExtend#
                        "
                    )

                }
            }

        } catch (any e) {

            getAlert(e.message, 'danger');

        }

    }

}

writeOutput(response);

</cfscript>