public with sharing class EUR_CRM_NL_SalesOrderItemTableCtrlr {
    public Boolean displayDealColumn{get;set;}
    public String salesOrderId {get;set;}
    public String width {get;set;}
    private List<EUR_CRM_Sales_Order__c> soList;
    public Boolean displayOldStyle {get {
        if(soList == null)
            soList = [SELECT Id, EUR_CRM_Country_Code__c FROM EUR_CRM_Sales_Order__c WHERE Id =: salesOrderId LIMIT 1];
        if(soList.size() > 0){
            if(soList[0].EUR_CRM_Country_Code__c == 'NL'){
                return false;
            } else {
                return true;
            }
        }
        return displayOldStyle;
    }
        set;} {displayOldStyle = true;}

//    public void EUR_CRM_SE_SalesOrderItemTableCtrlr() {
//        displayDealColumn = false;
//        EUR_CRM_Sales_Order__c rt = [Select RecordType.DeveloperName From EUR_CRM_Sales_Order__c Where Id =: salesOrderId];
//        If(rt != null && (rt.RecordType.DeveloperName == 'EUR_NL_Direct_Sales_Order'|| rt.RecordType.DeveloperName == 'EUR_NL_Indirect_Off_Trade_Sales_Order_Item_PR_Delivery')){
//            displayDealColumn = true;
//        }
//    }
    public String getApprovalLink(){
        String url = '';
        List<ProcessInstanceWorkitem> workItemLst = [SELECT Id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId = :salesOrderId];

        if(workItemLst.size() > 0){
            url='https://'+ System.URL.getSalesforceBaseUrl().getHost() +
                    '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;
        }
        return url;
    }

    public List<SalesOrderItemWrapper> getSalesOrderItemsWithCustomerCode(){
        displayDealColumn = false;
        EUR_CRM_Sales_Order__c rt = [Select RecordType.DeveloperName From EUR_CRM_Sales_Order__c Where Id =: salesOrderId];
        If(rt != null && (rt.RecordType.DeveloperName == 'EUR_NL_Direct_Sales_Order'|| rt.RecordType.DeveloperName == 'EUR_NL_Indirect_Off_Trade_Sales_Order_Item_PR_Delivery')){
            displayDealColumn = true;
        }

        Map<Id, EUR_CRM_Sales_Order_Items__c> soItemMap = new Map<Id, EUR_CRM_Sales_Order_Items__c>();
        Map<String, String> productCodeMap = new Map<String, String>();
        Set<Id> wholeSalerIds = new Set<Id>();
        Set<Id> skuIds = new Set<Id>();
        Map<String, String> skuCodeMap = new Map<String, String>();
        Set<String> skuCode = new Set<String>();
        List<SalesOrderItemWrapper> soItemWrapperList = new List<SalesOrderItemWrapper>();

        for(EUR_CRM_Sales_Order_Items__c soItem : [SELECT Id, Name, EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name, EUR_CRM_SKU__r.EUR_CRM_SKU_Code__c, EUR_CRM_Quantity__c, EUR_CRM_Unit__c,
                EUR_CRM_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Size_Image_url__c, EUR_CRM_Sales_Order__c, EUR_CRM_Sales_Order__r.EUR_CRM_Wholesaler__c,EUR_CRM_Discount_Amount__c
        FROM EUR_CRM_Sales_Order_Items__c
        WHERE EUR_CRM_Sales_Order__c =: salesOrderId]
        ){
            soItemMap.put(soItem.Id, soItem);
            wholeSalerIds.add(soItem.EUR_CRM_Sales_Order__r.EUR_CRM_Wholesaler__c);
            skuIds.add(soItem.EUR_CRM_SKU__c);
            skuCode.add(soItem.EUR_CRM_SKU__r.EUR_CRM_SKU_Code__c);
        }
        for (EUR_CRM_SKU__c skuItem: [SELECT Id, Name, EUR_CRM_EAN_Code__c, EUR_CRM_SKU_Code__c
        FROM EUR_CRM_SKU__c
        WHERE id =: skuIds AND
        EUR_CRM_SKU_Code__c =: skuCode]){
            skuCodeMap.put(createKey(skuItem.Id,skuItem.EUR_CRM_SKU_Code__c),skuItem.EUR_CRM_EAN_Code__c);
        }

        for(EUR_CRM_CustomerInternalProductCodeMap__c productCode : [SELECT Id, EUR_CRM_SKU__c, EUR_CRM_Customer_Internal_Product_Code__c, EUR_CRM_Account__c,EUR_CRM_Account__r.Name
        FROM EUR_CRM_CustomerInternalProductCodeMap__c
        WHERE EUR_CRM_Account__c IN : wholeSalerIds
        ]
        ){
            productCodeMap.put(createKey(productCode.EUR_CRM_SKU__c, productCode.EUR_CRM_Account__c), createKey(productCode.EUR_CRM_Customer_Internal_Product_Code__c,productCode.EUR_CRM_SKU__c));
        }

        for(EUR_CRM_Sales_Order_Items__c soItem : soItemMap.values()){
            String skuItem = skuCodeMap.get(createKey(soItem.EUR_CRM_SKU__c,soItem.EUR_CRM_SKU__r.EUR_CRM_SKU_Code__c));
            String productCode = productCodeMap.get(createKey(soItem.EUR_CRM_SKU__c, soItem.EUR_CRM_Sales_Order__r.EUR_CRM_Wholesaler__c));
            soItemWrapperList.add(new SalesOrderItemWrapper(soItem, soItem.Name, soItem.EUR_CRM_SKU__r.Name, soItem.EUR_CRM_SKU__r.EUR_CRM_SKU_Code__c,
                    soItem.EUR_CRM_Quantity__c, soItem.EUR_CRM_Unit__c, productCode, soItem.EUR_CRM_Discount_Amount__c, skuItem));
        }

        return soItemWrapperList;
    }

    public class SalesOrderItemWrapper{
        public EUR_CRM_Sales_Order_Items__c soItem {get;set;}
        public String soName {get;set;}
        public String skuName {get;set;}
        public String skuCode {get;set;}
        public Decimal quantity {get;set;}
        public String unit {get;set;}
        public String productCode {get; set;}
        public Decimal discountAmt {get; set;}
        public String eanCode {get; set;}

        public SalesOrderItemWrapper(EUR_CRM_Sales_Order_Items__c soItem, String soName, String skuName, String skuCode, Decimal quantity, String unit, String productCode, Decimal discountAmt, String eanCode){
            this.soItem = soItem;
            this.soName = soName;
            this.skuName = skuName;
            this.skuCode = skuCode;
            this.quantity = quantity;
            this.unit = unit;
            this.productCode = productCode;
            this.discountAmt = discountAmt;
            this.eanCode = eanCode;
        }
    }

    /**
    *   function: createKey
    *   Creates a unique map key to map sku code with CIP mapping
    */
    private String createKey(String sku, String account){
        return sku+account;
    }
}