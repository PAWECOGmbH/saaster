
<cfscript>

    catID = 0;
    if (structKeyExists(url, "catID") and isNumeric(url.catID)) {
        catID = url.catID;
    }

    blogComp = new frontend.core.com.blog();
    posts = blogComp.getOverviewPosts(category=catID);
    allCategories = blogComp.getCategories();

</cfscript>
<cfoutput>
<div class="blog-overview-container container py-5">
    <h1 class="mb-4 text-center">Blog Overview</h1>
    <div class="mb-4 text-center">
        <span class="me-2">Filter by category:</span>
        <cfif catID gt 0>
            <a href="#application.mainURL#/blog/overview" class="badge bg-primary text-light me-1">All</a>
        <cfelse>
            <a href="#application.mainURL#/blog/overview" class="badge bg-primary text-light me-1 border border-dark">All</a>
        </cfif>
        <cfloop array="#allCategories#" index="cat">
            <cfif catID eq cat.id>
                <a href="#application.mainURL#/blog/overview?catID=#cat.id#" class="badge bg-light text-dark border me-1 border border-dark">#encodeForHtml(cat.name)#</a>
            <cfelse>
                <a href="#application.mainURL#/blog/overview?catID=#cat.id#" class="badge bg-light text-dark border me-1">#encodeForHtml(cat.name)#</a>
            </cfif>
        </cfloop>
    </div>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        <cfloop array="#posts#" index="post">
            <div class="col">
                <div class="blog-card card h-100 shadow-sm">
                    <img src="#(len(trim(post.previewImage)) ? post.previewImage : 'https://placehold.co/600x300?text=Blog+Image')#" class="blog-image card-img-top" alt="#encodeForHtml(post.title)#">
                    <div class="card-body d-flex flex-column mb-3">
                        <h5 class="blog-card-title card-title">#encodeForHtml(post.previewTitle ?: post.title)#</h5>
                        <p class="blog-card-text card-text">#encodeForHtml(post.previewText)#</p>
                        <a href="#application.mainURL#/#post.mapping#" class="btn btn-primary mt-auto">#post.buttonText#</a>
                    </div>
                    <div class="blog-card-footer card-footer text-muted small">
                        Published on #dateFormat(post.publishDate ?: post.created, 'dd.mm.yyyy')#
                        <cfif post.showAuthor and len(trim(post.author))>
                            by <span class="fw-bold">#encodeForHtml(post.author)#</span>
                        </cfif>
                        <cfif arrayLen(post.categories)>
                            <div class="mt-2">
                                <span class="badge bg-secondary me-1">Categories:</span>
                                <cfloop array="#post.categories#" index="cat">
                                    <a href="#application.mainURL#/blog/overview?catID=#cat.id#" class="badge bg-light text-dark border">#encodeForHtml(cat.name)#</a>
                                </cfloop>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </cfloop>
    </div>
</div>
</cfoutput>