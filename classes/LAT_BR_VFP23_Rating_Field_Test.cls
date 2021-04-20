@isTest
private class LAT_BR_VFP23_Rating_Field_Test {
	
	static testMethod void test1() {

		Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert acc;

		ApexPages.StandardController sc = new ApexPages.StandardController(acc); 

		LAT_BR_VFP23_Rating_Field controller = new LAT_BR_VFP23_Rating_Field(sc);

		controller.saveCliente();

		LAT_BR_VFP23_HighEnd_Field controller2 = new LAT_BR_VFP23_HighEnd_Field(sc);
		controller2.saveCliente();
		Utils.setMigrationDoneTest(true);
		LAT_BR_VFP23_HighEnd_Field controller3 = new LAT_BR_VFP23_HighEnd_Field(sc);
		controller3.saveCliente();

	}
	
	
	
}