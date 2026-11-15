<cfoutput>
<cfif moduleAccessManaged>
    <div class="modal fade" id="module-access-#module.moduleID#" tabindex="-1" aria-labelledby="module-access-title-#module.moduleID#" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form method="post" action="#application.mainURL#/sysadm/modules">
                    #csrfField()#
                    <input type="hidden" name="module_access_action" value="#moduleAccessBlocked ? 'unblock' : 'block'#">
                    <input type="hidden" name="customer_id" value="#thisCustomerID#">
                    <input type="hidden" name="module_id" value="#module.moduleID#">
                    <div class="modal-header">
                        <h5 class="modal-title" id="module-access-title-#module.moduleID#">#moduleAccessBlocked ? 'Unblock module' : 'Block module'#</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p><strong>#encodeForHTML(module.name)#</strong><br>#encodeForHTML(getCustomer.companyName)#</p>
                        <p class="mb-0">#moduleAccessBlocked ? 'Unblocking only removes the access restriction. Access and scheduler runs resume if a valid booking exists. The subscription period is not extended.' : 'Blocking prevents module access and further scheduler runs. Tasks already running may finish. Billing and the subscription period continue; customer data is preserved.'#</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn #moduleAccessBlocked ? 'btn-primary' : 'btn-danger'#">#moduleAccessBlocked ? 'Unblock module' : 'Block module'#</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</cfif>
</cfoutput>
