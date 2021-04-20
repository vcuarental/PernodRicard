public with sharing class EUR_CRM_AdminConsoleLwcController {

	@AuraEnabled
	public static Integer countAccountsToForceEmptyPVA(String countryCode) {
		Integer count = new EUR_CRM_AccountEmptyPVABatch(countryCode).countAccountsToUpdateField();
		System.debug('\n count => ' + count + '\n');
		return count;
	}

	@AuraEnabled
	public static String runUpdateAccountsForceEmptyPVA(String countryCode) {
		return new EUR_CRM_AccountEmptyPVABatch(countryCode).run();
	}

}