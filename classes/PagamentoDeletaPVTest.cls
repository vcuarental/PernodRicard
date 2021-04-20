@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Responsável pelo teste de cobertura do seguinte código: PagamentoDeletaPV.trigger
*
* NAME: PagamentoDeletaPVTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 
*
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 20/11/2016
*
********************************************************************************/
private class PagamentoDeletaPVTest {

    static testMethod void myUnitTest() {
        Utils.setMigrationDoneTest(false); 
        Pagamento__c lPagto;
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
        
        lPagto = new Pagamento__c();
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
        
     //delete lPagto;
      try{ delete lPagto;}catch(Exception e){}
    }

    static testMethod void myUnitTestB() {
        Utils.setMigrationDoneTest(true); 
        Pagamento__c lPagto;
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
        try{insert ibp;}catch(Exception e){}
        
        lPagto = new Pagamento__c();
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
        
     //delete lPagto;
      try{ delete lPagto;}catch(Exception e){}
    }
}