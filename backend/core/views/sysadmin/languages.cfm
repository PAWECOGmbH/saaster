<cfscript>
    qLanguages = application.objLanguage.getAllLanguages();
</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Languages</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Languages</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##lng_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add language
                        </a>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table card-table table-vcenter text-nowrap">
                                    <thead >
                                        <tr>
                                            <th width="5%"></th>
                                            <th width="5%" class="text-center w-10">Prio</th>
                                            <th width="25%">Language (english)</th>
                                            <th width="25%">Language (in its language)</th>
                                            <th width="10%" class="text-center">ISO code</th>
                                            <th width="10%" class="text-center">Chooseable</th>
                                            <th width="10%" class="text-center">Default</th>
                                            <th width="5%"></th>
                                            <th width="5%"></th>
                                        </tr>
                                    </thead>
                                    <tbody id="dragndrop_body">
                                    <cfloop query="qLanguages">
                                        <tr id="sort_#qLanguages.intLanguageID#">
                                            <cfif qLanguages.recordCount gt 1>
                                                <td class="move text-center"><i class="fas fa-bars hand" style="cursor: grab;"></i></td>
                                            <cfelse>
                                                <td class="text-center"></td>
                                            </cfif>
                                            <td class="text-center">#qLanguages.intPrio#</td>
                                            <td>#qLanguages.strLanguageEN#</td>
                                            <td>#qLanguages.strLanguage#</td>
                                            <td class="text-center">#qLanguages.strLanguageISO#</td>
                                            <td class="text-center">#yesNoFormat(qLanguages.blnChooseable)#</td>
                                            <td class="text-center">#yesNoFormat(qLanguages.blnDefault)#</td>
                                            <td><a href="##" class="btn" data-bs-toggle="modal" data-bs-target="##lng_#qLanguages.intLanguageID#">Edit</a></td>
                                            <td><cfif !qLanguages.blnDefault><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/languages?delete_language=#qLanguages.intLanguageID#', 'Delete language', 'If you delete a language, all variables, translations and contents in tables with this language will also be deleted. Do you really want to delete this language irrevocably?', 'No, cancel!', 'Yes, delete!')">Delete</a></cfif></td>
                                        </tr>
                                        <div id="lng_#qLanguages.intLanguageID#" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                <form action="#application.mainURL#/sysadm/languages" method="post">
                                                <input type="hidden" name="edit_language" value="#qLanguages.intLanguageID#">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Edit language</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="mb-3">
                                                                <label class="form-label">Language (english)</label>
                                                                <input type="text" name="lng_en" class="form-control" autocomplete="off" value="#HTMLEditFormat(qLanguages.strLanguageEN)#" maxlength="20" required>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label">Language (in its language)</label>
                                                                <input type="text" name="lng_own" class="form-control" autocomplete="off" value="#HTMLEditFormat(qLanguages.strLanguage)#" maxlength="20" required>
                                                            </div>
                                                            <div class="row">
                                                                <div class="col-lg-2 me-2">
                                                                    <div class="mb-3">
                                                                        <label class="form-label">ISO code</label>
                                                                        <div class="input-group input-group-flat">
                                                                            <input type="text" class="form-control" name="iso" autocomplete="off" value="#qLanguages.strLanguageISO#" maxlength="2" required>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-lg-4">
                                                                    <label class="form-label">&nbsp;</label>
                                                                    <label class="form-check form-switch pt-2">
                                                                        <cfif qLanguages.recordCount eq 1>
                                                                            <input class="form-check-input" type="checkbox" name="chooseable" checked disabled>
                                                                            <input type="hidden" name="chooseable" value="1">
                                                                        <cfelse>
                                                                            <input class="form-check-input" type="checkbox" name="chooseable" <cfif qLanguages.blnChooseable>checked</cfif>>
                                                                        </cfif>

                                                                        <span class="form-check-label">Chooseable</span>
                                                                    </label>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                            <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
                                                        </div>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>

                                    </cfloop>
                                    </tbody>
                                    <div id="lng_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                            <form action="#application.mainURL#/sysadm/languages" method="post">
                                            <input type="hidden" name="new_language">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">New language</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">Language (english)</label>
                                                            <input type="text" name="lng_en" class="form-control" autocomplete="off" maxlength="20" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Language (in its language)</label>
                                                            <input type="text" name="lng_own" class="form-control" autocomplete="off" maxlength="20" required>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-2 me-2">
                                                                <div class="mb-3">
                                                                    <label class="form-label">ISO code</label>
                                                                    <div class="input-group input-group-flat">
                                                                        <input type="text" class="form-control" name="iso" autocomplete="off" maxlength="2" required>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-4">
                                                                <label class="form-label">&nbsp;</label>
                                                                <label class="form-check form-switch pt-2">
                                                                    <input class="form-check-input" type="checkbox" name="chooseable" checked>
                                                                    <span class="form-check-label">Chooseable</span>
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                        <button type="submit" class="btn btn-primary ms-auto">
                                                            Save language
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>



<cfif qLanguages.recordCount gt 1>
    <cfoutput>
    <script>

        // Save new prio
        function fnSaveSort(){

            var jsonTmp = "[";
                $('##dragndrop_body > tr').each(function (i, row) {
                    var divbox = $(this).attr('id');
                    var aTR = divbox.split('_');
                    var newslist = 0;
                    jsonTmp += "{\"prio\" :" + (i+1) + ',';
                    if(newslist != 0){
                        var setlist = JSON.stringify(newslist);
                        jsonTmp += "\"strBoxList\" :" + setlist + ',';
                    }
                    jsonTmp += "\"intLanguageID\" :" + aTR[1] + '},';
                }
            );

            jsonTmp += jsonTmp.slice(0,-1);
            jsonTmp += "]]";

            var ajaxResponse = $.ajax({
                type: "post",
                url: "#application.mainURL#/backend/core/handler/ajax_sort.cfm?languages",
                contentType: "application/json",
                data: JSON.stringify( jsonTmp )
            })

            // Response
            ajaxResponse.then(
                function( apiResponse ){
                    if(apiResponse.trim() == 'ok'){
                        location.href = '#application.mainURL#/sysadmin/languages';
                    }
                }
            );
        }
    </script>
    </cfoutput>
</cfif>