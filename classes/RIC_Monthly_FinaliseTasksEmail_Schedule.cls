/*
Description: Planification pour la classe "RIC_Monthly_FinaliseTasksEmail" pour envoyer le mail le 1er de chaque mois
Author: Joyce Saidy
Date: 06/05/2019
version 1.0
Test class: RIC_Monthly_FinaliseTasksEmail_Schedule_Test
*/
global class RIC_Monthly_FinaliseTasksEmail_Schedule implements schedulable{  
    public String CRON_EXP = '0 0 8 1 1/1 ? *'; 
    global void execute(SchedulableContext sc){
        RIC_Monthly_FinaliseTasksEmail batch1 = new RIC_Monthly_FinaliseTasksEmail();
        ID batchprocessid = Database.executeBatch(batch1);
    }   
 }