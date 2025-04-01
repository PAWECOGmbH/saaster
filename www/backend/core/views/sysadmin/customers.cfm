<cfscript>
    param name="session.cust_search" default="" type="string";
    param name="session.cust_sort" default="intPrio" type="string";
    param name="session.customers_page" default=1 type="numeric";

    objSysadmin = new backend.core.com.sysadmin();

    getEntries = 10;
    cust_start = 0;

    // Search
    if(structKeyExists(form, 'search') and len(trim(form.search))){
        session.cust_search = form.search;
    }else if (structKeyExists(form, 'delete') or structKeyExists(url, 'delete')) {
        session.cust_search = '';
    }

    // Sorting
    if(structKeyExists(form, 'sort')){
        session.cust_sort = form.sort;
    }

    // Filter out unsupport search characters
    searchTerm = ReplaceList(trim(session.cust_search),'##,<,>,/,{,},[,],(,),+,,{,},?,*,",'',',',,,,,,,,,,,,,,,');
    searchTerm = replace(searchTerm,' - ', "-", "all");

    if (len(trim(searchTerm))) {

        if (FindNoCase("@",searchTerm)){
            searchString = 'AGAINST (''"#searchTerm#"'' IN BOOLEAN MODE)'
        }else {
            searchString = 'AGAINST (''*''"#searchTerm#"''*'' IN BOOLEAN MODE)'
        }

        qTotalCustomers = objSysadmin.getTotalCustomersSearch(searchString, cust_start, session.cust_sort);
    }
    else {

        qTotalCustomers = objSysadmin.getTotalCustomers();
    }

    pages = ceiling(qTotalCustomers.totalCustomers / getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt pages) {
        session.customers_page = url.page;
    }

    if (session.customers_page gt 1){
        tPage = session.customers_page - 1;
        valueToAdd = getEntries * tPage;
        cust_start = cust_start + valueToAdd;
    }

    if (len(trim(searchTerm))) {
        if (FindNoCase("@",searchTerm)){
            searchString = 'AGAINST (''"#searchTerm#"'' IN BOOLEAN MODE)'
        }else {
            searchString = 'AGAINST (''*''"#searchTerm#"''*'' IN BOOLEAN MODE)'
        }

        qCustomers = objSysadmin.getCustomerSearch(searchString, cust_start, session.cust_sort);
    }else {

        qCustomers = objSysadmin.getCustomer(cust_start, session.cust_sort);
    }

    cntCountries = application.objGlobal.getCountry().recordCount;

    qCountries = application.objGlobal.getCountry();
    if (!qCountries.recordCount) {
        timeZones = new backend.core.com.time().getTimezones();
    }

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Customers</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">Sysadmin</li>
                            <li class="breadcrumb-item active">Customers</li>
                        </ol>
                    </div>
                    <!--- Button new customer --->
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##customer_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> New customer
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
                <div class="col-lg-12">
                    <form action="#application.mainURL#/sysadmin/customers?page=1" method="post">
                        <div class="row">
                            <div class="col-lg-4">
                                <label class="form-label">Search for customer:</label>
                                <div class="input-group mb-2">
                                    <input type="text" name="search" class="form-control" minlength="1" placeholder="Search for…">
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
                                    <div class="form-label">Sort customer</div>
                                    <select class="form-select" name="sort" onchange="this.form.submit()">
                                        <option value="strCompanyName ASC" <cfif session.cust_sort eq "strCompanyName ASC">selected</cfif>>Customer name A -> Z</option>
                                        <option value="strCompanyName DESC" <cfif session.cust_sort eq "strCompanyName DESC">selected</cfif>>Customer name Z -> A</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </form>
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Customers</h3>
                        </div>
                        <div class="card-body">
                            <p>There are <b>#qTotalCustomers.totalCustomers#</b> Customers in the database.</p>
                            <div class="card">
                                <div class="table-responsive">
                                    <table class="table table-vcenter table-mobile-md card-table">
                                        <thead>
                                            <tr>
                                                <th width="20%">Company</th>
                                                <th width="20%">Contact</th>
                                                <th width="20%">City</th>
                                                <th width="20%">Phone</th>
                                                <th width="15%"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfoutput query="qCustomers">
                                                <tr>
                                                    <td data-label="Name">
                                                        <div class="d-flex py-1 align-items-center">
                                                            <cfif len(trim(qCustomers.strLogo))>
                                                                <img src="#application.mainURL#/userdata/images/logos/#qCustomers.strLogo#" style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center" alt="#qCustomers.strCompanyName#">
                                                            <cfelse>
                                                                <cfif len(trim(qCustomers.strCompanyName))>
                                                                    <div style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center">#left(qCustomers.strCompanyName,2)#</div>
                                                                <cfelse>
                                                                    <div style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center">#left(qCustomers.strContactPerson,2)#</div>
                                                                </cfif>
                                                            </cfif>
                                                            <a href="#application.mainURL#/sysadmin/customers/details/#qCustomers.intCustomerID#">
                                                                <div class="flex-fill">
                                                                    <cfif len(trim(qCustomers.strCompanyName))>
                                                                        <div class="font-weight-medium">#qCustomers.strCompanyName#</div>
                                                                    <cfelse>
                                                                        <div class="font-weight-medium">#qCustomers.strContactPerson# (Private)</div>
                                                                    </cfif>
                                                                </div>
                                                            </a>
                                                        </div>
                                                    </td>
                                                    <td data-label="Contact">
                                                        <div>#qCustomers.strContactPerson#</div>
                                                        <div class="text-muted">#qCustomers.strEmail#</div>
                                                    </td>
                                                    <td data-label="City">
                                                        #qCustomers.strCity#
                                                    </td>
                                                    <td data-label="Phone">
                                                        #qCustomers.strPhone#
                                                    </td>
                                                    <td>
                                                        <div class="btn-list flex-nowrap">
                                                            <a href="#application.mainURL#/sysadmin/customers/edit/#qCustomers.intCustomerID#" class="btn">
                                                                Edit
                                                            </a>
                                                            <a href="#application.mainURL#/sysadm/customers?logincustomer=#qCustomers.intCustomerID#" class="btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Login as customer" onclick="return confirm('You are about to leave your sysadmin session and log in as this customer. Do you want to proceed?')">
                                                                Login
                                                            </a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </cfoutput>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <cfif pages neq 1 and qCustomers.recordCount>
                            <div class="card-body">
                                <ul class="pagination justify-content-center" id="pagination">

                                    <!--- First arrow --->
                                    <li class="page-item <cfif session.customers_page eq 1>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=1" tabindex="-1" aria-disabled="true">
                                            <i class="fas fa-angle-double-left"></i>
                                        </a>
                                    </li>

                                    <!--- Prev arrow --->
                                    <li class="page-item <cfif session.customers_page eq 1>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#session.customers_page-1#" tabindex="-1" aria-disabled="true">
                                            <i class="fas fa-angle-left"></i>
                                        </a>
                                    </li>

                                    <!--- Pages --->
                                    <cfif session.customers_page + 4 gt pages>
                                        <cfset blockPage = pages>
                                    <cfelse>
                                        <cfset blockPage = session.customers_page + 4>
                                    </cfif>

                                    <cfif blockPage neq pages>
                                        <cfloop index="j" from="#session.customers_page#" to="#blockPage#">
                                            <cfif not blockPage gt pages>
                                                <li class="page-item <cfif session.customers_page eq j>active</cfif>">
                                                    <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#j#">#j#</a>
                                                </li>
                                            </cfif>
                                        </cfloop>
                                    <cfelseif blockPage lt 5>
                                        <cfloop index="j" from="1" to="#pages#">
                                            <li class="page-item <cfif session.customers_page eq j>active</cfif>">
                                                <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#j#">#j#</a>
                                            </li>
                                        </cfloop>
                                    <cfelse>
                                        <cfloop index="j" from="#pages - 4#" to="#pages#">
                                                <li class="page-item <cfif session.customers_page eq j>active</cfif>">
                                                    <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#j#">#j#</a>
                                                </li>
                                        </cfloop>
                                    </cfif>

                                    <!--- Next arrow --->
                                    <li class="page-item <cfif session.customers_page gte pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#session.customers_page+1#">
                                            <i class="fas fa-angle-right"></i>
                                        </a>
                                    </li>

                                    <!--- Last page --->
                                    <li class="page-item <cfif session.customers_page gte pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#pages#">
                                            <i class="fas fa-angle-double-right"></i>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>


</div>

<!--- Modal new customer --->
<cfoutput>
    <form action="#application.mainURL#/sysadm/customers" method="post">
        <input type="hidden" name="add_customer">
        <div id="customer_new" class="modal modal-blur fade" tabindex="-1" style="display: none;" aria-hidden="true" data-bs-backdrop='static' data-bs-keyboard='false'>
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Add new customer</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Company *</label>
                            <input type="text" name="company" class="form-control" autocomplete="off" maxlength="50" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">First name *</label>
                            <input type="text" name="first_name" class="form-control" autocomplete="off" maxlength="50" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Last name *</label>
                            <input type="text" name="last_name" class="form-control" autocomplete="off" maxlength="50" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">E-Mail address *</label>
                            <input type="email" name="email" class="form-control" autocomplete="off" maxlength="50" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password *</label>
                            <input type="text" name="password" class="form-control" autocomplete="off" maxlength="50" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formLanguage')#</label>
                            <select name="language" class="form-select">
                                <cfloop list="#application.allLanguages#" index="i">
                                    <cfset lngIso = listfirst(i,"|")>
                                    <cfset lngName = listlast(i,"|")>
                                    <option value="#lngIso#" <cfif lngIso eq session.lng>selected</cfif>>#lngName#</option>
                                </cfloop>
                            </select>
                        </div>
                        <cfif qCountries.recordCount>
                            <div class="mb-3">
                                <label class="form-label">#getTrans('formCountry')# *</label>
                                <select name="countryID" class="form-select" required>
                                    <option value=""></option>
                                    <cfloop query="qCountries">
                                        <option value="#qCountries.intCountryID#">#qCountries.strCountryName#</option>
                                    </cfloop>
                                </select>
                            </div>
                        <cfelse>
                            <div class="mb-3">
                                <label class="form-label">#getTrans('titTimezone')# *</label>
                                <select name="timezoneID" class="form-select" required>
                                    <option value=""></option>
                                    <cfloop array="#timeZones#" index="i">
                                        <option value="#i.id#">#i.timezone# - #i.city# (#i.utc#)</option>
                                    </cfloop>
                                </select>
                            </div>
                        </cfif>
                    </div>
                    <div class="modal-footer">
                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                        <button type="submit" class="btn btn-primary ms-auto">
                            Save customer
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </form>
    </cfoutput>