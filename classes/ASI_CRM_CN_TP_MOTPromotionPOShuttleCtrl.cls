/* Filename:    ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl.cls
* Author:       jason
* Purpose:      Controller for MOT Promotion PO Shuttle pdf in Po page
* Reference :    ASI_CRM_CN_TP_MOTPromotionPOShuttleComp.component
* History 
*/
public without sharing class ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl {
  public String poId {get;set;}
  public String pageStyle{get{if(String.isBlank(pageStyle)){pageStyle='pdf';}return pageStyle;}set;}
  public PoWrapper poWrapper_Global{get;set;}
  // a dummy variable to invoke init() method
  public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

  public Boolean init(){
    poWrapper_Global = new PoWrapper();
    Set<Id> brsfLineItemIdSet_PoV0 = new Set<Id>();
    Set<Id> brsfLineItemIdSet_NoPoV0 = new Set<Id>();
    Set<Id> pRLineItemIdSet = new Set<Id>();
    List<AggregateResult> brsfResult_PoV0 = new List<AggregateResult>();
    List<AggregateResult> brsfResult_NoPoV0 = new List<AggregateResult>();
    ASI_TH_CRM_Contract__c po = [SELECT id,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_PO_Version__c,
                                        ASI_CRM_New_FY_PO__c,ASI_CRM_CN_Outlet_WS__r.Name,
                                        ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_PO_Start_Date__c,
                                        ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Status__c,
                                        ASI_CRM_CN_Description__c,
                                                                (
                                                                  SELECT id,
                                                                          ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Promotion_Vol__c,
                                                                          ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Cont_Margin_Amount__c,
                                                                          ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Amount__c,
                                                                          ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Gross_Sales_Amount__c,
                                                                          ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_DM_Display_Amount__c,
                                                                          ASI_CRM_CN_TP_Budget_Plan__r.ASI_MFM_Budget_Amount__c,
                                                                          ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_Remaining_Amount__c
                                                                  FROM Plans__r 
                                                                  WHERE RecordType.DeveloperName like 'ASI_CRM_CN_TP_Trade_Plan%'
                                                                  LIMIT 1
                                                                ),
                                                                (
                                                                  SELECT id,ASI_CRM_CN_Sub_Brand__r.Name,
                                                                         ASI_CRM_CN_TP_Promotion_Cost__c,
                                                                         ASI_CRM_CN_TP_Fixed_Cost__c,
                                                                         ASI_CRM_CN_Total_Volume_9L__c,
                                                                         ASI_CRM_CN_GS_Per_9L__c,
                                                                         ASI_CRM_CN_TP_GS_Amount__c,
                                                                         ASI_CRM_CN_TP_GS_Percent__c,
                                                                         ASI_CRM_CN_TP_CM_Per_9L__c,
                                                                         ASI_CRM_CN_TP_CM_Amount__c
                                                                    FROM Contract_BRSF_Line_Item__r
                                                                    WHERE RecordType.DeveloperName = :ASI_CRM_CN_TP_Utils.PO_BRSF_RTNAME
                                                                )
                                  FROM ASI_TH_CRM_Contract__c 
                                  WHERE id=:poId
                                  AND RecordType.developerName =:ASI_CRM_CN_TP_Utils.CN_Contract
                                  LIMIT 1
                                ];
    List<ASI_TH_CRM_PaymentRequest__c> paymentRequestList = [SELECT id,
                                                                      (
                                                                        SELECT id 
                                                                        FROM ASI_TH_CRM_PRLI_PaymentRequest__r 
                                                                        WHERE ASI_CRM_CN_Expense_Type__c in (:ASI_CRM_CN_TP_Utils.PRICE_PROMOTION,:ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE)
                                                                        AND RecordType.developerName =:ASI_CRM_CN_TP_Utils.PAYMENT_DETAIL_OTHER_RTNAME
                                                                      )
                                                             FROM ASI_TH_CRM_PaymentRequest__c 
                                                             WHERE ASI_TH_CRM_Contract__r.id =:poId
                                                             AND RecordType.developerName = :ASI_CRM_CN_TP_Utils.PAYMENT_RTNAME
                                                            ];
    if(po!=null){
      poWrapper_Global.po = po;
      if(po.Plans__r!=null&&po.Plans__r.size()>0){
        poWrapper_Global.lyPromotionVol = nv(po.Plans__r[0].ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Promotion_Vol__c);
        poWrapper_Global.lYContMarginAmount = nv(po.Plans__r[0].ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Cont_Margin_Amount__c);
        poWrapper_Global.lYPricePromotion = -nv(po.Plans__r[0].ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Amount__c);
        poWrapper_Global.lYGrossSalesAmount = nv(po.Plans__r[0].ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_Gross_Sales_Amount__c);
        poWrapper_Global.lYDMDisplayAmount = -nv(po.Plans__r[0].ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_LY_DM_Display_Amount__c);
        poWrapper_Global.lYTradeExpenses = poWrapper_Global.lYPricePromotion+poWrapper_Global.lYDMDisplayAmount;
        if(poWrapper_Global.lYTradeExpenses==0||poWrapper_Global.lYGrossSalesAmount==0){
          poWrapper_Global.lYGrossSalesPercent = 0;
        }else{
          poWrapper_Global.lYGrossSalesPercent =(((-poWrapper_Global.lYTradeExpenses)/poWrapper_Global.lYGrossSalesAmount)*100).setScale(4,System.RoundingMode.HALF_UP);
        }
        if(poWrapper_Global.lYPricePromotion==0||poWrapper_Global.lYGrossSalesAmount==0){
          poWrapper_Global.lYGrossSalesExclDisplayPercent = 0;
        }else{
          poWrapper_Global.lYGrossSalesExclDisplayPercent =(((-poWrapper_Global.lYPricePromotion)/poWrapper_Global.lYGrossSalesAmount)*100).setScale(4,System.RoundingMode.HALF_UP);
        }
      }
      if(po.ASI_CRM_CN_PO_Version__c=='0.0'){
        if(po.Contract_BRSF_Line_Item__r!=null&&po.Contract_BRSF_Line_Item__r.size()>0){
          poWrapper_Global.bBRSLineItemList = new List<BRSFLineItemWrapper>();
          poWrapper_Global.bBRSLItemPoV0List = new List<BRSFLineItemPoV0Wrapper>();
          poWrapper_Global.primitivePCostTotal = 0;
          poWrapper_Global.primitiveGSTotal = 0;
          for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLItem:po.Contract_BRSF_Line_Item__r){
            BRSFLineItemWrapper brsfLineItemWrapper = new BRSFLineItemWrapper();
            BRSFLineItemPoV0Wrapper brsfLItemPoV0Wrapper = new BRSFLineItemPoV0Wrapper();
            brsfLineItemWrapper.subBrandName = brsfLItem.ASI_CRM_CN_Sub_Brand__r.Name;
            brsfLItemPoV0Wrapper.subBrandName = brsfLItem.ASI_CRM_CN_Sub_Brand__r.Name;
            brsfLineItemWrapper.primitiveVolumes = nv(brsfLItem.ASI_CRM_CN_Total_Volume_9L__c);
            brsfLItemPoV0Wrapper.primitivePromotionCost = nv(brsfLItem.ASI_CRM_CN_TP_Promotion_Cost__c);
            poWrapper_Global.primitivePCostTotal+=brsfLItemPoV0Wrapper.primitivePromotionCost;
            brsfLItemPoV0Wrapper.primitiveGSAmount = nv(brsfLItem.ASI_CRM_CN_TP_GS_Amount__c);
            poWrapper_Global.primitiveGSTotal+=brsfLItemPoV0Wrapper.primitiveGSAmount;
            if(brsfLItemPoV0Wrapper.primitivePromotionCost==0||brsfLItemPoV0Wrapper.primitiveGSAmount==0){
              brsfLItemPoV0Wrapper.primitivePcVsGs = 0;
            }else{
              brsfLItemPoV0Wrapper.primitivePcVsGs = (brsfLItemPoV0Wrapper.primitivePromotionCost/brsfLItemPoV0Wrapper.primitiveGSAmount).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            brsfLineItemIdSet_PoV0.add(brsfLItem.id);
            poWrapper_Global.bBRSLineItemList.add(brsfLineItemWrapper);
            poWrapper_Global.bBRSLItemPoV0List.add(brsfLItemPoV0Wrapper);
          }
          brsfResult_PoV0 = getAccumulationData(brsfLineItemIdSet_PoV0);
          if(brsfResult_PoV0.size()>0){
            poWrapper_Global.primitiveVolumesTotal = nv(brsfResult_PoV0[0].get('tVolume'));
            poWrapper_Global.primitiveCMAmountTotal = nv(brsfResult_PoV0[0].get('cmAmount'));
            poWrapper_Global.primitiveGSAmountTotal = nv(brsfResult_PoV0[0].get('gsAmount'));
            poWrapper_Global = getAccumulationContractCost(poWrapper_Global,po.id,'PrimitiveV');
            poWrapper_Global.primitiveTradeExpensesTotal = nv(poWrapper_Global.primitiveFixedCostTotal)+nv(poWrapper_Global.primitivePricePromotionTotal);
            if(judgeParamIsNormal(poWrapper_Global.primitiveTradeExpensesTotal,poWrapper_Global.primitiveGSAmountTotal)){
              poWrapper_Global.primitiveGSPercentTotal = 0;
            }else{
              poWrapper_Global.primitiveGSPercentTotal = ((-poWrapper_Global.primitiveTradeExpensesTotal)/poWrapper_Global.primitiveGSAmountTotal).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            if(judgeParamIsNormal(poWrapper_Global.primitivePricePromotionTotal,poWrapper_Global.primitiveGSAmountTotal)){
              poWrapper_Global.primitiveGSPTExclDisplay = 0;
            }else{
              poWrapper_Global.primitiveGSPTExclDisplay = ((-poWrapper_Global.primitivePricePromotionTotal)/poWrapper_Global.primitiveGSAmountTotal).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            if(judgeParamIsNormal(poWrapper_Global.lyPromotionVol,poWrapper_Global.primitiveVolumesTotal)){
              poWrapper_Global.pVolPercentByLy_Vs_V =0;
            }else{
              poWrapper_Global.pVolPercentByLy_Vs_V = ((poWrapper_Global.lyPromotionVol/poWrapper_Global.primitiveVolumesTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            if(judgeParamIsNormal(poWrapper_Global.lYTradeExpenses,poWrapper_Global.primitiveTradeExpensesTotal)){
              poWrapper_Global.tradeExpensesByLy_Vs_V = 0;
            }else{
              poWrapper_Global.tradeExpensesByLy_Vs_V = ((poWrapper_Global.lYTradeExpenses/poWrapper_Global.primitiveTradeExpensesTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            if(judgeParamIsNormal(poWrapper_Global.lYContMarginAmount,poWrapper_Global.primitiveCMAmountTotal)){
              poWrapper_Global.cMAmountTotalByLy_Vs_V = 0;
            }else{
              poWrapper_Global.cMAmountTotalByLy_Vs_V = ((poWrapper_Global.lYContMarginAmount/poWrapper_Global.primitiveCMAmountTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            if(judgeParamIsNormal(poWrapper_Global.lYPricePromotion,poWrapper_Global.primitivePricePromotionTotal)){
              poWrapper_Global.pricePromotionTotalByLy_Vs_V = 0;
            }else{
              poWrapper_Global.pricePromotionTotalByLy_Vs_V = ((poWrapper_Global.lYPricePromotion/poWrapper_Global.primitivePricePromotionTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            if(judgeParamIsNormal(poWrapper_Global.lYGrossSalesAmount,poWrapper_Global.primitiveGSAmountTotal)){
              poWrapper_Global.gSAmountTotalByLy_Vs_V = 0;
            }else{
              poWrapper_Global.gSAmountTotalByLy_Vs_V = ((poWrapper_Global.lYGrossSalesAmount/poWrapper_Global.primitiveGSAmountTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            if(judgeParamIsNormal(poWrapper_Global.lYDMDisplayAmount,poWrapper_Global.primitiveFixedCostTotal)){
              poWrapper_Global.fixedCostTotalByLy_Vs_V = 0;
            }else{
              poWrapper_Global.fixedCostTotalByLy_Vs_V = ((poWrapper_Global.lYDMDisplayAmount/poWrapper_Global.primitiveFixedCostTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            poWrapper_Global.gSPercentTotalByLy_Vs_V = nv(poWrapper_Global.primitiveGSPercentTotal)-nv(poWrapper_Global.lYGrossSalesPercent);
            poWrapper_Global.gSExclDispalyPercentTotalByLy_Vs_V = nv(poWrapper_Global.primitiveGSPTExclDisplay)-nv(poWrapper_Global.lYGrossSalesExclDisplayPercent);
          }
        }
      }else if(po.ASI_CRM_CN_PO_Version__c!='0.0'){
        ASI_TH_CRM_Contract__c poV0 = [SELECT id FROM ASI_TH_CRM_Contract__c 
                                       WHERE RecordType.developerName =:ASI_CRM_CN_TP_Utils.CN_Contract
                                       AND ASI_CRM_CN_PO_No__c =:po.ASI_CRM_CN_PO_No__c
                                       AND ASI_CRM_CN_PO_Version__c='0.0'
                                       LIMIT 1
                                      ];
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> cBRSFLItemList = [SELECT id,ASI_CRM_CN_Sub_Brand__r.Name,
                                                                          ASI_CRM_CN_TP_Promotion_Cost__c,
                                                                          ASI_CRM_CN_TP_Fixed_Cost__c,
                                                                          ASI_CRM_CN_Total_Volume_9L__c,
                                                                          ASI_CRM_CN_GS_Per_9L__c,
                                                                          ASI_CRM_CN_TP_GS_Amount__c,
                                                                          ASI_CRM_CN_TP_GS_Percent__c,
                                                                          ASI_CRM_CN_TP_CM_Per_9L__c,
                                                                          ASI_CRM_CN_TP_CM_Amount__c
                                                                      FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                      WHERE ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_No__c =:po.ASI_CRM_CN_PO_No__c
                                                                      AND ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c='0.0'
                                                                      AND RecordType.DeveloperName = :ASI_CRM_CN_TP_Utils.PO_BRSF_RTNAME
                                                                    ];
        Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfLItemMap_V0= new Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c>(cBRSFLItemList);
        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfLItemMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        brsfResult_PoV0 = getAccumulationData(brsfLItemMap_V0.keyset());
        poWrapper_Global.bBRSLineItemList = new List<BRSFLineItemWrapper>();
        poWrapper_Global.bBRSLItemPoV0List = new List<BRSFLineItemPoV0Wrapper>();
        poWrapper_Global.primitivePCostTotal = 0;
        poWrapper_Global.primitiveGSTotal = 0;
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLineItem:cBRSFLItemList){
          brsfLItemMap.put(brsfLineItem.ASI_CRM_CN_Sub_Brand__r.Name,brsfLineItem);
        }
        if(po.Contract_BRSF_Line_Item__r!=null&&po.Contract_BRSF_Line_Item__r.size()>0){
          for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLItem:po.Contract_BRSF_Line_Item__r){
            BRSFLineItemPoV0Wrapper brsfLItemPoV0Wrapper = new BRSFLineItemPoV0Wrapper();
            brsfLItemPoV0Wrapper.subBrandName = brsfLItem.ASI_CRM_CN_Sub_Brand__r.Name;
            brsfLItemPoV0Wrapper.primitivePromotionCost = nv(brsfLItem.ASI_CRM_CN_TP_Promotion_Cost__c);
            poWrapper_Global.primitivePCostTotal+=brsfLItemPoV0Wrapper.primitivePromotionCost;
            brsfLItemPoV0Wrapper.primitiveGSAmount = nv(brsfLItem.ASI_CRM_CN_TP_GS_Amount__c);
            poWrapper_Global.primitiveGSTotal+=brsfLItemPoV0Wrapper.primitiveGSAmount;
            if(judgeParamIsNormal(brsfLItemPoV0Wrapper.primitivePromotionCost,brsfLItemPoV0Wrapper.primitiveGSAmount)){
              brsfLItemPoV0Wrapper.primitivePcVsGs = 0;
            }else{
              brsfLItemPoV0Wrapper.primitivePcVsGs = (brsfLItemPoV0Wrapper.primitivePromotionCost/brsfLItemPoV0Wrapper.primitiveGSAmount).setScale(4,System.RoundingMode.HALF_UP)*100;
            }
            poWrapper_Global.bBRSLItemPoV0List.add(brsfLItemPoV0Wrapper);

            BRSFLineItemWrapper brsfLineItemWrapper = new BRSFLineItemWrapper();
            brsfLineItemWrapper.subBrandName = brsfLItem.ASI_CRM_CN_Sub_Brand__r.Name;
            brsfLineItemWrapper.latestVolumes = nv(brsfLItem.ASI_CRM_CN_Total_Volume_9L__c);
            if(brsfLItemMap.containskey(brsfLItem.ASI_CRM_CN_Sub_Brand__r.Name)){
              brsfLineItemWrapper.primitiveVolumes = nv(brsfLItemMap.get(brsfLItem.ASI_CRM_CN_Sub_Brand__r.Name).ASI_CRM_CN_Total_Volume_9L__c);
              if(judgeParamIsNormal(brsfLineItemWrapper.latestVolumes,brsfLineItemWrapper.primitiveVolumes)){
                brsfLineItemWrapper.volumePercentByV_Vs_V0 = 0;
              }else{
                brsfLineItemWrapper.volumePercentByV_Vs_V0 = ((brsfLineItemWrapper.latestVolumes/brsfLineItemWrapper.primitiveVolumes)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
              }
            }
            brsfLineItemIdSet_NoPoV0.add(brsfLItem.id);
            poWrapper_Global.bBRSLineItemList.add(brsfLineItemWrapper);
          }
        }
        if(brsfResult_PoV0.size()>0){
          poWrapper_Global.primitiveVolumesTotal = nv(brsfResult_PoV0[0].get('tVolume'));
          poWrapper_Global.primitiveCMAmountTotal = nv(brsfResult_PoV0[0].get('cmAmount'));
          poWrapper_Global.primitiveGSAmountTotal = nv(brsfResult_PoV0[0].get('gsAmount'));
          poWrapper_Global = getAccumulationContractCost(poWrapper_Global,poV0.id,'PrimitiveV');
          poWrapper_Global.primitiveTradeExpensesTotal = nv(poWrapper_Global.primitiveFixedCostTotal)+nv(poWrapper_Global.primitivePricePromotionTotal);
          if(judgeParamIsNormal(poWrapper_Global.primitiveTradeExpensesTotal,poWrapper_Global.primitiveGSAmountTotal)){
            poWrapper_Global.primitiveGSPercentTotal = 0;
          }else{
            poWrapper_Global.primitiveGSPercentTotal = (-poWrapper_Global.primitiveTradeExpensesTotal/poWrapper_Global.primitiveGSAmountTotal).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.primitivePricePromotionTotal,poWrapper_Global.primitiveGSAmountTotal)){
            poWrapper_Global.primitiveGSPTExclDisplay = 0;
          }else{
            poWrapper_Global.primitiveGSPTExclDisplay = (-poWrapper_Global.primitivePricePromotionTotal/poWrapper_Global.primitiveGSAmountTotal).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
        }
        brsfResult_NoPoV0 = getAccumulationData(brsfLineItemIdSet_NoPoV0);
        if(brsfResult_NoPoV0.size()>0){
          poWrapper_Global.latestVolumesTotal = nv(brsfResult_NoPoV0[0].get('tVolume'));
          poWrapper_Global.latestCMAmountTotal = nv(brsfResult_NoPoV0[0].get('cmAmount'));
          poWrapper_Global.latestGSAmountTotal = nv(brsfResult_NoPoV0[0].get('gsAmount'));
          poWrapper_Global = getAccumulationContractCost(poWrapper_Global,po.id,'LatestV');
          poWrapper_Global.latestTradeExpensesTotal = nv(poWrapper_Global.latestFixedCostTotal)+nv(poWrapper_Global.latestPricePromotionTotal);
          if(judgeParamIsNormal(poWrapper_Global.latestTradeExpensesTotal,poWrapper_Global.latestGSAmountTotal)){
            poWrapper_Global.latestGSPercentTotal = 0;
          }else{
            poWrapper_Global.latestGSPercentTotal = (-poWrapper_Global.latestTradeExpensesTotal/poWrapper_Global.latestGSAmountTotal).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.latestPricePromotionTotal,poWrapper_Global.latestGSAmountTotal)){
            poWrapper_Global.latestGSExclDisplayPercentTotal = 0;
          }else{
            poWrapper_Global.latestGSExclDisplayPercentTotal = (-poWrapper_Global.latestPricePromotionTotal/poWrapper_Global.latestGSAmountTotal).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.lyPromotionVol,poWrapper_Global.latestVolumesTotal)){
            poWrapper_Global.pVolPercentByLy_Vs_V =0;
          }else{
            poWrapper_Global.pVolPercentByLy_Vs_V = ((poWrapper_Global.lyPromotionVol/poWrapper_Global.latestVolumesTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.lYTradeExpenses,poWrapper_Global.latestTradeExpensesTotal)){
            poWrapper_Global.tradeExpensesByLy_Vs_V = 0;
          }else{
            poWrapper_Global.tradeExpensesByLy_Vs_V = ((poWrapper_Global.lYTradeExpenses/poWrapper_Global.latestTradeExpensesTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.lYContMarginAmount,poWrapper_Global.latestCMAmountTotal)){
            poWrapper_Global.cMAmountTotalByLy_Vs_V = 0;
          }else{
            poWrapper_Global.cMAmountTotalByLy_Vs_V = ((poWrapper_Global.lYContMarginAmount/poWrapper_Global.latestCMAmountTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.lYPricePromotion,poWrapper_Global.latestPricePromotionTotal)){
            poWrapper_Global.pricePromotionTotalByLy_Vs_V = 0;
          }else{
            poWrapper_Global.pricePromotionTotalByLy_Vs_V = ((poWrapper_Global.lYPricePromotion/poWrapper_Global.latestPricePromotionTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.lYGrossSalesAmount,poWrapper_Global.latestGSAmountTotal)){
            poWrapper_Global.gSAmountTotalByLy_Vs_V = 0;
          }else{
            poWrapper_Global.gSAmountTotalByLy_Vs_V = ((poWrapper_Global.lYGrossSalesAmount/poWrapper_Global.latestGSAmountTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          if(judgeParamIsNormal(poWrapper_Global.lYDMDisplayAmount,poWrapper_Global.latestFixedCostTotal)){
            poWrapper_Global.fixedCostTotalByLy_Vs_V = 0;
          }else{
            poWrapper_Global.fixedCostTotalByLy_Vs_V = ((poWrapper_Global.lYDMDisplayAmount/poWrapper_Global.latestFixedCostTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
          }
          poWrapper_Global.gSPercentTotalByLy_Vs_V = nv(poWrapper_Global.latestGSPercentTotal)-nv(poWrapper_Global.lYGrossSalesPercent);
          poWrapper_Global.gSExclDispalyPercentTotalByLy_Vs_V = nv(poWrapper_Global.latestGSExclDisplayPercentTotal)-nv(poWrapper_Global.lYGrossSalesExclDisplayPercent);
        }
        if(judgeParamIsNormal(poWrapper_Global.latestVolumesTotal,poWrapper_Global.primitiveVolumesTotal)){
          poWrapper_Global.pVolumeByV_Vs_V0 = 0;
        }else{
          poWrapper_Global.pVolumeByV_Vs_V0 = ((poWrapper_Global.latestVolumesTotal/poWrapper_Global.primitiveVolumesTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
        }
        if(judgeParamIsNormal(poWrapper_Global.latestTradeExpensesTotal,poWrapper_Global.primitiveTradeExpensesTotal)){
          poWrapper_Global.tradeExpensesByV0VsV = 0;
        }else{
          poWrapper_Global.tradeExpensesByV0VsV = ((poWrapper_Global.latestTradeExpensesTotal/poWrapper_Global.primitiveTradeExpensesTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
        }
        if(judgeParamIsNormal(poWrapper_Global.latestCMAmountTotal,poWrapper_Global.primitiveCMAmountTotal)){
          poWrapper_Global.cMAmountByV0VsV = 0;
        }else{
          poWrapper_Global.cMAmountByV0VsV = ((poWrapper_Global.latestCMAmountTotal/poWrapper_Global.primitiveCMAmountTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
        }
        if(judgeParamIsNormal(poWrapper_Global.latestGSAmountTotal,poWrapper_Global.primitiveGSAmountTotal)){
          poWrapper_Global.gSAmountByV0VsV = 0;
        }else{
          poWrapper_Global.gSAmountByV0VsV = ((poWrapper_Global.latestGSAmountTotal/poWrapper_Global.primitiveGSAmountTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
        }
        if(judgeParamIsNormal(poWrapper_Global.latestGSPercentTotal,poWrapper_Global.primitiveGSPercentTotal)){
          poWrapper_Global.gSPercentByV0VsV = 0;
        }else{
          poWrapper_Global.gSPercentByV0VsV = (poWrapper_Global.latestGSPercentTotal-poWrapper_Global.primitiveGSPercentTotal).setScale(4,System.RoundingMode.HALF_UP);
        }
        if(judgeParamIsNormal(poWrapper_Global.latestGSExclDisplayPercentTotal,poWrapper_Global.primitiveGSPTExclDisplay)){
          poWrapper_Global.gSExclDisplayPercentByV0VsV = 0;
        }else{
          poWrapper_Global.gSExclDisplayPercentByV0VsV = (poWrapper_Global.latestGSExclDisplayPercentTotal-poWrapper_Global.primitiveGSPTExclDisplay).setScale(4,System.RoundingMode.HALF_UP);
        }
        if(judgeParamIsNormal(poWrapper_Global.latestPricePromotionTotal,poWrapper_Global.primitivePricePromotionTotal)){
          poWrapper_Global.pricePromotionByV0VsV = 0;
        }else{
          poWrapper_Global.pricePromotionByV0VsV = ((poWrapper_Global.latestPricePromotionTotal/poWrapper_Global.primitivePricePromotionTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
        }
        if(judgeParamIsNormal(poWrapper_Global.latestFixedCostTotal,poWrapper_Global.primitiveFixedCostTotal)){
          poWrapper_Global.fixedCostByV0VsV = 0;
        }else{
          poWrapper_Global.fixedCostByV0VsV = ((poWrapper_Global.latestFixedCostTotal/poWrapper_Global.primitiveFixedCostTotal)-1).setScale(4,System.RoundingMode.HALF_UP)*100;
        }
      }
    }
    for(ASI_TH_CRM_PaymentRequest__c paymentRequest:paymentRequestList){
      if(paymentRequest.ASI_TH_CRM_PRLI_PaymentRequest__r!=null&&paymentRequest.ASI_TH_CRM_PRLI_PaymentRequest__r.size()>0){
        for(ASI_TH_CRM_PaymentRequestLineItem__c pRLItem:paymentRequest.ASI_TH_CRM_PRLI_PaymentRequest__r){
          pRLineItemIdSet.add(pRLItem.id);
        }
      }
    }
    if(getAccumulationByPRLItem(pRLineItemIdSet).size()>0){
      for(AggregateResult result:getAccumulationByPRLItem(pRLineItemIdSet)){
        String expenseType = (String)result.get('expenseType');
        Decimal amount = nv((Decimal)result.get('amount'));
        if(expenseType==ASI_CRM_CN_TP_Utils.PRICE_PROMOTION){
          poWrapper_Global.OutletPromotion_Pay = amount;
        }else if(expenseType==ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE){
          poWrapper_Global.PosterSFPromotion_Pay = amount;
        }
      }
    }else{
      poWrapper_Global.OutletPromotion_Pay = 0;
      poWrapper_Global.PosterSFPromotion_Pay = 0;
    }
    if(Decimal.valueof(po.ASI_CRM_CN_PO_Version__c)>0.1){
      String poVersion= String.valueOf(Decimal.valueof(po.ASI_CRM_CN_PO_Version__c)-0.1).subString(0,3);
      ASI_TH_CRM_Contract__c poPreVersion = [SELECT id FROM ASI_TH_CRM_Contract__c 
                                             WHERE RecordType.developerName =:ASI_CRM_CN_TP_Utils.CN_Contract
                                             AND ASI_CRM_CN_PO_No__c =:po.ASI_CRM_CN_PO_No__c
                                             AND ASI_CRM_CN_PO_Version__c=:poVersion
                                             LIMIT 1
                                            ];
      poWrapper_Global = getAccumulationContractCost(poWrapper_Global,poPreVersion.id,'PreviousV');
    }else{
      poWrapper_Global.PreviousPPromotionTotal = nv(poWrapper_Global.primitivePricePromotionTotal);
      poWrapper_Global.PreviousfCostTotal = nv(poWrapper_Global.primitiveFixedCostTotal);
    }
    return true;
  }
  private Decimal nv(Object obj){
    return obj==null?0:(Decimal)obj;
  }
  private List<AggregateResult> getAccumulationData(Set<Id> brsfIdSet){
    List<AggregateResult> brsfResult = [SELECT SUM(ASI_CRM_CN_TP_Promotion_Cost__c) pCost,SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fCost,
                                               SUM(ASI_CRM_CN_Total_Volume_9L__c) tVolume,SUM(ASI_CRM_CN_GS_Per_9L__c) gsPer,
                                               SUM(ASI_CRM_CN_TP_GS_Amount__c) gsAmount,SUM(ASI_CRM_CN_TP_CM_Amount__c) cmAmount,
                                               SUM(ASI_CRM_CN_TP_GS_Percent__c) gsPercent
                                        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                        WHERE id in:brsfIdSet
                                        AND RecordType.DeveloperName =:ASI_CRM_CN_TP_Utils.PO_BRSF_RTNAME
                                       ];
    return brsfResult==null?new List<AggregateResult>():brsfResult;
  }
  private List<AggregateResult> getAccumulationByPRLItem(Set<Id> pRLItemId){
    List<AggregateResult> pRLItemList = [SELECT SUM(ASI_CRM_CN_TP_Amount__c) amount,
                                                ASI_CRM_CN_Expense_Type__c expenseType
                                         FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                         WHERE id in:pRLItemId
                                         AND RecordType.developerName =:ASI_CRM_CN_TP_Utils.PAYMENT_DETAIL_OTHER_RTNAME
                                         GROUP BY ASI_CRM_CN_Expense_Type__c
                                        ];
    return pRLItemList==null?new List<AggregateResult>():pRLItemList;
  }
  private PoWrapper getAccumulationContractCost(PoWrapper poWrapper_Global,Id PoId,String valueType){
    List<AggregateResult> contractCostList = [SELECT SUM(ASI_CRM_CN_Estimate_Amount__c) estimateAmountTotal,ASI_CRM_CN_Chinese_Description__c chineseDesc
                                              FROM ASI_CRM_Contract_Cost__c 
                                              WHERE ASI_CRM_CN_Contract__c = : PoId
                                              AND ASI_CRM_CN_Cost_Type__c in ('Fixed','Variable')
                                              AND ASI_CRM_CN_Chinese_Description__c in (:ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE,:ASI_CRM_CN_TP_Utils.PRICE_PROMOTION)
                                              AND RecordType.developerName =:ASI_CRM_CN_TP_Utils.CN_Contract_Cost
                                              GROUP BY ASI_CRM_CN_Chinese_Description__c
                                             ];
    if(contractCostList.size()>0){
      for(AggregateResult cCost:contractCostList){
        String chineseDesc = (String)cCost.get('chineseDesc');
        Decimal estimateAmountTotal = (Decimal)cCost.get('estimateAmountTotal');
        if(valueType=='PrimitiveV'){
          if(chineseDesc==ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE){
            poWrapper_Global.primitiveFixedCostTotal = -nv(estimateAmountTotal);
          }else if(chineseDesc==ASI_CRM_CN_TP_Utils.PRICE_PROMOTION){
            poWrapper_Global.primitivePricePromotionTotal = -nv(estimateAmountTotal);
          }
        }else if(valueType=='LatestV'){
          if(chineseDesc==ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE){
            poWrapper_Global.latestFixedCostTotal = -nv(estimateAmountTotal);
          }else if(chineseDesc==ASI_CRM_CN_TP_Utils.PRICE_PROMOTION){
            poWrapper_Global.latestPricePromotionTotal = -nv(estimateAmountTotal);
          }
        }else if(valueType=='PreviousV'){
          if(chineseDesc==ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE){
            poWrapper_Global.PreviousfCostTotal = -nv(estimateAmountTotal);
          }else if(chineseDesc==ASI_CRM_CN_TP_Utils.PRICE_PROMOTION){
            poWrapper_Global.PreviousPPromotionTotal = -nv(estimateAmountTotal);
          }
        }
      }
    }
    return poWrapper_Global;
  }
  private Boolean judgeParamIsNormal(Decimal molecular,Decimal denominator){
    if(nv(molecular)==0||nv(denominator)==0){
      return true;
    }else{
      return false;
    }
  }
  class PoWrapper{
    public Decimal latestVolumesTotal{get;set;}
    public Decimal primitiveVolumesTotal{get;set;}
    public Decimal latestTradeExpensesTotal{get;set;}
    public Decimal primitiveTradeExpensesTotal{get;set;}
    public Decimal latestCMAmountTotal{get;set;}
    public Decimal primitiveCMAmountTotal{get;set;}
    public Decimal latestGSAmountTotal{get;set;}
    public Decimal primitiveGSAmountTotal{get;set;}
    public Decimal latestGSPercentTotal{get;set;}
    public Decimal latestGSExclDisplayPercentTotal{get;set;}
    public Decimal primitiveGSPercentTotal{get;set;}
    public Decimal primitiveGSPTExclDisplay{get;set;}
    public Decimal latestFixedCostTotal{get;set;}
    public Decimal primitiveFixedCostTotal{get;set;}
    public Decimal latestPricePromotionTotal{get;set;}
    public Decimal primitivePricePromotionTotal{get;set;}
    
    public Decimal OutletPromotion_Pay{get;set;}
    public Decimal PosterSFPromotion_Pay{get;set;}

    public Decimal lyPromotionVol{get;set;}
    public Decimal lYContMarginAmount{get;set;}
    public Decimal lYPricePromotion{get;set;}
    public Decimal lYTradeExpenses{get;set;}
    public Decimal lYGrossSalesPercent{get;set;}
    public Decimal lYGrossSalesExclDisplayPercent{get;set;}
    public Decimal lYGrossSalesAmount{get;set;}
    public Decimal lYDMDisplayAmount{get;set;}

    public Decimal pVolumeByV_Vs_V0{get;set;}
    public Decimal tradeExpensesByV0VsV{get;set;}
    public Decimal cMAmountByV0VsV{get;set;}
    public Decimal gSAmountByV0VsV{get;set;}
    public Decimal gSPercentByV0VsV{get;set;}
    public Decimal gSExclDisplayPercentByV0VsV{get;set;}
    public Decimal pricePromotionByV0VsV{get;set;}
    public Decimal fixedCostByV0VsV{get;set;}

    public Decimal pVolPercentByLy_Vs_V{get;set;}
    public Decimal tradeExpensesByLy_Vs_V{get;set;}
    public Decimal cMAmountTotalByLy_Vs_V{get;set;}
    public Decimal pricePromotionTotalByLy_Vs_V{get;set;}
    public Decimal gSAmountTotalByLy_Vs_V{get;set;}
    public Decimal fixedCostTotalByLy_Vs_V{get;set;}
    public Decimal gSPercentTotalByLy_Vs_V{get;set;}
    public Decimal gSExclDispalyPercentTotalByLy_Vs_V{get;set;}

    public Decimal primitivePCostTotal{get;set;}
    public Decimal primitiveGSTotal{get;set;}

    public Decimal PreviousPPromotionTotal{get;set;}
    public Decimal PreviousfCostTotal{get;set;}

    public List<BRSFLineItemWrapper> bBRSLineItemList{get;set;}
    public List<BRSFLineItemPoV0Wrapper> bBRSLItemPoV0List{get;set;}
    public ASI_TH_CRM_Contract__c po{get;set;}
  }
  class BRSFLineItemWrapper{
    public String subBrandName{get;set;}
    public Decimal latestVolumes{get;set;}
    public Decimal primitiveVolumes{get;set;}
    public Decimal volumePercentByV_Vs_V0{get;set;}
  }
  class BRSFLineItemPoV0Wrapper{
    public String subBrandName{get;set;}
    public Decimal primitivePromotionCost{get;set;}
    public Decimal primitiveGSAmount{get;set;}
    public Decimal primitivePcVsGs{get;set;}
  }
}