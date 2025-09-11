
<cfscript>

    param name="session.p_search" default="" type="string";
    param name="session.p_sort" default="dtmCreated DESC" type="string";
    param name="session.p_page" default=1 type="numeric";

    objBlog = new backend.core.com.blog();

    getEntries = 10;
    p_start = 0;

    // Search
    if (structKeyExists(form, 'search') and len(trim(form.search))) {
        session.p_search = form.search;
    } else if (structKeyExists(form, 'delete') or structKeyExists(url, 'delete')) {
        session.p_search = '';
    }

    // Sorting
    if (structKeyExists(form, 'sort')) {
        session.p_sort = form.sort;
    }

    // Filter out unsupported search characters
    searchTerm = ReplaceList(trim(session.p_search),'##,<,>,/,{,},[,],(,),+,,{,},?,*,",'',',',,,,,,,,,,,,,,,');
    searchTerm = replace(searchTerm,' - ', "-", "all");

    if (len(trim(searchTerm))) {
        searchString = 'AGAINST (''*''"#searchTerm#"''*'' IN BOOLEAN MODE)'
        qTotalPosts = objBlog.getTotalPostsSearch(searchString);
    } else {
        qTotalPosts = objBlog.getTotalPosts();
    }

    pages = ceiling(qTotalPosts.totalPosts / getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt pages) {
        session.p_page = url.page;
    }

    if (session.p_page gt 1){
        tPage = session.p_page - 1;
        valueToAdd = getEntries * tPage;
        p_start = p_start + valueToAdd;
    }

    if (len(trim(searchTerm))) {
        if (FindNoCase("@",searchTerm)){
            searchString = 'AGAINST (''"#searchTerm#"'' IN BOOLEAN MODE)'
        }else {
            searchString = 'AGAINST (''*''"#searchTerm#"''*'' IN BOOLEAN MODE)'
        }

        qPosts = objBlog.getPostsSearch(searchString, p_start, session.p_sort);
    }
    else {

        qPosts = objBlog.getPosts(p_start, session.p_sort);
    }

    timeZones = getTime.getTimezones();
    getModal = new backend.core.com.translate();

</cfscript>



<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Blog</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active">Blog posts</li>
                    </ol>
                </div>
                <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                    <div class="button-group">
                        <button data-bs-toggle="modal" data-bs-target="##post_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> New post
                        </button>
                        <a href="#application.mainURL#/sysadmin/blog-posts/categories" class="btn btn-primary">
                            <i class="fas fa-tags pe-3"></i> Post categories
                        </a>
                    </div>
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
                    <div class="card-header">
                        <h3 class="card-title">Existing blog posts: #qTotalPosts.totalPosts#</h3>
                    </div>
                    <div class="card-body">
                        <form action="#application.mainURL#/sysadmin/blog-posts?page=1" method="post">
                            <div class="row">
                                <div class="col-lg-4">
                                    <label class="form-label">Search for post:</label>
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
                                        <div class="form-label">Sort posts</div>
                                        <select class="form-select" name="sort" onchange="this.form.submit()">
                                            <option value="dtmCreated ASC" <cfif session.p_sort eq "dtmCreated ASC">selected</cfif>>By create date asc</option>
                                            <option value="dtmCreated DESC" <cfif session.p_sort eq "dtmCreated DESC">selected</cfif>>By create date desc</option>
                                            <option value="dtmUpdated ASC" <cfif session.p_sort eq "dtmUpdated ASC">selected</cfif>>By update date asc</option>
                                            <option value="dtmUpdated DESC" <cfif session.p_sort eq "dtmUpdated DESC">selected</cfif>>By update date desc</option>
                                            <option value="strTitle ASC" <cfif session.p_sort eq "strTitle ASC">selected</cfif>>Title A -> Z</option>
                                            <option value="strTitle DESC" <cfif session.p_sort eq "strTitle DESC">selected</cfif>>Title Z -> A</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </form>
                        <div class="table-responsive">
                            <table class="table card-table table-vcenter text-nowrap">
                                <thead>
                                    <tr>
                                        <th width="50%">Title</th>
                                        <th width="10%">Create date</th>
                                        <th width="10%">Update date</th>
                                        <th width="10%">Publish date</th>
                                        <th width="10%" class="text-center">Published</th>
                                        <th width="10%" class="text-center"></th>
                                    </tr>
                                </thead>
                                <cfif qPosts.recordCount>
                                    <tbody id="dragndrop_body">
                                        <cfloop query="qPosts">
                                            <tr>
                                                <td>#qPosts.strPreviewTitle#</td>
                                                <td>#lsDateFormat(qPosts.dtmCreated)#</td>
                                                <td>#lsDateFormat(qPosts.dtmUpdated)#</td>
                                                <td>#lsDateFormat(qPosts.dtePublishDate)#</td>
                                                <td class="text-center">#yesNoFormat(qPosts.blnIsPublished)#</td>
                                                <td class="text-center"><a href="#application.mainURL#/sysadmin/blog-posts/edit/#qPosts.intBlogPostID#" class="btn">Edit</a></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </cfif>
                            </table>
                        </div>
                        <cfif pages neq 1 and qPosts.recordCount>
                            <div class="card-body">
                                <ul class="pagination justify-content-center" id="pagination">

                                    <!--- First Page --->
                                    <li class="page-item <cfif session.p_page eq 1>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=1" tabindex="-1" aria-disabled="true">
                                            <i class="fas fa-angle-double-left"></i>
                                        </a>
                                    </li>

                                    <!--- Prev arrow --->
                                    <li class="page-item <cfif session.p_page eq 1>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#session.p_page-1#" tabindex="-1" aria-disabled="true">
                                            <i class="fas fa-angle-left"></i>
                                        </a>
                                    </li>

                                    <!--- Pages --->
                                    <cfif session.p_page + 4 gt pages>
                                        <cfset blockPage = pages>
                                    <cfelse>
                                        <cfset blockPage = session.p_page + 4>
                                    </cfif>

                                    <cfif blockPage neq pages>
                                        <cfloop index="j" from="#session.p_page#" to="#blockPage#">
                                            <cfif not blockPage gt pages>
                                                <li class="page-item <cfif session.p_page eq j>active</cfif>">
                                                    <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#j#">#j#</a>
                                                </li>
                                            </cfif>
                                        </cfloop>
                                    <cfelseif blockPage lt 5>
                                        <cfloop index="j" from="1" to="#pages#">
                                            <li class="page-item <cfif session.p_page eq j>active</cfif>">
                                                <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#j#">#j#</a>
                                            </li>
                                        </cfloop>
                                    <cfelse>
                                        <cfloop index="j" from="#pages - 4#" to="#pages#">
                                            <li class="page-item <cfif session.p_page eq j>active</cfif>">
                                                <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#j#">#j#</a>
                                            </li>
                                        </cfloop>
                                    </cfif>


                                    <!--- Next arrow --->
                                    <li class="page-item <cfif session.p_page gte pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#session.p_page+1#">
                                            <i class="fas fa-angle-right"></i>
                                        </a>
                                    </li>

                                    <!--- Last Page --->
                                    <li class="page-item <cfif session.p_page gte pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/countries?page=#pages#">
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
    </div>
</div>
<!--- Modal for new post --->
<form action="#application.mainURL#/sysadm/blog-posts" method="post">
<div id="post_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
        <input type="hidden" name="post_new">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">New post</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Post title</label>
                    <input type="text" name="title" class="form-control" autocomplete="off" maxlength="100" required>
                </div>
            </div>
            <div class="modal-footer">
                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                <button type="submit" class="btn btn-primary ms-auto">
                    Save
                </button>
            </div>
        </div>
    </div>
</div>
</form>
</cfoutput>

