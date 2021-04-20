/*********************************************************************************
 * Name: ASI_CRM_SG_ContractTarget_TriggerClass
 * Description: Trigger Class for Contract Target for SG 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-11-21       Laputa                  Created
 * 2016-02-24       Laputa: Vincent Lam     [VL 1.0] Update contract header's field Total Cash Sponsorship (Cash)
 * 2016-04-19       Wilken Lee              [VL 1.1] Fill in Blind Bonus Rate and Standard Cost before upsert
 * 2016-05-06       Laputa: Vincent Lam     [VL 2.0] Update contract header's field Sales Revenue Target
 * 2016-05-19       Laputa: Vincent Lam     [VL 3.0] Update contract header's field Total Free Goods (Value)
 * 2016-05-26       Laputa: Vincent Lam     [VL 4.0] In total investment amount of PRS, minus total Marketing Support from contract
 * 2017-02-03       Wilken Lee 			    [WL 5.0] Fix blind bonus and SKU cost assignment logic
 * 2018-03-27       Laputa: Vincent         [VL 5.0] ICM117657570 : use new field to store RTM wholesaler margin
 */
public without sharing class ASI_CRM_SG_ContractTarget_TriggerClass{

    public static void routineAfterUpsert(List<ASI_CRM_ContractTarget__c> trigger_new, Map<Id, ASI_CRM_ContractTarget__c> trigger_oldMap){    
        Set<Id> ContractIdSet = new Set<Id>();
        for(ASI_CRM_ContractTarget__c c : trigger_new){
            ContractIdSet.add(c.ASI_CRM_Contract__c);
        }
        
        
        // In case contract targer re-parent
        if(trigger_oldMap != null){
            for(ASI_CRM_ContractTarget__c c : trigger_oldMap.values()){
                ContractIdSet.add(c.ASI_CRM_Contract__c);
            }
        }
        
        if(ContractIdSet.size()>0)
            updateContractSummary(ContractIdSet);

    }
    
    public static void routineBeforeUpsert(List<ASI_CRM_ContractTarget__c> trigger_new, Map<Id, ASI_CRM_ContractTarget__c> trigger_oldMap){    
        Set<id> skuIDSet = new Set<id>();
        Set<id> subBrandIDSet = new Set<id>();
        Map<id,id> skuSubBrandMap = new Map<id,id>();
        List<ASI_CRM_Blind_Bonus__c>  bbList = new List<ASI_CRM_Blind_Bonus__c>();
        
        for(ASI_CRM_ContractTarget__c c : trigger_new){
            skuIDSet.add(c.ASI_CRM_SKU__c);
        }
        
         if (skuIDSet.size() > 0){
            //Calculate Blind Bonus
            for (ASI_MFM_SKU_Code__c sku:[select id, ASI_MFM_Sub_brand__c from ASI_MFM_SKU_Code__c where id = :skuIDSet]){
                subBrandIDSet.add(sku.ASI_MFM_Sub_brand__c);
                skuSubBrandMap.put(sku.id, sku.ASI_MFM_Sub_brand__c);
            }
            
            if (subBrandIDSet.size() > 0){
                bbList = [select id, ASI_CRM_Blind_Bonus_Amount_Per_9L__c, ASI_CRM_Blind_Bonus_Amount_per_Case__c, ASI_CRM_Sub_brand__c, ASI_CRM_Effective_Date__c from ASI_CRM_Blind_Bonus__c 
                    where recordTypeID = :Global_RecordTypeCache.getRTId('ASI_CRM_Blind_Bonus__cASI_CRM_SG_Wholesaler') and ASI_CRM_Default_Est_Blind_Bonus_Amount__c = true and ASI_CRM_Sub_brand__c = :subBrandIDSet order by ASI_CRM_Sub_brand__c, ASI_CRM_Effective_Date__c desc];
                    
            }
            
            //Calculate Standard Cost
            Set<ID> skuCostIDSet = new Set<ID>();
            skuCostIDSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Standard_Cost_Per_Bottle'));
            skuCostIDSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle'));
            
            List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = [select id, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c, ASI_CRM_SKU__c, recordTypeID from ASI_CRM_MY_SKUPriceCost__c 
                    where ASI_CRM_SKU__c = :skuIDSet and recordTypeID = :skuCostIDSet order by ASI_CRM_SKU__c, ASI_CRM_EffectiveDate__c desc];
            
            Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUStandard = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
            Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUFOB = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
            
            
            for (ASI_CRM_MY_SKUPriceCost__c cost:skuPriceList){
                if (cost.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Standard_Cost_Per_Bottle')){
                    if (mapSKUStandard.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUStandard.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUStandard.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                }
                else if (cost.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle')){
                    if (mapSKUFOB.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUFOB.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUFOB.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                }
            }
            
            for(ASI_CRM_ContractTarget__c c : trigger_new){
                //Match SKU Sub-brand for Blind Bonus Rate
                ASI_CRM_Blind_Bonus__c lastMatchedBB;
                
                for (ASI_CRM_Blind_Bonus__c bb:bbList){
					//[WL 5.0] Fix blind bonus and SKU cost assignment logic
                    if ((lastMatchedBB == null && bb.ASI_CRM_Sub_brand__c == skuSubBrandMap.get(c.ASI_CRM_SKU__c) && c.ASI_CRM_Contract_Start_Date__c >= bb.ASI_CRM_Effective_Date__c) || (lastMatchedBB != null && bb.ASI_CRM_Sub_brand__c == skuSubBrandMap.get(c.ASI_CRM_SKU__c) && c.ASI_CRM_Contract_Start_Date__c >= bb.ASI_CRM_Effective_Date__c && bb.ASI_CRM_Effective_Date__c > lastMatchedBB.ASI_CRM_Effective_Date__c)){
                        lastMatchedBB = bb;
                    }
                }
                
                if (lastMatchedBB != null){
                    if (lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_Per_9L__c != null){
                        //Blind Bonus Amount per 9L case has been defined
                        c.ASI_CRM_Blind_Bonus_Amount__c = c.ASI_CRM_SG_Target_Sales_9L_Cases__c * lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_Per_9L__c;
                    }
                    else if (lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_per_Case__c != null){
                        //Blind Bonus Amount per case has been defined
                        c.ASI_CRM_Blind_Bonus_Amount__c = c.ASI_CRM_TargetCase__c * lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_per_Case__c;
                    }
                }
                
                //Match SKU for Standard Cost or FOB Cost
                ASI_CRM_MY_SKUPriceCost__c lastMatchedCost;
                
                if (mapSKUStandard.get(c.ASI_CRM_SKU__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUStandard.get(c.ASI_CRM_SKU__c)){
                        system.debug('evaludate each Standard Cost: Contract Target Eff Date: ' + c.ASI_CRM_Contract_Start_Date__c + ' cost eff date: ' + cost.ASI_CRM_EffectiveDate__c);
						
						//[WL 5.0] Fix blind bonus and SKU cost assignment logic
                        if ((lastMatchedCost == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedCost != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedCost.ASI_CRM_EffectiveDate__c)){
                            lastMatchedCost = cost;
                            system.debug('last matched Standard Cost: ' + cost);
                        }
                    }
                    
                    if (lastMatchedCost != null)
                        c.ASI_CRM_See_Through_Cost__c = lastMatchedCost.ASI_CRM_Cost__c;
                }
                else if (mapSKUFOB.get(c.ASI_CRM_SKU__c) != null){
                    //Alternatively use FOB Cost if SKU has no Standard Cost, but FOB Cost Defined
                     for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUFOB.get(c.ASI_CRM_SKU__c)){
                        system.debug('evaludate each Standard Cost: Contract Target Eff Date: ' + c.ASI_CRM_Contract_Start_Date__c + ' cost eff date: ' + cost.ASI_CRM_EffectiveDate__c);
						
						//[WL 5.0] Fix blind bonus and SKU cost assignment logic
                        if ((lastMatchedCost == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedCost != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedCost.ASI_CRM_EffectiveDate__c))
                            lastMatchedCost = cost;
                    }
                    
                    if (lastMatchedCost != null)
                        c.ASI_CRM_See_Through_Cost__c = lastMatchedCost.ASI_CRM_Cost__c;
                }
            }
        }
    }

    public static void routineAfterDelete(List<ASI_CRM_ContractTarget__c> trigger_old){    
        Set<Id> ContractIdSet = new Set<Id>();
        for(ASI_CRM_ContractTarget__c c : trigger_old){
            ContractIdSet.add(c.ASI_CRM_Contract__c);
        }
        if(ContractIdSet.size()>0)
            updateContractSummary(ContractIdSet);
    }
    
    private static void updateContractSummary(Set<Id> ContractIdSet){
        List<ASI_TH_CRM_Contract__c> updateContractList = new List<ASI_TH_CRM_Contract__c>();
        Set<ID> tempContractIDSet = ContractIdSet.clone();
        
        List<AggregateResult> resultAggregateList = [SELECT ASI_CRM_Contract__c, SUM(ASI_CRM_SG_Net_Sales__c) netSalesSum, 
            SUM(ASI_CRM_SG_Return_on_Investment__c) ROISum, SUM(ASI_CRM_SG_TotalCashGoodsinkindSponsor__c) totalCashGoodsSum,
            SUM(ASI_CRM_SG_Cash_Sponsorship_Total__c) totalCashSponsorSum, SUM(ASI_CRM_SG_Contract_Margin_Total__c) totalMarginSum,
			/* [VL 5.0] BEGIN */
			SUM(ASI_CRM_Wholesaler_Margin_Total_RTM__c) totalMarginSumRTM,
			ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c existBeforeRTM,
			/* [VL 5.0] BEGIN */
            SUM(ASI_CRM_SG_Total_Free_Goods_9L_Cases__c) totalFreeGoods9LSum, 
            SUM(ASI_CRM_SG_Total_Free_Goods_Cases__c) totalFreeGoodsCaseSum, 
            SUM(ASI_CRM_SG_Target_Sales_9L_Cases__c) totalSales9LSum, SUM(ASI_CRM_SG_TradeAPTotalFOCWSOntradeSP__c) totalTradeAPOnTradeSum,
            SUM(ASI_CRM_SG_Trade_A_P_Total_PRS__c) totalTradeAPPRS,
            SUM(ASI_CRM_SG_TotalInvestmentValueforPRS__c) totalInvestment,
            AVG(ASI_CRM_SG_ROI__c) AvgROI
            /* [VL 1.0] BEGIN */
            , SUM(ASI_CRM_SG_Cash__c) totalCashSponsorSum_cashOnly                                        
            /* [VL 1.0] END */
            /* [VL 2.0] BEGIN */
            , SUM(ASI_CRM_Sales_Revenue_Target__c) totalGrossSales                                        
            /* [VL 2.0] END */
            /* [VL 3.0] BEGIN */
            , SUM(ASI_CRM_SG_Free_Goods__c) totalFreeGoodsValue                                        
            /* [VL 3.0] END */
            FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c IN: ContractIdSet
            AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
            GROUP BY ASI_CRM_Contract__c
			/* [VL 5.0] BEGIN */
			, ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c
			/* [VL 5.0] BEGIN */
			];
            
        /* [VL 4.0] BEGIN */
        Map<id, ASI_TH_CRM_Contract__c> map_contract = new Map<id, ASI_TH_CRM_Contract__c>([select id, ASI_CRM_SG_Total_Marketing_A_P_Support__c 
            FROM ASI_TH_CRM_Contract__c
            WHERE id IN: ContractIdSet]); 
        /* [VL 4.0] END */
        
        for(AggregateResult result : 
            resultAggregateList){
            
            ASI_TH_CRM_Contract__c tempContract = new ASI_TH_CRM_Contract__c(id = (ID)result.get('ASI_CRM_Contract__c'));
            tempContract.ASI_CRM_SG_Net_Sales__c = (Decimal)result.get('netSalesSum');
            tempContract.ASI_CRM_SG_Return_on_Investment__c = (Decimal)result.get('ROISum');
            tempContract.ASI_CRM_SG_TotalCashGoodsinkindSponsor__c = (Decimal)result.get('totalCashGoodsSum');
            tempContract.ASI_CRM_SG_Total_Cash_Sponsorship__c = (Decimal)result.get('totalCashSponsorSum');
			/* [VL 5.0] BEGIN */
			/*
			tempContract.ASI_CRM_SG_Total_Contract_Margin__c = (Decimal)result.get('totalMarginSum');
			*/
			Boolean existBeforeRTM = Boolean.valueOf(result.get('existBeforeRTM'));
            tempContract.ASI_CRM_SG_Total_Contract_Margin__c = existBeforeRTM ? (Decimal)result.get('totalMarginSum') : (Decimal)result.get('totalMarginSumRTM');
			/* [VL 5.0] BEGIN */
            tempContract.ASI_CRM_SG_Total_Free_Goods_9L_Cases__c = (Decimal)result.get('totalFreeGoods9LSum');
            tempContract.ASI_CRM_SG_Total_Free_Goods_Cases__c = (Decimal)result.get('totalFreeGoodsCaseSum');
            tempContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c = (Decimal)result.get('totalSales9LSum');
            tempContract.ASI_CRM_SG_TotalTradeAPFOCWSOntradeSP__c = (Decimal)result.get('totalTradeAPOnTradeSum');
            tempContract.ASI_CRM_SG_Total_Trade_A_P_PRS__c = (Decimal)result.get('totalTradeAPPRS');
            /* [VL 4.0] BEGIN */
            /*
            tempContract.ASI_CRM_SG_TotalInvestment_Value_for_PRS__c = (Decimal)result.get('totalInvestment');
            */
            Decimal totalMarketingSupport = map_contract.get(tempContract.id).ASI_CRM_SG_Total_Marketing_A_P_Support__c != null ? map_contract.get(tempContract.id).ASI_CRM_SG_Total_Marketing_A_P_Support__c : 0;
            //tempContract.ASI_CRM_SG_TotalInvestment_Value_for_PRS__c = (Decimal)result.get('totalInvestment') + totalMarketingSupport;                                       
            tempContract.ASI_CRM_SG_TotalInvestment_Value_for_PRS__c = (Decimal)result.get('totalInvestment');                                       
            /* [VL 4.0] END */
            tempContract.ASI_CRM_ROI__c = ((Decimal)result.get('netSalesSum') == 0 || (Decimal)result.get('netSalesSum') == null || (Decimal)result.get('ROISum') == null) ? 0 : ((Decimal)result.get('ROISum')/(Decimal)result.get('netSalesSum')*100);
            /* [VL 1.0] BEGIN */
            tempContract.ASI_CRM_Total_Cash_Sponsorship_Cash__c = (Decimal)result.get('totalCashSponsorSum_cashOnly');                                        
            /* [VL 1.0] END */
            /* [VL 2.0] BEGIN */
            tempContract.ASI_CRM_Sales_Revenue_Target__c = (Decimal)result.get('totalGrossSales');                                        
            /* [VL 2.0] END */
            /* [VL 3.0] BEGIN */
            tempContract.ASI_CRM_Total_Free_Goods_Value__c = -(Decimal)result.get('totalFreeGoodsValue');                                       
            /* [VL 3.0] END */
                
            updateContractList.add(tempContract);   
            if(!Test.isRunningTest()) tempContractIDSet.remove(tempContract.id);
        }
        if(updateContractList.size()>0){
            update updateContractList;
        }
        
        
        //Base case Scenario
        if(tempContractIDSet.size() > 0) {
            for(ID contractID : tempContractIDSet) {
            ASI_TH_CRM_Contract__c tempContract = new ASI_TH_CRM_Contract__c(id = contractID);
            tempContract.ASI_CRM_SG_Net_Sales__c = null;
            tempContract.ASI_CRM_SG_Return_on_Investment__c = null;
            tempContract.ASI_CRM_SG_TotalCashGoodsinkindSponsor__c = null;
            tempContract.ASI_CRM_SG_Total_Cash_Sponsorship__c = null;
            tempContract.ASI_CRM_SG_Total_Contract_Margin__c = null;
            tempContract.ASI_CRM_SG_Total_Free_Goods_9L_Cases__c = null;
            tempContract.ASI_CRM_SG_Total_Free_Goods_Cases__c = null;
            tempContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c = null;
            tempContract.ASI_CRM_SG_TotalTradeAPFOCWSOntradeSP__c = null;
            tempContract.ASI_CRM_SG_Total_Trade_A_P_PRS__c = null;
            tempContract.ASI_CRM_SG_TotalInvestment_Value_for_PRS__c = null;
            tempContract.ASI_CRM_ROI__c = null;
            /* [VL 1.0] BEGIN */
            tempContract.ASI_CRM_Total_Cash_Sponsorship_Cash__c = null;                                        
            /* [VL 1.0] END */
            /* [VL 2.0] BEGIN */
            tempContract.ASI_CRM_Sales_Revenue_Target__c = null;                                        
            /* [VL 2.0] END */
            /* [VL 3.0] BEGIN */
            tempContract.ASI_CRM_Total_Free_Goods_Value__c = null;                                       
            /* [VL 3.0] END */
            
            
            if(!Test.isRunningTest()) updateContractList.add(tempContract); 
            }
        }
        
        if(updateContractList.size()>0){
            update updateContractList;
        }
    }
}