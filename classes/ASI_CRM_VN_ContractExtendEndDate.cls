/*********************************************************************************
 * Name: ASI_CRM_VN_ContractExtendEndDate
 * Description: update end date when user extend contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/02/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractExtendEndDate {
    
    public ASI_CRM_VN_ContractExtendEndDate() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList   = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        updateEndDate(filteredContractList);
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
		if(contractMap == null) {
        	return new List<ASI_CRM_VN_Contract__c>();
        }
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = new List<ASI_CRM_VN_Contract__c>();
        
        for(ASI_CRM_VN_Contract__c contract : contractList) {
        	if(contract.ASI_CRM_Original_End_Date__c != contractMap.get(contract.Id).ASI_CRM_Original_End_Date__c) {
            	filteredContractList.add(contract);
            }
        }
        
        return filteredContractList;
    }
    
    private void updateEndDate(List<ASI_CRM_VN_Contract__c> contractList) {
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            contract.ASI_CRM_End_Date__c = contract.ASI_CRM_New_End_Date__c;
            contract.ASI_CRM_New_End_Date__c = null;
            if(contract.ASI_CRM_Extend_Times__c == null) {
            	contract.ASI_CRM_Extend_Times__c = 1;
            } else {
            	contract.ASI_CRM_Extend_Times__c += 1;
            }
        }
    }
}