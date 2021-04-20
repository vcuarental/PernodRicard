global class RIC_SCHD_WeeklyTaskEmail implements Schedulable{
    
    //--------- Run anonymous to schedule: ------------------------    
    /*RIC_SCHD_WeeklyTaskEmail scheduler = new RIC_SCHD_WeeklyTaskEmail();
public String dailyCronExpression = '0 0 7 ? * MON *';
System.schedule('WeeklyTaskEmail every monday @7am', dailyCronExpression, scheduler);  */
    
    private static final Integer EMAIL_CNT = 200;
    global void execute(SchedulableContext SC) {
        RIC_WeeklyTaskEmail batch = new RIC_WeeklyTaskEmail();
        database.executeBatch(batch,EMAIL_CNT);
    }
}