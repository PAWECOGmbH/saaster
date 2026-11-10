<cfset deletionState = new backend.core.com.account_lifecycle().deletionState(deletionCustomerID)>
<cfoutput>
<div class="modal modal-blur fade" id="#encodeForHTMLAttribute(deletionModalID)#" tabindex="-1" aria-labelledby="#encodeForHTMLAttribute(deletionModalID)#-title" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-status bg-danger"></div>
            <div class="modal-header">
                <h3 class="modal-title" id="#encodeForHTMLAttribute(deletionModalID)#-title">#getTrans(deletionState.pending ? 'btnAccountDeletionRetry' : 'titDeleteAccount')#</h3>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="#encodeForHTMLAttribute(getTrans('btnClose'))#"></button>
            </div>
            <form action="#application.mainURL#/cancel" method="post">
                #csrfField()#
                <input type="hidden" name="delete" value="#deletionCustomerID#">
                <div class="modal-body">
                    <p class="fw-bold">#encodeForHTML(deletionCustomerName)#</p>
                    <cfif deletionState.children gt 0>
                        <div class="alert alert-warning">#getTrans('msgAccountHasTenants')#</div>
                    <cfelseif deletionState.protected>
                        <div class="alert alert-warning">#getTrans('msgAccountDeletionDenied')#</div>
                    <cfelse>
                        <cfif deletionState.status eq 'failed'>
                            <div class="alert alert-danger">#getTrans('msgAccountDeletionFailed')#</div>
                        <cfelseif deletionState.pending>
                            <div class="alert alert-warning">#getTrans('msgAccountDeletionStarted')#</div>
                        </cfif>
                        <p>#getTrans('txtAccountDeletionWarning')#</p>
                        <label class="form-label" for="#encodeForHTMLAttribute(deletionModalID)#-password">#getTrans('txtAccountDeletionPassword')#</label>
                        <input id="#encodeForHTMLAttribute(deletionModalID)#-password" type="password" name="password" class="form-control mb-3" autocomplete="current-password" required>
                        <label class="form-check">
                            <input class="form-check-input" type="checkbox" name="confirm_delete" value="1" required>
                            <span class="form-check-label">#getTrans('txtAccountDeletionConfirm')#</span>
                        </label>
                    </cfif>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn" data-bs-dismiss="modal">#getTrans('btnClose')#</button>
                    <cfif deletionState.children eq 0 and not deletionState.protected>
                        <button type="submit" class="btn btn-danger">#getTrans(deletionState.pending ? 'btnAccountDeletionRetry' : 'btnDeleteDefinitely')#</button>
                    </cfif>
                </div>
            </form>
        </div>
    </div>
</div>
</cfoutput>
