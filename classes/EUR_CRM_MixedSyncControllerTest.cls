@IsTest
private with sharing class EUR_CRM_MixedSyncControllerTest {

	@IsTest
	private static void runScript_Test() {
		insert makeApplicationSetup();

		List<clm__ApplicationSetup__c> applicationSetupsBefore = EUR_CRM_MixedSyncController.selectApplicationSetups();
		System.assertEquals(false, applicationSetupsBefore.isEmpty());
		for(clm__ApplicationSetup__c s : applicationSetupsBefore) {
			System.assertNotEquals(null, s.clm__MetadataLastModifiedDate__c);
		}

		Test.startTest();
		String response = EUR_CRM_MixedSyncController.runScript();
		Test.stopTest();

		System.assertEquals('Success', response);

		List<clm__ApplicationSetup__c> applicationSetupsAfter = EUR_CRM_MixedSyncController.selectApplicationSetups();
		System.assertEquals(false, applicationSetupsAfter.isEmpty());
		for(clm__ApplicationSetup__c s : applicationSetupsAfter) {
			System.assertEquals(null, s.clm__MetadataLastModifiedDate__c);
		}
	}

	@IsTest
	private static void isValidCronTriggersExists_Test() {
		String min = String.valueOf(Datetime.now().addMinutes(2).minute());
		String hours = String.valueOf(Datetime.now().addHours(1).hour());
		String nextFireTime = '0 ' + min + ' ' + hours + ' * * ?';
		EUR_CRM_MixedSyncController controller = new EUR_CRM_MixedSyncController();
		System.schedule(EUR_CRM_MixedSyncController.PACKAGE_SCHEDULERS_NAME_TEMPLATE, nextFireTime, controller);

		Test.startTest();
		System.assertEquals(true, controller.isNeedToRunChecker());
		Test.stopTest();

	}

	private static clm__ApplicationSetup__c makeApplicationSetup() {
		return new clm__ApplicationSetup__c (
			clm__MetadataLastModifiedDate__c = System.now()
		);
	}
}