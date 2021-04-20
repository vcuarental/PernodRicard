public with sharing class MMPJ_XRM_LCR03_DisplayPicture {
    
    @AuraEnabled
    public static Id getLastImageApex(Id pRecordId) {
        ContentDocumentLink vContentDocumentLink = getLastImageContentDocumentLink(pRecordId);
        
        if(vContentDocumentLink != null){
            return vContentDocumentLink.ContentDocumentId;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean updateContentDocumentTitleApex(Id pContentDocumentId) {
        ContentDocument vContentDocument = [SELECT Title FROM ContentDocument WHERE Id =:pContentDocumentId limit 1];
        vContentDocument.Title = 'MMPJ_XRM_photo_contact_' + vContentDocument.Title;
        update vContentDocument;
        return true;
    }
    
    @AuraEnabled
    public static Id deleteLastImageApex(Id pRecordId) {
        ContentDocumentLink vContentDocumentLink = getLastImageContentDocumentLink(pRecordId);
        ContentDocument vContentDocument = [SELECT Id FROM ContentDocument WHERE Id = :vContentDocumentLink.ContentDocumentId limit 1];
        delete vContentDocument;
        return getLastImageApex(pRecordId);
    }
    
    //return the last uploaded file linked to the current recordId, filtered on contentDocument title wich has to begin with 'MMPJ_XRM_photo_contact'
    private static ContentDocumentLink getLastImageContentDocumentLink(Id pRecordId) {
        try{
            ContentDocumentLink vContentDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:pRecordId AND ContentDocumentId IN (SELECT Id FROM ContentDocument WHERE Title LIKE '%MMPJ_XRM_photo_contact%') ORDER BY ContentDocumentId DESC NULLS FIRST limit 1];
            return vContentDocumentLink;
        }
        catch(exception e){
            return null;
        }
    }
    
}