/**
 * Created by V. Kamenskyi on 20.04.2017.
 */
({
    doInit : function (cmp, helper) {
        helper.switchVariant(cmp);
    },

    switchVariant : function (cmp) {
        var className = cmp.get('v.sldsModalClass');
        switch (cmp.get('v.variant')) {
            case 'large' :
                cmp.set('v.sldsModalClass', className + ' slds-modal--large');
                break;
        }
    },

    handleScrollToBottom : function (cmp, helper) {
        var bodyCmp = cmp.get('v.modalContent');
        var action = cmp.get('v.onScrollToBottom');
        if (bodyCmp && typeof bodyCmp[action] === 'function') {
            bodyCmp[action]();
        }
    },

    cancel : function (cmp, event, helper) {
        cmp.getEvent('oncancel').fire();
        cmp.find('search').set('v.value', '');
        cmp.set('v.visible', false);
    }
})