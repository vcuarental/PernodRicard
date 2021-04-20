/*********************************************************
Created by Stella Sing (2014-06-11)

Shared Controller for Pages:
- ASI_CRM_CN_PreContractEvalView
- ASI_CRM_CN_PreContractEval_Page

Added
1. Covered Outlet (historical contract)
2. Competitor Sub-brand (historical contract)
3. CutOffday (2014-06-24 follow)
4. LastPO added criteria Status = 'Archived'

Modified by Michael 17Oct2014
Pre-Contract Alignment
1. 3 categories will have the alignment - Investment per CR12 eq btl, ROI for AD Above, Currently, Pre-contract do not have % of Total Trade A&P/GS column, need to add one more row to the pre-contract summary
2. The align Percent will support 2 decimals
3. Setup will be based on division & On/Off channel
4. Support 2 types of operation, >= greater than or equal to and < less than
5. Regional Finance, IT/HQ admin will have the security to change this table
6. The align? Is based on "New Contract" Column's figure to do the comparison with alignment setup table
7. Assume IHBR will be all show blank in alignment
8. If there is no setup in the table, we will show blank in the alignment column



*********************************************************/
public without sharing class ASI_CRM_CN_PreContractEval_Ctrl{
    
    public integer TestInt {get;set;}
    public string TestStr {get;set;}
    public string isTestPCDate {set;get;}
    public string isTest {set;get;}
    public string isTestDate {set;get;}
    //Page Parameters
    public string PageId {set;get;}
    public string OutletId {set;get;}
    public boolean isOwner {set;get;}
    
    //Query
    public ASI_CRM_PreContractEval__c PC {set;get;}
    public decimal NoOfCoveredOutlet {
        get { return PC.ASI_CRM_No_of_covered_outlet__c; }
        set { PC.ASI_CRM_No_of_covered_outlet__c = value; }
    }
    public decimal FixedExpense {
        get { return PC.ASI_CRM_Fixed_Expense__c!=null?PC.ASI_CRM_Fixed_Expense__c:0; }
        set { PC.ASI_CRM_Fixed_Expense__c = value; }
    }
    public string VolumeOption { get; set; } // Added by Alan Wong (Elufa) 20150625
    public decimal PromotionServiceFee {
        get { return PC.ASI_CRM_Promotion_Service_Fee__c; }
        set { PC.ASI_CRM_Promotion_Service_Fee__c = value; }
    }
    public list<ASI_CRM_Pre_Contract_Sub_Brand__c> BtlIncentive_List {set;get;}
    public ASI_CRM_CN_Channel_Strategy__c sbPriority_sc {set;get;}
    public list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> sbPriority_list {set;get;}
    public ASI_CRM_AccountsAdditionalField__c Outlet_acc {set;get;}
    public ASI_TH_CRM_Contract__c LastPO {set;get;}{LastPO = new ASI_TH_CRM_Contract__c ();}
    public list<ASI_MFM_Sub_brand__c> sb_grade {set;get;}
    public list<ASI_CRM_CM_GS__c> sb_actualcm_list {set;get;}
    public list<ASI_CRM_CM_GS__c> sb_budgetcm_list {set;get;}
    public list<ASI_CRM_CM_GS__c> sb_ProFormaCM_list {set;get;}
    public list<ASI_CRM_CM_GS__c> sb_HCProFormaCM_list {set;get;}
    public list<ASI_CRM_CN_PreContract_AlignSetting__c> Align_setting {set;get;}
    
    //String,Integer
    public string PCRecordTypeid {set;get;}
    public boolean showEdit {set;get;}
    public integer Btl_rowid {set;get;}
    public Integer rowid {set;get;}
    public boolean showError {set;get;}
    public integer MonthsPeriod {set;get;}
    public decimal BtlIncentive_Total {set;get;}
    public integer NoMonths {set;get;}
    public boolean noManager {set;get;}
    public boolean LastPOnotEnd {set;get;} //Last PO Contract Not End
    public integer POEndtillNow{set;get;} //Last PO today till End
    public integer POStarttillNow {set;get;} // Last PO Start till today
    public date CutOffDay {set;get;}
    public integer strCutOffDay {set;get;}
    
    //Identify User locale
    public string UserId {set;get;}
    public boolean showCN {set;get;}
    //AD or Above Identity checking
    public boolean ADorAbove {set;get;}
    
    public Boolean hasV0 {set;get;} //20160930, added by Leo
    public Id v0Contract {set;get;} //20160930, added by Leo
    public Date v0StartD {set;get;} //20160930, added by Leo
    public Date v0EndD {set;get;} //20160930, added by Leo
    public Integer v0NoMonths {set;get;} //20160930, added by Leo
    public Boolean lastPOChange {set;get;} //20160930, added by Leo

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd preContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    
    //Custom List/Map/Set
    public class Row {
        public ASI_CRM_Pre_Contract_Sub_Brand__c Record {get;set;}
        public Integer Index {get;set;}
        public decimal EstBtlMonth {
            get { return Record.ASI_CRM_Estimated_Btl_Month__c; }
            set { Record.ASI_CRM_Estimated_Btl_Month__c = value; }
        }
        public decimal BtlIncentive {
            get { return Record.ASI_CRM_Bottle_Incentive__c; }
            set { Record.ASI_CRM_Bottle_Incentive__c = value; }
        }
        public Row(Integer index, ASI_CRM_Pre_Contract_Sub_Brand__c record) {
            this.Index = index;
            this.Record = record;
        }
    }
    public list<Row> Rows {get;set;} 
    public list<ASI_CRM_Pre_Contract_Sub_Brand__c> DelItems {set;get;}
    public set<id> sb_id {set;get;}
    public map<string, list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>> sbPriority_map {set;get;}
    public map<id, string> sbgrade_map {set;get;}
    public map<id, decimal> sb_estimatebtl {set;get;}
    public map<string, ASI_CRM_CN_PreContract_AlignSetting__c> Align_map {set;get;}
    public map<string, SubBrandProrate> ROI_map {set;get;}
    public map<string, SubBrandProrate> HCROI_map {set;get;}
    public map<string, SubBrandProrate> HCROI_mapv0 {set;get;}//20170207 Elufa
    
    public map<string, string> sb_chiname {set;get;}

    public Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> investmentBySubBrandByContractBySubBrand { set; get; } {
        investmentBySubBrandByContractBySubBrand = new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>{
        };
    }

    public Decimal TotalHistoricalBottles {get;set;}
    public Decimal TotalEstimateBottles {get;set;}
    public Decimal TotalContractBottles {get;set;}

    public Decimal AllHistoricalTotalFees {get;set;}
    public Decimal AllEstimateTotalFees {get;set;}
    public Decimal AllContractTotalFees {get;set;}

    public List<SubbrandVolume> subbrandList {get;set;}
    public Map<String,String> subbrandNameMap {get;set;}
    public Boolean Ishave999 {get;set;} {Ishave999 = false;}

    public Decimal VsVolume9L {GET;SET;}//VS Volume 9L %
    public Decimal VolumeAligned {GET;SET;}//Volume Aligned?
    public Decimal VsTradeExpense {GET;SET;}//VS Trade Expense %
    public Decimal TradeExpenseAligned {GET;SET;}//Trade Expense Aligned
    public Decimal VsVariableExpense {GET;SET;}//VS Variable Expense %
    public Decimal VariableExpenseAligned {GET;SET;}//   Variable Expense Aligned
    public Decimal VsFixedExpense {GET;SET;}//VS Fixed Expense
    public Decimal FixedExpenseAligned {GET;SET;}//Fixed Expense Aligned
    public Decimal VsFixedExpenseRate {GET;SET;}//VS Fixed Expense %
    public Decimal FixedExpenseRateAligned {GET;SET;}//Fixed Expense Rate Aligned
    public Decimal VsTotalAPGS {GET;SET;}//VS % of Total A&P/GS
    public Decimal TotalAPGSAligned {GET;SET;}//% of Total A&P/GS Aligned
    public Decimal VSContractIndex{GET;SET;}//VS Contract Index %
    public Decimal ContractIndexAligned{GET;SET;}//Contract Index Aligned
    
    public void Init_Data(){
        strCutOffDay = 16; // 0 = ASI_CRM_CN_PO_End_Date__c
        PCRecordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PreContractEval__cASI_CRM_CN_Pre_Contract');
        Btl_rowid = 0;
        Rows = new list<Row>();
        DelItems = new list<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        BtlIncentive_List = new list<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        sbPriority_map = new map<string, list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>>();
        ROI_map = new map<string, SubBrandProrate>();
        HCROI_map = new map<string, SubBrandProrate>();
        HCROI_mapv0 = new map<string, SubBrandProrate>();
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> newsb = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> newsb1 = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        if (showCN == true){
            sbPriority_map.put('重点推荐品牌1', newsb);
            sbPriority_map.put('重点推荐品牌2', newsb1);
        }else{
            sbPriority_map.put('Priority 1', newsb);
            sbPriority_map.put('Priority 2', newsb1);
        }
        refreshSBPriority();
        
        map<id, string> sbgrade_map = new map<id, string>();
        sb_estimatebtl = new map<id, decimal>();
        Align_map = new map<string, ASI_CRM_CN_PreContract_AlignSetting__c>();

    }
    //Choose the right locale for User
    public void chooseLocale(){
        showCN = UserInfo.getLanguage()=='zh_CN';
    }
    //Check whether user is AD Above
    public void checkUserID(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }
    public ASI_CRM_CN_PreContractEval_Ctrl(ApexPages.StandardController controller) {
        hasV0 = false; //20160930, added by Leo
        lastPOChange = false; //20160930, added by Leo
        showCN = false;
        PageId = ApexPages.currentPage().getParameters().get('id');
        OutletId = ApexPages.currentPage().getParameters().get('OutletId');
        isTest = ApexPages.currentPage().getParameters().get('test');
        isTestDate = ApexPages.currentPage().getParameters().get('cutoff');
        isTestPCDate = ApexPages.currentPage().getParameters().get('date');
        UserId = UserInfo.getUserId();
        chooseLocale();
        checkUserID();
        
        if(ApexPages.currentPage().getParameters().get('cn')=='1') showCN=true;
    }
    
    //Only runs on ASI_CRM_CN_PreContractEval_Page
    public void RunEditData(){
        Init_Data();
        if (PageId != null){
            try{
                PC = [SELECT name, id, ASI_CRM_No_of_Months__c, ASI_CRM_Bottle_Incentive_Total__c, 
                      ASI_CRM_Variable_Event_Cost__c, ASI_CRM_Promotion_Service_Fee__c,
                      ASI_CRM_CN_Budget_Version__c, ASI_CRM_Contract_Total__c, ASI_CRM_CN_Last_Contract__c,
                      ASI_CRM_Variable_Cost__c, ASI_CRM_CN_Outlet__c,ASI_CRM_No_of_covered_outlet__c,
                      ASI_CRM_Fixed_Expense__c, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c, 
                      ASI_CRM_CN_Outlet__r.Name, ASI_CRM_Status__c, ASI_CRM_Monthly_Contract_Total_Vol_9LC__c, 
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,ASI_CRM_CN_Outlet__r.RecordType.DeveloperName,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, 
                      ASI_CRM_City__c,ASI_CRM_CN_Sub_Channel_Chi_Name__c,OwnerId,
                      ASI_CRM_Area__c, ASI_CRM_Image__c, ASI_CRM_OutletChannel__c,
                      ASI_CRM_Investment_per_Equiv_Chivas_12Y__c, CreatedDate, ASI_CRM_CN_VS_Total_APGS__c,
                      ASI_CRM_CN_Total_APGS__c, ASI_CRM_CN_Total_APGS_Aligned__c, ASI_CRM_CN_Last_Contract_TotalAPGS__c, ASI_CRM_CN_Total_Volume_9L__c
                      //20160929, added by Leo
                      ,ASI_CRM_CN_Last_V0_Contract_TradeExpense__c,ASI_CRM_CN_Last_V0_Contract_Volume_Total__c,ASI_CRM_CN_Last_V0_Contract_VarExpense__c
                      ,ASI_CRM_CN_Last_V0_Contract_FixedExpense__c,ASI_CRM_CN_Last_V0_Contract_FixExp_Rate__c,ASI_CRM_CN_Last_V0_Contract_Total_APGS__c
                      ,ASI_CRM_CN_Last_V0_Contract_InvestCR12__c,ASI_CRM_CN_Last_V0_Contract_ROI__c
                      ,ASI_CRM_CN_Last_V0_Contract_Pro_FormaROI__c
                      ,ASI_CRM_CN_Monthly_Volume__c
                      ,ASI_CRM_CN_Outlet__r.ASI_CRM_CN_NewChannel__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_New_Image__c

                      //20160929, added by Leo
                      from ASI_CRM_PreContractEval__c WHERE id = :PageId];
                NoMonths = MonthDiff(PC.ASI_CRM_Start_Date__c, PC.ASI_CRM_End_Date__c);  
            }catch(exception e){
                system.debug('Try getPC failed: ' + e);
                PC = new ASI_CRM_PreContractEval__c();
                PC.RecordTypeId = PCRecordTypeid;
                PC.ASI_CRM_No_of_covered_outlet__c = 1;
            }
            try{
                BtlIncentive_List = [SELECT id, ASI_CRM_Bottle_Incentive__c, ASI_CRM_Estimated_Btl_Month__c, 
                                     ASI_CRM_Grade__c, ASI_CRM_Sub_Brand__c, ASI_CRM_Total_Amount__c,
                                     ASI_CRM_Temp_Total_Amount__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                                     ASI_CRM_CN_Estimate_Volume_CR12_Month__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name
                                    ,ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c
                                     FROM ASI_CRM_Pre_Contract_Sub_Brand__c 
                                     WHERE ASI_CRM_Pre_Contract_Eval__c = :PageId];
            }catch(exception e){
                system.debug('Try BtlIncentive_List failed: ' + e);
                BtlIncentive_List = new list<ASI_CRM_Pre_Contract_Sub_Brand__c >();
            }
            if (BtlIncentive_List.size() > 0){
                set<id> sb_id = new set<id>();
                //decimal est_btl = 0;
                for (ASI_CRM_Pre_Contract_Sub_Brand__c  btl_temp : BtlIncentive_List ){
                    rows.add(new Row(Btl_rowid++, btl_temp));
                    sb_id.add(btl_temp.ASI_CRM_Sub_Brand__c);
                }
            }
            //Check if it is owner
            if (UserId == PC.OwnerId){
                isOwner = true;
            }else{
                isOwner = false;
            }
        }else{
            sbPriority_sc = new ASI_CRM_CN_Channel_Strategy__c();
            sbPriority_list = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            BtlIncentive_List = new list<ASI_CRM_Pre_Contract_Sub_Brand__c >();
            PC = new ASI_CRM_PreContractEval__c();
            PC.RecordTypeId = PCRecordTypeid;
            PC.ASI_CRM_No_of_covered_outlet__c = 1;
        }
        if (OutletId != null){
            PC.ASI_CRM_CN_Outlet__c = OutletId;       
        } 
        getLastPO();
        getOutletInfo();
        showPriority(); 
    }
    
    //20160926 Ben @ Elufa
    Public Void ViewPageInitAction(){
        
        Init_Data();
        if (PageId != null){
            try{
                PC = [SELECT name, id, ASI_CRM_No_of_Months__c, ASI_CRM_Bottle_Incentive_Total__c, 
                      ASI_CRM_Variable_Event_Cost__c, ASI_CRM_Promotion_Service_Fee__c,
                      ASI_CRM_CN_Budget_Version__c, ASI_CRM_Contract_Total__c, ASI_CRM_CN_Last_Contract__c,
                      ASI_CRM_Variable_Cost__c, ASI_CRM_CN_Outlet__c,ASI_CRM_No_of_covered_outlet__c,
                      ASI_CRM_Fixed_Expense__c, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c, 
                      ASI_CRM_CN_Outlet__r.Name, ASI_CRM_Status__c, ASI_CRM_Monthly_Contract_Total_Vol_9LC__c, 
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,ASI_CRM_CN_Outlet__r.RecordType.DeveloperName,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, 

                      ASI_CRM_CN_Last_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,
                      ASI_CRM_CN_Last_V0_Contract_Index__c,ASI_CRM_CN_Last_Contract_Index__c,ASI_CRM_CN_New_Contract_Index__c,ASI_CRM_CN_VS_Contract_Index__c,
                      ASI_CRM_CN_Contract_Index_Aligned__c ,ASI_CRM_CN_Last_V0_Regional_Index__c,
                      ASI_CRM_CN_Last_Regional_Index__c,ASI_CRM_CN_New_Regional_Index__c,
                      ASI_CRM_CN_VS_Regional_Index__c,ASI_CRM_CN_Regional_Index_Aligned__c,
                      ASI_CRM_CN_Last_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,

                      ASI_CRM_City__c,ASI_CRM_CN_Sub_Channel_Chi_Name__c,OwnerId,
                      ASI_CRM_Area__c, ASI_CRM_Image__c, ASI_CRM_OutletChannel__c,
                      ASI_CRM_Investment_per_Equiv_Chivas_12Y__c, CreatedDate, ASI_CRM_CN_VS_Total_APGS__c,
                      ASI_CRM_CN_Total_APGS__c, ASI_CRM_CN_Total_APGS_Aligned__c, ASI_CRM_CN_Last_Contract_TotalAPGS__c, ASI_CRM_CN_Total_Volume_9L__c
                      //20160929, added by Leo
                      ,ASI_CRM_CN_Last_V0_Contract_TradeExpense__c,ASI_CRM_CN_Last_V0_Contract_Volume_Total__c,ASI_CRM_CN_Last_V0_Contract_VarExpense__c
                      ,ASI_CRM_CN_Last_V0_Contract_FixedExpense__c,ASI_CRM_CN_Last_V0_Contract_FixExp_Rate__c,ASI_CRM_CN_Last_V0_Contract_Total_APGS__c
                      ,ASI_CRM_CN_Last_V0_Contract_InvestCR12__c,ASI_CRM_CN_Last_V0_Contract_ROI__c
                      ,ASI_CRM_CN_Last_V0_Contract_Pro_FormaROI__c
                      //20160929, added by Leo
                      ,ASI_CRM_CN_Monthly_Volume__c
                      ,ASI_CRM_CN_Outlet__r.ASI_CRM_CN_NewChannel__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Last_Contract_Trade_Expense__c
                      ,ASI_CRM_Total_Variable_Cost__c,ASI_CRM_CN_Last_Contract_Variable_Exp__c,
                      ASI_CRM_CN_Last_Contract_Fixed_Expense__c,ASI_CRM_CN_Last_Fixed_Exp_Rate__c,
                      ASI_CRM_CN_Fixed_Expense_Rate__c

                      from ASI_CRM_PreContractEval__c WHERE id = :PageId];
                NoMonths = MonthDiff(PC.ASI_CRM_Start_Date__c, PC.ASI_CRM_End_Date__c);            
            }catch(exception e){
                system.debug('Try getPC failed: ' + e);
                PC = new ASI_CRM_PreContractEval__c();
                PC.RecordTypeId = PCRecordTypeid;
                PC.ASI_CRM_No_of_covered_outlet__c = 1;
            }
            try{
                BtlIncentive_List = [SELECT id, ASI_CRM_Bottle_Incentive__c, ASI_CRM_Estimated_Btl_Month__c, 
                                     ASI_CRM_Grade__c, ASI_CRM_Sub_Brand__c, ASI_CRM_Total_Amount__c,
                                     ASI_CRM_Temp_Total_Amount__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                                     ASI_CRM_CN_Estimate_Volume_CR12_Month__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name
                                    ,ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c
                                    ,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c

                                     FROM ASI_CRM_Pre_Contract_Sub_Brand__c 
                                     WHERE ASI_CRM_Pre_Contract_Eval__c = :PageId];
            }catch(exception e){
                system.debug('Try BtlIncentive_List failed: ' + e);
                BtlIncentive_List = new list<ASI_CRM_Pre_Contract_Sub_Brand__c >();
            }
            System.debug(LoggingLevel.INFO, '*** BtlIncentive_List: ' + BtlIncentive_List);
            if (BtlIncentive_List.size() > 0){
                set<id> sb_id = new set<id>();
                //decimal est_btl = 0;
                for (ASI_CRM_Pre_Contract_Sub_Brand__c  btl_temp : BtlIncentive_List ){
                    rows.add(new Row(Btl_rowid++, btl_temp));
                    sb_id.add(btl_temp.ASI_CRM_Sub_Brand__c);
                }
            }
            System.debug(LoggingLevel.INFO, '*** rows: ' + rows);
            //Check if it is owner
            if (UserId == PC.OwnerId){
                isOwner = true;
            }else{
                isOwner = false;
            }
        }
        BtlIncentive_Total = 0;
        if (Rows.size() > 0){
            for (Row row: Rows){
                ASI_CRM_Pre_Contract_Sub_Brand__c r = row.Record;
                r.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pre_Contract_Sub_Brand__cCN_Pre_Contract_Sub_Brand');
                if (r.ASI_CRM_Bottle_Incentive__c != null && r.ASI_CRM_Estimated_Btl_Month__c != null)
                    BtlIncentive_Total += r.ASI_CRM_Estimated_Btl_Month__c * r.ASI_CRM_Bottle_Incentive__c;
            }
        }
        System.debug(LoggingLevel.INFO, '*** BtlIncentive_Total: ' + BtlIncentive_Total);
        getLastPO();
        // System.debug(LoggingLevel.INFO, '*** LastPO: ' + LastPO);
        lastPOChange = true;
        if(lastPOChange) //20160930, added by Leo
        {
            getOutletInfo();

            CalculatePC();
            // System.debug(LoggingLevel.INFO, '*** LastPO: ' + LastPO);
            //20160930, added by Leo
            if(hasV0)
            {
                CalculateV0PC();
            }
            // if (LastPO.ASI_CRM_CN_Is_2nd_KPI_PO__c)
                CalculateV0IndexPC();
            //20160930, added by Leo*/
            // CalculateIndexPC();
            // System.debug(LoggingLevel.INFO, '*** pc.ASI_CRM_CN_Last_V0_Contract_Index__c: ' + pc.ASI_CRM_CN_Last_V0_Contract_Index__c);
            Update PC;
            // System.debug(LoggingLevel.INFO, '*** pc.ASI_CRM_CN_Last_V0_Contract_Index__c: ' + pc.ASI_CRM_CN_Last_V0_Contract_Index__c);
        } //20160930, added by Leo
        if(PC.ASI_CRM_CN_Last_Contract_Volume_Total__c !=0 && PC.ASI_CRM_CN_Last_Contract_Volume_Total__c != null && PC.ASI_CRM_CN_Total_Volume_9L__c != null){
            VsVolume9L = (PC.ASI_CRM_CN_Total_Volume_9L__c/PC.ASI_CRM_CN_Last_Contract_Volume_Total__c - 1)*100;
            VsVolume9L = VsVolume9L.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VsVolume9L: ' + VsVolume9L);
        if(PC.ASI_CRM_CN_Last_Contract_Volume_Total__c != null && PC.ASI_CRM_CN_Total_Volume_9L__c != null){
            //VolumeAligned = Math.abs(PC.ASI_CRM_CN_Total_Volume_9L__c-PC.ASI_CRM_CN_Last_Contract_Volume_Total__c);
            VolumeAligned = PC.ASI_CRM_CN_Total_Volume_9L__c-PC.ASI_CRM_CN_Last_Contract_Volume_Total__c;
            VolumeAligned = VolumeAligned.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VolumeAligned: ' + VolumeAligned);
        if(PC.ASI_CRM_CN_Last_Contract_Trade_Expense__c != 0 && PC.ASI_CRM_CN_Last_Contract_Trade_Expense__c != null && PC.ASI_CRM_Contract_Total__c != null){
            VsTradeExpense = (PC.ASI_CRM_Contract_Total__c/PC.ASI_CRM_CN_Last_Contract_Trade_Expense__c - 1)*100;
            VsTradeExpense = VsTradeExpense.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VsTradeExpense: ' + VsTradeExpense);
        if(PC.ASI_CRM_Contract_Total__c != null && PC.ASI_CRM_CN_Last_Contract_Trade_Expense__c != null){
            //TradeExpenseAligned = Math.abs(PC.ASI_CRM_Contract_Total__c-PC.ASI_CRM_CN_Last_Contract_Trade_Expense__c);
            TradeExpenseAligned = PC.ASI_CRM_Contract_Total__c-PC.ASI_CRM_CN_Last_Contract_Trade_Expense__c;
            TradeExpenseAligned = TradeExpenseAligned.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** TradeExpenseAligned: ' + TradeExpenseAligned);
        if(PC.ASI_CRM_CN_Last_Contract_Variable_Exp__c != 0 && PC.ASI_CRM_Total_Variable_Cost__c != null && PC.ASI_CRM_CN_Last_Contract_Variable_Exp__c != null){
            VsVariableExpense = (PC.ASI_CRM_Total_Variable_Cost__c/PC.ASI_CRM_CN_Last_Contract_Variable_Exp__c - 1)*100;
            VsVariableExpense = VsVariableExpense.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VsVariableExpense: ' + VsVariableExpense);
        if(PC.ASI_CRM_Total_Variable_Cost__c != null && PC.ASI_CRM_CN_Last_Contract_Variable_Exp__c != null){
            //VariableExpenseAligned = Math.abs(PC.ASI_CRM_Total_Variable_Cost__c-PC.ASI_CRM_CN_Last_Contract_Variable_Exp__c);
            VariableExpenseAligned = PC.ASI_CRM_Total_Variable_Cost__c-PC.ASI_CRM_CN_Last_Contract_Variable_Exp__c;
            VariableExpenseAligned = VariableExpenseAligned.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VariableExpenseAligned: ' + VariableExpenseAligned);
        if(PC.ASI_CRM_CN_Last_Contract_Fixed_Expense__c != 0 && PC.ASI_CRM_Fixed_Expense__c != null && PC.ASI_CRM_CN_Last_Contract_Fixed_Expense__c != null){
            VsFixedExpense = (PC.ASI_CRM_Fixed_Expense__c/PC.ASI_CRM_CN_Last_Contract_Fixed_Expense__c - 1)*100;
            VsFixedExpense = VsFixedExpense.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VsFixedExpense: ' + VsFixedExpense);
        if(PC.ASI_CRM_Fixed_Expense__c != null && PC.ASI_CRM_CN_Last_Contract_Fixed_Expense__c != null){
            //FixedExpenseAligned = Math.abs(PC.ASI_CRM_Fixed_Expense__c-PC.ASI_CRM_CN_Last_Contract_Fixed_Expense__c);
            FixedExpenseAligned = PC.ASI_CRM_Fixed_Expense__c-PC.ASI_CRM_CN_Last_Contract_Fixed_Expense__c;
            FixedExpenseAligned = FixedExpenseAligned.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** FixedExpenseAligned: ' + FixedExpenseAligned);
        if(PC.ASI_CRM_CN_Last_Fixed_Exp_Rate__c != 0 && PC.ASI_CRM_CN_Fixed_Expense_Rate__c != null && PC.ASI_CRM_CN_Last_Fixed_Exp_Rate__c != null){
            VsFixedExpenseRate = (PC.ASI_CRM_CN_Fixed_Expense_Rate__c/PC.ASI_CRM_CN_Last_Fixed_Exp_Rate__c - 1)*100;
            VsFixedExpenseRate = VsFixedExpenseRate.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VsFixedExpenseRate: ' + VsFixedExpenseRate);
        if(PC.ASI_CRM_CN_Fixed_Expense_Rate__c != null && PC.ASI_CRM_CN_Last_Fixed_Exp_Rate__c != null){
            //FixedExpenseRateAligned = Math.abs(PC.ASI_CRM_CN_Fixed_Expense_Rate__c-PC.ASI_CRM_CN_Last_Fixed_Exp_Rate__c);
            FixedExpenseRateAligned = PC.ASI_CRM_CN_Fixed_Expense_Rate__c-PC.ASI_CRM_CN_Last_Fixed_Exp_Rate__c;
            FixedExpenseRateAligned = FixedExpenseRateAligned.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** FixedExpenseRateAligned: ' + FixedExpenseRateAligned);
        if(PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c != 0 && PC.ASI_CRM_CN_Total_APGS__c != null && PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c != null){
            VsTotalAPGS = (PC.ASI_CRM_CN_Total_APGS__c/PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c - 1)*100;
            VsTotalAPGS = VsTotalAPGS.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VsTotalAPGS: ' + VsTotalAPGS);
        if(PC.ASI_CRM_CN_Total_APGS__c != null && PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c != null){
            //TotalAPGSAligned = Math.abs(PC.ASI_CRM_CN_Total_APGS__c-PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c);
            TotalAPGSAligned = PC.ASI_CRM_CN_Total_APGS__c-PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c;
            TotalAPGSAligned = TotalAPGSAligned.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** TotalAPGSAligned: ' + TotalAPGSAligned);

        if(PC.ASI_CRM_CN_Last_Contract_Index__c != 0 && PC.ASI_CRM_CN_New_Contract_Index__c != null && PC.ASI_CRM_CN_Last_Contract_Index__c != null){
            VSContractIndex = (PC.ASI_CRM_CN_New_Contract_Index__c/PC.ASI_CRM_CN_Last_Contract_Index__c - 1)*100;
            VSContractIndex = VSContractIndex.setScale(2, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** VSContractIndex: ' + VSContractIndex);
        if(PC.ASI_CRM_CN_New_Contract_Index__c != null && PC.ASI_CRM_CN_Last_Contract_Index__c != null){
            //ContractIndexAligned = Math.abs(PC.ASI_CRM_CN_New_Contract_Index__c-PC.ASI_CRM_CN_Last_Contract_Index__c);
            ContractIndexAligned = PC.ASI_CRM_CN_New_Contract_Index__c-PC.ASI_CRM_CN_Last_Contract_Index__c;
            ContractIndexAligned = ContractIndexAligned.setScale(0, System.RoundingMode.HALF_UP);
        }
        System.debug(LoggingLevel.INFO, '*** ContractIndexAligned: ' + ContractIndexAligned);

    }
    //20160926 End
    
    //20200710 add
    public void CalculateV0IndexPC() {

        // List<ASI_Attachment__c> AttachmentList= ;

        System.debug(LoggingLevel.INFO, '*** LastPO: ' + LastPO);
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalVFinalContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();

        // if(AttachmentList.size()>0){
            Boolean contractDateFlag = false;
            for(ASI_Attachment__c att:[SELECT id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,
                                                    ASI_CRM_Type__c,
                                                        ASI_CRM_Historical_Financial_Data2__c,
                                                        ASI_CRM_Historical_Financial_Data3__c,ASI_CRM_Historical_Financial_Data4__c
                                        FROM ASI_Attachment__c 
                                        WHERE ((ASI_CRM_Contract__c = :LastPO.Id AND (ASI_CRM_Type__c ='PO Modification Data' OR  ASI_CRM_Type__c ='Contract Data' ))
                                           OR (ASI_CRM_Type__c ='Contract Data' AND ASI_CRM_Contract__c = :LastPO.ASI_CRM_CN_V0_0_PO_version__c)) AND ASI_CRM_Contract__c!=null AND ASI_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c = true order by createddate]){ 
                String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');
                List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class); 
                if(att.ASI_CRM_Type__c=='PO Modification Data' && ContractList.size()>0 ){
                    HistoricalVFinalContract2nd= ContractList[0]; //POModiContractFI
                }else if(att.ASI_CRM_Type__c=='Contract Data' && ContractList.size()>0 && !contractDateFlag){
                    HistoricalV00Contract2nd = ContractList[0];
                    // NewContactV0Contract = ContractList[1];
                    contractDateFlag = true;
                }
            }
        // }

        if (HistoricalVFinalContract2nd.ContractId == null || HistoricalVFinalContract2nd.ContractId == '') {
            HistoricalVFinalContract2nd = HistoricalV00Contract2nd;
        } 
        pc.ASI_CRM_CN_Last_V0_Contract_Index__c = HistoricalV00Contract2nd.DomesticContractIndexProForma != null?HistoricalV00Contract2nd.DomesticContractIndexProForma:null;

        if (HistoricalVFinalContract2nd.DomesticContractIndexProForma != null) {
            pc.ASI_CRM_CN_Last_Contract_Index__c = HistoricalVFinalContract2nd.DomesticContractIndexProForma;
        } else {
            pc.ASI_CRM_CN_Last_Contract_Index__c = pc.ASI_CRM_CN_Last_V0_Contract_Index__c ;
        }

        // pc.ASI_CRM_CN_New_Contract_Index__c = NewContactV0Contract2nd.DomesticContractIndexProForma != null ? NewContactV0Contract2nd.DomesticContractIndexProForma : null;

        pc.ASI_CRM_CN_Last_V0_Regional_Index__c = HistoricalV00Contract2nd.VsRegionalAverageIndexProForma != null?HistoricalV00Contract2nd.VsRegionalAverageIndexProForma:null;

        if (HistoricalVFinalContract2nd.VsRegionalAverageIndexProForma != null) {
            pc.ASI_CRM_CN_Last_Regional_Index__c = HistoricalVFinalContract2nd.VsRegionalAverageIndexProForma;
        } else {
            pc.ASI_CRM_CN_Last_Regional_Index__c = pc.ASI_CRM_CN_Last_V0_Regional_Index__c;
        }
        System.debug(LoggingLevel.INFO, '*** preContract2nd: ' + preContract2nd);
        investmentBySubBrandByContractBySubBrand = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
                new List<String>{'historicalV0' ,'historical','preContract2nd'},
                new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract2nd, HistoricalVFinalContract2nd,preContract2nd}
            );
        System.debug(LoggingLevel.INFO, '*** investmentBySubBrandByContractBySubBrand: ' + investmentBySubBrandByContractBySubBrand);
        Set<String> subbrandIds = new Set<String>();
        SubbrandVolume sub999 = new SubbrandVolume();
        subbrandList = new List<SubbrandVolume>();
        List<SubbrandVolume> historicSubbrandList = new List<SubbrandVolume>();
        List<SubbrandVolume> conSubbrandList = new List<SubbrandVolume>();
        ASI_MFM_Sub_brand__c subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1];
        for (String key : investmentBySubBrandByContractBySubBrand.keySet()) {
            Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> subbrandExpenseMap = investmentBySubBrandByContractBySubBrand.get(key);
            if (subbrandExpenseMap.containsKey('preContract2nd')) {
                if (subbrand999.Id != key) {
                    if (subbrandExpenseMap.get('preContract2nd').volumeSTD == null || subbrandExpenseMap.get('preContract2nd').volumeSTD == 0) {
                        if (subbrandExpenseMap.get('historical').volumeSTD != null && subbrandExpenseMap.get('historical').volumeSTD != 0) {
                            SubbrandVolume sv = new SubbrandVolume();
                            sv.subbrandId = key;
                            sv.volume = subbrandExpenseMap.get('historical').volumeSTD;
                            conSubbrandList.add(sv);
                            subbrandIds.add(key);
                        } else {
                            if (subbrandExpenseMap.get('historicalV0').volumeSTD != null && subbrandExpenseMap.get('historicalV0').volumeSTD != 0) {
                                SubbrandVolume sv = new SubbrandVolume();
                                sv.subbrandId = key;
                                sv.volume = subbrandExpenseMap.get('historicalV0').volumeSTD;
                                historicSubbrandList.add(sv);
                                subbrandIds.add(key);
                            }
                        }
                    } else {
                        SubbrandVolume sv = new SubbrandVolume();
                        sv.subbrandId = key;
                        sv.volume = subbrandExpenseMap.get('preContract2nd').volumeSTD;
                        subbrandList.add(sv);
                        subbrandIds.add(key);
                    }
                } else {
                    sub999.subbrandId = key;
                    sub999.volume = subbrandExpenseMap.get('preContract2nd').volumeSTD;
                    subbrandIds.add(key);
                }
            }
        }

        for(Integer i = 1; i< subbrandList.size(); i++) {
            Integer j;
            SubbrandVolume temp = subbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(subbrandList[j].volume < temp.volume) {
                    subbrandList[j+1] = subbrandList[j];
                }else{
                    break;
                }
            }
            subbrandList[j+1]=temp;
        }

        for(Integer i = 1; i< conSubbrandList.size(); i++) {
            Integer j;
            SubbrandVolume temp = conSubbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(conSubbrandList[j].volume < temp.volume) {
                    conSubbrandList[j+1] = conSubbrandList[j];
                }else{
                    break;
                }
            }
            conSubbrandList[j+1]=temp;
        }

        for(Integer i = 1; i< historicSubbrandList.size(); i++) {
            Integer j;
            SubbrandVolume temp = historicSubbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(historicSubbrandList[j].volume < temp.volume) {
                    historicSubbrandList[j+1] = historicSubbrandList[j];
                }else{
                    break;
                }
            }
            historicSubbrandList[j+1]=temp;
        }

        subbrandList.addAll(conSubbrandList);
        subbrandList.addAll(historicSubbrandList);

        if (String.isNotBlank(sub999.subbrandId)) {
            Ishave999 = true;
            if (subbrandList.size() > 21) {
                subbrandList.add(20, sub999);
            } else {
                subbrandList.add(sub999);
            }
        }


        TotalHistoricalBottles = 0;
        TotalEstimateBottles = 0;
        TotalContractBottles = 0;

        AllHistoricalTotalFees = 0;
        AllEstimateTotalFees = 0;
        AllContractTotalFees = 0;
        for (SubbrandVolume sv : subbrandList) {
            TotalHistoricalBottles += investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historicalV0').monthlyVolumeSTD != null ? investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historicalV0').monthlyVolumeSTD : 0;

            TotalEstimateBottles += investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historical').monthlyVolumeSTD != null ? investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historical').monthlyVolumeSTD : 0;

            // TotalContractBottles += investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('contract').monthlyVolumeSTD != null ? investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('contract').monthlyVolumeSTD : 0;

            AllHistoricalTotalFees += investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historicalV0').totalTradeExpense != null ? investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historicalV0').totalTradeExpense : 0;

            AllEstimateTotalFees += investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historical').totalTradeExpense != null ? investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('historical').totalTradeExpense : 0;

            AllContractTotalFees += investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('preContract2nd').totalTradeExpense != null ? investmentBySubBrandByContractBySubBrand.get(sv.subbrandId).get('preContract2nd').totalTradeExpense : 0;
        }

        subbrandNameMap = new Map<String,String>();
        // System.debug(LoggingLevel.INFO, '*** groupStr: ' + groupStr);
        for (ASI_MFM_Sub_brand__c sb : [SELECT Name,Id,ASI_HK_CRM_English_Name__c,ASI_CRM_CN_CHI_NAME_C__c FROM ASI_MFM_Sub_brand__c WHERE Id IN: subbrandIds]) {
            if (!showCN) {
                subbrandNameMap.put(sb.Id, sb.ASI_HK_CRM_English_Name__c);
            } else {
                subbrandNameMap.put(sb.Id, sb.ASI_CRM_CN_CHI_NAME_C__c);
            }
        }

        // pc.ASI_CRM_CN_New_Regional_Index__c = NewContactV0Contract2nd.VsRegionalAverageIndexProForma != null ? NewContactV0Contract2nd.VsRegionalAverageIndexProForma : null;
    }

    public void getOutletInfo(){
        system.debug('getOutletInfo()');
        if (PC.ASI_CRM_CN_Outlet__c != null){
            try{
                Outlet_acc = [SELECT id, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, ASI_CRM_CN_Image__c, ASI_CRM_CN_Sub_Channel__c,
                              ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.Name, ASI_CRM_CN_CCity__r.Name,
                              ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                              ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Chi_Name__c,
                              ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,
                              ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c,
                              ASI_CRM_CN_Is_IHBR_Outlet__c
                              FROM ASI_CRM_AccountsAdditionalField__c WHERE id = :PC.ASI_CRM_CN_Outlet__c ];
            }catch(exception e){
                Outlet_acc = new ASI_CRM_AccountsAdditionalField__c();
            }
        }else{
            Outlet_acc = new ASI_CRM_AccountsAdditionalField__c();
        }
    }
    public void showPriority(){
        //has to be followed after getOutletInfo();
        system.debug('showPriority() Outlet_acc: ' + Outlet_acc );
        //if (Outlet_acc != null){
        if (Outlet_acc != null){
            string sc_rtid = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy__cASI_CRM_CN_Area');
            string scol_rtid = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
            try{
                sbPriority_sc = [SELECT id
                                 FROM ASI_CRM_CN_Channel_Strategy__c 
                                 WHERE RecordTypeId = :sc_rtid 
                                 //  AND ASI_CRM_CN_FY_Start_Date__c <= :PC.ASI_CRM_Start_Date__c
                                 AND ASI_CRM_CN_FY_Start_Date__c <= TODAY
                                 AND ASI_CRM_CN_Area__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c 
                                 AND ASI_CRM_CN_Image__c = :Outlet_acc.ASI_CRM_CN_Image__c
                                 AND ASI_CRM_CN_Sub_Channel__c = :Outlet_acc.ASI_CRM_CN_Sub_Channel__c
                                 AND ASI_CRM_CN_Status__c = 'Final' 
                                 AND ASI_CRM_CN_Strategy_Type__c = 'Area Strategy'
                                 ORDER BY ASI_CRM_CN_FY_End_Date__c DESC LIMIT 1];
            }catch(exception e){
                system.debug('Try Area Strategy Failed: ' + e);
                try{
                    sbPriority_sc = [SELECT id
                                     FROM ASI_CRM_CN_Channel_Strategy__c 
                                     //  WHERE ASI_CRM_CN_FY_Start_Date__c <= :PC.ASI_CRM_Start_Date__c
                                     WHERE ASI_CRM_CN_FY_Start_Date__c <= TODAY
                                     //AND ASI_CRM_CN_Area__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c 
                                     AND ASI_CRM_CN_Image__c = :Outlet_acc.ASI_CRM_CN_Image__c
                                     AND ASI_CRM_CN_Sub_Channel__c = :Outlet_acc.ASI_CRM_CN_Sub_Channel__c
                                     AND ASI_CRM_CN_Status__c = 'Final' 
                                     AND ASI_CRM_CN_Strategy_Type__c = 'National Strategy'
                                     ORDER BY ASI_CRM_CN_FY_End_Date__c DESC LIMIT 1];
                }catch(exception ae){
                    sbPriority_sc = new ASI_CRM_CN_Channel_Strategy__c();
                }  
            }
            system.debug('sbPriority_sc: ' + sbPriority_sc );               
            if (sbPriority_sc != null){
                try{
                    sbPriority_list = [SELECT id, ASI_CRM_CN_Brand__c, ASI_CRM_CN_Sub_brand__c
                                       FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c
                                       WHERE ASI_CRM_CN_Channel_Strategy__c = :sbPriority_sc.id
                                       AND RecordTypeId = :scol_rtid];
                    
                }catch(exception e){
                    sbPriority_list = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
                }
            }else{
                sbPriority_list = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            }
            system.debug('sbPriority_list: ' + sbPriority_list );
            if (sbPriority_list.size() > 0){
                string strbrand;
                for (ASI_CRM_CN_Channel_Strategy_Line_Item__c sbtemp : sbPriority_list ){
                    system.debug('showCN: ' + showCN);
                    if (showCN == true){
                        if ( sbtemp.ASI_CRM_CN_Brand__c == 'Priority 1'){
                            strbrand = '重点推荐品牌1';
                        }
                        if ( sbtemp.ASI_CRM_CN_Brand__c == 'Priority 2'){
                            strbrand = '重点推荐品牌2';
                        }
                    }else{
                        strbrand = sbtemp.ASI_CRM_CN_Brand__c;
                    }
                    system.debug('strbrand: ' + strbrand );
                    if (sbPriority_map.containskey(strbrand)){
                        sbPriority_map.get(strbrand).add(sbtemp);
                    }
                }
                system.debug('sbPriority_map: ' + sbPriority_map);
            } 
        }
    }
    public void getLastPO(){
        system.debug('getLastPO()');
        LastPOnotEnd = false;
        if (PC.ASI_CRM_CN_Outlet__c != null){
            date strDate;
            Integer strDays; //Criteria within 6 Months (from today)
            strDays = 365/12*6;
            if (isTest == '1' && isTestPCDate != null && isTestPCDate != ''){
                strDate = Date.newinstance(integer.valueof(isTestPCDate.LEFT(4)), integer.valueof((isTestPCDate.LEFT(6)).RIGHT(2)), integer.valueof(isTestPCDate.RIGHT(2)));
            }else{
                //20161031, Leo@Elufa
                if(PC.ASI_CRM_Start_Date__c != null)
                {
                    strDate = PC.ASI_CRM_Start_Date__c - strDays;
                    //System.assertequals(null,strDate);
                }
                else
                {
                    strDate = Date.Today() - strDays;
                }
                //20161031, Leo@Elufa
                //strDate = Date.Today() - strDays; //20161031, Leo@Elufa
            }
            set<string> PromotionType = new set<string>();
   //          PromotionType.add('New Contract ON');
   //          PromotionType.add('New Contract OFF');
   //          //20160926 Ben @ Elufa
            // PromotionType.add('Contract ON');
   //          PromotionType.add('Contract OFF');
            PromotionType.add('Heavy Contract On');
            //21060926 End
            //if (PC.ASI_CRM_CN_Last_Contract__c == null){
                try{
                    LastPO = [SELECT id, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,
                              ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                              ASI_CRM_CN_BRSF_Contract_Total__c,
                              ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,ASI_CRM_CN_Total_Contract_Amount__c ,
                              ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,
                              ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c
                              , ASI_CRM_CN_V0_0_PO_version__c//20160928 Ben @ Elufa
                              , ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c //20160930, added by Leo
                              , ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c
                              , ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Is_2nd_KPI_PO__c //20160930, added by Leo
                              , ASI_CRM_CN_PO_Version__c//20170125 Elufa
                              FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_Outlet_WS__c = :PC.ASI_CRM_CN_Outlet__c
                              AND ASI_CRM_CN_PO_End_Date__c >= :strDate
                              AND ASI_CRM_CN_PO_End_Date__c != null AND ASI_CRM_CN_PO_Start_Date__c != null 
                              AND ASI_TH_CRM_Promotion_Type__c IN :PromotionType
                              AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived' OR ASI_CRM_CN_Status__c = 'Submitted')
                              ORDER BY ASI_CRM_CN_PO_End_Date__c DESC, ASI_CRM_CN_PO_Version__c DESC LIMIT 1];

                }catch(exception e){
                    LastPO = new ASI_TH_CRM_Contract__c();
                }
            
            //20170120, edited by Leo
            if(LastPO!=null && LastPO.Id!=null)
            {
                List<ASI_TH_CRM_Contract__c> checkLatest 
                    = new List<ASI_TH_CRM_Contract__c>([SELECT id FROM ASI_TH_CRM_Contract__c 
                                                        WHERE ASI_CRM_CN_Last_PO_version__c =: LastPO.Id AND ASI_CRM_CN_Status__c != 'Draft']);
                if(checkLatest.size()>0)
                {
                    LastPO = new ASI_TH_CRM_Contract__c();
                }
            }
            //20170120, edited by Leo
            
            //20160930, added by Leo
            //if(LastPO.id != null && PC.ASI_CRM_CN_Last_Contract__c != LastPO.id)
            if((LastPO.id != null && PC.ASI_CRM_CN_Last_Contract__c != LastPO.id)||(PC.ASI_CRM_CN_Last_Contract__c != null && LastPO.id==null)) //20161031, added by Leo
                lastPOChange = true;
            //20160930, added by Leo
            if(Test.isRunningTest()|| (LastPO!=null && LastPO.Id!=null)){
                PC.ASI_CRM_CN_Last_Contract__c = LastPO.id;
                //20160930, added by Leo
                if(LastPO.ASI_CRM_CN_V0_0_PO_version__c != null)
                {
                    hasV0 = true;
                    v0Contract = LastPO.ASI_CRM_CN_V0_0_PO_version__c;
                    v0StartD = LastPO.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c;
                    v0EndD = LastPO.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c;
                }else if(LastPO.ASI_CRM_CN_PO_Version__c == '0.0'){//20170125 Elufa
                    hasV0 = true;
                    v0Contract = LastPO.id;
                    v0StartD = LastPO.ASI_CRM_CN_PO_Start_Date__c;
                    v0EndD = LastPO.ASI_CRM_CN_PO_End_Date__c;
                }
            }
                         
                //20160930, added by Leo
            /*}else{
                try{
                    LastPO = [SELECT id, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,
                              ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                              ASI_CRM_CN_BRSF_Contract_Total__c,
                              ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,ASI_CRM_CN_Total_Contract_Amount__c ,
                              ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,
                              ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c
                              FROM ASI_TH_CRM_Contract__c WHERE id = :PC.ASI_CRM_CN_Last_Contract__c];
                }catch(exception e){
                    LastPO = new ASI_TH_CRM_Contract__c();
                }
            }*/
        }
    }
    public pagereference refreshSBPriority(){
        system.debug('refreshSBPriority()');
        for (string a : sbPriority_map.keyset()){
            sbPriority_map.get(a).clear();
        }
        system.debug('sbPriority_map.clear(): ' + sbPriority_map);
        showPriority();
        //refreshBtlAmount();
        return null;
    }
    public void getSBGrade(){
        if (sb_id.size() > 0){
            try{
                sb_grade = [SELECT id, ASI_CRM_CN_Sub_brand_Grade__r.Name FROM ASI_MFM_Sub_brand__c
                            WHERE id IN :sb_id];
            }catch(exception e){
                system.debug('Try sb_grade failed: ' + e);
                sb_grade = new list<ASI_MFM_Sub_brand__c>();
            }
        }
        
        if (sb_grade.size() > 0){
            sbgrade_map = new map<id, string>();
            for (ASI_MFM_Sub_brand__c sbgradetemp : sb_grade){
                if (sbgradetemp.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    if (!sbgrade_map.containskey(sbgradetemp.id))
                        sbgrade_map.put(sbgradetemp.id, sbgradetemp.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                }else{
                    sbgrade_map.put(sbgradetemp.id, 'Not Specified');
                }
            }
            system.debug('sbgrade_map: ' + sbgrade_map);
        }
        if (sbgrade_map != null && sbgrade_map.size() > 0){
            for (Row r :Rows) {
                string sbid = r.Record.ASI_CRM_Sub_Brand__c;
                if (sbgrade_map.containskey(sbid)){
                    r.Record.ASI_CRM_Grade__c = sbgrade_map.get(sbid);
                }
                //system.debug('sbid: ' + sbid);
            }
        }
    }
    
    public void refreshBottleIncentive(){
        refreshBtlAmount();
        refreshSBGrade();
        
    }
    public void refreshSBGrade(){
        if (Rows.size() > 0){
            sb_id = new set<id>();
            for (Row r :Rows) {
                sb_id.add(r.Record.ASI_CRM_Sub_Brand__c);
            }
            getSBGrade();
        }
    }
    public void refreshBtlAmount(){
        if (PC.ASI_CRM_Start_Date__c == null || PC.ASI_CRM_End_Date__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'请输入合同起始日期.'));
        }
        if (PC.ASI_CRM_Start_Date__c != null && PC.ASI_CRM_End_Date__c != null){
            NoMonths = MonthDiff(PC.ASI_CRM_Start_Date__c, PC.ASI_CRM_End_Date__c);
            if (Rows.size() > 0){
                for (Row row :Rows){
                    ASI_CRM_Pre_Contract_Sub_Brand__c r = row.Record;
                    if (r.ASI_CRM_Bottle_Incentive__c != null && r.ASI_CRM_Estimated_Btl_Month__c != null){
                        r.ASI_CRM_Temp_Total_Amount__c = r.ASI_CRM_Bottle_Incentive__c * r.ASI_CRM_Estimated_Btl_Month__c * NoMonths;
                    }else if (r.ASI_CRM_Bottle_Incentive__c == null){
                        r.ASI_CRM_Temp_Total_Amount__c = 0;
                    }
                }
            }
        }
    }
    public pagereference AddNew(){
        //refreshBottleIncentive();
        ASI_CRM_Pre_Contract_Sub_Brand__c b = new ASI_CRM_Pre_Contract_Sub_Brand__c();
        b.ASI_CRM_Pre_Contract_Eval__c = PC.id;
        Rows.add(new Row(Btl_rowid++, b));
        return null;
    }
    public pagereference RemoveRow(){
        for(integer i=Rows.size()-1; i>=0; i--) {
            Row r = Rows[i];
            if(r.Index==rowid) {
                DelItems.add(r.Record);
                Rows.remove(i);
            }
        }
        return null;
    }
    public pageReference SaveAll(){
        
        //validation
        {
            boolean abort = false;
            boolean subbrandError = false;
            boolean estBtlMonthError = false;
            boolean btlIncentiveError = false;
            for(Row r: Rows) {
                if(r.Record.ASI_CRM_Sub_Brand__c==null && !subbrandError) {
                    abort = true;
                    subbrandError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'空值：请选择子品牌'));
                }
                if(r.EstBtlMonth==null && !estBtlMonthError) {
                    abort = true;
                    estBtlMonthError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'空值：请输入预计每月销量（标准瓶）'));
                }
                if(r.BtlIncentive==null && !btlIncentiveError) {
                    abort = true;
                    btlIncentiveError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'空值：请输入空瓶回收费（每瓶）'));
                }
            }
            if(abort) {
                return null;
            }
        }
        
        
        NoMonths = MonthDiff(PC.ASI_CRM_Start_Date__c, PC.ASI_CRM_End_Date__c);
        showError = false;
        try{
            if (PC.id != null)
                update PC;
            else
                insert PC;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'不能保存合同试算.'));
            return null;
        }
        
        refreshBottleIncentive();
        
        BtlIncentive_Total = 0;    
        System.debug(LoggingLevel.INFO, '*** Rows: ' + Rows);
        if (Rows.size() > 0){
            list<ASI_CRM_Pre_Contract_Sub_Brand__c> InsertBtl_List = new list<ASI_CRM_Pre_Contract_Sub_Brand__c>();
            list<ASI_CRM_Pre_Contract_Sub_Brand__c> UpdateBtl_List = new list<ASI_CRM_Pre_Contract_Sub_Brand__c>();
            for (Row row: Rows){
                ASI_CRM_Pre_Contract_Sub_Brand__c r = row.Record;
                r.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pre_Contract_Sub_Brand__cCN_Pre_Contract_Sub_Brand');
                if (r.ASI_CRM_Bottle_Incentive__c != null && r.ASI_CRM_Estimated_Btl_Month__c != null){
                    r.ASI_CRM_Temp_Total_Amount__c = r.ASI_CRM_Bottle_Incentive__c * r.ASI_CRM_Estimated_Btl_Month__c * NoMonths;
                }else if (r.ASI_CRM_Bottle_Incentive__c == null){
                    r.ASI_CRM_Temp_Total_Amount__c = 0;
                }
                if (r.id != null){
                    UpdateBtl_List.add(r);
                }else{
                    r.ASI_CRM_Pre_Contract_Eval__c = PC.id;
                    InsertBtl_List.add(r);
                }
                if (r.ASI_CRM_Bottle_Incentive__c != null && r.ASI_CRM_Estimated_Btl_Month__c != null)
                    BtlIncentive_Total += r.ASI_CRM_Estimated_Btl_Month__c * r.ASI_CRM_Bottle_Incentive__c;
            }
            
            system.debug('UpdateBtl_List: ' + UpdateBtl_List);
            system.debug('InsertBtl_List: ' + InsertBtl_List);
            try{
                if (UpdateBtl_List.size() > 0)
                    update UpdateBtl_List;
            }catch(exception e){
                system.debug('Try updateBtl_list: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'无法更新现有空瓶回收费.'));
            }
            Try{
                if (InsertBtl_List.size() > 0)
                    insert InsertBtl_List;
            }catch(exception e){
                system.debug('Try InsertBtl_List: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'无法插入新空瓶回收费条目.'));
            }
        }
        if (DelItems.size() > 0 ){
            list<ASI_CRM_Pre_Contract_Sub_Brand__c> delList = new list<ASI_CRM_Pre_Contract_Sub_Brand__c >();
            for (ASI_CRM_Pre_Contract_Sub_Brand__c deltemp : DelItems){
                if (deltemp.id != null){
                    delList.add(deltemp);
                }
            }
            try{
                if (delList.size() > 0){
                    delete delList;
                }
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'无法删除空瓶回收费条目.'));
            }
            DelItems.clear();
        }
        return null;
    }
    
    public PageReference view() {
        SaveAll();
        // CalculatePC();
        // //20160930, added by Leo
        // if(hasV0)
        // {
        //     getOutletInfo();
        //     CalculateV0PC();
        // }
        // // if (LastPO.ASI_CRM_CN_Is_2nd_KPI_PO__c)
        // CalculateV0IndexPC();
        // //20160930, added by Leo*/
        
        // try{
        //     update PC;
        // }catch(exception e){
        //     system.debug('Save Error: ' + e);
        //     showError = true;
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'不能保存合同试算'));
        // }
        PageReference pg = Page.ASI_CRM_CN_PreContractEvalView;
        pg.getParameters().put('id', PC.Id);
        pg.setredirect(true);
        return pg;
    }
    
    public void CalculatePC(){
        NoMonths = MonthDiff(PC.ASI_CRM_Start_Date__c, PC.ASI_CRM_End_Date__c);
        //Last PO Total Volume 9L
        decimal TotalBRSF_Est_Cost = 0;
        decimal TotalFixed_Cost = 0;
        decimal TotalVar_Cost = 0;
        set<id> lastBRSF_set = new set<id>();
        // Added by Alan Wong (Elufa) 20160608
        Map<id, decimal> LatestBudget_Map = new Map<id, decimal>();
        Map<id, decimal> HCLatestBudget_Map = new Map<id, decimal>();  
        date FYLatestDate = checkFYDate(Date.today());
        integer CurrentFiscalYear = FYLatestDate.year();
        // -- End -- //
        system.debug('PC.ASI_CRM_CN_Last_Contract__c : ' + PC.ASI_CRM_CN_Last_Contract__c );
        if (PC.ASI_CRM_CN_Last_Contract__c != null){
            list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> Last_BRSF_List = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            try{
                Last_BRSF_List = [SELECT ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Est_Total__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                  WHERE ASI_CRM_CN_Contract__c = :PC.ASI_CRM_CN_Last_Contract__c ];
            }catch(exception e){
                system.debug('Try Last Contract BRSF: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Last contract does not exist BRSF list.'));
            }
            system.debug('Last_BRSF_List: ' + Last_BRSF_List);
            if (Last_BRSF_List.size() > 0){
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lastbrsf_temp : Last_BRSF_List ){
                    lastBRSF_set.add(lastbrsf_temp.ASI_CRM_CN_Sub_Brand__c);
                    TotalBRSF_Est_Cost += lastbrsf_temp.ASI_CRM_CN_Est_Total__c;
                }
            }
            list<ASI_CRM_Contract_Cost__c> Last_CostList = new list<ASI_CRM_Contract_Cost__c>();
            try{
                Last_CostList = [SELECT ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Estimate_Amount__c
                                 FROM ASI_CRM_Contract_Cost__c
                                 WHERE ASI_CRM_CN_Contract__c = :PC.ASI_CRM_CN_Last_Contract__c ];
            }catch(exception e){
                system.debug('Try Last_CostList Failed: ' + e);
            }
            if (Last_CostList.size() > 0){
                for (ASI_CRM_Contract_Cost__c last_cost_temp : Last_CostList ){
                    if (last_cost_temp.ASI_CRM_CN_Estimate_Amount__c != null){
                        if (last_cost_temp.ASI_CRM_CN_Cost_Type__c == 'Fixed')
                            TotalFixed_Cost += last_cost_temp.ASI_CRM_CN_Estimate_Amount__c;
                        if (last_cost_temp.ASI_CRM_CN_Cost_Type__c == 'Variable')
                            TotalVar_Cost += last_cost_temp.ASI_CRM_CN_Estimate_Amount__c;
                    }
                }
            }
            //Query Covered Outlet of last contract
            list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
            try{
                CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                                 FROM ASI_CRM_CN_Covered_Outlet__c
                                 WHERE ASI_CRM_CN_Contract__c = :PC.ASI_CRM_CN_Last_Contract__c];
            }catch(exception e){
                system.debug('Try CoveredOutlet failed: ' + e);
            }
            set<id> CoveredOutletset = new set<id>();
            ASI_TH_CRM_Contract__c tempCC = [Select id, ASI_CRM_Volume_Option__c From ASI_TH_CRM_Contract__c WHERE id = :PC.ASI_CRM_CN_Last_Contract__c];
            if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || tempCC.ASI_CRM_Volume_Option__c == null) {
                CoveredOutletset.add(PC.ASI_CRM_CN_Outlet__c);
            }
            if (CoveredOutlet.size() > 0){
                if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || tempCC.ASI_CRM_Volume_Option__c == null) {
                    for (ASI_CRM_CN_Covered_Outlet__c CO_temp : CoveredOutlet){
                        CoveredOutletset.add(CO_temp.ASI_CRM_CN_Outlet__c);
                    }
                }
            }
            // Get monthly sales volume information of sub-brands from object “WS/Outlet Sub-brand Volume”(ASI_CRM_Subbrand_Volume) in covered outlets based on the period between the start date to the cut-off date of last contract
            // The wordings “PR_Direct”, “T1_Depletion” and “T2_Depletion” in the object are related to different wholesalers 
            list<ASI_CRM_Subbrand_Volume__c> HistoricalContract_SBList = new list<ASI_CRM_Subbrand_Volume__c>();
            system.debug('lastBRSF_set: ' + lastBRSF_set);
            CutOffDay = CutOffDate(strCutOffDay);
            system.debug('CutOffDay: ' + CutOffDay );
            try{
                //Query Historical Contract Sub Brand Volume
                HistoricalContract_SBList = [SELECT ASI_CRM_End_Date__c, ASI_CRM_PR_Direct__c, ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,
                                             ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                                             ASI_CRM_PR_Direct_Btl__c, ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_T2_Depletion_BTL__c,
                                             ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.Name
                                             FROM ASI_CRM_Subbrand_Volume__c 
                                             WHERE //ASI_CRM_Account__c = : PC.ASI_CRM_CN_Outlet__c
                                             ASI_CRM_Account__c IN :CoveredOutletset
                                             AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                                             //AND ASI_CRM_Subbrand__c IN :lastBRSF_set
                                             AND ASI_CRM_End_Date__c >= :LastPO.ASI_CRM_CN_PO_Start_Date__c
                                             //AND ASI_CRM_End_Date__c <= :LastPO.ASI_CRM_CN_PO_End_Date__c
                                             AND ASI_CRM_End_Date__c <= :CutOffDay and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false];
                //20170118 Elufa
            }catch(exception e){
                system.debug('Try HistoricalContract_SBList: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Sub Brand Volume Data for Historical Contract.'));
            }
            system.debug('HistoricalContract_SBList: ' + HistoricalContract_SBList );
            set<id> sbId_set = new set<id>();
            
            //20170126 Elufa
            sbId_set.addAll(lastBRSF_set);
            
            if (HistoricalContract_SBList.size() > 0){
                for (ASI_CRM_Subbrand_Volume__c sbttemp : HistoricalContract_SBList ){
                    sbId_set.add(sbttemp.ASI_CRM_Subbrand__c);
                    system.debug('checkIDDDDDDDDDD' + sbttemp.id + '        ' + sbttemp.ASI_CRM_Subbrand__c);
                }
            }
            //Historical ROI Period map
            //Execute function "checkFYDayPeriod" to return the breakdown of the period in last contract to a map of pairs of "Fiscal Year Last Date" (key) and "Number of month covered of last contract in the fiscal year" (value)   
            map<date, decimal> HistContractPeriod = checkFYDayPeriod(LastPO.ASI_CRM_CN_PO_Start_Date__c, LastPO.ASI_CRM_CN_PO_End_Date__c);
            if (HistContractPeriod != null && HistContractPeriod.size() > 0){
            // Create the map “HCROL_map” for each subbrand item in historical contract in each Fiscal Year, with key and value:
            // Key: String value of date value “Last Date of each Fiscal Year” + String value of “Subbrand id”
            // Value: from the class “SubBrandProrate”:
            //    strPeriod: value from the map “HistContractPeriod” obtained by the key
            //    sbid: Subbrand id
                string strkey;
                for (date hctemp : HistContractPeriod.keyset() ){
                    if (sbId_set.size() > 0){
                        for (id brsfidtemp : sbId_set){
                            strkey = string.valueof(hctemp) + brsfidtemp;
                            if (!HCROI_map.containskey(strkey)){
                                SubBrandProrate newsb = new SubBrandProrate();
                                newsb.strPeriod = HistContractPeriod.get(hctemp);
                                newsb.sbid = brsfidtemp;
                                HCROI_map.put(strkey, newsb);
                            }
                        }
                    }
                }
            }
            system.debug('HCROI_map: ' + HCROI_map);

            // Select the monthly Gross Sales and Cost Margin (i.e. profit margin) of each sub-brand within the last contract’s contract period from the object “Actual CM GS”(ASI_CRM_CM_GS) to the list “sb_actualcm_list”
            try{
            //Query Historical Contract Actual YTD CM
            date strStart = LastPO.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            //date strEnd = LastPO.ASI_CRM_CN_PO_End_Date__c.addMonths(+1);
            system.debug('Outlet_acc (ActualCM): ' + Outlet_acc );

                sb_actualcm_list = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_CR12_Factor__c, 
                                    ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__c , ASI_CRM_TYPE__c, ASI_CRM_CN_Standard_Bottle_Factor__c 
                                    FROM ASI_CRM_CM_GS__c
                                    WHERE ASI_CRM_PRODUCTCODE__c IN :sbId_set AND
                                    (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
                                    AND ASI_CRM_Region__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                    //AND ASI_CRM_CN_Month_End_Date__c >= :LastPO.ASI_CRM_CN_PO_Start_Date__c
                                    //AND ASI_CRM_CN_Month_End_Date__c <= :LastPO.ASI_CRM_CN_PO_End_Date__c
                                    AND ASI_CRM_CN_Month_End_Date__c >= :strStart
                                    //AND ASI_CRM_CN_Month_End_Date__c <= :strEnd
                                    AND ASI_CRM_CN_Month_End_Date__c <= :CutOffDay
                                    ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ];
            }catch(exception e){
                system.debug('Try sb_actualcm_list: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Actual YTD CM Data for Historical Contract.'));
                sb_actualcm_list = new list<ASI_CRM_CM_GS__c>();
            }
            
            // Added By Alan Wong (Elufa) 20160609
            try{
                
                String currentFY2 = '' + (CurrentFiscalYear - 1);//20170109 Elufa
                String currentFY3 = '' + (CurrentFiscalYear - 2);//20170109 Elufa
                
                sb_HCProFormaCM_list = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c 
                                        FROM ASI_CRM_CM_GS__c
                                        WHERE ASI_CRM_PRODUCTCODE__c IN :sbId_set 
                                        AND (ASI_CRM_TYPE__c = 'Budget CM')
                                        AND ASI_CRM_Region__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                        AND (ASI_CRM_YEAR__c = :string.valueOf(CurrentFiscalYear) 
                                             OR ASI_CRM_YEAR__c = :currentFY2//20170109 Elufa
                                             OR ASI_CRM_YEAR__c = :currentFY3)//20170109 Elufa
                                        AND ASI_CRM_CN_Month__c = 6
                                        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC];
            }catch(exception e){
                system.debug('Try sb_HCProFormaCM_list: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Actual YTD CM Data for Historical Contract.'));
                sb_HCProFormaCM_list = new list<ASI_CRM_CM_GS__c>();
            }
            for (ASI_CRM_CM_GS__c HCLatestBudget: sb_HCProFormaCM_list)
            {
                if(HCLatestBudget.ASI_CRM_CM_GS_per_9L__c == null){
                    HCLatestBudget.ASI_CRM_CM_GS_per_9L__c = 0;
                }
                if(!HCLatestBudget_Map.containsKey(HCLatestBudget.ASI_CRM_PRODUCTCODE__c) && HCLatestBudget.ASI_CRM_CM_GS_per_9L__c != Null && HCLatestBudget.ASI_CRM_CM_GS_per_9L__c != 0){//20161114 Elufa
                    HCLatestBudget_Map.put(HCLatestBudget.ASI_CRM_PRODUCTCODE__c, HCLatestBudget.ASI_CRM_CM_GS_per_9L__c);
                }
            }
            // -- End -- //
            //Actual CM/GS for Historical Contract
            map<id, decimal> latest_cm = new map<id, decimal>();
            map<id, decimal> latest_gs = new map<id, decimal>();
            if (sb_actualcm_list.size() > 0){
                string subbrand_id;
                string strkey;
                date strDatecheckFY;
                decimal totalactualcm = 0;
                decimal totalactualgs = 0;
                for (ASI_CRM_CM_GS__c actualcmTemp : sb_actualcm_list){
                    subbrand_id = actualcmTemp.ASI_CRM_PRODUCTCODE__c;
                    strDatecheckFY = checkFYDate(actualcmTemp.ASI_CRM_CN_Month_End_Date__c);
                    strkey = string.valueof(strDatecheckFY) + subbrand_id;
                    //YTD CM (9L)
                    // 1. Assign “Actual CM per 9L” information (in the field “strCM” of the class “SubBrandProrate” of the value) from the list “sb_actualcm_list” to the map “HCROL_map”
                    // 2. Create a map "latest_cm" to store the latest “Actual CM per 9L” information for each sub-brand in the last contract’s contract period
                    if (actualcmTemp.ASI_CRM_TYPE__c == 'YTD CM'){
                        if (actualcmTemp.ASI_CRM_CM_GS_per_9L__c != null) {
                            totalactualcm = actualcmTemp.ASI_CRM_CM_GS_per_9L__c; // / actualcmTemp.ASI_CRM_CN_Standard_Bottle_Factor__c; 
                        }else{
                            totalactualcm = 0;
                        }
                        // Latest version of CM (ASI_CRM_VERSION__c DESC) would be stored in the map “HCROI_map” only. Thus, if the value of CM is null, CM valued would be filled into the map. Otherwise, it means the current CM value obtained is not the latest version and it is not required to fill in.
                        if (HCROI_map.containskey(strkey)){

                            if (HCROI_map.get(strkey).strCM == null && totalactualcm != Null && totalactualcm != 0){//20161114 Elufa
                                HCROI_map.get(strkey).strCM = totalactualcm ;
                                system.debug('totalactualcm11111: ' + totalactualcm + '    ' + actualcmTemp.ASI_CRM_PRODUCTCODE__c);
                            }
                            // Added By Alan Wong (Elufa) 20160609
                            if (HCROI_map.get(strkey).LatestCM == null || HCROI_map.get(strkey).LatestCM == 0){//20170125 Elufa added  || HCROI_map.get(strkey).LatestCM == 0
                                if (HCLatestBudget_Map.containsKey(subbrand_id)){
                                    HCROI_map.get(strkey).LatestCM = HCLatestBudget_Map.get(subbrand_id) ;
                                }
                            }
                            // -- End -- //
                            
                        }
                        if (!latest_cm.containskey(subbrand_id) && totalactualcm != Null && totalactualcm != 0){//20161214 Elufa
                            system.debug('check1111' + actualcmTemp.ASI_CRM_PRODUCTCODE__c + '  ' + actualcmTemp.id);
                            latest_cm.put(subbrand_id, totalactualcm);
                        }
                        
                    }
                    //YTD GS (9L)
                    // 1. Assign Actual GS per 9L information (in the field “strGS” of the class “SubBrandProrate” of the value) from the list “sb_actualcm_list” to the map “HCROL_map”
                    // 2. Create a map "latest_ gs " to store the latest “Actual GS per 9L” information for each sub-brand in the last contract’s contract period
                    if (actualcmTemp.ASI_CRM_TYPE__c == 'YTD GS'){
                        if (actualcmTemp.ASI_CRM_CM_GS_per_9L__c != null ){
                            totalactualgs = actualcmTemp.ASI_CRM_CM_GS_per_9L__c; // / actualcmTemp.ASI_CRM_CN_Standard_Bottle_Factor__c; 
                        }else{
                            totalactualgs = 0;
                        }
                        if (HCROI_map.containskey(strkey)&& totalactualgs != null && totalactualgs != 0){//20161214 Elufa
                            if (HCROI_map.get(strkey).strGS == null){
                                HCROI_map.get(strkey).strGS = totalactualgs ;
                                system.debug('totalactualgs11111: ' + totalactualgs + '    ' + actualcmTemp.ASI_CRM_PRODUCTCODE__c);
                            }
                        }
                        if (!latest_gs.containskey(subbrand_id) && totalactualgs != null && totalactualgs != 0)//20161214 Elufa
                            latest_gs.put(subbrand_id, totalactualgs);
                    }
                }
            }
            system.debug('HCROI_map: ' + HCROI_map);
            system.debug('latest_cm: ' + latest_cm);
            
            //Loop Historical SB List            
            decimal LastPO_Vol = 0;
            decimal LastPO_Vol_temp = 0;
            decimal LastPO_Vol_CR12 = 0;
            decimal LastPO_Vol_CR12_temp = 0;
            decimal LastPO_Vol_9L_CM = 0;
            decimal LastPO_Vol_9L_GS = 0;
            decimal LastPO_Vol_ROI = 0;
            decimal LastPO_Vol_GS = 0;
            
            decimal strLastPOtotalVol = 0;
            decimal strTotalSBGS = 0;
            decimal LastProFormatotalVol = 0; // Added by Alan Wong (Elufa) 20160609
            decimal LatestPO_Vol_9L_CM = 0; // Added by Alan Wong (Elufa) 20160609
            
            date strEndDate;
            
            map <id, decimal> LastPO_VolBtl_map = new map <id, decimal>();
            system.debug('HistoricalContract_SBList: ' + HistoricalContract_SBList );
            if (HistoricalContract_SBList.size() > 0){
                date DataLastDate;
                string subbrand_id;
                string strkey;
                decimal actualcm;
                decimal actualgs;
                decimal lastcm;
                map<id, SubBrandProrate> sb_datadate_map = new map<id, SubBrandProrate>();
                map<id, SubBrandProrate> sb_datadate_CR12_map = new map<id, SubBrandProrate>();
                map<date, map<id, SubBrandProrate>> sb_datadate_ROI_map = new map<date, map<id, SubBrandProrate>>();
                // Add up the “Volume 9L” of each sub-brand from different wholesalers (PR_Direct, T1 Depletion, T2 Depletion) within the time period and covered outlets of last contract for each fiscal year accordingly. 
                for (ASI_CRM_Subbrand_Volume__c hc_sbtemp : HistoricalContract_SBList){
                    actualcm = 0;
                    actualgs = 0;
                    lastcm = 0; // Added by Alan Wong (Elufa) 20160609
                    LastPO_Vol_temp = 0;
                    subbrand_id  =  hc_sbtemp.ASI_CRM_Subbrand__c;
                    DataLastDate = checkFYDate(hc_sbtemp.ASI_CRM_End_Date__c);
                    strkey = string.valueof(DataLastDate) + subbrand_id;
                    //Total Volume 9L cs for Historical Contract (prepare for proration)
                    if (hc_sbtemp.ASI_CRM_PR_Direct__c != null)
                        LastPO_Vol_temp = hc_sbtemp.ASI_CRM_PR_Direct__c;
                    if (hc_sbtemp.ASI_CRM_T1_Depletion__c!= null)
                        LastPO_Vol_temp += hc_sbtemp.ASI_CRM_T1_Depletion__c;
                    if (hc_sbtemp.ASI_CRM_T2_Depletion__c!= null)
                        LastPO_Vol_temp += hc_sbtemp.ASI_CRM_T2_Depletion__c;

                    if (HCROI_map.containskey(strkey) && HCROI_map.get(strkey).strCM != Null && HCROI_map.get(strkey).strCM != 0){//20170126 Elufa added  && actualcm = HCROI_map.get(strkey).strCM != Null && actualcm = HCROI_map.get(strkey).strCM != 0
                        actualcm = HCROI_map.get(strkey).strCM;
                        //lastcm = HCROI_map.get(strkey).LatestCM;
                    }else if (latest_cm.containskey(subbrand_id)){
                        actualcm = latest_cm.get(subbrand_id);
                        /*if (HCLatestBudget_Map.containsKey(subbrand_id)){
                            lastcm = HCLatestBudget_Map.get(subbrand_id);
                        }*/
                    }else{
                        actualcm = 0;
                        //lastcm = 0;
                    }
                    //20170126 Elufa
                    if (HCROI_map.containskey(strkey) && HCROI_map.get(strkey).LatestCM != Null && HCROI_map.get(strkey).LatestCM != 0){//20170126 Elufa added  && actualcm = HCROI_map.get(strkey).strCM != Null && actualcm = HCROI_map.get(strkey).strCM != 0
                        //actualcm = HCROI_map.get(strkey).strCM;
                        lastcm = HCROI_map.get(strkey).LatestCM;
                    }else if(HCLatestBudget_Map.containsKey(subbrand_id)){
                            lastcm = HCLatestBudget_Map.get(subbrand_id);
                    }else{
                        //actualcm = 0;
                        lastcm = 0;
                    }
                    //20170126 End

                    if (HCROI_map.containskey(strkey) && HCROI_map.get(strkey).strGS != null && HCROI_map.get(strkey).strGS != 0){//20170207 Elufa added  && HCROI_map.get(strkey).strGS != 0
                            actualgs = HCROI_map.get(strkey).strGS;
                    }else if (latest_gs.containskey(subbrand_id) && latest_gs.get(subbrand_id) != null && latest_gs.get(subbrand_id) != 0){//20170207 Elufa added latest_gs.get(subbrand_id) != 0
                            actualgs = latest_gs.get(subbrand_id);
                    }
                    system.debug('latest_cm: ' + latest_cm);
                    system.debug('actualcm: ' + actualcm  + ' actualgs: ' + actualgs);
                    system.debug('LastPO_Vol_temp: ' + LastPO_Vol_temp + ' * ' + actualcm);
                    //for Historical Contract ROI
                    LastPO_Vol_9L_CM  = 0;
                    LatestPO_Vol_9L_CM = 0;
                    if (actualcm != null){
                        LastPO_Vol_9L_CM = LastPO_Vol_temp * actualcm;
                    }
                    if (lastcm != null){
                        LatestPO_Vol_9L_CM = LastPO_Vol_temp * lastcm;
                    }
                    LastPO_Vol_9L_GS =0;
                    if (actualgs != null)
                        LastPO_Vol_9L_GS = LastPO_Vol_temp * actualgs;
                    //system.debug('LastPO_Vol_9L_CM: ' + LastPO_Vol_9L_CM );
                    //system.debug('LastPO_Vol_9L_GS: ' + LastPO_Vol_9L_GS );
                    
                    //Volume 9L Map 
                    // Sum up the “9L Volume”, CM and GS for each sub-brand and store in the map instance “sb_datadate_map”
                    if (sb_datadate_map.containskey(subbrand_id)){
                        SubBrandProrate newitem = sb_datadate_map.get(subbrand_id);
                        newitem.strVolume += LastPO_Vol_temp;
                        newitem.strCM += LastPO_Vol_9L_CM;
                        newitem.LatestCM += LatestPO_Vol_9L_CM;
                        newitem.strGS += LastPO_Vol_9L_GS;
                        sb_datadate_map.put(subbrand_id , newitem);
                    }else{
                        SubBrandProrate newsb = new SubBrandProrate();
                        newsb.strVolume = LastPO_Vol_temp;
                        newsb.strCM = LastPO_Vol_9L_CM;
                        newsb.LatestCM = LatestPO_Vol_9L_CM;
                        newsb.strGS = LastPO_Vol_9L_GS;
                        newsb.sbname = hc_sbtemp.ASI_CRM_Subbrand__r.name;
                        sb_datadate_map.put(subbrand_id , newsb);
                    }
                    system.debug('sb_datadate_map: ' + sb_datadate_map);
                    LastPO_Vol_CR12_temp = 0;
                    //Total Volume CR12 for Historical Contract (prepare for proration)
                    if (hc_sbtemp.ASI_CRM_PR_Direct_CR12__c!= null)
                        LastPO_Vol_CR12_temp = hc_sbtemp.ASI_CRM_PR_Direct_CR12__c;
                    if (hc_sbtemp.ASI_CRM_T1_Depletion_CR12__c!= null)
                        LastPO_Vol_CR12_temp += hc_sbtemp.ASI_CRM_T1_Depletion_CR12__c;
                    if (hc_sbtemp.ASI_CRM_T2_Depletion_CR12__c != null)
                        LastPO_Vol_CR12_temp += hc_sbtemp.ASI_CRM_T2_Depletion_CR12__c;
                    //Volume CR12 Map
                    if (sb_datadate_CR12_map.containskey(subbrand_id)){
                        sb_datadate_CR12_map.get(subbrand_id).strVolume += LastPO_Vol_CR12_temp;
                    }else{
                        SubBrandProrate newsb = new SubBrandProrate();
                        newsb.strVolume = LastPO_Vol_CR12_temp;
                        sb_datadate_CR12_map.put(subbrand_id, newsb);
                    }
                    system.debug('sb_datadate_CR12_map: ' + sb_datadate_CR12_map);
                  
                }
                
                //Calculate Prorated Volume
                Integer LastPONoMonths = MonthDiff(LastPO.ASI_CRM_CN_PO_Start_Date__c, LastPO.ASI_CRM_CN_PO_End_Date__c);
                Integer CutOffPeriod = MonthDiff(LastPO.ASI_CRM_CN_PO_Start_Date__c, CutOffDay);
                integer strDiffEnd = 0;
                if (LastPONoMonths != null && CutOffPeriod != null)
                    strDiffEnd  = LastPONoMonths - CutOffPeriod;
                //Volume 9L = Total Volume
                decimal tempCM = 0;
                decimal tempGS = 0;
                decimal tempProFormaCM = 0; // Added by Alan Wong (Elufa) 20150609
                if (sb_datadate_map.size() > 0){
                    decimal tempVol = 0;
                    for (id vol_temp : sb_datadate_map.keyset()){ 
                        SubBrandProrate item = sb_datadate_map.get(vol_temp);
                        tempVol = 0 ; 
                        tempCM = 0;
                        tempGS = 0;  
                        actualgs = 0;
                        actualcm = 0;
                        tempProFormaCM = 0;
                        lastcm = 0;
                        decimal proratevol = 0;
                        // Calculate the average monthly volume of a sub-brand within the last contract’s start date and cut-off date
                        if (CutOffPeriod != 0 && CutOffPeriod != null){
                            tempVol = (item.strVolume / CutOffPeriod ); 
                        }  
                        // Sum up the total volume of a sub-brand within the last contract’s contract period, with the prorated volume after the cut-off date included
                        if (strDiffEnd != 0 && strDiffEnd != null && tempVol != 0){
                            LastPO_Vol += tempVol * strDiffEnd;
                            proratevol = tempVol * strDiffEnd;
                        } 
                        system.debug('Prorate proratevol: ' + item.sbname + ' - ' + proratevol + ' strVolume: ' + item.strVolume + ' cm: ' + item.strCM);
                        if (latest_gs.containskey(vol_temp))
                            actualgs = latest_gs.get(vol_temp);
                        if (actualgs != null)
                            tempGS = proratevol * actualgs;
                        if (latest_cm.containskey(vol_temp))
                            actualcm = latest_cm.get(vol_temp);
                        if (HCLatestBudget_Map.containskey(vol_temp))
                            lastcm = HCLatestBudget_Map.get(vol_temp);
                        if (actualcm != null)
                            tempCM = proratevol * actualcm;
                        if (lastcm != null)
                            tempProFormaCM = proratevol * lastcm;
                        system.debug('Prorate proratevol actualcm : ' + item.sbname + ' - ' + proratevol + ' * ' + actualcm + ' = ' + tempCM );
                        strLastPOtotalVol += (tempCM + item.strCM); // Calculate the Profit (CM * Volume) of each sub-brand
                        strTotalSBGS += (tempGS + item.strGS); // Calculate the Gross Sales (GS * Volume) of each sub-brand
                        LastPO_Vol += item.strVolume;
                        LastProFormatotalVol += (tempProFormaCM + item.LatestCM); // Added By Alan Wong (Elufa) 20160609
                    }
                    
                }

                system.debug('HC ROI LastProFormatotalVol : ' + LastProFormatotalVol );
                system.debug('HC ROI strLastPOtotalVol : ' + strLastPOtotalVol );
                //system.debug('HC ROI LastPO_Vol_9L_CM: ' + LastPO_Vol_9L_CM);

                //ASI_CRM_CN_Last_Contract_Volume_Total__c 
                if (LastPO_Vol != 0 && LastPO_Vol != null)
                    PC.ASI_CRM_CN_Last_Contract_Volume_Total__c = LastPO_Vol;
                else
                    PC.ASI_CRM_CN_Last_Contract_Volume_Total__c = 0;
                
                //Calculate Prorated Volume CR12 for Historical Contract Investment CR 12 eq Btl
                if (sb_datadate_CR12_map.size() > 0){
                    decimal tempVol = 0;
                    for (SubBrandProrate vol_temp : sb_datadate_CR12_map.values()){
                        tempVol =0;
                        if (CutOffPeriod != 0 && CutOffPeriod != null){
                            tempVol = (vol_temp.strVolume / CutOffPeriod ); 
                        }  
                        if (strDiffEnd != 0 && strDiffEnd != null && tempVol !=0){
                            LastPO_Vol_CR12 += tempVol * strDiffEnd;
                        }  
                        LastPO_Vol_CR12 += vol_temp.strVolume;
                    }
                    system.debug('Investment CR12 CutOffPeriod : ' + CutOffPeriod + ' strDiffEnd: ' + strDiffEnd );
                }
                
                decimal strTradeExpense;
                if (TotalFixed_Cost != null)
                    strTradeExpense = TotalFixed_Cost ;
                if (TotalVar_Cost != null)
                    strTradeExpense += TotalVar_Cost ;
                if (TotalBRSF_Est_Cost != null)
                    strTradeExpense += TotalBRSF_Est_Cost;
                
                //ASI_CRM_CN_Last_Contract_Investment_CR12__c 
                system.debug('LastPO_Vol_CR12: ' + LastPO_Vol_CR12 );
                if (LastPO_Vol_CR12 != 0 && strTradeExpense != null && strTradeExpense !=0){
                    PC.ASI_CRM_CN_Last_Contract_Investment_CR12__c = strTradeExpense/ LastPO_Vol_CR12;
                }else{
                    PC.ASI_CRM_CN_Last_Contract_Investment_CR12__c = 0;
                }
                
                
                //Total Volume By Subbrand * Actual YTD CM / Total Cost(Investment)
                system.debug('strLastPOtotalVol: ' + strLastPOtotalVol );
                if (strLastPOtotalVol != null && strLastPOtotalVol != 0&& strTradeExpense!= null && strTradeExpense!= 0) {
                    PC.ASI_CRM_CN_Last_Contract_ROI__c = strLastPOtotalVol / strTradeExpense;
                }else{
                    PC.ASI_CRM_CN_Last_Contract_ROI__c = 0;
                }
                // Added By Alan Wong (Elufa) 20160609
                // Last Contract Pro-Forma ROI
                if (LastProFormatotalVol != null && LastProFormatotalVol != 0&& strTradeExpense!= null && strTradeExpense!= 0) {
                    PC.ASI_CRM_Last_Contract_Pro_Forma_ROI__c = LastProFormatotalVol / strTradeExpense;
                }else{
                    PC.ASI_CRM_Last_Contract_Pro_Forma_ROI__c = 0;
                }
                // -- End -- //
                //% of Total Trade A&P / GS
                if (strTotalSBGS  != null && strTotalSBGS != 0 && strTradeExpense != null && strTradeExpense != 0){
                    PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c = strTradeExpense / strTotalSBGS * 100;
                }else{
                    PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c = 0;
                }
            }else{
                PC.ASI_CRM_CN_Last_Contract_ROI__c = 0;
                PC.ASI_CRM_Last_Contract_Pro_Forma_ROI__c = 0; // Added By Alan Wong (Elufa) 20160609
                PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c = 0;
                PC.ASI_CRM_CN_Last_Contract_Investment_CR12__c = 0;
                PC.ASI_CRM_CN_Last_Contract_Volume_Total__c = 0;
            }
        }else{
            PC.ASI_CRM_CN_Last_Contract_ROI__c = 0;
            PC.ASI_CRM_Last_Contract_Pro_Forma_ROI__c = 0; // Added By Alan Wong (Elufa) 20160609
            PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c = 0;
            PC.ASI_CRM_CN_Last_Contract_Investment_CR12__c = 0;
            PC.ASI_CRM_CN_Last_Contract_Volume_Total__c = 0;
        }
        
        /*************************** Current Contract Total Estimate Volume 9L && Total Esitmate Btl **********************/
        
        // Note: “BtlIncentive_Total”  is calculated in the function (Page Reference “SaveAll”). When the user press the button “Evaluate” in the Page, this function would be executed before executing the coding here (i.e. function CalculatePC).
        // Sum up total cost into “Contract_Total”
        
        decimal MonthVol_9L = 0;
        decimal MonthVol_9L_CR12 = 0;
        decimal est_btl = 0;
        //Total Contract Cost ---------------- Cannot get Formula field when PC not Saved. 2014-06-14
        decimal ContractTotal = 0;
        decimal ContractFloatTotal = 0;
        System.debug(LoggingLevel.INFO, '*** BtlIncentive_Total: ' + BtlIncentive_Total);
        System.debug(LoggingLevel.INFO, '*** NoMonths: ' + NoMonths);
        if (PC.ASI_CRM_Fixed_Expense__c != null) {
            ContractTotal += PC.ASI_CRM_Fixed_Expense__c;
            ContractFloatTotal += PC.ASI_CRM_Fixed_Expense__c;
        }

        if (BtlIncentive_Total  != null)
            ContractTotal += BtlIncentive_Total * NoMonths;
        if (PC.ASI_CRM_Promotion_Service_Fee__c != null) {
            ContractTotal += PC.ASI_CRM_Promotion_Service_Fee__c;
            ContractFloatTotal += PC.ASI_CRM_Promotion_Service_Fee__c;
        }
        decimal str9LFactor = 1;
        decimal strCR12Factor = 1;
        set<id> btl_set = new set<id>();
        for (Row r :Rows) {
            btl_set.add(r.Record.ASI_CRM_Sub_Brand__c);
        }
        System.debug(LoggingLevel.INFO, '*** btl_set11: ' + btl_set);
        list<ASI_MFM_Sub_brand__c> btl_set_sbList = new list<ASI_MFM_Sub_brand__c>();
        // Select the "Standard Bottle Size" and "CR12 Conversion Factor" of each sub-brands in the pre-contract from the object “Sub-Brand” (ASI_MFM_Sub_brand__c)
        if (btl_set.size() > 0){
            try{
                btl_set_sbList = [select id, ASI_CRM_CN_Standard_Bottle_Size__c, ASI_CRM_CN_COnvfactor_Ltocr12_C__c
                                  FROM ASI_MFM_Sub_brand__c WHERE id IN:btl_set ];
            }catch(exception e){
                system.debug('Try btl_set_sbList failed: ' + e);
            }
            date strStart = PC.ASI_CRM_Start_Date__c.addYears(-1);
            date strEnd = PC.ASI_CRM_End_Date__c.addYears(+1);
            
            date strStartBGDate2 = PC.ASI_CRM_Start_Date__c.addYears(-3);//20170125 Elufa
            date strEndBGDate2 = PC.ASI_CRM_End_Date__c.addYears(1);//20170125 Elufa
            
            try{
                sb_budgetcm_list = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_CR12_Factor__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_CN_Month__c,
                                    ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_TYPE__c 
                                    FROM ASI_CRM_CM_GS__c
                                    WHERE ASI_CRM_PRODUCTCODE__c IN :btl_set
                                    //AND ASI_CRM_Sub_Channel__c = :Outlet_acc.ASI_CRM_CN_Sub_Channel__c
                                    AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                                    AND ASI_CRM_Region__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                    AND ((ASI_CRM_CN_Month_End_Date__c >= :strStart
                                          AND ASI_CRM_CN_Month_End_Date__c <= :strEnd)
                                         OR (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 //20170125 Elufa
                                             AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2//20170125 Elufa
                                             AND ASI_CRM_CN_Month__c = 6 ))//20170125 Elufa
                                    ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
            }catch(exception e){
                system.debug('Try sb_budgetcm_list: ' + e);
                System.debug(LoggingLevel.INFO, '*** e.getStackTraceString(): ' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Budget CM Data for this Contract.'));
                sb_budgetcm_list = new list<ASI_CRM_CM_GS__c>();
            }
            // Added by Alan Wong (Elufa) 20160608
            try{
                
                String currentFY2 = '' + (CurrentFiscalYear - 1);
                String currentFY3 = '' + (CurrentFiscalYear - 2);
                
                sb_ProFormaCM_list = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_CN_Month__c
                                      FROM ASI_CRM_CM_GS__c
                                      WHERE ASI_CRM_PRODUCTCODE__c IN :btl_set
                                      AND (ASI_CRM_TYPE__c = 'Budget CM')
                                      AND ASI_CRM_Region__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                      AND (ASI_CRM_YEAR__c = :string.valueOf(CurrentFiscalYear) 
                                           OR ASI_CRM_YEAR__c = :currentFY2//20170125 Elufa
                                           OR ASI_CRM_YEAR__c = :currentFY3)//20170125 Elufa
                                      AND ASI_CRM_CN_Month__c = 6
                                      ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC];
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Latest Budget CM Data for this Contract.'));
                sb_ProFormaCM_list = new list<ASI_CRM_CM_GS__c>();
            }
            for (ASI_CRM_CM_GS__c LatestBudget: sb_ProFormaCM_list)
            {
                if(LatestBudget.ASI_CRM_CM_GS_per_9L__c == null)
                    LatestBudget.ASI_CRM_CM_GS_per_9L__c = 0;
                if(!LatestBudget_Map.containsKey(LatestBudget.ASI_CRM_PRODUCTCODE__c) && LatestBudget.ASI_CRM_CM_GS_per_9L__c != Null && LatestBudget.ASI_CRM_CM_GS_per_9L__c != 0)//20161114 Elufa
                    LatestBudget_Map.put(LatestBudget.ASI_CRM_PRODUCTCODE__c, LatestBudget.ASI_CRM_CM_GS_per_9L__c);
            }
            // -- End -- //
            // Breakdown the contract period into different fiscal years (as a map “ContractPeriod”)
            map<date, decimal> ContractPeriod = checkFYDayPeriod(PC.ASI_CRM_Start_Date__c, PC.ASI_CRM_End_Date__c);
            decimal strTotalVol = 0;
            decimal strTotalVolgs = 0;

            //Prepare ROI Map for Calculation
            // Create a map ("ROI_map") for each sub-brand in each Fiscal Year to prepare the ROI calculation
            system.debug('ContractPeriod: ' + ContractPeriod);
            if (ContractPeriod.size() > 0){
                string strkey;
                for (date cmtemp : ContractPeriod.keyset()){
                    if (btl_set.size() > 0){
                        for (id subbrand_id : btl_set){
                            strkey = string.valueof(cmtemp) + subbrand_id;
                            if (!ROI_map.containskey(strkey)){
                                SubBrandProrate newsb = new SubBrandProrate();
                                newsb.strPeriod = ContractPeriod.get(cmtemp);
                                newsb.sbid = subbrand_id;
                                ROI_map.put(strkey, newsb);
                            }
                        }
                    }
                }
            }
        }
        system.debug('ROI_map 1: ' + ROI_map);
        map<id, decimal> standardsize_btl_map = new map<id, decimal>();
        map<id, decimal> CR12_btl_map = new map<id, decimal>();
        decimal MonthlyVol;
        // Create two maps ("Standard Bottle Size" and "CR12 Conversion Factor") by breaking down the information of the list “btl_set_sbList”, which contains the sub-brand information for each row (sub-brand) of the pre-contract
        if (btl_set_sbList.size() > 0){
            for (ASI_MFM_Sub_brand__c sblist_temp : btl_set_sbList){
                if (!standardsize_btl_map.containskey(sblist_temp.id)){
                    standardsize_btl_map.put(sblist_temp.id, sblist_temp.ASI_CRM_CN_Standard_Bottle_Size__c);
                }
                if (!CR12_btl_map.containskey(sblist_temp.id)){
                    CR12_btl_map.put(sblist_temp.id, sblist_temp.ASI_CRM_CN_COnvfactor_Ltocr12_C__c);
                }
            }
        }
        
        //ROI for current Contract
        system.debug('sb_budgetcm_list: ' + sb_budgetcm_list );
        if (sb_budgetcm_list!=null && sb_budgetcm_list.size() > 0){
            string subbrand_id;
            date strDatecheckFY;
            decimal totalbudgetcm = 0;
            decimal latestbudgetcm = 0;
            decimal totalbudgetgs = 0;
            decimal strCM = 0;
            decimal strGS = 0;
            string strkey;
            Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();//20170125 Elufa
            // Assign the Budget CM and Budget GS of each sub-brand in each Fiscal Year respectively to the map “ROI_map” created before  
            for (ASI_CRM_CM_GS__c budgetcmTemp : sb_budgetcm_list){
                strDatecheckFY = checkFYDate(budgetcmTemp.ASI_CRM_CN_Month_End_Date__c);
                subbrand_id = budgetcmTemp.ASI_CRM_PRODUCTCODE__c;
                strCM = 0;
                strGS = 0;
                strkey = string.valueof(strDatecheckFY) + subbrand_id;
                
                //20170125 Elufa
                if(budgetcmTemp.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(budgetcmTemp.ASI_CRM_PRODUCTCODE__c + budgetcmTemp.ASI_CRM_TYPE__c) && budgetcmTemp.ASI_CRM_CM_GS_per_9L__c != null && budgetcmTemp.ASI_CRM_CM_GS_per_9L__c != 0){
                    cmgsMap.put(budgetcmTemp.ASI_CRM_PRODUCTCODE__c + budgetcmTemp.ASI_CRM_TYPE__c, budgetcmTemp);
                }
                //20170125 End
                
                //Total Budget CM (9L) * Estimate Qty Monthly
                if (budgetcmTemp.ASI_CRM_TYPE__c == 'Budget CM'){
                    if (budgetcmTemp.ASI_CRM_CM_GS_per_9L__c != null && budgetcmTemp.ASI_CRM_CM_GS_per_9L__c != 0){
                        totalbudgetcm = budgetcmTemp.ASI_CRM_CM_GS_per_9L__c;
                    }else{
                        totalbudgetcm = 0;
                    }
                    // Added by Alan Wong (Elufa) 20160608
                    if(LatestBudget_Map.containsKey(budgetcmTemp.ASI_CRM_PRODUCTCODE__c)){
                        latestbudgetcm = LatestBudget_Map.get(budgetcmTemp.ASI_CRM_PRODUCTCODE__c);
                    }
                    else {
                        latestbudgetcm = 0;
                    }
                    // -- End --//
                    //Budget CM
                    if (ROI_map.containskey(strkey)){
                        if (ROI_map.get(strkey).strCM == null && totalbudgetcm != Null && totalbudgetcm != 0) {//20161114 Elufa
                            ROI_map.get(strkey).strCM = totalbudgetcm;
                        }
                        if(ROI_map.get(strkey).LatestCM == null && latestbudgetcm != Null && latestbudgetcm != 0){//20161114 Elufa
                            // Added by Alan Wong (Elufa) 20160608
                            ROI_map.get(strkey).LatestCM = latestbudgetcm;
                            system.debug('subbrand::: ' + budgetcmTemp.ASI_CRM_PRODUCTCODE__c + 'Strkey::: ' + strkey + ' strCM::: ' + totalbudgetcm + ' LatestCM:::' + latestbudgetcm );
                            // -- End --//
                        }
                    } 

                }
                //Total Budget GS (9L) * Estimate Qty Monthly
                if (budgetcmTemp.ASI_CRM_TYPE__c == 'Budget GS'){
                    if (budgetcmTemp.ASI_CRM_CM_GS_per_9L__c != null && budgetcmTemp.ASI_CRM_CM_GS_per_9L__c != 0){
                        totalbudgetgs = budgetcmTemp.ASI_CRM_CM_GS_per_9L__c;
                    }else{
                        totalbudgetgs = 0;
                    }
                    
                    //Budget GS
                    if (ROI_map.containskey(strkey) && totalbudgetgs != null && totalbudgetgs != 0){//20161214 Elufa
                        if (ROI_map.get(strkey).strGS == null)
                            ROI_map.get(strkey).strGS = totalbudgetgs;
                    }
                }

            }
            
            //20170125 Elufa to replace null value with latest CMGS data
            for(String key : ROI_map.keySet()){
                if(ROI_map.get(key).strCM == Null || ROI_map.get(key).strCM == 0 || ROI_map.get(key).strGS == Null || ROI_map.get(key).strGS == 0 || ROI_map.get(key).LatestCM == Null || ROI_map.get(key).LatestCM == 0){
                    if((ROI_map.get(key).strCM == Null || ROI_map.get(key).strCM == 0) && cmgsMap.containsKey(ROI_map.get(key).sbid + 'Budget CM')){
                        ASI_CRM_CM_GS__c cmgs = cmgsMap.get(ROI_map.get(key).sbid + 'Budget CM');
                        
                        ROI_map.get(key).strCM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                    }
                    
                    if((ROI_map.get(key).strGS == Null || ROI_map.get(key).strGS == 0) && cmgsMap.containsKey(ROI_map.get(key).sbid + 'Budget GS')){
                        ASI_CRM_CM_GS__c cmgs = cmgsMap.get(ROI_map.get(key).sbid + 'Budget GS');
                        
                        ROI_map.get(key).strGS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                    }
                    
                    if(ROI_map.get(key).LatestCM == Null || ROI_map.get(key).LatestCM == 0){
                        if(LatestBudget_Map.containsKey(ROI_map.get(key).sbid))
                            ROI_map.get(key).LatestCM = LatestBudget_Map.get(ROI_map.get(key).sbid);
                    }
                }
            }
            //20170125
            if (Rows.size() > 0){
                for (Row row :Rows){
                    ASI_CRM_Pre_Contract_Sub_Brand__c r = row.Record;
                    //get Volume 9L Factor
                    // Get the proportion factor of each bottle in 9L size (i.e. 1 / number of bottles per 9L size)
                    if (standardsize_btl_map.containskey(r.ASI_CRM_Sub_Brand__c)){
                        if (standardsize_btl_map.get(r.ASI_CRM_Sub_Brand__c) != null)
                            str9LFactor = 1/(9000/standardsize_btl_map.get(r.ASI_CRM_Sub_Brand__c));
                    }
                    //get CR12 Factor
                    if (CR12_btl_map.containskey(r.ASI_CRM_Sub_Brand__c)){
                        if (CR12_btl_map.get(r.ASI_CRM_Sub_Brand__c) != null)
                            strCR12Factor = CR12_btl_map.get(r.ASI_CRM_Sub_Brand__c);
                    }
                    if (r.ASI_CRM_Estimated_Btl_Month__c!= null){
                        MonthVol_9L += r.ASI_CRM_Estimated_Btl_Month__c * str9LFactor;
                        MonthVol_9L_CR12 += r.ASI_CRM_Estimated_Btl_Month__c * strCR12Factor * NoMonths;
                        MonthlyVol = r.ASI_CRM_Estimated_Btl_Month__c * str9LFactor; // Convert the estimated bottle per month into the unit of 9L
                    }
                    system.debug('MonthVol_9L_CR12: ' + r.ASI_CRM_Estimated_Btl_Month__c +' * '+ strCR12Factor + ' * ' + NoMonths);
                    //Used to calculate ROI
                    est_btl = MonthlyVol;
                    system.debug('est_btl 1: ' + est_btl );
                    if (sb_estimatebtl.containskey(r.ASI_CRM_Sub_Brand__c)){
                        est_btl += sb_estimatebtl.get(r.ASI_CRM_Sub_Brand__c);
                        sb_estimatebtl.put(r.ASI_CRM_Sub_Brand__c , est_btl );
                    }else{
                        sb_estimatebtl.put(r.ASI_CRM_Sub_Brand__c , est_btl );
                    }
                    system.debug('est_btl 2: ' + est_btl );
                    system.debug('sb_estimatebtl: ' + sb_estimatebtl);
                }
                // 计算新合同的Contract index ，vs . Regional Average Index ，Trade Expenses Per Bottle信息, add by zhonghui, 2020-07-22
                for (Row row :Rows){
                    ASI_CRM_Pre_Contract_Sub_Brand__c r = row.Record;
                    ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd teb2 = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd();
                    teb2.subBrandId = r.ASI_CRM_Sub_Brand__c;
                    teb2.subBrandName = r.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
                    teb2.subBrandCode = r.ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c;
                    teb2.gradeId = r.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                    teb2.gradeName = r.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    teb2.categoryId = r.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
                    teb2.categoryName = r.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    teb2.cr12Factor = ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(r.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,1);
                    //teb2.factor9L = denullify(r.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,1);
                    teb2.factor9L = ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(r.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,1000)/1000;
                    // teb2.nonContract = true;
                    // 单瓶销售费用(单瓶销售费用 + 浮动金额*（转12销售量/累计汇总的转12销售量）)
                    teb2.BRSFPerTradeExpense = r.ASI_CRM_Bottle_Incentive__c + ContractFloatTotal  * teb2.cr12Factor/MonthVol_9L_CR12;
                    teb2.volumeSTD = r.ASI_CRM_Estimated_Btl_Month__c * NoMonths;
                    // 子品牌总金额
                    teb2.BRSFAmount = teb2.BRSFPerTradeExpense * r.ASI_CRM_Estimated_Btl_Month__c * NoMonths;
                    preContract2nd.TradeExpenseBySubBrand.add(teb2);
                }

                // Display this information to “Volume (9L cs)” of Pre-contract 
                PC.ASI_CRM_Monthly_Contract_Total_Vol_9LC__c = MonthVol_9L;
                
                // Note: “ContractTotal” is the total expenses including Fixed expenses, incentive of bottles and promotional service fee.                
                if (MonthVol_9L_CR12 != 0 && ContractTotal != 0 && ContractTotal != null){
                    PC.ASI_CRM_Investment_per_Equiv_Chivas_12Y__c = ContractTotal/MonthVol_9L_CR12 ;
                }else{
                    PC.ASI_CRM_Investment_per_Equiv_Chivas_12Y__c = 0;
                }
            }
            //Query BudgetCM for current contract
            system.debug('Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: ' + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c);
            system.debug('Outlet_acc.ASI_CRM_CN_Sub_Channel__c: ' + Outlet_acc.ASI_CRM_CN_Sub_Channel__c);
            
            decimal strTotalVol = 0;
            decimal strTotalVolgs =0;
            decimal strProFormaTotalVol = 0; // Added by Alan Wong (Elufa) 20150608
            if (ROI_map.size() >0){
                decimal strVol = 0;
                decimal strPeriodVol = 0;
                for (string ROI : ROI_map.keyset()){
                    if (sb_estimatebtl.containskey(ROI_map.get(ROI).sbid)){
                        strVol = sb_estimatebtl.get(ROI_map.get(ROI).sbid);
                    }
                    if (strVol != null && ROI_map.get(ROI).strPeriod != null)
                        strPeriodVol = strVol * ROI_map.get(ROI).strPeriod;
                    if (ROI_map.get(ROI).strCM != null)
                        strTotalVol += ROI_map.get(ROI).strCM * strPeriodVol;
                    // Added by Alan Wong (Elufa) 20150608
                    if (ROI_map.get(ROI).LatestCM != null)
                        strProFormaTotalVol += ROI_map.get(ROI).LatestCM * strPeriodVol;
                    // -- End --  //
                    if (ROI_map.get(ROI).strGS != null)
                        strTotalVolgs += ROI_map.get(ROI).strGS * strPeriodVol;
                    system.debug('ROI: ' + ROI + 'New Contract ROI: '+ strTotalVol + ' = ' + ROI_map.get(ROI).strCM +' * ' + ROI_map.get(ROI).strPeriod + ' * ' + strVol);
                }
            }
            system.debug('strTotalVol: ' + strTotalVol + ' ContractTotal: ' + ContractTotal );
            //ROI
            // Note: “strTotalVol” is total Cost Margin (i.e. profit margin) and “ContractTotal” is the total expense of the pre-contract
            if (ContractTotal != null && ContractTotal != 0 && strTotalVol != null && strTotalVol != 0){
                PC.ASI_CRM_CN_ROI__c = strTotalVol / ContractTotal ;
            }else{
                PC.ASI_CRM_CN_ROI__c = 0;
            }
            
            // Added by Alan Wong (Elufa) 20150608
            if (ContractTotal != null && ContractTotal != 0 && strProFormaTotalVol != null && strProFormaTotalVol != 0){
                PC.ASI_CRM_Pro_Forma_ROI__c = strProFormaTotalVol / ContractTotal ;
            }else{
                PC.ASI_CRM_Pro_Forma_ROI__c = 0;
            } 
            // -- End --//
            
            System.debug(LoggingLevel.INFO, '*** strTotalVolgs: ' + strTotalVolgs);
            //% of Trade A&P / GS
            // Note: “strTotalVolgs” is total Gross Sales (GS) and “ContractTotal” is the total expense of the pre-contract
            if (ContractTotal != null && ContractTotal != 0 && strTotalVolgs != null && strTotalVolgs != 0){
                PC.ASI_CRM_CN_Total_APGS__c = ContractTotal /strTotalVolgs * 100;
            }else{
                PC.ASI_CRM_CN_Total_APGS__c = 0;
            }

            //Modified by Michael Yip (Introv) 17Oct2014
            //Query Align Setting 
            system.debug('Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c: ' + Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c);
            system.debug('Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c: ' + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c);
            try{
                if(Outlet_acc.ASI_CRM_CN_Is_IHBR_Outlet__c)
                    Align_setting  = new List<ASI_CRM_CN_PreContract_AlignSetting__c>();
                else 
                    Align_setting  = [SELECT ASI_CRM_CN_Align__c, ASI_CRM_CN_Align_Percent__c, ASI_CRM_CN_Type__c,
                                  ASI_CRM_CN_Alignment_Value__c, ASI_CRM_CN_Operation__c, ASI_CRM_CN_By_Percentage_Value__c, ASI_CRM_CN_On_Off__c, ASI_CRM_CN_Division__c 
                                  FROM ASI_CRM_CN_PreContract_AlignSetting__c
                                  WHERE ASI_CRM_CN_On_Off__c = :Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase()
                                  AND ASI_CRM_CN_Division__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c
                                  AND RecordType.DeveloperName = 'ASI_CRM_CN_Alignment'
                                  ORDER BY CreatedDate DESC];
            }catch(exception e){
                system.debug('Try Align_setting: ' + e);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'无与目标相符指标.'));
                Align_setting = new list<ASI_CRM_CN_PreContract_AlignSetting__c>();
            }
            system.debug('Align_setting: ' + Align_setting);
            if (Align_setting != null && Align_setting.size() > 0){
                String key;
                for (ASI_CRM_CN_PreContract_AlignSetting__c aligntemp : Align_setting){
                    key = aligntemp.ASI_CRM_CN_On_Off__c + aligntemp.ASI_CRM_CN_Division__c + aligntemp.ASI_CRM_CN_Type__c;                    
                    if (!Align_map.containskey(key)){
                        Align_map.put(key, aligntemp);
                        system.debug('MapKey = ' + key);
                    }
                }
            }
            
        //Revised by William Yang (Introv) 20141118 for UAT II #4
            String key;
            //Investment per CR12 eq btl
            if(Outlet_acc.ASI_CRM_CN_Sub_Channel__r == null)
            {
                key = Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'Investment per CR12 eq btl';
            } else {
                key = Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase() + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'Investment per CR12 eq btl';
            }
             PC.ASI_CRM_CN_Investment_CR12_Aligned__c = CalculateAlign(key, PC.ASI_CRM_Investment_per_Equiv_Chivas_12Y__c);
            system.debug('LookupKey = ' + key);
            
            //ROI for AD Above
            if(Outlet_acc.ASI_CRM_CN_Sub_Channel__r == null)
            {
                key = Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'ROI';
            } else {
                key = Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase() + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'ROI';
            }
           // key = Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase() + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'ROI';
            PC.ASI_CRM_CN_ROI_Aligned__c = CalculateAlign(key, PC.ASI_CRM_CN_ROI__c);
            system.debug('LookupKey = ' + key);
            
            //Pro-Forma ROI for AD Above
            if(Outlet_acc.ASI_CRM_CN_Sub_Channel__r == null)
            {
                key = Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'Pro-Forma ROI';
            } else {
                key = Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase() + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'Pro-Forma ROI';
            }
            //key = Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase() + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + 'Pro-Forma ROI';
            PC.ASI_MFM_Pro_Forma_ROI_Aligned__c = CalculateAlign(key, PC.ASI_CRM_Pro_Forma_ROI__c );
            system.debug('LookupKey = ' + key);
            
            //% of Total Trade A&P/GS
            if(Outlet_acc.ASI_CRM_CN_Sub_Channel__r == null)
            {
                key = Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + '% of Total Trade A&P/GS';
            } else {
                key = Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase() + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + '% of Total Trade A&P/GS';
            }
            //key = Outlet_acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c.toUpperCase() + Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + '% of Total Trade A&P/GS';
            PC.ASI_CRM_CN_Total_APGS_Aligned__c = CalculateAlign(key, PC.ASI_CRM_CN_Total_APGS__c);
            system.debug('LookupKey = ' + key);
            //End of revision by William Yang (Introv) 20141118

            Date setDate = FYConversion(Date.today());

            //Domestic Target
            Map<String, ASI_CRM_CM_GS__c>  DomesticTargetMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(setDate,btl_set);
            //Regional Target
            String channel='',region='',cityInvestementGrade='',newImage='';
            channel = PC.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_NewChannel__c;
            region = PC.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            cityInvestementGrade = PC.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
            newImage = PC.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_New_Image__c;

            Map<String, ASI_CRM_CM_GS__c> RegionalAverageMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,btl_set);
            Map<String, Decimal> LatestBudgetString_Map = new Map<String, Decimal>();
            for (String subId : LatestBudget_Map.keySet()) {
                LatestBudgetString_Map.put(subId+'Budget CM', LatestBudget_Map.get(subId));
            }
            preContract2nd.IntakeSTD = PC.ASI_CRM_CN_Monthly_Volume__c * NoMonths;
            preContract2nd.MarginAfterAnP = strTotalVol - PC.ASI_CRM_Contract_Total__c;
            preContract2nd.MarginPerBottle = preContract2nd.MarginAfterAnP / preContract2nd.IntakeSTD;
            preContract2nd = ASI_CRM_CN_HeavyContractUtilitiesClass.calculatedTradeExpense(preContract2nd,DomesticTargetMap,RegionalAverageMap,LatestBudgetString_Map);
            System.debug(LoggingLevel.INFO, '*** preContract2nd22: ' + preContract2nd);
            PC.ASI_CRM_CN_New_Contract_Index__c = preContract2nd.DomesticContractIndex;
            PC.ASI_CRM_CN_New_Regional_Index__c = preContract2nd.VsRegionalAverageIndex;


        }
    }
    
    //20160930,addedby Leo
    public void CalculateV0PC(){
        v0NoMonths = MonthDiff(PC.ASI_CRM_Start_Date__c, PC.ASI_CRM_End_Date__c);
        //Last PO Total Volume 9L
        decimal TotalBRSF_Est_Cost = 0;
        decimal TotalFixed_Cost = 0;
        decimal TotalVar_Cost = 0;
        set<id> lastBRSF_set = new set<id>();
        // Added by Alan Wong (Elufa) 20160608
        Map<id, decimal> LatestBudget_Map = new Map<id, decimal>();
        Map<id, decimal> HCLatestBudget_Map = new Map<id, decimal>();  
        date FYLatestDate = checkFYDate(Date.today());
        integer CurrentFiscalYear = FYLatestDate.year();
        // -- End -- //
        //system.debug('PC.ASI_CRM_CN_Last_Contract__c : ' + PC.ASI_CRM_CN_Last_Contract__c );
        //if (PC.ASI_CRM_CN_Last_Contract__c != null){
        if (hasV0){
            list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> Last_BRSF_List = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            try{
                //Last_BRSF_List = [SELECT ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Est_Total__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                //                  WHERE ASI_CRM_CN_Contract__c = :PC.ASI_CRM_CN_Last_Contract__c ];
                Last_BRSF_List = [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,
                                  ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, 
                                  ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                                  ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                  ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                                  ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :v0Contract];
                
            }catch(exception e){
                system.debug('Try Last Contract BRSF: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Last contract does not exist BRSF list.'));
            }
            system.debug('Last_BRSF_List: ' + Last_BRSF_List);
            if (Last_BRSF_List.size() > 0){
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lastbrsf_temp : Last_BRSF_List ){
                    lastBRSF_set.add(lastbrsf_temp.ASI_CRM_CN_Sub_Brand__c);
                    TotalBRSF_Est_Cost += lastbrsf_temp.ASI_CRM_CN_Est_Total__c;
                }
            }
            list<ASI_CRM_Contract_Cost__c> Last_CostList = new list<ASI_CRM_Contract_Cost__c>();
            try{
                //Last_CostList = [SELECT ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Estimate_Amount__c
                //                 FROM ASI_CRM_Contract_Cost__c
                //                 WHERE ASI_CRM_CN_Contract__c = :PC.ASI_CRM_CN_Last_Contract__c ];
                Last_CostList = [SELECT ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Estimate_Amount__c
                                 FROM ASI_CRM_Contract_Cost__c
                                 WHERE ASI_CRM_CN_Contract__c = :v0Contract ];
            }catch(exception e){
                system.debug('Try Last_CostList Failed: ' + e);
            }
            if (Last_CostList.size() > 0){
                for (ASI_CRM_Contract_Cost__c last_cost_temp : Last_CostList ){
                    if (last_cost_temp.ASI_CRM_CN_Estimate_Amount__c != null){
                        if (last_cost_temp.ASI_CRM_CN_Cost_Type__c == 'Fixed')
                            TotalFixed_Cost += last_cost_temp.ASI_CRM_CN_Estimate_Amount__c;
                        if (last_cost_temp.ASI_CRM_CN_Cost_Type__c == 'Variable')
                            TotalVar_Cost += last_cost_temp.ASI_CRM_CN_Estimate_Amount__c;
                    }
                }
            }
            
            // Get monthly sales volume information of sub-brands from object “WS/Outlet Sub-brand Volume”(ASI_CRM_Subbrand_Volume) in covered outlets based on the period between the start date to the cut-off date of last contract
            // The wordings “PR_Direct”, “T1_Depletion” and “T2_Depletion” in the object are related to different wholesalers 
            list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> HistoricalContract_SBList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            Map<Id, ASI_CRM_CN_Contract_BRSF_Line_Item__c> mapBRSFLine = new Map<Id, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();//20161214 Elufa
            system.debug('lastBRSF_set: ' + lastBRSF_set);
            CutOffDay = v0CutOffDate(strCutOffDay);
            system.debug('CutOffDay: ' + CutOffDay );
            try{
                //Query Historical Contract Sub Brand Volume
                HistoricalContract_SBList = Last_BRSF_List;
            }catch(exception e){
                system.debug('Try HistoricalContract_SBList: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Sub Brand Volume Data for Historical Contract.'));
            }
            system.debug('HistoricalContract_SBList: ' + HistoricalContract_SBList );
            set<id> sbId_set = new set<id>();
            if (HistoricalContract_SBList.size() > 0){
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c sbttemp : HistoricalContract_SBList ){
                    sbId_set.add(sbttemp.ASI_CRM_CN_Sub_Brand__c);
                    mapBRSFLine.put(sbttemp.ASI_CRM_CN_Sub_Brand__c, sbttemp);
                }
                system.debug('mapBRSFLine' + mapBRSFLine);
            }
            //Historical ROI Period map
            //Execute function "checkFYDayPeriod" to return the breakdown of the period in last contract to a map of pairs of "Fiscal Year Last Date" (key) and "Number of month covered of last contract in the fiscal year" (value)   
            //map<date, decimal> HistContractPeriod = checkFYDayPeriod(LastPO.ASI_CRM_CN_PO_Start_Date__c, LastPO.ASI_CRM_CN_PO_End_Date__c);

            map<date, decimal> HistContractPeriod = checkFYDayPeriod(v0StartD, v0EndD);
            if (HistContractPeriod.size() > 0){
            // Create the map “HCROL_map” for each subbrand item in historical contract in each Fiscal Year, with key and value:
            // Key: String value of date value “Last Date of each Fiscal Year” + String value of “Subbrand id”
            // Value: from the class “SubBrandProrate”:
            //    strPeriod: value from the map “HistContractPeriod” obtained by the key
            //    sbid: Subbrand id
                string strkey;
                for (date hctemp : HistContractPeriod.keyset() ){
                    if (sbId_set.size() > 0){
                        for (id brsfidtemp : sbId_set){
                            strkey = string.valueof(hctemp) + brsfidtemp;
                            if (!HCROI_mapv0.containskey(strkey)){
                                system.debug('brsfidtemp' + brsfidtemp);
                                SubBrandProrate newsb = new SubBrandProrate();
                                newsb.strPeriod = HistContractPeriod.get(hctemp);
                                newsb.sbid = brsfidtemp;
                                HCROI_mapv0.put(strkey, newsb);
                            }
                        }
                    }
                }
            }
            system.debug('HCROI_mapv0: ' + HCROI_mapv0);
            //Query Historical Contract Actual YTD CM
            //date strStart = LastPO.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            date strStart = v0StartD.addYears(-1);
            date strEnd = v0EndD.addYears(+1);
            
            //20170125 Elufa
            date strStartBGDate2 = date.newInstance(v0StartD.addYears(-3).year(), 6, 30);
            date strEndBGDate2 = date.newInstance(v0EndD.addYears(+1).year(), 6, 30);
            Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
            //20170125 End
            
            system.debug('Outlet_acc (ActualCM): ' + Outlet_acc );
            // Select the monthly Gross Sales and Cost Margin (i.e. profit margin) of each sub-brand within the last contract’s contract period from the object “Actual CM GS”(ASI_CRM_CM_GS) to the list “sb_actualcm_list”
            try{
                sb_actualcm_list = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_CR12_Factor__c, 
                                    ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__c , ASI_CRM_TYPE__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_CN_Month__c
                                    FROM ASI_CRM_CM_GS__c
                                    WHERE ASI_CRM_PRODUCTCODE__c IN :sbId_set AND
                                    (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                                    AND ASI_CRM_Region__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                    AND ((ASI_CRM_CN_Month_End_Date__c >= :strStart
                                          AND ASI_CRM_CN_Month_End_Date__c <= :strEnd)
                                         OR (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 //20170125 Elufa
                                             AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2//20170125 Elufa
                                             AND ASI_CRM_CN_Month__c = 6 )
                                        )
                                    ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ];
            }catch(exception e){
                system.debug('Try sb_actualcm_list: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Actual YTD CM Data for Historical Contract.'));
                sb_actualcm_list = new list<ASI_CRM_CM_GS__c>();
            }
            
            // Added By Alan Wong (Elufa) 20160609
            try{
                
                String currentFY2 = '' + (CurrentFiscalYear - 1);//20170125 Elufa
                String currentFY3 = '' + (CurrentFiscalYear - 2);//20170125 Elufa
                
                sb_HCProFormaCM_list = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_CN_Month__c
                                        FROM ASI_CRM_CM_GS__c
                                        WHERE ASI_CRM_PRODUCTCODE__c IN :sbId_set 
                                        AND (ASI_CRM_TYPE__c = 'Budget CM')
                                        AND ASI_CRM_Region__c = :Outlet_acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                        AND (ASI_CRM_YEAR__c = :string.valueOf(CurrentFiscalYear) 
                                             OR ASI_CRM_YEAR__c = :currentFY2//20170125 Elufa
                                             OR ASI_CRM_YEAR__c = :currentFY3)//20170125 Elufa
                                        AND ASI_CRM_CN_Month__c = 6
                                        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC];
            }catch(exception e){
                system.debug('Try sb_HCProFormaCM_list: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Actual YTD CM Data for Historical Contract.'));
                sb_HCProFormaCM_list = new list<ASI_CRM_CM_GS__c>();
            }
            for (ASI_CRM_CM_GS__c HCLatestBudget: sb_HCProFormaCM_list)
            {
                if(HCLatestBudget.ASI_CRM_CM_GS_per_9L__c == null)
                    HCLatestBudget.ASI_CRM_CM_GS_per_9L__c = 0;
                if(!HCLatestBudget_Map.containsKey(HCLatestBudget.ASI_CRM_PRODUCTCODE__c) && HCLatestBudget.ASI_CRM_CM_GS_per_9L__c != Null && HCLatestBudget.ASI_CRM_CM_GS_per_9L__c != 0)//20161114 Elufa
                    HCLatestBudget_Map.put(HCLatestBudget.ASI_CRM_PRODUCTCODE__c, HCLatestBudget.ASI_CRM_CM_GS_per_9L__c);
            }
            // -- End -- //
            //Actual CM/GS for Historical Contract
            map<id, decimal> latest_cm = new map<id, decimal>();
            map<id, decimal> latest_gs = new map<id, decimal>();
            if (sb_actualcm_list.size() > 0){
                string subbrand_id;
                string strkey;
                date strDatecheckFY;
                decimal totalactualcm = 0;
                decimal totalactualgs = 0;
                for (ASI_CRM_CM_GS__c actualcmTemp : sb_actualcm_list){
                    subbrand_id = actualcmTemp.ASI_CRM_PRODUCTCODE__c;
                    strDatecheckFY = checkFYDate(actualcmTemp.ASI_CRM_CN_Month_End_Date__c);
                    strkey = string.valueof(strDatecheckFY) + subbrand_id;
                    
                    //20170125 Elufa
                    if(actualcmTemp.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(actualcmTemp.ASI_CRM_PRODUCTCODE__c + actualcmTemp.ASI_CRM_TYPE__c) && actualcmTemp.ASI_CRM_CM_GS_per_9L__c != null && actualcmTemp.ASI_CRM_CM_GS_per_9L__c != 0){
                        cmgsMap.put(actualcmTemp.ASI_CRM_PRODUCTCODE__c + actualcmTemp.ASI_CRM_TYPE__c, actualcmTemp);
                    }
                    //20170125 End
                    
                    //YTD CM (9L)
                    // 1. Assign “Actual CM per 9L” information (in the field “strCM” of the class “SubBrandProrate” of the value) from the list “sb_actualcm_list” to the map “HCROL_map”
                    // 2. Create a map "latest_cm" to store the latest “Actual CM per 9L” information for each sub-brand in the last contract’s contract period
                    if (actualcmTemp.ASI_CRM_TYPE__c == 'Budget CM'){
                        if (actualcmTemp.ASI_CRM_CM_GS_per_9L__c != null) {
                            totalactualcm = actualcmTemp.ASI_CRM_CM_GS_per_9L__c; // / actualcmTemp.ASI_CRM_CN_Standard_Bottle_Factor__c; 
                        }else{
                            totalactualcm = 0;
                        }
                        // Latest version of CM (ASI_CRM_VERSION__c DESC) would be stored in the map “HCROI_mapv0” only. Thus, if the value of CM is null, CM valued would be filled into the map. Otherwise, it means the current CM value obtained is not the latest version and it is not required to fill in.
                        if (HCROI_mapv0.containskey(strkey)){
                            if((HCROI_mapv0.get(strkey).strCM == null || HCROI_mapv0.get(strkey).strCM == 0) && totalactualcm != Null && totalactualcm != 0){//2016114 Elufa
                                HCROI_mapv0.get(strkey).strCM = totalactualcm ;
                            }
                            // Added By Alan Wong (Elufa) 20160609
                            if (HCROI_mapv0.get(strkey).LatestCM == null){
                                if (HCLatestBudget_Map.containsKey(subbrand_id)){
                                    HCROI_mapv0.get(strkey).LatestCM = HCLatestBudget_Map.get(subbrand_id) ;
                                }
                            }
                            // -- End -- //
                        }
                    }
                    //YTD GS (9L)
                    // 1. Assign Actual GS per 9L information (in the field “strGS” of the class “SubBrandProrate” of the value) from the list “sb_actualcm_list” to the map “HCROL_map”
                    // 2. Create a map "latest_ gs " to store the latest “Actual GS per 9L” information for each sub-brand in the last contract’s contract period
                    if (actualcmTemp.ASI_CRM_TYPE__c == 'Budget GS'){
                        if (actualcmTemp.ASI_CRM_CM_GS_per_9L__c != null ){
                            totalactualgs = actualcmTemp.ASI_CRM_CM_GS_per_9L__c; // / actualcmTemp.ASI_CRM_CN_Standard_Bottle_Factor__c; 
                        }else{
                            totalactualgs = 0;
                        }
                        if (HCROI_mapv0.containskey(strkey)){//20161214 Elufa
                            if((HCROI_mapv0.get(strkey).strGS == null || HCROI_mapv0.get(strkey).strGS == 0) && totalactualgs != null && totalactualgs != 0){
                                HCROI_mapv0.get(strkey).strGS = totalactualgs ;
                            }
                        }
                    }
                }
                
                //20170125 Elufa to replace null/0 value with latest CMGS data
                for(String key : HCROI_mapv0.keySet()){
                    if(HCROI_mapv0.get(key).strCM == Null || HCROI_mapv0.get(key).strCM == 0 || HCROI_mapv0.get(key).strGS == Null || HCROI_mapv0.get(key).strGS == 0 || HCROI_mapv0.get(key).LatestCM == Null || HCROI_mapv0.get(key).LatestCM == 0){
                        if((HCROI_mapv0.get(key).strCM == Null || HCROI_mapv0.get(key).strCM == 0) && cmgsMap.containsKey(HCROI_mapv0.get(key).sbid + 'Budget CM')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(HCROI_mapv0.get(key).sbid + 'Budget CM');
                            
                            HCROI_mapv0.get(key).strCM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                        }
                        
                        if((HCROI_mapv0.get(key).strGS == Null || HCROI_mapv0.get(key).strGS == 0) && cmgsMap.containsKey(HCROI_mapv0.get(key).sbid + 'Budget GS')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(HCROI_mapv0.get(key).sbid + 'Budget GS');
                            
                            HCROI_mapv0.get(key).strGS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                        }
                        
                        if(HCROI_mapv0.get(key).LatestCM == Null || HCROI_mapv0.get(key).LatestCM == 0){
                            if(HCLatestBudget_Map.containsKey(HCROI_mapv0.get(key).sbid))
                                HCROI_mapv0.get(key).LatestCM = HCLatestBudget_Map.get(HCROI_mapv0.get(key).sbid);
                        }
                    }
                }
                //20170125
                
            }
            system.debug('HCROI_mapv0: ' + HCROI_mapv0);
            //system.debug('latest_cm: ' + latest_cm);
            
            //Loop Historical SB List            
            decimal LastPO_Vol = 0;
            decimal LastPO_Vol_temp = 0;
            decimal LastPO_Vol_CR12 = 0;
            decimal LastPO_Vol_CR12_temp = 0;
            decimal LastPO_Vol_9L_CM = 0;
            decimal LastPO_Vol_9L_GS = 0;
            decimal LastPO_Vol_ROI = 0;
            decimal LastPO_Vol_GS = 0;
            
            decimal strLastPOtotalVol = 0;
            decimal strTotalSBGS = 0;
            decimal LastProFormatotalVol = 0; // Added by Alan Wong (Elufa) 20160609
            decimal LatestPO_Vol_9L_CM = 0; // Added by Alan Wong (Elufa) 20160609
            
            date strEndDate;
            
            map <id, decimal> LastPO_VolBtl_map = new map <id, decimal>();
            system.debug('HistoricalContract_SBList: ' + HistoricalContract_SBList );
            if (HCROI_mapv0.size() > 0){
                string subbrand_id;
                string strkey;
                decimal actualcm;
                decimal actualgs;
                decimal lastcm;
                map<id, SubBrandProrate> sb_datadate_map = new map<id, SubBrandProrate>();
                map<id, SubBrandProrate> sb_datadate_CR12_map = new map<id, SubBrandProrate>();
                map<date, map<id, SubBrandProrate>> sb_datadate_ROI_map = new map<date, map<id, SubBrandProrate>>();
                // Add up the “Volume 9L” of each sub-brand from different wholesalers (PR_Direct, T1 Depletion, T2 Depletion) within the time period and covered outlets of last contract for each fiscal year accordingly. 
                for (String hc_sbtemp : HCROI_mapv0.keyset()){
                    strkey = hc_sbtemp;
                    actualcm = 0;
                    actualgs = 0;
                    lastcm = 0; // Added by Alan Wong (Elufa) 20160609
                    LastPO_Vol_temp = 0;
                    subbrand_id  =  HCROI_mapv0.get(strkey).sbid;
                    //Total Volume 9L cs for Historical Contract (prepare for proration)
                    if(mapBRSFLine.containsKey(subbrand_id)){
                        system.debug('mapBRSFLine.get(subbrand_id).ASI_CRM_CN_Estimate_Volume_9L_Month__c * HCROI_mapv0.get(strkey).strPeriod' + mapBRSFLine.get(subbrand_id).ASI_CRM_CN_Estimate_Volume_9L_Month__c + '    ' + HCROI_mapv0.get(strkey).strPeriod);
                        LastPO_Vol_temp = mapBRSFLine.get(subbrand_id).ASI_CRM_CN_Estimate_Volume_9L_Month__c * HCROI_mapv0.get(strkey).strPeriod;
                    }

                    if (HCROI_mapv0.containskey(strkey)){
                        actualcm = HCROI_mapv0.get(strkey).strCM;
                        lastcm = HCROI_mapv0.get(strkey).LatestCM;
                    }
                    
                    else{
                        actualcm = 0;
                        lastcm = 0;
                    }

                    if (HCROI_mapv0.containskey(strkey)){
                        if (HCROI_mapv0.get(strkey).strGS != null)
                            actualgs = HCROI_mapv0.get(strkey).strGS;
                        else
                            actualgs = 0;
                    }
                    
                    system.debug('latest_cm: ' + latest_cm);
                    system.debug('actualcm: ' + actualcm  + ' actualgs: ' + actualgs);
                    system.debug('LastPO_Vol_temp: ' + LastPO_Vol_temp + ' * ' + actualcm);
                    //for Historical Contract ROI
                    LastPO_Vol_9L_CM  = 0;
                    LatestPO_Vol_9L_CM = 0;
                    if (actualcm != null){
                        LastPO_Vol_9L_CM = LastPO_Vol_temp * actualcm;
                    }
                    if (lastcm != null){
                        LatestPO_Vol_9L_CM = LastPO_Vol_temp * lastcm;
                    }
                    LastPO_Vol_9L_GS =0;
                    if (actualgs != null)
                        LastPO_Vol_9L_GS = LastPO_Vol_temp * actualgs;
                    //system.debug('LastPO_Vol_9L_CM: ' + LastPO_Vol_9L_CM );
                    //system.debug('LastPO_Vol_9L_GS: ' + LastPO_Vol_9L_GS );
                    
                    //Volume 9L Map 
                    // Sum up the “9L Volume”, CM and GS for each sub-brand and store in the map instance “sb_datadate_map”
                    if (sb_datadate_map.containskey(subbrand_id)){
                        SubBrandProrate newitem = sb_datadate_map.get(subbrand_id);
                        newitem.strVolume += LastPO_Vol_temp;
                        newitem.strCM += LastPO_Vol_9L_CM;
                        newitem.LatestCM += LatestPO_Vol_9L_CM;
                        newitem.strGS += LastPO_Vol_9L_GS;
                        sb_datadate_map.put(subbrand_id , newitem);
                    }else{
                        SubBrandProrate newsb = new SubBrandProrate();
                        newsb.strVolume = LastPO_Vol_temp;
                        newsb.strCM = LastPO_Vol_9L_CM;
                        newsb.LatestCM = LatestPO_Vol_9L_CM;
                        newsb.strGS = LastPO_Vol_9L_GS;
                        //newsb.sbname = hc_sbtemp.ASI_CRM_Subbrand__r.name; 20161214 Elufa
                        sb_datadate_map.put(subbrand_id , newsb);
                    }
                    system.debug('sb_datadate_map: ' + sb_datadate_map);
                    LastPO_Vol_CR12_temp = 0;
                    //Total Volume CR12 for Historical Contract (prepare for proration)
                    if(mapBRSFLine.containsKey(subbrand_id)){
                        
                        double cr12 = mapBRSFLine.get(subbrand_id).ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null ? mapBRSFLine.get(subbrand_id).ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c : 0;
                        
                        LastPO_Vol_CR12_temp = mapBRSFLine.get(subbrand_id).ASI_CRM_CN_Est_Monthly_Qty__c * mapBRSFLine.get(subbrand_id).ASI_CRM_CN_No_of_Months__c * cr12;
                    }
                    //Volume CR12 Map
                    if (sb_datadate_CR12_map.containskey(subbrand_id)){
                        sb_datadate_CR12_map.get(subbrand_id).strVolume += LastPO_Vol_CR12_temp;
                    }else{
                        SubBrandProrate newsb = new SubBrandProrate();
                        newsb.strVolume = LastPO_Vol_CR12_temp;
                        sb_datadate_CR12_map.put(subbrand_id, newsb);
                    }
                    system.debug('sb_datadate_CR12_map: ' + sb_datadate_CR12_map);
                  
                }
                
                //Calculate Prorated Volume
                //Integer LastPONoMonths = MonthDiff(LastPO.ASI_CRM_CN_PO_Start_Date__c, LastPO.ASI_CRM_CN_PO_End_Date__c);
                Integer LastPONoMonths = MonthDiff(v0StartD, v0EndD);
                //Integer CutOffPeriod = MonthDiff(LastPO.ASI_CRM_CN_PO_Start_Date__c, CutOffDay);
                Integer CutOffPeriod = MonthDiff(v0StartD, CutOffDay);
                integer strDiffEnd = 0;
                if (LastPONoMonths != null && CutOffPeriod != null)
                    strDiffEnd  = LastPONoMonths - CutOffPeriod;
                //Volume 9L = Total Volume
                decimal tempCM = 0;
                decimal tempGS = 0;
                decimal tempProFormaCM = 0; // Added by Alan Wong (Elufa) 20150609
                if (sb_datadate_map.size() > 0){
                    decimal tempVol = 0;
                    for (id vol_temp : sb_datadate_map.keyset()){ 
                        SubBrandProrate item = sb_datadate_map.get(vol_temp);
                        tempVol = 0 ; 
                        tempCM = 0;
                        tempGS = 0;  
                        actualgs = 0;
                        actualcm = 0;
                        tempProFormaCM = 0;
                        lastcm = 0;
                        decimal proratevol = 0;
                        
                        system.debug('Prorate proratevol actualcm : ' + item.sbname + ' - ' + proratevol + ' * ' + actualcm + ' = ' + tempCM );
                        strLastPOtotalVol += (tempCM + item.strCM); // Calculate the Profit (CM * Volume) of each sub-brand
                        strTotalSBGS += (tempGS + item.strGS); // Calculate the Gross Sales (GS * Volume) of each sub-brand
                        LastPO_Vol += item.strVolume;
                        LastProFormatotalVol += (tempProFormaCM + item.LatestCM); // Added By Alan Wong (Elufa) 20160609
                    }
                    
                }

                system.debug('HC ROI LastProFormatotalVol : ' + LastProFormatotalVol );
                system.debug('HC ROI strLastPOtotalVol : ' + strLastPOtotalVol );
                //system.debug('HC ROI LastPO_Vol_9L_CM: ' + LastPO_Vol_9L_CM);

                //ASI_CRM_CN_Last_Contract_Volume_Total__c 
                if (LastPO_Vol != 0 && LastPO_Vol != null)
                    //PC.ASI_CRM_CN_Last_Contract_Volume_Total__c = LastPO_Vol;
                    PC.ASI_CRM_CN_Last_V0_Contract_Volume_Total__c = LastPO_Vol;
                else
                    //PC.ASI_CRM_CN_Last_Contract_Volume_Total__c = 0;
                    PC.ASI_CRM_CN_Last_V0_Contract_Volume_Total__c = 0;
                
                //Calculate Prorated Volume CR12 for Historical Contract Investment CR 12 eq Btl
                if (sb_datadate_CR12_map.size() > 0){
                    decimal tempVol = 0;
                    for (SubBrandProrate vol_temp : sb_datadate_CR12_map.values()){
                        tempVol =0;
                        if (CutOffPeriod != 0 && CutOffPeriod != null){
                            tempVol = (vol_temp.strVolume / CutOffPeriod ); 
                        }  
                        if (strDiffEnd != 0 && strDiffEnd != null && tempVol !=0){
                            LastPO_Vol_CR12 += tempVol * strDiffEnd;
                        }  
                        LastPO_Vol_CR12 += vol_temp.strVolume;
                    }
                    system.debug('Investment CR12 CutOffPeriod : ' + CutOffPeriod + ' strDiffEnd: ' + strDiffEnd );
                }
                
                decimal strTradeExpense;
                if (TotalFixed_Cost != null)
                    strTradeExpense = TotalFixed_Cost ;
                if (TotalVar_Cost != null)
                    strTradeExpense += TotalVar_Cost ;
                if (TotalBRSF_Est_Cost != null)
                    strTradeExpense += TotalBRSF_Est_Cost;
                
                //ASI_CRM_CN_Last_Contract_Investment_CR12__c 
                system.debug('LastPO_Vol_CR12: ' + LastPO_Vol_CR12 );
                
                if (LastPO_Vol_CR12 != 0 && strTradeExpense != null && strTradeExpense !=0){
                    //PC.ASI_CRM_CN_Last_Contract_Investment_CR12__c = strTradeExpense/ LastPO_Vol_CR12;
                    PC.ASI_CRM_CN_Last_V0_Contract_InvestCR12__c = strTradeExpense/ LastPO_Vol_CR12;
                }else{
                    //PC.ASI_CRM_CN_Last_Contract_Investment_CR12__c = 0;
                    PC.ASI_CRM_CN_Last_V0_Contract_InvestCR12__c = 0;
                }
                
                
                //Total Volume By Subbrand * Actual YTD CM / Total Cost(Investment)
                system.debug('strLastPOtotalVol: ' + strLastPOtotalVol );
                if (strLastPOtotalVol != null && strLastPOtotalVol != 0&& strTradeExpense!= null && strTradeExpense!= 0) {
                    //PC.ASI_CRM_CN_Last_Contract_ROI__c = strLastPOtotalVol / strTradeExpense;
                    PC.ASI_CRM_CN_Last_V0_Contract_ROI__c = strLastPOtotalVol / strTradeExpense;
                }else{
                    //PC.ASI_CRM_CN_Last_Contract_ROI__c = 0;
                    PC.ASI_CRM_CN_Last_V0_Contract_ROI__c = 0;
                }
                // Added By Alan Wong (Elufa) 20160609
                // Last Contract Pro-Forma ROI
                if (LastProFormatotalVol != null && LastProFormatotalVol != 0&& strTradeExpense!= null && strTradeExpense!= 0) {
                    //PC.ASI_CRM_Last_Contract_Pro_Forma_ROI__c = LastProFormatotalVol / strTradeExpense;
                    PC.ASI_CRM_CN_Last_V0_Contract_Pro_FormaROI__c = LastProFormatotalVol / strTradeExpense;
                }else{
                    //PC.ASI_CRM_Last_Contract_Pro_Forma_ROI__c = 0;
                    PC.ASI_CRM_CN_Last_V0_Contract_Pro_FormaROI__c = 0;
                }
                // -- End -- //
                //% of Total Trade A&P / GS
                if (strTotalSBGS  != null && strTotalSBGS != 0 && strTradeExpense != null && strTradeExpense != 0){
                    //PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c = strTradeExpense / strTotalSBGS * 100;
                    PC.ASI_CRM_CN_Last_V0_Contract_Total_APGS__c = strTradeExpense / strTotalSBGS * 100;
                }else{
                    //PC.ASI_CRM_CN_Last_Contract_TotalAPGS__c = 0;
                    PC.ASI_CRM_CN_Last_V0_Contract_Total_APGS__c = 0;
                }
            }else{
                PC.ASI_CRM_CN_Last_V0_Contract_ROI__c = 0;
                PC.ASI_CRM_CN_Last_V0_Contract_Pro_FormaROI__c = 0;
                PC.ASI_CRM_CN_Last_V0_Contract_Total_APGS__c = 0;
                PC.ASI_CRM_CN_Last_V0_Contract_InvestCR12__c = 0;
                PC.ASI_CRM_CN_Last_V0_Contract_Volume_Total__c = 0;
            }
        }else{
            PC.ASI_CRM_CN_Last_V0_Contract_ROI__c = 0;
            PC.ASI_CRM_CN_Last_V0_Contract_Pro_FormaROI__c = 0;
            PC.ASI_CRM_CN_Last_V0_Contract_Total_APGS__c = 0;
            PC.ASI_CRM_CN_Last_V0_Contract_InvestCR12__c = 0;
            PC.ASI_CRM_CN_Last_V0_Contract_Volume_Total__c = 0;
        }
    }
    //20160930,added by Leo
    
    public string CalculateAlign(string key, decimal strNew){
        string YesNo;
        YesNo = 'N/A';
        if (Align_map.containskey(key)){
            ASI_CRM_CN_PreContract_AlignSetting__c Setting = Align_map.get(key);
            if(strNew >= Setting.ASI_CRM_CN_Alignment_Value__c && Setting.ASI_CRM_CN_Operation__c == '>='){
                YesNo = 'Yes'; 
            }
            else if(strNew < Setting.ASI_CRM_CN_Alignment_Value__c && Setting.ASI_CRM_CN_Operation__c == '<'){
                YesNo = 'Yes';
            }
            else YesNo = 'No';
            System.debug(Setting);
        }
        System.debug(YesNo+'/'+ key+'/'+ strNew);
        return YesNo;
    }

    public pageReference Share(){
        showError = false;
        noManager = false;
        shareChatter();
        if (showError != false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'不能分享至经理.'));
        }else if (noManager != false){
            return null;
        }else{
            if (PageId != null){
                try{ 
                    ASI_CRM_PreContractEval__c updatePC = new ASI_CRM_PreContractEval__c();
                    updatePC.id = PageId;
                    updatePC.ASI_CRM_Status__c = 'Shared';
                    update updatePC;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'成功分享至经理.'));
                }catch(exception e){
                    system.debug('Update status failed: ' + e);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'不能分享至经理.'));
                }
            }
        }
        return null;
    }
    public pagereference shareChatter(){
        Id UserId = UserInfo.getUserId();
        Id ManagerId = [SELECT Managerid FROM USER WHERE Id = :UserId].Managerid;
        id subjectId = PageId;
        String communityId = null;
        if (ManagerId != null){
            try{
                //Add a @Mention UserId to Feeditem
                ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = 'Hi ';
                messageInput.messageSegments.add(textSegment);
                
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = ManagerId;
                messageInput.messageSegments.add(mentionSegment);
                
                String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                string url = salesforceHost + '/apex/ASI_CRM_CN_PreContractEvalView?id=' + PageId;
                
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '. 我分享了一份试算合同给你.'; //'\nDetails: ' + url;
                messageInput.messageSegments.add(textSegment);
                
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.body = messageInput;
                ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, subjectId, input, null);
            }catch(exception e){
                system.debug('Share Failed: ' + e);
                showError = true;
            }
        }else{
            system.debug('No ManageId to share');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'不能分享至经理.'));
            noManager = true;
        }
        return null;
    }
    public integer MonthDiff(Date startDate, Date endDate){
        Date a = startDate;
        Date b = endDate;
        /*Integer monthDiff = a.monthsBetween(b);
if (b.day() > a.day()) monthDiff++;
*/
        if (startDate != null && endDate != null){
            Integer monthDiff = ((endDate.YEAR() - startDate.YEAR() - 1) *12) + (12 - startDate.MONTH() +1) + endDate.MONTH();
            System.debug(monthDiff);
            return monthDiff;
        }else{
            return null;
        }
    }
    //AutoComplete for lookup
    @RemoteAction
    public static String[] findSObjects(string obj, string qry, string rec) {
        string RA_UserId = UserInfo.getUserId();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';
        //boolean RA_showCN;
        List <ASI_MFM_Sub_brand__c> sub_brand = new List<ASI_MFM_Sub_brand__c>();
        map<string, id> map_recordtype =ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');
        
        try {
            sub_brand=[SELECT id, Name,ASI_MFM_Active_for_CRM__c,RecordTypeid, ASI_CRM_CN_CHI_NAME_C__c  
                       FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = TRUE 
                       AND RecordTypeid = :map_recordtype.get('ASI_FOC_CN_Sub_brand') 
                       AND Name like :key 
                       AND ASI_MFM_Brand__r.ASI_CRM_CN_Competitor__c = FALSE
                       ORDER BY NAME];
            
            for(ASI_MFM_Sub_brand__c sb:sub_brand){
                //results.add(sb.Name + ' ('+ sb.ASI_CRM_CN_CHI_NAME_C__c + ')' );  
                results.add(sb.Name);    
            }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
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
            if (returnDate > LastPO.ASI_CRM_CN_PO_End_Date__c){
                returnDate = LastPO.ASI_CRM_CN_PO_End_Date__c;
            }
            //returnDate = Date.newinstance(Date.Today().Year(),Date.Today().Month(),strDay);
        }else{
            returnDate = LastPO.ASI_CRM_CN_PO_End_Date__c;
        }
        if (isTest == '1' && isTestDate != null && isTestDate != ''){
            system.debug('TestDate: ' + integer.valueof(isTestDate.Left(4)) + ' ' + integer.valueof(((isTestDate.Right(4)).Left(2))) + ' ' + integer.valueof(isTestDate.Right(2)));
            return Date.newinstance(integer.valueof(isTestDate.Left(4)),integer.valueof(((isTestDate.Right(4)).Left(2))),integer.valueof(isTestDate.Right(2)));          
        }
        system.debug('CutOffDate: ' + returnDate);
        return returnDate;
    }
    //20160930, added by Leo
    public date v0CutOffDate(integer strDay){
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
            if (returnDate > v0EndD){
                returnDate = v0EndD;
            }
            //returnDate = Date.newinstance(Date.Today().Year(),Date.Today().Month(),strDay);
        }else{
            returnDate = v0EndD;
        }
        if (isTest == '1' && isTestDate != null && isTestDate != ''){
            system.debug('TestDate: ' + integer.valueof(isTestDate.Left(4)) + ' ' + integer.valueof(((isTestDate.Right(4)).Left(2))) + ' ' + integer.valueof(isTestDate.Right(2)));
            return Date.newinstance(integer.valueof(isTestDate.Left(4)),integer.valueof(((isTestDate.Right(4)).Left(2))),integer.valueof(isTestDate.Right(2)));          
        }
        system.debug('CutOffDate: ' + returnDate);
        return returnDate;
    }
    //20160930, added by Leo
    public date checkFYDate(date strDate){
        integer strYear;
        date returnDate;
        if (strDate != null){
            if (strDate.Month() > 6 && strDate.Month() < 13)
                strYear = strDate.Year() + 1;
            else if (strDate.Month() < 7 && strDate.Month() > 0)
                strYear = strDate.Year();
            //system.debug('checkFYDate strYear: ' + strYear);
            returnDate = Date.newinstance(strYear,6,30);
            return returnDate;
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
                        system.debug('returnDate <= startDate: ' + returnDate + ' - ' + startDate);
                    }else if (returnDate > startDate && returnDate < endDate){
                        strtemp = MonthDiff(tempDate, returnDate);
                        system.debug('(returnDate > startDate && returnDate < endDate): ' + tempDate + ' - ' + returnDate);
                    }else if (returnDate >= endDate){
                        strtemp = MonthDiff(tempDate, endDate);
                        system.debug('returnDate >= endDate: ' + endDate + ' - ' + returnDate);
                    }else if (returnDate >= startDate && returnDate >= endDate){
                        strtemp = MonthDiff(startDate, returnDate);
                        system.debug('returnDate >= startDate && returnDate >= endDate: ' + startDate + ' - ' + returnDate);
                    }
                    returnDateMap.put(returnDate, decimal.valueof(strtemp));
                    tempDate = Date.newinstance(StartFY,7,1);
                    system.debug('tempDate: ' + tempDate );
                    StartFY++;
                }
            }
            system.debug('checkFYDayPeriod: ' + returnDateMap);
            return returnDateMap;
        }else{
            return null;
        }
    }
    public pageReference MainCancel(){
        pageReference mainpage = Page.ASI_CRM_CN_PreContractEvalMain;
        mainpage.setredirect(true);
        return mainpage;
    }
    /**
     * @DateTime 2020-08-03
     * 复制po试算
     */
    public pagereference Copy(){
        String whereClause = 'ID =:PageId';
        PageReference newPage = null;
        ASI_CRM_PreContractEval__c newPreContractEval = new ASI_CRM_PreContractEval__c();
        String sqlQuery = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_PreContractEval__c',whereClause,'');
        List<ASI_CRM_PreContractEval__c> preContractEvalList = Database.query(sqlQuery);
        if(preContractEvalList.size()>0){
            newPreContractEval = preContractEvalList[0].clone(false,true,false,false);
            insert newPreContractEval;
            CopyIncentive(newPreContractEval.Id);
            newPage = new PageReference('/apex/ASI_CRM_CN_PreContractEval_Page?id='+newPreContractEval.Id);
        }else{
            newPage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalView?id='+PageId);
        }
        System.debug(LoggingLevel.INFO, '*** newPreContractEval: ' + newPreContractEval);
        newPage.setRedirect(true);
        return newPage;
    }
    /**
     * @DateTime 2020-08-03
     * @param    ContractEvalId 
     */
    public void CopyIncentive(Id ContractEvalId){
        String whereClause = 'ASI_CRM_Pre_Contract_Eval__c =: PageId';
        String sqlQuery = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_Pre_Contract_Sub_Brand__c',whereClause,'');
        List<ASI_CRM_Pre_Contract_Sub_Brand__c> IncentiveList = Database.query(sqlQuery);
        List<ASI_CRM_Pre_Contract_Sub_Brand__c> newIncentiveList = new List<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        for(ASI_CRM_Pre_Contract_Sub_Brand__c b : IncentiveList){
            ASI_CRM_Pre_Contract_Sub_Brand__c newSubBrand = b.clone(false,true,false,false);
            newSubBrand.ASI_CRM_Pre_Contract_Eval__c = ContractEvalId;
            newIncentiveList.add(newSubBrand);
        }
        if(newIncentiveList.size()>0){
            insert newIncentiveList;
        }
        
    }

    public class SubBrandProrate{
        public decimal strVolume {set;get;}
        public decimal strGS {set;get;}
        public decimal strCM {set;get;}
        public date strDate {set;get;}
        public decimal strPeriod {set;get;}
        public id sbid {set;get;}
        public string sbname {set;get;}
        public decimal LatestCM {set;get;} // Added by Alan Wong (Elufa) 20150608
    }
    
    //20161031, Elufa
    @RemoteAction
    public static void dateChangeAlert()
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Start Date change may update Last PO value.'));
    }
    //20161031, Elufa
    //
    public class SubbrandVolume {
        public String subbrandId {get;set;}
        public Decimal volume {get;set;}
    }
}