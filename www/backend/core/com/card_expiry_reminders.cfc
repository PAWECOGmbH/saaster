component output="false" {
    public struct function run(date asOf = now()) {
        local.counts = {checked:0, sent:0};
        local.cards = queryExecute(
            options = {datasource:application.datasource},
            sql = "SELECT p.intPayrexxID, p.intCustomerID, p.intTransactionID
                FROM payrexx p INNER JOIN customers c ON c.intCustomerID=p.intCustomerID AND c.blnActive=1
                WHERE p.strStatus='authorized' AND p.blnDefault=1 AND p.blnFailed=0
                    AND p.intTransactionID>0
                    AND (p.dtmExpiryCheckedAt IS NULL OR p.dtmExpiryCheckedAt < UTC_TIMESTAMP() - INTERVAL 1 DAY)
                    AND EXISTS (SELECT 1 FROM bookings b WHERE b.intCustomerID=p.intCustomerID
                        AND b.strRecurring IN ('monthly','yearly') AND b.strStatus IN ('active','expired','waiting'))
                ORDER BY COALESCE(p.dtmExpiryCheckedAt,'1970-01-01'), p.intPayrexxID LIMIT 100"
        );
        loop query=local.cards {
            try {
                if (refreshAndRemind(local.cards.intPayrexxID, local.cards.intCustomerID, local.cards.intTransactionID, arguments.asOf)) {
                    local.counts.sent++;
                }
                local.counts.checked++;
            } catch (any e) {
                application.objLog.logWrite("scheduletask", "warning",
                    "Card expiry check failed [PayrexxID: #local.cards.intPayrexxID#, CustomerID: #local.cards.intCustomerID#, Error: #e.message#]");
            }
        }
        return local.counts;
    }

    private boolean function refreshAndRemind(required numeric paymentID, required numeric customerID, required numeric transactionID, required date asOf) {
        local.params = {
            paymentID:{type:"integer",value:arguments.paymentID},
            customerID:{type:"integer",value:arguments.customerID},
            transactionID:{type:"bigint",value:arguments.transactionID}
        };
        queryExecute(
            options = {datasource:application.datasource,result:"local.claimResult"},
            params = local.params,
            sql = "UPDATE payrexx SET dtmExpiryCheckedAt=UTC_TIMESTAMP()
                WHERE intPayrexxID=:paymentID AND intCustomerID=:customerID
                    AND intTransactionID=:transactionID AND blnDefault=1
                    AND strStatus='authorized' AND blnFailed=0
                    AND (dtmExpiryCheckedAt IS NULL OR dtmExpiryCheckedAt < UTC_TIMESTAMP() - INTERVAL 1 DAY)"
        );
        if (!local.claimResult.recordCount) return false;
        local.response = new backend.core.com.payrexx().callPayrexx({}, "GET", "Transaction", arguments.transactionID);
        if (local.response.status neq "success" or val(local.response.httpStatus ?: 0) lt 200
            or val(local.response.httpStatus ?: 0) gte 300 or !isArray(local.response.data ?: "")
            or arrayLen(local.response.data) neq 1
            or val(local.response.data[1].id ?: 0) neq arguments.transactionID
            or (local.response.data[1].status ?: "") neq "authorized"
            or !isStruct(local.response.data[1].payment ?: "")) return false;
        local.expiry = new backend.core.com.payrexx().normalizeCardExpiry(local.response.data[1].payment.expiry ?: "");
        if (!len(local.expiry)) return false;
        queryExecute(
            options = {datasource:application.datasource},
            params = {paymentID:local.params.paymentID,transactionID:local.params.transactionID,
                expiry:{type:"char",value:local.expiry}},
            sql = "UPDATE payrexx SET strCardExpiry=:expiry
                WHERE intPayrexxID=:paymentID AND intTransactionID=:transactionID
                    AND blnDefault=1 AND strStatus='authorized'"
        );
        local.expiryDate = dateAdd("d",-1,dateAdd("m",1,
            createDate(2000+val(left(local.expiry,2)),val(right(local.expiry,2)),1)));
        local.today = createDate(year(arguments.asOf),month(arguments.asOf),day(arguments.asOf));
        if (local.today gt local.expiryDate) return false;
        if (local.today gte dateAdd("d",-7,local.expiryDate)) {
            local.stage = "week";
        } else if (local.today gte dateAdd("m",-1,local.expiryDate)) {
            local.stage = "month";
        } else {
            return false;
        }
        local.current = queryExecute(
            options = {datasource:application.datasource},
            params = {paymentID:local.params.paymentID,customerID:local.params.customerID,
                transactionID:local.params.transactionID,expiry:{type:"char",value:local.expiry}},
            sql = "SELECT p.intPayrexxID FROM payrexx p
                INNER JOIN customers c ON c.intCustomerID=p.intCustomerID AND c.blnActive=1
                WHERE p.intPayrexxID=:paymentID AND p.intCustomerID=:customerID
                    AND p.intTransactionID=:transactionID AND p.strCardExpiry=:expiry
                    AND p.strStatus='authorized' AND p.blnDefault=1 AND p.blnFailed=0
                    AND EXISTS (SELECT 1 FROM bookings b WHERE b.intCustomerID=p.intCustomerID
                        AND b.strRecurring IN ('monthly','yearly') AND b.strStatus IN ('active','expired','waiting'))"
        );
        if (!local.current.recordCount) return false;
        return sendOnce(arguments.paymentID,arguments.customerID,local.expiry,local.expiryDate,local.stage);
    }

    private boolean function sendOnce(required numeric paymentID, required numeric customerID,
        required string expiry, required date expiryDate, required string stage) {
        local.token = createUUID();
        local.params = {
            paymentID:{type:"integer",value:arguments.paymentID},
            expiry:{type:"char",value:arguments.expiry},
            stage:{type:"varchar",value:arguments.stage},
            token:{type:"char",value:local.token}
        };
        queryExecute(
            options = {datasource:application.datasource},
            params = local.params,
            sql = "INSERT IGNORE INTO card_expiry_reminders
                (intPayrexxID,strCardExpiry,strStage,strClaimToken,dtmClaimedAt)
                VALUES (:paymentID,:expiry,:stage,:token,UTC_TIMESTAMP())"
        );
        queryExecute(
            options = {datasource:application.datasource},
            params = local.params,
            sql = "UPDATE card_expiry_reminders SET strClaimToken=:token,dtmClaimedAt=UTC_TIMESTAMP()
                WHERE intPayrexxID=:paymentID AND strCardExpiry=:expiry AND strStage=:stage
                    AND dtmSentAt IS NULL AND dtmClaimedAt < UTC_TIMESTAMP() - INTERVAL 1 HOUR"
        );
        local.claim = queryExecute(
            options = {datasource:application.datasource},
            params = local.params,
            sql = "SELECT intCardExpiryReminderID FROM card_expiry_reminders
                WHERE intPayrexxID=:paymentID AND strCardExpiry=:expiry AND strStage=:stage
                    AND strClaimToken=:token AND dtmSentAt IS NULL"
        );
        if (!local.claim.recordCount) return false;
        try {
            local.invoices = new backend.core.com.invoices();
            local.email = local.invoices.getInvoiceEmail(customerID=arguments.customerID);
            if (!application.objGlobal.checkEmail(local.email)) {
                throw(type="CardExpiry.NoRecipient",message="No valid billing email is available.");
            }
            local.language = local.invoices.getInvoiceLanguage(arguments.customerID);
            variables.mailLanguage = local.language;
            variables.getTrans = application.objLanguage.getTrans;
            local.subjectKey = arguments.stage eq "week" ? "subjectCardExpiryWeek" : "subjectCardExpiryMonth";
            local.messageKey = arguments.stage eq "week" ? "msgCardExpiryWeek" : "msgCardExpiryMonth";
            variables.mailTitle = application.objLanguage.getTrans(local.subjectKey,local.language);
            local.expiryLabel = dateFormat(arguments.expiryDate,"mm/yyyy");
            local.message = replace(application.objLanguage.getTrans(local.messageKey,local.language),
                "{expiry}",local.expiryLabel,"all");
            variables.mailContent = "<p>" & encodeForHTML(local.message) & "</p><p><a class='mail-btn' href='"
                & encodeForHTMLAttribute(application.mainURL & "/account-settings/payment") & "'>"
                & encodeForHTML(application.objLanguage.getTrans("btnUpdatePaymentMethod",local.language))
                & "</a></p>";
            mail to="#local.email#" from="#application.fromEmail#" subject="#variables.mailTitle#" type="html" {
                include template="/config.cfm";
                include template="/frontend/core/mail_design.cfm";
            }
            queryExecute(
                options = {datasource:application.datasource},
                params = local.params,
                sql = "UPDATE card_expiry_reminders SET dtmSentAt=UTC_TIMESTAMP()
                    WHERE intPayrexxID=:paymentID AND strCardExpiry=:expiry
                        AND strStage=:stage AND strClaimToken=:token AND dtmSentAt IS NULL"
            );
            return true;
        } catch (any e) {
            queryExecute(
                options = {datasource:application.datasource},
                params = local.params,
                sql = "DELETE FROM card_expiry_reminders
                    WHERE intPayrexxID=:paymentID AND strCardExpiry=:expiry
                        AND strStage=:stage AND strClaimToken=:token AND dtmSentAt IS NULL"
            );
            rethrow;
        }
    }
}
