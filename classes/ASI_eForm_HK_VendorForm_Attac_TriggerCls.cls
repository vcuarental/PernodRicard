public Without Sharing class ASI_eForm_HK_VendorForm_Attac_TriggerCls {

    Public Static Void afterDelete(List<ASI_eForm_Vendor_Form_Attachment__c> triggerOld){
        
        Set<Id> documentId = new Set<Id>();
        Set<Id> cvIdSet = new Set<Id>();
        
        for(ASI_eForm_Vendor_Form_Attachment__c obj : triggerOld)
            cvIdSet.add(obj.ASI_eForm_FileId__c);
        
        if(cvIdSet.size() > 0){
            
            for(ContentVersion obj : [SELECT Id, ContentDocumentId, SharingPrivacy FROM ContentVersion WHERE Id IN : cvIdSet])
                documentId.add(obj.ContentDocumentId);
                
            
            if(documentId.size() > 0)
                Delete [SELECT id FROM ContentDocument WHERE Id IN : documentId];
        }
    }
}