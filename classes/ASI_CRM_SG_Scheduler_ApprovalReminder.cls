/***************************************************************************************************************************
 * Name:		ASI_CRM_SG_Scheduler_ApprovalReminder
 * Description:	Scheduler class for ASI_CRM_SG_Batch_ApprovalReminder
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 2017-11-11		Vincent Lam				Created				
 ****************************************************************************************************************************/
global class ASI_CRM_SG_Scheduler_ApprovalReminder implements Schedulable {

    global void execute(SchedulableContext sc) {

        Id jobId1 = Database.executeBatch(new ASI_CRM_SG_Batch_ApprovalReminder('Contract'), 200);
        System.debug('------ jobId ------ : ' + jobId1);
        Id jobId2 = Database.executeBatch(new ASI_CRM_SG_Batch_ApprovalReminder('Payment Request'), 200);
        System.debug('------ jobId ------ : ' + jobId2);
        Id jobId3 = Database.executeBatch(new ASI_CRM_SG_Batch_ApprovalReminder('FOC Request'), 200);
        System.debug('------ jobId ------ : ' + jobId3);

    }

}