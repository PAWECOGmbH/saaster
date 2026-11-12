component output="false" {
    public string function fromHtml(required string html) {
        local.newline = chr(10);
        local.text = reReplaceNoCase(arguments.html,
            "(?s)<a\b[^>]*href=""([^""]+)""[^>]*>(.*?)</a\s*>",
            "\2 (\1)", "all");
        local.text = reReplaceNoCase(local.text,
            "(?s)<a\b[^>]*href='([^']+)'[^>]*>(.*?)</a\s*>",
            "\2 (\1)", "all");
        local.text = reReplaceNoCase(local.text, "<br\s*/?>", local.newline, "all");
        local.text = reReplaceNoCase(local.text, "</(p|div|h[1-6]|li|tr)\s*>",
            local.newline & local.newline, "all");
        local.text = reReplace(local.text, "<[^>]+>", "", "all");
        local.text = replace(decodeForHTML(local.text), chr(160), " ", "all");
        local.text = reReplace(local.text, "[ \t]+", " ", "all");
        local.text = reReplace(local.text, " *\r?\n *", local.newline, "all");
        return trim(reReplace(local.text, "\n{3,}", local.newline & local.newline, "all"));
    }
}
