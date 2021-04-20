/*
*********************************************************************************
 * Name: ASI_NPP_SG_TestClass
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/07/2017       Wilken Lee              [WL 1.0] CHM114427152 NPA Multiple Market Enhancement
*/
@isTest
public class ASI_NPP_SG_Visualforce_page_testing {   
    static ASI_MFM_Sub_brand__c createSubBrand(){
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c();
        
        sub.ASI_MFM_Sub_brand_Code__c = 'C25';
        sub.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand');
        
        insert sub;
        
        ASI_NPP_Budget_Volume__c subVol = new ASI_NPP_Budget_Volume__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_NPP_Budget_Volume__cASI_NPP_SG_Budget_Volume_Record_Type'), 
            ASI_NPP_Budget_Volume__c = 100, ASI_NPP_Fiscal_Year__c = 'FY1415', ASI_NPP_Inactive__c = false, ASI_NPP_Sub_Brand__c = sub.id);
        
        insert subVol;
        
        return sub;
    }

	/*[WL 1.0 BEGIN]*/
	static void createRouteType(){
		ASI_NPP_Route_Type__c rt = new ASI_NPP_Route_Type__c();
		rt.recordTypeId = Global_RecordTypeCache.getRtId('ASI_NPP_Route_Type__cASI_NPP_SG_Route_Type');
		rt.Name = 'Singapore';
		rt.ASI_NPP_Approver_2__c = UserInfo.getUserId();
		
		insert rt;
	}
	/*[WL 1.0 END]*/
	
    static testMethod void NPP_SG_Visualforce_page_testing1() {
		/*[WL 1.0 BEGIN]*/
		createRouteType();
		/*[WL 1.0 END]*/
		
        ASI_NPP_New_Product_Promotion__c t = new  ASI_NPP_New_Product_Promotion__c();
        ASI_NPP_New_Product_Promotion__c t3 = new  ASI_NPP_New_Product_Promotion__c();
        ASI_NPP_New_Product_Promotion__c t4 = new  ASI_NPP_New_Product_Promotion__c();
        ASI_NPP_New_Product_Promotion__c t5 = new  ASI_NPP_New_Product_Promotion__c();
        ASI_MFM_Exchange_Rate__c rList = new ASI_MFM_Exchange_Rate__c();
        ASI_NPP_Calculation_Base__c cList = new ASI_NPP_Calculation_Base__c();
        ASI_NPP_PRISMA_code__c p1 = new ASI_NPP_PRISMA_code__c();
        ASI_NPP_PRISMA_code__c p2 = new ASI_NPP_PRISMA_code__c();
        ASI_MFM_Sub_brand__c sub = createSubBrand();
      
        rList.ASI_MFM_Counter_Currency__c = 'USD';
        rList.ASI_MFM_Exchange_Rate__c = 1.5;
        rList.ASI_NPP_Fiscal_Year__c = 'FY1415';
        rList.ASI_MFM_Country__c = 'SG';
        rList.ASI_MFM_Application__c = 'NPP';
        rList.ASI_MFM_Effective_Date__c = date.today();
        insert rList;
        

        cList.ASI_NPP_BB__c = 1.1;
        cList.ASI_NPP_Benchmark_CAAP__c = 0;
        cList.ASI_NPP_Benchmark_CM__c = 0;
        cList.ASI_NPP_Distribution__c = 1.1;
        cList.ASI_NPP_FASTAR__c = 'CHI';
        cList.ASI_NPP_Fiscal_Year__c = 'FY1415';
        cList.ASI_NPP_Handling__c = 1.1;
        cList.ASI_NPP_Prompt_Payment_Discount__c = 1.1;
        cList.ASI_NPP_Sub_brand__c = sub.id;
        ID pnlid = Schema.SObjectType.ASI_NPP_Calculation_Base__c.getRecordTypeInfosByName().get('SG Calculation Base').getRecordTypeId();
        cList.RecordTypeId = pnlid;
        insert cList;
        
        p1.ASI_NPP_RP9__c = '1';
        p1.ASI_NPP_RP10__c = '2';
        p1.ASI_NPP_RP11__c = '3';
        p1.ASI_NPP_RP12_ST__c = '4';
        p1.ASI_NPP_RP12_NST__c = '5';
        insert p1;
        
        p1.ASI_NPP_RP9__c = '';
        p1.ASI_NPP_RP10__c = '';
        p1.ASI_NPP_RP11__c = '';
        p1.ASI_NPP_RP12_ST__c = '';
        p1.ASI_NPP_RP12_NST__c = '';
        insert p2;
        
        t.OwnerId = UserInfo.getUserId();
        ID tid = Schema.SObjectType.ASI_NPP_New_Product_Promotion__c.getRecordTypeInfosByName().get('SG New Product or Promotion').getRecordTypeId();
        t.RecordTypeId = tid;
		/*[WL 1.0 BEGIN]*/
		t.ASI_NPP_Market__c = 'Singapore';
		t.ASI_NPP_Size_Single__c = '70';
		/*[WL 1.0 BEGIN]*/
        t.ASI_NPP_Others_Detail__c = 'test detail';
        t.ASI_NPP_Percentage_of_Alcohol__c = 40;
        t.ASI_NPP_Percent_of_A_P_Expenses__c = 100;
        t.ASI_NPP_Additional_Trade_Deal_Offer__c = 0;
        t.ASI_NPP_Ad_hoc_Trading_Term__c = 0;
        t.ASI_NPP_Forecast_AND_Target__c = 460;
        t.ASI_NPP_BB_9LC__c = 10;
        t.ASI_NPP_Benchmark_CAAP__c = 10;
        t.ASI_NPP_Benchmark_CM__c = 10;
        t.ASI_NPP_Brand_Company_Allocation_Check__c = true;
        t.ASI_NPP_Brand_Company_VAP__c = 0;
        t.ASI_NPP_Brand_Owner__c = 'MMPJ';
        t.ASI_NPP_CAAP__c = 10;
        t.ASI_NPP_CAAP_Per_Litre__c = 10;
        t.ASI_NPP_Percent_of_CAAP__c = 10;
        t.ASI_NPP_CAAP_Indicators__c = '10';
        t.ASI_NPP_Category__c = 'Whisky - Blended Scotch';
        t.ASI_NPP_Competition_Brands__c = 'Competition Brand';
        t.ASI_NPP_Consumer_Price_From__c = 280;
        t.ASI_NPP_Consumer_Price_To__c = 400;
        t.ASI_NPP_Contribution_Margin__c = 10;
        t.ASI_NPP_Contribution_Margin_Per_Litre__c = 10;
        t.ASI_NPP_Percent_Contribution_Margin__c = 10;
        t.ASI_NPP_Contribution_Margin_Indicators__c = '10';
        t.ASI_NPP_Percent_of_Cost_of_Sales__c = 10;
        t.ASI_NPP_FOB_Currency__c = 'SGD';
        t.ASI_NPP_VAP_Currency__c = 'SGD';
        t.ASI_NPP_Distribution_L__c = 10;
        t.ASI_NPP_Distribution_Channel__c = 'Offtrade';
        t.ASI_NPP_Duration__c = '2 months';
        t.ASI_NPP_Event__c = 0;
        t.ASI_NPP_FOB_Exchange_Rate__c = 10;
        t.ASI_NPP_VAP_Exchange_Rate__c = 10;
        t.ASI_NPP_Fiscal_Year__c = 'FY1415';
        t.ASI_NPP_FOB_Cost_w_o_Duties__c = 18.76;
        t.ASI_NPP_Handling_L__c = 10;
        t.ASI_NPP_Initial_Requested_Quantity__c = 'test quantity';
        t.ASI_NPP_Local__c = 0;
        t.ASI_NPP_Media_Total__c = 0;
        t.ASI_NPP_Net_Sales__c = 10;
        t.ASI_NPP_Net_Sales_Per_Litre__c = 10;
        t.ASI_NPP_Percent_of_Net_Sales__c = 10;
        t.ASI_NPP_No_of_Bottles_Per_Case__c = 6;
        t.ASI_NPP_Objective__c = 'Test Class';
        t.ASI_NPP_Others_please_indicate__c =0;
        t.ASI_NPP_P_L_Remarks__c = 'test PnL Remark';
        t.ASI_NPP_Packing_Size_Per_Bottle__c = 75;
        t.ASI_NPP_Period_of_Sales__c = 'One-shot';
        t.ASI_NPP_PO_Raised_Check__c = true;
        t.ASI_NPP_Priority_Level__c = 'Tactical';
        t.ASI_NPP_PRISMA_Detail__c = '123';
        t.ASI_NPP_PRISMA_code__c = p1.Id;
        t.ASI_NPP_Product__c = 'CR18 Taka Voucher';
        t.ASI_NPP_Product_Launch__c = 0;
        t.ASI_NPP_Prompt_Payment_Discount__c = 10;
        t.ASI_NPP_PRS_to_Wholesaler_Offtrade__c = 118;
        t.ASI_NPP_Quantity_annual__c = 'test quantity';
        t.ASI_NPP_Reason_of_Assessment__c = 'Product Addition';
        t.ASI_NPP_Sales_Forecast_by_Channel__c = 'test sales forecast';
        t.ASI_NPP_Size__c = '35ml';
        t.ASI_NPP_SKU__c = 'test';
        t.ASI_NPP_Special_Packing__c = 0;
        t.ASI_NPP_Special_Shipping_Handling__c = 0;
        t.ASI_NPP_Sponsorship__c = 0;

        t.ASI_NPP_Sub_Brand_Type__c = 'PR Sub-Brands';
        t.ASI_NPP_Sub_brand__c =  sub.id;
        t.ASI_NPP_Target_Measurement__c = '9LC';
        t.ASI_NPP_Total_Allowances_Discounts__c = 10;
        t.ASI_NPP_Trade_Deal_Offer_Current__c = 2;
        t.ASI_NPP_Value_Added_Pack_in_details__c = 'test VAP detail';
        t.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = 3700;
        t.ASI_NPP_Wholesaler_Margin__c = 10;
        t.ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c = 128;
        t.ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c = 128;

        t3.RecordTypeId = tid;
		/*[WL 1.0 BEGIN]*/
		t3.ASI_NPP_Market__c = 'Singapore';
		t3.ASI_NPP_Size_Single__c = '70';
		/*[WL 1.0 BEGIN]*/		
        t3.ASI_NPP_Percentage_of_Alcohol__c = 40;
        t3.ASI_NPP_Percent_of_A_P_Expenses__c = 100;
        t3.ASI_NPP_Additional_Trade_Deal_Offer__c = 0;
        t3.ASI_NPP_Ad_hoc_Trading_Term__c = 0;
        t3.ASI_NPP_Forecast_AND_Target__c = 460;
        t3.ASI_NPP_BB_9LC__c = 10;
        t3.ASI_NPP_Benchmark_CAAP__c = 10;
        t3.ASI_NPP_Benchmark_CM__c = 10;
        t3.ASI_NPP_Brand_Company_Allocation_Check__c = true;
        t3.ASI_NPP_Brand_Company_VAP__c = 0;
        t3.ASI_NPP_Brand_Owner__c = 'MMPJ';
        t3.ASI_NPP_CAAP__c = 10;
        t3.ASI_NPP_CAAP_Per_Litre__c = 10;
        t3.ASI_NPP_Percent_of_CAAP__c = 10;
        t3.ASI_NPP_CAAP_Indicators__c = '10';
        t3.ASI_NPP_Category__c = 'Whisky - Blended Scotch';
        t3.ASI_NPP_Consumer_Price_From__c = 280;
        t3.ASI_NPP_Consumer_Price_To__c = 400;
        t3.ASI_NPP_Contribution_Margin__c = 10;
        t3.ASI_NPP_Contribution_Margin_Per_Litre__c = 10;
        t3.ASI_NPP_Percent_Contribution_Margin__c = 10;
        t3.ASI_NPP_Contribution_Margin_Indicators__c = '10';
        t3.ASI_NPP_Percent_of_Cost_of_Sales__c = 10;
        t3.ASI_NPP_FOB_Currency__c = 'USD';
        t3.ASI_NPP_VAP_Currency__c = 'USD';
        t3.ASI_NPP_Distribution_L__c = 10;
        t3.ASI_NPP_Distribution_Channel__c = 'On Trade - MOT';
        t3.ASI_NPP_Duration__c = '2 months';
        t3.ASI_NPP_Event__c = 0;
        t3.ASI_NPP_FOB_Exchange_Rate__c = 10;
        t3.ASI_NPP_VAP_Exchange_Rate__c = 10;
        t3.ASI_NPP_Fiscal_Year__c = 'FY1415';
        t3.ASI_NPP_FOB_Cost_w_o_Duties__c = 18.76;
        t3.ASI_NPP_Handling_L__c = 10;
        t3.ASI_NPP_Local__c = 0;
        t3.ASI_NPP_Media_Total__c = 0;
        t3.ASI_NPP_Net_Sales__c = 10;
        t3.ASI_NPP_Net_Sales_Per_Litre__c = 10;
        t3.ASI_NPP_Percent_of_Net_Sales__c = 10;
        t3.ASI_NPP_No_of_Bottles_Per_Case__c = 6;
        t3.ASI_NPP_Others_please_indicate__c =0;
        t3.ASI_NPP_Packing_Size_Per_Bottle__c = 75;
        t3.ASI_NPP_PRISMA_code__c = p2.id;
        t3.ASI_NPP_Product__c = 'CR18 Taka Voucher';
        t3.ASI_NPP_Product_Launch__c = 0;
        t3.ASI_NPP_Prompt_Payment_Discount__c = 10;
        t3.ASI_NPP_PRS_to_Wholesaler_Offtrade__c = 118;
        t3.ASI_NPP_Reason_of_Assessment__c = 'Product Addition';
        t3.ASI_NPP_Size__c = '35ml';
        t3.ASI_NPP_SKU__c = 'test';
        t3.ASI_NPP_Special_Packing__c = 0;
        t3.ASI_NPP_Special_Shipping_Handling__c = 0;
        t3.ASI_NPP_Sponsorship__c = 0;
        t3.ASI_NPP_Sub_Brand_Type__c = 'PR Sub-Brands';
        t3.ASI_NPP_Sub_brand__c =  sub.id;
        t3.ASI_NPP_Target_Measurement__c = '9LC';
        t3.ASI_NPP_Total_Allowances_Discounts__c = 10;
        t3.ASI_NPP_Trade_Deal_Offer_Current__c = 2;
        t3.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = 3700;
        t3.ASI_NPP_Wholesaler_Margin__c = 10;
        t3.ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c = 128;
        t3.ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c = 128;
        
        t4.RecordTypeId = tid;
		/*[WL 1.0 BEGIN]*/
		t4.ASI_NPP_Market__c = 'Singapore';
		t4.ASI_NPP_Size_Single__c = '70';
		/*[WL 1.0 BEGIN]*/		
        t4.ASI_NPP_Percentage_of_Alcohol__c = 40;
        t4.ASI_NPP_Percent_of_A_P_Expenses__c = 100;
        t4.ASI_NPP_Additional_Trade_Deal_Offer__c = 0;
        t4.ASI_NPP_Ad_hoc_Trading_Term__c = 0;
        t4.ASI_NPP_Forecast_AND_Target__c = 460;
        t4.ASI_NPP_BB_9LC__c = 10;
        t4.ASI_NPP_Benchmark_CAAP__c = 10;
        t4.ASI_NPP_Benchmark_CM__c = 10;
        t4.ASI_NPP_Brand_Company_Allocation_Check__c = true;
        t4.ASI_NPP_Brand_Company_VAP__c = 0;
        t4.ASI_NPP_Brand_Owner__c = 'MMPJ';
        t4.ASI_NPP_CAAP__c = 10;
        t4.ASI_NPP_CAAP_Per_Litre__c = 10;
        t4.ASI_NPP_Percent_of_CAAP__c = 10;
        t4.ASI_NPP_CAAP_Indicators__c = '10';
        t4.ASI_NPP_Category__c = 'Whisky - Blended Scotch';
        t4.ASI_NPP_Consumer_Price_From__c = 280;
        t4.ASI_NPP_Consumer_Price_To__c = 400;
        t4.ASI_NPP_Contribution_Margin__c = 10;
        t4.ASI_NPP_Contribution_Margin_Per_Litre__c = 10;
        t4.ASI_NPP_Percent_Contribution_Margin__c = 10;
        t4.ASI_NPP_Contribution_Margin_Indicators__c = '10';
        t4.ASI_NPP_Percent_of_Cost_of_Sales__c = 10;
        t4.ASI_NPP_FOB_Currency__c = 'USD';
        t4.ASI_NPP_VAP_Currency__c = 'USD';
        t4.ASI_NPP_Distribution_L__c = 10;
        t4.ASI_NPP_Distribution_Channel__c = 'Offtrade';
        t4.ASI_NPP_Duration__c = '2 months';
        t4.ASI_NPP_Event__c = 0;
        t4.ASI_NPP_FOB_Exchange_Rate__c = 10;
        t4.ASI_NPP_VAP_Exchange_Rate__c = 10;
        t4.ASI_NPP_Fiscal_Year__c = 'FY1415';
        t4.ASI_NPP_FOB_Cost_w_o_Duties__c = 18.76;
        t4.ASI_NPP_Handling_L__c = 10;
        t4.ASI_NPP_Local__c = 0;
        t4.ASI_NPP_Media_Total__c = 0;
        t4.ASI_NPP_Net_Sales__c = 10;
        t4.ASI_NPP_Net_Sales_Per_Litre__c = 10;
        t4.ASI_NPP_Percent_of_Net_Sales__c = 10;
        t4.ASI_NPP_No_of_Bottles_Per_Case__c = 6;
        t4.ASI_NPP_Others_please_indicate__c =0;
        t4.ASI_NPP_Packing_Size_Per_Bottle__c = 75;
        t4.ASI_NPP_PRISMA_code__c = p1.Id;
        t4.ASI_NPP_Product__c = 'CR18 Taka Voucher';
        t4.ASI_NPP_Product_Launch__c = 0;
        t4.ASI_NPP_Prompt_Payment_Discount__c = 10;
        t4.ASI_NPP_PRS_to_Wholesaler_Offtrade__c = 118;
        t4.ASI_NPP_Reason_of_Assessment__c = 'Product Addition';
        t4.ASI_NPP_Size__c = '35ml';
        t4.ASI_NPP_SKU__c = 'test';
        t4.ASI_NPP_Special_Packing__c = 0;
        t4.ASI_NPP_Special_Shipping_Handling__c = 0;
        t4.ASI_NPP_Sponsorship__c = 0;
        t4.ASI_NPP_Sub_Brand_Type__c = 'PR Sub-Brands';
        t4.ASI_NPP_Sub_brand__c =  sub.id;
        t4.ASI_NPP_Target_Measurement__c = '9LC';
        t4.ASI_NPP_Total_Allowances_Discounts__c = 10;
        t4.ASI_NPP_Trade_Deal_Offer_Current__c = 2;
        t4.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = 3700;
        t4.ASI_NPP_Wholesaler_Margin__c = 10;
        t4.ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c = 128;
        t4.ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c = 128;
        t4.ASI_NPP_Launch_Date__c = date.today();
        
        t5.RecordTypeId = tid;
		/*[WL 1.0 BEGIN]*/
		t5.ASI_NPP_Market__c = 'Singapore';
		t5.ASI_NPP_Size_Single__c = '70';
		/*[WL 1.0 BEGIN]*/		
        t5.ASI_NPP_Others_Detail__c = 'test detail';
        t5.ASI_NPP_Percentage_of_Alcohol__c = 40;
        t5.ASI_NPP_Percent_of_A_P_Expenses__c = 100;
        t5.ASI_NPP_Additional_Trade_Deal_Offer__c = 0;
        t5.ASI_NPP_Ad_hoc_Trading_Term__c = 0;
        t5.ASI_NPP_Forecast_AND_Target__c = 460;
        t5.ASI_NPP_BB_9LC__c = 10;
        t5.ASI_NPP_Benchmark_CAAP__c = 10;
        t5.ASI_NPP_Benchmark_CM__c = 10;
        t5.ASI_NPP_Brand_Company_Allocation_Check__c = true;
        t5.ASI_NPP_Brand_Company_VAP__c = 0;
        t5.ASI_NPP_Brand_Owner__c = 'MMPJ';
        t5.ASI_NPP_CAAP__c = 10;
        t5.ASI_NPP_CAAP_Per_Litre__c = 10;
        t5.ASI_NPP_Percent_of_CAAP__c = 10;
        t5.ASI_NPP_CAAP_Indicators__c = '10';
        t5.ASI_NPP_Category__c = 'Whisky - Blended Scotch';
        t5.ASI_NPP_Competition_Brands__c = 'Competition Brand';
        t5.ASI_NPP_Consumer_Price_From__c = 280;
        t5.ASI_NPP_Consumer_Price_To__c = 400;
        t5.ASI_NPP_Contribution_Margin__c = 10;
        t5.ASI_NPP_Contribution_Margin_Per_Litre__c = 10;
        t5.ASI_NPP_Percent_Contribution_Margin__c = 10;
        t5.ASI_NPP_Contribution_Margin_Indicators__c = '10';
        t5.ASI_NPP_Percent_of_Cost_of_Sales__c = 10;
        t5.ASI_NPP_FOB_Currency__c = 'SGD';
        t5.ASI_NPP_VAP_Currency__c = 'SGD';
        t5.ASI_NPP_Distribution_L__c = 10;
        t5.ASI_NPP_Distribution_Channel__c = 'Offtrade';
        t5.ASI_NPP_Duration__c = '2 months';
        t5.ASI_NPP_Event__c = 0;
        t5.ASI_NPP_FOB_Exchange_Rate__c = 10;
        t5.ASI_NPP_VAP_Exchange_Rate__c = 10;
        t5.ASI_NPP_Fiscal_Year__c = 'FY1415';
        t5.ASI_NPP_FOB_Cost_w_o_Duties__c = 18.76;
        t5.ASI_NPP_Handling_L__c = 10;
        t5.ASI_NPP_Initial_Requested_Quantity__c = 'test quantity';
        t5.ASI_NPP_Local__c = 0;
        t5.ASI_NPP_Media_Total__c = 0;
        t5.ASI_NPP_Net_Sales__c = 10;
        t5.ASI_NPP_Net_Sales_Per_Litre__c = 10;
        t5.ASI_NPP_Percent_of_Net_Sales__c = 10;
        t5.ASI_NPP_No_of_Bottles_Per_Case__c = 6;
        t5.ASI_NPP_Objective__c = 'Test Class';
        t5.ASI_NPP_Others_please_indicate__c =0;
        t5.ASI_NPP_P_L_Remarks__c = 'test PnL Remark';
        t5.ASI_NPP_Packing_Size_Per_Bottle__c = 75;
        t5.ASI_NPP_Period_of_Sales__c = 'One-shot';
        t5.ASI_NPP_PO_Raised_Check__c = true;
        t5.ASI_NPP_Priority_Level__c = 'Tactical';
        t5.ASI_NPP_PRISMA_Detail__c = '123';
        t5.ASI_NPP_PRISMA_code__c = p2.Id;
        t5.ASI_NPP_Product__c = 'CR18 Taka Voucher';
        t5.ASI_NPP_Product_Launch__c = 0;
        t5.ASI_NPP_Prompt_Payment_Discount__c = 10;
        t5.ASI_NPP_PRS_to_Wholesaler_Offtrade__c = 118;
        t5.ASI_NPP_Quantity_annual__c = 'test quantity';
        t5.ASI_NPP_Reason_of_Assessment__c = 'Product Addition';
        t5.ASI_NPP_Sales_Forecast_by_Channel__c = 'test sales forecast';
        t5.ASI_NPP_Size__c = '35ml';
        t5.ASI_NPP_SKU__c = 'test';
        t5.ASI_NPP_Special_Packing__c = 0;
        t5.ASI_NPP_Special_Shipping_Handling__c = 0;
        t5.ASI_NPP_Sponsorship__c = 0;
        t5.ASI_NPP_Sub_Brand_Type__c = 'PR Sub-Brands';
        t5.ASI_NPP_Sub_brand__c =  sub.id;
        t5.ASI_NPP_Target_Measurement__c = '9LC';
        t5.ASI_NPP_Total_Allowances_Discounts__c = 10;
        t5.ASI_NPP_Trade_Deal_Offer_Current__c = 2;
        t5.ASI_NPP_Value_Added_Pack_in_details__c = 'test VAP detail';
        t5.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = 3700;
        t5.ASI_NPP_Wholesaler_Margin__c = 10;
        t5.ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c = 128;
        t5.ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c = 128;

        insert t;
        insert t3;
        insert t4;
        insert t5;
        ID reultId = t.id;
        ASI_NPP_New_Product_Promotion__c t2 = [SELECT ASI_NPP_Sub_Brand__c,OwnerId  FROM ASI_NPP_New_Product_Promotion__c WHERE ID = :reultId];

        ApexPages.currentPage().getParameters().put('id',t.id);
        ApexPages.StandardController stdCont = new ApexPages.StandardController(t);
        ASI_NPP_Create_Record_Extension myExtension  = new ASI_NPP_Create_Record_Extension(stdCont);
        myExtension.getCanEdit();      
        myExtension.getdate();
        t.ASI_NPP_Start_Launch_Date__c = date.today();
        myExtension.getdate();
        myExtension.getHideshow();
        myExtension.getsubBrand();
        myExtension.setHideshow(true);
        myExtension.showSection1();
        t.OwnerId = '005M00000068kpp';
        t.ASI_NPP_Sub_brand__c = null;
        myExtension.getsubBrand();
        t.ASI_NPP_Percent_Contribution_Margin__c = 20;
        t.ASI_NPP_Percent_of_CAAP__c = 20;
        t.ASI_NPP_Benchmark_CM__c = 10;
        t.ASI_NPP_Benchmark_CAAP__c = 10;
        myExtension.getCMcolor();
        myExtension.getCAAPcolor(); 
        t.ASI_NPP_Percent_Contribution_Margin__c = 5;
        t.ASI_NPP_Percent_of_CAAP__c = 5;
        myExtension.getCMcolor();
        myExtension.getCAAPcolor(); 
    }  
    
    static testMethod void NPP_SG_Visualforce_page_testing2() {
		/*[WL 1.0 BEGIN]*/
		createRouteType();
		/*[WL 1.0 END]*/
		
        ASI_NPP_New_Product_Promotion__c t = new  ASI_NPP_New_Product_Promotion__c();
        ASI_NPP_New_Product_Promotion__c t3 = new  ASI_NPP_New_Product_Promotion__c();
        ASI_NPP_New_Product_Promotion__c t4 = new  ASI_NPP_New_Product_Promotion__c();
        ASI_NPP_New_Product_Promotion__c t5 = new  ASI_NPP_New_Product_Promotion__c();
        ASI_MFM_Exchange_Rate__c rList = new ASI_MFM_Exchange_Rate__c();
        ASI_NPP_Calculation_Base__c cList = new ASI_NPP_Calculation_Base__c();
        ASI_NPP_PRISMA_code__c p1 = new ASI_NPP_PRISMA_code__c();
        ASI_NPP_PRISMA_code__c p2 = new ASI_NPP_PRISMA_code__c();
        ASI_MFM_Sub_brand__c sub = createSubBrand();
      
        rList.ASI_MFM_Counter_Currency__c = 'USD';
        rList.ASI_MFM_Exchange_Rate__c = 1.5;
        rList.ASI_NPP_Fiscal_Year__c = 'FY1415';
        rList.ASI_MFM_Country__c = 'SG';
        rList.ASI_MFM_Application__c = 'NPP';
        rList.ASI_MFM_Effective_Date__c = date.today();
        insert rList;
       
        cList.ASI_NPP_BB__c = 1.1;
        cList.ASI_NPP_Benchmark_CAAP__c = 0;
        cList.ASI_NPP_Benchmark_CM__c = 0;
        cList.ASI_NPP_Distribution__c = 1.1;
        cList.ASI_NPP_FASTAR__c = 'CHI';
        cList.ASI_NPP_Fiscal_Year__c = 'FY1415';
        cList.ASI_NPP_Handling__c = 1.1;
        cList.ASI_NPP_Prompt_Payment_Discount__c = 1.1;
        cList.ASI_NPP_Sub_brand__c = sub.id;
        ID pnlid = Schema.SObjectType.ASI_NPP_Calculation_Base__c.getRecordTypeInfosByName().get('SG Calculation Base').getRecordTypeId();
        cList.RecordTypeId = pnlid;
        insert cList;
        
        p1.ASI_NPP_RP9__c = '1';
        p1.ASI_NPP_RP10__c = '2';
        p1.ASI_NPP_RP11__c = '3';
        p1.ASI_NPP_RP12_ST__c = '4';
        p1.ASI_NPP_RP12_NST__c = '5';
        insert p1;
        
        p1.ASI_NPP_RP9__c = '';
        p1.ASI_NPP_RP10__c = '';
        p1.ASI_NPP_RP11__c = '';
        p1.ASI_NPP_RP12_ST__c = '';
        p1.ASI_NPP_RP12_NST__c = '';
        insert p2;
        
        t.OwnerId = UserInfo.getUserId();
        ID tid = Schema.SObjectType.ASI_NPP_New_Product_Promotion__c.getRecordTypeInfosByName().get('SG New Product or Promotion').getRecordTypeId();
        t.RecordTypeId = tid;
		/*[WL 1.0 BEGIN]*/
		t.ASI_NPP_Market__c = 'Singapore';
		t.ASI_NPP_Size_Single__c = '70';
		/*[WL 1.0 BEGIN]*/		
        t.ASI_NPP_Others_Detail__c = 'test detail';
        t.ASI_NPP_Percentage_of_Alcohol__c = 40;
        t.ASI_NPP_Percent_of_A_P_Expenses__c = 100;
        t.ASI_NPP_Additional_Trade_Deal_Offer__c = 0;
        t.ASI_NPP_Ad_hoc_Trading_Term__c = 0;
        t.ASI_NPP_Forecast_AND_Target__c = 460;
        t.ASI_NPP_BB_9LC__c = 10;
        t.ASI_NPP_Benchmark_CAAP__c = 10;
        t.ASI_NPP_Benchmark_CM__c = 10;
        t.ASI_NPP_Brand_Company_Allocation_Check__c = true;
        t.ASI_NPP_Brand_Company_VAP__c = 0;
        t.ASI_NPP_Brand_Owner__c = 'MMPJ';
        t.ASI_NPP_CAAP__c = 10;
        t.ASI_NPP_CAAP_Per_Litre__c = 10;
        t.ASI_NPP_Percent_of_CAAP__c = 10;
        t.ASI_NPP_CAAP_Indicators__c = '10';
        t.ASI_NPP_Category__c = 'Whisky - Blended Scotch';
        t.ASI_NPP_Competition_Brands__c = 'Competition Brand';
        t.ASI_NPP_Consumer_Price_From__c = 280;
        t.ASI_NPP_Consumer_Price_To__c = 400;
        t.ASI_NPP_Contribution_Margin__c = 10;
        t.ASI_NPP_Contribution_Margin_Per_Litre__c = 10;
        t.ASI_NPP_Percent_Contribution_Margin__c = 10;
        t.ASI_NPP_Contribution_Margin_Indicators__c = '10';
        t.ASI_NPP_Percent_of_Cost_of_Sales__c = 10;
        t.ASI_NPP_FOB_Currency__c = 'SGD';
        t.ASI_NPP_VAP_Currency__c = 'SGD';
        t.ASI_NPP_Distribution_L__c = 10;
        t.ASI_NPP_Distribution_Channel__c = 'Offtrade';
        t.ASI_NPP_Duration__c = '2 months';
        t.ASI_NPP_Event__c = 0;
        t.ASI_NPP_FOB_Exchange_Rate__c = 10;
        t.ASI_NPP_VAP_Exchange_Rate__c = 10;
        t.ASI_NPP_Fiscal_Year__c = 'FY1314';
        t.ASI_NPP_FOB_Cost_w_o_Duties__c = 18.76;
        t.ASI_NPP_Handling_L__c = 10;
        t.ASI_NPP_Initial_Requested_Quantity__c = 'test quantity';
        t.ASI_NPP_Local__c = 0;
        t.ASI_NPP_Media_Total__c = 0;
        t.ASI_NPP_Net_Sales__c = 10;
        t.ASI_NPP_Net_Sales_Per_Litre__c = 10;
        t.ASI_NPP_Percent_of_Net_Sales__c = 10;
        t.ASI_NPP_No_of_Bottles_Per_Case__c = 6;
        t.ASI_NPP_Objective__c = 'Test Class';
        t.ASI_NPP_Others_please_indicate__c =0;
        t.ASI_NPP_P_L_Remarks__c = 'test PnL Remark';
        t.ASI_NPP_Packing_Size_Per_Bottle__c = 75;
        t.ASI_NPP_Period_of_Sales__c = 'One-shot';
        t.ASI_NPP_PO_Raised_Check__c = true;
        t.ASI_NPP_Priority_Level__c = 'Tactical';
        t.ASI_NPP_PRISMA_Detail__c = '123';
        t.ASI_NPP_PRISMA_code__c = p1.Id;
        t.ASI_NPP_Product__c = 'CR18 Taka Voucher';
        t.ASI_NPP_Product_Launch__c = 0;
        t.ASI_NPP_Prompt_Payment_Discount__c = 10;
        t.ASI_NPP_PRS_to_Wholesaler_Offtrade__c = 118;
        t.ASI_NPP_Quantity_annual__c = 'test quantity';
        t.ASI_NPP_Reason_of_Assessment__c = 'Product Addition';
        t.ASI_NPP_Sales_Forecast_by_Channel__c = 'test sales forecast';
        t.ASI_NPP_Size__c = '35ml';
        t.ASI_NPP_SKU__c = 'test';
        t.ASI_NPP_Special_Packing__c = 0;
        t.ASI_NPP_Special_Shipping_Handling__c = 0;
        t.ASI_NPP_Sponsorship__c = 0;

        t.ASI_NPP_Sub_Brand_Type__c = 'PR Sub-Brands';
        t.ASI_NPP_Sub_brand__c =  sub.id;
        t.ASI_NPP_Target_Measurement__c = '9LC';
        t.ASI_NPP_Total_Allowances_Discounts__c = 10;
        t.ASI_NPP_Trade_Deal_Offer_Current__c = 2;
        t.ASI_NPP_Value_Added_Pack_in_details__c = 'test VAP detail';
        t.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = 3700;
        t.ASI_NPP_Wholesaler_Margin__c = 10;
        t.ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c = 128;
        t.ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c = 128;

        insert t;
        ASI_NPP_Proposal_PDF_PageController myExtension2 = new ASI_NPP_Proposal_PDF_PageController();
        ASI_NPP_PnL_PDF_PageController myExtension3 = new ASI_NPP_PnL_PDF_PageController();
        PageReference myPage = new Pagereference('/apex/ASI_NPP_Component_Test');

        Test.setCurrentPage(myPage);  
        myExtension2.NPPID = t.id;
        myExtension2.init();
        myExtension2.getCAAPcolor();
        myExtension2.getCMcolor();
        myExtension2.getsubBrand();
        myExtension2.NPPCurrent.ASI_NPP_Sub_brand__c = null;
        myExtension2.getsubBrand();
        myExtension2.getdate();
        myExtension2.NPPCurrent.ASI_NPP_Start_Launch_Date__c = date.today();
        myExtension2.getdate();
        
        myExtension3.NPPID = t.id;
        myExtension3.init();
        myExtension3.getCAAPcolor();
        myExtension3.getCMcolor();
        myExtension3.getsubBrand();
        myExtension3.NPPCurrent.ASI_NPP_Sub_brand__c = null;
        myExtension3.getsubBrand();
        myExtension3.getdate();
        myExtension3.NPPCurrent.ASI_NPP_Start_Launch_Date__c = date.today();
        myExtension3.getdate();
    } 
    
}