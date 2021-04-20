/**
 * Created by V. Kamenskyi on 12.04.2017.
 */
({
    oninit : function (cmp, event, helper) {
        helper.doInit(cmp, helper);
    },

    onscroll : function (cmp, event, helper) {
        if (event.target.scrollHeight - event.target.scrollTop - 50 <= event.target.offsetHeight) {
            helper.handleScrollToBottom(cmp, helper);
        }
    },

    oncancel : function (cmp, event, helper) {
        helper.cancel(cmp, event, helper);
    },

    onsave : function (cmp, event, helper) {
        var evt = cmp.getEvent('onsave');
        evt.setParams({'who': cmp.getLocalId(), 'data':cmp.get('v.modalContent'), 'returnValue':cmp.get('v.data')});
        evt.fire();
        cmp.find('search').set('v.value', '');
        cmp.set('v.visible', false);
    },

    onsearch : function (cmp, event, helper) {
        var val = event.getSource().get('v.value') || '';
        val = val.replace(/[\[\]\/{}()*+?.\\^$|]+/g, "");
        var reg = RegExp(val.split('').join('[\\w\\W]*').replace('+', "\\+"), 'i');
        var items = cmp.get('v.modalContent').find('iteration').get('v.body');
        for (let i = 0; i < items.length; i++) {
            items[i].set('v.class', items[i].get('v.body')[0].get('v.title').search(reg) < 0 ? 'slds-hide' : 'slds-p-around--small');
        }
    },

    handleValidityChange : function (cmp, event, helper) {
        var validity = cmp.get('v.validity');
        if (validity) {
            let errors = [];
            for (let key in validity) {
                if (!validity[key]) {
                    errors.push(key);
                }
            }
            cmp.set('v.errors', errors);
        }
    },
    
    onkeyup : function (cmp, event, helper) {
        switch (event.key) {
            case 'Escape':
                helper.cancel(cmp, event, helper);
                break;
            default: break;
        }
    }
})