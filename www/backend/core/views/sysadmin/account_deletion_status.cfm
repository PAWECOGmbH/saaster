<cfscript>
    deletionState = new backend.core.com.account_lifecycle().deletionState(thisCustomerID);
    if (deletionState.pending) {
        deletionOperations = queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:thisCustomerID}},
            sql="SELECT strKind, strStatus, intInvoiceID, strPaymentReference FROM account_operations WHERE intCustomerID = :id ORDER BY dtmStartedAt");
    }
</cfscript>
<cfif deletionState.pending>
<cfoutput>
<div class="alert alert-warning d-block" role="status">
    <h4 class="alert-title">#deletionState.status eq 'failed' ? 'Account cleanup failed' : 'Account deletion pending'#</h4>
    <p>Access and subscriptions are stopped. The account has not been fully deleted.</p>
    <cfif deletionState.error eq 'operations'>
        <p>Waiting for running work or payment verification. A retry never discards unresolved payments.</p>
    <cfelseif deletionState.status eq 'failed'>
        <p>Cleanup could not finish. Check the system log and the affected module or payment service, then retry.</p>
    </cfif>
    <cfif deletionOperations.recordCount>
        <ul>
        <cfloop query="deletionOperations">
            <li>#listFind('charge,checkout', deletionOperations.strKind) ? 'Payment verification' : 'Running account operation'#<cfif val(deletionOperations.intInvoiceID)> · Invoice ID #val(deletionOperations.intInvoiceID)#</cfif><cfif len(trim(deletionOperations.strPaymentReference))> · Reference: #encodeForHTML(deletionOperations.strPaymentReference)#</cfif></li>
        </cfloop>
        </ul>
    </cfif>
    <button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="##delete-customer">Retry deletion</button>
</div>
</cfoutput>
</cfif>
