@isTest	
public class LAT_BR_Inactivation_AccMob_Test {
	
	@testSetup
	private static void testSetup(){
		delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
	}

	public static testMethod void testLAT_BR_Inactivation_AccMob_Test(){
		Account acc = new Account(Name='Test',Reason_for_Inactivation__c ='test');
		insert acc;
		Test.startTest();
		PageReference pf = Page.LAT_BR_Inactivation_Account_Mobile;
		pf.getParameters().put('id',acc.Id);
		Test.setCurrentPage(pf);
		LAT_BR_Inactivation_AccMob_Controller con = new LAT_BR_Inactivation_AccMob_Controller();
		con.cas.Description ='aa';
		con.save();

		acc.Type ='Outros';
		acc.Reason_for_Inactivation__c = null;
		update acc;

		con = new LAT_BR_Inactivation_AccMob_Controller();
		system.assertEquals(con.acc.Reason_for_Inactivation__c,'--None--');
		Test.stopTest();

	}
}