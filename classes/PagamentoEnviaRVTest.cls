/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura na classe PagamentoEnviaRV
* NAME: PagamentoEnviaRVTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 09/11/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 15/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 19/11/2016
*
********************************************************************************/
@isTest
private class PagamentoEnviaRVTest {
 
  static testMethod void myUnitTest() 
  {
        Utils.setMigrationDoneTest(false); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        Account acc = new Account();
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        try{insert acc;}catch(Exception e){}
          
        LAT_Contract__c lContract = new LAT_Contract__c();
        lContract.Account__c = acc.Id;
        lContract.Status__c = 'Em elaboração';
        lContract.StartDate__c = System.today();
        lContract.ContractTerm__c = 12;
        lContract.RecordTypeId = idrecTypeLatCon;
        lContract.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContract;
        try{insert lContract;}catch(Exception e){}
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = lContract.id;
        ibp.Valor_R__c = 100;
        ibp.Status_da_Verba__c = 'Reservado';
        //insert ibp;
        // try{insert ibp;}catch(Exception e){}
        
        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        //insert lPagto;
        try{insert lPagto;}catch(Exception e){}
      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        //insert lPagtoVerba;
        try{insert lPagtoVerba;}catch(Exception e){}
        
        try{ 
           PagamentoEnviaRV.RVManagerInterfaceInvoke( lPagto.id );
        }catch(Exception e ){
            System.debug(e.getMessage());
        }
  }

  static testMethod void myUnitTestB() 
  {
        Utils.setMigrationDoneTest(true); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        insert regional;

        Account acc = new Account();
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
       insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true); 

        LAT_Contract__c lContract = new LAT_Contract__c();
        lContract.Account__c = acc.Id;
        lContract.Status__c = 'Em elaboração';
        lContract.StartDate__c = System.today();
        lContract.ContractTerm__c = 12;
        lContract.RecordTypeId = idrecTypeLatCon;
        lContract.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContract;
        insert lContract;
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = lContract.id;
        ibp.Valor_R__c = 100;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Numero_da_DA__c = '120'; 
        //insert ibp;
        try{insert ibp;}catch(Exception e){}
        
        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        //insert lPagto;
        insert lPagto;
      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        //insert lPagtoVerba;
       insert lPagtoVerba;
        
        try{ 
           PagamentoEnviaRV.RVManagerInterfaceInvoke( lPagto.id );

           delete lPagtoVerba;

           PagamentoEnviaRV.RVManagerInterfaceInvoke( lPagto.id );

        }catch(Exception e ){
            System.debug(e.getMessage());
        }
        Test.stopTest();
  }  
}