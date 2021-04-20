/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromotionPaymentCtrl
 * Description: Apex class for ASI_CRM_CN_PromotionPaymentCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-11-21       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_PromotionPaymentCtrl implements Iterable<interimData>, Iterator<interimData>{
    public static final String PROMOTION_TARGET_MODULE_TYPE = 'BRSF';
    public static final String PRICE_PROMOTION_MODULE_TYPE = 'PSF';
    public static final String FREE_GOODS_MODULE_TYPE = 'Display';
    public static final String VISIBILITY_MODULE_TYPE = 'Visibility';
    public static final String PAGE_NAME = '/apex/ASI_CRM_CN_PromotionPaymentPage';
    public static Integer BATCH_OUTLET_QTY = 2000; //超出店家数时开启batch
    public static Integer DELETEBATCH_ROW_QTY = 2000; //超出明细数是时开启删除batch
    public static Map<String, Decimal> bottleSizeMap = New Map<String, Decimal>(); 
    {
        for(ASI_MFM_Sub_brand__c sb:[SELECT Id,Name,ASI_CRM_CN_Standard_Bottle_Size__c,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c
        FROM ASI_MFM_Sub_brand__c WHERE RecordType.DeveloperName  LIKE '%CN%'])
        {
            bottleSizeMap.put(sb.Id, sb.ASI_CRM_CN_Standard_Bottle_Size__c);
        }
    }

    /*
        Author:Bowen
        Date : 2019-08-06
        Function : VF前端页面真分页参数
    */
    public Decimal sumNum {get;set;} // 数据总数
    public Decimal totalNumPage {get;set;} // 当前页面数
    public Decimal sumNumPage {get;set;} // 总页面数
    public Boolean isFirst {get;set;} // 是否显示上一页
    public Boolean isNext {get;set;} // 是否显示下一页
    public String PageSkipType {get;set;} // 跳转类型

    // public static Decimal skipNum = [select ASI_CRM_CN_Payment_Page_Number__c from ASI_CRM_CN_CustomSetting__c].ASI_CRM_CN_Payment_Page_Number__c; // 每页的条目数
    public static Decimal skipNum = 50; // 每页的条目数

    public Decimal WS_Intake_9L{get;set;}{WS_Intake_9L = 0;} // WS Intake (9L) 批发商进货量（9L)
    public Decimal CTD_Actual_Purchase_Value{get;set;}{CTD_Actual_Purchase_Value = 0;} // CTD Actual Purchase Value 批发商进货金额
    public Decimal POS_Volume_9L{get;set;}{POS_Volume_9L = 0;} // POS Volume (9L) 
    public Decimal POS_Value{get;set;}{POS_Value = 0;} // POS Value
    public Decimal Outlet_Intake_9L{get;set;}{Outlet_Intake_9L = 0;} // Outlet Intake (9L) 店家进货量（9L)
    public Decimal CTD_Actual_Retail_Value{get;set;}{CTD_Actual_Retail_Value = 0;} // CTD Actual Retail Value 店家进货金额
    public Decimal Actual_Value_Base{get;set;}{Actual_Value_Base = 0;} // WS Intake (9L) 实际销售金额
    public Decimal Total_Suggest_Incentive{get;set;}{Total_Suggest_Incentive = 0;} // Total Suggest Incentive 合同至今应付金额
    public Decimal Historical_Paid_Amount{get;set;}{Historical_Paid_Amount = 0;} // Historical Paid Amount 已支付金额
    public Decimal Suggested_this_time_payment{get;set;}{Suggested_this_time_payment = 0;} // Suggested this time payment 支付金额
    public Decimal Total_this_time_payment{get;set;}{Total_this_time_payment = 0;} // Total this time payment 实际支付金额
    public Decimal Actual_Incentive{get;set;}{Actual_Incentive = 0;} // Actual Incentive%  实际返点%
    public Decimal vs_suggested{get;set;}{vs_suggested = 0;} // vs. suggested  vs.支付金额

    public Boolean showWS{get;set;}{showWS = true;}

    public Map<Decimal ,Decimal> moduleActualPaymentMap_ByPage{get;set;}
    public Map<String ,Decimal> moduleActualPaymentMap_ByController{get;set;}
    

    public Boolean isRefresh{get;set;} {
        isRefresh = true;
    }

    public ASI_TH_CRM_Contract__c ContractSelected { set; get; }
    public ASI_CRM_Module__c contractPromotionTargetModule { set; get; }

    public String dataSource{get;set;}
    public Decimal markupPercent;
    public Map<String, String> reportByName { set; get; }
    public String reportByNameJSON { set; get; }
    public List<ASI_CRM_Module__c> deletedModules { set; get; } {
        deletedModules = new List<ASI_CRM_Module__c>();
    }
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> deletedLines { set; get; } {
        deletedLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
    }


    public ASI_TH_CRM_PaymentRequest__c PH { set; get; }
    public String PageId { set; get; }


    //Line Detail
    public ASI_CRM_Module__c BRSFModule { set; get; } {
        BRSFModule = new ASI_CRM_Module__c();
    }

    //Display
    public Map<String, interimData> DisplayItemMap { set; get; } {
        DisplayItemMap = new Map<String, interimData>();
    }

    //Other Payment Detail
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> OtherPaymentLineList { set; get; } {
        OtherPaymentLineList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
    }

    public Boolean DisplayVEC { set; get; } {
        DisplayVEC = false;
    }

    //@description : new line count
    public static String LINE_ITEM_NEWRECORD_PREFIX { get {return 'z';} }
    public Integer LINE_ITEM_NEWRECORD_COUNTER { get; set; }
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentLineDeleteList { get; set; }{
        PaymentLineDeleteList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
    }

    public String Msg { get; set; } {
        Msg = '';
    }
    public Boolean UpsertPermission { get; set; }{
        UpsertPermission = true;
    }
    public Boolean showCN { set; get; }
    public List<ASI_CRM_Module__c> HistoricalModuleList { get; set; }{
        HistoricalModuleList = new List<ASI_CRM_Module__c>();
    }
    public Boolean showReturn { set; get; } {
        showReturn = false;
    }
    public List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary> PaymentSummaryList { set; get; }{
        PaymentSummaryList = new List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary>();
    }
    public Boolean cashtype { set; get; }
    public Boolean discounttype { set; get; }
    public Boolean isEdit { set; get; }
    public Boolean isView { set; get; }
    public Boolean isEditHeader { set; get; }
    public Boolean isSouthRegion { set; get; }
    public Boolean isAutoModi { set; get; }{isAutoModi = false;}
    public Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CD { set; get; }{
        Payee_Item_Map_CD = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
    }
    public Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_DISCOUNT { set; get; }{
        Payee_Item_Map_DISCOUNT = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
    }
    public Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CASH { set; get; }{
        Payee_Item_Map_CASH = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
    }

    public Set<Id> wholesalerIds { set; get; } {
        wholesalerIds = new Set<Id>();
    }
    public Set<Id> outletIds { set; get; } {
        outletIds = new Set<Id>();
    }
    public Set<Id> subBrandIds { set; get; }

    // remove outletInterimData, use interimDataMap
    public interimData outletInterimData { set; get; }
    public Map<String, interimData> interimDataMap { set; get; }
    public Transient String interimDataMapJSON { set; get; }
    public Integer numberOfModules { set; get; }

    public List<String> colHeaders { get; set; }
    public String colHeadersJSON { get; set; }
    public Date endDate { get; set; }

    public String freeGoodsRecordTypeId { get; set; }
    public interimData freeGoodsInterimData { get; set; }
    public String freeGoodsInterimDataJSON { get; set; }

    public ASI_CRM_Module__c visibilityModule { get; set; }

    public set<Id> onlyForStrategyIdSet { get; set; }{ onlyForStrategyIdSet = new set<Id>();}

    public Map<String, Decimal> HistoricalAmountMap { get; set; }{ HistoricalAmountMap = new Map<String, Decimal>();}

    public Map<Id, List<ASI_CRM_Subbrand_Volume__c>> WSSubbrandVolumeMap = new Map<Id, List<ASI_CRM_Subbrand_Volume__c>>();

    public Decimal paidVisibilityAmt { get; set; }{paidVisibilityAmt = 0;}
    public ASI_TH_CRM_PaymentRequest__c PHAdditional { set; get; }

    // Batch update releated var
    public Integer progressRate {get;set;}  // 前端batch处理指示条
    public String jobId {get;set;} // 批量处理数据job ID
    public String deletejobId {get;set;} // 批量删除数据Job Id
    public Boolean IsEnabled {get;set;} // 是否开启处理数据job 轮询
    public Boolean IsEnabledDelete {get;set;} // 是否开启删除数据job 轮询
    public String BatchhandleResult {get;set;} //处理数据job结果
    public String deleteBatchResult {get;set;} //处理删除数据job结果
    public String batchType {get;set;} //开启job类型

    // 实现内部类可Iterable
    public List<interimData> interimDataList;
    Integer iBatch {get; set;} 
    public ASI_CRM_CN_PromotionPaymentCtrl(List<interimData> interimDataList)
    { 
        this.interimDataList = interimDataList;
        iBatch = 0; 
    }
    public ASI_CRM_CN_PromotionPaymentCtrl(){

    } 
    public Boolean hasNext() 
    { 
        return (iBatch >= interimDataList.size()) ? false : true; 
    } 
    public interimData next()
    { 
        if(iBatch  < interimDataList.size())
        {
            iBatch = iBatch+1;
            return interimDataList[iBatch-1]; 
        }
        return null;
    } 
    public Iterator<interimData> iterator() 
    { 
        return this; 
    } 


    public void Calculation() {
        if (!isView) {
            return;
        }
        //Calculate all normal Data
        /*if (PH.ASI_CRM_System_Debug__c) {
            ASI_CRM_CN_OffPaymentUtilClass.PaymentKPICalculation(PH);
        } else {
            try {
                ASI_CRM_CN_OffPaymentUtilClass.PaymentKPICalculation(PH);
            } catch (Exception e) {
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_PromotionPaymentPage.Calculation <br/> in ASI_CRM_CN_Edit_OffPR_DetailsPage Page have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_PromotionPaymentPage', 'Calculation function failed! with payment Id: ' + PH.Id + ' Stack: ' + e.getStackTraceString());
            }

        }*/
        //try {
        if(endDate != null) {
            System.debug(endDate);
            if(!Test.isRunningTest()) ASI_CRM_CN_PromotionContractUtilClass.ReconstructCurrentPOModiFIData(ContractSelected, endDate);
        }
        if(!Test.isRunningTest()) ASI_CRM_CN_PromotionPaymentUtilClass.PaymentKPICalculation(PH);
        /*} catch (Exception e) {
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_PromotionPaymentPage.Calculation <br/> in ASI_CRM_CN_Edit_OffPR_DetailsPage Page have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_PromotionPaymentPage', 'Calculation function failed! with payment Id: ' + PH.Id + ' Stack: ' + e.getStackTraceString());
        }*/


        if (PH.ASI_CRM_CN_Last_Payment__c) {
            try {
                String V0ContractID = '';
                if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null) {
                    ASI_TH_CRM_Contract__c V0Contract = [
                            SELECT Id,Name,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c, ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                                    ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
                                    ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c, ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Effective_Date__c,
                                    RecordTypeId, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_PO_Modification__c, ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c, ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_Business_License__c, CreatedDate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, LastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
                                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                    ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c
                            FROM ASI_TH_CRM_Contract__c
                            WHERE Id = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c
                    ];
                    ASI_CRM_CN_PromotionContractUtilClass.ReconstructCurrentPOModiFIData(ContractSelected, null);
                    ASI_CRM_CN_PromotionContractUtilClass.RestructureCurrentFinancialIndicatorData(V0Contract);
                } else {// this contract is V0.0
                    ASI_CRM_CN_PromotionContractUtilClass.ReconstructCurrentPOModiFIData(ContractSelected, null);
                    ASI_CRM_CN_PromotionContractUtilClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
                }

                //ASI_CRM_CN_PromotionPaymentUtilClass.ReconstructLastPaymentFIData(PH);
            } catch (Exception e) {
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_PromotionPaymentPage.Calculation <br/> in ASI_CRM_CN_ViewHeavyContractPage Page have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_EditOffPaymentDetailCtrl', 'Calculation function failed! with contract Id: ' + ContractSelected.Id);
            }
        }
        //ContractSelected
    }


    public ASI_CRM_CN_PromotionPaymentCtrl(ApexPages.StandardController controller) {
        interimDataMap = new Map<String, interimData>();
        freeGoodsInterimData = new interimData();
        numberOfModules = 0;
        isView = true;
        IsEnabled = false;
        IsEnabledDelete = false;
        if (ApexPages.currentPage().getParameters().get('isEdit') == '1') {
            isEdit = true;
            isView = false;
        }

        isEditHeader = false;
        if (ApexPages.currentPage().getParameters().get('isEditHeader') == '1') {
            isEditHeader = true;
        }

        totalNumPage = 1; // Price Promotion页面初始化，默认为首页
        isNext = false; // Price Promotion 默认下一页为false，需要根据数据长度来判断是否显示
        isFirst = false;// Price Promotion 默认上一页为false，即页面不显示

        this.PH = (ASI_TH_CRM_PaymentRequest__c) controller.getRecord();
        PageId = PH.Id;
        //Select the field which cannot be got from controller.getRecord(), need to fix later
        PHAdditional = [select ASI_CRM_Auto_PO_Modification__c from ASI_TH_CRM_PaymentRequest__c where Id = :PageId];
        isAutoModi = PHAdditional.ASI_CRM_Auto_PO_Modification__c;
        PH.put('ASI_CRM_Auto_PO_Modification__c', isAutoModi);

        freeGoodsRecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Free_Goods');
        List <ASI_TH_CRM_PaymentRequest__c> HeaderList = new List <ASI_TH_CRM_PaymentRequest__c>();

        //Get Header information
        if (PageId != null) {
            HeaderList = [
                    SELECT
                            ASI_CRM_CalOtherCostHistoricalPaidAmt__c,
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
                            Id,
                            Name,
                            ASI_TH_CRM_GL_Date__c,ASI_CRM_CN_Invoice_Date__c
                    FROM ASI_TH_CRM_PaymentRequest__c
                    WHERE Id = :PageId
            ];

        }

        if (HeaderList.size() > 0) {
            this.PH = HeaderList[0];
            ContractSelected = [
                    SELECT
                            ASI_TH_CRM_Contract_Status__c,
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
                    //(SELECT Id, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.RecordType.DeveloperName, ASI_CRM_CN_Strategy_WS__c FROM Covered_Outlet__r)
                    FROM ASI_TH_CRM_Contract__c
                    WHERE Id = :PH.ASI_TH_CRM_Contract__c
            ];

            List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletList = [select Id, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.RecordType.DeveloperName, ASI_CRM_CN_Strategy_WS__c FROM ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c =:PH.ASI_TH_CRM_Contract__c];
            // Set wholesalerIds and outletIds
            //for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : ContractSelected.Covered_Outlet__r) {
            for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutletList) {
                if (coveredOutlet.ASI_CRM_CN_Outlet__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN') {
                    outletIds.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                }
                if (coveredOutlet.ASI_CRM_CN_Outlet__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS') {
                    wholesalerIds.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                    if(coveredOutlet.ASI_CRM_CN_Strategy_WS__c){
                        onlyForStrategyIdSet.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                    }
                }
            }
            PaymentSummaryList = ASI_CRM_CN_PromotionContractUtilClass.PaymentSummaryTable(ContractSelected, PH);
            //get paid visibility amount
            for(ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary ps :PaymentSummaryList){
                if(ps.Name =='Visibility'){
                    paidVisibilityAmt = ps.PaidAmount;
                }
            }
            isSouthRegion = ContractSelected.ASI_CRM_CN_Region__c == 'South Region';
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractPromotionTargetLines = [
                    SELECT
                            ASI_CRM_CN_Activity_Code__c,
                            ASI_CRM_CN_Contract__c,
                            //ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,
                            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                            ASI_CRM_CN_Contract_Monthly_Qty__c,
                            //ASI_CRM_CN_Contract_Purchase_Value__c,
                            //ASI_CRM_CN_Estimate_Purchase_Value__c,
                            //ASI_CRM_CN_Contract_Total__c,
                            //ASI_CRM_CN_Contract_Total_Dummy__c,
                            //ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                            //ASI_CRM_CN_Est_Monthly_Qty__c,
                            //ASI_CRM_CN_Est_Total__c,
                            //ASI_CRM_CN_Est_Total_Dummy__c,
                            ASI_CRM_CN_Max_Purchase_Target__c,
                            ASI_CRM_CN_Min_Purchase_Target__c,
                            //ASI_CRM_CN_Rebate__c,
                            ASI_CRM_CN_Rebate_Percent__c,
                            ASI_CRM_CN_Sub_Brand__c,
                            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                            ASI_CRM_CN_Sub_Brand__r.Name,
                            //ASI_CRM_CN_Target__c,
                            //ASI_CRM_Contract_Monthly_Volume_CR12__c,
                            //ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c,
                            //ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c,
                            //ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                            //ASI_CRM_Contract_Total_QTY_std_Btl__c,
                            //ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c,
                            //ASI_CRM_Est_Monthly_Volume_CR12__c,
                            //ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c,
                            //ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                            //ASI_CRM_Est_Total_QTY_std_Btl__c,
                            ASI_CRM_Key_Sub_brand__c,
                            ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,
                            //ASI_CRM_Product_Category__c,
                            //ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                            //ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                            //ASI_CRM_Product_Category__r.Name,
                            //ASI_CRM_Sub_Brand_Grade__c,
                            //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                            //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                            Id
                    FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                    WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c
                    AND ASI_CRM_Type__c = 'BRSF'
                    ORDER BY Id
            ];

            List<ASI_CRM_Module__c> contractPromotionList = [
                    SELECT
                            ASI_CRM_CN_Total_Markup__c,
                            Id
                    FROM ASI_CRM_Module__c
                    WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                    AND ASI_CRM_Line_Type__c = :PROMOTION_TARGET_MODULE_TYPE
                    LIMIT 1
            ];
            if(contractPromotionList.size() > 0) contractPromotionTargetModule = contractPromotionList[0];
            subBrandIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Sub_Brand__c, contractPromotionTargetLines);
        }

        dataSource = ContractSelected.ASI_CRM_CN_Data_Source__c;
        if(contractPromotionTargetModule != null && contractPromotionTargetModule.ASI_CRM_CN_Total_Markup__c != null){
            markupPercent = (1 + contractPromotionTargetModule.ASI_CRM_CN_Total_Markup__c / 100);
        }
        // 2019-11-01 bowen update ，因为出现空指针异常的报错，原因是contractPromotionTargetModule是空的，所以markupPercent没有值，导致下面的计算是错的，因此这里多加一个逻辑，如果数据是空的，则将markupPercent默认为1
        else{
            markupPercent = 1;
        }

        init();
    }

    public void init() {
        reportByName = retrieveReports();
        reportByNameJSON = JSON.serialize(reportByName);
        showReturn = false;
        if ([
            SELECT Assignee.Name, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'ASI_CRM_CN_General_BA' AND AssigneeId = :UserInfo.getUserId()
        ].size() > 0 && PH.ASI_TH_CRM_Status__c == 'Submitted') {
            showReturn = true;
        }
        
        // 2019-08-16 bowen 因为数据不存在，导致查询报list= 0的错误，需要先对数据进行判断是否存在。再进行下一步逻辑判断
        List<ASI_CRM_Module__c> moduleCount_List = new List<ASI_CRM_Module__c>([
            SELECT
                        Id
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                AND ASI_CRM_Line_Type__c = :PRICE_PROMOTION_MODULE_TYPE
                ]);
        if(moduleCount_List.size() > 0)
        {
            numberOfModules = (Integer) [
                SELECT
                        COUNT(Id)
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                AND ASI_CRM_Line_Type__c = :PRICE_PROMOTION_MODULE_TYPE
                GROUP BY ASI_CRM_Parent_Module__c
            ][0].get('expr0');
        }
        WS_Intake_9L = 0; // WS Intake (9L) 批发商进货量（9L)
        CTD_Actual_Purchase_Value = 0; // CTD Actual Purchase Value 批发商进货金额
        POS_Volume_9L = 0; // POS Volume (9L) 
        POS_Value = 0; // POS Value
        Outlet_Intake_9L = 0; // Outlet Intake (9L) 店家进货量（9L)
        CTD_Actual_Retail_Value = 0; // CTD Actual Retail Value 店家进货金额
        Actual_Value_Base = 0; // WS Intake (9L) 实际销售金额
        Total_Suggest_Incentive = 0; // Total Suggest Incentive 合同至今应付金额
        Historical_Paid_Amount = 0; // Historical Paid Amount 已支付金额
        Suggested_this_time_payment = 0; // Suggested this time payment 支付金额
        Total_this_time_payment = 0; // Total this time payment 实际支付金额
        Actual_Incentive = 0; // Actual Incentive%  实际返点%
        vs_suggested = 0; // vs. suggested  vs.支付金额
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        PaymentItemList = [
                SELECT
                //ASI_CRM_Brand_Code__c,
                //ASI_CRM_CN_AC_Code__c,
                        ASI_CRM_CN_Actual_Vol__c,
                        ASI_CRM_CN_Allow_Changing_Incentive__c,
                        ASI_CRM_CN_Comment__c,
                        ASI_CRM_Customer__c,
                        ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Customer__r.Name,
                        //ASI_CRM_CN_Completion_Rate__c, // no need
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Total_Dummy__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Est_Total_Dummy__c,
                        //ASI_CRM_CN_Rebate__c, // no need
                        ASI_CRM_CN_Rebate_Percent__c,
                        //ASI_CRM_CN_Target__c, // no need
                        ASI_CRM_Historical_Paid_Amount__c, //no need
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_std_Btl__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_std_Btl__c,
                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                        //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Contract_Amount__c,    // no need
                        //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_Contract_Terms__c,    // no need
                        //ASI_CRM_CN_Expense_Type__c, // no need
                        //ASI_CRM_CN_Incentive_BT__c, // no need
                        ASI_CRM_CN_Item_Group__c,   // no need
                        ASI_CRM_CN_Item_Group__r.Name,  // no need
                        ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,    // no need
                        //ASI_CRM_CN_Payable_Vol__c,    // no need
                        //ASI_CRM_CN_Remaining_Amount__c,   // no need
                        //ASI_CRM_CN_Standard__c,   // no need
                        ASI_CRM_CN_Sub_Brand__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                        ASI_CRM_CN_Sub_Brand__r.Name,
                        //ASI_CRM_CN_Suggested_Amount__c,   // no need
                        ASI_CRM_CN_Total_Payable__c,
                        ASI_CRM_CN_Wholesaler__c,
                        ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_CN_Wholesaler__r.Name,
                        //ASI_CRM_CNY_Est__c,   // no need
                        ASI_CRM_CTD_Actual_Purchase_Value__c,
                        ASI_CRM_CTD_Actual_Vol__c,
                        //ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,   // no need
                        //ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,  // no need
                        //ASI_CRM_Key_Sub_Brand__c, // no need
                        //ASI_CRM_Line_Name__c, // no need
                        ASI_CRM_Line_Long_Name__c,
                        //ASI_CRM_MAF_Est__c, // no need
                        //ASI_CRM_Max_Incentive__c, // no need
                        ASI_CRM_Module__c,
                        ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                        //ASI_CRM_Non_Contract_Line__c, // no need
                        //ASI_CRM_Other_Est__c, // no need
                        //ASI_CRM_Over_Incentive__c, // no need
                        //ASI_CRM_Product_Category__c,  // no need
                        //ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,   // no need
                        //ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,       // no need
                        //ASI_CRM_Product_Category__r.Name, // no need
                        //ASI_CRM_Sub_Brand_Grade__c,       // no need
                        //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,   // no need
                        //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,    // no need
                        //ASI_CRM_System_Payable_Vol_Std_Bottle__c,         // no need
                        ASI_CRM_Unit_Price__c,
                        ASI_CRM_CN_Suggest_Unit_Price__c,
                        //ASI_CRM_V0_0_Full_Contract_Target__c, // no need
                        ASI_CRM_Volume_Base__c, // no need
                        //ASI_TH_CRM_Amount__c, // no need
                        ASI_TH_CRM_Payment_Request__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Region__c,
                        ASI_TH_CRM_Quantity__c,
                        ASI_CRM_CN_WS_Intake_9L__c,
                        ASI_CRM_CTD_Actual_Vol_Std__c,
                        ASI_CRM_CN_WS_Intake_Std__c,
                        ASI_CRM_CN_Outlet_Intake_Std__c,
                        ASI_CRM_CN_Outlet_Intake_9L__c,
                        //ASI_CRM_CN_Outlet_Offtake_9L__c,      // no need
                        ASI_CRM_CN_POS_Volume__c,
                        //ASI_CRM_CTD_Actual_Offtake_Value__c,  // no need
                        ASI_CRM_CN_POS_Value__c,
                        ASI_CRM_CTD_Actual_Retail_Value__c,
                        ASI_CRM_Actual_Value_Base__c,
                        Id,
                        RecordType.DeveloperName,
                        RecordTypeId,
                        ASI_CRM_CN_CRM_Code__c
                FROM ASI_TH_CRM_PaymentRequestLineItem__c
                WHERE ASI_TH_CRM_Payment_Request__c = :PH.Id
                and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods')
                ORDER BY ASI_CRM_CN_CRM_Code__c ASC 
        ];

        sumNum = PaymentItemList.size(); //获取Price Promotion 数据的总数
        sumNumPage = Math.ceil(sumNum / skipNum); // Price Promotion 总页数
        if(sumNumPage > 1) isNext = true; // Price Promotion 当页面数大于1时，默认勾选

        List<ASI_TH_CRM_PaymentRequestLineItem__c> interList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

        Set<Id> wsIntakeSet = new Set<Id>();
        Set<Id> CTDAutualPurchaseValueSet = new Set<Id>();

        Decimal num = 0;
        for (ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : PaymentItemList) {
            switch on paymentLine.RecordType.DeveloperName {
                when 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS' {
                    /*
                        Author:Bowen
                        Date:2019-09-03
                        function:
                            1.当属于南区，并且ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion'，如果存在相同的ASI_CRM_CN_Wholesaler__c，
                            则不再累加
                            2.其他区不做特殊处理，全部汇总
                     */
                    if(paymentLine.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' && 
                        paymentLine.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Region__c == 'South Region')
                    {
                        if(!wsIntakeSet.contains(paymentLine.ASI_CRM_CN_Wholesaler__c))
                        {
                            WS_Intake_9L += paymentLine.ASI_CRM_CN_WS_Intake_9L__c == null ? 0 :paymentLine.ASI_CRM_CN_WS_Intake_9L__c;
                            CTD_Actual_Purchase_Value += paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c == null ? 0 :paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c;
                            wsIntakeSet.add(paymentLine.ASI_CRM_CN_Wholesaler__c);
                        }
                    }
                    else
                    {
                        WS_Intake_9L += paymentLine.ASI_CRM_CN_WS_Intake_9L__c == null ? 0 :paymentLine.ASI_CRM_CN_WS_Intake_9L__c;
                        CTD_Actual_Purchase_Value += paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c == null ? 0 :paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c;
                    }
                    Outlet_Intake_9L += paymentLine.ASI_CRM_CN_Outlet_Intake_9L__c == null ? 0 :paymentLine.ASI_CRM_CN_Outlet_Intake_9L__c;
                    CTD_Actual_Retail_Value += paymentLine.ASI_CRM_CTD_Actual_Retail_Value__c == null ? 0 : paymentLine.ASI_CRM_CTD_Actual_Retail_Value__c;
                    Actual_Value_Base += paymentLine.ASI_CRM_Actual_Value_Base__c == null ? 0 : paymentLine.ASI_CRM_Actual_Value_Base__c;

                    POS_Volume_9L += paymentLine.ASI_CRM_CN_POS_Volume__c == null ? 0 : paymentLine.ASI_CRM_CN_POS_Volume__c;
                    POS_Value += paymentLine.ASI_CRM_CN_POS_Value__c == null ? 0 : paymentLine.ASI_CRM_CN_POS_Value__c;

                    interimData interimData = new interimData();
                    interimData.paymentRequestLineOutletWS = paymentLine;

                    if(num >= skipNum) continue;
                    interList.add(paymentLine);
                    
                    num ++;
                    
                }
                when 'ASI_CRM_CN_Payment_Request_Detail_Promotion' {

                }
                when 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods' {
                    if (paymentLine.ASI_CRM_CN_Suggest_Unit_Price__c == null)
                        paymentLine.ASI_CRM_CN_Suggest_Unit_Price__c = 0;
                    freeGoodsInterimData.paymentRequestLines.add(paymentLine);
                }
            }

        }
        system.debug('interList.size() == '+interList.size());
        for(Decimal i = interList.size()-1 ; i>=0 ;i--)
        {
            ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = interList.get(Integer.valueOf(i));
            interimData interimData = new interimData();
            interimData.paymentRequestLineOutletWS = paymentLine;
            interimDataMap.put(paymentLine.ASI_CRM_CN_CRM_Code__c, interimData);
            
        }
        // system.debug('JSON.serialize(interimDataMap) ===' + JSON.serialize(interimDataMap));
        Set<Id> parentModuleIdSet = new Set<Id>();
        moduleActualPaymentMap_ByPage = new Map<Decimal ,Decimal>();
        moduleActualPaymentMap_ByController = new Map<String ,Decimal>();

        for (ASI_CRM_Module__c module : [
                SELECT
                        ASI_CRM_Actual_Payment__c,
                        //ASI_CRM_Adjustment__c,
                        ASI_CRM_Application_Payment_Amount__c,
                        //ASI_CRM_CN_CTD_Minimal_Achievement__c,
                        //ASI_CRM_CN_Contract_Volume_Base__c,
                        //ASI_CRM_CN_KPI_Base__c,
                        //ASI_CRM_CN_Total_Markup__c,
                        //ASI_CRM_CN_Minimal_Achievement__c,
                        //ASI_CRM_CN_Is_Capped__c,
                        //ASI_CRM_CN_Criteria__c,
                        ASI_CRM_CN_Customer__c,
                        ASI_CRM_CN_Customer__r.ASI_CRM_CN_CRM_Code__c,
                        //ASI_CRM_Completion_Ratio__c,
                        ASI_CRM_End_Date__c,
                        ASI_CRM_Historical_Paid_Amount__c,
                        ASI_CRM_Line_Type__c,
                        ASI_CRM_Methodology__c,
                        ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                        //ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                        ASI_CRM_Methodology__r.Name,
                        ASI_CRM_Other_Comments__c,
                        //ASI_CRM_Overpayment_Reason__c,
                        ASI_CRM_Parent_Module__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,
                        ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_CN_Criteria__c,
                        ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Parent_Module__r.Name,
                        //ASI_CRM_PSF_Overpayment_Reason__c,
                        ASI_CRM_Created_PO_Version__c,
                        //ASI_CRM_Reason_NCD_Volume_Base__c,
                        //ASI_CRM_Reason_Not_NCD_Methodology__c,
                        //ASI_CRM_Remark__c,
                        //ASI_CRM_Suggested_Payable_Amount__c,
                        //ASI_CRM_Unit__c,
                        //ASI_CRM_VEC_Overpayment_Reason__c,
                        ASI_CRM_Volume_Base__c,
                        Id, (
                        SELECT
                        //ASI_CRM_Brand_Code__c,
                        //ASI_CRM_CN_AC_Code__c,
                                ASI_CRM_CN_Actual_Vol__c,
                                ASI_CRM_CN_Allow_Changing_Incentive__c,
                                ASI_CRM_CN_Comment__c,
                                ASI_CRM_Customer__c,
                                ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_Customer__r.Name,
                                //ASI_CRM_CN_Completion_Rate__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Total_Dummy__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Est_Total_Dummy__c,
                                //ASI_CRM_CN_Rebate__c,
                                ASI_CRM_CN_Rebate_Percent__c,
                                //ASI_CRM_CN_Target__c,
                                ASI_CRM_Historical_Paid_Amount__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_std_Btl__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_std_Btl__c,
                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                                //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Contract_Amount__c,
                                //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_Contract_Terms__c,
                                //ASI_CRM_CN_Expense_Type__c,
                                //ASI_CRM_CN_Incentive_BT__c,
                                ASI_CRM_CN_Item_Group__c,
                                ASI_CRM_CN_Item_Group__r.Name,
                                ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,
                                //ASI_CRM_CN_Payable_Vol__c,
                                //ASI_CRM_CN_Remaining_Amount__c,
                                //ASI_CRM_CN_Standard__c,
                                ASI_CRM_CN_Sub_Brand__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                ASI_CRM_CN_Sub_Brand__r.Name,
                                //ASI_CRM_CN_Suggested_Amount__c,
                                ASI_CRM_CN_Total_Payable__c,
                                ASI_CRM_CN_Wholesaler__c,
                                ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_CN_Wholesaler__r.Name,
                                //ASI_CRM_CNY_Est__c,
                                ASI_CRM_CTD_Actual_Purchase_Value__c,
                                ASI_CRM_CTD_Actual_Vol__c,
                                //ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,
                                //ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,
                                //ASI_CRM_Key_Sub_Brand__c,
                                //ASI_CRM_Line_Name__c,
                                ASI_CRM_Line_Long_Name__c,
                                //ASI_CRM_MAF_Est__c,
                                //ASI_CRM_Max_Incentive__c,
                                ASI_CRM_Module__c,
                                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                                //ASI_CRM_Non_Contract_Line__c,
                                //ASI_CRM_Other_Est__c,
                                //ASI_CRM_Over_Incentive__c,
                                //ASI_CRM_Product_Category__c,
                                //ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                //ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                //ASI_CRM_Product_Category__r.Name,
                                //ASI_CRM_Sub_Brand_Grade__c,
                                //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                //ASI_CRM_System_Payable_Vol_Std_Bottle__c,
                                ASI_CRM_Unit_Price__c,
                                ASI_CRM_CN_Suggest_Unit_Price__c,
                                //ASI_CRM_V0_0_Full_Contract_Target__c,
                                ASI_CRM_Volume_Base__c,
                                //ASI_TH_CRM_Amount__c,
                                ASI_TH_CRM_Payment_Request__c,
                                ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                                ASI_TH_CRM_Quantity__c,
                                ASI_CRM_CN_WS_Intake_9L__c,
                                ASI_CRM_CTD_Actual_Vol_Std__c,
                                ASI_CRM_CN_WS_Intake_Std__c,
                                ASI_CRM_CN_Outlet_Intake_Std__c,
                                ASI_CRM_CN_Outlet_Intake_9L__c,
                                //ASI_CRM_CN_Outlet_Offtake_9L__c,
                                ASI_CRM_CN_POS_Volume__c,
                                //ASI_CRM_CTD_Actual_Offtake_Value__c,
                                ASI_CRM_CN_POS_Value__c,
                                ASI_CRM_CTD_Actual_Retail_Value__c,
                                ASI_CRM_Actual_Value_Base__c,
                                Id,
                                RecordType.DeveloperName,
                                RecordTypeId ,
                                ASI_CRM_CN_CRM_Code__c
                        FROM Payment_Request_Line_Items__r
                        WHERE ASI_TH_CRM_Payment_Request__c = :PH.Id
                        ORDER BY ASI_CRM_CN_CRM_Code__c DESC
                )
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Payment_Request__c = :PageId
        ]) {

            if (module.ASI_CRM_Line_Type__c == PRICE_PROMOTION_MODULE_TYPE) {
                if(moduleActualPaymentMap_ByController.containsKey(module.ASI_CRM_Parent_Module__c))
                {
                    Decimal actualNum = moduleActualPaymentMap_ByController.get(module.ASI_CRM_Parent_Module__c) ;
                    actualNum += denullify(module.ASI_CRM_Actual_Payment__c) ;
                    moduleActualPaymentMap_ByController.put(module.ASI_CRM_Parent_Module__c, actualNum);
                    Total_this_time_payment += module.ASI_CRM_Actual_Payment__c == null ? 0 : module.ASI_CRM_Actual_Payment__c;
                }
                else
                {
                    Decimal actualNum = 0;
                    actualNum += denullify(module.ASI_CRM_Actual_Payment__c);
                    moduleActualPaymentMap_ByController.put(module.ASI_CRM_Parent_Module__c, actualNum);
                    Total_this_time_payment += module.ASI_CRM_Actual_Payment__c == null ? 0 : module.ASI_CRM_Actual_Payment__c;
                }
                Total_Suggest_Incentive += module.ASI_CRM_Application_Payment_Amount__c == null ? 0 : module.ASI_CRM_Application_Payment_Amount__c;
                Historical_Paid_Amount += module.ASI_CRM_Historical_Paid_Amount__c == null ? 0 : module.ASI_CRM_Historical_Paid_Amount__c;

                if (module.Payment_Request_Line_Items__r.isEmpty()) {
                    continue;
                }
                ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = module.Payment_Request_Line_Items__r[0];

                interimData interimData;
                
                if(!interimDataMap.containsKey(paymentLine.ASI_CRM_CN_CRM_Code__c))
                {
                    continue;
                }
                if (PH.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion') {
                    interimData = interimDataMap.get(paymentLine.ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c);
                } else if (PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion) {
                    interimData = interimDataMap.get(paymentLine.ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c + paymentLine.ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c);
                } else {
                    interimData = interimDataMap.get(paymentLine.ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c);
                }

                if (interimData == null) {
                    continue;
                }

                interimData moduleWrapper = new interimData();
                moduleWrapper.module = module;
                // 
                if (module.ASI_CRM_Line_Type__c == FREE_GOODS_MODULE_TYPE) {
                    moduleWrapper.paymentRequestLines = module.Payment_Request_Line_Items__r;
                }
                moduleWrapper.ASI_CRM_Application_Payment_Amount = denullify(module.ASI_CRM_Actual_Payment__c).setScale(2);

                interimData.moduleWrappers.add(moduleWrapper);

                // Assume all Price Promotion modules have same end date
                endDate = module.ASI_CRM_End_Date__c;
            }
            if (module.ASI_CRM_Line_Type__c == FREE_GOODS_MODULE_TYPE) {
                freeGoodsInterimData.module = module;
                if(endDate == null) {
                    endDate = module.ASI_CRM_End_Date__c;
                }
            }
            if (module.ASI_CRM_Line_Type__c == VISIBILITY_MODULE_TYPE) {
                visibilityModule = module;
                if(endDate == null) {
                    endDate = module.ASI_CRM_End_Date__c;
                }
            }
            //            interimDataMap.put(module.Id, interimData);
        }

        if(!moduleActualPaymentMap_ByController.isEmpty())
        {
            Decimal i = 1;
            for(String mapKey : moduleActualPaymentMap_ByController.keySet())
            {

                moduleActualPaymentMap_ByPage.put(i, moduleActualPaymentMap_ByController.get(mapKey));
                i++;
            }
        }

        // Create module if no module found
        if (freeGoodsInterimData.module.Id == null) {
            freeGoodsInterimData.module = new ASI_CRM_Module__c(
                    ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_Line_Type__c = FREE_GOODS_MODULE_TYPE,
                    ASI_CRM_Payment_Request__c = PageId
            );
        }
        if (visibilityModule == null) {
            visibilityModule = new ASI_CRM_Module__c(
                    ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_Line_Type__c = VISIBILITY_MODULE_TYPE,
                    ASI_CRM_Actual_Payment__c = 0,
                    ASI_CRM_Payment_Request__c = PageId
            );
        }

        //Get Historical Module and Amount
        for(ASI_CRM_Module__c module :[ SELECT Id
                                        FROM ASI_CRM_Module__c
                                        WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                                        AND ASI_CRM_Line_Type__c = :PRICE_PROMOTION_MODULE_TYPE
                                        AND ASI_CRM_Parent_Module__c = null]){
            parentModuleIdSet.add(module.Id);
        }
        if(parentModuleIdSet.size()>0){
            List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();
            moduleList = ASI_CRM_CN_PromotionPaymentUtilClass.HistoricalModuleQuerying(parentModuleIdSet, PageId);
            HistoricalAmountMap = ASI_CRM_CN_PromotionPaymentUtilClass.GetHistoricalAmountMap(moduleList);
        }

        Suggested_this_time_payment = Total_Suggest_Incentive-Historical_Paid_Amount;
         /*
            Author:Bowen
            Date:2019-09-02
            Function：原逻辑是vs_suggested = Suggested_this_time_payment - Total_this_time_payment;
            应客户方BA的要求，将逻辑修改为vs_suggested = Total_this_time_payment - Suggested_this_time_payment;

         */
        vs_suggested = Total_this_time_payment - Suggested_this_time_payment;

        if(Actual_Value_Base != 0)
        {
            Actual_Incentive =  ( Total_this_time_payment + Historical_Paid_Amount ) / Actual_Value_Base * 100;
        }
        else
        {
            Actual_Incentive = 0;
        }
        if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Cash')||PH.ASI_CRM_CN_Payment_Type__c.contains('cash')))
            cashtype = true;
        else
            cashtype = false;

        
        // Actual_Incentive = (Historical_Paid_Amount +Suggested_this_time_payment) /
        if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Discount')||PH.ASI_CRM_CN_Payment_Type__c.contains('discount')))
            discounttype = true;
        else
            discounttype = false;



        integer indexCASH = 0;
        integer indexDISCOUNT = 0;
        integer indexCD = 0;

        List<ASI_CRM_CN_PH_Payee_Line_Item__c> LPHPayeeAll = [SELECT ASI_CRM_CN_Amount__c, ASI_CRM_CN_Cash_Discount__c, ASI_CRM_CN_Cash_Amount__c, ASI_CRM_CN_Discount_Amount__c,
                                                              ASI_CRM_CN_Payment_Request__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_T1__r.Name, ASI_CRM_CN_Payee_T1__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T1__r.Name,
                                                              ASI_CRM_CN_Reason__c , ASI_CRM_CN_Payee_T2__r.Name, ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Comfirm_Receipt__c,
                                                              ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name, RecordTypeId, ASI_CRM_CN_Instruction_Sent_Time__c
                                                              FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                                                              WHERE ASI_CRM_CN_Payment_Request__c = :PH.Id and
                                                              (ASI_CRM_CN_Type__c = 'Cash' or ASI_CRM_CN_Type__c = 'Discount' or ASI_CRM_CN_Type__c = 'Others' OR ASI_CRM_CN_Type__c = 'CD')];

        for(ASI_CRM_CN_PH_Payee_Line_Item__c payee : LPHPayeeAll){
            if(payee.ASI_CRM_CN_Type__c == 'Cash'){
                Payee_Item_Map_CASH.put(indexCASH++, payee);
            }else if(payee.ASI_CRM_CN_Type__c == 'Discount'){
                Payee_Item_Map_DISCOUNT.put(indexDISCOUNT++, payee);
            }else if(payee.ASI_CRM_CN_Type__c == 'Others' || payee.ASI_CRM_CN_Type__c == 'CD'){
                Payee_Item_Map_CD.put(indexCD++, payee);
            }
        }

        interimDataMapJSON = JSON.serialize(interimDataMap);
        freeGoodsInterimDataJSON = JSON.serialize(freeGoodsInterimData);
        colHeaders = getColHeaders(PH.ASI_CRM_CN_Promotion_Type__c, PH.ASI_CRM_CN_Region__c);
        colHeadersJSON = JSON.serialize(colHeaders);
    }

    /*
        Author:Bowen
        Date:2019-08-06
        Function : Price Promotion模块的分页功能，
    */
    public void NextPage()
    {
        if(PageSkipType == 'Next' || PageSkipType == 'Last')
        {
            saveItems();
        }
        System.debug('NextPage' + PageSkipType);
        Decimal offsetNum = 0;
        if(PageSkipType == 'Next')
        {
            totalNumPage += 1; // 回传的是next，代表下一页，故+1
        }
        else if(PageSkipType == 'Last')
        {
            totalNumPage -= 1;// 回传的是Last，代表上一页，故-1
        }

        if(PageSkipType != 'Next' && PageSkipType != 'Last')
        {
            WS_Intake_9L = 0; // WS Intake (9L) 批发商进货量（9L)
            CTD_Actual_Purchase_Value = 0; // CTD Actual Purchase Value 批发商进货金额
            POS_Volume_9L = 0; // POS Volume (9L) 
            POS_Value = 0; // POS Value
            Outlet_Intake_9L = 0; // Outlet Intake (9L) 店家进货量（9L)
            CTD_Actual_Retail_Value = 0; // CTD Actual Retail Value 店家进货金额
            Actual_Value_Base = 0; // WS Intake (9L) 实际销售金额
            Total_Suggest_Incentive = 0; // Total Suggest Incentive 合同至今应付金额
            Historical_Paid_Amount = 0; // Historical Paid Amount 已支付金额
            Suggested_this_time_payment = 0; // Suggested this time payment 支付金额
            Total_this_time_payment = 0; // Total this time payment 实际支付金额
            Actual_Incentive = 0; // Actual Incentive%  实际返点%
            vs_suggested = 0; // vs. suggested  vs.支付金额
        }

        System.debug('当前页=='+totalNumPage);
        offsetNum = (totalNumPage - 1) * skipNum; // 需从第几条数据开始查
        System.debug(LoggingLevel.INFO, '*** skipNum22: ' + skipNum);
        String recordTypeName = 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS';
        String phId =PH.Id;

        List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        String sqlStr = 'SELECT '
                +' ASI_CRM_CN_Actual_Vol__c,'
                +' ASI_CRM_CN_Allow_Changing_Incentive__c,'
                +' ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Region__c,'
                +' ASI_CRM_CN_Comment__c,'
                +' ASI_CRM_Customer__c,'
                +' ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,'
                +' ASI_CRM_Customer__r.Name,'
                +' ASI_CRM_CN_Rebate_Percent__c,'
                +' ASI_CRM_Historical_Paid_Amount__c,' //no need
                +' ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,'
                +' ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,'
                +' ASI_CRM_CN_Item_Group__c, '  // no need
                +' ASI_CRM_CN_Item_Group__r.Name, ' // no need
                +' ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,'    // no need
                +' ASI_CRM_CN_Sub_Brand__c,'
                +' ASI_CRM_CN_Total_Payable__c,'
                +' ASI_CRM_CN_Wholesaler__c,'
                +' ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,'
                +' ASI_CRM_CN_Wholesaler__r.Name,'
                +' ASI_CRM_CTD_Actual_Purchase_Value__c,'
                +' ASI_CRM_CTD_Actual_Vol__c,'
                +' ASI_CRM_Line_Long_Name__c,'
                +' ASI_CRM_Module__c,'
                +' ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,'
                +' ASI_CRM_Volume_Base__c,' // no need
                +' ASI_TH_CRM_Payment_Request__c,'
                +' ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,'
                +' ASI_CRM_CN_WS_Intake_9L__c,'
                +' ASI_CRM_CTD_Actual_Vol_Std__c,'
                +' ASI_CRM_CN_WS_Intake_Std__c,'
                +' ASI_CRM_CN_Outlet_Intake_Std__c,'
                +' ASI_CRM_CN_Outlet_Intake_9L__c,'
                +' ASI_CRM_CN_POS_Volume__c,'
                +' ASI_CRM_CN_POS_Value__c,'
                +' ASI_CRM_CTD_Actual_Retail_Value__c,'
                +' ASI_CRM_Actual_Value_Base__c,'
                +' Id,'
                +' RecordType.DeveloperName,'
                +' RecordTypeId'
                +' FROM ASI_TH_CRM_PaymentRequestLineItem__c'
                +' WHERE ASI_TH_CRM_Payment_Request__c =: phId'
                +' and recordType.DeveloperName =: recordTypeName';
        if(PageSkipType == 'Next' || PageSkipType == 'Last')
        {
            sqlStr += ' ORDER BY ASI_CRM_CN_CRM_Code__c ASC limit '+ skipNum +' offset '+offsetNum;
        }
        System.debug('sqlStr ===' + sqlStr);

        PaymentItemList = Database.query(sqlStr);
        System.debug('PaymentItemList ==' + PaymentItemList);


        if(sumNumPage > totalNumPage)
        {
            isNext = true; // 总页数大于当前页数，下一页 按钮需显示
        }
        else
        {
            isNext = false; // 反之，下一页 按钮不需显示
        }
        if(totalNumPage == 1)
        {
            isFirst = false;// 当前页为第一页，上一页 按钮不需显示
        }
        else
        {
            isFirst = true;// 反之，上一页 按钮需显示
        }

        System.debug('isNext ==' + isNext + '---isFirst==='+isFirst);

        interimDataMap.clear();

        Set<Id> wsIntakeSet = new Set<Id>();
        Decimal num = 0;
        for (Decimal i = PaymentItemList.size() - 1 ;i >= 0 ; i--) {
            ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = PaymentItemList.get(Integer.valueOf(i));
            if(PageSkipType != 'Next' && PageSkipType != 'Last')
            {
                /*
                    Author:Bowen
                    Date:2019-09-03
                    function:
                        1.当属于南区，并且ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion'，如果存在相同的ASI_CRM_CN_Wholesaler__c，
                        则不再累加
                        2.其他区不做特殊处理，全部汇总
                 */
                if(paymentLine.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' && 
                    paymentLine.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Region__c == 'South Region')
                {
                    if(!wsIntakeSet.contains(paymentLine.ASI_CRM_CN_Wholesaler__c))
                    {
                        WS_Intake_9L += paymentLine.ASI_CRM_CN_WS_Intake_9L__c == null ? 0 :paymentLine.ASI_CRM_CN_WS_Intake_9L__c;
                        CTD_Actual_Purchase_Value += paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c == null ? 0 :paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c;
                        wsIntakeSet.add(paymentLine.ASI_CRM_CN_Wholesaler__c);
                    }
                }
                else
                {
                    WS_Intake_9L += paymentLine.ASI_CRM_CN_WS_Intake_9L__c == null ? 0 :paymentLine.ASI_CRM_CN_WS_Intake_9L__c;
                    CTD_Actual_Purchase_Value += paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c == null ? 0 :paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c;
                }
                Outlet_Intake_9L += paymentLine.ASI_CRM_CN_Outlet_Intake_9L__c == null ? 0 :paymentLine.ASI_CRM_CN_Outlet_Intake_9L__c;
                CTD_Actual_Retail_Value += paymentLine.ASI_CRM_CTD_Actual_Retail_Value__c == null ? 0 : paymentLine.ASI_CRM_CTD_Actual_Retail_Value__c;
                Actual_Value_Base += paymentLine.ASI_CRM_Actual_Value_Base__c == null ? 0 : paymentLine.ASI_CRM_Actual_Value_Base__c;

                POS_Volume_9L += paymentLine.ASI_CRM_CN_POS_Volume__c == null ? 0 : paymentLine.ASI_CRM_CN_POS_Volume__c;
                POS_Value += paymentLine.ASI_CRM_CN_POS_Value__c == null ? 0 : paymentLine.ASI_CRM_CN_POS_Value__c;
            }
            if(num >= skipNum) continue;
            num ++;

            interimData interimData = new interimData();
            interimData.paymentRequestLineOutletWS = paymentLine;
            if (PH.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion') {
                interimDataMap.put(paymentLine.ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c, interimData);
            } else if (PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion) {
                interimDataMap.put(paymentLine.ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c + paymentLine.ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c, interimData);
            } else {
                interimDataMap.put(paymentLine.ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c, interimData);
            }
        }
        System.debug('interimDataMap ==' + interimDataMap.size());

        moduleActualPaymentMap_ByPage = new Map<Decimal ,Decimal>();
        moduleActualPaymentMap_ByController = new Map<String ,Decimal>();

        for (ASI_CRM_Module__c module : [
                SELECT
                        ASI_CRM_Actual_Payment__c,
                        ASI_CRM_Application_Payment_Amount__c,
                        ASI_CRM_CN_Customer__c,
                        ASI_CRM_CN_Customer__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_End_Date__c,
                        ASI_CRM_Historical_Paid_Amount__c,
                        ASI_CRM_Line_Type__c,
                        ASI_CRM_Methodology__c,
                        ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_Methodology__r.Name,
                        ASI_CRM_Other_Comments__c,
                        ASI_CRM_Parent_Module__c,
                        ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                        // ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Parent_Module__r.Name,
                        // ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Volume_Base__c,
                        Id, (
                        SELECT
                                ASI_CRM_CN_Actual_Vol__c,
                                ASI_CRM_CN_Allow_Changing_Incentive__c,
                                ASI_CRM_CN_Comment__c,
                                ASI_CRM_Customer__c,
                                ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_Customer__r.Name,
                                ASI_CRM_CN_Rebate_Percent__c,
                                ASI_CRM_Historical_Paid_Amount__c,
                                // ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                                // ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                                ASI_CRM_CN_Item_Group__c,
                                ASI_CRM_CN_Item_Group__r.Name,
                                ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,
                                ASI_CRM_CN_Sub_Brand__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                ASI_CRM_CN_Sub_Brand__r.Name,
                                ASI_CRM_CN_Total_Payable__c,
                                ASI_CRM_CN_Wholesaler__c,
                                ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_CN_Wholesaler__r.Name,
                                ASI_CRM_CTD_Actual_Purchase_Value__c,
                                ASI_CRM_CTD_Actual_Vol__c,
                                // ASI_CRM_Line_Long_Name__c,
                                ASI_CRM_Module__c,
                                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                                ASI_CRM_Unit_Price__c,
                                ASI_CRM_CN_Suggest_Unit_Price__c,
                                ASI_CRM_Volume_Base__c,
                                ASI_TH_CRM_Payment_Request__c,
                                ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                                ASI_TH_CRM_Quantity__c,
                                ASI_CRM_CN_WS_Intake_9L__c,
                                ASI_CRM_CTD_Actual_Vol_Std__c,
                                ASI_CRM_CN_WS_Intake_Std__c,
                                ASI_CRM_CN_Outlet_Intake_Std__c,
                                ASI_CRM_CN_Outlet_Intake_9L__c,
                                ASI_CRM_CN_POS_Volume__c,
                                ASI_CRM_CN_POS_Value__c,
                                ASI_CRM_CTD_Actual_Retail_Value__c,
                                ASI_CRM_Actual_Value_Base__c,
                                Id,
                                RecordType.DeveloperName,
                                RecordTypeId ,
                                ASI_CRM_CN_CRM_Code__c
                        FROM Payment_Request_Line_Items__r
                        WHERE ASI_TH_CRM_Payment_Request__c = :PH.Id
                        ORDER BY ASI_CRM_CN_CRM_Code__c ASC
                )
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Payment_Request__c = :PageId
        ]) {

            if (module.ASI_CRM_Line_Type__c == PRICE_PROMOTION_MODULE_TYPE) {

                if(moduleActualPaymentMap_ByController.containsKey(module.ASI_CRM_Parent_Module__c))
                {
                    Decimal actualNum = moduleActualPaymentMap_ByController.get(module.ASI_CRM_Parent_Module__c) ;
                    actualNum += module.ASI_CRM_Actual_Payment__c;
                    moduleActualPaymentMap_ByController.put(module.ASI_CRM_Parent_Module__c, actualNum);
                    Total_this_time_payment += module.ASI_CRM_Actual_Payment__c == null ? 0 : module.ASI_CRM_Actual_Payment__c;
                }
                else
                {
                    Decimal actualNum = 0;
                    actualNum += module.ASI_CRM_Actual_Payment__c;
                    moduleActualPaymentMap_ByController.put(module.ASI_CRM_Parent_Module__c, actualNum);
                    Total_this_time_payment += module.ASI_CRM_Actual_Payment__c == null ? 0 : module.ASI_CRM_Actual_Payment__c;
                }
                Total_Suggest_Incentive += module.ASI_CRM_Application_Payment_Amount__c == null ? 0 : module.ASI_CRM_Application_Payment_Amount__c;
                Historical_Paid_Amount += module.ASI_CRM_Historical_Paid_Amount__c == null ? 0 : module.ASI_CRM_Historical_Paid_Amount__c;


                if (module.Payment_Request_Line_Items__r.isEmpty()) {
                    continue;
                }
                interimData interimData;
                ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = module.Payment_Request_Line_Items__r[0];
                if(!interimDataMap.containsKey(paymentLine.ASI_CRM_CN_CRM_Code__c))continue;
                
                if (PH.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion') {
                    interimData = interimDataMap.get(paymentLine.ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c);
                } else if (PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion) {
                    interimData = interimDataMap.get(paymentLine.ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c + paymentLine.ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c);
                } else {
                    interimData = interimDataMap.get(paymentLine.ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c);
                }

                if (interimData == null) {
                    continue;
                }

                interimData moduleWrapper = new interimData();

                moduleWrapper.module = module;
                if (module.ASI_CRM_Line_Type__c == FREE_GOODS_MODULE_TYPE) {
                    moduleWrapper.paymentRequestLines = module.Payment_Request_Line_Items__r;
                }
                moduleWrapper.ASI_CRM_Application_Payment_Amount = module.ASI_CRM_Actual_Payment__c.setScale(2);

                interimData.moduleWrappers.add(moduleWrapper);
                // Assume all Price Promotion modules have same end date
                endDate = module.ASI_CRM_End_Date__c;
            }
            if (module.ASI_CRM_Line_Type__c == FREE_GOODS_MODULE_TYPE) {
                freeGoodsInterimData.module = module;
            }
            if (module.ASI_CRM_Line_Type__c == VISIBILITY_MODULE_TYPE) {
                visibilityModule = module;
            }
            //            interimDataMap.put(module.Id, interimData);
        }

        // Create module if no module found
        if (freeGoodsInterimData.module.Id == null) {
            freeGoodsInterimData.module = new ASI_CRM_Module__c(
                    ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_Line_Type__c = FREE_GOODS_MODULE_TYPE,
                    ASI_CRM_Payment_Request__c = PageId
            );
        }
        if (visibilityModule == null) {
            visibilityModule = new ASI_CRM_Module__c(
                    ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_Line_Type__c = VISIBILITY_MODULE_TYPE,
                    ASI_CRM_Payment_Request__c = PageId
            );
        }
        Suggested_this_time_payment = Total_Suggest_Incentive-Historical_Paid_Amount;
         /*
            Author:Bowen
            Date:2019-09-02
            Function：原逻辑是vs_suggested = Suggested_this_time_payment - Total_this_time_payment;
            应客户方BA的要求，将逻辑修改为vs_suggested = Total_this_time_payment - Suggested_this_time_payment;

         */
        vs_suggested = Total_this_time_payment - Suggested_this_time_payment;

        if(Actual_Value_Base != 0)
        {
            Actual_Incentive =  ( Total_this_time_payment + Historical_Paid_Amount ) / Actual_Value_Base * 100;
        }
        else
        {
            Actual_Incentive = 0;
        }
        // Actual_Incentive = (Historical_Paid_Amount +Suggested_this_time_payment) /
        // 
        if(!Test.isRunningTest()){
            interimDataMapJSON = JSON.serialize(interimDataMap);
        }
        freeGoodsInterimDataJSON = JSON.serialize(freeGoodsInterimData);
        colHeaders = getColHeaders(PH.ASI_CRM_CN_Promotion_Type__c, PH.ASI_CRM_CN_Region__c);
        colHeadersJSON = JSON.serialize(colHeaders);

    }

    public List<String> getColHeaders(String promotionType, String region) {
        List<String> colHeaders = new List<String>{
                'Validation Key'
        };
        if (promotionType == 'Outlet Promotion' && region == 'South Region') {
            colHeaders.addAll(new List<String>{
                    ASI_CRM_AccountsAdditionalField__c.ASI_CRM_CN_CRM_Code__c.getDescribe().getLabel(),
                    ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_Wholesaler__c.getDescribe().getLabel(),
                    ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_WS_Intake_9L__c.getDescribe().getLabel(),
                    ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Purchase_Value__c.getDescribe().getLabel()
            });
        }

        colHeaders.addAll(new List<String>{
                ASI_CRM_AccountsAdditionalField__c.ASI_CRM_CN_CRM_Code__c.getDescribe().getLabel(),
                ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_Customer__c.getDescribe().getLabel()
        });


        switch on promotionType {
            when 'Wholesaler Promotion' {
                if (dataSource == 'Min(WS Intake, Outlet Intake)') {
                    colHeaders.addAll(new List<String>{
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_WS_Intake_9L__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Purchase_Value__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_Outlet_Intake_9L__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Retail_Value__c.getDescribe().getLabel()
                    });
                } else if(dataSource == 'Outlet Intake'){
                    colHeaders.addAll(new List<String>{
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_Outlet_Intake_9L__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Retail_Value__c.getDescribe().getLabel()
                    });
                }else {
                    colHeaders.addAll(new List<String>{
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_WS_Intake_9L__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Purchase_Value__c.getDescribe().getLabel()
                    });

                }
            }
            when 'Outlet Promotion' {
                if(region == 'South Region') {
                    colHeaders.addAll(new List<String>{
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_Outlet_Intake_9L__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Retail_Value__c.getDescribe().getLabel()
                    });
                }else{
                    colHeaders.addAll(new List<String>{
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_Outlet_Intake_9L__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Retail_Value__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_POS_Volume__c.getDescribe().getLabel(),
                            ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_POS_Value__c.getDescribe().getLabel()
                    });
                    showWS = false;
                }
            }
            when 'Consumer Promotion' {
                colHeaders.addAll(new List<String>{
                        ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_Outlet_Intake_9L__c.getDescribe().getLabel(),
                        ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CTD_Actual_Retail_Value__c.getDescribe().getLabel(),
                        ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_POS_Volume__c.getDescribe().getLabel(),
                        ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_POS_Value__c.getDescribe().getLabel()
                });
                showWS = false;
            }
        }

        colHeaders.addAll(new List<String>{
                ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_Actual_Value_Base__c.getDescribe().getLabel(),
                '合同至今应付金额',
                ASI_CRM_Module__c.ASI_CRM_Historical_Paid_Amount__c.getDescribe().getLabel(),
                '支付金额',
                '实际支付金额',
                '实际返点%',
                'vs.支付金额',
                ASI_CRM_Module__c.ASI_CRM_Other_Comments__c.getDescribe().getLabel()
        });


        for (Integer i = 0; i < numberOfModules; i++) {
            Integer displayIndex = i + 1;
            colHeaders.add('项目指标 ' + displayIndex + ' 合同至今应付金额');
            if (promotionType == 'Wholesaler Promotion' && dataSource == 'Min(WS Intake, Outlet Intake)') {
                //colHeaders.add('Module ' + displayIndex + ' WS Purchase Value');
                //colHeaders.add('Module ' + displayIndex + ' Outlet Purchase Value');
            } else if (dataSource == 'WS Intake') {
                //                colHeaders.add('Module ' + displayIndex + ' WS Purchase Value');
            }

            colHeaders.add('项目指标' + displayIndex + '已支付金额');
            colHeaders.add('Validation Key');
            colHeaders.add('项目指标' + displayIndex + '实际支付金额');
        }

        return colHeaders;

    }


    /********************************************
    Page actions
    *********************************************/

    public PageReference GoEditHeader() {
        PageReference redirect = new PageReference(PAGE_NAME);
        redirect.getParameters().put('id', PageId);
        redirect.getParameters().put('isEditHeader', '1');
        redirect.setRedirect(true);
        return redirect;
    }

    public PageReference GoToCheckPoint() {
        Msg = ' ';
        UpsertPermission = true;

        // TODO enable checkpoint checking
        //        //Last Payment checking
        //        for (ASI_TH_CRM_PaymentRequest__c paymentTemp : ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {
        //            if (paymentTemp.ASI_CRM_CN_Last_Payment__c == true && paymentTemp.ASI_TH_CRM_Status__c != 'Draft') {
        //                ErrorHandling(Label.ASI_CRM_CN_ErrorMsg_MakePayment + paymentTemp.Name);
        //            }
        //        }
        //
        //
               //checking payment summary
               // List<ASI_CRM_CN_ContractOffUtilClass.PaymentSummary> PaymentSummaryList = new List<ASI_CRM_CN_ContractOffUtilClass.PaymentSummary> ();
               // PaymentSummaryList = ASI_CRM_CN_ContractOffUtilClass.PaymentSummaryTable(PH, ContractSelected);
               // System.debug('PaymentSummaryList ==' + PaymentSummaryList.size());
               // for (ASI_CRM_CN_ContractOffUtilClass.PaymentSummary SummaryData : PaymentSummaryList) {
               //      Decimal PORemainAmt = SummaryData.POEstimatedAmount - SummaryData.PaidAmount;
               //      System.debug('PORemainAmt ==' + PORemainAmt);
               //      System.debug('SummaryData.PaymentRequestAmount ==' + SummaryData.PaymentRequestAmount);
               //      System.debug('SummaryData.Name ==' + SummaryData.Name);
               //      if (SummaryData.PaymentRequestAmount > PORemainAmt + 1) {
               //          ErrorHandling(SummaryData.Name + Label.ASI_CRM_CN_Account_payment_amount_Checking);
               //      }
               // }
               // System.debug('UpsertPermission ==' + UpsertPermission);
        for(ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary SummaryData : PaymentSummaryList)
        {
            Decimal PORemainAmt = SummaryData.POEstimatedAmount - SummaryData.PaidAmount;
            System.debug('PORemainAmt ==' + PORemainAmt);
            System.debug('SummaryData.PaymentRequestAmount ==' + SummaryData.PaymentRequestAmount);
            System.debug('SummaryData.Name ==' + SummaryData.Name);
            if (SummaryData.PaymentRequestAmount > PORemainAmt + 1) {
                ErrorHandling(SummaryData.Name + Label.ASI_CRM_CN_Account_payment_amount_Checking);
            }
        }

        Decimal sum_of_payee_amount = 0;
        List<ASI_CRM_CN_PH_Payee_Line_Item__c> CheckpayeeLine = [select Id, ASI_CRM_CN_Amount__c from ASI_CRM_CN_PH_Payee_Line_Item__c where ASI_CRM_CN_Payment_Request__c = :PH.Id];
        if(CheckpayeeLine.size()>0){
            for(ASI_CRM_CN_PH_Payee_Line_Item__c p :CheckpayeeLine){
                sum_of_payee_amount += p.ASI_CRM_CN_Amount__c != null ? p.ASI_CRM_CN_Amount__c :0;
            }
        }
        Decimal payee_amount= sum_of_payee_amount.setScale(2, RoundingMode.HALF_UP);
        Decimal total_Amount= PH.ASI_CRM_CN_Total_Payment__c.setScale(2, RoundingMode.HALF_UP);
        if(payee_amount!=total_Amount){
            if(USerInfo.getLanguage()=='zh_CN')
               ErrorHandling('报错：付款方金额加总须与付款申请总额一致。付款方金额：'+payee_amount+'。 付款申请总额：'+total_Amount);
            else
               ErrorHandling('Error: The total amount in payment detail should consistent with the one in payment information.  Payment amount: '+payee_amount+'. Total Payment Amount: '+total_Amount);
        }


        //
        //
        //        Decimal sum_of_payee_amount = 0;
        //        //checking payee
        //        List<ASI_CRM_CN_PH_Payee_Line_Item__c> LPHPayeeAll = [
        //            SELECT ASI_CRM_CN_Amount__c, ASI_CRM_CN_Cash_Discount__c, ASI_CRM_CN_Cash_Amount__c, ASI_CRM_CN_Discount_Amount__c,
        //                ASI_CRM_CN_Payment_Request__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_T1__r.Name, ASI_CRM_CN_Payee_T1__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T1__r.Name,
        //                ASI_CRM_CN_Reason__c, ASI_CRM_CN_Payee_T2__r.Name, ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Comfirm_Receipt__c,
        //                ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name, RecordTypeId, ASI_CRM_CN_Instruction_Sent_Time__c
        //            FROM ASI_CRM_CN_PH_Payee_Line_Item__c
        //            WHERE ASI_CRM_CN_Payment_Request__c = :PH.Id AND
        //            (ASI_CRM_CN_Type__c = 'Cash' OR ASI_CRM_CN_Type__c = 'Discount' OR ASI_CRM_CN_Type__c = 'Others' OR ASI_CRM_CN_Type__c = 'CD')
        //        ];
        //
        //        for (ASI_CRM_CN_PH_Payee_Line_Item__c PayeeLine : LPHPayeeAll) {
        //            sum_of_payee_amount += PayeeLine.ASI_CRM_CN_Amount__c != null? PayeeLine.ASI_CRM_CN_Amount__c : 0;
        //        }
        //
        //
        //        List<ASI_Attachment__c> AttachmentList = new List<ASI_Attachment__c>();
        //        if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null) {
        //            AttachmentList = [
        //                SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
        //                FROM ASI_Attachment__c
        //                WHERE ASI_CRM_Contract__c = :ContractSelected.Id OR ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c
        //            ];
        //        } else {
        //            //Geting HistoricalV0.0 and VFinal Data
        //            AttachmentList = [
        //                SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
        //                FROM ASI_Attachment__c
        //                WHERE ASI_CRM_Contract__c = :ContractSelected.Id
        //            ];
        //
        //        }
        //
        //
        //        Decimal FixedCostTotal = 0;
        //        Decimal VariableCostTotal = 0;
        //        if (AttachmentList.size() > 0) {
        //            Map<String, Decimal> PaymentKPIMap = new Map<String, Decimal>();
        //
        //            for (ASI_Attachment__c att : AttachmentList) {
        //                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;', '"');
        //
        //                //General Payment Info
        //                if (att.ASI_CRM_Type__c == 'Payment Data' && att.ASI_CRM_Contract__c == ContractSelected.Id) {
        //
        //                    PaymentKPIMap = (Map<String, Decimal>) System.JSON.deserialize(JsonString, Map<String, Decimal>.class);
        //                    if (PaymentKPIMap.containsKey('FixedCostTotal')) {
        //                        FixedCostTotal = PaymentKPIMap.get('FixedCostTotal');
        //                    }
        //                    if (PaymentKPIMap.containsKey('VariableCostTotal')) {
        //                        VariableCostTotal = PaymentKPIMap.get('VariableCostTotal');
        //                    }
        //
        //                }
        //
        //            }
        //
        //        }
        //
        //        Decimal TotalAmount = (FixedCostTotal + VariableCostTotal);
        //        if (Math.abs(sum_of_payee_amount - TotalAmount) > 0.1) {
        //            String tempStr = Label.ASI_CRM_CN_Payment_total_amount_no_consistent;
        //            Decimal payee_amount = sum_of_payee_amount.setScale(2, RoundingMode.HALF_UP);
        //            List<String> fillers = new String[]{
        //                payee_amount.format(), TotalAmount.setScale(2, RoundingMode.HALF_UP).format()
        //            };
        //            ErrorHandling(String.format(tempStr, fillers));
        //        }
        //
        //
        //        if (TotalAmount > PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c) {
        //            String tempStr = Label.ASI_CRM_Payee_Amount_checking;
        //            List<String> fillers = new String[]{
        //                TotalAmount.format(), PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format()
        //            };
        //            ErrorHandling(String.format(tempStr, fillers));
        //        }


        if (UpsertPermission) {
            PageReference redirect = new PageReference('/apex/ASI_CRM_CN_PromotionCheckPointResultPage');
            redirect.getParameters().put('id', PageId);
            redirect.getParameters().put('Type', 'SubmitApproval');
            redirect.setRedirect(true);
            return redirect;
        } else {
            return null;
        }
    }

    public void ErrorHandling(String ErrorMsg) {
        Msg += ErrorMsg + '</br>';
        UpsertPermission = false;
    }

    public PageReference AutoPOModification() {
        if (ContractSelected.ASI_TH_CRM_Contract_Status__c == 'Final') {
            PH.ASI_CRM_Auto_PO_Modification__c = true;
            update PH;
            //ASI_CRM_CN_OffPaymentUtilClass.lastPaymentAutoPOModification(ContractSelected, PH.ASI_CRM_Volume_Cut_Off_Date__c);
            ASI_CRM_CN_PromotionPaymentUtilClass.lastPaymentAutoPOModification(ContractSelected, endDate);
            return new PageReference('/' + PageId);
        } else {
            UpsertPermission = false;
            Msg = '我们发现改合同不是    已批准 状态，无法继续执行PO自动修改。We found that contract is not in Final Status, cannot process Auto-PO Modi.';
            return null;
        }
    }

    public PageReference GoReturn() {
        Msg = '';
        List<ASI_TH_CRM_PaymentRequest__c> LPayment = [SELECT Id, ASI_TH_CRM_Status__c, ASI_CRM_CN_Return_Comments__c FROM ASI_TH_CRM_PaymentRequest__c WHERE Id = :PageId LIMIT 1];
        List<Profile> LProfileID = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        String profileName = LProfileID[0].Name;

        if (LPayment.size() > 0) {
            if (LPayment [0].ASI_TH_CRM_Status__c != 'Submitted') {
                if (UserInfo.getLanguage() == 'zh_CN') {
                    UpsertPermission = false;
                    Msg += '付款不得退回！\nPO付款状态仅在"已提交"时方可退回。';//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款不得退回！\nPO付款状态仅在"已提交"时方可退回。'));
                } else {
                    UpsertPermission = false;
                    Msg += 'Cannot Return Payment.\nOnly Payment with "Submitted" status can be returned';//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot Return Payment.\nOnly Payment with "Submitted" status can be returned'));
                }
            } else {
                if (LPayment[0].ASI_CRM_CN_Return_Comments__c != '') {
                    try {
                        LPayment[0].ASI_CRM_CN_Return_Comments__c = '';
                        update LPayment[0];
                    } catch (DmlException e) {
                        UpsertPermission = false;
                        Msg += 'Unable to save Return Comments.';//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Return Comments'));
                    }
                }

                PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_HeavyReturnPaymentPage?scontrolCaching=1&id=' + PageId);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        return null;
    }

    public PageReference GoEditDetailPage() {
        PageReference redirect = new PageReference(PAGE_NAME);
        redirect.getParameters().put('id', PageId);
        redirect.getParameters().put('isEdit', '1');
        redirect.setRedirect(true);
        return redirect;
    }
    public PageReference GoEditPayee() {
        if(ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Wholesaler Promotion' && (PH.ASI_CRM_CN_Payment_Type__c.contains('Discount')
                ||PH.ASI_CRM_CN_Payment_Type__c.contains('discount'))){
            List<ASI_CRM_CN_PH_Payee_Line_Item__c> CheckpayeeLine = [select Id from ASI_CRM_CN_PH_Payee_Line_Item__c 
                                                        where ASI_CRM_CN_Payment_Request__c = :PH.Id and (ASI_CRM_CN_Type__c = 'Discount' or ASI_CRM_CN_Type__c='Others')];
            if(CheckpayeeLine.size()>0) {
                delete CheckpayeeLine;
            }

            Map<Id, Decimal> paymentAmtByWSMap = new Map<Id, Decimal>();
            for (String key : interimDataMap.keySet()) {
                Decimal totalAmt = 0;
                for (interimData moduleWrapper : interimDataMap.get(key).moduleWrappers) {
                    totalAmt += moduleWrapper.module.ASI_CRM_Actual_Payment__c != null ? moduleWrapper.module.ASI_CRM_Actual_Payment__c : 0;
                }
                if (paymentAmtByWSMap.containsKey(interimDataMap.get(key).paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c)) {
                    Decimal oldValue = paymentAmtByWSMap.get(interimDataMap.get(key).paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c);
                    paymentAmtByWSMap.put(interimDataMap.get(key).paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c, oldValue + totalAmt);
                } else {
                    paymentAmtByWSMap.put(interimDataMap.get(key).paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c, totalAmt);
                }
            }

            List<ASI_CRM_Effective_supplier__c> suppliers =
            [SELECT ASI_CRM_Supplier__c,
                    ASI_CRM_Supplier__r.Id,
                    ASI_CRM_Supplier__r.Name,
                    ASI_CRM_Supplier__r.ASI_CRM_Account__r.id,
                    ASI_CRM_Supplier__r.ASI_CRM_Account__r.Name
            FROM ASI_CRM_Effective_supplier__c
            WHERE ASI_CRM_Account__c in :outletIds
            AND ASI_CRM_Last_tran_date__c > :system.today().addYears(-1)];
            set<Id> EffectiveSupplierSet = new set<Id>();
            if(suppliers.size()>0) {
                for (ASI_CRM_Effective_supplier__c supplier : suppliers) {
                    if (supplier.ASI_CRM_Supplier__c != null && supplier.ASI_CRM_Supplier__r.Id != null && supplier.ASI_CRM_Supplier__r.Name != null && supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__c != null) {
                        EffectiveSupplierSet.add(supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__c);
                    }
                }
            }

            if (paymentAmtByWSMap.size() > 0) {
                List<ASI_CRM_CN_PH_Payee_Line_Item__c> payeeLineList = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
                List<ASI_CRM_AccountsAdditionalField__c> WSList = [select ASI_CRM_T1_WS_Account__c, ASI_CRM_Account__c from ASI_CRM_AccountsAdditionalField__c where Id in :paymentAmtByWSMap.keySet()];
                if (WSList.size() > 0) {
                    for (ASI_CRM_AccountsAdditionalField__c ws : WSList) {
                        String type = EffectiveSupplierSet.contains(ws.ASI_CRM_Account__c) ? 'Discount' : 'Others';
                        ASI_CRM_CN_PH_Payee_Line_Item__c p = new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Type__c = type);
                        p.ASI_CRM_CN_Payment_Request__c = PH.Id;
                        p.ASI_CRM_CN_Amount__c = paymentAmtByWSMap.get(ws.Id).setScale(2);
                        p.ASI_CRM_CN_Payee_T2__c = ws.ASI_CRM_Account__c;
                        p.ASI_CRM_CN_Payee_T1__c = ws.ASI_CRM_T1_WS_Account__c;
                        payeeLineList.add(p);
                    }
                    if (payeeLineList.size() > 0) {
                        insert payeeLineList;
                    }
                }
            }
        }

        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_HeavyEditPaymentPayeePage');
        redirect.getParameters().put('id', PageId);
        redirect.setRedirect(true);
        return redirect;
    }

    public PageReference saveItems() {
        Date endDate = endDate;

        UpsertPermission = true;
        Msg = '';

        //        TODO validate date
        if (endDate > PH.ASI_CRM_CN_PO_End_Date__c) {
            UpsertPermission = false;
            Msg = 'End Date must be <= PO End Date!';
            return null;
        }
        //checking end day
        if (!ASI_CRM_DateUtilClass.isEndOfMonth(endDate)) {// Label.ASI_CRM_CN_PO_End_Date_Validation+
            Msg += Label.ASI_CRM_CN_PO_End_Date_Validation + '<br/>';//End Date should be the last day of the month .
            UpsertPermission = false;
            return null;
        }

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('isQuickSave');
        Boolean isQuickSave = (isQuickSaveStr == null)? false : Boolean.valueOf(isQuickSaveStr);
        PageReference redirect = new PageReference(PAGE_NAME);
        redirect.getParameters().put('id', PageId);
        if (isQuickSave) {
            redirect.getParameters().put('isEdit', '1');
        }
        redirect.setRedirect(true);
        freeGoodsInterimData = (interimData) JSON.deserialize(params.get('freeGoodsJSON'), interimData.class);
        interimDataMap = (Map<String, interimData>) JSON.deserialize(params.get('pricePromotionJSON'), Map<String, interimData>.class);

        // Update all Price Promotion modules End Date
        // for (interimData interimData : interimDataMap.values()) {
        //     interimData.module.ASI_CRM_End_Date__c = endDate;
        //     for (interimData moduleWrapper : interimData.moduleWrappers) {
        //         moduleWrapper.module.ASI_CRM_End_Date__c = endDate;
        //     }
        // }

        // if(visibilityModule.ASI_CRM_Actual_Payment__c > ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c)
        // {
        //     Msg += Label.ASI_CRM_CN_PO_End_Date_Validation + '<br/>';//End Date should be the last day of the month .
        //     UpsertPermission = false;
        //     return null;
        // }

        //Update Variable Amount of Payment request
        // if(PH.ASI_CRM_Total_Variable_Amount__c == null)
        // {
        //     PH.ASI_CRM_Total_Variable_Amount__c = 0;
        // }
        // for (interimData interimData : interimDataMap.values()) {
        //     for (interimData moduleWrapper : interimData.moduleWrappers) {
        //         PH.ASI_CRM_Total_Variable_Amount__c += moduleWrapper.module.ASI_CRM_Actual_Payment__c != null ? moduleWrapper.module.ASI_CRM_Actual_Payment__c : 0;
        //     }
        // }

        if (PH.ASI_CRM_CN_Promotion_Type__c != 'Consumer Promotion' && freeGoodsInterimData.paymentRequestLines != null) {
            System.debug(LoggingLevel.INFO, '*** freeGoodsInterimData: ' + freeGoodsInterimData);
            System.debug(LoggingLevel.INFO, '*** Total_this_time_payment: ' + Total_this_time_payment);
            System.debug(LoggingLevel.INFO, '*** visibilityModule: ' + visibilityModule);
            Decimal freegoodsAmount = 0;
            for (ASI_TH_CRM_PaymentRequestLineItem__c paymentRequest:freeGoodsInterimData.paymentRequestLines) {
                freegoodsAmount += paymentRequest.ASI_CRM_CN_Total_Payable__c != null?paymentRequest.ASI_CRM_CN_Total_Payable__c:0;
            }
            System.debug(LoggingLevel.INFO, '*** freegoodsAmount: ' + freegoodsAmount);
            if (freegoodsAmount > 0) {
                Decimal payFee = 0;
                payFee += Total_this_time_payment!=null?Total_this_time_payment:0;
                //payFee += visibilityModule.ASI_CRM_Actual_Payment__c != null ? visibilityModule.ASI_CRM_Actual_Payment__c : 0;
                System.debug(LoggingLevel.INFO, '*** payFee: ' + payFee);
                if (freegoodsAmount > payFee) {
                    // String tempStr = Label.ASI_CRM_CN_Goods_Deduction_Validation ;
                    // Decimal payFee_amount= payFee.setScale(2, RoundingMode.HALF_UP);
                    // List<String> fillers = new String[] {payFee.format(),freegoodsAmount.setScale(2, RoundingMode.HALF_UP).format()};
                    // Msg = String.format(tempStr,fillers)) + '<br/>';
                    Msg += Label.ASI_CRM_CN_Goods_Deduction_Validation + '<br/>';
                    UpsertPermission = false;
                    return null;
                }
            }
        }
        

        System.Savepoint pSavepoint = Database.setSavepoint();

        try {
            // delete old data
            // delete deletedModules;
            // delete deletedLines;

            // update PH;

            List<ASI_CRM_Module__c> modules = new List<ASI_CRM_Module__c>();
            Set<ASI_TH_CRM_PaymentRequestLineItem__c> lineItems = new Set<ASI_TH_CRM_PaymentRequestLineItem__c>();

            for (interimData interimData : interimDataMap.values()) {
                if (interimData.paymentRequestLineOutletWS != null) {
                    lineItems.add(interimData.paymentRequestLineOutletWS);
                }
                for (interimData moduleWrapper : interimData.moduleWrappers) {
                    modules.add(moduleWrapper.module);
                }
            }

            Set<Id> moduleSet = new Set<Id>();
            Set<Id> paymentLineItemSet = new Set<Id>();
            if (!interimDataMap.isEmpty()) {
                upsert modules;
                // Bowen 这里是为了获得已经upsert的module的id集合，进行后续的修改
                for(ASI_CRM_Module__c module : modules)
                {
                    moduleSet.add(module.Id);
                }

                List<ASI_CRM_Module__c> Ph_ModulesList = new List<ASI_CRM_Module__c>();
                Ph_ModulesList = [select Id ,ASI_CRM_Actual_Payment__c from ASI_CRM_Module__c where ASI_CRM_Payment_Request__c =: PH.Id and ASI_CRM_Line_Type__c =: 'PSF'];

                PH.ASI_CRM_Total_Variable_Amount__c = 0;
                if(Ph_ModulesList.size() > 0)
                {
                    
                    for(ASI_CRM_Module__c module : Ph_ModulesList)
                    {
                        PH.ASI_CRM_Total_Variable_Amount__c += module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c : 0;
                    }
                    
                }
                if (PH.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion') {
                    PH.ASI_CRM_Total_Variable_Amount__c += freeGoodsInterimData.module.ASI_CRM_Actual_Payment__c != null ? freeGoodsInterimData.module.ASI_CRM_Actual_Payment__c : 0;
                }
                PH.ASI_CRM_Total_Variable_Amount__c += visibilityModule.ASI_CRM_Actual_Payment__c != null ? visibilityModule.ASI_CRM_Actual_Payment__c : 0;
                // 2020-01-21 Bowen 增加一个字段的修改，更改为false，为了减少payment request的trigger执行，相对应减少了trigger里的sql查询
                PH.ASI_CRM_CN_IsRefresh__c = false;
                update PH;
            
                // Put module Id to paymentRequestLines
                // for (interimData interimData : interimDataMap.values()) {
                //     for (interimData moduleWrapper : interimData.moduleWrappers) {
                //         for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
                //             lineItem.ASI_CRM_Module__c = moduleWrapper.module.Id;
                //         }
                //         lineItems.addAll(moduleWrapper.paymentRequestLines);
                //     }
                // }

                String promotionType = PH.ASI_CRM_CN_Promotion_Type__c;

                // List<ASI_TH_CRM_PaymentRequestLineItem__c> newPaymentLineItem 
                // = new List<ASI_TH_CRM_PaymentRequestLineItem__c>(lineItems);
                // upsert newPaymentLineItem;
                // upsert new List<ASI_TH_CRM_PaymentRequestLineItem__c>(lineItems);
                 
                
                // Bowen 这里是为了获得已经upsert的payment line item的id集合，进行后续的修改
                // for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : newPaymentLineItem)
                // {
                //     paymentLineItemSet.add(paymentItem.Id);
                // }
            } else {
                update PH;
            }

            Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> exisFreegoodsMap = new Map<String,ASI_TH_CRM_PaymentRequestLineItem__c>([select Id ,ASI_CRM_Module__c from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c =: PH.Id
                    and recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods']);
            if (freeGoodsInterimData.paymentRequestLines != null) {
                for(ASI_TH_CRM_PaymentRequestLineItem__c item : freeGoodsInterimData.paymentRequestLines) {
                    if (item.Id != null) {
                        exisFreegoodsMap.remove(item.Id);
                    }
                }
            }
            
            if (!exisFreegoodsMap.isEmpty()) {
                delete exisFreegoodsMap.values();
            }

            if (freeGoodsInterimData.module != null) {
                //Update end Date in freeGoods module
                freeGoodsInterimData.module.ASI_CRM_End_Date__c = endDate;
                upsert freeGoodsInterimData.module;
            }
            if (freeGoodsInterimData.paymentRequestLines != null) {
                upsert freeGoodsInterimData.paymentRequestLines;
            }
            if (visibilityModule != null) {
                //Update end Date in visibility module
                visibilityModule.ASI_CRM_Actual_Payment__c = visibilityModule.ASI_CRM_Actual_Payment__c ==null?0:visibilityModule.ASI_CRM_Actual_Payment__c;
                visibilityModule.ASI_CRM_End_Date__c = endDate;
                upsert visibilityModule;
            }

        } catch (Exception e) {
            msg = 'Save Error : ' + e.getMessage() + '</br>Save Line :' + e.getLineNumber();
            System.debug(e.getStackTraceString());
            redirect = null;
            Database.rollback(pSavepoint);
            UpsertPermission = false;
            return null;
        }


        return redirect;
    }
    

    public PageReference CancelProcess() {
        // 2020-01-21 Bowen 增加一个字段的修改，更改为false，为了减少payment request的trigger执行，相对应减少了trigger里的sql查询
        PH.ASI_CRM_CN_IsRefresh__c = false;
        update PH;
        PageReference pageRef = new PageReference('/' + PageId);

        UpsertPermission = true;
        pageRef.setRedirect(true);
        return pageRef;
    }
    // vf 前端通过 action Function 调用此方法用于 启动或者禁用 action poller
    public PageReference startOrStopActionPoller(){
        if (batchType == 'delete') {
            IsEnabledDelete = !IsEnabledDelete;
        } else {
            IsEnabled = !IsEnabled;
        }
        return null;
    }
    //用于重新初始化导入进度的状态(适用于在此页面进行二次导入)
    public PageReference initProgressBarStatus(){

        // resultNum_total   = 0;
        // resultNum_success = 0;
        // resultNum_error   = 0;
        progressRate = 0;

        return null;
    }

    //如果开启了action poller 将会定时调用此方法，以显示进度。
    public PageReference processBarPercent(){
        if (String.isNotBlank(jobId)) {
            AsyncApexJob asynApexJob =  [SELECT Id, Status, NumberOfErrors, 
                                                JobItemsProcessed,TotalJobItems 
                                         FROM   AsyncApexJob 
                                         WHERE  Id =: jobId];
            System.debug(LoggingLevel.INFO, '*** asynApexJob.JobItemsProcessed: ' + asynApexJob.JobItemsProcessed);
            System.debug(LoggingLevel.INFO, '*** asynApexJob.TotalJobItems: ' + asynApexJob.TotalJobItems);
            if (asynApexJob.TotalJobItems != 0) {
                
                Double tempVar = (Double.valueOf(asynApexJob.JobItemsProcessed) / Double.valueOf(asynApexJob.TotalJobItems)) * 100;
                progressRate = Integer.valueOf(tempVar);
            }

            if (asynApexJob.Status == 'Completed') {
                BatchhandleResult = 'success';
                //jobId 置空
                jobId = '';
                IsEnabled = false;
            }
        }
        // 删除与新建BatchJob都成功, 才更新数据
        if (deleteBatchResult == 'success' && BatchhandleResult == 'success') {
            PH.ASI_CRM_CN_IsRefresh__c = true;
            PH.ASI_CRM_CN_Payment_Request_End_Date__c = endDate;
            System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize10): ' + Limits.getHeapSize());
            update PH;
            NextPage();
            System.debug(LoggingLevel.INFO, '*** Job Complete: ');            
        }
        return null;
    }
    public PageReference processBarPercentDelete(){

        if (String.isNotBlank(deletejobId)) {
            AsyncApexJob asynApexJob =  [SELECT Id, Status, NumberOfErrors, 
                                                JobItemsProcessed,TotalJobItems 
                                         FROM   AsyncApexJob 
                                         WHERE  Id =: deletejobId];
            if (asynApexJob.TotalJobItems != 0) {
                
                Double tempVar = (Double.valueOf(asynApexJob.JobItemsProcessed) / Double.valueOf(asynApexJob.TotalJobItems)) * 100;
                progressRate = Integer.valueOf(tempVar);
            }

            if (asynApexJob.Status == 'Completed') {
                deleteBatchResult = 'success';
                //jobId 置空
                deletejobId = '';
                IsEnabledDelete = false;
                if (String.isBlank(jobId)) {
                    // 删除Job处理完，再执行新建Batch数据
                    // refreshPricePromotionVolume();                    
                }

            }
        }
        return null;
    }

    public void refreshPricePromotionVolume() {
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize(): ' + Limits.getHeapSize());
        Datetime startTime = Datetime.now();

        Date startDate = PH.ASI_CRM_CN_PO_Start_Date__c;
        Date endDate = endDate;
        BatchhandleResult = '';
        deleteBatchResult = '';
        progressRate = 0;
        UpsertPermission = true;
        Msg = '';

        //        TODO validate date
        if (endDate > PH.ASI_CRM_CN_PO_End_Date__c) {
            UpsertPermission = false;
            Msg = 'End Date must be <= PO End Date!';
            return;
        }
        //checking end day
        if (!ASI_CRM_DateUtilClass.isEndOfMonth(endDate)) {// Label.ASI_CRM_CN_PO_End_Date_Validation+
            Msg += Label.ASI_CRM_CN_PO_End_Date_Validation + '<br/>';//End Date should be the last day of the month .
            UpsertPermission = false;
            return;
        }
        deletedModules = new List<ASI_CRM_Module__c>();
        deletedLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        Integer deleteLines = [SELECT count() FROM ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c =: PH.Id
                        and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                        OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Promotion')];
        // 删除行大于1000走Batch删除
        if (deleteLines > ASI_CRM_CN_PromotionPaymentCtrl.DELETEBATCH_ROW_QTY) {
            ASI_CRM_CN_PromotionDataDeleteBatch deleteBatch = new ASI_CRM_CN_PromotionDataDeleteBatch();
            deleteBatch.query = 'select Id ,ASI_CRM_Module__c from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c = \'' + PH.Id +'\'' +
                            ' and (recordType.DeveloperName =\'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS\'' +
                            ' OR recordType.DeveloperName =\'ASI_CRM_CN_Payment_Request_Detail_Promotion\')';
            deletejobId = Database.executeBatch(deleteBatch, 2000);
            return;
        } else {
            deleteBatchResult = 'success';
            deletejobId = '';
            deletedLines = [select Id ,ASI_CRM_Module__c from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c =: PH.Id
                            and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                            OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Promotion')];
            Set<Id> modulesSet = new Set<Id>();
            for(ASI_TH_CRM_PaymentRequestLineItem__c pay : deletedLines)
            {
                if(pay.ASI_CRM_Module__c != null && !modulesSet.equals(pay.ASI_CRM_Module__c))
                {
                    modulesSet.add(pay.ASI_CRM_Module__c);
                }
            }
            if(modulesSet.size() > 0) deletedModules = [select Id from ASI_CRM_Module__c where Id in: modulesSet and ASI_CRM_Line_Type__c =: 'PSF'];
            if(deletedLines.size() > 0) delete deletedLines;
            if(deletedModules.size() > 0) delete deletedModules;
        }
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize1(): ' + Limits.getHeapSize());
        // Remove all price promotion modules and lines
        // for (interimData interimData : interimDataMap.values()) {
        //     if (interimData.paymentRequestLineOutletWS != null && interimData.paymentRequestLineOutletWS.Id != null) {
        //         deletedLines.add(interimData.paymentRequestLineOutletWS);
        //     }
        //     for (interimData moduleWrapper : interimData.moduleWrappers) {
        //         if (moduleWrapper.module != null && moduleWrapper.module.Id != null) {
        //             deletedModules.add(moduleWrapper.module);
        //         }
        //         for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
        //             if (lineItem != null && lineItem.Id != null) {
        //                 deletedLines.add(lineItem);
        //             }
        //         }
        //     }
        // }

        // Empty interimDataMap
        // interimDataMap = new Map<String, interimData>();

        Set<Id> WSOutletIds = new Set<Id>();
        if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' && dataSource !='Outlet Intake'){
            WSOutletIds = wholesalerIds;
        }else{
            WSOutletIds = outletIds;
        }


        //List<ASI_CRM_Subbrand_Volume__c> subBrandVolumes = retrieveSubBrandVolume(startDate, endDate, ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion'? wholesalerIds : outletIds, outletIds, wholesalerIds, subBrandIds);
        List<ASI_CRM_Subbrand_Volume__c> subBrandVolumes = new List<ASI_CRM_Subbrand_Volume__c>();
        System.debug('*** WSOutletIds: ' + JSON.serializePretty(WSOutletIds) + '');
        System.debug(LoggingLevel.INFO, '*** WSOutletIds.size(): ' + WSOutletIds.size());
        system.debug('outletIds ==='+outletIds);
        system.debug('wholesalerIds ==='+wholesalerIds);
        system.debug('subBrandIds ==='+subBrandIds);
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize5(): ' + Limits.getHeapSize());
        Map<String, List<ASI_CRM_Subbrand_Volume__c>> subBrandVolumesByCustomers = new Map<String, List<ASI_CRM_Subbrand_Volume__c>>();
        Map<String, List<ASI_CRM_Volume_Aggregation_Breakdown__c>> subBrandVolumeBreakdownsByWSOutlet = new Map<String, List<ASI_CRM_Volume_Aggregation_Breakdown__c>>();
        if(test.isRunningTest()){isSouthRegion = true;}
        // For south region, each line is group by Supplier then Account
        if (isSouthRegion && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion') {
            //South region, get breakdown record and group by WS and outlet
            System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize5Test(): ' + Limits.getHeapSize());
            // List<ASI_CRM_Volume_Aggregation_Breakdown__c> subBrandVolumeBreakdowns = retrieveSubBrandVolumeBreakdown(startDate, endDate, WSOutletIds,subBrandIds);
            set<Id> WSIdSet = new set<Id>();
            for(List<ASI_CRM_Volume_Aggregation_Breakdown__c> breakdowns :[
                select  ASI_CRM_Depletion__c,
                        ASI_CRM_Depletion_GS__c,
                        ASI_CRM_Depletion_GS_T1_Price__c,
                        ASI_CRM_Depletion_STD__c,
                        ASI_CRM_Month__c,
                        ASI_CRM_Year__c,
                        ASI_CRM_Sub_brand_RO__c,
                        ASI_CRM_Volume_Out__c ,
                        ASI_CRM_Outlet_Sub_brand_Volume__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_T1_Depletion__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_T1_Depletion_GS__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_STD__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Intake_GS_T1_price__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Volume_Out_GS_Price__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Offtake_GS__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_POS_9L__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_POS_GS__c,
                        ASI_CRM_Sub_brand_Volume__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_T1_Depletion__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_T1_Depletion_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_STD__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_CN_Intake_GS_T1_price__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_CN_Volume_Out_GS_Price__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Offtake_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_POS_9L__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_POS_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_End_Date__c ,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Subbrand__c
                from ASI_CRM_Volume_Aggregation_Breakdown__c
                where ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c IN :WSOutletIds
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Subbrand__c in :subBrandIds
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_End_Date__c <= :endDate
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_End_Date__c >= :startDate
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Competitor_Sub_brand__c = FALSE
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                and ASI_CRM_Outlet_Sub_brand_Volume__r.RecordType.DeveloperName = 'ASI_CRM_CN_WS_Outlet_Sub_brand_Volume'

        ]){
                for (ASI_CRM_Volume_Aggregation_Breakdown__c breakdown: breakdowns) {
                    String strKey = breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c+';'+breakdown.ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c;
                    if(subBrandVolumeBreakdownsByWSOutlet.containsKey(strKey)){
                        subBrandVolumeBreakdownsByWSOutlet.get(strKey).add(breakdown);
                    }else{
                        List<ASI_CRM_Volume_Aggregation_Breakdown__c> tempList = new List<ASI_CRM_Volume_Aggregation_Breakdown__c>();
                        tempList.add(breakdown);
                        subBrandVolumeBreakdownsByWSOutlet.put(strKey,tempList);
                    }
                    WSIdSet.add(breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c);

                }

            }
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize5Origin(): ' + Limits.getHeapSize());
            System.debug(LoggingLevel.INFO, '*** WSIdSet.size(): ' + WSIdSet.size());
            System.debug('*** WSIdSet: ' + JSON.serializePretty(WSIdSet) + '');
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize5Remove(): ' + Limits.getHeapSize());
            if(WSIdSet.size()>0){
                WSSubbrandVolumeMap = new Map<Id, List<ASI_CRM_Subbrand_Volume__c>>();
                for(List<ASI_CRM_Subbrand_Volume__c> vols : [select Id,
                                                             ASI_CRM_Account__c,
                                                             ASI_CRM_T1_Depletion__c,
                                                             ASI_CRM_T1_Depletion_GS__c,
                                                             ASI_CRM_Actual_Vol_9L__c,
                                                             ASI_CRM_CN_Intake_GS_T1_price__c,
                                                             ASI_CRM_CN_Volume_Out_GS_Price__c,
                                                             ASI_CRM_Actual_Vol_STD__c
                                                      from ASI_CRM_Subbrand_Volume__c
                                                      where ASI_CRM_Account__c IN :WSIdSet
                                                      AND ASI_CRM_Subbrand__c IN :subBrandIds
                                                      AND ASI_CRM_End_Date__c <= :endDate
                                                      AND ASI_CRM_End_Date__c >= :startDate
                                                      AND ASI_CRM_CN_Competitor_Sub_brand__c = FALSE
                                                      AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                                                      AND RecordType.DeveloperName = 'ASI_CRM_CN_WS_Outlet_Sub_brand_Volume'
                                                      ]){
                    for (ASI_CRM_Subbrand_Volume__c vol : vols) {
                        if(WSSubbrandVolumeMap.containsKey(vol.ASI_CRM_Account__c)){
                            WSSubbrandVolumeMap.get(vol.ASI_CRM_Account__c).add(vol);
                        }else{
                            List<ASI_CRM_Subbrand_Volume__c> tempList = new List<ASI_CRM_Subbrand_Volume__c>();
                            tempList.add(vol);
                            WSSubbrandVolumeMap.put(vol.ASI_CRM_Account__c, tempList);
                        }
                    }
                }
            }

            //subBrandVolumesByCustomers = ASI_CRM_CN_UtilGroupBy.groupByStrings('ASI_CRM_CN_Supplier__c;ASI_CRM_Account__c', subBrandVolumes);
        } else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' && dataSource =='Outlet Intake'){
            subBrandVolumes = retrieveSubBrandVolume(startDate, endDate, WSOutletIds, outletIds, wholesalerIds, subBrandIds);

            for(ASI_CRM_Subbrand_Volume__c subbrandVol : subBrandVolumes){
                Set<String> WSIds = new Set<String>();
                for(ASI_CRM_Volume_Aggregation_Breakdown__c breakdown : subbrandVol.Sub_brand_Volume_Aggregation_Breakdown__r) {
                    WSIds.add(breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c);
                }
                for(String WSId : WSIds){
                    if(subBrandVolumesByCustomers.containsKey(WSId)){
                        subBrandVolumesByCustomers.get(WSId).add(subbrandVol);
                    }else{
                        List<ASI_CRM_Subbrand_Volume__c> tempList = new List<ASI_CRM_Subbrand_Volume__c>();
                        tempList.add(subbrandVol);
                        subBrandVolumesByCustomers.put(WSId, tempList);
                    }
                }
            }
        } else {
            subBrandVolumes = retrieveSubBrandVolume(startDate, endDate, WSOutletIds, outletIds, wholesalerIds, subBrandIds);
            subBrandVolumesByCustomers = ASI_CRM_CN_UtilGroupBy.groupByStrings('ASI_CRM_Account__c', subBrandVolumes);
        }
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize6(): ' + Limits.getHeapSize());

        // For getting volumes from suppliers
        Set<Id> supplierIds = new Set<Id>();
         /* ---------------  2019-08-15 Bowen UAT期间，修改的分页逻辑，但发现与真实业务需求有出入，暂时先注释，需对代码进行重构------------------- */
        sumNum = subBrandVolumeBreakdownsByWSOutlet.size();//获取Price Promotion 数据的总数
        System.debug(LoggingLevel.INFO, '*** subBrandVolumeBreakdownsByWSOutlet.size: ' + subBrandVolumeBreakdownsByWSOutlet.size());
        totalNumPage = 1;
        sumNumPage = Math.ceil(sumNum / skipNum); // Price Promotion 总页数
        Id PRDORecordTypeId = ASI_TH_CRM_PaymentRequestLineItem__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Payment_Request_Detail_Outlet_WS').getRecordTypeId();
        if(sumNumPage > 1) isNext = true; // Price Promotion 当页面数大于1时，默认勾选

        // Empty interimDataMap
         Map<String, interimData> interimDataMapAll = new Map<String, interimData>();

         System.debug(LoggingLevel.INFO, '*** subBrandVolumesByCustomers: ' + subBrandVolumesByCustomers);

        //if PO type = Outlet Promotion and region = South Region, use break down record to generate the interimDataMap
        // subBrandVolumeBreakdownsByWSOutlet and interimDataMap share the same key
        if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion){
           
            Decimal num = 0;

            
            for (String key : subBrandVolumeBreakdownsByWSOutlet.keySet()) {
                
                ASI_CRM_Volume_Aggregation_Breakdown__c breakdown = subBrandVolumeBreakdownsByWSOutlet.get(key)[0];
                interimData interimData = new interimData();
                interimData.paymentRequestLineOutletWS = createPaymentRequestLineItem(PageId, null, null, PRDORecordTypeId);
                interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c = breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c;
                interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__r = breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r;
                interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c = breakdown.ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c;
                interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__r = breakdown.ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r;
                interimData.paymentRequestLineOutletWS = calculateSubBrandVolumesByBreakdowns(subBrandVolumeBreakdownsByWSOutlet.get(key), interimData.paymentRequestLineOutletWS, PH.ASI_CRM_CN_Promotion_Type__c, dataSource, 'By Total', null, false);
                // if(num <= skipNum)
                // {
                //     interimDataMap.put(key, interimData);
                // }
                
                interimDataMapAll.put(key, interimData);
                num ++;
            }
        }else {

            // Create WS/Outlet payment request line, and assign Wholesaler/Customer base on promotion type and region
            // subBrandVolumesByCustomers and interimDataMap share the same key
            Decimal num = 0;
            for (String key : subBrandVolumesByCustomers.keySet()) {
                

                ASI_CRM_Subbrand_Volume__c volume = subBrandVolumesByCustomers.get(key)[0];
                interimData interimData = new interimData();
                interimData.paymentRequestLineOutletWS = createPaymentRequestLineItem(PageId, null, null, PRDORecordTypeId);
                if (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion') {
                    if (dataSource == 'Outlet Intake') {
                        interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c = Id.valueOf(key);
                    } else {
                        interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c = volume.ASI_CRM_Account__c;
                        interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__r = volume.ASI_CRM_Account__r;
                        supplierIds.add(volume.ASI_CRM_Account__c);
                    }
                } else {
                    interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c = volume.ASI_CRM_Account__c;
                    interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__r = volume.ASI_CRM_Account__r;
//                    if (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion) {
//                        supplierIds.add(volume.ASI_CRM_CN_Supplier__c);
//                        interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c = volume.ASI_CRM_CN_Supplier__c;
//                        interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__r = volume.ASI_CRM_CN_Supplier__r;
//                    }
                }

                interimData.paymentRequestLineOutletWS = calculateSubBrandVolumes(subBrandVolumesByCustomers.get(key), interimData.paymentRequestLineOutletWS, PH.ASI_CRM_CN_Promotion_Type__c, dataSource, 'By Total', null);


                // if(num <= skipNum)
                // {
                //     interimDataMap.put(key, interimData);
                // }
                
                interimDataMapAll.put(key, interimData);
                num ++;
            }
        }

        // List<ASI_CRM_Subbrand_Volume__c> subBrandVolumesFromSuppliers = retrieveSubBrandVolume(startDate, endDate, ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion'? outletIds : supplierIds, outletIds, wholesalerIds, subBrandIds);
        // Map<Id, List<ASI_CRM_Subbrand_Volume__c>> subBrandVolumesBySuppliers = ASI_CRM_CN_UtilGroupBy.groupByIds(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion'? 'ASI_CRM_CN_Supplier__c' : 'ASI_CRM_Account__c', subBrandVolumesFromSuppliers);

        // for (String key : interimDataMap.keySet()) {
        //     interimData interimData = interimDataMap.get(key);
        // for (String key : interimDataMapAll.keySet()) {
            // interimData interimData = interimDataMapAll.get(key);
//            if (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' || isSouthRegion) {
//                interimData.paymentRequestLineOutletWS = calculateSubBrandVolumes(subBrandVolumesBySuppliers.get(interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c), interimData.paymentRequestLineOutletWS, 'Wholesaler Promotion', null, 'By Total', null);
//            }
            // interimData.paymentRequestLineOutletWS = calculateDataSource(interimData.paymentRequestLineOutletWS, dataSource);
        // }
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize7-middle): ' + Limits.getHeapSize());

        List<ASI_CRM_Module__c> contractModules = [
                SELECT Id, ASI_CRM_Methodology__c, ASI_CRM_Methodology__r.Name, ASI_CRM_Volume_Base__c, ASI_CRM_Line_Type__c, ASI_CRM_CN_Only_for_Strategy_WS__c,(
                        SELECT
                                ASI_CRM_CN_Activity_Code__c,
                                ASI_CRM_CN_Contract__c,
                                //ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,
                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                                ASI_CRM_CN_Contract_Monthly_Qty__c,
                                //ASI_CRM_CN_Contract_Purchase_Value__c,
                                //ASI_CRM_CN_Estimate_Purchase_Value__c,
                                //ASI_CRM_CN_Contract_Total__c,
                                //ASI_CRM_CN_Contract_Total_Dummy__c,
                                ASI_CRM_CN_Date__c,
                                //ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                                //ASI_CRM_CN_Est_Monthly_Qty__c,
                                //ASI_CRM_CN_Est_Total__c,
                                //ASI_CRM_CN_Est_Total_Dummy__c,
                                ASI_CRM_CN_Max_Purchase_Target__c,
                                ASI_CRM_CN_Min_Purchase_Target__c,
                                //ASI_CRM_CN_Rebate__c,
                                ASI_CRM_CN_Rebate_Percent__c,
                                ASI_CRM_CN_Sub_Brand__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                                ASI_CRM_CN_Sub_Brand__r.Name,
                                //ASI_CRM_CN_Target__c,
                                ASI_CRM_CN_Volume_Value_Base__c,
                                //ASI_CRM_Contract_Monthly_Volume_CR12__c,
                                //ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c,
                                //ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c,
                                //ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                                //ASI_CRM_Contract_Total_QTY_std_Btl__c,
                                //ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c,
                                //ASI_CRM_Est_Monthly_Volume_CR12__c,
                                //ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c,
                                //ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                                //ASI_CRM_Est_Total_QTY_std_Btl__c,
                                //ASI_CRM_Line_Name__c,
                                ASI_CRM_Line_Long_Name__c,
                                ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,
                                Id
                        FROM Contract_BRSF_Line_Item__r
                )
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c AND ASI_CRM_Line_Type__c = :PRICE_PROMOTION_MODULE_TYPE AND ASI_CRM_Payment_Request__c = NULL
        ];
        Integer iModuleLine = [SELECT count()  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_Module__r.ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c 
                                                            AND ASI_CRM_Module__r.ASI_CRM_Line_Type__c = :PRICE_PROMOTION_MODULE_TYPE 
                                                            AND ASI_CRM_Module__r.ASI_CRM_Payment_Request__c = NULL];
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize7): ' + Limits.getHeapSize());
        System.debug(LoggingLevel.INFO, '*** interimDataMapAll.keySet(): ' + interimDataMapAll.keySet().size());
        Integer iOutlet = interimDataMapAll.keySet().size() ;
        Integer iLines = iOutlet * (iModuleLine + 1);
        // 店家数量超20个，用batch方式进行数据处理
        Boolean isBatch = false;
        if ( iLines > ASI_CRM_CN_PromotionPaymentCtrl.BATCH_OUTLET_QTY) {
            for (String key : interimDataMapAll.keySet()) {
                interimData interimData = interimDataMapAll.get(key);
                interimData.subBrandVolumes = subBrandVolumesByCustomers.get(key);
                interimData.subBrandVolumeBreakdowns = subBrandVolumeBreakdownsByWSOutlet.get(interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c+';'+interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c);
            }
            System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize8): ' + Limits.getHeapSize());
            isBatch = true;
            jobId = Database.executeBatch(new ASI_CRM_CN_PromotionDataHandleBatch(interimDataMapAll.values(), PH , ContractSelected, endDate), 10);
            return ;
        } else {
            BatchhandleResult = 'success';
            jobId = '';
        }


        List<ASI_CRM_Module__c> modules = new List<ASI_CRM_Module__c>();
        Set<ASI_TH_CRM_PaymentRequestLineItem__c> lineItems = new Set<ASI_TH_CRM_PaymentRequestLineItem__c>();


        // For each WS/Outlet, create Modules and lines
        for (String key : interimDataMapAll.keySet()) {
            interimData interimData = interimDataMapAll.get(key);
            subBrandVolumes = subBrandVolumesByCustomers.get(key);
            System.debug(LoggingLevel.INFO, '*** subBrandVolumes222: ' + subBrandVolumes);
            interimData.paymentRequestLineOutletWS = calculateDataSource(interimData.paymentRequestLineOutletWS, dataSource);
             System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize7): ' + key + ' : ' + Limits.getHeapSize());

            for (ASI_CRM_Module__c module : contractModules) {
                // Skip this module if it has no BRSF line
                if (module.Contract_BRSF_Line_Item__r.isEmpty()) {
                    continue;
                }

                interimData moduleWrapper = new interimData();
                moduleWrapper.module = createModule(module);

                moduleWrapper.paymentRequestLines = createPaymentRequestLineFromContractLines(module.Contract_BRSF_Line_Item__r);
                // Set Wholesaler/Outlet
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
                    lineItem.ASI_CRM_CN_Wholesaler__c = interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c;
                    lineItem.ASI_CRM_Customer__c = interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c;
                }
                moduleWrapper.paymentRequestLines = calculateSubBrandVolumes(subBrandVolumes, moduleWrapper.paymentRequestLines, PH.ASI_CRM_CN_Promotion_Type__c, dataSource, module.ASI_CRM_Volume_Base__c, module.ASI_CRM_Methodology__r.Name);
                // Calculate Outlet Intake from another set of sub-brand volumes
//                if (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion') {
//                    moduleWrapper.paymentRequestLines = calculateSubBrandVolumes(subBrandVolumesBySuppliers.get(interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c), moduleWrapper.paymentRequestLines, PH.ASI_CRM_CN_Promotion_Type__c, dataSource, module.ASI_CRM_Volume_Base__c, module.ASI_CRM_Methodology__r.Name);
//                }

                if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion){
                    moduleWrapper.paymentRequestLines = calculateSubBrandVolumesByBreakdowns(
                        subBrandVolumeBreakdownsByWSOutlet.get(interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c+';'+interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c),
                                                             moduleWrapper.paymentRequestLines, 
                                                             PH.ASI_CRM_CN_Promotion_Type__c, 
                                                             dataSource, 
                                                             module.ASI_CRM_Volume_Base__c, 
                                                             module.ASI_CRM_Methodology__r.Name, 
                                                             true);
                }

                moduleWrapper.paymentRequestLines = calculateDataSource(moduleWrapper.paymentRequestLines, dataSource);
        
                switch on module.ASI_CRM_Methodology__r.Name {
                    when 'Per Incentive Btl' {
                        // system.debug('----calculatePerIncentiveBottle(Per Incentive Btl) '+module.ASI_CRM_Methodology__r.Name);
                        moduleWrapper.paymentRequestLines = calculatePerIncentiveBottle(moduleWrapper.paymentRequestLines);
                    }
                    when 'Rebate%(By Package)' {
                        // system.debug('----calculateRebatePercentByPackage(Rebate%(By Package)) '+module.ASI_CRM_Methodology__r.Name);
                        moduleWrapper.paymentRequestLines = calculateRebatePercentByPackage(moduleWrapper.paymentRequestLines, module.ASI_CRM_Volume_Base__c);
                    }
                    when 'Rebate%(By Ladder)' {
                        // system.debug('----calculateRebatePercentByLadder(Rebate%(By Ladder)) '+module.ASI_CRM_Methodology__r.Name);
                        moduleWrapper.paymentRequestLines = calculateRebatePercentByLadder(moduleWrapper.paymentRequestLines);
                    }
                    when else {
                        // system.debug('----calculateRebatePercent(else) '+module.ASI_CRM_Methodology__r.Name);
                        moduleWrapper.paymentRequestLines = calculateRebatePercent(moduleWrapper.paymentRequestLines);
                    }
                }

                Decimal totalPaymentAmount = 0;
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
                    if(module.ASI_CRM_CN_Only_for_Strategy_WS__c && !onlyForStrategyIdSet.contains(lineItem.ASI_CRM_CN_Wholesaler__c)){
                        lineItem.ASI_CRM_CN_Total_Payable__c = 0;
                    }
                    totalPaymentAmount += lineItem.ASI_CRM_CN_Total_Payable__c;
                }
                moduleWrapper.module.ASI_CRM_CN_Customer__c = interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c != null? interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c : interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c;
                moduleWrapper.module.ASI_CRM_Application_Payment_Amount__c = totalPaymentAmount;
                // TODO calculate historical paid amount
                moduleWrapper.module.ASI_CRM_Historical_Paid_Amount__c = 0;
                moduleWrapper.module.ASI_CRM_Actual_Payment__c = totalPaymentAmount;
                moduleWrapper.module.ASI_CRM_Parent_Module__c = module.Id;

                if(HistoricalAmountMap.size()>0){
                    String WholesalerId = interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c != null ? String.valueOf(interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c) : '';
                    String OutletId = interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c != null ? String.valueOf(interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c) : '';
                    String TemKey =  String.valueOf(moduleWrapper.module.ASI_CRM_Parent_Module__c)+';'+WholesalerId+';'+OutletId;
                    if(HistoricalAmountMap.containsKey(TemKey)){
                        moduleWrapper.module.ASI_CRM_Historical_Paid_Amount__c = HistoricalAmountMap.get(TemKey);
                        moduleWrapper.module.ASI_CRM_Actual_Payment__c = totalPaymentAmount - moduleWrapper.module.ASI_CRM_Historical_Paid_Amount__c;
                    }
                }
                moduleWrapper.module.ASI_CRM_End_Date__c = endDate;
                modules.add(moduleWrapper.module);
                interimData.moduleWrappers.add(moduleWrapper);
            }

            interimData.module.ASI_CRM_End_Date__c = endDate;
            if (interimData.paymentRequestLineOutletWS != null) {
                lineItems.add(interimData.paymentRequestLineOutletWS);
            }

            if(interimDataMap.containsKey(key))
            {
                if(interimDataMap.get(key) != null)
                {
                    interimDataMap.remove(key);
                    interimDataMap.put(key, interimData);
                } 
            }

        }
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize8): ' + Limits.getHeapSize());

        // List<ASI_CRM_Module__c> modules = new List<ASI_CRM_Module__c>();
        // Set<ASI_TH_CRM_PaymentRequestLineItem__c> lineItems = new Set<ASI_TH_CRM_PaymentRequestLineItem__c>();

        // for (interimData interimData : interimDataMapAll.values()) {
        //     interimData.module.ASI_CRM_End_Date__c = endDate;

        //     if (interimData.paymentRequestLineOutletWS != null) {
        //         lineItems.add(interimData.paymentRequestLineOutletWS);
        //     }
        //     for (interimData moduleWrapper : interimData.moduleWrappers) {
        //         moduleWrapper.module.ASI_CRM_End_Date__c = endDate;
        //         modules.add(moduleWrapper.module);
        //     }
        // }

        // Set<Id> moduleSet = new Set<Id>();
        // Set<Id> paymentLineItemSet = new Set<Id>();
        System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize9): ' + Limits.getHeapSize());
        if (!interimDataMapAll.isEmpty()) {
            // 2020-01-21 Bowen 增加一个字段的修改，更改为true，为了减少payment request的trigger执行，相对应减少了trigger里的sql查询
            PH.ASI_CRM_CN_IsRefresh__c = true;
            PH.ASI_CRM_CN_Payment_Request_End_Date__c = endDate;
            System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize10): ' + Limits.getHeapSize());
            update PH;
            System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize11): ' + Limits.getHeapSize());
            if (!isBatch) {
                upsert modules;
                System.debug(LoggingLevel.INFO, '*** Limits.getHeapSize12): ' + Limits.getHeapSize());

                // Bowen 这里是为了获得已经upsert的module的id集合，进行后续的修改
                // for(ASI_CRM_Module__c module : modules)
                // {
                //     moduleSet.add(module.Id);
                // }

                // Put module Id to paymentRequestLines
                for (interimData interimData : interimDataMapAll.values()) {
                    for (interimData moduleWrapper : interimData.moduleWrappers) {
                        for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
                            lineItem.ASI_CRM_Module__c = moduleWrapper.module.Id;
                        }
                        lineItems.addAll(moduleWrapper.paymentRequestLines);
                    }
                }

                // upsert new List<ASI_TH_CRM_PaymentRequestLineItem__c>(lineItems);
                List<ASI_TH_CRM_PaymentRequestLineItem__c> newPaymentLineItem 
                    = new List<ASI_TH_CRM_PaymentRequestLineItem__c>(lineItems);
                System.debug(LoggingLevel.INFO, '*** newPaymentLineItem.size(): ' + newPaymentLineItem.size());
                upsert newPaymentLineItem;
            }
            // upsert new List<ASI_TH_CRM_PaymentRequestLineItem__c>(lineItems);
            
            // Bowen 这里是为了获得已经upsert的payment line item的id集合，进行后续的修改
            // for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : newPaymentLineItem)
            // {
            //     paymentLineItemSet.add(paymentItem.Id);
            // }
            // sumNum = lineItems.size(); // 获取总数据长度
            // sumNumPage = Math.ceil(sumNum / skipNum); // Price Promotion 总页数
        }
        Datetime stopTime = Datetime.now();
        system.debug('共消耗的时间是==='+(stopTime.getTime() - startTime.getTime()));
        // 先将payment request line item的扣减计算逻辑执行，再执行module的计算逻辑
        // ModuleAndPaymentRequestExclude(moduleSet , paymentLineItemSet);

        // system.debug('paymentLineItemSet.size =='+paymentLineItemSet.size());

            
        PageSkipType = '';
        totalNumPage = 1; // Price Promotion页面初始化，默认为首页
        isNext = false; // Price Promotion 默认下一页为false，需要根据数据长度来判断是否显示
        isFirst = false;// Price Promotion 默认上一页为false，即页面不显示
        if(!Test.isRunningTest() && !isBatch) {NextPage();}

        // interimDataMapJSON = JSON.serialize(interimDataMap);
        // System.debug('interimDataMapJSON ' + interimDataMapJSON);
    }

    // /*
    //     Authro:Bowen
    //     Date:2019-10-28
    //     Function:先将payment request line item的扣减计算逻辑执行，再执行module的计算逻辑
    //  */
    // public void ModuleAndPaymentRequestExclude(Set<Id> moduleSet ,Set<Id> paymentLineItemSet)
    // {

    //     Transient List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
    //     if(paymentLineItemSet.size() > 0)
    //     {
    //         PaymentRequestLineItemList = [select Id ,
    //                                             ASI_CRM_CN_Sub_Brand__c  ,
    //                                             ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Pack_Size__c ,
    //                                             ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Drop_In__c ,
    //                                             ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ,
    //                                             ASI_CRM_CN_Contract_BRSF_Line_Item__c ,
    //                                             ASI_CRM_CN_WS_Intake_9L_Original__c ,
    //                                             ASI_CRM_CN_WS_Intake_9L__c ,
    //                                             ASI_CRM_CN_WS_Intake_9L_Exclude__c ,
    //                                             ASI_CRM_CN_Outlet_Intake_9L_Exclude__c ,
    //                                             ASI_CRM_CN_Outlet_Intake_9L_Original__c ,
    //                                             ASI_CRM_CN_Outlet_Intake_9L__c ,
    //                                             ASI_CRM_CTD_Actual_Purchase_Value__c ,
    //                                             ASI_CRM_Actual_Purchase_Value_Original__c ,
    //                                             ASI_CRM_Actual_Purchase_Value_Exclude__c ,
    //                                             ASI_CRM_CN_POS_Volume__c ,
    //                                             ASI_CRM_CN_POS_Volume_9L_Original__c ,
    //                                             ASI_CRM_CN_POS_Volume_9L_Exclude__c ,
    //                                             ASI_CRM_CN_POS_Value__c ,
    //                                             ASI_CRM_Line_Long_Name__c ,
    //                                             ASI_CRM_CN_POS_Value_Original__c ,
    //                                             ASI_CRM_CN_POS_Value_Exclude__c ,
    //                                             ASI_CRM_CTD_Actual_Retail_Value_Original__c ,
    //                                             ASI_CRM_CTD_Actual_Retail_Value_Exclude__c ,
    //                                             ASI_CRM_Actual_Value_Base__c ,
    //                                             ASI_CRM_CN_Wholesaler__c ,
    //                                             ASI_CRM_Customer__c ,
    //                                             ASI_CRM_CTD_Actual_Retail_Value__c ,
    //                                             ASI_CRM_CN_CRM_Code__c ,
    //                                             ASI_CRM_CN_Actual_Value_Base_Original__c ,
    //                                             ASI_CRM_Module__c ,
    //                                             ASI_CRM_Module__r.ASI_CRM_Volume_Base__c ,
    //                                             ASI_CRM_CN_Sub_brand_Group__c ,
    //                                             ASI_CRM_Sub_Brand_Grade__c ,
    //                                             ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_CN_Only_for_Strategy_WS__c ,
    //                                             ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Methodology__r.Name ,
    //                                             ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c
    //                                         from ASI_TH_CRM_PaymentRequestLineItem__c 
    //                                         where Id in: paymentLineItemSet
    //                                         and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
    //                                         OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods'
    //                                         OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Promotion')];
    //     }

    //     if(PaymentRequestLineItemList.size() > 0)
    //     {
    //         system.debug('PaymentRequestLineItemList =='+PaymentRequestLineItemList.size());
    //         // 执行计算payment request line item的数据
    //         PaymentRequestLineItemList = TotalPaymentRequestLineItem(PaymentRequestLineItemList);
    //         update PaymentRequestLineItemList;
    //     }

    //     Transient List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();
    //     if(moduleSet.size() > 0 || Test.isRunningTest())
    //     {
    //         moduleList = [select Id ,
    //                             ASI_CRM_Volume_Base__c ,
    //                             ASI_CRM_Methodology__r.Name ,
    //                             ASI_CRM_Parent_Module__r.ASI_CRM_CN_Only_for_Strategy_WS__c ,
    //                             ASI_CRM_Historical_Paid_Amount__c ,
    //                             (
    //                                 SELECT
    //                                     ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c ,
    //                                     ASI_CRM_CTD_Actual_Vol__c ,
    //                                     ASI_CRM_CN_Actual_Package_Number__c,
    //                                     ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c ,
    //                                     ASI_CRM_Actual_Value_Base__c ,
    //                                     ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c ,
    //                                     ASI_CRM_CN_Total_Payable__c ,
    //                                     ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c ,
    //                                     ASI_CRM_Line_Long_Name__c ,
    //                                     ASI_CRM_CN_Sub_Brand__c ,
    //                                     ASI_CRM_CN_Wholesaler__c
    //                                 FROM Payment_Request_Line_Items__r
    //                                 WHERE ASI_TH_CRM_Payment_Request__c = :PH.Id
    //                             )
    //                         from ASI_CRM_Module__c 
    //                         where Id in: moduleSet];

    //         List<ASI_TH_CRM_PaymentRequestLineItem__c> modulePaymentList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
    //         system.debug('onlyForStrategyIdSet ==='+onlyForStrategyIdSet);
    //         for(ASI_CRM_Module__c module : moduleList)
    //         {
    //             if(module.Payment_Request_Line_Items__r.size() > 0)
    //             {
    //                 // 重新计算module的ASI_CRM_Application_Payment_Amount__c，汇总payment line item的ASI_CRM_CN_Total_Payable__c
    //                 switch on module.ASI_CRM_Methodology__r.Name {
    //                     when 'Per Incentive Btl' {
    //                         calculatePerIncentiveBottle(module.Payment_Request_Line_Items__r);
    //                     }
    //                     when 'Rebate%(By Package)' {
    //                         calculateRebatePercentByPackage(module.Payment_Request_Line_Items__r, module.ASI_CRM_Volume_Base__c);
    //                     }
    //                     when 'Rebate%(By Ladder)' {
    //                         calculateRebatePercentByLadder(module.Payment_Request_Line_Items__r);
    //                     }
    //                     when else {
    //                         calculateRebatePercent(module.Payment_Request_Line_Items__r);
    //                     }
    //                 }


    //                 Decimal totalPaymentAmount = 0;
    //                 for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : module.Payment_Request_Line_Items__r) {
    //                     if(module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_Only_for_Strategy_WS__c && !onlyForStrategyIdSet.contains(lineItem.ASI_CRM_CN_Wholesaler__c)){
    //                         system.debug('----StrategyWS ==='+ lineItem.ASI_CRM_CN_Wholesaler__c);
    //                         lineItem.ASI_CRM_CN_Total_Payable__c = 0;
    //                         lineItem.ASI_CRM_CN_WS_Intake_9L__c = 0;
    //                         lineItem.ASI_CRM_CN_Outlet_Intake_9L__c = 0;
    //                         lineItem.ASI_CRM_Actual_Value_Base__c = 0;
    //                         lineItem.ASI_CRM_CTD_Actual_Purchase_Value__c = 0;
    //                         lineItem.ASI_CRM_CN_POS_Value__c = 0;
    //                         lineItem.ASI_CRM_CN_POS_Volume__c = 0;
    //                         lineItem.ASI_CRM_CTD_Actual_Retail_Value__c = 0;
    //                         lineItem.ASI_CRM_CTD_Actual_Vol__c = 0;

    //                     }
    //                     totalPaymentAmount += lineItem.ASI_CRM_CN_Total_Payable__c;

    //                     modulePaymentList.add(lineItem);
    //                 }
    //                 module.ASI_CRM_Application_Payment_Amount__c = totalPaymentAmount;
    //                 // TODO calculate historical paid amount
    //                 module.ASI_CRM_Actual_Payment__c = totalPaymentAmount - denullify(module.ASI_CRM_Historical_Paid_Amount__c);
    //                 // module.ASI_CRM_Actual_Payment__c = totalPaymentAmount ;
    //             }
    //         }
    //         update moduleList;
    //         if(modulePaymentList.size() > 0) upsert modulePaymentList;
    //     }
        
    // }

    // /*
    //     Author:Bowen
    //     Date:2019-10-24
    //     Function: 计算payment request line item的扣减金额
    //  */
    // public List<ASI_TH_CRM_PaymentRequestLineItem__c> TotalPaymentRequestLineItem(List<ASI_TH_CRM_PaymentRequestLineItem__c> lineItems )
    // {
    //     Set<String> packSizeSet = new Set<String>();
    //     Set<Id> subbrandSet = new Set<Id>();

    //     Map<Id ,String> subBrandPackSizeMap = new Map<Id ,String>();
    //     Map<Id ,Boolean> subBrandDropInMap = new Map<Id ,Boolean>();

    //     Map<String ,Set<Id>> subBrandGroupMap = new Map<String ,Set<Id>>();

    //     List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSF_List = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
    //     BRSF_List = [select Id ,
    //                         ASI_CRM_CN_Sub_Brand__c ,
    //                         ASI_CRM_CN_Pack_Size__c ,
    //                         ASI_CRM_CN_Drop_In__c ,
    //                         ASI_CRM_Type__c ,
    //                         ASI_CRM_CN_Sub_Brand_Package__c ,
    //                         ASI_CRM_CN_Contract__c 
    //                     from ASI_CRM_CN_Contract_BRSF_Line_Item__c
    //                     where ASI_CRM_CN_Contract__c =: ContractSelected.Id
    //                     and (ASI_CRM_CN_Pack_Size__c != null
    //                         or ASI_CRM_CN_Drop_In__c = true)
    //                     and ASI_CRM_Type__c =: 'BRSF'];
    //     if(BRSF_List.size() > 0)
    //     {
    //         for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf : BRSF_List)
    //         {
    //             if(brsf.ASI_CRM_CN_Sub_Brand__c == null) continue;
    //             Boolean flag = false;
    //             // 存储brsf中的每一个数据的packsize值
    //             if(brsf.ASI_CRM_CN_Pack_Size__c != null)
    //             {
    //                 flag = true;
    //                 if(!subBrandPackSizeMap.containsKey(brsf.ASI_CRM_CN_Sub_Brand__c))
    //                 {
    //                     subBrandPackSizeMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, brsf.ASI_CRM_CN_Pack_Size__c);
    //                 }
    //                 else
    //                 {
    //                     String packSize = subBrandPackSizeMap.get(brsf.ASI_CRM_CN_Sub_Brand__c);
    //                     subBrandPackSizeMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, packSize + brsf.ASI_CRM_CN_Pack_Size__c);
    //                 }
    //                 // 将BRSF上的pack size上分解，用for循环，将包含的pack size归到set上。
    //                 List<String> splitList = brsf.ASI_CRM_CN_Pack_Size__c.split(';');
    //                 if(splitList.size() > 0)
    //                 {
    //                     for(String str : splitList)
    //                     {
    //                         // 取packsize的值
    //                         if(!packSizeSet.contains(str))
    //                         {
    //                             packSizeSet.add(str);
    //                         }
    //                     }
    //                     // 将subbrand加入到set集合中
    //                     if(!subbrandSet.contains(brsf.ASI_CRM_CN_Sub_Brand__c))
    //                     {
    //                         subbrandSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
    //                     }
    //                 }
    //             }
    //             // 存储brsf中的每一个数据的dropIn值
    //             if(brsf.ASI_CRM_CN_Drop_In__c)
    //             {
    //                 if(!flag) flag = true;
    //                 subBrandDropInMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, brsf.ASI_CRM_CN_Drop_In__c);

    //                 // 将subbrand加入到set集合中
    //                 if(!subbrandSet.contains(brsf.ASI_CRM_CN_Sub_Brand__c))
    //                 {
    //                     subbrandSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
    //                 }
    //             }

    //             // 属于exclude的内容，且brsf中的属于同一group的subbrandId
    //             if(flag && brsf.ASI_CRM_CN_Sub_Brand_Package__c != null && brsf.ASI_CRM_CN_Sub_Brand_Package__c != '')
    //             {
    //                 if(subBrandGroupMap.containsKey(brsf.ASI_CRM_CN_Sub_Brand_Package__c))
    //                 {
    //                     Set<Id> subBrandGroupSet = subBrandGroupMap.get(brsf.ASI_CRM_CN_Sub_Brand_Package__c);
    //                     if(!subBrandGroupSet.contains(brsf.ASI_CRM_CN_Sub_Brand__c))
    //                     {
    //                         subBrandGroupSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
    //                     }
    //                     subBrandGroupMap.put(brsf.ASI_CRM_CN_Sub_Brand_Package__c ,subBrandGroupSet);
    //                 }
    //                 else
    //                 {
    //                     Set<Id> subBrandGroupSet = new Set<Id>();
    //                     subBrandGroupSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
    //                     subBrandGroupMap.put(brsf.ASI_CRM_CN_Sub_Brand_Package__c ,subBrandGroupSet);
    //                 }
    //             }
    //         }
    //     }

    //     Set<Id> WSOutletIds = new Set<Id>();
    //     if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' && dataSource !='Outlet Intake'){
    //         WSOutletIds = wholesalerIds;
    //     }else{
    //         WSOutletIds = outletIds;
    //     }

    //     Set<Id> excludeOutletSet = new Set<Id>();
    //     Set<Id> exculdeWSSet = new Set<Id>();

    //     for(ASI_TH_CRM_PaymentRequestLineItem__c paymentlineItem : lineItems)
    //     {
    //         if(paymentLineItem.ASI_CRM_Customer__c != null && !excludeOutletSet.contains(paymentLineItem.ASI_CRM_Customer__c)) excludeOutletSet.add(paymentLineItem.ASI_CRM_Customer__c);

    //         if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && !exculdeWSSet.contains(paymentLineItem.ASI_CRM_CN_Wholesaler__c)) exculdeWSSet.add(paymentLineItem.ASI_CRM_CN_Wholesaler__c);
    //     }
    //     // 开始日期是payment中的start date
    //     Date startDate = PH.ASI_CRM_CN_PO_Start_Date__c;
    //     system.debug('----subbrandSet==='+subbrandSet.size());
    //     system.debug('----WSOutletIds==='+WSOutletIds.size());

    //     if(subbrandSet.size() > 0)
    //     {
    //         // 查询条件：相同的subbrand，PO下的outlet/wholeasler，时间在payment 开始时间到enddate之间
    //         List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemGroupVolumeList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
    //         if(Test.isRunningTest())
    //         {
    //             excludeItemGroupVolumeList = [select Id ,ASI_CRM_CN_Pack_Size__c ,
    //                                                                                     ASI_CRM_CN_Intake_GS_T1_price__c ,
    //                                                                                     ASI_CRM_POS_9L__c ,
    //                                                                                     ASI_CRM_POS_GS__c ,
    //                                                                                     ASI_CRM_Actual_Vol_9L__c ,
    //                                                                                     ASI_CRM_PR_Direct__c ,
    //                                                                                     ASI_CRM_T2_Depletion__c ,
    //                                                                                     ASI_CRM_Depletion_GS_T1_Price__c ,
    //                                                                                     ASI_CRM_Depletion__c,
    //                                                                                     ASI_CRM_Account__c ,
    //                                                                                     ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
    //                                                                                     ASI_CRM_Outlet__c ,
    //                                                                                     ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,
    //                                                                                     ASI_CRM_Sub_Brand__c ,
    //                                                                                     ASI_CRM_End_Date__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c
    //                                                                                 from ASI_CRM_Exclude_Item_Group_Volume__c 
    //                                                                                 ];              
    //         }
    //         else
    //         {
    //             if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion)
    //             {
    //                 system.debug('outlet promotion =='+subbrandSet+'----'+exculdeWSSet+'====='+excludeOutletSet);
    //                 excludeItemGroupVolumeList = [select Id ,ASI_CRM_CN_Pack_Size__c ,
    //                                                                                     ASI_CRM_CN_Intake_GS_T1_price__c ,
    //                                                                                     ASI_CRM_POS_9L__c ,
    //                                                                                     ASI_CRM_POS_GS__c ,
    //                                                                                     ASI_CRM_Actual_Vol_9L__c ,
    //                                                                                     ASI_CRM_PR_Direct__c ,
    //                                                                                     ASI_CRM_T2_Depletion__c ,
    //                                                                                     ASI_CRM_Depletion_GS_T1_Price__c ,
    //                                                                                     ASI_CRM_Depletion__c,
    //                                                                                     ASI_CRM_Account__c ,
    //                                                                                     ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
    //                                                                                     ASI_CRM_Outlet__c ,
    //                                                                                     ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,
    //                                                                                     ASI_CRM_CN_CRM_Code__c ,
    //                                                                                     ASI_CRM_Sub_Brand__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__c ,
    //                                                                                     ASI_CRM_End_Date__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c
    //                                                                                 from ASI_CRM_Exclude_Item_Group_Volume__c 
    //                                                                                 where ASI_CRM_Sub_Brand__c in: subbrandSet
    //                                                                                 and (ASI_CRM_Account__c in: exculdeWSSet
    //                                                                                     or ASI_CRM_Outlet__c in: excludeOutletSet)
    //                                                                                 and ASI_CRM_End_Date__c <=: endDate
    //                                                                                 and ASI_CRM_End_Date__c >=: startDate
    //                                                                                 and ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Exclusion__c = true];
    //             }
    //             else
    //             {
    //                 system.debug('outlet promotion =='+subbrandSet+'----'+wholesalerIds+'====='+outletIds);
    //                 excludeItemGroupVolumeList = [select Id ,ASI_CRM_CN_Pack_Size__c ,
    //                                                                                     ASI_CRM_CN_Intake_GS_T1_price__c ,
    //                                                                                     ASI_CRM_POS_9L__c ,
    //                                                                                     ASI_CRM_POS_GS__c ,
    //                                                                                     ASI_CRM_Actual_Vol_9L__c ,
    //                                                                                     ASI_CRM_PR_Direct__c ,
    //                                                                                     ASI_CRM_T2_Depletion__c ,
    //                                                                                     ASI_CRM_Depletion_GS_T1_Price__c ,
    //                                                                                     ASI_CRM_Depletion__c,
    //                                                                                     ASI_CRM_Account__c ,
    //                                                                                     ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
    //                                                                                     ASI_CRM_Outlet__c ,
    //                                                                                     ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,
    //                                                                                     ASI_CRM_CN_CRM_Code__c ,
    //                                                                                     ASI_CRM_Sub_Brand__c ,
    //                                                                                     ASI_CRM_End_Date__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c ,
    //                                                                                     ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c
    //                                                                                 from ASI_CRM_Exclude_Item_Group_Volume__c 
    //                                                                                 where ASI_CRM_Sub_Brand__c in: subbrandSet
    //                                                                                 and (ASI_CRM_Account__c in: wholesalerIds
    //                                                                                     or ASI_CRM_Outlet__c in: outletIds)
    //                                                                                 and ASI_CRM_End_Date__c <=: endDate
    //                                                                                 and ASI_CRM_End_Date__c >=: startDate
    //                                                                                 and ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Exclusion__c = true];
    //             }
    //         }
    //         system.debug('excludeItemGroupVolumeList.size() '+excludeItemGroupVolumeList.size());
    //         Transient Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>> outletExcludeMap = new Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>>();
    //         Transient Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>> wholesalerExcludeMap = new Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>>();
    //         for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : excludeItemGroupVolumeList)
    //         {

    //             if(exclude.ASI_CRM_Outlet__c != null)
    //             {
    //                 if(outletExcludeMap.containsKey(exclude.ASI_CRM_Outlet__c))
    //                 {
    //                     List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = outletExcludeMap.get(exclude.ASI_CRM_Outlet__c);
    //                     excludeItemList.add(exclude);
    //                     outletExcludeMap.put(exclude.ASI_CRM_Outlet__c, excludeItemList);
    //                 }
    //                 else
    //                 {
    //                     List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
    //                     excludeItemList.add(exclude);
    //                     outletExcludeMap.put(exclude.ASI_CRM_Outlet__c, excludeItemList);
    //                 }
    //             }

    //             if(exclude.ASI_CRM_Account__c != null)
    //             {
    //                 if(wholesalerExcludeMap.containsKey(exclude.ASI_CRM_Account__c))
    //                 {
    //                     List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = wholesalerExcludeMap.get(exclude.ASI_CRM_Account__c);
    //                     excludeItemList.add(exclude);
    //                     wholesalerExcludeMap.put(exclude.ASI_CRM_Account__c, excludeItemList);
    //                 }
    //                 else
    //                 {
    //                     List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
    //                     excludeItemList.add(exclude);
    //                     wholesalerExcludeMap.put(exclude.ASI_CRM_Account__c, excludeItemList);
    //                 }
    //             }
    //         }
            
    //         for(ASI_TH_CRM_PaymentRequestLineItem__c paymentlineItem : lineItems)
    //         {
    //             // Set<Id> excludeSet = new Set<Id>();
    //             // 先判断outlet，因为在exclude中，outlet不一定存在，存在的时候必定有对应的一个wholesaler，故wholesaler的map是全部的exclude List 集合值
    //             if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && wholesalerExcludeMap.containsKey(paymentLineItem.ASI_CRM_CN_Wholesaler__c))
    //             {
    //                 system.debug('paymentLineItem.Id==='+paymentLineItem.Id+'所对应的wholesaler exclude list==='+ wholesalerExcludeMap.get(paymentLineItem.ASI_CRM_CN_Wholesaler__c).size());
    //                 for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : wholesalerExcludeMap.get(paymentLineItem.ASI_CRM_CN_Wholesaler__c))
    //                 {
    //                     // if(excludeSet.size() > 0 && excludeSet.contains(exclude.Id))continue;
    //                     Boolean flag = ExcludeCount(paymentlineItem , exclude ,subBrandPackSizeMap ,subBrandDropInMap ,subBrandGroupMap ,exculdeWSSet ,excludeOutletSet);
    //                 }
    //                 // ExcludeCount(paymentlineItem , wholesalerExcludeMap.get(paymentLineItem.ASI_CRM_CN_Wholesaler__c) ,subBrandPackSizeMap ,subBrandDropInMap ,subBrandGroupMap ,exculdeWSSet ,excludeOutletSet);
    //             }
    //             else if(paymentLineItem.ASI_CRM_Customer__c != null && outletExcludeMap.containsKey(paymentLineItem.ASI_CRM_Customer__c))
    //             {
    //                 system.debug('paymentLineItem.Id==='+paymentLineItem.Id+'所对应的outlet exclude list==='+ outletExcludeMap.get(paymentLineItem.ASI_CRM_Customer__c).size());
    //                 for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : outletExcludeMap.get(paymentLineItem.ASI_CRM_Customer__c))
    //                 {
    //                     Boolean flag = ExcludeCount(paymentlineItem , exclude ,subBrandPackSizeMap ,subBrandDropInMap ,subBrandGroupMap ,exculdeWSSet ,excludeOutletSet);
    //                     // if(!flag)
    //                     // {
    //                     //     excludeSet.add(exclude.Id);
    //                     // }
    //                 }
                    
    //             }
                
                


    //             system.debug('开始时'+paymentLineItem);
    //             // WS Intake (9L) 的实际数值、以及未扣减前数值和应扣减数值
    //             paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Original__c = paymentLineItem.ASI_CRM_CN_WS_Intake_9L__c;// 保存初始原来的值
    //             paymentLineItem.ASI_CRM_CN_WS_Intake_9L__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Original__c ,paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c);
                
    //             //  Outlet Intake (9L) 的实际数值、以及未扣减前数值和应扣减数值
    //             paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c = paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L__c;// 保存初始原来的值
    //             if(paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c != 0 && paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c != null)
    //             {
    //                 paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c ,paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c);
    //             }
                
    //             // CTD Actual Purchase Value 的实际数值、以及未扣减前数值和应扣减数值
    //             paymentLineItem.ASI_CRM_Actual_Purchase_Value_Original__c = (paymentLineItem.ASI_CRM_CTD_Actual_Purchase_Value__c != null ? paymentLineItem.ASI_CRM_CTD_Actual_Purchase_Value__c : 0); // 保存初始原来的值
    //             paymentLineItem.ASI_CRM_CTD_Actual_Purchase_Value__c = ExcludeJudge(paymentLineItem.ASI_CRM_Actual_Purchase_Value_Original__c ,paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c);
    //             // POS Volume (9L) 的实际数值、以及未扣减前数值和应扣减数值
    //             paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Original__c = (paymentLineItem.ASI_CRM_CN_POS_Volume__c != null ? paymentLineItem.ASI_CRM_CN_POS_Volume__c : 0);// 保存初始原来的值
    //             paymentLineItem.ASI_CRM_CN_POS_Volume__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Original__c ,paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c);// 计算初始值-exclude后得到的值
                
    //             // POS Value 的实际数值、以及未扣减前数值和应扣减数值
    //             paymentLineItem.ASI_CRM_CN_POS_Value_Original__c = (paymentLineItem.ASI_CRM_CN_POS_Value__c != null ? paymentLineItem.ASI_CRM_CN_POS_Value__c : 0); // 保存初始原来的值
    //             paymentLineItem.ASI_CRM_CN_POS_Value__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_POS_Value_Original__c ,paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c); // 计算初始值-exclude后得到的值
                
    //             // CTD Actual Retail Value 的实际数值、以及未扣减前数值和应扣减数值
    //             paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c = (paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value__c != null ? paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value__c : 0); // 保存初始原来的值
    //             if(paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c != null &&
    //                 paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c != 0   )
    //             {
    //                 paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value__c = ExcludeJudge(paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c ,paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c); // 计算初始值-exclude后得到的值 

    //             }
    //             // Actual Value Base 的实际数值、以及未扣减前数值
    //             paymentLineItem.ASI_CRM_CN_Actual_Value_Base_Original__c = (paymentLineItem.ASI_CRM_Actual_Value_Base__c != null ? paymentLineItem.ASI_CRM_Actual_Value_Base__c : 0);

    //             // Total Payable Original 的实际数值、以及未扣减前数值
    //             paymentLineItem.ASI_CRM_CN_Total_Payable_Original__c = (paymentLineItem.ASI_CRM_CN_Total_Payable__c != null ? paymentLineItem.ASI_CRM_CN_Total_Payable__c : 0);

    //             system.debug('计算结束后'+paymentLineItem);
    //         }
    //     }
    //     lineItems = calculateDataSource(lineItems ,dataSource); // 重新计算ASI_CRM_Actual_Value_Base__c
    //     return lineItems;
    // }
    // private Boolean ExcludeCount(ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem ,ASI_CRM_Exclude_Item_Group_Volume__c exclude
    //     ,Map<Id ,String> subBrandPackSizeMap ,Map<Id ,Boolean> subBrandDropInMap ,Map<String ,Set<Id>> subBrandGroupMap ,Set<Id> exculdeWSSet ,Set<Id> excludeOutletSet)
    // {
    //     // for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : excludeList)
    //     // {
            
    //     Boolean WSFlag = false;
    //     Boolean OutletFlag = false;

    //     Boolean itemFlag = true;

    //     // if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && paymentLineItem.ASI_CRM_Customer__c != null && 
    //     //     exclude.ASI_CRM_Account__c != null && exclude.ASI_CRM_Outlet__c != null &&
    //     //     (paymentLineItem.ASI_CRM_CN_Wholesaler__c != exclude.ASI_CRM_Account__c || 
    //     //         paymentLineItem.ASI_CRM_Customer__c != exclude.ASI_CRM_Outlet__c))
    //     // {
    //     //     continueFlag = true;
    //     // }
    //     // else 
    //     if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && exclude.ASI_CRM_Account__c != null &&
    //         paymentLineItem.ASI_CRM_CN_Wholesaler__c != exclude.ASI_CRM_Account__c) { WSFlag = true; }
    //     if(paymentLineItem.ASI_CRM_Customer__c != null && exclude.ASI_CRM_Outlet__c != null &&
    //         paymentLineItem.ASI_CRM_Customer__c != exclude.ASI_CRM_Outlet__c) { OutletFlag = true; }

    //     if(PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' && WSFlag && OutletFlag) return itemFlag;

    //     if((PH.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion' || PH.ASI_CRM_CN_Promotion_Type__c == 'Customer Promotion') && paymentlineItem.ASI_CRM_CN_CRM_Code__c != exclude.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c && paymentLineItem.ASI_CRM_CN_CRM_Code__c != exclude.ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c) return itemFlag;

    //     // 当payment request line item的subbrandId不为空时，且与exclusion的subbrandId不相同，则跳出判断。仅当不为空或相同，方能进入判断
    //     if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c != null && paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  != null && paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  != exclude.ASI_CRM_Sub_Brand__c) return itemFlag;

    //     // if(paymentLineItem.ASI_CRM_CN_Sub_Brand__c != null && paymentLineItem.ASI_CRM_CN_Sub_Brand__c != exclude.ASI_CRM_Sub_Brand__c) continue;

    //     if (paymentLineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Methodology__r.Name == 'Rebate%(By Month)') {
    //         if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c != null)
    //         {
    //             Integer year = paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.year();
    //             Integer month = paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.month();
    //             if (year != exclude.ASI_CRM_End_Date__c.year() || month != exclude.ASI_CRM_End_Date__c.month()) {
    //                 return itemFlag;
    //             }
    //         }
            
    //     }
    //     // 当payment request line item所关联的module是by Brand Group的时候，判断这个group中的subbrandId是否包含exclude，不包含，则跳出循环
    //     if(paymentLineItem.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c == 'By Brand Group' && paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c != null
    //         && paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c != '')
    //     {
    //         if(subBrandGroupMap.containsKey(paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c))
    //         {
    //             Set<Id> subBrandGroupSet = subBrandGroupMap.get(paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c);
    //             if(!subBrandGroupSet.contains(exclude.ASI_CRM_Sub_Brand__c)) return itemFlag;
    //         }
    //         else
    //         {
    //             return itemFlag;
    //         }
    //     }

        

    //     String BRSF_PackSize = '';
    //     Boolean isDropIn = false;

    //     // ASI_CRM_CN_Payment_Request_Detail_Promotion 类型的payment request line item，是存在subbrand，所以可以直接判断这个subbrandId
    //     if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c != null && 
    //         paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  != null)
    //     {
    //         BRSF_PackSize = (subBrandPackSizeMap.containsKey(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) ?
    //                             subBrandPackSizeMap.get(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) : '');
    //         isDropIn = (subBrandDropInMap.containsKey(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) ?
    //                             subBrandDropInMap.get(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) : false);
    //     }
    //     // 其余情况，根据exclusion判断
    //     else if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null || paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  == null)
    //     {
    //         BRSF_PackSize = (subBrandPackSizeMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
    //                             subBrandPackSizeMap.get(exclude.ASI_CRM_Sub_Brand__c) : '');
    //         isDropIn = (subBrandDropInMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
    //                             subBrandDropInMap.get(exclude.ASI_CRM_Sub_Brand__c) : false);
    //     }
        

    //     /* 
    //         如果BRSF line item的pack size 不为空，根据相同的subbrand
    //         包含exclude item group volume中item group 的bottle size，
    //         即将exclude item group volume视为可扣减对象，进行标识
    //     */
    //     if((BRSF_PackSize != null || BRSF_PackSize != '' )
    //         && (exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c != null))
    //     {
            
    //         Integer pointCount = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c.indexOf('.');
    //         String BT_Size = '';
    //         if(pointCount >= 0)
    //         {
    //             BT_Size = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c.substring(0 ,pointCount);
    //         }
    //         else
    //         {
    //             BT_Size = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c;
    //         }
    //         if(BRSF_PackSize.indexOf(BT_Size) != -1)
    //         {
    //             itemFlag = false;
    //         }
            
    //     }
    //     /* 
    //         如果payment request line item中BRSF line item的drop in 为true
    //         且当前exclude item group volume中item group 的drop in也为true，
    //         即将exclude item group volume视为可扣减对象，进行标识
    //     */
    //     if(itemFlag && isDropIn 
    //         && exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c)
    //     {
    //         itemFlag = false;
    //     }

    //     /*
    //         如果itemFlag为false，执行payment request line item与exclude之间的计算逻辑
    //      */
    //     if(!itemFlag)
    //     {
    //         system.debug('exclude.Id =='+exclude.Id);
    //         paymentLineItem = CountExcludeItemGroupAndPaymentItem(paymentLineItem , exclude ,exculdeWSSet ,excludeOutletSet);
    //     }

    //     return itemFlag;
    //     // }
    // }
    // /*
    //     Author：Bowen
    //     Date:2019-11-01
    //     Function:
    //         功能类，当被减数小于减数，则返回0；反之按正常的计算逻辑走
    //  */
    // public static Decimal ExcludeJudge(Decimal orginal ,Decimal exclude)
    // {
    //     Decimal ExcludeResult = 0;
    //     if(orginal == null) orginal = 0;
    //     if(exclude == null) exclude = 0;
    //     ExcludeResult = orginal - exclude;

    //     // if(orginal < exclude)
    //     // {
    //     //     ExcludeResult = 0;
    //     // }
    //     // else
    //     // {
    //     //     ExcludeResult = orginal - exclude;
    //     // }
    //     return ExcludeResult;
    // }
    
    // public Decimal NullJude(Decimal total)
    // {
    //     Decimal result = 0;
    //     if(total != null)
    //     {
    //         result = total;
    //     }
    //     return result;
    // }

    // /*
    //     Author:Bowen
    //     Date:2019-10-29
    //     Function:
    //         计算逻辑：根据整个代码汇总出来，当user选择pack size 或者 drop in的时候，
    //         需要从exclude line item上汇总用于扣减的数据
    //  */
    // public ASI_TH_CRM_PaymentRequestLineItem__c CountExcludeItemGroupAndPaymentItem(ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem ,ASI_CRM_Exclude_Item_Group_Volume__c exclude ,Set<Id> exculdeWSSet ,Set<Id> excludeOutletSet)
    // {
    //     system.debug('进入 CountExcludeItemGroupAndPaymentItem '+exclude.Id);
    //     if(paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c == null) paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c = 0;
    //     if(paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c == null) paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c= 0;
    //     if(paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c == null) paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c= 0;
    //     if(paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c == null) paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c= 0;
    //     if(paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c == null) paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c= 0;
    //     if(paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c == null) paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c= 0;

    //     // paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
    //     // paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //     if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion)
    //     {
    //         if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && exclude.ASI_CRM_Account__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
    //         {
    //             paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
    //             paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //         }
    //         if(paymentLineItem.ASI_CRM_Customer__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c != null)
    //         {
    //             if(exclude.ASI_CRM_Outlet__c != null)
    //             {
    //                 if(paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
    //                 {
    //                     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //                     paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //                 }
    //             }
    //         }
    //         else if(exclude.ASI_CRM_Outlet__c != null && paymentLineItem.ASI_CRM_Customer__c != null 
    //             && paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c)
    //         {
    //             paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //             paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //         }
    //     }
    //     else
    //     {

    //         if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion')
    //         {
    //             if(dataSource !='Outlet Intake')
    //             {
    //                 paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
    //                 paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //             }

    //             // if(outletIds.size() > 0 && exclude.ASI_CRM_Outlet__c != null)
    //             // {
    //             //     for(Id outlet : outletIds)
    //             //     {
    //             //         if(outlet == exclude.ASI_CRM_Outlet__c)
    //             //         {
    //             //             paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //             //             paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //             //         }
    //             //     }
    //             // }

    //             if(dataSource =='Outlet Intake' && exclude.ASI_CRM_Outlet__c != null && excludeOutletSet.size() > 0)
    //             {
    //                 if(excludeOutletSet.contains(exclude.ASI_CRM_Outlet__c))
    //                 {
    //                     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //                     paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //                 }
    //             }
    //             // else if(exclude.ASI_CRM_Outlet__c != null && paymentLineItem.ASI_CRM_Customer__c != null 
    //             //     && paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c)
    //             else if(paymentLineItem.ASI_CRM_Customer__c == null )
    //             {

    //                 if(outletIds.size() > 0 && exclude.ASI_CRM_Outlet__c != null)
    //                 {
    //                     if(outletIds.contains(exclude.ASI_CRM_Outlet__c))
    //                     {
    //                         paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //                         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //                     }
    //                 }
    //             }
                
    //         }
    //         else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Consumer Promotion')
    //         {
    //             if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && exclude.ASI_CRM_Account__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
    //             {
    //                 paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
    //                 paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //             }

    //             if(paymentLineItem.ASI_CRM_Customer__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c != null)
    //             {
    //                 if(exclude.ASI_CRM_Outlet__c != null)
    //                 {
    //                     if(paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
    //                     {
    //                         paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //                         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //                     }
    //                 }
    //             }
    //             else if(exclude.ASI_CRM_Outlet__c != null && paymentLineItem.ASI_CRM_Customer__c != null 
    //                 && paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c)
    //             {
    //                 paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //                 paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //             }
    //             // paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
    //             // paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //             paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_9L__c);
    //             paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_GS__c) * markupPercent;
    //         }
    //     }
        

    //     // if(PH.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion')
    //     // {
    //     //     paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
    //     //     paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //     //     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
    //     //     //if(dataSource =='Outlet Intake')
    //     //     //{                
    //     //     //}
    //     // }
    //     // else if(PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion')
    //     // {
    //     //     paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
    //     //     paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //     //     paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_9L__c);
    //     //     paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_GS__c) * markupPercent;
    //     //     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion__c);

    //     // }
    //     // else if(PH.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
    //     // {
    //     //     paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_9L__c);
    //     //     paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_GS__c) * markupPercent;
    //     //     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion__c);
    //     // }

    //     // if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion)
    //     // {
    //     //     if(PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' || PH.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
    //     //     {
    //     //         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //     //     }
            
    //     // }
    //     // else
    //     // {
    //     //     if(PH.ASI_CRM_CN_Promotion_Type__c =='Wholesaler Promotion')
    //     //     {
    //     //         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
    //     //     }
    //     //     else if(PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' || PH.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
    //     //     {
    //     //         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
    //     //     }
    //     // }
        
    //     return paymentLineItem;
    // }


    public List<ASI_TH_CRM_PaymentRequestLineItem__c> createPaymentRequestLineFromContractLines(List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList) {
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        Id PRDORecordTypeId = ASI_TH_CRM_PaymentRequestLineItem__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Payment_Request_Detail_Promotion').getRecordTypeId();

        // Create a payment request line for each contract line
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractList) {
            ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine = createPaymentRequestLineItem(PH.Id, null, null, PRDORecordTypeId);
            paymentRequestLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
            if(!test.isRunningTest()) {paymentRequestLine.ASI_CRM_CN_Sub_Brand__r = ContractLine.ASI_CRM_CN_Sub_Brand__r;}
            //paymentRequestLine.ASI_CRM_Line_Name__c = ContractLine.ASI_CRM_Line_Name__c;
            paymentRequestLine.ASI_CRM_Line_Long_Name__c = ContractLine.ASI_CRM_Line_Long_Name__c;
            paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.Id;
            paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r = ContractLine;
            paymentRequestLine.ASI_CRM_CN_Rebate_Percent__c = ContractLine.ASI_CRM_CN_Rebate_Percent__c;


            paymentRequestLines.add(paymentRequestLine);
        }

        return paymentRequestLines;
    }

    public ASI_TH_CRM_PaymentRequestLineItem__c calculateSubBrandVolumesByBreakdowns(List<ASI_CRM_Volume_Aggregation_Breakdown__c> subBrandVolumesBreakdowns, ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine, String promotionType, String dataSource, String volumeBase, String methodology, Boolean IsModule) {
        if (paymentRequestLine == null) {
            return null;
        }
        return calculateSubBrandVolumesByBreakdowns(subBrandVolumesBreakdowns, new List<ASI_TH_CRM_PaymentRequestLineItem__c>{
                paymentRequestLine
        }, promotionType, dataSource, volumeBase, methodology, IsModule)[0];
    }

    public List<ASI_TH_CRM_PaymentRequestLineItem__c> calculateSubBrandVolumesByBreakdowns(List<ASI_CRM_Volume_Aggregation_Breakdown__c> subBrandVolumesBreakdowns, List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines, String promotionType, String dataSource, String volumeBase, String methodology, Boolean IsModule) {
        if (subBrandVolumesBreakdowns == null || subBrandVolumesBreakdowns.isEmpty()) {
            return paymentRequestLines;
        }
        // Calculate all actual volume and actual value for each payment request line
        for (ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine : paymentRequestLines) {
//            Set<Id> subBrandVolIds = new Set<Id>();
            for (ASI_CRM_Volume_Aggregation_Breakdown__c Breakdown : subBrandVolumesBreakdowns) {
                if (volumeBase == 'By Sub-Brand' && paymentRequestLine.ASI_CRM_CN_Sub_Brand__c != null && Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Subbrand__c != null &&  paymentRequestLine.ASI_CRM_CN_Sub_Brand__c != Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Subbrand__c) {
                    continue;
                }
                //if (volumeBase == 'By Brand Group' && !paymentRequestLine.ASI_CRM_Line_Name__c.contains(subBrandVolume.ASI_CRM_Subbrand__c)) {
                if (volumeBase == 'By Brand Group' && paymentRequestLine.ASI_CRM_Line_Long_Name__c != null && Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Subbrand__c != null  && !paymentRequestLine.ASI_CRM_Line_Long_Name__c.contains(Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Subbrand__c)) {
                    continue;
                }
                if (methodology == 'Rebate%(By Month)') {
                    Integer year = paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.year();
                    Integer month = paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.month();
                    if (year != Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_End_Date__c.year() || month != Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_End_Date__c.month()) {
                        continue;
                    }
                }
                switch on promotionType {
                    when 'Outlet Promotion', 'Consumer Promotion' {
//                        if(!subBrandVolIds.contains(Breakdown.ASI_CRM_Sub_brand_Volume__c)){
//                            paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c += denullify(Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_T1_Depletion__c);
//                            paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value__c += denullify(Breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_T1_Depletion_GS__c) * markupPercent;
//                        }
                        paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c +=  denullify(Breakdown.ASI_CRM_Depletion__c);
                        //paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c += denullify(Breakdown.ASI_CRM_Depletion_GS__c) * markupPercent;
                        paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c += denullify(Breakdown.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
//                        subBrandVolIds.add(Breakdown.ASI_CRM_Sub_brand_Volume__c);

// standard bottle
                        paymentRequestLine.ASI_CRM_CN_Outlet_Intake_Std__c += denullify(Breakdown.ASI_CRM_Depletion_STD__c);
                    }
                }
                // paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c -= Breakdown.ASI_CRM_Volume_Out__c;
            }

            //Calculate WS Vol and WS Intake
            if(promotionType =='Outlet Promotion' && IsModule==false){
                if(WSSubbrandVolumeMap.containsKey(paymentRequestLine.ASI_CRM_CN_Wholesaler__c)){
                    for(ASI_CRM_Subbrand_Volume__c vol : WSSubbrandVolumeMap.get(paymentRequestLine.ASI_CRM_CN_Wholesaler__c)){
                        paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c += denullify(vol.ASI_CRM_Actual_Vol_9L__c);
                        paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value__c += (denullify(vol.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent-denullify(vol.ASI_CRM_CN_Volume_Out_GS_Price__c));

                        // standard bottle
                        if(paymentRequestLine.ASI_CRM_CN_WS_Intake_Std__c != null)
                        {
                            paymentRequestLine.ASI_CRM_CN_WS_Intake_Std__c += denullify(vol.ASI_CRM_Actual_Vol_STD__c);
                        }
                        else
                        {
                            paymentRequestLine.ASI_CRM_CN_WS_Intake_Std__c = denullify(vol.ASI_CRM_Actual_Vol_STD__c);

                        }
                    }
                }
            }
        }
        return paymentRequestLines;
    }

    public ASI_TH_CRM_PaymentRequestLineItem__c calculateSubBrandVolumes(List<ASI_CRM_Subbrand_Volume__c> subBrandVolumes, ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine, String promotionType, String dataSource, String volumeBase, String methodology) {
        if (paymentRequestLine == null) {
            return null;
        }
        return calculateSubBrandVolumes(subBrandVolumes, new List<ASI_TH_CRM_PaymentRequestLineItem__c>{
                paymentRequestLine
        }, promotionType, dataSource, volumeBase, methodology)[0];
    }

    public List<ASI_TH_CRM_PaymentRequestLineItem__c> calculateSubBrandVolumes(List<ASI_CRM_Subbrand_Volume__c> subBrandVolumes, List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines, String promotionType, String dataSource, String volumeBase, String methodology) {
        if (subBrandVolumes == null || subBrandVolumes.isEmpty()) {
            return paymentRequestLines;
        }

        System.debug(LoggingLevel.INFO, '*** subBrandVolumes: ' + subBrandVolumes);
        System.debug(LoggingLevel.INFO, '*** paymentRequestLines: ' + paymentRequestLines);
        System.debug(LoggingLevel.INFO, '*** volumeBase: ' + volumeBase);
        System.debug(LoggingLevel.INFO, '*** methodology: ' + methodology);

        // Calculate all actual volume and actual value for each payment request line
        for (ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine : paymentRequestLines) {
            for (ASI_CRM_Subbrand_Volume__c subBrandVolume : subBrandVolumes) {
                if (volumeBase == 'By Sub-Brand' && paymentRequestLine.ASI_CRM_CN_Sub_Brand__c != null &&
                                subBrandVolume.ASI_CRM_Subbrand__c != null && 
                                paymentRequestLine.ASI_CRM_CN_Sub_Brand__c != subBrandVolume.ASI_CRM_Subbrand__c) {
                    continue;
                }
                //if (volumeBase == 'By Brand Group' && !paymentRequestLine.ASI_CRM_Line_Name__c.contains(subBrandVolume.ASI_CRM_Subbrand__c)) {
                if (volumeBase == 'By Brand Group' && paymentRequestLine.ASI_CRM_Line_Long_Name__c != null &&
                                subBrandVolume.ASI_CRM_Subbrand__c != null && 
                                !paymentRequestLine.ASI_CRM_Line_Long_Name__c.contains(subBrandVolume.ASI_CRM_Subbrand__c)) {
                    continue;
                }
                if (methodology == 'Rebate%(By Month)') {
                    if(paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c != null)
                    {
                        Integer year = paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.year();
                        Integer month = paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.month();
                        if (year != subBrandVolume.ASI_CRM_End_Date__c.year() || month != subBrandVolume.ASI_CRM_End_Date__c.month()) {
                            continue;
                        }
                    }
                    
                }

                switch on promotionType {
                    when 'Wholesaler Promotion' {
                        if(dataSource =='Outlet Intake'){
                            for(ASI_CRM_Volume_Aggregation_Breakdown__c breakdown : subBrandVolume.Sub_brand_Volume_Aggregation_Breakdown__r) {
                                if(paymentRequestLine.ASI_CRM_CN_Wholesaler__c == breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c){
                                    if(!Test.isRunningTest()) paymentRequestLine.ASI_CRM_CN_Wholesaler__r = breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r;
                                    paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c += denullify(breakdown.ASI_CRM_Depletion__c);
                                    //paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c += denullify(breakdown.ASI_CRM_Depletion_GS__c) * markupPercent;
                                    paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c += denullify(breakdown.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;

                                    // standard bottle
                                    paymentRequestLine.ASI_CRM_CN_Outlet_Intake_Std__c += denullify(Breakdown.ASI_CRM_Depletion_STD__c);

                                    system.debug('breakdown.Id==='+breakdown.Id + ' ---------breakdown.ASI_CRM_Depletion__c =='+breakdown.ASI_CRM_Depletion__c);
                                    system.debug('paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c =='+paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c);
                                }
                            }
                        }else {
                            if (paymentRequestLine.ASI_CRM_CN_Wholesaler__c == subBrandVolume.ASI_CRM_Account__c) {
                                //paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c += denullify(subBrandVolume.ASI_CRM_Actual_Vol_9L__c);
                                paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c += denullify(subBrandVolume.ASI_CRM_CN_WS_Tier__c=='T2' ? subBrandVolume.ASI_CRM_Actual_Vol_9L__c : 0);

                                // standard bottle
                                paymentRequestLine.ASI_CRM_CN_WS_Intake_Std__c += denullify(subBrandVolume.ASI_CRM_CN_WS_Tier__c=='T2' ? subBrandVolume.ASI_CRM_Actual_Vol_STD__c : 0);

                                //paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value__c += denullify(subBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
                                paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value__c += (denullify(subBrandVolume.ASI_CRM_CN_WS_Tier__c=='T2' ? subBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c : 0) * markupPercent -denullify(subBrandVolume.ASI_CRM_CN_Volume_Out_GS_Price__c));
                                for (ASI_CRM_Volume_Aggregation_Breakdown__c breakdown : subBrandVolume.Outlet_Intake__r) {
                                    paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c += denullify(breakdown.ASI_CRM_Depletion__c);
                                    paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c += denullify(breakdown.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;

                                    // standard bottle
                                    paymentRequestLine.ASI_CRM_CN_Outlet_Intake_Std__c += denullify(breakdown.ASI_CRM_Depletion_STD__c);
                                }

                            }
                        }
//                        if (paymentRequestLine.ASI_CRM_CN_Wholesaler__c == subBrandVolume.ASI_CRM_CN_Supplier__c) {
//                            paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c += denullify(subBrandVolume.ASI_CRM_T2_Depletion_STD__c);
//                            paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c += denullify(subBrandVolume.ASI_CRM_T2_Depletion_GS__c) * markupPercent;
//                        }
                    }
                    when 'Outlet Promotion', 'Consumer Promotion' {
                        paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c += denullify(subBrandVolume.ASI_CRM_Actual_Vol_9L__c);
                        paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c += (denullify(subBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent -denullify(subBrandVolume.ASI_CRM_CN_Volume_Out_GS_Price__c));
                        //paymentRequestLine.ASI_CRM_CN_Outlet_Offtake_9L__c += denullify(subBrandVolume.ASI_CRM_Offtake_Std__c);
                        //paymentRequestLine.ASI_CRM_CTD_Actual_Offtake_Value__c += denullify(subBrandVolume.ASI_CRM_Offtake_GS__c) * markupPercent;
                        paymentRequestLine.ASI_CRM_CN_POS_Volume__c += denullify(subBrandVolume.ASI_CRM_POS_9L__c);
                        paymentRequestLine.ASI_CRM_CN_POS_Value__c += denullify(subBrandVolume.ASI_CRM_POS_GS__c) * markupPercent;

                        // standard bottle
                        paymentRequestLine.ASI_CRM_CN_Outlet_Intake_Std__c += denullify(subBrandVolume.ASI_CRM_Actual_Vol_STD__c);
                    }
                }

            }
        }
        return paymentRequestLines;
    }

    public static ASI_TH_CRM_PaymentRequestLineItem__c calculateDataSource(ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine, String dataSource) {
        if (paymentRequestLine == null) {
            return null;
        }
        return calculateDataSource(new List<ASI_TH_CRM_PaymentRequestLineItem__c>{
                paymentRequestLine
        }, dataSource)[0];
    }
    public static List<ASI_TH_CRM_PaymentRequestLineItem__c> calculateDataSource(List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines, String dataSource) {
        Decimal wholesalerIntakeSum = 0;
        Decimal outletIntakeSum = 0;

        // Calculate all actual volume and actual value for each payment request line
        for (ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine : paymentRequestLines) {
            wholesalerIntakeSum += denullify(paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c);
            outletIntakeSum += denullify(paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c);
        }

        // Determine which volume/value to use base on data source
        for (ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine : paymentRequestLines) {
            switch on dataSource {
                when 'Min(WS Intake, Outlet Intake)' {
                    Boolean takeWholesalerIntake = wholesalerIntakeSum < outletIntakeSum;
                    if (takeWholesalerIntake) {
                        paymentRequestLine.ASI_CRM_CTD_Actual_Vol__c = paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c;
                        paymentRequestLine.ASI_CRM_Actual_Value_Base__c = paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value__c;
                        paymentRequestLine.ASI_CRM_CTD_Actual_Vol_Std__c = paymentRequestLine.ASI_CRM_CN_WS_Intake_Std__c;
                    } else {
                        paymentRequestLine.ASI_CRM_CTD_Actual_Vol__c = paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c;
                        paymentRequestLine.ASI_CRM_Actual_Value_Base__c = paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c;
                        paymentRequestLine.ASI_CRM_CTD_Actual_Vol_Std__c = paymentRequestLine.ASI_CRM_CN_Outlet_Intake_Std__c;

                    }
                }
                when 'WS Intake' {
                    paymentRequestLine.ASI_CRM_CTD_Actual_Vol__c = paymentRequestLine.ASI_CRM_CN_WS_Intake_9L__c;
                    paymentRequestLine.ASI_CRM_Actual_Value_Base__c = paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value__c;
                    paymentRequestLine.ASI_CRM_CTD_Actual_Vol_Std__c = paymentRequestLine.ASI_CRM_CN_WS_Intake_Std__c;
                }
                when 'Outlet Intake' {
                    paymentRequestLine.ASI_CRM_CTD_Actual_Vol__c = paymentRequestLine.ASI_CRM_CN_Outlet_Intake_9L__c;
                    paymentRequestLine.ASI_CRM_Actual_Value_Base__c = paymentRequestLine.ASI_CRM_CTD_Actual_Retail_Value__c;
                    paymentRequestLine.ASI_CRM_CTD_Actual_Vol_Std__c = paymentRequestLine.ASI_CRM_CN_Outlet_Intake_Std__c;
                }
                when 'Offtake' {
                    //paymentRequestLine.ASI_CRM_CTD_Actual_Vol__c = paymentRequestLine.ASI_CRM_CN_Outlet_Offtake_9L__c;
                    //paymentRequestLine.ASI_CRM_Actual_Value_Base__c = paymentRequestLine.ASI_CRM_CTD_Actual_Offtake_Value__c;
                }
                when 'POS' {
                    paymentRequestLine.ASI_CRM_CTD_Actual_Vol__c = paymentRequestLine.ASI_CRM_CN_POS_Volume__c;
                    paymentRequestLine.ASI_CRM_Actual_Value_Base__c = paymentRequestLine.ASI_CRM_CN_POS_Value__c;
                }
            }
        }


        return paymentRequestLines;
    }

    public static List<ASI_TH_CRM_PaymentRequestLineItem__c> calculatePerIncentiveBottle(List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines) {
        for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : paymentRequestLines) {
            // system.debug('calculatePerIncentiveBottle lineItem计算 lineItem.ASI_CRM_CTD_Actual_Vol__c '+lineItem.ASI_CRM_CTD_Actual_Vol__c+'---lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c ===' +lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c + 'lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c ==' + lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c);
            if(!Test.isRunningTest()) lineItem.ASI_CRM_CN_Total_Payable__c = (denullify(lineItem.ASI_CRM_CTD_Actual_Vol__c)*9000/denullify(bottleSizeMap.get(lineItem.ASI_CRM_CN_Sub_Brand__c),700) * denullify(lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c)).setScale(2, System.RoundingMode.FLOOR);
            //if(!Test.isRunningTest()) lineItem.ASI_CRM_CN_Total_Payable__c = (denullify(lineItem.ASI_CRM_CTD_Actual_Vol_Std__c) * denullify(lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c)).round(System.RoundingMode.FLOOR);
            // system.debug('---calculatePerIncentiveBottle end lineItem.ASI_CRM_CN_Total_Payable__c--'+lineItem.ASI_CRM_CN_Total_Payable__c);
        }

        return paymentRequestLines;
    }
    public static List<ASI_TH_CRM_PaymentRequestLineItem__c> calculateRebatePercentByPackage(List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines, String volumeBase) {
        List<ASI_TH_CRM_PaymentRequestLineItem__c> returnLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        if (paymentRequestLines.isEmpty()) {
            return returnLines;
        }

        // Group by Sub-Brand/Sub-Brand Group
        Map<String, List<ASI_TH_CRM_PaymentRequestLineItem__c>> lineItemMap = new Map<String, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();

        if (volumeBase == 'By Sub-Brand') {
            lineItemMap = ASI_CRM_CN_UtilGroupBy.groupByStrings('ASI_CRM_CN_Sub_Brand__c', paymentRequestLines);
        }
        if (volumeBase == 'By Brand Group') {
            //lineItemMap = ASI_CRM_CN_UtilGroupBy.groupByStrings('ASI_CRM_Line_Name__c', paymentRequestLines);
            lineItemMap = ASI_CRM_CN_UtilGroupBy.groupByStrings('ASI_CRM_Line_Long_Name__c', paymentRequestLines);
        }
        if (volumeBase == 'By Total') {
            lineItemMap.put('total', paymentRequestLines);
        }
        // System.debug('lineItemMap ' + lineItemMap.keySet());

        for (List<ASI_TH_CRM_PaymentRequestLineItem__c> lineItems : lineItemMap.values()) {
            // Sort lines by ASI_CRM_CN_Min_Purchase_Target__c, from high to low
            List<PaymentRequestLineWrapper> paymentRequestLineWrappers = new List<PaymentRequestLineWrapper>();

            for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lineItems) {
                // System.debug('calculateRebatePercentByPackage lineItem.ASI_CRM_Actual_Value_Base__c ' + lineItem.ASI_CRM_Actual_Value_Base__c);
                paymentRequestLineWrappers.add(new PaymentRequestLineWrapper(lineItem, lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c));
            }
            if(!Test.isRunningTest()) {paymentRequestLineWrappers.sort();}
            Decimal remainingAmount = paymentRequestLineWrappers[0].lineItem.ASI_CRM_Actual_Value_Base__c;
            // System.debug('remainingAmount ' + remainingAmount);
            for (PaymentRequestLineWrapper wrapper : paymentRequestLineWrappers) {
                ASI_TH_CRM_PaymentRequestLineItem__c lineItem = wrapper.lineItem;
                // system.debug('lineItem ==' + lineItem);

                if (remainingAmount < wrapper.value) {
                    // System.debug('calculateRebatePercentByPackage remainingAmount ' + remainingAmount + '   wrapper.value'+ wrapper.value + '  lineItem.ASI_CRM_CN_Actual_Package_Number__c == '+lineItem.ASI_CRM_CN_Actual_Package_Number__c);
                    // system.debug('calculateRebatePercentByPackage lineItem.Id ===' + lineItem.Id);
                    lineItem.ASI_CRM_CN_Actual_Package_Number__c = 0;
                    returnLines.add(lineItem);
                    // continue;
                }
                else
                {
                    if(!Test.isRunningTest()) 
                    {
                        if(wrapper.value != null && wrapper.value != 0)
                        {

                            lineItem.ASI_CRM_CN_Actual_Package_Number__c = Integer.valueOf(remainingAmount / wrapper.value);
                            // System.debug('calculateRebatePercentByPackage remainingAmount ' + remainingAmount + '   wrapper.value'+ wrapper.value + '  lineItem.ASI_CRM_CN_Actual_Package_Number__c == '+lineItem.ASI_CRM_CN_Actual_Package_Number__c);
                            // system.debug('calculateRebatePercentByPackage lineItem.Id ===' + lineItem.Id);
                        }
                        else
                        {
                            lineItem.ASI_CRM_CN_Actual_Package_Number__c = 0;
                        }
                    }
                }
                
                if(!Test.isRunningTest()) {lineItem.ASI_CRM_CN_Total_Payable__c = lineItem.ASI_CRM_CN_Actual_Package_Number__c * wrapper.value * denullify(lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c) / 100;}

                if(!Test.isRunningTest()) {remainingAmount = remainingAmount - lineItem.ASI_CRM_CN_Actual_Package_Number__c * wrapper.value;}
                // system.debug('---calculateRebatePercentByPackage end lineItem.ASI_CRM_CN_Total_Payable__c--'+lineItem.ASI_CRM_CN_Total_Payable__c);
                returnLines.add(lineItem);
            }
        }

        return returnLines;
    }

    public static List<ASI_TH_CRM_PaymentRequestLineItem__c> calculateRebatePercentByLadder(List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines) {
        for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : paymentRequestLines) {
      
            Decimal min = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c;
            Decimal actualPurchaseValue = lineItem.ASI_CRM_Actual_Value_Base__c;
            Decimal max = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c;
            
            // system.debug('calculateRebatePercentByLadder----min =='+min+'----max =='+max);
            // system.debug('calculateRebatePercentByLadder actualPurchaseValue=='+actualPurchaseValue +'---lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c=='+lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c +'lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c=='+lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c);
            if (min <= actualPurchaseValue && (actualPurchaseValue <= max || max == null)) {
                
                lineItem.ASI_CRM_CN_Total_Payable__c = actualPurchaseValue * denullify(lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c) / 100;
            } else {
                lineItem.ASI_CRM_CN_Total_Payable__c = 0;
            }
            // system.debug('---calculateRebatePercentByLadder end lineItem.ASI_CRM_CN_Total_Payable__c--'+lineItem.ASI_CRM_CN_Total_Payable__c);
        }

        return paymentRequestLines;
    }

    public static List<ASI_TH_CRM_PaymentRequestLineItem__c> calculateRebatePercent(List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines) {
        for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : paymentRequestLines) {
            // system.debug('calculateRebatePercent lineItem.ASI_CRM_Actual_Value_Base__c=='+lineItem.ASI_CRM_Actual_Value_Base__c +'---lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c=='+lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c +'lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c=='+lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c);
            if(!test.isRunningTest()) lineItem.ASI_CRM_CN_Total_Payable__c = (lineItem.ASI_CRM_Actual_Value_Base__c != null ? lineItem.ASI_CRM_Actual_Value_Base__c : 0) * (lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c != null ? denullify(lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c) : 0)/ 100;
          // system.debug('---calculateRebatePercent end lineItem.ASI_CRM_CN_Total_Payable__c--'+lineItem.ASI_CRM_CN_Total_Payable__c);
        }

        return paymentRequestLines;
    }

    public static List<ASI_CRM_Volume_Aggregation_Breakdown__c> retrieveSubBrandVolumeBreakdown(Date startDate, Date endDate, Set<Id> WSOutletIds, Set<Id> subBrandIds){
        if (startDate == null || endDate == null) {
            return new List<ASI_CRM_Volume_Aggregation_Breakdown__c>();
        }
        startDate = startDate.toStartOfMonth();
        endDate = endDate.toStartOfMonth().addMonths(1).addDays(-1);
        system.debug(startDate + 'WSOutletIds : '+WSOutletIds);
        system.debug('subBrandIds : '+subBrandIds);
        system.debug(endDate +'WSOutletIds : '+WSOutletIds);

        
        return [
                select  ASI_CRM_Depletion__c,
                        ASI_CRM_Depletion_GS__c,
                        ASI_CRM_Depletion_GS_T1_Price__c,
                        ASI_CRM_Depletion_STD__c,
                        ASI_CRM_Month__c,
                        ASI_CRM_Year__c,
                        ASI_CRM_Sub_brand_RO__c,
                        ASI_CRM_Volume_Out__c ,
                        ASI_CRM_Outlet_Sub_brand_Volume__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_T1_Depletion__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_T1_Depletion_GS__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_STD__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Intake_GS_T1_price__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Volume_Out_GS_Price__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Offtake_GS__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_POS_9L__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_POS_GS__c,
                        ASI_CRM_Sub_brand_Volume__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_T1_Depletion__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_T1_Depletion_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_STD__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_CN_Intake_GS_T1_price__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_CN_Volume_Out_GS_Price__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Offtake_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_POS_9L__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_POS_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_End_Date__c ,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Subbrand__c
                from ASI_CRM_Volume_Aggregation_Breakdown__c
                where ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c IN :WSOutletIds
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Subbrand__c in :subBrandIds
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_End_Date__c <= :endDate
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_End_Date__c >= :startDate
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Competitor_Sub_brand__c = FALSE
                and ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                and ASI_CRM_Outlet_Sub_brand_Volume__r.RecordType.DeveloperName = 'ASI_CRM_CN_WS_Outlet_Sub_brand_Volume'

        ];
    }

    // Actual value base is base on contract's data source
    public List<ASI_CRM_Subbrand_Volume__c> retrieveSubBrandVolume(Date startDate, Date endDate, Set<Id> WSOutletIds, Set<Id> outletIds, Set<Id> WSIds, Set<Id> subBrandIds) {
        if (startDate == null || endDate == null) {
            return new List<ASI_CRM_Subbrand_Volume__c>();
        }
        startDate = startDate.toStartOfMonth();
        endDate = endDate.toStartOfMonth().addMonths(1).addDays(-1);
//        String subBrandVolumeDeveloperName = '';
//        String contractId = '';
//        if (outletIds.size() <= ASI_CRM_CN_OffContractUtilitiesClass.outletThreshold()) {
//            subBrandVolumeDeveloperName = 'ASI_CRM_CN_WS_Outlet_Sub_brand_Volume';
//        } else {
//            subBrandVolumeDeveloperName = 'CN_WS_Outlet_Monthly_Sub_Brand_Data';
//            contractId = PH.ASI_TH_CRM_Contract__c;
//        }
        return [
                SELECT
                        ASI_CRM_Account__c,
                        ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Account__r.Name,
                        ASI_CRM_Actual_Vol__c,
                        ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Actual_Vol_STD__c,
                        ASI_CRM_CN_Payment_Request_Line_Item__c,
                        ASI_CRM_Empty_Bottle_Btl__c,
                        ASI_CRM_End_Date__c,
                        ASI_CRM_PR_Direct__c,
                        ASI_CRM_PR_Direct_CR12__c,
                        ASI_CRM_PR_Direct_STD_Billing__c,
                        ASI_CRM_Sub_Brand_Grade_Incentive__c,
                        ASI_CRM_CN_Supplier__c,
                        ASI_CRM_CN_Supplier__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_CN_Supplier__r.Name,
                        ASI_CRM_Subbrand__c,
                        ASI_CRM_T1_Depletion__c,
                        ASI_CRM_T1_Depletion_BTL__c,
                        ASI_CRM_T1_Depletion_CR12__c,
                        ASI_CRM_T1_Depletion_GS__c,
                        ASI_CRM_T1_Depletion_STD__c,
                        ASI_CRM_T1_Depletion_STD_Billing__c,
                        ASI_CRM_T2_Depletion__c,
                        ASI_CRM_T2_Depletion_CR12__c,
                        ASI_CRM_T2_Depletion_GS__c,
                        ASI_CRM_T2_Depletion_STD_Billing__c,
                        ASI_CRM_T2_Depletion_STD__c,
                        ASI_CRM_Intake_GS__c,
                        ASI_CRM_CN_Intake_GS_T1_price__c,
                        ASI_CRM_CN_Volume_Out_GS_Price__c,
                        ASI_CRM_Offtake_GS__c,
                        ASI_CRM_Offtake_Std__c,
                        ASI_CRM_Offtake__c,
                        ASI_CRM_POS_9L__c,
                        ASI_CRM_POS_GS__c,
                        ASI_CRM_POS_Std_Btl__c,
                        ASI_CRM_CN_WS_Tier__c,
                        ASI_CRM_Intake_Std_Btl__c,
                (select ASI_CRM_Account__c,
                        ASI_CRM_Depletion__c,
                        ASI_CRM_Depletion_GS__c,
                        ASI_CRM_Depletion_GS_T1_Price__c,
                        ASI_CRM_Depletion_STD__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_STD__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_T2_Depletion_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Intake_Std_Btl__c
                from Outlet_Intake__r
                where ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c in :outletIds),
                (select ASI_CRM_Account__c,
                        ASI_CRM_Depletion__c,
                        ASI_CRM_Depletion_GS__c,
                        ASI_CRM_Depletion_GS_T1_Price__c,
                        ASI_CRM_Depletion_STD__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_STD__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_T2_Depletion_GS__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Intake_Std_Btl__c
                from Sub_brand_Volume_Aggregation_Breakdown__r
                where ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c in :WSIds
                )
                FROM ASI_CRM_Subbrand_Volume__c
                WHERE ASI_CRM_Account__c IN :WSOutletIds
                AND ASI_CRM_Subbrand__c IN :subBrandIds
                AND ASI_CRM_End_Date__c <= :endDate
                AND ASI_CRM_End_Date__c >= :startDate
                AND ASI_CRM_CN_Competitor_Sub_brand__c = FALSE
                AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                AND RecordType.DeveloperName = 'ASI_CRM_CN_WS_Outlet_Sub_brand_Volume'
                ORDER BY ASI_CRM_CN_Supplier__c, ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c
        ];
    }
    public ASI_TH_CRM_PaymentRequestLineItem__c createPaymentRequestLineItem(Id paymentId, Id moduleId, String volumeBase, Id recordTypeId) {
        ASI_TH_CRM_PaymentRequestLineItem__c lineItem = new ASI_TH_CRM_PaymentRequestLineItem__c (
                ASI_CRM_Actual_Volume_Id__c = '',
                ASI_CRM_Actual_Value_Base__c = 0,
                ASI_CRM_CN_Actual_Vol__c = 0,
                ASI_CRM_CN_Outlet_Intake_9L__c = 0,
                ASI_CRM_CN_Outlet_Intake_Std__c = 0,
                //ASI_CRM_CN_Outlet_Offtake_9L__c = 0,
                //ASI_CRM_CN_Payable_Vol__c = 0,
                ASI_CRM_CN_POS_Value__c = 0,
                ASI_CRM_CN_POS_Volume__c = 0,
                ASI_CRM_CN_Rebate_Percent__c = 0,
                //ASI_CRM_CN_Suggested_Amount__c = 0,
                ASI_CRM_CN_Total_Payable__c = 0,
                ASI_CRM_CN_WS_Intake_9L__c = 0,
                ASI_CRM_CN_WS_Intake_Std__c = 0,
                //ASI_CRM_CTD_Actual_Offtake_Value__c = 0,
                ASI_CRM_CTD_Actual_Purchase_Value__c = 0,
                ASI_CRM_CTD_Actual_Retail_Value__c = 0,
                ASI_CRM_CTD_Actual_Vol__c = 0,
                ASI_CRM_CTD_Actual_Vol_Std__c = 0,
                ASI_CRM_Module__c = moduleId,
                ASI_CRM_Suggested_Volume__c = 0,
                ASI_CRM_V0_0_Full_Contract_Target__c = 0,
                ASI_CRM_Volume_Base__c = volumeBase,
                ASI_TH_CRM_Payment_Request__c = paymentId,
                RecordTypeId =  recordTypeId
        );
        return lineItem;
    }
    public ASI_CRM_Module__c createModule(ASI_CRM_Module__c module) {

        return new ASI_CRM_Module__c(
                ASI_CRM_Volume_Base__c = module.ASI_CRM_Volume_Base__c,
                ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
                ASI_CRM_Line_Type__c = module.ASI_CRM_Line_Type__c,
                ASI_CRM_Methodology__c = module.ASI_CRM_Methodology__c,
                ASI_CRM_Payment_Request__c = PageId
        );
    }

    @RemoteAction
    public static List<SObject> retrieveFreeGoods(String obj, String qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {// Object name not valid
            return null;
        }

        //begin building the dynamic soql query
        String soql = 'select ' +
                'Id, Name,ASI_MFM_Item_Group_Code__c ,(select id, ASI_CRM_CN_T1_Price__c from T1_Price__r where ASI_CRM_CN_Effective_Date__c <= today order by ASI_CRM_CN_Effective_Date__c desc limit 1)  from ' + obj;
        if (String.isNotEmpty(qry)) {
            soql += qry;
        }
        soql += ' order by Name';

        try {
            return Database.query(soql);
        } catch (QueryException e) {
            ASI_MFM_ByPass_Setting.ErrorHandling('RemoteAction.ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList class have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_EditHeavyContractDetailCtrl', 'failed! ');
            return null;
        }
    }

    public static Decimal denullify(Decimal input, Integer defaultValue) {
        if (input == null) {
            return Decimal.valueOf(defaultValue);
        }
        return input;
    }
    public static Decimal denullify(Decimal input) {
        return denullify(input, 0);
    }

    public Map<String, String> retrieveReports() {
        Map<String, String> reportsByName = new Map<String, String>();
        for (Report report : [SELECT Id, Name, DeveloperName FROM Report WHERE FolderName = 'ASI CRM CN WS Evaluation Report']) {
            reportsByName.put(report.Name, report.Id);
        }


        return reportsByName;
    }


    public class interimData {
        public ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLineOutletWS { set; get; }
        public ASI_CRM_Module__c module { set; get; }
        //        List<ASI_CRM_Module__c> modules { set; get; }
        public List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines { set; get; }
        public List<interimData> moduleWrappers { set; get; }
        public Decimal ASI_CRM_Application_Payment_Amount {get;set;}
        public List<ASI_CRM_Subbrand_Volume__c> subBrandVolumes;
        public List<ASI_CRM_Volume_Aggregation_Breakdown__c>  subBrandVolumeBreakdowns;
        public interimData() {
            module = new ASI_CRM_Module__c();
            moduleWrappers = new List<interimData>();
            paymentRequestLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        }
        public interimData(ASI_CRM_Module__c m) {
            module = m;
            moduleWrappers = new List<interimData>();
            paymentRequestLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        }
    }

    // For sorting purpose only
    class PaymentRequestLineWrapper implements Comparable {

        public ASI_TH_CRM_PaymentRequestLineItem__c lineItem;
        public String key;
        public Decimal value;

        // Constructor
        public PaymentRequestLineWrapper(ASI_TH_CRM_PaymentRequestLineItem__c i, Decimal v) {
            lineItem = i;
            value = v;
        }

        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            PaymentRequestLineWrapper compareToEmp = (PaymentRequestLineWrapper) compareTo;
            return Integer.valueOf(compareToEmp.value - value);
        }
    }

    //20200513:AM@introv - copy "Tax Calculation" button (ASI_CRM_CN_Payment_Header_Controller [class] + ASI_CRM_CN_Payment_Header_Page [vf page])
    Public pageReference reDirectToTaxSavingPage(){
        return new pageReference('/apex/ASI_CRM_CN_Payment_Tax_Saving_Page?id=' + PageId);
    }

}