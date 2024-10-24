/**
 * Displays a SweetAlert popup with dynamic content and button actions.
 *
 * @param {string} type - The type of alert ('warning', 'info', etc.).
 * @param {string} thisURL - The URL to redirect to if the second button is clicked.
 * @param {string} textOne - The main title text of the alert.
 * @param {string} textTwo - The secondary text of the alert.
 * @param {string} buttonOne - The label for the first button.
 * @param {string} buttonTwo - The label for the second button (optional).
 */
function sweetAlert(type, thisURL, textOne, textTwo, buttonOne, buttonTwo) {

    // Determine if danger mode (red highlight) should be activated based on the type of alert
    let dangerMode = (type === "warning");

    // If a second button is provided, display the alert with two buttons
    if (buttonTwo) {
        swal({
            title: textOne,
            text: textTwo,
            icon: type,
            buttons: [buttonOne, buttonTwo], // Two buttons array
            dangerMode: dangerMode,
        }).then((willDelete) => {
            // If the user confirms (clicks the second button), redirect to the provided URL
            if (willDelete) {
                window.location.href = thisURL;
            }
            // Refresh UI buttons after the alert is handled
            refreshButton();
        });

    } else {
        // If no second button is provided, display a simple alert with one button
        swal({
            title: textOne,
            text: textTwo,
            icon: type,
            buttons: [buttonOne], // Only one button
        }).then(() => {
            // Refresh UI buttons after the alert is handled
            refreshButton();
        });
    }
}

/**
 * Placeholder function to refresh buttons on the UI.
 * This could include re-enabling buttons or other UI updates after SweetAlert actions.
 */
function refreshButton() {
    // Logic for refreshing buttons or resetting the UI (placeholder function)
    $('a.plan').each(function(i, obj) {
        $(this).text(obj.text); // Reset the button text
        $(this).removeClass('disabled'); // Ensure the button is enabled
    });
}




/**
 * Executes a live search for customers based on input and updates the result area.
 *
 * @param {string} str - The search string entered by the user.
 */
function showResult(str) {

    // If the search string is empty, clear the live search results and exit the function
    if (str.length === 0) {
        document.getElementById("livesearch").innerHTML = "";
        return;
    }

    // Create a new XMLHttpRequest to perform an AJAX request
    var xmlhttp = new XMLHttpRequest();

    // Define the callback function for handling the AJAX response
    xmlhttp.onreadystatechange = function() {
        // If the request is complete (readyState = 4) and successful (status = 200)
        if (this.readyState === 4 && this.status === 200) {
            // Insert the server's response (HTML) into the 'livesearch' element
            document.getElementById("livesearch").innerHTML = this.responseText;
        }
    };

    // Open a GET request to the server with the search query as a parameter
    xmlhttp.open("GET", "/backend/core/views/sysadmin/ajax_search_customer.cfm?search=" + encodeURIComponent(str), true);

    // Send the AJAX request
    xmlhttp.send();
}


/**
 * Populates the customer name and ID fields when a search result is selected.
 *
 * @param {string} c - The customer name to be inserted into the input field.
 * @param {string} i - The customer ID to be inserted into the hidden field.
 */
function intoTf(c, i) {
    // Find the input field for the customer name and set its value to the selected name
    var customer_name = document.getElementById("searchfield");
    customer_name.value = c;

    // Find the hidden input field for the customer ID and set its value to the selected ID
    var customer_id = document.getElementById("customer_id");
    customer_id.value = i;
}

/**
 * Clears the live search results when the user wants to hide the suggestions.
 */
function hideResult() {
    // Simply clear the innerHTML of the live search result container
    document.getElementById("livesearch").innerHTML = "";
}


/**
 * Submits the payment form via AJAX and reloads the modal content.
 */
function sendPayment() {
    var paymentModal = $('#dyn_modal-content');
    var formData = $("#sendPayment").serialize();
    var formAction = $("#sendPayment").attr("action");
    var formReturn = $("#sendPayment").data("return");

    $.ajax({
        type: "POST",
        url: formAction,
        data: formData,
        success: function () {
            paymentModal.load(formReturn);
        }
    });
}

/**
 * Deletes a payment via AJAX and reloads the modal content.
 *
 * @param {number} paymentID - The ID of the payment to be deleted.
 */
function deletePayment(paymentID) {
    var paymentModal = $('#dyn_modal-content');
    var formData = 'delete_payment=' + encodeURIComponent(paymentID);
    var formAction = $("#sendPayment").attr("action");
    var formReturn = $("#sendPayment").data("return");

    $.ajax({
        type: "POST",
        url: formAction,
        data: formData,
        success: function(data) {
            paymentModal.load(formReturn);
        }
    });
}


/**
 * Disables all buttons of the specified class, adds a loading spinner, and redirects to the given URL.
 *
 * @param {string} buttonClass - The class of the buttons to be disabled.
 * @param {string} url - The URL to redirect to after disabling the buttons.
 */
function disableButtonsAndRedirect(buttonClass, url) {
    // Disable all buttons of the specified class and show a loading spinner on each
    $(buttonClass).each(function(i, obj) {
        // Add a Bootstrap spinner and append the button text
        $(obj).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;' + obj.text);

        // Disable the button to prevent further clicks
        $(obj).addClass('disabled');
    });

    // Redirect the user to the specified URL
    location.href = url;
}

/**
 * Handles the activation of a module when the user clicks on a link with the class 'activate-module'.
 * This prevents multiple clicks, shows a spinner, and redirects to the module activation URL.
 */
$('body').on('click', 'a.activate-module', function(e) {
    e.preventDefault();  // Prevent default link behavior

    // Get the activation URL from the clicked link
    var moduleUrl = $(this).attr('href');

    // Use the helper function to disable buttons and redirect
    disableButtonsAndRedirect('a.activate-module', moduleUrl);
});

/**
 * Handles plan selection when the user clicks on a link with the class 'plan'.
 * This prevents multiple clicks, shows a spinner, and redirects to the selected plan URL.
 */
$('body').on('click', 'a.plan', function(e) {
    e.preventDefault();  // Prevent default link behavior

    // Get the plan URL from the clicked link
    var planUrl = $(this).attr('href');

    // Use the helper function to disable buttons and redirect
    disableButtonsAndRedirect('a.plan', planUrl);
});


/**
 * Generates a random UUID (Universally Unique Identifier) using the standard version 4 format.
 *
 * @returns {string} A randomly generated UUID.
 */
function generateUUID() {
    var timestamp = new Date().getTime();

    if (window.performance && typeof window.performance.now === "function") {
        timestamp += performance.now();
    }

    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var randomHex = (timestamp + Math.random() * 16) % 16 | 0;
        timestamp = Math.floor(timestamp / 16);
        return (c === 'x' ? randomHex : (randomHex & 0x3 | 0x8)).toString(16);
    });
}






/* ========================================================= */
/*  jQuery Initialization & Event Handling                   */
/*  This section contains all jQuery-based interactions      */
/*  and dynamic event handlers. Ensure the DOM is fully      */
/*  loaded before manipulating elements or attaching events. */
/* ========================================================= */

$(document).ready(function() {

    /**
     * Toggles all checkboxes when the "Check All" checkbox is clicked.
     *
     * @param {Event} event - The event triggered when the #checkAll checkbox changes.
     */
    $("#checkAll").change(function(event) {
        // Set all checkboxes' 'checked' state to match the "Check All" checkbox
        $("input:checkbox").prop('checked', $(this).prop("checked"));
    });

    /**
     * Toggles a row's checkbox when the row is clicked, unless the target is a checkbox.
     *
     * @param {Event} event - The click event triggered on the table row.
     */
    $('#checkall tr').click(function(event) {
        // Only trigger checkbox click if the actual target was not a checkbox (i.e., user clicked the row)
        if (event.target.type !== 'checkbox') {
            // Trigger the checkbox inside the clicked row
            $(':checkbox', this).trigger('click');
        }
    });


    // Add the modal functionality for loading dynamic content
    /**
     * Opens a modal and loads dynamic content via AJAX.
     *
     * This function is triggered when an element with the class 'openPopup' is clicked.
     * It retrieves the URL from the 'data-href' attribute of the clicked element,
     * then loads that URL's content into the modal, and finally displays the modal.
     */
    $('.openPopup').on('click', function(event) {
        event.preventDefault(); // Prevent the default behavior (e.g., following a link)

        // Retrieve the URL for loading dynamic content from the 'data-href' attribute
        var dataURL = $(this).attr('data-href');

        // Load the content from the URL into the modal's content container ('#dyn_modal-content')
        $('#dyn_modal-content').load(dataURL, function() {
            // Show the modal once the content has been successfully loaded
            $('#dynModal').modal('show');

            // Initialize Litepicker (if present) for date inputs within the loaded content
            if (window.Litepicker) {
                // Apply Litepicker to the element with ID 'date1'
                new Litepicker({
                    element: document.getElementById('date1'),
                    buttonText: {
                        previousMonth: `<i class="fas fa-angle-left" style="cursor: pointer;"></i>`,
                        nextMonth: `<i class="fas fa-angle-right" style="cursor: pointer;"></i>`,
                    },
                });

                // Apply Litepicker to the element with ID 'date2'
                new Litepicker({
                    element: document.getElementById('date2'),
                    buttonText: {
                        previousMonth: `<i class="fas fa-angle-left" style="cursor: pointer;"></i>`,
                        nextMonth: `<i class="fas fa-angle-right" style="cursor: pointer;"></i>`,
                    },
                });
            }
        });
    });

    // Load modal with dynamic content (general big)
    $('.openPopup_big').on('click', function(event) {
        event.preventDefault(); // Prevent default behavior (e.g., following a link)
        var dataURL = $(this).attr('data-href');

        $('#dyn_modal-content').load(dataURL, function() {
            $('#dynModal_big').modal('show'); // Show the large modal
        });
    });


    /**
     * Enables sortable drag-and-drop functionality for the #dragndrop_body element.
     *
     * The items can be rearranged by dragging them via a handle (".move"). Special handling is
     * applied for Firefox browsers due to their specific behavior during dragging operations.
     */

    $('#dragndrop_body').sortable({
        handle: ".move",  // Element that acts as the drag handle

        /**
         * Triggered when dragging starts.
         *
         * Applies specific handling for Firefox browsers, adjusting the position and margin of the dragged element.
         */
        start: function(event, ui) {
            // Special handling for Firefox browsers
            if (navigator.userAgent.toLowerCase().match(/firefoxy/) && ui.helper !== undefined) {
                alert('ff'); // Debugging alert (can be removed)
                // Set the dragged item's position and margin relative to the window's scroll position
                ui.helper.css('position', 'absolute').css('margin-top', $(window).scrollTop());

                // Adjust the margin when the window scrolls during the drag operation
                $(window).bind('scroll.sortableplaylist', function () {
                    ui.helper.css('position', 'absolute').css('margin-top', $(window).scrollTop());
                });
            }
        },

        /**
         * Triggered before the dragging stops.
         *
         * Removes the special scroll handling for Firefox and resets the margin.
         */
        beforeStop: function(event, ui) {
            if (navigator.userAgent.toLowerCase().match(/firefoxy/) && ui.offset !== undefined) {
                // Unbind the scrolling behavior once the drag stops
                $(window).unbind('scroll.sortableplaylist');
                // Reset margin
                ui.helper.css('margin-top', 0);
            }
        },

        /**
         * Custom helper function to keep item widths consistent during the drag.
         *
         * This ensures that each child element of the dragged item retains its width while being dragged.
         */
        helper: function(e, ui) {
            // Set the width of each child element to its original width during drag
            ui.children().each(function() {
                $(this).width($(this).width());
            });
            return ui; // Return the modified element for dragging
        },

        scroll: true,  // Allow scrolling while dragging

        /**
         * Triggered when dragging stops.
         *
         * Calls a function to save the new order of items after the drag completes.
         */
        stop: function(event, ui) {
            fnSaveSort(); // Function to save the new item order (assumed to be defined elsewhere)
        }

    });


    /**
     * Changes the cursor style to "grab" on mouse up and to "grabbing" on mouse down for elements with the class 'hand'.
     *
     * This provides visual feedback to the user when interacting with draggable elements.
     */
    $(".hand")
    .mouseup(function() {
        // Set the cursor to "grab" when the mouse button is released
        $(this).css("cursor", "grab");
    })
    .mousedown(function() {
        // Set the cursor to "grabbing" when the mouse button is pressed
        $(this).css("cursor", "grabbing");
    });


    /**
     * Enables sorting for the dashboard widgets using drag-and-drop.
     *
     * Users can drag widgets by the handle (".move-widget"). After sorting is done, the new order
     * is sent to the server for persistence.
     */
    $('div.dashboard').sortable({
        handle: '.move-widget',  // Element that acts as the drag handle
        tolerance: 'pointer',    // Defines how the items are sorted based on the pointer
        placeholder: 'widget-placeholder',  // Class to apply to the placeholder during sorting

        /**
         * Triggered when the sorting starts. Adds the appropriate column classes to the placeholder
         * so it maintains the correct size.
         */
        start: function(event, ui) {
            // Split the class list of the dragged item and apply relevant column classes to the placeholder
            var classes = ui.item.attr('class').split(/\s+/);
            for (var x = 0; x < classes.length; x++) {
                if (classes[x].indexOf("col") > -1) {
                    ui.placeholder.addClass(classes[x]);
                }
            }

            // Set the placeholder's width, height, and padding based on the dragged item's dimensions
            ui.placeholder.css({
                width: ui.item.innerWidth() - 30 + 1,
                height: ui.item.innerHeight() - 15 + 1,
                padding: ui.item.css("padding")
            });
        },

        /**
         * Triggered when the sorting stops. Sends the new order of the widgets to the server.
         */
        stop: function(event, ui) {
            // Send the new widget order to the server for persistence
            $.post('/dashboard-settings', { sortorder: $(this).sortable('serialize') });
        }
    }).disableSelection();  // Disable text selection during sorting


    /**
     * Enables or disables dashboard widgets based on checkbox status.
     *
     * When a widget is enabled or disabled, the server is updated with the new status, and the widget's
     * visibility is adjusted in the UI.
     */
    $('.disable-widget').on('change', function() {
        var $isvisible = $(this).closest('div.card-header').find('span.isvisible');
        var $isinvisible = $(this).closest('div.card-header').find('span.isinvisible');
        var $targetWidget = $(this).closest('div.card').find('div.card-body');

        // If the widget is enabled (checkbox is checked)
        if ($(this).prop('checked')) {
            $.post('/dashboard-settings', { action: 'disable', id: $(this).val(), active: 1 }, function() {
                // Remove the 'widget-disabled' class and show the widget
                $targetWidget.removeClass('widget-disabled');
                $isinvisible.hide();  // Hide the "invisible" indicator
                $isvisible.show();    // Show the "visible" indicator
            });
        } else {
            // If the widget is disabled (checkbox is unchecked)
            $.post('/dashboard-settings', { action: 'disable', id: $(this).val(), active: 0 }, function() {
                // Add the 'widget-disabled' class and hide the widget
                $targetWidget.addClass('widget-disabled');
                $isvisible.hide();    // Hide the "visible" indicator
                $isinvisible.show();  // Show the "invisible" indicator
            });
        }

    });


    /**
     * Updates the displayed plan details based on the user's selection of a plan and recurring period (monthly/yearly).
     *
     * The first function handles clicks on the plan editing buttons, while the second function updates
     * the displayed plan whenever the user toggles between monthly and yearly recurrence.
     */

    // Handle plan edit button clicks
    $('.plan_edit').on('click', function() {
        // Get the plan ID from the clicked element
        var plan_id = $(this).val();
        var recurring = '';

        // Loop through the recurring options to determine which one is selected
        $('.plan_recurring').each(function() {
            if ($(this).prop('checked')) {
                recurring = $(this).val();  // Get the value of the selected option
            }
        });

        // If no recurring option is selected, default to 'monthly'
        if (recurring === '') {
            $(".plan_recurring[value='monthly']").prop('checked', true);
            recurring = 'monthly';
        }

        // Load the updated plan details via AJAX into the '#change_plan' container
        $('#change_plan').load('/backend/core/views/plan_calc.cfm?plan_id=' + plan_id + '&recurring=' + recurring);

    });

    // Handle clicks on recurring options (monthly/yearly)
    $('.plan_recurring').on('click', function() {
        var plan_id;
        var recurring = $(this).val();  // Get the selected recurring option (monthly or yearly)

        // Loop through the plan edit buttons to determine which plan is currently selected
        $('.plan_edit').each(function() {
            if ($(this).prop('checked')) {
                plan_id = $(this).val();  // Get the plan ID of the selected plan
            }
        });

        // Load the updated plan details via AJAX into the '#change_plan' container
        $('#change_plan').load('/backend/core/views/plan_calc.cfm?plan_id=' + plan_id + '&recurring=' + recurring);

    });

    /**
     * Initializes the Trumbowyg WYSIWYG editor on all elements with the class 'editor'.
     *
     * Trumbowyg is a lightweight, customizable editor. This code configures it with specific toolbar
     * buttons like bold, italic, link, formatting, and alignment options.
     */
    $('.editor').each(function(index, element) {
        var $this = $(element);  // The current editor element

        // Initialize the Trumbowyg editor with custom toolbar options
        $this.trumbowyg({
            btns: [
                ['viewHTML'],                    // Toggle HTML view
                ['bold', 'italic'],              // Basic formatting options
                ['link'],                        // Insert/edit a link
                ['formatting'],                  // Heading, subheading, etc.
                ['justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull'],  // Text alignment options
                ['unorderedList', 'orderedList'] // Bullet points and numbered lists
            ]
        });
    });

    /**
     * Initializes the Dropify plugin on all input elements with the class 'dropify'.
     *
     * Dropify provides a customizable and user-friendly file input field for uploading pictures or files.
     */
    $('.dropify').dropify();


    /**
     * Disables the submit button when the form is submitted to prevent multiple submissions.
     *
     * This function disables the submit button by adding the 'disabled' attribute and applies a class 'not-allowed'
     * to give visual feedback that the button is no longer clickable. This helps prevent duplicate form submissions.
     *
     * @returns {boolean} true - Allows the form to continue submission after disabling the button.
     */
    $("#submit_form").submit(function () {
        // Disable the submit button and add a 'not-allowed' class to change the cursor style
        $("#submit_button").attr("disabled", true).addClass("not-allowed");

        // Allow the form submission to proceed
        return true;
    });

    /**
     * Handles the relationship between sysadmin, superadmin, and admin checkboxes.
     *
     * If sysadmin is selected, both superadmin and admin must be selected.
     * If superadmin is selected, admin must be selected but sysadmin can be deselected.
     * If admin is deselected, both sysadmin and superadmin are deselected.
     */
    $('input[name="sysadmin"], input[name="superadmin"], input[name="admin"]').on('click', function() {
        var isSysadminChecked = $('input[name="sysadmin"]').prop('checked');
        var isSuperadminChecked = $('input[name="superadmin"]').prop('checked');
        var isAdminChecked = $('input[name="admin"]').prop('checked');

        // If sysadmin is checked, superadmin and admin should also be checked
        if ($(this).attr('name') === 'sysadmin') {
            if (isSysadminChecked) {
                $('input[name="superadmin"]').prop('checked', true);
                $('input[name="admin"]').prop('checked', true);
            }
        }

        // If superadmin is checked, admin should also be checked; if unchecked, sysadmin is unchecked
        if ($(this).attr('name') === 'superadmin') {
            if (isSuperadminChecked) {
                $('input[name="admin"]').prop('checked', true);
            } else {
                $('input[name="sysadmin"]').prop('checked', false);
            }
        }

        // If admin is unchecked, both sysadmin and superadmin should be unchecked
        if ($(this).attr('name') === 'admin') {
            if (!isAdminChecked) {
                $('input[name="sysadmin"]').prop('checked', false);
                $('input[name="superadmin"]').prop('checked', false);
            }
        }
    });

    /**
     * Handles the Sysadmin settings for the Swiss QR Bill.
     */
    function handleQrBillVisibility() {
        var roundFactorValue = $('#roundFactorSelect').val();
        var qrBillCheckboxValue = $('#QrBillCheckbox').val();

        // Show or hide the QR Bill container based on the round factor selection
        if (roundFactorValue === '5') {
            $('#QrBillContainer').show();
            // Show or hide the extra link based on the QR Bill checkbox
            if (qrBillCheckboxValue === '1') {
                $('#extraLink').show();
            } else {
                $('#extraLink').hide();
            }
        } else {
            $('#QrBillContainer').hide();
            $('#extraLink').hide();
            $('#QrBillCheckbox').val('0'); // Reset QR Bill checkbox if not applicable
        }
    }

    // Handle changes to the round factor dropdown
    $('#roundFactorSelect').change(function() {
        handleQrBillVisibility();
    });

    // Handle changes to the QR Bill checkbox
    $('#QrBillCheckbox').change(function() {
        handleQrBillVisibility();
    });

    // Initial call to set the correct visibility when the page loads
    handleQrBillVisibility();


    /**
     * Event listener for the "generate key" icon in the modal.
     *
     * When the user clicks on the icon with the id `#keygen`, this function generates a UUID
     * using the `generateUUID()` function and sets the value of the `#apiKey` input field with the
     * generated UUID.
     */
    $('#keygen').on('click', function() {
        var newUUID = generateUUID();  // Generate a new UUID
        $('#apiKey').val(newUUID);     // Set the generated UUID into the input field with id #apiKey
        console.log("Generated API Key: " + newUUID);  // Log the generated UUID for debugging
    });


});







