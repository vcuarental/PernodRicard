public with sharing class GRP_CC_AttachPDF {

    public string idVal{get;set;}
    //public string doSave{get;set;}

    public GRP_CC_AttachPDF(ApexPages.StandardController stdController){
        idVal = (String)stdController.getId();
        //orderName = idVal.getSObjectType().getDescribe().getName();
    }

    @AuraEnabled
    public static ContentVersion savePDFFile(String recordId, String typeObj) {
        System.debug('###### savePDFFile typeObj : ' + typeObj);
        PageReference pages;

        switch on typeObj{
            when 'deepdive' {
                pages = Page.GRP_CC_deep_dive_PDF;
            }
            
        }
        pages.getParameters().put('id', recordId);
        Blob pdfPageBlob;

        if(Test.isRunningTest()){
            pdfPageBlob = blob.valueOf('Unit.Test');
        }else{
            pdfPageBlob = pages.getContentAsPDF();
        }
        ContentVersion vContentVersion = new ContentVersion();
        vContentVersion.ContentLocation = 'S';
        switch on typeObj{
            when 'deepdive' {
                vContentVersion.PathOnClient = [SELECT Name FROM GRP_CC_deep_dive__c WHERE Id = :recordId LIMIT 1].Name + '.pdf';
                vContentVersion.Title = vContentVersion.PathOnClient;
            }
            
        }

        vContentVersion.VersionData = pdfPageBlob;
        
        insert vContentVersion;
        vContentVersion = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE id =: vContentVersion.Id];

        ContentDocumentLink vContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = recordId,
            ContentDocumentId = vContentVersion.ContentDocumentId,
            Visibility = 'AllUsers',
            ShareType = 'V'
        );
        insert vContentDocumentLink;
        return vContentVersion;
    }

}