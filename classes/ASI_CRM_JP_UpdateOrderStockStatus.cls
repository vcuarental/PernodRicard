/*********************************************************************************
 * Name: ASI_CRM_JP_UpdateOrderStockStatus
 * Description: Update the Partial Complete Flag to alert users in case quantity cancelled is > 0
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/08/2017       Vincent Kwok            Created          
*********************************************************************************/
public class ASI_CRM_JP_UpdateOrderStockStatus extends ASI_CRM_JP_TriggerAbstract{

    public ASI_CRM_JP_UpdateOrderStockStatus() {
        super('ASI_CRM_JP_UpdateOrderStockStatus');
    }    
    
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<Id> salesOrderIdSet = new Set<Id>();
        List<ASI_CRM_JP_Sales_Order_History__c> salesOrderList = filterSalesOrder((List<ASI_CRM_JP_Sales_Order_History__c>) sObjList, (Map<Id, ASI_CRM_JP_Sales_Order_History__c>) oldMap);
        for (ASI_CRM_JP_Sales_Order_History__c salesOrderListidx : salesOrderList) {
            salesOrderIdSet.add(salesOrderListidx.ASI_CRM_Sales_Order__c);
        }
        if (salesOrderIdSet.size() > 0) {
            List<ASI_CRM_JP_Sales_Order__c> LinkedSalesOrderList = [SELECT id, name, ASI_CRM_JP_Partial_Complete__c FROM ASI_CRM_JP_Sales_Order__c WHERE id in :salesOrderIdSet];
            for (ASI_CRM_JP_Sales_Order__c LinkedSalesOrder : LinkedSalesOrderList) {
                LinkedSalesOrder.ASI_CRM_JP_Partial_Complete__c = true;
            }
            update LinkedSalesOrderList;
        }
    }
    
    private List<ASI_CRM_JP_Sales_Order_History__c> filterSalesOrder(List<ASI_CRM_JP_Sales_Order_History__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order_History__c> salesOrderMap) {
        List<ASI_CRM_JP_Sales_Order_History__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order_History__c>();
        for(ASI_CRM_JP_Sales_Order_History__c salesOrder : salesOrderList) {
            if(salesOrder.ASI_CRM_Total_Cancelled_Quantity__c > 0 && 
               salesOrder.ASI_CRM_Total_Cancelled_Quantity__c != salesOrderMap.get(salesOrder.Id).ASI_CRM_Total_Cancelled_Quantity__c) {
              filteredSalesOrderList.add(salesOrder);
            }
        }
        return filteredSalesOrderList;
    }    
}