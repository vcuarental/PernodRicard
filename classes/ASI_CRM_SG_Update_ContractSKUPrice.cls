/*********************************************************************************
 * Name: ASI_CRM_SG_Update_ContractSKUPrice
 * Description: Update the contract SKU Price if the contract start date is updated
 * Test Class: ASI_CRM_SG_Update_ContractSKUPrice_Test
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/05/2016       Laputa:Hugo             Created
 * 2016-08-16       Laputa: Vincent         [VL 1.0] Revise entry criteria
 * 2017-11-27       Laputa: Vincent         [VL 2.0] Handle RTM contract
 * 2018-02-06       Laputa: Vincent         [VL 3.0] Populate PRS-WS (RTM) price to all contract target
 * 2018-03-27       Laputa: Vincent         [VL 4.0] ICM117657570 : use new field to store RTM wholesaler margin
 * 2018-10-26       Wilken Lee         		[WL 5.0] Allow issuing back rebate even if 0 sales target, do not auto uncheck back rebate checkbox
 *              
*/
public with sharing class ASI_CRM_SG_Update_ContractSKUPrice extends ASI_CRM_SG_TriggerAbstract {
    
    //The record type of SKU Price that related to CRM SG
    private static Set<String> SKU_PRICE_RECORD_TYPE = new Set<String> {
        'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',
        'ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',
        'ASI_CRM_SG_IGC',
        'ASI_CRM_SG_CRM_Duty_Per_Bottle',
        'ASI_CRM_SG_CRM_FOB_Per_Bottle',
        'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'
		/* [VL 2.0] BEGIN */
        ,'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'
        ,'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle'
        ,'ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'
		/* [VL 2.0] END */
    };
	
    //only update price/cost for status below 
    private static Set<String> CONTRACT_STATUS = new Set<String> {
        'Draft',
        'Proposal Rejected',
        'Contract Rejected',
        'Archived'
    };

    public ASI_CRM_SG_Update_ContractSKUPrice() {
        super('ASI_CRM_SG_Update_ContractSKUPrice');
    }

    public override void executeTriggerAction (
        TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<Id> updatedContractIdList = new List<Id>();
        List<Id> list_allContract = new List<Id>();
        
        for(ASI_TH_CRM_Contract__c contract : (List<ASI_TH_CRM_Contract__c>)sObjList) {

			if(contract.ASI_CRM_SYS_Update_Price_Cost__c) list_allContract.add(contract.Id);
		
            ASI_TH_CRM_Contract__c tempContract = oldMap != null ? (ASI_TH_CRM_Contract__c) oldMap.get(contract.Id) : new ASI_TH_CRM_Contract__c();

            if (!Test.isRunningTest()) {
            
                // [VL 1.0] entry criteria:
                // - new status = Draft / Proposal Rejected / Contract Rejected / Archived; OR
                // - contract start date is changed
                if(contract.ASI_TH_CRM_Start_Date__c != null && 
                   ((CONTRACT_STATUS.contains(contract.ASI_TH_CRM_Contract_Status__c) && contract.ASI_TH_CRM_Contract_Status__c != tempContract.ASI_TH_CRM_Contract_Status__c) || 
                    (contract.ASI_TH_CRM_Start_Date__c != tempContract.ASI_TH_CRM_Start_Date__c) ||
					contract.ASI_CRM_SYS_Update_Price_Cost__c)
                  ) {
                    
                    updatedContractIdList.add(contract.Id);
                                    
                }
            } else {
                if (oldMap != null) {
                    //ASI_TH_CRM_Contract__c tempContract = (ASI_TH_CRM_Contract__c) oldMap.get(contract.Id);
                    if(contract.ASI_TH_CRM_Start_Date__c != tempContract.ASI_TH_CRM_Start_Date__c || 
                       contract.ASI_CRM_Revising__c ||
						contract.ASI_CRM_SYS_Update_Price_Cost__c
                    ) {
    
                        updatedContractIdList.add(contract.Id);
    
                    }
                }
            }

        }
        
        if(updatedContractIdList.size() != 0) {
            
            //Get the contract target based on the contract id
            List<ASI_CRM_ContractTarget__c> contractTargetList = getContractTargetList(updatedContractIdList);
            
            if(contractTargetList.size() != 0) {
                
                //Get the sku id from contract target
                List<Id> skuIdList = new List<Id>();
                
                for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {

                    skuIdList.add(contractTarget.ASI_CRM_SKU__c);

                }
                
                //Get the sku price based on the sku id list
                List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = getSKUPriceList(skuIdList);
                //store need-to-update contract target list if price change
                List<ASI_CRM_ContractTarget__c> contractTargetList_final = new List<ASI_CRM_ContractTarget__c>();
                
                for(ASI_TH_CRM_Contract__c contract : (List<ASI_TH_CRM_Contract__c>)sObjList) {
                    
                    Map<Id, Map<String, ASI_CRM_MY_SKUPriceCost__c>> skuIdPriceMap = getSKUPriceIdMap(skuPriceList, contract.ASI_TH_CRM_Start_Date__c);
                    
                    //Update contract target if contract target is under current contract
                    for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
                        
                        if(contractTarget.ASI_CRM_Contract__c == contract.Id) {
 
                            Map<String, ASI_CRM_MY_SKUPriceCost__c> tempSKUPriceTypeMap = skuIdPriceMap.get(contractTarget.ASI_CRM_SKU__c);
                            
                            Decimal Selling_Price_Btl_PRS_WS = contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
                            Decimal Selling_Price_Btl_WS_On_Trade = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c;
                            Decimal IGC_Cost_Per_case = contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c;
                            Decimal Duty_Per_Bottle = contractTarget.ASI_CRM_Duty_Per_Bottle__c;
                            Decimal FOB_Per_Bottle = contractTarget.ASI_CRM_FOB_Per_Bottle__c;
                            Decimal Handling_Cost_Per_Bottle = contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c;
                            Decimal ASI_CRM_SG_IGC_Cost_Per_9Lc = contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c;
							/* [VL 2.0] BEGIN */
                            Decimal ASI_CRM_Incentive_Price_Per_Bottle = contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c;
							/* [VL 2.0] END */
							/* [VL 3.0] BEGIN */
                            Decimal ASI_CRM_RTM_Price_Per_Bottle_PRS_WS = contractTarget.ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c;
                            Decimal ASI_CRM_RTM_Price_Per_Bottle_WS_OT = contractTarget.ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c;
							/* [VL 3.0] END */
                            
                            updateSKUPrice(contractTarget, tempSKUPriceTypeMap);
                            
                            
                            if (
                                Selling_Price_Btl_PRS_WS  != contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c ||
                                Selling_Price_Btl_WS_On_Trade != contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c ||
                                IGC_Cost_Per_case != contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c ||
                                Duty_Per_Bottle != contractTarget.ASI_CRM_Duty_Per_Bottle__c ||
                                FOB_Per_Bottle != contractTarget.ASI_CRM_FOB_Per_Bottle__c ||
                                Handling_Cost_Per_Bottle != contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c ||
                                ASI_CRM_SG_IGC_Cost_Per_9Lc != contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c
								/* [VL 2.0] BEGIN */
								|| ASI_CRM_Incentive_Price_Per_Bottle != contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c
								/* [VL 2.0] END */
								/* [VL 3.0] BEGIN */
								|| ASI_CRM_RTM_Price_Per_Bottle_PRS_WS != contractTarget.ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c
								|| ASI_CRM_RTM_Price_Per_Bottle_WS_OT != contractTarget.ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c
								/* [VL 3.0] END */
                            ) {
                                contractTargetList_final.add(contractTarget);
                            }
                               
                        }
        
                    }
                    
                }
                
                //update contractTargetList;
                update contractTargetList_final;
            }
			
			
        }
        
			list<ASI_TH_CRM_Contract__c> list_c = [select id from ASI_TH_CRM_Contract__c where id in :list_allContract];
			for(ASI_TH_CRM_Contract__c c : list_c){
				c.ASI_CRM_SYS_Update_Price_Cost__c = false;
			}
			update list_c;

    }

    private List<ASI_CRM_ContractTarget__c> getContractTargetList(List<Id> contractIdList) {

        List<ASI_CRM_ContractTarget__c> contractTargetList = [SELECT Id,
                                                                     ASI_CRM_Contract__c, 
                                                                     ASI_CRM_SKU__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_case__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_9Lc__c,
                                                                     ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c,
                                                                     ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c,
                                                                     ASI_CRM_SG_IGC_Cost_Per_case__c,
                                                                     ASI_CRM_Duty_Per_Bottle__c,
                                                                     ASI_CRM_FOB_Per_Bottle__c,
                                                                     ASI_CRM_Handling_Cost_Per_Bottle__c,
                                                                     ASI_CRM_SG_IGC_Cost_Per_9Lc__c
																	 /* [VL 2.0] BEGIN */
																	 , ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c
																	 , ASI_CRM_Entitle_Back_Rebates__c
																	 , ASI_CRM_TargetCase__c
																	 , ASI_CRM_Minimum_Sales_Cases__c
																	 , ASI_CRM_Incentive_Price_Per_Bottle__c
																	 /* [VL 2.0] END */
																	 /* [VL 3.0] BEGIN */
																	 , ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c
																	 , ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c
																	 /* [VL 3.0] END */
                                                              FROM ASI_CRM_ContractTarget__c
                                                              WHERE ASI_CRM_Contract__c in :contractIdList
                                                                    AND RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target')];

        return contractTargetList;
    }

    private List<ASI_CRM_MY_SKUPriceCost__c> getSKUPriceList(List<Id> skuIdList) {

        Map<String, Schema.SObjectField> skuHistoricFieldsMap = Schema.SObjectType.ASI_CRM_MY_SKUPriceCost__c.fields.getMap();
        String query = 'SELECT RecordType.DeveloperName, ';

        for(String fields  : skuHistoricFieldsMap.keySet()){
            query += fields + ' ,';
        }
            
        query = query.subString(0,query.length()-1);
        query +=' From ASI_CRM_MY_SKUPriceCost__c where ';
            
        query +=' RecordType.DeveloperName IN :SKU_PRICE_RECORD_TYPE';
        query +=' AND ASI_CRM_SKU__c IN :skuIdList AND ASI_CRM_EffectiveDate__c != NULL';
        
        return (List<ASI_CRM_MY_SKUPriceCost__c>)Database.query(query);
    }

    private Map<Id, Map<String, ASI_CRM_MY_SKUPriceCost__c>> getSKUPriceIdMap(List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList, Date contractStartDate) {

        //Create a map that store the latest effect date of sku price, the key format is ([SKU Id][KU Price Record Type API Name])
        Map<String, Date> latestSKUDateMap = new Map<String, Date>();
        //Create a map that store the sku id and the price under this sku, the map format is Map<SKU Id, Map<SKU Price Record Type API Name, SKU Price>>
        Map<Id, Map<String, ASI_CRM_MY_SKUPriceCost__c>> skuIdPriceMap = new Map<Id, Map<String, ASI_CRM_MY_SKUPriceCost__c>>();
                    
        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
                        
            //If the sku id with record type api name is already exist in the map 
            if(latestSKUDateMap.containsKey(skuPrice.ASI_CRM_SKU__c + '' + skuPrice.RecordType.DeveloperName)) {
                            
                //Check the sku price effective date is bigger than the latest sku price date 
                //And the sku price effective date is lower or equal to the contract start date 
                if(skuPrice.ASI_CRM_EffectiveDate__c <= contractStartDate && 
                    skuPrice.ASI_CRM_EffectiveDate__c > latestSKUDateMap.get(skuPrice.ASI_CRM_SKU__c + '' + skuPrice.RecordType.DeveloperName)) {
                                
                    //Store the sku price data and the effective date
                    latestSKUDateMap.put(skuPrice.ASI_CRM_SKU__c + '' + skuPrice.RecordType.DeveloperName, skuPrice.ASI_CRM_EffectiveDate__c);
                    Map<String, ASI_CRM_MY_SKUPriceCost__c> tempSKUPriceTypeMap = skuIdPriceMap.get(skuPrice.ASI_CRM_SKU__c);
                    tempSKUPriceTypeMap.put(skuPrice.RecordType.DeveloperName, skuPrice);
                    skuIdPriceMap.put(skuPrice.ASI_CRM_SKU__c, tempSKUPriceTypeMap);

                }
                        
            //If the sku id with record type api name first appear
            } else {
                            
                //The sku price effective date is lower or equal to the contract start date 
                if(skuPrice.ASI_CRM_EffectiveDate__c <= contractStartDate) {
                                
                    //Store the sku price data and the effective date
                    latestSKUDateMap.put(skuPrice.ASI_CRM_SKU__c + '' + skuPrice.RecordType.DeveloperName, skuPrice.ASI_CRM_EffectiveDate__c);
                                
                    Map<String, ASI_CRM_MY_SKUPriceCost__c> tempSKUPriceTypeMap;
                                
                    if(skuIdPriceMap.containsKey(skuPrice.ASI_CRM_SKU__c)) {
                                    
                        tempSKUPriceTypeMap = skuIdPriceMap.get(skuPrice.ASI_CRM_SKU__c);
                                
                    } else {
                                    
                        tempSKUPriceTypeMap = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
                                    
                    }
                                
                    tempSKUPriceTypeMap.put(skuPrice.RecordType.DeveloperName, skuPrice);
                    skuIdPriceMap.put(skuPrice.ASI_CRM_SKU__c, tempSKUPriceTypeMap);

                }

            }

        }

        return skuIdPriceMap;

    }

    private void updateSKUPrice(ASI_CRM_ContractTarget__c contractTarget, Map<String, ASI_CRM_MY_SKUPriceCost__c> skuPriceTypeMap) {

        if(skuPriceTypeMap != null) {

			/* [VL 2.0] BEGIN */
			/*
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWS = skuPriceTypeMap.get('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler');
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWSOnTrade = skuPriceTypeMap.get('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade');
			*/
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWS = !contractTarget.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c ? skuPriceTypeMap.get('ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle') : skuPriceTypeMap.get('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler');
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWSOnTrade = !contractTarget.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c ? skuPriceTypeMap.get('ASI_CRM_SG_Open_Outlet_Price_Per_Bottle') : skuPriceTypeMap.get('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade');
			/* [VL 2.0] END */
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostIGC = skuPriceTypeMap.get('ASI_CRM_SG_IGC');
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostDuty = skuPriceTypeMap.get('ASI_CRM_SG_CRM_Duty_Per_Bottle');
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostFob = skuPriceTypeMap.get('ASI_CRM_SG_CRM_FOB_Per_Bottle');
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostHandlingCost = skuPriceTypeMap.get('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle');
			/* [VL 2.0] BEGIN */
            ASI_CRM_MY_SKUPriceCost__c skuIncentivePrice = !contractTarget.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c ? skuPriceTypeMap.get('ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle') : null;
			/* [VL 2.0] END */
			/* [VL 3.0] BEGIN */
            ASI_CRM_MY_SKUPriceCost__c skuRTMwsPrice = skuPriceTypeMap.get('ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle');
            ASI_CRM_MY_SKUPriceCost__c skuRTMotPrice = skuPriceTypeMap.get('ASI_CRM_SG_Open_Outlet_Price_Per_Bottle');
			/* [VL 3.0] END */
    
            contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = skuHistoricCostWS != null ? skuHistoricCostWS.ASI_CRM_Price__c : contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c;
            contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = skuHistoricCostWSOnTrade != null ? skuHistoricCostWSOnTrade.ASI_CRM_Price__c : contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c = skuHistoricCostIGC != null ? skuHistoricCostIGC.ASI_CRM_Cost__c : contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_case__c;
            contractTarget.ASI_CRM_Duty_Per_Bottle__c = skuHistoricCostDuty != null ? skuHistoricCostDuty.ASI_CRM_Cost__c : 0;
            contractTarget.ASI_CRM_FOB_Per_Bottle__c = skuHistoricCostFob != null ? skuHistoricCostFob.ASI_CRM_Cost__c : 0;
            contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c = skuHistoricCostHandlingCost != null ? skuHistoricCostHandlingCost.ASI_CRM_Cost__c : 0;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c = skuHistoricCostIGC != null ? skuHistoricCostIGC.ASI_CRM_SG_IGC_Cost_Per_9Lc__c : contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_9Lc__c;
			/* [VL 2.0] BEGIN */
            contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c = skuIncentivePrice != null ? skuIncentivePrice.ASI_CRM_Price__c : 0;
			
			contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c != null ? contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c : 0;
            contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c = contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c != null ? contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c : 0;
            contractTarget.ASI_CRM_Duty_Per_Bottle__c = contractTarget.ASI_CRM_Duty_Per_Bottle__c != null ? contractTarget.ASI_CRM_Duty_Per_Bottle__c : 0;
            contractTarget.ASI_CRM_FOB_Per_Bottle__c = contractTarget.ASI_CRM_FOB_Per_Bottle__c != null ? contractTarget.ASI_CRM_FOB_Per_Bottle__c : 0;
            contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c = contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c != null ? contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c : 0;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c = contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c != null ? contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c : 0;
			contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c = contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c != null ? contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c : 0;
			
			if (!contractTarget.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c){
				/* [VL 4.0] BEGIN */
				/*
				contractTarget.ASI_CRM_SG_Wholesaler_Margin__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c - contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
				*/
				contractTarget.ASI_CRM_Wholesaler_Margin_RTM__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c - contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
				/* [VL 4.0] END */
				/*[WL 5.0] BEGIN*/
				/*if (contractTarget.ASI_CRM_Entitle_Back_Rebates__c && contractTarget.ASI_CRM_TargetCase__c >= contractTarget.ASI_CRM_Minimum_Sales_Cases__c){
					contractTarget.ASI_CRM_Bottle_Incentive__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c - contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c;
				} else {
					contractTarget.ASI_CRM_Entitle_Back_Rebates__c = false;
					contractTarget.ASI_CRM_Bottle_Incentive__c = 0;
				}*/
				if (contractTarget.ASI_CRM_Entitle_Back_Rebates__c){
					if (!contractTarget.ASI_CRM_Back_Rebates_Adjusted__c)
						contractTarget.ASI_CRM_Bottle_Incentive__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c - contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c;
				}
				/*[WL 5.0] END*/
			}
			/* [VL 2.0] END */
			/* [VL 3.0] BEGIN */
            contractTarget.ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c = skuRTMwsPrice != null ? skuRTMwsPrice.ASI_CRM_Price__c : null;
            contractTarget.ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c = skuRTMotPrice != null ? skuRTMotPrice.ASI_CRM_Price__c : null;
			/* [VL 3.0] END */
        
        } else {

            contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c;
            contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c = contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_case__c;
            contractTarget.ASI_CRM_Duty_Per_Bottle__c = 0;
            contractTarget.ASI_CRM_FOB_Per_Bottle__c = 0;
            contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c = 0;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c = contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_9Lc__c;
			/* [VL 2.0] BEGIN */
            contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c = 0;
			
			contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c != null ? contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c : 0;
            contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c = contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c != null ? contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c : 0;
            contractTarget.ASI_CRM_Duty_Per_Bottle__c = contractTarget.ASI_CRM_Duty_Per_Bottle__c != null ? contractTarget.ASI_CRM_Duty_Per_Bottle__c : 0;
            contractTarget.ASI_CRM_FOB_Per_Bottle__c = contractTarget.ASI_CRM_FOB_Per_Bottle__c != null ? contractTarget.ASI_CRM_FOB_Per_Bottle__c : 0;
            contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c = contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c != null ? contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c : 0;
            contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c = contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c != null ? contractTarget.ASI_CRM_SG_IGC_Cost_Per_9Lc__c : 0;
			contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c = contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c != null ? contractTarget.ASI_CRM_Incentive_Price_Per_Bottle__c : 0;
			
			if (!contractTarget.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c){
				contractTarget.ASI_CRM_SG_Wholesaler_Margin__c = 0;
				contractTarget.ASI_CRM_Bottle_Incentive__c = 0;
			}
			/* [VL 2.0] END */
			/* [VL 3.0] BEGIN */
            contractTarget.ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c = null;
            contractTarget.ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c = null;
			/* [VL 3.0] END */

        }

    }

}