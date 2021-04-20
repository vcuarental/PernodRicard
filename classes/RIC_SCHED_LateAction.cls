global with sharing class RIC_SCHED_LateAction implements schedulable{

    public  String CRON_EXP = '0 0 2 1/1 * ? *';

    global void execute(SchedulableContext sc){
        RIC_Batch_LateActions batch1 = new RIC_Batch_LateActions();
        ID batchprocessid = Database.executeBatch(batch1);
    }   
 }