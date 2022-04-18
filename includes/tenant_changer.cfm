
<cfset qTenants = application.objCustomer.getAllTenants(session.user_id)>

<cfif qTenants.recordCount gt 1>

<cfoutput>
<ul class="navbar-nav">
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="##navbar-third" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false" >
            <cfif len(trim('#getCustomerData.strLogo#'))>
                <img src="#application.mainURL#/userdata/images/logos/#getCustomerData.strLogo#" class="avatar avatar-sm me-3 align-self-center" alt="#getCustomerData.strCompanyName#">
                <span class="nav-link-title">#getCustomerData.strCompanyName#</span>
            <cfelse>
                <div class="avatar avatar-sm me-3 align-self-center">#left(getCustomerData.strCompanyName,2)#</div>
                <span class="nav-link-title">#getCustomerData.strCompanyName#</span>
            </cfif>

        </a>
        <div class="dropdown-menu">
            <cfloop query="qTenants">
                <cfif qTenants.blnActive eq 1>
                    <a href="#application.mainURL#/global?switch=#qTenants.intCustomerID#" class="dropdown-item">
                        <cfif len(trim(qTenants.strLogo))>
                            <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" class="avatar avatar-sm me-3 align-self-center" alt="#qTenants.strCompanyName#">
                            #qTenants.strCompanyName#
                        <cfelse>
                            <div class="avatar avatar-sm me-3 align-self-center">#left(qTenants.strCompanyName,2)#</div>
                            #qTenants.strCompanyName#
                        </cfif>
                    </a>
                </cfif>
            </cfloop>
        </div>
    </li>
</ul>
</cfoutput>

</cfif>

