global class GDT_SetupAuditTrail_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		/* Batch execution */
		String executeAT = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_SetupAuditTrail_isActive', ',',false)[0];
		if(executeAT == 'true'){
			GDT_SetupAuditTrail_Batch b = new GDT_SetupAuditTrail_Batch();
			database.executebatch(b);
		}
	}
}