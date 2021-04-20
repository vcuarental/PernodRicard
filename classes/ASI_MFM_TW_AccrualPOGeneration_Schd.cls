global class ASI_MFM_TW_AccrualPOGeneration_Schd implements Schedulable {
    global void execute(SchedulableContext sc) {
		
        Integer NoOfPendingBatch =[SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
    	if ( NoOfPendingBatch < 5){ 
            database.executebatch(new ASI_MFM_TW_AccrualPOGeneration_Batch());
        }
        
        if (Test.isRunningTest() || NoOfPendingBatch >= 5){
            ASI_MFM_TW_AccrualPOGeneration_Schd  scRetry = new ASI_MFM_TW_AccrualPOGeneration_Schd(); 
            Datetime dt = Datetime.now() + (0.00138); // 2 mins 
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('MFM_TW_AccrualPoGeneration_Reschedule'+timeForScheduler,timeForScheduler,scRetry);
        } 
    
    }
}