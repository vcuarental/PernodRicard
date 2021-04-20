@isTest(seeAlldata=false)
private class LAT_BR_VFC16_PendingApprovalReport_Test {
  
  @isTest static void test_method_one() {
      //Cria novo usuario. 

      Utils.setMigrationDoneTest(false);
    Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    acc.Status__c = 'Novo cadastro';
    insert acc;
    User gerente = new User();
    gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    Database.Saveresult sResult = Database.insert( gerente, false );
    system.assert( sResult.isSuccess() );
    
    //Cria novo usuario.
    User usuario = new User();
    usuario.FirstName           = 'nome';
    usuario.LastName            = 'Sobrenome';
    usuario.Alias               = 'NSobres';
    usuario.Email               = 'nome@sobrenome.com';
    usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
    usuario.CommunityNickname   = '1234jjuuu';
    usuario.EmailEncodingKey    = 'ISO-8859-1';
    usuario.TimeZoneSidKey      = 'GMT';
    usuario.LocaleSidKey        = 'en_Us';
    usuario.LanguageLocaleKey   = 'en_Us';
    usuario.C_digo_JDE__c       = '235';
    usuario.ProfileId           = gerente.ProfileId;
    usuario.Gerente_de_area__c  = gerente.Id;
    usuario.Gerente_regional__c = gerente.Id;
    usuario.ManagerId           = gerente.Id;
    usuario.Country = 'BR';

    insert usuario;
    System.runAs(usuario) {  
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ acc.OwnerId});
        req.setObjectId( acc.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
    }
    Test.startTest();
    LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(
            LAT_VisualForceName__c = 'LAT_BR_VFP22_PendingApprovalReport'
        );
        insert crp;

        ApexPages.currentPage().getParameters().put('IdRep', crp.Id);
        LAT_BR_VFC16_PendingApprovalReportCont cont = new LAT_BR_VFC16_PendingApprovalReportCont();
        LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper aw2 = 
            new LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper('Test', acc.name, 'clientRating', 'Account',
                                             'TargetObject.Type', 'lastApprover', usuario.Id, 'CreatedBy.Regional_de_vendas__c',
                               Date.today(), 'justificationSeg', acc.Id, acc.Id);
        cont.wrapperList.add(aw2);    
    cont.filters = new LAT_BR_VFC16_PendingApprovalReportCont.reportFilters();
    cont.applyFilters();

    cont.filters.createdByRegional.Regional_de_vendas__c = 'Test';
    cont.filters.client.ParentId = acc.Id;
    cont.filters.relatedTo = 'Test';
    cont.applyFilters();

    cont.filters.currentApprover.OwnerId = UserInfo.getUserId();
    cont.filters.DateStart.CloseDate = Date.today();
    cont.filters.DateEnd.CloseDate = Date.today();
    cont.applyFilters();
    Case nullCase = new Case();
    Opportunity nullOppy = new Opportunity();
    system.assertEquals('-', cont.getClientName(null, null, nullCase, null, null, nullOppy));
    system.assertEquals('-', cont.getClientRating(null, null, nullCase, null, null, nullOppy));
    system.assertEquals('-', cont.getClientId(null, null, nullCase, null, null, nullOppy));
    list<RecordType> record = [select id, DeveloperName from RecordType WHERE SobjectType='Case' order by Name ASC];
        
       //Cria um novo pagamento
    Pagamento__c payment = new Pagamento__c();
    payment.OwnerId               = usuario.Id;
    payment.Recebedor__c          = 'Cliente Abertura da RV';
    payment.Forma_de_Pagamento__c ='Deposito em Conta';
    sResult = Database.insert( payment, false );
    system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
    system.assert( sResult.isSuccess() );


    Case caso = new Case(
        status= 'Without customer proposal-Sent to Credit',
        Reason = 'Alt. cliente pai',
        Description = 'TEST',
        OwnerId = usuario.id,
        Type = 'Account Alteration ARG',
        AccountId= acc.id
    );
    Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

    LAT_Contract__c Lc = new LAT_Contract__c();
    Lc.Account__c = Acc.Id;
    Lc.Status__c = 'Em elaboração';
    Lc.StartDate__c = System.today();
    Lc.ContractTerm__c = 12;
    Lc.RecordTypeId = idrecTypeLatCon;
    Lc.ROI_Comentarios_Negativo__c = 'teste';

    Analise_de_credito__c ac = new Analise_de_credito__c();
    ac.Conta__c = acc.id;
    ac.LAT_BR_Status__c = 'Ativo';
    
    Opportunity oportunidade = new Opportunity();
    oportunidade.Name = 'Cloud2b - Oportunidade - AtualizarEventoProdutosOportunidade';
    oportunidade.AccountId = acc.Id;
    oportunidade.stagename = 'Novo pedido';
    oportunidade.closedate = Date.today();
    insert oportunidade;
    //Cria um novo IBP
    Investimento_Bonificacao_e_Pagamento__c IBP =
      new Investimento_Bonificacao_e_Pagamento__c(
        Status_da_Verba__c='Reservado',
        RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
        Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
        Sistema__c='ME',
        OwnerId=usuario.Id
      );
    sResult = Database.insert( IBP, false );
    system.assert( sResult.isSuccess() );
    
    //Cria um novo pagamento de verba
    Pagamento_da_Verba__c pagVerba = 
      new Pagamento_da_Verba__c( 
        Pagamento__c=payment.Id, 
        Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
      );
    sResult = Database.insert( pagVerba, false );
    system.assert( sResult.isSuccess() );
    
    payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
      FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
       // Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
       // req2.setNextApproverIds( new List< Id >{ acc.OwnerId});
       // req2.setObjectId( oportunidade.Id );
     
          // submit the approval request for processing
       //   Approval.ProcessResult result = Approval.process( req2 );

    LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
          LAT_BR_Client__c = acc.id,
          RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade'),
          LAT_BR_ApprovalStatus__c = 'Draft',
          LAT_BR_IconicHouse__c = 'Yes',
          LAT_BR_PubPhysicalSpace__c = 'Tables and most people seated',
          LAT_BR_Music__c = 'Mild or none',
          LAT_BR_ConsumerProfile__c = 'A',
          LAT_BR_MainDrinks__c = 'High quality cocktails',
          LAT_BR_AverageMainMealPrice__c = 'Between 76 and 125',
          LAT_BR_AdultEntertainmentHouse__c = 'Yes',
          LAT_BR_MainBillFocus__c = 'Drinks with meals and snacks to complement',
          LAT_BR_MainConsumptionOccasion__c = 'Lunch/dinner',
          LAT_BR_ActivitiesStartTime__c = 'For lunches/dinners',
          LAT_BR_MainBrandsSold__c = 'Standard',
          LAT_BR_Brigade__c = 'Excellent',
          LAT_BR_AverageSodaCansPrice__c = 'Above 4',
          LAT_BR_PeopleCapacity__c = 'Above 1000',
          LAT_BR_Justificativa__c = 'Justificativa'
      );
    //insert seg;

    LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper aw = 
            new LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper('Test', acc.name, 'clientRating', 'Account',
                                             'TargetObject.Type', 'lastApprover', usuario.Id, 'CreatedBy.Regional_de_vendas__c',
                               Date.today(), 'justificationSeg', acc.Id, acc.Id);

    cont.getClientName(acc, seg, caso, Lc, ac, oportunidade);               
    Test.stopTest();
  }

  @isTest static void test_method_oneB() {
    
      Utils.setMigrationDoneTest(true);

    Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    acc.Status__c = 'Novo cadastro';
    insert acc;
    User gerente = new User();
    gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    Database.Saveresult sResult = Database.insert( gerente, false );
    system.assert( sResult.isSuccess() );
    
    //Cria novo usuario.
    User usuario = new User();
    usuario.FirstName           = 'nome';
    usuario.LastName            = 'Sobrenome';
    usuario.Alias               = 'NSobres';
    usuario.Email               = 'nome@sobrenome.com';
    usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
    usuario.CommunityNickname   = '1234jjuuu';
    usuario.EmailEncodingKey    = 'ISO-8859-1';
    usuario.TimeZoneSidKey      = 'GMT';
    usuario.LocaleSidKey        = 'en_Us';
    usuario.LanguageLocaleKey   = 'en_Us';
    usuario.C_digo_JDE__c       = '235';
    usuario.ProfileId           = gerente.ProfileId;
    usuario.Gerente_de_area__c  = gerente.Id;
    usuario.Gerente_regional__c = gerente.Id;
    usuario.ManagerId           = gerente.Id;
    usuario.Country = 'BR';

    insert usuario;
    System.runAs(usuario) {  
  Test.startTest();
    Utils.setMigrationDoneTest(true);
    Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        system.assert( sResult.isSuccess() );
        
        //Cria um novo IBP
        Investimento_Bonificacao_e_Pagamento__c IBP =
          new Investimento_Bonificacao_e_Pagamento__c(
            Status_da_Verba__c='Reservado',
            RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
            Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
            Sistema__c='ME',
            OwnerId=usuario.Id
          );
        sResult = Database.insert( IBP, false );
        system.assert( sResult.isSuccess() );
        
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
          );
        sResult = Database.insert( pagVerba, false );
        system.assert( sResult.isSuccess() );
        
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
        Test.stopTest();
    }

    LAT_Case__c caso = new LAT_Case__c(
            LAT_status__c = 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            LAT_Type__c = 'Account Alteration ARG',
            LAT_Account__c = acc.id
        );
    Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

        LAT_Contract__c Lc = new LAT_Contract__c();
        Lc.Account__c = Acc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.StartDate__c = System.today();
        Lc.ContractTerm__c = 12;
        Lc.RecordTypeId = idrecTypeLatCon;
        Lc.ROI_Comentarios_Negativo__c = 'teste';
    
        Analise_de_credito__c ac = new Analise_de_credito__c();
      ac.Conta__c = acc.id;
        ac.LAT_BR_Status__c = 'Ativo';

         LAT_Opportunity__c LAT_oportunidade = new LAT_Opportunity__c();
         LAT_oportunidade.Name = 'Cloud2b - LAT Oportunidade - AtualizarEventoProdutosOportunidade';
         LAT_oportunidade.LAT_Account__c = acc.Id;
         LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(
            LAT_VisualForceName__c = 'LAT_BR_VFP22_PendingApprovalReport'
        );
        insert crp;

        ApexPages.currentPage().getParameters().put('IdRep', crp.Id);
        LAT_BR_VFC16_PendingApprovalReportCont cont = new LAT_BR_VFC16_PendingApprovalReportCont();
     cont.LAT_filters = new LAT_BR_VFC16_PendingApprovalReportCont.LAT_reportFilters();
     cont.applyFilters();

    cont.LAT_filters.createdByRegional.Regional_de_vendas__c = 'Test';
    cont.LAT_filters.client.ParentId = acc.Id;
    cont.LAT_filters.relatedTo = 'Test';
    cont.applyFilters();

    cont.LAT_filters.currentApprover.OwnerId = UserInfo.getUserId();
    cont.LAT_filters.DateStart.LAT_CloseDate__c = Date.today();
    cont.LAT_filters.DateEnd.LAT_CloseDate__c = Date.today();
    cont.applyFilters();
    LAT_Case__c nullCase = new LAT_Case__c();
    LAT_Opportunity__c nullOppy = new LAT_Opportunity__c();
    system.assertEquals('-', cont.getClientName(null, null, nullCase, null, null, nullOppy));
    system.assertEquals('-', cont.getClientRating(null, null, nullCase, null, null, nullOppy));
    system.assertEquals('-', cont.getClientId(null, null, nullCase, null, null, nullOppy));

    LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
          LAT_BR_Client__c = acc.id,
          RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade'),
          LAT_BR_ApprovalStatus__c = 'Draft',
          LAT_BR_IconicHouse__c = 'Yes',
          LAT_BR_PubPhysicalSpace__c = 'Tables and most people seated',
          LAT_BR_Music__c = 'Mild or none',
          LAT_BR_ConsumerProfile__c = 'A',
          LAT_BR_MainDrinks__c = 'High quality cocktails',
          LAT_BR_AverageMainMealPrice__c = 'Between 76 and 125',
          LAT_BR_AdultEntertainmentHouse__c = 'Yes',
          LAT_BR_MainBillFocus__c = 'Drinks with meals and snacks to complement',
          LAT_BR_MainConsumptionOccasion__c = 'Lunch/dinner',
          LAT_BR_ActivitiesStartTime__c = 'For lunches/dinners',
          LAT_BR_MainBrandsSold__c = 'Standard',
          LAT_BR_Brigade__c = 'Excellent',
          LAT_BR_AverageSodaCansPrice__c = 'Above 4',
          LAT_BR_PeopleCapacity__c = 'Above 1000',
          LAT_BR_Justificativa__c = 'Justificativa'
      );
    // insert seg;

    LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper aw = 
            new LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper('Test', 'clientName', 'clientRating', 'TargetObject',
                                             'TargetObject.Type', 'lastApprover', 'CreatedBy.Name', 'CreatedBy.Regional_de_vendas__c',
                               Date.today(), 'justificationSeg', 'TargetObjectId', 'clientId');

    cont.getClientName(acc, seg, caso, Lc, ac,LAT_oportunidade );
  }
  @isTest static void test_method_two() {
      //Cria novo usuario.

      Utils.setMigrationDoneTest(false);
    Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    acc.Status__c = 'Novo cadastro';
    insert acc;
    User gerente = new User();
    gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    Database.Saveresult sResult = Database.insert( gerente, false );
    system.assert( sResult.isSuccess() );
    
    //Cria novo usuario.
    User usuario = new User();
    usuario.FirstName           = 'nome';
    usuario.LastName            = 'Sobrenome';
    usuario.Alias               = 'NSobres';
    usuario.Email               = 'nome@sobrenome.com';
    usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
    usuario.CommunityNickname   = '1234jjuuu';
    usuario.EmailEncodingKey    = 'ISO-8859-1';
    usuario.TimeZoneSidKey      = 'GMT';
    usuario.LocaleSidKey        = 'en_Us';
    usuario.LanguageLocaleKey   = 'en_Us';
    usuario.C_digo_JDE__c       = '235';
    usuario.ProfileId           = gerente.ProfileId;
    usuario.Gerente_de_area__c  = gerente.Id;
    usuario.Gerente_regional__c = gerente.Id;
    usuario.ManagerId           = gerente.Id;
    usuario.Country = 'BR';

    insert usuario;
    System.runAs(usuario) {  
//Cria um novo pagamento
        Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        system.assert( sResult.isSuccess() );
        
        //Cria um novo IBP
        Investimento_Bonificacao_e_Pagamento__c IBP =
          new Investimento_Bonificacao_e_Pagamento__c(
            Status_da_Verba__c='Reservado',
            RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
            Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
            Sistema__c='ME',
            OwnerId=usuario.Id
          );
        sResult = Database.insert( IBP, false );
        system.assert( sResult.isSuccess() );
        
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
          );
        sResult = Database.insert( pagVerba, false );
        system.assert( sResult.isSuccess() );
        
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
  }
      
    Test.startTest();
    LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(
            LAT_VisualForceName__c = 'LAT_BR_VFP22_PendingApprovalReport'
        );
        insert crp;

        ApexPages.currentPage().getParameters().put('IdRep', crp.Id);
        LAT_BR_VFC16_PendingApprovalReportCont cont = new LAT_BR_VFC16_PendingApprovalReportCont();
        LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper aw2 = 
            new LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper('Test', acc.name, 'clientRating', 'Account',
                                             'TargetObject.Type', 'lastApprover', usuario.Id, 'CreatedBy.Regional_de_vendas__c',
                               Date.today(), 'justificationSeg', acc.Id, acc.Id);
        cont.wrapperList.add(aw2);    
    cont.filters = new LAT_BR_VFC16_PendingApprovalReportCont.reportFilters();
    cont.applyFilters();

    //cont.filters.createdByRegional.Regional_de_vendas__c = 'Test';
    //cont.filters.client.ParentId = acc.Id;
    //cont.filters.relatedTo = 'Test';
    cont.applyFilters();

    cont.filters.currentApprover.OwnerId = UserInfo.getUserId();
    cont.filters.DateStart.CloseDate = Date.today();
    cont.filters.DateEnd.CloseDate = Date.today();
    cont.applyFilters();
    Case nullCase = new Case();
    Opportunity nullOppy = new Opportunity();
    system.assertEquals('-', cont.getClientName(null, null, nullCase, null, null, nullOppy));
    system.assertEquals('-', cont.getClientRating(null, null, nullCase, null, null, nullOppy));
    system.assertEquals('-', cont.getClientId(null, null, nullCase, null, null, nullOppy));
    list<RecordType> record = [select id, DeveloperName from RecordType WHERE SobjectType='Case' order by Name ASC];
        
       //Cria um novo pagamento
    Pagamento__c payment = new Pagamento__c();
    payment.OwnerId               = usuario.Id;
    payment.Recebedor__c          = 'Cliente Abertura da RV';
    payment.Forma_de_Pagamento__c ='Deposito em Conta';
    sResult = Database.insert( payment, false );
    system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
    system.assert( sResult.isSuccess() );


    Case caso = new Case(
        status= 'Without customer proposal-Sent to Credit',
        Reason = 'Alt. cliente pai',
        Description = 'TEST',
        OwnerId = usuario.id,
        Type = 'Account Alteration ARG',
        AccountId= acc.id
    );
    Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

    LAT_Contract__c Lc = new LAT_Contract__c();
    Lc.Account__c = Acc.Id;
    Lc.Status__c = 'Em elaboração';
    Lc.StartDate__c = System.today();
    Lc.ContractTerm__c = 12;
    Lc.RecordTypeId = idrecTypeLatCon;
    Lc.ROI_Comentarios_Negativo__c = 'teste';

    Analise_de_credito__c ac = new Analise_de_credito__c();
    ac.Conta__c = acc.id;
    ac.LAT_BR_Status__c = 'Ativo';
    
    Opportunity oportunidade = new Opportunity();
    oportunidade.Name = 'Cloud2b - Oportunidade - AtualizarEventoProdutosOportunidade';
    oportunidade.AccountId = acc.Id;
    oportunidade.stagename = 'Novo pedido';
    oportunidade.closedate = Date.today();
    insert oportunidade;
    //Cria um novo IBP
    Investimento_Bonificacao_e_Pagamento__c IBP =
      new Investimento_Bonificacao_e_Pagamento__c(
        Status_da_Verba__c='Reservado',
        RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
        Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
        Sistema__c='ME',
        OwnerId=usuario.Id
      );
    sResult = Database.insert( IBP, false );
    system.assert( sResult.isSuccess() );
    
    //Cria um novo pagamento de verba
    Pagamento_da_Verba__c pagVerba = 
      new Pagamento_da_Verba__c( 
        Pagamento__c=payment.Id, 
        Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
      );
    sResult = Database.insert( pagVerba, false );
    system.assert( sResult.isSuccess() );
    
    payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
      FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
       // Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
       // req2.setNextApproverIds( new List< Id >{ acc.OwnerId});
       // req2.setObjectId( oportunidade.Id );
     
          // submit the approval request for processing
       //   Approval.ProcessResult result = Approval.process( req2 );

    LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
          LAT_BR_Client__c = acc.id,
          RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade'),
          LAT_BR_ApprovalStatus__c = 'Draft',
          LAT_BR_IconicHouse__c = 'Yes',
          LAT_BR_PubPhysicalSpace__c = 'Tables and most people seated',
          LAT_BR_Music__c = 'Mild or none',
          LAT_BR_ConsumerProfile__c = 'A',
          LAT_BR_MainDrinks__c = 'High quality cocktails',
          LAT_BR_AverageMainMealPrice__c = 'Between 76 and 125',
          LAT_BR_AdultEntertainmentHouse__c = 'Yes',
          LAT_BR_MainBillFocus__c = 'Drinks with meals and snacks to complement',
          LAT_BR_MainConsumptionOccasion__c = 'Lunch/dinner',
          LAT_BR_ActivitiesStartTime__c = 'For lunches/dinners',
          LAT_BR_MainBrandsSold__c = 'Standard',
          LAT_BR_Brigade__c = 'Excellent',
          LAT_BR_AverageSodaCansPrice__c = 'Above 4',
          LAT_BR_PeopleCapacity__c = 'Above 1000',
          LAT_BR_Justificativa__c = 'Justificativa'
      );
    //insert seg;

    LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper aw = 
            new LAT_BR_VFC16_PendingApprovalReportCont.approvalWrapper('Test', acc.name, 'clientRating', 'Account',
                                             'TargetObject.Type', 'lastApprover', usuario.Id, 'CreatedBy.Regional_de_vendas__c',
                               Date.today(), 'justificationSeg', acc.Id, acc.Id);

    cont.getClientName(acc, seg, caso, Lc, ac, oportunidade);               
    Test.stopTest();
  }
}