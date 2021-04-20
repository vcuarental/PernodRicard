@isTest
private class GVP_RackControllerTest {

	@testSetup static void setupData() {
		gvp__Company__c testCompany = new gvp__Company__c(Name = 'Company');
		insert testCompany;
		gvp__Division__c testDivision = new gvp__Division__c(Name = 'Division', gvp__Company__c = testCompany.Id);
		insert testDivision;
		gvp__Region__c testRegion = new gvp__Region__c(Name = 'Region', gvp__Division__c = testDivision.Id);
		insert testRegion;
		gvp__Territory__c territory = new gvp__Territory__c(Name = 'Territory', gvp__Region__c = testRegion.Id);
		insert territory;
		Account testAccount1 = new Account(
			Name = 'test account 1',
			gvp__Territory__c = territory.Id
		);
		insert testAccount1;
		Account testAccount2 = new Account(
			Name = 'test account 2',
			gvp__Territory__c = territory.Id
		);
		insert testAccount2;
		gvp__POS_Material__c material = new gvp__POS_Material__c(
			GVP_Status__c = 'Active',
			GVP_Province__c = territory.Id,
			GVP_Total_Quantity__c = 1
		);
		insert material;

		gvp__Brand__c brand = new gvp__Brand__c(gvp__Brand_Key__c = 'brand');
		insert brand;
		gvp__Label__c label = new gvp__Label__c(gvp__Brand__c = brand.Id, gvp__Label_Key__c = 'label');
		insert label;

		gvp__Budget__c testBudget = new gvp__Budget__c();
		insert testBudget;
		gvp__Budget_Plan__c testPlan = new gvp__Budget_Plan__c(gvp__Parent_Budget__c = testBudget.Id);
		insert testPlan;
		gvp__Program__c testProgram= new gvp__Program__c(gvp__Budget_Plan__c = testPlan.Id);
		insert testProgram;
	}

	private static @isTest void constructor_mode_set_to_new() {
		System.Test.setCurrentPage(Page.GVP_Rack);
		ApexPages.StandardController standardController = new ApexPages.StandardController(new gvp__Pos_Placement__c());
		GVP_RackController controller = new GVP_RackController(standardController);
		System.assertEquals('New', controller.mode, 'Mode set to new');
	}

	private static @isTest void constructor_mode_set_to_edit() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		gvp__Pos_Placement__c placement = new gvp__Pos_Placement__c(gvp__Account__c = testAccount.Id);
		insert placement;

		System.Test.setCurrentPage(Page.GVP_Rack);
		ApexPages.StandardController standardController = new ApexPages.StandardController(placement);
		GVP_RackController controller = new GVP_RackController(standardController);
		System.assertEquals('Edit', controller.mode, 'Mode set to edit');
	}

	private static @isTest void constructor_mode_set_to_new_on_clone() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		gvp__Pos_Placement__c placement = new gvp__Pos_Placement__c(gvp__Account__c = testAccount.Id);
		insert placement;

		System.Test.setCurrentPage(Page.GVP_Rack);
		ApexPages.currentPage().getParameters().put('id', placement.Id);
		ApexPages.currentPage().getParameters().put('clone', '1');
		ApexPages.StandardController standardController = new ApexPages.StandardController(placement);
		GVP_RackController controller = new GVP_RackController(standardController);
		System.assertEquals('New', controller.mode, 'Mode set to New');
		System.assertEquals(1, controller.assignRackController.posPlacements[0].availableRacks.size(), '1 Pos Material found');
	}

	private static @isTest void savePlacement_returns_url_to_record() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		gvp__Pos_Placement__c placement = new gvp__Pos_Placement__c(gvp__Account__c = testAccount.Id);
		insert placement;

		System.Test.setCurrentPage(Page.GVP_Rack);
		ApexPages.currentPage().getParameters().put('id', placement.Id);
		ApexPages.currentPage().getParameters().put('clone', '1');
		ApexPages.StandardController standardController = new ApexPages.StandardController(placement);
		GVP_RackController controller = new GVP_RackController(standardController);
		PageReference result = controller.savePlacement();
		System.assertEquals('/' + controller.placement.Id, result.getUrl(), 'Path to record returned');
	}
}