/**
 * Created by V. Kamenskyi on 27.02.2018.
 */
({
    onInit : function (cmp, event, helper) {
        helper.CalloutService = cmp.find('calloutService');
        helper.OverlayService = cmp.find('overlayLib');
        helper.DialogBuilder = helper.getClass(cmp, helper);
    },

    /**
     * Instantiates the DialogBuilder class
     *
     * @param cmp
     * @param event
     * @param helper
     * @returns {DialogBuilder} The instance of the builder.
     */
    getInstance : function (cmp, event, helper) {
        return new helper.DialogBuilder();
    },

    /**
     * Dialog actions' callback dispatcher
     *
     * @param cmp
     * @param event
     * @param helper
     * @private
     */
    _dispatchCallback : function (cmp, event, helper) {
        var actionName = event.getSource().get('v.name');
        cmp.get('v._actionsStorage.' + (actionName || '__default__'))();
        if (actionName === 'submit' || actionName === 'reject') {
            helper.closePopup(cmp, actionName);
        }
    }
})