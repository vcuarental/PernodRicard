public with sharing class LAT_BR_PromotionalClientVisitsController {
    public List<TaskWrapper> taskList {get; set;}
    public LAT_AccountInAction__c client {get; set;}
    public String visitId{get;set;}
    public List<LAT_Visit_Task__c> tasksSelected = new List<LAT_Visit_Task__c>();

    public LAT_BR_PromotionalClientVisitsController() {

        this.taskList = new List<TaskWrapper>();
        visitId = system.currentPageReference().getparameters().get('visitId');
        String clientId = [Select id,conta__c from Visitas__c where id =: visitId].conta__c;


        Set<String> allTasks = new Set<String>();

        for(LAT_Visit_Task__c vTask : [Select id,LAT_TaskId__c,LAT_Task__c from LAT_Visit_Task__c where LAT_Visita__c =: visitId]){
            allTasks.add(vTask.LAT_TaskId__c);
            tasksSelected.add(vTask);
        }

        for (LAT_AccountInAction__c acc : [SELECT id,(Select id,Subject,ActivityDate from Tasks where status != 'Concluído'), LAT_PromotionalAction__r.LAT_endDate__c, 
                                                        LAT_PromotionalAction__r.LAT_StartDate__c, LAT_Account__c 
                                                    FROM LAT_AccountInAction__c 
                                                    WHERE LAT_Account__c =: clientId]){
            for(Task t : acc.tasks){
                system.debug('bbbb ' + t.id);
                if(allTasks.contains(t.id)){
                    taskList.add(new TaskWrapper(true, t));
                }else{
                    taskList.add(new TaskWrapper(false, t));
                }
            }
        }


        
    }

    public pageReference doSave() {
        List<LAT_Visit_Task__c> toUpdate = new List<LAT_Visit_Task__c>();
        for (TaskWrapper tVisit: taskList) {
            if (tVisit.selected) {
                LAT_Visit_Task__c vtask = new LAT_Visit_Task__c();
                vtask.LAT_TaskId__c = tVisit.task.id;
                vtask.LAT_Visita__c = visitId;
                vtask.name = tVisit.task.subject;
                toUpdate.add(vtask);
            } 
        }

        try {
            delete tasksSelected;
            insert toUpdate;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, 
                                                                        'Successfully saved');
            ApexPages.addMessage(errorMsg);
        } catch (Exception e) {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                          e.getMessage());
            ApexPages.addMessage(errorMsg);
        }

        return null;
    }

    //Inner class for Sales Prevission section
    public class TaskWrapper {
        public Task task {get; set;}
        public Boolean selected {get; set;}
        
        public TaskWrapper (Boolean selected, Task v){
            this.task = v;
            this.selected = selected;
        }
    }
}