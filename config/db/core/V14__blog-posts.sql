SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT IGNORE INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES
    ('sysadmin/blog-posts', 'backend/core/views/sysadmin/blog_posts.cfm', 0, 0, 1),
    ('sysadmin/blog-posts/edit', 'backend/core/views/sysadmin/blog_posts_edit.cfm', 0, 0, 1),
    ('sysadm/blog-posts', 'backend/core/handler/sysadmin/blog_posts.cfm', 0, 0, 1),
    ('sysadmin/blog-posts/categories', 'backend/core/views/sysadmin/blog_posts_categories.cfm', 0, 0, 1);

INSERT IGNORE INTO frontend_mappings (strMapping, strPath, strMetatitle, strMetadescription, strhtmlcodes, blnCreatedByApp)
VALUES ('blog/overview', 'templates/blog/overview.cfm', '', '', '', 0);

CREATE TABLE `blog_categories`  (
  `intBlogCategoryID` int NOT NULL AUTO_INCREMENT,
  `strCategoryName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intPrio` tinyint NOT NULL DEFAULT 1,
  PRIMARY KEY (`intBlogCategoryID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

CREATE TABLE `blog_categories_trans`  (
  `intBlogCategoryTransID` int NOT NULL AUTO_INCREMENT,
  `intBlogCategoryID` int NOT NULL,
  `intLanguageID` int NOT NULL,
  `strCategoryName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intBlogCategoryTransID`) USING BTREE,
  INDEX `_intBlogCategoryID`(`intBlogCategoryID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_bc_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `frn_blog_categories` FOREIGN KEY (`intBlogCategoryID`) REFERENCES `blog_categories` (`intBlogCategoryID`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

CREATE TABLE `blog_post_categories`  (
  `intBlogPostCategoryID` int NOT NULL AUTO_INCREMENT,
  `intBlogPostID` int NOT NULL,
  `intBlogCategoryID` int NOT NULL,
  PRIMARY KEY (`intBlogPostCategoryID`) USING BTREE,
  UNIQUE INDEX `idx_unique`(`intBlogPostID`, `intBlogCategoryID`) USING BTREE,
  INDEX `idx_blogpost`(`intBlogPostID`) USING BTREE,
  INDEX `idx_postcategory`(`intBlogCategoryID`) USING BTREE,
  CONSTRAINT `fk_bpc_categories` FOREIGN KEY (`intBlogCategoryID`) REFERENCES `blog_categories` (`intBlogCategoryID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_bpc_posts` FOREIGN KEY (`intBlogPostID`) REFERENCES `blog_posts` (`intBlogPostID`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

CREATE TABLE `blog_posts`  (
  `intBlogPostID` int NOT NULL AUTO_INCREMENT,
  `dtmCreated` datetime NOT NULL,
  `dtmUpdated` datetime NULL DEFAULT NULL,
  `blnIsPublished` tinyint NOT NULL DEFAULT 0,
  `dtePublishDate` date NULL DEFAULT NULL,
  `dteUnpublishDate` date NULL DEFAULT NULL,
  `blnShowPublishedDate` tinyint NOT NULL DEFAULT 1,
  `blnShowTOC` tinyint NOT NULL DEFAULT 0,
  `strAuthorName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnShowAuthor` tinyint NOT NULL DEFAULT 0,
  `strPreviewTitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strPreviewText` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strPreviewImage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strButtonText` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strBlogHeaderImage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPostTitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPostIntro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strPostContent` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `intFrontendMappingsID` int NULL DEFAULT NULL,
  PRIMARY KEY (`intBlogPostID`) USING BTREE,
  INDEX `idx_dtmCreated`(`dtmCreated`) USING BTREE,
  INDEX `idx_blnIsPublished`(`blnIsPublished`) USING BTREE,
  FULLTEXT INDEX `FulltextSearch`(`strPreviewTitle`, `strPreviewText`, `strButtonText`, `strPostContent`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

CREATE TABLE `blog_posts_trans`  (
  `intBlogPostTransID` int NOT NULL AUTO_INCREMENT,
  `intBlogPostID` int NOT NULL,
  `intLanguageID` int NOT NULL,
  `strPreviewTitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPreviewText` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strButtonText` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPostTitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPostIntro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strPostContent` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intBlogPostTransID`) USING BTREE,
  UNIQUE INDEX `idx_unique_translation`(`intBlogPostID`, `intLanguageID`) USING BTREE,
  INDEX `fk_blogpoststrans_language`(`intLanguageID`) USING BTREE,
  CONSTRAINT `fk_blogpoststrans_blogposts` FOREIGN KEY (`intBlogPostID`) REFERENCES `blog_posts` (`intBlogPostID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_blogpoststrans_language` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;