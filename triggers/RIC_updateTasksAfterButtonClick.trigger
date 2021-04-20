/*
Nazim Dabouz nazim.dabouz@bluewolfgroup.com Christophe Averseng christophe.averseng@bluewolfgroup.com

Once the button "Diffuser les actions" is clicked, it will update a hidden field RIC_Task_Status__c
That will trigger this Trigger. This trigger will update all the tasks (Actions) related to the Project 
at hand. This in turn will trigger a workflow rule that will send all the tasks to their assigned users.

*/

trigger RIC_updateTasksAfterButtonClick on Milestone1_Project__c (after update) {
    //TMA JSA 156
    List<Milestone1_Project__c> ListProjets = new List <Milestone1_Project__c> ();
    for(Milestone1_Project__c proj:Trigger.new)
    {
        if(proj.RIC_Code_Article__c!=trigger.oldMap.get(proj.Id).RIC_Code_Article__c || proj.RIC_Lieu__c!=trigger.oldMap.get(proj.Id).RIC_Lieu__c)
        {
            ListProjets.add(proj);
        }
    }
    if(ListProjets!=null && ListProjets.size()>0)
    {
        RIC_AP01_RIC_Projet.MAJChampsOnArticle(ListProjets);
    }
    System.debug('Chrsitia');
    RIC_AP02_Milestone1Task.updateTasksStatus(trigger.oldMap, trigger.newMap);
    RIC_AP01_Milestone1Project.updateRelatedTasks(trigger.oldMap, trigger.newMap);
    RIC_AP01_Milestone1Project.sendStatusChangedNotification(trigger.oldMap, trigger.new);
    RIC_AP01_Milestone1Project.notifyAssignedToUsers(trigger.oldMap, trigger.newMap);
    RIC_AP01_Milestone1Project.shareProjectWithCoordinator(trigger.oldMap, trigger.newMap, true);
    /*
for(Milestone1_Project__c pr : Trigger.new){
if(pr.RIC_Task_Status__c == 'Sent') {
myId.add(pr.id);
}

if(!myId.isEmpty()){
// Find all Tasks related to Project
List<Milestone1_Task__c> taskUpdate = [SELECT id, RIC_Task_Sent__c, RIC_Status__c 
FROM Milestone1_Task__c 
WHERE RIC_IsPickVal__c = 'True'
AND Milestone1_Task__c.Project_Milestone__r.Project__c IN :myId];

for (Milestone1_Task__c task : taskUpdate) {
task.RIC_Task_Sent__c = 'Yes'; //Value to give to hidden Field
}
update taskUpdate; //Update all Tasks related to Project with defined value
}
}*/ 
}