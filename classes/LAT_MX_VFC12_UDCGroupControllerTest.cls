@isTest
private class LAT_MX_VFC12_UDCGroupControllerTest {
	
	static testMethod void createNewUDCGroup() {

		Test.startTest();

		Group gp = [select id from group where name = 'LAT_MX_Alta_Grupos'];

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc@yahoo.com');

        system.RunAs(u){

        	GroupMember gm = new GroupMember();
			gm.GroupId = gp.Id;
			gm.UserOrGroupId = UserInfo.getUserId();

			insert gm;

        	LAT_MX_VFC12_UDCGroupController controller = new LAT_MX_VFC12_UDCGroupController();

			controller.newUDC.Name = 'Test Group 1';
			controller.newUDC.CodDefUsuario__c = 'Test Group 1';

			controller.save();

        }		

		Test.stopTest();
	}

	static testMethod void createSameUDCGroup() {

		Test.startTest();

		Group gp = [select id from group where name = 'LAT_MX_Alta_Grupos'];

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc@yahoo.com');

        system.RunAs(u){

        	GroupMember gm = new GroupMember();
			gm.GroupId = gp.Id;
			gm.UserOrGroupId = UserInfo.getUserId();

			insert gm;

        	LAT_MX_VFC12_UDCGroupController controller = new LAT_MX_VFC12_UDCGroupController();

			controller.newUDC.Name = 'Test Group 1';
			controller.newUDC.CodDefUsuario__c = 'Test Group 1';

			controller.save();
			controller.save();

        }

		Test.stopTest();
	}

}