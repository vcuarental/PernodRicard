global with sharing class LAT_wakawakaForm {


    public LAT_FormBuilderSchema__c fbs                         {get;set;}
    public LAT_FormBuilderEntries__c entry                      {get;set;}
    public String status                                        {get;set;}
    public List<LAT_FormBuilderConnection__c> connections       {get;set;}
    public String backUrl                                       {get;set;}

    public LAT_wakawakaForm()  {

        Id objectId = ApexPages.currentPage().getParameters().get('id');
        Id entryId = ApexPages.currentPage().getParameters().get('entry');
        backUrl = (ApexPages.currentPage().getParameters().get('isAdmin') != null ) ? '/apex/LAT_SchemaBuilderDashBoard' : '/apex/LAT_UserDashboard' ;



        connections = new  List<LAT_FormBuilderConnection__c>();
        entry = null;

         if(objectId != null ){
            fbs = [Select id, Name,  (Select  UpdateBasedOnLookup__c, SkipIfValueProvided__c, SkipIfValueNotProvided__c,  ObjectName__c,  Mapping__c from LAT_Schema_Connections__r where IsActive__c = true order by Sequence__c asc  ),  (Select Name, Json__c from Form_Builder_Pages__r ORDER BY Order__c ASC,  CreatedDate DESC) ,Pages_Count__c, Status__c from LAT_FormBuilderSchema__c where Id =: objectId];
         }

         if(!fbs.LAT_Schema_Connections__r.isEmpty()) {
             connections = fbs.LAT_Schema_Connections__r;
         }
         //  else {
         //     fbs = new LAT_FormBuilderSchema__c();
         //     fbs.name = 'New';
         //
         // }

          if(entryId != null ){
              entry = [Select id, Name, createddate, LastModifiedDate, Status__c, createdbyid, createdby.name, jsonData__c from LAT_FormBuilderEntries__c where Id =: entryId];
          }
    }


    /*

    */
    public PageReference checkIfEntryExists(){
        Id entryId = ApexPages.currentPage().getParameters().get('entry');
        Id objectId = ApexPages.currentPage().getParameters().get('id');
        String schemaStatus = '';
        List<LAT_FormBuilderSchema__c> currentSchemas  = [Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c  where Id =: objectId];

        if(!currentSchemas.isEmpty()) {
            schemaStatus = currentSchemas[0].status__c;
        }

        PageReference redirectPage = null;
        if(entryId == null  &&  schemaStatus == 'Active'){
            entry = new LAT_FormBuilderEntries__c();
            entry.Status__c = 'Draft';
            entry.Fields_Populated__c = 0;
            entry.Form_Builder_Schema__c = objectId;
            entry.jsonData__c = '[]';

            // var entryDetails = {Status__c: status, Fields_Populated__c: fieldsP, Form_Builder_Schema__c: formId, jsonData__c: JSON.stringify(json) };

            insert entry;
            redirectPage = new PageReference('/apex/LAT_wakawakaForm?id='+objectId+'&entry=' + entry.id);
            redirectPage.setRedirect(true);



        } else {

        }
        return redirectPage;
    }


    /*
    * getObjects
    *
    */
	 @RemoteAction
     global static List<SObject> getSalesforceObject(String fields, String objectName, String searchText, String filter) {

        List<List<sObject>> objectNames = new List<List<sObject>>();

        // we need the name field in each query
        fields = fields + ', Name ';

        String mySearch = searchText+'*';
        String searchquery = '';
        // Filter
        if(filter != '') {
            // the html send with "#"" to do more easy the parser, so we must to return the single quote
            filter = filter.replace('#', '\'');
            searchquery = 'FIND \''+mySearch+'\' IN  NAME FIELDS RETURNING '+objectName+'('+fields+' WHERE '+ filter+')  ' ;
        } else {
            searchquery = 'FIND \''+mySearch+'\' IN  NAME FIELDS RETURNING '+objectName+'('+fields+')';
        }

        System.debug('#searchquery \n'+ searchquery);
        objectNames = search.query(searchquery);

        List<sObject> contentData = new List<sObject>();
        for(List<sObject> obj:objectNames) {
            for(sObject customObj:obj) {
                 contentData.add(customObj);
            }

        }

        system.debug(contentData);



        return contentData;
    }


    @RemoteAction
    global static void saveSalesforceObject(String objName,  String jsonMap) {


        SObject newObject = Schema.getGlobalDescribe().get(objName).newSObject() ;

        Map<String, Object> myMap = (Map<String, Object>)JSON.deserializeUntyped(jsonMap);
        for(String fieldName :  myMap.keySet()) {
            System.debug('*************** Current Target: ' + fieldName);
            System.debug('*************** Current Target: ' + myMap.get(fieldName));
            String fieldValue = (String) myMap.get(fieldName);
            newObject.put(fieldName , fieldValue) ;

        }
        try{
            upsert newObject ;
            system.debug(newObject.id);
            //return newObject.id;
        } catch (DmlException e) {
            List<String> toMail = New List<String>{getUserMail()};
            sendEmail('An error occurred when integrating', e.getMessage() , toMail);

        }

    }

    private static string getUserMail(){
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        return userEmail;
    }

    // Messaging.SingleEmailMessage1
    private static void sendEmail(String subject, String message, List<String> toAddress) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddress);
		mail.setSubject(subject);
		mail.setPlainTextBody(message);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
   }


    @RemoteAction
    public static String doUploadAttachment(String entryId, String attachmentBody, String attachmentName, String attachmentId) {
        system.debug(attachmentId);
        if(entryId != null) {
            LAT_FormBuilderEntries__c entry = getEntry(entryId);
            if(entry != null) {
                if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    String newBody = '';
                    /*if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }*/
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    att.Name = attachmentName;
                    if(attachmentId == null) {

                        att.parentId = entry.Id;
                    }
                    system.debug(att);
                    upsert att;
                    return att.Id;
                } else {
                    return 'Attachment Body was null';
                }
            } else {
                return 'Entry could not be found';
            }
        } else {
            return 'Entry Id was null';
        }
    }

    private static LAT_FormBuilderEntries__c getEntry(String entryId) {
       list<LAT_FormBuilderEntries__c> entries = [SELECT Id, Name
                                 FROM LAT_FormBuilderEntries__c
                                 WHERE Id =: entryId];
       if(entries.isEmpty()) {
           return null;
       } else {
           return entries[0];
       }
   }

    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }


}
// global with sharing class LAT_wakawakaForm {
//
//
//     public LAT_FormBuilderSchema__c fbs {get;set;}
//     public LAT_FormBuilderEntries__c entry {get;set;}
//     public String status {get;set;}
//
//
//     public LAT_wakawakaForm()  {
//         Id objectId = ApexPages.currentPage().getParameters().get('id');
//         Id entryId = ApexPages.currentPage().getParameters().get('entry');
//         entry = null;
//
//          if(objectId != null ){
//             fbs = [Select id, Name,  (Select Name, Json__c from Form_Builder_Pages__r ORDER BY Order__c ASC,  CreatedDate DESC) ,Pages_Count__c, Status__c from LAT_FormBuilderSchema__c where Id =: objectId];
//          }
//          //  else {
//          //     fbs = new LAT_FormBuilderSchema__c();
//          //     fbs.name = 'New';
//          //
//          // }
//
//           if(entryId != null ){
//               entry = [Select id, Name, createddate, LastModifiedDate, Status__c, createdbyid, createdby.name, jsonData__c from LAT_FormBuilderEntries__c where Id =: entryId];
//           }
//     }
//
//
//     /*
//
//     */
//     public PageReference checkIfEntryExists(){
//         Id entryId = ApexPages.currentPage().getParameters().get('entry');
//         Id objectId = ApexPages.currentPage().getParameters().get('id');
//         String schemaStatus = '';
//         List<LAT_FormBuilderSchema__c> currentSchemas  = [Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c  where Id =: objectId];
//
//         if(!currentSchemas.isEmpty()) {
//             schemaStatus = currentSchemas[0].status__c;
//         }
//
//         PageReference redirectPage = null;
//         if(entryId == null  &&  schemaStatus == 'Active'){
//             entry = new LAT_FormBuilderEntries__c();
//             entry.Status__c = 'Draft';
//             entry.Fields_Populated__c = 0;
//             entry.Form_Builder_Schema__c = objectId;
//             entry.jsonData__c = '[]';
//
//             // var entryDetails = {Status__c: status, Fields_Populated__c: fieldsP, Form_Builder_Schema__c: formId, jsonData__c: JSON.stringify(json) };
//
//             insert entry;
//             redirectPage = new PageReference('/apex/LAT_wakawakaForm?id='+objectId+'&entry=' + entry.id);
//             redirectPage.setRedirect(true);
//
//
//
//         } else {
//
//         }
//         return redirectPage;
//     }
//
//
//     /*
//     * getObjects
//     *
//     */
// 	 @RemoteAction
//      global static List<SObject> getSalesforceObject(String fields, String objectName, String searchText, String filter) {
//
//         List<List<sObject>> objectNames = new List<List<sObject>>();
//
//         // we need the name field in each query
//         fields = fields + ', Name ';
//
//         String mySearch = searchText+'*';
//         String searchquery = '';
//         // Filter
//         if(filter != '') {
//             // the html send with "#"" to do more easy the parser, so we must to return the single quote
//             filter = filter.replace('#', '\'');
//             searchquery = 'FIND \''+mySearch+'\' IN  NAME FIELDS RETURNING '+objectName+'('+fields+' WHERE '+ filter+')  ' ;
//         } else {
//             searchquery = 'FIND \''+mySearch+'\' IN  NAME FIELDS RETURNING '+objectName+'('+fields+')';
//         }
//
//         System.debug('#searchquery \n'+ searchquery);
//         objectNames = search.query(searchquery);
//
//         List<sObject> contentData = new List<sObject>();
//         for(List<sObject> obj:objectNames) {
//             for(sObject customObj:obj) {
//                  contentData.add(customObj);
//             }
//
//         }
//
//         system.debug(contentData);
//
//
//
//         return contentData;
//     }
//
//
//     @RemoteAction
//     public static String doUploadAttachment(String entryId, String attachmentBody, String attachmentName, String attachmentId) {
//         system.debug(attachmentId);
//         if(entryId != null) {
//             LAT_FormBuilderEntries__c entry = getEntry(entryId);
//             if(entry != null) {
//                 if(attachmentBody != null) {
//                     Attachment att = getAttachment(attachmentId);
//                     String newBody = '';
//                     /*if(att.Body != null) {
//                         newBody = EncodingUtil.base64Encode(att.Body);
//                     }*/
//                     newBody += attachmentBody;
//                     att.Body = EncodingUtil.base64Decode(newBody);
//                     att.Name = attachmentName;
//                     if(attachmentId == null) {
//
//                         att.parentId = entry.Id;
//                     }
//                     system.debug(att);
//                     upsert att;
//                     return att.Id;
//                 } else {
//                     return 'Attachment Body was null';
//                 }
//             } else {
//                 return 'Entry could not be found';
//             }
//         } else {
//             return 'Entry Id was null';
//         }
//     }
//
//     private static LAT_FormBuilderEntries__c getEntry(String entryId) {
//        list<LAT_FormBuilderEntries__c> entries = [SELECT Id, Name
//                                  FROM LAT_FormBuilderEntries__c
//                                  WHERE Id =: entryId];
//        if(entries.isEmpty()) {
//            return null;
//        } else {
//            return entries[0];
//        }
//    }
//
//     private static Attachment getAttachment(String attId) {
//         list<Attachment> attachments = [SELECT Id, Body
//                                         FROM Attachment
//                                         WHERE Id =: attId];
//         if(attachments.isEmpty()) {
//             Attachment a = new Attachment();
//             return a;
//         } else {
//             return attachments[0];
//         }
//     }
//
//
// }