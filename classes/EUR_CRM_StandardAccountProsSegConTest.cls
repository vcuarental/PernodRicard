/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_StandardAccountProsSegController Class.
  @Author:      IPC
  @History:     APR.29.2014 - Created
*/
@isTest (SeeAllData=true)
private class EUR_CRM_StandardAccountProsSegConTest {
    private static Account account;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    
    public static void dataInsert1(){
        
        account = EUR_CRM_TestClassUtilityHelper.createAccounts(1, 'On Trade')[0];
        insert account;
    }
    
    public static void dataInsert2(){
        
        account = EUR_CRM_TestClassUtilityHelper.createAccounts(1, 'On Trade')[0];
        insert account;
        
        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_EE_PROS_Segmentation', '', null, null, null, null, null, account.Id)[0];
        insert prosSegmentation;
    }
    
    static testMethod void standardAccntPSTest1() {
        dataInsert1();
        
        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
        PageReference rf = new Pagereference('/apex/EUR_CRM_Account_ProsSegSectionPage');
        rf.getParameters().put('id', account.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_StandardAccountProsSegController controller = new EUR_CRM_StandardAccountProsSegController(standardController);
        
        test.stopTest();
    }
    
    static testMethod void standardAccntPSTest2() {
        dataInsert2();
        
        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
        PageReference rf = new Pagereference('/apex/EUR_CRM_Account_ProsSegSectionPage');
        rf.getParameters().put('id', account.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_StandardAccountProsSegController controller = new EUR_CRM_StandardAccountProsSegController(standardController);
        
        controller.getCustomLink();
        controller.createProsSegmentation();
        controller.openProsSeg();
        controller.openAccountPlan();
        controller.addPageMessage('error', ApexPages.Severity.FATAL);
        
        test.stopTest();
    }
}