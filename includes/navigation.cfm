<div class="navbar-expand-md">
    <div class="collapse navbar-collapse" id="navbar-menu">
        <div class="navbar navbar-light">
            <div class="container-xl">
                <ul class="navbar-nav">
                    <li class="nav-item <cfif listlast(cgi.path_info, '/') eq 'dashboard'>active</cfif>">
                        <cfoutput>
                        <a href="#application.mainURL#/dashboard" class="nav-link">
                        </cfoutput>
                            <span class="nav-link-icon d-md-none d-lg-inline-block">
                                <i class="fas fa-home"></i>
                            </span>
                            <span class="nav-link-title">
                                Home
                            </span>
                        </a>
                    </li>
                    <!--- SysAdmin stuff --->
                    <cfif structKeyExists(session, "sysadmin") and session.sysadmin>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false">
                                <span class="nav-link-icon d-md-none d-lg-inline-block">
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
                                <a href="#application.mainURL#/sysadmin/plans" class="dropdown-item">Plans & Prices</a>
                                <a href="#application.mainURL#/sysadmin/invoices" class="dropdown-item">Invoices</a>
                                <div class="dropdown-divider"></div>

                                <span class="dropdown-header">System</span>
                                <a href="#application.mainURL#/sysadmin/languages" class="dropdown-item">Languages</a>
                                <a href="#application.mainURL#/sysadmin/currencies" class="dropdown-item">Currencies</a>
                                <a href="#application.mainURL#/sysadmin/countries" class="dropdown-item">Countries</a>
                                <a href="#application.mainURL#/sysadmin/settings" class="dropdown-item">Settings</a>
                                <a href="#application.mainURL#/sysadmin/mappings" class="dropdown-item">Mappings</a>
                                <a href="#application.mainURL#/sysadmin/translations" class="dropdown-item">Translations</a>
                                <a href="#application.mainURL#/sysadmin/modules" class="dropdown-item">Modules</a>
                                <a href="#application.mainURL#/sysadmin/widgets" class="dropdown-item">Widgets</a>

                            </div>
                            </cfoutput>
                        </li>
                    </cfif>

                </ul>
            </div>
        </div>
    </div>
</div>