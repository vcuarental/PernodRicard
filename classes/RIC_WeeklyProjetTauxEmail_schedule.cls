/*
Description: Planification pour la classe "RIC_WeeklyProjetTauxEmail" pour envoyer le mail chaque mardi à 8:30
Author: Joyce Saidy
Date: 06/05/2019
version 1.0
Test class: RIC_WeeklyProjetTauxEmail_schedule_Test
*/
global class RIC_WeeklyProjetTauxEmail_schedule implements schedulable{  
    public String CRON_EXP = '0 30 8 ? * TUE *'; 
    global void execute(SchedulableContext sc){
        RIC_WeeklyProjetTauxEmail batch1 = new RIC_WeeklyProjetTauxEmail();
        ID batchprocessid = Database.executeBatch(batch1);
    }   
 }