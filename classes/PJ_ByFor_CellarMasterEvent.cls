public without sharing class PJ_ByFor_CellarMasterEvent{
	public Boolean saveOK{get;set;}
	public String message{get;set;}
	public Event theEvent{get;set;}
	public String reason{get;set;}
	public String title{get;set;}
	private String eventId;
	public Boolean reasonSave{get;set;}
	public String cellarResponse{get;set;}
	public void init()
	{
		reasonSave = false;
		reason = '';
		cellarResponse = ApexPages.currentPage().getParameters().get('r');
		eventId = ApexPages.currentPage().getParameters().get('eid');
		saveOK = false;
		if(eventId != null && eventId != '')
		{
			theEvent = [select Id, WhatId from Event where id=:eventId];
			//Event ev= new Event(Id=eventid);
			if(cellarResponse != null && cellarResponse != '' && cellarResponse=='yes')
			{
				theEvent.PJ_ByFor_Status__c = 'Confirmed';
				theEvent.PJ_ByFor_Cellar_Master_Response__c = '';
				update theEvent;
				
				PJ_ByFor_Experience__c xp = [select Id from PJ_ByFor_Experience__c where Id=:theEvent.whatId];
				xp.PJ_ByFor_Status__c = System.Label.PJ_ByFor_Experience_Estimate_Sent;
				update xp;
				saveOK = true;
				message = 'The experience date has been confirmed.';
				title = 'Thank you';
				
			} else if (cellarResponse != null && cellarResponse != '' && cellarResponse=='no')
			{
				/*
				theEvent.PJ_ByFor_Status__c = 'Free';
				//theEvent.whatId = null;
				update theEvent;
				
				PJ_ByFor_Experience__c xp = [select Id from PJ_ByFor_Experience__c where Id=:theEvent.whatId];
				//Supprimer la wished expérience date et 
				xp.PJ_ByFor_Status__c = System.Label.PJ_ByFor_Experience_Open;
				xp.PJ_ByFor_Wishedexperiencedate__c = null;
				update xp;
				*/
				saveOK = true;
				title = 'Please confirm';
				message = 'Please enter a reason to decline and click save in order to confirm the negative answer.';
			}
		}
	}
	
	public void save()
	{
		/*
		if(theEvent.PJ_ByFor_Cellar_Master_Response__c != '' && theEvent.PJ_ByFor_Cellar_Master_Response__c != null)
		{
			update theEvent;
			message = 'Reason of declined has been saved';
			reasonSave = true;
		}
		*/
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		//String[] toAddresses = new String[] {'pj_byfor_cellarmaster_rejectevent@q-277ft4y3ocftq2pasptbqim3jfg6fvyigraib7xi2l7lbxw9ch.26-dbtseao.cs81.apex.sandbox.salesforce.com'};
		String[] toAddresses = new String[]{System.Label.PJ_ByFor_EmailService};
		mail.setToAddresses(toAddresses);
		
		//String[] ccAddresses = new String[] {'yann.gorvel@exl-group.com'};
		//mail.setCcAddresses(ccAddresses);
		mail.setReplyTo('yann.gorvel@exl-group.com');
		mail.setSenderDisplayName('Salesforce Support');
		mail.setSubject(eventId);
		mail.setPlainTextBody(reason);
		mail.setUseSignature(false);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		title = 'Thank you';
		message = 'Reason of refuse has been saved';
		reasonSave = true;
	}
}