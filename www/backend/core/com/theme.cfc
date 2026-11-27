component displayname="theme" output="false" hint="Sysadmin theme settings, applied through Tabler's own theme attributes." {

    /*
        Tabler stays unchanged (CDN). Its tabler-themes.css reacts to data attributes on <html>
        (primary color, gray tone, corner radius, font) and tabler.css to data-bs-navbar-theme.
        A custom primary color only overrides the documented --tblr-primary tokens; Tabler
        derives hover, light variants, focus rings and links from them. Light primary colors
        also get dark text (--tblr-primary-fg), darker links and the navigation colors of the layout.

        The two optional accent colors (corporate design) are Saaster tokens: --saaster-accent and
        --saaster-accent-2 with -fg, -text and -lt variants (defaults and classes in backend.css).
        They highlight, the primary color stays responsible for everything clickable.

        The choice values below are those attribute values. Check them when updating Tabler.
    */

    variables.defaults = {
        "settingThemePrimary": "blue",
        "settingColorPrimary": "##206bc4",
        "settingThemeAccent": "none",
        "settingColorAccent": "##f76707",
        "settingThemeAccent2": "none",
        "settingColorAccent2": "##0ca678",
        "settingThemeNavbar": "default",
        "settingThemeBase": "neutral",
        "settingThemeRadius": "1",
        "settingThemeFont": "sans-serif"
    };

    // Free hex colors, each used when its color setting is "custom"
    variables.hexSettings = {
        "settingColorPrimary": "settingThemePrimary",
        "settingColorAccent": "settingThemeAccent",
        "settingColorAccent2": "settingThemeAccent2"
    };

    // The accent colors and the CSS variables they set
    variables.accents = [
        {setting: "settingThemeAccent", colorSetting: "settingColorAccent", variable: "--saaster-accent"},
        {setting: "settingThemeAccent2", colorSetting: "settingColorAccent2", variable: "--saaster-accent-2"}
    ];

    /*
        Tabler's colors (--tblr-<value>, identical to the primary presets of tabler-themes.css).
        Tabler keeps light text on all of them; darkText marks those that stay below the contrast
        limit with it (computed from their --tblr-primary-rgb in tabler-themes.css).
    */
    variables.colorPresets = [
        {value: "blue", label: "Blue", darkText: false},
        {value: "azure", label: "Azure", darkText: false},
        {value: "indigo", label: "Indigo", darkText: false},
        {value: "purple", label: "Purple", darkText: false},
        {value: "pink", label: "Pink", darkText: false},
        {value: "red", label: "Red", darkText: false},
        {value: "orange", label: "Orange", darkText: false},
        {value: "yellow", label: "Yellow", darkText: true},
        {value: "lime", label: "Lime", darkText: true},
        {value: "green", label: "Green", darkText: true},
        {value: "teal", label: "Teal", darkText: false},
        {value: "cyan", label: "Cyan", darkText: false}
    ];

    // The choices of each theme setting in display order
    variables.themeChoices = {
        "settingThemePrimary": arrayMerge(duplicate(variables.colorPresets), [{value: "custom", label: "Custom color", darkText: false}]),
        "settingThemeAccent": arrayMerge(arrayMerge([{value: "none", label: "None", darkText: false}], variables.colorPresets), [{value: "custom", label: "Custom color", darkText: false}]),
        "settingThemeAccent2": arrayMerge(arrayMerge([{value: "none", label: "None", darkText: false}], variables.colorPresets), [{value: "custom", label: "Custom color", darkText: false}]),
        "settingThemeNavbar": [
            {value: "default", label: "As defined by the layout"},
            {value: "primary", label: "Primary color"}
        ],
        "settingThemeBase": [
            {value: "neutral", label: "Neutral (default)"},
            {value: "slate", label: "Slate"},
            {value: "gray", label: "Gray"},
            {value: "zinc", label: "Zinc"},
            {value: "stone", label: "Stone"},
            {value: "mist", label: "Mist"}
        ],
        "settingThemeRadius": [
            {value: "0", label: "None"},
            {value: "0.5", label: "Small"},
            {value: "1", label: "Default"},
            {value: "1.5", label: "Large"},
            {value: "2", label: "Extra large"}
        ],
        "settingThemeFont": [
            {value: "sans-serif", label: "Sans-serif (default)"},
            {value: "serif", label: "Serif"},
            {value: "monospace", label: "Monospace"}
        ]
    };

    // Below this contrast ratio with light text, text on a theme color switches to dark (WCAG 3:1 for UI components)
    variables.minLightTextContrast = 3;


    // The choices of a theme setting in display order (empty for settings without a fixed list)
    public array function choices(required string settingVariable) {
        return variables.themeChoices[arguments.settingVariable] ?: [];
    }


    public boolean function isThemeSetting(required string settingVariable) {
        return structKeyExists(variables.defaults, arguments.settingVariable);
    }


    // Returns an allowed value: other settings unchanged, theme settings as a listed choice or their default
    public string function normalizeValue(required string settingVariable, required string value) {

        if (!isThemeSetting(arguments.settingVariable)) {
            return arguments.value;
        }

        local.value = trim(arguments.value);

        if (structKeyExists(variables.hexSettings, arguments.settingVariable)) {
            return reFind("^##[0-9a-fA-F]{6}$", local.value) ? lCase(local.value) : variables.defaults[arguments.settingVariable];
        }

        loop array=choices(arguments.settingVariable) item="local.choice" {
            if (compareNoCase(local.choice.value, local.value) eq 0) {
                return local.choice.value;
            }
        }

        return variables.defaults[arguments.settingVariable];

    }


    // The theme of the backend, built from the system settings (application.systemSettingStruct)
    public struct function themeSetting(required struct settings) {

        local.theme = {};
        loop collection=variables.defaults key="local.setting" {
            local.theme[local.setting] = normalizeValue(local.setting, arguments.settings[local.setting] ?: "");
        }

        local.isCustom = local.theme.settingThemePrimary eq "custom";
        local.theme.darkText = colorNeedsDarkText(local.theme.settingThemePrimary, local.theme.settingColorPrimary);

        // Tabler always puts light text on a primary navbar, so light primary colors keep the layout colors
        local.theme.primaryNavbar = local.theme.settingThemeNavbar eq "primary" and !local.theme.darkText;

        local.tokens = [];
        if (local.isCustom) {
            arrayAppend(local.tokens, "--tblr-primary: " & local.theme.settingColorPrimary & ";");
            arrayAppend(local.tokens, "--tblr-primary-rgb: " & arrayToList(hexToRgb(local.theme.settingColorPrimary), ", ") & ";");
        }
        if (local.isCustom or local.theme.darkText) {
            arrayAppend(local.tokens, "--tblr-primary-fg: " & (local.theme.darkText ? "var(--tblr-dark)" : "var(--tblr-light)") & ";");
        }
        if (local.theme.darkText) {
            // Links use the primary color; on light backgrounds a light one needs darkening (dark mode as in Tabler)
            arrayAppend(local.tokens, "--tblr-link-color: " & textColor("--tblr-primary", true) & ";");
        }

        // Accent colors; without them backend.css falls back to the primary color and shows no accent decoration
        local.theme.hasAccent = false;
        loop array=variables.accents item="local.accent" {
            local.value = local.theme[local.accent.setting];
            if (local.value eq "none") continue;
            local.theme.hasAccent = true;
            local.accentDarkText = colorNeedsDarkText(local.value, local.theme[local.accent.colorSetting]);
            arrayAppend(local.tokens, local.accent.variable & ": " & (local.value eq "custom" ? local.theme[local.accent.colorSetting] : "var(--tblr-" & local.value & ")") & ";");
            arrayAppend(local.tokens, local.accent.variable & "-fg: " & (local.accentDarkText ? "var(--tblr-dark)" : "var(--tblr-light)") & ";");
            arrayAppend(local.tokens, local.accent.variable & "-text: " & textColor(local.accent.variable, local.accentDarkText) & ";");
        }

        // Only allowed values reach the attributes and the CSS, so they need no further encoding
        local.attributes = [];
        if (!local.isCustom) {
            arrayAppend(local.attributes, 'data-bs-theme-primary="' & local.theme.settingThemePrimary & '"');
        }
        arrayAppend(local.attributes, 'data-bs-theme-base="' & local.theme.settingThemeBase & '"');
        arrayAppend(local.attributes, 'data-bs-theme-radius="' & local.theme.settingThemeRadius & '"');
        arrayAppend(local.attributes, 'data-bs-theme-font="' & local.theme.settingThemeFont & '"');
        if (local.theme.primaryNavbar) {
            arrayAppend(local.attributes, 'data-bs-navbar-theme="primary"');
        }
        if (local.theme.hasAccent) {
            arrayAppend(local.attributes, "data-saaster-accent");
        }
        local.theme.htmlAttributes = " " & arrayToList(local.attributes, " ");

        local.theme.customCss = arrayIsEmpty(local.tokens) ? "" : ":root { " & arrayToList(local.tokens, " ") & " }";

        return local.theme;

    }


    // WCAG contrast ratio between a color and white
    public numeric function contrastWithWhite(required string hexColor) {
        return 1.05 / (relativeLuminance(arguments.hexColor) + 0.05);
    }


    public boolean function needsDarkText(required string hexColor) {
        return contrastWithWhite(arguments.hexColor) lt variables.minLightTextContrast;
    }


    // Text in a theme color: as is on light backgrounds (darkened if the color is light), lightened in dark mode as in Tabler
    private string function textColor(required string variable, required boolean darkText) {
        local.color = "var(" & arguments.variable & ")";
        local.light = arguments.darkText ? "color-mix(in oklab, " & local.color & " 55%, var(--tblr-black))" : local.color;
        return "light-dark(" & local.light & ", color-mix(in oklab, var(--tblr-white) 40%, " & local.color & "))";
    }


    // A preset color or the custom hex color of a color setting
    private boolean function colorNeedsDarkText(required string value, required string hexColor) {
        if (arguments.value eq "custom") {
            return needsDarkText(arguments.hexColor);
        }
        loop array=variables.colorPresets item="local.preset" {
            if (local.preset.value eq arguments.value) {
                return local.preset.darkText;
            }
        }
        return false;
    }


    private array function hexToRgb(required string hexColor) {
        local.hex = replace(arguments.hexColor, "##", "");
        return [
            inputBaseN(mid(local.hex, 1, 2), 16),
            inputBaseN(mid(local.hex, 3, 2), 16),
            inputBaseN(mid(local.hex, 5, 2), 16)
        ];
    }


    private numeric function relativeLuminance(required string hexColor) {
        local.channels = [];
        loop array=hexToRgb(arguments.hexColor) item="local.value" {
            local.channel = local.value / 255;
            arrayAppend(local.channels, local.channel lte 0.04045 ? local.channel / 12.92 : ((local.channel + 0.055) / 1.055) ^ 2.4);
        }
        return 0.2126 * local.channels[1] + 0.7152 * local.channels[2] + 0.0722 * local.channels[3];
    }


}
