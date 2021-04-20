@isTest
public class ASI_CRM_SG_Start_Simulation_ContractTest {
	public static testMethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id from ASI_TH_CRM_Contract__c limit 1];       
        test.startTest();
            ASI_CRM_SG_Start_Simulation_Contract.validateContract(contract.Id);
         contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
        update contract;
        ASI_CRM_SG_Start_Simulation_Contract.validateContract(contract.Id);
 		ASI_CRM_SG_Start_Simulation_Contract.validateContract(null);        
        test.stopTest();
    }
}