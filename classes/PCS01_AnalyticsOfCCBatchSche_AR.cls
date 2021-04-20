/*********************************************************************
 Dev: Waldemar Mayo  Version: 1  Consulting: Valuenet
**********************************************************************/

global class PCS01_AnalyticsOfCCBatchSche_AR implements Schedulable{
    
    global void Execute(SchedulableContext SC){
        PCS01_AnalyticsOfCCBatch_AR batch = new PCS01_AnalyticsOfCCBatch_AR();
        Database.executeBatch(batch);
    }
}