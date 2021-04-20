@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do controlador EditarTodosScheduleCOrgExp.cls
* NAME: EditarTodosScheduleCOrgExpTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 05/06/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 14/01/2013 
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
private class EditarTodosScheduleCOrgExpTest 
{

    static testMethod void EditarTodosScheduleCOrgExpTest() 
      {
            Utils.setMigrationDoneTest(false); 
            //Declaração de variáveis.
            Account acc                           = null;
            UDC__c regional, bandeira             = null;
            Profile perfil                        = null;
            User usuario                          = null;
            Visitas__c visita                     = null;
            Planejamento__c plan                  = null;
            String idAccount                      = null;      
            
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
            Id idRecTypePlan = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
            Id idRecTypePC = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard');
            Id idRecTypeCe = Global_RecordTypeCache.getRtId('Checklist_Exposicao__c' + 'BRA_Standard');

            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'On_Trade');
            
            //Recupera o ID do perfil desejado.
            usuario = new User();
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '01-01';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //delete [SELECT id FROM UDC__c WHERE Internal_Id__c = '01-06' AND RecordTypeId =: idRecTypeUDC];
            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '01-06';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;
          
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Channel_Type__c = 'Direto';
            acc.Client_code_AN8__c = '557799';
            acc.Price_Group__c = '1';
            acc.Customer_Flag__c = bandeira.Id;
            insert acc;
            
            //Cria novo planejamento.
            plan = new Planejamento__c();
            plan.Ano_de_Referencia__c = '2012';
            plan.M_s_de_Ref_rencia__c = 'Fevereiro';
            plan.Name = 'Teste';
            plan.OwnerId = usuario.Id;
            plan.RecordTypeId = idRecTypePlan;
            insert plan;
            
            //Cria nova visita
            visita = new Visitas__c();
            visita.Name = 'Teste';
            visita.Data_da_Visita__c = System.today();
            visita.Hora_da_Visita__c = '08:00';
            visita.Planejamento__c = plan.Id;
            visita.Tipo_de_Visita__c = 'Execução';
            visita.Conta__c = acc.Id;
            visita.Status__c = 'Planejada';
            visita.RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
            visita.Resumo_da_Visita__c = 'teste';
            test.startTest();
            Utils.setMigrationDoneTest(false); 
            insert visita;
            
            
            
            Id idRecTypeCheck = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade');
            
            //Cria novo checklist de visita
            Checklist_de_visita__c check = new Checklist_de_visita__c();
            check.Visita__c = visita.Id;
            check.RecordTypeId = idRecTypeCheck;
            insert check;
            
            //Cria novo produto da concorrencia
            Product2 prod = new Product2();
            prod.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            prod.IsActive = true;
            prod.CD_Unit__c = 'UN';
            prod.Internal_id__c = '123';
            //prod.QT_lead_time__c = 5;
            prod.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
            insert prod;
            
            //Cria novo produto da concorrencia
            Produto_Concorr_ncia__c prodC = new Produto_Concorr_ncia__c();
            prodC.Checklist_de_visita__c = check.Id;
            prodC.RecordTypeId = idRecTypePC;
            prodC.Produto_PERNOD__c = prod.id;
            insert prodC;
            
            Checklist_Exposicao__c checkE = new Checklist_Exposicao__c();
            checkE.Checklist_de_visita__c = check.Id;
            checkE.Schedule_C__c = 'Teste';
            checkE.RecordTypeId = idRecTypeCe;
            insert checkE;
            
            //Armazena a visita criada em uma lista.
            List<Checklist_Exposicao__c> listCheckE = new List<Checklist_Exposicao__c>();
            listCheckE.add( checkE );
            
            //Executa a pagina visual force
            PageReference pageRef = Page.Editar_todos_schedule_c_org_e_exp;
            Test.setCurrentPageReference(pageRef);
            
            //Excuta o standard controller
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listCheckE);
            
            //Seleciona os itens (Serve para as caixas de seleção de visita)
            sc.setSelected(listCheckE);
            
            //Executa o controller customizado e seus métodos
            EditarTodosScheduleCOrgExp con = new EditarTodosScheduleCOrgExp(sc);
            con.save();
            test.stopTest();
            
      }
      //MIGRATED 21/11/2016
    static testMethod void EditarTodosScheduleCOrgExpTestB() 
      {
            Utils.setMigrationDoneTest(true); 
            //Declaração de variáveis.
            Account acc                           = null;
            UDC__c regional, bandeira             = null;
            Profile perfil                        = null;
            User usuario                          = null;
            Visitas__c visita                     = null;
            Planejamento__c plan                  = null;
            String idAccount                      = null;      
            
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
            Id idRecTypePlan = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
            Id idRecTypePC = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard');
            Id idRecTypeCe = Global_RecordTypeCache.getRtId('Checklist_Exposicao__c' + 'BRA_Standard');

            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'On_Trade');
            
            //Recupera o ID do perfil desejado.
            usuario = new User();
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '01-01';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //delete [SELECT id FROM UDC__c WHERE Internal_Id__c = '01-06' AND RecordTypeId =: idRecTypeUDC];
            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '01-06';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;
          
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Channel_Type__c = 'Direto';
            acc.Client_code_AN8__c = '557799';
            acc.Price_Group__c = '1';
            acc.Customer_Flag__c = bandeira.Id;
            insert acc;
            
            //Cria novo planejamento.
            plan = new Planejamento__c();
            plan.Ano_de_Referencia__c = '2012';
            plan.M_s_de_Ref_rencia__c = 'Fevereiro';
            plan.Name = 'Teste';
            plan.OwnerId = usuario.Id;
            plan.RecordTypeId = idRecTypePlan;
            insert plan;
            
            //Cria nova visita
            visita = new Visitas__c();
            visita.Name = 'Teste';
            visita.Data_da_Visita__c = System.today();
            visita.Hora_da_Visita__c = '08:00';
            visita.Planejamento__c = plan.Id;
            visita.Tipo_de_Visita__c = 'Execução';
            visita.Conta__c = acc.Id;
            visita.Status__c = 'Planejada';
            visita.RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
            visita.Resumo_da_Visita__c = 'teste';
            test.startTest();
            Utils.setMigrationDoneTest(true); 
            insert visita;
            
            
            
            Id idRecTypeCheck = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade');
            
            //Cria novo checklist de visita
            Checklist_de_visita__c check = new Checklist_de_visita__c();
            check.Visita__c = visita.Id;
            check.RecordTypeId = idRecTypeCheck;
            insert check;
            
            //Cria novo produto da concorrencia
            LAT_Product__c prod = new LAT_Product__c();
            prod.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            prod.LAT_IsActive__c = true;
            prod.LAT_CDUnit__c = 'UN';
            prod.LAT_ExternalId__c = '123';
            //prod.QT_lead_time__c = 5;
            prod.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
            insert prod;
            
            //Cria novo produto da concorrencia
            Produto_Concorr_ncia__c prodC = new Produto_Concorr_ncia__c();
            prodC.Checklist_de_visita__c = check.Id;
            prodC.RecordTypeId = idRecTypePC;
            prodC.LAT_Product__c = prod.id;
            insert prodC;
            
            Checklist_Exposicao__c checkE = new Checklist_Exposicao__c();
            checkE.Checklist_de_visita__c = check.Id;
            checkE.Schedule_C__c = 'Teste';
            checkE.RecordTypeId = idRecTypeCe;
            insert checkE;
            
            //Armazena a visita criada em uma lista.
            List<Checklist_Exposicao__c> listCheckE = new List<Checklist_Exposicao__c>();
            listCheckE.add( checkE );
            
            //Executa a pagina visual force
            PageReference pageRef = Page.Editar_todos_schedule_c_org_e_exp;
            Test.setCurrentPageReference(pageRef);
            
            //Excuta o standard controller
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listCheckE);
            
            //Seleciona os itens (Serve para as caixas de seleção de visita)
            sc.setSelected(listCheckE);
            
            //Executa o controller customizado e seus métodos
            EditarTodosScheduleCOrgExp con = new EditarTodosScheduleCOrgExp(sc);
            con.save();
            test.stopTest();
            
      }
}