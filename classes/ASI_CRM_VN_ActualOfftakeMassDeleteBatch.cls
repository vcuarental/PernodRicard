/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassDeleteBatch
 * Description:  class for ASI_CRM_VN_ActualOfftakeMassDeleteBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

global class ASI_CRM_VN_ActualOfftakeMassDeleteBatch implements Database.Batchable<sObject> {
    global final String ownerId;

    global ASI_CRM_VN_ActualOfftakeMassDeleteBatch(String ownerId){
        this.ownerId = ownerId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
                SELECT Id FROM ASI_TH_CRM_Actual_Offtake__c WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Actual_Offtake_Temporary' AND OwnerId = :ownerId
        ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
     delete scope;
    }

    global void finish(Database.BatchableContext BC){
        User u = [SELECT Id, Name, Email FROM User WHERE Id = :ownerId];

        List<Messaging.Email> emails = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody('Your mass delete submission was processed.<br/>' + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>');
        mail.setPlainTextBody('Your mass delete submission was processed.\n' + '\n\nPlease do not reply to this message.\nContact your system administrator if you have received this message in error.\n');
        mail.setToAddresses(new List<String>{
                u.email
        });
        mail.setSubject('Mass Delete Process is Completed');
        emails.add(mail);
        Messaging.sendEmail(emails);

    }

}