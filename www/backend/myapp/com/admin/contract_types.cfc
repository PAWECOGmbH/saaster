component displayname="industries" output="false" extends="backend.myapp.com.init" {

    public array function getContractTypes() {

        local.qContractTypes = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intContractTypeID, strName, blnActive,
                (
                    IF(
                        (
                            SELECT COUNT(intAdID)
                            FROM ss_ads
                            WHERE intContractTypeID = ss_contract_types.intContractTypeID
                        ) > 0, 0, 1
                    )
                ) as canDelete
                FROM ss_contract_types
                ORDER BY strName
            "
        );

        local.arrayContractTypes = [];
        loop query=local.qContractTypes {
            local.structTypes = {};
            local.structTypes['id'] = local.qContractTypes.intContractTypeID;
            local.structTypes['name'] = local.qContractTypes.strName;
            local.structTypes['active'] = local.qContractTypes.blnActive;
            local.structTypes['canDelete'] = local.qContractTypes.canDelete;
            arrayAppend(local.arrayContractTypes, local.structTypes);
        }

        return local.arrayContractTypes;

    }


    public struct function newContractType(required struct contract) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    contract: {type: "nvarchar", value = arguments.contract.contract_new},
                    active: {type: "boolean", value = arguments.contract.active}
                },
                sql = "
                    INSERT INTO ss_contract_types (strName, blnActive)
                    VALUES (:contract, :active)
                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Vertragsart wurde erfolgreich erfasst.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Vertragsart konnte nicht erfasst werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function updateContractType(required struct contract) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    contract: {type: "nvarchar", value = arguments.contract.contract},
                    active: {type: "boolean", value = arguments.contract.active},
                    contractID: {type: "numeric", value = arguments.contract.contract_edit}
                },
                sql = "
                    UPDATE ss_contract_types
                    SET strName = :contract,
                        blnActive = :active
                    WHERE intContractTypeID = :contractID
                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Vertragsart wurde erfolgreich gespeichert.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Vertragsart konnte nicht gespeichert werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function deleteContractType(required struct contract) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    contractID: {type: "numeric", value = arguments.contract.contract_edit}
                },
                sql = "

                    DELETE FROM ss_contract_types
                    WHERE intContractTypeID = :contractID;

                    UPDATE ss_ads
                    SET intContractTypeID = NULL
                    WHERE intContractTypeID = :contractID;

                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Vertragsart wurde erfolgreich gelöscht.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Vertragsart konnte nicht gelöscht werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


}