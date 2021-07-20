import intlTelInput from 'intl-tel-input';
import utilsJs from 'intl-tel-input/build/js/utils'

$(document).on('turbolinks:load', function () {
    initPhoneNumberLib();
})

window.initPhoneNumberLib = function () {
    const input = document.querySelector('.phone-number-field'),
        errorMsg = document.querySelector(".number-error-msg");

    const _this = this

    // Verifying Phone Number

    if (input) {
        const iti = intlTelInput(input, {
            utilsScript: utilsJs,
            formatOnDisplay: false,
            separateDialCode: true
        });

        document.querySelector('.phone-number-form').addEventListener('submit', function () {
            setCountryCode(input, iti)
            return true
        })

        const errorMap = ["Invalid number", "Invalid country code", "Too short", "Too long", "Invalid number"];
        let reset = function() {
            input.classList.remove("error");
            errorMsg.innerHTML = "";
            errorMsg.classList.add("hide");
            jQuery('.phone-number-submit').removeAttr('disabled', 'disabled');
            jQuery('.phone-number-form').unbind();
        };

        input.addEventListener('blur', function() {
            reset();
            if (input.value.trim()) {
                if (!(iti.isValidNumber())) {
                    input.classList.add("error");
                    let errorCode = iti.getValidationError();
                    errorMsg.innerHTML = errorCode === -99 ? 'Invalid Phone Number' : errorMap[errorCode];
                    errorMsg.classList.remove("hide");
                    jQuery('.phone-number-submit').attr('disabled', 'disabled');
                    jQuery('.phone-number-form').bind('submit',function(e){e.preventDefault();});
                }
            }
        });
        input.addEventListener('change', reset);
        input.addEventListener('keyup', reset);
    }
}

function setCountryCode(input, iti) {
    let countrySelected = iti.getSelectedCountryData()
    if (countrySelected) {
        input.value = `+${countrySelected['dialCode']}${input.value}`
    }
}
