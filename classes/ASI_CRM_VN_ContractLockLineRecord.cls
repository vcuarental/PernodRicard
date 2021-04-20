/*********************************************************************************
 * Name: ASI_CRM_VN_ContractLockLineRecord
 * Description: Lock the line item when contract submit for approval
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 24/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractLockLineRecord {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> BOTTLE_ANALYSIS_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Bottle_Analysis__c.fields.getMap();
    
    private final static String CONTRACT_SUBMITTED = 'Submitted';
    private final static String CONTRACT_DRAFT     = 'Draft';
    
    private final static String CONTRACT_EXPENDITURE_OBJECT_NAME = 'ASI_CRM_VN_Contract_Expenditure__c';
    private final static String BOTTLE_ANALYSIS_OBJECT_NAME = 'ASI_CRM_VN_Bottle_Analysis__c';
    
    private final static Id CONTRACT_EXPENDITURE_RECORD_TYPE = Global_RecordTypeCache.getRtId(CONTRACT_EXPENDITURE_OBJECT_NAME + 'ASI_CRM_VN_Contract_Expenditure');
    private final static Id CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY = Global_RecordTypeCache.getRtId(CONTRACT_EXPENDITURE_OBJECT_NAME + 'ASI_CRM_VN_Contract_Expenditure_Read_Only');
    
    private final static Id CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE = Global_RecordTypeCache.getRtId(CONTRACT_EXPENDITURE_OBJECT_NAME + 'ASI_CRM_VN_Capsule_Agreement_Contract_Expenditure');
    private final static Id CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY = Global_RecordTypeCache.getRtId(CONTRACT_EXPENDITURE_OBJECT_NAME + 'ASI_CRM_VN_Capsule_Agreement_Contract_Expenditure_Read_Only');
    
    private final static Id BOTTLE_ANALYSIS_RECORD_TYPE = Global_RecordTypeCache.getRtId(BOTTLE_ANALYSIS_OBJECT_NAME + 'ASI_CRM_VN_Bottle_Analysis');
    private final static Id BOTTLE_ANALYSIS_RECORD_TYPE_READ_ONLY = Global_RecordTypeCache.getRtId(BOTTLE_ANALYSIS_OBJECT_NAME + 'ASI_CRM_VN_Bottle_Analysis_Read_Only');
    
    public ASI_CRM_VN_ContractLockLineRecord() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        if(filteredContractList != null) {
        	lockLineRecord(filteredContractList);
        }
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
		if(contractMap == null) {
            return null;
        }
        
        List<ASI_CRM_VN_Contract__c> filterContractList = new List<ASI_CRM_VN_Contract__c>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            if(contract.ASI_CRM_Contract_Status__c == CONTRACT_SUBMITTED && 
               contractMap.get(contract.Id).ASI_CRM_Contract_Status__c == CONTRACT_DRAFT) {
            	filterContractList.add(contract);
            }
            
            if(contract.ASI_CRM_Contract_Status__c == CONTRACT_DRAFT && 
               contractMap.get(contract.Id).ASI_CRM_Contract_Status__c == CONTRACT_SUBMITTED) {
            	filterContractList.add(contract);
            }
        }
        
        return filterContractList;
    }
    
    private void lockLineRecord(List<ASI_CRM_VN_Contract__c> contractList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            contractIdSet.add(contract.Id);
        }
        
        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = retrieveContractExpenditureList(contractIdSet);
        List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList = retrieveBottleAnalysisList(contractIdSet);
        
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            if(contractExpenditure.RecordTypeId == CONTRACT_EXPENDITURE_RECORD_TYPE) {
            	contractExpenditure.RecordTypeId = CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY;
            } else if(contractExpenditure.RecordTypeId == CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE) {
                contractExpenditure.RecordTypeId = CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY;
            } else if(contractExpenditure.RecordTypeId == CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY) {
                contractExpenditure.RecordTypeId = CONTRACT_EXPENDITURE_RECORD_TYPE;
            } else if(contractExpenditure.RecordTypeId == CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY) {
                contractExpenditure.RecordTypeId = CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE;
            }
        }
        
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            if(bottleAnalysis.RecordTypeId == BOTTLE_ANALYSIS_RECORD_TYPE) {
                bottleAnalysis.RecordTypeId = BOTTLE_ANALYSIS_RECORD_TYPE_READ_ONLY;
            } else if(bottleAnalysis.RecordTypeId == BOTTLE_ANALYSIS_RECORD_TYPE_READ_ONLY) {
                bottleAnalysis.RecordTypeId = BOTTLE_ANALYSIS_RECORD_TYPE;
            }
        }
        
        if(contractExpenditureList.size() > 0) {
            update contractExpenditureList;
        }
        
        if(bottleAnalysisList.size() > 0) {
            update bottleAnalysisList;
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet';
        
    	return (List<ASI_CRM_VN_Contract_Expenditure__c>) Database.query(query);
  	}
    
	private List<ASI_CRM_VN_Bottle_Analysis__c> retrieveBottleAnalysisList(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(BOTTLE_ANALYSIS_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Bottle_Analysis__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet';
        
    	return (List<ASI_CRM_VN_Bottle_Analysis__c>) Database.query(query);
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