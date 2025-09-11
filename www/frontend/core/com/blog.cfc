component displayname="frontendBlog" output="false" {

    /**
     * Returns an array with all blog posts for the overview page.
     */
    public array function getOverviewPosts(numeric start=0, string sort="dtmCreated DESC", numeric limit=10, string lng="en", category=0) {

        // Get the language ID based on the provided language code
        local.languageID = application.objLanguage.getAnyLanguage(arguments.lng).lngID;

        // Category join
        if (arguments.category gt 0) {
            local.categoryJoin = " INNER JOIN blog_post_categories ON bp.intBlogPostID = blog_post_categories.intBlogPostID AND blog_post_categories.intBlogCategoryID = :category";
        } else {
            local.categoryJoin = "";
        }

        local.posts = [];
        local.qPosts = queryExecute(
            options = {datasource = application.datasource},
            params = {
                start: {type: "numeric", value: arguments.start},
                limit: {type: "numeric", value: arguments.limit},
                languageID: {type: "numeric", value: local.languageID},
                category: {type: "numeric", value: arguments.category}
            },
            sql = "
                SELECT
                    bp.intBlogPostID,
                    bp.dtmCreated,
                    bp.dtmUpdated,
                    bp.blnIsPublished,
                    bp.dtePublishDate,
                    bp.dteUnpublishDate,
                    bp.blnShowPublishedDate,
                    bp.blnShowTOC,
                    bp.strAuthorName,
                    bp.blnShowAuthor,
                    bp.strPreviewImage,
                    bp.strBlogHeaderImage,
                    bp.intFrontendMappingsID,
                    COALESCE(bpt.strPreviewTitle, bp.strPreviewTitle) as strPreviewTitle,
                    COALESCE(bpt.strPreviewText, bp.strPreviewText) as strPreviewText,
                    COALESCE(bpt.strPostTitle, bp.strPostTitle) as strPostTitle,
                    COALESCE(bpt.strButtonText, bp.strButtonText) as strButtonText,
                    COALESCE(bpt.strPostIntro, bp.strPostIntro) as strPostIntro,
                    COALESCE(bpt.strPostContent, bp.strPostContent) as strPostContent,
                    COALESCE(fmt.strMapping, fm.strMapping) as strMapping
                FROM blog_posts bp
                LEFT JOIN blog_posts_trans bpt
                    ON bp.intBlogPostID = bpt.intBlogPostID
                    AND bpt.intLanguageID = :languageID
                LEFT JOIN frontend_mappings fm
                    ON bp.intFrontendMappingsID = fm.intFrontendMappingsID
                LEFT JOIN frontend_mappings_trans fmt
                    ON fm.intFrontendMappingsID = fmt.intFrontendMappingsID
                    AND fmt.intLanguageID = :languageID
                #local.categoryJoin#
                WHERE bp.blnIsPublished = 1
                  AND bp.dtePublishDate <= NOW()
                  AND (bp.dteUnpublishDate IS NULL OR bp.dteUnpublishDate > NOW())
                ORDER BY #sort#
                LIMIT #start#, #limit#
            "
        );

        for (local.row=1; local.row <= local.qPosts.recordCount; local.row++) {
            // Get categories for this post
            local.qCats = queryExecute(
                options = {datasource = application.datasource},
                params = { postID: {type: "numeric", value: local.qPosts["intBlogPostID"][local.row]} },
                sql = "
                    SELECT c.intBlogCategoryID, c.strCategoryName, c.intPrio
                    FROM blog_post_categories pc
                    INNER JOIN blog_categories c ON pc.intBlogCategoryID = c.intBlogCategoryID
                    WHERE pc.intBlogPostID = :postID
                    ORDER BY c.intPrio
                "
            );
            local.categories = [];
            for (local.catRow=1; local.catRow <= local.qCats.recordCount; local.catRow++) {
                arrayAppend(local.categories, {
                    'id': local.qCats["intBlogCategoryID"][local.catRow],
                    'name': local.qCats["strCategoryName"][local.catRow],
                    'prio': local.qCats["intPrio"][local.catRow]
                });
            }
            arrayAppend(local.posts, {
                'id': local.qPosts["intBlogPostID"][local.row],
                'title': local.qPosts["strPostTitle"][local.row],
                'previewTitle': local.qPosts["strPreviewTitle"][local.row],
                'previewText': local.qPosts["strPreviewText"][local.row],
                'previewImage': local.qPosts["strPreviewImage"][local.row],
                'buttonText': local.qPosts["strButtonText"][local.row],
                'author': local.qPosts["strAuthorName"][local.row],
                'showAuthor': local.qPosts["blnShowAuthor"][local.row],
                'published': local.qPosts["blnIsPublished"][local.row],
                'publishDate': local.qPosts["dtePublishDate"][local.row],
                'showPublishedDate': local.qPosts["blnShowPublishedDate"][local.row],
                'created': local.qPosts["dtmCreated"][local.row],
                'updated': local.qPosts["dtmUpdated"][local.row],
                'categories': local.categories,
                'mapping': local.qPosts["strMapping"][local.row]
            });
        }

        return local.posts;

    }

    /**
     * Returns a struct with all data for a single blog post.
     */
    public struct function getPostData(required numeric postID, numeric preview=0, string lng="de") {

        if (structKeyExists(arguments, "preview") and arguments.preview eq 1) {
            local.published = "";
        } else {
            local.published = " AND bp.blnIsPublished = 1 AND bp.dtePublishDate <= NOW() AND (bp.dteUnpublishDate IS NULL OR bp.dteUnpublishDate > NOW())";
        }

        local.languageID = application.objLanguage.getAnyLanguage(arguments.lng).lngID;

        local.qPost = queryExecute(
            options = {datasource = application.datasource},
            params = {
                postID: {type: "numeric", value: arguments.postID},
                languageID: {type: "numeric", value: local.languageID}
            },
            sql = "
                SELECT
                    bp.intBlogPostID,
                    bp.dtmCreated,
                    bp.dtmUpdated,
                    bp.dtePublishDate,
                    bp.dteUnpublishDate,
                    bp.blnShowPublishedDate,
                    bp.blnShowTOC,
                    bp.strAuthorName,
                    bp.blnShowAuthor,
                    bp.strBlogHeaderImage,
                    bp.intFrontendMappingsID,
                    bp.blnIsPublished,
                    COALESCE(bpt.strPostTitle, bp.strPostTitle) as strPostTitle,
                    COALESCE(bpt.strButtonText, bp.strButtonText) as strButtonText,
                    COALESCE(bpt.strPostIntro, bp.strPostIntro) as strPostIntro,
                    COALESCE(bpt.strPostContent, bp.strPostContent) as strPostContent
                FROM blog_posts bp
                LEFT JOIN blog_posts_trans bpt
                    ON bp.intBlogPostID = bpt.intBlogPostID
                    AND bpt.intLanguageID = :languageID
                WHERE bp.intBlogPostID = :postID
                #local.published#
            "
        );

        if (!local.qPost.recordCount) return {};

        local.row = 1;

        // Get categories for this post
        local.qCats = queryExecute(
            options = {datasource = application.datasource},
            params = { postID: {type: "numeric", value: arguments.postID} },
            sql = "
                SELECT c.intBlogCategoryID, c.strCategoryName, c.intPrio
                FROM blog_post_categories pc
                INNER JOIN blog_categories c ON pc.intBlogCategoryID = c.intBlogCategoryID
                WHERE pc.intBlogPostID = :postID
                ORDER BY c.intPrio
            "
        );
        local.categories = [];
        for (local.catRow=1; local.catRow <= local.qCats.recordCount; local.catRow++) {
            arrayAppend(local.categories, {
                'id': local.qCats["intBlogCategoryID"][local.catRow],
                'name': local.qCats["strCategoryName"][local.catRow],
                'prio': local.qCats["intPrio"][local.catRow]
            });
        }

        return {
            'id': local.qPost["intBlogPostID"][local.row],
            'title': local.qPost["strPostTitle"][local.row],
            'headerImage': local.qPost["strBlogHeaderImage"][local.row],
            'author': local.qPost["strAuthorName"][local.row],
            'showAuthor': local.qPost["blnShowAuthor"][local.row],
            'published': local.qPost["blnIsPublished"][local.row],
            'publishDate': local.qPost["dtePublishDate"][local.row],
            'showPublishedDate': local.qPost["blnShowPublishedDate"][local.row],
            'showTOC': local.qPost["blnShowTOC"][local.row],
            'intro': local.qPost["strPostIntro"][local.row],
            'content': local.qPost["strPostContent"][local.row],
            'created': local.qPost["dtmCreated"][local.row],
            'updated': local.qPost["dtmUpdated"][local.row],
            'categories': local.categories
        };

    }

    /**
     * Returns an array of all categories (optional for filters, etc.)
     */
    public array function getCategories() {
        local.cats = [];
        local.qCats = queryExecute(
            sql = "SELECT intBlogCategoryID, strCategoryName, intPrio FROM blog_categories ORDER BY intPrio",
            options = {datasource = application.datasource}
        );
        for (local.row=1; local.row <= local.qCats.recordCount; local.row++) {
            arrayAppend(local.cats, {
                'id': local.qCats["intBlogCategoryID"][local.row],
                'name': local.qCats["strCategoryName"][local.row],
                'prio': local.qCats["intPrio"][local.row]
            });
        }
        return local.cats;
    }


    /**
    * Generates a Table of Contents (ToC) from blog content with auto-anchors.
    * @param blogContent HTML content containing H2–H4 headings.
    * @return struct with two keys: modifiedContent, strTOC
    */
    public struct function createBlogTOC(required string blogContent) {

        local.result = {
            'modifiedContent' = arguments.blogContent,
            'toc' = ""
        };

        // Regex to find all h2, h3, h4 tags
        local.re = "<(h[2-4])[^>]*>(.*?)</\1>";
        local.matches = reMatchNoCase(re, arguments.blogContent);
        local.tocItems = [];
        local.index = 0;

        for (local.match in local.matches) {
            local.index++;
            local.tag = reFindNoCase("(h[2-4])", match, 1, true).match[1];
            local.text = reReplace(local.match, "<.*?>(.*?)</.*?>", "\1", "one");
            local.slug = lCase(reReplace(local.text, "[^\w]+", "-", "all"));
            local.anchor = "heading-" & local.index;

            // Replace heading with added ID
            local.headingWithID = "<#local.tag# id=""#local.anchor#"">#local.text#</#local.tag#>";
            local.result['modifiedContent'] = replace(local.result.modifiedContent, local.match, local.headingWithID, "one");

            // Build ToC entry
            arrayAppend(tocItems, {
                'tag': local.tag,
                'text': local.text,
                'anchor': local.anchor
            });
        }

        // Build HTML ToC
        if (arrayLen(tocItems)) {
            local.tocHTML = "<div class=""toc-container""><ul class=""toc-list"">";
            for (local.item in tocItems) {
                local.cls = item.tag;
                local.tocHTML &= '<li class="toc-item #local.cls#"><a href="##' & local.item.anchor & '">' & encodeForHTML(local.item.text) & '</a></li>';
            }
            local.tocHTML &= "</ul></div>";
            local.result['toc'] = local.tocHTML;
        }

        return local.result;
    }

}
