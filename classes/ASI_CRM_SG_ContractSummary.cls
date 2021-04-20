/*********************************************************************************
 * Name: ASI_CRM_SG_ContractSummary
 * Description: Controller class for ASI_CRM_SG_ContractSummary
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-10		Laputa: Vincent			Create
 * 2018-03-27       Laputa: Vincent         [VL 1.0] ICM117657570 : use new field to store RTM wholesaler margin
 */

public class ASI_CRM_SG_ContractSummary {
	
    private Id contractId;
    public boolean external {get; set;}
	public String CorP {get; set;}
    public boolean existBeforeRTM {get; set;}

    public ASI_CRM_SG_ContractSummary(ApexPages.StandardController stdController) {
        contractId = APexPages.currentPage().getParameters().get('Id');
        external = APexPages.currentPage().getParameters().get('external') == '1' ? true : false;
        CorP = APexPages.currentPage().getParameters().get('type') == 'c' ? 'Contract' : 'Proposal';
        existBeforeRTM = APexPages.currentPage().getParameters().get('existBeforeRTM') == '1' ? true : false;
    }
    
    public ASI_TH_CRM_Contract__c getContract(){
        ASI_TH_CRM_Contract__c c = [
            select id, name,
            // detail
            ASI_CRM_CN_Outlet_WS__r.name,
            ASI_CRM_CN_Outlet_WS__c,
            owner.firstname, owner.lastname,
            ASI_CRM_Remarks__c,
            ASI_CRM_Converted_From__r.name,
            ASI_CRM_Original_Version__r.name,
            ASI_CRM_Version__c,
            ASI_CRM_Type__c,
            ASI_TH_CRM_Contract_Status__c,
            ASI_TH_CRM_Start_Date__c,
            ASI_TH_CRM_End_Date__c,
            ASI_CRM_Early_Contract_Completed__c,
            ASI_CRM_Contract_Period_Extended__c,
            // outlet
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Legal_Outlet_Name__c,
            ASI_CRM_CN_Outlet_WS__r.owner.firstname, ASI_CRM_CN_Outlet_WS__r.owner.lastname,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Business_Registration_Number__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_IsParentAccount__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Inactive_Flag__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Parent_Outlet__r.name,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Main_Sector__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Outlet_Capacity__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_JP_City_Ward__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Phone_Number__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_JP_Town__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Fax_Number__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Street_Number__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Category_Code_13__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_PostalCode__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Area__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Location__c,
            // Marketing A&P support
            ASI_CRM_SG_Anniversary__c,
            ASI_CRM_SG_Anniversary_Amount__c,
            ASI_CRM_SG_Training__c,
            ASI_CRM_SG_Training_Amount__c,
            ASI_CRM_SG_POSM__c,
            ASI_CRM_SG_POSM_Amount__c,
            ASI_CRM_SG_Events__c,
            ASI_CRM_SG_Events_Amount__c,
            ASI_CRM_SG_Total_Marketing_A_P_Support__c,
            // summary
            ASI_CRM_Inflation_Rate__c,
            ASI_CRM_Distribution_Rate__c,
            ASI_CRM_TotalSalesTargetCase__c,
            ASI_CRM_SG_Total_Free_Goods_Cases__c,
            ASI_CRM_SG_Total_Target_Sales_9L_Cases__c,
            ASI_CRM_SG_Total_Free_Goods_9L_Cases__c,
            ASI_CRM_SG_Total_Contract_Margin__c,
            ASI_CRM_SG_TotalCashGoodsinkindSponsor__c,
            ASI_CRM_SG_Total_Cash_Sponsorship__c,
            ASI_CRM_SG_Net_Sales__c,
            ASI_CRM_Total_Cash_Sponsorship_Cash__c,
            ASI_CRM_SG_Return_on_Investment__c,
            ASI_CRM_SG_TotalTradeAPFOCWSOntradeSP__c,
            ASI_CRM_SG_Total_Volume_Cases__c,
            ASI_CRM_SG_Total_Trade_A_P_PRS__c,
            ASI_CRM_SG_Total_Volume_9L_Cases__c,
            ASI_CRM_SG_TotalInvestment_Value_for_PRS__c,
            ASI_CRM_Sales_Revenue_Target__c,
            ASI_CRM_Total_Free_Goods_Value__c,
			ASI_CRM_Till_Date_Sales_Volume_9L__c,
			ASI_CRM_Sales_Revenue__c,
			ASI_CRM_Return_On_Investment_Actual__c,
			ASI_CRM_Till_Date_Sales_Percent_Achieved__c,
			ASI_CRM_ROI_Percent_Actual__c
            FROM ASI_TH_CRM_Contract__c
            WHERE id = :contractId
            LIMIT 1
        ];
        return c;
    }
    
    public decimal totalPackageSize {get; set;}
    public decimal totalSalesCases {get; set;}
    public decimal totalSales9L {get; set;}
    public decimal totalDuty {get; set;}
    public decimal totalFOB {get; set;}
    public decimal totalHandling {get; set;}
    public decimal totalTotalCOGS {get; set;}
    public decimal totalWSOTPerBottle {get; set;}
    public decimal totalSalesIncentive {get; set;}
    public decimal totalManagementIncentive {get; set;}
    public decimal totalCSTargetIncentive {get; set;}
    public decimal totalOthers {get; set;}
    public decimal totalConsumerOffer {get; set;}
    public decimal totalWSMargin {get; set;}
    public decimal totalBottleIncentive {get; set;}
    public decimal totalBottleIncentiveTotal {get; set;}
    public decimal totalGoodsInKind {get; set;}
    public decimal totalCash {get; set;}
    public decimal totalEventCase {get; set;}
    public decimal totalEventValue {get; set;}
    public decimal totalSignageCase {get; set;}
    public decimal totalSignageValue {get; set;}
    public decimal totalASCase {get; set;}
    public decimal totalASValue {get; set;}
    public decimal totalAnniversary {get; set;}
    public decimal totalTradeIncentive {get; set;}
    public decimal totalProductBranding {get; set;}
    public decimal totalAdhoc {get; set;}
    public decimal totalAdhocMoney {get; set;}
    public decimal totalAPWSOT {get; set;}
    public decimal totalAPPRSWS {get; set;}
    
    public boolean notDisplayFGTab {get; set;}
    public boolean notDisplayCMTab {get; set;}
    public boolean notDisplayCSTab {get; set;}
    public boolean notDisplayAPTab {get; set;}
    
    public list<ASI_CRM_Payment_Schedule__c> CashSponsorshipSchedule {get; set;}
    public list<ASI_CRM_Payment_Schedule__c> ContractSponsorshipSchedule {get; set;}
    
    public void getPaymentSchedule(){
        CashSponsorshipSchedule = new list<ASI_CRM_Payment_Schedule__c>();
        ContractSponsorshipSchedule = new list<ASI_CRM_Payment_Schedule__c>();
        list<ASI_CRM_Payment_Schedule__c> psList = [
            select id,
            ASI_CRM_Sponsorship__c,
            ASI_CRM_Percentof_achieved_Sales_Target__c,
            ASI_CRM_Schedule_Date__c,
            ASI_CRM_Type__c,
			ASI_CRM_Payment_Issued__c,
			ASI_CRM_Remarks__c
            from ASI_CRM_Payment_Schedule__c
            Where ASI_CRM_Contract__c = :contractId
            AND recordtype.developername = 'ASI_CRM_SG_Payment_Schedule'
			Order by ASI_CRM_Schedule_Date__c asc NULLS FIRST, ASI_CRM_Percent_Achieved__c asc
        ];
        for (ASI_CRM_Payment_Schedule__c ps : psList){
            if (ps.ASI_CRM_Type__c == 'Cash Sponsorship') {
                CashSponsorshipSchedule.add(ps);
            } else {
                ContractSponsorshipSchedule.add(ps);
            }
        }
    }
    
    public List<ASI_CRM_ContractTarget__c> getContractTarget(){
        List<ASI_CRM_ContractTarget__c> ctList = [
            select id, 
            // SKU
            ASI_CRM_SKU__r.name,
			ASI_CRM_SKU__r.ASI_CRM_Short_Description__c,
            ASI_CRM_Subbrand__r.name,
			ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Description__c,
			ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c,
			ASI_CRM_SKU__r.ASI_HK_CRM_Pack_Factor__c,
            ASI_CRM_TargetCase__c,
            ASI_CRM_SG_Target_Sales_9L_Cases__c,
            ASI_CRM_Total_Duty__c,
            ASI_CRM_Total_FOB__c,
            ASI_CRM_Total_Handling_Cost__c,
            ASI_CRM_PackagingSize__c,
            ASI_CRM_Total_COGS__c,
            //Incentive
            ASI_CRM_Entitle_Back_Rebates__c,
            ASI_CRM_SG_Anniversary__c,
            ASI_CRM_SG_Net_Price__c,
            ASI_CRM_SG_Net_Net_Price__c,
            ASI_CRM_Net_Net_Price_After_A_P__c,
            // FOC
            ASI_CRM_SG_Sales_Incentive__c,
            ASI_CRM_SG_Management_Incentives__c,
            ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c,
            ASI_CRM_SG_Others__c,
            ASI_CRM_SG_Total_Free_Goods_Cases__c,
            ASI_CRM_SG_Total_Free_Goods_9L_Cases__c,
            // Contract Margin
            ASI_CRM_SG_Consumer_Price_Offer__c,
            ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c,
            ASI_CRM_SG_Compensation_for_WS_Price_Dif__c,
            ASI_CRM_SG_Wholesaler_Margin__c,
            ASI_CRM_SG_Wholesaler_Margin_Total__c,
            ASI_CRM_SG_Contract_Margin_per_9Lc__c,
            ASI_CRM_SG_Contract_Margin_Total__c,
			/* [VL 1.0] BEGIN */
            ASI_CRM_Wholesaler_Margin_RTM__c,
            ASI_CRM_Wholesaler_Margin_Total_RTM__c,
			/* [VL 1.0] END */
            ASI_CRM_Bottle_Incentive__c,
            ASI_CRM_Bottle_Incentive_Total__c,
            // cash sponsorship
            ASI_CRM_SG_Good_in_Kinds__c,
            ASI_CRM_SG_Cash__c,
            ASI_CRM_SG_Cash_Sponsorship_Total__c,
            // A&P
            ASI_CRM_SG_Events_Free_Bottles__c,
            ASI_CRM_SG_Events__c,
            ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c,
            ASI_CRM_SG_Signages_Advertising_Spot__c,
            ASI_CRM_Advertising_Spot_Free_Bottles__c,
            ASI_CRM_Advertising_Spot__c,
            ASI_CRM_SG_Anniversary_Free_Bottles__c,
            ASI_CRM_SG_Trade_Incentive_Trips__c,
            ASI_CRM_SG_Product_Branding_Display__c,
            ASI_CRM_SG_Ad_hoc_Promotions__c,
            ASI_CRM_SG_Trd_Adv_Promo_Total__c,
            ASI_CRM_SG_Trd_Adv_Promo_TotalPRS__c,
            // SKU Achievement
            ASI_CRM_Till_Date_Sales_Percent_Bottle__c,
            ASI_CRM_Back_Rebates_Issued_Percent__c,
            ASI_CRM_System_Remarks__c
            FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c = : contractId
            AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
            ORDER BY ASI_CRM_Sequence_No__c
        ];
        
        for (ASI_CRM_ContractTarget__c ct: ctList){
            totalPackageSize += ct.ASI_CRM_PackagingSize__c == null ? 0 : ct.ASI_CRM_PackagingSize__c;
            totalSalesCases += ct.ASI_CRM_TargetCase__c == null ? 0 : ct.ASI_CRM_TargetCase__c;
            totalSales9L += ct.ASI_CRM_SG_Target_Sales_9L_Cases__c == null ? 0 : ct.ASI_CRM_SG_Target_Sales_9L_Cases__c;
            totalDuty += ct.ASI_CRM_Total_Duty__c == null ? 0 : ct.ASI_CRM_Total_Duty__c;
            totalFOB += ct.ASI_CRM_Total_FOB__c == null ? 0 : ct.ASI_CRM_Total_FOB__c;
            totalHandling += ct.ASI_CRM_Total_Handling_Cost__c == null ? 0 : ct.ASI_CRM_Total_Handling_Cost__c;
            totalTotalCOGS += ct.ASI_CRM_Total_COGS__c == null ? 0 : ct.ASI_CRM_Total_COGS__c;
            totalWSOTPerBottle += ct.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c == null ? 0 : ct.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c;

            totalSalesIncentive += ct.ASI_CRM_SG_Sales_Incentive__c == null ? 0 : ct.ASI_CRM_SG_Sales_Incentive__c;
            totalManagementIncentive += ct.ASI_CRM_SG_Management_Incentives__c == null ? 0 : ct.ASI_CRM_SG_Management_Incentives__c;
            totalCSTargetIncentive += ct.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c == null ? 0 : ct.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c;
            totalOthers += ct.ASI_CRM_SG_Others__c == null ? 0 : ct.ASI_CRM_SG_Others__c;
            totalConsumerOffer += ct.ASI_CRM_SG_Consumer_Price_Offer__c == null ? 0 : ct.ASI_CRM_SG_Consumer_Price_Offer__c;
			/* [VL 1.0] BEGIN */
			/*
            totalWSMargin += ct.ASI_CRM_SG_Wholesaler_Margin__c == null ? 0 : ct.ASI_CRM_SG_Wholesaler_Margin__c;
			*/
			if(existBeforeRTM){
				totalWSMargin += ct.ASI_CRM_SG_Wholesaler_Margin__c == null ? 0 : ct.ASI_CRM_SG_Wholesaler_Margin__c;
			} else {
				totalWSMargin += ct.ASI_CRM_Wholesaler_Margin_RTM__c == null ? 0 : ct.ASI_CRM_Wholesaler_Margin_RTM__c;
			}
			/* [VL 1.0] END */
            totalBottleIncentive += ct.ASI_CRM_Bottle_Incentive__c == null ? 0 : ct.ASI_CRM_Bottle_Incentive__c;
            totalBottleIncentiveTotal += ct.ASI_CRM_Bottle_Incentive_Total__c == null ? 0 : ct.ASI_CRM_Bottle_Incentive_Total__c;
            totalGoodsInKind += ct.ASI_CRM_SG_Good_in_Kinds__c == null ? 0 : ct.ASI_CRM_SG_Good_in_Kinds__c;
            totalCash += ct.ASI_CRM_SG_Cash__c == null ? 0 : ct.ASI_CRM_SG_Cash__c;
            totalEventCase += ct.ASI_CRM_SG_Events_Free_Bottles__c == null ? 0 : ct.ASI_CRM_SG_Events_Free_Bottles__c;
            totalEventValue += ct.ASI_CRM_SG_Events__c == null ? 0 : ct.ASI_CRM_SG_Events__c;
            totalSignageCase += ct.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c == null ? 0 : ct.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c;
            totalSignageValue += ct.ASI_CRM_SG_Signages_Advertising_Spot__c == null ? 0 : ct.ASI_CRM_SG_Signages_Advertising_Spot__c;
            totalASCase += ct.ASI_CRM_Advertising_Spot_Free_Bottles__c == null ? 0 : ct.ASI_CRM_Advertising_Spot_Free_Bottles__c;
            totalASValue += ct.ASI_CRM_Advertising_Spot__c == null ? 0 : ct.ASI_CRM_Advertising_Spot__c;
            totalAnniversary += ct.ASI_CRM_SG_Anniversary_Free_Bottles__c == null ? 0 : ct.ASI_CRM_SG_Anniversary_Free_Bottles__c;
            totalTradeIncentive += ct.ASI_CRM_SG_Trade_Incentive_Trips__c == null ? 0 : ct.ASI_CRM_SG_Trade_Incentive_Trips__c;
            totalProductBranding += ct.ASI_CRM_SG_Product_Branding_Display__c == null ? 0 : ct.ASI_CRM_SG_Product_Branding_Display__c;
            totalAdhocMoney += ct.ASI_CRM_SG_Ad_hoc_Promotions__c == null ? 0 : ct.ASI_CRM_SG_Ad_hoc_Promotions__c;
            totalAdhoc += ct.ASI_CRM_SG_Anniversary_Free_Bottles__c == null ? 0 : ct.ASI_CRM_SG_Anniversary_Free_Bottles__c;
            totalAPWSOT += ct.ASI_CRM_SG_Trd_Adv_Promo_Total__c == null ? 0 : ct.ASI_CRM_SG_Trd_Adv_Promo_Total__c;
            totalAPPRSWS += ct.ASI_CRM_SG_Trd_Adv_Promo_TotalPRS__c == null ? 0 : ct.ASI_CRM_SG_Trd_Adv_Promo_TotalPRS__c;
        }
        
        notDisplayFGTab = (totalSalesIncentive + totalManagementIncentive + totalCSTargetIncentive + totalOthers) <= 0;
        notDisplayCMTab = (totalConsumerOffer + totalWSMargin + totalBottleIncentive) <= 0;
        notDisplayCSTab = (totalGoodsInKind + totalCash) <= 0;
        notDisplayAPTab = (totalEventCase + totalEventValue + totalAdhoc) <= 0;
        
        return ctList;
    }
    
    public boolean notDisplayCOTab {get; set;}
    
    public list<ASI_CRM_Contract_Outlets__c> getContractOutlet(){
        list<ASI_CRM_Contract_Outlets__c> coList = [
            SELECT id,
            ASI_CRM_SG_Customer__r.name
            FROM ASI_CRM_Contract_Outlets__c
            WHERE ASI_CRM_SG_Contract__c = :contractId
            AND recordtype.developername = 'ASI_CRM_SG_Contract_Outlet'
        ];
        notDisplayCOTab = coList.size() <= 0;
        return coList;
    }
    
    public void init(){
        totalPackageSize = 0;
        totalSalesCases = 0;
        totalSales9L = 0;
        totalDuty = 0;
        totalFOB = 0;
        totalHandling = 0;
        totalTotalCOGS = 0;
        totalWSOTPerBottle = 0;
        totalSalesIncentive = 0;
        totalManagementIncentive = 0;
        totalCSTargetIncentive = 0;
        totalOthers = 0;
        totalConsumerOffer = 0;
        totalWSMargin = 0;
        totalBottleIncentive = 0;
        totalBottleIncentiveTotal = 0;
        totalGoodsInKind = 0;
        totalCash = 0;
        totalEventCase = 0;
        totalEventValue = 0;
        totalSignageCase = 0;
        totalSignageValue = 0;
        totalASCase = 0;
        totalASValue = 0;
        totalAnniversary = 0;
        totalTradeIncentive = 0;
        totalProductBranding = 0;
        totalAdhoc = 0;
        totalAdhocMoney = 0;
        totalAPWSOT = 0;
        totalAPPRSWS = 0;
        
        notDisplayFGTab = true;
        notDisplayCMTab = true;
        notDisplayCSTab = true;
        notDisplayAPTab = true;
        notDisplayCOTab = true;
        
        getPaymentSchedule();
    }
    
}