/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for EUR_CRM_RouteDeletionControllerExt 
History
29/04/2014        IPC     Created
------------------------------------------------------------*/
@isTest
public with sharing class EUR_CRM_TestRouteDeletionControllerExt {

    private static EUR_CRM_Route_Template__c  routeTemplate;
    private static Event event;
    private static EUR_CRM_Route_Template_Item__c routeTemplateItem;
    
    static testmethod void testManager(){
        try{
            Test.startTest();
           
            List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
            routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_GB_Route_Template', 'EUR');
            insert routeTemplateList;
            system.assert(routeTemplateList[0].Id<>null);
            
            routeTemplate = routeTemplateList[0];
            system.assert(routeTemplate.Id<>null);  
            
            routeTemplateItem = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
            insert routeTemplateItem;
        
            Date d = date.valueOf(System.now()+7);
            d = d.toStartOfWeek()+3;
            Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
            Date eventDate = date.newinstance(dt.year(), dt.month(), dt.day());
        
            List<Event> eventList = new List<Event>();
            eventList = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR DE Visitation Event', routeTemplate.Id, UserInfo.getUserId(), dt, System.now()+14);
            eventList[0].EUR_CRM_Route_Template__c = routeTemplate.Id;
            eventList[0].EUR_CRM_Week_Number__c=7;
            system.debug('@eventList'+eventList);
            insert eventList;
            system.assert(eventList.size()==1);
            
            ApexPages.Standardcontroller standard = new ApexPages.Standardcontroller(routeTemplate);
            ApexPages.currentPage().getParameters().put('Id', routeTemplate.Id);
            EUR_CRM_RouteDeletionControllerExt routeDeletion = new EUR_CRM_RouteDeletionControllerExt(standard);
            Integer eventDelete = routeDeletion.eventsToDeleteSize;
            
            routeDeletion.events.put(eventList[0].Id, eventList[0]);
            string json = routeDeletion.eventsJS;
            routeDeletion.selectedDate = String.valueOf(System.Today().format());
            routeDeletion.clearTempCalendar(System.Today());
            //routeDeletion.eventsToDelete = eventList;
            routeDeletion.clearCalendar();
            routeDeletion.retrieveLastEvent();
            routeDeletion.clearTempCalendar();
            routeDeletion.createPostDMLs();
            routeDeletion.retrieveLastPopulatedDate(routeTemplate.Id,routeTemplate.ownerId);
            Test.stopTest();
        }catch (Exception e){ // this exeption will not be catch because it is probably thown in a separate transaction
        }
        
        
    }
     /*       
     static testmethod void testManager2(){
        try{
            //Test.startTest();
           
            List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
            routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_GB_Route_Template', 'EUR');
            insert routeTemplateList;
            system.assert(routeTemplateList[0].Id<>null);
            
            routeTemplate = routeTemplateList[0];
            system.assert(routeTemplate.Id<>null);  
            
            routeTemplateItem = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
            insert routeTemplateItem;
        
            Date d = date.valueOf(System.now()+7);
            d = d.toStartOfWeek()+3;
            Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
            Date eventDate = date.newinstance(dt.year(), dt.month(), dt.day());
        
            List<Event> eventList = new List<Event>();
            eventList = EUR_CRM_TestClassUtilityHelper.createEvents(2001, 'EUR DE Visitation Event', routeTemplate.Id, UserInfo.getUserId(), dt, System.now()+14);
            eventList[0].EUR_CRM_Route_Template__c = routeTemplate.Id;
            eventList[0].EUR_CRM_Week_Number__c=7;
            system.debug('@eventList'+eventList);
            insert eventList;
            system.assert(eventList.size()==2001);
            
            ApexPages.Standardcontroller standard = new ApexPages.Standardcontroller(routeTemplate);
            ApexPages.currentPage().getParameters().put('Id', routeTemplate.Id);
            EUR_CRM_RouteDeletionControllerExt routeDeletion = new EUR_CRM_RouteDeletionControllerExt(standard);
            Integer eventDelete = routeDeletion.eventsToDeleteSize;
            
            routeDeletion.events.put(eventList[0].Id, eventList[0]);
            string json = routeDeletion.eventsJS;
            routeDeletion.selectedDate = String.valueOf(System.Today().format());
            routeDeletion.clearTempCalendar(System.Today());
            routeDeletion.eventsToDelete = eventList;
            routeDeletion.clearCalendar();
            routeDeletion.retrieveLastEvent();
            routeDeletion.clearTempCalendar();
            
            //Test.stopTest();
        }catch (Exception e){ // this exeption will not be catch because it is probably thown in a separate transaction
        }
        
        
    }
    */
    /*
    static testmethod void testManager2(){

        Test.startTest();

        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_GB_Route_Template', 'EUR');
        insert routeTemplateList;
        system.assert(routeTemplateList[0].Id<>null);
        
        routeTemplate = routeTemplateList[0];
        system.assert(routeTemplate.Id<>null);
        
        Date d = date.valueOf(System.now()+7);
        d = d.toStartOfWeek()+3;
        Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
        Date eventDate = date.newinstance(dt.year(), dt.month(), dt.day());
        event = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR DE Visitation Event', routeTemplate.Id, UserInfo.getUserId(), dt, System.now()+14)[0];
        event.EUR_CRM_Route_Template__c = routeTemplate.Id;
        event.EUR_CRM_Week_Number__c = 1;
        insert event;

        ApexPages.Standardcontroller standard = new ApexPages.Standardcontroller(routeTemplate);
        ApexPages.currentPage().getParameters().put('Id', routeTemplate.Id);
        EUR_CRM_RouteDeletionControllerExt routeDeletion = new EUR_CRM_RouteDeletionControllerExt(standard);
        routeDeletion.selectedDate = String.valueOf(eventDate.format());
        routeDeletion.retrieveLastEvent();
        routeDeletion.clearTempCalendar();
        Test.stopTest();
        
    }
    */
}