@isTest
public class RIC_SCHED_LateAction_Test{
    
    static testMethod void test_SCHD003_AP02Event_Batch(){
        RIC_SCHED_LateAction s = new RIC_SCHED_LateAction();
        System.schedule('RIC_SCHED_LateAction', s.CRON_EXP, s);
    }
}