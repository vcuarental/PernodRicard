/*********************************************************************************
 * Name: ASI_CRM_VN_FOC_CheckBalance
 * Description: Check the balance amount of FOC Request before insert/update
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/07/2017       Hugo Cheung             Created          
 * 2018-10-18       Vincent Lam             [VL 1.0] ICM119302541  fix bug
*/
public class ASI_CRM_VN_FOC_CheckBalance {
    
    private final static Map<String, Schema.SObjectField> REQUEST_HEADER_FIELD_MAP       = Schema.SObjectType.ASI_GiftBox_Request_Header__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP    = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> INVENTORY_MASTER_FIELD_MAP     = Schema.SObjectType.ASI_GiftBox_Inventory_Master__c.fields.getMap();
    
    private final static String FOC_CONTRACT_EXPENDITURE = 'FOC Bottles';
    
    public ASI_CRM_VN_FOC_CheckBalance() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Item__c> focRequestItemList   = (List<ASI_GiftBox_Request_Item__c>) newList;
        Map<Id, ASI_GiftBox_Request_Item__c> focRequestItemMap = (Map<Id, ASI_GiftBox_Request_Item__c>) oldMap;
        
        List<ASI_GiftBox_Request_Item__c> filteredFOCRequestItemList = filterFOCRequestItem(focRequestItemList, focRequestItemMap);
		checkBalanceAmount(filteredFOCRequestItemList);
    }
    
    private List<ASI_GiftBox_Request_Item__c> filterFOCRequestItem(List<ASI_GiftBox_Request_Item__c> focRequestItemList, Map<Id, ASI_GiftBox_Request_Item__c> focRequestItemMap) {
    	if(focRequestItemMap == null) {
        	return focRequestItemList;
        }
        
        List<ASI_GiftBox_Request_Item__c> filteredFOCRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(ASI_GiftBox_Request_Item__c focRequestItem : focRequestItemList) {
            if(focRequestItem.ASI_GiftBox_Request_Quantity__c != focRequestItemMap.get(focRequestItem.Id).ASI_GiftBox_Request_Quantity__c || 
               focRequestItem.ASI_CRM_Amount__c != focRequestItemMap.get(focRequestItem.Id).ASI_CRM_Amount__c || 
               focRequestItem.ASI_GiftBox_Request_Item__c != focRequestItemMap.get(focRequestItem.Id).ASI_GiftBox_Request_Item__c) {
                filteredFOCRequestItemList.add(focRequestItem);
            }
        }
        
        return filteredFOCRequestItemList;
    }
    
   	private void checkBalanceAmount(List<ASI_GiftBox_Request_Item__c> focRequestItemList) {
        Set<Id> itemIdSet = new Set<Id>();
        Set<Id> focRequestItemIdSet = new Set<Id>();
        Set<Id> focRequestHeaderIdSet = new Set<Id>();
        Map<Id, List<ASI_GiftBox_Request_Item__c>> focRequestItemMap = new Map<Id, List<ASI_GiftBox_Request_Item__c>>();
        for(ASI_GiftBox_Request_Item__c focRequestItem : focRequestItemList) {
            itemIdSet.add(focRequestItem.ASI_GiftBox_Request_Item__c);
            
            focRequestHeaderIdSet.add(focRequestItem.ASI_GiftBox_Request_Id__c);
            if(String.isNotBlank(focRequestItem.Id)) {
                focRequestItemIdSet.add(focRequestItem.Id);
            }
            
            List<ASI_GiftBox_Request_Item__c> tempFOCRequestItemList;
            if(focRequestItemMap.containsKey(focRequestItem.ASI_GiftBox_Request_Id__c)) {
            	tempFOCRequestItemList = focRequestItemMap.get(focRequestItem.ASI_GiftBox_Request_Id__c);
            } else {
            	tempFOCRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
            }
            
            tempFOCRequestItemList.add(focRequestItem);
            focRequestItemMap.put(focRequestItem.ASI_GiftBox_Request_Id__c, tempFOCRequestItemList);
        }
        
        Map<Id, List<ASI_GiftBox_Request_Item__c>> contractFOCRequestItemMap = new Map<Id, List<ASI_GiftBox_Request_Item__c>>();
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c focRequestHeader : retrieveFOCRequestList(focRequestHeaderIdSet)) {
            contractIdSet.add(focRequestHeader.ASI_CRM_VN_Contract__c);
            
            contractFOCRequestItemMap.put(focRequestHeader.ASI_CRM_VN_Contract__c, focRequestItemMap.get(focRequestHeader.Id));
        }
        
        for(ASI_GiftBox_Request_Item__c requestItem : retrieveFOCRequestItemList(contractIdSet, focRequestItemIdSet)) {
            itemIdSet.add(requestItem.ASI_GiftBox_Request_Item__c);
            
            List<ASI_GiftBox_Request_Item__c> tempFOCRequestItemList;
        	if(contractFOCRequestItemMap.containsKey(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c)) {
                tempFOCRequestItemList = contractFOCRequestItemMap.get(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c);
            } else {
            	tempFOCRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
            }
            
            tempFOCRequestItemList.add(requestItem);
            contractFOCRequestItemMap.put(requestItem.ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c, tempFOCRequestItemList);
        }
        
        System.debug('Debug Log : ' + contractFOCRequestItemMap);
        
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
        for(Id contractId : contractFOCRequestItemMap.keySet()) {
        	List<ASI_GiftBox_Request_Item__c> tempFOCRequestItemList = contractFOCRequestItemMap.get(contractId);
            List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = contractExpenditureMap.get(contractId);
            
            if(contractExpenditureList == null) {
                for(ASI_GiftBox_Request_Item__c focRequestItem : tempFOCRequestItemList) {
                	showError(focRequestItem, Label.ASI_CRM_VN_FOC_Item_Not_Defined);
                }
                continue;
            } 
            
            Map<String, ASI_CRM_VN_Contract_Expenditure__c> itemContractExpenditureMap = new Map<String, ASI_CRM_VN_Contract_Expenditure__c>();
            for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            	itemContractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure);
            }
            
            Decimal focAmount = 0;
           	for(ASI_GiftBox_Request_Item__c focRequestItem : tempFOCRequestItemList) {
                focAmount += (focRequestItem.ASI_CRM_Amount__c == null ? 0 : focRequestItem.ASI_CRM_Amount__c);
            }
            
            if(itemContractExpenditureMap.containsKey(FOC_CONTRACT_EXPENDITURE) == false) {
                for(ASI_GiftBox_Request_Item__c focRequestItem : tempFOCRequestItemList) {
                	showError(focRequestItem, Label.ASI_CRM_VN_FOC_Item_Not_Defined);
                }
                continue;
            }
            
            ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = itemContractExpenditureMap.get(FOC_CONTRACT_EXPENDITURE);
            
            if(contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD') {
            	focAmount *= contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c;
            }
            
            /* [VL 1.0] BEGIN */
            /*
            if(focAmount > contractExpenditure.ASI_CRM_VN_Amount__c) {
            */
            if(focAmount > contractExpenditure.ASI_CRM_Total_Amount__c) {
            /* [VL 1.0] END */
            	for(ASI_GiftBox_Request_Item__c focRequestItem : tempFOCRequestItemList) {
                	showError(focRequestItem, Label.ASI_CRM_VN_FOC_Amount_Over);
                }
                continue;
        	}
        }
    }
    
    private void showError(ASI_GiftBox_Request_Item__c focRequestItem, String errorMsg) {
        focRequestItem.addError(errorMsg);
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_GiftBox_Request_Header__c> retrieveFOCRequestList(Set<Id> focRequestIdSet) {
    	String query = 'SELECT ' + genQueryField(REQUEST_HEADER_FIELD_MAP) +  
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Header__c ' + 
                       'Where Id in :focRequestIdSet';
        
    	return (List<ASI_GiftBox_Request_Header__c>) Database.query(query);
  	}
    
    private List<ASI_GiftBox_Request_Item__c> retrieveFOCRequestItemList(Set<Id> contractIdSet, Set<Id> requestItemIdSet) {
        String query = 'SELECT ' + genQueryField(REQUEST_ITEM_FIELD_MAP) +  
                       ', RecordType.DeveloperName, ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'WHERE ASI_GiftBox_Request_Id__r.ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND Id not in :requestItemIdSet ' + 
                       'AND (ASI_GiftBox_Request_Id__r.RecordType.DeveloperName = \'ASI_CRM_VN_FOC_Request\' ' + 
                       'OR ASI_GiftBox_Request_Id__r.RecordType.DeveloperName = \'ASI_CRM_VN_FOC_Request_Read_Only\') ';
        
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