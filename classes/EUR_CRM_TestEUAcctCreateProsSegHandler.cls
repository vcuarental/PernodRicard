/**
 * Test Class for EUR_CRM_EU_AccountCreateProsSegHandler
 */
@isTest
private class EUR_CRM_TestEUAcctCreateProsSegHandler {
    
    //private static EUR_CRM_Account__c account;
    //private static EUR_CRM_Pros_Segmentation__c pros; 
    static testMethod void testBulkified(){
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
         
        // Edited By Jay 20160926 : Reduce Account Creation From 400 to 100
        for(Integer i = 0 ; i < 100 ; i++){
            EUR_CRM_Account__c account =EUR_CRM_TestClassHelper.createEUAccount('TEST' + i,'EE');
            account.EUR_CRM_3_Most_Pop_Prod_Categories__c = 'Vodka;Rum;Beer';
            account.eur_Crm_postal_code__C ='12345';
            accounts.add(account);
        
        }
        Test.startTest(); // Edited By Jay 20160926
        insert accounts;
        Set<Id> ac = new Set<Id>();

        for(EUR_CRM_Account__c a : accounts){
            ac.add(a.id);
        }

        List<EUR_CRM_Pros_Segmentation__c> prosSegList = [select id from EUR_CRM_Pros_Segmentation__c where EUR_CRM_Account__c in: ac]; 
        system.Assert(prosSegList.size() == 100); // Edited By Jay 20160926 : Reduce size checking From 400 to 100
        
        Test.stopTest(); // Edited By Jay 20160926
        
    } 
    static testMethod void testLT() {
        Boolean isRecursive = false;
        
        EUR_CRM_Account__c account = new EUR_CRM_Account__c();
        account = EUR_CRM_TestClassHelper.createEUAccount('Test');  
        account.eur_Crm_postal_code__C ='12345'; 
        account.EUR_CRM_3_Most_Pop_Prod_Categories__c = 'Vodka;Rum;Beer';
        insert account; 
        
    }
    static testMethod void testEE() {
        Boolean isRecursive = false;
        
        EUR_CRM_Account__c account = new EUR_CRM_Account__c();
        account = EUR_CRM_TestClassHelper.createEUAccount('Test',EUR_CRM_TestClassHelper.EE);   
        account.eur_Crm_postal_code__C ='12345';
        account.EUR_CRM_3_Most_Pop_Prod_Categories__c = 'Vodka;Rum;Beer';
        insert account; 
        
    }
    static testMethod void testLV() {
        Boolean isRecursive = false;
        
        EUR_CRM_Account__c account = new EUR_CRM_Account__c();
        account = EUR_CRM_TestClassHelper.createEUAccount('Test',EUR_CRM_TestClassHelper.LV);   
        account.eur_Crm_postal_code__C ='1234';
        account.EUR_CRM_3_Most_Pop_Prod_Categories__c = 'Vodka;Rum;Beer';
        insert account; 
    }
    /*
         static testMethod void testAT() {
        Boolean isRecursive = false;
        
        EUR_CRM_Account__c account = new EUR_CRM_Account__c();
        account = EUR_CRM_TestClassHelper.createEUAccount('Test',EUR_CRM_TestClassHelper.AT);   
        
        insert account;
        
        
        EUR_CRM_Pros_Segmentation__c pros = new EUR_CRM_Pros_Segmentation__c();
        pros.EUR_CRM_Account__c = account.Id;
        pros.RecordTypeId = ProsRecordTypeInfo.get('EUR_AT_PROS_Segmentation').getRecordTypeId();       
        
        if (!isRecursive){
            isRecursive = true;
            insert pros;
        }
        
    } */
}