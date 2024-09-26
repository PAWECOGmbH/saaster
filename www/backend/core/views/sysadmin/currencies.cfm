<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qCurrencies = objSysadmin.getCurrencies();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Currencies</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Currencies</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##cur_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add currency
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
                                            <th width="10%">Currency (english)</th>
                                            <th width="10%">Currency (own language)</th>
                                            <th width="10%" class="text-center">ISO code</th>
                                            <th width="10%" class="text-center">Currency Sign</th>
                                            <th width="10%" class="text-center">Default</th>
                                            <th width="10%" class="text-center">Active</th>
                                            <th width="5%"></th>
                                            <th width="5%"></th>
                                        </tr>
                                    </thead>
                                    <tbody id="dragndrop_body">
                                    
                                    <cfloop query="qCurrencies">
                                        <tr id="sort_#qCurrencies.intCurrencyID#">
                                            <td class="move text-center"><i class="fas fa-bars hand" style="cursor: grab;"></i></td>
                                            <td class="text-center">#qCurrencies.intPrio#</td>
                                            <td>#qCurrencies.strCurrencyEN#</td>
                                            <td>#qCurrencies.strCurrency#</td>
                                            <td class="text-center">#qCurrencies.strCurrencyISO#</td>
                                            <td class="text-center">#qCurrencies.strCurrencySign#</td>
                                            <td class="text-center">#yesNoFormat(qCurrencies.blnDefault)#</td>
                                            <td class="text-center">#yesNoFormat(qCurrencies.blnActive)#</td>
                                            <td><a href="##" class="btn" data-bs-toggle="modal" data-bs-target="##cur_#qCurrencies.intCurrencyID#">Edit</a></td>
                                            <td><cfif !qCurrencies.blnDefault><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/currencies?delete_currency=#qCurrencies.intCurrencyID#', 'Delete currency', 'If you delete a currency, all variables, translations and contents in tables with this currency will also be deleted. Do you really want to delete this currency irrevocably?', 'No, cancel!', 'Yes, delete!')">Delete</a></cfif></td>
                                        </tr>
                                        
                                        <div id="cur_#qCurrencies.intCurrencyID#" class='modal fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                
                                                <form action="#application.mainURL#/sysadm/currencies" method="post">
                                                    <input type="hidden" name="edit_currency" value="#qCurrencies.intCurrencyID#">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Edit currency</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="mb-3">
                                                                <label class="form-label">Currency (english)</label>
                                                                <input type="text" name="lng_en" class="form-control" autocomplete="off" value="#HTMLEditFormat(qCurrencies.strCurrencyEN)#" maxlength="20" required>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label">Currency (in its language)</label>
                                                                <input type="text" name="lng_own" class="form-control" autocomplete="off" value="#HTMLEditFormat(qCurrencies.strCurrency)#" maxlength="20" required>
                                                            </div>
                                                            <div class="row">
                                                                <div class="col-lg-3">
                                                                    <div class="mb-2">
                                                                        <label class="form-label">ISO code</label>
                                                                        <div class="input-group input-group-flat w-50">
                                                                            <input type="text" class="form-control" name="iso" autocomplete="off" value="#qCurrencies.strCurrencyISO#" maxlength="3" required>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-lg-4 mb-3">
                                                                    <label class="form-label">Active</label>
                                                                    <label class="form-check form-switch">
                                                                        <input class="form-check-input" type="checkbox" name="active" <cfif qCurrencies.blnActive>checked</cfif>>
                                                                        <span class="form-check-label">Activate currency</span>
                                                                    </label>
                                                                </div>
                                                                <div class="col-lg-4 mb-3">
                                                                    <label class="form-label">Default</label>
                                                                    <label class="form-check form-switch">
                                                                        <cfif qCurrencies.blnDefault>
                                                                            <input class="form-check-input" type="checkbox" name="default" checked disabled>
                                                                            <input type="hidden" name="default" value="on">
                                                                        <cfelse>
                                                                            <input class="form-check-input" type="checkbox" name="default">
                                                                        </cfif>
                                                                        <span class="form-check-label">Default currency</span>
                                                                    </label>
                                                                </div>

                                                                <div class="row">
                                                                    <div class="col-lg-3">
                                                                        <div class="mb-3">
                                                                            <label class="form-label">Sign</label>
                                                                            <div class="input-group input-group-flat w-50">
                                                                                <input type="text" class="form-control" name="sign" value="#HTMLEditFormat(qCurrencies.strCurrencySign)#" autocomplete="off">
                                                                            </div>
                                                                        </div>
                                                                    </div>
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
                                    <div id="cur_new" class='modal fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                            <form action="#application.mainURL#/sysadm/currencies" method="post">
                                                <input type="hidden" name="new_currency">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">New currency</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">Currency (english)</label>
                                                            <input type="text" name="lng_en" class="form-control" autocomplete="off" maxlength="20" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Currency (own language)</label>
                                                            <input type="text" name="lng_own" class="form-control" autocomplete="off" maxlength="20" required>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-3">
                                                                <div class="mb-3">
                                                                    <label class="form-label">ISO code</label>
                                                                    <div class="input-group input-group-flat w-50">
                                                                        <input type="text" class="form-control" name="iso" autocomplete="off" maxlength="3" required>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-4 mb-3">
                                                                <label class="form-label">Active</label>
                                                                <label class="form-check form-switch">
                                                                    <input class="form-check-input" type="checkbox" name="active" checked>
                                                                    <span class="form-check-label">Activate currency</span>
                                                                </label>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-lg-3">
                                                                <div class="mb-3">
                                                                    <label class="form-label">Sign</label>
                                                                    <div class="input-group input-group-flat w-50">
                                                                        <input type="text" class="form-control" name="sign" maxlength="3" autocomplete="off">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>

                                                    </div>
                                                    <div class="modal-footer">
                                                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                        <button type="submit" class="btn btn-primary ms-auto">
                                                            Save currency
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


<cfif qCurrencies.recordCount gt 1>
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
                    jsonTmp += "\"intCurrencyID\" :" + aTR[1] + '},';
                }
            );

            jsonTmp += jsonTmp.slice(0,-1);
            jsonTmp += "]]";

            var ajaxResponse = $.ajax({
                type: "post",
                url: "#application.mainURL#/backend/core/handler/ajax_sort.cfm?currencies",
                contentType: "application/json",
                data: JSON.stringify( jsonTmp )
            })

            // Response
            ajaxResponse.then(
                function( apiResponse ){
                    if(apiResponse.trim() == 'ok'){
                        location.href = '#application.mainURL#/sysadmin/currencies';
                    }
                }
            );
        }
    </script>
    </cfoutput>
</cfif>