/*********************************************************************
 Dev: Waldemar Mayo  Version: 1  Consulting: Valuenet
**********************************************************************/

global class PCS01_AnalyticsOfCCBatchAccSche_AR implements Schedulable{
    
    public map<Id, Account> mapIdAccountAccounts;
    public String emails;
    
    global void Execute(SchedulableContext SC){
        PCS01_AnalyticsOfCCBatchAcc_AR batch = new PCS01_AnalyticsOfCCBatchAcc_AR();
        batch.mapIdAccountAccounts = this.mapIdAccountAccounts;
        batch.emails = this.emails;
        Database.executeBatch(batch);
    }
}