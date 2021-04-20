/**
* @Author: Christia Al Tawil
* Test Class: RIC_AP02_Milestone1Task_Test
* Code Coverage from RIC_AP02_Milestone1Task_Test 96%
*/
public class RIC_AP02_Milestone1Task {
 public static void updateTasksStatus(Map<Id,Milestone1_Project__c> oldMap, Map<Id,Milestone1_Project__c> newMap) {
     

        Set<Id> myId = new Set<Id>();
        List<Milestone1_Task__c> listTasksToUpdate = new List<Milestone1_Task__c>();
        Map<Id, Milestone1_Project__c> projectsMap = new Map<Id, Milestone1_Project__c>();
     System.debug('Chrsitia'+ newMap.values() );
        for(Milestone1_Project__c pr : newMap.values()){
            if(pr.RIC_Status__c == 'Clôturé') {
             
                projectsMap.put(pr.Id, pr);
            }
        }
        //Update the related tasks according to the Project status
        if(projectsMap.size() > 0) {
            List<Milestone1_Task__c> allTasksForProjects = [SELECT id, RIC_Task_Sent__c, RIC_Status__c, RIC_IsPickVal__c, Project_Milestone__r.Project__c
                                                            FROM Milestone1_Task__c 
                                                            WHERE Milestone1_Task__c.Project_Milestone__r.Project__c IN :projectsMap.keySet()];
            
            Map<String, List<Milestone1_Task__c>> mapProjectAndTasks = new Map<String, List<Milestone1_Task__c>>();
            if(allTasksForProjects != null && allTasksForProjects.size() > 0) {
                for(Milestone1_Task__c cTask : allTasksForProjects) {
                    if(mapProjectAndTasks.containsKey(cTask.Project_Milestone__r.Project__c))
                        mapProjectAndTasks.get(cTask.Project_Milestone__r.Project__c).add(cTask);
                    else
                        mapProjectAndTasks.put(cTask.Project_Milestone__r.Project__c, new List<Milestone1_Task__c> {cTask});
                }
                
                for(Milestone1_Project__c pr : projectsMap.values()){
                    List<Milestone1_Task__c> listProjectTasks = mapProjectAndTasks.get(pr.Id);
                    if(listProjectTasks != null && listProjectTasks.size() > 0) {
                        for(Milestone1_Task__c cTask : listProjectTasks) {
                            if('En cours'.equalsIgnoreCase(cTask.RIC_Status__c)){
                                cTask.RIC_Status__c = 'Non réalisé';
                                 listTasksToUpdate.add(cTask);
                            }   
                        }
                    }
                }
                 update listTasksToUpdate; 
             
         
            }
        }
    }
}