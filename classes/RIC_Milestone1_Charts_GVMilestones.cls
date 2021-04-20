public class RIC_Milestone1_Charts_GVMilestones {
    
    public Integer numberOfOpenTasks {get; set;}
    public Integer numberOfLateTasks {get; set;}
    public Integer numberOfCompleteTasks {get; set;}
    public String filterFieldName;
    List<Sobject> listOfTasks;
    public String objectType;
    
    public RIC_Milestone1_Charts_GVMilestones(ApexPages.StandardController stdController) {
        
        numberOfOpenTasks = 0;
        numberOfLateTasks = 0;
        numberOfCompleteTasks = 0;
        String objectId = stdController.getId();
        initFieldNames(objectId);
        retrieveData(objectId);
        
        if(listOfTasks != null) {
            for(Sobject sObj : listOfTasks) {
                Milestone1_Task__c ricTask = (Milestone1_Task__c) sObj;
                if(ricTask.Complete__c)
                    numberOfCompleteTasks += 1;
                else if(ricTask.Days_Late_Formula__c > 0)
                    numberOfLateTasks += 1;
                else
                    
                   numberOfOpenTasks += 1;
                
            }
        }
    }
    
    private void initFieldNames(String objectId){
        if(objectId != null){
            if(objectId.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){
                filterFieldName = 'Project_Milestone__r.Project__c';
            }
            else if(objectId.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){
                filterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
            }
            objectType = Schema.SObjectType.Milestone1_Task__c.getName();
        }
    }
    
    private void retrieveData(String objectId){
        String query = 'Select Complete__c, Days_Late_Formula__c FROM '+ objectType + ' where '+ filterFieldName +'=\''+ objectId +'\'';
        System.debug('### Query: ' + query);
        listOfTasks = Database.query(query);
    }
}