/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_ViewContractOffCtrl
 * Description: Apex class for ASI_CRM_CN_ViewContractOffCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-08-21       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_ViewContractOffCtrl {

    public void Calculation() {

        if(ContractSelected.ASI_CRM_System_Debug__c){
            if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(ContractSelected);
                ASI_CRM_CN_OffContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);

            }else{
                ASI_CRM_CN_OffContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);
                ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalPOModiFIData(ContractSelected);
            }
        }else{
            try{
                if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                    ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(ContractSelected);
                    if(!ContractSelected.ASI_CRM_Heap_Size_Large__c) ASI_CRM_CN_OffContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
                }else{//!='0.0'
                    ASI_CRM_CN_OffContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);
                    if(!ContractSelected.ASI_CRM_Heap_Size_Large__c) ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalPOModiFIData(ContractSelected);
                }
            }catch(Exception e){
                System.debug(e.getStackTraceString());
                System.debug(e.getMessage());
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData <br/> in ASI_CRM_CN_ViewContractOffPage class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewContractOffCtrl','Calculation function failed! with contract Id: '+ContractSelected.Id + ' stack: ' + e.getStackTraceString());
            }
        }
    }


    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public Boolean showPOModification {set;get;}
    public Boolean showRestorePO {set;get;}
    public Boolean makePayment {set;get;}
    public Boolean PSFNoModules  {set;get;}
    public Boolean DisplayNoModules  {set;get;}

    public Decimal totalEstimate=0;
    public Boolean showSuggestedAmountAndTargetVolume { get; set; } {showSuggestedAmountAndTargetVolume=false;}
    //Fix cost
    public List<ASI_CRM_Contract_Cost__c> LFixCost {set;get;}

    //BRSF
    public interimData BRSFItemMap {set;get;} {BRSFItemMap= new interimData();}
    public Decimal maxMargin { set; get; }

    //PSF
    public Map<String, interimData> PSF_Item_Map {set;get;} {PSF_Item_Map= new Map<String, interimData>();}

    //Display Listing
    public Map<String, interimData> DisplayListingItemMap {set;get;} {DisplayListingItemMap= new Map<String, interimData>();}


    public List<ASI_CRM_CN_Covered_Outlet__c> ContractOutletList {set;get;} {ContractOutletList = new List<ASI_CRM_CN_Covered_Outlet__c> (); }
    public Boolean ShowCoveredOutlet {set;get;} {ShowCoveredOutlet =false;}

    public List<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList{set;get;}
    public Boolean ShowPaymentList {set;get;} {ShowPaymentList =false;}

    public Decimal HistoricalBRSFEstimateTotal {set;get;} {HistoricalBRSFEstimateTotal=0;}
    public Map<String, ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_Item_Map {set;get;}{CoveredOutlet_Item_Map= new Map<String, ASI_CRM_CN_Covered_Outlet__c>();}
    //@description : new line count
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public Boolean ValidateTotalSuggestedAmount=false;

    public Boolean IsRBAUser {set;get;} {IsRBAUser=false;}
    public Boolean showReturn {set;get;} {showReturn=false;}
    public Boolean inBAPermissionSet {set;get;} {inBAPermissionSet = false;}
    public Boolean isPOModi {get;set;}
    public Boolean isGroupPo {get;set;}

    public String PageId {set;get;}
    public Boolean showCN {set;get;}
    public Boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public String Msg {get;set;} {Msg='';}
    public Boolean IsDolphinContract{get;set;}{IsDolphinContract=false;}
    public Boolean IsOverContractGuideline{get;set;}{IsOverContractGuideline=false;}
    public Boolean IsOverEstGuideline{get;set;}{IsOverEstGuideline=false;}
    public Decimal ContractGuidelinePercent{get;set;}{ContractGuidelinePercent=0;}
    public Decimal EstGuidelinePercent{get;set;}{EstGuidelinePercent=0;}
    public ASI_CRM_CN_CustomSetting__c customSetting{get;set;}
    
    public ASI_CRM_CN_ViewContractOffCtrl (ApexPages.StandardController controller) {
        //Variables Initialization
        showCN = UserInfo.getLanguage()=='zh_CN';
        showPOModification = false;
        showRestorePO  = false;
        makePayment = false;
        this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
        if(this.ContractSelected != null)
            PageId = ContractSelected.Id;



        if([SELECT Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name ='ASI_CRM_CN_General_BA' AND AssigneeId = :UserInfo.getUserId()].size()>0){
            inBAPermissionSet = true;
        }

        this.ContractSelected = [SELECT
            ASI_CRM_Active_Dummy_PO__c,
            ASI_CRM_Auto_PO_Modification__c,
            ASI_CRM_Auto_PO_Modification_Time__c,
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
            ASI_CRM_CN_Last_PO_version__c,
            ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
            ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
            ASI_CRM_CN_Last_Rejected_Date__c,
            ASI_CRM_CN_Last_Submitted_Date__c,
            ASI_CRM_CN_Local_Group_Contract__c,
            ASI_CRM_CN_National_Group_Contract__c,
            ASI_CRM_CN_No_of_Months__c,
            ASI_CRM_CN_Outlet_WS__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.Name,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,
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
            ASI_CRM_CN_Use_PRC_Contract_Template__c,
            ASI_CRM_CN_V0_0_PO_version__c,
            ASI_CRM_CN_V0_Display_Contract_Total__c,
            ASI_CRM_CN_Vol_Budget_LE__c,
            ASI_CRM_Contract_Template_Id__c,
            ASI_CRM_Display_Estimate_Adjustment_Amt__c,
            ASI_CRM_EVC_Cost_Estimate_Total__c,
            ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
            ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,
            ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
            ASI_CRM_Heap_Size_Large__c,
            ASI_CRM_Investment_Type__c,
            ASI_CRM_Last_RBA_Approver__c,
            ASI_CRM_Martell_BC_Rate__c,
            ASI_CRM_National_Group__c,
            ASI_CRM_National_Group__r.Name,
            ASI_CRM_New_FY_PO__c,
            ASI_CRM_PO_Channel__c,
            ASI_CRM_PO_City__c,
            ASI_CRM_PO_City__r.Name,
            ASI_CRM_PO_Province__c,
            ASI_CRM_Prev_Version_Display_Est_Total__c,
            ASI_CRM_Previous_Version_PSF_Est_Total__c,
            ASI_CRM_PSF_Contract_Adjustment_Amount__c,
            ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
            ASI_CRM_PSF_Grand_Contract_Total__c,
            ASI_CRM_PSF_Grand_Estimate_Total__c,
            ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
            ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
            ASI_CRM_System_Debug__c,
            ASI_CRM_V0_PSF_Contract_Total__c,
            ASI_CRM_Volume_Option__c,
            ASI_TH_CRM_Promotion_Type__c,
            ASI_TH_CRM_Summary_Contract_Spending__c,
            CreatedById,
            CreatedDate,
            Id,
            LastModifiedDate,
            Name,
            Owner.Email,
            OwnerId,
            RecordTypeId,ASI_CRM_CN_Is_Block__c,ASI_CRM_CN_Total_RContract_Amount__c,
            ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Activity_Times__c,ASI_CRM_CN_Target_Base__c,ASI_CRM_CN_Contract_Classification__c,
        (SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
            ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
        FROM ASI_TH_CRM_PaymentRequests_Contract__r)
        FROM ASI_TH_CRM_Contract__c
        WHERE Id =:PageId ];


        if(inBAPermissionSet && ContractSelected.ASI_CRM_CN_Status__c == 'Submitted'){
            showReturn = true;
        }

        PaymentRequestList = ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r;

        if(PaymentRequestList.size()>0){
            ShowPaymentList=true;
        }
        if(ContractSelected.ASI_CRM_CN_Status__c == 'Final'){
            showPOModification = true;
        }
        if(ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Last_PO_version__c != null && !ContractSelected.ASI_CRM_Auto_PO_Modification__c){
            showRestorePO = true;
        }
        if(ContractSelected.ASI_CRM_CN_Status__c == 'Final'){
            makePayment = true;
        }

        init();
    }


    public void init(){
        customSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
            IsDolphinContract = true;
        }
        initSetTotalMarkup();
        if(ContractSelected.ASI_CRM_Last_RBA_Approver__c==UserInfo.getUserId()){
            IsRBAUser=true;
        }
        User u =[SELECT Id,BypassTriggers__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.BypassTriggers__c!=null && u.BypassTriggers__c.contains('CNSetToFinal')){ // select id,Name,BypassTriggers__c from user where id='005M0000006Ghj6'
            IsRBAUser=true;
        }

        isPOModi = ContractSelected.ASI_CRM_CN_PO_Version__c!='0.0';
        isGroupPo = ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Group PO';

        //Contract Cost  Line
        if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
            LFixCost = [SELECT Id, Name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c,ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Contract_Amount_Rate__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Estimate_Amount_Rate__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :PageId ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC];
        }else{
            LFixCost = [SELECT Id, Name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c,ASI_CRM_CN_Contract_Amount_Rate__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Estimate_Amount_Rate__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :PageId AND ASI_CRM_CN_Cost_Type__c = 'Fixed' ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC];            
        }
        System.debug(LoggingLevel.INFO, '*** LFixCost: ' + LFixCost);
        Map<String,ASI_CRM_Module__c> ModuleMap = new Map<String,ASI_CRM_Module__c>(); // Map <Id, ASI_CRM_Module__c>
        for(ASI_CRM_Module__c module : [SELECT Id,ASI_CRM_Remark_Display__c,ASI_CRM_Remark_Options__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c, ASI_CRM_CN_Contract_Volume_Base__c, ASI_CRM_CN_Volume_Value_Base__c, ASI_CRM_CN_Total_Markup__c,
            ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c, ASI_CRM_CN_KPI_Base__c, ASI_CRM_CN_Minimal_Achievement__c, ASI_CRM_CN_Criteria__c,ASI_CRM_CN_Is_Capped__c
        FROM ASI_CRM_Module__c WHERE ASI_CRM_Contract__c =:PageId  ])
        {
            ModuleMap.put(module.Id, module);
            if (module.ASI_CRM_Line_Type__c == 'BRSF') {
                BRSFItemMap.Module = module;
            }
        }
        Set<String> ArchivedModuleId = new Set<String>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ArchivedBRSFList= new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        String ArchivedBRSFModuleId= '';

        //BRSF/PSF Line
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:[SELECT Id,ASI_CRM_Product_Category__r.Name,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Max_Incentive__c ,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c, ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
            ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c,
            ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c, ASI_CRM_CN_Rebate_Percent__c, ASI_CRM_CN_Contract_Purchase_Value__c, ASI_CRM_CN_Estimate_Purchase_Value__c, ASI_CRM_CN_Target__c, ASI_CRM_CN_Rebate__c, ASI_CRM_Line_Name__c, ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c, ASI_CRM_Module__r.ASI_CRM_CN_Volume_Value_Base__c, ASI_CRM_CN_Min_Purchase_Target__c, ASI_CRM_CN_Max_Purchase_Target__c,ASI_CRM_CN_Max_Rebate_Percent__c
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :PageId] )
        {


            if(BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c==null){
                BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0;
            }

            if(BRSFLine.ASI_CRM_Type__c=='BRSF'){
                if(BRSFLine.ASI_CRM_Module__c != null && ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                    BRSFItemMap.Module=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                }else if(BRSFLine.ASI_CRM_Module__c != null){
                    ArchivedBRSFModuleId = BRSFLine.ASI_CRM_Module__c;
                    ArchivedModuleId.add(BRSFLine.ASI_CRM_Module__c);
                }

                BRSFItemMap.DetailLineMap.put(BRSFLine.Id,BRSFLine);
                    if(showCN){
                        BRSFItemMap.MethodologyValue = BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c;
                    }else{
                        BRSFItemMap.MethodologyValue = BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name;
                    }
                    HistoricalBRSFEstimateTotal+=BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
            }

            if(BRSFLine.ASI_CRM_Type__c=='PSF'){


                String LineKey=BRSFLine.Id;
                if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Category'){
                    LineKey=ASI_CRM_CN_OffContractUtilitiesClass.NameSortingASC(BRSFLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) +LineKey;
                }


                if(PSF_Item_Map.containsKey(BRSFLine.ASI_CRM_Module__c)){
                    PSF_Item_Map.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey,BRSFLine);
                }else{
                    if(ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                        interimData TempData= new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
                        PSF_Item_Map.put(BRSFLine.ASI_CRM_Module__c,TempData);
                        PSF_Item_Map.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey,BRSFLine);
                    }else if(BRSFLine.ASI_CRM_Module__c !=null){
                        ArchivedModuleId.add(BRSFLine.ASI_CRM_Module__c);
                        ArchivedBRSFList.add(BRSFLine);
                    }
                }
            }

            if (BRSFLine.ASI_CRM_Type__c == 'Display') {
                String LineKey=BRSFLine.Id;

                if(DisplayListingItemMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                    DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey,BRSFLine);
                }else{
                    if(ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                        interimData TempData= new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
                        DisplayListingItemMap.put(BRSFLine.ASI_CRM_Module__c,TempData);
                        DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey,BRSFLine);
                        DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).Module.ASI_CRM_Contract__c=PageId;
                        DisplayListingItemMap.get(BRSFLine.ASI_CRM_Module__c).MethodologyValue = showCN? BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c : BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name;
                    }else if(BRSFLine.ASI_CRM_Module__c !=null){
                        ArchivedModuleId.add(BRSFLine.ASI_CRM_Module__c);
                        ArchivedBRSFList.add(BRSFLine);
                    }
                }

            }


        }

        if(ArchivedModuleId.size()>0 ){ //&& ArchivedBRSFList.size()>0 
            for(ASI_CRM_Module__c Module: [SELECT Id,ASI_CRM_Remark_Display__c,ASI_CRM_Remark_Options__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c, ASI_CRM_CN_Contract_Volume_Base__c, ASI_CRM_CN_Volume_Value_Base__c, ASI_CRM_CN_Total_Markup__c,
                ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c, ASI_CRM_CN_KPI_Base__c, ASI_CRM_CN_Minimal_Achievement__c, ASI_CRM_CN_Criteria__c,ASI_CRM_CN_Is_Capped__c FROM ASI_CRM_Module__c WHERE Id IN : ArchivedModuleId ]){
                ModuleMap.put(Module.Id,Module);
            }

            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ArchivedBRSFList ){
                Map<String, interimData> interimDataMap = ContractLine.ASI_CRM_Type__c == 'PSF' ? PSF_Item_Map : DisplayListingItemMap;
                if (interimDataMap.containsKey(ContractLine.ASI_CRM_Module__c)) {
                    interimDataMap.get(ContractLine.ASI_CRM_Module__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                }else{
                    if(ModuleMap.containsKey(ContractLine.ASI_CRM_Module__c)){
                        interimData TempData= new interimData(ModuleMap.get(ContractLine.ASI_CRM_Module__c));
                        interimDataMap.put(ContractLine.ASI_CRM_Module__c,TempData);
                        interimDataMap.get(ContractLine.ASI_CRM_Module__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                    }
                }
            }

            if (ArchivedBRSFModuleId != null && ModuleMap.containsKey(ArchivedBRSFModuleId)) {
                BRSFItemMap.Module = ModuleMap.get(ArchivedBRSFModuleId);
            }
        }


        PSFNoModules = PSF_Item_Map.isEmpty();
        DisplayNoModules = DisplayListingItemMap.isEmpty();
        // Covered Outlet
        ContractOutletList = [SELECT Id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Target_Volume_Std_Btl__c ,ASI_CRM_CN_Suggested_Amount__c, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.ASI_CRM_Account__c, ASI_CRM_CN_Allocated_Amount__c, ASI_CRM_CN_Check_All__c, ASI_CRM_CN_Selected_Covered_Outlet__c, ASI_CRM_CN_Target_Volume_9L__c, ASI_CRM_CN_Target_Value__c
        FROM ASI_CRM_CN_Covered_Outlet__c
        WHERE ASI_CRM_CN_Contract__c = :PageId];

        if(ContractOutletList.size()>0){
            ShowCoveredOutlet=true;
            for(ASI_CRM_CN_Covered_Outlet__c Outlet:ContractOutletList){
                CoveredOutlet_Item_Map.put(Outlet.Id,Outlet);
            }
        }


        if(BRSFItemMap.Module == null){
            ASI_CRM_Module__c Module = new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Unit__c='Std. Btl.');
            BRSFItemMap.Module= Module;
        }



        String recordType = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting');
        List<ASI_CRM_SpecialPromotionTypeSetting__c> SpecialPromotionTypeSettingList=[SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c
        FROM ASI_CRM_SpecialPromotionTypeSetting__c
        WHERE  RecordTypeId =: recordType  AND ASI_CRM_Promotion_Type__c ='Heavy Contract On'];
        if(SpecialPromotionTypeSettingList.size()>0){
            showSuggestedAmountAndTargetVolume= SpecialPromotionTypeSettingList[0].ASI_CRM_SuggestedAmount_And_TargetVolume__c;
            ValidateTotalSuggestedAmount= SpecialPromotionTypeSettingList[0].ASI_CRM_Validate_TotalSuggestedAmount__c;
        }

        if(IsDolphinContract){
            calGuidelinePercent();
            if(ContractGuidelinePercent > customSetting.ASI_CRM_CN_Dolphin_PO_Default_Guideline__c){
                IsOverContractGuideline = true;
            }
            if(EstGuidelinePercent > customSetting.ASI_CRM_CN_Dolphin_PO_Default_Guideline__c){
                IsOverEstGuideline = true;
            }
        }

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






    public PageReference GoEditHeaderPage(){
        if (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Group PO') {
            return redirectToPage('/apex/ASI_CRM_CN_OffGroupPOHeaderEditPage?isEditable=1',PageId);
        } else {
            return redirectToPage('/apex/ASI_CRM_CN_OffContractHeaderEditPage',PageId);
        }
    }



    public PageReference GoToContractGenerationPage(){
        if( ContractSelected.ASI_CRM_Contract_Template_Id__c==null){
            Document DocumentFile;
            if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
              DocumentFile = ASI_CRM_CN_HeavyContracFunctionClass.GenerateGeneralContractTemplate('offDolphin',ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,false);
            } else {
              DocumentFile = ASI_CRM_CN_HeavyContracFunctionClass.GenerateOffContractTemplate(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,false);
            }
            ContractSelected.ASI_CRM_Contract_Template_Id__c=DocumentFile!=null?DocumentFile.Id:null;
        }
        try{
            update ContractSelected;
        }catch(Exception e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData <br/> in ASI_CRM_CN_ViewContractOffPage class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Calculation function failed! with contract Id: '+ContractSelected.Id );
        }




        String url='/apex/ASI_CRM_CN_OffContractGenerationPage?edit=1&id='+ContractSelected.Id+'&TemplateId='+ContractSelected.ASI_CRM_Contract_Template_Id__c;
        return new PageReference(url);
    }


    public PageReference submitForApproval() {
        //submit for approval
        if (!Test.isRunningTest()) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(ContractSelected.Id);
            Approval.ProcessResult result = Approval.process(req1);
        }
        return ApexPages.currentPage();
    }

    public PageReference GoCheckPointPage(){
        PageReference redirectPage = new PageReference('/apex/ASI_CRM_CN_OffPDFRedirectPage?id='+PageId+'&Type=SubmitApproval');
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    public PageReference ViewCheckPointPage(){

        PageReference redirectPage = new PageReference('/apex/ASI_CRM_CN_OffPDFRedirectPage?id='+PageId+'&Type=ViewCheckPoint');
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    public PageReference GoEditDetailPage(){
        return redirectToPage('/apex/ASI_CRM_CN_EditContractOffDetailPage',PageId);
    }
    public PageReference GoUploadPage(){
        return redirectToPage('/apex/ASI_CRM_CN_CoveredOutletUploadPage', PageId);
    }

    public PageReference redirectToPage(String pagePath, String pid){

        PageReference redirect = new PageReference(pagePath);
        redirect.getParameters().put('id',pid);
        redirect.setRedirect(true);
        return redirect;
    }




    public PageReference POModification(){
        List<ASI_TH_CRM_Contract__c> cContract = [SELECT Id, ASI_CRM_CN_Status__c, LastModifiedDate FROM ASI_TH_CRM_Contract__c WHERE Id=:ContractSelected.Id LIMIT 1];

        if (cContract[0].ASI_CRM_CN_Status__c == 'Final' && cContract[0].LastModifiedDate == ContractSelected.LastModifiedDate){


            for(ASI_TH_CRM_PaymentRequest__c paymentrequest:ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {
                if( paymentrequest.ASI_TH_CRM_Status__c=='Submitted'){
                    Msg=Label.ASI_CRM_CN_ContractSubmittedPaymentCheckErrMsg;
                    UpsertPermission=false;
                    return null;

                }

            }


            PageReference redirect = new PageReference('/apex/ASI_CRM_CN_OffContractHeaderEditPage');
            redirect.getParameters().put('id',ContractSelected.Id);
            redirect.getParameters().put('POModification','1');
            redirect.setRedirect(true);


            return redirect;
        } else {
            if(UserInfo.getLanguage()=='zh_CN'){
                ErrorHandling('Contract has been modified since last update, Please refresh and do modification again!');
            }else{
                ErrorHandling('请刷新网页，更新PO资料，再PO修改。');
            }

        }

        return null;


    }


    public Integer getNumberOfCoveredOutlets(){
        return CoveredOutlet_Item_Map.size();
    }


    //***************Restore PO******************************************************************
    public PageReference restorePO(){
        PageReference p;
        String returnId = ContractSelected.Id;
        List<ASI_TH_CRM_Contract__c> cContract = [SELECT Id, ASI_CRM_CN_Status__c, LastModifiedDate FROM ASI_TH_CRM_Contract__c WHERE Id=:ContractSelected.Id LIMIT 1];
        if (cContract[0].ASI_CRM_CN_Status__c == 'Draft' && cContract[0].LastModifiedDate == ContractSelected.LastModifiedDate){
            restore(ContractSelected);
            return redirectToPage('/apex/ASI_CRM_CN_ViewContractOffPage',returnId);
        } else {
            if(UserInfo.getLanguage()=='zh_CN')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contract has been modified since last update, Please refresh and restore again!'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'请刷新网页，更新PO资料，再恢复以前的版本。'));

        }

        return null;
    }



    private void restore(ASI_TH_CRM_Contract__c cont){

        List<ASI_TH_CRM_Contract__c> LLastContract = [SELECT Id,Name,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_Auto_PO_Modification_Time__c,
            ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,
            ASI_CRM_Copied_From__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
            ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,  ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_IsClone__c ,ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,RecordTypeId, ASI_CRM_CN_PO_Modification__c ,  ASI_CRM_CN_Contract_Upload__c,ASI_CRM_CN_Business_License__c,ASI_CRM_CN_Last_PO_version__c, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Start_Date__c, ASI_CRM_CN_Return_Comments__c,ASI_CRM_Reject_Return_Comments__c, ASI_CRM_CN_Last_Approved_By__c, ASI_CRM_CN_Last_Approved_Date__c, ASI_CRM_CN_Last_Recall_By__c
            , ASI_CRM_CN_Last_Recall_Date__c, ASI_CRM_CN_Last_Rejected_By__c, ASI_CRM_CN_Last_Rejected_Date__c
            , ASI_CRM_CN_Last_Submitted_By__c, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_National_Group__c, ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_NationalGroup__c,
            ASI_CRM_CN_Expected_Display_Est_Total__c,ASI_CRM_CN_V0_Display_Contract_Total__c, ASI_CRM_CN_Expected_V0_Display_Est_Total__c, ASI_CRM_Prev_Version_Display_Est_Total__c,ASI_CRM_Display_Estimate_Adjustment_Amt__c
            ,ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Target_Base__c,ASI_CRM_CN_Activity_Times__c,ASI_CRM_CN_Contract_Classification__c
        FROM ASI_TH_CRM_Contract__c  WHERE Id = :cont.ASI_CRM_CN_Last_PO_version__c];

        if(LLastContract != null && LLastContract.size()==1){
            cont.Name= LLastContract[0].Name;

            cont.ASI_CRM_EVC_Cost_Estimate_Total__c= LLastContract[0].ASI_CRM_EVC_Cost_Estimate_Total__c;
            cont.ASI_CRM_V0_PSF_Contract_Total__c= LLastContract[0].ASI_CRM_V0_PSF_Contract_Total__c;
            cont.ASI_CRM_Expected_V0_PSF_Estimated_Total__c= LLastContract[0].ASI_CRM_Expected_V0_PSF_Estimated_Total__c;
            cont.ASI_CRM_Previous_Version_PSF_Est_Total__c= LLastContract[0].ASI_CRM_Previous_Version_PSF_Est_Total__c;
            cont.ASI_CRM_CN_Expected_PSF_Est_Total__c= LLastContract[0].ASI_CRM_CN_Expected_PSF_Est_Total__c;
            cont.ASI_CRM_CN_Expected_BRSF_Est_Total__c= LLastContract[0].ASI_CRM_CN_Expected_BRSF_Est_Total__c;
            cont.ASI_CRM_PSF_Estimate_Adjustment_Amount__c= LLastContract[0].ASI_CRM_PSF_Estimate_Adjustment_Amount__c;

            cont.ASI_CRM_CN_Expected_Display_Est_Total__c= LLastContract[0].ASI_CRM_CN_Expected_Display_Est_Total__c;
            cont.ASI_CRM_CN_V0_Display_Contract_Total__c= LLastContract[0].ASI_CRM_CN_V0_Display_Contract_Total__c;
            cont.ASI_CRM_CN_Expected_V0_Display_Est_Total__c= LLastContract[0].ASI_CRM_CN_Expected_V0_Display_Est_Total__c;
            cont.ASI_CRM_Prev_Version_Display_Est_Total__c= LLastContract[0].ASI_CRM_Prev_Version_Display_Est_Total__c;
            cont.ASI_CRM_Display_Estimate_Adjustment_Amt__c= LLastContract[0].ASI_CRM_Display_Estimate_Adjustment_Amt__c;

            cont.ASI_CRM_Auto_PO_Modification__c= LLastContract[0].ASI_CRM_Auto_PO_Modification__c;
            cont.ASI_CRM_Auto_PO_Modification_Time__c= LLastContract[0].ASI_CRM_Auto_PO_Modification_Time__c;

            cont.ASI_CRM_CN_Vol_Budget_LE__c= LLastContract[0].ASI_CRM_CN_Vol_Budget_LE__c;
            cont.ASI_CRM_CN_Status__c= 'Final';
            cont.ASI_CRM_CN_Source_of_Contract__c= LLastContract[0].ASI_CRM_CN_Source_of_Contract__c;
            cont.ASI_CRM_CN_Source_Others__c= LLastContract[0].ASI_CRM_CN_Source_Others__c;
            cont.ASI_CRM_CN_Reason_without_Budget__c= LLastContract[0].ASI_CRM_CN_Reason_without_Budget__c;
            cont.ASI_TH_CRM_Promotion_Type__c= LLastContract[0].ASI_TH_CRM_Promotion_Type__c;
            cont.ASI_CRM_CN_PP_No__c= LLastContract[0].ASI_CRM_CN_PP_No__c;
            cont.ASI_CRM_CN_PO_Version__c= LLastContract[0].ASI_CRM_CN_PO_Version__c;
            cont.ASI_CRM_CN_PO_Start_Date__c= LLastContract[0].ASI_CRM_CN_PO_Start_Date__c;
            cont.ASI_CRM_CN_PO_No__c= LLastContract[0].ASI_CRM_CN_PO_No__c;
            cont.ASI_CRM_CN_PO_End_Date__c= LLastContract[0].ASI_CRM_CN_PO_End_Date__c;
            cont.ASI_CRM_CN_Outlet_WS__c= LLastContract[0].ASI_CRM_CN_Outlet_WS__c;
            cont.ASI_CRM_CN_Exchange_Rate__c= LLastContract[0].ASI_CRM_CN_Exchange_Rate__c;
            cont.ASI_CRM_CN_Description__c= LLastContract[0].ASI_CRM_CN_Description__c;
            cont.ASI_CRM_CN_Currency__c= LLastContract[0].ASI_CRM_CN_Currency__c;
            cont.ASI_CRM_CN_Budget_LE__c= LLastContract[0].ASI_CRM_CN_Budget_LE__c;
            cont.ASI_CRM_CN_Bottle_Collection_Rate__c= LLastContract[0].ASI_CRM_CN_Bottle_Collection_Rate__c;
            cont.ASI_CRM_CN_Effective_Date__c= LLastContract[0].ASI_CRM_CN_Effective_Date__c;
            cont.ASI_CRM_CN_PO_Modification__c = LLastContract[0].ASI_CRM_CN_PO_Modification__c ;
            cont.ASI_CRM_CN_Contract_Upload__c= LLastContract[0].ASI_CRM_CN_Contract_Upload__c;
            cont.ASI_CRM_CN_Last_PO_version__c= LLastContract[0].ASI_CRM_CN_Last_PO_version__c;
            cont.ASI_CRM_CN_Business_License__c = LLastContract[0].ASI_CRM_CN_Business_License__c;
            cont.ASI_TH_CRM_Start_Date__c = LLastContract[0].ASI_TH_CRM_Start_Date__c;
            cont.ASI_TH_CRM_End_Date__c = LLastContract[0].ASI_TH_CRM_End_Date__c;
            cont.ASI_CRM_Reject_Return_Comments__c = LLastContract[0].ASI_CRM_Reject_Return_Comments__c;
            cont.ASI_CRM_CN_Return_Comments__c = LLastContract[0].ASI_CRM_CN_Return_Comments__c;
            cont.ASI_CRM_CN_Last_Approved_By__c = LLastContract[0].ASI_CRM_CN_Last_Approved_By__c;
            cont.ASI_CRM_CN_Last_Approved_Date__c = LLastContract[0].ASI_CRM_CN_Last_Approved_Date__c;
            cont.ASI_CRM_CN_Last_Recall_By__c = LLastContract[0].ASI_CRM_CN_Last_Recall_By__c;
            cont.ASI_CRM_CN_Last_Recall_Date__c = LLastContract[0].ASI_CRM_CN_Last_Recall_Date__c;
            cont.ASI_CRM_CN_Last_Rejected_By__c = LLastContract[0].ASI_CRM_CN_Last_Rejected_By__c;
            cont.ASI_CRM_CN_Last_Rejected_Date__c = LLastContract[0].ASI_CRM_CN_Last_Rejected_Date__c;
            cont.ASI_CRM_CN_Last_Submitted_By__c = LLastContract[0].ASI_CRM_CN_Last_Submitted_By__c;
            cont.ASI_CRM_CN_Last_Submitted_Date__c = LLastContract[0].ASI_CRM_CN_Last_Submitted_Date__c;
            cont.ASI_CRM_National_Group__c = LLastContract[0].ASI_CRM_National_Group__c;
            cont.ASI_CRM_CN_National_Group_Contract__c = LLastContract[0].ASI_CRM_CN_National_Group_Contract__c;
            cont.ASI_CRM_NationalGroup__c = LLastContract[0].ASI_CRM_NationalGroup__c;
            cont.ASI_CRM_Copied_From__c = LLastContract[0].ASI_CRM_Copied_From__c;
            cont.ASI_CRM_CN_IsClone__c = false;
            cont.ASI_CRM_CN_Is_Dolphin__c = LLastContract[0].ASI_CRM_CN_Is_Dolphin__c;
            cont.ASI_CRM_CN_Activity_Times__c = LLastContract[0].ASI_CRM_CN_Activity_Times__c;
            cont.ASI_CRM_CN_Target_Base__c = LLastContract[0].ASI_CRM_CN_Target_Base__c;
            cont.ASI_CRM_CN_Contract_Classification__c = LLastContract[0].ASI_CRM_CN_Contract_Classification__c;
            update cont;
        }
        if(cont.ASI_CRM_CN_Status__c== 'Final'){
            //update cont;
            //---- original child objects ----
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = [SELECT Id FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :cont.Id];
            if(LBRSF != null && LBRSF.size()>0)
                delete LBRSF;
            List<ASI_CRM_Contract_Cost__c> LContractCost = [SELECT Id FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :cont.Id];
            if(LContractCost.size()>0)
                delete LContractCost;
            List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet = [SELECT Id FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :cont.Id];
            if(LCoveredOutlet.size()>0)
                delete LCoveredOutlet;

            List<ASI_CRM_Approval_Comment__c> LComment = [SELECT Id FROM ASI_CRM_Approval_Comment__c WHERE ASI_CRM_Contract__c = :cont.Id];
            if(LCoveredOutlet.size()>0)
                delete LComment;
            // Change lookup for archived child record
            LBRSF = [SELECT Id, ASI_CRM_CN_Contract__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :LLastContract[0].Id];
            if(LBRSF.size()>0){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c itm : LBRSF){
                    itm.ASI_CRM_CN_Contract__c = cont.Id;
                }
                update LBRSF;
            }
            LContractCost = [SELECT Id FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :LLastContract[0].Id];
            if(LContractCost.size()>0){
                for(ASI_CRM_Contract_Cost__c itm : LContractCost ){
                    itm.ASI_CRM_CN_Contract__c = cont.Id;
                }
                update LContractCost;
            }
            LCoveredOutlet = [SELECT Id FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :LLastContract[0].Id];
            if(LCoveredOutlet.size()>0){
                for(ASI_CRM_CN_Covered_Outlet__c itm : LCoveredOutlet ){
                    itm.ASI_CRM_CN_Contract__c = cont.Id;
                }
                update LCoveredOutlet;
            }

            LComment = [SELECT Id FROM ASI_CRM_Approval_Comment__c WHERE ASI_CRM_Contract__c = :LLastContract[0].Id];
            if(LComment.size()>0){
                for(ASI_CRM_Approval_Comment__c itm : LComment ){
                    itm.ASI_CRM_Contract__c = cont.Id;
                }
                update LComment;
            }

            // Change to draft before deleting to comply with only draft can be deleted
            List<ASI_TH_CRM_Contract__c> ContractsNotDraft = new List<ASI_TH_CRM_Contract__c>();
            for(ASI_TH_CRM_Contract__c c : LLastContract){
                if(c.ASI_CRM_CN_Status__c!='Draft') {
                    c.ASI_CRM_CN_Status__c = 'Draft';
                    c.ASI_CRM_CN_PO_Version__c = '0.0';
                    ContractsNotDraft.add(c);
                }
            }
            //update LLastContract;
            update ContractsNotDraft;
            delete LLastContract;
        }
    }




    //Make Payment
    public PageReference GoPayment(){
        UpsertPermission=true;
        Msg = ' ';

        for(ASI_TH_CRM_PaymentRequest__c paymentrequest:ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {
            if(paymentrequest.ASI_CRM_CN_Last_Payment__c==true && paymentrequest.ASI_TH_CRM_Status__c!='Draft'){
                Msg+=Label.ASI_CRM_CN_ErrorMsg_MakePayment+' '+paymentrequest.Name+'<br/>';
                UpsertPermission=false;
                return null;
            }
            if(paymentrequest.ASI_TH_CRM_Status__c=='Draft' || paymentrequest.ASI_TH_CRM_Status__c=='Submitted'){
                Msg+='<br/>'+Label.ASI_CRM_CN_Cannot_make_payment; // Cannot make payment, because system exist Draft or Submitted Payment.
                UpsertPermission=false;
                return null;
            }
        }


        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditHeavyPayment_Header_Page');
        redirect.getParameters().put('contractid',PageId);
        redirect.setRedirect(true);

        return redirect;


    }



    public PageReference UploadCompletion(){

        //ASI_CRM_CN_Last_Approved_Date__c   SELECT ID,createdDate FROM Attachment WHERE ParentId = 'a8cM00000004XRFIA2'
        try{
            ASI_TH_CRM_Contract__c Contract = [SELECT Id,ASI_CRM_CN_Last_Approved_Date__c FROM ASI_TH_CRM_Contract__c WHERE Id=:ContractSelected.Id];
            List<Attachment> AttachmentList  = new List<Attachment>();
            if(Contract.ASI_CRM_CN_Last_Approved_Date__c!=null){
                AttachmentList = [SELECT Id,CreatedDate  FROM Attachment WHERE ParentId = : ContractSelected.Id AND CreatedDate >: Contract.ASI_CRM_CN_Last_Approved_Date__c ];
            }else{
                AttachmentList = [SELECT Id,CreatedDate  FROM Attachment WHERE ParentId = : ContractSelected.Id ];
            }

            if(AttachmentList.size()>0){
                ContractSelected.ASI_CRM_CN_Contract_Upload__c=true;
                update ContractSelected;
                PageReference pageRef = new PageReference('/'+PageId);
                pageRef.setRedirect(true);
                return pageRef;
            }else{
                Msg=System.Label.ASI_CRM_CN_Upload_Contract_Msg;
                UpsertPermission=false;
                return null;
            }
        }catch(DmlException e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in UploadCompletion class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );return null;
        }



    }


    public PageReference UncheckContractUploading(){
        try{
            ContractSelected.ASI_CRM_CN_Contract_Upload__c=false;
            update ContractSelected;
            PageReference pageRef = new PageReference('/'+PageId);
            pageRef.setRedirect(true);
            return pageRef;

        }catch(DmlException e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in UploadCompletion class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );return null;
        }

    }

    public PageReference SetToDraft(){
        try{
            ContractSelected.ASI_CRM_CN_Status__c='Draft';
            update ContractSelected;

            //Sending Final email template to Contract Owner
            User ContractOwner = [SELECT Id, Email FROM User WHERE Id= :ContractSelected.OwnerId ];
            String templateApiName='ASI_CRM_CN_Heavy_Contract_DraftEmail';
            List <String> ToAddresses=  new List <String>();
            Id  templateId = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = : templateApiName].Id;
            ToAddresses.add(ContractOwner.Email);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(ContractSelected.OwnerId);
            email.setToAddresses( ToAddresses );
            email.setWhatId(ContractSelected.Id);
            email.setSaveAsActivity(false);
            email.setBccSender(false);
            email.setUseSignature(false);
            email.setTemplateId(templateId);
            if(!Test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }

        }catch(DmlException e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in SetToDraft class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );
        }
        return null;
    }


    public PageReference SetToFinal() {
        try {

            ASI_TH_CRM_Contract__c Contract = [SELECT Id,ASI_CRM_Last_RBA_Approver__c FROM ASI_TH_CRM_Contract__c WHERE Id = :ContractSelected.Id];
            User u = [SELECT Id,BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId()];
            Boolean BypassFlag = u.BypassTriggers__c != null && u.BypassTriggers__c.contains('CNSetToFinal');

            if (Contract.ASI_CRM_Last_RBA_Approver__c == null) {
                Msg += System.Label.ASI_CRM_CN_Cant_Find_RBA_Msg;
                UpsertPermission = false;
                return null;
            } else if (Contract.ASI_CRM_Last_RBA_Approver__c != UserInfo.getUserId() && !BypassFlag) {
                Msg += 'You are not RBA, cannot change this contract to Final.';
                UpsertPermission = false;
                return null;
            } else {
                ContractSelected.ASI_CRM_CN_Status__c = 'Final';
                update ContractSelected;

                PageReference pageRef = new PageReference('/' + PageId);
                pageRef.setRedirect(true);
                return pageRef;
            }

        } catch (DmlException e) {
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in UploadCompletion class have Error  ' + 'Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_ViewHeavyContractCtrl', 'Contract Id: ' + PageId);return null;
        }

    }

    public PageReference GoReturn(){
        List<ASI_TH_CRM_Contract__c> LContract = [SELECT ASI_CRM_CN_Return_Comments__c FROM ASI_TH_CRM_Contract__c WHERE Id=:PageId LIMIT 1];
        if(LContract[0].ASI_CRM_CN_Return_Comments__c != ''){
            try{
                LContract[0].ASI_CRM_CN_Return_Comments__c = '';
                update LContract[0];
            }catch(DmlException e){
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in GoReturn class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );

            }
        }


        PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_HeavyReturnContractByBAPage?scontrolCaching=1&id='+PageId);
        pageRef.setRedirect(true);
        return pageRef;

    }


    public void ErrorHandling(String ErrorMsg){
        Msg += ErrorMsg + '<br/> ';
        //msg='Error,Can not Save!';
        UpsertPermission = false;
    }

    // shared function
    public String newCounterCreatorLine() {

        String idNew;
        if(LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            LINE_ITEM_NEWRECORD_COUNTER+=1;
        }

        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;

        if(LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }

        idNew = zParser + String.valueOf(oneDigitCounter);
        return idNew;

    }



    //*******************************************************************************************************
    //* @description custom class for PSF
    // ********************************************************************************************************
    public class interimData{
        public ASI_CRM_Module__c Module {set;get;}
        public Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}
        public String MethodologyValue  {set;get;} {MethodologyValue='';}

        public interimData(){
            Module=new ASI_CRM_Module__c();
            this.MethodologyValue='';
            DetailLineMap= new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        public interimData( ASI_CRM_Module__c ModuleInput){
            Module=ModuleInput;
            this.MethodologyValue='';
            DetailLineMap= new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }


    }

    //Cancel the record
    public PageReference CancelProcess(){
        PageReference pageRef = null;
        pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef;
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