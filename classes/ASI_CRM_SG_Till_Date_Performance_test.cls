@isTest
public class ASI_CRM_SG_Till_Date_Performance_test {
	public static testMethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id from ASI_TH_CRM_Contract__c limit 1];       
        test.startTest();
            ASI_CRM_SG_Till_Date_Performance_ctrl.getContract(contract.Id);      
        test.stopTest();
    }
}