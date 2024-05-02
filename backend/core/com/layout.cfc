component displayname="layout" output="false" {

    public struct function layoutSetting(required String layoutValue) {

        local.struct = structNew();
        local.struct['layoutString'] = ''
        local.struct['layoutBody'] = '';
        local.struct['layoutHeader'] = '';
        local.struct['layoutHeaderEnd'] ='';
        local.struct['layoutContainer'] = '';
        local.struct['layoutTitel'] = '';
        local.struct['layoutDiv'] = '';
        local.struct['layoutClass'] = '';
        local.struct['layoutNav'] = '';
        local.struct['layoutLogo'] = '';
        local.struct['layoutPage'] = '';
        local.struct['layoutPageHeader'] = '';
        local.struct['layoutPageFooter'] = '';
        local.struct['layoutDivStart'] = '';
        local.struct['layoutDivEnd'] = '';
        local.struct['horizontal'] = '';

    
        switch(arguments.layoutValue){
            case "horizontal":
                local.struct['layoutString'] = 'horizontal';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-light d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-xl';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "horizontalDark":
                local.struct['layoutString'] = 'horizontalDark';
                local.struct['layoutBody'] = 'class="theme-dark"';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-light d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-xl';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "verticalTransparent":
                local.struct['layoutString'] = 'verticalTransparent';
                local.struct['layoutHeader'] = '<aside class="navbar navbar-vertical navbar-expand-lg navbar-light">';
                local.struct['layoutHeaderEnd'] = '</aside>';
                local.struct['layoutContainer'] = 'container-fluid';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark';
                local.struct['layoutDiv'] = 'navbar-nav flex-row d-lg-none';
                local.struct['layoutClass'] = 'class="d-md-none"';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "vertical":
                local.struct['layoutString'] = 'vertical';
                local.struct['layoutHeader'] = '<aside class="navbar navbar-vertical navbar-expand-lg navbar-dark">';
                local.struct['layoutHeaderEnd'] = '</aside>';
                local.struct['layoutContainer'] = 'container-fluid';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark';
                local.struct['layoutDiv'] = 'navbar-nav flex-row d-lg-none';
                local.struct['layoutClass'] = 'class="d-md-none"';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo-withe.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "rightVertical":
                local.struct['layoutString'] = 'rightVertical';
                local.struct['layoutHeader'] = '<aside class="navbar navbar-vertical navbar-right navbar-expand-lg navbar-light">';
                local.struct['layoutHeaderEnd'] = '</aside>';
                local.struct['layoutContainer'] = 'container-fluid';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark';
                local.struct['layoutDiv'] = 'navbar-nav flex-row d-lg-none';
                local.struct['layoutClass'] = 'class="d-md-none"';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "condensed":
                local.struct['layoutString'] = 'condensed';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-light d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-xl';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "combined":
                local.struct['layoutString'] = 'combined';
                local.struct['layoutHeader'] = '<aside class="navbar navbar-vertical navbar-expand-lg navbar-dark">';
                local.struct['layoutHeaderEnd'] = '</aside>';
                local.struct['layoutContainer'] = 'container-fluid';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark';
                local.struct['layoutDiv'] = 'navbar-nav flex-row d-lg-none';
                local.struct['layoutClass'] = 'class="d-md-none"';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo-withe.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "navbarDark":
                local.struct['layoutString'] = 'navbarDark';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-dark d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-xl';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo-withe.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "navbarSticky":
                local.struct['layoutString'] = 'navbarSticky';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-light sticky-top d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-xl';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct['layoutDivStart'] = '<div class="sticky-top">';
                local.struct['layoutDivEnd'] = '</div>';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "navbarOverlap":
                local.struct['layoutString'] = 'navbarOverlap';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-dark navbar-overlap d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-xl';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo-withe.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none text-white';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "fluid":
                local.struct['layoutString'] = 'fluid';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-light d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-fluid';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-fluid';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-fluid';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            case "fluidVertical":
                local.struct['layoutString'] = 'fluidVertical';
                local.struct['layoutHeader'] = '<aside class="navbar navbar-vertical navbar-expand-lg navbar-dark">';
                local.struct['layoutHeaderEnd'] = '</aside>';
                local.struct['layoutContainer'] = 'container-fluid';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark';
                local.struct['layoutDiv'] = 'navbar-nav flex-row d-lg-none';
                local.struct['layoutClass'] = 'class="d-md-none"';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo-withe.svg';
                local.struct['layoutPage'] = 'container-fluid';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-fluid';
                local.struct[arguments.layoutValue] = 'checked';
                break;
            default:
                local.struct['layoutString'] = 'horizontal';
                local.struct['layoutHeader'] = '<header class="navbar navbar-expand-md navbar-light d-print-none">';
                local.struct['layoutHeaderEnd'] ='</header>';
                local.struct['layoutContainer'] = 'container-xl';
                local.struct['layoutTitel'] = 'navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3';
                local.struct['layoutDiv'] = 'navbar-nav flex-row order-md-last';
                local.struct['layoutNav'] = 'navbar navbar-light';
                local.struct['layoutLogo'] = '#application.mainURL#/dist/img/logo.svg';
                local.struct['layoutPage'] = 'container-xl';
                local.struct['layoutPageHeader'] = 'page-header d-print-none';
                local.struct['layoutPageFooter'] = 'container-xl';
                local.struct['horizontal'] = 'checked';
                break;
        }
        
        return local.struct;
    }
}
