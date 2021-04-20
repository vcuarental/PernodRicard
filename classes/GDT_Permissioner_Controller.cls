public with sharing class GDT_Permissioner_Controller {

	private final GDT_Permissioner__c mysObject;

	/* Variable Declaration */
	String slApplicationName; // selectList Application Name
	String slPermissionName; // slectList Permission Name
	List<SelectOption> soPermissionName; // select option for picklist
	List<User> listUser; // User list

	// Pagination - Table 'Assign'
	Integer startRecord;
	Integer endRecord;
	// Pagination - Table 'Remove'
	Integer startRecordR;
	Integer endRecordR;

	public List<User> searchResultUser {get;set;} // User searched list
	public Boolean btnSearch {get;set;} //
	public String searchValueA {get;set;} // Value searched - 'Assign'
	public String searchValueR {get;set;} // Value searched - 'Remove'
	public String oldSearchValueA {get;set;} // Stock last value searched
	public String oldSearchValueR {get;set;} // Stock last value searched
	public String userID {get;set;} // User Id selected

	public Boolean rStep1 {get;set;} // PageBlock 'Choose Application' 
	public Boolean rStep2 {get;set;} // PageBlock 'Choose Permission Set'
	public Boolean rStep3 {get;set;} // PageBlock 'Add/Remoce User'
	public Boolean dtSearchUser {get;set;} // Table 'Search'
	public String msgResultSummary {get;set;} // String contain the message result for assignment
	public String msgResultTitle {get;set;} //
	public Boolean pmsg {get;set;} // Hide or Display message result

	//Pagination
	protected Integer limitSize = 20;   // Limit SOQL
	public Integer counterOffset {get; set;} // Offset SOQL - table 'Assign'
	public Integer counterOffsetR {get; set;} // Offset SOQL - table 'Remove'
	public Integer totalRecord {get; set;} // Number of record - table 'Assign'
	public Integer totalRecordR {get; set;} // Number of record - table 'Remove'
	public Integer currentPage {get; set;} // Current page table - table 'Assign'
	public Integer currentPageR {get; set;} // Current page table - table 'Remove'


	public List<GDT_Permissioner__c> listRecordTypeId {get;set;}

	public GDT_Permissioner__c invoiceStatement {get;set;}
	public List<SelectOption> statusOptions {get;set;}

	public String idrec {get;set;}

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public GDT_Permissioner_Controller(ApexPages.StandardController stdController) {
		this.mysObject = (GDT_Permissioner__c)stdController.getRecord();

		// Display Step1 by default
		rStep1 = true;
		// Hide message result assignment by default
		pmsg = false;

		// Pagination
		counterOffset = 0;
		counterOffsetR = 0;
		currentPage = 1;
		currentPageR = 1;

		btnSearch = false;

		invoiceStatement = new GDT_Permissioner__c();
		statusOptions = new List<SelectOption>();
	}


	/* 
	 * Get/Set - slApllicationName
	 */
	public String getslApplicationName() {
		return slApplicationName;
	}
	public void setslApplicationName(String slApplicationName) {
		this.slApplicationName = slApplicationName;
	}

	/*
	 * Get/Set - slPermissionName
	 */
	public String getslPermissionName() {
		return slPermissionName;
	}
	public void setslPermissionName(String slPermissionName) {
		this.slPermissionName = slPermissionName;
	}
	public List<SelectOption> getsoPermissionName() {
		List<GDT_Permissioner__c> lPermissionName = [SELECT GDT_Permission_Id__c, GDT_Permission_Name__c FROM GDT_Permissioner__c WHERE RecordTypeId = :this.mysObject.RecordTypeId ORDER BY GDT_Permission_Name__c  ASC NULLS FIRST];
		List<SelectOption> options = new List<SelectOption>();
		// Option by default
		options.add(new SelectOption('NONE','--None--'));

		// Add options in the picklist
		for(GDT_Permissioner__c lpn : lPermissionName){
			options.add(new SelectOption(String.valueOf(lpn.get('GDT_Permission_Id__c')),String.valueOf(lpn.get('GDT_Permission_Name__c')) ));
		}

		return options;
	}
	public void setsoPermissionName(List<SelectOption> soPermissionName) {
		this.soPermissionName = soPermissionName;
	}

	/*
	 * Users list
	 */
	public List<User> getlistUser() {
		String querySoql;

		// Search an user to remove a permission set 
		if(btnSearch == true) {
			querySoql = 'SELECT Id, Name, Username, Email, CompanyName, IsActive, LastLoginDate FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = \''+slPermissionName+'\') AND Name LIKE \'%'+ searchValueR +'%\' LIMIT '+ limitSize +' OFFSET '+ counterOffsetR;

			totalRecordR = Database.countQuery('SELECT count() FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = \''+slPermissionName+'\') AND Name LIKE \'%'+ searchValueR +'%\'');
			if(totalRecordR == 0)
				currentPageR = 0;
		}
		// By default, display all users with the permission set
		else {
			querySoql = 'SELECT Id, Name, Username, Email, CompanyName, IsActive, LastLoginDate FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = \''+slPermissionName+'\') LIMIT '+ limitSize +' OFFSET '+ counterOffsetR;
		
			totalRecordR = Database.countQuery('SELECT count() FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = \''+slPermissionName+'\')' );
			if(totalRecordR == 0)
				currentPageR = 0;
		}

		listUser = Database.query(querySoql);
		return listUser;
	}
	public void setlistUser(List<User> listUser) {
		this.listUser = listUser;
	}

	/*
	 * Display Step
	 */
	// Choose an application
	public PageReference changeApplicationName() {
		rStep3 = false;
		pmsg = false;
		slPermissionName = 'NONE';

		mysObject.RecordTypeId = this.mysObject.RecordTypeId;

		if(slApplicationName != '') {
			rStep2 = true;
		} else {
			rStep2 = false;
			rStep3 = false;
			slPermissionName = 'NONE';
		}

		return null;
	}
	// Choose a permission set
	public PageReference changePermissionName() {
		pmsg = false;

		if(slPermissionName != 'NONE') {
			rStep3 = true;
		} else {
			rStep3 = false;
		}

		return null;
	}

	/*
	 * Search User
	 */
	public void searchUserA() {
		// Hide result message
		pmsg = false;
		// Pagination
		if(oldSearchValueA != searchValueA){
			currentPage = 1;
			counterOffset = 0;
		}

		if(searchValueA != ''){
			dtSearchUser = true;

			String querySoql = 'SELECT Id, Name, Username, Email, CompanyName, IsActive, LastLoginDate FROM User WHERE Name LIKE \'%'+searchValueA+'%\' LIMIT '+ limitSize +' OFFSET '+ counterOffset;
			
			// Number of records
			totalRecord = Database.countQuery('SELECT count() FROM User WHERE Name LIKE \'%'+searchValueA+'%\'');
			if(totalRecord == 0)
				currentPage = 0;

			searchResultUser = Database.query(querySoql);
		}
		else {
			dtSearchUser = false;
		}

		// Stock last value researched
		oldSearchValueA = searchValueA;
	}
	public void searchUserR() {
		// Hide result message
		pmsg = false;

		counterOffsetR = 0;
		currentPageR = 1;

		if(searchValueR != '') {
			btnSearch = true;
		} 
		else {
			btnSearch = false;
		}
	}

	/*
	 * Assign / Remove
	 */
	public PageReference remove() {
		userID = ApexPages.currentPage().getParameters().get('nUserID'); // User Id selected
		//userName = ApexPages.currentPage().getParameters().get('nUserName'); // User Id selected

		String querySoql = 'SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=\''+ userID +'\' AND PermissionSetId=\''+ slPermissionName +'\'';

		List<PermissionSetAssignment> forRemove = new List<PermissionSetAssignment>();
		forRemove = Database.query(querySoql);

		msgResultTitle = 'Success';
		msgResultSummary =  [SELECT Name FROM PermissionSet WHERE Id=:slPermissionName].Name + ' permission set has been successfully removed from ' + [SELECT Name FROM User WHERE Id=:userID].Name;
		pmsg = true;

		// Delete
		delete(forRemove);

		return null;
	}
	public PageReference assign() {
		userID = ApexPages.currentPage().getParameters().get('nUserID'); // User Id selected

		// Verification External User
		// License BlackList
		String licenseBlackList = 'Chatter External';
		List<Profile> listIdProfileExternal = [SELECT Id, UserLicenseId FROM Profile WHERE UserLicenseId IN (SELECT Id FROM UserLicense WHERE Name = :licenseBlackList)];
		Boolean isExternalUser = false;
		String profileId;

		List<User> listExternalUser = new List<User>();
		// Liste des profiles avec la licence black listé
		for(Profile lipe : listIdProfileExternal) {
			profileId = String.valueOf(lipe.get('Id'));
			listExternalUser = [SELECT Id, Name FROM User WHERE ProfileId = :profileId];

			// Liste des Users avec ce Profile
			for(User leu : listExternalUser) {
				if(leu.get('Id') == userID) {
					isExternalUser = true;
				}
			}
		}

		// Verification Assignment
		String querySoql = 'SELECT count() FROM PermissionSetAssignment WHERE AssigneeId=\''+ userID +'\' AND PermissionSetId=\''+ slPermissionName +'\'';
		Integer forVerification = 0;
		forVerification = Database.countQuery(querySoql);
		
		if(forVerification == 0 && isExternalUser == false) {
			// New PermissionSetAssignment
			PermissionSetAssignment nPSA = new PermissionSetAssignment(AssigneeId=userID, PermissionSetId=slPermissionName);
			insert nPSA;
			msgResultTitle = 'Success';
			msgResultSummary = [SELECT Name FROM PermissionSet WHERE Id=:slPermissionName].Name +' permission set has been properly assigned to '+[SELECT Name FROM User WHERE Id=:userID].Name;
		}
		else
		{   
			// External User
			if(isExternalUser == true) {
				msgResultTitle = 'Wrong user license';
				msgResultSummary = 'You are not allowed to add this permission set to external users';
			}
			// Duplicate
			else {
				msgResultTitle = 'Duplicate permission set';
				msgResultSummary = 'This permission set is already assigned to this user';
			}
		}

		// Display message result
		pmsg = true;

		return null;
	}

	/*
	 * Pagination
	 */
	// Returns the first page of records
	public void first() {
			counterOffset = 0;
			currentPage = 1;
			searchUserA();
	}
	public void firstR() {
		counterOffsetR = 0;
		currentPageR = 1;
	}
	// Returns the last page of records
	public void last() {
		counterOffset = (nbPage * limitSize) - limitSize;
		currentPage = nbPage;
		searchUserA();
	}
	public void lastR() {
		counterOffsetR = (nbPageR * limitSize) - limitSize;
		currentPageR = nbPageR;
	}
	// Returns the previous page of records
	public void previous() {
		counterOffset -= limitSize;
		currentPage -= 1;
		searchUserA();
	}
	public void previousR() {
		counterOffsetR -= limitSize;
		currentPageR -= 1;
	}
	// Returns the next page of records
	public void next() {
		counterOffset += limitSize;
		currentPage += 1;
		searchUserA();
	}
	public void nextR() {
		counterOffsetR += limitSize;
		currentPageR += 1;
	}

	// Start Record
	public Integer getstartRecord() {
		if(totalRecord > 0)
			startRecord = counterOffset + 1;
		else
			startRecord = 0;

		return startRecord;
	}
	public Integer getstartRecordR() {
		if(totalRecordR > 0)
			startRecordR = counterOffsetR + 1;
		else
			startRecordR = 0;

		return startRecordR;
	}
	// End Record
	public Integer getendRecord() {
		if(endRecord == null)
			endRecord = 0;

		endRecord = counterOffset + limitSize;

		if(endRecord > totalRecord)
			endRecord = totalRecord;

		return endRecord;
	}
	public Integer getendRecordR() {
		if(endRecordR == null)
			endRecordR = 0;

		endRecordR = counterOffsetR + limitSize;

		if(endRecordR > totalRecordR)
			endRecordR = totalRecordR;

		return endRecordR;
	}
	// Calculate the number of page
	public Integer nbPage {
		get {
			nbPage = (totalRecord + limitSize - 1) / limitSize;
			return nbPage;
		} private set;
	}
	public Integer nbPageR {
		get {
			nbPageR = (totalRecordR + limitSize - 1) / limitSize;
			return nbPageR;
		} private set;
	}

	// Display buttons 'First' and 'Previous'
	public Boolean firstPageLink {
		get {
			if(currentPage == 1 || totalRecord == 0)
				return false;
			else
				return true;
		} private set;
	}
	public Boolean firstPageLinkR {
		get {
			if(currentPageR == 1 || totalRecordR == 0)
				return false;
			else
				return true;
		} private set;
	}
	// Display buttons 'Last' and 'Next'
	public Boolean lastPageLink {
		get {
			if(currentPage == nbPage || totalRecord == 0 || totalRecord <= limitSize)
				return false;
			else
				return true;
		} private set;
	}
	public Boolean lastPageLinkR {
		get {
			if(currentPageR == nbPageR || totalRecordR == 0 || totalRecordR <= limitSize)
				return false;
			else
				return true;
		} private set;
	}
}