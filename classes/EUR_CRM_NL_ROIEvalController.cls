public with sharing class EUR_CRM_NL_ROIEvalController {

    private ApexPages.StandardController standardController { get; set; }
    public EUR_CRM_Contract__c contractObj { get; set; }
    public Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap { get; set; } // Key is mechanic type name
    public Map<String, List<MechanicTypeWrapper>> mechTypeWrapperMap { get; set; }
    public Set<String> mechanicTypes = new Set<String>{
            'Pouring Refund', 'Lumpsum', 'Marketing Tailormade', 'Brand Activation', 'Bar Presentation', 'POS', 'Drinks Menu', 'Other Activities', 'Trainings'
    };
    // Set to control the order of the table
//    public String availableActivities {
//        get {
//            if (availableActivities == null) {
//                availableActivities = ', ';
//                for (String key : mechTypeWrapperMap.keyset()) {
//                    availableActivities += key + ', ';
//                }
//                System.debug('availableActivities: ' + availableActivities);
//            }
//            return availableActivities;
//        }
//        set;
//    }
    // lists available activities according to mechTypes
    public Set<Id> activityItemsId { get; set; }

    //Calculation
    public Set<String> getMechanicTypes() {
        for (String mechType : mechanicTypes){
            if(!mechTypeWrapperMap.keySet().contains(mechType)){
                mechanicTypes.remove(mechType);
            }
        }
        return mechanicTypes;
    }

    public Decimal GtTotalRebate { get; set; }
    public Decimal GtOtherInvest { get; set; }
    public Decimal GtNetSales { get; set; }
    public Decimal GtTotalCM { get; set; }
    public Decimal GtProfit { get; set; }
    public Decimal GtProfitIclMktInv { get; set; }
    public Decimal PercentProfitNS { get; set; }
    public Decimal PercentProfitNSInclInv { get; set; }

    //constructor
    public EUR_CRM_NL_ROIEvalController(ApexPages.StandardController standardController) {

        GtTotalRebate = 0;
        GtOtherInvest = 0;
        GtNetSales = 0;
        GtTotalCM = 0;
        GtProfit = 0;
        GtProfitIclMktInv = 0;
        PercentProfitNS = 0;
        PercentProfitNSInclInv = 0;

        System.Debug('Init2');
        this.standardController = standardController;
        if (String.isEmpty(this.standardController.getId())) {
        } else {
            contractObj = (EUR_CRM_Contract__c) standardController.getRecord();
            // Retrieve the contract related list data
        }
        System.Debug(contractObj);

        if (contractObj != null) {


            retrieveMechanicTypes();
            retrieveActivityLineItems();
            calculateGrandTotal();

        }
    }

    public EUR_CRM_NL_ROIEvalController() {
        System.Debug('Init1');
        String ObjectId = ApexPages.currentPage().getParameters().get('id');
        contractObj = [SELECT Id,RecordTypeId, EUR_CRM_Status__c FROM EUR_CRM_Contract__c WHERE Id = :ObjectId];
        this.standardController = New ApexPages.StandardController(contractObj);
        System.Debug(contractObj);

        if (contractObj != null) {
            retrieveMechanicTypes();
            retrieveActivityLineItems();
        }
    }


    /***********************************************************************
    * Description:      Retrieve All Mechanic Types
    *                   mechanicTypeMap
    *                   
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/
    private void retrieveMechanicTypes() {
        mechanicTypeMap = new Map<String, EUR_CRM_Mechanic_Type__c>();
        for (EUR_CRM_Mechanic_Type__c mechanic : [
                SELECT Id, Name, EUR_CRM_Country_Code__c
                FROM EUR_CRM_Mechanic_Type__c
                WHERE EUR_CRM_Country_Code__c = 'NL'
        ]) {
            mechanicTypeMap.put(mechanic.Name, mechanic);
        }
        System.debug('mechanicTypeMap:' + mechanicTypeMap);
    }


    /***********************************************************************
    * Description:      Retrieve All Contract Activity Line Items
    *                   populates the Activity product Item map
    *                   
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/

    public void retrieveActivityLineItems() {
        mechTypeWrapperMap = new Map<String, List<MechanicTypeWrapper>>();
        EUR_CRM_Contract_Activity_Item__c activityPouringRefund;
        List<EUR_CRM_Contract_Product_Item__c> productItemsListingAndPouringRefund = new List<EUR_CRM_Contract_Product_Item__c>();
        List<EUR_CRM_Contract_Rebate__c> rebatesListingAndPouringRefund = new List<EUR_CRM_Contract_Rebate__c>();
        String key = '';
        for (EUR_CRM_Contract_Activity_Item__c activity : [
                SELECT Id,
                        Name,
                        EUR_CRM_Contract__c,
                        EUR_CRM_Mechanic_Type__c,
                        EUR_CRM_Mechanic_Type__r.Name,
                        EUR_CRM_Mechanic_Type__r.EUR_CRM_Country_Code__c,
                        EUR_CRM_Lumpsum_Value__c,
                        EUR_CRM_Description__c,
                        EUR_CRM_Product_Item_Qty_Total__c,
                        EUR_CRM_Total_Actual_Performance_Bottles__c,
                        EUR_CRM_Performance_Index__c,
                        EUR_CRM_Premium_Total_Volume_lt__c,
                        EUR_CRM_Super_Premium_Total_Volume_lt__c,
                        EUR_CRM_Premium_Performance_Rebate__c,
                        EUR_CRM_SP_Performance_Rebate__c,
                        EUR_CRM_Premium_Conditional_Rebate__c,
                        EUR_CRM_SP_Conditional_Rebate__c,
                        EUR_CRM_Amount__c,
                        EUR_CRM_Product_Items_Total__c,
                        EUR_CRM_Contract_Activity_Total__c,
                        EUR_CRM_Name__c,
                        EUR_CRM_Amount_Year_1__c, (
                        SELECT Name,
                                EUR_CRM_Brand__c,
                                EUR_CRM_Premium_Super_Premium__c,
                                EUR_CRM_Brand__r.name,
                                EUR_CRM_Brand_Quality__r.name,
                                EUR_CRM_Brand_Quality_Size__r.name,
                                EUR_CRM_Quantity__c,
                                EUR_CRM_Amount__c,
                                EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c,
                                EUR_CRM_Marketing_Amount__c,
                                EUR_CRM_Amount_Spent__c,
                                EUR_CRM_Volume_lt__c,
                                EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c,
                                EUR_CRM_Brand_Quality__r.EUR_CMR_Net_Sales__c,
                                EUR_CRM_Product_Name__c
                        FROM Contract_Product_Items__r
                ), (
                        SELECT EUR_CRM_Conditional_Rebate__c,
                                EUR_CRM_Performance_Rebate__c,
                                EUR_CRM_Total_Conditional_Rebate__c,
                                EUR_CRM_Total_Performance_Rebate__c,
                                EUR_CRM_Product_Sub_Category__c
                        FROM Contract_Rebates_EU__r
                )
                FROM EUR_CRM_Contract_Activity_Item__c
                WHERE EUR_CRM_Contract__c = :contractObj.Id
                //LIMIT 49999
        ]) {

            key = activity.EUR_CRM_Mechanic_Type__r.Name;
            if (key == 'Listing' || key == 'Pouring Refund') {
                activityPouringRefund = activity;

                productItemsListingAndPouringRefund.addAll(activity.Contract_Product_Items__r);
                rebatesListingAndPouringRefund.addAll(activity.Contract_Rebates_EU__r);
                continue;

            }
            if (mechTypeWrapperMap.containsKey(key)) {
                mechTypeWrapperMap.get(key).add(new MechanicTypeWrapper(key, activity, activity.Contract_Product_Items__r, activity.Contract_Rebates_EU__r));
            } else {
                List<MechanicTypeWrapper> mecTypes = new List<MechanicTypeWrapper>();
                mecTypes.add(new MechanicTypeWrapper(key, activity, activity.Contract_Product_Items__r, activity.Contract_Rebates_EU__r));
                mechTypeWrapperMap.put(key, mecTypes);
            }
        }
        List<MechanicTypeWrapper> mecTypes = new List<MechanicTypeWrapper>();
        key = 'Pouring Refund';
        mecTypes.add(new MechanicTypeWrapper(key, activityPouringRefund, productItemsListingAndPouringRefund, rebatesListingAndPouringRefund));
        mechTypeWrapperMap.put(key, mecTypes);

    }
    public class MechanicTypeWrapper {
        public String mechTypeName { get; set; }
        public EUR_CRM_Contract_Activity_Item__c activity { get; set; }
        public List<EUR_CRM_Contract_Product_Item__c> productItems { get; set; }
        public List<EUR_CRM_Contract_Rebate__c> rebates { get; set; }
        public Map<Id, Decimal> pouringRefundNetSalesMap { get; set; }
        public Map<Id, Decimal> pouringRefundTtlNetSalesMap { get; set; }
        public Map<Id, Decimal> pouringRefundTtlCMMap { get; set; }
        public Map<Id, Decimal> pouringRefundCMMap { get; set; }
        public Map<Id, Decimal> pouringRefundTtlRebateMap { get; set; }

        public Decimal otherInvestValueAmount {
            get;
            set {
                otherInvestValueAmount = (value == null ? 0 : value);
            }
        }

        public List<Decimal> pouringRefundNetSales {
            get {
                List<Decimal> tempList = new List<Decimal>();
                for (Id pid : pouringRefundNetSalesMap.keySet()) {
                    tempList.add(pouringRefundNetSalesMap.get(pid));
                }
                return tempList;
            }
            private set;
        }

        public List<Decimal> pouringRefundCM {
            get {
                List<Decimal> tempList = new List<Decimal>();
                for (Id pid : pouringRefundCMMap.keySet()) {
                    tempList.add(pouringRefundCMMap.get(pid));
                }
                return tempList;
            }
            private set;
        }

        public List<Decimal> pouringRefundTtlNetSales {
            get {
                List<Decimal> tempList = new List<Decimal>();
                for (Id pid : pouringRefundTtlNetSalesMap.keySet()) {
                    tempList.add(pouringRefundTtlNetSalesMap.get(pid));
                }
                return tempList;
            }
            private set;
        }

        public List<Decimal> pouringRefundTtlCM {
            get {
                List<Decimal> tempList = new List<Decimal>();
                for (Id pid : pouringRefundTtlCMMap.keySet()) {
                    tempList.add(pouringRefundTtlCMMap.get(pid));
                }
                return tempList;
            }
            private set;
        }

        public Boolean hasItems { get; set; }


        public MechanicTypeWrapper(String mechTypeName, EUR_CRM_Contract_Activity_Item__c activityx, List<EUR_CRM_Contract_Product_Item__c> productItemsx, List<EUR_CRM_Contract_Rebate__c> rebatesx) {
            pouringRefundNetSalesMap = New Map<Id, Decimal>(); //Net Sales/lt
            pouringRefundTtlNetSalesMap = New Map<Id, Decimal>(); //Net Sales
            pouringRefundCMMap = New Map<Id, Decimal>();  // CM (EUR/lt)
            pouringRefundTtlCMMap = New Map<Id, Decimal>(); //Total CM
            pouringRefundTtlRebateMap = New Map<Id, Decimal>(); //Total Rebate = (Volume target/lt * Perform Rebate Rate) + (Volume target/lt * Condi Rebate Rate)
            rebates = rebatesx;

            otherInvestValueAmount = 0;
            hasItems = false;
            this.mechTypeName = mechTypeName;
            activity = activityx;
            productItems = productItemsx;

            Decimal premiumPerformanceRebate = 0;
            Decimal premiumConditionalRebate = 0;
            Decimal superPremiumPerformanceRebate = 0;
            Decimal superPremiumConditionalRebate = 0;

            if (productItemsx.size() > 0) {
                hasItems = true;
            }
            if (mechTypeName == 'Pouring Refund') {
                if (rebates.size() > 0) {
                    for (EUR_CRM_Contract_Rebate__c rebate : rebates) {

                        if (rebate.EUR_CRM_Product_Sub_Category__c == 'Premium') {
                            Decimal tmpPremiumPerformanceRebate = rebate.EUR_CRM_Performance_Rebate__c == null ? 0 : rebate.EUR_CRM_Performance_Rebate__c;
                            Decimal tmpPremiumConditionalRebate = rebate.EUR_CRM_Conditional_Rebate__c == null ? 0 : rebate.EUR_CRM_Conditional_Rebate__c;
                            premiumPerformanceRebate += tmpPremiumPerformanceRebate;
                            premiumConditionalRebate += tmpPremiumConditionalRebate;
                        } else if (rebate.EUR_CRM_Product_Sub_Category__c == 'Super Premium') {

                            Decimal tmpSuperPremiumPerformanceRebate = rebate.EUR_CRM_Performance_Rebate__c == null ? 0 : rebate.EUR_CRM_Performance_Rebate__c;
                            Decimal tmpSuperPremiumConditionalRebate = rebate.EUR_CRM_Conditional_Rebate__c == null ? 0 : rebate.EUR_CRM_Conditional_Rebate__c;
                            superPremiumPerformanceRebate += tmpSuperPremiumPerformanceRebate;
                            superPremiumConditionalRebate += tmpSuperPremiumConditionalRebate;

                        }
                    }
                }
            }
            if (hasItems && mechTypeName == 'Pouring Refund') {

                for (EUR_CRM_Contract_Product_Item__c product_Item : productItems) {

                    Decimal netSales = product_Item.EUR_CRM_Brand_Quality__r.EUR_CMR_Net_Sales__c == null ? 0 : product_Item.EUR_CRM_Brand_Quality__r.EUR_CMR_Net_Sales__c;
                    Decimal contributiveMarginBQ = product_Item.EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c == null ? 0 : product_Item.EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c;
                    Decimal volumeLt = product_Item.EUR_CRM_Volume_lt__c == null ? 0 : product_Item.EUR_CRM_Volume_lt__c;

                    pouringRefundNetSalesMap.put(product_Item.Id, netSales); //Net Sales/lt
                    pouringRefundCMMap.put(product_Item.Id, contributiveMarginBQ); // CM (EUR/lt)

                    Decimal totalRebate = 0;
                    If (product_Item.EUR_CRM_Premium_Super_Premium__c == 'Premium') {
                        totalRebate = (premiumPerformanceRebate * volumeLt) + (premiumConditionalRebate * volumeLt);
                    } else if (product_Item.EUR_CRM_Premium_Super_Premium__c == 'Super Premium') {
                        totalRebate = (superPremiumPerformanceRebate * volumeLt) + (superPremiumConditionalRebate * volumeLt);
                    }
                    pouringRefundTtlRebateMap.put(product_Item.Id, totalRebate);

                    pouringRefundTtlNetSalesMap.put(product_Item.Id, volumeLt * pouringRefundNetSalesMap.get(product_Item.Id));
                    pouringRefundTtlCMMap.put(product_Item.Id, volumeLt * pouringRefundCMMap.get(product_Item.Id));
                }
            }
            if (mechTypeName == 'Marketing Tailormade' || mechTypeName == 'Lumpsum') {
                otherInvestValueAmount = activity.EUR_CRM_Amount_Year_1__c;
            } else if (mechTypeName == 'Trainings') {
                otherInvestValueAmount = activity.EUR_CRM_Amount__c;
            } else if (mechTypeName != 'Pouring Refund') {
//                otherInvestValueAmount = activity.EUR_CRM_Product_Items_Total__c;
                otherInvestValueAmount = activity.EUR_CRM_Contract_Activity_Total__c;
            }
        }


    }

    public void calculateGrandTotal() {

        Decimal LumpSum1stYr = 0;

//Loop Mechacnic Product For:
//getGtTotalRebate
//getGtNetSales
//getGtTotalCM

//Loop Mechanic For:
//getGtOtherInvest

//Assign Lumpsum 1st yr to LumpSum1stYr

//getGtProfit = getGtTotalCM - getGtTotalRebate

        for (String mcName : mechTypeWrapperMap.keySet()) {
            List<MechanicTypeWrapper> mcWrapperList = mechTypeWrapperMap.get(mcName);

            for (MechanicTypeWrapper mcWrapper : mcWrapperList) {
                If (mcWrapper.mechTypeName == 'Pouring Refund') {
//Loop Products
                    If (mcWrapper.hasItems) {
                        for (EUR_CRM_Contract_Product_Item__c product_Item : (List<EUR_CRM_Contract_Product_Item__c>) mcWrapper.productItems) {
                            GtTotalRebate += mcWrapper.pouringRefundTtlRebateMap.get(product_Item.id);
                            GtNetSales += mcWrapper.pouringRefundTtlNetSalesMap.get(product_Item.id);
                            GtTotalCM += mcWrapper.pouringRefundTtlCMMap.get(product_Item.id);
                        }
                    }
                } Else If (mcWrapper.mechTypeName == 'Lumpsum') {
                    LumpSum1stYr = mcWrapper.otherInvestValueAmount;
                    GtOtherInvest += mcWrapper.otherInvestValueAmount;
                } Else If (mcWrapper.mechTypeName == 'Marketing Tailormade') {
                    GtOtherInvest += mcWrapper.otherInvestValueAmount;
                    GtProfitIclMktInv -= mcWrapper.otherInvestValueAmount;
                } Else {
                    GtOtherInvest += mcWrapper.otherInvestValueAmount;
                }
            }
        }
        GtProfit = GtTotalCM - GtTotalRebate - LumpSum1stYr;
//        GtProfitIclMktInv += GtProfit;
        GtProfitIclMktInv = GtProfit - GtOtherInvest + LumpSum1stYr;
        PercentProfitNS = GtNetSales == 0 ? 0 : (GtProfit / GtNetSales) * 100;
        PercentProfitNSInclInv = GtNetSales == 0 ? 0 : (GtProfitIclMktInv / GtNetSales) * 100;
    }

}