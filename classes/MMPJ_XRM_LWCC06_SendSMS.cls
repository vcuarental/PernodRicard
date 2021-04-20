public with sharing class MMPJ_XRM_LWCC06_SendSMS {
    
    @AuraEnabled
    public static Integer getNumberOfContacts(String campaignId,String status, String participation,String presence){
        String req = 'SELECT Id, Contact.Name,ContactId FROM CampaignMember WHERE CampaignId=:campaignId';
        if(status != null && status != ''){
            req+= ' AND Status=:status';
        }
        if(participation != null && participation !=''){
            req += ' AND MMPJ_Ext_Vign_Participation__c=:participation';
        }
        if(presence != null && presence !=''){
            req += ' AND MMPJ_Ext_Vign_Presence__c=:presence';
        }
        List<CampaignMember> cMembers = Database.query(req);
        System.debug('### '+cMembers);
        List<Id> contactIds = new List<Id>();
        for(CampaignMember cMember : cMembers){
            contactIds.add(cMember.ContactId);
        }
        List<Contact> contacts = [
            SELECT Id,MMPJ_Ext_Vign_Telephone_portable_perso__c
            FROM Contact
            WHERE Id in :contactIds
        ];
        
        List<Contact> validContacts = new List<Contact>();
        for(Contact cont : contacts){
            System.debug('### ' +cont.MMPJ_Ext_Vign_Telephone_portable_perso__c);
            if(cont.MMPJ_Ext_Vign_Telephone_portable_perso__c!=null && cont.MMPJ_Ext_Vign_Telephone_portable_perso__c!=''){
                validContacts.add(cont);
            }
        }
        return validContacts.size();
    }


    @AuraEnabled
    public static String handleSendSMS(String message,String messageName,String campaignId, String status, String participation,String presence){
        String messageEncode = message.replaceAll('\n', '%%=char(10)=%%').replaceAll('\r', '\\\\r').replaceAll('"','\\"');
        
        String req = 'SELECT Id, Contact.Name,ContactId FROM CampaignMember WHERE CampaignId=:campaignId';
        if(status != null && status != ''){
            req+= ' AND Status=:status';
        }
        if(participation != null && participation !=''){
            req += ' AND MMPJ_Ext_Vign_Participation__c=:participation';
        }
        if(presence != null && presence !=''){
            req += ' AND MMPJ_Ext_Vign_Presence__c=:presence';
        }
        List<CampaignMember> cMembers = Database.query(req);
        List<Id> contactIds = new List<Id>();
        for(CampaignMember cMember : cMembers){
            contactIds.add(cMember.ContactId);
        }
        List<Contact> contacts = [
            SELECT Id,MMPJ_Ext_Vign_Telephone_portable_perso__c,Name,FirstName,LastName
            FROM Contact
            WHERE Id in :contactIds
        ];
        List<Contact> validContacts = new List<Contact>();
        for(Contact cont : contacts){
            System.debug('### ' +cont.MMPJ_Ext_Vign_Telephone_portable_perso__c);
            if(cont.MMPJ_Ext_Vign_Telephone_portable_perso__c!=null && cont.MMPJ_Ext_Vign_Telephone_portable_perso__c!=''){
                validContacts.add(cont);
            }
        }
        String token =MMPJ_XRM_MarketingCloudAPI.getToken();
        String errorMessage = '';
        errorMessage = MMPJ_XRM_MarketingCloudAPI.createSMSDefinition(token,messageEncode,messageName);
        System.debug('### '+errorMessage);
        if(errorMessage!=''){
            return errorMessage;
        }
        errorMessage = MMPJ_XRM_MarketingCloudAPI.sendSMS(token,validContacts,messageName,campaignId,message);
        System.debug('### '+errorMessage);
        if(errorMessage != ''){
            return errorMessage;
        }
        return '';
    }
}