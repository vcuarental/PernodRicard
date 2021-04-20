public class VFC01_RLSTimeline {

    private final Release__c Release;
    //Our collection of the class/wrapper object ReleaseItems    
    public List<ReleaseItem> ReleaseItems {get; set;}
    public List<ReleaseItem> ReleaseEvents {get; set;}
    public List<ReleaseItem> ReleaseTasks {get; set;} 
    public integer numbOfElts {get; set;}
    public integer numbOfEvents {get; set;}
    public integer numbOfTasks {get; set;}
    public CS001_TimelineConfig__c CS {get; set;}
    private Integer COLLECTIONITEMS_MAXSIZE = 1000;
    public boolean isLegend {get; set;}
    private String priorityTaskFilter {get; set;}
    private String typeTaskFilter {get; set;}
    private boolean eventSupport {get; set;}
    private boolean taskSupport {get; set;}
     
     
    public VFC01_RLSTimeline(ApexPages.StandardController stdController) {        
        this.Release = (Release__c) stdController.getRecord();
        CS= CS001_TimelineConfig__c.getInstance();
        isLegend = CS.DisplayLegend__c;  
        priorityTaskFilter = CS.PriorityTaskFilter__c;
        typeTaskFilter = CS.TypeTaskFilter__c;
        eventSupport = CS.EventSupport__c;
        taskSupport = CS.taskSupport__c;
        System.debug('#### Release Timeline configured with : ');
        System.debug('#### Support for Events ? : ' + eventSupport);
        System.debug('#### Support for Tasks ? : ' + taskSupport); 
        if (typeTaskFilter == null) typeTaskFilter= '';
        getReleaseItems();
    }
    
    
    //This method uses a simple SOQL query to return a List of Events/Tasks and convert them in Wrapper objects    
    public List<ReleaseItem> getReleaseItems() {        
        if (ReleaseItems == null) {            
            ReleaseItems = new List<ReleaseItem>();
            ReleaseEvents = new List<ReleaseItem>();
            if (eventSupport) {
                for (Event eve : [select Id, Subject, ActivityDate,TECH_TruncatedDescription__c, StartDateTime, EndDateTime,Type FROM Event where whatid = :Release.Id AND IsChild = false and IsRecurrence = false limit :COLLECTIONITEMS_MAXSIZE]) {                
                    ReleaseEvents.add(new ReleaseItem(eve));            
                }
                
 
        }    
            ReleaseTasks  = new List<ReleaseItem>();
            if (taskSupport) {
                if (priorityTaskFilter == 'All') {
                    if (typeTaskFilter.length() == 0 ) {
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :Release.Id and ActivityDate != null  limit :COLLECTIONITEMS_MAXSIZE]) {                
                            ReleaseTasks .add(new ReleaseItem(eve));            
                        }
                        
 
                	} else {
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :Release.Id and ActivityDate!= null and Type in :typeTaskFilter.split(',') limit :COLLECTIONITEMS_MAXSIZE]) {                
                            ReleaseTasks .add(new ReleaseItem(eve));   
                        }
                        
 
                  }  
                } else {
                    for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :Release.Id and ActivityDate!= null and Priority= :priorityTaskFilter limit :COLLECTIONITEMS_MAXSIZE]) {                
                        ReleaseTasks .add(new ReleaseItem(eve));            
                    }
                  
                    
              }         
            }
        }        
        System.Debug('ReleaseItems size : ' + ReleaseItems.size()); 
        numbOfEvents = ReleaseEvents.size(); 
        numbOfTasks = ReleaseTasks.size();       
        numbOfElts = numbOfEvents + numbOfTasks;        
        return ReleaseItems;    
    }
    
    public class ReleaseItem {        
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
        public ReleaseItem(Event eve) {            
            identifiant = eve.Id;            
            startDateTime = eve.StartDateTime;            
            theDate = eve.StartDateTime.date();            
            endDateTime = eve.EndDateTime;            
            subject = eve.Subject;               
            type = EVENT;
            description = eve.TECH_TruncatedDescription__c;
            durationEvent = !startDateTime.isSameDay(endDateTime);
            priority = NORMAL;
            itemType = eve.Type;     
        }
        
        //Constructor for Task object
        public ReleaseItem(Task eve) {            
            identifiant = eve.Id;            
            startDateTime = eve.ActivityDate;            
            theDate = eve.ActivityDate;            
            subject = eve.Subject;      
            type = TASK;
            description = eve.TECH_TruncatedDescription__c;
            durationEvent = false;              
            priority = eve.Priority;
            itemType = eve.Type;
        }            
    }
}