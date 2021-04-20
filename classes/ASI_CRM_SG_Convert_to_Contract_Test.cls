@isTest
public class ASI_CRM_SG_Convert_to_Contract_Test {
       public static testMethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id from ASI_TH_CRM_Contract__c limit 1];       
        test.startTest();
            ASI_CRM_SG_Build_Contract_Ctrl.validateContract(null);
            ASI_CRM_SG_Build_Contract_Ctrl.validateContract(contract.Id);
            contract.ASI_TH_CRM_Contract_Status__c = 'Proposal Approved';
            contract.ASI_CRM_Contract_Exist_Before_RTM__c = true;
        update contract;
        ASI_CRM_SG_Convert_to_Contract.validateContract(contract.Id);
           contract.ASI_TH_CRM_Contract_Status__c = 'Proposal Converted';
           update contract;
        ASI_CRM_SG_Convert_to_Contract.validateContract(contract.Id);
             contract.ASI_TH_CRM_Contract_Status__c = 'Proposal Rejected';
           update contract;
        ASI_CRM_SG_Convert_to_Contract.validateContract(contract.Id);
        ASI_CRM_SG_Convert_to_Contract.validateContract(null);
        test.stopTest();
    }
}