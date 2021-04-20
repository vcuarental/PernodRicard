/********************************************************************************
 *  This class contains unit tests for validating the behavior of Apex classes
 *  and triggers.
 *
 *  Unit tests are class methods that verify whether a particular piece
 *  of code is working properly. Unit test methods take no arguments,
 *  commit no data to the database, and are flagged with the testMethod
 *  keyword in the method definition.
 *
 *  All test methods in an organization are executed whenever Apex code is
 *  deployed to a production organization to confirm correctness, ensure code
 *  coverage, and prevent regressions. All Apex classes are required to have at
 *  least 75% code coverage in order to be deployed to a production organization.
 *  In addition, all triggers must have some code coverage.
 *
 *  The @isTest class annotation indicates this class only contains test
 *  methods. Classes defined with the @isTest annotation do not count against
 *  the organization size limit for all Apex scripts.
 *
 *  See the Apex Language Reference for more information about Testing
 *  and Code Coverage.
 *
 * Name     :   GDT_SetupAuditTrail_TEST.cls
 * 
 * Author   :   Simon GAZIN
 * Date     :   12.11.2015=
 *********************************************************/
@isTest(SeeAllData=false)
private class GDT_SetupAuditTrail_TEST { 

	@isTest static void test_method_one() {
		Test.startTest();

			GDT_GeneralConfig__c flagGDT = new GDT_GeneralConfig__c(name = 'GDT_SetupAuditTrail_isActive', GDT_Value__c = 'true');
        	insert flagGDT;

        	GDT_GeneralConfig__c retDaysGDT = new GDT_GeneralConfig__c(name = 'GDT_SetupAuditTrail_RetentionInDays', GDT_Value__c = '10');
        	insert retDaysGDT;

        	GDT_SetupAuditTrail_SectionAction__c secAct = createSectionAction('changedApexClass', 'Apex Class',true, false);
        	insert secAct;


			//Instantiate a new controller with all parametres in the page
			GDT_Setup_Audit_Trail__c cObj = createAuditTrail('name', 'changedApexClass', UserInfo.getUserId(),null, 'Changed ASI_CRM_SG_ContractManageAll_Ctrl Apex Class code', 'Apex Class');
			insert cObj;

			/* Batch  */
			GDT_SetupAuditTrail_Controller satc = new GDT_SetupAuditTrail_Controller();
			GDT_SetupAuditTrail_Controller.getAuditTrails('2019-04-04', '2019-04-04', True);	
			GDT_SetupAuditTrail_Controller.runBatch();

		
			/* Scheduler */
			GDT_SetupAuditTrail_Scheduler scheduledTest = new GDT_SetupAuditTrail_Scheduler();
			String strScheduler = '0 0 9 * * ?';
			system.schedule('Test GDT_SetupAuditTrail_Scheduler', strScheduler, scheduledTest);

			GDT_SetupAuditTrail_Batch batchB = new GDT_SetupAuditTrail_Batch();
			batchB.execute(null, [SELECT Action,CreatedById,CreatedBy.username, CreatedDate,Display,Id,Section,DelegateUser FROM SetupAuditTrail where CreatedDate >= last_n_days:5]);

		Test.stopTest();
	}

	public static GDT_SetupAuditTrail_SectionAction__c createSectionAction(String action , String section, Boolean section_to_control , Boolean action_to_control){
		GDT_SetupAuditTrail_SectionAction__c obj = new GDT_SetupAuditTrail_SectionAction__c();
		obj.name = 'name';
		obj.Action__c = action;
		obj.Section__c = section;
		obj.Section_to_control__c = section_to_control;
		obj.Action_to_control__c = action_to_control;
		return obj;
	}


	public static GDT_Setup_Audit_Trail__c createAuditTrail(String name, String action, String createdById, String delegateUser, String display, String section){
		GDT_Setup_Audit_Trail__c cObj_SetupAuditTrail = new GDT_Setup_Audit_Trail__c();
		cObj_SetupAuditTrail.Name               = name;
		cObj_SetupAuditTrail.Action__c          = action;
		cObj_SetupAuditTrail.CreatedById__c     = createdById;
		cObj_SetupAuditTrail.CreatedDate__c     = Datetime.now();
		cObj_SetupAuditTrail.DelegateUser__c    = delegateUser;
		cObj_SetupAuditTrail.Display__c         = display;
		cObj_SetupAuditTrail.Section__c         = section;
		return cObj_SetupAuditTrail;

	}



}