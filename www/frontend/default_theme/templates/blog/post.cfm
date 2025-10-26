
<cfscript>
	postID = 0;
	isPreview = 0;
	if (structKeyExists(thiscontent, "urlVariables")){
		if (structKeyExists(thiscontent.urlVariables, "id")) {
			postID = thiscontent.urlVariables.id;
		}
	} else {
		location url="#application.mainURL#" addtoken="false";
	}
	if (postID lte 0) {
		location url="#application.mainURL#" addtoken="false";
	}

	if (structKeyExists(url, "preview")) {
		isPreview = 1;
	}

	objBlog = new frontend.core.com.blog();
	post = objBlog.getPostData(postID, isPreview);
	if (structIsEmpty(post)) {
		location url="#application.mainURL#" addtoken="false";
	}

</cfscript>

<cfoutput>
<div class="blog-post-container container py-5">
	<div class="row justify-content-center">
		<div class="col-lg-8">
			<article class="card shadow-sm">
				<img src="#(len(trim(post.headerImage)) ? post.headerImage : 'https://placehold.co/900x400?text=Blog+Image')#" class="card-img-top" alt="#encodeForHtml(post.title)#">
				<div class="card-body">
					<h1 class="blog-post-title card-title mb-3">#encodeForHtml(post.title)#</h1>
					<div class="blog-post-meta mb-3 text-muted small">
						<cfif post.showPublishedDate>
							Published on #dateFormat(post.publishDate ?: post.created, 'dd.mm.yyyy')#<br />
						</cfif>
						<cfif post.showAuthor && len(trim(post.author))>
							Published by #encodeForHtml(post.author)#<br />
						</cfif>
					</div>
					<cfif len(trim(post.intro))>
						<p class="blog-post-intro card-text lead">#encodeForHtml(post.intro)#</p>
					</cfif>
					<cfif len(trim(post.content))>
						<div class="mt-3">
							<div class="blog-post-content" id="blog-content"><cfif post.showTOC>#objBlog.createBlogTOC(post.content).modifiedContent#<cfelse>#post.content#</cfif></div>
						</div>
					</cfif>
				</div>
			</article>
			<div class="mt-4">
				<a href="#application.mainURL#/blog/overview" class="btn btn-outline-secondary">Back to overview</a>
			</div>
		</div>
		<cfif arrayLen(post.categories) or post.showTOC>
			<div class="col-lg-4">
				<div id="sticky-toc">
					<cfif post.showTOC>
						<div class="card mb-4">
							<div class="card-header bg-light fw-bold">Table of Contents</div>
							<div class="card-body p-3">
								#objBlog.createBlogTOC(post.content).toc#
							</div>
						</div>
					</cfif>
					<cfif arrayLen(post.categories)>
						<div class="card mb-4">
							<div class="card-header bg-light fw-bold">Categories</div>
							<div class="card-body p-3">
								<cfloop array="#post.categories#" index="cat">
									<a href="#application.mainURL#/blog/overview?catID=#cat.id#" class="badge bg-light text-dark border">#encodeForHtml(cat.name)#</a>
								</cfloop>
							</div>
						</div>
					</cfif>
				</div>
			</div>
		</cfif>
	</div>
</div>
</cfoutput>
