@isTest
private class LAT_QueriesCacheHelper_Test {
	
	@isTest static void test_method_one() {
		LAT_QueriesCacheHelper.getUDC_List_By_CodProd_CodUs_RT('Test', 'Test', 'Test');
		LAT_QueriesCacheHelper.getUDC_List_By_CodProd_CodUs_RT_Name('Test', 'Test', 'Test', new List<String> {'test'});
		LAT_QueriesCacheHelper.getUDC_List_By_Ids(new List<String> {'test'});
		LAT_QueriesCacheHelper.getUDC_List_By_Ids_RT(new List<String> {'test'}, 'Test');
	}
	
}