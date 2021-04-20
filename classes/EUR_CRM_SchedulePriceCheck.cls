/*************************************************************************************
* Name:         EUR_CRM_SchedulePriceCheck
* Descriptopn:  Global scheduler that calls the EUR_CRM_EnablePriceCheckBatch batch file 
*               to set the price checks field on accounts to true.
*               Executed nightly
*
**************************************************************************************/
global class EUR_CRM_SchedulePriceCheck implements Schedulable {

    // The schedule time in cron format 
    public static String sched = '0 00 * * * ?';
    // Various name variables
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Enable Account Price Checks';
    public static String JOB_NAME_RETRY = 'Enable Account Price Checks Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    /*
    * Main schedule function
    * creates a schedule job for the batch file
    * according to the sched time variable
    */
    global static String schedule() {
        EUR_CRM_SchedulePriceCheck SC = new EUR_CRM_SchedulePriceCheck(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    /*
    * Executes the batch job 
    * retries for 5 times consecutivly, and if it fails runs again in 30 minutes
    */
    global void execute(SchedulableContext sc) {
        // Runs for 5 times if it does not succeed
        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_EnablePriceCheckBatch b1 = new EUR_CRM_EnablePriceCheckBatch();
            Id batchprocessid = Database.executeBatch(b1,50);  
        } 
        // If more than 5 trials already, runs a new schedule again in 30 minutes
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_SchedulePriceCheck scRetry = new EUR_CRM_SchedulePriceCheck(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }      
    }
}