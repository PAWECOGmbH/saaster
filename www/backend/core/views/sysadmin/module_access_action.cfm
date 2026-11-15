<cfoutput>
<cfif moduleAccessManaged>
    <button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="##module-access-#module.moduleID#">
        #moduleAccessBlocked ? 'Unblock module' : 'Block module'#
    </button>
</cfif>
</cfoutput>
