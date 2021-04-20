@isTest
public class ASI_CRM_SG_Submit_for_ApprovalCtrl_Test {
    public static testMethod void test1(){
    	ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
        ASI_CRM_AccountsAdditionalField__c customer = [Select Id from ASI_CRM_AccountsAdditionalField__c limit 1];
        test.startTest();
        	ASI_CRM_SG_Submit_for_ApprovalCtrl.validateRecord(customer.Id);
        contact ct = new Contact(ASI_CRM_AccountAdditionalField__c = customer.Id, LastName = 'test');
        insert ct;
        ASI_CRM_SG_Submit_for_ApprovalCtrl.validateRecord(customer.Id);
        ASI_CRM_SG_Submit_for_ApprovalCtrl.validateRecord(null);
        test.stopTest();
    }
}