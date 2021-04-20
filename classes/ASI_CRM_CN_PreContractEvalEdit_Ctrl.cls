/* Filename:    ASI_CRM_CN_PreContractEvalEdit_Ctrl.cls
* Author:      Michael Yip (Introv Limited)
* Purpose: 
*
*
* History
* -----------------------------------------------------------------------------
* 2014-02-14   michael.yip@introv.com      Created
* 
*/

public with sharing class ASI_CRM_CN_PreContractEvalEdit_Ctrl {
    
    public ASI_CRM_PreContractEval__c PC {get; set;}
    public List<ASI_CRM_PreContractEval__c> LPreContract {get; set;}
    public string OutletId {get;set;}
    public string PageId {set;get;}
    public boolean showResult {get;set;}
    public Integer index {set;get;}
    public Integer rowid {set;get;}
    
    public List<ASI_CRM_AccountsAdditionalField__c> OutletInfoList {set;get;}
    public ASI_CRM_AccountsAdditionalField__c OutletInfo {set;get;}
    public List <ASI_CRM_Pre_Contract_Sub_Brand__c> BottleIncentive {set;get;}
    public map<integer, ASI_CRM_Pre_Contract_Sub_Brand__c> BottleIncentiveMap {set;get;}
    public List <ASI_CRM_Pre_Contract_Sub_Brand__c> DelItems {set;get;}
    
    public List <ASI_CRM_CN_Channel_Strategy__c> objCS {set;get;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSLI {set;get;}
    public Map <string, list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>> objCSLI_map {set;get;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSLI_mapList {set;get;}
    
    public Evaluation_Result EvalResultTable1 {set;get;}
    public Evaluation_Result EvalResultTable2 {set;get;}
    public Evaluation_Result EvalResultTable3 {set;get;}
    public list<Evaluation_Result > EvalResultTableList {set;get;}
    public Map<string, Evaluation_Result > EvalResultTable_map {set;get;}
    
    public List<ASI_TH_CRM_Contract__c> ListLastPO {set;get;}
    public string LastPO {set;get;}
    public ASI_TH_CRM_Contract__c LastContract {set;get;}
    //public ASI_CRM_CM_GS__c ActualCMGS {set;get;}
    //public list <ASI_CRM_CM_GS__c> ActualCMGSList {set;get;}
    
    public List<ASI_CRM_Contract_Cost__c> ListContractCost{set;get;}
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ListContractBRSF {set;get;}
    public List<ASI_CRM_Subbrand_Volume__c> ListSBVolume {set;get;}
    public List<ASI_CRM_Subbrand_Volume__c> ListSBVolumeFilter {set;get;}
    public Set<id> LC_BRSF_SubBrand {set;get;}
    public set<id> BottleIncentiveSB_id {set;get;}
    public set<string> sb_fiscalyear {set;get;}
    public decimal strFixedCostOld {set;get;}
    public decimal strVCostOld {set;get;}
    public decimal strNewVCost {set;get;}
    public decimal strNewFixedCost {set;get;}
    public decimal strOldVolume {set;get;}
    public decimal strNewVolume {set;get;}
    public decimal strOldExpenses {set;get;}
    public decimal strNewExpenses {set;get;}
    public decimal strExpensesRate {set;get;}
    public decimal strVcostRate {set;get;}
    public decimal strFcostRate {set;get;}
    public decimal strROIRate {set;get;}
    public decimal strVolumeRate {set;get;}
    public Date strDayBefore {set;get;}
    public decimal strCR12Rate {set;get;}
    
    public string strFEAlign {set;get;}
    public string strVEAlign {set;get;}
    public string strTEAlign {set;get;}
    public string strVOAlign {set;get;}    
    
    //Pre-Contract Alignment Setting
    public list<ASI_CRM_CN_PreContract_AlignSetting__c> Align_List {set;get;}
    public map<string, integer> Align_map {set;get;}
    public string Outlet_ONOFF {set;get;}
    public id strDivision {set;get;}
    
    public ASI_CRM_CN_PreContractEvalEdit_Ctrl(apexpages.standardController sc){
        PageId = ApexPages.currentPage().getParameters().get('id');
        OutletId = ApexPages.currentPage().getParameters().get('OutletId');
        DelItems = new List<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        index = 0;
        BottleIncentiveMap = new Map<Integer, ASI_CRM_Pre_Contract_Sub_Brand__c>();
        objCSLI_map = new map<string, list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>>();
        objCSLI_mapList = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        Align_map = new map<string, integer>();
        sb_fiscalyear = new set<string>();
        
        if (PageId == null){
            PC = new ASI_CRM_PreContractEval__c();
            PC.ASI_CRM_CN_Outlet__c = OutletId;
            List<ASI_CRM_Pre_Contract_Sub_Brand__c> BottleIncentive = new List<ASI_CRM_Pre_Contract_Sub_Brand__c>();
            //ASI_CRM_Pre_Contract_Sub_Brand__c a = new ASI_CRM_Pre_Contract_Sub_Brand__c();
            //BottleIncentiveMap.put(index++, a);
        }else{
            try{
                PC = [SELECT name, id, ASI_CRM_No_of_Months__c, ASI_CRM_Bottle_Incentive_Total__c, ASI_CRM_Variable_Event_Cost__c, ASI_CRM_Promotion_Service_Fee__c, 
                      ASI_CRM_CN_Budget_Version__c, ASI_CRM_Variable_Cost__c,  ASI_CRM_No_of_covered_outlet__c,
                      ASI_CRM_Fixed_Expense__c, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c, ASI_CRM_CN_Outlet__r.name, ASI_CRM_Status__c, ASI_CRM_Monthly_Contract_Total_Vol_9LC__c, 
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c,
                      ASI_CRM_Investment_per_Equiv_Chivas_12Y__c, CreatedDate
                      from ASI_CRM_PreContractEval__c WHERE id = :PageId];
                if (PC.ASI_CRM_CN_Outlet__c != null){
                    Outlet_ONOFF = PC.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c;
                    strDivision = PC.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c;
                }
                system.debug('Outlet_ONOFF : ' + Outlet_ONOFF + ' strDivision : ' + strDivision );
            }catch(QueryException e){
                
            }
            /*
BottleIncentive = [SELECT id, Name, ASI_CRM_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,ASI_CRM_Sub_Brand__c, ASI_CRM_Bottle_Incentive__c, ASI_CRM_Estimated_Btl_Month__c, 
ASI_CRM_Grade__c, ASI_CRM_Total_Amount__c FROM ASI_CRM_Pre_Contract_Sub_Brand__c WHERE ASI_CRM_Pre_Contract_Eval__c = :PageId];
*/
            getSubBrandLineItems();
            if (BottleIncentive.size() > 0){
                for (ASI_CRM_Pre_Contract_Sub_Brand__c a : BottleIncentive){
                    BottleIncentiveMap.put(index++, a);
                }
            }
            OutletId = PC.ASI_CRM_CN_Outlet__c;
            
            try{
                Align_List = [SELECT ASI_CRM_CN_Align__c, ASI_CRM_CN_Type__c FROM ASI_CRM_CN_PreContract_AlignSetting__c
                              WHERE ASI_CRM_CN_Division__c =:strDivision AND ASI_CRM_CN_On_Off__c = :Outlet_ONOFF ];
                if (Align_List.size()> 0){
                    for (ASI_CRM_CN_PreContract_AlignSetting__c pcas : Align_List){
                        Align_map.put(pcas.ASI_CRM_CN_Type__c, integer.valueof(pcas.ASI_CRM_CN_Align__c));
                    }
                    system.debug('Align_map : ' + Align_map);
                }
            }catch(QueryException e){
                Align_List = new list<ASI_CRM_CN_PreContract_AlignSetting__c>();
            }
        }
        if (OutletId != null){
            try{
                OutletInfo = [SELECT id, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.Name, ASI_CRM_CN_Sales_Rep__r.Name, ASI_CRM_CN_Sales_Rep__c, ASI_CRM_CN_CCity__r.Name, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.Name, ASI_CRM_CN_Image__c,
                              ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                              ASI_CRM_CN_Sub_Channel__r.Name FROM ASI_CRM_AccountsAdditionalField__c WHERE Id = :OutletId];
            }catch(QueryException e){
                OutletInfo = new ASI_CRM_AccountsAdditionalField__c();
            }
        }else{
            OutletInfo = new ASI_CRM_AccountsAdditionalField__c();
            //ActualCMGS = new ASI_CRM_CM_GS__c();
            //ActualCMGSList = new List<ASI_CRM_CM_GS__c>();
        }
        showPriority();
        showResult = false;
    }
    
    public void getSubBrandLineItems(){
        try{
            BottleIncentive = [SELECT id, Name, ASI_CRM_Sub_Brand__c, ASI_CRM_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_Bottle_Incentive__c, ASI_CRM_Estimated_Btl_Month__c, 
                               ASI_CRM_Grade__c, ASI_CRM_Total_Amount__c FROM ASI_CRM_Pre_Contract_Sub_Brand__c WHERE ASI_CRM_Pre_Contract_Eval__c = :PageId];
        }catch(QueryException e){
            BottleIncentive = new List<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        }
        
    }
    public void getSubBrandLineItemsMap(){
        BottleIncentiveSB_id = new set<id>();
        BottleIncentive = new list<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        system.debug('BottleIncentiveMap: ' + BottleIncentiveMap);
        if (BottleIncentiveMap.size() > 0){
            for (ASI_CRM_Pre_Contract_Sub_Brand__c a : BottleIncentiveMap.values()){
                BottleIncentive.add(a);
                BottleIncentiveSB_id.add(a.ASI_CRM_Sub_Brand__c);
            }
            system.debug('BottleIncentiveSB_id: ' + BottleIncentiveSB_id);
        }
        //BottleIncentive = [SELECT id, Name, ASI_CRM_Sub_Brand__c, ASI_CRM_Bottle_Incentive__c, ASI_CRM_Estimated_Btl_Month__c, 
        //        ASI_CRM_Grade__c, ASI_CRM_Total_Amount__c FROM ASI_CRM_Pre_Contract_Sub_Brand__c WHERE ASI_CRM_Pre_Contract_Eval__c = :PageId];
        
    }
    public List<ASI_CRM_CM_GS__c> getActualCMGS(Set<id> strSBSet){
        List<ASI_CRM_CM_GS__c> ActualCMGS = new List<ASI_CRM_CM_GS__c>();
        try{
            ActualCMGS = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_VERSION__c FROM ASI_CRM_CM_GS__c WHERE ASI_CRM_YEAR__c IN:sb_fiscalyear 
                          AND ASI_CRM_REGION__c =:OutletInfo.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                          AND ASI_CRM_PRODUCTCODE__c IN :strSBSet];
        }catch(Queryexception e){
            system.debug(e);
            ActualCMGS = new List <ASI_CRM_CM_GS__c>();
        }
        system.debug('ActualCMGS: ' + ActualCMGS );
        return ActualCMGS;
    }
    public List<ASI_CRM_CM_GS__c> getBudgetCMGS(set<id> strSBSet){
        string FYear = getChannelStrategy(Date.Today()).left(4);   //string.valueof(Date.Today().Year()).left(4);
        List<ASI_CRM_CM_GS__c> BudgetCMGS = new List<ASI_CRM_CM_GS__c>();
        try{
            BudgetCMGS = [SELECT id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_VERSION__c FROM ASI_CRM_CM_GS__c WHERE ASI_CRM_YEAR__c =:FYear
                          AND ASI_CRM_TYPE__c = 'Budget CM' AND ASI_CRM_Sub_Channel__c = :OutletInfo.ASI_CRM_CN_Sub_Channel__c 
                          AND ASI_CRM_REGION__c =:OutletInfo.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                          AND ASI_CRM_PRODUCTCODE__c IN :strSBSet
                          ORDER BY ASI_CRM_VERSION__c DESC];
        }catch(Queryexception e){
            system.debug(e);
            BudgetCMGS = new List<ASI_CRM_CM_GS__c>();
        }
        system.debug('BudgetCMGS: ' + BudgetCMGS );
        return BudgetCMGS;
    }
    
    public void showPriority(){
        string FY;
        objCSLI_map.clear();
        objCS = new List<ASI_CRM_CN_Channel_Strategy__c>();
        objCSLI = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSNull1 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSNull2 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSNull3 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        objCSLI_map.put('Priority 1', objCSNull1);
        objCSLI_map.put('Priority 2', objCSNull2);
        objCSLI_map.put('Priority 3', objCSNull3);
        if (PC.ASI_CRM_Start_Date__c != null){
            checkLastPO();
            FY = getChannelStrategy(PC.ASI_CRM_Start_Date__c);
            try{
                objCS = [SELECT id FROM ASI_CRM_CN_Channel_Strategy__c WHERE ASI_CRM_CN_Fiscal_Year__c = :FY 
                         AND ASI_CRM_CN_Image__c = :OutletInfo.ASI_CRM_CN_Image__c AND ASI_CRM_CN_Sub_Channel__c = :OutletInfo.ASI_CRM_CN_Sub_Channel__c
                         AND ASI_CRM_CN_Area__c = :OutletInfo.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c ORDER BY CreatedDate DESC];
                if (objCS.size()>0)
                    objCSLI = [SELECT id, Name, ASI_CRM_CN_Sub_brand__c,ASI_CRM_CN_Sub_brand__r.Name, ASI_CRM_CN_Brand__c FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c WHERE ASI_CRM_CN_Channel_Strategy__c IN :objCS];
            }catch(queryexception e){
                
            }
            system.debug('objCS: ' + objCS );
            system.debug('objCSLI: ' + objCSLI );
            if (objCSLI.size() > 0){
                for (ASI_CRM_CN_Channel_Strategy_Line_Item__c  a: objCSLI ){
                    if (objCSLI_map.containskey(a.ASI_CRM_CN_Brand__c)){
                        objCSLI_map.get(a.ASI_CRM_CN_Brand__c).add(a);
                    }else{
                        objCSLI_mapList = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
                        objCSLI_maplist.add(a);
                        objCSLI_map.put(a.ASI_CRM_CN_Brand__c, objCSLI_maplist);
                    }
                }
            }
            system.debug('objCSLI_map: ' + objCSLI_map);
            
        }else{
            objCSLI_map.put('Priority 1', objCSLI);
            objCSLI_map.put('Priority 2', objCSLI);
            objCSLI_map.put('Priority 3', objCSLI);
        } 
    }
    public void checkLastPO(){
        system.debug('checkLastPO()');
        //ASI_TH_CRM_Contract__c  
        system.debug('PC.ASI_CRM_CN_Outlet__c ' + PC.ASI_CRM_CN_Outlet__c );
        
        set<string> PromotionTypes = new set<string>();
        PromotionTypes.add('New Contract ON');
        PromotionTypes.add('New Contract OFF');
        
        strDayBefore = Date.today() - (365/12*6);
        try{
            LastContract = [SELECT id, ASI_CRM_CN_Contract_Variable_Cost_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c, 
                            ASI_TH_CRM_No_Of_Months__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_PO_No__c, 
                            ASI_TH_CRM_Start_Date__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c, 
                            ASI_TH_CRM_End_Date__c FROM ASI_TH_CRM_Contract__c
                            WHERE ASI_CRM_CN_Outlet_WS__c = :PC.ASI_CRM_CN_Outlet__c
                            AND ASI_CRM_CN_PO_End_Date__c != null AND ASI_CRM_CN_PO_Start_Date__c != null
                            AND ASI_CRM_CN_PO_End_Date__c >= :strDayBefore
                            AND ASI_TH_CRM_Promotion_Type__c IN :PromotionTypes
                            AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived')
                            ORDER BY ASI_CRM_CN_PO_End_Date__c Desc ,ASI_CRM_CN_PO_Version__c DESC LIMIT 1];
            /*LastContract = new ASI_TH_CRM_Contract__c ();
system.debug('ListLastPO: ' + ListLastPO);
for (ASI_TH_CRM_Contract__c b : ListLastPO){
//system.debug('Last Contract/PO: ' + b.ASI_CRM_CN_PO_End_Date__c.daysBetween(Date.today()));
LastPO = b.ASI_CRM_CN_PO_No__c;
LastContract = b;
}*/
            LastPO = LastContract.ASI_CRM_CN_PO_No__c;
            system.debug('LastContract: ' + LastContract + ' LastPO: ' + LastPO);
        }catch(Queryexception e){
            LastContract = new ASI_TH_CRM_Contract__c ();
            system.debug('Try Exception LastContract: ' + e);
        }
    }
    public string getChannelStrategy(Date strStart){
        integer SYear = strStart.Year();
        integer SMonth = strStart.Month();
        integer FYSYear;
        if (SMonth >= 7 && SMonth <= 12){
            FYSYear = SYear;
        }else if (SMonth >= 1 && SMonth <= 6){
            FYSYear = SYear - 1;
        }
        string FY = string.valueof(FYSYear) + '/'+ string.valueof(FYSYear+1);
        system.debug('FY: ' + FY);
        return FY;    
    }
    public Integer getChannelStrategySingleYear(Date strStart){
        integer SYear = strStart.Year();
        integer SMonth = strStart.Month();
        integer FYSYear;
        if (SMonth >= 7 && SMonth <= 12){
            FYSYear = SYear;
        }else if (SMonth >= 1 && SMonth <= 6){
            FYSYear = SYear - 1;
        }
        system.debug('FY: ' + FYSYear);
        return FYSYear;    
    }
    
    public void Result(){
        Saved();
        strNewVCost = 0;
        strNewVolume = 0;
        strNewExpenses = 0;
        if (PC.ASI_CRM_Variable_Cost__c != 0 && PC.ASI_CRM_Variable_Cost__c != null){
            strNewVCost = PC.ASI_CRM_Variable_Cost__c;
        }else{
            if(PC.ASI_CRM_Bottle_Incentive_Total__c != null)
                strNewVCost += PC.ASI_CRM_Bottle_Incentive_Total__c;
            if (PC.ASI_CRM_Promotion_Service_Fee__c != null)
                strNewVCost += PC.ASI_CRM_Promotion_Service_Fee__c;
            if (PC.ASI_CRM_Variable_Event_Cost__c != null)
                strNewVCost += PC.ASI_CRM_Variable_Event_Cost__c;
        } 
        if (PC.ASI_CRM_Bottle_Incentive_Total__c != null)
            strNewVolume = PC.ASI_CRM_Bottle_Incentive_Total__c;
        if (PC.ASI_CRM_Fixed_Expense__c != null)
            strNewExpenses = strNewVCost + PC.ASI_CRM_Fixed_Expense__c;
        
        showResult = true ;
        
        EvalResultTableList = new List<Evaluation_Result>();
        EvalResultTable_map = new Map<string, Evaluation_Result>();
        EvalResultTable1 = new Evaluation_Result();
        EvalResultTable2 = new Evaluation_Result();
        EvalResultTable3 = new Evaluation_Result();
        
        if (LastContract.id != null && BottleIncentiveMap.size() > 0){
            //Investment per Equiv. Chivas 12Y
            EvalResultTable1.name = 'Investment per Equiv. Chivas 12Y';
            EvalResultTable1.Result = Calculation1('PC');
            
            EvalResultTable1.lastcontract = Calculation1('LastContract');
            EvalResultTable_map.put('Investment per Equiv. Chivas 12Y', EvalResultTable1 );
            EvalResultTableList.add(EvalResultTable1);
            
            //% of Trade A&P on Fix Cost
            EvalResultTable2.name = '% of Trade A&P on Fix Cost';
            EvalResultTable2.Result = 0;
            EvalResultTable2.Align = '--';
            EvalResultTable2.lastcontract = 0;
            EvalResultTable_map.put('% of Trade A&P on Fix Cost', EvalResultTable2 );
            EvalResultTableList.add(EvalResultTable2);
            
            //Indexed ROI*
            EvalResultTable3.name = 'Indexed ROI*';
            EvalResultTable3.Result = CalculationROI('PC');
            //EvalResultTable3.Align = '--';
            EvalResultTable3.lastcontract = CalculationROI('LastContract');
            EvalResultTable_map.put('Indexed ROI*', EvalResultTable3 );
            EvalResultTableList.add(EvalResultTable3);
            
            strOldExpenses = strVCostOld + strFixedCostOld;
            strNewExpenses = strNewVCost + PC.ASI_CRM_Fixed_Expense__c;
            if (strOldExpenses != 0 && strOldExpenses != null && strNewExpenses != null && strNewExpenses != 0) strExpensesRate = (strNewExpenses/strOldExpenses)*100;
            if (strVCostOld != 0 && strVCostOld != null && strNewVCost != 0 && strNewVCost != null) strVcostRate = (strNewVCost / strVCostOld)*100;
            if (strFixedCostOld != 0 && strFixedCostOld != null && PC.ASI_CRM_Fixed_Expense__c != null && PC.ASI_CRM_Fixed_Expense__c != 0) strFCostRate = (PC.ASI_CRM_Fixed_Expense__c/strFixedCostOld)*100;  
            if (EvalResultTable3.Result != 0 && EvalResultTable3.Result != null && EvalResultTable3.lastcontract != 0 && EvalResultTable3.lastcontract != null) strROIRate = (EvalResultTable3.Result / EvalResultTable3.lastcontract)*100;
            if (strOldVolume != null && strOldVolume != 0 && strNewVolume != null && strNewVolume != 0) strVolumeRate = (strNewVolume/strOldVolume)*100;
            if (EvalResultTable1.Result != 0 && EvalResultTable1.Result != null && EvalResultTable1.lastcontract != 0 && EvalResultTable1.lastcontract != null) strCR12Rate = (EvalResultTable1.Result / EvalResultTable1.lastcontract)*100;
            
            if (strCR12Rate  != 0 && strCR12Rate  != null){
                if (Align_map.containskey('Investment per CR12 eq btl')){
                        EvalResultTable1.Align = (strCR12Rate*100 >= Align_map.get('Investment per CR12 eq btl')) ? 'Yes' : 'No';
                }
            }
            if (strROIRate != 0 && strROIRate!= null){
                if (Align_map.containskey('ROI for AD Above')){
                    EvalResultTable3.Align = (strROIRate*100 >= Align_map.get('ROI for AD Above')) ? 'Yes' : 'No';
                }
            }
            if (strFCostRate!= 0 && strFCostRate!= null){
                if (Align_map.containskey('Fixed Expense')){
                        strFEAlign = (strFCostRate*100 >= Align_map.get('Fixed Expense')) ? 'Yes' : 'No';
                }
            }
            
            if (strVCostRate!= 0 && strVCostRate!= null){
                if (Align_map.containskey('Variable Expense')){
                        strVEAlign = (strVCostRate*100 >= Align_map.get('Variable Expense')) ? 'Yes' : 'No';
                }
            }
            system.debug('strExpensesRate: ' + strExpensesRate);
            if (strExpensesRate!= 0 && strExpensesRate!= null){
                if (Align_map.containskey('Trade Expenses')){
                        strTEAlign = (strExpensesRate*100 >= Align_map.get('Trade Expenses')) ? 'Yes' : 'No';
                }
            }
            if (strVolumeRate != 0 && strVolumeRate != null){
                if (Align_map.containskey('Volumes (in 9L cs)')){
                        strVOAlign = (strVolumeRate*100 >= Align_map.get('Volumes (in 9L cs)')) ? 'Yes' : 'No';
                }
            }
        }
    }
    public void getLastContractVolume(){
        if (LastContract.id != null){
            try{
                ListContractCost = [SELECT id, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Estimate_Amount__c FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :LastContract.id];
                system.debug('ListContractCost: ' + ListContractCost);
                ListContractBRSF = [SELECT id, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c , ASI_CRM_CN_Contract_Total__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :LastContract.id];
                LC_BRSF_SubBrand = new set<id>();
                system.debug('ListContractBRSF: ' + ListContractBRSF);
            }catch(queryexception e){
                ListContractCost = new List<ASI_CRM_Contract_Cost__c>();
                ListContractBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            }
            if (ListContractBRSF.size() >0)
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf : ListContractBRSF ){
                    LC_BRSF_SubBrand.add(brsf.ASI_CRM_CN_Sub_Brand__c);
                }
            system.debug('LC_BRSF_SubBrand: ' + LC_BRSF_SubBrand.size() + ': ' + LC_BRSF_SubBrand);
        }else{
            ListContractCost = new List<ASI_CRM_Contract_Cost__c>();
            ListContractBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            ListSBVolume = new List<ASI_CRM_Subbrand_Volume__c>();
        }
    }
    public decimal GetSubBrandVolumeData(string strType){
        system.debug('GetSubBrandVolumeData()' + strType);
        getLastContractVolume();
        ListSBVolume = new List<ASI_CRM_Subbrand_Volume__c>();
        Integer StartYear = 0;
        Integer EndYear = 0;
        decimal Factor = 1;
        if (LastContract.ASI_CRM_CN_PO_Start_Date__c != null)
            StartYear = getChannelStrategySingleYear(LastContract.ASI_CRM_CN_PO_Start_Date__c);
        if (LastContract.ASI_CRM_CN_PO_End_Date__c != null)
            EndYear = getChannelStrategySingleYear(LastContract.ASI_CRM_CN_PO_End_Date__c);
        Integer NOYears = (EndYear - StartYear)+1;
        system.debug('StartYear: ' + StartYear + ' EndYear: ' + EndYear + ' NoYears: ' + NoYears);
        Decimal Result = 0;
        decimal strActualCMGS = 1;
        strOldVolume =0;
        //strCR12Rate = 0;
        system.debug('NoYears:' + NoYears);
        for (integer i=0; i < NOYears; i++){
            sb_fiscalyear.add(string.valueof(StartYear+i)); 
        }
        system.debug('sb_fiscalyear: ' + sb_fiscalyear);
        try{
            ListSBVolume = [SELECT ASI_CRM_Month__c, ASI_CRM_Offtake__c, ASI_CRM_Year__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c FROM ASI_CRM_Subbrand_Volume__c WHERE 
                            ASI_CRM_Subbrand__c IN :LC_BRSF_SubBrand AND
                            ASI_CRM_Year__c IN :sb_fiscalyear];
            system.debug('ListSBVolume: ' + ListSBVolume.size());
        }catch(queryexception e){
            ListSBVolume = new list<ASI_CRM_Subbrand_Volume__c>();
        }
        if (strType == 'Investment' && ListSBVolume.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c a : ListSBVolume){
                if (a.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null)
                    Factor = a.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                if (a.ASI_CRM_Offtake__c != null){
                    Result += (a.ASI_CRM_Offtake__c * Factor);
                }
            }
        }
        if (strType == 'ROI' && ListSBVolume.size() > 0){
            system.debug('ROI');
            List<ASI_CRM_CM_GS__c> LastContractACM = getActualCMGS(LC_BRSF_Subbrand);
            for (ASI_CRM_Subbrand_Volume__c a : ListSBVolume){
                for (ASI_CRM_CM_GS__c b : LastContractACM){
                    if (a.ASI_CRM_Subbrand__c == b.ASI_CRM_PRODUCTCODE__c && b.ASI_CRM_CM_GS_per_9L__c != null && b.ASI_CRM_CM_GS_per_9L__c != 0)//20161114 Elufa
                        strActualCMGS = b.ASI_CRM_CM_GS_per_9L__c;
                }
                if (a.ASI_CRM_Offtake__c != null){
                    Result += (a.ASI_CRM_Offtake__c * strActualCMGS);
                    strOldVolume += a.ASI_CRM_Offtake__c;
                }
            }
            system.debug('strOldVolume: '+ strOldVolume);
        }
        system.debug('GetSubBrandVolumeData ' + strType + ': ' + Result);
        return Result;
    }
    public decimal CalculationROI(string strContract){
        
        decimal TotalInvestment = 0;
        decimal TotalCR12eqv = 0;
        decimal Result = 0;
        decimal factor = 1;
        decimal strBudgetCM = 1;
        
        
        if (strContract == 'LastContract'){
            TotalCR12eqv = GetSubBrandVolumeData('ROI');
            if (LastContract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c != null)
                TotalInvestment += LastContract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c;
            if (LastContract.ASI_CRM_CN_Contract_Variable_Cost_Total__c != null)
                TotalInvestment += LastContract.ASI_CRM_CN_Contract_Variable_Cost_Total__c;
        }
        
        if (strContract == 'PC'){
            decimal version = 0;
            getSubBrandLineItemsMap();
            if (PC.ASI_CRM_Variable_Cost__c != 0 && PC.ASI_CRM_Variable_Cost__c != null){
                TotalInvestment = PC.ASI_CRM_Variable_Cost__c ;
            }else{
                if (PC.ASI_CRM_Bottle_Incentive_Total__c != null)
                    TotalInvestment += PC.ASI_CRM_Bottle_Incentive_Total__c;
                if (PC.ASI_CRM_Promotion_Service_Fee__c != null)
                    TotalInvestment += PC.ASI_CRM_Promotion_Service_Fee__c;
                if (PC.ASI_CRM_Variable_Event_Cost__c != null)
                    TotalInvestment += PC.ASI_CRM_Variable_Event_Cost__c;
                
            }
            List<ASI_CRM_CM_GS__c> NewContractBudgetCM = getBudgetCMGS(BottleIncentiveSB_id);
            if (BottleIncentive.size() > 0){
                for (ASI_CRM_Pre_Contract_Sub_Brand__c b: BottleIncentive){
                    for (ASI_CRM_CM_GS__c a : NewContractBudgetCM){
                        if (b.ASI_CRM_Sub_Brand__c == a.ASI_CRM_PRODUCTCODE__c && a.ASI_CRM_VERSION__c > version){
                            if (a.ASI_CRM_CM_GS_per_9L__c != null && a.ASI_CRM_CM_GS_per_9L__c != 0)//20161114 Elufa
                                strBudgetCM = a.ASI_CRM_CM_GS_per_9L__c;
                            //b.ASI_CRM_Estimated_Btl_Month__c * a.ASI_CRM_CM_GS_per_9L__c * 12;
                        }
                    }
                    if (b.ASI_CRM_Estimated_Btl_Month__c != null)
                        TotalCR12eqv += b.ASI_CRM_Estimated_Btl_Month__c;
                    TotalCR12eqv = TotalCR12eqv * strBudgetCM * 12;
                }
            }
        }   
        
        if (TotalInvestment!= 0 && TotalCR12eqv != 0)
            Result = TotalCR12eqv/ TotalInvestment;
        system.debug('CalcROI Result: ' + result);
        return Result;
    }
    public decimal Calculation1(string strContract){
        decimal TotalInvestment = 0;
        decimal TotalCR12eqv = 0;
        decimal Result = 0;
        decimal factor =1;
        strFixedCostOld = 0;
        strVCostOld = 0;
        strNewVCost = 0;
        strNewVolume = 0;
        system.debug('LastContract: ' + LastContract.id);
        if (strContract == 'LastContract'){
            TotalCR12eqv = GetSubBrandVolumeData('Investment');
            
            if (LastContract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c != null){
                TotalInvestment += LastContract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c;
                strFixedCostOld = LastContract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c;
            }
            if (LastContract.ASI_CRM_CN_Contract_Variable_Cost_Total__c != null){
                TotalInvestment += LastContract.ASI_CRM_CN_Contract_Variable_Cost_Total__c;
                strVCostOld = LastContract.ASI_CRM_CN_Contract_Variable_Cost_Total__c;
            }
        }
        
        if (strContract == 'PC'){
            getSubBrandLineItemsMap();  
            if (PC.ASI_CRM_Variable_Cost__c != 0 && PC.ASI_CRM_Variable_Cost__c != null){
                TotalInvestment = PC.ASI_CRM_Variable_Cost__c ;
                strNewVCost = PC.ASI_CRM_Variable_Cost__c;
            }else{
                if (PC.ASI_CRM_Bottle_Incentive_Total__c != null)
                    TotalInvestment += PC.ASI_CRM_Bottle_Incentive_Total__c;
                if (PC.ASI_CRM_Promotion_Service_Fee__c != null)
                    TotalInvestment += PC.ASI_CRM_Promotion_Service_Fee__c;
                if (PC.ASI_CRM_Variable_Event_Cost__c != null)
                    TotalInvestment += PC.ASI_CRM_Variable_Event_Cost__c;
                strNewVCost = TotalInvestment;
            }
            system.debug('strNewVCost: ' + strNewVCost);
            for (ASI_CRM_Pre_Contract_Sub_Brand__c b: BottleIncentive){
                if (b.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null)
                    factor = b.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                if (b.ASI_CRM_Estimated_Btl_Month__c != null){
                    TotalCR12eqv += b.ASI_CRM_Estimated_Btl_Month__c * factor * 12;
                    strNewVolume += b.ASI_CRM_Estimated_Btl_Month__c;
                }
            }
            system.debug('strNewVolume: '+ strNewVolume);
        }   
        
        if (TotalCR12eqv != 0 && TotalInvestment != 0)
            Result = TotalInvestment / TotalCR12eqv;
        system.debug('Calc1 Result: ' + result);
        return Result;
    }
    public void hideResult(){
        showResult = false;
    }
    public void AddNew(){
        ASI_CRM_Pre_Contract_Sub_Brand__c b = new ASI_CRM_Pre_Contract_Sub_Brand__c();
        BottleIncentiveMap.put(index++, b);
        system.debug('BottleIncentiveMap: ' + BottleIncentiveMap);
    }
    public void RemoveRow(){  
        DelItems.add(BottleIncentiveMap.get(rowid)); 
        BottleIncentiveMap.remove(rowid);
        system.debug('BottleIncentiveMap: ' + BottleIncentiveMap);
    }
    public void Saved(){
        
        if (PageId != null){
            update PC;
        }else{
            insert PC;
            PageId = PC.id;
        }
        system.debug(PC.Id);
        List<ASI_CRM_Pre_Contract_Sub_Brand__c> AddChild = new List<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        List<ASI_CRM_Pre_Contract_Sub_Brand__c> UpdateChild = new List<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        if (BottleIncentiveMap.size() > 0){
            for (ASI_CRM_Pre_Contract_Sub_Brand__c b : BottleIncentiveMap.values()){
                if (b.id != null){
                    UpdateChild.add(b);
                    //update b;
                }else{
                    ASI_CRM_Pre_Contract_Sub_Brand__c child = new ASI_CRM_Pre_Contract_Sub_Brand__c();
                    //child = b.clone();
                    child = b;
                    child.ASI_CRM_Pre_Contract_Eval__c = PC.Id;
                    if (b.ASI_CRM_Sub_Brand__c != null && b.ASI_CRM_Estimated_Btl_Month__c != null)
                        AddChild.add(child);
                    //insert child;
                }
            }
        }
        system.debug('AddChild.size(): '+AddChild.size());
        if (AddChild.size() > 0)
            insert AddChild;
        if (UpdateChild.size() > 0)
            update UpdateChild;
        system.debug('DelItems: ' + DelItems);
        
        if (DelItems.size() > 0){
            for (ASI_CRM_Pre_Contract_Sub_Brand__c  c: DelItems){
                if (c.id != null){
                    delete c;
                }
            }
            DelItems.clear();
        }
    }
    public pageReference SaveAll(){
        Saved();
        PageReference SavePage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalSummary?id=' + PC.Id);
        SavePage.setredirect(true);
        return SavePage;
    }
    public pageReference CancelPC(){
        PageReference cancelPage;
        if (PageId != null)
            cancelPage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalSummary?id=' + PC.Id);
        else
            cancelPage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalMain');
        cancelPage.setredirect(true);
        return cancelPage;
    }
    public pageReference BackPC(){
        PageReference backPage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalMain');
        backPage.setredirect(true);
        return backPage;
    }
    public pageReference EditPC(){
        PageReference EditPage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalEdit?id=' + PC.Id);
        EditPage.setredirect(true);
        return EditPage;
    }
    public pageReference SaveAsNew(){
        List <ASI_CRM_Pre_Contract_Sub_Brand__c> AddChild = new List<ASI_CRM_Pre_Contract_Sub_Brand__c>();
        ASI_CRM_PreContractEval__c newPC = new ASI_CRM_PreContractEval__c();
        if (pageId != null)
            newPC = PC.clone();
        insert newPC;
        for (ASI_CRM_Pre_Contract_Sub_Brand__c b : BottleIncentiveMap.values()){
            
            ASI_CRM_Pre_Contract_Sub_Brand__c child = new ASI_CRM_Pre_Contract_Sub_Brand__c();
            child = b.clone();
            child.ASI_CRM_Pre_Contract_Eval__c = newPC.Id;
            if (b.ASI_CRM_Sub_Brand__c != null && b.ASI_CRM_Estimated_Btl_Month__c != null)
                AddChild.add(child);
            //insert child;
        }
        Insert AddChild;
        
        PageReference newPage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalMain');
        newPage.setredirect(true);
        return newPage;
    }
    public pageReference SaveAndShare(){
        saved();
        shareChatter();
        PageReference sharePage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalSummary?id=' + PageId);
        sharePage.setredirect(true);
        return sharePage;
    }
    public pageReference Share(){
        shareChatter();
        PageReference sharePage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalSummary?id=' + PageId);
        sharePage.setredirect(true);
        return sharePage;
    }
    public void shareChatter(){
        Id UserId = UserInfo.getUserId();
        Id ManagerId = [SELECT Managerid FROM USER WHERE Id = :UserId].Managerid;
        id subjectId = PageId;
        String communityId = null;
        if (ManagerId != null){
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
            string url = salesforceHost + '/apex/ASI_CRM_CN_PreContractEvalSummary?id=' + PageId;
            
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = '. I have shared a Pre-Contract with you.'; //'\nDetails: ' + url;
            messageInput.messageSegments.add(textSegment);
            
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.body = messageInput;
            ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, subjectId, input, null);
        }
    }
    public PageReference SaveEval(){
        saved();
        PageReference SaveEvalPage = new PageReference('/apex/ASI_CRM_CN_PreContractEvalSummary?id=' + PageId);
        SaveEvalPage.setredirect(true);
        return SaveEvalPage;
        
    }
    @RemoteAction
    public static String[] findSObjects(string obj, string qry, string rec) {
        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';
        
        List <ASI_MFM_Sub_brand__c> sub_brand = new List<ASI_MFM_Sub_brand__c>();
        map<string, id> map_recordtype =ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');
        
        
        try {
            sub_brand=[SELECT Name,ASI_MFM_Active_for_CRM__c,RecordTypeid FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c=TRUE AND RecordTypeid=:map_recordtype.get('ASI_FOC_CN_Sub_brand') AND Name like :key ORDER BY NAME];
            
            for(ASI_MFM_Sub_brand__c sb:sub_brand){
                results.add(sb.Name);  }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
    }
    
    public class Evaluation_Result{
        public SOBject EValuation_Result {set;get;}
        public string name {set;get;}
        public decimal Result {set;get;}
        public string Align {set;get;}
        public decimal lastcontract {set;get;}
    }
}