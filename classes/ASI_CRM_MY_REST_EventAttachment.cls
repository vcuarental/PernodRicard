@RestResource(urlMapping='/Attachment/*')
global with sharing class ASI_CRM_MY_REST_EventAttachment {

    @HttpGet
    global static Attachment[] doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //String attachId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //
        String queryStr = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        String attachId = '';
        String ownerId = '';
        datetime lastsyncTime = DateTime.now();
        Attachment[] result;
            
        if(queryStr.contains('_')) {
           String[] arr = queryStr.split('_');
            
           ownerId = arr[0];
                     
           //lastsyncTime = Datetime.parse(EncodingUtil.urlDecode(arr[1], 'utf-8'));  // 31/3/2018 11:55
           lastsyncTime = Datetime.valueOfGMT(EncodingUtil.urlDecode(arr[1], 'utf-8'));  // 2018-05-11 00:00:00
             
                
           result = [SELECT Id, Name, Body, Description, BodyLength, ParentId, OwnerId, IsDeleted, LastModifiedDate FROM Attachment 
                      WHERE ParentId IN (SELECT ID FROM ASI_CRM_EventCapture__c WHERE OwnerId=:ownerId AND IsDeleted=false)
                      AND LastModifiedDate >: lastsyncTime ALL ROWS];
            
        } else if (queryStr.length()==18) {
            attachId = queryStr;
            result = [SELECT Id, Name, Body, Description, BodyLength, ParentId, OwnerId, IsDeleted, LastModifiedDate FROM Attachment WHERE Id = :attachId];
        }

        for(integer i=0; result!=null && i < result.size(); i++)
            result[i].Description  = EncodingUtil.base64Encode(result[i].Body);

        return result;
    }

  
}