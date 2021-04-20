/**
* Class: EUR_CRM_ZA_MassUpdateOPAccountMapping
*
* Fired from the schedulable class EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping
* which is called by schedulable job ZA Mass Update OP Mapping
* Sets O/P Account Mappings active field to false for each mappings' whose Object Promo has ended
* Sets the Object Promo object's status to under evaluation if entered evaluation period.
* sets evaluation required to true if the execution visit action was completed
*/

global class EUR_CRM_ZA_MassUpdateOPAccountMapping implements Database.Batchable<sObject>{

    global static String generateQuery(){
        return  'SELECT Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c, EUR_CRM_ObjPromo__r.EUR_CRM_Active_End_Date__c, ' +
                'EUR_CRM_ObjPromo__r.EUR_CRM_Evaluation_Period_End_Date__c,  EUR_CRM_ObjPromo__c ' + 
                'FROM EUR_CRM_ObjPromo_Account_Mapping__c ' +
                'WHERE Recordtype.DeveloperName =  \'EUR_ZA_OP_Account_Mapping\' ' +
                'AND EUR_CRM_Is_Active__c = TRUE ' +
                'AND EUR_CRM_Evaluation_Required__c = FALSE ' +
                'AND EUR_CRM_ObjPromo__r.EUR_CRM_Active_End_Date__c < TODAY';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('QUERY: ' + generateQuery());
        return Database.getQueryLocator(generateQuery());
    }

    global void finish(Database.BatchableContext BC){   
    }
    
    //Main Logic Implementation
    global void execute (Database.Batchablecontext BC, List<sObject> scope){
        System.debug('SCOPE: ' + scope);

        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapList = (List<EUR_CRM_ObjPromo_Account_Mapping__c>)scope;
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapToUpdateList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        List<EUR_CRM_objPromo__c> objPromoToUpdateList = new List<EUR_CRM_objPromo__c>();

        // The key is the aggregate of Account and ObjPromo since visit and opMappings dont link to each other
        String key = '';
        Map<String, List<EUR_CRM_Visit_Action__c>> acctOPToVisitActionsMap = new Map<String, List<EUR_CRM_Visit_Action__c>>();        

        // Get all objPromos associated with the mappings
        Set<Id> opIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : opAcctMapList){
            opIds.add(opMap.EUR_CRM_ObjPromo__c);
            accIds.add(opMap.EUR_CRM_Account__c);
        }
        Map<Id, EUR_CRM_objPromo__c> objPromoMap = new Map<Id, EUR_CRM_objPromo__c>([SELECT Id, EUR_CRM_Status__c FROM EUR_CRM_objPromo__c WHERE Id IN: opIds]);

        // Get all execution visit actions associated with the accounts and objPromos
        for(EUR_CRM_Visit_Action__c visitAction :   [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Status__c, EUR_CRM_Stage__c, EUR_CRM_ObjPromo__c, RecordType.Developername
                                                        FROM EUR_CRM_Visit_Action__c 
                                                        WHERE EUR_CRM_ObjPromo__c IN : opIds
                                                        AND EUR_CRM_Account__c IN : accIds
                                                        AND Recordtype.Developername IN ('EUR_ZA_ON_Define_Participation_Conditions',
                                                                                        'EUR_ZA_OFF_Define_Participation_Conditions')
                                                        AND EUR_CRM_Stage__c = 'Execution'
                                                    ]){

            key = String.valueOf(visitAction.EUR_CRM_Account__c) + String.valueOf(visitAction.EUR_CRM_objPromo__c);
            if(acctOPToVisitActionsMap.get(key) == null){
                acctOPToVisitActionsMap.put(key, new List<EUR_CRM_Visit_Action__c>());
            }
            acctOPToVisitActionsMap.get(key).add(visitAction);
        }
       
 
        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : opAcctMapList){
            // Deactivate all OPAcct Mappings if the Op has ended
            opMap.EUR_CRM_Is_Active__c = false;
            key = String.valueOf(opMap.EUR_CRM_Account__c) + String.valueOf(opMap.EUR_CRM_objPromo__c);
            if(acctOPToVisitActionsMap.KeySet().contains(key)){
                for(EUR_CRM_Visit_Action__c visit : acctOPToVisitActionsMap.get(key)){
                    // Visit action is successful depending on the value of its Status picklist
                    if(visit.EUR_CRM_Status__c == 'Yes'){
                        opMap.EUR_CRM_Evaluation_Required__c = true;
                        // Set evaluation to true if evaluation date is not over
                        if(opMap.EUR_CRM_objPromo__r.EUR_CRM_Evaluation_Period_End_Date__c > Date.Today()){
                            if(objPromoMap.KeySet().contains(opMap.EUR_CRM_objPromo__c)){
                                objPromoMap.get(opMap.EUR_CRM_ObjPromo__c).EUR_CRM_Status__c = 'Under Evaluation';
                                objPromoToUpdateList.add(objPromoMap.get(opMap.EUR_CRM_ObjPromo__c));
                            }
                        }
                    } else {
                        System.debug('Status is No: ' + acctOPToVisitActionsMap.get(key));
                    }
                }
            } else {
                System.debug('Execution Visit Action does not exist for mapping: ' + opMap);
            } 

            opAcctMapToUpdateList.add(opMap);
        }
        
        if(opAcctMapToUpdateList.size() > 0){
            update opAcctMapToUpdateList;
        }

        if(objPromoToUpdateList.size() > 0){
            update objPromoToUpdateList;
        }
    }     
}