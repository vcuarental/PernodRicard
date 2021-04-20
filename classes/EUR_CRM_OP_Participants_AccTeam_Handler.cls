/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Class handler to Create Account Team for the Participants.
                This will give the participants Read/Write access to Accounts.
  @Author:      IPC
  @History:     OCT.23.2014 - Created
*/
public class EUR_CRM_OP_Participants_AccTeam_Handler{

    public static final Set<String> valid_OP_RecType = new Set<String>{'EUR_DE_Off_Trade_Trade_Fair'};
    /*************
    @ After Insert
    *************/
    public static void processObjPromoTradeFair_Insert(List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> objPromo_TradeFair){
        System.debug('***valid_OP_RecType: ' + valid_OP_RecType + '***objPromo_TradeFair: ' + objPromo_TradeFair);

        Id eventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('EUR_DE_Visitation_Event').getRecordTypeId();

        Set<Id> objPromoIds = new Set<Id>();

        // get all Objective / Promotion Ids
        for(EUR_CRM_ObjPromo_Trade_Fair_Participant__c opT :objPromo_TradeFair){
            objPromoIds.add(opT.EUR_CRM_Objectives_Promotions__c);
        }

        // get valid Objective / Promotion Ids. Ids in objPromoIds and Record Type is EUR_DE_Off_Trade_Trade_Fair.
        Set<Id> validObjPromo = new Set<Id>();
        for(EUR_CRM_ObjPromo__c objP :[Select Id, RecordType.DeveloperName From EUR_CRM_ObjPromo__c
        Where Id IN: objPromoIds
        AND RecordType.DeveloperName IN: valid_OP_RecType]){

            validObjPromo.add(objP.Id);
        }

        /*************************************************************
            @ get all Accounts in O/P - Account Mappings
            @ get valid Trade Fair Participants
            @ give valid participants Read/Write access to accounts
        *************************************************************/
        if(validObjPromo.size() > 0){
            List<EUR_CRM_ObjPromo_Account_Mapping__c> accountOPMapping = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            accountOPMapping = [Select Id, EUR_CRM_Account__c, EUR_CRM_Account__r.Name, EUR_CRM_ObjPromo__c From EUR_CRM_ObjPromo_Account_Mapping__c
            Where EUR_CRM_ObjPromo__c IN: validObjPromo];
            System.debug('***accountOPMapping: ' + accountOPMapping);

            List<Event> assignEvents = new List<Event>();
            List<EUR_CRM_Account_Team__c> pAccountAccess = new List<EUR_CRM_Account_Team__c>();
            if(accountOPMapping.size() > 0){
                for(EUR_CRM_ObjPromo_Trade_Fair_Participant__c tfP :objPromo_TradeFair){
                    if(validObjPromo.contains(tfP.EUR_CRM_Objectives_Promotions__c)){

                        for(EUR_CRM_ObjPromo_Account_Mapping__c accM :accountOPMapping){
                            //Account Team
                            EUR_CRM_Account_Team__c accTeam = new EUR_CRM_Account_Team__c();
                            accTeam.EUR_CRM_Account__c = accM.EUR_CRM_Account__c;
                            accTeam.EUR_CRM_Team_Member__c = tfP.EUR_CRM_Participant__c;
                            accTeam.EUR_CRM_Access_Level__c = 'Read/Write';

                            pAccountAccess.add(accTeam);

                            //Participant's Event
                            Event ev = new Event();
                            ev.Subject = 'Trade Fair';
                            ev.OwnerId = tfP.EUR_CRM_Participant__c;
                            ev.WhatId = accM.EUR_CRM_Account__c;
                            ev.IsAllDayEvent = true;
                            ev.ActivityDate = Date.today();
                            ev.recordTypeId = eventRecTypeId;

                            assignEvents.add(ev);
                        }

                    }
                }
            }
            System.debug('***pAccountAccess: ' + pAccountAccess + '\n' + '***Events: ' + assignEvents);
            if(pAccountAccess.size() > 0){
                try{
                    insert pAccountAccess;
                    insert assignEvents;
                }catch(System.DMLException e){
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        System.debug('Error: ' + e.getDmlMessage(i));
                    }
                }
            }
        }//end of if(validObjPromo.size() > 0){
    }//end of processObjPromoTradeFair_Insert method


    /*************
    @ Before Delete
    *************/
    public static void processObjPromoTradeFair_Delete(List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> objPromo_TradeFair){
        System.debug('***valid_OP_RecType: ' + valid_OP_RecType + '***objPromo_TradeFair: ' + objPromo_TradeFair);

        // get all Objective / Promotion Ids and Participant Ids
        Set<Id> objPromoIds = new Set<Id>();
        for(EUR_CRM_ObjPromo_Trade_Fair_Participant__c opT :objPromo_TradeFair){
            objPromoIds.add(opT.EUR_CRM_Objectives_Promotions__c);
        }

        // get valid Objective / Promotion Ids. Ids in objPromoIds and Record Type is EUR_DE_Off_Trade_Trade_Fair.
        Set<Id> validObjPromo = new Set<Id>();
        for(EUR_CRM_ObjPromo__c objP :[Select Id, RecordType.DeveloperName From EUR_CRM_ObjPromo__c
        Where Id IN: objPromoIds
        AND RecordType.DeveloperName IN: valid_OP_RecType]){

            validObjPromo.add(objP.Id);
        }

        /*************************************************************
            @ get all Accounts in O/P - Account Mappings
            @ get valid Trade Fair Participants
            @ delete account Teams and events
        *************************************************************/
        if(validObjPromo.size() > 0){
            List<EUR_CRM_ObjPromo_Account_Mapping__c> accountOPMapping = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            accountOPMapping = [Select Id, EUR_CRM_Account__c, EUR_CRM_Account__r.Name, EUR_CRM_ObjPromo__c From EUR_CRM_ObjPromo_Account_Mapping__c
            Where EUR_CRM_ObjPromo__c IN: validObjPromo];
            System.debug('***accountOPMapping: ' + accountOPMapping);

            Set<Id> accMapIds = new Set<Id>();
            Set<Id> participantIds = new Set<Id>();
            List<Event> eventsToDelete = new List<Event>();
            List<EUR_CRM_Account_Team__c> accountTeamToDelete = new List<EUR_CRM_Account_Team__c>();

            if(accountOPMapping.size() > 0){
                for(EUR_CRM_ObjPromo_Account_Mapping__c accM : accountOPMapping){
                    accMapIds.add(accM.EUR_CRM_Account__c);
                }

                for(EUR_CRM_ObjPromo_Trade_Fair_Participant__c tfP :objPromo_TradeFair){
                    if(validObjPromo.contains(tfP.EUR_CRM_Objectives_Promotions__c)){
                        participantIds.add(tfP.EUR_CRM_Participant__c);
                    }
                }

                accountTeamToDelete = [Select Id, EUR_CRM_Account__c, EUR_CRM_Team_Member__c From EUR_CRM_Account_Team__c
                Where EUR_CRM_Account__c IN: accMapIds
                AND EUR_CRM_Team_Member__c IN: participantIds];
                system.debug('***accountTeamToDelete: ' + accountTeamToDelete);

                eventsToDelete = [Select Id, OwnerId, WhatId From Event
                Where WhatId IN: accMapIds
                AND OwnerId IN: participantIds];
                system.debug('***eventsToDelete: ' + eventsToDelete);
            }

            if(accountTeamToDelete.size() > 0){
                try{
                    delete accountTeamToDelete;
                }catch(System.DMLException e){
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        System.debug('Account Team Error: ' + e.getDmlMessage(i));
                    }
                }
            }

            if(eventsToDelete.size() > 0){
                try{
                    delete eventsToDelete;
                }catch(System.DMLException e){
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        System.debug('Events Error: ' + e.getDmlMessage(i));
                    }
                }
            }
        }//end of if(validObjPromo.size() > 0){
    }//end of processObjPromoTradeFair_Delete method

}