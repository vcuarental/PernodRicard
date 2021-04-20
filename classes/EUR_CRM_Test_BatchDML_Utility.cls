@isTest
public class EUR_CRM_Test_BatchDML_Utility{

    private static EUR_CRM_Route_Template__c  routeTemplate;
    private static Event event;
    private static EUR_CRM_Route_Template_Item__c routeTemplateItem;
    private static List<Event> eventsToDelete {get;set;}
    private static List<EUR_CRM_Route_Template_Item__c> routeItems {get;set;}

    static testMethod void test1(){

        dataInsert();
        test.startTest();
            Id batchprocessid = Database.executeBatch(new EUR_CRM_BatchDML_Utility(eventsToDelete, 'Event', EUR_CRM_BatchDML_Utility.Operation.DELETE_RECORDS,true, createPostDMLs())); 
        test.stopTest();
         
    }

    private static List<EUR_CRM_BatchDML_Utility.PostDML> createPostDMLs(){
        
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

    
    static testmethod void dataInsert(){
        eventsToDelete = new List<Event>();
        routeItems = new List<EUR_CRM_Route_Template_Item__c> ();
        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_GB_Route_Template', 'EUR');
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
        eventsToDelete.add(event);
        
        
        routeTemplateItem = EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, routeTemplate.Id)[0];
        insert routeTemplateItem;
        routeItems.add(routeTemplateItem);
    }
}