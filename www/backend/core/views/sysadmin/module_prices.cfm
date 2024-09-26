

<cfscript>
    
    objSysadmin = new backend.core.com.sysadmin();
    qPrices = objSysadmin.getPricesModule(thisModuleID);
    
</cfscript>

<cfoutput>
<form id="submit_form" method="post" action="#application.mainURL#/sysadm/modules">
<input type="hidden" name="edit_prices" value="#qModule.intModuleID#">
    <div class="row">
        <div class="col-lg-5">
            <div class="table-responsive">
                <table class="table card-table table-vcenter text-nowrap">
                    <thead>
                        <tr>
                            <th width="25%">Currency</th>
                            <th width="25%" class="text-end">One time pricing</th>
                            <th width="25%" class="text-end">Price monthly</th>
                            <th width="25%" class="text-end">Price yearly</th>
                        </tr>
                        <cfloop query="qPrices">
                            <tr>
                                <td>#qPrices.strCurrencyEN# (#qPrices.strCurrencyISO#)</td>
                                <td align="right">
                                    <input type="text" name="onetime_#qPrices.currID#" class="form-control text-end w-75" autocomplete="off" value="#trim(numberFormat(qPrices.decPriceOneTime, '__.__'))#" maxlength="10">
                                </td>
                                <td align="right">
                                    <input type="text" name="pricemonthly_#qPrices.currID#" class="form-control text-end w-75" autocomplete="off" value="#trim(numberFormat(qPrices.decPriceMonthly, '__.__'))#" maxlength="10">
                                </td>
                                <td align="right">
                                    <input type="text" name="priceyearly_#qPrices.currID#" class="form-control text-end w-75" autocomplete="off" value="#trim(numberFormat(qPrices.decPriceYearly, '__.__'))#" maxlength="10">
                                </td>
                            </tr>
                        </cfloop>
                    </thead>
                </table>
            </div>
        </div>
        <div class="col-lg-1"></div>
        <div class="col-lg-6">
            <div class="row">
                <div class="col-lg-3 me-3 mb-3">
                    <div class="mb-3 text-end w-75">
                        <label class="form-label text-end">Vat (%)</label>
                        <input type="text" name="vat" class="form-control text-end" autocomplete="off" value="#trim(decimalFormat(qPrices.decVat))#" maxlength="10">
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="mb-3">
                        <label class="form-label mb-3">Vat type</label>
                        <label class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="type" value="1" <cfif qPrices.intVatType eq 1 or qPrices.intVatType eq "">checked</cfif>>
                            <span class="form-check-label small pt-1">Incl. VAT</span>
                        </label>
                        <label class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="type" value="2" <cfif qPrices.intVatType eq 2>checked</cfif>>
                            <span class="form-check-label small pt-1">Excl. VAT</span>
                        </label>
                        <label class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="type" value="3" <cfif qPrices.intVatType eq 3>checked</cfif>>
                            <span class="form-check-label small pt-1">No VAT</span>
                        </label>
                    </div>
                </div>
                <div class="col-lg-3 me-3 mb-3">
                    <div class="mb-3">
                        <label class="form-check form-switch">
                            <input class="form-check-input" name="netto" type="checkbox" <cfif qPrices.blnIsNet eq 1 or qPrices.blnIsNet eq "">checked</cfif>>
                            <span class="form-check-label">Netto</span>
                        </label>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="card-footer ps-0 pt-3">
        <button type="submit" id="submit_button" class="btn btn-primary">Save prices</button>
    </div>
</form>
</cfoutput>