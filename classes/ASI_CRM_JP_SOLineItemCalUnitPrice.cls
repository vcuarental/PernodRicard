/*********************************************************************************
 * Name: ASI_CRM_JP_SOLineItemCalUnitPrice
 * Description: Retrieve the unit price from item based price record
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 12/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOLineItemCalUnitPrice extends ASI_CRM_JP_TriggerAbstract {
    
   	//Field Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SKU_FIELD_MAP         = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ITEM_PRICE_MAP        = Schema.SObjectType.ASI_CRM_JP_Customer_Product_Price__c.fields.getMap();
    
    //SO Record Type need to retrieve price
    //Key = SO Record Type, Value = Item Base Price Record Type
    private final static Map<String, String> RETRIEVE_PRICE_RECORD_TYPE_MAP = new Map<String, String> {
        'ASI_CRM_JP_Normal_SO'      => 'ASI_CRM_JP_Duty_Paid_Product_Price',
        'ASI_CRM_JP_Employee_Sales' => 'ASI_CRM_JP_Employee_Product_Price',
        'ASI_CRM_JP_Direct_Sales'   => 'ASI_CRM_JP_Direct_Sales_Product_Price',
        'ASI_CRM_JP_Duty_Free_SO'   => 'ASI_CRM_JP_Duty_Free_Product_Price'
    };
    
    public ASI_CRM_JP_SOLineItemCalUnitPrice() {
        super('ASI_CRM_JP_SOLineItemCalUnitPrice');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        //String sUserId = UserInfo.getUserId();
        //List <User> list_user = [SELECT id, name, BypassTriggers__c FROM user WHERE id = :sUserId];
        //for (User idx_user : list_user) {
		//	String CurrentClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        //    if (idx_user.BypassTriggers__c.contains(CurrentClassName)) {
        //        return;
        //    }
        //} 	
        
        List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList = (List<ASI_CRM_JP_Sales_Order_Item__c>) sObjList;
        Map<Id, ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemMap = (Map<Id, ASI_CRM_JP_Sales_Order_Item__c>) oldMap;
            
    	List<ASI_CRM_JP_Sales_Order_Item__c> filteredSalesOrderItemList = filterSalesOrderItem(salesOrderItemList, salesOrderItemMap);
        
       	assignUnitPrice(filteredSalesOrderItemList);
    }
    
    @TestVisible
    private List<ASI_CRM_JP_Sales_Order_Item__c> filterSalesOrderItem(List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList, Map<Id, ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemMap) {
    	if(salesOrderItemMap == null) {
        	return salesOrderItemList;
        }
        
        List<ASI_CRM_JP_Sales_Order_Item__c> filteredSalesOrderItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            if(salesOrderItem.ASI_CRM_SKU__c == salesOrderItemMap.get(salesOrderItem.Id).ASI_CRM_SKU__c || 
               salesOrderItem.ASI_CRM_Status__c == '980-Cancelled') {
            	continue;
            } else {
            	filteredSalesOrderItemList.add(salesOrderItem);
            }
        }
        
        return filteredSalesOrderItemList;
    }
    
    @TestVisible
    private void assignUnitPrice(List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList) {
        Set<Id> salesOrderIdSet = new Set<Id>();
        Set<Id> skuIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            salesOrderIdSet.add(salesOrderItem.ASI_CRM_Sales_Order__c);
            skuIdSet.add(salesOrderItem.ASI_CRM_SKU__c);
        }
        
        Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = new Map<Id, ASI_CRM_JP_Sales_Order__c>(retrieveSalesOrderList(salesOrderIdSet));
        Map<Id, ASI_MFM_SKU_Code__c> skuMap = new Map<Id, ASI_MFM_SKU_Code__c>(retrieveSKUList(skuIdSet));
        
        Set<Id> itemGroupIdSet = new Set<Id>();
        for(ASI_MFM_SKU_Code__c sku : skuMap.values()) {
            itemGroupIdSet.add(sku.ASI_MFM_Item_Group__c);
        }
        
        Map<String, List<ASI_CRM_JP_Customer_Product_Price__c>> itemPriceMap = retrieveItemPriceMap(skuIdSet, itemGroupIdSet);
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            ASI_CRM_JP_Sales_Order__c salesOrder = salesOrderMap.get(salesOrderItem.ASI_CRM_Sales_Order__c);
            
            Id soldToCustomerId = salesOrder.ASI_CRM_Sold_To__c;
            Id customerGroupId  = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_National_Group__c;
            
            String keyWithSkuCustomer  = '';
            String keyWithSkuEmptyCust = salesOrderItem.ASI_CRM_SKU__c;
            String keyWithIGCustomer   = '';
            String keyWithIGCustomerGroup   = '';
            String keyWithIGEmptyCust  = skuMap.get(salesOrderItem.ASI_CRM_SKU__c).ASI_MFM_Item_Group__c;
            if(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).DeveloperName == 'ASI_CRM_JP_Direct_Sales') {
            	keyWithSkuCustomer = salesOrderItem.ASI_CRM_SKU__c + '_' + customerGroupId;
                keyWithIGCustomer  = skuMap.get(salesOrderItem.ASI_CRM_SKU__c).ASI_MFM_Item_Group__c + '_' + soldToCustomerId;
                keyWithIGCustomerGroup  = skuMap.get(salesOrderItem.ASI_CRM_SKU__c).ASI_MFM_Item_Group__c + '_' + customerGroupId;
            } else {
                keyWithSkuCustomer = salesOrderItem.ASI_CRM_SKU__c + '_' + soldToCustomerId;
                keyWithIGCustomer  = skuMap.get(salesOrderItem.ASI_CRM_SKU__c).ASI_MFM_Item_Group__c + '_' + soldToCustomerId;
            }
            
            if(RETRIEVE_PRICE_RECORD_TYPE_MAP.containsKey(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).DeveloperName) == false) {
                continue;
            }
            
            if(salesOrder.ASI_CRM_Order_Type__c == 'Sample Sales' || 
               salesOrder.ASI_CRM_Order_Type__c == 'POSM') {
                continue;
            }
           
            String itemPriceRecordType = RETRIEVE_PRICE_RECORD_TYPE_MAP.get(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).DeveloperName);
            keyWithSkuCustomer  += '_' + itemPriceRecordType;
            keyWithSkuEmptyCust += '_' + itemPriceRecordType;
            keyWithIGCustomer   += '_' + itemPriceRecordType;
            keyWithIGCustomerGroup   += '_' + itemPriceRecordType;
            keyWithIGEmptyCust  += '_' + itemPriceRecordType; 
        	
            if(itemPriceMap.containsKey(keyWithSkuCustomer) == false && 
               itemPriceMap.containsKey(keyWithSkuEmptyCust) == false &&
               itemPriceMap.containsKey(keyWithIGCustomer) == false && 
               itemPriceMap.containsKey(keyWithIGCustomerGroup) == false && 
               itemPriceMap.containsKey(keyWithIGEmptyCust) == false && 
               skuMap.get(salesOrderItem.ASI_CRM_SKU__c).ASI_CRM_Ex_Price__c == NULL) {
                showError(salesOrderItem, skuMap.get(salesOrderItem.ASI_CRM_SKU__c));
            }
            
            List<ASI_CRM_JP_Customer_Product_Price__c> itemPriceList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
            if(itemPriceMap.containsKey(keyWithSkuCustomer)) {
                itemPriceList = itemPriceMap.get(keyWithSkuCustomer);
            } else if(itemPriceMap.containsKey(keyWithSkuEmptyCust)) {
                itemPriceList = itemPriceMap.get(keyWithSkuEmptyCust);
            } else if(itemPriceMap.containsKey(keyWithIGCustomer)) {
                itemPriceList = itemPriceMap.get(keyWithIGCustomer);
            } else if(itemPriceMap.containsKey(keyWithIGCustomerGroup)) {
                itemPriceList = itemPriceMap.get(keyWithIGCustomerGroup);
            } else if(itemPriceMap.containsKey(keyWithIGEmptyCust)) {
                itemPriceList = itemPriceMap.get(keyWithIGEmptyCust);
            }
            
            System.debug('Debug Log : ' + itemPriceMap);
            System.debug('Debug Log : ' + keyWithSkuCustomer);
            System.debug('Debug Log : ' + keyWithSkuEmptyCust);
            System.debug('Debug Log : ' + keyWithIGCustomer);
            System.debug('Debug Log : ' + keyWithIGEmptyCust);
            
            salesOrderItem.ASI_CRM_Unit_Price__c = skuMap.get(salesOrderItem.ASI_CRM_SKU__c).ASI_CRM_Ex_Price__c;
            
            for(ASI_CRM_JP_Customer_Product_Price__c itemPrice : itemPriceList) {
                if(itemPrice.ASI_Effective_Date__c <= salesOrder.ASI_CRM_Requested_Date__c) {
                	salesOrderItem.ASI_CRM_Unit_Price__c    = itemPrice.ASI_Bottle_Price__c;
                    salesOrderItem.ASI_CRM_JP_Base_Price__c = itemPrice.ASI_Bottle_Price__c;
                    break;
                }
            }
            
            if(salesOrderItem.ASI_CRM_Unit_Price__c == null) {
                showError(salesOrderItem, skuMap.get(salesOrderItem.ASI_CRM_SKU__c));
            }
        }
    }
    
    @TestVisible
    private void showError(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem, ASI_MFM_SKU_Code__c skuCode) {
        String skuName = skuCode.Name;
                
        String errorMsg = String.format(Label.ASI_CRM_JP_SO_Item_Based_Price_Not_Found, new String[] {skuName});
        salesOrderItem.addError(errorMsg);
    }
    
    /***************
	Data Retrievement Function
	***************/
    @TestVisible
    private List<ASI_CRM_JP_Sales_Order__c> retrieveSalesOrderList(Set<Id> salesOrderIdSet) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + 
                       ', ASI_CRM_Sold_To__r.Name, ASI_CRM_Sold_To__r.ASI_CRM_National_Group__c, ASI_CRM_Sold_To__r.ASI_CRM_National_Group__r.Name ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_JP_Sales_Order__c ' +
                       'WHERE Id in :salesOrderIdSet ';
        return (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
    }
    
    @TestVisible
    private List<ASI_MFM_SKU_Code__c> retrieveSKUList(Set<Id> skuIdSet) {
        String query = 'SELECT ' + genQueryField(SKU_FIELD_MAP) + 
                       ', ASI_MFM_Item_Group__r.Name ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_MFM_SKU_Code__c ' + 
                       'Where Id in :skuIdSet';
        return (List<ASI_MFM_SKU_Code__c>) Database.query(query);
    }
    
    @TestVisible
    private Map<String, List<ASI_CRM_JP_Customer_Product_Price__c>> retrieveItemPriceMap(Set<Id> skuIdSet, Set<Id> itemGroupIdSet) {
    	String query = 'SELECT ' + genQueryField(ITEM_PRICE_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_JP_Customer_Product_Price__c ' + 
                       'WHERE (ASI_SKU_Lookup__c in :skuIdSet OR ASI_MFM_Item_Group__c in :itemGroupIdSet) ' + 
                       'AND ASI_CRM_JP_Active__c = true ' + 
                       'ORDER BY ASI_Effective_Date__c DESC ';
        
        List<ASI_CRM_JP_Customer_Product_Price__c> itemPriceList = (List<ASI_CRM_JP_Customer_Product_Price__c>) Database.query(query);
        
        Map<String, List<ASI_CRM_JP_Customer_Product_Price__c>> itemPriceMap = new Map<String, List<ASI_CRM_JP_Customer_Product_Price__c>>();
        for(ASI_CRM_JP_Customer_Product_Price__c itemPrice : itemPriceList) {
            Boolean isCustomerFilled = false;
            Set<String> keySet = new Set<String>();
            if(String.isNotBlank(itemPrice.ASI_SKU_Lookup__c)) {
                if(String.isNotBlank(itemPrice.ASI_Customer_Name__c)) {
                	keySet.add(itemPrice.ASI_SKU_Lookup__c + '_' + itemPrice.ASI_Customer_Name__c);
                    isCustomerFilled = true;
                } 
                if (String.isNotBlank(itemPrice.ASI_CRM_Customer_Group__c)) {
                    keySet.add(itemPrice.ASI_SKU_Lookup__c + '_' + itemPrice.ASI_CRM_Customer_Group__c);
                    isCustomerFilled = true;
                }
                if(!isCustomerFilled) {
                	keySet.add(itemPrice.ASI_SKU_Lookup__c);
                }
            } else if(String.isNotBlank(itemPrice.ASI_MFM_Item_Group__c)) {
                if(String.isNotBlank(itemPrice.ASI_Customer_Name__c)) {
                	keySet.add(itemPrice.ASI_MFM_Item_Group__c + '_' + itemPrice.ASI_Customer_Name__c);
                    isCustomerFilled = true;
                }
                if(String.isNotBlank(itemPrice.ASI_CRM_Customer_Group__c)) {
                	keySet.add(itemPrice.ASI_MFM_Item_Group__c + '_' + itemPrice.ASI_CRM_Customer_Group__c);
                    isCustomerFilled = true;
                }
                if(!isCustomerFilled) {               
                	keySet.add(itemPrice.ASI_MFM_Item_Group__c);
                }
            }
            
            for(String key : keySet) {
                key += '_' + itemPrice.RecordType.DeveloperName;
                
            	List<ASI_CRM_JP_Customer_Product_Price__c> tempPriceList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
                if(itemPriceMap.containsKey(key)) {
                    tempPriceList = itemPriceMap.get(key);
                }
                tempPriceList.add(itemPrice);
                itemPriceMap.put(key, tempPriceList);
            }
            
        }
        
        return itemPriceMap;
    }
    
    /***************
    Tools Function
    ***************/
    @TestVisible
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}