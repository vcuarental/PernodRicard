@isTest
private class LAT_SchemaBuilderDashBoardCont_Test {
	
	@isTest static void test_LAT_SchemaBuilderDashBoardControllere() {
		LAT_SchemaBuilderDashBoardController cont = new LAT_SchemaBuilderDashBoardController();

		
		cont.formSearchTerm = 'TEST';
		cont.nextBatch();
		cont.getHasMoreForms();
		cont.fetchForms();
		cont.getMyForms();
		cont.formBeginning();
		cont.changeSearch();
		cont.formSearchTerm = 'TEST';
		cont.changeSearch();
		cont.formIndex = 20;
		cont.formPrevious();
		cont.formNext();
		cont.formEnd();
		cont.getformPrev();
		cont.getformNxt();
		cont.getCurrentPage();

		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Draft');
		insert schemaParent;
		LAT_SchemaBuilderDashBoardController.cloneSchema('Test2', schemaParent.Id);

	}

	@isTest static void test_LAT_wakawakaForm() {
		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Active');
		insert schemaParent;

		PageReference pf = Page.LAT_wakawakaForm;
        pf.getParameters().put('id',schemaParent.Id);
        Test.setCurrentPage(pf);
        LAT_wakawakaForm cont = new LAT_wakawakaForm();

		cont.checkIfEntryExists();
		LAT_wakawakaForm.getSalesforceObject('LAT_SKU__c', 'LAT_Product__c', 'TEST', 'LAT_SKU__c=#Mexico#');

		LAT_wakawakaForm.saveSalesforceObject('LAT_FormBuilderSchema__c', '{"Country__c":"Mexico"}');
		//LAT_wakawakaForm.getUserMail();

		//LAT_wakawakaForm.sendEmail('test', 'test', new List<String>{'test@zimmic.com'});

		LAT_FormBuilderEntries__c entry = new LAT_FormBuilderEntries__c();
        entry.Status__c = 'Draft';
        entry.Fields_Populated__c = 0;
        entry.Form_Builder_Schema__c = schemaParent.Id;
        entry.jsonData__c = '[]';
        insert entry;
        LAT_wakawakaForm.doUploadAttachment(entry.Id, 'Test Body', 'Test', null);

	}

	@isTest static void test_LAT_wakawakaFormsController() {
		LAT_wakawakaFormsController cont1 = new LAT_wakawakaFormsController();
		cont1.saveSchema();
		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Draft');
		insert schemaParent;

		PageReference pf = Page.LAT_wakawakaForms;
        pf.getParameters().put('id',schemaParent.Id);
        Test.setCurrentPage(pf);
        LAT_wakawakaFormsController cont = new LAT_wakawakaFormsController();

		
		cont.publish();	
		LAT_wakawakaFormsController.getObjectsList();
		LAT_wakawakaFormsController.getObjects();	
		LAT_wakawakaFormsController.getPages(schemaParent.id);
		LAT_wakawakaFormsController.getFields('LAT_Product__c');
		

	}

	@isTest static void test_LAT_wakawakaPageBuilderController() {
		
		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Draft');
		insert schemaParent;

		PageReference pf = Page.LAT_wakawakaPageBuilder;
        pf.getParameters().put('id',schemaParent.Id);
        Test.setCurrentPage(pf);
        LAT_wakawakaPageBuilderController cont = new LAT_wakawakaPageBuilderController();
		
		LAT_wakawakaPageBuilderController.getSalesforceObject('LAT_SKU__c', 'LAT_Product__c', 'TEST', 'LAT_SKU__c=#Mexico#');
		

	}

	@isTest static void test_LAT_SchemaBuilderConnectionController() {
		
		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Draft');
		insert schemaParent;

		PageReference pf = Page.LAT_SchemaBuilderConnection;
        pf.getParameters().put('schema',schemaParent.Id);
        Test.setCurrentPage(pf);
        LAT_SchemaBuilderConnectionController cont = new LAT_SchemaBuilderConnectionController();
			
		LAT_SchemaBuilderConnectionController.getFields('LAT_Product__c');
		

	}

	@isTest static void test_LAT_RestAuditSurveyServices() {
		
		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Draft');
		insert schemaParent;
		Test.startTest();
		RestContext.response = new RestResponse();
		RestContext.request  = new RestRequest();
		LAT_RestAuditSurveyServices.post(UserInfo.getUserId(), null);
		LAT_RestAuditSurveyServices.post(UserInfo.getUserId(), Datetime.now());

		LAT_FormBuilderEntries__c entry = new LAT_FormBuilderEntries__c();
        entry.Status__c = 'Draft';
        entry.Fields_Populated__c = 0;
        entry.Form_Builder_Schema__c = schemaParent.Id;
        entry.jsonData__c = '[]';
        insert entry;
		
		RestContext.request.params.put('sfdcId', entry.Id);
		LAT_RestAuditSurveyServices.getEntryById();
		RestContext.request.params.put('sfdcId', null);
		LAT_RestAuditSurveyServices.getEntryById();

		Test.stopTest();
		
	}
	

	@isTest static void test_LAT_UserDashBoardController() {
		
		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Draft');
		insert schemaParent;

		LAT_FormBuilderShare__c share = new LAT_FormBuilderShare__c(
			LAT_FormBuilderSchema__c = schemaParent.Id,   
			LAT_AccessLevel__c = 'Fill', 
			LAT_User__c = UserInfo.getUserId() 
			);
		insert share;

		PageReference pf = Page.LAT_SchemaBuilderConnection;
        pf.getParameters().put('schema',schemaParent.Id);
        Test.setCurrentPage(pf);
        LAT_UserDashBoardController cont = new LAT_UserDashBoardController();
        cont.entrySearchTerm = 'Test';
		cont.fetchEntries(new Set<Id>{schemaParent.Id});
		LAT_UserDashBoardController.getMySchemaForms(UserInfo.getUserId());
		cont.nextBatch();
		cont.entryBeginning();
		cont.changeSearch();
		cont.entrySearchTerm = 'Testq';		
		cont.changeSearch();		
		cont.getHasMoreForms();	
		cont.getCurrentPage();	
		cont.getEntryNxt();	
		cont.getEntryPrev();

	}

	@isTest static void test_LAT_SchemaBuilderShareController() {
		
		LAT_FormBuilderSchema__c schemaParent = new LAT_FormBuilderSchema__c(
				Name = 'Test', Country__c= 'Mexico' , Status__c = 'Draft');
		insert schemaParent;

		LAT_FormBuilderShare__c share = new LAT_FormBuilderShare__c(
			LAT_FormBuilderSchema__c = schemaParent.Id,   
			LAT_AccessLevel__c = 'Fill', 
			LAT_User__c = UserInfo.getUserId() 
			);
		insert share;

		PageReference pf = Page.LAT_SchemaBuilderShare;
        pf.getParameters().put('id',schemaParent.Id);
        Test.setCurrentPage(pf);
        LAT_SchemaBuilderShareController cont = new LAT_SchemaBuilderShareController();

        LAT_SchemaBuilderShareController.updateSharePerms('Fill', share.Id);
        LAT_SchemaBuilderShareController.SavePerm('user', 'Test', UserInfo.getUserId(), 'View', schemaParent.Id);
        LAT_SchemaBuilderShareController.deletePermission(share.Id);
		

	}

}