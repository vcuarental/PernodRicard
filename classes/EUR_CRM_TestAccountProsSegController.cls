@isTest
public with sharing class EUR_CRM_TestAccountProsSegController {
    private static EUR_CRM_Account__c euAccount;
    private static EUR_CRM_Affiliate__c affiliate;
    private static User user;
    
    static void init(){
        user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();

    }
    
    static void createCommon(){
        euAccount= (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1,'EE Direct - On Trade')).get(0);   
        insert euAccount;
        
        User activeUser = [SELECT CompanyName FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        affiliate = EUR_CRM_TestClassHelper.createAffiliate();
        affiliate.Name = activeUser.CompanyName;
        insert affiliate;
        
    }
    
    static testMethod void testCreateProsSegmentation(){
        //init();
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            createCommon();
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(euAccount);
            
            PageReference ref = new PageReference('/apex/EUR_CRM_Account_ProsSegSectionPageCntry');
            ref.getParameters().put('id', euAccount.id);
            Test.setCurrentPage(ref);
            
            EUR_CRM_AccountProsSegController controller = new EUR_CRM_AccountProsSegController(standardController);
            controller.createProsSegmentation();
            controller.getCustomLink(); 
            controller.openProsSeg(); 
            controller.openAccountPlan();
        	controller.getIsServicePackRendered();
            //System.assertNotEquals(controller.url, null);
            //controller.openProsSeg();
        //}
    }
    static testMethod void testCreateProsSegmentation2(){
        //init();
        createCommon();
        user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        System.runAs(user){
            String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
            user.CompanyName = companyName;
            update user;
            
            euAccount.id=null;
            ApexPages.StandardController standardController = new ApexPages.StandardController(euAccount);
            
            PageReference ref = new PageReference('/apex/EUR_CRM_Account_ProsSegSectionPageCntry');
            ref.getParameters().put('id', euAccount.id);
            Test.setCurrentPage(ref);
            
            EUR_CRM_AccountProsSegController controller = new EUR_CRM_AccountProsSegController(standardController);
            controller.createProsSegmentation();
           /* controller.createProsSegmentation();
            controller.getCustomLink(); 
            controller.openProsSeg(); 
            controller.openAccountPlan();*/
            //System.assertNotEquals(controller.url, null);
            //controller.openProsSeg();
        }
    }
    /*
    static testMethod void testOpenProsSegmentation(){
        //init();

        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            createCommon();
            
            //Create Pros Segmentation
            EUR_CRM_Pros_Segmentation__c prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            insert prosSegmentation;
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(account);
            
            PageReference ref = new PageReference('/apex/EUR_CRM_Account_ProsSegSectionPage');
            ref.getParameters().put('id', account.id);
            Test.setCurrentPage(ref);
            
            EUR_CRM_AccountProsSegController controller = new EUR_CRM_AccountProsSegController(standardController);
            
            EUR_CRM_Pros_Segmentation__c testProsSegRes = controller.getProsSeg();
            
            System.debug('Test Pros Seg Result:'+testProsSegRes);
                
            controller.openProsSeg();
            
            System.assertNotEquals(controller.url, null);
        //}
    }*/
    
}