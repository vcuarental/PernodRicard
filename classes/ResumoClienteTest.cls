@isTest(seealldata=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do controlador ResumoCliente.cls
* NAME: ResumoClienteTeste.CLS
* AUTHOR:                                           DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/06/2012
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/
private class ResumoClienteTest {

      static testMethod void ResumoClienteTest() 
      {
            Utils.setMigrationDoneTest(false);
            //Declaração de variáveis.
            Account acc, acc2, acc3         = null;
            User usuario              = null;
            Planejamento__c plan          = null;
            Profile perfil              = null;
            List<RecordType> listRecType      = null;
            List<String> developerName        = null;
            Map<String, String> mapRecType      = null;
            UDC__c regional, org, bandeira, classSub, banco, condicao, glCliente, instrumento, areaNielsen, regGeo  = null;
            String idAccount            = null;
            Par_metro_Produto_Concorr_ncia__c param = null;
            Product2 produto            = null;
            CustomerRSPProducts__c customProd,customProd2,customProd3   = null;
            CustomerRSPProfiles__c customProfile,customProfile2,customProfile3  = null;
            Visitas__c visita, visita2 = null;
            Event compromisso = null;
            Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
            
            //Recupera os IDS de tipo de registro.
            idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
            
            //Recupera o ID do perfil desejado.
            
            
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '4546';
            regional.RecordTypeId = idRecTypeUDC;
            //insert regional;
            try{insert regional;}catch(Exception e){}
            
            //Cria nova UDC.
            org = new UDC__c();
            org.CodDefUsuario__c  = '171';
            org.CodProd__c      = '01';
            org.CodUs__c      = '10';
            org.Internal_Id__c    = '171';
            org.RecordTypeId = idRecTypeUDC;
            //insert org;
            try{ insert org;}catch(Exception e){}
            
            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c = '179'; 
            bandeira.RecordTypeId = idRecTypeUDC;
            //insert bandeira;
            try{insert bandeira;}catch(Exception e){}
            
            //Cria nova UDC.
            classSub = new UDC__c();
            classSub.CodDefUsuario__c = '1889';
            classSub.CodProd__c     = '01';
            classSub.CodUs__c     = '03';
            classSub.Internal_Id__c   = '1889';
            classSub.RecordTypeId = idRecTypeUDC;
            //insert classSub;
            try{ insert classSub;}catch(Exception e){}
            
            //Cria nova UDC.
            banco = new UDC__c();
            banco.CodDefUsuario__c  = '1234';
            banco.CodProd__c    = '76';
            banco.CodUs__c      = 'BC';
            banco.Internal_Id__c  = '1234';
            banco.RecordTypeId = idRecTypeUDC;
            //insert banco;
            try{insert banco;}catch(Exception e){}
            
            //Cria nova UDC.
            condicao = new UDC__c();
            condicao.CodDefUsuario__c = '1235';
            condicao.CodProd__c     = 'CRM';
            condicao.CodUs__c     = 'PT';
            condicao.Internal_Id__c   = '1235';
            condicao.RecordTypeId = idRecTypeUDC;
            //insert condicao;
            try{insert condicao;}catch(Exception e){}
            
            //Cria nova UDC.
            glCliente = new UDC__c();
            glCliente.CodDefUsuario__c  = '1236';
            glCliente.CodProd__c    = '55';
            glCliente.CodUs__c      = 'GL';
            glCliente.Internal_Id__c  = '1236';
            glCliente.RecordTypeId = idRecTypeUDC;
            //insert glCliente;
            try{ insert glCliente;}catch(Exception e){}
            
            //Cria nova UDC.
            instrumento = new UDC__c();
            instrumento.CodDefUsuario__c  = '1237';
            instrumento.CodProd__c      = '00';
            instrumento.CodUs__c      = 'PY';
            instrumento.Internal_Id__c    = '1237';
            instrumento.RecordTypeId = idRecTypeUDC;
            //insert instrumento;
            try{ insert instrumento;}catch(Exception e){}
            
            //Cria nova UDC.
            areaNielsen = new UDC__c();
            areaNielsen.CodDefUsuario__c  = '1238';
            areaNielsen.CodProd__c      = '01';
            areaNielsen.CodUs__c      = '04';
            areaNielsen.Internal_Id__c    = '1238';
            areaNielsen.RecordTypeId = idRecTypeUDC;
            //insert areaNielsen;
            try{ insert areaNielsen;}catch(Exception e){}
            
            //Cria nova UDC.
            regGeo = new UDC__c();
            regGeo.CodDefUsuario__c = '1239';
            regGeo.CodProd__c   = '01';
            regGeo.CodUs__c     = '11';
            regGeo.Internal_Id__c = '1239';
            regGeo.RecordTypeId = idRecTypeUDC;
            //insert regGeo;
            try{insert regGeo;}catch(Exception e){}
            
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            //insert usuario;
            try{insert usuario;}catch(Exception e){}
        
            
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'Conta PlanejamentoVisitasCriaVisitasTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'XXXX';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = '1';
            acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
            try{
            //insert acc;
            }
            catch(DMLException e){
              System.debug(e.getMessage());
            }
            
            //Cria novo planejamento.
            plan = new Planejamento__c();
            plan.Ano_de_Referencia__c = '2012';
            plan.M_s_de_Ref_rencia__c = 'Janeiro';
            plan.Name = 'Teste';
            plan.OwnerId = usuario.Id;
            plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
            //insert plan;
            try{insert plan;}catch(Exception e){}
            
            //Cria nova visita.
            visita = new Visitas__c();
            visita.Conta__c = acc.Id;
            visita.Name = 'NOME';
            visita.Data_da_Visita__c = System.today();
            visita.Hora_da_Visita__c = '08:00';
            visita.Planejamento__c = plan.Id;
            visita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
            visita.Resumo_da_Visita__c = 'teste';
            //insert visita;
            try{insert visita;}catch(Exception e){}
            
            //Cria nova visita.
            visita2 = new Visitas__c();
            visita2.Conta__c = acc.Id;
            visita2.Name = 'NOME';
            visita2.Data_da_Visita__c = System.today()-1;
            visita2.Hora_da_Visita__c = '08:00';
            visita2.Planejamento__c = plan.Id;
            visita2.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
            visita2.Resumo_da_Visita__c = 'teste';
            //insert visita2;
            try{insert visita2;}catch(Exception e){}
            
            Opportunity lPedido = new Opportunity();
            lPedido.Name = 'Teste';
            lPedido.AccountId = acc.id;
            lPedido.CloseDate = Date.today()+1;
            lPedido.StageName = 'Novo pedido';
            lPedido.RecordTypeId = RecordTypeForTest.getRecType( 'Opportunity', 'Nova_oportunidade' );
            //insert lPedido;
            try{insert lPedido;}catch(Exception e){}
            
            produto = new Product2();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.IsActive = true;
            produto.CD_Unit__c = 'UN';
            produto.Internal_id__c = '123';
            //produto.QT_lead_time__c = 5;
            produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
            //insert produto;
            try{insert produto;}catch(Exception e){}
            
            List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];
            
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            //insert entradaCatalogoPreco;
            try{insert entradaCatalogoPreco;}catch(Exception e){}
            
            OpportunityLineItem lItem = new OpportunityLineItem();
            lItem.OpportunityId = lPedido.Id;
            lItem.PricebookEntryId = entradaCatalogoPreco.Id;
            lItem.Quantity = 1;
            lItem.UnitPrice = 1000.00;
            //insert lItem;
            try{insert lItem;}catch(Exception e){}
            
            
            lPedido = new Opportunity();
            lPedido.Name = 'Teste2';
            lPedido.AccountId = acc.id;
            lPedido.CloseDate = Date.today()+1;
            lPedido.StageName = 'Novo pedido';
            lPedido.RecordTypeId = RecordTypeForTest.getRecType( 'Opportunity', 'Nova_oportunidade' );
            //insert lPedido;
            try{insert lPedido;}catch(Exception e){}
            
            lItem = new OpportunityLineItem();
            lItem.OpportunityId = lPedido.Id;
            lItem.PricebookEntryId = entradaCatalogoPreco.Id;
            lItem.Quantity = 2;
            lItem.UnitPrice = 1000.00;
            lItem.cd_line_status__c = '999';
            //insert lItem;
            try{insert lItem;}catch(Exception e){}
            
              
            try{
             ResumoCliente lTela = new ResumoCliente( new ApexPages.StandardController( visita2 ) );
            }
            catch(Exception e)
            {
              System.debug(e.getMessage());
            }
      }
      static testMethod void ResumoClienteTest2() 
      {
            Utils.setMigrationDoneTest(true);
            //Declaração de variáveis.
            Account acc, acc2, acc3         = null;
            User usuario              = null;
            Planejamento__c plan          = null;
            Profile perfil              = null;
            List<RecordType> listRecType      = null;
            List<String> developerName        = null;
            Map<String, String> mapRecType      = null;
            UDC__c regional, org, bandeira, classSub, banco, condicao, glCliente, instrumento, areaNielsen, regGeo  = null;
            String idAccount            = null;
            Par_metro_Produto_Concorr_ncia__c param = null;
            LAT_Product__c produto            = null;
            CustomerRSPProducts__c customProd,customProd2,customProd3   = null;
            CustomerRSPProfiles__c customProfile,customProfile2,customProfile3  = null;
            Visitas__c visita, visita2 = null;
            Event compromisso = null;
            Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
            
            //Recupera os IDS de tipo de registro.
            idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
            
            //Recupera o ID do perfil desejado.
            
            
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '4546';
            regional.RecordTypeId = idRecTypeUDC;
            //insert regional;
            try{insert regional;}catch(Exception e){}
            
            //Cria nova UDC.
            org = new UDC__c();
            org.CodDefUsuario__c  = '171';
            org.CodProd__c      = '01';
            org.CodUs__c      = '10';
            org.Internal_Id__c    = '171';
            org.RecordTypeId = idRecTypeUDC;
            //insert org;
            try{ insert org;}catch(Exception e){}
            
            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c = '179'; 
            bandeira.RecordTypeId = idRecTypeUDC;
            //insert bandeira;
            try{insert bandeira;}catch(Exception e){}
            
            //Cria nova UDC.
            classSub = new UDC__c();
            classSub.CodDefUsuario__c = '1889';
            classSub.CodProd__c     = '01';
            classSub.CodUs__c     = '03';
            classSub.Internal_Id__c   = '1889';
            classSub.RecordTypeId = idRecTypeUDC;
            //insert classSub;
            try{ insert classSub;}catch(Exception e){}
            
            //Cria nova UDC.
            banco = new UDC__c();
            banco.CodDefUsuario__c  = '1234';
            banco.CodProd__c    = '76';
            banco.CodUs__c      = 'BC';
            banco.Internal_Id__c  = '1234';
            banco.RecordTypeId = idRecTypeUDC;
            //insert banco;
            try{insert banco;}catch(Exception e){}
            
            //Cria nova UDC.
            condicao = new UDC__c();
            condicao.CodDefUsuario__c = '1235';
            condicao.CodProd__c     = 'CRM';
            condicao.CodUs__c     = 'PT';
            condicao.Internal_Id__c   = '1235';
            condicao.RecordTypeId = idRecTypeUDC;
            //insert condicao;
            try{insert condicao;}catch(Exception e){}
            
            //Cria nova UDC.
            glCliente = new UDC__c();
            glCliente.CodDefUsuario__c  = '1236';
            glCliente.CodProd__c    = '55';
            glCliente.CodUs__c      = 'GL';
            glCliente.Internal_Id__c  = '1236';
            glCliente.RecordTypeId = idRecTypeUDC;
            //insert glCliente;
            try{ insert glCliente;}catch(Exception e){}
            
            //Cria nova UDC.
            instrumento = new UDC__c();
            instrumento.CodDefUsuario__c  = '1237';
            instrumento.CodProd__c      = '00';
            instrumento.CodUs__c      = 'PY';
            instrumento.Internal_Id__c    = '1237';
            instrumento.RecordTypeId = idRecTypeUDC;
            //insert instrumento;
            try{ insert instrumento;}catch(Exception e){}
            
            //Cria nova UDC.
            areaNielsen = new UDC__c();
            areaNielsen.CodDefUsuario__c  = '1238';
            areaNielsen.CodProd__c      = '01';
            areaNielsen.CodUs__c      = '04';
            areaNielsen.Internal_Id__c    = '1238';
            areaNielsen.RecordTypeId = idRecTypeUDC;
            //insert areaNielsen;
            try{ insert areaNielsen;}catch(Exception e){}
            
            //Cria nova UDC.
            regGeo = new UDC__c();
            regGeo.CodDefUsuario__c = '1239';
            regGeo.CodProd__c   = '01';
            regGeo.CodUs__c     = '11';
            regGeo.Internal_Id__c = '1239';
            regGeo.RecordTypeId = idRecTypeUDC;
            //insert regGeo;
            try{insert regGeo;}catch(Exception e){}
            
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            //insert usuario;
            try{insert usuario;}catch(Exception e){}
        
            
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'Conta PlanejamentoVisitasCriaVisitasTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'XXXX';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = '1';
            acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
            try{
            //insert acc;
            }
            catch(DMLException e){
              System.debug(e.getMessage());
            }
            
            //Cria novo planejamento.
            plan = new Planejamento__c();
            plan.Ano_de_Referencia__c = '2012';
            plan.M_s_de_Ref_rencia__c = 'Janeiro';
            plan.Name = 'Teste';
            plan.OwnerId = usuario.Id;
            plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
            //insert plan;
            try{insert plan;}catch(Exception e){}
            
            //Cria nova visita.
            visita = new Visitas__c();
            visita.Conta__c = acc.Id;
            visita.Name = 'NOME';
            visita.Data_da_Visita__c = System.today();
            visita.Hora_da_Visita__c = '08:00';
            visita.Planejamento__c = plan.Id;
            visita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
            visita.Resumo_da_Visita__c = 'teste';
            //insert visita;
            try{insert visita;}catch(Exception e){}
            
            //Cria nova visita.
            visita2 = new Visitas__c();
            visita2.Conta__c = acc.Id;
            visita2.Name = 'NOME';
            visita2.Data_da_Visita__c = System.today()-1;
            visita2.Hora_da_Visita__c = '08:00';
            visita2.Planejamento__c = plan.Id;
            visita2.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
            visita2.Resumo_da_Visita__c = 'teste';
            //insert visita2;
            try{insert visita2;}catch(Exception e){}
            
            LAT_Opportunity__c lPedido = new LAT_Opportunity__c();
            lPedido.Name = 'Teste';
            lPedido.LAT_Account__c = acc.id;
            lPedido.LAT_CloseDate__c = Date.today()+1;
            lPedido.LAT_StageName__c = 'Novo pedido';
            lPedido.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Nova_oportunidade' );
            //insert lPedido;
            try{insert lPedido;}catch(Exception e){}
            
            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '123';
            //produto.QT_lead_time__c = 5;
            produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
            //insert produto;
            try{insert produto;}catch(Exception e){}
            
            LAT_OpportunityLineItem__c lItem = new LAT_OpportunityLineItem__c();
            lItem.LAT_Opportunity__c = lPedido.Id;
            lItem.LAT_Product__c = produto.Id;
            lItem.LAT_Quantity__c = 1;
            lItem.LAT_UnitPrice__c = 1000.00;
            //insert lItem;
            try{insert lItem;}catch(Exception e){}
            
            
            lPedido = new LAT_Opportunity__c();
            lPedido.Name = 'Teste2';
            lPedido.LAT_Account__c = acc.id;
            lPedido.LAT_CloseDate__c = Date.today()+1;
            lPedido.LAT_StageName__c = 'Novo pedido';
            lPedido.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Nova_oportunidade' );
            //insert lPedido;
            try{insert lPedido;}catch(Exception e){}
            
            lItem = new LAT_OpportunityLineItem__c();
            lItem.LAT_Opportunity__c = lPedido.Id;
            lItem.LAT_Product__c = produto.Id;
            lItem.LAT_Quantity__c = 2;
            lItem.LAT_UnitPrice__c = 1000.00;
            lItem.LAT_CdLineStatus__c = '999';
            //insert lItem;
            try{insert lItem;}catch(Exception e){}
            
              
            try{
             ResumoCliente lTela = new ResumoCliente( new ApexPages.StandardController( visita2 ) );
            }
            catch(Exception e)
            {
              System.debug(e.getMessage());
            }
      }

}