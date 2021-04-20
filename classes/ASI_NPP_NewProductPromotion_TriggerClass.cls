/*
*********************************************************************************
 * Name: ASI_NPP_NewProductPromotion_TriggerClass
 * Description: 
 * Test Class: ASI_NPP_SG_TestClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/06/2017       Wilken Lee              [WL 1.0] CHM114427152 NPA Multiple Market Enhancement
 * 21/08/2017       Wilken Lee              [WL 2.0] Validate Status before delete
 * 04/07/2018       Wilken Lee              [WL 3.0] Get Sub-brand Budget Volume by Fiscal Year
*/
public class ASI_NPP_NewProductPromotion_TriggerClass {
        public static void validateStatusBeforeDelete(List<ASI_NPP_New_Product_Promotion__c> trigger_old) {
            for (ASI_NPP_New_Product_Promotion__c old:trigger_old){
                if (old.ASI_NPP_status__c != 'Draft')
                    old.addError('Only Draft status New Product/Promotion Form can be deleted');
            }
        }
        
        public static void assignApprover(List<ASI_NPP_New_Product_Promotion__c> NPPList, Map<Id,ASI_NPP_New_Product_Promotion__c> oldMapNPP) { //assign approver based on market, retrieved from ASI NPA Route Type object
            List<ASI_NPP_Route_Type__c> routeTypeList = [SELECT Name, ASI_NPP_Approver_2__c, ASI_NPP_Approver_3__c, ASI_NPP_Approver_4__c, ASI_NPP_Approver_5__c
                FROM ASI_NPP_Route_Type__c WHERE recordTypeId = :Global_RecordTypeCache.getRtId('ASI_NPP_Route_Type__cASI_NPP_SG_Route_Type')];

            Set<Id> ownerIdSet = new Set<Id>();

            for (ASI_NPP_New_Product_Promotion__c npp:NPPList){
                for (ASI_NPP_Route_Type__c routeType:routeTypeList){
                    if (npp.ASI_NPP_Market__c == routeType.Name){
                        npp.ASI_NPP_Approver_2__c = routeType.ASI_NPP_Approver_2__c;
                        npp.ASI_NPP_Approver_3__c = routeType.ASI_NPP_Approver_3__c;
                        npp.ASI_NPP_Approver_4__c = routeType.ASI_NPP_Approver_4__c;
                        npp.ASI_NPP_Approver_5__c = routeType.ASI_NPP_Approver_5__c;
                    }
                }
                ownerIdSet.add(npp.OwnerId);

                //Copy Size picklist value to Packing Size per Bottle number field for volume conversion
                if (npp.ASI_NPP_Size_Single__c != null)
                    npp.ASI_NPP_Packing_Size_Per_Bottle__c = Decimal.valueOf(npp.ASI_NPP_Size_Single__c);

                /*
                If “Cost by Brand Company – VAP” is blank, no need to enter PO, NPA status change to Complete once approved by Director
                If “Cost by Brand Company – VAP” is not blank, requester will receive email when NPA is Final (approved by Director), once they fill in PO, then NPA status will becomes Complete and Ops & market specific BA team will be notified
                */
                if (npp.ASI_NPP_status__c == 'Final' && oldMapNPP.get(npp.Id).ASI_NPP_status__c == 'Submitted' && npp.ASI_NPP_Brand_Company_VAP__c == null)
                    npp.ASI_NPP_status__c = 'Complete';

            }

            Map<Id,User> ownerWithManagerMap = new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN :ownerIdSet]);
            for (ASI_NPP_New_Product_Promotion__c npp:NPPList){
                npp.ASI_NPP_Approver_1__c = ownerWithManagerMap.get(npp.ownerId).ManagerId;
            }
        }

        public static void setReportingCurrToBaseCurrExRate(List<ASI_NPP_New_Product_Promotion__c> NPPList) { //calculate ex rate of Base Curr (amount entered by user) to Reporting Currency
        Date nppCreateDate = Date.newInstance(2000, 1, 1);

        Set<String> currencySet = new Set<String>();

        for (ASI_NPP_New_Product_Promotion__c npp:NPPList){
            if (nppCreateDate == null){
                nppCreateDate = Date.valueOf(npp.CreatedDate);
            }
            else if (npp.CreatedDate > nppCreateDate){
                nppCreateDate = Date.valueOf(npp.CreatedDate);
            }

            if (npp.ASI_NPP_Reporting_Currency__c == null)
                npp.ASI_NPP_Reporting_Currency__c = npp.ASI_NPP_Market_Currency__c;

            currencySet.add(npp.ASI_NPP_Market_Currency__c);
            currencySet.add(npp.ASI_NPP_Reporting_Currency__c);
        }

        List<ASI_MFM_Exchange_Rate__c> exRateList = [SELECT ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c FROM ASI_MFM_Exchange_Rate__c 
            WHERE ASI_MFM_Country__c = 'SG' AND ASI_MFM_Application__c = 'NPP' AND ASI_MFM_Effective_Date__c <= :nppCreateDate AND (ASI_MFM_Base_Currency__c in :currencySet OR ASI_MFM_Counter_Currency__c in :currencySet)
                ORDER BY ASI_MFM_Effective_Date__c DESC];

        for (ASI_NPP_New_Product_Promotion__c npp:NPPList){
            if (npp.ASI_NPP_Market_Currency__c == npp.ASI_NPP_Reporting_Currency__c)
                //If NPP Market Currency = NPP Reporting Currency, no exchange rate conversion is needed.
                npp.ASI_NPP_Ex_Rate_To_Report_Curr__c = 1;
            else if (npp.ASI_NPP_Reporting_Currency__c == 'SGD'){
                //If NPP Reporting Currency is SGD, which is same as Exchange Rate Master's Base Currency, then directly retrieve NPP Market Currency from Exchange Rate master's Counter Currency
                for (ASI_MFM_Exchange_Rate__c exRate:exRateList){
                    if (npp.ASI_NPP_Reporting_Currency__c == exRate.ASI_MFM_Base_Currency__c && npp.ASI_NPP_Market_Currency__c == exRate.ASI_MFM_Counter_Currency__c && exRate.ASI_MFM_Effective_Date__c <= npp.CreatedDate){
                        npp.ASI_NPP_Ex_Rate_To_Report_Curr__c = exRate.ASI_MFM_Exchange_Rate__c;
                        break;
                    }
                }
            }
            else if (npp.ASI_NPP_Reporting_Currency__c != 'SGD'){
                //E.g. Market Currency is USD, Reporting Currency is PHP
                Decimal marketCurrToSGDRate = 0;
                Decimal reportCurrToSGDRate = 0;

                //Retrieve Market Currency to SGD Rate
                if (npp.ASI_NPP_Market_Currency__c == 'SGD')
                    marketCurrToSGDRate = 1;
                else {
                    for (ASI_MFM_Exchange_Rate__c exRate:exRateList){
                        if (exRate.ASI_MFM_Base_Currency__c == 'SGD' && npp.ASI_NPP_Market_Currency__c == exRate.ASI_MFM_Counter_Currency__c && exRate.ASI_MFM_Effective_Date__c <= npp.CreatedDate){
                            marketCurrToSGDRate = exRate.ASI_MFM_Exchange_Rate__c;
                            break;
                        }
                    }
                }

                //Retrieve Reporting Currency to SGD Rate
                for (ASI_MFM_Exchange_Rate__c exRate:exRateList){
                    if (exRate.ASI_MFM_Base_Currency__c == 'SGD' && npp.ASI_NPP_Reporting_Currency__c == exRate.ASI_MFM_Counter_Currency__c && exRate.ASI_MFM_Effective_Date__c <= npp.CreatedDate){
                        reportCurrToSGDRate = exRate.ASI_MFM_Exchange_Rate__c;
                        break;
                    }
                }

                npp.ASI_NPP_Ex_Rate_To_Report_Curr__c = (marketCurrToSGDRate/reportCurrToSGDRate).setScale(6);
            }
        }
    }

    public static void setSubBrandBudgetVolume(List<ASI_NPP_New_Product_Promotion__c> trigger_new, Map<id,ASI_NPP_New_Product_Promotion__c> oldMap) {
        Set<ID> nppIDSet = new Set<ID>();
        List<ASI_NPP_New_Product_Promotion__c> nppUpdate = new List<ASI_NPP_New_Product_Promotion__c>();
        
        for(ASI_NPP_New_Product_Promotion__c npp : trigger_new) {
			/*[WL 3.0] BEGIN*/
            if (oldMap == null || (oldMap != null && (npp.ASI_NPP_Sub_brand__c != oldMap.get(npp.id).ASI_NPP_Sub_brand__c) 
				|| npp.ASI_NPP_Fiscal_Year__c != oldMap.get(npp.id).ASI_NPP_Fiscal_Year__c)) //Cater fiscal year update
			/*[WL 3.0] END*/
                nppIDSet.add(npp.id);
                nppUpdate.add(npp);
        }
        
        if (nppIDSet.size() > 0){
			/*[WL 3.0] BEGIN*/			
            List<ASI_NPP_Budget_Volume__c> budgetVolList = [select id, ASI_NPP_Budget_Volume__c, ASI_NPP_Sub_Brand__c, ASI_NPP_Fiscal_Year__c from ASI_NPP_Budget_Volume__c where 
                recordtypeid = :Global_RecordTypeCache.getRtId('ASI_NPP_Budget_Volume__cASI_NPP_SG_Budget_Volume_Record_Type') AND ASI_NPP_Inactive__c = false
					and ASI_NPP_Fiscal_Year__c = :trigger_new.get(0).ASI_NPP_Fiscal_Year__c]; //Added Fiscal Year filter
            /*[WL 3.0] END*/
			
            Map<ID, Decimal> sbVolMap = new Map<ID, Decimal>();
            
            for (ASI_NPP_Budget_Volume__c vol:budgetVolList){
                sbVolMap.put(vol.ASI_NPP_Sub_Brand__c, vol.ASI_NPP_Budget_Volume__c);
            }
            
            for(ASI_NPP_New_Product_Promotion__c npp : nppUpdate) {
				/*[WL 3.0] BEGIN*/	
				npp.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = null;	
				/*[WL 3.0] END*/	
				
                if (npp.ASI_NPP_Sub_brand__c != null && sbVolMap.get(npp.ASI_NPP_Sub_brand__c) != null && sbVolMap.get(npp.ASI_NPP_Sub_brand__c) != null){
                    npp.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = sbVolMap.get(npp.ASI_NPP_Sub_brand__c);
                }
            }
        }       
    }
    
    public static void SetSGAutoNumber(List<ASI_NPP_New_Product_Promotion__c> NPPList) { //Set running number for Recordtype SG
        List<ASI_NPP_New_Product_Promotion__c> NPPs = NPPList;
        List<ASI_NPP_New_Product_Promotion__c> SGNPPs = [SELECT Name FROM ASI_NPP_New_Product_Promotion__c where RecordType.Name = 'SG New Product or Promotion' AND Name LIKE 'NPA%' order by Name desc limit 1];
        Integer TotalNPP = SGNPPs.size();
        String starting = '000000';
        String Prefix = 'NPA-';
        if(!SGNPPs.isEmpty()) {
           // System.debug('SOQL have result, First Record Name:' + SGNPPs.get(0).Name);
            starting = SGNPPs.get(0).Name;
            starting = starting.substring(4,10);
           // System.debug('Starting: '+ starting);
        }
       // System.debug('Starting:' + starting);
        for(ASI_NPP_New_Product_Promotion__c NPP : NPPs) {
            starting = String.valueOf(Integer.valueOf(starting) + 1);
            starting = '000000'.substring(0, 6-starting.length()) + starting;
            NPP.Name = Prefix + starting;
           // System.debug('NPP Name:' + NPP.Name);
           // NPP.ASI_NPP_status__c = 'Draft';
        }
        
    }
    
    public static void GetCalculationBase(List<ASI_NPP_New_Product_Promotion__c> NPPList) { //get pnl base from object Pnl  Base
        List<ASI_NPP_New_Product_Promotion__c> NPPs = NPPList;
        List<ASI_MFM_Exchange_Rate__c> RateLists = [SELECT ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c, ASI_NPP_Fiscal_Year__c FROM ASI_MFM_Exchange_Rate__c WHERE ASI_MFM_Country__c = 'SG' AND ASI_MFM_Application__c = 'NPP'];

        /*[WL 1.0 Begin]*/
        //List<ASI_NPP_Calculation_Base__c> CalBaseLists = [SELECT ASI_NPP_BB__c, ASI_NPP_Benchmark_CAAP__c, ASI_NPP_Benchmark_CM__c, ASI_NPP_Distribution__c, ASI_NPP_FASTAR__c, ASI_NPP_Fiscal_Year__c, ASI_NPP_Handling__c, ASI_NPP_Prompt_Payment_Discount__c, ASI_NPP_Sub_brand__c  FROM ASI_NPP_Calculation_Base__c WHERE RecordType.Name = 'SG Calculation Base'];
        List<ASI_NPP_Calculation_Base__c> CalBaseLists = [SELECT ASI_NPP_BB__c, ASI_NPP_Benchmark_CAAP__c, ASI_NPP_Benchmark_CM__c, ASI_NPP_Distribution__c, ASI_NPP_FASTAR__c, ASI_NPP_Fiscal_Year__c, ASI_NPP_Handling__c, ASI_NPP_Prompt_Payment_Discount__c, ASI_NPP_Sub_brand__c, ASI_NPP_Market__c FROM ASI_NPP_Calculation_Base__c WHERE RecordType.Name = 'SG Calculation Base'];
        /*[WL 1.0 Begin]*/
        boolean Have_FOB;
        boolean Have_VAP;
        for (ASI_NPP_New_Product_Promotion__c NPP : NPPs){
            Have_FOB = false;
            Have_VAP = false;
            if (NPP.ASI_NPP_FOB_Currency__c == 'SGD'){
                NPP.ASI_NPP_FOB_Exchange_Rate__c = 1;
                Have_FOB = true;
            }
            if (NPP.ASI_NPP_VAP_Currency__c == 'SGD'){
                NPP.ASI_NPP_VAP_Exchange_Rate__c = 1;
                Have_VAP = true;
            }
           // system.debug('RateList: ' + RateLists.Size());
            for (ASI_MFM_Exchange_Rate__c RateList : RateLists){
                //system.debug('Rate Fiscal Year: ' + RateList.ASI_NPP_Fiscal_Year__c);
                //system.debug('Rate Corrency: ' + RateList.ASI_MFM_Counter_Currency__c);
                if (RateList.ASI_NPP_Fiscal_Year__c == NPP.ASI_NPP_Fiscal_Year__c && RateList.ASI_MFM_Counter_Currency__c == NPP.ASI_NPP_FOB_Currency__c)
                {
                    NPP.ASI_NPP_FOB_Exchange_Rate__c = RateList.ASI_MFM_Exchange_Rate__c;
                    Have_FOB = true;
                }           
            }
            for (ASI_MFM_Exchange_Rate__c RateList : RateLists){
                if (RateList.ASI_NPP_Fiscal_Year__c == NPP.ASI_NPP_Fiscal_Year__c && RateList.ASI_MFM_Counter_Currency__c == NPP.ASI_NPP_VAP_Currency__c)
                {
                    NPP.ASI_NPP_VAP_Exchange_Rate__c = RateList.ASI_MFM_Exchange_Rate__c;
                    Have_VAP = true;
                }           
            }
            
            for (ASI_NPP_Calculation_Base__c CalBase : CalBaseLists)
            {
                /*[WL 1.0 Begin]*/
                //if (CalBase.ASI_NPP_Fiscal_Year__c == NPP.ASI_NPP_Fiscal_Year__c && CalBase.ASI_NPP_Sub_brand__c == NPP.ASI_NPP_Sub_brand__c)
                if (CalBase.ASI_NPP_Fiscal_Year__c == NPP.ASI_NPP_Fiscal_Year__c && CalBase.ASI_NPP_Sub_brand__c == NPP.ASI_NPP_Sub_brand__c && CalBase.ASI_NPP_Market__c == NPP.ASI_NPP_Market__c)
                /*[WL 1.0 End*/
                {
                    NPP.ASI_NPP_Handling_L__c = CalBase.ASI_NPP_Handling__c;
                    NPP.ASI_NPP_Distribution_L__c = CalBase.ASI_NPP_Distribution__c;
                    IF (NPP.ASI_NPP_Distribution_Channel__c != null){
                    If (NPP.ASI_NPP_Distribution_Channel__c.contains('Offtrade'))
                        {
                            NPP.ASI_NPP_BB_9LC__c = 0;
                            NPP.ASI_NPP_Prompt_Payment_Discount__c = 0;
                        }
                        else
                        {
                            NPP.ASI_NPP_BB_9LC__c = CalBase.ASI_NPP_BB__c;
                            NPP.ASI_NPP_Prompt_Payment_Discount__c = CalBase.ASI_NPP_Prompt_Payment_Discount__c;
                        } 
                    }

                    system.debug('Assign Benchmark: NPP Market: ' + NPP.ASI_NPP_Market__c + ' P&L Market: ' + CalBase.ASI_NPP_Market__c);
                    NPP.ASI_NPP_Benchmark_CAAP__c = CalBase.ASI_NPP_Benchmark_CAAP__c;
                    NPP.ASI_NPP_Benchmark_CM__c = CalBase.ASI_NPP_Benchmark_CM__c;   
                }
            }  
            if (NPP.ASI_NPP_Fiscal_Year__c != null && NPP.ASI_NPP_FOB_Currency__c != null){
                if (!Have_FOB){
                    NPP.addError('No exchange rate for ' + NPP.ASI_NPP_FOB_Currency__c + ' is found in ' + NPP.ASI_NPP_Fiscal_Year__c);
                }
            }
            if (NPP.ASI_NPP_Fiscal_Year__c != null && NPP.ASI_NPP_VAP_Currency__c != null){
                if (!Have_VAP )
                {
                    NPP.addError('No exchange rate for ' + NPP.ASI_NPP_FOB_Currency__c + ' is found in ' + NPP.ASI_NPP_Fiscal_Year__c);
                }
            }
        }       
    }
    
    public static void GetPrismaCode(List<ASI_NPP_New_Product_Promotion__c> NPPList) { //get pnl base from object prisma Base
        List<ASI_NPP_New_Product_Promotion__c> NPPs = NPPList;
        List<String> ids = new List<String>(); 
        List<String> RP = new List<String>();
        for (ASI_NPP_New_Product_Promotion__c NPP : NPPs)
        {
            ids.add(NPP.ASI_NPP_PRISMA_code__c);                   
        }  
        List<ASI_NPP_PRISMA_code__c> PriLists = [SELECT id,ASI_NPP_RP9__c, ASI_NPP_RP10__c, ASI_NPP_RP11__c, ASI_NPP_RP12_ST__c , ASI_NPP_RP12_NST__c FROM ASI_NPP_PRISMA_code__c WHERE id in :ids];
        for (ASI_NPP_New_Product_Promotion__c NPP : NPPs)
        {
            for (ASI_NPP_PRISMA_code__c pl : PriLists)
            if(NPP.ASI_NPP_PRISMA_code__c == pl.id)  
            {
                if (pl.ASI_NPP_RP9__c == null)
                {
                    RP.add('--');
                }
                else
                {
                    RP.add(pl.ASI_NPP_RP9__c);  
                }
                if (pl.ASI_NPP_RP10__c == null)
                {
                    RP.add('--');
                }
                else
                {
                    RP.add(pl.ASI_NPP_RP10__c);  
                }
                if (pl.ASI_NPP_RP11__c == null)
                {
                    RP.add('--');
                }
                else
                {
                    RP.add(pl.ASI_NPP_RP11__c);  
                }
                if (pl.ASI_NPP_RP12_ST__c == null)
                {
                    RP.add('--');
                }
                else
                {
                    RP.add(pl.ASI_NPP_RP12_ST__c);  
                }
                if (pl.ASI_NPP_RP12_NST__c == null)
                {
                    RP.add('--');
                }
                else
                {
                    RP.add(pl.ASI_NPP_RP12_NST__c);  
                }
                NPP.ASI_NPP_PRISMA_Detail__c = 'RP9: ' + RP[0] + ', RP10: ' + RP[1] + ', RP11: ' + RP[2] + ', RP12 ST: ' + RP[3] + ', RP12 NST: ' + RP[4];
            }
        } 
    }
    
    public static void SetAssessmentBox(List<ASI_NPP_New_Product_Promotion__c> NPPList) { // if NPL reason of assessment is picked, auto check the assessment check box
        List<ASI_NPP_New_Product_Promotion__c> NPPs = NPPList;
        for (ASI_NPP_New_Product_Promotion__c NPP : NPPs)
        {
            if (!String.isEmpty(Npp.ASI_NPP_Reason_of_Assessment__c))
            {
                NPP.ASI_NPP_New_Product_Assessment_Form__c = true;
                if (NPP.ASI_NPP_Launch_Date__c != null && NPP.ASI_NPP_Start_Launch_Date__c == null)
                {
                    NPP.ASI_NPP_Start_Launch_Date__c = NPP.ASI_NPP_Launch_Date__c;
                }
            }
        }
    }

     public static void PnLCalculationAfterInsert(List<ASI_NPP_New_Product_Promotion__c> NPPList) {
        List<ASI_NPP_New_Product_Promotion__c> NPPs = NPPList;
        List<ASI_NPP_New_Product_Promotion__c> upNpps = new List<ASI_NPP_New_Product_Promotion__c>();
        for (ASI_NPP_New_Product_Promotion__c NPP : NPPs)
        {
            ASI_NPP_New_Product_Promotion__c NPP2 = new ASI_NPP_New_Product_Promotion__c();
            Decimal freegoodselling = 0;
            Decimal contractmargin = 0;
            Decimal promptpaymenttowholesaler = 0;
            Decimal blindbonus = 0;
            Decimal tradingtermssupermarkets = 0;
            Decimal adhoctradingtermsupermarkets = 0;
            Decimal grosssales = 0;
            Decimal FOB_Cost = 0;
            Decimal exciseTax = 0;
            Decimal Duties = 0;
            Decimal Handling_Cost = 0;
            Decimal Distribution_Cost = 0;
            Decimal A_P_Spending = 0;
            Decimal LC_conversion = 0;
            Decimal priceDiscount = 0;
            Decimal rebate = 0;
            //Decimal
            
            if (NPP.ASI_NPP_New_Product_Assessment_Form__c)
            {
                NPP2.id = NPP.id;
                if(NPP.ASI_NPP_Free_Goods_Selling__c != null)
                {
                    freegoodselling = NPP.ASI_NPP_Free_Goods_Selling__c;
                }
                //20170512 Wilken CHM114427152: Total Allowance and Discount = Free Goods value + Price Discount % + Price Discount value per bottle
                /*if(NPP.ASI_NPP_Contract_Margin__c != null)
                {
                    contractmargin = NPP.ASI_NPP_Contract_Margin__c;
                }
                if(NPP.ASI_NPP_Prompt_Payment_to_Wholesaler__c != null)
                {
                    promptpaymenttowholesaler = NPP.ASI_NPP_Prompt_Payment_to_Wholesaler__c;
                }
                if(NPP.ASI_NPP_Blind_Bonus__c != null)
                {
                    blindbonus = NPP.ASI_NPP_Blind_Bonus__c;
                }
                if(NPP.ASI_NPP_Trading_terms_Supermarkets__c != null)
                {
                    tradingtermssupermarkets = NPP.ASI_NPP_Trading_terms_Supermarkets__c;
                }
                if(NPP.ASI_NPP_Ad_hoc_trading_Term_Supermarkets__c != null)
                {
                    adhoctradingtermsupermarkets = NPP.ASI_NPP_Ad_hoc_trading_Term_Supermarkets__c;
                }*/
                if(NPP.ASI_NPP_Gross_Sales__c != null)
                {
                    grosssales = NPP.ASI_NPP_Gross_Sales__c;
                }
                if(NPP.ASI_NPP_FOB_Cost__c != null)
                {
                    FOB_Cost = NPP.ASI_NPP_FOB_Cost__c;
                }
                if(NPP.ASI_NPP_Duties__c != null)
                {
                    Duties = NPP.ASI_NPP_Duties__c;
                }
                if(NPP.ASI_NPP_Excise_Tax__c != null)
                {
                    exciseTax = NPP.ASI_NPP_Excise_Tax__c;
                }
                
                if(NPP.ASI_NPP_Handling_Cost__c != null)
                {
                    Handling_Cost = NPP.ASI_NPP_Handling_Cost__c;
                }
                if(NPP.ASI_NPP_Distribution_Cost__c != null)
                {
                    Distribution_Cost = NPP.ASI_NPP_Distribution_Cost__c;
                }
                if(NPP.ASI_NPP_Total_A_P_Expenses__c != null)
                {
                    A_P_Spending = NPP.ASI_NPP_Total_A_P_Expenses__c;
                }
                if(NPP.ASI_NPP_9LC_conversion__c != null)
                {
                    LC_conversion = NPP.ASI_NPP_9LC_conversion__c;
                }
                if(NPP.ASI_NPP_Price_Discount_Value_Total__c != null)
                {
                    priceDiscount = NPP.ASI_NPP_Price_Discount_Value_Total__c;
                }
                if(NPP.ASI_NPP_Rebate__c != null)
                {
                    rebate = NPP.ASI_NPP_Rebate__c * -1;
                }
                
                //20170512 Wilken CHM114427152: Total Allowance and Discount = Free Goods value + Price Discount % + Price Discount value per bottle
                //NPP2.ASI_NPP_Total_Allowances_Discounts__c = freegoodselling + contractmargin + promptpaymenttowholesaler + blindbonus + tradingtermssupermarkets + adhoctradingtermsupermarkets + 0;
                NPP2.ASI_NPP_Total_Allowances_Discounts__c = freegoodselling + priceDiscount + rebate;

                NPP2.ASI_NPP_Net_Sales__c = NPP2.ASI_NPP_Total_Allowances_Discounts__c + grosssales;
                NPP2.ASI_NPP_Contribution_Margin__c = NPP2.ASI_NPP_Net_Sales__c + FOB_Cost + Duties + exciseTax + Handling_Cost + Distribution_Cost;
                NPP2.ASI_NPP_CAAP__c = NPP2.ASI_NPP_Contribution_Margin__c + A_P_Spending;
                /*[WL 1.0 Begins]*/
                //if (LC_conversion != 0)
                //{
                    //NPP2.ASI_NPP_Net_Sales_Per_Litre__c = NPP2.ASI_NPP_Net_Sales__c / ( LC_conversion * 9 );
                    //NPP2.ASI_NPP_Contribution_Margin_Per_Litre__c = NPP2.ASI_NPP_Contribution_Margin__c  / ( LC_conversion * 9 );
                    //NPP2.ASI_NPP_CAAP_Per_Litre__c = NPP2.ASI_NPP_CAAP__c / ( LC_conversion * 9 );
                /*[WL 1.0 End]*/
                    if(NPP2.ASI_NPP_Net_Sales__c != 0)
                    {
                        NPP2.ASI_NPP_Percent_of_Net_Sales__c = NPP2.ASI_NPP_Net_Sales__c / NPP2.ASI_NPP_Net_Sales__c * 100;
                        NPP2.ASI_NPP_Percent_of_Cost_of_Sales__c = (FOB_Cost + Duties + NPP.ASI_NPP_Excise_Tax__c + Handling_Cost + Distribution_Cost) / NPP2.ASI_NPP_Net_Sales__c * 100;
                        NPP2.ASI_NPP_Percent_of_A_P_Expenses__c = (0 - A_P_Spending) / NPP2.ASI_NPP_Net_Sales__c * 100;

                        /*[WL 1.0 Begins: If both CAAP/CM & Net Sales are negative, need to multiple by -1 to avoid positive result]*/
                        if (NPP2.ASI_NPP_CAAP__c < 0 && NPP2.ASI_NPP_Net_Sales__c < 0)
                            NPP2.ASI_NPP_Percent_of_CAAP__c = -1 * NPP2.ASI_NPP_CAAP__c / NPP2.ASI_NPP_Net_Sales__c * 100;
                        else 
                            NPP2.ASI_NPP_Percent_of_CAAP__c = NPP2.ASI_NPP_CAAP__c / NPP2.ASI_NPP_Net_Sales__c * 100;

                        if (NPP2.ASI_NPP_Contribution_Margin__c < 0 && NPP2.ASI_NPP_Net_Sales__c <0)
                            NPP2.ASI_NPP_Percent_Contribution_Margin__c = -1 * NPP2.ASI_NPP_Contribution_Margin__c / NPP2.ASI_NPP_Net_Sales__c * 100;
                        else 
                            NPP2.ASI_NPP_Percent_Contribution_Margin__c = NPP2.ASI_NPP_Contribution_Margin__c / NPP2.ASI_NPP_Net_Sales__c * 100;
                        /*[WL 1.0 End]*/
                    }
                    
                    
                    IF(NPP.ASI_NPP_Benchmark_CM__c == 0 || NPP.ASI_NPP_Benchmark_CM__c == null)
                    {
                        NPP2.ASI_NPP_Contribution_Margin_Indicators__c = 'BENCHMARK NOT AVAILABLE';  
                    }
                    else
                    {
                        if(NPP.ASI_NPP_Percent_Contribution_Margin__c >= NPP.ASI_NPP_Benchmark_CM__c)
                        {
                            NPP2.ASI_NPP_Contribution_Margin_Indicators__c = 'PROPOSAL ABOVE BENCHMARK';
                        }
                        else
                        {
                            NPP2.ASI_NPP_Contribution_Margin_Indicators__c = 'PROPOSAL BELOW BENCHMARK';
                        }
                    }
                    
                    IF(NPP.ASI_NPP_Benchmark_CAAP__c == 0 || NPP.ASI_NPP_Benchmark_CAAP__c == null)
                    {
                        NPP2.ASI_NPP_CAAP_Indicators__c = 'BENCHMARK NOT AVAILABLE';  
                    }
                    else
                    {
                        if(NPP.ASI_NPP_Percent_of_CAAP__c >= NPP.ASI_NPP_Benchmark_CAAP__c)
                        {
                            NPP2.ASI_NPP_CAAP_Indicators__c = 'PROPOSAL ABOVE BENCHMARK';
                        }
                        else
                        {
                            NPP2.ASI_NPP_CAAP_Indicators__c = 'PROPOSAL BELOW BENCHMARK';
                        }
                    }
                /*[WL 1.0 Begins]*/
                //}
                /*[WL 1.0 End]*/
                upNpps.add(NPP2);
            }
        }
         update upNpps;
    }  
}