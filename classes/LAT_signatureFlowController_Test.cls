@isTest
private class LAT_signatureFlowController_Test {

	@isTest static void test_method_one() {
		insert new LAT_GeneralConfig__c (Name= 'LAT_CONTRACT_CARTA_ACORDO_MAX_VALUE', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_OnTrade_LetterAgreementCommercialCondition');
		insert con;
		System.CurrentPageReference().getParameters().put('item','1');
		ApexPages.StandardController stdCon = new ApexPages.StandardController(con);
		LAT_signatureFlowController controller = new LAT_signatureFlowController(stdCon);
		controller.labels = new Map<String, String>();
		controller.labels.put('test','test');
		controller.chatterPost();
		controller.updateSignature();
		controller.insertChatterMessage(7, 'conName', 'Accountname');
		String[] emails = new String[1];
		emails[0] = 'test@test.com';
		controller.sendEmailNotification(1, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));

		controller.sendEmailNotification(2, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));


		controller.sendEmailNotification(3, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));
		System.CurrentPageReference().getParameters().put('item','3');
		controller.updateSignature();

		LAT_ContractErrorsController errorCont = new LAT_ContractErrorsController(stdCon);
		LAT_ContractErrorsController.letterOfAgreementValidation(new List<LAT_Contract2__c>{con});

	}
   	@isTest static void test_method_two() {
		insert new LAT_GeneralConfig__c (Name= 'LAT_CONTRACT_CARTA_ACORDO_MAX_VALUE', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_OnTrade_LetterAgreementCommercialCondition');
		insert con;
		System.CurrentPageReference().getParameters().put('item','0');
		ApexPages.StandardController stdCon = new ApexPages.StandardController(con);
		LAT_signatureFlowController controller = new LAT_signatureFlowController(stdCon);
		controller.labels = new Map<String, String>();
		controller.labels.put('test','test');
		controller.chatterPost();
		controller.updateSignature();
		controller.insertChatterMessage(7, 'conName', 'Accountname');
		String[] emails = new String[1];
		emails[0] = 'test@test.com';
		controller.sendEmailNotification(1, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));

		controller.sendEmailNotification(2, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));


		controller.sendEmailNotification(3, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));
		System.CurrentPageReference().getParameters().put('item','3');
		controller.updateSignature();

		// LAT_ContractErrorsController errorCont = new LAT_ContractErrorsController(stdCon);
		// LAT_ContractErrorsController.letterOfAgreementValidation(new List<LAT_Contract2__c>{con});

	}

	@isTest static void test_method_three() {
		insert new LAT_GeneralConfig__c (Name= 'LAT_CONTRACT_CARTA_ACORDO_MAX_VALUE', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_OnTrade_LetterAgreementCommercialCondition');
		insert con;
		System.CurrentPageReference().getParameters().put('item','0');
		ApexPages.StandardController stdCon = new ApexPages.StandardController(con);
		LAT_signatureFlowController controller = new LAT_signatureFlowController(stdCon);
		// controller.labels = new Map<String, String>();
		// controller.labels.put('test','test');
		// controller.chatterPost();
		// controller.updateSignature();
		// controller.insertChatterMessage(7, 'conName', 'Accountname');
		// String[] emails = new String[1];
		// emails[0] = 'test@test.com';
		// controller.sendEmailNotification(1, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));
		//
		// controller.sendEmailNotification(2, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));
		//
		//
		// controller.sendEmailNotification(3, emails, Double.valueOf(1000.00), con.Name, String.valueOf(con.Id));
		// System.CurrentPageReference().getParameters().put('item','3');
		// controller.updateSignature();
		Test.startTest();
		LAT_ContractErrorsController errorCont = new LAT_ContractErrorsController(stdCon);
		LAT_ContractErrorsController.letterOfAgreementValidation(new List<LAT_Contract2__c>{con});
		Test.stopTest();

	}


}