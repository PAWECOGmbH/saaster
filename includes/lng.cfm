
<cfoutput>
<ul class="navbar-nav" style="margin-right: 10px;">
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="##navbar-third" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false" >
            <span class="nav-link-icon d-md-none d-lg-inline-block">
                <i class="fas fa-globe"></i>
            </span>
            <span class="nav-link-title d-none d-sm-none d-md-block">
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