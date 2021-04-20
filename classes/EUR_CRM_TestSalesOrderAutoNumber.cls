@isTest
private class EUR_CRM_TestSalesOrderAutoNumber{

//    public testmethod static void testSalesOrderDE(){
//        EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', UserInfo.getUserId(), 'DE Region');
//
//        EUR_CRM_Territory__c territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', UserInfo.getUserId(),region.id, 'DE Territory');
//        Id accountrecordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'DE OFF STD');
//
//        EUR_CRM_Postal_Code_Territory_Mapping__c mapping  = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , '12345' , territory.id, 'DE Off Trade Postal Code - Territory Mapping');
//        EUR_CRM_Postal_Code_Territory_Mapping__c mapping2  = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , '123456' , territory.id, 'DE Off Trade Postal Code - Territory Mapping');
//
//        EUR_CRM_Account__c  offTradeAccount1 = new EUR_CRM_Account__c();
//        offTradeAccount1.EUR_CRM_Postal_Code__c = '12345';
//        offTradeAccount1.recordtypeid = accountrecordtypeId;
//
//        insert offTradeAccount1;
//        Id configRTId = [select id from recordtype where developername = 'EUR_CRM_Running_Number' and sobjecttype = 'EUR_CRM_Apex_Configuration__c'][0].id;
//        Id soRTId = [select id from recordtype where developername = 'EUR_DE_ON_Standard_Goods_Sales_Order' and sobjecttype = 'EUR_CRM_Sales_Order__c'][0].id;
//
//        EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c(
//            EUR_CRM_Country_Code__c = 'DE',
//            EUR_CRM_Module__c = 'EUR_CRM_Running_Number',
//            EUR_CRM_Prefix__c = 'DE-SO-',
//            EUR_CRM_Running_Number__c = 1,
//            recordtypeid = configRTId ,
//            EUR_CRM_Running_Number_Length__c = 10
//        );
//
//        insert config;
//
//        EUR_CRM_Sales_Order__c so = new EUR_CRM_Sales_Order__c(
//            recordtypeid = soRTId ,
//            EUR_CRM_Account__c =  offTradeAccount1.id
//        );
//        insert so;
//
//        ApexPages.StandardController sc = new ApexPages.StandardController(so);
//        EUR_CRM_NewSalesOrderPageController con = new EUR_CRM_NewSalesOrderPageController(sc);
//        con.assignDefaultAndRedirect();
//
//        // Calls the update trigger
//        so.EUR_CRM_Name__c = 'Test Name';
//        update so;
//    }

    @isTest
    private static void testSalesOrderBG(){
        EUR_CRM_Region__c region = EUR_CRM_TestClassUtilityHelper.createRegion(1,'EUR', UserInfo.getUserId())[0];

        EUR_CRM_Territory__c territory = EUR_CRM_TestClassUtilityHelper.createTerritory(1,'EUR', UserInfo.getUserId(),region.id)[0];
        Id accountrecordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_BG_Wholesaler');

        //EUR_CRM_Postal_Code_Territory_Mapping__c mapping  = EUR_CRM_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , '12345' , territory.id, 'BG Off Trade Postal Code - Territory Mapping');
        //EUR_CRM_Postal_Code_Territory_Mapping__c mapping2  = EUR_CRM_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , '123456' , territory.id, 'BG Off Trade Postal Code - Territory Mapping');

        Id ctId1 = [SELECT id FROM RecordType Where DeveloperName = 'EUR_BG_Wholesalers_Customer_Taxonomy' Limit 1].id;
        Id ctId2 = [SELECT id FROM RecordType Where DeveloperName = 'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy' Limit 1].id;
        Id ctId3 = [SELECT id FROM RecordType Where DeveloperName = 'EUR_BG_Modern_Off_Trade_Customer_Taxonomy' Limit 1].id;
        
        List<EUR_CRM_Customer_Taxonomy__c> ctList = new List<EUR_CRM_Customer_Taxonomy__c>();
        EUR_CRM_Customer_Taxonomy__c sobj1 = new EUR_CRM_Customer_Taxonomy__c(
              Name = 'Wholesalers',// Outlet Taxonomy,
                RecordTypeId = ctId1
            );
        
        EUR_CRM_Customer_Taxonomy__c sobj2 = new EUR_CRM_Customer_Taxonomy__c(
              Name = 'BG T Off',// Outlet Taxonomy,
                RecordTypeId = ctId2
            );
        
        EUR_CRM_Customer_Taxonomy__c sobj3 = new EUR_CRM_Customer_Taxonomy__c(
              Name = 'BG M Off',// Outlet Taxonomy,
                RecordTypeId = ctId3
            );
        ctList.add(sobj1);
        ctList.add(sobj2);
        ctList.add(sobj3);
        
        insert ctList;
        
        EUR_CRM_Account__c  offTradeAccount1 = new EUR_CRM_Account__c();
        offTradeAccount1.EUR_CRM_Postal_Code__c = '12345';
        offTradeAccount1.recordtypeid = accountrecordtypeId;

        insert offTradeAccount1;
        Id configRTId = [select id from recordtype where developername = 'EUR_CRM_Running_Number' and sobjecttype = 'EUR_CRM_Apex_Configuration__c'][0].id;
        Id soRTId = [select id from recordtype where developername = 'EUR_BG_Indirect_Sales_Order' and sobjecttype = 'EUR_CRM_Sales_Order__c'][0].id;

        EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c(
            EUR_CRM_Country_Code__c = 'BG',
            EUR_CRM_Module__c = 'EUR_CRM_Running_Number',
            EUR_CRM_Prefix__c = 'BG-SO-',
            EUR_CRM_Running_Number__c = 1,
            recordtypeid = configRTId ,
            EUR_CRM_Running_Number_Length__c = 10
        );

        insert config;

        EUR_CRM_Sales_Order__c so = new EUR_CRM_Sales_Order__c(
            recordtypeid = soRTId ,
            EUR_CRM_Account__c =  offTradeAccount1.id
        );
        insert so;

        ApexPages.StandardController sc = new ApexPages.StandardController(so);
        EUR_CRM_NewSalesOrderPageController con = new EUR_CRM_NewSalesOrderPageController(sc);
        con.assignDefaultAndRedirect();
        
        // Calls the update trigger
        so.EUR_CRM_Name__c = 'Test Name';
        update so;
    }
}