component extends="taffy.core.resource" taffy_uri="/authenticate" {

    function get(){

        local.apiID = request._taffyrequest.headers.apiID ?: 0;
        local.apiKey = request._taffyrequest.headers.apiKey ?: 0;

        if(local.apiID eq 0 or local.apiKey eq 0){
            return noData().withStatus(400);
        }
        
        local.qCheckApiKey = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisApiID: {type: "numeric", value: local.apiID},
            },
            sql = "
                SELECT strApiName, strApiKeyHash, strApiKeySalt, dtmValidUntil
                FROM api_management
                WHERE intApiID = :thisApiID
                LIMIT 1
            "
        )

        // Check if the provided API key is valid
        local.apiKeyValid = local.qCheckApiKey.strApiKeyHash eq hash(local.apiKey & qCheckApiKey.strApiKeySalt, 'SHA-512')

        // Return 401 when api key isn't valid
        if(not local.apiKeyValid){
            return noData().withStatus(401);
        }

        // Return 401 when api key is no longer valid
        if(now().Diff("d", local.qCheckApiKey.dtmValidUntil) < 0){
            return noData().withStatus(401);
        }

        local.validUntil = dateAdd("s", 60, now())

        local.startDate = createdatetime( '1970','01','01','00','00','00');
        local.unixStamp = datediff("s", local.startDate, local.validUntil);

        local.subHash = hash(qCheckApiKey.strApiName & now());
        local.nonceUUID = createUUID();

        local.payload = {
            "iss": application.issJWT,
            "sub": local.subHash,
            "iat": now(),
            "exp": local.unixStamp,
            "nonce": local.nonceUUID,
        }

        local.enocodedJWT = application.jwt.encode(local.payload, application.apiSecret, 'HS256');

        // Write nonce to to api_nonce table
        local.qInsertNonce = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisNonceUUID: {type: "string", value: local.nonceUUID},
                thisCreationTime: {type: "datetime", value: now()},
                thisCreatedBy: {type: "numeric", value: local.apiID}
            },
            sql = "
                INSERT INTO api_nonce (strNonceUUID, dtmNonceCreated, intCreatedBy)
                VALUES (:thisNonceUUID, :thisCreationTime, :thisCreatedBy)
            "
        )

        return rep(["token" : local.enocodedJWT]);
    }

}