/**
 * Name 	:	GDT_ManageLicense_Controller_Purchase.cls
 * 	VFP, GDT_ManageLicense_Administration.page
 * 	Objet, GDT_ManageLicense_Purchase__c
 * 
 * Author	:	Simon GAZIN
 * Date 	:	11.03.2015
 ***************************************************************/
public with sharing class GDT_ManageLicense_Controller_Purchase {

	/** Standard Controller */
	public final GDT_ManageLicense_Purchase__c mysObject;

	//The extension constructor initializes the private member
	//variable mysObject by using the getRecord method from the standard
	//controller.
	public GDT_ManageLicense_Controller_Purchase(ApexPages.StandardController stdController) {
		this.mysObject = (GDT_ManageLicense_Purchase__c)stdController.getRecord();
	}

	/** Retrieves the purchase list */
	public List<GDT_ManageLicense_Purchase__c> listAll_Purchase {
		get {
			return [SELECT Id,GDT_Purchase_Description__c, GDT_Purchase_AffiliateGroup__c, GDT_Purchase_AppName__c, GDT_Purchase_LicenseType__r.GDT_License_APIName__c, GDT_Purchase_LicenseType__r.Name, GDT_Purchase_TotalLicenses__c, GDT_Purchase_ExpirationDate__c, GDT_Purchase_PurchaseDate__c FROM GDT_ManageLicense_Purchase__c where GDT_Purchase_ExpirationDate__c >= TODAY ORDER BY GDT_Purchase_AffiliateGroup__c];
		}
	}

	/** Retrieves the purchase list */
	public List<GDT_ManageLicense_Purchase__c> obsoletelistAll_Purchase {
		get {
			return [SELECT Id,GDT_Purchase_Description__c, GDT_Purchase_AffiliateGroup__c, GDT_Purchase_AppName__c, GDT_Purchase_LicenseType__r.GDT_License_APIName__c, GDT_Purchase_LicenseType__r.Name, GDT_Purchase_TotalLicenses__c, GDT_Purchase_ExpirationDate__c, GDT_Purchase_PurchaseDate__c FROM GDT_ManageLicense_Purchase__c where GDT_Purchase_ExpirationDate__c < TODAY ORDER BY GDT_Purchase_AffiliateGroup__c];
		}
	}


	/**
	 * NEW Record (Purchase)
	 */
	//Add a new record (Purchase)
	public void addRecord_Purchase() {
		GDT_ManageLicense_Purchase__c recordPurchase = new GDT_ManageLicense_Purchase__c();
			recordPurchase.GDT_Purchase_LicenseType__c = this.mysObject.GDT_Purchase_LicenseType__c;
			recordPurchase.GDT_Purchase_AffiliateGroup__c = this.mysObject.GDT_Purchase_AffiliateGroup__c;
			recordPurchase.GDT_Purchase_AppName__c = this.mysObject.GDT_Purchase_AppName__c;
			recordPurchase.GDT_Purchase_Description__c = this.mysObject.GDT_Purchase_Description__c;
			recordPurchase.GDT_Purchase_PurchaseDate__c = this.mysObject.GDT_Purchase_PurchaseDate__c;
			recordPurchase.GDT_Purchase_ExpirationDate__c = this.mysObject.GDT_Purchase_ExpirationDate__c;
			recordPurchase.GDT_Purchase_TotalLicenses__c = this.mysObject.GDT_Purchase_TotalLicenses__c;
		
		try {
			insert recordPurchase;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'New purchase is registered'));
			
			//Clear
			this.mysObject.GDT_Purchase_LicenseType__c = null;
			this.mysObject.GDT_Purchase_AffiliateGroup__c = null;
			this.mysObject.GDT_Purchase_AppName__c = null;
			this.mysObject.GDT_Purchase_Description__c = null;
			this.mysObject.GDT_Purchase_PurchaseDate__c = null;
			this.mysObject.GDT_Purchase_ExpirationDate__c = null;
			this.mysObject.GDT_Purchase_TotalLicenses__c = null;

		} catch(Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to insert'));
			System.debug('CATCH in addRecord_Purchase : ' + e.getMessage());
		}
	}
}