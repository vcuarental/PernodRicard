global class PJ_ByFor_EmailService_Event implements Messaging.InboundEmailHandler {

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
	
	    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		String eventId = '';
	   	if(email.Subject.contains('Sandbox'))
			eventId = email.Subject.substringAfter(' ');
		else
			eventId = email.Subject;
		
		String reason = email.plainTextBody;
		
		Event theEvent = [select whatId from Event where Id=:eventId];
		theEvent.PJ_ByFor_Status__c = 'Free';
		theEvent.PJ_ByFor_Cellar_Master_Response__c = reason;
		update theEvent;
		
		PJ_ByFor_Experience__c xp = [select Id from PJ_ByFor_Experience__c where Id=:theEvent.whatId];
		xp.PJ_ByFor_Status__c = System.Label.PJ_ByFor_Experience_Open;
		xp.PJ_ByFor_Wishedexperiencedate__c = null;
		update xp;
		
	    return result;
	
	}

}