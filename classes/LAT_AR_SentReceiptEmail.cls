/**
 * Sent Email recipt
 * @author ernesto@zimmic.com
 */
public without sharing class LAT_AR_SentReceiptEmail {
	public Contact toSend {get;set;}
	public RCP_Receipt_ARG__c rec {get;set;}
	public Id recId {get;set;}
	public Id accId {get;set;}

	public String body {get;set;}
	public String emailcsv {get;set;}
	public String subject {get;set;}
	public List<String> emailList {get;set;}
	public boolean hasAtt {get;set;}
	public boolean wasSent {get;set;}


	public LAT_AR_SentReceiptEmail() {
		hasAtt = true;
		wasSent = false;
		recId = ApexPages.currentPage().getParameters().get('receiptId');
		rec = [SELECT Id,Name, Account_AR__r.Name, Account_AR__r.OwnerId ,Account_AR__c, Account_AR__r.Email_NFE__c,  Account_AR__r.Owner.Email, Account_AR__r.Owner.Name From RCP_Receipt_ARG__c where id =:recId];

		if (rec == null){
			hasAtt = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Recibo No encontrado'));
        }

		Attachment a = [select Name, Body, BodyLength from Attachment where ParentId = :recId ORDER BY CreatedDate desc LIMIT 1];
        // Add to attachment file list
        if (a == null){
        	hasAtt = false;
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No contiene recibos adjuntos'));
        }
		
		// set recipient data
		subject = 'Recibo de Pago Nro '+ rec.Name;
		loadEmailList();
		loadBodyList();
		//


	}

	public void loadEmailList(){
		String initialEmailList = '';
		List <Contact> lstcon= [Select Id,Name,Email FROM Contact Where AccountId = :rec.Account_AR__c];
		system.debug(lstcon);
		for (Contact con:lstcon){
			if (con.email != null) {
				initialEmailList += con.Email + ',';	
			}
		}

		if (rec.Account_AR__r.Email_NFE__c != '' && rec.Account_AR__r.Email_NFE__c!= null){
			initialEmailList += rec.Account_AR__r.Email_NFE__c + ',';
		}

		if(rec.Account_AR__r.Owner.Email != '' && rec.Account_AR__r.Owner.Email != null){
			initialEmailList += rec.Account_AR__r.Owner.Email + ',';
		}
		system.debug(lstcon);
		initialEmailList = initialEmailList.removeEnd(',');
		system.debug(initialEmailList);
		emailcsv = initialEmailList;
		system.debug(emailcsv);

	}

	public void loadBodyList(){
		body = 'Estimado \r\n';
		body += 'Le envío adjunto el comprobante del recibo por pago de deuda. \r\n';
		body += 'Saludos,  \r\n';
		body += UserInfo.getName();

	}

	public PageReference sendMail(){
		//load emails
		try{
		emailList = emailcsv.split(',');
		LAT_AR_SentReceiptEmailWS.sendEmail(emailList,body,subject,recId);
		wasSent = true;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Email Enviado Correctamente'));
		} catch (Exception e){
			system.debug(e.getStackTraceString());
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR:' + e.getMessage()));
		} 
		return null;
	}



}