/*********************************************************************************
 * Name: ASI_CRM_JP_SOCalculation
 * Description: Calculate all price/quantity of SO
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/02/2017       Hugo Cheung             Created          
*/
public with sharing class ASI_CRM_JP_SOCalculation extends ASI_CRM_JP_TriggerAbstract {

	private static final String FILTER_SOLINEITEM_STATUS = '520-Ready';
    
    private static Set<String> RECORD_TYPE_FILTER = new Set<String> {
    	'ASI_CRM_JP_Normal_SO_Locked',
        'ASI_CRM_JP_Duty_Free_SO_Locked'
    };
    
    private static Set<String> ORDER_TYPE_FILTER = new Set<String> {
    	'Normal SO',
        'Normal Sales SO'
    };

	public ASI_CRM_JP_SOCalculation() {
		super('ASI_CRM_JP_SOCalculation');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		List<ASI_CRM_JP_Sales_Order__c> salesOrderList   = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
		Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap; 
        
		//Filter out the sales order record
		List<ASI_CRM_JP_Sales_Order__c> filteredSOList = new List<ASI_CRM_JP_Sales_Order__c>();
		for(ASI_CRM_JP_Sales_Order__c so : salesOrderList) {
			if(so.ASI_CRM_Status__c == 'Final' &&
			   salesOrderMap.get(so.Id).ASI_CRM_Status__c != 'Final') {
               	filteredSOList.add(so);
			} 
		}

		if(filteredSOList.size() > 0) {
			calculateSO(filteredSOList);
		}
	}
	@TestVisible
	private void calculateSO(List<ASI_CRM_JP_Sales_Order__c> salesOrderList) {
		Set<Id> soIdSet       = new Set<Id>();
		Set<Id> customerIdSet = new Set<Id>();

		for(ASI_CRM_JP_Sales_Order__c so : salesOrderList) {
			soIdSet.add(so.Id);
			customerIdSet.add(so.ASI_CRM_Sold_To__c);
		}

		Map<String, List<ASI_CRM_JP_Sales_Order_Item__c>> soItemMap = retrieveSalesOrderItemMap(soIdSet);
		Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = retrieveCustomerMap(customerIdSet);

		Set<Id> itemAvailabilityIdSet = new Set<Id>();
		for(List<ASI_CRM_JP_Sales_Order_Item__c> soItemList : soItemMap.values()) {
			for(ASI_CRM_JP_Sales_Order_Item__c soItem : soItemList) {
				itemAvailabilityIdSet.add(soItem.ASI_CRM_SKU_Item__c);
			}
		}

		Map<String, ASI_CRM_JP_Item_Availability__c> itemAvailabilityMap = retrieveItemAvailabilityMap(itemAvailabilityIdSet);
		Boolean needToUpdateCustomer = false;
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> updatedCustomerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_CRM_JP_Item_Availability__c> itemAvailabilityList = new List<ASI_CRM_JP_Item_Availability__c>();
        
		for(ASI_CRM_JP_Sales_Order__c so : salesOrderList) {
			Decimal totalAmount = 0;
			for(ASI_CRM_JP_Sales_Order_Item__c soItem : soItemMap.get(so.Id)) {
				totalAmount += (soItem.ASI_CRM_Quantity__c == null ? 0 : soItem.ASI_CRM_Quantity__c)
				             * (soItem.ASI_CRM_Unit_Price__c == null ? 0 : soItem.ASI_CRM_Unit_Price__c);
				if(itemAvailabilityMap.containsKey(soItem.ASI_CRM_SKU_Item__c)) {
					ASI_CRM_JP_Item_Availability__c tempItemAvailablity = itemAvailabilityMap.get(soItem.ASI_CRM_SKU_Item__c);
                    if(tempItemAvailablity.ASI_SFDC_SO_Commit__c == null) tempItemAvailablity.ASI_SFDC_SO_Commit__c = 0;
					tempItemAvailablity.ASI_SFDC_SO_Commit__c += soItem.ASI_CRM_Quantity__c == null ? 0 : soItem.ASI_CRM_Quantity__c;
				}
			}
			
            
           	if(RECORD_TYPE_FILTER.contains(Global_RecordTypeCache.getRt(so.RecordTypeId).DeveloperName) &&
               ORDER_TYPE_FILTER.contains(so.ASI_CRM_Order_Type__c)) {
                if(customerMap.containsKey(so.ASI_CRM_Sold_To__c)) {
                    ASI_CRM_AccountsAdditionalField__c tempCustomer = customerMap.get(so.ASI_CRM_Sold_To__c);
                    if(String.isNotBlank(tempCustomer.ASI_CRM_JP_Customer_Parent__c)) {
                        Id parentId               = tempCustomer.ASI_CRM_JP_Customer_Parent__c;
                        Decimal parentCreditLimit = tempCustomer.ASI_CRM_JP_Customer_Parent__r.ASI_CRM_JP_Commit_SO_Credit_Limit__c;

                        tempCustomer                                      = new ASI_CRM_AccountsAdditionalField__c();
                        tempCustomer.Id                                   = parentId;
                        tempCustomer.ASI_CRM_JP_Commit_SO_Credit_Limit__c = parentCreditLimit;                    
                    }

					if(updatedCustomerMap.containsKey(tempCustomer.Id)) {
                        tempCustomer = updatedCustomerMap.get(tempCustomer.Id);
                    }
                    
                    if(tempCustomer.ASI_CRM_JP_Commit_SO_Credit_Limit__c == null) tempCustomer.ASI_CRM_JP_Commit_SO_Credit_Limit__c = 0;
                    tempCustomer.ASI_CRM_JP_Commit_SO_Credit_Limit__c += totalAmount;
                    updatedCustomerMap.put(tempCustomer.Id, tempCustomer);
                }
            }
		}

        if(updatedCustomerMap.size() > 0) update updatedCustomerMap.values();
		update itemAvailabilityMap.values();
	}
	
    /***************
	Data Retrievement Function
	***************/
	private Map<String, List<ASI_CRM_JP_Sales_Order_Item__c>> retrieveSalesOrderItemMap(Set<Id> soIdSet) {
		String query = 'SELECT Id, ASI_CRM_Sales_Order__c, ASI_CRM_SKU_Item__c, ASI_CRM_Quantity__c, ASI_CRM_Unit_Price__c, ASI_CRM_Status__c ' + 
		               'FROM ASI_CRM_JP_Sales_Order_Item__c ' + 
		               'Where ASI_CRM_Sales_Order__c in :soIdSet ' + 
		               'AND ASI_CRM_Status__c = :FILTER_SOLINEITEM_STATUS ';

		List<ASI_CRM_JP_Sales_Order_Item__c> soItemList = (List<ASI_CRM_JP_Sales_Order_Item__c>) Database.query(query);

		Map<String, List<ASI_CRM_JP_Sales_Order_Item__c>> soItemMap = new Map<String, List<ASI_CRM_JP_Sales_Order_Item__c>>();
		for(ASI_CRM_JP_Sales_Order_Item__c soItem : soItemList) {
			List<ASI_CRM_JP_Sales_Order_Item__c> tempSOItemList = soItemMap.get(soItem.ASI_CRM_Sales_Order__c);
			if(tempSOItemList == null) tempSOItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
			tempSOItemList.add(soItem);
			soItemMap.put(soItem.ASI_CRM_Sales_Order__c, tempSOItemList);
		}

		return soItemMap;
	}

	private Map<String, ASI_CRM_AccountsAdditionalField__c> retrieveCustomerMap(Set<Id> customerIdSet) {
		String query = 'SELECT Id, ASI_CRM_JP_Commit_SO_Credit_Limit__c ' +
                       ', ASI_CRM_JP_Customer_Parent__c, ASI_CRM_JP_Customer_Parent__r.ASI_CRM_JP_Commit_SO_Credit_Limit__c ' + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_AccountsAdditionalField__c ' + 
		               'Where Id in :customerIdSet ';

		return new Map<String, ASI_CRM_AccountsAdditionalField__c>((List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query));
	}

	private Map<String, ASI_CRM_JP_Item_Availability__c> retrieveItemAvailabilityMap(Set<Id> itemAvailabilityIdSet) {
		String query = 'SELECT Id, ASI_SFDC_SO_Commit__c' +
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_JP_Item_Availability__c ' + 
		               'Where Id in :itemAvailabilityIdSet ';
	
		return new Map<String, ASI_CRM_JP_Item_Availability__c>((List<ASI_CRM_JP_Item_Availability__c>) Database.query(query));
	}

}