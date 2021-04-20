/*****************************************************************************
Added:
1. Covered Outlet 
2. CutOffDay
3. Competitor Subbrand Filtering
*****************************************************************************/

public without sharing class ASI_CRM_CN_PRForm_Cmpnt_Ctrl{


    public string isTest {set;get;}
    public string isTestDate {set;get;}
    public string isTest1 {set;get;}
    public string isTestDate1 {set;get;}
    public String relatedto { get; set; }
    public string strPDF {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    //20151204 Ben @ Elufa System
    public Decimal totalOffTakeVSInTake {get;set;}
    public Decimal totalOffTakeVSBC {get;set;}
    //End
    public string PageId {set;get;}

    //Query List
    public list<ASI_TH_CRM_PaymentRequestLineItem__c> PSF_List {set;get;}
    public list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSF_List {set;get;}
    public transient  list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List {set;get;}
    public list<ASI_CRM_Subbrand_Volume__c> SB_Vol_GreenCap_List {set;get;}
    //public list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List_v0 {set;get;}
    //public list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List_All {set;get;}
    //public list<ASI_CRM_CM_GS__c> ActualCM_List {set;get;}
    public list<ASI_CRM_CM_GS__c> BudgetCM_List_v0 {set;get;}
    public list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet {set;get;}

    //Manual assign List & Map & Set
    public map<string, DataClass> PSF_map {set;get;}
    public map<string, DataClass> SubBrand_ROI_map_v1 {set;get;}
    public map<string, DataClass> SubBrand_ROI_map_v0 {set;get;}
    public set<id> BRSF_SBId {set;get;}
    public set<id> BRSF_SBId_v0 {set;get;}
    public map<date, date> PSF_Period_map {set;get;}
    public DataClass TotalVolCR12 {set;get;}
    public DataClass TotalVolBtl {set;get;}
    public DataClass Investment_CR12 {set;get;}
    public map<id, decimal> ActualCM_v0_map {set;get;}
    public map<string, decimal> ActualCM_v1_map {set;get;}
    public map<string, decimal> ActualGS_v1_map {set;get;}
    public map<string, decimal> lbcm_v1_map {set;get;}
    public DataClass vAllROI {set;get;}
    public DataClass vProFormaROI {set;get;}

    //String & Decimal
    public decimal Other_VOL_CR12 {set;get;}
    public decimal TotalCR12_Volume_v0 {set;get;}
    public decimal TotalCR12_Volume_v1 {set;get;}
    public decimal PaymentBCRate {set;get;}
    public decimal PaymentSpeed {set;get;}
    public date AllPaymentPeriod {set;get;} //BRSF or PSF Latest Period
    public date CutOffDay {set;get;} //Pending Custom Setting follow for Sub Brand Volume
    public decimal BRSF_CTD_CR12 {get;set;}
    public decimal BRSF_CTD_Cost {set;get;}
    public decimal BRSF_CTD_CR12_contract {set;get;}
    public decimal BRSF_CTD_Cost_contract {set;get;}

    //AD or Above Identity checking
    public boolean ADorAbove {set;get;}
    public string UserId {set;get;}

    //Payee Line Item
    public list<ASI_CRM_CN_PH_Payee_Line_Item__c> PayeeList {set;get;}
    public decimal PayeeAmount {set;get;}

    //Profit Shuttle
    public map<string, string> SubbrandGroup {set;get;}
    public map<string, DataClass> lastpayment_sbgrade {set;get;}
    public DataClass VolumeData {set;get;}
    public DataClass tradeExp {set;get;}
    public DataClass VarExp {set;get;}
    public DataClass FixExp {set;get;}
    public DataClass FixExpRate {set;get;}
    public DataClass GrossSales {set;get;}
    public DataClass MarginAP {set;get;}
    public DataClass MarginperBtl {set;get;}

    //Fixes
    public date PSFEndDate {set;get;}
    public date PSFStartDate {set;get;}
    public string PSFDateString {set;get;}

    public list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> paymentRequestSummary {set;get;}
    public list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> mafSummary {set;get;} //20160816, added by Leo
    public list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> cnySummary {set;get;} //20160816, added by Leo
    public list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> othersSummary {set;get;} //20160816, added by Leo
    public decimal PS_TotalPOEstAmt {set;get;}
    public decimal PS_TotalPORemainAmt {set;get;}
    public decimal PS_TotalPRAmt {set;get;}
    public decimal PS_TotalMAFEstAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalMAFRemainAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalMAFPRAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalCNYEstAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalCNYRemainAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalCNYPRAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalOthersEstAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalOthersRemainAmt {set;get;} //20160816, added by Leo
    public decimal PS_TotalOthersPRAmt {set;get;} //20160816, added by Leo

    public map<string, map<string,decimal>> RegionSubBrandCM_Map = new map<string,map<string,decimal>>(); // Added by Alan Wong (Elufa) 20150623

    //BA Comment
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}

    //BC % - Actual Performance
    public decimal intActualBCRate {set;get;}

    //20200610
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> freeGoodsList {get;set;}
    public Boolean DisplayFreeGoods {set;get;} {DisplayFreeGoods = false;}

    public ASI_CRM_CN_PRForm_Cmpnt_Ctrl() {
        //strPDF = ApexPages.currentPage().getParameters().get('pdf'); //Test
        //Canter注释 注释时间：2019/8/29 注释原因：获取pageId的方式有问题，且不应该在无参构造函数中这样操作
        PageId = ApexPages.currentPage().getParameters().get('Id'); 
        String objectName = ASI_TH_CRM_PaymentRequest__c.sobjecttype.getDescribe().getKeyPrefix();
        String PageIdName;
        if(PageId != null) {PageIdName=PageId.substring(0, 3);}
        if(PageIdName != objectName){
            PageId = ApexPages.currentPage().getParameters().get('related_to_id'); 
            strPDF = '0';
        }else{
            strPDF = ApexPages.currentPage().getParameters().get('pdf');
        }
        isTest1 = ApexPages.currentPage().getParameters().get('test');
        isTestDate1 = ApexPages.currentPage().getParameters().get('cutoff');

        system.debug('PageId: ' + PageId);
        system.debug('thisPR: ' + thisPR);

        if (PageId == null && thisPR != null){
            PageId = thisPR.Id;
        }

        if (PageId != null){
            thisPR = [SELECT id,ASI_CRM_CN_Payment_Raised_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Total_BRSF_Amount__c,
                    ASI_CRM_CN_Total_PSF_Amount__c, ASI_CRM_CN_Total_Other_Amount__c , ASI_CRM_CN_PO_Remain_Amount__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_Heap_Size_Large__c,
                    ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.Name,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,//20170209 Elufa
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.Name, ASI_CRM_CN_Payment_Type__c,
                    ASI_CRM_CN_Overpayment_Reason__c, ASI_CRM_CN_Other_Reason__c, ASI_CRM_CN_Description__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_PO_End_Date__c,
                    ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PSF_End__c , ASI_CRM_CN_PSF_Start__c ,
                    Owner.Name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Cost_Total__c ,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.Name, ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Currency__c,
                    ASI_CRM_CN_BRSF_End_Date__c , ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_BRSF_Start_Date__c, ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_CRM_CN_PO_No__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_OutletWS__r.Name, name,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
                    ASI_CRM_CN_Total_Payment__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_TH_CRM_Contract__r.ASI_CRM_Investment_Type__c,
                    ASI_CRM_New_FY_Payment__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name, ASI_TH_CRM_Contract__r.ASI_CRM_PO_Channel__r.Name//20160617 Ben @ Elufa
                    ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__c //20160621 Ben @ Elufa
                    ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.Name //20160621 Ben @ Elufa
                    ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c //20160621 Ben @ Elufa
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE id = :PageId];
      
            //INC0092941 
            if (dummyVar != true) 
            {
                dummyVar = init();
            } 
            
            //init();
        }

    }


    public ASI_CRM_CN_PRForm_Cmpnt_Ctrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('Id'); 
        String objectName = ASI_TH_CRM_PaymentRequest__c.sobjecttype.getDescribe().getKeyPrefix();
        String PageIdName;
        if(PageId != null) {PageIdName=PageId.substring(0, 3);}
        if(PageIdName != objectName){
            PageId = ApexPages.currentPage().getParameters().get('related_to_id'); 
            strPDF = '0';
        }else{
            strPDF = ApexPages.currentPage().getParameters().get('pdf');
        }
        isTest1 = ApexPages.currentPage().getParameters().get('test');
        isTestDate1 = ApexPages.currentPage().getParameters().get('cutoff');
        if (PageId == null && thisPR != null){
            PageId = thisPR.Id;
        }
        if (PageId != null){
            thisPR = [SELECT id,ASI_CRM_CN_Payment_Raised_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Total_BRSF_Amount__c,
                    ASI_CRM_CN_Total_PSF_Amount__c, ASI_CRM_CN_Total_Other_Amount__c , ASI_CRM_CN_PO_Remain_Amount__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_Heap_Size_Large__c,
                    ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.Name,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,//20170209 Elufa
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.Name, ASI_CRM_CN_Payment_Type__c,
                    ASI_CRM_CN_Overpayment_Reason__c, ASI_CRM_CN_Other_Reason__c, ASI_CRM_CN_Description__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_PO_End_Date__c,
                    ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PSF_End__c , ASI_CRM_CN_PSF_Start__c ,
                    Owner.Name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Cost_Total__c ,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_CRM_CN_Promotion_Type__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.Name, ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Currency__c,
                    ASI_CRM_CN_BRSF_End_Date__c , ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_BRSF_Start_Date__c, ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_CRM_CN_PO_No__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_OutletWS__r.Name, name,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
                    ASI_CRM_CN_Total_Payment__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_TH_CRM_Contract__r.ASI_CRM_Investment_Type__c,
                    ASI_CRM_New_FY_Payment__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name, ASI_TH_CRM_Contract__r.ASI_CRM_PO_Channel__r.Name//20160617 Ben @ Elufa
                    ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__c //20160621 Ben @ Elufa
                    ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.Name //20160621 Ben @ Elufa
                    ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c //20160621 Ben @ Elufa
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE id = :PageId];
            system.debug('197-->'+thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c);
            
            if (dummyVar != true) {
                   dummyVar = init();
             } 
            //init();
            system.debug('最终的ADorAbove的值：' + ADorAbove);
        }
    }
    public void InitVariable(){
        /****************************** SET CUTOFF Date ***********************************/
        CutOffDay = CutOffDate(16); // 0 = ASI_CRM_CN_PO_End_Date__c
        /****************************** SET CUTOFF Date ***********************************/

        //-------------------------------------------------------------------------
        //Sub-Brand Grade Grouping
        SubbrandGroup = new map<string, string>();
        SubbrandGroup.put('Premium', '1. Standard + Premium / 标准档 + 高档');
        SubbrandGroup.put('Standard', '1. Standard + Premium / 标准档 + 高档');
        SubbrandGroup.put('Prestige', '4. Prestige + Ultra Prestige / 奢华档 + 特级奢华档');
        SubbrandGroup.put('Ultra Prestige', '4. Prestige + Ultra Prestige / 奢华档 + 特级奢华档');
        SubbrandGroup.put('Super Premium', '2. Super Premium / 超高档');
        SubbrandGroup.put('Ultra Premium', '3. Ultra Premium / 特级高档');
        SubbrandGroup.put('Not Specified / 未指定','0. Not Specified / 未指定');
        //system.debug('SubbrandGroup: ' + SubbrandGroup);
        lastpayment_sbgrade = new map<string, DataClass>();
        //-------------------------------------------------------------------------

        ADorAbove = false;
        if (strPDF == '1'){
            checkUserID();
        }else if (strPDF == '0'){
            checkApprover();
        }

        system.debug('strPDF:' + strPDF);
        system.debug('ADorAbove:' + ADorAbove);

        PSF_map = new map<string, DataClass>();
        SubBrand_ROI_map_v1 = new map<string, DataClass>();
        SubBrand_ROI_map_v0 = new map<string, DataClass>();
        PSF_Period_map = new map<date, date>();
        BRSF_SBId = new set<id>();
        BRSF_SBId_v0 = new set<id>();
        PSF_List = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        BRSF_List = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c>();
        //SB_Vol_List_v0 = new list<ASI_CRM_Subbrand_Volume__c>();
        SB_Vol_GreenCap_List = new list<ASI_CRM_Subbrand_Volume__c>();
        //ActualCM_List = new list<ASI_CRM_CM_GS__c>();
        BudgetCM_List_v0 = new list<ASI_CRM_CM_GS__c>();
        ActualCM_v0_map = new map<id, decimal>();
        ActualCM_v1_map = new map<string, decimal>();
        ActualGS_v1_map = new map<string, decimal>();
        lbcm_v1_map = new map<string, decimal>(); // Added by Alan Wong (Elufa) 20150623

        PaymentBCRate = 0;
        BRSF_CTD_CR12 = 0;
        BRSF_CTD_Cost = 0;
        BRSF_CTD_CR12_contract = 0;
        BRSF_CTD_Cost_contract = 0;
        Other_VOL_CR12 = 0;
        PaymentSpeed = 0;
        PayeeList = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        PayeeAmount = 0;
        //Total Volume (std btl)
        TotalVolBtl = new DataClass();
        TotalVolBtl.target_vol = 0;
        TotalVolBtl.actual_vol = 0;

        //Total Volume (std btl)
        TotalVolCR12 = new DataClass();
        TotalVolCR12.target_vol = 0;
        TotalVolCR12.actual_vol = 0;

        //Investment per Btl
        Investment_CR12 = new DataClass();
        Investment_CR12.v0 = 0;
        Investment_CR12.v1 = 0;
        Investment_CR12.gap = 0;
        Investment_CR12.v0_contract = 0;
        Investment_CR12.v0_con_gap = 0;
        Investment_CR12.v0_est_gap = 0;

        //(Total BRSF CR12) - Prepare for calculating Investment per BTL (Contract Total Cost / Total BRSF CR12)
        TotalCR12_Volume_v0 = 0;
        TotalCR12_Volume_v1 = 0;

        //ROI Only for AD Above
        vALLROI = new DataClass();
        vALLROI.v0 = 0;
        vALLROI.v1 = 0;
        vALLROI.gap = 0;
        vAllROI.v0_contract = 0;
        vAllROI.v0_estimate = 0;
        vAllROI.v1_actual = 0;
        vAllROI.v0_con_gap = 0;
        vAllROI.v0_est_gap = 0;

        // Added by Alan Wong (Elufa) 20150623
        vProFormaROI = new DataClass();
        vProFormaROI.v0 = 0;
        vProFormaROI.v1 = 0;
        vProFormaROI.gap = 0;
        vProFormaROI.v0_contract = 0;
        vProFormaROI.v0_estimate = 0;
        vProFormaROI.v1_actual = 0;
        vProFormaROI.v0_con_gap = 0;
        vProFormaROI.v0_est_gap = 0;
        // -- End -- //
        VolumeData = new DataClass();
        VolumeData.v0_contract = 0;
        VolumeData.v0_estimate = 0;
        VolumeData.v1_actual = 0;
        VolumeData.v0_con_gap = 0;
        VolumeData.v0_est_gap = 0;

        tradeExp = new DataClass();
        tradeExp.v0_contract = 0;
        tradeExp.v0_estimate = 0;
        tradeExp.v1_actual = 0;
        tradeExp.v0_con_gap = 0;
        tradeExp.v0_est_gap = 0;

        VarExp = new DataClass();
        VarExp.v0_contract = 0;
        VarExp.v0_estimate = 0;
        VarExp.v1_actual = 0;
        VarExp.v0_con_gap = 0;
        VarExp.v0_est_gap = 0;

        FixExp = new DataClass();
        FixExp.v0_contract = 0;
        FixExp.v0_estimate = 0;
        FixExp.v1_actual = 0;
        FixExp.v0_con_gap = 0;
        FixExp.v0_est_gap = 0;

        FixExpRate = new DataClass();
        FixExpRate.v0_contract = 0;
        FixExpRate.v0_estimate = 0;
        FixExpRate.v1_actual = 0;
        FixExpRate.v0_con_gap = 0;
        FixExpRate.v0_est_gap = 0;

        GrossSales = new DataClass();
        GrossSales.v0_contract = 0;
        GrossSales.v0_estimate = 0;
        GrossSales.v1_actual = 0;
        GrossSales.v0_con_gap = 0;
        GrossSales.v0_est_gap = 0;

        MarginAP = new DataClass();
        MarginAP.v0_contract = 0;
        MarginAP.v0_estimate = 0;
        MarginAP.v1_actual = 0;
        MarginAP.v0_con_gap = 0;
        MarginAP.v0_est_gap = 0;

        MarginperBtl = new DataClass();
        MarginperBtl.v0_contract = 0;
        MarginperBtl.v0_estimate = 0;
        MarginperBtl.v1_actual = 0;
        MarginperBtl.v0_con_gap = 0;
        MarginperBtl.v0_est_gap = 0;

        paymentRequestSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();

        // Added By Alan Wong(Elufa) 20150623
        // get latest Budget CM for all Sub-Brands
        string currentFY = String.valueOf(FYConversion(date.Today()).Year());
        string currentFY2 = (integer.valueOf(currentFY) - 1) + '';
        string currentFY3 = (integer.valueOf(currentFY) - 2) + '';
        string ProductCode;
        string Region;
        decimal cm;
        map<string, decimal> newItem;
        map<string, decimal> newItem2;
        for (ASI_CRM_CM_GS__c lbcm : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c, ASI_CRM_CN_Month__c
        FROM ASI_CRM_CM_GS__c
        WHERE ASI_CRM_CN_Month__c = 6
        AND ASI_CRM_Region__c = : thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
        AND (ASI_CRM_YEAR__c = :currentFY
        OR ASI_CRM_YEAR__c = :currentFY2//2017029 Elufa
        OR ASI_CRM_YEAR__c = :currentFY3)//2017029 Elufa
        AND (ASI_CRM_TYPE__c = 'Budget CM')
        AND ASI_CRM_CM_GS_per_9L__c != Null//2017029 Elufa
        AND ASI_CRM_CM_GS_per_9L__c != 0//2017029 Elufa
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            Region = lbcm.ASI_CRM_Region__c;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c == null){
                cm = 0;
            }else{
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
            }
            if (!RegionSubBrandCM_Map.containsKey(Region) ){
                if(cm != Null && cm != 0){//20161111 Elufa added && cm != Null && cm != 0
                    newItem = new map<string, decimal>();
                    newItem.put(ProductCode, cm);
                    RegionSubBrandCM_Map.put(Region,newItem);
                }
            }else if(!RegionSubBrandCM_Map.get(Region).containsKey(ProductCode)){
                if( cm != Null && cm != 0)//20161111 Elufa && cm != Null && cm != 0
                    RegionSubBrandCM_Map.get(Region).put(ProductCode,cm);
            }
        }
        system.debug('RegionSubBrandCM_Map:::' + RegionSubBrandCM_Map);
        system.debug('strPDF2:' + strPDF);
        system.debug('ADorAbove2:' + ADorAbove);
        // -- End -- //


    }

    public date CutOffDate(integer strDay){
        Date returnDate;
        Integer strDate = Date.Today().Day();
        Integer strMonth;
        Integer strEndDay;
        if (strDay != 0){
            if (strDate >= strDay){
                strMonth = Date.Today().Month() - 1;
            }
            if (strDate < strDay){
                strMonth = Date.Today().Month() - 2;
            }
            strEndDay = Date.daysInMonth(Date.Today().Year(), strMonth);
            returnDate = Date.newinstance(Date.Today().Year(),strMonth,strEndDay);
        }else{
            returnDate = thisPR.ASI_CRM_CN_PO_End_Date__c;
        }
        if (isTest == '1' && isTestDate != null && isTestDate != ''){
            system.debug('TestDate: ' + integer.valueof(isTestDate.Left(4)) + ' ' + integer.valueof(((isTestDate.Right(4)).Left(2))) + ' ' + integer.valueof(isTestDate.Right(2)));
            return Date.newinstance(integer.valueof(isTestDate.Left(4)),integer.valueof(((isTestDate.Right(4)).Left(2))),integer.valueof(isTestDate.Right(2)));
        }
        //system.debug('CutOffDate: ' + returnDate);
        return returnDate;
    }

    public boolean init(){
        InitVariable();

        if (thisPR.id != null){
            //Added by Twinkle 11/25/2014 - BA Comments
            lstApprovalComment = [SELECT id, ASI_CRM_BA_comments__c FROM ASI_CRM_Approval_Comment__c
            WHERE ASI_CRM_Payment_Request__c =:thisPR.id];
            if(lstApprovalComment==null || lstApprovalComment.size()==0){
                lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
            }else{
                lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
            }
            //Ended by Twinkle 11/25/2014

            Id PSF_RTId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
            Id BRSF_RTId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');

            //Added by William Yang(Introv) 20141024 to fix issue #151
            if(thisPR.ASI_CRM_CN_Description__c != null && thisPR.ASI_CRM_CN_Description__c != '')
            {
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\,', '\\, ');
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\，', '\\， ');
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\.', '\\. ');
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\。', '\\。 ');
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\;', '\\; ');
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\；', '\\； ');
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\:', '\\: ');
                thisPR.ASI_CRM_CN_Description__c = thisPR.ASI_CRM_CN_Description__c.replaceAll('\\：', '\\： ');
            }
            //Latest Period End Date (CTD)
            if (thisPR.ASI_CRM_CN_BRSF_End_Date__c != null )
                AllPaymentPeriod = thisPR.ASI_CRM_CN_BRSF_End_Date__c ;
            else if (thisPR.ASI_CRM_CN_PSF_End__c > thisPR.ASI_CRM_CN_BRSF_End_Date__c)
                AllPaymentPeriod = thisPR.ASI_CRM_CN_PSF_End__c;

            //if PSF does not exist
            if (thisPR.ASI_CRM_CN_PSF_End__c != null)
                PSFEndDate = thisPR.ASI_CRM_CN_PSF_End__c;
            else
                    PSFEndDate = CutOffDay;
            if (thisPR.ASI_CRM_CN_PSF_Start__c != null)
                PSFStartDate = thisPR.ASI_CRM_CN_PSF_Start__c;

            if (PSFStartDate != null && PSFEndDate != null)
                PSFDateString = string.valueof(PSFStartDate.DAY()) + '/' + string.valueof(PSFStartDate.MONTH()) + '/' + string.valueof(PSFStartDate.YEAR()) + ' - ' + string.valueof(PSFEndDate.DAY()) + '/' + string.valueof(PSFEndDate.MONTH()) + '/' + string.valueof(PSFEndDate.YEAR());
            else
                    PSFDateString = 'No PSF Period specified.';

            try{
                //query PSF Period Date
                PSF_List = [SELECT id, ASI_CRM_CN_Period_End__c, ASI_CRM_CN_Period_Start__c, ASI_TH_CRM_Amount__c,
                        ASI_CRM_CN_Payment_Description__c , ASI_CRM_CN_Comment__c
                        , ASI_CRM_CN_Offtake_Vol__c, ASI_CRM_CN_Actual_Vol__c, ASI_CRM_CN_Bottle_Collected__c//20151204 Ben @ Elufa System
                FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__c = :thisPR.id
                AND ASI_CRM_CN_Period_Start__c != null AND ASI_CRM_CN_Period_End__c != null
                AND RecordTypeId = :PSF_RTId ];
            }catch(exception e){
                //system.debug('Try PSF_List failed: ' + e);
                PSF_List = new list<ASI_TH_CRM_PaymentRequestLineItem__c >();
            }

            //get & map Start + End date
            if (PSF_List.size() > 0){

                for (ASI_TH_CRM_PaymentRequestLineItem__c  PSF_List_temp: PSF_List){

                    //Add Data Collection Period
                    PSF_Period_map.put(PSF_List_temp.ASI_CRM_CN_Period_Start__c, PSF_List_temp.ASI_CRM_CN_Period_End__c);
                    //Latest Period End Date
                    if (PSF_List_temp.ASI_CRM_CN_Period_End__c > AllPaymentPeriod )
                        AllPaymentPeriod = PSF_List_temp.ASI_CRM_CN_Period_End__c ;

                    //Updated by William Yang(Introv) 20141111 fix pdf rendering
                    if(PSF_List_temp.ASI_CRM_CN_Comment__c != null && PSF_List_temp.ASI_CRM_CN_Comment__c != '')
                    {
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\,', '\\, ');
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\，', '\\， ');
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\.', '\\. ');
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\。', '\\。 ');
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\;', '\\; ');
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\；', '\\； ');
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\:', '\\: ');
                        PSF_List_temp.ASI_CRM_CN_Comment__c = PSF_List_temp.ASI_CRM_CN_Comment__c.replaceAll('\\：', '\\： ');
                    }
                    //End of update by William Yang(Introv) 20141111
                }
            }
            try{
                //query Contract vFinal & v0.0 BRSF Sub Brands & Data
                BRSF_List = [SELECT id, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Monthly_Qty__c , ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,
                        ASI_CRM_CN_Contract__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                        ASI_CRM_CN_Contract_Monthly_Vol9L__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                        ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c
                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :thisPR.ASI_TH_CRM_Contract__c
                OR ASI_CRM_CN_Contract__c = :thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c];
            }catch(exception e){
                BRSF_List = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c >();
            }
            //Generate Contract Period, subbrand id Data
            map<date, decimal> V0_Period_map = new map<date, decimal>();
            
            if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null){
                if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c != null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c != null)
                    V0_Period_map = checkFYDayPeriod(thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
            }else{
                if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c != null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c != null)
                    V0_Period_map = checkFYDayPeriod(thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c);
            }
            map<string, DataClass> v0_ROI_newMap = new map<string, DataClass>();
            set<id> v0_BRSF_sbid_set = new set<id>();
            if (BRSF_List.size() > 0 ){
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c v0brsftemp : BRSF_List){
                    v0_BRSF_sbid_set.add(v0brsftemp.ASI_CRM_CN_Sub_Brand__c);
                }
            }
            if (v0_Period_map.size() > 0){
                string strkey;
                for (date v0temp : V0_Period_map.keyset()){
                    if (v0_BRSF_sbid_set.size() > 0){
                        for (id idtemp : v0_BRSF_sbid_set){
                            strkey = string.valueof(v0temp) + idtemp;
                            if (!v0_ROI_newMap.containskey(strkey)){
                                DataClass newitem = new DataClass();
                                newitem.strPeriod = V0_Period_map.get(v0temp);
                                newitem.sbid = idtemp;
                                v0_ROI_newMap.put(strkey, newitem);
                            }
                        }
                    }
                }
            }
            //get BRSF Target Volume from BRSF
            Integer PSFPeriod;
            if (thisPR.ASI_CRM_CN_PSF_Start__c != null && thisPR.ASI_CRM_CN_PSF_End__c != null)
                PSFPeriod = MonthDiff(thisPR.ASI_CRM_CN_PSF_Start__c, thisPR.ASI_CRM_CN_PSF_End__c );
            else
                    PSFPeriod = 0;

            Decimal CCPeriod = thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c;
            decimal v0_CCPeriod;
            if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null)
                v0_CCPeriod  = thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c;
            else
                    v0_CCPeriod  = thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c;
            //decimal FCBRSF_targetvol_CR12 = 0;
            decimal FCBRSF_targetvol_9L = 0;
            decimal FCBRSF_targetvol_Btl = 0;
            decimal FCBRSF_targetvol_CR12_v0 = 0;
            decimal FCBRSF_targetvol_9L_v0 = 0;
            decimal FCBRSF_targetvol_Btl_v0 = 0;
            decimal v0Estimate_totalBtl = 0;
            decimal v0Contract_totalBtl = 0;
            decimal v0_EstCost = 0;
            string sbGradeName;
            //system.debug('BRSF_List: ' + BRSF_List.size());
            if (BRSF_List.size() > 0){
                string sb_brand;
                decimal BRSF_targetvol_Btl = 0;
                decimal BRSF_targetvol_CR12 = 0;
                decimal BRSF_targetvol_CR12_v0 = 0;
                decimal Vol12_temp = 0;
                decimal Vol12Contract_temp = 0;
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSF_List_temp : BRSF_List){
                    //Profit Shuttle like table
                    if (BRSF_List_temp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                        if (SubbrandGroup.containskey(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                            sbGradeName = SubbrandGroup.get(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                        }else{
                            sbGradeName = 'Not Specified / 未指定';
                        }
                    }else{
                        sbGradeName = 'Not Specified / 未指定';
                    }
                    //PSF Map key (by Brand Name)
                    if (BRSF_List_temp.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c != null)
                        sb_brand = BRSF_List_temp.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name;
                    if (BRSF_List_temp.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c != null)
                        sb_brand += ' / ' + BRSF_List_temp.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c;
                    else
                            sb_brand = 'Not Specified / 未指定';

                    //vFinal PO
                    if (BRSF_List_temp.ASI_CRM_CN_Contract__c == thisPR.ASI_TH_CRM_Contract__c){
                        //Uses to select Actual volume from Subbrand Volume table
                        BRSF_SBId.add(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__c);

                        //Define Target Volume value & Sub brand - Brand name
                        DataClass BRSF_Class = new DataClass();
                        BRSF_Class.target_vol = 0;
                        BRSF_Class.actual_vol = 0;
                        BRSF_Class.achieverate= 0;

                        //Last Payment Full Contract Table - Target Volume (9L) = Estimate Monthly Qty * Contract Period #of Months 2014-06-20
                        if (BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && CCPeriod != null)
                            FCBRSF_targetvol_9L = BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c * CCPeriod ;

                    }//vFinal PO End

                    //V0.0 PO
                    if (BRSF_List_temp.ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c == '0.0'){
                        BRSF_SBId_v0.add(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__c);

                        //Total Estimate volume in standard btl
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c != null)
                            v0Estimate_totalBtl += BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c * v0_CCPeriod;

                        //Total Contract volume in standard btl
                        if (BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Qty__c != null)
                            v0Contract_totalBtl += BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Qty__c * v0_CCPeriod;

                        //v0.0 investment CR12 Contract
                        if (BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Qty__c != null && v0_CCPeriod != null && BRSF_List_Temp.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!= null)
                            BRSF_CTD_Cost_contract += BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Qty__c * v0_CCPeriod * BRSF_List_Temp.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;

                        //PSF Table - Target Volume (Btl) = Estimate Monthly Qty * PSF Period #of Months 2014-06-19
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c != null && PSFPeriod != null)
                            BRSF_targetvol_Btl = BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c * PSFPeriod ;

                        //PSF Table - Target Volume (CR12) = Estimate Monthly Qty * PSF Period #of Months * Factor 2014-06-19
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c != null && PSFPeriod  != null && BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c != null)
                            BRSF_targetvol_CR12 = BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c * PSFPeriod * BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c;

                        //Add Total Target Volume (Btl)
                        TotalVolBtl.target_vol += BRSF_targetvol_Btl;

                        //Add Total Target Volume (CR12)
                        TotalVolCR12.target_vol += BRSF_targetvol_CR12;

                        //Add Contract Target to Brand Map
                        DataClass BRSF_Class = new DataClass();
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c != null)
                            BRSF_Class.target_vol = BRSF_targetvol_Btl;
                        BRSF_Class.actual_vol = 0;
                        BRSF_Class.achieverate= 0;

                        if (thisPR.ASI_CRM_CN_PSF_Start__c != null && thisPR.ASI_CRM_CN_PSF_Start__c != null){
                            if (PSF_map.containskey(sb_brand)){
                                PSF_map.get(sb_brand).target_vol += BRSF_targetvol_Btl;
                                if (PSF_map.get(sb_brand).target_vol != null && PSF_map.get(sb_brand).target_vol != 0
                                        && PSF_map.get(sb_brand).actual_vol != 0 && PSF_map.get(sb_brand).actual_vol != null)
                                    PSF_map.get(sb_brand).achieverate =  PSF_map.get(sb_brand).actual_vol / PSF_map.get(sb_brand).target_vol * 100;
                            }else{
                                BRSF_Class.target_vol = BRSF_targetvol_Btl;
                                PSF_map.put(sb_brand, BRSF_Class);
                            }
                        }

                        //CTD Volume CR12 * CCPeriod (for VOL %) Estimate
                        Vol12_temp = 0;
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c != null)
                            Vol12_temp = BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c ;
                        if (BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c != null)
                            Vol12_temp *= BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c;
                        if (v0_CCPeriod != null)
                            Vol12_temp *= v0_CCPeriod;
                        BRSF_CTD_CR12 += Vol12_temp;

                        //CTD Volume CR12 * v0_CCPeriod (for profit Shuttle) Contract
                        Vol12Contract_temp = 0;
                        if (BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Qty__c != null)
                            Vol12Contract_temp += BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Qty__c;
                        if (BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c != null)
                            Vol12Contract_temp *= BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c;
                        if (v0_CCPeriod != null)
                            Vol12Contract_temp *= v0_CCPeriod;
                        BRSF_CTD_CR12_contract += Vol12Contract_temp ;

                        //Last Payment Full Contract Table - Target Volume (9L) = Estimate Monthly Qty * Contract Period #of Months 2014-06-20
                        if (BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && v0_CCPeriod != null)
                            FCBRSF_targetvol_9L_v0 = BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c * v0_CCPeriod ;
                        if (FCBRSF_targetvol_9L_v0 != null)
                            VolumeData.v0_estimate += FCBRSF_targetvol_9L_v0;

                        //profit shuttle like table
                        //Total Volume 9L
                        if (BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null && CCPeriod != null)
                            VolumeData.v0_contract += BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c * v0_CCPeriod;

                        //(v0 ROI) Last Payment Full Contract Table - Target Volume (Btl) = Estimate Monthly Qty * Contract Period #of Months 2014-06-20
                        if (BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null)
                            FCBRSF_targetvol_Btl_v0 = BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c;

                        //Last Payment Full Contract Table - Target Volume (CR12) = Estimate Monthly Qty * Contract Period #of Months * Factor 2014-06-20
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c != null && v0_CCPeriod != null && BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c != null)
                            FCBRSF_targetvol_CR12_v0 = BRSF_List_temp.ASI_CRM_CN_Est_Monthly_Qty__c * v0_CCPeriod * BRSF_List_temp.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c;

                        //Add v0.0 Full Contract Total Target Volume (CR12) For Investment Calculation
                        TotalCR12_Volume_v0 += FCBRSF_targetvol_CR12_v0;

                        //v0.0 Estimate Cost
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Total__c != null)
                            v0_EstCost += BRSF_List_temp.ASI_CRM_CN_Est_Total__c ;

                        //v0 estimate Variable cost
                        if (BRSF_List_temp.ASI_CRM_CN_Est_Total__c != null){
                            VarExp.v0_estimate += BRSF_List_temp.ASI_CRM_CN_Est_Total__c;
                            tradeExp.v0_estimate += BRSF_List_temp.ASI_CRM_CN_Est_Total__c;
                        }

                        //v0 contract Variable cost
                        if (BRSF_List_temp.ASI_CRM_CN_Contract_Total__c != null){
                            VarExp.v0_contract += BRSF_List_temp.ASI_CRM_CN_Contract_Total__c;
                            tradeExp.v0_contract += BRSF_List_temp.ASI_CRM_CN_Contract_Total__c;
                        }

                        //v0.0 ROI Full Contract Estimate Vol (prepare to * Budget CM)
                        if (SubBrand_ROI_map_v0.containskey(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__c)){
                            SubBrand_ROI_map_v0.get(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__c).actual_vol += FCBRSF_targetvol_Btl_v0; //estimate volume
                            SubBrand_ROI_map_v0.get(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__c).target_vol += BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c ;
                        }else{
                            DataClass newDC1 = new DataClass();
                            newDC1.actualCM = 0;
                            newDC1.actualGS = 0;
                            newDC1.actual_vol = FCBRSF_targetvol_Btl_v0;
                            newDC1.target_vol = BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c ;
                            SubBrand_ROI_map_v0.put(BRSF_List_temp.ASI_CRM_CN_Sub_Brand__c, newDC1);
                        }

                        //Profit shuttle like table
                        if (lastpayment_sbgrade.containskey(sbGradeName)){
                            if (BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null)
                                lastpayment_sbgrade.get(sbGradeName).v0_contract += BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c * v0_CCPeriod;
                            if (BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null)
                                lastpayment_sbgrade.get(sbGradeName).v0_estimate += BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c * v0_CCPeriod;
                        }else{
                            DataClass newitem = new DataClass();
                            if (BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null)
                                newitem.v0_contract = BRSF_List_temp.ASI_CRM_CN_Contract_Monthly_Vol9L__c * v0_CCPeriod;
                            else
                                    newitem.v0_contract = 0;

                            if (BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null)
                                newitem.v0_estimate = BRSF_List_temp.ASI_CRM_CN_Estimate_Volume_9L_Month__c * v0_CCPeriod;
                            else
                                    newitem.v0_estimate = 0;
                            newitem.v1_actual = 0;
                            newitem.v0_con_gap = 0;
                            newitem.v0_est_gap = 0;
                            lastpayment_sbgrade.put(sbGradeName, newitem);
                        }

                    }//v0.0 PO end
                }
            }
            //query v0.0 estimate Cost
            list<ASI_CRM_Contract_Cost__c> v0_EstCostList = new list<ASI_CRM_Contract_Cost__c>();
            string thisPRv0Id;
            if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null)
                thisPRv0Id = thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
            else
                    thisPRv0Id = thisPR.ASI_TH_CRM_Contract__c;
            try{
                v0_EstCostList = [SELECT ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CN_Cost_Type__c,
                        ASI_CRM_CN_Contract_Amount__c
                FROM ASI_CRM_Contract_Cost__c
                WHERE ASI_CRM_CN_Contract__c = :thisPRv0Id];
            }catch(exception e){
                system.debug('Try v0_EstCostList failed: ' + e);
            }
            if (v0_EstCostList.size() > 0){
                for (ASI_CRM_Contract_Cost__c v0Costtemp : v0_EstCostList){
                    if (v0Costtemp.ASI_CRM_CN_Estimate_Amount__c != null){
                        v0_EstCost += v0Costtemp.ASI_CRM_CN_Estimate_Amount__c;
                        tradeExp.v0_estimate += v0Costtemp.ASI_CRM_CN_Estimate_Amount__c;
                        if (v0Costtemp.ASI_CRM_CN_Cost_Type__c == 'Fixed')
                            FixExp.v0_estimate += v0Costtemp.ASI_CRM_CN_Estimate_Amount__c;
                        if (v0Costtemp.ASI_CRM_CN_Cost_Type__c == 'Variable')
                            VarExp.v0_estimate += v0Costtemp.ASI_CRM_CN_Estimate_Amount__c;
                    }
                    if (v0Costtemp.ASI_CRM_CN_Contract_Amount__c != null){
                        BRSF_CTD_Cost_contract += v0Costtemp.ASI_CRM_CN_Contract_Amount__c;
                        tradeExp.v0_contract += v0Costtemp.ASI_CRM_CN_Contract_Amount__c;
                        if (v0Costtemp.ASI_CRM_CN_Cost_Type__c == 'Fixed')
                            FixExp.v0_contract += v0Costtemp.ASI_CRM_CN_Contract_Amount__c;
                        if (v0Costtemp.ASI_CRM_CN_Cost_Type__c == 'Variable')
                            VarExp.v0_contract += v0Costtemp.ASI_CRM_CN_Contract_Amount__c;
                    }
                }
            }
            //query Actual YTD CM for both V0.0 & VFinal
            //Added by Alan Wong (Elufa) 20150717
            ASI_TH_CRM_Contract__c Contractv0;
            date strStart;
            date strEnd;
            if (thisPRv0Id != null && thisPRv0Id != ''){
                Contractv0 = [SELECT ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c  FROM ASI_TH_CRM_Contract__c WHERE id = :thisPRv0Id];
            }
            if (Contractv0.ASI_CRM_CN_PO_Start_Date__c !=null ){
                strStart = Contractv0.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            }
            else if(thisPR.ASI_CRM_CN_PO_Start_Date__c != null){
                strStart = thisPR.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            }
            if (Contractv0.ASI_CRM_CN_PO_End_Date__c !=null ){
                strEnd = getEndDate(Contractv0.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
            }
            else if(thisPR.ASI_CRM_CN_PO_End_Date__c != null){
                strEnd = getEndDate(thisPR.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
            }
            //date strStart = thisPR.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            //date strEnd = getEndDate(thisPR.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
            //-- End --//

            //20170209 Elufa
            Date strStart2; Date strEnd2;
            if(strStart != null){ strStart2 = date.newInstance(strStart.addYears(-3).year(), 6, 30);}
            if(strEnd != null){ strEnd2 = date.newInstance(strEnd.addYears(1).year(), 6, 30);}
            Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
            //20170209 End

            /*
            try{
                BudgetCM_List_v0 = [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                                    ASI_CRM_CN_Month_End_Date__c, ASI_CRM_TYPE__c
                                    FROM ASI_CRM_CM_GS__c
                                    WHERE ASI_CRM_PRODUCTCODE__c IN :BRSF_SBId_v0 AND
                                    ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                    AND ((ASI_CRM_CN_Month_End_Date__c >= :strStart
                                          AND ASI_CRM_CN_Month_End_Date__c <= :strEnd)
                                         OR (ASI_CRM_CN_Month_End_Date__c >= : strStart2
                                             AND ASI_CRM_CN_Month_End_Date__c <= : strEnd2
                                             AND ASI_CRM_CN_Month__c = 6
                                            )
                                        )
                                    AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                                    AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != Null
                                    ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
            }catch(exception e){
                BudgetCM_List_v0 = new list<ASI_CRM_CM_GS__c>();
            }
            system.debug('BudgetCM_List_v0: ' + BudgetCM_List_v0);
            //get Budget YTD CM v0.0
            //if (BudgetCM_List_v0.size() > 0){
                */
            for (ASI_CRM_CM_GS__c ACM_v0_temp : [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                    ASI_CRM_CN_Month_End_Date__c, ASI_CRM_TYPE__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c IN :BRSF_SBId_v0 AND
            ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND ((ASI_CRM_CN_Month_End_Date__c >= :strStart
            AND ASI_CRM_CN_Month_End_Date__c <= :strEnd)
            OR (ASI_CRM_CN_Month_End_Date__c >= : strStart2
            AND ASI_CRM_CN_Month_End_Date__c <= : strEnd2
            AND ASI_CRM_CN_Month__c = 6
            )
            )
            AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
            AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != Null
            ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC])
            {
                string strkey;
                string subbrand_id;
                decimal BrsfVol;
                decimal BrsfTargetVol;
                decimal ActualCMperBtl;
                subbrand_id = ACM_v0_temp.ASI_CRM_PRODUCTCODE__c;
                strkey = string.valueof(ACM_v0_temp.ASI_CRM_CN_Month_End_Date__c) + subbrand_id;
                ActualCMperBtl = null;

                //20170209 Elufa
                if(ACM_v0_temp.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c + ACM_v0_temp.ASI_CRM_TYPE__c) && ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c != null && ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c != 0){
                    cmgsMap.put(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c + ACM_v0_temp.ASI_CRM_TYPE__c, ACM_v0_temp);
                }
                //20170209 End

                if (ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c != null)
                    ActualCMperBtl = ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c;

                //Estimate volume
                BrsfVol = 0;
                if (Subbrand_ROI_map_v0.containskey(subbrand_id)){
                    BrsfVol = Subbrand_ROI_map_v0.get(subbrand_id).actual_vol;
                }
                //Contract volume Added on 7-28-2014
                BrsfTargetVol = 0;
                if (Subbrand_ROI_map_v0.containskey(subbrand_id)){
                    BrsfTargetVol = Subbrand_ROI_map_v0.get(subbrand_id).target_vol;
                }

                //Budget CM
                if (ACM_v0_temp.ASI_CRM_TYPE__c == 'Budget CM'){
                    if (V0_ROI_newMap.containskey(strkey)){
                        if ((V0_ROI_newMap.get(strkey).actualCM == null || V0_ROI_newMap.get(strkey).actualCM == 0 )&& ActualCMperBtl != Null && ActualCMperBtl != 0)//20161111 Elufa added && ActualCMperBtl != Null && ActualCMperBtl != 0
                            V0_ROI_newMap.get(strkey).actualCM = ActualCMperBtl;
                        if (V0_ROI_newMap.get(strkey).actual_vol == null)
                            V0_ROI_newMap.get(strkey).actual_vol = BrsfVol;
                        if (V0_ROI_newMap.get(strkey).target_vol == null)
                            V0_ROI_newMap.get(strkey).target_vol = BrsfTargetVol;
                    }
                }
                //Budget GS
                if (ACM_v0_temp.ASI_CRM_TYPE__c == 'Budget GS'){
                    if (V0_ROI_newMap.containskey(strkey)){
                        if((V0_ROI_newMap.get(strkey).actualGS == null || V0_ROI_newMap.get(strkey).actualGS == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0)//20161111 Elufa added && ActualCMperBtl != Null && ActualCMperBtl != 0
                            V0_ROI_newMap.get(strkey).actualGS = ActualCMperBtl;
                        if (V0_ROI_newMap.get(strkey).target_vol == null)
                            V0_ROI_newMap.get(strkey).target_vol = BrsfTargetVol;
                        if (V0_ROI_newMap.get(strkey).actual_vol == null)
                            V0_ROI_newMap.get(strkey).actual_vol = BrsfVol;
                    }
                }

                if (V0_ROI_newMap.containskey(strkey)){
                    if (V0_ROI_newMap.get(strkey).latestbudgetCM == null || V0_ROI_newMap.get(strkey).latestbudgetCM == 0)
                        if(RegionSubBrandCM_Map.containsKey(ACM_v0_temp.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(ACM_v0_temp.ASI_CRM_Region__c).containsKey(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c)){
                            V0_ROI_newMap.get(strkey).latestbudgetCM = RegionSubBrandCM_Map.get(ACM_v0_temp.ASI_CRM_Region__c).get(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c);
                        }
                }
            }

            String strRegion = thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            //20170209 Elufa to replace null value with latest CMGS data
            for(String key : V0_ROI_newMap.keySet()){
                if(V0_ROI_newMap.get(key).actualCM == Null || V0_ROI_newMap.get(key).actualCM == 0 || V0_ROI_newMap.get(key).actualGS == Null || V0_ROI_newMap.get(key).actualGS == 0 || V0_ROI_newMap.get(key).latestbudgetCM == Null || V0_ROI_newMap.get(key).latestbudgetCM == 0){
                    if((V0_ROI_newMap.get(key).actualCM == Null || V0_ROI_newMap.get(key).actualCM == 0) && cmgsMap.containsKey(V0_ROI_newMap.get(key).sbid + 'Budget CM')){
                        ASI_CRM_CM_GS__c cmgs = cmgsMap.get(V0_ROI_newMap.get(key).sbid + 'Budget CM');

                        V0_ROI_newMap.get(key).actualCM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                    }

                    if((V0_ROI_newMap.get(key).actualGS == Null || V0_ROI_newMap.get(key).actualGS == 0) && cmgsMap.containsKey(V0_ROI_newMap.get(key).sbid + 'Budget GS')){
                        ASI_CRM_CM_GS__c cmgs = cmgsMap.get(V0_ROI_newMap.get(key).sbid + 'Budget GS');

                        V0_ROI_newMap.get(key).actualGS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                    }

                    if(V0_ROI_newMap.get(key).latestBudgetCM == Null || V0_ROI_newMap.get(key).latestBudgetCM == 0){
                        if(RegionSubBrandCM_Map.containsKey(strRegion) && RegionSubBrandCM_Map.get(strRegion).containsKey(V0_ROI_newMap.get(key).sbid))
                            V0_ROI_newMap.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(strRegion).get(V0_ROI_newMap.get(key).sbid);
                    }
                }

                if(V0_ROI_newMap.get(key).actual_vol == null && Subbrand_ROI_map_v0.containsKey(V0_ROI_newMap.get(key).sbid))
                    V0_ROI_newMap.get(key).actual_vol = Subbrand_ROI_map_v0.get(V0_ROI_newMap.get(key).sbid).actual_vol;
                if(V0_ROI_newMap.get(key).target_vol == null && Subbrand_ROI_map_v0.containsKey(V0_ROI_newMap.get(key).sbid))
                    V0_ROI_newMap.get(key).target_vol = Subbrand_ROI_map_v0.get(V0_ROI_newMap.get(key).sbid).target_vol;
            }
            //20170209
            // }
            //Add Covered outlet id
            try{
                CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                FROM ASI_CRM_CN_Covered_Outlet__c
                WHERE ASI_CRM_CN_Contract__c = :thisPR.ASI_TH_CRM_Contract__c];
            }catch(exception e){
                CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
            }
            set<id> AllOutlet = new set<id>();
            // Added by Alan Wong (Elufa) 20150629
            ASI_TH_CRM_PaymentRequest__c tempPR = [SELECT id, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :thisPR.id];
            if (tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
                AllOutlet.add(thisPR.ASI_CRM_CN_OutletWS__c);
            }
            if (tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
                if (CoveredOutlet.size() > 0){
                    for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                        AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                    }
                }
            }
            // -- End -- //
            date TillEnd = getEndDate(FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));

            // try{
                //query Actual Sub Brand Volume Data (PSF Period dates & BRSF Sub brands)
                // SB_Vol_List = [SELECT ASI_CRM_T1_Depletion_Std_Billing__c, ASI_CRM_T1_Depletion_CR12__c,
                //         ASI_CRM_T2_Depletion_Std_Billing__c, ASI_CRM_T2_Depletion_CR12__c,
                //         ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c,
                //         ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,
                //         ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,
                //         ASI_CRM_PR_Direct__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name,
                //         ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                //         ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                //         ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                //         ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                //         ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c
                // FROM ASI_CRM_Subbrand_Volume__c
                // WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PO_Start_Date__c
                // AND ASI_CRM_End_Date__c <= :TillEnd
                // AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                // AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false];
                //20170118 Elufa Support
            // }catch(exception e){
            //     SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c >();
            // }
            map<date, decimal> V1_Period_map = checkFYDayPeriod(thisPR.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_CRM_CN_PO_End_Date__c);
            map<string, DataClass> v1_ROI_newMap = new map<string, DataClass>();
            set<id> v1_sbid_set = new set<id>();



            // if (SB_Vol_List.size() > 0){
                for (ASI_CRM_Subbrand_Volume__c sbtemp : [SELECT ASI_CRM_T1_Depletion_Std_Billing__c, ASI_CRM_T1_Depletion_CR12__c,
                        ASI_CRM_T2_Depletion_Std_Billing__c, ASI_CRM_T2_Depletion_CR12__c,
                        ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c,
                        ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,
                        ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,
                        ASI_CRM_PR_Direct__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name,
                        ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                        ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                        ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c
                FROM ASI_CRM_Subbrand_Volume__c
                WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PO_Start_Date__c
                AND ASI_CRM_End_Date__c <= :TillEnd
                AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false] ){
                    v1_sbid_set.add(sbtemp.ASI_CRM_Subbrand__c);
                }
            // }
            //V1 Contract Period
            if (V1_Period_map.size() > 0){
                string strkey;
                for (date v1temp : V1_Period_map.keyset()){
                    if (v1_sbid_set.size() > 0){
                        for (id sbtemp : v1_sbid_set){
                            strkey = string.valueof(v1temp) + sbtemp;
                            DataClass newitem = new DataClass();
                            newitem.strPeriod = V1_Period_map.get(v1temp);
                            newitem.sbid = sbtemp;
                            newitem.year = string.valueof(v1temp.year());
                            if (!v1_ROI_newMap.containskey(strkey)){
                                v1_ROI_newMap.put(strkey, newitem);
                            }
                        }
                    }
                }
            }
            system.debug(v1_ROI_newMap);
            date strV1End = FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN');
            /*
            try{
                ActualCM_List = [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                                 ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_TYPE__c
                                 FROM ASI_CRM_CM_GS__c
                                 WHERE ASI_CRM_PRODUCTCODE__c IN :v1_sbid_set
                                 AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                 AND ASI_CRM_CN_Month_End_Date__c >= :strStart
                                 AND ASI_CRM_CN_Month_End_Date__c <= :strV1End
                                 AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
                                 AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0
                                 ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
            }catch(exception e){
                ActualCM_List = new list<ASI_CRM_CM_GS__c>();
            }
            */
            system.debug('CutoffDate VfinalROI: ' + strV1End);


            //get Actual YTD CM vFinal
            decimal ActualCMperBtl;
            // if (ActualCM_List.size() > 0){

            for (ASI_CRM_CM_GS__c ACM_temp : [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                    ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_TYPE__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c IN :v1_sbid_set
            AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND ASI_CRM_CN_Month_End_Date__c >= :strStart
            AND ASI_CRM_CN_Month_End_Date__c <= :strV1End
            AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
            AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0
            ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC])
            {
                string strkey;
                string subbrand_id;
                string lastestkey;

                subbrand_id = ACM_temp.ASI_CRM_PRODUCTCODE__c;
                strkey = string.valueof(ACM_temp.ASI_CRM_CN_Month_End_Date__c) + subbrand_id;
                system.debug(strkey);
                ActualCMperBtl = null;
                if (ACM_temp.ASI_CRM_CM_GS_per_9L__c != null)
                    ActualCMperBtl = ACM_temp.ASI_CRM_CM_GS_per_9L__c;
                lastestkey = subbrand_id;
                if (ACM_temp.ASI_CRM_TYPE__c == 'YTD CM'){
                    if (!ActualCM_v1_map.containskey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0)//20161111 Elufa added && ActualCMperBtl != Null && ActualCMperBtl != 0
                        ActualCM_v1_map.put(lastestkey, ActualCMperBtl);
                    if (v1_ROI_newMap.containskey(strkey)){
                        if ((v1_ROI_newMap.get(strkey).actualCM == null || v1_ROI_newMap.get(strkey).actualCM == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0)//20161111 Elufa added && ActualCMperBtl != Null && ActualCMperBtl != 0
                            v1_ROI_newMap.get(strkey).actualCM = ActualCMperBtl;
                        V1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                    }
                    system.debug(ActualCMperBtl);
                }
                if (ACM_temp.ASI_CRM_TYPE__c == 'YTD GS'){
                    if (!ActualGS_v1_map.containskey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0)//20161111 Elufa added && ActualCMperBtl != Null && ActualCMperBtl != 0
                        ActualGS_v1_map.put(lastestkey, ActualCMperBtl);
                    if (v1_ROI_newMap.containskey(strkey)){
                        if ((v1_ROI_newMap.get(strkey).actualGS == null || v1_ROI_newMap.get(strkey).actualGS == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0)//20161111 Elufa added && ActualCMperBtl != Null && ActualCMperBtl != 0
                            v1_ROI_newMap.get(strkey).actualGS = ActualCMperBtl;
                        V1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                    }
                    system.debug(ActualCMperBtl);
                }

                if (!lbcm_v1_map.containskey(lastestkey))
                    if (RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_Region__c).containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c)) {
                        lbcm_v1_map.put(lastestkey, RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_Region__c).get(ACM_temp.ASI_CRM_PRODUCTCODE__c));
                    }
                if (v1_ROI_newMap.containskey(strkey)){
                    if (v1_ROI_newMap.get(strkey).latestbudgetCM == null || v1_ROI_newMap.get(strkey).latestbudgetCM == 0)//20170209 Elufa added v1_ROI_newMap.get(strkey).latestbudgetCM == 0
                        if (RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_Region__c).containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c)) {
                            v1_ROI_newMap.get(strkey).latestbudgetCM = RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_Region__c).get(ACM_temp.ASI_CRM_PRODUCTCODE__c);
                        }
                    V1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                }
                system.debug(ACM_temp.ASI_CRM_TYPE__c +':'+ ActualCMperBtl);
            }
            // }
            //get & map Actual Sub Brand Volume
            decimal MarginUseTotalVol_std = 0;
            decimal ActualIntakeTotal = 0;
            // if (SB_Vol_List.size() > 0){
                string sb_vol_brand;
                string strkey;
                decimal PSF_actual_vol = 0;
                decimal PSF_actual_vol_CR12 = 0;
                decimal strActualCM_v1 = 1;
                decimal strGreenCap = 0;
                decimal strTotalIntake = 0;
                decimal FC_actualvol_btl = 0; //Full Contract
                decimal FCBRSF_targetvol_CR12 = 0; //Full Contract vFinal investment
                decimal Vol_CR12_1 =0; //All Payment Period
                date endDate;
                decimal ActualEmpBtl = 0; //for calculating bc%
                ActualIntakeTotal = 0;//for calculating bc%

                //20151204 Ben @ Elufa System
                Decimal totalOffTake = 0;
                //End

                for (ASI_CRM_Subbrand_Volume__c  SB_Vol_temp : [SELECT ASI_CRM_T1_Depletion_Std_Billing__c, ASI_CRM_T1_Depletion_CR12__c,
                        ASI_CRM_T2_Depletion_Std_Billing__c, ASI_CRM_T2_Depletion_CR12__c,
                        ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c,
                        ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,
                        ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,
                        ASI_CRM_PR_Direct__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name,
                        ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                        ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                        ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c
                FROM ASI_CRM_Subbrand_Volume__c
                WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PO_Start_Date__c
                AND ASI_CRM_End_Date__c <= :TillEnd
                AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false]){
                    endDate = FYConversion(SB_Vol_temp.ASI_CRM_End_Date__c);
                    strkey = string.valueof(endDate) + SB_Vol_temp.ASI_CRM_Subbrand__c;
                    //2014-06-19 PSF MIN & MAX Date period
                    /************************** PSF SECTION **************************/
                    if (SB_Vol_temp.ASI_CRM_End_Date__c >= thisPR.ASI_CRM_CN_PSF_Start__c && SB_Vol_temp.ASI_CRM_End_Date__c <= thisPR.ASI_CRM_CN_PSF_End__c){

                        if (SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c != null){
                            sb_vol_brand = SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name;
                            if (SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c != null)
                                sb_vol_brand += ' / ' + SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c;
                        }else{
                            sb_Vol_brand = 'Not Specified / 未指定';
                        }

                        //Define Target Volume value & Sub brand - Brand name
                        DataClass BRSF_Class = new DataClass();
                        BRSF_Class.target_vol = 0;
                        BRSF_Class.actual_vol = 0;
                        BRSF_Class.achieverate = 0;
                        //Actual Volume (Btl) = T1_Depletion + T2_Depletion + PR_Direct
                        PSF_actual_vol = 0 ;
                        if (SB_Vol_temp.ASI_CRM_T1_Depletion_Std_Billing__c != null)
                            PSF_actual_vol = SB_Vol_temp.ASI_CRM_T1_Depletion_Std_Billing__c;
                        if (SB_Vol_temp.ASI_CRM_T2_Depletion_Std_Billing__c != null)
                            PSF_actual_vol += SB_Vol_temp.ASI_CRM_T2_Depletion_Std_Billing__c;
                        if (SB_Vol_temp.ASI_CRM_PR_Direct_Std_Billing__c!= null)
                            PSF_actual_vol += SB_Vol_temp.ASI_CRM_PR_Direct_Std_Billing__c;

                        //Actual Volume (CR12) = T1_Depletion + T2_Depletion + PR_Direct
                        PSF_actual_vol_CR12 = 0;
                        if (SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c != null)
                            PSF_actual_vol_CR12 = SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c;
                        if (SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c != null)
                            PSF_actual_vol_CR12 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c;
                        if (SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c != null)
                            PSF_actual_vol_CR12 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c;

                        //Add Actual Volume to Brand Map
                        if (PSF_map.containskey(sb_vol_brand)){
                            PSF_map.get(sb_vol_brand).actual_vol += PSF_actual_vol;
                            if (PSF_map.get(sb_vol_brand).target_vol != null && PSF_map.get(sb_vol_brand).target_vol != 0
                                    && PSF_map.get(sb_vol_brand).actual_vol != 0 && PSF_map.get(sb_vol_brand).actual_vol != null)
                                PSF_map.get(sb_vol_brand).achieverate =  PSF_map.get(sb_vol_brand).actual_vol / PSF_map.get(sb_vol_brand).target_vol * 100;
                        }else{
                            BRSF_Class.actual_vol = PSF_actual_vol;
                            PSF_map.put(sb_vol_brand, BRSF_Class);
                        }

                        //Add Total Target Volume (Btl)
                        TotalVolBtl.actual_vol += PSF_actual_vol ;

                        //Total Target Volume (Btl) Achieve Rate %
                        if (TotalVolBtl.target_vol != null && TotalVolBtl.target_vol != 0 && TotalVolBtl.actual_vol != null && TotalVolBtl.actual_vol != 0)
                            TotalVolBtl.achieverate = TotalVolBtl.actual_vol / TotalVolBtl.target_vol * 100;

                        //Add Total Target Volume (CR12)
                        TotalVolCR12.actual_vol += PSF_actual_vol_CR12;
                        //Total Target Volume (CR12) Achieve Rate %
                        if (TotalVolCR12.target_vol != null && TotalVolCR12.target_vol != 0 && TotalVolCR12.actual_vol != null && TotalVolCR12.actual_vol != 0)
                            TotalVolCR12.achieverate = TotalVolCR12.actual_vol / TotalVolCR12.target_vol * 100;
                    }
                    /************************** PSF SECTION END **************************/
                    /************************** BRSF SECTION **************************/
                    if (SB_Vol_temp.ASI_CRM_End_Date__c >= thisPR.ASI_CRM_CN_BRSF_Start_Date__c && SB_Vol_temp.ASI_CRM_End_Date__c <= thisPR.ASI_CRM_CN_BRSF_End_Date__c){

                        //Payment BC %
                        if (SB_Vol_temp.ASI_CRM_Green_Cap_Std_Billing__c  != null)
                            strGreenCap += SB_Vol_temp.ASI_CRM_Green_Cap_Std_Billing__c ;
                        if (SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Billing__c != null)
                            strGreenCap += SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Billing__c ;
                        //Total Intake within BRSF Period
                        if (SB_Vol_temp.ASI_CRM_T1_Depletion_Std_Billing__c != null)
                            strTotalIntake += SB_Vol_temp.ASI_CRM_T1_Depletion_Std_Billing__c;
                        if (SB_Vol_temp.ASI_CRM_T2_Depletion_Std_Billing__c != null)
                            strTotalIntake += SB_Vol_temp.ASI_CRM_T2_Depletion_Std_Billing__c;
                        if (SB_Vol_temp.ASI_CRM_PR_Direct_Std_Billing__c != null)
                            strTotalIntake += SB_Vol_temp.ASI_CRM_PR_Direct_Std_Billing__c;
                        //20151204 Ben @ Elufa System
                        if(SB_Vol_temp.ASI_CRM_Offtake_Std_Billing__c != NULL)
                            totalOffTake += SB_Vol_temp.ASI_CRM_Offtake_Std_Billing__c;
                        //End
                    }
                    /************************** BRSF SECTION END **************************/
                    /************************ Full Contract Period ************************/

                    //Actual Volume (9L) = T1_Depletion + T2_Depletion + PR_Direct
                    FC_actualvol_btl = 0;
                    if (SB_Vol_temp.ASI_CRM_T1_Depletion__c!= null)
                        FC_actualvol_btl = SB_Vol_temp.ASI_CRM_T1_Depletion__c;
                    if (SB_Vol_temp.ASI_CRM_T2_Depletion__c!= null)
                        FC_actualvol_btl += SB_Vol_temp.ASI_CRM_T2_Depletion__c;
                    if (SB_Vol_temp.ASI_CRM_PR_Direct__c!= null)
                        FC_actualvol_btl += SB_Vol_temp.ASI_CRM_PR_Direct__c;
                    FCBRSF_targetvol_CR12 = 0;
                    if (SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c != null)
                        FCBRSF_targetvol_CR12  = SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c;
                    if (SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c != null)
                        FCBRSF_targetvol_CR12 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c;
                    if (SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c != null)
                        FCBRSF_targetvol_CR12 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c;
                    if (V1_ROI_newMap.containskey(strkey)){
                        system.debug(strkey);
                        if (V1_ROI_newMap.get(strkey).actual_vol != null)
                            V1_ROI_newMap.get(strkey).actual_vol += FC_actualvol_btl;
                        else
                                V1_ROI_newMap.get(strkey).actual_vol = FC_actualvol_btl;
                    }else{
                        DataClass newDC1 = new DataClass();
                        newDC1.actual_vol = FC_actualvol_btl;
                        newDC1.sbname = SB_Vol_temp.ASI_CRM_Subbrand__r.Name;
                        V1_ROI_newMap.put(strkey, newDC1);
                    }
                    //Last Payment Actual Performance 2014-07-27
                    VolumeData.v1_actual += FC_actualvol_btl;
                    if (SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                        if (SubbrandGroup.containskey(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                            sbGradeName = SubbrandGroup.get(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                        }else{
                            sbGradeName = 'Not Specified / 未指定';
                        }
                    }else{
                        sbGradeName = 'Not Specified / 未指定';
                    }
                    if (lastpayment_sbgrade.containskey(sbGradeName)){
                        lastpayment_sbgrade.get(sbGradeName).v1_actual += FC_actualvol_btl;
                    }else{
                        DataClass newitem = new DataClass();
                        newitem.v1_actual = FC_actualvol_btl;
                        newitem.v0_estimate = 0;
                        newitem.v0_contract= 0;
                        newitem.v0_con_gap = 0;
                        newitem.v0_est_gap = 0;
                        lastpayment_sbgrade.put(sbGradeName, newitem);
                    }


                    //Add VFinal Full Contract Total Target Volume (CR12) For Investment Calculation
                    TotalCR12_Volume_v1 += FCBRSF_targetvol_CR12;

                    //profit shuttle like table (standard btl) for vFinal actual performance margin per btl
                    MarginUseTotalVol_std = 0;
                    if (SB_Vol_temp.ASI_CRM_PR_Direct_STD__c != null)
                        MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_PR_Direct_STD__c;
                    if (SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c != null)
                        MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c;
                    if (SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c != null)
                        MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c;

                    ActualIntakeTotal += MarginUseTotalVol_std;

                    /************************ Full Contract Period END ************************/
                    /************************** ALL Payment SECTION **************************/
                    //system.debug('AllPaymentPeriod inside SB_VOL_List: ' + AllPaymentPeriod );
                    //if (SB_Vol_temp.ASI_CRM_End_Date__c <= AllPaymentPeriod){
                    if (SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c != null)
                        Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c;
                    if (SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c != null)
                        Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c;
                    if (SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c != null)
                        Vol_CR12_1 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c;
                    //}
                    /************************** ALL Payment SECTION END **************************/

                    //Added by Twinkle 20141204 - BC % for Actual Performance
                    if (SB_Vol_temp.ASI_CRM_Green_Cap_STD__c != null && SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Btl__c != null){
                        ActualEmpBtl += (SB_Vol_temp.ASI_CRM_Green_Cap_STD__c + SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Btl__c);
                    }
                }

                //20151216 Ben @ Elufa System
                if(totalOffTake > 0 && strTotalIntake > 0)
                    totalOffTakeVSInTake = (totalOffTake/strTotalIntake)*100;
                if(totalOffTake > 0 && strGreenCap > 0)
                    totalOffTakeVSBC = (totalOffTake/strGreenCap)*100;
                //20151216 End

                if(ActualEmpBtl != null && ActualEmpBtl != 0 && ActualIntakeTotal != null && ActualIntakeTotal != 0)
                    intActualBCRate = (ActualEmpBtl / ActualIntakeTotal)*100;
                system.debug('Bottle Collected: ' + ActualEmpBtl + ' Intake: ' + ActualIntakeTotal + ' BC Rate: ' + intActualBCRate);
                //End by Twinkle 20141204

                if (strGreenCap != 0 && strTotalIntake != 0)
                    PaymentBCRate = strGreenCap / strTotalIntake *100;
                else
                        PaymentBCRate = 0;
                //Other - VOL % (CR12)
                if (Vol_CR12_1  != null && Vol_CR12_1  != 0 && BRSF_CTD_CR12 != null && BRSF_CTD_CR12 != 0)
                    Other_VOL_CR12 =  Vol_CR12_1 / BRSF_CTD_CR12  * 100;
                system.debug('Vol_CR12_1:'+Vol_CR12_1+',BRSF_CTD_CR12:'+BRSF_CTD_CR12+',Other_VOL_CR12:'+Other_VOL_CR12);
            // }

            //Query all payment request with vFinal contract
            list<ASI_TH_CRM_PaymentRequest__c> allPR = new list<ASI_TH_CRM_PaymentRequest__c>();
            try{
                allPR = [SELECT ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                        ASI_CRM_CN_Total_Other_Amount__c, ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c
                FROM ASI_TH_CRM_PaymentRequest__c
                WHERE ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c
                AND (id = :thisPR.id OR ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted'
                OR ASI_TH_CRM_Status__c = 'Paid')];
            }catch(exception e){

            }
            decimal allPaymentTotal = 0;

            //Sum up previous payments amounts
            set<id> AllPRId = new set<id>();
            if (allPR.size() > 0){

                for (ASI_TH_CRM_PaymentRequest__c allPR_temp : allPR){
                    AllPRid.add(allPR_temp.id);
                    if (allPR_temp.ASI_CRM_CN_Total_Payment__c != null){
                        allPaymentTotal += allPR_temp.ASI_CRM_CN_Total_Payment__c;
                        //tradeExp.v1_actual += allPR_temp.ASI_CRM_CN_Total_Payment__c;
                    }
                }
            }
            tradeExp.v1_actual = allPaymentTotal ;

            decimal ContractCost;
            ContractCost = thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c;
            //Payment Speed %
            if (v0_EstCost != null && v0_EstCost !=0 && allPaymentTotal != null && allPaymentTotal != 0){
                //Updated by Twinkle 20141204
                PaymentSpeed = allPaymentTotal / v0_EstCost * 100;
            }
            system.debug('Payment Speed %: ' + allPaymentTotal + ' / ' + ContractCost + ' * 100');
            /************************** ALL Payment END **************************/

            //Total Investment per Btl V0.0
            if (v0_EstCost != null && v0_EstCost != 0 && TotalCR12_Volume_v0 != null && TotalCR12_Volume_v0 != 0)
                Investment_CR12.v0 = v0_EstCost / TotalCR12_Volume_v0;

            //Total Investment per Btl VFinal Actual
            if (allPaymentTotal != null && allPaymentTotal != 0 && TotalCR12_Volume_v1 != null && TotalCR12_Volume_v1 != 0)
                Investment_CR12.v1 = allPaymentTotal / TotalCR12_Volume_v1;


            //Total Investment per Btl v0.0 Contract (Contract Cost (all BRSF + Variable + fixed cost) / BRSF Contract Volume)
            if (BRSF_CTD_Cost_contract != null && BRSF_CTD_Cost_contract != 0 && BRSF_CTD_CR12_contract != null && BRSF_CTD_CR12_contract !=0)
                Investment_CR12.v0_contract = BRSF_CTD_Cost_contract / BRSF_CTD_CR12_contract;

            //Total Investment per Btl GAP Estimate vs Actual
            if (Investment_CR12.v0 != null && Investment_CR12.v0 != 0 && Investment_CR12.v1 != null && Investment_CR12.v1 != 0)
                Investment_CR12.v0_est_gap = (Investment_CR12.v1 - Investment_CR12.v0) / Investment_CR12.v0 * 100;

            //Total Investment per Btl GAP Estimate vs Actual
            if (Investment_CR12.v0_contract != null && Investment_CR12.v0_contract != 0 && Investment_CR12.v1 != null && Investment_CR12.v1 != 0)
                Investment_CR12.v0_con_gap = (Investment_CR12.v1 - Investment_CR12.v0_contract) / Investment_CR12.v0_contract *100;

            //V0.0 ROI Estimate
            if (V0_ROI_newMap.size() > 0){
                decimal totalsb_cm_v0 = 0;
                decimal totalsb_gs_v0 = 0;
                decimal totalsb_cm_v0_contract = 0;
                decimal totalsb_gs_v0_contract = 0;
                decimal totalsb_lbcm_v0_contract = 0; // Added by Alan Wong (Elufa) 20150623
                decimal totalsb_lbcm_v0 = 0; // Added by Alan Wong (Elufa) 20150623
                for (DataClass sb_v0 : V0_ROI_newMap.values()){
                    //estimate volume * budget cm
                    if (sb_v0.actual_vol != null && sb_v0.strPeriod != null && sb_v0.actualCM != null){
                        totalsb_cm_v0 += sb_v0.actual_vol * sb_v0.actualCM * sb_v0.strPeriod;
                    }
                    //estimate volume * budget gs
                    if (sb_v0.actual_vol != null && sb_v0.strPeriod != null && sb_v0.actualGS != null){
                        totalsb_gs_v0 += sb_v0.actual_vol * sb_v0.actualGS * sb_v0.strPeriod;
                    }
                    //contract volume * budget cm
                    if (sb_v0.target_vol != null && sb_v0.strPeriod != null && sb_v0.actualCM != null){
                        totalsb_cm_v0_contract += sb_v0.target_vol * sb_v0.actualCM * sb_v0.strPeriod;
                    }
                    //contract volume * budget gs
                    if (sb_v0.target_vol != null && sb_v0.strPeriod != null && sb_v0.actualGS != null){
                        totalsb_gs_v0_contract += sb_v0.target_vol * sb_v0.actualGS * sb_v0.strPeriod;
                    }
                    // Added by Alan Wong (Elufa) 20150623
                    // contract volume * latest budget cm
                    if (sb_v0.target_vol != null && sb_v0.strPeriod != null && sb_v0.latestbudgetCM != null){
                        totalsb_lbcm_v0_contract += sb_v0.target_vol * sb_v0.latestbudgetCM * sb_v0.strPeriod;
                    }
                    //estimate volume * budget cm
                    if (sb_v0.actual_vol != null && sb_v0.strPeriod != null && sb_v0.latestbudgetCM != null){
                        totalsb_lbcm_v0 += sb_v0.actual_vol * sb_v0.latestbudgetCM * sb_v0.strPeriod;
                    }
                    system.debug('totalsb_lbcm_v0_contract:::' + sb_v0.target_vol + ' * ' + sb_v0.latestbudgetCM + ' * ' + sb_v0.strPeriod);
                    system.debug('totalsb_lbcm_v0:::' + sb_v0.actual_vol + ' * ' + sb_v0.latestbudgetCM + ' * ' + sb_v0.strPeriod);
                    system.debug('sb_v0.actualCM:::' + sb_v0.actualCM);
                    system.debug('sb_v0.actualGS:::' + sb_v0.actualGS);
                    // -- End -- //
                }
                //v0.0 Estimate Gross Sales %
                if (totalsb_gs_v0 != null && totalsb_gs_v0 != 0 && tradeExp.v0_estimate != 0 && tradeExp.v0_estimate != null)
                    GrossSales.v0_estimate = tradeExp.v0_estimate / totalsb_gs_v0 * 100;
                //v0.0 Contract Gross Sales %
                if (totalsb_gs_v0_contract != null && totalsb_gs_v0_contract != 0 && tradeExp.v0_contract != 0 && tradeExp.v0_contract != null)
                    GrossSales.v0_contract = tradeExp.v0_contract / totalsb_gs_v0_contract * 100;
                system.debug('GrossSales.v0_contract = ' + tradeExp.v0_contract + ' / ' + totalsb_gs_v0);
                //v0.0 estimate Margin AP
                if (tradeExp.v0_estimate != null && totalsb_cm_v0 != null)
                    MarginAP.v0_estimate = totalsb_cm_v0 - tradeExp.v0_estimate;

                //v0.0 contract Margin AP
                if (tradeExp.v0_contract != null && totalsb_cm_v0_contract != null)
                    MarginAP.v0_contract = totalsb_cm_v0_contract - tradeExp.v0_contract;

                //v0.0 estimate Margin per btl
                if (v0Estimate_totalBtl != null && v0Estimate_totalBtl != 0 && MarginAP.v0_estimate != null && MarginAP.v0_estimate != 0)
                    MarginperBtl.v0_estimate = MarginAP.v0_estimate / v0Estimate_totalBtl;

                //v0.0 contract Margin per btl
                if (v0Contract_totalBtl != null && v0Contract_totalBtl != 0 && MarginAP.v0_contract != null && MarginAP.v0_contract != 0)
                    MarginperBtl.v0_contract = MarginAP.v0_contract / v0Contract_totalBtl ;

                //v0.0 estimate ROI
                if (v0_EstCost != 0 && v0_EstCost != null && totalsb_cm_v0 != null && totalsb_cm_v0 != 0){
                    vALLROI.v0 = totalsb_cm_v0 / v0_EstCost;
                    vALLROI.v0_estimate = totalsb_cm_v0 / v0_EstCost;
                }
                system.debug('vALLROI.v0_contract: ' + totalsb_cm_v0_contract + ' / ' + tradeExp.v0_contract);
                system.debug('v0.0 Estimate ROI Total: ' + totalsb_cm_v0  + ' / ' + v0_EstCost);

                //v0.0 contract ROI
                if (tradeExp.v0_contract != 0 && tradeExp.v0_contract != null && totalsb_cm_v0_contract != null && totalsb_cm_v0_contract != 0){
                    vALLROI.v0_contract = totalsb_cm_v0_contract / tradeExp.v0_contract;
                }

                // Added by Alan Wong (elufa) 20150623
                // v0.0 Pro-Forma ROI
                if (tradeExp.v0_contract != 0 && tradeExp.v0_contract != null && totalsb_lbcm_v0_contract != null && totalsb_lbcm_v0_contract != 0){
                    vProFormaROI.v0_contract = totalsb_lbcm_v0_contract / tradeExp.v0_contract;
                }
                //v0.0 Pro-Forma estimate ROI
                if (v0_EstCost != 0 && v0_EstCost != null && totalsb_lbcm_v0 != null && totalsb_lbcm_v0 != 0){
                    vProFormaROI.v0_estimate = totalsb_lbcm_v0 / v0_EstCost;
                }
                // -- End -- //

            }
            //VFinal ROI Actual Performance
            if (V1_ROI_newMap.size() > 0){
                decimal totalsb_cm_v1 = 0;
                decimal totalsb_gs_v1 = 0;
                decimal actualcm;
                decimal totalsb_cm_v1_temp = 0;
                integer tilldateperiod;
                decimal actualgs;
                decimal totalsb_lbcm_v1 = 0; // Added by Alan Wong (Elufa) 20150623
                decimal lbcm; // Added by Alan Wong (Elufa) 20150623
                for (DataClass sb_v1 : V1_ROI_newMap.values()){
                    system.debug(sb_v1);
                    actualcm = null;
                    if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                        actualcm = sb_v1.actualCM;
                    }else if (ActualCM_v1_map.containskey(sb_v1.sbid)){
                        actualcm = ActualCM_v1_map.get(sb_v1.sbid);
                    }
                    if (sb_v1.actual_vol != null && actualcm != null){
                        totalsb_cm_v1 += sb_v1.actual_vol * actualcm;
                        system.debug('vFinal ROI item: ' + sb_v1.sbname + ': ' + sb_v1.actual_vol + ' * ' + actualcm);
                    }
                    // Added by Alan Wong (Elufa) 20150623
                    lbcm = null;
                    if (sb_v1.actualCM != null){
                        lbcm = sb_v1.latestbudgetCM;
                    }else if (lbcm_v1_map.containskey(sb_v1.sbid)){
                        lbcm = lbcm_v1_map.get(sb_v1.sbid);
                    }
                    if (sb_v1.actual_vol != null && lbcm != null){
                        totalsb_lbcm_v1 += sb_v1.actual_vol * lbcm;
                    }
                    // -- End -- //
                    actualgs = null;
                    if (sb_v1.actualGS != null){
                        actualgs = sb_v1.actualGS;
                    }else if (ActualGS_v1_map.containskey(/*sb_v1.year +*/ sb_v1.sbid)){
                        actualgs = ActualGS_v1_map.get(/*sb_v1.year +*/ sb_v1.sbid);
                    }
                    if (sb_v1.actual_vol != null && actualgs != null){
                        totalsb_gs_v1 += sb_v1.actual_vol * actualgs;
                        system.debug('vFinal ROI item: ' + sb_v1.actual_vol + ' * ' + actualgs);
                    }
                    system.debug('SB GS: ' + sb_v1.sbid + ' '+ sb_v1.actual_vol + ' * ' + actualgs + ' = ' + totalsb_gs_v1);
                    system.debug('SB CM: ' + sb_v1.sbid + ' '+ sb_v1.actual_vol + ' * ' + actualcm + ' = ' + totalsb_cm_v1);
                    system.debug('GS MAP: ' + ActualGS_v1_map );
                }
                //vFinal Actual Gross Sales %
                if (totalsb_gs_v1 != 0 && totalsb_gs_v1 != null && tradeExp.v1_actual != 0 && tradeExp.v1_actual != null)
                    GrossSales.v1_actual = tradeExp.v1_actual / totalsb_gs_v1 *100;
                system.debug('vFinal GrossSales: ' + tradeExp.v1_actual + ' / ' + totalsb_gs_v1 + ' = ' + GrossSales.v1_actual);
                //vFinal Actual ROI
                if (allPaymentTotal != 0 && allPaymentTotal != null && totalsb_cm_v1 != null && totalsb_cm_v1 != 0)
                    vALLROI.v1 = totalsb_cm_v1 / allPaymentTotal;
                system.debug('vFinal ROI Total: ' + totalsb_cm_v1 + ' / ' + allPaymentTotal);

                //vFinal Actual Margin AP
                if (tradeExp.v1_actual != null && totalsb_cm_v1 != null)
                    MarginAP.v1_actual = totalsb_cm_v1 - tradeExp.v1_actual;
                system.debug('vFinal MarginAP: ' + totalsb_cm_v1 + ' - ' + tradeExp.v1_actual + ' = ' + MarginAP.v1_actual);
                //vFinal Actual Margin per Btl
                if (ActualIntakeTotal != null && ActualIntakeTotal != 0 && MarginAP.v1_actual != null && MarginAP.v1_actual != 0)
                    MarginperBtl.v1_actual = MarginAP.v1_actual / ActualIntakeTotal ;

                //Added by Alan Wong (Elufa) 20150623
                //vFinal Actual Pro-Forma ROI
                if (allPaymentTotal != 0 && allPaymentTotal != null && totalsb_lbcm_v1 != null && totalsb_lbcm_v1 != 0)
                    vProFormaROI.v1 = totalsb_lbcm_v1 / allPaymentTotal;
            }
            //vFinal Actual Variable Cost and Fixed Cost from Payment Request
            list<ASI_TH_CRM_PaymentRequestLineItem__c> PRLineItems = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
            try{
                //query All Payment Variable & Fixed Cost
                PRLineItems = [SELECT id, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Total_Payable__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c, RecordTypeId,
                        ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Cost__c
                FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__c IN :AllPRid];
            }catch(exception e){
                PRLineItems = new list<ASI_TH_CRM_PaymentRequestLineItem__c >();
            }

            decimal tempTotal = 0;
            decimal tempadjust = 1;
            if (PRLineItems.size() > 0){
                for ( ASI_TH_CRM_PaymentRequestLineItem__c  li_temp : PRLineItems ){
                    if (li_temp.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c != null && li_temp.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c != 0)
                        tempadjust = li_temp.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c / 100;
                    else
                            tempadjust = 1;
                    if (li_temp.ASI_TH_CRM_Amount__c != null){
                        tempTotal += li_temp.ASI_TH_CRM_Amount__c;
                        if (li_temp.ASI_CRM_CN_Cost_Type__c != null && li_temp.ASI_CRM_CN_Cost_Type__c != ''){
                            if (li_temp.ASI_CRM_CN_Cost_Type__c == 'Fixed')
                                FixExp.v1_actual += li_temp.ASI_TH_CRM_Amount__c;
                            if (li_temp.ASI_CRM_CN_Cost_Type__c == 'Variable' || li_temp.RecordTypeId == PSF_RTId)
                                VarExp.v1_actual += li_temp.ASI_TH_CRM_Amount__c;
                            //Handle when cost type not mention, R to contract cost line item, otherwise = variable
                        }else if ((li_temp.ASI_CRM_CN_Cost_Type__c == null || li_temp.ASI_CRM_CN_Cost_Type__c == '') && li_temp.ASI_CRM_CN_Contract_Cost__c != null){
                            if (li_temp.ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c == 'Fixed')
                                FixExp.v1_actual += li_temp.ASI_TH_CRM_Amount__c;
                            if (li_temp.ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c == 'Variable')
                                VarExp.v1_actual += li_temp.ASI_TH_CRM_Amount__c;
                        }else if ((li_temp.ASI_CRM_CN_Cost_Type__c == null || li_temp.ASI_CRM_CN_Cost_Type__c == '') && li_temp.ASI_CRM_CN_Contract_Cost__c == null){
                            VarExp.v1_actual += li_temp.ASI_TH_CRM_Amount__c;
                        }
                    }
                    if (li_temp.RecordTypeId == BRSF_RTId && li_temp.ASI_CRM_CN_Total_Payable__c != null)
                        VarExp.v1_actual += li_temp.ASI_CRM_CN_Total_Payable__c * tempadjust;
                    if (li_temp.ASI_CRM_CN_Total_Payable__c != null)
                        tempTotal += li_temp.ASI_CRM_CN_Total_Payable__c * tempadjust ;
                }
            }

            //FixExp Rate %
            if (FixExp.v0_contract != 0 && tradeExp.v0_contract != 0)
                FixExpRate.v0_contract = FixExp.v0_contract / tradeExp.v0_contract * 100;
            if (FixExp.v0_estimate != 0 && tradeExp.v0_estimate != 0)
                FixExpRate.v0_estimate = FixExp.v0_estimate / tradeExp.v0_estimate * 100;
            if (FixExp.v1_actual != 0 && tradeExp.v1_actual != 0)
                FixExpRate.v1_actual = FixExp.v1_actual / tradeExp.v1_actual * 100;

            //VolumeData gap
            if (VolumeData.v0_estimate != null && VolumeData.v0_estimate != 0 && VolumeData.v1_actual != null && VolumeData.v1_actual != 0)
                VolumeData.v0_est_gap = (VolumeData.v1_actual - VolumeData.v0_estimate) / VolumeData.v0_estimate * 100;
            if (VolumeData.v0_contract != null && VolumeData.v0_contract != 0 && VolumeData.v1_actual != null && VolumeData.v1_actual != 0)
                VolumeData.v0_con_gap = (VolumeData.v1_actual - VolumeData.v0_contract) / VolumeData.v0_contract * 100;

            //Gross Sales Rate gap
            if (GrossSales.v0_estimate != null && GrossSales.v1_actual != null && GrossSales.v0_estimate != 0 && GrossSales.v1_actual != 0 )
                GrossSales.v0_est_gap = ( GrossSales.v1_actual - GrossSales.v0_estimate);
            if (GrossSales.v0_contract != null  && GrossSales.v1_actual != null && GrossSales.v0_contract != 0 && GrossSales.v1_actual != 0)
                GrossSales.v0_con_gap = ( GrossSales.v1_actual - GrossSales.v0_contract);

            //Trade Expense gap
            if (tradeExp.v0_estimate != null && tradeExp.v0_estimate != 0 && tradeExp.v1_actual != null && tradeExp.v1_actual != 0)
                tradeExp.v0_est_gap = (tradeExp.v1_actual - tradeExp.v0_estimate) / tradeExp.v0_estimate * 100;
            if (tradeExp.v0_contract != null && tradeExp.v0_contract != 0 && tradeExp.v1_actual != null && tradeExp.v1_actual != 0)
                tradeExp.v0_con_gap = (tradeExp.v1_actual - tradeExp.v0_contract) / tradeExp.v0_contract * 100;

            //Variable Expense gap
            if (VarExp.v0_estimate != null && VarExp.v0_estimate != 0 && VarExp.v1_actual != null && VarExp.v1_actual != 0)
                VarExp.v0_est_gap = (VarExp.v1_actual - VarExp.v0_estimate) / VarExp.v0_estimate * 100;
            if (VarExp.v0_contract != null && VarExp.v0_contract != 0 && VarExp.v1_actual != null && VarExp.v1_actual != 0)
                VarExp.v0_con_gap = (VarExp.v1_actual - VarExp.v0_contract) / VarExp.v0_contract * 100;

            //Fixed Expense gap
            if (FixExp.v0_estimate != null && FixExp.v1_actual != null && FixExp.v0_estimate != 0&& FixExp.v1_actual != 0)
                FixExp.v0_est_gap = (FixExp.v1_actual - FixExp.v0_estimate) / FixExp.v0_estimate * 100;
            if (FixExp.v0_contract != null && FixExp.v1_actual != null && FixExp.v0_contract != 0 && FixExp.v1_actual != 0)
                FixExp.v0_con_gap = (FixExp.v1_actual - FixExp.v0_contract) / FixExp.v0_contract * 100;

            //Fixed Exp Rate gap
            if (FixExpRate.v0_estimate != null && FixExpRate.v1_actual != null && FixExpRate.v0_estimate != 0 && FixExpRate.v1_actual != 0)
                FixExpRate.v0_est_gap = ( FixExpRate.v1_actual - FixExpRate.v0_estimate);
            if (FixExpRate.v0_contract != null  && FixExpRate.v1_actual != null && FixExpRate.v0_contract != 0 && FixExpRate.v1_actual != 0)
                FixExpRate.v0_con_gap = ( FixExpRate.v1_actual - FixExpRate.v0_contract);

            //ROI Gap
            if (vALLROI.v1 != 0 && vALLROI.v1 != null && vALLROI.v0_estimate != null && vALLROI.v0_estimate != 0)
                vALLROI.v0_est_gap = (vALLROI.v1 - vALLROI.v0_estimate) / vALLROI.v0_estimate * 100;

            if (vALLROI.v1 != 0 && vALLROI.v1 != null && vALLROI.v0_contract != null && vALLROI.v0_contract != 0)
                vALLROI.v0_con_gap = ( vALLROI.v1 - vALLROI.v0_contract) / vALLROI.v0_contract * 100;

            // Added by Alan Wong (Elufa) 20150623
            // Pro-Forma ROI Gap
            if (vProFormaROI.v1 != 0 && vProFormaROI.v1 != null && vProFormaROI.v0_estimate != null && vProFormaROI.v0_estimate != 0)
                vProFormaROI.v0_est_gap = (vProFormaROI.v1 - vProFormaROI.v0_estimate) / vProFormaROI.v0_estimate * 100;

            if (vProFormaROI.v1 != 0 && vProFormaROI.v1 != null && vALLROI.v0_contract != null && vProFormaROI.v0_contract != 0)
                vProFormaROI.v0_con_gap = ( vProFormaROI.v1 - vProFormaROI.v0_contract) / vProFormaROI.v0_contract * 100;
            // -- End -- //

            //MarginAP Gap
            if (MarginAP.v0_estimate != 0 && MarginAP.v0_estimate != null && MarginAP.v1_actual != 0 && MarginAP.v1_actual != null)
                MarginAP.v0_est_gap = (MarginAP.v1_actual - MarginAP.v0_estimate) / MarginAP.v0_estimate * 100 ;
            if (MarginAP.v0_contract != 0 && MarginAP.v0_contract != null && MarginAP.v1_actual != 0 && MarginAP.v1_actual != null)
                MarginAP.v0_con_gap = (MarginAP.v1_actual - MarginAP.v0_contract) / MarginAP.v0_contract * 100 ;

            //Margin per Btl gap
            if (MarginperBtl.v0_estimate != 0 && MarginperBtl.v0_estimate != null && MarginperBtl.v1_actual != 0 && MarginperBtl.v1_actual != null)
                MarginperBtl.v0_est_gap = (MarginperBtl.v1_actual - MarginperBtl.v0_estimate) / MarginperBtl.v0_estimate * 100;
            if (MarginperBtl.v0_contract != 0 && MarginperBtl.v0_contract != null && MarginperBtl.v1_actual != 0 && MarginperBtl.v1_actual != null)
                MarginperBtl.v0_con_gap = (MarginperBtl.v1_actual - MarginperBtl.v0_contract) / MarginperBtl.v0_contract * 100;

            if (lastpayment_sbgrade.size() > 0){
                for (DataClass sbg_temp : lastpayment_sbgrade.values()){
                    if (sbg_temp.v1_actual != 0 && sbg_temp.v0_estimate != 0)
                        sbg_temp.v0_est_gap = (sbg_temp.v1_actual - sbg_temp.v0_estimate) / sbg_temp.v0_estimate * 100;
                    if (sbg_temp.v1_actual != 0 && sbg_temp.v0_contract != 0)
                        sbg_temp.v0_con_gap = (sbg_temp.v1_actual - sbg_temp.v0_contract) / sbg_temp.v0_contract * 100;
                }
            }

            //Payee Section
            try{
                PayeeList = [SELECT id, ASI_CRM_CN_Type__c, ASI_CRM_CN_Amount__c,
                        ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T2_lookup__c,
                        ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Payee_Name_T1__r.Name,
                        ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name,
                        ASI_CRM_CN_Cash_Amount__c
                FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                WHERE ASI_CRM_CN_Payment_Request__c = :thisPR.id];

            }catch(exception e){
                //system.debug('Try PayeeList failed: ' + e);
                PayeeList = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            }

            if (PayeeList.size() > 0){
                for (ASI_CRM_CN_PH_Payee_Line_Item__c payeetemp : PayeeList){
                    if (payeetemp.ASI_CRM_CN_Amount__c != null)
                        PayeeAmount += payeetemp.ASI_CRM_CN_Amount__c;
                }

            }
            //Payment Request Summary
            List<integer> lstRemove = new List<integer>();
            integer index = 0;
            integer c = 0;
            try{
                paymentRequestSummary = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(thisPR, null);
            }catch(exception e){
            }
            PS_TotalPOEstAmt = 0;
            PS_TotalPORemainAmt = 0;
            PS_TotalPRAmt = 0;
            PS_TotalMAFEstAmt = 0; //20160816, added by Leo
            PS_TotalMAFRemainAmt = 0; //20160816, added by Leo
            PS_TotalMAFPRAmt = 0; //20160816, added by Leo
            PS_TotalCNYEstAmt = 0; //20160816, added by Leo
            PS_TotalCNYRemainAmt = 0; //20160816, added by Leo
            PS_TotalCNYPRAmt = 0; //20160816, added by Leo
            PS_TotalOthersEstAmt = 0; //20160816, added by Leo
            PS_TotalOthersRemainAmt = 0; //20160816, added by Leo
            PS_TotalOthersPRAmt = 0; //20160816, added by Leo
            if (paymentRequestSummary.size() > 0){
                mafSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>(); //20160816, added by Leo
                cnySummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>(); //20160816, added by Leo
                othersSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>(); //20160816, added by Leo
                for (ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary prtemp : paymentRequestSummary){
                    PS_TotalPOEstAmt += prtemp.POEstimateAmt ;
                    PS_TotalPORemainAmt += prtemp.PORemainAmt ;
                    PS_TotalPRAmt += prtemp.PaymentRequestAmount ;
                    PS_TotalMAFEstAmt += prtemp.mafEst ; //20160816, added by Leo
                    PS_TotalMAFRemainAmt += prtemp.mafRemaining ; //20160816, added by Leo
                    PS_TotalMAFPRAmt += prtemp.mafRequest ; //20160816, added by Leo
                    PS_TotalCNYEstAmt += prtemp.cnyEst ; //20160816, added by Leo
                    PS_TotalCNYRemainAmt += prtemp.cnyRemaining ; //20160816, added by Leo
                    PS_TotalCNYPRAmt += prtemp.cnyRequest ; //20160816, added by Leo
                    PS_TotalOthersEstAmt += prtemp.othersEst ; //20160816, added by Leo
                    PS_TotalOthersRemainAmt += prtemp.othersRemaining ; //20160816, added by Leo
                    PS_TotalOthersPRAmt += prtemp.othersRequest ; //20160816, added by Leo

                    //Added by Twinkle 20141204 - Remove empty record
                    if((prtemp.POEstimateAmt == 0 || prtemp.POEstimateAmt == null) &&
                            (prtemp.PORemainAmt == 0 || prtemp.PORemainAmt == null) &&
                            (prtemp.PaymentRequestAmount == 0 || prtemp.PaymentRequestAmount == null)){
                        lstRemove.add(index);
                    }
                    //20160816, added by Leo
                    if((prtemp.mafEst != 0 && prtemp.mafEst != null) ||
                            (prtemp.mafRemaining != 0 && prtemp.mafRemaining != null) ||
                            (prtemp.mafRequest != 0 && prtemp.mafRequest != null)){
                        mafSummary.add(prtemp);
                    }
                    if((prtemp.cnyEst != 0 && prtemp.cnyEst != null) ||
                            (prtemp.cnyRemaining != 0 && prtemp.cnyRemaining != null) ||
                            (prtemp.cnyRequest != 0 && prtemp.cnyRequest != null)){
                        cnySummary.add(prtemp);
                    }
                    if((prtemp.othersEst != 0 && prtemp.othersEst != null) ||
                            (prtemp.othersRemaining != 0 && prtemp.othersRemaining != null) ||
                            (prtemp.othersRequest != 0 && prtemp.othersRequest != null)){
                        othersSummary.add(prtemp);
                    }
                    //20160816, added by Leo
                    index++;
                }
                for(integer n : lstRemove){
                    if(n!=0){
                        if(c>0) n=n-c;
                        paymentRequestSummary.remove(n);
                        c++;
                    }else{
                        paymentRequestSummary.remove(0);
                        c++;
                    }
                }
                //End by Twinkle 20141204
            }
        

            freeGoodsList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
                //query All Payment Variable & Fixed Cost
            freeGoodsList = [SELECT Id, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c, RecordTypeId,RecordType.DeveloperName,ASI_CRM_Adjustment__c,
                        ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Cost__c, 
                        ASI_TH_CRM_Payment_Request__r.Name,ASI_CRM_CN_Item_Group__r.Name,
                        ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Unit_Price__c,ASI_TH_CRM_Quantity__c
                FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c and RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods' AND (ASI_TH_CRM_Payment_Request__c =:thisPR.Id
                OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR
                ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted'  OR
                ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid')];

            if (!freeGoodsList.isEmpty()) {
                DisplayFreeGoods = true;
            }

            System.debug(LoggingLevel.INFO, '*** freeGoodsList: ' + freeGoodsList);
        }

        if(thisPR.ASI_CRM_Heap_Size_Large__c){
            SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c >();
        }

        //system.assertEquals(Limits.getHeapSize(), Limits.getLimitHeapSize());

        return true;
    }
    public integer MonthDiff(date startDate, date endDate){
        Integer monthDiff;
        if (startDate != null && endDate != null){
            monthDiff = ((endDate.YEAR() - startDate.YEAR() - 1) *12) + (12 - startDate.MONTH() +1) + endDate.MONTH();
            return monthDiff;
        }else{
            return null;
        }
    }
    public set<date> checkFY(date startDate, date endDate){
        set<date> returnDateSet = new set<date>();
        date returnDate;
        integer StartFY;
        integer EndFY;
        if (startDate != null && endDate != null){
            if (startDate.Month() > 6 && startDate.Month() < 12){
                StartFY = startDate.Year()+ 1;
            }
            if (startDate.Month() < 7 && startDate.Month() > 0){
                StartFY = startDate.Year();
            }
            if (endDate.Month() > 6 && endDate.Month() < 12){
                EndFY = endDate.Year() + 1;
            }
            if (endDate.Month() < 7 && endDate.Month() > 0){
                EndFY = endDate.Year();
            }
            integer strPeriod = EndFY - StartFY;
            if (strPeriod >= 0){
                for (integer i=0; i<strPeriod; i++){
                    returnDate = Date.newinstance(StartFY,7,1);
                    returnDateSet.add(returnDate);
                    StartFY++;
                }
            }
            return returnDateSet;
        }else{
            return null;
        }
    }

    public class DataClass{
        public string brand {set;get;}
        public decimal target_vol {set;get;}
        public decimal actual_vol {set;get;}
        public decimal achieverate {set;get;}
        public decimal v0 {set;get;}
        public decimal v1 {set;get;}
        public decimal gap {set;get;}
        public decimal actualCM {set;get;}
        public decimal actualGS {set;get;}
        public decimal budgetCM {set;get;}
        public decimal budgetGS {set;get;}
        public date tilldate {set;get;}
        public decimal strPeriod {set;get;}
        public id sbid {set;get;}
        public string sbname {set;get;}
        public decimal v0_contract {set;get;}
        public decimal v0_estimate {set;get;}
        public decimal v1_actual {set;get;}
        public decimal v0_con_gap {set;get;}
        public decimal v0_est_gap {set;get;}
        public string year {set;get;}
        public decimal latestbudgetCM {set;get;} // Added by Alan Wong (Elufa) 20150623
    }
    public map<date, decimal> checkFYDayPeriod(date startDate, date endDate){
        map<date, decimal> returnDateMap = new map<date, decimal>();
        Integer EndFY;
        Integer StartFY;
        date returnDate;
        date tempDate = startDate;
        if (startDate != null && endDate != null){
            if (startDate.Month() > 6 && startDate.Month() < 13){
                StartFY = startDate.Year() + 1;
            }
            if (startDate.Month() < 7 && startDate.Month() > 0){
                StartFY = startDate.Year();
            }
            if (endDate.Month() > 6 && endDate.Month() < 13){
                EndFY = endDate.Year() + 1;
            }
            if (endDate.Month() < 7 && endDate.Month() > 0){
                EndFY = endDate.Year();
            }
            integer strPeriod = EndFY - StartFY + 1;
            integer strtemp = 0;
            if (strPeriod >= 0){
                for (integer i=0; i<strPeriod; i++){
                    returnDate = Date.newinstance(StartFY,6,30);
                    if (returnDate <= startDate){
                        strtemp = MonthDiff(returnDate, startDate);
                        //system.debug('returnDate <= startDate: ' + returnDate + ' - ' + startDate);
                    }else if (returnDate > startDate && returnDate < endDate){
                        strtemp = MonthDiff(tempDate, returnDate);
                        //system.debug('(returnDate > startDate && returnDate < endDate): ' + tempDate + ' - ' + returnDate);
                    }else if (returnDate >= endDate){
                        strtemp = MonthDiff(tempDate, endDate);
                        //system.debug('returnDate >= endDate: ' + endDate + ' - ' + returnDate);
                    }else if (returnDate >= startDate && returnDate >= endDate){
                        strtemp = MonthDiff(startDate, returnDate);
                        //system.debug('returnDate >= startDate && returnDate >= endDate: ' + startDate + ' - ' + returnDate);
                    }
                    returnDateMap.put(returnDate, decimal.valueof(strtemp));
                    tempDate = Date.newinstance(StartFY,7,1);
                    //system.debug('tempDate: ' + tempDate );
                    StartFY++;
                }
            }
            return returnDateMap;
        }else{
            return null;
        }
    }
    public date FYConversion(date strDate){
        date returndate;
        integer EndFY;
        if (strDate.Month() > 6 && strDate.Month() < 13){
            EndFY = strDate.Year() + 1;
        }
        if (strDate.Month() < 7 && strDate.Month() > 0){
            EndFY = strDate.Year();
        }
        returndate = date.newinstance(EndFY,6,30);
        return returnDate;
    }
    public void checkUserID(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
           ADorAbove  = true;
    }
    public void checkApprover(){
        ADorAbove = false;
        set<Id> actorIds = new set<Id>();
        for(ProcessInstanceWorkitem piw
                :[SELECT ActorId FROM ProcessInstanceWorkitem
        WHERE processinstance.status = 'Pending' AND
        processinstance.targetobjectid = : thisPR.id]) {
            actorIds.add(piw.ActorId);
        }
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];
        if(gms.size()>0)
            ADorAbove = true;
    }
    public date getEndDate(date strDate){
        Integer numberOfDays;
        Date lastDayOfMonth;
        if(strDate != null){
            numberOfDays = Date.daysInMonth(strDate.year(), strDate.month());
          lastDayOfMonth = Date.newInstance(strDate.year(), strDate.month(), numberOfDays);
        }
        return lastDayofMonth;
    }
    public date FindMinMaxDate(date Date1, date Date2, string strType){
        //strType: MIN, MAX
        Date returnDate;
        if (strType == 'MIN'){
            if (Date1 <= Date2)
                returnDate = Date1;
            else
                    returnDate = Date2;
        }
        if (strType == 'MAX'){
            if (Date1 >= Date2)
                returnDate = Date1;
            else
                    returnDate = Date2;
        }
        return returnDate;
    }
}