global class LAT_VerifyPendingOpportunities implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        List<LAT_Opportunity__c> oppList = new List<LAT_Opportunity__c>();
        
        String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);
        //String[] mails  = LAT_GeneralConfigDao.getValueAsStringArray('OPP_Verification_Email_Recipients',',');

        DateTime dt = System.now();
        DateTime earlier = dt.addMinutes(-15);

        oppList = [SELECT Id, Name FROM LAT_opportunity__c WHERE LAT_StageName__c in ('Pedido enviado para o JDE', 'Pedido com erro no JDE') AND LAT_NROrderJDE__c = null AND lastmodifieddate < :earlier];

        String html = '';
        String subject = 'Verificacion de pedidos';

        if(!oppList.isEmpty() || test.isRunningTest()){

            html += 'Se han encontrado pedidos que necesitan de su atención: <br>';

            for(LAT_opportunity__c opp :oppList){


                html += ' - ' + opp.Name +' - https://' + URL.getSalesforceBaseUrl().getHost() + '/' + opp.id + '<br>';
            }

            html += '<br><br>Muchas gracias! <br><br>Equipo CRM ';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(mails);
            email.setSaveAsActivity(false);
            email.setHtmlBody(html);
            email.setBccSender(false);
            email.setSubject(subject);
            email.setUseSignature(false);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        }

        //VERIFY PENDING ACCOUNTS

        String pendingAccounts = LAT_GeneralConfig__c.getInstance('LAT_ACCOUNT_VERIFICATION_QUERY').LAT_Value__c;

        system.debug('query:' + pendingAccounts);

        List<Account> pendingAccountsList = Database.query(pendingAccounts);

        html = '';
        subject = 'Clientes pendientes de integracion';

        if(!pendingAccountsList.isEmpty() || test.isRunningTest()){

            html += 'Se han encontrado clientes que necesitan de su atención: <br>';

            for(Account acc :pendingAccountsList){

                html += ' - ' + acc.Name +' - https://' + URL.getSalesforceBaseUrl().getHost() + '/' + acc.id + '<br>';
            }

            html += '<br><br>Muchas gracias! <br><br>Equipo CRM ';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(mails);
            email.setSaveAsActivity(false);
            email.setHtmlBody(html);
            email.setBccSender(false);
            email.setSubject(subject);
            email.setUseSignature(false);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        }

        
    }
}