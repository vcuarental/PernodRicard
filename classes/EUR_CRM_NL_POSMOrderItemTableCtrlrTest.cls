@IsTest(IsParallel = true)
private class EUR_CRM_NL_POSMOrderItemTableCtrlrTest {
    private static final String POSM_ORDER_RECORD_TYPE = 'EUR_ZA_POSM_Order';
    private static final String POSM_ORDER_ITEM_RECORD_TYPE = 'EUR_ZA_POSM_Order_Item';

    @IsTest
    static void test() {
        EUR_CRM_Account__c acc = makeAccount();
        insert acc;
        EUR_CRM_POSM_Order__c order = makePOSMOrder(acc);
        insert order;
        insert makeOrderItem(order);

        EUR_CRM_NL_POSMOrderItemTableCtrlr controller = new EUR_CRM_NL_POSMOrderItemTableCtrlr();
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
        , EUR_CRM_Status__c = 'Active'
        , EUR_CRM_Postal_Code__c = '00000'
        );
    }

    private static EUR_CRM_POSM_Order__c makePOSMOrder(EUR_CRM_Account__c acc) {
        return new EUR_CRM_POSM_Order__c(
//                RecordTypeId = selectRecordTypesIdWhereDeveloperName('EUR_CRM_POSM_Order__c', POSM_ORDER_RECORD_TYPE),
                EUR_CRM_Account__c = acc.Id
        );
    }

    private static EUR_CRM_POSM_Order_Item__c makeOrderItem(EUR_CRM_POSM_Order__c order) {
        return new EUR_CRM_POSM_Order_Item__c(
                EUR_CRM_POSM_Order__c = order.Id,
//                RecordTypeId = selectRecordTypesIdWhereDeveloperName('EUR_CRM_POSM_Order_Item__c', POSM_ORDER_ITEM_RECORD_TYPE),
         EUR_CRM_Quantity__c = 0
        );
    }

    /* ========================================================= */
    /*     SOQL selectors
    /* ========================================================= */

    private static Id selectRecordTypesIdWhereDeveloperName(String sobjType, String devName) {
        return [
                SELECT Id
                FROM RecordType
                WHERE DeveloperName = :devName
                AND SobjectType = :sobjType
                LIMIT 1
        ][0].Id;
    }

}