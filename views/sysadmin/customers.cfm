<cfscript>
    param name="session.cust_search" default="" type="string";
    param name="session.cust_sort" default="intPrio" type="string";
    param name="session.customers_page" default=1 type="numeric";

    local.getEntries = 10;
    local.cust_start = 0;

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
    
    if (len(trim(session.cust_search))) {
        if (FindNoCase("@",session.cust_search)){
            local.searchString = 'AGAINST (''"#session.cust_search#"'' IN BOOLEAN MODE)'
        }else {
            local.searchString = 'AGAINST (''*''"#session.cust_search#"''*'' IN BOOLEAN MODE)'
        }
        local.qTotalCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(DISTINCT customers.intCustomerID) as totalCustomers, customers.strCompanyName, customers.strContactPerson, 
                customers.strCity, customers.strEmail, customers.strLogo, countries.strCountryName
                FROM customers

                LEFT JOIN countries
                ON countries.intCountryID = customers.intCountryID

                INNER JOIN users
                ON customers.intCustomerID = users.intCustomerID
                OR customers.intCustParentID = users.intCustomerID
                
                WHERE customers.blnActive = 1
                AND MATCH (strCompanyName, strContactPerson, strAddress, strZIP, strCity, customers.strEmail)
                #local.searchString#
                ORDER BY #session.cust_sort#
                LIMIT #local.cust_start#, #getEntries#
            "
        )
    }
    else {
        local.qTotalCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCustomerID) as totalCustomers
                FROM customers
                WHERE blnActive = 1
            "
        )
    }

    local.pages = ceiling(local.qTotalCustomers.totalCustomers / local.getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt local.pages) {  
        session.customers_page = url.page;
    }

    if (session.customers_page gt 1){
        local.tPage = session.customers_page - 1;
        local.valueToAdd = local.getEntries * tPage;
        local.cust_start = local.cust_start + local.valueToAdd;
    }

    if (len(trim(session.cust_search))) {
        if (FindNoCase("@",session.cust_search)){
            local.searchString = 'AGAINST (''"#session.cust_search#"'' IN BOOLEAN MODE)'
        }else {
            local.searchString = 'AGAINST (''*''"#session.cust_search#"''*'' IN BOOLEAN MODE)'
        }
        local.qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT DISTINCT customers.intCustomerID, customers.strCompanyName, customers.strContactPerson, 
                customers.strCity, customers.strEmail, customers.strLogo, countries.strCountryName
                FROM customers

                LEFT JOIN countries
                ON countries.intCountryID = customers.intCountryID

                INNER JOIN users
                ON customers.intCustomerID = users.intCustomerID
                OR customers.intCustParentID = users.intCustomerID
                
                WHERE customers.blnActive = 1
                AND MATCH (strCompanyName, strContactPerson, strAddress, strZIP, strCity, customers.strEmail)
                #local.searchString#
                ORDER BY #session.cust_sort#
                LIMIT #local.cust_start#, #getEntries#
            "
        );
    }else {
        local.qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT customers.*, countries.strCountryName
                FROM customers
                LEFT JOIN countries ON countries.intCountryID = customers.intCountryID
                WHERE customers.blnActive = 1
                ORDER BY #session.cust_sort#
                LIMIT #local.cust_start#, #getEntries#
            "
        );
    }

</cfscript>

<cfinclude template="/includes/header.cfm">

<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Customers</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">Sysadmin</li>
                            <li class="breadcrumb-item active">Customers</li>
                        </ol>
                    </div>    
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <form action="#application.mainURL#/sysadmin/customers?page=1" method="post">
                        <div class="row">
                            <div class="col-lg-4">
                                <label class="form-label">Search for customer:</label>
                                <div class="input-group mb-2">
                                    <input type="text" name="search" class="form-control" minlength="1" placeholder="Search for…">
                                    <button class="btn bg-green-lt" type="submit">Go!</button>
                                    <cfif len(trim(session.cust_search))>
                                        <button class="btn bg-red-lt" name="delete" type="submit" data-bs-toggle="tooltip" data-bs-placement="top" title="Delete search">
                                            #session.cust_search# <i class="ms-2 fas fa-times"></i>
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
                            <p>There are <b>#local.qTotalCustomers.totalCustomers#</b> invoices in the database.</p>
                            <div class="card">
                                <div class="table-responsive">
                                    <table class="table table-vcenter table-mobile-md card-table">
                                        <thead>
                                            <tr>
                                                <th>Company</th>
                                                <th>Contact</th>
                                                <th>City</th>
                                                <th>Country</th>
                                                <th class="w-1"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfoutput query="local.qCustomers">
                                                <tr>
                                                    <td data-label="Name">
                                                        <div class="d-flex py-1 align-items-center">
                                                            <cfif len(trim(local.qCustomers.strLogo))>
                                                                <img src="#application.mainURL#/userdata/images/logos/#local.qCustomers.strLogo#" style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center" alt="#local.qCustomers.strCompanyName#">
                                                            <cfelse>
                                                                <div style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center">#left(local.qCustomers.strCompanyName,2)#</div>
                                                            </cfif>
                                                            <a href="#application.mainURL#/sysadmin/customers/details/#local.qCustomers.intCustomerID#">
                                                                <div class="flex-fill">
                                                                    <div class="font-weight-medium">#local.qCustomers.strCompanyName#</div>
                                                                </div>
                                                            </a>
                                                        </div>
                                                    </td>

                                                    <td data-label="Contact">
                                                        <div>#local.qCustomers.strContactPerson#</div>
                                                        <div class="text-muted">#local.qCustomers.strEmail#</div>
                                                    </td>

                                                    <td data-label="City">
                                                        #local.qCustomers.strCity#
                                                    </td>

                                                    <td data-label="Country">
                                                        #local.qCustomers.strCountryName#
                                                    </td>

                                                    <td>
                                                        <div class="btn-list flex-nowrap">
                                                            <a href="#application.mainURL#/sysadmin/customers/edit/#local.qCustomers.intCustomerID#" class="btn">
                                                                Edit
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
                        <cfif local.pages neq 1 and local.qCustomers.recordCount>
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
                                    <cfif session.customers_page + 4 gt local.pages>
                                        <cfset blockPage = local.pages>
                                    <cfelse>
                                        <cfset blockPage = session.customers_page + 4>
                                    </cfif>
                                    
                                    <cfif blockPage neq local.pages>
                                        <cfloop index="j" from="#session.customers_page#" to="#blockPage#">
                                            <cfif not blockPage gt local.pages>
                                                <li class="page-item <cfif session.customers_page eq j>active</cfif>">
                                                    <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#j#">#j#</a>
                                                </li>
                                            </cfif>
                                        </cfloop>
                                    <cfelseif blockPage lt 5>
                                        <cfloop index="j" from="1" to="#local.pages#">
                                            <li class="page-item <cfif session.customers_page eq j>active</cfif>">
                                                <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#j#">#j#</a>
                                            </li>
                                        </cfloop>
                                    <cfelse>
                                        <cfloop index="j" from="#local.pages - 4#" to="#local.pages#">
                                                <li class="page-item <cfif session.customers_page eq j>active</cfif>">
                                                    <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#j#">#j#</a>
                                                </li>
                                        </cfloop>
                                    </cfif>

                                    <!--- Next arrow --->
                                    <li class="page-item <cfif session.customers_page gte local.pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#session.customers_page+1#">
                                            <i class="fas fa-angle-right"></i>
                                        </a>
                                    </li>

                                    <!--- Last page --->
                                    <li class="page-item <cfif session.customers_page gte local.pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/customers?page=#local.pages#">
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
    <cfinclude template="/includes/footer.cfm">
</div>
