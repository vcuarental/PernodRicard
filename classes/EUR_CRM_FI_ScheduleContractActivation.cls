/*************************************************************************************
* Name:         EUR_CRM_FI_ScheduleContractActivation
* Descriptopn:  Global scheduler that calls the EUR_CRM_FI_ContractActivationBatch batch file 
*               to activate FI Contracts.
*               Executed nightly
*
**************************************************************************************/

global class EUR_CRM_FI_ScheduleContractActivation implements Schedulable{

    // The schedule time in cron format 
    public static String sched = '0 00 * * * ?';
    // Various name variables
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Activate Finland Approved-Pending Activation Contracts';
    public static String JOB_NAME_RETRY = 'Activate Finland Approved-Pending Activation Contracts Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    /*
    * Main schedule function
    * creates a schedule job for the batch file
    * according to the sched time variable
    */
    global static String schedule() {
        EUR_CRM_FI_ScheduleContractActivation SC = new EUR_CRM_FI_ScheduleContractActivation(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    /*
    * Executes the batch job 
    * retries for 5 times consecutivly, and if it fails runs again in 30 minutes
    */
    global void execute(SchedulableContext sc) {
        // Runs for 5 times if it does not succeed
        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_FI_ContractActivationBatch b1 = new EUR_CRM_FI_ContractActivationBatch ();
            Id batchprocessid = Database.executeBatch(b1,50);  
        } 
        // If more than 5 trials already, runs a new schedule again in 30 minutes
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_FI_ScheduleContractActivation scRetry = new EUR_CRM_FI_ScheduleContractActivation(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }      
    }
}