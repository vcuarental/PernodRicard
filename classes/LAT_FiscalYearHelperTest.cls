@isTest
private class LAT_FiscalYearHelperTest {
	
	@isTest static void test_method_one() {

		LAT_FiscalYearHelper fyh = LAT_FiscalYearHelper.getInstance();
		Integer i = fyh.getFiscalYear(Date.today());
		String s =  fyh.getFiscalYearCode(Date.today());

	}

	
}