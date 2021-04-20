@isTest
private class GVP_PosPlacementRollupControllerTest {

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
		gvp__POS_Material__c material = new gvp__POS_Material__c(
			GVP_Status__c = 'Active',
			GVP_Province__c = territory.Id,
			GVP_Total_Quantity__c = 1
		);
		insert material;
	}

	private static @isTest void posPlacementRollupSummary_rolls_up_pos_placements() {
		User user = [SELECT BypassVR__c FROM User WHERE Id = :UserInfo.getUserId()];
		user.BypassVR__c = false;
		update user;

		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		gvp__POS_Material__c material = [SELECT Id, GVP_Placed__c FROM gvp__POS_Material__c];
		System.assertEquals(null, material.GVP_Placed__c, '0 Placements');
		gvp__Pos_Placement__c placement = new gvp__Pos_Placement__c(
			gvp__POS_Item__c = material.Id,
			gvp__Account__c = testAccount.Id,
			gvp__Quantity__c = 10,
			GVP_Status__c = 'Active'
		);
		insert placement;
		material = [SELECT Id, GVP_Placed__c FROM gvp__POS_Material__c];
		System.assertEquals(10, material.GVP_Placed__c, '1 Placement added');
		delete placement;
		material = [SELECT Id, GVP_Placed__c FROM gvp__POS_Material__c];
		System.assertEquals(0, material.GVP_Placed__c, '1 Placement deleted');
	}
}