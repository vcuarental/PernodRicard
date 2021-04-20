public without sharing class LAT_CTY_B2B_PendingFiscalNotesCont {
    
    public final static List<string> TRACKING_STATUS = new List<String>{'EN DESPACHO'};
    
    public LAT_CTY_B2B_PendingFiscalNotesCont() {
        
    }
    @AuraEnabled
    public static string actualizarPim(){
        actualizarPIMFuture();
        return 'Se está ejecutando la actualización, en unos minutos quedarán actualizados los productos.';
    }

    @AuraEnabled
    public static string refreshAllPrices(){
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(10);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        LAT_AR_B2B_PriceCalc_Scheduler scheduler = new LAT_AR_B2B_PriceCalc_Scheduler();
        System.schedule('B2B PriceCalculation ' + sysTime,chron_exp,scheduler);

        
        return 'Se está ejecutando la actualización, en unos minutos quedarán actualizados los productos.';
    }


    @future(callout=true)
    public static void actualizarPIMFuture(){
        LAT_B2B_PIMIntegration cont = new LAT_B2B_PIMIntegration();
        cont.makePIMCallout(cont.getProducts());
    }

    @AuraEnabled
    public static Decimal getMinimunPrice() {
        final Id accountId = getAccountId();
        return LAT_CTY_B2B_UtilsController.getMinimunPrice(accountId);
    }

    @AuraEnabled
    public static String updateMinimunPrice(Double newValue) {
        LAT_GeneralConfig__c currentMinimun = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_MinOrderPrice');
        currentMinimun.LAT_Value__c = String.valueOf(newValue);
        update currentMinimun;
        return 'OK';
    }

    @AuraEnabled
    public static Boolean getChartBlocked() {
        LAT_CTY_B2B_UtilsController.SiteStatus objSiteStatus = null;
        Boolean boolIsBlocked = false;

        System.debug('getChartBlocked [] ->');
        try {
            objSiteStatus = LAT_CTY_B2B_UtilsController.retrieveSiteStatus();

            boolIsBlocked = objSiteStatus.IsBlocked;
        } catch(Exception Ex) {
            LAT_Utils.handleException('getChartBlocked', Ex.getMessage());
        }

        System.debug('getChartBlocked [ ' + boolIsBlocked + ' ] <-');
        return boolIsBlocked;
    }

    @AuraEnabled
    public static List<LAT_CTY_B2B_Settings__c> listBlocks(Date datFrom, Date datTo, Boolean boolActive) {
        List<LAT_CTY_B2B_Settings__c> lstSettings = null;
        String strSOQL = null;
        //EN ALGUN MOMENTO CAPAZ SEA NECESARIO FILTRAR.
        System.debug('listBlocks [datFrom : ' + datFrom + ' - datTo : ' + datTo + ' - boolActive : ' + boolActive + '] ->');
        try {
            lstSettings = [SELECT Id, LAT_CTY_B2B_Blocked_From__c, LAT_CTY_B2B_Blocked_To__c, LAT_CTY_B2B_Message__c, LAT_CTY_B2B_Active__c, LAT_CTY_B2B_Is_Blocked__c
                            FROM LAT_CTY_B2B_Settings__c
                            ORDER BY LAT_CTY_B2B_Blocked_To__c ASC
                            LIMIT 5
                            ];            
        } catch(Exception Ex) {
            LAT_Utils.handleException('listBlocks', Ex.getMessage());
        }

        System.debug('listBlocks [ ' + lstSettings + ' ] <-');
        return lstSettings;
    }

    @AuraEnabled
    public static OperationResult updateStatus(String strRecordId, Boolean boolActive) {
        LAT_CTY_B2B_Settings__c objSettings = null;
        String strSOQL = null;
        OperationResult objResult = null;
        //EN ALGUN MOMENTO CAPAZ SEA NECESARIO FILTRAR.
        System.debug('updateStatus [strRecordId : ' + strRecordId + ' - boolActive : ' + boolActive + '] ->');
        try {
            objResult = new OperationResult();

            objSettings = new LAT_CTY_B2B_Settings__c();
            objSettings.Id = strRecordId;
            objSettings.LAT_CTY_B2B_Active__c = boolActive;
            update objSettings;

            objResult.Code = 0;
            objResult.Message = 'La operación se ha realizado exitosamente';
        } catch(Exception Ex) {
            LAT_Utils.handleException('updateStatus', Ex.getMessage());
            objResult.Code = 999;
            objResult.Message = 'Ha ocurrido un error al realizar la operación';
        }

        System.debug('updateStatus [ ' + objResult + ' ] <-');
        return objResult;
    }

    /*
    @AuraEnabled
    public static Boolean getChartBlocked() {
        LAT_GeneralConfig__c currentMinimun = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_ChartIsBlocked');
        if(currentMinimun == null) {
            currentMinimun = new LAT_GeneralConfig__c();
            currentMinimun.Name = 'LAT_CTY_B2B_AR_ChartIsBlocked';
            currentMinimun.LAT_Value__c = 'false';
            currentMinimun.LAT_Description__c = 'Config para habilitar/bloquear la creación de pedidos en B2B.';
            insert currentMinimun;
        }

        return currentMinimun.LAT_Value__c == 'true';
    }
    */

    @AuraEnabled
    public static String getBlockingComments() {
        LAT_GeneralConfig__c currentMinimun = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_BlockingComments');
        if(currentMinimun == null) {
            currentMinimun = new LAT_GeneralConfig__c();
            currentMinimun.Name = 'LAT_CTY_B2B_AR_BlockingComments';
            currentMinimun.LAT_Value__c = '';
            currentMinimun.LAT_Description__c = 'Comentarios del Bloqueo del carrito en B2B.';
            insert currentMinimun;
        }
        return currentMinimun.LAT_Value__c;
    }

    
    @AuraEnabled
    public static String hablitarCarrito() {
        LAT_GeneralConfig__c currentMinimun = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_ChartIsBlocked');
        currentMinimun.LAT_Value__c = 'false';
        update currentMinimun;
        return 'OK';
    }

    @AuraEnabled
    public static OperationResult scheduleBlock(DateTime datFrom, DateTime datTo, String strComments) {
        LAT_CTY_B2B_Settings__c objSettings = null;
        List<LAT_CTY_B2B_Settings__c> lstSettings = null;
        OperationResult objResult = null;

        System.debug('scheduleBlock [ datFrom : ' + datFrom + ' - datTo : ' + datTo + ' - strComments : ' + strComments + '] ->');
        try {
            objResult = new OperationResult();
            //CHECKEO QUE LAS FECHAS NO CAIGAN EN UN RANGO EXISTENTE
            lstSettings = [SELECT Id 
                            FROM LAT_CTY_B2B_Settings__c 
                            WHERE (
                                LAT_CTY_B2B_Blocked_From__c  <= :datFrom 
                                AND LAT_CTY_B2B_Blocked_To__c >= :datFrom   
                            ) OR (
                                LAT_CTY_B2B_Blocked_From__c <= :datTo
                                AND LAT_CTY_B2B_Blocked_To__c >= :datTo
                            )];
            
            if(lstSettings.isEmpty()) {
                objSettings = new LAT_CTY_B2B_Settings__c();
                objSettings.LAT_CTY_B2B_Blocked_From__c = datFrom;
                objSettings.LAT_CTY_B2B_Blocked_To__c = datTo;
                objSettings.LAT_CTY_B2B_Message__c = strComments;
                objSettings.LAT_CTY_B2B_Active__c = true;
                
                insert objSettings;

                objResult.Code = 0;
                objResult.Message = 'La operación se ha realizado exitosamente.';
                objResult.Id = objSettings.Id;

                LAT_CTY_B2B_ProcessBlock_Schedulable.scheduleRetryJob(datTo);
            } else {
                objResult.Code = 100;
                objResult.Message = 'El rango ingresado no puede superponerse con uno ya existente';
            }
        } catch(Exception Ex) {
            LAT_Utils.handleException('scheduleBlock', Ex.getMessage());
            objResult.Code = 999;
            objResult.Message = 'Ha ocurrido un error al realizar la operación';
        }

        System.debug('scheduleBlock [' + objResult + '] <-');
        return objResult;
    }

    //TODO: METERLO EN UNA CLASE GENERICA
    public class OperationResult {
        @AuraEnabled
        public Integer Code {get; set;}
        
        @AuraEnabled
        public String Message {get; set;}
        
        @AuraEnabled
        public Id Id {get; set;}
    }
    
    @AuraEnabled
    public static String bloquearCarrito(String comments) {
        LAT_GeneralConfig__c isBlockedCS = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_ChartIsBlocked');
         if(isBlockedCS == null) {
            isBlockedCS = new LAT_GeneralConfig__c();
            isBlockedCS.Name = 'LAT_CTY_B2B_AR_ChartIsBlocked';
            isBlockedCS.LAT_Value__c = 'false';
            isBlockedCS.LAT_Description__c = 'Config para habilitar/bloquear la creación de pedidos en B2B.';
            insert isBlockedCS;
        }

        isBlockedCS.LAT_Value__c = 'true';
        LAT_GeneralConfig__c commentsCS = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_BlockingComments');
        if(commentsCS == null) {
            commentsCS = new LAT_GeneralConfig__c();
            commentsCS.Name = 'LAT_CTY_B2B_AR_BlockingComments';
            commentsCS.LAT_Value__c = 'false';
            commentsCS.LAT_Description__c = 'Config para habilitar/bloquear la creación de pedidos en B2B.';
            insert commentsCS;
        }

        commentsCS.LAT_Value__c = comments;
        update new List<LAT_GeneralConfig__c>{isBlockedCS,commentsCS};
        return 'OK';
    }
    

    @AuraEnabled
    public static LAT_CTY_B2B_Payment__c createB2BPayment() {
        LAT_CTY_B2B_Payment__c newPayment = new LAT_CTY_B2B_Payment__c();
        newPayment.LAT_Account__c = getAccountId();
        newPayment.LAT_Status__c = 'Pago Informado';
        newPayment.LAT_Date__c = Date.today();
        newPayment.LAT_Amount__c = 0;
        insert newPayment;

        return newPayment;
    }

    @AuraEnabled
    public static LAT_CTY_B2B_Payment__c cancelarPago(String paymentId, String comments) {
        List<LAT_CTY_B2B_Payment__c> payments = [SELECT Id, Name, LAT_Account__c, LAT_Account__r.Corporate_Name__c, LAT_Status__c, LAT_Date__c, LAT_Amount__c, LAT_Comments__c,
                                            (SELECT ContentDocumentId FROM ContentDocumentLinks), CreatedById,
                                            (SELECT LAT_LegalInvoice__c, LAT_BillingDate__c, LAT_Opportunity__c, LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_FiscalNoteAmount__c,
                                                LAT_AR_NetAmmount__c, LAT_PaymentTerm__c FROM Fiscal_Notes__r)
                                            FROM LAT_CTY_B2B_Payment__c WHERE Id =:paymentId];
        if(payments.size() > 0){
            LAT_CTY_B2B_Payment__c pago = payments[0];
            pago.LAT_Status__c = 'Pago Rechazado';
            pago.LAT_Comments__c = comments;
            update pago;
            postToChatter(pago);
            return pago;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static LAT_CTY_B2B_Payment__c procesarPago(String paymentId) {
        List<LAT_CTY_B2B_Payment__c> payments = [SELECT Id, Name, LAT_Account__c, LAT_Account__r.Corporate_Name__c, LAT_Status__c, LAT_Date__c, LAT_Amount__c,
                                            (SELECT ContentDocumentId FROM ContentDocumentLinks), CreatedById,
                                            (SELECT LAT_LegalInvoice__c, LAT_BillingDate__c, LAT_Opportunity__c, LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_FiscalNoteAmount__c,
                                                LAT_AR_NetAmmount__c, LAT_PaymentTerm__c FROM Fiscal_Notes__r)
                                            FROM LAT_CTY_B2B_Payment__c WHERE Id =:paymentId];
        if(payments.size() > 0){
            LAT_CTY_B2B_Payment__c pago = payments[0];
            pago.LAT_Status__c = 'Pago Confirmado';
            update pago;
            postToChatter(pago);
            return pago;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static List<LAT_CTY_B2B_Payment__c> getPaymentsList() {

        List<LAT_CTY_B2B_Payment__c> payments = [SELECT Id, Name, LAT_Status__c, LAT_Date__c, LAT_Amount__c, LAT_Comments__c
                                                    FROM LAT_CTY_B2B_Payment__c WHERE LAT_Account__c =:getAccountId() ORDER BY Name DESC];
        return payments;
    } 
    @AuraEnabled
    public static List<Titulos__c> getNotasDeCredito() {

        List<Titulos__c> titulos = [SELECT Id, LegalInvoice_AR__c, valorOriginalTitulo__c, valorSaldo__c, dataEmissao__c, LAT_AR_TypeDescription__c
                                                    FROM Titulos__c WHERE LAT_AR_TypeDescription__c ='NOTA DE CRÉDITO' AND Cliente__c=:getAccountId() ];
        return titulos;
    } 

    @AuraEnabled
    public static List<LAT_CTY_B2B_Payment__c> getInformedPayments() {

        List<LAT_CTY_B2B_Payment__c> payments = [SELECT Id, Name, LAT_Account__r.Name, LAT_Status__c, LAT_Date__c, LAT_Amount__c, LAT_Comments__c
                                                    FROM LAT_CTY_B2B_Payment__c WHERE LAT_Status__c = 'Pago Informado' ORDER BY Name DESC];
        return payments;
    } 

    @AuraEnabled
    public static List<LAT_CTY_B2B_Payment__c> getProcessedPayments() {

        List<LAT_CTY_B2B_Payment__c> payments = [SELECT Id, Name, LAT_Account__r.Name, LAT_Status__c, LAT_Date__c, LAT_Amount__c, LAT_Comments__c
                                                    FROM LAT_CTY_B2B_Payment__c WHERE LAT_Status__c IN ('Pago Confirmado', 'Pago Rechazado') ORDER BY Name DESC];
        return payments;
    }  
    @AuraEnabled
    public static LAT_CTY_B2B_Payment__c getB2BPayment(String paymentId) {
        try{
            LAT_CTY_B2B_Payment__c payment = [SELECT Id, Name, LAT_Account__c, LAT_Account__r.Corporate_Name__c, LAT_Status__c, LAT_Date__c, LAT_Amount__c, LAT_Comments__c,
                                            (SELECT ContentDocumentId FROM ContentDocumentLinks),
                                            (SELECT LAT_LegalInvoice__c, LAT_BillingDate__c, LAT_Opportunity__c, LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_FiscalNoteAmount__c, 
                                                LAT_AR_NetAmmount__c, LAT_PaymentTerm__c FROM Fiscal_Notes__r)
                                            FROM LAT_CTY_B2B_Payment__c WHERE Id =: paymentId];
            return payment;
        } catch(Exception e) {
            return null;
        }
        
    }   

    @AuraEnabled
    public static String deleteB2BPayment(String paymentId) {
        LAT_CTY_B2B_Payment__c payment = [SELECT Id FROM LAT_CTY_B2B_Payment__c WHERE Id =: paymentId];
        if(payment!=null) delete payment;
        return '';
    }
    @AuraEnabled
    public static String deleteAttachment(String attId) {
        ContentDocument att = [SELECT Id FROM ContentDocument WHERE Id =: attId];
        if(att!=null) delete att;
        return '';
    }

    

    @AuraEnabled
    public static void updatePayment(String paymentId, String paymentAmount, String fiscalNotesId, Boolean isDownpayment, String titulosId) {
        final Id accountId = getAccountId();
        LAT_CTY_B2B_Payment__c payment = [SELECT Id, LAT_Amount__c FROM LAT_CTY_B2B_Payment__c WHERE Id =: paymentId];
       
        payment.LAT_Amount__c = Decimal.valueOf(paymentAmount);
        if(isDownpayment)
            payment.LAT_Comments__c = 'Es un Adelanto de Pago';
        update payment;

        System.debug(fiscalNotesId);
        Type idArrType = Type.forName('List<String>');
        List <String> fiscalNotesWrapperList = (List<String>) JSON.deserialize(fiscalNotesId, idArrType);
        List <String> titulosWrapperList = (List<String>) JSON.deserialize(titulosId, idArrType);

        List <LAT_Opportunity__c> opportunitites = new List<LAT_Opportunity__c>();
        List <LAT_FiscalNote__c> fiscalNotes = [SELECT Id, LAT_Opportunity__c, LAT_AR_B2B_Status__c                                                     
                                                    FROM LAT_FiscalNote__c
                                                    WHERE Id IN: fiscalNotesWrapperList  AND LAT_Client__c =:accountId  
                                                    ORDER BY createdDate DESC];
        List<Titulos__c> titulos = [SELECT Id, Name, LegalInvoice_AR__c, valorOriginalTitulo__c, valorSaldo__c, dataEmissao__c, LAT_AR_TypeDescription__c
                                                    FROM Titulos__c WHERE Id IN:titulosWrapperList ];
        List<LAT_FiscalNote__c> toInsert = new List<LAT_FiscalNote__c>();
        for(Titulos__c t: titulos){
            LAT_FiscalNote__c nuevo = new LAT_FiscalNote__c();
            nuevo.Name = t.Name;
            nuevo.LAT_LegalInvoice__c = t.LegalInvoice_AR__c;
            nuevo.LAT_B2B_Payment__c = payment.Id;
            nuevo.LAT_BillingDate__c = t.dataEmissao__c;
            nuevo.LAT_AR_NetAmmount__c = t.valorSaldo__c;
            nuevo.LAT_PaymentTerm__c = 'NC';
            toInsert.add(nuevo);
        }
        if(toInsert.size() > 0) insert toInsert;

        for (LAT_FiscalNote__c note : fiscalNotes) {
            note.LAT_B2B_Payment__c = paymentId;
            note.LAT_AR_B2B_Status__c = 'Pago Informado';
            LAT_Opportunity__c opp = new LAT_Opportunity__c();
            opp.Id = note.LAT_Opportunity__c;
            opp.LAT_B2B_Payment__c = paymentId;
            opportunitites.add(opp);
        }
        
        update opportunitites;
        update fiscalNotes;
    }
    
    @AuraEnabled
    public static List<LAT_FiscalNote__c> getPendingFiscalNotes(){
        String baseUrl = Network.getLoginUrl(Network.getNetworkId());
        if(baseUrl!=null) baseUrl = baseUrl.remove('/s/login');
        System.debug('&&& baseUrl : ' + baseUrl);
        Id accountId = getAccountId();
        System.debug('%%%% accountId : ' + accountId);
        List<LAT_FiscalNote__c> retorno =  [SELECT Id, LAT_B2B_Estado_Calico__c, LAT_Opportunity__r.LAT_Description__c, LAT_B2B_URL_Calico__c , LAT_Opportunity__r.LAT_NROrderJDE__c,
                        LAT_Opportunity__r.LAT_CloseDate__c, LAT_LegalInvoice__c,LAT_AR_B2B_Status__c, LAT_BillingDate__c, LAT_FiscalNoteAmount__c, LAT_AR_NetAmmount__c, 
                        LAT_Opportunity__r.LAT_NextStep__c,LAT_Balance__c, LAT_DueDate__c, LAT_B2B_Payment__c, LAT_B2B_Payment__r.Name, LAT_PaymentTerm__c,
                        (SELECT ID, Name FROM Attachments ORDER BY lastmodifieddate)
                FROM LAT_FiscalNote__c 
                WHERE (LAT_AR_B2B_Status__c = 'A Pagar' OR LAT_AR_B2B_Status__c = 'Pago Informado') 
                AND LAT_Client__c =:accountId  AND LAT_Opportunity__c <> null 
                ORDER BY createdDate DESC];
        for(LAT_FiscalNote__c nf : retorno){
            if(nf.Attachments != null) {
                for(Attachment att : nf.Attachments) {
                    if(att.Name.contains(nf.LAT_LegalInvoice__c)) {
                        System.debug('nf.LAT_Opportunity__r.LAT_NextStep__c : ' + nf.LAT_Opportunity__r.LAT_NextStep__c );
                        System.debug('baseUrl : ' + baseUrl);
                        System.debug('att.Id: '+ att.Id);
                        nf.LAT_Opportunity__r.LAT_NextStep__c = baseUrl+'/servlet/servlet.FileDownload?file='+att.Id;
                    } else if(att.Name.startsWith('Recibo')){
                        System.debug('%%%% encontramos  recbibo');
                        nf.LAT_Opportunity__r.LAT_Description__c = baseUrl+'/servlet/servlet.FileDownload?file='+att.Id;
                    }
                }
            }
        }
        return retorno;
    }

    @AuraEnabled
    public static List<LAT_FiscalNote__c> getPaidFiscalNotes(){
        String baseUrl = Network.getLoginUrl(Network.getNetworkId());
        if(baseUrl!=null) baseUrl = baseUrl.remove('/s/login');
        System.debug('&&& baseUrl : ' + baseUrl);
        Id accountId = getAccountId();
        System.debug('%%%% accountId : ' + accountId);
        List<LAT_FiscalNote__c> retorno =  [SELECT Id, LAT_B2B_Estado_Calico__c, LAT_Opportunity__r.LAT_Description__c, LAT_B2B_URL_Calico__c , LAT_Opportunity__r.LAT_NROrderJDE__c,
                            LAT_Opportunity__r.LAT_CloseDate__c, LAT_LegalInvoice__c,LAT_AR_B2B_Status__c, LAT_BillingDate__c, LAT_FiscalNoteAmount__c, LAT_AR_NetAmmount__c, 
                            LAT_Opportunity__r.LAT_NextStep__c, LAT_B2B_Payment__c, LAT_B2B_Payment__r.Name, LAT_PaymentTerm__c,
                        (SELECT ID, Name FROM Attachments where name != null ORDER BY lastmodifieddate)
                FROM LAT_FiscalNote__c 
                WHERE (LAT_AR_B2B_Status__c != 'A Pagar' AND LAT_AR_B2B_Status__c != 'Pago Informado') 
                AND LAT_Client__c =:accountId  
                AND LAT_BillingDate__c >= LAST_N_MONTHS:36 AND LAT_Opportunity__c <> null 
                ORDER BY LAT_BillingDate__c DESC];
        for(LAT_FiscalNote__c nf : retorno){
            if(nf.Attachments != null) {
                for(Attachment att : nf.Attachments) {
                    if(att.Name.contains(nf.LAT_LegalInvoice__c)) {
                        nf.LAT_Opportunity__r.LAT_NextStep__c = baseUrl+'/servlet/servlet.FileDownload?file='+att.Id;
                    } else if(att.Name.startsWith('Recibo')){
                        System.debug('%%%% encontramos  recbibo');
                        nf.LAT_Opportunity__r.LAT_Description__c = baseUrl+'/servlet/servlet.FileDownload?file='+att.Id;
                    }
                }
            }
        }
        return retorno;
    }
    
    @AuraEnabled
    public static List<LAT_FiscalNote__c> getTrackingFiscalNotes(){
        Id accountId = getAccountId();
        System.debug('%%%% accountId : ' + accountId);
        return [Select Id, LAT_B2B_Estado_Calico__c, LAT_B2B_URL_Calico__c ,LAT_Opportunity__r.LAT_NROrderJDE__c,LAT_Opportunity__r.LAT_CloseDate__c, LAT_LegalInvoice__c,LAT_AR_B2B_Status__c FROM LAT_FiscalNote__c where LAT_B2B_Estado_Calico__c IN :TRACKING_STATUS  AND LAT_Client__c =:accountId  ORDER BY createdDate DESC] ;
    }
    
    
    @AuraEnabled
    public static Id getAccountId() {
        final String userId = UserInfo.getUserId(); 
        String accountId = null; 
        final List <User> usrs = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];
        
        if (!usrs.isEmpty()) {
            return (usrs[0].Contact !=  null ) ? usrs[0].Contact.AccountId : null;
        }
        return null;
    }

    public static void postToChatter(LAT_CTY_B2B_Payment__c pago) {

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        String body = 'El pago ' + pago.Name +' fue ';
        if(pago.LAT_Status__c == 'Pago Confirmado') {
            body+= 'procesado por Customer Service exitosamente. \n\n\tEn las próximas 48hs el mismo se verá reflejado en su cuenta corriente. \n\n\t';
        } else {
             body+= 'rechazado por la siguiente razón:\n\n\t'+pago.LAT_Comments__c+'.\n\n\t';
        }
        body += 'Saludos!\n\nEquipo Pernod Ricard';
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = body;
        System.debug('%%%% textSegmentInput.text : '+textSegmentInput.text);
        messageBodyInput.messageSegments.add(textSegmentInput);
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = pago.CreatedById;
        messageBodyInput.messageSegments.add(mentionSegment);
        
        System.debug('%%%% messageBodyInput : '+messageBodyInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = pago.CreatedById;


        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        batchInputs.add(batchInput);         
        if (batchInputs.size() > 0) {
            if (!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        } 
                


    }
}