global class ASI_TH_CRM_SITDetailOTFinalInitScheduler implements Schedulable{
   global void execute(SchedulableContext sc) {
      ASI_TH_CRM_SITDetailOTFinalInitBatch sitDetailOTFinalInitBatch = new ASI_TH_CRM_SITDetailOTFinalInitBatch(); 
      
      //check if there are 5 active batch jobs 
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
            database.executebatch(new ASI_TH_CRM_SITDetailOTFinalInitBatch());
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            ASI_TH_CRM_RSPGenarateScheduler scRetry = new ASI_TH_CRM_RSPGenarateScheduler(); 
            Datetime dt = Datetime.now() + (0.00138); // 2 mins 
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('RSPGenarateScheRetry'+timeForScheduler,timeForScheduler,scRetry);
        } 
   }
}