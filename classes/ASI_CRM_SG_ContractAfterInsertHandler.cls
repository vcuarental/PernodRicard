/*
*********************************************************************************
 * Name: ASI_CRM_SG_ContractAfterInsertHandler
 * Description: Contract After Insert Trigger Handler
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/11/2017       Hugo Cheung             Created
 * 2017-03-27		Vincent Lam				[VL 1.0] ICM117657570 : use new field to represent RTM wholesaler margin
*/
public class ASI_CRM_SG_ContractAfterInsertHandler {
	
	private static final String SKU_SG_RECORD_TYPE = 'ASI_CRM_SG_SKU';

	private final static Set<String> SG_SKU_PRICE_RECORD_TYPE_SET = new Set<String> {
        'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle',
        'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle',
        'ASI_CRM_SG_IGC',
        'ASI_CRM_SG_CRM_Duty_Per_Bottle',
        'ASI_CRM_SG_CRM_FOB_Per_Bottle',
        'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',
        'ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'
    };
        
    private static final String SG_PROPOSAL_RECORD_TYPE = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');

	public static void executeTrigger(List<sObject> newList) {
		
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        for (ASI_TH_CRM_Contract__c c : (List<ASI_TH_CRM_Contract__c>) newList){
            if (c.RecordTypeId == SG_PROPOSAL_RECORD_TYPE){
                contractList.add(c);
            }
        }
		if (contractList.size()>0) updateValueAfterInsert(contractList);
	}

	private static void updateValueAfterInsert(List<ASI_TH_CRM_Contract__c> contractList) {
		//Get Information from contract list, Currently not necessary

		//Retrieve related records
		Map<Id, ASI_MFM_SKU_Code__c> skuMap = new Map<Id, ASI_MFM_SKU_Code__c>(retrieveSKUList('WHERE RecordType.DeveloperName = :SKU_SG_RECORD_TYPE ' + 
			                                                                                   'AND ASI_CRM_Preset__c = true ' + 
			                                                                                   'AND ASI_HK_CRM_Active__c = true '));
		Map<Id, ASI_CRM_SG_SkuPriceWrapper> skuPriceWrapperMap = new Map<Id, ASI_CRM_SG_SkuPriceWrapper>();

		for(ASI_CRM_MY_SKUPriceCost__c skuPrice : retrieveSKUPriceList(skuMap.keySet())) {
			ASI_CRM_SG_SkuPriceWrapper skuPriceWrapper = skuPriceWrapperMap.containsKey(skuPrice.ASI_CRM_SKU__c)
			                                           ? skuPriceWrapperMap.get(skuPrice.ASI_CRM_SKU__c)
			                                           : new ASI_CRM_SG_SkuPriceWrapper(skuMap.get(skuPrice.ASI_CRM_SKU__c));
			skuPriceWrapper.addSKUPrice(skuPrice);           
			skuPriceWrapperMap.put(skuPrice.ASI_CRM_SKU__c, skuPriceWrapper);                                                  
		}

		//Process business logic
		List<ASI_CRM_ContractTarget__c> insertContractTargetList = new List<ASI_CRM_ContractTarget__c>();
		for(ASI_TH_CRM_Contract__c contract : contractList) {
			insertContractTargetList.addAll(generateContractTargetList(contract, skuPriceWrapperMap));
		}

		if(insertContractTargetList.size() > 0) insert insertContractTargetList;
	}

	private static List<ASI_CRM_ContractTarget__c> generateContractTargetList(ASI_TH_CRM_Contract__c contract, Map<Id, ASI_CRM_SG_SkuPriceWrapper> skuPriceWrapperMap) {
		List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();

		Integer sequenceNo = 1;
		
		for(Id skuId : skuPriceWrapperMap.keySet()) {
			ASI_CRM_SG_SkuPriceWrapper skuPriceWrapper = skuPriceWrapperMap.get(skuId);
			if(skuPriceWrapper.checkIsValidRecord() == false) continue; 

			ASI_MFM_SKU_Code__c sku = skuPriceWrapper.sku;
			Map<String, ASI_CRM_MY_SKUPriceCost__c> skuPriceMap = skuPriceWrapper.getSkuPriceMapByEffectiveDate(contract.ASI_TH_CRM_Start_Date__c);
			if(skuPriceMap == null) continue;

			ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWS           = skuPriceMap.get('ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle');
	        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWSOnTrade    = skuPriceMap.get('ASI_CRM_SG_Open_Outlet_Price_Per_Bottle');
	        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostIGC          = skuPriceMap.get('ASI_CRM_SG_IGC');
	        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostDuty         = skuPriceMap.get('ASI_CRM_SG_CRM_Duty_Per_Bottle');
	        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostFob          = skuPriceMap.get('ASI_CRM_SG_CRM_FOB_Per_Bottle');
	        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostHandlingCost = skuPriceMap.get('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle');
	        ASI_CRM_MY_SKUPriceCost__c skuIncentivePrice           = skuPriceMap.get('ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle');

	        ASI_CRM_ContractTarget__c contractTarget = new ASI_CRM_ContractTarget__c();
	        contractTarget.ASI_CRM_Contract__c                         = contract.Id;
	        contractTarget.ASI_CRM_SKU__c                              = sku.Id;
	        contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c      = skuHistoricCostWS == null 
	                                                                   ? (sku.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c == null ? 0 : sku.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c)
	                                                                   : (skuHistoricCostWS.ASI_CRM_Price__c == null ? 0 : skuHistoricCostWS.ASI_CRM_Price__c);

	        contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = skuHistoricCostWSOnTrade == null 
	                                                                   ? (sku.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c == null ? 0 : sku.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c)
	                                                                   : (skuHistoricCostWSOnTrade.ASI_CRM_Price__c == null ? 0 : skuHistoricCostWSOnTrade.ASI_CRM_Price__c);

	        contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c             = skuHistoricCostIGC == null 
	                                                                   ? sku.ASI_CRM_SG_IGC_Cost_Per_case__c
	                                                                   : skuHistoricCostIGC.ASI_CRM_Cost__c;

	        contractTarget.ASI_CRM_Duty_Per_Bottle__c                  = skuHistoricCostDuty == null 
	                                                                   ? 0 
	                                                                   : skuHistoricCostDuty.ASI_CRM_Cost__c;

	        contractTarget.ASI_CRM_FOB_Per_Bottle__c                   = skuHistoricCostFob == null 
	                                                                   ? 0
	                                                                   : skuHistoricCostFob.ASI_CRM_Cost__c;

	        contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c         = skuHistoricCostHandlingCost == null 
	                                                                   ? 0 
	                                                                   : skuHistoricCostHandlingCost.ASI_CRM_Cost__c;

	        contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c              = skuHistoricCostIGC == null
	                                                                   ? sku.ASI_CRM_SG_IGC_Cost_Per_9Lc__c
	                                                                   : skuHistoricCostIGC.ASI_CRM_SG_IGC_Cost_Per_9Lc__c;

	        contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c       = skuIncentivePrice == null 
	                                                                   ? 0
	                                                                   : skuIncentivePrice.ASI_CRM_Price__c;

	        contractTarget.ASI_CRM_TargetCase__c                       = sku.ASI_CRM_Minimum_Sales_Cases__c;
	        contractTarget.ASI_CRM_Minimum_Sales_Cases__c              = sku.ASI_CRM_Minimum_Sales_Cases__c;

			/* [VL 1.0] BEGIN */
			/*
	        contractTarget.ASI_CRM_SG_Wholesaler_Margin__c             = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c 
                                                                       - contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
			*/
	        contractTarget.ASI_CRM_Wholesaler_Margin_RTM__c            = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c 
                                                                       - contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
			/* [VL 1.0] END */
			/*
            contractTarget.ASI_CRM_Bottle_Incentive__c                 = (!contract.ASI_CRM_Contract_Exist_Before_RTM__c && contract.ASI_CRM_Type__c == 'Incentive') ?
                													   contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c - contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c :
                													   0;
			*/
            contractTarget.ASI_CRM_SG_Btls_Per_Case__c                 = sku.ASI_HK_CRM_Packaging_Size__c;
            contractTarget.ASI_CRM_SG_Size_cl__c                       = sku.ASI_HK_CRM_Std_Bottle_Size__c;
			
            contractTarget.ASI_CRM_Sequence_No__c                      = sequenceNo++;

            contractTargetList.add(contractTarget);
		}

		return contractTargetList;
	}

	/***************
    Data Retrievement Function
    ***************/
    private static List<ASI_MFM_SKU_Code__c> retrieveSKUList(String whereClause) {
    	String query = 'SELECT Id, ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c, ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c, ASI_CRM_SG_IGC_Cost_Per_case__c, ASI_CRM_SG_IGC_Cost_Per_9Lc__c '
    	             + ', ASI_HK_CRM_Packaging_Size__c, ASI_HK_CRM_Std_Bottle_Size__c, ASI_CRM_Minimum_Sales_Cases__c '
    	             + ', RecordType.DeveloperName ' 
    	             + 'FROM ASI_MFM_SKU_Code__c ';
    	
    	if(String.isNotBlank(whereClause)) {
    		query += whereClause;
    	}

    	return (List<ASI_MFM_SKU_Code__c>) Database.query(query);
    }

    private static List<ASI_CRM_MY_SKUPriceCost__c> retrieveSKUPriceList(Set<Id> skuIdSet) {
      String query = 'SELECT ASI_CRM_SKU__c, ASI_CRM_SG_IGC_Cost_Per_9Lc__c, ASI_CRM_Price__c, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c' + 
                       ', RecordType.DeveloperName ' +
                       'FROM ASI_CRM_MY_SKUPriceCost__c ' +
                       'WHERE RecordType.DeveloperName in :SG_SKU_PRICE_RECORD_TYPE_SET ' + 
                       'AND ASI_CRM_EffectiveDate__c != NULL ' + 
                       'AND ASI_CRM_SKU__c in :skuIdSet ';

        query += 'Order By ASI_CRM_SKU__r.Name, ASI_CRM_EffectiveDate__c DESC';
        return (List<ASI_CRM_MY_SKUPriceCost__c>) Database.query(query);
    }

}