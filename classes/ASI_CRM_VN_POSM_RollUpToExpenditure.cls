/*********************************************************************************
 * Name: ASI_CRM_VN_POSM_RollUpToExpenditure
 * Description: Roll up POSM amount to expenditure
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_POSM_RollUpToExpenditure {
    
    private final static Map<String, Schema.SObjectField> POSM_REQUEST_ITEM_FIELD_MAP  = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    
    private final static Map<String, String> itemCategoryExpenditureMap = new Map<String, String> {
    	'Podium stand'    => 'Podium Stands & Glorifiers',
        'Glorifier'       => 'Podium Stands & Glorifiers',
        'Glassware'       => 'Glassware (Including Ice Buckets)',
        'Dice & Dice Cup' => '',
        'Drink menus'     => 'Drink Menus'
    };
    
    private final static String WAITING_FOR_HR_REVIEW = 'Waiting for HR Review';
    
    public ASI_CRM_VN_POSM_RollUpToExpenditure() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> posmRequestList   = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> posmRequestMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        
        List<ASI_GiftBox_Request_Header__c> filteredPOSMRequestList = filterPOSMRequest(posmRequestList, posmRequestMap);
        System.debug('Debug Log : ' + filteredPOSMRequestList);
        rollupToContractExpenditure(filteredPOSMRequestList);
    }
    
    private List<ASI_GiftBox_Request_Header__c> filterPOSMRequest(List<ASI_GiftBox_Request_Header__c> posmRequestList, Map<Id, ASI_GiftBox_Request_Header__c> posmRequestMap) {
        if(posmRequestMap == null) {
        	return new List<ASI_GiftBox_Request_Header__c>();
        }
        
       	List<ASI_GiftBox_Request_Header__c> posmRequestHeaderList = new List<ASI_GiftBox_Request_Header__c>();
        for(ASI_GiftBox_Request_Header__c posmRequest : posmRequestList) {
            if(posmRequest.ASI_GiftBox_Status__c == WAITING_FOR_HR_REVIEW &&
               posmRequestMap.get(posmRequest.Id).ASI_GiftBox_Status__c != WAITING_FOR_HR_REVIEW) {
            	posmRequestHeaderList.add(posmRequest);
            }
        }
        
        return posmRequestHeaderList;
    }
    
    private void rollupToContractExpenditure(List<ASI_GiftBox_Request_Header__c> posmRequestList) {
        Set<Id> posmRequestIdSet = new Set<Id>();
        Set<Id> contractIdSet    = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c posmRequest : posmRequestList) {
            posmRequestIdSet.add(posmRequest.Id);
            contractIdSet.add(posmRequest.ASI_CRM_VN_Contract__c);
        }
        
        List<sObject> posmRequestItemList = (List<sObject>) retrievePOSMRequestItemList(posmRequestIdSet);
        List<sObject> contractExpenditureList = (List<sObject>) retrieveContractExpenditureList(contractIdSet);
        
        Map<Id, List<ASI_GiftBox_Request_Item__c>> posmRequestHeaderItemMap = (Map<Id, List<ASI_GiftBox_Request_Item__c>>) convertToMasterDetailMap('ASI_GiftBox_Request_Id__c', posmRequestItemList);
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> contractExpenditureMap = (Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>>) convertToMasterDetailMap('ASI_CRM_VN_Contract__c', contractExpenditureList);
		
        List<ASI_CRM_VN_Contract_Expenditure__c> updateContractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        for(ASI_GiftBox_Request_Header__c posmRequest : posmRequestList) {
            List<ASI_GiftBox_Request_Item__c> tempPOSMRequestItemList = posmRequestHeaderItemMap.get(posmRequest.Id);
            List<ASI_CRM_VN_Contract_Expenditure__c> tempContractExpenditureList = contractExpenditureMap.get(posmRequest.ASI_CRM_VN_Contract__c);
            if(tempPOSMRequestItemList == null || 
               tempContractExpenditureList == null) {
            	continue;
            }
            
            Map<String, ASI_CRM_VN_Contract_Expenditure__c> itemContractExpenditureMap = new Map<String, ASI_CRM_VN_Contract_Expenditure__c>();
            for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : tempContractExpenditureList) {
                itemContractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure);
            }
            
            Map<String, Decimal> amountPerItem = new Map<String, Decimal>();
            for(ASI_GiftBox_Request_Item__c posmRequestItem : tempPOSMRequestItemList) {
            	Decimal amount;
                if(amountPerItem.containsKey(posmRequestItem.ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c)) {
                	amount = amountPerItem.get(posmRequestItem.ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c);
                } else {
                	amount = 0;
                }
                amount += (posmRequestItem.ASI_CRM_Amount__c == null ? 0 : posmRequestItem.ASI_CRM_Amount__c);
                
                amountPerItem.put(posmRequestItem.ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c, amount);
            }
            
            for(String itemName : amountPerItem.keySet()) {
                Decimal amount = amountPerItem.get(itemName);
                if(itemContractExpenditureMap.containsKey(itemCategoryExpenditureMap.get(itemName)) == false) {
                    continue;
                }
                
                ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = itemContractExpenditureMap.get(itemCategoryExpenditureMap.get(itemName));
                
                if(contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD') {
                	amount *= contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c;
                }
                
                if(contractExpenditure.ASI_CRM_Commit_Amount__c == null) {
                	contractExpenditure.ASI_CRM_Commit_Amount__c = 0;
                }
                contractExpenditure.ASI_CRM_Commit_Amount__c += amount;
                updateContractExpenditureList.add(contractExpenditure);
            }
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
    private List<ASI_GiftBox_Request_Item__c> retrievePOSMRequestItemList(Set<Id> posmRequestIdSet) {
    	String query = 'SELECT ' + genQueryField(POSM_REQUEST_ITEM_FIELD_MAP) +  
                       ', ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'Where ASI_GiftBox_Request_Id__c in :posmRequestIdSet';
        
    	return (List<ASI_GiftBox_Request_Item__c>) Database.query(query);
  	}
    
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) +  
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c ' + 
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_To_VND_Exchange_Rate__c, ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'Where ASI_CRM_VN_Contract__c in :contractIdSet';
        
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