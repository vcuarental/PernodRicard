/*
 * *******************************************************************************
 * Name: ASI_CRM_PH_PnLReport_PageCtrl
 * Description: Controller class for ASI_CRM_PH_PnLReport_Page
 * Version History
 * Date             Developer           Comments
 * --------------- -------------------- --------------------------------------------------------------------------------
 * 2018-11-13       Vincent Lam         Created
 */
public class ASI_CRM_PH_PnLReport_PageCtrl {

    public String contractId {get; set;}
    public String customerId {get; set;}
    
    public String customerName {get; set;}
    public String customerMainSector {get; set;}
    public String customerChannel {get; set;}
    public String customerLocalChannel {get; set;}
    public String contractPeriod {get; set;}
    
    public string inputStartDate {get; set;}
    public string inputEndDate {get; set;}

    private final static string TYPE_CONTRACTFUND = 'Contract Fund';
    private final static string TYPE_ACTIVATIONFUND = 'Activation Fund';
    private final static string TYPE_MARKETINGSUPPORTFUND = 'Marketing Support Fund (FOC)';
    private final static string TYPE_MERCHANDISE = 'Merchandise';
    private final static string TYPE_PURCHASEINCENTIVE = 'Purchase Incentive';
    private final static string TYPE_BOTTLEREBATE = 'Bottle Rebate';
    private final static string TYPE_STAFFINCENTIVE = 'Staff Incentive';

    public ASI_CRM_PH_PnLReport_PageCtrl() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        contractId = params.get('contractId');
        customerId = params.get('customerId');
        if(customerId != null){
            init_customer();
        } else {
            init_contract();
        }
    }

    public class PnLDetailWrapper implements Comparable{
        private ASI_TH_CRM_Contract__c c {get;set;}
        private ASI_CRM_ContractTarget__c ct {get;set;}
        private PnLDetailWrapper actual {get;set;}
        
        private string skuId {get;set;}
        private string skuCode {get;set;}
        private string skuDescription {get;set;}
        private string subBrandDescription {get;set;}
        private decimal bottleSize {get;set;}
        private decimal packagingSize {get;set;}

		public Integer compareTo(Object compareTo) {
			PnLDetailWrapper detailW = (PnLDetailWrapper) compareTo;
			if (subBrandDescription == detailW.subBrandDescription) return 0;
			if (subBrandDescription > detailW.subBrandDescription) return 1;
			return -1;        
		}
		
        // for contracted
        private PnLDetailWrapper(ASI_TH_CRM_Contract__c c, ASI_CRM_ContractTarget__c ct) {
            resetNumbers();
            this.c = c;
            this.ct = ct;
            buildHeader();
            calculate_self_contracted();
            this.actual = new PnLDetailWrapper(this);
        }
        // for contracted total
        private PnLDetailWrapper(list<PnLDetailWrapper> list_w) {
            resetNumbers();
            buildHeader_total();
            calculate_fromChild(list_w);
            calculate_self_contracted_total();
            calculate_final_contracted_total();
            
            List<PnLDetailWrapper> list_wChild = new List<PnLDetailWrapper>();
            for(PnLDetailWrapper w : list_w){
                if(w.actual != null) list_wChild.add(w.actual);
            }
            if(list_wChild.size()>0) this.actual = new PnLDetailWrapper(list_wChild);
        }
        // for actual
        private PnLDetailWrapper(PnLDetailWrapper w) {
            resetNumbers();
            perBottle_outletSellingPrice = w.perBottle_outletSellingPrice;
            perBottle_listPrice = w.perBottle_listPrice;
            perBottle_duty = w.perBottle_duty;
            perBottle_handlingCost = w.perBottle_handlingCost;
            perBottle_COGS = w.perBottle_COGS;
            perBottle_standardCost = w.perBottle_standardCost;
			perBottle_distributionCost = w.perBottle_distributionCost;
        }
        private PnLDetailWrapper(ASI_MFM_SKU_Code__c sku) {
            resetNumbers();
            buildHeader(sku);
        }

        private void buildHeader(){
            skuId = ct.ASI_CRM_SKU__c;
            skuCode = ct.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c;
            skuDescription = ct.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c;
            subBrandDescription = ct.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c;
            bottleSize = ct.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c != null ? ct.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c : 0;
            packagingSize = ct.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null ? ct.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
        }
        
        private void buildHeader(ASI_MFM_SKU_Code__c sku){
            skuId = sku.Id;
            skuCode = sku.ASI_MFM_SKU_Code__c;
            skuDescription = sku.ASI_MFM_SKU_Description__c;
            subBrandDescription = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c;
            bottleSize = sku.ASI_HK_CRM_Std_Bottle_Size__c != null ? sku.ASI_HK_CRM_Std_Bottle_Size__c : 0;
            packagingSize = sku.ASI_HK_CRM_Packaging_Size__c != null ? sku.ASI_HK_CRM_Packaging_Size__c : 0;
        }
        
        private void buildHeader_total(){
            skuId = '';
            skuCode = 'Total';
            skuDescription = '';
			subBrandDescription = '';
            bottleSize = 0;
            packagingSize = 0;
        }
        
        private void calculate_self_contracted(){
            totalBottle = ct.ASI_CRM_Target_Total_Bottle__c != null ? ct.ASI_CRM_Target_Total_Bottle__c : 0;
            
            perBottle_outletSellingPrice = ct.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? ct.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
            perBottle_listPrice = ct.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c != null ? ct.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c : 0;
            perBottle_duty = ct.ASI_CRM_Duty_Per_Bottle__c != null ? ct.ASI_CRM_Duty_Per_Bottle__c : 0;
            perBottle_handlingCost = ct.ASI_CRM_Handling_Cost_Per_Bottle__c != null ? ct.ASI_CRM_Handling_Cost_Per_Bottle__c : 0;
            perBottle_COGS = ct.ASI_CRM_IGC__c != null ? ct.ASI_CRM_IGC__c : 0;
            perBottle_standardCost = ct.ASI_CRM_Standard_Cost_per_Bottle__c != null ? ct.ASI_CRM_Standard_Cost_per_Bottle__c : 0;
			perBottle_distributionCost = ct.ASI_CRM_DistributionCostperBottleFinal__c != null ? ct.ASI_CRM_DistributionCostperBottleFinal__c : 0;
            weight = ct.ASI_CRM_Weight_by_Outlet_Sales_Revenue__c != null ? ct.ASI_CRM_Weight_by_Outlet_Sales_Revenue__c / 100 : 0;
            decimal bottleRebatePerBottle = ct.ASI_CRM_Bottle_Rebate__c != null ? ct.ASI_CRM_Bottle_Rebate__c : 0;
            decimal staffIncentivePerBottle = ct.ASI_CRM_Staff_Incentive__c != null ? ct.ASI_CRM_Staff_Incentive__c : 0;
            
            decimal totalContractFund = c.ASI_CRM_Contract_Fund_Amount__c != null ? c.ASI_CRM_Contract_Fund_Amount__c : 0;
            decimal totalMarketingSupportFund = c.ASI_CRM_Marketing_Support_Fund_Amount__c != null ? c.ASI_CRM_Marketing_Support_Fund_Amount__c : 0;
            decimal totalActivationFund = c.ASI_CRM_Activation_Fund_Amount__c != null ? c.ASI_CRM_Activation_Fund_Amount__c : 0;
            decimal totalMerchandise = c.ASI_CRM_Merchandise_Amount__c != null ? c.ASI_CRM_Merchandise_Amount__c : 0;
            decimal totalPurchaseIncentive = c.ASI_CRM_Purchase_Incentive_Amount__c != null ? c.ASI_CRM_Purchase_Incentive_Amount__c : 0;
            decimal totalStaffIncentive = c.ASI_CRM_Staff_Incentive_Amount__c != null ? c.ASI_CRM_Staff_Incentive_Amount__c : 0;
            decimal totalBottleRebate = c.ASI_CRM_Bottle_Rebate_Amount__c != null ? c.ASI_CRM_Bottle_Rebate_Amount__c : 0;
            
            listPrice = perBottle_listPrice;
            grossSales = listPrice * totalBottle;
            
            AnDFOC = 0;
            purchaseIncentive = (-1) * totalPurchaseIncentive * weight;
            bottleRebate = (-1) * bottleRebatePerBottle * totalBottle;
            staffIncentive = (-1) * staffIncentivePerBottle * totalBottle;
            totalAnD = AnDFOC + purchaseIncentive + bottleRebate + staffIncentive;
            
            netSales = grossSales + totalAnD;
            
            COGS = (-1) * perBottle_COGS * totalBottle;
            standardCost = (-1) * perBottle_standardCost * totalBottle;
            dutyAndTax = (-1) * perBottle_duty * totalBottle;
            handlingCost = (-1) * perBottle_handlingCost * totalBottle;
            
            grossMarginST = netSales + standardCost + dutyAndTax + handlingCost;
            
            mfmFOC = 0;
            contractFund = (-1) * totalContractFund * weight;
            activationFund = (-1) * totalActivationFund * weight;
            merchandise = (-1) * totalMerchandise * weight;
            marketingSupportFund = (-1) * totalMarketingSupportFund * weight;
            distributionCost = (-1) * perBottle_distributionCost * totalBottle;
            
			totalAnP = mfmFOC + contractFund + activationFund + merchandise + marketingSupportFund;
			
            //contributionMarginST = grossMarginST + mfmFOC + contractFund + activationFund + merchandise + marketingSupportFund;
            contributionMarginST = grossMarginST + distributionCost;
			caapST = contributionMarginST + totalAnP;
            
            grossMarginLocal = netSales + COGS + dutyAndTax + handlingCost;
            //contributionMarginLocal = grossMarginLocal + mfmFOC + contractFund + activationFund + merchandise + marketingSupportFund;
            contributionMarginLocal = grossMarginLocal + distributionCost;
			caapLocal = contributionMarginLocal + totalAnP;
            
            totalFixedCost = purchaseIncentive + bottleRebate + staffIncentive + contractFund + activationFund + merchandise + marketingSupportFund;
            
            totalInvestment = purchaseIncentive + bottleRebate + staffIncentive + contractFund + activationFund + merchandise + marketingSupportFund;
            profitOrLossST = contributionMarginST + totalInvestment;
            investmentPercentOverCMST = contributionMarginST != 0 ? (-1) * totalInvestment / contributionMarginST : 0;
            profitOrLossLocal = contributionMarginLocal + totalInvestment;
            investmentPercentOverCMLocal = contributionMarginLocal != 0 ? (-1) * totalInvestment / contributionMarginLocal : 0;
        }
        
        private void calculate_self_contracted_total(){
            averageCMperBottle = totalBottle != 0 ? contributionMarginST / totalBottle : 0;
            totalUnitsToBreakeven = averageCMperBottle != 0 ? (-1) * totalFixedCost / averageCMperBottle : 0;
        }
        
        private void calculate_final_contracted(PnLDetailWrapper w_total){
            productMixRatio = w_total.totalBottle != 0 ? totalBottle / w_total.totalBottle : 0;
            idealMix = productMixRatio * w_total.totalUnitsToBreakeven;
            idealGrossSales = idealMix * listPrice;
        }
        
        private void calculate_final_contracted_total(){
            productMixRatio = 1;
            idealMix = totalUnitsToBreakeven;
            investmentPercentOverCMST = contributionMarginST != 0 ? (-1) * (-1) * totalInvestment / contributionMarginST : 0;
            investmentPercentOverCMLocal = contributionMarginLocal != 0 ? (-1) * (-1) * totalInvestment / contributionMarginLocal : 0;
        }
        
        private void calculateOfftake(aggregateResult ar){
            totalBottle = (decimal)ar.get('qty') != null ? (decimal)ar.get('qty') : 0;
        }
        
        private void calculateOfftakeWithPriceCost(aggregateResult ar){
            totalBottle = (decimal)ar.get('qty') != null ? (decimal)ar.get('qty') : 0;
            perBottle_outletSellingPrice = (decimal)ar.get('outletSellingPrice') != null ? (decimal)ar.get('outletSellingPrice') : 0;
            perBottle_listPrice = (decimal)ar.get('listPrice') != null ? (decimal)ar.get('listPrice') : 0;
            perBottle_duty = (decimal)ar.get('duty') != null ? (decimal)ar.get('duty') : 0;
            perBottle_handlingCost = (decimal)ar.get('handlingCost') != null ? (decimal)ar.get('handlingCost') : 0;
            perBottle_COGS = (decimal)ar.get('cogs') != null ? (decimal)ar.get('cogs') : 0;
            perBottle_standardCost = (decimal)ar.get('standardCost') != null ? (decimal)ar.get('standardCost') : 0;
            perBottle_distributionCost = (decimal)ar.get('distributionCost') != null ? (decimal)ar.get('distributionCost') : 0;
        }
        
        private void calculatePayment(list<aggregateResult> list_ar){
            for(aggregateResult ar : list_ar){
                string type = string.valueOf(ar.get('type'));
                decimal amount = (Decimal)ar.get('amount') != null ? (decimal)ar.get('amount') : 0;
                if(type == TYPE_CONTRACTFUND){
                    contractFund -= amount;
                } else
                if(type == TYPE_ACTIVATIONFUND){
                    activationFund -= amount;
                } else
                if(type == TYPE_MERCHANDISE){
                    merchandise -= amount;
                } else
                if(type == TYPE_PURCHASEINCENTIVE){
                    purchaseIncentive -= amount;
                } else
                if(type == TYPE_BOTTLEREBATE){
                    bottleRebate -= amount;
                } else
                if(type == TYPE_STAFFINCENTIVE){
                    staffIncentive -= amount;
                } 
            }
        }
        
        private void calculateFOC(list<aggregateResult> list_ar){
            for(aggregateResult ar : list_ar){
                string type = string.valueOf(ar.get('type'));
                decimal amount = (Decimal)ar.get('amount') != null ? (decimal)ar.get('amount') : 0;
                if(type == TYPE_MARKETINGSUPPORTFUND){
                    marketingSupportFund -= amount;
                } else
                if(type == TYPE_MERCHANDISE){
                    merchandise -= amount;
                } else {
					mfmFOC -= amount;
				}
            }
        }
        
        private void calculate_self_actual(){
            listPrice = perBottle_listPrice;
            grossSales = listPrice * totalBottle;
            
            totalAnD = AnDFOC + purchaseIncentive + bottleRebate + staffIncentive;
            
            netSales = grossSales + totalAnD;
            
            COGS = (-1) * perBottle_COGS * totalBottle;
            standardCost = (-1) * perBottle_standardCost * totalBottle;
            dutyAndTax = (-1) * perBottle_duty * totalBottle;
            handlingCost = (-1) * perBottle_handlingCost * totalBottle;
			distributionCost = (-1) * perBottle_distributionCost * totalBottle;
            
            grossMarginST = netSales + standardCost + dutyAndTax + handlingCost;
            
			totalAnP = mfmFOC + contractFund + activationFund + merchandise + marketingSupportFund;
			
            //contributionMarginST = grossMarginST + mfmFOC + contractFund + activationFund + merchandise + marketingSupportFund;
            contributionMarginST = grossMarginST + distributionCost;
			caapST = contributionMarginST + totalAnP;
            
            grossMarginLocal = netSales + COGS + dutyAndTax + handlingCost;
            //contributionMarginLocal = grossMarginLocal + mfmFOC + contractFund + activationFund + merchandise + marketingSupportFund;
            contributionMarginLocal = grossMarginLocal + distributionCost;
			caapLocal = contributionMarginLocal + totalAnP;
            
            totalFixedCost = purchaseIncentive + bottleRebate + staffIncentive + contractFund + activationFund + merchandise + marketingSupportFund;
            
            totalInvestment = purchaseIncentive + bottleRebate + staffIncentive + contractFund + activationFund + merchandise + marketingSupportFund;
            profitOrLossST = contributionMarginST + totalInvestment;
            investmentPercentOverCMST = contributionMarginST != 0 ? (-1) * (-1) * totalInvestment / contributionMarginST : 0;
            profitOrLossLocal = contributionMarginLocal + totalInvestment;
            investmentPercentOverCMLocal = contributionMarginLocal != 0 ? (-1) * (-1) * totalInvestment / contributionMarginLocal : 0;
        }
        
        private decimal weight {get; set;}
        private decimal perBottle_outletSellingPrice {get; set;}
        private decimal perBottle_listPrice {get; set;}
        private decimal perBottle_duty {get; set;}
        private decimal perBottle_handlingCost {get; set;}
        private decimal perBottle_COGS {get; set;}
        private decimal perBottle_standardCost {get; set;}
        private decimal perBottle_distributionCost {get; set;}
        private decimal totalBottle {get; set;}
        private decimal listPrice {get; set;}
        private decimal grossSales {get; set;}
        private decimal totalAnD {get; set;}
        private decimal AnDFOC {get; set;}
        private decimal purchaseIncentive {get; set;}
        private decimal bottleRebate {get; set;}
        private decimal staffIncentive {get; set;}
        private decimal netSales {get; set;}
        private decimal COGS {get; set;}
        private decimal standardCost {get; set;}
        private decimal dutyAndTax {get; set;}
        private decimal handlingCost {get; set;}
        private decimal grossMarginST {get; set;}
        private decimal activationFund {get; set;}
        private decimal mfmFOC {get; set;}
        private decimal contractFund {get; set;}
        private decimal merchandise {get; set;}
        private decimal marketingSupportFund {get; set;}
        private decimal distributionCost {get; set;}
        private decimal totalAnP {get; set;}
        private decimal contributionMarginST {get; set;}
        private decimal caapST {get; set;}
        private decimal grossMarginLocal {get; set;}
        private decimal contributionMarginLocal {get; set;}
        private decimal caapLocal {get; set;}
        private decimal averageCMperBottle {get; set;}
        private decimal totalFixedCost {get; set;}
        private decimal totalUnitsToBreakeven {get; set;}
        private decimal productMixRatio {get; set;}
        private decimal idealMix {get; set;}
        private decimal idealGrossSales {get; set;}
        private decimal totalInvestment {get; set;}
        private decimal profitOrLossST {get; set;}
        private decimal investmentPercentOverCMST {get; set;}
        private decimal profitOrLossLocal {get; set;}
        private decimal investmentPercentOverCMLocal {get; set;}


        private void resetNumbers() {
            perBottle_outletSellingPrice = 0;
            perBottle_listPrice = 0;
            perBottle_duty = 0;
            perBottle_handlingCost = 0;
            perBottle_COGS = 0;
            perBottle_standardCost = 0;
			perBottle_distributionCost = 0;
            totalBottle = 0;
            listPrice = 0;
            grossSales = 0;
            totalAnD = 0;
            AnDFOC = 0;
            purchaseIncentive = 0;
            bottleRebate = 0;
            staffIncentive = 0;
            netSales = 0;
            COGS = 0;
            standardCost = 0;
			distributionCost = 0;
            dutyAndTax = 0;
            handlingCost = 0;
            grossMarginST = 0;
            activationFund = 0;
            mfmFOC = 0;
            contractFund = 0;
            merchandise = 0;
            marketingSupportFund = 0;
			totalAnP = 0;
            contributionMarginST = 0;
            grossMarginLocal = 0;
            contributionMarginLocal = 0;
			caapST = 0;
			caapLocal = 0;
            averageCMperBottle = 0;
            totalFixedCost = 0;
            totalUnitsToBreakeven = 0;
            productMixRatio = 0;
            idealMix = 0;
            idealGrossSales = 0;
            totalInvestment = 0;
            profitOrLossST = 0;
            investmentPercentOverCMST = 0;
            profitOrLossLocal = 0;
            investmentPercentOverCMLocal = 0;

        }

        private void calculate_fromChild(list<PnLDetailWrapper> list_w) {

            for (PnLDetailWrapper w : list_w) {
                totalBottle += w.totalBottle;
                listPrice += w.listPrice;
                grossSales += w.grossSales;
                totalAnD += w.totalAnD;
                AnDFOC += w.AnDFOC;
                purchaseIncentive += w.purchaseIncentive;
                bottleRebate += w.bottleRebate;
                staffIncentive += w.staffIncentive;
                netSales += w.netSales;
                COGS += w.COGS;
                standardCost += w.standardCost;
				distributionCost += w.distributionCost;
                dutyAndTax += w.dutyAndTax;
                handlingCost += w.handlingCost;
                grossMarginST += w.grossMarginST;
                activationFund += w.activationFund;
                mfmFOC += w.mfmFOC;
                contractFund += w.contractFund;
                merchandise += w.merchandise;
                marketingSupportFund += w.marketingSupportFund;
                contributionMarginST += w.contributionMarginST;
                grossMarginLocal += w.grossMarginLocal;
                contributionMarginLocal += w.contributionMarginLocal;
                totalAnP += w.totalAnP;
                caapST += w.caapST;
                caapLocal += w.caapLocal;
                averageCMperBottle += w.averageCMperBottle;
                totalFixedCost += w.totalFixedCost;
                totalUnitsToBreakeven += w.totalUnitsToBreakeven;
                productMixRatio += w.productMixRatio;
                idealMix += w.idealMix;
                idealGrossSales += w.idealGrossSales;
                totalInvestment += w.totalInvestment;
                profitOrLossST += w.profitOrLossST;
                investmentPercentOverCMST += w.investmentPercentOverCMST;
                profitOrLossLocal += w.profitOrLossLocal;
                investmentPercentOverCMLocal += w.investmentPercentOverCMLocal;

            }
            
        }

        private void calculate_fromChild_idealGrossSales(list<PnLDetailWrapper> list_w) {

            for (PnLDetailWrapper w : list_w) {
                idealGrossSales += w.idealGrossSales;
            }
            
        }

        private void roundToZero() {
            if(totalBottle != null) totalBottle = totalBottle.setScale(0);
            if(listPrice != null) listPrice = listPrice.setScale(0);
            if(grossSales != null) grossSales = grossSales.setScale(0);
            if(totalAnD != null) totalAnD = totalAnD.setScale(0);
            if(AnDFOC != null) AnDFOC = AnDFOC.setScale(0);
            if(purchaseIncentive != null) purchaseIncentive = purchaseIncentive.setScale(0);
            if(bottleRebate != null) bottleRebate = bottleRebate.setScale(0);
            if(staffIncentive != null) staffIncentive = staffIncentive.setScale(0);
            if(netSales != null) netSales = netSales.setScale(0);
            if(COGS != null) COGS = COGS.setScale(0);
            if(standardCost != null) standardCost = standardCost.setScale(0);
            if(distributionCost != null) distributionCost = distributionCost.setScale(0);
            if(dutyAndTax != null) dutyAndTax = dutyAndTax.setScale(0);
            if(handlingCost != null) handlingCost = handlingCost.setScale(0);
            if(grossMarginST != null) grossMarginST = grossMarginST.setScale(0);
            if(activationFund != null) activationFund = activationFund.setScale(0);
            if(mfmFOC != null) mfmFOC = mfmFOC.setScale(0);
            if(contractFund != null) contractFund = contractFund.setScale(0);
            if(merchandise != null) merchandise = merchandise.setScale(0);
            if(marketingSupportFund != null) marketingSupportFund = marketingSupportFund.setScale(0);
            if(contributionMarginST != null) contributionMarginST = contributionMarginST.setScale(0);
            if(grossMarginLocal != null) grossMarginLocal = grossMarginLocal.setScale(0);
            if(contributionMarginLocal != null) contributionMarginLocal = contributionMarginLocal.setScale(0);
            if(totalAnP != null) totalAnP = totalAnP.setScale(0);
            if(caapST != null) caapST = caapST.setScale(0);
            if(caapLocal != null) caapLocal = caapLocal.setScale(0);
            if(averageCMperBottle != null) averageCMperBottle = averageCMperBottle.setScale(0);
            if(totalFixedCost != null) totalFixedCost = totalFixedCost.setScale(0);
            if(totalUnitsToBreakeven != null) totalUnitsToBreakeven = totalUnitsToBreakeven.setScale(0);
            if(productMixRatio != null) {
                productMixRatio = productMixRatio * 100;
                productMixRatio = productMixRatio.setScale(0);
            }
            if(idealMix != null) idealMix = idealMix.setScale(0);
            if(idealGrossSales != null) idealGrossSales = idealGrossSales.setScale(0);
            if(totalInvestment != null) totalInvestment = totalInvestment.setScale(0);
            if(profitOrLossST != null) profitOrLossST = profitOrLossST.setScale(0);
            if(investmentPercentOverCMST != null) {
                investmentPercentOverCMST = investmentPercentOverCMST * 100;
                investmentPercentOverCMST = investmentPercentOverCMST.setScale(0);
            }
            if(profitOrLossLocal != null) profitOrLossLocal = profitOrLossLocal.setScale(0);
            if(investmentPercentOverCMLocal != null) {
                investmentPercentOverCMLocal = investmentPercentOverCMLocal * 100;
                investmentPercentOverCMLocal = investmentPercentOverCMLocal.setScale(0);
            }

        }
    }

    //JSON String for VF Page
    public String list_wrapper_detailPnL_json {
        get {return toJsonString(list_wrapper_detailPnL);}
    }
    public String list_wrapper_summary_json {
        get {return toJsonString(list_wrapper_summary);}
    }

    //All contract records
    public transient List<PnLDetailWrapper> list_wrapper_detailPnL;
    public transient List<PnLDetailWrapper> list_wrapper_summary;


    //Execute the logic when contract id is setted by component
    public Boolean init_contract() {

        list_wrapper_detailPnL = new List<PnLDetailWrapper>();
        list_wrapper_summary = new List<PnLDetailWrapper>();        

        ASI_TH_CRM_Contract__c contract = retrieveContract(contractId);
        System.debug(contractId);
        System.debug(contract);
        customerName = contract.ASI_CRM_CN_Outlet_WS__r.Name;
        customerMainSector = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Main_Sector__c;
        customerChannel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_VN_Channel__c;
        customerLocalChannel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Local_Channel__c;
        contractPeriod = formatDate(contract.ASI_TH_CRM_Start_Date__c) + ' ~ ' + formatDate(contract.ASI_TH_CRM_End_Date__c);
        
        map<string, aggregateResult> map_skuId_offtake = retrieveOfftake(contract.ASI_CRM_CN_Outlet_WS__c, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c);
        map<string, list<aggregateResult>> map_skuId_payment = retrievePayment(contract.Id);
        map<string, list<aggregateResult>> map_skuId_foc = retrieveFOC(contract.Id);
        
        for(ASI_TH_CRM_Contract__c c : retrieveContractWithChildList(contractId)){
            for(ASI_CRM_ContractTarget__c ct : c.Contract_Target__r){
                PnLDetailWrapper w = new PnLDetailWrapper(c, ct);
                
                // to calculate actual
                string skuId = ct.ASI_CRM_SKU__c;
                if(map_skuId_offtake.containsKey(skuId)){
                    w.actual.calculateOfftake(map_skuId_offtake.get(skuId));
                    map_skuId_offtake.remove(skuId);
                }
                if(map_skuId_payment.containsKey(skuId)){
                    w.actual.calculatePayment(map_skuId_payment.get(skuId));
                    map_skuId_payment.remove(skuId);
                }
                if(map_skuId_foc.containsKey(skuId)){
                    w.actual.calculateFOC(map_skuId_foc.get(skuId));
                    map_skuId_foc.remove(skuId);
                }
                w.actual.calculate_self_actual();
                
                list_wrapper_detailPnL.add(w);
            }
        }
		
		// append rest of offtake to report
		if(map_skuId_offtake != null && map_skuId_offtake.keySet().size()>0){
			for(ASI_MFM_SKU_Code__c sku : retrieveSKU(map_skuId_offtake.keySet())){
                PnLDetailWrapper w = new PnLDetailWrapper(sku);
				w.actual = new PnLDetailWrapper(w);
                
                // to calculate actual
                string skuId = sku.Id;
                if(map_skuId_offtake.containsKey(skuId)){
                    w.actual.calculateOfftakeWithPriceCost(map_skuId_offtake.get(skuId));
                    map_skuId_offtake.remove(skuId);
                }
                if(map_skuId_payment.containsKey(skuId)){
                    w.actual.calculatePayment(map_skuId_payment.get(skuId));
                    map_skuId_payment.remove(skuId);
                }
                if(map_skuId_foc.containsKey(skuId)){
                    w.actual.calculateFOC(map_skuId_foc.get(skuId));
                    map_skuId_foc.remove(skuId);
                }
                w.actual.calculate_self_actual();
                
                list_wrapper_detailPnL.add(w);
            }
		}
        // append remaining payment SKU to report
		if(map_skuId_payment != null && map_skuId_payment.keySet().size()>0){
			for(ASI_MFM_SKU_Code__c sku : retrieveSKU(map_skuId_payment.keySet())){
                PnLDetailWrapper w = new PnLDetailWrapper(sku);
				w.actual = new PnLDetailWrapper(w);
                
                // to calculate actual
                string skuId = sku.Id;
                if(map_skuId_payment.containsKey(skuId)){
                    w.actual.calculatePayment(map_skuId_payment.get(skuId));
                    map_skuId_payment.remove(skuId);
                }
                if(map_skuId_foc.containsKey(skuId)){
                    w.actual.calculateFOC(map_skuId_foc.get(skuId));
                    map_skuId_foc.remove(skuId);
                }
                w.actual.calculate_self_actual();
                
                list_wrapper_detailPnL.add(w);
            }
		}
        // append remaining FOC SKU to report
		if(map_skuId_foc != null && map_skuId_foc.keySet().size()>0){
			for(ASI_MFM_SKU_Code__c sku : retrieveSKU(map_skuId_foc.keySet())){
                PnLDetailWrapper w = new PnLDetailWrapper(sku);
				w.actual = new PnLDetailWrapper(w);
                
                // to calculate actual
                string skuId = sku.Id;
                if(map_skuId_foc.containsKey(skuId)){
                    w.actual.calculateFOC(map_skuId_foc.get(skuId));
                    map_skuId_foc.remove(skuId);
                }
                w.actual.calculate_self_actual();
                
                list_wrapper_detailPnL.add(w);
            }
		}
        
        list<PnLDetailWrapper> list_wChild = new list<PnLDetailWrapper>();
        PnLDetailWrapper w_total = new PnLDetailWrapper(list_wrapper_detailPnL);
        for(PnLDetailWrapper w : list_wrapper_detailPnL){
            w.calculate_final_contracted(w_total);
            w.roundToZero();
            list_wChild.add(w.actual);
            // actual
            w.actual.calculate_final_contracted(w_total.actual);
            w.actual.roundToZero();
        }
        w_total.calculate_fromChild_idealGrossSales(list_wrapper_detailPnL);
        w_total.roundToZero();
        // actual
        w_total.actual.calculate_fromChild_idealGrossSales(list_wChild);
        w_total.actual.roundToZero();
        
		list_wrapper_detailPnL.sort();
		
        list_wrapper_detailPnL.add(w_total);
        list_wrapper_summary.add(w_total);

        return true;
    }
    
    public Boolean init_customer() {

        ASI_CRM_AccountsAdditionalField__c customer = retrieveCustomer(customerId);
        customerName = customer.Name;
        customerMainSector = customer.ASI_CRM_SG_Main_Sector__c;
        customerChannel = customer.ASI_CRM_VN_Channel__c;
        customerLocalChannel = customer.ASI_CRM_SG_Local_Channel__c;
        
        date endDate = system.today();
        date startDate = endDate.addYears(-1);
        inputEndDate = formatDate(endDate);
        inputStartDate = formatDate(startDate);
        
        getPnL(startDate, endDate);

        return true;
    }
    
    public void getPnL(date startDate, date endDate){
        
        list_wrapper_detailPnL = new List<PnLDetailWrapper>();
        list_wrapper_summary = new List<PnLDetailWrapper>();        

        map<string, aggregateResult> map_skuId_offtake = retrieveOfftake(customerId, startDate, endDate);
        map<string, list<aggregateResult>> map_skuId_payment = retrievePayment(customerId, startDate, endDate);
        map<string, list<aggregateResult>> map_skuId_foc = retrieveFOC(customerId, startDate, endDate);
        
        if(map_skuId_offtake.values().size()>0){
            for(ASI_MFM_SKU_Code__c sku : retrieveSKU(map_skuId_offtake.keySet())){
                PnLDetailWrapper w = new PnLDetailWrapper(sku);
                
                // to calculate actual
                string skuId = sku.Id;
                if(map_skuId_offtake.containsKey(skuId)){
                    w.calculateOfftakeWithPriceCost(map_skuId_offtake.get(skuId));
                    map_skuId_offtake.remove(skuId);
                }
                if(map_skuId_payment.containsKey(skuId)){
                    w.calculatePayment(map_skuId_payment.get(skuId));
                    map_skuId_payment.remove(skuId);
                }
                if(map_skuId_foc.containsKey(skuId)){
                    w.calculateFOC(map_skuId_foc.get(skuId));
                    map_skuId_foc.remove(skuId);
                }
                w.calculate_self_actual();
                
                list_wrapper_detailPnL.add(w);
            }
            
			// append remaining payment SKU to report
			if(map_skuId_payment != null && map_skuId_payment.keySet().size()>0){
				for(ASI_MFM_SKU_Code__c sku : retrieveSKU(map_skuId_payment.keySet())){
					PnLDetailWrapper w = new PnLDetailWrapper(sku);
					
					// to calculate actual
					string skuId = sku.Id;
					if(map_skuId_payment.containsKey(skuId)){
						w.calculatePayment(map_skuId_payment.get(skuId));
						map_skuId_payment.remove(skuId);
					}
					if(map_skuId_foc.containsKey(skuId)){
						w.calculateFOC(map_skuId_foc.get(skuId));
						map_skuId_foc.remove(skuId);
					}
					w.calculate_self_actual();
					
					list_wrapper_detailPnL.add(w);
				}
			}
			// append remaining FOC SKU to report
			if(map_skuId_foc != null && map_skuId_foc.keySet().size()>0){
				for(ASI_MFM_SKU_Code__c sku : retrieveSKU(map_skuId_foc.keySet())){
					PnLDetailWrapper w = new PnLDetailWrapper(sku);
					
					// to calculate actual
					string skuId = sku.Id;
					if(map_skuId_foc.containsKey(skuId)){
						w.calculateFOC(map_skuId_foc.get(skuId));
						map_skuId_foc.remove(skuId);
					}
					w.calculate_self_actual();
					
					list_wrapper_detailPnL.add(w);
				}
			}
			
            PnLDetailWrapper w_total = new PnLDetailWrapper(list_wrapper_detailPnL);
            for(PnLDetailWrapper w : list_wrapper_detailPnL){
                w.calculate_final_contracted(w_total);
                w.roundToZero();
            }
            w_total.calculate_fromChild_idealGrossSales(list_wrapper_detailPnL);
            w_total.roundToZero();
            
			list_wrapper_detailPnL.sort();
		
            list_wrapper_detailPnL.add(w_total);
            list_wrapper_summary.add(w_total);
        }
        
        
    }
    
    public void getPnLFromVF() {
        //Retrieve data from VF Page
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Date startDate = Date.valueOf(params.get('startDate'));
        Date endDate = Date.valueOf(params.get('endDate'));
        
        getPnL(startDate, endDate);
    }

    /*
     * *************
     * Data Retrievement Function
     * *************
     */
    private final static list<string> CUSTOMER_FIELD_LIST_SIMPLE = new list<string>{
        'Name',
        'ASI_CRM_SG_Main_Sector__c',
        'ASI_CRM_VN_Channel__c',
        'ASI_CRM_SG_Local_Channel__c'
    };

    private final static list<string> CONTRACT_FIELD_LIST_SIMPLE = new list<string>{
        'Name',
        'ASI_CRM_CN_Outlet_WS__c',
        'ASI_CRM_CN_Outlet_WS__r.Name',
        'ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Main_Sector__c',
        'ASI_CRM_CN_Outlet_WS__r.ASI_CRM_VN_Channel__c',
        'ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Local_Channel__c',
        'ASI_TH_CRM_Start_Date__c',
        'ASI_TH_CRM_End_Date__c',
        'ASI_CRM_Contract_Fund_Amount__c',
        'ASI_CRM_Marketing_Support_Fund_Amount__c',
        'ASI_CRM_Activation_Fund_Amount__c',
        'ASI_CRM_Merchandise_Amount__c',
        'ASI_CRM_Purchase_Incentive_Amount__c',
        'ASI_CRM_Staff_Incentive_Amount__c',
        'ASI_CRM_Bottle_Rebate_Amount__c'
    };

    private final static List<String> MECHANICS_FIELD_LIST = new List<string>{
        'id', 
        'ASI_CRM_Contract__c',
        'ASI_CRM_Target_Total_Bottle__c',
        'ASI_CRM_Bottle_Rebate__c',
        'ASI_CRM_Staff_Incentive__c',
        'ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c',
        'ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c',
        'ASI_CRM_Duty_Per_Bottle__c',
        'ASI_CRM_Handling_Cost_Per_Bottle__c',
        'ASI_CRM_IGC__c',
        'ASI_CRM_Standard_Cost_per_Bottle__c',
		'ASI_CRM_DistributionCostperBottleFinal__c',
        'ASI_CRM_Weight_by_Outlet_Sales_Revenue__c',
        'ASI_CRM_SKU__c',
        'ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c',
        'ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c',
		'ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c',
        'ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c',
        'ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c',
        'ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name'
    };

    private final static List<String> PAYMENTREQUESTLINE_FIELD_LIST = new List<string>{
        'id', 
        'ASI_CRM_Amount_Number__c',
        'ASI_CRM_SKU__c',
        'ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c',
        'ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__c',
        'ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c'
    };

    private final static List<String> SKU_FIELD_LIST = new List<string>{
        'ASI_MFM_SKU_Code__c',
        'ASI_MFM_SKU_Description__c',
		'ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c',
        'ASI_HK_CRM_Std_Bottle_Size__c',
        'ASI_HK_CRM_Packaging_Size__c',
        'ASI_MFM_Sub_brand__r.Name'
    };

    private final static string REJECTED = 'Rejected';
    private final static string RTID_CONTRACTTARGET = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target');
    private final static string RTID_ACTUALOFFTAKE = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_PH_Actual_Offtake');
    private final static string RTID_PAYMENTREQUESTLINE = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_PH_Payment_Request_Detail');
    private final static string RTID_FOCLINE = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item');

    private list<ASI_MFM_SKU_Code__c> retrieveSKU(set<string> list_skuId) {
        String query = 'SELECT ' + genQueryFieldFromList(SKU_FIELD_LIST) +
                ', RecordType.DeveloperName ' +
                'FROM ASI_MFM_SKU_Code__c ' +
                'WHERE Id in : list_skuId ';

        List<ASI_MFM_SKU_Code__c> skuList = (List<ASI_MFM_SKU_Code__c>) Database.query(query);
        return skuList.size() > 0 ? skuList : null;
    }

    private ASI_TH_CRM_Contract__c retrieveContract(string contractId) {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) +
                ', RecordType.DeveloperName ' +
                'FROM ASI_TH_CRM_Contract__c ' +
                'WHERE Id = : contractId ';

        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
        return contractList.size() > 0 ? contractList[0] : null;
    }

    private list<ASI_TH_CRM_Contract__c> retrieveContractWithChildList(string contractId) {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) +
                ', RecordType.DeveloperName, ' +
            //Retrieve Actual Offtake
                '(SELECT ' + genQueryFieldFromList(MECHANICS_FIELD_LIST) +
                ' FROM Contract_Target__r where recordtypeid = :RTID_CONTRACTTARGET  ' +
                ' Order by ASI_CRM_SKU__r.Name' + 
                ') ' + 
                'FROM ASI_TH_CRM_Contract__c ' +
                'WHERE Id = : contractId ';

        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
        return contractList.size() > 0 ? contractList : null;
    }

    private ASI_CRM_AccountsAdditionalField__c retrieveCustomer(string customerId) {
        String query = 'SELECT ' + genQueryFieldFromList(CUSTOMER_FIELD_LIST_SIMPLE) +
                ', RecordType.DeveloperName ' +
                'FROM ASI_CRM_AccountsAdditionalField__c ' +
                'WHERE Id = : customerId ';

        List<ASI_CRM_AccountsAdditionalField__c> contractList = (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
        return contractList.size() > 0 ? contractList[0] : null;
    }

    private map<string, AggregateResult> retrieveOfftake(string customerId, date startDate, date endDate) {
        map<string, AggregateResult> map_ar = new map<string, AggregateResult>();
        for(AggregateResult ar : [
            select
                sum(ASI_TH_CRM_Quantity__c) qty,
                avg(ASI_CRM_Outlet_Selling_Price__c ) outletSellingPrice,
                avg(ASI_CRM_List_Price__c  ) listPrice,
                avg(ASI_CRM_Duty_Cost__c  ) duty,
                avg(ASI_CRM_Handling_Cost__c  ) handlingCost,
                avg(ASI_CRM_Cost_of_Sales__c  ) cogs,
                avg(ASI_CRM_Standard_Cost__c  ) standardCost,
                avg(ASI_CRM_Distribution_Cost_Final__c  ) distributionCost,
                ASI_CRM_SKU__c skuId
            from 
                ASI_TH_CRM_Actual_Offtake__c
            where
                recordtypeid = :RTID_ACTUALOFFTAKE
                and ASI_CRM_SG_Customer__c = :customerId
                and ASI_TH_CRM_Offtake_G_L_Date__c >= :startDate
                and ASI_TH_CRM_Offtake_G_L_Date__c <= :endDate
            group by
                ASI_CRM_SKU__c
        ]){
            string skuId = string.valueOf(ar.get('skuId'));
            map_ar.put(skuId, ar);
        }
		system.debug(map_ar);
        return map_ar;
    }

    private map<string, list<AggregateResult>> retrievePayment(string contractId) {
        map<string, list<AggregateResult>> map_ar = new map<string, list<AggregateResult>>();
        for(AggregateResult ar : [
            select
                sum(ASI_CRM_Amount_Number__c) amount,
                ASI_CRM_SKU__c skuId,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c type
            from 
                ASI_TH_CRM_PaymentRequestLineItem__c
            where
                recordtypeid = :RTID_PAYMENTREQUESTLINE
                and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contractId
                and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c <> :REJECTED
            group by
                ASI_CRM_SKU__c,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c
        ]){
            string skuId = string.valueOf(ar.get('skuId'));
            list<aggregateResult> list_ar = map_ar.containsKey(skuId) ? map_ar.get(skuId) : new list<aggregateResult>();
            list_ar.add(ar);
            map_ar.put(skuId, list_ar);
        }
        return map_ar;
    }

    private map<string, list<AggregateResult>> retrievePayment(string customerId, date startDate, date endDate) {
        map<string, list<AggregateResult>> map_ar = new map<string, list<AggregateResult>>();
        for(AggregateResult ar : [
            select
                sum(ASI_CRM_Amount_Number__c) amount,
                ASI_CRM_SKU__c skuId,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c type
            from 
                ASI_TH_CRM_PaymentRequestLineItem__c
            where
                recordtypeid = :RTID_PAYMENTREQUESTLINE
                and ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__c = :customerId
                and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c <> :REJECTED
				and ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_Date__c >= :startDate
				and ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_Date__c <= :endDate
            group by
                ASI_CRM_SKU__c,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c
        ]){
            string skuId = string.valueOf(ar.get('skuId'));
            list<aggregateResult> list_ar = map_ar.containsKey(skuId) ? map_ar.get(skuId) : new list<aggregateResult>();
            list_ar.add(ar);
            map_ar.put(skuId, list_ar);
        }
        return map_ar;
    }

    private map<string, list<AggregateResult>> retrieveFOC(string contractId) {
        map<string, list<AggregateResult>> map_ar = new map<string, list<AggregateResult>>();
        for(AggregateResult ar : [
            select
                sum(ASI_CRM_Amount_Number__c) amount,
                ASI_FOC_SKU__c skuId,
                ASI_CRM_Support_Type__c type
            from 
                ASI_FOC_Request_Item__c
            where
                recordtypeid = :RTID_FOCLINE
                and ASI_FOC_Request_Order__r.ASI_CRM_Contract__c = :contractId
                and ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c <> :REJECTED
            group by
                ASI_FOC_SKU__c,
                ASI_CRM_Support_Type__c
        ]){
            string skuId = string.valueOf(ar.get('skuId'));
            list<aggregateResult> list_ar = map_ar.containsKey(skuId) ? map_ar.get(skuId) : new list<aggregateResult>();
            list_ar.add(ar);
            map_ar.put(skuId, list_ar);
        }
        return map_ar;
    }

    private map<string, list<AggregateResult>> retrieveFOC(string customerId, date startDate, date endDate) {
        map<string, list<AggregateResult>> map_ar = new map<string, list<AggregateResult>>();
        for(AggregateResult ar : [
            select
                sum(ASI_CRM_Amount_Number__c) amount,
                ASI_FOC_SKU__c skuId,
                ASI_CRM_Support_Type__c type
            from 
                ASI_FOC_Request_Item__c
            where
                recordtypeid = :RTID_FOCLINE
                and ASI_FOC_Request_Order__r.ASI_CRM_Outlet__c = :customerId
                and ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c <> :REJECTED
				and ASI_FOC_Request_Order__r.ASI_CRM_SG_Order_Date__c >= :startDate
				and ASI_FOC_Request_Order__r.ASI_CRM_SG_Order_Date__c <= :endDate
            group by
                ASI_FOC_SKU__c,
                ASI_CRM_Support_Type__c
        ]){
            string skuId = string.valueOf(ar.get('skuId'));
            list<aggregateResult> list_ar = map_ar.containsKey(skuId) ? map_ar.get(skuId) : new list<aggregateResult>();
            list_ar.add(ar);
            map_ar.put(skuId, list_ar);
        }
        return map_ar;
    }

    /*
     * *************
     * Tools Function
     * *************
     */
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for (String fields : fieldMap.keySet()) {
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
        if (String.isBlank(jsonString)) {
            return null;
        }
        return (List<Object>) System.JSON.deserialize(jsonString, apexType);
    }

    private static String formatDate(date d){
        if(d == null) return ''; 
        Datetime dt = d;
        return dt.format('yyyy-MM-dd');
    }
    
}