public class ASI_NPP_Proposal_PDF_PageController {
    
    public id NPPID {set;get;}
    List<String> args = new String[]{'0','number','###,###,##0.00'};
        
    public ASI_NPP_New_Product_Promotion__c NPPCurrent{get;set;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }


    public ASI_NPP_Proposal_PDF_PageController(){
    	system.debug(NPPID);
    }
    
     public boolean init(){
        //try{
        //this.Po = (ASI_MFM_PO__c)stdController.getRecord();
       system.debug('select Name, ASI_NPP_Product__c, ASI_NPP_Reason_of_Assessment__c, ASI_NPP_Objective__c,ASI_NPP_Priority_Level__c, ASI_NPP_Competition_Brands__c, ASI_NPP_Duration__c,ASI_NPP_Forecast_AND_Target__c,ASI_NPP_Target_Measurement__c, ASI_NPP_9LC_conversion__c, ASI_NPP_Volume_Sub_Brands_Per_Annum__c, ASI_NPP_Target_Forecast_vs_Sub_Brands__c,ASI_NPP_Sub_Brand_Type__c, ASI_NPP_Category__c, ASI_NPP_Packing_Size_Per_Bottle__c, ASI_NPP_No_of_Bottles_Per_Case__c,ASI_NPP_Percentage_of_Alcohol__c, ASI_NPP_FOB_Cost_w_o_Duties__c, ASI_NPP_FOB_Currency__c, ASI_NPP_FOB_Exchange_Rate__c,ASI_APP_FOB_Cost_conversion_to_SGD__c, ASI_NPP_PRS_to_Wholesaler_Offtrade__c, ASI_NPP_PRS_to_Saler_Offtrade_Proposed__c,ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c, ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c, ASI_NPP_Wholesaler_Margin__c, ASI_NPP_Consumer_Price_From__c, ASI_NPP_Consumer_Price_To__c, ASI_NPP_Distribution_Channel__c, ASI_NPP_Trade_Deal_Offer_Current__c,ASI_NPP_Trading_Term_Supermarket_only__c, ASI_NPP_Additional_Trade_Deal_Offer__c, ASI_NPP_Ad_hoc_Trading_Term__c, ASI_NPP_Brand_Company_VAP__c,ASI_NPP_VAP_Currency__c, ASI_NPP_VAP_conversion_to_SGD__c, ASI_NPP_Local__c, ASI_NPP_Total_VAP_Cost__c, ASI_NPP_Value_Added_Pack_in_details__c,ASI_NPP_Media_Total__c, ASI_NPP_Consumer_A_P__c, ASI_NPP_Product_Launch__c, ASI_NPP_Event__c,ASI_NPP_Sponsorship__c, ASI_NPP_Special_Packing__c,ASI_NPP_Special_Shipping_Handling__c, ASI_NPP_Others_please_indicate__c, ASI_NPP_Others_Detail__c, ASI_NPP_Total_A_P_Expenses__c,ASI_NPP_Percent_Contribution_Margin__c, ASI_NPP_Benchmark_CM__c, ASI_NPP_Contribution_Margin_Indicators__c, ASI_NPP_Percent_of_CAAP__c, ASI_NPP_Benchmark_CAAP__c,ASI_NPP_CAAP_Indicators__c, ASI_NPP_Start_Launch_Date__c,ASI_NPP_Sub_brand__c from ASI_NPP_New_Product_Promotion__c where id ='+NPPID); 
        
        NPPCurrent = [select Name, ASI_NPP_Product__c, ASI_NPP_Reason_of_Assessment__c, ASI_NPP_Objective__c,
                      ASI_NPP_Priority_Level__c, ASI_NPP_Competition_Brands__c, ASI_NPP_Duration__c,ASI_NPP_Forecast_AND_Target__c,
                      ASI_NPP_Target_Measurement__c, ASI_NPP_9LC_conversion__c, ASI_NPP_Volume_Sub_Brands_Per_Annum__c, ASI_NPP_Target_Forecast_vs_Sub_Brands__c,
                      ASI_NPP_Sub_Brand_Type__c, ASI_NPP_Category__c, ASI_NPP_Packing_Size_Per_Bottle__c, ASI_NPP_No_of_Bottles_Per_Case__c,
                      ASI_NPP_Percentage_of_Alcohol__c, ASI_NPP_FOB_Cost_w_o_Duties__c, ASI_NPP_FOB_Currency__c, ASI_NPP_FOB_Exchange_Rate__c,
                      ASI_APP_FOB_Cost_conversion_to_SGD__c, ASI_NPP_PRS_to_Wholesaler_Offtrade__c, ASI_NPP_PRS_to_Saler_Offtrade_Proposed__c,
                      ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c, ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c, ASI_NPP_Wholesaler_Margin__c,
                      ASI_NPP_Consumer_Price_From__c, ASI_NPP_Consumer_Price_To__c, ASI_NPP_Distribution_Channel__c, ASI_NPP_Trade_Deal_Offer_Current__c,
                      ASI_NPP_Trading_Term_Supermarket_only__c, ASI_NPP_Additional_Trade_Deal_Offer__c, ASI_NPP_Ad_hoc_Trading_Term__c, ASI_NPP_Brand_Company_VAP__c,
                      ASI_NPP_VAP_Currency__c, ASI_NPP_VAP_conversion_to_SGD__c, ASI_NPP_Local__c, ASI_NPP_Total_VAP_Cost__c, ASI_NPP_Value_Added_Pack_in_details__c,
                      ASI_NPP_Media_Total__c, ASI_NPP_Consumer_A_P__c, ASI_NPP_Product_Launch__c, ASI_NPP_Event__c,ASI_NPP_Sponsorship__c, ASI_NPP_Special_Packing__c,
                      ASI_NPP_Special_Shipping_Handling__c, ASI_NPP_Others_please_indicate__c, ASI_NPP_Others_Detail__c, ASI_NPP_Total_A_P_Expenses__c,
                      ASI_NPP_Percent_Contribution_Margin__c, ASI_NPP_Benchmark_CM__c, ASI_NPP_Contribution_Margin_Indicators__c, ASI_NPP_Percent_of_CAAP__c, ASI_NPP_Benchmark_CAAP__c,
                      ASI_NPP_CAAP_Indicators__c, ASI_NPP_Start_Launch_Date__c,ASI_NPP_Sub_brand__c from ASI_NPP_New_Product_Promotion__c where id =:NPPID];
        
         
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