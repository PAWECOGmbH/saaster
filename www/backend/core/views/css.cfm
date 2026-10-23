<!--- Local files carry their modification time as version (global.cfc::assetUrl); the setup has no objGlobal yet --->
<cfset assetUrl = (path) => structKeyExists(application, "objGlobal") ? application.objGlobal.assetUrl(path) : path>
<cfoutput>
<!--- Main Tabler CSS --->
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.6.1/dist/css/tabler.min.css" />

<!--- Dropify --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/dropify.min.css')#" />

<!--- Fontawesome Plugin --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/fontawesome/css/all.css')#" />

<!--- Sweetalert --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/sweetalert.css')#" />

<!--- hugerte Plugin --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/hugerte@1.0.9/skins/ui/hugerte-5/skin.min.css">

<!--- Tom Select --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/tom-select.css')#" />

<!--- Customized CSS --->
<link rel="stylesheet" type="text/css" href="#assetUrl('/backend/dist/css/backend.css')#" />

<!--- Dynamic CSS for Primary and Secondary Button color --->
<link rel="stylesheet" type="text/css" href="/backend/core/views/color.cfm" />
</cfoutput>
