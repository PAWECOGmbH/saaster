
<cfset qTenants = application.objCustomer.getAllTenants(session.user_id)>

<cfif qTenants.recordCount gt 1>

<cfoutput>
<ul class="navbar-nav">
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="##navbar-third" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false" >
            <cfif len(trim(getCustomerData.companyName))>
                <cfif len(trim(getCustomerData.logo))>
                    <img src="#application.mainURL#/userdata/images/logos/#getCustomerData.logo#" class="avatar avatar-sm me-3 align-self-center" alt="#getCustomerData.companyName#">
                    <span class="nav-link-title d-none d-sm-none d-md-block">#getCustomerData.companyName#</span>
                <cfelse>
                    <div class="avatar avatar-sm me-3 align-self-center">#left(getCustomerData.companyName,2)#</div>
                    <span class="nav-link-title d-none d-sm-none d-md-block">#getCustomerData.companyName#</span>
                </cfif>
            <cfelse>
                <cfif len(trim(getCustomerData.logo))>
                    <img src="#application.mainURL#/userdata/images/logos/#getCustomerData.logo#" class="avatar avatar-sm me-3 align-self-center" alt="#getCustomerData.companyName#">
                    <span class="nav-link-title d-none d-sm-none d-md-block">#getCustomerData.contactPerson#</span>
                <cfelse>
                    <div class="avatar avatar-sm me-3 align-self-center">#left(getCustomerData.contactPerson,2)#</div>
                    <span class="nav-link-title d-none d-sm-none d-md-block">#getCustomerData.contactPerson#</span>
                </cfif>
            </cfif>
        </a>
        <div class="dropdown-menu">
            <cfloop query="qTenants">
                <cfif qTenants.blnActive eq 1>
                    <a href="#application.mainURL#/global?switch=#qTenants.intCustomerID#" class="dropdown-item">
                        <cfif len(trim(qTenants.strCompanyName))>
                            <cfif len(trim(qTenants.strLogo))>
                                <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" class="avatar avatar-sm me-3 align-self-center" alt="#qTenants.strCompanyName#">
                                <cfif len(trim(qTenants.strCompanyName)) gt 12>
                                    #qTenants.strCompanyName.left(12)#..
                                <cfelse>
                                    #qTenants.strCompanyName#
                                </cfif>
                            <cfelse>
                                <div class="avatar avatar-sm me-3 align-self-center">#left(qTenants.strCompanyName,2)#</div>
                                <cfif len(trim(qTenants.strCompanyName)) gt 12>
                                    #qTenants.strCompanyName.left(12)#..
                                <cfelse>
                                    #qTenants.strCompanyName#
                                </cfif>
                            </cfif>
                        <cfelse>
                            <cfif len(trim(qTenants.strLogo))>
                                <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" class="avatar avatar-sm me-3 align-self-center" alt="#qTenants.strContactPerson#">
                                <cfif len(trim(qTenants.strContactPerson)) gt 12>
                                    #qTenants.strContactPerson.left(12)#..
                                <cfelse>
                                    #qTenants.strContactPerson#
                                </cfif>
                            <cfelse>
                                <div class="avatar avatar-sm me-3 align-self-center">#left(qTenants.strContactPerson,2)#</div>
                                <span class="nav-link-title">
                                    <cfif len(trim(qTenants.strContactPerson)) gt 12>
                                        #qTenants.strContactPerson.left(12)#..
                                    <cfelse>
                                        #qTenants.strContactPerson#
                                    </cfif>
                                </span>
                            </cfif>
                        </cfif>
                    </a>
                </cfif>
            </cfloop>
        </div>
    </li>
</ul>
</cfoutput>

</cfif>

