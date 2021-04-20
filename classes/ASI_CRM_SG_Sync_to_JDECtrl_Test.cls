@isTest
public class ASI_CRM_SG_Sync_to_JDECtrl_Test {
    public static testmethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
        ASI_CRM_AccountsAdditionalField__c customer = [Select Id from ASI_CRM_AccountsAdditionalField__c limit 1];
        test.startTest();
        ASI_CRM_SG_Sync_to_JDECtrl.updateCustomer(customer.Id);
        customer.ASI_CRM_SG_Search_Type__c = 'C - Customer';
        update customer;
        ASI_CRM_SG_Sync_to_JDECtrl.updateCustomer(customer.Id); 
        customer.ASI_CRM_ToJDE__c = true;
        update customer;
        ASI_CRM_SG_Sync_to_JDECtrl.updateCustomer(customer.Id); 
        test.stopTest();
    }
}