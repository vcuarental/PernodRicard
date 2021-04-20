@isTest
private class LAT_MX_MetodosRFC_Test {
	
	@isTest static void ValidationCNPJduplicateTest() {
		test.startTest();
				List<LAT_MX_RFC__c> rfcList = createRFC();
				LAT_MX_MetodosRFC.ValidationCNPJduplicate(rfcList);

		test.stopTest();
	}
	
	@isTest static void ValidationRFCTestMal() {
		test.startTest();
			LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
			rfc.LAT_RFC__c = 'sd';
			rfc.name = '123456789112';
			List<LAT_MX_RFC__c> rfcList = new List<LAT_MX_RFC__c>();
			rfcList.add(rfc);
			LAT_MX_MetodosRFC.ValidationRFC(rfcList);
		test.stopTest();
	}
	@isTest static void ValidationRFCTestBien() {
		test.startTest();
				List<LAT_MX_RFC__c> rfcList = createRFC();
				LAT_MX_MetodosRFC.ValidationRFC(rfcList);
		test.stopTest();
	}

	public static List<LAT_MX_RFC__c> createRFC () {
		LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
		rfc.LAT_RFC__c = 'OEP890111G75';
		rfc.name = 'abc';
		insert rfc;
		List<LAT_MX_RFC__c> rfcList = new List<LAT_MX_RFC__c>();
		rfcList.add(rfc);
		return rfcList;
	} 
}