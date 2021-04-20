@isTest(SeeAllData=true) 
public class PRH_Iconic_Account_Trigger_Test{
        
    public static testMethod void testTriggerBrazil() {
        ID rtID = Global_RecordTypeCache.getRtID('Account'+'On_Trade');
        Account testAcc = new Account();
        testAcc.Name = 'Test 1';
        testAcc.RecordTypeID = rtID;
        testAcc.Segmentation_Type_on_trade__c ='Bar Agitado';
        testAcc.Revenue_Address__c = 'TEST ADD';
        testAcc.PRH_Iconic_Account__c = true;
        insert testAcc;
    }
    
    public static testMethod void testTriggerBrazil2() {
        ID rtID = Global_RecordTypeCache.getRtID('Account'+'On_Trade');
        Account testAcc = new Account();
        testAcc.Name = 'Test 1';
        testAcc.RecordTypeID = rtID;
        testAcc.Segmentation_Type_on_trade__c ='Bar';
        testAcc.Revenue_Address__c = 'TEST ADD';
        testAcc.PRH_Iconic_Account__c = true;
        insert testAcc;
   
    }
    public static testMethod void testTriggerUSA() {
        ID rtID = Global_RecordTypeCache.getRtID('Account'+'USA_Account');
        Account testAcc = new Account();
        testAcc.Name = 'Test 1';
        testAcc.RecordTypeID = rtID;
        testAcc.BillingStreet = 'Test Street';
        testAcc.BillingCity = 'Test';
        testAcc.BillingState = 'Test';
        testAcc.BillingState = 'Test';
        testAcc.BillingPostalCode = 'TEST ADD';
        testAcc.BillingCountry = 'TEST ADD';
        testAcc.PRH_Iconic_Account__c = true;
        insert testAcc;
   
    }
     public static testMethod void testTriggerUSA2() {
        ID rtID = Global_RecordTypeCache.getRtID('Account'+'USA_Account');
        Account testAcc = new Account();
        testAcc.Name = 'Test 1';
        testAcc.RecordTypeID = rtID;

        testAcc.BillingCity = 'Test';
        testAcc.BillingState = 'Test';
        testAcc.BillingPostalCode = 'TEST ADD';
        testAcc.BillingCountry = 'TEST ADD';
        testAcc.PRH_Iconic_Account__c = true;
        insert testAcc;
   
    } 
    
    public static testMethod void testTrigger2() {

        ID rtIDEu = Global_RecordTypeCache.getRtID('EUR_CRM_Account__c'+'EUR_GB_FS_Indirect');
        
        EUR_CRM_Account__c testEUAcc = new EUR_CRM_Account__c(Name = 'Test', recordTypeID = rtIDEu );
        insert testEUAcc;
        Test.startTest();
        testEUAcc.EUR_CRM_Force_Iconic_Account__c = true;
        update testEUAcc;
        
        Test.stopTest(); 
    }
    
    public static testMethod void testTrigger3() {
         ID rtIDEu = Global_RecordTypeCache.getRtID('EUR_CRM_Account__c'+'EUR_GB_FS_Indirect');
        
        EUR_CRM_Account__c testEUAcc2 = new EUR_CRM_Account__c(Name = 'Test', recordTypeID = rtIDEu,EUR_CRM_Force_Iconic_Account__c = true);       
        insert testEUAcc2;
        
        // GDT TO AVOID ERRORS delete testEUAcc2;
       
        
        
    }
    /*
    AUG 10, 2015 - updated.
    */
    public static testMethod void testTrigger4() {
        ID rtIDEu = Global_RecordTypeCache.getRtID('EUR_CRM_Account__c'+'EUR_GB_FS_Indirect');
        ID rtIDEu2 = Global_RecordTypeCache.getRtID('EUR_CRM_Account__c'+'EUR_EE_DIR_ON_Trade');
        final String dtimestamp = '' + system.now();
        String accountName1 = 'Test GB Account' + dtimestamp;
        String accountName2 = 'Test EE Account' + dtimestamp;
        List<EUR_CRM_Account__c> toInsert = new List<EUR_CRM_Account__c>();
        EUR_CRM_Account__c testEUAcc1 = new EUR_CRM_Account__c(Name = accountName1, recordTypeID = rtIDEu,EUR_CRM_Force_Iconic_Account__c = true);       
        toInsert.add(testEUAcc1);
        EUR_CRM_Account__c testEUAcc2 = new EUR_CRM_Account__c(EUR_CRM_Postal_Code__c = '12345', Name = accountName2, recordTypeID = rtIDEu2,EUR_CRM_Force_Iconic_Account__c = true);       
        toInsert.add(testEUAcc2);
        insert toInsert;
        /*PRH_Luxury_Accounts__c iconicAccount = [select id from PRH_Luxury_Accounts__c where name =: accountName1 limit 1];
        system.assert(iconicAccount!= null);     
        List<PRH_Luxury_Accounts__c> iconicAccount2 = [select id from PRH_Luxury_Accounts__c where name =: accountName2 ];
        system.assert(iconicAccount2 == null || iconicAccount2.size() == 0);    */ 
    }
    
    
}