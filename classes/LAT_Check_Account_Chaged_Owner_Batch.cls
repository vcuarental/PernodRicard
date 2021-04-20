global class LAT_Check_Account_Chaged_Owner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    String query;
    Map <Id, Id> accountNewOwner = new Map<Id, Id>();
    Set <Id> accounts = new Set <Id>();
    Map<Id, Lat_Account__c> mapLatAccount = new Map<Id, Lat_Account__c>();
    String[] sizes = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_OWNER_UPDATE_Batch', ' ');
    Integer batchSize = sizes != null ?  Integer.valueOf(sizes[0]) : 1;

    global LAT_Check_Account_Chaged_Owner_Batch() {

        query = 'Select id, LAT_Accountid__c, LAT_Accountid__r.ownerid, LAT_Owner_Changed__c From LAT_Account__c Where LAT_Owner_Changed__c =' + true;
        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List <LAT_Account__c> lat_Accounts = (List<Lat_Account__c>)scope;
    
        for(LAT_Account__c latacc :lat_Accounts){

            system.debug('CAMBIÓ OWNER: acc id: ' + latacc.LAT_Accountid__c + ' lat_account: ' + latacc);
            mapLatAccount.put(latacc.LAT_Accountid__c, latacc);
            
        }

        
    
    }
    
    global void finish(Database.BatchableContext BC) {
        String errorMsg = '';
        try {
            if(!mapLatAccount.isEmpty()){
                Database.executeBatch(new LAT_UpdateLAT_OpportunityOwner_Batch(mapLatAccount), 200);//OK
                Database.executeBatch(new LAT_UpdateLAT_CaseOwner_Batch(mapLatAccount), 200);//OK
                Database.executeBatch(new LAT_UpdateContactOwner_Batch(mapLatAccount), 200);//OK
                Database.executeBatch(new LAT_UpdateVisitasOwner_Batch(mapLatAccount), 200);
                Database.executeBatch(new LAT_UpdateLATContract2Owner_Batch(mapLatAccount), 20);
                Database.executeBatch(new LAT_UpdateFiscalNoteOwner_Batch(mapLatAccount), 200);
                Database.executeBatch(new LAT_UpdateSellOutColletOwner_Batch(mapLatAccount), 200);
                Database.executeBatch(new LAT_UpdateInventarioPOPOwner_Batch(mapLatAccount), 200);
                Database.executeBatch(new LAT_ClientChannelSegmOwner_Batch(mapLatAccount), 1);
                Database.executeBatch(new LAT_ClientChannelSegmResultOwner_Batch(mapLatAccount), 1);

            }
            for(LAT_Account__c latacc :mapLatAccount.values()){
                latacc.LAT_Owner_Changed__c = false;
            }
            if(mapLatAccount.size()>0)
                update mapLatAccount.values();
        } catch(Exception e) {
            errorMsg = e.getStackTraceString();
            errorMsg += '<br>'+e.getMessage();
            errorMsg += '<br>'+e.getLineNumber();
        } finally {
            if(mapLatAccount.size()>0) {
                String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
                System.debug('%%%%% strMails : '+strMails);
                String[] mails  = strMails.split(',');
                System.debug('%%%%% mails : '+mails);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String html = 'Estimados, <br> Se procesaron los siguientes ids de Clientes por cambio de Owner. <br>';
                for(LAT_Account__c latacc : mapLatAccount.values()){
                    html += '<br> - Cliente: ' +latacc.LAT_Accountid__c + ' || Owner nuevo : '+ latacc.LAT_Accountid__r.Ownerid + '.';
                }

                html += (errorMsg == '')? '<br>No se encontraron Errores.<br>' : '<br>Se encontraron los siguientes errores : <br>' + errorMsg +'<br>';
                html += '<br> Saludos, <br> <br> Equipo CRM.';  
                email.setToAddresses( mails );
                email.setSaveAsActivity(false);
                email.setHtmlBody(html);
                email.setBccSender(false);
                email.setSubject('Se procesaron clientes por cambio de Owner');
                email.setUseSignature(false);
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
        

                
    }
    
}