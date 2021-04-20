/*********************************************************************************
 * Name: ASI_CRM_JP_SODeleteInactiveScheduler
 * Description: Scheduler for the ASI_CRM_JP_SODeleteInactiveBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/08/2017       Hugo Cheung             Created          
*/
global class ASI_CRM_JP_SODeleteInactiveScheduler implements Schedulable {
    global ASI_CRM_JP_SODeleteInactiveScheduler() {
    }
    
    global void execute(SchedulableContext sc) {
        Id jobId = Database.executeBatch(new ASI_CRM_JP_SODeleteInactiveBatch());
    }
}