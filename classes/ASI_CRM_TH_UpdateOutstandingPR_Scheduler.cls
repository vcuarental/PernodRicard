/*********************************************************************************
 * Name: ASI_CRM_TH_UpdateOutstandingPR_Scheduler 
 * Description: Scheduler for ASI_CRM_TH_Update_Outstanding_PR_Batch 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/27/2016       Introv: Twinkle LI      Created
*********************************************************************************/

global class ASI_CRM_TH_UpdateOutstandingPR_Scheduler implements Schedulable{
   global void execute(SchedulableContext sc) {
      ASI_CRM_TH_UpdateOutstandingPR_Batch batch = new ASI_CRM_TH_UpdateOutstandingPR_Batch(); 
      
      //check if there are 5 active batch jobs 
        if (!Test.isRunningTest() && [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
            database.executebatch(new ASI_CRM_TH_UpdateOutstandingPR_Batch());
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            ASI_CRM_TH_UpdateOutstandingPR_Scheduler scRetry = new ASI_CRM_TH_UpdateOutstandingPR_Scheduler(); 
            Datetime dt = Datetime.now() + (0.00138); // 2 mins 
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('UpdateOutstangingPRScheRetry'+timeForScheduler,timeForScheduler,scRetry);
        } 
   }
}