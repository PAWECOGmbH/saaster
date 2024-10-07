component displayname="job_positions" output="false" extends="backend.myapp.com.init" {

    public array function getJobPositions() {

        local.qJobPositions = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intJobPositionID, strName, blnActive,
                (
                    IF(
                        (
                            SELECT COUNT(intAdID)
                            FROM ss_ads
                            WHERE intJobPositionID = ss_job_positions.intJobPositionID
                        ) > 0, 0, 1
                    )
                ) as canDelete
                FROM ss_job_positions
                ORDER BY strName
            "
        );

        local.arrayJobPositions = [];
        loop query=local.qJobPositions {
            local.structPosition = {};
            local.structPosition['id'] = local.qJobPositions.intJobPositionID;
            local.structPosition['name'] = local.qJobPositions.strName;
            local.structPosition['active'] = local.qJobPositions.blnActive;
            local.structPosition['canDelete'] = local.qJobPositions.canDelete;
            arrayAppend(local.arrayJobPositions, local.structPosition);
        }

        return local.arrayJobPositions;

    }

    public struct function newJobPosition(required struct position) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    position: {type: "nvarchar", value = arguments.position.position_new},
                    active: {type: "boolean", value = arguments.position.active}
                },
                sql = "
                    INSERT INTO ss_job_positions (strName, blnActive)
                    VALUES (:position, :active)
                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Position wurde erfolgreich erfasst.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Position konnte nicht erfasst werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function updateJobPosition(required struct position) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    position: {type: "nvarchar", value = arguments.position.position},
                    active: {type: "boolean", value = arguments.position.active},
                    positionID: {type: "numeric", value = arguments.position.position_edit}
                },
                sql = "
                    UPDATE ss_job_positions
                    SET strName = :position,
                        blnActive = :active
                    WHERE intJobPositionID = :positionID
                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Position wurde erfolgreich gespeichert.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Position konnte nicht gespeichert werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


    public struct function deleteJobPosition(required struct position) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    positionID: {type: "numeric", value = arguments.position.position_edit}
                },
                sql = "

                    DELETE FROM ss_job_positions
                    WHERE intJobPositionID = :positionID;

                    UPDATE ss_ads
                    SET intJobPositionID = NULL
                    WHERE intJobPositionID = :positionID;

                "
            );

            variables.argsReturnValue.success = true;
            variables.argsReturnValue.message = "Die Position wurde erfolgreich gelöscht.";


        } catch (any e) {

            variables.argsReturnValue.message = "Die Position konnte nicht gelöscht werden: " & e.message;

        }

        return variables.argsReturnValue;

    }


}