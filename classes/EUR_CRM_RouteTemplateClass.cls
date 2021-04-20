public with sharing class EUR_CRM_RouteTemplateClass {
    
    public final Integer maxTemplateEventCount=5000;
    public final Integer maxEventCount=10000;
    private final String INTERNAL_EVENT = 'INTERNAL';
    private final String EXTERNAL_EVENT = 'EXTERNAL';
    
    private Date systemStartDate{get;set;}{systemStartDate = Date.today();}
    
    private final Map<String, Integer>ROUTE_SYSTEM_DAY_MAP = new Map<String, Integer>{'Saturday'=>2 , 
                                                                                'Sunday'=>1 , 
                                                                                'Monday'=>0 , 
                                                                                'Tuesday'=>-1 , 
                                                                                'Wednesday'=>-2 , 
                                                                                'Thursday'=>-3 , 
                                                                                'Friday'=>-4};
    private final Set<String> ROUTE_WEEKEND_SET = new Set<String>{'Saturday', 'Sunday'};
    private Id templateEventRecordTypeId {get;set;}
    
    public EUR_CRM_Route_Template__c routeTemplate{get;set;}
    public List<RouteItemWrapper> routeItems{get;set;}{routeItems = new List<RouteItemWrapper>();}
    public Map<Id, RouteItemWrapper> routeItemsMap{get; set;}{routeItemsMap = new Map<Id, RouteItemWrapper>();}//Key:Account Id
    public Set<EUR_CRM_Route_Template_Item__c> forDeletionInactiveRouteTemplate = new Set<EUR_CRM_Route_Template_Item__c>(); //Route Template Items with Inactive Account
    public Set<EUR_CRM_Route_Template_Day__c> forDeletionVisitModifiedRouteTemplate = new Set<EUR_CRM_Route_Template_Day__c>(); //Route Template Days with Modified Visit Frequency
    
    public Map<Id, List<EUR_CRM_Route_Template_Day__c>> routeTemplateDays{get;set;}{routeTemplateDays = new Map<Id, List<EUR_CRM_Route_Template_Day__c>>();}
    public Map<Id, List<Event>> openEvents{get;set;}{openEvents= new Map<Id, List<Event>>();}
    
    public Integer eventCount {get;set;}{eventCount=0;} //Total of Event Count Template
    public Integer eventCountEstimate{get;set;}{eventCountEstimate=0;} //Total of estimated event count in one cycle 
    
    //Country Specific Properties
    public Boolean hasExternalEvents{get;set;}{hasExternalEvents = false;} //True for Baltics
    public String externalEventsRecordType{get;set;}
    
    //FOR JS Event Display
    public Map<Id, List<EventJS>> eventsJSDisplayMap{get;set;}{eventsJSDisplayMap = new Map<Id, List<EventJS>>();}//Internal Template events
    public List<EventJS> externalEventsList{get;set;}{externalEventsList = new List<EventJS>();}
    public List<EventJS> externalEventsAll{get;set;}{externalEventsList = new List<EventJS>();}
    
    public Boolean isEditable{get{
        Boolean isEditable = false;
        if (routeTemplate!=null && routeTemplate.OwnerId == UserInfo.getUserId()){
            isEditable = true;
        }
        return isEditable;
    }}

    public EUR_CRM_RouteTemplateClass(Id routeTemplateId){
        this.routeTemplate = retrieveRouteTemplate(routeTemplateId);
        
        if (routeTemplate.EUR_CRM_External_Event_Record__c != null){
            externalEventsRecordType = routeTemplate.EUR_CRM_External_Event_Record__c;
            hasExternalEvents = true;
        }
        
         if (routeTemplate.EUR_CRM_Template_Event_Record_Type__c != null && 
            String.valueOf(routeTemplate.EUR_CRM_Template_Event_Record_Type__c).trim().length()>0){
            templateEventRecordTypeId = retrieveTemplateEventRecordTypeId(routeTemplate.EUR_CRM_Template_Event_Record_Type__c);
        }
    }
    
    public EUR_CRM_RouteTemplateClass(Id routeTemplateId, Date systemStartDate){
        this.routeTemplate = retrieveRouteTemplate(routeTemplateId);
        this.systemStartDate = systemStartDate;
        
        if (routeTemplate.EUR_CRM_External_Event_Record__c != null){
            externalEventsRecordType = routeTemplate.EUR_CRM_External_Event_Record__c;
            hasExternalEvents = true;
        }
        
        if (routeTemplate.EUR_CRM_Template_Event_Record_Type__c != null && 
            String.valueOf(routeTemplate.EUR_CRM_Template_Event_Record_Type__c).trim().length()>0){
            templateEventRecordTypeId = retrieveTemplateEventRecordTypeId(routeTemplate.EUR_CRM_Template_Event_Record_Type__c);
        }
    }
    
    
    public EUR_CRM_Route_Template__c retrieveRouteTemplate(Id routeTemplateId){     
                List<EUR_CRM_Route_Template__c> tmp = [SELECT Id, 
                                                    OwnerId,
                                                    Name, RecordType.developername,
                                                    EUR_CRM_Country_Code__c, EUR_CRM_Active__c,
                                                    EUR_CRM_Last_Date_Populated__c, EUR_CRM_Reset_Week__c,
                                                    EUR_CRM_Max_Planning_Period_Week__c, EUR_CRM_Max_Visit_Duration_Hour__c,
                                                    EUR_CRM_Scheduled__c, EUR_CRM_Planning_Period__c,
                                                    EUR_CRM_Visit_Duration__c, EUR_CRM_Reminder_Day__c,
                                                    EUR_CRM_External_Event_Record__c, EUR_CRM_Template_Event_Record_Type__c,
                                                    EUR_CRM_Other_Visits_Viewable__c, EUR_CRM_Has_View_More__c,
                                                    EUR_CRM_Is_All_Day_Event__c, EUR_CRM_Has_Template_Clean_Out__c,
                                                    EUR_CRM_Assigned_To__c, EUR_CRM_Self_Assigned__c
                                                    FROM EUR_CRM_Route_Template__c
                                                    WHERE Id=: routeTemplateId
                                                    LIMIT 1];

                EUR_CRM_Route_Template__c tempRouteTemplate = (tmp.size()>0)?tmp[0]:null;

                return tempRouteTemplate;
    }
    
    public List<EventJS> retrieveExternalEvents(Date startDate, String recordTypeName){
        List<EventJS> externalEvents = new List<EventJS>();
        DateTime startDateTime= DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        List <Event> events = new List<Event>();
        List<Id> eventWhatId = new List<Id>();
        
        if (routeTemplate!=null){
            for (Event externalEv : [SELECT Id, AccountId, ActivityDateTime, 
                            DurationInMinutes, EndDateTime, OwnerId, 
                            StartDateTime, Subject, Type, WhatId, 
                            EUR_CRM_Route_Template__c, EUR_CRM_Route_Template_Item__c, 
                            EUR_CRM_Week_Number__c, EUR_CRM_Account_Details__c,
                            CreatedDate
                            FROM Event
                            WHERE ActivityDateTime>:startDateTime
                            AND ActivityDateTime<:startDateTime.addYears(1)
                            AND RecordType.developername =: recordTypeName
                            AND OwnerId =: routeTemplate.OwnerId
                            ORDER BY ActivityDateTime, CreatedDate
                            LIMIT 49999]){
                events.add(externalEv);
                eventWhatId.add(externalEv.WhatId);
            }
            
            //Get Account Name
            Map <Id, String> accountNameMap = new Map<Id, String>();
            for (Account acct: [Select Id, Name From Account WHERE Id IN: eventWhatId LIMIT 49999]){
                accountNameMap.put(acct.Id, acct.Name);
            }
            
            //Create EventJS object
            for (Event event: events){
                Integer dayNum = Integer.valueOf(event.ActivityDateTime.day() - startDate.day());
                Date eventStartDate = systemStartDate.addDays(dayNum);
                Date originalStartDate = Date.newInstance(event.ActivityDateTime.year(),event.ActivityDateTime.month(),event.ActivityDateTime.day());
                String accountName = (accountNameMap.containsKey(event.WhatId))?accountNameMap.get(event.WhatId):event.WhatId;
                System.debug('Check - External event - Account Name:' + accountName);
                if(accountName == null || accountName=='null' || accountName.trim().length()<=0){
                    accountName = String.valueOf(event.Id);
                }
                System.debug('Check - External event - Account Name2:' + accountName);
                EventJS evDisplay = new EventJS(event.Id, accountName, 0, event.subject, 
                                        originalStartDate, 
                                        eventStartDate, 
                                        dayNum);
                externalEvents.add(evDisplay);
            }
        }
        
        System.debug('Check - External Events:' + externalEvents);
        return externalEvents;
    }
    
    public List<EventJS> getSelectedExternalEvents(Date referenceDate){
        externalEventsList = new List<EventJS>();
        
        Date monday = calculateStartingMonday(referenceDate);
        System.debug('Flag - Selected External Event Date - Check Monday:' + monday);
        if (externalEventsAll!=null){
            externalEventsAll.sort();
            System.debug('Flag - All external events:' + externalEventsAll);
            for(EventJS externalEv: externalEventsAll){
                if (externalEv.originalStartDate >= monday){
                    Integer dayNum = Integer.valueOf(externalEv.originalStartDate.day() - monday.day());
                    Date eventStartDate = systemStartDate.addDays(dayNum);
                    externalEv.setNewDate(eventStartDate);
                    externalEv.eventDayNum = String.valueOf(dayNum);
                    externalEventsList.add(externalEv);
                }else continue;
            }
        }
        System.debug('Flag - Selected External Event Date - External Event:' + externalEventsList);
        return externalEventsList;
    }
    
    public List<routeItemWrapper> initRouteItems(boolean isRouteTemplate, Date startDate, Boolean isForCleanOut)
    {
        System.debug('Init Route Items:' + isRouteTemplate + '-' + startDate);
        //Id userId = UserInfo.getUserId();
        
        routeItems = new List<routeItemWrapper>();
        eventCount = 0;
        eventCountEstimate = 0;
        
        //Get all Route Template Days
        routeTemplateDays = retrieveRouteDays();
        System.debug('Flag - Route Days Map: ' + routeTemplateDays);
        //TODO Get all Latest Visitation Date - Event
        
        Set<Id> accountList = new Set<Id>();
        Set<Id> allUserAccounts = new Set<Id>();
        //Map for checking (key = Account)
        Map<Id, EUR_CRM_Route_Template_Item__c> rtiMap = new Map<Id, EUR_CRM_Route_Template_Item__c>();
        
        if (routeTemplate!=null){
            //Get existing Route Template Items
            for(EUR_CRM_Route_Template_Item__c rti: [SELECT Id, EUR_CRM_Route_Template__r.OwnerId,
                                                    EUR_CRM_Meeting_Duration_Minutes__c, EUR_CRM_Name__c,
                                                    EUR_CRM_Route_Template__c, EUR_CRM_Subject__c,
                                                    EUR_CRM_Event_Count__c, EUR_CRM_Visit_Frequency__c,
                                                    EUR_CRM_Visit_Span__c, EUR_CRM_Visit_Frequency_Name__c,
                                                    EUR_CRM_First_Day__c, EUR_CRM_Account__c,
                                                    EUR_CRM_Account__r.EUR_CRM_Active_Flag__c, EUR_CRM_Account__r.Name,
                                                    EUR_CRM_Account__r.EUR_CRM_Postal_Code__c, EUR_CRM_Account__r.EUR_JB_City_Name__c,
                                                    EUR_CRM_Account__r.EUR_CRM_Street__c, EUR_CRM_Last_Scheduled_Visit__c,
                                                    EUR_CRM_Previous_Visit_Frequency__c, EUR_CRM_Previous_Visit_Span__c,
                                                    EUR_CRM_Visit_Frequency_Modified__c, EUR_CRM_Default_Subject__c
                                                    FROM EUR_CRM_Route_Template_Item__c
                                                    WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id
                                                    AND EUR_CRM_Route_Template__r.OwnerId =: routeTemplate.OwnerId//userId
                                                    ORDER BY EUR_CRM_Account__r.EUR_CRM_Postal_Code__c NULLS LAST
                                                    LIMIT 1000])
        //retrieveRouteTemplateItems())
            {       
                if (rti.EUR_CRM_Account__r.EUR_CRM_Active_Flag__c == true){
                    rtiMap.put(rti.EUR_CRM_Account__c, rti);
                    //Create Route Template Item Wrapper instance
                    List<EUR_CRM_Route_Template_Day__c> rDays = (routeTemplateDays.containsKey(rti.EUR_CRM_Account__c))?routeTemplateDays.get(rti.EUR_CRM_Account__c):new List<EUR_CRM_Route_Template_Day__c>();
                    
                    //TODO CLEAR IF VISIT FREQUENCY WAS MODIFIED
                    if (rti.EUR_CRM_Visit_Frequency_Modified__c==true && rDays.size()>0){
                        //TODO ADD ITEM FOR DELETION
                        forDeletionVisitModifiedRouteTemplate.addAll(rDays);
                        //Set Route Days to Blank
                        rDays = new List<EUR_CRM_Route_Template_Day__c>();
                    }
                    
                    String subject = (rti.EUR_CRM_Subject__c==null)?rti.EUR_CRM_Default_Subject__c:rti.EUR_CRM_Subject__c;
                    routeItemWrapper rtiWrap = createRouteItemWrap(rti, 
                                                Double.valueOf(rti.EUR_CRM_Meeting_Duration_Minutes__c),
                                                rti.EUR_CRM_Subject__c,
                                                subject,
                                                rti.EUR_CRM_Visit_Frequency_Name__c,
                                                Double.valueOf(rti.EUR_CRM_Visit_Frequency__c), 
                                                Double.valueOf(rti.EUR_CRM_Visit_Span__c),
                                                rti.EUR_CRM_Account__c,
                                                rti.EUR_CRM_Account__r.Name,
                                                null,
                                                rti.EUR_CRM_Account__r.EUR_CRM_Postal_Code__c,
                                                rti.EUR_CRM_Account__r.EUR_JB_City_Name__c,
                                                rti.EUR_CRM_Account__r.EUR_CRM_Street__c,
                                                rDays
                                                );  
                    //rtiWrap.lastScheduleVisit = rti.EUR_CRM_Last_Scheduled_Visit__c;            
                    routeItems.add(rtiWrap);
                    routeItemsMap.put(rti.EUR_CRM_Account__c, rtiWrap);
                    accountList.add(rti.EUR_CRM_Account__c);//To exclude at Account query
                    
                    //Add to Event JS Display
                    List<EventJS> eventJSList = new List<EventJS>();
                    System.debug('Flag - EVENT JS LIST ADD:' + Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c)+'-'+rtiWrap+'-'+rDays+'-'+startDate);
                    if (rDays.size()>0 && startDate!=null && rti.EUR_CRM_Visit_Span__c!=null && Integer.valueOf(rti.EUR_CRM_Visit_Span__c)>0){
                        addEventJSToMap(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c), rtiWrap, rDays, startDate);
                        rtiWrap.isEventSet = true;   
                    }
        
                    //Add to event count computed
                    eventCount += (rti.EUR_CRM_Event_Count__c==null)?0:Integer.valueOf(rti.EUR_CRM_Event_Count__c);
                    eventCountEstimate += Integer.valueOf(eventCount);
                }else if (rti.EUR_CRM_Account__r.EUR_CRM_Active_Flag__c == false){
                    //TODO ADD ITEM FROR DELETION
                    forDeletionInactiveRouteTemplate.add(rti);
                }
            }
            
            if (accountList.size()>0){
                allUserAccounts.addAll(accountList);
            }
            System.debug('Flag - Route Items Wrap 1:' + routeItems);
            System.debug('Flag - Event JS:' + eventsJSDisplayMap);
            //Form new  Route Template Items from Account
            if (isRouteTemplate){
                Integer remAccountLimit = (1000 - routeItems.size());
                for (EUR_CRM_Account__c account: [Select Id, 
                                            Name, OwnerId,
                                            EUR_CRM_Visit_Frequency__c,
                                            EUR_CRM_Visit_Frequency__r.Name,
                                            EUR_CRM_Visit_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c,
                                            EUR_CRM_Visit_Frequency__r.EUR_CRM_Frequency_Span_Days__c,
                                            EUR_CRM_Visit_Frequency_Filtered__c,
                                            EUR_CRM_Visit_Frequency_Filtered__r.Name,
                                            EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_No_of_Visits_Within_Interval__c,
                                            EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_Frequency_Span_Days__c,
                                            EUR_CRM_Postal_Code__c,
                                            EUR_JB_City_Name__c,
                                            EUR_CRM_Street__c,
                                            EUR_CRM_Active_Flag__c,
                                            CreatedDate,
                                            UserRecordAccess.HasEditAccess 
                                            FROM EUR_CRM_Account__c
                                            WHERE Name!=null and (Id NOT IN:accountList)
                                            //10/16 Edit - Account List should include all records User HasEdit access to //AND OwnerId =: routeTemplate.OwnerId //userId
                                            AND EUR_CRM_Active_Flag__c=true
                                            ORDER BY EUR_CRM_Postal_Code__c NULLS LAST
                                            LIMIT :remAccountLimit])
                {
                    if((!rtiMap.containsKey(account.Id)) && account.UserRecordAccess.HasEditAccess)
                    {
                        //Add to All User Accounts
                        allUserAccounts.add(account.Id);
                        
                        EUR_CRM_Route_Template_Item__c rti = new EUR_CRM_Route_Template_Item__c(EUR_CRM_Account__c=account.Id, EUR_CRM_Route_Template__c=routeTemplate.Id);
                        rtiMap.put(account.Id, rti);
                        //TODO Confirm Record Type of JB on EUR Account, change using formula field implementation
                        String tempVisitFrequencyName = (account.EUR_CRM_Visit_Frequency_Filtered__c!=null)?account.EUR_CRM_Visit_Frequency_Filtered__r.Name:account.EUR_CRM_Visit_Frequency__r.Name;
                        Double tempVisitFrequencySpan = Double.valueOf((account.EUR_CRM_Visit_Frequency_Filtered__c!=null)?account.EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_Frequency_Span_Days__c:account.EUR_CRM_Visit_Frequency__r.EUR_CRM_Frequency_Span_Days__c);
                        Double tempVisitFrequencyDuration = Double.valueOf((account.EUR_CRM_Visit_Frequency_Filtered__c!=null)?account.EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_No_of_Visits_Within_Interval__c:account.EUR_CRM_Visit_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c);
                        //modified by Dakang 2013-12-17
                        String subject = (rti.EUR_CRM_Subject__c==null)?rti.EUR_CRM_Default_Subject__c:rti.EUR_CRM_Subject__c;
                        routeItemWrapper rtiWrap = createRouteItemWrap(rti, 
                                                    Double.valueOf(rti.EUR_CRM_Meeting_Duration_Minutes__c),
                                                    rti.EUR_CRM_Subject__c,
                                                    subject,
                                                    tempVisitFrequencyName,//account.EUR_CRM_Visit_Frequency__r.Name,
                                                    Double.valueOf(tempVisitFrequencyDuration),//account.EUR_CRM_Visit_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c), 
                                                    Double.valueOf(tempVisitFrequencySpan),//account.EUR_CRM_Visit_Frequency__r.EUR_CRM_Frequency_Span_Days__c),
                                                    account.Id,
                                                    account.Name,
                                                    null,
                                                    account.EUR_CRM_Postal_Code__c,
                                                    account.EUR_JB_City_Name__c,
                                                    account.EUR_CRM_Street__c,
                                                    null);                                       
        
                        routeItems.add(rtiWrap);
                        routeItemsMap.put(rti.EUR_CRM_Account__c, rtiWrap);
                    }
                }
                System.debug('Flag - Route Items Wrap 2:' + routeItems);
            }
            
            //Set Account's Last Visit Date - Event (Calendar)
            Map<Id, DateTime> accountLastVisitDates = retrieveLastVisitDates(allUserAccounts);
            for (Id key: accountLastVisitDates.keySet()){
                if (routeItemsMap.containsKey(key)){
                    RouteItemWrapper rtiWrap = routeItemsMap.get(key);
                    rtiWrap.lastScheduleVisit = accountLastVisitDates.get(key).date();
                }
            }
            
            //Get External Events
            if (hasExternalEvents){     
                //Get Monday of the week - default start Date
                Date startingMonday = calculateStartingMonday(Date.today());
                
                externalEventsAll = retrieveExternalEvents(startingMonday, externalEventsRecordType);
                externalEventsList = externalEventsAll;
                System.debug('Flag - External Events List('+startingMonday+'-'+externalEventsRecordType+'):' + externalEventsList);
            }
            
            System.debug('Flag - Event Count Estimate:' + eventCountEstimate);
            routeItems.sort();
            
            //TODO CLEAN OUT ROUTE TEMPLATE
            if (isForCleanOut){
                System.debug('Flag - Check Clean Out:' + forDeletionInactiveRouteTemplate + '-' +forDeletionVisitModifiedRouteTemplate);
                cleanOutRouteTemplateItems(forDeletionInactiveRouteTemplate, forDeletionVisitModifiedRouteTemplate);
            }
        }
        return routeItems;
    }
    
    private Map<Id, DateTime> retrieveLastVisitDates(Set<Id> accounts){
        Map<Id, DateTime> accountLastVisitDates = new Map<Id, DateTime>();
        List<Id> accountList = new List<Id>();
        accountList.addAll(accounts);
        if (routeTemplate!=null){
            for(AggregateResult ar: [SELECT WhatId, MAX(StartDateTime)visitDate 
                                    FROM Event 
                                    WHERE WhatId IN : accountList
                                    AND OwnerId =: routeTemplate.OwnerId//UserInfo.getUserId()
                                    GROUP BY WhatId]){
                accountLastVisitDates.put((Id)ar.get('WhatId'), (DateTime)ar.get('visitDate'));
            }
        }
        
        return accountLastVisitDates;
    }
    
    public void deleteRouteItems(Integer key){
         Id currentAccountId = routeItems.get(key).accountId;
         
        //routeItems.remove(key);
        routeItemsMap.remove(currentAccountId);
    }
    
    public void deleteRouteItems(String accountId){
        //Id currentAccountId = routeItems.get(key).accountId;
         
        //routeItems.remove(key);
        routeItemsMap.remove(accountId);
    }
    
    
    public EUR_CRM_Route_Template_Day__c createRouteTemplateDay(EUR_CRM_Route_Template_Item__c routeItemObj, Integer day){
        EUR_CRM_Route_Template_Day__c newDay = new EUR_CRM_Route_Template_Day__c(EUR_CRM_Route_Template_Item__c=routeItemObj.Id ,EUR_CRM_Day__c=day);
        
        return newDay;
    }
    
    public void updateRouteTemplateDay(String accountId, Integer rowNum, Integer day){
        if(routeItemsMap.containsKey(accountId)){
            routeItemWrapper routeItem = routeItemsMap.get(accountId);

            if(routeItem.routeDays.size()>=0 || routeItem.routeDays.size()<rowNum){
                EUR_CRM_Route_Template_Day__c dayRecord = createRouteTemplateDay(routeItem.routeTemplateItem, day);
                routeItem.routeDays.add(dayRecord);
                routeItem.routeDaysInt.add(day);
            }else{
                routeItem.routeDays[rowNum].EUR_CRM_Day__c = day;
                routeItem.routeDaysInt[rowNum] = day;
            }
            
        }
    }
    
    public Date getNextWorkingDate(DateTime referenceDateTime){
        DateTime populationDateTime = referenceDateTime.addDays(1); //Next Working Day
        String populationDay = populationDateTime.format('EEEE'); 
        //Check if Weekend, calculate next working day
        if (ROUTE_WEEKEND_SET.contains(populationDay)){
            populationDateTime = populationDateTime.addDays(ROUTE_SYSTEM_DAY_MAP.get(populationDay));
        }
        System.debug('Flag - Get Population Date - Check Date:' + referenceDateTime + '- Next Working Day' + populationDateTime);
        return populationDateTime.date();
    }
    
    public Event createEvent(Id accountId, DateTime startDate, DateTime endDate, 
                            Integer duration, String subject, Id routeTemplateItemId, Integer weekNum){
        /*AccountId, ActivityDateTime, 
                        DurationInMinutes, EndDateTime, OwnerId, 
                        StartDateTime, Subject, Type, WhatId,
                        EUR_CRM_Route_Template__c, EUR_CRM_Route_Template_Day__c, CreatedDate */
                        
        Event newEvent = new Event(WhatId = accountId, 
                                    ActivityDate = startDate.date(), 
                                    //StartDateTime = startDate, 
                                    //EndDateTime = endDate,
                                    //DurationInMinutes = duration,
                                    Subject = subject
                                    );
        if (routeTemplate.EUR_CRM_Is_All_Day_Event__c==true){
            newEvent.IsAllDayEvent = true;
        }else{
            newEvent.ActivityDateTime = startDate;
            newEvent.StartDateTime = startDate; 
            newEvent.EndDateTime = endDate;
            newEvent.DurationInMinutes = duration;
        }
        
        newEvent.EUR_CRM_Route_Template_Item__c = routeTemplateItemId;
        newEvent.EUR_CRM_Route_Template__c = routeTemplate.Id;  
        newEvent.EUR_CRM_Week_Number__c = weekNum;  
        //newEvent.EUR_CRM_Account_Details__c = routeItemWrap.accountName + '('+routeItemWrap.accountStreet+')';
            
        if (templateEventRecordTypeId!=null){
            newEvent.RecordTypeId = templateEventRecordTypeId;
        }
        
        return newEvent;
    }
    
    public Event createEvent(routeItemWrapper routeItemWrap, DateTime startDate, DateTime endDate, Id routeTemplateItemId, Integer weekNum){
        /*AccountId, ActivityDateTime, 
                        DurationInMinutes, EndDateTime, OwnerId, 
                        StartDateTime, Subject, Type, WhatId,
                        EUR_CRM_Route_Template__c, EUR_CRM_Route_Template_Day__c, CreatedDate */
                        
        String defaultName = (routeItemWrap.accountStreet==null)?routeItemWrap.accountName:(routeItemWrap.accountName+': '+routeItemWrap.accountStreet);
        defaultName = (isAT() || isDE())?routeItemWrap.accountName:defaultName;
        String defaultSubject = (isBaltics())?'Visit ':('Visit:'+ defaultName);
//        EUR_CRM_Route_Template__c routeTemplateInfo = [SELECT id, OwnerId, EUR_CRM_Self_Assigned__c, EUR_CRM_Assigned_To__c FROM EUR_CRM_Route_Template__c WHERE id = :routeTemplate.id LIMIT 1];
        EUR_CRM_Route_Template__c routeTemplateInfo = this.routeTemplate;
        /*
        Event newEvent = new Event(WhatId = routeItemWrap.accountId, 
                                    ActivityDateTime = startDate, 
                                    StartDateTime = startDate, 
                                    EndDateTime = endDate,
                                    DurationInMinutes = (routeItemWrap.meetingDuration!=null)?Integer.valueOf(routeItemWrap.meetingDuration):60,
                                    Subject = (routeItemWrap.subject!=null)? routeItemWrap.subject: defaultSubject
                                    );
        */
        Event newEvent = new Event(WhatId = routeItemWrap.accountId, 
                                    ActivityDate = startDate.date(), 
                                    Subject = (routeItemWrap.subject!=null)? routeItemWrap.subject: defaultSubject
                                    );
        
        if (routeTemplate.EUR_CRM_Is_All_Day_Event__c==true){
            newEvent.IsAllDayEvent = true;
        }else{
            newEvent.ActivityDateTime = startDate;
            newEvent.StartDateTime = startDate; 
            newEvent.EndDateTime = endDate;
            newEvent.DurationInMinutes = (routeItemWrap.meetingDuration!=null)?Integer.valueOf(routeItemWrap.meetingDuration):60;
        }
                                    
        newEvent.EUR_CRM_Route_Template_Item__c = routeTemplateItemId;
        newEvent.EUR_CRM_Route_Template__c = routeTemplate.Id;  
        newEvent.EUR_CRM_Week_Number__c = weekNum;  
        newEvent.EUR_CRM_Account_Details__c = (routeItemWrap.accountStreet==null)?routeItemWrap.accountName:routeItemWrap.accountName + '('+routeItemWrap.accountStreet+')';
        if (routeTemplateInfo.EUR_CRM_Self_Assigned__c){
                    newEvent.OwnerId = routeTemplateInfo.OwnerId;
                }else{
                    newEvent.OwnerId = routeTemplateInfo.EUR_CRM_Assigned_To__c;
                }
        if (templateEventRecordTypeId!=null){
            newEvent.RecordTypeId = templateEventRecordTypeId;
        }                   
        
        return newEvent;
    }
    
    public void populateRTIEventDisplay(Date startDate){
        //Iterate Route Items Wrapper
        eventsJSDisplayMap = new Map <Id, List<EventJS>>();
        
        for (RouteItemWrapper rtiWrap: routeItemsMap.values()){
            List<EventJS> eventsDisplay = new List<EventJS>();
            eventsDisplay = addEventJSToMap(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c), rtiWrap,
                            rtiWrap.routeDays, startDate);
            
            eventsJSDisplayMap.put(rtiWrap.accountId, eventsDisplay);
        }
        
        System.debug('Flag - Populate RTI Event Display:' + Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c) + '-' + eventsJSDisplayMap);
    }

    public List<EventJS> addEventJSToMap(Integer planningPeriod, 
                                        RouteItemWrapper routeItemWrap, 
                                        List<EUR_CRM_Route_Template_Day__c> rDays, 
                                        Date startDate){
        //Create Event JS until planning period
        Integer processCount = 0;
        List<EventJS> events = new List<EventJS>();
        Date templateEndDate = startDate.addDays(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c*7)-1);
        
        for (Integer week = 1; week<=routeTemplate.EUR_CRM_Planning_Period__c; week++){
            Integer startingDay = (7*((week-1)*1))+1;
            Integer endingDay = startingDay + 6;
            Date startingDate = startDate;
            Date endingDate = startingDate.addDays(endingDay-1);
            
            //TODO Get First Day base on EUR_CRM_Route_Template_Day__c List
            Integer firstDay = (routeItemWrap.routeTemplateItem.EUR_CRM_First_Day__c!=null && routeItemWrap.routeTemplateItem.EUR_CRM_First_Day__c>0)?Integer.valueOf(routeItemWrap.routeTemplateItem.EUR_CRM_First_Day__c):0;
            System.debug('Flag - Add Event to Map - Check First Day 1:'+firstDay+'-'+routeItemWrap.routeTemplateItem.EUR_CRM_First_Day__c);
            
            if (firstDay==0 && routeItemWrap.routeDays.size()>0){
                List<Integer> dayList = new List<Integer>();//Integer[(routeItemWrap.routeDays.size())];//==1)?(routeItemWrap.routeDays.size()):(routeItemWrap.routeDays.size()-1)];
                for (EUR_CRM_Route_Template_Day__c rtDay: routeItemWrap.routeDays){
                    dayList.add(Integer.valueOf(rtDay.EUR_CRM_Day__c));
                }
                dayList.sort();
                System.debug('Flag - Add Event to Map - Days List:' + dayList);
                firstDay = dayList.get(0);
            }
            Boolean isProcessed = false;
            
            System.debug('Flag - Add Event to Map - Check1:' +firstDay+'-'+routeItemWrap);
            if (routeItemWrap.visitFrequency!=null && firstDay>0 &&
                (routeItemWrap.visitSpan!=null || routeItemWrap.visitSpan<=0))
            {
                List<EventJS> newEvents = new List<EventJS>();
                
                
                Integer itemStartWeek = routeItemWrap.processCount + routeItemWrap.visitSpan;
                Date targetNexStartDate = startingDate.addDays(routeItemWrap.visitSpan*processCount);
                
                System.debug('Flag - Add Event to Map - Check2:' +firstDay+'-'+endingDay+'-'+startingDay+'-'+processCount+'-'+targetNexStartDate);
                if(firstDay<=endingDay && firstDay>=startingDay)
                {
                    isProcessed = true;
                    //newEvents
                    newEvents = processEventDays(startingDate, templateEndDate, startingDate,
                                                week, routeItemWrap, true);
                }
                else if (firstDay<endingDay && processCount>0 
                        && targetNexStartDate<endingDate && targetNexStartDate>=startingDate)
               {
                    isProcessed = true;
                    //newEvents
                    newEvents = processEventDays(startingDate, templateEndDate, startingDate,
                                                week, routeItemWrap, false);
               }
                if (newEvents.size()>0){
                    processCount++;
                    events.addAll(newEvents);
                }
            }
        }
        System.debug('Flag - Add Event to Map:' + events);
        eventsJSDisplayMap.put(routeItemWrap.accountId, events);
        return events;
    }
    
    private List<EventJS> processEventDays(Date startDate, Date templateEndDate, 
                                        Date populationStartDate, Integer week, 
                                        RouteItemWrapper routeTemplateItem, 
                                        Boolean firstFlag)
    {
        List<EventJS> eventList = new List<EventJS>();
        Integer evCount = 0;
        for (EUR_CRM_Route_Template_Day__c rtDay: routeTemplateItem.routeDays)
        {
            Date startEventDate;
            if(firstFlag){
                startEventDate = startDate.addDays(Integer.valueOf(rtDay.EUR_CRM_Day__c-1));
            }else{
                startEventDate = startDate.addDays(Integer.valueOf((7*(week-1))+rtDay.EUR_CRM_Day__c)-1);
            }
            
            if(templateEndDate>=startEventDate && startEventDate>=populationStartDate)
            {
                //Add to Event JS
                EventJS eventJS = createEventJS(routeTemplateItem, 
                                    evCount, rtDay, startEventDate);     
                eventList.add(eventJS);
                evCount++;
            }
        }
        
        return eventList;
    }
    
    public List<EventJS> addEventJSToMap(Integer planningPeriod, Integer visitSpan, Id accountId, String accountName, 
                                            List<EUR_CRM_Route_Template_Day__c> rDays, Date startDate){
        //Create Event JS until planning period
        List <EventJS> eventJSList = new List<EventJS>();
        Integer maxCount = Math.round((planningPeriod*7)/visitSpan);
        maxCount = (maxCount==0)?1:maxCount;
        System.debug('Flag - Add Event JS - Account:'+accountName+' - Max Count:' + maxCount + '-' + ((planningPeriod*7)/maxCount));
        
        for (Integer i=0; i<maxCount; i++){
            for (Integer j=0; j<rDays.size();j++){
                EUR_CRM_Route_Template_Day__c rDay = rDays.get(j);
                Integer dayNum = Integer.valueOf(rDay.EUR_CRM_Day__c+(i*visitSpan));
                EventJS evJS = new EventJS(accountId, accountName, j, accountName, 
                                        startDate.addDays(Integer.valueOf(dayNum-1)), dayNum);
                eventJSList.add(evJS);
            }
        }
        
        eventsJSDisplayMap.put(accountId, eventJSList);
        //eventsDisplayMap.put(INTERNAL_EVENTS, eventsJSDisplayMap);
        return eventJSList;
    }
    
    public EventJS createEventJS(String accountName, Id accountId, Integer eventOrder, Integer dayNum, Date startDate){
        EventJS newEventJS= new EventJS(accountId, accountName, eventOrder, accountName, 
                                    startDate.addDays(Integer.valueOf(dayNum-1)), dayNum);
        
        return newEventJS;
    }
    
    public EventJS createEventJS(RouteItemWrapper rti, Integer eventOrder, EUR_CRM_Route_Template_Day__c rDay, Date startDate){
        String eventName = (rti.accountStreet==null)?rti.accountName:rti.accountName+'-'+rti.accountStreet;
        EventJS newEventJS= new EventJS(rti.accountId, rti.accountName, eventOrder, eventName, 
                                    startDate, Integer.valueOf(rDay.EUR_CRM_Day__c));
        
        return newEventJS;
    }
    
    public void cleanOutRouteTemplateItems(Set<EUR_CRM_Route_Template_Item__c> routeTemplateItems, Set<EUR_CRM_Route_Template_Day__c> routeTemplateDays){
        //Removes Route Template Items with Inactive Account and Modified Visit Frequency.
            Database.deleteResult[] deleteResultRouteItems;
            Database.deleteResult[] deleteResultRouteDays;
            System.Savepoint pSavepoint = Database.setSavepoint();
            if (routeTemplate.EUR_CRM_Has_Template_Clean_Out__c && isEditable){
                try{            
                    List<EUR_CRM_Route_Template_Day__c> tempDeletedRouteDays = new List<EUR_CRM_Route_Template_Day__c>();
                    List<EUR_CRM_Route_Template_Item__c> tempDeletedRouteItems = new List<EUR_CRM_Route_Template_Item__c>();
                    
                    tempDeletedRouteDays.addAll(routeTemplateDays);
                    tempDeletedRouteItems.addAll(routeTemplateItems);
                    
                    deleteResultRouteDays = Database.delete(tempDeletedRouteDays);
                    System.debug('Flag - Clean Out - Route Template Days:' + deleteResultRouteDays);
                    deleteResultRouteItems = Database.delete(tempDeletedRouteItems);
                    System.debug('Flag - Clean Out - Route Template Items:' + deleteResultRouteItems);
                    
                    if (tempDeletedRouteItems.size()>0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, tempDeletedRouteItems.size()+' inactive route item/s were deleted'));
                    }
                    if (tempDeletedRouteDays.size()>0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleted '+tempDeletedRouteDays.size()+' day/s of modified visit frequency'));
                    }
                }catch(Exception e){
                    System.debug('Clean Out - Delete Error: ' + e);
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
            }
    }
    
    private routeItemWrapper createRouteItemWrap (EUR_CRM_Route_Template_Item__c rti, 
                                                Double meetingDuration,
                                                String subject,
                                                String eventSubject,
                                                String visitFrequencyName,
                                                Double visitFrequency, 
                                                Double visitSpan,
                                                Id accountId,
                                                String accountName,
                                                String accountAddress,
                                                String accountPostCode,
                                                String accountCity,
                                                String accountStreet,
                                                List<EUR_CRM_Route_Template_Day__c> routeDays)
    {
        RouteItemWrapper rtiWrap = new RouteItemWrapper();
        rtiWrap.routeTemplateItem = rti;    
        rtiWrap.meetingDuration = meetingDuration;
        rtiWrap.subject = subject;
        rtiWrap.visitFrequencyName = visitFrequencyName;
        rtiWrap.visitFrequency = Integer.valueOf(visitFrequency);
        rtiWrap.visitSpan = Integer.valueOf(visitSpan);
        rtiWrap.accountId = accountId;
        rtiWrap.accountName = accountName;
        rtiWrap.accountAddress = accountAddress;
        rtiWrap.accountPostCode = accountPostCode;
        rtiWrap.accountCity = accountCity;
        rtiWrap.accountStreet = accountStreet;

        rtiWrap.hasFrequency = (visitSpan==null || visitSpan==0)? false: true;
       
        //Country Specifications
        rtiWrap.isVisitFrequencyModified = (rti!=null && rti.EUR_CRM_Visit_Frequency_Modified__c!=null)?rti.EUR_CRM_Visit_Frequency_Modified__c:false;

        
        List<Integer> rDaysInt = new List<Integer>();
        if(routeDays!=null){
            rtiWrap.routeDays = routeDays;
            for(EUR_CRM_Route_Template_Day__c rDay: routeDays){
                rDaysInt.add(Integer.valueOf(rDay.EUR_CRM_Day__c));
            }
        }else{
            for(Integer i=0; i<visitFrequency; i++){
                rDaysInt.add(0);
            }
        }
        rtiWrap.routeDaysInt = rDaysInt;
        
        return rtiWrap;
    }
    
    private Map<Id, List<EUR_CRM_Route_Template_Day__c>> retrieveRouteDays(){
        Map<Id, List<EUR_CRM_Route_Template_Day__c>> rDaysMap = new Map<Id, List<EUR_CRM_Route_Template_Day__c>>();
        for (EUR_CRM_Route_Template_Day__c rDay: [SELECT Id,
                            EUR_CRM_Day__c,
                            EUR_CRM_Route_Template_Item__c, 
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c
                            FROM EUR_CRM_Route_Template_Day__c
                            WHERE EUR_CRM_Route_Template_Item__r.EUR_CRM_Route_Template__c=:routeTemplate.Id
                            ORDER BY EUR_CRM_Route_Template_Item__c, EUR_CRM_Day__c])
        {
            List<EUR_CRM_Route_Template_Day__c> rDays = rDaysMap.containsKey(rDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c)?rDaysMap.get(rDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c):new List<EUR_CRM_Route_Template_Day__c>(); 
            rDays.add(rDay);
            
            rDaysMap.put(rDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c, rDays);
        }
        
        System.debug('Flag - Retrieve Route Days Result: ' + rDaysMap);
        return rDaysMap;
    }
    
    private List<EUR_CRM_Route_Template_Item__c> retrieveRouteTemplateItems(){
        //modified by Dakang 2013-12-17                                           
        List<EUR_CRM_Route_Template_Item__c> rtiList = [SELECT Id, 
                                                    EUR_CRM_Meeting_Duration_Minutes__c,
                                                    EUR_CRM_Name__c,
                                                    EUR_CRM_Route_Template__c,
                                                    EUR_CRM_Subject__c,
                                                    EUR_CRM_Visit_Frequency__c,
                                                    EUR_CRM_Visit_Span__c,
                                                    EUR_CRM_Account__c,
                                                    EUR_CRM_Account__r.Name,
                                                    EUR_CRM_Account__r.EUR_CRM_Postal_Code__c,
                                                    EUR_CRM_Default_Subject__c,
                                                    EUR_CRM_Previous_Visit_Frequency__c, 
                                                    EUR_CRM_Previous_Visit_Span__c,
                                                    EUR_CRM_Visit_Frequency_Modified__c
                                                    FROM EUR_CRM_Route_Template_Item__c
                                                    WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id
                                                    ORDER BY EUR_CRM_Account__r.EUR_CRM_Postal_Code__c
                                                    LIMIT 4999];
        
        return rtiList;
    }
    
    private Id retrieveTemplateEventRecordTypeId(String developerName){
        List<Recordtype> recordTypeList = [SELECT Id, DeveloperName 
                                FROM Recordtype 
                                WHERE SobjectType = 'Event' 
                                AND DeveloperName=: developerName LIMIT 1];
        if (recordTypeList.size()>0){
            return recordTypeList.get(0).Id;
        }
        return null;
    }
    
    public Map<Id, List<Event>> retrieveEvents(){
        Map<Id, List<Event>> oEvents = new Map<Id, List<Event>>();
        //Id userId = UserInfo.getUserId();
        
        if (routeTemplate!=null){
            for (Event ev: [SELECT Id, AccountId, ActivityDateTime, 
                            DurationInMinutes, EndDateTime, OwnerId, 
                            StartDateTime, Subject, Type, WhatId,
                            EUR_CRM_Route_Template__c, EUR_CRM_Route_Template_Item__c, 
                            EUR_CRM_Week_Number__c, EUR_CRM_Account_Details__c,
                            CreatedDate
                            FROM Event
                            WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id
                            AND ActivityDateTime>TODAY
                            AND OwnerId =: routeTemplate.OwnerId //userId
                            LIMIT 49999]){
                                
                List<Event> evList = (oEvents.containsKey(ev.WhatId))?oEvents.get(ev.WhatId):new List<Event>();
                evList.add(ev);
                oEvents.put(ev.WhatId, evList);
            }
        }
        
        return oEvents;
    }
    

    public List<Event> retrieveEvents(Date fromDate){
        List<Event> oEvents = new List<Event>();
        
        for (Event ev: [SELECT Id, AccountId, ActivityDateTime, 
                        DurationInMinutes, EndDateTime, OwnerId, 
                        StartDateTime, Subject, Type, WhatId,
                        EUR_CRM_Route_Template__c, EUR_CRM_Route_Template_Item__c, 
                        EUR_CRM_Week_Number__c, EUR_CRM_Account_Details__c,
                        CreatedDate 
                        FROM Event
                        WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id
                        AND StartDateTime>=:fromDate
                        ORDER BY  StartDateTime
                        LIMIT 49999]){
                            
            //List<Event> evList = (oEvents.containsKey(ev.WhatId))?oEvents.get(ev.WhatId):new List<Event>();
            //evList.add(ev);
            oEvents.add(ev);
        }
        
        return oEvents;
    }
    
    public Map<Id, Event> retrieveEventsMap(Date fromDate){
        Map<Id, Event> oEvents = new Map<Id, Event>();
        
        for (Event ev: [SELECT Id, AccountId, ActivityDateTime, 
                        DurationInMinutes, EndDateTime, OwnerId, 
                        StartDateTime, Subject, Type, WhatId,
                        EUR_CRM_Route_Template__c, EUR_CRM_Route_Template_Item__c, 
                        EUR_CRM_Week_Number__c, EUR_CRM_Account_Details__c,
                        CreatedDate 
                        FROM Event
                        WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id
                        AND StartDateTime>=:fromDate
                        ORDER BY  StartDateTime
                        LIMIT 49999]){
                            
            //List<Event> evList = (oEvents.containsKey(ev.WhatId))?oEvents.get(ev.WhatId):new List<Event>();
            //evList.add(ev);
            oEvents.put(ev.Id, ev);
        }
        
        return oEvents;
    }
    
    
    public Date calculateStartingMonday(Date referenceDate){
        Datetime referenceDateTime = (DateTime)referenceDate;
        //String day = referenceDateTime.format('EEEE');
        Integer dayDiff = ROUTE_SYSTEM_DAY_MAP.get(referenceDateTime.format('EEEE'));
        Date monday = referenceDate.addDays(dayDiff);
        return monday;
    }
    
    public void createReminderTask(Date reminderDate, Date templateEndDate, Id rootTemplateId){
        Database.saveResult insertTaskResult;
        try{
            Task task = new Task();
            EUR_CRM_Route_Template__c routeTemplateInfo = [SELECT id, OwnerId, EUR_CRM_Self_Assigned__c, EUR_CRM_Assigned_To__c FROM EUR_CRM_Route_Template__c WHERE id = :rootTemplateId LIMIT 1];
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
            System.debug('Flag - Creating Task:' + task);
            
            insertTaskResult = Database.insert(task);
            System.debug('Flag - Task Insert Result:' + insertTaskResult);
        }
        catch(Exception e){
           System.debug('Insert Error: ' + e);  
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
    }
    
    public void clearReminderTask(){
        Database.deleteResult deleteTaskResult;
        try{
            List<Task> taskList = [SELECT Id, EUR_CRM_Route_Template__c 
                                    FROM Task WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id LIMIT 1];
            System.debug('Flag - Clearing Task:' + taskList);
            if (taskList.size()>0){
                Task task = taskList[0];
                deleteTaskResult = Database.delete (task);
                System.debug('Flag - Delete Task Result:' + deleteTaskResult);
            }
            }
        catch(Exception e){
           System.debug('Insert Error: ' + e);  
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
        
    }
    
    public Boolean isBaltics(){
        if (this.routeTemplate.RecordType.DeveloperName.toUpperCase().contains('EUR_EE') || 
            this.routeTemplate.RecordType.DeveloperName.toUpperCase().contains('EUR_LV') ||
            this.routeTemplate.RecordType.DeveloperName.toUpperCase().contains('EUR_LT')){
            return true;
        }
        return false;
    }
    
    public Boolean isAT(){
        if (this.routeTemplate.RecordType.DeveloperName.toUpperCase().contains('EUR_AT'))
            return true;
        return false;
    }
    public Boolean isDE(){
        if (this.routeTemplate.RecordType.DeveloperName.toUpperCase().contains('EUR_DE'))
            return true;
        return false;
    }
    
    
    public class RouteItemWrapper implements Comparable{
        public Integer rowNum{get;set;}
        public EUR_CRM_Route_Template_Item__c routeTemplateItem{get;set;}
        public Double meetingDuration{get;set;}
        public String subject{get;set;}
        public String eventSubject{get;set;}
        public String visitFrequencyName{get;set;}
        public Integer visitFrequency{get;set;}
        public Integer visitSpan{get;set;}
        public Id accountId{get;set;}
        public String accountName{get;set;}
        public String accountAddress{get;set;}
        public String accountPostCode{get;set;}
        public String accountCity{get;set;}
        public String accountStreet{get;set;}
        public Date lastScheduleVisit{get;set;}
        public String lastScheduleVisitStr{get{
            String visitDateStr = null;
            if (lastScheduleVisit!=null)
                visitDateStr = String.valueOf(lastScheduleVisit.format());
            return visitDateStr;
        }}
        public Boolean hasFrequency {get;set;}
        
        //Base on country specification
        public Boolean isVisitFrequencyModified{get;set;}
                
        public List<EUR_CRM_Route_Template_Day__c> routeDays{get;set;}{routeDays = new List<EUR_CRM_Route_Template_Day__c>();}
        public List<Integer> routeDaysInt{get;set;}{routeDaysInt = new List<Integer>();}
        
        //Route Template Process
        public Boolean isEventSet{get;set;}{isEventSet=false;}
        
        //Route Schedule specific
        public List<Event> events{get;set;}{events = new List<Event>();}
        public Integer processCount{get;set;}{processCount=0;}        
        //TODO Add Event List wrapper
        
        public Integer compareTo (Object compareTo){
            RouteItemWrapper compareToRtWrap = (RouteItemWrapper)compareTo;     
            if (accountPostCode == compareToRtWrap.accountPostCode) return 0;
            if (accountPostCode > compareToRtWrap.accountPostCode && compareToRtWrap.accountPostCode!=null) return 1;
            if(compareToRtWrap.accountPostCode==null) return -1;
            return -1; 
        }
    }
    
    public class EventJS implements Comparable{
        public Id accountId{get;set;}
        public String accountName{get;set;}
        public Integer eventOrder{get;set;}
        public String eventName {get;set;}
        public String eventYear {get;set;}
        public String eventMonth {get;set;}
        public String eventDay {get;set;}
        public String eventDayNum {get;set;}
        public Integer rowNum{get;set;}
        public Integer eventType{get;set;} //Internal or External
        public Date startDate{get;set;}
        public Date originalStartDate{get;set;}
            
        public EventJS(Id accountId, String accountName, Integer eventOrder, String name, Date eventDate, Integer dayNum){
            this.accountId = accountId;
            this.accountName = accountName;
            this.eventOrder = eventOrder;
            this.eventName = name;
            this.eventYear = String.valueOf(eventDate.year());
            this.eventMonth = String.valueOf(eventDate.month()-1);
            this.eventDay = String.valueOf(eventDate.day());
            this.eventDayNum = String.valueOf(dayNum);
            this.startDate = eventDate;
            this.originalStartDate = startDate;
        }
        
        public EventJS(Id accountId, String accountName, Integer eventOrder, String name, Date originalStartDate, Date eventDate, Integer dayNum){
            this.accountId = accountId;
            this.accountName = accountName;
            this.eventOrder = eventOrder;
            this.eventName = name;
            this.eventYear = String.valueOf(eventDate.year());
            this.eventMonth = String.valueOf(eventDate.month()-1);
            this.eventDay = String.valueOf(eventDate.day());
            this.eventDayNum = String.valueOf(dayNum);
            this.startDate = eventDate;
            this.originalStartDate = originalStartDate;
        }
        
        public void setNewDate(Date eventDate){
            this.eventYear = String.valueOf(eventDate.year());
            this.eventMonth = String.valueOf(eventDate.month()-1);
            this.eventDay = String.valueOf(eventDate.day());
            this.startDate = eventDate;
        }
        
        public Integer compareTo (Object compareTo){
            EventJS compareToEventDisplay = (EventJS)compareTo;
            if (this.originalStartDate == compareToEventDisplay.originalStartDate) return 0;
            
            if (this.originalStartDate > compareToEventDisplay.originalStartDate) return 1;
            
            if(compareToEventDisplay.originalStartDate==null) return -1;
            
            return -1; 
        }  
    }
    
}