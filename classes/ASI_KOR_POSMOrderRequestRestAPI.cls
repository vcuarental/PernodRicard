@RestResource(urlMapping='/ASI_KOR_POSM_Order_Request/*')
global with sharing class ASI_KOR_POSMOrderRequestRestAPI {
    
    @HttpPost
    global static Map<String, String> submitChanges(ASI_KOR_POSM_Order_Request__c record, String upsertField, List<ASI_KOR_POSM_Order_Detail__c> ASI_KOR_POSM_Order_Details) {
        Schema.SObjectField upsertFieldSchema = Schema.SObjectType.ASI_KOR_POSM_Order_Request__c.fields.getMap().get(upsertField);
        ASI_KOR_ParentChildEditHelper pcEditHelper = new ASI_KOR_ParentChildEditHelper('ASI_KOR_POSM_Order_Request__c', record, upsertFieldSchema);
        pcEditHelper.addChildRecords('ASI_KOR_POSM_Order_Detail__c', 'ASI_KOR_POSM_Order_Request__c', 'ASI_KOR_POSM_Order_Details__r', ASI_KOR_POSM_Order_Details);
        ASI_KOR_POSM_Order_Request__c returnRecord = (ASI_KOR_POSM_Order_Request__c)pcEditHelper.commitChanges();
        Map<String, String> result = new Map<String, String>();
        if (returnRecord != null) {
            result.put('id', returnRecord.Id);
            result.put('success', 'true');
        } else {
            result.put('success', 'false');
        }
        return result;
    }
    

}