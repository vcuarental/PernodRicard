/**
 * Created by user on 2019-03-25.
 */

trigger ASI_EV_Prediction_Trigger on ASI_EV_Prediction__c (before delete) {

    Set<Id> delIds = Trigger.OldMap.KeySet();

    // ContentDocumentLink
    List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :delIds];

    Set<Id> contentDocumentIds = new Set<Id>();
    for(ContentDocumentLink cdl : cdlList){
        contentDocumentIds.add(cdl.ContentDocumentId);
    }

    // ContentDocument
    List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];

    // ContentDocument Delete
    if(cdList.size() > 0) delete cdList;

}