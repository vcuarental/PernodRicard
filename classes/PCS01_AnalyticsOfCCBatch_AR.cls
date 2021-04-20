/**********************************************
 Dev: Waldemar Mayo     Version: 1
**********************************************/

global class PCS01_AnalyticsOfCCBatch_AR implements Database.Batchable<sObject>,Database.Stateful {
    
    private map<Id, Account> mapIdAccountAccounts;
    private String errors;
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        mapIdAccountAccounts = new map<Id, Account>();
        errors='';
        
        RecordType rtAR = [select id, DeveloperName FROM RecordType WHERE SobjectType = 'Titulos__c'and DeveloperName = 'Standard_AR'];
        RecordType rtUY = [select id, DeveloperName FROM RecordType WHERE SobjectType = 'Titulos__c'and DeveloperName = 'Standard_UY'];
        set<Id> setRts = new set<Id>{rtAR.Id, rtUY.Id};
        return Database.getQueryLocator('SELECT Id, Name, Internal_id_pk__c, NetSRReceipts_AR__c, Status__c, Cliente__c, RecordTypeId FROM Titulos__c WHERE RecordTypeId IN: setRts');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Titulos__c> titulos = (List<Titulos__c>)scope;
        set<string> internalId = new set<string>();
        
        for(Titulos__c tit: titulos){
            internalId.add(tit.Internal_id_pk__c);
            if(tit.Cliente__c != null){
                if(!mapIdAccountAccounts.containsKey(tit.Cliente__c)){
                    if(tit.Status__c == true){
                        Account acc = new Account(id = tit.Cliente__c, Overdue__c = true);
                        mapIdAccountAccounts.put(tit.Cliente__c, acc);
                    }else{
                        Account acc = new Account (id = tit.Cliente__c, Overdue__c = false);
                        mapIdAccountAccounts.put(tit.Cliente__c, acc);
                    }
                }else if( tit.Status__c == true && mapIdAccountAccounts.get(tit.Cliente__c).Overdue__c == false ){
                    mapIdAccountAccounts.get(tit.Cliente__c).Overdue__c = true;
                }
            }
        }
        
        List<DCM_Documents_ARG__c>  documentos = [SELECT Id, Name, Internal_id_pk_AR__c, Amounttoapply_AR__c FROM DCM_Documents_ARG__c WHERE Internal_id_pk_AR__c IN: internalId AND DocAppliedinJDE_AR__c = false AND Amounttoapply_AR__c != null];
        if(documentos.isEmpty()){
            return;
        }
        
        map<String, Decimal> mapIdPk = new map<String, Decimal>();
        Map<String, List<DCM_Documents_ARG__c>> mapTituloListDocumentos = new Map<String, List<DCM_Documents_ARG__c>>();
        for(DCM_Documents_ARG__c doc: documentos){
            if(mapTituloListDocumentos.containskey(doc.Internal_id_pk_AR__c)){
                mapTituloListDocumentos.get(doc.Internal_id_pk_AR__c).add(doc);
            }else{
                mapTituloListDocumentos.put(doc.Internal_id_pk_AR__c, new List<DCM_Documents_ARG__c>{doc});
            }
        }
        List<Titulos__c> titulosToUpdate = new List<Titulos__c>();
        for(Titulos__c tit: titulos){
            if(mapTituloListDocumentos.containskey(tit.Internal_id_pk__c)){
                Decimal amountToApply = 0;
                for(DCM_Documents_ARG__c d: mapTituloListDocumentos.get(tit.Internal_id_pk__c)){
                     amountToApply += d.Amounttoapply_AR__c;
                }
                tit.NetSRReceipts_AR__c = amountToApply;
                titulosToUpdate.add(tit);
            }
        }
        
        if(titulosToUpdate.size() > 0){
            try{
                update titulosToUpdate;
            }catch(exception e){
                errors += e.getMessage()+'<br/>';
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        
        CS005_Emails__c mails = CS005_Emails__c.getInstance('UpdateOfAnalyticsofCC');
        String emails = '';
        
        if(mails!=null){
            if(mails.Emails__c!=null){
                emails = mails.Emails__c;
            }
        }
        if(emails == ''){
            emails = UserInfo.getUserEmail();
        }
        
        if(errors == ''){
            if(mapIdAccountAccounts.values().size() > 0){
                DateTime nowTime = datetime.now().addSeconds(65);
				String Seconds = '0';
				String Minutes = String.valueOf(nowTime.minute()).length() == 1 ? '0' + String.valueOf(nowTime.minute()) : String.valueOf(nowTime.minute());
				String Hours = String.valueOf(nowTime.hour()).length() == 1 ? '0' + String.valueOf(nowTime.hour()) : String.valueOf(nowTime.hour());
				String DayOfMonth = String.valueOf(nowTime.day());
				String Month = String.ValueOf(nowTime.month());
				String DayOfweek = '?';
				String optionalYear = String.valueOf(nowTime.year());
				String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
				
				PCS01_AnalyticsOfCCBatchAccSche_AR schAcc = new PCS01_AnalyticsOfCCBatchAccSche_AR();
				schAcc.mapIdAccountAccounts = mapIdAccountAccounts;
				schAcc.emails = emails;
				system.schedule('Analítico de Cuenta Corriente - Cuentas '+System.now(), CronExpression, schAcc);
            }
        }
        
        String subject = '';
        String body = '';
        
        if(errors == ''){
            subject = strFecha(false)+' - SF Update – Analítico Cuenta Corriente - Éxito';
            body += 'El "Analítico de Cuenta Corriente" fue ejecutado con éxito a las '+strFecha(true)+'.';
            body += '<br/>';
            body += '<br/>';
            if(mapIdAccountAccounts.values().size() > 0){
                body += '<b>Se agendó el proceso para actualizar '+mapIdAccountAccounts.values().size()+' cuenta/s, recibirá un correo cuando finalice.</b>';
            }
        }else{
            subject = strFecha(false)+' - SF Update – Analítico Cuenta Corriente - Error';
            body += 'El "Analítico de Cuenta Corriente" fue ejecutado con error a las '+strFecha(true)+'.<br/>';
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
    
    public static String strFecha(Boolean withTime){
        DateTime fecha = datetime.now();
        String strReturn='';
        strReturn += fecha.day()<10?('0'+fecha.day()):(String.ValueOf(fecha.day()));
        strReturn += '/';
        strReturn += fecha.month()<10?('0'+fecha.month()):(String.ValueOf(fecha.month()));
        strReturn += '/';
        strReturn += fecha.year();
        if(withTime){
            strReturn += ' ';
            strReturn += fecha.hour()<10?('0'+fecha.hour()):(String.ValueOf(fecha.hour()));
            strReturn += ':';
            strReturn += fecha.minute()<10?('0'+fecha.minute()):(String.ValueOf(fecha.minute()));
            strReturn += ':';
            strReturn += fecha.second()<10?('0'+fecha.second()):(String.ValueOf(fecha.second()));
        }
        return strReturn;
    }
    
}