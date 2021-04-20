@isTest
public class EUR_CRM_Test_OutletToSupplierHandler {

    public static testmethod void testOutletToSupplier() {
        List<EUR_CRM_Account__c> accountList = new List<EUR_CRM_Account__c>();
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'AO Off Trade')[0];
        EUR_CRM_Account__c account2 = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'AO Distributor')[0];
        account2.EUR_CRM_Status__c = 'Inactive';
        accountList.add(account);
        accountList.add(account2);
        insert accountList;
        
        EUR_CRM_Outlet_to_Supplier_Mapping__c outletSupplierMapping = new EUR_CRM_Outlet_to_Supplier_Mapping__c();
        outletSupplierMapping.RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Outlet_to_Supplier_Mapping__c', 'EUR AO Outlet to Supplier Mapping');
        outletSupplierMapping.EUR_CRM_Outlet_Account__c = account.Id;
        outletSupplierMapping.EUR_CRM_Supplier_Account__c = account2.Id;
        insert outletSupplierMapping;
        
        account2.EUR_CRM_Status__c = 'Active';
        update account2;
    }
    
}