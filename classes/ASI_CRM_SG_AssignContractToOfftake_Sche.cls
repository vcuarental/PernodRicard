/**********************************************************************************
 * Name : ASI_CRM_SG_AssignContractToOfftake_Sche
 * Created : Vincent Lam @ 24 Jan 2017
 * Revision History:
 * 1. 24 Jan 2017 - [VL 1.0] Created
 **********************************************************************************/

global class ASI_CRM_SG_AssignContractToOfftake_Sche implements Schedulable {
    global void execute(SchedulableContext sc) {

        Id jobId = Database.executeBatch(new ASI_CRM_SG_AssignContractToOfftake_Batch(), 200);
        System.debug('------ jobId ------ : ' + jobId);

    }
}