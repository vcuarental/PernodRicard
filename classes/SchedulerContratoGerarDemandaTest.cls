@isTest(seeAllData=true)
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe SchedulerContratoGerarDemandaTest
* NAME: SchedulerContratoGerarDemandaTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 02/10/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 05/10/2012
*******************************************************************************/
private class SchedulerContratoGerarDemandaTest {

    static testMethod void myUnitTest() 
    {     

    	Account Acc = new Account();      
          Acc.Name = 'Teste';
          Acc.Rating = 'Cliente';
          Acc.Status__c = 'Cliente cadastrado no JDE';
          Acc.CNPJ__c = '48843971000120';
          Acc.Segmentation_Type_on_trade__c = 'Restaurante';
          acc.Rating = 'Cliente';
            
          
          insert Acc; 

          LAT_Contract__c Lc = new LAT_Contract__c();        
          Lc.OwnerId = UserInfo.getUserId();       
          Lc.RecordTypeId = [select id,Name from RecordType where SobjectType='LAT_Contract__c' and Name='Assinatura de contrato - Off Trade ativo' Limit 1].id;
          Lc.Account__c = Acc.Id;        
          //Lc.Status__c = 'Em Elaboração';        
          Lc.ROI_Comentarios_Negativo__c = 'Teste';        
          Lc.StartDate__c = System.today();        
          Lc.Gerente_Regional__c = UserInfo.getUserId();    
          Lc.Gerente__c =UserInfo.getUserId();    
          Lc.Gerente_de_area__c = UserInfo.getUserId();    
          Lc.Status__c = 'Ativo';

          insert Lc;
    
    	Test.startTest();
		Integer lStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;

    	integer lAnoFiscal = system.today().year();
    		  if ( system.today().month() >= lStartMonth ) lAnoFiscal++;

    	 Id idRecTypeAgr = [SELECT id,Name FROM RecordType WHERE SobjectType='Agrupamento_Fiscal_Year__c' AND DeveloperName = 'BRA_Standard' Limit 1].id;
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
          RecordTypeId=idRecTypeAgr,
          LAT_Contract__c = Lc.Id,
          Ano_Fiscal__c = FiscalYearFormat( Date.today().addDays(5) ),
          Ano_fiscal_calculadoag__c = String.valueOf(lAnoFiscal)
        );
        
        insert lAgrp;
    	Utils.setMigrationDoneTest(false);   
    	
    	System.schedule('SchedulerContratoGerarDemandaTest', SchedulerContratoGerarDemanda.CRON_EXP, new SchedulerContratoGerarDemanda());
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
    static testMethod void myUnitTestB() 
    { 
        	Account Acc = new Account();      
          Acc.Name = 'Teste';
          Acc.Rating = 'Cliente';
          Acc.Status__c = 'Cliente cadastrado no JDE';
          Acc.CNPJ__c = '48843971000120';
          Acc.Segmentation_Type_on_trade__c = 'Restaurante';
          acc.Rating = 'Cliente';
            
          
          insert Acc; 

          LAT_Contract__c Lc = new LAT_Contract__c();        
          Lc.OwnerId = UserInfo.getUserId();       
          Lc.RecordTypeId = [select id,Name from RecordType where SobjectType='LAT_Contract__c' and Name='Assinatura de contrato - Off Trade ativo' Limit 1].id;
          Lc.Account__c = Acc.Id;        
          //Lc.Status__c = 'Em Elaboração';        
          Lc.ROI_Comentarios_Negativo__c = 'Teste';        
          Lc.StartDate__c = System.today();        
          Lc.Gerente_Regional__c = UserInfo.getUserId();    
          Lc.Gerente__c =UserInfo.getUserId();    
          Lc.Gerente_de_area__c = UserInfo.getUserId();    
          Lc.Status__c = 'Ativo';

          insert Lc;
    	Test.startTest();

    	Id idRecTypeAgr = [SELECT id,Name FROM RecordType WHERE SobjectType='Agrupamento_Fiscal_Year__c' AND DeveloperName = 'BRA_Standard' Limit 1].id;
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
          RecordTypeId=idRecTypeAgr,
          LAT_Contract__c = Lc.Id,
          Ano_Fiscal__c = FiscalYearFormat( Date.today().addDays(5) )
        );
        
        insert lAgrp;
    	Utils.setMigrationDoneTest(true);   
    	System.schedule('SchedulerContratoGerarDemandaTest', SchedulerContratoGerarDemanda.CRON_EXP, new SchedulerContratoGerarDemanda());
    	Test.stopTest(); 
    
    }

}