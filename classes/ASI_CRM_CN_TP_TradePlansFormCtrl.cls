/* Filename:    ASI_CRM_CN_TP_TradePlansFormCtrl.cls
* Author:       Alex
* Purpose:      Controller for trade plans pdf in Po or Payment page
* Reference :    ASI_CRM_CN_TP_TradePlansFormComp.component
* History 
*/
public without sharing class ASI_CRM_CN_TP_TradePlansFormCtrl {
    public String poId {set;get;}
    public String paymentId {set;get;}
    public String tradePlanId{get;set;}
    public String distinguishPageFlag{get;set;}
    public String pageStyle{get{if(String.isBlank(pageStyle)){pageStyle='pdf';}return pageStyle;}set;}
    public String characterStr{get{if(String.isBlank(characterStr)){
      characterStr = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }return characterStr;}set;}
    public ASI_TH_CRM_Contract__c po{get;set;}
    public ASI_TH_CRM_PaymentRequest__c payment{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> planLineItemList{get;set;}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> pRLineItemList{get;set;}
    public TradePlanLineWrapper tPLineWrapper{get;set;}
    // a dummy variable to invoke init() method
   	public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Decimal estAmountLimit {get; set;}
    public String tpRemarks {get; set;}
    public String poRemarks {get; set;}
    public ASI_CRM_CN_TP_TradePlansFormCtrl() {
    }
    public boolean init(){
      pRLineItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
      planLineItemList = new List<ASI_MFM_Plan_Line_Item__c>();
      estAmountLimit = Decimal.valueOf(Label.ASI_CRM_CN_TP_Estimate_Amount_Limit);
      if(distinguishPageFlag=='0'){
        if(String.isNotBlank(poId)){
          poRemarks = '';
          po = [SELECT id,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_PO_Version__c,
                      ASI_CRM_New_FY_PO__c,ASI_CRM_CN_Outlet_WS__r.Name,
                      ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_PO_Start_Date__c,
                      ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Status__c,
                      ASI_CRM_CN_Description__c,
                      (SELECT Id, ASI_CRM_CN_TP_Approval__c, ASI_CRM_CN_TP_Approval__r.ASI_MFM_Remarks__c 
                        FROM Plans__r 
                        WHERE RecordType.DeveloperName like 'ASI_CRM_CN_TP_Trade_Plan%')
                FROM ASI_TH_CRM_Contract__c 
                WHERE id=:poId
              ];
          if(po!=null){
            Map<Id, String> tpRemarksMap = new Map<Id, String>();
            Set<String> tradePlanIdSet = new Set<String>();
            if(po.Plans__r.size()>0){
              for(ASI_MFM_Plan__c plan:po.Plans__r){
                tradePlanIdSet.add(plan.id);
                if (!tpRemarksMap.containsKey(plan.ASI_CRM_CN_TP_Approval__c)) {
                    poRemarks = poRemarks + plan?.ASI_CRM_CN_TP_Approval__r?.ASI_MFM_Remarks__c +  '。' ;
                    tpRemarksMap.put(plan.ASI_CRM_CN_TP_Approval__c, plan?.ASI_CRM_CN_TP_Approval__r?.ASI_MFM_Remarks__c);
                } 
              }
              poRemarks = lineBreakUtil(150,poRemarks);
              System.debug(LoggingLevel.INFO, '*** poRemarks: ' + poRemarks);
            }
            planLineItemList = getPrLineItemList('',tradePlanIdSet);
            Set<String> pLItemSet = new Set<String>();
            for(ASI_MFM_Plan_Line_Item__c pLItem:planLineItemList){
              pLItemSet.add(pLItem.id);
            }
            List<AggregateResult> resultList = getDataAccumulationByPLItem(pLItemSet);
            tPLineWrapper = new TradePlanLineWrapper(planLineItemList,null,resultList,null);
          } 
        }else if(String.isNotBlank(paymentId)){
          payment = [SELECT id,Name,ASI_CRM_CN_Payment_Raised_Date__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_No__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Version__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c,
                            ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Description__c,
                            ASI_CRM_CN_Payment_Type__c,ASI_CRM_CN_Approval_Status__c,
                            ASI_CRM_CN_Description__c,
                            (
                              SELECT id,
                                    ASI_CRM_CN_TP_Plan_Line_Item__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Total_Fee_Percent__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.Name,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Activity_NO__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_End_Date__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Outlet_Count__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Bottle_Size__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Retail_Price__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Promotion_Unit_Price__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Promotion_Mode__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Promotion_Content__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Normal_Purchase_Price__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Promotion_Purchase_Price__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Subsidies__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Actual_Qty__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Estimated_Amount__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Plan_Fee_Percent__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Fixed_Cost__c,
                                    ASI_CRM_CN_TP_Promotion_Fee__c,
                                    ASI_CRM_CN_TP_Fixed_Cost__c,
                                    ASI_CRM_CN_Actual_Vol__c,
                                    ASI_CRM_CN_TP_Actual_Promotion_Percent__c,
                                    ASI_CRM_CN_TP_Actual_Total_Percent__c,
                                    ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Actual_Fee_Percent__c
                              FROM ASI_TH_CRM_PRLI_PaymentRequest__r
                              WHERE (ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Estimated_Amount__c>0 OR ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Fixed_Cost__c>0)
                              AND RecordType.DeveloperName like 'ASI_CRM_CN_TP_Payment_Request_Detail_TradePlan%'
                            )
                    FROM ASI_TH_CRM_PaymentRequest__c 
                    WHERE id=:paymentId
                    AND RecordType.developerName =:ASI_CRM_CN_TP_Utils.PAYMENT_RTNAME
                    ];
          if(payment!=null){
            if(payment.ASI_TH_CRM_PRLI_PaymentRequest__r!=null&&payment.ASI_TH_CRM_PRLI_PaymentRequest__r.size()>0){
              pRLineItemList.addAll(payment.ASI_TH_CRM_PRLI_PaymentRequest__r);
            }
          }
          Set<String> pLItemSet = new Set<String>();
          Set<String> pRItemSet = new Set<String>();
          for(ASI_TH_CRM_PaymentRequestLineItem__c rLItem:pRLineItemList){
            pLItemSet.add(rLItem.ASI_CRM_CN_TP_Plan_Line_Item__c);
            pRItemSet.add(rLItem.id);
          }
          tPLineWrapper = new TradePlanLineWrapper(null,pRLineItemList,getDataAccumulationByPLItem(pLItemSet),getDataAccumulationByPaymenRLItem(pRItemSet));
        }
      }else if(distinguishPageFlag=='1'){
        if(String.isNotBlank(tradePlanId)){
          ASI_MFM_Plan__c tradeplanInstance = [SELECT id,RecordType.DeveloperName,
                                                      ASI_MFM_Remarks__c,
                                                      (
                                                        SELECT id 
                                                        FROM Approval_Plans__r
                                                        WHERE RecordType.DeveloperName like 'ASI_CRM_CN_TP_Trade_Plan%'
                                                      )
                                                FROM ASI_MFM_Plan__c
                                                WHERE id=:tradePlanId
                                              ];
          if(tradeplanInstance!=null){
            if(tradeplanInstance.RecordType.DeveloperName.contains('ASI_CRM_CN_TP_Approval')){
              tpRemarks = lineBreakUtil(150,tradeplanInstance.ASI_MFM_Remarks__c);
              if(tradeplanInstance.Approval_Plans__r!=null&&tradeplanInstance.Approval_Plans__r.size()>0){
                Set<String> tradePlanIdSet = new Set<String>();
                for(ASI_MFM_Plan__c tradePlan:tradeplanInstance.Approval_Plans__r){
                  tradePlanIdSet.add(tradePlan.id);
                }
                planLineItemList = getPrLineItemList('',tradePlanIdSet);
                
              }
            }else if(tradeplanInstance.RecordType.DeveloperName.contains('ASI_CRM_CN_TP_Trade_Plan')){
                planLineItemList = getPrLineItemList(tradePlanId,null);
                System.debug(' planLineItemList '+planLineItemList.size());
            }
          }
          Set<String> pLItemSet = new Set<String>();
          for(ASI_MFM_Plan_Line_Item__c pLItem:planLineItemList){
            pLItemSet.add(pLItem.id);
          }
          tPLineWrapper = new TradePlanLineWrapper(planLineItemList,null,getDataAccumulationByPLItem(pLItemSet),null);
        }
      }
      return true;
    }
    private List<ASI_MFM_Plan_Line_Item__c> getPrLineItemList(String tradePlanId,Set<String> tradePlanIdSet){
      List<ASI_MFM_Plan_Line_Item__c> pLItemList = new List<ASI_MFM_Plan_Line_Item__c>();
      if(String.isNotBlank(tradePlanId)||tradePlanIdSet.size()>0){
        String sql = 'SELECT id,ASI_MFM_Plan__r.ASI_CRM_CN_TP_Activity_NO__c,ASI_MFM_Plan__c,'+
                          'ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,ASI_MFM_Plan__r.Name,'+
                          'ASI_MFM_Plan__r.ASI_MFM_End_Date__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Customer__r.Name,'+
                          'ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c,'+
                          'ASI_MFM_Plan__r.ASI_CRM_CN_TP_Outlet_Count__c,'+
                          'ASI_CRM_CN_TP_Approval_Step2_Rule1__c,'+
                          'ASI_CRM_CN_TP_Approval_Step2_Rule2__c,'+
                          'ASI_CRM_CN_TP_Approval_Step2_Rule3__c,'+
                          'ASI_MFM_Plan__r.ASI_MFM_Status__c,'+
                          'ASI_MFM_Plan__r.ASI_CRM_CN_TP_CRM_Code__c,'+
                          'ASI_MFM_Plan__r.ASI_CRM_CN_TP_KA_Banner__c,'+
                          'ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__r.ASI_CRM_Chinese_Name__c,'+
                          'ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region_P__c,'+
                          'ASI_MFM_Sub_brand_Code__r.Name,ASI_CRM_CN_TP_Bottle_Size__c,'+
                          'ASI_CRM_CN_TP_Retail_Price__c,ASI_CRM_CN_TP_Total_Fee_Percent__c,'+
                          'ASI_CRM_CN_TP_Promotion_Unit_Price__c,ASI_CRM_CN_TP_Promotion_Mode__c,'+
                          'ASI_CRM_CN_TP_Promotion_Content__c,ASI_CRM_CN_TP_Normal_Purchase_Price__c,'+
                          'ASI_CRM_CN_TP_Promotion_Purchase_Price__c,ASI_CRM_CN_TP_Subsidies__c,'+
                          'ASI_CRM_CN_TP_Estimated_Qty__c,ASI_CRM_CN_TP_Estimated_Amount__c,'+
                          'ASI_CRM_CN_TP_Plan_Fee_Percent__c,'+
                          'ASI_CRM_CN_TP_Benchmark__c,'+
                          'ASI_CRM_CN_TP_LPP_Price__c,'+
                          'ASI_CRM_CN_TP_Fixed_Cost__c'+
                  ' FROM ASI_MFM_Plan_Line_Item__c'+
                  ' WHERE (ASI_CRM_CN_TP_Estimated_Amount__c>0 OR ASI_CRM_CN_TP_Fixed_Cost__c>0)'+
                  ' AND RecordType.DeveloperName like \'ASI_CRM_CN_TP_Trade_Plan_Line_Item%\'';
        if(String.isNotBlank(tradePlanId)){
          sql+=' AND ASI_MFM_Plan__c =:tradePlanId';
        }else if(tradePlanIdSet.size()>0){
          sql+=' AND ASI_MFM_Plan__c in:tradePlanIdSet';
        }
        pLItemList = Database.query(sql);
        for (ASI_MFM_Plan_Line_Item__c planItem : pLItemList) {
            planItem.ASI_MFM_Plan__r.Name = lineBreakUtil(11, planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Customer__r.Name);
            planItem.ASI_MFM_Sub_brand_Code__r.Name = lineBreakUtil(11, planItem.ASI_MFM_Sub_brand_Code__r.Name);
            planItem.ASI_CRM_CN_TP_Promotion_Content__c = lineBreakUtil(11, planItem.ASI_CRM_CN_TP_Promotion_Content__c);
            String coverCity = planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c;
            
            if (coverCity == '总部' || String.isBlank(coverCity)) {
                planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_CRM_Code__c = lineBreakUtil(11,planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__r.ASI_CRM_Chinese_Name__c + '-全国');
            } else if (planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region_P__c == 'Non-Central Region') {
                planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_CRM_Code__c = lineBreakUtil(11, '非中区'  + '-' + coverCity);
            } else {
                planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_CRM_Code__c = lineBreakUtil(11, planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__r.ASI_CRM_Chinese_Name__c  + '-' + coverCity);
            }

            // planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c = (planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c == '总部' || String.isBlank(planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c))
            //                                                        ? lineBreakUtil(11,planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__r.ASI_CRM_Chinese_Name__c + '-全国')
            //                                                        :lineBreakUtil(11, planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__r.ASI_CRM_Chinese_Name__c  + '-' + planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c);
            planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_KA_Banner__c = lineBreakUtil(11, planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_KA_Banner__c);
            if (planItem.ASI_CRM_CN_TP_Promotion_Mode__c == 'intake price verification') {
                planItem.ASI_CRM_CN_TP_Promotion_Mode__c = '进价核销';
            } else if (planItem.ASI_CRM_CN_TP_Promotion_Mode__c == 'intake price verification tax included') {
                planItem.ASI_CRM_CN_TP_Promotion_Mode__c = '进价核销 (含税)';
            }
        }
      }
      return pLItemList;
    }

    // For line break
    public static String lineBreakUtil(Integer strIndex, String content) {
        if (String.isBlank(content)) return '';
        String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String newContent = '';
        Integer conLength = content.length();
        Integer countFlag = 0;
        Boolean isWrap = false;
        Integer indexFlag = 0;
        for (Integer i = 0; i< conLength; i++) {

            String str = content.substring(i, i+1);
            if (countFlag >= strIndex) {
                if (newContent.contains('\n')) {
                    newContent = newContent.substring(0, newContent.lastIndexOf('\n') + 1) + content.substring(indexFlag, i) + '\n';
                } else {
                    newContent = newContent + '\n';
                }
                countFlag = 0;
                isWrap = true;
                indexFlag = i;
            } else if (!isWrap){
                newContent = content.substring(0, i + 1);

            }
            if (chars.contains(str) && str != '') {
                countFlag ++;
            } else if (str != ''){
                countFlag += 2;
            } else if (str == ''){
                countFlag = 0;
            }
            if (i == conLength-1 && isWrap) {
                newContent = newContent + content.substring(indexFlag);
            }
        }
        return newContent;
    }

    private List<AggregateResult> getDataAccumulationByPLItem(Set<String> pLIIdSet){
      return [SELECT SUM(ASI_CRM_CN_TP_Estimated_Qty__c) estimatedQtyTotal,
                     SUM(ASI_CRM_CN_TP_Estimated_Amount__c) estimatedAmountTotal,
                     SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixedCostTotal,
                     SUM(ASI_CRM_CN_TP_Actual_Qty__c) actualQtyTotal
             FROM ASI_MFM_Plan_Line_Item__c
             WHERE id in:pLIIdSet
             AND (ASI_CRM_CN_TP_Estimated_Amount__c>0 OR ASI_CRM_CN_TP_Fixed_Cost__c>0)
             AND RecordType.DeveloperName like 'ASI_CRM_CN_TP_Trade_Plan_Line_Item%'
            ];
    }
    private List<AggregateResult> getDataAccumulationByPaymenRLItem(Set<String> pLIIdSet){
      return [SELECT SUM(ASI_CRM_CN_TP_Promotion_Fee__c) promotionFeeTotal,
                     SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixedCostTotal,
                     SUM(ASI_CRM_CN_Actual_Vol__c) actualVolTotal
              FROM ASI_TH_CRM_PaymentRequestLineItem__c
              WHERE id in:pLIIdSet
              AND (ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Estimated_Amount__c>0 OR ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Fixed_Cost__c>0)
              AND RecordType.DeveloperName like 'ASI_CRM_CN_TP_Payment_Request_Detail_TradePlan%'
             ];
    }
    class TradePlanLineWrapper{
      public List<ASI_MFM_Plan_Line_Item__c> planLineItemList{get;set;}
      public List<ASI_TH_CRM_PaymentRequestLineItem__c> pRLineItemList{get;set;}
      public Decimal fixedCostTotal{get;set;}
      public Decimal estimatedAmountTotal{get;set;}
      public Decimal estimatedQtyTotal{get;set;}
      public Decimal promotionFeeTotal{get;set;}
      public Decimal paymentfixedCostTotal{get;set;}
      public Decimal actualQtyTotal{get;set;}
      public Decimal actualVolTotal{get;set;}
      
      public TradePlanLineWrapper(List<ASI_MFM_Plan_Line_Item__c> pLIlist,List<ASI_TH_CRM_PaymentRequestLineItem__c> pRLIlist,List<AggregateResult> planResultList,List<AggregateResult> payResultList){
        this.planLineItemList = pLIlist;
        this.pRLineItemList = pRLIlist;
        if(planResultList!=null&&planResultList.size()>0){
          this.fixedCostTotal = (Decimal)planResultList[0].get('fixedCostTotal')==null?0:(Decimal)planResultList[0].get('fixedCostTotal');
          this.estimatedAmountTotal = (Decimal)planResultList[0].get('estimatedAmountTotal')==null?0:(Decimal)planResultList[0].get('estimatedAmountTotal');
          this.estimatedQtyTotal = (Decimal)planResultList[0].get('estimatedQtyTotal')==null?0:(Decimal)planResultList[0].get('estimatedQtyTotal');
          this.actualQtyTotal = (Decimal)planResultList[0].get('actualQtyTotal')==null?0:(Decimal)planResultList[0].get('actualQtyTotal');
        }else{
          this.fixedCostTotal = 0;
          this.estimatedAmountTotal = 0;
          this.estimatedQtyTotal = 0;
          this.actualQtyTotal = 0;
        }
        if(payResultList!=null&&payResultList.size()>0){
          this.promotionFeeTotal = (Decimal)payResultList[0].get('promotionFeeTotal')==null?0:(Decimal)payResultList[0].get('promotionFeeTotal');
          this.paymentfixedCostTotal = (Decimal)payResultList[0].get('fixedCostTotal')==null?0:(Decimal)payResultList[0].get('fixedCostTotal');
          this.actualVolTotal = (Decimal)payResultList[0].get('actualVolTotal')==null?0:(Decimal)payResultList[0].get('actualVolTotal');
        }else{
          this.promotionFeeTotal = 0;
          this.paymentfixedCostTotal = 0;
          this.actualVolTotal = 0;
        }
      }
    }
}