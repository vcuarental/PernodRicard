/*********************************************************************************
 * Name: ASI_CRM_VN_POSM_CheckBalance
 * Description: Check the balance amount of POSM Request before insert/update
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/06/2017       Hugo Cheung             Created          
 * 2018-08-01       Vincent Lam             [VL 1.0] IM004336 fix bug
 * 2018-12-17		Calvin Chiu				PAVN01-11 - Bypass check balance for non-contract posm
*/
public class ASI_CRM_VN_POSM_CheckBalance {
    
    private final static Map<String, Schema.SObjectField> POSM_REQUEST_HEADER_FIELD_MAP  = Schema.SObjectType.ASI_GiftBox_Request_Header__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> POSM_REQUEST_ITEM_FIELD_MAP    = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> INVENTORY_MASTER_FIELD_MAP     = Schema.SObjectType.ASI_GiftBox_Inventory_Master__c.fields.getMap();
    
    private final static Map<String, String> itemCategoryExpenditureMap = new Map<String, String> {
    	'Podium stand'    => 'Podium Stands & Glorifiers',
        'Glorifier'       => 'Podium Stands & Glorifiers',
        'Glassware'       => 'Glassware (Including Ice Buckets)',
        'Dice & Dice Cup' => '',
        'Drink menus'     => 'Drink Menus'
    };
    
    public ASI_CRM_VN_POSM_CheckBalance() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Item__c> posmRequestItemList   = (List<ASI_GiftBox_Request_Item__c>) newList;
        Map<Id, ASI_GiftBox_Request_Item__c> posmRequestItemMap = (Map<Id, ASI_GiftBox_Request_Item__c>) oldMap;
        
        List<ASI_GiftBox_Request_Item__c> filteredPOSMRequestItemList = filterPOSMRequestItem(posmRequestItemList, posmRequestItemMap);
        checkBalanceAmount(filteredPOSMRequestItemList);
    }
    
    private List<ASI_GiftBox_Request_Item__c> filterPOSMRequestItem(List<ASI_GiftBox_Request_Item__c> posmRequestItemList, Map<Id, ASI_GiftBox_Request_Item__c> posmRequestItemMap) {
    	if(posmRequestItemMap == null) {
        	return posmRequestItemList;
        }
        
        List<ASI_GiftBox_Request_Item__c> filteredPOSMRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(ASI_GiftBox_Request_Item__c posmRequestItem : posmRequestItemList) {
            if(posmRequestItem.ASI_GiftBox_Request_Quantity__c != posmRequestItemMap.get(posmRequestItem.Id).ASI_GiftBox_Request_Quantity__c || 
               posmRequestItem.ASI_CRM_Amount__c != posmRequestItemMap.get(posmRequestItem.Id).ASI_CRM_Amount__c || 
               posmRequestItem.ASI_GiftBox_Request_Item__c != posmRequestItemMap.get(posmRequestItem.Id).ASI_GiftBox_Request_Item__c) {
                filteredPOSMRequestItemList.add(posmRequestItem);
            }
        }
        
        return filteredPOSMRequestItemList;
    }
    
    private void checkBalanceAmount(List<ASI_GiftBox_Request_Item__c> posmRequestItemList) {
        //Step 1 : Retrieve all related request item
        Set<Id> posmRequestHeaderIdSet = new Set<Id>();
        Set<Id> posmRequestItemIdSet = new Set<Id>();
        Set<Id> itemIdSet = new Set<Id>();
        
        Map<Id, List<ASI_GiftBox_Request_Item__c>> posmRequestItemMap = new Map<Id, List<ASI_GiftBox_Request_Item__c>>();
    	for(ASI_GiftBox_Request_Item__c posmRequestItem : posmRequestItemList) {
            itemIdSet.add(posmRequestItem.ASI_GiftBox_Request_Item__c);
            posmRequestHeaderIdSet.add(posmRequestItem.ASI_GiftBox_Request_Id__c);
            if(String.isNotBlank(posmRequestItem.Id)) {
                posmRequestItemIdSet.add(posmRequestItem.Id);
            }
            
            List<ASI_GiftBox_Request_Item__c> tempPOSMRequestItemList;
            if(posmRequestItemMap.containsKey(posmRequestItem.ASI_GiftBox_Request_Id__c)) {
				tempPOSMRequestItemList = posmRequestItemMap.get(posmRequestItem.ASI_GiftBox_Request_Id__c);
            } else {
            	tempPOSMRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
            }
            
            tempPOSMRequestItemList.add(posmRequestItem);
            posmRequestItemMap.put(posmRequestItem.ASI_GiftBox_Request_Id__c, tempPOSMRequestItemList);
        }
        
        //Step 2 : Put the request item and related contract to a map
        Map<Id, List<ASI_GiftBox_Request_Item__c>> contractPOSMRequestItemMap = new Map<Id, List<ASI_GiftBox_Request_Item__c>>();
       	Set<Id> contractIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c posmRequestHeader : retrievePOSMRequestList(posmRequestHeaderIdSet)) {
            contractIdSet.add(posmRequestHeader.ASI_CRM_VN_Contract__c);
            
            contractPOSMRequestItemMap.put(posmRequestHeader.ASI_CRM_VN_Contract__c, posmRequestItemMap.get(posmRequestHeader.Id));
        }
        
        // added by Calvin (LAPUTA): only check balance if posm header has contract
        if(!contractIdSet.isEmpty()){
        	for(ASI_GiftBox_Request_Item__c requestItem : retrievePOSMRequestItemList(contractIdSet, posmRequestItemIdSet)) {
	            itemIdSet.add(requestItem.ASI_GiftBox_Request_Item__c);
	            
	            List<ASI_GiftBox_Request_Item__c> tempPOSMRequestItemList;
	        	if(contractPOSMRequestItemMap.containsKey(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c)) {
	                tempPOSMRequestItemList = contractPOSMRequestItemMap.get(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c);
	            } else {
	            	tempPOSMRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
	            }
	            
	            tempPOSMRequestItemList.add(requestItem);
	            contractPOSMRequestItemMap.put(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c, tempPOSMRequestItemList);
	        }
	       	
	        //Step 3 : Retrieve the related contract expenditure record
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
	        
	        //Step 4 : Calculate the item amount and contract expenditure amount
	        Map<Id, ASI_GiftBox_Inventory_Master__c> itemMap = new Map<Id, ASI_GiftBox_Inventory_Master__c>(retrieveInventoryMasterList(itemIdSet));
	        for(Id contractId : contractPOSMRequestItemMap.keySet()) {
	        	List<ASI_GiftBox_Request_Item__c> tempPOSMRequestItemList = contractPOSMRequestItemMap.get(contractId);
	            List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = contractExpenditureMap.get(contractId);
	            
	            Map<String, ASI_CRM_VN_Contract_Expenditure__c> itemContractExpenditureMap = new Map<String, ASI_CRM_VN_Contract_Expenditure__c>();
	            for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
	            	itemContractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure);
	            }
	            
	            if(contractExpenditureList == null) {
	                for(ASI_GiftBox_Request_Item__c posmRequestItem : tempPOSMRequestItemList) {
	                	showError(posmRequestItem, Label.ASI_CRM_VN_Request_Item_Not_Defined);
	                }
	                continue;
	            } 
	            
	            Map<String, Decimal> amountPerItem = new Map<String, Decimal>();
	            Map<String, List<ASI_GiftBox_Request_Item__c>> itemPosmRequestMap = new Map<String, List<ASI_GiftBox_Request_Item__c>>();
	            for(ASI_GiftBox_Request_Item__c posmRequestItem : tempPOSMRequestItemList) {
	                ASI_GiftBox_Inventory_Master__c item = itemMap.get(posmRequestItem.ASI_GiftBox_Request_Item__c);
	                Decimal amount;
	                if(amountPerItem.containsKey(item.ASI_CRM_Category__c)) {
	                	amount = amountPerItem.get(item.ASI_CRM_Category__c);
	                } else {
	                	amount = 0;
	                }
	                amount += (posmRequestItem.ASI_CRM_Amount__c == null ? 0 : posmRequestItem.ASI_CRM_Amount__c);
	                
	                amountPerItem.put(item.ASI_CRM_Category__c, amount);
	                
	                List<ASI_GiftBox_Request_Item__c> itemPOSMRequestItemList;
	                if(itemPosmRequestMap.containsKey(item.ASI_CRM_Category__c)) {
	                	itemPOSMRequestItemList = itemPosmRequestMap.get(item.ASI_CRM_Category__c);
	                } else {
	                	itemPOSMRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
	                }
	                itemPOSMRequestItemList.add(posmRequestItem);
	                itemPosmRequestMap.put(item.ASI_CRM_Category__c, itemPOSMRequestItemList); 
	            }
	            
	            for(String itemName : amountPerItem.keySet()) {
	                Decimal amount = amountPerItem.get(itemName);
	                if(itemContractExpenditureMap.containsKey(itemCategoryExpenditureMap.get(itemName)) == false) {
	                    for(ASI_GiftBox_Request_Item__c posmRequestItem : itemPosmRequestMap.get(itemName)) {
	                        showError(posmRequestItem, Label.ASI_CRM_VN_Request_Item_Not_Defined);
	                    }
	                    continue;
	                }
	                
	                ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = itemContractExpenditureMap.get(itemCategoryExpenditureMap.get(itemName));
	                
	                if(contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD') {
	                	amount *= contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c;
	                }
	                
					/* [VL 1.0] BEGIN */
					/*
	                if(amount > contractExpenditure.ASI_CRM_VN_Amount__c) {
					*/
	                if(amount > contractExpenditure.ASI_CRM_Total_Amount__c) {
					/* [VL 1.0] BEGIN */
	                	for(ASI_GiftBox_Request_Item__c posmRequestItem : itemPosmRequestMap.get(itemName)) {
	                        showError(posmRequestItem, Label.ASI_CRM_VN_POSM_Amount_Over);
	                    }
	                    continue;
	                }
	                
	            }
	            
	        }
        }        
    }
    
    private void showError(ASI_GiftBox_Request_Item__c posmRequestItem, String errorMsg) {
        posmRequestItem.addError(errorMsg);
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_GiftBox_Request_Header__c> retrievePOSMRequestList(Set<Id> posmRequestIdSet) {
    	String query = 'SELECT ' + genQueryField(POSM_REQUEST_HEADER_FIELD_MAP) +  
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Header__c ' + 
                       'Where Id in :posmRequestIdSet and ASI_CRM_VN_Contract__c != null';
        
    	return (List<ASI_GiftBox_Request_Header__c>) Database.query(query);
  	}
    
    private List<ASI_GiftBox_Request_Item__c> retrievePOSMRequestItemList(Set<Id> contractIdSet, Set<Id> requestItemIdSet) {
        String query = 'SELECT ' + genQueryField(POSM_REQUEST_ITEM_FIELD_MAP) +  
                       ', RecordType.DeveloperName, ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'WHERE ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND Id not in :requestItemIdSet ' + 
                       'AND (ASI_GiftBox_Request_Id__r.RecordType.DeveloperName = \'ASI_CRM_POSM_VN_Request\' ' + 
                       'OR ASI_GiftBox_Request_Id__r.RecordType.DeveloperName = \'ASI_CRM_POSM_VN_Request_Read_Only\') ';
        
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