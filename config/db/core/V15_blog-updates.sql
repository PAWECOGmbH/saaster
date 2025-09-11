
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE blog_posts
  DROP INDEX FulltextSearch,
  ADD FULLTEXT INDEX FulltextSearch (
    strPreviewTitle,
    strPreviewText,
    strPostTitle,
    strPostIntro,
    strPostContent
  );

  SET FOREIGN_KEY_CHECKS = 1;