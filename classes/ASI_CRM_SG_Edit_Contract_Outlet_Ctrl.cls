public class ASI_CRM_SG_Edit_Contract_Outlet_Ctrl {
	@AuraEnabled
    public Static String getRecord(String recordId){
        try{
        ASI_TH_CRM_Contract__c contractRec = [Select Id,Name,RecordType.DeveloperName,ASI_TH_CRM_Contract_Status__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
        String recordtype = contractRec.RecordType.DeveloperName == 'ASI_CRM_SG_Proposal_Read_Only' ? 'ASI_CRM_SG_Proposal' : 'ASI_CRM_SG_Contract'; 
            String originalContractName1 = contractRec.Name; 
            String originalContractName = originalContractName1.substring(0,15); 
            String queryRevisingContract = 'SELECT Id, Name from ASI_TH_CRM_Contract__c where id <> \''+recordId+'\' and recordtype.developername = \'' + recordtype + '\' and name like \'' + originalContractName + '%\' and ASI_TH_CRM_Contract_Status__c in (\'Draft\',\'Submitted\',\'Contract Rejected\') Limit 1'; 
            List<ASI_TH_CRM_Contract__c> revisingContractArray  = Database.query(queryRevisingContract); 
         String simulationRecordType = 'ASI_CRM_SG_Contract_Target_Simulation';
            String querySimulationLineItem = 'SELECT Id from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = \''+recordId+'\' and recordtype.developername = \'' + simulationRecordType + '\' Limit 1';
            List<ASI_CRM_ContractTarget__c> simulationContractLineItemArray = Database.query(querySimulationLineItem);

            if (revisingContractArray != null && revisingContractArray.size() > 0) {
                return 'Please continue your revision on ' + revisingContractArray[0].Name;
            }
            else if (contractRec.ASI_TH_CRM_Contract_Status__c != 'Contract Approved') {
                return 'This contract cannot edit contract outlets. Only approved contract is allow to click.';
            }
            else if (simulationContractLineItemArray != null && simulationContractLineItemArray.size() > 0) {
                return 'This contract has existed simulation data. It cannot edit contract outlets.';
            }
            else {
				return 'Success';               
            }
        }catch(Exception e)  {
            return e.getMessage();
        }
    }
}