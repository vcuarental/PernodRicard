@isTest
public class EUR_CRM_TestRouteTemplateSummaryExt {
	
    public static testmethod void testRouteTemplateSummaryExt() {
        RecordType routeTemplateRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Route_Template__c' and DeveloperName = 'EUR_DK_Route_Template'];
        
        EUR_CRM_Route_Template__c routeTemplate = new EUR_CRM_Route_Template__c();
        routeTemplate.RecordTypeId = routeTemplateRecordType.Id;
        routeTemplate.EUR_CRM_Max_Planning_Period_Week__c = 7;
        routeTemplate.EUR_CRM_Planning_Period__c = 7;
        routeTemplate.EUR_CRM_Reminder_Day__c = 1;
        insert routeTemplate;
        
        routeTemplate = [SELECT Id, EUR_CRM_Country_Code__c FROM EUR_CRM_Route_Template__c WHERE Id = :routeTemplate.Id];
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(routeTemplate);
        EUR_CRM_Route_Template_SummaryPage_Ext templateSummaryPage = new EUR_CRM_Route_Template_SummaryPage_Ext(standardController);
    }
    
}