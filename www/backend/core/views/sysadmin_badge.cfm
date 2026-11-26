<cfif structKeyExists(session, "sysadmin") and session.sysadmin and !findNoCase("frontend", thiscontent.thisPath)>
    <span class="sysadmin-badge badge bg-red text-red-fg rounded-pill fs-5 d-inline-flex align-items-center gap-1 align-self-center flex-shrink-0 ms-0 me-2">
        <strong>SysAdmin</strong>
        <span class="fw-normal">English only</span>
    </span>
</cfif>
