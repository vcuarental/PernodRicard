@isTest 
public class LAT_ClientByRegionHandlerTest {
	@testSetup
    public static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        
    }

	@isTest 
	static void testTrigger() {
		LAT_PromotionalAction__c ap = createAP();
		voidInsertAtt(ap.id);
		generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
		generateLATConfig('AP_SLA_COLLECTS', '10');
		ap.LAT_status__c = 'Ação aprovada';
		Test.startTest();
		update ap;


		LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
		

		update cbrOn;


		Test.stopTest();
	}

/*
	@isTest 
	static void testRegionalManagerMethods() {
    LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
    LAT_PromotionalAction__c ap = createAP();
    LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);

    //Testing Methods
    Map<String, LAT_RegionalSupervisor__c> rsMap = LAT_ClientByRegionHandler.getSupervisorMap();
		LAT_ClientByRegionHandler.assignRegionalManager(new List<LAT_ClientByRegion__c>{cbrOn});
    LAT_ClientByRegionHandler.validateSendToApproval(cbrOn.id);
    LAT_ClientByRegionHandler.shareRecords(new List<LAT_ClientByRegion__c>{cbrOn});
	}

	@isTest
	static void testCalculateAddedByRegion() {
	    LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
	    LAT_PromotionalAction__c ap = createAP();
	    LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
	    LAT_ClientByRegion__c cbrOff = createOffCBR(ap.id);
	    LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
		Test.startTest();
		LAT_ClientByRegionHandler.calculateAddedByRegion(new List<LAT_AccountInAction__c>{aiac});
	    LAT_ClientByRegionHandler.SendToApproval(ap.id);
	    LAT_ClientByRegionHandler.assignAccountInActions(new List<LAT_ClientByRegion__c>{cbrOn});
		LAT_ClientByRegionHandler.deleteClientByRegion(cbrOff.Id);
		LAT_PromotionalActionHandler.manageInitialTasks(aiac);
		Test.stopTest();
  }

	@isTest 
	static void testKPIandBrands() {
		LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
		LAT_PromotionalAction__c ap = createAP();
		LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
		LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
		voidInsertAtt(ap.id);

		generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
		generateLATConfig('AP_SLA_COLLECTS', '10');
		Test.startTest();
		LAT_ActionKPI__c kpi = createKPI(ap.Id);
		createBrand(ap.Id);
		insertMech(ap.Id);
		ap.LAT_status__c = 'Ação iniciada';
		update ap;
	 //Ação Finalizada

		//LAT_PromotionalActionHandler.generateKPIsAndBrandsForClients(ap.Id);
		Test.stopTest();
	}

	@isTest 
	static void testAction() {
		LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
		LAT_PromotionalAction__c ap = createAP();
		User u = getLAT_SystemAdminUser(userInfo.getUserId());
		System.runAs(u) {
			Test.startTest();
				generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
				generateLATConfig('AP_SLA_COLLECTS', '10');
				ap.LAT_status__c = 'Ação iniciada';
				update ap;
				LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
				LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
				voidInsertAtt(ap.id);

				LAT_ActionKPI__c kpi = createKPI(ap.Id);
				createBrand(ap.Id);
				insertMech(ap.Id);


				LAT_PromotionalActionHandler.notificarManagers(ap.id);
				LAT_PromotionalActionHandler.finaliceAction(ap.id);
				//LAT_PromotionalActionHandler.generateKPIsAndBrandsForClients(ap.Id);
			Test.stopTest();
		}

	}
*/
	// {
	// 	public static Messaging.SingleEmailMessage sendEmailPagamentos(LAT_ActionClientPayment__c acp) {
	//
	// }

	public static User getLAT_SystemAdminUser(Id userId) {
		Profile p = [SELECT Id FROM Profile WHERE Name='LAT_SystemAdministrator'];
		User u2 = [SELECT Id FROM User WHERE Profile.Name='LAT_SystemAdministrator' AND IsActive = true LIMIT 1];
		return u2;
	}
/*
	@isTest 
	static void testAction2() {
		LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
		LAT_PromotionalAction__c ap = createAP();
		voidInsertAtt(ap.id);
		generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
		generateLATConfig('AP_SLA_COLLECTS', '10');
		Test.startTest();

		ap.LAT_status__c = 'Ação aprovada';
		update ap;
		//LAT_PromotionalActionHandler.updatePromotionalActionFields(new String[]{ap.id});
		// LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
		// LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
		// aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
		// update aiac;



		Test.stopTest();
	}

	@isTest 
	static void testAction6() {
		LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
		LAT_PromotionalAction__c ap = createAP();
		voidInsertAtt(ap.id);
		generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
		generateLATConfig('AP_SLA_COLLECTS', '10');
		ap.LAT_status__c = 'Ação aprovada';
		update ap;


		LAT_PromotionalActionHandler.updatePromotionalActionFields(new String[]{ap.id});
		LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
		Test.startTest();
		LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
		aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
		update aiac;



		Test.stopTest();
	}

	@isTest 
	static void testAction4() {
		LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
		LAT_PromotionalAction__c ap = createAP();
		voidInsertAtt(ap.id);
		generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
		generateLATConfig('AP_SLA_COLLECTS', '10');
		LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
		LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
		Test.startTest();

		ap.LAT_status__c = 'Ação cancelada';
		update ap;



		aiac.LAT_Status__c = 'Ação aprovada';
		update aiac;



		Test.stopTest();
	}

	@isTest 
	static void testAction5() {
		LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
		LAT_PromotionalAction__c ap = createAP();
		voidInsertAtt(ap.id);
		generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
		generateLATConfig('AP_SLA_COLLECTS', '10');
		LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
		LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
		aiac.LAT_Status__c = 'Cliente Validado';
		Test.startTest();

		ap.LAT_status__c = 'Ação cancelada';
		update ap;



		aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
		update aiac;



		Test.stopTest();
	}




	@isTest static void testAction3() {
		LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
		LAT_PromotionalAction__c ap = createAP();
		voidInsertAtt(ap.id);
		generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
		generateLATConfig('AP_SLA_COLLECTS', '10');

				LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
				LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
		Test.startTest();

		aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
		update aiac;



		Test.stopTest();
	}

*/

	public static  void voidInsertAtt(Id ap) {
		Attachment att = new Attachment();
		att.Name='test';
		att.body = Blob.valueof('test');
		att.parentId = ap;
		insert att;

	}

	public static void insertMech(Id ap) {
		LAT_Mecanica__c m = new LAT_Mecanica__c();
		m.LAT_PromotionalAction__c = ap;
		m.LAT_Default__c = true;
		m.LAT_Mecanica__c ='mecanica';
		insert m;

	}
	public static void generateLATConfig(String name, String value) {
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		List<LAT_GeneralConfig__c> lg = [Select Name from LAT_GeneralConfig__c where Name =:name];
		if(lg.size() == 0) {
			lgc.Name = name;
			lgc.LAT_Value__c = value;
			insert lgc;
		}

	}


	public static LAT_ActionKPI__c createKPI(Id apId) {


		LAT_ActionKPIMaster__c k = new LAT_ActionKPIMaster__c();
		k.LAT_Description__c = 'test';
		k.LAT_KPI_OffTrade__c = true;
		k.LAT_KPI_OnTrade__c = true;
		k.LAT_KPI_Recurring__c = true;
		insert k;
		LAT_ActionKPI__c kpi = new LAT_ActionKPI__c();
		kpi.LAT_PromotionalAction__c = apId;
		kpi.LAT_KPI__c = k.Id;

		insert kpi;

		return kpi;

	}

	public static LAT_PromotionalActionKeyBrands__c createBrand(Id apId) {
		LAT_KeyBrand__c br = new LAT_KeyBrand__c();
		br.Name = 'Test';
		br.Active__c = true;
		br.Key__c = 'ABX';
		insert br;

		LAT_PromotionalActionKeyBrands__c k = new LAT_PromotionalActionKeyBrands__c();
		k.Promotional_Action__c = apId;
		k.LAT_KeyBrand__c = br.Id;

		insert k;

		return k;

	}

	//            List<LAT_PromotionalActionKeyBrands__c> brands = [Select Id, LAT_KeyBrand__c, LAT_BrandName__c,  Promotional_Action__c from LAT_PromotionalActionKeyBrands__c where Promotional_Action__c =: apID ];

/*
	@isTest 
	static void testValidateCloseTask() {
    LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
    LAT_PromotionalAction__c ap = createAP();
    LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
    Test.startTest();    
    LAT_AccountInAction__c aiac = createAccountInAction(ap.id);

    Task notif = LAT_ProcessesTaks.createTask(cbrOn.id, UserInfo.getUserId(), 'Validar Clientes Foco',
                        'msg', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalActionManagers'), 10, 'AP-Validar Clientes Foco');
    notif.LAT_PromotionalAction__c = ap.id;
    insert notif;

    LAT_ClientByRegionHandler.SendToApproval(cbrOn.id);
    LAT_ClientByRegionHandler.closeTask(cbrOn.id);
    LAT_ClientByRegionHandler.closeTask(notif.id);
	Test.stopTest();
	}

  @isTest 
  static void testValidateClients() {
    LAT_RegionalSupervisor__c rs = createSupervisor(userInfo.getUserId());
    LAT_PromotionalAction__c ap = createAP();
    LAT_ClientByRegion__c cbrOn = createOnCBR(ap.id);
    LAT_AccountInAction__c aiac = createAccountInAction(ap.id);
	Test.startTest();
    LAT_ClientByRegionHandler.ValidateClients(new List<String>{aiac.id});
    LAT_ClientByRegionHandler.sendChatterNotification(ap.id);
    Test.stopTest();
  }
*/
	public static LAT_PromotionalAction__c createAP() {
		LAT_PromotionalAction__c ap = new LAT_PromotionalAction__c();
		ap.LAT_BusinessCycle__c = 'H1';
		ap.LAT_StartDate__c = date.today();
		ap.LAT_EndDate__c = date.today().addDays(10);
		ap.LAT_Description__c = 'Testing';
		ap.LAT_Booster__c = 'Distribução';
		insert ap;

    return ap;
	}

	public static LAT_ClientByRegion__c createOnCBR(String apId) {
		LAT_ClientByRegion__c cbr = new LAT_ClientByRegion__c();
		cbr.LAT_Planejado__c = 10;
		cbr.Promotional_Action__c = apId;
		cbr.LAT_RegionalClientOnPremise__c = 'REG NE';
		cbr.RecordTypeId = Global_RecordTypeCache.getRtRec('LAT_ClientByRegion__c'+'LAT_OnTrade').id;
    cbr.LAT_Status__c = 'Pendente';
		insert cbr;

    return cbr;
	}

	public static LAT_ClientByRegion__c createOffCBR(String apId) {
		UDC__c regional =  createRegionalUDC();
		LAT_ClientByRegion__c cbr = new LAT_ClientByRegion__c();
		cbr.LAT_Planejado__c = 10;
		cbr.Promotional_Action__c = apId;
		cbr.RecordTypeId = Global_RecordTypeCache.getRtRec('LAT_ClientByRegion__c'+'LAT_OffTrade').id;
		cbr.LAT_Regional__c = regional.id;
    	cbr.LAT_Status__c = 'Pendente';
		insert cbr;

    return cbr;
	}

	public static UDC__c createRegionalUDC() {
		UDC__c udc = new UDC__c();
		List<UDC__c> udcL = [Select Internal_Id__c from UDC__c where  Internal_Id__c='1-1-01-01'];
		if(udCL.size() == 0){
			udc.CodDefUsuario__c = '1';
			udc.CodProd__c = '01';
			udc.CodUs__c = '01';
			udc.Internal_Id__c = '1-1-01-01';
			udc.RecordTypeId = Global_RecordTypeCache.getRtRec('UDC__c'+'BRA_Standard').id;
			insert udc;
		} else { udc = udcL.get(0);}


    return udc;
	}

	public static LAT_RegionalSupervisor__c createSupervisor(String userId) {
		LAT_RegionalSupervisor__c rs = new LAT_RegionalSupervisor__c();
		rs.Supervisor__c = userId;
		rs.LAT_RegionalClientOnPremise__c = 'REG NE';
		insert rs;

    return rs;
	}

  public static LAT_AccountInAction__c createAccountInAction(String apId) {
    Account acc = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
    acc.LAT_BR_RegionalClientOnPremise__c = 'REG NE';
    insert acc;

    LAT_AccountInAction__c aia = new LAT_AccountInAction__c();
    aia.LAT_Account__c = acc.id;
    aia.LAT_PromotionalAction__c = apId;
	aia.LAT_Status__c = 'Cliente Validado';
	aia.LAT_Execute__c = true;
    insert aia;

    return aia;
  }


}