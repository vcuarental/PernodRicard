({
    doInit: function (component, event, helper) {
        component.set('v.cssStyle', '<style>' +
            '.cuf-scroller-outside {' +
            'background: rgb(255, 255, 255) !important;' +
            '}' +
            '.cuf-content {' +
            'padding: 0 0rem !important;' +
            '}' +
            '.slds-p-around--medium {' +
            'padding: 0rem !important;' +
            '}' +
            '.slds-modal__content {' +
            'overflow-y: hidden !important;' +
            'height: unset !important;' +
            'max-height: unset !important;' +
            '}' +
            '</style>');
    },
});