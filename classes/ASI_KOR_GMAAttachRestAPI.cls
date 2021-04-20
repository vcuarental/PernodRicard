@RestResource(urlMapping='/ASI_KOR_GMAAttachRestAPI/*')
global with sharing class ASI_KOR_GMAAttachRestAPI {
    
    global static final String PARAM_GMA_ID = 'gmaid';
    global static final String PARAM_EXT = 'ext';
    
    @HttpPut
    global static Map<String, String> submitChanges() {
        RestRequest req = RestContext.request;
        String gmaId = req.params.get(PARAM_GMA_ID);
        String ext = req.params.get(PARAM_EXT);
        if (ext == null) ext = 'jpg';
        List<ASI_KOR_GMA__c> gmaList = [SELECT Id FROM ASI_KOR_GMA__c WHERE Id = :gmaId];
        if (gmaList.size() > 0) {
            ASI_KOR_GMA__c gma = gmaList.get(0);
            ASI_KOR_FileAttachmentController fileAttachCon = new ASI_KOR_FileAttachmentController();
            fileAttachCon.isForPage = false;
            fileAttachCon.sObjParentId = gmaId;
            fileAttachCon.attachmentObjType = 'ASI_KOR_GMA_Image__c';
            fileAttachCon.contentData = req.requestBody;
            fileAttachCon.contentFileName = 'GMA Image ' + System.now().format('yyyy-MM-dd_HH-mm') + '.' + ext;
            fileAttachCon.contentType = 'image/' + ext;
            fileAttachCon.fileSize = fileAttachCon.contentData.size();
            
            fileAttachCon.uploadAction();
        }
        return new Map<String, String> {'success' => 'true'};
    }
    

    
}