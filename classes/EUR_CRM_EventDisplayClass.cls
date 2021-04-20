public with sharing class EUR_CRM_EventDisplayClass {
	
	//public static Map<Date, Map<Id, >>
	private static List<EventDisplay> eventsList{
		get{
			eventsList = new List<EventDisplay>();
			for(EventDisplay evDisplay: eventsMap.values()){
				eventsList.add(evDisplay);
			}
			
			return eventsList;
		}
	}//{eventsList = new List<EventDisplay>();}
	
	public static Map<Id, EventDisplay> eventsMap{get;set;} {eventsMap = new Map<Id, EventDisplay>();}
	
	public EUR_CRM_EventDisplayClass (ApexPages.StandardController standardController)
    {
    	eventsMap = new Map<Id, EventDisplay>();
    }
    
	public EUR_CRM_EventDisplayClass (){
		//eventsList = new List<EventDisplay>();
		eventsMap = new Map<Id, EventDisplay>();
	}
	
	public EUR_CRM_EventDisplayClass (List<EventDisplay> events){
		//eventsList = events;
		eventsMap = new Map<Id, EventDisplay>();
		for (EventDisplay evDisplay: events){
			eventsMap.put(evDisplay.sObjectId, evDisplay);
		}
	}
	
	public EUR_CRM_EventDisplayClass (List<Event> events){
		//eventsList = new List<EventDisplay>();
		for (Event event: events){
			//this.events.add(new EventJS(event.Id, event.EUR_CRM_Route_Template_Day__c, event.Subject, event.StartDateTime));
			EventDisplay evDisplay = new EventDisplay(event.Id, event.EUR_CRM_Route_Template__c, event.Subject, 
														event.StartDateTime, event.EndDateTime, Integer.valueOf(event.EUR_CRM_Week_Number__c));
			//eventsList.add(evDisplay);
			eventsMap.put(evDisplay.sObjectId, evDisplay);
		}
	}
	
	public EventDisplay addEventDisplayItem(Id sObjectId, Integer eventOrder, String name, Date eventStartDate, Date evendEndDate, Integer dayNum){
		EventDisplay eventDisplay= new EventDisplay(sObjectId, eventOrder, name, eventStartDate, evendEndDate, dayNum);
		//eventsList.add(eventDisplay);
		if (eventsMap==null){
			eventsMap = new Map<Id, EventDisplay>();
		}
		eventsMap.put(eventDisplay.sObjectId, eventDisplay);
		
		return eventDisplay;
	}
	
	public void deleteEventDisplayItem(Id sObjectId){
		if (eventsMap!=null && eventsMap.containsKey(sObjectId)){
			eventsMap.remove(sObjectId);
		}
	}
	
	public void deleteEventsFromDate(Date referenceDate){
		if(eventsMap!=null){
			for (Id key: eventsMap.keySet()){
				EventDisplay evDisplay = eventsMap.get(key);
				if (evDisplay.eventStartDate>= referenceDate){
					eventsMap.remove(key);
				}
			}
		}
	}
	
	@RemoteAction
	public static String getTemplateEvents(){
		//JSON String
		List<EventDisplay> evList = new List<EventDisplay>();
		for(EventDisplay evDisplay: eventsMap.values()){
			evList.add(evDisplay);
		}
		
		evList.sort();
		
		System.debug('Flag - EventDisplay List:' + evList);
        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartArray();
        for (EventDisplay evDisplay: evList) {
            g.writeStartObject();
            g.writeStringField('title', evDisplay.eventName);
            g.writeDateField('start', evDisplay.eventStartDate);
            //g.writeDateField('end', evDisplay.eventEndDate);
            //g.writeBooleanField('allDay', evDisplay.allDay);
            g.writeStringField('dayNum', evDisplay.eventDayNum);
            g.writeEndObject();
        }
        g.writeEndArray();
        System.debug('Flag - get event JS:' + g.getAsString());
        return g.getAsString();
	}
	
	
    public class EventDisplay implements Comparable{
    	public Id sObjectId{get;set;}
    	public Id templateId {get;set;}
    	public Integer eventOrder{get;set;}
    	public String eventName {get;set;}
    	
    	public DateTime eventStartDateTime{get;set;}
    	public Date eventStartDate{get;set;}
    	public String eventStartYear {get;set;}
    	public String eventStartMonth {get;set;}
    	public String eventStartDay {get;set;}
    	
    	public String eventEndDateTime{get;set;}
    	public Date eventEndDate{get;set;}
    	public String eventEndYear {get;set;}
    	public String eventEndMonth {get;set;}
    	public String eventEndDay {get;set;}
    	
    	public String eventDayNum {get;set;}
    	public Integer rowNum{get;set;}
    	public Integer weekNum {get;set;}
    	public Boolean isAllDay{get;set;}
    	public Integer eventType{get;set;} //Internal or External
    	
    	public EventDisplay(Id sObjectId, Integer eventOrder, String name, Date eventStartDate, Date evendEndDate, Integer dayNum){
    		sObjectId = sObjectId;
    		eventOrder = eventOrder;
    		eventName = name;
    		eventStartDate = eventStartDate;
    		eventStartYear = String.valueOf(eventStartDate.year());
    		eventStartMonth = String.valueOf(eventStartDate.month()-1);
    		eventStartDay = String.valueOf(eventStartDate.day());
    		eventEndDate = eventEndDate;
    		eventEndYear = String.valueOf(evendEndDate.year());
    		eventEndMonth = String.valueOf(evendEndDate.month()-1);
    		eventEndDay = String.valueOf(evendEndDate.day());
    		eventDayNum = String.valueOf(dayNum);
    		//isAllDay = isAllDay;
    	}
    	
    	public EventDisplay(Id sObjectId, Id templateId, String name, DateTime eventStartDateTime, DateTime evendEndDateTime, Integer weekNum){
    		sObjectId = sObjectId;
    		templateId = templateId;
    		eventName = name;
    		eventStartDateTime = eventStartDateTime;
    		eventEndDateTime = eventEndDateTime;
    		weekNum = weekNum;
    	}
    	
    	
    	public void setNewStartDate(Date eventDate){
    		eventStartYear = String.valueOf(eventDate.year());
    		eventStartMonth = String.valueOf(eventDate.month()-1);
    		eventStartDay = String.valueOf(eventDate.day());
    	}
    	
    	public Integer compareTo (Object compareTo){
        	EventDisplay compareToEventDisplay = (EventDisplay)compareTo;
	        if (eventStartDateTime!=null && eventStartDateTime == compareToEventDisplay.eventStartDateTime) return 0;
	        else if(eventStartDate!=null && eventStartDate == compareToEventDisplay.eventStartDate) return 0;
	        
	        if (eventStartDateTime!=null && eventStartDateTime > compareToEventDisplay.eventStartDateTime && compareToEventDisplay.eventStartDateTime!=null) return 1;
	        else if(eventStartDate!=null && eventStartDate > compareToEventDisplay.eventStartDate && compareToEventDisplay.eventStartDate!=null) return 1; 
	        
	        if(compareToEventDisplay.eventStartDateTime==null || compareToEventDisplay.eventStartDate==null) return -1;
	        
	        return -1; 
        }    	
    }
}