@isTest
public with sharing class LAT_Notification_Controller_Test {
    
    @isTest
    static void createNotifications(){
        LAT_Notification__c template = new LAT_Notification__c();
        template.LAT_Notification_Detail__c = 'Es un test';
        template.LAT_Country__c = 'Argentina';
        template.LAT_Status__c = 'Created';
        template.LAT_Start_Date__c = Date.today();
        template.LAT_Active__c = true;
        template.LAT_End_Date__c = Date.today().addDays(5);
        template.Name = 'Test';
        template.RecordTypeId = Schema.SObjectType.LAT_Notification__c.getRecordTypeInfosByDeveloperName().get('LAT_Template').getRecordTypeId();
        
        insert template;

    }

    @isTest
    static void LAT_LookUp_Controller_Test(){


        LAT_LookUp_Controller.fetchRecords('LAT_Product__c', 'Name', 'Vodka',null);
        UDC__c UdcTest = new UDC__c();
		UdcTest.CodUs__c = '03';
		UdcTest.CodProd__c = '01';
		UdcTest.Name = 'KA';
		UdcTest.Internal_Id__c = '00-CT';
		UdcTest.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
        insert UdcTest;

        LAT_LookUp_Controller.fetchRecords('UDC__c', 'Name', 'Vodka',UdcTest.Id);
    }
}