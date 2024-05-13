<cfcontent type="text/css" />

<cfoutput>

    .btn-primary{
        --tblr-btn-bg: #application.systemSettingStruct.settingColorPrimary# !important;
        --tblr-btn-disabled-bg: #application.systemSettingStruct.settingColorPrimary# !important;
    }
    .btn-primary:hover,
    .btn-primary:active{
        --tblr-btn-hover-bg: #application.systemSettingStruct.settingColorPrimary# !important;
        --tblr-btn-active-bg: #application.systemSettingStruct.settingColorPrimary# !important;    
        filter: brightness(110%) saturate(105%);
    }
    .btn-secondary{
        --tblr-btn-bg: #application.systemSettingStruct.settingColorSecondary# !important;
        --tblr-btn-disabled-bg:#application.systemSettingStruct.settingColorSecondary# !important;
    }

    .btn-secondary:hover,
    .btn-secondary:active{
        --tblr-btn-hover-bg: #application.systemSettingStruct.settingColorSecondary# !important;
        --tblr-btn-active-bg:#application.systemSettingStruct.settingColorSecondary# !important;
        filter: brightness(110%) saturate(105%);
    }

</cfoutput>