public with sharing class ASI_CRM_CN_ContractEmailCtrl {
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public string isTest1 {set;get;}
    public string isTestDate1 {set;get;}
    public string isTest {set;get;}
    public string isTestDate {set;get;}
    public String PageId {set;get;}
    public set<string> PromotionTypeFilter {set;get;}
    public map<string, string> SubbrandGroup = new map<string, string>();
    public map<integer, string> MonthMapping = new map<integer, string>();
    public set<id> thisCC_Subbrand {get;set;}
    public decimal PriorityBrand {set;get;}
    //Highlight output cell
    public string td_prefix {set;get;}
    public string td_end {set;get;}
    public string highlight1_td_prefix {set;get;}
    public string highlight2_td_prefix {set;get;}
    public decimal strpb {set;get;}
    Transient string color1 {set;get;}
    Transient string color2 {set;get;}
    public string strTitle {set;get;}
    public decimal THVarGap {set;get;}
    public decimal THFixGap {set;get;}
    public string positiveGreen {set;get;}
    public string negativeRed {set;get;}
    public string normalBlack {set;get;}
    public string positiveGreen_bottom {set;get;}
    public string negativeRed_bottom {set;get;}
    public string normalBlack_bottom {set;get;}
    public String fixedDescription {set;get;}
    
    //20160623 Ben @ Elufa
    Public Boolean isFE{Get; Set;}
    
    public set<id> AllOutlet {set;get;}
    
    public ASI_TH_CRM_Contract__c PreviousCC {set;get;}
    public list<ASI_CRM_Subbrand_Volume__c> PreviousCC_SBVolumeList {set;get;}
    private set<id> PreviousCC_Subbrand {get;set;}
    public decimal POMVariance {set;get;}
    
    public string thisCCStart {set;get;}
    public string thisCCEnd {set;get;}
    public string previousCCStart {set;get;}
    public string previousCCEnd {set;get;}
    public decimal previousCCNoMonths {set;get;}
    public string previousCCSalesRep {set;get;}
    public string InitPreviousCCStart {set;get;}
    public string InitPreviousCCEnd {set;get;}
    public string InitPreviousCCSalesRep {set;get;}
    public decimal InitPreviousCCNoMonths {set;get;}
    Transient decimal TotalHC_VolumeBtl {set;get;}
    
    public ASI_TH_CRM_Contract__c thisCC {set;get;}
    private list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> thisCC_BRSFList {set;get;}

    public CalculateData VolumeData {set;get;}
    public CalculateData MarginperBottle {set;get;}
    public CalculateData MarginAP {set;get;}
    public CalculateData InvestmentCR12 {set;get;}
    public CalculateData TradeExpense {set;get;}
    public CalculateData VExpense {set;get;}
    public CalculateData FExpense {set;get;}
    public CalculateData FExpenseRate {set;get;}
    public CalculateData GrossSales {set;get;}
    public CalculateData GrossSalesTotal {set;get;}
    public CalculateData CMTotal {set;get;}
    public CalculateData ROI {set;get;}
    public CalculateData latestBudgetCMTotal {set;get;} // Added by Alan Wong (Elufa) 20150618
    public CalculateData ProForma_ROI {set;get;} // Added by Alan Wong (Elufa) 20150618
    public map<string, map<string,decimal>> RegionSubBrandCM_Map = new map<string,map<string,decimal>>(); // Added by Alan Wong (Elufa) 20150618
    public map<string, decimal> ProForma_LatestBudgetCM = new map<string, decimal>(); // Added by Alan Wong (Elufa) 20150618
    public CalculateData VarExp_AllProducts {set;get;}
    public CalculateData FixExp_Total {set;get;}
    public CalculateData VarExp_Total {set;get;}
    public map <string, subbrand_data> current_sbDataROI_map{set;get;}
    public map <string, subbrand_data> historical_sbDataROI_map{set;get;}
    public map<string, decimal> latest_actualcm = new map<string, decimal>();
    public map<string, decimal> latest_actualgs = new map<string, decimal>();
    private map<id, decimal> EstVolume_map {set;get;}
    private map<id, decimal> ConVolume_map {set;get;}
    
    public map<string, CalculateData> sbGroup_map {set;get;}
    public map<string, map<string, CalculateData>> sbVarExp {set;get;}
    
    //private list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> CS_list {set;get;}
    private map<id, integer> CS_Sbmap {set;get;}
    public map<string, CalculateData> FixExpense_Map {set;get;}
    public map<string, CalculateData> VarExpense_Map {set;get;}
    //20160615 Ben @ Elufa
    //for Season Expense
    Public Map<String, ASI_CRM_Contract_Cost__c> mapSeasonExpense_Fix {Set; Get;}
    Public Map<String, ASI_CRM_Contract_Cost__c> mapSeasonExpense_Var {Set; Get;}
    Public List<Decimal> mapSeasonExpense_subTotal {Set; Get;}
    Public List<Decimal> seasonExpenseDiff_Total {Set; Get;}
    Public Map<String, CalculateData> mapSeasonExpense_Diff {Set; Get;}
    
    //Set up CutOff Date
    public date CutOffDay {set;get;}
    public integer strCutOffDay {set;get;}
    
    //AD or Above Identity checking
    public boolean ADorAbove {set;get;}
    public string UserId {set;get;}
    public string strPDF {set;get;}
    //PO MOdification Investment CR12 
    public CalculateData InvestmentCR12_POM {set;get;}
    public CalculateData ROI_POM {set;get;}
    public decimal THAmount {set;get;}
    public decimal strv0FixCost {set;get;}
    public decimal strv0VarCost {set;get;}
    public decimal ActVSEst_Vol {set;get;}
    public decimal THGap {set;get;}
    
    //add PO Summary to PO Modification PDF 
    public list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> paymentRequestSummary {set;get;}
    public decimal PS_TotalPOEstAmt {set;get;}
    public decimal PS_TotalPORemainAmt {set;get;}
    public decimal PS_TotalPODeltaAmt {set;get;}
    public decimal PS_TotalPaidAmt {set;get;}
    public decimal PS_TotalLastEstAmt {set;get;}
    
    public decimal Mod_VCost {set;get;}
    
    //get Contract Approval Comments
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}
    public String ApprovalComment {set;get;}
        
    //V0 Contract Data
    public ASI_TH_CRM_Contract__c PreviousV0CC {set;get;}
    public list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PreviousV0CC_BRSFList {set;get;}
    public map <string, subbrand_data> historicalV0_sbDataROI_map{set;get;}
    public set<id> pV0CC_Subbrand {set;get;}
    private map<string, decimal> pV0_EstVolume_map {set;get;}
    public decimal pV0CC_numOfMonth {set;get;}
    
    //Added by Twinkle 20141201 - BC %
    public CalculateData BCRate {set;get;}
    public CalculateData NetBCRate {set;get;}
    public decimal pV0CC_bcRate {set;get;}
    
    //Added by Twinkle - 20141204 - Check empty
    public boolean checkNotEmpty_VarExp {set;get;}
    public boolean checkNotEmpty_VarExp_Total {set;get;}
    public boolean checkNotEmpty_FixExp_Total {set;get;}
    public boolean boolCheckCCPeriod {set;get;}
    public boolean boolVariableCost {set;get;}
    public boolean boolFixedCost {set;get;}
    public ASI_CRM_CN_ContractEmailCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
        isTest1 = ApexPages.currentPage().getParameters().get('test');
        isTestDate1 = ApexPages.currentPage().getParameters().get('cutoff');
        if (PageId != null){
            try{
                thisCC = [SELECT id, Name, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, 
                          ASI_CRM_CN_Vol_Budget_LE__c,ASI_CRM_CN_PO_Modification__c,
                          ASI_CRM_CN_Contract_Est_Var_Cost_Total__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                          ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,  ASI_CRM_CN_PO_End_Date__c,
                          ASI_CRM_CN_PO_No__c, ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
                          ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                          ASI_CRM_CN_Contract_Variable_Cost_Total__c,ASI_CRM_CN_No_of_Months__c,
                          ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c, 
                          ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,ASI_CRM_CN_Total_Contract_Amount__c,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c, ASI_CRM_CN_Description__c, 
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
                          ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                          ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                          ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
                          ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                          ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                          ASI_CRM_CN_V0_0_PO_version__c, Owner.Name,
                          ASI_CRM_CN_Status__c , ASI_CRM_Volume_Option__c,
                          ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                          ASI_CRM_CN_Bottle_Collection_Rate__c,
                          ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,//20160614 Ben @ Elufa
                          ASI_CRM_PO_Channel__r.Name, ASI_CRM_PO_Province__r.Name//20160614 Ben @ Elufa
                          ,ASI_CRM_PO_City__c //20160619 Ben @ Elufa
                          ,ASI_CRM_PO_City__r.Name //20160619 Ben @ Elufa
                          ,ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c //20160619 Ben @ Elufa
                          FROM ASI_TH_CRM_Contract__c WHERE id = :PageId];
            }catch(exception e){
                thisCC = new ASI_TH_CRM_Contract__c();
                PreviousCC = new ASI_TH_CRM_Contract__c();
            }
        }else{
            thisCC = new ASI_TH_CRM_Contract__c();
            PreviousCC = new ASI_TH_CRM_Contract__c();
        }
        system.debug('thisCC:'+thisCC);
        system.debug('thisCC.ASI_CRM_CN_PO_Start_Date__c:'+thisCC.ASI_CRM_CN_PO_Start_Date__c);
    }
    public ASI_CRM_CN_ContractEmailCtrl(){
    }

    public boolean init(){
        //20160623 Ben @ Elufa
        isFE = FALSE;
        
        /*********************************  SET UP CUTOFF DATE ************************************/
        strCutOffDay = 16;
        positiveGreen = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        negativeRed = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        normalBlack = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        positiveGreen_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        negativeRed_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        normalBlack_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        //AD Identity checking
        if (strPDF == '1')
            checkUserID();
        if (strPDF == '0')
            checkApprover();
        
        //Covered Outlet
        AllOutlet = new set<id>();
        //html table <td> </td> highlight prefix
        td_prefix = '<td style="border-right:1px solid black;" valign="top">';
        td_end = '</td>';
        highlight1_td_prefix = '<td style="border-right:1px solid black;" bgcolor="#FF7171" valign="top">';
        highlight2_td_prefix = '<td style="border-right:1px solid black;" bgcolor="#66FFFF" valign="top">';
        color1 = 'bgcolor="#FF7171"';
        color2 = 'bgcolor="#66FFFF"';
        strpb = 0;
        
        //Promotion Type Filter (New Contract On/Off no PO Start/End Date overlap)
        set<string> PromotionTypeFilter = new set<string>();
        PromotionTypeFilter.add('New Contract ON');
        PromotionTypeFilter.add('New Contract OFF');
        PromotionTypeFilter.add('Contract ON');
        PromotionTypeFilter.add('Contract OFF');
        
        //Only these Promotion type need to find historical contract
        set<string> PromotionTypes = new set<string>();
        PromotionTypes.add('RTD ON');
        PromotionTypes.add('RTD OFF');
        PromotionTypes.add('New Contract ON');
        PromotionTypes.add('New Contract OFF');
        //20160125 Ben @ Elufa
        PromotionTypes.add('New Contract E-Commerce');
        //20160614 Ben @ Elufa
        PromotionTypes.add('Contract ON');
        PromotionTypes.add('Contract OFF');
        PromotionTypes.add('Contract E-Commerce');
        
        //2016614 Ben @ Elufa
        //For New FY PO, Used for related Old Promotion Type
        Set<String> oldPromotionTypes = new Set<String>();
        
        //-------------------------------------------------------------------------
        //Sub-Brand Grade Grouping
        //Updated by Twinkle 20141127 - billingual
        SubbrandGroup.put('Premium', '1. Standard + Premium 标准档 + 高档');
        SubbrandGroup.put('Standard', '1. Standard + Premium 标准档 + 高档');
        SubbrandGroup.put('Prestige', '4. Prestige + Ultra Prestige 奢华档 + 特级奢华档');
        SubbrandGroup.put('Ultra Prestige', '4. Prestige + Ultra Prestige 奢华档 + 特级奢华档');
        SubbrandGroup.put('Super Premium', '2. Super Premium 超高档');
        SubbrandGroup.put('Ultra Premium', '3. Ultra Premium 特级高档');
        SubbrandGroup.put('Not Specified','0. Not Specified');
        
        //------------------------------------------------------------------------- 
        //Month Mapping
        MonthMapping.put(1,'Jan');
        MonthMapping.put(2,'Feb');
        MonthMapping.put(3,'Mar');
        MonthMapping.put(4,'Apr');
        MonthMapping.put(5,'May');
        MonthMapping.put(6,'Jun');
        MonthMapping.put(7,'Jul');
        MonthMapping.put(8,'Aug');
        MonthMapping.put(9,'Sept');
        MonthMapping.put(10,'Oct');
        MonthMapping.put(11,'Nov');
        MonthMapping.put(12,'Dec');
        //-------------------------------------------------------------------------     
        
        init_Data();
        
        if (thisCC!= null){
            
            //20160614 Ben @ Elufa For New FY PO, Add Related Old Promotion Type in PromotionTypes
            if(thisCC.ASI_CRM_New_FY_PO__c){// && PromotionTypes.contains(thisCC.ASI_TH_CRM_Promotion_Type__c)){20170315 Elufa
                List<ASI_CRM_Special_Promotion_Type_Mapping__c> promtionTypeMappingList = new List<ASI_CRM_Special_Promotion_Type_Mapping__c>([SELECT id
                                                                                                                                               , ASI_CRM_Mapping_of_New_Promotion_Type__c
                                                                                                                                               , ASI_CRM_Mapping_of_Old_Promotion_Type__c
                                                                                                                                               , ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c
                                                                                                                                               , ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c
                                                                                                                                               FROM ASI_CRM_Special_Promotion_Type_Mapping__c
                                                                                                                                               WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Special_Promotion_Type_Mapping'
                                                                                                                                               AND ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c = : thisCC.ASI_TH_CRM_Promotion_Type__c
                                                                                                                                              ]);
                if(promtionTypeMappingList.size() > 0){
                    for(ASI_CRM_Special_Promotion_Type_Mapping__c obj : promtionTypeMappingList){
                        PromotionTypes.add(obj.ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
                        PromotionTypes.add(obj.ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c);//20170205 Elufa if there is mapping record, add into historical prmotion type set
                        oldPromotionTypes.add(obj.ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
                    }
                }
            }
            //20160614 End
            
            //Added by Twinkle - 20141202 - Check contract period of last & modified version
            if(thisCC != null && thisCC.ASI_CRM_CN_Last_PO_version__c !=null){
                if(thisCC.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c == thisCC.ASI_CRM_CN_PO_Start_Date__c && thisCC.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c == thisCC.ASI_CRM_CN_PO_End_Date__c){
                    boolCheckCCPeriod = true;
                }
                else{
                    boolCheckCCPeriod = false;system.debug('thisCC.ASI_CRM_CN_PO_Start_Date__c:'+thisCC.ASI_CRM_CN_PO_Start_Date__c);
                }
            }
            //End by Twinkle - 20141202
            
            //Added by Twinkle 11/25/2014 - BA Comments
            lstApprovalComment = [SELECT id, recordtypeid, ASI_CRM_BA_comments__c, ASI_CRM_Background_Objective__c, ASI_CRM_New_contract_Analsysis__c, ASI_CRM_Historical_Contract_Performance__c FROM ASI_CRM_Approval_Comment__c 
                                  WHERE ASI_CRM_Contract__c =:thisCC.id];  
            if(lstApprovalComment==null || lstApprovalComment.size()==0){
                ApprovalComment ='';
                lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
            }
            else{
                lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
                for(ASI_CRM_Approval_Comment__c ac : lstApprovalComment){
                    if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')){
                        ApprovalComment = 'new';
                        lstApprovalComment[0] = ac;
                    }
                    else if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')){
                        ApprovalComment = 'po';
                        lstApprovalComment[0] = ac;
                        break;
                    }
                }
            }
            //End by Twinkle 11/25/2014
                                  
            //Added by William Yang(Introv) 20141024 to fix issue #151
            if(thisCC.ASI_CRM_CN_Description__c != null && thisCC.ASI_CRM_CN_Description__c != '')
            {
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\,', '\\, ');
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\，', '\\， ');
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\.', '\\. ');
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\。', '\\。 ');
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\;', '\\; ');
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\；', '\\； ');
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\:', '\\: ');
                thisCC.ASI_CRM_CN_Description__c = thisCC.ASI_CRM_CN_Description__c.replaceAll('\\：', '\\： ');
            }
            //End William Yang (Introv)20141024 
            if (thisCC.ASI_CRM_CN_PO_Version__c == '0.0'){
                strTitle = 'PO Application Form';
            }else{
                strTitle = 'PO Modification Form';
            }
            //Add Covered outlet id
            // Added by Alan Wong (Elufa) 20150626
            if (thisCC.ASI_CRM_CN_PO_Version__c != '0.0') {
                string tempPageId = thisCC.id;
                ASI_TH_CRM_Contract__c tempCC = [SELECT id, Name, ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_Contract__c WHERE id = :tempPageId];
                if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || tempCC.ASI_CRM_Volume_Option__c == null){
                    AllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
                }
                if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Covered Outlet Only'  || tempCC.ASI_CRM_Volume_Option__c == null) {
                    for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :thisCC.id]){
                        AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c); 
                    }
                }
            }
            // -- End --//
            else {
                AllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :thisCC.id]){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
            CutOffDay = CutOffDate(strCutOffDay); // 0 = ASI_CRM_CN_PO_End_Date__c
            if (thisCC.ASI_CRM_CN_PO_Start_Date__c != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null){
                set<string> subP_set = checkFiscalYear(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
                for (ASI_CRM_CN_Channel_Strategy_Line_Item__c cs : [SELECT ASI_CRM_CN_Brand__c, ASI_CRM_CN_Sub_brand__c
                       FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c
                       WHERE ASI_CRM_CN_Channel_Strategy__r.ASI_CRM_CN_Image__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c
                       AND ASI_CRM_CN_Channel_Strategy__r.ASI_CRM_CN_Area__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c
                       AND ASI_CRM_CN_Channel_Strategy__r.ASI_CRM_CN_Fiscal_Year__c IN :subP_set
                       AND ASI_CRM_CN_Channel_Strategy__r.ASI_CRM_CN_Sub_Channel__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c
                       AND (ASI_CRM_CN_Brand__c = 'Priority 1' OR ASI_CRM_CN_Brand__c = 'Priority 2')]){
                    if (cs.ASI_CRM_CN_Brand__c == 'Priority 1')
                        CS_Sbmap.put(cs.ASI_CRM_CN_Sub_brand__c, 1);
                    if (cs.ASI_CRM_CN_Brand__c == 'Priority 2')
                        CS_Sbmap.put(cs.ASI_CRM_CN_Sub_brand__c, 2);
                }
            }
            
           
            //Total Variable Cost (Estimate & Contract)
            if (thisCC.ASI_CRM_CN_PO_Start_Date__c != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null && thisCC.ASI_TH_CRM_Promotion_Type__c != null){
                //Criteria to get last contract     
                if (PromotionTypeFilter.contains(thisCC.ASI_TH_CRM_Promotion_Type__c)){
                    //Added by Twinkle - 20150116
                    Integer strDays = 365/12*6; //Criteria within 6 Months (from PO start date)
                    Date strDate = thisCC.ASI_CRM_CN_PO_Start_Date__c - strDays;
                    //End by Twinkle 20150116
                    try{
                        PreviousCC = [SELECT id, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                                      ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                                      ASI_CRM_CN_Contract_Variable_Cost_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                                      ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c, 
                                      ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                                      ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                      ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                                      ASI_CRM_CN_Bottle_Collection_Rate__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                                      ASI_CRM_New_FY_PO__c, ASI_CRM_CN_Status__c
                                      FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_Outlet_WS__c = :thisCC.ASI_CRM_CN_Outlet_WS__c
                                      AND ASI_CRM_CN_PO_End_Date__c != null AND ASI_CRM_CN_PO_Start_Date__c != null
                                      AND ASI_CRM_CN_PO_End_Date__c <= :thisCC.ASI_CRM_CN_PO_Start_Date__c
                                      AND ASI_CRM_CN_PO_End_Date__c >= :strDate
                                      AND ASI_TH_CRM_Promotion_Type__c IN :PromotionTypes
                                      AND (ASI_TH_CRM_Promotion_Type__c = :thisCC.ASI_TH_CRM_Promotion_Type__c
                                           OR ASI_TH_CRM_Promotion_Type__c IN : oldPromotionTypes
                                          )//20160614 Ben @ Elufa added OR ASI_TH_CRM_Promotion_Type__c IN : oldPromotionTypes
                                      AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived' OR ASI_CRM_CN_Status__c = 'Submitted') //20170120, edited by Leo, add status = submitted
                                      //ORDER BY ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_Version__c DESC LIMIT 1];//20170315 Elufa
                                      ORDER BY ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_PO_Version__c DESC LIMIT 1];
                    }catch(exception e){
                        PreviousCC = new ASI_TH_CRM_Contract__c();
                        system.debug('Try Exception (PreviousCC): ' + e);
                    }
                    
                }else{
                    try{
                        Integer strDays = 365/12*6; //Criteria within 6 Months (from PO start date)
                        Date strDate = thisCC.ASI_CRM_CN_PO_Start_Date__c - strDays;    
                        PreviousCC = [SELECT id, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                                      ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                                      ASI_CRM_CN_Contract_Variable_Cost_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                                      ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c, 
                                      ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                                      ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                      ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                                      ASI_CRM_CN_Bottle_Collection_Rate__c,
                                      ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                                      ASI_CRM_New_FY_PO__c, ASI_CRM_CN_Status__c
                                      FROM ASI_TH_CRM_Contract__c WHERE //id =:thisCC.ASI_CRM_CN_Last_PO_version__c
                                      ASI_CRM_CN_Outlet_WS__c = :thisCC.ASI_CRM_CN_Outlet_WS__c
                                      AND ASI_CRM_CN_PO_End_Date__c != null AND ASI_CRM_CN_PO_Start_Date__c != null
                                      AND ASI_CRM_CN_PO_End_Date__c <= :thisCC.ASI_CRM_CN_PO_Start_Date__c
                                      AND ASI_CRM_CN_PO_End_Date__c >= :strDate
                                      AND ASI_TH_CRM_Promotion_Type__c IN :PromotionTypes
                                      AND (ASI_TH_CRM_Promotion_Type__c = :thisCC.ASI_TH_CRM_Promotion_Type__c
                                           OR ASI_TH_CRM_Promotion_Type__c IN : oldPromotionTypes
                                          )//20160614 Ben @ Elufa added OR ASI_TH_CRM_Promotion_Type__c IN : oldPromotionTypes
                                      AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived' OR ASI_CRM_CN_Status__c = 'Submitted') //20170120, edited by Leo, add status = submitted
                                      //ORDER BY ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_Version__c DESC LIMIT 1];//20170315 Elufa
                                      ORDER BY ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_PO_Version__c DESC LIMIT 1];
                    }catch(exception e){
                        PreviousCC = new ASI_TH_CRM_Contract__c();
                    }
                    
                }
            }else{
                PreviousCC = new ASI_TH_CRM_Contract__c();
            }
            //20170120, edited by Leo
            if(PreviousCC!=null && PreviousCC.ASI_CRM_CN_Status__c == 'Archived')
            {
                
                Integer strDays = 365/12*6; //Criteria within 6 Months (from PO start date)
                Date strDate = thisCC.ASI_CRM_CN_PO_Start_Date__c - strDays;
                String v0Id = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c == Null ? PreviousCC.id : PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;

                List<ASI_TH_CRM_Contract__c> checkLatest 
                    = new List<ASI_TH_CRM_Contract__c>([SELECT id, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                                                        ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                                                        ASI_CRM_CN_Contract_Variable_Cost_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c, 
                                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c,
                                                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                                                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                                                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                                                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                                                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                                                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                                        ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                                                        ASI_CRM_CN_Bottle_Collection_Rate__c,
                                                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                                                        ASI_CRM_New_FY_PO__c, ASI_CRM_CN_Status__c
                                                        FROM ASI_TH_CRM_Contract__c 
                                                        WHERE ASI_CRM_CN_V0_0_PO_version__c = : v0Id
                                                        AND ASI_CRM_CN_Status__c != 'Draft'
                                                        AND (NOT ASI_CRM_CN_Status__c Like 'FY Landing Archive')
                                                        AND ASI_CRM_CN_PO_End_Date__c != null AND ASI_CRM_CN_PO_Start_Date__c != null
                                                        Order By createddate DESC limit 1
                                                       ]);
                if(checkLatest.size()>0)
                {
                    if(checkLatest[0].ASI_CRM_CN_PO_End_Date__c <= thisCC.ASI_CRM_CN_PO_Start_Date__c && checkLatest[0].ASI_CRM_CN_PO_End_Date__c >= strDate){
                        PreviousCC = checkLatest[0];
                    }else{
                        PreviousCC = new ASI_TH_CRM_Contract__c();
                    }
                }
            }
            //20170120, edited by Leo
            
            // Added By Alan Wong(Elufa) 20150619
            // get latest Budget CM for all Sub-Brands
            string currentFY = String.valueOf(FYConversion(date.Today()).Year());
            string currentFY2 = (integer.valueOf(currentFY) - 1) + '';
            string currentFY3 = (integer.valueOf(currentFY) - 2) + ''; //20170301 Elufa comment
            string ProductCode;
            string Region;
            Id pccRegion = PreviousCC != Null && PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != Null ? PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c : Null;
            Id thisccRegion = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            decimal cm;
            map<string, decimal> newItem;
            map<string, decimal> newItem2;
            for (ASI_CRM_CM_GS__c lbcm : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c
                                          FROM ASI_CRM_CM_GS__c
                                          WHERE ASI_CRM_CN_Month__c = 6 
                                          AND (ASI_CRM_YEAR__c = :currentFY
                                              OR ASI_CRM_YEAR__c = :currentFY2 //20170109 Elufa
                                              OR ASI_CRM_YEAR__c = :currentFY3)//20170109 Elufa
                                          AND (ASI_CRM_Region__c = : pccRegion//20170109 Elufa
                                               OR ASI_CRM_Region__c = : thisccRegion)//20170109 Elufa
                                          AND (ASI_CRM_TYPE__c = 'Budget CM')
                                          AND ASI_CRM_CM_GS_per_9L__c != Null//20170109 Elufa
                                          AND ASI_CRM_CM_GS_per_9L__c != 0//20170109 Elufa
                                          ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ]){
                                              ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
                                              Region = lbcm.ASI_CRM_Region__c;
                                              if (lbcm.ASI_CRM_CM_GS_per_9L__c == null){
                                                  cm = 0;
                                              }else{
                                                  cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
                                              }
                                              if (!RegionSubBrandCM_Map.containsKey(Region)){
                                                  newItem = new map<string, decimal>();
                                                  //Fix for HPSM IM52771
                                                  if (lbcm.ASI_CRM_CM_GS_per_9L__c != null && lbcm.ASI_CRM_CM_GS_per_9L__c != 0){//20160905 Ben @ Elufa
                                                      newItem.put(ProductCode, cm);
                                                      RegionSubBrandCM_Map.put(Region,newItem) ;   
                                                  }
                                              }else if(!RegionSubBrandCM_Map.get(Region).containsKey(ProductCode)){
                                                  //Fix for HPSM IM52771
                                                  if (lbcm.ASI_CRM_CM_GS_per_9L__c != null && lbcm.ASI_CRM_CM_GS_per_9L__c != 0)//20160905 Ben @ Elufa
                                                      RegionSubBrandCM_Map.get(Region).put(ProductCode,cm);
                                              }
                                          }
            system.debug('RegionSubBrandCM_Map:::' + RegionSubBrandCM_Map);
            // -- End -- // 
            
            //get thisCC Data
            getthisCCData(); //20170109 Elufa
            
            if (thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c != null){
                BCRate.strB = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
                BCRate.strD = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            }else{
                BCRate.strB = 0;
                BCRate.strD = 0;
            }
            //End by Twinkle 20141201
            if (thisCC.ASI_CRM_CN_Vol_Budget_LE__c != null){
                VolumeData.strE = thisCC.ASI_CRM_CN_Vol_Budget_LE__c;
            }else{
                VolumeData.strE = 0;
            }
            if (VolumeData.strE != null && VolumeData.strB != null){
                VolumeData.strF = VolumeData.strE - VolumeData.strB;
            }
            if (thisCC.ASI_CRM_CN_Budget_LE__c != null){
                TradeExpense.strE = thisCC.ASI_CRM_CN_Budget_LE__c;//decimal.valueof(thisCC.ASI_CRM_CN_Budget_LE__c);
            }else{
                TradeExpense.strE = 0;
            }
            if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null)
                if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH()))
                thisCCStart = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
            else
                thisCCStart = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + (thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH();
            if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null)
                if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH()))
                thisCCEnd = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
            else
                thisCCEnd = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + (thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH();
              
            if (thisCC.ASI_CRM_CN_Contract_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Cost_Total__c != null)
                TradeExpense.strD += thisCC.ASI_CRM_CN_Contract_Cost_Total__c;
            
            if (thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                FExpense.strB = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            
            //Trade Expenses, Esitmate               
            if (thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0 &&  thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0){
                TradeExpense.strB += thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;  
            } 
            if (TradeExpense.strE != null && TradeExpense.strB != null){
                TradeExpense.strF = TradeExpense.strE - TradeExpense.strB;
            }
            
            if (PreviousCC.id != null){
                //Contract Version Final Start & End Date
                if (previousCC.ASI_CRM_CN_PO_Start_Date__c!= null)
                    if (MonthMapping != null && MonthMapping.containskey((previousCC.ASI_CRM_CN_PO_Start_Date__c).MONTH()))
                        previousCCStart = (previousCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((previousCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                else
                    previousCCStart = (previousCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + (previousCC.ASI_CRM_CN_PO_Start_Date__c).MONTH();
                if (previousCC.ASI_CRM_CN_PO_End_Date__c!= null)
                    if (MonthMapping != null && MonthMapping.containskey((previousCC.ASI_CRM_CN_PO_End_Date__c).MONTH()))
                        previousCCEnd = (previousCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((previousCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
                else
                    previousCCEnd = (previousCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + (previousCC.ASI_CRM_CN_PO_End_Date__c).MONTH();       
                
                if(previousCC.Owner != null)
                    PreviousCCSalesRep = previousCC.Owner.Name;

                if (previousCC.ASI_CRM_CN_No_of_Months__c != null)
                    PreviousCCNoMonths = previousCC.ASI_CRM_CN_No_of_Months__c;
                
                //-----------------
                
                //Contract Version 0.0 Start & End Date
                if (strPDF == '0' || thisCC.ASI_CRM_CN_PO_Version__c == '0.0')
                    getPreviousCCData();
            }else{
                PreviousCC_SBVolumeList = new list<ASI_CRM_Subbrand_Volume__c>();
            }            
            finalize_data();
            LoopSubbrand_data();
        }else{
            thisCC = new ASI_TH_CRM_Contract__c();
            PreviousCC = new ASI_TH_CRM_Contract__c();
            thisCC_BRSFList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            PreviousV0CC_BRSFList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        
        system.debug(paymentRequestSummary);
        return true;
    }
    //************************** HISTORICAL CONTRACT DATA *****************************************//
    public void getPreviousCCData(){
        string sbName;
        string SbGradeName = null;
        string SBGradeGroup = null;
        string SBGradeSort = '0000';
        decimal strAVol9L;
        decimal strA = 0;
        decimal strA2 = 0;
        decimal strTotalA = 0;
        boolean highlight1 = false;
        boolean highlight2 = false;
        decimal strD2 = 0;
        
        //Added by Twinkle 20141128 - V0 Historical Contract Data
        map<date, decimal> PreviousV0CC_Period_map = new map<date, decimal>();
        string IdPreviousV0CC = null;
        string strRegion;
        date strStartBGDate;
        date strEndBGDate;
        date startDate;
        date endDate;
        decimal estvol;
        decimal pV0CC_EstimateCostTotal;
        decimal pV0CC_FixedCost;
        decimal totalCM;
        decimal totalGS;
        
        if(PreviousCC != null && PreviousCC.id != null && PreviousCC.ASI_CRM_CN_V0_0_PO_version__c == null){
            IdPreviousV0CC = PreviousCC.id;
            if(PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                pV0CC_EstimateCostTotal = PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
            if(PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                pV0CC_FixedCost = PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            if(PreviousCC.ASI_CRM_CN_No_of_Months__c != 0 &&  PreviousCC.ASI_CRM_CN_No_of_Months__c != null)
                pV0CC_numOfMonth = PreviousCC.ASI_CRM_CN_No_of_Months__c;
            if(PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null)
                strRegion = PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            if(PreviousCC.ASI_CRM_CN_PO_Start_Date__c != null){
                strStartBGDate = getEndDate(PreviousCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
                startDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c;
            }
            if(PreviousCC.ASI_CRM_CN_PO_End_Date__c != null){
                strEndBGDate = getEndDate(PreviousCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
                endDate = PreviousCC.ASI_CRM_CN_PO_End_Date__c;
            }
            if(PreviousCC.ASI_CRM_CN_Bottle_Collection_Rate__c != null)
                pV0CC_bcRate = PreviousCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            
        }
        else if(PreviousCC != null && PreviousCC.ASI_CRM_CN_V0_0_PO_version__c != null){
            IdPreviousV0CC = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;
            if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                pV0CC_EstimateCostTotal = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
            if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)   
                pV0CC_FixedCost = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != null)
                pV0CC_numOfMonth = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c;
            if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null)
                strRegion = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c != null){
                strStartBGDate = getEndDate(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
                startDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c;
            }
            if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c != null){
                strEndBGDate = getEndDate(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
                endDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c;
            }
            if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c != null)
                pV0CC_bcRate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c;
        }
        else{
            IdPreviousV0CC = null;
        }
        
        if(pV0CC_EstimateCostTotal != null && pV0CC_EstimateCostTotal != 0)
            TradeExpense.strV0 = pV0CC_EstimateCostTotal;
        
        if(IdPreviousV0CC != null){
            PreviousV0CC_BRSFList = [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,
                                     ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, 
                                     ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                                     ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                     ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                     ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                                     ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                     FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c =:IdPreviousV0CC ];
        }
        
        if(PreviousV0CC_BRSFList != null && PreviousV0CC_BRSFList.size() > 0){
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c a : PreviousV0CC_BRSFList){        
                CalculateData data = new CalculateData();
                decimal strV0 = 0;
                decimal strV02 = 0;
                decimal strE2 = 0;
                decimal TotalV0 = 0;                 
                decimal strCR12Factor = 0;

                if (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && a.ASI_CRM_CN_No_of_Months__c != null){
                    VolumeData.strV0 += (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c* a.ASI_CRM_CN_No_of_Months__c);
                    strV0 = (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c * a.ASI_CRM_CN_No_of_Months__c);
                }else{
                    strV0 = 0;
                }
                
                //Sub Brand Grade
                if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null)
                    sbGradeName = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                else
                    sbGradeName = 'Not Specified';
                
                //get Sub Brand Grade Grouping (refer to Map: SubbrandGroup)
                if (SubbrandGroup.containskey(sbGradeName)){
                    SBGradeGroup = SubbrandGroup.get(sbGradeName);
                }
                if (sbGroup_map.containskey(SBGradeGroup)){
                    if(sbGroup_map.get(SBGradeGroup).strV0 == null)
                        sbGroup_map.get(SBGradeGroup).strV0 = strV0;
                    else
                        sbGroup_map.get(SBGradeGroup).strV0 += strV0;
                }else{
                    data.strV0 = strV0; //V0.0 Contract - Estimate Volume
                    sbGroup_map.put(SBGradeGroup, data);
                }       
                
                if (a.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                    strV02 = a.ASI_CRM_CN_Est_Monthly_Qty__c;
                }else{
                    strV02 = 0;
                }
                
                if (a.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null){
                    //Table 2 (Estimate Fees / Bottle)
                    strE2 = a.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                }else{
                    strE2 = 0;
                }

                if (strV02 != null && strE2!= null && pV0CC_numOfMonth != null){
                    //Total Estimate Fees
                    TotalV0 = strV02 * strE2 * pV0CC_numOfMonth;
                }
                else{
                    TotalV0 = 0;
                }
                
                //Variable Expenses (ALL PRODUCTS)
                VarExp_AllProducts.strV0 += strV02;

                //Trade Expenses
                TradeExpense.strV0 += TotalV0;            
                //Variable Expenses
                VExpense.strV0 += TotalV0;
                
                pV0CC_Subbrand.add(a.ASI_CRM_CN_Sub_Brand__c);
                //Volume 9L for ROI
                estvol = 0;
                if (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null)
                    estvol = a.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                if (pV0_EstVolume_map.containskey(a.ASI_CRM_CN_Sub_Brand__c)){
                    estvol += pV0_EstVolume_map.get(a.ASI_CRM_CN_Sub_Brand__c);
                    pV0_EstVolume_map.put(a.ASI_CRM_CN_Sub_Brand__c, estvol);
                }else{
                    pV0_EstVolume_map.put(a.ASI_CRM_CN_Sub_Brand__c, estvol);
                }
                
                //CR12 Conversion Factor
                if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != 0 && a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null)
                    strCR12Factor = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                else
                    strCR12Factor = 1;

                //Table 1 Estimate CR12 / Month
                if (a.ASI_CRM_CN_Est_Monthly_Qty__c != null)
                    InvestmentCR12.strV0 += a.ASI_CRM_CN_Est_Monthly_Qty__c * strCR12Factor * a.ASI_CRM_CN_No_of_Months__c;
            }
            if (InvestmentCR12.strV0 != 0 && InvestmentCR12.strV0 != null && TradeExpense.strV0 != 0 && TradeExpense.strV0 != null)
                InvestmentCR12.strV0 = TradeExpense.strV0 / InvestmentCR12.strV0;
            else
                investmentCR12.strV0 =0 ;
        }
        
        //Fixed and Viable Costs 
        if(IdPreviousV0CC != null){
            for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c
                                                    FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :IdPreviousV0CC]){
                decimal strV0 = 0;
                
                if (ccost.ASI_CRM_CN_Estimate_Amount__c != null){
                    strV0 = ccost.ASI_CRM_CN_Estimate_Amount__c;
                }else{
                    strV0 = 0;
                }
                if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                    FExpense.strV0 += strV0;
                }
                if (ccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                    VExpense.strV0 += strV0;
                }
                
            }
        }
        if(pV0CC_FixedCost != null){
            FExpense.strV0 = pV0CC_FixedCost;
        }
        
        PreviousV0CC_Period_map = checkFYDayPeriod(startDate, endDate);        
        system.debug(startDate);
        system.debug(endDate);
        system.debug(PreviousV0CC_Period_map);
        if (PreviousV0CC_Period_map != null && PreviousV0CC_Period_map.size() > 0){
            string strkey_p;
            date strDateCC;
            for (date previousV0CCdate : PreviousV0CC_Period_map.keyset() ){
                strDateCC = FYConversion(previousV0CCdate);
                if (pV0CC_Subbrand != null && pV0CC_Subbrand.size() > 0){
                    for (id sbid : pV0CC_Subbrand){
                        strkey_p = string.valueof(strDateCC) + sbid ;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = PreviousV0CC_Period_map.get(previousV0CCdate);
                        newitem.sbname = sbid;
                        newitem.TotalVolume = 0;
                        newitem.TotalEstVolume = 0;
                        historicalV0_sbDataROI_map.put(strkey_p, newitem);
                        system.debug(strkey_p+':'+newitem);
                    }
                }
            }
        }
        
        // Budget CM / GS for Historical V0 Contract       
        String strkey_v0;
        Date strCMdate;
        totalCM = 0;
        totalGS = 0;
        
        //20170109 Elufa
        date strStartBGDate2 = date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
        date strEndBGDate2 = date.newInstance(strEndBGDate.year(), 6, 30);
        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
        //20170109 End
        
        for (ASI_CRM_CM_GS__c pV0bcm : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,
                                        ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                        , ASI_CRM_CN_Month__c
                                        FROM ASI_CRM_CM_GS__c
                                        WHERE ASI_CRM_PRODUCTCODE__c IN :pV0CC_Subbrand 
                                        AND ASI_CRM_Region__c = :strRegion
                                        AND (
                                        (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate
                                        AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate )
                                        OR (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 //20170109 Elufa
                                        AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2//20170109 Elufa
                                        AND ASI_CRM_CN_Month__c = 6 )//20170109 Elufa
                                        )
                                        AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                                        AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0//20170109 Elufa
                                        ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ]){
            strCMdate = pV0bcm.ASI_CRM_CN_Month_End_Date__c;
            strkey_v0 = string.valueof(strCMdate) + pV0bcm.ASI_CRM_PRODUCTCODE__c;
            
            //20170109 Elufa
            if(pV0bcm.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(pV0bcm.ASI_CRM_PRODUCTCODE__c + pV0bcm.ASI_CRM_TYPE__c) && pV0bcm.ASI_CRM_CM_GS_per_9L__c != null && pV0bcm.ASI_CRM_CM_GS_per_9L__c != 0){
                cmgsMap.put(pV0bcm.ASI_CRM_PRODUCTCODE__c + pV0bcm.ASI_CRM_TYPE__c, pV0bcm);
            }
            //20170109 End
            
            //Budget CM
            if (pV0bcm.ASI_CRM_TYPE__c == 'Budget CM'){
                //whichContract = 'Estimate';
                if (pV0bcm.ASI_CRM_CM_GS_per_9L__c != null)
                    totalCM = pV0bcm.ASI_CRM_CM_GS_per_9L__c;
                if (historicalV0_sbDataROI_map.containskey(strkey_v0)){
                    if (historicalV0_sbDataROI_map.get(strkey_v0).CM == null || historicalV0_sbDataROI_map.get(strkey_v0).CM == 0){//20170207 Elufa
                        //Fix for HPSM IM52771
                        if (pV0bcm.ASI_CRM_CM_GS_per_9L__c != null && pV0bcm.ASI_CRM_CM_GS_per_9L__c != 0){//20160905 Ben @ Elufa
                            historicalV0_sbDataROI_map.get(strkey_v0).CM = totalCM;
                        }
                    }
                }
            }
            //Budget GS
            if (pV0bcm.ASI_CRM_TYPE__c == 'Budget GS'){
                //whichContract = 'Estimate';
                if(pV0bcm.ASI_CRM_CM_GS_per_9L__c != null)
                    totalGS = pV0bcm.ASI_CRM_CM_GS_per_9L__c;
                if (historicalV0_sbDataROI_map.containskey(strkey_v0)){
                    if (historicalV0_sbDataROI_map.get(strkey_v0).GS == null || historicalV0_sbDataROI_map.get(strkey_v0).GS == 0){//20170207 Elufa
                        //Fix for HPSM IM52771
                        if(pV0bcm.ASI_CRM_CM_GS_per_9L__c != null && pV0bcm.ASI_CRM_CM_GS_per_9L__c != 0){//20160905 Ben @ Elufa
                            historicalV0_sbDataROI_map.get(strkey_v0).GS = totalGS;
                        }
                    }
                }
            }
            if (historicalV0_sbDataROI_map.containskey(strkey_v0)){
                if (historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM == null || historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM == 0){//20170207 Elufa
                    if (RegionSubBrandCM_Map.containsKey(pV0bcm.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(pV0bcm.ASI_CRM_Region__c).containsKey(pV0bcm.ASI_CRM_PRODUCTCODE__c)){
                        historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM = RegionSubBrandCM_Map.get(pV0bcm.ASI_CRM_Region__c).get(pV0bcm.ASI_CRM_PRODUCTCODE__c);
                    }
                }
            }
            totalCM = 0;
            totalGS = 0;
        }
        
        //20170109 Elufa to replace null value with latest CMGS data
        for(String key : historicalV0_sbDataROI_map.keySet()){
            if(historicalV0_sbDataROI_map.get(key).CM == Null || historicalV0_sbDataROI_map.get(key).CM == 0 || historicalV0_sbDataROI_map.get(key).GS == Null || historicalV0_sbDataROI_map.get(key).GS == 0 || historicalV0_sbDataROI_map.get(key).latestBudgetCM == Null || historicalV0_sbDataROI_map.get(key).latestBudgetCM == 0){
                if((historicalV0_sbDataROI_map.get(key).CM == Null || historicalV0_sbDataROI_map.get(key).CM == 0) && cmgsMap.containsKey(historicalV0_sbDataROI_map.get(key).sbname + 'Budget CM')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(historicalV0_sbDataROI_map.get(key).sbname + 'Budget CM');
                    
                    historicalV0_sbDataROI_map.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }
                
                if((historicalV0_sbDataROI_map.get(key).GS == Null || historicalV0_sbDataROI_map.get(key).GS == 0) && cmgsMap.containsKey(historicalV0_sbDataROI_map.get(key).sbname + 'Budget GS')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(historicalV0_sbDataROI_map.get(key).sbname + 'Budget GS');
                    
                    historicalV0_sbDataROI_map.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }
                
                if(historicalV0_sbDataROI_map.get(key).latestBudgetCM == Null || historicalV0_sbDataROI_map.get(key).latestBudgetCM == 0){
                    if(RegionSubBrandCM_Map.containsKey(strRegion) && RegionSubBrandCM_Map.get(strRegion).containsKey(historicalV0_sbDataROI_map.get(key).sbname))
                        historicalV0_sbDataROI_map.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(strRegion).get(historicalV0_sbDataROI_map.get(key).sbname);
                }
            }
        }
        //20170109
        
        //End by Twinkle 20141128
        
        //Added by Twinkle 20141201 - Historical V0 BC % 
        if (pV0CC_bcRate != null){
            BCRate.strV0 = pV0CC_bcRate;
        }else{
            BCRate.strV0 = 0;
        }
        //End by Twinkle 20141201

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c a : [SELECT ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Est_Monthly_Qty__c,
                               ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                               ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Contract_Total__c,
                               ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Total__c ,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
                               ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                               ASI_CRM_CN_Estimate_Volume_9L_Month__c
                               FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.id]){
            PreviousCC_Subbrand.add(a.ASI_CRM_CN_Sub_Brand__c);
            map<string, CalculateData> data2_map = new map<string, CalculateData>();
            CalculateData data2 = new CalculateData();
            //Sub Brand Name
            if (a.ASI_CRM_CN_Sub_Brand__c != null){
                sbName = a.ASI_CRM_CN_Sub_Brand__r.Name;
            }
            //Sub Brand Grade
            if (a.ASI_CRM_CN_Sub_Brand__c != null && a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null)
                sbGradeName = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            else
                sbGradeName = 'Not Specified';
            
            sbGradeSort =  SBGradeSorting(a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGradeName;
            if (CS_Sbmap != null && CS_Sbmap.containskey(a.ASI_CRM_CN_Sub_Brand__c)){
                if (CS_Sbmap.get(a.ASI_CRM_CN_Sub_Brand__c) == 1){
                    highlight1 = true;
                }
                if (CS_Sbmap.get(a.ASI_CRM_CN_Sub_Brand__c) == 2){
                    highlight2 = true;
                }
            }
            //System.debug('hightlight1: ' + highlight1 + ' highlight2: ' + highlight2);
            //Table 2 - Variable Expenses (in RMB) Historical Total Fees
            if (a.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                strA2 = a.ASI_CRM_CN_Est_Monthly_Qty__c;
            }else{
                strA2 = 0;
            }
            
            if (a.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!= null){
                strD2 = a.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
            }else{
                strD2 = 0;
            }
                       
            //Historical Contract Varible Expense + BRSF Estimate
            if (a.ASI_CRM_CN_Est_Total__c!= null){
                strTotalA = a.ASI_CRM_CN_Est_Total__c;
            }else{
                strTotalA = 0;
            }
            //data2.strTotalA = 0; //strTotalA; //Historical Bottles/month
            
            data2.strhighlight1 = highlight1; //hasSubBrand in Priority 1
            data2.strhighlight2 = highlight2; //hasSubBrand in Priority 2
            data2.strA = 0; //strA2;
            data2.strB = 0;
            data2.strC = 0;
            data2.strD = strD2; //Historical Fees/month
            data2.strE = 0;
            data2.strF = 0;
            data2.strTotalA = 0; //strTotalA;
            data2.strTotalB = 0;
            data2.strTotalC = 0;
            data2.strSubBrand = '';
            if (sbVarExp != null && sbVarExp.containskey(sbGradeSort)){
                if (sbVarExp.get(sbGradeSort).containskey(sbName)){
                    //sbVarExp.get(sbGradeSort).get(sbName).strA += strA2;
                    sbVarExp.get(sbGradeSort).get(sbName).strD += strD2;
                    //sbVarExp.get(sbGradeSort).get(sbName).strTotalA += strTotalA;
                    if (sbVarExp.get(sbGradeSort).get(sbName).strhighlight1 != true)
                        sbVarExp.get(sbGradeSort).get(sbName).strhighlight1 = highlight1;
                    if (sbVarExp.get(sbGradeSort).get(sbName).strhighlight2 != true)
                        sbVarExp.get(sbGradeSort).get(sbName).strhighlight2 = highlight2;
                    if (highlight1 == true){
                        sbVarExp.get(sbGradeSort).get(sbName).strformat = highlight1_td_prefix;
                    }else if (highlight2 == true){
                        sbVarExp.get(sbGradeSort).get(sbName).strformat = highlight2_td_prefix;
                    }else if (highlight1 != true && highlight2 != true){
                        sbVarExp.get(sbGradeSort).get(sbName).strformat = td_prefix;
                    }
                }else{
                if(data2.checkNotEmpty())
                    sbVarExp.get(sbGradeSort).put(sbName, data2);
                }
            }else{
            if(data2.checkNotEmpty())
                data2_map.put(sbName, data2);
            if(data2_map != null && data2_map.size() > 0)
                sbVarExp.put(sbGradeSort, data2_map);
            }
            //Table 2 - All Products Historical Fees/month
            VarExp_AllProducts.strD += strD2;
            VExpense.strA += strTotalA;
            TradeExpense.strA += strTotalA;
            VarExp_Total.strTotalA += strTotalA;
        }

        set<id> Previous_AllOutlet = new set<id>();
        // Added by Alan Wong (Elufa) 20150625
        id tempid = PreviousCC.id;
        if (tempid != null){
            ASI_TH_CRM_Contract__c tempCC = [SELECT Name, ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_Contract__c WHERE id = :tempid];
            if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || tempCC.ASI_CRM_Volume_Option__c == null){
                Previous_AllOutlet.add(PreviousCC.ASI_CRM_CN_Outlet_WS__c);
            }
            if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || tempCC.ASI_CRM_Volume_Option__c == null){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.id]){
                    Previous_AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
            system.debug('tempCC.ASI_CRM_Volume_Option__c:::' + tempCC.ASI_CRM_Volume_Option__c); 
        } else {
            Previous_AllOutlet.add(PreviousCC.ASI_CRM_CN_Outlet_WS__c);
            for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.id]){
                Previous_AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
            } 
        }
        // -- End -- //
        date TillEnd;
        if (CutOffDay >= PreviousCC.ASI_CRM_CN_PO_End_Date__c)
            TillEnd = getEndDate(PreviousCC.ASI_CRM_CN_PO_End_Date__c);
        else
            TillEnd = CutOffDay;         
        System.debug('TillEnd (Previous): ' + TillEnd + ' AllOutlet :' + AllOutlet + ' Previous_AllOutlet: ' + Previous_AllOutlet + ' End: ' + PreviousCC.ASI_CRM_CN_PO_Start_Date__c );
        
        try{
            PreviousCC_SBVolumeList = [SELECT id, ASI_CRM_Offtake__c, ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c, ASI_CRM_Cap_with_Issues_Std_Billing__c,
                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.Name,
                                       ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,
                                       ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                                       ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c,
                                       ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,
                                       ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c, ASI_CRM_PR_Direct_STD__c,
                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                       ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
                                       FROM ASI_CRM_Subbrand_Volume__c WHERE 
                                       ASI_CRM_Account__c IN :Previous_AllOutlet 
                                       AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                                       AND ASI_CRM_End_Date__c >= :PreviousCC.ASI_CRM_CN_PO_Start_Date__c
                                       AND ASI_CRM_End_Date__c <= :TillEnd AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE];// = :PreviousCC.ASI_CRM_CN_Outlet_WS__c//20170207 Elufa AND ASI_CRM_CN_Exclude_From_Payment_Volume__c =FALSE //ASI_CRM_Subbrand__c IN :PreviousCC_Subbrand
            if(Test.isRunningTest()){
                PreviousCC_SBVolumeList = [SELECT id, ASI_CRM_Offtake__c, ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c, ASI_CRM_Cap_with_Issues_Std_Billing__c,
                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.Name,
                                       ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,
                                       ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                                       ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c,
                                       ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,
                                       ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c, ASI_CRM_PR_Direct_STD__c,
                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                       ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
                                           FROM ASI_CRM_Subbrand_Volume__c];
            }
        }catch(exception e){
            PreviousCC_SBVolumeList = new list<ASI_CRM_Subbrand_Volume__c>();            
        }
        system.debug('PreviousCC_SBVolumeList: ' + PreviousCC_SBVolumeList );
        
        //get All SB Volume id for Actual CM
        map<date, decimal> PreviousCC_Period_map = checkFYDayPeriod(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
        set<id> PreviousCC_SBId = new set<id>();
        
        String strkey;
        for (ASI_CRM_Subbrand_Volume__c sbid : PreviousCC_SBVolumeList){
            PreviousCC_SBId.add(sbid.ASI_CRM_Subbrand__c);
        }
        for (date PCCperiod: PreviousCC_Period_map.keyset() ){
            if (PreviousCC_SBId.size() > 0){
                for (id sbidtemp : PreviousCC_SBId){
                    strkey = string.valueof(PCCperiod) + sbidtemp;
                    subbrand_data newitem = new subbrand_data();
                    newitem.period = PreviousCC_Period_map.get(PCCperiod);
                    newitem.sbname = sbidtemp;
                    newitem.year = string.valueof(PCCperiod.year());
                    newitem.TotalVolume = 0;
                    historical_sbDataROI_map.put(strkey, newitem);
                }
            }
        }
        date strStartDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        
        totalCM = 0;
        totalGS = 0;
        date CMdate;
        string CMYear;
        string CMRegion;
        //Actual CM/GS for Historical Contract
        for (ASI_CRM_CM_GS__c acm : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c,
                               ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,
                               ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                               FROM ASI_CRM_CM_GS__c
                               WHERE ASI_CRM_PRODUCTCODE__c IN :PreviousCC_SBId 
                               AND ASI_CRM_Region__c = :PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                               //AND ASI_CRM_Sub_Channel__c = :PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c
                               AND ASI_CRM_CN_Month_End_Date__c >= :strStartDate 
                               AND ASI_CRM_CN_Month_End_Date__c <= :TillEnd
                               AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
                               AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0//20170209 Elufa
                               ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ]){
            CMdate = acm.ASI_CRM_CN_Month_End_Date__c;
            strkey = string.valueof(CMdate) + acm.ASI_CRM_PRODUCTCODE__c;
            CMYear = acm.ASI_CRM_PRODUCTCODE__c;
            CMRegion = acm.ASI_CRM_Region__c;
            if (acm.ASI_CRM_CM_GS_per_9L__c != null && acm.ASI_CRM_CM_GS_per_9L__c != 0){//20170109 Elufa
                if (acm.ASI_CRM_TYPE__c == 'YTD CM'){
                    totalCM = acm.ASI_CRM_CM_GS_per_9L__c;
                    if (historical_sbDataROI_map != null && historical_sbDataROI_map.containskey(strkey)){
                        if (historical_sbDataROI_map.get(strkey).CM == null || historical_sbDataROI_map.get(strkey).CM == 0)//20170208 Elufa
                            historical_sbDataROI_map.get(strkey).CM = totalCM;
                        historical_sbDataROI_map.get(strkey).sbname = CMYear;
                        //System.debug('YTD CM: '+acm.id + ' = ' + totalCM );
                    }
                    if (!latest_actualcm.containskey(CMYear)){
                        latest_actualcm.put(CMYear, totalCM);
                    }
                    // Added by Alan Wong (Elufa) 20150619
                    if(!ProForma_LatestBudgetCM.containsKey(CMYear))
                    {
                        if (RegionSubBrandCM_Map.containsKey(CMRegion) && RegionSubBrandCM_Map.get(CMRegion).containsKey(CMYear)){
                            ProForma_LatestBudgetCM.put(CMYear,RegionSubBrandCM_Map.get(CMRegion).get(CMYear));
                        }
                    }
                    // -- End -- //
                }
                if (acm.ASI_CRM_TYPE__c == 'YTD GS'){
                    totalGS = acm.ASI_CRM_CM_GS_per_9L__c;
                    if (historical_sbDataROI_map != null && historical_sbDataROI_map.containskey(strkey)){
                        if (historical_sbDataROI_map.get(strkey).GS == null || historical_sbDataROI_map.get(strkey).GS == 0)//20170208 Elufa
                            historical_sbDataROI_map.get(strkey).GS = totalGS;
                        historical_sbDataROI_map.get(strkey).sbname = CMYear;
                        //System.debug('YTD GS: '+ acm.id + ' = ' + totalGS );
                    } 
                    if (!latest_actualgs.containskey(CMYear)){
                        latest_actualgs.put(CMYear, totalGS);
                    } 
                } 
            }
            // Added by Alan Wong (Elufa) 20150619
            if (historical_sbDataROI_map != null && historical_sbDataROI_map.containskey(strkey)){
                if (historical_sbDataROI_map.get(strkey).latestBudgetCM == null || historical_sbDataROI_map.get(strkey).latestBudgetCM == 0){//20170208 Elufa
                    if (RegionSubBrandCM_Map.containsKey(CMRegion) && RegionSubBrandCM_Map.get(CMRegion).containsKey(CMYear)){
                        historical_sbDataROI_map.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(CMRegion).get(CMYear);
                    }
                }
                historical_sbDataROI_map.get(strkey).sbname = CMYear;
            }
            if(!ProForma_LatestBudgetCM.containsKey(CMYear))
            {
                if (RegionSubBrandCM_Map.containsKey(CMRegion) && RegionSubBrandCM_Map.get(CMRegion).containsKey(CMYear)){
                    ProForma_LatestBudgetCM.put(CMYear,RegionSubBrandCM_Map.get(CMRegion).get(CMYear));
                }
            }
            // -- End --// 
        }
        
        TotalHC_VolumeBtl =0;
        decimal StdBtlVol = 0;
        Integer PeriodA = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
        Integer PeriodB = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
        Integer PeriodDiff = 0;
        if (PeriodA != null && PeriodB != null)
            PeriodDiff = PeriodB - PeriodA;
        if (PeriodDiff < 0 ) PeriodDiff = 0;
        
        date datekey;
        decimal VarHistBtl = 0;
        decimal VarHistTotal = 0;
        decimal strVolTemp = 0;
        decimal VarEmpBtl = 0;
        decimal VarIntakeTotal = 0;
        decimal IssuesCap=0;
        
        for (ASI_CRM_Subbrand_Volume__c b : PreviousCC_SBVolumeList){
            CalculateData data1 = new CalculateData();
            CalculateData data2 = new CalculateData();
            map<string, CalculateData> data2_map = new map<string, CalculateData>();
            datekey = FYConversion(b.ASI_CRM_End_Date__c);
            strkey = string.valueof(datekey) + b.ASI_CRM_Subbrand__c;
            
            //Sub Brand Name
            if (b.ASI_CRM_Subbrand__c != null){
                sbName = b.ASI_CRM_Subbrand__r.Name;    
            }   
            //Sub Brand Grade
            if (b.ASI_CRM_Subbrand__c != null && b.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null)
                sbGradeName = b.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            else
                sbGradeName = 'Not Specified';
            //get Sub Brand Grade Grouping (refer to Map: SubbrandGroup)
            if (SubbrandGroup != null && SubbrandGroup.containskey(sbGradeName)){
                SBGradeGroup = SubbrandGroup.get(sbGradeName);
            }
            //System.debug('SBGradeGroup : ' + SBGradeGroup );
            sbGradeSort =  SBGradeSorting(b.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGradeName;
            //Table 1 - Historical Contract INTAKE = ASI_CRM_T1_Depletion__c + ASI_CRM_T2_Depletion__c (9L cs)
            strA = 0;
            if (b.ASI_CRM_T1_Depletion__c != null)
                strA += b.ASI_CRM_T1_Depletion__c;

            if (b.ASI_CRM_T2_Depletion__c != null){
                strA += b.ASI_CRM_T2_Depletion__c;
            }
            if (b.ASI_CRM_PR_Direct__c != null){
                strA += b.ASI_CRM_PR_Direct__c ;
            }
            if (b.ASI_CRM_Green_Cap_STD__c != null && b.ASI_CRM_Empty_Bottle_Std_Btl__c != null){
                VarEmpBtl += (b.ASI_CRM_Green_Cap_STD__c + b.ASI_CRM_Empty_Bottle_Std_Btl__c);
            }
            IssuesCap+=b.ASI_CRM_Cap_with_Issues_Std_Billing__c !=null?b.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;
   
            //Used for future actualcm calculation
            if (historical_sbDataROI_map != null && historical_sbDataROI_map.containskey(strkey)){
                historical_sbDataROI_map.get(strkey).TotalVolume += strA;
            }

            //Prorated each subbrand Volume
            if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null)
                strA = strA/PeriodA * PeriodB;

            
            //Table 1 - (VolumeData.strA) Volume (in 9L cs) INTAKE (Historical Contract vFinal)
            VolumeData.strA += strA;

            
            //Table 2 - (strA2) Historical Contract Bottles (for Cont.Margin per Bottle)
            strA2 = 0;
            if (b.ASI_CRM_T1_Depletion_STD__c != null){
                strA2 = b.ASI_CRM_T1_Depletion_STD__c ;
            }
            if (b.ASI_CRM_T2_Depletion_STD__c!= null){
                strA2 += b.ASI_CRM_T2_Depletion_STD__c;
            }
            if (b.ASI_CRM_PR_Direct_STD__c!= null){
                strA2 += b.ASI_CRM_PR_Direct_STD__c;
            }
            //2014-07-10 Average Bottle per Month per Subbrand
            VarHistBtl = 0;
            VarHistTotal = strA2;
            VarIntakeTotal += strA2;
            if (PeriodB != null && PeriodB != 0 && VarHistTotal != 0){
                VarHistBtl = VarHistTotal / PeriodA;
            }
            
            //Prorate Bottle
            if (PeriodA != 0 && PeriodB != 0 && PeriodB != null)
                strA2 = strA2/PeriodA * PeriodB;
                        
            TotalHC_VolumeBtl += strA2;
            
            //Table 1 - (InvestmentCR12.strA) CR12 eq btl (ASI_CRM_T1_Depletion_CR12__c + ASI_CRM_T2_Depletion_CR12__c + ASI_CRM_PR_Direct_CR12__c)
            if (b.ASI_CRM_T1_Depletion_CR12__c != null)
                InvestmentCR12.strA += b.ASI_CRM_T1_Depletion_CR12__c;
            if (b.ASI_CRM_T2_Depletion_CR12__c != null)
                InvestmentCR12.strA += b.ASI_CRM_T2_Depletion_CR12__c;
            if (b.ASI_CRM_PR_Direct_CR12__c!= null)
                InvestmentCR12.strA += b.ASI_CRM_PR_Direct_CR12__c;
                 
            //Sub Brand Grade Grouping (Historical Contract vFinal)
            if (sbGroup_map != null && sbGroup_map.containskey(SBGradeGroup)){
                if (sbGroup_map.get(SBGradeGroup).strA != null)
                    sbGroup_map.get(SBGradeGroup).strA += strA;
                else
                    sbGroup_map.get(SBGradeGroup).strA = strA;
            }else{
                data1.strA = strA;
                sbGroup_map.put(SBGradeGroup, data1);
            }
            
            /********************** Table 2 - Historical Contract (sbVarExp) ***************************/   
            //place in map (Variable Expenses subbrand)
            if (sbVarExp != null && sbVarExp.containskey(sbGradeSort)){
                if (sbVarExp.get(sbGradeSort).containskey(sbName)){
                    if (sbVarExp.get(sbGradeSort).get(sbName).strD != null && sbVarExp.get(sbGradeSort).get(sbName).strD != 0){
                        strTotalA = sbVarExp.get(sbGradeSort).get(sbName).strD * VarHistTotal; //strA2;
                    }else{
                        strTotalA = 0;
                    }
                }else{
                    strTotalA = 0;
                }
            }else{
                strTotalA = 0;
            }
            
            //Table 2 2014-07-10 Historical Bottles/month & Total Fees
            data2.strhighlight1 = highlight1; //hasSubBrand in Priority 1
            data2.strhighlight2 = highlight2; //hasSubBrand in Priority 2
            data2.strA = VarHistBtl; //Historical Bottles/month
            data2.strB = 0;
            data2.strC = 0;
            data2.strD = 0; 
            data2.strE = 0;
            data2.strF = 0;
            data2.strTotalA = strTotalA;  //Historical Total Fees
            data2.strTotalB = 0;
            data2.strTotalC = 0;
            data2.strSubBrand = '';
            if (sbVarExp != null && sbVarExp.containskey(sbGradeSort)){
                if (sbVarExp.get(sbGradeSort).containskey(sbName)){
                    sbVarExp.get(sbGradeSort).get(sbName).strA += VarHistBtl; //strA2;
                    if (sbVarExp.get(sbGradeSort).get(sbName).strhighlight1 != true)
                        sbVarExp.get(sbGradeSort).get(sbName).strhighlight1 = highlight1;
                    if (sbVarExp.get(sbGradeSort).get(sbName).strhighlight2 != true)
                        sbVarExp.get(sbGradeSort).get(sbName).strhighlight2 = highlight2;
                    sbVarExp.get(sbGradeSort).get(sbName).strTotalA += strTotalA;
                }else{
                if(data2.checkNotEmpty())
                    sbVarExp.get(sbGradeSort).put(sbName, data2);
                }
            }else{
                if(data2.checkNotEmpty())
                    data2_map.put(sbName, data2);
                if(data2_map != null && data2_map.size() > 0)
                    sbVarExp.put(sbGradeSort, data2_map);
            }
            VarExp_AllProducts.strA += VarHistBtl;
            VarExp_AllProducts.strTotalA += strTotalA;
            //Used to calculate Acheivement Recognition
            VarExp_Total.strD += strTotalA;                       
        }
                
        //Added by Twinkle 20141202 - Rounding (Historical btl/months)
        set<string> remove_keys;
        for (String key : sbVarExp.keySet()) {
            for(String key2 : sbVarExp.get(key).keySet()) {
                sbVarExp.get(key).get(key2).strA = sbVarExp.get(key).get(key2).strA.setScale(0, RoundingMode.HALF_UP);
                
                //Remove RP6 code in sub-brand name
                system.debug('key2:' + key2);
                integer intlength = key2.length();
                integer intRP6 = key2.lastIndexOf('-');    
                system.debug('intlength vs intRP6:' + intlength + '/'+ intRP6);
                if(intlength >= 4){
                    if(intRP6 == (intlength-4) && sbVarExp.get(key) != null && sbVarExp.get(key).get(key2) != null){
                        sbVarExp.get(key).get(key2).strSubBrand = key2.substring(0, (intlength-4));
                    }
                    else{
                        if(sbVarExp.get(key) != null && sbVarExp.get(key).get(key2) != null)
                            sbVarExp.get(key).get(key2).strSubBrand = key2;
                    }
                }
                /* Removed by William Yang(Introv) 20141223
                //Remove empty row
                if(sbVarExp.get(key).get(key2).strA == 0){
                    remove_keys = new set<string>{key2};
                    sbVarExp.get(key).keySet().removeAll(remove_keys);
                }
                */
            }
        }
        //Rounding (All product - Historical btl/months)
        VarExp_AllProducts.strA = VarExp_AllProducts.strA.setScale(0, RoundingMode.HALF_UP);
        //End by Twinkle 20141202
        /********************** END - Table 2 - Historical Contract (sbVarExp) ***************************/
         
        //Prorate Investment CR12 for Historical Contract
        if (PeriodA != 0 && PeriodB!= 0 && PeriodA != null && PeriodB!= null){
            InvestmentCR12.strA = InvestmentCR12.strA/PeriodA * PeriodB;
        }
        
        //Added by Twinkle 20141201 - vFinal BC %
        if(VarEmpBtl != null && VarEmpBtl != 0 && VarIntakeTotal != null && VarIntakeTotal != 0)
            BCRate.strA = (VarEmpBtl / VarIntakeTotal)*100;
        //End by Twinkle 20141201
        
        
        if(VarEmpBtl != null && VarEmpBtl != 0 && VarIntakeTotal != null && VarIntakeTotal != 0){
            NetBCRate.strA = ((VarEmpBtl-IssuesCap) / VarIntakeTotal)*100;
        }else{
            NetBCRate.strA =0;
        }
        
        for (ASI_CRM_Contract_Cost__c pccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c
                                                , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c//20160616 Ben @ Elufa
                                                FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.id]){
                                                    
            if (pccost.ASI_CRM_CN_Estimate_Amount__c != null){
                
                TradeExpense.strA += pccost.ASI_CRM_CN_Estimate_Amount__c;
                //Historical Contract - Fixed Expenses
                if (pccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                    FixExp_Total.strA += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    FExpense.strA += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    CalculateData data0 = new CalculateData();
                    if (FixExpense_Map.containskey(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c)){
                        FixExpense_Map.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).strA += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    }else{
                        data0.strA = pccost.ASI_CRM_CN_Estimate_Amount__c;
                        data0.strB = 0;
                        data0.strC = 0;
                        FixExpense_Map.put(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c, data0);
                    }
                }
                //Historical Contract - Variable Expense
                if (pccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                    VarExp_Total.strTotalA += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    VarExp_Total.strD += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    VExpense.strA += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    
                    //Place VarExpense Total
                    CalculateData data0_var = new CalculateData(pccost.ASI_CRM_CN_Estimate_Amount__c,0,0);
                    if (VarExpense_Map.containskey(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c)){
                        VarExpense_Map.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).strA += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    }else{
                        VarExpense_Map.put(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c, data0_var);
                    }
                }
            }
        }  
    }
    //***************************************** CURRENT CONTRACT **********************************************//
    public void getthisCCData(){
        try{
            thisCC_BRSFList = [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,
                               ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, 
                               ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                               ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                               ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                               ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                               FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :thisCC.id];
        }catch(exception e){
            system.debug('Try Exception (thisCC_BRSFList): ' + e);
            thisCC_BRSFList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        if (thisCC_BRSFList != null && thisCC_BRSFList.size()>0){
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c a : thisCC_BRSFList){
                thisCC_Subbrand.add(a.ASI_CRM_CN_Sub_Brand__c);
            }
        }
        //New Contract Period
        map<date, decimal> thisCC_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        if (thisCC_Period_map != null && thisCC_Period_map.size() > 0){
            string strkey;
            date strDateCC;
            for (date thisCCdate : thisCC_Period_map.keyset() ){
                strDateCC = FYConversion(thisCCdate);
                if (thisCC_Subbrand != null && thisCC_Subbrand.size() > 0){
                    for (id sbid : thisCC_Subbrand){
                        strkey = string.valueof(strDateCC) + sbid ;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = thisCC_Period_map.get(thisCCdate);
                        newitem.sbname = sbid;
                        newitem.TotalVolume = 0;
                        newitem.TotalEstVolume = 0;
                        current_sbDataROI_map.put(strkey, newitem);
                        system.debug(strkey+':'+newitem);
                    }
                }
            }
        }
        //Budget CM
        date strStartBGDate;
        date strEndBGDate;
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_Start_Date__c != null)
            strStartBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null)
            strEndBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
        decimal strB;
        decimal strC;
        //20160616 Ben @ Elufa
        for (ASI_CRM_Contract_Cost__c pccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c
                                                , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c//20160616 Ben @ Elufa
                                                FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = : thisCC.ASI_CRM_CN_Last_PO_version__c]){
                                                    
                                                    
                                                    CalculateData seasonDate = new CalculateData(0, 0, 0, 0, 0, 0);
                                                    seasonDate.strA = pccost.ASI_CRM_CNY_Est__c != NULL ? pccost.ASI_CRM_CNY_Est__c : 0;
                                                    seasonDate.strB = pccost.ASI_CRM_MAF_Est__c != NULL ? pccost.ASI_CRM_MAF_Est__c : 0;
                                                    seasonDate.strC = pccost.ASI_CRM_Other_Est__c != NULL ? pccost.ASI_CRM_Other_Est__c : 0;
                                                    seasonDate.strD = pccost.ASI_CRM_CN_Estimate_Amount__c != NULL ? pccost.ASI_CRM_CN_Estimate_Amount__c : 0;
                                                    
                                                    if(seasonDate.strA != 0 || seasonDate.strB != 0 || seasonDate.strC != 0)
                                                        isFE = TRUE;
                                                    
                                                    if(seasonExpenseDiff_Total.size() > 7){
                                                        seasonExpenseDiff_Total[0] += pccost.ASI_CRM_CNY_Est__c != NULL ? pccost.ASI_CRM_CNY_Est__c : 0;
                                                        seasonExpenseDiff_Total[1] += pccost.ASI_CRM_MAF_Est__c != NULL ? pccost.ASI_CRM_MAF_Est__c : 0;
                                                        seasonExpenseDiff_Total[2] += pccost.ASI_CRM_Other_Est__c != NULL ? pccost.ASI_CRM_Other_Est__c : 0;
                                                        seasonExpenseDiff_Total[3] += pccost.ASI_CRM_CN_Estimate_Amount__c != NULL ? pccost.ASI_CRM_CN_Estimate_Amount__c : 0;
                                                    }
                                                    
                                                    if(mapSeasonExpense_diff.containsKey(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c)){
                                                        
                                                        seasonDate.strA += mapSeasonExpense_diff.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).strA;
                                                        seasonDate.strB += mapSeasonExpense_diff.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).strB;
                                                        seasonDate.strC += mapSeasonExpense_diff.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).strC;
                                                        seasonDate.strD += mapSeasonExpense_diff.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).strD;
                                                        mapSeasonExpense_diff.put(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c, seasonDate);
                                                    }else{
                                                        mapSeasonExpense_diff.put(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c, seasonDate);
                                                    }
                                                    system.debug('seasonDate.strA  ' + seasonDate.strA + '  ' + seasonDate.strB + '  ' + seasonDate.strC + '  ' + seasonDate.strD);
                                                }
        //20160616 End
        
        for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c
                                                , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
                                                FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :thisCC.id]){
                                                    
                                                    //20160616 Ben @ Elufa
                                                    CalculateData seasonDate = new CalculateData(0, 0, 0, 0, 0, 0);
                                                    seasonDate.strE = ccost.ASI_CRM_CNY_Est__c != NULL ? ccost.ASI_CRM_CNY_Est__c : 0;
                                                    seasonDate.strF = ccost.ASI_CRM_MAF_Est__c != NULL ? ccost.ASI_CRM_MAF_Est__c : 0;
                                                    seasonDate.strG = ccost.ASI_CRM_Other_Est__c != NULL ? ccost.ASI_CRM_Other_Est__c : 0;
                                                    seasonDate.strH = ccost.ASI_CRM_CN_Estimate_Amount__c != NULL ? ccost.ASI_CRM_CN_Estimate_Amount__c : 0;
                                                    
                                                    if(seasonDate.strE != 0 || seasonDate.strF != 0 || seasonDate.strG != 0)
                                                        isFE = TRUE;
                                                    
                                                    if(seasonExpenseDiff_Total.size() > 7){
                                                        seasonExpenseDiff_Total[4] += ccost.ASI_CRM_CNY_Est__c != NULL ? ccost.ASI_CRM_CNY_Est__c : 0;
                                                        seasonExpenseDiff_Total[5] += ccost.ASI_CRM_MAF_Est__c != NULL ? ccost.ASI_CRM_MAF_Est__c : 0;
                                                        seasonExpenseDiff_Total[6] += ccost.ASI_CRM_Other_Est__c != NULL ? ccost.ASI_CRM_Other_Est__c : 0;
                                                        seasonExpenseDiff_Total[7] += ccost.ASI_CRM_CN_Estimate_Amount__c != NULL ? ccost.ASI_CRM_CN_Estimate_Amount__c : 0;
                                                    }
                                                    
                                                    if(mapSeasonExpense_diff.containsKey(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c)){
                                                        
                                                        seasonDate.strA = mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strA;
                                                        seasonDate.strB = mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strB;
                                                        seasonDate.strC = mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strC;
                                                        seasonDate.strD = mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strD;
                                                        seasonDate.strE += mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strE;
                                                        seasonDate.strF += mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strF;
                                                        seasonDate.strG += mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strG;
                                                        seasonDate.strH += mapSeasonExpense_diff.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strH;
                                                        system.debug('seasonDate.strC  ' + seasonDate.strA + '  ' + seasonDate.strB + '  ' + seasonDate.strC + '  ' + seasonDate.strD);
                                                        mapSeasonExpense_diff.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c, seasonDate);
                                                    }else{
                                                        mapSeasonExpense_diff.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c, seasonDate);
                                                    }
                                                    system.debug('seasonDate.strB  ' + seasonDate.strA + '  ' + seasonDate.strB + '  ' + seasonDate.strC + '  ' + seasonDate.strD);
                                                    //20160616 End
            
            if (ccost.ASI_CRM_CN_Estimate_Amount__c != null){
                strB = ccost.ASI_CRM_CN_Estimate_Amount__c;
            }else{
                strB = 0;
            }
            if (ccost.ASI_CRM_CN_Contract_Amount__c != null){
                strC = ccost.ASI_CRM_CN_Contract_Amount__c;
            }else{
                strC = 0;
            }
            if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                if (FixExpense_Map != null && FixExpense_Map.containskey(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c)){
                    FixExpense_Map.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strB += strB;
                    FixExpense_Map.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strC += strC;
                }else{
                    FixExpense_Map.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c, new CalculateData(0,strB,strC));
                    
                    //20160615 Ben @ Elufa
                    mapSeasonExpense_Fix.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c, ccost);
                    if(mapSeasonExpense_subTotal.size() > 3){
                        mapSeasonExpense_subTotal[0] += ccost.ASI_CRM_CNY_Est__c != NULL ? ccost.ASI_CRM_CNY_Est__c : 0;
                        mapSeasonExpense_subTotal[1] += ccost.ASI_CRM_MAF_Est__c != NULL ? ccost.ASI_CRM_MAF_Est__c : 0;
                        mapSeasonExpense_subTotal[2] += ccost.ASI_CRM_Other_Est__c != NULL ? ccost.ASI_CRM_Other_Est__c : 0;
                        mapSeasonExpense_subTotal[3] += ccost.ASI_CRM_CN_Estimate_Amount__c != NULL ? ccost.ASI_CRM_CN_Estimate_Amount__c : 0;
                    }
                }
                FixExp_Total.strB += strB;
                FixExp_Total.strC += strC;
                FExpense.strB += strB;
                FExpense.strD += strC;
            }
            if (ccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                Mod_VCost += strB;
                if (VarExpense_Map != null && VarExpense_Map.containskey(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c)){
                    VarExpense_Map.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strB += strB;
                    VarExpense_Map.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).strC += strC;
                    
                }else{
                    VarExpense_Map.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c, new CalculateData(0,strB,strC));
                    
                    //20160615 Ben @ Elufa
                    mapSeasonExpense_Var.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c, ccost);
                    if(mapSeasonExpense_subTotal.size() > 3){
                        mapSeasonExpense_subTotal[0] += ccost.ASI_CRM_CNY_Est__c != NULL ? ccost.ASI_CRM_CNY_Est__c : 0;
                        mapSeasonExpense_subTotal[1] += ccost.ASI_CRM_MAF_Est__c != NULL ? ccost.ASI_CRM_MAF_Est__c : 0;
                        mapSeasonExpense_subTotal[2] += ccost.ASI_CRM_Other_Est__c != NULL ? ccost.ASI_CRM_Other_Est__c : 0;
                        mapSeasonExpense_subTotal[3] += ccost.ASI_CRM_CN_Estimate_Amount__c != NULL ? ccost.ASI_CRM_CN_Estimate_Amount__c : 0;
                    }
                }
                
                VarExp_Total.strTotalB += strB;
                VarExp_Total.strTotalC += strC;
                VExpense.strB += strB;
                VExpense.strD += strC;
            }
        }
        if (thisCC_BRSFList != null && thisCC_BRSFList.size() > 0){
            //for ROI vol 9L without * period
            decimal estvol;
            decimal convol;
            //P&L Review(in RMB) table
            strB = 0;
            decimal strD;
            //Variable Expenses(in RMB) table
            decimal strB2;
            decimal strC2;
            decimal strE2;
            decimal strF2;
            decimal totalB;
            decimal totalC;
            //uses on Investment per CR12 eq btl
            decimal strCR12Factor;
            //shared variables
            string sbGradeName;
            string SBGradeGroup;
            string SBGradeSort;
            string sbName;
            
            boolean highlight1 = false;
            boolean highlight2 = false;
            
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c a : thisCC_BRSFList){
                //P&L Review (in RMB)
                CalculateData data1 = new CalculateData();
                
                //Variable Expenses(in RMB)
                CalculateData data2 = new CalculateData();
                map<string, CalculateData> data2_sbmap = new map<string, CalculateData>();
                
                //Sub Brand Name 
                if (a.ASI_CRM_CN_Sub_Brand__c != null){
                    sbName = a.ASI_CRM_CN_Sub_Brand__r.Name;
                }
                system.debug('thisCC_BRSFList CS_Sbmap: ' + CS_Sbmap);
                
                //Check if Channel Strategy contains sub brand in Priority 1 & 2
                if (CS_Sbmap != null && CS_Sbmap.containskey(a.ASI_CRM_CN_Sub_Brand__c)){
                    if (CS_Sbmap.get(a.ASI_CRM_CN_Sub_Brand__c) == 1){
                        highlight1 = true;
                    }
                    if (CS_Sbmap.get(a.ASI_CRM_CN_Sub_Brand__c) == 2){
                        highlight2 = true;
                    }
                }
                //Sub Brand Grade
                if (a.ASI_CRM_CN_Sub_Brand__c != null && a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null)
                    sbGradeName = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                else
                    sbGradeName = 'Not Specified';
                SBGradeSort = SBGradeSorting(a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGradeName;
                //get Sub Brand Grade Grouping (refer to Map: SubbrandGroup)
                if (SubbrandGroup != null && SubbrandGroup.containskey(sbGradeName)){
                    SBGradeGroup = SubbrandGroup.get(sbGradeName);
                }
                //CR12 Conversion Factor
                if (a.ASI_CRM_CN_Sub_Brand__c != null && a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != 0 && a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null)
                    strCR12Factor = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                else
                    strCR12Factor = 1;

                //Table 1 - Cont. Margin per Bottle: (New Contract - Estimate & Contract)
                if (a.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null){
                    //Table 2 (Estimate Fees / Bottle)
                    strE2 = a.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                }else{
                    strE2 = 0;
                }
                if (a.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null){
                    //Table 2 (Contract Fees / Bottle)
                    strF2 = a.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                }else{
                    strF2 = 0;
                }
                //Table 2 (Estimate Bottles / month)
                if (a.ASI_CRM_CN_Est_Monthly_Qty__c!= null){
                    strB2 = a.ASI_CRM_CN_Est_Monthly_Qty__c;
                    if (highlight1 != false || highlight2 != false)
                        strpb += a.ASI_CRM_CN_Est_Monthly_Qty__c;
                }else{
                    strB2 = 0;
                }
                //Table 1 Estimate CR12 / Month
                if (a.ASI_CRM_CN_Est_Monthly_Qty__c!= null)
                    InvestmentCR12.strB += a.ASI_CRM_CN_Est_Monthly_Qty__c * strCR12Factor * a.ASI_CRM_CN_No_of_Months__c;
                 
                if (a.ASI_CRM_CN_Est_Total__c != null)
                    Mod_VCost += a.ASI_CRM_CN_Est_Total__c;
                //Table 2 (Contract Bottles / Month)
                if (a.ASI_CRM_CN_Contract_Monthly_Qty__c != null){
                    
                    strC2 = a.ASI_CRM_CN_Contract_Monthly_Qty__c;
                }else{
                    strC2 = 0;
                }
                //Table 1 Contract CR12 / Month
                if (a.ASI_CRM_CN_Contract_Monthly_Qty__c != null)
                    InvestmentCR12.strD += a.ASI_CRM_CN_Contract_Monthly_Qty__c * strCR12Factor * a.ASI_CRM_CN_No_of_Months__c;
                
                //Table 1 (Estimate Qty Convert 9L * No of Months) ASI_CRM_CN_Estimate_Volume_9L_Month__c
                if (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && a.ASI_CRM_CN_No_of_Months__c != null){
                    VolumeData.strB += (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c* a.ASI_CRM_CN_No_of_Months__c);
                    strB = (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c * a.ASI_CRM_CN_No_of_Months__c);
                }else{
                    strB = 0;
                }
                //Table 1 Volume 9L (Contract Qty Convert 9L * No of Months) ASI_CRM_CN_Contract_Monthly_Vol9L__c
                if (a.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null && a.ASI_CRM_CN_No_of_Months__c != null){
                    VolumeData.strD += (a.ASI_CRM_CN_Contract_Monthly_Vol9L__c * a.ASI_CRM_CN_No_of_Months__c);
                    strD = (a.ASI_CRM_CN_Contract_Monthly_Vol9L__c * a.ASI_CRM_CN_No_of_Months__c);
                }else{
                    strD = 0;
                }
                //Volume 9L for ROI
                estvol = 0;
                if (a.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null)
                    estvol = a.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                convol = 0;
                if (a.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null)
                    convol = a.ASI_CRM_CN_Contract_Monthly_Vol9L__c;
                
                //Sub Brand Estimate & Contract 9L cs Volume
                if (sbGroup_map != null && sbGroup_map.containskey(SBGradeGroup)){
                    sbGroup_map.get(SBGradeGroup).strB += strB;
                    sbGroup_map.get(SBGradeGroup).strD += strD;
                }else{
                    data1.strB = strB; //New Contract - Estimate Volume
                    data1.strD = strD; //New Contract - Contract Volume
                    sbGroup_map.put(SBGradeGroup, data1);
                }
                //Variable Expenses (in RMB)
                data2.strA = 0;
                data2.strB = strB2; //Estimate Bottles/month
                data2.strC = strC2; //Contract Bottles/month
                data2.strD = 0; 
                data2.strE = strE2; //Estimate Fees/month
                data2.strF = strF2; //Contract Fees/month
                data2.strhighlight1 = highlight1; //hasSubBrand in Priority 1
                data2.strhighlight2 = highlight2; //hasSubBrand in Priority 2
                if (thisCC != null && thisCC.ASI_CRM_CN_No_of_Months__c != null){
                    //Total Estimate Fees
                    TotalB = strB2 * strE2 * thisCC.ASI_CRM_CN_No_of_Months__c;
                    //Total Contract Fees
                    TotalC = strC2 * strF2 * thisCC.ASI_CRM_CN_No_of_Months__c;
                }else{
                    TotalB = 0;
                    TotalC = 0;
                }
                data2.strTotalA = 0;
                data2.strTotalB = TotalB;
                data2.strTotalC = TotalC;
                data2.strSubBrand = '';
                
                //Trade Expenses
                TradeExpense.strB += TotalB;
                TradeExpense.strD += TotalC;
                
                //Variable Expense
                VExpense.strB += TotalB;
                VExpense.strD += TotalC;
                
                //Total Variable Expenses (Include BRSF Cost)
                VarExp_Total.strTotalB += TotalB;
                VarExp_Total.strTotalC += TotalC;
                
                //Variable Expenses (ALL PRODUCTS)
                VarExp_AllProducts.strB += strB2;
                VarExp_AllProducts.strC += strC2;
                VarExp_AllProducts.strE += strE2;
                VarExp_AllProducts.strF += strF2;
                VarExp_AllProducts.strTotalB += TotalB;
                VarExp_AllProducts.strTotalC += TotalC;
                
                //Variable Expenses SB Estimate & Contract
                if (sbVarExp != null && sbVarExp.containskey(sbGradeSort)){
                    if (sbVarExp.get(sbGradeSort).containskey(sbName)){
                        sbVarExp.get(sbGradeSort).get(sbName).strB += strB2;
                        sbVarExp.get(sbGradeSort).get(sbName).strC += strC2;
                        sbVarExp.get(sbGradeSort).get(sbName).strE += strE2;
                        sbVarExp.get(sbGradeSort).get(sbName).strF += strF2;
                        if (sbVarExp.get(sbGradeSort).get(sbName).strhighlight1 != true)
                            sbVarExp.get(sbGradeSort).get(sbName).strhighlight1 = highlight1;
                        if (sbVarExp.get(sbGradeSort).get(sbName).strhighlight2 != true)
                            sbVarExp.get(sbGradeSort).get(sbName).strhighlight2 = highlight2; 
                        if (highlight1 == true){
                            sbVarExp.get(sbGradeSort).get(sbName).strformat = color1;
                        }else if (highlight2 == true){
                            sbVarExp.get(sbGradeSort).get(sbName).strformat = color2;
                        }else if (highlight1 != true && highlight2 != true){
                            sbVarExp.get(sbGradeSort).get(sbName).strformat = '';
                        }
                        sbVarExp.get(sbGradeSort).get(sbName).strTotalB += TotalB;
                        sbVarExp.get(sbGradeSort).get(sbName).strTotalC += TotalC;
                        
                        
                    }else{
                    if(data2.checkNotEmpty())
                        sbVarExp.get(sbGradeSort).put(sbName, data2);
                    }
                }else{
                if(data2.checkNotEmpty())
                    data2_sbmap.put(sbName, data2);
                if(data2_sbmap != null && data2_sbmap.size() > 0)
                    sbVarExp.put(sbGradeSort, data2_sbmap);
                }
                
                //Updated by William Yang(Introv) 20141218
                set<string> remove_keys;
                for (String key : sbVarExp.keySet()) {
                    for(String key2 : sbVarExp.get(key).keySet()) {
                        sbVarExp.get(key).get(key2).strA = sbVarExp.get(key).get(key2).strA.setScale(0, RoundingMode.HALF_UP);
                        
                        //Remove RP6 code in sub-brand name
                        system.debug('key2:' + key2);
                        integer intlength = key2.length();
                        integer intRP6 = key2.lastIndexOf('-');    
                        system.debug('intlength vs intRP6:' + intlength + '/'+ intRP6);
                        if(intlength >= 4){
                            if(intRP6 == (intlength-4) && sbVarExp.get(key) != null && sbVarExp.get(key).get(key2) != null){
                                sbVarExp.get(key).get(key2).strSubBrand = key2.substring(0, (intlength-4));
                            }
                            else{
                                if(sbVarExp.get(key) != null && sbVarExp.get(key).get(key2) != null)
                                    sbVarExp.get(key).get(key2).strSubBrand = key2;
                            }
                        }
                    }
                }
                //End of update by William Yang(Introv) 20141218
                
                //Map for ROI     
                if (ConVolume_map.containskey(a.ASI_CRM_CN_Sub_Brand__c)){
                    convol += ConVolume_map.get(a.ASI_CRM_CN_Sub_Brand__c);
                    ConVolume_map.put(a.ASI_CRM_CN_Sub_Brand__c, convol);
                }else{
                    ConVolume_map.put(a.ASI_CRM_CN_Sub_Brand__c, convol);
                }
                if (EstVolume_map.containskey(a.ASI_CRM_CN_Sub_Brand__c)){
                    estvol += EstVolume_map.get(a.ASI_CRM_CN_Sub_Brand__c);
                    EstVolume_map.put(a.ASI_CRM_CN_Sub_Brand__c, estvol);
                }else{
                    EstVolume_map.put(a.ASI_CRM_CN_Sub_Brand__c, estvol);
                }
                
            }
            
            if (VolumeData.strA != 0 && VolumeData.strB != 0){
                VolumeData.strC = ((VolumeData.strB - VolumeData.strA)/VolumeData.strA)*100;
            }
        }
        thisCC_BRSFList = null;
        decimal totalGS;
        decimal totalCM;
        string strkey;
        date strCMdate;
        
        //20170109 Elufa
        date strStartBGDate2 = date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
        date strEndBGDate2 = date.newInstance(strEndBGDate.year(), 6, 30);
        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
        //20170109 End
        
        // Budget CM / GS for Current Contract
        for (ASI_CRM_CM_GS__c thisbcm : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,
                                         ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                         , ASI_CRM_CN_Month__c
                                         FROM ASI_CRM_CM_GS__c
                                         WHERE ASI_CRM_PRODUCTCODE__c IN :thisCC_Subbrand 
                                         AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                         //AND ASI_CRM_Sub_Channel__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c
                                         AND ((ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate 
                                               AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate )
                                              OR (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 //20170109 Elufa
                                                  AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2//20170109 Elufa
                                                  AND ASI_CRM_CN_Month__c = 6 ))//20170109 Elufa
                                         AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                                         AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != Null
                                         ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ]){
            
            strCMdate = thisbcm.ASI_CRM_CN_Month_End_Date__c;
            strkey = string.valueof(strCMdate) + thisbcm.ASI_CRM_PRODUCTCODE__c;
                                             
            //20170109 Elufa
            if(thisbcm.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c) && thisbcm.ASI_CRM_CM_GS_per_9L__c != null && thisbcm.ASI_CRM_CM_GS_per_9L__c != 0){
                cmgsMap.put(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c, thisbcm);
            }
            //20170109 End

            if (thisbcm.ASI_CRM_TYPE__c == 'Budget CM'){
                //whichContract = 'Estimate';
                if (thisbcm.ASI_CRM_CM_GS_per_9L__c != null){
                    totalCM = thisbcm.ASI_CRM_CM_GS_per_9L__c;
                }
                if (current_sbDataROI_map.containskey(strkey)){
                    if (current_sbDataROI_map.get(strkey).CM == null || current_sbDataROI_map.get(strkey).CM == 0){//20170125 Elufa added || current_sbDataROI_map.get(strkey).CM == 0
                        //Fix for HPSM IM52771
                        if (thisbcm.ASI_CRM_CM_GS_per_9L__c != null && thisbcm.ASI_CRM_CM_GS_per_9L__c != 0){//20160905 Ben @ Elufa
                            current_sbDataROI_map.get(strkey).CM = totalCM;
                        }
                    }
                }
            }
            if (thisbcm.ASI_CRM_TYPE__c == 'Budget GS'){
                //whichContract = 'Estimate';
                if (thisbcm.ASI_CRM_CM_GS_per_9L__c != null){
                    totalGS = thisbcm.ASI_CRM_CM_GS_per_9L__c;
                }
                if (current_sbDataROI_map.containskey(strkey)){
                    if (current_sbDataROI_map.get(strkey).GS == null || current_sbDataROI_map.get(strkey).GS == 0){//20170125 Elufa added || current_sbDataROI_map.get(strkey).GS == 0
                        //Fix for HPSM IM52771
                        if (thisbcm.ASI_CRM_CM_GS_per_9L__c != null && thisbcm.ASI_CRM_CM_GS_per_9L__c != 0){//20160905 Ben @ Elufa
                            current_sbDataROI_map.get(strkey).GS = totalGS;
                        }
                    }
                }
            }
            if (current_sbDataROI_map.containskey(strkey)){
                if (current_sbDataROI_map.get(strkey).latestBudgetCM == null){
                    if (RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_Region__c).containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c))
                        current_sbDataROI_map.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_Region__c).get(thisbcm.ASI_CRM_PRODUCTCODE__c);
                }
            }
            totalCM = 0;
            totalGS = 0;
        }
        
        //20170109 Elufa to replace null/0 value with latest CMGS data
        for(String key : current_sbDataROI_map.keySet()){
            if(current_sbDataROI_map.get(key).CM == Null || current_sbDataROI_map.get(key).CM == 0 || current_sbDataROI_map.get(key).GS == Null || current_sbDataROI_map.get(key).GS == 0 || current_sbDataROI_map.get(key).latestBudgetCM == Null || current_sbDataROI_map.get(key).latestBudgetCM == 0){
                if((current_sbDataROI_map.get(key).CM == Null || current_sbDataROI_map.get(key).CM == 0) && cmgsMap.containsKey(current_sbDataROI_map.get(key).sbname + 'Budget CM')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(current_sbDataROI_map.get(key).sbname + 'Budget CM');
                    
                    current_sbDataROI_map.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }
                
                if((current_sbDataROI_map.get(key).GS == Null || current_sbDataROI_map.get(key).GS == 0) && cmgsMap.containsKey(current_sbDataROI_map.get(key).sbname + 'Budget GS')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(current_sbDataROI_map.get(key).sbname + 'Budget GS');
                    
                    current_sbDataROI_map.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }
                
                if(current_sbDataROI_map.get(key).latestBudgetCM == Null || current_sbDataROI_map.get(key).latestBudgetCM == 0){
                    if(RegionSubBrandCM_Map.containsKey(thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c).containsKey(current_sbDataROI_map.get(key).sbname))
                        current_sbDataROI_map.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c).get(current_sbDataROI_map.get(key).sbname);
                }
            }
        }
        //20170109
    }
    public void finalize_data(){
        //Sb Grouping %vFinal
        for (CalculateData a : sbGroup_map.values()){
            if (a.strB != 0 && a.strA !=0 && a.strB != null && a.strA !=null){
                a.strC = ((a.strB - a.strA)/a.strA)*100;
            }
        }
        //Fixed Expenses %
        system.debug('FExpense.strB: ' + FExpense.strB + ' / TradeExpense.strB: ' + TradeExpense.strB);
        system.debug('FExpense.strD: ' + FExpense.strD + ' / TradeExpense.strD: ' + TradeExpense.strD);
        //Added by Twinkle 20141128
        if (FExpense.strV0 != null && FExpense.strV0 != 0 && TradeExpense.strV0 != null && TradeExpense.strV0 != 0)
            FExpenseRate.strV0 = FExpense.strV0 / TradeExpense.strV0 *100;      
        //End by Twinkle 20141128
        if (FExpense.strB != null && FExpense.strB != 0 && TradeExpense.strB != null && TradeExpense.strB != 0)
            FExpenseRate.strB = FExpense.strB / TradeExpense.strB *100;
        if (FExpense.strD != null && FExpense.strD != 0 && TradeExpense.strD != null && TradeExpense.strD != 0)
            FExpenseRate.strD = FExpense.strD / TradeExpense.strD *100;
        //Historical Contract Fixed Expenses Rate %                        
        if (FExpense.strA != 0 &&  FExpense.strA != 0 && TradeExpense.strA != null &&  TradeExpense.strA != null)
            FExpenseRate.strA = FExpense.strA / TradeExpense.strA * 100;
        //Investment per CR12 eq btl
        if (InvestmentCR12.strA != 0 && InvestmentCR12.strA != null && TradeExpense.strA != 0 && TradeExpense.strA != null){
            InvestmentCR12.strA = TradeExpense.strA / InvestmentCR12.strA;    
        }else{
            investmentCR12.strA = 0;
        }
        system.debug('InvestmentCR12.strA: ' + InvestmentCR12.strA);
        system.debug('InvestmentCR12.strA = ' + TradeExpense.strA + ' / ' + InvestmentCR12.strA);
        if (InvestmentCR12.strB != 0 && InvestmentCR12.strB != null && TradeExpense.strB != 0 && TradeExpense.strB != null)
            InvestmentCR12.strB = TradeExpense.strB / InvestmentCR12.strB;
        else
            investmentCR12.strB =0 ;
        if (InvestmentCR12.strD != 0 && InvestmentCR12.strD != null && TradeExpense.strD != 0 && TradeExpense.strD != null)
            InvestmentCR12.strD = TradeExpense.strD / InvestmentCR12.strD;
        else
            investmentCR12.strD = 0;
        if (InvestmentCR12.strA != 0 && InvestmentCR12.strA != null && InvestmentCR12.strB != 0 && InvestmentCR12.strB != null)
            InvestmentCR12.strC = ((InvestmentCR12.strB - InvestmentCR12.strA) / InvestmentCR12.strA)*100;
        system.debug('InvestmentCR12: ' + InvestmentCR12.strB + ' - ' + InvestmentCR12.strA + ' / ' + InvestmentCR12.strA + '*100' );
        if (investmentCR12.strA != null && InvestmentCR12.strB != null)
            POMVariance = InvestmentCR12.strB - InvestmentCR12.strA;
            
        /********************** Table 1 - vFinal % ***************************/
        //Table 1 Volume (in 9L cs)
        if (VolumeData.strA != null && VolumeData.strB != null && VolumeData.strA != 0 && VolumeData.strB != 0)
            VolumeData.strC = (VolumeData.strB - VolumeData.strA)/VolumeData.strA *100;
        
        //Table 1 Trade Expenses            
        if (TradeExpense.strA != null && TradeExpense.strB != null && TradeExpense.strA != 0 && TradeExpense.strB != 0)
            TradeExpense.strC = (TradeExpense.strB - TradeExpense.strA)/TradeExpense.strA *100;
        
        if (VExpense.strA != null && VExpense.strB != null && VExpense.strA != 0 && VExpense.strB != 0)
            VExpense.strC = (VExpense.strB - VExpense.strA)/VExpense.strA *100;
        if (FExpense.strA != null && FExpense.strB != null && FExpense.strA != 0 && FExpense.strB != 0)
            FExpense.strC = (FExpense.strB - FExpense.strA)/FExpense.strA *100;
        
        /********************** END - Table 1 - vFinal % ***************************/
        //%vFinal Fixed Expense % 
        if (FExpenseRate.strA != 0 && FExpenseRate.strB != 0 && FExpenseRate.strA != null && FExpenseRate.strB != null)
            FExpenseRate.strC = (FExpenseRate.strB/100 - FExpenseRate.strA/100)*100;
        //Acheivement Recognition (Actual Variable Expenses - Estimate Variable Expenses)
        if (VarExp_Total.strTotalA != null && VarExp_Total.strD != null){
            VarExp_Total.strA = VarExp_Total.strD - VarExp_Total.strTotalA;
        }
        
        //Added by Twinkle 20141202
        //VarExp_Total Check empty record
        if((VarExp_Total.strA == null || VarExp_Total.strA == 0) && (VarExp_Total.strB == null || VarExp_Total.strB == 0) && (VarExp_Total.strC == null || VarExp_Total.strC == 0))
            checkNotEmpty_VarExp = false;
        else
            checkNotEmpty_VarExp = true;
        
        //VarExpense_Map check empty record
        for(String key : VarExpense_Map.keySet()){
            VarExpense_Map.get(key).boolCheckEmpty = VarExpense_Map.get(key).checkNotEmpty();
        }
        
        //VarExp_Total check empty record
        if((VarExp_Total.strTotalA == null || VarExp_Total.strTotalA == 0) && (VarExp_Total.strTotalB == null || VarExp_Total.strTotalB == 0) && (VarExp_Total.strTotalC == null || VarExp_Total.strTotalC == 0))
            checkNotEmpty_VarExp_Total = false;
        else
            checkNotEmpty_VarExp_Total = true;
        
        //FixExpense_Map check empty record
        for(String key : FixExpense_Map.keySet()){
            FixExpense_Map.get(key).boolCheckEmpty = FixExpense_Map.get(key).checkNotEmpty();
        }
        
        //FixExp_Total Check empty record
        if((FixExp_Total.strA == null || FixExp_Total.strA == 0) && (FixExp_Total.strB == null || FixExp_Total.strB == 0) && (FixExp_Total.strC == null || FixExp_Total.strC == 0))
            checkNotEmpty_FixExp_Total = false;
        else
            checkNotEmpty_FixExp_Total = true;
        //End by Twinkle 20141202
        
        //Added by Twinkle 20141204
        //Variable Cost / 变动费用 Check empty record
        if((ActVSEst_Vol == null || ActVSEst_Vol == 0) && (Mod_VCost == null || Mod_VCost == 0) && (THVarGap == null || THVarGap == 0))
            boolVariableCost = false;
        else
            boolVariableCost = true;
            
        //Variable Cost / 变动费用 Check empty record
        if((strv0FixCost == null || strv0FixCost == 0) && (thisCC.ASI_CRM_CN_Contract_Fixed_Cost_Total__c == null || thisCC.ASI_CRM_CN_Contract_Fixed_Cost_Total__c == 0) && (THFixGap == null || THFixGap == 0))
            boolFixedCost = false;
        else
            boolFixedCost = true;
        //End by Twinkle 20141204
        
    }
    public void LoopSubbrand_data(){
        //ROI Calculations for Historical
        if (historical_sbDataROI_map != null && historical_sbDataROI_map.size() > 0){
            decimal actualcm;
            decimal lbcm;
            decimal lbcm_prorate;
            decimal actualgs;
            decimal totalactualvol;
            decimal strperiod;
            decimal actualcm_prorate;
            decimal actualgs_prorate;
            date TillEnd;
            
            if (PreviousCC.ASI_CRM_CN_PO_End_Date__c != null && CutOffDay >= PreviousCC.ASI_CRM_CN_PO_End_Date__c)
                TillEnd = getEndDate(PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            else
                TillEnd = CutOffDay;
                
            Integer PeriodA_prorate = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            Integer PeriodB_prorate = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            Integer PeriodD_prorate = PeriodB_prorate - PeriodA_prorate;
            
            for (string hctemp : historical_sbDataROI_map.keyset()){
                strperiod= null;
                if (historical_sbDataROI_map.get(hctemp).period != null){
                    strperiod = historical_sbDataROI_map.get(hctemp).period;
                }
                //Actual CM
                actualcm = null;
                if (historical_sbDataROI_map.get(hctemp).CM != null && historical_sbDataROI_map.get(hctemp).CM != 0){//20170208 Elufa
                    actualcm = historical_sbDataROI_map.get(hctemp).CM;
                }else{/*comment by wilson*/
                    if (latest_actualcm != null && latest_actualcm.containskey(historical_sbDataROI_map.get(hctemp).sbname)){
                        actualcm = latest_actualcm.get(historical_sbDataROI_map.get(hctemp).sbname);
                    }
                    //actualcm = 0;
                }
                //Latest Budget CM
                lbcm = null;
                if (historical_sbDataROI_map.get(hctemp).latestBudgetCM != null){
                    lbcm = historical_sbDataROI_map.get(hctemp).latestBudgetCM;
                }else{/*comment by wilson*/
                    if (ProForma_LatestBudgetCM != null && ProForma_LatestBudgetCM.containskey(historical_sbDataROI_map.get(hctemp).sbname)){
                        lbcm = ProForma_LatestBudgetCM.get(historical_sbDataROI_map.get(hctemp).sbname);
                    }
                }
                //Actual GS
                actualgs = null;
                if (historical_sbDataROI_map.get(hctemp).GS != null && historical_sbDataROI_map.get(hctemp).GS != 0){//20170208 Elufa
                    actualgs = historical_sbDataROI_map.get(hctemp).GS;
                }else{/* comment by wilson*/
                    if (latest_actualcm != null && latest_actualgs.containskey(historical_sbDataROI_map.get(hctemp).sbname)){
                        actualgs = latest_actualgs.get(historical_sbDataROI_map.get(hctemp).sbname);
                    }
                    //actualgs = 0;
                }
                //Total Volume
                totalactualvol = null;
                if (historical_sbDataROI_map.get(hctemp).TotalVolume != null){
                    totalactualvol = historical_sbDataROI_map.get(hctemp).TotalVolume;
                }
                if (totalactualvol != null && actualcm != null ){ //& strperiod != null){
                    CMTotal.strA += actualcm * totalactualvol; // * strperiod;
                }
                // Added by Alan Wong (Elufa) 20150618
                if (totalactualvol != null && lbcm != null ){
                    latestBudgetCMTotal.strA += lbcm * totalactualvol;
                }
                // -- End -- //
                actualcm_prorate = 0;
                if (latest_actualcm != null && latest_actualcm.containskey(historical_sbDataROI_map.get(hctemp).sbname)){
                    actualcm_prorate = latest_actualcm.get(historical_sbDataROI_map.get(hctemp).sbname);
                }  
                //Added by Alan Wong (Elufa) 20150619
                lbcm_prorate = 0;
                if (ProForma_LatestBudgetCM != null && ProForma_LatestBudgetCM.containskey(historical_sbDataROI_map.get(hctemp).sbname)){
                    lbcm_prorate = ProForma_LatestBudgetCM.get(historical_sbDataROI_map.get(hctemp).sbname);
                } 
                // -- End --//
                if (PeriodA_prorate != null && PeriodA_prorate != 0 && totalactualvol != null && totalactualvol != 0 && PeriodD_prorate != null && actualcm_prorate != null)
                    CMTotal.strA += actualcm_prorate * totalactualvol / PeriodA_prorate * PeriodD_prorate;
                // Added by Alan Wong (Elufa) 20150618
                if (PeriodA_prorate != null && PeriodA_prorate != 0 && totalactualvol != null && totalactualvol != 0 && PeriodD_prorate != null && lbcm_prorate != null){
                    latestBudgetCMTotal.strA += lbcm_prorate * totalactualvol / PeriodA_prorate * PeriodD_prorate;
                }
                // -- End -- //    
                if (totalactualvol != null && actualgs != null){ // & strperiod != null){
                    GrossSalesTotal.strA += actualgs * totalactualvol; // * strperiod;
                    system.debug('Historical Gross Sales: ' + historical_sbDataROI_map.get(hctemp).sbname + ' ' + actualgs + ' * ' + totalactualvol ); //+ ' * ' + strperiod);
                }
                actualgs_prorate = 0;
                if (latest_actualcm != null && latest_actualgs.containskey(historical_sbDataROI_map.get(hctemp).sbname)){
                    actualgs_prorate = latest_actualgs.get(historical_sbDataROI_map.get(hctemp).sbname);
                }   
                if (PeriodA_prorate != null && PeriodA_prorate != 0 && totalactualvol != null && totalactualvol != 0 && PeriodD_prorate != null && actualgs_prorate != null)
                    GrossSalesTotal.strA += actualgs_prorate * totalactualvol / PeriodA_prorate * PeriodD_prorate;
            }

        }
        
        //New Contract ROI Calculation
        if (current_sbDataROI_map != null && current_sbDataROI_map.size() > 0){
            decimal actualcm;
            decimal lbcm;
            decimal actualgs;
            decimal totalactualvol;
            decimal totalestimatevol;
            decimal strperiod;
            
            for (string ccroi : current_sbDataROI_map.keyset()){
                strperiod= null;
                if (current_sbDataROI_map.get(ccroi).period != null){
                    strperiod = current_sbDataROI_map.get(ccroi).period;
                }
                //Budget CM
                actualcm = null;
                if (current_sbDataROI_map.get(ccroi).CM != null){
                    actualcm = current_sbDataROI_map.get(ccroi).CM;
                }
                // Added by Alan Wong (Elufa) 2015061
                //Latest Budget CM
                lbcm = null;
                if (current_sbDataROI_map.get(ccroi).latestBudgetCM != null){
                    lbcm = current_sbDataROI_map.get(ccroi).latestBudgetCM;
                }
                // -- End -- //
                //Budget GS
                actualgs = null;
                if (current_sbDataROI_map.get(ccroi).GS != null){
                    actualgs = current_sbDataROI_map.get(ccroi).GS;
                }
                
                //Total Volume
                totalactualvol = null;
                if (ConVolume_map != null && current_sbDataROI_map.get(ccroi) != null && current_sbDataROI_map.get(ccroi).sbname != null && ConVolume_map.containskey(current_sbDataROI_map.get(ccroi).sbname)){
                    totalactualvol = ConVolume_map.get(current_sbDataROI_map.get(ccroi).sbname);
                }
                totalestimatevol = null;
                system.debug(EstVolume_map);
                system.debug(EstVolume_map.size());
                if (EstVolume_map != null && current_sbDataROI_map.get(ccroi) != null && current_sbDataROI_map.get(ccroi).sbname != null && EstVolume_map.containskey(current_sbDataROI_map.get(ccroi).sbname)){
                    totalestimatevol = EstVolume_map.get(current_sbDataROI_map.get(ccroi).sbname);
                }
                if (totalestimatevol != null && actualcm != null && strperiod != null){
                    CMTotal.strB += actualcm * totalestimatevol * strperiod;
                }
                // Added by Alan Wong (Elufa) 20150618
                if (totalestimatevol != null && lbcm != null && strperiod != null){
                    latestBudgetCMTotal.strB += lbcm * totalestimatevol * strperiod;
                }
                // -- End -- //
                if (totalestimatevol != null && actualgs != null && strperiod != null){
                    GrossSalesTotal.strB += actualgs * totalestimatevol * strperiod;
                }               
                if (totalactualvol != null && actualcm != null && strperiod != null){
                    CMTotal.strD += actualcm * totalactualvol * strperiod;
                }
                // Added by Alan Wong (Elufa) 20150618
                if (totalactualvol != null && lbcm != null && strperiod != null){
                    latestBudgetCMTotal.strD += lbcm * totalactualvol * strperiod;
                }
                // -- End -- //
                if (totalactualvol != null && actualgs != null && strperiod != null){
                    GrossSalesTotal.strD += actualgs * totalactualvol * strperiod;
                }
            }
        }
        
        //Added by Twinkle 20141128 - Historical V0  
        if (historicalV0_sbDataROI_map != null && historicalV0_sbDataROI_map.size() > 0){
            decimal actualgs;
            decimal actualcm;
            decimal lbcm;
            decimal totalestimatevol;
            decimal strperiod;
            
            for (string ccroi : historicalV0_sbDataROI_map.keyset()){
                strperiod= null;
                if (historicalV0_sbDataROI_map.get(ccroi).period != null){
                    strperiod = historicalV0_sbDataROI_map.get(ccroi).period;
                }
                //Budget CM
                actualcm = null;
                if (historicalV0_sbDataROI_map.get(ccroi).CM != null){
                    actualcm = historicalV0_sbDataROI_map.get(ccroi).CM;
                }
                // Added by Alan Wong (Elufa) 20150618
                // Latest Budget CM
                lbcm = null;
                if (historicalV0_sbDataROI_map.get(ccroi).latestBudgetCM != null){
                    lbcm = historicalV0_sbDataROI_map.get(ccroi).latestBudgetCM;
                }
                // -- End -- //
                //Budget GS
                actualgs = null;
                if (historicalV0_sbDataROI_map.get(ccroi).GS != null){
                    actualgs = historicalV0_sbDataROI_map.get(ccroi).GS;
                }
                totalestimatevol = null;
                if (pV0_EstVolume_map != null && historicalV0_sbDataROI_map.get(ccroi) != null && historicalV0_sbDataROI_map.get(ccroi).sbname != null && pV0_EstVolume_map.containskey(historicalV0_sbDataROI_map.get(ccroi).sbname)){
                    totalestimatevol = pV0_EstVolume_map.get(historicalV0_sbDataROI_map.get(ccroi).sbname);
                }                               
                //Total Volume
                if (totalestimatevol != null && actualcm != null && strperiod != null){
                    CMTotal.strV0 += actualcm * totalestimatevol * strperiod;
                }
                // Added by Alan Wong (Elufa) 20150618
                if (totalestimatevol != null && lbcm != null && strperiod != null){
                    latestBudgetCMTotal.strV0 += lbcm * totalestimatevol * strperiod;
                }
                // -- End --//
                //Gross Sales
                if (totalestimatevol != null && actualgs != null && strperiod != null){
                    GrossSalesTotal.strV0 += actualgs * totalestimatevol * strperiod;
                }
            }
        }
        //End by Twinkle 20141128
        
        //Added by Twinkle 20141201 - Historical V0 Cont. Margin after A&P
        if (CMTotal.strV0 != null && TradeExpense.strV0 != null){
            MarginAP.strV0 = CMTotal.strV0 - TradeExpense.strV0;
            system.debug(CMTotal.strV0);
        }
        //End by Twinkle 20141201
        
        //Historical Cont. Margin after A&P
        if (CMTotal.strA != null && TradeExpense.strA != null){
            MarginAP.strA = CMTotal.strA - TradeExpense.strA;
        }
        system.debug('Final Historical Margin AP: ' + CMTotal.strA + ' - ' + TradeExpense.strA);
        //Estimate Cont. Margin after A&P
        if (CMTotal.strB != null && TradeExpense.strB != null){
            MarginAP.strB = CMTotal.strB - TradeExpense.strB;
            system.debug(CMTotal.strB);
        }
        system.debug('Final Estimate Margin AP: ' + CMTotal.strB + ' - ' + TradeExpense.strB);
        system.debug('MarginAP.strB: ' + MarginAP.strB);
        //Contract Cont. Margin after A&P
        if (CMTotal.strD != null && TradeExpense.strD != null){
            MarginAP.strD = CMTotal.strD - TradeExpense.strD;
        }
        system.debug('RegionSubBrandCM_Map:::' + RegionSubBrandCM_Map);
        system.debug('Final Contract Margin AP: ' + CMTotal.strD + ' - ' + TradeExpense.strD);
        if (MarginAP.strB != null && MarginAP.strA != null && MarginAP.strA !=0){
            MarginAP.strC = ((MarginAP.strB - MarginAP.strA)/MarginAP.strA)*100;
        }
        //%vFinal Cont. Margin after A&P
        if (GrossSalesTotal.strA != null && GrossSalesTotal.strA != 0 && GrossSalesTotal.strB != null && GrossSalesTotal.strB != 0){
            GrossSalesTotal.strC = ((GrossSalesTotal.strB - GrossSalesTotal.strA)/GrossSalesTotal.strA)*100;
        }
        if (TotalHC_VolumeBtl != 0 && TotalHC_VolumeBtl != null && MarginAP.strA != 0 && MarginAP.strA != null){
            MarginperBottle.strA = MarginAP.strA / TotalHC_VolumeBtl;
        }
        system.debug('Historical Margin per Bottle: ' + MarginAP.strA + ' / ' + TotalHC_VolumeBtl);
        
        //Added by Twinkle 20141201 - Historical V0 Estimate Cont Margin per Bottle
        if (VarExp_AllProducts.strV0 != null && pV0CC_numOfMonth != null){
            MarginperBottle.strV0 = VarExp_AllProducts.strV0 * pV0CC_numOfMonth;
        }
        if (MarginperBottle.strV0 != 0 && MarginperBottle.strV0 != null && MarginAP.strV0 != 0 && MarginAP.strV0 != null){
            MarginperBottle.strV0 = MarginAP.strV0 / MarginperBottle.strV0;
        }
        //End by Twinkle 20141201 
        
        //Estimate Cont Margin per Bottle
        if (VarExp_AllProducts.strB != null && thisCC.ASI_CRM_CN_No_of_Months__c != null){
            MarginperBottle.strB = VarExp_AllProducts.strB * thisCC.ASI_CRM_CN_No_of_Months__c;
        }
        if (MarginperBottle.strB != 0 && MarginperBottle.strB != null && MarginAP.strB != 0 && MarginAP.strB != null){
            MarginperBottle.strB = MarginAP.strB / MarginperBottle.strB;
        }       
        
        //Contract Cont Margin per Bottle
        if (VarExp_AllProducts.strD != null && thisCC.ASI_CRM_CN_No_of_Months__c != null){
            MarginperBottle.strD = VarExp_AllProducts.strC * thisCC.ASI_CRM_CN_No_of_Months__c;
        }
        if (MarginperBottle.strD != 0 && MarginperBottle.strD != null && MarginAP.strD != 0 && MarginAP.strD != null){
            MarginperBottle.strD = MarginAP.strD / MarginperBottle.strD;
        }
        //%vFinal Cont Margin per Bottle
        if (MarginperBottle.strA != null && MarginperBottle.strA != 0 && MarginperBottle.strB != null && MarginperBottle.strB != 0){
            MarginperBottle.strC = ((MarginperBottle.strB - MarginperBottle.strA)/MarginperBottle.strA)*100;
        }
        //Added by Twinkle 20141128 - Gross Sales Historical V0
        if (GrossSalesTotal.strV0 != null && GrossSalesTotal.strV0 != 0 && TradeExpense.strV0 != 0 && TradeExpense.strV0 != null){
            GrossSales.strV0 = TradeExpense.strV0 / GrossSalesTotal.strV0 *100;
        }
        //End by Twinkle 20141128 
        //%Gross Sales Historical
        if (GrossSalesTotal.strA != null && GrossSalesTotal.strA != 0 && TradeExpense.strA != 0 && TradeExpense.strA != null){
            GrossSales.strA = TradeExpense.strA / GrossSalesTotal.strA *100;
        }
        system.debug('GrossSales %: ' + TradeExpense.strA + '/' + GrossSalesTotal.strA + '*100');
        //%Gross Sales Estimate
        if (GrossSalesTotal.strB != null && GrossSalesTotal.strB != 0 && TradeExpense.strB != 0 && TradeExpense.strB != null){
            GrossSales.strB = TradeExpense.strB / GrossSalesTotal.strB *100;
        }
        system.debug('GrossSales %: ' + TradeExpense.strB + '/' + GrossSalesTotal.strB + '*100');
        //%Gross Sales Contract
        if (GrossSalesTotal.strD != null && GrossSalesTotal.strD != 0 && TradeExpense.strD != 0 && TradeExpense.strD != null){
            GrossSales.strD = TradeExpense.strD / GrossSalesTotal.strD *100;
        }
        system.debug('GrossSales %: ' + TradeExpense.strD + '/' + GrossSalesTotal.strD + '*100');
        //%Gross Sales %vFinal
        if (GrossSales.strA != null && GrossSales.strA != 0 && GrossSales.strB != 0 && GrossSales.strB != null){
            GrossSales.strC = (GrossSales.strB - GrossSales.strA);
        }
        
        //Added by Twinkle 20141201 - ROI Historical V0
        if (CMTotal.strV0 != null && CMTotal.strV0 != 0 && TradeExpense.strV0 != 0 && TradeExpense.strV0 != null){
            ROI.strV0 = CMTotal.strV0 / TradeExpense.strV0;
        }
        //End by Twinkle 20141201 
        //ROI Historical
        if (CMTotal.strA != null && CMTotal.strA != 0 && TradeExpense.strA != 0 && TradeExpense.strA != null){
            ROI.strA = CMTotal.strA / TradeExpense.strA;
        }
        system.debug('Final Historical ROI: ' + CMTotal.strA + ' / ' + TradeExpense.strA);
        //ROI Estimate
        if (CMTotal.strB != null && CMTotal.strB != 0 && TradeExpense.strB != 0 && TradeExpense.strB != null){
            ROI.strB = CMTotal.strB / TradeExpense.strB;
        }
        system.debug('Final Estimate ROI: ' + CMTotal.strB + ' / ' + TradeExpense.strB);
        //ROI Contract
        if (CMTotal.strD != null && CMTotal.strD != 0 && TradeExpense.strD != 0 && TradeExpense.strD != null){
            ROI.strD = CMTotal.strD / TradeExpense.strD;
        }
        system.debug('Final Contract ROI: ' + CMTotal.strB + ' / ' + TradeExpense.strB);
        //ROI %vFinal
        if (ROI.strB != null && ROI.strB != 0 && ROI.strA != null && ROI.strA != 0){
            ROI.strC = ((ROI.strB - ROI.strA) / ROI.strA)*100;
        }
        
        
        //Added by Alan Wong (Elufa) 20150618 - ProForma_ROI Historical V0
        if (latestBudgetCMTotal.strV0 != null && latestBudgetCMTotal.strV0 != 0 && TradeExpense.strV0 != 0 && TradeExpense.strV0 != null){
            ProForma_ROI.strV0 = latestBudgetCMTotal.strV0 / TradeExpense.strV0;
        }
        //ProForma_ROI Historical
        if (latestBudgetCMTotal.strA != null && latestBudgetCMTotal.strA != 0 && TradeExpense.strA != 0 && TradeExpense.strA != null){
            ProForma_ROI.strA = latestBudgetCMTotal.strA / TradeExpense.strA;
        }
        system.debug('Final Historical ProForma_ROI: ' + latestBudgetCMTotal.strA + ' / ' + TradeExpense.strA);
        //ProForma_ROI Estimate
        if (latestBudgetCMTotal.strB != null && latestBudgetCMTotal.strB != 0 && TradeExpense.strB != 0 && TradeExpense.strB != null){
            ProForma_ROI.strB = latestBudgetCMTotal.strB / TradeExpense.strB;
        }
        system.debug('Final Estimate ProForma_ROI: ' + latestBudgetCMTotal.strB + ' / ' + TradeExpense.strB);
        //ProForma_ROI %vFinal
        if (ProForma_ROI.strB != null && ProForma_ROI.strB != 0 && ProForma_ROI.strA != null && ProForma_ROI.strA != 0){
            ProForma_ROI.strC = ((ProForma_ROI.strB/ProForma_ROI.strA)-1)*100;
        }
        //ProForma_ROI Contract
        if (latestBudgetCMTotal.strD != null && latestBudgetCMTotal.strD != 0 && TradeExpense.strD != 0 && TradeExpense.strD != null){
            ProForma_ROI.strD = latestBudgetCMTotal.strD / TradeExpense.strD;
        }
        system.debug('Final Contract ProForma_ROI: ' + latestBudgetCMTotal.strB + ' / ' + TradeExpense.strB);
        // -- End -- //
        
       
        if (strpb != null && strpb != 0 &&  VarExp_AllProducts.strB != null &&  VarExp_AllProducts.strB !=0)
            PriorityBrand = strpb / VarExp_AllProducts.strB * 100;
        system.debug('strpb: ' + strpb + ' PriorityBrand: '+ PriorityBrand );
        releaseHeapsize();
        
        
        /*********************************** PO Modification Email Template *********************************************/      
        if (thisCC.ASI_CRM_CN_PO_Version__c != '0.0'){
            system.debug('AllOutlet2: ' + AllOutlet);
            Date TillEndPOM = FindMinMaxDate(CutOffDay, thisCC.ASI_CRM_CN_PO_End_Date__c, 'MIN');
            //Canter优化代码 优化时间：2019/8/22 优化原因：两次查询ASI_CRM_Subbrand_Volume__c，导致查询的数据超出五万条，因此将两次查询合并
            date v0TillEndPOM = getEndDate(FindMinMaxDate(CutOffDay, thisCC.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
            Date FindDate = TillEndPOM >= v0TillEndPOM ? TillEndPOM : v0TillEndPOM;
            List<ASI_CRM_Subbrand_Volume__c> SubbList = new List<ASI_CRM_Subbrand_Volume__c>([SELECT id, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                                                                                            ASI_CRM_PR_Direct_CR12__c,  
                                                                                            ASI_CRM_End_Date__c,ASI_CRM_Subbrand__c ,
                                                                                            ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,
                                                                                            ASI_CRM_PR_Direct__c
                                                                                            FROM ASI_CRM_Subbrand_Volume__c WHERE //ASI_CRM_Subbrand__c IN :PreviousCC_Subbrand
                                                                                            ASI_CRM_Account__c IN: AllOutlet//= :thisCC.ASI_CRM_CN_Outlet_WS__c
                                                                                            AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                                                                                            AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c
                                                                                            AND ASI_CRM_End_Date__c <= :FindDate and ASI_CRM_CN_Exclude_From_Payment_Volume__c = false]);
            system.debug('TillEndPOM: ' + TillEndPOM );
            map<string, decimal> POMv1_sbvol = new map<string, decimal>();
            set<id> POMv1_sbid = new set<id>();
            decimal pomv1_vol;
            string strkey;
            date pomdate;
            for (ASI_CRM_Subbrand_Volume__c pom: SubbList){
                if(pom.ASI_CRM_End_Date__c <= TillEndPOM){
                    pomdate = FYConversion(pom.ASI_CRM_End_Date__c);
                    strkey = string.valueof(pomdate) + pom.ASI_CRM_Subbrand__c;
                    
                    if (pom.ASI_CRM_T1_Depletion_CR12__c != null)
                        InvestmentCR12_POM.strB += pom.ASI_CRM_T1_Depletion_CR12__c;
                    if (pom.ASI_CRM_T2_Depletion_CR12__c != null)
                        InvestmentCR12_POM.strB += pom.ASI_CRM_T2_Depletion_CR12__c;
                    if (pom.ASI_CRM_PR_Direct_CR12__c!= null)
                        InvestmentCR12_POM.strB += pom.ASI_CRM_PR_Direct_CR12__c;
                    //ROI Volume
                    pomv1_vol = 0;    
                    if (pom.ASI_CRM_T1_Depletion__c != null)
                        pomv1_vol += pom.ASI_CRM_T1_Depletion__c;
                    if (pom.ASI_CRM_T2_Depletion__c != null)
                        pomv1_vol += pom.ASI_CRM_T2_Depletion__c;
                    if (pom.ASI_CRM_PR_Direct__c!= null)
                        pomv1_vol += pom.ASI_CRM_PR_Direct__c;
                    
                    if (POMv1_sbvol != null && POMv1_sbvol.containskey(strkey)){
                        pomv1_vol += POMv1_sbvol.get(strkey);
                        POMv1_sbvol.put(strkey, pomv1_vol);
                    }else{
                        POMv1_sbvol.put(strkey, pomv1_vol);
                    }
                    system.debug('POM vol id: ' + pom.id + '          ' + pom.ASI_CRM_Subbrand__c);
                    POMv1_sbid.add(pom.ASI_CRM_Subbrand__c);
                }
            }
            //以下是Canter注释代码，注释时间：2019/8/23 注释原因：由于单次事务查询超过salesforce限制的五万条，因此将两条查询合并为一条
            /*for (ASI_CRM_Subbrand_Volume__c pom: [SELECT id, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                                ASI_CRM_PR_Direct_CR12__c,  
                                ASI_CRM_End_Date__c,ASI_CRM_Subbrand__c ,
                                ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,
                                ASI_CRM_PR_Direct__c
                                FROM ASI_CRM_Subbrand_Volume__c WHERE //ASI_CRM_Subbrand__c IN :PreviousCC_Subbrand
                                ASI_CRM_Account__c IN: AllOutlet//= :thisCC.ASI_CRM_CN_Outlet_WS__c
                                AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                                AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c
                                AND ASI_CRM_End_Date__c <= :TillEndPOM and ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ]){//20170207 Elufa
                                    //
                pomdate = FYConversion(pom.ASI_CRM_End_Date__c);
                strkey = string.valueof(pomdate) + pom.ASI_CRM_Subbrand__c;
                
                if (pom.ASI_CRM_T1_Depletion_CR12__c != null)
                    InvestmentCR12_POM.strB += pom.ASI_CRM_T1_Depletion_CR12__c;
                if (pom.ASI_CRM_T2_Depletion_CR12__c != null)
                    InvestmentCR12_POM.strB += pom.ASI_CRM_T2_Depletion_CR12__c;
                if (pom.ASI_CRM_PR_Direct_CR12__c!= null)
                    InvestmentCR12_POM.strB += pom.ASI_CRM_PR_Direct_CR12__c;
                //ROI Volume
                pomv1_vol = 0;    
                if (pom.ASI_CRM_T1_Depletion__c != null)
                    pomv1_vol += pom.ASI_CRM_T1_Depletion__c;
                if (pom.ASI_CRM_T2_Depletion__c != null)
                    pomv1_vol += pom.ASI_CRM_T2_Depletion__c;
                if (pom.ASI_CRM_PR_Direct__c!= null)
                    pomv1_vol += pom.ASI_CRM_PR_Direct__c;
                
                if (POMv1_sbvol != null && POMv1_sbvol.containskey(strkey)){
                    pomv1_vol += POMv1_sbvol.get(strkey);
                    POMv1_sbvol.put(strkey, pomv1_vol);
                }else{
                    POMv1_sbvol.put(strkey, pomv1_vol);
                }
                system.debug('POM vol id: ' + pom.id + '          ' + pom.ASI_CRM_Subbrand__c);
                POMv1_sbid.add(pom.ASI_CRM_Subbrand__c);
            }*/
            
            //Prorate 
            if (thisCC.ASI_CRM_CN_PO_End_Date__c > CutOffDay){
                integer daysperiod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
                integer prorateperiod = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
                if (prorateperiod < 0) prorateperiod = 0;
                system.debug('daysperiod: ' + daysperiod + ' prorateperiod: ' + prorateperiod);
                decimal AverageCR12;
                decimal Average9L;
                //for Latest Investment CR12
                if (daysperiod != null && daysperiod != 0 && InvestmentCR12_POM.strB != 0)
                    AverageCR12 = InvestmentCR12_POM.strB / daysperiod;
                if (prorateperiod != 0 && prorateperiod != null && AverageCR12 != null && AverageCR12 !=0)
                    InvestmentCR12_POM.strB += AverageCR12 * prorateperiod ;
                
            }
            system.debug('InvestmentCR12_POM.strB: ' + InvestmentCR12_POM.strB);
            //system.debug('ROI_POM.strTotalB: ' + ROI_POM.strTotalB);
            system.debug('thisCC.ASI_CRM_CN_Total_Contract_Amount__c: ' + thisCC.ASI_CRM_CN_Total_Contract_Amount__c);
            if (thisCC != null && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null && InvestmentCR12_POM.strB != 0)
                InvestmentCR12_POM.strB = thisCC.ASI_CRM_CN_Total_Contract_Amount__c / InvestmentCR12_POM.strB;
            decimal v0Brsf = 0;
            decimal brsfvol_roi = 0;
            decimal v0_estvol_pom = 0;
            strv0VarCost = 0;
            set<id>POMv0_sbid =new set<id>();
            map<id, decimal> BRSF_SBVol = new map<id, decimal>(); 
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c  pombrsf : [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,
                            ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, 
                            ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                            ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :thisCC.ASI_CRM_CN_V0_0_PO_version__c] ){
                v0Brsf = 0;
                if (pombrsf.ASI_CRM_CN_Est_Monthly_Qty__c != null && pombrsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null)
                    v0Brsf = pombrsf.ASI_CRM_CN_Est_Monthly_Qty__c * pombrsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                v0_estvol_pom += v0Brsf ;
                if (pombrsf.ASI_CRM_CN_No_of_Months__c != null){
                    v0Brsf *= pombrsf.ASI_CRM_CN_No_of_Months__c;
                }
                if (pombrsf.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null){
                    brsfvol_roi = pombrsf.ASI_CRM_CN_Estimate_Volume_9L_Month__c ;
                }
                if (pombrsf.ASI_CRM_CN_Est_Total__c!= null)
                    strv0VarCost += pombrsf.ASI_CRM_CN_Est_Total__c;
                
                
                InvestmentCR12_POM.strA += v0Brsf;
                POMv0_sbid.add(pombrsf.ASI_CRM_CN_Sub_Brand__c);
                if (BRSF_SBVol.containskey(pombrsf.ASI_CRM_CN_Sub_Brand__c)){
                    brsfvol_roi += BRSF_SBVol.get(pombrsf.ASI_CRM_CN_Sub_Brand__c);
                    BRSF_SBVol.put(pombrsf.ASI_CRM_CN_Sub_Brand__c, brsfvol_roi);
                }else{
                    BRSF_SBVol.put(pombrsf.ASI_CRM_CN_Sub_Brand__c, brsfvol_roi);
                }
            }
            system.debug('InvestmentCR12_POM.strA: ' + InvestmentCR12_POM.strA);
            
            if (InvestmentCR12_POM.strA != null && InvestmentCR12_POM.strA != 0 && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != null && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != 0)
                InvestmentCR12_POM.strA = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c / InvestmentCR12_POM.strA ;
            //Investment CR12 gap
            if (InvestmentCR12_POM.strA != null && InvestmentCR12_POM.strB != null && InvestmentCR12_POM.strA != 0 && InvestmentCR12_POM.strB != 0)
                InvestmentCR12_POM.strC = (InvestmentCR12_POM.strB - InvestmentCR12_POM.strA) /InvestmentCR12_POM.strA*100;
            system.debug('POMv0_sbid: ' + POMv0_sbid); 
            //Define var  
            date v0startdate;
            date v0enddate;
            
            if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!= null){
                v0startdate = getEndDate(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
            }else{
                //assign value to v0startdate if ASI_CRM_CN_PO_Start_Date__c = null? or need to check y ASI_CRM_CN_PO_Start_Date__c can be null
            }
            if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!= null){   
                v0enddate = getEndDate(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
            }else{
                //assign value to v0startdate if ASI_CRM_CN_PO_End_Date__c = null?
            }
            
            map<date, decimal> v0_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
            map<string, subbrand_data> v0_ROImap = new map <string, subbrand_data>();
            
            if (v0_Period_map != null && v0_Period_map.size() > 0){
                strkey = null;
                for (date v0period : v0_Period_map.keyset()){
                    if (POMv0_sbid != null && POMv0_sbid.size() > 0){
                        for (id sbid : POMv0_sbid){
                            strkey = string.valueof(v0period) + sbid;
                            subbrand_data newitem = new subbrand_data();
                            newitem.period = v0_Period_map.get(v0period);
                            newitem.sbname = sbid;
                            newitem.totalVolume = 0;
                            v0_ROImap.put(strkey, newitem);
                        }
                    }
                }
            }
            
            strkey = null;
            decimal budgetcm;
            
            //20170109 Elufa
            date strStartBGDate2 = date.newInstance(v0startdate.addYears(-1).year(), 6, 30);
            date strEndBGDate2 = date.newInstance(v0enddate.year(), 6, 30);
            Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
            //20170109 End
            
            for (ASI_CRM_CM_GS__c v0budgetcmtemp : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,
                                                    ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,
                                                    ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                                    , ASI_CRM_CN_Month__c
                                                    FROM ASI_CRM_CM_GS__c
                                                    WHERE ASI_CRM_PRODUCTCODE__c IN :POMv0_sbid
                                                    AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                    AND ((ASI_CRM_CN_Month_End_Date__c >= :v0startdate
                                                          AND ASI_CRM_CN_Month_End_Date__c <= :v0enddate )
                                                         OR (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 //20170109 Elufa
                                                             AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2//20170109 Elufa
                                                             AND ASI_CRM_CN_Month__c = 6 ))//20170109 Elufa
                                                    AND ASI_CRM_TYPE__c = 'Budget CM'
                                                    AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != Null
                                                    ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ]){
                                                        strkey = string.valueof(v0budgetcmtemp.ASI_CRM_CN_Month_End_Date__c) + v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
                                                        budgetcm = 0;
                                                        
                                                        //20170109 Elufa
                                                        if(v0budgetcmtemp.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c + v0budgetcmtemp.ASI_CRM_TYPE__c) && v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null && v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != 0){
                                                            cmgsMap.put(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c + v0budgetcmtemp.ASI_CRM_TYPE__c, v0budgetcmtemp);
                                                        }
                                                        //20170109 End
                                                        
                                                        if (v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null)
                                                            budgetcm = v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c;
                                                        if (v0_ROImap != null && v0_ROImap.containskey(strkey)){
                                                            if (v0_ROImap.get(strkey).CM == null || v0_ROImap.get(strkey).CM == 0){//20170125 Elufa added || v0_ROImap.get(strkey).CM == 0
                                                                //Fix for HPSM IM52771
                                                                if (v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null && v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != 0){//20160905 Ben @ Elufa
                                                                    v0_ROImap.get(strkey).CM = budgetcm;
                                                                }
                                                            }
                                                            if (v0_ROImap.get(strkey).latestBudgetCM == null){
                                                                if (RegionSubBrandCM_Map.containsKey(v0budgetcmtemp.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(v0budgetcmtemp.ASI_CRM_Region__c).containsKey(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c)){
                                                                    v0_ROImap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(v0budgetcmtemp.ASI_CRM_Region__c).get(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c);
                                                                }
                                                            }
                                                        }                
                                                    }
            
            //20170109 Elufa to replace null/0 value with latest CMGS data
            for(String key : v0_ROImap.keySet()){
                if(v0_ROImap.get(key).CM == Null || v0_ROImap.get(key).CM == 0 || v0_ROImap.get(key).latestBudgetCM == Null || v0_ROImap.get(key).latestBudgetCM == 0){
                    if((v0_ROImap.get(key).CM == Null || v0_ROImap.get(key).CM == 0) && cmgsMap.containsKey(v0_ROImap.get(key).sbname + 'Budget CM')){
                        ASI_CRM_CM_GS__c cmgs = cmgsMap.get(v0_ROImap.get(key).sbname + 'Budget CM');
                        
                        v0_ROImap.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                    }
                    
                    if(v0_ROImap.get(key).latestBudgetCM == Null || v0_ROImap.get(key).latestBudgetCM == 0){
                        if(RegionSubBrandCM_Map.containsKey(thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c).containsKey(v0_ROImap.get(key).sbname)){
                            v0_ROImap.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c).get(v0_ROImap.get(key).sbname);
                        }
                    }
                }
            }
            //20170109
            
            system.debug('v0_ROImap (BudgetCM): ' + v0_ROImap );
            
            if (v0_ROImap != null && v0_ROImap.size() > 0){
                for (string roitemp : v0_ROImap.keyset()){
                    if (BRSF_SBVol != null && BRSF_SBVol.containskey(v0_ROImap.get(roitemp).sbname)){
                        v0_ROImap.get(roitemp).TotalVolume = BRSF_SBVol.get(v0_ROImap.get(roitemp).sbname);
                    }
                    if (v0_ROImap.get(roitemp).TotalVolume != null && v0_ROImap.get(roitemp).CM != null && v0_ROImap.get(roitemp).period != null){
                        ROI_POM.strTotalA += v0_ROImap.get(roitemp).TotalVolume * v0_ROImap.get(roitemp).CM * v0_ROImap.get(roitemp).period;
                        system.debug('ROI_POM.strTotalA: ' + ' += ' + v0_ROImap.get(roitemp).TotalVolume + ' * ' + v0_ROImap.get(roitemp).CM  + ' * ' + v0_ROImap.get(roitemp).period);
                    }
                    // Added by Alan Wong (Elufasys) 20150621
                    if (v0_ROImap.get(roitemp).TotalVolume != null && v0_ROImap.get(roitemp).latestBudgetCM != null && v0_ROImap.get(roitemp).period != null){
                       ROI_POM.ProFormaROIstrTotalA += v0_ROImap.get(roitemp).TotalVolume * v0_ROImap.get(roitemp).latestBudgetCM * v0_ROImap.get(roitemp).period;
                    }
                    // -- End -- //
                }
            }
            if (ROI_POM.strTotalA != null && ROI_POM.strTotalA != 0 && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != null && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != 0){
                ROI_POM.strA = ROI_POM.strTotalA / thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c;
            }
            // Added by Alan Wong (Elufasys) 20150621
            if (ROI_POM.ProFormaROIstrTotalA != null && ROI_POM.ProFormaROIstrTotalA != 0 && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != null && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != 0){
                ROI_POM.ProFormaROIstrA = ROI_POM.ProFormaROIstrTotalA / thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c;
            }
            // -- End -- //
            system.debug('ROI_POM.strA: ' + ROI_POM.strTotalA + ' / ' + thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c);

            //Lastest ROI (Actual CM)
            date v1startdate = getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
            date v1enddate;
            if (thisCC.ASI_CRM_CN_PO_End_Date__c < CutOffDay){
                v1enddate = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c);
                //v1enddate = thisCC.ASI_CRM_CN_PO_End_Date__c;
            }else{
                v1enddate = CutOffDay;
            }
            map<date, decimal> Lastest_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
            map<string, subbrand_data> Lastest_ROImap = new map <string, subbrand_data>();
            if (Lastest_Period_map != null && Lastest_Period_map.size() > 0){
                strkey = null;
                for (date v1period : Lastest_Period_map.keyset()){
                    if (POMv1_sbid != null && POMv1_sbid.size() > 0){
                        for (id sbid : POMv1_sbid){
                            strkey = string.valueof(v1period) + sbid;
                            subbrand_data newitem = new subbrand_data();
                            newitem.period = Lastest_Period_map.get(v1period);
                            newitem.sbname = sbid;
                            newitem.year = string.valueof(FYConversion(v1period).year());
                            newitem.totalVolume = 0;
                            Lastest_ROImap.put(strkey, newitem);
                        }
                    }
                }
            }
            system.debug('Lastest_Period_map: ' + Lastest_Period_map);
            map<string, decimal> lastestroi = new map<string, decimal>();
            map<string, decimal> lastestproformaroi = new map<string, decimal>(); // Added by Alan Wong (Elufa) 20150623
            strkey = null;
            decimal actualcm;
            string lastestkey;
            for (ASI_CRM_CM_GS__c v1budgetcmtemp : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,
                                ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,
                                ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                FROM ASI_CRM_CM_GS__c
                                WHERE ASI_CRM_PRODUCTCODE__c IN :POMv1_sbid
                                AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                AND ASI_CRM_CN_Month_End_Date__c >= :v1startdate 
                                AND ASI_CRM_CN_Month_End_Date__c <= :v1enddate 
                                AND ASI_CRM_TYPE__c = 'YTD CM'
                                AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != Null
                                ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ]){
                strkey = string.valueof(v1budgetcmtemp.ASI_CRM_CN_Month_End_Date__c) + v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
                lastestkey = v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
                actualcm = 0;
                
                if (v1budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null)
                    actualcm = v1budgetcmtemp.ASI_CRM_CM_GS_per_9L__c;
                if (Lastest_ROImap != null && Lastest_ROImap.containskey(strkey)){
                    if (Lastest_ROImap.get(strkey).CM == null || Lastest_ROImap.get(strkey).CM == 0)//20170126 Elufa Added  || Lastest_ROImap.get(strkey).CM == 0
                        Lastest_ROImap.get(strkey).CM = actualcm;
                    // Added by Alan Wong (Elufa) 20150623
                    if (Lastest_ROImap.get(strkey).latestBudgetCM == null || Lastest_ROImap.get(strkey).latestBudgetCM == null)//20170126 Elufa Added || Lastest_ROImap.get(strkey).latestBudgetCM == null
                        if (RegionSubBrandCM_Map.containsKey(v1budgetcmtemp.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(v1budgetcmtemp.ASI_CRM_Region__c).containsKey(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c)){
                            Lastest_ROImap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(v1budgetcmtemp.ASI_CRM_Region__c).get(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c);
                        }
                    // -- End -- //
                }
                                    
                if (Lastest_ROImap != null && !lastestroi.containskey(lastestkey) && actualcm != Null && actualcm != 0){//20161025 Ben @ Elufa added actualcm != NULL and actualcm != 0
                    system.debug('check111 ' + v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c + '   ' + v1budgetcmtemp.id);
                    lastestroi.put(lastestkey, actualcm);
                }
                // Added by Alan Wong (Elufa) 20150623
                if (Lastest_ROImap != null && !lastestproformaroi.containskey(lastestkey)){
                    if (RegionSubBrandCM_Map.containsKey(v1budgetcmtemp.ASI_CRM_Region__c) && RegionSubBrandCM_Map.get(v1budgetcmtemp.ASI_CRM_Region__c).containsKey(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c)) {
                        lastestproformaroi.put(lastestkey, RegionSubBrandCM_Map.get(v1budgetcmtemp.ASI_CRM_Region__c).get(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c));
                    }
                }
                // -- End -- //
            }
            system.debug('Lastest_ROImap: ' + Lastest_ROImap);
            if (Lastest_ROImap != null && Lastest_ROImap.size() > 0){
                decimal strv1vol;
                actualcm = 0;
                decimal Average9L = 0;
                decimal prorate_actualcm = 0;
                // Added by Alan Wong (Elufa) 20150623
                decimal lbcm = 0;
                decimal prorate_lbcm = 0;
                // -- End -- //
                integer daysperiod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
                integer prorateperiod = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
                if (prorateperiod < 0) prorateperiod = 0;
                for (string v1roitemp : Lastest_ROImap.keyset()){
                    strv1vol = 0;
                    if (POMv1_sbvol.containskey(v1roitemp)){
                        strv1vol = POMv1_sbvol.get(v1roitemp);
                    }
                    actualcm = null;
                    if (Lastest_ROImap.get(v1roitemp).CM != null && Lastest_ROImap.get(v1roitemp).CM != 0)//20170126 Elufa added  && Lastest_ROImap.get(v1roitemp).CM != 0
                        actualcm = Lastest_ROImap.get(v1roitemp).CM;
                    else if (lastestroi != null && lastestroi.containskey(Lastest_ROImap.get(v1roitemp).sbname))
                            actualcm = lastestroi.get(Lastest_ROImap.get(v1roitemp).sbname);
                    system.debug('Latest ROI actualcm: ' + actualcm);
                    if (strv1vol != null && actualcm != null){
                        ROI_POM.strTotalB += strv1vol * actualcm;
                        system.debug('ROI_POM.strTotalB item: ' + strv1vol + ' * ' + actualcm);
                        Average9L = 0;
                        if (lastestroi != null && lastestroi.containskey(Lastest_ROImap.get(v1roitemp).sbname))
                            prorate_actualcm = lastestroi.get(Lastest_ROImap.get(v1roitemp).sbname);
                        if (strv1vol != 0 && strv1vol != null && daysperiod != null && daysperiod != 0)
                            Average9L = strv1vol / daysperiod;
                        if (Average9L != null && prorateperiod != null && prorate_actualcm != null)
                            ROI_POM.strTotalB += Average9L *  prorateperiod * prorate_actualcm;
                    }
                    system.debug('prorate_actualcm: ' + Average9L + ' * ' + prorateperiod + ' * ' + prorate_actualcm);
                    // Added by Alan Wong (Elufa) 20150623
                    lbcm = null;
                    if (Lastest_ROImap.get(v1roitemp).latestBudgetCM != null && Lastest_ROImap.get(v1roitemp).latestBudgetCM != 0)//20170126 Elufa added  && Lastest_ROImap.get(v1roitemp).latestBudgetCM != 0
                        lbcm = Lastest_ROImap.get(v1roitemp).latestBudgetCM;
                    else if (lastestproformaroi != null && lastestproformaroi.containskey(Lastest_ROImap.get(v1roitemp).sbname))
                            lbcm = lastestproformaroi.get(Lastest_ROImap.get(v1roitemp).sbname);
                    if (strv1vol != null && lbcm != null){
                        ROI_POM.ProFormaROIstrTotalB += strv1vol * lbcm;
                        Average9L = 0;
                        if (lastestproformaroi != null && lastestproformaroi.containskey(Lastest_ROImap.get(v1roitemp).sbname))
                            prorate_lbcm = lastestproformaroi.get(Lastest_ROImap.get(v1roitemp).sbname);
                        if (strv1vol != 0 && strv1vol != null && daysperiod != null && daysperiod != 0)
                            Average9L = strv1vol / daysperiod;
                        if (Average9L != null && prorateperiod != null && prorate_lbcm != null)
                            ROI_POM.ProFormaROIstrTotalB += Average9L *  prorateperiod * prorate_lbcm;
                    }
                    // -- End -- //
                }
            }
            //POM ROI
            system.debug('ROI_POM.strTotalB: ' + ROI_POM.strTotalB + ' / ' + thisCC.ASI_CRM_CN_Total_Contract_Amount__c);
            if (ROI_POM.strTotalB != null && ROI_POM.strTotalB != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null)
                ROI_POM.strB = ROI_POM.strTotalB / thisCC.ASI_CRM_CN_Total_Contract_Amount__c;
            // Added by Alan Wong (Elufa) 20150623
            if (ROI_POM.ProFormaROIstrTotalB != null && ROI_POM.ProFormaROIstrTotalB != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null)
                ROI_POM.ProFormaROIstrB = ROI_POM.ProFormaROIstrTotalB / thisCC.ASI_CRM_CN_Total_Contract_Amount__c;
            
            //POM ROI Gap
            if (ROI_POM.strA != null && ROI_POM.strB != null)
                if (ROI_POM.strA != 0 && ROI_POM.strB != 0 && (ROI_POM.strB - ROI_POM.strA) != 0)
                    ROI_POM.strC = (ROI_POM.strB - ROI_POM.strA)/ROI_POM.strA * 100;
            // Added by Alan Wong (Elufa) 20150623
            if (ROI_POM.ProFormaROIstrA != null && ROI_POM.ProFormaROIstrB != null)
                if (ROI_POM.ProFormaROIstrA != 0 && ROI_POM.ProFormaROIstrB != 0 && (ROI_POM.ProFormaROIstrB - ROI_POM.ProFormaROIstrA) != 0)
                    ROI_POM.ProFormaROIstrC = (ROI_POM.ProFormaROIstrB - ROI_POM.ProFormaROIstrA)/ROI_POM.ProFormaROIstrA * 100;
            // -- End -- //
                for (ASI_CRM_Contract_Cost__c v0cost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c
                               FROM ASI_CRM_Contract_Cost__c 
                               WHERE ASI_CRM_CN_Contract__c = :thisCC.ASI_CRM_CN_V0_0_PO_version__c]){
                    
                    if (v0cost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                        if (v0cost.ASI_CRM_CN_Estimate_Amount__c != null)
                            strv0VarCost += v0cost.ASI_CRM_CN_Estimate_Amount__c;
                    }
                }
                system.debug('strv0VarCost: ' + strv0VarCost);
                system.debug('v0_estvol_pom: ' + v0_estvol_pom );
            
            if (thisCC != null && thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                strv0FixCost = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            THFixGap = 0;
            
            decimal v0_actualvol_pom = 0;
            //system.debug('v0_VolList: ' + v0_VolList );
            if (SubbList != null && SubbList.size() > 0){
                for(ASI_CRM_Subbrand_Volume__c v0vol : SubbList){
                    if(v0vol.ASI_CRM_End_Date__c <= v0TillEndPOM){
                        if (v0vol.ASI_CRM_T1_Depletion_CR12__c != null)
                            v0_actualvol_pom += v0vol.ASI_CRM_T1_Depletion_CR12__c;
                        if (v0vol.ASI_CRM_T2_Depletion_CR12__c != null)
                            v0_actualvol_pom += v0vol.ASI_CRM_T2_Depletion_CR12__c;
                        if (v0vol.ASI_CRM_PR_Direct_CR12__c != null)
                            v0_actualvol_pom += v0vol.ASI_CRM_PR_Direct_CR12__c;
                    }
                }
            }
            SubbList = null;
            //v0 Actual Volume CTD
            //Canter优化代码 将该段代码写在了2502行（原因：两次查询ASI_CRM_Subbrand_Volume__c导致查询超限，因此将这两次插叙你合并为一次）优化时间：2019/8/23
            /*list<ASI_CRM_subbrand_Volume__c> v0_VolList = new list<ASI_CRM_Subbrand_Volume__c>();
            date v0TillEndPOM = getEndDate(FindMinMaxDate(CutOffDay, thisCC.ASI_CRM_CN_PO_End_Date__c, 'MIN')); //Canter优化代码 将该段代码写在了2502行（原因：两次查询ASI_CRM_Subbrand_Volume__c导致查询超限，因此将这两次插叙你合并为一次）
            try{
                v0_VolList = [SELECT id, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                              ASI_CRM_PR_Direct_CR12__c,  
                              ASI_CRM_End_Date__c,ASI_CRM_Subbrand__c
                              FROM ASI_CRM_Subbrand_Volume__c WHERE //ASI_CRM_Subbrand__c IN :PreviousCC_Subbrand
                              ASI_CRM_Account__c IN: AllOutlet//= :thisCC.ASI_CRM_CN_Outlet_WS__c
                              AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                              AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c
                              AND ASI_CRM_End_Date__c <= :v0TillEndPOM AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE];//20170207 Elufa
                //20170118 Elufa
            }catch(exception e){
                system.debug('Try Exception (v0_VolList ): ' + e);
            }
            decimal v0_actualvol_pom = 0;
            system.debug('v0_VolList: ' + v0_VolList );
            if (v0_VolList != null && v0_VolList.size() > 0){
                for(ASI_CRM_Subbrand_Volume__c v0vol : v0_VolList){
                    if (v0vol.ASI_CRM_T1_Depletion_CR12__c != null)
                        v0_actualvol_pom += v0vol.ASI_CRM_T1_Depletion_CR12__c;
                    if (v0vol.ASI_CRM_T2_Depletion_CR12__c != null)
                        v0_actualvol_pom += v0vol.ASI_CRM_T2_Depletion_CR12__c;
                    if (v0vol.ASI_CRM_PR_Direct_CR12__c != null)
                        v0_actualvol_pom += v0vol.ASI_CRM_PR_Direct_CR12__c;
                }
            }*/
            //2014-08-27 release heap size
            //v0_VolList = null;
            
            system.debug('v0_actualvol_pom: ' + v0_actualvol_pom );
            //Theoretical Amount Final Calculation
            
            date cutoffend;
            if (CutOffDay > thisCC.ASI_CRM_CN_PO_End_Date__c)
                cutoffend = thisCC.ASI_CRM_CN_PO_End_Date__c;
            else
                cutoffend = CutOffDay;
            Integer thisCCPeriod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
            Integer v0CCPeriod = thisCCPeriod;
            if (thisCC.ASI_CRM_CN_V0_0_PO_version__c != null)
                v0CCPeriod = MonthDiff(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
            Integer THCTDPeriod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, cutoffend);
            system.debug('thisCCPeriod: ' + thisCCPeriod);
            system.debug('THCTDPeriod: ' + THCTDPeriod );
            ActVSEst_Vol = 0;
            decimal v0_actualVol_Period = 0;
            decimal v0_actualVol_Period_Month = 0;
            if (THCTDPeriod != null && THCTDPeriod != 0 && v0_actualvol_pom != null && v0_actualvol_pom != 0)
                v0_actualVol_Period_Month =  v0_actualvol_pom /  THCTDPeriod ;
            if (v0_actualVol_Period_Month != null && v0_actualVol_Period_Month  != 0 && thisCCPeriod != null && thisCCPeriod != 0)
                v0_actualVol_Period  = v0_actualVol_Period_Month * thisCCPeriod ;
            system.debug('v0_actualVol_Period_Month: ' + v0_actualVol_Period_Month );
            if (v0_actualVol_Period != null && v0_actualVol_Period != 0 && v0_estvol_pom != null && v0_estvol_pom != 0 && v0CCPeriod != null && v0CCPeriod != 0)
                ActVSEst_Vol = v0_actualVol_Period / (v0_estvol_pom * v0CCPeriod);
            system.debug('v0_actualVol_Period: ' + v0_actualVol_Period );
            if (strv0VarCost != null)
                ActVSEst_Vol  *= strv0VarCost;
            if (ActVSEst_Vol <= 0 || ActVSEst_Vol == null)
                ActVSEst_Vol = 0; //strv0VarCost;
            if (ActVSEst_Vol != null && strv0FixCost != null)
                THAmount = strv0FixCost + ActVSEst_Vol ;
            if (THAmount != null && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null)
                THGap = thisCC.ASI_CRM_CN_Total_Contract_Amount__c - THAmount;
            if (ActVSEst_Vol != null && Mod_VCost != null)
                THVarGap = Mod_VCost - ActVSEst_Vol;
                
            //Payment Request Summary
            try{
                paymentRequestSummary = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(null, thisCC);
            }catch(exception e){
                system.debug('Try paymentRequestSummary failed: ' + e);
            }
            PS_TotalPOEstAmt = 0;
            PS_TotalPORemainAmt = 0;
            PS_TotalPODeltaAmt = 0;
            PS_TotalPaidAmt = 0;
            PS_TotalLastEstAmt = 0;
            
            List<integer> lstRemove = new List<integer>();
            integer index = 0;
            integer c = 0;
            if (paymentRequestSummary != null && paymentRequestSummary.size() > 0){
                for (ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary prtemp : paymentRequestSummary){
                    PS_TotalPOEstAmt += prtemp.POEstimateAmt ;
                    PS_TotalPORemainAmt += prtemp.PORemainAmt ;
                    PS_TotalPODeltaAmt += prtemp.PODeltaAmt;
                    PS_TotalPaidAmt += prtemp.PaidAmt;
                    PS_TotalLastEstAmt += prtemp.LastPOEstimateAmt;
                    
                    //Added by Twinkle 20141202 - Remove empty record
                    if((prtemp.LastPOEstimateAmt == 0 || prtemp.LastPOEstimateAmt == null) &&
                        (prtemp.PaidAmt == 0 || prtemp.PaidAmt == null) &&
                        (prtemp.PORemainAmt == 0 || prtemp.PORemainAmt == null) &&
                        (prtemp.PODeltaAmt == 0 || prtemp.PODeltaAmt == null) &&
                        (prtemp.POEstimateAmt == 0 || prtemp.POEstimateAmt == null)){
                        lstRemove.add(index);
                    }
                    index++;
                }
                for(integer n : lstRemove){
                    if(n!=0){
                        if(c>0) 
                            n=n-c;
                        paymentRequestSummary.remove(n);
                        c++;
                    }else{
                        paymentRequestSummary.remove(0);
                        c++;
                    }
                }
                //End by Twinkle 20141202
            }
        }   
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
        else if (strType == 'MAX'){
            if (Date1 >= Date2)
                returnDate = Date1;
            else
                returnDate = Date2;
        }
        return returnDate;
    }
    public void init_Data(){

        PreviousCC_Subbrand = new set<id>();
        thisCC_Subbrand = new set<id>();
        pV0CC_Subbrand = new set<id>();
        sbVarExp = new map<string, map<string, CalculateData>>();
        sbGroup_map = new map<string, CalculateData>();
        FixExpense_Map = new map<string, CalculateData>();
        VarExpense_Map = new map<string, CalculateData>();
        mapSeasonExpense_Fix = new Map<String, ASI_CRM_Contract_Cost__c>();
        mapSeasonExpense_Var = new Map<String, ASI_CRM_Contract_Cost__c>();
        mapSeasonExpense_subTotal = new List<Decimal>{0, 0, 0, 0};
        //mapSeasonExpense_subTotal.add(0);
        //mapSeasonExpense_subTotal.add(0);
        //mapSeasonExpense_subTotal.add(0);
        //mapSeasonExpense_subTotal.add(0);
        seasonExpenseDiff_Total = new List<Decimal>{0, 0, 0, 0, 0, 0, 0, 0};
        mapSeasonExpense_Diff = new Map<String, CalculateData>();
        historical_sbDataROI_map = new map <string, subbrand_data>();
        historicalV0_sbDataROI_map = new map <string, subbrand_data>(); //Added by Twinkle 20141128
        current_sbDataROI_map = new map <string, subbrand_data>();
        latest_actualcm = new map<string, decimal>();
        latest_actualgs = new map<string, decimal>();
        EstVolume_map = new map<id, decimal>();
        pV0_EstVolume_map = new map<string, decimal>(); //Added by Twinkle 20141128
        ConVolume_map = new map<id, decimal>();
        
        
        paymentRequestSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();
        
        CS_Sbmap = new map<id, integer>();
        
        CalculateData tempNull = new CalculateData(0,0,0,0);
        CalculateData tempNull1 = new CalculateData(0,0,0,0);
        CalculateData tempNull2 = new CalculateData(0,0,0,0);
        CalculateData tempNull3 = new CalculateData(0,0,0,0);
        //Updated by Twinkle 20141127 - billingual
        sbGroup_map.put('1. Standard + Premium 标准档 + 高档', tempNull);
        sbGroup_map.put('2. Super Premium 超高档', tempNull1);
        sbGroup_map.put('3. Ultra Premium 特级高档', tempNull2);
        sbGroup_map.put('4. Prestige + Ultra Prestige 奢华档 + 特级奢华档', tempNull3);
        
        VolumeData = new CalculateData(0,0,0,0,0,0,0);
        VolumeData.strName = 'Volume (in 9L cs)';
        
        GrossSales = new CalculateData(0,0,0,0,0);
        GrossSales.strName = '% Gross Sales ';
        
        InvestmentCR12 = new CalculateData(0,0,0,0,0);
        InvestmentCR12.strName = 'Investment per CR12 eq btl';
        
        VExpense = new CalculateData(0,0,0,0,0);
        VExpense.strName = 'Variable Expense';
        
        FExpense = new CalculateData(0,0,0,0,0,0,0);
        FExpense.strName = 'Fixed Expense';
        
        FExpenseRate = new CalculateData(0,0,0,0,0);
        FExpenseRate.strName = 'Fixed Expense %';
        
        TradeExpense = new CalculateData(0,0,0,0,0,0,0);
        TradeExpense.strName = 'Trade Expenses';
        
        MarginAP = new CalculateData(0,0,0,0,0);
        MarginAP.strName = 'Cont. Margin after A&P 销售净利润 ';
        
        MarginperBottle = new CalculateData(0,0,0,0,0);
        MarginperBottle.strName = 'Cont. Margin per Bottle 单瓶利润 ';
        
        ROI = new CalculateData(0,0,0,0,0,0,0);
        ROI.strName = 'ROI (Actual) ';
        
        //Added by Alan Wong (Elufa) 20150618
        ProForma_ROI = new CalculateData(0,0,0,0,0,0,0);
        ProForma_ROI.strName = 'ROI (Pro-Forma) ';
        
        latestBudgetCMTotal = new CalculateData(0,0,0,0,0);
        latestBudgetCMTotal.strName = 'latestBudgetCMTotal';
        // -- End --//
        
        VarExp_AllProducts = new CalculateData(0,0,0,0,0,0,0,0,0,0);
        VarExp_AllProducts.strName = 'ALL PRODUCTS';
        
        FixExp_Total = new CalculateData(0,0,0);
        
        VarExp_Total = new CalculateData(0,0,0,0,0,0,0,0,0,0);
        
        GrossSalesTotal = new CalculateData(0,0,0,0,0);
        GrossSalesTotal.strName = 'Gross Sales';
        
        CMTotal = new CalculateData(0,0,0,0,0);
        CMTotal.strName = 'Gross Sales before A&P (CM)';        
        
        InvestmentCR12_POM = new CalculateData(0,0,0,0,0,0,0,0,0,0);
        InvestmentCR12_POM.strName = 'PO Modification Key Fin. Indicator';
        
        BCRate = new CalculateData(0,0,0,0,0);
        BCRate.strName = 'BC %';
        NetBCRate = new CalculateData(0,0,0,0,0);
        NetBCRate.strName = 'Net BC %';
        
        ROI_POM = new CalculateData(0,0,0,0,0,0,0,0,0,0);
        ROI_POM.strName = 'PO Modification Key Fin. Indicator ROI';        
        Mod_VCost =0;
        THGap = 0;
        THFixGap = 0;
        THVarGap = 0;
    }
    
    public set<string> checkFiscalYear(Date strStart, Date strEnd){
        Integer strSYear = strStart.Year();
        Integer strEYear = strEnd.Year();
        Integer strSMonth = strStart.Month();
        Integer strEMonth = strEnd.Month();
        Integer strPeriodY = 0;
        Integer outputSFY;
        Integer outputEFY;
        set<string> FY_set = new set<string>();
        if (strSMonth > 6)
            outputSFY = strSYear;
        else if (strSMonth < 7)
            outputSFY = strSYear - 1;
        if (strEMonth > 6)
            outputEFY = strEYear + 1;
        else if (strEMonth < 7)
            outputEFY = strEYear;
        strPeriodY = outputEFY - outputSFY ;
        if (strPeriodY <= 1){
            FY_set.add(outputSFY + '/' + outputEFY);
        }else{
            for (Integer i=0; i< strPeriodY; i++ ){
                FY_set.add(string.valueof(outputSFY + i) + '/' + string.valueof(outputSFY + i + 1));
            }
        }
        return FY_set;
    }
    
    public class CalculateData{
        public string strName {set;get;}
        public decimal strA {set;get;}
        public decimal strB {set;get;}
        public decimal strC {set;get;}
        public decimal strD {set;get;}
        public decimal strE {set;get;}
        public decimal strF {set;get;}
        //20160616 Ben @ Elufa
        public decimal strG {set;get;}
        public decimal strH {set;get;}
        //20160616 End
        public decimal strTotalA {set;get;}
        public decimal strTotalB {set;get;}
        public decimal strTotalC {set;get;}
        public decimal ProFormaROIstrA {set;get;} //Added by Alan Wong (Elufa) 20150623
        public decimal ProFormaROIstrB {set;get;} //Added by Alan Wong (Elufa) 20150623
        public decimal ProFormaROIstrC {set;get;} //Added by Alan Wong (Elufa) 20150623
        public decimal ProFormaROIstrTotalA {set;get;} //Added by Alan Wong (Elufa) 20150623
        public decimal ProFormaROIstrTotalB {set;get;} //Added by Alan Wong (Elufa) 20150623
        public boolean strHighlight1 {set;get;}
        public boolean strHighlight2 {set;get;}
        public string strformat {set;get;}        
        public decimal strV0 {set;get;} //Added by Twinkle 20141128
        public string strSubBrand {set;get;} //Added by Twinkle 20141202
        public boolean boolCheckEmpty {set;get;} //Added by Twinkle 20141202

        public CalculateData() {
            this(null,null,null,null,null,null,null,null,null,null);
        }
        public CalculateData(decimal a, decimal b, decimal c) {
            this(null,a,b,c,null,null,null,null,null,null);
        }
        public CalculateData(decimal a, decimal b, decimal c, decimal d) {
            this(null,a,b,c,d,null,null,null,null,null);
        }
        public CalculateData(decimal v0, decimal a, decimal b, decimal c, decimal d) {
            this(v0,a,b,c,d,null,null,null,null,null);
        }
        public CalculateData(decimal a, decimal b, decimal c, decimal d, decimal e, decimal f) {
            this(null,a,b,c,d,e,f,null,null,null);
        }
        public CalculateData(decimal v0, decimal a, decimal b, decimal c, decimal d, decimal e, decimal f) {
            this(v0,a,b,c,d,e,f,null,null,null);
        }
        public CalculateData(decimal v0, decimal a, decimal b, decimal c, decimal d, decimal e, decimal f, decimal totalA, decimal totalB, decimal totalC) {     
            strV0 = v0;       
            strA = a;
            strB = b;
            strC = c;
            strD = d;
            strE = e;
            strF = f;
            strTotalA = totalA;
            strTotalB = totalB;
            strTotalC = totalC;
            ProFormaROIstrTotalA = 0; //Added by Alan Wong (Elufa) 20150623
            ProFormaROIstrTotalB = 0; //Added by Alan Wong (Elufa) 20150623
            ProFormaROIstrA = 0; //Added by Alan Wong (Elufa) 20150623
            ProFormaROIstrB = 0; //Added by Alan Wong (Elufa) 20150623
            ProFormaROIstrC = 0;
            //20160616 Ben @ Elufa
            strG = 0;
            strH = 0;
        }
        
        public boolean checkNotEmpty(){
            if((strV0 == null || strV0 == 0) && (strA == null || strA == 0) && (strB == null || strB == 0) && (strC == null || strC == 0) && (strD == null || strD == 0) && (strE == null || strE == 0) && (strF == null || strF == 0) && (strTotalA == null || strTotalA == 0) && (strTotalB == null || strTotalB == 0) && (strTotalC == null  || strTotalC == 0))
                return false;
            else 
                return true;
        }
    }
    public class subbrand_data{
        public string sbname {set;get;}
        public decimal BottleperMonth {set;get;}
        public decimal FeesperMonth {set;get;}
        public decimal TotalVolume {set;get;}
        public decimal TotalEstVolume {set;get;}
        public decimal TotalGS {set;get;}
        public decimal TotalCM {set;get;}
        public decimal GS {set;get;}{GS=0;}
        public decimal CM {set;get;}{CM=0;}//20170118 Elufa support
        public decimal latestBudgetCM {set;get;}
        public decimal period {set;get;}
        public decimal seqence {set;get;}
        public string year {set;get;}
    }
    public void releaseHeapsize(){
        PreviousCC_SBVolumeList = null;
        thisCC_BRSFList = null;
        PreviousV0CC_BRSFList = null;
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
            else if (strDate < strDay){
                strMonth = Date.Today().Month() - 2;
            }
            strEndDay = Date.daysInMonth(Date.Today().Year(), strMonth);
            returnDate = Date.newinstance(Date.Today().Year(),strMonth,strEndDay);
        }else{
            returnDate = thisCC.ASI_CRM_CN_PO_End_Date__c;
        }
        if (isTest == '1' && isTestDate != null && isTestDate != ''){
            system.debug('TestDate: ' + integer.valueof(isTestDate.Left(4)) + ' ' + integer.valueof(((isTestDate.Right(4)).Left(2))) + ' ' + integer.valueof(isTestDate.Right(2)));
            return Date.newinstance(integer.valueof(isTestDate.Left(4)),integer.valueof(((isTestDate.Right(4)).Left(2))),integer.valueof(isTestDate.Right(2)));          
        }
        return returnDate;
    }
    public void checkUserID(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }
    public date getEndDate(date strDate){
        Integer numberOfDays = Date.daysInMonth(strDate.year(), strDate.month());
        Date lastDayOfMonth = Date.newInstance(strDate.year(), strDate.month(), numberOfDays);
        return lastDayofMonth;
    }
    public void checkApprover(){
        AdorAbove = false;
        set<Id> actorIds = new set<Id>();
        for(ProcessInstanceWorkitem piw 
            :[SELECT ActorId FROM ProcessInstanceWorkitem 
              WHERE processinstance.status = 'Pending' AND
              processinstance.targetobjectid = : thisCC.id]) {
                  actorIds.add(piw.ActorId);
              }
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];
        if(gms.size()>0)
            AdorAbove = true;
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
            else if (startDate.Month() < 7 && startDate.Month() > 0){
                StartFY = startDate.Year();
            }
            if (endDate.Month() > 6 && endDate.Month() < 13){
                EndFY = endDate.Year() + 1;
            }
            else if (endDate.Month() < 7 && endDate.Month() > 0){
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
        else if (strDate.Month() < 7 && strDate.Month() > 0){
            EndFY = strDate.Year();
        }
        returndate = date.newinstance(EndFY,6,30);
        return returnDate;
    }
    public integer MonthDiff(date startDate, date endDate){
        Integer monthDiff;
        if (startDate != null && endDate != null){
            monthDiff = ((endDate.YEAR() - startDate.YEAR() - 1) *12) + (12 - startDate.MONTH() +1) + endDate.MONTH();
            //system.debug('monthDiff: ' + monthDiff);
            return monthDiff;
        }else{
            return null;
        }
    }
    public string SBGradeSorting(decimal strSeq){
        string returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = '0000' + string.valueof(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString = '000' + string.valueof(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString = '00' + string.valueof(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = '0' + string.valueof(strSeq);
            }
        }else{
            returnString = '00000';
        }
        return returnString;
    }
}