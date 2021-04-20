/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz teste de cobertura da classe CasoCopiaDA_ParaAgrupamentoFiscal
* NAME: CasoCopiaDA_ParaAgrupamentoFiscalTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 14/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 22/10/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

@isTest
private class CasoCopiaDA_ParaAgrupamentoFiscalTest {

    static testMethod void myUnitTest() {

      
      Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( RecordTypeId=[SELECT id,Name FROM RecordType WHERE SobjectType='Agrupamento_Fiscal_Year__c' AND DeveloperName = 'BRA_Standard' Limit 1].id );
      insert lAgrp;
        
      Case lCaso = new Case();
      lCaso.Grouping_Fiscal_Year__c = lAgrp.id;
      lCaso.DA_Number__c = 1;
      lCaso.WF_Type__c = '';
      lCaso.RecordTypeId = [SELECT id,Name FROM RecordType WHERE SobjectType='Case' AND DeveloperName = 'Gerar_D_A_no_sistema_ME' Limit 1].id;
      lCaso.Status = 'Fechado e Resolvido';
      lCaso.Integration_Status__c = 'Reservado';
      lCaso.Inquiry_held__c = true;
      insert lCaso;
      
    }
    //MIGRATED 21/11/2016
    static testMethod void myUnitTestLATCase() {

      
      Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( RecordTypeId=[SELECT id,Name FROM RecordType WHERE SobjectType='Agrupamento_Fiscal_Year__c' AND DeveloperName = 'BRA_Standard' Limit 1].id );
      insert lAgrp;
        
      LAT_Case__c lCaso = new LAT_Case__c();
      lCaso.LAT_GroupingFiscalYear__c = lAgrp.id;
      lCaso.LAT_DANumber__c = 1;
      lCaso.LAT_WFType__c = '';
      lCaso.RecordTypeId = [SELECT id,Name FROM RecordType WHERE SobjectType='LAT_Case__c' AND DeveloperName = 'Gerar_D_A_no_sistema_ME' Limit 1].id;
      lCaso.LAT_Status__c = 'Fechado e Resolvido';
      lCaso.LAT_IntegrationStatus__c = 'Reservado';
      lCaso.LAT_Inquiryheld__c = true;
      insert lCaso;
      
    }
}