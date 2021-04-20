@isTest
public class LAT_BR_AccountBasicInfoFieldsCont_TEST {
	
    @testSetup
    static void setup(){

        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'BR_CAN_UPDATE_BASIC_INFO_FIELDS_PROF',
            lat_value__c = 'LAT_SystemAdministrator');
        insert cfg1;
        Account acc = new Account(            
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro', 
            Type = 'Payer', 
            Phone = '+54 0380 11111111', 
            Notes__c = 'TEST', 
            AddressLine1_AR__c = 'TEST', 
            CNPJ__c = '30641670223', 
            Corporate_Name__c = 'TEST', 
            Channel__c = 'WS', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG')
        );        
        insert acc;
    }
	
    @isTest
    static void unitTest(){
        
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
     		Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF',
   			LAT_Value__c = 'LAT_AR2_Vendedor');
        insert cfg;
        
        Test.startTest();        
        Account acc = [SELECT Id FROM Account LIMIT 1];
                            
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);            
        LAT_BR_AccountBasicInfoFieldsCont testPage = new LAT_BR_AccountBasicInfoFieldsCont(sc);
        testPage.doEdit();
        testPage.updateAccount();
        testPage.doSave();
        testPage.doCancel();    
        Test.stopTest();    
    }

	@isTest
    static void unitTest_LatAccountBefore(){
                
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
     		Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF',
   			LAT_Value__c = 'LAT_AR2_Vendedor');
        insert cfg;
        
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
                            
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);            
        LAT_BR_AccountBasicInfoFieldsCont testPage = new LAT_BR_AccountBasicInfoFieldsCont(sc);
        testPage.doEdit();
        testPage.updateAccount();
        testPage.doSave();
        testPage.doCancel();    
        Test.stopTest();        
    }
    
	@isTest
    static void unitTest_LatAccountBefore2(){
                
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
     		Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF',
   			LAT_Value__c = 'LAT_AR2_Vendedor');
        insert cfg;
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
                            
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);            
        LAT_BR_AccountBasicInfoFieldsCont testPage = new LAT_BR_AccountBasicInfoFieldsCont(sc);
        testPage.doEdit();
        testPage.updateAccount();
        testPage.doSave();
        testPage.doCancel();   
        Test.stopTest();         
    }
}