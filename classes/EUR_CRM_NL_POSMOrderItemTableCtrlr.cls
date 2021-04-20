public with sharing class EUR_CRM_NL_POSMOrderItemTableCtrlr {
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
                                   
	public void EUR_CRM_SE_SalesOrderItemTableCtrlr() {
	}

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
        Map<Id, EUR_CRM_POSM_Order_Item__c> soItemMap = new Map<Id, EUR_CRM_POSM_Order_Item__c>();
        Map<String, String> productCodeMap = new Map<String, String>();
        Map<String, String> skuCodeMap = new Map<String, String>();
        Set<Id> wholeSalerIds = new Set<Id>();
        List<SalesOrderItemWrapper> soItemWrapperList = new List<SalesOrderItemWrapper>();

        for(EUR_CRM_POSM_Order_Item__c soItem : [SELECT Id, Name, EUR_CRM_POS_Material__c, EUR_CRM_Quantity__c,
                                                    EUR_CRM_POSM_Order__c, EUR_CRM_POSM_Order__r.EUR_CRM_Wholesaler__c 
                                                    FROM EUR_CRM_POSM_Order_Item__c 
                                                    WHERE EUR_CRM_POSM_Order__c =: salesOrderId]
                                                ){
            soItemMap.put(soItem.Id, soItem);
            wholeSalerIds.add(soItem.EUR_CRM_POSM_Order__r.EUR_CRM_Wholesaler__c);

        }

        for(EUR_CRM_CustomerInternalProductCodeMap__c productCode : [SELECT Id, EUR_CRM_SKU__c, EUR_CRM_Customer_Internal_Product_Code__c, EUR_CRM_Account__c, EUR_CRM_Account__r.Name, EUR_CRM_POS_Material__r.Name
                                                                    FROM EUR_CRM_CustomerInternalProductCodeMap__c
                                                                    WHERE EUR_CRM_Account__c IN : wholeSalerIds
                                                                    ]
                                                                ){
            productCodeMap.put(productCode.EUR_CRM_Account__c,productCode.EUR_CRM_Customer_Internal_Product_Code__c);
        }

        for(EUR_CRM_POSM_Order_Item__c soItem : soItemMap.values()){
            String productCode = productCodeMap.get(soItem.EUR_CRM_POSM_Order__r.EUR_CRM_Wholesaler__c);
            soItemWrapperList.add(new SalesOrderItemWrapper(soItem, soItem.Name, soItem.EUR_CRM_POS_Material__c,
                                                            soItem.EUR_CRM_Quantity__c, productCode));
        }

        return soItemWrapperList;
    }
    
    public class SalesOrderItemWrapper{
        public EUR_CRM_POSM_Order_Item__c soItem {get;set;}
        public String soName {get;set;}
        //public String skuName {get;set;}
        public String posmName {get;set;}
        public Decimal quantity {get;set;}
        //public String unit {get;set;}
        public String productCode {get; set;}
        //public Decimal discountAmt {get; set;}
        
        public SalesOrderItemWrapper(EUR_CRM_POSM_Order_Item__c soItem, String soName, String posmName, Decimal quantity, String productCode){
            this.soItem = soItem;
            this.soName = soName;
            this.posmName = posmName;
            //this.skuCode = skuCode;
            this.quantity = quantity;
            //this.unit = unit;
            this.productCode = productCode;
            //this.discountAmt = discountAmt;
        }
    }

    /**
    *   function: createKey
    *   Creates a unique map key to map sku code with CIP mapping
    */
//    private String createKey(String sku, String account){
//        return sku+account;
//    }
}