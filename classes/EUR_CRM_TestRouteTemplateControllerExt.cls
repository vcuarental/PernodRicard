/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for EUR_CRM_RouteTemplateControllerExt 
History
02/05/2014        IPC     Created
------------------------------------------------------------*/
@isTest
public with sharing class EUR_CRM_TestRouteTemplateControllerExt {

    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Route_Template__c  routeTemplate;
    private static Event event;
    private static EUR_CRM_Route_Template_Item__c routeTemplateItem;
    private static EUR_CRM_Visit_Frequency__c visitFrequency;
    private static EUR_CRM_Route_Template_Day__c routeTempDay;
    private static Map<Id, List<EUR_CRM_RouteTemplateClass.EventJS>> eventsJSDisplayMap = new Map<Id, List<EUR_CRM_RouteTemplateClass.EventJS>>();
    private static List<EUR_CRM_RouteTemplateClass.EventJS> eventsDisplay = new List<EUR_CRM_RouteTemplateClass.EventJS>();
    private static EUR_CRM_RouteTemplateClass.EventJS eJS;
    static void dataInsert(){

        visitFrequency = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1, 'CZ Visit Frequency')[0];
        visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c = 3;
        visitFrequency.EUR_CRM_Frequency_Span_Days__c = 2;
        visitFrequency.EUR_CRM_No_of_Visits_Within_Interval__c  = 3;
        visitFrequency.EUR_CRM_Channel__c = 'ON TRADE';
        visitFrequency.EUR_CRM_Sub_Channel__c = 'ON_STD';
        insert visitFrequency;

        account= EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'AT On Trade')[0];
        account.EUR_CRM_Visit_Frequency_Filtered__c = visitFrequency.Id;
        account.EUR_CRM_Sub_Channel__c='ON_STD';
        insert account;
        
        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        //routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_GB_Route_Template', 'EUR');
        routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_LT_Route_Template', 'EUR');
        insert routeTemplateList;
        system.assert(routeTemplateList[0].Id<>null);
        
        routeTemplate = routeTemplateList[0];
        system.assert(routeTemplate.Id<>null);
        
        Date d = date.valueOf(System.now()+7);
        d = d.toStartOfWeek()+3;
        Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
        
        event = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR DE Visitation Event', routeTemplate.Id, UserInfo.getUserId(), dt, System.now()+14)[0];
        event.EUR_CRM_Route_Template__c = routeTemplate.Id;
        event.EUR_CRM_Week_Number__c = 1;
        insert event;
        
        system.debug('##EVENT: '+event);
        
        routeTemplateItem = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
        routeTemplateItem.EUR_CRM_Account__c = account.Id;
        insert routeTemplateItem;

        routeTempDay = EUR_CRM_TestClassUtilityHelper.createRouteTempDay(1, routeTemplateItem.Id)[0];
        routeTempDay.EUR_CRM_Day__c = 2;
        insert routeTempDay;
        eJS = new EUR_CRM_RouteTemplateClass.EventJS(account.Id,account.name,0,'Test Event',d,d,1);
        eventsDisplay.add(eJS);
        eventsJSDisplayMap.put(account.Id,eventsDisplay);
    }
    static testmethod void testManager(){
        
        Test.startTest();
        dataInsert();
        system.debug('##EVENT: '+event);
        //event = [Select Id from Event where Id =: event.Id];
        
        ApexPages.Standardcontroller standard2 = new ApexPages.Standardcontroller(routeTemplate);
        ApexPages.currentPage().getParameters().put('Id', routeTemplate.Id);
        EUR_CRM_RouteTemplateClass rtClass = new EUR_CRM_RouteTemplateClass(routeTemplate.Id);
        rtClass.retrieveExternalEvents(System.Today(), 'EUR_DE_Visitation_Event');
        
        ApexPages.Standardcontroller standard = new ApexPages.Standardcontroller(routeTemplate);
        ApexPages.currentPage().getParameters().put('Id', routeTemplate.Id);
        ApexPages.currentPage().getParameters().put('accountId', account.Id);
        EUR_CRM_RouteTemplateControllerExt routeTempCtrlr = new EUR_CRM_RouteTemplateControllerExt(standard);
        routeTempCtrlr.selectedInProcessAccount = account.Id;
        routeTempCtrlr.selectedInProcessDays = '1';
        routeTempCtrlr.externalEventStartYear = String.valueOf(System.today().year());
        routeTempCtrlr.externalEventStartMonth = String.valueOf(System.Today().month());
        routeTempCtrlr.externalEventStartDay = String.valueOf(System.Today().day());
        routeTempCtrlr.externalEventStartDate = String.valueOf(System.Today().format());
        Integer eventCount = routeTempCtrlr.eventCount;
        String eventsJSON = routeTempCtrlr.otherEventsJS;
        String evm = String.valueOf(account.Id);
        routeTempCtrlr.eventMapFromPage = '{\"'+evm+'\":[1]}';
        routeTempCtrlr.getPlanningPeriodOptions();
        routeTempCtrlr.getVisitDurationOptions();
        routeTempCtrlr.retrieveRouteTemplateItems();
        routeTempCtrlr.populateEventsDisplay();
        routeTempCtrlr.addRouteItems();
        routeTempCtrlr.deleteRouteItems();
        //routeTempCtrlr.updateExternalEventList();
        routeTempCtrlr.saveTemplate();
        
        
        String accId = String.valueOf(account.Id);
        //routeTempCtrlr.saveRouteDayToMap(accId, 1, 1);
        List<Integer> intList = new List<Integer>();
        intList.add(0);
        intList.add(1);
        intList.add(2);
        routeTempCtrlr.currentRouteDays.put(account.Id, intList);
        routeTempCtrlr.saveRouteDay(accId, 0, 1);
        routeTempCtrlr.saveRouteDay(accId, 1, 1);
        routeTempCtrlr.saveRouteDays();
        routeTempCtrlr.updateExternalEventList();
        routeTempCtrlr.selectedInProcessOrder = '0';
        routeTempCtrlr.selectedInProcessAccount = account.Id;
        routeTempCtrlr.selectedInProcessDays = '1';
        routeTempCtrlr.saveRouteDayEvents();
        List<EUR_CRM_RouteTemplateClass.RouteItemWrapper> crWrapper = routeTempCtrlr.routeItemsDisplay; 
        List<SelectOption> planningPeriodOptions = new List<SelectOption>();
        List<SelectOption> visitDurationOptions = new List<SelectOption>();
        Date a = routeTempCtrlr.sampleDate;
        String b = routeTempCtrlr.currentDate;
        routeTempCtrlr.extendActions();
        rtClass.eventsJSDisplayMap=eventsJSDisplayMap;
        String c = routeTempCtrlr.eventsJS;
        String d = routeTempCtrlr.otherEventsJS;
        Test.stopTest();
        
    }
}