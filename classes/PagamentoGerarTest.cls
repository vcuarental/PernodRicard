/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe PagamentoGerar
* NAME: PagamentoGerarTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 30/10/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                               DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

@isTest(seeAllData=true)
private class PagamentoGerarTest {

    static testMethod void myUnitTest() 
    {
        Utils.setMigrationDoneTest(false); 
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
        Account lAcc = new Account(
          Name='Conta teste',
          RecordTypeId=idRecTypeAcc,
          Rating='Cliente',
          Status__c='Cliente cadastrado no JDE',
          CNPJ__c='22055368000190' );
          
        Database.insert( lAcc );

        Id idRecTypeProd = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        Product2 produto = new Product2(
          Name = 'Cloud2b - Produto',
          IsActive = true,
          CD_Unit__c = 'UN',
          Internal_id__c = '123',
          //QT_lead_time__c = 5,
          RecordTypeId = idRecTypeProd
        );
        insert produto;


        Id idRecTypeInv = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos');
        Investimento_Bonificacao_e_Pagamento__c inv = new Investimento_Bonificacao_e_Pagamento__c (
          Status_da_Verba__c = 'Reservado',
          Finalidade__c = 'Contrato',
          RecordTypeId = idRecTypeInv,
          Produto_Bonificado__c = produto.id,
          Data_de_Previsao_do_Pagamento__c = Date.today().addDays(5)
        );
        Database.insert( inv );

              
        List< Id > lListIBP = new List< Id >();
        
        List< Investimento_Bonificacao_e_Pagamento__c > lList = new List< Investimento_Bonificacao_e_Pagamento__c > ();
        lList.add( inv );
        
        for( Investimento_Bonificacao_e_Pagamento__c ibp : lList ){
            lListIBP.add( ibp.Id );
        }
        
        PagamentoGerar.gerar( lListIBP, lAcc.id );
    }
    //MIGRATED 21/11/2016
    static testMethod void myUnitTestB() 
    {
        Utils.setMigrationDoneTest(true); 
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
        Account lAcc = new Account(
          Name='Conta teste',
          RecordTypeId=idRecTypeAcc,
          Rating='Cliente',
          Status__c='Cliente cadastrado no JDE',
          CNPJ__c='22055368000190' );
          
        Database.insert( lAcc );

        Id idRecTypeProd = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        LAT_Product__c produto = new LAT_Product__c(
          Name = 'Cloud2b - Produto',
          LAT_IsActive__c = true,
          LAT_CDUnit__c = 'UN',
          LAT_ExternalId__c = '123',
          //QT_lead_time__c = 5,
          RecordTypeId = idRecTypeProd
        );
        insert produto;


        Id idRecTypeInv = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos');
        Investimento_Bonificacao_e_Pagamento__c inv = new Investimento_Bonificacao_e_Pagamento__c (
          Status_da_Verba__c = 'Reservado',
          Finalidade__c = 'Contrato',
          RecordTypeId = idRecTypeInv,
          LAT_Product__c = produto.id,
          Data_de_Previsao_do_Pagamento__c = Date.today().addDays(5)
        );
        Database.insert( inv );

              
        List< Id > lListIBP = new List< Id >();
        
        List< Investimento_Bonificacao_e_Pagamento__c > lList = new List< Investimento_Bonificacao_e_Pagamento__c > ();
        lList.add( inv );
        
        for( Investimento_Bonificacao_e_Pagamento__c ibp : lList ){
            lListIBP.add( ibp.Id );
        }
        
        PagamentoGerar.gerar( lListIBP, lAcc.id );
    }
}