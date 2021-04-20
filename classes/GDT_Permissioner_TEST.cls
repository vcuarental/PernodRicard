@isTest
private class GDT_Permissioner_TEST {

	//
	static testMethod void myUnitTest_main() {
		// Variable declaration
		String recType_InSite = [SELECT DeveloperName,Id FROM RecordType WHERE DeveloperName LIKE '%GDT_Insite%'].Id;
		String permSetId_Insite = [SELECT Id,Name FROM PermissionSet WHERE Name LIKE '%PR_USA_Insite%'].Id;

		List<User> listUser = new List<User>(); // For getlistUser

		// Instantiate a new controller with all parametres in the page
		GDT_Permissioner__c objPermissioner_InSite = new GDT_Permissioner__c(RecordTypeId=recType_InSite,
																			GDT_Application_Name__c='InSite',
																			GDT_Permission_Name__c='PR USA Insite',
																			GDT_Permission_Id__c=permSetId_Insite);
																			// RecordTypeId : InSite

		ApexPages.StandardController sc = new ApexPages.StandardController(objPermissioner_InSite);
		GDT_Permissioner_Controller pc = new GDT_Permissioner_Controller(sc);

		// Page Reference
		PageReference pageRef = Page.GDT_Permissioner_Assign;
		Test.setCurrentPage(pageRef);

		// START()
		Test.startTest();
			System.debug('Page Reference : '+ pageRef);

			// Step 1
			pc.setslApplicationName(objPermissioner_InSite.GDT_Application_Name__c);
			String appName = pc.getslApplicationName();
			System.debug('Application Name : '+ appName);
			
			// Step 2
			pc.setslPermissionName(objPermissioner_InSite.GDT_Permission_Id__c);
			List<SelectOption> soPermSet = pc.getsoPermissionName();
			String permName = pc.getslPermissionName();
			System.debug('Permission Name (Id): '+ permName);

			// Step 3
			listUser = pc.getlistUser();
			System.debug('List User(s) : ' + listUser);

			// Button Search 
			pc.searchValueA = ''; // No value
			pc.searchUserA();
			System.assertEquals(false, pc.dtSearchUser);

			pc.searchValueR = ''; // No value
			pc.searchUserR();
			System.assertEquals(false, pc.btnSearch);

			// Search Assignment
			pc.searchValueA = 'Jean Simon Gazin'; // Value return no result
			pc.searchUserA();
			System.debug('SearchA (Jean Simon Gazin) : ' + pc.searchResultUser);
			// Search Remove
			pc.searchValueR = 'Jean Simon Gazin'; // Value return no result
			pc.searchUserR();
			System.assertEquals(true, pc.btnSearch);

			listUser = pc.getlistUser();
			System.debug('List User(s) : ' + listUser);

			// Search Assignment
			pc.searchValueA = 'GDT'; // Value returned
			pc.searchUserA();
			System.debug('SearchA (GDT) :' + pc.searchResultUser);


			pageRef.getParameters().put('nUserID', [SELECT Id FROM User WHERE Username LIKE 'globaldev.team@pernod-ricard.com%' LIMIT 1].Id); // User selected
			pc.assign(); // Assignement
			System.debug('msgTilte : ' + pc.msgResultTitle); // Result

			// Search Remove
			pc.searchValueR = 'GDT'; // Value returned
			pc.searchUserR();
			System.assertEquals(true, pc.btnSearch);

			listUser = pc.getlistUser();
			System.debug('List User(s) : ' + listUser);
			pc.setlistUser(listUser);


			if(pc.msgResultTitle == 'Success'){
				pc.assign(); // Assignement
				System.debug('msgTilte : ' + pc.msgResultTitle); // Result
				System.assertEquals(pc.msgResultTitle, 'Duplicate permission set', 'No duplicate permission set');
			}
			else{
				pc.remove(); // Remove
				System.debug('msgTilte : ' + pc.msgResultTitle); // Result

				pc.assign(); // Assignement
				System.debug('msgTilte : ' + pc.msgResultTitle); // Result
			}

			pc.remove(); // Remove
			System.debug('msgTilte : ' + pc.msgResultTitle); // Result
			System.assertEquals(pc.msgResultTitle, 'Success', 'Permission set not remove');

			// Test External User
			pageRef.getParameters().put('nUserID', [SELECT Id FROM User WHERE Name LIKE '%Gabe Abdo%'].Id); // External User selected : Gabe Abdo
			pc.assign(); // Assignement
			System.assertEquals(pc.msgResultTitle, 'Wrong user license', 'Is not an External user');

		Test.stopTest();
		// STOP()
	}

	//
	static testMethod void myUnitTest_onChangeStep() {
		// Variable declaration
		String recType_InSite = [SELECT DeveloperName,Id FROM RecordType WHERE DeveloperName LIKE '%GDT_Insite%'].Id;
		String permSetId_Insite = [SELECT Id,Name FROM PermissionSet WHERE Name LIKE '%PR_USA_Insite%'].Id;
		
		// Instantiate a new controller with all parametres in the page
		GDT_Permissioner__c objPermissioner_InSite = new GDT_Permissioner__c(RecordTypeId=recType_InSite,
																			GDT_Application_Name__c='InSite',
																			GDT_Permission_Name__c='PR USA Insite',
																			GDT_Permission_Id__c=permSetId_Insite);
																			// RecordTypeId : InSite

		ApexPages.StandardController sc = new ApexPages.StandardController(objPermissioner_InSite);
		GDT_Permissioner_Controller pc = new GDT_Permissioner_Controller(sc);

		// Page Reference
		PageReference pageRef = Page.GDT_Permissioner_Assign;
		Test.setCurrentPage(pageRef);

		// START()
		Test.startTest();

			// Test display 3 blockSection (Step 1,2,3) with event onChange
			pc.setslApplicationName(objPermissioner_InSite.GDT_Application_Name__c);
			pc.changeApplicationName();
			System.assertEquals(true, pc.rStep2, 'Step 2 not visible');

			pc.setslPermissionName(objPermissioner_InSite.GDT_Permission_Name__c);
			pc.changePermissionName();
			System.assertEquals(true, pc.rStep3, 'Step 3 not visible');

			pc.setslPermissionName('NONE');
			pc.changePermissionName();
			System.assertEquals(false, pc.rStep3, 'Step 3 visible');

			pc.setslPermissionName(objPermissioner_InSite.GDT_Permission_Name__c);
			pc.changePermissionName();
			System.assertEquals(true, pc.rStep3, 'Step 3 not visible');

			pc.setslApplicationName('');
			pc.changeApplicationName();
			System.assertEquals(false, pc.rStep2, 'Step 2 visible');
			System.assertEquals(false, pc.rStep3, 'Step 3 visible');
			System.assertEquals('NONE', pc.getslPermissionName(), 'setslPermissionName != NONE');

		Test.stopTest();
		// STOP()
	}

	//
	static testMethod void myUnitTest_paginationAssign() {
		// Variable declaration
		String recType_InSite = [SELECT DeveloperName,Id FROM RecordType WHERE DeveloperName LIKE '%GDT_Insite%'].Id;
		String permSetId_Insite = [SELECT Id,Name FROM PermissionSet WHERE Name LIKE '%PR_USA_Insite%'].Id;
		
		// Instantiate a new controller with all parametres in the page
		GDT_Permissioner__c objPermissioner_InSite = new GDT_Permissioner__c(RecordTypeId=recType_InSite,
																			GDT_Application_Name__c='InSite',
																			GDT_Permission_Name__c='PR USA Insite',
																			GDT_Permission_Id__c=permSetId_Insite);
																			// RecordTypeId : InSite

		ApexPages.StandardController sc = new ApexPages.StandardController(objPermissioner_InSite);
		GDT_Permissioner_Controller pc = new GDT_Permissioner_Controller(sc);

		// Page Reference
		PageReference pageRef = Page.GDT_Permissioner_Assign;
		Test.setCurrentPage(pageRef);

		// START()
		Test.startTest();

			// Step 1
			pc.setslApplicationName(objPermissioner_InSite.GDT_Application_Name__c);
			String appName = pc.getslApplicationName();

			// Step 2
			pc.setslPermissionName(objPermissioner_InSite.GDT_Permission_Id__c);
			List<SelectOption> soPermSet = pc.getsoPermissionName();

			// Step 3
			// Return total record > limitSize (minimum 2 pages)
			pc.searchValueA = 'Simon';
			pc.searchUserA();

			System.debug('Pagination : '+ pc.getstartRecord() +'-'+ pc.getendRecord() +' of '+ pc.totalRecord);
			System.debug('Pagination : Page '+ pc.currentPage +' of '+ pc.nbPage);

			// checking the visibility of buttons
			if(pc.nbPage > 1 || pc.totalRecord == 0){
				System.assertEquals(true, pc.lastPageLink, 'AE1');
				pc.next(); // Next Button
				System.assertEquals(true, pc.firstPageLink, 'AE2');

				if(pc.currentPage < pc.nbPage){
					pc.last(); // Last Button
					System.assertEquals(true, pc.firstPageLink, 'AE3');
					System.assertEquals(false, pc.lastPageLink, 'AE4');
					pc.previous(); // Previous Button
					System.assertEquals(true, pc.lastPageLink, 'AE5');
				}
				else{
					System.assertEquals(true, pc.firstPageLink, 'AE6');
					System.assertEquals(false, pc.lastPageLink, 'AE7');
					pc.previous(); // Previous Button
					System.assertEquals(true, pc.lastPageLink, 'AE8');
					pc.last(); // Last Button
					System.assertEquals(true, pc.firstPageLink, 'AE9');
				}

				pc.first(); // First Button
				System.assertEquals(true, pc.lastPageLink, 'AE10');
			}
			else{
				System.assertEquals(false, pc.lastPageLink, 'AE11');
			}

			if(pc.currentPage == 1 || pc.totalRecord == 0)
				System.assertEquals(false, pc.firstPageLink, 'AE12');
			else
				System.assertEquals(true, pc.firstPageLink, 'AE13');


			// Return 0 record
			pc.searchValueA = 'aeiouy';
			pc.searchUserA();

			System.debug('Pagination : '+ pc.getstartRecord() +'-'+ pc.getendRecord() +' of '+ pc.totalRecord);
			System.debug('Pagination : Page '+ pc.currentPage +' of '+ pc.nbPage);

			// checking the visibility of buttons
			if(pc.totalRecord == 0) {
				System.assertEquals(false, pc.lastPageLink, 'AE14');
				System.assertEquals(false, pc.firstPageLink, 'AE15');
			}


		Test.stopTest();
		// STOP()
	}

	//
	static testMethod void myUnitTest_paginationRemove() {
		// Variable declaration
		String recType_InSite = [SELECT DeveloperName,Id FROM RecordType WHERE DeveloperName LIKE '%GDT_Insite%'].Id;
		String permSetId_Insite = [SELECT Id,Name FROM PermissionSet WHERE Name LIKE '%PR_USA_Insite%'].Id;
		
		// Instantiate a new controller with all parametres in the page
		GDT_Permissioner__c objPermissioner_InSite = new GDT_Permissioner__c(RecordTypeId=recType_InSite,
																			GDT_Application_Name__c='InSite',
																			GDT_Permission_Name__c='PR USA Insite',
																			GDT_Permission_Id__c=permSetId_Insite);
																			// RecordTypeId : InSite

		ApexPages.StandardController sc = new ApexPages.StandardController(objPermissioner_InSite);
		GDT_Permissioner_Controller pc = new GDT_Permissioner_Controller(sc);

		// Page Reference
		PageReference pageRef = Page.GDT_Permissioner_Assign;
		Test.setCurrentPage(pageRef);

		// START()
		Test.startTest();

			// Step 1
			pc.setslApplicationName(objPermissioner_InSite.GDT_Application_Name__c);
			String appName = pc.getslApplicationName();

			// Step 2
			pc.setslPermissionName(objPermissioner_InSite.GDT_Permission_Id__c);
			List<SelectOption> soPermSet = pc.getsoPermissionName();

			// Step 3
			// Return total record > limitSize (minimum 2 pages)
			pageRef.getParameters().put('nUserID', [SELECT Id FROM User WHERE Username LIKE 'globaldev.team@pernod-ricard.com%' LIMIT 1].Id); // User selected
			pc.assign(); // Assignement
			System.debug('msgTilte : ' + pc.msgResultTitle); // Result

			List<User> listUser = pc.getlistUser();
			System.debug('List User(s) : ' + listUser);

			//
			pc.searchValueR = 'Simon';
			pc.searchUserR();

			listUser = pc.getlistUser();
			System.debug('List User(s) : ' + listUser);

			System.debug('Pagination : '+ pc.getstartRecordR() +'-'+ pc.getendRecordR() +' of '+ pc.totalRecordR);
			System.debug('Pagination : Page '+ pc.currentPageR +' of '+ pc.nbPageR);

			// Return 0 record
			pc.searchValueR = 'aeiouy';
			pc.searchUserR();

			listUser = pc.getlistUser();
			System.debug('List User(s) : ' + listUser);

			System.debug('Pagination : '+ pc.getstartRecordR() +'-'+ pc.getendRecordR() +' of '+ pc.totalRecordR);
			System.debug('Pagination : Page '+ pc.currentPageR +' of '+ pc.nbPageR);

			// checking the visibility of buttons
			if(pc.totalRecordR == 0) {
				System.assertEquals(false, pc.lastPageLinkR, 'AE14');
				System.assertEquals(false, pc.firstPageLinkR, 'AE15');
			}


		Test.stopTest();
		// STOP()
	}
}