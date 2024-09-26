<cfscript>
    param name="session.ci_search" default="" type="string";
    param name="session.ci_sort" default="strCountryName ASC" type="string";

    objSysadmin = new backend.core.com.sysadmin();

    if(structKeyExists(form, "search") and len(trim(form.search))) {
        session.ci_search = form.search;
    }else if (structKeyExists(form, "delete") or structKeyExists(url, "delete")) {
        session.ci_search = "";
    }

    if(structKeyExists(form, "sort")) {
        session.ci_sort = form.sort;
    }

    qTotalCountries = objSysadmin.getTotalCountriesImport();

    // Filter out unsupport search characters
    searchTerm = ReplaceList(trim(session.ci_search),'##,<,>,/,{,},[,],(,),+,,{,},?,*,",'',',',,,,,,,,,,,,,,,');
    searchTerm = replace(searchTerm,' - ', "-", "all");

    if(len(trim(searchTerm))){
        if (FindNoCase("@",searchTerm)){
            searchString = 'AGAINST (''"#searchTerm#"'' IN BOOLEAN MODE)'
        }else {
            searchString = 'AGAINST (''*''"#searchTerm#"''*'' IN BOOLEAN MODE)'
        }

        qCountries = objSysadmin.getCountriesImportSearch(searchString, session.ci_sort);
    }else {

        qCountries = objSysadmin.getCountriesImport(session.ci_sort);
    }

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">
            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Countries</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item "><a href="#application.mainURL#/sysadmin/countries?delete">Countries</a></li>
                            <li class="breadcrumb-item active">Import</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/sysadmin/countries?delete" class="btn btn-primary">
                            <i class="fas fa-angle-double-left pe-3"></i> Back to overview
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
                            <p>We have <b>#qTotalCountries.totalCountries# not imported Countries</b> in our database. You will only find countries here that you have not yet imported.</p>
                            <form action="#application.mainURL#/sysadmin/countries/import" method="post">
                                <div class="row">
                                    <div class="col-lg-4">
                                        <label class="form-label">Search for country:</label>
                                        <div class="input-group mb-2">
                                            <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                            <button class="btn bg-green-lt" type="submit">Go!</button>
                                            <cfif len(trim(searchTerm))>
                                                <button class="btn bg-red-lt" name="delete" type="submit" data-bs-toggle="tooltip" data-bs-placement="top" title="Delete search">
                                                    #searchTerm# <i class="ms-2 fas fa-times"></i>
                                                </button>
                                            </cfif>
                                        </div>
                                    </div>
                                    <div class="col-lg-5"></div>
                                    <div class="col-lg-3">
                                        <div class="mb-3">
                                            <div class="form-label">Sort countries</div>
                                            <select class="form-select" name="sort" onchange="this.form.submit()">
                                                <option value="strCountryName ASC" <cfif session.ci_sort eq "strCountryName ASC">selected</cfif>>Country name A -> Z</option>
                                                <option value="strCountryName DESC" <cfif session.ci_sort eq "strCountryName DESC">selected</cfif>>Country name Z -> A</option>
                                                <option value="strRegion ASC" <cfif session.ci_sort eq "strRegion ASC">selected</cfif>>Region A -> Z</option>
                                                <option value="strRegion DESC" <cfif session.ci_sort eq "strRegion DESC">selected</cfif>>Region Z -> A</option>
                                                <option value="strSubRegion ASC" <cfif session.ci_sort eq "strSubRegion ASC">selected</cfif>>Subregion A -> Z</option>
                                                <option value="strSubRegion DESC" <cfif session.ci_sort eq "strSubRegion DESC">selected</cfif>>Subregion Z -> A</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </form>
                            <div class="table-responsive">
                                <form action="#application.mainURL#/sysadm/countries" method="post">
                                    <input type="hidden" name="import_country">
                                    <table class="table card-table table-vcenter text-nowrap" id="checkall">
                                        <thead>
                                            <tr>
                                                <th width="5%"><input type="checkbox" class="form-check-input" id="checkAll"/></th>
                                                <th width="35%">Country</th>
                                                <th width="10%" class="text-center">ISO 1</th>
                                                <th width="10%" class="text-center">ISO 2</th>
                                                <th width="5%" class="text-center">Locale</th>
                                                <th width="20%">Region</th>
                                                <th width="20%">Subregion</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfloop query="qCountries">
                                                <tr>
                                                    <td><input type="checkbox" name="country_id" value="#qCountries.intCountryID#" class="form-check-input" id="checkAll"></td>
                                                    <td>#qCountries.strCountryName#</td>
                                                    <td class="text-center">#qCountries.strISO1#</td>
                                                    <td class="text-center">#qCountries.strISO2#</td>
                                                    <td class="text-center">#qCountries.strLocale#</td>
                                                    <td>#qCountries.strRegion#</td>
                                                    <td>#qCountries.strSubRegion#</td>
                                                    <td><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/countries?delete_country=#qCountries.intCountryID#', 'Delete country', 'Do you really want to delete this country irrevocably?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                                                </tr>
                                            </cfloop>
                                        </tbody>
                                    </table>
                                    <div class="mx-3 my-3">
                                        <button type="submit" class="btn btn-primary">Import now!</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>