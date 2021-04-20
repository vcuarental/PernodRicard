global class MMPJ_XRM_SMSStatusBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public String query;
  
    global MMPJ_XRM_SMSStatusBatch() {
        query = 'SELECT Id,MMPJ_XRM_Contact__c,MMPJ_XRM_SMS_Envoye__c,MMPJ_XRM_SMS_Message_Key__c,MMPJ_XRM_Statut__c FROM MMPJ_XRM_SMS__c WHERE MMPJ_XRM_Statut__c=null OR MMPJ_XRM_Statut__c=\'\'';
        /* WHERE MMPJ_XRM_Date_envoi__c='+DateTime.newInstance(dateEnvoi.year(), dateEnvoi.month(),dateEnvoi.day()).format('yyyy-MM-dd');*/
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<MMPJ_XRM_SMS__c> scope) {
        String token = MMPJ_XRM_MarketingCloudAPI.getToken();
        Map<Id,Integer> nbSMSSentBySMSCampaign = new Map<Id,Integer>();
        List<MMPJ_XRM_SMS__c> smsUpdate = new List<MMPJ_XRM_SMS__c>();
        for(MMPJ_XRM_SMS__c sms : scope){
            Map<String,Object> mapResp = MMPJ_XRM_MarketingCloudAPI.getSMSStatus(token, sms.MMPJ_XRM_SMS_Message_Key__c);
            String status =(String) mapResp.get('eventCategoryType');
            if(status!=null && status !=''){
                if(status == 'TransactionalSendEvents.SMSSent'){
                    sms.MMPJ_XRM_Statut__c = 'Envoyé';
                }else if(status == 'TransactionalSendEvents.SMSQueued'){
                    sms.MMPJ_XRM_Statut__c = 'En attente';
                }else if(status == 'TransactionalSendEvents.SMSNotSent'){
                    sms.MMPJ_XRM_Statut__c = 'Non envoyé';
                    sms.MMPJ_XRM_Message__c = (String) mapResp.get('statusMessage');
                }
                System.debug('### '+ mapResp);
                Map<String,Object> infos = (Map<String,Object>) mapResp.get('info');
                if(infos !=null){
                    sms.MMPJ_XRM_Contact__c = (Id)infos.get('contactKey');
                }
                
                smsUpdate.add(sms);
            }
        }
        update smsUpdate;
    }

    global void finish(Database.BatchableContext BC) {  
    }
}