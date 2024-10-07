
<cfoutput>

<!--- SysAdmin --->
<cfif session.sysadmin>
    <li class="nav-item dropdown <cfif listlast(cgi.path_info, '/') eq 'industries' or listlast(cgi.path_info, '/') eq 'contract-types' or listlast(cgi.path_info, '/') eq 'job-positions'>active</cfif>">
        <a class="nav-link dropdown-toggle" href="##navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false">
            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
                <i class="fas fa-cog"></i>
            </span>
            <span class="nav-link-title">
                Portaleinstellungen
            </span>
        </a>
        <div class="dropdown-menu">
            <a href="#application.mainURL#/admin/industries" class="dropdown-item">Branchenverwaltung</a>
            <a href="#application.mainURL#/admin/contract-types" class="dropdown-item">Vertragsarten</a>
            <a href="#application.mainURL#/admin/job-positions" class="dropdown-item">Berufspositionen </a>
        </div>
    </li>
    <li class="nav-item <cfif listlast(cgi.path_info, '/') eq 'ads'>active</cfif>">
        <a href="#application.mainURL#/admin/ads" class="nav-link">
            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
                <i class="fas fa-ad"></i>
            </span>
            <span class="nav-link-title">
                Inserate Arbeitgeber
            </span>
        </a>
        <div class="dropdown-divider d-block d-sm-block d-md-none"></div>
    </li>
    <li class="nav-item <cfif listlast(cgi.path_info, '/') eq 'worker-profiles'>active</cfif>">
        <a href="#application.mainURL#/admin/worker-profiles" class="nav-link">
            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
                <i class="fas fa-user-circle"></i>
            </span>
            <span class="nav-link-title">
                Jobprofile Fachkräfte
            </span>
        </a>
        <div class="dropdown-divider d-block d-sm-block d-md-none"></div>
    </li>
</cfif>

<!--- Employer --->
<cfif planGroupID eq 1>
    <li class="nav-item <cfif listlast(cgi.path_info, '/') eq 'profile'>active</cfif>">
        <a href="#application.mainURL#/employer/profile" class="nav-link">
            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
                <i class="far fa-address-card"></i>
            </span>
            <span class="nav-link-title">
                Profil
            </span>
        </a>
        <div class="dropdown-divider d-block d-sm-block d-md-none"></div>
    </li>
    <li class="nav-item dropdown <cfif listlast(cgi.path_info, '/') eq 'ads' or listlast(cgi.path_info, '/') eq 'new' or listlast(cgi.path_info, '/') eq 'archive' or isNumeric(listlast(cgi.path_info, '/'))>active</cfif>">
        <a class="nav-link dropdown-toggle" href="##navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false">
            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
                <i class="fas fa-ad"></i>
            </span>
            <span class="nav-link-title">
                Inserateverwaltung
            </span>
        </a>
        <div class="dropdown-menu">
            <a href="#application.mainURL#/employer/ads" class="dropdown-item">Inserate</a>
            <a href="#application.mainURL#/employer/ads/new" class="dropdown-item">Inserat erfassen</a>
            <a href="#application.mainURL#/employer/ads/archive" class="dropdown-item">Archiv</a>
        </div>
    </li>
</cfif>

<!--- Employee --->
<cfif planGroupID eq 2>
    <li class="nav-item <cfif listlast(cgi.path_info, '/') eq 'profile'>active</cfif>">
        <a href="#application.mainURL#/employee/profile" class="nav-link">
            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
                <i class="fas fa-user-circle"></i>
            </span>
            <span class="nav-link-title">
                Profildetails
            </span>
        </a>
        <div class="dropdown-divider d-block d-sm-block d-md-none"></div>
    </li>
    <li class="nav-item dropdown <cfif isNumeric(listlast(cgi.path_info, '/'))>active</cfif>">
        <a class="nav-link dropdown-toggle" href="##navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false">
            <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
                <i class="fas fa-user-tie"></i>
            </span>
            <span class="nav-link-title">
                Jobprofil
            </span>
        </a>
        <div class="dropdown-menu">
            <cfif application.objAdsBackend.getAds(session.customer_id).recordCount>
                <a href="#application.mainURL#/employee/ads/edit/#application.objAdsBackend.getAds(session.customer_id).intAdID#" class="dropdown-item">Bearbeiten</a>
                <a href="#application.mainURL#/employee/ads/settings" class="dropdown-item">Einstellungen</a>
            <cfelse>
                <a href="#application.mainURL#/employee/ads/new" class="dropdown-item">Erstellen</a>
            </cfif>
        </div>
    </li>
</cfif>
<li class="nav-item">
    <a href="#application.mainURL#" class="nav-link" target="_blank">
        <span class="nav-link-icon d-none d-sm-none d-md-none d-lg-inline-block">
            <i class="fas fa-external-link-alt"></i>
        </span>
        <span class="nav-link-title">
            Zum Stellenportal
        </span>
    </a>
    <div class="dropdown-divider d-block d-sm-block d-md-none"></div>
</li>
</cfoutput>