/*********************************************************************************
 * Name: ASI_CRM_PH_FreeGoodsRequest_TriggerClass
 * Description: Controller for ASI_FOC_Free_Goods_Request__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 19/11/2018       Calvin Chiu             Created     
 * 10/01/2019		Calvin Chiu				Use ASI_HK_CRM_Inventory__c instead of ASI_HK_CRM_Inventory__c
*/
public without sharing class ASI_CRM_PH_FreeGoodsRequest_TriggerClass {
    
	private static final string RTID_PO = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_MFM_PH_PO_FOC_POSM_Request');
	private static final string RTID_PORO = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_MFM_PH_PO_FOC_POSM_Request_Read_Only');
	private static final string RTID_CONTRACT = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request');
	private static final string RTID_CONTRACTRO = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request_Read_Only');
	
	public static void routineAfterUpdate(List<ASI_FOC_Free_Goods_Request__c> trigger_New, Map<Id, ASI_FOC_Free_Goods_Request__c> trigger_OldMap){
    	Map<Id, Decimal> skuItemCount = new Map<Id, Decimal>(); // sku Id: sum of ASI_FOC_Request_Quantity_Bottle__c
    	Set<Id> submittedFoc = new Set<Id>();
    	Set<Id> rejectedFoc = new Set<Id>();
    	Set<Id> approvedFOC_PO = new Set<Id>();
    	Set<Id> approvedFOC_Contract = new Set<Id>();
    	
    	for(ASI_FOC_Free_Goods_Request__c foc: trigger_New){
    		if(foc.recordtypeId == RTID_CONTRACT || foc.recordtypeId == RTID_CONTRACTRO){
				if(foc.ASI_FOC_Request_Status__c != trigger_OldMap.get(foc.Id).ASI_FOC_Request_Status__c && foc.ASI_FOC_Request_Type__c == 'POSM'){
					if(foc.ASI_FOC_Request_Status__c == 'Submitted'){
						submittedFoc.add(foc.Id);
					} 
					else if(foc.ASI_FOC_Request_Status__c == 'Rejected'){
						rejectedFoc.add(foc.Id);
					}
				}    		
				if(foc.ASI_FOC_Request_Status__c == 'Final' && trigger_OldMap.get(foc.Id).ASI_FOC_Request_Status__c == 'Submitted'){
					approvedFOC_Contract.add(foc.ASI_CRM_Contract__c);
				}
			} else
            if(foc.recordtypeId == RTID_PO || foc.recordtypeId == RTID_PORO){
                // when the foc request is approved
				if(foc.ASI_FOC_Request_Status__c == 'Final' && trigger_OldMap.get(foc.Id).ASI_FOC_Request_Status__c == 'Submitted'){
					approvedFOC_PO.add(foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c);
				}
            }
    	}
    	
    	for(ASI_FOC_Request_Item__c item: [select ASI_FOC_Request_Order__c, ASI_FOC_SKU__c, ASI_FOC_Request_Quantity_Bottle__c from ASI_FOC_Request_Item__c where recordType.DeveloperName = 'ASI_CRM_PH_FOC_POSM_Request_Item' AND (ASI_FOC_Request_Order__c in: submittedFoc OR ASI_FOC_Request_Order__c in: rejectedFoc) for update]){
    		if(submittedFoc.contains(item.ASI_FOC_Request_Order__c)){
    			Decimal amount = skuItemCount.get(item.ASI_FOC_SKU__c);
    			if(amount == null){
    				amount = 0;
    			}
    			skuItemCount.put(item.ASI_FOC_SKU__c, amount - item.ASI_FOC_Request_Quantity_Bottle__c);    			
    		}
    		else if(rejectedFoc.contains(item.ASI_FOC_Request_Order__c)){
    			Decimal amount = skuItemCount.get(item.ASI_FOC_SKU__c);
    			if(amount == null){
    				amount = 0;
    			}
    			skuItemCount.put(item.ASI_FOC_SKU__c, amount + item.ASI_FOC_Request_Quantity_Bottle__c);
    		}
    	}
    	
    	if(!skuItemCount.isEmpty()){
	    	List<ASI_MFM_SKU_Code__c> updateSKUList = new List<ASI_MFM_SKU_Code__c>();
	    	for(ASI_MFM_SKU_Code__c sku: [select ASI_HK_CRM_Inventory__c from ASI_MFM_SKU_Code__c where id in: skuItemCount.keySet() for update]){
	    		if(sku.ASI_HK_CRM_Inventory__c == null){
	    			sku.ASI_HK_CRM_Inventory__c = 0;
	    		}    		
	    		sku.ASI_HK_CRM_Inventory__c += skuItemCount.get(sku.Id);
	    		updateSKUList.add(sku);
	    	}
	    	
	    	update updateSKUList;
    	}
		
		if(approvedFOC_PO.size() > 0){
			rollupPO(approvedFOC_PO);
		}
		
		if(approvedFOC_Contract.size() > 0){
			rollupContract(approvedFOC_Contract);
		}
    }
	
	private static void rollupPO(set<id> set_POID){
		list<ASI_MFM_PO__c> list_po = new list<ASI_MFM_PO__c>();
		for(AggregateResult ar : [
            select
				sum(ASI_CRM_FOC_Amount_Number__c) amount,
                ASI_FOC_MFM_Consumer_AP_PO_Number__c poid
            from 
                ASI_FOC_Free_Goods_Request__c
            where
                recordtypeid in (:RTID_PO, :RTID_PORO)
				and ASI_FOC_MFM_Consumer_AP_PO_Number__c in :set_POID
            group by
				ASI_FOC_MFM_Consumer_AP_PO_Number__c
        ]){
            string poid = string.valueOf(ar.get('poid'));
			decimal amount = (decimal)ar.get('amount');
            list_po.add(new ASI_MFM_PO__c(
				id = poid,
				ASI_MFM_FOC_Actual__c = amount
			));
        }
		if(list_po.size()>0){
			update list_po;
		}
	}
	
	private static void rollupContract(set<id> set_ContractID){
		map<string, ASI_TH_CRM_Contract__c> map_contract = new map<string, ASI_TH_CRM_Contract__c>();
		for(AggregateResult ar : [
            select
				sum(ASI_CRM_FOC_Amount_Number__c) amount,
                ASI_CRM_Contract__c cid,
				ASI_FOC_Request_Type__c type
            from 
                ASI_FOC_Free_Goods_Request__c
            where
                recordtypeid = :RTID_CONTRACTRO
				and ASI_CRM_Contract__c in :set_ContractID
            group by
				ASI_CRM_Contract__c,
				ASI_FOC_Request_Type__c
        ]){
            string cid = string.valueOf(ar.get('cid'));
            string type = string.valueOf(ar.get('type'));
			decimal amount = (decimal)ar.get('amount');
			ASI_TH_CRM_Contract__c c = map_contract.containsKey(cid) ? map_contract.get(cid) : new ASI_TH_CRM_Contract__c(id = cid);
            if(type == 'FOC'){
				c.ASI_CRM_Paid_Marketing_Support_Fund_Amt__c = amount;
			} else {
				c.ASI_CRM_Paid_Merchandise_Amount__c = amount;
			}
			map_contract.put(cid, c);
        }
		if(map_contract != null && map_contract.values().size()>0){
			update map_contract.values();
		}
	}
}