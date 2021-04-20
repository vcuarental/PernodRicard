/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_RouteScheduleControllerExt Class.
  @Author:      IPC
  @History:     APR.29.2014 - Created
*/
@isTest (SeeAllData=false)
private class EUR_CRM_TestRouteScheduleControllerExt{
    private static User user;
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Route_Template__c routeTemplate;
    private static List<EUR_CRM_Route_Template_Item__c> routeTempItem;
    private static EUR_CRM_Route_Template_Item__c routeTempItem2;
    private static EUR_CRM_Visit_Frequency__c visitFrequency;
    private static EUR_CRM_Route_Template_Day__c routeTempDay;
    private static list<EUR_CRM_Route_Template_Day__c> routeTempDay2;
    private static Event events;
    
    public static void dataInsert1(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
        	user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
        	insert user;
        }
        
        System.runAs(user){
        
            visitFrequency = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1, 'CZ Visit Frequency')[0];
            visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c = 3;
            visitFrequency.EUR_CRM_Frequency_Span_Days__c = 2;
            visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c  = 3;
            visitFrequency.EUR_CRM_Channel__c = 'ON TRADE';
            visitFrequency.EUR_CRM_Sub_Channel__c = 'ON_STD';
            insert visitFrequency;
            
            accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
            accountEU.EUR_CRM_Status__c = 'Active';
            accountEU.EUR_JB_Approved_Status__c = 'Active';
            accountEU.EUR_CRM_Channel__c = 'ON TRADE';
            accountEU.EUR_CRM_Sub_Channel__c = 'Retail';
            accountEU.EUR_CRM_Visit_Frequency_Filtered__c = visitFrequency.Id;
            insert accountEU;
            
            routeTemplate = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'JB Route Template', '')[0];
            routeTemplate.EUR_CRM_Scheduled__c = true;
            routeTemplate.EUR_CRM_Reset_Week__c = 5;
            routeTemplate.EUR_CRM_Reminder_Day__c = 6;
            routeTemplate.EUR_CRM_Planning_Period__c = 1;
            insert routeTemplate;
            
            routeTempItem2 = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
            routeTempItem2.EUR_CRM_Account__c = accountEU.Id;
            insert routeTempItem2;
            
            routeTempDay = EUR_CRM_TestClassUtilityHelper.createRouteTempDay(1, routeTempItem2.Id)[0];
            routeTempDay.EUR_CRM_Day__c = 2;
            routeTempDay.EUR_CRM_Week_Day__c = '3';
            insert routeTempDay;
            
            events = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR EE Visitation Event', routeTemplate.Id, user.Id, DateTime.now(), DateTime.now().addDays(9))[0];
            insert events;
        }
    }
    
    public static void dataInsert2(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
            insert user;
        }
        
        System.runAs(user){
        
            visitFrequency = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1, 'CZ Visit Frequency')[0];
            visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c = 3;
            visitFrequency.EUR_CRM_Frequency_Span_Days__c = 2;
            visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c  = 3;
            visitFrequency.EUR_CRM_Channel__c = 'ON TRADE';
            visitFrequency.EUR_CRM_Sub_Channel__c = 'ON_STD';
            insert visitFrequency;
            
            accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
            accountEU.EUR_CRM_Status__c = 'Active';
            accountEU.EUR_JB_Approved_Status__c = 'Active';
            accountEU.EUR_CRM_Channel__c = 'ON TRADE';
            accountEU.EUR_CRM_Sub_Channel__c = 'Retail';
            accountEU.EUR_CRM_Visit_Frequency_Filtered__c = visitFrequency.Id;
            insert accountEU;
            
            routeTemplate = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'JB Route Template', '')[0];
            routeTemplate.EUR_CRM_Scheduled__c = false;
            routeTemplate.EUR_CRM_Reset_Week__c = 5;
            routeTemplate.EUR_CRM_Reminder_Day__c = 6;
            routeTemplate.EUR_CRM_Planning_Period__c = 3;
            insert routeTemplate;
            
            routeTempItem2 = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
            routeTempItem2.EUR_CRM_Account__c = accountEU.Id;
            insert routeTempItem2;
            
            routeTempDay2 = EUR_CRM_TestClassUtilityHelper.createRouteTempDay(2, routeTempItem2.Id);
            insert routeTempDay2;
            
            events = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR EE Visitation Event', routeTemplate.Id, user.Id, DateTime.now(), DateTime.now().addDays(9))[0];
            insert events;
        }
    }
    
    static testMethod void routeTemplate1() {
        dataInsert1();
        
        test.startTest();
        System.runAs(user){
            List<Event> evList = new List<Event>();
            evList = new List<Event>();
            evList.add(events);
            
            System.Debug('@@Events Size:'+evList.size());
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(routeTemplate);
            
            EUR_CRM_RouteScheduleControllerExt controller = new EUR_CRM_RouteScheduleControllerExt(standardController);
            EUR_CRM_RouteTemplateClass routeTempClass = new EUR_CRM_RouteTemplateClass(routeTemplate.Id);
            routeTempClass.eventCountEstimate = 15;
            
            Date dToday = System.today();
               
            controller.selectedDate = '05/05/2016'; 
            controller.startDate = System.today();
            controller.events = evList;
            
            controller.populateTempCalendar();
            controller.repopulateTempCalendar();
            controller.populateCalendar();
            
            //Test1.2
            routeTemplate.EUR_CRM_Scheduled__c = false;
            routeTemplate.EUR_CRM_Reset_Week__c = null;
            update routeTemplate;
            
            standardController = new Apexpages.Standardcontroller(routeTemplate);
            controller = new EUR_CRM_RouteScheduleControllerExt(standardController);
            
            controller.selectedDate = '05/05/2016';
            controller.startDate = System.today();
            controller.events = evList;
            
            controller.repopulateTempCalendar();
            controller.populateTempCalendar();
            
            controller.onLoadPrep();
            controller.createPostDMLs();
            String JsStr = controller.eventsJS;
            //PageReference pr = controller.onLoadPre();
            //List<EUR_CRM_BatchDML_Utility.PostDML> dmls = controller.createPostDMLs();
        }
        test.stopTest();
    }
    
    static testMethod void routeTemplate2() {
        dataInsert2();
        
        test.startTest();
        System.runAs(user){
            List<Event> evList = new List<Event>();
            evList = new List<Event>();
            evList.add(events);
            
            List<EUR_CRM_Route_Template_Day__c> tempD = new List<EUR_CRM_Route_Template_Day__c>();
            for(EUR_CRM_Route_Template_Day__c td :routeTempDay2){
                td.EUR_CRM_Day__c = 1;
                tempD.add(td);
            }
            update tempD;
            
            JSONGenerator g = JSON.createGenerator(true);
            g.writeStartArray();
            for (Event event: evList) {
                g.writeStartObject();
                g.writeStringField('title', 'test subject');
                g.writeDateTimeField('start', DateTime.now());//event.StartDateTime);
                g.writeDateTimeField('end', DateTime.now().addDays(9));//event.EndDateTime);
                g.writeStringField('weekNum', '2');
                g.writeStringField('routeTemplate', String.valueOf(routeTemplate.Id));
                g.writeEndObject();
            }
            g.writeEndArray();
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(routeTemplate);
            
            EUR_CRM_RouteScheduleControllerExt controller = new EUR_CRM_RouteScheduleControllerExt(standardController);
            EUR_CRM_RouteTemplateClass routeTempClass = new EUR_CRM_RouteTemplateClass(routeTemplate.Id);
            routeTempClass.eventCountEstimate = 15;
            
            Date dToday = System.today();
            String eventJS = g.getAsString();
            
            controller.numCycle = 2;
            controller.selectedDate = '05/05/2016';
            controller.startDate = System.today();
            controller.events = evList;
            
            controller.populateTempCalendar();
            controller.populateCalendar();
            controller.repopulateTempCalendar(); 
            List<Event> events2 = new List<Event>();
            for(Integer i = 0 ; i < 2002 ; i ++){
                Event e = new Event(Subject= '123', ActivityDateTime=Datetime.now());
                events2.add(e);
            }
            controller.events = events2;
            controller.populateCalendar();
            //String JsStr = controller.eventsJS();
            //PageReference pr = controller.onLoadPre();
            //List<EUR_CRM_BatchDML_Utility.PostDML> dmls = controller.createPostDMLs();
        }
        test.stopTest();
    }
    
    static  void routeTemplate3() { 
        // user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
       // insert user;
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        System.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            //EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            Id rtid = [select id from recordtype where developername = 'EUR_DE_Route_Template' and sobjecttype ='EUR_CRM_Route_Template__c'][0].id;
            Id rtid2 = [select id from recordtype where developername = 'EUR_DE_Visit_Frequency' and sobjecttype= 'EUR_CRM_Visit_Frequency__c'][0].id;
            EUR_CRM_Visit_Frequency__c visitFreq= new EUR_CRM_Visit_Frequency__c(name='test', EUR_CRM_Frequency_Span_Days__c = 14, EUR_CRM_No_of_Visits_Within_Interval__c  = 1 );
            insert visitFreq;
            
            /*
            EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1.EUR_CRM_Visit_Frequency__c = visitFreq.id;
            EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1.eur_crm_status_of_customer__c = 'Active';
            EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1.ownerid = EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager.id;
            update EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1;
            */
            EUR_CRM_DE_TestClassUtilityHelper.initData();
            EUR_CRM_Account__c euAccount= EUR_CRM_DE_TestClassUtilityHelper.euAccount;
            
            euAccount.EUR_CRM_Visit_Frequency__c = visitFreq.id;
            euAccount.eur_crm_status_of_customer__c = 'Active';
            update euAccount;
            
            EUR_CRM_Route_Template__c routeTemplate2 = new EUR_CRM_Route_Template__c(recordtypeid=rtid, 
            EUR_CRM_Max_Planning_Period_Week__c = 52, EUR_CRM_Planning_Period__c = 4, EUR_CRM_Reminder_Day__c =5 );
            insert routeTemplate2; 
            routeTemplate2 = [select id,EUR_CRM_Max_Planning_Period_Week__c ,  EUR_CRM_Planning_Period__c , EUR_CRM_Reminder_Day__c , 
            EUR_CRM_Country_Code__c from EUR_CRM_Route_Template__c where id=:routeTemplate2.id];
            EUR_CRM_Route_Template_Item__c routeTemplateItem = new EUR_CRM_Route_Template_Item__c(EUR_CRM_Account__c = euAccount.id,
            EUR_CRM_Route_Template__c = routeTemplate2.id, EUR_CRM_Subject__c = 'test');
            insert routeTemplateItem ;
            
            EUR_CRM_Route_Template_Day__c rday = new EUR_CRM_Route_Template_Day__c(EUR_CRM_Route_Template_Item__c = routeTemplateItem.id, EUR_CRM_Day__c =5);
           insert rday;    
            test.startTest();            
               
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(routeTemplate2);
             EUR_CRM_RouteScheduleControllerExt controller = new EUR_CRM_RouteScheduleControllerExt(standardController);
             controller.populateCalendar(); 
             //controller.populateTempCalendar();
             controller.createPostDMLs();
             String s = controller.eventsJS;
             
             controller.numCycle = 2;
            controller.selectedDate = '05/05/2014';
            controller.startDate = System.today(); 
            
            controller.populateTempCalendar();
            //String JsStr = controller.eventsJS;
            //PageReference pr = controller.onLoadPre();
            //List<EUR_CRM_BatchDML_Utility.PostDML> dmls = controller.createPostDMLs();
           test.StopTest();
        }
    }
}