@isTest
private class LAT_PromotionalActionHandlerTest {

    @isTest static void testBasicMethods() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
       

        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);

        
        LAT_PromotionalActionHandler pah = new LAT_PromotionalActionHandler();
        LAT_PromotionalActionHandler.initAction(new List<String>{ap.id});
        LAT_PromotionalActionHandler.generateTaskForNewClients(ap.Id);

        LAT_PromotionalActionHandler.sendEmail(new List<String>{'test@test.com'}, ap);




        Test.stopTest();

    }

    @isTest static void testBasicMethods2() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);

        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);
        LAT_PromotionalActionHandler.notificarManagers(ap.Id); 
        
        LAT_PromotionalActionHandler pah = new LAT_PromotionalActionHandler();
        LAT_PromotionalActionHandler.initAction(new List<String>{ap.id});
        LAT_PromotionalActionHandler.generateTaskForNewClients(ap.Id);

        LAT_PromotionalActionHandler.sendEmail(new List<String>{'test@test.com'}, ap);




        Test.stopTest();

    }

    @isTest static void testBasicMethodsPower() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);
        LAT_PromotionalActionHandler pah = new LAT_PromotionalActionHandler();
        LAT_PromotionalActionHandler.closePromotionalActionTasks(new List<String>{ap.id});
        LAT_PromotionalActionHandler.createPromotionalActionTasks(new List<String>{ap.id});
        //closePromotionalActionTasks(ids);
        //createPromotionalActionTasks(ids);
        Test.stopTest();

    }

    @isTest static void testBasicMethodsPower2() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);
        LAT_PromotionalActionHandler pah = new LAT_PromotionalActionHandler();
        LAT_PromotionalActionHandler.closePromotionalActionTasks(new List<String>{ap.id});
        LAT_PromotionalActionHandler.createPromotionalActionTasks(new List<String>{ap.id});
        //closePromotionalActionTasks(ids);
        //createPromotionalActionTasks(ids);
        Test.stopTest();

    }

    @isTest static void testBasicMethods4() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);
        LAT_PromotionalActionHandler.getAmmountOfDays();
        LAT_PromotionalActionHandler.pagarPromotionalActionTasks(ap.id);
        LAT_PromotionalActionHandler.pagarClienteActionTasks(aiac.id);

        List<Task> tList = new List<Task>();
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Coletar'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Iniciada'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Pagamento'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Cancelada'));
        LAT_PromotionalActionHandler.closeTasks(tList);

            //LAT_PromotionalActionHandler.sendEmail(new List<String>{'testing@testing.com'}, ap);
            LAT_PromotionalActionHandler.initPromotionalAction(ap.id);
            //LAT_PromotionalActionHandler.finaliceAction(ap.id);
            LAT_PromotionalActionHandler.cancelAction(ap.id);
            LAT_PromotionalActionHandler.sendToApproval(ap.id);
            LAT_PromotionalActionHandler.manageClosingTasks(tList.get(0).id);
            LAT_PromotionalActionHandler.implemetedActionFinished(tList, tList);
        Test.stopTest();

    }

     @isTest static void testBasicMethods5() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);

        LAT_PromotionalActionHandler.getAmmountOfDays();
        LAT_PromotionalActionHandler.pagarPromotionalActionTasks(ap.id);
        LAT_PromotionalActionHandler.pagarClienteActionTasks(aiac.id);

        List<Task> tList = new List<Task>();
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Coletar'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Iniciada'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Pagamento'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Cancelada'));
        LAT_PromotionalActionHandler.closeTasks(tList);


            LAT_PromotionalActionHandler.sendEmail(new List<String>{'testing@testing.com'}, ap);
            //LAT_PromotionalActionHandler.initPromotionalAction(ap.id);
            LAT_PromotionalActionHandler.finaliceAction(ap.id);
            ap.LAT_CancelationReason__c = 'test';
            update ap;
            LAT_PromotionalActionHandler.cancelAction(ap.id);
            //LAT_PromotionalActionHandler.sendToApproval(ap.id);
            //LAT_PromotionalActionHandler.manageClosingTasks(tList.get(0).id);
        Test.stopTest();

    }

     @isTest static void testBasicMethods9() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);

        LAT_PromotionalActionHandler.getAmmountOfDays();
        LAT_PromotionalActionHandler.pagarPromotionalActionTasks(ap.id);
        LAT_PromotionalActionHandler.pagarClienteActionTasks(aiac.id);

        List<Task> tList = new List<Task>();
        Task tk1 = LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Coletar');
        //tk1.LAT_Tipo__c =' AP-Apresentar Proposta ao Cliente';
        tk1.LAT_Tipo__c = ' AP-Apresentar Proposta ao Cliente';
        tk1.status  ='New';
        insert tk1;
        LAT_PromotionalActionHandler.manageClosingTasks(tk1.Id);
        //update tk1;
        tList.add(tk1);
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Iniciada'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Pagamento'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Cancelada'));
        LAT_PromotionalActionHandler.closeTasks(tList);

        aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
        update aiac;
        Test.stopTest();

    }

    @isTest static void testBasicMethods10() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);

        LAT_PromotionalActionHandler.getAmmountOfDays();
        LAT_PromotionalActionHandler.pagarPromotionalActionTasks(ap.id);
        LAT_PromotionalActionHandler.pagarClienteActionTasks(aiac.id);

        
        LAT_PromotionalActionHandler.manageInitialTasks(aiac);
        Test.stopTest();

    } 

    @isTest static void testBasicMethods14() {
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        test.startTest();
        LAT_ActionKPIMaster__c kpiMaster = createKPI();

        LAT_ActionKPI__c actionKPI = new LAT_ActionKPI__c();
        actionKPI.LAT_KPI__c = kpiMaster.id;
        actionKPI.LAT_PromotionalAction__c = ap.id;
        insert actionKPI;
        LAT_PromotionalActionHandler.getMockDataPromAction();
        LAT_PromotionalActionHandler.CreateAKKPIs(new List<LAT_ActionKPI__c>{actionKPI});

        Test.stopTest();

    } 

    @isTest static void testBasicMethods8() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
        Account acc = getAccount();
        Test.startTest();
        LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);

        LAT_PromotionalActionHandler.getAmmountOfDays();
        LAT_PromotionalActionHandler.pagarPromotionalActionTasks(ap.id);
        LAT_PromotionalActionHandler.pagarClienteActionTasks(aiac.id);

        List<Task> tList = new List<Task>();
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Coletar'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Iniciada'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Pagamento'));
        tList.add(LAT_PromotionalActionHandler.createTask(aiac.id, UserInfo.getUserId(), 'test', 'descript', 'Cancelada'));
        LAT_PromotionalActionHandler.closeTasks(tList);

        
           LAT_ActionClientPayment__c acp = new LAT_ActionClientPayment__c(LAT_AccountInAction__c = aiac.id);
        insert acp;

        LAT_ActionClientPaymentLine__c acpl1 = new LAT_ActionClientPaymentLine__c();
        acpl1.LAT_Description__c = 'description1';
        acpl1.LAT_Value__c = 10;
        acpl1.LAT_ActionClientPayment__c = acp.id;
        insert acpl1;
        LAT_PromotionalActionHandler.sendEmailPagamentos( acp);
            
        Test.stopTest();

    }

    public static LAT_AccountInAction__c createAccountInAction(String apId, String accId) {


        LAT_AccountInAction__c aia = new LAT_AccountInAction__c();
        aia.LAT_Account__c = accId;
        aia.LAT_PromotionalAction__c = apId;
        aia.LAT_Status__c = 'Cliente Validado';
        aia.LAT_Execute__c = true;
        insert aia;

        return aia;
    }

    public static Account getAccount(){
        Account acc = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
        acc.LAT_BR_RegionalClientOnPremise__c = 'REG NE';
        insert acc;
        return acc;
    }

    public static LAT_ActionKPIMaster__c createKPI() {
        LAT_ActionKPIMaster__c master = new LAT_ActionKPIMaster__c();
        master.LAT_Description__c = 'Testing';
        master.LAT_Type__c = 'Number';
        insert master;

        return master;
    }

}