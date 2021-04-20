@RestResource(UrlMapping = '/accounts/*')
global with sharing class EUR_CRM_AccountRestResource {


	@TestVisible private static final String CAN_NOT_FIND_EUR_CRM_ACCOUNT_C_WITH_ID = 'Can not find EUR_CRM_Account__c with Id: ';


	// /services/apexrest/accounts/
	@HttpGet
	global static void doGet() {
		String accId = getFirstParamFromUri();
		List<EUR_CRM_Account__c> accs = selectAccountWhereId(accId);
		if (accs.isEmpty()) {
			setResponse(404, CAN_NOT_FIND_EUR_CRM_ACCOUNT_C_WITH_ID + accId);
			return;
		}
		setResponse(200, JSON.serializePretty(new AccountResource(accs[0])));
	}

	@HttpPut
	global static void doPut() {
		String accId = getFirstParamFromUri();

		List<EUR_CRM_Account__c> accs = selectAccountWhereId(accId);
		if (accs.isEmpty()) {
			setResponse(404, CAN_NOT_FIND_EUR_CRM_ACCOUNT_C_WITH_ID + accId);
			return;
		}

		updateAccountFields(accs[0], getAccResourceFromRequest());
		update accs[0];
		setResponse(200, JSON.serializePretty(new AccountResource(accs[0])));
	}


	//High level helpers


	//Middle level helpers
	private static AccountResource getAccResourceFromRequest() {
		return (AccountResource)JSON.deserialize(RestContext.request.requestBody.toString(), AccountResource.class);
	}

	private static String getFirstParamFromUri() {
		return RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/') + 1);
	}

	private static void setResponse(Integer statusCode, String body) {
		RestContext.response.statusCode = statusCode;
		RestContext.response.responseBody = Blob.valueOf(body);
	}

	private static void updateAccountFields(EUR_CRM_Account__c acc, AccountResource accRes) {
		acc.EUR_CRM_Customer_No_ERP__c = accRes.AccountERPNumber;
	}


	//Selectors
	public static List<EUR_CRM_Account__c> selectAccountWhereId(String accId) {
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
			WHERE Id = :accId ];
	}

	public class AccountResource {

		public String AccountId;
		public String AccountNumber;
		public String AccountName;
		public String AccountCompanyName;
		public String AccountERPNumber;
		public String AccountShipTo;
		public String AccountSoldTo;
		public String AccountStatus;
		public String DeliveryType;
		public String ShippingStreet;
		public String ShippingCity;
		public String ShippingPostalCode;
		public String ShippingContactPhone;
		public String ShippingFaxNumber;
		public String Affiliate;
		public String Language;
		public String BillingAddressType;

		public AccountResource() {}

		public AccountResource(EUR_CRM_Account__c acc) {
			this.AccountId = acc.Id;
			this.AccountName = acc.Name;
			this.AccountCompanyName = acc.EUR_CRM_Company_Name__c;
			this.AccountNumber = acc.EUR_CRM_Customer_No__c;
			this.AccountStatus = acc.EUR_CRM_Status__c;
			this.AccountERPNumber = acc.EUR_CRM_Customer_No_ERP__c;
			this.AccountShipTo = acc.EUR_CRM_Customer_Ship_To_No_ERP__c;
			this.AccountSoldTo = acc.EUR_CRM_ERPSoldToAccount__r.EUR_CRM_Customer_No_ERP__c;
			this.DeliveryType = acc.EUR_CRM_Delivery_Type__c;
			this.ShippingStreet = acc.EUR_CRM_Street__c;
			this.ShippingPostalCode = acc.EUR_CRM_Postal_Code__c;
			this.ShippingCity = acc.EUR_CRM_City__c;
			this.ShippingContactPhone = acc.EUR_CRM_Delivery_Contact_Phone__c;
			this.Affiliate = acc.EUR_CRM_Country_Code__c;
			this.Language = acc.EUR_CRM_General_Language__c;
			this.ShippingFaxNumber = acc.EUR_CRM_Fax_No__c;
			this.BillingAddressType = 'Ship to Account'; // new field to add.
		}

	}

}