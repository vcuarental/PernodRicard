/**
* Class: EUR_CRM_ZA_MassUpdateOPAcctMapEval
*
* Fired from the schedulable class 
* which is called by schedulable job ZA Mass Update OP Mapping
* Sets the opMapping evaluation required field to false if the ZA follow up visit action was successful
*/

global class EUR_CRM_ZA_MassUpdateOPAcctMapEval implements Database.Batchable<sObject>{

    global static String generateQuery(){
        return  'SELECT Id, EUR_CRM_Status__c, EUR_CRM_Stage__c, EUR_CRM_Account__c, EUR_CRM_ObjPromo__c, RecordtypeId ' +
                'FROM EUR_CRM_Visit_Action__c ' +
                'WHERE RecordtypeId IN (SELECT Id FROM RecordType WHERE DeveloperName IN (\'EUR_ZA_ON_Follow_Up\',\'EUR_ZA_OFF_Follow_Up\')) ' +
                'AND EUR_CRM_Status__c = \'Evaluation: Successful\'';
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

        List<EUR_CRM_Visit_Action__c> visitActionsList = (List<EUR_CRM_Visit_Action__c>)scope;
        List<Id> opIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoMappingsToUpdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

        // The key is the aggregate of Account and ObjPromo since visit and opMappings dont link to each other
        String key = '';
        Map<String, EUR_CRM_Visit_Action__c> visitActionMap = new Map<String, EUR_CRM_Visit_Action__c>();
        Map<String, EUR_CRM_ObjPromo_Account_Mapping__c> objPromoMappingsMap = new Map<String, EUR_CRM_ObjPromo_Account_Mapping__c>();

        // Loop the scope
        // Get all accounts and ObjPromos associated with the visits
        // and create a unique map
        for(EUR_CRM_Visit_Action__c visit : visitActionsList){
            opIds.add(visit.EUR_CRM_ObjPromo__c);
            accIds.add(visit.EUR_CRM_Account__c);

            key = String.valueOf(visit.EUR_CRM_ObjPromo__c) + String.valueOf(visit.EUR_CRM_Account__c);
            visitActionMap.put(key, visit);
        }   
        
        // Retrieve all OP-Acct mappings that have the account and objpromos as the visits
        // Which are also innactive, and currently being evaluated
        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : [SELECT Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c, 
                                                                EUR_CRM_ObjPromo__c, RecordType.DeveloperName 
                                                        FROM EUR_CRM_ObjPromo_Account_Mapping__c 
                                                        WHERE Recordtype.DeveloperName =  'EUR_ZA_OP_Account_Mapping'
                                                        AND EUR_CRM_ObjPromo__c IN : opIds
                                                        AND EUR_CRM_Account__c IN : accIds
                                                        AND EUR_CRM_Is_Active__c = false 
                                                        AND EUR_CRM_Evaluation_Required__c = true]
                                                    ){
            key =  String.valueOf(opMap.EUR_CRM_ObjPromo__c) + String.valueOf(opMap.EUR_CRM_Account__c);
            objPromoMappingsMap.put(key, opMap);
        }

        // Set the evaluation required of the opMapping to false if its visit action fits the criteria
        for(String currentKey : visitActionMap.KeySet()){
            if(objPromoMappingsMap.KeySet().contains(currentKey)){
                EUR_CRM_ObjPromo_Account_Mapping__c opMap = objPromoMappingsMap.get(currentKey);
                opMap.EUR_CRM_Evaluation_Required__c = false;
                objPromoMappingsToUpdate.add(opMap);
            }
        }

        // Update
        if(objPromoMappingsToUpdate.size() > 0){
            update objPromoMappingsToUpdate;
        }   
    }
}