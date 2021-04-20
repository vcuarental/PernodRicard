/*********************************************************************************
 * Name: ASI_CRM_VN_ContractSetDraft
 * Description: Check when contract set to draft
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractSetDraft {
    
    private final static Map<String, Schema.SObjectField> REQUEST_FIELD_MAP = Schema.SObjectType.ASI_GiftBox_Request_Header__c.fields.getMap();
    
    private final static String DRAFT_STATUS = 'Draft';
    
    public ASI_CRM_VN_ContractSetDraft() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList   = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        checkRequest(filteredContractList);
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
		if(contractMap == null) {
        	return new List<ASI_CRM_VN_Contract__c>();
        }
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = new List<ASI_CRM_VN_Contract__c>();
        
        for(ASI_CRM_VN_Contract__c contract : contractList) {
        	if(contract.ASI_CRM_Contract_Status__c != contractMap.get(contract.Id).ASI_CRM_Contract_Status__c && 
               contract.ASI_CRM_Contract_Status__c == DRAFT_STATUS) {
            	filteredContractList.add(contract);
            }
        }
        
        return filteredContractList;
    }
    
    private void checkRequest(List<ASI_CRM_VN_Contract__c> contractList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            contractIdSet.add(contract.Id);
        }
        
        Set<Id> contractContainRequestIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c request : retrieveRequestList(contractIdSet)) {
        	contractContainRequestIdSet.add(request.ASI_CRM_VN_Contract__c);
        }
        
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            if(contractContainRequestIdSet.contains(contract.Id)) {
                showError(contract);
            }
        }
    }
    
    private void showError(ASI_CRM_VN_Contract__c contract) {
        contract.addError(Label.ASI_CRM_VN_Contract_Linked_Request);
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_GiftBox_Request_Header__c> retrieveRequestList(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(REQUEST_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Header__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet';
        
    	return (List<ASI_GiftBox_Request_Header__c>) Database.query(query);
  	}
    
    /***************
  	Tools Function
  	***************/
	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      	String queryField = '';
      	for(String fields : fieldMap.keySet()) {
       		queryField += fields + ',';
   		}
    	return queryField.subString(0, queryField.length() - 1);
    }
}