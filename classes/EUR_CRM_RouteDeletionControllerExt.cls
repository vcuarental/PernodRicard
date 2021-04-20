public with sharing class EUR_CRM_RouteDeletionControllerExt {

    private ApexPages.StandardController standardController;
    private final Integer listViewLimit = 1000;
    
    private Date deletionDate{get{
        Date deletionDate;
        if (routeTemplateClass!=null)
            deletionDate = routeTemplateClass.getNextWorkingDate(DateTime.now());
        return deletionDate;
    }}
    
    public EUR_CRM_Route_Template__c routeTemplate {get;set;}
    public EUR_CRM_RouteTemplateClass routeTemplateClass{get;set;}
    
    public String selectedDate{get;set;}
    public Map<Id, Event> events {get;set;}{events = new Map<Id, Event>();}
    
    public List<Event> eventsToDelete {get;set;}
    public List<EUR_CRM_Route_Template_Item__c> routeItems {get;set;}
    public Integer eventsToDeleteSize{get{
        Integer eventsToDeleteSize = 0;
        if(eventsToDelete !=null){
            eventsToDeleteSize = eventsToDelete.size();
        }
        return eventsToDeleteSize;
    }}
    
    public String eventsJS {
        get {
           System.debug('Flag - get Event JS:' + events);
                    JSONGenerator g = JSON.createGenerator(true);
                    g.writeStartArray();
                            for (Id key: events.keySet()) {
                                Event event = events.get(key);
                                g.writeStartObject();
                                g.writeStringField('title', event.Subject);
                                g.writeDateTimeField('start', event.StartDateTime);
                                g.writeDateTimeField('end', event.EndDateTime);
                                g.writeStringField('eventId', event.Id);
                                g.writeStringField('weekNum', String.valueOf(event.EUR_CRM_Week_Number__c));
                                g.writeStringField('routeTemplate', String.valueOf(event.EUR_CRM_Route_Template__c));
                                g.writeEndObject();
                            }
                    g.writeEndArray();
                    return g.getAsString();
            //}else return null;
        }
    }
    
    //public List<EUR_CRM_RouteTemplateClass.EventJS> eventsJSDisplayList{get;set;}{eventsJSDisplayList=new List<EUR_CRM_RouteTemplateClass.EventJS>();}
        
    public EUR_CRM_RouteDeletionControllerExt (ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        
        routeItems = new List<EUR_CRM_Route_Template_Item__c> ();
        
        routeTemplateClass = new EUR_CRM_RouteTemplateClass(this.standardController.getId());
        routeTemplate = routeTemplateClass.routeTemplate;
        
        if (routeTemplateClass!=null){
            initRouteTemplateDetails();
            clearTempCalendar(deletionDate);
        }
                 
    }
    
    public void initRouteTemplateDetails(){
        if(routeTemplateClass!=null){
                routeTemplate = routeTemplateClass.routeTemplate;
                       
                //Get initial list of events
                initEvents();
        }
    }
    
    public void initEvents(){
        if(routeTemplateClass!=null){
                events = routeTemplateClass.retrieveEventsMap(Date.today());
        }
    }
    
    
    public PageReference clearTempCalendar(){
            PageReference pageRef = null;

            System.debug('Start Date:' + selectedDate);
            Date selectedStartDate = Date.parse(selectedDate);
            //Retrieve Events to be deleted
            eventsToDelete = routeTemplateClass.retrieveEvents(selectedStartDate);
            
            System.debug('Flag - Events for deletion Size:' + eventsToDelete.size());
            System.debug('Flag - Events for deletion:' + eventsToDelete);
            
            for(Event ev:eventsToDelete){
                if (events.containsKey(ev.Id)){
                        events.remove(ev.Id);
                }
            }
            
            if(eventsToDelete.size()>0){
                //Retrieve Route Template Items to be updated
                for (EUR_CRM_Route_Template_Item__c rti: [SELECT Id, EUR_CRM_Route_Template__c, EUR_CRM_Last_Scheduled_Visit__c
                                                        FROM EUR_CRM_Route_Template_Item__c WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id]){
                    rti.EUR_CRM_Last_Scheduled_Visit__c = null;
                    routeItems.add(rti);
                }
                System.debug('Flag - Check Route Template Items Query Res:'+ routeItems);
            }
            //Notify numbedr of events to be deleted
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleting '+eventsToDelete.size()+' events from your calendar, from '+selectedStartDate.format()));
                        
            return pageRef;
    }
    
    public void clearTempCalendar(Date selectedStartDate){
            PageReference pageRef = null;
            
            eventsToDelete = routeTemplateClass.retrieveEvents(selectedStartDate);
            
            System.debug('Flag - Events for deletion Size:' + eventsToDelete.size());
            System.debug('Flag - Events for deletion:' + eventsToDelete);
            
            for(Event ev:eventsToDelete){
                if (events.containsKey(ev.Id)){
                        events.remove(ev.Id);
                }
            }
             if(eventsToDelete.size()>0){
                //Retrieve Route Template Items to be updated
                for (EUR_CRM_Route_Template_Item__c rti: [SELECT Id, EUR_CRM_Route_Template__c, EUR_CRM_Last_Scheduled_Visit__c
                                                        FROM EUR_CRM_Route_Template_Item__c WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id]){
                    rti.EUR_CRM_Last_Scheduled_Visit__c = null;
                    routeItems.add(rti);
                }
                System.debug('Flag - Check Route Template Items Query Res:'+ routeItems);
            }

           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleting '+eventsToDelete.size()+' events from your calendar, from '+selectedStartDate.format()));
    }
    
    public PageReference clearCalendar(){ 
        PageReference pageRef = null;
                
                Database.saveResult[] deleteEventResult;
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        //Job Delete
        try{
                if(eventsToDelete.size()>0){
                        //TODO apply batch apex or @future
                        
                        if(eventsToDelete.size()<2000){
                            
                            //Database.executeBatch(new EUR_CRM_BatchDML_Utility(eventsToDelete, 'Event', EUR_CRM_BatchDML_Utility.Operation.DELETE_RECORDS,true, null));
                            
                            Event ev = eventsToDelete.get(0);
                            routeTemplate.EUR_CRM_Reset_Week__c = ev.EUR_CRM_Week_Number__c;
                            Database.delete(eventsToDelete);
                            
                            System.debug('Flag - Route Items for update: ' + routeItems);
                            update routeItems;
                             
                            
                            //Event lastEvent = retrieveLastEvent();
                            //if(lastEvent!=null){
                                   // DateTime evDate = lastEvent.StartDateTime;
                                   // routeTemplate.EUR_CRM_Last_Date_Populated__c = Date.newInstance(evDate.year(), evDate.month(), evDate.day()).addDays(-1);
                            //}else{
                                    routeTemplate.EUR_CRM_Last_Date_Populated__c = retrieveLastPopulatedDate(routeTemplate.Id, UserInfo.getUserId());
                            //}
                            update routeTemplate;
                            
                            //Clear Repopulation Reminder - Task
                            routeTemplateClass.clearReminderTask();
                        
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
                            ApexPages.Severity.INFO, 'There are too many events to be deleted. A batch process has already been submitted to process your request, an email will be sent to you after the batch process finished.'
                          ));
                            //create the postDMLS
                            
                            Event ev = eventsToDelete.get(0);   
                            routeTemplate.EUR_CRM_Last_Date_Populated__c = retrieveLastPopulatedDate(routeTemplate.Id, UserInfo.getUserId());
                            routeTemplate.EUR_CRM_Reset_Week__c = ev.EUR_CRM_Week_Number__c;
                            Database.executeBatch(new EUR_CRM_BatchDML_Utility(eventsToDelete, 'Event', EUR_CRM_BatchDML_Utility.Operation.DELETE_RECORDS,true, createPostDMLs()));
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
        
        return pageRef;
    }
        
    public Event retrieveLastEvent(){
        List<Event> oEvents = new List<Event>();
        
        oEvents = [SELECT Id, AccountId, ActivityDateTime, 
                                        DurationInMinutes, EndDateTime, OwnerId, 
                                        StartDateTime, Subject, Type, WhatId,
                                        EUR_CRM_Route_Template__c, EUR_CRM_Week_Number__c,
                                        CreatedDate 
                                        FROM Event
                                        WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id
                                        ORDER BY  StartDateTime DESC
                                        LIMIT 1];
                                                
                
        return (oEvents.size()>0?oEvents.get(0):null);
    }
    
    public Date retrieveLastPopulatedDate(Id routeTemplateId, Id ownerId){
        Date lastPopulatedDate = null;
        
        /*AggregateResult[] groupedResults = [SELECT Max(StartDateTime)maxStartDateTime FROM Event 
                                            WHERE EUR_CRM_Route_Template__c =: routeTemplateId 
                                            AND OwnerId=: ownerId];
        DateTime lastPopulatedDateTime = (DateTime)groupedResults[0].get('maxStartDateTime');*/
        
        for (AggregateResult ar: [SELECT Max(StartDateTime)maxStartDateTime FROM Event 
                                            WHERE EUR_CRM_Route_Template__c =: routeTemplateId 
                                            AND OwnerId=: ownerId]){
            DateTime lastPopulatedDateTime = (DateTime) ar.get('maxStartDateTime'); 
            if (lastPopulatedDateTime != null){
                lastPopulatedDate = lastPopulatedDateTime.date();   
            }
        }
        return lastPopulatedDate;
    }
    public List<EUR_CRM_BatchDML_Utility.PostDML> createPostDMLs(){

        List<EUR_CRM_BatchDML_Utility.PostDML> postDMLs = new List<EUR_CRM_BatchDML_Utility.PostDML>();
        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        routeTemplateList.add(routeTemplate);
        EUR_CRM_BatchDML_Utility.PostDML routeTemplateListPOSTDML = new EUR_CRM_BatchDML_Utility.PostDML(EUR_CRM_BatchDML_Utility.Operation.UPDATE_RECORDS, (List<sObject>) routeTemplateList);                
        
        
        //clear reminder task
        List<Task> taskList = [SELECT Id  FROM Task WHERE EUR_CRM_Route_Template__c=:routeTemplate.Id LIMIT 1];
        EUR_CRM_BatchDML_Utility.PostDML taskListPOSTDML = new EUR_CRM_BatchDML_Utility.PostDML(EUR_CRM_BatchDML_Utility.Operation.DELETE_RECORDS,  (List<sObject>)taskList );                
        postDMLs.add(taskListPOSTDML);
         EUR_CRM_BatchDML_Utility.PostDML routeItemsListPOSTDML = new EUR_CRM_BatchDML_Utility.PostDML(EUR_CRM_BatchDML_Utility.Operation.UPDATE_RECORDS,  (List<sObject>) routeItems  );                
        postDMLs.add(routeItemsListPOSTDML );
        postDMLs.add(routeTemplateListPOSTDML);
        return postDMLs;
    }
}