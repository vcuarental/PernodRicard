public class ASI_CRM_PH_ActualOfftake_TriggerCls {
	public static void routineBeforeUpsert(list<ASI_TH_CRM_Actual_Offtake__c> trigger_new, Map<id,ASI_TH_CRM_Actual_Offtake__c> oldMap){ 
		Set<Id> skuIDSet = new Set<Id>();
		Set<id> validRTSet = new Set<id>();
		
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Duty_Excise_Tax'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_SKU_Handling_Cost'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_COGS'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Standard_Cost'));
		validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_DP_Distribution_Cost'));
		
		ASI_CRM_PH_Rate__mdt distributionRate = [select ASI_CRM_Rate__c from ASI_CRM_PH_Rate__mdt where MasterLabel = 'Distribution' limit 1];
		
		for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){
			skuIDSet.add(i.ASI_CRM_SKU__c);			
			i.ASI_CRM_Distribution_Rate_Percent__c = distributionRate.ASI_CRM_Rate__c;
		}
		
		List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = [	select id, ASI_CRM_Price__c, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c, ASI_CRM_SKU__c, recordTypeID, ASI_CRM_Customer__c
															from ASI_CRM_MY_SKUPriceCost__c 
                                                            where ASI_CRM_SKU__c = :skuIDSet and recordTypeID = :validRTSet 
															order by ASI_CRM_SKU__c, ASI_CRM_EffectiveDate__c desc
														];

		
		Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapOutletSellingPrice = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();	//Outlet Selling Price, customer specific
		Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapListPrice = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();	//List Price
		Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapDutyCost = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();	//Duty Excise Tax Cost
		Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapHandlingCost = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();	//Handling Cost
		Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapCOGS = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();	//Cost of Good Sold
		Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapStandardCost = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();	//Standard Cost
		Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapDistributionCost = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();	//Distribution Cost
		
		for (ASI_CRM_MY_SKUPriceCost__c price:skuPriceList){
			if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price')){
				if (mapOutletSellingPrice.containsKey(price.ASI_CRM_SKU__c))
					mapOutletSellingPrice.get(price.ASI_CRM_SKU__c).add(price);
				else 
					mapOutletSellingPrice.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
			}			
			else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price')){
				if (mapListPrice.containsKey(price.ASI_CRM_SKU__c))
					mapListPrice.get(price.ASI_CRM_SKU__c).add(price);
				else 
					mapListPrice.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
			}			
			else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Duty_Excise_Tax')){
				if (mapDutyCost.containsKey(price.ASI_CRM_SKU__c))
					mapDutyCost.get(price.ASI_CRM_SKU__c).add(price);
				else 
					mapDutyCost.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
			}			
			else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_SKU_Handling_Cost')){
				if (mapHandlingCost.containsKey(price.ASI_CRM_SKU__c))
					mapHandlingCost.get(price.ASI_CRM_SKU__c).add(price);
				else 
					mapHandlingCost.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
			}
			else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_COGS')){
				if (mapCOGS.containsKey(price.ASI_CRM_SKU__c))
					mapCOGS.get(price.ASI_CRM_SKU__c).add(price);
				else 
					mapCOGS.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
			}			
			else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Standard_Cost')){
				if (mapStandardCost.containsKey(price.ASI_CRM_SKU__c))
					mapStandardCost.get(price.ASI_CRM_SKU__c).add(price);
				else 
					mapStandardCost.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
			}				
			else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_DP_Distribution_Cost')){
				if (mapDistributionCost.containsKey(price.ASI_CRM_SKU__c))
					mapDistributionCost.get(price.ASI_CRM_SKU__c).add(price);
				else 
					mapDistributionCost.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
			}			
		}		
				
		for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){		
			ASI_CRM_MY_SKUPriceCost__c lastMatchedSellingPrice;
			ASI_CRM_MY_SKUPriceCost__c lastMatchedListPrice;
			ASI_CRM_MY_SKUPriceCost__c lastMatchedDutyCost;
			ASI_CRM_MY_SKUPriceCost__c lastMatchedHandlingCost;
			ASI_CRM_MY_SKUPriceCost__c lastMatchedCOGS;
			ASI_CRM_MY_SKUPriceCost__c lastMatchedStandardCost;
			ASI_CRM_MY_SKUPriceCost__c lastMatchedDistributionCost;
		
			if (mapOutletSellingPrice.get(i.ASI_CRM_SKU__c) != null){                        
				for (ASI_CRM_MY_SKUPriceCost__c price:mapOutletSellingPrice.get(i.ASI_CRM_SKU__c)){
					if (price.ASI_CRM_Customer__c == i.ASI_CRM_SG_Customer__c &&
						(
							(lastMatchedSellingPrice == null  && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c) 
							|| 
							(lastMatchedSellingPrice != null && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c 
								&& 
							price.ASI_CRM_EffectiveDate__c > lastMatchedSellingPrice.ASI_CRM_EffectiveDate__c)
						)
					)
						lastMatchedSellingPrice = price;
				}                
			}
			
			if (mapListPrice.get(i.ASI_CRM_SKU__c) != null){                        
				for (ASI_CRM_MY_SKUPriceCost__c price:mapListPrice.get(i.ASI_CRM_SKU__c)){
					if ((lastMatchedListPrice == null  && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c) 
						|| 
						(lastMatchedListPrice != null && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c 
							&& 
						price.ASI_CRM_EffectiveDate__c > lastMatchedListPrice.ASI_CRM_EffectiveDate__c)
					)
						lastMatchedListPrice = price;
				}                
			}
			
			if (mapDutyCost.get(i.ASI_CRM_SKU__c) != null){                        
				for (ASI_CRM_MY_SKUPriceCost__c price:mapDutyCost.get(i.ASI_CRM_SKU__c)){
					if ((lastMatchedDutyCost == null  && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c) 
						|| 
						(lastMatchedDutyCost != null && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c 
							&& 
						price.ASI_CRM_EffectiveDate__c > lastMatchedDutyCost.ASI_CRM_EffectiveDate__c)
					)
						lastMatchedDutyCost = price;
				}                
			}
			
			if (mapHandlingCost.get(i.ASI_CRM_SKU__c) != null){                        
				for (ASI_CRM_MY_SKUPriceCost__c price:mapHandlingCost.get(i.ASI_CRM_SKU__c)){
					if ((lastMatchedHandlingCost == null  && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c) 
						|| 
						(lastMatchedHandlingCost != null && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c 
							&& 
						price.ASI_CRM_EffectiveDate__c > lastMatchedHandlingCost.ASI_CRM_EffectiveDate__c)
					)
						lastMatchedHandlingCost = price;
				}                
			}
			
			if (mapCOGS.get(i.ASI_CRM_SKU__c) != null){                        
				for (ASI_CRM_MY_SKUPriceCost__c price:mapCOGS.get(i.ASI_CRM_SKU__c)){
					if ((lastMatchedCOGS == null  && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c) 
						|| 
						(lastMatchedCOGS != null && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c 
							&& 
						price.ASI_CRM_EffectiveDate__c > lastMatchedCOGS.ASI_CRM_EffectiveDate__c)
					)
						lastMatchedCOGS = price;
				}                
			}		
			
			if (mapStandardCost.get(i.ASI_CRM_SKU__c) != null){                        
				for (ASI_CRM_MY_SKUPriceCost__c price:mapStandardCost.get(i.ASI_CRM_SKU__c)){
					if ((lastMatchedStandardCost == null  && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c) 
						|| 
						(lastMatchedStandardCost != null && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c 
							&& 
						price.ASI_CRM_EffectiveDate__c > lastMatchedStandardCost.ASI_CRM_EffectiveDate__c)
					)
						lastMatchedStandardCost = price;
				}                
			}			
			
			if (mapDistributionCost.get(i.ASI_CRM_SKU__c) != null){                        
				for (ASI_CRM_MY_SKUPriceCost__c price:mapDistributionCost.get(i.ASI_CRM_SKU__c)){
					if ((lastMatchedDistributionCost == null  && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c) 
						|| 
						(lastMatchedDistributionCost != null && i.ASI_TH_CRM_Offtake_G_L_Date__c >= price.ASI_CRM_EffectiveDate__c 
							&& 
						price.ASI_CRM_EffectiveDate__c > lastMatchedDistributionCost.ASI_CRM_EffectiveDate__c)
					)
						lastMatchedDistributionCost = price;
				}                
			}			
			
			if (lastMatchedSellingPrice != null)
				i.ASI_CRM_Outlet_Selling_Price__c = lastMatchedSellingPrice.ASI_CRM_Price__c;
				
			if (lastMatchedListPrice != null)
				i.ASI_CRM_List_Price__c = lastMatchedListPrice.ASI_CRM_Price__c;
			
			if (lastMatchedDutyCost != null)
				i.ASI_CRM_Duty_Cost__c = lastMatchedDutyCost.ASI_CRM_Cost__c;
			
			if (lastMatchedHandlingCost != null)
				i.ASI_CRM_Handling_Cost__c = lastMatchedHandlingCost.ASI_CRM_Cost__c;
			
			if (lastMatchedCOGS != null)
				i.ASI_CRM_Cost_of_Sales__c = lastMatchedCOGS.ASI_CRM_Cost__c;
			
			if (lastMatchedStandardCost != null)
				i.ASI_CRM_Standard_Cost__c = lastMatchedStandardCost.ASI_CRM_Cost__c;
			
			if (lastMatchedDistributionCost != null)
				i.ASI_CRM_Distribution_Cost__c = lastMatchedDistributionCost.ASI_CRM_Cost__c;
		}
	}
}