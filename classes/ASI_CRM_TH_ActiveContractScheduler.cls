global class ASI_CRM_TH_ActiveContractScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      ASI_CRM_TH_ActiveContractBatch activeContractBatch= new ASI_CRM_TH_ActiveContractBatch(); 
      
        //check if there are 5 active batch jobs 
        if (!Test.isRunningTest() && [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
            database.executebatch(activeContractBatch);
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            ASI_CRM_TH_ActiveContractScheduler scRetry = new ASI_CRM_TH_ActiveContractScheduler(); 
            Datetime dt = Datetime.now() + (0.00138); // 2 mins 
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('RSPGenarateScheRetry'+timeForScheduler,timeForScheduler,scRetry);
        } 
   }
}