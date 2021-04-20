/*********************************************************************************
 * Name: ASI_CRM_SG_ContractComparison_Controller
 * Description: Controller class for comparing the different contract records (ASI_CRM_SG_ContractComparison_Page)
 * Test Class: ASI_CRM_SG_ContractComparison_CtrlTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/02/2017       Hugo Cheung             Created          
 * 2018-03-27		Vincent Lam				[VL 1.0] ICM117657570 : use new field to store RTM wholesaler margin
 * 2018-07-06		Wilken Lee				[WL 2.0] Missing FOC expense in Contract estimate Net Sales calculation
*/
public with sharing class ASI_CRM_SG_ContractComparison_Controller {

    //Inner class for storing contract comparison result
    private class ContractComparisonResultWrapper {
        private Boolean isBaseContract {get; set;}
        
        //Header
        private String outlet         		{get; set;}
        private String contractNo     		{get; set;}
        private String contractPeriod 		{get; set;}
        private String sectorCodeDetail     {get; set;}
        private String statusDetail 		{get; set;}
        private Decimal inflationRate 		{get; set;}
        private Decimal distributionRate	{get; set;}

        //Detail 
        //Column 1 Sales
        private Decimal salesVol            {get; set;}
        private Decimal salesVolPerformance {get; set;}
        private Decimal salesVolDTG         {get; set;}

        //Column 2 FOC
        private Decimal focVol            {get; set;}
        private Decimal focVolPerformance {get; set;}
        private Decimal focVolDTG         {get; set;}

        //Column 3 FOC Ratio
        private Decimal focRatioVol            {get; set;}
        private Decimal focRatioVolPerformance {get; set;}

        //Column 4 Gross Sales
        private Decimal grossSales            {get; set;}
        private Decimal grossSalesPerformance {get; set;}
        private Decimal grossSalesDTG         {get; set;}

        //Column 5 Free Goods
        private Decimal freeGoods            {get; set;}
        private Decimal freeGoodsPerformance {get; set;}

        //Column 6 Free Goods (Ad-hoc)
        private Decimal freeGoodsAdhocPerformance {get; set;}

        //Column 7 Contract Margin/Price Overwrite
        private Decimal contractMarginAndPriceOverwrite            {get; set;}
        private Decimal contractMarginAndPriceOverwritePerformance {get; set;}

        //Column 7 Contract Margin/Price Overwrite
        private Decimal wholesalerMargin            {get; set;}
        private Decimal wholesalerMarginPerformance {get; set;}

        //Column 8 Bottle Incentive
        private Decimal bottleIncentive            {get; set;}
        private Decimal bottleIncentivePerformance {get; set;}

        //Column 9 Cash Sponsorship
        private Decimal cashSponsorship            {get; set;}
        private Decimal cashSponsorshipPerformance {get; set;}

        //Column 10 Total Allowances & Discounts
        private Decimal allowancesAndDiscounts            {get; set;}
        private Decimal allowancesAndDiscountsPerformance {get; set;}

        //Column 11 New Sales
        private Decimal netSales            {get; set;}
        private Decimal netSalesPerformance {get; set;}
        private Decimal netSalesDTG         {get; set;}

        //Column 12 Duty
        private Decimal duty            {get; set;}
        private Decimal dutyPerformance {get; set;}

        //Column 13 FOB + Handling Cost
        private Decimal fobHandlingCost            {get; set;}
        private Decimal fobHandlingCostPerformance {get; set;}

        //Column 14 Distribution Cost
        private Decimal distributionCost            {get; set;}
        private Decimal distributionCostPerformance {get; set;}

        //Column 15 Total Cost of Sales
        private Decimal costOfSales            {get; set;}
        private Decimal costOfSalesPerformance {get; set;}

        //Column 16 Gross Margin
        private Decimal grossMargin            {get; set;}
        private Decimal grossMarginPerformance {get; set;}
        private Decimal grossMarginDTG         {get; set;}

        //Column 17 Trade A&P Expenses
        private Decimal tradeAPExpenses            {get; set;}
        private Decimal tradeAPExpensesPerformance {get; set;}

        //Column 18 Marketing Support
        private Decimal marketingSupport            {get; set;}

        //Column 19 Sales Support
        private Decimal salesSupportPerformance {get; set;}

        //Column 20 Return On Investment 
        private Decimal roi            {get; set;}
        private Decimal roiPerformance {get; set;}
        private Decimal roiDTG         {get; set;}

        //Column 21 ROI in currency
        private Decimal roiCurrency            {get; set;}
        private Decimal roiCurrencyPerformance {get; set;}

        //Column 22 ROI In percentage
        private Decimal roiPercentage            {get; set;}
        private Decimal roiPercentagePerformance {get; set;}
		
		//Column Blind Bonus
        private Decimal blindBonus            {get; set;}
        private Decimal blindBonusPerformance {get; set;}

		//Column Blind Bonus
        private Decimal promptPayment            {get; set;}
        private Decimal promptPaymentPerformance {get; set;}

        //Column T&E Market Visit
        private Decimal tneMarketVisitOwner      {get; set;}
        private Decimal tneMarketVisitOthers     {get; set;}

        //Column Brand Event Held
        private Decimal brandEventHeld      {get; set;}
		
		//Column Last
		private Decimal subtotalForAdditionalCost						{get; set;}
		private Decimal subtotalForAdditionalCostPerformance			{get; set;}
		private Decimal roiAfterAdditionalCost							{get; set;}
		private Decimal roiAfterAdditionalCostPerformance				{get; set;}
		private Decimal roiPercentAfterAdditionalCost					{get; set;}
		private Decimal roiPercentAfterAdditionalCostPerformance		{get; set;}

        private ContractComparisonResultWrapper(Boolean isBaseContract, ASI_TH_CRM_Contract__c contract, List<ASI_TH_CRM_PaymentRequest__c> paymentList) {
            this.isBaseContract = isBaseContract;
            setBaseValue(contract, paymentList);
            unitInThousandField();
            roundUpField();
        }

        private void setBaseValue(ASI_TH_CRM_Contract__c baseContract, List<ASI_TH_CRM_PaymentRequest__c> basePaymentList) {
            //Set Header
            outlet = baseContract.ASI_CRM_CN_Outlet_WS__r.Name == null ? '' : baseContract.ASI_CRM_CN_Outlet_WS__r.Name;
            contractNo = baseContract.Name;
            contractPeriod = (baseContract.ASI_TH_CRM_Start_Date__c == null ? '' : baseContract.ASI_TH_CRM_Start_Date__c.format()) + ' - ' + (baseContract.ASI_TH_CRM_End_Date__c == null ? '' : baseContract.ASI_TH_CRM_End_Date__c.format());
			sectorCodeDetail = baseContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Category_Code_13__c;
			statusDetail = baseContract.ASI_TH_CRM_Contract_Status__c;
			inflationRate = (baseContract.ASI_CRM_Inflation_Rate__c == null ? 0 : baseContract.ASI_CRM_Inflation_Rate__c)/100;
			distributionRate = (baseContract.ASI_CRM_Distribution_Rate__c == null ? 0 : baseContract.ASI_CRM_Distribution_Rate__c)/100;
			

            //Set Detail
            /**** TO DO *****/
            contractMarginAndPriceOverwritePerformance = 0;
            
            grossSales                      = 0;
            contractMarginAndPriceOverwrite = 0;
            wholesalerMargin                = 0;
            bottleIncentive                 = 0;
            duty                            = 0;
            fobHandlingCost                 = 0;
            costOfSales                     = 0;
			blindBonus                      = 0;
			promptPayment                   = 0;
            for(ASI_CRM_ContractTarget__c contractTarget : baseContract.Contract_Target__r) {
                grossSales                      += contractTarget.ASI_CRM_SG_Gross_Sales__c == null ? 0 : contractTarget.ASI_CRM_SG_Gross_Sales__c;
                contractMarginAndPriceOverwrite += contractTarget.ASI_CRM_SG_Compensation_for_WS_Price_Dif__c == null ? 0 : contractTarget.ASI_CRM_SG_Compensation_for_WS_Price_Dif__c;
				/* [VL 1.0] BEGIN */
				/*
				wholesalerMargin				+= contractTarget.ASI_CRM_SG_Wholesaler_Margin_Total__c == null ? 0 : contractTarget.ASI_CRM_SG_Wholesaler_Margin_Total__c;
				*/
				if(baseContract.ASI_CRM_Contract_Exist_Before_RTM__c){
					wholesalerMargin			+= contractTarget.ASI_CRM_SG_Wholesaler_Margin_Total__c == null ? 0 : contractTarget.ASI_CRM_SG_Wholesaler_Margin_Total__c;
				} else {
					wholesalerMargin			+= contractTarget.ASI_CRM_Wholesaler_Margin_Total_RTM__c == null ? 0 : contractTarget.ASI_CRM_Wholesaler_Margin_Total_RTM__c;
				}
				/* [VL 1.0] END */
                bottleIncentive                 += contractTarget.ASI_CRM_Bottle_Incentive_Total__c == null ? 0 : contractTarget.ASI_CRM_Bottle_Incentive_Total__c;
                duty                            += contractTarget.ASI_CRM_Total_Duty__c == null ? 0 : contractTarget.ASI_CRM_Total_Duty__c;
                fobHandlingCost                 += ((contractTarget.ASI_CRM_Total_FOB__c == null ? 0 : contractTarget.ASI_CRM_Total_FOB__c) 
                                                 + (contractTarget.ASI_CRM_Total_Handling_Cost__c == null ? 0 : contractTarget.ASI_CRM_Total_Handling_Cost__c)
												 ) * (1 + inflationRate);
                costOfSales                     += contractTarget.ASI_CRM_SG_Cost_of_Sales__c == null ? 0 : -contractTarget.ASI_CRM_SG_Cost_of_Sales__c;
				blindBonus                      += contractTarget.ASI_CRM_Blind_Bonus_Amount__c == null ? 0 : contractTarget.ASI_CRM_Blind_Bonus_Amount__c;
				promptPayment                   += (contractTarget.ASI_CRM_SG_Gross_Sales__c == null ? 0 : contractTarget.ASI_CRM_SG_Gross_Sales__c) * (contractTarget.ASI_CRM_Prompt_Payment_Rate__c == null ? 0 : contractTarget.ASI_CRM_Prompt_Payment_Rate__c)/100;
            }
            
            salesVolPerformance = 0;
            for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : baseContract.ASI_CRM_Actual_Offtake__r) {
                salesVolPerformance += actualOfftake.ASI_CRM_Converted_Qty_9L__c == null ? 0 : actualOfftake.ASI_CRM_Converted_Qty_9L__c;
            }
            
			/*
            bottleIncentivePerformance = 0;
            cashSponsorshipPerformance = 0;
            salesSupportPerformance    = 0;
            for(ASI_TH_CRM_PaymentRequest__c paymentRequest : basePaymentList) {
                for(ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLineItem : paymentRequest.ASI_TH_CRM_PRLI_PaymentRequest__r) {
                    Decimal amount = paymentRequestLineItem.ASI_TH_CRM_Amount__c == null ? 0 : paymentRequestLineItem.ASI_TH_CRM_Amount__c;
                    if(paymentRequestLineItem.ASI_CRM_SG_Type__c.equals('Bottle Incentive') || 
                       paymentRequestLineItem.ASI_CRM_SG_Type__c.equals('Cash - Target Achieved')) {
                        bottleIncentivePerformance += amount; 
                    }
                    if(paymentRequestLineItem.ASI_CRM_SG_Type__c.equals('Cash - Upfront') || 
                       paymentRequestLineItem.ASI_CRM_SG_Type__c.equals('Cash - Target Achieved')) {
                        cashSponsorshipPerformance += amount;
                    }
                    if(paymentRequestLineItem.ASI_CRM_SG_Type__c.equals('Sales Support')) {
                        salesSupportPerformance += amount;
                    }
                }
            }
			*/
            
            salesVol    = baseContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c == null ? 0 : baseContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c;
            salesVolDTG = salesVol - salesVolPerformance;

            focVol            = baseContract.ASI_CRM_SG_Total_Free_Goods_9L_Cases__c == null ? 0 : baseContract.ASI_CRM_SG_Total_Free_Goods_9L_Cases__c;
            focVolPerformance = baseContract.ASI_CRM_FREE_GOODS_9L_ACTUAL__c == null ? 0 : baseContract.ASI_CRM_FREE_GOODS_9L_ACTUAL__c;
            focVolDTG         = focVol - focVolPerformance;

            focRatioVol            = baseContract.ASI_CRM_SG_Total_Free_Goods_9L_Cases__c == null ? 0 : baseContract.ASI_CRM_SG_Total_Free_Goods_9L_Cases__c
                                   / (baseContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c == null || baseContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c == 0 
                                      ? 1 : baseContract.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c)
                                   * 12;
            focRatioVolPerformance = focVolPerformance / (salesVolPerformance == 0 ? 1 : salesVolPerformance) * 12;

            
            grossSalesPerformance = baseContract.ASI_CRM_Gross_Sales_Actual__c == null ? 0 : baseContract.ASI_CRM_Gross_Sales_Actual__c;
            grossSalesDTG         = grossSales - grossSalesPerformance;

            freeGoods            = baseContract.ASI_CRM_Total_Free_Goods_Value__c == null ? 0 : baseContract.ASI_CRM_Total_Free_Goods_Value__c;
            freeGoodsPerformance = baseContract.ASI_CRM_Free_Goods_Actual__c == null ? 0 : baseContract.ASI_CRM_Free_Goods_Actual__c;
			
            freeGoodsAdhocPerformance = baseContract.ASI_CRM_Free_Goods_Ad_hoc_Actual__c == null ? 0 : baseContract.ASI_CRM_Free_Goods_Ad_hoc_Actual__c;
            
			contractMarginAndPriceOverwritePerformance = baseContract.ASI_CRM_ContractMarginPriceOverwrite_Act__c == null ? 0 : baseContract.ASI_CRM_ContractMarginPriceOverwrite_Act__c;

			wholesalerMarginPerformance = baseContract.ASI_CRM_Wholesaler_Margin_Actual__c == null ? 0 : baseContract.ASI_CRM_Wholesaler_Margin_Actual__c;

			bottleIncentivePerformance = baseContract.ASI_CRM_Bottle_Incentive_Actual__c == null ? 0 : baseContract.ASI_CRM_Bottle_Incentive_Actual__c;
			
            cashSponsorship = baseContract.ASI_CRM_SG_Total_Cash_Sponsorship__c == null ? 0 : baseContract.ASI_CRM_SG_Total_Cash_Sponsorship__c;
			cashSponsorshipPerformance = baseContract.ASI_CRM_Cash_Sponsorship_Actual__c == null ? 0 : baseContract.ASI_CRM_Cash_Sponsorship_Actual__c;
			
            /* [VL 1.0] BEGIN */
			/*
            allowancesAndDiscounts            = cashSponsorship + bottleIncentive + contractMarginAndPriceOverwrite + wholesalerMargin;
            allowancesAndDiscountsPerformance = freeGoodsPerformance + cashSponsorshipPerformance + bottleIncentivePerformance + contractMarginAndPriceOverwritePerformance + wholesalerMarginPerformance;
			*/
			/*[WL 2.0] BEGIN*/
			//allowancesAndDiscounts            = cashSponsorship + bottleIncentive + contractMarginAndPriceOverwrite + (baseContract.ASI_CRM_Contract_Exist_Before_RTM__c ? wholesalerMargin : 0);
			allowancesAndDiscounts            = freeGoods + cashSponsorship + bottleIncentive + contractMarginAndPriceOverwrite + (baseContract.ASI_CRM_Contract_Exist_Before_RTM__c ? wholesalerMargin : 0);
			/*[WL 2.0] BEGIN*/
			
            allowancesAndDiscountsPerformance = freeGoodsPerformance + cashSponsorshipPerformance + bottleIncentivePerformance + contractMarginAndPriceOverwritePerformance + (baseContract.ASI_CRM_Contract_Exist_Before_RTM__c ? wholesalerMarginPerformance : 0);
			/* [VL 1.0] END */
            
            netSales            = grossSales - allowancesAndDiscounts;
            netSalesPerformance = grossSalesPerformance - allowancesAndDiscountsPerformance;
            netSalesDTG         = netSales - netSalesPerformance;
            
            dutyPerformance = (baseContract.ASI_CRM_Total_Duty_Free_Goods_Actual__c == null ? 0 : baseContract.ASI_CRM_Total_Duty_Free_Goods_Actual__c)
                            + (baseContract.ASI_CRM_Total_Duty_Actual__c == null ? 0 : baseContract.ASI_CRM_Total_Duty_Actual__c);
            
            fobHandlingCostPerformance = ((baseContract.ASI_CRM_Total_FOB_Free_Goods_Actual__c == null ? 0 : baseContract.ASI_CRM_Total_FOB_Free_Goods_Actual__c)
                                       + (baseContract.ASI_CRM_Total_Handling_Cost_FOC_Actual__c == null ? 0 : baseContract.ASI_CRM_Total_Handling_Cost_FOC_Actual__c)
                                       + (baseContract.ASI_CRM_Total_FOB_Actual__c == null ? 0 : baseContract.ASI_CRM_Total_FOB_Actual__c)
                                       + (baseContract.ASI_CRM_Total_Handling_Cost_Actual__c == null ? 0 : baseContract.ASI_CRM_Total_Handling_Cost_Actual__c)
									   ) * (1 + inflationRate);
            
            distributionCost = grossSales * distributionRate;
            distributionCostPerformance = grossSalesPerformance * distributionRate;
            
            costOfSalesPerformance = dutyPerformance + fobHandlingCostPerformance + distributionCostPerformance;
            
            grossMargin            = netSales - costOfSales;
            grossMarginPerformance = netSalesPerformance - costOfSalesPerformance;
            grossMarginDTG         = grossMargin - grossMarginPerformance;
            
            tradeAPExpenses            = baseContract.ASI_CRM_SG_Total_Trade_A_P_PRS__c == null ? 0 : baseContract.ASI_CRM_SG_Total_Trade_A_P_PRS__c;
            tradeAPExpensesPerformance = baseContract.ASI_CRM_Trade_A_P_Expenses_Actual__c == null ? 0 : baseContract.ASI_CRM_Trade_A_P_Expenses_Actual__c;
            
            marketingSupport = baseContract.ASI_CRM_SG_Total_Marketing_A_P_Support__c == null ? 0 : baseContract.ASI_CRM_SG_Total_Marketing_A_P_Support__c;
			
			salesSupportPerformance = baseContract.ASI_CRM_Sales_Support_Actual__c == null ? 0 : baseContract.ASI_CRM_Sales_Support_Actual__c;
        
            roi            = baseContract.ASI_CRM_SG_Return_on_Investment__c == null ? 0 : baseContract.ASI_CRM_SG_Return_on_Investment__c;
            roiPerformance = grossMarginPerformance - tradeAPExpensesPerformance;
            roiDTG         = roi - roiPerformance;
			
            /*
            roiCurrency = roi / 1000;
            roiCurrencyPerformance = roiPerformance / 1000;
			*/
            roiCurrency = roi;
            roiCurrencyPerformance = roiPerformance;
            
            //roiPercentage = roi / (netSales == 0 ? 1 : netSales) * 100;
            roiPercentage = netSales == 0 ? 0 : (roi < 0 && netSales < 0 ? -100 * roi/netSales : 100 * roi/netSales);
            //roiPercentagePerformance = roiPerformance / (netSalesPerformance == 0 ? 1 : netSalesPerformance) * 100;
            roiPercentagePerformance = netSalesPerformance == 0 ? 0 : (roiPerformance < 0 && netSalesPerformance < 0 ? -100 * roiPerformance/netSalesPerformance : 100 * roiPerformance/netSalesPerformance);
			
			blindBonusPerformance    = baseContract.ASI_CRM_Blind_Bonus_Actual__c == null ? 0 : baseContract.ASI_CRM_Blind_Bonus_Actual__c;
			promptPaymentPerformance = baseContract.ASI_CRM_Prompt_Payment_Actual__c == null ? 0 : baseContract.ASI_CRM_Prompt_Payment_Actual__c;
			
			tneMarketVisitOwner  = baseContract.ASI_CRM_T_E_Market_Visit_Outlet_Owner__c == null ? 0 : baseContract.ASI_CRM_T_E_Market_Visit_Outlet_Owner__c;
			tneMarketVisitOthers = baseContract.ASI_CRM_T_E_Market_Visit_Others__c == null ? 0 : baseContract.ASI_CRM_T_E_Market_Visit_Others__c;
			
			brandEventHeld = baseContract.ASI_CRM_Brand_Event_Held__c == null ? 0 : baseContract.ASI_CRM_Brand_Event_Held__c;
			
			subtotalForAdditionalCost            = promptPayment + blindBonus;
			subtotalForAdditionalCostPerformance = blindBonusPerformance + promptPaymentPerformance + tneMarketVisitOwner + tneMarketVisitOthers + brandEventHeld;
			
			roiAfterAdditionalCost            = roi - subtotalForAdditionalCost;
			roiAfterAdditionalCostPerformance = roiPerformance - subtotalForAdditionalCostPerformance;
			
			//roiPercentAfterAdditionalCost            = roiAfterAdditionalCost / (netSales == 0 ? 1 : netSales) * 100;
            roiPercentAfterAdditionalCost = netSales == 0 ? 0 : (roiAfterAdditionalCost < 0 && netSales < 0 ? -100 * roiAfterAdditionalCost/netSales : 100 * roiAfterAdditionalCost/netSales);
			//roiPercentAfterAdditionalCostPerformance = roiAfterAdditionalCostPerformance / (netSalesPerformance == 0 ? 1 : netSalesPerformance) * 100;
            roiPercentAfterAdditionalCostPerformance = netSalesPerformance == 0 ? 0 : (roiAfterAdditionalCostPerformance < 0 && netSalesPerformance < 0 ? -100 * roiAfterAdditionalCostPerformance/netSalesPerformance : 100 * roiAfterAdditionalCostPerformance/netSalesPerformance);
			
        }
        
        private void unitInThousandField() {
            grossSales                                 = grossSales/1000;            
            grossSalesPerformance                      = grossSalesPerformance/1000; 
            grossSalesDTG                              = grossSalesDTG/1000;         
            freeGoods                                  = freeGoods/1000;            
            freeGoodsPerformance                       = freeGoodsPerformance/1000; 
            freeGoodsAdhocPerformance                  = freeGoodsAdhocPerformance/1000; 
            contractMarginAndPriceOverwrite            = contractMarginAndPriceOverwrite/1000;            
            contractMarginAndPriceOverwritePerformance = contractMarginAndPriceOverwritePerformance/1000; 
            wholesalerMargin			               = wholesalerMargin/1000;            
            wholesalerMarginPerformance	               = wholesalerMarginPerformance/1000;            
            bottleIncentive                            = bottleIncentive/1000;            
            bottleIncentivePerformance                 = bottleIncentivePerformance/1000; 
            cashSponsorship                            = cashSponsorship/1000;            
            cashSponsorshipPerformance                 = cashSponsorshipPerformance/1000; 
            allowancesAndDiscounts                     = allowancesAndDiscounts/1000;            
            allowancesAndDiscountsPerformance          = allowancesAndDiscountsPerformance/1000; 
            netSales                                   = netSales/1000;            
            netSalesPerformance                        = netSalesPerformance/1000; 
            netSalesDTG                                = netSalesDTG/1000;      
            duty                                       = duty/1000;            
            dutyPerformance                            = dutyPerformance/1000; 
            fobHandlingCost                            = fobHandlingCost/1000;            
            fobHandlingCostPerformance                 = fobHandlingCostPerformance/1000; 
            distributionCost                           = distributionCost/1000;            
            distributionCostPerformance                = distributionCostPerformance/1000; 
            costOfSales                                = costOfSales/1000;            
            costOfSalesPerformance                     = costOfSalesPerformance/1000; 
            grossMargin                                = grossMargin/1000;            
            grossMarginPerformance                     = grossMarginPerformance/1000; 
            grossMarginDTG                             = grossMarginDTG/1000;         
            tradeAPExpenses                            = tradeAPExpenses/1000;            
            tradeAPExpensesPerformance                 = tradeAPExpensesPerformance/1000; 
            marketingSupport                           = marketingSupport/1000;            
            salesSupportPerformance                    = salesSupportPerformance/1000; 
            roi                                        = roi/1000;            
            roiPerformance                             = roiPerformance/1000; 
            roiDTG                                     = roiDTG/1000;         
            roiCurrency                                = roiCurrency/1000;            
            roiCurrencyPerformance                     = roiCurrencyPerformance/1000; 
			tneMarketVisitOwner                        = tneMarketVisitOwner/1000;
			tneMarketVisitOthers                       = tneMarketVisitOthers/1000;
			brandEventHeld                             = brandEventHeld/1000;
			blindBonus                                 = blindBonus/1000;
			blindBonusPerformance                      = blindBonusPerformance/1000;
			promptPayment                              = promptPayment/1000;
			promptPaymentPerformance                   = promptPaymentPerformance/1000;
			subtotalForAdditionalCost                  = subtotalForAdditionalCost/1000;
			subtotalForAdditionalCostPerformance       = subtotalForAdditionalCostPerformance/1000;
			roiAfterAdditionalCost                     = roiAfterAdditionalCost/1000;
			roiAfterAdditionalCostPerformance          = roiAfterAdditionalCostPerformance/1000;
        }

        private void roundUpField() {
            salesVol                                   = salesVol.setScale(0);
            salesVolPerformance                        = salesVolPerformance.setScale(0);
            salesVolDTG                                = salesVolDTG.setScale(0);         
            focVol                                     = focVol.setScale(2);            
            focVolPerformance                          = focVolPerformance.setScale(2); 
            focVolDTG                                  = focVolDTG.setScale(2);         
            focRatioVol                                = focRatioVol.setScale(2);            
            focRatioVolPerformance                     = focRatioVolPerformance.setScale(2); 
            grossSales                                 = grossSales.setScale(2);            
            grossSalesPerformance                      = grossSalesPerformance.setScale(2); 
            grossSalesDTG                              = grossSalesDTG.setScale(2);         
            freeGoods                                  = freeGoods.setScale(2);            
            freeGoodsPerformance                       = freeGoodsPerformance.setScale(2); 
            freeGoodsAdhocPerformance                  = freeGoodsAdhocPerformance.setScale(2); 
            contractMarginAndPriceOverwrite            = contractMarginAndPriceOverwrite.setScale(2);            
            contractMarginAndPriceOverwritePerformance = contractMarginAndPriceOverwritePerformance.setScale(2); 
            wholesalerMargin			               = wholesalerMargin.setScale(2);            
            wholesalerMarginPerformance	               = wholesalerMarginPerformance.setScale(2);            
            bottleIncentive                            = bottleIncentive.setScale(2);            
            bottleIncentivePerformance                 = bottleIncentivePerformance.setScale(2); 
            cashSponsorship                            = cashSponsorship.setScale(2);            
            cashSponsorshipPerformance                 = cashSponsorshipPerformance.setScale(2); 
            allowancesAndDiscounts                     = allowancesAndDiscounts.setScale(2);            
            allowancesAndDiscountsPerformance          = allowancesAndDiscountsPerformance.setScale(2); 
            netSales                                   = netSales.setScale(2);            
            netSalesPerformance                        = netSalesPerformance.setScale(2); 
            netSalesDTG                                = netSalesDTG.setScale(2);      
            duty                                       = duty.setScale(2);            
            dutyPerformance                            = dutyPerformance.setScale(2); 
            fobHandlingCost                            = fobHandlingCost.setScale(2);            
            fobHandlingCostPerformance                 = fobHandlingCostPerformance.setScale(2); 
            distributionCost                           = distributionCost.setScale(2);            
            distributionCostPerformance                = distributionCostPerformance.setScale(2); 
            costOfSales                                = costOfSales.setScale(2);            
            costOfSalesPerformance                     = costOfSalesPerformance.setScale(2); 
            grossMargin                                = grossMargin.setScale(2);            
            grossMarginPerformance                     = grossMarginPerformance.setScale(2); 
            grossMarginDTG                             = grossMarginDTG.setScale(2);         
            tradeAPExpenses                            = tradeAPExpenses.setScale(2);            
            tradeAPExpensesPerformance                 = tradeAPExpensesPerformance.setScale(2); 
            marketingSupport                           = marketingSupport.setScale(2);            
            salesSupportPerformance                    = salesSupportPerformance.setScale(2); 
            roi                                        = roi.setScale(2);            
            roiPerformance                             = roiPerformance.setScale(2); 
            roiDTG                                     = roiDTG.setScale(2);         
            roiCurrency                                = roiCurrency.setScale(2);            
            roiCurrencyPerformance                     = roiCurrencyPerformance.setScale(2); 
            roiPercentage                              = roiPercentage.setScale(2);            
            roiPercentagePerformance                   = roiPercentagePerformance.setScale(2); 
			tneMarketVisitOwner                        = tneMarketVisitOwner.setScale(2);
			tneMarketVisitOthers                       = tneMarketVisitOthers.setScale(2);
			brandEventHeld                             = brandEventHeld.setScale(2);
			blindBonus                                 = blindBonus.setScale(2);
			blindBonusPerformance                      = blindBonusPerformance.setScale(2);
			promptPayment                              = promptPayment.setScale(2);
			promptPaymentPerformance                   = promptPaymentPerformance.setScale(2);
			subtotalForAdditionalCost                  = subtotalForAdditionalCost.setScale(2);
			subtotalForAdditionalCostPerformance       = subtotalForAdditionalCostPerformance.setScale(2);
			roiAfterAdditionalCost                     = roiAfterAdditionalCost.setScale(2);
			roiAfterAdditionalCostPerformance          = roiAfterAdditionalCostPerformance.setScale(2);
			roiPercentAfterAdditionalCost              = roiPercentAfterAdditionalCost.setScale(2);
			roiPercentAfterAdditionalCostPerformance   = roiPercentAfterAdditionalCostPerformance.setScale(2);
        }

    }

    private final static Set<String> CONTRACT_RECORD_TYPE_SET = new Set<String> {
        'ASI_CRM_SG_Contract',
        'ASI_CRM_SG_Contract_Read_Only',
        'ASI_CRM_SG_Contract_Archived',
        'ASI_CRM_SG_Proposal',
        'ASI_CRM_SG_Proposal_Read_Only',
        'ASI_CRM_SG_Proposal_Archived'
    };

    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
	private final static list<string> CONTRACT_FIELD_LIST = new list<string>{
		'Name',
		'ASI_CRM_Contract_Exist_Before_RTM__c',
		'ASI_TH_CRM_Start_Date__c',
		'ASI_TH_CRM_End_Date__c',
		'ASI_CRM_SG_Total_Target_Sales_9L_Cases__c',
		'ASI_CRM_SG_Total_Free_Goods_9L_Cases__c',
		'ASI_CRM_FREE_GOODS_9L_ACTUAL__c',
		'ASI_CRM_Gross_Sales_Actual__c',
		'ASI_CRM_Total_Free_Goods_Value__c',
		'ASI_CRM_Free_Goods_Actual__c',
		'ASI_CRM_Free_Goods_Ad_hoc_Actual__c',
		'ASI_CRM_ContractMarginPriceOverwrite_Act__c',
		'ASI_CRM_Wholesaler_Margin_Actual__c',
		'ASI_CRM_Bottle_Incentive_Actual__c',
		'ASI_CRM_SG_Total_Cash_Sponsorship__c',
		'ASI_CRM_Cash_Sponsorship_Actual__c',
		'ASI_CRM_Total_Duty_Free_Goods_Actual__c',
		'ASI_CRM_Total_Duty_Actual__c',
		'ASI_CRM_Total_FOB_Free_Goods_Actual__c',
		'ASI_CRM_Total_Handling_Cost_FOC_Actual__c',
		'ASI_CRM_Total_FOB_Actual__c',
		'ASI_CRM_Total_Handling_Cost_Actual__c',
		'ASI_CRM_Distribution_Rate__c',
		'ASI_CRM_SG_Total_Trade_A_P_PRS__c',
		'ASI_CRM_Trade_A_P_Expenses_Actual__c',
		'ASI_CRM_SG_Total_Marketing_A_P_Support__c',
		'ASI_CRM_Sales_Support_Actual__c',
		'ASI_CRM_SG_Return_on_Investment__c',
        'ASI_CRM_SG_PDF_Attachment__c',
		'ASI_TH_CRM_Contract_Status__c',
		'ASI_CRM_T_E_Market_Visit_Outlet_Owner__c',
		'ASI_CRM_T_E_Market_Visit_Others__c',
		'ASI_CRM_Brand_Event_Held__c',
		'ASI_CRM_Blind_Bonus_Actual__c',
		'ASI_CRM_Prompt_Payment_Actual__c',
		'ASI_CRM_Inflation_Rate__c'
	};
	private final static list<string> CONTRACT_FIELD_LIST_SIMPLE = new list<string>{
		'Name',
		'ASI_CRM_Contract_Exist_Before_RTM__c',
		'ASI_TH_CRM_Start_Date__c',
		'ASI_TH_CRM_End_Date__c',
		'ASI_TH_CRM_Contract_Status__c'
	};
    private final static String PAYMENT_REQUEST_RECORD_TYPE = 'ASI_CRM_SG_Payment_Request_Read_Only';
	private static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';

    
    private String baseContractId;
    private List<String> contractIdList;
    
    //JSON String for VF Page
    public String contractListJson                        {get {return toJsonString(contractList);}}
    public String contractComparisonResultWrapperListJson {get {return toJsonString(contractComparisonResultWrapperList);}}
    public Boolean getShowComparison(){
        return Boolean.valueOf(ApexPages.currentPage().getParameters().containsKey('showComparison') ? ApexPages.currentPage().getParameters().get('showComparison') : 'false');
    }
    public Boolean submitRTM			{get; set;}

    //All contract records
    public List<ASI_TH_CRM_Contract__c> contractList { get; set; }
    public List<ContractComparisonResultWrapper> contractComparisonResultWrapperList;
	
    public PageReference pageRef = ApexPages.currentPage();
    
    //Init
    public ASI_CRM_SG_ContractComparison_Controller() {
        contractList = retrieveContractList();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        contractIdList = new List<String>();
        Boolean isDefaultedContract = false;
        if(params.containsKey('BASE_CONTRACT_ID') && String.isNotBlank(params.get('BASE_CONTRACT_ID'))) {
            contractIdList.add(params.get('BASE_CONTRACT_ID'));
            baseContractId = params.get('BASE_CONTRACT_ID');
            isDefaultedContract = true;
        }
        if(params.containsKey('CONTRACT_ONE') && String.isNotBlank(params.get('CONTRACT_ONE'))) {
            contractIdList.add(params.get('CONTRACT_ONE'));
        }
        if(params.containsKey('CONTRACT_TWO') && String.isNotBlank(params.get('CONTRACT_TWO'))) {
            contractIdList.add(params.get('CONTRACT_TWO'));
        }
        if(params.containsKey('CONTRACT_THREE') && String.isNotBlank(params.get('CONTRACT_THREE'))) {
            contractIdList.add(params.get('CONTRACT_THREE'));
        }
        if(params.containsKey('submitRTM') && String.isNotBlank(params.get('submitRTM'))) {
            submitRTM = params.get('submitRTM') == '1' ? true : false;
        } else {
			submitRTM = false;
		}
		
		
        if(isDefaultedContract) {
        	compareContract(baseContractId, contractIdList);
        }
    }

    public void compareContractFromVFPage() {
        //Retrieve data from VF Page
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String contractIdListJson  = params.get('CONTRACT_ID_LIST_JSON');
        baseContractId      = params.get('BASE_CONTRACT_ID');
        
        //Convert contract id list json to contract id list
        contractIdList = (List<String>) fromJsonString(contractIdListJson, List<String>.class);
        
        compareContract(baseContractId, contractIdList);
    }
    
    public void compareContract(String baseContractId, List<String> contractIdList) {
        //Retrieve the contract records that need to be compared
        Map<Id, ASI_TH_CRM_Contract__c> compareContractMap = new Map<Id, ASI_TH_CRM_Contract__c>(retrieveContractWithChildList(contractIdList));
        Map<Id, List<ASI_TH_CRM_PaymentRequest__c>> contractPaymentMap = retrieveContractPaymentMap(contractIdList);

        //Init wrapperList
        contractComparisonResultWrapperList = new List<ContractComparisonResultWrapper>();

        //Get the base contract and remove it in the map
        ASI_TH_CRM_Contract__c baseContract = compareContractMap.get(baseContractId);
        compareContractMap.remove(baseContractId);

        List<ASI_TH_CRM_PaymentRequest__c> basePaymentList = contractPaymentMap.containsKey(baseContract.Id) ? contractPaymentMap.get(baseContract.Id) : new List<ASI_TH_CRM_PaymentRequest__c>();

        //Create base contract wrapper
        ContractComparisonResultWrapper baseContractComparisonResultWrapper = new ContractComparisonResultWrapper(true, baseContract, basePaymentList);
        contractComparisonResultWrapperList.add(baseContractComparisonResultWrapper);

        //Create other contract wrapper
        for(Id contractId : compareContractMap.keySet()) {
            ASI_TH_CRM_Contract__c contract = compareContractMap.get(contractId);
            List<ASI_TH_CRM_PaymentRequest__c> paymentList = contractPaymentMap.containsKey(contractId) ? contractPaymentMap.get(contractId) : new List<ASI_TH_CRM_PaymentRequest__c>();
            ContractComparisonResultWrapper contractComparisonResultWrapper = new ContractComparisonResultWrapper(false, contract, paymentList);
            contractComparisonResultWrapperList.add(contractComparisonResultWrapper);
        }   

    }
    
    //Pass the table content and redirect to the PDF page and 
    public PageReference redirectPDF() {
        PageReference pageRef = null;
        
        ASI_TH_CRM_Contract__c contract = retrieveContract(baseContractId);
        if(contract != null) {
        	Map<String, String> params = ApexPages.currentPage().getParameters();
			
			// if the attachment already exist, delete its upload log
			if (contract.ASI_CRM_SG_PDF_Attachment__c != null){
				List<String> pdfAttachmentList = contract.ASI_CRM_SG_PDF_Attachment__c.split(';');
            
				String contractComparsionAttId;
				for(String pdfAtt : pdfAttachmentList) {
				  if(pdfAtt.contains('ContractComparsionPDF')) {
						contractComparsionAttId = pdfAtt.split(':')[1];
					}
				}
				if(String.isNotBlank(contractComparsionAttId)) {
				  List<Attachment> list_tempAttachment = [SELECT ParentId FROM Attachment WHERE Id = :contractComparsionAttId];
                    if (list_tempAttachment.size()>0){
                        Attachment tempAttachment = list_tempAttachment[0];
                      	delete [SELECT id FROM ASI_MFM_Mass_Upload_Log__c WHERE id = :tempAttachment.ParentId];
                    }
				}
			}
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
            insert uploadLog;

            Attachment tempAttached = new Attachment();
            tempAttached.ParentId = uploadLog.Id;
            tempAttached.Name = 'Contract Comparison Result';
            tempAttached.Body = Blob.valueOf(params.get('TABLE_CONTENT'));
            insert tempAttached;
            
            String pdfAttachment = 'ContractComparsionPDF:' + tempAttached.Id + ';';
            if(String.isNotBlank(contract.ASI_CRM_SG_PDF_Attachment__c)) {
                List<String> pdfAttachmentList = contract.ASI_CRM_SG_PDF_Attachment__c.split(';');
                
                for(String pdfAtt : pdfAttachmentList) {
                    if(pdfAtt.contains('ContractComparsionPDF')) {
                        continue;
                    } else {
                    	pdfAttachment += pdfAtt + ';';
                    }
            	}
                
            }
            
            contract.ASI_CRM_SG_PDF_Attachment__c = pdfAttachment;
            update contract;
            
            pageRef = new PageReference('/apex/ASI_CRM_SG_SubmitApprovalPage?id=' + baseContractId);
	    	pageRef.setRedirect(true);
        }
        
        return pageRef;
    }
    
	public void searchContract(){
        Map<String, String> params      = ApexPages.currentPage().getParameters();
        String inputDateStr             = params.get('inputDate');
        String startDateStr             = params.get('startDate');
        String endDateStr               = params.get('endDate');
        List<String> statusList         = (List<String>) fromJsonString(params.get('statusListJson'), List<String>.class);
		
        Date startDate = Date.valueOf(startDateStr);
		Date endDate = Date.valueOf(endDateStr);

        String inputDate = inputDateStr == 'start' ? 'ASI_TH_CRM_Start_Date__c' : 'ASI_TH_CRM_End_Date__c';
		
		contractList = new List<ASI_TH_CRM_Contract__c>();
		contractList = retrieveContractListFilter(inputDate, startDate, endDate, statusList);
	}
	
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_TH_CRM_Contract__c> retrieveContractList() {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) + ', ' +
						'RecordType.DeveloperName, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Category_Code_13__c, owner.name ' +
                       'FROM ASI_TH_CRM_Contract__c ' +
                       'WHERE RecordType.DeveloperName in : CONTRACT_RECORD_TYPE_SET';

        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
        return contractList.size() > 0 ? contractList : new List<ASI_TH_CRM_Contract__c>();
    }
	
    private List<ASI_TH_CRM_Contract__c> retrieveContractListFilter(string inputDate, date startDate, date endDate, list<string> status) {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) + ', ' +
						'RecordType.DeveloperName, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Category_Code_13__c, owner.name ' +
                       'FROM ASI_TH_CRM_Contract__c ' +
                       'WHERE RecordType.DeveloperName in : CONTRACT_RECORD_TYPE_SET ' +
					   'AND ASI_TH_CRM_Contract_Status__c in :status ' +
					   'AND ' + inputDate + ' >= :startDate ' +
					   'AND ' + inputDate + ' <= :endDate ';

        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
        return contractList.size() > 0 ? contractList : new List<ASI_TH_CRM_Contract__c>();
    }

    private ASI_TH_CRM_Contract__c retrieveContract(Id contractId) {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST) + ', RecordType.DeveloperName ' +
                       'FROM ASI_TH_CRM_Contract__c ' +
                       'WHERE Id = : contractId';
        
        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
        return contractList.size() > 0 ? contractList.get(0) : null;
    }
    
    private List<ASI_TH_CRM_Contract__c> retrieveContractWithChildList(List<Id> contractIdList) {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST) +
                       ', RecordType.DeveloperName, owner.name, ' +
                        //Retrieve ASI_CRM_CN_Outlet_WS__c record
                       'ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Outlet_WS__r.Owner.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Category_Code_13__c, ' + 
                       'ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Main_Sector__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_PROS_Outlet_Type__c, ' + 
                       //Retrieve Contract Target
                       '(SELECT ASI_CRM_SG_Gross_Sales__c, ASI_CRM_Total_Duty__c, ASI_CRM_Total_FOB__c, ' + 
                       'ASI_CRM_Total_Handling_Cost__c, ASI_CRM_SG_Cost_of_Sales__c, ASI_CRM_SG_Target_Sales_9L_Cases__c, ' + 
                       'ASI_CRM_Prompt_Payment_Rate__c, ASI_CRM_Blind_Bonus_Amount__c, ASI_CRM_Bottle_Incentive_Total__c, ASI_CRM_SG_Contract_Margin_Total__c, ' +
                       'ASI_CRM_SG_Compensation_for_WS_Price_Dif__c, ASI_CRM_SG_Wholesaler_Margin_Total__c ' +
					   /* [VL 1.0] BEGIN */
                       ', ASI_CRM_Wholesaler_Margin_Total_RTM__c ' +
					   /* [VL 1.0] END */
                       'FROM Contract_Target__r WHERE recordtype.developername = :CONTRACTTARGET_RECORD_TYPE), ' + 
                       //Retrieve Actual Offtake
                       '(SELECT ASI_CRM_Converted_Qty_9L__c FROM ASI_CRM_Actual_Offtake__r) ' + 
                       'FROM ASI_TH_CRM_Contract__c ' +
                       'WHERE RecordType.DeveloperName in : CONTRACT_RECORD_TYPE_SET ' + 
                       'AND Id in : contractIdList';

        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
        return contractList.size() > 0 ? contractList : new List<ASI_TH_CRM_Contract__c>();
    }

    private Map<Id, List<ASI_TH_CRM_PaymentRequest__c>> retrieveContractPaymentMap (List<Id> contractIdList) {
        Map<Id, List<ASI_TH_CRM_PaymentRequest__c>> contractPaymentMap = new Map<Id, List<ASI_TH_CRM_PaymentRequest__c>>();

        String query = 'SELECT Id, ASI_TH_CRM_Contract__c, ' + 
                       '(SELECT ASI_CRM_SG_Type__c, ASI_TH_CRM_Amount__c FROM ASI_TH_CRM_PRLI_PaymentRequest__r) ' + 
                       'FROM ASI_TH_CRM_PaymentRequest__c ' + 
                       'WHERE ASI_TH_CRM_Contract__c in : contractIdList ' + 
                       'AND RecordType.DeveloperName = : PAYMENT_REQUEST_RECORD_TYPE ' + 
                       'AND ASI_TH_CRM_Status__c = \'Approved\'';

        List<ASI_TH_CRM_PaymentRequest__c> paymentRequestList = (List<ASI_TH_CRM_PaymentRequest__c>) Database.query(query);
        for(ASI_TH_CRM_PaymentRequest__c paymentRequest : paymentRequestList) {
            List<ASI_TH_CRM_PaymentRequest__c> tempPaymentRequestList = contractPaymentMap.get(paymentRequest.ASI_TH_CRM_Contract__c);
            if(tempPaymentRequestList == null) tempPaymentRequestList = new List<ASI_TH_CRM_PaymentRequest__c>();
            tempPaymentRequestList.add(paymentRequest);
            contractPaymentMap.put(paymentRequest.ASI_TH_CRM_Contract__c, tempPaymentRequestList);
        }
        return contractPaymentMap;
    }

    /***************
    Tools Function
    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private String genQueryFieldFromList(list<string> fieldList) {
        return String.join(fieldList, ',');
    }

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private List<Object> fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return (List<Object>) System.JSON.deserialize(jsonString, apexType);
    }

    public string inputEndDate{
        get{
			Datetime dt = System.now();            
            return dt.format('YYYY-MM-dd');
        }
        set;
    }
	
    public string inputStartDate{
        get{
			Datetime dt = System.now().addYears(-2);            
            return dt.format('YYYY-MM-dd');
        }
        set;
    }
	
}