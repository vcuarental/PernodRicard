/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe de teste da trigger InvestBonifPagtoROI_RecalculaContrato.trigger
* NAME: InvestBonifPagto_ROI_RecalcContratoTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 15/08/2012
*
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

@isTest()
private class InvestBonifPagto_ROI_RecalcContratoTest {

      static testMethod void myUnitTest() {
            Test.startTest();
            Utils.setMigrationDoneTest(false); 
            //Recupera os IDS de tipo de registro.
            Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
            Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
            Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
            
            User usuario = new User();
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            
            //Cria nova UDC.S
            UDC__c regional = new UDC__c();
            regional.CodDefUsuario__c = '1';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '01-01';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //Cria nova UDC.
            UDC__c bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '01-06';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;
            
            //Cria novo Account.
            Account acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idRecTypeAcc;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Channel_Type__c = 'Indireto';
            acc.Client_code_AN8__c = '557799';
            acc.Price_Group__c = '1';
            acc.Customer_Flag__c = bandeira.Id;
            acc.Revenue_UF__c = 'SP';
            acc.Regional_Manager__c = usuario.id;
            insert acc;
            
            LAT_Contract__c lContrato = new LAT_Contract__c();
            lContrato.Account__c = acc.id;
            lContrato.Status__c = 'Em elaboração';
            lContrato.StartDate__c = System.today();
            lContrato.ContractTerm__c = 12;
            lContrato.OwnerId = usuario.Id;
            lContrato.trigger_on__c = true;
            lContrato.RecordTypeId = idrecTypeLatCon;
            insert lContrato;


            
            Product2 lProd = new Product2();
            lProd.Description = 'Cachaca';
            lProd.Name = 'Cachaca';
            lProd.Internal_id__c = 'asdad';
            lProd.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard');
            insert lProd;
            
            Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
            IBP.LAT_Contract__c = lContrato.Id;
            IBP.Produto_Bonificado__c = lProd.id;
            IBP.Volume_Cx__c = 10;
            IBP.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
            IBP.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
            insert IBP;

            Test.stopTest();
    }
     //MIGRATED 21/11/2016
      static testMethod void myUnitTest2() { 
            Test.startTest();
            //Recupera os IDS de tipo de registro.
            Utils.setMigrationDoneTest(true); 
            Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
            Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
            Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
            
            User usuario = new User();
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            
            //Cria nova UDC.S
            UDC__c regional = new UDC__c();
            regional.CodDefUsuario__c = '1';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '01-01';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //Cria nova UDC.
            UDC__c bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '01-06';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;
            
            //Cria novo Account.
            Account acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idRecTypeAcc;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Channel_Type__c = 'Indireto';
            acc.Client_code_AN8__c = '557799';
            acc.Price_Group__c = '1';
            acc.Customer_Flag__c = bandeira.Id;
            acc.Revenue_UF__c = 'SP';
            acc.Regional_Manager__c = usuario.id;
            insert acc;
            
            LAT_Contract__c lContrato = new LAT_Contract__c();
            lContrato.Account__c = acc.id;
            lContrato.Status__c = 'Em elaboração';
            lContrato.StartDate__c = System.today();
            lContrato.ContractTerm__c = 12;
            lContrato.OwnerId = usuario.Id;
            lContrato.trigger_on__c = true;
            lContrato.RecordTypeId = idrecTypeLatCon;
            insert lContrato;
            
            LAT_Product__c lProd = new LAT_Product__c();
            lProd.LAT_Description__c = 'Cachaca';
            lProd.Name = 'Cachaca';
            lProd.LAT_ExternalID__c = 'asdad';
            lProd.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard');
            insert lProd;
            
            Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
            IBP.LAT_Contract__c = lContrato.Id;
            IBP.LAT_Product__c = lProd.id;
            IBP.Volume_Cx__c = 10;
            IBP.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
            IBP.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
            insert IBP;

            Test.stopTest();
    }


      static testMethod void myUnitTestB() {
            Test.startTest();
            Utils.setMigrationDoneTest(false); 
            //Recupera os IDS de tipo de registro.
            Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
            Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
            Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
            
            User usuario = new User();
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            
            //Cria nova UDC.S
            UDC__c regional = new UDC__c();
            regional.CodDefUsuario__c = '1';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '01-01';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //Cria nova UDC.
            UDC__c bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '01-06';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;
            
            //Cria novo Account.
            Account acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idRecTypeAcc;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Channel_Type__c = 'Indireto';
            acc.Client_code_AN8__c = '557799';
            acc.Price_Group__c = '1';
            acc.Customer_Flag__c = bandeira.Id;
            acc.Revenue_UF__c = 'SP';
            acc.Regional_Manager__c = usuario.id;
            insert acc;
            
            LAT_Contract__c lContrato = new LAT_Contract__c();
            lContrato.Account__c = acc.id;
            lContrato.Status__c = 'Em elaboração';
            lContrato.StartDate__c = System.today();
            lContrato.ContractTerm__c = 12;
            lContrato.OwnerId = usuario.Id;
            lContrato.trigger_on__c = true;
            lContrato.RecordTypeId = idrecTypeLatCon;
            insert lContrato;

            //ContratoSemaphoro.setNewCode(lContrato.Id, 'test');
            
            Product2 lProd = new Product2();
            lProd.Description = 'Cachaca';
            lProd.Name = 'Cachaca';
            lProd.Internal_id__c = 'asdad';
            lProd.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard');
            insert lProd;
            
            Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
            IBP.LAT_Contract__c = lContrato.Id;
            IBP.Produto_Bonificado__c = lProd.id;
            IBP.Volume_Cx__c = 10;
            IBP.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
            IBP.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
            insert IBP;
            Test.stopTest();
    }
     //MIGRATED 21/11/2016
      static testMethod void myUnitTest2B() { 

            Test.startTest();
            //Recupera os IDS de tipo de registro.
            Utils.setMigrationDoneTest(true); 
            Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
            Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
            Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
            
            User usuario = new User();
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            
            //Cria nova UDC.S
            UDC__c regional = new UDC__c();
            regional.CodDefUsuario__c = '1';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '01-01';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;
            
            //Cria nova UDC.
            UDC__c bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '01-06';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;
            
            //Cria novo Account.
            Account acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idRecTypeAcc;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'Off Trade';
            acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Channel_Type__c = 'Indireto';
            acc.Client_code_AN8__c = '557799';
            acc.Price_Group__c = '1';
            acc.Customer_Flag__c = bandeira.Id;
            acc.Revenue_UF__c = 'SP';
            acc.Regional_Manager__c = usuario.id;
            insert acc;
            
            LAT_Contract__c lContrato = new LAT_Contract__c();
            lContrato.Account__c = acc.id;
            lContrato.Status__c = 'Em elaboração';
            lContrato.StartDate__c = System.today();
            lContrato.ContractTerm__c = 12;
            lContrato.OwnerId = usuario.Id;
            lContrato.trigger_on__c = true;
            lContrato.RecordTypeId = idrecTypeLatCon;
            insert lContrato;



            //ContratoSemaphoro.setNewCode(lContrato.Id, 'test');

            LAT_Product__c lProd = new LAT_Product__c();
            lProd.LAT_Description__c = 'Cachaca';
            lProd.Name = 'Cachaca';
            lProd.LAT_ExternalID__c = 'asdad';
            lProd.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard');
            insert lProd;
            
            Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
            IBP.LAT_Contract__c = lContrato.Id;
            IBP.LAT_Product__c = lProd.id;
            IBP.Volume_Cx__c = 10;
            IBP.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
            IBP.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
            insert IBP;

            Test.stopTest();
    }
}