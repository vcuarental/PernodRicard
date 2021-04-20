global class GDT_SetupAuditTrail_Batch implements Database.Batchable<sObject> , Database.Stateful{
	
	String query;
	Datetime lastExecutionDate{get;set;}
	Set<String> bypassUsers{get;set;}
	Set<String> toControlActions{get;set;}
	Set<String> toControlSections{get;set;}


	global GDT_SetupAuditTrail_Batch() {
		GDT_Setup_Audit_Trail__c lastAT = [Select id,CreatedDate from GDT_Setup_Audit_Trail__c order by CreatedDate desc limit 1];
		Integer retentionDays = INTEGER.valueOf(GDT_GeneralConfigDAO.getValueAsStringArray('GDT_SetupAuditTrail_RetentionInDays', ',',false)[0]);
		Date retentionDate = Date.today().addDays(-retentionDays);
		List<GDT_Setup_Audit_Trail__c> toDelete = [Select id from GDT_Setup_Audit_Trail__c where CreatedDate__c <: retentionDate];
		delete toDelete;
		lastExecutionDate = lastAT.CreatedDate;
		populateFilters();
	}

	public void populateFilters(){
		toControlActions = new Set<String>();
		toControlSections = new Set<String>();
		for(GDT_SetupAuditTrail_SectionAction__c secAct : [Select id, Action__c,Section__c,Section_to_control__c,Action_to_control__c from GDT_SetupAuditTrail_SectionAction__c where Action_to_control__c = True OR Section_to_control__c = True]){
			if(secAct.Action_to_control__c)toControlActions.add(secAct.Action__c);
			if(secAct.Section_to_control__c)toControlSections.add(secAct.Section__c);
		}
		bypassUsers = GDT_GeneralConfigDAO.getValueAsStringSet('GDT_SetupAuditTrail_BypassControl',',',false);

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		this.query = 'SELECT Action,CreatedById,CreatedBy.username, CreatedDate,Display,Id,Section,DelegateUser FROM SetupAuditTrail where CreatedDate >=: lastExecutionDate';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<SetupAuditTrail> scope) {
		try {
			List<GDT_Setup_Audit_Trail__c> toInsert = new List<GDT_Setup_Audit_Trail__c>();
			
			for(SetupAuditTrail obj : scope) {
				GDT_Setup_Audit_Trail__c cObj_SetupAuditTrail = new GDT_Setup_Audit_Trail__c(); //Custom Object : Setup Audit Trail
				cObj_SetupAuditTrail.Name               = obj.Id;
				cObj_SetupAuditTrail.Action__c          = obj.Action;
				cObj_SetupAuditTrail.CreatedById__c     = obj.CreatedById;
				cObj_SetupAuditTrail.CreatedDate__c     = obj.CreatedDate;
				cObj_SetupAuditTrail.DelegateUser__c    = obj.DelegateUser;
				cObj_SetupAuditTrail.Display__c         = obj.Display;
				cObj_SetupAuditTrail.Section__c         = obj.Section;

				String username = obj.CreatedBy == null ? '' : obj.CreatedBy.username;
				Boolean baypassUser = bypassUsers.contains(username);
				Boolean notDelegatedUser = obj.DelegateUser != null;
				Boolean actionToControl = toControlActions.contains(obj.Action);
				Boolean sectionToControl = toControlSections.contains(obj.Section);

				if((baypassUser && notDelegatedUser) || (!baypassUser && sectionToControl) || (!baypassUser && actionToControl)){
									system.debug(cObj_SetupAuditTrail);

					cObj_SetupAuditTrail.toControl__c = true;
				}
				toInsert.add(cObj_SetupAuditTrail);
			}

			insert toInsert;
			
		} catch(Exception e) {
			System.debug(e.getMessage());
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];

		// Send an email to the Apex job's submitter 
		// notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('GDT Audit Trial : Process Completed');
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
}