/**
* Class: EUR_CRM_ZA_CreateVisitActionFollowUps
*
* Fired from the schedulable class EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping
* which is called by schedulable job ZA Mass Update OP Mapping
* Creates ZA Follow Up Actions Visits if execution Action visits of the opMapping is successful
*/

global class EUR_CRM_ZA_CreateVisitActionFollowUps implements Database.Batchable<sObject>{ 

    global static String generateQuery(){
        return  'SELECT Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c, EUR_CRM_ObjPromo__c, RecordType.DeveloperName ' + 
                'FROM EUR_CRM_ObjPromo_Account_Mapping__c ' +
                'WHERE Recordtype.DeveloperName =  \'EUR_ZA_OP_Account_Mapping\' ' +
                'AND EUR_CRM_Is_Active__c = FALSE ' +
                'AND EUR_CRM_Evaluation_Required__c = TRUE';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('QUERY: ' + generateQuery());
        return Database.getQueryLocator(generateQuery());
    }

    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('SCOPE: ' + scope);

        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapList = (List<EUR_CRM_ObjPromo_Account_Mapping__c>)scope;
        List<EUR_CRM_Visit_Action__c> visitActionsFollowUp = new List<EUR_CRM_Visit_Action__c>();

        Set<Id> opIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();        

        String ON_DEFINE_PARTICIPATION = 'EUR_ZA_ON_Define_Participation_Conditions';
        String OFF_DEFINE_PARTICIPATION = 'EUR_ZA_OFF_Define_Participation_Conditions';

        Id ON_FOLLOW_UP_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_ZA_ON_Follow_Up');
        Id OFF_FOLLOW_UP_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_ZA_OFF_Follow_Up');

        EUR_CRM_ObjPromo_Action__c objPromoActionOnFollowUp = [SELECT Id,  EUR_CRM_Stage__c, EUR_CRM_Stage_Sequence_Order__c
                                                                FROM EUR_CRM_ObjPromo_Action__c 
                                                                WHERE EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_ZA_ON_Follow_Up'
                                                            ];
        EUR_CRM_ObjPromo_Action__c objPromoActionOffFollowUp = [SELECT Id, EUR_CRM_Stage_Sequence_Order__c, EUR_CRM_Stage__c
                                                                 FROM EUR_CRM_ObjPromo_Action__c 
                                                                 WHERE EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_ZA_OFF_Follow_Up'
                                                            ];

        // The key is the aggregate of Account and ObjPromo since visit and opMappings dont link to each other
        String key = '';
        Map<String, EUR_CRM_ObjPromo_Account_Mapping__c> objPromoMappingsMap = new Map<String, EUR_CRM_ObjPromo_Account_Mapping__c>();
        Map<String, EUR_CRM_Visit_Action__c> visitActionMap = new Map<String, EUR_CRM_Visit_Action__c>();

        // Loop the scope
        // Get all accounts and ObjPromos associated with the visits
        // and create a unique map
        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : opAcctMapList){
            opIds.add(opMap.EUR_CRM_ObjPromo__c);
            accIds.add(opMap.EUR_CRM_Account__c);
            
            key =  String.valueOf(opMap.EUR_CRM_ObjPromo__c) + String.valueOf(opMap.EUR_CRM_Account__c);
            objPromoMappingsMap.put(key, opMap);
        }   

        for(EUR_CRM_Visit_Action__c visitAct : [SELECT Id, RecordtypeId, RecordType.DeveloperName, EUR_CRM_Status__c, EUR_CRM_ObjPromo__c, EUR_CRM_Account__c,
                                                EUR_CRM_Stage_Sequence_Order__c, EUR_CRM_Stage__c, EUR_CRM_OP_Action__c
                                                FROM EUR_CRM_Visit_Action__c
                                                WHERE EUR_CRM_ObjPromo__c IN : opIds 
                                                AND EUR_CRM_Account__c IN : accIds]
                                            ){
            if(visitAct.EUR_CRM_Status__c == 'Yes'){
                key = String.valueOf(visitAct.EUR_CRM_ObjPromo__c) + String.valueOf(visitAct.EUR_CRM_Account__c);
                visitActionMap.put(key, visitAct);
            }
        } 

        for(String currentKey : visitActionMap.KeySet()){
            if(objPromoMappingsMap.KeySet().contains(currentKey)){
                EUR_CRM_Visit_Action__c visitAct = visitActionMap.get(currentKey);

                if(visitAct.Recordtype.DeveloperName == ON_DEFINE_PARTICIPATION){
                    EUR_CRM_Visit_Action__c newVA = new EUR_CRM_Visit_Action__c();
                    newVA.RecordtypeId = ON_FOLLOW_UP_ID;
                    newVA.EUR_CRM_Account__c = visitAct.EUR_CRM_Account__c;
                    newVA.EUR_CRM_Stage__c = objPromoActionOnFollowUp.EUR_CRM_Stage__c;
                    newVA.EUR_CRM_ObjPromo__c = visitAct.EUR_CRM_ObjPromo__c;
                    newVA.EUR_CRM_OP_Action__c = objPromoActionOnFollowUp.Id;
                    newVA.EUR_CRM_Stage_Sequence_Order__c = objPromoActionOnFollowUp.EUR_CRM_Stage_Sequence_Order__c;
                    visitActionsFollowUp.add(newVA);
                }
                else if (visitAct.Recordtype.DeveloperName == OFF_DEFINE_PARTICIPATION){
                    EUR_CRM_Visit_Action__c newVA = new EUR_CRM_Visit_Action__c();
                    newVA.RecordtypeId = OFF_FOLLOW_UP_ID;
                    newVA.EUR_CRM_Account__c = visitAct.EUR_CRM_Account__c;
                    newVA.EUR_CRM_Stage__c = objPromoActionOffFollowUp.EUR_CRM_Stage__c;
                    newVA.EUR_CRM_ObjPromo__c = visitAct.EUR_CRM_ObjPromo__c;
                    newVA.EUR_CRM_OP_Action__c = objPromoActionOffFollowUp.Id;
                    newVA.EUR_CRM_Stage_Sequence_Order__c = objPromoActionOffFollowUp.EUR_CRM_Stage_Sequence_Order__c;
                    visitActionsFollowUp.add(newVA);
                }
            }
        }
        
        System.debug('FOLLOWUPS: ' + visitActionsFollowUp);
        if(visitActionsFollowUp.size() > 0){
            insert visitActionsFollowUp;
        }
    }
}