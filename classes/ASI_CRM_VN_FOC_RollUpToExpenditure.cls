/*********************************************************************************
 * Name: ASI_CRM_VN_FOC_RollUpToExpenditure
 * Description: Roll up FOC amount to expenditure
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_FOC_RollUpToExpenditure {
    
    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP  = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    
    private final static String APPROVED_STATUS = 'Complete';
    private final static String FOC_CONTRACT_EXPENDITURE = 'FOC Bottles';
    
    public ASI_CRM_VN_FOC_RollUpToExpenditure() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> focRequestList   = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> focRequestMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        
        List<ASI_GiftBox_Request_Header__c> filteredFOCRequestList = filterFOCRequest(focRequestList, focRequestMap);
        rollupToContractExpenditure(filteredFOCRequestList);
    }
    
    private List<ASI_GiftBox_Request_Header__c> filterFOCRequest(List<ASI_GiftBox_Request_Header__c> focRequestList, Map<Id, ASI_GiftBox_Request_Header__c> focRequestMap) {
        if(focRequestMap == null) {
        	return new List<ASI_GiftBox_Request_Header__c>();
        }
        
       	List<ASI_GiftBox_Request_Header__c> filteredFOCRequestList = new List<ASI_GiftBox_Request_Header__c>();
        for(ASI_GiftBox_Request_Header__c focRequest : focRequestList) {
            if(focRequest.ASI_GiftBox_Status__c == APPROVED_STATUS &&
               focRequestMap.get(focRequest.Id).ASI_GiftBox_Status__c != APPROVED_STATUS) {
            	filteredFOCRequestList.add(focRequest);
            }
        }
        
        return filteredFOCRequestList;
    }
    
    private void rollupToContractExpenditure(List<ASI_GiftBox_Request_Header__c> focRequestList) {
        Set<Id> focRequestIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c focRequest : focRequestList) {
            focRequestIdSet.add(focRequest.Id);
            contractIdSet.add(focRequest.ASI_CRM_VN_Contract__c);
        }
        
        List<sObject> focRequestItemList = (List<sObject>) retrieveFOCRequestItemList(focRequestIdSet);
        List<sObject> contractExpenditureList = (List<sObject>) retrieveContractExpenditureList(contractIdSet);
        
        Map<Id, List<ASI_GiftBox_Request_Item__c>> focRequestHeaderItemMap = (Map<Id, List<ASI_GiftBox_Request_Item__c>>) convertToMasterDetailMap('ASI_GiftBox_Request_Id__c', focRequestItemList);
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> contractExpenditureMap = (Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>>) convertToMasterDetailMap('ASI_CRM_VN_Contract__c', contractExpenditureList);
    
    	List<ASI_CRM_VN_Contract_Expenditure__c> updateContractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        
        for(ASI_GiftBox_Request_Header__c focRequest : focRequestList) {
            List<ASI_GiftBox_Request_Item__c> tempFOCRequestItemList = focRequestHeaderItemMap.get(focRequest.Id);
            List<ASI_CRM_VN_Contract_Expenditure__c> tempContractExpenditureList = contractExpenditureMap.get(focRequest.ASI_CRM_VN_Contract__c);
            if(tempFOCRequestItemList == null || tempFOCRequestItemList.size() == 0 || 
               tempContractExpenditureList == null || tempContractExpenditureList.size() == 0) {
            	continue;
            }
            
            Decimal amount = 0;
     		for(ASI_GiftBox_Request_Item__c focRequestItem : tempFOCRequestItemList) {
                amount += (focRequestItem.ASI_CRM_Amount__c == null ? 0 : focRequestItem.ASI_CRM_Amount__c);
            }
            
            ASI_CRM_VN_Contract_Expenditure__c focContractExpenditure = tempContractExpenditureList.get(0);
            
            if(focContractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD') {
                	amount *= focContractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c;
            }
            
            if(focContractExpenditure.ASI_CRM_Commit_Amount__c == null) {
            	focContractExpenditure.ASI_CRM_Commit_Amount__c = 0;
           	}
            focContractExpenditure.ASI_CRM_Commit_Amount__c += amount;
            updateContractExpenditureList.add(focContractExpenditure);
        }
        
        if(updateContractExpenditureList.size() > 0) {
        	update updateContractExpenditureList;
        }
    }
    
    private Map<Id, List<sObject>> convertToMasterDetailMap(String keyFieldName, List<sObject> detailList) {
        Map<Id, List<sObject>> sObjectMap = new Map<Id, List<sObject>>();
        for(sObject detail : detailList) {
            List<sObject> sObjectList;
            Id key = (Id) detail.get(keyFieldName);
            if(sObjectMap.containsKey(key)) {
            	sObjectList = sObjectMap.get(key);
            } else {
                sObjectList = new List<sObject>();
            }
            sObjectList.add(detail);
            sObjectMap.put(key, sObjectList);
        }
        return sObjectMap;
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_GiftBox_Request_Item__c> retrieveFOCRequestItemList(Set<Id> focRequestIdSet) {
    	String query = 'SELECT ' + genQueryField(REQUEST_ITEM_FIELD_MAP) +  
                       ', ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'WHERE ASI_GiftBox_Request_Id__c in :focRequestIdSet';
        
    	return (List<ASI_GiftBox_Request_Item__c>) Database.query(query);
  	}
    
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) +  
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c ' + 
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_To_VND_Exchange_Rate__c, ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND ASI_CRM_VN_Item__c = :FOC_CONTRACT_EXPENDITURE';
        
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