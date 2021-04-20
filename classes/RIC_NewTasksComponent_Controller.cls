public class RIC_NewTasksComponent_Controller {
    
    public String receipientUserId {get; set;}
    public String relatedToProjectId {get; set;}
    public List<Milestone1_Task__c> listOfTasksToDisplay;
    
    public RIC_NewTasksComponent_Controller() {
        
    }
    
    public List<Milestone1_Task__c> getTasksToDisplay() {
        listOfTasksToDisplay = new List<Milestone1_Task__c>();
        List<Milestone1_Milestone__c> listOfPhases = [SELECT Id, Project__c FROM Milestone1_Milestone__c WHERE Project__c = :relatedToProjectId];
        
        if(listOfPhases != null) {
            Map<ID, Milestone1_Task__c> mapOfTasks = new Map<ID, Milestone1_Task__c>([SELECT Id, RIC_Link_To_Task__c, Project__c, Assigned_To__c, Due_Date__c
                                                                                      FROM Milestone1_Task__c 
                                                                                      WHERE Project_Milestone__c in :listOfPhases AND RIC_Type_Action__c = 'Avec Notification']);
            if(mapOfTasks != null) {
                Set<Milestone1_Task__c> setOfTasks = new Set<Milestone1_Task__c>();
                
                for(Milestone1_Task__c ricTask : mapOfTasks.values()) {
                    String ricTaskId = ricTask.Assigned_To__c;
                    if(ricTaskId.contains(receipientUserId)) {
                        setOfTasks.add(ricTask);
                    }
                }
                //Check if the user is in the acteur of a task
                List<RIC_Acteur__c> listProjectActeurs = [SELECT Id, RIC_Action__c FROM RIC_Acteur__c WHERE RIC_Action__c in :mapOfTasks.values() AND RIC_Acteur_User__c  = :receipientUserId];
                if(listProjectActeurs != null) {
                    for(RIC_Acteur__c acteur : listProjectActeurs) {
                        setOfTasks.add(mapOfTasks.get(acteur.RIC_Action__c));
                    }
                }
                
                listOfTasksToDisplay.addAll(setOfTasks);
            }
        }
        return listOfTasksToDisplay;
    }
}