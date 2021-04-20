/**************************************************************************************************
 * Name: ASI_CTY_CN_WS_SORItem_TriggerClass
 * Object: 
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-05-29
 * Modify History:
 * 2020-05-29       Create this class
 **************************************************************************************************/
public without sharing class ASI_CTY_CN_WS_SORItem_TriggerClass {
    
    public static void routineAfterUpsert(Map<Id,ASI_KOR_Sales_Order_Transaction__c> trigger_newMap) {
    	Set<Id> sorIds = new Set<Id>();
    	for (ASI_KOR_Sales_Order_Transaction__c sorItem : trigger_newMap.values()) {
    		sorIds.add(sorItem.ASI_KOR_Sales_Order_Request__c);
    	}
    	List<ASI_KOR_Sales_Order_Request__c> sorList = [SELECT Id,(SELECT Id, ASI_CRM_CN_Product_Name__r.ASI_CTY_CN_WS_Is_Especial_For_WS__c 
    															   FROM ASI_KOR_Sales_Order_Transactions__r)
    													FROM ASI_KOR_Sales_Order_Request__c
    													WHERE Id IN :sorIds
                                                        AND ASI_CTY_CN_WS_IsCommunity__c = true];
    	Set<Id> sorErrorIds = new Set<Id>();
    	for (ASI_KOR_Sales_Order_Request__c sor : sorList) {
    		Integer especialCount = 0;
    		Integer notEspecialCount = 0;
    		for (ASI_KOR_Sales_Order_Transaction__c sorItem : sor.ASI_KOR_Sales_Order_Transactions__r) {
    			if (sorItem.ASI_CRM_CN_Product_Name__r.ASI_CTY_CN_WS_Is_Especial_For_WS__c) {
    				especialCount ++ ;
    			} else {
    				notEspecialCount ++;
    			}
    		}
    		if (especialCount > 0 && notEspecialCount > 0) {
    			 sorErrorIds.add(sor.Id);
    		}
    	}
    	for (ASI_KOR_Sales_Order_Transaction__c sorItem : trigger_newMap.values()) {
    		if (sorErrorIds.contains(sorItem.ASI_KOR_Sales_Order_Request__c)) {
    			sorItem.addError(Label.ASI_CTY_CN_WS_MixedProducts);
    		}
    	}

    }
}