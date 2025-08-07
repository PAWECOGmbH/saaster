component displayname="blogposts" output="false" {

    // Create a new blog post using only the title
    public struct function saveNewPost(required string title, required string language) {

        local.title = arguments.title;

        try {

            // Set the mapping path based on the title
            local.mapping = "blog/" & application.objGlobal.beautifyString(local.title);

            // Save frontend mapping
            queryExecute(
                options = {datasource = application.datasource, result = "local.newMappingID"},
                params = {
                    urlSlug: {type: "varchar", value: local.mapping},
                    metaTitle: {type: "nvarchar", value: local.title}
                },
                sql = "
                    INSERT INTO frontend_mappings (strMapping, strMetatitle, blnCreatedByApp)
                    VALUES (:urlSlug, :metaTitle, 1)
                "
            );

            local.newMappingID = local.newMappingID.generated_key;

            // Save post with only title and created date
            queryExecute(
                options = {datasource = application.datasource, result = "local.newPostID"},
                params = {
                    title: {type: "varchar", value: local.title},
                    createdAt: {type: "timestamp", value: now()},
                    newMappingID: {type: "numeric", value: local.newMappingID}
                },
                sql = "
                    INSERT INTO blog_posts (dtmCreated, strPreviewTitle, strPostTitle, intFrontendMappingsID)
                    VALUES (:createdAt, :title, :title, :newMappingID)
                "
            );

            local.newPostID = local.newPostID.generated_key;
            local.path = "templates/blog/post.cfm?id=#local.newPostID#";

            // Update the mapping path with the new post ID
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    mappingID: {type: "numeric", value: local.newMappingID},
                    mappingPath: {type: "varchar", value: local.path}
                },
                sql = "
                    UPDATE frontend_mappings
                    SET strPath = :mappingPath
                    WHERE intFrontendMappingsID = :mappingID
                "
            );

        } catch (any e) {

            return {
                success: false,
                message: "Error creating post: " & e.message
            };

        }

        return {
            success: true,
            postID: local.newPostID,
            message: "Post created successfully. Add your content now.",
        };

    }


    public query function getTotalPostsSearch(required string search) {

        local.qTotalPosts = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intBlogPostID) as totalPosts
                FROM blog_posts
                WHERE MATCH (strTitle, strPreviewText, strButtonText, strContent)
                #arguments.search#
            "
        );

        return local.qTotalPosts;

    }


    public query function getTotalPosts() {

        local.qTotalPosts = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intBlogPostID) as totalPosts
                FROM blog_posts
            "
        );

        return local.qTotalPosts;
    }


    public query function getPosts(required numeric start, required string sort){

        local.entries = 10;

        local.qPosts = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM blog_posts
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qPosts;

    }


    public query function getPost(required numeric postID) {

        local.qPost = queryExecute(
            options = {datasource = application.datasource},
            params = {
                postID: {type: "numeric", value: postID}
            },
            sql = "
                SELECT *,
                (
                    SELECT strMapping
                    FROM frontend_mappings
                    WHERE intFrontendMappingsID = blog_posts.intFrontendMappingsID
                ) AS strMapping
                FROM blog_posts
                WHERE intBlogPostID = :postID
            "
        );

        return local.qPost;


    }


    public query function getBlogCategories() {

        local.qBlogCategories = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM blog_categories
                ORDER BY intPrio
            "
        );

        return local.qBlogCategories;

    }


    public struct function saveCategory(required string categoryName, required numeric categoryID) {

        local.categoryName = arguments.categoryName;
        local.categoryID = arguments.categoryID;

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    categoryName: {type: "varchar", value: local.categoryName},
                    categoryID: {type: "numeric", value: local.categoryID}
                },
                sql = "
                    UPDATE blog_categories
                    SET strCategoryName = :categoryName
                    WHERE intBlogCategoryID = :categoryID
                "
            );

        } catch (any e) {

            return {
                success: false,
                message: "Error updating category: " & e.message
            };

        }

        return {
            success: true,
            message: "Category updated successfully"
        };

    }

    public struct function deleteCategory(required numeric categoryID) {

        local.categoryID = arguments.categoryID;

        qCategory = queryExecute(
            options = {datasource = application.datasource},
            params = {
                categoryID: {type: "numeric", value: local.categoryID}
            },
            sql = "
                SELECT intPrio
                FROM blog_categories
                WHERE intBlogCategoryID = :categoryID
            "
        );

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    categoryID: {type: "numeric", value: local.categoryID},
                    currPrio: {type: "numeric", value: qCategory.intPrio}
                },
                sql = "
                    DELETE FROM blog_categories WHERE intBlogCategoryID = :categoryID;
                    UPDATE blog_categories SET intPrio = intPrio-1 WHERE intPrio > :currPrio
                "
            );

        } catch (any e) {

            return {
                success: false,
                message: "Error deleting category: " & e.message
            };

        }

        return {
            success: true,
            message: "Category deleted successfully"
        };

    }

    public struct function createCategory(required string categoryName) {

        local.categoryName = arguments.categoryName;

        qNexPrio = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COALESCE(MAX(intPrio),0)+1 as nextPrio
                FROM blog_categories
            "
        );

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    categoryName: {type: "varchar", value: local.categoryName},
                    nextPrio: {type: "numeric", value: qNexPrio.nextPrio}
                },
                sql = "
                    INSERT INTO blog_categories (strCategoryName, intPrio)
                    VALUES (:categoryName, :nextPrio)
                "
            );

        } catch (any e) {

            return {
                success: false,
                message: "Error creating category: " & e.message
            };

        }

        return {
            success: true,
            message: "Category created successfully"
        };

    }


    /* Get the list of connected blog categories */
    public string function getConnectedCategories(required numeric postID) {

        local.postID = arguments.postID;

        local.qCategories = queryExecute(
            options = {datasource = application.datasource},
            params = {
                postID: {type: "numeric", value: local.postID}
            },
            sql = "
                SELECT *
                FROM blog_post_categories
                WHERE intBlogPostID = :postID
            "
        );

        local.connectedCategories = "";
        loop query="local.qCategories" {
            local.connectedCategories = listAppend(local.connectedCategories, local.qCategories.intBlogCategoryID);
        }

        return local.connectedCategories;

    }

    public struct function savePost(required struct postStruct) {

        local.postID = arguments.postStruct.postID;
        local.updateDate = now();
        local.isPublished = arguments.postStruct.is_published ?: 0;
        local.publishDate = arguments.postStruct.publish_date ?: "";
        local.unpublishDate = arguments.postStruct.unpublish_date ?: "";
        local.showPublishedDate = arguments.postStruct.show_publish_date ?: 0;
        local.showTOC = arguments.postStruct.show_toc ?: 0;
        local.authorName = arguments.postStruct.author_name ?: "";
        local.showAuthor = arguments.postStruct.show_author ?: 0;
        local.previewTitle = arguments.postStruct.preview_title ?: "";
        local.previewText = arguments.postStruct.preview_text ?: "";
        local.previewImage = arguments.postStruct.preview_image ?: "";
        local.buttonText = arguments.postStruct.button_text ?: "";
        local.headerImage = arguments.postStruct.header_image ?: "";
        local.postTitle = arguments.postStruct.post_title ?: "";
        local.postIntro = arguments.postStruct.post_intro ?: "";
        local.postContent = arguments.postStruct.content ?: "";
        local.errorMessage = "";

        local.connectedCategories = arguments.postStruct.categoryID ?: "";

        if (len(local.publishDate)) {
            local.publishType = "date";
        } else {
            local.publishType = "null";
        }
        if (len(local.unpublishDate)) {
            local.unpublishType = "date";
        } else {
            local.unpublishType = "null";
        }

        if (len(trim(local.previewImage))) {

            local.allowedFileTypes = ["jpg", "jpeg", "png", "gif", "webp"];

            // Build folder path by date: /userdata/images/blog/YYYY/MM/DD
            local.now = now();
            local.year = dateFormat(local.now, "yyyy");
            local.month = dateFormat(local.now, "mm");
            local.day = dateFormat(local.now, "dd");
            local.relPath = "/userdata/images/blog/" & local.year & "/" & local.month & "/" & local.day;
            local.absPath = expandPath(local.relPath);

            // Create the directory if it doesn't exist
            if (!directoryExists(local.absPath)) {
                directoryCreate(local.absPath, true);
            }

            local.uploadArgs = {
                filePath: local.absPath,
                fileNameOrig: "preview_image",
                makeUnique: true
            };

            local.globalObj = new backend.core.com.global();
            local.result = local.globalObj.uploadFile(local.uploadArgs, local.allowedFileTypes);

            if (local.result.success) {
                local.previewImage = local.relPath & "/" & local.result.fileName;
            } else {
                local.errorMessage = "Error uploading preview image: " & local.result.message;
            }

        } else {

            // Get the image from table
            local.qPost = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID}
                },
                sql = "
                    SELECT strPreviewImage
                    FROM blog_posts
                    WHERE intBlogPostID = :postID
                "
            );

            if (local.qPost.recordCount) {
                local.previewImage = local.qPost.strPreviewImage;
            }

        }

        if (len(trim(local.headerImage))) {

            local.allowedFileTypes = ["jpg", "jpeg", "png", "gif", "webp"];

            // Build folder path by date: /userdata/images/blog/YYYY/MM/DD
            local.now = now();
            local.year = dateFormat(local.now, "yyyy");
            local.month = dateFormat(local.now, "mm");
            local.day = dateFormat(local.now, "dd");
            local.relPath = "/userdata/images/blog/" & local.year & "/" & local.month & "/" & local.day;
            local.absPath = expandPath(local.relPath);

            // Create the directory if it doesn't exist
            if (!directoryExists(local.absPath)) {
                directoryCreate(local.absPath, true);
            }

            local.uploadArgs = {
                filePath: local.absPath,
                fileNameOrig: "header_image",
                makeUnique: true
            };

            local.globalObj = new backend.core.com.global();
            local.result = local.globalObj.uploadFile(local.uploadArgs, local.allowedFileTypes);

            if (local.result.success) {
                local.headerImage = local.relPath & "/" & local.result.fileName;
            } else {
                local.errorMessage = "Error uploading header image: " & local.result.message;
            }

        } else {

            // Get the image from table
            local.qPost = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID}
                },
                sql = "
                    SELECT strBlogHeaderImage
                    FROM blog_posts
                    WHERE intBlogPostID = :postID
                "
            );

            if (local.qPost.recordCount) {
                local.headerImage = local.qPost.strBlogHeaderImage;
            }

        }

        try {

            // Check if frontend mapping exists and if not, create it
            local.qMapping = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID}
                },
                sql = "
                    SELECT bp.intFrontendMappingsID
                    FROM blog_posts bp
                    INNER JOIN frontend_mappings fm
                    ON bp.intFrontendMappingsID = fm.intFrontendMappingsID
                    WHERE bp.intBlogPostID = :postID
                "
            );

            if (local.qMapping.recordCount) {

                local.mappingID = local.qMapping.intFrontendMappingsID;

            } else {

                // Set the mapping path based on the title
                local.mapping = "blog/" & application.objGlobal.beautifyString(local.previewTitle);
                local.path = "templates/blog/post.cfm?id=#local.postID#";

                // Save frontend mapping
                queryExecute(
                    options = {datasource = application.datasource, result = "local.newMappingID"},
                    params = {
                        urlSlug: {type: "varchar", value: local.mapping},
                        metaTitle: {type: "nvarchar", value: local.previewTitle},
                        postPath: {type: "varchar", value: local.path}
                    },
                    sql = "
                        INSERT INTO frontend_mappings (strMapping, strMetatitle, strPath)
                        VALUES (:urlSlug, :metaTitle, :postPath)
                    "
                );

                local.mappingID = local.newMappingID.generated_key;

            }

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID},
                    updateDate: {type: "datetime", value: local.updateDate},
                    isPublished: {type: "boolean", value: local.isPublished},
                    publishDate: {type: local.publishType, value: local.publishDate},
                    unpublishDate: {type: local.unpublishType, value: local.unpublishDate},
                    showPublishedDate: {type: "boolean", value: local.showPublishedDate},
                    showTOC: {type: "boolean", value: local.showTOC},
                    authorName: {type: "nvarchar", value: local.authorName},
                    showAuthor: {type: "boolean", value: local.showAuthor},
                    previewTitle: {type: "nvarchar", value: local.previewTitle},
                    previewText: {type: "nvarchar", value: local.previewText},
                    previewImage: {type: "varchar", value: local.previewImage},
                    buttonText: {type: "nvarchar", value: local.buttonText},
                    headerImage: {type: "varchar", value: local.headerImage},
                    postTitle: {type: "nvarchar", value: local.postTitle},
                    postIntro: {type: "nvarchar", value: local.postIntro},
                    postContent: {type: "nvarchar", value: local.postContent},
                    mappingID: {type: "numeric", value: local.mappingID}
                },
                sql = "
                    UPDATE blog_posts
                    SET dtmUpdated = :updateDate,
                        blnIsPublished = :isPublished,
                        dtePublishDate = :publishDate,
                        dteUnpublishDate = :unpublishDate,
                        blnShowPublishedDate = :showPublishedDate,
                        blnShowTOC = :showTOC,
                        strAuthorName = :authorName,
                        blnShowAuthor = :showAuthor,
                        strPreviewTitle = :previewTitle,
                        strPreviewText = :previewText,
                        strPreviewImage = :previewImage,
                        strButtonText = :buttonText,
                        strBlogHeaderImage = :headerImage,
                        strPostTitle = :postTitle,
                        strPostIntro = :postIntro,
                        strPostContent = :postContent,
                        intFrontendMappingsID = :mappingID
                    WHERE intBlogPostID = :postID
                "
            );

            // Update categories
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID}
                },
                sql = "
                    DELETE FROM blog_post_categories WHERE intBlogPostID = :postID
                "
            );

            if (len(trim(local.connectedCategories))) {
                arrayOfCategories = listToArray(local.connectedCategories);
                for (local.category in arrayOfCategories) {
                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            postID: {type: "numeric", value: local.postID},
                            categoryID: {type: "numeric", value: local.category}
                        },
                        sql = "
                            INSERT INTO blog_post_categories (intBlogPostID, intBlogCategoryID)
                            VALUES (:postID, :categoryID)
                        "
                    );
                }
            }

        } catch (any e) {

            return {
                success: false,
                message: "Error saving post: " & e.message
            };

        }

        if (len(local.errorMessage)) {
            return {
                success: false,
                message: local.errorMessage
            };
        }

        return {
            success: true,
            message: "Post saved successfully"
        };

    }

    // Delete post
    public struct function deletePost(required numeric postID) {

        local.postID = arguments.postID;

        // Get all images associated with the post
        // we need to scan the content for image URLs
        local.qPost = queryExecute(
            options = {datasource = application.datasource},
            params = {
                postID: {type: "numeric", value: local.postID}
            },
            sql = "
                SELECT strPostContent, strPreviewImage, intFrontendMappingsID
                FROM blog_posts
                WHERE intBlogPostID = :postID
            "
        );

        local.imageURLs = [];

        // Scan the post content for image URLs that start with /userdata/images/blog
        if (local.qPost.recordCount) {

            local.postContent = local.qPost.strPostContent;

            // Use reMatchNoCase to find all img tags with src attributes
            local.imgTags = reMatchNoCase('<img[^>]+src="[^"]+"', local.postContent);
            local.imageURLs = [];

            for (local.tag in local.imgTags) {

                // Extract the src value from each img tag
                local.srcMatch = reFindNoCase('src="([^"]+)"', local.tag, 1, true);
                if (
                    arrayLen(local.srcMatch.pos) &&
                    local.srcMatch.len[2] > 0
                ) {
                    local.imgUrl = mid(local.tag, local.srcMatch.pos[2], local.srcMatch.len[2]);
                    if (left(local.imgUrl, 21) eq "/userdata/images/blog") {
                    arrayAppend(local.imageURLs, local.imgUrl);
                    }
                }

            }

            // Also check the preview image
            if (len(trim(local.qPost.strPreviewImage)) && left(local.qPost.strPreviewImage, 21) eq "/userdata/images/blog") {
                arrayAppend(local.imageURLs, local.qPost.strPreviewImage);
            }

        }

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID},
                    mappingID: {type: "numeric", value: local.qPost.intFrontendMappingsID}
                },
                sql = "
                    DELETE FROM blog_posts WHERE intBlogPostID = :postID;
                    DELETE FROM frontend_mappings WHERE intFrontendMappingsID = :mappingID;
                "
            );

        } catch (any e) {

            return {
                success: false,
                message: "Error deleting post: " & e.message
            };

        }

        // Delete associated images
        for (local.imgUrl in local.imageURLs) {
            local.absImgPath = expandPath(local.imgUrl);
            if (fileExists(local.absImgPath)) {
                fileDelete(local.absImgPath);
            }
        }

        return {
            success: true,
            message: "Post deleted successfully"
        };

    }

    // Delete preview image
    public struct function deletePreviewImage(required numeric postID) {

        local.postID = arguments.postID;

        // Get the current preview image path
        local.qPost = queryExecute(
            options = {datasource = application.datasource},
            params = {
                postID: {type: "numeric", value: local.postID}
            },
            sql = "
                SELECT strPreviewImage
                FROM blog_posts
                WHERE intBlogPostID = :postID
            "
        );

        local.currentPreviewImage = local.qPost.strPreviewImage;

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID}
                },
                sql = "
                    UPDATE blog_posts
                    SET strPreviewImage = ''
                    WHERE intBlogPostID = :postID
                "
            );

            // Delete the preview image from the filesystem
            if (len(trim(local.currentPreviewImage))) {

                local.absImgPath = expandPath(local.currentPreviewImage);
                if (fileExists(local.absImgPath)) {
                    fileDelete(local.absImgPath);
                }

            }

        } catch (any e) {

            return {
                success: false,
                message: "Error deleting preview image: " & e.message
            };

        }

        return {
            success: true,
            message: "Preview image deleted successfully"
        };

    }


    // Delete header image
    public struct function deleteHeaderImage(required numeric postID) {

        local.postID = arguments.postID;

        // Get the current header image path
        local.qPost = queryExecute(
            options = {datasource = application.datasource},
            params = {
                postID: {type: "numeric", value: local.postID}
            },
            sql = "
                SELECT strBlogHeaderImage
                FROM blog_posts
                WHERE intBlogPostID = :postID
            "
        );

        local.currentHeaderImage = local.qPost.strBlogHeaderImage;

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    postID: {type: "numeric", value: local.postID}
                },
                sql = "
                    UPDATE blog_posts
                    SET strBlogHeaderImage = ''
                    WHERE intBlogPostID = :postID
                "
            );

            // Delete the header image from the filesystem
            if (len(trim(local.currentHeaderImage))) {

                local.absImgPath = expandPath(local.currentHeaderImage);
                if (fileExists(local.absImgPath)) {
                    fileDelete(local.absImgPath);
                }

            }

        } catch (any e) {

            return {
                success: false,
                message: "Error deleting header image: " & e.message
            };

        }

        return {
            success: true,
            message: "Header image deleted successfully"
        };

    }

}
