/*******************************************************************************
*                           Company: Zimmic
*-------------------------------------------------------------------------------
* 
* This class contains methods related to TAA and TAAAgreements objects.
*
* NAME: LAT_BR_TAAActions.cls
* AUTHOR: Mariano Boezio                           DATE: 23/02/2016
********************************************************************************/
public class LAT_BR_TAAActions {

	private static final String taskRecordTypeId = Global_RecordTypeCache.getRtId('Task'+'LAT_TAAAccompaniment');


	/*********************************************************************************************************
    * Nombre del metodo: TAAsendConfirmationEmail
    * Descripcion: Send email to related contact and Account Owner, and creates attachment on related Visit
    * Modo: after insert, after update
    ********************************************************************************************************/
	public static void TAAsendConfirmationEmail(List<LAT_BR_TAA__c> triggerNew) {
		// Gets email template and inits lists
		List<String> attIdList = new List<String> ();

		// Gets TAA from trigger with extra fields from related Visit object
		Map<id, LAT_BR_TAA__c> taaList = new Map<id, LAT_BR_TAA__c>([SELECT id, Contact__c, Contact__r.Email, DoNotSendEmail__c,
																	  Visit__r.Conta__r.Owner.email, Visit__c, Visit__r.Status__c,
																	  Visit__r.LAT_BR_HasAttachment__c, EmailSent__c, AttachmentDone__c
																	  FROM LAT_BR_TAA__c 
																	  WHERE id IN: triggerNew]);
		
		// Determins if the email needs to be send and attachement created.
		// If the HasAttachemnt from visit object isn't checked and the status of the visit is Closed
		// an email should be sent and an attachment created 							
		for (LAT_BR_TAA__c taa: taaList.values()) {
			if (taa.Visit__r.Status__c == 'Encerrada' && !taa.EmailSent__c && !taa.AttachmentDone__c) {
				attIdList.add(taa.id);
		   	}
	   	}

	   	// If created list are not empty send email and create attachements.
	   	if (!attIdList.isEmpty()) {
	   		addTAAAttachment(attIdList);
	   	}
	}

	/*********************************************************************************************************
    * Nombre del metodo: addTAAAttachment
    * Description: Creates Attachemnts based on the TAA objects passed as parameter. 
    *              This is a future methods so it can be invoked from trigger context
    ********************************************************************************************************/
	
	public static void addTAAAttachment(List<String> taaIds) {
		EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'LAT_BR_TAAConfirmationEmailVisual'];
		
		// Checks if there is an email service address to replay
		// String[] serviceEmail = LAT_GeneralConfigDao.getValueAsStringArray('TAA_SERVICE_EMAIL', ';');
		// String replayToEmail = serviceEmail.isEmpty() ? '' : serviceEmail[0];

		Map<id, LAT_BR_TAA__c> taaList = new Map<id, LAT_BR_TAA__c>([SELECT id, Contact__c, Contact__r.Email, DoNotSendEmail__c,
																	  Visit__r.Conta__r.Owner.email, Visit__c,
																	  Visit__r.Conta__r.Corporate_Name__c, Visit__r.Data_da_Visita__c,
																	  Visit__r.Hora_da_Visita__c, EmailSent__c, AttachmentDone__c
																	  FROM LAT_BR_TAA__c 
																	  WHERE id IN: taaIds]);

		Set<LAT_BR_TAA__c> modified = new Set<LAT_BR_TAA__c>();	
		Set<String> modifiedIds = new Set<String>();				
		Set<Id> taaIdsForEmail = new Set<Id>();
		Set<Id> taaIdsForPDF = new Set<Id>();
		
		for (LAT_BR_TAA__c taa: taaList.values()) {

			if (taa.Contact__r.Email != null && taa.DoNotSendEmail__c == false && !taa.EmailSent__c) {

				taaIdsForEmail.add(taa.Id);
		   		
		   		taa.EmailSent__c = true;
		   		if (!modifiedIds.contains(taa.id)){
		   			modified.add(taa);
		   			modifiedIds.add(taa.id);
		   		} 
		   	}

		   	if (!taa.AttachmentDone__c) {

		   		taaIdsForPDF.add(taa.Id);

		   		taa.AttachmentDone__c = true;
		   		if (!modifiedIds.contains(taa.id)){
		   			modified.add(taa);
		   			modifiedIds.add(taa.id);
		   		} 
		   	}
	   	}

	   	if (!taaIdsForPDF.isEmpty()) {
	   		
	   		if(!System.isBatch())insertPDF(taaIdsForPDF);
	   		
		}
		if (!taaIdsForEmail.isEmpty()) {
	   		sendEmailToContact(taaIdsForEmail);
	   		
	   	}

	   	if (!taaIdsForEmail.isEmpty() || !taaIdsForPDF.isEmpty()) {
	   		List<LAT_BR_TAA__c> toUpdate = new List<LAT_BR_TAA__c>(modified);
	   		update toUpdate;
	   	}
	}

	/*********************************************************************************************************
    * Nombre del metodo: TAAAgreementAccompaniment
    * Description: This method creates tasks related to visits or TAA based on TAAAgreements
    * Modo: after insert, after update
    ********************************************************************************************************/
	public static void TAAAgreementAccompaniment(List<LAT_BR_TAAAgreement__c> triggerNew, Map<id, LAT_BR_TAAAgreement__c> mapOld) {
		Map<id, LAT_BR_TAAAgreement__c> agreementList = new Map<id, LAT_BR_TAAAgreement__c>([SELECT id, LAT_BR_TAA__r.Visit__r.Conta__c, Due_Date__c, 
																									Items__c, Accompaniment__c, LAT_BR_TAA__c, LAT_BR_TAA__r.Visit__c
																							FROM LAT_BR_TAAAgreement__c 
																							WHERE id IN: triggerNew]);

		Map<id, String> acIds = new Map<id, String>();
		for (LAT_BR_TAAAgreement__c ag: agreementList.values()) {
			acIds.put(ag.id, ag.LAT_BR_TAA__r.Visit__r.Conta__c);
		}

		Map<id, Account> accWithVisits = new Map<id, Account>([SELECT id, OwnerId, (SELECT id, Data_da_Visita__c FROM Visitas__r WHERE Data_da_Visita__c >: Date.today() ORDER BY Data_da_Visita__c LIMIT 1)
																FROM Account WHERE id IN: acIds.values()]);

		List<Task> tasksToCreate = new List<Task>();
		for (LAT_BR_TAAAgreement__c ag: triggerNew) {
			if ((ag.Accompaniment__c && trigger.isInsert)
				|| (ag.Accompaniment__c && !mapOld.get(ag.id).Accompaniment__c)) {
				String clientOwner = accWithVisits.get(acIds.get(ag.id)) != null ? accWithVisits.get(acIds.get(ag.id)).OwnerId : userInfo.getUserId();
				if (ag.Due_Date__c != null) {
					
					tasksToCreate.add(
						new Task(OwnerId = clientOwner,
								 Subject = 'Acompanhamento TAA',
								 Priority = 'Normal',
								 ActivityDate = ag.Due_Date__c,
								 Description = ag.Items__c,
								 recordTypeId = taskRecordTypeId,
								 whatId = ag.LAT_BR_TAA__c,
								 LAT_Visita__c = agreementList.get(ag.id).LAT_BR_TAA__r.Visit__c
						)
					);
				} else {
					if (accWithVisits.get(acIds.get(ag.id)) != null 
						&& !accWithVisits.get(acIds.get(ag.id)).Visitas__r.isEmpty()) {
						tasksToCreate.add(
							new Task(OwnerId = clientOwner,
									 Subject = 'Acompanhamento TAA',
									 Priority = 'Normal',
									 Description = ag.Items__c,
								 	 recordTypeId = taskRecordTypeId,
									 whatId = accWithVisits.get(acIds.get(ag.id)).Visitas__r.get(0).id,
								 	 LAT_Visita__c = accWithVisits.get(acIds.get(ag.id)).Visitas__r.get(0).id

							)
						);
					} else {
						tasksToCreate.add(
							new Task(OwnerId = clientOwner,
									 Subject = 'Acompanhamento TAA',
									 Priority = 'Normal',
									 Description = ag.Items__c,
								 	 recordTypeId = taskRecordTypeId,
									 whatId = ag.LAT_BR_TAA__c,
								 	 LAT_Visita__c = agreementList.get(ag.id).LAT_BR_TAA__r.Visit__c
							)
						);
					}
				}
			} 
		}

		if (!tasksToCreate.isEmpty()){
			insert tasksToCreate;
		}

	}

	/*********************************************************************************************************
    * Nombre del metodo: copyObjectivesToVisit
    * Description: Method tha copies Objective fields from taa object to Visit
    * Modo: after insert, after update
    ********************************************************************************************************/
	public static void copyObjectivesToVisit(List<LAT_BR_TAA__c> triggerNew){
		List<String> visitIds = new List<String>();
		for (LAT_BR_TAA__c taa: triggerNew) {
			visitIds.add(taa.Visit__c);
		}

		Map<id, Visitas__c> MapVisits = new Map<id, Visitas__c>([SELECT id, LAT_BR_Client__c, LAT_BR_PRB__c 
																FROM Visitas__c WHERE id IN: visitIds]);

		for (LAT_BR_TAA__c taa: triggerNew) {
			if (MapVisits.get(taa.Visit__c) != null) {
				MapVisits.get(taa.Visit__c).LAT_BR_Client__c = taa.ClientObjectives__c;
				MapVisits.get(taa.Visit__c).LAT_BR_PRB__c = taa.PRBObjectives__c;
			}
		}

		if (!MapVisits.values().isEmpty()) {
			update MapVisits.values();
		}

	}

	/*********************************************************************************************************
    * Nombre del metodo: DeleteAgreements
    * Description: If aggrements comes from mobile app with toDelte field, the agreement is deleted.
    * Modo: after insert, after update
    ********************************************************************************************************/
	public static void DeleteAgreements(List<LAT_BR_TAAAgreement__c> triggerNew) {
		
		List<LAT_BR_TAAAgreement__c> aggList = new List<LAT_BR_TAAAgreement__c>();
		for (LAT_BR_TAAAgreement__c ag: triggerNew) {
			if (ag.toDelete__c) {
				aggList.add(new LAT_BR_TAAAgreement__c(id = ag.id));
			}
		}

		if (!aggList.isEmpty()) {
			Database.delete(aggList);
		}
	}


	/*********************************************************************************************************
    * Nombre del metodo: insertPDF
    * Description: Insert PDF for the visit once it has been closed.
    * Modo: after insert, after update
    ********************************************************************************************************/
	@future(callout = true)
	public static void insertPDF (Set <Id> taaIds) {

		List<Attachment> attList = new List<Attachment> ();

		for (LAT_BR_TAA__c taa: [SELECT Id, Visit__c, visit__r.Conta__r.Corporate_Name__c , Visit__r.Data_da_Visita__c , Visit__r.Hora_da_Visita__c from LAT_BR_TAA__c where id in :taaIds]) {

			// Reference the attachment page, pass in the taa ID
			PageReference pdf = Page.LAT_BR_TAAAttachment;
			pdf.getParameters().put('id',taa.id);
			pdf.setRedirect(true);

			// Take the PDF content
			Blob pdfBlob = !Test.isRunningTest() ? pdf.getContent() : Blob.valueOf('Testing');

	   		attList.add ( new Attachment (
	   			ParentId = taa.Visit__c,
	   			Name = 'TAA - ' + taa.Visit__r.Conta__r.Corporate_Name__c + ' - ' 
	   					+ taa.Visit__r.Data_da_Visita__c + ' - ' + taa.Visit__r.Hora_da_Visita__c + '.pdf',
	   			Body = pdfBlob
	   		));
	   		
		}

		if (!attList.isEmpty()) {
	   		insert attList;
		}
	}


	/*********************************************************************************************************
    * Nombre del metodo: sendEmailToContact
    * Description: Send email to contact if a TAA has been modified.
    * Modo: after insert, after update
    ********************************************************************************************************/
	@future(callout = true)
	public static void sendEmailToContact (Set <Id> taaIds) {

		EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'LAT_BR_TAAConfirmationEmailVisual'];

		List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

		for (LAT_BR_TAA__c taa: [SELECT Id, visit__r.Conta__r.Owner.email , Contact__c from LAT_BR_TAA__c where id in :taaIds]) {

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	  		mail.setTemplateId(et.id);
	  		mail.setCcAddresses(new String[]{taa.Visit__r.Conta__r.Owner.email});
	  		mail.setTargetObjectId(taa.Contact__c);
	  		mail.setWhatId(taa.id);
	  		
	   		emailsToSend.add(mail);
		}
		
		if (!emailsToSend.isEmpty()) {
	   		Messaging.sendEmail(emailsToSend);
	   	}
	}

}