@isTest
private class LAT_GeneralConfigDaoTest {

	static void setUp() {
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
			name = 'MY_TEST_STRINGARRAY_1',
			lat_value__c = 'a;b;c');
		insert cfg;
	}
	
	@isTest static void testGetValueAsStringArray() {

		setUp();

		// send the correct separator
		String[] data = LAT_GeneralConfigDao.getValueAsStringArray('MY_TEST_STRINGARRAY_1',';');
		System.assertEquals(data.size(), 3);
		System.assertEquals('a', data[0]);
		System.assertEquals('b', data[1]);
		System.assertEquals('c', data[2]);

		Set<String> asSet = LAT_GeneralConfigDao.getValueAsStringSet('MY_TEST_STRINGARRAY_1',';', false);
		System.assertEquals(asSet.size(), 3);
		System.assertEquals(true, asSet.contains('b'));

		// with other separator
		data = LAT_GeneralConfigDao.getValueAsStringArray('MY_TEST_STRINGARRAY_1','-');
		System.assertEquals(data.size(), 1);
		System.assertEquals('a;b;c', data[0]);

		data = LAT_GeneralConfigDao.getValueAsStringArray('XXXXX','@');
		System.assertEquals(null, data);

		data = LAT_GeneralConfigDao.getValueAsStringArray('XXXXX','@', true);
		System.assertEquals(0, data.size());


		asSet = LAT_GeneralConfigDao.getValueAsStringSet('XXXXX',';', false);
		System.assertEquals(null, asSet);

		asSet = LAT_GeneralConfigDao.getValueAsStringSet('XXXXX',';', true);
		System.assertEquals(0, asSet.size());

	}
	

}