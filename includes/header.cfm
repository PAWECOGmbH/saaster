<cfscript>
    usersImgStruct = application.objUser.getUserImage(session.user_id);
</cfscript>

<cfoutput>

<cfif application.layoutStruct.layoutString eq "combined">
    <cfinclude template="navigationCombined.cfm">
<cfelse>
    #application.layoutStruct.layoutDivStart#

    #application.layoutStruct.layoutHeader#

        <div class="#application.layoutStruct.layoutContainer#">

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="##navbar-menu" >
                <span class="navbar-toggler-icon"></span>
            </button>

            <h1 class="#application.layoutStruct.layoutTitel#">
                <a href="#application.mainURL#/dashboard">
                    <img src="#application.layoutStruct.layoutLogo#" alt="logo" class="navbar-brand-image">
                </a>
            </h1>
            

            <div class="#application.layoutStruct.layoutDiv#">
                
                <!--- Language changer --->
                <div #application.layoutStruct.layoutClass#>
                    <cfif structKeyExists(application, "allLanguages") and listLen(application.allLanguages) gt 1>
                        <cfinclude template="lng.cfm">
                    </cfif>
                </div>

                <!--- Tenant changer --->
                <div #application.layoutStruct.layoutClass#>
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

            <cfswitch expression="#application.layoutStruct.layoutString#">
                <cfcase value="verticalTransparent"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="vertical"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="rightVertical"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="fluidVertical"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="condensed"><cfinclude template="navigationCondensed.cfm"></cfcase>
                <cfcase value="navbarOverlap"><cfinclude template="navigationCondensed.cfm"></cfcase>
            </cfswitch>

        </div>

    #application.layoutStruct.layoutHeaderEnd#

    
    <cfswitch expression="#application.layoutStruct.layoutString#">
        <cfcase value="horizontal"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="horizontalDark"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="navbarDark"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="navbarSticky"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="fluid"><cfinclude template="navigation.cfm"></cfcase>
    </cfswitch>

    #application.layoutStruct.layoutDivEnd#

</cfif>

</cfoutput>