@isTest
public class EUR_CRM_TestNewSalesRepOrderPageCtrl {

    public static testmethod void testNewSalesRepOrderPageCtrl() {
        RecordType salesRepOrderRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_SalesRep_Order__c' and DeveloperName = 'EUR_DK_Free_Goods_Order_to_SR_Stock'];
        
        EUR_CRM_Apex_Configuration__c runningNumber = new EUR_CRM_Apex_Configuration__c();
        runningNumber.EUR_CRM_Prefix__c = 'Testing';
        runningNumber.EUR_CRM_Running_Number_Length__c = 5;
        runningNumber.EUR_CRM_Running_Number__c = 1;
        runningNumber.EUR_CRM_Module__c = 'EUR_CRM_SRO_Running_Number';
        runningNumber.EUR_CRM_Country_Code__c = 'DK';
        insert runningNumber;
        
        EUR_CRM_SalesRep_Order__c salesRepOrder = new EUR_CRM_SalesRep_Order__c();
        salesRepOrder.RecordTypeId = salesRepOrderRecordType.Id;
        insert salesRepOrder;
        
        Test.startTest();
        	ApexPages.StandardController stdController = new ApexPages.StandardController(salesRepOrder);
        	EUR_CRM_NewSalesRepOrderPageController controller = new EUR_CRM_NewSalesRepOrderPageController(stdController);
        	controller.assignDefaultAndRedirect();
        Test.stopTest();
    }
    
}