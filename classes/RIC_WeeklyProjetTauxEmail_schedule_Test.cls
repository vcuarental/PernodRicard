/*
Description: Classe de test pour RIC_WeeklyProjetTauxEmail_schedule
Author: Joyce Saidy
Date: 06/05/2019
version 1.0 
*/
@isTest
public class RIC_WeeklyProjetTauxEmail_schedule_Test{
    
    static testMethod void test_RIC_WeeklyProjetTauxEmail_schedule(){
        RIC_WeeklyProjetTauxEmail_schedule s = new RIC_WeeklyProjetTauxEmail_schedule();
        System.schedule('RIC_WeeklyProjetTauxEmail', s.CRON_EXP, s);
    }
}