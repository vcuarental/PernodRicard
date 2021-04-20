@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Responsável pelo teste de cobertura do seguinte código:
* ProdutosOppVerificaCotaExistente.trigger
*
* NAME: ProdutosOppVerificaCotaExistenteTeste.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/
private class ProdutosOppVerificaCotaExistenteTeste {

      static testMethod void ProdutosOppVerificaCotaExistenteTeste() 
      {
            Utils.setMigrationDoneTest(false);        
            //Declaração de variáveis.
            Account acc                           = null;
            UDC__c regional, bandeira, cidade     = null;
            Profile perfil                        = null;
            SKU__c sku                            = null;
            //Criterio_de_cota_regional__c critR    = null;
            Criterio_nacional_de_cota__c critN    = null;
            Cota_nacional__c cotaN                = null;
            Cota_regional__c cotaR                = null;
            Opportunity opp                       = null;
            OpportunityLineItem oli               = null;
            User usuario                          = null;
            Product2 produto                      = null;
            Pricebook2 pricebook                  = null;
            PricebookEntry pbe                    = null;
            List<RecordType> listRecType          = null;
            List<String> developerName            = null;
            Map<String, String> mapRecType        = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
            
            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
            
            
          
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;

            //Recupera o ID do perfil desejado.
            //
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
          
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
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = '1';
            //acc.Customer_Flag__c = bandeira.Id;
            insert acc;
            
            produto = new Product2();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.IsActive = true;
            produto.CD_Unit__c = 'UN';
            produto.Internal_id__c = '9999999';
            //produto.QT_lead_time__c = 5;
            produto.SKU__c = '9999999';
            produto.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
            insert produto;
            
            test.startTest();
            Utils.setMigrationDoneTest(false);        
            //Recupera o catalogo de preço padrão
            List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];
        
            //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            insert entradaCatalogoPreco;
              
            //Cria novo sku.
            sku = new SKU__c();
            sku.Name = '9999999';
            sku.Nome_do_produto__c = 'TESTE';
            sku.RecordTypeId = Global_RecordTypeCache.getRtId('SKU__c' + 'BRA_Standard');
            insert sku;
            
            //Cria novo critério nacional.
            critN = new Criterio_nacional_de_cota__c();
            critN.SKU__c = sku.Id;
            critN.Cota__c = 500;
            critN.Canal__c = true;
            critN.Bandeira__c = true;
            critN.Regional__c = true;
            critN.Subcanal__c = true;
            critN.RecordTypeId = Global_RecordTypeCache.getRtId('Criterio_nacional_de_cota__c' + 'BRA_Standard');
            insert critN;
            
            //Cria nova cota nacional.
            cotaN = new Cota_nacional__c();
            cotaN.Cota__c = 500;
            cotaN.Canal__c = 'Off Trade';
            cotaN.Sub_canal__c = 'Atacadista';
            cotaN.Regional__c = regional.Id;
            cotaN.Bandeira__c = bandeira.Id;
            cotaN.Criterio_nacional_de_cota__c = critN.Id;
            cotaN.RecordTypeId = Global_RecordTypeCache.getRtId('Cota_nacional__c' + 'BRA_Standard');
            insert cotaN;
            
            Fornecedor__c forn = new Fornecedor__c();
            forn.Codigo_do_Fornecedor_AN8__c = '445566';
            forn.RecordTypeId = Global_RecordTypeCache.getRtId('Fornecedor__c' + 'BRA_Standard');
            Database.Saveresult[] resultsForn = Database.insert(new Fornecedor__c[]{ forn }, false );

            //Recupera os IDS de tipo de registro.
            idOpportunity = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade');
            
            //Cria nova oportunidade.
            opp = new Opportunity();
            opp.Name = 'Opp TESTE COTA';
            opp.closeDate = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.AccountId = acc.Id;
            opp.StageName = 'Novo Pedido';
            
            insert opp;
            
            //Cria um novo produto da oportunidade.
            oli = new OpportunityLineItem();
            oli.PricebookEntryId = entradaCatalogoPreco.Id;
            oli.OpportunityId    = opp.Id;
            oli.UnitPrice        = 12;
            oli.Quantity         = 12;
            
            //try to insert user
            Database.SaveResult[] resultsOli = Database.insert( new OpportunityLineItem[]{ oli }, false );
            delete oli;
            test.stopTest();
            
      }

      static testMethod void ProdutosOppVerificaCotaExistenteTeste2() 
      {
            Utils.setMigrationDoneTest(true);        
            //Declaração de variáveis.
            Account acc                           = null;
            UDC__c regional, bandeira, cidade     = null;
            Profile perfil                        = null;
            SKU__c sku                            = null;
            //Criterio_de_cota_regional__c critR    = null;
            Criterio_nacional_de_cota__c critN    = null;
            Cota_nacional__c cotaN                = null;
            Cota_regional__c cotaR                = null;
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            List<RecordType> listRecType          = null;
            List<String> developerName            = null;
            Map<String, String> mapRecType        = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
            
            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
            
            
          
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;

            //Recupera o ID do perfil desejado.
            //
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
          
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
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = '1';
            //acc.Customer_Flag__c = bandeira.Id;
            insert acc;
            
            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '9999999';
            //produto.QT_lead_time__c = 5;
            produto.LAT_Sku__c = '9999999';
            produto.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
            insert produto;
            
            test.startTest();
            Utils.setMigrationDoneTest(true);        
            //Recupera o catalogo de preço padrão
            
            //Cria novo sku.
            sku = new SKU__c();
            sku.Name = '9999999';
            sku.Nome_do_produto__c = 'TESTE';
            sku.RecordTypeId = Global_RecordTypeCache.getRtId('SKU__c' + 'BRA_Standard');
            insert sku;
            
            //Cria novo critério nacional.
            critN = new Criterio_nacional_de_cota__c();
            critN.SKU__c = sku.Id;
            critN.Cota__c = 500;
            critN.Canal__c = true;
            critN.Bandeira__c = true;
            critN.Regional__c = true;
            critN.Subcanal__c = true;
            critN.RecordTypeId = Global_RecordTypeCache.getRtId('Criterio_nacional_de_cota__c' + 'BRA_Standard');
            insert critN;
            
            //Cria nova cota nacional.
            cotaN = new Cota_nacional__c();
            cotaN.Cota__c = 500;
            cotaN.Canal__c = 'Off Trade';
            cotaN.Sub_canal__c = 'Atacadista';
            cotaN.Regional__c = regional.Id;
            cotaN.Bandeira__c = bandeira.Id;
            cotaN.Criterio_nacional_de_cota__c = critN.Id;
            cotaN.RecordTypeId = Global_RecordTypeCache.getRtId('Cota_nacional__c' + 'BRA_Standard');
            insert cotaN;
            
            Fornecedor__c forn = new Fornecedor__c();
            forn.Codigo_do_Fornecedor_AN8__c = '445566';
            forn.RecordTypeId = Global_RecordTypeCache.getRtId('Fornecedor__c' + 'BRA_Standard');
            Database.Saveresult[] resultsForn = Database.insert(new Fornecedor__c[]{ forn }, false );

            //Recupera os IDS de tipo de registro.
            idOpportunity = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade');
            
            //Cria nova oportunidade.
            opp = new LAT_Opportunity__c();
            opp.Name = 'Opp TESTE COTA';
            opp.LAT_CloseDate__c = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.LAT_Account__c = acc.Id;
            opp.LAT_StageName__c = 'Novo Pedido';
            
            insert opp;
            
            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            
            //try to insert user
            Database.SaveResult[] resultsOli = Database.insert( new LAT_OpportunityLineItem__c[]{ oli }, false );
            delete oli;
            test.stopTest();
            
      }

}