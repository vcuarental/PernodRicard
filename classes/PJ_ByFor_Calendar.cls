public with sharing class PJ_ByFor_Calendar {
    private Map<Id,EventClass> events{get;set;}
    public Event eventPopup{get;set;}
    public String eventToDelete{get;set;}
    public String startDateString{get;set;}
    public String endDateString{get;set;}
    private Map<String, String> countriesMap;
    private List<SelectOption> countries;
    public List<Date> nonClickDays{get;set;}
    public void init()
    {
        startDateString = '';
        endDateString = '';
        eventToDelete = '';
        eventPopup = new Event(OwnerId=System.Label.PJ_ByFor_CellarMasterCalendar_Id,recordTypeId=System.Label.PJ_ByFor_recordType_Id);
        makeJsonCalendar();
        initCountries();
    }
    
    public void makeJsonCalendar()
    {
        events = new Map<Id,EventClass>();
        nonClickDays = new List<Date>();
        for(Event ev:[select Id, StartDateTime, EndDateTime, tolabel(PJ_ByFor_Country__c), PJ_ByFor_Place_of_the_experience__c, Subject, whatId, PJ_ByFor_Status__c from Event where OwnerId=:System.Label.PJ_ByFor_CellarMasterCalendar_Id])
        {
            events.put(ev.id,new EventClass(ev.Id,ev.StartDateTime.date(),ev.EndDateTime.date(),ev.Subject,ev.PJ_ByFor_Status__c,ev.PJ_ByFor_Country__c, ev.PJ_ByFor_Place_of_the_experience__c));
            if(ev.PJ_ByFor_Status__c != 'Free')
                nonClickDays.add(ev.StartDateTime.date());
        }
        
    }
    
    public List<EventClass> getEvents()
    {
        return events.values();
    }
    
    public Integer getEventsListSize()
    {
        return events.size();
    }
    
    public void saveEventToSalesforce()
    {
        System.Debug('#####StartDate=' + startDateString);
        System.Debug('#####EndDate=' + endDateString);
        
        
        eventPopup.OwnerId=System.Label.PJ_ByFor_CellarMasterCalendar_Id;
        eventPopup.isAllDayEvent=true;
        eventPopup.Subject='Experience';
        eventPopup.PJ_ByFor_Status__c='Free';
        eventPopup.recordTypeId=System.Label.PJ_ByFor_recordType_Id;
        
        system.debug('#### date : ' + startDateString);
        Date parsedStartDate = Date.parse(String.valueOf(startDateString));
        Date parsedEndDate = Date.parse(String.valueOf(endDateString));
        
        
        if(parsedStartDate == parsedEndDate)
        {
        		//DateTime startTime = Datetime.newInstance(parsedStartDate.year(), parsedStartDate.month(), parsedStartDate.day(), 0, 0, 0);
		        //DateTime endTime = startTime + 1;
		        //List<Event> evs = [select Id,PJ_ByFor_Country__c,PJ_ByFor_Place_of_the_experience__c from Event where StartDateTime>:startTime and StartDateTime<:endTime and OwnerId=:System.Label.PJ_ByFor_CellarMasterCalendar_Id and recordTypeId=:System.Label.PJ_ByFor_recordType_Id];
		        //if(evs.size() == 0)
	            //{
		            eventPopup.StartDateTime = Datetime.newInstance(parsedStartDate.year(), parsedStartDate.month(), parsedStartDate.day(), 0, 0, 0);
		            eventPopup.EndDateTime = Datetime.newInstance(parsedEndDate.year(), parsedEndDate.month(), parsedEndDate.day(), 0, 0, 0);
		            //List<Event> controlEvents = [select Id from Event where OwnerId=:System.Label.PJ_ByFor_CellarMasterCalendar_Id and recordTypeId=:System.Label.PJ_ByFor_recordType_Id and StartDateTime>=:eventPopup.StartDateTime and EndDateTime<:eventPopup.EndDateTime.addDays(1)];
		            //if(controlEvents.size() == 0)
	           		//{
	            	insert eventPopup;
		            events.put(eventPopup.Id, new EventClass(eventPopup.Id,eventPopup.StartDateTime.date(),eventPopup.EndDateTime.date(),eventPopup.Subject,eventPopup.PJ_ByFor_Status__c,countriesMap.get(eventPopup.PJ_ByFor_Country__c), eventPopup.PJ_ByFor_Place_of_the_experience__c));
	           		//}
        		//}
        } else {
            Date whileEndDate = parsedStartDate;
            List<Event> eventsToInsert = new List<Event>();
            do {
                Event ev = eventPopup.clone();
                ev.StartDateTime = Datetime.newInstance(whileEndDate.year(), whileEndDate.month(), whileEndDate.day(), 0, 0, 0);
                ev.EndDateTime = Datetime.newInstance(whileEndDate.year(), whileEndDate.month(), whileEndDate.day(), 0, 0, 0);
                eventsToInsert.add(ev);
                whileEndDate = whileEndDate + 1;
            } while (whileEndDate <= parsedEndDate);
            
            insert eventsToInsert;
            for(Event e:eventsToinsert)
                events.put(e.Id, new EventClass(e.Id,e.StartDateTime.date(),e.EndDateTime.date(),e.Subject,e.PJ_ByFor_Status__c,countriesMap.get(e.PJ_ByFor_Country__c), e.PJ_ByFor_Place_of_the_experience__c));
        }
        
        eventPopup = new Event(OwnerId=System.Label.PJ_ByFor_CellarMasterCalendar_Id,recordTypeId=System.Label.PJ_ByFor_recordType_Id);
        startDateString = '';
        endDateString = '';
        
        events = new Map<Id,EventClass>();
        makeJsonCalendar();
        
    }
    
    public void deleteEventToSalesforce()
    {
        System.Debug('#####Id=' + eventToDelete);
        Event ev = [select PJ_ByFor_Status__c, whatId from Event where Id=:eventToDelete];
        if(ev.PJ_ByFor_Status__c == 'Free')
        {
            delete ev;
        } else {
            ev.PJ_ByFor_Event_deleted_by_Cellar_Master__c=true;
            update ev;
            delete ev;
            List<Event> evCellar = [select Id from Event where whatId=:ev.whatId and OwnerId!=:System.Label.PJ_ByFor_CellarMasterCalendar_Id LIMIT 1];
            if(evCellar.size() > 0)
                delete evCellar[0];
            PJ_ByFor_Experience__c xp = [select Id from PJ_ByFor_Experience__c where Id=:ev.whatId];
            //xp.PJ_ByFor_Status__c = System.Label.PJ_ByFor_Experience_Open;
            xp.PJ_ByFor_Wishedexperiencedate__c = null;
            update xp;
        }
        
        //Event ev = new Event(Id=eventToDelete,PJ_ByFor_Event_deleted_by_Cellar_Master=true);
        //delete ev;
        events.remove(eventToDelete);  
        eventToDelete = '';
        events = new Map<Id,EventClass>();
        makeJsonCalendar();
    }
    
    /*
    @RemoteAction
    public static String saveEventToSalesforce(eventClass theEvent) {
        Event ev = new Event(OwnerId='02326000000fqer',isAllDayEvent=true,Subject='Experience',PJ_ByFor_Status__c='Free',recordTypeId='012260000004eM8');
        
        ev.StartDateTime = Datetime.newInstance(theEvent.startDate.year(), theEvent.startDate.month(), theEvent.startDate.day(), 0, 0, 0);
        ev.EndDateTime = Datetime.newInstance(theEvent.EndDate.year(), theEvent.EndDate.month(), theEvent.EndDate.day(), 0, 0, 0);
        ev.PJ_ByFor_Place_of_the_experience__c = theEvent.place;
        ev.PJ_ByFor_Country__c = theEvent.Country;
    
        
        if(theEvent.theId != null && theEvent.theId != '')
        {
            ev.Id=theEvent.theId;
            update ev;
        } else {
            insert ev;
        }

        return ('' + ev.Id);
    }
    
    @RemoteAction
    public static void deleteEventToSalesforce(String eventId) {
        Event ev = new Event(Id=eventId);
        delete ev;
    }
    */
    /*
    public List<picklistClass> getCountries()
    {
        List<picklistClass> options = new List<picklistClass>();
        Schema.DescribeFieldResult fieldResult = PJ_ByFor_Experience__c.PJ_ByFor_Countries__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new picklistClass('', '--None--'));
            
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new picklistClass(f.getValue(), f.getLabel()));
        }       
        return options;
    }
    */
    
    public List<SelectOption> getCountries()
    {
        return countries;
    }
    
    private void initCountries()
    {
        countriesMap = new Map<String,String>();
            
        countries = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Event.PJ_ByFor_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        countries.add(new SelectOption('', '--None--'));
            
        for( Schema.PicklistEntry f : ple)
        {
            countriesMap.put(f.getValue(), f.getLabel());
            
            countries.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
    }
    
    class EventClass
    {
        public String theId{get;set;}
        public Date startDate{get;set;}
        public Date EndDate{get;set;}
        public String Subject{get;set;}
        public String Status{get;set;}
        public String Country{get;set;}
        public String place{get;set;}
        public String location{get;set;}
        public EventClass(Id theId,Date startDate, Date EndDate, String Subject, String Status, String Country, String place)
        {
            this.theId = theId;
            this.startDate = startDate;
            this.EndDate = EndDate;
            this.Subject = Subject;
            this.Country = Country;
            this.place = place;
            this.Status = Status;
            
            if(place == 'Epernay')
                this.location = 'Epernay, France';
            else
                this.location = country;
        }
    }

   class pickListClass
   {
        public String keyValue{get;set;}
        public String labelValue{get;set;}
        public pickListClass(String k, String l)
        {
            this.keyValue = k;
            this.labelValue = l;
        }
   }
}