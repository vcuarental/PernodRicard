/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_EditContractOffDetailCtrl
 * Description: Apex class for ASI_CRM_CN_EditContractOffDetailCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-08-22       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_EditContractOffDetailCtrl {
    public ASI_TH_CRM_Contract__c ContractSelected { set; get; }

    public List<ASI_CRM_Contract_Cost__c> LFixCost {set;get;} {LFixCost = new List<ASI_CRM_Contract_Cost__c>();}

    //BRSF
    public interimData BRSFItemMap { set; get; } {
        BRSFItemMap = new interimData();
    }
    public String PSF_Item_MapJSON { set; get; }
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFDeleteList { get; set; }{
        BRSFDeleteList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
    }
    public List<ASI_CRM_Module__c> ModuleDeleteList { get; set; }{
        ModuleDeleteList = new List<ASI_CRM_Module__c>();
    }
    public Boolean BRSFIsVolumeBase { set; get; }
    public Boolean BRSFIsValueBase { set; get; }
    public Decimal maxMargin { set; get; }

    //PSF
    public Map<String, interimData> PSF_Item_Map {set;get;} {PSF_Item_Map= new Map<String, interimData>();}
    public Map<String, interimDataDto> PSF_Item_MapDto {set;get;} {PSF_Item_MapDto= new Map<String, interimDataDto>();}

    public Integer SizeOfPSFMap { get {return PSF_Item_Map.size();} }


    //Display Listing
    public Map<String, interimData> DisplayListingItemMap {set;get;} {DisplayListingItemMap= new Map<String, interimData>();}
    public Decimal displayContractTotalSum { set; get; }
    public Decimal displayEstimateTotalSum { set; get; }


    public Map<Id, ASI_CRM_Methodology__c> MethodologyById { set; get; }
    public String MethodologyByIdJSON { set; get; }

    //@description : new line count
    public static String LINE_ITEM_NEWRECORD_PREFIX { get {return 'z';} }
    public Integer LINE_ITEM_NEWRECORD_COUNTER { get; set; }
    public Boolean ShowWarning  {get;set;} {ShowWarning= false;}
    public String BRSFActivityCodeId  {get;set;}{BRSFActivityCodeId='';}
    public String PSFActivityCodeId  {get;set;}{PSFActivityCodeId='';}
    public String DisplayActivityCodeId  {get;set;}{DisplayActivityCodeId='';}


    public List<SelectOption> VolumeBasePickList {set;get;} {VolumeBasePickList = new List<SelectOption>();}
    public List<SelectOption> displayMethodologyOptions { set; get; }

    public String msg {get;set;} {msg='';}
    public Boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public Boolean IsGroupContract {get;set;}{IsGroupContract=false;}
    public Boolean isPOModi { get; set; }
    public Boolean isOpenForPOSData { get; set; }

    public Boolean isGroupPo { get; set; }
    public Boolean isChildPo { get; set; }


    public Decimal DiffMonth {get;set;} {DiffMonth=0;}

    public List<ASI_CRM_Methodology__c> defaultMethodologies { get; set; }


    //Save Historical Estimate Total Amount
    public Decimal HistoricalBRSFEstimateTotal {set;get;} {HistoricalBRSFEstimateTotal=0;}


    public Integer WarningTimes {get;set;} {WarningTimes=0;}
    public String WarningMsg {get;set;} {WarningMsg='';}

    public Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  {get;set;}{SubBrandGradeMap= new Map<String, ASI_CRM_Sub_Brand_Grade__c>();}

    public Map<String, ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_Item_Map {set;get;}{CoveredOutlet_Item_Map= new Map<String, ASI_CRM_CN_Covered_Outlet__c>();}

    public String PageId { set; get; }

    public Boolean showCN { set; get; }

    public String BRSFLineRecordTypeId { set; get; }

    public Boolean IsDolphinContract{get;set;}
    public ASI_CRM_CN_CustomSetting__c customSetting{get;set;}
    public Decimal TotalContractPurchase{get;set;}{TotalContractPurchase = 0;}
    public Decimal TotalEstimatePurchase{get;set;}{TotalEstimatePurchase = 0;}
    public Decimal rebatePercent{get;set;}{rebatePercent = 0;}
    public Boolean IsOverContractGuideline{get;set;}{IsOverContractGuideline=false;}
    public Boolean IsOverEstGuideline{get;set;}{IsOverEstGuideline=false;}
    public Decimal ContractGuidelinePercent{get;set;}{ContractGuidelinePercent=0;}
    public Decimal EstGuidelinePercent{get;set;}{EstGuidelinePercent=0;}


    public ASI_CRM_CN_EditContractOffDetailCtrl(ApexPages.StandardController controller) {
        customSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        showCN = UserInfo.getLanguage() == 'zh_CN';

        this.ContractSelected = (ASI_TH_CRM_Contract__c) controller.getRecord();
        if (this.ContractSelected != null)
            PageId = ContractSelected.Id;

        this.BRSFLineRecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');


        this.ContractSelected = [
            SELECT
                ASI_CRM_CN_Bottle_Collection_Rate__c,
                ASI_CRM_CN_Budget_LE__c,
                ASI_CRM_CN_Business_License__c,
                ASI_CRM_CN_Contract_Upload__c,
                ASI_CRM_CN_Currency__c,
                ASI_CRM_CN_Description__c,
                ASI_CRM_CN_Effective_Date__c,
                ASI_CRM_CN_Exchange_Rate__c,
                ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                ASI_CRM_CN_Expected_Display_Est_Total__c,
                ASI_CRM_CN_Expected_PSF_Est_Total__c,
                ASI_CRM_CN_Expected_V0_Display_Est_Total__c,
                ASI_CRM_CN_Group_Contract__c,
                ASI_CRM_CN_Group_Contract__r.Name,
                ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_BRSF_Total_Con_Monthly_Qty__c,
                ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_BRSF_Total_Est_Monthly_Qty__c,
                ASI_CRM_CN_Group_Contract__r.ASI_CRM_Contract_Total_Dummy__c,
                ASI_CRM_CN_Group_Contract__r.ASI_CRM_Est_Total_Dummy__c,
                ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Last_PO_version__c,
                ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
                ASI_CRM_CN_Last_Rejected_Date__c,
                ASI_CRM_CN_Last_Submitted_Date__c,
                ASI_CRM_CN_National_Group_Contract__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Outlet_WS__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Open_for_POS_Data__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                ASI_CRM_CN_PO_End_Date__c,
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
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_V0_Display_Contract_Total__c,
                ASI_CRM_CN_V00_No_of_Month__c,
                ASI_CRM_CN_Vol_Budget_LE__c,
                ASI_CRM_Display_Estimate_Adjustment_Amt__c,
                ASI_CRM_EVC_Cost_Estimate_Total__c,
                ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                ASI_CRM_National_Group__c,
                ASI_CRM_National_Group__r.Name,
                ASI_CRM_New_FY_PO__c,
                ASI_CRM_PO_Channel__c,
                ASI_CRM_PO_City__c,
                ASI_CRM_PO_City__r.Name,
                ASI_CRM_PO_Province__c,
                ASI_CRM_Prev_Version_Display_Est_Total__c,
                ASI_CRM_Previous_Version_PSF_Est_Total__c,
                ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
                ASI_CRM_V0_PSF_Contract_Total__c,
                ASI_CRM_Volume_Option__c,
                ASI_TH_CRM_Promotion_Type__c,
                CreatedDate,
                Id,ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Contract_Classification__c,
                LastModifiedDate,
                Name,ASI_CRM_CN_Total_RContract_Amount__c,
                RecordTypeId, (SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c FROM ASI_TH_CRM_PaymentRequests_Contract__r)
            FROM ASI_TH_CRM_Contract__c
            WHERE Id = :PageId
        ];
        init();
    }


    public void init() {

        IsDolphinContract = ContractSelected.ASI_CRM_CN_Is_Dolphin__c;

        System.debug(LoggingLevel.INFO, '*** IsDolphinContract: ' + IsDolphinContract);

        isPOModi = ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0';

        if (isPOModi && ContractSelected.ASI_CRM_CN_V0_0_PO_version__r != null) {
            //current version of month compare with V0.0
            DiffMonth = ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c - ContractSelected.ASI_CRM_CN_No_of_Months__c;
        }
        isGroupPo = ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Group PO';
        isChildPo = ContractSelected.ASI_CRM_CN_Group_Contract__c != null;

        isOpenForPOSData = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_Open_for_POS_Data__c;
        ShowWarning = false;

        WarningTimes = 0;
        if (ContractSelected.ASI_CRM_CN_Group_Contract__c != null) {
            IsGroupContract = true;
        }
        FindingDefaultValue();
        //Contract Cost
        if(IsDolphinContract){
            LFixCost = [SELECT Id, Name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c,ASI_CRM_CN_Contract_Amount_Rate__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Estimate_Amount_Rate__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :PageId ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC];
        }else{
            LFixCost = [SELECT Id, Name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c,ASI_CRM_CN_Contract_Amount_Rate__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Estimate_Amount_Rate__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :PageId AND ASI_CRM_CN_Cost_Type__c = 'Fixed' ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC];
        }

        System.debug(LoggingLevel.INFO, '*** LFixCost: ' + LFixCost);

        for(ASI_CRM_Contract_Cost__c line : LFixCost){
            if(line.ASI_CRM_CN_Contract_Amount__c == null){
                line.ASI_CRM_CN_Contract_Amount__c = 0;
            }
            if(line.ASI_CRM_CN_Estimate_Amount__c == null){
                line.ASI_CRM_CN_Estimate_Amount__c = 0;
            }
        }

        initMethodologyMap();
        initSetTotalMarkup();


        //Module
        Map<String, ASI_CRM_Module__c> ModuleMap = new Map<String, ASI_CRM_Module__c>([
            SELECT
                ASI_CRM_CN_AC_Code__c,
                ASI_CRM_CN_Criteria__c,
                ASI_CRM_CN_Is_Capped__c,
                ASI_CRM_CN_KPI_Base__c,
                ASI_CRM_CN_Minimal_Achievement__c,
                ASI_CRM_CN_Total_Markup__c,
                ASI_CRM_CN_Contract_Volume_Base__c,
                ASI_CRM_CN_Volume_Value_Base__c,
                ASI_CRM_Created_PO_Version__c,
                ASI_CRM_Group_Contract__c,
                ASI_CRM_Line_Type__c,
                ASI_CRM_Methodology__c,
                ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Methodology__r.Name,
                ASI_CRM_Reason_NCD_Volume_Base__c,
                ASI_CRM_Reason_Not_NCD_Methodology__c,
                ASI_CRM_Remark__c,
                ASI_CRM_Remark_Display__c,
                ASI_CRM_Remark_Options__c,
                ASI_CRM_Unit__c,
                ASI_CRM_Volume_Base__c,
                Id
            FROM ASI_CRM_Module__c
            WHERE ASI_CRM_Contract__c = :PageId
        ]);

        for (ASI_CRM_Module__c module : ModuleMap.values()) {
            if (module.ASI_CRM_Line_Type__c == 'BRSF') {
                BRSFItemMap.Module = module;
            }
        }

        //SubBrandGradeMap: Sub Brand name + Region + Commercial Team,  ASI_CRM_Sub_Brand_Grade__c
        SubBrandGradeMap = new Map<String, ASI_CRM_Sub_Brand_Grade__c>();

        for (ASI_CRM_Sub_Brand_Grade__c sbg : ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c)) {
            if (sbg.ASI_CRM_CN_City_Tier__c != null) {
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c + ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            } else {
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
            }

        }


        //*****************Looping  BRSF/PSF Line
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine : [
            SELECT
                ASI_CRM_Adjustment_Line__c,
                ASI_CRM_CN_Activity_Code__c,
                ASI_CRM_CN_Contract__c,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Contract_Purchase_Value__c,
                ASI_CRM_CN_Contract_Total__c,
                ASI_CRM_CN_Contract_Total_Dummy__c,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Est_Monthly_Qty__c,
                ASI_CRM_CN_Est_Total__c,
                ASI_CRM_CN_Est_Total_Dummy__c,
                ASI_CRM_CN_Estimate_Purchase_Value__c,
                ASI_CRM_CN_GS_Per_9L__c,
                ASI_CRM_CN_Max_Purchase_Target__c,
                ASI_CRM_CN_Min_Purchase_Target__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Rebate__c,
                ASI_CRM_CN_Rebate_Percent__c,
                ASI_CRM_CN_Max_Rebate_Percent__c,
                ASI_CRM_CN_Sub_Brand__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Target__c,
                ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                ASI_CRM_Contract_Total_QTY_std_Btl__c,
                ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                ASI_CRM_Est_Total_QTY_std_Btl__c,
                ASI_CRM_Key_Sub_brand__c,
                ASI_CRM_Line_Name__c,
                ASI_CRM_Max_Incentive__c,
                ASI_CRM_Module__c,
                ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c,
                ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
                ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
                ASI_CRM_Product_Category__c,
                ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_Product_Category__r.Name,
                ASI_CRM_Product_Category_Name__c,
                ASI_CRM_Sub_Brand_CR12_Factor__c,
                ASI_CRM_Sub_Brand_Grade__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_Sub_Brand_Grade__r.Name,
                ASI_CRM_Sub_Brand_Grade_Name__c,
                ASI_CRM_Type__c,
                ASI_CRM_Volume_Base__c,
                Id
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :PageId
        ]) {
            if (BRSFLine.ASI_CRM_CN_Sub_Brand__c != null && BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null) {
                BRSFLine.ASI_CRM_Sub_Brand_Grade__c = BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            }
            if (BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null) {
                BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
            }
            if (BRSFLine.ASI_CRM_CN_GS_Per_9L__c == null) {
                BRSFLine.ASI_CRM_CN_GS_Per_9L__c = 1;
            }
            if (BRSFLine.ASI_CRM_Type__c == 'BRSF') {
                BRSFItemMap.Module = ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                BRSFLine.ASI_CRM_Line_Name__c = BRSFLine.ASI_CRM_Sub_Brand_Grade__c != null? BRSFLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c : BRSFLine.ASI_CRM_Sub_Brand_Grade__r.Name;
                BRSFItemMap.updateMethodologyDisplay(showCN);

                if (!BRSFLine.ASI_CRM_Adjustment_Line__c) {
                    HistoricalBRSFEstimateTotal += BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c != null? BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }

                BRSFItemMap.DetailLineMap.put(BRSFLine.Id, BRSFLine);
            }

            if (BRSFLine.ASI_CRM_Type__c == 'PSF') {
                if (BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                    BRSFLine.ASI_CRM_Line_Name__c = BRSFLine.ASI_CRM_Sub_Brand_Grade__c != null? BRSFLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c : BRSFLine.ASI_CRM_Sub_Brand_Grade__r.Name;
                }
                String LineKey = BRSFLine.Id;
                if (BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c == 'By Category') {
                    BRSFLine.ASI_CRM_Line_Name__c = BRSFLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? BRSFLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : BRSFLine.ASI_CRM_Product_Category__r.Name;
                    LineKey = ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(BRSFLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) + LineKey;
                }


                if (PSF_Item_Map.containsKey(BRSFLine.ASI_CRM_Module__c)) {
                    PSF_Item_Map.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey, BRSFLine);
                } else {
                    if (ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)) {
                        interimData TempData = new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
                        TempData.isCreatedInCurrentVersion = TempData.Module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;
                        // TODO calculate too much times. Use a mapping to store picklist relationship
                        TempData.MethodologyPicklist = genMethodologyPicklist(BRSFLine.ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c, 'PSF');
                        TempData.VolumeValueBasePickList = genPSFVolValBasePicklist(BRSFLine.ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c, BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c);

                        PSF_Item_Map.put(BRSFLine.ASI_CRM_Module__c, TempData);
                        PSF_Item_Map.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey, BRSFLine);
                        PSF_Item_Map.get(BRSFLine.ASI_CRM_Module__c).Module.ASI_CRM_Contract__c = PageId;
                        PSF_Item_Map.get(BRSFLine.ASI_CRM_Module__c).updateMethodologyDisplay(showCN);
                    }
                }

            }

            if (BRSFLine.ASI_CRM_Type__c == 'Display') {
                String LineKey = BRSFLine.Id;

                if (DisplayListingItemMap.containsKey(BRSFLine.ASI_CRM_Module__c)) {
                    DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey, BRSFLine);
                } else {
                    if (ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)) {
                        interimData TempData = new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
                        TempData.isCreatedInCurrentVersion = TempData.Module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;

                        DisplayListingItemMap.put(BRSFLine.ASI_CRM_Module__c, TempData);
                        DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey, BRSFLine);
                        DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).Module.ASI_CRM_Contract__c = PageId;
                        DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).updateMethodologyDisplay(showCN);
                    }
                }

            }

        }

        updatePSFItemMapDTO();

        if (BRSFItemMap.Module == null && !IsGroupContract) {
            BRSFItemMap.Module = new ASI_CRM_Module__c(
                ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Intake',
                ASI_CRM_Volume_Base__c = 'By Sub-Brand',
                ASI_CRM_Unit__c = 'Std. Btl.',
                ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c
            );
        }


        if (IsGroupContract) { // of this contract is Group Contract
            for (String ModuleKey : ModuleMap.keySet()) {
                ASI_CRM_Module__c Module = ModuleMap.get(ModuleKey);
                if (ModuleMap.get(ModuleKey).ASI_CRM_Line_Type__c == 'BRSF') {

                    BRSFItemMap.Module = Module;
                }
                if (ModuleMap.get(ModuleKey).ASI_CRM_Line_Type__c == 'PSF' && ModuleMap.get(ModuleKey).ASI_CRM_Group_Contract__c) {
                    if (!PSF_Item_Map.containsKey(ModuleKey)) {
                        PSF_Item_Map.put(ModuleKey, new interimData(Module, false));
                    }

                    if (showCN) {
                        PSF_Item_Map.get(ModuleKey).MethodologyDisplay = ModuleMap.get(ModuleKey).ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c;
                    } else {
                        PSF_Item_Map.get(ModuleKey).MethodologyDisplay = ModuleMap.get(ModuleKey).ASI_CRM_Methodology__r.Name;
                    }

                    PSF_Item_Map.get(ModuleKey).moduleReadOnly = true;
                }
            }

        }


        VolumeBasePickList = getPickListValue(ASI_CRM_Module__c.ASI_CRM_Volume_Base__c.getDescribe());


        // Covered Outlet
        CoveredOutlet_Item_Map = new Map<String, ASI_CRM_CN_Covered_Outlet__c>([
            SELECT Id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Suggested_Amount__c, ASI_CRM_CN_Target_Volume_Std_Btl__c, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.ASI_CRM_Account__c, ASI_CRM_CN_Allocated_Amount__c, ASI_CRM_CN_Check_All__c, ASI_CRM_CN_Selected_Covered_Outlet__c, ASI_CRM_CN_Target_Volume_9L__c, ASI_CRM_CN_Target_Value__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__c = :PageId
        ]);


        String volumeOrValue = BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c;
        System.debug(BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c);
        BRSFIsVolumeBase = volumeOrValue == 'Volume';
        BRSFIsValueBase = volumeOrValue == 'Value';
        displayMethodologyOptions = genMethodologyPicklist(volumeOrValue + ' base', 'Display');

        if(IsDolphinContract){
            reCalPurchaseValue();
        }

    }

    public void initMethodologyMap() {
        MethodologyById = new Map<Id, ASI_CRM_Methodology__c>(
        [
            SELECT Id,Name,ASI_CRM_CN_KPI_Base__c,ASI_CRM_Sequence__c,ASI_CRM_Type__c,ASI_CRM_Default__c,RecordType.DeveloperName,ASI_CRM_Chinese_Name__c,ASI_CRM_CN_Criteria__c,
            (SELECT Id,ASI_CRM_Region__c,ASI_CRM_Key_Principle__c,ASI_CRM_Region__r.Name,ASI_CRM_CN_New_Channel__c FROM ASI_CRM_Methodology_Assignment__r WHERE ASI_CRM_Key_Principle__c = TRUE AND ASI_CRM_Region__r.Name = :ContractSelected.ASI_CRM_CN_Region__c AND ASI_CRM_CN_New_Channel__c =: ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c)
            FROM ASI_CRM_Methodology__c
            WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Methodology_TOT_MOT_Contract'
        ]
        );
        MethodologyByIdJSON = JSON.serialize(MethodologyById);
    }

    public void initSetTotalMarkup() {
        String regionId = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c;
        String channelGroupId = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c;
        String recordType = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName;

        ASI_CN_Trade_Margin__c margin = ASI_CRM_CN_ContractOffUtilClass.getDefaultTradeMargin(regionId, channelGroupId, recordType);
        if (margin == null) {
            maxMargin = 99999;
            return ;
        }

        maxMargin = margin.ASI_CRM_CN_Max_Margin__c;
    }

    //*****************************init setup end********************

    //Retrieve default value
    public void FindingDefaultValue() {
        defaultMethodologies = [SELECT Id,ASI_CRM_Default__c,ASI_CRM_Chinese_Name__c,Name,ASI_CRM_Type__c,ASI_CRM_Sequence__c,ASI_CRM_CN_KPI_Base__c FROM ASI_CRM_Methodology__c WHERE ASI_CRM_Default__c = TRUE AND RecordType.DeveloperName = 'ASI_CRM_CN_Methodology_TOT_MOT_Contract'];

        BRSFActivityCodeId = '';
        PSFActivityCodeId = '';

        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList = [SELECT Id, Name,ASI_CRM_CN_BRSF_Activity_Code_Default__c,ASI_CRM_PSF_Activity_Code_Default__c,ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_VEC_Activity_Code_Defaul__c, ASI_CRM_CN_Channel__c, ASI_CRM_CN_Other_Cost_Payment_Request__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE ASI_CRM_CN_Promotion_Type__c = 'TOT/MOT Contract'];
        for (ASI_CRM_Contract_Cost_Setting__c ccs : ContractCostSettingList) {
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
    }


    //*************************************BRSF Part: Add/ Delete/ Clone function  ******************************

    /*
    if vol base, Contract Monthly QTY and Estimate Monthly QTY are editable
    if val base, Contract purchase value and Est. purchase value are editable
    */
    public void onBRSFVolValBaseChange() {
        String volumeOrValue = BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c;
        BRSFIsVolumeBase = volumeOrValue == 'Volume';
        BRSFIsValueBase = volumeOrValue == 'Value';

        if(!IsDolphinContract){
            //        deleteAllPSF and display
            for (String interimDataKey : PSF_Item_Map.keySet()) {
                for (String lineItemKey : PSF_Item_Map.get(interimDataKey).DetailLineMap.keySet()) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = PSF_Item_Map.get(interimDataKey).DetailLineMap.get(lineItemKey);
                    if (delTarget.Id != null) {
                        BRSFDeleteList.add(delTarget);
                    }
                    //remove PSF Line
                    PSF_Item_Map.get(interimDataKey).DetailLineMap.remove(lineItemKey);
                }

                if (PSF_Item_Map.get(interimDataKey).Module.Id != null) {
                    ModuleDeleteList.add(PSF_Item_Map.get(interimDataKey).Module);
                }
                //ModuleDeleteList
                //remove interimData
                PSF_Item_Map.remove(interimDataKey);
            }
            for (String interimDataKey : DisplayListingItemMap.keySet()) {
                for (String lineItemKey : DisplayListingItemMap.get(interimDataKey).DetailLineMap.keySet()) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = DisplayListingItemMap.get(interimDataKey).DetailLineMap.get(lineItemKey);
                    if (delTarget.Id != null) {
                        BRSFDeleteList.add(delTarget);
                    }
                    //remove PSF Line
                    DisplayListingItemMap.get(interimDataKey).DetailLineMap.remove(lineItemKey);
                }

                if (DisplayListingItemMap.get(interimDataKey).Module.Id != null) {
                    ModuleDeleteList.add(DisplayListingItemMap.get(interimDataKey).Module);
                }

                //remove interimData
                DisplayListingItemMap.remove(interimDataKey);
            }
        }
    }

    public void onTotalMarkupChange() {
        calculateBRSFLine(BRSFItemMap.DetailLineMap.values(), BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c == 'Volume'? 'ASI_CRM_CN_Contract_Monthly_Qty__c' : 'ASI_CRM_CN_Contract_Total_Dummy__c', false);
    }

    public void onBRSFContractMonthlyQtyChange() {
        String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        String change = ApexPages.currentPage().getParameters().get('change');
        calculateBRSFLine(new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>{BRSFItemMap.DetailLineMap.get(itemKey)}, change, true);
        CalBRSFAmount();
        //0924
        if(IsDolphinContract){
            //updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
            System.debug(LoggingLevel.INFO, '*** psf: ' + ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
            reCalPurchaseValue();
            if(!isPOModi){
                //refresh psf module
                /*Integer index = 1;
                for(interimData interimData : PSF_Item_Map.values()) {
                    if(index == 1){
                        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()){
                            lineItem.ASI_CRM_CN_Contract_Purchase_Value__c = TotalContractPurchase;
                            lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c = TotalEstimatePurchase;
                            lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Purchase_Value__c*lineItem.ASI_CRM_CN_Rebate_Percent__c/100;
                            lineItem.ASI_CRM_CN_Est_Total_Dummy__c =  lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c*lineItem.ASI_CRM_CN_Rebate_Percent__c/100;
                        }
                    }
                    index++;
                }*/
                //refresh other cost
                reCalOtherCost();
                //updatePSFItemMapDTO();
            }
        }
    }

    /**
     * Calculate BRSF line values.
     *
     * @param lines Array of BRSF Lines
     * @param change String of one of these values: 'ASI_CRM_CN_Contract_Monthly_Qty__c', 'ASI_CRM_CN_Est_Monthly_Qty__c', 'ASI_CRM_Est_Total_QTY_std_Btl__c' ,'ASI_CRM_CN_Contract_Total_Dummy__c', 'ASI_CRM_CN_Est_Total_Dummy__c'
     */
    public void calculateBRSFLine(List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lines, String change, Boolean overwriteEstimate) {
        Date strStartBGDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        Date strEndBGDate = ASI_CRM_DateUtilClass.getFiscalYearEndDate(ContractSelected.ASI_CRM_CN_PO_End_Date__c);
        Set<Id> subBrandIds = pluckIds(ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Sub_Brand__c, lines);

        System.debug(strStartBGDate);
        System.debug(strEndBGDate);
        System.debug(subBrandIds);

        if (subBrandIds.isEmpty()) {
            return;
        }

        // Get GS List
        List<ASI_CRM_CM_GS__c> gsList = [
            SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_YEAR__c,ASI_CRM_CN_Month__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c = :subBrandIds
            AND ASI_CRM_Region__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate
            AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate
            AND ASI_CRM_CN_Month__c = 6
            AND ASI_CRM_TYPE__c = 'Budget GS'
            AND ASI_CRM_CM_GS_per_9L__c != 0
            AND ASI_CRM_CM_GS_per_9L__c != NULL
            ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC
        ];

        Map<Id, ASI_CRM_CM_GS__c> gsBySubBrandIds = new Map<Id, ASI_CRM_CM_GS__c>();
        for (ASI_CRM_CM_GS__c gs : gsList) {
            // Since the latest GS is already there
            if (gsBySubBrandIds.containsKey(gs.ASI_CRM_PRODUCTCODE__c) || gs.ASI_CRM_CN_Month__c != 6) {
                continue;
            } else {
                System.debug('GS ID ' + gs.Id);
                System.debug(gs.ASI_CRM_PRODUCTCODE__c);
                System.debug('GS value ' + gs.ASI_CRM_CM_GS_per_9L__c);
                gsBySubBrandIds.put(gs.ASI_CRM_PRODUCTCODE__c, gs);
            }
        }

        // Get conversion factor 9L
        List<ASI_MFM_Sub_brand__c> subBrands = [SELECT Id,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c FROM ASI_MFM_Sub_brand__c WHERE Id = :subBrandIds];
        Map<Id, Decimal> conversionFactor9LBySubBrandIds = new Map<Id, Decimal>();
        for (ASI_MFM_Sub_brand__c subBrand : subBrands) {
            conversionFactor9LBySubBrandIds.put(subBrand.Id, subBrand.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c);
        }


        if (BRSFItemMap.Module.ASI_CRM_CN_Total_Markup__c == null) {
            BRSFItemMap.Module.ASI_CRM_CN_Total_Markup__c = 0;
        }
        Decimal markupPercent = BRSFItemMap.Module.ASI_CRM_CN_Total_Markup__c;

        Decimal vatPercent = ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_VAT__c != null? ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_VAT__c : 0;

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : lines) {
            ASI_CRM_CM_GS__c gs = gsBySubBrandIds.get(lineItem.ASI_CRM_CN_Sub_Brand__c);
            Decimal gsPer9L = gs == null? 1 : gs.ASI_CRM_CM_GS_per_9L__c;
            Decimal conversionFactor9L = conversionFactor9LBySubBrandIds.get(lineItem.ASI_CRM_CN_Sub_Brand__c);
            Boolean calculateEstimate = false;

            lineItem.ASI_CRM_Actual_CM_GS__c = gs == null? null : gs.Id;

            if (lineItem.get(change) == null) {
                lineItem.put(change, 0);
            }

            // Set Estimate Monthly QTY (Std. Bottle) + Contract Total Qty + Contract purchase value
            if (change == 'ASI_CRM_CN_Contract_Monthly_Qty__c') {
                if (overwriteEstimate) {
                    lineItem.ASI_CRM_CN_Est_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c;
                }
                lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = gsPer9L * conversionFactor9L / 9 * (1 + vatPercent / 100) * lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c * (1 + markupPercent / 100);
                calculateEstimate = true;
            }
            // Set Estimate Total Qty + Est. purchase value
            if (change == 'ASI_CRM_CN_Est_Monthly_Qty__c' || calculateEstimate) {
                lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = lineItem.ASI_CRM_CN_Est_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = gsPer9L * conversionFactor9L / 9 * (1 + vatPercent / 100) * lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c * (1 + markupPercent / 100);
            }
            // Set Estimate Total Qty + Est. purchase value
            if (change == 'ASI_CRM_Est_Total_QTY_std_Btl__c') {
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = gsPer9L * conversionFactor9L / 9 * (1 + vatPercent / 100) * lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c * (1 + markupPercent / 100);
            }
            // Set Contract Monthly QTY (Std. Bottle) +  Contract Total Qty + Est. purchase value
            if (change == 'ASI_CRM_CN_Contract_Total_Dummy__c') {
                if (overwriteEstimate) {
                    lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
                }
                lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c / (gsPer9L * conversionFactor9L / 9 * (1 + vatPercent/100) * (1 + markupPercent/100)) / ContractSelected.ASI_CRM_CN_No_of_Months__c;
                lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c.round(System.RoundingMode.FLOOR);

                lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;

                calculateEstimate = true;
            }
            // Set Estimate Total Qty + Estimate Monthly QTY (Std. Bottle)
            if (change == 'ASI_CRM_CN_Est_Total_Dummy__c' || calculateEstimate) {
                lineItem.ASI_CRM_CN_Est_Monthly_Qty__c = lineItem.ASI_CRM_CN_Est_Total_Dummy__c / (gsPer9L * conversionFactor9L / 9 * (1 + vatPercent/100) * (1 + markupPercent/100)) / ContractSelected.ASI_CRM_CN_No_of_Months__c;
                lineItem.ASI_CRM_CN_Est_Monthly_Qty__c = lineItem.ASI_CRM_CN_Est_Monthly_Qty__c.round(System.RoundingMode.FLOOR);

                lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = lineItem.ASI_CRM_CN_Est_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
            }
            if(IsDolphinContract){
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c.setScale(2, System.RoundingMode.HALF_UP);
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Est_Total_Dummy__c.setScale(2, System.RoundingMode.HALF_UP);
            }
        }
    }

    public void CalBRSFAmount() {
        //Assign Sub-Brand Grade
        Set<Id> BRSFSubBrandIdSet = new Set<Id>();
        for (String key : BRSFItemMap.DetailLineMap.keySet()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine = BRSFItemMap.DetailLineMap.get(key);
            if (BRSFLine.ASI_CRM_CN_Sub_Brand__c != null) {
                BRSFSubBrandIdSet.add(BRSFLine.ASI_CRM_CN_Sub_Brand__c);
            }
        }

        Map<String,ASI_MFM_Sub_brand__c> SubBrandMap= new Map<String,ASI_MFM_Sub_brand__c> ([SELECT Id,Name,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c
        FROM ASI_MFM_Sub_brand__c WHERE Id IN: BRSFSubBrandIdSet]);



        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BRSFItemMap.DetailLineMap.values()) {
            if (SubBrandMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)) {
                ASI_MFM_Sub_brand__c subBrand = SubBrandMap.get(line.ASI_CRM_CN_Sub_Brand__c);
                line.ASI_CRM_Line_Name__c = subBrand.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null? subBrand.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c : subBrand.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                line.ASI_CRM_Sub_Brand_Grade__c = subBrand.ASI_CRM_CN_Sub_brand_Grade__c;
            }
        }
    }


    /**
     * Copy Historical Contract V0.0.
     * A contract is regarded as historical if its end date is within half year of current contract start date
     */
    public void CopyHistoricalV0Contract() {
        SettingDefaultValue();
        Integer strDays = 365 / 12 * 6;
        Date strDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c - strDays;

        //Finding Old Promotion Types
        Set<String> oldPromotionTypes = new Set<String>{'Contract OFF'};

        ASI_TH_CRM_Contract__c PreviousCC = new ASI_TH_CRM_Contract__c();

        try {
            PreviousCC = [
                SELECT Id,ASI_CRM_CN_V0_0_PO_version__c
                FROM ASI_TH_CRM_Contract__c
                WHERE ASI_CRM_CN_Outlet_WS__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c
                AND ASI_CRM_CN_PO_End_Date__c != NULL AND ASI_CRM_CN_PO_Start_Date__c != NULL
                AND ASI_CRM_CN_PO_End_Date__c <= :ContractSelected.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_CN_PO_End_Date__c >= :strDate
                AND (ASI_TH_CRM_Promotion_Type__c = :ContractSelected.ASI_TH_CRM_Promotion_Type__c OR ASI_TH_CRM_Promotion_Type__c IN :oldPromotionTypes)
                AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived' OR ASI_CRM_CN_Status__c = 'Submitted')
                ORDER BY ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_PO_Version__c DESC
                LIMIT 1
            ];
        } catch (Exception e) {
            PreviousCC = new ASI_TH_CRM_Contract__c();
        }

        if (PreviousCC.Id == null) {
            ErrorHandling(Label.ASI_CRM_CN_Historical_V0_0_Contract_data);
            return;
        }

        //Found Historical V0.0
        String HistoricalV00ContractId = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c == null? PreviousCC.Id : PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;


        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> NewBRSFList = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(HistoricalV00ContractId, 'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' and ASI_CRM_Type__c=\'BRSF\' ');


        if (NewBRSFList.isEmpty()) {
            ErrorHandling(Label.ASI_CRM_CN_Historical_V0_0_Contract_data);//'Please note that no Historical V0.0 Contract data found.'
            return;
        }
        //remove
        for (String key : BRSFItemMap.DetailLineMap.keySet()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c DelTarget = BRSFItemMap.DetailLineMap.get(key);
            if (DelTarget.Id != null) {
                BRSFDeleteList.add(DelTarget);
            }
            BRSFItemMap.DetailLineMap.remove(key);
        }

        String ModuleId = '';
        if (BRSFItemMap.Module.Id != null) {
            ModuleId = BRSFItemMap.Module.Id;
        }

        Id BRSFLineRtId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');


        //Added---- Looping the BRSF Line
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : NewBRSFList) {
            ContractLine.Id = null;
            ContractLine.ASI_CRM_CN_External_ID__c = null;
            if (ModuleId != null) {
                try {
                    ContractLine.ASI_CRM_Module__c = ModuleId;
                } catch (Exception e) {

                }
            }

            // Round-down the Monthly quantity
            ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c.setScale(0);
            ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c.setScale(0);


            if (ContractLine.ASI_CRM_Sub_Brand_Grade__c == null) {
                ContractLine.ASI_CRM_Sub_Brand_Grade__c = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            }
            ContractLine.ASI_CRM_Line_Name__c = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c : ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;

            ContractLine.ASI_CRM_Type__c = 'BRSF';
            ContractLine.RecordTypeId = BRSFLineRtId;


            ContractLine.ASI_CRM_CN_Contract__c = ContractSelected.Id;
            BRSFItemMap.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), ContractLine);
        }
        String change = '';
        String volValBase = BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c;
        if (volValBase == 'Volume') {
            change = 'ASI_CRM_CN_Contract_Monthly_Qty__c';
        }
        if (volValBase == 'Value') {
            change = 'ASI_CRM_CN_Contract_Total_Dummy__c';
        }

        calculateBRSFLine(BRSFItemMap.DetailLineMap.values(), change, true);

        if(IsDolphinContract){
            reCalPurchaseValue();
            reCalOtherCost();
        }

    }

    public void BRSFClearAll() {
        SettingDefaultValue();
        for (String key : BRSFItemMap.DetailLineMap.keySet()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c DelTarget = BRSFItemMap.DetailLineMap.get(key);
            if (DelTarget.Id != null) {
                BRSFDeleteList.add(DelTarget);
            }
            BRSFItemMap.DetailLineMap.remove(key);
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> newLines = ASI_CRM_CN_ContractOffUtilClass.GeneratingVolumeValueTargetLine(ContractSelected);
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : newLines) {
            //avoid insert psf line in dolphin contract
            if(lineItem.ASI_CRM_Type__c == 'BRSF'){
                SetAmountToZero(lineItem);
                BRSFItemMap.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), lineItem);
            }
        }

        if(IsDolphinContract){
            reCalPurchaseValue();
            reCalOtherCost();
        }

        CalBRSFAmount();
    }

    /** Used in PO Modification. Will update all estimate values in PSF and Display
     *
     */
    public void BRSFRefreshAll() {
        // Refresh PSF lines from BRSF
        for (interimData interimData : PSF_Item_Map.values()) {
            Boolean isVolumeBase = interimData.Module.ASI_CRM_CN_KPI_Base__c == 'Volume Base';
            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine : BySubBrandRefresh(interimData.Module)) {
                        if (lineItem.ASI_CRM_CN_Sub_Brand__c == newLine.ASI_CRM_CN_Sub_Brand__c) {
                            lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = newLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                            if (isVolumeBase) {
                                //                                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = newLine.ASI_CRM_Est_Total_QTY_std_Btl__c * lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;

                            } else {
                                lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c = newLine.ASI_CRM_CN_Estimate_Purchase_Value__c;
                            }

                        }
                    }

                }

            }


            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Category') {
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine : ByProductCategoryGrouping('PSF').values()) {
                        if (lineItem.ASI_CRM_Product_Category__c == newLine.ASI_CRM_Product_Category__c) {
                            lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = newLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                            lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = newLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                            if (isVolumeBase) {
                                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c / (lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0? 1 : lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c) * lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                            } else {
                                lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c = newLine.ASI_CRM_CN_Estimate_Purchase_Value__c;
                            }
                        }
                    }

                }
            }

            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Total') {
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = ByTotalAmountGenerating('PSF');
                    lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = newLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                    lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = newLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                    if (isVolumeBase) {
                        lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c / (lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0? 1 : lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c) * lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                    } else {
                        lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c = newLine.ASI_CRM_CN_Estimate_Purchase_Value__c;
                    }
                }
            }

        }
        //         Calculate all lines. Above code only update the value from BRSF
        for (interimData interimData : PSF_Item_Map.values()) {
            String KPIBase = interimData.Module.ASI_CRM_CN_KPI_Base__c;
            String methodology = interimData.Module.ASI_CRM_Methodology__r.Name;
            Boolean isCapped = interimData.Module.ASI_CRM_CN_Is_Capped__c;
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                lineItem = calculatePSFLine(lineItem, KPIBase, methodology, isCapped);
            }
        }

        updatePSFItemMapDTO();
        for (interimData interimData : DisplayListingItemMap.values()) {
            Boolean isVolumeBase = interimData.Module.ASI_CRM_CN_KPI_Base__c == 'Volume Base';

            if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Total') {
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = ByTotalAmountGenerating('Display');
                    if (isVolumeBase) {
                        lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = newLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                        lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = newLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                        Decimal contractTotalCR12 = lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null || lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0? 1 : lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                        lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c / contractTotalCR12 * lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                    } else {
                        lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c = newLine.ASI_CRM_CN_Estimate_Purchase_Value__c;
                    }

                }
            }

        }
        if(isDolphinContract){
            //refresh other cost
            reCalOtherCost();
        }
        calculateContractSummary();
    }

    public void AddNew_BRSF() {


        Id BRSFLineRtId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        BRSFItemMap.Module.ASI_CRM_Line_Type__c = 'BRSF';
        BRSFItemMap.Module.ASI_CRM_Contract__c = PageId;
        BRSFItemMap.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), ASI_CRM_CN_ContractOffUtilClass.createBRSFLine('BRSF', BRSFLineRtId, PageId, BRSFItemMap.Module.Id, BRSFActivityCodeId));

        CalBRSFAmount();
    }


    //@description: action for removing BRSF Line
    //@param: Null
    //@return: Null
    public void Remove_BRSF() {
        SettingDefaultValue();
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_Line_ID');
        if (BRSFItemMap.DetailLineMap.containsKey(param_Id) && !BRSFItemMap.DetailLineMap.isEmpty()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = BRSFItemMap.DetailLineMap.get(param_Id);
            if (delTarget.Id != null) {
                BRSFDeleteList.add(delTarget);
            }
            BRSFItemMap.DetailLineMap.remove(param_Id);
        }
        CalBRSFAmount();
        if(isDolphinContract){
            reCalPurchaseValue();
            reCalOtherCost();
        }
    }

    //*****************************End of BRSF part  ********************************

    //**************Shared by PSF and Display ************
    public ASI_CRM_Module__c createModule(String lineType) {

        ASI_CRM_Module__c module = new ASI_CRM_Module__c(
            ASI_CRM_CN_KPI_Base__c = BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c == 'Volume'? 'Volume base' : 'Value base',
            ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
            ASI_CRM_Line_Type__c = lineType,
            ASI_CRM_CN_Minimal_Achievement__c = 0,
            ASI_CRM_Contract__c = PageId
        );

        List<SelectOption> methodologyPicklist = genMethodologyPicklist(module.ASI_CRM_CN_KPI_Base__c, module.ASI_CRM_Line_Type__c);
        List<SelectOption> volumeBasePicklist = genPSFVolValBasePicklist(module.ASI_CRM_CN_KPI_Base__c, module.ASI_CRM_Methodology__c);
        ASI_CRM_Methodology__c defaultMethodology;
        for (ASI_CRM_Methodology__c methodology : defaultMethodologies) {
            if (methodology.ASI_CRM_Type__c == module.ASI_CRM_Line_Type__c && methodology.ASI_CRM_CN_KPI_Base__c == module.ASI_CRM_CN_KPI_Base__c) {
                defaultMethodology = methodology;
            }
        }
        if (methodologyPicklist.size() > 0) {
            module.ASI_CRM_Methodology__c = methodologyPicklist[0].getValue();
            module.ASI_CRM_Methodology__r = MethodologyById.get(module.ASI_CRM_Methodology__c);
        }

        System.debug(methodologyPicklist.size());
        System.debug(module.ASI_CRM_Methodology__c);
        if (module.ASI_CRM_Line_Type__c == 'PSF') {
            if (module.ASI_CRM_Methodology__c != null) {
                module.ASI_CRM_Volume_Base__c = volumeBasePicklist.isEmpty()? '' : volumeBasePicklist[0].getValue();
                module.ASI_CRM_Unit__c = calculatePSFUnit(module.ASI_CRM_CN_KPI_Base__c, module.ASI_CRM_Methodology__c);
                module.ASI_CRM_CN_Criteria__c = module.ASI_CRM_Methodology__r.ASI_CRM_CN_Criteria__c;
            } else {
                module.ASI_CRM_Volume_Base__c = '';
                module.ASI_CRM_Unit__c = '';
                module.ASI_CRM_CN_Criteria__c = '';

            }
        }
        if (module.ASI_CRM_Line_Type__c == 'Display') {
            module = setModuleByMethodology(module, module.ASI_CRM_Methodology__c);
        }

        if(IsDolphinContract){
                module.ASI_CRM_CN_Volume_Value_Base__c = 'Value';
                module.ASI_CRM_CN_KPI_Base__c = 'Value base';
                module.ASI_CRM_Volume_Base__c = 'By Total';
                //module.ASI_CRM_Unit__c = 'RMB';
        }

        return module;
    }
    public interimData createInterimData(ASI_CRM_Module__c module) {
        interimData d = new interimData(module, false);

        if (module.ASI_CRM_Line_Type__c == 'PSF') {
            d.MethodologyPicklist = genMethodologyPicklist(module.ASI_CRM_CN_KPI_Base__c, module.ASI_CRM_Line_Type__c);
            if (d.MethodologyPicklist.isEmpty()) {
                d.VolumeValueBasePickList = new List<SelectOption>();
            } else {
                d.VolumeValueBasePickList = genPSFVolValBasePicklist(module.ASI_CRM_CN_KPI_Base__c, module.ASI_CRM_Methodology__c);
            }
        }

        d.updateMethodologyDisplay(showCN);
        d.showLineItems = false;
        return d;
    }

    public void refreshModule() {
        SettingDefaultValue();
        String paramId = ApexPages.currentPage().getParameters().get('PARAM_Line_ID');
        interimData dataInRefresh = PSF_Item_Map.containsKey(paramId)? PSF_Item_Map.get(paramId) : DisplayListingItemMap.get(paramId);

        if (dataInRefresh == null) {
            return;
        }

        if (dataInRefresh.Module.ASI_CRM_Methodology__c == null) {
            ErrorHandling(Label.ASI_CRM_CN_No_Methodology_Selected);
            return;
        }

        String lineType = PSF_Item_Map.containsKey(paramId)? 'PSF' : 'Display';
        if (lineType == 'PSF' && ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON') != null) {
            updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));

        }

        dataInRefresh.moduleReadOnly = true;
        dataInRefresh.showLineItems = true;
        ASI_CRM_Methodology__c methodology = MethodologyById.get(dataInRefresh.Module.ASI_CRM_Methodology__c);
        if (methodology != null) {
            dataInRefresh.MethodologyDisplay = showCN? methodology.ASI_CRM_Chinese_Name__c : methodology.Name;
        }
        for (String key : dataInRefresh.DetailLineMap.keySet()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = dataInRefresh.DetailLineMap.get(key);
            if (delTarget.Id != null) {
                BRSFDeleteList.add(delTarget);
            }
            if(IsDolphinContract){
                rebatePercent = dataInRefresh.DetailLineMap.get(key).ASI_CRM_CN_Rebate_Percent__c;
            }
            dataInRefresh.DetailLineMap.remove(key);
        }

        //**************By Sub-Brand**************
        if (dataInRefresh.Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BySubBrandRefresh(dataInRefresh.Module)) {
                dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), line);
            }

            CalPSFAmount(paramId);
            SettingDefaultValue();
        }


        //**************By Category**************
        if (dataInRefresh.Module.ASI_CRM_Volume_Base__c == 'By Category') {
            Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> CategoryGrouping = ByProductCategoryGrouping(lineType);
            for (String key : CategoryGrouping.keySet()) {
                dataInRefresh.DetailLineMap.put(CategoryGrouping.get(key).ASI_CRM_Map_Key__c + LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), CategoryGrouping.get(key));
            }
        }


        //************* By Total || By Other ***************
        if (dataInRefresh.Module.ASI_CRM_Volume_Base__c == 'By Total' || MethodologyById.get(dataInRefresh.Module.ASI_CRM_Methodology__c).Name == 'Others') {
            dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), ByTotalAmountGenerating(lineType));
        }


        //           Set contract value to zero if it is PO Modification
        if (isPOModi) {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : dataInRefresh.DetailLineMap.values()) {
                lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = 0;
                lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = 0;
                lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
                if (methodology.Name != 'Rebate%(By Ladder)' && methodology.Name != 'Rebate%(By Tax)') {
                    lineItem.ASI_CRM_CN_Contract_Purchase_Value__c = 0;
                }
            }
        }

        // Because refresh will add new lines to module, so need to update the contract summary
        calculateContractSummary();
        updatePSFItemMapDTO();

    }

    public void resetModule() {
        SettingDefaultValue();
        String paramId = ApexPages.currentPage().getParameters().get('PARAM_Line_ID');
        interimData dataInRefresh = PSF_Item_Map.containsKey(paramId)? PSF_Item_Map.get(paramId) : DisplayListingItemMap.get(paramId);

        if (dataInRefresh == null) {
            return;
        }

        if (dataInRefresh.Module.ASI_CRM_Methodology__c == null) {
            ErrorHandling(Label.ASI_CRM_CN_No_Methodology_Selected);
            return;
        }

        String lineType = PSF_Item_Map.containsKey(paramId)? 'PSF' : 'Display';
        if (lineType == 'PSF' && ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON') != null) {
            updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
        }

        for (String key : dataInRefresh.DetailLineMap.keySet()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = dataInRefresh.DetailLineMap.get(key);
            if (delTarget.Id != null) {
                BRSFDeleteList.add(delTarget);
            }
            dataInRefresh.DetailLineMap.remove(key);
        }
        if (dataInRefresh.Module.Id != null) {
            ModuleDeleteList.add(dataInRefresh.Module);
        }

        dataInRefresh.moduleReadOnly = false;
        dataInRefresh.showLineItems = false;
        dataInRefresh.Module = createModule(lineType);
        if (lineType == 'PSF') {
            dataInRefresh.MethodologyPicklist = genMethodologyPicklist(dataInRefresh.Module.ASI_CRM_CN_KPI_Base__c, dataInRefresh.Module.ASI_CRM_Line_Type__c);
            dataInRefresh.VolumeValueBasePickList = genPSFVolValBasePicklist(dataInRefresh.Module.ASI_CRM_CN_KPI_Base__c, dataInRefresh.MethodologyPicklist[0].getValue());
            dataInRefresh.Module.ASI_CRM_Unit__c = calculatePSFUnit(dataInRefresh.Module.ASI_CRM_CN_KPI_Base__c, dataInRefresh.MethodologyPicklist[0].getValue());
        }
        updatePSFItemMapDTO();

    }

    //*******************************PSF Part ****************************************


    public void updatePSFItemMapDTO() {
        for (String key : PSF_Item_Map.keySet()) {
            PSF_Item_MapDto.put(key, new interimDataDto(PSF_Item_Map.get(key)));
        }
        PSF_Item_MapJSON = JSON.serialize(PSF_Item_MapDto);
    }

    /**
     * Given a map of interimDataDto JSON string, update interimData
     *
     * @param jsonString JSON String which will be deserialized as Map<String, interimDataDto>
     */
    public void updatePSFItemMapByJSON(String jsonString) {
        Map<String, interimDataDto> PSF_Item_MapJSON = (Map<String, interimDataDto>) JSON.deserialize(jsonString, Map<String, interimDataDto>.class);
        for (String key : PSF_Item_Map.keySet()) {
            interimData interimData = PSF_Item_Map.get(key).copyFromDTO(PSF_Item_MapJSON.get(key));
            PSF_Item_Map.put(key, interimData);
        }
    }

    //Refresh Module based on Volume Base
    public void PSFAddModule() {
        updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
        SettingDefaultValue();
        //Construct Key Id
        String keyId = LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine();
        ASI_CRM_Module__c module = createModule('PSF');
        interimData d = createInterimData(module);

        PSF_Item_Map.put(keyId, d);


        updatePSFItemMapDTO();

    }

    public ASI_CRM_CN_Contract_BRSF_Line_Item__c calculatePSFLine(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem, String KPIBase, String methodology, Boolean isCapped) {
        if (lineItem == null || String.isEmpty(KPIBase) || String.isEmpty(methodology)) {
            return lineItem;
        }

        if (KPIBase == 'Volume base' && methodology == 'Per Incentive Btl') {
            lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c * lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
            lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c * lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;

        }


        Decimal contractPurchaseValue = lineItem.ASI_CRM_CN_Contract_Purchase_Value__c != null? lineItem.ASI_CRM_CN_Contract_Purchase_Value__c : 0;
        Decimal estimatePurchaseValue = lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c != null? lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c : 0;

        if (KPIBase == 'Value base' && methodology == 'Rebate%') {
            Decimal rebatePercent = lineItem.ASI_CRM_CN_Rebate_Percent__c == null? 0 : lineItem.ASI_CRM_CN_Rebate_Percent__c;
            lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = contractPurchaseValue * rebatePercent / 100;
            lineItem.ASI_CRM_CN_Est_Total_Dummy__c = estimatePurchaseValue * rebatePercent / 100;
        }
        if (KPIBase == 'Value base' && methodology == 'Reach X get Y') {
            Decimal target = lineItem.ASI_CRM_CN_Target__c;
            Decimal rebate = lineItem.ASI_CRM_CN_Rebate__c;
            if (target == null || target == 0 || rebate == null) {
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = 0;
                return lineItem;
            }

            lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = Integer.valueOf(contractPurchaseValue / target) * rebate;
            lineItem.ASI_CRM_CN_Est_Total_Dummy__c = Integer.valueOf(estimatePurchaseValue / target) * rebate;

        }
        if (KPIBase == 'Value base' && methodology == 'Rebate%(By Ladder)') {
            Decimal min = lineItem.ASI_CRM_CN_Min_Purchase_Target__c != null? lineItem.ASI_CRM_CN_Min_Purchase_Target__c : 0;
            Decimal max = lineItem.ASI_CRM_CN_Max_Purchase_Target__c;
            Decimal rebatePercent = lineItem.ASI_CRM_CN_Rebate_Percent__c;

            lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = ASI_CRM_CN_ContractOffUtilClass.calculateRebatePercentByLadder(min, max, contractPurchaseValue, rebatePercent, false, null);
            lineItem.ASI_CRM_CN_Est_Total_Dummy__c = ASI_CRM_CN_ContractOffUtilClass.calculateRebatePercentByLadder(min, max, estimatePurchaseValue, rebatePercent, isCapped, Math.max(min, contractPurchaseValue));
        }
        if (KPIBase == 'Value base' && methodology == 'Rebate%(By Tax)') {
            Decimal min = lineItem.ASI_CRM_CN_Min_Purchase_Target__c == null? 0 : lineItem.ASI_CRM_CN_Min_Purchase_Target__c;
            Decimal rebatePercent = lineItem.ASI_CRM_CN_Rebate_Percent__c == null? 0 : lineItem.ASI_CRM_CN_Rebate_Percent__c;


            if (contractPurchaseValue > min) {
                Decimal max = lineItem.ASI_CRM_CN_Max_Purchase_Target__c != null? Math.min(lineItem.ASI_CRM_CN_Max_Purchase_Target__c, contractPurchaseValue) : contractPurchaseValue;
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = contractPurchaseValue > min? (max - min) * rebatePercent / 100 : 0;
            } else {
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
            }
            if (estimatePurchaseValue > min) {
                Decimal max = lineItem.ASI_CRM_CN_Max_Purchase_Target__c != null? Math.min(lineItem.ASI_CRM_CN_Max_Purchase_Target__c, estimatePurchaseValue) : estimatePurchaseValue;
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = estimatePurchaseValue > min? (max - min) * rebatePercent / 100 : 0;
            } else {
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = 0;
            }

        }


        return lineItem;
    }


    /**
     * Calculate ASI_CRM_CN_Contract_Total_Dummy__c and ASI_CRM_CN_Est_Total_Dummy__c. Only calculate Per incentive bottle and Rebate%.
     * Called after setting default value for sub-brand after "Refresh"
     *
     * @param ModuleId
     */
    public void CalPSFAmount(String ModuleId) { //Only Apply to By SubBrand Module
        String KPIBase = PSF_Item_Map.get(ModuleId).Module.ASI_CRM_CN_KPI_Base__c;

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : PSF_Item_Map.get(ModuleId).DetailLineMap.values()) {

            if (KPIBase == 'Volume base') {
                if (line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null && ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
                    line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                }
                if (line.ASI_CRM_CN_Contract_Monthly_Qty__c != null && line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null) {
                    line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Monthly_Qty__c * line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                }
                if (line.ASI_CRM_CN_Est_Monthly_Qty__c != null && line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null) {
                    line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Monthly_Qty__c * line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                }

            }
            if (KPIBase == 'Value base') {
                if (line.ASI_CRM_CN_Rebate_Percent__c != null) {
                    line.ASI_CRM_CN_Contract_Total_Dummy__c = isPOModi? 0 : line.ASI_CRM_CN_Contract_Purchase_Value__c * line.ASI_CRM_CN_Rebate_Percent__c / 100;
                    line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Estimate_Purchase_Value__c * line.ASI_CRM_CN_Rebate_Percent__c / 100;

                }
            }

        }
    }


    public void PSFChangingSB() {
        SettingDefaultValue();
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String Module_Id = params.get('PARAM_Module_ID');
        String Line_Id = params.get('PARAM_Line_ID');
        if (PSF_Item_Map.containsKey(Module_Id) && !PSF_Item_Map.isEmpty()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c SelectedTarget = PSF_Item_Map.get(Module_Id).DetailLineMap.get(Line_Id);

            String SubBrandId = SelectedTarget.ASI_CRM_CN_Sub_Brand__c;
            ASI_MFM_Sub_brand__c SubBrand = [SELECT Id,ASI_CRM_CN_Sub_brand_Grade__c FROM ASI_MFM_Sub_brand__c WHERE Id = :SubBrandId];

            PSF_Item_Map.get(Module_Id).DetailLineMap.get(Line_Id).ASI_CRM_Sub_Brand_Grade__c = SubBrand.ASI_CRM_CN_Sub_brand_Grade__c;
        }

    }

    public void AddNewPSFLine() {
        SettingDefaultValue();
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_Line_ID');
        Id BRSFLineRtId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        if (PSF_Item_Map.containsKey(param_Id)) {
            if (PSF_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c == 'By Total') {
                ByTotalAmountGenerating('PSF');

            } else {
                PSF_Item_Map.get(param_Id).DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId, ASI_CRM_Type__c = 'PSF',
                    ASI_CRM_Volume_Base__c = 'By Sub-Brand',
                    RecordTypeId = BRSFLineRtId, ASI_CRM_Max_Incentive__c = 0,
                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0));
            }

        }

        if (PSF_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
            CalPSFAmount(param_Id);
            SettingDefaultValue();
        }

    }


    public void RemovePSFLine() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_Line_ID');
        String itm_Id = params.get('PARAM_item_ID');
        String UnitStr = params.get('PARAM_Unit_ID');
        SettingDefaultValue();

        //system.debug('Now Unit_Id: '+ UnitStr );
        if (PSF_Item_Map.containsKey(itm_Id) && !PSF_Item_Map.isEmpty()) {
            System.debug('RemovePSFLine param_Id: ' + param_Id);
            ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = PSF_Item_Map.get(itm_Id).DetailLineMap.get(param_Id);
            if (delTarget.Id != null) {
                BRSFDeleteList.add(delTarget);
            }
            PSF_Item_Map.get(itm_Id).Module.ASI_CRM_Unit__c = UnitStr;
            System.debug('Now RemovePSFLine' + PSF_Item_Map.get(itm_Id).Module.ASI_CRM_Unit__c);
            PSF_Item_Map.get(itm_Id).DetailLineMap.remove(param_Id);
            if (PSF_Item_Map.get(itm_Id).Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                SettingDefaultValue();
                CalPSFAmount(itm_Id);
            }
        }
    }


    // called when deleting a module. Used by both PSF and Display module
    public void deleteModule() {
        SettingDefaultValue();
        String param_Id = ApexPages.currentPage().getParameters().get('PARAMID');

        interimData dataInRefresh = PSF_Item_Map.containsKey(param_Id)? PSF_Item_Map.get(param_Id) : DisplayListingItemMap.get(param_Id);

        if (dataInRefresh == null) {
            return;
        }
        System.debug(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
        String lineType = PSF_Item_Map.containsKey(param_Id)? 'PSF' : 'Display';
        if (lineType == 'PSF' && ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON') != null) {
            updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));

        }

        // delete all lines
        for (String key : dataInRefresh.DetailLineMap.keySet()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = dataInRefresh.DetailLineMap.get(key);
            if (delTarget.Id != null) {
                BRSFDeleteList.add(delTarget);
            }
            dataInRefresh.DetailLineMap.remove(key);
        }

        // delete module
        if (dataInRefresh.Module.Id != null) {
            ModuleDeleteList.add(dataInRefresh.Module);
        }

        //delete interimData
        if (lineType == 'PSF') {
            PSF_Item_Map.remove(param_Id);
        } else {
            DisplayListingItemMap.remove(param_Id);
        }


        // Since the total will be different after deleting a module, need to recalculate
        calculateContractSummary();

        updatePSFItemMapDTO();
    }


    //in PSF, after clicking 'refresh', if by sub-brand, get incentive from master
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BySubBrandRefresh(ASI_CRM_Module__c module) { // System will refer to the default PSF incentive from sub-brand grade object
        Set<String> SBBrandSet = new Set<String>();
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BRSFItemMap.DetailLineMap.values()) {
            SBBrandSet.add(line.ASI_CRM_CN_Sub_Brand__c);
        }
        Map<String, ASI_MFM_Sub_brand__c> SubBrandGradeMapping = new Map<String, ASI_MFM_Sub_brand__c> ();
        for (ASI_MFM_Sub_brand__c sb : [
            SELECT Id,Name,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c, (
                SELECT Id, ASI_CRM_CN_Incentive_for_PSF__c,ASI_CRM_CN_Max_Incentive_for_PSF__c,ASI_CRM_CN_Rebate_Percent__c,ASI_CRM_CN_Max_Rebate_Percent__c
                FROM ASI_CRM_CR12_Factors__r
                WHERE ASI_CRM_CN_Region__c = :ContractSelected.ASI_CRM_CN_Region__c AND ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c
            )
            FROM ASI_MFM_Sub_brand__c
            WHERE RecordType.DeveloperName LIKE '%CN%' AND Id IN:SBBrandSet
        ]) {
            SubBrandGradeMapping.put(sb.Id, sb);
        }

        //Sub-Brand Grade id, Sub-Brand Grade Record for 'ASI_CRM_CN_Sub_brand_Grade'
        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeNameMap = new Map<String, ASI_CRM_Sub_Brand_Grade__c>([
            SELECT Id, Name,ASI_CRM_Chinese_Name__c
            FROM ASI_CRM_Sub_Brand_Grade__c
            WHERE
                RecordType.DeveloperName = 'ASI_CRM_CN_Sub_brand_Grade'
        ]);


        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BRSFItemMap.DetailLineMap.values()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = line.clone(false);
            TempLine.Id = null;
            TempLine.ASI_CRM_CN_Activity_Code__c = PSFActivityCodeId;
            TempLine.ASI_CRM_Type__c = 'PSF';
            TempLine.ASI_CRM_Volume_Base__c = 'By Sub-Brand';
            TempLine.ASI_CRM_Max_Incentive__c = 99999;
            TempLine.ASI_CRM_CN_Sub_Brand__r = SubBrandGradeMapping.get(line.ASI_CRM_CN_Sub_Brand__c);
            TempLine.ASI_CRM_CN_Rebate_Percent__c = 0;

                for (ASI_CRM_Sub_Brand_Line__c subBrandLine : SubBrandGradeMapping.get(TempLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CR12_Factors__r) {
                    TempLine.ASI_CRM_Max_Incentive__c = subBrandLine.ASI_CRM_CN_Max_Incentive_for_PSF__c;
                    TempLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = subBrandLine.ASI_CRM_CN_Incentive_for_PSF__c;
                    TempLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = subBrandLine.ASI_CRM_CN_Incentive_for_PSF__c;
                    TempLine.ASI_CRM_CN_Max_Rebate_Percent__c = subBrandLine.ASI_CRM_CN_Max_Rebate_Percent__c;
                    TempLine.ASI_CRM_CN_Rebate_Percent__c = (subBrandLine.ASI_CRM_CN_Rebate_Percent__c != null ?subBrandLine.ASI_CRM_CN_Rebate_Percent__c : 0);
                }

            // if current module is Value base, copy BRSF Contract purchase value(ASI_CRM_CN_Contract_Total_Dummy__c) to PSF Contract purchase value(ASI_CRM_CN_Contract_Purchase_Value__c)
            if (module.ASI_CRM_CN_KPI_Base__c == 'Value base') {
                TempLine.ASI_CRM_CN_Contract_Purchase_Value__c = line.ASI_CRM_CN_Contract_Total_Dummy__c;
                TempLine.ASI_CRM_CN_Estimate_Purchase_Value__c = line.ASI_CRM_CN_Est_Total_Dummy__c;
                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
                TempLine.ASI_CRM_CN_Est_Total_Dummy__c = 0;
            }

            if (TempLine.ASI_CRM_Sub_Brand_Grade__c == null && SubBrandGradeMapping.containsKey(TempLine.ASI_CRM_CN_Sub_Brand__c)) {
                TempLine.ASI_CRM_Sub_Brand_Grade__c = SubBrandGradeMapping.get(TempLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__c != null? SubBrandGradeMapping.get(TempLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__c : null;
            }

            if (TempLine.ASI_CRM_Sub_Brand_Grade__c != null && SubBrandGradeNameMap.containsKey(TempLine.ASI_CRM_Sub_Brand_Grade__c)) {
                TempLine.ASI_CRM_Line_Name__c = SubBrandGradeNameMap.get(TempLine.ASI_CRM_Sub_Brand_Grade__c).ASI_CRM_Chinese_Name__c != null? SubBrandGradeNameMap.get(TempLine.ASI_CRM_Sub_Brand_Grade__c).ASI_CRM_Chinese_Name__c : SubBrandGradeNameMap.get(TempLine.ASI_CRM_Sub_Brand_Grade__c).Name;


            }

            ContractLines.add(TempLine);
        }

        return ContractLines;
    }

    public void onPSFMethodologyChange() {
        String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        interimData interimData = PSF_Item_Map.get(itemKey);

        interimData.VolumeValueBasePickList = genPSFVolValBasePicklist(interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__c);
        interimData.Module.ASI_CRM_Unit__c = calculatePSFUnit(interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__c);
        interimData.Module.ASI_CRM_CN_Criteria__c = calculateCriteria(interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__c);
        interimData.Module.ASI_CRM_Methodology__r = MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c);

        if (interimData.Module.ASI_CRM_Methodology__r.Name == 'Others') {
            interimData.Module.ASI_CRM_Volume_Base__c = '';
            interimData.Module.ASI_CRM_Unit__c = '';
        }

        // Update the map after setting values
        PSF_Item_Map.put(itemKey, interimData);
    }
    public void onPSFVolumeBaseChange() {
        String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        interimData interimData = PSF_Item_Map.get(itemKey);

        interimData.Module.ASI_CRM_Unit__c = calculatePSFUnit(interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__c);

        // Update the map after setting values
        PSF_Item_Map.put(itemKey, interimData);
    }


    /**
     * Get all methodologies from Master file with specific KPIBase and type
     *
     * @param KPIBase
     * @param type
     *
     * @return
     */
    public List<SelectOption> genMethodologyPicklist(String KPIBase, String type) {
        List<SelectOption> methodologyPicklist = new List<SelectOption>();
        String methodologyLabel;

        for (ASI_CRM_Methodology__c methodology : MethodologyById.values()) {
            // fulfill master file and match module
            if (!methodology.ASI_CRM_Methodology_Assignment__r.isEmpty() && methodology.ASI_CRM_CN_KPI_Base__c == KPIBase && methodology.ASI_CRM_Type__c == type) {
                methodologyLabel = showCN? methodology.ASI_CRM_Chinese_Name__c : methodology.Name;
                methodologyPicklist.add(new SelectOption(methodology.Id, methodologyLabel));
            }
        }
        return methodologyPicklist;
    }


    public List<SelectOption> genPSFVolValBasePicklist(String KPIBase, String methodologyId) {
        List<SelectOption> picklist = new List<SelectOption>();

        if (String.isEmpty(KPIBase) || String.isEmpty(methodologyId)) {
            return picklist;
        }

        String methodology = MethodologyById.get(methodologyId).Name;
        Map<String, SelectOption> allOptions = getPickListValueMap(ASI_CRM_Module__c.ASI_CRM_Volume_Base__c.getDescribe());

        // Return empty picklist if methodology == other
        if (methodology == 'Others') {
            return picklist;
        }

        if (KPIBase == 'Volume base' && methodology == 'Per Incentive Btl') {
            picklist.add(allOptions.get('By Sub-Brand'));
        }
        if (KPIBase == 'Volume base' && methodology == 'Actual Achievement%') {
            picklist.add(allOptions.get('By Category'));
            picklist.add(allOptions.get('By Total'));
        }
        if (KPIBase == 'Value base') {
            if (methodology == 'Rebate%(By Ladder)' || methodology == 'Rebate%(By Tax)') {
                picklist.add(allOptions.get('By Total'));
            } else {
                picklist.add(allOptions.get('By Sub-Brand'));
                picklist.add(allOptions.get('By Category'));
                picklist.add(allOptions.get('By Total'));
            }
        }

        return picklist;
    }


    public String calculatePSFUnit(String KPIBase, String methodologyId) {
        if (String.isEmpty(KPIBase) || String.isEmpty(methodologyId)) {
            return '';
        }

        String methodology = MethodologyById.get(methodologyId).Name;
        String unit;

        if (KPIBase == 'Volume base' && methodology == 'Per Incentive Btl') {
            unit = 'Std. Btl.';
        }
        if (KPIBase == 'Volume base' && methodology == 'Actual Achievement%') {
            unit = 'CR12 Extra Eqv.';
        }
        if (KPIBase == 'Value base') {
            unit = 'RMB';
        }

        return unit;
    }

    public String calculateCriteria(String KPIBase, String methodologyId) {
        if (String.isEmpty(KPIBase) || String.isEmpty(methodologyId)) {
            return '';
        }

        String methodology = MethodologyById.get(methodologyId).Name;

        if (KPIBase == 'Value base' && methodology == 'Rebate%(By Ladder)') {
            return 'By Ladder';
        }
        if (KPIBase == 'Value base' && methodology == 'Rebate%(By Tax)') {
            return 'By Tax';
        }

        return 'NA';
    }

    //***********************************End of PSF Part *************************************


    //************DisplayListing***************
    public void onDisplayMethodologyChange() {
        String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        ASI_CRM_Module__c module = DisplayListingItemMap.get(itemKey).Module;
        module = setModuleByMethodology(module, module.ASI_CRM_Methodology__c);

        DisplayListingItemMap.get(itemKey).updateMethodologyDisplay(showCN);


    }

    /**
     * Only for Display module.
     *
     * @param module    The module you gonna set
     * @param methodologyId Methodology Id
     */
    public ASI_CRM_Module__c setModuleByMethodology(ASI_CRM_Module__c module, Id methodologyId) {
        ASI_CRM_Methodology__c methodology = MethodologyById.get(methodologyId);

        if (methodology == null) {
            module.ASI_CRM_Volume_Base__c = null;
            module.ASI_CRM_Unit__c = null;
            module.ASI_CRM_Methodology__r = null;
            return module;
        }

        if (methodology.Name == 'Actual Achievement%') {
            module.ASI_CRM_Volume_Base__c = 'By Total';
            module.ASI_CRM_Unit__c = 'CR12 Extra Eqv.';
        }
        if (methodology.Name == 'Others') {
            module.ASI_CRM_Volume_Base__c = null;
            module.ASI_CRM_Unit__c = null;
        }
        module.ASI_CRM_Methodology__r = methodology;

        return module;
    }

    public void onDisplayContractTotalChange() {
        String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        String lineKey = ApexPages.currentPage().getParameters().get('lineKey');
        ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem = DisplayListingItemMap.get(itemKey).DetailLineMap.get(lineKey);
        String change = ApexPages.currentPage().getParameters().get('change');
        Boolean isContractChange = change == 'contract';

        if (lineItem == null) {
            return;
        }

        if (isContractChange) {
            lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
        }


        // recalculate total
        displayContractTotalSum = 0;
        displayEstimateTotalSum = 0;

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : DisplayListingItemMap.get(itemKey).DetailLineMap.values()) {
            displayContractTotalSum += item.ASI_CRM_CN_Contract_Total_Dummy__c;
            displayEstimateTotalSum += item.ASI_CRM_CN_Contract_Total_Dummy__c;
        }

    }

    public void DisplayListingAddModule() {
        SettingDefaultValue();
        //Construct Key Id
        String keyId = LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine();
        ASI_CRM_Module__c module = createModule('Display');
        interimData d = createInterimData(module);

        DisplayListingItemMap.put(keyId, d);
    }


    //******************************** Covered Outlet Line Item - functions End ***********************
    public void AddNew_CoveredOutlet() {
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        CoveredOutlet_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), outlet);
        outlet.ASI_CRM_CN_Contract__c = ContractSelected.Id;
        outlet.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet');
        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
    }


    //****************************************************** Covered Outlet Line Item - functions End ******************************************************


    // ****************  For PSF,Product Category Map by BRSF Sub-Brand grade after clicking 'fresh'   ****************
    public Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> ByProductCategoryGrouping(String LineType) {
        Id BRSFLineRtId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        Set<String> SBBrandSet = new Set<String>();//Store all Sub-Brand Id
        //Getting current sub-brand
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BRSFItemMap.DetailLineMap.values()) {
            if (line.ASI_CRM_CN_Sub_Brand__c != null) {
                SBBrandSet.add(line.ASI_CRM_CN_Sub_Brand__c);
            }
        }

        Map<String, ASI_MFM_Sub_brand__c> ProductCategoryMap = new Map<String, ASI_MFM_Sub_brand__c> (); //Map : <Sub-Brand Id,Product Category Name>
        for (ASI_MFM_Sub_brand__c sb : [SELECT Id,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_MFM_Brand__c, ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name FROM ASI_MFM_Sub_brand__c WHERE RecordType.DeveloperName LIKE '%CN%' AND Id IN:SBBrandSet]) {
            if (sb.ASI_MFM_Brand__c != null) {
                if (sb.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c != null) {
                    ProductCategoryMap.put(sb.Id, sb);//sb.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name
                }
            }
        }

        //Map : <Product Category Name,Insert BRSF Line >        //ASI_CRM_CN_Contract_Total_Dummy__c=0.0, //ASI_CRM_CN_Est_Total_Dummy__c=0.0, //ASI_CRM_CN_Contract_BRSF_Per_Bottle__c= 0, //ASI_CRM_CN_Est_BRSF_Per_Bottle__c= 0,
        Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> ProductCategoryGrouping = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
        //Getting all Product Category from DataBase
        for (ASI_HK_CRM_Product_Category__c ProductCategory : [
            SELECT Id,Name,ASI_CRM_CN_Chinese_Name__c,ASI_HK_CRM_Sequence__c
            FROM ASI_HK_CRM_Product_Category__c
            WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Product_Category'
            AND ASI_HK_CRM_English_Name__c != 'RTD'
            AND ASI_HK_CRM_English_Name__c != 'Baijiu'
        ]) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c NewContractLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId, ASI_CRM_Volume_Base__c = 'By Category',
                ASI_CRM_Product_Category__c = ProductCategory.Id,
                ASI_CRM_Product_Category_Name__c = ProductCategory.Name, ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0,
                ASI_CRM_Line_Name__c = ProductCategory.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_CN_Contract_Monthly_Qty__c = 0, ASI_CRM_Contract_Monthly_Volume_CR12__c = 0, ASI_CRM_Est_Monthly_Volume_CR12__c = 0,
                ASI_CRM_Map_Key__c = ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(ProductCategory.ASI_HK_CRM_Sequence__c),
                ASI_CRM_CN_Est_Monthly_Qty__c = 0, ASI_CRM_Max_Incentive__c = 0, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0,
                ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = 0,
                ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0,
                ASI_CRM_Contract_Total_QTY_std_Btl__c = 0,
                ASI_CRM_Est_Total_QTY_std_Btl__c = 0,
                ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c = 0, ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c = 0,
                ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c = 0, ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c = 0,
                ASI_CRM_Type__c = LineType, RecordTypeId = BRSFLineRtId,
                ASI_CRM_CN_Contract_Purchase_Value__c = 0,
                ASI_CRM_CN_Estimate_Purchase_Value__c = 0,
                ASI_CRM_CN_Rebate_Percent__c = 0,
                ASI_CRM_CN_Rebate__c = 0,
                ASI_CRM_CN_Target__c = 0
            );
            if (ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0') {
                NewContractLine.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
            }
            ProductCategoryGrouping.put(ProductCategory.Name, NewContractLine);
        }


        //Getting CR12 Factor Map
        Map<String, Decimal> CR12FactorMap = GenerateCR12FactorMap(SBBrandSet);
        //Based on the SubBrand, calculate the volume in the detail list
        // Loop lines in BRSF
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BRSFItemMap.DetailLineMap.values()) {
            String productCategoryName = ProductCategoryMap.get(line.ASI_CRM_CN_Sub_Brand__c).ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name;
            if (ProductCategoryMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c) && ProductCategoryGrouping.containsKey(productCategoryName)) {
                Decimal CR12Factor = CR12FactorMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)? CR12FactorMap.get(line.ASI_CRM_CN_Sub_Brand__c) : 1;

                //------ Monthly Volume -------
                ASI_CRM_CN_Contract_BRSF_Line_Item__c productCategoryLine = ProductCategoryGrouping.get(productCategoryName);
                productCategoryLine.ASI_CRM_Contract_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor;
                productCategoryLine.ASI_CRM_Est_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor;

                productCategoryLine.ASI_CRM_CN_Contract_Monthly_Qty__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c;
                productCategoryLine.ASI_CRM_CN_Est_Monthly_Qty__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c;

                //Total
                productCategoryLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor * ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;
                productCategoryLine.ASI_CRM_Contract_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;

                if (line.ASI_CRM_Est_Total_QTY_std_Btl__c != null) {
                    productCategoryLine.ASI_CRM_Est_Total_QTY_std_Btl__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c;
                    productCategoryLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c * CR12Factor;
                } else {
                    productCategoryLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;

                    productCategoryLine.ASI_CRM_Est_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;
                }

                // Calculate ASI_CRM_CN_Contract_Purchase_Value__c and ASI_CRM_CN_Estimate_Purchase_Value__c
                productCategoryLine.ASI_CRM_CN_Contract_Purchase_Value__c += (line.ASI_CRM_CN_Contract_Total_Dummy__c == null)? 0 : line.ASI_CRM_CN_Contract_Total_Dummy__c;
                productCategoryLine.ASI_CRM_CN_Estimate_Purchase_Value__c += (line.ASI_CRM_CN_Est_Total_Dummy__c == null)? 0 : line.ASI_CRM_CN_Est_Total_Dummy__c;


                if (isPOModi) {
                    productCategoryLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = 0;
                    productCategoryLine.ASI_CRM_Contract_Total_QTY_std_Btl__c = 0;
                    productCategoryLine.ASI_CRM_CN_Contract_Monthly_Qty__c = 0;
                    productCategoryLine.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0;
                    productCategoryLine.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
                }


            }
        }


        return ProductCategoryGrouping;

    }


    /**
     * Generate BRSF Line if Volume base is By Total
     *
     * @param LineType PSF or Display
     *
     * @return BRSF Line
     */

    public ASI_CRM_CN_Contract_BRSF_Line_Item__c ByTotalAmountGenerating(String LineType) {
        Id BRSFLineRtId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        ASI_CRM_CN_Contract_BRSF_Line_Item__c InsertedLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId, ASI_CRM_Type__c = LineType, RecordTypeId = BRSFLineRtId,
            ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = 0, ASI_CRM_Contract_Monthly_Volume_CR12__c = 0,
            ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0, ASI_CRM_Est_Monthly_Volume_CR12__c = 0,
            ASI_CRM_Contract_Total_QTY_std_Btl__c = 0, ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0,
            ASI_CRM_Est_Total_QTY_std_Btl__c = 0, ASI_CRM_Max_Incentive__c = 0, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0,
            ASI_CRM_CN_Contract_Monthly_Qty__c = 0.0, ASI_CRM_CN_Est_Monthly_Qty__c = 0.0, ASI_CRM_Volume_Base__c = 'By Total',
            ASI_CRM_CN_Contract_Purchase_Value__c = 0,
            ASI_CRM_CN_Estimate_Purchase_Value__c = 0,
            ASI_CRM_CN_Rebate_Percent__c = 0,
            ASI_CRM_CN_Rebate__c = 0,
            ASI_CRM_CN_Target__c = 0

        );
        Set<String> SubBrandIdSet = new Set<String> ();
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BRSFItemMap.DetailLineMap.values()) {
            if (line.ASI_CRM_CN_Sub_Brand__c != null) {
                SubBrandIdSet.add(line.ASI_CRM_CN_Sub_Brand__c);
            }
        }
        //Getting CR12 Factor Map
        Map<String, Decimal> CR12FactorMap = GenerateCR12FactorMap(SubBrandIdSet);


        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : BRSFItemMap.DetailLineMap.values()) {
            Decimal CR12Factor = CR12FactorMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)? CR12FactorMap.get(line.ASI_CRM_CN_Sub_Brand__c) : 1;


            // Monthly
            InsertedLine.ASI_CRM_CN_Est_Monthly_Qty__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c;
            InsertedLine.ASI_CRM_Est_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor;


            if (line.ASI_CRM_Est_Total_QTY_std_Btl__c != null) {
                InsertedLine.ASI_CRM_Est_Total_QTY_std_Btl__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c;
                InsertedLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c * CR12Factor;
            } else {
                InsertedLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;

                InsertedLine.ASI_CRM_Est_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;
            }


            InsertedLine.ASI_CRM_CN_Contract_Purchase_Value__c += (line.ASI_CRM_CN_Contract_Total_Dummy__c == null)? 0 : line.ASI_CRM_CN_Contract_Total_Dummy__c;
            InsertedLine.ASI_CRM_CN_Estimate_Purchase_Value__c += (line.ASI_CRM_CN_Est_Total_Dummy__c == null)? 0 : line.ASI_CRM_CN_Est_Total_Dummy__c;


            if (ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
                InsertedLine.ASI_CRM_CN_Contract_Monthly_Qty__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c;
                InsertedLine.ASI_CRM_Contract_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor;
                InsertedLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                InsertedLine.ASI_CRM_Contract_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
            } else {
                InsertedLine.ASI_CRM_CN_Contract_Monthly_Qty__c = 0;
                InsertedLine.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0;
                InsertedLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = 0;
                InsertedLine.ASI_CRM_Contract_Total_QTY_std_Btl__c = 0;
                InsertedLine.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
            }
        }
        if(IsDolphinContract){
            InsertedLine.ASI_CRM_CN_Rebate_Percent__c = rebatePercent;
            InsertedLine.ASI_CRM_CN_Contract_Total_Dummy__c = InsertedLine.ASI_CRM_CN_Contract_Purchase_Value__c*InsertedLine.ASI_CRM_CN_Rebate_Percent__c/100;
            InsertedLine.ASI_CRM_CN_Est_Total_Dummy__c = InsertedLine.ASI_CRM_CN_Estimate_Purchase_Value__c*InsertedLine.ASI_CRM_CN_Rebate_Percent__c/100;
        }
        return InsertedLine;

    }


    //Generate CR12 Factor Mapping table : Sub-Brand Id, CR12 Factor
    private Map<String, Decimal> GenerateCR12FactorMap(Set<String> SBIdSet) {
        Map<String, Decimal> CR12FactorMap = new Map<String, Decimal> ();
        for (ASI_MFM_Sub_brand__c SubBrand : [SELECT Id,ASI_CRM_CN_COnvfactor_Ltocr12_C__c, (SELECT Id,ASI_CRM_CR12_Conversion_Factor__c,ASI_CRM_Commercial_Team__c,ASI_CRM_CN_Region__c FROM ASI_CRM_CR12_Factors__r) FROM ASI_MFM_Sub_brand__c WHERE Id IN :SBIdSet]) {
            Decimal CR12Factor = 1;
            Boolean FoundFactor = false;
            for (ASI_CRM_Sub_Brand_Line__c SubBrandLine : SubBrand.ASI_CRM_CR12_Factors__r) {
                if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c != null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c != null && SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c != null && SubBrandLine.ASI_CRM_Commercial_Team__c == ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c && SubBrandLine.ASI_CRM_CN_Region__c == ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c) {
                    CR12Factor = SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c;
                    FoundFactor = true;
                }
            }
            if (!FoundFactor && SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null) {
                CR12Factor = SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                FoundFactor = true;
            }
            if (FoundFactor) {
                CR12FactorMap.put(SubBrand.Id, CR12Factor);
            }
        }
        return CR12FactorMap;
    }


    //*********************************Save the record **************************************
    public PageReference saveItems() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('isQuickSave');
        updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PSFDeletedLines = (List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>) JSON.deserialize(params.get('PSFDeletedLinesJson'), List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>.class);

        Boolean isQuickSave = (isQuickSaveStr == null)? false : Boolean.valueOf(isQuickSaveStr);
        PageReference pageRef = null;
        msg = '';
        UpsertPermission = true;
        WarningMsg = '';

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpsertBRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        ASI_CRM_Module__c BRSFModule = new ASI_CRM_Module__c();

        List<ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> Saved_CoveredOutlet_Temp = new List<ASI_CRM_CN_Covered_Outlet__c>();


        Database.UpsertResult[] UpsertTarget;
        Database.DeleteResult[] DeleteTarget;

        Map<String, ASI_CRM_Module__c> PSFModuleMap = new Map<String, ASI_CRM_Module__c> ();
        Map<String, ASI_CRM_Module__c> DisplayModuleMap = new Map<String, ASI_CRM_Module__c> ();

        if(IsDolphinContract){
            BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c = 'Value';
        }

        ModuleChecking();
        System.Savepoint pSavepoint = Database.setSavepoint();

        //Upsert Module Part
        if (UpsertPermission) {
            BRSFModule = BRSFItemMap.Module;
            BRSFModule.ASI_CRM_Contract__c = PageId;


            if (ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
                BRSFModule.ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c;
            }

            for (String key : PSF_Item_Map.keySet()) {
                if (ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
                    PSF_Item_Map.get(key).Module.ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c;
                }
                PSF_Item_Map.get(key).Module.ASI_CRM_CN_AC_Code__c = String.isNotEmpty(PSFActivityCodeId)? PSFActivityCodeId : null;
                PSFModuleMap.put(key, PSF_Item_Map.get(key).Module);
            }
            for (String key : DisplayListingItemMap.keySet()) {
                if (ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
                    DisplayListingItemMap.get(key).Module.ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c;
                }
                DisplayListingItemMap.get(key).Module.ASI_CRM_CN_AC_Code__c = String.isNotEmpty(DisplayActivityCodeId)? DisplayActivityCodeId : null;
                DisplayModuleMap.put(key, DisplayListingItemMap.get(key).Module);
            }


            try {
                System.debug('going to save module~');
                System.debug('UpsertPermission ');
                System.debug(UpsertPermission);
                System.debug(BRSFModule);
                if (BRSFModule != null) {
                    upsert BRSFModule;
                }
                if (PSFModuleMap.size() > 0) {
                    upsert PSFModuleMap.values();
                }
                if (DisplayModuleMap.size() > 0) {
                    upsert DisplayModuleMap.values();
                }
            } catch (Exception e) {
                msg += 'Save Error : ' + e.getMessage() + '</br>';
                pageRef = null;
                Database.rollback(pSavepoint);
                UpsertPermission = false;
                return null;
            }
        }


        CalBRSFAmount();


        if (UpsertPermission) {//Upsert detail Line
            UpsertBRSFList = ValidationChecking(BRSFModule, DisplayModuleMap, PSFModuleMap);

            List<ASI_CRM_CN_Covered_Outlet__c> coveredOutlets = CoveredOutlet_Item_Map.values();
            Set<Id> coveredOutletIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_CRM_CN_Covered_Outlet__c.ASI_CRM_CN_Outlet__c, coveredOutlets);
            Map<Id, ASI_CRM_AccountsAdditionalField__c> outletsById = new Map<Id, ASI_CRM_AccountsAdditionalField__c>([SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE RecordType.DeveloperName = 'ASI_CRM_Outlet_CN' AND Id IN :coveredOutletIds]);

            List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletsOutsideGroupPO = ASI_CRM_CN_CoveredOutletValidationClass.getCoveredOutletsOutsideGroupPO(coveredOutlets, PageId);
            System.debug(coveredOutletsOutsideGroupPO);
            System.debug(coveredOutletsOutsideGroupPO.size());
            if (!coveredOutletsOutsideGroupPO.isEmpty()) {
                for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutletsOutsideGroupPO) {
                    if (coveredOutlet.ASI_CRM_CN_Outlet__c != null) {
                        ErrorHandling(String.format(
                            Label.ASI_CRM_CN_Covered_Outlet_not_existed_in_Group_PO,
                            new List<String>{
                                outletsById.get(coveredOutlet.ASI_CRM_CN_Outlet__c).Name,
                                ContractSelected.ASI_CRM_CN_Group_Contract__r.Name
                            }
                        )
                        );
                    }
                }
            }
            Map<ASI_CRM_CN_Covered_Outlet__c, List<ASI_TH_CRM_Contract__c>> coveredOutletsOverlapWithOtherContracts = ASI_CRM_CN_CoveredOutletValidationClass.getCoveredOutletsOverlapWithOtherContracts(coveredOutlets, PageId);
            if (!coveredOutletsOverlapWithOtherContracts.isEmpty()) {
                for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutletsOverlapWithOtherContracts.keySet()) {
                    List<String> contractName = new List<String>();
                    for (ASI_TH_CRM_Contract__c contract : coveredOutletsOverlapWithOtherContracts.get(coveredOutlet)) {
                        contractName.add(contract.Name);
                    }
                    if (coveredOutlet.ASI_CRM_CN_Outlet__c != null) {
                        ErrorHandling(String.format(
                            Label.ASI_CRM_CN_Outlet_overlap,
                            new List<String>{
                                outletsById.get(coveredOutlet.ASI_CRM_CN_Outlet__c).Name, String.join(contractName, ',')
                            }
                        )
                        );
                    }
                }
            }


            //  save Covered Outlet Line Items
            for (String key : CoveredOutlet_Item_Map.keySet()) {
                ASI_CRM_CN_Covered_Outlet__c outlet = CoveredOutlet_Item_Map.get(key);
                if (outlet != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true && outlet.ASI_CRM_CN_Outlet__c != null) {
                    Save_CoveredOutlet_Item.add(outlet);
                }
                else if (outlet.Id != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == false) {
                    Saved_CoveredOutlet_Temp.add(outlet);
                }
            }

            if (Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0) {
                CoveredOutletValdationChecking(Save_CoveredOutlet_Item);
            }

        }

        if (UpsertPermission && WarningTimes != 1) {

            pSavepoint = Database.setSavepoint();


            try {


                //Previous Version PSF Est. Total +Adjustment=Expected PSF Est. Total
                if (!isPOModi) {
                    calculateContractSummary();
                }
                if (isPOModi && ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c != null && ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c != null) {
                    ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c - ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c;
                }
                if (isPOModi && ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c != null && ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c != null) {
                    ContractSelected.ASI_CRM_Display_Estimate_Adjustment_Amt__c = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c - ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c;
                }

                update ContractSelected;


                if (ModuleDeleteList.size() > 0) {
                    DeleteTarget = Database.delete(ModuleDeleteList);
                    ModuleDeleteList.clear();
                }
                if (BRSFDeleteList.size() > 0) {
                    DeleteTarget = Database.delete(BRSFDeleteList);
                    BRSFDeleteList.clear();
                }
                if (PSFDeletedLines.size() > 0) {
                    DeleteTarget = Database.delete(PSFDeletedLines);
                    PSFDeletedLines.clear();
                }
                if (LFixCost.size() > 0) { //Upsert Fix Cost Line
                    UpsertTarget = Database.upsert(LFixCost);
                }


                if (UpsertBRSFList.size() > 0) {//Upsert Contract Line
                    UpsertTarget = Database.upsert(UpsertBRSFList);

                }

                if (Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0) {
                    upsert Save_CoveredOutlet_Item;
                }
                if (Saved_CoveredOutlet_Temp != null && Saved_CoveredOutlet_Temp.size() > 0) {
                    delete Saved_CoveredOutlet_Temp;
                }

                // Always run aggregation
//                if (ASI_CRM_CN_OffContractUtilitiesClass.outletThreshold() >= Save_CoveredOutlet_Item.size()) {
                    Database.executeBatch(new ASI_CRM_CN_OffVolumeDeleteJob(new Set<Id> {ContractSelected.Id}));
//                }

                if (!isQuickSave) {
                    pageRef = new PageReference('/' + PageId);
                    pageRef.setRedirect(true);
                } else {
                    pageRef = new PageReference('/apex/ASI_CRM_CN_EditContractOffDetailPage?id=' + PageId + '&isEdit=1');
                    pageRef.setRedirect(true);
                }


            } catch (Exception e) {
                System.debug('Save Error');
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                msg += 'Save Error : ' + e.getMessage() + '</br>';
                pageRef = null;
                Database.rollback(pSavepoint);
                UpsertPermission = false;
                return null;
            }
        }
        return pageRef;
    }


    public void CoveredOutletValdationChecking(List<ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item) {
        Set<Id> effectiveChildsSet = new Set<Id>();
        Boolean isAllCustomer = false;
        Set<Id> invalidChilds = new Set<Id>();


        if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS') {
            for (ASI_CRM_Effective_supplier__c obj : [SELECT Id, ASI_CRM_Supplier__c, ASI_CRM_Account__c FROM ASI_CRM_Effective_supplier__c WHERE ASI_CRM_Supplier__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c]) {
                effectiveChildsSet.add(obj.ASI_CRM_Account__c);
            }
        } else if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN') {
            isAllCustomer = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c != null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name.toLowerCase().contains('all customer');

            if (!isAllCustomer) {
                for (ASI_CRM_AccountsAdditionalField__c obj : [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c]) {
                    effectiveChildsSet.add(obj.Id);
                }
                for (ASI_CRM_AccountsAdditionalField__c obj : [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c IN :effectiveChildsSet]) {
                    effectiveChildsSet.add(obj.Id);
                }
            }
        }

        Double totalSuggestedAmount = 0;
        for (ASI_CRM_CN_Covered_Outlet__c obj : Save_CoveredOutlet_Item) {
            if (obj.ASI_CRM_CN_Suggested_Amount__c != null) {
                totalSuggestedAmount += obj.ASI_CRM_CN_Suggested_Amount__c;
            }
            if (!effectiveChildsSet.contains(obj.ASI_CRM_CN_Outlet__c)) {
                invalidChilds.add(obj.ASI_CRM_CN_Outlet__c);
            }
        }


        //        if(invalidChilds.size() > 0 && !isAllCustomer){ String errorMsg = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? 'This wholesaler is not effective supplier of below outlets and thus they can\'t be cover outlet : ' : 'This Outlet is not effective parent of below outlets and thus they can\'t be cover outlet : ';
        //            String errorMsgCN = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? '该经销商并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ' : '该母店家并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ';
        //            for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT Id , Name   FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN : invalidChilds   ]){
        //                errorMsg += obj.Name + ',';
        //                errorMsgCN += obj.Name + ',';
        //            }
        //            errorMsg += ' If it is necessary to be covered, Please contact Admin';
        //            errorMsgCN += ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? ' 若此覆盖店家与供货商暂无展开合作，但确认需加入，请和Admin联系' : ' 如确认需加入，请和Admin联系';
        //
        //            if(UserInfo.getLanguage()=='zh_CN')
        //                ErrorHandling(errorMsgCN);
        //            else
        //                ErrorHandling(errorMsg);
        //
        //        }

    }


    //******************************Validation Rule for Module****************************************
    public void ModuleChecking() {
        Integer moduleIndex = 0;
        for (interimData interimData : PSF_Item_Map.values()) {
            moduleIndex++;
            validateInterimData(interimData, moduleIndex);
            ASI_CRM_Module__c module = interimData.Module;
            validateModule(module,moduleIndex);
        }
        moduleIndex = 0;
        for (interimData interimData : DisplayListingItemMap.values()) {
            moduleIndex++;
            validateInterimData(interimData, moduleIndex);
            ASI_CRM_Module__c module = interimData.Module;
            validateModule(module,moduleIndex);
        }

    }

    public void validateInterimData(interimData interimData, Integer moduleIndex) {
        if (interimData.DetailLineMap.isEmpty()) {
            String lineType = interimData.Module.ASI_CRM_Line_Type__c == 'PSF'? Label.ASI_CRM_CN_PSF : Label.ASI_CRM_CN_Display;
            ErrorHandling(String.format(Label.ASI_CRM_CN_No_line_in_Display_Module, new String[]{lineType, String.valueOf(moduleIndex)}));
            return;
        }
        String methodology = MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c).Name;
        String volumeValueBase = BRSFItemMap.Module.ASI_CRM_CN_Volume_Value_Base__c;
        String volumeBase = interimData.Module.ASI_CRM_Volume_Base__c;
        Integer lineIndex = 0;

        if (methodology == 'Others') {
            return ;
        }

        // This map contains the validation needed.
        // Used by both Volume and Value base. The key should be the same in both cases but the value is taking from different field
        Map<String, Decimal> BRSFContractValidationBySubBrand = new Map<String, Decimal>();
        Map<String, Decimal> BRSFEstimateValidationBySubBrand = new Map<String, Decimal>();
        Map<String, Decimal> BRSFContractValidationByCategory = new Map<String, Decimal>();
        Map<String, Decimal> BRSFEstimateValidationByCategory = new Map<String, Decimal>();
        Decimal BRSFContractValueByTotal = 0;
        Decimal BRSFEstimateValueByTotal = 0;

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : BRSFItemMap.DetailLineMap.values()) {
            lineIndex++;

            Decimal contractNewValue = 0;
            Decimal estimateNewValue = 0;
            if (volumeValueBase == 'Volume') {
                contractNewValue = lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c;
                estimateNewValue = lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c;
            }
            if (volumeValueBase == 'Value') {
                contractNewValue = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
                estimateNewValue = lineItem.ASI_CRM_CN_Est_Total_Dummy__c;
            }

            if (contractNewValue == null) {
                String missingField = volumeValueBase == 'Volume'? ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Contract_Monthly_Qty__c.getDescribe().getLabel() : ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Contract_Purchase_Value__c.getDescribe().getLabel();
                ErrorHandling(String.format(Label.ASI_CRM_CN_Missing_Required_Value, new String[]{missingField, Label.ASI_CRM_CN_Volume_Value_Target, String.valueOf(moduleIndex)}));

            }
            if (estimateNewValue == null) {
                String missingField = volumeValueBase == 'Volume'? ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Est_Monthly_Qty__c.getDescribe().getLabel() : ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Estimate_Purchase_Value__c.getDescribe().getLabel();
                ErrorHandling(String.format(Label.ASI_CRM_CN_Missing_Required_Value, new String[]{missingField, Label.ASI_CRM_CN_Volume_Value_Target, String.valueOf(moduleIndex)}));
            }

            // Set up By Sub-Brand map. The map should be sub-brandId -> value
            BRSFContractValidationBySubBrand.put(lineItem.ASI_CRM_CN_Sub_Brand__c, contractNewValue);
            BRSFEstimateValidationBySubBrand.put(lineItem.ASI_CRM_CN_Sub_Brand__c, estimateNewValue);

            // Set up By Category map. The map should be categoryId -> value
            Id categoryId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
            Decimal contractTotal = BRSFContractValidationByCategory.containsKey(categoryId)? BRSFContractValidationByCategory.get(categoryId) : 0;
            Decimal estimateTotal = BRSFEstimateValidationByCategory.containsKey(categoryId)? BRSFEstimateValidationByCategory.get(categoryId) : 0;


            BRSFContractValidationByCategory.put(categoryId, contractTotal + contractNewValue);
            BRSFEstimateValidationByCategory.put(categoryId, estimateTotal + estimateNewValue);

            BRSFContractValueByTotal += contractNewValue;
            BRSFEstimateValueByTotal += estimateNewValue;
        }

        lineIndex = 0;
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
            lineIndex++;

            lineItem = SetAmountToZero(lineItem);

            Decimal contractValueToCompare = 0;
            Decimal estimateValueToCompare = 0;
            if (volumeValueBase == 'Volume') {
                contractValueToCompare = lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c;
                estimateValueToCompare = lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c;
            }
            if (volumeValueBase == 'Value') {
                contractValueToCompare = lineItem.ASI_CRM_CN_Contract_Purchase_Value__c;
                estimateValueToCompare = lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c;
            }

            String contractValueError = String.format(Label.ASI_CRM_CN_Contract_Volume_Target_Validation, new List<String>{ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Contract_Purchase_Value__c.getDescribe().getLabel(),Label.ASI_CRM_CN_Volume_Value_Target,lineItem.ASI_CRM_Type__c,String.valueOf(moduleIndex)});
            String estimateValueError = String.format(Label.ASI_CRM_CN_Contract_Volume_Target_Validation, new List<String>{ASI_CRM_CN_Contract_BRSF_Line_Item__c.ASI_CRM_CN_Estimate_Purchase_Value__c.getDescribe().getLabel(),Label.ASI_CRM_CN_Volume_Value_Target,lineItem.ASI_CRM_Type__c,String.valueOf(moduleIndex)});

            // by sub-Brand checking
            if (volumeBase == 'By Sub-Brand') {
                if (lineItem.ASI_CRM_CN_Sub_Brand__c == null) {
                    ErrorHandling(String.format(Label.ASI_CRM_CN_PSF_Sub_Brand_Null_Validation, new String[]{
                        String.valueOf(lineIndex), String.valueOf(moduleIndex)
                    }));//ErrorHandling('Please input Sub-Brand in line '+String.valueOf(LineCount) +' in PSF Module '+String.valueOf(coun) );
                    continue;
                }
                if (!BRSFContractValidationBySubBrand.keySet().contains(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
                    ErrorHandling(String.format(Label.ASI_CRM_CN_OFF_Target_and_PSF_Subbrand_Different, new String[]{
                        String.valueOf(lineIndex), String.valueOf(moduleIndex)
                    }));//ErrorHandling('We found that the Sub-Brand dont not exist in BRSF in line of '+String.valueOf(LineCount) +' in PSF Module '+String.valueOf(coun) );
                }
                if (BRSFContractValidationBySubBrand.get(lineItem.ASI_CRM_CN_Sub_Brand__c) != contractValueToCompare && !isPOModi) {
                    ErrorHandling(contractValueError);
                }
                if (BRSFEstimateValidationBySubBrand.get(lineItem.ASI_CRM_CN_Sub_Brand__c) != estimateValueToCompare) {
                    ErrorHandling(estimateValueError);
                }
            }

            if (volumeBase == 'By Category') {
                if (!BRSFContractValidationByCategory.containsKey(lineItem.ASI_CRM_Product_Category__c)) {
                    continue;
                }
                if (BRSFContractValidationByCategory.get(lineItem.ASI_CRM_Product_Category__c) != contractValueToCompare && !isPOModi) {
                    ErrorHandling(contractValueError);
                }
                if (BRSFEstimateValidationByCategory.get(lineItem.ASI_CRM_Product_Category__c) != estimateValueToCompare) {
                    ErrorHandling(estimateValueError);
                }
            }
            if (volumeBase == 'By Total') {
                System.debug(LoggingLevel.INFO, '*** BRSFContractValueByTotal: ' + BRSFContractValueByTotal);
                System.debug(LoggingLevel.INFO, '*** contractValueToCompare: ' + contractValueToCompare);
                System.debug(LoggingLevel.INFO, '*** BRSFEstimateValueByTotal: ' + BRSFEstimateValueByTotal);
                System.debug(LoggingLevel.INFO, '*** estimateValueToCompare: ' + estimateValueToCompare);
                if (BRSFContractValueByTotal != contractValueToCompare && !isPOModi) {
                    ErrorHandling(contractValueError);
                }
                if (BRSFEstimateValueByTotal != estimateValueToCompare) {
                    ErrorHandling(estimateValueError);
                }

            }
        }
    }
    public void validateModule(ASI_CRM_Module__c module, Integer moduleIndex) {
        if (module.ASI_CRM_Methodology__c == null) {
            return;
        }

        String methodology = MethodologyById.get(module.ASI_CRM_Methodology__c).Name;
        if (module.ASI_CRM_Line_Type__c != 'Display' && methodology == 'Others' && String.isEmpty(module.ASI_CRM_Remark__c)) {
            ErrorHandling(Label.ASI_CRM_CN_Fill_in_Remarks_for_Others);
        }
        //2020-12-15:minimal achievement validation
        if(IsDolphinContract && moduleIndex == 2){
            if(module.ASI_CRM_CN_Minimal_Achievement__c < ASI_CRM_CN_ContractOffUtilClass.MINIMAL_ACHIEVEMENT){
                ErrorHandling(Label.ASI_CRM_CN_DolphinPO_Minimal_Achievement_Validation);
            }
        }
    }


    public void calculateContractSummary() {

        if (ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
            ContractSelected.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = 0;
            ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c = 0;
            ContractSelected.ASI_CRM_V0_PSF_Contract_Total__c = 0;
            ContractSelected.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c = 0;
            ContractSelected.ASI_CRM_Expected_V0_0_VEC_Est_Total__c = 0;
            ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c = 0;
            ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c = 0;
            ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = 0;
            ContractSelected.ASI_CRM_Display_Estimate_Adjustment_Amt__c = 0;
        }

        //Looping BRSF
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : BRSFItemMap.DetailLineMap.values()) {
            if (ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
                ContractSelected.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
        }

        //Looping PSF
        Decimal PSFEstimateTotal = 0;
        for (interimData interimData : PSF_Item_Map.values()) {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                if (ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {
                    ContractSelected.ASI_CRM_Expected_V0_PSF_Estimated_Total__c += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                    ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                    ContractSelected.ASI_CRM_V0_PSF_Contract_Total__c += lineItem.ASI_CRM_CN_Contract_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                } else {
                    PSFEstimateTotal += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
            }
        }

        Decimal DisplayContractTotal = 0;
        Decimal DisplayEstimateTotal = 0;
        for (interimData interimData : DisplayListingItemMap.values()) {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                DisplayContractTotal += lineItem.ASI_CRM_CN_Contract_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                DisplayEstimateTotal += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
        }

        if (isPOModi) {
            ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c = PSFEstimateTotal;
            ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c - (ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c == null? 0 : ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c);
            ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c = DisplayEstimateTotal;
            ContractSelected.ASI_CRM_Display_Estimate_Adjustment_Amt__c = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c - (ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c == null? 0 : ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c);
        } else {
            ContractSelected.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = DisplayEstimateTotal;
            ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c = DisplayEstimateTotal;
            ContractSelected.ASI_CRM_CN_V0_Display_Contract_Total__c = DisplayContractTotal;
        }
    }


    // **********Validation Checking************
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ValidationChecking(ASI_CRM_Module__c BRSFModule, Map<String, ASI_CRM_Module__c> DisplayModuleMap, Map<String, ASI_CRM_Module__c> PSFModuleMap) {
        Integer coun = 1;
        Integer moduleIndex = 1;

        Decimal TotalContractAmount = 0;
        Decimal TotalEstimateAmount = 0;

        // Looping the fix cost
        for (ASI_CRM_Contract_Cost__c FixCost : LFixCost) {
            if(IsDolphinContract){
                if(FixCost.ASI_CRM_CN_Contract_Amount_Rate__c == null){
                    FixCost.ASI_CRM_CN_Contract_Amount_Rate__c = 0;
                    FixCost.ASI_CRM_CN_Contract_Amount__c = 0;
                }else{
                    FixCost.ASI_CRM_CN_Contract_Amount__c = FixCost.ASI_CRM_CN_Contract_Amount_Rate__c * TotalContractPurchase/100;
                }
                if(FixCost.ASI_CRM_CN_Estimate_Amount_Rate__c == null){
                    FixCost.ASI_CRM_CN_Estimate_Amount_Rate__c = 0;
                    FixCost.ASI_CRM_CN_Estimate_Amount__c = 0;
                }else{
                    FixCost.ASI_CRM_CN_Estimate_Amount__c = FixCost.ASI_CRM_CN_Estimate_Amount_Rate__c * TotalEstimatePurchase/100; 
                }
            }else{
                if (FixCost.ASI_CRM_CN_Contract_Amount__c == null) {
                    FixCost.ASI_CRM_CN_Contract_Amount__c = 0;
                }
                if (FixCost.ASI_CRM_CN_Estimate_Amount__c == null) {
                    FixCost.ASI_CRM_CN_Estimate_Amount__c = 0;
                }
            }
            TotalContractAmount += FixCost.ASI_CRM_CN_Contract_Amount__c;
            TotalEstimateAmount += FixCost.ASI_CRM_CN_Estimate_Amount__c;
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ReturnList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();


        //Sub-Brand Id,Vol
        Map<String, Decimal> BRSFContractVolMap = new Map<String, Decimal>();
        Map<String, Decimal> BRSFEstimateVolMap = new Map<String, Decimal>();


        Set<String> SubBrandIdSet = new Set<String> ();
        //First time looping getting all subBrand Id Set
        for (String key : BRSFItemMap.DetailLineMap.keySet()) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine = BRSFItemMap.DetailLineMap.get(key);
            if (BRSFLine.ASI_CRM_CN_Sub_Brand__c != null) {
                SubBrandIdSet.add(BRSFLine.ASI_CRM_CN_Sub_Brand__c);
            }
        }

        for (String key : PSF_Item_Map.keySet()) {

            if (PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                //key is the module Id, keyline is the Line Id,
                //Checking Null Value
                for (String keyline : PSF_Item_Map.get(key).DetailLineMap.keySet()) {
                    Id subBrandId = PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Sub_Brand__c;
                    if (subBrandId != null) {
                        SubBrandIdSet.add(subBrandId);
                    }
                }
            }
        }

        Decimal BRSFContractMonthlyQty = 0;
        Decimal BRSFEstimateMonthlyQty = 0;
        Decimal BRSFContractTotalQty = 0;
        Decimal BRSFEstimateTotalQty = 0;
        Decimal BRSFContractPurchaseValue = 0;
        Decimal BRSFEstimatePurchaseValue = 0;

        Map<String, ASI_MFM_Sub_brand__c> SubBrandMap = new Map<String, ASI_MFM_Sub_brand__c> ([
            SELECT Id,Name,ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_MFM_Brand__c,ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__c,
                ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_CN_Sub_brand_Grade__c
            FROM ASI_MFM_Sub_brand__c
            WHERE Id IN:SubBrandIdSet
        ]);

        Map<String, Decimal> CR12FactorMap = GenerateCR12FactorMap(SubBrandIdSet);

        if (UpsertPermission) {
            //*************************Looping the BRSF*************************
            coun = 1;
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine : BRSFItemMap.DetailLineMap.values()) {
                BRSFLine = SetAmountToZero(BRSFLine);

                BRSFContractMonthlyQty += BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c;
                BRSFEstimateMonthlyQty += BRSFLine.ASI_CRM_CN_Est_Monthly_Qty__c;
                BRSFContractTotalQty += BRSFLine.ASI_CRM_Contract_Total_QTY_std_Btl__c;
                BRSFEstimateTotalQty += BRSFLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                BRSFContractPurchaseValue += BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                BRSFEstimatePurchaseValue += BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c;

                if (BRSFLine.ASI_CRM_CN_Sub_Brand__c == null) {
                    ErrorHandling(String.format(Label.ASI_CRM_CN_Blank_Subbrand_Line, new List<String>{Label.ASI_CRM_CN_Volume_Value_Target,String.valueOf(coun)}));//Please Input Sub-Brand in BRSF in line.
                    continue;
                }
                if (!BRSFContractVolMap.containsKey(BRSFLine.ASI_CRM_CN_Sub_Brand__c) && BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c != null) {
                    BRSFContractVolMap.put(BRSFLine.ASI_CRM_CN_Sub_Brand__c, BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c);
                } else if (BRSFContractVolMap.containsKey(BRSFLine.ASI_CRM_CN_Sub_Brand__c)) {
                    if (SubBrandMap.containsKey(BRSFLine.ASI_CRM_CN_Sub_Brand__c)) {
                        ErrorHandling(Label.ASI_CRM_CN_Duplicate_Sub_brand_BRSF + SubBrandMap.get(BRSFLine.ASI_CRM_CN_Sub_Brand__c).Name);//'Please found the duplicated in BRSF in Sub-Brand : '
                    } else {
                        ErrorHandling(Label.ASI_CRM_CN_Duplicate_Sub_brand_BRSF + String.valueOf(coun));//'Please found the duplicated in BRSF in Sub-Brand '
                    }
                }
                if (!BRSFEstimateVolMap.containsKey(BRSFLine.ASI_CRM_CN_Sub_Brand__c) && BRSFLine.ASI_CRM_CN_Est_Monthly_Qty__c != null) {
                    BRSFEstimateVolMap.put(BRSFLine.ASI_CRM_CN_Sub_Brand__c, BRSFLine.ASI_CRM_CN_Est_Monthly_Qty__c);
                }


                if (BRSFModule != null) {
                    BRSFLine.ASI_CRM_Module__c = BRSFModule.Id;
                }


                if (UpsertPermission) {
                    ReturnList.add(BRSFLine);
                }
                coun++;

            }

            // It current contract is a child PO, its BRSF total cannot exceed Parent PO
            if (ContractSelected.ASI_CRM_CN_Group_Contract__c != null) {
                String groupPOName = ContractSelected.ASI_CRM_CN_Group_Contract__r.Name;

                if (BRSFModule.ASI_CRM_CN_Volume_Value_Base__c == 'Volume') {
                    Decimal groupPOContractTotalQty = ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_BRSF_Total_Con_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_No_of_Months__c;
                    Decimal groupPOEstimateTotalQty = ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_BRSF_Total_Est_Monthly_Qty__c * ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_No_of_Months__c;
                    if (groupPOContractTotalQty != null && BRSFContractTotalQty > groupPOContractTotalQty) {
                        ErrorHandling('Contract Monthly Quantity cannot exceed parent PO ' + groupPOName);
                    }
                    if (groupPOEstimateTotalQty != null && BRSFEstimateTotalQty > groupPOEstimateTotalQty) {
                        ErrorHandling('Estimate Monthly Quantity cannot exceed parent PO ' + groupPOName);
                    }

                }
                if (BRSFModule.ASI_CRM_CN_Volume_Value_Base__c == 'Value') {
                    Decimal groupPOContractPurchaseValue = ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_Contract_Total_Dummy__c;
                    Decimal groupPOEstimatePurchaseValue = ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_Est_Total_Dummy__c;
                    System.debug(BRSFContractPurchaseValue);
                    System.debug(groupPOContractPurchaseValue);
                    System.debug(BRSFEstimatePurchaseValue);
                    System.debug(groupPOEstimatePurchaseValue);

                    if (groupPOContractPurchaseValue != null && BRSFContractPurchaseValue > groupPOContractPurchaseValue) {
                        ErrorHandling('Contract Purchase Value cannot exceed parent PO ' + groupPOName);
                    }
                    if (groupPOEstimatePurchaseValue != null && BRSFEstimatePurchaseValue > groupPOEstimatePurchaseValue) {
                        ErrorHandling('Estimate Purchase Value cannot exceed parent PO ' + groupPOName);
                    }
                }
            }


            //*************************************Looping the PSF*************************************
            for (interimData interimData : PSF_Item_Map.values()) {
                String methodology = MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c).Name;


                Integer lineIndex = 0;
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                    lineIndex++;

                    lineItem.ASI_CRM_CN_Contract__c = ContractSelected.Id;

                    lineItem.ASI_CRM_Module__c = interimData.Module.Id;

                    if (lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0) {
                        Decimal CR12Factor = CR12FactorMap.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)? CR12FactorMap.get(lineItem.ASI_CRM_CN_Sub_Brand__c) : 1;
                        lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c * CR12Factor;
                    }
                    if (lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0) {
                        Decimal CR12Factor = CR12FactorMap.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)? CR12FactorMap.get(lineItem.ASI_CRM_CN_Sub_Brand__c) : 1;
                        lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c * CR12Factor;
                    }


                    if (UpsertPermission) {
                        ReturnList.add(lineItem);
                    }

                    TotalContractAmount += lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
                    TotalEstimateAmount += lineItem.ASI_CRM_CN_Est_Total_Dummy__c;

                }//End of looping PSF Line in module
            }

            if(IsDolphinContract){
                calGuidelinePercent();
                //contractAmount validate 
                if((ContractSelected.ASI_CRM_CN_Contract_Classification__c == 'A' || ContractSelected.ASI_CRM_CN_Contract_Classification__c == 'B') && TotalContractAmount >= customSetting.ASI_CRM_CN_Dolphin_Online_Cont_Threshold__c){
                    ContractSelected.ASI_CRM_CN_Use_PRC_Contract_Template__c = true;
                }
                //estamount validate
                if(TotalEstimateAmount > TotalContractAmount*customSetting.ASI_CRM_CN_Dolphin_POModi_Threshold__c/100){
                    if(isPOModi){
                        ShowWarning = true;
                        WarningMsg += String.format(Label.ASI_CRM_CN_Modify_Poamount_Validation,new List<String>{String.valueOf(customSetting.ASI_CRM_CN_Dolphin_POModi_Threshold__c)}) + '<br/> ';
                    }else{
                        ShowWarning = true;
                        WarningMsg += String.format(Label.ASI_CRM_CN_EstAmount_Validation,new List<String>{String.valueOf(customSetting.ASI_CRM_CN_Dolphin_POModi_Threshold__c)}) + '<br/> ';
                    }
                    
                }
                //percent validation
                if(EstGuidelinePercent > customSetting.ASI_CRM_CN_Dolphin_PO_Default_Guideline__c){
                    IsOverEstGuideline = true;
                }
                if(ContractGuidelinePercent > customSetting.ASI_CRM_CN_Dolphin_PO_Default_Guideline__c){
                    //IsOverContractGuideline = true;
                    ShowWarning = true;
                    WarningMsg += String.format(Label.ASI_CRM_CN_Dolphin_PO_Guideline_Validation,new List<String>{String.valueOf(customSetting.ASI_CRM_CN_Dolphin_PO_Default_Guideline__c)}) + '<br/> ';
                }
            }

            if (ShowWarning) {
                WarningTimes++;
            }


            //********************************************Looping the Display items***********************************************
            for (interimData interimData : DisplayListingItemMap.values()) {

                Integer lineIndex = 1;
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c DisplayLine : interimData.DetailLineMap.values()) {
                    // For new module, you only have module Id now after saving them
                    DisplayLine.ASI_CRM_Module__c = interimData.Module.Id;
                    if (UpsertPermission) {
                        ReturnList.add(DisplayLine);
                    }

                    lineIndex++;
                }
            }// end of looping VEC


        }
        return ReturnList;

    }


    /**
     * A method to set every null value to zero. So there will be no null point exception
     *
     * @param lineItem
     *
     * @return
     */
    private ASI_CRM_CN_Contract_BRSF_Line_Item__c SetAmountToZero(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem) {
        lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c == null? 0 : lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c;
        lineItem.ASI_CRM_CN_Est_Monthly_Qty__c = lineItem.ASI_CRM_CN_Est_Monthly_Qty__c == null? 0 : lineItem.ASI_CRM_CN_Est_Monthly_Qty__c;
        lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c == null? 0 : lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c;
        lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c == null? 0 : lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c;
        lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null? 0 : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
        lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null? 0 : lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
        lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c == null? 0 : lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
        lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Est_Total_Dummy__c == null? 0 : lineItem.ASI_CRM_CN_Est_Total_Dummy__c;
        lineItem.ASI_CRM_CN_Contract_Purchase_Value__c = lineItem.ASI_CRM_CN_Contract_Purchase_Value__c == null? 0 : lineItem.ASI_CRM_CN_Contract_Purchase_Value__c;
        lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c = lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c == null? 0 : lineItem.ASI_CRM_CN_Estimate_Purchase_Value__c;
        return lineItem;
    }


    public void ErrorHandling(String ErrorMsg) {
        msg += ErrorMsg + '<br/> ';
        //msg='Error,Can not Save!';
        UpsertPermission = false;
    }
    public void ErrorHandling(String ErrorMsg, List<String> formats) {
        msg += String.format(ErrorMsg, formats) + '<br/> ';
        //msg='Error,Can not Save!';
        UpsertPermission = false;
    }

    private void SettingDefaultValue() {
        msg = '';
        UpsertPermission = true;
    }

    public PageReference CancelProcess() {
        PageReference pageRef = new PageReference('/' + PageId);

        UpsertPermission = true;
        pageRef.setRedirect(true);
        return pageRef;
    }


    // shared function
    public String newCounterCreatorLine() {

        String idNew;
        if (LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
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


    // @description: get Pick List Value by 'DescribeFieldResult' such as : getPickListValue(ASI_CRM_KR_A_P_Guideline__c.ASI_CRM_KR_Activity_Type__c.getDescribe());
    public List<SelectOption> getPickListValue(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> Selectoptions = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            Selectoptions.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return Selectoptions;
    }

    /**
     * Return a map with key = picklist Value, value = SelectOption
     *
     * @param fieldResult
     *
     * @return
     */
    public Map<String, SelectOption> getPickListValueMap(Schema.DescribeFieldResult fieldResult) {
        Map<String, SelectOption> selectOptions = new Map<String, SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            selectOptions.put(f.getValue(), new SelectOption(f.getValue(), f.getLabel()));
        }
        return selectOptions;
    }

    //*********************************************************
    //@description: Add All Child Outlets  in one time
    //@param: Null
    //@return: Null
    // *********************************************************
    public void AddAllChildOutlets() {
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        Set<Id> outletIds = new Set<Id>();

        String recordType = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName;

        if (recordType != 'ASI_CRM_Outlet_CN') {
            return;
        }

        for (ASI_CRM_CN_Covered_Outlet__c s : CoveredOutlet_Item_Map.values()) {
            outletIds.add(s.ASI_CRM_CN_Outlet__c);
        }


        for (ASI_CRM_AccountsAdditionalField__c customer : [
            SELECT Id
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE
            ASI_CRM_CN_Parent_Outlet__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c
            AND Id NOT IN :outletIds
            LIMIT 1000
        ]) {
            // If covered outlet list already contains this outlet, don't create a new record
            if (outletIds.contains(customer.Id)) {
                continue;
            }
            outlet = new ASI_CRM_CN_Covered_Outlet__c(
                ASI_CRM_CN_Outlet__c = customer.Id,
                ASI_CRM_CN_Contract__c = ContractSelected.Id,
                ASI_CRM_CN_Selected_Covered_Outlet__c = true
            );


            CoveredOutlet_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), outlet);
        }
    }

    public Integer getNumberOfCoveredOutlets() {
        return CoveredOutlet_Item_Map.size();
    }

    //*******************************************************************************************************
    //* @description custom class for PSF and Display
    // ********************************************************************************************************
    public class interimDataDto {

        public ASI_CRM_Module__c Module { set; get; }
        // Set to true after clicking Refresh or created from existing module
        public Boolean moduleReadOnly { set; get; }
        public Boolean showLineItems { set; get; }
        public Boolean isCreatedInCurrentVersion { set; get; }
        public String MethodologyDisplay  {set;get;} {MethodologyDisplay='';}
        public Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap { set; get; }

        public interimDataDto(interimData d) {
            Module = d.Module;
            moduleReadOnly = d.moduleReadOnly;
            showLineItems = d.showLineItems;
            DetailLineMap = d.DetailLineMap;
            isCreatedInCurrentVersion = d.isCreatedInCurrentVersion;
        }



    }
    public class interimData {
        public ASI_CRM_Module__c Module { set; get; }
        // Set to true after clicking Refresh or created from existing module
        public Boolean moduleReadOnly { set; get; }
        public Boolean showLineItems { set; get; }
        public Boolean isCreatedInCurrentVersion  {set;get;} {isCreatedInCurrentVersion = true;}
        public String MethodologyDisplay  {set;get;} {MethodologyDisplay='';}
        public List<SelectOption> MethodologyPicklist { set; get; }
        public List<SelectOption> VolumeValueBasePickList { set; get; }

        public Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap { set; get; }

        public interimData() {
            this.Module = new ASI_CRM_Module__c();
            DetailLineMap = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly = true;
        }
        public interimData(Boolean ClickRefresh) {
            this.Module = new ASI_CRM_Module__c();
            this.DetailLineMap = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly = ClickRefresh;
        }

        public interimData(ASI_CRM_Module__c ModuleInput) {
            this.Module = ModuleInput;
            this.DetailLineMap = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly = true;
            this.showLineItems = true;
        }

        public interimData(ASI_CRM_Module__c ModuleInput, Boolean ClickRefresh) {
            this.Module = ModuleInput;
            this.DetailLineMap = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly = ClickRefresh;
            this.isCreatedInCurrentVersion = true;
        }

        public void updateMethodologyDisplay(Boolean showCN) {
            MethodologyDisplay = showCN? Module.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c : Module.ASI_CRM_Methodology__r.Name;
        }

        public interimData copyFromDTO(interimDataDto dto) {
            this.DetailLineMap = dto.DetailLineMap;
            return this;
        }
    }


    @RemoteAction
    public static List<SObject> FindSubBrandList(String obj, String qry, String CommercialTeam, String Region, String CityTier) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {// Object name not valid
            return null;
        }
        // create the filter text
        String filter = qry;
        //begin building the dynamic soql query
        String soql = 'select Id, Name,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Incentive_Central__c,ASI_CRM_Incentive_East__c,ASI_CRM_Incentive_North__c,ASI_CRM_Incentive_North_West__c  from ' + obj;
        if (String.isNotEmpty(filter)) {
            soql += filter;
        }
        soql += ' order by Name';

        List<SObject> sobjs = new List<SObject>();


        try {
            Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap = new Map<String, ASI_CRM_Sub_Brand_Grade__c>();

            for (ASI_CRM_Sub_Brand_Grade__c sbg : ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(CommercialTeam, Region)) {
                if (sbg.ASI_CRM_CN_City_Tier__c != null) {
                    SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c + ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
                } else {
                    SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
                }
            }


            //ASI_CRM_Max_Incentive__c,ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Incentive_for_PSF__c
            sobjs = Database.query(soql);


            for (SObject SubBrand : sobjs) {
                Decimal BRSFIncentive = 0.0;
                Decimal PSFIncentive = 0.0;
                Decimal BRSFMaxIncentive = 99999999;
                Decimal PSFMaxIncentive = 99999999;

                if (SubBrand.getSObject('ASI_CRM_CN_Sub_brand_Grade__r') != null) {
                    String SubBrandGradeName = (String) SubBrand.getSObject('ASI_CRM_CN_Sub_brand_Grade__r').get('Name');
                    String ExternalKey = (String) SubBrand.getSObject('ASI_CRM_CN_Sub_brand_Grade__r').get('Name');
                    ExternalKey += Region != null? Region : '';
                    ExternalKey += CommercialTeam != null? CommercialTeam : '';

                    String CityTierExternalKey = ExternalKey;
                    if (CityTier != null) {
                        CityTierExternalKey += ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(CityTier) ;
                    }

                    if (SubBrandGradeMap.containsKey(CityTierExternalKey)) {
                        BRSFIncentive = SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
                        PSFIncentive = SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Incentive_for_PSF__c;
                        BRSFMaxIncentive = SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;
                        PSFMaxIncentive = SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
                    } else if (SubBrandGradeMap.containsKey(ExternalKey)) {
                        BRSFIncentive = SubBrandGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
                        PSFIncentive = SubBrandGradeMap.get(ExternalKey).ASI_CRM_Incentive_for_PSF__c;
                        BRSFMaxIncentive = SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
                        PSFMaxIncentive = SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
                    } else if (SubBrandGradeMap.containsKey(SubBrandGradeName)) {
                        BRSFIncentive = SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_CN_Incentive__c;
                        PSFIncentive = SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Incentive_for_PSF__c;
                        BRSFMaxIncentive = SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
                        PSFMaxIncentive = SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive_for_PSF__c;
                    }

                    SubBrand.put('ASI_CRM_Incentive_Central__c', BRSFIncentive); //BRSF Incentive
                    SubBrand.put('ASI_CRM_Incentive_East__c', BRSFMaxIncentive); //BRSF Max Incentive
                    SubBrand.put('ASI_CRM_Incentive_North__c', PSFIncentive); //PSF Incentive
                    SubBrand.put('ASI_CRM_Incentive_North_West__c', PSFMaxIncentive); //PSF Max Incentive

                }

            }
            return sobjs;
        } catch (QueryException e) {

            ASI_MFM_ByPass_Setting.ErrorHandling('RemoteAction.ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList class have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_EditHeavyContractDetailCtrl', 'failed! ');


            return null;
        }
        //        return sobjs;
    }
    public static Set<Id> pluckIds(Schema.SObjectField field, List<SObject> records) {
        Set<Id> results = new Set<Id>();
        for (SObject rec : records) {
            Id value = (Id) rec.get(field);
            if (value != null) {
                results.add(value);
            }
        }
        return results;
    }

    public void reCalPurchaseValue(){
        TotalContractPurchase = 0;
        TotalEstimatePurchase = 0;
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : BRSFItemMap.DetailLineMap.values()){
            TotalContractPurchase = TotalContractPurchase+lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
            TotalEstimatePurchase = TotalEstimatePurchase+lineItem.ASI_CRM_CN_Est_Total_Dummy__c;
        }
    }

    public void reCalOtherCost(){
        for(ASI_CRM_Contract_Cost__c line : LFixCost){
            line.ASI_CRM_CN_Contract_Amount__c = TotalContractPurchase*line.ASI_CRM_CN_Contract_Amount_Rate__c/100;
            line.ASI_CRM_CN_Estimate_Amount__c = TotalEstimatePurchase*line.ASI_CRM_CN_Estimate_Amount_Rate__c/100;
        }
    }

    public void calGuidelinePercent(){
        ContractGuidelinePercent = 0;
        EstGuidelinePercent = 0;
        for (interimData interimData : PSF_Item_Map.values()) {
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()){
                ContractGuidelinePercent += lineItem.ASI_CRM_CN_Rebate_Percent__c;
                EstGuidelinePercent += lineItem.ASI_CRM_CN_Rebate_Percent__c;
            }
        }
        for(ASI_CRM_Contract_Cost__c line : LFixCost){
            ContractGuidelinePercent += line.ASI_CRM_CN_Contract_Amount_Rate__c;
            EstGuidelinePercent += line.ASI_CRM_CN_Estimate_Amount_Rate__c;            
        }
    }
}