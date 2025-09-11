<cfscript>

if (structKeyExists(form, "post_new")) {

    objPosts = new backend.core.com.blog();

    if (len(trim(form.title))) {

        saveNewPost = objPosts.saveNewPost(form.title, session.lng);
        if (saveNewPost.success) {
            getAlert("Post saved successfully", "success");
            location url="#application.mainURL#/sysadmin/blog-posts/edit/#saveNewPost.postID#" addtoken="false";
        } else {
            getAlert("Error saving post: " & saveNewPost.message, "danger");
        }

    }

}

if (structKeyExists(form, "edit_category")) {

    objPosts = new backend.core.com.blog();

    if (len(trim(form.category_name))) {

        saveCategory = objPosts.saveCategory(form.category_name, form.edit_category);
        if (saveCategory.success) {
            getAlert("Category saved successfully", "success");
        } else {
            getAlert("Error saving category: " & saveCategory.message, "danger");
        }

        location url="#application.mainURL#/sysadmin/blog-posts/categories" addtoken="false";

    }

}

if (structKeyExists(url, "delete_category")) {

    objPosts = new backend.core.com.blog();

    deleteCategory = objPosts.deleteCategory(url.delete_category);
    if (deleteCategory.success) {
        getAlert("Category deleted successfully", "success");
    } else {
        getAlert("Error deleting category: " & deleteCategory.message, "danger");
    }

    location url="#application.mainURL#/sysadmin/blog-posts/categories" addtoken="false";

}

if (structKeyExists(form, "new_category")) {

    if (len(trim(form.category_name))) {

        objPosts = new backend.core.com.blog();

        createCategory = objPosts.createCategory(form.category_name);
        if (createCategory.success) {
            getAlert("Category created successfully", "success");
        } else {
            getAlert("Error creating category: " & createCategory.message, "danger");
        }

    }

    location url="#application.mainURL#/sysadmin/blog-posts/categories" addtoken="false";

}

if (structKeyExists(url, "delete_post")) {

    objPosts = new backend.core.com.blog();

    deletePost = objPosts.deletePost(url.delete_post);
    if (deletePost.success) {
        getAlert("Post deleted successfully", "success");
    } else {
        getAlert("Error deleting post: " & deletePost.message, "danger");
    }

    location url="#application.mainURL#/sysadmin/blog-posts" addtoken="false";

}

// Delete preview image
if (structKeyExists(url, "delete_image")) {

    objPosts = new backend.core.com.blog();

    deleteImage = objPosts.deletePreviewImage(url.delete_image);
    if (deleteImage.success) {
        getAlert("Preview image deleted successfully", "success");
    } else {
        getAlert("Error deleting preview image: " & deleteImage.message, "danger");
    }

    location url="#application.mainURL#/sysadmin/blog-posts/edit/#url.delete_image#" addtoken="false";

}

// Delete header image
if (structKeyExists(url, "delete_header_image")) {

    objPosts = new backend.core.com.blog();

    deleteImage = objPosts.deleteHeaderImage(url.delete_header_image);
    if (deleteImage.success) {
        getAlert("Header image deleted successfully", "success");
    } else {
        getAlert("Error deleting header image: " & deleteImage.message, "danger");
    }

    location url="#application.mainURL#/sysadmin/blog-posts/edit/#url.delete_header_image#" addtoken="false";

}

if (structKeyExists(form, "postID")) {

    objPosts = new backend.core.com.blog();

    savePost = objPosts.savePost(form);
    if (savePost.success) {
        getAlert("Post updated successfully", "success");
    } else {
        getAlert("Error updating post: " & savePost.message, "danger");
    }

    location url="#application.mainURL#/sysadmin/blog-posts/edit/#form.postID#" addtoken="false";


}

location url="#application.mainURL#/sysadmin/blog-posts" addtoken="false";

</cfscript>