/**
 * Created by V. Kamenskyi on 01.11.2017.
 */
@IsTest
private class EUR_CRM_Test_ManualSharingLtngCtrl {

    @TestSetup
    private static void init() {
        SObject cat = EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_ProductCatalog__c(), true);
    }

    @IsTest
    private static void getShareRecordsTest() {
        Id parentId = [
                SELECT Id
                FROM EUR_CRM_ProductCatalog__c
                LIMIT 1
        ].Id;
        
        Map<String, Object> result = (Map<String, Object>) EUR_CRM_ManualSharingLightningController.getShareRecords(parentId);
        Map<Id, EUR_CRM_ProductCatalog__Share> shares = new Map<Id, EUR_CRM_ProductCatalog__Share>([
                SELECT Id
                FROM EUR_CRM_ProductCatalog__Share
                WHERE ParentId = :parentId
        ]);
        System.assertNotEquals(null, result.get('records'));
        System.assertNotEquals(null, result.get('reasons'));
        System.assertNotEquals(null, result.get('allReasons'));

        System.assertEquals(shares.size(),( (List<Object>)result.get('records') ).size());
    }

    @IsTest
    private static void getSharingSubjectsTest() {
        Map<String, List<SObject>> result = (Map<String, List<SObject>>) EUR_CRM_ManualSharingLightningController.getSharingSubjects(null);
        Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE IsActive = TRUE AND UserType = 'Standard' ORDER BY Name ASC LIMIT 50]).keySet();
        Set<Id> groupIds = new Map<Id, Group>([SELECT Id FROM Group WHERE Name LIKE '%' AND Type != 'Queue' ORDER BY Name ASC LIMIT 50]).keySet();
        System.Test.startTest();
        System.assert(new Map<Id, SObject>(result.get('users')).keySet().containsAll(userIds));
        System.assert(new Map<Id, SObject>(result.get('groups')).keySet().containsAll(groupIds));
        System.Test.stopTest();
    }

    @IsTest
    private static void setSharingTest() {
        Id parentId = [
                SELECT Id
                FROM EUR_CRM_ProductCatalog__c
                LIMIT 1
        ].Id;
         
        Set<Id> userIds = new Map<Id, User>([
                SELECT Id
                FROM User
                WHERE IsActive = TRUE
                AND UserType = 'Standard'
                AND Id <> :UserInfo.getUserId()
            	LIMIT 3
        ]).keySet();
        
        Set<Id> groupIds = new Map<Id, Group>([
                SELECT Id
                FROM Group
                WHERE Name LIKE '%'
                AND Type != 'Queue'
            	LIMIT 3
        ]).keySet();
        
        Set<Id> userOrGroupIds = new Set<Id>();
        userOrGroupIds.addAll(userIds);
        userOrGroupIds.addAll(groupIds);
        String reason = 'manual';
        String accessLevel = 'edit';
        String result = EUR_CRM_ManualSharingLightningController.setSharing(parentId, new List<Id>(userOrGroupIds), accessLevel, reason);
        Database.SaveResult[] results = (Database.SaveResult[]) JSON.deserializeStrict(result, Database.SaveResult[].class);
        for (Database.SaveResult sr : results) {
            System.assert(sr.isSuccess());
        }
    }

    @IsTest
    private static void removeSharingTest() {
        Id parentId = [
                SELECT Id
                FROM EUR_CRM_ProductCatalog__c
                LIMIT 1
        ].Id;
        Set<Id> userIds = new Map<Id, User>([
                SELECT Id
                FROM User
                WHERE IsActive = TRUE
                AND UserType = 'Standard'
                AND Id <> :UserInfo.getUserId()
        ]).keySet();
        Set<Id> groupIds = new Map<Id, Group>([
                SELECT Id
                FROM Group
                WHERE Name LIKE '%'
                AND Type != 'Queue'
        ]).keySet();
        
        Set<Id> userOrGroupIds = new Set<Id>();
        userOrGroupIds.addAll(userIds);
        userOrGroupIds.addAll(groupIds);
        String result = EUR_CRM_ManualSharingLightningController.removeSharing(parentId, new List<Id>(userOrGroupIds));
        Database.DeleteResult[] results = (Database.DeleteResult[]) JSON.deserializeStrict(result, Database.DeleteResult[].class);
        for (Database.DeleteResult dr : results) {
            System.assert(dr.isSuccess());
        }
    }

    @IsTest
    private static void getInitValuesTest() {
        String shareObjectType = 'EUR_CRM_ProductCatalog__Share';
        Map<String, Object> result = (Map<String, Object>) EUR_CRM_ManualSharingLightningController.getInitValues(shareObjectType);
        System.assertNotEquals(null, result.get('reasons'));
        System.assertNotEquals(null, result.get('allReasons'));
        System.assertNotEquals(null, result.get('accessLevels'));
        System.assertNotEquals(null, result.get('userType'));
        System.assertNotEquals(null, result.get('groupType'));
        System.assertEquals(UserInfo.getUserId(), (String) result.get('userId'));
    }
}