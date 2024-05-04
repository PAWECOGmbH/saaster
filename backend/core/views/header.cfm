<cfscript>
    usersImgStruct = application.objUser.getUserImage(session.user_id);
    getSysadminData = application.objSysadmin.getSysAdminData(); 
</cfscript>

<cfoutput>

<cfif getLayout.layoutString eq "combined">
    <cfinclude template="navigationCombined.cfm">
<cfelse>
    #getLayout.layoutDivStart#

    #getLayout.layoutHeader#

        <div class="#getLayout.layoutContainer#">

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="##navbar-menu" >
                <span class="navbar-toggler-icon"></span>
            </button>

            <h1 class="#getLayout.layoutTitel#">
                <cfif len(trim(getSysadminData.logo))>
                    <a href="#application.mainURL#/dashboard" class="navbar-brand navbar-brand-autodark">
                        <img src="#application.mainURL#/userdata/images/logos/#getSysadminData.logo#" class="navbar-brand-image" alt="Logo">
                    </a>
                <cfelse>
                    <a href="#application.mainURL#/dashboard">
                        <img src="#getLayout.layoutLogo#" alt="logo" class="navbar-brand-image">
                    </a>
                </cfif>
            </h1>


            <div class="#getLayout.layoutDiv#">

                <!--- Notifications --->
                <cfinclude template="notifications/flyout.cfm">

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
                        <a class="dropdown-item" href="#application.mainURL#/logincheck?logout">
                            #getTrans('txtLogout')#
                        </a>

                    </div>

                </div>
            </div>

            <cfswitch expression="#getLayout.layoutString#">
                <cfcase value="verticalTransparent"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="vertical"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="rightVertical"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="fluidVertical"><cfinclude template="navigationVertical.cfm"></cfcase>
                <cfcase value="condensed"><cfinclude template="navigationCondensed.cfm"></cfcase>
                <cfcase value="navbarOverlap"><cfinclude template="navigationCondensed.cfm"></cfcase>
            </cfswitch>

        </div>

    #getLayout.layoutHeaderEnd#


    <cfswitch expression="#getLayout.layoutString#">
        <cfcase value="horizontal"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="horizontalDark"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="navbarDark"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="navbarSticky"><cfinclude template="navigation.cfm"></cfcase>
        <cfcase value="fluid"><cfinclude template="navigation.cfm"></cfcase>
    </cfswitch>

    #getLayout.layoutDivEnd#

</cfif>

</cfoutput>