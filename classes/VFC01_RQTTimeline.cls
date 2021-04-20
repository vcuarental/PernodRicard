public class VFC01_RQTTimeline {

    private final Request__c Request;
    //Our collection of the class/wrapper object RequestItems    
    public List<RequestItem> RequestItems {get; set;}
    public List<RequestItem> RequestEvents {get; set;}
    public List<RequestItem> RequestTasks {get; set;} 
    public integer numbOfElts {get; set;}
    public integer numbOfEvents {get; set;}
    public integer numbOfTasks {get; set;}
    private Integer COLLECTIONITEMS_MAXSIZE = 1000;
    public boolean isLegend {get; set;}
    private String priorityTaskFilter {get; set;}
    private String typeTaskFilter {get; set;}
    private boolean eventSupport {get; set;}
    private boolean taskSupport {get; set;}
     
     
    public VFC01_RQTTimeline(ApexPages.StandardController stdController) {        
        this.Request = (Request__c) stdController.getRecord();
        CS001_TimelineConfig__c CS= CS001_TimelineConfig__c.getInstance();
        isLegend = CS.DisplayLegend__c;  
        priorityTaskFilter = CS.PriorityTaskFilter__c;
        typeTaskFilter = CS.TypeTaskFilter__c;
        eventSupport = CS.EventSupport__c;
        taskSupport = CS.taskSupport__c;
        System.debug('#### Request Timeline configured with : ');
        System.debug('#### Support for Events ? : ' + eventSupport);
        System.debug('#### Support for Tasks ? : ' + taskSupport); 
        if (typeTaskFilter == null) typeTaskFilter= '';
        getRequestItems();
    }
    
    
    //This method uses a simple SOQL query to return a List of Events/Tasks and convert them in Wrapper objects    
    public List<RequestItem> getRequestItems() {        
        if (RequestItems == null) {            
            RequestItems = new List<RequestItem>();
            RequestEvents = new List<RequestItem>();
            if (eventSupport) {
                for (Event eve : [select Id, Subject, ActivityDate,TECH_TruncatedDescription__c, StartDateTime, EndDateTime,Type FROM Event where whatid = :Request.Id AND IsChild = false and IsRecurrence = false  limit :COLLECTIONITEMS_MAXSIZE]) {                
                    RequestEvents.add(new RequestItem(eve));            
                }
                
 
        }    
            RequestTasks  = new List<RequestItem>();
            if (taskSupport) {
                if (priorityTaskFilter == 'All') {
                    if (typeTaskFilter.length() == 0 ) {
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :Request.Id and ActivityDate != null  limit :COLLECTIONITEMS_MAXSIZE]) {                
                            RequestTasks .add(new RequestItem(eve));            
                        }
                        
 
                } else {
                        for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :Request.Id and ActivityDate!= null and Type in :typeTaskFilter.split(',') limit :COLLECTIONITEMS_MAXSIZE]) {                
                            RequestTasks .add(new RequestItem(eve));   
                        }
                        
 
                  }  
                } else {
                    for (Task eve : [select Id, Subject, TECH_TruncatedDescription__c, ActivityDate, Status,IsClosed,Priority,Type FROM Task where whatid = :Request.Id and ActivityDate!= null and Priority= :priorityTaskFilter limit :COLLECTIONITEMS_MAXSIZE]) {                
                        RequestTasks .add(new RequestItem(eve));            
                    }
                  
                    
              }         
            }
        }        
        System.Debug('RequestItems size : ' + RequestItems.size()); 
        numbOfEvents = RequestEvents.size(); 
        numbOfTasks = RequestTasks.size();       
        numbOfElts = numbOfEvents + numbOfTasks;        
        return RequestItems;    
    }
    
    public class RequestItem {        
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
        public RequestItem(Event eve) {            
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
        public RequestItem(Task eve) {            
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