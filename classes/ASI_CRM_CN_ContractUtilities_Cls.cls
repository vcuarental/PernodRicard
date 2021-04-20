/**********************************************************
Summary, Summary, Historical/Contract/Estimate, VariableExpensesTable 
Review, Review, Sub-brand Group, VariableExpensesTable 
Variable Expenses, Sub-brand Grade, Sub-brand Id, VariableExpensesTable 

*********************************************************/
public class ASI_CRM_CN_ContractUtilities_Cls{
    
    private static integer strCutOffDay = 16;
    public static String lineBreak = '\n';
    private static String reservedPattern = '[.,;。，、:：；　 \'"/）)]';
    public static decimal IntChar = 112;
    public class ContractSummary{
        public decimal strROI {set;get;}
        public decimal strTotalCMVol {set;get;}
        public decimal strTotalGSVol {set;get;}
        public decimal strInvestCR12 {set;get;}
        public decimal MarginAP {set;get;}
        public decimal strMarginBottle {set;get;}
        
        public decimal strTotalInvest {set;get;}
        public decimal strTotalVolume {set;get;}
        public decimal strTotalBtl {set;get;}
        public decimal strTotalStdBtl {set;get;}
        
        public integer strCutOffPeriod {set;get;}
        public decimal strContractPeriod {set;get;}
        public decimal strDiff {set;get;}
        public decimal totalExpense {set;get;}
        public decimal fixExpense {set;get;}
        public decimal varExpense {set;get;}
        public decimal fixExpenseRate {set;get;}
        
        public decimal strProrateVolume {set;get;}
        public decimal strProrateCR12 {set;get;}
        public ContractSummary(){
            strROI = 0;
            strTotalCMVol = 0;
            strTotalGSVol = 0;
            strInvestCR12 = 0;
            MarginAP = 0;
            strTotalInvest = 0;
            strTotalVolume = 0;
            strTotalBtl = 0;
            strTotalStdBtl = 0;
            totalExpense = 0;
            fixExpense = 0;
            varExpense = 0;
            strProrateVolume = 0;
            strProrateCR12 = 0;
            strCutOffPeriod = 0;
            strContractPeriod = 0;
            strDiff = 0;
            strMarginBottle = 0;
        }
        public void AddTotalCMVol(decimal input){
            if (input != null)
                strTotalCMVol += input;
        }
        public void AddTotalGSVol(decimal input){
            if (input != null)
                strTotalGSVol += input;
        }
        public void AddTotalBtl(decimal input){
            if (input != null)
                strTotalBtl += input;
        }
        public void AddTotalVolume(decimal input){
            if (input != null)
                strTotalVolume += input;
        }
        public void AddTotalInvestCR12(decimal input){
            if (input != null)
                strTotalInvest += input;
        }
        public void AddTotalStdBtl(decimal input){
            if (input != null)
                strTotalStdBtl += input;
        }
        public void AddvarExpense(decimal input){
            if (input != null)
                varExpense += input;
        }
        public void AddfixExpense(decimal input){
            if (input != null)
                fixExpense += input;
        }
        public void getFixExpRate(){
            if (fixExpense != null && fixExpense != 0 && totalExpense != null && totalExpense != 0)
                fixExpenseRate = fixExpense / totalExpense * 100;
        }
        public void getTotalInvestperBtl(){
            if (totalExpense != null && totalExpense != 0 && strProrateCR12 != null && strProrateCR12 !=0)
                strInvestCR12 = totalExpense / strProrateCR12;
        }
        public void getROIvalue(){
            if (totalExpense != null && totalExpense != 0 && strTotalCMVol != null && strTotalCMVol !=0)
                strROI = strTotalCMVol / totalExpense;
        }
        public void getProratedVolume(){
            if (strContractPeriod != null && strContractPeriod != 0 && strTotalVolume != null && strTotalVolume != 0 && strCutOffPeriod != null && strCutOffPeriod != 0)
                strProrateVolume = (strTotalVolume / strCutOffPeriod  * strContractPeriod);
            else
                strProrateVolume = strTotalVolume;
        }
        public void getProratedInvestCR12(){
            if (strContractPeriod != null && strContractPeriod != 0 && strTotalInvest != null && strTotalInvest != 0 && strCutOffPeriod != null && strCutOffPeriod != 0)
                strProrateCR12 = (strTotalInvest / strCutOffPeriod  * strContractPeriod);
            else
                strProrateCR12 = strTotalInvest;
        }
        public void getMonthDiff(){
            if (strCutOffPeriod != null && strContractPeriod != null)
                    strDiff = (strContractPeriod - strCutOffPeriod);
        }
        public void getGrossSales(){
            if (strTotalGSVol != null && totalExpense != null)
                MarginAP = strTotalGSVol - totalExpense;
        }
        public void getMarginBottle(){
            if (MarginAP != null && MarginAP  != 0 && strTotalStdBtl != null && strTotalStdBtl != 0)
                strMarginBottle = MarginAP / strTotalStdBtl;
        }
        public void gettotalExpense(){
            if (varExpense != null && fixExpense != null)
                totalExpense = varExpense + fixExpense;
        }
        public void getSum(){  
            //for Subbrand volume data          
            getProratedVolume();
            getProratedInvestCR12();
            getROIvalue();
            getTotalInvestperBtl();
            getGrossSales();
            getMarginBottle();
            getFixExpRate();
        }
        public void getNewSum(){ 
            //for BRSF Line item data
            strProrateVolume = strTotalVolume;
            strProrateCR12 = strTotalInvest;  
            gettotalExpense();    
            getROIvalue();
            getTotalInvestperBtl();
            getGrossSales();
            getMarginBottle();
            getFixExpRate();
        }
    }
    public class VariableExpensesTable{
        public string strSBGrade {set;get;}
        public string strSBName {set;get;}
        public string strSBId {set;get;}
        public decimal sequence {set {value=0;}get;}
        
        public decimal HC_Volume {set;get;}
        public decimal Estimate_Volume {set;get;}
        public decimal Contract_Volume {set;get;}
        
        public decimal HC_Qty {set;get;}
        public decimal Estimate_Qty {set;get;}
        public decimal Contract_Qty {set;get;}
        
        public decimal HC_BtlInc {set;get;}
        public decimal Estimate_BtlInc {set;get;}
        public decimal Contract_BtlInc {set;get;}
        
        public decimal HC_total {set;get;}
        public decimal Estimate_total {set;get;}
        public decimal Contract_total {set;get;}
        
        public decimal strROI {set;get;}
        public decimal strInvestperBtl {set;get;}
        public decimal MarginAP {set;get;}
        public decimal MarginperBtl {set;get;}
        public decimal TradeExpense {set;get;}
        public decimal FixExpense {set;get;}
        public decimal VarExpense {set;get;}
        public decimal FixExpenseRate {set;get;}
        public decimal GrossSalesRate {set;get;}
        public decimal TotalVolume {set;get;}
        
        public VariableExpensesTable(){
            sequence = 0;
            HC_Volume = 0;
            Estimate_Volume = 0;
            Contract_Volume = 0;
            HC_Qty = 0;
            Estimate_Qty = 0;
            Contract_Qty = 0;
            HC_BtlInc = 0;
            Estimate_BtlInc = 0;
            Contract_BtlInc = 0;
            strROI = 0;
            strInvestperBtl = 0;
            MarginAP = 0;
            MarginperBtl = 0;
            TradeExpense = 0;
            FixExpense = 0;
            VarExpense = 0;
            FixExpenseRate = 0;
            GrossSalesRate = 0;
            TotalVolume = 0;
        }
        public VariableExpensesTable(string sbGrade, string sbName, id sbId, decimal seq, decimal eQty, decimal eVol, decimal eInc, decimal cQty, decimal cVol, decimal cInc){
            strSBGrade = sbGrade;
            strSBName = sbName;
            strSBId = sbId;
            sequence = seq;
            Estimate_Qty = eQty;
            Estimate_Volume = eVol;
            Estimate_BtlInc = eInc;
            Contract_Qty = cQty;
            Contract_Volume = cVol;
            Contract_BtlInc = cInc;
            
        }
        public VariableExpensesTable(string sbGrade, string sbName, id sbId, decimal seq, decimal HCQty, decimal Vol){
            strSBGrade = sbGrade;
            strSBName = sbName;
            strSBId = sbId;
            sequence = seq;
            HC_Qty = HCQty;
            HC_Volume = Vol;
        }
        public VariableExpensesTable(ContractSummary summary){
            strROI = summary.strROI;
            strInvestperBtl = summary.strInvestCR12;
            MarginAP = summary.MarginAP;
            MarginperBtl = summary.strMarginBottle;
            TradeExpense = summary.totalExpense;
            FixExpense = summary.fixExpense;
            VarExpense = summary.varExpense;
            FixExpenseRate = summary.fixExpenseRate;
            if (summary.strTotalGSVol != null && summary.strTotalGSVol != 0 && MarginAP != null && MarginAP != 0)
                GrossSalesRate = MarginAP / summary.strTotalGSVol * 100;
            TotalVolume = summary.strTotalVolume;
        }
        
        public void AddHCQty(decimal input){
            if (input != null)
                HC_Qty += input;
        }
        public void AddEstimateQty(decimal input){
            if (input != null)
                Estimate_Qty += input;
        }
        public void AddContractQty(decimal input){
            if (input != null)
                Contract_Qty += input;
        }
        public void getSum(){
            GetContractTotal();
            GetEstTotal();
            GetHCTotal();
        }
        public void GetContractTotal(){
            if (Contract_BtlInc != null && Contract_Qty != null)
                Contract_total = Contract_BtlInc * Contract_Qty;
            else Contract_total = 0;
        }
        public void GetEstTotal(){
            if (Estimate_BtlInc != null && Estimate_Qty != null)
                Estimate_total =  Estimate_BtlInc * Estimate_Qty;
            else Estimate_total = 0;
        }
        public void GetHCTotal(){
            if (HC_BtlInc != null && HC_Qty != null)
                HC_total = HC_BtlInc * HC_Qty;
            else HC_total = 0;
        }
    }
    public class MarginTable{
        public string sbName {set;get;}
        public string sbId {set;get;}
        public decimal strVolume {set;get;}
        public decimal strPeriod {set;get;}
        public decimal strCM {set;get;}
        public decimal strGS {set;get;}
        public date strDate {set;get;}
        public MarginTable(){
            strVolume = 0;
            strPeriod = 0;
            strCM = 0;
            strGS = 0;
        }
    }
    

    private static map<string, string> SubbrandGroup = new map<string, string>();
    
    public static ASI_TH_CRM_Contract__c QueryContract(string ContractId){
        ASI_TH_CRM_Contract__c objContract = new ASI_TH_CRM_Contract__c();
        if (contractId != null){
            objContract = [SELECT id, Name, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, 
                          ASI_CRM_CN_Vol_Budget_LE__c,ASI_CRM_CN_PO_Modification__c,
                          ASI_CRM_CN_Contract_Est_Var_Cost_Total__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                          ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,  ASI_CRM_CN_PO_End_Date__c,
                          ASI_CRM_CN_PO_No__c, ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
                          ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                          ASI_CRM_CN_Contract_Variable_Cost_Total__c,ASI_CRM_CN_No_of_Months__c,
                          ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,
                          ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,ASI_CRM_CN_Total_Contract_Amount__c,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
                          ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                          ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                          ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
                          ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                          ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                          ASI_CRM_CN_V0_0_PO_version__c, Owner.Name,
                          ASI_CRM_CN_Status__c ,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                          (SELECT id, Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c,ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                          ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                          ASI_CRM_CN_Sub_Brand_Conversion_Factor__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                          ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name
                          FROM Contract_BRSF_Line_Item__r),
                          (SELECT id, Name,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CN_Contract_Amount__c
                          FROM Contract_Costs__r)
                          FROM ASI_TH_CRM_Contract__c WHERE id = :ContractId];
        }
        return objContract;
    }
    
    public static map<string, map<string, map<string, VariableExpensesTable>>> getSubbrandVolumebyContract(ASI_TH_CRM_Contract__c objContract){
        
        ContractSummary returnSummary = new ContractSummary();
        map<string, map<string, VariableExpensesTable>> VE_Table_map = new map<string, map<string, VariableExpensesTable>>();
        map<string, VariableExpensesTable> Review_Map = new map<string, VariableExpensesTable>();
    
        if (objContract != null){
            
            list<VariableExpensesTable> VETable_SB_List = new list<VariableExpensesTable>();
            
            //Get All Covered Outlet for this contract
            set<id> AllOutlet = new set<id>();
            AllOutlet.add(objContract.ASI_CRM_CN_Outlet_WS__c);
            for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :objContract.id]){
                AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
            }
            //CutOffDate
            date TillEnd = CutOffDate(strCutOffDay, objContract.ASI_CRM_CN_PO_End_Date__c);
            system.debug(TillEnd);
            returnSummary.strContractPeriod = objContract.ASI_CRM_CN_No_of_Months__c;
            returnSummary.strCutOffPeriod = MonthDiff(objContract.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            returnSummary.getMonthDiff();
            returnSummary.totalExpense = objContract.ASI_CRM_CN_Total_Contract_Amount__c;
            returnSummary.fixExpense = objContract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c;
            returnSummary.varExpense = objContract.ASI_CRM_CN_Contract_Variable_Cost_Total__c;   
            if(Test.isRunningTest()){
                if(returnSummary.varExpense != null)       
                    returnSummary.varExpense += objContract.ASI_CRM_CN_BRSF_Contract_Total__c * objContract.ASI_CRM_CN_No_of_Months__c;
            }
            else{     
                returnSummary.varExpense += objContract.ASI_CRM_CN_BRSF_Contract_Total__c * objContract.ASI_CRM_CN_No_of_Months__c;
            }
            
            //Query Sub-brand Volume Data
            list<ASI_CRM_Subbrand_Volume__c> SBList  = [SELECT id, ASI_CRM_Subbrand__c, 
                                               ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.Name,
                                               ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_End_Date__c,
                                               ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_T2_Depletion_BTL__c, ASI_CRM_PR_Direct_Btl__c,
                                               ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c,
                                               ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c, ASI_CRM_PR_Direct_CR12__c, 
                                               ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c, ASI_CRM_PR_Direct_STD__c
                                               FROM ASI_CRM_Subbrand_Volume__c WHERE
                                               ASI_CRM_Account__c IN :AllOutlet
                                               AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                                               AND ASI_CRM_End_Date__c >= :objContract.ASI_CRM_CN_PO_Start_Date__c
                                               AND ASI_CRM_End_Date__c <= :TillEnd];
            AllOutlet = null;
            //sb Id
            set<id> sbIdset = new set<id>();
            for (ASI_CRM_Subbrand_Volume__c tempsb : SBList){
                sbIdset.add(tempsb.ASI_CRM_Subbrand__c);
            }
            
            //Actual CM & GS
            map<string, decimal> latest_actualcm = new map<string, decimal>();
            map<string, decimal> actualcm_map = new map<string, decimal>();
            map<string, decimal> latest_actualgs = new map<string, decimal>();
            map<string, decimal> actualgs_map = new map<string, decimal>();
            map<string, decimal> Last_cm = new map<string, decimal>();
            map<string, decimal> Last_gs = new map<string, decimal>();
            date strStartDate = objContract.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            string strkey;
            string strYearkey;
            decimal strvalue;
            date datestring;
            for (ASI_CRM_CM_GS__c tempCM : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,
                                   ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,
                                   ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                   FROM ASI_CRM_CM_GS__c
                                   WHERE ASI_CRM_PRODUCTCODE__c IN :sbIdset
                                   AND ASI_CRM_Region__c = :objContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                   AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
                                   AND ASI_CRM_CN_Month_End_Date__c >= :strStartDate                                   
                                   AND ASI_CRM_CN_Month_End_Date__c <= :TillEnd
                                   ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ]){

                datestring = FYConversion(tempCM.ASI_CRM_CN_Month_End_Date__c);
                strYearkey = string.valueof(datestring.Year()) + tempCM.ASI_CRM_PRODUCTCODE__c;
                strkey = string.valueof(datestring) + tempCM.ASI_CRM_PRODUCTCODE__c;
                
                strvalue = 0;
                if (tempCM.ASI_CRM_CM_GS_per_9L__c != null)
                    strvalue = tempCM.ASI_CRM_CM_GS_per_9L__c;
                    
                if (tempCM.ASI_CRM_Type__c == 'YTD CM'){
                    if (!latest_actualcm.containskey(strYearkey))
                        latest_actualcm.put(strYearkey, strvalue);
                    if (!actualcm_map.containskey(strkey))
                        actualcm_map.put(strkey, strvalue);
                    if (!Last_cm.containskey(tempCM.ASI_CRM_PRODUCTCODE__c))
                        Last_cm.put(tempCM.ASI_CRM_PRODUCTCODE__c, strvalue);
                }else if (tempCM.ASI_CRM_Type__c == 'YTD GS'){
                    if (!latest_actualgs.containskey(strYearkey))
                        latest_actualgs.put(strYearkey, strvalue);
                    if (!actualgs_map.containskey(strkey))
                        actualgs_map.put(strkey, strvalue);
                    if (!Last_gs.containskey(tempCM.ASI_CRM_PRODUCTCODE__c))
                        Last_gs.put(tempCM.ASI_CRM_PRODUCTCODE__c, strvalue);
                }
            }//End of Actual_CM Data Loop
            strStartDate = null;
            strkey = null;
            strYearkey = null;
            sbIdset = null;
            strValue = null;
            datestring = null;
            
            //Sub-brand Volume Looping
            decimal strVolume = 0;
            decimal strBtl = 0;
            decimal strCM = 0;
            decimal strGS = 0;
            decimal strPeriod = 0;
            string sbGradeName;
            string SBGradeGroup;
            string sbGradeSequence;
            for (ASI_CRM_Subbrand_Volume__c tempsb : SBList){
                datestring = FYConversion(tempsb.ASI_CRM_End_Date__c);
                strYearkey = string.valueof(datestring.Year()) + tempsb.ASI_CRM_Subbrand__c;
                strkey = string.valueof(datestring) + tempsb.ASI_CRM_Subbrand__c;
                
                //get Sub-brand Grade Name
                sbGradeName = '';
                if (tempsb.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null)
                    sbGradeName = tempsb.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                else
                    sbGradeName = 'Not Specified';
                
                //get Sub-brand Grade Name Sequence
                sbGradeSequence = '';
                if (tempsb.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c != null)
                    sbGradeSequence = SBGradeSorting(tempsb.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGradeName;
                else
                    sbGradeSequence = SBGradeSorting(null);
                    
                //get Sub-brand Grade Grouping
                SBGradeGroup = '';
                if (SubbrandGroup.containskey(sbGradeName)){
                    SBGradeGroup = SubbrandGroup.get(sbGradeName);
                }
                
                //Total Volume in Bottle (AddTotalBtl)
                strBtl = 0;
                if (tempsb.ASI_CRM_T1_Depletion_BTL__c != null){
                    returnSummary.AddTotalBtl(tempsb.ASI_CRM_T1_Depletion_BTL__c);
                    strBtl += tempsb.ASI_CRM_T1_Depletion_BTL__c;
                }
                if (tempsb.ASI_CRM_T2_Depletion_BTL__c != null){
                    returnSummary.AddTotalBtl(tempsb.ASI_CRM_T2_Depletion_BTL__c);
                    strBtl += tempsb.ASI_CRM_T2_Depletion_BTL__c;
                }
                if (tempsb.ASI_CRM_PR_Direct_BTL__c != null){
                    returnSummary.AddTotalBtl(tempsb.ASI_CRM_PR_Direct_BTL__c);
                    strBtl += tempsb.ASI_CRM_PR_Direct_BTL__c;
                }
                //Total Standard Billing Btl 
                if (tempsb.ASI_CRM_T1_Depletion_STD__c != null){
                    returnSummary.AddTotalBtl(tempsb.ASI_CRM_T1_Depletion_STD__c);
                }
                if (tempsb.ASI_CRM_T2_Depletion_STD__c != null){
                    returnSummary.AddTotalBtl(tempsb.ASI_CRM_T2_Depletion_STD__c);
                }
                if (tempsb.ASI_CRM_PR_Direct_STD__c != null){
                    returnSummary.AddTotalBtl(tempsb.ASI_CRM_PR_Direct_STD__c);
                }
                
                //Total CR12 for Investment CR12 per Btl (AddTotalInvestCR12)
                if (tempsb.ASI_CRM_T1_Depletion_CR12__c != null)
                    returnSummary.AddTotalInvestCR12(tempsb.ASI_CRM_T1_Depletion_CR12__c);
                if (tempsb.ASI_CRM_T2_Depletion_CR12__c != null)
                    returnSummary.AddTotalInvestCR12(tempsb.ASI_CRM_T2_Depletion_CR12__c);
                if (tempsb.ASI_CRM_PR_Direct_CR12__c != null)
                    returnSummary.AddTotalInvestCR12(tempsb.ASI_CRM_PR_Direct_CR12__c);
                    
                //Total Volume in 9L (AddTotalVolume)
                strVolume = 0;
                if (tempsb.ASI_CRM_T1_Depletion__c != null){
                    returnSummary.AddTotalVolume(tempsb.ASI_CRM_T1_Depletion__c);
                    strVolume += tempsb.ASI_CRM_T1_Depletion__c;
                }
                if (tempsb.ASI_CRM_T2_Depletion__c != null){
                    returnSummary.AddTotalVolume(tempsb.ASI_CRM_T2_Depletion__c);
                    strVolume += tempsb.ASI_CRM_T2_Depletion__c;
                }
                if (tempsb.ASI_CRM_PR_Direct__c != null){
                    returnSummary.AddTotalVolume(tempsb.ASI_CRM_PR_Direct__c);
                    strVolume += tempsb.ASI_CRM_PR_Direct__c;
                }
                
                    
                //get ActualCM
                strCM = 0;
                if (actualcm_map.containskey(strkey))
                    strCM = actualcm_map.get(strkey);
                /*else if (latest_actualcm.containskey(strYearkey))
                    strCM = latest_actualcm.get(strYearkey);*/
                else if (last_cm.containskey(tempsb.ASI_CRM_Subbrand__c))
                    strCM = last_cm.get(tempsb.ASI_CRM_Subbrand__c);
                //get Actual GS
                strGS = 0;
                if (actualgs_map.containskey(strkey))
                    strGS = actualgs_map.get(strkey);
                /*else if (latest_actualgs.containskey(strYearkey))
                    strGS = latest_actualgs.get(strYearkey);*/
                else if (last_gs.containskey(tempsb.ASI_CRM_Subbrand__c))
                    strGS = last_gs.get(tempsb.ASI_CRM_Subbrand__c);
                    
                //Total Volume * CM (AddTotalCMVol)
                if (strVolume != null && strCM != null)
                    returnSummary.AddTotalCMVol(strVolume * strCM);
                //system.debug('CM * Volume: ' + tempsb.ASI_CRM_Subbrand__r.Name + ' - ' + strkey + ' ' + strVolume + ' * ' + strCM);
                //Total Volume * GS (AddTotalGSVol)
                if (strVolume != null && strGS != null)
                    returnSummary.AddTotalGSVol(strVolume * strGS);
                
                //Place in Variable Expenese Table (VE_Table_map)
                if (VE_Table_map.containskey(sbGradeSequence)){
                    if (VE_Table_map.get(sbGradeSequence).containskey(tempsb.ASI_CRM_Subbrand__c)){
                        VariableExpensesTable newVEitem = VE_Table_map.get(sbGradeSequence).get(tempsb.ASI_CRM_Subbrand__c);
                        newVEitem.HC_Qty += strBtl;
                        newVEitem.HC_Volume += strVolume;
                        newVEitem.getSum();
                        VE_Table_map.get(sbGradeSequence).put(tempsb.ASI_CRM_Subbrand__c, newVEitem);
                        VETable_SB_List.add(newVEitem);
                    }else{
                        VariableExpensesTable newVEitem = new VariableExpensesTable(sbGradeName, tempsb.ASI_CRM_Subbrand__r.Name, tempsb.ASI_CRM_Subbrand__c, tempsb.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, strBtl, strVolume);
                        newVEitem.getSum();
                        VE_Table_map.get(sbGradeSequence).put(tempsb.ASI_CRM_Subbrand__r.Name, newVEitem);
                        VETable_SB_List.add(newVEitem);
                    }
                }else{
                    map<string, VariableExpensesTable> newMap = new map<string, VariableExpensesTable>();
                    VariableExpensesTable newVEitem = new VariableExpensesTable(sbGradeName, tempsb.ASI_CRM_Subbrand__r.Name, tempsb.ASI_CRM_Subbrand__c, tempsb.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, strBtl, strVolume);
                    newVEitem.getSum();
                    newMap.put(tempsb.ASI_CRM_Subbrand__r.Name, newVEitem);
                    VE_Table_map.put(sbGradeSequence, newMap);
                    VETable_SB_List.add(newVEitem);
                }
                //Place in P&L Review List
                if (Review_Map.containskey(sbGradeGroup)){
                    VariableExpensesTable newVEitem = Review_Map.get(sbGradeGroup);
                    if (returnSummary.strCutOffPeriod != 0 && returnSummary.strCutOffPeriod != null && returnSummary.strDiff != null)
                        newVEitem.HC_Volume += strVolume / returnSummary.strCutOffPeriod * returnSummary.strDiff;
                    else
                        newVEitem.HC_Volume += strVolume;
                    Review_Map.put(sbGradeGroup, newVEitem);
                }else{
                    VariableExpensesTable newVEitem = new VariableExpensesTable();
                    if (returnSummary.strCutOffPeriod != 0 && returnSummary.strCutOffPeriod != null && returnSummary.strDiff != null)
                        newVEitem.HC_Volume = strVolume / returnSummary.strCutOffPeriod * returnSummary.strDiff;
                    else
                        newVEitem.HC_Volume = strVolume;
                    Review_Map.put(sbGradeGroup, newVEitem);
                }
            }//End of Subbrand Volume Data Loop
            strVolume = null;
            strBtl = null;
            strCM = null;
            strGS = null;
            strPeriod = null;
            sbGradeName = null;
            SBGradeGroup = null;
            sbGradeSequence = null;
            datestring = null;
            
            //Prorate volume by Subbrand
            for (VariableExpensesTable tempmap : VETable_SB_List){
                strYearkey = string.valueof(FYConversion(TillEnd).Year()) + tempmap.strSBId;
                                
                //get Latest Actual CM
                if (last_cm.containskey(tempmap.strSbid))
                    strCM  = last_cm.get(tempmap.strSbid);
                /*if (latest_actualcm.containskey(strYearkey))
                    strCM = latest_actualcm.get(strYearkey);*/
                else strCM = 0;
                //get Latest Actual GS
                if (last_gs.containskey(tempmap.strSbid))
                    strGS  = last_cm.get(tempmap.strSbid);
                /*if (latest_actualgs.containskey(strYearkey))
                    strGS = latest_actualgs.get(strYearkey);*/
                else strGS = 0;
                
                //Prorate volume with CM & GS
                if (tempmap.HC_Volume != null && tempmap.HC_Volume != 0 && strCM != null && returnSummary.strDiff != null && returnSummary.strCutOffPeriod != 0 && returnSummary.strCutOffPeriod != null)
                    returnSummary.AddTotalCMVol(tempmap.HC_Volume / returnSummary.strCutOffPeriod  * strCM * returnSummary.strDiff);
                if (tempmap.HC_Volume != null && strGS != null && returnSummary.strDiff != null)
                    returnSummary.AddTotalGSVol(tempmap.HC_Volume / returnSummary.strCutOffPeriod  * strGS * returnSummary.strDiff);
                
            }//End of Subbrand table Loop
            
            returnSummary.getSum();
        }
        //Summary
        map<string, map<string, map<string, VariableExpensesTable>>> returnMap = new map<string, map<string, map<string, VariableExpensesTable>>>();
        map<string, map<string, VariableExpensesTable>> returnMap1 = new map<string, map<string, VariableExpensesTable>>();
        map<string, VariableExpensesTable> returnMap1_inner = new map<string, VariableExpensesTable>();
        VariableExpensesTable lastItem = new VariableExpensesTable(returnSummary);
        returnMap1_inner.put('Historical', lastItem);
        returnMap1.put('Summary', returnMap1_inner);
        
        //Review
        map<string, map<string, VariableExpensesTable>> returnMap2 = new map<string, map<string, VariableExpensesTable>>();
        returnMap2.put('Review' , Review_Map);
        
        returnMap.put('Summary', returnMap1);
        returnMap.put('Review', returnMap2);
        returnMap.put('Variable Expenses', VE_Table_map);
        
        return returnMap;
    }
    public static map<string, map<string, map<string, VariableExpensesTable>>> getContractBRSFbyContract(ASI_TH_CRM_Contract__c objContract){
        
        ContractSummary NewContractSummary = new ContractSummary();
        ContractSummary NewEstimateSummary = new ContractSummary();
        map<string, map<string, VariableExpensesTable>> VE_Table_map = new map<string, map<string, VariableExpensesTable>>();
        map<string, VariableExpensesTable> Review_Map = new map<string, VariableExpensesTable>();
        
        if (objContract != null){
            date TillEnd = CutOffDate(strCutOffDay, objContract.ASI_CRM_CN_PO_End_Date__c);
            NewEstimateSummary.strContractPeriod = objContract.ASI_CRM_CN_No_of_Months__c;
            NewEstimateSummary.strCutOffPeriod = MonthDiff(objContract.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            
            NewContractSummary.strContractPeriod = objContract.ASI_CRM_CN_No_of_Months__c;
            NewContractSummary.strCutOffPeriod = MonthDiff(objContract.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            
            NewEstimateSummary.totalExpense = objContract.ASI_CRM_CN_Total_Contract_Amount__c;
            NewEstimateSummary.fixExpense = objContract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c;
            NewEstimateSummary.varExpense = objContract.ASI_CRM_CN_Contract_Variable_Cost_Total__c;
            
            if(objContract.ASI_CRM_CN_BRSF_Contract_Total__c != null && objContract.ASI_CRM_CN_No_of_Months__c != null)
                NewEstimateSummary.varExpense += objContract.ASI_CRM_CN_BRSF_Contract_Total__c * objContract.ASI_CRM_CN_No_of_Months__c;
            
            //get BRSF Line Items Sub-brands
            set<id> sbIdset = new set<id>();
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf: objContract.Contract_BRSF_Line_Item__r){
                sbIdset.add(brsf.ASI_CRM_CN_Sub_Brand__c);
            }
            
            map<string, MarginTable> NewContract_MarginTable = checkFYDayPeriod_MarginTable(objContract.ASI_CRM_CN_PO_Start_Date__c, objContract.ASI_CRM_CN_PO_End_Date__c, sbIdset);
            
            //get Budge CM & GS
            date strStartDate = getEndDate(objContract.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
            date strEndDate = getEndDate(objContract.ASI_CRM_CN_PO_Start_Date__c.addYears(+1));
            date datestring;
            string strkey;
            decimal strvalue;
            for (ASI_CRM_CM_GS__c budget : [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,
                               ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                               FROM ASI_CRM_CM_GS__c
                               WHERE ASI_CRM_PRODUCTCODE__c IN :sbIdset
                               AND ASI_CRM_Region__c = :objContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                               //AND ASI_CRM_Sub_Channel__c = :objContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c
                               AND ASI_CRM_CN_Month_End_Date__c >= :strStartDate
                               AND ASI_CRM_CN_Month_End_Date__c <= :strEndDate 
                               AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                               ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ]){
                 
                datestring = FYConversion(budget.ASI_CRM_CN_Month_End_Date__c);
                strkey = string.valueof(datestring) + budget.ASI_CRM_PRODUCTCODE__c;
                
                strvalue = 0;
                if (budget.ASI_CRM_CM_GS_per_9L__c != null)
                    strvalue = budget.ASI_CRM_CM_GS_per_9L__c;
                
                if (NewContract_MarginTable.containskey(strkey)){
                    MarginTable newitem = NewContract_MarginTable.get(strkey);
                    newitem.sbName = budget.ASI_CRM_PRODUCTCODE__r.Name;
                    if (budget.ASI_CRM_Type__c == 'Budget CM')
                        newitem.strCM = strvalue;
                    else if (budget.ASI_CRM_Type__c == 'Budget GS')
                        newitem.strGS = strvalue;
                    NewContract_MarginTable.put(strkey, newitem);
                }
            }//End of Budget CM Data Loop
            strStartDate = null;
            strkey = null;
            sbIdset = null;
            strValue = null;
            datestring = null;
            
            //Loop BRSF Line Items data
            map<string, decimal> NewContract_BRSF_SB_Map = new map<string, decimal>();
            map<string, decimal> NewEstimate_BRSF_SB_Map = new map<string, decimal>();
            decimal strEstBtl = 0;
            decimal strEstVol = 0;
            decimal strEstInc = 0;
            decimal strEstCR12 = 0;
            decimal strContractBtl = 0;
            decimal strContractVol = 0;
            decimal strContractInc = 0;
            decimal strContractCR12 = 0;
            string sbGradeName;
            string sbGradeGroup;
            string sbGradeSequence;
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf: objContract.Contract_BRSF_Line_Item__r){
            
                //get Sub-brand Grade Name
                sbGradeName = '';
                if (brsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null)
                    sbGradeName = brsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                else
                    sbGradeName = 'Not Specified';
                    
                //get Sub-brand Grade Name Sequence
                sbGradeSequence = '';
                if (brsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c != null)
                    sbGradeSequence = SBGradeSorting(brsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGradeName;
                else
                    sbGradeSequence = SBGradeSorting(null);
                     
                //get Sub-brand Grade Grouping
                sbGradeGroup = '';
                if (SubbrandGroup.containskey(sbGradeName)){
                    SBGradeGroup = SubbrandGroup.get(sbGradeName);
                }
                
                //Estimate Volume in 9L
                if (brsf.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null)
                    strEstVol = brsf.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                else strEstVol = 0;
                //Estimate Qty
                if (brsf.ASI_CRM_CN_Est_Monthly_Qty__c != null)
                    strEstBtl = brsf.ASI_CRM_CN_Est_Monthly_Qty__c;
                else strEstBtl = 0;
                //Estimate Bottle Incentive
                if (brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null)
                    strEstInc = brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                else strEstInc = 0;
                
                //Contract Volume in 9L
                if (brsf.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null)
                    strContractVol = brsf.ASI_CRM_CN_Contract_Monthly_Vol9L__c;
                else strContractVol = 0;
                //Contract Qty
                if (brsf.ASI_CRM_CN_Contract_Monthly_Qty__c != null)
                    strContractBtl = brsf.ASI_CRM_CN_Contract_Monthly_Qty__c;
                else strContractBtl = 0;
                //Contract Bottle Incentive
                if (brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!= null)
                    strContractInc = brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                else strContractInc = 0;
                
                //Estimate & Contract Qty in CR12
                if (brsf.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c != null){
                    strContractCR12 = brsf.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c * strContractVol;
                    strEstCR12 = brsf.ASI_CRM_CN_Sub_Brand_Conversion_Factor__c * strEstVol;
                }else{
                    strContractCR12 = strContractVol;
                    strEstCR12 = strEstVol;
                }
                //Estimate Summary
                NewEstimateSummary.AddTotalVolume(strEstVol * objContract.ASI_CRM_CN_No_of_Months__c);
                NewEstimateSummary.AddTotalInvestCR12(strEstCR12 * objContract.ASI_CRM_CN_No_of_Months__c);
                
                //Contract Summary
                NewContractSummary.AddvarExpense(strContractBtl * strContractInc * objContract.ASI_CRM_CN_No_of_Months__c);
                NewContractSummary.AddTotalVolume(strContractVol * objContract.ASI_CRM_CN_No_of_Months__c);
                NewContractSummary.AddTotalInvestCR12(strContractCR12 * objContract.ASI_CRM_CN_No_of_Months__c);
                
                //Place in Variable Expenese Table (VE_Table_map) with sbGradeSequence
                if (VE_Table_map.containskey(sbGradeSequence)){
                    if (VE_Table_map.get(sbGradeSequence).containskey(brsf.ASI_CRM_CN_Sub_Brand__c)){
                        VariableExpensesTable newVEitem = VE_Table_map.get(sbGradeSequence).get(brsf.ASI_CRM_CN_Sub_Brand__c);
                        newVEitem.Estimate_Qty += strEstBtl;
                        newVEitem.Estimate_BtlInc += strEstInc;
                        newVEitem.Estimate_Volume += strEstVol;
                        newVEitem.Contract_Qty += strContractBtl;
                        newVEitem.Contract_BtlInc += strContractInc;
                        newVEitem.Contract_Volume += strContractVol;
                        VE_Table_map.get(sbGradeSequence).put(brsf.ASI_CRM_CN_Sub_Brand__c, newVEitem);
                    }else{
                        VariableExpensesTable newVEitem = new VariableExpensesTable(sbGradeName, brsf.ASI_CRM_CN_Sub_Brand__r.Name, brsf.ASI_CRM_CN_Sub_Brand__c, brsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, strEstBtl, strEstVol, strEstInc, strContractBtl, strContractVol, strContractInc);
                        VE_Table_map.get(sbGradeSequence).put(brsf.ASI_CRM_CN_Sub_Brand__r.Name, newVEitem);
                    }
                }else{
                    map<string, VariableExpensesTable> newMap = new map<string, VariableExpensesTable>();
                    VariableExpensesTable newVEitem = new VariableExpensesTable(sbGradeName, brsf.ASI_CRM_CN_Sub_Brand__r.Name, brsf.ASI_CRM_CN_Sub_Brand__c, brsf.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, strEstBtl, strEstVol, strEstInc, strContractBtl, strContractVol, strContractInc);
                    newMap.put(brsf.ASI_CRM_CN_Sub_Brand__r.Name, newVEitem);
                    VE_Table_map.put(sbGradeSequence, newMap);
                }
                
                //Place in P&L Review List
                if (Review_Map.containskey(sbGradeGroup)){
                    VariableExpensesTable newVEitem = Review_Map.get(sbGradeGroup);
                    newVEitem.Estimate_Volume += strEstVol * objContract.ASI_CRM_CN_No_of_Months__c;
                    newVEitem.Contract_Volume += strContractVol * objContract.ASI_CRM_CN_No_of_Months__c;
                    Review_Map.put(sbGradeGroup, newVEitem);
                }else{
                    VariableExpensesTable newVEitem = new VariableExpensesTable();
                    newVEitem.Estimate_Volume += strEstVol * objContract.ASI_CRM_CN_No_of_Months__c;
                    newVEitem.Contract_Volume += strContractVol * objContract.ASI_CRM_CN_No_of_Months__c;
                    Review_Map.put(sbGradeGroup, newVEitem);
                }
                
                //get Estimate Total Volume by Subbrand (for Budget CM & GS Calculation) 
                if (NewEstimate_BRSF_SB_Map.containskey(brsf.ASI_CRM_CN_Sub_Brand__c)){
                    strValue = NewEstimate_BRSF_SB_Map.get(brsf.ASI_CRM_CN_Sub_Brand__c);
                    strValue += strEstVol;
                    NewEstimate_BRSF_SB_Map.put(brsf.ASI_CRM_CN_Sub_Brand__c, strValue);
                }else{
                    NewEstimate_BRSF_SB_Map.put(brsf.ASI_CRM_CN_Sub_Brand__c, strEstVol);
                }
                
                //get Contract Total Volume by Subbrand (for Budget CM & GS Calculation)
                if (NewContract_BRSF_SB_Map.containskey(brsf.ASI_CRM_CN_Sub_Brand__c)){
                    strValue = NewContract_BRSF_SB_Map.get(brsf.ASI_CRM_CN_Sub_Brand__c);
                    strValue += strContractVol;
                    NewContract_BRSF_SB_Map.put(brsf.ASI_CRM_CN_Sub_Brand__c, strValue);
                }else{
                    NewContract_BRSF_SB_Map.put(brsf.ASI_CRM_CN_Sub_Brand__c, strContractVol);
                }
                    
            }//End of BRSF items Loop
            strValue = null;
            strEstBtl = null;
            strEstVol = null;
            strEstInc = null;
            strEstCR12 = null;
            strContractBtl = null;
            strContractVol = null;
            strContractInc = null;
            strContractCR12 = null;
            sbGradeName = null;
            sbGradeGroup = null;
            sbGradeSequence = null;
            
            //Budget CM & GS Calculation for Estimate & Contract
            decimal strEVol;
            decimal strCVol;
            for (MarginTable mt : NewContract_MarginTable.values()){
                if (NewEstimate_BRSF_SB_Map.containskey(mt.sbid))
                    strEVol = NewEstimate_BRSF_SB_Map.get(mt.sbid);
                else
                    strEVol = 0;
                //Add Estimate Total CM & GS
                if (mt.strCM != null && mt.strVolume != null)
                    NewEstimateSummary.AddTotalCMVol(mt.strCM * strEVol);
                if (mt.strGS != null && mt.strVolume != null)
                    NewEstimateSummary.AddTotalGSVol(mt.strGS * strEVol);
                
                if (NewContract_BRSF_SB_Map.containskey(mt.sbid))
                    strCVol = NewEstimate_BRSF_SB_Map.get(mt.sbid);
                else
                    strCVol = 0;
                //Add Contract Total CM & GS
                if (mt.strCM != null && mt.strVolume != null)
                    NewContractSummary.AddTotalCMVol(mt.strCM * strCVol);
                if (mt.strGS != null && mt.strVolume != null)
                    NewContractSummary.AddTotalGSVol(mt.strGS * strCVol);
            }//End of Budget CM & GS Calculation
            strEVol = null;
            strCVol = null;
            
            //get Contract Cost  
            for (ASI_CRM_Contract_Cost__c cost: objContract.Contract_Costs__r){
                if (cost.ASI_CRM_CN_Cost_Type__c == 'Variable' && cost.ASI_CRM_CN_Contract_Amount__c != null)
                    NewContractSummary.AddvarExpense(cost.ASI_CRM_CN_Contract_Amount__c);
                else if (cost.ASI_CRM_CN_Cost_Type__c == 'Fixed' && cost.ASI_CRM_CN_Contract_Amount__c != null)
                    NewContractSummary.AddfixExpense(cost.ASI_CRM_CN_Contract_Amount__c);
            }//End of Contract Cost
            NewEstimateSummary.getNewSum();
            NewContractSummary.getNewSum();
        }
        
        
        //Contract Summary
        VariableExpensesTable Contract_Summary = new VariableExpensesTable(NewContractSummary);
        map<string, VariableExpensesTable> contractmap = new map<string, VariableExpensesTable>();
        contractmap.put('Contract', Contract_Summary);
        
        //Estimate Summary
        VariableExpensesTable Estimate_Summary = new VariableExpensesTable(NewEstimateSummary);
        
        //Review Summary
        map<string, map<string, VariableExpensesTable>> ReviewMap = new map<string, map<string, VariableExpensesTable>>();
        ReviewMap.put('Review', Review_Map);
        
        map<string, map<string, VariableExpensesTable>> Summarymap = new map<string, map<string, VariableExpensesTable>>();
        Summarymap.put('Summary', contractmap);
        Summarymap.get('Summary').put('Estimate', Estimate_Summary);
        
        map<string, map<string, map<string, VariableExpensesTable>>> returnMap = new map<string, map<string, map<string, VariableExpensesTable>>>();
        returnMap.put('Summary', Summarymap);
        returnMap.put('Variable Expenses' , VE_Table_map);
        returnMap.put('Review' , ReviewMap);
        return returnMap;
    }
    
    public static date CutOffDate(integer strDay, date DefaultDate){
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
            if (returnDate > DefaultDate){
                returnDate = DefaultDate;
            }
        }else{
            returnDate = DefaultDate;
        }
        return returnDate;
    }
    public static date FYConversion(date strDate){
        date returndate;
        integer EndFY;
        if (strDate != null){
            if (strDate.Month() > 6 && strDate.Month() < 13){
                EndFY = strDate.Year() + 1;
            }
            else if (strDate.Month() < 7 && strDate.Month() > 0){
                EndFY = strDate.Year();
            }
            return date.newinstance(EndFY,6,30);
        }else{
            return null;
        }
    }
    public static map<string, decimal> checkFYDayPeriod(date startDate, date endDate, set<id> Idset){
        map<string, decimal> returnDateMap = new map<string, decimal>();
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
                    for (id tempset : Idset){
                        returnDateMap.put(string.valueof(returnDate) + tempset, decimal.valueof(strtemp));
                    }
                    tempDate = Date.newinstance(StartFY,7,1);
                    //system.debug('tempDate: ' + tempDate );
                    StartFY++;
                }
            }
            //system.debug('checkFYDayPeriod: ' + returnDateMap);
            return returnDateMap;
        }else{
            return null;
        }
    }
    public static map<string, MarginTable> checkFYDayPeriod_MarginTable(date startDate, date endDate, set<id> Idset){
        map<string, MarginTable> returnDateMap = new map<string, MarginTable>();
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
                    for (id tempset : Idset){
                        MarginTable newitem = new MarginTable();
                        newitem.strDate = returnDate;
                        newitem.sbId = tempset;
                        newitem.strPeriod = decimal.valueof(strtemp);
                        returnDateMap.put(string.valueof(returnDate) + tempset, newitem);
                    }
                    tempDate = Date.newinstance(StartFY,7,1);
                    //system.debug('tempDate: ' + tempDate );
                    StartFY++;
                }
            }
            //system.debug('checkFYDayPeriod: ' + returnDateMap);
            return returnDateMap;
        }else{
            return null;
        }
    }
    public static integer MonthDiff(date startDate, date endDate){
        Integer monthDiff;
        if (startDate != null && endDate != null){
            monthDiff = ((endDate.YEAR() - startDate.YEAR() - 1) *12) + (12 - startDate.MONTH() +1) + endDate.MONTH();
            //system.debug('monthDiff: ' + monthDiff);
            return monthDiff;
        }else{
            return null;
        }
    }
    public static date getEndDate(date strDate){
        Integer numberOfDays = Date.daysInMonth(strDate.year(), strDate.month());
        Date lastDayOfMonth = Date.newInstance(strDate.year(), strDate.month(), numberOfDays);
        return lastDayofMonth;
    }
    public static string SBGradeSorting(decimal strSeq){
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
        //system.debug('SBGradeSorting: ' + returnString);
        return returnString;
    }
    static{
        SubbrandGroup.put('Premium', '1. Standard + Premium');
        SubbrandGroup.put('Standard', '1. Standard + Premium');
        SubbrandGroup.put('Prestige', '4. Prestige + Ultra Prestige');
        SubbrandGroup.put('Ultra Prestige', '4. Prestige + Ultra Prestige');
        SubbrandGroup.put('Super Premium', '2. Super Premium');
        SubbrandGroup.put('Ultra Premium', '3. Ultra Premium');
        SubbrandGroup.put('Not Specified','0. Not Specified');
    }
    //pdf中换行方法
    public static String addWrap(String str, Decimal length, Boolean isTrim)
    {
        
        String tmpStr = '';
        //32不知道是什么
        if (str == null)
        {
            return null;
        }
        if (isTrim) {
            for (Integer i=0; i<str.length();i++)
            {
                String sub = str.substring(i, i + 1);
                if (str.charAt(i) == 32)
                {
                    str.replace(sub, '');
                    break;
                }
            }
        }

        List<String> proDecList = new List<String>();
        List<String> tempProDecList = str.split('\r\n');
        for (String proDec : tempProDecList) {
          proDecList.addAll(proDec.split('<br/>'));
        }
        //System.debug('proDecList::::' + proDecList.size());
        //System.debug('proDecList::::' + proDecList);
        Pattern p1 = Pattern.compile('[A-Za-z]');
        Pattern p = Pattern.compile(reservedPattern);
        Matcher m;
        Matcher mLeft;
        Matcher mRight;
        Matcher mReservedLeft;

        for(String proDec : proDecList)
        {
            System.debug('proDec:::::' + proDec);
            String s = proDec;
            String t = '';
            Decimal z = length;
            Decimal leng = 0;
            String tmp = '';
            //System.debug(LoggingLevel.INFO, '*** proDec: ' + proDec);
            Integer j = 0;
            Integer k = 0;
            //System.debug('proDec:::::::' + proDec);
            for (Integer i = 0; i < s.length();i++)
            {
              
              System.debug('s.charAt(i):::' + s.charAt(i));
              System.debug('s.substring(i, i + 1)::::' + s.substring(i, i + 1));
              String sub = s.substring(i, i + 1);
              Decimal a = leng;
              //19968 - 171941中文   60-90大写字母   109 m    64 @   12289 、37% 12290。
              if ((s.charAt(i) >= 19968 && s.charAt(i) <= 171941)
                 || (s.charAt(i) == 64) || (s.charAt(i) == 12289) || (s.charAt(i) == 12290) || (s.charAt(i) == 37) || (s.charAt(i) == 12298) || (s.charAt(i) == 12299))
              {
                  leng = leng + 2;
              }
              else if (s.charAt(i) == 109)
              {
                  leng = leng + 1.5;
              }
              // 8221 8220 “”
              else if (s.charAt(i) == 8221 || s.charAt(i) == 8220)
              {
                  leng = leng + 0.6;
              }
              // 73I
              else if (s.charAt(i) == 73)
              {
                  leng = leng + 0.6;
              }
              else if ((s.charAt(i) >= 60 && s.charAt(i) <= 90 ) )
              {
                  leng = leng + 1.6;
              }
              // 49 1    105 i   106 j  108 l  116 t 
              else if ((s.charAt(i) == 49) || (s.charAt(i) == 105) || (s.charAt(i) == 106) || (s.charAt(i) == 108)  || (s.charAt(i) == 116))
              {
                  leng = leng + 0.6;
              }
              // 46 .   58 :
              else if ((s.charAt(i) == 46) || (s.charAt(i) == 58))
              {
                   leng = leng + 0.4;
              }
              // 48 - 57 0-9
              else if (s.charAt(i) >= 48 && s.charAt(i) <= 57)
              {
                   leng = leng + 1.3;
              }
              else if (s.charAt(i) == 32 )
              {
                  if (!isTrim) {
                      leng = leng + 0.6;
                  }
                    //s.replace(sub, '')
              }
              else if (s.charAt(i) == 95)
              {
                    leng = leng + 1;
              }
              else
              {
                  leng = leng + 1.1;
              }
              Decimal b = leng;
              System.debug('leng:::::' + (b - a));
              System.debug('leng::::::' + leng);
              
              j++;

            if ((leng >= z) || (leng + 1 >= z))
            {
                System.debug('clear::::');
  
                Integer ioffset = 0;
                do {
                    // 分隔左右都是英文时，往左移以形成整个单词。
                    String splitLeft = s.subString(0, i + 1 -ioffset ).right(1);
                    String splitRight = s.subString(i + 1 -ioffset).left(1);
                    System.debug(LoggingLevel.INFO, '*** splitLeft: ' + splitLeft);
                    System.debug(LoggingLevel.INFO, '*** splitRight: ' + splitRight);
                    mLeft = p1.matcher(splitLeft);
                    mRight = p1.matcher(splitRight);
                    mReservedLeft = p.matcher(splitLeft);
                    System.debug(LoggingLevel.INFO, '*** mLeft.matches(): ' + mLeft.matches());
                    System.debug(LoggingLevel.INFO, '*** mRight.matches(): ' + mRight.matches());
                    if (mLeft.matches() && mRight.matches()) {
                        System.debug(LoggingLevel.INFO, '*** 进入: ' + ioffset);
                        ioffset ++;
                    }
                    System.debug(LoggingLevel.INFO, '*** mReservedLeft.matches(): ' + mReservedLeft.matches());
                } while (mLeft.matches() && mRight.matches() && !mReservedLeft.matches());
                if (ioffset>0) {
                    System.debug(LoggingLevel.INFO, '*** s: ' + s);
                    System.debug(LoggingLevel.INFO, '*** ioffset: ' + ioffset);
                    System.debug(LoggingLevel.INFO, '*** k: ' + k);
                    System.debug(LoggingLevel.INFO, '*** j: ' + j);
                    tmp = tmp + s.mid(k - ioffset + 1,j - ioffset) + '\r\n' + s.mid(k + j - ioffset, ioffset);
                } else {
                    tmp = tmp + s.mid(k,j) + '\r\n';
                }
                k = i + 1;
                leng = 0;
                j = 0;
            }

              

              if (i == (s.length() - 1))
              {
                  tmp = tmp + s.mid(k,j);
              }
              
            }
            if (tmp.length() > 0)
            {
            //tmp = tmp.removeEnd('<br/>');
            tmpStr = tmpStr + '\n' +tmp;
            }
            else
            {
            tmpStr = tmpStr + '\n' +proDec;
            }
        }
        tmpStr = tmpStr.replace('<br/>', '\n');
        //tmpStr = tmpStr.replace('\r', '<br/>');
        tmpStr = tmpStr.removeStart('\n');
        return tmpStr;
    }
    /*public static String TableSplitLineRow(String InputString, integer CutNumber){
        String outputString ='';

        integer tempCutNumber = CutNumber;
        // if (!isEditable){
            List<String> inputLineList = InputString.split(lineBreak);
            System.debug('*** inputLineList: ' + JSON.serializePretty(inputLineList) + '');
            for (String inputLine:inputLineList){
                if (inputLine.length() < CutNumber){
                    outputString += inputLine + lineBreak;
                } else {
                    while(inputLine.length() >= CutNumber ){
                        //Add 1 for every 2 symbol/number/alphabet
                        //Add 2 for each '\n'
                        Integer offset = inputLine.subString(0,CutNumber).countMatches('/n') * 2 + (inputLine.subString(0, CutNumber).replaceAll('[\\w ,."*()\'=<>%0-9]','c').countMatches('c') / 2);

                        //To prevent out of bound, new cut number cannot exceed length of the line
                        tempCutNumber = Math.min(inputLine.length(), CutNumber + offset);
                        Pattern p1 = Pattern.compile('[A-Za-z]');
                        Pattern p = Pattern.compile(reservedPattern);
                        Matcher m;
                        Matcher mLeft;
                        Matcher mRight;
                        Matcher mReservedLeft;
                        do {
                            // 分隔左右都是英文时，往左移以形成整个单词。
                            String splitLeft = inputLine.subString(0,tempCutNumber).right(1);
                            String splitRight = inputLine.subString(tempCutNumber).left(1);
                            System.debug(LoggingLevel.INFO, '*** splitLeft: ' + splitLeft);
                            System.debug(LoggingLevel.INFO, '*** splitRight: ' + splitRight);
                            mLeft = p1.matcher(splitLeft);
                            mRight = p1.matcher(splitRight);
                            mReservedLeft = p.matcher(splitLeft);
                            System.debug(LoggingLevel.INFO, '*** mLeft.matches(): ' + mLeft.matches());
                            System.debug(LoggingLevel.INFO, '*** mRight.matches(): ' + mRight.matches());
                            if (mLeft.matches() && mRight.matches()) {
                                tempCutNumber = Math.min(inputLine.length(), tempCutNumber - 1);
                            }
                            System.debug(LoggingLevel.INFO, '*** mReservedLeft.matches(): ' + mReservedLeft.matches());
                        } while (mLeft.matches() && mRight.matches() && !mReservedLeft.matches());
                        outputString = outputString + inputLine.subString(0,tempCutNumber);
                        // do {
                        //     String splitRight = inputLine.subString(tempCutNumber).left(1);
                        //     m = p.matcher(splitRight);
                        //      if (m.matches()){
                        //         tempCutNumber = Math.min(inputLine.length(), tempCutNumber + 1);
                        //     }
                        // } while (m.matches());
                        // outputString = outputString + inputLine.subString(0,tempCutNumber);

                        //If next line contains less than 2 characters or the line contain line break, forfeit new line
                        if ((inputLine.subString(tempCutNumber).length() > 2 && !inputLine.subString(0,tempCutNumber).contains('<b'))){
                            outputString += lineBreak;
                        }
                        inputLine= inputLine.subString(tempCutNumber);
                    }
                    outputString += inputLine + lineBreak;
                }
            }
            //outputString = outputString + InputString;
        // }else{
        //     outputString=InputString;
        // }
        return outputString;
    }*/

    public static List<ASI_CRM_Approval_Comment__c> convertCommentLineBreak(List<ASI_CRM_Approval_Comment__c> comments) {
        for (ASI_CRM_Approval_Comment__c comment : comments) {
            comment.ASI_CRM_BA_comments__c = String.isBlank(comment.ASI_CRM_BA_comments__c)?'':addWrap(comment.ASI_CRM_BA_comments__c, IntChar, false);
            comment.ASI_CRM_Background_Objective__c = String.isBlank(comment.ASI_CRM_Background_Objective__c)?'':addWrap(comment.ASI_CRM_Background_Objective__c, IntChar, false);
            comment.ASI_CRM_New_contract_Analsysis__c = String.isBlank(comment.ASI_CRM_New_contract_Analsysis__c)?'':addWrap(comment.ASI_CRM_New_contract_Analsysis__c, IntChar, false);
            comment.ASI_CRM_Historical_Contract_Performance__c = String.isBlank(comment.ASI_CRM_Historical_Contract_Performance__c)?'':addWrap(comment.ASI_CRM_Historical_Contract_Performance__c, IntChar,false);
        }
        return comments;
    }
}