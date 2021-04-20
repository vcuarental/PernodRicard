public without sharing class LAT_RecordIntegrationVerifications {
  
  public static void verifyOpportunitiesIntegration() {
    List<LAT_Opportunity__c> oppList = new List<LAT_Opportunity__c>();
        
        String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);
        List<String> strStatus = LAT_GeneralConfig__c.getInstance('OPP_Verification_StatusToCheck').LAT_Value__c.split(',');
        System.debug('%%%% strStatus : ' + strStatus);        
        //'Pedido enviado para o JDE', 'Pedido com erro no JDE', 'Mobile Order', 'Moblie Order Sent To JDE'
        //String[] mails  = LAT_GeneralConfigDao.getValueAsStringArray('OPP_Verification_Email_Recipients',',');

        DateTime dt = System.now();
        DateTime earlier = dt.addMinutes(-15);

        oppList = [SELECT Id, Name FROM LAT_opportunity__c WHERE LAT_StageName__c IN :strStatus AND LAT_NROrderJDE__c = null AND lastmodifieddate < :earlier];

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

    }
  

  public static void verifyAccountsIntegration() {
    //VERIFY PENDING ACCOUNTS
    String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);
        String pendingAccounts = LAT_GeneralConfig__c.getInstance('LAT_ACCOUNT_VERIFICATION_QUERY').LAT_Value__c;

        system.debug('query:' + pendingAccounts);

        List<Account> pendingAccountsList = Database.query(pendingAccounts);

        String html = '';
        String subject = 'Clientes pendientes de integracion';

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
            if(!Test.isRunningTest()) {
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
            }
            
    }
  }

    public static void verifyDocusignUsers() {
        //VERIFY Docusign users
        String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);

        LAT_Docusign_Config__c cs = LAT_Docusign_Utils.getDocusignConfig();
        Map<String, String> idsToVerify = new Map<String, String>();
        idsToVerify.put('LAT_ComercialDirectorId', cs.LAT_ComercialDirectorId__c);
        idsToVerify.put('LAT_PresidentId', cs.LAT_PresidentId__c);
        idsToVerify.put('LAT_TradeManagerId', cs.LAT_TradeManagerId__c);
        idsToVerify.put('LAT_ComercialDirectorId_PRESTIGE', cs.LAT_ComercialDirectorId_PRESTIGE__c);
        idsToVerify.put('LAT_FinancialDirectorId', cs.LAT_FinancialDirectorId__c);
        idsToVerify.put('LAT_Testemunha_PRB_Id_PRESTIGE', cs.LAT_Testemunha_PRB_Id_PRESTIGE__c);
        idsToVerify.put('Testemunha PRB Id', cs.LAT_Testemunha_PRB_Id__c);
        system.debug('idsToVerify:' + idsToVerify);

        List<User> usersToVerfify = [SELECT Id, Name,  IsActive FROM User WHERE Id IN :idsToVerify.values() ];


        String html = '';
        String subject = 'Alerta Signatários Inativos em Docusign';
        Boolean enviar = false;


        html += 'Foram encontrados os seguintes usuários que estão inativos e associados como Signatários em Docusign.<br>Favor substituir os mesmos por um Id de usuário Ativo:: <br> <br>';

        for(User u :usersToVerfify){
            if(u.isActive == false ) {
                enviar = true;
                html += ' - ' + u.Name +' (Id : '+ u.Id +'). Campos: ' ;

                for (String s : idsToVerify.keySet()) {
                    if(String.valueOf(u.Id).startsWith(idsToVerify.get(s))){
                        html += s + ' '; 
                    }
                }
                 html += '<br> ';
            }
            
        }
        html += ' <br> <br> Link Docusing Config :  https://' + URL.getSalesforceBaseUrl().getHost() + '/setup/ui/listCustomSettingsData.apexp?id=' + LAT_Docusign_Config__c.sObjectType.getDescribe().getKeyPrefix() + '<br> <br>';
        html += '<br><br>Muito obrigado,<br><br>CRM Team';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(mails);
        email.setSaveAsActivity(false);
        email.setHtmlBody(html);
        email.setBccSender(false);
        email.setSubject(subject);
        email.setUseSignature(false);
        if(enviar) {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
        }
        
        
    }

    public static void verifyApprovalsUsers() {
        //VERIFY Approval Active Users
        

        String objectsToSearch = LAT_GeneralConfig__c.getInstance('APPROVAL_SLA_OBJECTS').LAT_Value__c;
        Datetime lastRun = Datetime.now().addMinutes(-15);


        String query = 'SELECT ProcessInstanceid, ProcessInstance.targetobject.name, Actor.email, ActorId, ProcessInstance.ProcessDefinition.TableEnumOrId, ProcessInstance.ProcessDefinitionId, ProcessInstance.targetobjectid, CreatedDate,ProcessInstance.Status FROM ProcessInstanceWorkitem where ';
        query += ' ProcessInstance.ProcessDefinition.TableEnumOrId IN ('+ objectsToSearch +') AND Createddate >= '+lastRun.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        System.debug('%%%% query : ' + query);
        
        List<ProcessInstanceWorkitem> instances = Database.Query(query);
        System.debug('%%%%% instances : ' + instances);
        Map<Id, ProcessInstanceWorkitem> mapInstancesByUser = new Map<Id, ProcessInstanceWorkitem>();
        for(ProcessInstanceWorkitem wi : instances) {
            mapInstancesByUser.put(wi.ActorId, wi);

        }   

        List<User> usersToVerfify = [SELECT Id, Name,  IsActive FROM User WHERE Id IN :mapInstancesByUser.keySet()];


        String html = '';
        String subject = 'Alerta Usuários Inativos em Processos de Aprovação';
        Boolean enviar = false;


        html += 'Foram encontrados os seguintes usuários que estão inativos e associados como aprovadores em Processos de Aprovação.<br>Favor substituir os mesmos por um usuário Ativo e reatribuir as aprovações pendentes: <br> <br>';

        for(User u :usersToVerfify){
            if(u.isActive == false ) {
                enviar = true;
                html += ' - ' + u.Name +' (Id : '+ u.Id +'):<br>';
                html += '         Registro: https://' + URL.getSalesforceBaseUrl().getHost() + '/' + mapInstancesByUser.get(u.Id).ProcessInstance.targetobjectid+ '<br>';
                html += '         Processo de Aprovação: https://' + URL.getSalesforceBaseUrl().getHost() + '/' + mapInstancesByUser.get(u.Id).ProcessInstance.ProcessDefinitionId+ '<br>';

                html += '<br> ';
            }
            
        }
        html += '<br><br>Muito obrigado, <br><br>CRM Team';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(getAdminEmails());
        email.setSaveAsActivity(false);
        email.setHtmlBody(html);
        email.setBccSender(false);
        email.setSubject(subject);
        email.setUseSignature(false);
        if(enviar) {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
        } 
    }

    public static String[] getAdminEmails(){
        String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);
        return mails;
    }

    public static void verifyBrasilUsers() {
        
        List<LAT_GeneralConfig__c> configs = [SELECT LAT_Value__c FROM LAT_GeneralConfig__c WHERE Name LIKE 'USERS_TO_BYPASSVALIDATIONS%'];
        List<String> idsToByPass = new List<String>();
        for(LAT_GeneralConfig__c c : configs){
            String[] values  = c.LAT_Value__c.split(',');
            System.debug('%%%%%% values : ' + values);
            idsToByPass.addAll(values);
        }
        LAT_GeneralConfig__c cs = [SELECT LAT_Value__c FROM LAT_GeneralConfig__c WHERE Name = 'BRASIL_USER_VERIFICATION_PROFILES' LIMIT 1];
        List<String> profilesToVerify = new List<String>();
        String[] profs  = cs.LAT_Value__c.split(',');
        System.debug('%%%%%% profs : ' + profs);
        profilesToVerify.addAll(profs);

        List<User> toVerfiy = [SELECT Id, DefaultCurrencyIsoCode, Name, Gerente_regional__r.Name, Gerente_regional__r.IsActive, ManagerId, Manager.IsActive, Manager.Name, Gerente_regional__c, 
                                C_digo_JDE__c, Profile.Name FROM User WHERE IsActive = true AND Profile.Name IN :profilesToVerify AND ID NOT IN :idsToByPass ];
        
        String message = '';        
        for (User u : toVerfiy) {
            if(u.ManagerId != null){
                if(!u.Manager.IsActive){
                    message += '<br> - El Manager (' + u.Manager.Name + ') de '+ u.Name + ' está Inactivo, revíselo por favor (Id : ' + u.Id + ').';
                }
            } else {
                message += '<br> - El Usuario '+ u.Name + ' no tiene Mánager, por favor solicite a Active Directory que lo setee según indique RRHH.';
            }
            
            if(u.Gerente_regional__c != null){
                if(!u.Gerente_regional__r.IsActive){
                    message += '<br> - El Gerente Regional (' + u.Gerente_regional__r.Name + ') de '+ u.Name + ' está Inactivo, revíselo por favor (Id : ' + u.Id + ').';
                }
            } else {
                message += '<br> - El Usuario '+ u.Name + ' no tiene Gerente Regional, revíselo por favor (Id : ' + u.Id + ').';
            }
            
            if(u.C_digo_JDE__c == null && u.Profile.Name == 'LAT_BR2_Vendas'){
                message += '<br> - El Usuario '+ u.Name + ' no tiene asignado Código de JDE, revíselo por favor (Id : ' + u.Id + ').';
            }
            if(u.DefaultCurrencyIsoCode <> 'BRL'){
                message += '<br> - El Usuario '+ u.Name + ' tiene Moneda '+ u.DefaultCurrencyIsoCode +' cuando debería tener BRL, revíselo por favor (Id : ' + u.Id + ').';
            }
        }   
    
        String html = '';
        String subject = 'Usuarios de Brasil que necesitan revisión';
        

        if(message != '') {
            html += 'Se han encontrado los siguientes usuarios de Brasil que tienen datos inconsistentes: <br> <br>';

            html += message;
            html += '<br><br>Muchas gracias! <br><br>Equipo CRM ';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(getAdminEmails());
            email.setSaveAsActivity(false);
            email.setHtmlBody(html);
            email.setBccSender(false);
            email.setSubject(subject);
            email.setUseSignature(false);
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
            
        }
        
    }

    public static void verifyManagerFieldsInContracts(){

        List<LAT_Contract2__c> contractsToVerfiy = [SELECT Id, Name, Manager__c, OwnerId, RegionalManager__c, RegionalManager__r.IsActive, Manager__r.IsActive
                FROM LAT_Contract2__c WHERE Status__c <> 'Encerrado' AND Status__c <> 'Cancelado'];
        Set<Id> ownerIds = new Set<Id>();
        for (LAT_Contract2__c con : contractsToVerfiy) {
            ownerIds.add(con.OwnerId);
        }   

        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Name, ManagerId, Manager.IsActive, Manager.Name, Gerente_regional__c, Gerente_regional__r.Name,
                Gerente_regional__r.IsActive FROM User WHERE Id IN :ownerIds ]);
        
        String message = '';      
        String errors = ''; 
        List<LAT_Contract2__c> toUpdate = new List<LAT_Contract2__c>(); 
        for (LAT_Contract2__c con : contractsToVerfiy) {
            Boolean hasChanged = false;
            if(con.Manager__c != null){
                if(con.Manager__c <> usersMap.get(con.OwnerId).ManagerId){
                    con.Manager__c = usersMap.get(con.OwnerId).ManagerId;
                    hasChanged = true;
                } else {
                    if(!con.Manager__r.IsActive){
                        message += '<br> - El Contrato '+ con.Name + ' tiene Mánager inactivo, ya que está inactivo el Manager ('+ usersMap.get(con.OwnerId).Manager.Name +') del dueño del contrato (' + usersMap.get(con.OwnerId).Name +'), por favor revíselo.';
                    }
                }
            } else {
                if(usersMap.get(con.OwnerId).ManagerId != null){
                    if(usersMap.get(con.OwnerId).Manager.IsActive){
                        con.Manager__c = usersMap.get(con.OwnerId).ManagerId;
                        hasChanged = true;
                    } else {
                        message += '<br> - El Contrato '+ con.Name + ' no tiene Mánager, ya que está inactivo el Manager ('+ usersMap.get(con.OwnerId).Manager.Name +') del dueño del contrato (' + usersMap.get(con.OwnerId).Name +'), por favor revíselo.';
                    }
                } else {
                    message += '<br> - El Contrato '+ con.Name + ' no tiene Mánager, ya que está vacío el campo Manager del dueño del contrato (' + usersMap.get(con.OwnerId).Name +'), por favor revíselo.';

                }
                
            }
            
            if(con.RegionalManager__c != null){
                if(con.RegionalManager__c <> usersMap.get(con.OwnerId).Gerente_regional__c){
                    con.RegionalManager__c = usersMap.get(con.OwnerId).Gerente_regional__c;
                    hasChanged = true;
                } else {
                    if(!con.Manager__r.IsActive){
                        message += '<br> - El Contrato '+ con.Name + ' tiene Mánager inactivo, ya que está inactivo el Manager ('+ usersMap.get(con.OwnerId).Manager.Name +') del dueño del contrato (' + usersMap.get(con.OwnerId).Name +'), por favor revíselo.';
                    }
                }
            } else {
                if(usersMap.get(con.OwnerId).Gerente_regional__c != null){
                    if(usersMap.get(con.OwnerId).Gerente_regional__r.IsActive){
                        con.RegionalManager__c = usersMap.get(con.OwnerId).Gerente_regional__c;
                        hasChanged = true;
                    } else {
                        message += '<br> - El Contrato '+ con.Name + ' no tiene Mánager, ya que está inactivo el Manager ('+ usersMap.get(con.OwnerId).Gerente_regional__r.Name +') del dueño del contrato (' + usersMap.get(con.OwnerId).Name +'), por favor revíselo.';
                    }
                } else {
                    message += '<br> - El Contrato '+ con.Name + ' no tiene Mánager, ya que está vacío el campo Manager del dueño del contrato (' + usersMap.get(con.OwnerId).Name +'), por favor revíselo.';

                }
                
            }    
            if(hasChanged) {
                toUpdate.add(con);
                message += '<br> - El Contrato '+ con.Name + '  fue actualizado con el Manager/Regional Manager Correcto.';
            }
        }   
        
        try{
            if(toUpdate.size() > 0) {
                update toUpdate;
                message += '<br><br> - Cantidad de Contratos actualizados : '+ toUpdate.size();
            }
        } catch(Exception e){
            errors = '<br> - Errores : '+ e.getStackTraceString()+ ' || ' + e.getCause() + '||'+ e.getLineNumber();
        } 
         


        
        String html = '';
        String subject = 'Revisión de Registros de Contratos - Brasil';
        

        if(message != '') {
            html += 'Se procesaron los registros de contratos de Brasil con los siguientes resultados: <br> <br>';

            html += message;
            if(errors != '') {
                html += '<br><br>El update de Contratos arrojó los siguientes errores : <br> ' + errors;
            }
            html += '<br><br>Muchas gracias! <br><br>Equipo CRM ';


            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(getAdminEmails());
            email.setSaveAsActivity(false);
            email.setHtmlBody(html);
            email.setBccSender(false);
            email.setSubject(subject);
            email.setUseSignature(false);
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
            
        }
    }

    public static void verifyManagerFieldsInPayments(){

        List<LAT_Payment__c> paymentsToVerfiy = [SELECT Id, Name, Manager__c, LAT_Contract__r.OwnerId, RegionalManager__c, RegionalManager__r.IsActive, Manager__r.IsActive
                FROM LAT_Payment__c WHERE Status__c IN ('P', 'R') Order By Lastmodifieddate DESC];
        Set<Id> ownerIds = new Set<Id>();
        for (LAT_Payment__c pay : paymentsToVerfiy) {
            ownerIds.add(pay.LAT_Contract__r.OwnerId);
        }   

        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Name, ManagerId, Manager.IsActive, Manager.Name, Gerente_regional__c, Gerente_regional__r.Name,
                Gerente_regional__r.IsActive FROM User WHERE Id IN :ownerIds ]);
        
        String message = '';      
        String errors = ''; 
        List<LAT_Payment__c> toUpdate = new List<LAT_Payment__c>(); 
        for (LAT_Payment__c pay : paymentsToVerfiy) {
            Boolean hasChanged = false;
            if(pay.Manager__c != null){
                if(pay.Manager__c <> usersMap.get(pay.LAT_Contract__r.OwnerId).ManagerId){
                    pay.Manager__c = usersMap.get(pay.LAT_Contract__r.OwnerId).ManagerId;
                    hasChanged = true;
                } else {
                    if(!pay.Manager__r.IsActive){
                        message += '<br> - El Pagamento '+ pay.Name + ' tiene Mánager inactivo, ya que está inactivo el Manager ('+ usersMap.get(pay.LAT_Contract__r.OwnerId).Manager.Name +') del dueño del contrato (' + usersMap.get(pay.LAT_Contract__r.OwnerId).Name +'), por favor revíselo.';
                    }
                }
            } else {
                if(usersMap.get(pay.LAT_Contract__r.OwnerId).ManagerId != null){
                    if(usersMap.get(pay.LAT_Contract__r.OwnerId).Manager.IsActive){
                        pay.Manager__c = usersMap.get(pay.LAT_Contract__r.OwnerId).ManagerId;
                        hasChanged = true;
                    } else {
                        message += '<br> - El Pagamento '+ pay.Name + ' no tiene Mánager, ya que está inactivo el Manager ('+ usersMap.get(pay.LAT_Contract__r.OwnerId).Manager.Name +') del dueño del contrato (' + usersMap.get(pay.LAT_Contract__r.OwnerId).Name +'), por favor revíselo.';
                    }
                } else {
                    message += '<br> - El Pagamento '+ pay.Name + ' no tiene Mánager, ya que está vacío el campo Manager del dueño del contrato (' + usersMap.get(pay.LAT_Contract__r.OwnerId).Name +'), por favor revíselo.';

                }
                
            }
            
            if(pay.RegionalManager__c != null){
                if(pay.RegionalManager__c <> usersMap.get(pay.LAT_Contract__r.OwnerId).Gerente_regional__c){
                    pay.RegionalManager__c = usersMap.get(pay.LAT_Contract__r.OwnerId).Gerente_regional__c;
                    hasChanged = true;
                } else {
                    if(!pay.Manager__r.IsActive){
                        message += '<br> - El Pagamento '+ pay.Name + ' tiene Mánager inactivo, ya que está inactivo el Manager ('+ usersMap.get(pay.LAT_Contract__r.OwnerId).Manager.Name +') del dueño del contrato (' + usersMap.get(pay.LAT_Contract__r.OwnerId).Name +'), por favor revíselo.';
                    }
                }
            } else {
                if(usersMap.get(pay.LAT_Contract__r.OwnerId).Gerente_regional__c != null){
                    if(usersMap.get(pay.LAT_Contract__r.OwnerId).Gerente_regional__r.IsActive){
                        pay.RegionalManager__c = usersMap.get(pay.LAT_Contract__r.OwnerId).Gerente_regional__c;
                        hasChanged = true;
                    } else {
                        message += '<br> - El Pagamento '+ pay.Name + ' no tiene Mánager, ya que está inactivo el Manager ('+ usersMap.get(pay.LAT_Contract__r.OwnerId).Gerente_regional__r.Name +') del dueño del contrato (' + usersMap.get(pay.LAT_Contract__r.OwnerId).Name +'), por favor revíselo.';
                    }
                } else {
                    message += '<br> - El Pagamento '+ pay.Name + ' no tiene Mánager, ya que está vacío el campo Manager del dueño del contrato (' + usersMap.get(pay.LAT_Contract__r.OwnerId).Name +'), por favor revíselo.';

                }
                
            }    
            if(hasChanged) {
                toUpdate.add(pay);
                message += '<br> - El Pagamento '+ pay.Name + '  fue actualizado con el Manager/Regional Manager Correcto.';
            }
            if(toUpdate.size() >100) break;
        }   
        
        try{
            if(toUpdate.size() > 0) {
                update toUpdate;
                message += '<br><br> - Cantidad de Pagamentos actualizados : '+ toUpdate.size();
            }
        } catch(Exception e){
            errors = '<br> - Errores : '+ e.getStackTraceString()+ ' || ' + e.getCause() + '||'+ e.getLineNumber();
        } 
         


        
        String html = '';
        String subject = 'Revisión de Registros de Pagamento - Brasil';
        

        if(message != '') {
            html += 'Se procesaron los registros de pagamentos de Brasil con los siguientes resultados: <br> <br>';

            html += message;
            if(errors != '') {
                html += '<br><br>El update de Pagamento arrojó los siguientes errores : <br> ' + errors;
            }
            html += '<br><br>Muchas gracias! <br><br>Equipo CRM ';


            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(getAdminEmails());
            email.setSaveAsActivity(false);
            email.setHtmlBody(html);
            email.setBccSender(false);
            email.setSubject(subject);
            email.setUseSignature(false);
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
            
        }
    }

    public static void notifyGroupsProductWithoutChilds() {
        List<LAT_ReferenceProductGrouping__c> lstVolumeContrato = null;
        List<LAT_ReferenceProductGrouping__c> lstProductPayment = null;
        List<LAT_ReferenceProductGrouping__c> lstColetaNF = null;
        String strRecordType = null;
        String strHTMLSubject = null;
        String strHTMLBody = null;

        System.debug('notifyGroupsProductWithoutChilds [] ->');
        
        lstVolumeContrato = retrieveGroupsProductWithoutChilds('LAT_ContractVolume');
        lstProductPayment = retrieveGroupsProductWithoutChilds('LAT_ProductPayment');
        lstColetaNF = retrieveGroupsProductWithoutChilds('LAT_Sellin');

        if(!lstVolumeContrato.IsEmpty()) {
            strHTMLSubject = 'PR - Notificacion - Agrupamientos sin productos';
            strHTMLBody = retrieveErrorsContractVolume(lstVolumeContrato);
            strHTMLBody += retrieveErrorsColetaNF(lstColetaNF);
            strHTMLBody += retrieveErrorsPagamentoProducto(lstProductPayment);
           

            LAT_Utils.sendEmail('Pernod Ricard', 'matias@zimmic.com', strHTMLSubject, strHTMLBody);
        }

        System.debug('notifyGroupsProductWithoutChilds [] <-');    
    }

    public static List<LAT_ReferenceProductGrouping__c> retrieveGroupsProductWithoutChilds(String strRecordType) {
        List<LAT_ReferenceProductGrouping__c> lstGrouping = null;

        System.debug('retrieveGroupsProductWithoutChilds [strRecordType : ' + strRecordType + '] ->');

        lstGrouping = [ SELECT ID, Name, (SELECT Id FROM  LAT_ProductCosts__r LIMIT 1), 
                        (   SELECT RecordType.DeveloperName 
                            FROM ReferenceProductGroupChilds__r 
                            WHERE RecordType.DeveloperName = 'LAT_ProductPayment' 
                            OR  RecordType.DeveloperName = 'LAT_Sellin' 
                            ORDER BY RecordType.DeveloperName ASC), 
                        ( SELECT Id FROM LAT_ReferenceProducts__r) 
                        FROM LAT_ReferenceProductGrouping__c 
                        WHERE RecordType.DeveloperName = :strRecordType];

        System.debug('retrieveGroupsProductWithoutChilds [' + lstGrouping + '] <-');    
        return lstGrouping;
    }

    @testVisible
    private static String retrieveErrorsContractVolume(List<LAT_ReferenceProductGrouping__c> lstGrouping) {
        Boolean boolHasColetaNF = false;
        Boolean boolHasPagamentoProduto = false;
        String strHTML = null;
        String strHTMLBody = null;

        System.debug('retrieveErrorsContractVolume [lstGrouping : ' + lstGrouping + '] ->');
        if(lstGrouping != NULL && !lstGrouping.isEmpty()) {
            strHTML = '';
            for(LAT_ReferenceProductGrouping__c objGroup : lstGrouping) {
                if(objGroup.LAT_ProductCosts__r.size() == 0) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene costo relacionado</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }

                if(objGroup.LAT_ReferenceProducts__r.size() == 0) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene producto de referencia relacionado</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }

                boolHasColetaNF = false;
                boolHasPagamentoProduto = true; //esto no se valida mas
                for(LAT_ReferenceProductGrouping__c objProductReference : objGroup.ReferenceProductGroupChilds__r) {
                    if(objProductReference.RecordType.DeveloperName == 'LAT_ProductPayment') {
                        boolHasPagamentoProduto = true;
                    } else if (objProductReference.RecordType.DeveloperName == 'LAT_Sellin') {
                        boolHasColetaNF = true;
                    }                    
                }

                if(!boolHasColetaNF) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene coleta NF asociada</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }

                if(!boolHasPagamentoProduto) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene pagamento producto asociado</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }
            }
        }
        if(String.isNotBlank(strHTML)) {
            strHTMLBody = 'Los siguientes agrupamientos no son válidos : <br />';
            strHTMLBody += '<ul>';
            strHTMLBody += strHTML;
            strHTMLBody += '</ul>';
        } else {
            strHTMLBody = '';
        }
 
        System.debug('retrieveErrorsContractVolume [' + strHTMLBody + '] <-');

        return strHTMLBody;
    }
	
    @testVisible
    private static String retrieveErrorsColetaNF(List<LAT_ReferenceProductGrouping__c> lstGrouping) {
        Boolean boolHasColetaNF = false;
        Boolean boolHasPagamentoProduto = false;
        String strHTML = null;
        String strHTMLBody = null;

        System.debug('retrieveErrorsColetaNF [lstGrouping : ' + lstGrouping + '] ->');
        if(lstGrouping != NULL && !lstGrouping.isEmpty()) {
            strHTML = '';
            for(LAT_ReferenceProductGrouping__c objGroup : lstGrouping) {
                if(objGroup.LAT_ProductCosts__r.size() == 0) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene costo relacionado</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }

                if(objGroup.LAT_ReferenceProducts__r.size() == 0) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene producto de referencia relacionado</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }
            }
        }

        if(String.isNotBlank(strHTML)) {
            strHTMLBody = 'Los siguientes coletas no son válidas : <br />';
            strHTMLBody += '<ul>';
            strHTMLBody += strHTML;
            strHTMLBody += '</ul>';
        } else {
            strHTMLBody = '';
        }
 
        System.debug('retrieveErrorsColetaNF [' + strHTMLBody + '] <-');

        return strHTMLBody;
    }
	
    @testVisible
    private static String retrieveErrorsPagamentoProducto(List<LAT_ReferenceProductGrouping__c> lstGrouping) {
        Boolean boolHasColetaNF = false;
        Boolean boolHasPagamentoProduto = false;
        String strHTML = null;
        String strHTMLBody = null;

        System.debug('retrieveErrorsPagamentoProducto [lstGrouping : ' + lstGrouping + '] ->');
        if(lstGrouping != NULL && !lstGrouping.isEmpty()) {
            strHTML = '';
            for(LAT_ReferenceProductGrouping__c objGroup : lstGrouping) {
                if(objGroup.LAT_ProductCosts__r.size() == 0) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene costo relacionado</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }

                if(objGroup.LAT_ReferenceProducts__r.size() == 0) {
                    strHTML += String.format('<li><a href="{0}/{1}">{2} <span style="color:red;">No tiene producto de referencia relacionado</span></a></li>', new String[] {Url.getSalesforceBaseUrl().toExternalForm(),objGroup.Id, objGroup.Name }) ;
                }
            }
        }

        if(String.isNotBlank(strHTML)) {
            strHTMLBody = 'Los siguientes pagamentos no son válidos : <br />';
            strHTMLBody += '<ul>';
            strHTMLBody += strHTML;
            strHTMLBody += '</ul>';
        } else {
            strHTMLBody = '';
        }
 
        System.debug('retrieveErrorsPagamentoProducto [' + strHTMLBody + '] <-');

        return strHTMLBody;
    }
}