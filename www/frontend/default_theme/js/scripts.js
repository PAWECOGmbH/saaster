
/**
 * Toggles the visibility of price boxes and switches the active class on the selected plan.
 *
 * This function listens to changes in the "monthly" and "yearly" radio buttons and updates
 * both the displayed pricing boxes and the focus (visual highlight) of the active label.
 */
document.addEventListener('DOMContentLoaded', function() {

    // Radio buttons
    const monthlyRadio = document.getElementById('monthly');
    const yearlyRadio = document.getElementById('yearly');

    // Check if the elements are present on the page
    if (!monthlyRadio || !yearlyRadio) {
        return; // Exit if either element is missing
    }

    // Labels for styling
    const monthlyLabel = document.querySelector('label[for="monthly"]');
    const yearlyLabel = document.querySelector('label[for="yearly"]');

    // Price box elements
    const monthlyBoxes = document.querySelectorAll('.price_box.monthly');
    const yearlyBoxes = document.querySelectorAll('.price_box.yearly');

    // Select all booking buttons
    const bookingButtons = document.querySelectorAll('.bookingButton');

    // Function to toggle visibility and button focus, and update each booking button's link
    function togglePriceBoxes() {

        if (monthlyRadio.checked) {

            // Show monthly boxes, hide yearly boxes
            monthlyBoxes.forEach(box => box.style.display = 'block');
            yearlyBoxes.forEach(box => box.style.display = 'none');

            // Add active class to monthly, remove from yearly
            monthlyLabel.classList.add('active');
            yearlyLabel.classList.remove('active');

            // Update href for all booking buttons to the monthly link
            bookingButtons.forEach(button => {
                const monthlyLink = button.getAttribute('data-monthly');
                button.setAttribute('href', monthlyLink);
            });

        } else if (yearlyRadio.checked) {

            // Show yearly boxes, hide monthly boxes
            monthlyBoxes.forEach(box => box.style.display = 'none');
            yearlyBoxes.forEach(box => box.style.display = 'block');

            // Add active class to yearly, remove from monthly
            yearlyLabel.classList.add('active');
            monthlyLabel.classList.remove('active');

            // Update href for all booking buttons to the yearly link
            bookingButtons.forEach(button => {
                const yearlyLink = button.getAttribute('data-yearly');
                button.setAttribute('href', yearlyLink);
            });

        }

    }

    // Add event listeners to both radio buttons
    monthlyRadio.addEventListener('change', togglePriceBoxes);
    yearlyRadio.addEventListener('change', togglePriceBoxes);

    // Initial toggle based on the default selection
    togglePriceBoxes();

});



/**
 * This script manages the 6-digit MFA code input, handling numeric validation,
 * focus shifting, and form submission upon completion.
 */
document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('mfa_form');

    // Check if the form exists on the page
    if (!form) {
        return; // Exit if the form is not present
    }

    const inputs = form.querySelectorAll('.code-input');

    // Set focus on the first input with the class `.code-input`
    const firstInput = document.querySelector('.code-input');
    if (firstInput) {
        firstInput.focus();
    }

    /**
     * Restricts input to numeric characters only.
     *
     * @param {Event} event - The keypress event triggered when the user types a character.
     */
    function onlyDigits(event) {
        const charCode = event.which || event.keyCode;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }

    /**
     * Checks if all input fields are filled and submits the form if they are.
     */
    function checkAndSubmit() {
        const code = Array.from(inputs).map(input => input.value).join('');
        if (code.length === 6) {
            form.submit();
        }
    }

    /**
     * Event handling for each input field: numeric-only restriction, focus shifts,
     * and backspace handling.
     */
    inputs.forEach((input, index) => {
        input.addEventListener('keypress', onlyDigits);

        input.addEventListener('input', function (event) {
            const value = event.target.value;

            if (value.length === 1 && index < inputs.length - 1) {
                inputs[index + 1].focus(); // Move focus to the next field
            } else if (value.length > 1) {
                // Handle paste or multiple characters
                const values = value.split('');
                values.forEach((val, i) => {
                    if (index + i < inputs.length) {
                        inputs[index + i].value = val;
                    }
                });
                if (index + values.length < inputs.length) {
                    inputs[index + values.length].focus();
                }
            }

            checkAndSubmit(); // Submit if all fields are filled
        });

        input.addEventListener('keydown', function (event) {
            if (event.key === 'Backspace' && input.value === '' && index > 0) {
                inputs[index - 1].focus();
            }
        });
    });

    /**
     * Handles paste of a full 6-digit code into the first field.
     */
    inputs[0].addEventListener('paste', function (event) {
        const paste = event.clipboardData.getData('text');
        if (/^\d{6}$/.test(paste)) {
            paste.split('').forEach((char, i) => {
                if (i < inputs.length) {
                    inputs[i].value = char;
                }
            });
            checkAndSubmit();
        }
        event.preventDefault(); // Prevent default paste action
    });



});



/**
 * Prevents the user from navigating back using the browser's back button
 * after logging out. This script runs only when `isLogout` is true.
 *
 * @param {Window} global - The global window object.
 */
(function (global) {
    if (typeof (global) === "undefined") {
        throw new Error("window is undefined");
    }

    // Check if the user has logged out
    if (typeof isLogout !== "undefined" && isLogout) {

        /**
         * Disables the browser's back navigation by manipulating the history state.
         */
        var noBackPlease = function () {
            global.history.pushState(null, null, global.location.href);
            global.addEventListener('popstate', function () {
                global.history.pushState(null, null, global.location.href);
            });
        };

        /**
         * Runs when the page is fully loaded.
         * Calls the function to disable the back button and prevents backspace key navigation.
         */
        global.onload = function () {
            noBackPlease();

            // Prevent the backspace key from navigating back when not in an input or textarea
            document.body.onkeydown = function (e) {
                var elm = e.target.nodeName.toLowerCase();
                if (e.which === 8 && (elm !== 'input' && elm !== 'textarea')) {
                    e.preventDefault();
                }
                e.stopPropagation();
            };
        };
    }
})(window);
