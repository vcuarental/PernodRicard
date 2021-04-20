/*
	RMS - Route To Market Spirits
	RMC - Route To Market Champagne

*/

@IsTest(IsParallel = true)
private class EUR_CRM_AccountToOutletSupplMapBatchTest {

	private static final Set<String> ACC_GB_RTS = new Set<String> {
		'EUR_GB_FS_Blitz'
	,	'EUR_GB_FS_Indirect'
	,	'EUR_GB_FS_RTM'
	};

	private static final String PRIMARY = 'Primary';
	private static final String SECONDARY = 'Secondary';

	private static final String GB_OSM_RT = 'EUR_GB_Outlet_to_Supplier_Mapping';

	@IsTest
	private static void allRoutesIsDifferent_ValidCountryCode_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(4, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(4, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void allRoutesIsDifferent_ValidCountryCode_Second_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_RTM');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(4, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(4, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void allRoutesIsDifferent_InvalidCountryCode_NegativeTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_IT_Enoteca_Account');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_IT_Enoteca_Account');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_IT_Enoteca_Account');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_IT_Enoteca_Account');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_IT_Enoteca_Account');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('IT', acc.EUR_CRM_Country_Code__c);
		}

		System.assert(insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		System.assert(osmBySupplierAcc.isEmpty());
	}

	@IsTest
	private static void noRoutesFilled_NegativeTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_RTM');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = null;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = null;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = null;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = null;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(0, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();

		System.assert(osmBySupplierAcc.isEmpty());
	}

	@IsTest
	private static void oneRoutFilled_ValidCountryCode_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = null;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = null;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = null;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(2, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(1, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(1, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoRoutFilled_ValidCountryCode_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = null;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = null;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(3, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(2, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(2, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void threeRoutFilled_ValidCountryCode_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 , supplier3 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = null;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(4, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(3, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(3, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void fourRoutFilled_ValidCountryCode_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 , supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(4, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(4, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoRoutesDifferentAndTwoRoutesEqual_First_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(4, insertedAccById.values().size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(3, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(3, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoRoutesDifferentAndTwoRoutesEqual_Second_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier1.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(4, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(3, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(3, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoRoutesDifferentAndTwoRoutesEqual_Third_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier1.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(4, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(3, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(3, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoEqualsPairsOfRoutes_First_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier2.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier2.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(3, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(2, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(2, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoEqualsPairsOfRoutes_Second_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier1.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier2.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(3, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(2, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(2, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoEqualsPairsOfRoutes_Third_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier2.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier1.Id;
		insert outlet;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(3, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(2, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(2, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
	}

	/* ========================================================= */
	/*      Tests for Accounts with existing OSM
	/* ========================================================= */

	@IsTest
	private static void twoEqualsPairsOfRoutes_oneOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier2.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier1.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM.EUR_CRM_Supplier_Account__c = supplier1.Id;
		insert outletOSM;

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(1, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());
		System.debug('\n insertedAccByIdBeforeBatch.size() => ' + insertedAccByIdBeforeBatch.size() + '\n');
		System.debug('\n insertedAccByIdBeforeBatch => ' + JSON.serializePretty(insertedAccByIdBeforeBatch) + '\n');

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(3, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(2, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(2, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoEqualsPairsOfRoutes_twoOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier2.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier1.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM1 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM1.EUR_CRM_Supplier_Account__c = supplier1.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM2 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM2.EUR_CRM_Supplier_Account__c = supplier2.Id;
		insert new List<EUR_CRM_Outlet_to_Supplier_Mapping__c >{ outletOSM1, outletOSM2 };

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(2, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());
		System.debug('\n insertedAccByIdBeforeBatch.size() => ' + insertedAccByIdBeforeBatch.size() + '\n');
		System.debug('\n insertedAccByIdBeforeBatch => ' + JSON.serializePretty(insertedAccByIdBeforeBatch) + '\n');

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(3, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(2, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(2, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoRoutesDifferentAndTwoRoutesEqual_oneOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier1.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM.EUR_CRM_Supplier_Account__c = supplier1.Id;
		insert outletOSM;

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(1, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(4, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(3, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(3, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoRoutesDifferentAndTwoRoutesEqual_twoOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier1.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM1 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM1.EUR_CRM_Supplier_Account__c = supplier1.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM2 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM2.EUR_CRM_Supplier_Account__c = supplier2.Id;
		insert new List<EUR_CRM_Outlet_to_Supplier_Mapping__c >{ outletOSM1, outletOSM2 };

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(2, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(4, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(3, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(3, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void twoRoutesDifferentAndTwoRoutesEqual_threeOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier1.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM1 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM1.EUR_CRM_Supplier_Account__c = supplier1.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM2 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM2.EUR_CRM_Supplier_Account__c = supplier2.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM3 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM3.EUR_CRM_Supplier_Account__c = supplier3.Id;
		insert new List<EUR_CRM_Outlet_to_Supplier_Mapping__c >{ outletOSM1, outletOSM2, outletOSM3 };

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(3, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(4, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(3, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(3, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void allRoutesIsDifferent_oneOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM.EUR_CRM_Supplier_Account__c = supplier1.Id;
		insert outletOSM;

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(1, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(4, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(4, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void allRoutesIsDifferent_twoOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM1 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM1.EUR_CRM_Supplier_Account__c = supplier1.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM2 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM2.EUR_CRM_Supplier_Account__c = supplier2.Id;
		insert new List<EUR_CRM_Outlet_to_Supplier_Mapping__c >{ outletOSM1, outletOSM2 };

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(2, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(4, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(4, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(PRIMARY, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void allRoutesIsDifferent_threeOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM1 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM1.EUR_CRM_Supplier_Account__c = supplier1.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM2 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM2.EUR_CRM_Supplier_Account__c = supplier2.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM3 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM3.EUR_CRM_Supplier_Account__c = supplier3.Id;
		insert new List<EUR_CRM_Outlet_to_Supplier_Mapping__c >{ outletOSM1, outletOSM2, outletOSM3 };

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(3, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(4, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(4, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(SECONDARY, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}

	@IsTest
	private static void allRoutesIsDifferent_fourOsmExist_PositiveTest() {
		EUR_CRM_Account__c supplier1 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier2 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier3 = makeAccount('EUR_GB_FS_RTM');
		EUR_CRM_Account__c supplier4 = makeAccount('EUR_GB_FS_RTM');
		insert new List<EUR_CRM_Account__c>{ supplier1, supplier2, supplier3, supplier4 };

		EUR_CRM_Account__c outlet = makeAccount('EUR_GB_FS_Indirect');
		outlet.EUR_CRM_Primary_Route_to_Market_Spirits__c = supplier1.Id;
		outlet.EUR_GB_Secondary_Route_to_Market_Spirits__c = supplier2.Id;
		outlet.EUR_CRM_Primary_Route_to_Market_Champa__c = supplier3.Id;
		outlet.EUR_CRM_Secondary_Route_to_Market_Cham__c = supplier4.Id;
		insert outlet;

		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM1 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM1.EUR_CRM_Supplier_Account__c = supplier1.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM2 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM2.EUR_CRM_Supplier_Account__c = supplier2.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM3 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM3.EUR_CRM_Supplier_Account__c = supplier3.Id;
		EUR_CRM_Outlet_to_Supplier_Mapping__c outletOSM4 = makeOSM(outlet.Id, 'EUR_GB_Outlet_to_Supplier_Mapping');
		outletOSM4.EUR_CRM_Supplier_Account__c = supplier4.Id;
		insert new List<EUR_CRM_Outlet_to_Supplier_Mapping__c >{ outletOSM1, outletOSM2, outletOSM3, outletOSM4 };

		Map<Id, EUR_CRM_Account__c> insertedAccByIdBeforeBatch = selectAccounts();
		System.assertEquals(4, insertedAccByIdBeforeBatch.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountToOutletSupplMapBatch());
		Test.stopTest();

		Map<Id, EUR_CRM_Account__c> insertedAccById = selectAccounts();
		System.assertEquals(5, insertedAccById.size());
		for (EUR_CRM_Account__c acc : insertedAccById.values()) {
			System.assertEquals('GB', acc.EUR_CRM_Country_Code__c);
		}

		System.assertEquals(4, insertedAccById.get(outlet.Id).Outlet_to_Supplier_Mappings1__r.size());

		System.assert(insertedAccById.get(supplier1.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier2.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier3.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());
		System.assert(insertedAccById.get(supplier4.Id).Outlet_to_Supplier_Mappings1__r.isEmpty());

		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = getOSMBySupplierAcc();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osmBySupplierAcc.values()) {
			System.assertEquals(GB_OSM_RT, osm.RecordType.DeveloperName);
		}

		System.assertEquals(4, osmBySupplierAcc.size());
		System.assertEquals(supplier1.Id, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier2.Id, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier3.Id, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(supplier4.Id, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Supplier_Account__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier1.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier2.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier3.Id).EUR_CRM_Champagne_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Spirit_Type__c);
		System.assertEquals(null, osmBySupplierAcc.get(supplier4.Id).EUR_CRM_Champagne_Type__c);
	}




	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private static Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> getOSMBySupplierAcc() {
		List<EUR_CRM_Outlet_to_Supplier_Mapping__c> osms = selectOSMs();
		Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c> osmBySupplierAcc = new Map<Id, EUR_CRM_Outlet_to_Supplier_Mapping__c>();
		for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : osms) {
			osmBySupplierAcc.put(osm.EUR_CRM_Supplier_Account__c, osm);
		}
		return osmBySupplierAcc;
	}

	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			EUR_CRM_Postal_Code__c = '12345'
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Outlet_to_Supplier_Mapping__c makeOSM(Id outletId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Outlet_to_Supplier_Mapping__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Outlet_to_Supplier_Mapping__c(
			EUR_CRM_Outlet_Account__c = outletId
		,	RecordTypeId = rtId
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static Map<Id, EUR_CRM_Account__c> selectAccounts() {
		return new Map<Id, EUR_CRM_Account__c>([
			SELECT Id
			,	EUR_CRM_Primary_Route_to_Market_Spirits__c
			,	EUR_CRM_Primary_Route_to_Market_Champa__c
			,	EUR_GB_Secondary_Route_to_Market_Spirits__c
			,	EUR_CRM_Secondary_Route_to_Market_Cham__c
			,	EUR_CRM_Country_Code__c
			,	(
				SELECT
					EUR_CRM_Outlet_Account__c
				,	EUR_CRM_Supplier_Account__c
				,	EUR_CRM_Spirit_Type__c
				,	EUR_CRM_Champagne_Type__c
				FROM Outlet_to_Supplier_Mappings1__r
			)
			FROM EUR_CRM_Account__c
		]);
	}

	private static List<EUR_CRM_Outlet_to_Supplier_Mapping__c> selectOSMs() {
		return [
			SELECT Id
			,	RecordType.DeveloperName
			,	EUR_CRM_Outlet_Account__c
			,	EUR_CRM_Supplier_Account__c
			,	EUR_CRM_Spirit_Type__c
			,	EUR_CRM_Champagne_Type__c
			FROM EUR_CRM_Outlet_to_Supplier_Mapping__c
		];
	}
}