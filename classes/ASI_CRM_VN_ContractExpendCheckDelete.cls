/*********************************************************************************
 * Name: ASI_CRM_VN_ContractExpendCheckDelete
 * Description: Check can contract expenditure record be deleted
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractExpendCheckDelete {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP     = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
	private final static String CONTRACT_STATUS_ALLOW_DELETE = 'Draft'; 
    
    public ASI_CRM_VN_ContractExpendCheckDelete() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
    	List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList   = (List<ASI_CRM_VN_Contract_Expenditure__c>) newList;
        Map<Id, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap = (Map<Id, ASI_CRM_VN_Contract_Expenditure__c>) oldMap;
        
        List<ASI_CRM_VN_Contract_Expenditure__c> filteredContractExpenditureList = filterContractExpenditure(contractExpenditureList, contractExpenditureMap);
        checkDelete(filteredContractExpenditureList);
    }
    
    private List<ASI_CRM_VN_Contract_Expenditure__c> filterContractExpenditure(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList, Map<Id, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap) {
    	return contractExpenditureMap.values();
    }
    
    private void checkDelete(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList) {
    	Set<Id> contractIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            contractIdSet.add(contractExpenditure.ASI_CRM_VN_Contract__c);
        }
        
        Map<Id, ASI_CRM_VN_Contract__c> contractIdMap = new Map<Id, ASI_CRM_VN_Contract__c>(retrieveContractList(contractIdSet));
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            ASI_CRM_VN_Contract__c tempContract = contractIdMap.get(contractExpenditure.ASI_CRM_VN_Contract__c);
            if(tempContract.ASI_CRM_Contract_Status__c == CONTRACT_STATUS_ALLOW_DELETE) {
            	continue;
            } else {
            	contractExpenditure.addError(Label.ASI_CRM_VN_Contract_Expend_Cannot_Be_Deleted);
            }
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract__c> retrieveContractList(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'Where Id in :contractIdSet';
        
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