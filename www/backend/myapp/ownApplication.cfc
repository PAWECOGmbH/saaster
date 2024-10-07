component displayname="myApplication" output="false" {

    // If needed, you can use your own codes for the Application.cfc here

    function ownApplicationStart() {

        application.objPlan = new backend.core.com.plans();
        application.objAdsBackend = new backend.myapp.com.ads();
        application.objAdsFrontend = new frontend.com.ads();
        application.objProfilesFrontend = new frontend.com.profiles();


    }

    function ownSessionStart() {


    }

    function ownRequestStart() {

        getSetting = application.objSettings.getSetting;

        if (structKeyExists(session, "currentPlan") and session.currentPlan.planID gt 0 and !session.sysadmin) {
            getAdCost = getSetting('varAdCosts', session.currentPlan.planID);
            getAdDuring = getSetting('varAdDuringDays', session.currentPlan.planID);
            planGroupID = application.objPlan.getPlanDetail(session.currentPlan.planID).planGroupID;
        } else {
            getAdCost = 0;
            getAdDuring = 0;
            planGroupID = 0;
        }

    }

    function ownRequest() {

    }


}