/**
 * Created by V. Kamenskyi on 19.09.2017.
 */
({
    handleScriptsLoaded : function (cmp, event, helper) {
        helper.setRecords(cmp, helper);
    },

    setRecords : function (cmp, event, helper) {
        cmp.set('v.records', helper.mapRecords(cmp, event.getParam('arguments').records || []));
    },

    handleCtrlBtnClick : function (cmp, event, helper) {
        var who = event.getSource().get('v.name');
        switch(who) {
            case 'add':
                helper.selectUsersOrGroups(cmp, helper);
                break;
        }
    },

    handleAddToShare : function (cmp, event, helper) {
        helper.addToShare(cmp, helper);
    },

    handleActionSelect : function (cmp, event, helper) {
        var who = event.getParam('value');
        var record = cmp.get('v.records')[event.getSource().get('v.name')];
        cmp.set('v.editRecordPos', event.getSource().get('v.name'));
        switch(who) {
            case 'edit':
                helper.showEditSharingDialog(cmp, helper, record);
                break;
            case 'delete':
                helper.deleteSharing(cmp, helper, record, event.getSource().get('v.name'));
                break;
        }
    },

    handleEditDialogConfirm : function (cmp, event, helper) {
        helper.updateSharing(cmp, helper);
    },
    
    navigateTo : function (cmp, event, helper) {
	    var navEvt = $A.get("e.force:navigateToSObject");
	    var selectedItem = event.currentTarget;
        var objId = selectedItem.dataset.id;
	    if(navEvt){
	    	navEvt.setParams({
		      "recordId": objId		     
		    });
		    navEvt.fire();
	    }
	},
     handleSearch : function (cmp, event, helper) {
        
        ltngService.runApex(cmp, helper, 'getSharingSubjects', {'searchTerm':cmp.get('v.searchTerm')}, (cmp, helper, response) => {
            var subjects = response.getReturnValue();
            var mapping = item => { return { 'name' : item.Id, 'label' : item.Name || item.Related.Name || '' } };
            subjects.users = (subjects.users || []).map(mapping);
            subjects.groups = (subjects.groups || []).map(mapping);
            subjects.roles = (subjects.roles || []).map(mapping);
            subjects.rolesAndSubordinates = (subjects.rolesAndSubordinates || []).map(mapping);
            cmp.set('v.subjects', subjects);  
         	var aud = cmp.find('addUsersDialog');
            if(aud){
                 aud.set('v.users',subjects.users);
                 aud.set('v.groups',subjects.groups);
                 aud.set('v.roles',subjects.roles);
                 aud.set('v.rolesAndSubordinates',subjects.rolesAndSubordinates);
                 aud.doSetRecords();
            }
         	
        });
    },
})