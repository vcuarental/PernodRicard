/**********************************************************************************
 * Name : ASI_CRM_SG_YtdAchievementNotif_Scheduler
 * Created : DC @03/18/2016 1:07 PM
 * Revision History:
 * 1. 03/18/2016 - [DC 1.0] Created
 **********************************************************************************/

global class ASI_CRM_SG_YtdAchievementNotif_Scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Id jobId = Database.executeBatch(new ASI_CRM_SG_YtdAchievementNotif_Batch(), 1);
        System.debug('------ jobId ------ : ' + jobId);

    }

}