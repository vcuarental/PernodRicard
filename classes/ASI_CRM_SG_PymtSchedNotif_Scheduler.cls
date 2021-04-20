/**********************************************************************************
 * Name : ASI_CRM_SG_PymtSchedNotif_Scheduler
 * Created : Vincent Lam @ 18 Apr 2016
 * Revision History:
 * 1. 18 Apr 2016 - [VL 1.0] Created
 **********************************************************************************/

global class ASI_CRM_SG_PymtSchedNotif_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {

        Id jobId = Database.executeBatch(new ASI_CRM_SG_PymtSchedIssuanceNotif_Batch(), 50);
        System.debug('------ jobId ------ : ' + jobId);

    }
}