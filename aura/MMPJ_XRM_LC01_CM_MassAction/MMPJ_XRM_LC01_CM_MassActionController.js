({
    doInit : function(component, event, helper) {
        var pageReference = component.get('v.pageReference');
        
        if(pageReference && pageReference.state ){
            console.log(JSON.stringify(pageReference.state));
            component.set('v.recordId',pageReference.state.c__recordId);
            component.set('v.isAllRecordPage',true);
            
        }else{
            component.set('v.currentRowsLimit',10);
        }
        console.log(component.get('v.recordId'));
        var action = component.get('c.getStatusValues');
        
        action.setCallback(this, function (response){
            if(response.getState() === "SUCCESS"){
                component.set("v.statusValues", response.getReturnValue());
            }
            else{
                alert(response.getState());
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get('c.getRecordTypeMYPJCampaign');
        action.setParams({
            "campaignId" : component.get('v.recordId')
        });
        action.setCallback(this, function (response){
            if(response.getState() === "SUCCESS"){
                component.set("v.isMYPJCampaign", response.getReturnValue());
               
            }
            else{
                alert(response.getState());
            }
        });
        $A.enqueueAction(action);
        
        
        
        helper.refresh(component);
        
    },
    
    onCheck : function(component, event, helper){
        var campaignMemberId = event.getSource().get("v.name");
        var checkedCampaignMembers = component.get("v.checkedCampaignMembers");
        
        var indexOfCampaignMemberId = checkedCampaignMembers.indexOf(campaignMemberId);
        if(!(indexOfCampaignMemberId + 1)){
            checkedCampaignMembers.push(campaignMemberId);
        }
        else{
            checkedCampaignMembers.splice(indexOfCampaignMemberId, 1);
        }
    },
    
    selectAll : function(component){
        var compCM = component.find("checkboxCM");
        var checkedCampaignMembers = [];
        
        if(component.find("cbSelectAll").get("v.value")){
            var toSet = true;
        }
        else{
            var toSet = false;
        }
        
        if(compCM.length != undefined){
            for(var i=0; i<compCM.length;i++){
                compCM[i].set("v.value", toSet);
                checkedCampaignMembers.push(compCM[i].get("v.name"));
            }
            
            if(toSet){
                component.set("v.checkedCampaignMembers", checkedCampaignMembers);
            }
            else{
                component.set("v.checkedCampaignMembers", []);
            }
        }
    },
    
    viewAll : function(component, event, helper){
        var pageReference = {
            "type": 'standard__component',
            "attributes": {
                "componentName": 'c__MMPJ_XRM_LC01_CM_MassAction'
            },
            "state": {
                "c__recordId" : component.get('v.recordId')
            }
        };
        console.log(pageReference);
        const navService = component.find('navService');
        // event.preventDefault();        
        navService.navigate(pageReference);

        // helper.showCM(component);
    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    openModal : function(component, event, helper){
        component.set("v.isModalOpen", true);
    },

    openQuickAddModal: function(component, event, helper){
        component.set("v.isQuickAddModalOpen", true);
    },

    closeQuickAddModal: function(component, event, helper) {
        component.set("v.isQuickAddModalOpen", false);
        helper.refresh(component);
    },
    
    closeModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    majInvites: function(component, event, helper) {
        var checkedCampaignMembers = component.get("v.checkedCampaignMembers");
        var valStatus = component.find("selectStatus").get("v.value");
        console.log(valStatus);
        var valPresence = component.find("selectPresence").get("v.value");
        var valParticipation = component.find("selectParticipation").get("v.value"); 
        var valAccompagnant = component.find("selectAccompagnant").get("v.value"); 
        var valCommentaire = component.find("selectCommentaire").get("v.value"); 
        console.log('Accompagnant : '+valAccompagnant);
        console.log('valCommentaire : '+valCommentaire);
        var majInv = component.get('c.majPresenceParticipationInvites');
        
        majInv.setParams({
            "checkedCampaignMembers" : checkedCampaignMembers,
            "valStatus" : valStatus,
            "valPresence" : valPresence,
            "valParticipation" : valParticipation,
            "valAccompagnant" : valAccompagnant,
            "valCommentaire" : valCommentaire
        });
        
        majInv.setCallback(this, function (response){
            if(response.getState() === "SUCCESS"){
                var nbCheckedCampaignMembers = Object.keys(checkedCampaignMembers).length;
                component.set("v.isModalOpen", false);
                
                if(nbCheckedCampaignMembers > 0){
                    var toastEvent = $A.get("e.force:showToast");
                    switch(nbCheckedCampaignMembers){
                        case 1 :
                            var msg = nbCheckedCampaignMembers + " membre de la campagne a été mis à jour !";
                            break;
                        default:
                            var msg = nbCheckedCampaignMembers + " membres de la campagne ont été mis à jour !";
                    }
                    toastEvent.setParams({
                        title: "Mise à jour effectuée !",
                        message: msg,
                        type: "success"
                    });
                    toastEvent.fire();
                    
                }
                
                helper.refresh(component);
            }
            else{
                alert(response.getState());
            }
        });
        $A.enqueueAction(majInv);
    },
    
    deleteCM: function(component, event, helper) {
        var checkedCampaignMembers = component.get("v.checkedCampaignMembers");       
        var deleteCMAction = component.get('c.deleteCM_Apex');
        
        deleteCMAction.setParams({
            "checkedCampaignMembers" : checkedCampaignMembers
        });
        
        deleteCMAction.setCallback(this, function (response){
            console.log("response : " + response.getState());
            if(response.getState() === "SUCCESS"){
                var nbCheckedCampaignMembers = Object.keys(checkedCampaignMembers).length;component.set("v.isModalOpen", false);
                
                if(nbCheckedCampaignMembers > 0){
                    var toastEvent = $A.get("e.force:showToast");
                    switch(nbCheckedCampaignMembers){
                        case 1 :
                            var msg = nbCheckedCampaignMembers + " membre de la campagne a été supprimé !";
                            break;
                        default:
                            var msg = nbCheckedCampaignMembers + " membres de la campagne ont été supprimés !";
                    }
                    toastEvent.setParams({
                        title: "Suppression effectuée !",
                        message: msg,
                        type: "success"
                    });
                    toastEvent.fire();
                    
                }
                
                helper.refresh(component);
            }
            else{
                alert(response.getState());
            }
            
        });
        $A.enqueueAction(deleteCMAction);
    },
    
    navigateToCampaignMember : function (component, event, helper) {
        
        var campaignMemberContactId = event.getSource().get("v.name");
       /* var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
                "recordId": campaignMemberContactId,
            "slideDevName": "related"
        });
        navEvt.fire();**/
         window.open("/lightning/r/Contact/" + campaignMemberContactId+ "/view","_blank");

    },
    
    navigateToSociete :function (component, event, helper) {
        
        var societeId = event.getSource().get("v.name");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": societeId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },

    openQuickSendSMS : function(component,event,helper){
        component.set('v.isQuickSendSMSOpen',true);
    },

    handleCloseSendSMSModal : function(component,event,helper){
        component.set('v.isQuickSendSMSOpen', false);
    },

    handleChangeFilters : function(component,event,helper){
        
        var cMembers = component.get('v.campaignMembers');
        var filters = component.get('v.filters');

        var cMemberFilterValue = component.find('fullNameFilter').get('v.value') || '';
        var oldSearch = filters.fullName;
        filters.fullName = cMemberFilterValue;
        component.set('v.filters',filters);
        console.log(oldSearch +' = '+cMemberFilterValue);
        if(cMemberFilterValue!=oldSearch && cMemberFilterValue.length<3 && oldSearch.length<3){
            return;
        }
        component.set('v.campaignMembersFiltered', []);
        
        var filteredCMembers = cMembers.filter(cm => 
            (filters.fullName.toLowerCase().length <3 ||(cm.FirstName + ' '+cm.LastName).toLowerCase().includes(filters.fullName.toLowerCase()))
            && (filters.participation==='' || cm.MMPJ_Ext_Vign_Participation__c===filters.participation)
            && (filters.presence==='' || cm.MMPJ_Ext_Vign_Presence__c===filters.presence)
            && (filters.status==='' || cm.Status===filters.status)    
        );
        console.log(JSON.stringify(filteredCMembers));
        component.get('v.isAllRecordPage')?component.set('v.currentRowsLimit',50):component.set('v.currentRowsLimit',10);
        component.set('v.campaignMembersFiltered', filteredCMembers);
    },

    handleSeeMoreData : function(component,event,helper){
        let rowLimit = component.get('v.currentRowsLimit');
        rowLimit += 50;
        component.set('v.currentRowsLimit',rowLimit);
    },
    handleReturn: function(component, event, helper) {
        window.history.back();
       $A.get('e.force:refreshView').fire();
    },
});