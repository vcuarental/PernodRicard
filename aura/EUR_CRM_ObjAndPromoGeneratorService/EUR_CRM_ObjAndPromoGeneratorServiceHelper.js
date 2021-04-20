({
    setCallbacks : function (cmp, helper) {
        cmp.set('v.onDeleteSuccess', helper.onDeleteSuccess);
        cmp.set('v.onDeleteIncomplete', helper.onDeleteIncomplete);
        cmp.set('v.onDeleteError', helper.onDeleteError);
    },

    onDeleteSuccess : function (cmp) {
        cmp.set('v.isReady', true);
        ltngService.showToast({'type':'success','title':'Success!','message':'{0} has been successfully deleted'.replace('{0}', cmp.get('v.animation.Name'))});
        var evt = $A.get('e.force:navigateToURL');
        evt.setParams({
            'url' : window.location.protocol + '//' + window.location.host + '/one/one.app#/sObject/Animation__c/list?filterName=Recent'
        });
        evt.fire();
    },

    onDeleteIncomplete : function (cmp) {
        cmp.set('v.isReady', true);
        ltngService.showToast({'type':'warning','title':'Warning!','message':'Error occurred during {0} delete'.replace('{0}', cmp.get('v.animation.Name'))});
    },
    onDeleteError : function (cmp) {
        cmp.set('v.isReady', true);
        ltngService.showToast({'type':'warning','title':'Warning!','message':'Error occurred during {0} delete'.replace('{0}', cmp.get('v.animation.Name'))});
    },

    showModalDialog : function (cmp, helper, attrName, modalParams, onsave, oncancel) {
        var ctx = cmp.get('v.context');
        if (!$A.util.isEmpty(ctx) && attrName) {
            $A.createComponent('c:modal', modalParams, function (newModal, status, errorMessage) {
                if (status === 'SUCCESS') {
                    newModal.addEventHandler('onsave', onsave || function () {});
                    newModal.addEventHandler('oncancel', oncancel || function () {});
                    ctx.cmp.set('v.' + attrName, newModal);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        }
    }
});