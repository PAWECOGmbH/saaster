<cfscript>

    if (structKeyExists(form, "mappingID")) {
        mappingID = form.mappingID;
    } else if (structKeyExists(url, "mappingID")) {
        mappingID = url.mappingID;
    } else {
        mappingID = 0;
    }

    objSysadmin = new backend.core.com.sysadmin();
    getModal = new backend.core.com.translate();
    qMapping = objSysadmin.getFrontendMappings(mappingID);

    if (!qMapping.recordCount) {
        location url="#application.mainURL#/sysadmin/mappings" addtoken="false";
    }

</cfscript>


<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Edit frontend mapping</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/mappings?mapping=frontend">Frontend mappings</a></li>
                        <li class="breadcrumb-item active">#qMapping.strMapping#</li>
                    </ol>
                </div>

            </div>
        </div>
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
    </div>
    <div class="#getLayout.layoutPage#">
        <div class="row">
            <div class="col-lg-12">
                <div class="card">
                    <form action="#application.mainURL#/sysadm/mappings" method="post" onsubmit="encodeMeta()">
                        <input type="hidden" name="edit_mapping_frontend" value="#qMapping.intFrontendMappingsID#">
                        <div class="card-header">
                            <h3 class="card-title">Edit your mapping here</h3>
                        </div>
                        <div class="card-body">
                            <div class="mb-3 row">
                                <label class="col-12 col-md-2 col-form-label">Mapping</label>
                                <div class="col-12 col-md-8">
                                    <div class="input-group input-group-flat">
                                        <input type="text" name="mapping" value="#HTMLEditFormat(qMapping.strMapping)#" class="form-control" maxlength="255" required>
                                        <span class="input-group-text">
                                            <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##frontend_mapping_#qMapping.intFrontendMappingsID#">
                                                <i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" aria-label="Translate mapping" data-bs-original-title="Translate mapping"></i>
                                            </a>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label class="col-12 col-md-2 col-form-label">Path</label>
                                <div class="col-12 col-md-8">
                                    <input type="text" name="path" value="#HTMLEditFormat(qMapping.strPath)#" class="form-control" maxlength="255" required>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label class="col-12 col-md-2 col-form-label">Meta Title</label>
                                <div class="col-12 col-md-8">
                                    <div class="input-group input-group-flat">
                                        <input type="text" name="metatitle" value="#HTMLEditFormat(qMapping.strMetatitle)#" class="form-control" id="input#qMapping.intFrontendMappingsID#" maxlength="255">
                                        <span class="input-group-text">
                                            <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##frontend_metatitle_#qMapping.intFrontendMappingsID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" aria-label="Translate meta title" data-bs-original-title="Translate meta title"></i></a>
                                        </span>
                                    </div>
                                    <div class="d-flex">
                                        <div class="progress-bar">
                                            <div id="progress#qMapping.intFrontendMappingsID#" class="progress"></div>
                                        </div>
                                        <div id="progressbar#qMapping.intFrontendMappingsID#" class="progress-text"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label class="col-12 col-md-2 col-form-label">Meta Description</label>
                                <div class="col-12 col-md-8">
                                    <div class="input-group input-group-flat">
                                        <textarea name="metadescription" value="#HTMLEditFormat(qMapping.strMetadescription)#" class="form-control" id="inputDesc#qMapping.intFrontendMappingsID#" maxlength="3000" rows="3">#HTMLEditFormat(qMapping.strMetadescription)#</textarea>
                                        <span class="input-group-text">
                                            <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##frontend_metadescription_#qMapping.intFrontendMappingsID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" aria-label="Translate meta description" data-bs-original-title="Translate meta description"></i></a>
                                        </span>
                                    </div>
                                    <div class="d-flex">
                                        <div class="progress-bar">
                                            <div id="progressDesc#qMapping.intFrontendMappingsID#" class="progress"></div>
                                        </div>
                                        <div id="progressbarDesc#qMapping.intFrontendMappingsID#" class="progress-text"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label class="col-12 col-md-2 col-form-label">Header HTML Codes</label>
                                <div class="col-12 col-md-8">
                                    <div class="input-group input-group-flat">
                                        <textarea type="text" name="htmlcodes" id="htmlcodes" class="form-control" maxlength="10000" rows="10">#HTMLEditFormat(qMapping.strhtmlcodes)#</textarea>
                                        <span class="input-group-text">
                                            <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##frontend_htmlcodes_#qMapping.intFrontendMappingsID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" aria-label="Translate HTML Codes" data-bs-original-title="Translate HTML Codes"></i></a>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card-footer">
                            <div class="d-flex justify-content-between">
                                <button type="submit" class="btn btn-success">Save changes</button>
                                <button type="submit" name="delete" class="btn btn-danger">Delete mapping</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<cfset cgiPathTab = "#cgi.path_info#?mappingID=#mappingID#">
<!--- Modal --->
#getModal.args('frontend_mappings', 'strMapping', qMapping.intFrontendMappingsID, 255).openModal('frontend_mapping', cgiPathTab, 'Translate Mapping')#
#getModal.args('frontend_mappings', 'strPath', qMapping.intFrontendMappingsID, 255).openModal('frontend_path', cgiPathTab, 'Translate Path')#
#getModal.args('frontend_mappings', 'strMetatitle', qMapping.intFrontendMappingsID, 255).openModal('frontend_metatitle', cgiPathTab, 'Translate Metatitle')#
#getModal.args('frontend_mappings', 'strMetadescription', qMapping.intFrontendMappingsID, 3000).openModal('frontend_metadescription', cgiPathTab, 'Translate Metadescription')#
#getModal.args('frontend_mappings', 'strhtmlcodes', qMapping.intFrontendMappingsID, 3000).openModal('frontend_htmlcodes', cgiPathTab, 'Translate HTML Codes')#
</cfoutput>


<script>
/**
 * Encodes the 'htmlcodes' field in Base64 before form submission.
 * Converts the UTF-8 string to Base64 to prevent interference from ScriptProtect.
 */
function encodeMeta() {
  const txt = document.getElementById("htmlcodes");
  txt.value = btoa(unescape(encodeURIComponent(txt.value)));
}
</script>