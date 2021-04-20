global class RIC_SCHD_WeeklyTaskEmail_Opp implements Schedulable{
    
    //--------- Run anonymous to schedule: ------------------------    
    /*SCHD_WeeklyTaskEmail_Opp scheduler = new SCHD_WeeklyTaskEmail_Opp();
public String dailyCronExpression = '0 0 7 ? * WED *';
System.schedule('WeeklyTaskEmail_Opp every wednesday @7am', dailyCronExpression, scheduler);  */
    
    private static final Integer EMAIL_CNT = 200;
    global void execute(SchedulableContext SC) {
        RIC_WeeklyTaskEmail_Opp batch = new RIC_WeeklyTaskEmail_Opp();
        database.executeBatch(batch,EMAIL_CNT);
    }
}