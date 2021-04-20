@RestResource(urlMapping='/ASI_KOR_StockInTrade/*')
global with sharing class ASI_KOR_StockInTradeRestAPI {
    
    @HttpPost
    global static Map<String, String> submitChanges(ASI_KOR_Stock_In_Trade__c record, String upsertField, List<ASI_KOR_WS_Stock_In_Trade_Detail__c> Stock_In_Trade_Details) {
        Schema.SObjectField upsertFieldSchema = Schema.SObjectType.ASI_KOR_Stock_In_Trade__c.fields.getMap().get(upsertField);
        ASI_KOR_ParentChildEditHelper pcEditHelper = new ASI_KOR_ParentChildEditHelper('ASI_KOR_Stock_In_Trade__c', record, upsertFieldSchema);
        pcEditHelper.addChildRecords('ASI_KOR_WS_Stock_In_Trade_Detail__c', 'Stock_In_Trade__c', 'Stock_In_Trade_Details__r', Stock_In_Trade_Details);
        ASI_KOR_Stock_In_Trade__c returnRecord = (ASI_KOR_Stock_In_Trade__c)pcEditHelper.commitChanges();
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