public with sharing class EUR_CRM_RouteScheduleControllerExt { 
    
    public EUR_CRM_Route_Template__c routeTemplate {get;set;}
    public EUR_CRM_RouteTemplateClass routeTemplateClass{get;set;}
    
    public Integer planningPeriod{get;set;}{planningPeriod=8;}
    public Integer aveVisitDuration {get;set;}{aveVisitDuration=1;}
    public List<SelectOption> numCyclesOptions{get;set;} {numCyclesOptions = new List<SelectOption>();}
    public Integer numCycle {get;set;}{numCycle=1;}
    
    public Date startDate{get;set;}//Start Date, either Today or Last Populated Date
    public String startYear{get;set;}
    public String startMonth{get;set;}
    public String startDay{get;set;}
    
    public String selectedDate{get;set;}

    public Boolean disableNumberOfCycles {get; set;}
    public Boolean disableReminderDay {get; set;}
    
    public transient List<Event> events {get;set;}
    public transient Set<EUR_CRM_Route_Template_Item__c> routeItems{get;set;}
    public transient Set<Id> routeItemIds{get;set;}
    public transient List<EUR_CRM_RouteTemplateClass.EventJS> eventsJSDisplayList{get;set;} 
    
    private ApexPages.StandardController standardController;
    private final Integer LIST_VIEW_LIMIT = 1000;
    private final Integer MAXIMUM_CYCLE = 10;
    private final Integer DAYS_LIMIT = (2*365); //2 Years
    public Boolean disableSave {get;set;}
    private Set<String> countriesWithActiveFlag = new Set<String>{'DE','FI', 'DK','PT'};
    private Date populationMonday{get{
        //Calculation on population should always start on Monday
        Date populationMonday;
        DateTime nextWorkingDate = populationDate;//routeTemplateClass.getNextWorkingDate(DateTime.now());
        
        populationMonday = routeTemplateClass.calculateStartingMonday(nextWorkingDate.date());
        return populationMonday;
    }}
    
    private Date populationDate{get{
        Date populationDate;
        if (routeTemplateClass!=null)
                populationDate = routeTemplateClass.getNextWorkingDate(DateTime.now());
        return populationDate;
    }}
    
    private Date templateEndDate {get{
        Date endDate;
        Date populationStartDate =  populationMonday;
        
        if (routeTemplate!=null && routeTemplateClass!=null){
            Integer futureDays = 0;
            
            System.debug('Flag - Template End Date - Check Reset Week:' + routeTemplate.EUR_CRM_Reset_Week__c);
            if (routeTemplate.EUR_CRM_Reset_Week__c!= null && routeTemplate.EUR_CRM_Reset_Week__c>0){
                futureDays = Integer.valueOf(
                                ((routeTemplate.EUR_CRM_Planning_Period__c - (routeTemplate.EUR_CRM_Reset_Week__c-1)) * 7) + 
                                ((numCycle-1) * (routeTemplate.EUR_CRM_Planning_Period__c * 7))
                                )-1;
            }
            else{
                futureDays = Integer.valueOf((numCycle) * (routeTemplate.EUR_CRM_Planning_Period__c * 7))-1;
            }

            endDate = populationStartDate.addDays(futureDays);
            
            System.debug('Flag - Template End Date:' + endDate + '- '+ futureDays +' days -- '+ 'Population Date:'+populationStartDate);
        }
        return endDate; 
    }}
        
        private Date reminderDate{get{
                Date reminderDate;
                if ((routeTemplate !=null && routeTemplate.EUR_CRM_Reminder_Day__c!=null) && routeTemplate.EUR_CRM_Reminder_Day__c>0){
                    Integer daysPriorEndDate = Integer.valueOf(routeTemplate.EUR_CRM_Reminder_Day__c)+2; // + 2 for weekend
                    reminderDate = templateEndDate.addDays((daysPriorEndDate*-1)); 
                    System.debug('Flag  - Reminder Date:' + reminderDate + '( #DaysBeforeEnd:'+daysPriorEndDate+' - TemplateEndDate:'+templateEndDate+')');
                }
                return reminderDate;
        }}
        
    
     public   String eventsJS {
        get {
            if (events!=null){
                System.debug('Flag - get Event JS:' + events);
                JSONGenerator g = JSON.createGenerator(true);
                g.writeStartArray();
                for (Event event: events) {
                    String subject = (routeTemplateClass.isBaltics() || routeTemplateClass.isAT())?(event.Subject+':'+event.EUR_CRM_Account_Details__c): event.Subject;
                    
                    g.writeStartObject();
                    g.writeStringField('title', subject);
                    g.writeDateTimeField('start', event.ActivityDate);//event.StartDateTime);
                    g.writeDateTimeField('end', event.ActivityDate);//event.EndDateTime);
                    //g.writeStringField('eventId', event.Id);
                    g.writeStringField('weekNum', String.valueOf(event.EUR_CRM_Week_Number__c));
                    g.writeStringField('routeTemplate', String.valueOf(event.EUR_CRM_Route_Template__c));
                    g.writeEndObject();
                }
                g.writeEndArray();
                return g.getAsString();
            }
            return '';
        }
    }
    
    public EUR_CRM_RouteScheduleControllerExt (ApexPages.StandardController standardController)
    {    
        disableSave = false;
        disableReminderDay = false;
        disableNumberOfCycles = false;
        this.standardController = standardController;
        routeItems =  new Set<EUR_CRM_Route_Template_Item__c>();
                
        routeTemplateClass = new EUR_CRM_RouteTemplateClass(this.standardController.getId());
        routeTemplate = routeTemplateClass.routeTemplate;
        if (routeTemplateClass!=null){
            //Init Route Template Items
            initRouteTemplateDetails();

            //Set selected Date = next working day
            populateTempCalendar(populationDate);
        }
        System.debug(routeTemplate.EUR_CRM_Country_Code__c);
        if(routeTemplate.EUR_CRM_Country_Code__c == 'DK'){
            disableReminderDay = true;
            disableNumberOfCycles = true;
        }
    }
    
    public PageReference onLoadPrep (){
        PageReference pageRef = null;
        System.debug('Flag - On Load Prep - ' + routeTemplateClass);
        if (routeTemplateClass!=null){
            if (routeTemplateClass.forDeletionInactiveRouteTemplate.size()>0 || routeTemplateClass.forDeletionVisitModifiedRouteTemplate.size()>0){
                System.debug('Flag - Check Clean Out:' + routeTemplateClass.forDeletionInactiveRouteTemplate + '-' +routeTemplateClass.forDeletionVisitModifiedRouteTemplate);
                routeTemplateClass.cleanOutRouteTemplateItems(routeTemplateClass.forDeletionInactiveRouteTemplate, routeTemplateClass.forDeletionVisitModifiedRouteTemplate);
            }

        }
        
        return pageRef;
    }
    
    public void initRouteTemplateDetails(){
        if(routeTemplateClass!=null){
                routeTemplateClass.initRouteItems(false, null, false);
                //Compute possible max cycle
                Integer maxCycle = 1;
                if (routeTemplateClass.eventCount>0){
                        maxCycle = Integer.valueOf((routeTemplateClass.maxEventCount-1)/routeTemplateClass.eventCount); // 10,000/eventCountEstimate
                        Integer maxCycleByYear = Integer.valueOf(DAYS_LIMIT/2/(routeTemplate.EUR_CRM_Planning_Period__c*7));
                        System.debug('Flag Check Max Cycle:' + maxCycle + ' - By Year:' + maxCycleByYear);
                        maxCycle = (maxCycleByYear>maxCycle)? maxCycle: maxCycleByYear;
                        maxCycle = (maxCycle>MAXIMUM_CYCLE) ? MAXIMUM_CYCLE : maxCycle;
                }
                for (Integer i=1; i<=maxCycle; i++){
                   numCyclesOptions.add(new Selectoption(String.valueOf(i),String.valueOf(i)));
                }
                
                checkEventCount(routeTemplateClass.eventCount);
                
                //Set Start Date
                startDate = (routeTemplate.EUR_CRM_Last_Date_Populated__c!=null)?routeTemplate.EUR_CRM_Last_Date_Populated__c:Date.today();
                //Add 1 day
                startDate.addDays(1);
                startYear = String.valueOf(startDate.year());
                startMonth = String.valueOf(startDate.month()-1);
                startDay = String.valueOf(startDate.day());
        }
    }
    
    public void repopulateTempCalendar(){
        PageReference pageRef = null;
        System.debug('Flag - Calendar Repopulation:' + numCycle);
        populateTempCalendar(populationDate);
        
        //return pageRef;
    }
    
    public void populateTempCalendar(Date selectedStartDate){
        //TODO:
        //1.Convert Start Date - String to Date
        //2.Iterate Week - Max: Planning Period
        //3. Iterate Route Item Wrapper - list or map
        //IF (WEEK/FREQ.SPAN)%0 = math.mod(WEEK, FREQ DURATION)  //3.1. Iterate Route Days (list)
        //ITERAT DAYS  //3.1.1.1 Set event, event day = Start Date +((Week * (7+span)) + Day) - if event day <= max planning day (7 * Max Planning Week)
        //SET EVENT   //3.1.1.2 Set event, event day = Start Date - if week=0 && day=1
        PageReference pageRef = null;
        events = new List<Event>();
        eventsJSDisplayList=new List<EUR_CRM_RouteTemplateClass.EventJS>();
        System.debug('Start Date:' + selectedDate + '- Cycle:' + numCycle + '-' + selectedStartDate);
            
        //Get start of the week - start date's Monday - Population should always start on Monday
        Date actualStartDate = populationMonday;
            
        //startDateTime.addHours(9);
        System.debug('Flag - Future Days vs Days Limit:' + templateEndDate + ' - ' + selectedStartDate.addDays(DAYS_LIMIT));
        //Integer weekCount = Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c) * numCycle;
        
        if(templateEndDate<actualStartDate.addDays(DAYS_LIMIT)){
            Date cycleStartDate = actualStartDate;
            Date cycleEndDate;
                            
            for(Integer cycle=1; cycle<=numCycle; cycle++){
                //TODO Change Week Start, GET FROM CUSTOM FIELD, LAST WEEK DELETED
                Integer startWeek = 1;
                                                                    
                    if (cycle==1 && routeTemplate.EUR_CRM_Scheduled__c && routeTemplate.EUR_CRM_Reset_Week__c!= null && routeTemplate.EUR_CRM_Reset_Week__c>1) {//If cycle==1: StartWeek == reset week
                        //startWeek = Integer.valueOf(routeTemplate.EUR_CRM_Reset_Week__c);
                        cycleStartDate = actualStartDate.addDays(-7*(Integer.valueOf(routeTemplate.EUR_CRM_Reset_Week__c)-1));
                        cycleEndDate = cycleStartDate.addDays(Integer.valueOf((routeTemplate.EUR_CRM_Planning_Period__c-(startWeek-1))*7)-1);
                    }else if (cycle ==1 && startWeek ==1){
                        cycleStartDate = actualStartDate;
                        cycleEndDate = cycleStartDate.addDays(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c*7)-1);
                    }
                    else if(cycle>1){
                        cycleStartDate = cycleEndDate.addDays(1);
                        cycleEndDate = cycleStartDate.addDays(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c*7)-1);
                    }

                Boolean newCycleFlag = true;
                //planningEndDate = selectedStartDate.addDays(Integer.valueOf((routeTemplate.EUR_CRM_Planning_Period__c-(startWeek-1))*7)-1);
                System.debug('Flag - Planning End Date:' + templateEndDate + ' - Start Week:' + startWeek);
                System.debug('Flag - Cycle Start and End Date:' + cycleStartDate + ' - ' + cycleEndDate);

                System.debug('Flag - Iterate Weeks for cycle:'+cycle+' --- From - ' + startWeek +' To-'+ routeTemplate.EUR_CRM_Planning_Period__c);
                for (Integer week = startWeek; week<=routeTemplate.EUR_CRM_Planning_Period__c; week++){
                        Integer startingDay = (7*((week-1)*1))+1;
                        Integer endingDay = startingDay + 6;
                        Date startingDate = cycleStartDate;//selectedStartDate.addDays(startingDay-1);
                        Date endingDate = startingDate.addDays(endingDay-1);//cycleEndDate;//selectedStartDate.addDays(endingDay-1);
                        
                    for (Id key: routeTemplateClass.routeItemsMap.keySet()){
                        EUR_CRM_RouteTemplateClass.RouteItemWrapper routeTemplateItem = routeTemplateClass.routeItemsMap.get(key);
                        Boolean isProcessed = false;
                        
                        if (routeTemplateItem.visitFrequency!=null && (routeTemplateItem.visitSpan!=null || routeTemplateItem.visitSpan<=0)){
                            List<Event> newEvents = new List<Event>();
                            
                            if (newCycleFlag){
                                    routeTemplateItem.processCount = 0;
                            }
                            
                            Integer itemStartWeek = routeTemplateItem.processCount + routeTemplateItem.visitSpan;
                            Date targetNexStartDate = startingDate.addDays(routeTemplateItem.visitSpan*routeTemplateItem.processCount);
                            
                            System.debug('Flag Processing Template Item:' + routeTemplateItem.accountName +'- Week:'+week+
                                                    '('+routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c+'-'+startingDay+'-'+endingDay+')'+
                                                    ' ('+routeTemplateItem.processCount+'-'+targetNexStartDate+'-'+(itemStartWeek/week)+'-'+Math.mod(itemStartWeek, week)+')');
                            
                            System.debug('DEBUGGING - Week>1 Process:' + routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c+'-'+endingDay +'-'+ 
                                                            routeTemplateItem.processCount +'-'+ targetNexStartDate+'-'+endingDate +'-'+startingDate);
                            //IF startWeek == week; item start day >= selectedStartDate
                            if(routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c<=endingDay 
                                && routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c>=startingDay)
                            {
                                if ((routeTemplate.EUR_CRM_Reset_Week__c==null) || (cycle>1) || (cycle==1 && routeTemplate.EUR_CRM_Reset_Week__c!=null && week>=routeTemplate.EUR_CRM_Reset_Week__c)){
                                        System.debug('CHECK - 1st Attempt:'+routeTemplateItem.accountName+'-'+startingDate+'-'+selectedStartDate+'-'+routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c);
                                        newEvents = processEventDays(startingDate, templateEndDate, selectedStartDate,
                                                    week, routeTemplateItem, true);
                                }
                                isProcessed = true;
                            }
                            //else if week>startweek &&  modulo==0; item start day >= selectedStartDate
                           else if (routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c<endingDay && routeTemplateItem.processCount>0 
                                    && targetNexStartDate<endingDate && targetNexStartDate>=startingDate)
                           {
                                if ((routeTemplate.EUR_CRM_Reset_Week__c==null) || (cycle>1) || (cycle==1 && routeTemplate.EUR_CRM_Reset_Week__c!=null && week>=routeTemplate.EUR_CRM_Reset_Week__c)){
                                        System.debug('CHECK - Repeat:'+routeTemplateItem.accountName+'-'+startingDate+'-'+selectedStartDate+'-'+routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c);
                                        newEvents = processEventDays(startingDate, templateEndDate, selectedStartDate,
                                                    week, routeTemplateItem, false);
                                }
                                isProcessed = true;
                            } 
                            if (isProcessed){
                                    routeTemplateItem.processCount += 1;
                            }
                            System.debug('Flag - New event - '+routeTemplateItem.accountName+':' + newEvents);
                            if (newEvents.size()>0){
                                events.addAll(newEvents);
                            }
                        }
                    }
                    newCycleFlag = false;
                }
            }
            checkEventCount(events.size());
            
            System.debug('Flag - Events:' + events);
            System.debug('Flag - Total Events:' + events.size());
        }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot schedule visits for more than 2 years.'));
        }
    }
    
        public PageReference populateTempCalendar(){
                PageReference pageRef = null;
                
                System.debug('Start Date:' + selectedDate);
                //TODO:
                //1.Convert Start Date - String to Date
                //2.Iterate Week - Max: Planning Period
                //3. Iterate Route Item Wrapper - list or map
                //IF (WEEK/FREQ.SPAN)%0 = math.mod(WEEK, FREQ DURATION)  //3.1. Iterate Route Days (list)
                //ITERAT DAYS  //3.1.1.1 Set event, event day = Start Date +((Week * (7+span)) + Day) - if event day <= max planning day (7 * Max Planning Week)
                //SET EVENT   //3.1.1.2 Set event, event day = Start Date - if week=0 && day=1
                
                events = new List<Event>();
                                
                Date selectedStartDate = Date.parse(selectedDate);
                                
                //startDateTime.addHours(9);
                System.debug('Flag - Future Days vs Days Limit: A ' + templateEndDate + ' - ' + selectedStartDate.addDays(DAYS_LIMIT));
                //Integer weekCount = Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c) * numCycle;
                
                if(templateEndDate<selectedStartDate.addDays(DAYS_LIMIT)){
                        Date cycleStartDate = selectedStartDate;
                Date cycleEndDate;
                                
                        for(Integer cycle=1; cycle<=numCycle; cycle++){
                                //TODO Change Week Start, GET FROM CUSTOM FIELD, LAST WEEK DELETED
                                Integer startWeek = 1;
                                                                                
                                if (cycle==1 && routeTemplate.EUR_CRM_Scheduled__c && routeTemplate.EUR_CRM_Reset_Week__c!= null && routeTemplate.EUR_CRM_Reset_Week__c>1) {//If cycle==1: StartWeek == reset week
                                        startWeek = Integer.valueOf(routeTemplate.EUR_CRM_Reset_Week__c);
                                        cycleStartDate = selectedStartDate;
                                        cycleEndDate = cycleStartDate.addDays(Integer.valueOf((routeTemplate.EUR_CRM_Planning_Period__c-(startWeek-1))*7)-1);
                                }else if (cycle ==1 && startWeek ==1){
                                    cycleStartDate = selectedStartDate;
                                    cycleEndDate = cycleStartDate.addDays(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c*7)-1);
                                }
                                else if(cycle>1){
                                    cycleStartDate = cycleEndDate.addDays(1);
                                    cycleEndDate = cycleStartDate.addDays(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c*7)-1);
                                }

                                Boolean newCycleFlag = true;
                                //planningEndDate = selectedStartDate.addDays(Integer.valueOf((routeTemplate.EUR_CRM_Planning_Period__c-(startWeek-1))*7)-1);
                                System.debug('Flag - Planning End Date:' + templateEndDate + ' - Start Week:' + startWeek);
                                System.debug('Flag - Cycle Start and End Date:' + cycleStartDate + ' - ' + cycleEndDate);
                            
                                
                                System.debug('Flag - Iterate Weeks for cycle:'+cycle+' --- From - ' + startWeek +' To-'+ routeTemplate.EUR_CRM_Planning_Period__c);
                                for (Integer week = startWeek; week<=routeTemplate.EUR_CRM_Planning_Period__c; week++){
                                        Integer startingDay = (7*((week-1)*1))+1;
                                        Integer endingDay = startingDay + 6;
                                        Date startingDate = cycleStartDate;//selectedStartDate.addDays(startingDay-1);
                                        Date endingDate = cycleEndDate;//selectedStartDate.addDays(endingDay-1);
                                        
                                        for (Id key: routeTemplateClass.routeItemsMap.keySet()){
                                                EUR_CRM_RouteTemplateClass.RouteItemWrapper routeTemplateItem = routeTemplateClass.routeItemsMap.get(key);
                                                if (routeTemplateItem.visitFrequency!=null && (routeTemplateItem.visitSpan!=null || routeTemplateItem.visitSpan<=0)){
                                                        List<Event> newEvents = new List<Event>();
                                                        
                                                        if (newCycleFlag){
                                                            routeTemplateItem.processCount = 0;
                                                        }
                                                        Integer itemStartWeek = routeTemplateItem.processCount + routeTemplateItem.visitSpan;
                                                        Date targetNexStartDate = startingDate.addDays(routeTemplateItem.visitSpan*routeTemplateItem.processCount);
                                                        
                                                        System.debug('Flag Processing Template Item:' + routeTemplateItem.accountName +'- Week:'+week+
                                                                                '('+routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c+'-'+startingDay+'-'+endingDay+')'+
                                                                                ' ('+routeTemplateItem.processCount+'-'+targetNexStartDate+'-'+(itemStartWeek/week)+'-'+Math.mod(itemStartWeek, week)+')');
                                                        
                                                        System.debug('DEBUGGING - Week>1 Process:' + routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c+'-'+endingDay +'-'+ 
                                                                                        routeTemplateItem.processCount +'-'+ targetNexStartDate+'-'+endingDate +'-'+startingDate);
                                                        //IF startWeek == week
                                                        if(routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c<=endingDay && routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c>=startingDay){
                                                                System.debug('CHECK: 1st Attempt:'+routeTemplateItem.accountName+'-'+startingDate +'-'+selectedStartDate);
                                                                newEvents = processEventDays(startingDate, templateEndDate, selectedStartDate, 
                                                                                week, routeTemplateItem, true);
                                                        }
                                                        //else if week>startweek &&  modulo==0
                                                        else if (routeTemplateItem.processCount>0 && routeTemplateItem.routeTemplateItem.EUR_CRM_First_Day__c<endingDay //&& routeTemplateItem.processCount>0 
                                                                                && targetNexStartDate<endingDate && targetNexStartDate>=startingDate){
                                                            System.debug('CHECK: Repeat:'+routeTemplateItem.accountName+'-'+startingDate +'-'+selectedStartDate);                       
                                                                newEvents = processEventDays(startingDate, templateEndDate, selectedStartDate, 
                                                                       week, routeTemplateItem, false);
                                                        }                               
                                                        
                                                        if (newEvents.size()>0){
                                                                routeTemplateItem.processCount += 1;
                                                                events.addAll(newEvents);
                                                        }
                                                }
                                        }
                                        newCycleFlag = false;
                                }
                        }
                        checkEventCount(events.size());
                        
                        System.debug('Flag - Events:' + events);
                        System.debug('Flag - Total Events:' + events.size());
                                }else{
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot schedule visits for more than 2 years.'));
                                }
                return pageRef;
        }
    
        //Population Start Date: Valid event start date (event date>= population start date)
        //Start Date: Week start date
    private List<Event> processEventDays(Date startDate, Date templateEndDate, Date populationStartDate, 
                                         Integer week, EUR_CRM_RouteTemplateClass.RouteItemWrapper routeTemplateItem, Boolean firstFlag){
        List<Event> eventList = new List<Event>();
        Integer evCount = 0;
        //Integer startingDay = (7*((week-1)*1))+1;
        //Integer endingDay = startingDay + 6;
        //routeItems = new Set<EUR_CRM_Route_Template_Item__c>();
        System.debug('Flag Process Event Days - Population Start Date:' + populationStartDate + '-' + startDate);
        for (EUR_CRM_Route_Template_Day__c rtDay: routeTemplateItem.routeDays){
                Date startEventDate;
                //Set Start Date
                if(firstFlag){
                        startEventDate = startDate.addDays(Integer.valueOf(rtDay.EUR_CRM_Day__c-1));
                }else{
                        startEventDate = startDate.addDays(Integer.valueOf((7*(week-1))+rtDay.EUR_CRM_Day__c)-1);
                }
                System.debug('Flag - Process Events Day:' + templateEndDate + ' - '+startEventDate + ' - ' + routeTemplateItem);
                if(templateEndDate>=startEventDate && startEventDate>=populationStartDate){
                    //Set End Date= an hour after start date
                    DateTime startEventDateTime = DateTime.newInstance(startEventDate, Time.newInstance(9, 0, 0, 0));
                    DateTime endEventDate = startEventDateTime.addHours(1);
                    Integer daysDiff = Math.abs(startEventDate.daysBetween(startDate));
                    //System.debug('Flag - Days Diff:' + daysDiff);
                    Integer weekCount = (daysDiff==0)? 1: (Integer.valueOf(Math.ceil(daysDiff/7))+1);
                    Event newEvent = routeTemplateClass.createEvent(routeTemplateItem, startEventDateTime, 
                                                                endEventDate, routeTemplateItem.routeTemplateItem.Id, weekCount);
                    
                    eventList.add(newEvent);
                    
                    //Add to Event JS
                    EUR_CRM_RouteTemplateClass.EventJS eventJS = routeTemplateClass.createEventJS(routeTemplateItem, 
                                                                                                evCount, rtDay, startEventDate);     
                                                                                                                                                                                                              
                    //if(eventsJSDisplayList.size()<LIST_VIEW_LIMIT){
                    eventsJSDisplayList.add(eventJS);
                    //}
                    evCount++;
                    
                    routeTemplateItem.routeTemplateItem.EUR_CRM_Last_Scheduled_Visit__c = startEventDate;
                }
                
        }
        if (eventList.size()>0){
                if(routeItems == null)
                    routeItems = new Set<EUR_CRM_Route_Template_Item__c>();
                if(routeItemIds  == null)
                    routeItemIds = new Set<ID>();
                if(!routeItemIds.contains(routeTemplateItem.routeTemplateItem.id)){
                    routeItems.add(routeTemplateItem.routeTemplateItem); //include RTI on list for upsert
                    routeItemIds.add(routeTemplateItem.routeTemplateItem.id);
                }

        }
        return eventList;
        }
        
         
    public PageReference populateCalendar(){
        PageReference pageRef = null;
        populateTempCalendar(populationDate);
                
        //if(checkEventCount(events.size())){
            Database.saveResult[] insertEventResult;
            System.Savepoint pSavepoint = Database.setSavepoint();
                
            try{
                if(events.size()>0){
                    if(events.size() < 2000){
                        System.debug('Flag - About to insert events:' + events);
                        insertEventResult = Database.insert(events);
                        
                        Date routePlanEndDate = templateEndDate;
                        Date taskReminderDate = reminderDate;
                        
                        List<EUR_CRM_Route_Template_Item__c> routeItemsList = new List<EUR_CRM_Route_Template_Item__c>();
                        routeItemsList.addAll(routeItems);
                        update routeItemsList;
                        
                        //TODO EDIT ROUTE TEMPLATE, ADD LAST POPULATE DATE
                        routeTemplate.EUR_CRM_Last_Date_Populated__c = templateEndDate;
                        routeTemplate.EUR_CRM_Scheduled__c = true;
                        routeTemplate.EUR_CRM_Reset_Week__c = null;
                        //Added May 4, 2015 - active flag is set upon calendar population (for Germany and Finland only)
                        if(countriesWithActiveFlag.contains(routeTemplate.EUR_CRM_Country_Code__c))
                            routeTemplate.EUR_CRM_Active__c = true;
                        
                        update routeTemplate;
                        
                        //Set Repopulation Reminder - Task
                        setReminderTask(taskReminderDate, routePlanEndDate);
                        pageRef = new PageReference('/'+routeTemplate.Id);
                    }
                    else{ // INSERT events by batches
                        pageRef = null;
                        Integer MAX_BATCHES = 5;
                        Integer runningBatchJobs = [select count() from AsyncApexJob where JobType = 'BatchApex'
                          and status in ('Queued','Processing','Preparing') ];

                        if(runningBatchJobs >= MAX_BATCHES) {
                          ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.WARNING, 'No resources available.  Please try again later.'
                          ));
                        } else { 
                          ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.INFO, 'There are too many events to be created. A batch process has already been submitted to process your request, an email will be sent to you after the batch process finished.'
                          ));
                            //create the postDMLS
                            
                            routeTemplate.EUR_CRM_Is_Batch_Processing__c = true;
                            update routeTemplate;
                            Database.executeBatch(new EUR_CRM_BatchDML_Utility(events, 'Event', EUR_CRM_BatchDML_Utility.Operation.INSERT_RECORDS,true, createPostDMLs()));
                            
                            disableSave = true;
                        }
                    }
                }
                
            }
            catch(Exception e){
                System.debug('Insert Error: ' + e);
                pageRef = null;
                Database.rollback(pSavepoint);      
                String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                //System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
                if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
                {
                    String s = e.getDmlMessage(0);
                    strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                }
                else{       
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
                }
            }
       //}
         
        return pageRef ; 
    }
    
    private void setReminderTask(Date reminderDate, Date referenceDate){
        routeTemplateClass.clearReminderTask();
        
        if (routeTemplate.EUR_CRM_Reminder_Day__c != null && routeTemplate.EUR_CRM_Reminder_Day__c>0)
            routeTemplateClass.createReminderTask(reminderDate, referenceDate,routeTemplate.id);
    }
    
    private boolean checkEventCount(Integer eventCount){
        if(eventCount >= routeTemplateClass.maxEventCount){
                        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Event count ('+eventCount+') exceeded ' + 
                                                                routeTemplateClass.maxEventCount+ ' limit, cannot be saved'));
                        return false;
        }return true;
    }
    
    public List<EUR_CRM_BatchDML_Utility.PostDML> createPostDMLs(){
        List<EUR_CRM_BatchDML_Utility.PostDML> postDMLs = new List<EUR_CRM_BatchDML_Utility.PostDML>();
        Date routePlanEndDate = templateEndDate;
        Date taskReminderDate = reminderDate;
        List<EUR_CRM_Route_Template_Item__c> routeItemsList = new List<EUR_CRM_Route_Template_Item__c>();
        routeItemsList.addAll(routeItems);
        EUR_CRM_BatchDML_Utility.PostDML routeItemsListPOSTDML = new EUR_CRM_BatchDML_Utility.PostDML(EUR_CRM_BatchDML_Utility.Operation.UPDATE_RECORDS, (List<sObject>) routeItemsList);                
        routeTemplate.EUR_CRM_Last_Date_Populated__c = templateEndDate;
        routeTemplate.EUR_CRM_Scheduled__c = true; 
        routeTemplate.EUR_CRM_Reset_Week__c = null;
        routeTemplate.EUR_CRM_Is_Batch_Processing__c = false;
        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        routeTemplateList.add(routeTemplate);
        EUR_CRM_BatchDML_Utility.PostDML routeTemplateListPOSTDML = new EUR_CRM_BatchDML_Utility.PostDML(EUR_CRM_BatchDML_Utility.Operation.UPDATE_RECORDS, (List<sObject>) routeTemplateList);                
        postDMLs.add(routeItemsListPOSTDML);
        postDMLs.add(routeTemplateListPOSTDML);

        //clear reminder task
        List<Task> taskList = [SELECT Id  FROM Task WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id LIMIT 1];
        EUR_CRM_BatchDML_Utility.PostDML taskListPOSTDML = new EUR_CRM_BatchDML_Utility.PostDML(EUR_CRM_BatchDML_Utility.Operation.DELETE_RECORDS,  (List<sObject>)taskList );                
        postDMLs.add(taskListPOSTDML);
        if (routeTemplate.EUR_CRM_Reminder_Day__c != null && routeTemplate.EUR_CRM_Reminder_Day__c>0){
            EUR_CRM_Route_Template__c routeTemplateInfo = [SELECT id, OwnerId, EUR_CRM_Self_Assigned__c, EUR_CRM_Assigned_To__c FROM EUR_CRM_Route_Template__c WHERE id = :routeTemplate.id LIMIT 1];
            List<Task> taskList2 = new  List<Task>();
            Task task = new Task();
            task.Priority = 'Low';
            task.Status = 'Not Started'; 
            task.Subject = 'Other';
            task.EUR_CRM_Route_Template__c = routeTemplate.Id;
            task.ReminderDateTime = DateTime.newInstance(reminderDate, Time.newInstance(9, 0, 0, 0));
            task.IsReminderSet = true;
            task.ActivityDate = reminderDate;
            task.WhatId = routeTemplate.Id;
            task.Description = 'Last visit for Route Template,'+routeTemplate.Name+', is about to end on '+templateEndDate;
            if (routeTemplateInfo.EUR_CRM_Self_Assigned__c){
                task.OwnerId = routeTemplateInfo.OwnerId;
                }else{
                    task.OwnerId = routeTemplateInfo.EUR_CRM_Assigned_To__c;
                }
            taskList2.add(task);
            EUR_CRM_BatchDML_Utility.PostDML taskPOSTDML = new EUR_CRM_BatchDML_Utility.PostDML(EUR_CRM_BatchDML_Utility.Operation.INSERT_RECORDS, (List<sObject>) taskList2);                
            postDMLs.add(taskPOSTDML);
        }                   
        return postDMLs;
    }
}