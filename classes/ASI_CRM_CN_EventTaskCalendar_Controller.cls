global class ASI_CRM_CN_EventTaskCalendar_Controller {

	global class event{	
		public string id{set;get;}	
        public String text {set;get;}
        public String start_date {set;get;}
        public String end_date {set;get;}        
        public String details {set;get;} 
        public String eventOutletId {set;get;}                             
    
        global event(){
                        
        }
    }
    
    global class events{
        public event[] wholelist {set;get;}        
        
        global events(){
            
            
        }
    }  
	
	@RemoteAction
	global static String getEventData(String currentSelectFromDateTimeString) {
		JSONGenerator gen = JSON.createGenerator(true);
    	    
	    events eventList = new events();
	    eventList.wholelist = new event[]{};	  
	    
	    String[] stringDate = currentSelectFromDateTimeString.split('-');
	    Integer d =  Integer.valueOf(stringDate[2]);
	    Integer m = Integer.valueOf(stringDate[1]);
	    Integer y = Integer.valueOf(stringDate[0]);
    
	    Date currentSelectFromDate = date.newInstance(y,m,d);	    
	    Date currentSelectToDate = currentSelectFromDate.addMonths(1);
	    
	    /*String soalString = 'SELECT id, ASI_MFM_Beginning_Date__c, ASI_MFM_End_Date__c, ASI_MFM_Event__r.Name, ASI_MFM_Outlet__c FROM ASI_MFM_Event_Outlet__c '+ 
	    	'WHERE (ASI_MFM_Beginning_Date__c >= :currentSelectFromDate AND ASI_MFM_Beginning_Date__c < :currentSelectToDate) ' + 
	    	'OR (ASI_MFM_End_Date__c >= :currentSelectFromDate AND ASI_MFM_End_Date__c < :currentSelectToDate) ' + 
	    	'OR (ASI_MFM_End_Date__c > :currentSelectToDate AND ASI_MFM_Beginning_Date__c < :currentSelectFromDate) ';    	   	    
	    
	    String whereClauseOperator = 'AND ';*/
	    
	    String soalString = 'SELECT id, ASI_MFM_Beginning_Date__c, ASI_MFM_End_Date__c, ASI_MFM_Event__r.Name,  ' +
	    'ASI_MFM_Outlet__r.Name, ASI_MFM_Outlet__r.ownerid FROM ASI_MFM_Event_Outlet__c ' + 
	    'WHERE (ASI_MFM_Beginning_Date__c >= :currentSelectFromDate AND ASI_MFM_Beginning_Date__c < :currentSelectToDate) ' + 
	    	'OR (ASI_MFM_End_Date__c >= :currentSelectFromDate AND ASI_MFM_End_Date__c < :currentSelectToDate) ' + 
	    	'OR (ASI_MFM_End_Date__c > :currentSelectToDate AND ASI_MFM_Beginning_Date__c < :currentSelectFromDate) ';	    	     
	    
	    List<ASI_MFM_Event_Outlet__c> eventOutlets = Database.query(soalString);
	    for(ASI_MFM_Event_Outlet__c eventOutlet : eventOutlets){
	    	
	    	date eventStartDate =  eventOutlet.ASI_MFM_Beginning_Date__c;
	    	date eventEndDate =  eventOutlet.ASI_MFM_End_Date__c.addDays(1);
	    	date startDate =  eventOutlet.ASI_MFM_Beginning_Date__c;
	    	date endDate =  startDate.addDays(1);
	    	
	    	/*do {	    			    		
			    event tempEvent = new event();
			    tempEvent.start_date = startDate.month() + '/' +
			    startDate.day() + '/' + 
			    startDate.year();
			    		    
			    tempEvent.end_date = endDate.month() + '/' +
			    endDate.day() + '/' +
			    endDate.year();
			    
			    tempEvent.details = '<br/>' + eventOutlet.ASI_MFM_Event__r.Name;
			    tempEvent.eventOutletId = eventOutlet.id;
			    
			    checkEventDateExist(eventList.wholelist, tempEvent);	
			    
			    startDate = startDate.addDays(1);
			    endDate = endDate.addDays(1);    
	    	}while (endDate <= eventEndDate);	*/	    		    		    		  	    	
	    }
	    gen.writeStartObject();
        gen.writeFieldName('Event');
        gen.writeObject(eventList);                
        gen.writeEndObject();
            	       
    	return gen.getAsString();
	}
}