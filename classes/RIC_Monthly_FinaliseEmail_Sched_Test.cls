/*
Description: Classe de test pour RIC_Monthly_FinaliseTasksEmail_Schedule
Author: Joyce Saidy
Date: 06/05/2019
version 1.0 
*/
@isTest
public class RIC_Monthly_FinaliseEmail_Sched_Test{ 
    static testMethod void test_RIC_WeeklyProjetTauxEmail_schedule(){
        RIC_Monthly_FinaliseTasksEmail_Schedule s = new RIC_Monthly_FinaliseTasksEmail_Schedule();
        System.schedule('RIC_Monthly_FinaliseTasksEmail', s.CRON_EXP, s);
    }
}