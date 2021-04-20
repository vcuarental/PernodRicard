public interface EUR_NIM_ERPHandler {
    EUR_NIM_Service.RequestResponseWrapper calculatePrice(EUR_CRM_Account__c account, String urlPath, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList);
    List<EUR_NIM_Service.LineItemWrapper> calculateInventory(EUR_CRM_Account__c account, String urlPath, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList);
}