@IsTest(IsParallel = true)
private class EUR_CRM_DynamicGroupServiceTest {

    private static final String DEFAULT_ATG_RT_DEVNAME = 'EUR_DE_Account_Target_Group';
    private static final String DEFAULT_ACCOUNT_RT_DEVNAME = 'EUR_DE_Off_Trade_New_Business';

    @IsTest
    static void testInsertAccountGroupDynamic() {
        String criteria = '{"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE Name LIKE \'tes%\'",' +
                '"objectName":"EUR_CRM_Account__c","items":[{"value":"tes","operator":"starts with","field":"Name"}],' +
                '"filterLogic":"1","childItems":{}}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        EUR_CRM_Account__c account = makeAccount('test name', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account__c = :account.Id AND EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);
    }

    @IsTest
    static void testInsertAccountGroupStatic() {
        String criteria = '{"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE Name LIKE \'tes%\'",' +
                '"objectName":"EUR_CRM_Account__c","items":[{"value":"tes","operator":"starts with","field":"Name"}],' +
                '"filterLogic":"1","childItems":{}}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, false, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        EUR_CRM_Account__c account = makeAccount('test name', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account__c = :account.Id AND EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);
    }

    @IsTest
    static void testUpdateAccountGroup() {
        Test.startTest();
        String criteria = '{"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE Name LIKE \'tes%\'",' +
                '"objectName":"EUR_CRM_Account__c","items":[{"value":"tes","operator":"starts with","field":"Name"}],' +
                '"filterLogic":"1","childItems":{}}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        EUR_CRM_Account__c account1 = makeAccount('test name', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account1;

        EUR_CRM_Account_in_Target_Group__c accountInTargetGroup = makeAccountInTargetGroup(accountTargetGroup.Id, account1.Id);
        insert accountInTargetGroup;

        EUR_CRM_Account__c account2 = makeAccount('another Acc Name', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account2;

        accountTargetGroup.EUR_CRM_Criteria__c = '{"testQuery":"SELECT Id, Name FROM Account WHERE Name LIKE \'another%\'",' +
                '"objectName":"EUR_CRM_Account__c","items":[{"value":"another","operator":"starts with","field":"Name"}],"filterLogic":"1","childItems":{}}';
        update accountTargetGroup;

        Database.executeBatch(new EUR_CRM_DynGroupMembBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account__c = :account1.Id AND EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(0, countOfAccountInGroup);

        countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account__c = :account2.Id AND EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);
    }

    @IsTest
    static void testUpdateAccount() {
        EUR_CRM_Account__c account = makeAccount('test name', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        String criteria = '{"testQuery":"SELECT Id, EUR_CRM_Postal_Code__c FROM EUR_CRM_Account__c WHERE EUR_CRM_Postal_Code__c LIKE \'11%\'",' +
                '"objectName":"EUR_CRM_Account__c","items":[{"value":"11","operator":"starts with","field":"EUR_CRM_Postal_Code__c"}],' +
                '"filterLogic":"1","childItems":{}}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        EUR_CRM_Account_in_Target_Group__c accountInTargetGroup = makeAccountInTargetGroup(accountTargetGroup.Id, account.Id);
        insert accountInTargetGroup;

        account.EUR_CRM_Postal_Code__c = '99999';
        update account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account__c = :account.Id AND EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(0, countOfAccountInGroup);
    }

    @IsTest
    static void testDeleteAccount() {
        EUR_CRM_Account__c account = makeAccount('test name', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        String criteria = '{"testQuery":"SELECT Id, Name FROM Account WHERE Name LIKE \'tes%\'",' +
                '"objectName":"EUR_CRM_Account__c","items":[{"value":"tes","operator":"starts with","field":"Name"}],' +
                '"filterLogic":"1","childItems":{}}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        EUR_CRM_Account_in_Target_Group__c accountInTargetGroup = makeAccountInTargetGroup(accountTargetGroup.Id, account.Id);
        insert accountInTargetGroup;

        delete account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account__c = :account.Id AND EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(0, countOfAccountInGroup);
    }


    @IsTest
    static void testUndeleteAccount() {
        EUR_CRM_Account__c account = makeAccount('test name', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        String criteria = '{"testQuery":"SELECT Id, Name FROM Account WHERE Name LIKE \'tes%\'",' +
                '"objectName":"EUR_CRM_Account__c","items":[{"value":"tes","operator":"starts with","field":"Name"}],' +
                '"filterLogic":"1","childItems":{}}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        EUR_CRM_Account_in_Target_Group__c accountInTargetGroup = makeAccountInTargetGroup(accountTargetGroup.Id, account.Id);
        insert accountInTargetGroup;

        delete account;
        undelete account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account__c = :account.Id AND EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);
    }

    @IsTest
    static void testUpdateDynamicSegmentation() {
        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        insert new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account_Target_Group__c = accountTargetGroup.Id, EUR_CRM_Account__c = account.Id);

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);

        List<EUR_CRM_PRS_Segmentation__c> segmList = [SELECT EUR_CRM_PRS_Group_Outlet_Type__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.Id];
        segmList[0].EUR_CRM_PRS_Group_Outlet_Type__c = null;
        update segmList;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupSecond = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(0, countOfAccountInGroupSecond);
    }

    @IsTest
    static void testDeleteDynamicSegmentation() {
        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        insert new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account_Target_Group__c = accountTargetGroup.Id, EUR_CRM_Account__c = account.Id);

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);
        delete outletType;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupSecond = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(0, countOfAccountInGroupSecond);
    }

    @IsTest
    static void testUnDeleteDynamicSegmentation() {
        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        insert new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account_Target_Group__c = accountTargetGroup.Id, EUR_CRM_Account__c = account.Id);

        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);
        delete outletType;
        undelete outletType;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupSecond = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroupSecond);
    }

    @IsTest
    static void testUpdateStaticSegmentation() {
        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, false, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        insert new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account_Target_Group__c = accountTargetGroup.Id, EUR_CRM_Account__c = account.Id);
        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);

        Test.startTest();

        List<EUR_CRM_PRS_Segmentation__c> segmList = [SELECT EUR_CRM_PRS_Group_Outlet_Type__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.Id];
        segmList[0].EUR_CRM_PRS_Group_Outlet_Type__c = null;
        update segmList;

        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupSecond = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroupSecond);
    }
    @IsTest
    static void testDeleteStaticSegmentation() {
        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, false, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        insert new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account_Target_Group__c = accountTargetGroup.Id, EUR_CRM_Account__c = account.Id);
        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);

        Test.startTest();

        delete outletType;

        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupSecond = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroupSecond);
    }

    @IsTest
    static void testUnDeleteStaticSegmentation() {
        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, false, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        insert new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account_Target_Group__c = accountTargetGroup.Id, EUR_CRM_Account__c = account.Id);
        Integer countOfAccountInGroup = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroup);

        Test.startTest();

        delete outletType;
        undelete outletType;

        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupSecond = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroupSecond);
    }

    @IsTest
    static void testCreateDynamicSegmentation() {
        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, true, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupFirst = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroupFirst);

    }
    @IsTest
    static void testCreateStaticSegmentation() {
        String criteria = '{"childItems":{"EUR_CRM_PRS_Segmentation__r":{"testQuery":"SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE (EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' AND (EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c=\'Convenience\'))","objectName":"EUR_CRM_PRS_Segmentation__c","items":[{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName","operator":"ends with","value":"_PRS_Off_Trade_Group_Outlet_Type"},{"field":"EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c","operator":"equals","value":"Convenience"}],"filterLogic":" (1 AND (2))","parentRelationType":"contains","childRelationshipName":"EUR_CRM_PRS_Segmentation__r","childRelationshipField":"EUR_CRM_Account__c"}},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (Name LIKE \'%Alona%\')","objectName":"EUR_CRM_Account__c","items":[{"value":"Alona","operator":"contains","field":"Name"}],"filterLogic":"1"}';
        EUR_CRM_Account_Target_Group__c accountTargetGroup = makeAccountTargetGroup(criteria, false, DEFAULT_ATG_RT_DEVNAME);
        insert accountTargetGroup;

        EUR_CRM_Account__c account = makeAccount('Test cafe by Alona', DEFAULT_ACCOUNT_RT_DEVNAME);
        insert account;

        List<RecordType> groupOutletRecordtypeLT = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Group_Outlet_Type__c' AND DeveloperName LIKE '%_PRS_Off_Trade_Group_Outlet_Type'];
        EUR_CRM_PRS_Group_Outlet_Type__c outletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        outletType.EUR_CRM_PRS_Group_Outlet_Name__c = 'Convenience';
        outletType.RecordTypeId = groupOutletRecordtypeLT[0].Id;
        insert outletType;

        EUR_CRM_PRS_Segmentation__c segment = new EUR_CRM_PRS_Segmentation__c();
        segment.EUR_CRM_Account__c = account.Id;
        segment.EUR_CRM_PRS_Group_Outlet_Type__c = outletType.Id;
        insert segment;


        Test.startTest();
        Database.executeBatch(new EUR_CRM_DynGroupMembBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        Integer countOfAccountInGroupFirst = [
                SELECT COUNT()
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :accountTargetGroup.Id
        ];
        System.assertEquals(1, countOfAccountInGroupFirst);

    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String name, String rtDevName) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_Account__c(
            RecordTypeId = rtId
        ,   Name = name
        ,   EUR_CRM_Postal_Code__c = '11111'
        );
    }

    private static EUR_CRM_Account_Target_Group__c makeAccountTargetGroup(String criteria, Boolean isDynamic, String rtDevName) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account_Target_Group__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_Account_Target_Group__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Criteria__c = criteria
        ,   EUR_CRM_IsDynamic__c = isDynamic
        );
    }

    private static EUR_CRM_Account_in_Target_Group__c makeAccountInTargetGroup(Id atg, Id accId) {
        return new EUR_CRM_Account_in_Target_Group__c(
            EUR_CRM_Account_Target_Group__c = atg
        ,   EUR_CRM_Account__c = accId
        );
    }

}