/*
@Company:     IP-Converge Data Services, Inc.
@Description: Test Class for EUR_CRM_RouteTemplateClass Class.
@Author:      IPC
@History:     MAY.2.2014 - Created
*/
@isTest 
private class EUR_CRM_TestRouteTemplateClass{
    private static User user;
    private static Account account;
    private static EUR_CRM_Account__c accountEUS;
    private static List<EUR_CRM_Account__c> accountEU;
    private static EUR_CRM_Route_Template__c routeTemplate;
    private static EUR_CRM_Route_Template__c routeTemplate2;
    private static EUR_CRM_Route_Template_Item__c routeTempItem;
    private static EUR_CRM_Route_Template_Day__c routeTempDay;
    private static EUR_CRM_Visit_Frequency__c visitFrequency;
    private static Event events;
    private static Event events2;
    private static Event events3;
    private static Datetime dt;
    
    public static void dataInsert1(){
        
        Date dte = date.valueOf(DateTime.now().addDays(7));
        dte = dte.toStartOfWeek().addDays(3);
        dt = dateTime.newInstance(dte.year(), dte.month(),dte.day());
        
        visitFrequency = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1, 'CZ Visit Frequency')[0];
        visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c = 3;
        visitFrequency.EUR_CRM_Frequency_Span_Days__c = 2;
        visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c  = 3;
        visitFrequency.EUR_CRM_Channel__c = 'ON TRADE';
        visitFrequency.EUR_CRM_Sub_Channel__c = 'ON_STD';
        insert visitFrequency;
        
        account = EUR_CRM_TestClassUtilityHelper.createAccounts(1, 'Off Trade')[0];
        account.Name = 'null';
        insert account;
        
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(2, 'LT Direct - On Trade');
        for (EUR_CRM_Account__c acc: accountEU){
            acc.EUR_JB_Approved_Status__c = 'ACTIVE';
            acc.EUR_CRM_Status__c = 'Active';
            acc.EUR_JB_Approved_Status__c = 'Active';
            acc.EUR_CRM_Channel__c = 'ON TRADE';
            acc.EUR_CRM_Sub_Channel__c = 'Retail';
            acc.EUR_CRM_Visit_Frequency_Filtered__c = visitFrequency.Id;
        }
        insert accountEU;
        
        //EUR_CRM_External_Event_Record__c = EUR_LV_Direct_Account_Visit_Event
        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        routeTemplate = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_LV_Route_Template', '')[0];
        routeTemplate2 = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_DK_Route_Template', '')[0];
        routeTemplateList.add(routeTemplate);
        routeTemplateList.add(routeTemplate2);
        insert routeTemplateList;
        
        routeTempItem = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
        routeTempItem.EUR_CRM_Account__c = accountEU[0].Id;
        insert routeTempItem;
        
        routeTempDay = EUR_CRM_TestClassUtilityHelper.createRouteTempDay(1, routeTempItem.Id)[0];
        routeTempDay.EUR_CRM_Day__c = 2;
        insert routeTempDay;
        
        events = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR LV Direct Account Visit Event', account.Id, UserInfo.getUserId(), dt, DateTime.now().addDays(14))[0];
        events.IsAllDayEvent = true;
        events.ActivityDateTime = DateTime.now().addDays(20);
        events.EUR_CRM_Route_Template__c = routeTemplate.Id;
        insert events;
        
        events2 = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR LV Direct Account Visit Event', accountEU[0].Id, UserInfo.getUserId(), dt, DateTime.now().addDays(14))[0];
        events2.IsAllDayEvent = true;
        events2.ActivityDateTime = DateTime.now().addDays(20);
        events2.EUR_CRM_Route_Template__c = routeTemplate.Id;
        insert events2;
    }
    
    static testMethod void routeTemplateClass1() {
        
        dataInsert1();
        test.startTest();
        Date dToday = Date.today();
        DateTime dtToday = DateTime.now();
        DateTime eDate = DateTime.now().addDays(10);
        
        List<EUR_CRM_Route_Template_Day__c> rtd = new List<EUR_CRM_Route_Template_Day__c>();
        rtd.add(routeTempDay);
        
        EUR_CRM_RouteTemplateClass con = new EUR_CRM_RouteTemplateClass(routeTemplate.Id);
        EUR_CRM_RouteTemplateClass.routeItemWrapper rtiWrap = new EUR_CRM_RouteTemplateClass.routeItemWrapper();
        
        rtiWrap.routeTemplateItem = routeTempItem;    
        rtiWrap.meetingDuration = 2;
        rtiWrap.subject = 'Test Subject';
        rtiWrap.visitFrequencyName = 'CZ';
        rtiWrap.visitFrequency = 1;
        rtiWrap.visitSpan = 2;
        rtiWrap.accountId = accountEU[0].Id;
        rtiWrap.accountName = accountEU[0].Name;
        rtiWrap.accountAddress = null;
        rtiWrap.accountPostCode = accountEU[0].EUR_CRM_Postal_Code__c;
        rtiWrap.accountCity = accountEU[0].EUR_JB_City_Name__c;
        rtiWrap.accountStreet = accountEU[0].EUR_CRM_Street__c;
        rtiWrap.hasFrequency = true;
        rtiWrap.isVisitFrequencyModified = true;
        List<EUR_CRM_Route_Template_Day__c> rtDays = new List<EUR_CRM_Route_Template_Day__c>();
        rtDays.add(routeTempDay);
        rtiWrap.routeDays = rtDays;
        List<Integer> rDaysInt = new List<Integer>();
        rDaysInt.add(2);
        rDaysInt.add(0);
        rtiWrap.routeDaysInt = rDaysInt;
        
        boolean edit = con.isEditable;
        
        con.retrieveExternalEvents(System.Today(), 'EUR_DE_Visitation_Event');
        //2014-06-14 added 3rd param 'false' in the method
        con.initRouteItems(true, dToday, true);
        con.populateRTIEventDisplay(dToday);
        con.getSelectedExternalEvents(Date.valueOf(dt));
        con.createEventJS('test accountName', accountEU[0].Id, 2, 10, Date.valueOf(dt));
        con.retrieveEvents();
        con.retrieveEvents(dToday);
        con.retrieveEventsMap(dToday);
        con.createReminderTask(dToday.addDays(5), dToday.addDays(10),routeTemplate.Id);
        con.clearReminderTask();
        con.isAT();
        con.addEventJSToMap(1, 2, accountEU[0].Id, 'test accountName', rtd, Date.valueOf(dt));
        con.createEvent(accountEU[0].Id, dt, DateTime.now().addDays(14), 2, 'testSubject', routeTempItem.Id, 2);
        con.createEvent(rtiWrap, dt, DateTime.now().addDays(14), routeTempItem.Id, 2);
        con.getNextWorkingDate(dtToday);
        con.updateRouteTemplateDay(String.valueOf(accountEU[0].Id), 1, 3);
        con.deleteRouteItems(0);
        con.deleteRouteItems(String.valueOf(accountEU[0].Id));
        
        test.stopTest();
    }
    
    public static void dataInsert2(){
        Date dte = date.valueOf(DateTime.now().addDays(7));
        dte = dte.toStartOfWeek().addDays(3);
        dt = dateTime.newInstance(dte.year(), dte.month(),dte.day());
        
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(2, 'LT Direct - On Trade');
        for (EUR_CRM_Account__c acc:accountEU){           
            acc.EUR_CRM_Sub_Channel__c = 'Retail';
        }
        insert accountEU;
        
        routeTemplate = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_GB_Route_Template', 'EUR')[0];
        insert routeTemplate;
        
        events = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR DE Visitation Event', routeTemplate.Id, UserInfo.getUserId(), dt, System.now()+14)[0];
        events.EUR_CRM_Route_Template__c = routeTemplate.Id;
        events.EUR_CRM_Week_Number__c = 1;
        insert events;
        
        system.debug('##events: '+events);
        
        routeTempItem = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
        routeTempItem.EUR_CRM_Account__c = accountEU[0].Id;
        insert routeTempItem;
        
        routeTempDay = EUR_CRM_TestClassUtilityHelper.createRouteTempDay(1, routeTempItem.Id)[0];
        insert routeTempDay;
    }
    
    static testMethod void routeTemplateClass2() {
        
        test.startTest();
        dataInsert2();
        system.debug('##events: '+events);
        
        Date dToday = Date.today();
        DateTime dtToday = DateTime.now();
        
        EUR_CRM_RouteTemplateClass con1 = new EUR_CRM_RouteTemplateClass(routeTemplate.Id);
        con1.retrieveExternalEvents(System.Today(), 'EUR_DE_Visitation_Event');
        
        EUR_CRM_RouteTemplateClass con = new EUR_CRM_RouteTemplateClass(routeTemplate.Id, System.today());
        
        con.retrieveExternalEvents(System.Today(), 'EUR_DE_Visitation_Event');
        con.clearReminderTask();
        con.createReminderTask(null, null,routeTemplate.Id);
        con.isAT();
        con.populateRTIEventDisplay(Date.valueOf(dt));
        con.createEvent(accountEU[0].Id, dt, DateTime.now().addDays(14), 2, 'testSubject', routeTempItem.Id, 2);
        con.updateRouteTemplateDay(String.valueOf(String.valueOf(accountEU[1].Id)), 1, 3);
        test.stopTest();
    }
}