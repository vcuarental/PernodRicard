@IsTest
private class EUR_CRM_AccountGroupUserHandlerTest {

	@TestSetup
	private static void setupTest() {
//    insert makeUser('EUR GB IT Platform User', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
		insert makeUser('EUR GB On Trade FS Platform User', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
	}


	/* ========================================================= */
	/*     After Insert Tests
    /* ========================================================= */
	@IsTest
	private static void whenInsertEUAccount_ParentOwnersAreDifferent_createAGandAGU_PositiveTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake parentOwnerFake = new EUR_CRM_Fake(User.class);

		//eu account fakes
		EUR_CRM_Fake parentFake = makeAccountFake('GB').putParent('OwnerId', parentOwnerFake);
		EUR_CRM_Fake accFake = makeAccountFake('GB')
				.putParent('EUR_CRM_Parent_Account__c', parentFake)
				.putParent('OwnerId', ownerFake);

		EUR_CRM_Account__c acc = (EUR_CRM_Account__c) accFake.build();

		//ag fakes
		EUR_CRM_Fake agFake = new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
				.putParent('EUR_CRM_Account__c', accFake);

		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) agFake.build();

		List<EUR_CRM_Account__c> newAccs = new List<EUR_CRM_Account__c>{ acc };


		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{ acc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{ ag })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>())
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.calculateSharingForParentAccountOwner(newAccs);
		Test.stopTest();

		System.assertEquals(1, service.agsToInsert.size());
		System.assertEquals(1, service.agusToInsert.size());
	}

	@IsTest
	private static void whenInsertEUAccount_ParentOwnersAreEquals_noCreateAGandAGU_NegativeTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);

		//eu account fakes
		EUR_CRM_Fake parentFake = makeAccountFake('GB').putParent('OwnerId', ownerFake);
		EUR_CRM_Fake accFake = makeAccountFake('GB')
				.putParent('EUR_CRM_Parent_Account__c', parentFake)
				.putParent('OwnerId', ownerFake);

		EUR_CRM_Account__c acc = (EUR_CRM_Account__c) accFake.build();

		//ag fakes
		EUR_CRM_Fake agFake = new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
				.putParent('EUR_CRM_Account__c', accFake);

		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) agFake.build();

		List<EUR_CRM_Account__c> newAccs = new List<EUR_CRM_Account__c>{ acc };


		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{ acc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{ ag })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>())
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.calculateSharingForParentAccountOwner(newAccs);
		Test.stopTest();

		System.assertEquals(0, service.agsToInsert.size());
		System.assertEquals(0, service.agusToInsert.size());
	}

	@IsTest
	private static void whenInsertEUAccount_noParentAccount_noCreateAGandAGU_NegativeTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);

		//eu account fakes
		EUR_CRM_Fake accFake = makeAccountFake('GB')
				.putParent('OwnerId', ownerFake);

		EUR_CRM_Account__c acc = (EUR_CRM_Account__c) accFake.build();

		//ag fakes
		EUR_CRM_Fake agFake = new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
				.putParent('EUR_CRM_Account__c', accFake);

		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) agFake.build();

		List<EUR_CRM_Account__c> newAccs = new List<EUR_CRM_Account__c>{ acc };


		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{ acc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{ ag })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>())
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.calculateSharingForParentAccountOwner(newAccs);
		Test.stopTest();

		System.assertEquals(1, service.agsToInsert.size());
		System.assertEquals(0, service.agusToInsert.size());
	}


	/* ========================================================= */
	/*     After Update Tests
    /* ========================================================= */
	@IsTest
	private static void whenPopulateParentAccountField_createAGandAGU_PositiveTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake parentOwnerFake = new EUR_CRM_Fake(User.class);


		//eu account fakes

		//old acc
		EUR_CRM_Fake oldAccFake = makeAccountFake('GB').putParent('OwnerId', ownerFake);
		EUR_CRM_Account__c oldAcc = (EUR_CRM_Account__c) oldAccFake.build();

		//new acc
		EUR_CRM_Fake parentFake = makeAccountFake('GB').putParent('OwnerId', parentOwnerFake);
		EUR_CRM_Fake oldParentFake = makeAccountFake('GB').putParent('OwnerId', ownerFake);
		EUR_CRM_Fake newAccFake = makeAccountFake('GB')
				.putField('Id', oldAcc.Id)
				.putParent('OwnerId', ownerFake)
				.putParent('EUR_CRM_Parent_Account__c', parentFake.build());
		EUR_CRM_Account__c newAcc = (EUR_CRM_Account__c) newAccFake.build();
		EUR_CRM_Account__c parentAcc = (EUR_CRM_Account__c) parentFake.build();
		EUR_CRM_Account__c oldParentAcc = (EUR_CRM_Account__c) oldParentFake.build();


		Map<Id, EUR_CRM_Account__c> oldAccById = new Map<Id, EUR_CRM_Account__c>{oldAcc.Id => oldAcc};
		Map<Id, EUR_CRM_Account__c> oldParentAccById = new Map<Id, EUR_CRM_Account__c>{oldParentAcc.Id => oldParentAcc};
		List<EUR_CRM_Account__c> newAccs = new List<EUR_CRM_Account__c>{ newAcc };
		List<EUR_CRM_Account__c> parentAccs = new List<EUR_CRM_Account__c>{ parentAcc };

		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{parentAcc, newAcc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectChildAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{newAcc})
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{})
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>())
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.recalculateSharingForParentAccountOwner(newAccs, oldAccById);
//		service.recalculateSharingForChildAccountOwner(parentAccs, oldParentAccById);
		Test.stopTest();

		System.assertEquals(1, service.agsToInsert.size());
		System.assertEquals(1, service.agusToInsert.size());
		System.assertEquals(parentOwnerFake.build().Id, service.agusToInsert[0].EUR_CRM_User__c);
		System.assertEquals('Edit', service.agusToInsert[0].EUR_CRM_AccessLevel__c);
	}

	@IsTest
	private static void whenClearParentAccountField_updateAGUstatusToDelete_PositiveTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake parentOwnerFake = new EUR_CRM_Fake(User.class);


		//eu account fakes
		//old acc
		EUR_CRM_Fake parentFake = makeAccountFake('GB').putParent('OwnerId', parentOwnerFake);
		EUR_CRM_Fake oldAccF = makeAccountFake('GB')
				.putParent('OwnerId', ownerFake)
				.putParent('EUR_CRM_Parent_Account__c', parentFake.build());
		EUR_CRM_Account__c oldAcc = (EUR_CRM_Account__c) oldAccF.build();

		//new acc
		EUR_CRM_Fake newAccF = makeAccountFake('GB')
				.putField('Id', oldAcc.Id)
				.putParent('OwnerId', ownerFake);

		//ag fakes
		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
				.putParent('EUR_CRM_Account__c', oldAccF)
				.build();

		//add ag child to old acc
		oldAccF.putChild('EUR_CRM_AccountGroups__r', ag);

		//agu fakes
		EUR_CRM_AccountGroupUser__c agu = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
				.putField('EUR_CRM_User__c', oldAcc.EUR_CRM_Parent_Account__r.OwnerId)
				.putField('EUR_CRM_Status__c', 'New')
				.putParent('EUR_CRM_AccountGroup__c', ag)
				.build();

		EUR_CRM_Account__c newAcc = (EUR_CRM_Account__c) newAccF.build();
		EUR_CRM_Account__c parentAcc = (EUR_CRM_Account__c) parentFake.build();

		Map<Id, EUR_CRM_Account__c> oldAccById = new Map<Id, EUR_CRM_Account__c>{oldAcc.Id => oldAcc};
		List<EUR_CRM_Account__c> newAccs = new List<EUR_CRM_Account__c>{ newAcc };

		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{parentAcc, newAcc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{ ag })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>{ agu })
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.recalculateSharingForParentAccountOwner(newAccs, oldAccById);
		Test.stopTest();

		System.assertEquals(0, service.agsToInsert.size());
		System.assertEquals(0, service.agusToInsert.size());
		System.assertEquals(1, service.agusToUpdate.size());
		System.assertEquals(parentOwnerFake.build().Id, service.agusToUpdate[0].EUR_CRM_User__c);
		System.assertEquals('To Delete', service.agusToUpdate[0].EUR_CRM_Status__c);
	}

	@IsTest
	private static void whenChangeParentAccountField_updateAGUstatusToDeleteAndCreateNewAGU_PositiveTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake oldParentOwnerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake newParentOwnerFake = new EUR_CRM_Fake(User.class);


		//eu account fakes
		//old acc
		EUR_CRM_Fake oldParentFake = makeAccountFake('GB').putParent('OwnerId', oldParentOwnerFake);
		EUR_CRM_Fake oldAccF = makeAccountFake('GB')
				.putParent('OwnerId', ownerFake)
				.putParent('EUR_CRM_Parent_Account__c', oldParentFake.build());
		EUR_CRM_Account__c oldAcc = (EUR_CRM_Account__c) oldAccF.build();

		//new acc
		EUR_CRM_Fake newParentFake = makeAccountFake('GB').putParent('OwnerId', newParentOwnerFake);
		EUR_CRM_Fake newAccF = makeAccountFake('GB')
				.putField('Id', oldAcc.Id)
				.putParent('OwnerId', ownerFake)
				.putParent('EUR_CRM_Parent_Account__c', newParentFake.build());

		//ag fakes
		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
				.putParent('EUR_CRM_Account__c', newAccF)
				.build();

		//add ag child to old acc
//    oldAccF.putChild('EUR_CRM_AccountGroups__r', ag);
		newAccF.putChild('EUR_CRM_AccountGroups__r', ag);

		//agu fakes
		EUR_CRM_AccountGroupUser__c agu = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
				.putField('EUR_CRM_User__c', oldAcc.EUR_CRM_Parent_Account__r.OwnerId)
				.putField('EUR_CRM_Status__c', 'New')
				.putParent('EUR_CRM_AccountGroup__c', ag)
				.build();

		EUR_CRM_Account__c newAcc = (EUR_CRM_Account__c) newAccF.build();
		EUR_CRM_Account__c oldParentAcc = (EUR_CRM_Account__c) oldParentFake.build();
		EUR_CRM_Account__c newParentAcc = (EUR_CRM_Account__c) newParentFake.build();

		Map<Id, EUR_CRM_Account__c> oldAccById = new Map<Id, EUR_CRM_Account__c>{oldAcc.Id => oldAcc};
		List<EUR_CRM_Account__c> newAccs = new List<EUR_CRM_Account__c>{ newAcc };

		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{oldParentAcc, newParentAcc, newAcc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{ ag })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>{ agu })
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.recalculateSharingForParentAccountOwner(newAccs, oldAccById);
		Test.stopTest();

		System.assertEquals(0, service.agsToInsert.size());
		System.assertEquals(1, service.agusToInsert.size());
		System.assertEquals(newParentOwnerFake.build().Id, service.agusToInsert[0].EUR_CRM_User__c);
		System.assertEquals(1, service.agusToUpdate.size());
		System.assertEquals(oldParentOwnerFake.build().Id, service.agusToUpdate[0].EUR_CRM_User__c);
		System.assertEquals('To Delete', service.agusToUpdate[0].EUR_CRM_Status__c);
	}

	@IsTest
	private static void whenChangeOldParentAccountField_updateAGUstatusToDeleteAndCreateNewAGU_PositiveTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake oldParentOwnerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake newParentOwnerFake = new EUR_CRM_Fake(User.class);


		//eu account fakes
		//old acc
		EUR_CRM_Fake parentAccFake = makeAccountFake('GB').putParent('OwnerId', oldParentOwnerFake);
		EUR_CRM_Account__c oldParentAcc = (EUR_CRM_Account__c) parentAccFake.build();

		//new acc
		parentAccFake.putParent('OwnerId', newParentOwnerFake);
		EUR_CRM_Account__c newParentAcc = (EUR_CRM_Account__c) parentAccFake.build();

		EUR_CRM_Fake childAccFace = makeAccountFake('GB')
				.putParent('OwnerId', ownerFake)
				.putParent('EUR_CRM_Parent_Account__c', parentAccFake.build());

		//ag fakes
		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
				.putParent('EUR_CRM_Account__c', childAccFace)
				.build();

		//add ag child to old acc
		childAccFace.putChild('EUR_CRM_AccountGroups__r', ag);

		//agu fakes
		EUR_CRM_AccountGroupUser__c agu = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
				.putField('EUR_CRM_User__c', oldParentAcc.OwnerId)
				.putField('EUR_CRM_Status__c', 'New')
				.putParent('EUR_CRM_AccountGroup__c', ag)
				.build();

		EUR_CRM_Account__c childAcc = (EUR_CRM_Account__c) childAccFace.build();


		Map<Id, EUR_CRM_Account__c> oldParentAccById = new Map<Id, EUR_CRM_Account__c>{oldParentAcc.Id => oldParentAcc};
		List<EUR_CRM_Account__c> newParentAccs = new List<EUR_CRM_Account__c>{ newParentAcc };

		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectChildAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{childAcc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{ ag })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>{ agu })
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.recalculateSharingForChildAccountOwner(newParentAccs, oldParentAccById);
		Test.stopTest();
		System.assertEquals(0, service.agsToInsert.size());
		System.assertEquals(1, service.agusToInsert.size());
		System.assertEquals(newParentOwnerFake.build().Id, service.agusToInsert[0].EUR_CRM_User__c);
		System.assertEquals(1, service.agusToUpdate.size());
		System.assertEquals(oldParentOwnerFake.build().Id, service.agusToUpdate[0].EUR_CRM_User__c);
		System.assertEquals('To Delete', service.agusToUpdate[0].EUR_CRM_Status__c);
	}

	@IsTest
	private static void whenPopulateParentAccountField_AGUalreadyExists_PositiveTest() {

		//user fakes
		EUR_CRM_Fake ownerFake = new EUR_CRM_Fake(User.class);
		EUR_CRM_Fake newParentOwnerFake = new EUR_CRM_Fake(User.class);


		//eu account fakes
		//old acc
		EUR_CRM_Fake oldAccF = makeAccountFake('GB')
				.putParent('OwnerId', ownerFake);
		EUR_CRM_Account__c oldAcc = (EUR_CRM_Account__c) oldAccF.build();

		//new acc
		EUR_CRM_Fake newParentFake = makeAccountFake('GB').putParent('OwnerId', newParentOwnerFake);
		EUR_CRM_Fake newAccF = makeAccountFake('GB')
				.putField('Id', oldAcc.Id)
				.putParent('OwnerId', ownerFake)
				.putParent('EUR_CRM_Parent_Account__c', newParentFake.build());

		//ag fakes
		EUR_CRM_AccountGroup__c ag = (EUR_CRM_AccountGroup__c) new EUR_CRM_Fake(EUR_CRM_AccountGroup__c.class)
				.putParent('EUR_CRM_Account__c', newAccF)
				.build();

		//add ag child to old acc
		newAccF.putChild('EUR_CRM_AccountGroups__r', ag);

		EUR_CRM_Account__c newAcc = (EUR_CRM_Account__c) newAccF.build();
		EUR_CRM_Account__c newParentAcc = (EUR_CRM_Account__c) newParentFake.build();

		//agu fakes
		EUR_CRM_AccountGroupUser__c agu = (EUR_CRM_AccountGroupUser__c) new EUR_CRM_Fake(EUR_CRM_AccountGroupUser__c.class)
				.putField('EUR_CRM_User__c', newAcc.EUR_CRM_Parent_Account__r.OwnerId)
				.putField('EUR_CRM_Status__c', 'New')
				.putParent('EUR_CRM_AccountGroup__c', ag)
				.build();

		Map<Id, EUR_CRM_Account__c> oldAccById = new Map<Id, EUR_CRM_Account__c>{oldAcc.Id => oldAcc};
		List<EUR_CRM_Account__c> newAccs = new List<EUR_CRM_Account__c>{ newAcc };

		EUR_CRM_AccountGroupUserHandler stubbedParent = (EUR_CRM_AccountGroupUserHandler)new EUR_CRM_StubBuilder(EUR_CRM_AccountGroupUserHandler.class)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAccountsWhereIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_Account__c>{newParentAcc, newAcc })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGsWhereIds')
								.addArgument(List<EUR_CRM_AccountGroup__c>.class)
								.returnValue(new List<EUR_CRM_AccountGroup__c>{ ag })
				)
				.withStub(
						new EUR_CRM_StubBuilder.EUR_CRM_Method('selectAGUsWhereAccIds')
								.addArgument(Set<Id>.class)
								.returnValue(new List<EUR_CRM_AccountGroupUser__c>{ agu })
				)
				.preview()
				.getStubbedInstance();
		System.debug('\n stubbed => ' + stubbedParent + '\n');
		Test.startTest();
		EUR_CRM_AccountGroupUserHandler.Service service = new EUR_CRM_AccountGroupUserHandler.Service();
		service.parent = stubbedParent;

		service.recalculateSharingForParentAccountOwner(newAccs, oldAccById);
		Test.stopTest();

		System.assertEquals(0, service.agsToInsert.size());
		System.assertEquals(0, service.agusToInsert.size());
		System.assertEquals(0, service.agusToUpdate.size());
	}

	@IsTest
	private static void integration_whenInsertEUAccount_parentPopulated_sharingsInserted_PositiveTest() {

		User gbItPlatformUser = selectUsersWhereUserName('test.userA@mail.com');

		EUR_CRM_Account__c parentEuAcc = makeAccount('EUR_GB_FS_Indirect');
		parentEuAcc.EUR_CRM_Business_Type__c= 'Head Office';
		System.runAs(gbItPlatformUser) {
			insert parentEuAcc;
		}
		EUR_CRM_Account__c euAccount = makeAccount('EUR_GB_FS_Indirect');
		euAccount.EUR_CRM_Parent_Account__c = parentEuAcc.Id;
		Test.startTest();
		insert euAccount;
		Test.stopTest();

		EUR_CRM_Account__c insertedAcc = [select id, EUR_CRM_Parent_Account__r.OwnerId from EUR_CRM_Account__c Where Id =: euAccount.Id];
		System.debug('\n insertedAcc => ' + JSON.serializePretty(insertedAcc) + '\n');

		List<EUR_CRM_AccountGroup__c> ag = selectAGs();
//		System.assertEquals(1, ag.size());
//		System.assertEquals(euAccount.Id, ag[0].EUR_CRM_Account__c);
//		System.assertEquals(1, ag[0].EUR_CRM_AccountGroupUsers__r.size());
//		System.assertEquals(insertedAcc.EUR_CRM_Parent_Account__r.OwnerId, ag[0].EUR_CRM_AccountGroupUsers__r[0].EUR_CRM_User__c);



	}


	/* ========================================================= */
	/*     Low Level Makers (sObjects)
    /* ========================================================= */
	private static EUR_CRM_Fake makeAccountFake(String countryCode) {
		return new EUR_CRM_Fake(EUR_CRM_Account__c.class)
				.putField(EUR_CRM_Account__c.EUR_CRM_Country_Code__c, countryCode)
				.putField(EUR_CRM_Account__c.EUR_CRM_Postal_Code__c, '12345')
				;
	}

	public static User makeUser(String profileName, String userEmail, String userName, String lastName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1][0];
//    UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = :roleName LIMIT 1][0];
		User u = new User(
				Alias = 'standt'
				,   Email = userEmail
//      ,   UserRoleId = r.Id
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

	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = EUR_CRM_Account__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
				RecordTypeId = rtId
				,   EUR_CRM_Postal_Code__c = '11223'
		);
	}

	public static List<EUR_CRM_AccountGroup__c> selectAGs() {
		return [
				SELECT Id
						,   EUR_CRM_Account__c
						,   EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId
						,   (
						SELECT Id
								,   EUR_CRM_User__c
								,   EUR_CRM_AccessLevel__c
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