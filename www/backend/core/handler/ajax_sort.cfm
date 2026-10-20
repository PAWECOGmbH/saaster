<cfsetting showdebugoutput="no">


<cfscript>

/*
    Saves the drag-and-drop order of the sysadmin lists (languages, countries, modules,
    currencies, plan groups, plans, plan features, blog categories).

    This file is called directly by its path (no mapping), so neither the router's role
    checks nor the CSRF rule in Application.cfc cover it - it checks both itself.
*/
if (!(structKeyExists(session, "sysadmin") and session.sysadmin)) {
    cfheader(statuscode = 403, statustext = "Forbidden");
    writeOutput("Forbidden");
    abort;
}

if (cgi.request_method neq "POST" or !application.objGlobal.csrfVerify()) {
    cfheader(statuscode = 403, statustext = "Forbidden");
    writeOutput("Invalid CSRF token");
    abort;
}


thisTable = "";

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
if (structKeyExists(url, "plans")) {
    thisTable = "plans";
}
if (structKeyExists(url, "planfeatures")) {
    thisTable = "plan_features";
}
if (structKeyExists(url, "blog_categories")) {
    thisTable = "blog_categories";
}

// Unknown list: nothing to sort
if (!len(thisTable)) {
    cfheader(statuscode = 400, statustext = "Bad Request");
    writeOutput("Unknown list");
    abort;
}

param name="response" default="ok";

requestBody = toString( getHttpRequestData().content );

if(thisTable neq "plans"){

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
                            "
                        )

                    }
                }

            } catch (any e) {

                getAlert(e.message, 'danger');

            }

        }

    }

}else{

    if (isJSON(requestBody)) {

        data = deserializeJSON(requestBody);
        datax = deserializeJSON(data);
        thisPrimKey = application.objGlobal.getPrimaryKey(thisTable);

        groups = '';
        group_id = 0;

        loop from=1 to=arrayLen(datax)-1 index="i" {

            group_id = datax[i].group;

            if(!listFind(groups, group_id)){
                groups = listAppend(groups, group_id);
            }
        }


        loop list=groups index="group_idx" {

            //writedump(group_idx);

            prio = 1;

            loop from=1 to=arrayLen(datax)-1 index="i" {

                //writedump(datax[i]);

                if(datax[i].group eq group_idx){

                    thisID = datax[i].intPlanID;


                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            thisPrio: {type: "numeric", value: prio},
                            thisGroup: {type: "numeric", value: group_idx},
                            thisID: {type: "numeric", value: thisID}
                        },
                        sql = "
                            UPDATE #thisTable#
                            SET intPrio = :thisPrio
                            WHERE intPlanGroupID = :thisGroup
                            AND #thisPrimKey# = :thisID
                        "
                    )

                    prio++;

                }

            }

        }

    }

}


writeOutput(response);

</cfscript>