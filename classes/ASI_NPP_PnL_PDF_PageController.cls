public class ASI_NPP_PnL_PDF_PageController {


    public id NPPID {set;get;}
    List<String> args = new String[]{'0','number','###,###,##0.00'};
        
    public ASI_NPP_New_Product_Promotion__c NPPCurrent{get;set;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }


    public ASI_NPP_PnL_PDF_PageController(){
    	system.debug(NPPID);
    }
    
     public boolean init(){
        //try{
        //this.Po = (ASI_MFM_PO__c)stdController.getRecord();
       
        
        NPPCurrent = [select Name, ASI_NPP_Product__c, ASI_NPP_Reason_of_Assessment__c, ASI_NPP_Objective__c, ASI_NPP_Period_of_Sales__c,
                      ASI_NPP_Target_Sales__c, ASI_NPP_Free_Goods__c, ASI_NPP_9LC_conversion__c, ASI_NPP_FOC_Ratio_PNL__c, ASI_NPP_Volume_Sub_Brands_Per_Annum__c,
                      ASI_NPP_Target_vs_Sub_Brands_Per_Annum__c, ASI_NPP_Gross_Sales__c, ASI_NPP_Free_Goods_Selling__c, ASI_NPP_Contract_Margin__c, 
                      ASI_NPP_Prompt_Payment_to_Wholesaler__c, ASI_NPP_Blind_Bonus__c, ASI_NPP_Trading_terms_Supermarkets__c, ASI_NPP_Ad_hoc_trading_Term_Supermarkets__c,
                      ASI_NPP_Total_Allowances_Discounts__c, ASI_NPP_Net_Sales__c, ASI_NPP_FOB_Cost__c, ASI_NPP_Duties__c, ASI_NPP_Handling_Cost__c,
                      ASI_NPP_Distribution_Cost__c, ASI_NPP_Contribution_Margin__c, ASI_NPP_A_P_Spending__c, ASI_NPP_CAAP__c, ASI_NPP_Net_Sales_Per_Litre__c,
                      ASI_NPP_Contribution_Margin_Per_Litre__c, ASI_NPP_CAAP_Per_Litre__c, ASI_NPP_Percent_of_Net_Sales__c, ASI_NPP_Percent_of_CAAP__c,
                      ASI_NPP_Percent_of_Cost_of_Sales__c, ASI_NPP_Percent_Contribution_Margin__c, ASI_NPP_Percent_of_A_P_Expenses__c, ASI_NPP_Benchmark_CM__c,
                      ASI_NPP_Benchmark_CAAP__c, ASI_NPP_Contribution_Margin_Indicators__c, ASI_NPP_CAAP_Indicators__c, ASI_NPP_P_L_Remarks__c,
                      ASI_NPP_Start_Launch_Date__c, ASI_NPP_Sub_brand__c,
                      //New fields created from NPA CR
                        ASI_NPP_Sub_Category__c,
                        ASI_NPP_Importer_to_Dist_Proposed__c,
                        ASI_NPP_Dist_to_Trade_Proposed__c,
                        ASI_NPP_Reason_for_Pricing_Structure__c,
                        ASI_NPP_Trade_A_P__c,
                        ASI_NPP_Other_Consumer_A_P__c,
                        ASI_NPP_Duties_per_bottle__c,
                        ASI_NPP_Excise_Tax_per_bottle__c,
                        ASI_NPP_Handling_Costs_per_bottle__c,
                        ASI_NPP_Dist_Costs_per_bottle__c,
                        ASI_NPP_Excise_Tax__c,
                        ASI_NPP_Importer_to_Dist_Current__c,
                        ASI_NPP_Dist_to_Trade_Current__c,
                        ASI_NPP_Market__c,
                        ASI_NPP_Market_Currency__c,
                        ASI_NPP_Reporting_Currency__c,
                        ASI_NPP_Ex_Rate_To_Report_Curr__c,
                        ASI_NPP_Price_Discount_Value_per_BT__c,
                        ASI_NPP_Price_Discount_Value_Total__c,
                        ASI_NPP_Wholesaler_to_On_Trade__c,
                        ASI_NPP_PO_Number__c,
                        ASI_NPP_Media_Total_Formula__c

                      from ASI_NPP_New_Product_Promotion__c where id =:NPPID];
        
         
         
        return true;
        //catch(exception e){e.getMessage();}
    }

    public string getdate()
    {
        if(NPPCurrent.ASI_NPP_Start_Launch_Date__c!=null)
        {
            return string.valueof(NPPCurrent.ASI_NPP_Start_Launch_Date__c.month()) + '/' +string.valueof(NPPCurrent.ASI_NPP_Start_Launch_Date__c.day())+ '/' +string.valueof(NPPCurrent.ASI_NPP_Start_Launch_Date__c.year());
        }
        else
        {
            return '';
        }
    }
    
    public string getsubBrand()
    {
        
        if (NPPCurrent.ASI_NPP_Sub_brand__c != null){
            ASI_MFM_Sub_brand__c sub = [SELECT Name FROM ASI_MFM_Sub_brand__c WHERE id = :NPPCurrent.ASI_NPP_Sub_brand__c];
            return sub.Name;
        }
        else
        {
            return '';
        }
    }
    
    public string getCAAPcolor()
    {
        String CAAPcolor = 'red';
        if (NPPCurrent.ASI_NPP_Percent_of_CAAP__c != null && NPPCurrent.ASI_NPP_Benchmark_CAAP__c !=null){
            if (NPPCurrent.ASI_NPP_Percent_of_CAAP__c > NPPCurrent.ASI_NPP_Benchmark_CAAP__c)
            {
                CAAPcolor = '#82FA58';
            }
        }
        
        return CAAPcolor;
    }
    
    public string getCMcolor()
    {
        String CMcolor = 'red';
        if (NPPCurrent.ASI_NPP_Percent_Contribution_Margin__c != null && NPPCurrent.ASI_NPP_Benchmark_CM__c !=null){
            if (NPPCurrent.ASI_NPP_Percent_Contribution_Margin__c > NPPCurrent.ASI_NPP_Benchmark_CM__c){
                CMcolor = '#82FA58';
            }
        }     
        return CMcolor;
    }   

}