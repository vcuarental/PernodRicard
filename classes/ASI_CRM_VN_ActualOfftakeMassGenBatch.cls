/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassGenBatch
 * Description: class for ASI_CRM_VN_ActualOfftakeMassGenBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

global class ASI_CRM_VN_ActualOfftakeMassGenBatch implements Database.Batchable<sObject> {
    global final String ownerId;

    global ASI_CRM_VN_ActualOfftakeMassGenBatch(String ownerId){
        this.ownerId = ownerId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
                SELECT Id FROM ASI_TH_CRM_Actual_Offtake__c WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Actual_Offtake_Temporary' AND OwnerId = :ownerId
        ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_TH_CRM_Actual_Offtake__c> offtakes = (List<ASI_TH_CRM_Actual_Offtake__c>) scope;
        for (ASI_TH_CRM_Actual_Offtake__c offtake : offtakes) {
            offtake.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_VN_Actual_Offtake');
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC){
        User u = [SELECT Id, Name, Email FROM User WHERE Id = :ownerId];

        List<Messaging.Email> emails = new List<Messaging.Email>();

        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        mail1.setSubject('Mass Generate Process is Completed');
        mail1.setPlainTextBody('Your mass generation submission was processed.\n' + '\n\nPlease do not reply to this message.\nContact your system administrator if you have received this message in error.\n');
        mail1.setToAddresses(new List<String>{
                u.email
        });
        emails.add(mail1);

        Set<Id> groupIds = new Set<Id>();
        for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE Group.Name = 'ASI_CRM_VN_Sales_User']) {
            groupIds.add(gm.UserOrGroupId);
        }
        Set<Id> userRolesIds = new Set<Id>(); 
        for(Group g : [SELECT Id, Name, RelatedId FROM Group WHERE Type = 'Role' AND Id in :groupIds]) {
            userRolesIds.add(g.RelatedId);
        }
        
        List<User> users = [SELECT Id, Email FROM User WHERE UserRoleId IN :userRolesIds];
		
        String emailBody = 'Dear User, '
                         + '<br/> '
                         + 'New Actual offtakes are ready for CS request.'
                         + '<br/><br/><br/>' 
                         + 'Chào Bạn'
                         + '<br/> '
                         + 'Doanh số mới nhất vừa được cập nhật và sẵn sàng cho các thanh toán có liên quan.'
                         + '<br/><br/><br/>' 
                         + 'Please do not reply to this message.' 
                         + '<br/>'
                         + 'Contact your system administrator if you have received this message in error.' 
                         + '<br/>';
        
        Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
        mail2.setSubject('Actual offtakes are ready for CS request');
        mail2.setHtmlBody(emailBody);
        mail2.setToAddresses(ASI_CRM_VN_Util_Pluck.strings(users, User.Email));
        
        for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]){  
            if(owa.DisplayName.contains('IT Service Desk')){
               mail2.setOrgWideEmailAddressId(owa.id);    
            }
        }
        
        if(ASI_CRM_VN_Util_Pluck.strings(users, User.Email).size() > 0)
        	emails.add(mail2);

        Messaging.sendEmail(emails);
    }

}