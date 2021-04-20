/**********************************************
 Dev: Waldemar Mayo     Version: 1
**********************************************/

global class PCS01_AnalyticsOfCCBatchAcc_AR implements Database.Batchable<sObject>,Database.Stateful {
    
    public map<Id, Account> mapIdAccountAccounts;
    public String emails;
    
    private String errors;
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        errors='';
        set<Id> setRts = mapIdAccountAccounts.keySet();
        return Database.getQueryLocator('SELECT Id, Overdue__c FROM Account WHERE Id IN: setRts');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> cuentas = (List<Account>)scope;
        for(Account acc: cuentas){
            acc.Overdue__c = mapIdAccountAccounts.get(acc.Id).Overdue__c;
        }
        try{
            update cuentas;
        }catch(exception e){
            errors += e.getMessage()+'<br/>';
        }
    }

    global void finish(Database.BatchableContext BC){
        
        String subject = '';
        String body = '';
        
        if(errors == ''){
            subject = PCS01_AnalyticsOfCCBatch_AR.strFecha(false)+' - SF Update – Analítico Cuenta Corriente - Cuentas - Éxito';
            body += 'El proceso "Analítico de Cuenta Corriente - Cuentas" fue ejecutado con éxito a las '+PCS01_AnalyticsOfCCBatch_AR.strFecha(true)+'.';
        }else{
            subject = PCS01_AnalyticsOfCCBatch_AR.strFecha(false)+' - SF Update – Analítico Cuenta Corriente - Cuenta - Error';
            body += 'El "Analítico de Cuenta Corriente - Cuentas" fue ejecutado con error a las '+PCS01_AnalyticsOfCCBatch_AR.strFecha(true)+'.<br/>';
            body += 'Detalle:<br/>';
            body += '<br/>';
            body += errors;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emails.split(','));
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }   
}