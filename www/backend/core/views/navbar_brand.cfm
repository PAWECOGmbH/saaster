<cfset hasCustomNavbarLogo = len(trim(getSysadminData.logo)) gt 0>
<cfoutput>
    <div class="#getLayout.layoutTitel#">
        <a href="#application.mainURL#/dashboard">
            <cfif hasCustomNavbarLogo>
                <img src="/userdata/images/logos/#encodeForHTMLAttribute(getSysadminData.logo)#" alt="Logo" class="navbar-brand-image backend-custom-logo">
            <cfelse>
                <img src="#encodeForHTMLAttribute(application.objGlobal.assetUrl(getLayout.layoutLogo))#" alt="Saaster" class="navbar-brand-image">
            </cfif>
        </a>
    </div>
</cfoutput>
