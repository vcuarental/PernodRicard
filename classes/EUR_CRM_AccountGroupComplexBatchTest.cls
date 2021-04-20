@IsTest
private class EUR_CRM_AccountGroupComplexBatchTest {

	private static final String RECORD_SHARED_STATUS = 'Record shared';
	private static final String NEW_STATUS = 'New';
	private static final String TO_DELETE_STATUS = 'To Delete';

	@TestSetup
	private static void setupMethod() {
		insert makeUser('EUR AT Affiliate Admin', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
		insert makeUser('EUR AT Affiliate Admin', 'test.userB@mail.com', 'test.userB@mail.com', 'LastNameB');
		insert makeUser('EUR AT Affiliate Admin', 'test.userC@mail.com', 'test.userC@mail.com', 'LastNameC');
		insert makeUser('EUR AT Affiliate Admin', 'test.userD@mail.com', 'test.userD@mail.com', 'LastNameD');
	}

	// Integration tests

	// Start of deleteAGsNotInRolloutCountries() method tests

	@IsTest
	static void deleteAGsNotInRolloutCountries_PositiveTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_AO_On_Trade');
		insert acc;

		EUR_CRM_AccountGroup__c ag = makeAG(acc.Id);
		insert ag;

		EUR_CRM_AccountGroupUser__c agu = makeAGU(ag.Id, UserInfo.getUserId(), NEW_STATUS);
		insert agu;

		Test.startTest();
		EUR_CRM_AccountGroupComplexBatch.deleteAGsNotInRolloutCountries();
		Test.stopTest();

		System.assertEquals(0, selectAGs().size());
	}

	@IsTest
	static void deleteAGsNotInRolloutCountries_NegativeTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_AT_ON_Cash_Carry');
		insert acc;

		EUR_CRM_AccountGroup__c ag = makeAG(acc.Id);
		insert ag;

		EUR_CRM_AccountGroupUser__c agu = makeAGU(ag.Id, UserInfo.getUserId(), NEW_STATUS);
		insert agu;

		Test.startTest();
		EUR_CRM_AccountGroupComplexBatch.deleteAGsNotInRolloutCountries();
		Test.stopTest();

		System.assertEquals(1, selectAGs().size());
	}

	// End of deleteAGsNotInRolloutCountries() method tests

	@IsTest
	static void deleteUnnecessaryAGUs_PositiveTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_AT_ON_Cash_Carry');
		insert acc;

		EUR_CRM_AccountGroup__c ag = makeAG(acc.Id);
		insert ag;

		EUR_CRM_AccountGroupUser__c agu = makeAGU(ag.Id, UserInfo.getUserId(), NEW_STATUS);
		insert agu;

		Test.startTest();
		EUR_CRM_AccountGroupComplexBatch.deleteUnnecessaryAGUs();
		Test.stopTest();

		List<EUR_CRM_AccountGroup__c> ags = selectAGs();
		System.assertEquals(1, ags.size());
		System.assertEquals(0, ags[0].EUR_CRM_AccountGroupUsers__r.size());
	}

	@IsTest
	static void deleteUnnecessaryAGUs_NegativeTest() {

		User user1 = selectUsersWhereUserName('test.userA@mail.com');

		EUR_CRM_Account__c acc = makeAccount('EUR_AT_ON_Cash_Carry');
		insert acc;

		EUR_CRM_AccountGroup__c ag = makeAG(acc.Id);
		insert ag;

		EUR_CRM_AccountGroupUser__c agu = makeAGU(ag.Id, user1.Id, NEW_STATUS);
		insert agu;

		Test.startTest();
		EUR_CRM_AccountGroupComplexBatch.deleteUnnecessaryAGUs();
		Test.stopTest();

		List<EUR_CRM_AccountGroup__c> ags = selectAGs();
		System.assertEquals(1, ags.size());
		System.assertEquals(1, ags[0].EUR_CRM_AccountGroupUsers__r.size());
	}

	@IsTest
	static void integrationTest_forTwoAccounts_deleteUnnecessaryAGUs_PositiveTest() {
		//create users for agus
		User user1 = selectUsersWhereUserName('test.userA@mail.com');

		//create accounts
		EUR_CRM_Account__c acc1 = makeAccount('EUR_AT_ON_Cash_Carry');
		acc1.EUR_CRM_External_ID__c = 'ACC_EXT_ID_1';
		EUR_CRM_Account__c acc2 = makeAccount('EUR_AT_ON_Cash_Carry');
		acc2.EUR_CRM_External_ID__c = 'ACC_EXT_ID_2';
		insert new List<EUR_CRM_Account__c>{ acc1, acc2 };

		//create ags
		//ags for acc1
		EUR_CRM_AccountGroup__c ag1ForAcc1 = makeAG(acc1.Id);

		//ags for acc2
		EUR_CRM_AccountGroup__c ag1ForAcc2 = makeAG(acc2.Id);

		insert new List<EUR_CRM_AccountGroup__c>{ag1ForAcc1, ag1ForAcc2 };

		//create agus
		//agus for ags for acc1
		EUR_CRM_AccountGroupUser__c agu1ForAG1ForAcc1 = makeAGU(ag1ForAcc1.Id, UserInfo.getUserId(), NEW_STATUS); //status = new

		EUR_CRM_AccountGroupUser__c agu2ForAG1ForAcc1 = makeAGU(ag1ForAcc1.Id, user1.Id, NEW_STATUS); //status = new

		//agus for ags for acc2
		EUR_CRM_AccountGroupUser__c agu1ForAG1ForAcc2 = makeAGU(ag1ForAcc2.Id, UserInfo.getUserId(), NEW_STATUS); //status = new

		EUR_CRM_AccountGroupUser__c agu2ForAG1ForAcc2 = makeAGU(ag1ForAcc2.Id, user1.Id, NEW_STATUS); //status = new

		List<EUR_CRM_AccountGroupUser__c> agusToInsert = new List<EUR_CRM_AccountGroupUser__c>();
		agusToInsert.add(agu1ForAG1ForAcc1);
		agusToInsert.add(agu2ForAG1ForAcc1);

		agusToInsert.add(agu1ForAG1ForAcc2);
		agusToInsert.add(agu2ForAG1ForAcc2);

		insert agusToInsert;

		Test.startTest();
		EUR_CRM_AccountGroupComplexBatch.deleteUnnecessaryAGUs();
		Test.stopTest();

		List<EUR_CRM_AccountGroup__c> newAGs = selectAGs();
		System.assertEquals(2, newAGs.size());
		for (EUR_CRM_AccountGroup__c newAG : newAGs) {
			System.assertEquals(1, newAG.EUR_CRM_AccountGroupUsers__r.size());
			System.assertEquals(user1.Id, newAG.EUR_CRM_AccountGroupUsers__r[0].EUR_CRM_User__c);
		}
	}

	@IsTest
	static void integrationTest_whenAccountHasDuplicateAGUs_ThenCreateNewAGWithAGUs_And_DeleteOldAGs_PositiveTest() {
		//create users for agus
		User user1 = selectUsersWhereUserName('test.userA@mail.com');
		User user2 = selectUsersWhereUserName('test.userB@mail.com');
		User user3 = selectUsersWhereUserName('test.userC@mail.com');
		User user4 = selectUsersWhereUserName('test.userD@mail.com');

		//create account
		EUR_CRM_Account__c acc = makeAccount('EUR_AT_ON_Cash_Carry');
		acc.EUR_CRM_External_ID__c = 'ACC_EXT_ID';
		insert acc;

		//create ags
		EUR_CRM_AccountGroup__c ag1 = makeAG(acc.Id);
		EUR_CRM_AccountGroup__c ag2 = makeAG(acc.Id);
		EUR_CRM_AccountGroup__c ag3 = makeAG(acc.Id);
		insert new List<EUR_CRM_AccountGroup__c>{ag1, ag2, ag3};

		//create agus
		EUR_CRM_AccountGroupUser__c agu1ForAG1 = makeAGU(ag1.Id, user1.Id, NEW_STATUS); //leave status = new
		EUR_CRM_AccountGroupUser__c agu1ForAG2 = makeAGU(ag2.Id, user1.Id, RECORD_SHARED_STATUS); //update to status = record shared
		EUR_CRM_AccountGroupUser__c agu1ForAG3 = makeAGU(ag3.Id, user1.Id, TO_DELETE_STATUS); //update to status = to delete
		agu1ForAG3.EUR_CRM_Status__c = TO_DELETE_STATUS;

		EUR_CRM_AccountGroupUser__c agu2ForAG1 = makeAGU(ag1.Id, user2.Id, NEW_STATUS); //leave status = new
		EUR_CRM_AccountGroupUser__c agu2ForAG2 = makeAGU(ag2.Id, user2.Id, RECORD_SHARED_STATUS); //update to status = record shared

		EUR_CRM_AccountGroupUser__c agu3ForAG1 = makeAGU(ag1.Id, user3.Id, NEW_STATUS); //leave status = new
		EUR_CRM_AccountGroupUser__c agu3ForAG3 = makeAGU(ag3.Id, user3.Id, TO_DELETE_STATUS); //update to status = to delete

		EUR_CRM_AccountGroupUser__c agu4ForAG2 = makeAGU(ag2.Id, user4.Id, RECORD_SHARED_STATUS); //update to status = record shared
		EUR_CRM_AccountGroupUser__c agu4ForAG3 = makeAGU(ag3.Id, user4.Id, TO_DELETE_STATUS); //update to status = to delete
		List<EUR_CRM_AccountGroupUser__c> agusToInsert = new List<EUR_CRM_AccountGroupUser__c>();
		agusToInsert.add(agu1ForAG1);
		agusToInsert.add(agu1ForAG2);
		agusToInsert.add(agu1ForAG3);
		agusToInsert.add(agu2ForAG1);
		agusToInsert.add(agu2ForAG2);
		agusToInsert.add(agu3ForAG1);
		agusToInsert.add(agu3ForAG3);
		agusToInsert.add(agu4ForAG2);
		agusToInsert.add(agu4ForAG3);
		insert agusToInsert;

		Test.startTest();
		EUR_CRM_AccountGroupComplexBatch.mergeAGsInRolloutCountries();
		Test.stopTest();

		List<EUR_CRM_AccountGroup__c> newAGs = selectAGs();
		System.assertEquals(1, newAGs.size());
		System.assertEquals('AT', newAGs[0].EUR_CRM_Country_Code__c);
		System.assertEquals('ACC_EXT_ID', newAGs[0].EUR_CRM_External_ID__c);
		System.assertEquals(4, newAGs[0].EUR_CRM_AccountGroupUsers__r.size());
		for (EUR_CRM_AccountGroupUser__c agu : newAGs[0].EUR_CRM_AccountGroupUsers__r) {
			if (agu.EUR_CRM_User__c == user1.Id) { System.assertEquals(RECORD_SHARED_STATUS,agu.EUR_CRM_Status__c); }
			if (agu.EUR_CRM_User__c == user2.Id) { System.assertEquals(RECORD_SHARED_STATUS,agu.EUR_CRM_Status__c); }
			if (agu.EUR_CRM_User__c == user3.Id) { System.assertEquals(NEW_STATUS,agu.EUR_CRM_Status__c); }
			if (agu.EUR_CRM_User__c == user4.Id) { System.assertEquals(RECORD_SHARED_STATUS,agu.EUR_CRM_Status__c); }
		}
	}

	@IsTest
	static void integrationTest_forTwoAccounts_whenAccountHasDuplicateAGUs_ThenCreateNewAGWithAGUs_And_DeleteOldAGs_PositiveTest() {
		//create users for agus
		User user1 = selectUsersWhereUserName('test.userA@mail.com');
		User user2 = selectUsersWhereUserName('test.userB@mail.com');
		User user3 = selectUsersWhereUserName('test.userC@mail.com');
		User user4 = selectUsersWhereUserName('test.userD@mail.com');

		//create accounts
		EUR_CRM_Account__c acc1 = makeAccount('EUR_AT_ON_Cash_Carry');
		acc1.EUR_CRM_External_ID__c = 'ACC_EXT_ID_1';
		EUR_CRM_Account__c acc2 = makeAccount('EUR_AT_ON_Cash_Carry');
		acc2.EUR_CRM_External_ID__c = 'ACC_EXT_ID_2';
		insert new List<EUR_CRM_Account__c>{ acc1, acc2 };

		//create ags
		//ags for acc1
		EUR_CRM_AccountGroup__c ag1ForAcc1 = makeAG(acc1.Id);
		EUR_CRM_AccountGroup__c ag2ForAcc1 = makeAG(acc1.Id);
		EUR_CRM_AccountGroup__c ag3ForAcc1 = makeAG(acc1.Id);

		//ags for acc2
		EUR_CRM_AccountGroup__c ag1ForAcc2 = makeAG(acc2.Id);
		EUR_CRM_AccountGroup__c ag2ForAcc2 = makeAG(acc2.Id);
		EUR_CRM_AccountGroup__c ag3ForAcc2 = makeAG(acc2.Id);

		insert new List<EUR_CRM_AccountGroup__c>{ag1ForAcc1, ag2ForAcc1, ag3ForAcc1, ag1ForAcc2, ag2ForAcc2, ag3ForAcc2};

		//create agus
		//agus for ags for acc1
		EUR_CRM_AccountGroupUser__c agu1ForAG1ForAcc1 = makeAGU(ag1ForAcc1.Id, user1.Id, NEW_STATUS); //status = new
		EUR_CRM_AccountGroupUser__c agu1ForAG2ForAcc1 = makeAGU(ag2ForAcc1.Id, user1.Id, RECORD_SHARED_STATUS); //status = record shared
		EUR_CRM_AccountGroupUser__c agu1ForAG3ForAcc1 = makeAGU(ag3ForAcc1.Id, user1.Id, TO_DELETE_STATUS); //status = to delete

		EUR_CRM_AccountGroupUser__c agu2ForAG1ForAcc1 = makeAGU(ag1ForAcc1.Id, user2.Id, NEW_STATUS); //status = new
		EUR_CRM_AccountGroupUser__c agu2ForAG2ForAcc1 = makeAGU(ag2ForAcc1.Id, user2.Id, RECORD_SHARED_STATUS); //status = record shared

		EUR_CRM_AccountGroupUser__c agu3ForAG1ForAcc1 = makeAGU(ag1ForAcc1.Id, user3.Id, NEW_STATUS); //status = new
		EUR_CRM_AccountGroupUser__c agu3ForAG3ForAcc1 = makeAGU(ag3ForAcc1.Id, user3.Id, TO_DELETE_STATUS); //status = to delete

		EUR_CRM_AccountGroupUser__c agu4ForAG2ForAcc1 = makeAGU(ag2ForAcc1.Id, user4.Id, RECORD_SHARED_STATUS); //status = record shared
		EUR_CRM_AccountGroupUser__c agu4ForAG3ForAcc1 = makeAGU(ag3ForAcc1.Id, user4.Id, TO_DELETE_STATUS); //status = to delete

		//agus for ags for acc2
		EUR_CRM_AccountGroupUser__c agu1ForAG1ForAcc2 = makeAGU(ag1ForAcc2.Id, user1.Id, NEW_STATUS); //status = new
		EUR_CRM_AccountGroupUser__c agu1ForAG2ForAcc2 = makeAGU(ag2ForAcc2.Id, user1.Id, RECORD_SHARED_STATUS); //status = record shared
		EUR_CRM_AccountGroupUser__c agu1ForAG3ForAcc2 = makeAGU(ag3ForAcc2.Id, user1.Id, TO_DELETE_STATUS); //status = to delete

		EUR_CRM_AccountGroupUser__c agu2ForAG1ForAcc2 = makeAGU(ag1ForAcc2.Id, user2.Id, NEW_STATUS); //status = new
		EUR_CRM_AccountGroupUser__c agu2ForAG2ForAcc2 = makeAGU(ag2ForAcc2.Id, user2.Id, RECORD_SHARED_STATUS); //status = record shared

		EUR_CRM_AccountGroupUser__c agu3ForAG1ForAcc2 = makeAGU(ag1ForAcc2.Id, user3.Id, NEW_STATUS); //status = new
		EUR_CRM_AccountGroupUser__c agu3ForAG3ForAcc2 = makeAGU(ag3ForAcc2.Id, user3.Id, TO_DELETE_STATUS); //status = to delete

		EUR_CRM_AccountGroupUser__c agu4ForAG2ForAcc2 = makeAGU(ag2ForAcc2.Id, user4.Id, RECORD_SHARED_STATUS); //status = record shared
		EUR_CRM_AccountGroupUser__c agu4ForAG3ForAcc2 = makeAGU(ag3ForAcc2.Id, user4.Id, TO_DELETE_STATUS); //status = to delete
		List<EUR_CRM_AccountGroupUser__c> agusToInsert = new List<EUR_CRM_AccountGroupUser__c>();
		agusToInsert.add(agu1ForAG1ForAcc1);
		agusToInsert.add(agu1ForAG2ForAcc1);
		agusToInsert.add(agu1ForAG3ForAcc1);
		agusToInsert.add(agu2ForAG1ForAcc1);
		agusToInsert.add(agu2ForAG2ForAcc1);
		agusToInsert.add(agu3ForAG1ForAcc1);
		agusToInsert.add(agu3ForAG3ForAcc1);
		agusToInsert.add(agu4ForAG2ForAcc1);
		agusToInsert.add(agu4ForAG3ForAcc1);

		agusToInsert.add(agu1ForAG1ForAcc2);
		agusToInsert.add(agu1ForAG2ForAcc2);
		agusToInsert.add(agu1ForAG3ForAcc2);
		agusToInsert.add(agu2ForAG1ForAcc2);
		agusToInsert.add(agu2ForAG2ForAcc2);
		agusToInsert.add(agu3ForAG1ForAcc2);
		agusToInsert.add(agu3ForAG3ForAcc2);
		agusToInsert.add(agu4ForAG2ForAcc2);
		agusToInsert.add(agu4ForAG3ForAcc2);

		insert agusToInsert;

		Test.startTest();
		EUR_CRM_AccountGroupComplexBatch.mergeAGsInRolloutCountries();
		Test.stopTest();

		List<EUR_CRM_AccountGroup__c> newAGs = selectAGs();
		System.assertEquals(2, newAGs.size());
		for (EUR_CRM_AccountGroup__c newAG : newAGs) {
			if (newAG.EUR_CRM_Account__c == acc1.Id) { System.assertEquals('ACC_EXT_ID_1', newAG.EUR_CRM_External_ID__c); }
			if (newAG.EUR_CRM_Account__c == acc2.Id) { System.assertEquals('ACC_EXT_ID_2', newAG.EUR_CRM_External_ID__c); }
			System.assertEquals('AT', newAG.EUR_CRM_Country_Code__c);
			System.assertEquals(4, newAG.EUR_CRM_AccountGroupUsers__r.size());

			for (EUR_CRM_AccountGroupUser__c agu : newAG.EUR_CRM_AccountGroupUsers__r) {
				if (agu.EUR_CRM_User__c == user1.Id) { System.assertEquals(RECORD_SHARED_STATUS,agu.EUR_CRM_Status__c); }
				if (agu.EUR_CRM_User__c == user2.Id) { System.assertEquals(RECORD_SHARED_STATUS,agu.EUR_CRM_Status__c); }
				if (agu.EUR_CRM_User__c == user3.Id) { System.assertEquals(NEW_STATUS,agu.EUR_CRM_Status__c); }
				if (agu.EUR_CRM_User__c == user4.Id) { System.assertEquals(RECORD_SHARED_STATUS,agu.EUR_CRM_Status__c); }
			}
		}
	}
	// End of integration tests

	// Unit tests

	// Unit tests for updateAGs() method
	@IsTest
	private static void whenAccountHasOneAGWithNotEqualToAccountFields_ThenUpdateAGCountryCodeAndExternalId_PositiveTest() {
		EUR_CRM_Fake accF = new EUR_CRM_Fake(EUR_CRM_Account__c.class)
			.putField('EUR_CRM_Country_Code__c', 'GB')
			.putField('EUR_CRM_External_ID__c', 'ACC_EXT_ID');

		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF).build();

		accF.putChild('EUR_CRM_AccountGroups__r', ag);
		EUR_CRM_Account__c acc = (EUR_CRM_Account__c) accF.build();

		EUR_CRM_AccountGroupComplexBatch.Service service = new EUR_CRM_AccountGroupComplexBatch.Service();
		service.updateAGs(new List<EUR_CRM_Account__c>{acc});

		System.assertEquals(1, service.agToUpdateByAccId.size());
		System.assertEquals(0, service.accWithManyOldAGsByAccId.size());
		System.assertEquals('GB', service.agToUpdateByAccId.values()[0].EUR_CRM_Country_Code__c);
		System.assertEquals('ACC_EXT_ID', service.agToUpdateByAccId.values()[0].EUR_CRM_External_ID__c);
	}

	@IsTest
	private static void whenAccountHasManyAGWithNoAGUsAndNotEqualToAccountFields_ThenCreateNewAG_And_DeleteOldAGs_PositiveTest() {
		//create account
		EUR_CRM_Fake accF = new EUR_CRM_Fake(EUR_CRM_Account__c.class)
			.putField('EUR_CRM_Country_Code__c', 'GB')
			.putField('EUR_CRM_External_ID__c', 'ACC_EXT_ID');

		//create ag
		EUR_CRM_AccountGroup__c ag1 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		EUR_CRM_AccountGroup__c ag2 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		EUR_CRM_AccountGroup__c ag3 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		//add children to account
		accF.putChildren('EUR_CRM_AccountGroups__r', new List<EUR_CRM_AccountGroup__c>{ ag1, ag2, ag3 });
		EUR_CRM_Account__c acc = (EUR_CRM_Account__c) accF.build();

		//Stub selector
		EUR_CRM_AccountGroupComplexSelector selector = (EUR_CRM_AccountGroupComplexSelector) new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupComplexSelector.class)
			.withStub(new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
				.addArgument(Set<Id>.class)
				.returnValue(new List<EUR_CRM_AccountGroupUser__c>()))
			.getStubbedInstance();

		EUR_CRM_AccountGroupComplexBatch.Service service = new EUR_CRM_AccountGroupComplexBatch.Service(selector);
		service.updateAGs(new List<EUR_CRM_Account__c>{acc});

		System.assertEquals(0, service.agToUpdateByAccId.size());
		System.assertEquals(1, service.accWithManyOldAGsByAccId.size());
		System.assertEquals(1, service.agToInsertByAccId.size());
		System.assertEquals(3, service.agsToDeleteByAccId.values()[0].size());
		System.assertEquals('GB', service.agToInsertByAccId.values()[0].EUR_CRM_Country_Code__c);
		System.assertEquals('ACC_EXT_ID', service.agToInsertByAccId.values()[0].EUR_CRM_External_ID__c);
	}

	@IsTest
	private static void whenAccountHasManyAGWithAGUsAndNotEqualToAccountFields_ThenCreateNewAGWithAGUs_And_DeleteOldAGs_PositiveTest() {
		//create account
		EUR_CRM_Fake accF = new EUR_CRM_Fake(EUR_CRM_Account__c.class)
			.putField('EUR_CRM_Country_Code__c', 'GB')
			.putField('EUR_CRM_External_ID__c', 'ACC_EXT_ID');

		//create ag
		EUR_CRM_AccountGroup__c ag1 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		EUR_CRM_AccountGroup__c ag2 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		EUR_CRM_AccountGroup__c ag3 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		//create users for agus
		User u1 = (User) new EUR_CRM_Fake(User.class).build();
		User u2 = (User) new EUR_CRM_Fake(User.class).build();
		User u3 = (User) new EUR_CRM_Fake(User.class).build();


		//create agus for each ag
		EUR_CRM_AccountGroupUser__c agu1ForAG1 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', NEW_STATUS)
			.putParent('EUR_CRM_User__c', u1)
			.putParent('EUR_CRM_AccountGroup__c', ag1)
			.build();

		EUR_CRM_AccountGroupUser__c agu1ForAG2 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', RECORD_SHARED_STATUS)
			.putParent('EUR_CRM_User__c', u2)
			.putParent('EUR_CRM_AccountGroup__c', ag2)
			.build();

		EUR_CRM_AccountGroupUser__c agu1ForAG3 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', TO_DELETE_STATUS)
			.putParent('EUR_CRM_User__c', u3)
			.putParent('EUR_CRM_AccountGroup__c', ag3)
			.build();

		//add children to account
		accF.putChildren('EUR_CRM_AccountGroups__r', new List<EUR_CRM_AccountGroup__c>{ ag1, ag2, ag3 });
		EUR_CRM_Account__c acc = (EUR_CRM_Account__c) accF.build();

		//Stub selector
		EUR_CRM_AccountGroupComplexSelector selector = (EUR_CRM_AccountGroupComplexSelector) new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupComplexSelector.class)
			.withStub(new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
				.addArgument(Set<Id>.class)
				.returnValue(new List<EUR_CRM_AccountGroupUser__c>{agu1ForAG1, agu1ForAG2, agu1ForAG3}))
			.getStubbedInstance();

		EUR_CRM_AccountGroupComplexBatch.Service service = new EUR_CRM_AccountGroupComplexBatch.Service(selector);
		service.updateAGs(new List<EUR_CRM_Account__c>{acc});

		System.assertEquals(0, service.agToUpdateByAccId.size());
		System.assertEquals(1, service.accWithManyOldAGsByAccId.size());
		System.assertEquals(1, service.agToInsertByAccId.size());
		System.assertEquals(3, service.agsToDeleteByAccId.values()[0].size());
		System.assertEquals('GB', service.agToInsertByAccId.values()[0].EUR_CRM_Country_Code__c);
		System.assertEquals('ACC_EXT_ID', service.agToInsertByAccId.values()[0].EUR_CRM_External_ID__c);
		System.assertEquals(1, service.aguToInsertByUserIdByAccId.values().size());

		for (Map<Id, EUR_CRM_AccountGroupUser__c> aguByUserId : service.aguToInsertByUserIdByAccId.values()) {
			EUR_CRM_AccountGroupUser__c newAGU1 = aguByUserId.get(u1.Id);
			EUR_CRM_AccountGroupUser__c newAGU2 = aguByUserId.get(u2.Id);
			EUR_CRM_AccountGroupUser__c newAGU3 = aguByUserId.get(u3.Id);
			System.assertEquals(u1.Id, newAGU1.EUR_CRM_User__c);
			System.assertEquals(u2.Id, newAGU2.EUR_CRM_User__c);
			System.assertEquals(u3.Id, newAGU3.EUR_CRM_User__c);
			System.assertEquals(NEW_STATUS, newAGU1.EUR_CRM_Status__c);
			System.assertEquals(RECORD_SHARED_STATUS, newAGU2.EUR_CRM_Status__c);
			System.assertEquals(TO_DELETE_STATUS, newAGU3.EUR_CRM_Status__c);
		}
	}

	@IsTest
	private static void whenAccountHasDuplicateAGUs_ThenCreateNewAGWithAGUs_And_DeleteOldAGs_PositiveTest() {
		//create account
		EUR_CRM_Fake accF = new EUR_CRM_Fake(EUR_CRM_Account__c.class)
			.putField('EUR_CRM_Country_Code__c', 'GB')
			.putField('EUR_CRM_External_ID__c', 'ACC_EXT_ID');

		//create ag
		EUR_CRM_AccountGroup__c ag1 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		EUR_CRM_AccountGroup__c ag2 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		EUR_CRM_AccountGroup__c ag3 = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
			.putParent('EUR_CRM_Account__c', accF)
			.build();

		//create users for agus
		User u1 = (User) new EUR_CRM_Fake(User.class).build();
		User u2 = (User) new EUR_CRM_Fake(User.class).build();
		User u3 = (User) new EUR_CRM_Fake(User.class).build();
		User u4 = (User) new EUR_CRM_Fake(User.class).build();


		//create agus for each ag
		EUR_CRM_AccountGroupUser__c agu1ForAG1 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', NEW_STATUS)
			.putParent('EUR_CRM_User__c', u1)
			.putParent('EUR_CRM_AccountGroup__c', ag1)
			.build();
		EUR_CRM_AccountGroupUser__c agu1ForAG2 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', RECORD_SHARED_STATUS)
			.putParent('EUR_CRM_User__c', u1)
			.putParent('EUR_CRM_AccountGroup__c', ag2)
			.build();
		EUR_CRM_AccountGroupUser__c agu1ForAG3 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', TO_DELETE_STATUS)
			.putParent('EUR_CRM_User__c', u1)
			.putParent('EUR_CRM_AccountGroup__c', ag3)
			.build();


		EUR_CRM_AccountGroupUser__c agu2ForAG1 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', NEW_STATUS)
			.putParent('EUR_CRM_User__c', u2)
			.putParent('EUR_CRM_AccountGroup__c', ag1)
			.build();
		EUR_CRM_AccountGroupUser__c agu2ForAG3 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', TO_DELETE_STATUS)
			.putParent('EUR_CRM_User__c', u2)
			.putParent('EUR_CRM_AccountGroup__c', ag3)
			.build();


		EUR_CRM_AccountGroupUser__c agu3ForAG1 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', NEW_STATUS)
			.putParent('EUR_CRM_User__c', u3)
			.putParent('EUR_CRM_AccountGroup__c', ag1)
			.build();
		EUR_CRM_AccountGroupUser__c agu3ForAG2 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', RECORD_SHARED_STATUS)
			.putParent('EUR_CRM_User__c', u3)
			.putParent('EUR_CRM_AccountGroup__c', ag2)
			.build();


		EUR_CRM_AccountGroupUser__c agu4ForAG2 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', RECORD_SHARED_STATUS)
			.putParent('EUR_CRM_User__c', u4)
			.putParent('EUR_CRM_AccountGroup__c', ag2)
			.build();
		EUR_CRM_AccountGroupUser__c agu4ForAG3 = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
			.putField('EUR_CRM_Status__c', TO_DELETE_STATUS)
			.putParent('EUR_CRM_User__c', u4)
			.putParent('EUR_CRM_AccountGroup__c', ag3)
			.build();

		List<EUR_CRM_AccountGroupUser__c> returnValueForSelector = new List<EUR_CRM_AccountGroupUser__c>();
		returnValueForSelector.add(agu1ForAG1);
		returnValueForSelector.add(agu1ForAG2);
		returnValueForSelector.add(agu1ForAG3);
		returnValueForSelector.add(agu2ForAG1);
		returnValueForSelector.add(agu2ForAG3);
		returnValueForSelector.add(agu3ForAG1);
		returnValueForSelector.add(agu3ForAG2);
		returnValueForSelector.add(agu4ForAG2);
		returnValueForSelector.add(agu4ForAG3);

		//add children to account
		accF.putChildren('EUR_CRM_AccountGroups__r', new List<EUR_CRM_AccountGroup__c>{ ag1, ag2, ag3 });
		EUR_CRM_Account__c acc = (EUR_CRM_Account__c) accF.build();

		//Stub selector
		EUR_CRM_AccountGroupComplexSelector selector = (EUR_CRM_AccountGroupComplexSelector) new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupComplexSelector.class)
			.withStub(new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
				.addArgument(Set<Id>.class)
				.returnValue(returnValueForSelector))
			.getStubbedInstance();

		EUR_CRM_AccountGroupComplexBatch.Service service = new EUR_CRM_AccountGroupComplexBatch.Service(selector);
		service.updateAGs(new List<EUR_CRM_Account__c>{acc});

		System.assertEquals(0, service.agToUpdateByAccId.size());
		System.assertEquals(1, service.accWithManyOldAGsByAccId.size());
		System.assertEquals(1, service.agToInsertByAccId.size());
		System.assertEquals(3, service.agsToDeleteByAccId.values()[0].size());
		System.assertEquals('GB', service.agToInsertByAccId.values()[0].EUR_CRM_Country_Code__c);
		System.assertEquals('ACC_EXT_ID', service.agToInsertByAccId.values()[0].EUR_CRM_External_ID__c);
		System.assertEquals(1, service.aguToInsertByUserIdByAccId.values().size());

		for (Map<Id, EUR_CRM_AccountGroupUser__c> aguByUserId : service.aguToInsertByUserIdByAccId.values()) {
			EUR_CRM_AccountGroupUser__c newAGU1 = aguByUserId.get(u1.Id);
			EUR_CRM_AccountGroupUser__c newAGU2 = aguByUserId.get(u2.Id);
			EUR_CRM_AccountGroupUser__c newAGU3 = aguByUserId.get(u3.Id);
			EUR_CRM_AccountGroupUser__c newAGU4 = aguByUserId.get(u4.Id);
			System.assertEquals(u1.Id, newAGU1.EUR_CRM_User__c);
			System.assertEquals(u2.Id, newAGU2.EUR_CRM_User__c);
			System.assertEquals(u3.Id, newAGU3.EUR_CRM_User__c);
			System.assertEquals(u4.Id, newAGU4.EUR_CRM_User__c);
			System.assertEquals(RECORD_SHARED_STATUS, newAGU1.EUR_CRM_Status__c);
			System.assertEquals(NEW_STATUS, newAGU2.EUR_CRM_Status__c);
			System.assertEquals(RECORD_SHARED_STATUS, newAGU3.EUR_CRM_Status__c);
			System.assertEquals(RECORD_SHARED_STATUS, newAGU4.EUR_CRM_Status__c);
		}
	}


	/* ========================================================= */
	/*     Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = EUR_CRM_Account__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			RecordTypeId = rtId
			,   EUR_CRM_Postal_Code__c = '11223'
		);
	}

	private static EUR_CRM_AccountGroup__c makeAG(Id accId) {
		return new EUR_CRM_AccountGroup__c(
			EUR_CRM_Account__c = accId
		,   EUR_CRM_AllowDeletion__c = false
		,	EUR_CRM_Status__c = 'Normal'
		);
	}

	private static EUR_CRM_AccountGroupUser__c makeAGU(Id agId, Id uId, String status) {
		return new EUR_CRM_AccountGroupUser__c(
			EUR_CRM_AccountGroup__c = agId
		,   EUR_CRM_User__c = uId
		,   EUR_CRM_Status__c = status
		);
	}

	public static User makeUser(String profileName, String userEmail, String userName, String lastName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1][0];
		User u = new User(
			Alias = 'standt'
			,   Email = userEmail
			,   EmailEncodingKey = 'UTF-8'
			,   LastName = lastName
			,   LanguageLocaleKey = 'en_US'
			,   LocaleSidKey = 'en_US'
			,   ProfileId = p.Id
			,   TimeZoneSidKey = 'America/Los_Angeles'
			,   Username = userName
		);
		return u;
	}


	/* ========================================================= */
	/*     SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_AccountGroup__c> selectAGs() {
		return [
			SELECT Id
			,   EUR_CRM_Account__c
			,   EUR_CRM_External_ID__c
			,   EUR_CRM_Country_Code__c
			,   (
				SELECT Id
				,   EUR_CRM_User__c
				,   EUR_CRM_Status__c
				FROM EUR_CRM_AccountGroupUsers__r
			)
			FROM EUR_CRM_AccountGroup__c
		];
	}

	private static User selectUsersWhereUserName(String username) {
		return [
			SELECT Id
			FROM User
			WHERE Username = :username
			LIMIT 1
		][0];
	}
}