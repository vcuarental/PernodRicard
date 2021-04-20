@isTest
public without sharing class Utils_TestMethods {

    public static ESNProject__c createProject(){
        ESNProject__c project = new ESNProject__c(Name='TestProject');
        return project;
    }
    
    public static Release__c createRelease(){
        Release__c Release = new Release__c(Name='TestRelease');
        return Release;
    }
    
    public static Request__c createRequest(){
        Request__c Request = new Request__c(Description__c='TestRequest');
        return Request;
    }
    
     public static ESNStream__c createStream(String projectId){
        ESNStream__c stream = new ESNStream__c(Name='TestStream', project__c=projectid);
        return stream;
    }

     //public static ESNStream__c createStream(String projectId, Date startDateProject, Integer gapProject){
     //   Date myDateProject = startDateProject;
     //   ESNStream__c stream = new ESNStream__c(Name='TestStream', project__c=projectid, StartDate__c=myDateProject, EndDate__c=myDateProject.addDays(gapProject));
     //   return stream;
   // }
        
    public static User createStandardUser(String alias){
        Profile profile = [select id from profile where name='Standard User'];
            
        User user = new User(alias = alias, email=alias + '@dev.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profile.Id, 
            timezonesidkey='Europe/London', username=alias + '@esn.pernod-ricard.com');
        return user;
    }
    
    public static User createUserWithProfile(String alias, String profileName){
        Profile profile = new Profile();
        if(profileName != '')
            profile = [select id from profile where name=:profileName];
        else
            profile = [select id from profile where name='Standard User'];
            
        User user = new User(alias = alias, email=alias + '@dev.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profile.Id, 
            timezonesidkey='Europe/London', username=alias + '@esn.pernod-ricard.com');
        return user;
    }
    
    public static void createEventOnProject(DateTime startDate, String projectId,Id owner, Integer eventNumber,Integer gap, String subject) {
        Datetime myDate = startDate;
        List<Event> batch = new List<Event>();
        for (integer i=0;i<eventNumber;i++) {
            Event eve = new Event();
            eve.OwnerId=owner;
            eve.WhatId=projectId;
            eve.Subject=subject + ' ' + i;
            eve.StartDateTime=myDate.addDays(gap) ;
            eve.IsAllDayEvent=true;
            batch.add(eve);
        }
    insert batch;
    }

    public static void createTaskOnProject(DateTime startDate, String projectId,Id owner, Integer eventNumber,Integer gap, String subject) {
        Datetime myDate = startDate;
        List<Task> batch = new List<Task>();
        for (integer i=0;i<eventNumber;i++) {
            Task eve = new Task();
            eve.OwnerId=owner;
            eve.WhatId=projectId;
            if (math.mod(i, 2)==0) {
                eve.Type='Call';
                eve.Priority='Low';
            } else {
                eve.Type='Other';
                eve.Priority='Normal';
            }
            if (math.mod(i, 3)==0) {
                eve.Type=null;
            }
            eve.Subject=subject + ' ' + i;
            eve.ActivityDate=myDate.addDays(gap).date();
            batch.add(eve);
        }
    insert batch;
    }
    
    public static Messaging.InboundEmail.BinaryAttachment createEmailBinaryAttachment(String content){
        Messaging.InboundEmail.BinaryAttachment newAttachmentBIN = new Messaging.InboundEmail.BinaryAttachment();
        newAttachmentBIN.body = blob.valueOf(content);
        newAttachmentBIN.fileName = content+'.pdf';
        newAttachmentBIN.mimeTypeSubType = 'text/plain';  
        return newAttachmentBIN;
    }
    
    public static Messaging.InboundEmail.Textattachment createEmailTextAttachment(String content){
        Messaging.InboundEmail.Textattachment newAttachmentTXT = new Messaging.InboundEmail.Textattachment();
        newAttachmentTXT.body = content;
        newAttachmentTXT.fileName = content+'.txt';
        newAttachmentTXT.mimeTypeSubType = 'text/plain';
        return newAttachmentTXT;
    }
}