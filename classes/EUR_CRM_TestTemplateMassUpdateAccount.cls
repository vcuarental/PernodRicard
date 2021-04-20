/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_Template_Mass_Update_Accounts Class.
  @Author:      IPC
  @History:     JUN.18.2014 - Created
*/
@isTest 
public with sharing class EUR_CRM_TestTemplateMassUpdateAccount {
    private static EUR_CRM_JB_Template__c template;
    private static EUR_CRM_JB_Template_Criteria__c tempCiteria;
    private static EUR_CRM_Account__c accountEU;
    
    public static void dataInsert(){
        template = EUR_CRM_TestClassUtilityHelper.createTemplate(1, 'DE OFF-Trade Template', 'DE OFF-Trade Template')[0];
        insert template;
        system.assert(template.Id!=null);
        
        tempCiteria = EUR_CRM_TestClassUtilityHelper.createTemplateCriteria(1, 'DE Template Criteria', template.Id)[0];
        tempCiteria.EUR_JB_Active__c= false;
        insert tempCiteria;
        system.assert(tempCiteria.Id!=null);
        
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'AT On Trade')[0];
        accountEU.EUR_JB_Default_Template__c = template.Id;
        accountEU.EUR_CRM_Listing_Template__c = template.Id;
        insert accountEU;
    }
    
    static testmethod void testMassUpdate1(){
        dataInsert();
        test.startTest();
            Id batchprocessid = Database.executeBatch(new EUR_CRM_Template_Mass_Update_Accounts(template.RecordTypeId), 150); 
        test.stopTest();
    }

    static testmethod void testMassUpdate2(){
        dataInsert();
        test.startTest();
            Id batchprocessid = Database.executeBatch(new EUR_CRM_Template_Mass_Update_Accounts('DE'), 150); 
        test.stopTest();
    }


    
}