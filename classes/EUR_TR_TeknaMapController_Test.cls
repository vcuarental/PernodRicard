/**
 * Created by osman on 21.10.2019.
 */

@IsTest(SeeAllData=false)
private with sharing class EUR_TR_TeknaMapController_Test {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'EUR_TR_TeknaMapController_Test';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_ActivityPoints__c = 'Absolut';
        account.EUR_TR_SubType__c = 'Pavyon';
        insert account;

    }

    @IsTest
    static void constructorMethodTest() {
        EUR_TR_TeknaMapController eurtrTeknaMapController = new EUR_TR_TeknaMapController();
    }

    @IsTest
    static void GetLocationTest() {


        EUR_TR_Account__c account = [SELECT Id,Name FROM EUR_TR_Account__c LIMIT 1];

        //  If method parameters is not null or empty
        String recordId = account.id;
        String objectName = 'EUR_TR_Account__c';
        String fieldName = 'EUR_TR_Location__c';
        String titleName = 'Name';
        String descriptionFileName = '';
        Map<String, String> locationInfo = null;
        Integer expectedMapResult = 4;

        locationInfo = EUR_TR_TeknaMapController.GetLocation(recordId, ObjectName, FieldName, TitleName, descriptionFileName);
        System.assertEquals(expectedMapResult, locationInfo.size());

        // If method parameters is  null or empty
        recordId = '';
        objectName = '';
        fieldName = '';
        descriptionFileName = '';

        locationInfo = EUR_TR_TeknaMapController.GetLocation(recordId, ObjectName, FieldName, TitleName, descriptionFileName);
        expectedMapResult = 0;
        System.assertEquals(expectedMapResult, locationInfo.size());

    }

}