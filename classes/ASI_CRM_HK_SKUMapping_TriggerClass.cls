/*********************************************************************************
* Name:        ASI_CRM_HK_SKUMapping_TriggerClass
* Description: ASI_HK_CRM_EDISORegenHelperCtrlTest, ASI_CRM_HK_EDISO_To_Invoice_Test
* Related Test Class: 
*
* Version History
*  Date             Developer               Comments
*  ---------------  --------------------    --------------------------------------------------------------------------------
*  2018-12-18       Wilken Lee               [WL 1.0] Created
*  2019-04-08       Wilken Lee               [WL 2.0] Bug fix for duplicate SKU Mapping checking blocking the same record itself
*/

public without sharing class ASI_CRM_HK_SKUMapping_TriggerClass{
	public static void routineAfterInsertItemGroup(list<ASI_CRM_SKU_Mapping__c> trigger_new, Map<id,ASI_CRM_SKU_Mapping__c> oldMap){ 
		Set<Id> itemGroupID = new Set<Id>();
		Set<Id> itemGroupMappingID = new Set<Id>();
		
		List<ASI_CRM_SKU_Mapping__c> skuMappingToInsert = new List<ASI_CRM_SKU_Mapping__c>();
		
		for (ASI_CRM_SKU_Mapping__c mapping:trigger_new){
			itemGroupID.add(mapping.ASI_CRM_Item_Group__c);
			itemGroupMappingID.add(mapping.Id);
		}
		
		//delete existing SKU Mapping
		List<ASI_CRM_SKU_Mapping__c> existingSKUMapping = [SELECT Id FROM ASI_CRM_SKU_Mapping__c 
														WHERE RecordType.DeveloperName = 'ASI_CRM_HK_EDI_SKU_Mapping' AND ASI_CRM_Item_Group_Mapping__c IN :itemGroupMappingID];
		delete existingSKUMapping;
			
		//Insert new SKU Mapping
		
		List<ASI_MFM_SKU_Code__c> skuList = [SELECT Id, ASI_MFM_Item_Group__c FROM ASI_MFM_SKU_Code__c WHERE RecordType.DeveloperName = 'ASI_HK_CRM_SKU' AND ASI_HK_CRM_Active__c = TRUE AND ASI_MFM_Item_Group__c = :itemGroupID];
		Integer counter;
		Map<Id,Integer> itemMappingCounter = new Map<Id,Integer>();

		for (ASI_CRM_SKU_Mapping__c mapping:trigger_new){
			counter = 0;
			
			for (ASI_MFM_SKU_Code__c sku:skuList){
				if (mapping.ASI_CRM_Item_Group__c == sku.ASI_MFM_Item_Group__c){
					ASI_CRM_SKU_Mapping__c newMapping = new ASI_CRM_SKU_Mapping__c();
					newMapping.recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cASI_CRM_HK_EDI_SKU_Mapping');
					newMapping.ASI_CRM_Account__c = mapping.ASI_CRM_Account__c;
					newMapping.ASI_CRM_Item_Group__c = mapping.ASI_CRM_Item_Group__c;
					newMapping.ASI_CRM_SKU__c = sku.Id;
					newMapping.ASI_CRM_Item_Number__c = mapping.ASI_CRM_Item_Number__c;
					newMapping.ASI_CRM_Item_Group_Mapping__c = mapping.Id;
					skuMappingToInsert.add(newMapping);
					
					counter++;
				}				
			}
			itemMappingCounter.put(mapping.Id,counter);
		}
		
		//Assign SKU Mapping as Preferred if there is only 1 SKU in item group
		for (ASI_CRM_SKU_Mapping__c mapping:trigger_new){
			if (itemMappingCounter.get(mapping.Id) == 1){
                system.debug('Item Group has 1 SKU, default mapping as Preferred');
				for (ASI_CRM_SKU_Mapping__c skuMapping:skuMappingToInsert){
					if (mapping.ASI_CRM_Item_Group__c == skuMapping.ASI_CRM_Item_Group__c && mapping.ASI_CRM_Account__c == skuMapping.ASI_CRM_Account__c)
						skuMapping.ASI_CRM_Preferred__c = true;
				}
			}
		}
		
		if (skuMappingToInsert.size() > 0)
			insert skuMappingToInsert;
		
	}
	
	public static void routineBeforeInsertItemGroup(list<ASI_CRM_SKU_Mapping__c> trigger_new){ 
		//Validate each customer Item Code will have 1 preferred Item group mapping  only
		Set<Id> acctId = new Set<Id>();
		Set<String> itemNum = new Set<String>();
		
		for (ASI_CRM_SKU_Mapping__c mapping:trigger_new){
			if (mapping.ASI_CRM_Preferred__c == true){
				acctId.add(mapping.ASI_CRM_Account__c);
				itemNum.add(mapping.ASI_CRM_Item_Number__c);
			}
		}
		
		List<ASI_CRM_SKU_Mapping__c> existingItemGroupMapping = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_Item_Group_Mapping__c, ASI_CRM_Item_Number__c, ASI_CRM_Preferred__c FROM ASI_CRM_SKU_Mapping__c
															WHERE RecordType.DeveloperName = 'ASI_CRM_HK_EDI_Item_Group_Mapping' AND ASI_CRM_Account__c IN :acctId
															AND ASI_CRM_Item_Number__c IN :itemNum
															AND ASI_CRM_Inactive__c = FALSE AND ASI_CRM_Preferred__c = TRUE];
		
		List<ASI_CRM_SKU_Mapping__c> existingMapRemovePrefer = new List<ASI_CRM_SKU_Mapping__c>();	//WL 2.0
		
		if (existingItemGroupMapping.size() > 0){
			for (ASI_CRM_SKU_Mapping__c mapping:trigger_new){
				for (ASI_CRM_SKU_Mapping__c existing:existingItemGroupMapping){
					if (mapping.ASI_CRM_Account__c == existing.ASI_CRM_Account__c && mapping.ASI_CRM_Item_Number__c == existing.ASI_CRM_Item_Number__c
						&& mapping.Id != existing.Id //WL 2.0
					){
						/*[WL 2.0] BEGIN*/
						existing.ASI_CRM_Preferred__c = false;
						existingMapRemovePrefer.add(existing);
						//mapping.addError('Existing Item Group Mapping ' + existing.Name + ' is already set as Preferred. Please remove it from Preferred mapping first.');						
						/*[WL 2.0] END*/
					}
				}
			}
			
			if (existingMapRemovePrefer.size() > 0)	//WL 2.0
				update existingMapRemovePrefer;	//WL 2.0
		}		
	}
	
	public static void routineBeforeUpdateSKU(list<ASI_CRM_SKU_Mapping__c> trigger_new, Map<id,ASI_CRM_SKU_Mapping__c> oldMap){ 
		//Validate each item group can has 1 preferred SKU only
		Set<Id> itemGroupMappingID = new Set<Id>();
		
		for (ASI_CRM_SKU_Mapping__c mapping:trigger_new){
			if (mapping.ASI_CRM_Preferred__c == true && oldMap.get(mapping.Id) != null && oldMap.get(mapping.Id).ASI_CRM_Preferred__c == false){
				itemGroupMappingID.add(mapping.ASI_CRM_Item_Group_Mapping__c);
			}
		}
		
		List<ASI_CRM_SKU_Mapping__c> existingSKUMapping = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_Item_Group_Mapping__c, ASI_CRM_Preferred__c  FROM ASI_CRM_SKU_Mapping__c 
															WHERE RecordType.DeveloperName = 'ASI_CRM_HK_EDI_SKU_Mapping' AND ASI_CRM_Item_Group_Mapping__c IN :itemGroupMappingID
															AND ASI_CRM_Inactive__c = FALSE AND ASI_CRM_Preferred__c = TRUE];
		
		List<ASI_CRM_SKU_Mapping__c> existingMapRemovePrefer = new List<ASI_CRM_SKU_Mapping__c>();	//WL 2.0
		
		if (existingSKUMapping.size() > 0){
			for (ASI_CRM_SKU_Mapping__c mapping:trigger_new){
				for (ASI_CRM_SKU_Mapping__c existing:existingSKUMapping){
					if (mapping.ASI_CRM_Account__c == existing.ASI_CRM_Account__c && mapping.ASI_CRM_Item_Group_Mapping__c == existing.ASI_CRM_Item_Group_Mapping__c
						&& mapping.Id != existing.Id //WL 2.0
					){
						/*[WL 2.0] BEGIN*/
						existing.ASI_CRM_Preferred__c = false;
						existingMapRemovePrefer.add(existing);
						//mapping.addError('Existing SKU Mapping ' + existing.Name + ' is already set as Preferred. Please remove it from Preferred mapping first.');
					}
				}
			}
			
			if (existingMapRemovePrefer.size() > 0)	//WL 2.0
				update existingMapRemovePrefer;	//WL 2.0
		}		
	}
}