/*********************************************************************************
 * Name: ASI_CRM_VN_Contract_Duplication
 * Description: Prevent the duplication records of Contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 23/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_Contract_Duplication {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
    
    private final static Set<String> RECORD_TYPE_FILTER = new Set<String> {
    	'ASI_CRM_VN_Contract',
        'ASI_CRM_VN_Capsule_Agreement_Contract'
    };
    
    private final static String CLOSED_STATUS = 'Closed';
    
    public ASI_CRM_VN_Contract_Duplication() {    
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        if(!ASI_MFM_Function.bypassTriggersFunction('ASI_VN_Admin')){
            checkDuplication(filteredContractList);
        }
        
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
		if(contractMap == null) {
            return contractList;
        }
        
        List<ASI_CRM_VN_Contract__c> filterContractList = new List<ASI_CRM_VN_Contract__c>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            if(contract.ASI_CRM_Outlet_WS__c == contractMap.get(contract.Id).ASI_CRM_Outlet_WS__c && 
               contract.ASI_CRM_Start_Date__c == contractMap.get(contract.Id).ASI_CRM_Start_Date__c &&
               contract.ASI_CRM_End_Date__c == contractMap.get(contract.Id).ASI_CRM_End_Date__c) {
                continue;
            } else {
            	filterContractList.add(contract);
            }
        }
        
        return filterContractList;
    }
    
    private void checkDuplication(List<ASI_CRM_VN_Contract__c> contractList) {
    	List<ASI_CRM_VN_Contract__c> existingContractList = retrieveContractList();
        
        for(Integer index = 0 ; index < contractList.size() ; index ++) {
        	ASI_CRM_VN_Contract__c contract = contractList.get(index);
            
            for(Integer compareIndex = index + 1 ; compareIndex < contractList.size() ; compareIndex++) {
            	ASI_CRM_VN_Contract__c compareContract = contractList.get(compareIndex);
                
                if(compare(contract, compareContract)) {
                    showError(contract);
                }
            }
            
            for(ASI_CRM_VN_Contract__c existingContract : existingContractList) {
                if(compare(contract, existingContract)) {
                    showError(contract);
                }
            }
            
        }
    }

    @TestVisible
    private Boolean compare(ASI_CRM_VN_Contract__c contractOne, ASI_CRM_VN_Contract__c contractTwo) {
        if(contractOne.Id == contractTwo.Id) {
        	return false;
        }
        
        if(contractOne.ASI_CRM_Outlet_WS__c == contractTwo.ASI_CRM_Outlet_WS__c) {
            Date endDate = contractTwo.ASI_CRM_Closed_Date__c == null ? contractTwo.ASI_CRM_End_Date__c : contractTwo.ASI_CRM_Closed_Date__c;
            
            System.debug(endDate);
            
            if(contractOne.ASI_CRM_Start_Date__c <= contractTwo.ASI_CRM_Start_Date__c && 
               contractOne.ASI_CRM_End_Date__c >= contractTwo.ASI_CRM_Start_Date__c) {
                return true;
            }
            
            if(contractOne.ASI_CRM_Start_Date__c >= contractTwo.ASI_CRM_Start_Date__c &&  contractOne.ASI_CRM_End_Date__c <= endDate) {
            	return true;
            }
            
            if(contractOne.ASI_CRM_Start_Date__c <= endDate && contractOne.ASI_CRM_End_Date__c >= endDate) {
            	return true;
            }
        }
        
        return false;
    }
    
    private void showError(ASI_CRM_VN_Contract__c contract) {
        contract.addError(Label.ASI_CRM_VN_DuplicateContract);
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract__c> retrieveContractList() {
    	String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'Where RecordType.DeveloperName in :RECORD_TYPE_FILTER ';
        
    	return (List<ASI_CRM_VN_Contract__c>) Database.query(query);
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