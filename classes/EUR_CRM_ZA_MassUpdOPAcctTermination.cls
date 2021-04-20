/**
* Class: EUR_CRM_ZA_MassUpdOPAcctTermination
*
* Fired from the schedulable class EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping 
* Sets O/P Account Mappings evaluation required field to false for each mapping whose Object Promo's evaluation period has ended
*/

global class EUR_CRM_ZA_MassUpdOPAcctTermination implements Database.Batchable<sObject> {

    final Set<String> VALID_RECORDTYPES = new Set<String>{
            'EUR_ZA_OP_Account_Mapping',
            'EUR_FI_O_P_Account_Mapping'
    };

    global static String generateQuery() {
        return 'SELECT Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_ObjPromo__r.EUR_CRM_Evaluation_Period_End_Date__c, RecordtypeId ' +
                'FROM EUR_CRM_ObjPromo_Account_Mapping__c ' +
                'WHERE Recordtype.DeveloperName IN :VALID_RECORDTYPES ' +
                'AND EUR_CRM_Is_Active__c = FALSE ' +
                'AND EUR_CRM_Evaluation_Required__c = TRUE ' +
                'AND EUR_CRM_ObjPromo__r.EUR_CRM_Evaluation_Period_End_Date__c < TODAY';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
//        System.debug('QUERY: ' + generateQuery());
        return Database.getQueryLocator(generateQuery());
    }

    global void finish(Database.BatchableContext BC) {
    }

    //Main Logic Implementation
    global void execute(Database.Batchablecontext BC, List<sObject> scope) {
        System.debug('SCOPE size: ' + scope.size());

        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapList = (List<EUR_CRM_ObjPromo_Account_Mapping__c>) scope;
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapListToUpdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

        for (EUR_CRM_ObjPromo_Account_Mapping__c opMap : opAcctMapList) {
            opMap.EUR_CRM_Evaluation_Required__c = FALSE;
            opAcctMapListToUpdate.add(opMap);
        }

        if (opAcctMapListToUpdate.size() > 0) {
            update opAcctMapListToUpdate;
        }
    }
}