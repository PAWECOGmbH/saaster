<cfscript>

objAds = new backend.myapp.com.admin.ads();

// Deactivate ad
if (structKeyExists(url, "deactivate")) {

if (isNumeric(url.deactivate)) {

    deactivateAd = objAds.deactivateAd(url.deactivate, session.customer_id, session.user_id);

    if (deactivateAd.success) {
        getAlert(deactivateAd.message);
    } else {
        getAlert(deactivateAd.message, "danger");
    }

}

}

// Activate ad
if (structKeyExists(url, "activate")) {

    if (isNumeric(url.activate)) {

        activateAd = objAds.activateAd(url.activate, session.customer_id, session.user_id);

        if (activateAd.success) {
            getAlert(activateAd.message);
        } else {
            getAlert(activateAd.message, "danger");
        }

    }

}

// Edit date
if (structKeyExists(form, "updatedDate")) {

    if (isDate(form.updatedDate)) {

        if (structKeyExists(url, "id") and isNumeric(url.id)) {

            editDate = objAds.editDate(form.updatedDate, url.id, session.customer_id, session.user_id);

            if (editDate.success eq "date") {

                getAlert(editDate.message, "warning");

            } else {

                if (editDate.success) {
                    getAlert(editDate.message);
                } else {
                    getAlert(editDate.message, "danger");
                }

            }

        }

    }

}


location url="#application.mainURL#/admin/ads" addtoken="false";

</cfscript>