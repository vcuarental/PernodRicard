/*********************************************************************************
 * Name: ASI_CRM_VN_DisplayListing_CheckBalance
 * Description: Check the balance amount of Display Listing Request before insert/update
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 23/01/2018       Hugo Cheung             Created          
 * 2018-10-18       Vincent Lam             [VL 1.0] ICM119302541  fix bug
*/
public class ASI_CRM_VN_DisplayListing_CheckBalance {
    
    private final static Map<String, Schema.SObjectField> REQUEST_HEADER_FIELD_MAP       = Schema.SObjectType.ASI_GiftBox_Request_Header__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP         = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> INVENTORY_MASTER_FIELD_MAP     = Schema.SObjectType.ASI_GiftBox_Inventory_Master__c.fields.getMap();
    
    private final static String DISPLAY_LISTING_CONTRACT_EXPENDITURE = 'Display/Listing Fee';
    
    public ASI_CRM_VN_DisplayListing_CheckBalance() {
        
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Item__c> requestItemList   = (List<ASI_GiftBox_Request_Item__c>) newList;
        Map<Id, ASI_GiftBox_Request_Item__c> requestItemMap = (Map<Id, ASI_GiftBox_Request_Item__c>) oldMap;
        
        List<ASI_GiftBox_Request_Item__c> filteredRequestItemList = filterRequestItem(requestItemList, requestItemMap);
		checkBalanceAmount(filteredRequestItemList);
    }
    
    private List<ASI_GiftBox_Request_Item__c> filterRequestItem(List<ASI_GiftBox_Request_Item__c> requestItemList, Map<Id, ASI_GiftBox_Request_Item__c> requestItemMap) {
    	if(requestItemMap == null) {
        	return requestItemList;
        }
        
        List<ASI_GiftBox_Request_Item__c> filteredRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            if(requestItem.ASI_GiftBox_Request_Quantity__c != requestItemMap.get(requestItem.Id).ASI_GiftBox_Request_Quantity__c || 
               requestItem.ASI_CRM_Amount__c != requestItemMap.get(requestItem.Id).ASI_CRM_Amount__c || 
               requestItem.ASI_GiftBox_Request_Item__c != requestItemMap.get(requestItem.Id).ASI_GiftBox_Request_Item__c) {
                filteredRequestItemList.add(requestItem);
            }
        }
        
        return filteredRequestItemList;
    }
    
    private void checkBalanceAmount(List<ASI_GiftBox_Request_Item__c> requestItemList) {
        Set<Id> itemIdSet = new Set<Id>();
        Set<Id> requestItemIdSet = new Set<Id>();
        Set<Id> requestHeaderIdSet = new Set<Id>();
        Map<Id, List<ASI_GiftBox_Request_Item__c>> requestItemMap = new Map<Id, List<ASI_GiftBox_Request_Item__c>>();
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            itemIdSet.add(requestItem.ASI_GiftBox_Request_Item__c);
            
            requestHeaderIdSet.add(requestItem.ASI_GiftBox_Request_Id__c);
            if(String.isNotBlank(requestItem.Id)) {
                requestItemIdSet.add(requestItem.Id);
            }
            
            List<ASI_GiftBox_Request_Item__c> tempRequestItemList;
            if(requestItemMap.containsKey(requestItem.ASI_GiftBox_Request_Id__c)) {
            	tempRequestItemList = requestItemMap.get(requestItem.ASI_GiftBox_Request_Id__c);
            } else {
            	tempRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
            }
            
            tempRequestItemList.add(requestItem);
            requestItemMap.put(requestItem.ASI_GiftBox_Request_Id__c, tempRequestItemList);
        }
        
        Map<Id, List<ASI_GiftBox_Request_Item__c>> contractRequestItemMap = new Map<Id, List<ASI_GiftBox_Request_Item__c>>();
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c requestHeader : retrieveRequestList(requestHeaderIdSet)) {
            contractIdSet.add(requestHeader.ASI_CRM_VN_Contract__c);
            
            contractRequestItemMap.put(requestHeader.ASI_CRM_VN_Contract__c, requestItemMap.get(requestHeader.Id));
        }
        
        for(ASI_GiftBox_Request_Item__c requestItem : retrieveRequestItemList(contractIdSet, requestItemIdSet)) {
            itemIdSet.add(requestItem.ASI_GiftBox_Request_Item__c);
            
            List<ASI_GiftBox_Request_Item__c> tempRequestItemList;
        	if(contractRequestItemMap.containsKey(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c)) {
                tempRequestItemList = contractRequestItemMap.get(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c);
            } else {
            	tempRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
            }
            
            tempRequestItemList.add(requestItem);
            contractRequestItemMap.put(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c, tempRequestItemList);
        }
        
        System.debug('Debug Log : ' + contractRequestItemMap);
        
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> contractExpenditureMap = new Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>>();
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : retrieveContractExpenditureList(contractIdSet)) {
            List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList;
            if(contractExpenditureMap.containsKey(contractExpenditure.ASI_CRM_VN_Contract__c)) {
           		contractExpenditureList = contractExpenditureMap.get(contractExpenditure.ASI_CRM_VN_Contract__c);
            } else {
            	contractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
            }	
            contractExpenditureList.add(contractExpenditure);
            contractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Contract__c, contractExpenditureList);
        }
        
        Map<Id, ASI_GiftBox_Inventory_Master__c> itemMap = new Map<Id, ASI_GiftBox_Inventory_Master__c>(retrieveInventoryMasterList(itemIdSet));
        for(Id contractId : contractRequestItemMap.keySet()) {
        	List<ASI_GiftBox_Request_Item__c> tempRequestItemList = contractRequestItemMap.get(contractId);
            List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = contractExpenditureMap.get(contractId);
            
            if(contractExpenditureList == null) {
                for(ASI_GiftBox_Request_Item__c requestItem : tempRequestItemList) {
                	showError(requestItem, 'No Display Listing Fee is defined in MCF. Cannot issue Display Listing Request Item.');
                }
                continue;
            } 
            
            Map<String, ASI_CRM_VN_Contract_Expenditure__c> itemContractExpenditureMap = new Map<String, ASI_CRM_VN_Contract_Expenditure__c>();
            for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            	itemContractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure);
            }
            
            Decimal amount = 0;
           	for(ASI_GiftBox_Request_Item__c requestItem : tempRequestItemList) {
                amount += (requestItem.ASI_CRM_Amount__c == null ? 0 : requestItem.ASI_CRM_Amount__c);
            }
            
            if(itemContractExpenditureMap.containsKey(DISPLAY_LISTING_CONTRACT_EXPENDITURE) == false) {
                for(ASI_GiftBox_Request_Item__c requestItem : tempRequestItemList) {
                	showError(requestItem, 'No Display Listing Fee is defined in MCF. Cannot issue Display Listing Request Item.');
                }
                continue;
            }
            
            ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = itemContractExpenditureMap.get(DISPLAY_LISTING_CONTRACT_EXPENDITURE);
            
            if(contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD') {
            	amount *= contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c;
            }
            
            /* [VL 1.0] BEGIN */
            /*
            if(amount > contractExpenditure.ASI_CRM_VN_Amount__c) {
            */
            if(amount > contractExpenditure.ASI_CRM_Total_Amount__c) {
            /* [VL 1.0] END */
            	for(ASI_GiftBox_Request_Item__c requestItem : tempRequestItemList) {
                	showError(requestItem, 'Display Listing Order Amount is larger than the Available Balance. Unable to save.');
                }
                continue;
        	}
        }
    }
    
   	private void showError(ASI_GiftBox_Request_Item__c requestItem, String errorMsg) {
        requestItem.addError(errorMsg);
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_GiftBox_Request_Header__c> retrieveRequestList(Set<Id> requestIdSet) {
    	String query = 'SELECT ' + genQueryField(REQUEST_HEADER_FIELD_MAP) +  
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Header__c ' + 
                       'Where Id in :requestIdSet';
        
    	return (List<ASI_GiftBox_Request_Header__c>) Database.query(query);
  	}
    
    private List<ASI_GiftBox_Request_Item__c> retrieveRequestItemList(Set<Id> contractIdSet, Set<Id> requestItemIdSet) {
        String query = 'SELECT ' + genQueryField(REQUEST_ITEM_FIELD_MAP) +  
                       ', RecordType.DeveloperName, ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'WHERE ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND Id not in :requestItemIdSet ' + 
                       'AND (ASI_GiftBox_Request_Id__r.RecordType.DeveloperName = \'ASI_CRM_VN_Display_Listing_Fee_Request\' ' + 
                       'OR ASI_GiftBox_Request_Id__r.RecordType.DeveloperName = \'ASI_CRM_VN_Display_Listing_Fee_Request_Read_Only\') ';
        
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
    
    private List<ASI_GiftBox_Inventory_Master__c> retrieveInventoryMasterList(Set<Id> itemIdSet) {
    	String query = 'SELECT ' + genQueryField(INVENTORY_MASTER_FIELD_MAP) +  
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Inventory_Master__c ' + 
                       'Where Id in :itemIdSet';
        
    	return (List<ASI_GiftBox_Inventory_Master__c>) Database.query(query);
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