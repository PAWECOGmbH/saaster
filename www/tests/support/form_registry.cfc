component output="false" hint="The collection of every form and every action link in the Saaster core, with what each one does." {

    /*
        This is the registry behind specs/integration/form_registry_spec.cfc.

        The spec scans all core views and both frontend themes and compares what it
        finds with this list - in both directions. A new form or action link that is
        not listed here turns the run red, and so does an entry here that no longer
        exists. Adding a form therefore means deciding consciously what it is:

          handlerForms()   POST forms that change data. They post to a core handler,
                           the CSRF check covers them, and the handler reacts to the
                           listed trigger field (its top-level structKeyExists check).
          viewForms()      POST forms that only search, sort, filter or navigate.
                           They post to a view, outside the CSRF check, and may only
                           contain the read-only fields listed in readOnlyFields().
          inertForms()     <form> tags that are never submitted (layout wrappers).
          protectedLinks() GET links that trigger a handler action and carry a CSRF token.
          openLinks()      GET links that trigger a handler action WITHOUT a token,
                           each with the reason. "gap" marks a real state change that
                           still needs protection; the spec lists these as skipped.

        Paths are relative to www/. Targets are the mapping as used in the action/href,
        without #application.mainURL#. Triggers are "form.<field>" or "url.<key>".
    */

    public array function handlerForms() {
        return [

            // ---------- Customer: company, profile, users, tenants ----------
            { file: "backend/core/views/customer/company-edit.cfm", target: "customer", trigger: "form.logo_upload_btn", purpose: "Upload the company logo" },
            { file: "backend/core/views/customer/company-edit.cfm", target: "customer", trigger: "form.edit_company_btn", purpose: "Save company details and invoice settings" },
            { file: "backend/core/views/customer/company-edit.cfm", target: "cancel", trigger: "form.delete", purpose: "Delete the whole account (asks for e-mail and password)" },
            { file: "backend/core/views/customer/my-profile.cfm", target: "user", trigger: "form.photo_upload_btn", purpose: "Upload the own profile photo" },
            { file: "backend/core/views/customer/my-profile.cfm", target: "user", trigger: "form.edit_profile_btn", purpose: "Save the own profile" },
            { file: "backend/core/views/customer/reset-password.cfm", target: "user", trigger: "form.change_pw_btn", purpose: "Change the own password" },
            { file: "backend/core/views/customer/user_new.cfm", target: "user", trigger: "form.user_new_btn", purpose: "Create a new user" },
            { file: "backend/core/views/customer/user_edit.cfm", target: "user", trigger: "form.edit_profile_btn", purpose: "Edit another user of the tenant (roles, tenant access)" },
            { file: "backend/core/views/customer/tenant_new.cfm", target: "customer", trigger: "form.new_tenant_btn", purpose: "Create a new tenant" },

            // ---------- Dashboard and notifications ----------
            { file: "backend/core/views/dashboard.cfm", target: "dashboard-settings", trigger: "form.dashboardedit", purpose: "Switch the dashboard edit mode" },
            { file: "backend/core/views/notifications/overview.cfm", target: "global", trigger: "form.noti_action", purpose: "Bulk action on notifications (read, delete)" },

            // ---------- Frontend: login, MFA, password reset, registration (both themes) ----------
            { file: "frontend/default_theme/templates/forms/login.cfm", target: "logincheck", trigger: "form.login_btn", purpose: "Log in" },
            { file: "frontend/default_theme/templates/forms/mfa.cfm", target: "logincheck", trigger: "form.mfa_btn", purpose: "Confirm the MFA code" },
            { file: "frontend/default_theme/templates/forms/password_1.cfm", target: "logincheck", trigger: "form.reset_pw_btn_1", purpose: "Request a password reset link" },
            { file: "frontend/default_theme/templates/forms/password_2.cfm", target: "logincheck", trigger: "form.reset_pw_btn_2", purpose: "Set a new password from the reset link" },
            { file: "frontend/default_theme/templates/forms/register_1.cfm", target: "logincheck", trigger: "form.register_btn", purpose: "Registration step 1: name, company, e-mail" },
            { file: "frontend/default_theme/templates/forms/register_2.cfm", target: "logincheck", trigger: "form.create_account", purpose: "Registration step 2: choose a password" },
            { file: "frontend/default_theme/templates/forms/register_3.cfm", target: "logincheck", trigger: "form.fill_remaining_data", purpose: "Registration step 3: address and timezone" },
            { file: "frontend/custom_theme/templates/forms/login.cfm", target: "logincheck", trigger: "form.login_btn", purpose: "Log in (custom theme)" },
            { file: "frontend/custom_theme/templates/forms/mfa.cfm", target: "logincheck", trigger: "form.mfa_btn", purpose: "Confirm the MFA code (custom theme)" },
            { file: "frontend/custom_theme/templates/forms/password_1.cfm", target: "logincheck", trigger: "form.reset_pw_btn_1", purpose: "Request a password reset link (custom theme)" },
            { file: "frontend/custom_theme/templates/forms/password_2.cfm", target: "logincheck", trigger: "form.reset_pw_btn_2", purpose: "Set a new password (custom theme)" },
            { file: "frontend/custom_theme/templates/forms/register_1.cfm", target: "logincheck", trigger: "form.register_btn", purpose: "Registration step 1 (custom theme)" },
            { file: "frontend/custom_theme/templates/forms/register_2.cfm", target: "logincheck", trigger: "form.create_account", purpose: "Registration step 2 (custom theme)" },
            { file: "frontend/custom_theme/templates/forms/register_3.cfm", target: "logincheck", trigger: "form.fill_remaining_data", purpose: "Registration step 3 (custom theme)" },

            // ---------- Sysadmin: customers ----------
            { file: "backend/core/views/sysadmin/customers.cfm", target: "sysadm/customers", trigger: "form.add_customer", purpose: "Create a customer with its first user" },
            { file: "backend/core/views/sysadmin/customers_edit.cfm", target: "sysadm/customers", trigger: "form.edit_company_btn", purpose: "Edit the company data of a customer" },
            { file: "backend/core/views/sysadmin/customers_details.cfm", target: "sysadm/customers", trigger: "form.edit_user,form.delete_user", purpose: "Edit or delete a user of a customer (two submit buttons)" },
            { file: "backend/core/views/sysadmin/customers_details.cfm", target: "sysadm/invoices", trigger: "form.new_invoice", purpose: "Create an invoice for a customer" },
            { file: "backend/core/views/sysadmin/ajax_period.cfm", target: "sysadm/##type##", resolvesTo: ["sysadm/plans", "sysadm/modules"], trigger: "url.booking", purpose: "Change the period of a plan or module booking" },

            // ---------- Sysadmin: invoices ----------
            { file: "backend/core/views/sysadmin/invoices.cfm", target: "sysadm/invoices", trigger: "form.new_invoice", purpose: "Create an invoice" },
            { file: "backend/core/views/sysadmin/invoice_edit.cfm", target: "sysadm/invoices", trigger: "form.new_position", purpose: "Add an invoice position" },
            { file: "backend/core/views/sysadmin/invoice_edit.cfm", target: "sysadm/invoices", trigger: "form.edit_position", purpose: "Edit an invoice position" },
            { file: "backend/core/views/sysadmin/invoice_edit.cfm", target: "sysadm/invoices", trigger: "form.settings", purpose: "Save the invoice settings (title, dates, currency, VAT type)" },
            { file: "backend/core/views/sysadmin/ajax_payments.cfm", target: "sysadm/invoices", trigger: "form.payments", purpose: "Record a payment on an invoice" },

            // ---------- Sysadmin: plans ----------
            { file: "backend/core/views/sysadmin/plans.cfm", target: "sysadm/plans", trigger: "form.new_plan", purpose: "Create a plan" },
            { file: "backend/core/views/sysadmin/plans.cfm", target: "sysadm/plans", trigger: "url.default", purpose: "Set the default plan of a plan group" },
            { file: "backend/core/views/sysadmin/plan_details.cfm", target: "sysadm/plans", trigger: "form.edit_plan", purpose: "Edit a plan" },
            { file: "backend/core/views/sysadmin/plan_prices.cfm", target: "sysadm/plans", trigger: "form.edit_prices", purpose: "Edit the prices of a plan" },
            { file: "backend/core/views/sysadmin/plan_modules.cfm", target: "sysadm/plans", trigger: "form.plan_modules", purpose: "Assign modules to a plan" },
            { file: "backend/core/views/sysadmin/plan_feat.cfm", target: "sysadm/plans", trigger: "form.edit_features", purpose: "Assign features to a plan" },
            { file: "backend/core/views/sysadmin/plan_features.cfm", target: "sysadm/plans", trigger: "form.new_feature", purpose: "Create a plan feature" },
            { file: "backend/core/views/sysadmin/plan_features.cfm", target: "sysadm/plans", trigger: "form.edit_feature", purpose: "Edit a plan feature" },
            { file: "backend/core/views/sysadmin/plan_groups.cfm", target: "sysadm/plans", trigger: "form.new_group", purpose: "Create a plan group" },
            { file: "backend/core/views/sysadmin/plan_groups.cfm", target: "sysadm/plans", trigger: "form.edit_plangroup", purpose: "Edit a plan group" },

            // ---------- Sysadmin: modules ----------
            { file: "backend/core/views/sysadmin/modules.cfm", target: "sysadm/modules", trigger: "form.new_module", purpose: "Create a module" },
            { file: "backend/core/views/sysadmin/module_details.cfm", target: "sysadm/modules", trigger: "form.edit_module", purpose: "Edit a module" },
            { file: "backend/core/views/sysadmin/module_prices.cfm", target: "sysadm/modules", trigger: "form.edit_prices", purpose: "Edit the prices of a module" },
            { file: "backend/core/views/sysadmin/module_scheduletasks.cfm", target: "sysadm/modules", trigger: "form.new_scheduletask", purpose: "Create a schedule task of a module" },
            { file: "backend/core/views/sysadmin/module_scheduletasks.cfm", target: "sysadm/modules", trigger: "form.edit_scheduletask", purpose: "Switch a schedule task on or off" },
            { file: "backend/core/views/sysadmin/ajax_scheduletasks.cfm", target: "sysadm/modules", trigger: "form.edit_scheduletask", purpose: "Edit a schedule task (modal)" },

            // ---------- Sysadmin: widgets and blog ----------
            { file: "backend/core/views/sysadmin/widgets.cfm", target: "sysadm/widgets", trigger: "form.new_widget", purpose: "Create a widget" },
            { file: "backend/core/views/sysadmin/widgets.cfm", target: "sysadm/widgets", trigger: "form.edit_widget", purpose: "Edit a widget" },
            { file: "backend/core/views/sysadmin/blog_posts.cfm", target: "sysadm/blog-posts", trigger: "form.post_new", purpose: "Create a blog post" },
            { file: "backend/core/views/sysadmin/blog_posts_edit.cfm", target: "sysadm/blog-posts", trigger: "form.postid", purpose: "Save a blog post" },
            { file: "backend/core/views/sysadmin/blog_posts_categories.cfm", target: "sysadm/blog-posts", trigger: "form.new_category", purpose: "Create a blog category" },
            { file: "backend/core/views/sysadmin/blog_posts_categories.cfm", target: "sysadm/blog-posts", trigger: "form.edit_category", purpose: "Edit a blog category" },

            // ---------- Sysadmin: system ----------
            { file: "backend/core/views/sysadmin/system_settings.cfm", target: "sysadm/settings", trigger: "form.edit_sysadmin_settings", purpose: "Save the system settings" },
            { file: "backend/core/views/sysadmin/api_settings.cfm", target: "sysadm/api-settings", trigger: "form.new_api", purpose: "Create an API key" },
            { file: "backend/core/views/sysadmin/languages.cfm", target: "sysadm/languages", trigger: "form.new_language", purpose: "Add a language" },
            { file: "backend/core/views/sysadmin/languages.cfm", target: "sysadm/languages", trigger: "form.edit_language", purpose: "Edit a language" },
            { file: "backend/core/views/sysadmin/currencies.cfm", target: "sysadm/currencies", trigger: "form.new_currency", purpose: "Add a currency" },
            { file: "backend/core/views/sysadmin/currencies.cfm", target: "sysadm/currencies", trigger: "form.edit_currency", purpose: "Edit a currency" },
            { file: "backend/core/views/sysadmin/countries.cfm", target: "sysadm/countries", trigger: "form.new_country", purpose: "Add a country" },
            { file: "backend/core/views/sysadmin/ajax_country.cfm", target: "sysadm/countries", trigger: "form.edit_country", purpose: "Edit a country (modal)" },
            { file: "backend/core/views/sysadmin/country_import.cfm", target: "sysadm/countries", trigger: "form.import_country", purpose: "Import a country from the inactive list" },
            { file: "backend/core/views/sysadmin/mappings.cfm", target: "sysadm/mappings", trigger: "form.new_mapping", purpose: "Create a custom mapping" },
            { file: "backend/core/views/sysadmin/mappings.cfm", target: "sysadm/mappings", trigger: "form.edit_mapping", purpose: "Edit or delete a custom mapping" },
            { file: "backend/core/views/sysadmin/mappings.cfm", target: "sysadm/mappings", trigger: "form.new_mapping_frontend", purpose: "Create a frontend mapping" },
            { file: "backend/core/views/sysadmin/mapping_edit.cfm", target: "sysadm/mappings", trigger: "form.edit_mapping_frontend", purpose: "Edit a frontend mapping (meta data, HTML codes)" },
            { file: "backend/core/views/sysadmin/translations.cfm", target: "sysadm/translations", trigger: "form.new_variable", purpose: "Create a custom translation" },
            { file: "backend/core/views/sysadmin/translations.cfm", target: "sysadm/translations", trigger: "form.edit_variable", purpose: "Edit a custom translation" },
            { file: "backend/core/views/sysadmin/translations.cfm", target: "sysadm/translations", trigger: "form.edit_syst_variable", purpose: "Edit a system translation" },
            { file: "backend/core/views/sysadmin/translations.cfm", target: "sysadm/translations", trigger: "form.bulk_translate", purpose: "Translate missing texts with an AI provider" },
            { file: "backend/core/views/sysadmin/logs.cfm", target: "sysadm/logs", trigger: "form.log_action", purpose: "Bulk action on log files (delete)" }

        ];
    }

    public array function viewForms() {
        return [
            { file: "backend/core/views/sysadmin/customers.cfm", target: "sysadmin/customers", trigger: "form.search", purpose: "Search and sort customers" },
            { file: "backend/core/views/sysadmin/invoices.cfm", target: "sysadmin/invoices", trigger: "form.search", purpose: "Search, sort and filter invoices by status" },
            { file: "backend/core/views/sysadmin/blog_posts.cfm", target: "sysadmin/blog-posts", trigger: "form.search", purpose: "Search and sort blog posts" },
            { file: "backend/core/views/sysadmin/countries.cfm", target: "sysadmin/countries", trigger: "form.search", purpose: "Search and sort countries" },
            { file: "backend/core/views/sysadmin/country_import.cfm", target: "sysadmin/countries/import", trigger: "form.search", purpose: "Search and sort importable countries" },
            { file: "backend/core/views/sysadmin/logs.cfm", target: "sysadmin/logs", trigger: "form.log_type", purpose: "Filter log files by type, level and date" },
            { file: "backend/core/views/sysadmin/mappings.cfm", target: "sysadmin/mapping/edit", trigger: "form.mappingid", purpose: "Open a frontend mapping for editing" },
            { file: "backend/core/views/sysadmin/translations.cfm", target: "sysadmin/translations", trigger: "form.search", count: 2, purpose: "Search custom and system translations" },
            { file: "backend/core/views/sysadmin/translations.cfm", target: "sysadmin/translations", trigger: "form.displaylanguage", count: 2, purpose: "Choose the display language of the translation lists" }
        ];
    }

    // The only fields a form posting to a view may contain. Anything else could change data
    // and belongs into a handler, behind the CSRF check.
    public array function readOnlyFields() {
        return ["search", "delete", "sort", "status", "log_type", "log_level", "log_date", "mappingid", "displaylanguage"];
    }

    public array function inertForms() {
        return [
            { file: "frontend/default_theme/templates/modals/privacy.cfm", target: "step3.cfm", purpose: "Layout wrapper of the privacy policy modal - no fields, never submitted" },
            { file: "frontend/custom_theme/templates/modals/privacy.cfm", target: "step3.cfm", purpose: "Layout wrapper of the privacy policy modal (custom theme)" }
        ];
    }

    public array function protectedLinks() {
        return [
            { file: "backend/core/views/customer/account-settings.cfm", target: "cancel", key: "url.plan", purpose: "Cancel the plan or revoke the cancellation" },
            { file: "backend/core/views/customer/plans.cfm", target: "cancel", key: "url.plan", purpose: "Cancel the plan" },
            { file: "backend/core/views/plan_view.cfm", target: "cancel", key: "url.plan", purpose: "Remove a waiting plan" },
            { file: "backend/core/views/customer/modules.cfm", target: "cancel", key: "url.module", purpose: "Cancel a module or revoke the cancellation" },
            { file: "backend/core/views/customer/company-edit.cfm", target: "customer", key: "url.del_logo", purpose: "Delete the company logo" },
            { file: "backend/core/views/customer/tenants.cfm", target: "customer", key: "url.delete", purpose: "Delete a tenant" },
            { file: "backend/core/views/customer/my-profile.cfm", target: "user", key: "url.del_photo", purpose: "Delete the own profile photo" },
            { file: "backend/core/views/customer/users.cfm", target: "user", key: "url.delete", purpose: "Delete a user" },
            { file: "backend/core/views/customer/users.cfm", target: "user", key: "url.invit", purpose: "Send the activation link to a user again" },
            { file: "backend/core/views/notifications/overview.cfm", target: "global", key: "url.noti_del", purpose: "Delete a notification" },
            { file: "backend/core/views/sysadmin/blog_posts_categories.cfm", target: "sysadm/blog-posts", key: "url.delete_category", purpose: "Delete a blog category" },
            { file: "backend/core/views/sysadmin/blog_posts_edit.cfm", target: "sysadm/blog-posts", key: "url.delete_post", purpose: "Delete a blog post" },
            { file: "backend/core/views/sysadmin/blog_posts_edit.cfm", target: "sysadm/blog-posts", key: "url.delete_image", purpose: "Delete the preview image of a blog post" },
            { file: "backend/core/views/sysadmin/blog_posts_edit.cfm", target: "sysadm/blog-posts", key: "url.delete_header_image", purpose: "Delete the header image of a blog post" },
            { file: "backend/core/views/sysadmin/countries.cfm", target: "sysadm/countries", key: "url.remove_country", purpose: "Deactivate a country" },
            { file: "backend/core/views/sysadmin/country_import.cfm", target: "sysadm/countries", key: "url.delete_country", purpose: "Delete a country" },
            { file: "backend/core/views/sysadmin/invoice_edit.cfm", target: "sysadm/invoices", key: "url.delete_pos", purpose: "Delete an invoice position" },
            { file: "backend/core/views/sysadmin/languages.cfm", target: "sysadm/languages", key: "url.delete_language", purpose: "Delete a language" },
            { file: "backend/core/views/sysadmin/currencies.cfm", target: "sysadm/currencies", key: "url.delete_currency", purpose: "Delete a currency" },
            { file: "backend/core/views/sysadmin/api_settings.cfm", target: "sysadm/api-settings", key: "url.deleteapi", purpose: "Delete an API key" },
            { file: "backend/core/views/sysadmin/modules.cfm", target: "sysadm/modules", key: "url.delete_module", purpose: "Delete a module" },
            { file: "backend/core/views/sysadmin/module_details.cfm", target: "sysadm/modules", key: "url.delete_pic", purpose: "Delete the picture of a module" },
            { file: "backend/core/views/sysadmin/module_scheduletasks.cfm", target: "sysadm/modules", key: "url.delete_scheduletask", purpose: "Delete a schedule task" },
            { file: "backend/core/views/sysadmin/plans.cfm", target: "sysadm/plans", key: "url.delete_plan", purpose: "Delete a plan" },
            { file: "backend/core/views/sysadmin/plan_features.cfm", target: "sysadm/plans", key: "url.delete_feature", purpose: "Delete a plan feature" },
            { file: "backend/core/views/sysadmin/plan_groups.cfm", target: "sysadm/plans", key: "url.delete_group", purpose: "Delete a plan group" },
            { file: "backend/core/views/sysadmin/translations.cfm", target: "sysadm/translations", key: "url.delete_trans", purpose: "Delete a custom translation" },
            { file: "backend/core/views/sysadmin/widgets.cfm", target: "sysadm/widgets", key: "url.delete_widget", purpose: "Delete a widget" },

            // Protected per handler (global.cfc variables.csrfProtectedGetKeys) - the key names are too generic for a global rule.
            { file: "backend/core/views/customer/payment.cfm", target: "payment-settings", key: "url.del", purpose: "Delete a payment method" },
            { file: "backend/core/views/customer/payment.cfm", target: "payment-settings", key: "url.default", purpose: "Set the default payment method" },
            { file: "backend/core/views/sysadmin/customers_details.cfm", target: "sysadm/plans", key: "url.booking", purpose: "Book, change, cancel, revoke or delete a plan booking of a customer" },
            { file: "backend/core/views/sysadmin/customers_details.cfm", target: "sysadm/modules", key: "url.booking", purpose: "Book, change, cancel, revoke or delete a module booking of a customer" },
            { file: "backend/core/views/sysadmin/customers_details.cfm", target: "sysadm/invoices", key: "url.status", purpose: "Cancel or delete an invoice" },
            { file: "backend/core/views/sysadmin/customers_details.cfm", target: "sysadm/invoices", key: "url.email", purpose: "Send an invoice by e-mail" },
            { file: "backend/core/views/sysadmin/invoices.cfm", target: "sysadm/invoices", key: "url.status", purpose: "Cancel or delete an invoice" },
            { file: "backend/core/views/sysadmin/invoices.cfm", target: "sysadm/invoices", key: "url.email", purpose: "Send an invoice by e-mail" },
            { file: "backend/core/views/sysadmin/invoices.cfm", target: "sysadm/invoices", key: "url.open", purpose: "Set an invoice to open" },
            { file: "backend/core/views/sysadmin/invoice_edit.cfm", target: "sysadm/invoices", key: "url.status", purpose: "Set an invoice back to draft" },
            { file: "backend/core/views/sysadmin/invoice_edit.cfm", target: "sysadm/invoices", key: "url.email", purpose: "Send an invoice by e-mail" },
            { file: "backend/core/views/sysadmin/invoice_edit.cfm", target: "sysadm/invoices", key: "url.open", purpose: "Set an invoice to open" },
            { file: "backend/core/views/sysadmin/logs.cfm", target: "sysadm/logs", key: "url.logfile", purpose: "Delete a log file" }
        ];
    }

    /*
        Action links without a CSRF token.

        reason "session": only changes the own session (tenant switch, logout).
        reason "entry":   an entry point that cannot carry a token or only starts an
                          external flow (MFA resend, Payrexx checkout and return).
        reason "gap":     a real state change that still needs protection. The spec
                          lists these as skipped (label csrf-gap). Currently none.
    */
    public array function openLinks() {
        return [
            { file: "backend/core/views/customer/tenants.cfm", target: "customer", key: "url.change_tenant", reason: "session", purpose: "Switch to another tenant from the tenant list" },
            { file: "backend/core/views/customer/tenants.cfm", target: "global", key: "url.switch", reason: "session", purpose: "Switch the active tenant" },
            { file: "backend/core/views/tenant_changer.cfm", target: "global", key: "url.switch", reason: "session", purpose: "Switch the active tenant (header dropdown)" },
            { file: "backend/core/views/navigationVertical.cfm", target: "global", key: "url.switch", reason: "session", purpose: "Switch the active tenant (vertical navigation)" },
            { file: "backend/core/views/navigationCombined.cfm", target: "global", key: "url.switch", reason: "session", purpose: "Switch the active tenant (combined navigation)" },
            { file: "backend/core/views/header.cfm", target: "customer", key: "url.sysadmin", reason: "session", purpose: "Return from a support login to the own sysadmin session" },
            { file: "backend/core/views/header.cfm", target: "logincheck", key: "url.logout", reason: "session", purpose: "Log out" },
            { file: "backend/core/views/sysadmin/customers.cfm", target: "sysadm/customers", key: "url.logincustomer", reason: "session", purpose: "Log in as a customer for support (sysadmin only)" },

            { file: "frontend/default_theme/templates/forms/mfa.cfm", target: "logincheck", key: "url.resend", reason: "entry", purpose: "Send a new MFA code" },
            { file: "frontend/custom_theme/templates/forms/mfa.cfm", target: "logincheck", key: "url.resend", reason: "entry", purpose: "Send a new MFA code (custom theme)" },
            { file: "backend/core/views/customer/payment.cfm", target: "payment-settings", key: "url.add", reason: "entry", purpose: "Start adding a payment method at Payrexx" },
            { file: "backend/core/views/invoices/invoice.cfm", target: "payment-settings", key: "url.pay", reason: "entry", purpose: "Start paying an invoice at Payrexx" },
            { file: "backend/core/views/payment.cfm", target: "book", key: "url.plan", reason: "entry", purpose: "Return link Payrexx calls after booking a plan" },
            { file: "backend/core/views/payment.cfm", target: "book", key: "url.module", reason: "entry", purpose: "Return link Payrexx calls after booking a module" }
        ];
    }

}
