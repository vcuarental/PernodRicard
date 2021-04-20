/*********************************************************************************
 * Name: ASI_CRM_VN_ContractUpdateValidClaimDate
 * Description: Update contract valid claim date
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/06/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractUpdateValidClaimDate {
    public ASI_CRM_VN_ContractUpdateValidClaimDate() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList   = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        updateClaimDate(filteredContractList);
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
        if(contractMap == null)
			return contractList;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = new List<ASI_CRM_VN_Contract__c>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            ASI_CRM_VN_Contract__c oldContract = (ASI_CRM_VN_Contract__c) contractMap.get(contract.Id);
            if ((contract.ASI_CRM_Contract_Status__c == 'Closed' && oldContract.ASI_CRM_Contract_Status__c != 'Closed') || 
                (contract.ASI_CRM_Contract_Status__c == 'Closed(Terminated)' && oldContract.ASI_CRM_Contract_Status__c != 'Closed(Terminated)')) {
                filteredContractList.add(contract);
            } else if(contract.ASI_CRM_End_Date__c != oldContract.ASI_CRM_End_Date__c) {
                filteredContractList.add(contract);
            }
        }
        
        return filteredContractList;
    }
    
    private void updateClaimDate(List<ASI_CRM_VN_Contract__c> contractList) {
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            Date lastDate;
            if(contract.ASI_CRM_Contract_Status__c == 'Closed' || contract.ASI_CRM_Contract_Status__c == 'Closed(Terminated)') 
                lastDate = Date.today();
            else 
                lastDate = contract.ASI_CRM_End_Date__c;
            
            contract.ASI_CRM_Valid_Claim_Date__c = lastDate.addMonths(Integer.valueOf(ASI_CRM_VN_Settings__c.getInstance().ASI_CRM_VN_Expired_Contract_Valid_Month__c));
        }
    }
}