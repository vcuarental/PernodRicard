public without sharing class EUR_CRM_RouteTemplateControllerExt{// implements al.ObjectPaginatorListener {

        private ApexPages.StandardController standardController;
        private Date genericStartDate{get;set;}{genericStartDate = Date.newInstance(2013,4,1);}//SET to April 1,2013 - Monday

        public EUR_CRM_Route_Template__c routeTemplate {get;set;}
        public EUR_CRM_RouteTemplateClass routeTemplateClass{get;set;}
        public Boolean isReady {get;set;}{isReady=false;}
        
        //FOR TEST  
        public List<EUR_CRM_RouteTemplateClass.RouteItemWrapper> routeItemsDisplay {get;set;}
        
        public String planningPeriod {get;set;}
        public String visitDuration{get;set;}
        public List<SelectOption> planningPeriodOptions{set;}
        public List<SelectOption> visitDurationOptions{set;}
        
        public String externalEventStartYear{get;set;}
        public String externalEventStartMonth{get;set;}
        public String externalEventStartDay{get;set;}
        public String externalEventStartDate{get;set;}//{externalEventStartDate=Date.today().format();}
        public Date sampleDate{get;set;}
        public String currentDate{get{ return Date.Today().format();}}
                
        public List<EUR_CRM_RouteTemplateClass.RouteItemWrapper> routeItems{get; private set;}
        public Map<Id, EUR_CRM_RouteTemplateClass.RouteItemWrapper> routeItemsMap{get; private set;}

        //Account Event Variables
        public static Map<Id, List<Integer>> currentAccountEvents {get;set;}{currentAccountEvents=new Map<Id, List<Integer>>();}
        public Map<Id, List<Integer>> currentRouteDays {get;set;}{currentRouteDays =new Map<Id, List<Integer>>();}
        
        public Id selectedInProcessAccount{get;set;}
        public String selectedInProcessDays{get;set;}//Comma(,) delimited
        public String selectedInProcessOrder{get;set;}
        public String eventMapFromPage{get; set;}
        
        public Integer eventCount{get{
                Integer eventCount = (routeTemplateClass!=null)?routeTemplateClass.eventCount:0;
            //Check event count
            checkEventCount();
            System.debug('Flag - Event Count: '+ eventCount);
                    
            return eventCount;
        }set;}
        
        private Set<EUR_CRM_Route_Template_Item__c> routeItemsForDeletion {get;set;}{routeItemsForDeletion = new Set<EUR_CRM_Route_Template_Item__c>();}
        private Map<Id, EUR_CRM_RouteTemplateClass.RouteItemWrapper> routeItemWrapMap{get; private set;}{routeItemWrapMap = new Map<Id, EUR_CRM_RouteTemplateClass.RouteItemWrapper>();}
        
        public String eventsJS {get{
                        System.debug('Flag - Check Route Item Map:' + routeItemsMap);
            System.debug('Flag - eventJS, displayMap:' + routeTemplateClass.eventsJSDisplayMap);
            JSONGenerator g = JSON.createGenerator(true);
            Boolean hasWritten = false;
            g.writeStartArray();
            
            if (routeTemplateClass.hasExternalEvents && routeTemplateClass.externalEventsList.size()>0){
                //g.writeStartArray();
                hasWritten = true;
                System.debug('Flag - EventsJS - external events:' +  routeTemplateClass.externalEventsList);
                for (EUR_CRM_RouteTemplateClass.EventJS externalEv: routeTemplateClass.externalEventsList){
                    Integer month = Integer.valueOf(externalEv.eventMonth)+1;
                    g.writeStartObject();
                    g.writeStringField('id', externalEv.accountId + '-' + externalEv.eventOrder);
                    g.writeStringField('title', (externalEv.eventName==null)?externalEv.accountName:externalEv.eventName);
                    g.writeDateField('start', Date.newInstance(Integer.valueOf(externalEv.eventYear), month, Integer.valueOf(externalEv.eventDay)));
                    g.writeBooleanField('allDay', true);
                    g.writeStringField('dayNum', (externalEv.eventDayNum==null)?'0':externalEv.eventDayNum);
                    g.writeStringField('duration', string.valueOf(routeItemsMap.get(externalEv.accountId).visitSpan));
                    g.writeStringField('order', string.valueOf(externalEv.eventOrder));
                    g.writeBooleanField('editable', true);
                    g.writeEndObject();
                }
            }
            if(routeTemplateClass.eventsJSDisplayMap!=null){
                System.debug('Flag - EventsJS - Events Display:' +routeTemplateClass.eventsJSDisplayMap);
                hasWritten = true;
                for (Id key: routeTemplateClass.eventsJSDisplayMap.keySet()) {
                    for(EUR_CRM_RouteTemplateClass.EventJS evJS: routeTemplateClass.eventsJSDisplayMap.get(key)){
                        Integer month = Integer.valueOf(evJS.eventMonth)+1;
                        //System.debug('Flag - TEST JSON:' + evJS.eventYear + '-' + evJS.eventMonth+'-'+ evJS.eventDay + '-' + month);
                        g.writeStartObject();
                        g.writeStringField('id', evJS.accountId + '-' + evJS.eventOrder);
                        g.writeStringField('title', evJS.eventName);
                        g.writeDateField('start', Date.newInstance(Integer.valueOf(evJS.eventYear), month, Integer.valueOf(evJS.eventDay)));
                        g.writeBooleanField('allDay', true);
                        g.writeStringField('dayNum', evJS.eventDayNum);
                        g.writeStringField('duration', string.valueOf(routeItemsMap.get(evJS.accountId).visitSpan));
                        g.writeStringField('order', string.valueOf(evJS.eventOrder));
                        g.writeBooleanField('editable', true);
                        g.writeEndObject();
                    }
                    
                }
            }

            g.writeEndArray();
            System.debug('Flag - get event JS:' + g.getAsString());
            return g.getAsString();
        }}
        
       public String eventsJSON {get;set;}
        
        public String otherEventsJS {get{
            System.debug('Flag - otherEventJS, displayMap:' + routeTemplateClass.eventsJSDisplayMap);
            JSONGenerator g = JSON.createGenerator(true);
            g.writeStartArray();

            if(routeTemplateClass.eventsJSDisplayMap!=null){
                for (Id key: routeTemplateClass.eventsJSDisplayMap.keySet()) {
                        //if (selectedInProcessAccount != key){
                            for(EUR_CRM_RouteTemplateClass.EventJS evJS: routeTemplateClass.eventsJSDisplayMap.get(key)){
                                Integer month = Integer.valueOf(evJS.eventMonth)+1;
                                //System.debug('Flag - TEST JSON:' + evJS.eventYear + '-' + evJS.eventMonth+'-'+ evJS.eventDay + '-' + month);
                                g.writeStartObject();
                                g.writeStringField('id', evJS.accountId + '-' +evJS.eventOrder);
                                g.writeStringField('title', evJS.eventName);
                                g.writeDateField('start', Date.newInstance(Integer.valueOf(evJS.eventYear), month, Integer.valueOf(evJS.eventDay)));
                                g.writeBooleanField('allDay', true);
                                g.writeStringField('dayNum', evJS.eventDayNum);
                                g.writeStringField('duration', string.valueOf(routeItemsMap.get(evJS.accountId).visitSpan));
                                g.writeStringField('order', string.valueOf(evJS.eventOrder));
                                g.writeBooleanField('editable', false);
                                g.writeEndObject();
                            }
                        //}
                }
            }
            g.writeEndArray();
            System.debug('Flag - get other event JS:' + g.getAsString());
            return g.getAsString();    
                }
        }

        public EUR_CRM_RouteTemplateControllerExt (ApexPages.StandardController standardController)
        {
                this.standardController = standardController;
                
            routeTemplateClass = new EUR_CRM_RouteTemplateClass(this.standardController.getId(), genericStartDate);
            routeTemplate = routeTemplateClass.routeTemplate;

            //Initiate Account List
            routeItemsMap = new Map<Id, EUR_CRM_RouteTemplateClass.RouteItemWrapper>();
            currentAccountEvents = new Map <Id, List<Integer>>();
                
            //Set Planning Period and Visit Duration values
            planningPeriod= String.valueOf(routeTemplate.EUR_CRM_Planning_Period__c);
            visitDuration = String.valueOf(routeTemplate.EUR_CRM_Visit_Duration__c);
        }     
        
        public List<SelectOption> getPlanningPeriodOptions(){
                 List<SelectOption> planningPeriodOptions = new List<SelectOption>();

                 for (Integer i=1; i<=routeTemplate.EUR_CRM_Max_Planning_Period_Week__c; i++){
                         planningPeriodOptions.add(new Selectoption(String.valueOf(i),String.valueOf(i)));
                 }
                 return planningPeriodOptions;
        }
        
        public List<SelectOption> getVisitDurationOptions(){
                List<SelectOption> visitDurationOptions = new List<SelectOption>();
                
                for (Double i=0.50; i<=routeTemplate.EUR_CRM_Max_Visit_Duration_Hour__c; i+=0.50){
                        visitDurationOptions.add(new Selectoption(String.valueOf(i),String.valueOf(i)));
                }
                return visitDurationOptions;
        }
        
        
        public void retrieveRouteTemplateItems(){
            Integer initialRouteItemsCount = 0;
            System.debug('Retrieve Template Items');
            routeItems = routeTemplateClass.initRouteItems(true, genericStartDate, true);         
            routeItemsMap = routeTemplateClass.routeItemsMap;
            initialRouteItemsCount = routeItemsMap.size();

            System.debug('Flag - Event JS Display Map:' + routeItemsMap);
            System.debug('Flag - Event JS Display Map Test:' + eventsJS);
            isReady = true;
        }
        
        /*
        private String createEventJSON(Map<Id, EUR_CRM_RouteTemplateClass.RouteItemWrapper> items){
            JSONGenerator evJSON = JSON.createGenerator(true);
            //evJSON.writeStartArray();
            evJSON.writeStartObject();
            for (Id key: items.keySet()){//EUR_CRM_RouteTemplateClass.RouteItemWrapper itemWrap : items.values()){
                EUR_CRM_RouteTemplateClass.RouteItemWrapper itemWrap = items.get(key);
                if ((key != null || String.valueOf(key).length()>0)){
                    System.debug('Flag - Events JSON - Check Route Item Wrapper:'+key+' - '+itemWrap);
                    //evJSON.writeStartObject();
                    evJSON.writeFieldName(String.valueOf(key));
                    evJSON.writeStartObject();
                    //Set Account details
                    evJSON.writeStringField('accountId', String.valueOf(itemWrap.accountId));
                    evJSON.writeStringField('accountName', itemWrap.accountName);
                    evJSON.writeStringField('accountStreet', (itemWrap.accountStreet==null)?'':itemWrap.accountStreet);
                    evJSON.writeStringField('visitFrequencyName', (itemWrap.visitFrequencyName==null)?'':itemWrap.visitFrequencyName);
                    evJSON.writeNumberField('visitFrequency', (itemWrap.visitFrequency==null)?0:itemWrap.visitFrequency);
                    evJSON.writeNumberField('visitSpan', (itemWrap.visitSpan==null)?0:itemWrap.visitSpan);
                    //evJSON.writeObjectField('routeTemplateItem', itemWrap.routeTemplateItem);
                    evJSON.writeObjectField('routeDays', (itemWrap.routeDays.size()<=0)?new List<EUR_CRM_Route_Template_Day__c>():itemWrap.routeDays);
                    evJSON.writeObjectField('routeDaysInt', (itemWrap.routeDaysInt.size()<=0)?new List<Integer>():itemWrap.routeDaysInt);
                    evJSON.writeEndObject();
                    //evJSON.writeEndObject();
                }
            }
            evJSON.writeEndObject();
            //evJSON.writeEndArray();
            System.debug('Flag - Events JSON:' + evJSON.getAsString());
            return evJSON.getAsString();

        }
        */
        
        public void addRouteItems(){}
        
        public void deleteRouteItems(){
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            System.debug('Flag - Delete Route Item:'+ accountId);
            if(routeItemsMap.containsKey(accountId)){
                //Get current account Id
                System.debug('Flag - Delete Route Item - FOUND:'+ accountId);
                if(routeItemsMap.get(accountId).routeTemplateItem!=null && routeItemsMap.get(accountId).routeTemplateItem.Id!=null){
                    //Add to list of route items for deletion
                    List<EUR_CRM_Route_Template_Day__c> routeDaysList = routeItemsMap.get(accountId).routeDays;
                    routeItemsForDeletion.add(routeItemsMap.get(accountId).routeTemplateItem);
                }
                //Remove days
                routeItemsMap.get(accountId).isEventSet = false;
                routeItemsMap.get(accountId).routeDays = new List<EUR_CRM_Route_Template_Day__c>();
                    
                populateEventsDisplay();
            }
            System.debug('Flag - Delete Route Items: '+routeItemsMap+' - '+ routeItemsMap.containsKey(accountId));
        }
        
        public PageReference updateExternalEventList(){
            Date eeStartDate;
            System.debug('Flag - UpdateExternal Event- Check ARGS:'+externalEventStartYear+'-'+externalEventStartMonth+'-'+externalEventStartDay);
            eeStartDate = Date.newInstance(Integer.valueOf(externalEventStartYear), 
                                                                    Integer.valueOf(externalEventStartMonth)+1, Integer.valueOf(externalEventStartDay));
            //externalEventStartDate
            System.debug('Flag - Update External. Events - Check Date:' + eeStartDate);
            routeTemplateClass.getSelectedExternalEvents(eeStartDate);
            
            return null;
        }
        
        public PageReference saveTemplate(){
            PageReference pageRef = null;
            
            Database.deleteResult[] deleteResultRouteItems;
            Database.upsertResult[] upsertResultRouteItems;
            Database.upsertResult[] upsertResultRouteDays;
            System.Savepoint pSavepoint = Database.setSavepoint();
            Boolean isSaved = true;
    
            List<EUR_CRM_Route_Template_Item__c> updatedRouteItems = new List<EUR_CRM_Route_Template_Item__c>();
            List<EUR_CRM_Route_Template_Day__c> updatedRouteDays = new List<EUR_CRM_Route_Template_Day__c>();
            
            System.debug('Flag - Save Template - Check Route Items:' + routeItemsMap);
            System.debug('Flag - Save Template - Check Route Items 2:' + routeItemWrapMap);
            
            try{
                //Reprocess Route Items Map - To Check content
                System.debug('Flag - Save Template - Event Map:' + eventMapFromPage);
                if (eventMapFromPage != null){
                    //reprocessRouteDays(eventMapFromPage);
                }
                //Delete Route Items
                if (routeItemsForDeletion.size()>0){
                    List<Id> rtiDeletionList = new List<Id>();
                    for (EUR_CRM_Route_Template_Item__c item : routeItemsForDeletion){
                            if (item.Id != null && ((routeItemsMap.containsKey(item.EUR_CRM_Account__c)) && (routeItemsMap.get(item.EUR_CRM_Account__c).routeDays.size()<=0))){
                                    rtiDeletionList.add(item.Id);
                            }
                    }
                    deleteResultRouteItems = Database.delete(rtiDeletionList);
                }
                //Update Route Items
                System.debug('Flag - Save Template - Check route items:' + routeItemsMap.values());
                for (EUR_CRM_RouteTemplateClass.RouteItemWrapper routeItem: routeItemsMap.values()){//routeItemsMap.values()){
                        System.debug('Flag - Save Template - Check Route Days:'+routeItem.routeDays.size());
                    if (routeItem.routeDays.size()>0){
                        //updatedRouteDays.addAll(routeItem.routeDays);
                        routeItem.routeTemplateItem.EUR_CRM_Previous_Visit_Frequency__c = routeItem.visitFrequency;
                        routeItem.routeTemplateItem.EUR_CRM_Previous_Visit_Span__c = routeItem.visitSpan;
                        System.debug('Flag - Save Template - Check Previous Visit Freq and Span:' + routeItem.routeTemplateItem.EUR_CRM_Previous_Visit_Frequency__c + '-' + routeItem.routeTemplateItem.EUR_CRM_Previous_Visit_Span__c);
                        updatedRouteItems.add(routeItem.routeTemplateItem);
                    }
                }
                
                //Process DB Transactions
                //Upsert Route Items
                if(updatedRouteItems.size()>0){
                    System.debug('Flag - Save Template - DB Save Route Items: ' +updatedRouteItems);
                    upsertResultRouteItems = Database.upsert(updatedRouteItems, EUR_CRM_Route_Template_Item__c.Id);
                    System.debug('Flag - Save Template - Upsert Route Items Result:' + upsertResultRouteItems);
                }
                
                for(EUR_CRM_Route_Template_Item__c routeItem: updatedRouteItems){
                    List<EUR_CRM_Route_Template_Day__c> routeDaysList = routeItemsMap.get(routeItem.EUR_CRM_Account__c).routeDays;
                    for (EUR_CRM_Route_Template_Day__c routeDay: routeDaysList){
                            if (routeDay.EUR_CRM_Route_Template_Item__c == null)
                                routeDay.EUR_CRM_Route_Template_Item__c = routeItem.Id;
                            updatedRouteDays.add(routeDay);
                    }
                }
                //Upsert Route Days
                if(updatedRouteDays.size()>0){
                    System.debug('Flag - Save Template - DB Save Route Days: ' +updatedRouteDays);
                    upsertResultRouteDays = Database.upsert(updatedRouteDays);
                    System.debug('Flag - Save Template - Upsert Route Items Result:' + upsertResultRouteDays);
                }
                
                //Update Route Template
                routeTemplate.EUR_CRM_Active__c = true;
                update routeTemplate;
                                //Set Page Reference
                pageRef = new PageReference('/'+routeTemplate.Id);
                pageRef.setRedirect(true); 
            }
            catch(Exception e){
                System.debug('Upsert Error: ' + e);
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
            
            return null;
        }

        public void saveRouteDay(String accountId, Integer rowNum, Integer day)
        {
                if (rowNum == 0){
                        currentRouteDays = new Map<Id, List<Integer>>();
                }
                if(currentRouteDays.containsKey(accountId)){
                        List<Integer> daysList = currentRouteDays.get(accountId);
                        
                        if(rowNum!=0 && (daysList.size()-1)<=rowNum){
                                daysList[rowNum] = day;
                        }else{
                                daysList.add(day);
                        }
                        currentRouteDays.put(accountId, daysList);
                }
        }
        
        /************************
        Extends the apex class call to make sure that eventJS is updated.
        *************************/
        public void extendActions(){
            system.debug('Extended: ' + selectedInProcessAccount + ' - ' + selectedInProcessOrder + ' - ' + selectedInProcessDays);
        }
        
        public void saveRouteDays(){
                System.debug('***evensJS: ' + routeTemplateClass.eventsJSDisplayMap);
                //PageReference pageRef = null;
                Map<String, List<String>> toProcessRouteMap = new Map<String,List<String>>();
                //Get Param
                //Map<String, String> params = ApexPages.currentPage().getParameters();
                //String paramEventMap = params.get('PARAM_EVENT_MAP');
                
                //Process selected account
                System.debug('On Save Route Days - Selected Account' + selectedInProcessAccount + '-'+selectedInProcessDays);
                System.debug('On Save Route Days - Event Map' +eventMapFromPage);
                //toProcessRouteMap.put(selectedInProcessAccount, selectedInProcessDays.split(','));
                saveAccountEvents(selectedInProcessAccount, selectedInProcessDays.split(','));
                
                if (eventMapFromPage != null){
                    //reprocessRouteDays(eventMapFromPage);
                }
                /*
                //iterate eventMap
                if (eventMapFromPage != null){
                        //Convert JSON String
                        //JSONParser parser = JSON.createParser(paramEventMap);
                        Map<String, Object> deserializedEventMap = new Map<String, Object>();
                        deserializedEventMap = (Map<String, Object>)JSON.deserializeUntyped(eventMapFromPage);
                        System.debug('Flag - Save Route Days - Deserialized Event Map:' + deserializedEventMap);
                        
                        for (String key: deserializedEventMap.keySet()){
                                if (deserializedEventMap.get(key)!= null && routeItemsMap.containsKey(key) && routeItemsMap.get(key).routeDays.size()==0){
                                        String daysStr = String.valueOf(deserializedEventMap.get(key)).replace('(', '').replace(')', '');
                                        List<String> days = daysStr.split(',');
                                        System.debug('Flag - Save Route Days - Check Days:' +daysStr+'-'+days);
                                        toProcessRouteMap.put(key, days);
                                }
                        }
                        
                }
                System.debug('Flag - Save Route Days - To Process:' + toProcessRouteMap);
                for (String key: toProcessRouteMap.keySet()){
                        saveAccountEvents(key, toProcessRouteMap.get(key));
                }*/
                System.debug('Flag - On Save Route Days - Done: '+routeItemsMap);
                //saveRouteDay2();
                //return pageRef;
        }
        
        /*

            This is commented because it is not used. - 4-1-15 IPC
        */
        /*    
        private void saveRouteDay2(){
            saveAccountEvents(selectedInProcessAccount, selectedInProcessDays.split(','));
        }
        */
        /*

            This is commented because it is not used. - 4-1-15 IPC
        */
        /*    
        private void reprocessRouteDays(String eventMapFromPage){
                Map<String, List<String>> toProcessRouteMap = new Map<String,List<String>>();
                if (eventMapFromPage != null){
                        //Convert JSON String
                        //JSONParser parser = JSON.createParser(paramEventMap);
                        Map<String, Object> deserializedEventMap = new Map<String, Object>();
                        deserializedEventMap = (Map<String, Object>)JSON.deserializeUntyped(eventMapFromPage);
                        System.debug('Flag - Reprocess Route Days - Deserialized Event Map:' + deserializedEventMap);
                        
                        for (String key: deserializedEventMap.keySet()){
                                System.debug('CHECK - Reprocess Route Days:' + routeItemsMap.get(key).routeDaysInt + deserializedEventMap.get(key) + (routeItemsMap.get(key).routeDaysInt==deserializedEventMap.get(key)));
                                if (deserializedEventMap.get(key)!= null && routeItemsMap.containsKey(key)&&
                                        (routeItemsMap.get(key).routeDaysInt!=deserializedEventMap.get(key))){ //&& routeItemsMap.get(key).routeDays.size()==0){
                                        String daysStr = String.valueOf(deserializedEventMap.get(key)).replace('(', '').replace(')', '');
                                        List<String> days = daysStr.split(',');
                                        System.debug('Flag - Reprocess Route Days - Check Days:' +daysStr+'-'+days);
                                        toProcessRouteMap.put(key, days);
                                }
                        }
                
                }
                System.debug('Flag - Reprocess Route Days - To Process:' + toProcessRouteMap);
                for (String key: toProcessRouteMap.keySet()){
                        saveAccountEvents(key, toProcessRouteMap.get(key));
                }
        }
        */
        
        private void saveAccountEvents(String key, List<String> days){
            System.debug('Flag - On Save Route Days - '+ key + '-' + routeItemsMap.containsKey(key));
                        //System.debug('Flag - On Save Route Days - Check Starting Map:' + routeItemsMap);
            if(routeItemsMap.containsKey(key)){
                    EUR_CRM_RouteTemplateClass.RouteItemWrapper routeItem = routeItemsMap.get(key);
                    EUR_CRM_RouteTemplateClass.RouteItemWrapper routeItemWrap = (routeItemWrapMap.containsKey(key))?routeItemWrapMap.get(key):routeItem; //FOR TESTING
                    
                    List<String> daysList = days;//selectedInProcessDays.split(',');
                    //Add to eventCount
                    System.debug('Flag - Save Route Days -'+key+':' + days + '- days: ' + daysList);
                    //Init Route days
                    List<EUR_CRM_Route_Template_Day__c> rDays = (routeItem.routeDays != null && routeItem.routeDays.size()>0)?routeItem.routeDays:(new List<EUR_CRM_Route_Template_Day__c>());
                    routeItem.routeDaysInt = new List<Integer>();
                    System.debug('Flag - Route Days - '+routeItem.routeTemplateItem+':' + routeItem.routeDays);
                    System.debug('Flag - Route Days - rDays:' + rDays);
                    for(Integer i=0; i<daysList.size();i++){
                        Integer day = Integer.valueOf(daysList[i]);
                        EUR_CRM_Route_Template_Day__c dayRecord = null;
                        if(rDays.size()>0 && i<rDays.size()){
                            dayRecord = routeItem.routeDays.get(i);
                            dayRecord.EUR_CRM_Day__c = day;
                            System.debug('Flag - Save Route Days - Update existing');
                        }else{
                            dayRecord = routeTemplateClass.createRouteTemplateDay(routeItem.routeTemplateItem, day);
                            routeItem.routeDays.add(dayRecord);
                            System.debug('Flag - Save Route Days - Add new:' + routeItem.routeTemplateItem);
                        }
                        routeItem.routeDaysInt.add(day);
                    }
                    
                    //Add Event JS to display map                   
                    if (routeItem.routeDays.size()>0){
                        System.debug('Flag - Save Route Days - Check Route Item:' + routeItem);
                        addEventJS(routeItem, routeItem.routeDays, genericStartDate);
                    }
                    routeItem.isEventSet = true;
                    routeItemsMap.put(key, routeItem);
                    routeItemWrapMap.put(key, routeItem);
                    System.debug('Flag - Save Route Days Result:' + routeItemsMap.get(key));
                    System.debug('Flag - Save Route Days Result 2 :' + routeItemWrapMap.get(key));
                    
                    //Check event count
                    checkEventCount();
                    System.debug('Flag - Save Route Days Result:' + routeItem);
            }
        }
        
        /*****************************************
        Saves the account events on main screen (drag & drop event).
        *****************************************/
        public PageReference saveRouteDayEvents(){
            System.debug('***evensJS: ' + routeTemplateClass.eventsJSDisplayMap);
            PageReference pageRef = null;
            Map<String, List<String>> toProcessRouteMap = new Map<String,List<String>>();
            
            //Get Param
            //Process selected account
            System.debug('On Save Route Days - Selected Account' + selectedInProcessAccount + '-'+selectedInProcessDays+'-'+selectedInProcessOrder);
            System.debug('On Save Route Days - Event Map' +eventMapFromPage);
            saveAccountDropEvents(selectedInProcessAccount, selectedInProcessOrder, selectedInProcessDays);
            
            if (eventMapFromPage != null){
                //reprocessRouteDays(eventMapFromPage);
            }
            System.debug('Flag - On Save Route Days - Done - Event Drop: '+routeItemsMap);
            saveRouteDayEvent2();
            return pageRef;
        }
        
        private void saveRouteDayEvent2(){
            saveAccountDropEvents(selectedInProcessAccount, selectedInProcessOrder, selectedInProcessDays);
        }
        
        private void saveAccountDropEvents(String key, String orderStr, String dayStr){
            System.debug('Flag - On Save Route Days - '+ key + '-' + routeItemsMap.containsKey(key) + ' - ' + orderStr + ' - ' + dayStr);
            
            if(routeItemsMap.containsKey(key)){
                    EUR_CRM_RouteTemplateClass.RouteItemWrapper routeItem = routeItemsMap.get(key);
                    EUR_CRM_RouteTemplateClass.RouteItemWrapper routeItemWrap = (routeItemWrapMap.containsKey(key))?routeItemWrapMap.get(key):routeItem; //FOR TESTING
                    
                    //String daysList = days;
                    Integer day = Integer.valueOf(dayStr);
                    Integer order = Integer.valueOf(orderStr);
                    
                    //Add to eventCount
                    //Init Route days
                    EUR_CRM_Route_Template_Day__c rDays = (routeItem.routeDays != null && routeItem.routeDays.size()>0)?routeItem.routeDays.get(order):(new EUR_CRM_Route_Template_Day__c());
                    routeItem.routeDaysInt = new List<Integer>();
                    System.debug('Flag - Route Days - '+routeItem.routeTemplateItem+':' + routeItem.routeDays);
                    System.debug('Flag - Route Days - rDays:' + rDays);
                    
                    EUR_CRM_Route_Template_Day__c dayRecord = null;
                    if(rDays != null){
                        dayRecord = routeItem.routeDays.get(order);
                        dayRecord.EUR_CRM_Day__c = day;
                        System.debug('Flag - Save Route Days - Update existing');
                    }else{
                        dayRecord = routeTemplateClass.createRouteTemplateDay(routeItem.routeTemplateItem, day);
                        routeItem.routeDays.add(dayRecord);
                        System.debug('Flag - Save Route Days - Add new:' + routeItem.routeTemplateItem);
                    }
                    routeItem.routeDaysInt.add(day);
                    
                    //Add Event JS to display map                   
                    if (routeItem.routeDays.size()>0){
                        System.debug('Flag - Save Route Days - Check Route Item:' + routeItem);
                        addEventJS(routeItem, routeItem.routeDays, genericStartDate);
                    }
                    routeItem.isEventSet = true;
                    routeItemsMap.put(key, routeItem);
                    routeItemWrapMap.put(key, routeItem);
                    System.debug('Flag - Save Route Days Result:' + routeItemsMap.get(key));
                    //System.debug('Flag - Save Route Days Result 2 :' + routeItemWrapMap.get(key));
                    
                    //Check event count
                    //checkEventCount();
                    System.debug('Flag - Save Route Days Result:' + routeItem);
            }
        }
        
        public PageReference populateEventsDisplay(){
            PageReference pageRef = null;
            
            //planningPeriod= String.valueOf(routeTemplate.EUR_CRM_Planning_Period__c);
            routeTemplateClass.populateRTIEventDisplay(genericStartDate);
            return pageRef;
        }
        
        private void addEventJS(EUR_CRM_RouteTemplateClass.RouteItemWrapper routeItemWrap, 
                List<EUR_CRM_Route_Template_Day__c> rDays, Date startDate){
                  
                        List<EUR_CRM_RouteTemplateClass.EventJS> eventJSList = routeTemplateClass.addEventJSToMap(Integer.valueOf(routeTemplate.EUR_CRM_Planning_Period__c), 
                                                                                routeItemWrap, rDays, startDate);
        }
        /*
        private void deleteEventJS(Id accountId){
                eventsJSDisplayMap.remove(accountId);
        }
        */
        private void checkEventCount(){
                if(routeTemplateClass.eventsJSDisplayMap.size() >= routeTemplateClass.maxTemplateEventCount){
                        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Event count exceeded ' + 
                                                                routeTemplateClass.maxTemplateEventCount+ ', population might be limited to once cycle only'));
                }
        }
  
}