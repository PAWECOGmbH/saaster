SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES
    ('sysadmin/blog-posts', 'backend/core/views/sysadmin/blog_posts.cfm', 0, 0, 1),
    ('sysadmin/blog-posts/edit', 'backend/core/views/sysadmin/blog_posts_edit.cfm', 0, 0, 1),
    ('sysadm/blog-posts', 'backend/core/handler/sysadmin/blog_posts.cfm', 0, 0, 1),
    ('sysadmin/blog-posts/categories', 'backend/core/views/sysadmin/blog_posts_categories.cfm', 0, 0, 1);

INSERT INTO frontend_mappings (strMapping, strPath, strMetatitle, strMetadescription, strhtmlcodes, blnCreatedByApp)
VALUES ('blog/overview', 'templates/blog/overview.cfm', '', '', '', 0);

SET FOREIGN_KEY_CHECKS = 1;