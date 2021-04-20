/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_EditOffPaymentDetailCtrl
 * Description: Apex class for ASI_CRM_CN_EditOffPaymentDetailCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-03       Jeffrey Cheung          Created
 * 2018-11-29		Hector Tsang			Use Last Payment for Off Contract
 ****************************************************************************************************************************/

public class ASI_CRM_CN_EditOffPaymentDetailCtrl {
    public void Calculation() {
        if (!isView) {
            return;
        }
        //Calculate all normal Data
        if (PH.ASI_CRM_System_Debug__c) {
            ASI_CRM_CN_OffPaymentUtilClass.PaymentKPICalculation(PH);
        } else {
            try {
                ASI_CRM_CN_OffPaymentUtilClass.PaymentKPICalculation(PH);
            } catch (Exception e) {
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_EditOffPaymentDetailCtrl.Calculation <br/> in ASI_CRM_CN_Edit_OffPR_DetailsPage Page have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_EditOffPaymentDetailCtrl', 'Calculation function failed! with payment Id: ' + PH.Id + ' Stack: ' + e.getStackTraceString());
            }

        }


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

                    ASI_CRM_CN_OffContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(V0Contract);
                } else {// this contract is V0.0
                    ASI_CRM_CN_OffContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);
                    ASI_CRM_CN_OffContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
                }

                ASI_CRM_CN_OffPaymentUtilClass.ReconstructLastPaymentFIData(PH);
            } catch (Exception e) {
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_EditOffPaymentDetailCtrl.Calculation <br/> in ASI_CRM_CN_ViewHeavyContractPage Page have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_EditOffPaymentDetailCtrl', 'Calculation function failed! with contract Id: ' + ContractSelected.Id);
            }
        }
        //ContractSelected
    }
    public ASI_TH_CRM_Contract__c ContractSelected { set; get; }

    public ASI_TH_CRM_PaymentRequest__c PH { set; get; }
    public String PageId { set; get; }

    public String RowId { set; get; }
    //Line Detail
    public ASI_CRM_Module__c BRSFModule { set; get; } {
        BRSFModule = new ASI_CRM_Module__c();
    }
    //PSF
    public Map<String, interimData> PSF_Item_Map { set; get; } {
        PSF_Item_Map = new Map<String, interimData>();
    }
    public String PSF_Item_MapJSON { set; get; } {
        PSF_Item_MapJSON = '';
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
    public List<ASI_CRM_CN_ContractOffUtilClass.PaymentSummary> PaymentSummaryList { set; get; }{
        PaymentSummaryList = new List<ASI_CRM_CN_ContractOffUtilClass.PaymentSummary>();
    }
    public Boolean cashtype { set; get; }
    public Boolean discounttype { set; get; }
    public Boolean isEdit { set; get; }
    public Boolean isView { set; get; }
    public Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CD { set; get; }{
        Payee_Item_Map_CD = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
    }
    public Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_DISCOUNT { set; get; }{
        Payee_Item_Map_DISCOUNT = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
    }
    public Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CASH { set; get; }{
        Payee_Item_Map_CASH = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
    }

    public Set<Id> outletIds { set; get; }

    public String BRSFActivityCodeId  {get;set;}
    public String PSFActivityCodeId  {get;set;}
    public String DisplayActivityCodeId  {get;set;}


    public ASI_CRM_CN_EditOffPaymentDetailCtrl(ApexPages.StandardController controller) {
        isView = true;
        if (ApexPages.currentPage().getParameters().get('isEdit') == '1') {
            isEdit = true;
            isView = false;
        }

        this.PH = (ASI_TH_CRM_PaymentRequest__c) controller.getRecord();
        PageId = PH.Id;
        List <ASI_TH_CRM_PaymentRequest__c> HeaderList = new List <ASI_TH_CRM_PaymentRequest__c>();

        //Get Header information
        if (PageId != null) {
            HeaderList = [
                SELECT
                    ASI_CRM_CalOtherCostHistoricalPaidAmt__c,
                    ASI_CRM_CN_Adjustment__c,
                    ASI_CRM_Auto_PO_Modification__c,
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
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                    ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c,
                    ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,
                    ASI_TH_CRM_Status__c,
                    ASI_TH_CRM_Total_Amount__c,
                    ASI_CRM_System_Debug__c,
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
                    ASI_CRM_Auto_PO_Modification__c,
                    ASI_CRM_CN_Budget_LE__c,
                    ASI_CRM_CN_Business_License__c,
                    ASI_CRM_CN_Contract_Upload__c,
                    ASI_CRM_CN_Currency__c,
                    ASI_CRM_CN_Description__c,
                    ASI_CRM_CN_Effective_Date__c,
                    ASI_CRM_CN_Exchange_Rate__c,
                    ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                    ASI_CRM_CN_Expected_PSF_Est_Total__c,
                    ASI_CRM_CN_Last_PO_version__c,
                    ASI_CRM_CN_Last_Rejected_Date__c,
                    ASI_CRM_CN_Last_Submitted_Date__c,
                    ASI_CRM_CN_No_of_Months__c,
                    ASI_CRM_CN_Outlet_WS__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.Name,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                    ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                    ASI_CRM_CN_Expected_Display_Est_Total__c,
                    ASI_CRM_CN_PO_End_Date__c,
                    ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                    ASI_CRM_CN_PO_Modification__c,
                    ASI_CRM_CN_PO_No__c,
                    ASI_CRM_CN_PO_Start_Date__c,
                    ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_CN_PP_No__c,
                    ASI_CRM_CN_Reason_without_Budget__c,
                    ASI_CRM_CN_Region__c,
                    ASI_CRM_CN_Source_of_Contract__c,
                    ASI_CRM_CN_Source_Others__c,
                    ASI_CRM_CN_Special_Promotion__c,
                    ASI_CRM_CN_Status__c,
                    ASI_CRM_CN_Total_Contract_Amount__c,
                    ASI_CRM_CN_V0_0_PO_version__c,
                    ASI_CRM_CN_Vol_Budget_LE__c,
                    ASI_CRM_New_FY_PO__c,
                    ASI_CRM_PO_Channel__c,
                    ASI_CRM_PO_City__c,
                    ASI_CRM_PO_City__r.Name,
                    ASI_CRM_PO_Province__c,
                    ASI_CRM_Volume_Option__c,
                    ASI_TH_CRM_Promotion_Type__c,
                    ASI_CRM_CN_Is_Dolphin__c,
                    CreatedDate,
                    Id,
                    LastModifiedDate,
                    Name,
                    RecordTypeId
                FROM ASI_TH_CRM_Contract__c
                WHERE Id = :PH.ASI_TH_CRM_Contract__c
            ];
        }

        init();
    }


    public void init() {
        DisplayVEC = false;
        showCN = UserInfo.getLanguage() == 'zh_CN';

        showReturn = false;
        if ([
            SELECT Assignee.Name, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'ASI_CRM_CN_General_BA' AND AssigneeId = :UserInfo.getUserId()
        ].size() > 0 && PH.ASI_TH_CRM_Status__c == 'Submitted') {
            showReturn = true;
        }
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList = [SELECT Id, Name,ASI_CRM_CN_BRSF_Activity_Code_Default__c,ASI_CRM_PSF_Activity_Code_Default__c,ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_VEC_Activity_Code_Defaul__c , ASI_CRM_CN_Channel__c, ASI_CRM_CN_Other_Cost_Payment_Request__c  FROM ASI_CRM_Contract_Cost_Setting__c WHERE ASI_CRM_CN_Promotion_Type__c = 'TOT/MOT Contract' ];
        for(ASI_CRM_Contract_Cost_Setting__c ccs:ContractCostSettingList){
            if (ccs.ASI_CRM_CN_BRSF_Activity_Code_Default__c) {
                BRSFActivityCodeId = ccs.ASI_CRM_CN_Activity_Code__c;
            }
            if (ccs.ASI_CRM_PSF_Activity_Code_Default__c) {
                PSFActivityCodeId = ccs.ASI_CRM_CN_Activity_Code__c;
            }
            if (ccs.ASI_CRM_VEC_Activity_Code_Defaul__c && ccs.ASI_CRM_CN_Channel__c == ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.Name) {
                DisplayActivityCodeId = ccs.ASI_CRM_CN_Activity_Code__c;
            }

        }

        outletIds = getOutletIds(PH.ASI_TH_CRM_Contract__c);

        List<AggregateResult> otherCostHistoricalPaidAmount = new List<AggregateResult>();
        if (PH.ASI_CRM_CalOtherCostHistoricalPaidAmt__c) {
            otherCostHistoricalPaidAmount = ASI_CRM_CN_OffPaymentUtilClass.calculateOtherCostHistoricalPaidAmount(PH.Id, PH.ASI_TH_CRM_Contract__c);
            System.debug(otherCostHistoricalPaidAmount);
            PH.ASI_CRM_CalOtherCostHistoricalPaidAmt__c = false;
        }


        //Module : Map <Id, ASI_CRM_Module__c>
        Map<String, ASI_CRM_Module__c> ModuleMap = new Map<String, ASI_CRM_Module__c>();
        Set<Id> ParentModuleIdSet = new Set<Id>();

        for (ASI_CRM_Module__c Module : [
            SELECT
                ASI_CRM_Actual_Payment__c,
                ASI_CRM_Adjustment__c,
                ASI_CRM_Application_Payment_Amount__c,
                ASI_CRM_CN_CTD_Minimal_Achievement__c,
                ASI_CRM_CN_Contract_Volume_Base__c,
                ASI_CRM_CN_KPI_Base__c,
                ASI_CRM_CN_Total_Markup__c,
                ASI_CRM_CN_Minimal_Achievement__c,
                ASI_CRM_CN_Is_Capped__c,
                ASI_CRM_CN_Criteria__c,
                ASI_CRM_Completion_Ratio__c,
                ASI_CRM_End_Date__c,
                ASI_CRM_Historical_Paid_Amount__c,
                ASI_CRM_Line_Type__c,
                ASI_CRM_Methodology__c,
                ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                ASI_CRM_Methodology__r.Name,
                ASI_CRM_Other_Comments__c,
                ASI_CRM_Overpayment_Reason__c,
                ASI_CRM_Parent_Module__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_CN_Criteria__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c,
                ASI_CRM_PSF_Overpayment_Reason__c,
                ASI_CRM_Created_PO_Version__c,
                ASI_CRM_Reason_NCD_Volume_Base__c,
                ASI_CRM_Reason_Not_NCD_Methodology__c,
                ASI_CRM_Remark__c,
                ASI_CRM_Suggested_Payable_Amount__c,
                ASI_CRM_Unit__c,
                ASI_CRM_VEC_Overpayment_Reason__c,
                ASI_CRM_Volume_Base__c,
                Id
            FROM ASI_CRM_Module__c
            WHERE ASI_CRM_Payment_Request__c = :PageId
        ]) {
            if (Module.ASI_CRM_Line_Type__c == 'BRSF') {
                BRSFModule = Module;
            }
            if (Module.ASI_CRM_Line_Type__c == 'PSF') {
                PSF_Item_Map.put(Module.ASI_CRM_Parent_Module__c, new interimData(Module));
            }
            if (Module.ASI_CRM_Line_Type__c == 'Display') {
                // Dolphin合同不显示Display块，Add By Zhonghui, 2020-09-24
                if (!ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
                    DisplayVEC = true;
                }
                DisplayItemMap.put(Module.ASI_CRM_Parent_Module__c, new interimData(Module));
            }
            ModuleMap.put(Module.Id, Module);
            if (Module.ASI_CRM_Parent_Module__c != null) {
                ParentModuleIdSet.add(Module.ASI_CRM_Parent_Module__c);
            }
        }
        Map<String, Decimal> HistoricalModuleMap = new Map<String, Decimal>();
        if (ParentModuleIdSet.size() > 0) {
            HistoricalModuleList = ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleIdSet, PH.Id);
            HistoricalModuleMap = ASI_CRM_CN_ContractOffUtilClass.GetHistoricalModuleAmount(HistoricalModuleList);

        }

        for (ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : [
            SELECT
                ASI_CRM_Brand_Code__c,
                ASI_CRM_CN_AC_Code__c,
                ASI_CRM_CN_Actual_Vol__c,
                ASI_CRM_CN_Allow_Changing_Incentive__c,
                ASI_CRM_CN_Bottle_Collected__c,
                ASI_CRM_CN_Collection_Rate__c,
                ASI_CRM_CN_Comment__c,
                ASI_CRM_CN_Completion_Rate__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Total_Dummy__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Est_Total_Dummy__c,
                ASI_CRM_CN_Rebate__c,
                ASI_CRM_CN_Rebate_Percent__c,
                ASI_CRM_CN_Target__c,
                ASI_CRM_Historical_Paid_Amount__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_std_Btl__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_std_Btl__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Contract_Amount__c,
                ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Estimate_Amount__c,
                ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Estimate_Amount_Rate__c,
                ASI_CRM_CN_Contract_Cost__r.ASI_CRM_Contract_Terms__c,
                ASI_CRM_CN_Expense_Type__c,
                ASI_CRM_CN_Incentive_BT__c,
                ASI_CRM_CN_Payable_Vol__c,
                ASI_CRM_CN_Remaining_Amount__c,
                ASI_CRM_CN_Standard__c,
                ASI_CRM_CN_Sub_Brand__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Suggested_Amount__c,
                ASI_CRM_CN_Total_Payable__c,
                ASI_CRM_CNY_Est__c,
                ASI_CRM_CTD_Actual_Purchase_Value__c,
                ASI_CRM_CTD_Actual_Purchase_Value_Ref__c,
                ASI_CRM_CTD_Actual_Vol__c,
                ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,
                ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,
                ASI_CRM_CTD_BC_Martell_CR12__c,
                ASI_CRM_CTD_BC_Pure_CR12__c,
                ASI_CRM_CTD_Cap_Collection_Vol__c,
                ASI_CRM_Key_Sub_Brand__c,
                ASI_CRM_Line_Name__c,
                ASI_CRM_MAF_Est__c,
                ASI_CRM_Max_Incentive__c,
                ASI_CRM_Module__c,
                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                ASI_CRM_Non_Contract_Line__c,
                ASI_CRM_Other_Est__c,
                ASI_CRM_Over_Incentive__c,
                ASI_CRM_Product_Category__c,
                ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_Product_Category__r.Name,
                ASI_CRM_Sub_Brand_Grade__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_System_Payable_Vol_Std_Bottle__c,
                ASI_CRM_V0_0_Full_Contract_Target__c,
                ASI_CRM_Volume_Base__c,
                ASI_TH_CRM_Amount__c,
                ASI_TH_CRM_Payment_Request__c,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                ASI_CRM_Application_Payment_Amount__c,
                Id,
                RecordType.DeveloperName,
                RecordTypeId
            FROM ASI_TH_CRM_PaymentRequestLineItem__c
            WHERE ASI_TH_CRM_Payment_Request__c = :PH.Id
            ORDER BY ASI_CRM_CN_Allow_Changing_Incentive__c DESC
        ]) {
            paymentLine.ASI_CRM_CN_Payable_Vol__c = paymentLine.ASI_CRM_CN_Payable_Vol__c == null? 0 : paymentLine.ASI_CRM_CN_Payable_Vol__c;
            paymentLine.ASI_CRM_CN_Total_Payable__c = paymentLine.ASI_CRM_CN_Total_Payable__c == null? 0 : paymentLine.ASI_CRM_CN_Total_Payable__c;
            paymentLine.ASI_CRM_CN_Suggested_Amount__c = paymentLine.ASI_CRM_CN_Suggested_Amount__c == null? 1 : paymentLine.ASI_CRM_CN_Suggested_Amount__c;

            if (paymentLine.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_Other') {
                for (AggregateResult aggregateResult : otherCostHistoricalPaidAmount) {
                    if (paymentLine.ASI_CRM_CN_Expense_Type__c == aggregateResult.get('ASI_CRM_CN_Expense_Type__c')) {
                        paymentLine.ASI_CRM_Historical_Paid_Amount__c = (Decimal) aggregateResult.get('actualPaymentAmountSum');
                    }
                }
                OtherPaymentLineList.add(paymentLine);
            } else if (paymentLine.ASI_CRM_Module__c != null) {
                if (paymentLine.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_PSF' && PSF_Item_Map.containsKey(paymentLine.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c)) {

                    String Mapkeystr = paymentLine.Id;
                    if (PSF_Item_Map.get(paymentLine.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                        Mapkeystr = NameSortingASC(paymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c) + paymentLine.ASI_CRM_CN_Sub_Brand__c;
                        if (paymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c) {
                            Mapkeystr = '9' + Mapkeystr;
                        }
                        if (paymentLine.ASI_CRM_Key_Sub_Brand__c) {
                            Mapkeystr = '0' + Mapkeystr;
                        }


                        //PSFMax
                        if (paymentLine.ASI_CRM_CN_Incentive_BT__c != null && paymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c) {
                            paymentLine.ASI_CRM_Over_Incentive__c = paymentLine.ASI_CRM_Max_Incentive__c < paymentLine.ASI_CRM_CN_Incentive_BT__c;
                        }

                        if (paymentLine.ASI_CRM_Sub_Brand_Grade__c != null) {
                            paymentLine.ASI_CRM_Line_Name__c = paymentLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c != null? paymentLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c : paymentLine.ASI_CRM_Sub_Brand_Grade__r.Name;
                        } else {
                            paymentLine.ASI_CRM_Line_Name__c = paymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null? paymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c : paymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        }


                    }
                    if (PSF_Item_Map.get(paymentLine.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c == 'By Category') {
                        Mapkeystr = NameSortingASC(paymentLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) + paymentLine.ASI_CRM_Product_Category__c;
                        if (paymentLine.ASI_CRM_CN_Incentive_BT__c == null || paymentLine.ASI_CRM_CN_Incentive_BT__c == 0) {
                            Mapkeystr = '9' + Mapkeystr;
                        }
                        paymentLine.ASI_CRM_Line_Name__c = paymentLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? paymentLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : paymentLine.ASI_CRM_Product_Category__r.Name;
                    }


                    //                    Boolean AllowCalculation=false;
                    //                    if(payline.ASI_CRM_Non_Contract_Line__c ){
                    //                        if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    //                            if(payline.ASI_CRM_CN_Payable_Vol__c!=0){
                    //                                AllowCalculation=true;
                    //                            }
                    //                        }else{
                    //                            if(payline.ASI_CRM_CN_Total_Payable__c!=0){
                    //                                AllowCalculation=true;
                    //                            }
                    //                        }
                    //                    }
                    //                    PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                    //
                    //                    if(!payline.ASI_CRM_Non_Contract_Line__c || AllowCalculation){
                    //                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Btl+=payline.ASI_CRM_CN_Actual_Vol__c!=null?payline.ASI_CRM_CN_Actual_Vol__c:0;
                    //                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Completion+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                    //                    }
                    //
                    PSF_Item_Map.get(paymentLine.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).DetailLineMap.put(Mapkeystr, paymentLine);
                    //                    PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).VolumeTarget +=payline.ASI_CRM_V0_0_Full_Contract_Target__c!=null?payline.ASI_CRM_V0_0_Full_Contract_Target__c:0;

                } else if (paymentLine.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_Display') {
                    DisplayItemMap.get(paymentLine.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).DetailLineMap.put(paymentLine.Id, paymentLine);
                }


            }
        }

        calculateInterimDataTotal(PSF_Item_Map);
        calculateInterimDataTotal(DisplayItemMap);

        PSF_Item_MapJSON = JSON.serialize(PSF_Item_Map);
        System.debug('PSF_Item_MapJSON =='+ PSF_Item_MapJSON);
        List<ASI_TH_CRM_PaymentRequest__c> Payment000List = [
            SELECT Id,Name,ASI_CRM_CN_Total_PSF_Amount__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Total_VEC_Amount__c
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c AND Name LIKE '%000%'
        ];
        // Decimal PaidAmount000=0;

        Decimal BRSFPaidAmount000 = 0;
        Decimal PSFPaidAmount000 = 0;
        Decimal VECPaidAmount000 = 0;


        if (Payment000List.size() > 0) {
            for (ASI_TH_CRM_PaymentRequest__c Paymenttemp : Payment000List) {
                if (Paymenttemp.Name.length() > 3) {
                    if (Paymenttemp.Name.substring(Paymenttemp.Name.length() - 3, Paymenttemp.Name.length()) == '000') {
                        BRSFPaidAmount000 += Paymenttemp.ASI_CRM_CN_Total_BRSF_Amount__c != null? Paymenttemp.ASI_CRM_CN_Total_BRSF_Amount__c : 0;
                        PSFPaidAmount000 += Paymenttemp.ASI_CRM_CN_Total_PSF_Amount__c != null? Paymenttemp.ASI_CRM_CN_Total_PSF_Amount__c : 0;
                        VECPaidAmount000 += Paymenttemp.ASI_CRM_CN_Total_VEC_Amount__c != null? Paymenttemp.ASI_CRM_CN_Total_VEC_Amount__c : 0;
                    }
                }
            }
        }
        Integer coun = 0;
        for (interimData interimData : PSF_Item_Map.values()) {
            if (interimData.Module.ASI_CRM_Parent_Module__c != null && HistoricalModuleMap.containsKey(interimData.Module.ASI_CRM_Parent_Module__c)) {
                interimData.Module.ASI_CRM_Historical_Paid_Amount__c = HistoricalModuleMap.get(interimData.Module.ASI_CRM_Parent_Module__c);
            }

        }
        for (interimData interimData : DisplayItemMap.values()) {
            if (interimData.Module.ASI_CRM_Parent_Module__c != null && HistoricalModuleMap.containsKey(interimData.Module.ASI_CRM_Parent_Module__c)) {
                interimData.Module.ASI_CRM_Historical_Paid_Amount__c = HistoricalModuleMap.get(interimData.Module.ASI_CRM_Parent_Module__c);
            }
        }


        if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Cash') || PH.ASI_CRM_CN_Payment_Type__c.contains('cash')))
            cashtype = true; else
            cashtype = false;

        if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Discount') || PH.ASI_CRM_CN_Payment_Type__c.contains('discount')))
            discounttype = true; else
            discounttype = false;

        Integer indexCASH = 0;
        Integer indexDISCOUNT = 0;
        Integer indexCD = 0;

        List<ASI_CRM_CN_PH_Payee_Line_Item__c> LPHPayeeAll = [
            SELECT ASI_CRM_CN_Amount__c, ASI_CRM_CN_Cash_Discount__c, ASI_CRM_CN_Cash_Amount__c, ASI_CRM_CN_Discount_Amount__c,
                ASI_CRM_CN_Payment_Request__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_T1__r.Name, ASI_CRM_CN_Payee_T1__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T1__r.Name,
                ASI_CRM_CN_Reason__c, ASI_CRM_CN_Payee_T2__r.Name, ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Comfirm_Receipt__c,
                ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name, RecordTypeId, ASI_CRM_CN_Instruction_Sent_Time__c
            FROM ASI_CRM_CN_PH_Payee_Line_Item__c
            WHERE ASI_CRM_CN_Payment_Request__c = :PH.Id AND
            (ASI_CRM_CN_Type__c = 'Cash' OR ASI_CRM_CN_Type__c = 'Discount' OR ASI_CRM_CN_Type__c = 'Others' OR ASI_CRM_CN_Type__c = 'CD')
        ];

        for (ASI_CRM_CN_PH_Payee_Line_Item__c payee : LPHPayeeAll) {
            if (payee.ASI_CRM_CN_Type__c == 'Cash') {
                Payee_Item_Map_CASH.put(indexCASH++, payee);
            } else if (payee.ASI_CRM_CN_Type__c == 'Discount') {
                Payee_Item_Map_DISCOUNT.put(indexDISCOUNT++, payee);
            } else if (payee.ASI_CRM_CN_Type__c == 'Others' || payee.ASI_CRM_CN_Type__c == 'CD') {
                Payee_Item_Map_CD.put(indexCD++, payee);
            }
        }

        PaymentSummaryList = ASI_CRM_CN_ContractOffUtilClass.PaymentSummaryTable(PH, ContractSelected);

    }

    //Go To Check Point Page
    public PageReference GoToCheckPoint() {
        Msg = ' ';
        UpsertPermission = true;
        Decimal totalPaymentAmount = 0;

        //Last Payment checking
        for (ASI_TH_CRM_PaymentRequest__c paymentTemp : ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {
            if (paymentTemp.ASI_CRM_CN_Last_Payment__c == true && paymentTemp.ASI_TH_CRM_Status__c != 'Draft') {
                ErrorHandling(Label.ASI_CRM_CN_ErrorMsg_MakePayment + paymentTemp.Name);
            }
        }


        //checking payment summary
        List<ASI_CRM_CN_ContractOffUtilClass.PaymentSummary> PaymentSummaryList = new List<ASI_CRM_CN_ContractOffUtilClass.PaymentSummary> ();
        PaymentSummaryList = ASI_CRM_CN_ContractOffUtilClass.PaymentSummaryTable(PH, ContractSelected);
        for (ASI_CRM_CN_ContractOffUtilClass.PaymentSummary SummaryData : PaymentSummaryList) {
            totalPaymentAmount += SummaryData.PaymentRequestAmount;
            Decimal PORemainAmt = SummaryData.POEstimatedAmount - SummaryData.PaidAmount;
            if (SummaryData.PaymentRequestAmount > PORemainAmt + 1) {
                ErrorHandling(SummaryData.Name + Label.ASI_CRM_CN_Account_payment_amount_Checking);
            }
        }


        Decimal payeeAmountSum = 0;
        //checking payee
        List<ASI_CRM_CN_PH_Payee_Line_Item__c> LPHPayeeAll = [
            SELECT ASI_CRM_CN_Amount__c
            FROM ASI_CRM_CN_PH_Payee_Line_Item__c
            WHERE ASI_CRM_CN_Payment_Request__c = :PH.Id
            AND ASI_CRM_CN_Type__c IN ('Cash', 'Discount', 'Others', 'CD')
        ];

        for (ASI_CRM_CN_PH_Payee_Line_Item__c PayeeLine : LPHPayeeAll) {
            payeeAmountSum += PayeeLine.ASI_CRM_CN_Amount__c != null? PayeeLine.ASI_CRM_CN_Amount__c : 0;
        }


        List<ASI_Attachment__c> AttachmentList = new List<ASI_Attachment__c>();
        if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null) {
            AttachmentList = [
                SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
                FROM ASI_Attachment__c
                WHERE ASI_CRM_Contract__c = :ContractSelected.Id OR ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c
            ];
        } else {
            //Geting HistoricalV0.0 and VFinal Data
            AttachmentList = [
                SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
                FROM ASI_Attachment__c
                WHERE ASI_CRM_Contract__c = :ContractSelected.Id
            ];

        }


        Decimal FixedCostTotal = 0;
        Decimal VariableCostTotal = 0;
        if (AttachmentList.size() > 0) {
            Map<String, Decimal> PaymentKPIMap = new Map<String, Decimal>();

            for (ASI_Attachment__c att : AttachmentList) {
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;', '"');

                //General Payment Info
                if (att.ASI_CRM_Type__c == 'Payment Data' && att.ASI_CRM_Contract__c == ContractSelected.Id) {

                    PaymentKPIMap = (Map<String, Decimal>) System.JSON.deserialize(JsonString, Map<String, Decimal>.class);
                    if (PaymentKPIMap.containsKey('FixedCostTotal')) {
                        FixedCostTotal = PaymentKPIMap.get('FixedCostTotal');
                    }
                    if (PaymentKPIMap.containsKey('VariableCostTotal')) {
                        VariableCostTotal = PaymentKPIMap.get('VariableCostTotal');
                    }

                }

            }

        }

        //        Decimal TotalAmount = (FixedCostTotal + VariableCostTotal);
        Decimal TotalAmount = totalPaymentAmount;
        if (Math.abs(payeeAmountSum - TotalAmount) > 0.1) {
            String tempStr = Label.ASI_CRM_CN_Payment_total_amount_no_consistent;
            Decimal payee_amount = payeeAmountSum.setScale(2, RoundingMode.HALF_UP);
            List<String> fillers = new String[]{
                payee_amount.format(), TotalAmount.setScale(2, RoundingMode.HALF_UP).format()
            };
            ErrorHandling(String.format(tempStr, fillers));
        }


        if (TotalAmount > PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c) {
            String tempStr = Label.ASI_CRM_Payee_Amount_checking;
            List<String> fillers = new String[]{
                TotalAmount.format(), PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format()
            };
            ErrorHandling(String.format(tempStr, fillers));
        }


        if (UpsertPermission) {
            PageReference redirect = new PageReference('/apex/ASI_CRM_CN_OffPaymentCheckPage?id=' + PH.Id + '&Type=SubmitApproval');
            redirect.getParameters().put('id', PageId);
            redirect.setRedirect(true);
            return redirect;
        } else {
            return null;
        }


    }

    public PageReference GoEditDetailPage() {
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_Edit_OffPR_DetailsPage');
        redirect.getParameters().put('id', PageId);
        redirect.getParameters().put('isEdit', '1');
        redirect.setRedirect(true);
        return redirect;
    }


    public PageReference GoEditPayee() {
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_HeavyEditPaymentPayeePage'); // ASI_CRM_CN_EditPaymentPayeePage
        redirect.getParameters().put('id', PageId);
        redirect.setRedirect(true);
        return redirect;
    }


    public PageReference GoEditHeader() {
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditHeavyPayment_Header_Page');
        redirect.getParameters().put('id', PageId);
        redirect.setRedirect(true);
        return redirect;
    }

    public PageReference GoSubmitApproval() {
        //ASI_CN_SubmitApprovalController
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(PH.Id);
        req1.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result = Approval.process(req1);
        return new PageReference('/' + PageId);


    }
    public PageReference AutoPOModification() {
        if (PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c == 'Final') {
            PH.ASI_CRM_Auto_PO_Modification__c = true;
            update PH;
            ASI_CRM_CN_OffPaymentUtilClass.lastPaymentAutoPOModification(ContractSelected, PH.ASI_CRM_Volume_Cut_Off_Date__c);
            return new PageReference('/' + PageId);
        } else {
            UpsertPermission = false;
            Msg = '我们发现改合同不是	已批准 状态，无法继续执行PO自动修改。We found that contract is not in Final Status, cannot process Auto-PO Modi.';
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

    //****************Generate Payment Line *******************************************************************************************
    public Decimal calculateCTDMinimalAchievement(Date startDate, Date endDate, Date currentDate, Decimal minimalAchievement) {
        // Null prevention
        minimalAchievement = minimalAchievement == null? 0 : minimalAchievement;

        // Because endDate and currentDate is always last day of month, so we add 1 more to day to make monthsBetween() calculate correctly
        Integer totalMonths = startDate.monthsBetween(endDate.addDays(1));
        Integer currentMonths = startDate.monthsBetween(currentDate.addDays(1));

        return (Decimal) currentMonths / totalMonths * minimalAchievement;
    }

    /**
     * Calculate totals for all interimData in Map. It is required because view page depends on them.
     *
     * @param dataMap
     */
    public void calculateInterimDataTotal(Map<String, interimData> dataMap) {
        for (interimData data : dataMap.values()) {
            data = calculateInterimDataTotal(data);
        }
    }

    public interimData calculateInterimDataTotal(interimData data) {
        data.TotalCTDIntakeStdBottle = 0;
        data.TotalCTDIntakeCR12 = 0;
        data.TotalCTDPayableAmount = 0;
        data.TotalCTDPurchaseValue = 0;
        data.TotalCTDPurchaseValueRef = 0;
        data.TotalCompletionRatio = 0;
        data.TotalContractTotalAmount = 0;
        data.TotalContractTargetCR12 = 0;
        data.TotalEstimateTargetCR12 = 0;
        data.TotalContractTargetStdBottle = 0;
        data.TotalContractTargetValue = 0;
        data.TotalEstimateTargetValue = 0;

        for (ASI_TH_CRM_PaymentRequestLineItem__c line : data.DetailLineMap.values()) {
            data.TotalCTDIntakeStdBottle += line.ASI_CRM_CN_Actual_Vol__c == null? 0 : line.ASI_CRM_CN_Actual_Vol__c;
            data.TotalCTDIntakeCR12 += line.ASI_CRM_CTD_Actual_Vol__c;
            data.TotalCTDPurchaseValue += line.ASI_CRM_CTD_Actual_Purchase_Value__c == null? 0 : line.ASI_CRM_CTD_Actual_Purchase_Value__c;
            data.TotalCTDPurchaseValueRef += line.ASI_CRM_CTD_Actual_Purchase_Value_Ref__c == null? 0 : line.ASI_CRM_CTD_Actual_Purchase_Value_Ref__c;
            data.TotalCTDPayableAmount += line.ASI_CRM_CN_Total_Payable__c;
            data.TotalContractTotalAmount += line.ASI_CRM_V0_0_Full_Contract_Target__c;
            data.TotalContractTargetCR12 += line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null? 0 : line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
            data.TotalEstimateTargetCR12 += line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null? 0 : line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
            data.TotalContractTargetStdBottle += line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_std_Btl__c == null? 0 : line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_std_Btl__c;
            data.TotalContractTargetValue += line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c == null? 0 : line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c;
            data.TotalEstimateTargetValue += line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c == null? 0 : line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c;
            data.ValueTarget = line.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c;
            data.CTDPurchaseValue = line.ASI_CRM_CTD_Actual_Purchase_Value__c;

        }

        String KPIBase = data.Module.ASI_CRM_CN_KPI_Base__c;
        String unit = data.Module.ASI_CRM_Unit__c;

        if (KPIBase == 'Volume base') {
            if (unit == 'Std. Btl.' || unit == 'CR12 Extra Eqv.' || unit == 'RMB' || unit == null) {
                Decimal targetCR12 = data.Module.ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c == '0.0'? data.TotalContractTargetCR12 : data.TotalEstimateTargetCR12;

                data.TotalCompletionRatio = targetCR12 != 0? data.TotalCTDIntakeCR12 / targetCR12 * 100 : 0;
            }
        }
        if (KPIBase == 'Value base') {
            Decimal targetValue = data.Module.ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c == '0.0'? data.TotalContractTargetValue : data.TotalEstimateTargetValue;
            data.TotalCompletionRatio = targetValue != 0? data.TotalCTDPurchaseValue / targetValue * 100 : 0;
        }

        return data;
    }

    public void GeneratePSFVol() {
        UpsertPermission = true;
        Msg = '';


        String param_Id = ApexPages.currentPage().getParameters().get('PARAMID');
        if (!PSF_Item_Map.containsKey(param_Id)) {
            return;
        }

        String PSFItemMapJSON = ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON');
        Map<String, interimData> PSFItemMapWithUpdatedLines = (Map<String, interimData>) JSON.deserialize(PSFItemMapJSON, Map<String, interimData>.class);
        for (String key : PSFItemMapWithUpdatedLines.keySet()) {
            interimData newInterimData = PSFItemMapWithUpdatedLines.get(key);
            interimData oldInterimData = PSF_Item_Map.get(key);
            // Skip copying others module because it use standard way not JS way
            if (oldInterimData.Module.ASI_CRM_Methodology__r.Name == 'Others') {
                continue;
            }

            oldInterimData.DetailLineMap = newInterimData.DetailLineMap;

            PSF_Item_Map.put(key, oldInterimData);
        }


        interimData interimData = PSF_Item_Map.get(param_Id);
        if (VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, interimData.Module.ASI_CRM_Parent_Module__c,
            'For PSF (' + interimData.Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c + '), we meet following error in End Date: <br/>')) {

            // 店家数很多时，需要运行batch汇总逻辑
            if (outletIds.size() > ASI_CRM_CN_OffContractUtilitiesClass.outletThreshold()) {
                ASI_TH_CRM_Contract__c lastestContract = [SELECT Id, ASI_CRM_CN_Aggregation_Batch_CTD_Date__c, ASI_CRM_CN_Is_Aggregation_Batch_Run__c 
                                                          FROM ASI_TH_CRM_Contract__c 
                                                          WHERE Id = :ContractSelected.Id];
                if (lastestContract.ASI_CRM_CN_Is_Aggregation_Batch_Run__c) {
                    ErrorHandling('数据汇总Job正在运行，请耐心等待再进入页面操作');
                    return;
                } else if (lastestContract.ASI_CRM_CN_Aggregation_Batch_CTD_Date__c ==null 
                            || lastestContract.ASI_CRM_CN_Aggregation_Batch_CTD_Date__c < interimData.Module.ASI_CRM_End_Date__c) {
                    Database.executeBatch(new ASI_CRM_CN_OffVolumeDeleteJob(new Set<Id> {lastestContract.Id}), 2000);
                    ErrorHandling('因数据汇总量大，需要进行数据汇总JOB，请等候大约五分钟再进入页面操作');
                    return;
                }
            }
            interimData.Module.ASI_CRM_CN_CTD_Minimal_Achievement__c = calculateCTDMinimalAchievement(PH.ASI_CRM_CN_PO_Start_Date__c, PH.ASI_CRM_CN_PO_End_Date__c, interimData.Module.ASI_CRM_End_Date__c, interimData.Module.ASI_CRM_CN_Minimal_Achievement__c);

            //remove existing line in PSF
            for (String key : interimData.DetailLineMap.keySet()) {
                ASI_TH_CRM_PaymentRequestLineItem__c delTarget = interimData.DetailLineMap.get(key);
                if (delTarget.Id != null) {
                    PaymentLineDeleteList.add(delTarget);
                }
                interimData.DetailLineMap.remove(key);
            }
            System.debug('*** interimData.Module: ' + JSON.serializePretty(interimData.Module) + '');
            //BRSF List from contract
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            //HistoricalPaymentLine
            List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList = new List<ASI_TH_CRM_PaymentRequestLineItem__c> ();
            Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();

            /* String V0_0_POId=PH.ASI_TH_CRM_Contract__c ;
             if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
                 V0_0_POId=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
             }*/

            if (interimData.Module.ASI_CRM_Parent_Module__c != null) {
                PSFList = [
                    SELECT
                        ASI_CRM_CN_Activity_Code__c,
                        ASI_CRM_CN_Contract__c,
                        ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,
                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                        ASI_CRM_CN_Contract_Monthly_Qty__c,
                        ASI_CRM_CN_Contract_Purchase_Value__c,
                        ASI_CRM_CN_Estimate_Purchase_Value__c,
                        ASI_CRM_CN_Contract_Total__c,
                        ASI_CRM_CN_Contract_Total_Dummy__c,
                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                        ASI_CRM_CN_Est_Monthly_Qty__c,
                        ASI_CRM_CN_Est_Total__c,
                        ASI_CRM_CN_Est_Total_Dummy__c,
                        ASI_CRM_CN_Max_Purchase_Target__c,
                        ASI_CRM_CN_Min_Purchase_Target__c,
                        ASI_CRM_CN_Rebate__c,
                        ASI_CRM_CN_Rebate_Percent__c,
                        ASI_CRM_CN_Sub_Brand__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                        ASI_CRM_CN_Sub_Brand__r.Name,
                        ASI_CRM_CN_Target__c,
                        ASI_CRM_Contract_Monthly_Volume_CR12__c,
                        ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c,
                        ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c,
                        ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                        ASI_CRM_Contract_Total_QTY_std_Btl__c,
                        ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c,
                        ASI_CRM_Est_Monthly_Volume_CR12__c,
                        ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c,
                        ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                        ASI_CRM_Est_Total_QTY_std_Btl__c,
                        ASI_CRM_Key_Sub_brand__c,
                        ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Product_Category__c,
                        ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                        ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                        ASI_CRM_Product_Category__r.Name,
                        ASI_CRM_Sub_Brand_Grade__c,
                        ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                        Id
                    FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                    WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c
                    AND ASI_CRM_Module__c = :interimData.Module.ASI_CRM_Parent_Module__c
                    AND ASI_CRM_Type__c = 'PSF'
                    AND ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != '999'
                    ORDER BY Id
                ];

                // Get historical payment line. Only payment lines that point to the same contract module
                HistoricalPaymentList = [
                    SELECT Id,ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Sub_Brand__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Product_Category__c,ASI_CRM_CN_Incentive_BT__c,ASI_CRM_CN_Rebate_Percent__c
                    FROM ASI_TH_CRM_PaymentRequestLineItem__c
                    WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                    AND ASI_CRM_Module__r.ASI_CRM_Parent_Module__c = :interimData.Module.ASI_CRM_Parent_Module__c
                    AND ASI_TH_CRM_Payment_Request__c != :PH.Id AND RecordType.DeveloperName = :'ASI_CRM_CN_Payment_Request_Detail_PSF'
                    ORDER BY ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_Version__c
                ];


            }


            //Getting Activity Code base on the 'Contract Cost Setting' table
            List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList = [
                SELECT Id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c,ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_CN_Other_Cost_Payment_Request__c
                FROM ASI_CRM_Contract_Cost_Setting__c
                WHERE ASI_CRM_CN_Promotion_Type__c = :PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
                AND ASI_CRM_PSF_Activity_Code_Default__c = TRUE
            ];
            Id ActivityCode;
            if (LContractCostSettingList != null && LContractCostSettingList.size() == 1) {
                ActivityCode = LContractCostSettingList[0].ASI_CRM_CN_Activity_Code__c;
            }

            Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            Set<Id> subBrandIds = new Set<Id>();
            Map<Id, Decimal> maxIncentiveBySubBrandId = new Map<Id, Decimal>();
            Map<Id, Decimal> maxRebatePercentBySubBrandId = new Map<Id, Decimal>();
            //Grouping by Sub-Brand : Map<Sub-Brand Id, ASI_TH_CRM_PaymentRequestLineItem__c>
            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {

                for (ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : HistoricalPaymentList) {
                    HistoricalPaymentMap.put(paymentLine.ASI_CRM_CN_Sub_Brand__c, paymentLine);
                }

                paymentLineMap = SubBrandGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, PSFList, interimData.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                subBrandIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_TH_CRM_PaymentRequestLineItem__c.ASI_CRM_CN_Sub_Brand__c, paymentLineMap.values());
                for (ASI_MFM_Sub_brand__c sb : [
                    SELECT Id, (
                        SELECT Id, ASI_CRM_CN_Incentive_for_PSF__c,ASI_CRM_CN_Max_Incentive_for_PSF__c,ASI_CRM_CN_Rebate_Percent__c,ASI_CRM_CN_Max_Rebate_Percent__c
                        FROM ASI_CRM_CR12_Factors__r
                        WHERE ASI_CRM_CN_Region__c = :ContractSelected.ASI_CRM_CN_Region__c AND ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c
                    )
                    FROM ASI_MFM_Sub_brand__c
                    WHERE RecordType.DeveloperName LIKE '%CN%' AND Id IN:subBrandIds
                ]) {
                    if (sb.ASI_CRM_CR12_Factors__r.isEmpty()) {
                        maxIncentiveBySubBrandId.put(sb.Id, 99999999);
                        maxRebatePercentBySubBrandId.put(sb.Id, 99999999);
                    } else {
                        for (ASI_CRM_Sub_Brand_Line__c subBrandLine : sb.ASI_CRM_CR12_Factors__r) {
                            maxIncentiveBySubBrandId.put(sb.Id, subBrandLine.ASI_CRM_CN_Max_Incentive_for_PSF__c);
                            maxRebatePercentBySubBrandId.put(sb.Id, subBrandLine.ASI_CRM_CN_Max_Rebate_Percent__c);
                        }
                    }
                }

            }

            //Grouping by Product Category : Map<Product Category Id, ASI_TH_CRM_PaymentRequestLineItem__c>
            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Category') {
                paymentLineMap = ProductCategoryGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, PSFList, interimData.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
            }

            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Total' || interimData.Module.ASI_CRM_Methodology__r.Name == 'Others') {
                paymentLineMap = ByTotalPaymentLineCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, PSFList, interimData.Module);
            }

            Decimal largestMinTarget = 0;
            for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : paymentLineMap.values()) {
                try {
                    largestMinTarget = Math.max(largestMinTarget, lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c);
                } catch (Exception e) {
                    continue;
                }
            }


            for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : paymentLineMap.values()) {
                if (lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null) {
                    //If the outlet sells the sub-brand not listed in the linked PO, the sub-brand item will be added by retrieving from the historical payment, the Incentive (Per Bottle) will be read-only.
                    // Has historical payment
                    if (HistoricalPaymentMap.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
                        lineItem.ASI_CRM_CN_Incentive_BT__c = HistoricalPaymentMap.get(lineItem.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BT__c;
                        lineItem.ASI_CRM_CN_Rebate_Percent__c = HistoricalPaymentMap.get(lineItem.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Rebate_Percent__c;
                        lineItem.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                    } else {//Not in HistoricalPaymentMap
                        lineItem.ASI_CRM_CN_Incentive_BT__c = 0;
                        lineItem.ASI_CRM_CN_Rebate_Percent__c = 0;
                        lineItem.ASI_CRM_CN_Allow_Changing_Incentive__c = true;
                    }

                    // Set max incentive/ max rebate%
                    if (interimData.Module.ASI_CRM_Methodology__r.Name == 'Rebate%') {
                        lineItem.ASI_CRM_Max_Incentive__c = maxRebatePercentBySubBrandId.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)? maxRebatePercentBySubBrandId.get(lineItem.ASI_CRM_CN_Sub_Brand__c) : 99999999;
                    } else {
                        lineItem.ASI_CRM_Max_Incentive__c = maxIncentiveBySubBrandId.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)? maxIncentiveBySubBrandId.get(lineItem.ASI_CRM_CN_Sub_Brand__c) : 99999999;
                    }

                } else {
                    lineItem.ASI_CRM_CN_Rebate__c = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate__c;
                    lineItem.ASI_CRM_CN_Target__c = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Target__c;
                    lineItem.ASI_CRM_CN_Rebate_Percent__c = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c;
                }
                lineItem = PaymentLineRounding(lineItem);
                Boolean isCapped = false;
                try {
                    isCapped = interimData.Module.ASI_CRM_CN_Is_Capped__c && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c == largestMinTarget;
                } catch (Exception e) {
                    isCapped = interimData.Module.ASI_CRM_CN_Is_Capped__c;
                }
                lineItem = calculatePSFLine(lineItem, interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__r.Name, isCapped, interimData.Module.ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c);
                lineItem.ASI_CRM_Module__c = interimData.Module.Id;

                lineItem.ASI_CRM_CN_AC_Code__c = ActivityCode;


            }
            interimData.DetailLineMap = paymentLineMap;

            interimData = calculateInterimDataTotal(interimData);
            interimData.Module.ASI_CRM_Suggested_Payable_Amount__c = interimData.TotalCTDPayableAmount;

            if (interimData.Module.ASI_CRM_Methodology__r.Name == 'Others') {
                Decimal totalAmount = 0;
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : interimData.DetailLineMap.values()) {
                    totalAmount += lineItem.ASI_CRM_V0_0_Full_Contract_Target__c;
                }
                interimData.Module.ASI_CRM_Historical_Paid_Amount__c = interimData.Module.ASI_CRM_Historical_Paid_Amount__c != null? interimData.Module.ASI_CRM_Historical_Paid_Amount__c : 0;
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = totalAmount.setScale(2) - interimData.Module.ASI_CRM_Historical_Paid_Amount__c;
                interimData.Module.ASI_CRM_Suggested_Payable_Amount__c = interimData.Module.ASI_CRM_Application_Payment_Amount__c;
                interimData.Module.ASI_CRM_Actual_Payment__c = interimData.Module.ASI_CRM_Application_Payment_Amount__c.setScale(2);
                interimData.Module.ASI_CRM_Adjustment__c = 100;
            } else if (interimData.TotalCompletionRatio < interimData.Module.ASI_CRM_CN_CTD_Minimal_Achievement__c) {
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = 0;
                interimData.Module.ASI_CRM_Suggested_Payable_Amount__c = 0;
                interimData.Module.ASI_CRM_Adjustment__c = 0;
                interimData.Module.ASI_CRM_Actual_Payment__c = 0;
                calculateOtherCostByDolphin(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, 'less');
            } else {
                interimData.Module.ASI_CRM_Historical_Paid_Amount__c = interimData.Module.ASI_CRM_Historical_Paid_Amount__c != null? interimData.Module.ASI_CRM_Historical_Paid_Amount__c : 0;
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = interimData.TotalCTDPayableAmount - interimData.Module.ASI_CRM_Historical_Paid_Amount__c;
                interimData.Module.ASI_CRM_Actual_Payment__c = interimData.Module.ASI_CRM_Application_Payment_Amount__c.setScale(2);
                interimData.Module.ASI_CRM_Adjustment__c = 100;
                calculateOtherCostByDolphin(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, 'normal');
            }


        }

        RefreshAllData();
        PSF_Item_MapJSON = JSON.serialize(PSF_Item_Map);

    }
    //@Description: Dolphin Contract合同时，需要计算Other Cost的应付金额并刷新
    //@return     : void
    public void calculateOtherCostByDolphin(Date startDate ,Date endDate, String type) {
        if (!ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
            return;
        }
        if (type == 'normal') {
            Decimal CTDActualPurchaseValueSum = 0;
            for (ASI_CRM_Subbrand_Volume__c SubVol : RetrieveSubBrandVolume(PH.ASI_CRM_CN_PO_Start_Date__c, EndDate, outletIds)) {
                CTDActualPurchaseValueSum += calculateCTDActualPurchaseValue(SubVol, 'Outlet Reception Scan', BRSFModule.ASI_CRM_CN_Total_Markup__c);
            }
            for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : OtherPaymentLineList) {
                Decimal rebatePercent = lineItem.ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Estimate_Amount_Rate__c != null? 
                lineItem.ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Estimate_Amount_Rate__c : 0;
                lineItem.ASI_CRM_Historical_Paid_Amount__c = lineItem.ASI_CRM_Historical_Paid_Amount__c == null?0:lineItem.ASI_CRM_Historical_Paid_Amount__c;
                lineItem.ASI_CRM_CTD_Actual_Purchase_Value__c = CTDActualPurchaseValueSum;
                lineItem.ASI_CRM_CN_Total_Payable__c = CTDActualPurchaseValueSum * rebatePercent / 100;
                System.debug(LoggingLevel.INFO, '*** lineItem.ASI_CRM_Historical_Paid_Amount__c: ' + lineItem.ASI_CRM_Historical_Paid_Amount__c);            
                lineItem.ASI_CRM_Application_Payment_Amount__c = lineItem.ASI_CRM_CN_Total_Payable__c - lineItem.ASI_CRM_Historical_Paid_Amount__c;
                lineItem.ASI_TH_CRM_Amount__c = lineItem.ASI_CRM_Application_Payment_Amount__c.setScale(2);
            }
        } else {
            for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : OtherPaymentLineList) {
                lineItem.ASI_CRM_Application_Payment_Amount__c = 0;
                lineItem.ASI_TH_CRM_Amount__c = 0;
            }
        }
    }
    public ASI_TH_CRM_PaymentRequestLineItem__c calculatePSFLine(ASI_TH_CRM_PaymentRequestLineItem__c lineItem, String KPIBase, String methodology, Boolean isCapped, String version) {
        version = version == null? '0.0' : version;
        Decimal actualPurchaseValue = lineItem.ASI_CRM_CTD_Actual_Purchase_Value__c != null? lineItem.ASI_CRM_CTD_Actual_Purchase_Value__c : 0;
        Decimal contractPurchaseValue = 0;
        if (lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r == null) {
            contractPurchaseValue = 0;
        } else if (version == '0.0' && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r != null && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c != null) {
            contractPurchaseValue = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c;
        } else if (version != '0.0' && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r != null && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c != null) {
            contractPurchaseValue = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c;
        }

        Decimal rebatePercent = lineItem.ASI_CRM_CN_Rebate_Percent__c != null? lineItem.ASI_CRM_CN_Rebate_Percent__c : 0;

        // Prevent divided by zero
        lineItem.ASI_CRM_CN_Completion_Rate__c = contractPurchaseValue != 0? actualPurchaseValue / contractPurchaseValue * 100 : 0;

        Decimal contractTargetCR12 = 0;
        if (lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r == null) {
            contractTargetCR12 = 0;
        } else if (version == '0.0' && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r != null && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c != null) {
            contractTargetCR12 = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
        } else if (version != '0.0' && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r != null && lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c != null) {
            contractTargetCR12 = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
        }

        if (KPIBase == 'Volume base' && methodology == 'Per Incentive Btl') {
            Decimal incentivePerBottle = lineItem.ASI_CRM_CN_Incentive_BT__c == null? 0 : lineItem.ASI_CRM_CN_Incentive_BT__c;
            Decimal CTDIntakeCR12 = lineItem.ASI_CRM_CTD_Actual_Vol__c == null? 0 : lineItem.ASI_CRM_CTD_Actual_Vol__c;
            lineItem.ASI_CRM_CN_Total_Payable__c = incentivePerBottle * lineItem.ASI_CRM_CN_Actual_Vol__c;
            if (contractTargetCR12 > 0) {
                lineItem.ASI_CRM_CN_Completion_Rate__c = CTDIntakeCR12 / contractTargetCR12 * 100;
            } else {
                lineItem.ASI_CRM_CN_Completion_Rate__c = 0;
            }
        }
        if ((KPIBase == 'Volume base' || KPIBase == 'Value base') && methodology == 'Actual Achievement%') {
            Decimal CTDIntakeCR12 = lineItem.ASI_CRM_CTD_Actual_Vol__c == null? 0 : lineItem.ASI_CRM_CTD_Actual_Vol__c;
            Decimal contractTotalAmount = 0;

            if (KPIBase == 'Volume base') {
                contractTotalAmount = lineItem.ASI_CRM_V0_0_Full_Contract_Target__c;
            } else if (KPIBase == 'Value base') {
                contractTotalAmount = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Total_Dummy__c;
            }

            if (contractTargetCR12 > 0) {
                lineItem.ASI_CRM_CN_Completion_Rate__c = CTDIntakeCR12 / contractTargetCR12 * 100;
            } else {
                lineItem.ASI_CRM_CN_Completion_Rate__c = 0;
            }
            lineItem.ASI_CRM_CN_Total_Payable__c = contractTotalAmount * lineItem.ASI_CRM_CN_Completion_Rate__c / 100;

        }
        if (KPIBase == 'Value base' && methodology == 'Rebate%') {
            lineItem.ASI_CRM_CN_Total_Payable__c = actualPurchaseValue * rebatePercent / 100;
        }
        if (KPIBase == 'Value base' && methodology == 'Reach X get Y') {
            Decimal target = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Target__c;
            Decimal rebate = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate__c;

            if (target == null || target == 0 || rebate == null) {
                lineItem.ASI_CRM_CN_Total_Payable__c = 0;
            } else {
                lineItem.ASI_CRM_CN_Total_Payable__c = Integer.valueOf(actualPurchaseValue / target) * rebate;
            }
        }
        if (KPIBase == 'Value base' && methodology == 'Rebate%(By Ladder)') {
            Decimal min = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c;
            Decimal max = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c;

            min = min == null? 0 : min;

            Decimal cappedValue = 0;

            if (actualPurchaseValue >= min && min >= contractPurchaseValue ) {
                cappedValue = min;
            } else if (actualPurchaseValue >= contractPurchaseValue && contractPurchaseValue >= min) {
                cappedValue = contractPurchaseValue;
            } else if (contractPurchaseValue >= actualPurchaseValue && actualPurchaseValue >= min) {
                cappedValue = actualPurchaseValue;
            }


            lineItem.ASI_CRM_CN_Total_Payable__c = ASI_CRM_CN_ContractOffUtilClass.calculateRebatePercentByLadder(min, max, actualPurchaseValue, rebatePercent, isCapped, cappedValue);
        }
        if (KPIBase == 'Value base' && methodology == 'Rebate%(By Tax)') {
            Decimal min = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c == null? 0 : lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c;
            Decimal max = lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c == null? actualPurchaseValue : Math.min(lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c, actualPurchaseValue);

            lineItem.ASI_CRM_CN_Total_Payable__c = actualPurchaseValue > min? (max - min) * rebatePercent / 100 : 0;
        }
        return lineItem;
    }

    public void GenerateVECVol() {


        String param_Id = ApexPages.currentPage().getParameters().get('PARAMID');

        interimData interimData = DisplayItemMap.get(param_Id);
        if (VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, interimData.Module.ASI_CRM_Parent_Module__c, 'For Display, we meet following error in End Date: <br/>')) {
            RefreshAllData();
            //remove existing line in DisplayItemMap
            for (String key : interimData.DetailLineMap.keySet()) {
                ASI_TH_CRM_PaymentRequestLineItem__c delTarget = interimData.DetailLineMap.get(key);
                if (delTarget.Id != null) {
                    PaymentLineDeleteList.add(delTarget);
                }
                interimData.DetailLineMap.remove(key);
            }
            interimData.Module.ASI_CRM_CN_CTD_Minimal_Achievement__c = calculateCTDMinimalAchievement(PH.ASI_CRM_CN_PO_Start_Date__c, PH.ASI_CRM_CN_PO_End_Date__c, interimData.Module.ASI_CRM_End_Date__c, interimData.Module.ASI_CRM_CN_Minimal_Achievement__c);

            //BRSF List from contract

            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            //HistoricalPaymentLine
            if (interimData.Module.ASI_CRM_Parent_Module__c != null) {

                ContractList = [
                    SELECT
                        ASI_CRM_CN_Activity_Code__c,
                        ASI_CRM_CN_Contract__c,
                        ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,
                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                        ASI_CRM_CN_Contract_Monthly_Qty__c,
                        ASI_CRM_CN_Contract_Purchase_Value__c,
                        ASI_CRM_CN_Estimate_Purchase_Value__c,
                        ASI_CRM_CN_Contract_Total__c,
                        ASI_CRM_CN_Contract_Total_Dummy__c,
                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                        ASI_CRM_CN_Est_Monthly_Qty__c,
                        ASI_CRM_CN_Est_Total__c,
                        ASI_CRM_CN_Est_Total_Dummy__c,
                        ASI_CRM_CN_Max_Purchase_Target__c,
                        ASI_CRM_CN_Min_Purchase_Target__c,
                        ASI_CRM_CN_Rebate__c,
                        ASI_CRM_CN_Rebate_Percent__c,
                        ASI_CRM_CN_Sub_Brand__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                        ASI_CRM_CN_Sub_Brand__r.Name,
                        ASI_CRM_CN_Target__c,
                        ASI_CRM_Contract_Monthly_Volume_CR12__c,
                        ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c,
                        ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c,
                        ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                        ASI_CRM_Contract_Total_QTY_std_Btl__c,
                        ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c,
                        ASI_CRM_Est_Monthly_Volume_CR12__c,
                        ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c,
                        ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                        ASI_CRM_Est_Total_QTY_std_Btl__c,
                        ASI_CRM_Key_Sub_brand__c,
                        ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Product_Category__c,
                        ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                        ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                        ASI_CRM_Product_Category__r.Name,
                        ASI_CRM_Sub_Brand_Grade__c,
                        ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                        Id
                    FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                    WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c
                    AND ASI_CRM_Module__c = :interimData.Module.ASI_CRM_Parent_Module__c
                    AND ASI_CRM_Type__c = 'Display'
                    AND ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != '999'
                    ORDER BY ASI_CRM_CN_Contract__c
                ];
            }

            //Getting Activity Code base on the 'Contract Cost Setting' table
            List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList = [
                SELECT Id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_CN_Other_Cost_Payment_Request__c
                FROM ASI_CRM_Contract_Cost_Setting__c
                WHERE ASI_CRM_CN_Promotion_Type__c = :PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
                AND ASI_CRM_VEC_Activity_Code_Defaul__c = TRUE
            ];
            Id ActivityCode;
            if (LContractCostSettingList != null && LContractCostSettingList.size() == 1) {
                ActivityCode = LContractCostSettingList[0].ASI_CRM_CN_Activity_Code__c;
            }


            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Total' || interimData.Module.ASI_CRM_Methodology__r.Name == 'Others') {

                Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineMap = ByTotalPaymentLineCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, ContractList, interimData.Module);

                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : paymentLineMap.values()) {
                    lineItem.ASI_CRM_CN_AC_Code__c = ActivityCode;
                }

                interimData.DetailLineMap = paymentLineMap;
            }

            calculateInterimDataTotal(DisplayItemMap);


            interimData.Module.ASI_CRM_Suggested_Payable_Amount__c = interimData.TotalCTDPayableAmount.setScale(2);

            if (interimData.Module.ASI_CRM_Methodology__r.Name == 'Others') {
                Decimal totalAmount = 0;
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : interimData.DetailLineMap.values()) {
                    totalAmount += lineItem.ASI_CRM_V0_0_Full_Contract_Target__c;
                }

                interimData.Module.ASI_CRM_Historical_Paid_Amount__c = interimData.Module.ASI_CRM_Historical_Paid_Amount__c != null? interimData.Module.ASI_CRM_Historical_Paid_Amount__c : 0;
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = totalAmount.setScale(2) - interimData.Module.ASI_CRM_Historical_Paid_Amount__c;
                interimData.Module.ASI_CRM_Suggested_Payable_Amount__c = interimData.Module.ASI_CRM_Application_Payment_Amount__c;
                interimData.Module.ASI_CRM_Adjustment__c = 100;
            } else if (interimData.TotalCompletionRatio < interimData.Module.ASI_CRM_CN_CTD_Minimal_Achievement__c) {
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = 0;
                interimData.Module.ASI_CRM_Adjustment__c = 0;
                interimData.Module.ASI_CRM_Actual_Payment__c = 0;
            } else {
                interimData.Module.ASI_CRM_Historical_Paid_Amount__c = interimData.Module.ASI_CRM_Historical_Paid_Amount__c != null? interimData.Module.ASI_CRM_Historical_Paid_Amount__c : 0;
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = interimData.TotalCTDPayableAmount.setScale(2) - interimData.Module.ASI_CRM_Historical_Paid_Amount__c;
                interimData.Module.ASI_CRM_Actual_Payment__c = interimData.Module.ASI_CRM_Application_Payment_Amount__c.setScale(2);
                interimData.Module.ASI_CRM_Adjustment__c = 100;
            }


        }

    }


    public ASI_TH_CRM_PaymentRequestLineItem__c PaymentLineRounding(ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine) { //Math.floor
        InsertPayLine.ASI_CRM_CN_Actual_Vol__c = InsertPayLine.ASI_CRM_CN_Actual_Vol__c != null? InsertPayLine.ASI_CRM_CN_Actual_Vol__c.setScale(0) : 0;
        InsertPayLine.ASI_CRM_CN_Bottle_Collected__c = InsertPayLine.ASI_CRM_CN_Bottle_Collected__c != null? InsertPayLine.ASI_CRM_CN_Bottle_Collected__c.setScale(0) : 0;
        InsertPayLine.ASI_CRM_CTD_Actual_Vol__c = InsertPayLine.ASI_CRM_CTD_Actual_Vol__c != null? InsertPayLine.ASI_CRM_CTD_Actual_Vol__c.setScale(0) : 0;

        return InsertPayLine;

    }


    public void resetModule() {
        String param_Id = ApexPages.currentPage().getParameters().get('PARAMID');
        interimData interimData = PSF_Item_Map.containsKey(param_Id)? PSF_Item_Map.get(param_Id) : DisplayItemMap.get(param_Id);
        if (interimData == null) {
            return;
        }

        // Reset module
        interimData.Module.ASI_CRM_End_Date__c = null;
        interimData.Module.ASI_CRM_Application_Payment_Amount__c = 0;
        interimData.Module.ASI_CRM_Actual_Payment__c = 0;
        interimData.Module.ASI_CRM_Other_Comments__c = null;
        interimData.Module.ASI_CRM_Overpayment_Reason__c = null;
        interimData.Module.ASI_CRM_PSF_Overpayment_Reason__c = null;
        interimData.Module.ASI_CRM_Adjustment__c = 100;
        interimData.Module.ASI_CRM_CN_CTD_Minimal_Achievement__c = 0;

        // Remove all lines
        for (String key : interimData.DetailLineMap.keySet()) {
            ASI_TH_CRM_PaymentRequestLineItem__c delTarget = interimData.DetailLineMap.get(key);
            if (delTarget.Id != null) {
                PaymentLineDeleteList.add(delTarget);
            }
            interimData.DetailLineMap.remove(key);
        }

        ResetInterimData(interimData);
        PSF_Item_MapJSON = JSON.serialize(PSF_Item_Map);
    }


    //Reset Value
    public interimData ResetInterimData(interimData InputData) {
        InputData.TotalIntake = 0;
        InputData.TotalIntake_Completion = 0.0;
        InputData.TotalIntake_Btl = 0.0;
        InputData.TotalCTDPayableAmount = 0.0;
        InputData.VolumeTarget = 0.0;
        InputData.TotalCompletionRatio = 0;


        return InputData;

    }


    //@Description: Base on Sub-Brand Volume, Contract Line and Historical payment Line,  to generate the Payment line
    //@param      : SubBrandVolumeList :  from RetrieveSubBrandVolume retrun List.
    //@param      : ContractList. Payment--->Contract----> Contract line.
    //@param      : HistoricalPaymentLineList : historical payment which is not included current payment. If the sub-brand incentive can be retrieved from the historical payment, the Incentive (Per Bottle) will be read-only.
    //@param      :  RecordTypeName : Payment request line Record Type
    //@return     : the refreshed Payment Line list
    public Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> SubBrandGroupingCalculation(Date StartDate, Date EndDate, List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList, String MethodologyCode) {


        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> SubBrandGroupingMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>(); //Sub-Brand, Payment Line

        // Looping the Subbrand Volume
        for (ASI_CRM_Subbrand_Volume__c SubVol : RetrieveSubBrandVolume(StartDate, EndDate, outletIds)) {
            Decimal CTDActualVol = Cal_CTD_Actual_Vol(SubVol,BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c);
            Decimal CTDIntakeCR12 = Cal_Intake_VolCR12(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c);

            //20191113:AM@introv - fix missing negative value
            //if (SubVol.ASI_CRM_Subbrand__c != null && CTDActualVol > 0) {
            if (SubVol.ASI_CRM_Subbrand__c != null && CTDActualVol != 0) {


                String Mapkeystr = NameSortingASC(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c) + SubVol.ASI_CRM_Subbrand__c;


                if (SubBrandGroupingMap.containsKey(Mapkeystr)) {
                    // If contain, recalculate  'CTD Actual Volume'
                    ASI_TH_CRM_PaymentRequestLineItem__c TempData = SubBrandGroupingMap.get(Mapkeystr);
                    TempData.ASI_CRM_CTD_Actual_Vol__c += CTDIntakeCR12;
                    TempData.ASI_CRM_CN_Actual_Vol__c += CTDActualVol;
                    TempData.ASI_CRM_CTD_Actual_Purchase_Value__c += calculateCTDActualPurchaseValue(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c, BRSFModule.ASI_CRM_CN_Total_Markup__c);
                    TempData.ASI_CRM_CTD_Actual_Purchase_Value_Ref__c += calculateCTDActualPurchaseValue(SubVol, 'Outlet Intake', BRSFModule.ASI_CRM_CN_Total_Markup__c);
                    //TempData.ASI_CRM_CN_Payable_Vol__c += PayableVol;
                    //TempData.ASI_CRM_Actual_Volume_Id__c += ';' + SubVol.Id; // save actual volume Id
                    SubBrandGroupingMap.remove(Mapkeystr);
                    SubBrandGroupingMap.put(Mapkeystr, TempData);
                } else {// If not contain, create new payment request line

                    ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine = createPaymentRequestLineItem(PH.Id, null, 'By Sub-Brand', 'ASI_CRM_CN_Payment_Request_Detail_PSF');
                    paymentRequestLine.ASI_CRM_CN_Sub_Brand__c = SubVol.ASI_CRM_Subbrand__c;
                    paymentRequestLine.ASI_CRM_CN_Sub_Brand__r = SubVol.ASI_CRM_Subbrand__r;
                    //paymentRequestLine.ASI_CRM_Actual_Volume_Id__c = SubVol.Id;
                    paymentRequestLine.ASI_CRM_Sub_Brand_Grade__c = SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                    paymentRequestLine.ASI_CRM_Line_Name__c = SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null? SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c : SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    paymentRequestLine.ASI_CRM_CN_Standard__c = SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    paymentRequestLine.ASI_CRM_Line_Name__c = SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    paymentRequestLine.ASI_CRM_Brand_Code__c = SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c != null? SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c : '';
                    paymentRequestLine.ASI_CRM_CTD_Actual_Vol__c = CTDIntakeCR12;
                    paymentRequestLine.ASI_CRM_CN_Actual_Vol__c = CTDActualVol;
                    paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value__c = calculateCTDActualPurchaseValue(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c, BRSFModule.ASI_CRM_CN_Total_Markup__c);
                    paymentRequestLine.ASI_CRM_CTD_Actual_Purchase_Value_Ref__c = calculateCTDActualPurchaseValue(SubVol, 'Outlet Intake', BRSFModule.ASI_CRM_CN_Total_Markup__c);

                    // Default them to true, then later set them to false in BRSF Line loop
                    paymentRequestLine.ASI_CRM_CN_Allow_Changing_Incentive__c = true;
                    paymentRequestLine.ASI_CRM_Non_Contract_Line__c = true;

                    SubBrandGroupingMap.put(Mapkeystr, paymentRequestLine);
                }
            }
        }


        //Looping the Contract List
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractList) {
            if (ContractLine.ASI_CRM_CN_Sub_Brand__c == null) {
                continue;
            }

            String Mapkeystr = NameSortingASC(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__c;

            ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLine;
            // If sub-brand is defined in contract, and there is sub-brand volume
            if (SubBrandGroupingMap.containsKey(Mapkeystr)) {
                paymentRequestLine = SubBrandGroupingMap.get(Mapkeystr);
                if (ContractLine.ASI_CRM_Key_Sub_brand__c) {
                    paymentRequestLine.ASI_CRM_Key_Sub_Brand__c = true;
                }
                // Set default incentive bottlw
                if (ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                    paymentRequestLine.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null? 0 : ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    paymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c == null? 0 : ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                } else {
                    paymentRequestLine.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null? 0 : ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                    paymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c == null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                }

                paymentRequestLine.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                paymentRequestLine.ASI_CRM_Non_Contract_Line__c = false;
                paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.Id;
                paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r = ContractLine;
                SubBrandGroupingMap.remove(Mapkeystr);
                SubBrandGroupingMap.put(Mapkeystr, paymentRequestLine);

            } else {
                // If sub-brand is defined in contract, and there is NO sub-brand volume

                paymentRequestLine = createPaymentRequestLineItem(PH.Id, null, 'By Sub-Brand', 'ASI_CRM_CN_Payment_Request_Detail_PSF');
                paymentRequestLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                paymentRequestLine.ASI_CRM_CN_Standard__c = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                paymentRequestLine.ASI_CRM_Line_Name__c = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c : ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.Id;
                paymentRequestLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r = ContractLine;
                paymentRequestLine.ASI_CRM_CN_Sub_Brand__r = ContractLine.ASI_CRM_CN_Sub_Brand__r;
                paymentRequestLine.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                paymentRequestLine.ASI_CRM_Key_Sub_Brand__c = ContractLine.ASI_CRM_Key_Sub_brand__c? true : false;
                paymentRequestLine.ASI_CRM_Non_Contract_Line__c = false;

                if (ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                    paymentRequestLine.ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null? 0 : ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    paymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c == null? 0 : ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                } else {
                    paymentRequestLine.ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null? 0 : ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                    paymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c == null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;

                }

                SubBrandGroupingMap.put(Mapkeystr, paymentRequestLine);
            }

        }

        // Modify the key of the map so it will order well
        // The ordering would be :
        // 1: Key Brand, 2: Sub-brand in BRSF Line, 3: Sub-brand not in BRSF Line
        // If they are within same group, order by grade sequence of the sub-brand
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> returnMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        for (String key : SubBrandGroupingMap.keySet()) {
            ASI_TH_CRM_PaymentRequestLineItem__c lineItem = SubBrandGroupingMap.get(key);
            String prefix = '5';

            if (lineItem.ASI_CRM_CN_Allow_Changing_Incentive__c) {
                prefix = '9';
            }

            if (lineItem.ASI_CRM_Key_Sub_Brand__c) {
                prefix = '0';
            }
            returnMap.put(prefix + key, lineItem);
        }
        return returnMap;
    }


    //********************Generating Payment Line by Product Category Grouping***************
    public Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> ProductCategoryGroupingCalculation(Date StartDate, Date EndDate, List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList, String MethodologyCode) {
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> GroupingMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();

        // Looping the Subbrand Volume
        for (ASI_CRM_Subbrand_Volume__c SubVol : RetrieveSubBrandVolume(StartDate, EndDate, outletIds)) {
            Decimal CTDIntakeCR12 = Cal_Intake_VolCR12(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c);

            //20191113:AM@introv - fix missing negative value
            //if (SubVol.ASI_CRM_Subbrand__c != null && SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c != null && CTDIntakeCR12 > 0) {            
            if (SubVol.ASI_CRM_Subbrand__c != null && SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c != null && CTDIntakeCR12 != 0) {
                String key = NameSortingASC(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c) + SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c;

                ASI_TH_CRM_PaymentRequestLineItem__c lineItem = GroupingMap.containsKey(key)? GroupingMap.get(key) : createPaymentRequestLineItem(PH.Id, null, 'By Category', 'ASI_CRM_CN_Payment_Request_Detail_PSF');
                lineItem.ASI_CRM_Product_Category__c = SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c;
                lineItem.ASI_CRM_Line_Name__c = SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c;
                lineItem.ASI_CRM_Non_Contract_Line__c = true;
                lineItem.ASI_CRM_CN_Allow_Changing_Incentive__c = true;
                lineItem.ASI_CRM_CTD_Actual_Vol__c += CTDIntakeCR12;
                lineItem.ASI_CRM_CN_Actual_Vol__c += Cal_CTD_Actual_Vol(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c);
                lineItem.ASI_CRM_CTD_Actual_Purchase_Value__c += calculateCTDActualPurchaseValue(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c, BRSFModule.ASI_CRM_CN_Total_Markup__c);
                lineItem.ASI_CRM_CTD_Actual_Purchase_Value_Ref__c += calculateCTDActualPurchaseValue(SubVol, 'Outlet Intake', BRSFModule.ASI_CRM_CN_Total_Markup__c);
                //lineItem.ASI_CRM_Actual_Volume_Id__c += ';' + SubVol.Id;

                GroupingMap.put(key, lineItem);
            }
        }

        //Looping the Contract List
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractList) {
            if (ContractLine.ASI_CRM_Product_Category__c == null) {
                continue;
            }
            String Mapkeystr = NameSortingASC(ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) + ContractLine.ASI_CRM_Product_Category__c;

            ASI_TH_CRM_PaymentRequestLineItem__c lineItem = GroupingMap.containsKey(Mapkeystr)? GroupingMap.get(Mapkeystr) : createPaymentRequestLineItem(PH.Id, null, 'By Category', 'ASI_CRM_CN_Payment_Request_Detail_PSF');
            lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.Id;
            lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r = ContractLine;

            // If there is sub-brand vol in this category and its BRSF Line has input, don't allow incentive change
            if (GroupingMap.containsKey(Mapkeystr)) {
                if (lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Total_Dummy__c != 0 || lineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Est_Total_Dummy__c != 0) {
                    lineItem.ASI_CRM_Non_Contract_Line__c = false;
                    lineItem.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                }
            } else {// Create new payment line
                lineItem.ASI_CRM_Product_Category__c = ContractLine.ASI_CRM_Product_Category__c;
                lineItem.ASI_CRM_Line_Name__c = ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : ContractLine.ASI_CRM_Product_Category__r.Name;
            }

            if (ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                lineItem.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c == null? 0 : ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
            } else {
                lineItem.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
            }

            GroupingMap.put(Mapkeystr, lineItem);

        }

        return GroupingMap ;
    }


    //************************************By Total ****************************************************************
    public Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> ByTotalPaymentLineCalculation(Date StartDate, Date EndDate, List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList, ASI_CRM_Module__c module) {
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> lineItemMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();

        Decimal actualVolumeCR12Sum = 0;
        Decimal actualVolumeSum = 0;
        String actualVolumeIds = '';
        Decimal CTDActualPurchaseValueSum = 0;
        Decimal CTDActualPurchaseValueSumRef = 0;
        for (ASI_CRM_Subbrand_Volume__c SubVol : RetrieveSubBrandVolume(StartDate, EndDate, outletIds)) {
            actualVolumeCR12Sum += Cal_Intake_VolCR12(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c);
            actualVolumeSum += Cal_CTD_Actual_Vol(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c);
            actualVolumeIds += ';' + SubVol.Id;
            CTDActualPurchaseValueSum += calculateCTDActualPurchaseValue(SubVol, BRSFModule.ASI_CRM_CN_Contract_Volume_Base__c, BRSFModule.ASI_CRM_CN_Total_Markup__c);
            CTDActualPurchaseValueSumRef += calculateCTDActualPurchaseValue(SubVol, 'Outlet Intake', BRSFModule.ASI_CRM_CN_Total_Markup__c);
        }


        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractList) {
            ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = createPaymentRequestLineItem(PH.Id, module.Id, 'By Total', 'ASI_CRM_CN_Payment_Request_Detail_' + module.ASI_CRM_Line_Type__c);

            paymentLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.Id;
            paymentLine.ASI_CRM_CN_Contract_BRSF_Line_Item__r = ContractLine;
            paymentLine.ASI_CRM_CTD_Actual_Vol__c = actualVolumeCR12Sum;
            paymentLine.ASI_CRM_CN_Actual_Vol__c = actualVolumeSum;
            //paymentLine.ASI_CRM_Actual_Volume_Id__c = actualVolumeIds;
            paymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c = CTDActualPurchaseValueSum;
            paymentLine.ASI_CRM_CTD_Actual_Purchase_Value_Ref__c = CTDActualPurchaseValueSumRef;
            if (ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                paymentLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c == null? 0 : ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
            } else {
                paymentLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
            }
            paymentLine = calculatePSFLine(paymentLine, module.ASI_CRM_CN_KPI_Base__c, module.ASI_CRM_Methodology__r.Name, module.ASI_CRM_CN_Is_Capped__c, module.ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c);
            paymentLine = PaymentLineRounding(paymentLine);

            lineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), paymentLine);
        }


        return lineItemMap;
    }


    /**
     * Get all outletIds, including contract's outlet and its covered outlets
     *
     * @param contractId
     *
     * @return Set of outlet Ids
     */
    public Set<Id> getOutletIds(Id contractId) {
        Set<Id> outletIds = new Set<Id>();
        //Getting Outlet Id including 'Covered Outlet'
        for (ASI_CRM_CN_Covered_Outlet__c o : [SELECT Id, ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :contractId]) {
            outletIds.add(o.ASI_CRM_CN_Outlet__c);
        }
        outletIds.add(PH.ASI_CRM_CN_OutletWS__c);
        return outletIds;
    }


    public ASI_TH_CRM_PaymentRequestLineItem__c createPaymentRequestLineItem(Id paymentId, Id moduleId, String volumeBase, String recordTypeName) {
        ASI_TH_CRM_PaymentRequestLineItem__c lineItem = new ASI_TH_CRM_PaymentRequestLineItem__c (
            ASI_CRM_Actual_Volume_Id__c = ' ',
            ASI_CRM_CN_Actual_Vol__c = 0,
            ASI_CRM_CN_Allow_Changing_Incentive__c = false,
            ASI_CRM_CN_Collection_Rate__c = 0,
            ASI_CRM_CN_Completion_Rate__c = 0,
            ASI_CRM_CN_Incentive_BT__c = 0,
            ASI_CRM_CN_Payable_Vol__c = 0,
            ASI_CRM_CN_Suggested_Amount__c = 0,
            ASI_CRM_CN_Target_BT__c = 0,
            ASI_CRM_CN_Total_Payable__c = 0,
            ASI_CRM_CTD_Actual_Purchase_Value__c = 0,
            ASI_CRM_CTD_Actual_Purchase_Value_Ref__c = 0,
            ASI_CRM_CTD_Actual_Vol__c = 0,
            ASI_CRM_CTD_Actual_Vol_Martell__c = 0,
            ASI_CRM_CTD_Actual_Vol_Martell_CR12__c = 0,
            ASI_CRM_CTD_Actual_Vol_Pure__c = 0,
            ASI_CRM_CTD_Actual_Vol_Pure_CR12__c = 0,
            ASI_CRM_CTD_BC_Martell__c = 0,
            ASI_CRM_CTD_BC_Pure__c = 0,
            ASI_CRM_CTD_Cap_Collection_Vol__c = 0,
            ASI_CRM_Full_Contract_Target_ExclPremium__c = 0,
            ASI_CRM_Intake_Excl_Premium__c = 0,
            ASI_CRM_Intake_Martell_Excl_Premium__c = 0,
            ASI_CRM_Intake_Pure_Excl_Premium__c = 0,
            ASI_CRM_Module__c = moduleId,
            ASI_CRM_Suggested_Volume__c = 0,
            ASI_CRM_V0_0_Full_Contract_Target__c = 0,
            ASI_CRM_Volume_Base__c = volumeBase,
            ASI_TH_CRM_Payment_Request__c = paymentId,
            ASI_CRM_CN_Rebate__c = 0,
            ASI_CRM_CN_Target__c = 0,
            ASI_CRM_CN_Rebate_Percent__c = 0,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__c' + recordTypeName)
        );
        return lineItem;
    }


    public Decimal calculateCTDActualPurchaseValue(ASI_CRM_Subbrand_Volume__c subBrandVolume, String contractVolumeBase, Decimal markupPercent) {
        markupPercent = markupPercent == null? 0 : markupPercent;

        Decimal actualPurchaseValue = 0;
        if (contractVolumeBase == 'Outlet Intake') {
            actualPurchaseValue = subBrandVolume.ASI_CRM_CN_Intake_GS_T1_Price__c != null? subBrandVolume.ASI_CRM_CN_Intake_GS_T1_Price__c : 0;
        }
        else if (contractVolumeBase == 'POS') {
            actualPurchaseValue = subBrandVolume.ASI_CRM_POS_GS__c != null? subBrandVolume.ASI_CRM_POS_GS__c : 0;
        } else if (contractVolumeBase == 'Outlet Reception Scan') {
            actualPurchaseValue += subBrandVolume.ASI_CRM_Green_ORS_GS__c != null? subBrandVolume.ASI_CRM_Green_ORS_GS__c : 0;
            actualPurchaseValue += subBrandVolume.ASI_CRM_Empty_Bottle_GS__c != null? subBrandVolume.ASI_CRM_Empty_Bottle_GS__c : 0;
        }

        return actualPurchaseValue * (1 + markupPercent / 100);
    }


    /**
     * Get CTD actual volume standard bottle. If Contract Volume Base is POS, take POS fields. If Contract Volume Base is Outlet Intake, take Direct fields.
     * The CTD actual volume is rounded by floor before return.
     *
     * @param subBrandVolume
     *
     * @return
     */
    public Decimal Cal_CTD_Actual_Vol(ASI_CRM_Subbrand_Volume__c subBrandVolume, String contractVolumeBase) {
        Decimal CTDActualVol = 0.0;
        if (contractVolumeBase == 'Outlet Intake') {
            CTDActualVol += subBrandVolume.ASI_CRM_PR_Direct_STD_Billing__c == null? 0 : subBrandVolume.ASI_CRM_PR_Direct_STD_Billing__c;
            CTDActualVol += subBrandVolume.ASI_CRM_T1_Depletion_STD_Billing__c == null? 0 : subBrandVolume.ASI_CRM_T1_Depletion_STD_Billing__c;
            CTDActualVol += subBrandVolume.ASI_CRM_T2_Depletion_STD_Billing__c == null? 0 : subBrandVolume.ASI_CRM_T2_Depletion_STD_Billing__c;
        }
        else if (contractVolumeBase == 'POS') {
            CTDActualVol = subBrandVolume.ASI_CRM_POS_Std_Billing__c;
        } else if (contractVolumeBase == 'Outlet Reception Scan') {
            CTDActualVol = subBrandVolume.ASI_CRM_Green_ORS_Std_Billing__c == null? 0 :subBrandVolume.ASI_CRM_Green_ORS_Std_Billing__c;
            CTDActualVol = subBrandVolume.ASI_CRM_Empty_Bottle_Std_Billing__c == null? 0 :subBrandVolume.ASI_CRM_Empty_Bottle_Std_Billing__c;
        }

        CTDActualVol = CTDActualVol.round(System.RoundingMode.FLOOR);

        return CTDActualVol;
    }


    public Decimal Cal_Intake_VolCR12(ASI_CRM_Subbrand_Volume__c subBrandVolume, String contractVolumeBase) {
        Decimal CTDActualVolCR12 = 0;

        if (contractVolumeBase == 'Outlet Intake') {
            CTDActualVolCR12 += subBrandVolume.ASI_CRM_PR_Direct_CR12__c == null? 0 : subBrandVolume.ASI_CRM_PR_Direct_CR12__c;
            CTDActualVolCR12 += subBrandVolume.ASI_CRM_T1_Depletion_CR12__c == null? 0 : subBrandVolume.ASI_CRM_T1_Depletion_CR12__c;
            CTDActualVolCR12 += subBrandVolume.ASI_CRM_T2_Depletion_CR12__c == null? 0 : subBrandVolume.ASI_CRM_T2_Depletion_CR12__c;
        }
        else if (contractVolumeBase == 'POS') {
            CTDActualVolCR12 = subBrandVolume.ASI_CRM_POS_CR12__c;
        } else if (contractVolumeBase == 'Outlet Reception Scan') {
            CTDActualVolCR12 += subBrandVolume.ASI_CRM_Green_ORS_CR12__c == null?0:subBrandVolume.ASI_CRM_Green_ORS_CR12__c;
            CTDActualVolCR12 += subBrandVolume.ASI_CRM_Empty_Bottle_CR12__c == null?0:subBrandVolume.ASI_CRM_Empty_Bottle_CR12__c;
        }

        CTDActualVolCR12 = CTDActualVolCR12.round(System.RoundingMode.FLOOR);


        return CTDActualVolCR12;
    }


    public static Date CutOffDate(Integer strDay) {
        Date returnDate;
        Integer strDate = Date.today().day();
        Integer strMonth;
        Integer strEndDay;
        Integer strYear;
        if (strDay != 0) {
            if (strDate >= strDay) {
                strMonth = Date.today().addMonths(-1).month();
                strYear = Date.today().addMonths(-1).year();
            }
            if (strDate < strDay) {
                strMonth = Date.today().addMonths(-2).month();
                strYear = Date.today().addMonths(-2).year();
            }
            strEndDay = Date.daysInMonth(strYear, strMonth);
            returnDate = Date.newInstance(strYear, strMonth, strEndDay);
        } else {
            returnDate = Date.today();
        }
        return returnDate;
    }

    //****************End of Generating  Volume*****************************************************************************************************


    public void ErrorHandling(String ErrorMsg) {
        Msg += ErrorMsg + '</br>';
        UpsertPermission = false;
    }



    //***********************************************************Save the record ************************************************************************************
    public PageReference saveItems() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('isQuickSave');
        Boolean isQuickSave = (isQuickSaveStr == null)? false : Boolean.valueOf(isQuickSaveStr);
        String PSFItemMapJSON = params.get('PSF_Item_MapJSON');
        Map<String, interimData> PSFItemMapWithUpdatedLines = (Map<String, interimData>) JSON.deserialize(PSFItemMapJSON, Map<String, interimData>.class);
        for (String key : PSFItemMapWithUpdatedLines.keySet()) {
            interimData newInterimData = PSFItemMapWithUpdatedLines.get(key);
            interimData oldInterimData = PSF_Item_Map.get(key);
            // Skip copying others module because it use standard way not JS way
            if (oldInterimData.Module.ASI_CRM_Methodology__r.Name == 'Others') {
                continue;
            }

            oldInterimData.DetailLineMap = newInterimData.DetailLineMap;

            PSF_Item_Map.put(key, oldInterimData);
        }

        PH.ASI_CRM_Total_Actual_Amount__c = 0;
        PH.ASI_CRM_Total_Variable_Amount__c = 0;
        PageReference pageRef = null;
        //Define variable
        UpsertPermission = true;
        Msg = '';
        List<ASI_TH_CRM_PaymentRequestLineItem__c> UpsertBRSFList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        Database.UpsertResult[] UpsertTarget;
        Database.DeleteResult[] DeleteTarget;

        UpsertBRSFList = ValidationChecking();

        //upsert Module
        List<ASI_CRM_Module__c> UpsertModuleList = new List<ASI_CRM_Module__c>();

        BRSFModule.ASI_CRM_CN_AC_Code__c = BRSFActivityCodeId;
        UpsertModuleList.add(BRSFModule);

        if (DisplayVEC) {
            for (interimData interimData : DisplayItemMap.values()) {
                if (interimData.Module.ASI_CRM_End_Date__c != null) {
                    if (!VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c, interimData.Module.ASI_CRM_End_Date__c, interimData.Module.ASI_CRM_Parent_Module__c,
                        'For Display, we meet following error in End Date: <br/>')) {
                        Msg += '<br/>';//msg= 'For Variable Event Cost, we meet following error in End Date: <br/>'+msg;
                    }
                }
                interimData.Module.ASI_CRM_CN_AC_Code__c = DisplayActivityCodeId;
                UpsertModuleList.add(interimData.Module);

            }
        }


        for (String key : PSF_Item_Map.keySet()) {

            /*
            Update:Laputa(Bowen) 
            Date: 2019-08-12
            Function:因为前端回传的数据是输入框的内容，只读框的数据是原样回传，
                    故在该处针对Adjustment的比例进行处理： Actual Payment / Application Payment Amount * 100
            */
            ASI_CRM_Module__c module = PSF_Item_Map.get(key).Module;
            if(!Test.isRunningTest() && module.ASI_CRM_Application_Payment_Amount__c != 0)module.ASI_CRM_Adjustment__c = module.ASI_CRM_Actual_Payment__c / module.ASI_CRM_Application_Payment_Amount__c * 100;
            /* ----------------------------------------bowen  update end---------------------------------------------------------------*/
            UpsertModuleList.add(module);
            if (PSF_Item_Map.get(key).Module.ASI_CRM_End_Date__c != null) {
                if (!VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c,
                    PSF_Item_Map.get(key).Module.ASI_CRM_End_Date__c,
                    PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__c,
                    'For PSF (' + PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c + '), we meet following error in End Date: ')) {
                    Msg += '<br/>';
                    // msg= 'For PSF ('+PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date: <br/>'+msg;
                }
            }
            PSF_Item_Map.get(key).Module.ASI_CRM_CN_AC_Code__c = PSFActivityCodeId;
        }


        System.Savepoint pSavepoint = Database.setSavepoint();


        if (UpsertPermission) {
            //Module
            try {
                if (UpsertModuleList.size() > 0) {
                    upsert UpsertModuleList;
                    UpsertPermission = true;
                }
            } catch (Exception e) {
                Msg += 'Save Error : ' + e.getMessage() + '</br>';
                pageRef = null;
                Database.rollback(pSavepoint);
                UpsertPermission = false;
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_EditHeavyPaymentDetailCtrl class have Error  ' + Msg, 'ASI_CRM_CN_EditHeavyPaymentDetailCtrl', 'Save function failed!');
                return null;
            }

            //upsert/Delete Payment Line
            if (UpsertPermission) {
                pSavepoint = Database.setSavepoint();
                try {
                    if (PaymentLineDeleteList.size() > 0) {
                        DeleteTarget = Database.delete(PaymentLineDeleteList);
                        PaymentLineDeleteList.clear();
                    }
                    //Upsert Payment Line
                    if (UpsertBRSFList.size() > 0) {
                        UpsertTarget = Database.upsert(UpsertBRSFList);
                    }

                    //update header
                    if (PH.ASI_CRM_Total_Actual_Amount__c != 0) {
                        update PH;
                    }


                    if (!isQuickSave) {
                        pageRef = new PageReference('/' + PageId);
                        pageRef.setRedirect(true);
                    } else {
                        pageRef = new PageReference('/apex/ASI_CRM_CN_Edit_OffPR_DetailsPage?id=' + PageId + '&isEdit=1');
                        pageRef.setRedirect(true);
                    }

                } catch (Exception e) {
                    Msg += 'Save Error : ' + e.getMessage() + '</br>';

                    pageRef = null;
                    Database.rollback(pSavepoint);
                    UpsertPermission = false;
                    ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_EditHeavyPaymentDetailCtrl class have Error  ' + Msg, 'ASI_CRM_CN_EditHeavyPaymentDetailCtrl', 'Save function!');
                    return null;
                }
            }
        }


        return pageRef;
    }


    public List<ASI_TH_CRM_PaymentRequestLineItem__c> ValidationChecking() {
        List<ASI_TH_CRM_PaymentRequestLineItem__c> ReturnList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

        Decimal TotalCTDPayableAmount = 0.0;
        Decimal ApplicationPaymentAmount = 0.0;
        Decimal CurrentPaymentAmount = 0;
        Integer LineCount;

        //**********************************************PSF**********************************************
        for (String key : PSF_Item_Map.keySet()) {
            TotalCTDPayableAmount = 0.0;
            ApplicationPaymentAmount = 0.0;
            CurrentPaymentAmount = 0;
            LineCount = 0;
            //Looping the PSF Line
            interimData interimData = PSF_Item_Map.get(key);
            interimData.TotalIntake_Btl = 0;
            interimData.TotalIntake_Completion = 0;
            interimData.VolumeTarget = 0;

            String KPIBase = interimData.Module.ASI_CRM_CN_KPI_Base__c;
            String methodology = interimData.Module.ASI_CRM_Methodology__r.Name;
            String volumeBase = interimData.Module.ASI_CRM_Volume_Base__c;

            if (interimData.DetailLineMap.isEmpty()) {
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = 0;
                interimData.Module.ASI_CRM_Actual_Payment__c = 0;
                interimData.Module.ASI_CRM_End_Date__c = null;
                continue;
            }

            // If it is Volume Base and  By Sub-Brand, suggested payment amount needs revaluation because user may change the incentive per bottle
            if ((KPIBase == 'Volume base' && volumeBase == 'By Sub-Brand') || (KPIBase == 'Value base' && methodology == 'Rebate%' && volumeBase == 'By Sub-Brand')) {
                interimData.Module.ASI_CRM_Suggested_Payable_Amount__c = 0;
            }

            // Loop every Module
            for (String keyline : interimData.DetailLineMap.keySet()) {
                LineCount++;
                ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine = interimData.DetailLineMap.get(keyline);
                if (KPIBase == 'Volume base' && volumeBase == 'By Sub-Brand') {
                    if (PaymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c && PaymentLine.ASI_CRM_CN_Incentive_BT__c > PaymentLine.ASI_CRM_Max_Incentive__c) {
                        interimData.Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_Max_Incentive__c * PaymentLine.ASI_CRM_CN_Actual_Vol__c;
                    } else {
                        interimData.Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_CN_Incentive_BT__c * PaymentLine.ASI_CRM_CN_Actual_Vol__c;
                    }

                }
                if (KPIBase == 'Value base' && methodology == 'Rebate%' && volumeBase == 'By Sub-Brand') {
                    if (PaymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c && PaymentLine.ASI_CRM_CN_Rebate_Percent__c > PaymentLine.ASI_CRM_Max_Incentive__c) {
                        interimData.Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c * PaymentLine.ASI_CRM_Max_Incentive__c / 100;
                    } else {
                        interimData.Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_CTD_Actual_Purchase_Value__c * PaymentLine.ASI_CRM_CN_Rebate_Percent__c / 100;
                    }
                }
                ApplicationPaymentAmount += PaymentLine.ASI_CRM_CN_Total_Payable__c;


                ReturnList.add(PaymentLine);
            }
            if (interimData.TotalCompletionRatio < interimData.Module.ASI_CRM_CN_CTD_Minimal_Achievement__c) {
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = 0;
                interimData.Module.ASI_CRM_Adjustment__c = 100;
                interimData.Module.ASI_CRM_Suggested_Payable_Amount__c = interimData.Module.ASI_CRM_Historical_Paid_Amount__c;
            } else {
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = ApplicationPaymentAmount - interimData.Module.ASI_CRM_Historical_Paid_Amount__c;
                interimData.Module.ASI_CRM_Adjustment__c = ApplicationPaymentAmount != 0? (interimData.Module.ASI_CRM_Actual_Payment__c / ApplicationPaymentAmount) * 100 : 100;
            }


            PH.ASI_CRM_Total_Actual_Amount__c += interimData.Module.ASI_CRM_Actual_Payment__c != null? interimData.Module.ASI_CRM_Actual_Payment__c : 0 ;
            PH.ASI_CRM_Total_Variable_Amount__c += interimData.Module.ASI_CRM_Actual_Payment__c != null? interimData.Module.ASI_CRM_Actual_Payment__c : 0 ;
            CurrentPaymentAmount = interimData.Module.ASI_CRM_Actual_Payment__c + interimData.Module.ASI_CRM_Historical_Paid_Amount__c;


            if (CurrentPaymentAmount.setScale(2) > interimData.Module.ASI_CRM_Suggested_Payable_Amount__c.setScale(2)) {
                if (
                    String.isEmpty(interimData.Module.ASI_CRM_PSF_Overpayment_Reason__c) ||
                        (interimData.Module.ASI_CRM_PSF_Overpayment_Reason__c == '其他 - 需填写具体原因' && String.isEmpty(interimData.Module.ASI_CRM_Other_Comments__c))
                    ) {
                    ErrorHandling(Label.ASI_CRM_CN_PSF + ' (' + interimData.Module.ASI_CRM_Volume_Base__c + ') :' + Label.ASI_CRM_Input_reason_for_overpayment);
                }
            }


        }


        //**********************************************Variable Event Cost**********************************************
        TotalCTDPayableAmount = 0.0;
        ApplicationPaymentAmount = 0.0;
        LineCount = 0;

        for (interimData interimData : DisplayItemMap.values()) {
            String methodology = interimData.Module.ASI_CRM_Methodology__r.Name;
            CurrentPaymentAmount = 0;

            if (interimData.DetailLineMap.isEmpty()) {
                interimData.Module.ASI_CRM_Application_Payment_Amount__c = 0;
                interimData.Module.ASI_CRM_Actual_Payment__c = 0;
                interimData.Module.ASI_CRM_End_Date__c = null;
                continue;
            }

            interimData.Module.ASI_CRM_Actual_Payment__c = interimData.Module.ASI_CRM_Actual_Payment__c != null? interimData.Module.ASI_CRM_Actual_Payment__c : 0 ;
            interimData.Module.ASI_CRM_Historical_Paid_Amount__c = interimData.Module.ASI_CRM_Historical_Paid_Amount__c != null? interimData.Module.ASI_CRM_Historical_Paid_Amount__c : 0 ;

            Decimal actualPayment = interimData.Module.ASI_CRM_Actual_Payment__c;
            Decimal historicalPaidAmount = interimData.Module.ASI_CRM_Historical_Paid_Amount__c;


            for (ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine : interimData.DetailLineMap.values()) {
                LineCount++;

                TotalCTDPayableAmount += PaymentLine.ASI_CRM_CN_Total_Payable__c != null? PaymentLine.ASI_CRM_CN_Total_Payable__c : 0 ;

                ReturnList.add(PaymentLine);
            }


            ApplicationPaymentAmount = TotalCTDPayableAmount - historicalPaidAmount;
            interimData.Module.ASI_CRM_Application_Payment_Amount__c = ApplicationPaymentAmount;

            if (ApplicationPaymentAmount != 0) {
                interimData.Module.ASI_CRM_Adjustment__c = (actualPayment / ApplicationPaymentAmount) * 100;
            } else {
                interimData.Module.ASI_CRM_Adjustment__c = 100;
            }

            PH.ASI_CRM_Total_Actual_Amount__c += actualPayment;
            PH.ASI_CRM_Total_Variable_Amount__c += actualPayment;

            CurrentPaymentAmount += actualPayment;
            CurrentPaymentAmount += historicalPaidAmount;

            System.debug('actualPayment ' + actualPayment);
            System.debug('interimData.Module.ASI_CRM_Suggested_Payable_Amount__c ' + interimData.Module.ASI_CRM_Suggested_Payable_Amount__c);
            if (methodology == 'Others' && actualPayment > interimData.Module.ASI_CRM_Suggested_Payable_Amount__c || (methodology != 'Others' && CurrentPaymentAmount > interimData.Module.ASI_CRM_Suggested_Payable_Amount__c)) {
                if (
                    String.isEmpty(interimData.Module.ASI_CRM_VEC_Overpayment_Reason__c) ||
                        (interimData.Module.ASI_CRM_VEC_Overpayment_Reason__c == '其他 - 需填写具体原因' && String.isEmpty(interimData.Module.ASI_CRM_Other_Comments__c))
                    ) {
                    ErrorHandling(Label.ASI_CRM_CN_Display + ': ' + Label.ASI_CRM_Input_reason_for_overpayment);
                }
            }
        }


        //***********************************************Other Payment Line List***********************************************
        for (ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine : OtherPaymentLineList) {
            if (PaymentLine.ASI_TH_CRM_Amount__c == null) {
                PaymentLine.ASI_TH_CRM_Amount__c = 0;
            }
            if (PaymentLine.ASI_CRM_Historical_Paid_Amount__c == null) {
                PaymentLine.ASI_CRM_Historical_Paid_Amount__c = 0;
            }

            if (PaymentLine.ASI_TH_CRM_Amount__c > PaymentLine.ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Estimate_Amount__c - PaymentLine.ASI_CRM_Historical_Paid_Amount__c) {
                ErrorHandling(String.format(Label.ASI_CRM_CN_Other_Cost_Payment_Amt_Validation, new String[]{
                    PaymentLine.ASI_CRM_CN_Expense_Type__c
                }));
            }
            // 当Dolphin合同时，实付金额大于建议的应付金额，需要填写备注
            if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
                if (PaymentLine.ASI_TH_CRM_Amount__c > PaymentLine.ASI_CRM_Application_Payment_Amount__c.setScale(2) 
                    && String.isBlank(PaymentLine.ASI_CRM_CN_Comment__c)) {
                    ErrorHandling('Payment Amount of ' + PaymentLine.ASI_CRM_CN_Expense_Type__c+' '+Label.ASI_CRM_CN_OTHER_COST_AMOUNT_CHECK);
                }
            }

            PH.ASI_CRM_Total_Actual_Amount__c += PaymentLine.ASI_TH_CRM_Amount__c;
            ReturnList.add(PaymentLine);

        }

        //Total Amount checking
        if (PH.ASI_CRM_Total_Actual_Amount__c > PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c) {
            String tempStr = Label.ASI_CRM_Payee_Amount_checking;
            List<String> fillers = new String[]{
                PH.ASI_CRM_Total_Actual_Amount__c.format(), PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format()
            };
            ErrorHandling(String.format(tempStr, fillers));//付款金额>PO金额！付款金额：{0}  PO金额：{1} //ErrorHandling('付款金额>PO金额！付款金额：'+PH.ASI_CRM_Total_Actual_Amount__c.format()+'  PO金额：'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format());
        }

        RefreshAllData();
        return ReturnList;
    }


    public PageReference CancelProcess() {
        PageReference pageRef = null;

        UpsertPermission = true;
        pageRef = new PageReference('/' + PageId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    /**
     * From old code. For each payment line, do the following:
     * 1. Set ASI_CRM_Over_Incentive__c by comparing ASI_CRM_CN_Incentive_BT__c > ASI_CRM_Max_Incentive__c
     * 2. Null prevention for fields: ASI_CRM_CN_Incentive_BT__c, ASI_CRM_CN_Total_Payable__c, ASI_CRM_CN_Payable_Vol__c
     */
    public void RefreshAllData() {

        for (interimData interimData : PSF_Item_Map.values()) {
            for (ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : interimData.DetailLineMap.values()) {

                if (paymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c && paymentLine.ASI_CRM_CN_Incentive_BT__c != null && paymentLine.ASI_CRM_Max_Incentive__c != null) {
                    paymentLine.ASI_CRM_Over_Incentive__c = paymentLine.ASI_CRM_CN_Incentive_BT__c > paymentLine.ASI_CRM_Max_Incentive__c;
                }
                paymentLine.ASI_CRM_CN_Incentive_BT__c = paymentLine.ASI_CRM_CN_Incentive_BT__c != null? paymentLine.ASI_CRM_CN_Incentive_BT__c : 0;
                paymentLine.ASI_CRM_CN_Total_Payable__c = paymentLine.ASI_CRM_CN_Total_Payable__c != null? paymentLine.ASI_CRM_CN_Total_Payable__c : 0;
                paymentLine.ASI_CRM_CN_Payable_Vol__c = paymentLine.ASI_CRM_CN_Payable_Vol__c != null? paymentLine.ASI_CRM_CN_Payable_Vol__c : 0;
            }
        }

        for (interimData interimData : DisplayItemMap.values()) {
            for (ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : interimData.DetailLineMap.values()) {
                if (paymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c && paymentLine.ASI_CRM_CN_Incentive_BT__c != null && paymentLine.ASI_CRM_Max_Incentive__c != null) {
                    paymentLine.ASI_CRM_Over_Incentive__c = paymentLine.ASI_CRM_CN_Incentive_BT__c > paymentLine.ASI_CRM_Max_Incentive__c;
                }
                paymentLine.ASI_CRM_CN_Incentive_BT__c = paymentLine.ASI_CRM_CN_Incentive_BT__c != null? paymentLine.ASI_CRM_CN_Incentive_BT__c : 0;
                paymentLine.ASI_CRM_CN_Total_Payable__c = paymentLine.ASI_CRM_CN_Total_Payable__c != null? paymentLine.ASI_CRM_CN_Total_Payable__c : 0;
                paymentLine.ASI_CRM_CN_Payable_Vol__c = paymentLine.ASI_CRM_CN_Payable_Vol__c != null? paymentLine.ASI_CRM_CN_Payable_Vol__c : 0;

            }
        }

    }


    // shared function
    public String newCounterCreatorLine() {

        String idNew;
        if (LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        } else {
            LINE_ITEM_NEWRECORD_COUNTER += 1;
        }

        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;

        if (LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER / 10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }

        idNew = zParser + String.valueOf(oneDigitCounter);
        return idNew;

    }


    public String NameSortingASC(Decimal strSeq) {
        if (strSeq == 0) {
            strSeq = 9;
        }
        String returnString;
        if (strSeq != null) {
            if (strSeq < 10) {
                returnString = String.valueOf(strSeq);
            } else if (strSeq > 9 && strSeq < 100) {
                returnString = String.valueOf(strSeq);
            } else if (strSeq > 99 && strSeq < 1000) {
                returnString = String.valueOf(strSeq);
            } else if (strSeq > 999 && strSeq < 10000) {
                returnString = String.valueOf(strSeq);
            }
        } else {
            returnString = '0';
        }
        return returnString;
    }


    public Boolean VolumeDateValidationChecking(Date VolumeStartDate, Date VolumeEndDate, String ParentModuleId, String ErrorInfo) {

        Boolean ReturnFlag = true; //checking the start day
        String DisplayErrorMsg = ErrorInfo;
        if (VolumeEndDate == null) {
            DisplayErrorMsg += 'Please input the end date.请输入结束日期。<br/>';
            UpsertPermission = false;
            Msg += DisplayErrorMsg;

            return false;
        }
        if (String.isNotEmpty(ParentModuleId)) {
            for (ASI_CRM_Module__c HistoricalModule : HistoricalModuleList) {
                if (HistoricalModule.ASI_CRM_Parent_Module__c == ParentModuleId) {
                    if (HistoricalModule.ASI_CRM_End_Date__c != null && HistoricalModule.ASI_CRM_End_Date__c > VolumeEndDate) {
                        DisplayErrorMsg += 'End date earlier than last payment End Date. 结束日期不能早于最新的付款的结束日期。<br/>';
                        ReturnFlag = false;
                    }
                }
            }
        }

        if (!ASI_CRM_DateUtilClass.isStartOfMonth(VolumeStartDate)) {
            Msg += 'Start Day should be the first day of month.<br/>';
            ReturnFlag = false;
        }
        //checking end day
        if (!ASI_CRM_DateUtilClass.isEndOfMonth(VolumeEndDate)) {// Label.ASI_CRM_CN_PO_End_Date_Validation+
            DisplayErrorMsg += Label.ASI_CRM_CN_PO_End_Date_Validation + '<br/>';//End Date should be the last day of the month .
            ReturnFlag = false;
        }

        if (PH.ASI_CRM_CN_PO_End_Date__c < VolumeEndDate || VolumeEndDate < PH.ASI_CRM_CN_PO_Start_Date__c) {
            DisplayErrorMsg += Label.ASI_CRM_CN_End_Date_within_PO_period + '<br/>';//End Date should be within PO period
            ReturnFlag = false;
        }
        ASI_CRM_CN_HeavyContractUtilitiesClass.ReturnResult checkingResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(VolumeStartDate, VolumeEndDate);

        if (!checkingResult.Process) {
            ReturnFlag = checkingResult.Process;
            DisplayErrorMsg += checkingResult.Msg;
        }


        if (ReturnFlag == false) {
            UpsertPermission = false;
            Msg += DisplayErrorMsg;
        }

        return ReturnFlag;
    }

    public List<SelectOption> getPSFOverpaymentReasons() {
        List<String> options = new List<String>{
            '支付合同销量目标外品牌', '系统计算sales value的价格与实际计算合同奖励的二批出货价有差异', '实际付款按照SKU计算', '产品间加价率不一致', 'CTD达成率低于合同要求，申请按实际销量支付','其他 - 需填写具体原因'
        };
        List<SelectOption> selectOptions = new List<SelectOption>{
            new SelectOption('', '-- 请选择 --')
        };
        for (String str : options) {
            selectOptions.add(new SelectOption(str, str));
        }
        return selectOptions;
    }

    public List<SelectOption> getDisplayOverpaymentReasons() {
        List<String> options = new List<String>{
            '首付款，事后根据销量追溯', '其他 - 需填写具体原因'
        };
        List<SelectOption> selectOptions = new List<SelectOption>{
            new SelectOption('', '-- 请选择 --')
        };
        for (String str : options) {
            selectOptions.add(new SelectOption(str, str));
        }
        return selectOptions;
    }

    //*******************************************************************************************************
    // Data Retrieval Function
    // ********************************************************************************************************
    public List<ASI_CRM_Subbrand_Volume__c> RetrieveSubBrandVolume(Date startDate, Date endDate, Set<Id> outletIds) {
        List<ASI_CRM_Subbrand_Volume__c> returnList = new List<ASI_CRM_Subbrand_Volume__c>();
        if (startDate == null || endDate == null) {
            return returnList;
        }
        startDate = startDate.toStartOfMonth();
        endDate = endDate.toStartOfMonth().addMonths(1).addDays(-1);
        String subBrandVolumeDeveloperName = '';
        String contractId = PH.ASI_TH_CRM_Contract__c;
        if (outletIds.size() <= ASI_CRM_CN_OffContractUtilitiesClass.outletThreshold()) {
            subBrandVolumeDeveloperName = 'ASI_CRM_CN_WS_Outlet_Sub_brand_Volume';
        } else {
            subBrandVolumeDeveloperName = 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data';
        }
        returnList = [
            SELECT
                ASI_CRM_Account__c,
                ASI_CRM_Actual_Vol__c,
                ASI_CRM_CN_Payment_Request_Line_Item__c,
                ASI_CRM_Empty_Bottle_Btl__c,
                ASI_CRM_End_Date__c,
                ASI_CRM_PR_Direct__c,
                ASI_CRM_PR_Direct_CR12__c,
                ASI_CRM_PR_Direct_STD_Billing__c,
                ASI_CRM_Sub_Brand_Grade_Incentive__c,
                ASI_CRM_Subbrand__c,
                ASI_CRM_Subbrand__r.Name,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,
                ASI_CRM_T1_Depletion_BTL__c,
                ASI_CRM_T1_Depletion_CR12__c,
                ASI_CRM_T1_Depletion_STD_Billing__c,
                ASI_CRM_T2_Depletion_CR12__c,
                ASI_CRM_T2_Depletion_STD_Billing__c,
                ASI_CRM_CN_Intake_GS_T1_Price__c,
                ASI_CRM_POS_Std_Billing__c,
                ASI_CRM_POS_CR12__c,
                ASI_CRM_Offtake_GS__c,
                ASI_CRM_POS_GS__c,
                ASI_CRM_Green_ORS_Std_Billing__c,
                ASI_CRM_Green_ORS_CR12__c,
                ASI_CRM_Green_ORS_GS__c,
                ASI_CRM_Empty_Bottle_CR12__c,
                ASI_CRM_Empty_Bottle_Std_Billing__c,
                ASI_CRM_Empty_Bottle_GS__c
            FROM ASI_CRM_Subbrand_Volume__c
            WHERE (ASI_CRM_Account__c IN :outletIds OR ASI_CRM_CN_Contract__c = :contractId)
            AND ASI_CRM_End_Date__c <= :endDate
            AND ASI_CRM_End_Date__c >= :startDate
            AND ASI_CRM_CN_Competitor_Sub_brand__c = FALSE
            AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
            AND RecordType.DeveloperName = :subBrandVolumeDeveloperName
            ORDER BY ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c
        ];
        System.debug(outletIds);
        System.debug(returnList.size());
        System.debug(returnList);
        return returnList;
    }

    //*******************************************************************************************************
    //* @description custom class for Line Detail
    // ********************************************************************************************************
    public class interimData {
        public ASI_CRM_Module__c Module { set; get; }
        public Boolean HaveRefresh { set; get; }
        public String MethodologyValue { set; get; }

        public Decimal TotalCTDIntakeStdBottle { set; get; }{
            TotalCTDIntakeStdBottle = 0;
        } //Display in the view page
        public Decimal TotalCTDIntakeCR12 { set; get; }{
            TotalCTDIntakeCR12 = 0;
        }//Display in the view page
        public Decimal TotalCTDPurchaseValue { set; get; }{
            TotalCTDPurchaseValue = 0;
        }//Display in the view page
        public Decimal TotalCTDPurchaseValueRef { set; get; }{
            TotalCTDPurchaseValueRef = 0;
        }//Display in the view page
        public Decimal TotalContractTotalAmount { set; get; }{
            TotalContractTotalAmount = 0;
        }//Display in the view page
        public Decimal TotalContractTargetStdBottle { set; get; }{
            TotalContractTargetStdBottle = 0;
        }//Display in the view page
        public Decimal TotalContractTargetCR12 { set; get; }{
            TotalContractTargetCR12 = 0;
        }//Display in the view page
        public Decimal TotalEstimateTargetCR12 { set; get; }{
            TotalEstimateTargetCR12 = 0;
        }//Display in the view page
        public Decimal TotalContractTargetValue { set; get; }{
            TotalContractTargetValue = 0;
        }//Display in the view page
        public Decimal TotalEstimateTargetValue { set; get; }{
            TotalEstimateTargetValue = 0;
        }//Display in the view page

        public Decimal TotalIntake { set; get; }{
            TotalIntake = 0;
        } //Display in the view page

        public Decimal TotalIntake_Btl { set; get; }{
            TotalIntake_Btl = 0;
        } // for calculating BC Rate

        public Decimal TotalIntake_Completion { set; get; }{
            TotalIntake_Completion = 0;
        }

        public Decimal VolumeTarget { set; get; }{
            VolumeTarget = 0;
        }

        public Decimal TotalCompletionRatio { set; get; }{
            TotalCompletionRatio = 0;
        }
        public Decimal TotalCTDPayableAmount { set; get; } {
            TotalCTDPayableAmount = 0.0;
        }
        public Decimal CTDPurchaseValue { set; get; } {
            CTDPurchaseValue = 0.0;
        }
        public Decimal ValueTarget { set; get; } {
            ValueTarget = 0.0;
        }
        public Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> DetailLineMap { set; get; }

        public interimData() {
            Module = new ASI_CRM_Module__c();
            MethodologyValue = '';
            DetailLineMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            this.HaveRefresh = true;
        }
        public interimData(Boolean ClickRefresh) {
            Module = new ASI_CRM_Module__c();
            MethodologyValue = '';
            DetailLineMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            HaveRefresh = ClickRefresh;
        }

        public interimData(ASI_CRM_Module__c ModuleInput) {
            Module = ModuleInput;
            MethodologyValue = ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            this.HaveRefresh = true;
        }

        public interimData(ASI_CRM_Module__c ModuleInput, Boolean ClickRefresh) {
            Module = ModuleInput;
            MethodologyValue = ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            this.HaveRefresh = ClickRefresh;
        }
    }
    
    //20191108:AM@introv - copy "Tax Calculation" button (ASI_CRM_CN_Payment_Header_Controller [class] + ASI_CRM_CN_Payment_Header_Page [vf page])
    Public pageReference reDirectToTaxSavingPage(){
        return new pageReference('/apex/ASI_CRM_CN_Payment_Tax_Saving_Page?id=' + PageId);
    }
    
}