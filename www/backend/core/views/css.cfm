<!--- Local files carry their modification time as version (global.cfc::assetUrl); the setup has no objGlobal yet --->
<cfset assetUrl = (path) => structKeyExists(application, "objGlobal") ? application.objGlobal.assetUrl(path) : path>
<cfoutput>
<!--- Main Tabler CSS --->
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.7.5/dist/css/tabler.min.css" />

<!--- Tabler theme attributes on <html> (primary color, gray tone, radius, font); keep the same version as tabler.min.css --->
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.7.5/dist/css/tabler-themes.min.css" />

<!--- Dropify --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/dropify.min.css')#" />

<!--- Tabler Icons (self-hosted) --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/tabler-icons/tabler-icons.min.css')#" />
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/icons.css')#" />

<!--- Sweetalert --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/sweetalert.css')#" />

<!--- hugerte Plugin --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/hugerte@1.0.9/skins/ui/hugerte-5/skin.min.css">

<!--- Tom Select --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/tom-select.css')#" />

<!--- Customized CSS --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/backend.css')#" />

<!--- Custom primary color of the sysadmin theme settings (theme.cfc); presets use the attributes on <html> --->
<cfif len(application.themeStruct.customCss ?: "")>
<style>#application.themeStruct.customCss#</style>
</cfif>
</cfoutput>
