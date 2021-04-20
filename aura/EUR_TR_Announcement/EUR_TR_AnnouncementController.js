({
    handleInit: function (component, event, helper) {
        var action = component.get('c.getAnnouncementById');
        action.setParams({
            announcementId: component.get('v.AnnouncementId') });
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                component.set('v.announcement', result.getReturnValue());

                var fileAction = component.get('c.getFilesByLinkedEntityId');
                fileAction.setParams({
                    entityId: component.get('v.AnnouncementId') });
                fileAction.setCallback(this, function (fileResult) {
                    if (fileResult.getState() === 'SUCCESS') {
                        component.set('v.documents', fileResult.getReturnValue());
                    }
                });
                $A.enqueueAction(fileAction);
            }
        });
        $A.enqueueAction(action);
    }
})