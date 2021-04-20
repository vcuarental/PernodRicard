/*
*********************************************************************************
 * Name: ASI_NPP_SG_TestClass
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/07/2017       Wilken Lee              [WL 1.0] CHM114427152 NPA Multiple Market Enhancement
 * 11/09/2017       Wilken Lee              [WL 2.0] CHM115996210 Allow NPA record owners to delete NPA records in draft status
*/
@isTest
public class ASI_NPP_SG_TestClass {
// test class for creating new production
    static testMethod void testPromotion(){
        /*[WL 1.0 BEGIN]*/
        createRouteType();
        /*[WL 1.0 END]*/
        
        ASI_NPP_New_Promotion__c pro = new ASI_NPP_New_Promotion__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_NPP_New_Promotion__cASI_NPP_SG_New_Promotion'), ASI_NPP_Status__c = 'Draft');
        insert pro;
        
        ASI_NPP_New_Product_Promotion__c npp = createNPP();     
        npp.ASI_NPP_New_Promotion__c = pro.id;
        update npp;
        
        pro.ASI_NPP_Status__c = 'Submitted';
        update pro;
        
        pro.ASI_NPP_Status__c = 'Final';
        update pro;
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
    
    static ASI_NPP_PRISMA_code__c createPrismaCode(){
        ASI_NPP_PRISMA_code__c p = new ASI_NPP_PRISMA_code__c();
        
        p.ASI_NPP_RP9__c = '1';
        p.ASI_NPP_RP10__c = '2';
        p.ASI_NPP_RP11__c = '3';
        p.ASI_NPP_RP12_ST__c = '4';
        p.ASI_NPP_RP12_NST__c = '5';
        insert p;
        
        return p;
    }
    
    static ASI_NPP_New_Product_Promotion__c createNPP(){
    
        ASI_MFM_Sub_brand__c sub = createSubBrand();
        ASI_NPP_PRISMA_code__c prisma = createPrismaCode();
        
        ASI_MFM_Exchange_Rate__c rList = new ASI_MFM_Exchange_Rate__c();      
        rList.ASI_MFM_Counter_Currency__c = 'USD';
        rList.ASI_MFM_Exchange_Rate__c = 1.5;
        rList.ASI_NPP_Fiscal_Year__c = 'FY1415';
        rList.ASI_MFM_Country__c = 'SG';
        rList.ASI_MFM_Application__c = 'NPP';
        rList.ASI_MFM_Effective_Date__c = date.today();
        insert rList;
        
        
        ASI_NPP_New_Product_Promotion__c npp = new  ASI_NPP_New_Product_Promotion__c();
        
        npp.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_NPP_New_Product_Promotion__cASI_NPP_SG_New_Product_or_Promotion');
        /*[WL 1.0 BEGIN]*/
        npp.ASI_NPP_Market__c = 'Singapore';
        npp.ASI_NPP_Size_Single__c = '70';
        /*[WL 1.0 BEGIN]*/
        npp.ASI_NPP_Percentage_of_Alcohol__c = 40;
        npp.ASI_NPP_Percent_of_A_P_Expenses__c = 100;
        npp.ASI_NPP_Additional_Trade_Deal_Offer__c = 0;
        npp.ASI_NPP_Ad_hoc_Trading_Term__c = 0;
        npp.ASI_NPP_Forecast_AND_Target__c = 460;
        npp.ASI_NPP_BB_9LC__c = 10;
        npp.ASI_NPP_Benchmark_CAAP__c = 10;
        npp.ASI_NPP_Benchmark_CM__c = 10;
        npp.ASI_NPP_Brand_Company_Allocation_Check__c = true;
        npp.ASI_NPP_Brand_Company_VAP__c = 0;
        npp.ASI_NPP_Brand_Owner__c = 'MMPJ';
        npp.ASI_NPP_CAAP__c = 10;
        npp.ASI_NPP_CAAP_Per_Litre__c = 10;
        npp.ASI_NPP_Percent_of_CAAP__c = 10;
        npp.ASI_NPP_CAAP_Indicators__c = '10';
        npp.ASI_NPP_Category__c = 'Whisky - Blended Scotch';
        npp.ASI_NPP_Consumer_Price_From__c = 280;
        npp.ASI_NPP_Consumer_Price_To__c = 400;
        npp.ASI_NPP_Contribution_Margin__c = 10;
        npp.ASI_NPP_Contribution_Margin_Per_Litre__c = 10;
        npp.ASI_NPP_Percent_Contribution_Margin__c = 10;
        npp.ASI_NPP_Contribution_Margin_Indicators__c = '10';
        npp.ASI_NPP_Percent_of_Cost_of_Sales__c = 10;
        npp.ASI_NPP_FOB_Currency__c = 'USD';
        npp.ASI_NPP_VAP_Currency__c = 'USD';
        npp.ASI_NPP_Distribution_L__c = 10;
        npp.ASI_NPP_Distribution_Channel__c = 'On Trade - MOT';
        npp.ASI_NPP_Duration__c = '2 months';
        npp.ASI_NPP_Event__c = 0;
        npp.ASI_NPP_FOB_Exchange_Rate__c = 10;
        npp.ASI_NPP_VAP_Exchange_Rate__c = 10;
        npp.ASI_NPP_Fiscal_Year__c = 'FY1415';
        npp.ASI_NPP_FOB_Cost_w_o_Duties__c = 18.76;
        npp.ASI_NPP_Handling_L__c = 10;
        npp.ASI_NPP_Local__c = 0;
        npp.ASI_NPP_Media_Total__c = 0;
        npp.ASI_NPP_Net_Sales__c = 10;
        npp.ASI_NPP_Net_Sales_Per_Litre__c = 10;
        npp.ASI_NPP_Percent_of_Net_Sales__c = 10;
        npp.ASI_NPP_No_of_Bottles_Per_Case__c = 6;
        npp.ASI_NPP_Others_please_indicate__c =0;
        npp.ASI_NPP_Packing_Size_Per_Bottle__c = 75;
        npp.ASI_NPP_PRISMA_code__c = prisma.id;
        npp.ASI_NPP_Product__c = 'CR18 Taka Voucher';
        npp.ASI_NPP_Product_Launch__c = 0;
        npp.ASI_NPP_Prompt_Payment_Discount__c = 10;
        npp.ASI_NPP_PRS_to_Wholesaler_Offtrade__c = 118;
        npp.ASI_NPP_Reason_of_Assessment__c = 'Product Addition';
        npp.ASI_NPP_Size__c = '35ml';
        npp.ASI_NPP_SKU__c = 'test';
        npp.ASI_NPP_Special_Packing__c = 0;
        npp.ASI_NPP_Special_Shipping_Handling__c = 0;
        npp.ASI_NPP_Sponsorship__c = 0;
        npp.ASI_NPP_Sub_Brand_Type__c = 'PR Sub-Brands';
        npp.ASI_NPP_Sub_brand__c = sub.id;
        npp.ASI_NPP_Target_Measurement__c = '9LC';
        npp.ASI_NPP_Total_Allowances_Discounts__c = 10;
        npp.ASI_NPP_Trade_Deal_Offer_Current__c = 2;
        npp.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = 3700;
        npp.ASI_NPP_Wholesaler_Margin__c = 10;
        npp.ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c = 128;
        npp.ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c = 128;
        
        insert npp;
        
        return npp;
    }
    
// test class for creating and updating NPPs
    static testMethod void testDupes() {
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
     //   t.ASI_NPP_Start_Launch_Date__c
        t.ASI_NPP_Sub_Brand_Type__c = 'PR Sub-Brands';
        t.ASI_NPP_Sub_brand__c = sub.id;
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
        t3.ASI_NPP_Sub_brand__c = sub.id;
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
        t4.ASI_NPP_PRISMA_code__c = p1.id;
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
        t4.ASI_NPP_Sub_brand__c = sub.id;
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
        t5.ASI_NPP_PRISMA_code__c = p2.id;
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
        t5.ASI_NPP_Sub_brand__c = sub.id;
        t5.ASI_NPP_Target_Measurement__c = '9LC';
        t5.ASI_NPP_Total_Allowances_Discounts__c = 10;
        t5.ASI_NPP_Trade_Deal_Offer_Current__c = 2;
        t5.ASI_NPP_Value_Added_Pack_in_details__c = 'test VAP detail';
        t5.ASI_NPP_Volume_Sub_Brands_Per_Annum__c = 3700;
        t5.ASI_NPP_Wholesaler_Margin__c = 10;
        t5.ASI_NPP_Saler_to_On_Trade_Offtrade_Curr__c = 128;
        t5.ASI_NPP_Saler_to_On_Trade_Offtrade_RSP_P__c = 128;       
        
		List<ASI_NPP_New_Product_Promotion__c> insertNPPList = new List<ASI_NPP_New_Product_Promotion__c>();
		insertNPPList.add(t);
		insertNPPList.add(t3);
		insertNPPList.add(t4);
		insertNPPList.add(t5);
		insert insertNPPList;
		
        //ID reultId = t.id;
        //ASI_NPP_New_Product_Promotion__c t2 = [SELECT ASI_NPP_Sub_Brand__c,OwnerId  FROM ASI_NPP_New_Product_Promotion__c WHERE ID = :reultId];      
		
		/*[WL 2.0 BEGIN]*/
		//delete t;
		
		//Test BeforeDelete trigger validation
		t3.ASI_NPP_status__c = 'Submitted';
		update t3;
		try {
			delete t3;
		}
		catch (Exception e){
		}
		/*[WL 2.0 END]*/
    }
    
}