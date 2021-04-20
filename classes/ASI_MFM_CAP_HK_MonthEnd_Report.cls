global class ASI_MFM_CAP_HK_MonthEnd_Report implements Database.Batchable<sObject>{
    global ASI_MFM_CAP_HK_MonthEnd_Report() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Start
        String query = 'SELECT id from ASI_MFM_CAP_OV_Creation_Log__c LIMIT 1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        //Execute
        //Define Email Recipients
        Final String BUFFER_USER_PUBLIC_GROUP = 'ASI_MFM_CAP_HK_Logistics_Buffer_Users';
        Id ORG_WIDE_EMAIL_ID = [SELECT id FROM OrgWideEmailAddress WHERE DisplayName = 'Asia Salesforce IT Service Desk' LIMIT 1].Id;
        
        //Admin User Id
        Id UserId = (Id)UserInfo.getUserId();
        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ASI_MFM_CAP_HK_Month_End_Notification'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<ASI_MFM_CAP_OV_Creation_Log__c> lstLog = [SELECT id FROM ASI_MFM_CAP_OV_Creation_Log__c LIMIT 1];
        mail.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ID);
        mail.setTargetObjectId(UserId);
        mail.setTemplateId(templateId.Id);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(getMailList(BUFFER_USER_PUBLIC_GROUP));
        allmsg.add(mail);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg,false);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
    }
    
    private List<String> getMailList(String publicgroup) {
        List<String> mailList = new List<String>();
        Set<Id> groupMemberId = new Set<Id>();
        for (groupmember listgroupMember : [select UserOrGroupId FROM groupmember WHERE group.developername = :publicgroup]) {
            groupMemberId.add(listgroupMember.UserOrGroupId);
        }
        if (groupMemberId.size() > 0) {
            for(user listUser : [SELECT email FROM user WHERE id in :groupMemberId]) {
                System.debug('Email := ' + listUser.email);
                if(!mailList.contains(String.ValueOf(listUser.email))) {
                    mailList.add(String.ValueOf(listUser.email));
                }
            }
        } 
        return mailList;
    }
}