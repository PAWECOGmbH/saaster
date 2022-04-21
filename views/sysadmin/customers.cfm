<cfscript>
    param name="session.cust_search" default="" type="string";
    param name="session.cust_sort" default="intPrio" type="string";
    param name="session.cust_start" default=1 type="numeric";

    // Check if url "start" exists
    if (structKeyExists(url, "start") and not isNumeric(url.start)) {
        abort;
    }

    // Pagination
    getEntries = 10;
    if( structKeyExists(url, 'start')){
        session.cust_start = url.start;
    }
    next = session.cust_start+getEntries;
    prev = session.cust_start-getEntries;
    session.cust_sql_start = session.cust_start-1;

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
        
        qTotalCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(DISTINCT customers.intCustomerID) as totalCustomers
                FROM customers

                INNER JOIN users ON 1=1
                AND customers.intCustomerID = users.intCustomerID
                OR customers.intCustParentID = users.intCustomerID

                WHERE customers.strCompanyName LIKE '%#session.cust_search#%' 
                OR users.strEmail LIKE '%#session.cust_search#%' 
                OR users.strFirstName LIKE '%#session.cust_search#%' 
                OR users.strLastName LIKE '%#session.cust_search#%'
                OR customers.strContactPerson LIKE '%#session.cust_search#%'
                OR customers.strAddress LIKE '%#session.cust_search#%'
                OR customers.strZIP LIKE '%#session.cust_search#%'
                OR customers.strCity LIKE '%#session.cust_search#%'
                OR customers.strEmail LIKE '%#session.cust_search#%'
                AND customers.blnActive = 1
            "
        )

        qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT customers.intCustomerID, customers.strCompanyName, customers.strContactPerson, 
                customers.strCity, customers.strEmail, customers.strLogo, countries.strCountryName
                FROM customers

                LEFT JOIN countries ON 1=1
                AND countries.intCountryID = customers.intCountryID

                INNER JOIN users ON 1=1
                AND customers.intCustomerID = users.intCustomerID
                OR customers.intCustParentID = users.intCustomerID

                WHERE customers.strCompanyName LIKE '%#session.cust_search#%' 
                OR users.strEmail LIKE '%#session.cust_search#%' 
                OR users.strFirstName LIKE '%#session.cust_search#%' 
                OR users.strLastName LIKE '%#session.cust_search#%'
                OR customers.strContactPerson LIKE '%#session.cust_search#%'
                OR customers.strAddress LIKE '%#session.cust_search#%'
                OR customers.strZIP LIKE '%#session.cust_search#%'
                OR customers.strCity LIKE '%#session.cust_search#%'
                OR customers.strEmail LIKE '%#session.cust_search#%'
                AND customers.blnActive = 1 

                GROUP BY customers.intCustomerID
                ORDER BY #session.cust_sort#
                LIMIT #session.cust_sql_start#, #getEntries#
            "
        );
    }
    else {
        qTotalCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCustomerID) as totalCustomers
                FROM customers
                WHERE blnActive = 1
            "
        )
        
        qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT customers.*, countries.strCountryName
                FROM customers
                LEFT JOIN countries ON countries.intCountryID = customers.intCountryID
                WHERE customers.blnActive = 1
                ORDER BY #session.cust_sort#
                LIMIT #session.cust_sql_start#, #getEntries#
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
                    <form action="#application.mainURL#/sysadmin/customers?start=1" method="post">
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
                                            <cfoutput query="qCustomers">
                                                <tr>
                                                    <td data-label="Name">
                                                        <div class="d-flex py-1 align-items-center">
                                                            <cfif len(trim(strLogo))>
                                                                <img src="#application.mainURL#/userdata/images/logos/#strLogo#" style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center" alt="#strCompanyName#">
                                                            <cfelse>
                                                                <div style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center">#left(strCompanyName,2)#</div>
                                                            </cfif>
                                                            <a href="#application.mainURL#/sysadmin/customers/details/#intCustomerID#">
                                                                <div class="flex-fill">
                                                                    <div class="font-weight-medium">#strCompanyName#</div>
                                                                </div>
                                                            </a>
                                                        </div>
                                                    </td>

                                                    <td data-label="Contact">
                                                        <div>#strContactPerson#</div>
                                                        <div class="text-muted">#strEmail#</div>
                                                    </td>

                                                    <td data-label="City">
                                                        #strCity#
                                                    </td>

                                                    <td data-label="Country">
                                                        #strCountryName#
                                                    </td>

                                                    <td>
                                                        <div class="btn-list flex-nowrap">
                                                            <a href="#application.mainURL#/sysadmin/customers/edit/#intCustomerID#" class="btn">
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
                        <div class="pt-4 card-footer d-flex align-items-center">
                            <ul class="pagination m-0 ms-auto">
                                <li class="page-item <cfif session.cust_start lt getEntries>disabled</cfif>">
                                    <a class="page-link" href="#application.mainURL#/sysadmin/customers?start=#prev#" tabindex="-1" aria-disabled="true">
                                        <i class="fas fa-angle-left"></i> prev
                                    </a>
                                </li>
                                <li class="ms-3 page-item <cfif qTotalCustomers.totalCustomers lt next>disabled</cfif>">
                                    <a class="page-link" href="#application.mainURL#/sysadmin/customers?start=#next#">
                                        next <i class="fas fa-angle-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>
