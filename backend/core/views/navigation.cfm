<div class="navbar-expand-md">
    <div class="collapse navbar-collapse" id="navbar-menu">
        <cfoutput>
        <div class="#getLayout.layoutNav#">
            <div class="#getLayout.layoutPage#">
            </cfoutput>
                <ul class="navbar-nav">
                    <li class="nav-item <cfif listlast(cgi.path_info, '/') eq 'dashboard'>active</cfif>">
                        <cfoutput>
                        <a href="#application.mainURL#/dashboard" class="nav-link">
                        </cfoutput>
                            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
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
                                <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
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

                </ul>
            </div>
        </div>
    </div>
</div>