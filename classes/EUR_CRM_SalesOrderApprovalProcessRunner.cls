public with sharing class EUR_CRM_SalesOrderApprovalProcessRunner {

    private static final String CLASS_NAME = 'EUR_CRM_SalesOrderApprovalProcessRunner';

    private final Set<String> VALID_SO_RT = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'VALID_SO_RT');
    private final Set<String> VALID_SO_COUNTRY_CODES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'VALID_SO_COUNTRY_CODES');
//    private final Set<String> VALID_SO_RT = new Set<String> {
//        'EUR_Free_Goods_to_Customer'
//    ,   'EUR_Free_Goods_to_Stock'
//    };
//
//    private final Set<String> VALID_SO_COUNTRY_CODES = new Set<String> {
//        'DE'
//    ,   'AT'
//    };

    @TestVisible private static final String STATUS_WAITING_FOR_SYNC = 'Waiting for sync';
    @TestVisible private static final String STATUS_INSTANT_VALIDATION = 'Instant validation';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void validateToRunApprovalProcess(List<EUR_CRM_Sales_Order__c> salesOrdersToUpdate, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById) {
        List<EUR_CRM_Sales_Order__c> salesOrderToInstantValidation = this.extractSalesOrdersToInstantValidation(salesOrdersToUpdate, oldSalesOrderById);
        System.debug('\n\n salesOrderToInstantValidation.size() => ' + JSON.serializePretty(salesOrderToInstantValidation.size()) + '\n');
        System.debug('\n\n salesOrderToInstantValidation => ' + JSON.serializePretty(salesOrderToInstantValidation) + '\n');
        if (salesOrderToInstantValidation.isEmpty()) { return ; }

        this.setStatusToInstantValidation(salesOrderToInstantValidation);
    }

    public void runApprovalProcess(List<EUR_CRM_Sales_Order__c> updatedSalesOrders, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById) {
        List<EUR_CRM_Sales_Order__c> salesOrdersToApprove = this.extractSalesOrderToApprove(updatedSalesOrders, oldSalesOrderById);
        System.debug('\n\n salesOrdersToApprove.size() => ' + JSON.serializePretty(salesOrdersToApprove.size()) + '\n');
        System.debug('\n\n salesOrdersToApprove => ' + JSON.serializePretty(salesOrdersToApprove) + '\n');
        if (salesOrdersToApprove.isEmpty()) { return ; }

        this.runAP(salesOrdersToApprove);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void setStatusToInstantValidation(List<EUR_CRM_Sales_Order__c> salesOrders) {
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            salesOrder.EUR_CRM_Status__c = STATUS_INSTANT_VALIDATION;
        }
    }

    private void runAP(List<EUR_CRM_Sales_Order__c> salesOrders) {
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
            submitRequest.setComments('Submitting request for approval automatically by Trigger.');
            submitRequest.setObjectId(salesOrder.Id);

            try {
                Approval.ProcessResult result = Approval.process(submitRequest);
            } catch (Exception e) {
                System.debug('\n\n e.getMessage() => ' + JSON.serializePretty(e.getMessage()) + '\n');
            }

        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Sales_Order__c> extractSalesOrdersToInstantValidation(List<EUR_CRM_Sales_Order__c> salesOrders, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById) {
        Map<Id, RecordTypeInfo> rtInfoByRTId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosById();

        List<EUR_CRM_Sales_Order__c> salesOrderToInstantValidation = new List<EUR_CRM_Sales_Order__c>();
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            if (this.isSalesOrderToInstantValidation(salesOrder, oldSalesOrderById, rtInfoByRTId)) {
                salesOrderToInstantValidation.add(salesOrder);
            }
        }
        return salesOrderToInstantValidation;
    }

    private List<EUR_CRM_Sales_Order__c> extractSalesOrderToApprove(List<EUR_CRM_Sales_Order__c> salesOrders, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById) {
        Map<Id, RecordTypeInfo> rtInfoByRTId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosById();

        List<EUR_CRM_Sales_Order__c> salesOrdersToApprove = new List<EUR_CRM_Sales_Order__c>();
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            if (this.isSalesOrderToApprove(salesOrder, oldSalesOrderById, rtInfoByRTId)) {
                salesOrdersToApprove.add(salesOrder);
            }
        }
        return salesOrdersToApprove;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Boolean isSalesOrderToInstantValidation(EUR_CRM_Sales_Order__c salesOrder, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isValidCountryCode(salesOrder)
            && this.isNeedToValidate(salesOrder, oldSalesOrderById)
            && this.isWaitingForSyncSalesOrder(salesOrder, rtInfoByRTId)
            && this.isExpectedNumberOfChild(salesOrder)
        ;
    }

    private Boolean isSalesOrderToApprove(EUR_CRM_Sales_Order__c salesOrder, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isStatusChanged(salesOrder, oldSalesOrderById)
            && this.isSubmittedSalesOrder(salesOrder, rtInfoByRTId)
        ;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isValidCountryCode(EUR_CRM_Sales_Order__c salesOrder) {
        return String.isNotBlank(salesOrder.EUR_CRM_Country_Code__c)
            && VALID_SO_COUNTRY_CODES.contains(salesOrder.EUR_CRM_Country_Code__c)
        ;
    }

    private Boolean isNeedToValidate(EUR_CRM_Sales_Order__c salesOrder, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById) {
        return this.isNumberOfChildChanged(salesOrder, oldSalesOrderById)
            || this.isStatusChanged(salesOrder, oldSalesOrderById)
        ;
    }

    private Boolean isNumberOfChildChanged(EUR_CRM_Sales_Order__c salesOrder, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById) {
        return salesOrder.EUR_CRM_NumberOfLines__c != oldSalesOrderById.get(salesOrder.Id).EUR_CRM_NumberOfLines__c
			|| salesOrder.EUR_CRM_N_of_DI_roll__c != oldSalesOrderById.get(salesOrder.Id).EUR_CRM_N_of_DI_roll__c
        ;
    }

    private Boolean isStatusChanged(EUR_CRM_Sales_Order__c salesOrder, Map<Id, EUR_CRM_Sales_Order__c> oldSalesOrderById) {
        return salesOrder.EUR_CRM_Status__c != oldSalesOrderById.get(salesOrder.Id).EUR_CRM_Status__c;
    }

    private Boolean isWaitingForSyncSalesOrder(EUR_CRM_Sales_Order__c salesOrder, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isValidSalesOrderMetadata(salesOrder, rtInfoByRTId)
            && salesOrder.EUR_CRM_Status__c == STATUS_WAITING_FOR_SYNC
            && salesOrder.EUR_CRM_NumberOfLines__c != null
        ;
    }

    private Boolean isValidSalesOrderMetadata(EUR_CRM_Sales_Order__c salesOrder, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return salesOrder.RecordTypeId != null
            && rtInfoByRTId.containsKey(salesOrder.RecordTypeId)
            && VALID_SO_RT.contains(rtInfoByRTId.get(salesOrder.RecordTypeId).getDeveloperName())
        ;
    }

    private Boolean isExpectedNumberOfChild(EUR_CRM_Sales_Order__c salesOrder) {
        return salesOrder.EUR_CRM_NumberOfLines__c == salesOrder.EUR_CRM_N_of_DI_roll__c;
    }

    private Boolean isSubmittedSalesOrder(EUR_CRM_Sales_Order__c salesOrder, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isValidSalesOrderMetadata(salesOrder, rtInfoByRTId)
            && salesOrder.EUR_CRM_Status__c == STATUS_INSTANT_VALIDATION
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */


}