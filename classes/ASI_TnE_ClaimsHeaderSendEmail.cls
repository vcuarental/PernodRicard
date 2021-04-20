/*********************************************************************************
 * Name:ASI_TnE_ClaimsHeaderSendEmail
 * Description: Send special Email Notification when TnE Claim is submitted
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/3/2015        Laputa: Hank            Created
 * 25/07/2016       Laputa: Hugo Cheung     Updated. Change ASI_TnE_Payment_Amount__c to ASI_TnE_TW_Payment_Amount__c
*********************************************************************************/

public with sharing class ASI_TnE_ClaimsHeaderSendEmail extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsHeaderSendEmail() {
        super('ASI_TnE_ClaimsHeaderSendEmail');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_TnE_ClaimHeader__c> headerList = (List<ASI_TnE_ClaimHeader__c>)sObjList;
        if(oldMap == null){
        }else{
            Map<Id, ASI_TnE_ClaimHeader__c> oldClaimMap = (Map<Id, ASI_TnE_ClaimHeader__c>) oldMap;
            Map<String, EmailTemplate> tempMap = new Map<String, EmailTemplate>();
            for(EmailTemplate temp:[Select id, name, subject, HtmlValue from EmailTemplate where name = 'ASI TnE Approved Email Template' or name = 'ASI TnE HK Approved Email Template']){
                tempMap.put(temp.name, temp);
            }
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Map<String, Boolean> existEmails = new Map<String, Boolean>();
            Set<Id> headerIdSet = new Set<Id>();
            String[] toAddresses;
            for(ASI_TnE_ClaimHeader__c header:headerList){
                if(header.ASI_TnE_Status__c == 'Approved' && header.ASI_TnE_Status__c != oldClaimMap.get(header.Id).ASI_TnE_Status__c){
                    headerIdSet.add(header.Id);        
                }
            }
            List<ASI_TnE_ClaimHeader__c> headerDetailList = [Select Owner.Id, ASI_TnE_Document_No__c, ASI_TnE_Total_Amount__c, ASI_TnE_TW_Total_Amount__c, ASI_TnE_Currency__c, ASI_TnE_Start_Date__c,
                                                             ASI_TnE_End_Date__c, ASI_TnE_Payment_Date__c, CreatedBy.name, name, Id,
                                                            (Select recordtype.name, ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_2__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_3__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_4__c From ASI_TnE_ClaimDetail__r) 
                                                             From ASI_TnE_ClaimHeader__c Where Id In :headerIdSet];
            for(ASI_TnE_ClaimHeader__c header:headerDetailList){
                for(ASI_TnE_ClaimDetail__c detail:header.ASI_TnE_ClaimDetail__r){
                    if(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setWhatID(header.Id);
                        email.setTemplateID((detail.recordtype.name).contains('HK')?tempMap.get('ASI TnE HK Approved Email Template').Id:tempMap.get('ASI TnE Approved Email Template').Id);
                        email.setTargetObjectID(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c);
                        email.setSaveAsActivity(false);
                        if(existEmails.get(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c) == null){
                            existEmails.put(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c, true);
                            emails.add(email);
                        }
                    }
                    if(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_2__c != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setWhatID(header.Id);
                        email.setTemplateID((detail.recordtype.name).contains('HK')?tempMap.get('ASI TnE HK Approved Email Template').Id:tempMap.get('ASI TnE Approved Email Template').Id);
                        email.setTargetObjectID(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_2__c);
                        email.setSaveAsActivity(false);
                        if(existEmails.get(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c) == null){
                            existEmails.put(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c, true);
                            emails.add(email);
                        }
                    }
                    if(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_3__c != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setWhatID(header.Id);
                        email.setTemplateID((detail.recordtype.name).contains('HK')?tempMap.get('ASI TnE HK Approved Email Template').Id:tempMap.get('ASI TnE Approved Email Template').Id);
                        email.setTargetObjectID(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_3__c);
                        email.setSaveAsActivity(false);
                        if(existEmails.get(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c) == null){
                            existEmails.put(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c, true);
                            emails.add(email);
                        }
                    }
                    if(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_4__c != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setWhatID(header.Id);
                        email.setTemplateID((detail.recordtype.name).contains('HK')?tempMap.get('ASI TnE HK Approved Email Template').Id:tempMap.get('ASI TnE Approved Email Template').Id);
                        email.setTargetObjectID(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email_4__c);
                        email.setSaveAsActivity(false);
                        if(existEmails.get(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c) == null){
                            existEmails.put(String.valueOf(header.Id) + detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Notification_Email__c, true);
                            emails.add(email);
                        }
                    }
                }
            }
            if(emails.size() > 0){
                Messaging.sendEmail(emails);
            }
        }
    }
}