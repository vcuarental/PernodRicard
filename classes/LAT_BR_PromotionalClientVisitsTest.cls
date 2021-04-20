@isTest
private class LAT_BR_PromotionalClientVisitsTest {

    @isTest static void basicTest() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
    LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
    LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
    LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
    LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);

        Task notif = LAT_ProcessesTaks.createTask(aiac.id, UserInfo.getUserId(), 'Validar Clientes Foco',
                                                'msg', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalActionManagers'), 10, 'AP-Validar Clientes Foco');
        notif.LAT_PromotionalAction__c = ap.id;
        insert notif;

        Task t = LAT_ProcessesTaks.createTask(aiac.id, UserInfo.getUserId(), 'test', 'msg', Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),10,'POP-Distribuicao Regional');
        insert t;

        Test.startTest();

            generateBasicData();
            LAT_BR_PromotionalClientVisitsController pcvc = new LAT_BR_PromotionalClientVisitsController();
            LAT_BR_PromotionalClientVisitsController.TaskWrapper tw = new LAT_BR_PromotionalClientVisitsController.TaskWrapper(true, new Task());
            if (!pcvc.taskList.isEmpty()) pcvc.taskList.get(0).selected = true;
            pcvc.doSave();
            t.status = 'Completed';
            update t;
        Test.stopTest();
    }

    static void generateBasicData() {
        Account acc = [SELECT id FROM Account LIMIT 1];

        Planejamento__c plan = new Planejamento__c();
        plan.Ano_de_Referencia__c = '2012';
        plan.M_s_de_Ref_rencia__c = 'Janeiro';
        plan.Name = 'Teste';
        plan.OwnerId = UserInfo.getUserId();//usuario.Id;
        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
        //insert plan;
        try{insert plan;}catch(Exception e){}

        Id idRecTypeVis = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
        //Cria nova visita
        Visitas__c visita = new Visitas__c(
            Name = 'Teste',
            Data_da_Visita__c = System.today(),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = plan.Id,
            Tipo_de_Visita__c = 'Execução',
            Conta__c = acc.Id,
            Status__c = 'Planejada',
            RecordTypeId = idRecTypeVis,
            Resumo_da_Visita__c = 'Teste'
        );
        //insert visita;
        try{insert visita;}catch(Exception e){}
        ApexPages.CurrentPage().getparameters().put('visitId', visita.id);
    }
}