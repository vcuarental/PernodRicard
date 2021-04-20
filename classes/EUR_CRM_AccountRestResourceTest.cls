@IsTest(IsParallel = true)
private class EUR_CRM_AccountRestResourceTest {

	private static final String ACCOUNT_RT = 'EUR_DK_On_Trade';
	private static final String BAD_ACCOUNT_ID = 'badAccountId';

	private static final String ACC_ERP_NUMBER = 'ACC_ERP_NUMBER';

	//doGet
	@IsTest
	private static void doGet_AccountExists_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		request.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/accounts/'+acc.Id;
		request.httpMethod = 'GET';

		RestContext.request = request;
		RestContext.response = response;

		//Assertion before
		System.assertEquals(1, selectAccounts().size());
		Test.startTest();
		EUR_CRM_AccountRestResource.doGet();
		Test.stopTest();

		EUR_CRM_AccountRestResource.AccountResource accResourceResponse = (EUR_CRM_AccountRestResource.AccountResource) JSON.deserialize(RestContext.response.responseBody.toString(), EUR_CRM_AccountRestResource.AccountResource.class);

		//Assertion after
		System.assertEquals(acc.Id, accResourceResponse.AccountId);
	}

	@IsTest
	private static void doGet_AccountNotFound_ReturnError_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		request.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/accounts/'+BAD_ACCOUNT_ID;
		request.httpMethod = 'GET';

		RestContext.request = request;
		RestContext.response = response;

		//Assertion before
		System.assertEquals(1, selectAccounts().size());

		Test.startTest();
		EUR_CRM_AccountRestResource.doGet();
		Test.stopTest();

		//Assertion after
		System.debug('\n RestContext.response.responseBody.toString() => ' + RestContext.response.responseBody.toString() + '\n');
		System.assertEquals(EUR_CRM_AccountRestResource.CAN_NOT_FIND_EUR_CRM_ACCOUNT_C_WITH_ID + BAD_ACCOUNT_ID, RestContext.response.responseBody.toString());
	}

	//doPut
	@IsTest
	private static void doPut_AccountExists_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_AccountRestResource.AccountResource accResource = new EUR_CRM_AccountRestResource.AccountResource();
		accResource.AccountERPNumber = ACC_ERP_NUMBER;

		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		request.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/accounts/'+acc.Id;
		request.httpMethod = 'PUT';
		request.requestBody = Blob.valueOf(JSON.serializePretty(accResource));

		RestContext.request = request;
		RestContext.response = response;

		//Assertion before
		List<EUR_CRM_Account__c> accsBeforeUpdate = selectAccounts();
		System.assertEquals(1, accsBeforeUpdate.size());
		System.assertEquals(null, accsBeforeUpdate[0].EUR_CRM_Customer_No_ERP__c);

		Test.startTest();
		EUR_CRM_AccountRestResource.doPut();
		Test.stopTest();

		EUR_CRM_AccountRestResource.AccountResource accResourceResponse = (EUR_CRM_AccountRestResource.AccountResource) JSON.deserialize(RestContext.response.responseBody.toString(), EUR_CRM_AccountRestResource.AccountResource.class);

		List<EUR_CRM_Account__c> accsAfterUpdate = selectAccounts();
		//Assertion after
		System.assertEquals(1, accsAfterUpdate.size());
		System.assertEquals(ACC_ERP_NUMBER, accsAfterUpdate[0].EUR_CRM_Customer_No_ERP__c);

		System.assertEquals(acc.Id, accResourceResponse.AccountId);
		System.assertEquals(ACC_ERP_NUMBER, accResourceResponse.AccountERPNumber);
	}

	@IsTest
	private static void doPut_AccountNotFound_ReturnError_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_AccountRestResource.AccountResource accResource = new EUR_CRM_AccountRestResource.AccountResource();
		accResource.AccountERPNumber = ACC_ERP_NUMBER;

		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		request.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/accounts/' + BAD_ACCOUNT_ID;
		request.httpMethod = 'PUT';
		request.requestBody = Blob.valueOf(JSON.serializePretty(accResource));

		RestContext.request = request;
		RestContext.response = response;

		//Assertion before
		List<EUR_CRM_Account__c> accsBeforeUpdate = selectAccounts();
		System.assertEquals(1, accsBeforeUpdate.size());
		System.assertEquals(null, accsBeforeUpdate[0].EUR_CRM_Customer_No_ERP__c);

		Test.startTest();
		EUR_CRM_AccountRestResource.doPut();
		Test.stopTest();


		List<EUR_CRM_Account__c> accsAfterUpdate = selectAccounts();
		//Assertion after
		System.assertEquals(EUR_CRM_AccountRestResource.CAN_NOT_FIND_EUR_CRM_ACCOUNT_C_WITH_ID + BAD_ACCOUNT_ID, RestContext.response.responseBody.toString());

		System.assertEquals(1, accsAfterUpdate.size());
		System.assertEquals(null, accsAfterUpdate[0].EUR_CRM_Customer_No_ERP__c);

	}


	//Makers
	private static EUR_CRM_Account__c makeAccount() {
		Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RT).getRecordTypeId();

		EUR_CRM_Account__c account = new EUR_CRM_Account__c();
		account.RecordTypeId = recordTypeId;
		account.EUR_CRM_Postal_Code__c = '112233';
		return account;
	}


	//Selectors
	public static List<EUR_CRM_Account__c> selectAccounts() {
		return [
			SELECT Id
				,   Name
				,   EUR_CRM_Company_Name__c
				,   EUR_CRM_Customer_No__c
				,   EUR_CRM_Status__c
				,   EUR_CRM_Customer_No_ERP__c
				,   EUR_CRM_Delivery_Type__c
				,   EUR_CRM_Street__c
				,   EUR_CRM_Postal_Code__c
				,   EUR_CRM_City__c
				,   EUR_CRM_Delivery_Contact_Phone__c
				,   EUR_CRM_Country_Code__c
				,   EUR_CRM_ERPSoldToAccount__r.EUR_CRM_Customer_No_ERP__c
				,   EUR_CRM_Customer_Ship_To_No_ERP__c
				,   EUR_CRM_General_Language__c
				,   EUR_CRM_Fax_No__c
			FROM EUR_CRM_Account__c
		];
	}

}