<cfscript>

objAds = new backend.myapp.com.ads();

// New ad
if (structKeyExists(form, "new_ad")) {

   jobData = structNew();
   jobData['customerID'] = session.customer_id;
   jobData['userID'] = session.user_id;
   jobData['adTypeID'] = form.typeID;
   structAppend(jobData, form);

   saveJob = objAds.newJob(jobData);

   if (saveJob.success) {
      getAlert(saveJob.message);
   } else {
      getAlert(saveJob.message, "danger");
   }

   if (form.typeID eq 1) {
      location url="#application.mainURL#/employer/ads" addtoken="false";
   } else if (form.typeID eq 2) {
      location url="#application.mainURL#/employee/ads/new" addtoken="false";
   } else {
      location url="#application.mainURL#/dashboard" addtoken="false";
   }

}

// Edit ad
if (structKeyExists(form, "edit_ad")) {

   if (structKeyExists(form, "adID") and isNumeric(form.adID)) {

      jobData = structNew();
      jobData['customerID'] = session.customer_id;
      jobData['userID'] = session.user_id;
      jobData['adTypeID'] = form.typeID;
      structAppend(jobData, form);

      saveJob = objAds.editJob(form.adID, jobData);

      if (saveJob.success) {
         getAlert(saveJob.message);
      } else {
         getAlert(saveJob.message, "danger");
      }

      if (form.typeID eq 1) {
         location url="#application.mainURL#/employer/ads/edit/#form.adID#" addtoken="false";
      } else if (form.typeID eq 2) {
         location url="#application.mainURL#/employee/ads/edit/#form.adID#" addtoken="false";
      } else {
         location url="#application.mainURL#/dashboard" addtoken="false";
      }

   }

}

// Delete ad
if (structKeyExists(url, "del")) {

   if (isNumeric(url.del)) {

      delJob = objAds.delAd(url.del, session.customer_id, session.user_id);

      if (delJob.success) {
         getAlert(delJob.message);
      } else {
         getAlert(delJob.message, "danger");
      }

      if (structKeyExists(url, "archive")) {
         location url="#application.mainURL#/employer/ads/archive" addtoken="false";
      }

      location url="#application.mainURL#/employer/ads" addtoken="false";

   }

}

// Activate ad
if (structKeyExists(url, "activate")) {

   if (isNumeric(url.activate)) {

      activateAd = objAds.activateAd(url.activate, session.customer_id, session.user_id, session.currentPlan.planID);

      if (activateAd.success) {
         getAlert(activateAd.message);
         location url="#application.mainURL#/account-settings/invoice/#activateAd.invoiceID#" addtoken="false";
      } else {
         getAlert(activateAd.message, "danger");
      }

      location url="#application.mainURL#/employer/ads" addtoken="false";

   }

}

// Pause ad
if (structKeyExists(url, "pause")) {

   if (isNumeric(url.pause)) {

      pauseAd = objAds.pauseAd(url.pause, session.customer_id, session.user_id);

      if (pauseAd.success) {
         getAlert(pauseAd.message);
      } else {
         getAlert(pauseAd.message, "danger");
      }

      location url="#application.mainURL#/employer/ads" addtoken="false";

   }

}

// Reactivate ad
if (structKeyExists(url, "pauseback")) {

   if (isNumeric(url.pauseback)) {

      reactiveAd = objAds.reactiveAd(url.pauseback, session.customer_id, session.user_id);

      if (reactiveAd.success) {
         getAlert(reactiveAd.message);
      } else {
         getAlert(reactiveAd.message, "danger");
      }

      location url="#application.mainURL#/employer/ads" addtoken="false";

   }

}


// End ad
if (structKeyExists(url, "end")) {

   if (isNumeric(url.end)) {

      endAd = objAds.endAd(url.end, session.customer_id, session.user_id);

      if (endAd.success) {
         getAlert(endAd.message);
      } else {
         getAlert(endAd.message, "danger");
      }

      location url="#application.mainURL#/employer/ads" addtoken="false";

   }

}


// Copy ad
if (structKeyExists(url, "copy")) {

   if (isNumeric(url.copy)) {

      copyAd = objAds.copyAd(url.copy, session.customer_id, session.user_id);

      if (copyAd.success) {
         getAlert(copyAd.message);
      } else {
         getAlert(copyAd.message, "danger");
      }

      location url="#application.mainURL#/employer/ads" addtoken="false";

   }

}


// Archive ad
if (structKeyExists(url, "archive")) {

   if (isNumeric(url.archive)) {

      archiveAd = objAds.archiveAd(url.archive, session.customer_id, session.user_id);

      if (archiveAd.success) {
         getAlert(archiveAd.message);
         location url="#application.mainURL#/employer/ads/archive" addtoken="false";
      } else {
         getAlert(archiveAd.message, "danger");
      }

      location url="#application.mainURL#/employer/ads" addtoken="false";

   }

}


// Application done
if (structKeyExists(form, "app")) {

   if (isNumeric(form.app) and form.app gt 0) {

      changeStatus = objAds.changeAppStatus(form, session.customer_id);

      location url="#application.mainURL#/employer/app-detail/#form.app#" addtoken="false";

   }

}


// Application delete
if (structKeyExists(url, "del_app")) {

   if (isNumeric(url.del_app) and url.del_app gt 0) {

      if (structKeyExists(url, "job") and isNumeric(url.job) and url.job gt 0) {

         delApp = objAds.delApplication(url.del_app, session.customer_id);

         if (delApp.success) {
            getAlert(delApp.message);
            location url="#application.mainURL#/employer/applications/#url.job#" addtoken="false";
         } else {
            getAlert(delApp.message, "danger");
            location url="#application.mainURL#/employer/ads" addtoken="false";
         }

      }

   }

}

location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>