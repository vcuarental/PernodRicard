/*********************************************************************************
 * Name: ASI_CRM_PH_ContractTarget_TriggerClass
 * Description: Trigger Class for Contract Target for SG 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-05       Laputa: Vincent         Created
 */
public without sharing class ASI_CRM_PH_ContractTarget_TriggerClass{

	private final static String RTID_OUTLETSELLINGPRICE = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price');
    private final static String RTID_LISTPRICE = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price');
    private final static String RTID_DUTY = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Duty_Excise_Tax');
    private final static String RTID_HANDLING = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_SKU_Handling_Cost');
    private final static String RTID_COGS = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_COGS');
    private final static String RTID_STANDARD = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Standard_Cost');
    private final static String RTID_DISTRIBUTION = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_DP_Distribution_Cost');

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
		set<string> set_contractId = new set<string>();
        for(ASI_CRM_ContractTarget__c c : trigger_new){
            skuIDSet.add(c.ASI_CRM_SKU__c);
			set_contractId.add(c.ASI_CRM_Contract__c);
					
            c.ASI_CRM_TargetCase__c = c.ASI_CRM_Target_Total_Bottle__c;
            c.ASI_CRM_SG_Btls_Per_Case__c = 1;
        }
		
         if (skuIDSet.size() > 0){
			map<id, ASI_TH_CRM_Contract__c> map_contract = new map<id, ASI_TH_CRM_Contract__c>([select id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where id in :set_contractId]);
        
            //Calculate Standard Cost
            Set<ID> skuCostIDSet = new Set<ID>();
            skuCostIDSet.add(RTID_OUTLETSELLINGPRICE);
            skuCostIDSet.add(RTID_LISTPRICE);
            skuCostIDSet.add(RTID_DUTY);
            skuCostIDSet.add(RTID_HANDLING);
            skuCostIDSet.add(RTID_COGS);
            skuCostIDSet.add(RTID_STANDARD);
			skuCostIDSet.add(RTID_DISTRIBUTION);
            
            List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = [select id, ASI_CRM_Cost__c, ASI_CRM_Price__c, ASI_CRM_EffectiveDate__c, ASI_CRM_SKU__c, ASI_CRM_Customer__c, recordTypeID from ASI_CRM_MY_SKUPriceCost__c 
                    where ASI_CRM_SKU__c = :skuIDSet and recordTypeID = :skuCostIDSet order by ASI_CRM_SKU__c, ASI_CRM_EffectiveDate__c desc];
            
            Map<string,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUOutletSelling = new Map<string,List<ASI_CRM_MY_SKUPriceCost__c>>();
            Map<string,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUJDESelling = new Map<string,List<ASI_CRM_MY_SKUPriceCost__c>>();
            Map<string,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUDuty = new Map<string,List<ASI_CRM_MY_SKUPriceCost__c>>();
            Map<string,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUHandling = new Map<string,List<ASI_CRM_MY_SKUPriceCost__c>>();
            Map<string,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUCOGS = new Map<string,List<ASI_CRM_MY_SKUPriceCost__c>>();
            Map<string,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUStandard = new Map<string,List<ASI_CRM_MY_SKUPriceCost__c>>();
            Map<string,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUDistribution = new Map<string,List<ASI_CRM_MY_SKUPriceCost__c>>();
            
            for (ASI_CRM_MY_SKUPriceCost__c cost:skuPriceList){
                if (cost.recordTypeID == RTID_OUTLETSELLINGPRICE){
                    if (mapSKUOutletSelling.containsKey(cost.ASI_CRM_SKU__c+'_'+cost.ASI_CRM_Customer__c))
                        mapSKUOutletSelling.get(cost.ASI_CRM_SKU__c+'_'+cost.ASI_CRM_Customer__c).add(cost);
                    else 
                        mapSKUOutletSelling.put(cost.ASI_CRM_SKU__c+'_'+cost.ASI_CRM_Customer__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                } else
                if (cost.recordTypeID == RTID_LISTPRICE){
                    if (mapSKUJDESelling.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUJDESelling.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUJDESelling.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                } else
                if (cost.recordTypeID == RTID_DUTY){
                    if (mapSKUDuty.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUDuty.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUDuty.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                } else
                if (cost.recordTypeID == RTID_HANDLING){
                    if (mapSKUHandling.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUHandling.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUHandling.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                } else
                if (cost.recordTypeID == RTID_COGS){
                    if (mapSKUCOGS.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUCOGS.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUCOGS.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                } else
                if (cost.recordTypeID == RTID_STANDARD){
                    if (mapSKUStandard.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUStandard.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUStandard.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                } else
                if (cost.recordTypeID == RTID_DISTRIBUTION){
                    if (mapSKUDistribution.containsKey(cost.ASI_CRM_SKU__c))
                        mapSKUDistribution.get(cost.ASI_CRM_SKU__c).add(cost);
                    else 
                        mapSKUDistribution.put(cost.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{cost});
                }
            }
			
            
            for(ASI_CRM_ContractTarget__c c : trigger_new){
                
                //Match SKU for Standard Cost or FOB Cost
                ASI_CRM_MY_SKUPriceCost__c lastMatchedOutletSelling;
                ASI_CRM_MY_SKUPriceCost__c lastMatchedJDESelling;
                ASI_CRM_MY_SKUPriceCost__c lastMatchedDuty;
                ASI_CRM_MY_SKUPriceCost__c lastMatchedHandling;
                ASI_CRM_MY_SKUPriceCost__c lastMatchedCOGS;
                ASI_CRM_MY_SKUPriceCost__c lastMatchedStandard;
                ASI_CRM_MY_SKUPriceCost__c lastMatchedDistribution;
                
                if (mapSKUOutletSelling.get(c.ASI_CRM_SKU__c+'_'+map_contract.get(c.ASI_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUOutletSelling.get(c.ASI_CRM_SKU__c+'_'+map_contract.get(c.ASI_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c)){
						
                        if ((lastMatchedOutletSelling == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedOutletSelling != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedOutletSelling.ASI_CRM_EffectiveDate__c)){
                            lastMatchedOutletSelling = cost;
                        }
                    }
                    
                    if (lastMatchedOutletSelling != null){
                        c.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = lastMatchedOutletSelling.ASI_CRM_Price__c;
					}
                } 
                if (mapSKUJDESelling.get(c.ASI_CRM_SKU__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUJDESelling.get(c.ASI_CRM_SKU__c)){
						
                        if ((lastMatchedJDESelling == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedJDESelling != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedJDESelling.ASI_CRM_EffectiveDate__c)){
                            lastMatchedJDESelling = cost;
                        }
                    }
                    
                    if (lastMatchedJDESelling != null){
                        c.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = lastMatchedJDESelling.ASI_CRM_Price__c;
					}
                }
                if (mapSKUDuty.get(c.ASI_CRM_SKU__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUDuty.get(c.ASI_CRM_SKU__c)){
						
                        if ((lastMatchedDuty == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedDuty != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedDuty.ASI_CRM_EffectiveDate__c)){
                            lastMatchedDuty = cost;
                        }
                    }
                    
                    if (lastMatchedDuty != null){
                        c.ASI_CRM_Duty_Per_Bottle__c = lastMatchedDuty.ASI_CRM_Cost__c;
					}
                }
                if (mapSKUHandling.get(c.ASI_CRM_SKU__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUHandling.get(c.ASI_CRM_SKU__c)){
						
                        if ((lastMatchedHandling == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedHandling != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedHandling.ASI_CRM_EffectiveDate__c)){
                            lastMatchedHandling = cost;
                        }
                    }
                    
                    if (lastMatchedHandling != null){
                        c.ASI_CRM_Handling_Cost_Per_Bottle__c = lastMatchedHandling.ASI_CRM_Cost__c;
					}
                }
                if (mapSKUCOGS.get(c.ASI_CRM_SKU__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUCOGS.get(c.ASI_CRM_SKU__c)){
						
                        if ((lastMatchedCOGS == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedCOGS != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedCOGS.ASI_CRM_EffectiveDate__c)){
                            lastMatchedCOGS = cost;
                        }
                    }
                    
                    if (lastMatchedCOGS != null){
                        c.ASI_CRM_IGC__c = lastMatchedCOGS.ASI_CRM_Cost__c;
					}
                }
                if (mapSKUStandard.get(c.ASI_CRM_SKU__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUStandard.get(c.ASI_CRM_SKU__c)){
						
                        if ((lastMatchedStandard == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedStandard != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedStandard.ASI_CRM_EffectiveDate__c)){
                            lastMatchedStandard = cost;
                        }
                    }
                    
                    if (lastMatchedStandard != null){
                        c.ASI_CRM_Standard_Cost_per_Bottle__c = lastMatchedStandard.ASI_CRM_Cost__c;
					}
                }
                if (mapSKUDistribution.get(c.ASI_CRM_SKU__c) != null){
                    //Use Standard Cost if SKU has Standard Cost defined
                    for (ASI_CRM_MY_SKUPriceCost__c cost:mapSKUDistribution.get(c.ASI_CRM_SKU__c)){
						
                        if ((lastMatchedDistribution == null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c) || (lastMatchedDistribution != null && c.ASI_CRM_Contract_Start_Date__c >= cost.ASI_CRM_EffectiveDate__c && cost.ASI_CRM_EffectiveDate__c > lastMatchedDistribution.ASI_CRM_EffectiveDate__c)){
                            lastMatchedDistribution = cost;
                        }
                    }
                    
                    if (lastMatchedDistribution != null){
                        c.ASI_CRM_DistributionCostperBottleAmount__c = lastMatchedDistribution.ASI_CRM_Cost__c;
					}
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
		  SUM(ASI_CRM_Wholesaler_Margin_Total_RTM__c) totalMarginSumRTM,
            SUM(ASI_CRM_SG_Total_Free_Goods_9L_Cases__c) totalFreeGoods9LSum, 
            SUM(ASI_CRM_SG_Total_Free_Goods_Cases__c) totalFreeGoodsCaseSum, 
            SUM(ASI_CRM_SG_Target_Sales_9L_Cases__c) totalSales9LSum, SUM(ASI_CRM_SG_TradeAPTotalFOCWSOntradeSP__c) totalTradeAPOnTradeSum,
            SUM(ASI_CRM_SG_Trade_A_P_Total_PRS__c) totalTradeAPPRS,
            SUM(ASI_CRM_SG_TotalInvestmentValueforPRS__c) totalInvestment,
            AVG(ASI_CRM_SG_ROI__c) AvgROI
            , SUM(ASI_CRM_SG_Cash__c) totalCashSponsorSum_cashOnly   
            , SUM(ASI_CRM_Sales_Revenue_Target__c) totalGrossSales 
            , SUM(ASI_CRM_SG_Free_Goods__c) totalFreeGoodsValue  
			, SUM(ASI_CRM_Total_Bottle_Rebate__c) totalBottleRebate
			, SUM(ASI_CRM_Total_Staff_Incentive__c) totalStaffIncentive
			, SUM(ASI_CRM_Sales_Revenue_Target_Outlet__c) totalSalesRevenueTargetOutlet
            FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c IN: ContractIdSet
            AND recordtype.developername = 'ASI_CRM_PH_Contract_Target'
            GROUP BY ASI_CRM_Contract__c
      ];
            
        for(AggregateResult result : resultAggregateList){
            
            ASI_TH_CRM_Contract__c tempContract = new ASI_TH_CRM_Contract__c(id = (ID)result.get('ASI_CRM_Contract__c'));
            tempContract.ASI_CRM_SG_Net_Sales__c = (Decimal)result.get('netSalesSum');
            tempContract.ASI_CRM_SG_Return_on_Investment__c = (Decimal)result.get('ROISum');
            tempContract.ASI_CRM_SG_TotalCashGoodsinkindSponsor__c = (Decimal)result.get('totalCashGoodsSum');
            tempContract.ASI_CRM_SG_Total_Cash_Sponsorship__c = (Decimal)result.get('totalCashSponsorSum');
            tempContract.ASI_CRM_SG_Total_Free_Goods_9L_Cases__c = (Decimal)result.get('totalFreeGoods9LSum');
            tempContract.ASI_CRM_SG_Total_Free_Goods_Cases__c = (Decimal)result.get('totalFreeGoodsCaseSum');
            tempContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c = (Decimal)result.get('totalSales9LSum');
            tempContract.ASI_CRM_SG_TotalTradeAPFOCWSOntradeSP__c = (Decimal)result.get('totalTradeAPOnTradeSum');
            tempContract.ASI_CRM_SG_Total_Trade_A_P_PRS__c = (Decimal)result.get('totalTradeAPPRS');
            tempContract.ASI_CRM_SG_TotalInvestment_Value_for_PRS__c = (Decimal)result.get('totalInvestment');  
            tempContract.ASI_CRM_ROI__c = ((Decimal)result.get('netSalesSum') == 0 || (Decimal)result.get('netSalesSum') == null || (Decimal)result.get('ROISum') == null) ? 0 : ((Decimal)result.get('ROISum')/(Decimal)result.get('netSalesSum')*100);
            tempContract.ASI_CRM_Total_Cash_Sponsorship_Cash__c = (Decimal)result.get('totalCashSponsorSum_cashOnly');     
            tempContract.ASI_CRM_Sales_Revenue_Target__c = (Decimal)result.get('totalGrossSales');  
            //tempContract.ASI_CRM_Total_Free_Goods_Value__c = -(Decimal)result.get('totalFreeGoodsValue');     
            tempContract.ASI_CRM_Bottle_Rebate_Amount__c = (Decimal)result.get('totalBottleRebate');     
            tempContract.ASI_CRM_Staff_Incentive_Amount__c = (Decimal)result.get('totalStaffIncentive');     
            tempContract.ASI_CRM_Sales_Revenue_Target_Outlet__c = (Decimal)result.get('totalSalesRevenueTargetOutlet');   
                
            updateContractList.add(tempContract);   
			system.debug(tempContract.ASI_CRM_Bottle_Rebate_Amount__c);
			system.debug(tempContract.ASI_CRM_Staff_Incentive_Amount__c);
            tempContractIDSet.remove(tempContract.id);
        }
        if(updateContractList.size()>0){
            update updateContractList;
        }
        
        updateContractList = new List<ASI_TH_CRM_Contract__c>();
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
            tempContract.ASI_CRM_Total_Cash_Sponsorship_Cash__c = null;  
            tempContract.ASI_CRM_Sales_Revenue_Target__c = null; 
            tempContract.ASI_CRM_Total_Free_Goods_Value__c = null;  
            tempContract.ASI_CRM_Bottle_Rebate_Amount__c = null;  
            tempContract.ASI_CRM_Staff_Incentive_Amount__c = null;  
            tempContract.ASI_CRM_Sales_Revenue_Target_Outlet__c = null;  
            
            
             updateContractList.add(tempContract); 
            }
        }
        
        if(updateContractList.size()>0){
            update updateContractList;
        }
    }
}