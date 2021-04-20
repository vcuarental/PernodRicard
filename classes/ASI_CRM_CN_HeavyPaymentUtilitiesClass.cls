/**
 * @File Name          : ASI_CRM_CN_HeavyPaymentUtilitiesClass.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 4/9/2020, 11:34:16 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/9/2020   pengchen@bluelinksys.com     Initial Version
**/
public class ASI_CRM_CN_HeavyPaymentUtilitiesClass {
    
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public static Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    
    //key performance indicators
    public static void PaymentKPICalculation(ASI_TH_CRM_PaymentRequest__c PaymentRequest ){
        Map<String,Decimal> PaymentKPIMap= new Map<String,Decimal>();
        
        //KPI 
        Decimal FixedCostTotal = 0 ; 
        Decimal VariableCostTotal=0;
        Decimal PaymentSpeed = 0 ;
        Decimal VolumeSpeed=0;
        
        
        
        //Payment Speed
        Decimal TotalPaymentAmount = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(PaymentRequest);
        Decimal v0_Cost = 0;
        Decimal V0ContractVolume=0;
        Decimal ActualIntake=0;
        
        //Min Key Strategy sub-brands achievement% should greater or equal to total volume achievement%.
        Decimal  MKSSBAR=9999999;// Min Key Strategy SubBrand Achievement Rate 
        
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [Select id, name,ASI_CRM_CN_Completion_Rate__c, ASI_CRM_Key_Sub_Brand__c , ASI_CRM_Volume_Base__c,RecordType.DeveloperName, recordtypeid, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c  
                                                               from ASI_TH_CRM_PaymentRequestLineItem__c 
                                                               where ASI_TH_CRM_Payment_Request__c = :PaymentRequest.Id ])
        {//and  RecordType.DeveloperName='ASI_CRM_CN_Payment_Request_Detail_Other' 
            if(PaymentLine.RecordType.DeveloperName =='ASI_CRM_CN_Payment_Request_Detail_Other'){
                FixedCostTotal+=PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
            }
            if(PaymentLine.RecordType.DeveloperName =='ASI_CRM_CN_Payment_Request_Detail_PSF' && PaymentLine.ASI_CRM_Volume_Base__c!=null && PaymentLine.ASI_CRM_CN_Completion_Rate__c !=null && PaymentLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'   && PaymentLine.ASI_CRM_Key_Sub_Brand__c ){
               PaymentKPIMap.put('Key Strategy sub-brands', 1);
                if(PaymentLine.ASI_CRM_CN_Completion_Rate__c<MKSSBAR){
                    MKSSBAR=PaymentLine.ASI_CRM_CN_Completion_Rate__c;
                }
            }
        }
        
        
        PaymentKPIMap.put('MKSSBAR', MKSSBAR);
        
        
        for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
            VariableCostTotal+=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
            
            if(module.ASI_CRM_Line_Type__c=='PSF' && module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                PaymentKPIMap.put('PSFBySubBrandAchievementRate', module.ASI_CRM_Completion_Ratio__c);
            }
        }
        
        
        
        String V0ContractId='';
        if(PaymentRequest.ASI_TH_CRM_Contract__c!=null && PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(PaymentRequest.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=PaymentRequest.ASI_TH_CRM_Contract__c;
        }
        
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractDetailList=[SELECT id, ASI_CRM_Type__c,ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c,
                                                                        ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name, 
                                                                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                                                                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, 
                                                                        ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Monthly_Qty__c , ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,
                                                                        ASI_CRM_CN_Contract__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                                                                        ASI_CRM_CN_Contract_Monthly_Vol9L__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                                                                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                                                                        ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c
                                                                        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0ContractId];
        
        Set<Id> SubBrandIdSet = new Set<Id> ();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractDetail:contractDetailList){
            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                SubBrandIdSet.add(ContractDetail.ASI_CRM_CN_Sub_Brand__c);
            }
        }
        
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        if(SubBrandIdSet.size()>0){
            CR12FactorMap=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(SubBrandIdSet,
                                                                                       PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                                                                       PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c);
        }
        
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetail:contractDetailList)
        {
            v0_Cost+= contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            if(contractDetail.ASI_CRM_Type__c=='BRSF'){
                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(contractDetail.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(contractDetail.ASI_CRM_CN_Sub_Brand__c);
                }
                V0ContractVolume+=CR12Factor*contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c * contractDetail.ASI_CRM_CN_No_of_Months__c;
            }
        }
        
        
        
        if (v0_Cost != null && v0_Cost !=0 && TotalPaymentAmount != null && TotalPaymentAmount != 0){
            system.debug('Now TotalPaymentAmount'+ TotalPaymentAmount);
            system.debug('Now v0_Cost'+ v0_Cost);
            PaymentSpeed = TotalPaymentAmount / v0_Cost * 100;
        }
        
        
        ///*******************Calculate Volume Speed*******************************************************************
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                             FROM ASI_CRM_CN_Covered_Outlet__c
                             WHERE ASI_CRM_CN_Contract__c = :PaymentRequest.ASI_TH_CRM_Contract__c];
        }catch(exception e){
            CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }  
        
        set<id> AllOutlet = new set<id>();
        //ASI_TH_CRM_PaymentRequest__c tempPR = [SELECT id, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :thisPR.id]; 
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(PaymentRequest.ASI_CRM_CN_OutletWS__c);
        }
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }
        
        list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c> ();
        date TillEnd = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate(), PaymentRequest.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        system.debug('SB Vol TillEnd : '+TillEnd);
        try{
            SB_Vol_List = [SELECT Id,Name,ASI_CRM_T1_Depletion_Std_Billing__c,ASI_CRM_DeductibleCapWithIssues_Std_Btl__c, ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_Std_Billing__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c, ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,ASI_CRM_PR_Direct__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c, ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c 
                           FROM ASI_CRM_Subbrand_Volume__c 
                           WHERE ASI_CRM_End_Date__c >= :PaymentRequest.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_End_Date__c <= :TillEnd  AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                           AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false and ASI_CRM_Subbrand__c !=null];
            
        }catch(exception e){
            SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c >();
        }
        
        if (SB_Vol_List.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : SB_Vol_List ){
                ActualIntake += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null?SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
                ActualIntake += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null?SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
                ActualIntake += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null?SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;
                
            }
            
        }
        
        
        if (V0ContractVolume != null && V0ContractVolume !=0 && ActualIntake != null && ActualIntake != 0){
            system.debug('ActualIntake'+ActualIntake);
            system.debug('V0ContractVolume'+V0ContractVolume);
            VolumeSpeed = (ActualIntake / V0ContractVolume) * 100;
        }
        
        
        PaymentKPIMap.put('FixedCostTotal',FixedCostTotal);
        
        PaymentKPIMap.put('VariableCostTotal',VariableCostTotal);
        PaymentKPIMap.put('PaymentSpeed',PaymentSpeed);
        
        PaymentKPIMap.put('VolumeSpeed',VolumeSpeed);
        
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(PaymentRequest.ASI_TH_CRM_Contract__c, System.JSON.serialize(PaymentKPIMap),'Payment Data' );
    }
    
    
    
    
    
    
    
    
    public static void  ReconstructLastPaymentFIData(ASI_TH_CRM_PaymentRequest__c thisPR) {
        date strStart;
        Date CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Map<String,VolumeObject> VolumeMap= new Map<String,VolumeObject>();
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator  ActualPerformance= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator(); 
        Map<String, String> sbGroup_map = ASI_CRM_CN_HeavyContractUtilitiesClass.SUB_BRAND_GRADE_GROUPING_MAP;
        
        
        map<string, string> SubbrandGroup = new map<string, string>();
        SubbrandGroup.put('Premium', '1. Standard + Premium 标准档 + 高档');
        SubbrandGroup.put('Standard', '1. Standard + Premium 标准档 + 高档');
        SubbrandGroup.put('Prestige', '4. Prestige + Ultra Prestige 奢华档 + 特级奢华档');
        SubbrandGroup.put('Ultra Prestige', '4. Prestige + Ultra Prestige 奢华档 + 特级奢华档');
        SubbrandGroup.put('Super Premium', '2. Super Premium 超高档');
        SubbrandGroup.put('Ultra Premium', '3. Ultra Premium 特级高档');
        SubbrandGroup.put('Not Specified / 未指定','5. Not Specified / 未指定');
        
        map<string,decimal> RegionSubBrandCM_Map = new map<string,decimal>();
        
        
        for(String SBGName:sbGroup_map.keySet()){
            ActualPerformance.SubBrandGradeMap.put(SBGName,0.0); 
        }
        
        //Query all payment request with vFinal contract
        list<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest = new list<ASI_TH_CRM_PaymentRequest__c>();
        try{
            AllPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
                                 ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                                 ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c
                                 FROM ASI_TH_CRM_PaymentRequest__c
                                 WHERE ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c
                                 AND (id = :thisPR.id OR ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted'  OR ASI_TH_CRM_Status__c = 'Paid')];
        }catch(exception e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyPaymentCheckCtrl. RetrieveTotalPaidAmount  class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyContractUtilitiesClass',' function failed! with Payment Id: '+thisPR.id );
        }
        
        //Sum up previous payments amounts
        if (AllPaymentRequest.size() > 0){
            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
                if (allPR_temp.ASI_CRM_CN_Total_Payment__c != null){
                    ActualPerformance.TradeExpenses += allPR_temp.ASI_CRM_CN_Total_Payment__c;
                    
                    if(allPR_temp.ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On'){
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_Total_Variable_Amount__c!=NULL?allPR_temp.ASI_CRM_Total_Variable_Amount__c:0;
                    }else{
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;
                    }
                    
                }
            }
        }
        
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> PRLineItems = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        try{
            //query All Payment Variable & Fixed Cost
            PRLineItems = [SELECT id, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
                           ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c, RecordTypeId,RecordType.DeveloperName,ASI_CRM_Adjustment__c,
                           ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Cost__c 
                           FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c and (ASI_TH_CRM_Payment_Request__c =:thisPR.id OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR 
                                                                                                                                                                     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted'  OR
                                                                                                                                                                     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid')];
        }catch(exception e){
            PRLineItems = new list<ASI_TH_CRM_PaymentRequestLineItem__c >();
        }
        
        for ( ASI_TH_CRM_PaymentRequestLineItem__c  li_temp : PRLineItems ){
            if(li_temp.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                if(li_temp.ASI_CRM_CN_Cost_Type__c == 'Fixed' ){
                    ActualPerformance.FixedExpense += li_temp.ASI_TH_CRM_Amount__c!=null? li_temp.ASI_TH_CRM_Amount__c:0;
                }else{
                    ActualPerformance.VariableExpense+= li_temp.ASI_TH_CRM_Amount__c!=null? li_temp.ASI_TH_CRM_Amount__c:0;
                }
            }
        }
        if(ActualPerformance.TradeExpenses!=null && ActualPerformance.TradeExpenses !=0){
            ActualPerformance.FixedExpenseRate = (ActualPerformance.FixedExpense/ActualPerformance.TradeExpenses)*100;
        }
        
        
        // get latest Budget CM for all Sub-Brands
        string currentFY = String.valueOf(ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(date.Today()).Year());
        string currentFY2 = (integer.valueOf(currentFY) - 1) + '';
        string currentFY3 = (integer.valueOf(currentFY) - 2) + '';
        system.debug('currentFY'+currentFY);
        system.debug('currentFY2'+currentFY2);
        system.debug('currentFY3'+currentFY3);
        string ProductCode;
        decimal cm;
        for (ASI_CRM_CM_GS__c lbcm : [SELECT id, ASI_CRM_YEAR__c,ASI_CRM_CM_GS_per_9L__c,ASI_CRM_PRODUCTCODE__r.name, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c, ASI_CRM_CN_Month__c FROM ASI_CRM_CM_GS__c WHERE ASI_CRM_CN_Month__c = 6 
                                      AND ASI_CRM_Region__c = : thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                      AND (ASI_CRM_YEAR__c = :currentFY  OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3)
                                      AND (ASI_CRM_TYPE__c = 'Budget CM')  AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0  ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        { 
            ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c == null){
                cm = 0;
            }else{
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
            }
            if(!RegionSubBrandCM_Map.containsKey(ProductCode) && cm != Null && cm != 0){
                RegionSubBrandCM_Map.put(ProductCode,cm);
            }
            
        }
        
        
        
        decimal Vol_CR12_1 =0; //All Payment Period
        map<string, decimal> ActualCM_v1_map = new map<string, decimal>();
        map<string, decimal> ActualGS_v1_map= new map<string, decimal>();
        map<string, decimal> lbcm_v1_map= new map<string, decimal>();
        Decimal ActualIntakeTotal = 0;//for calculating bc%
        Decimal ActualBCTotal = 0;//for calculating bc%
        
        Decimal ActualBlackCap = 0;

        Decimal Total_MartellBC =0;  // total contract Martel BC
        Decimal Total_MartellIntakeBtl =0;  // total contract Martel Intake Btl
        Decimal Total_MartellBlackCap =0;  // total contract Martel BlackCap
        
        
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                             FROM ASI_CRM_CN_Covered_Outlet__c
                             WHERE ASI_CRM_CN_Contract__c = :thisPR.ASI_TH_CRM_Contract__c];
        }catch(exception e){
            CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }  
        set<id> AllOutlet = new set<id>();
        
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(thisPR.ASI_CRM_CN_OutletWS__c);
        }
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }
        
		system.debug('CutOffDay:' + CutOffDay);
		system.debug('thisPR.ASI_CRM_CN_PO_End_Date__c:' + thisPR.ASI_CRM_CN_PO_End_Date__c);
		system.debug(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));        
        date TillEnd = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        
        
        system.debug('Payment thisPR.ASI_CRM_CN_PO_Start_Date__c: '+thisPR.ASI_CRM_CN_PO_Start_Date__c);
        system.debug('Payment TillEnd: '+TillEnd);
        list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c> ();
        
        
        try{
            SB_Vol_List = [SELECT Id,Name,ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                           ASI_CRM_T1_Depletion_Std_Billing__c,ASI_CRM_DeductibleCapWithIssues_Std_Btl__c, ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_Std_Billing__c,
                           ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c,
                           ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c, ASI_CRM_Subbrand__c, 
                           ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,ASI_CRM_PR_Direct__c, 
                           ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                           ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c, ASI_CRM_Green_Cap_STD__c,
                           ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c 
                           FROM ASI_CRM_Subbrand_Volume__c 
                           WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_End_Date__c <= :TillEnd  AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                           AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false and ASI_CRM_Subbrand__c !=null];
            
        }catch(exception e){
            SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c >();
        }
        
        
        list<ASI_CRM_CM_GS__c> ActualCM_List = new list<ASI_CRM_CM_GS__c>();
        map<date, decimal> V1_Period_map = ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(thisPR.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_CRM_CN_PO_End_Date__c);
        SYSTEM.debug('Now V1_Period_map: '+ V1_Period_map);
        map<string, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> v1_ROI_newMap = new map<string, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        
        set<id> v1_sbid_set = new set<id>(); //ActualPerformance
        if (SB_Vol_List.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : SB_Vol_List ){
                v1_sbid_set.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                String sbGradeName ='';
                Decimal ActualVolumes=0;
                ActualVolumes+=SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
                ActualVolumes+=SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
                ActualVolumes+=SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;
                
                ActualPerformance.Volumes+=ActualVolumes;
                
                if (SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    if (SubbrandGroup.containskey(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                        sbGradeName = SubbrandGroup.get(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                    }else{
                        sbGradeName = 'Not Specified / 未指定';
                    }
                }else{
                    sbGradeName = 'Not Specified / 未指定';
                }
                
                if(ActualPerformance.SubBrandGradeMap.containskey(sbGradeName)){
                    Decimal TempVolumes=ActualPerformance.SubBrandGradeMap.get(sbGradeName)+ActualVolumes;
                    ActualPerformance.SubBrandGradeMap.remove(sbGradeName);//remove orignal one
                    ActualPerformance.SubBrandGradeMap.put(sbGradeName,TempVolumes); 
                }else{
                    ActualPerformance.SubBrandGradeMap.put(sbGradeName,ActualVolumes); 
                }
                
                
            }
        }
        
        if (V1_Period_map.size() > 0){
            string strkey;
            for (date v1temp : V1_Period_map.keyset()){
                if (v1_sbid_set.size() > 0){
                    for (id sbtemp : v1_sbid_set){
                        strkey = string.valueof(v1temp) + sbtemp;
                        ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
                        newitem.period = V1_Period_map.get(v1temp);
                        newitem.SubBrandId = sbtemp;
                        newitem.year = string.valueof(v1temp.year());
                        newitem.totalVolume = 0;
                        
                        if (!v1_ROI_newMap.containskey(strkey)){
                            v1_ROI_newMap.put(strkey, newitem);
                        }
                    }
                }
            }
        }
        
        date strV1End = ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN');
        
        //V0ContractId
        ASI_TH_CRM_Contract__c Contractv0 =new ASI_TH_CRM_Contract__c();
        
        date strEnd;
        String V0ContractId='';
        if(thisPR.ASI_TH_CRM_Contract__c!=null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(thisPR.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__c;
        }
        if (V0ContractId != null && V0ContractId != ''){
            Contractv0 = [SELECT ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c  FROM ASI_TH_CRM_Contract__c WHERE id = :V0ContractId];
        }
        if (Contractv0.ASI_CRM_CN_PO_Start_Date__c !=null ){
            strStart = Contractv0.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        }else{
            strStart = thisPR.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        }
        
        
        strStart=ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(strStart);
        
        system.debug('234'+v1_sbid_set+'ActualCM Now strStart '+strStart);
        system.debug('ActualCM Now strV1End '+strV1End);
        
        try{
            ActualCM_List = [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                             ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_TYPE__c 
                             FROM ASI_CRM_CM_GS__c
                             WHERE ASI_CRM_PRODUCTCODE__c IN :v1_sbid_set
                             AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                             AND ASI_CRM_CN_Month_End_Date__c >= :strStart
                             AND ASI_CRM_CN_Month_End_Date__c <= :strV1End 
                             AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
                             AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0
                             ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
        }catch(exception e){
            ActualCM_List = new list<ASI_CRM_CM_GS__c>();
        }
        
        
        
        if (ActualCM_List.size() > 0){ 
            string strkey;
            string subbrand_id;
            string lastestkey;
            for (ASI_CRM_CM_GS__c ACM_temp : ActualCM_List){
                subbrand_id = ACM_temp.ASI_CRM_PRODUCTCODE__c;
                strkey = string.valueof(ACM_temp.ASI_CRM_CN_Month_End_Date__c) + subbrand_id;
                
                decimal ActualCMperBtl = null;
                if (ACM_temp.ASI_CRM_CM_GS_per_9L__c != null){
                    ActualCMperBtl = ACM_temp.ASI_CRM_CM_GS_per_9L__c;  
                }
                
                lastestkey = subbrand_id;
                if (ACM_temp.ASI_CRM_TYPE__c == 'YTD CM'){
                    if (!ActualCM_v1_map.containskey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0){//system.debug('Now Put '+lastestkey+' ActualCMperBtl : '+ActualCMperBtl);
                        ActualCM_v1_map.put(lastestkey, ActualCMperBtl);
                    }
                    if (v1_ROI_newMap.containskey(strkey)){
                        if ((v1_ROI_newMap.get(strkey).actualCM == null || v1_ROI_newMap.get(strkey).actualCM == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0){
                            v1_ROI_newMap.get(strkey).actualCM = ActualCMperBtl; //v1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                        } 
                    }
                }
                if (ACM_temp.ASI_CRM_TYPE__c == 'YTD GS'){
                    if (!ActualGS_v1_map.containskey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0){//system.debug('Now Put '+lastestkey+' ActualCMperBtl : '+ActualCMperBtl);
                        ActualGS_v1_map.put(lastestkey, ActualCMperBtl);
                    }
                    
                    if (v1_ROI_newMap.containskey(strkey)){
                        if ((v1_ROI_newMap.get(strkey).actualGS == null || v1_ROI_newMap.get(strkey).actualGS == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0){
                            v1_ROI_newMap.get(strkey).actualGS = ActualCMperBtl;
                        }
                    }
                }
                
                if (!lbcm_v1_map.containskey(lastestkey))
                    if ( RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c)) {
                        lbcm_v1_map.put(lastestkey, RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c));
                    }
                
                
                if (v1_ROI_newMap.containskey(strkey)){
                    if (v1_ROI_newMap.get(strkey).latestbudgetCM == null || v1_ROI_newMap.get(strkey).latestbudgetCM == 0){
                        if (RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c)) {
                            v1_ROI_newMap.get(strkey).latestbudgetCM = RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c);
                        }
                    }// v1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                }
                
            }
        }
        
        //Looping Sub-brand Volume
        for (ASI_CRM_Subbrand_Volume__c  SB_Vol_temp : SB_Vol_List){
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c:0;
            
            Decimal  MarginUseTotalVol_std = 0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_PR_Direct_STD__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c:0;
            ActualIntakeTotal += MarginUseTotalVol_std;
            
            Decimal  ActualBC_std = 0;
            
            ActualBC_std += SB_Vol_temp.ASI_CRM_Green_Cap_STD__c != null? SB_Vol_temp.ASI_CRM_Green_Cap_STD__c:0;
            ActualBC_std += SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Btl__c != null? SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Btl__c:0;
            ActualBC_std += SB_Vol_temp.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c != null? SB_Vol_temp.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c:0;
            ActualBCTotal += ActualBC_std ;
            
            if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){
                system.debug('Now Martell: ActualBC_std: '+ActualBC_std + ' MarginUseTotalVol_std : ' + MarginUseTotalVol_std);
                Total_MartellBC += ActualBC_std;
                Total_MartellIntakeBtl+=MarginUseTotalVol_std;
                Total_MartellBlackCap += SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;   
            }
            
            ActualBlackCap +=  SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;

            
            
            String Mapkeystr= ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            Decimal CTDActualVol=0.0;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c;
            
            CTDActualVol=CTDActualVol.setScale(0);
            if(VolumeMap.containsKey(Mapkeystr)){
                VolumeObject TempObject= VolumeMap.get(Mapkeystr);
                TempObject.CTDActualVol +=CTDActualVol;
                VolumeMap.remove(Mapkeystr);
                VolumeMap.put(Mapkeystr, TempObject);
            }else{
                VolumeObject TempObject= new VolumeObject();
                TempObject.SubBrandGradeName=SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                TempObject.CTDActualVol=CTDActualVol;
                VolumeMap.put(Mapkeystr, TempObject);
            }
            
            Decimal   FC_actualvol_btl = 0;// Full Contract 
            if (SB_Vol_temp.ASI_CRM_T1_Depletion__c!= null) 
                FC_actualvol_btl = SB_Vol_temp.ASI_CRM_T1_Depletion__c;
            if (SB_Vol_temp.ASI_CRM_T2_Depletion__c!= null) 
                FC_actualvol_btl += SB_Vol_temp.ASI_CRM_T2_Depletion__c;
            if (SB_Vol_temp.ASI_CRM_PR_Direct__c!= null) 
                FC_actualvol_btl += SB_Vol_temp.ASI_CRM_PR_Direct__c;
            
            Date endDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(SB_Vol_temp.ASI_CRM_End_Date__c);
            String strkey = string.valueof(endDate) + SB_Vol_temp.ASI_CRM_Subbrand__c;

            if (v1_ROI_newMap.containskey(strkey)){
                if (v1_ROI_newMap.get(strkey).actual_vol != null)
                    v1_ROI_newMap.get(strkey).actual_vol += FC_actualvol_btl;
                else
                    v1_ROI_newMap.get(strkey).actual_vol = FC_actualvol_btl;
            }else{
                ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newDC1 = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
                newDC1.actual_vol = FC_actualvol_btl;
                newDC1.SubBrandId = SB_Vol_temp.ASI_CRM_Subbrand__c;
                v1_ROI_newMap.put(strkey, newDC1);
            }  
            
        }
        
        
        for (String  VolumeMapKey:VolumeMap.keySet()){
            if(VolumeMap.get(VolumeMapKey).FullContractTarget==0 && VolumeMap.get(VolumeMapKey).CTDActualVol==0){
                VolumeMap.remove(VolumeMapKey);
            }
        }
        
        
        
        if(ActualBCTotal != null && ActualBCTotal != 0 && ActualIntakeTotal != null && ActualIntakeTotal != 0){
            ActualPerformance.BCRate = (ActualBCTotal / ActualIntakeTotal)*100;
            ActualPerformance.NetBCRate = ( (ActualBCTotal-ActualBlackCap) / ActualIntakeTotal)*100;
        }
        
        if(Total_MartellBC != null && Total_MartellBC != 0 && Total_MartellIntakeBtl != null && Total_MartellIntakeBtl != 0){
            ActualPerformance.TotalMBCRate = (Total_MartellBC / Total_MartellIntakeBtl)*100;
            ActualPerformance.NetMBCRate= ( (Total_MartellBC - Total_MartellBlackCap ) / Total_MartellIntakeBtl)*100;
        }
        
        
        //VFinal ROI Actual Performance
        Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> CMGSBySubBrand = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        if (v1_ROI_newMap.size() > 0){
            decimal totalsb_cm_v1 = 0;
            decimal totalsb_gs_v1 = 0;
            decimal totalsb_lbcm_v1 = 0; 
            
            for (ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data sb_v1 : v1_ROI_newMap.values()){
                ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.containsKey(sb_v1.SubBrandId) ? CMGSBySubBrand.get(sb_v1.SubBrandId) : new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();

                Decimal actualcm = null;
                if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                    actualcm = sb_v1.actualCM;
                }else if (ActualCM_v1_map.containsKey(sb_v1.SubBrandId)){
                    actualcm = ActualCM_v1_map.get(sb_v1.SubBrandId);
                }
                
                if (sb_v1.actual_vol != null && actualcm != null){ 
                    totalsb_cm_v1 += sb_v1.actual_vol * actualcm;
                    CMGSData.CM += sb_v1.actual_vol * actualcm;
                }
                
                
                Decimal lbcm = null;
                if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                    lbcm = sb_v1.latestBudgetCM;
                }else if (lbcm_v1_map.containsKey(sb_v1.SubBrandId)){
                    lbcm = lbcm_v1_map.get(sb_v1.SubBrandId);
                }
                if (sb_v1.actual_vol != null && lbcm != null){ 
                    totalsb_lbcm_v1 += sb_v1.actual_vol * lbcm; 
                    CMGSData.latestBudgetCM += sb_v1.actual_vol * lbcm;
                }
                
                
                //GS
                Decimal actualgs = null;
                if (sb_v1.actualGS != null && sb_v1.actualGS != 0){
                    actualgs = sb_v1.actualGS;
                }else if (ActualGS_v1_map.containsKey(sb_v1.SubBrandId)){
                    actualgs = ActualGS_v1_map.get(sb_v1.SubBrandId);
                }
                if (sb_v1.actual_vol != null && actualgs != null){ 
                    totalsb_gs_v1 += sb_v1.actual_vol * actualgs;
                    CMGSData.GS += sb_v1.actual_vol * actualgs;
                }

                CMGSBySubBrand.put(sb_v1.SubBrandId, CMGSData);
            }
            
            //vFinal Actual Gross Sales %
            if (totalsb_gs_v1 != 0 && totalsb_gs_v1 != null && ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null) {
                ActualPerformance.GrossSalesTotal = totalsb_gs_v1;
                ActualPerformance.GrossSalesRate = ActualPerformance.TradeExpenses / ActualPerformance.GrossSalesTotal *100;
            }
            
            //vFinal Actual ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null && totalsb_cm_v1 != 0){
                ActualPerformance.CMTotal=totalsb_cm_v1;
                ActualPerformance.ROIIntake= totalsb_cm_v1 / ActualPerformance.TradeExpenses;
            }
            
            
            if(Vol_CR12_1!=null && Vol_CR12_1 !=0 && ActualPerformance.TradeExpenses !=null && ActualPerformance.TradeExpenses!=0 ){
                ActualPerformance.InvestmentCR12 = ActualPerformance.TradeExpenses/Vol_CR12_1;
            }
            //vFinal Actual Margin AP
            if (ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null){
                ActualPerformance.MarginAfterAnP = totalsb_cm_v1 - ActualPerformance.TradeExpenses;
            }
            
            
            //vFinal Actual Margin per Btl
            if (ActualIntakeTotal != null && ActualIntakeTotal != 0 &&  ActualPerformance.MarginAfterAnP!= null &&  ActualPerformance.MarginAfterAnP != 0){
                ActualPerformance.MarginPerBottle =  ActualPerformance.MarginAfterAnP / ActualIntakeTotal ;
            }
            
            //vFinal Actual Pro-Forma ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_lbcm_v1 != null && totalsb_lbcm_v1 != 0){
                ActualPerformance.LatestBudgetCMTotal=totalsb_lbcm_v1;
                ActualPerformance.ROIProForma = totalsb_lbcm_v1 / ActualPerformance.TradeExpenses;
            }
            
        }

        ActualPerformance.TradeExpenseBySubBrand = ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(thisPR, 'estimate', 'Last Payment');
        // Set CM/GS By Sub-Brand
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown tradeExpenseBreakdown : ActualPerformance.TradeExpenseBySubBrand) {
            if (!CMGSBySubBrand.containsKey(tradeExpenseBreakdown.subBrandId)) {
                continue;
            }
            ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.get(tradeExpenseBreakdown.subBrandId);

            tradeExpenseBreakdown.GSTotal = CMGSData.GS;
            tradeExpenseBreakdown.CMTotal = CMGSData.CM;
            tradeExpenseBreakdown.latestBudgetCMTotal = CMGSData.latestBudgetCM;
        }
        // Set fixCostTradeExpense By Sub-Brand
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown tradeExpenseBreakdown : ActualPerformance.TradeExpenseBySubBrand) {
            tradeExpenseBreakdown.fixCostTradeExpense = ActualPerformance.FixedExpense * tradeExpenseBreakdown.propByTotal;
        }

        ActualPerformance = ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(ActualPerformance);

        //**Finish 
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> returnList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();
        returnList.add(ActualPerformance);
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(thisPR.ASI_TH_CRM_Contract__c, System.JSON.serialize(returnList),'Last Payment Data' );
    }
    
    
    public static void  ReconstructLastPaymentFIData2nd(ASI_TH_CRM_PaymentRequest__c thisPR) {
        
        //**Finish 
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> returnList = ReconstructLastPaymentFIDataList2nd(thisPR);
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(thisPR.ASI_TH_CRM_Contract__c, System.JSON.serialize(returnList),'Last Payment Data' );
    }

    public static List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>  ReconstructLastPaymentFIDataList2nd(ASI_TH_CRM_PaymentRequest__c thisPR) {
        System.debug(LoggingLevel.INFO, '*** thisPR: ' + thisPR);
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        ASI_TH_CRM_Contract__c thisCC = ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(thisPR.ASI_TH_CRM_Contract__c);
        String channel = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
        String region = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        String cityInvestementGrade = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
        String newImage = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;

        date strStart;
        Date CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Map<String,VolumeObject> VolumeMap= new Map<String,VolumeObject>();
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd  ActualPerformance= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd(); 
        ActualPerformance.ContractId = thisPR.ASI_TH_CRM_Contract__c;
        ActualPerformance.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
        ActualPerformance.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
        ActualPerformance.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);

        Map<String, String> sbGroup_map = ASI_CRM_CN_HeavyContractUtilitiesClass.SUB_BRAND_GRADE_GROUPING_MAP;
        
        map<string, string> SubbrandGroup = new map<string, string>();
        SubbrandGroup.put('Premium', '1. Standard + Premium 标准档 + 高档');
        SubbrandGroup.put('Standard', '1. Standard + Premium 标准档 + 高档');
        SubbrandGroup.put('Prestige', '4. Prestige + Ultra Prestige 奢华档 + 特级奢华档');
        SubbrandGroup.put('Ultra Prestige', '4. Prestige + Ultra Prestige 奢华档 + 特级奢华档');
        SubbrandGroup.put('Super Premium', '2. Super Premium 超高档');
        SubbrandGroup.put('Ultra Premium', '3. Ultra Premium 特级高档');
        SubbrandGroup.put('Not Specified / 未指定','5. Not Specified / 未指定');
        
        map<string,decimal> RegionSubBrandCM_Map = new map<string,decimal>();
        set<id> v1_sbid_set = new set<id>(); //ActualPerformance
        
        
        for(String SBGName:sbGroup_map.keySet()){
            ActualPerformance.SubBrandGradeMap.put(SBGName,0.0); 
        }
        
        //Query all payment request with vFinal contract
        list<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest = new list<ASI_TH_CRM_PaymentRequest__c>();
        try{
            AllPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
                                 ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                                 ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c
                                 FROM ASI_TH_CRM_PaymentRequest__c
                                 WHERE ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c
                                 AND (id = :thisPR.id OR ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted'  OR ASI_TH_CRM_Status__c = 'Paid')];
        }catch(exception e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyPaymentCheckCtrl. RetrieveTotalPaidAmount  class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyContractUtilitiesClass',' function failed! with Payment Id: '+thisPR.id );
        }
        
        //Sum up previous payments amounts
        if (AllPaymentRequest.size() > 0){
            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
                if (allPR_temp.ASI_CRM_CN_Total_Payment__c != null){
                    ActualPerformance.TradeExpenses += allPR_temp.ASI_CRM_CN_Total_Payment__c;
                    
                    if(allPR_temp.ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On'){
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_Total_Variable_Amount__c!=NULL?allPR_temp.ASI_CRM_Total_Variable_Amount__c:0;
                    }else{
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                        ActualPerformance.VariableExpense +=allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;
                    }
                    
                }
            }
        }
        
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> PRLineItems = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        Set<String> ModuleIds = new Set<String>();
        try{
            //query All Payment Variable & Fixed Cost
            PRLineItems = [SELECT id, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
                           ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c, RecordTypeId,RecordType.DeveloperName,ASI_CRM_Adjustment__c,ASI_CRM_CN_Sub_Brand__c,
                           ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Cost__c, ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Actual_Payment__c,ASI_CRM_Module__r.ASI_CRM_Line_Type__c
                           FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c and (ASI_TH_CRM_Payment_Request__c =:thisPR.id OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR 
                                                                                                                                                                     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted'  OR
                                                                                                                                                                     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid')];
        }catch(exception e){
            PRLineItems = new list<ASI_TH_CRM_PaymentRequestLineItem__c >();
        }
        
        for ( ASI_TH_CRM_PaymentRequestLineItem__c  li_temp : PRLineItems ){
            if (li_temp.ASI_CRM_CN_Sub_Brand__c != null)
            {
                v1_sbid_set.add(li_temp.ASI_CRM_CN_Sub_Brand__c);
            }
            if(li_temp.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                if(li_temp.ASI_CRM_Module__r.ASI_CRM_Line_Type__c == 'Fixed' && !ModuleIds.contains(li_temp.ASI_CRM_Module__c)){
                    ModuleIds.add(li_temp.ASI_CRM_Module__c);
                    ActualPerformance.FixedExpense += li_temp.ASI_CRM_Module__r.ASI_CRM_Actual_Payment__c !=null? li_temp.ASI_CRM_Module__r.ASI_CRM_Actual_Payment__c :0;
                }
                // else{
                //     ActualPerformance.VariableExpense+= li_temp.ASI_TH_CRM_Amount__c!=null? li_temp.ASI_TH_CRM_Amount__c:0;
                // }
            }
        }
        if(ActualPerformance.TradeExpenses!=null && ActualPerformance.TradeExpenses !=0){
            ActualPerformance.FixedExpenseRate = (ActualPerformance.FixedExpense/ActualPerformance.TradeExpenses)*100;
        }
        
        
        
        
        decimal Vol_CR12_1 =0; //All Payment Period
        map<string, decimal> ActualCM_v1_map = new map<string, decimal>();
        map<string, decimal> ActualGS_v1_map= new map<string, decimal>();
        map<string, decimal> ActualAD_v1_map = new map<string, decimal>();
        //map<string, decimal> lbcm_v1_map= new map<string, decimal>();
        Decimal ActualIntakeTotal = 0;//for calculating bc%
        Decimal ActualBCTotal = 0;//for calculating bc%
        
        Decimal ActualBlackCap = 0;

        Decimal Total_MartellBC =0;  // total contract Martel BC
        Decimal Total_MartellIntakeBtl =0;  // total contract Martel Intake Btl
        Decimal Total_MartellBlackCap =0;  // total contract Martel BlackCap
        
        
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                             FROM ASI_CRM_CN_Covered_Outlet__c
                             WHERE ASI_CRM_CN_Contract__c = :thisPR.ASI_TH_CRM_Contract__c];
        }catch(exception e){
            CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }  
        set<id> AllOutlet = new set<id>();
        
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(thisPR.ASI_CRM_CN_OutletWS__c);
        }
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }
        
        system.debug('CutOffDay:' + CutOffDay);
        system.debug('thisPR.ASI_CRM_CN_PO_End_Date__c:' + thisPR.ASI_CRM_CN_PO_End_Date__c);
        system.debug(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));        
        date TillEnd = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        
        
        system.debug('Payment thisPR.ASI_CRM_CN_PO_Start_Date__c: '+thisPR.ASI_CRM_CN_PO_Start_Date__c);
        system.debug('Payment TillEnd: '+TillEnd);
        list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c> ();
        
        
        try{
            SB_Vol_List = [SELECT Id,Name,ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                           ASI_CRM_T1_Depletion_Std_Billing__c,ASI_CRM_DeductibleCapWithIssues_Std_Btl__c, ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_Std_Billing__c,
                           ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c,
                           ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c, ASI_CRM_Subbrand__c, 
                           ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,ASI_CRM_PR_Direct__c, 
                           ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                           ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c, ASI_CRM_Green_Cap_STD__c,
                           ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name
                           FROM ASI_CRM_Subbrand_Volume__c 
                           WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_End_Date__c <= :TillEnd  AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                           AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false and ASI_CRM_Subbrand__c !=null];
            
        }catch(exception e){
            SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c >();
        }
        
        
        list<ASI_CRM_CM_GS__c> ActualCM_List = new list<ASI_CRM_CM_GS__c>();
        map<date, decimal> V1_Period_map = ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(thisPR.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_CRM_CN_PO_End_Date__c);
        SYSTEM.debug('Now V1_Period_map: '+ V1_Period_map);
        map<string, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> v1_ROI_newMap = new map<string, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        
        if (SB_Vol_List.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : SB_Vol_List ){
                v1_sbid_set.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                String sbGradeName ='';
                String CategoryName = '';
                Decimal ActualVolumes=0;
                ActualVolumes+=SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
                ActualVolumes+=SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
                ActualVolumes+=SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;
                
                ActualPerformance.Volumes+=ActualVolumes;
                
                if (SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    if (SubbrandGroup.containskey(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                        sbGradeName = SubbrandGroup.get(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                    }else{
                        sbGradeName = 'Not Specified / 未指定';
                    }
                }else{
                    sbGradeName = 'Not Specified / 未指定';
                }
                
                if(ActualPerformance.SubBrandGradeMap.containskey(sbGradeName)){
                    Decimal TempVolumes=ActualPerformance.SubBrandGradeMap.get(sbGradeName)+ActualVolumes;
                    ActualPerformance.SubBrandGradeMap.remove(sbGradeName);//remove orignal one
                    ActualPerformance.SubBrandGradeMap.put(sbGradeName,TempVolumes); 
                }else{
                    ActualPerformance.SubBrandGradeMap.put(sbGradeName,ActualVolumes); 
                }
                

                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c !=null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    CategoryName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                } else {
                    CategoryName = 'Not Specified / 未指定';
                }

                if(ActualPerformance.CategoryMap.containsKey(CategoryName)){
                    Decimal TempVolumes=ActualPerformance.CategoryMap.get(CategoryName)+ActualVolumes;
                    //remove orignal one
                    ActualPerformance.CategoryMap.remove(CategoryName);
                    ActualPerformance.CategoryMap.put(CategoryName,TempVolumes);
                }else{
                    ActualPerformance.CategoryMap.put(CategoryName,ActualVolumes);
                }
            }
        }

        // get latest Budget CM for all Sub-Brands
        string currentFY = String.valueOf(ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(date.Today()).Year());
        string currentFY2 = (integer.valueOf(currentFY) - 1) + '';
        string currentFY3 = (integer.valueOf(currentFY) - 2) + '';
        system.debug('currentFY'+currentFY);
        system.debug('currentFY2'+currentFY2);
        system.debug('currentFY3'+currentFY3);
        string ProductCode;
        decimal cm;
        for (ASI_CRM_CM_GS__c lbcm : [SELECT id, ASI_CRM_YEAR__c,ASI_CRM_CM_GS_per_9L__c,ASI_CRM_PRODUCTCODE__r.name, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c, ASI_CRM_CN_Month__c,ASI_CRM_TYPE__c FROM ASI_CRM_CM_GS__c WHERE ASI_CRM_CN_Month__c = 6 
                                      AND ASI_CRM_Region__c = : thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                      AND (ASI_CRM_YEAR__c = :currentFY  OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) AND ASI_CRM_PRODUCTCODE__c in: v1_sbid_set
                                      AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS' OR ASI_CRM_TYPE__c = 'Budget A&D')
                                      AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0  
                                      AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
                                      ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        { 
            ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c == null){
                cm = 0;
            }else{
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
            }
            if(!RegionSubBrandCM_Map.containsKey(ProductCode + lbcm.ASI_CRM_TYPE__c) && cm != Null && cm != 0){
                RegionSubBrandCM_Map.put(ProductCode + lbcm.ASI_CRM_TYPE__c,cm);
            }
            
        }
        
        if (V1_Period_map.size() > 0){
            string strkey;
            for (date v1temp : V1_Period_map.keyset()){
                if (v1_sbid_set.size() > 0){
                    for (id sbtemp : v1_sbid_set){
                        strkey = string.valueof(v1temp) + sbtemp;
                        ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
                        newitem.period = V1_Period_map.get(v1temp);
                        newitem.SubBrandId = sbtemp;
                        newitem.year = string.valueof(v1temp.year());
                        newitem.totalVolume = 0;
                        
                        if (!v1_ROI_newMap.containskey(strkey)){
                            v1_ROI_newMap.put(strkey, newitem);
                        }
                    }
                }
            }
        }
        
        date strV1End = ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN');
        
        //V0ContractId
        ASI_TH_CRM_Contract__c Contractv0 =new ASI_TH_CRM_Contract__c();
        
        date strEnd;
        String V0ContractId='';
        if(thisPR.ASI_TH_CRM_Contract__c!=null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(thisPR.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__c;
        }
        if (V0ContractId != null && V0ContractId != ''){
            Contractv0 = [SELECT ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c  FROM ASI_TH_CRM_Contract__c WHERE id = :V0ContractId];
        }
        if (Contractv0.ASI_CRM_CN_PO_Start_Date__c !=null ){
            strStart = Contractv0.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        }else{
            strStart = thisPR.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        }
        
        
        strStart=ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(strStart);
        
        system.debug('234'+v1_sbid_set+'ActualCM Now strStart '+strStart);
        system.debug('ActualCM Now strV1End '+strV1End);
        
        try{
            ActualCM_List = [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                             ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_TYPE__c 
                             FROM ASI_CRM_CM_GS__c
                             WHERE ASI_CRM_PRODUCTCODE__c IN :v1_sbid_set
                             AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                             AND ASI_CRM_CN_Month_End_Date__c >= :strStart
                             AND ASI_CRM_CN_Month_End_Date__c <= :strV1End 
                             AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS' OR ASI_CRM_TYPE__c = 'YTD A&D')
                             AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0
                             AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
                             ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
        }catch(exception e){
            ActualCM_List = new list<ASI_CRM_CM_GS__c>();
        }
        
        
        
        if (ActualCM_List.size() > 0){ 
            string strkey;
            string subbrand_id;
            string lastestkey;
            for (ASI_CRM_CM_GS__c ACM_temp : ActualCM_List){
                subbrand_id = ACM_temp.ASI_CRM_PRODUCTCODE__c;
                strkey = string.valueof(ACM_temp.ASI_CRM_CN_Month_End_Date__c) + subbrand_id;
                
                decimal ActualCMperBtl = null;
                if (ACM_temp.ASI_CRM_CM_GS_per_9L__c != null){
                    ActualCMperBtl = ACM_temp.ASI_CRM_CM_GS_per_9L__c;  
                }
                
                lastestkey = subbrand_id;
                if (ACM_temp.ASI_CRM_TYPE__c == 'YTD CM'){
                    if (!ActualCM_v1_map.containskey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0){//system.debug('Now Put '+lastestkey+' ActualCMperBtl : '+ActualCMperBtl);
                        ActualCM_v1_map.put(lastestkey, ActualCMperBtl);
                    }
                    if (v1_ROI_newMap.containskey(strkey)){
                        if ((v1_ROI_newMap.get(strkey).actualCM == null || v1_ROI_newMap.get(strkey).actualCM == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0){
                            v1_ROI_newMap.get(strkey).actualCM = ActualCMperBtl; //v1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                        } 
                    }
                }
                if (ACM_temp.ASI_CRM_TYPE__c == 'YTD GS'){
                    if (!ActualGS_v1_map.containskey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0){//system.debug('Now Put '+lastestkey+' ActualCMperBtl : '+ActualCMperBtl);
                        ActualGS_v1_map.put(lastestkey, ActualCMperBtl);
                    }
                    
                    if (v1_ROI_newMap.containskey(strkey)){
                        if ((v1_ROI_newMap.get(strkey).actualGS == null || v1_ROI_newMap.get(strkey).actualGS == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0){
                            v1_ROI_newMap.get(strkey).actualGS = ActualCMperBtl;
                        }
                    }
                }
                if (ACM_temp.ASI_CRM_TYPE__c == 'YTD A&D'){
                    if (!ActualAD_v1_map.containskey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0){//system.debug('Now Put '+lastestkey+' ActualCMperBtl : '+ActualCMperBtl);
                        ActualAD_v1_map.put(lastestkey, ActualCMperBtl);
                    }
                    
                    if (v1_ROI_newMap.containskey(strkey)){
                        if ((v1_ROI_newMap.get(strkey).actualAD == null || v1_ROI_newMap.get(strkey).actualAD == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0){
                            v1_ROI_newMap.get(strkey).actualAD = ActualCMperBtl;
                        }
                    }
                }
                
                // if (!lbcm_v1_map.containskey(lastestkey))
                //     if ( RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c)) {
                //         lbcm_v1_map.put(lastestkey, RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c));
                //     }
                
                
                if (v1_ROI_newMap.containskey(strkey)){
                    if (v1_ROI_newMap.get(strkey).latestbudgetCM == null || v1_ROI_newMap.get(strkey).latestbudgetCM == 0){
                        if (RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c + 'Budget CM')) {
                            v1_ROI_newMap.get(strkey).latestbudgetCM = RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c + 'Budget CM');
                        }
                    }

                    if (v1_ROI_newMap.get(strkey).latestbudgetGS == null || v1_ROI_newMap.get(strkey).latestbudgetGS == 0){
                        if (RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c + 'Budget GS')) {
                            v1_ROI_newMap.get(strkey).latestbudgetGS = RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c + 'Budget GS');
                        }
                    }

                    if (v1_ROI_newMap.get(strkey).latestbudgetAD == null || v1_ROI_newMap.get(strkey).latestbudgetAD == 0){
                        if (RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c + 'Budget A&D')) {
                            v1_ROI_newMap.get(strkey).latestbudgetAD = RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c + 'Budget A&D');
                        }
                    }
                }
                
            }
        }
        
        //Looping Sub-brand Volume
        for (ASI_CRM_Subbrand_Volume__c  SB_Vol_temp : SB_Vol_List){
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c:0;
            
            Decimal  MarginUseTotalVol_std = 0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_PR_Direct_STD__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c:0;
            ActualIntakeTotal += MarginUseTotalVol_std;
            
            Decimal  ActualBC_std = 0;
            
            ActualBC_std += SB_Vol_temp.ASI_CRM_Green_Cap_STD__c != null? SB_Vol_temp.ASI_CRM_Green_Cap_STD__c:0;
            ActualBC_std += SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Btl__c != null? SB_Vol_temp.ASI_CRM_Empty_Bottle_Std_Btl__c:0;
            ActualBC_std += SB_Vol_temp.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c != null? SB_Vol_temp.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c:0;
            ActualBCTotal += ActualBC_std ;
            
            if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){
                system.debug('Now Martell: ActualBC_std: '+ActualBC_std + ' MarginUseTotalVol_std : ' + MarginUseTotalVol_std);
                Total_MartellBC += ActualBC_std;
                Total_MartellIntakeBtl+=MarginUseTotalVol_std;
                Total_MartellBlackCap += SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;   
            }
            
            ActualBlackCap +=  SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SB_Vol_temp.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;

            
            
            String Mapkeystr= ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            Decimal CTDActualVol=0.0;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c;
            
            CTDActualVol=CTDActualVol.setScale(0);
            if(VolumeMap.containsKey(Mapkeystr)){
                VolumeObject TempObject= VolumeMap.get(Mapkeystr);
                TempObject.CTDActualVol +=CTDActualVol;
                VolumeMap.remove(Mapkeystr);
                VolumeMap.put(Mapkeystr, TempObject);
            }else{
                VolumeObject TempObject= new VolumeObject();
                TempObject.SubBrandGradeName=SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                TempObject.CTDActualVol=CTDActualVol;
                VolumeMap.put(Mapkeystr, TempObject);
            }
            
            Decimal   FC_actualvol_btl = 0;// Full Contract 
            if (SB_Vol_temp.ASI_CRM_T1_Depletion__c!= null) 
                FC_actualvol_btl = SB_Vol_temp.ASI_CRM_T1_Depletion__c;
            if (SB_Vol_temp.ASI_CRM_T2_Depletion__c!= null) 
                FC_actualvol_btl += SB_Vol_temp.ASI_CRM_T2_Depletion__c;
            if (SB_Vol_temp.ASI_CRM_PR_Direct__c!= null) 
                FC_actualvol_btl += SB_Vol_temp.ASI_CRM_PR_Direct__c;
            
            Date endDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(SB_Vol_temp.ASI_CRM_End_Date__c);
            String strkey = string.valueof(endDate) + SB_Vol_temp.ASI_CRM_Subbrand__c;

            if (v1_ROI_newMap.containskey(strkey)){
                if (v1_ROI_newMap.get(strkey).actual_vol != null)
                    v1_ROI_newMap.get(strkey).actual_vol += FC_actualvol_btl;
                else
                    v1_ROI_newMap.get(strkey).actual_vol = FC_actualvol_btl;
            }else{
                ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newDC1 = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
                newDC1.actual_vol = FC_actualvol_btl;
                newDC1.SubBrandId = SB_Vol_temp.ASI_CRM_Subbrand__c;
                v1_ROI_newMap.put(strkey, newDC1);
            }  
            
        }
        
        
        for (String  VolumeMapKey:VolumeMap.keySet()){
            if(VolumeMap.get(VolumeMapKey).FullContractTarget==0 && VolumeMap.get(VolumeMapKey).CTDActualVol==0){
                VolumeMap.remove(VolumeMapKey);
            }
        }
        
        
        
        if(ActualBCTotal != null && ActualBCTotal != 0 && ActualIntakeTotal != null && ActualIntakeTotal != 0){
            ActualPerformance.BCRate = (ActualBCTotal / ActualIntakeTotal)*100;
            ActualPerformance.NetBCRate = ( (ActualBCTotal-ActualBlackCap) / ActualIntakeTotal)*100;
        }
        
        if(Total_MartellBC != null && Total_MartellBC != 0 && Total_MartellIntakeBtl != null && Total_MartellIntakeBtl != 0){
            ActualPerformance.TotalMBCRate = (Total_MartellBC / Total_MartellIntakeBtl)*100;
            ActualPerformance.NetMBCRate= ( (Total_MartellBC - Total_MartellBlackCap ) / Total_MartellIntakeBtl)*100;
        }

        AdditionalFIMap.put('Total_MartellBC',Total_MartellBC);
        AdditionalFIMap.put('Total_MartellIntakeBtl',Total_MartellIntakeBtl);
        AdditionalFIMap.put('Total_MartellBlackCap',Total_MartellBlackCap);


        AdditionalFIMap.put('TotalBackCap',ActualBlackCap);
        AdditionalFIMap.put('TotalBC',ActualBCTotal);
        AdditionalFIMap.put('Total_IntakeBtl',ActualIntakeTotal);

        AdditionalFIMap.put('TotalBlackCap_prorate',ActualBlackCap);
        AdditionalFIMap.put('TotalBC_prorate',ActualBCTotal);
        AdditionalFIMap.put('Total_IntakeBtl_prorate',ActualIntakeTotal);
        
        
        //VFinal ROI Actual Performance
        Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> CMGSBySubBrand = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        if (v1_ROI_newMap.size() > 0){
            decimal totalsb_cm_v1 = 0;
            decimal totalsb_lbcm_v1 = 0; 
            decimal totalsb_gs_v1 = 0;
            decimal totalsb_lbgs_v1 = 0;
            decimal totalsb_ad_v1 = 0;
            decimal totalsb_lbad_v1 = 0; 
            
            
            for (ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data sb_v1 : v1_ROI_newMap.values()){
                ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.containsKey(sb_v1.SubBrandId) ? CMGSBySubBrand.get(sb_v1.SubBrandId) : new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();

                Decimal actualcm = null;
                if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                    actualcm = sb_v1.actualCM;
                }else if (ActualCM_v1_map.containsKey(sb_v1.SubBrandId)){
                    actualcm = ActualCM_v1_map.get(sb_v1.SubBrandId);
                }
                
                if (sb_v1.actual_vol != null && actualcm != null){ 
                    totalsb_cm_v1 += sb_v1.actual_vol * actualcm;
                    CMGSData.CM += sb_v1.actual_vol * actualcm;
                }
                
                
                Decimal lbcm = null;
                if (sb_v1.latestBudgetCM != null && sb_v1.latestBudgetCM != 0){
                    lbcm = sb_v1.latestBudgetCM;
                }else if (RegionSubBrandCM_Map.containsKey(sb_v1.SubBrandId + 'Budget CM')){
                    lbcm = RegionSubBrandCM_Map.get(sb_v1.SubBrandId + 'Budget CM');
                }
                if (sb_v1.actual_vol != null && lbcm != null){ 
                    totalsb_lbcm_v1 += sb_v1.actual_vol * lbcm; 
                    CMGSData.latestBudgetCM += sb_v1.actual_vol * lbcm;
                }
                
                
                //GS
                Decimal actualgs = null;
                if (sb_v1.actualGS != null && sb_v1.actualGS != 0){
                    actualgs = sb_v1.actualGS;
                }else if (ActualGS_v1_map.containsKey(sb_v1.SubBrandId)){
                    actualgs = ActualGS_v1_map.get(sb_v1.SubBrandId);
                }
                if (sb_v1.actual_vol != null && actualgs != null){ 
                    totalsb_gs_v1 += sb_v1.actual_vol * actualgs;
                    CMGSData.GS += sb_v1.actual_vol * actualgs;
                }

                Decimal lbgs = null;
                if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                    lbgs = sb_v1.latestBudgetCM;
                }else if (RegionSubBrandCM_Map.containsKey(sb_v1.SubBrandId + 'Budget GS')){
                    lbgs = RegionSubBrandCM_Map.get(sb_v1.SubBrandId + 'Budget GS');
                }
                if (sb_v1.actual_vol != null && lbgs != null){ 
                    totalsb_lbgs_v1 += sb_v1.actual_vol * lbgs; 
                    CMGSData.latestBudgetGS += sb_v1.actual_vol * lbgs;
                }

                //A&D
                Decimal actualad = null;
                if (sb_v1.actualAD != null && sb_v1.actualAD != 0){
                    actualad = sb_v1.actualAD;
                }else if (ActualAD_v1_map.containsKey(sb_v1.SubBrandId)){
                    actualad = ActualAD_v1_map.get(sb_v1.SubBrandId);
                }
                if (sb_v1.actual_vol != null && actualad != null){ 
                    totalsb_ad_v1 += sb_v1.actual_vol * actualad;
                    CMGSData.AD += sb_v1.actual_vol * actualad;
                }

                Decimal lbad = null;
                if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                    lbad = sb_v1.latestBudgetAD;
                }else if (RegionSubBrandCM_Map.containsKey(sb_v1.SubBrandId + 'Budget A&D')){
                    lbad = RegionSubBrandCM_Map.get(sb_v1.SubBrandId + 'Budget A&D');
                }
                if (sb_v1.actual_vol != null && lbad != null){ 
                    totalsb_lbad_v1 += sb_v1.actual_vol * lbad; 
                    CMGSData.latestBudgetAD += sb_v1.actual_vol * lbad;
                }

                CMGSBySubBrand.put(sb_v1.SubBrandId, CMGSData);
            }
            
            //vFinal Actual Gross Sales %
            if (totalsb_gs_v1 != 0 && totalsb_gs_v1 != null && ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null) {
                ActualPerformance.GrossSalesTotal = totalsb_gs_v1;
                ActualPerformance.GrossSalesRate = (ActualPerformance.TradeExpenses / ActualPerformance.GrossSalesTotal *100).setScale(2);
            }

            //vFinal GrossSalesTotal ProForma
            if (totalsb_lbgs_v1 != 0 && totalsb_lbgs_v1 != null && ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null){
                ActualPerformance.GrossSalesTotalProForma = totalsb_lbgs_v1;
                ActualPerformance.GrossSalesRateProForma = (ActualPerformance.TradeExpenses / ActualPerformance.GrossSalesTotalProForma *100).setScale(2);
            }

            //vFinal ADTotal & ADTotal ProForma
            if (totalsb_ad_v1 != 0 && totalsb_ad_v1 != null ){
                ActualPerformance.ADTotal =  totalsb_ad_v1;
            }
            if (totalsb_lbad_v1 != 0 && totalsb_lbad_v1 != null ){
                ActualPerformance.ADTotalProForma  = totalsb_lbad_v1;
            }
            
            
            //vFinal Actual ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null && totalsb_cm_v1 != 0){
                ActualPerformance.CMTotal=totalsb_cm_v1;
                ActualPerformance.ROIIntake= totalsb_cm_v1 / ActualPerformance.TradeExpenses;
            }
            
            
            if(Vol_CR12_1!=null && Vol_CR12_1 !=0 && ActualPerformance.TradeExpenses !=null && ActualPerformance.TradeExpenses!=0 ){
                ActualPerformance.IntakeCR12 = Vol_CR12_1;
                ActualPerformance.InvestmentCR12 = ActualPerformance.TradeExpenses/Vol_CR12_1;
            }
            //vFinal Actual Margin AP
            if (ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null){
                ActualPerformance.MarginAfterAnP = totalsb_cm_v1 - ActualPerformance.TradeExpenses;
            }

            //vFinal Actual Margin AP proform
            if (ActualPerformance.TradeExpenses != null && totalsb_lbcm_v1 != null){
                ActualPerformance.MarginAfterAnPProForma = totalsb_lbcm_v1 - ActualPerformance.TradeExpenses;
            }
            
            //vFinal Actual Margin per Btl
            if (ActualIntakeTotal != null && ActualIntakeTotal != 0 &&  ActualPerformance.MarginAfterAnP!= null &&  ActualPerformance.MarginAfterAnP != 0){
                ActualPerformance.IntakeSTD = ActualIntakeTotal;
                ActualPerformance.MarginPerBottle =  ActualPerformance.MarginAfterAnP / ActualIntakeTotal ;
            }

            //vFinal Margin Per Bottle proforma
            if (ActualIntakeTotal != null && ActualIntakeTotal != 0 &&  ActualPerformance.MarginAfterAnPProForma!= null &&  ActualPerformance.MarginAfterAnPProForma != 0){
                ActualPerformance.MarginPerBottleProForma =  ActualPerformance.MarginAfterAnPProForma / ActualIntakeTotal ;
            }
            
            //vFinal Actual Pro-Forma ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_lbcm_v1 != null && totalsb_lbcm_v1 != 0){
                ActualPerformance.LatestBudgetCMTotal=totalsb_lbcm_v1;
                ActualPerformance.ROIProForma = totalsb_lbcm_v1 / ActualPerformance.TradeExpenses;
            }
            
        }

        ActualPerformance.AddOnString = System.JSON.serialize(AdditionalFIMap);

        ActualPerformance.TradeExpenseBySubBrand = ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(thisPR, 'estimate', 'Last Payment');
        // Set CM/GS By Sub-Brand
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd tradeExpenseBreakdown : ActualPerformance.TradeExpenseBySubBrand) {
            if (!CMGSBySubBrand.containsKey(tradeExpenseBreakdown.subBrandId)) {
                continue;
            }
            ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.get(tradeExpenseBreakdown.subBrandId);

            tradeExpenseBreakdown.GSTotal = CMGSData.GS;
            tradeExpenseBreakdown.CMTotal = CMGSData.CM;
            tradeExpenseBreakdown.latestBudgetCMTotal = CMGSData.latestBudgetCM;
        }
        // Set fixCostTradeExpense By Sub-Brand
        // for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown tradeExpenseBreakdown : ActualPerformance.TradeExpenseBySubBrand) {
        //     tradeExpenseBreakdown.fixCostTradeExpense = ActualPerformance.FixedExpense * tradeExpenseBreakdown.propByTotal;
        // }

        ActualPerformance = ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(ActualPerformance);

        //**************************Calculation 2nd KPI Sub-brand Trade Expense**************************
        Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());

        //Domestic Target
        Map<String, ASI_CRM_CM_GS__c>  DomesticTargetMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(setDate,v1_sbid_set);
        //Regional Target
        Map<String, ASI_CRM_CM_GS__c> RegionalAverageMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,v1_sbid_set);

        ActualPerformance = ASI_CRM_CN_HeavyContractUtilitiesClass.calculatedTradeExpense(ActualPerformance,DomesticTargetMap,RegionalAverageMap,RegionSubBrandCM_Map);
        //**************************Calculation 2nd KPI Sub-brand Trade Expense end**************************


        //**Finish 
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> returnList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        returnList.add(ActualPerformance);
        return returnList;
    }
    
    
    public Static date getFiscalYearStart(Date inputDate){        
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Date fiscalYearStart;
        if(inputDate != null){            
            fiscalYearStart = Date.newinstance(inputDate.year(), orgFiscalMonth, 1);
            if(inputDate.month() < orgFiscalMonth && inputDate.year() == inputDate.year())
                fiscalYearStart = fiscalYearStart.addYears(-1);
        }
        System.debug(inputDate + '/' + fiscalYearStart);
        return fiscalYearStart;
    }
    
    
    //******************Last Payment Auto PO Modification*****************
    public Static void LastPaymentAutoPOModification(ASI_TH_CRM_Contract__c Contract,Date PaymentCutOffDate){
        //clone contract as archived po
        ASI_TH_CRM_Contract__c ContractCloned  =ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        
        
        //****update exsiting PO****
        Contract.ASI_CRM_CN_Last_PO_version__c=ContractCloned.id;
        
        
        
        //Contract.ASI_CRM_CN_Status__c = 'Final';
        if(Contract.ASI_CRM_CN_PO_Version__c=='0.0'){
            Contract.ASI_CRM_CN_V0_0_PO_version__c=ContractCloned.id;
        }
        List<String> poVersionSplit = contract.ASI_CRM_CN_PO_Version__c.split('\\.',0);
        if(poVersionSplit != null && poVersionSplit.size() ==2){
            Contract.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1])+1);
        }
        
        //2019/10/30 CanterDuan 注释原因：由于INC0106302 Issue，所以需要对ASI_CRM_CN_PO_End_Date__c的逻辑进行修改 start
        //if(PaymentCutOffDate!=null){
        //   Contract.ASI_CRM_CN_PO_End_Date__c =PaymentCutOffDate;
        //}else{
        //   Contract.ASI_CRM_CN_PO_End_Date__c = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        //}

        //Set cut off Date
        PaymentCutOffDate = PaymentCutOffDate != null ? PaymentCutOffDate : ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Contract.ASI_CRM_CN_PO_End_Date__c = PaymentCutOffDate < Contract.ASI_CRM_CN_PO_End_Date__c ?  PaymentCutOffDate : Contract.ASI_CRM_CN_PO_End_Date__c;
        //2019/10/30 CanterDuan End
        
        
        if(Contract.ASI_CRM_CN_PO_Start_Date__c != null){
            if(Contract.ASI_CRM_CN_PO_Start_Date__c <getFiscalYearStart(system.today()).addYears(1)){ 
                Contract.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
            }
            else{
                Contract.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(Contract.ASI_CRM_CN_PO_Start_Date__c);
            }
        }else{
            Contract.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
        }
        
        
        
        Contract.ASI_CRM_Copied_From__c=ContractCloned.Id; // Previous Contract
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c= Datetime.now();
        Contract.ASI_CRM_CN_PO_Modification__c = true;
        //Contract.ASI_CRM_CN_Contract_Upload__c=False;
        update Contract;
        
        
        ASI_TH_CRM_Contract__c SelectContract= [select Id,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_Effective_Date__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Description__c,ASI_CRM_Copied_From__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Contract_Upload__c,ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grand_Estimate_Total__c
                                                from ASI_TH_CRM_Contract__c WHERE id =:Contract.Id ];
        
        
        //****************** get Payment info **************************************************
        Decimal BRSFPaidAmount=0;
        Decimal PSFPaidAmount=0;
        Decimal VECPaidAmount=0;
        Map<String,Decimal> FixedCostMap= new Map<String,Decimal>();
        
        for(ASI_TH_CRM_PaymentRequestLineItem__c payline:[SELECT id, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                                          ASI_CRM_Over_Incentive__c,ASI_CRM_Suggested_Value__c,ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                                          ASI_TH_CRM_Payment_Request__c,ASI_CRM_Volume_Base__c ,ASI_CRM_Product_Category__c,ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_CTD_Actual_Vol__c , ASI_CRM_CN_Standard__c ,ASI_CRM_CTD_Cap_Collection_Vol__c , ASI_CRM_CN_Payable_Vol__c  , ASI_CRM_Key_Sub_Brand__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_V0_0_Full_Contract_Target__c, ASI_CRM_CN_Total_Payable__c , ASI_CRM_CN_Actual_Vol__c , ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c ,ASI_CRM_CN_Incentive_BT__c , ASI_CRM_CN_Allow_Changing_Incentive__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Module__c ,ASI_CRM_CN_Sub_Brand__c,RecordType.DeveloperName, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, recordtypeid , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c 
                                                          FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                                                          WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:contract.Id 
                                                          and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c!='Draft' and
                                                          RecordType.DeveloperName='ASI_CRM_CN_Payment_Request_Detail_Other' ])
        {
            if(payline.ASI_CRM_CN_AC_Code__c!=null && payline.ASI_TH_CRM_Amount__c!=null){
                if(FixedCostMap.containsKey(payline.ASI_CRM_CN_AC_Code__c)){
                    Decimal TempAmount=FixedCostMap.get(payline.ASI_CRM_CN_AC_Code__c)+payline.ASI_TH_CRM_Amount__c;
                    FixedCostMap.remove(payline.ASI_CRM_CN_AC_Code__c);
                    FixedCostMap.put(payline.ASI_CRM_CN_AC_Code__c,TempAmount);
                }else{
                    FixedCostMap.put(payline.ASI_CRM_CN_AC_Code__c,payline.ASI_TH_CRM_Amount__c);
                }
            }
        }
        
        
        List<ASI_CRM_Contract_Cost__c> LFixCost= new List<ASI_CRM_Contract_Cost__c>();
        for(ASI_CRM_Contract_Cost__c cc:[Select id, name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, 
                                         ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c 
                                         from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :contract.Id])
        {
            if(cc.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                if(FixedCostMap.containsKey(cc.ASI_CRM_CN_Activity_Code__c)){
                    cc.ASI_CRM_CN_Estimate_Amount__c=FixedCostMap.get(cc.ASI_CRM_CN_Activity_Code__c);
                }
                LFixCost.add(cc);
            }
        }
        
        
        //Update Contract Fix cost
        if(LFixCost.size()>0){
            update LFixCost;
        }
        
        
        Map<String,Decimal> PSFPaidMap = new Map<String,Decimal>();
        
        //Calculate actual paid amount
        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : [select Id,Name,ASI_TH_CRM_Status__c,
                                                           (select Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Parent_Module__c from ASI_CRM_Modules__r) 
                                                           from ASI_TH_CRM_PaymentRequest__c
                                                           where ASI_TH_CRM_Contract__c = :contract.Id and ASI_TH_CRM_Status__c!='Draft'  ])
        {
            for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
                if(module.ASI_CRM_Line_Type__c=='BRSF'){
                    BRSFPaidAmount+=module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                }
                if(module.ASI_CRM_Line_Type__c=='PSF'){
                    PSFPaidAmount+=module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                    if(PSFPaidMap.containsKey(module.ASI_CRM_Parent_Module__c)){
                        
                        Decimal TempAmount =   module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                        TempAmount += PSFPaidMap.get(module.ASI_CRM_Parent_Module__c) ;
                        PSFPaidMap.remove(module.ASI_CRM_Parent_Module__c);
                        PSFPaidMap.put(module.ASI_CRM_Parent_Module__c, TempAmount);
                    }else{
                       PSFPaidMap.put(module.ASI_CRM_Parent_Module__c, module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0 ); 
                    }
                    
                }
                if(module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    VECPaidAmount +=module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                }
            }
        }
        //***********************************Finish Getting Payment Info ********************************************
        
        
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpdatedDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        //current version Contract Line
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines =[SELECT Id,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                          WHERE ASI_CRM_CN_Contract__c = :contract.Id ] ;
        
        
        map<String,interimData> ContractLineItem_Map = new map<String,interimData> ();
        
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractDetailLines){
            //by Line Type(BRSF/PSF/VEC) + Module Id
            if(ContractLineItem_Map.containsKey(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c)){
                ContractLineItem_Map.get(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c).DetailLineMap.put(ContractLine.Id,ContractLine);
            }else{//New 
                ASI_CRM_Module__c TempModule= new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c=ContractLine.ASI_CRM_Volume_Base__c,ASI_CRM_Line_Type__c=ContractLine.ASI_CRM_Type__c);
                
                interimData TempData= new interimData(TempModule);
                TempData.DetailLineMap.put(ContractLine.Id,ContractLine);
                ContractLineItem_Map.put(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c, TempData);
                
            }
        }
        
        Decimal BRSFEstimateAmount=0;
        Decimal VECEstimateAmount=0;
        Decimal PSFEstimateAmount=0;
        
        Decimal PSFContractAmount=0;
        
        Decimal PSFPreviousEstimateAmount=0;
        
        
        
        Decimal DiffMonth = SelectContract.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c-SelectContract.ASI_CRM_CN_No_of_Months__c;
        Id subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1].id;
        Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        
        for(String HeaderKey:ContractLineItem_Map.keySet()){
            Decimal EstimateAmount=0;// For BRSF VEC Use
            ASI_CRM_CN_Contract_BRSF_Line_Item__c AjustmentLine =new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=contract.Id ,
                                                                                                           ASI_CRM_Adjustment_Line__c=true,
                                                                                                           recordTypeId=BRSFLineRtId, ASI_CRM_CN_Sub_Brand__c = subbrand999,
                                                                                                           ASI_CRM_CN_Est_Monthly_Qty__c = 0,ASI_CRM_CN_Contract_Monthly_Qty__c=0,
                                                                                                           ASI_CRM_CN_Est_Total_Dummy__c=0,
                                                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=0,
                                                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0);
            String PSFBySubBrandModuleId='';  
            Decimal PSFAmount_BySubBrand=0;
            //looping every contract Line
            for(String keyline:ContractLineItem_Map.get(HeaderKey).DetailLineMap.keySet()){
                
                
                ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine =ContractLineItem_Map.get(HeaderKey).DetailLineMap.get(keyline);
                AjustmentLine.ASI_CRM_Type__c=ContractLine.ASI_CRM_Type__c!=null? ContractLine.ASI_CRM_Type__c : 'BRSF';
                if(ContractLine.ASI_CRM_Module__c!=null){
                    AjustmentLine.ASI_CRM_Module__c = ContractLine.ASI_CRM_Module__c ;
                }
                
                
                if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                    PSFBySubBrandModuleId= ContractLine.ASI_CRM_Module__c!=null? ContractLine.ASI_CRM_Module__c:'';
                    if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                        PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                    //if this contarct line is 999-line, save the id
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c =='999'){
                        AjustmentLine.Id=ContractLine.Id;
                    }else{//if this contarct line is not 999-line, perform calculation
                        ContractLine.ASI_CRM_CN_Est_Total_Dummy__c= ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        PSFAmount_BySubBrand+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                        //AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c += (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*DiffMonth: 0;
                        //AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c	 += (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*DiffMonth: 0;
                        UpdatedDetailLines.add(ContractLine);
                        
                        if(ContractLine.ASI_CRM_Type__c=='BRSF' || ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
                            EstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            
                        }
                        
                    }                    
                }else{
                    ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    UpdatedDetailLines.add(ContractLine);
                    
                    if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                        PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0; 
                    }
                    if(ContractLine.ASI_CRM_Type__c=='BRSF' || ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
                        EstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        
                    }
                }
                
                
               
                
                if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                    PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    
                }
            }// end of looping this Module
            
            if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                system.debug('BRSF PaidAmount : '+BRSFPaidAmount);
                system.debug('BRSF EstimateAmount : '+EstimateAmount);
                AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c=BRSFPaidAmount-EstimateAmount;
            }else if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='PSF' && PSFBySubBrandModuleId!=''){
                if(PSFPaidMap.containsKey(PSFBySubBrandModuleId)){
                     AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = PSFPaidMap.get(PSFBySubBrandModuleId) - PSFAmount_BySubBrand;
                }
            }else if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                system.debug('VECPaidAmount : '+VECPaidAmount);
                system.debug('VEC EstimateAmount : '+EstimateAmount);
                AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c =VECPaidAmount-EstimateAmount;
            }
            
            
            //PSFPaidMap
            
            system.debug('EstimateAmount : '+EstimateAmount);
            system.debug('**********AjustmentLine*********'+AjustmentLine.ASI_CRM_Type__c);
            system.debug(AjustmentLine);
            
            //checking if need to create/update 999-Line 
            if(AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c !=0 || AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c!=0 || (AjustmentLine.Id!=NULL && ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='Variable Event Cost' ) )  {
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                    BRSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='PSF' ){
                    PSFContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    PSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }
                
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    //VECContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    VECEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }
                
                UpdatedDetailLines.add(AjustmentLine);
            }
            
            
            
            
        }//Ending of Contract Line looping
        
        
        //update exsting contract Line
        if(UpdatedDetailLines.size()>0){
            Upsert UpdatedDetailLines;
        }
        
         if(SelectContract.ASI_CRM_Copied_From__c!=null && SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c !=null){
            PSFPreviousEstimateAmount=SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c: 0 ;
        }

        /*
        if(SelectContract.ASI_CRM_CN_PO_Version__c!='0.1' && SelectContract.ASI_CRM_Copied_From__c!=null && SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c !=null){
            PSFPreviousEstimateAmount=SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
        }
        else{//PO_Version =='0.1'
            PSFPreviousEstimateAmount=PSFEstimateAmount;
        }*/          
        
        
        
        //**************************Contract Details**************************************************
      
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        if(SelectContract.ASI_CRM_CN_PO_Start_Date__c != null){
            if(SelectContract.ASI_CRM_CN_PO_Start_Date__c <ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(system.today(),orgFiscalMonth).addYears(1)){ 
                SelectContract.ASI_CRM_CN_Effective_Date__c=ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.today(),orgFiscalMonth);
            }else{
                SelectContract.ASI_CRM_CN_Effective_Date__c=ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(SelectContract.ASI_CRM_CN_PO_Start_Date__c,orgFiscalMonth);
            }
        }else{
            SelectContract.ASI_CRM_CN_Effective_Date__c=ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.today(),orgFiscalMonth);
        }
        
        
        
        //BRSF
        SelectContract.ASI_CRM_CN_Expected_BRSF_Est_Total__c=BRSFPaidAmount;
        //PSF
        //ASI_CRM_Expected_V0_PSF_Estimated_Total__c
        SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=PSFPreviousEstimateAmount;
        SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=PSFPaidAmount-PSFPreviousEstimateAmount;
        SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c=PSFPaidAmount;
        SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c=PSFContractAmount;
        SelectContract.ASI_CRM_V0_PSF_Contract_Total__c=PSFContractAmount;
        SelectContract.ASI_CRM_Auto_PO_Modification__c=true;
        //VEC
        SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECPaidAmount;
        
        
        update SelectContract;
        
        
    }
    
    
    
    public Static void LastPaymentAutoPOModification2nd(ASI_TH_CRM_Contract__c Contract,Date PaymentCutOffDate){

        System.debug(LoggingLevel.INFO, '*** jinlai: ');
        //clone contract as archived po
        ASI_TH_CRM_Contract__c ContractCloned  =ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        
        
        //****update exsiting PO****
        Contract.ASI_CRM_CN_Last_PO_version__c=ContractCloned.id;
        
        
        
        //Contract.ASI_CRM_CN_Status__c = 'Final';
        if(Contract.ASI_CRM_CN_PO_Version__c=='0.0'){
            Contract.ASI_CRM_CN_V0_0_PO_version__c=ContractCloned.id;
        }
        List<String> poVersionSplit = contract.ASI_CRM_CN_PO_Version__c.split('\\.',0);
        if(poVersionSplit != null && poVersionSplit.size() ==2){
            Contract.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1])+1);
        }
        
        //2019/10/30 CanterDuan 注释原因：由于INC0106302 Issue，所以需要对ASI_CRM_CN_PO_End_Date__c的逻辑进行修改 start
        //if(PaymentCutOffDate!=null){
        //   Contract.ASI_CRM_CN_PO_End_Date__c =PaymentCutOffDate;
        //}else{
        //   Contract.ASI_CRM_CN_PO_End_Date__c = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        //}

        //Set cut off Date
        PaymentCutOffDate = PaymentCutOffDate != null ? PaymentCutOffDate : ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Contract.ASI_CRM_CN_PO_End_Date__c = PaymentCutOffDate < Contract.ASI_CRM_CN_PO_End_Date__c ?  PaymentCutOffDate : Contract.ASI_CRM_CN_PO_End_Date__c;
        //2019/10/30 CanterDuan End
        
        
        if(Contract.ASI_CRM_CN_PO_Start_Date__c != null){
            if(Contract.ASI_CRM_CN_PO_Start_Date__c <getFiscalYearStart(system.today()).addYears(1)){ 
                Contract.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
            }
            else{
                Contract.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(Contract.ASI_CRM_CN_PO_Start_Date__c);
            }
        }else{
            Contract.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
        }
        
        
        
        Contract.ASI_CRM_Copied_From__c=ContractCloned.Id; // Previous Contract
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c= Datetime.now();
        Contract.ASI_CRM_CN_PO_Modification__c = true;
        //Contract.ASI_CRM_CN_Contract_Upload__c=False;
        update Contract;
        
        
        ASI_TH_CRM_Contract__c SelectContract= [select Id,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_Effective_Date__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Description__c,ASI_CRM_Copied_From__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Contract_Upload__c,ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grand_Estimate_Total__c,
            ASI_CRM_CN_PO_End_Date__c,ASI_CRM_Volume_Option__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_PO_Version__c
                                                from ASI_TH_CRM_Contract__c WHERE id =:Contract.Id ];
        
        
        //****************** get Payment info **************************************************
        Decimal BRSFPaidAmount=0;
        Decimal PSFPaidAmount=0;
        Decimal VECPaidAmount=0;

        Decimal FCPaidAmount = 0;
        // Map<String,Decimal> FixedCostMap= new Map<String,Decimal>();
        
        // for(ASI_TH_CRM_PaymentRequestLineItem__c payline:[SELECT id, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
        //                                                   ASI_CRM_Over_Incentive__c,ASI_CRM_Suggested_Value__c,ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
        //                                                   ASI_TH_CRM_Payment_Request__c,ASI_CRM_Volume_Base__c ,ASI_CRM_Product_Category__c,ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_CTD_Actual_Vol__c , ASI_CRM_CN_Standard__c ,ASI_CRM_CTD_Cap_Collection_Vol__c , ASI_CRM_CN_Payable_Vol__c  , ASI_CRM_Key_Sub_Brand__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_V0_0_Full_Contract_Target__c, ASI_CRM_CN_Total_Payable__c , ASI_CRM_CN_Actual_Vol__c , ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c ,ASI_CRM_CN_Incentive_BT__c , ASI_CRM_CN_Allow_Changing_Incentive__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Module__c ,ASI_CRM_CN_Sub_Brand__c,RecordType.DeveloperName, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, recordtypeid , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c 
        //                                                   FROM ASI_TH_CRM_PaymentRequestLineItem__c 
        //                                                   WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:contract.Id 
        //                                                   and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c!='Draft' and
        //                                                   RecordType.DeveloperName='ASI_CRM_CN_Payment_Request_Detail_Other' ])
        // {
        //     if(payline.ASI_CRM_CN_AC_Code__c!=null && payline.ASI_TH_CRM_Amount__c!=null){
        //         if(FixedCostMap.containsKey(payline.ASI_CRM_CN_AC_Code__c)){
        //             Decimal TempAmount=FixedCostMap.get(payline.ASI_CRM_CN_AC_Code__c)+payline.ASI_TH_CRM_Amount__c;
        //             FixedCostMap.remove(payline.ASI_CRM_CN_AC_Code__c);
        //             FixedCostMap.put(payline.ASI_CRM_CN_AC_Code__c,TempAmount);
        //         }else{
        //             FixedCostMap.put(payline.ASI_CRM_CN_AC_Code__c,payline.ASI_TH_CRM_Amount__c);
        //         }
        //     }
        // }
        
        
        // List<ASI_CRM_Contract_Cost__c> LFixCost= new List<ASI_CRM_Contract_Cost__c>();
        // for(ASI_CRM_Contract_Cost__c cc:[Select id, name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, 
        //                                  ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c 
        //                                  from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :contract.Id])
        // {
        //     if(cc.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
        //         if(FixedCostMap.containsKey(cc.ASI_CRM_CN_Activity_Code__c)){
        //             cc.ASI_CRM_CN_Estimate_Amount__c=FixedCostMap.get(cc.ASI_CRM_CN_Activity_Code__c);
        //         }
        //         LFixCost.add(cc);
        //     }
        // }
        
        
        // //Update Contract Fix cost
        // if(LFixCost.size()>0){
        //     update LFixCost;
        // }
        
        
        Map<String,Decimal> PSFPaidMap = new Map<String,Decimal>();

        Map<String,Decimal> FCPaidMap = new Map<String,Decimal>();

        Set<Id> moduleIds = new Set<Id>();
        
        //Calculate actual paid amount
        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : [select Id,Name,ASI_TH_CRM_Status__c,
                                                           (select Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Parent_Module__c from ASI_CRM_Modules__r) 
                                                           from ASI_TH_CRM_PaymentRequest__c
                                                           where ASI_TH_CRM_Contract__c = :contract.Id and ASI_TH_CRM_Status__c!='Draft'  ])
        {
            for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
                if(module.ASI_CRM_Line_Type__c=='BRSF'){
                    BRSFPaidAmount+=module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                }
                if(module.ASI_CRM_Line_Type__c=='PSF'){
                    PSFPaidAmount+=module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                    if(PSFPaidMap.containsKey(module.ASI_CRM_Parent_Module__c)){
                        
                        Decimal TempAmount =   module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                        TempAmount += PSFPaidMap.get(module.ASI_CRM_Parent_Module__c) ;
                        PSFPaidMap.remove(module.ASI_CRM_Parent_Module__c);
                        PSFPaidMap.put(module.ASI_CRM_Parent_Module__c, TempAmount);
                    }else{
                       PSFPaidMap.put(module.ASI_CRM_Parent_Module__c, module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0 ); 
                    }
                    
                }

                if(module.ASI_CRM_Line_Type__c== 'Fixed'){
                    moduleIds.add(Module.ASI_CRM_Parent_Module__c);
                    FCPaidAmount+=module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                    if(FCPaidMap.containsKey(module.ASI_CRM_Parent_Module__c)){
                        
                        Decimal TempAmount =   module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                        TempAmount += FCPaidMap.get(module.ASI_CRM_Parent_Module__c) ;
                        FCPaidMap.remove(module.ASI_CRM_Parent_Module__c);
                        FCPaidMap.put(module.ASI_CRM_Parent_Module__c, TempAmount);
                    }else{
                       FCPaidMap.put(module.ASI_CRM_Parent_Module__c, module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0 ); 
                    }
                    
                }
                if(module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    VECPaidAmount +=module.ASI_CRM_Actual_Payment__c!=null?module.ASI_CRM_Actual_Payment__c:0;
                }
            }
        }
        //***********************************Finish Getting Payment Info ********************************************
        
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpdatedDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        //current version Contract Line
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines =updateLineData(SelectContract);
        
        map<String,interimData> ContractLineItem_Map = new map<String,interimData> ();

        Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c> Line999Map = new Map<Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        List<Id> deleteItemIds = new List<Id>();
        
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractDetailLines){
            //by Line Type(BRSF/PSF/VEC) + Module Id
            if(ContractLineItem_Map.containsKey(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c)){
                ContractLineItem_Map.get(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c).DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),ContractLine);
            }else{//New 
                ASI_CRM_Module__c TempModule= new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c=ContractLine.ASI_CRM_Volume_Base__c,ASI_CRM_Line_Type__c=ContractLine.ASI_CRM_Type__c);
                
                interimData TempData= new interimData(TempModule);
                TempData.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),ContractLine);
                ContractLineItem_Map.put(ContractLine.ASI_CRM_Type__c+ContractLine.ASI_CRM_Module__c, TempData);
                
            }
        }
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lastvisonlines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> V0ContractDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        String detailsql = 'SELECT Id,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ';
        if (SelectContract.ASI_CRM_CN_V0_0_PO_version__c != SelectContract.ASI_CRM_Copied_From__c) {
            String v00DetailSql = detailsql + 'ASI_CRM_CN_Contract__c =\'' + SelectContract.ASI_CRM_CN_V0_0_PO_version__c + '\'';
            String preDetailSql = detailsql + 'ASI_CRM_CN_Contract__c =\'' + SelectContract.ASI_CRM_Copied_From__c + '\'';
            V0ContractDetailLines = Database.query(v00DetailSql);
            lastvisonlines = Database.query(preDetailSql);
        } else {
            String v00DetailSql = detailsql + 'ASI_CRM_CN_Contract__c =\'' + SelectContract.ASI_CRM_CN_V0_0_PO_version__c + '\'';
            V0ContractDetailLines = Database.query(v00DetailSql);
            lastvisonlines.addAll(V0ContractDetailLines);
        }

        Decimal BRSFEstimateAmount=0;
        Decimal VECEstimateAmount=0;
        Decimal PSFEstimateAmount=0;
        
        Decimal PSFContractAmount=0;
        
        Decimal PSFPreviousEstimateAmount=0;
        Decimal PSFv00EstimateAmount = 0;

        Decimal FCEstimateAmount=0;
        
        Decimal FCContractAmount=0;
        
        Map<String,Decimal> FCPreviousEstimateAmount= new Map<String,Decimal>();

        Map<String,String> accodeFieldMap = new Map<String,String>();

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:lastvisonlines) {
            if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                PSFPreviousEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
        }

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:V0ContractDetailLines) {
            if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                PSFv00EstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
        }

        for (ASI_CRM_CN_FixedMappingSetting__c setting : [SELECT ASI_CRM_CN_Activity_CodeId__c, 
                                                                 ASI_CRM_CN_Contract_Mapping_Field__c 
                                                          FROM ASI_CRM_CN_FixedMappingSetting__c]) {
            accodeFieldMap.put(setting.ASI_CRM_CN_Activity_CodeId__c, setting.ASI_CRM_CN_Contract_Mapping_Field__c);
        }
        
        
        
        Decimal DiffMonth = SelectContract.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c-SelectContract.ASI_CRM_CN_No_of_Months__c;
        Id subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1].id;
        Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        
        for(String HeaderKey:ContractLineItem_Map.keySet()){
            Decimal EstimateAmount=0;// For BRSF VEC Use
            ASI_CRM_CN_Contract_BRSF_Line_Item__c AjustmentLine =new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=contract.Id ,
                ASI_CRM_Adjustment_Line__c=true,
                recordTypeId=BRSFLineRtId, ASI_CRM_CN_Sub_Brand__c = subbrand999,
                ASI_CRM_CN_Est_Monthly_Qty__c = 0,ASI_CRM_CN_Contract_Monthly_Qty__c=0,
                ASI_CRM_CN_Est_Total_Dummy__c=0,
                ASI_CRM_CN_Contract_Total_Dummy__c=0,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=0,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=0);
            String PSFBySubBrandModuleId='';  
            Decimal PSFAmount_BySubBrand=0;

            // String PSFBySubBrandModuleId='';  
            // Decimal PSFAmount_BySubBrand=0;
            //looping every contract Line
            for(String keyline:ContractLineItem_Map.get(HeaderKey).DetailLineMap.keySet()){
                
                
                ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine =ContractLineItem_Map.get(HeaderKey).DetailLineMap.get(keyline);
                AjustmentLine.ASI_CRM_Type__c=ContractLine.ASI_CRM_Type__c!=null? ContractLine.ASI_CRM_Type__c : 'BRSF';
                AjustmentLine.ASI_CRM_CN_Activity_Code__c = ContractLine.ASI_CRM_CN_Activity_Code__c!=null? ContractLine.ASI_CRM_CN_Activity_Code__c : null;
                if(ContractLine.ASI_CRM_Module__c!=null){
                    AjustmentLine.ASI_CRM_Module__c = ContractLine.ASI_CRM_Module__c ;
                }
                
                
                if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                    PSFBySubBrandModuleId= ContractLine.ASI_CRM_Module__c!=null? ContractLine.ASI_CRM_Module__c:'';
                    // if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                    //     PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    // }

                    if(ContractLine.ASI_CRM_Type__c== 'Fixed' ){
                        if (FCPreviousEstimateAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                            Decimal tempAmount = FCPreviousEstimateAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                            tempAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            FCPreviousEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,tempAmount); 
                        } else {
                            FCPreviousEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0);
                        }
                        // FCPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                    //if this contarct line is 999-line, save the id
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c =='999'){
                        AjustmentLine.Id=ContractLine.Id;
                    }else{//if this contarct line is not 999-line, perform calculation
                        // ContractLine.ASI_CRM_CN_Est_Total_Dummy__c= ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        // ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                        PSFAmount_BySubBrand+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                        AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c += (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*DiffMonth: 0;
                        AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c    += (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null )? ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*  ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*DiffMonth: 0;
                        // UpdatedDetailLines.add(ContractLine);
                        
                        System.debug(LoggingLevel.INFO, '*** AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c: ' + AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c);
                        if(ContractLine.ASI_CRM_Type__c=='BRSF' || ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
                            EstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            
                        }
                        
                    }                    
                }else{
                    // ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    // ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    // ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    // ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    // UpdatedDetailLines.add(ContractLine);
                    
                    // if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                    //     PSFPreviousEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0; 
                    // }

                    if(ContractLine.ASI_CRM_Type__c== 'Fixed' ){
                        if (FCPreviousEstimateAmount.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__c)) {
                            Decimal tempAmount = FCPreviousEstimateAmount.get(ContractLine.ASI_CRM_CN_Activity_Code__c);
                            tempAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                            FCPreviousEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,tempAmount); 
                        } else {
                            FCPreviousEstimateAmount.put(ContractLine.ASI_CRM_CN_Activity_Code__c,ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0);
                        }
                    }
                    if(ContractLine.ASI_CRM_Type__c=='BRSF' || ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
                        EstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                        
                    }
                }
                
                
               
                
                if(ContractLine.ASI_CRM_Type__c=='PSF' ){
                    PSFContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    PSFEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    
                }

                if(ContractLine.ASI_CRM_Type__c== 'Fixed' ){
                    FCContractAmount+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    FCEstimateAmount+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    
                }
            }// end of looping this Module
            
            if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                system.debug('BRSF PaidAmount : '+BRSFPaidAmount);
                system.debug('BRSF EstimateAmount : '+EstimateAmount);
                AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c=BRSFPaidAmount-EstimateAmount;
            }else if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='PSF' && PSFBySubBrandModuleId!=''){
                if(PSFPaidMap.containsKey(PSFBySubBrandModuleId)){
                     AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = PSFPaidMap.get(PSFBySubBrandModuleId) - PSFAmount_BySubBrand;
                }
            }else if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                system.debug('VECPaidAmount : '+VECPaidAmount);
                system.debug('VEC EstimateAmount : '+EstimateAmount);
                AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c =VECPaidAmount-EstimateAmount;
            }else if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c== 'Fixed' && PSFBySubBrandModuleId!=''){
                if(FCPaidMap.containsKey(PSFBySubBrandModuleId)){
                     AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = FCPaidMap.get(PSFBySubBrandModuleId) - PSFAmount_BySubBrand;
                }
            }
            
            //PSFPaidMap
            
            system.debug('EstimateAmount : '+EstimateAmount);
            system.debug('**********AjustmentLine*********'+AjustmentLine.ASI_CRM_Type__c);
            system.debug(AjustmentLine);
            
            //checking if need to create/update 999-Line 
            if(AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c !=0 || AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c!=0 )  {
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='BRSF'){
                    BRSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='PSF' ){
                    PSFContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    PSFEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }

                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c== 'Fixed' ){
                    FCContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    FCEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }
                
                if(ContractLineItem_Map.get(HeaderKey).Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    //VECContractAmount+=AjustmentLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    VECEstimateAmount+=AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }
                AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = 0.00;
                if (AjustmentLine.Id != null) {
                    Line999Map.put(AjustmentLine.Id, AjustmentLine);
                } else {
                    ContractDetailLines.add(AjustmentLine);
                }
            } else {
                AjustmentLine.ASI_CRM_CN_Est_Total_Dummy__c = 0.00;
                if (AjustmentLine.Id != null) {
                    deleteItemIds.add(AjustmentLine.Id);
                }
            }
            
            
            
            
        }//Ending of Contract Line looping
        
        
        //update exsting contract Line
        if(ContractDetailLines.size()>0){
            for (Integer i = ContractDetailLines.size() - 1;i >= 0 ; i--) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c line = ContractDetailLines.get(i);
                if (Line999Map.containsKey(line.Id)) {
                    ContractDetailLines.remove(i);
                    contractDetailLines.add(Line999Map.get(line.Id));
                }
            }
            upsert ContractDetailLines;
        }
        

        if(SelectContract.ASI_CRM_Copied_From__c!=null && SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c !=null && SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_PO_Version__c !='0.0'){
            PSFPreviousEstimateAmount=SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c: 0 ;
        }

        /*
        if(SelectContract.ASI_CRM_CN_PO_Version__c!='0.1' && SelectContract.ASI_CRM_Copied_From__c!=null && SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c !=null){
            PSFPreviousEstimateAmount=SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
        }
        else{//PO_Version =='0.1'
            PSFPreviousEstimateAmount=PSFEstimateAmount;
        }*/          
        
        
        
        //**************************Contract Details**************************************************
      
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        if(SelectContract.ASI_CRM_CN_PO_Start_Date__c != null){
            if(SelectContract.ASI_CRM_CN_PO_Start_Date__c <ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(system.today(),orgFiscalMonth).addYears(1)){ 
                SelectContract.ASI_CRM_CN_Effective_Date__c=ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.today(),orgFiscalMonth);
            }else{
                SelectContract.ASI_CRM_CN_Effective_Date__c=ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(SelectContract.ASI_CRM_CN_PO_Start_Date__c,orgFiscalMonth);
            }
        }else{
            SelectContract.ASI_CRM_CN_Effective_Date__c=ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.today(),orgFiscalMonth);
        }
        
        
        
        //BRSF
        SelectContract.ASI_CRM_CN_Expected_BRSF_Est_Total__c=BRSFPaidAmount;
        //PSF
        //ASI_CRM_Expected_V0_PSF_Estimated_Total__c
        SelectContract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c=PSFv00EstimateAmount;
        SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c=PSFPreviousEstimateAmount;
        SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c=PSFPaidAmount-PSFPreviousEstimateAmount;
        SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c=PSFPaidAmount;
        SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c=PSFContractAmount;
        SelectContract.ASI_CRM_V0_PSF_Contract_Total__c=PSFContractAmount;

        // SelectContract.ASI_CRM_CN_Fixed_Cost_Estimated_Total__c = FCPaidAmount;
        List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();
        for (ASI_CRM_Module__c module : [SELECT ASI_CRM_CN_AC_Code__c,Id, 
                                                ASI_CRM_CN_Expected_Est_Total__c
                                         FROM ASI_CRM_Module__c
                                         WHERE Id IN:moduleIds]) {
            if (FCPaidMap.containsKey(module.Id)) {
                module.ASI_CRM_CN_Expected_Est_Total__c = FCPaidMap.get(module.Id);
                if (accodeFieldMap.containsKey(module.ASI_CRM_CN_AC_Code__c)) {
                    SelectContract.put(accodeFieldMap.get(module.ASI_CRM_CN_AC_Code__c),module.ASI_CRM_CN_Expected_Est_Total__c);
                }
                moduleList.add(module);
            }
        }
        update moduleList;
        // for (String key : FCPreviousEstimateAmount.keySet()) {
        //     if (accodeFieldMap.containsKey(key)) {
        //         SelectContract.put(accodeFieldMap.get(key),FCPreviousEstimateAmount.get(key));
        //     }
        // }
        // SelectContract.Per=PSFPreviousEstimateAmount;
        // SelectContract.Fixed_=PSFPaidAmount-PSFPreviousEstimateAmount;
        // SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c=PSFContractAmount;
        // SelectContract.Fixed_=PSFContractAmount;
        SelectContract.ASI_CRM_Auto_PO_Modification__c=true;
        //VEC
        SelectContract.ASI_CRM_EVC_Cost_Estimate_Total__c=VECPaidAmount;
        
        
        update SelectContract;
        

        List<ASI_TH_CRM_PaymentRequest__c> LastPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
                             ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                             ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,ASI_CRM_CN_OutletWS__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c
                             FROM ASI_TH_CRM_PaymentRequest__c
                             WHERE 
                             ASI_CRM_CN_PO_No__c = :contract.ASI_CRM_CN_PO_No__c
                            AND ASI_CRM_CN_Last_Payment__c = TRUE AND ASI_TH_CRM_Status__c = 'Paid'
                            Order By CreatedDate desc];
        if (!Test.isRunningTest()) {
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd VfinalFinancialIndicator = ReconstructLastPaymentFIDataList2nd(LastPaymentRequest.get(0)).get(0);
            ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(SelectContract, null, VfinalFinancialIndicator);
        }
    }

    public static String newCounterCreatorLine() {
        
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
    public static Decimal formatterQty(Decimal qty) {
        String myNumber = String.valueOf(qty);
        String myTruncatedNumber = '';
        if (myNumber.contains('.')) {
            myTruncatedNumber = myNumber.subString(0,myNumber.indexOf('.'));
        } else {
            myTruncatedNumber = myNumber;
        }
        Decimal d = Decimal.valueOf(myTruncatedNumber);
        return d;
    }

    public static List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> updateLineData(ASI_TH_CRM_Contract__c contract) {
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractDetailLines =[SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Product_Category_Name__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                              WHERE ASI_CRM_CN_Contract__c = :contract.Id] ;
        Date CutOffDay = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Date v0TillEndPOM = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, contract.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        Integer mothNo = Contract.ASI_CRM_CN_PO_Start_Date__c.monthsBetween(v0TillEndPOM.addDays(1));
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('ASI_CRM_Subbrand_Volume__c').getDescribe().Fields.getMap();
        // List<String> selectFields = new List<String>();

        // if (fMap != null){
        //     for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
        //         Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
        //         if (fd.isCreateable()){ // field is creatable
        //             selectFields.add(fd.getName());
        //         }
        //     }
        // }
        String queryStr = 'OwnerId,CurrencyIsoCode,RecordTypeId,ASI_CRM_AVG_Offtake_BTL__c,ASI_CRM_AVG_Offtake_CR12__c,ASI_CRM_AVG_Offtake_STD_Billing__c,ASI_CRM_AVG_Offtake_STD__c,ASI_CRM_AVG_Offtake__c,ASI_CRM_Account__c,ASI_CRM_CN_Payment_Request_Line_Item__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_WS_Tier__c,ASI_CRM_Empty_Bottle_Btl__c,ASI_CRM_Empty_Bottle_CR12__c,ASI_CRM_Empty_Bottle_GS__c,ASI_CRM_Empty_Bottle_Std_Billing__c,ASI_CRM_Empty_Bottle_Std_Btl__c,ASI_CRM_Empty_Bottle__c,ASI_CRM_End_Date__c,ASI_CRM_External_ID__c,ASI_CRM_Green_Cap_Btl__c,ASI_CRM_Green_Cap_CR12__c,ASI_CRM_Green_Cap_GS__c,ASI_CRM_Green_Cap_STD__c,ASI_CRM_Green_Cap_Std_Billing__c,ASI_CRM_Green_Cap__c,ASI_CRM_Month__c,ASI_CRM_Offtake_Btl__c,ASI_CRM_Offtake_CR12__c,ASI_CRM_Offtake_GS__c,ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_Offtake_Std__c,ASI_CRM_Offtake__c,ASI_CRM_PR_DIRECT_GS_LESS_50ML__c,ASI_CRM_PR_DIRECT_GS__c,ASI_CRM_PR_Direct_Btl__c,ASI_CRM_PR_Direct_CR12__c,ASI_CRM_PR_Direct_GS_L50__c,ASI_CRM_PR_Direct_L50_Btl__c,ASI_CRM_PR_Direct_L50_CR12__c,ASI_CRM_PR_Direct_L50_STD_Billing__c,ASI_CRM_PR_Direct_L50_STD__c,ASI_CRM_PR_Direct_L50__c,ASI_CRM_PR_Direct_STD_Billing__c,ASI_CRM_PR_Direct_STD__c,ASI_CRM_PR_Direct__c,ASI_CRM_PR_SHIPMENT__c,ASI_CRM_PR_Shipment_Btl__c,ASI_CRM_PR_Shipment_CR12__c,ASI_CRM_PR_Shipment_GS_L50__c,ASI_CRM_PR_Shipment_GS__c,ASI_CRM_PR_Shipment_L50_Btl__c,ASI_CRM_PR_Shipment_L50_CR12__c,ASI_CRM_PR_Shipment_L50_STD_Billing__c,ASI_CRM_PR_Shipment_L50_STD__c,ASI_CRM_PR_Shipment_L50__c,ASI_CRM_PR_Shipment_STD_Billing__c,ASI_CRM_PR_Shipment_STD__c,ASI_CRM_Red_Cap_Btl__c,ASI_CRM_Red_Cap_CR12__c,ASI_CRM_Red_Cap_GS__c,ASI_CRM_Red_Cap_STD_Billing__c,ASI_CRM_Red_Cap_STD__c,ASI_CRM_Red_Cap__c,ASI_CRM_Subbrand__c,ASI_CRM_T1_Depletion_BTL__c,ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T1_Depletion_GS_LESS_50ML__c,ASI_CRM_T1_Depletion_GS__c,ASI_CRM_T1_Depletion_L50_BTL__c,ASI_CRM_T1_Depletion_L50_CR12__c,ASI_CRM_T1_Depletion_L50_GS__c,ASI_CRM_T1_Depletion_L50_STD_Billing__c,ASI_CRM_T1_Depletion_L50_STD__c,ASI_CRM_T1_Depletion_L50__c,ASI_CRM_T1_Depletion_STD_Billing__c,ASI_CRM_T1_Depletion_STD__c,ASI_CRM_T1_Depletion__c,ASI_CRM_T1_DepletiontoALL_Btl__c,ASI_CRM_T1_DepletiontoALL_CR12__c,ASI_CRM_T1_DepletiontoALL_GS__c,ASI_CRM_T1_DepletiontoALL_L50_GS__c,ASI_CRM_T1_DepletiontoALL_L50_STD_Billin__c,ASI_CRM_T1_DepletiontoALL_L50_STD__c,ASI_CRM_T1_DepletiontoALL_STD_Billing__c,ASI_CRM_T1_DepletiontoALL_STD__c,ASI_CRM_T1_DepletiontoT2_L50_BTL__c,ASI_CRM_T1_DepletiontoT2_L50_CR12__c,ASI_CRM_T1_DepletiontoT2_L50__c,ASI_CRM_T1_DepletiontoT2__c,ASI_CRM_T23_DepletiontoALL_BTL__c,ASI_CRM_T23_DepletiontoALL_CR12__c,ASI_CRM_T23_DepletiontoALL_GS__c,ASI_CRM_T23_DepletiontoALL_L50_BTL__c,ASI_CRM_T23_DepletiontoALL_L50_CR12__c,ASI_CRM_T23_DepletiontoALL_L50_GS__c,ASI_CRM_T23_DepletiontoALL_L50_STD_Billi__c,ASI_CRM_T23_DepletiontoALL_L50_STD__c,ASI_CRM_T23_DepletiontoALL_STD_Billing__c,ASI_CRM_T23_DepletiontoALL_STD__c,ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_T2_Depletion_GS_50ML__c,ASI_CRM_T2_Depletion_GS__c,ASI_CRM_T2_Depletion_L50_BTL__c,ASI_CRM_T2_Depletion_L50_CR12__c,ASI_CRM_T2_Depletion_L50_GS__c,ASI_CRM_T2_Depletion_L50_STD_Billing__c,ASI_CRM_T2_Depletion_L50_STD__c,ASI_CRM_T2_Depletion_L50__c,ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_T2_Depletion_STD__c,ASI_CRM_T2_Depletion__c,ASI_CRM_T2_DepletiontoT3_L50__c,ASI_CRM_T2_DepletiontoT3__c,ASI_CRM_T2_Receive_Scan_GS__c,ASI_CRM_T2_receive_scan_BTL__c,ASI_CRM_T2_receive_scan_CR12__c,ASI_CRM_T2_receive_scan_STD_Billing__c,ASI_CRM_T2_receive_scan_STD__c,ASI_CRM_T2_receive_scan__c,ASI_CRM_Total_Depletion_To_T2_GS__c,ASI_CRM_WS_INV_BTL__c,ASI_CRM_WS_INV_CR12__c,ASI_CRM_WS_INV_STD_Billing__c,ASI_CRM_WS_INV_STD__c,ASI_CRM_WS_INV__c,ASI_CRM_WS_Inventory_GS__c,ASI_CRM_Year__c,ASI_CRM_Yellow_Cap_Btl__c,ASI_CRM_Yellow_Cap_CR12__c,ASI_CRM_Yellow_Cap_GS__c,ASI_CRM_Yellow_Cap_STD_Billing__c,ASI_CRM_Yellow_Cap_STD__c,ASI_CRM_Yellow_Cap__c,ASI_CRMT_2T3Depletion_ToALL_TY_VS_LY_YTD__c,ASI_CRM_CN_Division_Code__c,ASI_CRM_Empty_Bottle_Last_FY_MTD_9L__c,ASI_CRM_Empty_Bottle_Last_FY_MTD_Std_Btl__c,ASI_CRM_Empty_Bottle_Last_FY_YTD_9L__c,ASI_CRM_Empty_Bottle_Last_FY_YTD_Std_Btl__c,ASI_CRM_Empty_Bottle_This_FY_VS_Last_FY__c,ASI_CRM_Empty_Bottle_This_FY_YTD_9L__c,ASI_CRM_Empty_Bottle_This_FY_YTD_Std_Btl__c,ASI_CRM_Green_Cap_Last_FY_MTD_9L__c,ASI_CRM_Green_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Green_Cap_Last_FY_YTD_9L__c,ASI_CRM_Green_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Green_Cap_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Green_Cap_This_FY_YTD_9L__c,ASI_CRM_Green_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_Intake_9L__c,ASI_CRM_Intake_Btl__c,ASI_CRM_Intake_CR12__c,ASI_CRM_Intake_GS__c,ASI_CRM_Intake_Last_FY_MTD_9L__c,ASI_CRM_Intake_Last_FY_MTD_Std_Btl__c,ASI_CRM_Intake_Last_FY_YTD_9L__c,ASI_CRM_Intake_Last_FY_YTD_Std_Btl__c,ASI_CRM_Intake_Std_Billing__c,ASI_CRM_Intake_Std_Btl__c,ASI_CRM_Intake_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Intake_This_FY_YTD_9L__c,ASI_CRM_Intake_This_FY_YTD_Std_Btl__c,ASI_CRM_Offtake_Last_FY_MTD_9L__c,ASI_CRM_Offtake_Last_FY_MTD_Std_Btl__c,ASI_CRM_Offtake_Last_FY_YTD_9L__c,ASI_CRM_Offtake_Last_FY_YTD_Std_Btl__c,ASI_CRM_Offtake_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Offtake_This_FY_YTD_9L__c,ASI_CRM_Offtake_This_FY_YTD_Std_Btl__c,ASI_CRM_POS_9L__c,ASI_CRM_POS_Btl__c,ASI_CRM_POS_CR12__c,ASI_CRM_POS_GS__c,ASI_CRM_POS_LY_FY_9L__c,ASI_CRM_POS_LY_FY_Std_Btl__c,ASI_CRM_POS_LY_MTD_9L__c,ASI_CRM_POS_LY_MTD_Std_Btl__c,ASI_CRM_POS_LY_YTD_9L__c,ASI_CRM_POS_LY_YTD_Std_Btl__c,ASI_CRM_POS_Std_Billing__c,ASI_CRM_POS_Std_Btl__c,ASI_CRM_POS_This_FY_VS_Last_FY_YTD__c,ASI_CRM_POS_YTD_Std_Btl_9L__c,ASI_CRM_POS_YTD_Std_Btl_Std_Btl__c,ASI_CRM_PR_Direct_Last_FY_MTD_9L__c,ASI_CRM_PR_Direct_Last_FY_MTD_Std_Btl__c,ASI_CRM_PR_Direct_Last_FY_YTD_9L__c,ASI_CRM_PR_Direct_Last_FY_YTD_Std_Btl__c,ASI_CRM_PR_Direct_This_FY_VS_Last_FY_YTD__c,ASI_CRM_PR_Direct_This_FY_YTD_9L__c,ASI_CRM_PR_Direct_This_FY_YTD_Std_Btl__c,ASI_CRM_PR_Shipment_LY_MTD_Std_Btl__c,ASI_CRM_PR_Shipment_LY_YTD_Std_Btl__c,ASI_CRM_PR_Shipment_Last_FY_MTD_9L__c,ASI_CRM_PR_Shipment_Last_FY_YTD_9L__c,ASI_CRM_PR_Shipment_TY_VS_LY_YTD__c,ASI_CRM_PR_Shipment_TY_YTD_Std_Btl__c,ASI_CRM_PR_Shipment_This_FY_YTD_9L__c,ASI_CRM_Red_Cap_Last_FY_MTD_9L__c,ASI_CRM_Red_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Red_Cap_Last_FY_YTD_9L__c,ASI_CRM_Red_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Red_Cap_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Red_Cap_This_FY_YTD_9L__c,ASI_CRM_Red_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_T1DepletionTo_ALL_TY_YTD_Std_Btl__c,ASI_CRM_T1Depletion_ToALL_LY_YTD_Std_Btl__c,ASI_CRM_T1_Depletion_Last_FY_MTD_9L__c,ASI_CRM_T1_Depletion_Last_FY_MTD_Std_Btl__c,ASI_CRM_T1_Depletion_Last_FY_YTD_9L__c,ASI_CRM_T1_Depletion_Last_FY_YTD_Std_Btl__c,ASI_CRM_T1_Depletion_This_FY_VS_Last_FY__c,ASI_CRM_T1_Depletion_This_FY_YTD_9L__c,ASI_CRM_T1_Depletion_This_FY_YTD_Std_Btl__c,ASI_CRM_T1_Depletion_to_ALL_LY_MTD_9L__c,ASI_CRM_T1_Depletion_to_ALL_LY_MTD_Std__c,ASI_CRM_T1_Depletion_to_ALL_LY_YTD_9L__c,ASI_CRM_T1_Depletion_to_ALL_TY_VS_LY_YTD__c,ASI_CRM_T1_Depletion_to_ALL_TY_YTD_9L__c,ASI_CRM_T2T3DepletionToALL_LY_YTD_StdBtl__c,ASI_CRM_T2T3_Depletion_to_ALL_TY_YTD_Std__c,ASI_CRM_T2_Depletion_Last_FY_MTD_9L__c,ASI_CRM_T2_Depletion_Last_FY_MTD_Std_Btl__c,ASI_CRM_T2_Depletion_Last_FY_YTD_9L__c,ASI_CRM_T2_Depletion_Last_FY_YTD_Std_Btl__c,ASI_CRM_T2_Depletion_This_FY_VS_Last_FY__c,ASI_CRM_T2_Depletion_This_FY_YTD_9L__c,ASI_CRM_T2_Depletion_This_FY_YTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_LY_MTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_LY_YTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_Last_FY_MTD_9L__c,ASI_CRM_T2_Receive_Scan_Last_FY_YTD_9L__c,ASI_CRM_T2_Receive_Scan_TY_VS_LY_YTD__c,ASI_CRM_T2_Receive_Scan_TY_YTD_Std_Btl__c,ASI_CRM_T2_Receive_Scan_This_FY_YTD_9L__c,ASI_CRM_T2_T3_Depletion_to_ALL_LY_MTD_9L__c,ASI_CRM_T2_T3_Depletion_to_ALL_TY_YTD_9L__c,ASI_CRM_WS_Inventory_Last_FY_9L__c,ASI_CRM_WS_Inventory_Last_FY_Std_Btl__c,ASI_CRM_WS_Inventory_TY_VS_LY_YTD__c,ASI_CRM_Yellow_Cap_Last_FY_MTD_9L__c,ASI_CRM_Yellow_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Yellow_Cap_Last_FY_YTD_9L__c,ASI_CRM_Yellow_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Yellow_Cap_This_FY_VS_Last_FYYTD__c,ASI_CRM_Yellow_Cap_This_FY_YTD_9L__c,ASI_CRM_Yellow_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_CN_Greater_Region_Code__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Black_Cap_CR12__c,ASI_CRM_Black_Cap_GS__c,ASI_CRM_Black_Cap_Last_FY_MTD_9L__c,ASI_CRM_Black_Cap_Last_FY_MTD_Std_Btl__c,ASI_CRM_Black_Cap_Last_FY_YTD_9L__c,ASI_CRM_Black_Cap_Last_FY_YTD_Std_Btl__c,ASI_CRM_Black_Cap_STD__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Black_Cap_This_FY_VS_Last_FY_YTD__c,ASI_CRM_Black_Cap_This_FY_YTD_9L__c,ASI_CRM_Black_Cap_This_FY_YTD_Std_Btl__c,ASI_CRM_Black_Cap__c,ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Exclude_From_Payment_Volume__c,ASI_CRM_DeductCapWithIssue_StdBill__c,ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Deductible_Cap_with_Issues_Btl__c,ASI_CRM_Deductible_Cap_with_Issues_CR12__c,ASI_CRM_Deductible_Cap_with_Issues__c,ASI_CRM_Grey_Cap_Btl__c,ASI_CRM_Grey_Cap_CR12__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Grey_Cap_Std_Btl__c,ASI_CRM_Grey_Cap__c,ASI_CRM_Penalty_Coefficient_Applied__c,ASI_CRM_Times_of_cap_with_issues__c,ASI_CRM_CN_Contract__c,ASI_CRM_CN_Intake_GS_T1_price__c,ASI_CRM_CN_Original_Contract_Start_Date__c,ASI_CRM_CN_Product_Category_Agg__c,ASI_CRM_CN_Supplier__c,';

        Map<Id,String> subBrandIdMaps = new Map<Id,String>();

        for (ASI_MFM_Sub_brand__c brand : [SELECT Id,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c FROM ASI_MFM_Sub_brand__c 
                                           WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand' 
                                           AND ASI_CRM_CN_Sub_brand_Grade__c!=null 
                                           AND  ASI_MFM_Brand__r.ASI_CRM_CN_Competitor__c =FALSE 
                                           AND ASI_MFM_Active_for_CRM__c=TRUE  
                                           AND ASI_MFM_Sub_brand_Code__c != '999']) {
            subBrandIdMaps.put(brand.Id, brand.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c);
        }
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                             FROM ASI_CRM_CN_Covered_Outlet__c
                             WHERE ASI_CRM_CN_Contract__c = :contract.Id];
        }catch(exception e){
            CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }  
        set<id> AllOutlet = new set<id>();
        
        if (contract.ASI_CRM_Volume_Option__c == 'Normal' || contract.ASI_CRM_Volume_Option__c == 'Wholesaler Only' ||contract.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(contract.ASI_CRM_CN_Outlet_WS__c);
        }
        if (contract.ASI_CRM_Volume_Option__c == 'Normal' || contract.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || contract.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }

        date TillEnd = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, contract.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        // Id conId = ContractSelected.Id;
        // Id accId = ContractSelected.ASI_CRM_CN_Outlet_WS__c;
        Date startDate = contract.ASI_CRM_CN_PO_Start_Date__c;
        queryStr += 'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,';
        queryStr += 'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,';
        queryStr += 'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c';
        String volumeSql = 'SELECT '+ queryStr + ' FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_End_Date__c >=: startDate AND ASI_CRM_End_Date__c <= :TillEnd AND ASI_CRM_CN_Competitor_Sub_brand__c != true AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false and ASI_CRM_Subbrand__c !=null' ;

        System.debug(LoggingLevel.INFO, '*** volumeSql: ' + volumeSql);
        List<ASI_CRM_Subbrand_Volume__c> volumeList = Database.query(volumeSql);
        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfitemMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Id brsfmoduleId;
        Id bRSFActivityCodeId;
        Id bRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');

        Id vecModuleId;
        Id vecActivityCodeId;

        Set<Id> psfModuleId = new Set<Id>();
        Id psfcode;

        Set<Id> fcmoduleIds = new Set<Id>();
        Map<Id,Id> fcactivityCodeId = new Map<Id,Id>();

        System.debug(LoggingLevel.INFO, '*** contract.ASI_CRM_CN_No_of_Months__c: ' + contract.ASI_CRM_CN_No_of_Months__c);

        for (Integer i = contractDetailLines.size() - 1;i > = 0; i --) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine = contractDetailLines.get(i);
            if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){
                    ContractLine.ASI_CRM_CN_Is_Payment_New__c = false;
                    if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                        bRSFActivityCodeId = contractLine.ASI_CRM_CN_Activity_Code__c;
                        brsfmoduleId = contractLine.ASI_CRM_Module__c;
                        // ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0.00;

                        ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c = contractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                        brsfitemMap.put(contractLine.ASI_CRM_CN_Sub_Brand__c, contractLine);
                        contractDetailLines.remove(i);
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'PSF' && !psfModuleId.contains(ContractLine.ASI_CRM_Module__c)) {
                        psfModuleId.add(ContractLine.ASI_CRM_Module__c);
                        psfcode = ContractLine.ASI_CRM_CN_Activity_Code__c;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'Variable Event Cost') {
                        vecModuleId = ContractLine.ASI_CRM_Module__c;
                        vecActivityCodeId = ContractLine.ASI_CRM_CN_Activity_Code__c;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'Fixed' && !fcmoduleIds.contains(ContractLine.ASI_CRM_Module__c)) {
                        fcmoduleIds.add(ContractLine.ASI_CRM_Module__c);
                        fcactivityCodeId.put(ContractLine.ASI_CRM_Module__c, ContractLine.ASI_CRM_CN_Activity_Code__c);
                    }
                }
            }
        }

        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        //Looping the Sub-Brand Grade
        for(ASI_CRM_Sub_Brand_Grade__c sbg:ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c )){
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }else{
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);  
            }
        }

        System.debug(LoggingLevel.INFO, '*** brsfitemMap: ' + brsfitemMap);
        // if (mothNo >= (contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c!= null ?contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_CN_CTD_Monthly_Default_Period__c:6)) {


            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : brsfitemMap.values()) {
                item.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                item.ASI_CRM_CN_Est_Total_Dummy__c = 0.00;
                item.ASI_CRM_CN_Is_Payment_New__c = false;
            }
            System.debug(LoggingLevel.INFO, '*** volumeList: ' + volumeList);
            List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT Id,CreatedDate, ASI_TH_CRM_Contract__c
                                                              FROM ASI_TH_CRM_PaymentRequest__c
                                                              WHERE ASI_TH_CRM_Contract__c=:contract.Id
                                                              ORDER BY CreatedDate DESC];
            ASI_TH_CRM_PaymentRequest__c newestPayment = new ASI_TH_CRM_PaymentRequest__c();
            // List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();

            Map<Id,Map<Id,Decimal>> paymentPriceMap = new Map<Id,Map<Id,Decimal>>();
            if (paymentList != null && paymentList.size() > 0) {
                newestPayment = paymentList.get(0);
                Set<Id> moduleIds = new Set<Id>();
                for (ASI_CRM_Module__c module : [SELECT ASI_CRM_Line_Type__c, ASI_CRM_Parent_Module__c 
                                                  FROM ASI_CRM_Module__c
                                                  WHERE ASI_CRM_Contract__c=: contract.Id 
                                                  AND ASI_CRM_Payment_Request__c =: newestPayment.Id]) {
                    moduleIds.add(module.Id);
                }
                // Map<Id,Map<Id,Decimal>> paymentPriceMap = new Map<Id,Map<Id,Decimal>>();
                for (ASI_TH_CRM_PaymentRequestLineItem__c payment : [SELECT ASI_CRM_CN_Incentive_BT__c,
                                                                             ASI_CRM_CN_Sub_Brand__c,
                                                                             ASI_CRM_Module__r.ASI_CRM_Parent_Module__c
                                                                      FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                                                      WHERE ASI_CRM_Module__c IN:moduleIds
                                                                      AND ASI_CRM_CN_Sub_Brand__c != null]) {
                    if (paymentPriceMap.containsKey(payment.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c)) {
                        paymentPriceMap.get(payment.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).put(payment.ASI_CRM_CN_Sub_Brand__c, payment.ASI_CRM_CN_Incentive_BT__c);
                    } else {
                        paymentPriceMap.put(payment.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,new Map<Id,Decimal>{payment.ASI_CRM_CN_Sub_Brand__c => payment.ASI_CRM_CN_Incentive_BT__c});
                    }
                }

            }

            // List<Date> dateList = new List<Date>();
            Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
            // dateList.add(setDate);

            String channel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
            String region = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            String cityInvestementGrade = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
            String newImage = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;

            Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdMaps.keySet());

            Map<Id,String> gradeNameMap = new Map<Id,String>();
            //销量中新增的brsf
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> newItemList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            for (ASI_CRM_Subbrand_Volume__c volume : volumeList) {
                Decimal VolumeBtl = ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume, 'std');
                if (brsfitemMap.containsKey(volume.ASI_CRM_Subbrand__c)) {

                    Decimal qty = brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c + (VolumeBtl.divide(mothNo, 4) == null ? 0 : VolumeBtl.divide(mothNo, 4));
                    Decimal estQty = formatterQty(qty);
                    brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c = estQty;
                    // brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c += VolumeBtl.divide(mothNo, 4) != null ? VolumeBtl.divide(mothNo, 4) : 0;
                    brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Total_Dummy__c = brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_Monthly_Qty__c*brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                    // brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Contract_Total_Dummy__c = brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Contract_Monthly_Qty__c*brsfitemMap.get(volume.ASI_CRM_Subbrand__c).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                } else {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c newItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                    newItem.ASI_CRM_CN_Sub_Brand__c = volume.ASI_CRM_Subbrand__c;
                    newItem.ASI_CRM_CN_Contract__c = contract.Id;
                    newItem.ASI_CRM_Module__c = brsfmoduleId;
                    newItem.ASI_CRM_CN_Activity_Code__c = bRSFActivityCodeId;
                    newItem.ASI_CRM_Sub_Brand_Grade__c = volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                    newItem.ASI_CRM_Type__c= 'BRSF';
                    newItem.ASI_CRM_Volume_Base__c = 'By Sub-Brand';
                    newItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = 0.00;
                    newItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0.00;
                    newItem.ASI_CRM_CN_Contract_Total_Dummy__c = 0.00;
                    newItem.ASI_CRM_CN_Contract_Monthly_Qty__c = 0.00;
                    newItem.ASI_CRM_Sub_Brand_Grade__c = volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                    newItem.RecordTypeId = bRSFLineRtId;
                    newItem.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newItem.ASI_CRM_CN_Sub_Brand__c,setDate,'BRSFMax','');
                    newItem.ASI_CRM_Line_Name__c = volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                    Decimal estQty = formatterQty(VolumeBtl.divide(mothNo, 4));
                    newItem.ASI_CRM_CN_Est_Monthly_Qty__c = estQty;
                    if (paymentPriceMap.containsKey(newItem.ASI_CRM_Module__c)) {
                        Map<Id,Decimal> priceMap = paymentPriceMap.get(newItem.ASI_CRM_Module__c);
                        if (priceMap.containsKey(newItem.ASI_CRM_CN_Sub_Brand__c)) {
                            newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newItem.ASI_CRM_CN_Sub_Brand__c);
                        }
                    }
                    if (newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newItem.ASI_CRM_CN_Sub_Brand__c,setDate,'BRSFDefault','');
                        newItem.ASI_CRM_CN_Is_Payment_New__c = true;
                    }
                    if (newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        newItem.ASI_CRM_CN_Is_Payment_New__c = true;
                        newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(SubBrandGradeMap,volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFDefault',contract);
                    }
                    if (newItem.ASI_CRM_Max_Incentive__c == null) {
                        newItem.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newItem.ASI_CRM_CN_Sub_Brand__c,setDate,'BRSFMax','');
                    }
                    if (newItem.ASI_CRM_Max_Incentive__c == null) {
                        newItem.ASI_CRM_Max_Incentive__c = GeneratingIncentive(SubBrandGradeMap,volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFMax',contract);
                    }
                    newItem.ASI_CRM_CN_Est_Total_Dummy__c = newItem.ASI_CRM_CN_Est_Monthly_Qty__c*newItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                    //3.28add
                    // newItem.ASI_CRM_CN_Is_Payment_New__c = true;
                    gradeNameMap.put(newItem.ASI_CRM_Sub_Brand_Grade__c, volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                    newItemList.add(newItem);
                    brsfitemMap.put(newItem.ASI_CRM_CN_Sub_Brand__c,newItem);
                }
            }

            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : brsfitemMap.values()) {
                line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Monthly_Qty__c*line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Monthly_Qty__c*line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
            }

            //在其他module添加newItemList的数据
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : newItemList) {
                if (String.isNotBlank(vecModuleId)) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = line.clone();
                    newLine.ASI_CRM_Module__c = vecModuleId;
                    newLine.ASI_CRM_Type__c = 'Variable Event Cost';
                    newLine.ASI_CRM_CN_Activity_Code__c = vecActivityCodeId;

                    newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = null;
                    if (paymentPriceMap.containsKey(newLine.ASI_CRM_Module__c)) {
                        Map<Id,Decimal> priceMap = paymentPriceMap.get(newLine.ASI_CRM_Module__c);
                        if (priceMap.containsKey(newLine.ASI_CRM_CN_Sub_Brand__c)) {
                            newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newLine.ASI_CRM_CN_Sub_Brand__c);
                            newLine.ASI_CRM_CN_Is_Payment_New__c = false;
                        }
                    }

                    // if (newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                    //     newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'VECDefault','');
                    // }

                    // newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'VECDefault',contract);
                    newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : 0;

                    newLine.ASI_CRM_CN_Est_Total_Dummy__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*newLine.ASI_CRM_CN_Est_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                    contractDetailLines.add(newLine);
                }

                if (psfModuleId != null && psfModuleId.size() > 0) {
                    for (Id mId : psfModuleId) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = line.clone();
                        newLine.ASI_CRM_Module__c = mId;
                        newLine.ASI_CRM_Type__c = 'PSF';
                        newLine.ASI_CRM_CN_Activity_Code__c = psfcode;

                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = null;
                        if (paymentPriceMap.containsKey(newLine.ASI_CRM_Module__c)) {
                            Map<Id,Decimal> priceMap = paymentPriceMap.get(newLine.ASI_CRM_Module__c);
                            if (priceMap.containsKey(newLine.ASI_CRM_CN_Sub_Brand__c)) {
                                newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newLine.ASI_CRM_CN_Sub_Brand__c);
                                newLine.ASI_CRM_CN_Is_Payment_New__c = false;
                            }
                        }

                        // if (newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        //     newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'PSFDefault','');
                        // }

                        // newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'PSFDefault',contract);
                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : 0;


                        newLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'PSFMax','');
                        newLine.ASI_CRM_Max_Incentive__c = newLine.ASI_CRM_Max_Incentive__c == null ? GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'PSFMax',contract) : newLine.ASI_CRM_Max_Incentive__c;
                        newLine.ASI_CRM_CN_Est_Total_Dummy__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*newLine.ASI_CRM_CN_Est_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                        contractDetailLines.add(newLine);
                    }
                }

                if (fcmoduleIds != null && fcmoduleIds.size() > 0) {
                    for (Id mId : fcmoduleIds) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c newLine = line.clone();
                        newLine.ASI_CRM_Module__c = mId;
                        newLine.ASI_CRM_Type__c = 'Fixed';

                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = null;
                        newLine.ASI_CRM_CN_Activity_Code__c = fcactivityCodeId.get(newLine.ASI_CRM_Module__c);
                        if (paymentPriceMap.containsKey(newLine.ASI_CRM_Module__c)) {
                            Map<Id,Decimal> priceMap = paymentPriceMap.get(newLine.ASI_CRM_Module__c);
                            if (priceMap.containsKey(newLine.ASI_CRM_CN_Sub_Brand__c)) {
                                newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = priceMap.get(newLine.ASI_CRM_CN_Sub_Brand__c);
                                newLine.ASI_CRM_CN_Is_Payment_New__c = false;
                            }
                        }

                        // newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : GeneratingIncentive(SubBrandGradeMap,gradeNameMap.get(newLine.ASI_CRM_Sub_Brand_Grade__c),'FCDefault',contract);
                        // if (newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null) {
                        //     newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'FCDefault',newLine.ASI_CRM_CN_Activity_Code__c);
                        // }
                        newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null ? newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c : 0;
                        

                        newLine.ASI_CRM_Max_Incentive__c = GeneratingIncentive(gsMap,newLine.ASI_CRM_CN_Sub_Brand__c,setDate,'FCMax',newLine.ASI_CRM_CN_Activity_Code__c);
                        newLine.ASI_CRM_CN_Est_Total_Dummy__c = newLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*newLine.ASI_CRM_CN_Est_Monthly_Qty__c*contract.ASI_CRM_CN_No_of_Months__c;
                        contractDetailLines.add(newLine);
                    }
                }
            }
        // } else{

        //     Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> v00brsfitemMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        //     for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : [SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Product_Category_Name__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :contract.ASI_CRM_CN_V0_0_PO_version__c AND ASI_CRM_Type__c= 'BRSF' AND ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != '999']) {
        //         v00brsfitemMap.put(item.ASI_CRM_CN_Sub_Brand__c, item);
        //     }
        //     for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : brsfitemMap.values()) {
        //         if (v00brsfitemMap.containsKey(item.ASI_CRM_CN_Sub_Brand__c)) {
        //             Decimal estQty = v00brsfitemMap.get(item.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Est_Monthly_Qty__c*v00brsfitemMap.get(item.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_No_of_Months__c/contract.ASI_CRM_CN_No_of_Months__c;
        //             item.ASI_CRM_CN_Est_Monthly_Qty__c = formatterQty(estQty);
        //         }
        //     }
        // }

        
        contractDetailLines.addAll(brsfitemMap.values());

        //循环其他的line，更新销售量以及金额
        
            
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c contractLine:contractDetailLines) {
            if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){
                    if (brsfitemMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine = brsfitemMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        if (subBrandIdMaps.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)) {
                            ContractLine.ASI_CRM_Line_Name__c = subBrandIdMaps.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        }
                        ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c = brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c != null ? brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c : 0;
                        ContractLine.ASI_CRM_CN_Est_Total_Dummy__c = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                        ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c = brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c;

                        ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                    }
                }
            }
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> detailLines = updateModuleQty(contractDetailLines,contract);
        return detailLines;

    }

    public static List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> updateModuleQty(List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractDetailLines,ASI_TH_CRM_Contract__c contract) {

        //Module
        // Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>(); // Map <Id, ASI_CRM_Module__c>
        
        // for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Remark_Display__c,ASI_CRM_Remark_Options__c,ASI_CRM_CN_Expected_Est_Total__c,ASI_CRM_Created_PO_Version__c,ASI_CRM_CN_AC_Code__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Group_Contract__c,ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c from ASI_CRM_Module__c where ASI_CRM_Contract__c =:pageId ]){
        //     ModuleMap.put(Module.Id,Module);
        // }
        Set<String> SBBrandSet = new Set<String>();

        Set<Id> sbbrandIds = new Set<Id>();
        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> subbrandLineMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>> gradeLineMap = new Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>>();
        Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>> categoryLineMap = new Map<String,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>>();

        Map<String, String> ProductCategoryMap= new Map<String, String> ();   //Map : <Sub-Brand Id,Product Category Name>
            

            // System.debug(LoggingLevel.INFO, '*** ProductCategoryMap: ' + ProductCategoryMap);

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : contractDetailLines) {
            if (line.ASI_CRM_Type__c == 'BRSF') {

                line.ASI_CRM_CN_Est_Monthly_Qty__c = formatterQty(line.ASI_CRM_CN_Est_Monthly_Qty__c);
                line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c*line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;

                line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c*line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*contract.ASI_CRM_CN_No_of_Months__c;
                subbrandLineMap.put(line.ASI_CRM_CN_Sub_Brand__c, line);
                SBBrandSet.add(line.ASI_CRM_CN_Sub_Brand__c);

                sbbrandIds.add(line.ASI_CRM_CN_Sub_Brand__c);
                if (gradeLineMap.containsKey(line.ASI_CRM_Sub_Brand_Grade__c)) {
                    gradeLineMap.get(line.ASI_CRM_Sub_Brand_Grade__c).add(line);
                } else {
                    gradeLineMap.put(line.ASI_CRM_Sub_Brand_Grade__c, new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> {line});
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** subbrandLineMap: ' + subbrandLineMap);

        for(ASI_MFM_Sub_brand__c sb:[select Id,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_MFM_Brand__c, ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name from ASI_MFM_Sub_brand__c where RecordType.DeveloperName  like '%CN%' and  id in: SBBrandSet]){
            if(sb.ASI_MFM_Brand__c!=null){
                if(sb.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){  
                ProductCategoryMap.put(sb.Id, sb.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name);//
                } 
            }
        }

        Map<String, ASI_MFM_Sub_brand__c> SubBrandGradeMapping= new Map<String, ASI_MFM_Sub_brand__c> ();  
        for(ASI_MFM_Sub_brand__c sb:[select Id,Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c 
                                     from ASI_MFM_Sub_brand__c 
                                     where RecordType.DeveloperName  like '%CN%' and  id in: SBBrandSet]){
            SubBrandGradeMapping.put(sb.Id, sb);
        }

        Map<String,Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>> nosubbrandMap = new Map<String,Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>>();

        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> lastversionbytotalMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        if (contract.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c != '0.0') {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : [SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Product_Category_Name__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :contract.ASI_CRM_CN_Last_PO_version__c AND ASI_CRM_Volume_Base__c!= 'By Sub-Brand']) {
                if (item.ASI_CRM_Volume_Base__c == 'By Grade') {
                    if (nosubbrandMap.containsKey(item.ASI_CRM_Module__c)) {
                        nosubbrandMap.get(item.ASI_CRM_Module__c).put(item.ASI_CRM_Sub_Brand_Grade__c,item);
                    } else {
                        nosubbrandMap.put(item.ASI_CRM_Module__c, new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>{item.ASI_CRM_Sub_Brand_Grade__c => item});
                    }
                }
                if (item.ASI_CRM_Volume_Base__c == 'By Category') {
                    if (nosubbrandMap.containsKey(item.ASI_CRM_Module__c)) {
                        nosubbrandMap.get(item.ASI_CRM_Module__c).put(item.ASI_CRM_Product_Category_Name__c,item);
                    } else {
                        nosubbrandMap.put(item.ASI_CRM_Module__c, new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>{item.ASI_CRM_Product_Category_Name__c => item});
                    }
                }

                if (item.ASI_CRM_Volume_Base__c == 'By Total') {
                    lastversionbytotalMap.put(item.ASI_CRM_Module__c, item);
                }
            }
        }


        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : contractDetailLines) {
            if (line.ASI_CRM_Type__c == 'BRSF') {
                if (ProductCategoryMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)) {
                    String category = ProductCategoryMap.get(line.ASI_CRM_CN_Sub_Brand__c);
                    if (categoryLineMap.containsKey(category)) {
                        categoryLineMap.get(category).add(line);
                    } else {
                        categoryLineMap.put(category, new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> {line});
                    }
                }
            }
        }


        Map<String,Decimal> CR12FactorMap= new Map<String,Decimal> ();
        
        CR12FactorMap= ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(sbbrandIds,contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c);

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : contractDetailLines) {
            if (line.ASI_CRM_Type__c != 'BRSF') {
                if (line.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfline = subbrandLineMap.get(line.ASI_CRM_CN_Sub_Brand__c);
                    line.ASI_CRM_CN_Est_Monthly_Qty__c = brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c;

                    line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c*line.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*Contract.ASI_CRM_CN_No_of_Months__c;

                    line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Monthly_Qty__c == null ? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c*line.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c*Contract.ASI_CRM_CN_No_of_Months__c;
                }
                if (line.ASI_CRM_Volume_Base__c == 'By Grade') {
                    if (gradeLineMap.containsKey(line.ASI_CRM_Sub_Brand_Grade__c)) {
                        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsflineList = gradeLineMap.get(line.ASI_CRM_Sub_Brand_Grade__c);
                        line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0.00;
                        line.ASI_CRM_Est_Total_QTY_std_Btl__c = 0.00;
                        line.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c = 0.00;
                        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine : brsflineList) {
                            Decimal CR12Factor=1;
                            if(CR12FactorMap.containsKey(brsfLine.ASI_CRM_CN_Sub_Brand__c)){
                                CR12Factor=CR12FactorMap.get(brsfLine.ASI_CRM_CN_Sub_Brand__c);
                            }
                            // System.debug(LoggingLevel.INFO, '*** CR12Factor: ' + CR12Factor);
                            line.ASI_CRM_CN_Est_Monthly_Qty__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null ? 0: brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c);

                            line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor *Contract.ASI_CRM_CN_No_of_Months__c;

                            line.ASI_CRM_Est_Total_QTY_std_Btl__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c *Contract.ASI_CRM_CN_No_of_Months__c;
                            
                            line.ASI_CRM_Est_Monthly_Volume_CR12__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Contract_Monthly_Volume_CR12__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                            if (SubBrandGradeMapping.get(brsfLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<=4 ) {

                                line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c ;

                                line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c ;
                            }

                        }

                        if (line.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                            if (nosubbrandMap.containsKey(line.ASI_CRM_Module__c)) {
                                if (nosubbrandMap.get(line.ASI_CRM_Module__c).containsKey(line.ASI_CRM_Sub_Brand_Grade__c)) {
                                    ASI_CRM_CN_Contract_BRSF_Line_Item__c lastLine = nosubbrandMap.get(line.ASI_CRM_Module__c).get(line.ASI_CRM_Sub_Brand_Grade__c);
                                    line.ASI_CRM_CN_Est_Total_Dummy__c = (lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0 || lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null) ? 0 : (lastLine.ASI_CRM_CN_Est_Total_Dummy__c/lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                                }
                            }
                        } else {
                            line.ASI_CRM_CN_Est_Total_Dummy__c = (line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0 || line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null) ? 0 : (line.ASI_CRM_CN_Contract_Total_Dummy__c/line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                        }
                    }
                }

                if (line.ASI_CRM_Volume_Base__c == 'By Category') {
                    if (categoryLineMap.containsKey(line.ASI_CRM_Product_Category_Name__c)) {
                        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsflineList = categoryLineMap.get(line.ASI_CRM_Product_Category_Name__c);
                        line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0.00;
                        line.ASI_CRM_Est_Total_QTY_std_Btl__c = 0.00;
                        line.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c = 0.00;
                        line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c = 0.00;
                        line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c = 0.00;
                        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine : brsflineList) {
                            Decimal CR12Factor=1;
                            if(CR12FactorMap.containsKey(brsfLine.ASI_CRM_CN_Sub_Brand__c)){
                                CR12Factor=CR12FactorMap.get(brsfLine.ASI_CRM_CN_Sub_Brand__c);
                            }
                            // System.debug(LoggingLevel.INFO, '*** CR12Factor: ' + CR12Factor);
                            line.ASI_CRM_CN_Est_Monthly_Qty__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null ? 0: brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c);

                            line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor *Contract.ASI_CRM_CN_No_of_Months__c;

                            line.ASI_CRM_Est_Total_QTY_std_Btl__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c *Contract.ASI_CRM_CN_No_of_Months__c;
                            
                            line.ASI_CRM_Est_Monthly_Volume_CR12__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Contract_Monthly_Volume_CR12__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                            if (SubBrandGradeMapping.get(brsfLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<=4 ) {

                                line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c ;

                                line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                                line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c ;
                            }
                        }

                        if (line.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                            if (nosubbrandMap.containsKey(line.ASI_CRM_Module__c)) {
                                if (nosubbrandMap.get(line.ASI_CRM_Module__c).containsKey(line.ASI_CRM_Product_Category_Name__c)) {
                                    ASI_CRM_CN_Contract_BRSF_Line_Item__c lastLine = nosubbrandMap.get(line.ASI_CRM_Module__c).get(line.ASI_CRM_Product_Category_Name__c);
                                    line.ASI_CRM_CN_Est_Total_Dummy__c = (lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0 || lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null) ? 0 : (lastLine.ASI_CRM_CN_Est_Total_Dummy__c/lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                                }
                            }
                        } else {
                            line.ASI_CRM_CN_Est_Total_Dummy__c = (line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0 || line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null) ? 0 : (line.ASI_CRM_CN_Contract_Total_Dummy__c/line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                        }
                    }
                }

                if (line.ASI_CRM_Volume_Base__c == 'By Total') {
                    line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0.00;
                    line.ASI_CRM_Est_Total_QTY_std_Btl__c = 0.00;
                    line.ASI_CRM_Est_Monthly_Volume_CR12__c = 0.00;
                    line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c = 0.00;
                    line.ASI_CRM_CN_Est_Monthly_Qty__c = 0.00;
                    line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c = 0.00;
                    line.ASI_CRM_Contract_Monthly_Volume_CR12__c = 0.00;
                    line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c = 0.00;
                    line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c = 0.00;
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine : subbrandLineMap.values()) {
                        Decimal CR12Factor=1;
                        if(CR12FactorMap.containsKey(brsfLine.ASI_CRM_CN_Sub_Brand__c)){
                            CR12Factor=CR12FactorMap.get(brsfLine.ASI_CRM_CN_Sub_Brand__c);
                        }

                        line.ASI_CRM_CN_Est_Monthly_Qty__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null ? 0: brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c);

                        line.ASI_CRM_Est_Monthly_Volume_CR12__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                        line.ASI_CRM_Contract_Monthly_Volume_CR12__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                        line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor *Contract.ASI_CRM_CN_No_of_Months__c;

                        line.ASI_CRM_Est_Total_QTY_std_Btl__c += (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c *Contract.ASI_CRM_CN_No_of_Months__c;

                        if (SubBrandGradeMapping.get(brsfLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<=4 ) {

                            line.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Est_Monthly_Qty__c ;

                            line.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor ;

                            line.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c+= (brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:brsfLine.ASI_CRM_CN_Contract_Monthly_Qty__c ;
                        }
                    }

                    if (line.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c != '0.0') {
                        if (lastversionbytotalMap.containsKey(line.ASI_CRM_Module__c)) {
                            ASI_CRM_CN_Contract_BRSF_Line_Item__c lastLine = lastversionbytotalMap.get(line.ASI_CRM_Module__c);
                            line.ASI_CRM_CN_Est_Total_Dummy__c = (lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == 0 || lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null) ? 0 : (lastLine.ASI_CRM_CN_Est_Total_Dummy__c/lastLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                        }
                    } else {
                        line.ASI_CRM_CN_Est_Total_Dummy__c = (line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0 || line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null) ? 0 : (line.ASI_CRM_CN_Contract_Total_Dummy__c/line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c*line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                    }
                }
            }
        }

        return contractDetailLines;
    }

    public static Decimal GeneratingIncentive(Map<String, ASI_CRM_Sub_Brand_Grade__c> SBGradeMap ,String SubBrandGradeName,String TypeName , ASI_TH_CRM_Contract__c ContractSelected){
        
        
        Decimal Incentive=0.0;
        String ExternalKey=SubBrandGradeName;
        
        ExternalKey+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c:'';
        ExternalKey+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
        
        String CityTierExternalKey = ExternalKey;
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c!=null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
            CityTierExternalKey+= ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
        }
        
        if(TypeName =='BRSFDefault'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
            }else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
            }else if(SBGradeMap.containsKey(SubBrandGradeName)){Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_CN_Incentive__c;
            }            
        }
        
        
        
        if(TypeName =='BRSFMax'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;
            }
            else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
            }
            else if(SBGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
            }            
        }
        
        if(TypeName =='PSFMax'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;                                                          
            }
            else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }
            else if(SBGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive_for_PSF__c;
            }
        }

        //3.18新增
        if(TypeName =='FCMax'){
            if(SBGradeMap.containsKey(CityTierExternalKey)){ Incentive=SBGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;                                                          
            }
            else if(SBGradeMap.containsKey(ExternalKey)){ Incentive=SBGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
            }
            else if(SBGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SBGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
            }
        }
        
        
        if(Incentive==null){ Incentive=0;
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
            } else {
                Incentive = 0.00;
            }
        }


        if(TypeName =='VECMax'){
            if(gsMap.containsKey(CityTierExternalKey)){ 
                Incentive=gsMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_VEC__c;
            } else {
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
    
    
    
    //MethodologyCode : M01: Min (BC, Intake)  (Min of CTD Actual Vol (Std Btl) &&     CTD Cap Collection Vol (Std Btl)   )
    //M02  :  BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC                  
    //M03: Min (BC/V0.0 BC%, Intake)       
    //M04 : Intake 
    //M05: Others 
    //UseInputBCRateOrNot ---> if true, use (InputBC/InputIntake) to calculate BC Rate
    //UseInputBCRateOrNot ---> if false, use InputBCRate to calculate BC Rate , but  for return value , it will be 'InputIntake or InputBC'
    public static Decimal MethodologyDecision(String MethodologyCode,Decimal InputIntake,Decimal InputBC,Decimal InputBCRate, Decimal ComparedBCRate,Boolean UseInputBCRateOrNot){
        Decimal ReturnNumber=0;
        Decimal BCRate=0;
        system.debug('Enter MethodologyDecision:InputBC :  '+InputBC+'InputIntake : '+InputIntake+ '  MethodologyCode  : '+MethodologyCode );
        if(!UseInputBCRateOrNot){
            BCRate=InputBCRate;
        }else if(InputIntake!=0 && InputIntake!=null){ // UseInputBCRateOrNot = true
            BCRate=(InputBC/InputIntake)*100;
        }
        
        if(InputIntake==null){
            InputIntake=0;
        }
        if(InputBC==null){
            InputBC=0;
        }
        //************************compare**********************************
        if(MethodologyCode=='M01'){
            if(InputIntake>InputBC){
                ReturnNumber=InputBC;
            }else{
                ReturnNumber=InputIntake;
            }
        }else if(MethodologyCode=='M02'){
            if(BCRate>=ComparedBCRate){
                ReturnNumber=InputIntake;
            }else{
                ReturnNumber=InputBC;
            }
            
            if(InputIntake<=0){
                ReturnNumber=0;
            }
        }else if(MethodologyCode=='M03'){
            
            Decimal CalIntake=0;
            CalIntake=(InputBC/ComparedBCRate)*100;
            if(CalIntake>InputIntake){
                ReturnNumber=InputIntake;
            }else{
                ReturnNumber=CalIntake;
            }
            
        }else if(MethodologyCode=='M04'){
            ReturnNumber=InputIntake;
        }else if(MethodologyCode=='M05'){
            ReturnNumber=0;
        }else{
            ReturnNumber=InputIntake;
        }
        
        
        return ReturnNumber;
    }
    
    
    public static Boolean IsMartellSubBrandOrNot(String BrandCode){
        return BrandCode=='MAR';
    }
    
    public Class VolumeObject{
        //V0.0 Full Contract Target/合同销量目标
        
        public Decimal FullContractTarget {set;get;}{FullContractTarget=0;}
        //Actual Performance
        public Decimal CTDActualVol {set;get;}{CTDActualVol=0;}
        public String SubBrandGradeName {set;get;}{SubBrandGradeName='';}
        public VolumeObject(){
            
        }
    }


    public static String SplitLineIntoRow(String InputString, integer CutNumber) {
        if (InputString == null) {
            return '';
        }
        String outputString = '';
        if (!ASI_CRM_CN_HeavyContracFunctionClass.containsEnglishCharacters(InputString) && ASI_CRM_CN_HeavyContracFunctionClass.containsChineseCharacters(InputString)) {

            try {
                if (InputString.length() >= CutNumber) {
                    while (InputString.length() >= CutNumber) {
                        outputString = outputString + InputString.subString(0, CutNumber) + '<br/>';
                        InputString = InputString.subString(CutNumber);
                    }
                }
                outputString = outputString + InputString;
            } catch (exception e) {
                outputString = InputString;
            }
        } else {
            outputString = InputString;
        }


        return outputString;
    }

    public static void PaymentKPICalculation2nd(ASI_TH_CRM_PaymentRequest__c PaymentRequest ){
        Map<String,Decimal> PaymentKPIMap= new Map<String,Decimal>();
        
        //KPI 
        Decimal FixedCostTotal = 0 ; 
        Decimal VariableCostTotal=0;
        Decimal PaymentSpeed = 0 ;
        Decimal VolumeSpeed=0;
        
        
        
        //Payment Speed
        Decimal TotalPaymentAmount = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(PaymentRequest);
        Decimal v0_Cost = 0;
        Decimal V0ContractVolume=0;
        Decimal ActualIntake=0;
        
        //Min Key Strategy sub-brands achievement% should greater or equal to total volume achievement%.
        Decimal  MKSSBAR=9999999;// Min Key Strategy SubBrand Achievement Rate 
        
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [Select id, name,ASI_CRM_CN_Completion_Rate__c, ASI_CRM_Key_Sub_Brand__c , ASI_CRM_Volume_Base__c,RecordType.DeveloperName, recordtypeid, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c  
                                                               from ASI_TH_CRM_PaymentRequestLineItem__c 
                                                               where ASI_TH_CRM_Payment_Request__c = :PaymentRequest.Id ])
        {//and  RecordType.DeveloperName='ASI_CRM_CN_Payment_Request_Detail_Other' 
            // if(PaymentLine.RecordType.DeveloperName =='ASI_CRM_CN_Payment_Request_Detail_Other'){
            //     FixedCostTotal+=PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
            // }
            if(PaymentLine.RecordType.DeveloperName =='ASI_CRM_CN_Payment_Request_Detail_PSF' && PaymentLine.ASI_CRM_Volume_Base__c!=null && PaymentLine.ASI_CRM_CN_Completion_Rate__c !=null && PaymentLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'   && PaymentLine.ASI_CRM_Key_Sub_Brand__c ){
               PaymentKPIMap.put('Key Strategy sub-brands', 1);
                if(PaymentLine.ASI_CRM_CN_Completion_Rate__c<MKSSBAR){
                    MKSSBAR=PaymentLine.ASI_CRM_CN_Completion_Rate__c;
                }
            }
        }
        
        
        PaymentKPIMap.put('MKSSBAR', MKSSBAR);
        
        
        for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
            
            if(module.ASI_CRM_Line_Type__c=='PSF' && module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                PaymentKPIMap.put('PSFBySubBrandAchievementRate', module.ASI_CRM_Completion_Ratio__c);
            }
            if(module.ASI_CRM_Line_Type__c=='Fixed'){
                FixedCostTotal += module.ASI_CRM_Actual_Payment__c;
            }
            else {
                VariableCostTotal+=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
            }
            
        }
        
        
        
        String V0ContractId='';
        if(PaymentRequest.ASI_TH_CRM_Contract__c!=null && PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(PaymentRequest.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=PaymentRequest.ASI_TH_CRM_Contract__c;
        }
        
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractDetailList=[SELECT id, ASI_CRM_Type__c,ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c,
                                                                        ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name, 
                                                                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                                                                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, 
                                                                        ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Monthly_Qty__c , ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,
                                                                        ASI_CRM_CN_Contract__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                                                                        ASI_CRM_CN_Contract_Monthly_Vol9L__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                                                                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                                                                        ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c
                                                                        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0ContractId];
        
        Set<Id> SubBrandIdSet = new Set<Id> ();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractDetail:contractDetailList){
            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                SubBrandIdSet.add(ContractDetail.ASI_CRM_CN_Sub_Brand__c);
            }
        }
        
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        if(SubBrandIdSet.size()>0){
            CR12FactorMap=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(SubBrandIdSet,
                                                                                       PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                                                                       PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c);
        }
        
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetail:contractDetailList)
        {
            v0_Cost+= contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            if(contractDetail.ASI_CRM_Type__c=='BRSF'){
                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(contractDetail.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(contractDetail.ASI_CRM_CN_Sub_Brand__c);
                }
                V0ContractVolume+=CR12Factor*contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c * contractDetail.ASI_CRM_CN_No_of_Months__c;
            }
        }
        
        
        
        if (v0_Cost != null && v0_Cost !=0 && TotalPaymentAmount != null && TotalPaymentAmount != 0){
            system.debug('Now TotalPaymentAmount'+ TotalPaymentAmount);
            system.debug('Now v0_Cost'+ v0_Cost);
            PaymentSpeed = TotalPaymentAmount / v0_Cost * 100;
        }
        
        
        ///*******************Calculate Volume Speed*******************************************************************
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
                             FROM ASI_CRM_CN_Covered_Outlet__c
                             WHERE ASI_CRM_CN_Contract__c = :PaymentRequest.ASI_TH_CRM_Contract__c];
        }catch(exception e){
            CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }  
        
        set<id> AllOutlet = new set<id>();
        //ASI_TH_CRM_PaymentRequest__c tempPR = [SELECT id, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :thisPR.id]; 
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(PaymentRequest.ASI_CRM_CN_OutletWS__c);
        }
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }
        
        list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c> ();
        date TillEnd = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate(), PaymentRequest.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        system.debug('SB Vol TillEnd : '+TillEnd);
        try{
            SB_Vol_List = [SELECT Id,Name,ASI_CRM_T1_Depletion_Std_Billing__c,ASI_CRM_DeductibleCapWithIssues_Std_Btl__c, ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_Std_Billing__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c, ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,ASI_CRM_PR_Direct__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c, ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c 
                           FROM ASI_CRM_Subbrand_Volume__c 
                           WHERE ASI_CRM_End_Date__c >= :PaymentRequest.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_End_Date__c <= :TillEnd  AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                           AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false and ASI_CRM_Subbrand__c !=null];
            
        }catch(exception e){
            SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c >();
        }
        
        if (SB_Vol_List.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : SB_Vol_List ){
                ActualIntake += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null?SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
                ActualIntake += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null?SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
                ActualIntake += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null?SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;
                
            }
            
        }
        
        
        if (V0ContractVolume != null && V0ContractVolume !=0 && ActualIntake != null && ActualIntake != 0){
            system.debug('ActualIntake'+ActualIntake);
            system.debug('V0ContractVolume'+V0ContractVolume);
            VolumeSpeed = (ActualIntake / V0ContractVolume) * 100;
        }
        
        
        PaymentKPIMap.put('FixedCostTotal',FixedCostTotal);
        
        PaymentKPIMap.put('VariableCostTotal',VariableCostTotal);
        PaymentKPIMap.put('PaymentSpeed',PaymentSpeed);
        
        PaymentKPIMap.put('VolumeSpeed',VolumeSpeed);
        
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(PaymentRequest.ASI_TH_CRM_Contract__c, System.JSON.serialize(PaymentKPIMap),'Payment Data' );
    }
    
    
    public Class interimData{
        public ASI_CRM_Module__c Module {set;get;} 
        public boolean HaveRefresh  {set;get;} 
        public String MethodologyValue  {set;get;} {MethodologyValue='';}
        public String MethodologyDisplay  {set;get;} {MethodologyDisplay='';}
        
        
        public map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}
        
        public interimData(){
            this.Module=new ASI_CRM_Module__c();
            this.MethodologyValue='';
            DetailLineMap= new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.HaveRefresh=true;
        }
        public interimData(boolean ClickRefresh){
            this.Module=new ASI_CRM_Module__c();
            this.MethodologyValue='';
            this.DetailLineMap= new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.HaveRefresh=ClickRefresh;
        }
        
        public interimData( ASI_CRM_Module__c ModuleInput){
            this.Module=ModuleInput;
            this.DetailLineMap= new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.HaveRefresh=true;
        }
        
        public interimData( ASI_CRM_Module__c ModuleInput,boolean ClickRefresh){
            this.Module=ModuleInput;
            this.DetailLineMap= new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            this.HaveRefresh=ClickRefresh;
        }
    }
    
    
}