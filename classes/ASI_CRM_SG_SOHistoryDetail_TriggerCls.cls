/*********************************************************************************
 * Name:        ASI_CRM_SG_SOHistoryDetail_TriggerCls
 * Description: 
 * Related Test Class: 
 *
 * Version History
 *  Date             Developer               Comments
 *  ---------------  --------------------    --------------------------------------------------------------------------------
 *  2017-08-17       Wilken Lee               [WL 1.0] Created
*********************************************************************************/

public without sharing class ASI_CRM_SG_SOHistoryDetail_TriggerCls{
    
    public static void routineBeforeUpsert(list<ASI_HK_CRM_Sales_Order_History_Detail__c> trigger_new, Map<id,ASI_HK_CRM_Sales_Order_History_Detail__c> oldMap){  
		Set<id> skuIDSet = new Set<id>();
		Set<id> validRTSet = new Set<id>();
		
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'));
		
		for(ASI_HK_CRM_Sales_Order_History_Detail__c i : trigger_new){
			//Wilken 20160923 Added Adjustment checkbox for triggering re-calculation of existing offtake
			if(i.recordTypeId ==  Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail')){
				if (oldMap == null || 
					(oldMap != null && (i.ASI_HK_CRM_Product_SKU__c != oldMap.get(i.id).ASI_HK_CRM_Product_SKU__c)
					) ||
					i.ASI_CRM_Recalculate_Product_Cost__c == true)
				{
					//Prepare a set of SKU which need to retrieve latest PRS-WS Price for calculating Gross Sales on offtake record
					skuIDSet.add(i.ASI_HK_CRM_Product_SKU__c);
				}
			}
		}
		
		if (skuIDSet.size() > 0){
			List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = [select id, ASI_CRM_Price__c, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c, ASI_CRM_SKU__c, recordTypeID from ASI_CRM_MY_SKUPriceCost__c 
				where ASI_CRM_SKU__c = :skuIDSet and recordTypeID = :validRTSet order by ASI_CRM_SKU__c, ASI_CRM_EffectiveDate__c desc];
				
			Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUDuty = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
			Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUFOB = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
			Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUHandling = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
			
			for (ASI_CRM_MY_SKUPriceCost__c price:skuPriceList){
				if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle')){
					if (mapSKUDuty.containsKey(price.ASI_CRM_SKU__c))
						mapSKUDuty.get(price.ASI_CRM_SKU__c).add(price);
					else 
						mapSKUDuty.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
				}
				else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle')){
					if (mapSKUFOB.containsKey(price.ASI_CRM_SKU__c))
						mapSKUFOB.get(price.ASI_CRM_SKU__c).add(price);
					else 
						mapSKUFOB.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
				}
				else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle')){
					if (mapSKUHandling.containsKey(price.ASI_CRM_SKU__c))
						mapSKUHandling.get(price.ASI_CRM_SKU__c).add(price);
					else 
						mapSKUHandling.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
				}
			}
			
			for(ASI_HK_CRM_Sales_Order_History_Detail__c i : trigger_new){                       
				//Retrieve latest Duty Cost
				ASI_CRM_MY_SKUPriceCost__c lastMatchedDuty;
				
				if (mapSKUDuty.get(i.ASI_HK_CRM_Product_SKU__c) != null){                      
					for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUDuty.get(i.ASI_HK_CRM_Product_SKU__c)){
						//Retrive the latest SKU Duty Cost which the Cost Effective Date matches SO Order Date
						system.debug('lastMatchedDuty is null: ' + lastMatchedDuty == null + ' matched cost details: ' + lastMatchedDuty + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' SO Order date: ' + i.ASI_CRM_Order_Date__c);
						if ((lastMatchedDuty == null && i.ASI_CRM_Order_Date__c >= price.ASI_CRM_EffectiveDate__c)
							|| (lastMatchedDuty != null && i.ASI_CRM_Order_Date__c >= price.ASI_CRM_EffectiveDate__c 
								&& price.ASI_CRM_EffectiveDate__c > lastMatchedDuty.ASI_CRM_EffectiveDate__c))
							lastMatchedDuty = price;
					}
				}
				
				//Retrieve latest FOB Cost
				ASI_CRM_MY_SKUPriceCost__c lastMatchedFOB;
				
				if (mapSKUFOB.get(i.ASI_HK_CRM_Product_SKU__c) != null){
					for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUFOB.get(i.ASI_HK_CRM_Product_SKU__c)){
						//Retrive the latest SKU FOB Cost which the Cost Effective Date matches Offtake GL Date
						system.debug('lastMatchedFOB is null: ' + lastMatchedFOB == null + ' matched cost details: ' + lastMatchedFOB + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' SO Order Date: ' + i.ASI_CRM_Order_Date__c);
						if ((lastMatchedFOB == null && i.ASI_CRM_Order_Date__c >= price.ASI_CRM_EffectiveDate__c)
							|| (lastMatchedFOB != null && i.ASI_CRM_Order_Date__c >= price.ASI_CRM_EffectiveDate__c 
								&& price.ASI_CRM_EffectiveDate__c > lastMatchedFOB.ASI_CRM_EffectiveDate__c))
							lastMatchedFOB = price;
					}
				}
				
				//Retrieve latest Handling Cost
				ASI_CRM_MY_SKUPriceCost__c lastMatchedHandling;
				
				if (mapSKUHandling.get(i.ASI_HK_CRM_Product_SKU__c) != null){
					for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUHandling.get(i.ASI_HK_CRM_Product_SKU__c)){
						//Retrive the latest SKU Handling Cost which the Cost Effective Date matches Offtake GL Date
						system.debug('lastMatchedHandling is null: ' + lastMatchedHandling == null + ' matched cost details: ' + lastMatchedHandling + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' SO Order Date: ' + i.ASI_CRM_Order_Date__c);
						if ((lastMatchedHandling == null && i.ASI_CRM_Order_Date__c >= price.ASI_CRM_EffectiveDate__c)
							|| (lastMatchedHandling != null && i.ASI_CRM_Order_Date__c >= price.ASI_CRM_EffectiveDate__c 
								&& price.ASI_CRM_EffectiveDate__c > lastMatchedHandling.ASI_CRM_EffectiveDate__c))
							lastMatchedHandling = price;
					}
				}
				
				
				if (lastMatchedDuty != null){
					i.ASI_CRM_Duty_Cost__c = lastMatchedDuty.ASI_CRM_Cost__c;
					system.debug('Duty: ' +  lastMatchedDuty.ASI_CRM_Cost__c);
				}
				
				if (lastMatchedFOB != null){
					i.ASI_CRM_FOB_Cost__c = lastMatchedFOB.ASI_CRM_Cost__c;
					system.debug('FOB: ' + lastMatchedFOB.ASI_CRM_Cost__c);
				}
				
				if (lastMatchedHandling != null){
					i.ASI_CRM_Handling_Cost__c = lastMatchedHandling.ASI_CRM_Cost__c;
					system.debug('Handling: ' + lastMatchedHandling.ASI_CRM_Cost__c);
				}
				
				i.ASI_CRM_Recalculate_Product_Cost__c = false;
			}               
		}
	}
}