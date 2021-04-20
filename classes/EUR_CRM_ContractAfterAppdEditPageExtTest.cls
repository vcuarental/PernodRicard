@isTest
private with sharing class EUR_CRM_ContractAfterAppdEditPageExtTest{

    private static EUR_CRM_Account__c euaccount;
    private static Contact contact;
    public static EUR_CRM_Contract__c fiContract = new EUR_CRM_Contract__c();

     public static void dataInsert1(){
        euaccount = EUR_CRM_FI_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_FI_Indirect_On_Trade').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);

        contact = EUR_CRM_FI_TestClassHelper.createContact(1, 'TEST CONTACT', euaccount).get(0);
        insert contact;
        system.assertNotEquals(contact, null);
        
        fiContract = EUR_CRM_FI_TestClassHelper.createFIContract(1,'test', euaccount, contact, 'EUR_FI_Chain_Contract').get(0);
        insert fiContract;
        system.assertNotEquals(fiContract, null);
        
     }
     
     static testMethod void test1(){
         dataInsert1();
         test.StartTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(fiContract);
            EUR_CRM_ContractAfterApprovedEditPageExt afterApproved = new EUR_CRM_ContractAfterApprovedEditPageExt (sc);
           afterApproved.save();
           afterApproved.saveFIContract();
         Test.StopTest();
     }
}