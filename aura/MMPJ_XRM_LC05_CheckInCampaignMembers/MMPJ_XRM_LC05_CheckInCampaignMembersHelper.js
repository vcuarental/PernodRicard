({
    getCampaignInfos : function(component, event, helper, campaignId) {
        
        const action = component.get("c.fetchCampaignInfos");
        action.setParams({
            'campaignId': campaignId
        });
        action.setCallback(this, function(response) {
            console.log('Début réponse');
            const state = response.getState();
            if (state === "SUCCESS") {
                const campaign = response.getReturnValue();
                campaign.NbInscrits = 0;
                campaign.NbPresents = 0;
                const campaignMembers = [];
                const contactIds = [];
                 
                
                if (campaign.CampaignMembers) {
                    for (let i = 0; i < campaign.CampaignMembers.length; i++) {
                        contactIds.push(campaign.CampaignMembers[i].ContactId);
                    }
                    helper.getSocietesInfos(component, contactIds).then(function(res) {
                        const mapSocietesByContactId = new Map();
                        if (res) {
                            for (let i = 0; i < res.length; i++) {
                                if (mapSocietesByContactId.get(res[i].MMPJ_Ext_Vign_Contact__c)) {
                                    let listSocietes = mapSocietesByContactId.get(res[i].MMPJ_Ext_Vign_Contact__c);
                                    listSocietes.push(res[i].MMPJ_Ext_Vign_Societe__r);
                                    mapSocietesByContactId.set(res[i].MMPJ_Ext_Vign_Contact__c, listSocietes);
                                } else {
                                    mapSocietesByContactId.set(res[i].MMPJ_Ext_Vign_Contact__c, [res[i].MMPJ_Ext_Vign_Societe__r]);
                                }
                            }
                        }

                        for (let i = 0; i < campaign.CampaignMembers.length; i++) { 
                            let campaignMember = campaign.CampaignMembers[i];
                            if (campaignMember.Contact) {
                                campaignMember.Mobile = campaignMember.Contact.MMPJ_Ext_Vign_Telephone_portable_perso__c;
                                campaignMember.MMPJ_Ext_Vign_Telephone_fixe__c = campaignMember.Contact.MMPJ_Ext_Vign_Telephone_fixe__c
                            }
                            campaignMember.Accompagnateurs = campaignMember.MMPJ_Ext_Accompagnants__c; 
                            campaignMember.MMPJ_Ext_Vign_Participation = campaignMember.MMPJ_Ext_Vign_Participation__c;

                            campaignMember.provenanceIconName = 'utility:outbound_call';
                            campaignMember.provenanceIconLabel = 'outbound_call';

                            if (campaignMember.MMPJ_Ext_Vign_Presence__c === 'Venu') {
                                campaign.NbPresents += 1;
                                //le nombre d'accompagnant  = contact + ceux qui l'accompagnent
                                if(campaignMember.MMPJ_Ext_Accompagnants__c != null && campaignMember.MMPJ_Ext_Accompagnants__c != undefined){
                                    campaign.NbPresents += campaignMember.MMPJ_Ext_Accompagnants__c;
                                }
                                
                                campaignMember.isHere = true;
                                campaignMember.variantValue = 'Success';
                                campaignMember.imageValue = 'utility:check';
                                campaignMember.labelValue = 'Yes';
                                
                            } else {
                                campaignMember.isHere = false;
                                campaignMember.variantValue = 'Destructive';
                                campaignMember.imageValue = 'utility:close';
                                campaignMember.labelValue = 'No';     
                            } 

                            if(campaignMember.MMPJ_Ext_Vign_Participation === 'Accepté'){
                                campaign.NbInscrits += 1;
                                if(campaignMember.MMPJ_Ext_Accompagnants__c != null && campaignMember.MMPJ_Ext_Accompagnants__c != undefined){	
                                    campaign.NbInscrits += campaignMember.MMPJ_Ext_Accompagnants__c;
                                }	
                            }
                            //lorsque le contact n’a pas de société, erreur va se générer: attente de la réponse du client 
                            //désormais la société qui s'affiche, c'est la société associé au campaign member 
                            //et plus la concaténation des noms des sociétés
                            if(campaignMember.MMPJ_XRM_Societe__c != null){
                               campaignMember.Societes = campaignMember.MMPJ_XRM_Societe__r.Name; 
                            }
                            campaignMember.SocieteOwners = campaignMember.MMPJ_XRM_Responsable_Societe__c 
                            campaignMember.Codes = campaignMember.MMPJ_XRM_Code_Spirit__c;

                            if(helper.detectMobile()){
                                if(campaignMember.Codes != null && campaignMember.Codes != undefined){
                                    campaignMember.Societes += ' '+ campaignMember.Codes;
                                }  
                            }
                            /* if (campaignMember.ContactId) {
                                let societes = mapSocietesByContactId.get(campaignMember.ContactId);
                                if (societes) {
                                    for (let i = 0; i < societes.length; i++) {
                                       /* if(campaignMember.Societes == null ||
                                            campaignMember.Societes == undefined ||
                                            campaignMember.Societes == ''){
                                                 if (societes[i] && societes[i].Name) {
                                                //campaignMember.Societes = campaignMember.Societes ? campaignMember.Societes + '/' + societes[i].Name : societes[i].Name;
                                                }
                                        if (societes[i] && societes[i].MMPJ_Ext_Vign_SOCIETE_Spirit__c) {
                                            campaignMember.Codes = campaignMember.Codes ? campaignMember.Codes + '/' + societes[i].MMPJ_Ext_Vign_SOCIETE_Spirit__c : societes[i].MMPJ_Ext_Vign_SOCIETE_Spirit__c;
                                        }

                                        if (societes[i] && (!campaignMember.SocieteOwners || campaignMember.SocieteOwners.indexOf(societes[i].Owner.Name) === -1)) {
                                            campaignMember.SocieteOwners = campaignMember.SocieteOwners ? campaignMember.SocieteOwners + '/' + societes[i].Owner.Name : societes[i].Owner.Name ;
                                        }
                                        if(helper.detectMobile()){
                                            if (societes[i] && societes[i].Name) {
                                                   // campaignMember.Societes = campaignMember.Societes ? campaignMember.Societes + '/' + societes[i].Name : societes[i].Name;
                                                    if (campaignMember.Codes != null && societes[i].MMPJ_Ext_Vign_Societe_Segmentation__c == 'Cognac' && societes[i].MMPJ_Ext_Vign_SOCIETE_Spirit__c != null) {
                                                        campaignMember.Societes += ' ' + societes[i].MMPJ_Ext_Vign_SOCIETE_Spirit__c;	
                                                    }
                                                
                                                }
                                            }
                                    }
                                }
                            }*/
                        
                            campaignMembers.push(campaignMember);
                        }
                      
                        component.set("v.campaign", campaign);
                        component.set("v.campaignMembers", campaignMembers);
                        component.set("v.campaignMembersFiltered",campaignMembers.slice(0, 50));

                        if (component.get("v.showOnlyParticipantsMembers")) {
                            helper.showOnlyParticipantsMembers(component);
                            
                        }
                        helper.sortCampaignMembers(component, helper);
                    });
                } else {
                    component.set("v.campaign", campaign);
                    component.set("v.campaignMembers", campaignMembers);
                    component.set("v.campaignMembersFiltered", campaignMembers);
                    
                    
                }
                      
               
            }
           
        });
        $A.enqueueAction(action);
    },

    getSocietesInfos: function(component, contactIds) {

        const action = component.get("c.fetchSocietesInfos");
        action.setParams({
            'contactIds': contactIds
        });
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                    
                } else {
                    reject(new Error(response.getError()));
                }
            });
            $A.enqueueAction(action);
        });
        
    },

    sortData : function(component,fieldName,sortDirection, helper){
        var data = component.get("v.campaignMembersFiltered");
        var searchValue = component.get('v.SearchKeyWord') ||'';
        /*if(searchValue.length<3){
            data = component.get('v.campaignMembers');
        }*/
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;

        // to handel text type fields
        data.sort(function(a,b){
            var a = key(a) ? key(a) : '';//To handle null values , uppercase records during sorting
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        
        var setRows = []
        for(var i = 0; i<data.length; i++){
            if(data[i].MMPJ_Ext_Vign_Participation__c != 'Accepté'){
                setRows.push(data[i].Id);
            }
        }
        if(searchValue.length<3){
            data = data.slice(0,50);
        }
        
        //set sorted data to accountData attribute
        component.set("v.campaignMembersFiltered",data);
        component.set('v.selectedRows', setRows);
        
        
    },

    sortCampaignMembers: function(component, helper) {
        component.set("v.sortBy",'labelValue');
        component.set("v.sortDirection",'asc');
        
        helper.sortData(component,'labelValue','asc');
    },

    searchHelper : function(component, event, getInputkeyWord) {
        let showOnlyParticipantsMembers = component.get("v.showOnlyParticipantsMembers");
        let campaignMembersTotal = showOnlyParticipantsMembers ? component.get("v.campaignMembers").filter(cm => cm.MMPJ_Ext_Vign_Participation === 'Accepté') : component.get("v.campaignMembers");
        let campaignMembersFiltered = [];

        if(campaignMembersTotal && campaignMembersTotal.length > 0)
        {
            getInputkeyWord = getInputkeyWord || '';
            const getInputkeyWordLowerCase = getInputkeyWord.toLowerCase();

            for (let i = 0; i < campaignMembersTotal.length; i++) { 
                let campaignMember = campaignMembersTotal[i];
                if (
                    
                    (campaignMember.LastName + ' '+campaignMember.FirstName).toLowerCase().includes(getInputkeyWordLowerCase) ||
                    campaignMember.LastName.toLowerCase().indexOf(getInputkeyWordLowerCase) !== -1 ||
                    (campaignMember.Societes && campaignMember.Societes.toLowerCase().indexOf(getInputkeyWordLowerCase) !== -1)
                ) {
                    campaignMembersFiltered.push(campaignMember);
                }
            }

            component.set("v.campaignMembersFiltered", campaignMembersFiltered.slice(0,100));
            
        }
    },

    updateCampaignMember: function(component, helper, campaignMember) {
        const action = component.get("c.updateCampaignMember");

        action.setParams({
            'campaignMemberId': campaignMember.Id,
            'campaignMemberIsHere': !campaignMember.isHere
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                campaignMember.isHere = !campaignMember.isHere;
                const campaign = component.get("v.campaign");
                const campaignMembersFiltered = component.get("v.campaignMembersFiltered");
                // Mise à jour des CampaignMembers filtrés
                campaignMembersFiltered.forEach(function(element) {
                    if (element.Id === campaignMember.Id) {
                        campaign.NbPresents += !campaignMember.isHere ? -1 : 1;
                        campaign.NbInscrits += element.MMPJ_Ext_Vign_Participation !== 'Accepté' ? 1 : 0;
                        if (campaignMember.isHere) {
                            element.MMPJ_Ext_Vign_Presence__c = 'Venu';
                            element.variantValue = 'Success';
                            element.imageValue = 'utility:check';
                            element.labelValue = 'Yes';
                            element.isHere = true;
                           
                        } else {
                            element.MMPJ_Ext_Vign_Presence__c = 'Non venu';
                            element.variantValue = 'Destructive';
                            element.imageValue = 'utility:close';
                            element.labelValue = 'No';
                            element.isHere = false;
                           
                        }

                      /*if (element.MMPJ_Ext_Vign_Participation !== 'Accepté' && campaignMember.isHere) {
                            element.MMPJ_Ext_Vign_Participation = 'Accepté';
                        }*/
                    }
                });
               
                component.set("v.campaign", campaign);
                component.set("v.campaignMembersFiltered", campaignMembersFiltered);

                // Mise à jour des CampaignMembers initiaux
                const campaignMembers = component.get("v.campaignMembers");
                campaignMembers.forEach(function(element) {
                    if (element.Id === campaignMember.Id) {

                        if (campaignMember.isHere) {
                            element.MMPJ_Ext_Vign_Presence__c = 'Venu';
                            element.imageValue = 'utility:check';
                            element.variantValue = 'Success';
                            element.labelValue = 'Yes';
                            element.isHere = true;
                        } else {
                            element.MMPJ_Ext_Vign_Presence__c = 'Non venu';
                            element.imageValue = 'utility:close';
                            element.variantValue = 'Destructive';
                            element.labelValue = 'No';
                            element.isHere = false;
                        }

                      /* if (element.MMPJ_Ext_Vign_Participation !== 'Accepté' && campaignMember.isHere) {
                            element.MMPJ_Ext_Vign_Participation = 'Accepté';
                        }*/
                    }
                });
                component.set("v.campaignMembers", campaignMembers);
               
                //helper.sortCampaignMembers(component, helper);
                //$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },

    showOnlyParticipantsMembers: function(component) {
        const campaignMembersFiltered = component.get("v.campaignMembersFiltered");
        const campaignMembersFilteredUpdated = [];
        const campaignMembersWhoRefused = []; 
        if (campaignMembersFiltered) {
            for (let i = 0; i < campaignMembersFiltered.length; i++) {
                if (campaignMembersFiltered[i].MMPJ_Ext_Vign_Participation === 'Accepté') {
                    campaignMembersFilteredUpdated.push(campaignMembersFiltered[i]);
                } 
            }
        }
        component.set("v.campaignMembersFiltered", campaignMembersFilteredUpdated); 
        
        
    },
    detectMobile: function() {
        
        if ( navigator.userAgent.match(/Android/i)
            || navigator.userAgent.match(/webOS/i)
            || navigator.userAgent.match(/iPhone/i)
            || navigator.userAgent.match(/iPad/i)
            || navigator.userAgent.match(/iPod/i)
            || navigator.userAgent.match(/BlackBerry/i)
            || navigator.userAgent.match(/Windows Phone/i)
        ) {
            return !(
                window.innerWidth >= 500
                && window.innerWidth <= 800
            )
        } else {
            return window.innerWidth <= 800 && window.innerHeight <= 600
        }
    }
    
})