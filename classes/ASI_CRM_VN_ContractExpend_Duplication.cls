/*********************************************************************************
 * Name: ASI_CRM_VN_ContractExpend_Duplication
 * Description: Prevent the duplcation records of Contract Expenditure
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractExpend_Duplication {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    
    private final static String CONTRACT_EXPENDITURE_OBJECT_API = 'ASI_CRM_VN_Contract_Expenditure__c';
    
    private final static String CONTRACT_EXPENDITURE_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId(CONTRACT_EXPENDITURE_OBJECT_API + 'ASI_CRM_VN_Contract_Expenditure');
	private final static String CAPSULE_AGREEMENT_EXPENDITURE_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId(CONTRACT_EXPENDITURE_OBJECT_API + 'ASI_CRM_VN_Capsule_Agreement_Contract_Expenditure');
    
    public ASI_CRM_VN_ContractExpend_Duplication() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList   = (List<ASI_CRM_VN_Contract_Expenditure__c>) newList;
        Map<Id, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap = (Map<Id, ASI_CRM_VN_Contract_Expenditure__c>) oldMap;
        
        List<ASI_CRM_VN_Contract_Expenditure__c> filteredContractExpenditureList = filterContractExpenditure(contractExpenditureList, contractExpenditureMap);
    	checkDuplication(filteredContractExpenditureList);
    }
    
    private List<ASI_CRM_VN_Contract_Expenditure__c> filterContractExpenditure(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList, Map<Id, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap) {
    	if(contractExpenditureMap == null) {
        	return contractExpenditureList;
        }
        
       	List<ASI_CRM_VN_Contract_Expenditure__c> filteredContractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            if(contractExpenditure.ASI_CRM_VN_Item__c != contractExpenditureMap.get(contractExpenditure.Id).ASI_CRM_VN_Item__c && 
               contractExpenditure.RecordTypeId == CONTRACT_EXPENDITURE_RECORD_TYPE_ID) {
                filteredContractExpenditureList.add(contractExpenditure);
            }
            
            if(contractExpenditure.ASI_CRM_Sub_Brand__c != contractExpenditureMap.get(contractExpenditure.Id).ASI_CRM_Sub_Brand__c && 
               contractExpenditure.RecordTypeId == CAPSULE_AGREEMENT_EXPENDITURE_RECORD_TYPE_ID) {
                filteredContractExpenditureList.add(contractExpenditure);
            }
        }
        
        return filteredContractExpenditureList;
    }
    
    private void checkDuplication(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList) {
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> contractExpenditureIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            contractIdSet.add(contractExpenditure.ASI_CRM_VN_Contract__c);
            if(String.isNotBlank(contractExpenditure.Id)) {
            	contractExpenditureIdSet.add(contractExpenditure.Id);
            }
        }
        
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> existingContractExpenditureMap = mapContractAndContractExpenditure(retrieveContractExpenditureList(contractIdSet, contractExpenditureIdSet));
        
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> newContractExpenditureMap = mapContractAndContractExpenditure(contractExpenditureList);
        
        for(Id contractId : newContractExpenditureMap.keySet()) {
            List<ASI_CRM_VN_Contract_Expenditure__c> newContractExpenditureList = newContractExpenditureMap.get(contractId);
            List<ASI_CRM_VN_Contract_Expenditure__c> existingContractExpenditureList = existingContractExpenditureMap.get(contractId);
            
            for(Integer i = 0 ; i < contractExpenditureList.size() ; i++) {
                ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = contractExpenditureList.get(i);
                
                for(Integer compareIndex = i + 1; compareIndex < newContractExpenditureList.size() ; compareIndex++) {
                	ASI_CRM_VN_Contract_Expenditure__c compareContractExpenditure = newContractExpenditureList.get(compareIndex);
                    
                    if(contractExpenditure.ASI_CRM_VN_Item__c == compareContractExpenditure.ASI_CRM_VN_Item__c && 
                       contractExpenditure.RecordTypeId == CONTRACT_EXPENDITURE_RECORD_TYPE_ID) {
                        showError(contractExpenditure);
                    }
                    
                    if(contractExpenditure.ASI_CRM_Sub_Brand__c == compareContractExpenditure.ASI_CRM_Sub_Brand__c && 
                       contractExpenditure.RecordTypeId == CAPSULE_AGREEMENT_EXPENDITURE_RECORD_TYPE_ID) {
                        showError(contractExpenditure);
                    }
                }
                
                if(existingContractExpenditureList == null) {
                    continue;
                }
                
                for(ASI_CRM_VN_Contract_Expenditure__c existingContractExpenditure : existingContractExpenditureList) {
                    if(contractExpenditure.ASI_CRM_VN_Item__c == existingContractExpenditure.ASI_CRM_VN_Item__c && 
                       contractExpenditure.RecordTypeId == CONTRACT_EXPENDITURE_RECORD_TYPE_ID) {
                        showError(contractExpenditure);
                    }
                    
                    if(contractExpenditure.ASI_CRM_Sub_Brand__c == existingContractExpenditure.ASI_CRM_Sub_Brand__c && 
                       contractExpenditure.RecordTypeId == CAPSULE_AGREEMENT_EXPENDITURE_RECORD_TYPE_ID) {
                        showError(contractExpenditure);
                    }
                }
            }
        }
    }
    
    private Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> mapContractAndContractExpenditure(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList) {
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> contractExpenditureMap = new Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>>();
        
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            List<ASI_CRM_VN_Contract_Expenditure__c> tempContractExpenditureList;
            if(contractExpenditureMap.containsKey(contractExpenditure.ASI_CRM_VN_Contract__c)) {
            	tempContractExpenditureList = contractExpenditureMap.get(contractExpenditure.ASI_CRM_VN_Contract__c);
            } else {
            	tempContractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
            }
            tempContractExpenditureList.add(contractExpenditure);
            
            contractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Contract__c, tempContractExpenditureList);
        }
        
        return contractExpenditureMap;
    }
    
    private void showError(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure) {
        contractExpenditure.addError(Label.ASI_CRM_VN_DuplicatedContractExpend);
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Set<Id> contractIdSet, Set<Id> contractExpenditureIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) +  
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND Id not in : contractExpenditureIdSet';
        
    	return (List<ASI_CRM_VN_Contract_Expenditure__c>) Database.query(query);
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