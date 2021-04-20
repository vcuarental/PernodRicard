global class ASI_CRM_CN_ContractShare_Schd implements Schedulable {
    global void execute(SchedulableContext sc) {
        //check if there are 5 active batch jobs 
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
            database.executebatch(new ASI_CRM_CN_ContractShare_Batch(),100);
        } 
        if (Test.isRunningTest() || [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] >= 5){
            ASI_CRM_CN_ContractShare_Schd scRetry = new ASI_CRM_CN_ContractShare_Schd(); 
            Datetime dt = Datetime.now() + (0.00138); // 2 mins 
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('ContractShareScheRetry'+timeForScheduler,timeForScheduler,scRetry);
        } 
    }
}