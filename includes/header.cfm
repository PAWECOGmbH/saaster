<cfscript>
    usersImgStruct = application.objUser.getUserImage(session.user_id);
</cfscript>

<header class="navbar navbar-expand-md navbar-light d-print-none">

    <div class="container-xl">

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="##navbar-menu">
            <span class="navbar-toggler-icon"></span>
        </button>

        <cfoutput>

        <h1 class="navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3">
            <a href="#application.mainURL#/dashboard">
                <img src="#application.mainURL#/dist/img/logo.svg" alt="logo" class="navbar-brand-image">
            </a>
        </h1>
        <div class="navbar-nav flex-row order-md-last">

            <!--- Tenant changer --->
            <cfinclude template="tenant_changer.cfm">

            <!--- Language changer --->
            <cfif listLen(application.allLanguages) gt 1>
                <cfinclude template="lng.cfm">
            </cfif>

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
