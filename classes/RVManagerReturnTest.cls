/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe RVManagerReturn
* NAME: RVManagerReturnTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 24/08/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 19/11/2016
*
********************************************************************************/
@isTest
private class RVManagerReturnTest {

    static testMethod void myUnitTest() 
    {
      Utils.setMigrationDoneTest(false); 
    	Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
    	
      //Cria nova UDC.
      UDC__c regional = new UDC__c();
      regional.CodDefUsuario__c = '2';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUDC;
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
      acc.Regional__c = regional.id;
      acc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );
      insert acc;
        
      LAT_Contract__c lContract = new LAT_Contract__c();
      lContract.Account__c = acc.Id;
      lContract.Status__c = 'Em elaboração';
      lContract.StartDate__c = System.today();
      lContract.ContractTerm__c = 12;
      lContract.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato' );
      
      insert lContract;
      
      Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
      ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
      ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
      ibp.Finalidade__c = 'Contrato';
      ibp.LAT_Contract__c = lContract.id;
      ibp.Valor_R__c = 100;
      insert ibp;
      
      RVManagerReturn.RVReturn( ibp.id, '0', '', 100.00, 0.00, 123, 321 );
    }

    static testMethod void myUnitTestB() 
    {
      Utils.setMigrationDoneTest(true); 
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
      
      //Cria nova UDC.
      UDC__c regional = new UDC__c();
      regional.CodDefUsuario__c = '2';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUDC;
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
      acc.Regional__c = regional.id;
      acc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );
      insert acc;
        
      LAT_Contract__c lContract = new LAT_Contract__c();
      lContract.Account__c = acc.Id;
      lContract.Status__c = 'Em elaboração';
      lContract.StartDate__c = System.today();
      lContract.ContractTerm__c = 12;
      lContract.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato' );
      
      insert lContract;
      
      Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
      ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
      ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
      ibp.Finalidade__c = 'Contrato';
      ibp.LAT_Contract__c = lContract.id;
      ibp.Valor_R__c = 100;
      insert ibp;
      
      RVManagerReturn.RVReturn( ibp.id, '0', '', 100.00, 0.00, 123, 321 );
    }

}