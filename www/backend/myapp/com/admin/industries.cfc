component displayname="industries" output="false" extends="backend.myapp.com.init" {

    public query function getIndustries(boolean getProposals) {

        local.proposals = 0;
        if (structKeyExists(arguments, "getProposals") and arguments.getProposals eq 1) {
            local.proposals = 1;
        }

        local.qIndustries = queryExecute(
            options = {datasource = application.datasource},
            params = {
                proposals: {type: "boolean", value = local.proposals}
            },
            sql = "
                SELECT intIndustryID, strName, blnActive, blnProposal
                FROM ss_industries
                WHERE blnProposal = :proposals
                ORDER BY strName
            "
        );

        return local.qIndustries;

    }

    public struct function newIndustry(required struct industry) {

        try {

            local.qIndustries = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    industry: {type: "nvarchar", value = arguments.industry.industry_new},
                    active: {type: "boolean", value = arguments.industry.active}
                },
                sql = "
                    INSERT INTO ss_industries (strName, blnActive, blnProposal)
                    VALUES (:industry, :active, 0)
                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Branche wurde erfolgreich erfasst.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Branche konnte nicht erfasst werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function updateIndustry(required struct industry) {

        try {

            local.qIndustries = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    industry: {type: "nvarchar", value = arguments.industry.industry},
                    active: {type: "boolean", value = arguments.industry.active},
                    industryID: {type: "numeric", value = arguments.industry.industry_edit}
                },
                sql = "
                    UPDATE ss_industries
                    SET strName = :industry,
                        blnActive = :active
                    WHERE intIndustryID = :industryID
                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Branche wurde erfolgreich gespeichert.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Branche konnte nicht gespeichert werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function deleteIndustry(required struct industry) {

        try {

            local.qIndustries = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    industryID: {type: "numeric", value = arguments.industry.industry_edit}
                },
                sql = "
                    DELETE FROM ss_industries
                    WHERE intIndustryID = :industryID
                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Branche wurde erfolgreich gelöscht.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Branche konnte nicht gelöscht werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function editProposal(required struct proposal) {

        local.industryID = arguments.proposal.proposal;

        // Accept
        if (structKeyExists(arguments.proposal, "accept")) {

            try {

                local.qIndustries = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        industryID: {type: "numeric", value = local.industryID}
                    },
                    sql = "
                        UPDATE ss_industries
                        SET blnActive = 1,
                            blnProposal = 0
                        WHERE intIndustryID = :industryID
                    "
                );

                variables.argsReturnValue.success = true;
                variables.argsReturnValue.message = "Die Branche wurde erfolgreich aufgenommen.";


            } catch (any e) {

                variables.argsReturnValue.message = "Die Branche konnte nicht aufgenommen werden: " & e.message;

            }

            return variables.argsReturnValue;

        }


        // Decline
        if (structKeyExists(arguments.proposal, "decline")) {

            try {

                local.qIndustries = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        industryID: {type: "numeric", value = local.industryID}
                    },
                    sql = "
                        DELETE FROM ss_industries
                        WHERE intIndustryID = :industryID
                    "
                );

                variables.argsReturnValue.success = true;
                variables.argsReturnValue.message = "Die Branche wurde abgelehnt und gelöscht.";


            } catch (any e) {

                variables.argsReturnValue.message = "Die Branche konnte nicht gelöscht werden: " & e.message;

            }

            return variables.argsReturnValue;

        }

    }

}