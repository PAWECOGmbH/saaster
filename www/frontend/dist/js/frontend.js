
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

    // Labels
    const monthlyLabel = document.querySelector('label.monthly');
    const yearlyLabel = document.querySelector('label.yearly');

    // Price box elements
    const monthlyBoxes = document.querySelectorAll('.price_box.monthly');
    const yearlyBoxes = document.querySelectorAll('.price_box.yearly');

    // Function to toggle visibility and button focus
    function togglePriceBoxes() {
        if (monthlyRadio.checked) {
            // Show monthly boxes, hide yearly boxes
            monthlyBoxes.forEach(box => box.style.display = 'block');
            yearlyBoxes.forEach(box => box.style.display = 'none');

            // Add active class to monthly, remove from yearly
            monthlyLabel.classList.add('active');
            yearlyLabel.classList.remove('active');
        } else if (yearlyRadio.checked) {
            // Show yearly boxes, hide monthly boxes
            monthlyBoxes.forEach(box => box.style.display = 'none');
            yearlyBoxes.forEach(box => box.style.display = 'block');

            // Add active class to yearly, remove from monthly
            yearlyLabel.classList.add('active');
            monthlyLabel.classList.remove('active');
        }
    }

    // Add event listeners to both radio buttons
    monthlyRadio.addEventListener('change', togglePriceBoxes);
    yearlyRadio.addEventListener('change', togglePriceBoxes);

    // Initial toggle based on the default selection
    togglePriceBoxes();
});





/**
 * This script handles the 6-digit Multi-Factor Authentication (MFA) code input process.
 * It ensures that the user can only enter numeric values, automatically moves the focus
 * to the next field upon entry, supports pasting the full code, and submits the form when
 * all fields are filled.
 */

document.addEventListener('DOMContentLoaded', function () {
    const inputs = document.querySelectorAll('#mfa_form input[type="number"]');
    const form = document.getElementById('mfa_form');

    /**
     * Prevents non-digit characters from being entered in input fields.
     *
     * @param {Event} event - The keypress event triggered when the user types a character.
     */
    function onlyDigits(event) {
        const charCode = event.which ? event.which : event.keyCode;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }

    /**
     * Checks if all input fields are filled with exactly one digit each.
     * If all fields are filled, the form is submitted automatically.
     */
    function checkAndSubmit() {
        let code = '';
        inputs.forEach(input => {
            code += input.value;
        });
        if (code.length === 6) {
            form.submit();
        }
    }

    /**
     * Adds event listeners to each input field for handling input events, digit validation,
     * focus shift, and paste functionality.
     */
    inputs.forEach((input, index) => {
        /**
         * Handles input events on each field.
         * Moves focus to the next field after a digit is entered, and checks for paste cases.
         *
         * @param {Event} event - The input event triggered when the user types in the input.
         */
        input.addEventListener('input', function (event) {
            const value = event.target.value;
            if (value.length === 1) {
                if (index < inputs.length - 1) {
                    inputs[index + 1].focus(); // Move to the next field
                }
            } else if (value.length > 1) {
                // If multiple characters are pasted
                const values = value.split('');
                for (let i = 0; i < values.length && index + i < inputs.length; i++) {
                    inputs[index + i].value = values[i];
                    if (index + i < inputs.length - 1) {
                        inputs[index + i + 1].focus();
                    }
                }
            }
            checkAndSubmit(); // Check if all fields are filled
        });

        /**
         * Ensures that only numeric characters are allowed in the input fields.
         */
        input.addEventListener('keypress', onlyDigits);

        /**
         * Handles backspace behavior. Moves focus to the previous field if backspace is pressed and the field is empty.
         *
         * @param {Event} event - The keydown event triggered when the user presses a key.
         */
        input.addEventListener('keydown', function (event) {
            if (event.key === 'Backspace' && input.value === '' && index > 0) {
                inputs[index - 1].focus();
            }
        });
    });

    /**
     * Adds support for pasting a 6-digit code directly into the first input field.
     * The pasted code is split into the individual fields and the form is checked for completion.
     *
     * @param {Event} event - The paste event triggered when the user pastes content.
     */
    inputs[0].addEventListener('paste', function (event) {
        const paste = event.clipboardData.getData('text');
        if (/^\d{6}$/.test(paste)) {
            const values = paste.split('');
            inputs.forEach((input, i) => {
                input.value = values[i];
            });
            checkAndSubmit(); // Check if all fields are filled
        }
        event.preventDefault(); // Prevent the default paste behavior
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