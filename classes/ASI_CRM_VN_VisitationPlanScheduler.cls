/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_VisitationPlanScheduler
 * Description: Daily Batch Job finds unvisited Visitation Plan Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-04       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

global class ASI_CRM_VN_VisitationPlanScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new ASI_CRM_VN_VisitationPlanBatch());
    }
}