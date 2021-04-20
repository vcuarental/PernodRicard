/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromotionContractCtrl
 * Description: Apex class for ASI_CRM_CN_PromotionContractCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-11-08       Keith Yip               Created
 ****************************************************************************************************************************/
public class ASI_CRM_CN_PromotionContractCtrl {

    public void Calculation() {

        if(ContractSelected.ASI_CRM_System_Debug__c){
            if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                if(!Test.isRunningTest()) ASI_CRM_CN_PromotionContractUtilClass.RestructureCurrentFinancialIndicatorData(ContractSelected);

            }else{
                ASI_CRM_CN_PromotionContractUtilClass.ReconstructCurrentPOModiFIData(ContractSelected, null);
            }
        }else{
            //try{
                if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                    if(!ContractSelected.ASI_CRM_Heap_Size_Large__c) ASI_CRM_CN_PromotionContractUtilClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
                }else{//!='0.0'
                    if(!Test.isRunningTest()) ASI_CRM_CN_PromotionContractUtilClass.ReconstructCurrentPOModiFIData(ContractSelected, null);
                    //if (ASI_CRM_CN_PromotionContractUtilClass.outletThreshold() <= this.CoveredOutlet_Item_Map.size() && Date.today() <= ContractSelected.ASI_CRM_CN_PO_End_Date__c && Date.today() >= ContractSelected.ASI_CRM_CN_PO_Start_Date__c) {
                    if (ASI_CRM_CN_PromotionContractUtilClass.outletThreshold() <= this.CoveredOutlet_Item_Map.size() && Date.today() >= ContractSelected.ASI_CRM_CN_PO_Start_Date__c) {
                        if(ASI_CRM_CN_PromotionContractUtilClass.GetLatestAggregationDataDate(ContractSelected)< Date.today()) {
                            Database.executeBatch(new ASI_CRM_CN_PromoVolumeAggregationJob(true, new Set<Id>{
                                    ContractSelected.Id
                            }));
                        }
                    }
                }
            /*}catch(Exception e){
                System.debug(e.getStackTraceString());
                System.debug(e.getMessage());
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_PromotionContractUtilClass.RestructureHistoricalFinancialIndicatorData <br/> in ASI_CRM_CN_ViewContractOffPage class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_PromotionContractCtrl','Calculation function failed! with contract Id: '+ContractSelected.Id + ' stack: ' + e.getStackTraceString());
            }*/
        }
    }

    public String PageId {set;get;}
    
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}

    /*
        Author:Bowen
        Date : 2019-12-26
        Function : VF前端页面真分页参数
    */
    public Decimal BRSF_SumNum {get;set;}{BRSF_SumNum = 0;} // BRSF数据总数
    public Decimal PSF_SumNum {get;set;}{PSF_SumNum = 0;} // PSF数据总数
    // public Decimal Display_SumNum {get;set;}{Display_SumNum = 0;} // Display数据总数

    public Decimal BRSF_SumNumPage {get;set;}{BRSF_SumNumPage = 1;}  // BRSF总页面数
    public Decimal PSF_SumNumPage {get;set;}{PSF_SumNumPage = 1;}  // PSF总页面数
    // public Decimal Display_SumNumPage {get;set;}{Display_SumNumPage = 1;}  // Display总页面数

    public Decimal BRSF_totalNumPage {get;set;}{BRSF_totalNumPage = 1;} // BRSF当前页面数
    public Decimal PSF_totalNumPage {get;set;}{PSF_totalNumPage = 1;} // PSF当前页面数
    // public Decimal Display_totalNumPage {get;set;}{Display_totalNumPage = 1;} // Display当前页面数
    
    public Boolean BRSF_isFirst {get;set;}{BRSF_isFirst = false;}  // BRSF是否显示上一页
    public Boolean PSF_isFirst {get;set;}{PSF_isFirst = false;}  // PSF是否显示上一页
    // public Boolean Display_isFirst {get;set;}{Display_isFirst = false;}  // Display是否显示上一页

    public Boolean BRSF_isNext {get;set;}{BRSF_isNext = false;} // BRSF是否显示下一页
    public Boolean PSF_isNext {get;set;}{PSF_isNext = false;} // PSF是否显示下一页
    // public Boolean Display_isNext {get;set;}{Display_isNext = false;} // Display是否显示下一页

    public String PageSkipType {get;set;} // 跳转类型
    public String PageSkipLineType {get;set;} // 需要跳转的数据类型
    public static Decimal skipNum = [select ASI_CRM_CN_Payment_Page_Number__c from ASI_CRM_CN_CustomSetting__c].ASI_CRM_CN_Payment_Page_Number__c; // 每页的条目数
    
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PO_BRSFLineList{get;set;}{PO_BRSFLineList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();} // PO下BRSF line item的全部数据
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSF_LineList{get;set;}{BRSF_LineList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();} // PO下BRSF line item下类型为BRSF的数据
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PSF_LineList{get;set;}{PSF_LineList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();} // PO下BRSF line item下类型为PSF的数据
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> Display_LineList{get;set;}{Display_LineList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();} // PO下BRSF line item下类型为Visibility的数据
    

    //BRSF
    public String BRSF_Item_MapJSON { set; get; }
    public interimData BRSF_Item_Map {set;get;} {BRSF_Item_Map= new interimData();} 
    //public Map<String, interimDataDto> BRSF_Item_MapDto {set;get;} {BRSF_Item_MapDto= new Map<String, interimDataDto>();}
    
    //PSF
    public String PSF_Item_MapJSON { set; get; }
    public Map<String, interimData> PSF_Item_Map {set;get;} {PSF_Item_Map= new Map<String, interimData>();}
    public Map<String, interimDataDto> PSF_Item_MapDto {set;get;} {PSF_Item_MapDto= new Map<String, interimDataDto>();}
    
    //Display Listing (Free Goods)
    public String DisplayListing_Item_MapJSON { set; get; }
    public Map<String, interimData> DisplayListingItemMap {set;get;} {DisplayListingItemMap= new Map<String, interimData>();}
    public Map<String, interimDataDto> DisplayListingItemMapDto {set;get;} {DisplayListingItemMapDto= new Map<String, interimDataDto>();}
    
    //Visibility
    public interimData Visibility_Item_Map {set;get;} {Visibility_Item_Map= new interimData();} 
    public ASI_CRM_CN_Contract_BRSF_Line_Item__c VisibilityLine {set;get;} {VisibilityLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();}
    
    //Covered Outlet
    public Map<String, ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_Item_Map {set;get;}{CoveredOutlet_Item_Map= new Map<String, ASI_CRM_CN_Covered_Outlet__c>();}
    public List<ASI_CRM_CN_Covered_Outlet__c> ContractOutletList {set;get;} {ContractOutletList = new List<ASI_CRM_CN_Covered_Outlet__c> (); }
    
    //Covered WS
    public Map<String, ASI_CRM_CN_Covered_Outlet__c> CoveredWS_Item_Map {set;get;}{CoveredWS_Item_Map= new Map<String, ASI_CRM_CN_Covered_Outlet__c>();}
    public List<ASI_CRM_CN_Covered_Outlet__c> ContractWSList {set;get;} {ContractWSList = new List<ASI_CRM_CN_Covered_Outlet__c> (); }
    
    public List<ASI_CRM_Module__c> ModuleDeleteList { get; set; }{
        ModuleDeleteList = new List<ASI_CRM_Module__c>();
    }
    
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFDeleteList { get; set; }{
        BRSFDeleteList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
    }

    public List<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList{set;get;}
    public Boolean ShowPaymentList {set;get;} {ShowPaymentList =false;}
    
    public Boolean showCN {set;get;}
    public Map<Id, ASI_CRM_Methodology__c> MethodologyById { set; get; }
    public String MethodologyByIdJSON { set; get; }
    public List<ASI_CRM_Methodology__c> defaultMethodologies { get; set; }
    
    public String BRSFLineRecordTypeId {set;get;}
    public String msg {get;set;} {msg='';}
    public Boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public Integer WarningTimes {get;set;} {WarningTimes=0;}
    public String WarningMsg {get;set;} {WarningMsg='';}
    
    //@description : new line count
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public Boolean ShowWarning  {get;set;} {ShowWarning= false;}

    //Default Account Code
    public String PSFActivityCodeId  {get;set;}{PSFActivityCodeId='';}
    public String DisplayActivityCodeId  {get;set;}{DisplayActivityCodeId='';}
    public String VisibilityActivityCodeId  {get;set;}{VisibilityActivityCodeId='';}

    
    //VAT Percent
    public Decimal vatPercent {set;get;}

    //Default Markup
    public Decimal defaultMarkUp  {get;set;}{defaultMarkUp=0;}
    //Max Markup
    public Decimal maxMarkUp  {get;set;}
    
    //BG Date
    public Date strStartBGDate {get;set;} 
    public Date strEndBGDate {get;set;}
    public Date strStartBGDate2  {get;set;}
    public Date strEndBGDate2 {get;set;}

    //Contract Start/End Date
    public Date ContractStartDate {get;set;}
    public Date ContractEndDate {get;set;}
    
    //Page Flag for define the page status (edit/view)
    public Boolean IsView {get;set;} 
    public Boolean IsHeaderEdit {get;set;} 
    public Boolean IsDetailEdit {get;set;}
    public Boolean IsPOModiPage {get;set;}
    
    //PO Modi flag
    public Boolean isPOModi {get;set;}

    //Group PO flag
    public Boolean isGroupPO {get;set;}
    //Child PO flag
    public Boolean isChildPO {get;set;}

    public Boolean showRestorePO {set;get;}
    public Boolean showPSF {set;get;} {showPSF=true;}
    public Boolean showDisplay{set;get;} {showDisplay=true;}
    
    public Boolean showReturn {set;get;} {showReturn=false;}
    public Boolean inBAPermissionSet {set;get;} {inBAPermissionSet = false;}
        
    public ASI_CRM_CN_PromotionContractCtrl (ApexPages.StandardController controller) {
        
        
        if (ApexPages.currentPage().getParameters().get('IsHeaderEdit') == '1') {
            IsHeaderEdit = true;
            isView = false;
            IsDetailEdit = false;
            IsPOModiPage = false;
        }
        else if (ApexPages.currentPage().getParameters().get('IsDetailEdit') == '1') {
            IsHeaderEdit = false;
            isView = false;
            IsDetailEdit = true;
            IsPOModiPage = false;
        }
        else if (ApexPages.currentPage().getParameters().get('IsPOModiPage') == '1') {
            IsHeaderEdit = true;
            isView = false;
            IsDetailEdit = false;
            IsPOModiPage = true;
        }
        else{
            IsHeaderEdit = false;
            isView = true;
            IsDetailEdit = false;
            IsPOModiPage = false;
        }
        
        showCN = UserInfo.getLanguage()=='zh_CN';

        if([SELECT Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name ='ASI_CRM_CN_General_BA' AND AssigneeId = :UserInfo.getUserId()].size()>0){
            inBAPermissionSet = true;
        }  

        this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
        
        if(this.ContractSelected != null)
            PageId = ContractSelected.Id;
        
        this.BRSFLineRecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');    
        
        //get VAT Percent
        this.vatPercent = ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_VAT__c;
                    
        this.ContractSelected = [SELECT Id,
                                        ASI_CRM_CN_Festival_Season__c,
                                        ASI_CRM_CN_Data_Source__c,   
                                        ASI_CRM_Remarks__c,
                                        ASI_TH_CRM_Others__c,
                                        ASI_CRM_CN_PO_Division__c,
                                        ASI_CRM_Heap_Size_Large__c,
                                        OwnerId,
                                        ASI_CRM_CN_Local_Group_Contract__c,
                                        ASI_CRM_Contract_Template_Id__c,
                                        ASI_CRM_CN_V0_0_PO_version__c,
                                        ASI_CRM_Auto_PO_Modification_Time__c,
                                        ASI_CRM_Auto_PO_Modification__c,
                                        ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                                        ASI_CRM_System_Debug__c,
                                        ASI_CRM_Previous_Version_PSF_Est_Total__c ,
                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                                        ASI_CRM_CN_Expected_PSF_Est_Total__c ,
                                        ASI_CRM_V0_PSF_Contract_Total__c,
                                        Owner.Email,
                                        ASI_CRM_Last_RBA_Approver__c,
                                        ASI_CRM_CN_Group_Contract__c,
                                        ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c,
                                        ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c,
                                        Name,
                                        ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,
                                        ASI_CRM_Expected_V0_0_VEC_Est_Total__c, 
                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                                        ASI_CRM_PSF_Grand_Contract_Total__c,
                                        ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
                                        ASI_CRM_PSF_Contract_Adjustment_Amount__c,
                                        ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
                                        ASI_CRM_Investment_Type__c,
                                        ASI_TH_CRM_Summary_Contract_Spending__c, 
                                        ASI_CRM_CN_Total_Contract_Amount__c ,
                                        ASI_CRM_EVC_Cost_Estimate_Total__c,
                                        ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
                                        ASI_CRM_PSF_Grand_Estimate_Total__c,
                                        ASI_CRM_CN_Vol_Budget_LE__c, 
                                        ASI_CRM_CN_Status__c, 
                                        ASI_CRM_CN_Source_of_Contract__c,
                                        ASI_CRM_CN_Source_Others__c,
                                        ASI_CRM_CN_Reason_without_Budget__c, 
                                        ASI_TH_CRM_Promotion_Type__c, 
                                        ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, 
                                        ASI_CRM_CN_PO_Start_Date__c, 
                                        ASI_CRM_CN_PO_No__c, 
                                        ASI_CRM_CN_PO_End_Date__c, 
                                        ASI_CRM_CN_Outlet_WS__c,
                                        ASI_CRM_CN_Region__c, 
                                        ASI_CRM_Active_Dummy_PO__c,
                                        CreatedById,
                                        ASI_CRM_CN_Exchange_Rate__c, 
                                        ASI_CRM_CN_Expected_BRSF_Est_Total__c , 
                                        ASI_CRM_CN_Use_PRC_Contract_Template__c ,  
                                        ASI_CRM_CN_Description__c, 
                                        ASI_CRM_CN_Currency__c, 
                                        ASI_CRM_CN_Budget_LE__c, 
                                        ASI_CRM_CN_Bottle_Collection_Rate__c, 
                                        ASI_CRM_CN_Effective_Date__c,
                                        RecordTypeId, 
                                        ASI_CRM_CN_No_of_Months__c, 
                                        ASI_CRM_CN_PO_Modification__c , 
                                        ASI_CRM_CN_Special_Promotion__c, 
                                        ASI_CRM_CN_Contract_Upload__c,  
                                        ASI_CRM_CN_Last_PO_version__c, 
                                        ASI_CRM_CN_National_Group_Contract__c,
                                        ASI_CRM_CN_Business_License__c, 
                                        CreatedDate, 
                                        ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, 
                                        ASI_CRM_Volume_Option__c, 
                                        LastModifiedDate, 
                                        ASI_CRM_New_FY_PO__c, 
                                        ASI_CRM_PO_Channel__c, 
                                        ASI_CRM_PO_Province__c,
                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, 
                                        ASI_CRM_PO_City__c, 
                                        ASI_CRM_PO_City__r.Name,
                                        ASI_CRM_National_Group__c, 
                                        ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                        ASI_CRM_National_Group__r.Name, 
                                        ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, 
                                        ASI_CRM_CN_Last_Submitted_Date__c, 
                                        ASI_CRM_CN_Last_Rejected_Date__c,
                                        ASI_CRM_CN_V0_Display_Contract_Total__c, 
                                        ASI_CRM_CN_Expected_V0_Display_Est_Total__c, 
                                        ASI_CRM_Prev_Version_Display_Est_Total__c, 
                                        ASI_CRM_Display_Estimate_Adjustment_Amt__c, 
                                        ASI_CRM_CN_Expected_Display_Est_Total__c,
                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.Name,
                                        ASI_CRM_CN_V0_Visibility_Contract_Total__c,
                                        ASI_CRM_Prev_Ver_Visibility_Est_Total__c,
                                        ASI_CRM_Visibility_Est_Adjust_percent__c,
                                        ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                                        ASI_CRM_CN_Is_Group_Contract__c,ASI_CRM_CN_Is_Block__c,
                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                        (SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
                                                ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
                                        FROM ASI_TH_CRM_PaymentRequests_Contract__r)
        FROM ASI_TH_CRM_Contract__c
        WHERE Id =:PageId ];

        PaymentRequestList = ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r;

        if(PaymentRequestList.size()>0){
            ShowPaymentList=true;
        }

        showRestorePO = false;
        if(ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Last_PO_version__c != null && !ContractSelected.ASI_CRM_Auto_PO_Modification__c){
            showRestorePO = true;
        }
        
        if(inBAPermissionSet && ContractSelected.ASI_CRM_CN_Status__c == 'Submitted'){
            showReturn = true;
        }
        
        init();
        
    }
    
    public void init(){
        
        isPOModi = ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0';

        isGroupPO = ContractSelected.ASI_CRM_CN_Is_Group_Contract__c == true;

        isChildPO = ContractSelected.ASI_CRM_CN_Group_Contract__c != null;
        
        //Get BG Start/End Date for BS Budget 
        strStartBGDate = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(this.ContractSelected.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        strEndBGDate = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(this.ContractSelected.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
        strStartBGDate2 = Date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
        strEndBGDate2 = Date.newInstance(strEndBGDate.year(), 6, 30);

        //Get Contract Start/End Date
        ContractStartDate = this.ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
        ContractEndDate = this.ContractSelected.ASI_CRM_CN_PO_End_Date__c;
        
        initMethodologyMap();
        FindingDefaultValue();

        List<SelectOption> PSFPicklist = genMethodologyPicklist('', 'PSF');
        if(PSFPicklist.size()==0){
            showPSF=false;
        }

        List<SelectOption> DisplayPicklist = genMethodologyPicklist('', 'Display');
        if(DisplayPicklist.size()==0){
            showDisplay=false;
        }

        
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
                ASI_CRM_CN_Proportion__c,
                ASI_CRM_CN_Only_for_Strategy_WS__c,
                Id
            FROM ASI_CRM_Module__c
            WHERE ASI_CRM_Contract__c = :PageId
        ]);

        Decimal moduleSum = 0;

        // Map<String, ASI_CRM_Module__c> PSF_ModuleMap = new Map<String, ASI_CRM_Module__c>();
        for(String moduleId:ModuleMap.keySet()){
            ASI_CRM_Module__c module = ModuleMap.get(moduleId);
            
            if(module.ASI_CRM_Line_Type__c == 'BRSF'){
                BRSF_Item_Map.isCreatedInCurrentVersion = module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;
                BRSF_Item_Map.Module = module;
            }
            // do similar with psf and display,
            if(module.ASI_CRM_Line_Type__c == 'PSF'){
                // PSF_SumNum ++;
                // if(moduleSum > 2)
                // {
                //     moduleSum ++;
                //     continue;
                // }         
                // else
                // {
                //     PSF_ModuleMap.put(moduleId, module);
                //     moduleSum ++;
                // }
                
                //PSF_Item_Map.put(moduleId, module);
            }
            
            if(module.ASI_CRM_Line_Type__c == 'Visibility'){
                Visibility_Item_Map.Module = module;
            }
            
        }

        // If there is no BRSF Module, create one
        if(BRSF_Item_Map.Module.Id == null){        
            BRSF_Item_Map.Module = createModule('BRSF');
        }

        //Set default markup
        if(BRSF_Item_Map.Module.ASI_CRM_CN_Total_Markup__c == null){
            BRSF_Item_Map.Module.ASI_CRM_CN_Total_Markup__c = defaultMarkUp;
        }

        Map<String ,List<SelectOption>> pickMap = genPSFVolValBasePicklist();
        Map<String ,List<SelectOption>> methodMap = genMethodologyPicklist();
        
        PO_BRSFLineList = [SELECT
            ASI_CRM_Adjustment_Line__c,
            ASI_CRM_CN_Drop_In__c,
            ASI_CRM_CN_Pack_Size__c,
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
            ASI_CRM_Line_Long_Name__c,
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
            ASI_CRM_CN_Sub_Brand_Package__c,
            ASI_CRM_CN_Total_Volume_9L__c,
            ASI_CRM_CN_Total_Volume_Std_btl__c,
            ASI_CRM_CN_Package_Number__c, 
            ASI_CRM_CN_Date__c,
            ASI_CRM_Map_Key__c,
            ASI_CRM_CN_Sub_brand_Group__c,
            Id
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :PageId];

         //*****************Looping  BRSF/PSF Line
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:PO_BRSFLineList) {
            // bowen：为了预防空指针异常，给数据加上0
            if(BRSFLine.ASI_CRM_CN_Total_Volume_Std_btl__c == null)
            {
                BRSFLine.ASI_CRM_CN_Total_Volume_Std_btl__c = 0;
            }
            
            //BRSF
            if (BRSFLine.ASI_CRM_Type__c == 'BRSF') {  
                BRSF_LineList.add(BRSFLine);
            }
            
            //PSF
            if(BRSFLine.ASI_CRM_Type__c=='PSF'){  
                PSF_LineList.add(BRSFLine);
            }
            
            //Display
            if(BRSFLine.ASI_CRM_Type__c=='Display'){
                Display_LineList.add(BRSFLine);
            }
            
            //Visibility
            if(BRSFLine.ASI_CRM_Type__c=='Visibility'){
                VisibilityLine = BRSFLine;
            }
            
        }

        // Decimal BRSFNum = 0;
        // Decimal PSFNum = 0;
        // Decimal DisplayNum = 0;
        // Decimal VisibilityNum = 0;

        if(BRSF_LineList.size() > 0)
        {
            // BRSF_SumNum = BRSF_LineList.size(); //获取BRSF类型的 line item数据的总数
            // BRSF_SumNumPage = Math.ceil(BRSF_SumNum / skipNum); // BRSF类型的 line item数据 总页数
            // if(BRSF_SumNumPage > 1) BRSF_isNext = true; //BRSF类型的 line item数据 当页面数大于1时，默认勾选
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfitem : BRSF_LineList)
            {
                // if(BRSFNum >= skipNum) continue;
                // BRSFNum ++;              
                //BRSF_Item_Map= new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
                BRSF_Item_Map.DetailLineMap.put(brsfitem.Id,brsfitem);
            }
        }
        //Display
        if(Display_LineList.size() > 0)
        {

            // Display_SumNum = Display_LineList.size(); //获取BRSF类型的 line item数据的总数
            // Display_SumNumPage = Math.ceil(Display_SumNum / skipNum); // BRSF类型的 line item数据 总页数
            // if(Display_SumNumPage > 1) Display_isNext = true; //BRSF类型的 line item数据 当页面数大于1时，默认勾选

            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c displayitem : Display_LineList)
            {
                // if(BRSFNum >= skipNum) continue;
                // BRSFNum ++;     

                String LineKey=displayitem.Id;
                
                if(DisplayListingItemMap.containsKey(displayitem.ASI_CRM_Module__c)){
                    DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,displayitem);                                                       
                }else{
                    if(ModuleMap.containsKey(displayitem.ASI_CRM_Module__c)){
                        interimData TempData= new interimData(ModuleMap.get(displayitem.ASI_CRM_Module__c));
                        TempData.isCreatedInCurrentVersion = TempData.Module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;
                        // TODO calculate too much times. Use a mapping to store picklist relationship
                        // TempData.MethodologyPicklist = genMethodologyPicklist(BRSFLine.ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c, 'Display');
                        TempData.MethodologyPicklist = methodMap.get('Free Goods/GWP');
                        TempData.VolumeValueBasePickList = pickMap.get(displayitem.ASI_CRM_Module__r.ASI_CRM_Methodology__c);
                                                                      
                        DisplayListingItemMap.put(displayitem.ASI_CRM_Module__c,TempData);
                        DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,displayitem);
                        DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).Module.ASI_CRM_Contract__c=PageId;
                        DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).updateMethodologyDisplay(showCN);
                    }
                } 
            }
        }

        if(PSF_LineList.size() > 0)
        {
            // PSF_SumNum = PSF_LineList.size(); //获取BRSF类型的 line item数据的总数
            // PSF_SumNumPage = Math.ceil(PSF_SumNum / 2); // BRSF类型的 line item数据 总页数
            // if(PSF_SumNumPage > 1) PSF_isNext = true; //BRSF类型的 line item数据 当页面数大于1时，默认勾选

            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c psffitem : PSF_LineList)
            {
                // if(PSFNum >= 4) continue;
                // PSFNum ++;
              
                if(psffitem.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    psffitem.ASI_CRM_Line_Name__c= psffitem.ASI_CRM_Sub_Brand_Grade__c!=null?psffitem.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:psffitem.ASI_CRM_Sub_Brand_Grade__r.Name;
                    //BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(SubBrandGradeMap,BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');
                }else{
                    psffitem.ASI_CRM_Max_Incentive__c=0;
                }

                String LineKey=psffitem.Id;
                if(psffitem.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Category'){
                    psffitem.ASI_CRM_Line_Name__c= psffitem.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c!=null?psffitem.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c:psffitem.ASI_CRM_Product_Category__r.Name;
                    LineKey=ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(psffitem.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) +LineKey;
                }                


                if(PSF_Item_Map.containsKey(psffitem.ASI_CRM_Module__c)){
                    PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,psffitem);                                                       
                }else{
                    if(ModuleMap.containsKey(psffitem.ASI_CRM_Module__c)){
                        interimData TempData= new interimData(ModuleMap.get(psffitem.ASI_CRM_Module__c));
                        TempData.isCreatedInCurrentVersion = TempData.Module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;
                        // TODO calculate too much times. Use a mapping to store picklist relationship
                        

                        // TempData.MethodologyPicklist = genMethodologyPicklist(BRSFLine.ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c, 'PSF');
                        TempData.MethodologyPicklist = methodMap.get('Price Promotion');
        
                        TempData.VolumeValueBasePickList = pickMap.get(psffitem.ASI_CRM_Module__r.ASI_CRM_Methodology__c);
                        
                        if((TempData.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && TempData.Module.ASI_CRM_Methodology__r.Name != 'Per Incentive Btl' && TempData.Module.ASI_CRM_Methodology__r.Name != 'Rebate%')||
                          (TempData.Module.ASI_CRM_Volume_Base__c=='By Brand Group' && TempData.Module.ASI_CRM_Methodology__r.Name != 'Rebate%')){
                             TempData.displayMultiTable = true;
                        }
                        
                        PSF_Item_Map.put(psffitem.ASI_CRM_Module__c,TempData);
                        PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,psffitem);
                        PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).Module.ASI_CRM_Contract__c=PageId;
                        PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).updateMethodologyDisplay(showCN);
                    }
                }
            }
        }
        
        System.debug(Visibility_Item_Map);
        //If no Visibility module, Create Visibility module in Outlet Promotion 
        if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && Visibility_Item_Map.Module.Id ==null){
            Visibility_Item_Map.Module = createModule('Visibility');
            VisibilityLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId,
                                                                       ASI_CRM_Type__c ='Visibility',
                                                                       ASI_CRM_Module__c = Visibility_Item_Map.Module.Id,
                                                                       ASI_CRM_CN_Activity_Code__c = VisibilityActivityCodeId,
                                                                       ASI_CRM_CN_Est_Total_Dummy__c = 0,
                                                                       RecordTypeId = BRSFLineRecordTypeId);
                
        }/*else if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && Visibility_Item_Map != null){
            System.debug(Visibility_Item_Map);
            VisibilityLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId,
                                                                                                ASI_CRM_Type__c ='Visibility',
                                                                                                ASI_CRM_Module__c = Visibility_Item_Map.Module.Id,
                                                                                                ASI_CRM_CN_Est_Total_Dummy__c = 0,
                                                                                                RecordTypeId = BRSFLineRecordTypeId);                                                                                                   
        }*/
             
        GenPSFMultiTableMap();
        GenPSFLadderAmountMap();
        
        BRSF_Item_MapJSON = JSON.serialize(BRSF_Item_Map);
        System.debug('PSF_Item_Map === '+PSF_Item_Map);
        updatePSFItemMapDTO();
        updateDisplayListingItemMapDTO();
        //updateBRSFItemMapDTO();
        
        // Covered Outlet
        ContractOutletList = ASI_CRM_CN_PromotionContractUtilClass.getCoveredOutlets(PageId, 'ASI_CRM_Outlet_CN');

        for(ASI_CRM_CN_Covered_Outlet__c Outlet:ContractOutletList){
            CoveredOutlet_Item_Map.put(Outlet.Id,Outlet);
        }
        
        // Covered WS
        ContractWSList = ASI_CRM_CN_PromotionContractUtilClass.getCoveredOutlets(PageId, 'ASI_CRM_CN_WS');

        for(ASI_CRM_CN_Covered_Outlet__c WS:ContractWSList){
            CoveredWS_Item_Map.put(WS.Id,WS);
        }

        if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && VisibilityLine.ASI_CRM_CN_Contract__c != null){
            calVisibilityAmt();
        }
        
    }

    // public void NextPage()
    // {
    //     if(PageSkipType == 'Next' || PageSkipType == 'Last')
    //     {
    //         saveItems();
    //     }
    //     System.debug('NextPage PageSkipLineType' + PageSkipLineType);
    //     System.debug('NextPage PSF_LineList.size()' + PSF_LineList.size());
        
    //     initMethodologyMap();
    //     FindingDefaultValue();

    //     List<SelectOption> PSFPicklist = genMethodologyPicklist('', 'PSF');
    //     if(PSFPicklist.size()==0){
    //         showPSF=false;
    //     }

    //     List<SelectOption> DisplayPicklist = genMethodologyPicklist('', 'Display');
    //     if(DisplayPicklist.size()==0){
    //         showDisplay=false;
    //     }

    //     if(PageSkipLineType == 'BRSF')
    //     {
    //         BRSF_Item_Map= new interimData();
    //     }
    //     else if(PageSkipLineType == 'PSF')
    //     {
    //         PSF_Item_Map.clear();

    //         if(PageSkipType == 'Next')
    //         {
    //             PSF_totalNumPage += 1; // 回传的是next，代表下一页，故+1
    //         }
    //         else if(PageSkipType == 'Last')
    //         {
    //             PSF_totalNumPage -= 1;// 回传的是Last，代表上一页，故-1
    //         }

    //         System.debug('当前页=='+PSF_totalNumPage);
                
    //     }
    //     else if(PageSkipLineType == 'Display')
    //     {
    //         DisplayListingItemMap.clear();
    //     }

    //     Decimal PSF_startNum = 0;
    //     PSF_startNum = (PSF_totalNumPage - 1) * 2; // 需从第几条数据开始
    //     Decimal PSF_stopNum = PSF_startNum + 2; // 需从第几条数据结

    //     //Module
    //     Map<String, ASI_CRM_Module__c> ModuleMap = new Map<String, ASI_CRM_Module__c>([
    //         SELECT
    //             ASI_CRM_CN_AC_Code__c,
    //             ASI_CRM_CN_Criteria__c,
    //             ASI_CRM_CN_Is_Capped__c,
    //             ASI_CRM_CN_KPI_Base__c,
    //             ASI_CRM_CN_Minimal_Achievement__c,
    //             ASI_CRM_CN_Total_Markup__c,
    //             ASI_CRM_CN_Contract_Volume_Base__c,
    //             ASI_CRM_CN_Volume_Value_Base__c,
    //             ASI_CRM_Created_PO_Version__c,
    //             ASI_CRM_Group_Contract__c,
    //             ASI_CRM_Line_Type__c,
    //             ASI_CRM_Methodology__c,
    //             ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
    //             ASI_CRM_Methodology__r.Name,
    //             ASI_CRM_Reason_NCD_Volume_Base__c,
    //             ASI_CRM_Reason_Not_NCD_Methodology__c,
    //             ASI_CRM_Remark__c,
    //             ASI_CRM_Remark_Display__c,
    //             ASI_CRM_Remark_Options__c,
    //             ASI_CRM_Unit__c,
    //             ASI_CRM_Volume_Base__c,
    //             ASI_CRM_CN_Proportion__c,
    //             ASI_CRM_CN_Only_for_Strategy_WS__c,
    //             Id
    //         FROM ASI_CRM_Module__c
    //         WHERE ASI_CRM_Contract__c = :PageId
    //     ]);
    //     Decimal moduleSum = 0;
    //     Map<String, ASI_CRM_Module__c> PSF_ModuleMap = new Map<String, ASI_CRM_Module__c>();
    //     for(String moduleId:ModuleMap.keySet()){
    //         ASI_CRM_Module__c module = ModuleMap.get(moduleId);         
            
            
    //         if(module.ASI_CRM_Line_Type__c == 'BRSF'){
    //             BRSF_Item_Map.isCreatedInCurrentVersion = module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;
    //             BRSF_Item_Map.Module = module;
    //         }
    //         // do similar with psf and display,
    //         if(module.ASI_CRM_Line_Type__c == 'PSF'){
    //             //PSF_Item_Map.put(moduleId, module);
    //             if(moduleSum > PSF_startNum && moduleSum < PSF_stopNum)
    //             {
    //                 moduleSum ++;
    //                 continue;
    //             }         
    //             else
    //             {
    //                 PSF_ModuleMap.put(moduleId, module);
    //                 moduleSum ++;
    //             }
    //         }
            
    //         if(module.ASI_CRM_Line_Type__c == 'Visibility'){
    //             Visibility_Item_Map.Module = module;
    //         }
            
    //     }

    //     // If there is no BRSF Module, create one
    //     if(BRSF_Item_Map.Module.Id == null){        
    //         BRSF_Item_Map.Module = createModule('BRSF');
    //     }

    //     //Set default markup
    //     if(BRSF_Item_Map.Module.ASI_CRM_CN_Total_Markup__c == null){
    //         BRSF_Item_Map.Module.ASI_CRM_CN_Total_Markup__c = defaultMarkUp;
    //     }

    //     Map<String ,List<SelectOption>> pickMap = genPSFVolValBasePicklist();
    //     Map<String ,List<SelectOption>> methodMap = genMethodologyPicklist();
        
    //     Decimal BRSFNum = 0;
    //     Decimal PSFNum = 0;
    //     Decimal DisplayNum = 0;
    //     Decimal VisibilityNum = 0;
        
    //     // 分页的时候，要判断是不是BRSF点击进来的
    //     if(BRSF_LineList.size() > 0 && PageSkipLineType == 'BRSF')
    //     {
    //         Decimal startNum = 0;
    //         if(PageSkipType == 'Next')
    //         {
    //             BRSF_totalNumPage += 1; // 回传的是next，代表下一页，故+1
    //         }
    //         else if(PageSkipType == 'Last')
    //         {
    //             BRSF_totalNumPage -= 1;// 回传的是Last，代表上一页，故-1
    //         }

    //         System.debug('当前页=='+BRSF_totalNumPage);
    //         startNum = (BRSF_totalNumPage - 1) * skipNum; // 需从第几条数据开始

    //         Decimal stopNum = startNum + skipNum; // 需从第几条数据结束

    //         if(BRSF_SumNumPage > BRSF_totalNumPage) 
    //         {
    //             BRSF_isNext = true; 
    //         }
    //         else
    //         {
    //             BRSF_isNext = false;
    //         }

    //         if(BRSF_totalNumPage == 1)
    //         {
    //             BRSF_isFirst = false;
    //         }
    //         else
    //         {
    //             BRSF_isFirst = true;
    //         }

    //         for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfitem : BRSF_LineList)
    //         {
    //             if(BRSFNum < startNum || BRSFNum > stopNum)
    //             {
    //                 BRSFNum ++; 
    //                 continue;
    //             } 
    //             //BRSF_Item_Map= new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
    //             BRSF_Item_Map.DetailLineMap.put(brsfitem.Id,brsfitem);
    //         }
    //     }
    //     //Display
    //     if(Display_LineList.size() > 0 && PageSkipLineType == 'Display')
    //     {
    //         // Decimal startNum = 0;
    //         // if(PageSkipType == 'Next')
    //         // {
    //         //     Display_totalNumPage += 1; // 回传的是next，代表下一页，故+1
    //         // }
    //         // else if(PageSkipType == 'Last')
    //         // {
    //         //     Display_totalNumPage -= 1;// 回传的是Last，代表上一页，故-1
    //         // }

    //         // if(Display_SumNumPage > Display_totalNumPage) 
    //         // {
    //         //     Display_isNext = true; 
    //         // }
    //         // else
    //         // {
    //         //     Display_isNext = false;
    //         // }

    //         // if(Display_totalNumPage == 1)
    //         // {
    //         //     Display_isFirst = false;
    //         // }
    //         // else
    //         // {
    //         //     Display_isFirst = true;
    //         // }

    //         // System.debug('当前页=='+Display_totalNumPage);
    //         // startNum = (Display_totalNumPage - 1) * skipNum; // 需从第几条数据开始

    //         // Decimal stopNum = startNum + skipNum; // 需从第几条数据结束
            

    //         for(ASI_CRM_CN_Contract_BRSF_Line_Item__c displayitem : Display_LineList)
    //         {
    //             if(BRSFNum >= skipNum) continue;
    //             BRSFNum ++;     

    //             String LineKey=displayitem.Id;
                
    //             if(DisplayListingItemMap.containsKey(displayitem.ASI_CRM_Module__c)){
    //                 DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,displayitem);                                                       
    //             }else{
    //                 if(PSF_ModuleMap.containsKey(displayitem.ASI_CRM_Module__c)){
    //                     interimData TempData= new interimData(PSF_ModuleMap.get(displayitem.ASI_CRM_Module__c));
    //                     TempData.isCreatedInCurrentVersion = TempData.Module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;
    //                     // TODO calculate too much times. Use a mapping to store picklist relationship
    //                     // TempData.MethodologyPicklist = genMethodologyPicklist(BRSFLine.ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c, 'Display');
    //                     TempData.MethodologyPicklist = methodMap.get('Free Goods/GWP');
    //                     TempData.VolumeValueBasePickList = pickMap.get(displayitem.ASI_CRM_Module__r.ASI_CRM_Methodology__c);
                                                                      
    //                     DisplayListingItemMap.put(displayitem.ASI_CRM_Module__c,TempData);
    //                     DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,displayitem);
    //                     DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).Module.ASI_CRM_Contract__c=PageId;
    //                     DisplayListingItemMap.get(displayitem.ASI_CRM_Module__c).updateMethodologyDisplay(showCN);
    //                 }
    //             } 
    //         }
    //     }

    //     if(PSF_LineList.size() > 0 && PageSkipLineType == 'PSF')
    //     {

    //         if(PSF_SumNumPage > PSF_totalNumPage) 
    //         {
    //             PSF_isNext = true; 
    //         }
    //         else
    //         {
    //             PSF_isNext = false;
    //         }

    //         if(PSF_totalNumPage == 1)
    //         {
    //             PSF_isFirst = false;
    //         }
    //         else
    //         {
    //             PSF_isFirst = true;
    //         }
    //         system.debug('PSF_totalNumPage =='+PSF_totalNumPage);
    //         system.debug('PSF_isFirst =='+PSF_isFirst);
    //         for(ASI_CRM_CN_Contract_BRSF_Line_Item__c psffitem : PSF_LineList)
    //         {
              
    //             if(psffitem.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
    //                 psffitem.ASI_CRM_Line_Name__c= psffitem.ASI_CRM_Sub_Brand_Grade__c!=null?psffitem.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:psffitem.ASI_CRM_Sub_Brand_Grade__r.Name;
    //                 //BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(SubBrandGradeMap,BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');
    //             }else{
    //                 psffitem.ASI_CRM_Max_Incentive__c=0;
    //             }

    //             String LineKey=psffitem.Id;
    //             if(psffitem.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Category'){
    //                 psffitem.ASI_CRM_Line_Name__c= psffitem.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c!=null?psffitem.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c:psffitem.ASI_CRM_Product_Category__r.Name;
    //                 LineKey=ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(psffitem.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) +LineKey;
    //             }                


    //             if(PSF_Item_Map.containsKey(psffitem.ASI_CRM_Module__c)){
    //                 PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,psffitem);                                                       
    //             }else{
    //                 if(PSF_ModuleMap.containsKey(psffitem.ASI_CRM_Module__c)){
    //                     interimData TempData= new interimData(PSF_ModuleMap.get(psffitem.ASI_CRM_Module__c));
    //                     TempData.isCreatedInCurrentVersion = TempData.Module.ASI_CRM_Created_PO_Version__c == ContractSelected.ASI_CRM_CN_PO_Version__c;
    //                     // TODO calculate too much times. Use a mapping to store picklist relationship
                        

    //                     // TempData.MethodologyPicklist = genMethodologyPicklist(BRSFLine.ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c, 'PSF');
    //                     TempData.MethodologyPicklist = methodMap.get('Price Promotion');
        
    //                     TempData.VolumeValueBasePickList = pickMap.get(psffitem.ASI_CRM_Module__r.ASI_CRM_Methodology__c);
                        
    //                     if((TempData.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && TempData.Module.ASI_CRM_Methodology__r.Name != 'Per Incentive Btl' && TempData.Module.ASI_CRM_Methodology__r.Name != 'Rebate%')||
    //                       (TempData.Module.ASI_CRM_Volume_Base__c=='By Brand Group' && TempData.Module.ASI_CRM_Methodology__r.Name != 'Rebate%')){
    //                          TempData.displayMultiTable = true;
    //                     }
                        
    //                     PSF_Item_Map.put(psffitem.ASI_CRM_Module__c,TempData);
    //                     PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).DetailLineMap.put(LineKey,psffitem);
    //                     PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).Module.ASI_CRM_Contract__c=PageId;
    //                     PSF_Item_Map.get(psffitem.ASI_CRM_Module__c).updateMethodologyDisplay(showCN);
    //                 }
    //             }
    //         }
    //     }
        
    //     System.debug(Visibility_Item_Map);
    //     //If no Visibility module, Create Visibility module in Outlet Promotion 
    //     if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && Visibility_Item_Map.Module.Id ==null){
    //         Visibility_Item_Map.Module = createModule('Visibility');
    //         VisibilityLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId,
    //                                                                    ASI_CRM_Type__c ='Visibility',
    //                                                                    ASI_CRM_Module__c = Visibility_Item_Map.Module.Id,
    //                                                                    ASI_CRM_CN_Activity_Code__c = VisibilityActivityCodeId,
    //                                                                    ASI_CRM_CN_Est_Total_Dummy__c = 0,
    //                                                                    RecordTypeId = BRSFLineRecordTypeId);
                
    //     }/*else if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && Visibility_Item_Map != null){
    //         System.debug(Visibility_Item_Map);
    //         VisibilityLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId,
    //                                                                                             ASI_CRM_Type__c ='Visibility',
    //                                                                                             ASI_CRM_Module__c = Visibility_Item_Map.Module.Id,
    //                                                                                             ASI_CRM_CN_Est_Total_Dummy__c = 0,
    //                                                                                             RecordTypeId = BRSFLineRecordTypeId);                                                                                                   
    //     }*/
             
    //     GenPSFMultiTableMap();
    //     GenPSFLadderAmountMap();
        
    //     BRSF_Item_MapJSON = JSON.serialize(BRSF_Item_Map);
    //     System.debug('PSF_Item_Map === '+PSF_Item_Map);
    //     updatePSFItemMapDTO();
    //     updateDisplayListingItemMapDTO();
    //     //updateBRSFItemMapDTO();
        
    //     // Covered Outlet
    //     ContractOutletList = ASI_CRM_CN_PromotionContractUtilClass.getCoveredOutlets(PageId, 'ASI_CRM_Outlet_CN');

    //     for(ASI_CRM_CN_Covered_Outlet__c Outlet:ContractOutletList){
    //         CoveredOutlet_Item_Map.put(Outlet.Id,Outlet);
    //     }
        
    //     // Covered WS
    //     ContractWSList = ASI_CRM_CN_PromotionContractUtilClass.getCoveredOutlets(PageId, 'ASI_CRM_CN_WS');

    //     for(ASI_CRM_CN_Covered_Outlet__c WS:ContractWSList){
    //         CoveredWS_Item_Map.put(WS.Id,WS);
    //     }

    //     if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && VisibilityLine.ASI_CRM_CN_Contract__c != null){
    //         calVisibilityAmt();
    //     }


    // }
    
    //Generate PSFMultiTableMap Based on BRSF Sub brand/ package for create multi table 
    public void GenPSFMultiTableMap()
    {
        System.debug(LoggingLevel.INFO, '*** PSF_Item_Map: ' + PSF_Item_Map);
        for(String key:PSF_Item_Map.keySet()){

            if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && PSF_Item_Map.get(key).Module.ASI_CRM_Methodology__r.Name != 'Per Incentive Btl'){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line: BRSF_Item_Map.DetailLineMap.values()){
                    if(!PSF_Item_Map.get(key).PSFMultiTableMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)){
                        PSF_Item_Map.get(key).PSFMultiTableMap.put(line.ASI_CRM_CN_Sub_Brand__c, line.ASI_CRM_CN_Sub_Brand__r.Name);
                    }
                }
            }

             //if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Brand Group' && PSF_Item_Map.get(key).Module.ASI_CRM_Methodology__r.Name == 'Rebate%(By Ladder)'){
             if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Brand Group'){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line: BRSF_Item_Map.DetailLineMap.values()){
                  
                   if(PSF_Item_Map.get(key).PSFMultiTableMap.containsKey(line.ASI_CRM_CN_Sub_Brand_Package__c)){
                        String ExistingValue =PSF_Item_Map.get(key).PSFMultiTableMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c) +',  ';
                        PSF_Item_Map.get(key).PSFMultiTableMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, ExistingValue + line.ASI_CRM_CN_Sub_Brand__r.Name);
                    }else{
                        PSF_Item_Map.get(key).PSFMultiTableMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, line.ASI_CRM_CN_Sub_Brand__r.Name);                   
                    }
                }
             }
                                     
        }
    }
    
    //Generate PSFLadderAmountMap Based on BRSF 
    public void GenPSFLadderAmountMap()
    {
        
        for(String key:PSF_Item_Map.keySet()){
            Decimal TotalPurchaseValue = 0;
             //if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Brand Group' && PSF_Item_Map.get(key).Module.ASI_CRM_Methodology__r.Name == 'Rebate%(By Ladder)'){
             if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Brand Group' && PSF_Item_Map.get(key).Module.ASI_CRM_Methodology__r.Name != 'Rebate%'){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line: BRSF_Item_Map.DetailLineMap.values()){
                  
                   if(PSF_Item_Map.get(key).PSFLadderAmountMap.containsKey(line.ASI_CRM_CN_Sub_Brand_Package__c)){
                        Decimal ExistingValue =(PSF_Item_Map.get(key).PSFLadderAmountMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c) != null ? PSF_Item_Map.get(key).PSFLadderAmountMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c) : 0);
                        PSF_Item_Map.get(key).PSFLadderAmountMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, ExistingValue + (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0));
                    }else{
                        PSF_Item_Map.get(key).PSFLadderAmountMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0));                 
                    }
                }
             }
                                 
             if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && PSF_Item_Map.get(key).Module.ASI_CRM_Methodology__r.Name != 'Per Incentive Btl' && PSF_Item_Map.get(key).Module.ASI_CRM_Methodology__r.Name != 'Rebate%'){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line: BRSF_Item_Map.DetailLineMap.values()){
                    PSF_Item_Map.get(key).PSFLadderAmountMap.put(line.ASI_CRM_CN_Sub_Brand__c, (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0)); 
                }
             }
             
             for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line: BRSF_Item_Map.DetailLineMap.values()){ 
                   TotalPurchaseValue += (line.ASI_CRM_CN_Contract_Purchase_Value__c == null ? 0 : line.ASI_CRM_CN_Contract_Purchase_Value__c);                                
             }
             PSF_Item_Map.get(key).PSFLadderAmountMap.put('Total', TotalPurchaseValue);
                                     
        }
    }
    
    public void calVisibilityAmt(){
        if(!this.ContractSelected.ASI_CRM_Auto_PO_Modification__c) {
            VisibilityLine.ASI_CRM_CN_Est_Total_Dummy__c = 0;
            for (ASI_CRM_CN_Covered_Outlet__c outline : CoveredOutlet_Item_Map.values()) {
                if (outline.ASI_CRM_CN_Selected_Covered_Outlet__c == true) {
                    VisibilityLine.ASI_CRM_CN_Est_Total_Dummy__c += (outline.ASI_CRM_CN_Est_Visibility_Amt__c != null ? outline.ASI_CRM_CN_Est_Visibility_Amt__c : 0);
                }
            }
            this.ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c = VisibilityLine.ASI_CRM_CN_Est_Total_Dummy__c;
            if (isPOModi) {
                if (this.ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c == 0 || this.ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c == null) {
                    this.ContractSelected.ASI_CRM_Visibility_Est_Adjust_percent__c = 100;
                } else {
                    this.ContractSelected.ASI_CRM_Visibility_Est_Adjust_percent__c = this.ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c / this.ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c * 100;
                }
            }
        }
    }

    
    @RemoteAction
    public static List<SObject> FindSubBrandList(String obj, String qry,String CommercialTeam,String Region, String RegionId, String CityTier, String strStartBGDate, String strEndBGDate, String strStartBGDate2, String strEndBGDate2){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null){// Object name not valid
            return null;
        }
        // create the filter text
        String filter = qry;
        //begin building the dynamic soql query
        //String soql = 'select Id, Name,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Incentive_Central__c,ASI_CRM_Incentive_East__c,ASI_CRM_Incentive_North__c,ASI_CRM_Incentive_North_West__c,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c  from ' + obj;
         String soql = 'select Id, Name,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Incentive_Central__c,ASI_CRM_Incentive_East__c,ASI_CRM_Incentive_North__c,ASI_CRM_Incentive_North_West__c,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c ';
        
        //Get Budget GS    
        String budgetGSsoql  =', (SELECT ASI_CRM_CM_GS_per_9L__c FROM Actual_CM_GSs__r WHERE ((ASI_CRM_CN_Month_End_Date__c >=' + strStartBGDate + ' AND ' + 'ASI_CRM_CN_Month_End_Date__c <=' + strEndBGDate + ') OR ' + 
        '(ASI_CRM_CN_Month_End_Date__c >=' + strStartBGDate2 + ' AND ' + 'ASI_CRM_CN_Month_End_Date__c <=' + strEndBGDate2 +' AND '+ 'ASI_CRM_CN_Month__c = 6 )) ' + 
        'AND ASI_CRM_TYPE__c = \'Budget GS\'' +
        'AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL ' +
        'AND ASI_CRM_Region__c =\'' + RegionId +'\' ' +
        'ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC LIMIT 1) from ';
        soql += budgetGSsoql;
        soql += obj;
        //System.debug(soql);
        if(String.isNotEmpty(filter)) {
            soql += filter;
        }
        soql += ' order by Name';
        List<SObject> sobjs = new List<SObject>();
        System.debug('soql ==' +soql);
        try{
            Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();

            for(ASI_CRM_Sub_Brand_Grade__c sbg:ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(CommercialTeam,Region)){
                if(sbg.ASI_CRM_CN_City_Tier__c!=null){
                    SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
                }else{
                    SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
                }
            }

            //ASI_CRM_Max_Incentive__c,ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Incentive_for_PSF__c
            sobjs = Database.query(soql);
            System.debug(LoggingLevel.INFO, '*** sobjs: ' + sobjs);
            for(SObject SubBrand:sobjs){
                Decimal BRSFIncentive=0.0;
                Decimal PSFIncentive=0.0;
                Decimal BRSFMaxIncentive=99999999;
                Decimal PSFMaxIncentive=99999999;

                if(SubBrand.getSObject('ASI_CRM_CN_Sub_brand_Grade__r') !=null){
                    String SubBrandGradeName=  (String) SubBrand.getSObject('ASI_CRM_CN_Sub_brand_Grade__r').get('Name');
                    String ExternalKey= (String) SubBrand.getSObject('ASI_CRM_CN_Sub_brand_Grade__r').get('Name');
                    ExternalKey+=Region!=null?Region:'';
                    ExternalKey+=CommercialTeam!=null? CommercialTeam:'';

                    String CityTierExternalKey = ExternalKey;
                    if(CityTier!=null){
                        CityTierExternalKey+= ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(CityTier) ;
                    }

                    if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                        BRSFIncentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
                        PSFIncentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Incentive_for_PSF__c;
                        BRSFMaxIncentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;
                        PSFMaxIncentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
                    }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                        BRSFIncentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
                        PSFIncentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Incentive_for_PSF__c;
                        BRSFMaxIncentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
                        PSFMaxIncentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
                    }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                        BRSFIncentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_CN_Incentive__c;
                        PSFIncentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Incentive_for_PSF__c;
                        BRSFMaxIncentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
                        PSFMaxIncentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive_for_PSF__c;
                    }

                    SubBrand.put('ASI_CRM_Incentive_Central__c', BRSFIncentive); //BRSF Incentive
                    SubBrand.put('ASI_CRM_Incentive_East__c', BRSFMaxIncentive); //BRSF Max Incentive
                    SubBrand.put('ASI_CRM_Incentive_North__c', PSFIncentive); //PSF Incentive
                    SubBrand.put('ASI_CRM_Incentive_North_West__c', PSFMaxIncentive); //PSF Max Incentive

                }
            }
            return sobjs;
        }catch (QueryException e){

            ASI_MFM_ByPass_Setting.ErrorHandling('RemoteAction.ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_EditHeavyContractDetailCtrl','failed! ');


            return null;
        }
    }
    
    public void CoveredOutletValdationChecking(List<ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item){
        Set<Id> effectiveChildsSet = new Set<Id>();
        Boolean isAllCustomer = false;
        Set<Id> invalidChilds = new Set<Id>();


        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS'){
            for(ASI_CRM_Effective_supplier__c obj : [SELECT Id, ASI_CRM_Supplier__c , ASI_CRM_Account__c FROM ASI_CRM_Effective_supplier__c  WHERE ASI_CRM_Supplier__c = : ContractSelected.ASI_CRM_CN_Outlet_WS__c]){
                effectiveChildsSet.add(obj.ASI_CRM_Account__c);
            }
        }else if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN'){
            isAllCustomer = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c != null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name.toLowerCase().contains('all customer');

            if(!isAllCustomer){
                for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c = : ContractSelected.ASI_CRM_CN_Outlet_WS__c  ]){
                    effectiveChildsSet.add(obj.Id);
                }
                for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c IN : effectiveChildsSet ]){
                    effectiveChildsSet.add(obj.Id);
                }
            }
        }

        Double totalSuggestedAmount = 0;
        for(ASI_CRM_CN_Covered_Outlet__c obj : Save_CoveredOutlet_Item) {
            if(obj.ASI_CRM_CN_Suggested_Amount__c != null){
                totalSuggestedAmount += obj.ASI_CRM_CN_Suggested_Amount__c;
            }
            if(!effectiveChildsSet.contains(obj.ASI_CRM_CN_Outlet__c)){
                invalidChilds.add(obj.ASI_CRM_CN_Outlet__c);
            }
        }
    }
    
    public void calculateAdjustment(ASI_TH_CRM_Contract__c Contract){
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> V0ContractDetailLines =[SELECT Id,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c] ;
        Decimal V0PSFContractAmount = 0;
        Decimal V0DisplayContractAmount = 0;

        Decimal V0PSFEstimateAmount = 0;
        Decimal V0DisplayEstimateAmount = 0;

        Decimal V0VisibilityEstimateAmount = 0;

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:V0ContractDetailLines) {
            
            if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                V0PSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                V0PSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
            if (ContractLine.ASI_CRM_Type__c == 'Display') {
                V0DisplayContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                V0DisplayEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
            if (ContractLine.ASI_CRM_Type__c == 'Visibility') {
                V0VisibilityEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines = [
            SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Volume_Base__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :PageId
        ] ;

        Decimal BRSFContractAmount = 0;
        Decimal PSFContractAmount = 0;
        Decimal DisplayContractAmount = 0;

        Decimal BRSFEstimateAmount = 0;
        Decimal PSFEstimateAmount = 0;
        Decimal DisplayEstimateAmount = 0;

        Decimal VisibilityEstimateAmount = 0;

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractDetailLines) {
            if (ContractLine.ASI_CRM_Type__c == 'BRSF') {
                BRSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                BRSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            } else if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                PSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                PSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            } else if (ContractLine.ASI_CRM_Type__c == 'Display') {
                DisplayContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                DisplayEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            } else if (ContractLine.ASI_CRM_Type__c == 'Visibility') {
                VisibilityEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }

        }

        ASI_TH_CRM_Contract__c prevContract = [SELECT ASI_CRM_CN_Expected_PSF_Est_Total__c, ASI_CRM_CN_Expected_Display_Est_Total__c, ASI_CRM_CN_Expected_Visibility_Est_Total__c FROM ASI_TH_CRM_Contract__c WHERE Id = :Contract.ASI_CRM_Copied_From__c LIMIT 1];

        Contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c = BRSFEstimateAmount;
        Contract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c = BRSFEstimateAmount;

        //PSF
        Contract.ASI_CRM_PSF_Grand_Contract_Total__c = PSFContractAmount;
        Contract.ASI_CRM_PSF_Grand_Estimate_Total__c = PSFEstimateAmount;
        Contract.ASI_CRM_Previous_Version_PSF_Est_Total__c = prevContract.ASI_CRM_CN_Expected_PSF_Est_Total__c;
        Contract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = 0;
        Contract.ASI_CRM_CN_Expected_PSF_Est_Total__c = PSFEstimateAmount;
        Contract.ASI_CRM_V0_PSF_Contract_Total__c = V0PSFContractAmount;
        Contract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = V0PSFEstimateAmount;

        //Display
        Contract.ASI_CRM_CN_V0_Display_Contract_Total__c = V0DisplayContractAmount;
        Contract.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = V0DisplayEstimateAmount;
        Contract.ASI_CRM_Prev_Version_Display_Est_Total__c = prevContract.ASI_CRM_CN_Expected_Display_Est_Total__c;
        Contract.ASI_CRM_Display_Estimate_Adjustment_Amt__c = 0;
        Contract.ASI_CRM_CN_Expected_Display_Est_Total__c = DisplayEstimateAmount;

        //Visibility
        Contract.ASI_CRM_CN_V0_Visibility_Contract_Total__c = V0VisibilityEstimateAmount;
        Contract.ASI_CRM_Prev_Ver_Visibility_Est_Total__c = prevContract.ASI_CRM_CN_Expected_Visibility_Est_Total__c;
        Contract.ASI_CRM_Visibility_Est_Adjust_percent__c = 0;
        Contract.ASI_CRM_CN_Expected_Visibility_Est_Total__c = VisibilityEstimateAmount;

    }
        
    public Boolean HeaderValidationChecking(){
        Boolean isProcess = true;

        String version = ContractSelected.ASI_CRM_CN_PO_Version__c;
        Date startDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
        Date endDate = ContractSelected.ASI_CRM_CN_PO_End_Date__c;
        if (ContractSelected.ASI_CRM_CN_Group_Contract__c != null) {// is group contract
            if(startDate<ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c ||
                endDate>ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c){

                Msg +=Label.ASI_CRM_CN_PO_Date_GroupContract + '</br>';
                isProcess=false;
            }
        }
        /*if(!isGroupPo && String.isEmpty(ContractSelected.ASI_CRM_CN_Source_of_Contract__c)){
            Msg += ' Please input Source of Contract.请输入合同来源' + '</br>';
            isProcess=false;
        }*/

        System.debug('HeaderValidationChecking 1');
        if(startDate == null){
            Msg += ' Please input Start Date.请输入开始日期' + '</br>';
            isProcess=false;
        }

        if(endDate == null){
            Msg += ' Please input End Date.请输入结束日期' + '</br>';
            isProcess=false;
        }



        if(!ASI_CRM_DateUtilClass.isStartOfMonth(startDate)){
            Msg += Label.ASI_CRM_CN_PO_Start_Date_Validation+'<br/>';
            isProcess=false;
        }

        //checking end day
        if(!ASI_CRM_DateUtilClass.isEndOfMonth(endDate)){
            Msg +=Label.ASI_CRM_CN_PO_End_Date_Validation+'<br/>';// End Date should be the last day of the month .
            isProcess=false;
        }

        if(!ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CN_FiscalYearBypass') && version == '0.0' && ASI_CRM_DateUtilClass.isCrossingFiscalYear(startDate,endDate)){
            Msg += Label.ASI_CRM_CN_Contract_Start_Date_in_Last_FY+'<br/>';
            isProcess=false;
        }

//        if (startDate != null && endDate != null && !ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CN_checkOverlapBypass')) {
//            List<ASI_TH_CRM_Contract__c> contractsWithOverlapPeriod = [
//                SELECT Id, Name
//                FROM ASI_TH_CRM_Contract__c
//                WHERE Id != :ContractSelected.Id
//                AND ASI_CRM_CN_PO_No__c != :ContractSelected.ASI_CRM_CN_PO_No__c
//                AND ASI_CRM_CN_Status__c != 'Archived'
//                AND ASI_CRM_CN_Outlet_WS__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c
//                AND ASI_TH_CRM_Promotion_Type__c IN ('Outlet Promotion', 'Consumer Promotion', 'Wholesaler Promotion')
//                AND ASI_CRM_CN_PO_Start_Date__c <= :endDate
//                AND ASI_CRM_CN_PO_End_Date__c >= :startDate
//            ];
//            List<String> contractNames = new List<String>();
//            for (ASI_TH_CRM_Contract__c contract : contractsWithOverlapPeriod) {
//                contractNames.add(contract.Name);
//            }
//            if (!contractsWithOverlapPeriod.isEmpty()) {
//                Msg += 'PO period overlaps with other contract ' + String.join(contractNames, ',') + '<br/>';
//                isProcess=false;
//            }
//        }
        return isProcess;
    }

    public PageReference UpdateBRSFItemMap(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        System.debug(params);
        updateBRSFItemMapByJSON(params.get('BRSF_Item_MapJSON'));
        return null;
    }

    //*********************************Save the record **************************************
    public PageReference saveItems(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('isQuickSave');
        if(!Test.isRunningTest()) updateBRSFItemMapByJSON(params.get('BRSF_Item_MapJSON'));
        updatePSFItemMapByJSON(params.get('PSF_Item_MapJSON'));
        if(!Test.isRunningTest()) updateDisplayListingItemMapByJSON(params.get('DisplayListing_Item_MapJSON'));
        for(String key:DisplayListingItemMap.keySet()){
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : DisplayListingItemMap.get(key).DetailLineMap.values()){
                System.debug(lineItem.ASI_CRM_CN_Est_Total_Dummy__c);
            }
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> deletedLines = (List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>) JSON.deserialize(params.get('deletedLinesJSON'), List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>.class);

        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        PageReference pageRef = null;
        msg = '';
        UpsertPermission = true;
        WarningMsg='';
        Database.DeleteResult[] DeleteTarget;
        
        //For BRSF        
        List<ASI_CRM_Module__c> modulesToSave= new List<ASI_CRM_Module__c>();
        //Covered Outlet
        List<ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> Saved_CoveredOutlet_Temp = new List<ASI_CRM_CN_Covered_Outlet__c>();

        ValidationChecking();
        
        if(UpsertPermission || test.isRunningTest()){
            modulesToSave.add(BRSF_Item_Map.Module);            
            //modulesToSave.add(PSF_Item_Map.Module);
            for(String key:PSF_Item_Map.keySet()){
                if(ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0'){
                    PSF_Item_Map.get(key).Module.ASI_CRM_Created_PO_Version__c=ContractSelected.ASI_CRM_CN_PO_Version__c;
                }
                PSF_Item_Map.get(key).Module.ASI_CRM_CN_AC_Code__c=PSFActivityCodeId!=null?PSFActivityCodeId:null;
                if(PSF_Item_Map.get(key).DetailLineMap != null && PSF_Item_Map.get(key).DetailLineMap.size()>0) {
                    modulesToSave.add(PSF_Item_Map.get(key).Module);
                }
            }
            //Display
            for(String key:DisplayListingItemMap.keySet()){
                if(ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0'){
                    DisplayListingItemMap.get(key).Module.ASI_CRM_Created_PO_Version__c=ContractSelected.ASI_CRM_CN_PO_Version__c;
                }
                if(!Test.isRunningTest()) {DisplayListingItemMap.get(key).Module.ASI_CRM_CN_AC_Code__c=(DisplayActivityCodeId!=null&&DisplayActivityCodeId!='')?DisplayActivityCodeId:null;}
                if(DisplayListingItemMap.get(key).DetailLineMap != null && DisplayListingItemMap.get(key).DetailLineMap.size()>0) {
                    modulesToSave.add(DisplayListingItemMap.get(key).Module);
                }
            }

            if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion') {
                Visibility_Item_Map.Module.ASI_CRM_CN_AC_Code__c = VisibilityActivityCodeId != null ? VisibilityActivityCodeId : null;
                modulesToSave.add(Visibility_Item_Map.Module);
            }
            
        
            System.Savepoint pSavepoint = Database.setSavepoint();
            try{
                upsert modulesToSave;
                
                if(ModuleDeleteList.size()>0){
                    DeleteTarget = Database.delete(ModuleDeleteList);
                    ModuleDeleteList.clear();
                }
                
                if(BRSFDeleteList.size()>0){
                    DeleteTarget = Database.delete(BRSFDeleteList);
                    BRSFDeleteList.clear();
                }
                
            }catch(Exception e){
                System.debug('Save Error');
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                msg += 'Save Error : ' +e.getMessage() + '</br>';
                pageRef = null;
                Database.rollback(pSavepoint);
                UpsertPermission = false;
                return null;
            }                       
            
            //ValidationChecking();
            
            List <ASI_CRM_CN_Contract_BRSF_Line_Item__c> linesToSave = new List <ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
         
            //BRSF Line
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : BRSF_Item_Map.DetailLineMap.values()){
                lineItem.ASI_CRM_Module__c =  BRSF_Item_Map.Module.Id;
                linesToSave.add(lineItem);
            }
         
            //PSF Line
            for(String key:PSF_Item_Map.keySet()){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : PSF_Item_Map.get(key).DetailLineMap.values()){
                    lineItem.ASI_CRM_Module__c =  PSF_Item_Map.get(key).Module.Id;

                    //Put the subbrandId of the brand group into BRSF line
                    if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Brand Group'){
                        lineItem.ASI_CRM_Line_Long_Name__c = null;
                        List<String> SubBrandId = new List<String>();
                        List<String> SubBrandName = new List<String>();
                        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line: BRSF_Item_Map.DetailLineMap.values()){
                            System.debug(line.ASI_CRM_CN_Sub_Brand__c);
                            if(lineItem.ASI_CRM_CN_Sub_Brand_Package__c == line.ASI_CRM_CN_Sub_Brand_Package__c && line.ASI_CRM_CN_Sub_Brand__c != null){
                                SubBrandId.add(line.ASI_CRM_CN_Sub_Brand__c);
                                SubBrandName.add(line.ASI_CRM_CN_Sub_Brand__r.Name);
                            }

                        }
                        lineItem.ASI_CRM_Line_Long_Name__c = String.join(SubBrandId,';');
                        lineItem.ASI_CRM_CN_Sub_brand_Group__c = String.join(SubBrandName,',');
                    }

                    linesToSave.add(lineItem);
                }
            }
         
            //Display Line
            System.debug(DisplayListingItemMap);
            for(String key:DisplayListingItemMap.keySet()){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : DisplayListingItemMap.get(key).DetailLineMap.values()){
                    System.debug(lineItem.ASI_CRM_CN_Est_Total_Dummy__c);
                    lineItem.ASI_CRM_Module__c =  DisplayListingItemMap.get(key).Module.Id;
                    linesToSave.add(lineItem);
                }
            }
           
            System.debug(CoveredOutlet_Item_Map);
            Set<Id> customerIdSet = new Set<Id>();
            for(ASI_CRM_CN_Covered_Outlet__c record : CoveredOutlet_Item_Map.values()){
                customerIdSet.add(record.ASI_CRM_CN_Outlet__c);
            }
            for(ASI_CRM_CN_Covered_Outlet__c record : CoveredWS_Item_Map.values()){
                customerIdSet.add(record.ASI_CRM_CN_Outlet__c);
            }

            Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
            for(ASI_CRM_AccountsAdditionalField__c record :[SELECT Id, RecordType.Developername from ASI_CRM_AccountsAdditionalField__c where Id in:customerIdSet limit 50000]){
                customerMap.put(record.Id,record);
            }

            //save Covered Outlet Line Items
            Integer coveredOutletCount = 0;
            for (String key : CoveredOutlet_Item_Map.keySet()){
                ASI_CRM_CN_Covered_Outlet__c outlet = CoveredOutlet_Item_Map.get(key);
                //if(outlet != null && outlet.ASI_CRM_CN_Outlet__c != null && checkOutlet(outlet.ASI_CRM_CN_Outlet__c) =='Covered' && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                if(outlet != null && outlet.ASI_CRM_CN_Outlet__c != null && customerMap.get(outlet.ASI_CRM_CN_Outlet__c).RecordType.Developername =='ASI_CRM_Outlet_CN' && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                    Save_CoveredOutlet_Item.add(outlet);
                    coveredOutletCount ++;
                }else if(outlet.Id != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == false){
                    Saved_CoveredOutlet_Temp.add(outlet);
                }else if(outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                    ErrorHandling('Invalid Outlet in Covered Outlet!');
                }
                               
            }
            //save WS Outlet Line Items
            for (String key : CoveredWS_Item_Map.keySet()){
                ASI_CRM_CN_Covered_Outlet__c WSoutlet = CoveredWS_Item_Map.get(key);
                //if(WSoutlet != null && WSoutlet.ASI_CRM_CN_Outlet__c != null && checkOutlet(WSoutlet.ASI_CRM_CN_Outlet__c) =='WS' && WSoutlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                if(WSoutlet != null && WSoutlet.ASI_CRM_CN_Outlet__c != null && customerMap.get(WSoutlet.ASI_CRM_CN_Outlet__c).RecordType.Developername =='ASI_CRM_CN_WS' && WSoutlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                    Save_CoveredOutlet_Item.add(WSoutlet);
                }else if(WSoutlet.Id != null && WSoutlet.ASI_CRM_CN_Selected_Covered_Outlet__c == false){
                    Saved_CoveredOutlet_Temp.add(WSoutlet);
                }else if(WSoutlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                    ErrorHandling('Invalid Outlet in WS Outlet!');
                }              
            }
           
            //For Outlet Promotion, save Visibility line
            if(VisibilityLine.ASI_CRM_CN_Contract__c != null && this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion'){
                calVisibilityAmt();
                if(Saved_CoveredOutlet_Temp.size()>0){
                    for(ASI_CRM_CN_Covered_Outlet__c outlet : Saved_CoveredOutlet_Temp){
                        if(customerMap.get(outlet.ASI_CRM_CN_Outlet__c).RecordType.Developername =='ASI_CRM_Outlet_CN'){
                            VisibilityLine.ASI_CRM_CN_Est_Total_Dummy__c -= outlet.ASI_CRM_CN_Est_Visibility_Amt__c != null ? outlet.ASI_CRM_CN_Est_Visibility_Amt__c : 0;
                        }
                    }
                }
                VisibilityLine.ASI_CRM_Module__c = Visibility_Item_Map.Module.Id;
                linesToSave.add(VisibilityLine);
            }/*else if(VisibilityLine.ASI_CRM_CN_Contract__c ==null && this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion'){
                VisibilityLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = PageId,
                        ASI_CRM_Type__c ='Visibility',
                        ASI_CRM_Module__c = Visibility_Item_Map.Module.Id,
                        ASI_CRM_CN_Activity_Code__c = VisibilityActivityCodeId,
                        ASI_CRM_CN_Est_Total_Dummy__c = 0,
                        RecordTypeId = BRSFLineRecordTypeId);
                linesToSave.add(VisibilityLine);
            }*/
         
           /*if(Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0){
                CoveredOutletValdationChecking(Save_CoveredOutlet_Item);
           }*/
           
            if(UpsertPermission || Test.isRunningTest()){ 
            
                try{
                    //Previous Version PSF Est. Total +Adjustment=Expected PSF Est. Total
                    if (!isPOModi) {
                        calculateContractSummary();
                    }
                    if (isPOModi && ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c != null && ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c != null) {
                        if(ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c ==0 || ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c == null) {
                            ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = 100;
                        }else{
                            //ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = (ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c - ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c) / ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c * 100;
                            ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c / ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c * 100;
                        }
                    }
                    if (isPOModi && ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c != null && ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c != null) {
                        if(ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c ==0 || ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c == null){
                            ContractSelected.ASI_CRM_Display_Estimate_Adjustment_Amt__c = 100;
                        }else {
                            //ContractSelected.ASI_CRM_Display_Estimate_Adjustment_Amt__c = (ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c - ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c) / ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c * 100;
                            ContractSelected.ASI_CRM_Display_Estimate_Adjustment_Amt__c = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c / ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c * 100;
                        }
                    }
                    /*if (isPOModi && ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c != null && ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c != null) {
                        ContractSelected.ASI_CRM_Visibility_Est_Adjust_percent__c = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c / (ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c == null || ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c ==0 ? 1 : ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c) *100;
                    }*/

                    if (ASI_CRM_CN_PromotionContractUtilClass.outletThreshold() <= coveredOutletCount) {
                        Database.executeBatch(new ASI_CRM_CN_PromoVolumeAggregationJob(true, new Set<Id>{
                                ContractSelected.Id
                        }));
                    }

                    update ContractSelected;

                    delete deletedLines;

                    upsert linesToSave;
                
                    if(Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0){
                        upsert Save_CoveredOutlet_Item;
                    }
                    if(Saved_CoveredOutlet_Temp!= null && Saved_CoveredOutlet_Temp.size() > 0){
                        delete Saved_CoveredOutlet_Temp;
                    }
                
                    pageRef = new PageReference('/apex/ASI_CRM_CN_PromotionContractPage');
                    pageref.getParameters().put('id',PageId);
                    pageref.getParameters().put('IsDetailEdit',isQuickSave ? '1' : '0');
                    pageRef.setRedirect(true);
                                    
                
                    
                }catch(Exception e){
                    System.debug('Save Error');
                    System.debug(e.getMessage());
                    System.debug(e.getStackTraceString());
                    msg += 'Save Error : ' +e.getMessage() + '</br>';
                    pageRef = null;
                    Database.rollback(pSavepoint);
                    UpsertPermission = false;
                    return null;
                }     
            }                  
        }      
        return pageRef;
        
    }


    public void ValidationChecking(){
        Integer coun = 1;
        Integer moduleIndex = 1;
        
        System.debug(LoggingLevel.INFO, '*** this.ContractSelected: ' + this.ContractSelected);

        Map<String, Decimal> BRSFContractVolMap = new Map<String, Decimal>();
        
        Set<String> SubBrandIdSet = new Set<String> ();
        Set<String> BrandGroupSet = new Set<String> ();
        
        //*************************************Looping the BRSF*************************************              
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine : BRSF_Item_Map.DetailLineMap.values()) {             
                if (BRSFLine.ASI_CRM_CN_Sub_Brand__c == null) {
                    ErrorHandling(Label.ASI_CRM_CN_Sub_Brand_in_BRSF_Validation + String.valueOf(coun));//Please Input Sub-Brand in BRSF in line.
                    continue;
                }
                
                if (!BRSFContractVolMap.containsKey(BRSFLine.ASI_CRM_CN_Sub_Brand__c)) {
                    BRSFContractVolMap.put(BRSFLine.ASI_CRM_CN_Sub_Brand__c, 0);
                } else if (BRSFContractVolMap.containsKey(BRSFLine.ASI_CRM_CN_Sub_Brand__c)) {
                    ErrorHandling(Label.ASI_CRM_CN_Duplicate_Sub_brand_Promotion + String.valueOf(coun));//'Please found the duplicated in BRSF in Sub-Brand '
                }
                
                if (BRSFLine.ASI_CRM_CN_Sub_Brand__c != null) {
                    SubBrandIdSet.add(BRSFLine.ASI_CRM_CN_Sub_Brand__c);
                }
                if (BRSFLine.ASI_CRM_CN_Sub_Brand_Package__c != null) {
                    BrandGroupSet.add(BRSFLine.ASI_CRM_CN_Sub_Brand_Package__c);
                }                              
                coun++;
        }

        //Check the mark up percent > max mark up
        if(maxMarkUp != null && BRSF_Item_Map.Module.ASI_CRM_CN_Total_Markup__c != null) {
            if(BRSF_Item_Map.Module.ASI_CRM_CN_Total_Markup__c > maxMarkUp) {
                if(UserInfo.getLanguage()=='zh_CN')
                    ErrorHandling('加价率超标');
                else
                    ErrorHandling('Mark up % must be <= maximum mark up!');
            }
        }
         
         
        //*************************************Looping the PSF*************************************
        for (interimData interimData : PSF_Item_Map.values()) {
                String methodology = '';
                if(MethodologyById.containsKey(interimData.Module.ASI_CRM_Methodology__c) && MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c).Name != null 
                    && MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c).Name != '')
                {
                    methodology = MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c).Name;
                }

                Integer lineIndex = 0;

                Map<String ,Decimal> packNumberMap = new Map<String ,Decimal>();                
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                    system.debug('lineItem ==' + lineItem);
                    system.debug('interimData.Module.ASI_CRM_Volume_Base__c ==' + interimData.Module.ASI_CRM_Volume_Base__c);
                    lineIndex++;
                    // if(lineItem.ASI_CRM_CN_Package_Number__c != null && interimData.Module.ASI_CRM_Methodology__r.Name != 'Rebate%(By Package)')
                    // {
                    //     if(packNumberMap.containsKey(lineItem.ASI_CRM_CN_Sub_brand_Group__c))
                    //     {
                    //         Decimal sumPack = (packNumberMap.get(lineItem.ASI_CRM_CN_Sub_brand_Group__c) == null ? 0 : packNumberMap.get(lineItem.ASI_CRM_CN_Sub_brand_Group__c)) + lineItem.ASI_CRM_CN_Package_Number__c;
                    //         packNumberMap.put(lineItem.ASI_CRM_CN_Sub_brand_Group__c, sumPack);
                    //     }
                    //     else
                    //     {
                    //         Decimal sumPack = lineItem.ASI_CRM_CN_Package_Number__c;
                    //         packNumberMap.put(lineItem.ASI_CRM_CN_Sub_brand_Group__c, sumPack);

                    //     }
                    // }

                    if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && !SubBrandIdSet.contains(lineItem.ASI_CRM_CN_Sub_Brand__c)){
                        ErrorHandling('No Sub-Brand in BRSF!');
                    }else if(interimData.Module.ASI_CRM_Volume_Base__c == 'By Brand Group' && !BrandGroupSet.contains(lineItem.ASI_CRM_CN_Sub_Brand_Package__c)){
                        ErrorHandling('No Brand Group in BRSF!');
                    }
                }

                if(methodology =='Rebate%(By Ladder)' || methodology =='Rebate%(By Month)'){
                    Map<String, Decimal> checkProportionMap = new Map<String, Decimal>();
                    if(interimData.Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand'){
                        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()){
                            if(checkProportionMap.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)){
                                Decimal oldValue = checkProportionMap.get(lineItem.ASI_CRM_CN_Sub_Brand__c);
                                checkProportionMap.put(lineItem.ASI_CRM_CN_Sub_Brand__c, oldValue+(lineItem.ASI_CRM_CN_Package_Number__c != null ? lineItem.ASI_CRM_CN_Package_Number__c : 0));
                            }else{
                                checkProportionMap.put(lineItem.ASI_CRM_CN_Sub_Brand__c, lineItem.ASI_CRM_CN_Package_Number__c != null ? lineItem.ASI_CRM_CN_Package_Number__c : 0);
                            }
                        }
                    }else if(interimData.Module.ASI_CRM_Volume_Base__c == 'By Brand Group'){
                        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()){
                            if(checkProportionMap.containsKey(lineItem.ASI_CRM_CN_Sub_Brand_Package__c)){
                                Decimal oldValue = checkProportionMap.get(lineItem.ASI_CRM_CN_Sub_Brand_Package__c);
                                checkProportionMap.put(lineItem.ASI_CRM_CN_Sub_Brand_Package__c, oldValue+(lineItem.ASI_CRM_CN_Package_Number__c != null ? lineItem.ASI_CRM_CN_Package_Number__c : 0));
                            }else{
                                checkProportionMap.put(lineItem.ASI_CRM_CN_Sub_Brand_Package__c, lineItem.ASI_CRM_CN_Package_Number__c != null ? lineItem.ASI_CRM_CN_Package_Number__c : 0);
                            }
                        }
                    }else if(interimData.Module.ASI_CRM_Volume_Base__c == 'By Total'){
                        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()){
                            if(checkProportionMap.containsKey('Total')){
                                Decimal oldValue = checkProportionMap.get('Total');
                                checkProportionMap.put('Total', oldValue+(lineItem.ASI_CRM_CN_Package_Number__c != null ? lineItem.ASI_CRM_CN_Package_Number__c : 0));
                            }else{
                                checkProportionMap.put('Total', lineItem.ASI_CRM_CN_Package_Number__c != null ? lineItem.ASI_CRM_CN_Package_Number__c : 0);
                            }
                        }
                    }

                    for(Decimal proportion : checkProportionMap.values()){
                        if(proportion > 100){
                            if(UserInfo.getLanguage()=='zh_CN')
                                ErrorHandling('一个项目指标下，比重的加总需小于等于100%');
                            else
                                ErrorHandling('Proportion must be <=100!');
                        }
                    }
                }
        }

        //************Check the visibility and free goods by Trade Margin setting
        String tmType =  this.ContractSelected.ASI_TH_CRM_Promotion_Type__c =='Outlet Promotion' || this.ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Consumer Promotion' ? 'T1 to Outlet' : 'T1 to T2';

        List<ASI_CN_Trade_Margin__c> tradeMarginList = [select Id,
                                                               ASI_CRM_CN_Visibility_Threshold__c,
                                                               ASI_CRM_CN_Free_Goods_GWP_Threshold__c,
                                                               ASI_CRM_Other_Cost_Threshold__c,
                                                               ASI_CRM_Other_Cost_Threshold_for_Remark__c
                                                        from ASI_CN_Trade_Margin__c
                                                        where RecordType.DeveloperName='ASI_CRM_CN_Trade_Margin_Promotion'
                                                        and Type__c = :tmType
                                                        and ASI_CRM_CN_Region__c = :this.ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                        and ASI_CRM_Channel__c = :this.ContractSelected.ASI_CRM_PO_Channel__c];
        if(tradeMarginList.size()>0){
           for(ASI_CN_Trade_Margin__c tm :tradeMarginList){
               if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Outlet Promotion'){
                   if(VisibilityLine.ASI_CRM_CN_Est_Total_Dummy__c > tm.ASI_CRM_CN_Visibility_Threshold__c && BRSF_Item_Map.DetailLineMap.size()==0){
                       ErrorHandling('Visibility amount > Threshold! Target must be created!');
                   }
               } else if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Consumer Promotion'){
                   Decimal totalAmt = 0;
                   for (interimData interimData : DisplayListingItemMap.values()) {
                       for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                           totalAmt += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                       }
                   }
                   Integer coveredOutletCnt = 0;
                   for(ASI_CRM_CN_Covered_Outlet__c record : CoveredOutlet_Item_Map.values()){
                       if(record.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                           coveredOutletCnt++;
                           break;
                       }
                   }
                   if(totalAmt > tm.ASI_CRM_CN_Free_Goods_GWP_Threshold__c && (BRSF_Item_Map.DetailLineMap.size()==0 || coveredOutletCnt==0)){
                       ErrorHandling('Free Goods amount > Threshold! Target/Covered Outlet must be created!');
                   }
               }
               //Others Module Checking
               for(interimData interimData :PSF_Item_Map.values()){
                   if(interimData.Module.ASI_CRM_Methodology__r.Name=='Others'){
                       Decimal totalAmt = 0;
                       for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : interimData.DetailLineMap.values()) {
                           totalAmt += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null? lineItem.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                       }

                       Integer coveredOutletCnt = 0;
                       for(ASI_CRM_CN_Covered_Outlet__c record : CoveredOutlet_Item_Map.values()){
                           if(record.ASI_CRM_CN_Selected_Covered_Outlet__c == true){
                               coveredOutletCnt++;
                               break;
                           }
                       }
                       if(totalAmt > tm.ASI_CRM_Other_Cost_Threshold__c && coveredOutletCnt ==0){
                           ErrorHandling('Others amount > Threshold! Covered Outlet must be created!');
                       }
                       if(totalAmt > tm.ASI_CRM_Other_Cost_Threshold_for_Remark__c && interimData.Module.ASI_CRM_Remark__c == null){
                            if(UserInfo.getLanguage()=='zh_CN')
                                ErrorHandling('投资方式为“其他”时，需填写备注');
                            else
                                ErrorHandling('Others amount > Threshold! Module remark must be input!');
                       }

                   }
               }

           }
        }

    }
    
    //Check the outlet is WS/Covered
    //return 'Covered' = Covered Oulet ; return 'WS' = WS Outlet
    public string checkOutlet(Id OutletId){
        if(OutletId != null){
            try{
                ASI_CRM_AccountsAdditionalField__c Outlet = [select RecordType.Developername from ASI_CRM_AccountsAdditionalField__c where Id =:OutletId limit 1];
                //if(CustomerById.containsKey(OutletId)) {
                    //String Developername = CustomerById.get(OutletId).RecordType.Developername;
                String Developername = Outlet.RecordType.Developername;
                    if (Developername == 'ASI_CRM_Outlet_CN') {
                        return 'Covered';
                    } else if (Developername == 'ASI_CRM_CN_WS') {
                        return 'WS';
                    }
                //}
                return null;
            }catch(Exception e){
                return null;
            }       
        }
        else{
            return null;
        }
    }
    
    public pageReference OutletLineChange(){
        String paramId = ApexPages.currentPage().getParameters().get('ITEMKEY');
        String OutletLineType = ApexPages.currentPage().getParameters().get('OutletLineType');
        if(paramId != null){
            try{    
                if(OutletLineType == 'Covered'){
                    ASI_CRM_AccountsAdditionalField__c Outlet = [select id, 
                                                                    ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
                                                                    ASI_CRM_CN_Area_Name__c,
                                                                    ASI_CRM_CN_CCity__c, 
                                                                    ASI_CRM_CN_City_Name__c,
                                                                    ASI_CRM_CN_NewChannel__c 
                                                                 from ASI_CRM_AccountsAdditionalField__c where Id =:CoveredOutlet_Item_Map.get(paramId).ASI_CRM_CN_Outlet__c limit 1];                                                   
                    CoveredOutlet_Item_Map.get(paramId).ASI_CRM_CN_Outlet__r = Outlet;
                }else{
                    ASI_CRM_AccountsAdditionalField__c Outlet = [select id, 
                                                                    ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
                                                                    ASI_CRM_CN_Area_Name__c,
                                                                    ASI_CRM_CN_CCity__c, 
                                                                    ASI_CRM_CN_City_Name__c,
                                                                    ASI_CRM_CN_NewChannel__c 
                                                                 from ASI_CRM_AccountsAdditionalField__c where Id =:CoveredWS_Item_Map.get(paramId).ASI_CRM_CN_Outlet__c limit 1];  
                    CoveredWS_Item_Map.get(paramId).ASI_CRM_CN_Outlet__r = Outlet;
                }               
                return null;
            }catch(Exception e){
                return null;
            }       
        }
        else{
            return null;
        }
    }
    
    public void updateBRSFItemMapByJSON(String jsonString){
        system.debug('jsonString =='+jsonString);
        interimData BRSF_Item_MapFromJSON =  (interimData) JSON.deserialize(jsonString, interimData.class);
        BRSF_Item_Map.DetailLineMap = BRSF_Item_MapFromJSON.DetailLineMap;
    }
    
     public void updatePSFItemMapByJSON(String jsonString){
        Map<String, interimDataDto> PSF_Item_MapJSON = (Map<String, interimDataDto>) JSON.deserialize(jsonString, Map<String, interimDataDto>.class);
        for (String key : PSF_Item_Map.keySet()) {
            interimData interimData = PSF_Item_Map.get(key).copyFromDTO(PSF_Item_MapJSON.get(key));
            PSF_Item_Map.put(key, interimData);
        }
    }
    
    public void updateDisplayListingItemMapByJSON(String jsonString){
        Map<String, interimDataDto> DisplayListing_Item_MapJSON = (Map<String, interimDataDto>) JSON.deserialize(jsonString, Map<String, interimDataDto>.class);
        for (String key : DisplayListingItemMap.keySet()) {
            interimData interimData = DisplayListingItemMap.get(key).copyFromDTO(DisplayListing_Item_MapJSON.get(key));
            //interimData interimData = DisplayListingItemMap.get(key);
            DisplayListingItemMap.put(key, interimData);
        }
    }
       
      
   
        
      public ASI_CRM_Module__c createModule(String lineType) {
        
            ASI_CRM_Module__c module = new ASI_CRM_Module__c( 
            ASI_CRM_CN_KPI_Base__c = lineType =='PSF' ? 'Value base' : 'Volume base',       
            ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
            ASI_CRM_Line_Type__c = lineType,
            ASI_CRM_CN_Minimal_Achievement__c = 0,
            ASI_CRM_CN_Total_Markup__c = 0,
            ASI_CRM_Contract__c = PageId
            );     

            if(lineType=='Visibility'){
                module.ASI_CRM_CN_KPI_Base__c='Other';
            }
        /*ASI_CRM_Methodology__c defaultMethodology;
        for (ASI_CRM_Methodology__c methodology : defaultMethodologies) {
            if (methodology.ASI_CRM_Type__c == module.ASI_CRM_Line_Type__c && methodology.ASI_CRM_CN_KPI_Base__c == module.ASI_CRM_CN_KPI_Base__c) {
                defaultMethodology = methodology;
            }
        }

        if (module.ASI_CRM_Line_Type__c == 'PSF') {
            if (module.ASI_CRM_CN_KPI_Base__c == 'Volume base') {
                module.ASI_CRM_Volume_Base__c = 'By Sub-brand';
                module.ASI_CRM_Unit__c = 'Std. Btl.';
                module.ASI_CRM_CN_Criteria__c = 'NA';
            }
            if (module.ASI_CRM_CN_KPI_Base__c == 'Value base') {
                module.ASI_CRM_Volume_Base__c = 'By Sub-brand';
                module.ASI_CRM_Unit__c = null;
                module.ASI_CRM_CN_Criteria__c = 'NA';
            }
        }
        if (module.ASI_CRM_Line_Type__c == 'Display') {
                module.ASI_CRM_Volume_Base__c = 'By Total';
                module.ASI_CRM_Unit__c = 'CR12 Extra Eqv.';
        }
        if (defaultMethodology != null) {
            module.ASI_CRM_Methodology__c = defaultMethodology.Id;
            module.ASI_CRM_Methodology__r = defaultMethodology;
        }*/

        return module;
    }
    
    //Add Module
    public void PSFAddModule() {
        
        String ModuleType = ApexPages.currentPage().getParameters().get('ModuleType');
        
        if(ModuleType == 'PSF'){
        
            updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
            SettingDefaultValue();
            //Construct Key Id
            String keyId = LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine();
            ASI_CRM_Module__c module = createModule('PSF');
            interimData d = createInterimData(module);
            if(d != null) {
                PSF_Item_Map.put(keyId, d);
                updatePSFItemMapDTO();
            }else{
                //Msg = 'No Master Data Found!';
                ErrorHandling('No Master Data Found!');
            }
        }
        else
        {
            updateDisplayListingItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
            SettingDefaultValue();
            //Construct Key Id
            String keyId = LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine();
            ASI_CRM_Module__c module = createModule('Display');
            interimData d = createInterimData(module);
            if(d != null) {
                DisplayListingItemMap.put(keyId, d);
                updateDisplayListingItemMapDTO();
            }else{
                //Msg = 'No Master Data Found!';
                ErrorHandling('No Master Data Found!');
            }
        }

        // Since the total will be different after deleting a module, need to recalculate
        calculateContractSummary();

    }
    
    // called when deleting a module. Used by both PSF and Display module
    public void DeletePSFModule(){
        SettingDefaultValue();
        String param_Id = ApexPages.currentPage().getParameters().get('PARAMID');
        system.debug('DeletePSFModule =='+ param_Id);

        system.debug('DeletePSFModule =='+ PSF_Item_Map.containsKey(param_Id));

        system.debug('开始前 =='+ PSF_Item_Map.size());
        if(PSF_Item_Map.containsKey(param_Id) && !PSF_Item_Map.isEmpty()){
            for(String key : PSF_Item_Map.get(param_Id).DetailLineMap.keySet()){
                ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget=PSF_Item_Map.get(param_Id).DetailLineMap.get(key);
                if(delTarget.Id != null){
                    BRSFDeleteList.add(delTarget);
                }
                //remove PSF Line
                PSF_Item_Map.get(param_Id).DetailLineMap.remove(key);
            }
            if(PSF_Item_Map.get(param_Id).Module.Id!=null){
                ModuleDeleteList.add(PSF_Item_Map.get(param_Id).Module);
            }
            //ModuleDeleteList
            //remove interimData
            PSF_Item_Map.remove(param_Id);
        }
        system.debug('结束后 =='+ PSF_Item_Map.size());
        
        if(DisplayListingItemMap.containsKey(param_Id) && !DisplayListingItemMap.isEmpty()){
            for(String key : DisplayListingItemMap.get(param_Id).DetailLineMap.keySet()){
                ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget=DisplayListingItemMap.get(param_Id).DetailLineMap.get(key);
                if(delTarget.Id != null){
                    BRSFDeleteList.add(delTarget);
                }
                //remove PSF Line
                DisplayListingItemMap.get(param_Id).DetailLineMap.remove(key);
            }
            if(DisplayListingItemMap.get(param_Id).Module.Id!=null){
                ModuleDeleteList.add(DisplayListingItemMap.get(param_Id).Module);
            }
            //ModuleDeleteList
            //remove interimData
            DisplayListingItemMap.remove(param_Id);
        }
        // Since the total will be different after deleting a module, need to recalculate
        calculateContractSummary();
    }
    
    //Refresh Module
    public void refreshModule(){
        system.debug('PSF_Item_Map === '+PSF_Item_Map);
        //Module line ID
        String paramId = ApexPages.currentPage().getParameters().get('PARAM_Line_ID');
        //Module PSF/Display
        String ModuleType = ApexPages.currentPage().getParameters().get('ModuleType');
        if(ModuleType=='PSF'){ 
        
            //interimData dataInRefresh =  PSF_Item_Map.containsKey(paramId) ? PSF_Item_Map.get(paramId) : DisplayListingItemMap.get(paramId);
            interimData dataInRefresh =  PSF_Item_Map.get(paramId);
            
            if (dataInRefresh == null) {
                return;
            }
        
            String lineType='PSF';
            
            if (lineType == 'PSF' && ApexPages.currentPage().getParameters().get('Item_MapJSON') != null) {
                updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('Item_MapJSON'));
            }
        
            dataInRefresh.moduleReadOnly = true;
            dataInRefresh.showLineItems = true;
            ASI_CRM_Methodology__c methodology = MethodologyById.get(dataInRefresh.Module.ASI_CRM_Methodology__c);
            if (methodology != null) {
                dataInRefresh.MethodologyDisplay = showCN ? methodology.ASI_CRM_Chinese_Name__c : methodology.Name;
            }
        
            for (String key : dataInRefresh.DetailLineMap.keySet()) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = dataInRefresh.DetailLineMap.get(key);
                if (delTarget.Id != null) {
                    BRSFDeleteList.add(delTarget);
                }
                dataInRefresh.DetailLineMap.remove(key);
            }
        
            //Set displayMultiTable to true if the combination need to draw sub table
            //if((dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && dataInRefresh.Module.ASI_CRM_Methodology__r.Name == 'Rebate%(By Package)')||
               //(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && dataInRefresh.Module.ASI_CRM_Methodology__r.Name == 'Rebate%(By Month)')){
            if(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && dataInRefresh.Module.ASI_CRM_Methodology__r.Name != 'Per Incentive Btl'
                    && dataInRefresh.Module.ASI_CRM_Methodology__r.Name != 'Rebate%'){
                dataInRefresh.displayMultiTable = true;
                dataInRefresh.PSFMultiTableMap.Clear();
                dataInRefresh.PSFLadderAmountMap.Clear();
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
                    //dataInRefresh.PSFMultiTableList.add(line.ASI_CRM_CN_Sub_Brand__c);
                    dataInRefresh.PSFMultiTableMap.put(line.ASI_CRM_CN_Sub_Brand__c, line.ASI_CRM_CN_Sub_Brand__r.Name);

                    dataInRefresh.PSFLadderAmountMap.put(line.ASI_CRM_CN_Sub_Brand__c, (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0));

                } 
            }
            else if(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Brand Group' && dataInRefresh.Module.ASI_CRM_Methodology__r.Name != 'Rebate%'){
                dataInRefresh.displayMultiTable = true;
                dataInRefresh.PSFMultiTableMap.Clear();
                dataInRefresh.PSFLadderAmountMap.Clear();
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
                    //if(PSF_Item_Map.containsKey(line.ASI_CRM_CN_Sub_Brand_Package__c)){
                    if(dataInRefresh.PSFMultiTableMap.containsKey(line.ASI_CRM_CN_Sub_Brand_Package__c)){
                        String ExistingValue = (dataInRefresh.PSFMultiTableMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c) == null ? '' : dataInRefresh.PSFMultiTableMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c)) +',  ';
                        dataInRefresh.PSFMultiTableMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, ExistingValue + (line.ASI_CRM_CN_Sub_Brand__r.Name == null ? '' : line.ASI_CRM_CN_Sub_Brand__r.Name));
                        
                    }else{
                        dataInRefresh.PSFMultiTableMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, line.ASI_CRM_CN_Sub_Brand__r.Name);
                                           
                    }
                    //if(dataInRefresh.Module.ASI_CRM_Methodology__r.Name.indexOf('By Ladder') != -1){
                        if(dataInRefresh.PSFLadderAmountMap.containsKey(line.ASI_CRM_CN_Sub_Brand_Package__c)){
                            Decimal ExistingValue = (dataInRefresh.PSFLadderAmountMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c) == null ? 0 : dataInRefresh.PSFLadderAmountMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c));
                            dataInRefresh.PSFLadderAmountMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, (ExistingValue + (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0)));

                            
                        }
                        else{
                            dataInRefresh.PSFLadderAmountMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0));
                        }
                    //}
                    
                } 
            }
            
            Decimal TotalPurchaseValue = 0;
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){ 
                  TotalPurchaseValue += (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0);                                 
            }
            dataInRefresh.PSFLadderAmountMap.put('Total', TotalPurchaseValue);
            
            
            //**************Per Incentive Btl By Sub-Brand**************
            if(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand' && dataInRefresh.Module.ASI_CRM_Methodology__r.Name=='Per Incentive Btl' &&!dataInRefresh.displayMultiTable){
                
                if(dataInRefresh.DetailLineMap.size() != 0){
                    dataInRefresh.DetailLineMap.Clear();
                }
                
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BySubBrandRefresh(dataInRefresh.Module)){
                    dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),line);
                    
                }
                //CalPSFAmount(paramId);
                //SettingDefaultValue();
            }


            //*************Rabate%***************
            if(dataInRefresh.Module.ASI_CRM_Methodology__r.Name == 'Rebate%'){
                CreateRebateLine(dataInRefresh, dataInRefresh.Module.ASI_CRM_Volume_Base__c);
            }
            
            //************* By Month***************
            if(dataInRefresh.Module.ASI_CRM_Methodology__r.Name == 'Rebate%(By Month)'){
                
                if(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    for(string key : dataInRefresh.PSFMultiTableMap.keySet()){
                        CreatePSFYearMonthLine(dataInRefresh, key, null);
                    }
                }
                
                if(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Brand Group'){
                    for(string key : dataInRefresh.PSFMultiTableMap.keySet()){
                        CreatePSFYearMonthLine(dataInRefresh, null, key);
                    }
                }
                
                if(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Total'){ 
                    dataInRefresh = CreatePSFYearMonthLine(dataInRefresh, null, null);
                }
                
            }
            
            //************* Other***************
            if(dataInRefresh.Module.ASI_CRM_Methodology__r.Name == 'Others'){
                
                if(dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Total'){
                    dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), ByTotalAmountGenerating(lineType));
                } 
            
            }
            system.debug('PSF_Item_Map =='+dataInRefresh);
            PSF_Item_Map.remove(paramId);
            PSF_Item_Map.put(paramId, dataInRefresh);
            system.debug('PSF_Item_Map =='+PSF_Item_Map.get(paramId));
        
            updatePSFItemMapDTO();
        }
        //End PSF
        else{ //Display
        
            interimData dataInRefresh =  DisplayListingItemMap.get(paramId);
            
            if (dataInRefresh == null) {
                return;
            }
        
            String lineType='Display';
            
            if (lineType == 'Display' && ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON') != null) {
                updateDisplayListingItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
            }
        
            dataInRefresh.moduleReadOnly = true;
            dataInRefresh.showLineItems = true;
            ASI_CRM_Methodology__c methodology = MethodologyById.get(dataInRefresh.Module.ASI_CRM_Methodology__c);
            if (methodology != null) {
                dataInRefresh.MethodologyDisplay = showCN ? methodology.ASI_CRM_Chinese_Name__c : methodology.Name;
            }

            for (String key : dataInRefresh.DetailLineMap.keySet()) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c delTarget = dataInRefresh.DetailLineMap.get(key);
                if (delTarget.Id != null) {
                    BRSFDeleteList.add(delTarget);
                }
                dataInRefresh.DetailLineMap.remove(key);
            }
                                               
        
            //************* Other***************
            if(dataInRefresh.Module.ASI_CRM_Methodology__r.Name == 'Others' && dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Total'){
                dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), ByTotalAmountGenerating(lineType));  
            }
                            
            if(dataInRefresh.Module.ASI_CRM_Methodology__r.Name == 'Rebate%' && dataInRefresh.Module.ASI_CRM_Volume_Base__c=='By Total'){

                Decimal PurchaseTarget = 0;
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
                    //PurchaseTarget += line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0;
                    PurchaseTarget = PurchaseTarget + (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0);
                }
                ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                TempLine.ASI_CRM_Type__c=lineType;
                TempLine.ASI_CRM_Volume_Base__c='By Total';
                TempLine.ASI_CRM_Max_Incentive__c=9999999;
                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Contract__c=PageId;
                TempLine.ASI_CRM_CN_Min_Purchase_Target__c = PurchaseTarget;
                TempLine.ASI_CRM_CN_Activity_Code__c = DisplayActivityCodeId != null && DisplayActivityCodeId!= ''? DisplayActivityCodeId:null;
                TempLine.RecordTypeId = BRSFLineRecordTypeId;
                dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),TempLine);
            }
        
            updateDisplayListingItemMapDTO();
        }  
        system.debug('PSF_Item_Map =end== '+PSF_Item_Map);
        
    }
    
    //Create Year/Month for PSF (By Month)
    public interimData CreatePSFYearMonthLine(interimData dataInRefresh, String SubBrandId, String SubBrandPackage){
         
         for(date d=this.ContractSelected.ASI_CRM_CN_PO_Start_Date__c ; d <= this.ContractSelected.ASI_CRM_CN_PO_End_Date__c; d=d.addMonths(1)){
                
                ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();               
                TempLine.ASI_CRM_Type__c='PSF';
                //TempLine.ASI_CRM_Volume_Base__c='By Total';
                TempLine.ASI_CRM_Volume_Base__c= SubBrandId != null ? 'By Sub-Brand' :  SubBrandPackage != null ? 'By Brand Group' : 'By Total' ;
                TempLine.ASI_CRM_Max_Incentive__c=9999999;
                TempLine.ASI_CRM_CN_Date__c = d;
                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Contract__c=PageId;
                TempLine.ASI_CRM_CN_Sub_Brand__c=SubBrandId; 
                TempLine.ASI_CRM_CN_Sub_Brand_Package__c = SubBrandPackage;
                TempLine.ASI_CRM_CN_Activity_Code__c = PSFActivityCodeId;
                TempLine.RecordTypeId = BRSFLineRecordTypeId;
                dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),TempLine);
                
            }
        
        return dataInRefresh;   
                
    }

    //Create BRSF line for Rebate%
    public interimData CreateRebateLine(interimData dataInRefresh, String VolumeBase){
        if(VolumeBase == 'By Sub-Brand'){
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
                ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                TempLine.ASI_CRM_Type__c='PSF';
                TempLine.ASI_CRM_Volume_Base__c='By Sub-Brand';
                TempLine.ASI_CRM_Max_Incentive__c=9999999;
                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Contract__c=PageId;
                TempLine.ASI_CRM_CN_Sub_Brand__c= line.ASI_CRM_CN_Sub_Brand__c;
                TempLine.ASI_CRM_Map_Key__c=line.ASI_CRM_CN_Sub_Brand__r.Name;
                TempLine.ASI_CRM_CN_Min_Purchase_Target__c = line.ASI_CRM_CN_Contract_Purchase_Value__c;
                TempLine.ASI_CRM_CN_Activity_Code__c = PSFActivityCodeId;
                TempLine.RecordTypeId = BRSFLineRecordTypeId;
                dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),TempLine);
            }
        }
        else if(VolumeBase == 'By Brand Group'){
            Map<String,Decimal> BrandGroupMap = new Map<String,Decimal>();
            Map<String,String> BrandGroupNameMap = new Map<String,String>();
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
                if(BrandGroupMap.containsKey(line.ASI_CRM_CN_Sub_Brand_Package__c)){
                    Decimal ExistingValue = BrandGroupMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c) == null ? 0 : BrandGroupMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c);
                    system.debug('ExistingValue ' +ExistingValue);
                    system.debug('line.ASI_CRM_CN_Contract_Purchase_Value__c ' +line.ASI_CRM_CN_Contract_Purchase_Value__c);
                    BrandGroupMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, ExistingValue + (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0));

                    String ExistingValue2 = BrandGroupNameMap.get(line.ASI_CRM_CN_Sub_Brand_Package__c);
                    BrandGroupNameMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, ExistingValue2 +', '+ (line.ASI_CRM_CN_Sub_Brand__r.Name != null ? line.ASI_CRM_CN_Sub_Brand__r.Name : ''));
                }else{
                    BrandGroupMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c, line.ASI_CRM_CN_Contract_Purchase_Value__c);
                    BrandGroupNameMap.put(line.ASI_CRM_CN_Sub_Brand_Package__c,line.ASI_CRM_CN_Sub_Brand__r.Name);
                }
            }

            for(String key : BrandGroupMap.keySet()){
                ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                TempLine.ASI_CRM_Type__c='PSF';
                TempLine.ASI_CRM_Volume_Base__c='By Brand Group';
                TempLine.ASI_CRM_Max_Incentive__c=9999999;
                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
                TempLine.ASI_CRM_CN_Contract__c=PageId;
                TempLine.ASI_CRM_CN_Sub_Brand_Package__c= key;
                //TempLine.ASI_CRM_Map_Key__c=BrandGroupNameMap.get(key);
                TempLine.ASI_CRM_CN_Sub_brand_Group__c=BrandGroupNameMap.get(key);
                TempLine.ASI_CRM_CN_Min_Purchase_Target__c = BrandGroupMap.get(key);
                TempLine.ASI_CRM_CN_Activity_Code__c = PSFActivityCodeId;
                TempLine.RecordTypeId = BRSFLineRecordTypeId;
                dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),TempLine);
            }
        }
        else if(VolumeBase == 'By Total'){
            Decimal PurchaseTarget = 0;
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
                //PurchaseTarget += line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0;
                PurchaseTarget = PurchaseTarget + (line.ASI_CRM_CN_Contract_Purchase_Value__c != null ? line.ASI_CRM_CN_Contract_Purchase_Value__c : 0);
            }
            ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
            TempLine.ASI_CRM_Type__c='PSF';
            TempLine.ASI_CRM_Volume_Base__c='By Total';
            TempLine.ASI_CRM_Max_Incentive__c=9999999;
            TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
            TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
            TempLine.ASI_CRM_CN_Contract__c=PageId;
            TempLine.ASI_CRM_CN_Min_Purchase_Target__c = PurchaseTarget;
            TempLine.ASI_CRM_CN_Activity_Code__c = PSFActivityCodeId;
            TempLine.RecordTypeId = BRSFLineRecordTypeId;
            dataInRefresh.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),TempLine);
        }
        return dataInRefresh;
    }

    
    public void resetModule(){
        String paramId = ApexPages.currentPage().getParameters().get('PARAM_Line_ID');
        interimData dataInRefresh =  PSF_Item_Map.containsKey(paramId) ? PSF_Item_Map.get(paramId) : DisplayListingItemMap.get(paramId);

        if (dataInRefresh == null) {  return;
        }
        String lineType = PSF_Item_Map.containsKey(paramId) ? 'PSF' : 'Display';
        if (lineType == 'PSF' && ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON') != null) {  updatePSFItemMapByJSON(ApexPages.currentPage().getParameters().get('PSF_Item_MapJSON'));
        }
        System.debug(PSF_Item_Map);
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
        dataInRefresh = createInterimData(dataInRefresh.module);
        if (lineType == 'PSF') {
            PSF_Item_Map.put(paramId, dataInRefresh);
        }
        /*if (lineType == 'PSF') {
            dataInRefresh.MethodologyPicklist = genMethodologyPicklist(dataInRefresh.Module.ASI_CRM_CN_KPI_Base__c, dataInRefresh.Module.ASI_CRM_Line_Type__c);
            dataInRefresh.VolumeValueBasePickList = genPSFVolValBasePicklist(dataInRefresh.MethodologyPicklist[0].getValue());
            dataInRefresh.Module.ASI_CRM_Unit__c = calculatePSFUnit(dataInRefresh.MethodologyPicklist[0].getValue());
        }*/
        updatePSFItemMapDTO();
    }
    
    
    //in PSF, after clicking 'refresh', if by sub-brand, get incentive from master
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BySubBrandRefresh(ASI_CRM_Module__c module){ // System will refer to the default PSF incentive from sub-brand grade object
        
        Set<String> SBBrandSet= new Set<String>();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
            SBBrandSet.add(line.ASI_CRM_CN_Sub_Brand__c);
        }
        
        Map<String, ASI_MFM_Sub_brand__c> SubBrandGradeMapping= new Map<String, ASI_MFM_Sub_brand__c> ();
        for(ASI_MFM_Sub_brand__c sb:[SELECT Id,Name,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c
        FROM ASI_MFM_Sub_brand__c WHERE RecordType.DeveloperName  LIKE '%CN%' AND  Id IN: SBBrandSet])
        {
            SubBrandGradeMapping.put(sb.Id, sb);
        }
        
        //Sub-Brand Grade id, Sub-Brand Grade Record for 'ASI_CRM_CN_Sub_brand_Grade'
        Map<String,ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeNameMap = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        String ExternalKey='';
        ExternalKey += ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c !=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c: '';
        ExternalKey += ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c !=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c: '';
        
        //SubBrandGradeMap: External Key (Sub Brand name + Region + Commercial Team),  ASI_CRM_Sub_Brand_Grade__c
        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        //Looping the Sub-Brand Grade

        for(ASI_CRM_Sub_Brand_Grade__c sbg: [SELECT Id, Name,ASI_CRM_Chinese_Name__c,ASI_CRM_CN_City_Tier__c,ASI_CRM_External_Key__c,ASI_CRM_CN_Incentive__c,RecordType.DeveloperName,ASI_CRM_Incentive_for_PSF__c,ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Max_Incentive__c
        FROM ASI_CRM_Sub_Brand_Grade__c WHERE
        RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade' OR  RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade_Heavy_Contract_ON'  ])
        {
            if(sbg.RecordType.DeveloperName =='ASI_CRM_CN_Sub_brand_Grade'){
                SubBrandGradeNameMap.put(sbg.Id,sbg);
            }
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){ SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }else{
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
            }
        }
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSF_Item_Map.DetailLineMap.values()){
                System.debug(line);
                ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = line.clone(false);
                TempLine.Id=null;
                //TempLine.ASI_CRM_CN_Activity_Code__c=PSFActivityCodeId;
                TempLine.ASI_CRM_Type__c='PSF';
                TempLine.ASI_CRM_Volume_Base__c='By Sub-Brand';
                TempLine.ASI_CRM_Max_Incentive__c=9999999;
                TempLine.ASI_CRM_CN_Activity_Code__c = PSFActivityCodeId;
                if(module.ASI_CRM_Methodology__r.Name =='Per Incentive Btl'){                    
                     TempLine.ASI_CRM_Est_Total_QTY_std_Btl__c = line.ASI_CRM_CN_Total_Volume_Std_btl__c;
                     TempLine.ASI_CRM_CN_Est_Total_Dummy__c =  0;
                }

            /*// if current module is Value base, copy BRSF Contract purchase value(ASI_CRM_CN_Contract_Total_Dummy__c) to PSF Contract purchase value(ASI_CRM_CN_Contract_Purchase_Value__c)
            if (module.ASI_CRM_CN_KPI_Base__c == 'Value base') {
                TempLine.ASI_CRM_CN_Contract_Purchase_Value__c = line.ASI_CRM_CN_Contract_Total_Dummy__c;
                TempLine.ASI_CRM_CN_Estimate_Purchase_Value__c = line.ASI_CRM_CN_Est_Total_Dummy__c;
                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
                TempLine.ASI_CRM_CN_Est_Total_Dummy__c = 0;
            }*/

            if(TempLine.ASI_CRM_Sub_Brand_Grade__c==null && SubBrandGradeMapping.containsKey(TempLine.ASI_CRM_CN_Sub_Brand__c)){
                    TempLine.ASI_CRM_Sub_Brand_Grade__c= SubBrandGradeMapping.get(TempLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__c!=null?SubBrandGradeMapping.get(TempLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__c:null;
                }

                if(TempLine.ASI_CRM_Sub_Brand_Grade__c!=null && SubBrandGradeNameMap.containsKey(TempLine.ASI_CRM_Sub_Brand_Grade__c)){
                    TempLine.ASI_CRM_Line_Name__c= SubBrandGradeNameMap.get(TempLine.ASI_CRM_Sub_Brand_Grade__c).ASI_CRM_Chinese_Name__c !=null?SubBrandGradeNameMap.get(TempLine.ASI_CRM_Sub_Brand_Grade__c).ASI_CRM_Chinese_Name__c:SubBrandGradeNameMap.get(TempLine.ASI_CRM_Sub_Brand_Grade__c).Name;

                    String SubBrandGradeName= SubBrandGradeNameMap.get(TempLine.ASI_CRM_Sub_Brand_Grade__c).Name;
                    String CityTierExternalKey = SubBrandGradeName+ExternalKey;
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c!=null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
                        CityTierExternalKey+= ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
                    }


                }

                //If not v0.0 version, all contract Base amount is 0
                if(ContractSelected.ASI_CRM_CN_PO_Version__c !='0.0'){  TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                }
                ContractLines.add(TempLine);




        }

        return ContractLines;
        
    }
    
    public ASI_CRM_CN_Contract_BRSF_Line_Item__c ByTotalAmountGenerating(String LineType){
        Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        ASI_CRM_CN_Contract_BRSF_Line_Item__c InsertedLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=PageId, ASI_CRM_Type__c=LineType, RecordTypeId=BRSFLineRtId,
            ASI_CRM_Contract_Total_QTY_CR12_Eqv__c=0,ASI_CRM_Contract_Monthly_Volume_CR12__c=0,
            ASI_CRM_Est_Total_QTY_CR12_Eqv__c=0,ASI_CRM_Est_Monthly_Volume_CR12__c=0,
            ASI_CRM_Contract_Total_QTY_std_Btl__c=0,ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0,
            ASI_CRM_Est_Total_QTY_std_Btl__c=0,ASI_CRM_Max_Incentive__c=0,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0,
            ASI_CRM_CN_Contract_Monthly_Qty__c=0.0,ASI_CRM_CN_Est_Monthly_Qty__c=0.0,ASI_CRM_Volume_Base__c='By Total',
                ASI_CRM_CN_Activity_Code__c = LineType == 'PSF' ? PSFActivityCodeId : (DisplayActivityCodeId != null && DisplayActivityCodeId != '' ? DisplayActivityCodeId : null),
            ASI_CRM_CN_Contract_Purchase_Value__c = 0,
            ASI_CRM_CN_Estimate_Purchase_Value__c = 0

        );
        
        
        /*Set<String> SubBrandIdSet = new Set<String> ();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSFItemMap.DetailLineMap.values()){
            if(line.ASI_CRM_CN_Sub_Brand__c !=null){
                SubBrandIdSet.add(line.ASI_CRM_CN_Sub_Brand__c);
            }
        }
        //Getting CR12 Factor Map
        Map<String,Decimal> CR12FactorMap=GenerateCR12FactorMap(SubBrandIdSet);




        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line:BRSFItemMap.DetailLineMap.values()){
            Decimal CR12Factor = CR12FactorMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)? CR12FactorMap.get(line.ASI_CRM_CN_Sub_Brand__c) : 1;


            // Monthly
            InsertedLine.ASI_CRM_CN_Est_Monthly_Qty__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Est_Monthly_Qty__c;
            InsertedLine.ASI_CRM_Est_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Est_Monthly_Qty__c*CR12Factor;


            if (line.ASI_CRM_Est_Total_QTY_std_Btl__c != null) {
                InsertedLine.ASI_CRM_Est_Total_QTY_std_Btl__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c;
                InsertedLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c*CR12Factor;
            } else {
                InsertedLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c+= (line.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Est_Monthly_Qty__c*CR12Factor*ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;

                InsertedLine.ASI_CRM_Est_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Est_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_V00_No_of_Month__c;
            }


            InsertedLine.ASI_CRM_CN_Contract_Purchase_Value__c += (line.ASI_CRM_CN_Contract_Total_Dummy__c == null) ? 0 : line.ASI_CRM_CN_Contract_Total_Dummy__c;
            InsertedLine.ASI_CRM_CN_Estimate_Purchase_Value__c += (line.ASI_CRM_CN_Est_Total_Dummy__c == null) ? 0 : line.ASI_CRM_CN_Est_Total_Dummy__c;


            if(ContractSelected.ASI_CRM_CN_PO_Version__c =='0.0'){
                InsertedLine.ASI_CRM_CN_Contract_Monthly_Qty__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Contract_Monthly_Qty__c;
                InsertedLine.ASI_CRM_Contract_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Contract_Monthly_Qty__c*CR12Factor;
                InsertedLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Contract_Monthly_Qty__c*CR12Factor*ContractSelected.ASI_CRM_CN_No_of_Months__c;
                InsertedLine.ASI_CRM_Contract_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:line.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c;
            }else{
                InsertedLine.ASI_CRM_CN_Contract_Monthly_Qty__c=0;
                InsertedLine.ASI_CRM_Contract_Monthly_Volume_CR12__c=0;
                InsertedLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c=0;
                InsertedLine.ASI_CRM_Contract_Total_QTY_std_Btl__c=0;
                InsertedLine.ASI_CRM_CN_Contract_Purchase_Value__c=0;
                InsertedLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
            }
        }*/
        return InsertedLine;

    }
    
    //******************************** Covered Outlet Line Item ***********************
    public void AddNew_CoveredOutlet(){
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        CoveredOutlet_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), outlet );
        outlet.ASI_CRM_CN_Contract__c = ContractSelected.Id;
        outlet.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet');
        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
    }
    
    public Integer getNumberOfCoveredOutlets(){
        return CoveredOutlet_Item_Map.size();
    }
    
    //*********************************************************
    //@description: Add All Child Outlets  in one time
    // *********************************************************
    public void AddAllChildOutlets() {
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        Set<Id> outletIds = new Set<Id>();

        String recordType = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName;

        if (recordType != 'ASI_CRM_Outlet_CN') { return;
        }

        for (ASI_CRM_CN_Covered_Outlet__c s : CoveredOutlet_Item_Map.values()) { outletIds.add(s.ASI_CRM_CN_Outlet__c);
        }


        for (ASI_CRM_AccountsAdditionalField__c customer : [
            SELECT  Id,
                    ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
                    ASI_CRM_CN_Area_Name__c,
                    ASI_CRM_CN_CCity__c,
                    ASI_CRM_CN_City_Name__c,
                    ASI_CRM_CN_NewChannel__c
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
                    ASI_CRM_CN_Outlet__r = customer,
                    ASI_CRM_CN_Selected_Covered_Outlet__c = true
            );


            CoveredOutlet_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX + newCounterCreatorLine(), outlet);
        }
    }
    
    //******************************** Covered WS Line Item ***********************
    public void AddNew_CoveredWS(){
        ASI_CRM_CN_Covered_Outlet__c WS = new ASI_CRM_CN_Covered_Outlet__c();
        CoveredWS_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), WS );
        WS.ASI_CRM_CN_Contract__c = ContractSelected.Id;
        WS.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet');
        WS.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
    }
    
    public Integer getNumberOfCoveredWS(){
        return CoveredWS_Item_Map.size();
    }

    //ReCal PSF Monthly module if the PO start/end date is changed
    public void refreshMonthModule(){
        for(String ModuleKey : PSF_Item_Map.keyset()){
            if(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Methodology__r.Name == 'Rebate%(By Month)' || test.isRunningTest()){
                System.debug('refreshMonthModule');
                Map<String, List<Date>> DateMap = new Map<String, List<Date>>();
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line : PSF_Item_Map.get(ModuleKey).DetailLineMap.values()) {
                    if(line.ASI_CRM_CN_Date__c < this.ContractSelected.ASI_CRM_CN_PO_Start_Date__c || line.ASI_CRM_CN_Date__c > this.ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                        BRSFDeleteList.add(line);
                    }
                }

                List <ASI_CRM_CN_Contract_BRSF_Line_Item__c> linesToInsert = new List <ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

                for(date d=this.ContractSelected.ASI_CRM_CN_PO_Start_Date__c ; d <= this.ContractSelected.ASI_CRM_CN_PO_End_Date__c; d=d.addMonths(1)){

                    if(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        for(string key : PSF_Item_Map.get(ModuleKey).PSFMultiTableMap.keySet()){
                            System.debug('PSFMultiTableMap key:'+key);
                            Boolean AddnewLine = true;
                            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line : PSF_Item_Map.get(ModuleKey).DetailLineMap.values()) {
                                if(line.ASI_CRM_CN_Sub_Brand__c == key && line.ASI_CRM_CN_Date__c == d){
                                    AddnewLine = false;
                                }
                            }
                            System.debug(d +':'+ AddnewLine);
                            if(AddnewLine){
                                ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                                TempLine.ASI_CRM_Type__c='PSF';
                                TempLine.ASI_CRM_Volume_Base__c= 'By Sub-Brand' ;
                                TempLine.ASI_CRM_Max_Incentive__c=9999999;
                                TempLine.ASI_CRM_CN_Date__c = d;
                                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                                TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
                                TempLine.ASI_CRM_CN_Contract__c=PageId;
                                TempLine.ASI_CRM_CN_Activity_Code__c= PSFActivityCodeId;
                                TempLine.ASI_CRM_Module__c=PSF_Item_Map.get(ModuleKey).Module.Id;
                                TempLine.ASI_CRM_CN_Sub_Brand__c=key;
                                TempLine.RecordTypeId = BRSFLineRecordTypeId;
                                linesToInsert.add(TempLine);
                            }
                        }
                    }else if(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Volume_Base__c=='By Brand Group'){
                        for(string key : PSF_Item_Map.get(ModuleKey).PSFMultiTableMap.keySet()){
                            System.debug('PSFMultiTableMap key:'+key);
                            Boolean AddnewLine = true;
                            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line : PSF_Item_Map.get(ModuleKey).DetailLineMap.values()) {
                                if(line.ASI_CRM_CN_Sub_Brand_Package__c == key && line.ASI_CRM_CN_Date__c == d){
                                    AddnewLine = false;
                                }
                            }
                            System.debug(d +':'+ AddnewLine);
                            if(AddnewLine){
                                ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                                TempLine.ASI_CRM_Type__c='PSF';
                                TempLine.ASI_CRM_Volume_Base__c= 'By Brand Group' ;
                                TempLine.ASI_CRM_Max_Incentive__c=9999999;
                                TempLine.ASI_CRM_CN_Date__c = d;
                                TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                                TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
                                TempLine.ASI_CRM_CN_Contract__c=PageId;
                                TempLine.ASI_CRM_CN_Activity_Code__c= PSFActivityCodeId;
                                TempLine.ASI_CRM_Module__c=PSF_Item_Map.get(ModuleKey).Module.Id;
                                TempLine.ASI_CRM_CN_Sub_Brand_Package__c=key;
                                TempLine.RecordTypeId = BRSFLineRecordTypeId;
                                linesToInsert.add(TempLine);
                            }
                        }
                    }else if(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Volume_Base__c=='By Total'){
                        Boolean AddnewLine = true;
                        //Check the Monthly Line
                        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c line : PSF_Item_Map.get(ModuleKey).DetailLineMap.values()) {
                            if(line.ASI_CRM_CN_Date__c == d){
                                AddnewLine = false;
                            }
                        }
                        System.debug(d +':'+ AddnewLine);
                        if(AddnewLine){
                            ASI_CRM_CN_Contract_BRSF_Line_Item__c TempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                            TempLine.ASI_CRM_Type__c='PSF';
                            TempLine.ASI_CRM_Volume_Base__c= 'By Total' ;
                            TempLine.ASI_CRM_Max_Incentive__c=9999999;
                            TempLine.ASI_CRM_CN_Date__c = d;
                            TempLine.ASI_CRM_CN_Contract_Total_Dummy__c=0;
                            TempLine.ASI_CRM_CN_Est_Total_Dummy__c=0;
                            TempLine.ASI_CRM_CN_Contract__c=PageId;
                            TempLine.ASI_CRM_CN_Activity_Code__c= PSFActivityCodeId;
                            TempLine.ASI_CRM_Module__c=PSF_Item_Map.get(ModuleKey).Module.Id;
                            TempLine.RecordTypeId = BRSFLineRecordTypeId;
                            linesToInsert.add(TempLine);
                        }
                    }

                }
                System.debug(linesToInsert);
                Database.DeleteResult[] DeleteTarget;
                if(BRSFDeleteList.size()>0){
                    DeleteTarget = Database.delete(BRSFDeleteList);
                    BRSFDeleteList.clear();
                }
                if(linesToInsert.size()>0){
                    insert linesToInsert;
                }

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
            ContractSelected.ASI_CRM_CN_V0_Visibility_Contract_Total__c = 0;
            ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c = 0;
            ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c = 0;
        }

        //Looping BRSF
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : BRSF_Item_Map.DetailLineMap.values()) {
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

        //Visibility
        Decimal VisibilityEstimateTotal = 0;
        VisibilityEstimateTotal = VisibilityLine.ASI_CRM_CN_Est_Total_Dummy__c != null? VisibilityLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

        if (isPOModi) {
            ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c = PSFEstimateTotal;
            ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c / (ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c == null || ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c == 0 ? 1 : ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c) *100;
            ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c = DisplayEstimateTotal;
            ContractSelected.ASI_CRM_Display_Estimate_Adjustment_Amt__c = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c / (ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c == null || ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c== 0 ? 1 : ContractSelected.ASI_CRM_Prev_Version_Display_Est_Total__c) *100;
            ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c = VisibilityEstimateTotal;
            ContractSelected.ASI_CRM_Visibility_Est_Adjust_percent__c = ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c == null || ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c == 0 ? 100 : ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c / ContractSelected.ASI_CRM_Prev_Ver_Visibility_Est_Total__c *100;
        } else {
            ContractSelected.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = DisplayEstimateTotal;
            ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c = DisplayEstimateTotal;
            ContractSelected.ASI_CRM_CN_V0_Visibility_Contract_Total__c = VisibilityEstimateTotal;
            ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c = VisibilityEstimateTotal;
        }
    }

    //Change to header edit mode
    public PageReference GoEditHeader(){
                              
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageref.getParameters().put('IsHeaderEdit','1');
        pageRef.setRedirect(true);
        return pageRef;

    }
    
    //Change to detail edit mode
    public PageReference GoEditDetail(){
                              
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageref.getParameters().put('IsDetailEdit','1');
        pageRef.setRedirect(true);
        return pageRef;

    }
    
    //Change to view mode
    public PageReference GoView(){
                              
        //PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_PromotionContractPage?id='+PageId);
        pageref.getParameters().put('IsView','1');
        //pageref.getParameters().put('IsDetailEdit','0');
        pageRef.setRedirect(true);
        return pageRef;

    }
    
    public PageReference GoCheckPointPage(){
        PageReference redirectPage = new PageReference('/apex/ASI_CRM_CN_PromotionCheckPointResultPage?id='+PageId+'&Type=SubmitApproval');
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    public PageReference ViewCheckPointPage(){
        PageReference redirectPage = new PageReference('/apex/ASI_CRM_CN_PromotionCheckPointResultPage?id='+PageId+'&Type=ViewCheckPoint');
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    public PageReference GoCoveredUploadPage(){
        PageReference redirectPage = new PageReference('/apex/ASI_CRM_CN_CoveredOutletUploadPage?id='+PageId+'&Type=Promotion&OutletType=Covered');
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    public PageReference GoWSUploadPage(){
        PageReference redirectPage = new PageReference('/apex/ASI_CRM_CN_CoveredOutletUploadPage?id='+PageId+'&Type=Promotion&OutletType=WS');
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    public PageReference redirectToPage(String pagePath, String pid){

        PageReference redirect = new PageReference(pagePath);
        redirect.getParameters().put('id',pid);
        redirect.setRedirect(true);
        return redirect;
    }

    //***************Restore PO******************************************************************
    public PageReference restorePO(){
        PageReference p;
        String returnId = ContractSelected.Id;
        List<ASI_TH_CRM_Contract__c> cContract = [SELECT Id, ASI_CRM_CN_Status__c, LastModifiedDate FROM ASI_TH_CRM_Contract__c WHERE Id=:ContractSelected.Id LIMIT 1];
        if (cContract[0].ASI_CRM_CN_Status__c == 'Draft' && cContract[0].LastModifiedDate == ContractSelected.LastModifiedDate){
            restore(ContractSelected);
            return redirectToPage('/apex/ASI_CRM_CN_PromotionContractPage',returnId);
        } else {
            if(UserInfo.getLanguage()=='zh_CN')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contract has been modified since last update, Please refresh and restore again!'));
            else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'请刷新网页，更新PO资料，再恢复以前的版本。'));

        }

        return null;
    }

    private void restore(ASI_TH_CRM_Contract__c cont){

        List<ASI_TH_CRM_Contract__c> LLastContract = [SELECT Id,
                                                             Name,
                                                             ASI_CRM_EVC_Cost_Estimate_Total__c,
                                                             ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
                                                             ASI_CRM_Martell_BC_Rate__c,
                                                             ASI_CRM_Auto_PO_Modification__c,
                                                             ASI_CRM_Auto_PO_Modification_Time__c,
                                                             ASI_CRM_V0_PSF_Contract_Total__c,
                                                             ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                                                             ASI_CRM_Previous_Version_PSF_Est_Total__c,
                                                             ASI_CRM_CN_Expected_PSF_Est_Total__c,
                                                             ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                                                             ASI_CRM_Copied_From__c,
                                                             ASI_CRM_CN_Total_Contract_Amount__c,
                                                             ASI_CRM_CN_Vol_Budget_LE__c,
                                                             ASI_CRM_CN_Status__c,
                                                             ASI_CRM_CN_Source_of_Contract__c,
                                                             ASI_CRM_CN_Source_Others__c,
                                                             ASI_CRM_CN_Reason_without_Budget__c,
                                                             ASI_TH_CRM_Promotion_Type__c,
                                                             ASI_CRM_CN_PP_No__c,
                                                             ASI_CRM_CN_PO_Version__c,
                                                             ASI_CRM_CN_PO_Start_Date__c,
                                                             ASI_CRM_CN_PO_No__c,
                                                             ASI_CRM_CN_PO_End_Date__c,
                                                             ASI_CRM_CN_Outlet_WS__c,
                                                             ASI_CRM_CN_Exchange_Rate__c,
                                                             ASI_CRM_CN_IsClone__c,
                                                             ASI_CRM_CN_Description__c,
                                                             ASI_CRM_CN_Currency__c,
                                                             ASI_CRM_CN_Budget_LE__c,
                                                             ASI_CRM_CN_Bottle_Collection_Rate__c,
                                                             ASI_CRM_CN_Effective_Date__c,
                                                             RecordTypeId,
                                                             ASI_CRM_CN_PO_Modification__c,
                                                             ASI_CRM_CN_Contract_Upload__c,
                                                             ASI_CRM_CN_Business_License__c,
                                                             ASI_CRM_CN_Last_PO_version__c,
                                                             ASI_TH_CRM_End_Date__c,
                                                             ASI_TH_CRM_Start_Date__c,
                                                             ASI_CRM_CN_Return_Comments__c,
                                                             ASI_CRM_Reject_Return_Comments__c,
                                                             ASI_CRM_CN_Last_Approved_By__c,
                                                             ASI_CRM_CN_Last_Approved_Date__c,
                                                             ASI_CRM_CN_Last_Recall_By__c,
                                                             ASI_CRM_CN_Last_Recall_Date__c,
                                                             ASI_CRM_CN_Last_Rejected_By__c,
                                                             ASI_CRM_CN_Last_Rejected_Date__c,
                                                             ASI_CRM_CN_Last_Submitted_By__c,
                                                             ASI_CRM_CN_Last_Submitted_Date__c,
                                                             ASI_CRM_National_Group__c,
                                                             ASI_CRM_CN_National_Group_Contract__c,
                                                             ASI_CRM_NationalGroup__c,
                                                             ASI_CRM_CN_Festival_Season__c,
                                                             ASI_CRM_CN_Data_Source__c,
                                                             ASI_CRM_CN_V0_Visibility_Contract_Total__c,
                                                             ASI_CRM_Prev_Ver_Visibility_Est_Total__c,
                                                             ASI_CRM_Visibility_Est_Adjust_percent__c,
                                                             ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                                                             ASI_CRM_CN_Is_Group_Contract__c
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
            cont.ASI_CRM_CN_Festival_Season__c = LLastContract[0].ASI_CRM_CN_Festival_Season__c;
            cont.ASI_CRM_CN_Data_Source__c = LLastContract[0].ASI_CRM_CN_Data_Source__c;
            cont.ASI_CRM_CN_V0_Visibility_Contract_Total__c = LLastContract[0].ASI_CRM_CN_V0_Visibility_Contract_Total__c;
            cont.ASI_CRM_Prev_Ver_Visibility_Est_Total__c = LLastContract[0].ASI_CRM_Prev_Ver_Visibility_Est_Total__c;
            cont.ASI_CRM_Visibility_Est_Adjust_percent__c = LLastContract[0].ASI_CRM_Visibility_Est_Adjust_percent__c;
            cont.ASI_CRM_CN_Expected_Visibility_Est_Total__c = LLastContract[0].ASI_CRM_CN_Expected_Visibility_Est_Total__c;
            cont.ASI_CRM_CN_Is_Group_Contract__c = LLastContract[0].ASI_CRM_CN_Is_Group_Contract__c;
            cont.ASI_CRM_CN_IsClone__c = false;
            update cont;
        }
        if(cont.ASI_CRM_CN_Status__c== 'Final'){
            //update cont;
            //---- original child objects ----
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = [SELECT Id FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :cont.Id];
            if(LBRSF != null && LBRSF.size()>0) delete LBRSF;
            List<ASI_CRM_Module__c> LModule = [SELECT Id FROM ASI_CRM_Module__c WHERE ASI_CRM_Contract__c = :cont.Id];
            if(LModule != null && LModule.size()>0)  delete LModule;
            List<ASI_CRM_Contract_Cost__c> LContractCost = [SELECT Id FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :cont.Id];
            if(LContractCost.size()>0) delete LContractCost;
            List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet = [SELECT Id FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :cont.Id];
            if(LCoveredOutlet.size()>0) delete LCoveredOutlet;

            List<ASI_CRM_Approval_Comment__c> LComment = [SELECT Id FROM ASI_CRM_Approval_Comment__c WHERE ASI_CRM_Contract__c = :cont.Id];
            if(LCoveredOutlet.size()>0)  delete LComment;
            // Change lookup for archived child record
            LBRSF = [SELECT Id, ASI_CRM_CN_Contract__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :LLastContract[0].Id];
            if(LBRSF.size()>0){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c itm : LBRSF){
                    itm.ASI_CRM_CN_Contract__c = cont.Id;
                }
                update LBRSF;
            }
            LModule = [SELECT Id, ASI_CRM_Contract__c from ASI_CRM_Module__c where ASI_CRM_Contract__c = :LLastContract[0].Id];
            if(LModule.size()>0){
                for(ASI_CRM_Module__c itm : LModule){
                    itm.ASI_CRM_Contract__c = cont.Id;
                }
                update LModule;
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
    
     
    //*********************************Save the Contract Header/PO Modification **************************************
    public PageReference saveHeader(){
        PageReference pageRef = null;
        UpsertPermission=true;
        Msg='';
        if(!HeaderValidationChecking()){
            UpsertPermission=false;
        }
         if(UpsertPermission){
            System.Savepoint pSavepoint = Database.setSavepoint();

            //try{
                if(IsPOModiPage || test.isRunningTest()){
                    Date TempStartDate=ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
                    Date TempEndDate=ContractSelected.ASI_CRM_CN_PO_End_Date__c;
                    ContractSelected.ASI_CRM_CN_PO_Start_Date__c=ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
                    ContractSelected.ASI_CRM_CN_PO_End_Date__c=ContractSelected.ASI_CRM_CN_PO_End_Date__c;
                    System.debug('POModi 1');
                    ASI_TH_CRM_Contract__c ContractCloned  = ASI_CRM_CN_PromotionContractUtilClass.ArchivePO(ContractSelected);
                    System.debug('POModi 2');
                    System.debug(ContractCloned);
                    System.debug(' ContractCloned ' + ContractCloned.ASI_CRM_CN_Expected_V0_Display_Est_Total__c);
                    System.debug(' ContractCloned ' + ContractCloned.ASI_CRM_CN_V0_Display_Contract_Total__c);
                    System.debug(' ContractCloned ' + ContractCloned.ASI_CRM_CN_Total_RContract_Amount__c);
                    ContractSelected.ASI_CRM_CN_Last_PO_version__c=ContractCloned.Id;
                    ContractSelected.ASI_CRM_CN_PO_Start_Date__c=TempStartDate;
                    ContractSelected.ASI_CRM_CN_PO_End_Date__c=TempEndDate;

                    ContractSelected.ASI_CRM_CN_Last_PO_version__c=ContractCloned.Id;

                    ContractSelected.ASI_CRM_CN_Status__c = 'Draft';
                    ContractSelected.ASI_TH_CRM_Start_Date__c = null;
                    ContractSelected.ASI_TH_CRM_End_Date__c = null;
                    ContractSelected.ASI_CRM_Reject_Return_Comments__c = '';
                    ContractSelected.ASI_CRM_CN_Return_Comments__c = '';
                    ContractSelected.ASI_CRM_CN_Last_Approved_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Approved_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Recall_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Recall_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Rejected_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Rejected_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Submitted_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Submitted_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Contract_Upload__c=true;
                    ContractSelected.ASI_CRM_Auto_PO_Modification_Time__c=null;
                    ContractSelected.ASI_CRM_Auto_PO_Modification__c=false;

                    ContractSelected.ASI_CRM_CN_PO_Modification__c = true;
                    if(ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0'){
                        ContractSelected.ASI_CRM_CN_V0_0_PO_version__c=ContractCloned.Id;
                    }
                    System.debug(ContractSelected.ASI_CRM_CN_PO_Version__c);
                    List<String> poVersionSplit = ContractSelected.ASI_CRM_CN_PO_Version__c.split('\\.',0);
                    if(poVersionSplit != null && poVersionSplit.size() ==2){
                        ContractSelected.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1])+1);
                    }                  
                    ContractSelected.ASI_CRM_Copied_From__c=ContractCloned.Id; // Previous Contract

                    //calculate PSF Adjustment and Grand Total and Display
                    calculateAdjustment(ContractSelected);

                    //Refresh and save Monthly Module if the PO Period is changed
                    if(ContractStartDate != ContractSelected.ASI_CRM_CN_PO_Start_Date__c || ContractEndDate != ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                        refreshMonthModule();
                    }

                    if(!Test.isRunningTest()) update ContractSelected;
                }else{

                    //Refresh and save Monthly Module if the PO Period is changed
                    if(ContractStartDate != ContractSelected.ASI_CRM_CN_PO_Start_Date__c || ContractEndDate != ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                        refreshMonthModule();
                    }

                    update ContractSelected;
                }
                pageRef = new PageReference('/apex/ASI_CRM_CN_PromotionContractPage');
                pageref.getParameters().put('id',PageId);
                pageRef.setRedirect(true);

                //pageRef = new PageReference('/'+PageId);


//            } catch(Exception e){
//                Msg += ASI_CRM_CN_HeavyContracFunctionClass.ErrorMsgTransform(e.getMessage()) + '</br>';
//                UpsertPermission=false;
//                Database.rollback(pSavepoint);
//            }

        }

        if(Msg != '') {
            ErrorHandling(Msg);
        }

        return pageRef;
    }
    
    //PO Modification
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
        
            PageReference redirect =  new PageReference(ApexPages.currentPage().getUrl());
            redirect.getParameters().put('IsPOModiPage','1');
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
    
    public void ErrorHandling(String ErrorMsg){
        Msg += ErrorMsg + '<br/> ';
        //msg='Error,Can not Save!';
        UpsertPermission = false;
    }
        
    
    //Create interimData For Module
    public interimData createInterimData(ASI_CRM_Module__c module) {
        interimData d = new interimData(module, false);

        if (module.ASI_CRM_Line_Type__c == 'PSF') {
            d.MethodologyPicklist = genMethodologyPicklist(module.ASI_CRM_CN_KPI_Base__c,module.ASI_CRM_Line_Type__c);
            if(d.MethodologyPicklist.size() >0) {
                d.VolumeValueBasePickList = genPSFVolValBasePicklist(d.MethodologyPicklist[0].getValue());
                d.Module.ASI_CRM_Unit__c = calculatePSFUnit(d.MethodologyPicklist[0].getValue());

                d.module.ASI_CRM_Volume_Base__c = d.VolumeValueBasePickList[0].getValue();
                d.module.ASI_CRM_Methodology__c = d.MethodologyPicklist[0].getValue();
                d.module.ASI_CRM_Methodology__r = MethodologyById.get(d.MethodologyPicklist[0].getValue());
                d.module.ASI_CRM_CN_KPI_Base__c = MethodologyById.get(d.MethodologyPicklist[0].getValue()).ASI_CRM_CN_KPI_Base__c;
            }else{
                return null;
            }
          
        }
        else if (module.ASI_CRM_Line_Type__c == 'Display') {
                d.MethodologyPicklist = genMethodologyPicklist(module.ASI_CRM_CN_KPI_Base__c, module.ASI_CRM_Line_Type__c);
            if(d.MethodologyPicklist.size() >0) {
                d.VolumeValueBasePickList = genPSFVolValBasePicklist(d.MethodologyPicklist[0].getValue());
                d.Module.ASI_CRM_Unit__c = calculatePSFUnit(d.MethodologyPicklist[0].getValue());

                d.module.ASI_CRM_Volume_Base__c = d.VolumeValueBasePickList[0].getValue();
                d.module.ASI_CRM_Methodology__c = d.MethodologyPicklist[0].getValue();
                d.module.ASI_CRM_Methodology__r = MethodologyById.get(d.MethodologyPicklist[0].getValue());
                d.module.ASI_CRM_CN_KPI_Base__c = MethodologyById.get(d.MethodologyPicklist[0].getValue()).ASI_CRM_CN_KPI_Base__c;
            }else{
                return null;
            }
        }
        
         
 

        d.updateMethodologyDisplay(showCN);
        d.showLineItems = false;
        return d;
    }
       
    public void updatePSFItemMapDTO(){
        for (String key : PSF_Item_Map.keySet()) {  
           System.debug(PSF_Item_Map.get(key));
           PSF_Item_MapDto.put(key, new interimDataDto(PSF_Item_Map.get(key)));
        }
        //PSF_Item_MapJSON = JSON.serialize(PSF_Item_Map);
        PSF_Item_MapJSON = JSON.serialize(PSF_Item_MapDto);
    }
    
    public void updateDisplayListingItemMapDTO(){
        for (String key : DisplayListingItemMap.keySet()) { 
           DisplayListingItemMapDto.put(key, new interimDataDto(DisplayListingItemMap.get(key)));
        }
        DisplayListing_Item_MapJSON = JSON.serialize(DisplayListingItemMapDto);
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
    
    private void SettingDefaultValue(){
        msg = '';
        UpsertPermission = true;
    }
    
    
    /**
     * Get all methodologies from Master file with specific KPIBase and type
     *
     * @param KPIBase
     * @param type
     *
     * @return
     */
    public List<SelectOption> genMethodologyPicklist(String KPIBase, String type){
        
        List<SelectOption> methodologyPicklist = new List<SelectOption>();
        String methodologyLabel;
        String MethodologyType;
        if(type =='PSF'){
            MethodologyType ='Price Promotion';
        }else{
            MethodologyType ='Free Goods/GWP';
        }
        
        for(ASI_CRM_Methodology__c method:[select id, 
                                                Name, 
                                                ASI_CRM_Chinese_Name__c, 
                                                ASI_CRM_CN_Criteria__c,
                                                ASI_CRM_CN_KPI_Base__c,                                             
                                                (select id,
                                                        ASI_CRM_CN_PO_Type__c,
                                                        ASI_CRM_CN_New_Channel__c,
                                                        ASI_CRM_Region__c
                                                        from ASI_CRM_Methodology_Assignment__r
                                                        where ASI_CRM_CN_PO_Type__c = :ContractSelected.ASI_TH_CRM_Promotion_Type__c
                                                        and ASI_CRM_Region__r.Name = :ContractSelected.ASI_CRM_CN_Region__c
                                                        //and ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c
                                                        and (ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c or ASI_CRM_CN_New_Channel__c = null)
                                                        )
                                                from ASI_CRM_Methodology__c
                                                where ASI_CRM_Type__c =:MethodologyType ORDER BY ASI_CRM_Sequence__c ASC
                                        ])
        {
                                            
            if (method.ASI_CRM_Methodology_Assignment__r.size() >0) {
                methodologyLabel = showCN? method.ASI_CRM_Chinese_Name__c : method.Name;
                methodologyPicklist.add(new SelectOption(method.Id, methodologyLabel));
            }                                   
                                                                                        
        }
                
        return methodologyPicklist;
    }

    /*
        Update :Bowen
        Date: 2019-12-25
        Reason:因为之前的code，在for循环中调用方法，一旦BRSF line item过多，就会出现查询超101的限制，因此需修改
     */
    public Map<String ,List<SelectOption>> genMethodologyPicklist(){

        Map<String ,List<SelectOption>> MethodMap = new Map<String ,List<SelectOption>>();

        
        // 
        // String MethodologyType;
        // if(type =='PSF'){
        //     MethodologyType ='Price Promotion';
        // }else{
        //     MethodologyType ='Free Goods/GWP';
        // }
        
        for(ASI_CRM_Methodology__c method:[select id, 
                                                Name, 
                                                ASI_CRM_Chinese_Name__c, 
                                                ASI_CRM_CN_Criteria__c,
                                                ASI_CRM_CN_KPI_Base__c,  
                                                ASI_CRM_Type__c ,                                           
                                                (select id,
                                                        ASI_CRM_CN_PO_Type__c,
                                                        ASI_CRM_CN_New_Channel__c,
                                                        ASI_CRM_Region__c
                                                        from ASI_CRM_Methodology_Assignment__r
                                                        where ASI_CRM_CN_PO_Type__c = :ContractSelected.ASI_TH_CRM_Promotion_Type__c
                                                        and ASI_CRM_Region__r.Name = :ContractSelected.ASI_CRM_CN_Region__c
                                                        //and ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c
                                                        and (ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c or ASI_CRM_CN_New_Channel__c = null)
                                                        )
                                                from ASI_CRM_Methodology__c
                                                where ASI_CRM_Type__c =: 'Free Goods/GWP' or ASI_CRM_Type__c =: 'Price Promotion' ORDER BY ASI_CRM_Sequence__c ASC
                                        ])
        {
                                            
            if (method.ASI_CRM_Methodology_Assignment__r.size() >0) {
                if (MethodMap.containsKey(method.ASI_CRM_Type__c)) {
                    List<SelectOption> methodologyPicklist = MethodMap.get(method.ASI_CRM_Type__c);
                    String methodologyLabel = showCN? method.ASI_CRM_Chinese_Name__c : method.Name;
                    methodologyPicklist.add(new SelectOption(method.Id, methodologyLabel));

                    MethodMap.put(method.ASI_CRM_Type__c, methodologyPicklist);
                }
                else
                {
                    List<SelectOption> methodologyPicklist = new List<SelectOption>();
                    String methodologyLabel = showCN? method.ASI_CRM_Chinese_Name__c : method.Name;
                    methodologyPicklist.add(new SelectOption(method.Id, methodologyLabel));

                    MethodMap.put(method.ASI_CRM_Type__c, methodologyPicklist);
                }
                
            }                                   
                                                                                        
        }
                
        return MethodMap;
    }

    /*
        Update :Bowen
        Date: 2019-12-25
        Reason:因为之前的code，在for循环中调用方法，一旦BRSF line item过多，就会出现查询超101的限制，因此需修改
     */
    public Map<String ,List<SelectOption>> genPSFVolValBasePicklist(){

        Map<String ,List<SelectOption>> pickMap = new Map<String ,List<SelectOption>>();
        
        //String methodology = MethodologyById.get(methodologyId).Name;
        Map<String, SelectOption> allOptions = getPickListValueMap(ASI_CRM_Module__c.ASI_CRM_Volume_Base__c.getDescribe());
        //Map<String, SelectOption> allOptions = getPickListValueMap(ASI_CRM_Methodology_Assignment__c.ASI_CRM_CN_Volume_Value_Base__c.getDescribe());              
        List<ASI_CRM_Methodology_Assignment__c> metAsgList =    [select id,
                                                               ASI_CRM_CN_Volume_Value_Base__c ,
                                                               ASI_CRM_Methodology__c
                                                        from ASI_CRM_Methodology_Assignment__c
                                                        where ASI_CRM_CN_PO_Type__c = :ContractSelected.ASI_TH_CRM_Promotion_Type__c
                                                        and ASI_CRM_Region__r.Name = :ContractSelected.ASI_CRM_CN_Region__c
                                                        //and ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c
                                                        and (ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c or ASI_CRM_CN_New_Channel__c = null)
                                                        limit 1];
        
        if(metAsgList.size() > 0)
        {
            for(ASI_CRM_Methodology_Assignment__c met : metAsgList)
            {
                
                if(pickMap.containsKey(met.ASI_CRM_Methodology__c))
                {
                    List<SelectOption> picklist = pickMap.get(met.ASI_CRM_Methodology__c);
                    List<String> res = met.ASI_CRM_CN_Volume_Value_Base__c.split(';'); 
                    for (integer i = 0; i < res.size(); i++) {
                        picklist.add(allOptions.get(res.get(i)));
                    } 
                    pickMap.put(met.ASI_CRM_Methodology__c, picklist);
                }
                else
                {
                    List<SelectOption> picklist = new List<SelectOption>();
                    List<String> res = met.ASI_CRM_CN_Volume_Value_Base__c.split(';'); 
                    for (integer i = 0; i < res.size(); i++) {
                        picklist.add(allOptions.get(res.get(i)));
                    } 
                    pickMap.put(met.ASI_CRM_Methodology__c, picklist);
                }
                
            }
            
        }                                           
        System.debug(ContractSelected.ASI_TH_CRM_Promotion_Type__c);
        System.debug(ContractSelected.ASI_CRM_CN_Region__c);
        System.debug(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c);
        
        
        
        
                
        return pickMap;
    }
    
    public List<SelectOption> genPSFVolValBasePicklist(String methodologyId){
        List<SelectOption> picklist = new List<SelectOption>();
        //String methodology = MethodologyById.get(methodologyId).Name;
        Map<String, SelectOption> allOptions = getPickListValueMap(ASI_CRM_Module__c.ASI_CRM_Volume_Base__c.getDescribe());
        //Map<String, SelectOption> allOptions = getPickListValueMap(ASI_CRM_Methodology_Assignment__c.ASI_CRM_CN_Volume_Value_Base__c.getDescribe());              
        List<ASI_CRM_Methodology_Assignment__c> metAsgList =    [select id,
                                                               ASI_CRM_CN_Volume_Value_Base__c
                                                        from ASI_CRM_Methodology_Assignment__c
                                                        where ASI_CRM_Methodology__c = :methodologyId
                                                        and ASI_CRM_CN_PO_Type__c = :ContractSelected.ASI_TH_CRM_Promotion_Type__c
                                                        and ASI_CRM_Region__r.Name = :ContractSelected.ASI_CRM_CN_Region__c
                                                        //and ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c
                                                        and (ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c or ASI_CRM_CN_New_Channel__c = null)
                                                        limit 1];
        
        if(metAsgList.size() > 0)
        {
            ASI_CRM_Methodology_Assignment__c Met_asg = metAsgList[0];   
            List<String> res = Met_asg.ASI_CRM_CN_Volume_Value_Base__c.split(';'); 
            for (integer i = 0; i < res.size(); i++) {
                picklist.add(allOptions.get(res.get(i)));
            } 
        }                                           
        System.debug(ContractSelected.ASI_TH_CRM_Promotion_Type__c);
        System.debug(ContractSelected.ASI_CRM_CN_Region__c);
        System.debug(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c);
        
        
        
        
                
        return picklist;
    }
    
    public String calculatePSFUnit(String methodologyId){
        if (String.isEmpty(methodologyId)) {
            return '';
        }

        String methodology = MethodologyById.get(methodologyId).Name;
        String unit;

        if (methodology == 'Per Incentive Btl') {
            unit = 'Std. Btl.';
        }else{
            unit = 'RMB';
        }
        
        return unit;
    }
    
     public void initMethodologyMap() {
        MethodologyById = new Map<Id, ASI_CRM_Methodology__c>(
        [
            SELECT Id,Name,ASI_CRM_CN_KPI_Base__c,ASI_CRM_Sequence__c,ASI_CRM_Type__c,ASI_CRM_Default__c,RecordType.DeveloperName,ASI_CRM_Chinese_Name__c,ASI_CRM_CN_Criteria__c,
            (SELECT Id,ASI_CRM_Region__c,ASI_CRM_Key_Principle__c,ASI_CRM_Region__r.Name,ASI_CRM_CN_New_Channel__c
             FROM ASI_CRM_Methodology_Assignment__r
             WHERE ASI_CRM_Key_Principle__c = TRUE
             AND ASI_CRM_Region__r.Name = :ContractSelected.ASI_CRM_CN_Region__c
             //AND ASI_CRM_CN_New_Channel__c =: ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c)
             AND (ASI_CRM_CN_New_Channel__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c or ASI_CRM_CN_New_Channel__c = null))
            FROM ASI_CRM_Methodology__c
            WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Methodology_Promotion'
        ]
        );
        MethodologyByIdJSON = JSON.serialize(MethodologyById);
    }
    
    /*
        Author:Bowen
        Date:2019-10-18
        Function:获取subbrand对应的excluded item group的packsize
        
     */
    @RemoteAction
    public static String GetPackSizeBySubbrand(String SubBrandId)
    {
        List<String> packSizeList = new List<String>();
        if(SubBrandId != null && SubBrandId != '')
        {
            List<ASI_MFM_Item_Group__c> itemGroupVolumeList = [select Id ,ASI_CRM_CN_BT_Size_C__c  from ASI_MFM_Item_Group__c where ASI_MFM_Sub_brand__c =: SubBrandId];
            if(itemGroupVolumeList.size() > 0)
            {
                for(ASI_MFM_Item_Group__c item : itemGroupVolumeList)
                {

                    if(item.ASI_CRM_CN_BT_Size_C__c != null)
                    {
                        String str = item.ASI_CRM_CN_BT_Size_C__c;
                        String packSize = str;
                        if(str.indexOf('.') != -1)
                        {
                            Integer log = str.indexOf('.');
                            packSize = str.substring(0, log);
                        }
                        if(!packSizeList.contains(packSize))
                        {
                            packSizeList.add(packSize);
                        }
                    }
                }
            }
        }
        system.debug('GetPackSizeBySubbrand ==' + packSizeList.size());
        return JSON.serialize(packSizeList);
    }

    //Retrieve default value
    public void FindingDefaultValue(){
        PSFActivityCodeId='';
        DisplayActivityCodeId='';
        VisibilityActivityCodeId='';

        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList = [SELECT Id, Name,ASI_CRM_PSF_Activity_Code_Default__c,ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_VEC_Activity_Code_Defaul__c , ASI_CRM_CN_Channel__c, ASI_CRM_CN_Other_Cost_Payment_Request__c  FROM ASI_CRM_Contract_Cost_Setting__c WHERE ASI_CRM_CN_Promotion_Type__c in('Outlet Promotion', 'Consumer Promotion', 'Wholesaler Promotion')];
        for(ASI_CRM_Contract_Cost_Setting__c ccs:ContractCostSettingList){
            if (ccs.ASI_CRM_PSF_Activity_Code_Default__c && this.ContractSelected.ASI_TH_CRM_Promotion_Type__c==ccs.ASI_CRM_CN_Promotion_Type__c) {
                PSFActivityCodeId = ccs.ASI_CRM_CN_Activity_Code__c;
            }else if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Outlet Promotion' && this.ContractSelected.ASI_TH_CRM_Promotion_Type__c==ccs.ASI_CRM_CN_Promotion_Type__c && ccs.ASI_CRM_CN_Variable_Cost_Contract__c){
                VisibilityActivityCodeId = ccs.ASI_CRM_CN_Activity_Code__c;
            }else if(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Consumer Promotion' && this.ContractSelected.ASI_TH_CRM_Promotion_Type__c==ccs.ASI_CRM_CN_Promotion_Type__c && ccs.ASI_CRM_CN_Variable_Cost_Contract__c){
                DisplayActivityCodeId = ccs.ASI_CRM_CN_Activity_Code__c;
            }
        }

        String tmType =  this.ContractSelected.ASI_TH_CRM_Promotion_Type__c =='Outlet Promotion' || this.ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Consumer Promotion' ? 'T1 to Outlet' : 'T1 to T2';
        for(ASI_CN_Trade_Margin__c tm :[select ASI_CRM_CN_Default_Margin__c,
                                               ASI_CRM_CN_Max_Margin__c
                                        from ASI_CN_Trade_Margin__c
                                        where RecordType.DeveloperName='ASI_CRM_CN_Trade_Margin_Promotion'
                                        and Type__c = :tmType
                                        and ASI_CRM_CN_Region__c = :this.ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                        and ASI_CRM_Channel__c = :this.ContractSelected.ASI_CRM_PO_Channel__c]){
            defaultMarkUp = tm.ASI_CRM_CN_Default_Margin__c != null  ? tm.ASI_CRM_CN_Default_Margin__c : 0;
            if(tm.ASI_CRM_CN_Max_Margin__c != null) {
                maxMarkUp = tm.ASI_CRM_CN_Max_Margin__c;
            }
        }
    }
    
    public void onPSFMethodologyChange(){
        String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        interimData interimData = PSF_Item_Map.get(itemKey);
        interimData.Module.ASI_CRM_Methodology__r = MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c);
        interimData.VolumeValueBasePickList = genPSFVolValBasePicklist(interimData.Module.ASI_CRM_Methodology__c);
        interimData.Module.ASI_CRM_Unit__c = calculatePSFUnit(interimData.Module.ASI_CRM_Methodology__c);
        interimData.Module.ASI_CRM_CN_Only_for_Strategy_WS__c = false;
        interimData.Module.ASI_CRM_CN_Proportion__c = null;
        interimData.Module.ASI_CRM_CN_KPI_Base__c = MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c).ASI_CRM_CN_KPI_Base__c;
        // Update the map after setting values
        PSF_Item_Map.put(itemKey, interimData);
        
        /*String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        interimData interimData = PSF_Item_Map.get(itemKey);

        interimData.VolumeValueBasePickList = genPSFVolValBasePicklist(interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__c);
        interimData.Module.ASI_CRM_Unit__c = calculatePSFUnit(interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__c);
        interimData.Module.ASI_CRM_CN_Criteria__c = calculateCriteria(interimData.Module.ASI_CRM_CN_KPI_Base__c, interimData.Module.ASI_CRM_Methodology__c);
        // Update the map after setting values
        PSF_Item_Map.put(itemKey, interimData);*/
    }
    
    public void onDisplayMethodologyChange(){
        String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        interimData interimData = DisplayListingItemMap.get(itemKey);
        interimData.Module.ASI_CRM_Methodology__r = MethodologyById.get(interimData.Module.ASI_CRM_Methodology__c);
        interimData.VolumeValueBasePickList = genPSFVolValBasePicklist(interimData.Module.ASI_CRM_Methodology__c);
        // Update the map after setting values
        DisplayListingItemMap.put(itemKey, interimData);    
    }
    
    public void onPSFVolumeBaseChange(){
        /*String itemKey = ApexPages.currentPage().getParameters().get('itemKey');
        interimData interimData = PSF_Item_Map.get(itemKey);

        if (interimData.Module.ASI_CRM_Volume_Base__c == 'By Total') {
            interimData.Module.ASI_CRM_Unit__c = 'RMB';
        }

        // Update the map after setting values
        PSF_Item_Map.put(itemKey, interimData);*/
    }
    
    /**
     * Return a map with key = picklist Value, value = SelectOption
     *
     * @param fieldResult
     *
     * @return
    */
    public Map<String, SelectOption> getPickListValueMap(Schema.DescribeFieldResult fieldResult){
        Map<String, SelectOption> selectOptions = new Map<String, SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            selectOptions.put(f.getValue(), new SelectOption(f.getValue(), f.getLabel()));
        }
        return selectOptions;
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

    //interimData class
    public class interimDataDto {

        public ASI_CRM_Module__c Module {set;get;}
        // Set to true after clicking Refresh or created from existing module
        public Boolean moduleReadOnly {set;get;}
        public Boolean showLineItems {set;get;}
        public Boolean isCreatedInCurrentVersion  {set;get;}
        public String MethodologyDisplay  {set;get;} {MethodologyDisplay='';}
        public Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}               
        // alternative way to control tables
        public Boolean displayMultiTable {set;get;} {displayMultiTable = false;}
        //public List<String> PSFMultiTableList {set;get;} {PSFMultiTableList = new List<String>();}
        public Map<String, String> PSFMultiTableMap {set;get;} {PSFMultiTableMap = new Map<String, String>();}        
        public Map<String, Decimal> PSFLadderAmountMap {set;get;} {PSFLadderAmountMap = new Map<String, Decimal>();}

        public interimDataDto(interimData d) {
            Module = d.Module;
            moduleReadOnly = d.moduleReadOnly;
            showLineItems = d.showLineItems;
            DetailLineMap = d.DetailLineMap;
            isCreatedInCurrentVersion = d.isCreatedInCurrentVersion;
            displayMultiTable = d.displayMultiTable;
            //PSFMultiTableList = d.PSFMultiTableList;
            PSFMultiTableMap = d.PSFMultiTableMap;
            PSFLadderAmountMap = d.PSFLadderAmountMap;
        }



    }
    
    public class interimData{
       public ASI_CRM_Module__c Module {set;get;}
        // Set to true after clicking Refresh or created from existing module
        public Boolean moduleReadOnly {set;get;}
        public Boolean showLineItems {set;get;}
        public Boolean isCreatedInCurrentVersion  {set;get;} {isCreatedInCurrentVersion = true;}
        public String MethodologyDisplay  {set;get;} {MethodologyDisplay='';}
        public List<SelectOption> MethodologyPicklist {set;get;}
        public List<SelectOption> VolumeValueBasePickList {set;get;}
        // alternative way to control tables
        public Boolean displayMultiTable {set;get;} {displayMultiTable = false;}     
        //public List<String> PSFMultiTableList {set;get;} {PSFMultiTableList = new List<String>();}
        public Map<String, String> PSFMultiTableMap {set;get;} {PSFMultiTableMap = new Map<String, String>();}
        public Map<String, Decimal> PSFLadderAmountMap {set;get;} {PSFLadderAmountMap = new Map<String, Decimal>();}
        
        public Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}

        public interimData(){
            this.Module=new ASI_CRM_Module__c();
            this.DetailLineMap= new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly =true;
        }
        public interimData(Boolean ClickRefresh){
            this.Module=new ASI_CRM_Module__c();
            this.DetailLineMap= new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly =ClickRefresh;
        }

        public interimData(ASI_CRM_Module__c ModuleInput) {
            this.Module = ModuleInput;
            this.DetailLineMap = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly = true;
            this.showLineItems = true;
        }

        public interimData( ASI_CRM_Module__c ModuleInput,Boolean ClickRefresh){
            this.Module=ModuleInput;
            this.DetailLineMap= new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.moduleReadOnly =ClickRefresh;
            this.isCreatedInCurrentVersion = true;
        }

        public void updateMethodologyDisplay(Boolean showCN){
            MethodologyDisplay = showCN ? Module.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c : Module.ASI_CRM_Methodology__r.Name;
        }

        public interimData copyFromDTO(interimDataDto dto){
            this.DetailLineMap = dto.DetailLineMap;
            return this;
        }
    }
    
}