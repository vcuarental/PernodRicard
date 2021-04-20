@isTest
/********************************************************************************
*
* Classe de test poyr activation Trigger
* NAME: BRA_APEX_TRIGGER_TEST.cls
* AUTHOR: jean-Francois BERNARD
*
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
private class BRA_APEX_TRIGGER_TEST {

    static testMethod void myUnitTest() {
        Utils.setMigrationDoneTest(false); 
      
        //Declaração de variáveis.          

        UDC__C regional = null;     
        UDC__C bandeira = null; 
        Agrupamento_Fiscal_Year__c Ag = null;
        Case Cas = null;
        Attachment Att = null;
        Checklist_de_visita__c Cv = null;
        Cl_usulas_do_Contrato__c Cc = null;
        Cl_usulas_do_Contrato__c Cc2 = null;
        LAT_Contract__c Lc = null;
        LAT_Contract__c Lc2 = null;
        Cota_nacional__c Cn = null;
        Cota_regional__c Cr = null;
        Criterio_nacional_de_cota__c Ccn = null;
        Criterio_de_cota_regional__c Ccr = null;
        Distribui_o_de_Valores__c Dv = null;
        Investimento_Bonificacao_e_Pagamento__c Inv = null;
        Opportunity Opp = null;
        OpportunityLineItem Oppl = null;
        Pagamento__c Pag = null;
        Pagamento_da_Verba__c Pagv = null;
        Planejamento__c Plan = null;
        Produto_Concorrente__c Pcc = null;
        Produto_Concorr_ncia__c Prc = null;
        Rateio_do_Contrato__c Rat = null;
        Task Tsk = null;
        Tipo_de_Documento__c Td = null;
        Tipo_de_Documento__c Td2 = null;
        Account Acc = null;
        Visitas__c Vis = null;
        SKU__c Sku = null;
        User usuario = null;
              Product2 lProd = new Product2();
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = 'qeweqewq';
        insert lProd;

        Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );     
        Id idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade'); 
        ID idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
        ID idAccount2 = RecordTypeForTest.getRecType('Account','On_Trade');  
        Id idRecTypeAtt = RecordTypeForTest.getRecType('Pagamento__c', 'Bonificacao_Produtos');    
                 
        Id catalogoPreco = null;
        Profile perfil = null;

         /* Get User profile for bypassing execution by System Administrator GDT - Jef 01/10/2013 */
             if((UserInfo.getProfileId()!='00eD0000001ApvPIAS') && (UserInfo.getProfileId()!= '00eL0000000DkgiIAC'))
             {   

              
         // usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2B','Sobrenome2B','NSobre2B','nome2B@sobrenome.com','test@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
          //  insert usuario;  
          //Recupera o ID do perfil desejado.


        /*//Cria nova UDC.      
        regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';  
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;*/

        perfil = [Select Id From Profile Where Name=:'Business administrator'];
        System.debug('%%%%%%%%%% perfil : '+ perfil);
              
            usuario = new User();
          usuario.FirstName       = 'Nome';
          usuario.LastName      = 'Sobrenome';
          usuario.Alias       = 'NSobre';
          usuario.Email         = 'nome@sobrenome.com';
          usuario.Username      = 'nome@sobrenomeJef.com';
          usuario.CommunityNickname   = '123jjjuuu';
          usuario.EmailEncodingKey  = 'ISO-8859-1';
          usuario.TimeZoneSidKey    = 'GMT';
          usuario.LocaleSidKey    = 'en_Us';
          usuario.LanguageLocaleKey = 'en_Us';
          usuario.C_digo_JDE__c   = '234';
          usuario.ProfileId       = perfil.Id;
          usuario.Country = 'BR';
          insert usuario;
              
  


                       
        /*//Cria nova Agrapumenta fiscal Year.      
        Ag = new Agrupamento_Fiscal_Year__c(); 
        insert Ag;
        Ag.Ano_Fiscal__c = '2013';
        update Ag;*/
            
        //Cria nova Planajemnto...      
        Plan = new  Planejamento__c(); 
        Plan.Name = 'XXXX'; 
        Plan.M_s_de_Ref_rencia__c = 'Janeiro';
        Plan.Ano_de_Referencia__c = '2016';
        insert Plan;
        //Plan.Name = 'YYYY';
        //update Plan;

        //Cria novo Account.      
        Acc = new Account();      
        //Acc.OwnerId = usuario.Id;      
        Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.RecordTypeId = idAccount;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'Off Trade';  
        Acc.Rating = 'Cliente';    
        //Acc.Regional__c = regional.Id;      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        //Acc.Customer_Flag__c = bandeira.Id;      
        insert Acc;
        Acc.Checking_account__c = '000';    
        update Acc;

        //Cria nova Visitas.      
        Vis = new Visitas__c(); 
        Vis.Conta__c = Acc.Id;
        Vis.Data_da_Visita__c = System.today();
        Vis.planejamento__c = Plan.Id;
        Vis.Hora_da_Visita__c = '8:00';
        Vis.Resumo_da_Visita__c = 'xxxx';
        insert Vis;

        Test.startTest();
        Utils.setMigrationDoneTest(false); 

        //Cria nova Checklist de Visita.      
        Cv = new  Checklist_de_visita__c(); 
        Cv.visita__c = Vis.Id;
        insert Cv;

        //Cria criterio SKU.      
        Sku = new  SKU__c(); 
        Sku.Nome_do_produto__c = 'prod2';
        insert Sku;

        /*//Cria nova producto concorrecte
        Pcc = new Produto_Concorrente__c();
        insert Pcc;

        //Cria nova producto concurrencia...      
        Prc = new  Produto_Concorr_ncia__c(); 
        Prc.Checklist_de_visita__c = Cv.Id;
        Prc.Produto_Concorrente__c = Pcc.id;
        insert Prc;
        Prc.Canal__c = 'Off Trade';
        update Prc; */

        //Cria nova pagamento ...      
        Pag = new  Pagamento__c();
        Pag.Cliente__c = Acc.Id; 
        insert Pag;
        Pag.Observacoes_Complementares__c = 'XXX';
        update Pag;
        Pag = new  Pagamento__c();
        Pag.Cliente__c = Acc.Id; 
        Pag.Observacoes_Complementares__c = 'YYY';
        Pag.RecordTypeId = RecordTypeForTest.getRecType('Pagamento__c', 'Dinheiro' );
        insert Pag;


        /*/Recupera o catalogo de preço padrão      
        //catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];        
        //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.      
        PricebookEntry entradaCatalogoPreco = new PricebookEntry();      
        entradaCatalogoPreco.Pricebook2Id = '01sD0000000h8wyIAA';        
        entradaCatalogoPreco.Product2Id = lprod.Id;      
        entradaCatalogoPreco.UnitPrice = 1000.00;      
        entradaCatalogoPreco.IsActive = true;      
        entradaCatalogoPreco.UseStandardPrice = false;      
        insert entradaCatalogoPreco;           

        //Cria nova oportunidade.      
        Opp = new Opportunity();      
        Opp.Name = 'Opp TESTE COTA';      
        Opp.closeDate = System.today()+1;      
        Opp.AccountId = acc.Id;      
        Opp.StageName = 'Novo pedido';      
        Opp.RecordTypeId = idOpportunity;      
        insert Opp;            

        //Cria um novo produto da oportunidade.      
        Oppl = new OpportunityLineItem();      
        Oppl.PricebookEntryId = entradaCatalogoPreco.Id;      
        Oppl.OpportunityId    = Opp.Id;      
        Oppl.UnitPrice        = 12;      
        Oppl.Quantity         = 15;      
        insert Oppl;

        //Cria criterio national de Cota.      
        Ccn = new  Criterio_nacional_de_cota__c(); 
        Ccn.Cota__c = 1;
        Ccn.SKU__c = Sku.id;
        Ccn.Cota__c = 1000;  
        //Ccn.Regional__c = true;
        //Ccn.Canal__c = true;
        Ccn.bandeira__c = true;
        Ccn.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c', 'BRA_Standard' );      
        insert Ccn;*/

        //Cria novo contrato.        
        Lc = new LAT_Contract__c();        
        Lc.OwnerId = usuario.Id;        
        //Lc.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato');
        Lc.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo');
        Lc.Account__c = Acc.Id;        
        Lc.Status__c = 'Reservado';        
        //Lc.Status__c = 'Ativo';        
        Lc.ROI_Comentarios_Negativo__c = 'Teste';        
        Lc.StartDate__c = System.today();        
        Lc.Gerente_Regional__c = Usuario.Id;
        Lc.Gerente__c = Usuario.Id;
        Lc.Gerente_de_area__c = Usuario.Id;  
        insert Lc;

        //Cria nova Clausula de contrato.     
        Cc = new  Cl_usulas_do_Contrato__c();
        Cc.Contrato__c = Lc.Id;
        insert Cc;

        //Cria nova type de doc.      
        Td = new Tipo_de_Documento__c(); 
        td.LAT_Contract__c = lc.id;
        insert Td;

        Lc.Cl_usulas_do_Contrato__c = Cc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.ContractTerm__c = 12; 
        update Lc; 


        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.LAT_Contract__c = Lc.id;
        ibp.Status_da_Verba__c='Reservado';
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        //ibp.Valor_R__c = 100;
        ibp.Perc_de_Rateio__c = 30;
        ibp.Valor_Percebido__c = 120.32;
        ibp.Custo_Bonificado__c = 89;
        ibp.Produto_Bonificado__c = lProd.id;
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.CasoEspecial__c = true;
        insert ibp;

        //Cria nova pagamento da verba ...      
        Pagv = new  Pagamento_da_Verba__c(); 
        Pagv.Pagamento__c = Pag.id;
        Pagv.conta__c = Acc.Id;
        Pagv.Investimento_Bonifica_o_e_Pagamento__c = ibp.Id;
        Pagv.pagar_com_produto__c = lProd.Id;
        Pagv.Sistema__c = 'ME';
        //Pagv.RecordTypeId = RecordTypeForTest.getRecType('Pagamento_da_verba__c', 'Dinheiro' );
        insert Pagv; 
        Pagv.Status__c = 'Aprovado Integrado';
        update Pagv;

        ibp.Valor_R__c = 100;
        update ibp;

        //Cria Distrinui o de valores.      
        Dv = new  Distribui_o_de_Valores__c(); 
        Dv.Clausulas_do_Contrato__c = Cc.Id;
        insert Dv;

        //Cria nova retaio de contrato...      
        Rat = new  Rateio_do_Contrato__c(); 
        Rat.LAT_Contract__c = Lc.Id;
        Rat.Perc_de_rateio__c = 20;
        insert Rat;

        
        Id idtRecTypeCase = RecordTypeForTest.getRecType('Case', 'Gerar_D_A_no_sistema_ME'); 

            Cas = new Case(
            RecordTypeId = idtRecTypeCase,
            status= 'Fechado e resolvido',
            Reason = 'Alt. cliente pai',
            Description = 'TEST',
            Type = 'Account Alteration ARG',
            Integration_Status__c = 'Reservado',
            DA_Number__c = 123,
            AccountId= acc.id
        );

        /*Cria nova Case.      
        Cas = new Case(); 
        Cas.Integration_Status__c = 'Reservado';
        Cas.WF_Type__c = 'Jef';
        Cas.DA_Number__c = 123;
        //Cas.RecordtypeId = idRecTypeCase;*/
        insert Cas;

        //Cria nova Attachment.      
        Att = new Attachment(); 
        Att.ParentId = Lc.Id;
        Att.Name = 'Doc Jef';
        Att.Body = Blob.valueof( 'asdasd' );
        //Att.RecordTypeId = idRecTypeAtt;
        insert Att;

        //Cria secundo novo contrato.        
        Lc2 = new LAT_Contract__c();        
        Lc2.OwnerId = usuario.Id;        
        //Lc2.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato');
        Lc2.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo');
        Lc2.Account__c = Acc.Id;        
        Lc2.Status__c = 'Reservado';        
        //Lc2.Status__c = 'Ativo';        
        Lc2.ROI_Comentarios_Negativo__c = 'Teste';        
        Lc2.StartDate__c = System.today();        
        Lc2.Gerente_Regional__c = Usuario.Id;
        Lc2.Gerente__c = Usuario.Id;
        Lc2.Gerente_de_area__c = Usuario.Id;  
        insert Lc2;

        //Cria nova Clausula de contrato.     
        Cc2 = new  Cl_usulas_do_Contrato__c();
        Cc2.Descricao__c = 'Jef XXX2';
        Cc2.Contrato__c = Lc2.Id;
        insert Cc2;

        //Cria nova type de doc.      
        Td2 = new Tipo_de_Documento__c(); 
        td2.LAT_Contract__c = lc2.id;
        insert Td2;

        // Delete Pagamento
        Pagamento__c[] Pag2 = [Select Id from Pagamento__c where Observacoes_Complementares__c = 'YYY' ];
        delete Pag2;

        // Delete Cl_usualas_dp_contrato    
        Cl_usulas_do_Contrato__c[] Cc3 = [Select Id from  Cl_usulas_do_Contrato__c where Contrato__c = :Lc2.Id limit 1];
        delete Cc3;

        // Delete Tipo de documento    
        Tipo_de_Documento__c[] Td3 = [Select Id from Tipo_de_Documento__c where LAT_Contract__c = :lc2.Id limit 1]; 
        delete Td3;

        //               ABOVE IS : OK  OK  OK  OK   

        //Cria nova Cota national.      
        //Cn = new  Cota_nacional__c(); 
        //Cn.Cota__c = 1;
        //Cn.Criterio_nacional_de_cota__c = Ccn.Id;
        //insert Cn;

        //Cria criterio de Cota regional.      
        //Ccr = new  Criterio_de_cota_regional__c(); 
        //Ccr.Cota__c = 1;
        //insert Ccr;

        //Cria nova Cota regional.      
        //Cr = new  Cota_regional__c(); 
        //Cr.Cota__c = 1;
        //insert Cr;


            Test.stopTest();
            }
    }

    static testMethod void myUnitTestBB() {
        Utils.setMigrationDoneTest(true); 
      
        //Declaração de variáveis.          

        UDC__C regional = null;     
        UDC__C bandeira = null; 
        Agrupamento_Fiscal_Year__c Ag = null;
        LAT_Case__c Cas = null;
        Attachment Att = null;
        Checklist_de_visita__c Cv = null;
        Cl_usulas_do_Contrato__c Cc = null;
        Cl_usulas_do_Contrato__c Cc2 = null;
        LAT_Contract__c Lc = null;
        LAT_Contract__c Lc2 = null;
        Cota_nacional__c Cn = null;
        Cota_regional__c Cr = null;
        Criterio_nacional_de_cota__c Ccn = null;
        Criterio_de_cota_regional__c Ccr = null;
        Distribui_o_de_Valores__c Dv = null;
        Investimento_Bonificacao_e_Pagamento__c Inv = null;
        LAT_Opportunity__c Opp = null;
        LAT_OpportunityLineItem__c Oppl = null;
        Pagamento__c Pag = null;
        Pagamento_da_Verba__c Pagv = null;
        Planejamento__c Plan = null;
        Produto_Concorrente__c Pcc = null;
        Produto_Concorr_ncia__c Prc = null;
        Rateio_do_Contrato__c Rat = null;
        Task Tsk = null;
        Tipo_de_Documento__c Td = null;
        Tipo_de_Documento__c Td2 = null;
        Account Acc = null;
        Visitas__c Vis = null;
        SKU__c Sku = null;
        User usuario = null;
              Product2 lProd = new Product2();
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = 'qeweqewq';
        insert lProd;

        Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );     
        Id idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade'); 
        ID idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
        ID idAccount2 = RecordTypeForTest.getRecType('Account','On_Trade');  
        Id idRecTypeAtt = RecordTypeForTest.getRecType('Pagamento__c', 'Bonificacao_Produtos');    
                 
        Id catalogoPreco = null;
        Profile perfil = null;

         /* Get User profile for bypassing execution by System Administrator GDT - Jef 01/10/2013 */
             if((UserInfo.getProfileId()!='00eD0000001ApvPIAS') && (UserInfo.getProfileId()!= '00eL0000000DkgiIAC'))
             {   

              
         // usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2B','Sobrenome2B','NSobre2B','nome2B@sobrenome.com','test@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
          //  insert usuario;  
          //Recupera o ID do perfil desejado.


        /*//Cria nova UDC.      
        regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;*/

        perfil = [Select Id From Profile Where Name=:'LAT_BusinessAdministrator'];
        System.debug('%%%%%%%%%% perfil : '+ perfil);
              
            usuario = new User();
          usuario.FirstName       = 'Nome';
          usuario.LastName      = 'Sobrenome';
          usuario.Alias       = 'NSobre';
          usuario.Email         = 'nome@sobrenome.com';
          usuario.Username      = 'nome@sobrenomeJef.com';
          usuario.CommunityNickname   = '123jjjuuu';
          usuario.EmailEncodingKey  = 'ISO-8859-1';
          usuario.TimeZoneSidKey    = 'GMT';
          usuario.LocaleSidKey    = 'en_Us';
          usuario.LanguageLocaleKey = 'en_Us';
          usuario.C_digo_JDE__c   = '234';
          usuario.ProfileId       = perfil.Id;
          usuario.Country = 'BR';
          insert usuario;
              
  


                       
        /*//Cria nova Agrapumenta fiscal Year.      
        Ag = new Agrupamento_Fiscal_Year__c(); 
        insert Ag;
        Ag.Ano_Fiscal__c = '2013';
        update Ag;*/
            
        //Cria nova Planajemnto...      
        Plan = new  Planejamento__c(); 
        Plan.Name = 'XXXX'; 
        Plan.M_s_de_Ref_rencia__c = 'Janeiro';
        Plan.Ano_de_Referencia__c = '2016';
        insert Plan;
        //Plan.Name = 'YYYY';
        //update Plan;

        //Cria novo Account.      
        Acc = new Account();      
        //Acc.OwnerId = usuario.Id;      
        Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.RecordTypeId = idAccount;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'Off Trade';  
        Acc.Rating = 'Cliente';    
        //Acc.Regional__c = regional.Id;      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        //Acc.Customer_Flag__c = bandeira.Id;      
        insert Acc;
        Acc.Checking_account__c = '000';    
        update Acc;

        //Cria nova Visitas.      
        Vis = new Visitas__c(); 
        Vis.Conta__c = Acc.Id;
        Vis.Data_da_Visita__c = System.today();
        Vis.planejamento__c = Plan.Id;
        Vis.Hora_da_Visita__c = '8:00';
        Vis.Resumo_da_Visita__c = 'xxxx';
        insert Vis;

         Test.startTest();
        Utils.setMigrationDoneTest(true);     
        

        //Cria nova Checklist de Visita.      
        Cv = new  Checklist_de_visita__c(); 
        Cv.visita__c = Vis.Id;
        insert Cv;

        //Cria criterio SKU.      
        Sku = new  SKU__c(); 
        Sku.Nome_do_produto__c = 'prod2';
        insert Sku;

        /*//Cria nova producto concorrecte
        Pcc = new Produto_Concorrente__c();
        insert Pcc;

        //Cria nova producto concurrencia...      
        Prc = new  Produto_Concorr_ncia__c(); 
        Prc.Checklist_de_visita__c = Cv.Id;
        Prc.Produto_Concorrente__c = Pcc.id;
        insert Prc;
        Prc.Canal__c = 'Off Trade';
        update Prc; */

        //Cria nova pagamento ...      
        Pag = new  Pagamento__c();
        Pag.Cliente__c = Acc.Id; 
        insert Pag;
        Pag.Observacoes_Complementares__c = 'XXX';
        update Pag;
        Pag = new  Pagamento__c();
        Pag.Cliente__c = Acc.Id; 
        Pag.Observacoes_Complementares__c = 'YYY';
        Pag.RecordTypeId = RecordTypeForTest.getRecType('Pagamento__c', 'Dinheiro' );
        insert Pag;
        

        /*/Recupera o catalogo de preço padrão      
        //catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];        
        //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.      
        PricebookEntry entradaCatalogoPreco = new PricebookEntry();      
        entradaCatalogoPreco.Pricebook2Id = '01sD0000000h8wyIAA';        
        entradaCatalogoPreco.Product2Id = lprod.Id;      
        entradaCatalogoPreco.UnitPrice = 1000.00;      
        entradaCatalogoPreco.IsActive = true;      
        entradaCatalogoPreco.UseStandardPrice = false;      
        insert entradaCatalogoPreco;           

        //Cria nova oportunidade.      
        Opp = new Opportunity();      
        Opp.Name = 'Opp TESTE COTA';      
        Opp.closeDate = System.today()+1;      
        Opp.AccountId = acc.Id;      
        Opp.StageName = 'Novo pedido';      
        Opp.RecordTypeId = idOpportunity;      
        insert Opp;            

        //Cria um novo produto da oportunidade.      
        Oppl = new OpportunityLineItem();      
        Oppl.PricebookEntryId = entradaCatalogoPreco.Id;      
        Oppl.OpportunityId    = Opp.Id;      
        Oppl.UnitPrice        = 12;      
        Oppl.Quantity         = 15;      
        insert Oppl;

        //Cria criterio national de Cota.      
        Ccn = new  Criterio_nacional_de_cota__c(); 
        Ccn.Cota__c = 1;
        Ccn.SKU__c = Sku.id;
        Ccn.Cota__c = 1000;  
        //Ccn.Regional__c = true;
        //Ccn.Canal__c = true;
        Ccn.bandeira__c = true;
        Ccn.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c', 'BRA_Standard' );      
        insert Ccn;*/

        //Cria novo contrato.        
        Lc = new LAT_Contract__c();        
        Lc.OwnerId = usuario.Id;        
        //Lc.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato');
        Lc.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo');
        Lc.Account__c = Acc.Id;        
        Lc.Status__c = 'Reservado';        
        //Lc.Status__c = 'Ativo';        
        Lc.ROI_Comentarios_Negativo__c = 'Teste';        
        Lc.StartDate__c = System.today();        
        Lc.Gerente_Regional__c = Usuario.Id;
        Lc.Gerente__c = Usuario.Id;
        Lc.Gerente_de_area__c = Usuario.Id;  
        insert Lc;

        //Cria nova Clausula de contrato.     
        Cc = new  Cl_usulas_do_Contrato__c();
        Cc.Contrato__c = Lc.Id;
        insert Cc;

        //Cria nova type de doc.      
        Td = new Tipo_de_Documento__c(); 
        td.LAT_Contract__c = lc.id;
        insert Td;

        Lc.Cl_usulas_do_Contrato__c = Cc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.ContractTerm__c = 12; 
        update Lc; 


        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.LAT_Contract__c = Lc.id;
        ibp.Status_da_Verba__c='Reservado';
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        //ibp.Valor_R__c = 100;
        ibp.Perc_de_Rateio__c = 30;
        ibp.Valor_Percebido__c = 120.32;
        ibp.Custo_Bonificado__c = 89;
        ibp.Produto_Bonificado__c = lProd.id;
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.CasoEspecial__c = true;
        insert ibp;

        //Cria nova pagamento da verba ...      
        Pagv = new  Pagamento_da_Verba__c(); 
        Pagv.Pagamento__c = Pag.id;
        Pagv.conta__c = Acc.Id;
        Pagv.Investimento_Bonifica_o_e_Pagamento__c = ibp.Id;
        Pagv.pagar_com_produto__c = lProd.Id;
        Pagv.Sistema__c = 'ME';
        //Pagv.RecordTypeId = RecordTypeForTest.getRecType('Pagamento_da_verba__c', 'Dinheiro' );
        insert Pagv; 
        Pagv.Status__c = 'Aprovado Integrado';
        update Pagv;

        ibp.Valor_R__c = 100;
        update ibp;

        //Cria Distrinui o de valores.      
        Dv = new  Distribui_o_de_Valores__c(); 
        Dv.Clausulas_do_Contrato__c = Cc.Id;
        insert Dv;

        //Cria nova retaio de contrato...      
        Rat = new  Rateio_do_Contrato__c(); 
        Rat.LAT_Contract__c = Lc.Id;
        Rat.Perc_de_rateio__c = 20;
        insert Rat;

        
        Id idtRecTypeCase = RecordTypeForTest.getRecType('LAT_Case__c', 'Gerar_D_A_no_sistema_ME'); 

            Cas = new LAT_Case__c(
            RecordTypeId = idtRecTypeCase,
            LAT_Status__c = 'Fechado e resolvido',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            LAT_Type__c = 'Account Alteration ARG',
            LAT_IntegrationStatus__c = 'Reservado',
            LAT_DANumber__c = 123,
            LAT_Account__c = acc.id
        );




            Test.stopTest();
            }
    }    

    static testMethod void myUnitTest2BB() {
        Utils.setMigrationDoneTest(true); 
      
        //Declaração de variáveis.          

        UDC__C regional = null;     
        UDC__C bandeira = null; 
        Agrupamento_Fiscal_Year__c Ag = null;
        LAT_Case__c Cas = null;
        Attachment Att = null;
        Checklist_de_visita__c Cv = null;
        Cl_usulas_do_Contrato__c Cc = null;
        Cl_usulas_do_Contrato__c Cc2 = null;
        LAT_Contract__c Lc = null;
        LAT_Contract__c Lc2 = null;
        Cota_nacional__c Cn = null;
        Cota_regional__c Cr = null;
        Criterio_nacional_de_cota__c Ccn = null;
        Criterio_de_cota_regional__c Ccr = null;
        Distribui_o_de_Valores__c Dv = null;
        Investimento_Bonificacao_e_Pagamento__c Inv = null;
        LAT_Opportunity__c Opp = null;
        LAT_OpportunityLineItem__c Oppl = null;
        Pagamento__c Pag = null;
        Pagamento_da_Verba__c Pagv = null;
        Planejamento__c Plan = null;
        Produto_Concorrente__c Pcc = null;
        Produto_Concorr_ncia__c Prc = null;
        Rateio_do_Contrato__c Rat = null;
        Task Tsk = null;
        Tipo_de_Documento__c Td = null;
        Tipo_de_Documento__c Td2 = null;
        Account Acc = null;
        Visitas__c Vis = null;
        SKU__c Sku = null;
        User usuario = null;
              Product2 lProd = new Product2();
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = 'qeweqewq';
        insert lProd;

        Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );     
        Id idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade'); 
        ID idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
        ID idAccount2 = RecordTypeForTest.getRecType('Account','On_Trade');  
        Id idRecTypeAtt = RecordTypeForTest.getRecType('Pagamento__c', 'Bonificacao_Produtos');    
                 
        Id catalogoPreco = null;
        Profile perfil = null;

         /* Get User profile for bypassing execution by System Administrator GDT - Jef 01/10/2013 */
             if((UserInfo.getProfileId()!='00eD0000001ApvPIAS') && (UserInfo.getProfileId()!= '00eL0000000DkgiIAC'))
             {   

              
         // usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2B','Sobrenome2B','NSobre2B','nome2B@sobrenome.com','test@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
          //  insert usuario;  
          //Recupera o ID do perfil desejado.


        /*//Cria nova UDC.      
        regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;*/

        perfil = [Select Id From Profile Where Name=:'LAT_BusinessAdministrator'];
        System.debug('%%%%%%%%%% perfil : '+ perfil);
              
            usuario = new User();
          usuario.FirstName       = 'Nome';
          usuario.LastName      = 'Sobrenome';
          usuario.Alias       = 'NSobre';
          usuario.Email         = 'nome@sobrenome.com';
          usuario.Username      = 'nome@sobrenomeJef.com';
          usuario.CommunityNickname   = '123jjjuuu';
          usuario.EmailEncodingKey  = 'ISO-8859-1';
          usuario.TimeZoneSidKey    = 'GMT';
          usuario.LocaleSidKey    = 'en_Us';
          usuario.LanguageLocaleKey = 'en_Us';
          usuario.C_digo_JDE__c   = '234';
          usuario.ProfileId       = perfil.Id;
          usuario.Country = 'BR';
          insert usuario;
              
  


                       
        /*//Cria nova Agrapumenta fiscal Year.      
        Ag = new Agrupamento_Fiscal_Year__c(); 
        insert Ag;
        Ag.Ano_Fiscal__c = '2013';
        update Ag;*/
            
        //Cria nova Planajemnto...      
        Plan = new  Planejamento__c(); 
        Plan.Name = 'XXXX'; 
        Plan.M_s_de_Ref_rencia__c = 'Janeiro';
        Plan.Ano_de_Referencia__c = '2016';
        insert Plan;
        //Plan.Name = 'YYYY';
        //update Plan;

        //Cria novo Account.      
        Acc = new Account();      
        //Acc.OwnerId = usuario.Id;      
        Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.RecordTypeId = idAccount;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'Off Trade';  
        Acc.Rating = 'Cliente';    
        //Acc.Regional__c = regional.Id;      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        //Acc.Customer_Flag__c = bandeira.Id;      
        insert Acc;
        Acc.Checking_account__c = '000';    
        update Acc;

        //Cria nova Visitas.      
        Vis = new Visitas__c(); 
        Vis.Conta__c = Acc.Id;
        Vis.Data_da_Visita__c = System.today();
        Vis.planejamento__c = Plan.Id;
        Vis.Hora_da_Visita__c = '8:00';
        Vis.Resumo_da_Visita__c = 'xxxx';
        insert Vis;

         Test.startTest();
        Utils.setMigrationDoneTest(true);     
        

        //Cria nova Checklist de Visita.      
        

        /*//Cria nova producto concorrecte
        Pcc = new Produto_Concorrente__c();
        insert Pcc;

        //Cria nova producto concurrencia...      
        Prc = new  Produto_Concorr_ncia__c(); 
        Prc.Checklist_de_visita__c = Cv.Id;
        Prc.Produto_Concorrente__c = Pcc.id;
        insert Prc;
        Prc.Canal__c = 'Off Trade';
        update Prc; */

        //Cria nova pagamento ...      
        Pag = new  Pagamento__c();
        Pag.Cliente__c = Acc.Id; 
        insert Pag;
        Pag.Observacoes_Complementares__c = 'XXX';
        update Pag;
        Pag = new  Pagamento__c();
        Pag.Cliente__c = Acc.Id; 
        Pag.Observacoes_Complementares__c = 'YYY';
        Pag.RecordTypeId = RecordTypeForTest.getRecType('Pagamento__c', 'Dinheiro' );
        insert Pag;
        

        /*/Recupera o catalogo de preço padrão      
        //catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];        
        //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.      
        PricebookEntry entradaCatalogoPreco = new PricebookEntry();      
        entradaCatalogoPreco.Pricebook2Id = '01sD0000000h8wyIAA';        
        entradaCatalogoPreco.Product2Id = lprod.Id;      
        entradaCatalogoPreco.UnitPrice = 1000.00;      
        entradaCatalogoPreco.IsActive = true;      
        entradaCatalogoPreco.UseStandardPrice = false;      
        insert entradaCatalogoPreco;           

        //Cria nova oportunidade.      
        Opp = new Opportunity();      
        Opp.Name = 'Opp TESTE COTA';      
        Opp.closeDate = System.today()+1;      
        Opp.AccountId = acc.Id;      
        Opp.StageName = 'Novo pedido';      
        Opp.RecordTypeId = idOpportunity;      
        insert Opp;            

        //Cria um novo produto da oportunidade.      
        Oppl = new OpportunityLineItem();      
        Oppl.PricebookEntryId = entradaCatalogoPreco.Id;      
        Oppl.OpportunityId    = Opp.Id;      
        Oppl.UnitPrice        = 12;      
        Oppl.Quantity         = 15;      
        insert Oppl;

        //Cria criterio national de Cota.      
        Ccn = new  Criterio_nacional_de_cota__c(); 
        Ccn.Cota__c = 1;
        Ccn.SKU__c = Sku.id;
        Ccn.Cota__c = 1000;  
        //Ccn.Regional__c = true;
        //Ccn.Canal__c = true;
        Ccn.bandeira__c = true;
        Ccn.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c', 'BRA_Standard' );      
        insert Ccn;*/

        //Cria novo contrato.        
             /*Cria nova Case.      
        Cas = new Case(); 
        Cas.Integration_Status__c = 'Reservado';
        Cas.WF_Type__c = 'Jef';
        Cas.DA_Number__c = 123;
        //Cas.RecordtypeId = idRecTypeCase;*/
       // insert Cas;

        //Cria nova Attachment.     
         //Cria secundo novo contrato.        
        Lc2 = new LAT_Contract__c();        
        Lc2.OwnerId = usuario.Id;        
        //Lc2.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato');
        Lc2.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo');
        Lc2.Account__c = Acc.Id;        
        Lc2.Status__c = 'Reservado';        
        //Lc2.Status__c = 'Ativo';        
        Lc2.ROI_Comentarios_Negativo__c = 'Teste';        
        Lc2.StartDate__c = System.today();        
        Lc2.Gerente_Regional__c = Usuario.Id;
        Lc2.Gerente__c = Usuario.Id;
        Lc2.Gerente_de_area__c = Usuario.Id;  
        insert Lc2;

        Att = new Attachment(); 
        Att.ParentId = Lc2.Id;
        Att.Name = 'Doc Jef';
        Att.Body = Blob.valueof( 'asdasd' );
        //Att.RecordTypeId = idRecTypeAtt;
        insert Att;


       

        //Cria nova Clausula de contrato.     
        Cc2 = new  Cl_usulas_do_Contrato__c();
        Cc2.Descricao__c = 'Jef XXX2';
        Cc2.Contrato__c = Lc2.Id;
        insert Cc2;
        Cv = new  Checklist_de_visita__c(); 
        Cv.visita__c = Vis.Id;
        insert Cv;
        //Cria Distrinui o de valores.      
        Dv = new  Distribui_o_de_Valores__c(); 
        Dv.Clausulas_do_Contrato__c = Cc2.Id;
        insert Dv;
        //Cria criterio SKU.      
        Sku = new  SKU__c(); 
        Sku.Nome_do_produto__c = 'prod2';
        insert Sku;
        //Cria nova type de doc.      
        Td2 = new Tipo_de_Documento__c(); 
        td2.LAT_Contract__c = lc2.id;
        insert Td2;

        // Delete Pagamento
        Pagamento__c[] Pag2 = [Select Id from Pagamento__c where Observacoes_Complementares__c = 'YYY' ];
        delete Pag2;

        // Delete Cl_usualas_dp_contrato    
        Cl_usulas_do_Contrato__c[] Cc3 = [Select Id from  Cl_usulas_do_Contrato__c where Contrato__c = :Lc2.Id limit 1];
        delete Cc3;

        // Delete Tipo de documento    
        Tipo_de_Documento__c[] Td3 = [Select Id from Tipo_de_Documento__c where LAT_Contract__c = :lc2.Id limit 1]; 
        delete Td3;

        //               ABOVE IS : OK  OK  OK  OK   

        //Cria nova Cota national.      
        //Cn = new  Cota_nacional__c(); 
        //Cn.Cota__c = 1;
        //Cn.Criterio_nacional_de_cota__c = Ccn.Id;
        //insert Cn;

        //Cria criterio de Cota regional.      
        //Ccr = new  Criterio_de_cota_regional__c(); 
        //Ccr.Cota__c = 1;
        //insert Ccr;

        //Cria nova Cota regional.      
        //Cr = new  Cota_regional__c(); 
        //Cr.Cota__c = 1;
        //insert Cr;


        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.LAT_Contract__c = Lc2.id;
        ibp.Status_da_Verba__c='Reservado';
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        //ibp.Valor_R__c = 100;
        ibp.Perc_de_Rateio__c = 30;
        ibp.Valor_Percebido__c = 120.32;
        ibp.Custo_Bonificado__c = 89;
        ibp.Produto_Bonificado__c = lProd.id;
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.CasoEspecial__c = true;
        insert ibp;



        ibp.Valor_R__c = 100;
        update ibp;



        //Cria nova retaio de contrato...      
        Rat = new  Rateio_do_Contrato__c(); 
        Rat.LAT_Contract__c = Lc2.Id;
        Rat.Perc_de_rateio__c = 20;
        insert Rat;

        
        Id idtRecTypeCase = RecordTypeForTest.getRecType('LAT_Case__c', 'Gerar_D_A_no_sistema_ME'); 

            Cas = new LAT_Case__c(
            RecordTypeId = idtRecTypeCase,
            LAT_Status__c = 'Fechado e resolvido',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            LAT_Type__c = 'Account Alteration ARG',
            LAT_IntegrationStatus__c = 'Reservado',
            LAT_DANumber__c = 123,
            LAT_Account__c = acc.id
        );
        insert cas;



            Test.stopTest();
            }
    } 

   

}