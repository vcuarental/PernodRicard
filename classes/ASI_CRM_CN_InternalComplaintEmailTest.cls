@isTest
public class ASI_CRM_CN_InternalComplaintEmailTest {
    static testMethod void InternalComplaintTest(){
        ASI_CRM_Internal_Complaint__c InternalComplaint = new ASI_CRM_Internal_Complaint__c(ASI_CRM_CN_Complaint_Qty_btl__c='10',
                                                                                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Internal_Complaint__cASI_CRM_CN_Complaint_Send_to_BO'));
        insert InternalComplaint;
        
        List<ASI_CRM_Internal_Complaint__c> InternalComplaint1= [select Id,Name from ASI_CRM_Internal_Complaint__c where id=:InternalComplaint.Id];
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body\n2225256325\nTitle';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = InternalComplaint1[0].name+'#Test123';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            
            
            ASI_CRM_CN_InternalComplaintEmailhandler obj= new ASI_CRM_CN_InternalComplaintEmailhandler();
        obj.handleInboundEmail(email, env );
    }
}