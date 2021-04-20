/*********************************************************************************
 * Name: ASI_CRM_VN_DisplayListing_RollUpToExpen
 * Description: Roll up Display Listing amount to expenditure
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/01/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_DisplayListing_RollUpToExpen {
    
    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP  = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    
    private final static String APPROVED_STATUS = 'Complete';
    private final static String DISPLAY_LISTING_CONTRACT_EXPENDITURE = 'Display/Listing Fee';
    
    public ASI_CRM_VN_DisplayListing_RollUpToExpen() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> requestList   = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> requestMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        
        List<ASI_GiftBox_Request_Header__c> filteredRequestList = filterRequest(requestList, requestMap);
        rollupToContractExpenditure(filteredRequestList);
    }
    
    private List<ASI_GiftBox_Request_Header__c> filterRequest(List<ASI_GiftBox_Request_Header__c> requestList, Map<Id, ASI_GiftBox_Request_Header__c> requestMap) {
        if(requestMap == null) {
          return new List<ASI_GiftBox_Request_Header__c>();
        }
        
         List<ASI_GiftBox_Request_Header__c> filteredRequestList = new List<ASI_GiftBox_Request_Header__c>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            if(request.ASI_GiftBox_Status__c == APPROVED_STATUS &&
               requestMap.get(request.Id).ASI_GiftBox_Status__c != APPROVED_STATUS) {
              filteredRequestList.add(request);
            }
        }
        
        return filteredRequestList;
    }
    
    private void rollupToContractExpenditure(List<ASI_GiftBox_Request_Header__c> requestList) {
        Set<Id> requestIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            requestIdSet.add(request.Id);
            contractIdSet.add(request.ASI_CRM_VN_Contract__c);
        }
        
        List<sObject> requestItemList = (List<sObject>) retrieveRequestItemList(requestIdSet);
        List<sObject> contractExpenditureList = (List<sObject>) retrieveContractExpenditureList(contractIdSet);
        
        Map<Id, List<ASI_GiftBox_Request_Item__c>> requestHeaderItemMap = (Map<Id, List<ASI_GiftBox_Request_Item__c>>) convertToMasterDetailMap('ASI_GiftBox_Request_Id__c', requestItemList);
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> contractExpenditureMap = (Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>>) convertToMasterDetailMap('ASI_CRM_VN_Contract__c', contractExpenditureList);
    
      	List<ASI_CRM_VN_Contract_Expenditure__c> updateContractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            List<ASI_GiftBox_Request_Item__c> tempRequestItemList = requestHeaderItemMap.get(request.Id);
            List<ASI_CRM_VN_Contract_Expenditure__c> tempContractExpenditureList = contractExpenditureMap.get(request.ASI_CRM_VN_Contract__c);
            if(tempRequestItemList == null || tempRequestItemList.size() == 0 || 
               tempContractExpenditureList == null || tempContractExpenditureList.size() == 0) {
              continue;
            }
            
            Decimal amount = 0;
         	for(ASI_GiftBox_Request_Item__c requestItem : tempRequestItemList) {
                amount += (requestItem.ASI_CRM_Amount__c == null ? 0 : requestItem.ASI_CRM_Amount__c);
            }
            
            ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = tempContractExpenditureList.get(0);
            
            if(contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD') {
                  amount *= contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c;
            }
            
            if(contractExpenditure.ASI_CRM_Commit_Amount__c == null) {
              contractExpenditure.ASI_CRM_Commit_Amount__c = 0;
             }
            contractExpenditure.ASI_CRM_Commit_Amount__c += amount;
            updateContractExpenditureList.add(contractExpenditure);
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
    private List<ASI_GiftBox_Request_Item__c> retrieveRequestItemList(Set<Id> requestIdSet) {
      String query = 'SELECT ' + genQueryField(REQUEST_ITEM_FIELD_MAP) +  
                       ', ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'WHERE ASI_GiftBox_Request_Id__c in :requestIdSet';
        
      return (List<ASI_GiftBox_Request_Item__c>) Database.query(query);
    }
    
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Set<Id> contractIdSet) {
      String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) +  
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c ' + 
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_To_VND_Exchange_Rate__c, ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND ASI_CRM_VN_Item__c = :DISPLAY_LISTING_CONTRACT_EXPENDITURE';
        
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