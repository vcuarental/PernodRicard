global class ASI_CRM_JP_AccountAddressSched implements Schedulable {
    
    public boolean testmode = false;
	global void execute(SchedulableContext sc) {
        executeBatch();
	}
    
    global void executeBatch(){
        if (testmode || [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued' OR Status = 'Holding') AND ApexClass.Name = 'ASI_CRM_JP_AccountAddressBatch'] >= 1){ 
            if ([SELECT count() FROM CronTrigger WHERE  CronJobDetail.Name like '%ASI_CRM_JP_AccountAddressSched%' AND NextFireTime != null] >= 1){
                system.debug('@@@CronTrigger');
            } 
            else {
                //schedule the schedulable class again in 2 mins
                ASI_CRM_JP_AccountAddressSched scRetry = new ASI_CRM_JP_AccountAddressSched(); 
                Datetime dt = Datetime.now();
                dt = dt.addMinutes(2);
                //dt = dt.addSeconds(5);
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
                Id schedId = System.Schedule('ASI_CRM_JP_AccountAddressSched'+timeForScheduler,timeForScheduler,scRetry);
            }
        } 
        else {
            Integer batchSize = 20;
            ASI_CRM_JP_AccountAddressBatch batch = new ASI_CRM_JP_AccountAddressBatch();
            database.executebatch(batch, batchSize);
        }
    }
}