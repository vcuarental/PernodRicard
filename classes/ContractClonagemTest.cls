/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe ContractClonagem
* NAME: ContractClonagemTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 23/08/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 10/11/2012
*
* AUTHOR: CARLOS CARVALHO                           DATE: 16/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
*
* AUTHOR: CARLOS CARVALHO                           DATE: 22/01/2013
* DESC: INSERIDO NOVO CAMPO PARA REGRA DE VALIDAÇÃO DE CONTRATO. 
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/


@isTest
private class ContractClonagemTest {

    static testMethod void myUnitTest() 
    {
        Utils.setMigrationDoneTest(false); 
        
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario;

        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '01-01';      
        regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );      
        insert regional;   
        
        Account Acc = new Account();      
        Acc.Name = 'Teste';
        Acc.Rating = 'Cliente';
        Acc.Status__c = 'Cliente cadastrado no JDE';
        Acc.CNPJ__c = '66918405000111';
        Acc.Segmentation_Type_on_trade__c = 'Restaurante';
        acc.Rating = 'Cliente';
        Acc.Regional__c = regional.Id; 
        acc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );      
        insert Acc;
        
        LAT_Contract__c Lc = new LAT_Contract__c();        
        Lc.OwnerId = usuario.Id;        
        Lc.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo');
        Lc.Account__c = Acc.Id;        
        Lc.Status__c = 'Em Elaboração';        
        Lc.ROI_Comentarios_Negativo__c = 'Teste';        
        Lc.StartDate__c = System.today();        
        Lc.Gerente_Regional__c = Usuario.Id;
        Lc.Gerente__c = Usuario.Id;
        Lc.Gerente_de_area__c = Usuario.Id;  
        insert Lc;

        Id idRecTypeInv = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
        Investimento_Bonificacao_e_Pagamento__c inv = new Investimento_Bonificacao_e_Pagamento__c (
          Status_da_Verba__c = 'Reservado',
          Finalidade__c = 'Contrato',
          RecordTypeId = idRecTypeInv,
          LAT_Contract__c = Lc.Id,
          Data_de_Previsao_do_Pagamento__c = Date.today().addDays(5)
        );

        insert inv;
        
        ContractClonagem.executa( lc.id );
    }

    static testMethod void myUnitTestB() 
    {
        Utils.setMigrationDoneTest(true); 
        
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario;

        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '01-01';      
        regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );      
        insert regional;   
        
        Account Acc = new Account();      
        Acc.Name = 'Teste';
        Acc.Rating = 'Cliente';
        Acc.Status__c = 'Cliente cadastrado no JDE';
        Acc.CNPJ__c = '66918405000111';
        Acc.Segmentation_Type_on_trade__c = 'Restaurante';
        acc.Rating = 'Cliente';
        Acc.Regional__c = regional.Id; 
        acc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );      
        insert Acc;
        
        LAT_Contract__c Lc = new LAT_Contract__c();        
        Lc.OwnerId = usuario.Id;        
        Lc.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo');
        Lc.Account__c = Acc.Id;        
        Lc.Status__c = 'Em Elaboração';        
        Lc.ROI_Comentarios_Negativo__c = 'Teste';        
        Lc.StartDate__c = System.today();        
        Lc.Gerente_Regional__c = Usuario.Id;
        Lc.Gerente__c = Usuario.Id;
        Lc.Gerente_de_area__c = Usuario.Id;  
        insert Lc;
        
        Id idRecTypeInv = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
        Investimento_Bonificacao_e_Pagamento__c inv = new Investimento_Bonificacao_e_Pagamento__c (
          Status_da_Verba__c = 'Reservado',
          Finalidade__c = 'Contrato',
          RecordTypeId = idRecTypeInv,
          LAT_Contract__c = Lc.Id,
          Data_de_Previsao_do_Pagamento__c = Date.today().addDays(5)
        );

        insert inv;  
        ContractClonagem.executa( lc.id );
    }
}