public class VFC01_PRJTimeline {

    private final ESNProject__c project;
    //Our collection of the class/wrapper object ProjectItems    
    public List<ProjectItem> projectItems {get; set;}
    public List<ProjectItem> projectEvents {get; set;}
    public List<ProjectItem> projectTasks {get; set;} 
    public integer numbOfElts {get; set;}
    public integer numbOfEvents {get; set;}
    public integer numbOfTasks {get; set;}
    private Integer COLLECTIONITEMS_MAXSIZE = 1000;
    public boolean isLegend {get; set;}
    private String priorityTaskFilter {get; set;}
    private String typeTaskFilter {get; set;}
    private boolean eventSupport {get; set;}
    private boolean taskSupport {get; set;}
     
     
    public VFC01_PRJTimeline(ApexPages.StandardController stdController) {        
        this.project = (ESNProject__c) stdController.getRecord();
        CS001_TimelineConfig__c CS= CS001_TimelineConfig__c.getInstance();
        isLegend = CS.DisplayLegend__c;  
        priorityTaskFilter = CS.PriorityTaskFilter__c;
        typeTaskFilter = CS.TypeTaskFilter__c;
        eventSupport = CS.EventSupport__c;
        taskSupport = CS.taskSupport__c;
        System.debug('#### Project Timeline configured with : ');
        System.debug('#### Support for Events ? : ' + eventSupport);
        System.debug('#### Support for Tasks ? : ' + taskSupport); 
        if (typeTaskFilter == null) typeTaskFilter= '';
        getProjectItems();
    }
    
    
    //This method uses a simple SOQL query to return a List of Events/Tasks and convert them in Wrapper objects    
    public List<ProjectItem> getProjectItems() {        
        if (projectItems == null) {            
            projectItems = new List<ProjectItem>();
            projectEvents = new List<ProjectItem>();
            if (eventSupport) {
                for (Event eve : [select Id, Subject, ActivityDate,TECH_TruncatedDescription__c, owner.firstname, owner.lastname, StartDateTime, EndDateTime,Type FROM Event where whatid = :project.Id and IsChild = false and IsRecurrence = false  limit :COLLECTIONITEMS_MAXSIZE]) {                
                    projectEvents.add(new ProjectItem(eve));            
                }
                for (Event eve : [select Id, Subject, ActivityDate,TECH_TruncatedDescription__c, owner.firstname, owner.lastname, StartDateTime, EndDateTime,Type FROM Event where whatid in (select id from ESNStream__c where Project__c = :project.id  ) and  IsChild = false and IsRecurrence = false limit :COLLECTIONITEMS_MAXSIZE]) {                
                    projectEvents.add(new ProjectItem(eve));            
                }
 
        }    
            projectTasks  = new List<ProjectItem>();
            if (taskSupport) {
                if (priorityTaskFilter == 'All') {
                    if (typeTaskFilter.length() == 0 ) {
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, ActivityDate, owner.firstname, owner.lastname, Status,IsClosed,Priority,Type FROM Task where whatid = :project.Id and ActivityDate != null  limit :COLLECTIONITEMS_MAXSIZE]) {                
                            projectTasks .add(new ProjectItem(eve));            
                        }
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, owner.firstname, owner.lastname, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid in (select id from ESNStream__c where Project__c = :project.id) and ActivityDate != null limit :COLLECTIONITEMS_MAXSIZE]) {                
                            projectTasks .add(new ProjectItem(eve));            
                        }
 
                } else {
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, owner.firstname, owner.lastname,  ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :project.Id and ActivityDate!= null and Type in :typeTaskFilter.split(',') limit :COLLECTIONITEMS_MAXSIZE]) {                
                            projectTasks .add(new ProjectItem(eve));   
                        }
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, owner.firstname, owner.lastname, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid in (select id from ESNStream__c where Project__c = :project.id) and ActivityDate!= null and Type in :typeTaskFilter.split(',') limit :COLLECTIONITEMS_MAXSIZE]) {                
                            projectTasks .add(new ProjectItem(eve));   
                        }
 
                  }  
                } else {
                    for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, owner.firstname, owner.lastname, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :project.Id and ActivityDate!= null and Priority= :priorityTaskFilter limit :COLLECTIONITEMS_MAXSIZE]) {                
                        projectTasks .add(new ProjectItem(eve));            
                    }
                  
                    for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, owner.firstname, owner.lastname, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid in (select id from ESNStream__c where Project__c = :project.id) and ActivityDate!= null and Priority= :priorityTaskFilter  limit :COLLECTIONITEMS_MAXSIZE]) {                
                        projectTasks .add(new ProjectItem(eve));            
                    }
              }         
            }
        }        
        System.Debug('projectItems size : ' + projectItems.size()); 
        numbOfEvents = projectEvents.size(); 
        numbOfTasks = projectTasks.size();       
        numbOfElts = numbOfEvents + numbOfTasks;        
        return projectItems;    
    }
    
    public class ProjectItem {        
        public Datetime startDateTime {get;set;}        
        public Datetime endDateTime {get;set;}         
        public Date theDate {get;set;}        
        public String subject {get;set;}        
        public String identifiant {get;set;}  
        public String type  {get;set;}
        public final String TASK = 'Task';
        public final String EVENT = 'Event';
        public boolean durationEvent {get;set;}             
        public String priority {get;set;}
        public final String LOW = 'Low';
        public final String NORMAL = 'Normal';
        public final String HIGH = 'High';
        public String itemType {get;set;}
        public String description {get;set;}
         
        //Constructor for Event object     
        public ProjectItem(Event eve) {            
            identifiant = eve.Id;            
            startDateTime = eve.StartDateTime;            
            theDate = eve.StartDateTime.date();            
            endDateTime = eve.EndDateTime;            
            subject = eve.Subject;               
            type = EVENT;
            description = 'Event <br/> <b>Assigned to</b>: ' + eve.owner.firstname + ' ' + eve.owner.lastname + '.'  ;
            durationEvent = !startDateTime.isSameDay(endDateTime);
            priority = NORMAL;
            itemType = eve.Type;     
        }
        
        //Constructor for Task object
        public ProjectItem(Task eve) {            
            identifiant = eve.Id;            
            startDateTime = eve.ActivityDate;            
            theDate = eve.ActivityDate;            
            subject = eve.Subject;      
            type = TASK;
            description = 'Task <br/> <b>Assigned to</b>: ' + eve.owner.firstname + ' ' + eve.owner.lastname + '<br/> <b>Priority</b>: ' + eve.Priority;
            durationEvent = false;              
            priority = eve.Priority;
            itemType = eve.Type;
        }            
    }
}