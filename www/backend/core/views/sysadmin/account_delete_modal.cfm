<cfset deletionState = new backend.core.com.account_lifecycle().deletionState(thisCustomerID)>
<cfoutput>
<div class="modal modal-blur fade" id="delete-customer" tabindex="-1" aria-labelledby="delete-customer-title" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-status bg-danger"></div>
            <div class="modal-header">
                <h3 class="modal-title" id="delete-customer-title">#deletionState.pending ? 'Retry account deletion' : 'Delete account'#</h3>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="#application.mainURL#/sysadm/customers" method="post">
                #csrfField()#
                <input type="hidden" name="delete_account" value="#thisCustomerID#">
                <div class="modal-body">
                    <p class="fw-bold">#encodeForHTML(len(trim(getCustomer.companyName)) ? getCustomer.companyName : getCustomer.contactPerson)#</p>
                    <cfif deletionState.children gt 0>
                        <div class="alert alert-warning">Delete all tenants individually first. Inactive tenants and pending deletions also count.</div>
                    <cfelseif deletionState.protected>
                        <div class="alert alert-warning">Platform operator accounts cannot be deleted.</div>
                    <cfelse>
                        <p>Account access and module data will be permanently deleted. Subscriptions stop immediately. This action cannot be undone.</p>
                        <p class="text-muted">Issued invoices, their original PDFs and recorded payments are retained.</p>
                        <cfif deletionState.pending><div class="alert alert-warning">Deletion has already started. Retrying continues cleanup; it does not reactivate the account.</div></cfif>
                        <label class="form-label" for="delete-customer-password">Confirm with your own password</label>
                        <input id="delete-customer-password" type="password" name="password" class="form-control mb-3" autocomplete="current-password" required>
                        <label class="form-check">
                            <input class="form-check-input" type="checkbox" name="confirm_delete" value="1" required>
                            <span class="form-check-label">I confirm the permanent deletion of this account.</span>
                        </label>
                    </cfif>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn" data-bs-dismiss="modal">Close</button>
                    <cfif deletionState.children eq 0 and not deletionState.protected>
                        <button type="submit" class="btn btn-danger">#deletionState.pending ? 'Retry deletion' : 'Delete permanently'#</button>
                    </cfif>
                </div>
            </form>
        </div>
    </div>
</div>
</cfoutput>
