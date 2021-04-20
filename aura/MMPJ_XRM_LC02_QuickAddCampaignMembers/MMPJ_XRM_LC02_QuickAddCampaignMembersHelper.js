({
    searchHelper : function(component,event,getInputkeyWord) {
        var returnList = [];
        var reformatedList = [];
        var action = component.get("c.fetchSocieteContactFinal");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'contactIds' : component.get("v.contactIds"),
            'campaignId': component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success fetching contacts');
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'Aucun résultat ...');
                } else {
                    component.set("v.Message", 'Resultat de la recherche ...');
                }
                component.set("v.searchResVisible", true);

                /*var iCouleur = 0;
                var tCouleurs=['#'];*/
                var j = 0;
                if(storeResponse.length > 0) 
                {
                    component.set("v.listOfSearchRecords", storeResponse);
                  
                    //console.log( component.find("societiesPicklist").get("v.value"));
                   /* if(storeResponse[0].societeParDefaut != null && storeResponse[0].societeParDefaut != undefined
                        && storeResponse[0].societeParDefaut != ''){
                            component.set('v.nomDelaSociete', storeResponse[0].societeParDefaut); 
                        }
                   */
                    /* for(var i=0; i<storeResponse.length; i++)
                    {
                        if(returnList[j] != undefined && returnList[j].MMPJ_Ext_Vign_Contact__r != undefined && returnList[j].MMPJ_Ext_Vign_Contact__r.Id != undefined){

                            if(storeResponse[i].MMPJ_Ext_Vign_Contact__r.Id === returnList[j].MMPJ_Ext_Vign_Contact__r.Id){
                                if(returnList[j].MMPJ_Ext_Vign_Societe__r.Name != undefined){
                                    returnList[j].MMPJ_Ext_Vign_Societe__r.Name += ' / ' + storeResponse[i].MMPJ_Ext_Vign_Societe__r.Name;
                                }
                                else{
                                    returnList[j].MMPJ_Ext_Vign_Societe__r.Name = storeResponse[i].MMPJ_Ext_Vign_Societe__r.Name;
                                }
                            }
                            else{
                                j++;
                                returnList[j] = storeResponse[i];
                            }
                        }
                        else{
                            returnList[j] = storeResponse[i];
                        }
                    } */
                }
                //returnList[i] ; Pourquoi ????

            } else {
                console.log('error fetching contacts'); 
            }
        });
        $A.enqueueAction(action);


        /* var action2 = component.get("c.fetchContact");
        action2.setParams({
            'searchKeyWord': getInputkeyWord
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.searchResVisible", true);
                var returnListSocContLength = returnList.length;
                if(storeResponse.length > 0)
                {
                    var contactAlreadyInList = [];
                    for(var i=0; i < storeResponse.length; i++){
                        //if(!this.alreadyInReturnList(storeResponse[i], returnList)){
                        if(!this.alreadyInReturnList(storeResponse[i], contactAlreadyInList)){
                            returnList[i + returnListSocContLength] = storeResponse[i];
                            contactAlreadyInList.push(storeResponse[i].id);
                        }
                    }
                }
            }
            reformatedList = this.reformat(returnList);
            //component.set("v.listOfSearchRecords", reformatedList);
            this.setAlreadyCampaignMembers(component, reformatedList);
        });
        $A.enqueueAction(action2); */

    },

    reformat : function(returnList){
        var reformatedList = [];
        for(var i=0; i<returnList.length;i++){
            //if societe-contact
            if(returnList[i] != undefined && ('MMPJ_Ext_Vign_Contact__c' in returnList[i])){
                reformatedList.push({'alreadyCM' : false, 'contactId' : returnList[i].MMPJ_Ext_Vign_Contact__r['Id'], 'contactName' : returnList[i].MMPJ_Ext_Vign_Contact__r['Name'], 'listSocieteName' : returnList[i].MMPJ_Ext_Vign_Societe__r['listSocieteName']});
                
            }
            //MMPJ_XRM_Societe__r.Name

            //if contact without societe
            else if(returnList[i] != undefined && ('Name' in returnList[i])){
                reformatedList.push({'alreadyCM' : false, 'contactId' : returnList[i]['Id'], 'contactName' : returnList[i]['Name'],  'listSocieteName' : []});
            }
        }
       
        return reformatedList;
    },

    setAlreadyCampaignMembers : function(component, reformatedList){
        //get Ids of current campaign campaign members
        var action = component.get("c.getCampaignMembers");

        action.setParams({
            recordId : component.get("v.recordId"),
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //storeResponse : Ids of current campaign campaign members
                var storeResponse = response.getReturnValue();
                //if contacts in campaign members we set alreadyCM to true
                if(reformatedList.length > 0)
                {
                    for(var i=0; i < reformatedList.length; i++){
                        if(storeResponse.indexOf(reformatedList[i].contactId) > -1){
                            reformatedList[i].alreadyCM = true;
                        }
                    }
                }
            }
           
            component.set("v.listOfSearchRecords", reformatedList);
        });
        $A.enqueueAction(action);
    },

    alreadyInReturnList : function(contactToTest, contactAlreadyInList){

        return (contactAlreadyInList != 'undefined' && contactAlreadyInList.includes(contactToTest.Id)) ? true : false;
        // if(returnList != 'undefined'){
        //     for (var i=0; i<returnList.length;i++){

        //         if(contactToTest.Id === returnList[i].MMPJ_Ext_Vign_Contact__c){
        //             return true;
        //         }
        //     }
        // }
        //return false;
    },

    // function for clear the Record Selection
    clear :function(component,event){
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
    },

    onCloseBtnClick : function(component) {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire()
    },

    AddCampaignMemberHelper : function(component,event,contactId,recName, societeParDefaut) {
        var action = component.get("c.addCampaignMemberApex");
        action.setParams({
            'contactId': contactId,
            'campaignId': component.get("v.recordId"),
            'isCheckIn':  component.get("v.isCheckIn"), 
            'societeId':societeParDefaut
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                component.set("v.campaignMemberName", recName);
                component.set("v.notifVisible", true);
                component.set("v.searchResVisible", false);
                setTimeout(()=>{
                    component.set("v.notifVisible", false);
                }, 2000);
            }
        });

        $A.enqueueAction(action);
    },

    getCampaignMemberIds: function(component) {
        var action = component.get("c.getCampaignMembers");
        action.setParams({
            'campaignId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
               
                component.set("v.contactIds", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getIfCampIsMypj: function(component) {
        var action = component.get("c.isMypjCampaign");
        action.setParams({
            'pCampaignId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isMypj", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})