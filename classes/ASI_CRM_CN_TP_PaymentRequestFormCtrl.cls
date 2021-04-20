/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_PaymentRequestFormCtrl
 * Object: ASI_TH_CRM_PaymentRequest__c
 * Purpose: 
 * Author:  (Jack Yuan)
 * Create Date: 2020-04-07
 * Modify History:
 * 2020-04-07       Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_PaymentRequestFormCtrl {

    public String paymentId {set;get;}
    public String pageStyle{get{if(String.isBlank(pageStyle)){pageStyle='pdf';}return pageStyle;}set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_TH_CRM_PaymentRequest__c pmt {get; set;}
    public ASI_TH_CRM_Contract__c PO;
    public List<GrossSales> gsList {get; set;}
    public List<GrossSales> gsVolList {get; set;}
    public List<ASI_CRM_CN_PH_Payee_Line_Item__c> payeeList {get; set;}
    
    public List<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> paymentSummaryList {set; get;}{
        paymentSummaryList = new List<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();
    }
    public Decimal TotalPOEstAmt {set;get;}
    public Decimal TotalPORemainAmt {set;get;}
    public Decimal TotalRequestAmt {set;get;}

    public Decimal GSRatio {set; get;}
    public Decimal paymentSpeed {set; get;}
    public Decimal pmtPromotionSpeed {set; get;}

    public GrossSales totalCost {get; set;}
    public GrossSales totalCostRatio {get; set;}
    public GrossSales totalCM {get; set;}
    public GrossSales totalGS {get; set;}
    public GrossSales totalGSRatio {get; set;}
    public GrossSales totalPro {get; set;}
    public GrossSales totalFix {get; set;}


    public Boolean init() {
        System.debug(LoggingLevel.INFO, '*** init: ');
        pmt  = [SELECT ASI_CRM_CalOtherCostHistoricalPaidAmt__c,
                        ASI_CRM_CN_Adjustment__c,
                        ASI_CRM_CN_BRSF_End_Date__c,
                        ASI_CRM_CN_BRSF_Start_Date__c,
                        ASI_CRM_CN_Business_License_Qualify__c,
                        ASI_CRM_CN_Channel__c,
                        ASI_CRM_CN_Currency__c,
                        ASI_CRM_CN_Description__c,
                        ASI_CRM_CN_Division__c,
                        ASI_CRM_CN_Last_Payment__c,
                        ASI_CRM_CN_Last_Year_Payment__c,
                        ASI_CRM_CN_No_of_Month__c,
                        ASI_CRM_CN_Other_Reason__c,
                        ASI_CRM_CN_OutletWS__c,
                        ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_BRSF__c,
                        ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,
                        ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c,
                        ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                        ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,
                        ASI_CRM_CN_OutletWS__r.Name,
                        ASI_CRM_CN_Overpayment_Comment__c,
                        ASI_CRM_CN_Overpayment_Reason__c,
                        ASI_CRM_CN_Payable_Amount__c,
                        ASI_CRM_CN_Payment_Raised_Date__c,
                        ASI_CRM_CN_Payment_Type__c,
                        ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_PO_No__c,
                        ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_PO_Version__c,
                        ASI_CRM_CN_PO_Version_Latest__c,
                        ASI_CRM_CN_Promotion_Type__c,
                        ASI_CRM_CN_Reason_For_Business_License__c,
                        ASI_CRM_CN_Region__c,
                        ASI_CRM_CN_Reference_Code__c,
                        ASI_CRM_CN_Total_BRSF_Actual_Amount__c,
                        ASI_CRM_CN_Total_BRSF_Amount__c,
                        ASI_CRM_CN_Total_Other_Amount__c,
                        ASI_CRM_CN_Total_Payment__c,
                        ASI_CRM_CN_Total_PSF_Amount__c,
                        ASI_CRM_New_FY_Payment__c,
                        ASI_CRM_Total_Actual_Amount__c,
                        ASI_CRM_Total_Variable_Amount__c,
                        ASI_CRM_Volume_Option__c,
                        ASI_TH_CRM_Contract__c,
                        ASI_TH_CRM_Status__c,
                        ASI_TH_CRM_Total_Amount__c,
                        ASI_CRM_CN_Total_Free_Goods_Amount__c,
                        Name
                FROM ASI_TH_CRM_PaymentRequest__c
                WHERE Id = :paymentId];

        if (pmt != null) {
            PO = [SELECT ASI_TH_CRM_Contract_Status__c,
                        ASI_CRM_Auto_PO_Modification__c,
                        ASI_CRM_CN_Business_License__c,
                        ASI_CRM_CN_Currency__c,
                        ASI_CRM_CN_Data_Source__c,
                        ASI_CRM_CN_Description__c,
                        ASI_CRM_CN_Effective_Date__c,
                        ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                        ASI_CRM_CN_Expected_Display_Est_Total__c,
                        ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_CN_Festival_Season__c,
                        ASI_CRM_CN_Last_PO_version__c,
                        ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
                        ASI_CRM_CN_Last_Rejected_Date__c,
                        ASI_CRM_CN_Last_Submitted_Date__c,
                        ASI_CRM_CN_National_Group_Contract__c,
                        ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_Outlet_WS__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                        ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                        ASI_CRM_CN_PO_Modification__c,
                        ASI_CRM_CN_PO_No__c,
                        ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_PO_Version__c,
                        ASI_CRM_CN_Region__c,
                        ASI_CRM_CN_Source_of_Contract__c,
                        ASI_CRM_CN_Source_Others__c,
                        ASI_CRM_CN_Special_Promotion__c,
                        ASI_CRM_CN_Status__c,
                        ASI_CRM_CN_Total_Contract_Amount__c,
                        ASI_CRM_CN_V0_0_PO_version__c,
                        ASI_CRM_CN_Vol_Budget_LE__c,
                        ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                        ASI_CRM_Prev_Ver_Visibility_Est_Total__c,
                        ASI_CRM_New_FY_PO__c,
                        ASI_CRM_PO_Channel__c,
                        ASI_CRM_PO_City__c,
                        ASI_CRM_PO_City__r.Name,
                        ASI_CRM_PO_Province__c,
                        ASI_CRM_Volume_Option__c,
                        ASI_TH_CRM_Promotion_Type__c,
                        ASI_CRM_Copied_From__c,
                        ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                        CreatedDate,
                        Id,
                        LastModifiedDate,
                        Name,
                        RecordTypeId,
                        ASI_CRM_Reject_Return_Comments__c,
                        ASI_CRM_CN_Return_Comments__c,
                        ASI_CRM_CN_Last_Approved_By__c,
                        ASI_CRM_CN_Last_Approved_Date__c,
                        ASI_CRM_CN_Last_Recall_By__c,
                        ASI_CRM_CN_Last_Recall_Date__c,
                        ASI_CRM_CN_Last_Rejected_By__c,
                        ASI_CRM_CN_Last_Submitted_By__c,
                        ASI_CRM_Auto_PO_Modification_Time__c,
                        ASI_CRM_CN_PO_End_Date__c
                FROM ASI_TH_CRM_Contract__c
                WHERE Id = :pmt.ASI_TH_CRM_Contract__c];
        }
        paymentSummaryList = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(pmt,null);
        TotalPOEstAmt = 0.0;
        TotalPORemainAmt = 0.0;
        TotalRequestAmt = 0.0;
        for (Integer i = paymentSummaryList.size()-1; i >= 0; i --) {
            if (paymentSummaryList[i].feeChiName == ASI_CRM_CN_TP_Utils.PRICE_PROMOTION || paymentSummaryList[i].feeChiName == ASI_CRM_CN_TP_Utils.DM_SECONDARY_DISPLAY_FEE) {
                TotalPOEstAmt += paymentSummaryList[i].POEstimateAmt;
                TotalPORemainAmt += paymentSummaryList[i].PORemainAmt;
                TotalRequestAmt += paymentSummaryList[i].PaymentRequestAmount;
            } else {
                paymentSummaryList.remove(i);
            }

        }
       
        payeeList = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        payeeList = [SELECT ASI_CRM_CN_Payee_T1__r.Name, ASI_CRM_CN_Payee_T2__r.Name, ASI_CRM_CN_Type__c, ASI_CRM_CN_Amount__c 
                     FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                     WHERE ASI_CRM_CN_Payment_Request__c = :pmt.Id];
        // Promotion Cost / GS Ratio 
        calculateGSRatio();
        calculateLastPaymentSummary();
        return true;
    }

    // Price Promotion evaluation 
    public void calculateGSRatio() {
        
        List<AggregateResult> poBrsfResults = [SELECT ASI_CRM_CN_Sub_Brand__r.Name subName,
                                                      SUM(ASI_CRM_CN_TP_GS_Percent__c) gsRatio, SUM(ASI_CRM_CN_TP_GS_Amount__c) gsAmount,
                                                      SUM(ASI_CRM_CN_TP_Promotion_Cost__c) proCost, SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixedCost
                                                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                                WHERE ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_No__c = :PO.ASI_CRM_CN_PO_No__c
                                                AND ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c = '0.0'
                                                AND RecordType.DeveloperName = 'ASI_CRM_CN_Contract_TradePlan_BRSF_Line_Item'
                                                GROUP BY ASI_CRM_CN_Sub_Brand__r.Name];
        Map<String, AggregateResult> poResulMap = new Map<String, AggregateResult>();
        // Decimal totalPercent = 0.0;
        Decimal poTotalGSAmt = 0.0;
        Decimal poTotalProCost = 0.0;
        for (AggregateResult poResult : poBrsfResults) {
            String subkey = (String)poResult.get('subName');
            poResulMap.put(subkey, poResult);
            // totalPercent += (Decimal)poResult.get('gsRatio');
            poTotalGSAmt += poResult.get('gsAmount') == null ? 0.0 : (Decimal)poResult.get('gsAmount');
            poTotalProCost += poResult.get('proCost') == null ? 0.0 : (Decimal)poResult.get('proCost');
            poTotalProCost += poResult.get('fixedCost') == null ? 0.0 : (Decimal)poResult.get('fixedCost');
        }

        List<AggregateResult> pmtBrsfResults = [SELECT SUM(ASI_CRM_CN_TP_GS_Percent__c) gsRatio, ASI_CRM_CN_Sub_Brand__r.Name  subName,
                                                         SUM(ASI_CRM_CN_TP_GS_Amount__c) gsAmount, SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixedCost,
                                                        SUM(ASI_CRM_CN_TP_Promotion_Fee__c) proCost
                                                FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                                WHERE ASI_TH_CRM_Payment_Request__c = :pmt.Id
                                                AND RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_BRSF'
                                                GROUP BY ASI_CRM_CN_Sub_Brand__r.Name];
        System.debug(LoggingLevel.INFO, '*** pmtBrsfResults: ' + JSON.serialize(pmtBrsfResults));
        Map<String, AggregateResult> pmtResulMap = new Map<String, AggregateResult>();
        // Decimal actualPercent = 0.0;
        Decimal pmtTotalGSAmt = 0.0;
        Decimal pmtTotalProCost = 0.0;
        for (AggregateResult pmtResult : pmtBrsfResults) {
            String subkey = (String)pmtResult.get('subName');
            pmtResulMap.put(subkey, pmtResult);
            // actualPercent += (Decimal)pmtResult.get('gsRatio');
            pmtTotalGSAmt += pmtResult.get('gsAmount') == null ? 0.0 : (Decimal)pmtResult.get('gsAmount');
            pmtTotalProCost += pmtResult.get('proCost') == null ? 0.0 : (Decimal)pmtResult.get('proCost');
            pmtTotalProCost += pmtResult.get('fixedCost') == null ? 0.0 : (Decimal)pmtResult.get('fixedCost');
        }
        gsList = new List<GrossSales>();
        for (String subkey : pmtResulMap.keySet()) {
            AggregateResult poResult = poResulMap.get(subkey);
            system.debug('poResult '+poResult);
            AggregateResult pmtResult = pmtResulMap.get(subkey);
            system.debug('pmtResult '+pmtResult);
            Decimal poGsRatio = 0;
            Decimal pmGsRatio = 0;
            if(poResult!=null){
              poGsRatio = poResult.get('gsRatio')==null?0:(Decimal)poResult.get('gsRatio');
            }
            if(pmtResult!=null){
              pmGsRatio = pmtResult.get('gsRatio')==null?0:(Decimal)pmtResult.get('gsRatio');
            }
            GrossSales gs = new GrossSales((String)pmtResult.get('subName'),poGsRatio,pmGsRatio);
            gsList.add(gs);
        }
        Decimal totalPercent = poTotalGSAmt == 0.0 ? 0.0 : (poTotalProCost/poTotalGSAmt * 100).setScale(2);
        Decimal actualPercent = pmtTotalGSAmt == 0.0 ? 0.0 : (pmtTotalProCost/pmtTotalGSAmt * 100).setScale(2);
        totalCostRatio = new GrossSales('', totalPercent, actualPercent);


        // List<ASI_TH_CRM_Contract__c> poV0 = [SELECT Id,ASI_CRM_CN_Last_PO_version__c, ASI_CRM_New_FY_PO__c,ASI_TH_CRM_Promotion_Type__c FROM ASI_TH_CRM_Contract__c 
        //                                      WHERE ASI_CRM_CN_PO_No__c = :PO.ASI_CRM_CN_PO_No__c
        //                                      AND ASI_CRM_CN_PO_Version__c = '0.0'];
        // List<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> pmtSummaryList = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(null,poV0[0]);
        // System.debug(LoggingLevel.INFO, '*** JSON.serialize(pmtSummaryList): ' + JSON.serialize(pmtSummaryList));
        
        // Decimal totalPOEstAmt = 0.0;
        // for(ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary ps : pmtSummaryList){

        //     totalPOEstAmt += ps.POEstimateAmt == null ? 0.0 : ps.POEstimateAmt;
            // TotalPORemainAmt += ps.PORemainAmt == null ? 0 : ps.PORemainAmt;
            // TotalRequestAmt += ps.PaymentRequestAmount == null ? 0 : ps.PaymentRequestAmount;
        // }
        
        GSRatio = 0.0;
        paymentSpeed = 0.0;
        pmtPromotionSpeed = 0.0;
        Decimal totalRequestAmt = 0.0;
        Decimal proRequestAmt = 0.0;
        for(ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary ps : paymentSummaryList){
            if (ps.feeChiName == ASI_CRM_CN_TP_Utils.PRICE_PROMOTION) {
                proRequestAmt += ps.PaymentRequestAmount == null ? 0.0 : ps.PaymentRequestAmount;
            }
            totalRequestAmt += ps.PaymentRequestAmount == null ? 0.0 : ps.PaymentRequestAmount;
        }
        GSRatio = poTotalGSAmt == 0.0 ? 0.0 : (pmtTotalGSAmt/poTotalGSAmt * 100).setScale(2);
        paymentSpeed = poTotalProCost == 0.0 ? 0.0 : (totalRequestAmt/poTotalProCost * 100).setScale(2);
        pmtPromotionSpeed = poTotalProCost == 0.0 ? 0.0 : (proRequestAmt/poTotalProCost * 100).setScale(2);

    }

    // Last payment
    public void calculateLastPaymentSummary() {
        
        List<AggregateResult> poBrsfResults = [SELECT SUM(ASI_CRM_CN_Total_Volume_9L__c) vol, SUM(ASI_CRM_CN_TP_Promotion_Cost__c) proCost,
                                                      SUM(ASI_CRM_CN_TP_CM_Amount__c) cmAmt, SUM(ASI_CRM_CN_TP_GS_Amount__c) gsAmt,
                                                       SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixCost, ASI_CRM_CN_Sub_Brand__r.Name subName
                                                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                                WHERE ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_No__c = :PO.ASI_CRM_CN_PO_No__c
                                                AND ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c = '0.0'
                                                AND RecordType.DeveloperName = 'ASI_CRM_CN_Contract_TradePlan_BRSF_Line_Item'
                                                GROUP BY ASI_CRM_CN_Sub_Brand__r.Name];
        Map<String, AggregateResult> poResulMap = new Map<String, AggregateResult>();
        Decimal poTotalVol = 0.0;
        Decimal poTotalCost = 0.0;
        Decimal poTotalCMAmt = 0.0;
        Decimal poTotalGSAmt = 0.0;
        Decimal poTotalGSRatio = 0.0;
        Decimal poTotalFixAmt = 0.0;
        for (AggregateResult poResult : poBrsfResults) {
            String subkey = (String)poResult.get('subName');
            poResulMap.put(subkey, poResult);
            poTotalVol += poResult.get('vol') == null ? 0.0 : (Decimal)poResult.get('vol');
            poTotalCost += poResult.get('proCost') == null ? 0.0 : (Decimal)poResult.get('proCost');
            poTotalCMAmt += poResult.get('cmAmt') == null ? 0.0 : (Decimal)poResult.get('cmAmt');
            poTotalGSAmt += poResult.get('gsAmt') == null ? 0.0 : (Decimal)poResult.get('gsAmt');
            poTotalFixAmt += poResult.get('fixCost') == null ? 0.0 : (Decimal)poResult.get('fixCost');
        }
        poTotalGSRatio = poTotalGSAmt == 0.0 ? 0.0 : (poTotalCost/poTotalGSAmt * 100).setScale(2);
       
        Map<String, ASI_CRM_CN_TP_Utils.POBRSFInfo> actualBRSFMap = ASI_CRM_CN_TP_Utils.LastpaymentForm(pmt.Id);
        Map<String, ASI_CRM_CN_TP_Utils.POBRSFInfo> pmtResulMap = new Map<String, ASI_CRM_CN_TP_Utils.POBRSFInfo>();
        Decimal pmtTotalVol = 0.0;
        Decimal pmtTotalCost = 0.0;
        Decimal pmtTotalCMAmt = 0.0;
        Decimal pmtTotalGSAmt = 0.0;
        Decimal pmtTotalGSRatio = 0.0;
        Decimal pmtTotalFixAmt = 0.0;
        for (ASI_CRM_CN_TP_Utils.POBRSFInfo info : actualBRSFMap.values()) {
            pmtResulMap.put(info.subBrandName, info);
            pmtTotalVol += info.actualVolumeIn9L == null ? 0.0 : info.actualVolumeIn9L;
            pmtTotalCost += info.actualAmount == null ? 0.0 : info.actualAmount;
            pmtTotalCMAmt += info.cmAmount == null ? 0.0 : info.cmAmount;
            pmtTotalGSAmt += info.gsAmount == null ? 0.0 : info.gsAmount;
            pmtTotalFixAmt += info.fixedCost == null ? 0.0 : info.fixedCost;
        }
        pmtTotalGSRatio = pmtTotalGSAmt == 0.0 ? 0.0 : (pmtTotalCost/pmtTotalGSAmt * 100).setScale(2);

        gsVolList = new List<GrossSales>();
        gsVolList.add(new GrossSales('Total volume (in 9L)', poTotalVol, pmtTotalVol));
        for (String subkey : pmtResulMap.keySet()) {
            AggregateResult poResult = poResulMap.get(subkey);
            System.debug(LoggingLevel.INFO, '*** poResult: ' + poResult);
            ASI_CRM_CN_TP_Utils.POBRSFInfo pmtResult = pmtResulMap.get(subkey);
            System.debug(LoggingLevel.INFO, '*** pmtResult: ' + pmtResult);
            if (pmtResult != null && poResult != null) {
                GrossSales gs = new GrossSales(pmtResult.subBrandName, (Decimal)poResult.get('vol'), pmtResult.actualVolumeIn9L);
                gsVolList.add(gs);
            }
            
        }
        totalCost = new GrossSales('', (poTotalCost + poTotalFixAmt) * -1, (pmtTotalCost + pmtTotalFixAmt) * -1);
        totalCM = new GrossSales('', poTotalCMAmt, pmtTotalCMAmt);
        totalGS = new GrossSales('', poTotalGSAmt, pmtTotalGSAmt);
        totalGSRatio = new GrossSales('', poTotalGSRatio, pmtTotalGSRatio);
        totalPro = new GrossSales('', poTotalCost * -1, pmtTotalCost * -1);
        totalFix = new GrossSales('', poTotalFixAmt * -1, pmtTotalFixAmt * -1);

    } 

    class GrossSales{
        public String proName {get; set;}
        public Decimal gsRatioV0 {get; set;}
        public Decimal actualRatio {get; set;}
        public Decimal vsRatio {get; set;}

        GrossSales(String proName, Decimal gsRatioV0, Decimal actualRatio) {
            this.proName = proName;
            this.gsRatioV0 = gsRatioV0 == null ? 0.0 : gsRatioV0;
            this.actualRatio = actualRatio == null ? 0.0 : actualRatio;
            this.vsRatio = this.actualRatio - this.gsRatioV0;
        }

    }
}