global class EUR_CRM_PT_AssignOPTargetActualNoSched implements Schedulable {
	global void execute(SchedulableContext sc) {
        Id jobId = Database.executeBatch(new EUR_CRM_PT_AssignOPTargetActualNoBatch());
        System.debug('------ jobId ------ : ' + jobId);
    }
}