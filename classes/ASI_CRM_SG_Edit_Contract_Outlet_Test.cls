@isTest
public class ASI_CRM_SG_Edit_Contract_Outlet_Test {
	 public static testMethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id, Name from ASI_TH_CRM_Contract__c limit 1];
        test.startTest();
         ASI_CRM_SG_Edit_Contract_Outlet_Ctrl.getRecord(null);
            ASI_CRM_SG_Edit_Contract_Outlet_Ctrl.getRecord(contract.Id);
         contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
         update contract;
         ASI_CRM_SG_Edit_Contract_Outlet_Ctrl.getRecord(contract.Id);
        test.stopTest();
    }
}