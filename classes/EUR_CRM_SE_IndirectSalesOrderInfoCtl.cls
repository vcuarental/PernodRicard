public with sharing class EUR_CRM_SE_IndirectSalesOrderInfoCtl {
    public String salesOrderId {get;set;}
    public String width {get;set;}
    public String outletToSupMapCode {
    									get {
    										return getOutletToSupplierMappingCode(); 
    										} 
    										set;}

	public EUR_CRM_SE_IndirectSalesOrderInfoCtl() {	
	}

	public String getOutletToSupplierMappingCode(){
		String soAccount;
		String soWholesaler;
		//SalesOrderItemWrapper soInfoWrapperList = new SalesOrderItemWrapper();
		String outletToSupMapCode;
		if( salesOrderId != null){
		EUR_CRM_Sales_Order__c salesOrder = [SELECT Id, Name, EUR_CRM_Account__c,EUR_CRM_Wholesaler__c,EUR_CRM_Contact__c 
                                                    FROM EUR_CRM_Sales_Order__c 
                                                    WHERE Id =: salesOrderId];
        soAccount = salesOrder.EUR_CRM_Account__c;
        soWholesaler = salesOrder.EUR_CRM_Wholesaler__c; 

        List<EUR_CRM_Outlet_to_Supplier_Mapping__c> outletToSupMap = [SELECT EUR_CRM_Customer_Code__c
        															FROM EUR_CRM_Outlet_to_Supplier_Mapping__c
        															WHERE EUR_CRM_Outlet_Account__c =: soAccount
        															AND EUR_CRM_Supplier_Account__c=:soWholesaler LIMIT 1];
		if (outletToSupMap !=null && outletToSupMap.size()>0){
			outletToSupMapCode = outletToSupMap.get(0).EUR_CRM_Customer_Code__c;		
		}  		
		system.debug('Customer Code Found: '+outletToSupMapCode);        																
		
		//handle if no customer code found
		//if (String.isEmpty(outletToSupMapCode)){
		//	outletToSupMapCode = null;
		//}
		 
		}
	return outletToSupMapCode;
	}
}