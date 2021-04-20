/*********************************************************************************
 * Name:ASI_CRM_SG_AssignWineCat_Sche
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-08-03       Laputa: Vincent         Created
*********************************************************************************/
global class ASI_CRM_SG_AssignWineCat_Sche implements Schedulable {
    global void execute(SchedulableContext sc) {

        Id jobId = Database.executeBatch(new ASI_CRM_SG_AssignWineCat_Batch(), 200);
        System.debug('------ jobId ------ : ' + jobId);

    }
}