/* Filename  :  ASI_CRM_CN_ViewHeavyContractCtrl.cls
* Author     :  Laputa
* Purpose    :  Controller for view heavy contract on Page 
* Study From :  ASI_CRM_CN_MainHeavyContractPage
* Testing    :
* History
* -----------------------------------------------------------------------------
* 2017-06-02   Laputa      Created

*/

 

public class ASI_CRM_CN_ViewHeavyContractCtrl {
    
    public void Calculation2nd() {

        if(!ContractSelected.ASI_CRM_CN_IS_Manual_Refresh__c){
            if(ContractSelected.ASI_CRM_System_Debug__c){
                if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                    ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(ContractSelected); 
                    ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(ContractSelected);
                    
                }else{
                    ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(ContractSelected); 
                    ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(ContractSelected); 
                }
            }else{
                try{ 
                    if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(ContractSelected); 
                        IF(!ContractSelected.ASI_CRM_Heap_Size_Large__c) ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(ContractSelected);
                    }else{//!='0.0'
                        ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(ContractSelected); 
                        IF(!ContractSelected.ASI_CRM_Heap_Size_Large__c) ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(ContractSelected); 
                    }
                }catch(Exception e){
                    System.debug(LoggingLevel.INFO, '***Calculation error : ' + e.getMessage() + e.getStackTraceString() );
                    ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData in ASI_CRM_CN_ViewHeavyContractPage class have Error  '+'Save Error : ' +e.getMessage() + e.getStackTraceString(),'ASI_CRM_CN_ViewHeavyContractCtrl','Calculation function failed! with contract Id: '+ContractSelected.id );
                }
            }
        }
        this.ContractSelected = [SELECT Id,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_Heap_Size_Large__c,ownerId,ASI_CRM_CN_Local_Group_Contract__c,ASI_CRM_Contract_Template_Id__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_CTD_Monthly_Default_Date__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Auto_PO_Modification_Time__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_System_Debug__c,ASI_CRM_Previous_Version_PSF_Est_Total__c ,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_Expected_PSF_Est_Total__c ,ASI_CRM_V0_PSF_Contract_Total__c,Owner.Email,ASI_CRM_Last_RBA_Approver__c,ASI_CRM_CN_Group_Contract__c,Name,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_Investment_Type__c,ASI_TH_CRM_Summary_Contract_Spending__c, ASI_CRM_CN_Total_Contract_Amount__c ,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_PSF_Grand_Estimate_Total__c,ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                                 ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c, 
                                 ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c ,   ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                 recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c, 
                                 ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                 ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,ASI_CRM_CN_IS_Manual_Refresh__c,ASI_CRM_CN_Is_Block__c,
                                 (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
                                  ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c 
                                  From ASI_TH_CRM_PaymentRequests_Contract__r)                       
                                 FROM ASI_TH_CRM_Contract__c
                                 WHERE id =:pageId ];

        if (ContractSelected.ASI_CRM_CN_CTD_Monthly_Default_Date__c != null) {
            Date CutOffDay = ASI_CRM_CN_EditHeavyContractDetailCtrl.GenerateCutOffDate(ContractSelected.ASI_CRM_CN_CTD_Monthly_Default_Date__c);
            ctdmothDate = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, ContractSelected.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        }
    }

    public void Calculation() {

        if(ContractSelected.ASI_CRM_System_Debug__c){
            if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(ContractSelected); 
                ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
                
            }else{
                ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected); 
                ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(ContractSelected); 
            }
        }else{
            try{ 
                if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
                    ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(ContractSelected); 
                    IF(!ContractSelected.ASI_CRM_Heap_Size_Large__c) ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
                }else{//!='0.0'
                    ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected); 
                    IF(!ContractSelected.ASI_CRM_Heap_Size_Large__c) ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(ContractSelected); 
                }
            }catch(Exception e){
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData in ASI_CRM_CN_ViewHeavyContractPage class have Error  '+'Save Error : ' +e.getMessage() + e.getStackTraceString(),'ASI_CRM_CN_ViewHeavyContractCtrl','Calculation function failed! with contract Id: '+ContractSelected.id );
            }
        }
    }
    
    
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public boolean showPOModification {set;get;}
    public boolean showRestorePO {set;get;}
    public boolean makePayment {set;get;}
    Public boolean PSFNoModules  {set;get;}
    
    public Boolean DisplayVEC {set;get;}  {DisplayVEC=false;}


    // public Boolean DisplayFC {set;get;}  {DisplayFC=false;}

    public Decimal totalEstimate=0;
    public Boolean showSuggestedAmountAndTargetVolume { get; set; } {showSuggestedAmountAndTargetVolume=false;}
    //Fix cost3.19 edit as map
    public Map<String,interimData> LFixCost2nd {set;get;} {LFixCost2nd = new Map<String,interimData>();}  

    //Fix cost
    public List<ASI_CRM_Contract_Cost__c> LFixCost {set;get;}  
    
    //BRSF
    public interimData BRSFItemMap {set;get;} {BRSFItemMap= new interimData();}
    
    //PSF
    public map<String, interimData> PSF_Item_Map {set;get;} {PSF_Item_Map= new map<String, interimData>();}
    public List<ASI_CRM_CN_Covered_Outlet__c> ContractOutletList {set;get;} {ContractOutletList = new List<ASI_CRM_CN_Covered_Outlet__c> (); }
    public Boolean ShowCoveredOutlet {set;get;} {ShowCoveredOutlet =false;}
    
    public List<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList{set;get;}
    public Boolean ShowPaymentList {set;get;} {ShowPaymentList =false;}
    public String VECDefaultMethodology  {get;set;} {VECDefaultMethodology='';}

    public Date ctdmothDate {get;set;}

    public Boolean HaveBRSF999Line {set;get;} {HaveBRSF999Line=false;}
    public Boolean HaveVEC999Line {set;get;} {HaveVEC999Line=false;}
    public String BRSF999LineId {set;get;} {BRSF999LineId='';}
    public String VEC999LineId {set;get;} {VEC999LineId='';}
    public Decimal HistoricalBRSFEstimateTotal {set;get;} {HistoricalBRSFEstimateTotal=0;}
    public Decimal HistoricalVECEstimateTotal {set;get;} {HistoricalVECEstimateTotal=0;}
    public map<String, ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_Item_Map {set;get;}{CoveredOutlet_Item_Map= new map<String, ASI_CRM_CN_Covered_Outlet__c>();}
    //@description : new line count
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public Boolean ValidateTotalSuggestedAmount=false;
    
    //3.20 add
    public Map<String,ASI_CRM_CM_GS__c> gsMap {get;set;}{gsMap = new Map<String,ASI_CRM_CM_GS__c>();}
    public Boolean DisplayPSFAdjustPart{set;get;} {DisplayPSFAdjustPart=false;}
    public Boolean IsRBAUser {set;get;} {IsRBAUser=false;}
    public Boolean showReturn {set;get;} {showReturn=false;}
    public Boolean inBAPermissionSet {set;get;} {inBAPermissionSet = false;}
    
    //Variable Event Cost
    public interimData VariableEventCost {set;get;} {
        VariableEventCost= new interimData();
    }

    public Map<String,Integer> lfSize {get;set;} {lfSize = new Map<String,Integer>();}

    public String PageId {set;get;}
    public boolean showCN {set;get;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public String Msg {get;set;} {Msg='';}

    
    public ASI_CRM_CN_ViewHeavyContractCtrl(ApexPages.StandardController controller) {//system.debug('Test StandardController ');
        //Variables Initialization 
        showCN = USerInfo.getLanguage()=='zh_CN';
        showPOModification = false;
        showRestorePO  = false;
        makePayment = false;
        this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
        if(this.ContractSelected != null)PageId = ContractSelected.id;

        if([SELECT Assignee.Name, PermissionSet.name FROM PermissionSetAssignment where permissionSet.name ='ASI_CRM_CN_General_BA' and Assigneeid = :Userinfo.getUserid()].size()>0){
            inBAPermissionSet = true;
        }

        this.ContractSelected = [SELECT Id,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_Heap_Size_Large__c,ownerId,ASI_CRM_CN_Local_Group_Contract__c,ASI_CRM_Contract_Template_Id__c, ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_CTD_Monthly_Default_Date__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Auto_PO_Modification_Time__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_System_Debug__c,ASI_CRM_Previous_Version_PSF_Est_Total__c ,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_Expected_PSF_Est_Total__c ,ASI_CRM_V0_PSF_Contract_Total__c,Owner.Email,ASI_CRM_Last_RBA_Approver__c,ASI_CRM_CN_Group_Contract__c,Name,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_Investment_Type__c,ASI_TH_CRM_Summary_Contract_Spending__c, ASI_CRM_CN_Total_Contract_Amount__c ,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_PSF_Grand_Estimate_Total__c,ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                                 ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c, 
                                 ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c ,   ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                 recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c, 
                                 ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                 ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,ASI_CRM_CN_IS_Manual_Refresh__c,ASI_CRM_CN_Is_Block__c,
                                 (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
                                  ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c 
                                  From ASI_TH_CRM_PaymentRequests_Contract__r)                       
                                 FROM ASI_TH_CRM_Contract__c
                                 WHERE id =:pageId ];
        
        
        if(inBAPermissionSet && ContractSelected.ASI_CRM_CN_Status__c == 'Submitted'){
            showReturn = true;
        }
        
        
        
        
        PaymentRequestList = ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r;
        
        if(PaymentRequestList.size()>0){ ShowPaymentList=true;}
        
        if(ContractSelected.ASI_CRM_CN_Status__c == 'Final'){showPOModification = true;}
        
        if(ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Last_PO_version__c != null && !ContractSelected.ASI_CRM_Auto_PO_Modification__c){
            showRestorePO = true;
        }
        if(ContractSelected.ASI_CRM_CN_Status__c == 'Final'){makePayment = true;}
        
        if(ContractSelected.ASI_CRM_CN_PO_Version__c!='0.0'){DisplayPSFAdjustPart=true;}
        
        init();

        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf999line;
            for (String key : BRSFItemMap.DetailLineMap.keySet()) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c line = BRSFItemMap.DetailLineMap.get(key);
                if (line.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c == '999') {
                    brsf999line = line;
                    BRSFItemMap.DetailLineMap.remove(key);
                }
            }
            if (brsf999line != null) {
                BRSFItemMap.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), brsf999line);
            }
            
            

            if (VariableEventCost.Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c vec999line ;
                for (String key : VariableEventCost.DetailLineMap.keySet()) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c line = VariableEventCost.DetailLineMap.get(key);
                    if (line.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c == '999') {
                        vec999line = line;
                        VariableEventCost.DetailLineMap.remove(key);
                    }
                }

                if (vec999line != null) {
                    VariableEventCost.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), vec999line);
                }
                
            }


            for (String modulekey : PSF_Item_Map.keySet()) {
                if (PSF_Item_Map.get(modulekey).Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c psf999line;
                    for (String key : PSF_Item_Map.get(modulekey).DetailLineMap.keySet()) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c line = PSF_Item_Map.get(modulekey).DetailLineMap.get(key);
                        if (line.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c == '999') {
                            psf999line = line;
                            PSF_Item_Map.get(modulekey).DetailLineMap.remove(key);
                        }
                    }
                    if (psf999line != null) {
                        PSF_Item_Map.get(modulekey).DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), psf999line);
                    }
                    
                }
            }

            for (String modulekey : LFixCost2nd.keySet()) {
                if (LFixCost2nd.get(modulekey).Module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c fc999line;
                    for (String key : LFixCost2nd.get(modulekey).DetailLineMap.keySet()) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c line = LFixCost2nd.get(modulekey).DetailLineMap.get(key);
                        if (line.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c == '999') {
                            fc999line = line;
                            LFixCost2nd.get(modulekey).DetailLineMap.remove(key);
                        }
                    }

                    if (fc999line != null) {
                        LFixCost2nd.get(modulekey).DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), fc999line);
                    }
                    
                }
            }


            if (ContractSelected.ASI_CRM_CN_CTD_Monthly_Default_Date__c != null) {
                Date CutOffDay = ASI_CRM_CN_EditHeavyContractDetailCtrl.GenerateCutOffDate(ContractSelected.ASI_CRM_CN_CTD_Monthly_Default_Date__c);
                ctdmothDate = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, ContractSelected.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
            }
        }
    }
    
    
    public void init(){
        
        if(ContractSelected.ASI_CRM_Last_RBA_Approver__c==UserInfo.getUserId()) IsRBAUser=true;
        
        User u =[select id,BypassTriggers__c from user where Id=:UserInfo.getUserId()]; 
        if(u.BypassTriggers__c!=null && u.BypassTriggers__c.contains('CNSetToFinal')){ // select id,Name,BypassTriggers__c from user where id='005M0000006Ghj6'
            IsRBAUser=true;
        }
        
        
        PSFNoModules=false;
        DisplayVEC=false;
        //Contract Cost  Line
        LFixCost2nd = new Map<String,interimData>();
        LFixCost = new List<ASI_CRM_Contract_Cost__c>();
        if (!ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(ASI_CRM_Contract_Cost__c cc:[Select id, name,ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :PageId order by ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC]){
                if(cc.ASI_CRM_CN_Cost_Type__c == 'Fixed') LFixCost.add(cc);
                
            }
        }
        
        
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>(); // Map <Id, ASI_CRM_Module__c>
        for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Remark_Display__c,ASI_CRM_Remark_Options__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_CN_Expected_Est_Total__c,
                                       ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c 
                                       from ASI_CRM_Module__c where ASI_CRM_Contract__c =:pageId  ])
        {
            ModuleMap.put(Module.Id,Module);
        }
        // System.debug(LoggingLevel.INFO, '*** ModuleMap: ' + ModuleMap);
        Set<String> ArchivedModuleId = new Set<String>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ArchivedBRSFList= new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        String ArchivedBRSFModuleId= '';
        String ArchivedVECModuleId= '';
        

        Set<Id> subBrandIdSets = new Set<Id>();

        for (ASI_MFM_Sub_brand__c brand : [SELECT Id FROM ASI_MFM_Sub_brand__c]) {
            subBrandIdSets.add(brand.Id);
        }
        // List<Date> dateList = new List<Date>();
        Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
        // dateList.add(setDate);

        String channel = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
        String region = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        String cityInvestementGrade = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
        String newImage = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;

        gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);
        
        //SubBrandGradeMap: Sub Brand name + Region + Commercial Team,  ASI_CRM_Sub_Brand_Grade__c
        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        for(ASI_CRM_Sub_Brand_Grade__c sbg:ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c )){
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }else{
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
            }
        }


        
        
        //BRSF/PSF/VEC Line 
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:[SELECT Id,ASI_CRM_Product_Category__r.Name,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Max_Incentive__c ,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c, ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, 
                                                            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                            ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, 
                                                            ASI_CRM_CN_Est_BRSF_Per_Bottle__c,ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,
                                                            ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c, ASI_CRM_CN_Est_Monthly_Qty__c,
                                                             ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c,
                                                            ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c
                                                            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :PageId] )
        {
            
            if(BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c==null){BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0;} 
           
            
            if(BRSFLine.ASI_CRM_Type__c=='BRSF'){
                if(BRSFLine.ASI_CRM_Module__c != NULL && ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                    BRSFItemMap.Module=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                }else if(BRSFLine.ASI_CRM_Module__c != NULL){
                    ArchivedBRSFModuleId = BRSFLine.ASI_CRM_Module__c;
                    ArchivedModuleId.add(BRSFLine.ASI_CRM_Module__c);
                }
                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,BRSFLine.ASI_CRM_CN_Sub_Brand__c,setDate,'BRSFMax','');
                }
                
                if (BRSFLine.ASI_CRM_Max_Incentive__c == null || !ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(SubBrandGradeMap,BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFMax');
                }

                if(BRSFLine.ASI_CRM_CN_Sub_Brand__c!=null && BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c =='999'){
                    BRSFLine.ASI_CRM_Max_Incentive__c = 99999;
                    BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
                }

                BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null ? 0 : BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;

                BRSFLine.ASI_CRM_Max_Incentive__c = BRSFLine.ASI_CRM_Max_Incentive__c == null ? 99999 : BRSFLine.ASI_CRM_Max_Incentive__c;
                if (BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
                }
                if (BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0;
                }
                BRSFItemMap.DetailLineMap.put(BRSFLine.Id,BRSFLine);
                if(BRSFLine.ASI_CRM_CN_Sub_Brand__c!=null && BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c =='999'){
                    HaveBRSF999Line=true;
                    BRSF999LineId = BRSFLine.Id;
                }else{
                    if(showCN){BRSFItemMap.MethodologyValue = BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c;
                    }else{
                        BRSFItemMap.MethodologyValue = BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name; 
                    }
                    
                    HistoricalBRSFEstimateTotal+=BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
            }
            
            if(BRSFLine.ASI_CRM_Type__c=='PSF'){
                
                if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                        BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,BRSFLine.ASI_CRM_CN_Sub_Brand__c,setDate,'PSFMax','');
                    }
                    
                    if (BRSFLine.ASI_CRM_Max_Incentive__c == null || !ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                        BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(SubBrandGradeMap,BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');
                    }
                }else{
                    BRSFLine.ASI_CRM_Max_Incentive__c=0;
                }
                
                String LineKey=BRSFLine.Id;
                if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Grade'){
                    LineKey=ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(BRSFLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +LineKey;
                }else if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Category'){
                    LineKey=ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(BRSFLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) +LineKey;
                }
                
                if (BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
                }
                if (BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0;
                }
                if(PSF_Item_Map.containsKey(BRSFLine.ASI_CRM_Module__c)){PSF_Item_Map.get(BRSFLine.ASI_CRM_Module__c).DetailLineMap.put(LineKey,BRSFLine);
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
            
            if (BRSFLine.ASI_CRM_Type__c == 'Fixed' && ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,BRSFLine.ASI_CRM_CN_Sub_Brand__c,setDate,'FCMax',BRSFLine.ASI_CRM_CN_Activity_Code__c);
                    if (BRSFLine.ASI_CRM_Max_Incentive__c == null) {
                        BRSFLine.ASI_CRM_Max_Incentive__c=99999;
                    }
                }
                if (BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
                }
                if (BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0;
                }
                String LineKey=BRSFLine.Id;
                if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Grade'){
                    LineKey=ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(BRSFLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +LineKey;
                }else if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Category'){
                    LineKey=ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(BRSFLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c) +LineKey;
                }
                
                system.debug('FC  Line : ' + BRSFLine);
                if (showCN) {
                    if(LFixCost2nd.containsKey(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c)){
                        system.debug('LFixCost2nd  containsKey ');
                        LFixCost2nd.get(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c).DetailLineMap.put(LineKey,BRSFLine);
                    }else{
                        if(ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                            system.debug('ModuleMap  containsKey2  ');
                            interimData TempData= new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
                            LFixCost2nd.put(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c,TempData);
                            LFixCost2nd.get(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c).DetailLineMap.put(LineKey,BRSFLine);
                            // LFixCost2nd.get(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c).Module.ASI_CRM_Contract__c=PageId;
                        }  else if(BRSFLine.ASI_CRM_Module__c !=null){
                            ArchivedModuleId.add(BRSFLine.ASI_CRM_Module__c);
                            ArchivedBRSFList.add(BRSFLine);
                        }
                    }
                } else {
                    if(LFixCost2nd.containsKey(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c)){
                        system.debug('LFixCost2nd  containsKey ');
                        LFixCost2nd.get(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c).DetailLineMap.put(LineKey,BRSFLine);
                    }else{
                        if(ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                            system.debug('ModuleMap  containsKey2  ');
                            interimData TempData= new interimData(ModuleMap.get(BRSFLine.ASI_CRM_Module__c));
                            LFixCost2nd.put(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,TempData);
                            LFixCost2nd.get(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c).DetailLineMap.put(LineKey,BRSFLine);
                            // LFixCost2nd.get(BRSFLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c).Module.ASI_CRM_Contract__c=PageId;
                        }  else if(BRSFLine.ASI_CRM_Module__c !=null){
                            ArchivedModuleId.add(BRSFLine.ASI_CRM_Module__c);
                            ArchivedBRSFList.add(BRSFLine);
                        }
                    }
                }
            }

            if(BRSFLine.ASI_CRM_Type__c=='Variable Event Cost'){
                DisplayVEC=true;
                if(BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        // BRSFLine.ASI_CRM_Line_Name__c= BRSFLine.ASI_CRM_Sub_Brand_Grade__c!=null?BRSFLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:BRSFLine.ASI_CRM_Sub_Brand_Grade__r.Name;
                        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                            BRSFLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,BRSFLine.ASI_CRM_CN_Sub_Brand__c,setDate,'VECMax','');
                        }
                    }else{
                        BRSFLine.ASI_CRM_Max_Incentive__c=0;
                    }
                if(BRSFLine.ASI_CRM_Module__c != null && ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                    VariableEventCost.Module=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                }else if(BRSFLine.ASI_CRM_Module__c != null){
                    ArchivedVECModuleId = BRSFLine.ASI_CRM_Module__c;
                    ArchivedModuleId.add(BRSFLine.ASI_CRM_Module__c);
                }
                if (BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0;
                }
                if (BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                    BRSFLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0;
                }
                VariableEventCost.DetailLineMap.put(BRSFLine.Id,BRSFLine);
                
                if(BRSFLine.ASI_CRM_CN_Sub_Brand__c!=null && BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c =='999'){
                    HaveVEC999Line=true;
                    VEC999LineId=BRSFLine.Id;
                }else{
                    if(BRSFLine.ASI_CRM_Module__c!=null){
                        if(showCN){ VariableEventCost.MethodologyValue = BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c;
                        }else{
                            VariableEventCost.MethodologyValue = BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name; 
                        }
                        
                    }
                    HistoricalVECEstimateTotal +=BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
            }
        }
        
        if(ArchivedModuleId.size()>0 && ArchivedBRSFList.size()>0 ){
            for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Remark_Display__c,ASI_CRM_Remark_Options__c, ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c, ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_CN_Expected_Est_Total__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c from ASI_CRM_Module__c where Id in : ArchivedModuleId ]){
                ModuleMap.put(Module.Id,Module);
            }
            
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ArchivedBRSFList ){
                if(PSF_Item_Map.containsKey(ContractLine.ASI_CRM_Module__c)){
                    PSF_Item_Map.get(ContractLine.ASI_CRM_Module__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                }else{
                    if(ModuleMap.containsKey(ContractLine.ASI_CRM_Module__c) && ContractLine.ASI_CRM_Type__c == 'PSF'){
                        interimData TempData= new interimData(ModuleMap.get(ContractLine.ASI_CRM_Module__c));
                        PSF_Item_Map.put(ContractLine.ASI_CRM_Module__c,TempData);
                        PSF_Item_Map.get(ContractLine.ASI_CRM_Module__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                    }
                }                
            }

            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                if (showCN) {
                    for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ArchivedBRSFList ){
                        if(LFixCost2nd.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c)){
                            LFixCost2nd.get(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                        }else{
                            if(ModuleMap.containsKey(ContractLine.ASI_CRM_Module__c) && ContractLine.ASI_CRM_Type__c == 'Fixed'){
                                interimData TempData= new interimData(ModuleMap.get(ContractLine.ASI_CRM_Module__c));
                                LFixCost2nd.put(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c,TempData);
                                LFixCost2nd.get(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                            }
                        }                
                    }
                } else {
                    for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ArchivedBRSFList ){
                        if(LFixCost2nd.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c)){
                            LFixCost2nd.get(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                        }else{
                            if(ModuleMap.containsKey(ContractLine.ASI_CRM_Module__c)){
                                interimData TempData= new interimData(ModuleMap.get(ContractLine.ASI_CRM_Module__c));
                                LFixCost2nd.put(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,TempData);
                                LFixCost2nd.get(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c).DetailLineMap.put(ContractLine.Id,ContractLine);
                            }
                        }                
                    }
                }
            }
            
            
            
            if(ArchivedBRSFModuleId !=null && ModuleMap.containsKey(ArchivedBRSFModuleId)){BRSFItemMap.Module=ModuleMap.get(ArchivedBRSFModuleId);}
            
            if(ArchivedVECModuleId !=null && ModuleMap.containsKey(ArchivedVECModuleId)){VariableEventCost.Module=ModuleMap.get(ArchivedVECModuleId);}
            
        }
        
        if(PSF_Item_Map.size()>0){PSFNoModules=true;}
        
        else{
            DisplayPSFAdjustPart=false;
        }
        
        // Covered Outlet
        ContractOutletList = [SELECT id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Target_Volume_Std_Btl__c ,ASI_CRM_CN_Suggested_Amount__c, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.ASI_CRM_Account__c, ASI_CRM_CN_Allocated_Amount__c, ASI_CRM_CN_Check_All__c, ASI_CRM_CN_Selected_Covered_Outlet__c 
                              FROM ASI_CRM_CN_Covered_Outlet__c 
                              WHERE ASI_CRM_CN_Contract__c = :PageId];
        
        if(ContractOutletList.size()>0){
            ShowCoveredOutlet=true;
            for(ASI_CRM_CN_Covered_Outlet__c Outlet:ContractOutletList){
                CoveredOutlet_Item_Map.put(Outlet.Id,outlet);
            }
        }
        
        if(VariableEventCost.DetailLineMap.size()==0 || BRSFItemMap.DetailLineMap.size()==0  ){ // dont have VEC 
            List<ASI_CRM_Methodology__c> MethodologyList=[select Id,ASI_CRM_Chinese_Name__c,ASI_CRM_Default__c,Name,ASI_CRM_Type__c from ASI_CRM_Methodology__c 
                                                          where ASI_CRM_Default__c = true and RecordType.DeveloperName ='ASI_CRM_CN_Methodology'];
            string BRSFDefaultMethodology='';
            for(ASI_CRM_Methodology__c Methodology:MethodologyList){
                if(Methodology.ASI_CRM_Type__c =='Variable Event Cost'){
                    if(showCN){
                        VECDefaultMethodology=Methodology.ASI_CRM_Chinese_Name__c;
                    }else{
                        VECDefaultMethodology=Methodology.Name;
                    }
                }
                
                if(Methodology.ASI_CRM_Type__c =='BRSF'){
                    if(showCN){
                        BRSFDefaultMethodology=Methodology.ASI_CRM_Chinese_Name__c;
                    }else{
                        BRSFDefaultMethodology=Methodology.Name;
                    }
                }
            } 
            
            if(VariableEventCost.DetailLineMap.size()==0){
                ASI_CRM_Module__c Module = NEW ASI_CRM_Module__c(ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Unit__c='CR12 Extra Eqv.');
                VariableEventCost.MethodologyValue=VECDefaultMethodology;
                VariableEventCost.Module= Module;
            }
            if(BRSFItemMap.DetailLineMap.size()==0){
                ASI_CRM_Module__c Module = NEW ASI_CRM_Module__c(ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Unit__c='Std. Btl.');
                BRSFItemMap.MethodologyValue=BRSFDefaultMethodology;
                BRSFItemMap.Module= Module;
            }
            
            
        }
        
        String recordType = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting');
        List<ASI_CRM_SpecialPromotionTypeSetting__c> SpecialPromotionTypeSettingList=[SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c
                                                                                      FROM ASI_CRM_SpecialPromotionTypeSetting__c 
                                                                                      WHERE  recordtypeid =: recordType  and ASI_CRM_Promotion_Type__c ='Heavy Contract On'];
        if(SpecialPromotionTypeSettingList.size()>0){
            showSuggestedAmountAndTargetVolume= SpecialPromotionTypeSettingList[0].ASI_CRM_SuggestedAmount_And_TargetVolume__c;
            ValidateTotalSuggestedAmount= SpecialPromotionTypeSettingList[0].ASI_CRM_Validate_TotalSuggestedAmount__c;
        }
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            Map<String,Id> FCActivityCodeId = new Map<String,Id>();
            List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList = [SELECT id, Name, ASI_CRM_VEC_Activity_Code_Defaul__c,ASI_CRM_CN_BRSF_Activity_Code_Default__c,ASI_CRM_PSF_Activity_Code_Default__c,ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c,ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c, ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Variable_Cost_Contract__c,   ASI_CRM_CN_Other_Cost_Payment_Request__c FROM ASI_CRM_Contract_Cost_Setting__c where ASI_CRM_CN_Promotion_Type__c ='Heavy Contract On' ORDER BY ASI_CRM_CN_Sequence__c ASC];
            for(ASI_CRM_Contract_Cost_Setting__c ccs:ContractCostSettingList){
                //3.17新增固定费用id
                
                if (ccs.ASI_CRM_CN_Fixed_Cost_Contract__c) {
                    if (showCN) {
                        FCActivityCodeId.put(ccs.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c, ccs.ASI_CRM_CN_Activity_Code__c);
                    } else {
                        FCActivityCodeId.put(ccs.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c, ccs.ASI_CRM_CN_Activity_Code__c);
                    }
                }
            }
            if (LFixCost2nd.isEmpty() ) {
                for (String key : FCActivityCodeId.keySet()) {
                    ASI_CRM_Module__c module = new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_CN_AC_Code__c=FCActivityCodeId.get(key),ASI_CRM_Created_PO_Version__c=ContractSelected.ASI_CRM_CN_PO_Version__c,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_Contract__c=pageId);
                    LFixCost2nd.put(key, new interimData(module));
                }
            } else {
                for (String key : FCActivityCodeId.keySet()) {
                    if (!LFixCost2nd.containsKey(key)) {
                        ASI_CRM_Module__c module = new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_CN_AC_Code__c=FCActivityCodeId.get(key),ASI_CRM_Created_PO_Version__c=ContractSelected.ASI_CRM_CN_PO_Version__c,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_Contract__c=pageId);
                        LFixCost2nd.put(key, new interimData(module));
                    }
                }
            }


            Map<String,interimData> newFC = new Map<String,interimData>();
            List<String> keyList = new List<String>();
            keyList.addAll(FCActivityCodeId.keySet());
            for (Integer i = 0;i<keyList.size() ; i++) {
                if (LFixCost2nd.containsKey(keyList.get(i))) {
                    newFC.put(keyList.get(i), LFixCost2nd.get(keyList.get(i)));
                }
            }
            LFixCost2nd.clear();
            LFixCost2nd.putAll(newFC);

            System.debug(LoggingLevel.INFO, '*** LFixCost2nd: ' + LFixCost2nd);
            
            for (String key : LFixCost2nd.keySet()) {
                lfSize.put(key, LFixCost2nd.get(key).DetailLineMap.size());
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    //****************************************************** Covered Outlet Line Item - functions End *****************************************************
    
    public void AddNew_CoveredOutlet(){
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        CoveredOutlet_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(), outlet );
        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
    }
    
    
    
    
    
    
    //*********************************************************
    //@description: Add All Child Outlets  in one time 
    //@param: Null
    //@return: Null
    // *********************************************************
    public void AddAllChildOutlets(){
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        Set<id> Selecteddd = new Set<id>();
        Set<id> SChildCustomersIds = new Set<id>();
        String recordType = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName;
        Integer limitRecord = 0;
        if(recordType == 'ASI_CRM_Outlet_CN'){
            for ( ASI_CRM_CN_Covered_Outlet__c s:ContractOutletList ){ Selecteddd.add(s.ASI_CRM_CN_Outlet__r.Id); }
            
            List<ASI_CRM_AccountsAdditionalField__c> childCustomers = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c AND Id NOT IN :Selecteddd  limit 200];
            
            if(childCustomers!= null && childCustomers.size() > 0) {          
                for(ASI_CRM_AccountsAdditionalField__c customer : childCustomers){ 
                    if(limitRecord < 200){                 
                        outlet = new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Outlet__c = customer.id);
                        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
                        SChildCustomersIds.add(customer.Id);
                        CoveredOutlet_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),outlet);
                        limitRecord++;  
                    }  
                    else
                        break;
                }
            }  
            
            if(SChildCustomersIds != null && SChildCustomersIds.size() > 0 && limitRecord < 200){
                List<ASI_CRM_AccountsAdditionalField__c> childChildCustomers = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c IN :SChildCustomersIds limit 200];        
                if(childChildCustomers != null && childChildCustomers.size() > 0 ) {                                  
                    for(ASI_CRM_AccountsAdditionalField__c childCustomer : childChildCustomers){  
                        if(limitRecord < 200){               
                            outlet = new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Outlet__c = childcustomer.id);
                            outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
                            CoveredOutlet_Item_Map.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),outlet);
                            limitRecord++;  
                        }
                        else
                            break;
                    }
                }
            }
            
        }
        
        
        
    }
    
    
    
    
    
    //Save the record 
    public PageReference SaveItems(){
        msg = '';
        totalEstimate=0;
        UpsertPermission = true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);   
        
        //Fix cost 
        if (!ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(ASI_CRM_Contract_Cost__c FixCost: LFixCost){
            
                if(FixCost.ASI_CRM_CN_Estimate_Amount__c== null){FixCost.ASI_CRM_CN_Estimate_Amount__c=0;}
                
                else{
                    totalEstimate+= FixCost.ASI_CRM_CN_Estimate_Amount__c;
                }
            }
        }
        
        
        totalEstimate+=ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null? ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        totalEstimate+=ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null? ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        totalEstimate+=ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c!=null? ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
        
        List<ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> Saved_CoveredOutlet_Temp = new List<ASI_CRM_CN_Covered_Outlet__c>();
        for (String key : CoveredOutlet_Item_Map.keySet()){
            ASI_CRM_CN_Covered_Outlet__c outlet = CoveredOutlet_Item_Map.get(key);
            if(outlet.ASI_CRM_CN_Contract__c == null){
                outlet.ASI_CRM_CN_Contract__c = ContractSelected.Id;
                outlet.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet');
            }
            if(outlet != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true && outlet.ASI_CRM_CN_Outlet__c != null){
                Save_CoveredOutlet_Item.add(outlet);            
            }          
            else if (outlet.id != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == false) { 
                Saved_CoveredOutlet_Temp.add(outlet);            
            }
        }
        
        if(Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0){
            CoveredOutletValdationChecking(Save_CoveredOutlet_Item);
        }
        
        
        
        PageReference pageRef = null;
        System.Savepoint pSavepoint = Database.setSavepoint();
        if(UpsertPermission){
            try{
                
                if(Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0){
                    upsert Save_CoveredOutlet_Item;
                }
                if(Saved_CoveredOutlet_Temp!= null && Saved_CoveredOutlet_Temp.size() > 0){ delete Saved_CoveredOutlet_Temp;}
                
                if (!ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    update LFixCost;
                }
                // update LFixCost2nd;
                
                //Previous Version PSF Est. Total +Adjustment=Expected PSF Est. Total
                if(ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c !=null && ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c!=null ){
                    ContractSelected.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c - ContractSelected.ASI_CRM_Previous_Version_PSF_Est_Total__c; 
                }
                
                update ContractSelected;
                
                
                
                
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpdatedContractList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
                
                //ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c
                if(HistoricalBRSFEstimateTotal != ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c){
                    decimal Difference= HistoricalBRSFEstimateTotal-ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c;
                    Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF'); 
                    Id subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1].id;
                    
                    if(HaveBRSF999Line && BRSF999LineId !=NULL){
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFAjustmentLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(Id=BRSF999LineId,ASI_CRM_CN_Contract__c=ContractSelected.Id,
                             ASI_CRM_CN_Est_Total_Dummy__c=0-Difference);
                        UpdatedContractList.add(BRSFAjustmentLine);
                    }else{ // New 
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFAjustmentLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractSelected.Id, ASI_CRM_Type__c='BRSF', recordTypeId=BRSFLineRtId, ASI_CRM_CN_Sub_Brand__c = subbrand999, ASI_CRM_CN_Est_Monthly_Qty__c = 0, ASI_CRM_CN_Contract_Monthly_Qty__c=0, ASI_CRM_CN_Est_Total_Dummy__c=0-Difference, ASI_CRM_CN_Contract_Total_Dummy__c=0, ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0,
                                                                                                                            ASI_CRM_Module__c = BRSFItemMap.Module.Id);
                        UpdatedContractList.add(BRSFAjustmentLine);
                    }
                    
                }
                
                
                if(HistoricalVECEstimateTotal != ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c){
                    decimal Difference= HistoricalVECEstimateTotal-ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c;
                    Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF'); 
                    Id subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1].id;
                    
                    if(HaveVEC999Line && VEC999LineId !=NULL){
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFAjustmentLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(Id=VEC999LineId,ASI_CRM_CN_Contract__c=ContractSelected.Id,
                            ASI_CRM_CN_Est_Total_Dummy__c=0-Difference);
                        UpdatedContractList.add(BRSFAjustmentLine);
                    }else{ // New 
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFAjustmentLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractSelected.Id, ASI_CRM_Type__c='Variable Event Cost',
                            recordTypeId=BRSFLineRtId, ASI_CRM_CN_Sub_Brand__c = subbrand999,ASI_CRM_Volume_Base__c='999-AdjustmentLine',
                                ASI_CRM_CN_Est_Monthly_Qty__c = 0,
                                ASI_CRM_Contract_Total_QTY_CR12_Eqv__c=0,
                                ASI_CRM_Est_Total_QTY_CR12_Eqv__c=0,
                                ASI_CRM_CN_Contract_Monthly_Qty__c=0,
                                ASI_CRM_CN_Est_Total_Dummy__c=0-Difference,
                               ASI_CRM_CN_Contract_Total_Dummy__c=0,
                            ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0,
                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0,
                        ASI_CRM_Module__c = VariableEventCost.Module.Id);
                        UpdatedContractList.add(BRSFAjustmentLine);
                    }
                    
                }
                
                
                if(UpdatedContractList.size()>0){
                    upsert UpdatedContractList;
                }
                
                if (!isQuickSave){
                    pageRef = new PageReference('/'+PageId);
                    pageRef.setRedirect(true);
                }else{
                    pageRef = new PageReference('/apex/ASI_CRM_CN_Heavy_POModiPage?id='+PageId);
                    pageRef.setRedirect(true);
                }
            }catch(Exception e){
                Database.rollback(pSavepoint);
            }
        }
        
        return pageRef; 
    }
    
    
    
    
    public PageReference GoEditHeaderPage(){
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            return redirectToPage('/apex/ASI_CRM_CN_HeavyContractHeaderEdit2nd',PageId);
        } else {
            return redirectToPage('/apex/ASI_CRM_CN_HeavyContractHeaderEditPage',PageId);
        }
        return null;
    }
    
    
    // Modifier: Bluelinksys_PC Date : 2020-03-22
    // Modifiy Content : Lin3 GenerateContractTemplateOldOrNew Function
    public PageReference GoToContractGenerationPage(){
        if( ContractSelected.ASI_CRM_Contract_Template_Id__c==null){
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                Document DocumentFile =ASI_CRM_CN_HeavyContracFunctionClass.GenerateContractTemplateOldOrNew(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,false);
                ContractSelected.ASI_CRM_Contract_Template_Id__c=DocumentFile!=NULL?DocumentFile.Id:NULL;
            } else {
                Document DocumentFile =ASI_CRM_CN_HeavyContracFunctionClass.GenerateContractTemplate(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,false);
                ContractSelected.ASI_CRM_Contract_Template_Id__c=DocumentFile!=NULL?DocumentFile.Id:NULL;
            }
            
        }
        
        try{ 
            update ContractSelected;
        }catch(Exception e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData <br/> in ASI_CRM_CN_ViewHeavyContractPage class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Calculation function failed! with contract Id: '+ContractSelected.id );
        }
        
        
        String url = '';
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            url='/apex/ASI_CRM_CN_HeavyContractGeneration2nd?edit=1&id='+ContractSelected.Id+'&TemplateId='+ContractSelected.ASI_CRM_Contract_Template_Id__c;
        } else {
            url='/apex/ASI_CRM_CN_HeavyContractGenerationPage?edit=1&id='+ContractSelected.Id+'&TemplateId='+ContractSelected.ASI_CRM_Contract_Template_Id__c;
        }
        return new pageReference(url); 
    }
    
    
    
    public PageReference GoCheckPointPage(){//return redirectToPage('/apex/ASI_CRM_CN_HeavyPDFRedirectPage',PageId);
        PageReference redirectPage;
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            redirectPage = new pageReference('/apex/ASI_CRM_CN_HeavyPDFRedirectPage?id='+PageId+'&Type=SubmitApproval');
        } else {
            redirectPage = new pageReference('/apex/ASI_CRM_CN_HeavyPDFRedirectPage?id='+PageId+'&Type=SubmitApproval');
        }
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    public PageReference ViewCheckPointPage(){
        PageReference redirectPage;
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            redirectPage = new pageReference('/apex/ASI_CRM_CN_HeavyPDFRedirectPage?id='+PageId+'&Type=ViewCheckPoint');
        } else {
            redirectPage = new pageReference('/apex/ASI_CRM_CN_HeavyPDFRedirectPage?id='+PageId+'&Type=ViewCheckPoint');
        }
        redirectPage.setRedirect(true);
        return redirectPage;
    }         
    
    public PageReference GoEditDetailPage(){
        
        if(ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0'){
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return redirectToPage('/apex/ASI_CRM_CN_EditHeavyContractDetail2nd',PageId);
            } else {
                return redirectToPage('/apex/ASI_CRM_CN_EditHeavyContractDetailPage',PageId);
            }
        }else if(ContractSelected.ASI_CRM_CN_Group_Contract__c !=null){ 
                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    return redirectToPage('/apex/ASI_CRM_CN_Heavy_POModiEditPage2nd',PageId);
                } else {
                    return redirectToPage('/apex/ASI_CRM_CN_Heavy_POModiPage',PageId);
                }
            }
                                                                       
        else{
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return redirectToPage('/apex/ASI_CRM_CN_Heavy_POModiEditPage2nd',PageId);
            } else {
                return redirectToPage('/apex/ASI_CRM_CN_Heavy_POModiEditPage',PageId);
            }
            
        }
        
    }
    
    public PageReference redirectToPage(String pagePath, String pid){
        
        PageReference redirect = new PageReference(pagePath); 
        redirect.getParameters().put('id',pid); 
        redirect.setRedirect(true);    
        return redirect;
    }
    
    
    
    
    public PageReference POModification(){
        List<ASI_TH_CRM_Contract__c> cContract = [Select Id, ASI_CRM_CN_Status__c, lastModifiedDate from ASI_TH_CRM_Contract__c where id=:contractSelected.id LIMIT 1];
        
        if (cContract[0].ASI_CRM_CN_Status__c == 'Final' && cContract[0].lastModifiedDate == contractSelected.lastModifiedDate){
            
            
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest:ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {    
                if( paymentrequest.ASI_TH_CRM_Status__c=='Submitted'){
                    Msg=Label.ASI_CRM_CN_ContractSubmittedPaymentCheckErrMsg;
                    UpsertPermission=false;
                    return null;
                    
                }
                
            }

            PageReference redirect;
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                redirect = new PageReference('/apex/ASI_CRM_CN_HeavyContractHeaderEdit2nd'); 
            } else {
                redirect = new PageReference('/apex/ASI_CRM_CN_HeavyContractHeaderEditPage');
            }
            redirect.getParameters().put('id',contractSelected.id);
            redirect.getParameters().put('POModification','1'); 
            redirect.setRedirect(true);    
            
            
            return redirect;
        } else {
            if(USerInfo.getLanguage()=='zh_CN'){
                ErrorHandling('Contract has been modified since last update, Please refresh and do modification again!');
            }else{
                ErrorHandling('请刷新网页，更新PO资料，再PO修改。');
            }
            
        }
        
        return null; 
        
        
    }
    
    
    
    
    //*********************************************************
    //@description:Generate Sub-Brand Grade incentive By Sub-Brand Grade Map
    //@param: 
    //@return:incentive
    // *********************************************************
    public Decimal GeneratingIncentive(Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap ,String SubBrandGradeName,String TypeName){
        
        
        Decimal Incentive=0.0;
        String ExternalKey=SubBrandGradeName;
        
        ExternalKey+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c:'';
        ExternalKey+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
        
        String CityTierExternalKey = ExternalKey;
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c!=null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
            CityTierExternalKey+= ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
        }
        
        if(TypeName =='BRSFMax'){
            if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;
            }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
            }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
            }    
        } 
        
        if(TypeName =='PSFMax'){
            if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive_for_PSF__c;
            }
        }

        //3.18新增
        if(TypeName =='FCMax'){
            Incentive = 99999;
        }
        
        return Incentive;
    }


    //GeneratingIncentive2nd
    public static Decimal GeneratingIncentive(Map<String, ASI_CRM_CM_GS__c> gsMap ,String subBrand,Date setDate,String TypeName,String acCode){
        
        
        Decimal Incentive=null;
        String CityTierExternalKey=subBrand;

        if(TypeName =='BRSFDefault'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive_BRSF__c;
            }
        }
        
        
        
        if(TypeName =='BRSFMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_BRSF__c;
            }
        }
        
        if(TypeName =='PSFMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_PSF__c;
            }
        }

        if(TypeName =='PSFDefault'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive_PSF__c;
            }
        }

        if(TypeName =='VECDefault'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive_VEC__c;
            }
            if (Incentive == null) {
                Incentive = 0.00;
            }
        }


        if(TypeName =='VECMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_VEC__c;
            }
            if (Incentive == null) {
                Incentive = 99999;
            }
        }


        //3.18新增
        if(TypeName =='FCMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                ASI_CRM_CM_GS__c gs = gsMap.get(CityTierExternalKey);
                for (ASI_CRM_Actual_CM_GS_Line__c gsline : gs.Actual_CM_GS_Lines__r) {
                    if (String.isNotBlank(acCode) && gsline.ASI_CRM_CN_Activity_Code__c == acCode) {
                        Incentive = gsline.ASI_CRM_CN_Max_Incentive__c;
                    }
                }
            }
            if (Incentive == null) {
                Incentive = 99999;
            }
        }

        if (TypeName =='FCDefault') {
            if(gsMap.containsKey(CityTierExternalKey)){ 
                ASI_CRM_CM_GS__c gs = gsMap.get(CityTierExternalKey);
                for (ASI_CRM_Actual_CM_GS_Line__c gsline : gs.Actual_CM_GS_Lines__r) {
                    if (String.isNotBlank(acCode) && gsline.ASI_CRM_CN_Activity_Code__c == acCode) {
                        Incentive = gsline.ASI_CRM_CN_Incentive__c;
                    }
                }
            }
            if (Incentive == null) {
                Incentive = 0;
            }
        }
        
        
        return Incentive;
    }
    
    
    
    
    //***************Restore PO******************************************************************
    public PageReference restorePO(){
        PageReference p;
        String returnId = contractSelected.id;
        List<ASI_TH_CRM_Contract__c> cContract = [Select Id, ASI_CRM_CN_Status__c, lastModifiedDate from ASI_TH_CRM_Contract__c where id=:contractSelected.id LIMIT 1];
        if (cContract[0].ASI_CRM_CN_Status__c == 'Draft' && cContract[0].lastModifiedDate == contractSelected.lastModifiedDate){
            restore(contractSelected);
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return redirectToPage('/apex/ASI_CRM_CN_ViewHeavyContractPage2nd',returnId);
            } else {
                return redirectToPage('/apex/ASI_CRM_CN_ViewHeavyContractPage',returnId);
            }
            
        } else {
            if(USerInfo.getLanguage()=='zh_CN')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Contract has been modified since last update, Please refresh and restore again!'));
            else    
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'请刷新网页，更新PO资料，再恢复以前的版本。'));
            
        }
        
        return null; 
    }
    
    
    
    public void CoveredOutletValdationChecking(List<ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item){
        Set<Id> effectiveChildsSet = new Set<Id>();
        Boolean isAllCustomer = False;
        Set<Id> invalidChilds = new Set<Id>();
        
        
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS'){
            for(ASI_CRM_Effective_supplier__c obj : [SELECT id, ASI_CRM_Supplier__c , ASI_CRM_Account__c FROM ASI_CRM_Effective_supplier__c  WHERE ASI_CRM_Supplier__c = : ContractSelected.ASI_CRM_CN_Outlet_WS__c]){
                effectiveChildsSet.add(obj.ASI_CRM_Account__c);
            }
        }else if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN'){
            isAllCustomer = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c != Null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name.toLowerCase().contains('all customer');
            
            if(!isAllCustomer){
                for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c = : ContractSelected.ASI_CRM_CN_Outlet_WS__c  ]){
                    effectiveChildsSet.add(obj.id);
                }
                for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c IN : effectiveChildsSet ]){
                    effectiveChildsSet.add(obj.id);}
            }
        }
        
        double totalSuggestedAmount = 0;
        for(ASI_CRM_CN_Covered_Outlet__c obj : Save_CoveredOutlet_Item) {
            if(obj.ASI_CRM_CN_Suggested_Amount__c != null){
                totalSuggestedAmount += obj.ASI_CRM_CN_Suggested_Amount__c;}
            if(!effectiveChildsSet.contains(obj.ASI_CRM_CN_Outlet__c)){
                invalidChilds.add(obj.ASI_CRM_CN_Outlet__c);}
        }
        
        
        if(invalidChilds.size() > 0 && !isAllCustomer){
            String errorMsg = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? 'This wholesaler is not effective supplier of below outlets and thus they can\'t be cover outlet : ' : 'This Outlet is not effective parent of below outlets and thus they can\'t be cover outlet : ';String errorMsgCN = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? '该经销商并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ' : '该母店家并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ';
            for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id , Name   FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN : invalidChilds   ]){
                errorMsg += obj.Name + ','; errorMsgCN += obj.Name + ',';
            }
            errorMsg += ' If it is necessary to be covered, Please contact Admin';errorMsgCN += ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? ' 若此覆盖店家与供货商暂无展开合作，但确认需加入，请和Admin联系' : ' 如确认需加入，请和Admin联系';
            
            if(USerInfo.getLanguage()=='zh_CN'){ErrorHandling(errorMsgCN);}
            else{ErrorHandling(errorMsg);}
            
            
        }
        
        if(ValidateTotalSuggestedAmount){
            if(totalEstimate!=totalSuggestedAmount){ ErrorHandling('Total suggested amount should equal to total PO est. amount.');}
        }
    }
    
    
    
    
    
    
    
    
    
    private void restore(ASI_TH_CRM_Contract__c cont){
        
        List<ASI_TH_CRM_Contract__c> LLastContract = [select Id,Name,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_Auto_PO_Modification_Time__c,ASI_CRM_CN_CTD_Monthly_Default_Date__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,
                                                      ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                                                      ASI_CRM_Copied_From__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                                                      ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,  ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_IsClone__c ,ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,recordtypeid, ASI_CRM_CN_PO_Modification__c ,  ASI_CRM_CN_Contract_Upload__c,ASI_CRM_CN_Business_License__c,ASI_CRM_CN_Last_PO_version__c, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Start_Date__c, ASI_CRM_CN_Return_Comments__c,
                                                      ASI_CRM_CN_Fixed_Module_Est_Amount1__c,
                                                      ASI_CRM_CN_Fixed_Module_Est_Amount2__c,ASI_CRM_Reject_Return_Comments__c, ASI_CRM_CN_Last_Approved_By__c, ASI_CRM_CN_Last_Approved_Date__c, ASI_CRM_CN_Last_Recall_By__c
                                                      , ASI_CRM_CN_Last_Recall_Date__c, ASI_CRM_CN_Last_Rejected_By__c, ASI_CRM_CN_Last_Rejected_Date__c
                                                      , ASI_CRM_CN_Last_Submitted_By__c, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_National_Group__c, ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_NationalGroup__c 
                                                      from ASI_TH_CRM_Contract__c  where id = :cont.ASI_CRM_CN_Last_PO_version__c];
        List<ASI_CRM_CN_FixedMappingSetting__c> settingList = [SELECT Name,ASI_CRM_CN_Activity_CodeId__c,ASI_CRM_CN_Contract_Mapping_Field__c FROM ASI_CRM_CN_FixedMappingSetting__c];
        Map<String,Decimal> perfcestAmountMap = new Map<String,Decimal>();
        if(LLastContract != null && LLastContract.size()==1){
            cont.Name= LLastContract[0].Name;
            for (ASI_CRM_CN_FixedMappingSetting__c setting : settingList) {
                cont.put(setting.ASI_CRM_CN_Contract_Mapping_Field__c, LLastContract[0].get(setting.ASI_CRM_CN_Contract_Mapping_Field__c));
                perfcestAmountMap.put(setting.ASI_CRM_CN_Activity_CodeId__c,(Decimal)cont.get(setting.ASI_CRM_CN_Contract_Mapping_Field__c));
            }
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
            if (cont.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                if (cont.ASI_CRM_CN_PO_Version__c=='0.0') {
                    cont.ASI_CRM_CN_CTD_Monthly_Default_Date__c = null;
                } else {
                    cont.ASI_CRM_CN_CTD_Monthly_Default_Date__c = LLastContract[0].ASI_CRM_CN_CTD_Monthly_Default_Date__c;
                }
            }
            
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
            update cont;

            if (cont.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();
                for (ASI_CRM_Module__c module : [SELECT Id, ASI_CRM_CN_Expected_Est_Total__c,
                                                        ASI_CRM_CN_AC_Code__c, ASI_CRM_Contract__c,
                                                        ASI_CRM_Line_Type__c, ASI_CRM_Volume_Base__c
                                                 FROM ASI_CRM_Module__c
                                                 WHERE ASI_CRM_Contract__c =: cont.Id
                                                 AND ASI_CRM_Line_Type__c = 'Fixed']) {
                    if (perfcestAmountMap.containsKey(module.ASI_CRM_CN_AC_Code__c)) {
                        module.ASI_CRM_CN_Expected_Est_Total__c = perfcestAmountMap.get(module.ASI_CRM_CN_AC_Code__c);
                        moduleList.add(module);
                    }
                }
                if (moduleList != null && moduleList.size() > 0) {
                    update moduleList;
                }
            }
            
        }
        if(cont.ASI_CRM_CN_Status__c== 'Final'){
            //update cont;
            //---- original child objects ----
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = [Select id from ASI_CRM_CN_Contract_BRSF_Line_Item__c where ASI_CRM_CN_Contract__c = :cont.id];
            if(LBRSF != null && LBRSF.size()>0)
                delete LBRSF;        
            List<ASI_CRM_Contract_Cost__c> LContractCost = [Select id from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :cont.id];
            if(LContractCost.size()>0)
                delete LContractCost;
            List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet = [Select id from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :cont.id];
            if(LCoveredOutlet.size()>0)
                delete LCoveredOutlet;
            List<ASI_CRM_Approval_Comment__c> LComment = [Select id from ASI_CRM_Approval_Comment__c where ASI_CRM_Contract__c = :cont.id];
            if(LCoveredOutlet.size()>0)
                delete LComment;
            // Change lookup for archived child record
            LBRSF = [Select id, ASI_CRM_CN_Contract__c  from ASI_CRM_CN_Contract_BRSF_Line_Item__c where ASI_CRM_CN_Contract__c = :LLastContract[0].id];
            if(LBRSF.size()>0){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c itm : LBRSF){itm.ASI_CRM_CN_Contract__c = cont.id; }  
                Update LBRSF;
            }      
            LContractCost = [Select id from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :LLastContract[0].id];
            if(LContractCost.size()>0){
                for(ASI_CRM_Contract_Cost__c itm : LContractCost ){ itm.ASI_CRM_CN_Contract__c = cont.id; }  
                Update LContractCost;
            } 
            LCoveredOutlet = [Select id from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :LLastContract[0].id];
            if(LCoveredOutlet.size()>0){
                for(ASI_CRM_CN_Covered_Outlet__c itm : LCoveredOutlet ){
                    itm.ASI_CRM_CN_Contract__c = cont.id; 
                }  
                Update LCoveredOutlet;
            }
            
            LComment = [Select id from ASI_CRM_Approval_Comment__c where ASI_CRM_Contract__c = :LLastContract[0].id];
            if(LComment.size()>0){
                for(ASI_CRM_Approval_Comment__c itm : LComment ){
                    itm.ASI_CRM_Contract__c = cont.id; 
                }  
                Update LComment;
            }
            
            // Change to draft before deleting to comply with only draft can be deleted
            list<ASI_TH_CRM_Contract__c> ContractsNotDraft = new list<ASI_TH_CRM_Contract__c>();
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
            ASI_TH_CRM_Contract__c Contract = [select id,ASI_CRM_CN_Last_Approved_Date__c from ASI_TH_CRM_Contract__c where Id=:ContractSelected.Id];
            List<Attachment> AttachmentList  = new List<Attachment>();
            if(Contract.ASI_CRM_CN_Last_Approved_Date__c!=null){
                AttachmentList = [select id,createdDate  from Attachment WHERE ParentId = : ContractSelected.Id and createdDate >: Contract.ASI_CRM_CN_Last_Approved_Date__c ];
            }else{
                AttachmentList = [select id,createdDate  from Attachment WHERE ParentId = : ContractSelected.Id ];
            }
            
            if(AttachmentList.size()>0){
                ContractSelected.ASI_CRM_CN_Contract_Upload__c=true;
                update ContractSelected;
                PageReference pageRef = new PageReference('/'+PageId);
                pageRef.setRedirect(True);
                return pageRef;
            }else{
                Msg+=System.Label.ASI_CRM_CN_Upload_Contract_Msg;
                UpsertPermission=false;
                return Null;
            }            
        }catch(dmlException e){
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in UploadCompletion class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );return Null;
        }
        
        
        
    }
    
    
    public PageReference UncheckContractUploading(){
        try{
            ContractSelected.ASI_CRM_CN_Contract_Upload__c=false;
            update ContractSelected;
            PageReference pageRef = new PageReference('/'+PageId);
            pageRef.setRedirect(True);
            return pageRef;
            
        }catch(dmlException e){
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in UploadCompletion class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );return Null;
        } 
        
    }
    
    public PageReference SetToDraft(){
        try{
            ContractSelected.ASI_CRM_CN_Status__c='Draft';
            update ContractSelected;
            
            //Sending Final email template to Contract Owner
            User ContractOwner = [Select id, Email from User Where id= :ContractSelected.ownerId ];
            String templateApiName='ASI_CRM_CN_Heavy_Contract_DraftEmail';
            List <String> ToAddresses=  new List <String>();
            id  templateId = [select id, name from EmailTemplate where developername = : templateApiName].id; 
            ToAddresses.add(ContractOwner.email);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setTargetObjectId(ContractSelected.ownerId);
            email.setToAddresses( ToAddresses ); 
            email.setWhatId(ContractSelected.Id);
            email.setSaveAsActivity(false);
            email.setBccSender(false);
            email.setUseSignature(false);
            email.setTemplateId(templateId);
            if(!Test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            
        }catch(dmlException e){
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in SetToDraft class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );
        }
        return null;
    }    
    

    public PageReference SetToFinal(){
        try{
            
            ASI_TH_CRM_Contract__c Contract = [select id,ASI_CRM_Last_RBA_Approver__c from ASI_TH_CRM_Contract__c where Id=:ContractSelected.Id];
            User u =[select id,BypassTriggers__c from user where Id=:UserInfo.getUserId()]; // select id,BypassTriggers__c from user where Id='005M0000006Ghih'
            Boolean BypassFlag= false;
            if(u.BypassTriggers__c!=null && u.BypassTriggers__c.contains('CNSetToFinal')){
                BypassFlag=true;
            }
            
            if(Contract.ASI_CRM_Last_RBA_Approver__c==null ){
                Msg+=System.Label.ASI_CRM_CN_Cant_Find_RBA_Msg;
                UpsertPermission=false;
                return Null;
            }else if( Contract.ASI_CRM_Last_RBA_Approver__c!=UserInfo.getUserId() && !BypassFlag){
                Msg+='You are not RBA, cannot change this contract to Final.';
                UpsertPermission=false;
                return Null;
            }else{
                ContractSelected.ASI_CRM_CN_Status__c='Final';
                update ContractSelected;
                
                PageReference pageRef = new PageReference('/'+PageId);
                pageRef.setRedirect(True);
                return pageRef;
            }
            
            
            return Null;
            
        }catch(dmlException e){
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in UploadCompletion class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );return Null;
        }
        
    }
    
    public PageReference GoReturn(){
        List<ASI_TH_CRM_Contract__c> LContract = [Select ASI_CRM_CN_Return_Comments__c from ASI_TH_CRM_Contract__c where id=:PageId LIMIT 1]; 
        if(LContract[0].ASI_CRM_CN_Return_Comments__c != ''){
            try{
                LContract[0].ASI_CRM_CN_Return_Comments__c = '';
                update LContract[0];
            }catch(dmlException e){
                    ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ViewHeavyContractCtrl<br/> in GoReturn class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Contract Id: '+PageId );
            }
        }
        
        
        PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_HeavyReturnContractByBAPage?scontrolCaching=1&id='+PageId);
        pageRef.setRedirect(True);
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
        IF(LINE_ITEM_NEWRECORD_COUNTER == null) {
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
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    
    
    //*******************************************************************************************************
    //* @description custom class for PSF
    // ********************************************************************************************************
    public Class interimData{
        public ASI_CRM_Module__c Module {set;get;} 
        public map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}
        public String MethodologyValue  {set;get;} {MethodologyValue='';}
        
        public interimData(){
            Module=new ASI_CRM_Module__c();
            this.MethodologyValue='';
            DetailLineMap= new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        public interimData( ASI_CRM_Module__c ModuleInput){
            Module=ModuleInput;
            this.MethodologyValue='';
            DetailLineMap= new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        
        
    }
    
    //Cancel the record 
    public PageReference CancelProcess(){
        PageReference pageRef = null;
        pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef; 
    }
    

    
    
}