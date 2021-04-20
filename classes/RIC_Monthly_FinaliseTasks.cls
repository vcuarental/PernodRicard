public class RIC_Monthly_FinaliseTasks {
    
    private  List<Milestone1_Task__c> m_RicTaskList;
    public  List<Milestone1_Task__c> RicTaskList {
        get
        { 
            if(m_RicTaskList == null){
                  DateTime expired = System.now().addYears(-1);
                m_RicTaskList = [  select id  ,  Assigned_To__c ,createddate,RIC_Status__c,Project__c,RIC_Link_To_Task__c,Due_Date__c,Days_Late_Formula__c
                                    from Milestone1_Task__c
                                    where Assigned_To__c = : UserId and LastModifiedDate > :expired AND RIC_Status__c =: Label.RIC_Task_Finalise
                                    order by createddate asc ];
           } 
            return m_RicTaskList;
        }
    }
    
    public  string UserId {get; set;}
    
    public RIC_Monthly_FinaliseTasks() { 
    }
}