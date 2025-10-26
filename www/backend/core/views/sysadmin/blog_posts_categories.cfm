
<cfscript>

    objBlog = new backend.core.com.blog();
    getModal = new backend.core.com.translate();

    qCategories = objBlog.getBlogCategories();

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
                        <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/blog-posts">Blog posts</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Blog categories</li>
                    </ol>
                </div>
                <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                    <div class="button-group">
                        <a href="#application.mainURL#/sysadmin/blog-posts" class="btn btn-primary">
                            <i class="fas fa-angle-double-left pe-3"></i> Back to blog posts
                        </a>
                        <a href="##" data-bs-toggle="modal" data-bs-target="##category_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add category
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
                        <h3 class="card-title">Post categories</h3>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table card-table table-vcenter text-nowrap">
                                <thead>
                                    <tr>
                                        <th width="5%"></th>
                                        <th width="5%" class="text-center">Prio</th>
                                        <th width="80%">Category Name</th>
                                        <th width="5%"></th>
                                        <th width="5%"></th>
                                    </tr>
                                </thead>
                                <tbody <cfif qCategories.recordCount gt 1>id="dragndrop_body"</cfif>>
                                    <cfloop query="qCategories">
                                        <tr <cfif qCategories.recordCount gt 1>id="sort_#qCategories.intBlogCategoryID#"</cfif>>
                                            <td class="move text-center"><cfif qCategories.recordCount gt 1><i class="fas fa-bars hand" style="cursor: grab;"></i></cfif></td>
                                            <td class="text-center">#qCategories.intPrio#</td>
                                            <td>#qCategories.strCategoryName# <a href="##?" data-bs-toggle="modal" data-bs-target="##trans_category_#qCategories.intBlogCategoryID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate category"></i></a></td>
                                            <td><a href="##" class="btn" data-bs-toggle="modal" data-bs-target="##category_#qCategories.intBlogCategoryID#">Edit</a></td>
                                            <td><a href="##" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/blog-posts?delete_category=#qCategories.intBlogCategoryID#', 'Delete blog category', 'Do you want to delete this category?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                                        </tr>
                                        <div id="category_#qCategories.intBlogCategoryID#" class='modal fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                            <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
                                                <form action="#application.mainURL#/sysadm/blog-posts" method="post">
                                                <input type="hidden" name="edit_category" value="#qCategories.intBlogCategoryID#">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Edit blog category</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="mb-3">
                                                                <label class="form-label">Category name</label>
                                                                <input type="text" name="category_name" class="form-control" autocomplete="off" value="#HTMLEditFormat(qCategories.strCategoryName)#" maxlength="100" required>
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
                                        #getModal.args('blog_categories', 'strCategoryName', qCategories.intBlogCategoryID, 100).openModal('trans_category', cgi.path_info, 'Translate blog category')#
                                        <cfif qCategories.recordCount gt 1>
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
                                                            jsonTmp += "\"intBlogCategoryID\" :" + aTR[1] + '},';
                                                        }
                                                    );
                                                    jsonTmp += jsonTmp.slice(0,-1);
                                                    jsonTmp += "]]";
                                                    var ajaxResponse = $.ajax({
                                                        type: "post",
                                                        url: "#application.mainURL#/backend/core/handler/ajax_sort.cfm?blog_categories",
                                                        contentType: "application/json",
                                                        data: JSON.stringify( jsonTmp )
                                                    })
                                                    // Response
                                                    ajaxResponse.then(
                                                        function( apiResponse ){
                                                            if(apiResponse.trim() == 'ok'){
                                                                location.href = '#application.mainURL#/sysadmin/blog-posts/categories';
                                                            }
                                                        }
                                                    );
                                                }
                                            </script>
                                        </cfif>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!--- Modal for new group --->
<form action="#application.mainURL#/sysadm/blog-posts" method="post">
<div id="category_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
        <input type="hidden" name="new_category">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add category</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Category name</label>
                    <input type="text" name="category_name" class="form-control" autocomplete="off" maxlength="100" required>
                </div>
            </div>
            <div class="modal-footer">
                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                <button type="submit" class="btn btn-primary ms-auto">
                    Save category
                </button>
            </div>
        </div>
    </div>
</div>
</form>
</cfoutput>

