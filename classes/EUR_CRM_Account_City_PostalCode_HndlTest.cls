/*
    @Description: Test class for EUR_CRM_Account_City_PostalCode_Handler
 */
@IsTest
private class EUR_CRM_Account_City_PostalCode_HndlTest {
    private static final String POSTALCODE1 = '12345';
    private static final String POSTALCODE2 = '54321';
    private static final String CITYNAME1 = 'Test City1';
    private static final String CITYNAME2 = 'Test City2';

    private static final String POSTAL_CODE_TERRITORY_DE_OFF_TRADE_RECORD_TYPE = 'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping';
    private static final String TERRITORY_DE_RECORD_TYPE = 'EUR_DE_Territory';
    private static final String REGION_DE_RECORD_TYPE = 'EUR_DE_Region';
    private static final String OFF_TRADE = 'OFF TRADE';
    private static final String ON_TRADE = 'ON TRADE';
    private static Map<String, String> validAccountPostalCodeRecordTypes = EUR_CRM_Account_City_PostalCode_Handler.postalCodeRTDevNameByValidAccountRTDevName;

    private static List<RecordType> validAccountRecordTypesList = selectRecordTypesBySobjectAndDeveloperName('EUR_CRM_Account__c', validAccountPostalCodeRecordTypes.keySet());
    private static List<RecordType> validPostalCodeRecordTypesList = selectRecordTypesBySobjectAndDeveloperName ('EUR_CRM_Postal_Code_City_Mapping__c', validAccountPostalCodeRecordTypes.values());

    @TestSetup
    static void dataSetup() {
        List<EUR_CRM_Postal_Code_City_Mapping__c> postalCodeCityMappings = new List<EUR_CRM_Postal_Code_City_Mapping__c>();
        postalCodeCityMappings.add(makePostalCodeCityMaping(CITYNAME1, POSTALCODE1, CITYNAME1, validPostalCodeRecordTypesList[0].Id));
        postalCodeCityMappings.add(makePostalCodeCityMaping(CITYNAME2, POSTALCODE2, CITYNAME2, validPostalCodeRecordTypesList[0].Id));

        EUR_CRM_Region__c offTradeRegion = makeRegionAndInsert('Test Off Trade Region', OFF_TRADE);
        EUR_CRM_Region__c onTradeRegion = makeRegionAndInsert('Test On Trade Region', OFF_TRADE);
        EUR_CRM_Territory__c offTradeTerritory = makeTerritoryAndInsert('Test Off Trade Territory', offTradeRegion.Id);
        EUR_CRM_Territory__c onTradeTerritory = makeTerritoryAndInsert('Test On Trade Territory', onTradeRegion.Id);
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryOffTrade1 = makePostalCodeTerritoryMapingAndInsert('Test Off Trade Postal Code Territory 1', POSTALCODE1, CITYNAME1, offTradeTerritory.Id);
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryOffTrade2 = makePostalCodeTerritoryMapingAndInsert('Test Off Trade Postal Code Territory 2', POSTALCODE2, CITYNAME2, offTradeTerritory.Id);

        List<EUR_CRM_Account__c> accounts = makeAccountForAllValidAccountsRecordTypesList();
        System.debug('\n accounts => ' + JSON.serializePretty(accounts) + '\n');
        System.debug('\n postalCodeCityMappings => ' + JSON.serializePretty(postalCodeCityMappings) + '\n');


        insert postalCodeCityMappings;
        insert accounts;
    }


    @IsTest
    static void testPositiveBeforeInsert() {
        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        for (EUR_CRM_Account__c acc : insertedAccounts) {
            System.assertEquals(CITYNAME1, acc.EUR_CRM_City__c);
        }
    }

    @IsTest
    static void testPositiveBeforeUpdate() {
        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        List<EUR_CRM_Account__c> accountsForUpdate = new List<EUR_CRM_Account__c>();

        for (EUR_CRM_Account__c acc : insertedAccounts) {
            acc.EUR_CRM_Postal_Code__c = POSTALCODE2;
//            acc.EUR_CRM_Channel__c = ON_TRADE;
            accountsForUpdate.add(acc);
        }
        Test.startTest();
        update accountsForUpdate;

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        for (EUR_CRM_Account__c acc : updatedAccounts) {
            System.debug('testBeforeInsert acc => ' + JSON.serializePretty(acc));
            System.assertEquals(CITYNAME2, acc.EUR_CRM_City__c);
        }
        Test.stopTest();
    }

    @IsTest
    static void deleteAccounts(){
        Test.startTest();
        delete selectAccounts();
        Test.stopTest();
    }


    /*==============================
    * Low Level Helpers
    * ==============================*/


    private static Map<String, EUR_CRM_Account__c> getCityAccountsMap(List<EUR_CRM_Account__c> accountList) {
        Map<String, EUR_CRM_Account__c> cityAccountsMap = new Map<String, EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accountList) {
            if (!cityAccountsMap.containsKey(acc.EUR_CRM_City__c)) {
                cityAccountsMap.put(acc.EUR_CRM_City__c, acc);
            }
        }
        return cityAccountsMap;
    }


    /*==============================
    * Makers
    * ==============================*/

    private static List<EUR_CRM_Account__c> makeAccountForAllValidAccountsRecordTypesList() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (RecordType accRecordType : validAccountRecordTypesList) {
            if (accounts.size() == 5) { break; }
            EUR_CRM_Account__c a = makeAccount('Test', POSTALCODE1, accRecordType.Id, OFF_TRADE);
            accounts.add(a);
        }
        return accounts;
    }

    private static EUR_CRM_Postal_Code_City_Mapping__c makePostalCodeCityMaping(String recordName, String postalCode, String cityName, Id recordTypeId) {
        EUR_CRM_Postal_Code_City_Mapping__c postalCodeCityMapping = new EUR_CRM_Postal_Code_City_Mapping__c(
            Name = recordName,
            EUR_CRM_Postal_Code__c = postalCode,
            EUR_CRM_City__c = cityName,
            RecordTypeId = recordTypeId
        );
        return postalCodeCityMapping;
    }


    private static EUR_CRM_Account__c makeAccount(String recordName, String postalCode, Id recTypeId, String channel) {
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
            RecordTypeId = recTypeId,
            Name = recordName,
            EUR_CRM_Postal_Code__c = postalCode,
            EUR_CRM_Channel__c = channel
        );
        return euAccount;
    }

    private static EUR_CRM_Territory__c makeTerritoryAndInsert(String territoryName, Id regionId) {
        Id recordTypeId = selectRecordTypeIdByName('EUR_CRM_Territory__c', TERRITORY_DE_RECORD_TYPE);
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(
            Name = territoryName,
            EUR_CRM_Region__c = regionId,
            RecordTypeId = recordTypeId,
            EUR_CRM_Territory_Owner__c = UserInfo.getUserId()
        );
        insert territory;
        return territory;
    }

    private static EUR_CRM_Region__c makeRegionAndInsert(String regionName, String channel) {
        Id recordTypeId = selectRecordTypeIdByName('EUR_CRM_Region__c', REGION_DE_RECORD_TYPE);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(
            Name = regionName,
            RecordTypeId = recordTypeId,
            EUR_CRM_Channel__c = channel
        );
        insert region;
        return region;
    }

    private static EUR_CRM_Postal_Code_Territory_Mapping__c makePostalCodeTerritoryMapingAndInsert(String recordName, String postalCode, String cityName, Id territoryId) {
        Id recordTypeId = selectRecordTypeIdByName('EUR_CRM_Postal_Code_Territory_Mapping__c', POSTAL_CODE_TERRITORY_DE_OFF_TRADE_RECORD_TYPE);
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c(
            Name = recordName,
            EUR_CRM_Postal_Code__c = postalCode,
            EUR_CRM_City__c = cityName,
            EUR_CRM_Territory__c = territoryId,
            RecordTypeId = recordTypeId
        );
        insert postalCodeTerritoryMapping;
        return postalCodeTerritoryMapping;
    }


    /*==============================
    * SOQL Selectors
    * ==============================*/

    private static Id selectRecordTypeIdByName(String sobjectName, String name) {
        return [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = :sobjectName
            AND DeveloperName = :name
            LIMIT 1
        ].Id;
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
                , EUR_CRM_City__c
                , EUR_CRM_Postal_Code__c
                , RecordType.DeveloperName
                , EUR_CRM_Channel__c
                , EUR_CRM_Territory__c
            FROM EUR_CRM_Account__c
            ORDER BY EUR_CRM_City__c
        ];
    }

    private static List<RecordType> selectRecordTypesBySobjectAndDeveloperName(String sobjectName, List<String> developerNames) {
        return [
            SELECT Id, DeveloperName
            FROM Recordtype
            WHERE SobjectType = :sobjectName
            AND DeveloperName IN :developerNames
        ];
    }

    private static List<RecordType> selectRecordTypesBySobjectAndDeveloperName(String sobjectName, Set<String> developerNames) {
        return [
            SELECT Id, DeveloperName
            FROM Recordtype
            WHERE SobjectType = :sobjectName
            AND DeveloperName IN :developerNames
        ];
    }
}