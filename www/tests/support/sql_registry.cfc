component output="false" hint="Every value that is written into SQL directly (not bound as a parameter), with the reason why it is safe." {

    /*
        The registry behind specs/integration/sql_registry_spec.cfc.

        Values from requests belong into bound parameters (params / cfqueryparam).
        Some things cannot be bound: table and column names, ORDER BY clauses,
        LIMIT values in some places, or fixed SQL fragments. Each such place is
        listed here with the reason why the value cannot carry user input.

        The spec scans the SQL of all core components, handlers and views. A new
        interpolation that is not listed turns the run red - it must be reviewed
        and either replaced by a bound parameter or added here with a reason.
    */

    public array function entries() {
        return [

            // ---------- backend/core/com ----------
            { file: "backend/core/com/blog.cfc", expression: "arguments.sort", reason: "Checked against a whitelist with safeOrderBy()" },
            { file: "backend/core/com/blog.cfc", expression: "arguments.start", reason: "Numeric argument (typed)" },
            { file: "backend/core/com/blog.cfc", expression: "local.entries", reason: "Constant page size" },
            { file: "backend/core/com/book.cfc", expression: "local.sql_field", reason: "Fixed condition; the module ID comes from the database" },
            { file: "backend/core/com/cancel.cfc", expression: "variables.sqlField", reason: "Column name chosen in code (intPlanID or intModuleID)" },
            { file: "backend/core/com/cancel.cfc", expression: "variables.what", reason: "Constant 'plan' or 'module' passed by code" },
            { file: "backend/core/com/global.cfc", expression: "arguments.tableName", reason: "Table name passed by code as a constant" },
            { file: "backend/core/com/global.cfc", expression: "getPrimaryKey(arguments.tableName)", reason: "Primary key read from the database schema" },
            { file: "backend/core/com/global.cfc", expression: "local.sqlWhereString", reason: "Condition passed by code as a constant" },
            { file: "backend/core/com/invoices.cfc", expression: "local.queryLimit", reason: "Built from numeric arguments" },
            { file: "backend/core/com/invoices.cfc", expression: "local.queryOrder", reason: "Order passed by code as a constant" },
            { file: "backend/core/com/language.cfc", expression: "arguments.whereFilter", reason: "Condition passed by code as a constant" },
            { file: "backend/core/com/language.cfc", expression: "local.langIso", reason: "Language code read from the languages table" },
            { file: "backend/core/com/mappings.cfc", expression: "local.whereStatement", reason: "Built from a numeric argument" },
            { file: "backend/core/com/modules.cfc", expression: "local.exceptList", reason: "Module IDs read from the database (booked modules)" },
            { file: "backend/core/com/notifications.cfc", expression: "local.queryLimit", reason: "Built from numeric arguments" },
            { file: "backend/core/com/notifications.cfc", expression: "local.queryWhere", reason: "Fixed condition" },
            { file: "backend/core/com/payrexx.cfc", expression: "local.sql_default", reason: "Built from a boolean argument (checked with isBoolean)" },
            { file: "backend/core/com/payrexx.cfc", expression: "local.sql_failed", reason: "Fixed condition" },
            { file: "backend/core/com/payrexx.cfc", expression: "local.sql_gateway", reason: "Fixed condition with a bound parameter" },
            { file: "backend/core/com/plans.cfc", expression: "local.whereQuery", reason: "Built from a numeric argument" },
            { file: "backend/core/com/settings.cfc", expression: "arguments.sqlTable", reason: "Must match an existing table in information_schema first" },
            { file: "backend/core/com/sysadmin.cfc", expression: "arguments.sort", reason: "Checked against a whitelist with safeOrderBy()" },
            { file: "backend/core/com/sysadmin.cfc", expression: "arguments.start", reason: "Numeric argument (typed)" },
            { file: "backend/core/com/sysadmin.cfc", expression: "arguments.status", reason: "Built by views/sysadmin/invoices.cfm from form.status, cast to a whole number" },
            { file: "backend/core/com/sysadmin.cfc", expression: "local.entries", reason: "Constant page size" },
            { file: "backend/core/com/sysadmin.cfc", expression: "local.orList", reason: "Column names from the languages table; the search value is bound" },
            { file: "backend/core/com/sysadmin.cfc", expression: "local.orderClause", reason: "Chosen in code for whitelisted sort values" },
            { file: "backend/core/com/widget.cfc", expression: "local.widgetFilter", reason: "Fixed condition with a bound parameter" },
            { file: "backend/core/com/translate.cfc", expression: "arguments.field", reason: "Checked with isKnownColumn() against the database schema" },
            { file: "backend/core/com/translate.cfc", expression: "arguments.key", reason: "Checked with isKnownColumn() against the database schema" },
            { file: "backend/core/com/translate.cfc", expression: "arguments.transTable", reason: "Checked with isKnownColumn() against the database schema" },
            { file: "backend/core/com/user.cfc", expression: "arguments.columns", reason: "Column list passed by code as a constant" },
            { file: "backend/core/com/user.cfc", expression: "local.tenantID", reason: "Filtered to whole numbers in updateUser()" },

            // ---------- backend/core/handler ----------
            { file: "backend/core/handler/ajax_sort.cfm", expression: "thisPrimKey", reason: "Primary key read from the database schema" },
            { file: "backend/core/handler/ajax_sort.cfm", expression: "thisTable", reason: "Chosen in code from a fixed list of tables" },
            { file: "backend/core/handler/sysadmin/languages.cfm", expression: "ucase(form.iso)", reason: "Validated as exactly two letters before" },
            { file: "backend/core/handler/sysadmin/languages.cfm", expression: "ucase(qLanguage.strLanguageISO)", reason: "Language code read from the database" },
            { file: "backend/core/handler/sysadmin/modules.cfm", expression: "updateSQL", reason: "Fixed SQL fragment" },
            { file: "backend/core/handler/sysadmin/translations.cfm", expression: "allTables.table_name", reason: "Table names read from information_schema" },
            { file: "backend/core/handler/sysadmin/translations.cfm", expression: "form.fromLang", reason: "Validated as exactly two letters before" },
            { file: "backend/core/handler/sysadmin/translations.cfm", expression: "form.toLang", reason: "Validated as exactly two letters before" },
            { file: "backend/core/handler/sysadmin/translations.cfm", expression: "getLngId.intLanguageID", reason: "ID read from the database" },
            { file: "backend/core/handler/sysadmin/translations.cfm", expression: "rowNames", reason: "Column names read with DESCRIBE" },

            // ---------- frontend/core ----------
            { file: "frontend/core/com/blog.cfc", expression: "arguments.limit", reason: "Numeric argument (typed)" },
            { file: "frontend/core/com/blog.cfc", expression: "arguments.sort", reason: "Checked against a whitelist with safeOrderBy()" },
            { file: "frontend/core/com/blog.cfc", expression: "arguments.start", reason: "Numeric argument (typed)" },
            { file: "frontend/core/com/blog.cfc", expression: "local.categoryJoin", reason: "Fixed join with a bound parameter" },
            { file: "frontend/core/com/blog.cfc", expression: "local.published", reason: "Fixed condition" }

        ];
    }

}
