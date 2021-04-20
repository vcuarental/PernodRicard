({
    doInit : function(component, event, helper) {
        console.log('doInit*');
        helper.showModal(component);
    },
    
    close : function(component, event, helper) {
        console.log('close');
        helper.close(component);
    },
    
    showModal : function(component, event, helper) {
        helper.showModal(component);
    },
    
    addImage : function(component, event, helper) {
        helper.addImage(component);
    },
    
    deleteImage : function(component, event, helper) {
        helper.deleteImage(component, event, helper, component.get("v.recordId"));
    },
    
    handleUploadFinished : function(component, event, helper) {
        console.log('handleUploadFinished');
        console.log("files : ", event.getParam("files")[0].documentId);
        if(event.getParam("files")[0] != undefined){
            helper.updateContentDocumentTitle(component, event, helper, event.getParam("files")[0].documentId);
        }
        var appEvent = $A.get("e.c:RefreshImage");
        appEvent.fire();
        //keep this to close the modal after image added
        $A.get("e.force:closeQuickAction").fire();
    },
    
});