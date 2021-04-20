({
    doInit: function(component, event, helper) {
        var actions = [
            { label: 'Appeler', name: 'lastName' },
       ];
        const columns = [
            {
                label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_CheckedIn}"),
                type: 'button',
                fieldName: 'labelValue',
                typeAttributes: {
                    iconName: {fieldName: 'imageValue'},
                    value: {fieldName: 'labelValue'},
                    name: 'update_presence',
                    variant: {fieldName: 'variantValue'}
                },
                sortable: true   
            },
            {label:  $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_Accompagnateurs}"), fieldName: 'MMPJ_Ext_Accompagnants__c', type: 'number', sortable: true, editable : true, cellAttributes: { alignment: 'left' }},
            {label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_LastName}"), fieldName: 'LastName', type: 'text', sortable: true },
            {label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_FirstName}"), fieldName: 'FirstName', type: 'text', sortable: true},
            {label:  $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_Company}"), fieldName: 'Societes', type: 'text', sortable: true}
        ];

        if (!helper.detectMobile()) { 
            //columns.push({label: 'Mobile', fieldName: 'Mobile', type: 'phone', sortable: true});
            columns.push({label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_Delivery_Code}"), fieldName: 'Codes', type: 'text', sortable: true});
            columns.push({label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_Company_Owner}"), fieldName: 'SocieteOwners', type: 'text', sortable: true});
        }

        //this button shows the modal containing the number of the campaign member (call the handleRowAction method)
        columns.push({
            label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen2_call}"),
            type: 'button',
            fieldName: 'provenanceIconLabel',
            typeAttributes: {
                iconName: { fieldName: 'provenanceIconName' },
                value: { fieldName: 'provenanceIconLabel' },
                name: 'lastName',
            },
            sortable: true
        }

        );

        component.set('v.columns', columns);
        const campaignId = component.get("v.recordId");
        helper.getCampaignInfos(component, event, helper, campaignId);

    },

    keyPressController : function(component, event, helper) {
        // get the search Input keyword
        const getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0, or user clicked on search picto, then open the lookup result List and
        // call the helper
        // else close the lookup result List part.
        if (
            (
                getInputkeyWord
                && getInputkeyWord.length > 2  
            )
        ) {
            helper.searchHelper(component,event,getInputkeyWord);
        } else {
            const showOnlyParticipantsMembers = component.get("v.showOnlyParticipantsMembers");
            const campaignMembers = showOnlyParticipantsMembers ? component.get("v.campaignMembers").filter(cm => cm.MMPJ_Ext_Vign_Participation === 'Accepté') : [];
            component.set("v.campaignMembersFiltered", campaignMembers);
        }
        helper.sortCampaignMembers(component, helper);
    },

    handleRowAction: function(component,event,helper) {
        const action = event.getParam('action');
        const campaignMember = event.getParam('row');
        switch (action.name) {
            case 'update_presence':
                helper.updateCampaignMember(component, helper, campaignMember);
                break;
            case 'lastName':
                //we show the modal when the campaign member has a phone number
                if((campaignMember.Mobile != null && 
                    campaignMember.Mobile != undefined) ||
                    campaignMember.Contact.MMPJ_Ext_Vign_Telephone_fixe__c != null &&
                    campaignMember.Contact.MMPJ_Ext_Vign_Telephone_fixe__c != undefined ){component.set('v.call', true);
                    
                    component.set('v.campaignMemberToShow', campaignMember);
	            } else {
                    component.set('v.noNumber', true);
                }
                break;
        }
    },

    //update the number of accompanist for a campaign member
    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        var action = cmp.get("c.updateCampaignMemberAccompNumber");
        action.setParams({"campaignMemb" : draftValues});
        action.setCallback(this, function(response) {
            //var state = response.getState(); 
            //$A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
        
    },
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    },

    showOnlyParticipantsMembers : function(component, event, helper) {
        console.log('showOnlyParticipants');
        component.set('v.campaignMembersFiltered', []);
        console.log('showOnlyParticipants');
        let getInputkeyWord = component.get("v.SearchKeyWord");
        helper.searchHelper(component,event,getInputkeyWord || '');
        helper.sortCampaignMembers(component, helper);
    },

    handleReturn: function(component, event, helper) {
        window.history.back();
    },

    openQuickAddModal: function(component, event, helper) {
        component.set("v.isQuickAddModalOpen", true);
    },

    closeQuickAddModal: function(component, event, helper) {
        component.set("v.isQuickAddModalOpen", false);
        const campaignId = component.get("v.recordId");
        helper.getCampaignInfos(component, event, helper, campaignId);
    },
    closeSecondModal: function (component, event, helper) {
        component.set("v.call", false);
    },
    closethirdModal : function(component, event, helper) {
        component.set("v.noNumber", false);
    }
})