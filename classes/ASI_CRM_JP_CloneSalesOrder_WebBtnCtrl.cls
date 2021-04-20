/*********************************************************************************
 * Name: ASI_CRM_JP_CloneSalesOrder_Ctrl
 * Description: Controller class for cloning the Sales Order and Sales Order Item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/06/2019       Wilson Chow             Created
*/

global class ASI_CRM_JP_CloneSalesOrder_WebBtnCtrl {
    Webservice static String validateBillTo(String salesOrderId) {

        List<ASI_CRM_JP_Sales_Order__c> salesOrderList =
            [SELECT Id, ASI_CRM_Sold_To__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_Customer__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Active__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Bill_To_JDE__c
            FROM ASI_CRM_JP_Sales_Order__c
            WHERE Id=:salesOrderId];

        if(salesOrderList == null || salesOrderList.size() == 0) {
            system.debug('Cannnot query sales order by id:' + salesOrderId);
            return '';
        }

        ASI_CRM_JP_Sales_Order__c salesOrder = salesOrderList.get(0);
        system.debug('validateBillTo salesOrder:' + salesOrder);

        if(!(salesOrder.ASI_CRM_Sold_To__c == salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_Customer__c
                && salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Active__c
                && !salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Bill_To_JDE__c)) {
            if(salesOrder.ASI_CRM_Sold_To__c != salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_Customer__c) {
                return 'Please select Bill to customer which is same as Sold to.';
            }
            else if(!salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Active__c) {
                return 'Please select Bill to customer which is active.';
            }
            else {
                return 'Please select Bill to customer which is synced to JDE.';
            }
        }

        return '';
    }
}