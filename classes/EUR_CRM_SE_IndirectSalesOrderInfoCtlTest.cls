@IsTest(IsParallel = true)
private class EUR_CRM_SE_IndirectSalesOrderInfoCtlTest {

    @IsTest
    static void test() {
        EUR_CRM_Account__c acc = makeAccount();
        insert acc;
        Contact cont = makeContact(acc);
        insert cont;
        EUR_CRM_Sales_Order__c order = makeSalesOrder(acc, cont);
        insert order;

        EUR_CRM_SE_IndirectSalesOrderInfoCtl controller = new EUR_CRM_SE_IndirectSalesOrderInfoCtl();
        controller.salesOrderId = order.Id;
        String code = controller.getOutletToSupplierMappingCode();
        String width = controller.width;
        String outletToSupMapCode = controller.outletToSupMapCode;

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

    private static Contact makeContact(EUR_CRM_Account__c acc) {
        return new Contact(
            EUR_CRM_Account__c = acc.Id
        ,   LastName = 'testContact'
        );
    }

    private static EUR_CRM_Sales_Order__c makeSalesOrder(EUR_CRM_Account__c acc, Contact cont) {
        return new EUR_CRM_Sales_Order__c(
            EUR_CRM_Account__c = acc.Id
        ,   EUR_CRM_Wholesaler__c = acc.Id
        ,   EUR_CRM_Contact__c = cont.Id
        );
    }

}