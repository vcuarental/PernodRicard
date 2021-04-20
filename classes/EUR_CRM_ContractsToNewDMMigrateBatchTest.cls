@IsTest (IsParallel = true)
private class EUR_CRM_ContractsToNewDMMigrateBatchTest {

//    private static final Integer COUNT_OF_RECORDS = 5;

    private static final String DE_HOUSE_POURING_MECHANIC_TYPE = EUR_CRM_ContractsToNewDMMigrateBatch.HOUSE_POURING_MECHANIC_TYPE_BE_COUNTRY_CODE.get('DE');
    private static final String DE_LISTING_MECHANIC_TYPE = EUR_CRM_ContractsToNewDMMigrateBatch.LISTING_MECHANIC_TYPE_BE_COUNTRY_CODE.get('DE');

    @TestSetup
    private static void setupMethod() {
        Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Mechanic_Type').getRecordTypeId();
        insert new List<EUR_CRM_Mechanic_Type__c> {
            new EUR_CRM_Mechanic_Type__c(
                RecordTypeId = rtId
            ,   Name = DE_HOUSE_POURING_MECHANIC_TYPE
            ,   EUR_CRM_External_ID__c = DE_HOUSE_POURING_MECHANIC_TYPE
            )
        ,   new EUR_CRM_Mechanic_Type__c(
                RecordTypeId = rtId
            ,   Name = DE_LISTING_MECHANIC_TYPE
            ,   EUR_CRM_External_ID__c = DE_LISTING_MECHANIC_TYPE
            )
        };
    }

    @IsTest
    private static void setupTest() {
        List<EUR_CRM_Mechanic_Type__c> mechanicTypes = [SELECT Id FROM EUR_CRM_Mechanic_Type__c];
        System.assertEquals(2, mechanicTypes.size(), 'Mechanic Types do not exist!');
    }

    @IsTest
    private static void singleInvalidContractListingPouringToOneContractAllPeriodsTest_2() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        contract = [SELECT Id, EUR_CRM_Status__c, EUR_CRM_Active__c FROM EUR_CRM_Contract__c WHERE Id = :contract.Id LIMIT 1][0];
        System.debug('\n\n contract => ' + JSON.serializePretty(contract) + '\n');

        Test.startTest();

        Test.stopTest();


    }


    /* ======================================================================================================== */
    /*     ====================================================================================================
    /*     | EUR_CRM_Contract_Activity_Item__c and EUR_CRM_Contract_Product_Item__c don't exist - all Periods |
    /*     ====================================================================================================
    /* ======================================================================================================== */

    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleInvalidContractListingPouringToOneContractAllPeriodsTest_3() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }


    /* ======================================================================================================== */
    /*     Few EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void threeInvalidContractListingPouringsToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void threeListingContractListingPouringsToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(3, contractActivityItems[0].Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');
        for (Integer i = 0; i < contractActivityItems[0].Contract_Product_Items__r.size(); i++) {
            System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void threePouringContractListingPouringsToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(3, contractActivityItems[0].Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');
        for (Integer i = 0; i < contractActivityItems[0].Contract_Product_Items__r.size(); i++) {
            System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void threeListingAndPouringContractListingPouringsToOneContractAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(3, contractActivityItem.Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');
//            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
//                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//            }
        }
    }


    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (multiple EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
            }
        }
    }

    @IsTest
    private static void singlePouringContractListingPouringToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
            }
        }
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(6, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            Boolean shouldBeTrue =
                contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE
                || contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_LISTING_MECHANIC_TYPE
            ;
            System.assertEquals(true, shouldBeTrue, 'The wrong Mechanic Type');
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
            }
        }
    }


    /* ======================================================================================================== */
    /*     Few EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (multiple EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void threeInvalidContractListingPouringsToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void threeListingContractListingPouringsToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        }

//        Integer count = 0;
        for (Integer i = 0; i < contractActivityItems.size(); i++) {
            System.assertEquals(3, contractActivityItems[i].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

//            for (Integer j = 0; j < contractActivityItems[i].Contract_Product_Items__r.size(); j++) {
//                System.assertEquals(contractListingPourings[count].EUR_CRM_Brand_Quality__c, contractActivityItems[i].Contract_Product_Items__r[j].EUR_CRM_Brand_Quality__c, 'The lookup №' + count + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//                count++;
//            }
        }
    }

    @IsTest
    private static void threePouringContractListingPouringsToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        }

//        Integer count = 0;
        for (Integer i = 0; i < contractActivityItems.size(); i++) {
            System.assertEquals(3, contractActivityItems[i].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

//            for (Integer j = 0; j < contractActivityItems[i].Contract_Product_Items__r.size(); j++) {
//                System.assertEquals(contractListingPourings[count].EUR_CRM_Brand_Quality__c, contractActivityItems[i].Contract_Product_Items__r[j].EUR_CRM_Brand_Quality__c, 'The lookup №' + count + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//                count++;
//            }
        }
    }

    @IsTest
    private static void threeListingAndPouringContractListsingPouringToThreeContractsAllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(6, contractActivityItems.size(), 'The six EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            Boolean shouldBeTrue =
                contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE
                || contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_LISTING_MECHANIC_TYPE
            ;
            System.assertEquals(true, shouldBeTrue, 'The wrong Mechanic Type');
        }

//        Integer count = 0;
        for (Integer i = 0; i < contractActivityItems.size(); i++) {
            System.assertEquals(3, contractActivityItems[i].Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');

//            for (Integer j = 0; j < contractActivityItems[i].Contract_Product_Items__r.size(); j++) {
//                System.assertEquals(contractListingPourings[count].EUR_CRM_Brand_Quality__c, contractActivityItems[i].Contract_Product_Items__r[j].EUR_CRM_Brand_Quality__c, 'The lookup №' + count + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//                count++;
//            }
        }
    }


    /* ======================================================================================================== */
    /*     ==============================================================================================
    /*     | EUR_CRM_Contract_Activity_Item__c and EUR_CRM_Contract_Product_Item__c exist - all Periods |
    /*     ==============================================================================================
    /* ======================================================================================================== */

    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, null);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, listingMechanicType.Id));
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[0].Id, quality.Id));
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[1].Id, quality.Id));
        insert contractProductItems;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }


    /* ======================================================================================================== */
    /*     Few EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void threeInvalidContractListingPouringsToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, null);
        insert contractActivityItem;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItem.Id, qualities);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void threeListingContractListingPouringsToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItem.Id, qualities);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(3, contractActivityItems[0].Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');
        for (Integer i = 0; i < contractActivityItems[0].Contract_Product_Items__r.size(); i++) {
            System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void threePouringContractListingPouringsToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItem.Id, qualities);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(3, contractActivityItems[0].Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');
        for (Integer i = 0; i < contractActivityItems[0].Contract_Product_Items__r.size(); i++) {
            System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void threeListingAndPouringContractListingPouringsToOneContract_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        insert contract;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, listingMechanicType.Id));
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.addAll(makeContractProductItems(contractActivityItemsToInsert[0].Id, qualities));
        contractProductItems.addAll(makeContractProductItems(contractActivityItemsToInsert[1].Id, qualities));
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contract.Id, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItemsBefore.size(), 'Only 2 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(3, contractActivityItem.Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');
//            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
//                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//            }
        }
    }


    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (multiple EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = makeContractActivityItems(contracts, null);
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItemsToInsert, quality.Id);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItemsBefore.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');
    }

    @IsTest
    private static void singleListingContractListingPouringToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = makeContractActivityItems(contracts, listingMechanicType.Id);
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItemsToInsert, quality.Id);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItemsBefore.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
            }
        }
    }

    @IsTest
    private static void singlePouringContractListingPouringToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c pouringMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = makeContractActivityItems(contracts, pouringMechanicType.Id);
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItemsToInsert, quality.Id);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItemsBefore.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
            }
        }
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.addAll(makeContractActivityItems(contracts, listingMechanicType.Id));
        contractActivityItemsToInsert.addAll(makeContractActivityItems(contracts, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.addAll(makeContractProductItems(contractActivityItemsToInsert, quality.Id));
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, quality.Id);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(6, contractActivityItemsBefore.size(), 'Only 6 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(6, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            Boolean shouldBeTrue =
                contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE
                    || contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_LISTING_MECHANIC_TYPE
            ;
            System.assertEquals(true, shouldBeTrue, 'The wrong Mechanic Type');
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            for (Integer i = 0; i < contractActivityItem.Contract_Product_Items__r.size(); i++) {
                System.assertEquals(contractListingPourings[i].EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[i].EUR_CRM_Brand_Quality__c, 'The lookup №' + i + ' on EUR_CRM_Brand_Quality__c is mismatched!');
            }
        }
    }


    /* ======================================================================================================== */
    /*     Few EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (multiple EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void threeInvalidContractListingPouringsToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = makeContractActivityItems(contracts, null);
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItemsToInsert, qualities);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItemsBefore.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');
    }

    @IsTest
    private static void threeListingContractListingPouringsToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = makeContractActivityItems(contracts, listingMechanicType.Id);
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItemsToInsert, qualities);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItemsBefore.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        }

//        Integer count = 0;
        for (Integer i = 0; i < contractActivityItems.size(); i++) {
            System.assertEquals(3, contractActivityItems[i].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

//            for (Integer j = 0; j < contractActivityItems[i].Contract_Product_Items__r.size(); j++) {
//                System.assertEquals(contractListingPourings[count].EUR_CRM_Brand_Quality__c, contractActivityItems[i].Contract_Product_Items__r[j].EUR_CRM_Brand_Quality__c, 'The lookup №' + count + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//                count++;
//            }
        }
    }

    @IsTest
    private static void threePouringContractListingPouringsToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        EUR_CRM_Mechanic_Type__c pouringMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = makeContractActivityItems(contracts, pouringMechanicType.Id);
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItemsToInsert, qualities);
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItemsBefore.size(), 'Only 3 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(3, contractActivityItems.size(), 'The three EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItem.EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        }

//        Integer count = 0;
        for (Integer i = 0; i < contractActivityItems.size(); i++) {
            System.assertEquals(3, contractActivityItems[i].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');

//            for (Integer j = 0; j < contractActivityItems[i].Contract_Product_Items__r.size(); j++) {
//                System.assertEquals(contractListingPourings[count].EUR_CRM_Brand_Quality__c, contractActivityItems[i].Contract_Product_Items__r[j].EUR_CRM_Brand_Quality__c, 'The lookup №' + count + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//                count++;
//            }
        }
    }

    @IsTest
    private static void threeListingAndPouringContractListsingPouringToThreeContracts_WithExistData_AllPeriodsTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        List<EUR_CRM_Contract__c> contracts = makeContracts(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id, 3);
        insert contracts;

        List<EUR_CRM_Quality__c> qualities = makeBrandQualities(new Set<String> { 'Product_1', 'Product_2', 'Product_3' });
        insert qualities;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.addAll(makeContractActivityItems(contracts, listingMechanicType.Id));
        contractActivityItemsToInsert.addAll(makeContractActivityItems(contracts, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.addAll(makeContractProductItems(contractActivityItemsToInsert, qualities));
        insert contractProductItems;

        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = makeContractListingPourings(contracts, qualities);
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            contractListingPouring.EUR_CRM_Pouring__c = true;
            contractListingPouring.EUR_CRM_Listing__c = true;
        }
        insert contractListingPourings;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(6, contractActivityItemsBefore.size(), 'Only 6 EUR_CRM_Contract_Activity_Item__c records should exist!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Map<Id, EUR_CRM_Contract__c>(contracts).keySet());
        System.assertEquals(6, contractActivityItems.size(), 'The six EUR_CRM_Contract_Activity_Item__c records should exist!');
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            Boolean shouldBeTrue =
                contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE
                    || contractActivityItem.EUR_CRM_Mechanic_Type__r.Name == DE_LISTING_MECHANIC_TYPE
            ;
            System.assertEquals(true, shouldBeTrue, 'The wrong Mechanic Type');
        }

//        Integer count = 0;
        for (Integer i = 0; i < contractActivityItems.size(); i++) {
            System.assertEquals(3, contractActivityItems[i].Contract_Product_Items__r.size(), 'The three EUR_CRM_Contract_Product_Item__c records should exist!');

//            for (Integer j = 0; j < contractActivityItems[i].Contract_Product_Items__r.size(); j++) {
//                System.assertEquals(contractListingPourings[count].EUR_CRM_Brand_Quality__c, contractActivityItems[i].Contract_Product_Items__r[j].EUR_CRM_Brand_Quality__c, 'The lookup №' + count + ' on EUR_CRM_Brand_Quality__c is mismatched!');
//                count++;
//            }
        }
    }


    /* ======================================================================================================== */
    /*     ====================================================================================================
    /*     | EUR_CRM_Contract_Activity_Item__c and EUR_CRM_Contract_Product_Item__c don't exist - past period |
    /*     ====================================================================================================
    /* ======================================================================================================== */

    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToOneContractPastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContractPastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContractPastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContractPastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void singleInvalidContractListingPouringToOneContractPastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContractPastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContractPastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContractPastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }


    /* ======================================================================================================== */
    /*     ==============================================================================================
    /*     | EUR_CRM_Contract_Activity_Item__c and EUR_CRM_Contract_Product_Item__c exist - past period |
    /*     ==============================================================================================
    /* ======================================================================================================== */

    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToOneContract_WithExistData_PastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, null);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContract_WithExistData_PastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContract_WithExistData_PastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContract_WithExistData_PastPeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, listingMechanicType.Id));
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[0].Id, quality.Id));
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[1].Id, quality.Id));
        insert contractProductItems;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void singleInvalidContractListingPouringToOneContract_WithExistData_PastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, null);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContract_WithExistData_PastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContract_WithExistData_PastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContract_WithExistData_PastPeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, listingMechanicType.Id));
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[0].Id, quality.Id));
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[1].Id, quality.Id));
        insert contractProductItems;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', -1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }


    /* ======================================================================================================== */
    /*     ====================================================================================================
    /*     | EUR_CRM_Contract_Activity_Item__c and EUR_CRM_Contract_Product_Item__c don't exist - future period |
    /*     ====================================================================================================
    /* ======================================================================================================== */

    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToOneContractFuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContractFuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContractFuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'The one EUR_CRM_Contract_Activity_Item__c record has to exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContractFuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void singleInvalidContractListingPouringToOneContractFuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContractFuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContractFuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContractFuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItemsBefore.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(0, contractActivityItems.size(), 'At least 1 additional EUR_CRM_Contract_Activity_Item__c record exists!');
    }


    /* ======================================================================================================== */
    /*     ==============================================================================================
    /*     | EUR_CRM_Contract_Activity_Item__c and EUR_CRM_Contract_Product_Item__c exist - future period |
    /*     ==============================================================================================
    /* ======================================================================================================== */

    /* ======================================================================================================== */
    /*     One EUR_CRM_Contract_Listing_Pouring__c per One EUR_CRM_Contract__c (single EUR_CRM_Contract__c)
    /* ======================================================================================================== */
    @IsTest
    private static void singleInvalidContractListingPouringToOneContract_WithExistData_FuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, null);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContract_WithExistData_FuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
        System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContract_WithExistData_FuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
        System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);

        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
        System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContract_WithExistData_FuturePeriodPositiveTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, listingMechanicType.Id));
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[0].Id, quality.Id));
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[1].Id, quality.Id));
        insert contractProductItems;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'The two EUR_CRM_Contract_Activity_Item__c records should exist!');
        if (contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name == DE_HOUSE_POURING_MECHANIC_TYPE) {
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
        } else {
            System.assertEquals(DE_LISTING_MECHANIC_TYPE, contractActivityItems[0].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_LISTING_MECHANIC_TYPE);
            System.assertEquals(DE_HOUSE_POURING_MECHANIC_TYPE, contractActivityItems[1].EUR_CRM_Mechanic_Type__r.Name, 'The Mechanin Type should be ' + DE_HOUSE_POURING_MECHANIC_TYPE);
        }

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            System.assertEquals(1, contractActivityItem.Contract_Product_Items__r.size(), 'The one EUR_CRM_Contract_Product_Item__c record should exists!');
            System.assertEquals(contractListingPouring.EUR_CRM_Brand_Quality__c, contractActivityItem.Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c, 'The lookup on EUR_CRM_Brand_Quality__c is mismatched!');
        }
    }

    @IsTest
    private static void singleInvalidContractListingPouringToOneContract_WithExistData_FuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, null);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singleListingContractListingPouringToOneContract_WithExistData_FuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singlePouringContractListingPouringToOneContract_WithExistData_FuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c mechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id, mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id, quality.Id);
        insert contractProductItem;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(1, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }

    @IsTest
    private static void singleListingAndPouringContractListingPouringToOneContract_WithExistData_FuturePeriodNegativeTest() {
        EUR_CRM_Account__c account = makeAccount(Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_Wholesaler').getRecordTypeId());
        insert account;

        EUR_CRM_Contract__c contract = makeContract(Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId(), account.Id);
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(-9);
        insert contract;

        EUR_CRM_Quality__c quality = makeBrandQuality('Product_1');
        insert quality;

        EUR_CRM_Mechanic_Type__c listingMechanicType = selectMechanicTypeWhereExternalId(DE_LISTING_MECHANIC_TYPE);
        EUR_CRM_Mechanic_Type__c houseMechanicType = selectMechanicTypeWhereExternalId(DE_HOUSE_POURING_MECHANIC_TYPE);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, listingMechanicType.Id));
        contractActivityItemsToInsert.add(makeContractActivityItem(contract.Id, houseMechanicType.Id));
        insert contractActivityItemsToInsert;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[0].Id, quality.Id));
        contractProductItems.add(makeContractProductItem(contractActivityItemsToInsert[1].Id, quality.Id));
        insert contractProductItems;

        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = makeContractListingPouring(contract.Id, quality.Id);
        contractListingPouring.EUR_CRM_Listing__c = true;
        contractListingPouring.EUR_CRM_Pouring__c = true;
        insert contractListingPouring;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsBefore = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItemsBefore.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE', 1), 200);
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItems(new Set<Id> { contract.Id });
        System.assertEquals(2, contractActivityItems.size(), 'Only 1 EUR_CRM_Contract_Activity_Item__c record should exists!');
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Contract__c> makeContracts(Id rtId, Id accId, Integer count) {
        List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>();
        for (Integer i = 0; i < count; i++) {
            contracts.add(makeContract(rtId, accId));
        }
        return contracts;
    }

    private static List<EUR_CRM_Quality__c> makeBrandQualities(Set<String> productNames) {
        List<EUR_CRM_Quality__c> qualities = new List<EUR_CRM_Quality__c>();
        for (String product : productNames) {
            qualities.add(makeBrandQuality(product));
        }
        return qualities;
    }

    private static List<EUR_CRM_Contract_Listing_Pouring__c> makeContractListingPourings(Id contractId, List<EUR_CRM_Quality__c> qualities) {
        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = new List<EUR_CRM_Contract_Listing_Pouring__c>();
        for (EUR_CRM_Quality__c quality : qualities) {
            contractListingPourings.add(makeContractListingPouring(contractId, quality.Id));
        }
        return contractListingPourings;
    }

    private static List<EUR_CRM_Contract_Listing_Pouring__c> makeContractListingPourings(List<EUR_CRM_Contract__c> contracts, Id qualityId) {
        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = new List<EUR_CRM_Contract_Listing_Pouring__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            contractListingPourings.add(makeContractListingPouring(contract.Id, qualityId));
        }
        return contractListingPourings;
    }

    private static List<EUR_CRM_Contract_Listing_Pouring__c> makeContractListingPourings(List<EUR_CRM_Contract__c> contracts, List<EUR_CRM_Quality__c> qualities) {
        List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings = new List<EUR_CRM_Contract_Listing_Pouring__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            for (EUR_CRM_Quality__c quality : qualities) {
                contractListingPourings.add(makeContractListingPouring(contract.Id, quality.Id));
            }
        }
        return contractListingPourings;
    }

    private static List<EUR_CRM_Contract_Product_Item__c> makeContractProductItems(Id caiId, List<EUR_CRM_Quality__c> qualities) {
        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for (EUR_CRM_Quality__c quality : qualities) {
            contractProductItems.add(makeContractProductItem(caiId, quality.Id));
        }
        return contractProductItems;
    }

    private static List<EUR_CRM_Contract_Product_Item__c> makeContractProductItems(List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems, Id qualityId) {
        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            contractProductItems.add(makeContractProductItem(contractActivityItem.Id, qualityId));
        }
        return contractProductItems;
    }

    private static List<EUR_CRM_Contract_Product_Item__c> makeContractProductItems(List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems, List<EUR_CRM_Quality__c> qualities) {
        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            for (EUR_CRM_Quality__c quality : qualities) {
                contractProductItems.add(makeContractProductItem(contractActivityItem.Id, quality.Id));
            }
        }
        return contractProductItems;
    }

    private static List<EUR_CRM_Contract_Activity_Item__c> makeContractActivityItems(List<EUR_CRM_Contract__c> contracts, Id mechanicTypeId) {
        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            contractActivityItems.add(makeContractActivityItem(contract.Id, mechanicTypeId));
        }
        return contractActivityItems;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(Id rtId) {
        return new EUR_CRM_Account__c(
            RecordTypeId = rtId
        ,   Name = 'AccountName'
        ,   EUR_CRM_Postal_Code__c = '112233'
        );
    }

    private static EUR_CRM_Contract__c makeContract(Id rtId, Id accId) {
        return new EUR_CRM_Contract__c(
            EUR_CRM_Account__c = accId
        ,   RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Quality__c makeBrandQuality(String productName) {
        return new EUR_CRM_Quality__c(
            Name = productName
        );
    }

    private static EUR_CRM_Contract_Listing_Pouring__c makeContractListingPouring(Id contractId, Id bqId) {
        return new EUR_CRM_Contract_Listing_Pouring__c(
            EUR_CRM_Contract__c = contractId
        ,   EUR_CRM_Brand_Quality__c = bqId
        );
    }

    private static EUR_CRM_Contract_Activity_Item__c makeContractActivityItem(Id contractId, Id mechanicTypeId) {
        return new EUR_CRM_Contract_Activity_Item__c(
            EUR_CRM_Contract__c = contractId
        ,   EUR_CRM_Mechanic_Type__c = mechanicTypeId
        );
    }

    private static EUR_CRM_Contract_Product_Item__c makeContractProductItem(Id caiId, Id bqId) {
        return new EUR_CRM_Contract_Product_Item__c(
            EUR_CRM_Contract_Activity_Item__c = caiId
        ,   EUR_CRM_Brand_Quality__c = bqId
        );
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static List<EUR_CRM_Contract_Activity_Item__c> selectContractActivityItems(Set<Id> contractIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Mechanic_Type__r.Name
            ,   (
                SELECT Id
                ,   EUR_CRM_Brand_Quality__c
                FROM Contract_Product_Items__r
            )
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__c IN :contractIds
        ];
    }

    private static EUR_CRM_Mechanic_Type__c selectMechanicTypeWhereExternalId(String externalId) {
        return [
            SELECT Id
            FROM EUR_CRM_Mechanic_Type__c
            WHERE EUR_CRM_External_ID__c = :externalId
            LIMIT 1
        ][0];
    }

}