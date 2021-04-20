@isTest
public class EUR_CRM_Test_EventDisplayClass{
    private static EUR_CRM_Route_Template__c  routeTemplate;
    private static Event event;
    private static List<Event> eventList = new List<Event>();
    private static EUR_CRM_EventDisplayClass.EventDisplay eventWrap;
    private static List<EUR_CRM_EventDisplayClass.EventDisplay> eventWrapList;
    public static void insertData(){
        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_GB_Route_Template', 'EUR');
        insert routeTemplateList;

        routeTemplate = routeTemplateList[0];
        system.assert(routeTemplate.Id<>null);
        
        Date d = date.valueOf(System.now()+7);
        d = d.toStartOfWeek()+3;
        Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
        
        event = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR DE Visitation Event', routeTemplate.Id, UserInfo.getUserId(), dt, System.now()+14)[0];
        event.EUR_CRM_Route_Template__c = routeTemplate.Id;
        event.EUR_CRM_Week_Number__c = 1;
        insert event;
        eventList.add(event);

        Date eventStartDate = date.newinstance(event.StartDateTime.year(), event.StartDateTime.month(), event.StartDateTime.day());
        Date eventEndDate = date.newinstance(event.EndDateTime .year(), event.EndDateTime .month(), event.EndDateTime .day());
        eventWrap = new EUR_CRM_EventDisplayClass.EventDisplay(event.Id,2,'EventTest',eventStartDate,eventEndDate,5);
        eventWrap = new EUR_CRM_EventDisplayClass.EventDisplay(event.Id,routeTemplate.Id,'EventTest',eventStartDate,eventEndDate,5);
        eventWrap.setNewStartDate(eventStartDate);
        eventWrapList =  new List<EUR_CRM_EventDisplayClass.EventDisplay>();
        eventWrapList.add(eventWrap);
        eventWrapList.sort();

        ApexPages.StandardController standardController = new  ApexPages.StandardController(event);
        EUR_CRM_EventDisplayClass eventDisplayCls1 = new EUR_CRM_EventDisplayClass(standardController);
        EUR_CRM_EventDisplayClass eventDisplayCls2 = new EUR_CRM_EventDisplayClass();
        EUR_CRM_EventDisplayClass eventDisplayCls3 = new EUR_CRM_EventDisplayClass(eventWrapList);
        EUR_CRM_EventDisplayClass eventDisplayCls4 = new EUR_CRM_EventDisplayClass(eventList);
        eventDisplayCls1.addEventDisplayItem(event.Id,2,'EventTest',eventStartDate,eventEndDate,5);
        eventDisplayCls1.deleteEventDisplayItem(event.Id);
        eventDisplayCls1.deleteEventsFromDate(eventStartDate);
        eventWrap.compareTo(eventWrap);

        try{
            EUR_CRM_EventDisplayClass.getTemplateEvents();
        }
        catch(Exception e){

        }
    }
    static testMethod void test1(){
        insertData();
    }
}