<cfsetting showdebugoutput="no">


<cfscript>

if (structKeyExists(url, "extend")) {
    sqlExtend = url.extend;
} else {
    sqlExtend = "";
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

                    sqlstr = "
                    UPDATE #thisTable#
                    SET intPrio = #prio#
                    WHERE intPlanGroupID = #group_idx#
                    AND #thisPrimKey# = #thisID#
                    "
                    //writedump(sqlstr);


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