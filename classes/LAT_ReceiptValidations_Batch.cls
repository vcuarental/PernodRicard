global without sharing class LAT_ReceiptValidations_Batch implements Database.Batchable<sObject>, Database.Stateful{
	
	String query;
	String mensaje;
	Integer total;
	Map<String, String> receiptNames;

	global LAT_ReceiptValidations_Batch() {
		mensaje = '';
		total = 0;
		receiptNames = new Map<String, String>();
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		delete [SELECT Id FROM LAT_Blocked_Document__c];
		query = 'SELECT Id, Internal_id_pk_AR__c, ReceiptNo_AR__c, ReceiptNo_AR__r.Name, ReceiptNo_AR__r.ID_JDE_Debito__c, ReceiptNo_AR__r.Comercial_Discount_ID_JDE__c, '
				+ 'ReceiptNo_AR__r.Financial_Discount_ID_JDE__c, ReceiptNo_AR__r.ID_JDE_Downpayments__c, ReceiptNo_AR__r.AN8_AR__c '
				+ 'FROM DCM_Documents_ARG__c WHERE ReceiptNo_AR__r.LAT_AR_IntegrationStatus__c IN (\'Error in JDE\',\'Sent to JDE\')';
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//Borro todos los documentos de la última ejecución.
		
		List<LAT_Blocked_Document__c> toInsert = new List<LAT_Blocked_Document__c>();

		for(DCM_Documents_ARG__c doc : (List<DCM_Documents_ARG__c>)scope) {
			if(!receiptNames.keySet().contains(doc.ReceiptNo_AR__r.Name) ) {
				if(doc.ReceiptNo_AR__r.ID_JDE_Debito__c != null) {
					createNew(toInsert, doc, doc.ReceiptNo_AR__r.ID_JDE_Debito__c);
				}
				if(doc.ReceiptNo_AR__r.Comercial_Discount_ID_JDE__c != null) {
					createNew(toInsert, doc, doc.ReceiptNo_AR__r.Comercial_Discount_ID_JDE__c);
				}
				if(doc.ReceiptNo_AR__r.Financial_Discount_ID_JDE__c != null) {
					createNew(toInsert, doc, doc.ReceiptNo_AR__r.Financial_Discount_ID_JDE__c);
				}
				if(doc.ReceiptNo_AR__r.ID_JDE_Downpayments__c != null) {
					createNew(toInsert, doc, doc.ReceiptNo_AR__r.ID_JDE_Downpayments__c);
				}
			}
			LAT_Blocked_Document__c nuevo = new LAT_Blocked_Document__c();
			nuevo.LAT_Receipt__c 	= doc.ReceiptNo_AR__c;
			nuevo.LAT_Document__c		= doc.Id;
			nuevo.Internal_id_pk__c = doc.Internal_id_pk_AR__c;
			toInsert.add(nuevo);
			receiptNames.put(doc.ReceiptNo_AR__r.Name, doc.ReceiptNo_AR__c);

		}

		if (toInsert.size() > 0) {
			total += toInsert.size();
 			insert toInsert;
		}

	}

	global void finish(Database.BatchableContext BC) {
		if(total > 0) {
			mensaje = 'Se insertan ' + total + ' registros.';
		}  else {
			mensaje = 'No se encontraron documentos a bloquear.';
		}

		System.debug('%%%%%% mensaje en LAT_ReceiptValidations_Batch : ' + mensaje);
		System.debug('%%%%%% Recibos : ' + receiptNames.keySet());

		LAT_DebugUtil debugUtil = new LAT_DebugUtil();
		debugUtil.setOrigin('LAT_ReceiptValidations_Batch');
        debugUtil.addSubTitle(mensaje);
        debugUtil.insertDebug();
        if(receiptNames.keySet().size() > 0) {
        	SendEmail();
        }

		
	}

	public void createNew(List<LAT_Blocked_Document__c> toInsert, DCM_Documents_ARG__c doc, String codigo) {
		try{
			String[] splited = codigo.split('-');
			String internalId = '6-' + doc.ReceiptNo_AR__r.AN8_AR__c + '-100-' + splited[1] + '-' + splited[0] + '-1';
			LAT_Blocked_Document__c nuevo = new LAT_Blocked_Document__c();
			nuevo.LAT_Receipt__c 	= doc.ReceiptNo_AR__c;
			nuevo.LAT_Document__c	= null;
			nuevo.Internal_id_pk__c = internalId;
			toInsert.add(nuevo);
		} catch(Exception e) {
			System.debug('%%%% Error en LAT_ReceiptValidations_Batch : ' + e);
		}
	}

	public  void SendEmail() {
		String strMails = LAT_GeneralConfig__c.getInstance('AR_Receipt_Errors_Email_Recipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);

        String html = '';
        String subject = 'Recibos pendientes de integración';
        html += 'Se han encontrado los siguientes Recibos que no han completado su Integración con JDE: <br>';

        for(String rec :this.receiptNames.keySet()){

            html += '    - ' + rec +' - https://' + URL.getSalesforceBaseUrl().getHost() + '/' + this.receiptNames.get(rec) + '<br>';
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