@isTest
public class ASI_CRM_SG_EditContractPage_Comp_Test {
	public static testMethod void test1(){
        Id ProposalrecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        Id ProposalROrecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');

        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id, Name from ASI_TH_CRM_Contract__c limit 1];
        test.startTest();
         ASI_CRM_SG_EditContractPage_Comp_Ctlr.initializeContract(contract.Id,ProposalrecordTypeId);
		ASI_CRM_SG_EditContractPage_Comp_Ctlr.initializeContract(contract.Id,ProposalROrecordTypeId);  
        ASI_CRM_AccountsAdditionalField__c customer = [Select Id from ASI_CRM_AccountsAdditionalField__c limit 1];
        ASI_CRM_SG_EditContractPage_Comp_Ctlr.save(customer.Id);
        test.stopTest();
    }
}