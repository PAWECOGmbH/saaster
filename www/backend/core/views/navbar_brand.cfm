<cfset hasCustomNavbarLogo = len(trim(getSysadminData.logo)) gt 0>
<!--- A navigation in the primary color is dark, like the dark layouts --->
<cfset navbarLogo = (application.themeStruct.primaryNavbar ?: false) ? "/assets/img/logo-withe.svg" : getLayout.layoutLogo>
<cfoutput>
    <div class="#getLayout.layoutTitel#">
        <a href="#application.mainURL#/dashboard">
            <cfif hasCustomNavbarLogo>
                <img src="/userdata/images/logos/#encodeForHTMLAttribute(getSysadminData.logo)#" alt="Logo" class="navbar-brand-image backend-custom-logo">
            <cfelse>
                <img src="#encodeForHTMLAttribute(application.objGlobal.assetUrl(navbarLogo))#" alt="Saaster" class="navbar-brand-image">
            </cfif>
        </a>
    </div>
</cfoutput>
