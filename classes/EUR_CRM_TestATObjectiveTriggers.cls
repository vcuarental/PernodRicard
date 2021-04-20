/*------------------------------------------------------------
Author/Company:    IP Converge Data Services,Inc.
Description:       test class for EUR_CRM_AT_ObjectiveTrigger & EUR_CRM_AT_ActionTrigger
History
19/06/2014         IPC     Created
------------------------------------------------------------*/
@isTest
public with sharing class EUR_CRM_TestATObjectiveTriggers {
    
    static Id ATCentralObjectiveRT;
    static Id ATActionRT; 
    static void init(){
        ATCentralObjectiveRT = [select id from RecordType where SObjectType ='EUR_CRM_GB_Objective__c' and developername = 'EUR_AT_Central_Objective'].id;
        ATActionRT = [select id from RecordType where SObjectType ='EUR_CRM_GB_Action__c' and developername = 'EUR_AT_Central_Objective'].id;
    }
    
    static testmethod void testObjectiveTrigger(){
        init();
        EUR_CRM_GB_Objective__c objective = new EUR_CRM_GB_Objective__c(
        EUR_CRM_Target_Number_of_Actions__c = 100,
        EUR_CRM_Achieved_Number_of_Actions__c = 400,
        recordTypeId = ATCentralObjectiveRT );
        insert objective;
        EUR_CRM_GB_Objective__c objectiveResult = [select id,EUR_CRM_Achieved__c from EUR_CRM_GB_Objective__c where id =:objective.id];
        
        system.assert(objectiveResult.EUR_CRM_Achieved__c);
        objective.EUR_CRM_Target_Number_of_Actions__c = 100;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 30;
        update objective;
        objectiveResult = [select id,EUR_CRM_Achieved__c from EUR_CRM_GB_Objective__c where id =:objective.id];        
        system.assert(!objectiveResult.EUR_CRM_Achieved__c);
        
    }
    
    static testmethod void testActionTrigger(){
        init();
    //create account
        EUR_CRM_Account__c euAccount = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1,'AT On Trade')[0];
        insert euAccount;
    //create objective
        EUR_CRM_GB_Objective__c objective = new EUR_CRM_GB_Objective__c(
        EUR_CRM_Target_Number_of_Actions__c = 100,
        EUR_CRM_Achieved_Number_of_Actions__c = 400,
        recordTypeId = ATCentralObjectiveRT );
        insert objective;
    //insert
        EUR_CRM_GB_Action__c action = new EUR_CRM_GB_Action__c(
            EUR_CRM_Account__c = euAccount.id,
            EUR_CRM_Achieved__c = true,
            EUR_CRM_GB_Objective__c = objective.id, 
            recordTypeId = ATActionRT 
        );
        insert action;
    //update
        EUR_CRM_GB_Objective__c objectiveResult = [select id,EUR_CRM_Achieved_Number_of_Actions__c from EUR_CRM_GB_Objective__c where id =:objective.id];
        system.assert(objectiveResult.EUR_CRM_Achieved_Number_of_Actions__c == 401);
    //insert
        EUR_CRM_GB_Action__c action2 = new EUR_CRM_GB_Action__c(
            EUR_CRM_Account__c = euAccount.id,
            EUR_CRM_Achieved__c = false,
            EUR_CRM_GB_Objective__c = objective.id, 
            recordTypeId = ATActionRT);
        insert action2;
    //update
       
        objectiveResult = [select id,EUR_CRM_Achieved__c,EUR_CRM_Achieved_Number_of_Actions__c from EUR_CRM_GB_Objective__c where id =:objective.id];
         system.debug('!! result' + objectiveResult);
        system.assert(objectiveResult.EUR_CRM_Achieved_Number_of_Actions__c == 401);
        action2.EUR_CRM_Achieved__c = true;
        update action2;
        objectiveResult = [select id,EUR_CRM_Achieved__c,EUR_CRM_Achieved_Number_of_Actions__c from EUR_CRM_GB_Objective__c where id =:objective.id];
        system.assert(objectiveResult.EUR_CRM_Achieved_Number_of_Actions__c == 402);
        action2.EUR_CRM_Achieved__c = false;
        update action2;
        objectiveResult = [select id,EUR_CRM_Achieved__c,EUR_CRM_Achieved_Number_of_Actions__c from EUR_CRM_GB_Objective__c where id =:objective.id];
        system.assert(objectiveResult.EUR_CRM_Achieved_Number_of_Actions__c == 401);
       
        delete action;
        objectiveResult = [select id,EUR_CRM_Achieved__c,EUR_CRM_Achieved_Number_of_Actions__c from EUR_CRM_GB_Objective__c where id =:objective.id];
        system.assert(objectiveResult.EUR_CRM_Achieved_Number_of_Actions__c == 400);
        
    //delete
        
    }
}