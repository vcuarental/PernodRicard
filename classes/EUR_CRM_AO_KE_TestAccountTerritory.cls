/*
Test Class for the following classes:

EUR_CRM_AO_KE_AccountTerritoryHandler
EUR_CRM_AO_TerritoryUpdateController
EUR_CRM_KE_TerritoryUpdateController
EUR_CRM_OutletToSupplierHandler

*/
@isTest
public class EUR_CRM_AO_KE_TestAccountTerritory{
    static User eurSysUser;
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }
   static testMethod  void testTerritoryHandler(){
        setUser();
        System.runAs(eurSysUser){

        Id aoAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_AO_Off_Trade'].id;
        Id aoTerritoryRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Territory__c' and developername ='EUR_AO_Territory'].id;
        Id aoRegionRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Region__c' and developername ='EUR_AO_Region'].id;
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=aoRegionRecordTypeId,name = 'testregion',EUR_CRM_Region_Owner__c = eurSysUser.id, ownerid = eurSysUser.id);
        insert region;
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(EUR_CRM_Region__c = region.id, recordtypeid=aoTerritoryRecordTypeId,name = 'testterritory',
            EUR_CRM_Territory_Owner__c = eurSysUser.id, EUR_CRM_Default__c = true);
        insert territory;
       Test.startTest();
        eur_crm_account__C account = new eur_crm_account__C(name='test account', recordtypeid=aoAccountRecordTypeId, EUR_CRM_Territory__c =null);
            account.EUR_CRM_Postal_Code__c = '112233';
        insert account;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(territory);
        EUR_CRM_AO_TerritoryUpdateController tc = new EUR_CRM_AO_TerritoryUpdateController(sc);
        tc.massUpdateAccounts(); 
        EUR_CRM_KE_TerritoryUpdateController tck = new EUR_CRM_KE_TerritoryUpdateController(sc);
        tck.massUpdateAccounts();
        Test.stopTest();

        }
   }
//   static testMethod  void testOutletToSupplierHandler(){
//        setUser();
//        System.runAs(eurSysUser){
//
//        Id aoAccountRecordTypeIdOff = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_AO_Off_Trade'].id;
//        Id aoAccountRecordTypeIdDist = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_AO_Distributor'].id;
//        Id MappingRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Outlet_to_Supplier_Mapping__c' + 'EUR_CRM_AO_Outlet_to_Supplier_Mapping');
//        Test.startTest();
//        eur_crm_account__C account = new eur_crm_account__C(EUR_CRM_Status__c = 'Active', name='test account', recordtypeid=aoAccountRecordTypeIdOff, EUR_CRM_Territory__c =null);
//        eur_crm_account__C supplier = new eur_crm_account__C(EUR_CRM_Status__c = 'Inactive',name='supplier', recordtypeid=aoAccountRecordTypeIdDist, EUR_CRM_Territory__c =null);
//            account.EUR_CRM_Postal_Code__c = '112233';
//        insert account;
//            supplier.EUR_CRM_Postal_Code__c = '112233';
//        insert supplier;
//        EUR_CRM_Outlet_to_Supplier_Mapping__c mapping = new EUR_CRM_Outlet_to_Supplier_Mapping__c(EUR_CRM_Outlet_Account__c = account.id, EUR_CRM_Supplier_Account__c = supplier.id, recordtypeid=MappingRecordTypeId);
//        insert mapping;
//       // account.EUR_CRM_Status__c = 'Active';
//      //  update account;
//        supplier.EUR_CRM_Status__c = 'Active';
//        update supplier;
//        Test.stopTest();
//
//        }
//    }
    
}