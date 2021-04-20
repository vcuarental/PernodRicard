@isTest
private class LAT_BR_VFP31_NovoCadastroOverrideTest {
	
	@isTest static void test_method_one() {
		test.setCurrentPageReference(new pageReference('Page.LAT_BR_VFP31_NovoCadastroOverride'));
		System.currentPageReference().getParameters().put('id', 'random');
		LAT_BR_VFP_31_NovoCadastroOverride controller = new LAT_BR_VFP_31_NovoCadastroOverride();
		controller.authorized();

	}
	
	
}