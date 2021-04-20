/*********************************************************************************
 * Name: ASI_CRM_VN_ContractCheckDelete
 * Description: Check can contract record be deleted
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/08/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractCheckDelete {
    
    private final static String CONTRACT_STATUS_ALLOW_DELETE = 'Draft'; 
    
    public ASI_CRM_VN_ContractCheckDelete() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
    	List<ASI_CRM_VN_Contract__c> contractList   = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        checkDelete(filteredContractList);
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
    	return contractMap.values();
    }
    
    private void checkDelete(List<ASI_CRM_VN_Contract__c> contractList) {
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            if(contract.ASI_CRM_Contract_Status__c == CONTRACT_STATUS_ALLOW_DELETE) {
            	continue;
            } else {
            	contract.addError(Label.ASI_CRM_VN_Contract_Cannot_Be_Delete);
            }
        }
    }
}