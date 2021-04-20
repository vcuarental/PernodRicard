/**
 * Created by osman on 24.12.2020.
 */

@IsTest
private with sharing class EUR_TR_UserSearchControllerTest {

    @TestSetup
    static void setup() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'EUR TR Trade Tool User'];

        User user = new User();
        user.FirstName = 'vesium test';
        user.LastName = 'vesium test';
        user.UserName = 'pernodtestuser-survey-filter@pernod.com';
        user.Alias = 'filter99';
        user.Email = 'pernodtestuser-survey-filter@pernod.com';
        user.ProfileId = profile.Id;
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'tr_TR';
        user.ManagerId = UserInfo.getUserId();
        user.TimeZoneSidKey = 'Europe/Istanbul';
        insert user;

        EUR_TR_Employee__c areaManager = new EUR_TR_Employee__c();
        areaManager.EUR_TR_RelatedUser__c = UserInfo.getUserId();
        areaManager.Name = UserInfo.getName();
        areaManager.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AreaManager').getRecordTypeId();
        insert areaManager;

        EUR_TR_Employee__c salesChief = new EUR_TR_Employee__c();
        salesChief.EUR_TR_RelatedUser__c = user.Id;
        salesChief.Name = user.FirstName + ' ' + user.LastName;
        salesChief.EUR_TR_ReportsTo_AreaManager__c = areaManager.Id;
        salesChief.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesChief').getRecordTypeId();
        insert salesChief;

        EUR_TR_Account__c accountToSalesChiefReference = new EUR_TR_Account__c();
        accountToSalesChiefReference.EUR_TR_SalesChiefName__c = salesChief.Name;
        accountToSalesChiefReference.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        accountToSalesChiefReference.OwnerId = user.Id;
        accountToSalesChiefReference.EUR_TR_CityName__c = 'AMASYA';
        accountToSalesChiefReference.EUR_TR_Channel__c = 'Otel';
        insert accountToSalesChiefReference;

        EUR_TR_Account__c accountToOwnerReference = new EUR_TR_Account__c();
        accountToOwnerReference.EUR_TR_SalesChiefName__c = null;
        accountToOwnerReference.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        accountToOwnerReference.OwnerId = UserInfo.getUserId();
        accountToOwnerReference.EUR_TR_CityName__c = 'ADANA';
        accountToOwnerReference.EUR_TR_Channel__c = 'Otel';
        insert accountToOwnerReference;

    }

    @IsTest
    static void testGetFilters() {

        Test.startTest();
        {
            EUR_TR_UserSearchController.getFilters();
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetUsersByQueryFilter() {

        EUR_TR_UserSearchController.UserQueryFilterRequest userQueryFilterRequest = new EUR_TR_UserSearchController.UserQueryFilterRequest();

        Test.startTest();
        {
            // manager
            userQueryFilterRequest.fieldName = 'ManagerId';
            userQueryFilterRequest.selectedOptions = new List<String>{
                    UserInfo.getUserId()
            };
            userQueryFilterRequest.queryReference = '';
            EUR_TR_UserSearchController.getUsersByQueryFilter(userQueryFilterRequest);

            // city
            userQueryFilterRequest.fieldName = 'EUR_TR_CityName__c';
            userQueryFilterRequest.selectedOptions = new List<String>{
                    'ADANA', 'AMASYA'
            };
            userQueryFilterRequest.queryReference = 'byOwner';
            EUR_TR_UserSearchController.getUsersByQueryFilter(userQueryFilterRequest);

            userQueryFilterRequest.fieldName = 'EUR_TR_CityName__c';
            userQueryFilterRequest.selectedOptions = new List<String>{
                    'ADANA', 'AMASYA'
            };
            userQueryFilterRequest.queryReference = 'bySalesChief';
            EUR_TR_UserSearchController.getUsersByQueryFilter(userQueryFilterRequest);

            // channel
            userQueryFilterRequest.fieldName = 'EUR_TR_Channel__c';
            userQueryFilterRequest.selectedOptions = new List<String>{
                    'Otel'
            };
            userQueryFilterRequest.queryReference = 'byOwner';
            EUR_TR_UserSearchController.getUsersByQueryFilter(userQueryFilterRequest);

            userQueryFilterRequest.fieldName = 'EUR_TR_Channel__c';
            userQueryFilterRequest.selectedOptions = new List<String>{
                    'Otel'
            };
            userQueryFilterRequest.queryReference = 'bySalesChief';
            EUR_TR_UserSearchController.getUsersByQueryFilter(userQueryFilterRequest);

        }
        Test.stopTest();

    }

    @IsTest
    static void testGenerateQueryByUserIds() {

        List<String> userIds = new List<String>();
        List<User> users = [SELECT Id FROM User LIMIT 10];
        for (User user : users) {
            userIds.add(user.Id);
        }

        Test.startTest();
        {
            EUR_TR_UserSearchController.generateQueryByUserIds(userIds);
        }
        Test.stopTest();

    }

}