@IsTest
public with sharing class EUR_CRM_TerritoryOwnerChangeTest {

    private static final Set<String> TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE = new Set<String>{
        'EUR_CRM_NG_Territory'
    ,   'EUR_MA_Territory'
    };

    public static final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER = new Set<String>{
        'EUR_RU_On_Trade'
    ,   'EUR_RU_Direct_Off_Trade'
    ,   'EUR_RU_Indirect_Off_Trade'
    ,   'EUR_RU_Direct_Type_2_Off_Trade'
    ,   'EUR_RU_Distribution_Center'
    ,   'EUR_RU_Distributor'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_TerritoryOwnerChanged', 'TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE', TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_TerritoryOwnerChanged', 'ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER', ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER));
    }

    @IsTest
    private static void Test1NGTerritory() {
        initCMT();

        User testUser = new User();
        System.runAs (new User(Id = UserInfo.getUserId())) {
            testUser.Username = 'testUserNG111@company.com';
            testUser.Email = 'testuser111@company.com';
            testUser.Lastname = 'user';
            testUser.Firstname = 'test';
            testUser.Alias = 'test';
            testUser.CommunityNickname = '12346';
            testUser.ProfileId = UserInfo.getProfileId();
            testUser.TimeZoneSidKey = 'GMT';
            testUser.LocaleSidKey = 'en_US';
            testUser.EmailEncodingKey = 'ISO-8859-1';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.UserPermissionsMobileUser = false;
            insert testUser;
        }

        EUR_CRM_Region__c regionTest = EUR_CRM_TestClassUtilityHelper.createRegion('Region 1', UserInfo.getUserId(), 'EUR_NG_Region');
        insert regionTest;

        EUR_CRM_Territory__c territoryTest = EUR_CRM_TestClassUtilityHelper.createTerritory('Territory 1', UserInfo.getUserId(), regionTest.id, 'EUR_CRM_NG_Territory');
        insert territoryTest;

        EUR_CRM_Account__c testAccount = makeAccount(territoryTest.Id, 'EUR_NG_Off_Trade_Bulk_Breaker');
        insert testAccount;

        test.startTest();

        List<EUR_CRM_Territory__c> insertedTerrs = selectTerritories();
        System.debug('\n insertedTerrs.size() => ' + insertedTerrs.size() + '\n');
        System.debug('\n insertedTerrs => ' + JSON.serializePretty(insertedTerrs) + '\n');
        insertedTerrs[0].EUR_CRM_KD_Owner__c = testUser.id;
        update insertedTerrs;

        test.stopTest();

        List<EUR_CRM_Territory__c> updatedTerritories = selectTerritories();
        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.debug('\n updatedTerritories.size() => ' + updatedTerritories.size() + '\n');
        System.debug('\n updatedTerritories => ' + JSON.serializePretty(updatedTerritories) + '\n');
        System.assertEquals(true, updatedTerritories[0].EUR_CRM_IsOwnerChanged__c);
        System.assertEquals(updatedTerritories[0].EUR_CRM_Territory_Owner__c, updatedAccounts[0].OwnerId);

    }

    @IsTest
    private static void test3DETerritory() {
        initCMT();

        Integer accountsQty = 3;
        EUR_CRM_Account__c testAccount;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'EUR DE OFF Trade User'];
//        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'EUR DE BZL South'];
        Id accountRtId = null;
        List<User> users = new List<User>();
        User u = new User(
                Alias = 'standt',
                Email = 'userEmail1234aoke@test.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
//                userroleid = r.id,
                LastName = 'User',
                ProfileId = p.Id,
                UserName = 'testUser7749374397@ctdev.io',
                TimeZoneSidKey = 'America/Los_Angeles',
                BypassTriggers__c = 'Autofollow_User_InsertUpdate;AutoJoin_User_InsertUpdate;ESN_User_AutojoinByAffiliates;ChatterEmailSettings');
        users.add(u);
        User u2 = new User(
                Alias = 'standt',
                Email = 'userEmail@test.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
//                userroleid = r.id,
                LastName = 'User2',
                ProfileId = p.Id,
                UserName = 'testUser7749374398@ctdev.io',
                TimeZoneSidKey = 'America/Los_Angeles',
                BypassTriggers__c = 'Autofollow_User_InsertUpdate;AutoJoin_User_InsertUpdate;ESN_User_AutojoinByAffiliates;ChatterEmailSettings');
        users.add(u2);
        insert users;
        System.runAs(users[0]) {
            EUR_CRM_Region__c regionTest = EUR_CRM_TestClassUtilityHelper.createRegion('Region 1', users[0].Id, 'EUR_NG_Region');
            regionTest.EUR_CRM_Region_Code__c = 'R1';
            insert regionTest;
            EUR_CRM_Territory__c territoryTest = EUR_CRM_TestClassUtilityHelper.createTerritory('test territory', users[0].Id, regionTest.id, 'EUR_DE_Territory');
            insert territoryTest;
            EUR_CRM_Postal_Code_Territory_Mapping__c postalmapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap', '12345', territoryTest.id, EUR_CRM_DE_TestClassUtilityHelper.DE_POSTAL_CODE_MAPPING_RECORD_TYPE);

            //createAccounts(territoryTest.Id, accountRtId, accountsQty);
            test.startTest();
            territoryTest.EUR_CRM_Territory_Owner__c = users[1].Id;
            update territoryTest;
            Set<Id> territoryIds = new Set<Id>{territoryTest.Id};
            new EUR_CRM_TerritoryOwnerChanged().createMassUpdateBatch(territoryIds, new Set<Id>());
            test.stopTest();
        }

        //System.assertEquals(accountsQty, [SELECT Id FROM EUR_CRM_Account__c WHERE OwnerId = :users[1].Id].size());
    }

    private static void createAccounts(Id territoryId, Id accountRtId, Integer accountsQty) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < accountsQty; i++) {
            accounts.add(new EUR_CRM_Account__c(
                    Name = 'test account' + i,
                    EUR_CRM_Territory__c = territoryId,
                    RecordTypeId = accountRtId,
                    EUR_CRM_Status__c = 'Active',
                    EUR_CRM_Postal_Code__c = '12345'
            ));
        }
        insert accounts;
    }

    private static EUR_CRM_Account__c makeAccount(Id terrId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Territory__c = terrId
        ,   EUR_CRM_Postal_Code__c = '12345'
        );
    }

    private static List<EUR_CRM_Territory__c> selectTerritories() {
        return [
            SELECT Id
            ,   EUR_CRM_IsOwnerChanged__c
            ,   EUR_CRM_Territory_Owner__c
            ,   EUR_CRM_Off_Trade_Owner__c
            ,   EUR_CRM_On_Trade_Owner__c
            ,   EUR_CRM_KD_Owner__c
            FROM EUR_CRM_Territory__c];
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   OwnerId
            FROM EUR_CRM_Account__c
        ];
    }

    private static EUR_CRM_Account__c makeAccountWithOutTerritory(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
                RecordTypeId = rtId
                ,   EUR_CRM_Postal_Code__c = '12345'
        );
    }
}