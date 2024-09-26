<cfset qTenants = application.objCustomer.getAllTenants(session.user_id)>

<cfscript>
    usersImgStruct = application.objUser.getUserImage(session.user_id);
    getSysadminData = application.objSysadmin.getSysAdminData();
</cfscript>

    <cfoutput>

        #getLayout.layoutDivStart#

        #getLayout.layoutHeader#

            <div class="#getLayout.layoutContainer#">

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="##navbar-menu" >
                    <span class="navbar-toggler-icon"></span>
                </button>

                <h1 class="#getLayout.layoutTitel#">
                    <cfif len(trim(getSysadminData.logo))>
                        <a href="#application.mainURL#/dashboard">
                            <img src="#application.mainURL#/userdata/images/logos/#getSysadminData.logo#" class="navbar-brand-image" alt="Logo">
                        </a>
                    <cfelse>
                        <a href="#application.mainURL#/dashboard">
                            <img src="#getLayout.layoutLogo#" alt="logo" class="navbar-brand-image">
                        </a>
                    </cfif>

                </h1>


                <div class="#getLayout.layoutDiv#">

                    <!--- Language changer --->
                    <div #getLayout.layoutClass#>
                        <cfif structKeyExists(application, "allLanguages") and listLen(application.allLanguages) gt 1>
                            <cfinclude template="lng.cfm">
                        </cfif>
                    </div>

                    <!--- Tenant changer --->
                    <div #getLayout.layoutClass#>
                        <cfinclude template="tenant_changer.cfm">
                    </div>

                    <!--- User menu --->
                    <div class="nav-item dropdown">

                        <a class="nav-link dropdown-toggle" href="##navbar-third" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false" >
                            <span class="avatar avatar-sm newclass" style="background-image: url(#usersImgStruct.userImage#)" ></span>
                            <div class="d-none d-xl-block ps-2 newclass">
                                <div>#session.user_name#</div>
                            </div>
                        </a>

                        <div class="dropdown-menu dropdown-menu-end dropdown-menu-arrow">

                            <a class="dropdown-item" href="#application.mainURL#/account-settings">
                                #getTrans('txtAccountSettings')#
                            </a>
                            <a class="dropdown-item" href="#application.mainURL#/account-settings/my-profile">
                                #getTrans('txtMyProfile')#
                            </a>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" href="#application.mainURL#/global?logout">
                                #getTrans('txtLogout')#
                            </a>

                        </div>

                    </div>
                </div>
                </cfoutput>
                <cfoutput>
                    <div class="collapse navbar-collapse" id="navbar-menu">
                    </cfoutput>
                        <ul class="navbar-nav pt-lg-3">
                            <li class="nav-item <cfif listlast(cgi.path_info, '/') eq 'dashboard'>active</cfif>">
                                <cfoutput>
                                <a href="#application.mainURL#/dashboard" class="nav-link">
                                </cfoutput>
                                    <span class="nav-link-icon d-none d-sm-none d-md-inline-block d-lg-inline-block">
                                        <i class="fas fa-home"></i>
                                    </span>
                                    <span class="nav-link-title">
                                        Home
                                    </span>
                                </a>
                                <div class="dropdown-divider d-block d-sm-block d-md-none"></div>
                            </li>

                            <!--- SysAdmin stuff --->
                            <cfif structKeyExists(session, "sysadmin") and session.sysadmin>
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle" href="#navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false">
                                        <span class="nav-link-icon d-none d-sm-none d-md-inline-block d-lg-inline-block">
                                            <i class="fas fa-user-cog"></i>
                                        </span>
                                        <span class="nav-link-title">
                                            SysAdmin
                                        </span>
                                    </a>
                                    <cfoutput>
                                    <div class="dropdown-menu">

                                        <span class="dropdown-header">Sales</span>
                                        <a href="#application.mainURL#/sysadmin/customers" class="dropdown-item">Customers</a>
                                        <a href="#application.mainURL#/sysadmin/invoices" class="dropdown-item">Invoices</a>
                                        <a href="#application.mainURL#/sysadmin/plans" class="dropdown-item">Plans</a>
                                        <a href="#application.mainURL#/sysadmin/modules" class="dropdown-item">Modules</a>
                                        <a href="#application.mainURL#/sysadmin/widgets" class="dropdown-item">Widgets</a>
                                        <div class="dropdown-divider"></div>

                                        <span class="dropdown-header">System</span>
                                        <a href="#application.mainURL#/sysadmin/system-settings" class="dropdown-item">System settings</a>
                                        <a href="#application.mainURL#/sysadmin/api-settings" class="dropdown-item">API settings</a>
                                        <a href="#application.mainURL#/sysadmin/languages" class="dropdown-item">Languages</a>
                                        <a href="#application.mainURL#/sysadmin/currencies" class="dropdown-item">Currencies</a>
                                        <a href="#application.mainURL#/sysadmin/countries" class="dropdown-item">Countries</a>
                                        <a href="#application.mainURL#/sysadmin/mappings" class="dropdown-item">Mappings</a>
                                        <a href="#application.mainURL#/sysadmin/translations" class="dropdown-item">Translations</a>
                                        <a href="#application.mainURL#/sysadmin/logs" class="dropdown-item">Logfiles</a>

                                    </div>
                                    </cfoutput>
                                </li>
                            </cfif>

                            <!--- Main navigation --->
                            <cfinclude template="/backend/myapp/navigation.cfm">

                            <!--- Modules --->
                            <cfif isArray(session.currentModules) and arrayLen(session.currentModules)>
                                <cfoutput>
                                <cfset moduleList = "">
                                <cfloop array="#session.currentModules#" index="i">
                                    <cfif structKeyExists(i.moduleData, "name") and i.moduleStatus.status neq "expired" and i.moduleStatus.status neq "payment" and not listFind(moduleList, i.moduleID)>
                                        <li class="nav-item dropdown">
                                            <a class="nav-link dropdown-toggle" href="##navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false">
                                                <span class="nav-link-title">
                                                    #i.moduleData.name#
                                                </span>
                                            </a>
                                            <div class="dropdown-menu">
                                                <cfif fileExists(expandPath('/modules/#i.moduleData.table_prefix#/navigation.cfm'))>
                                                    <cfinclude template="/modules/#i.moduleData.table_prefix#/navigation.cfm">
                                                    <div class="dropdown-divider"></div>
                                                </cfif>
                                                <cfif len(trim(i.moduleData.settingPath))>
                                                    <a href="#application.mainURL#/#i.moduleData.settingPath#" class="dropdown-item">#getTrans('txtSettings')#</a>
                                                </cfif>
                                            </div>
                                        </li>
                                    </cfif>
                                    <cfset moduleList = listAppend(moduleList, i.moduleID)>
                                </cfloop>
                                </cfoutput>
                            </cfif>
                            <!--- Tanent changer --->
                            <cfif qTenants.recordCount gt 1>
                                <li class="nav-item dropdown d-none d-sm-none d-md-inline-block d-lg-none">

                                    <cfoutput>
                                    <ul class="p-0">
                                        <li class="nav-item dropdown">
                                            <a class="nav-link dropdown-toggle" href="##navbar-third" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false" >
                                                <span class="nav-link-icon d-none d-sm-none d-md-inline-block d-lg-inline-block">
                                                    <i class="fas fa-users"></i>
                                                </span>
                                                <span class="nav-link-title">
                                                    #getTrans('titMandanten')#
                                                </span>
                                            </a>
                                            <div class="dropdown-menu">
                                                <cfloop query="qTenants">
                                                    <cfif qTenants.blnActive eq 1>
                                                        <a href="#application.mainURL#/global?switch=#qTenants.intCustomerID#" class="dropdown-item">
                                                            <cfif len(trim(qTenants.strCompanyName))>
                                                                <cfif len(trim(qTenants.strLogo))>
                                                                    <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" class="avatar avatar-sm me-3 align-self-center" alt="#qTenants.strCompanyName#">
                                                                    <cfif (len(qTenants.strCompanyName) gt 12)>
                                                                        <div class="d-none d-lg-inline-block">#qTenants.strCompanyName.left(12)#..</div>
                                                                        <div class="d-lg-none">#qTenants.strCompanyName#</div>
                                                                    <cfelse>
                                                                        #qTenants.strCompanyName#
                                                                    </cfif>
                                                                <cfelse>
                                                                    <div class="avatar avatar-sm me-3 align-self-center">#left(qTenants.strCompanyName,2)#</div>
                                                                    <cfif (len(qTenants.strCompanyName) gt 12)>
                                                                        <div class="d-none d-lg-inline-block">#qTenants.strCompanyName.left(12)#..</div>
                                                                        <div class="d-lg-none">#qTenants.strCompanyName#</div>
                                                                    <cfelse>
                                                                        #qTenants.strCompanyName#
                                                                    </cfif>
                                                                </cfif>
                                                            <cfelse>
                                                                <cfif len(trim(qTenants.strLogo))>
                                                                    <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" class="avatar avatar-sm me-3 align-self-center" alt="#qTenants.strContactPerson#">
                                                                    #qTenants.strContactPerson.left(12)#
                                                                <cfelse>
                                                                    <div class="avatar avatar-sm me-3 align-self-center">#left(qTenants.strContactPerson,2)#</div>
                                                                    <span class="nav-link-title">#qTenants.strContactPerson#</span>
                                                                </cfif>
                                                            </cfif>
                                                        </a>
                                                    </cfif>
                                                </cfloop>
                                            </div>
                                        </li>
                                    </ul>
                                    </cfoutput>

                                </li>
                            </cfif>

                            <!--- Language changer --->
                            <li class="nav-item dropdown d-none d-sm-none d-md-inline-block d-lg-none">
                                <cfif structKeyExists(application, "allLanguages") and listLen(application.allLanguages) gt 1>
                                    <cfoutput>
                                        <ul class="p-0">
                                            <li class="nav-item dropdown">
                                                <a class="nav-link dropdown-toggle" href="##navbar-third" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false" >
                                                    <span class="nav-link-icon d-none d-sm-none d-md-inline-block d-lg-inline-block">
                                                        <i class="fas fa-globe"></i>
                                                    </span>
                                                    <span class="nav-link-title">
                                                        #application.objLanguage.getAnyLanguage(session.lng).language#
                                                    </span>
                                                </a>
                                                <div class="dropdown-menu lng-dropdown">
                                                    <cfloop list="#application.allLanguages#" index="i">
                                                        <cfset lngIso = listfirst(i,"|")>
                                                        <cfset lngName = listlast(i,"|")>
                                                        <cfif lngIso neq session.lng>
                                                            <cfset thisQueryString = replace(cgi.path_info, "?l=#session.lng#", "")>
                                                            <a href="#application.mainURL##thisQueryString#?l=#lngIso#" class="dropdown-item">
                                                                #lngName#
                                                            </a>
                                                        </cfif>
                                                    </cfloop>
                                                </div>
                                            </li>
                                        </ul>
                                    </cfoutput>
                                </cfif>
                            </li>

                        </ul>

                    </div>

            </div>
        <cfoutput>

        #getLayout.layoutHeaderEnd#


        #getLayout.layoutDivEnd#

        </cfoutput>








    <header class="navbar navbar-expand-md navbar-light d-print-none d-none d-sm-none d-md-none d-lg-inline-block">

        <div class="container-xl">

            <cfoutput>

            <h1 class="navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3">
            </h1>

            <div class="navbar-nav flex-row order-md-last">

                <!--- Language changer --->
                <cfif structKeyExists(application, "allLanguages") and listLen(application.allLanguages) gt 1>
                    <cfinclude template="lng.cfm">
                </cfif>

                <!--- Tenant changer --->
                <cfinclude template="tenant_changer.cfm">


                <div class="nav-item dropdown">

                    <a class="nav-link dropdown-toggle" href="##navbar-third" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false" >
                        <span class="avatar avatar-sm newclass" style="background-image: url(#usersImgStruct.userImage#)" ></span>
                        <div class="d-none d-xl-block ps-2 newclass">
                            <div>#session.user_name#</div>
                        </div>
                    </a>

                    <div class="dropdown-menu dropdown-menu-end dropdown-menu-arrow">

                        <a class="dropdown-item" href="#application.mainURL#/account-settings">
                            #getTrans('txtAccountSettings')#
                        </a>
                        <a class="dropdown-item" href="#application.mainURL#/account-settings/my-profile">
                            #getTrans('txtMyProfile')#
                        </a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item" href="#application.mainURL#/global?logout">
                            #getTrans('txtLogout')#
                        </a>

                    </div>

                </div>

            </div>

            </cfoutput>

        </div>
    </header>