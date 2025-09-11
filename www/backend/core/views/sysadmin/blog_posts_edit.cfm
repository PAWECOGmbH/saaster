
<cfscript>

    // Exception handling for url slug
    param name="thiscontent.thisID" default=0 type="numeric";
    postID = thiscontent.thisID;
    if(not isNumeric(postID) or postID lte 0) {
        location url="#application.mainURL#/sysadmin/blog-posts" addtoken="false";
    }

    objPosts = new backend.core.com.blog();
    qPost = objPosts.getPost(postID);
    if (!qPost.recordCount) {
        location url="#application.mainURL#/sysadmin/blog-posts" addtoken="false";
    }

    qCategories = objPosts.getBlogCategories();
    connectedCategories = objPosts.getConnectedCategories(postID);

    fileList = application.objGlobal.buildAllowedFileLists(variables.imageFileTypes);

    allowedFileTypesList = fileList.allowedFileTypesList;
    acceptFileTypesList = fileList.acceptFileTypesList;

    frontendMappingID = isNumeric(qPost.intFrontendMappingsID) ? qPost.intFrontendMappingsID : 0;
    qMapping = application.objSysadmin.getFrontendMappings(frontendMappingID);
    getModal = new backend.core.com.translate();

</cfscript>


<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-12">
                <div class="#getLayout.layoutPageHeader# mb-2">
                    <h4 class="page-title">Blog</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/blog-posts">Blog posts</a></li>
                        <li class="breadcrumb-item active">#qPost.strPreviewTitle#</li>
                    </ol>
                </div>
                <div class="d-flex justify-content-end gap-2 flex-wrap">
                    <cfif len(trim(qPost.strMapping))>
                        <button type="button" class="btn btn-primary" onclick="window.open('#application.mainURL#/#qPost.strMapping#?preview', '_blank')">
                            <i class="fas fa-eye me-2"></i> Preview
                        </button>
                    </cfif>
                    <a href="#application.mainURL#/sysadmin/blog-posts" class="btn btn-primary">
                        <i class="fas fa-chevron-left pe-2"></i> Back to overview
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
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h3 class="card-title mb-0">Edit your blog post</h3>
                        <div class="text-end">
                            <div class="text-muted small">Created: #lsDateFormat(qPost.dtmCreated)#</div>
                            <div class="text-muted small">Updated: <cfif isDate(qPost.dtmUpdated)>#lsDateFormat(qPost.dtmUpdated)#<cfelse>n/a</cfif></div>
                        </div>
                    </div>
                    <form action="#application.mainURL#/sysadm/blog-posts" method="post" enctype="multipart/form-data">
                        <div class="card-body">
                            <input type="hidden" name="postID" value="#qPost.intBlogPostID#">
                            <input type="hidden" name="author_name" value="#session.user_name#">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <h3><b>Blog settings</b></h3>
                                    </div>
                                    <div class="mb-2">
                                        <div class="row mb-4">
                                            <div class="col-md-4">
                                                <label class="form-label mb-3">Published?</label>
                                                <label class="form-check form-switch form-switch-2">
                                                    <input class="form-check-input" type="checkbox" value="1" name="is_published" <cfif qPost.blnIsPublished>checked</cfif>>
                                                    <span class="form-check-label">Is published</span>
                                                </label>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Publish date</label>
                                                <div class="position-relative">
                                                    <input class="form-control ps-5" placeholder="Select a date" name="publish_date" id="publish_date" value="#dateFormat(qPost.dtePublishDate, 'yyyy-mm-dd')#" required>
                                                    <span class="position-absolute top-50 start-0 translate-middle-y ms-3 text-muted">
                                                        <i class="far fa-calendar-alt"></i>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Unpublish date</label>
                                                <div class="position-relative">
                                                    <input class="form-control ps-5" placeholder="Optional" name="unpublish_date" id="unpublish_date" value="#dateFormat(qPost.dteUnpublishDate, 'yyyy-mm-dd')#">
                                                    <span class="position-absolute top-50 start-0 translate-middle-y ms-3 text-muted">
                                                        <i class="far fa-calendar-alt"></i>
                                                    </span>
                                                    <button type="button" class="btn btn-sm position-absolute top-50 end-0 translate-middle-y me-2" id="clear_unpublish_date" title="Delete date" style="z-index:2;">
                                                        <i class="fas fa-times text-muted"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-4">
                                                <label class="form-check form-switch form-switch-2">
                                                    <input class="form-check-input" type="checkbox" value="1" name="show_publish_date" <cfif qPost.blnShowPublishedDate>checked</cfif>>
                                                    <span class="form-check-label">Show publish date</span>
                                                </label>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-check form-switch form-switch-2">
                                                    <input class="form-check-input" type="checkbox" value="1" name="show_toc" <cfif qPost.blnShowTOC>checked</cfif>>
                                                    <span class="form-check-label">Show table of contents</span>
                                                </label>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-check form-switch form-switch-2">
                                                    <input class="form-check-input" type="checkbox" value="1" name="show_author" <cfif qPost.blnShowAuthor>checked</cfif>>
                                                    <span class="form-check-label">Show author <br><span class="text-muted small">(#session.user_name#)</span>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <h3><b>Blog categories</b></h3>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Select one or more categories (optional)</label>
                                        <select id="categories" class="form-select" name="categoryID" multiple autocomplete="off" tabindex="-1">
                                            <cfloop query="qCategories">
                                                <option value="#qCategories.intBlogCategoryID#" <cfif listFind(connectedCategories, qCategories.intBlogCategoryID)>selected</cfif>>#qCategories.strCategoryName#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <cfif qMapping.recordCount>
                                            <a class="btn" href="#application.mainURL#/sysadmin/mapping/edit?mappingID=#qPost.intFrontendMappingsID#" target="_blank">URL Slug & Meta tags</a>
                                        <cfelse>
                                            <button class="btn" disabled>Add URL Slug & Meta tags</button>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                            <hr>
                            <div class="row mb-3">
                                <h3><b>Blog Overview</b></h3>
                            </div>
                            <div class="row mb-4">
                                <div class="col-md-8">
                                    <div class="mb-3">
                                        <label class="form-label">Preview title</label>
                                        <div class="input-group input-group-flat">
                                            <input type="text" name="preview_title" class="form-control" value="#HTMLEditFormat(qPost.strPreviewTitle)#" maxlength="255" required>
                                            <span class="input-group-text">
                                                <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##preview_title_#qPost.intBlogPostID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate preview title"></i></a>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Preview text</label>
                                        <div class="input-group input-group-flat">
                                            <textarea name="preview_text" class="form-control" rows="5" maxlength="3000">#HTMLEditFormat(qPost.strPreviewText)#</textarea>
                                            <span class="input-group-text">
                                                <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##preview_text_#qPost.intBlogPostID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate preview text"></i></a>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label class="form-label">Post button text</label>
                                        <div class="input-group input-group-flat">
                                            <input type="text" name="button_text" class="form-control" value="#HTMLEditFormat(qPost.strButtonText)#" maxlength="100">
                                            <span class="input-group-text">
                                                <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##button_text_#qPost.intBlogPostID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate button text"></i></a>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Preview image</label>
                                        <cfif len(qPost.strPreviewImage)>
                                            <div class="d-flex align-items-center mb-2">
                                                <img src="#qPost.strPreviewImage#" alt="Preview Image" style="max-width: 300px; max-height: 110px;" />
                                                <a href="##?" class="ms-3 text-danger" title="Delete image" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/blog-posts?delete_image=#qPost.intBlogPostID#', 'Delete preview image', 'Do you want to delete this image?', 'No, cancel!', 'Yes, delete!')">
                                                    <i class="fas fa-trash-alt fa-lg"></i>
                                                </a>
                                            </div>
                                        <cfelse>
                                            <input name="preview_image" type="file" accept="#allowedFileTypesList#" class="dropify" data-height="100" data-allowed-file-extensions='[#acceptFileTypesList#]' data-max-file-size="1M" />
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                            <div class="row mb-3 align-items-center">
                                <hr>
                                <div class="col">
                                    <h3><b>Blog Post</b></h3>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-8">
                                    <div class="mb-3">
                                        <label class="form-label">Post title</label>
                                        <div class="input-group input-group-flat">
                                            <input type="text" name="post_title" class="form-control" value="#HTMLEditFormat(qPost.strPostTitle)#" maxlength="255">
                                            <span class="input-group-text">
                                                <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##post_title_#qPost.intBlogPostID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate post title"></i></a>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Post intro</label>
                                        <div class="input-group input-group-flat">
                                            <textarea name="post_intro" class="form-control" rows="5" maxlength="3000">#HTMLEditFormat(qPost.strPostIntro)#</textarea>
                                            <span class="input-group-text">
                                                <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##post_intro_#qPost.intBlogPostID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate post intro"></i></a>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label class="form-label">Header image</label>
                                        <cfif len(qPost.strBlogHeaderImage)>
                                            <div class="d-flex align-items-center mb-2">
                                                <img src="#qPost.strBlogHeaderImage#" alt="Header Image" style="max-width: 300px; max-height: 180px;" />
                                                <a href="##?" class="ms-3 text-danger" title="Delete image" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/blog-posts?delete_header_image=#qPost.intBlogPostID#', 'Delete header image', 'Do you want to delete this image?', 'No, cancel!', 'Yes, delete!')">
                                                    <i class="fas fa-trash-alt fa-lg"></i>
                                                </a>
                                            </div>
                                        <cfelse>
                                            <input name="header_image" type="file" accept="#allowedFileTypesList#" class="dropify" data-height="180" data-allowed-file-extensions='[#acceptFileTypesList#]' data-max-file-size="1M" />
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="mb-3">
                                    <label class="form-label">Content <a href="##?" class="input-group-link ms-2" data-bs-toggle="modal" data-bs-target="##post_content_#qPost.intBlogPostID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate post content"></i></a></label>
                                    <textarea class="form-control big-editor" name="content" style="height: 800px;">#qPost.strPostContent#</textarea>
                                </div>
                            </div>
                        </div>
                        <div class="card-footer d-flex justify-content-between">
                            <button type="submit" class="btn btn-primary">Save changes</button>
                            <a href="##?" class="btn btn-danger ms-auto" title="Delete post" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/blog-posts?delete_post=#postID#', 'Delete post', 'Are you sure you want to delete this post?', 'No, cancel!', 'Yes, delete!')">Delete post</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
#getModal.args('blog_posts', 'strPreviewTitle', qPost.intBlogPostID).openModal('preview_title', cgi.path_info, 'Translate preview title')#
#getModal.args('blog_posts', 'strPreviewText', qPost.intBlogPostID).openModal('preview_text', cgi.path_info, 'Translate preview text')#
#getModal.args('blog_posts', 'strButtonText', qPost.intBlogPostID).openModal('button_text', cgi.path_info, 'Translate button text')#
#getModal.args('blog_posts', 'strPostTitle', qPost.intBlogPostID).openModal('post_title', cgi.path_info, 'Translate post title')#
#getModal.args('blog_posts', 'strPostIntro', qPost.intBlogPostID).openModal('post_intro', cgi.path_info, 'Translate post intro')#
#getModal.args('blog_posts', 'strPostContent', qPost.intBlogPostID).openModal('post_content', cgi.path_info, 'Translate post content', 'big-editor')#
</cfoutput>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        window.Litepicker && (new Litepicker({
            element: document.getElementById('publish_date'),
            buttonText: {
                previousMonth: `<i class="fas fa-angle-left cursor-pointer"></i>`,
                nextMonth: `<i class="fas fa-angle-right cursor-pointer"></i>`,
            },
        }));
    });
    document.addEventListener("DOMContentLoaded", function () {
        window.Litepicker && (new Litepicker({
            element: document.getElementById('unpublish_date'),
            buttonText: {
                previousMonth: `<i class="fas fa-angle-left cursor-pointer"></i>`,
                nextMonth: `<i class="fas fa-angle-right cursor-pointer"></i>`,
            },
        }));
    });

    document.addEventListener('DOMContentLoaded', function() {
        new TomSelect("#categories", {
            plugins: ['remove_button', 'no_backspace_delete']
        });
    });

    // Delete date button
    var clearUnpublishBtn = document.getElementById('clear_unpublish_date');
    var unpublishInput = document.getElementById('unpublish_date');
    if (clearUnpublishBtn && unpublishInput) {
        clearUnpublishBtn.addEventListener('click', function() {
            unpublishInput.value = '';
            unpublishInput.setAttribute('value', '');
            unpublishInput.dispatchEvent(new Event('input'));
        });
    }


</script>