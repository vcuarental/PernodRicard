@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz teste de cobertura da classe CasoCopiaTipoDeVerba_ParaIBPAgrupFiscal
* NAME: CasoCopiaTipoDeVerba_ParaIBPAgFiscalTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 14/09/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 09/01/2013 
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
private class CasoCopiaTipoDeVerba_ParaIBPAgFiscalTest {

    static testMethod void myUnitTest() {
        //Declaração de variáveis
        Id recTypeLatCon = [SELECT id,Name FROM RecordType WHERE SobjectType='LAT_Contract__c' AND DeveloperName = 'Alteracao_de_contrato_OFF' Limit 1].id; 
                
        Account acc = new Account(
         Name = 'Conta teste Trigger',
         CNPJ__c = '48843971000120',
         Type = 'Outros',
         Status__c = 'Cliente cadastrado no JDE',
         Agency__c = '000',
         Checking_account__c = '000',
         Current_account__c = '0',
         Corporate_Name__c = 'Teste',
         Channel_Type__c = 'Indireto',
         RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
        );

        insert acc;
        
        LAT_Contract__c lContract = new LAT_Contract__c(
         Account__c = acc.Id,
         Status__c = 'Aprovado',
         StartDate__c = System.today(),
         ContractTerm__c = 12,
         Status_do_processo__c='Estudo em elaboração', 
         RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato'),
         ROI_Comentarios_Negativo__c = 'teste'
        );

        insert lContract;
        
        Id idRecTypeInv = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
        Investimento_Bonificacao_e_Pagamento__c inv = new Investimento_Bonificacao_e_Pagamento__c (
          Status_da_Verba__c = 'Reservado',
          Finalidade__c = 'Contrato',
          RecordTypeId = idRecTypeInv,
          LAT_Contract__c = lContract.Id,
          Data_de_Previsao_do_Pagamento__c = Date.today().addDays(5)
        );
       
        Database.insert( inv );
        
        Id idRecTypeAgr = [SELECT id,Name FROM RecordType WHERE SobjectType='Agrupamento_Fiscal_Year__c' AND DeveloperName = 'BRA_Standard' Limit 1].id;
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
          RecordTypeId=idRecTypeAgr,
          LAT_Contract__c = lContract.Id,
          Ano_Fiscal__c = FiscalYearFormat( Date.today().addDays(5) )
        );
        
        Database.insert( lAgrp );
        
        Case lCaso = new Case(
          Grouping_Fiscal_Year__c = lAgrp.Id,
          AccountId = lContract.Account__c,
          LAT_Contract__c = lContract.Id,
          Purposes_Action__c  = 'Aniversário',
          Amount_Type__c = 'Off Trade - Direto',
          RecordTypeId = [SELECT id,Name FROM RecordType WHERE SobjectType='Case' AND DeveloperName = 'Inserir_o_Tipo_de_Verba' Limit 1].id,
          Status = 'Aprovado'
        );        
        insert lCaso;
    }
   
    //MIGRATED 21/11/2016
    static testMethod void myUnitTestLATCase() {
        //Declaração de variáveis
        Id recTypeLatCon = [SELECT id,Name FROM RecordType WHERE SobjectType='LAT_Contract__c' AND DeveloperName = 'Alteracao_de_contrato_OFF' Limit 1].id; 
                
        Account acc = new Account(
         Name = 'Conta teste Trigger',
         CNPJ__c = '48843971000120',
         Type = 'Outros',
         Status__c = 'Cliente cadastrado no JDE',
         Agency__c = '000',
         Checking_account__c = '000',
         Current_account__c = '0',
         Corporate_Name__c = 'Teste',
         Channel_Type__c = 'Indireto',
         RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
        );

        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true); 
        LAT_Contract__c lContract = new LAT_Contract__c(
         Account__c = acc.Id,
         Status__c = 'Aprovado',
         StartDate__c = System.today(),
         ContractTerm__c = 12,
         Status_do_processo__c='Estudo em elaboração', 
         RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato'),
         ROI_Comentarios_Negativo__c = 'teste'
        );

        insert lContract;
        
        Id idRecTypeInv = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
        Investimento_Bonificacao_e_Pagamento__c inv = new Investimento_Bonificacao_e_Pagamento__c (
          Status_da_Verba__c = 'Reservado',
          Finalidade__c = 'Contrato',
          RecordTypeId = idRecTypeInv,
          LAT_Contract__c = lContract.Id,
          Data_de_Previsao_do_Pagamento__c = Date.today().addDays(5)
        );
       
        Database.insert( inv );
        
        Id idRecTypeAgr = [SELECT id,Name FROM RecordType WHERE SobjectType='Agrupamento_Fiscal_Year__c' AND DeveloperName = 'BRA_Standard' Limit 1].id;
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
          RecordTypeId=idRecTypeAgr,
          LAT_Contract__c = lContract.Id,
          Ano_Fiscal__c = FiscalYearFormat( Date.today().addDays(5) )
        );
        
        Database.insert( lAgrp );
        
        LAT_Case__c lCaso = new LAT_Case__c(
          LAT_GroupingFiscalYear__c = lAgrp.Id,
          LAT_Account__c = lContract.Account__c,
          LAT_Contract__c = lContract.Id,
          LAT_PurposesAction__c  = 'Aniversário',
          LAT_AmountType__c = 'Off Trade - Direto',
          RecordTypeId = [SELECT id,Name FROM RecordType WHERE SobjectType='LAT_Case__c' AND DeveloperName = 'Inserir_o_Tipo_de_Verba' Limit 1].id,
          LAT_Status__c = 'Aprovado'
        );        
        insert lCaso;
        Test.stopTest();
    }
    
    public static string FiscalYearFormat ( Date inputDate ) {
      Integer anoYY = Integer.valueOf( String.valueOf ( inputDate.year() ).right(2) );
      String dataFinal = 'FY';
      
      if ( inputDate.month() >= 7 && inputDate.month() <= 12 ){
        dataFinal += String.valueOf( anoYY +1 );
        dataFinal += ': jul/';
        dataFinal += String.valueOf( anoYY );
        dataFinal += ' - jun/';
        dataFinal += String.valueOf( anoYY + 1 );
      } else {
        dataFinal += String.valueOf( anoYY );
        dataFinal += ': jul/';
        dataFinal += String.valueOf( anoYY -1 );
        dataFinal += ' - jun/';
        dataFinal += String.valueOf( anoYY );
      } 
      
      return dataFinal;
    }
}