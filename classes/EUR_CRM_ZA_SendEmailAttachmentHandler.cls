public with sharing class EUR_CRM_ZA_SendEmailAttachmentHandler {

	@InvocableMethod
    public static void sendEmails(List<EUR_CRM_Contract__c> contracts) {
    	Set<Id> contractIds = new Set<Id>();
    	Map<Id, EUR_CRM_Contract__c> contractMap = new Map<Id, EUR_CRM_Contract__c>();
    	for(EUR_CRM_Contract__c con : contracts){
    		contractMap.put(con.Id, con);
    	}
    	
        Map<Id, Attachment> contractAttachmentMap = new Map<Id, Attachment>();
        
        for(Attachment att : [SELECT Id, Body, Name, ParentId FROM Attachment WHERE ParentId IN :contractMap.keyset()]){
        	if(att.Name.contains('EUR_ZA_Outlet_Contract_Soft_Copy')){
        		contractAttachmentMap.put(att.ParentId, att);
        	}
        }
        
        String devname = 'EUR_ZA_Contract_Notify_Event_Mgr';
        Id vfTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :devname].Id;
        
        //List<Messaging.SingleEmailMessage>﻿ mails = new List<Messaging.SingleEmailMessage>﻿();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(String key : contractAttachmentMap.keyset()){
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	mail.setTemplateId(vfTemplateId);
        	mail.setWhatId(key);
        	mail.setTargetObjectId(contractMap.get(key).EUR_CRM_Event_Manager__c);
        	mail.setSaveAsActivity(false);
        	
        	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setFileName(contractAttachmentMap.get(key).Name+'.pdf');
			efa.setBody(contractAttachmentMap.get(key).Body);
			
			mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        	
        	mails.add(mail);
        }
        
        if(mails.size() > 0){
        	Messaging.sendEmail(mails);
        }
    }
}