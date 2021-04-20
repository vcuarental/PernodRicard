@isTest
private class GVP_AssignRackControllerTest {

	@testSetup static void setupData() {
		gvp__Company__c testCompany = new gvp__Company__c(Name = 'Company');
		insert testCompany;
		gvp__Division__c testDivision = new gvp__Division__c(Name = 'Division', gvp__Company__c = testCompany.Id);
		insert testDivision;
		gvp__Region__c testRegion = new gvp__Region__c(Name = 'Region', gvp__Division__c = testDivision.Id);
		insert testRegion;
		gvp__Territory__c territory1 = new gvp__Territory__c(Name = 'Territory1', gvp__Region__c = testRegion.Id);
		insert territory1;
		gvp__Territory__c territory2 = new gvp__Territory__c(Name = 'Territory2', gvp__Region__c = testRegion.Id);
		insert territory2;
		Account testAccount1 = new Account(
			Name = 'test account 1',
			gvp__Territory__c = territory1.Id
		);
		insert testAccount1;
		Account testAccount2 = new Account(
			Name = 'test account 2',
			gvp__Territory__c = territory2.Id
		);
		insert testAccount2;
		gvp__POS_Material__c material1 = new gvp__POS_Material__c(
			Name = 'POS 1',
			GVP_Status__c = 'Active',
			GVP_Province__c = territory1.Id,
			GVP_Total_Quantity__c = 1
		);
		insert material1;
		gvp__POS_Material__c material2 = new gvp__POS_Material__c(
			Name = 'POS 2',
			GVP_Status__c = 'Active',
			GVP_Province__c = territory2.Id,
			GVP_Total_Quantity__c = 1
		);
		insert material2;

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

	private static @isTest void contructor_loads_data() {
		List<Account> accounts = [SELECT Id FROM Account];
		PageReference assignRackPage = Page.GVP_AssignRack;
		Test.setCurrentPage(assignRackPage);
		ApexPages.currentPage().getParameters().put('idArray', accounts[0].Id + ',' + accounts[1].Id);
		GVP_AssignRackController controller = new GVP_AssignRackController();

		System.assertEquals(2, controller.posPlacements.size(), '2 accounts loaded');
		System.assertEquals(1, controller.labels.size(), '1 Label found');
		System.assertEquals(1, controller.programs.size(), '1 Program found');
	}

	private static @isTest void getPosMaterials_creates_selectlist() {
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'test account 1'];
		PageReference assignRackPage = Page.GVP_AssignRack;
		Test.setCurrentPage(assignRackPage);
		ApexPages.currentPage().getParameters().put('idArray', accounts[0].Id);
		GVP_AssignRackController controller = new GVP_AssignRackController();

		System.assertEquals(1, controller.posPlacements[0].availableRacks.size(), '1 Pos Material found');
		System.assertEquals('POS 1', controller.posPlacements[0].availableRacks[0].Name, 'Related POS 1 Material found');
	}

	private static @isTest void getLabels_creates_selectlist() {
		List<Account> accounts = [SELECT Id FROM Account];
		gvp__Label__c label = [SELECT Id, Name FROM gvp__Label__c];
		PageReference assignRackPage = Page.GVP_AssignRack;
		Test.setCurrentPage(assignRackPage);
		ApexPages.currentPage().getParameters().put('idArray', accounts[0].Id + ',' + accounts[1].Id);
		GVP_AssignRackController controller = new GVP_AssignRackController();
		List<SelectOption> labels = controller.getLabels();

		System.assertEquals(1, labels.size(), '1 Pos Material found');
		System.assertEquals(label.Id, labels[0].getValue(), 'Value set');
		System.assertEquals(label.Name, labels[0].getLabel(), 'Label set');
	}

	private static @isTest void getPrograms_creates_selectlist() {
		List<Account> accounts = [SELECT Id FROM Account];
		gvp__Program__c program = [SELECT Id, Name FROM gvp__Program__c];
		PageReference assignRackPage = Page.GVP_AssignRack;
		Test.setCurrentPage(assignRackPage);
		ApexPages.currentPage().getParameters().put('idArray', accounts[0].Id + ',' + accounts[1].Id);
		GVP_AssignRackController controller = new GVP_AssignRackController();
		List<SelectOption> programs = controller.getPrograms();

		System.assertEquals(1, programs.size(), '1 Pos Material found');
		System.assertEquals(program.Id, programs[0].getValue(), 'Value set');
		System.assertEquals(program.Name, programs[0].getLabel(), 'Label set');
	}

	private static @isTest void savePosPlacementsavePosPlacements_returns_empty_string_on_success() {
		List<Account> accounts = [SELECT Id FROM Account];
		PageReference assignRackPage = Page.GVP_AssignRack;
		Test.setCurrentPage(assignRackPage);
		ApexPages.currentPage().getParameters().put('idArray', accounts[0].Id);
		GVP_AssignRackController controller = new GVP_AssignRackController();
		PageReference result = controller.SavePosPlacement();
		Id placementId = [SELECT Id FROM gvp__POS_Placement__c LIMIT 1].Id;
		System.assertEquals(
			'/' + placementId.getSObjectType().getDescribe().getKeyPrefix(),
			result.getUrl(),
			'Result empty'
		);
		List<gvp__POS_Placement__c> placements = [SELECT Id FROM gvp__POS_Placement__c];
		System.assertEquals(1, placements.size(), '1 placement added');
	}

	private static @isTest void removePosPlacement_reindexes_pos_array() {
		List<Account> accounts = [SELECT Id FROM Account];
		PageReference assignRackPage = Page.GVP_AssignRack;
		Test.setCurrentPage(assignRackPage);
		ApexPages.currentPage().getParameters().put('idArray', accounts[0].Id + ',' + accounts[1].Id);
		GVP_AssignRackController controller = new GVP_AssignRackController();
		Id account2Id = controller.posPlacements[1].placement.gvp__Account__c;
		System.assertEquals(2, controller.posPlacements.size(), '2 placement');

		controller.selectedIndex = 0;
		controller.removePosPlacement();
		System.assertEquals(account2Id, controller.posPlacements[0].placement.gvp__Account__c, 'List reindexed');
	}
}