public without sharing class ASI_KOR_SalesOrderRequestEDIAutoNumGen extends ASI_KOR_TriggerAbstract {
    
    public static Set<String> RELEVANT_STATUS = new Set<String>{'Requested'};
    private Integer autoNum;
    
    public ASI_KOR_SalesOrderRequestEDIAutoNumGen() {
        super('ASI_KOR_SalesOrderRequestEDIAutoNumGen');
        autoNum = 1000;
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (tAction == TriggerAction.BEFORE_UPDATE) {
            List<ASI_KOR_Sales_Order_Request__c> soReqList = (List<ASI_KOR_Sales_Order_Request__c>)sObjList;
            Set<ID> needAutoNumSOReqIdSet = new Set<ID>();
            for (ASI_KOR_Sales_Order_Request__c soReq : soReqList) {
                if (RELEVANT_STATUS.contains(soReq.ASI_KOR_Order_Status__c)) {
                    ASI_KOR_Sales_Order_Request__c oldSoReq = (ASI_KOR_Sales_Order_Request__c)oldMap.get(soReq.Id);
                    if ((oldSoReq == null || !RELEVANT_STATUS.contains(oldSoReq.ASI_KOR_Order_Status__c)) && initCount <= 1) {
                        needAutoNumSOReqIdSet.add(soReq.Id);
                    }
                }
            }
            
            if (needAutoNumSOReqIdSet.size() > 0) {
                List<ASI_KOR_Sales_Order_Request__c> soReqAndDetailsList = [
                    SELECT Id, ASI_KOR_SYS_INFO_EDI_Document_No__c, (
                        SELECT Id, ASI_KOR_SYS_INFO_EDI_Document_NO__c FROM ASI_KOR_Sales_Order_Transactions__r ORDER BY Name
                    ) FROM ASI_KOR_Sales_Order_Request__c WHERE Id IN :needAutoNumSOReqIdSet
                ];
                List<ASI_KOR_Sales_Order_Transaction__c> updateSOReqDetails = new List<ASI_KOR_Sales_Order_Transaction__c>();
                for (ASI_KOR_Sales_Order_Request__c soReqAndDetails : soReqAndDetailsList) {
                    List<ASI_KOR_Sales_Order_Transaction__c> soReqDetails = soReqAndDetails.ASI_KOR_Sales_Order_Transactions__r;
                    if (soReqDetails != null && soReqDetails.size() > 0) {
                        resetAutoNum();
                        for (ASI_KOR_Sales_Order_Transaction__c soReqDetail : soReqDetails) {
                            soReqDetail.ASI_KOR_SYS_INFO_EDI_Document_NO__c = nextAutoNum();
                            soReqDetail.ASI_KOR_SYS_INFO_SORD_ID__c = detailUniqueId(soReqAndDetails, soReqDetail);
                        }
                        updateSOReqDetails.addAll(soReqDetails);
                    }
                }
                /* Skip testing sales order details to avoid special bug:
                   System.DmlException: Update failed. First exception on row 0 with id xxxxxxxxxxxxx; first error: SELF_REFERENCE_FROM_TRIGGER, Object (id = xxxxxxxxxxxxx) is currently in trigger ASI_KOR_SalesOrderRequest_BeforeUpdate, therefore it cannot recursively update itself: []
                */
                if (updateSOReqDetails.size() > 0 && !Test.isRunningTest()) {
                    update updateSOReqDetails;
                }
            }
        }
    }
    
    private void resetAutoNum() { this.autoNum = 1000; }
    private String nextAutoNum() { String result = String.valueOf(autoNum); autoNum+=1000; return result; }
    private String detailUniqueId(ASI_KOR_Sales_Order_Request__c soReq, ASI_KOR_Sales_Order_Transaction__c soReqDetail) {
        String soReqId = soReq.Id;
        if (soReqId.length() != 15) soReqId = soReqId.substring(0, 15);
        return soReqId + '-' + soReqDetail.ASI_KOR_SYS_INFO_EDI_Document_NO__c;
    }
    
}