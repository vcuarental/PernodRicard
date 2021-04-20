@IsTest (IsParallel = true)
public class EUR_CRM_NL_SalesOrderItemTableCtrlrTest {

    @IsTest
    static void test() {
        EUR_CRM_Account__c acc = makeAccount();
        insert acc;
        EUR_CRM_Sales_Order__c order = makeSalesOrder(acc);
        insert order;
        insert makeOrderItem(order);

        EUR_CRM_NL_SalesOrderItemTableCtrlr controller = new EUR_CRM_NL_SalesOrderItemTableCtrlr();
        controller.salesOrderId = order.Id;
        controller.getApprovalLink();
        controller.getSalesOrderItemsWithCustomerCode();
        Boolean bool = controller.displayOldStyle;
        bool = controller.displayDealColumn;
        String width = controller.width;
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'test'
            ,   EUR_CRM_Status__c = 'Active'
            ,   EUR_CRM_Postal_Code__c = '00000'
        );
    }

    private static EUR_CRM_Sales_Order__c makeSalesOrder(EUR_CRM_Account__c acc) {
        return new EUR_CRM_Sales_Order__c(
            EUR_CRM_Account__c = acc.Id
        );
    }

    private static EUR_CRM_Sales_Order_Items__c makeOrderItem(EUR_CRM_Sales_Order__c order) {
        return new EUR_CRM_Sales_Order_Items__c(
            EUR_CRM_Sales_Order__c = order.Id
        );
    }

}