/*************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck  Date:02/09/2013    *
**************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016  
*
********************************************************************************/

@istest
public with sharing class NovaDemandaAlteracaoDATest {

    static testMethod void unitTest() {
        
        String rtContrato = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato');
        String rtAgrup = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        
        UDC__c regional = new UDC__c(      
            CodDefUsuario__c = '1',    
            CodProd__c     = '01',     
            CodUs__c     = '01',    
            Internal_Id__c   = '01-01',      
            RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard')     
        );
        
        insert regional;  
              
        Account acc = new Account(    
            Name = 'Teste',
            Rating = 'Cliente',
            Status__c = 'Cliente cadastrado no JDE',
            CNPJ__c = '48843971000120',
            Regional__c = regional.Id, 
            Segmentation_Type_on_trade__c = 'Restaurante',
            RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade')
        );  
          
        Test.startTest();
        insert acc;
        Test.stopTest();
          
        LAT_Contract__c contrato = new LAT_Contract__c(        
            RecordTypeId = rtContrato,
            Account__c = acc.Id,  
            Status__c = 'Em Elaboração',   
            ROI_Comentarios_Negativo__c = 'Teste',    
            StartDate__c = System.today()
        );
        insert contrato;

        
        
        
        Agrupamento_Fiscal_Year__c agrup = new Agrupamento_Fiscal_Year__c( 
            RecordTypeId = rtAgrup,
            LAT_Contract__c = contrato.id,
            Numero_da_D_A__c = 200,
            valor_total__c = 1000
        );
      
        Integer StartMonth = [SELECT FiscalYearStartMonth FROM Organization WHERE id =:Userinfo.getOrganizationId()].FiscalYearStartMonth;
        
        integer AnoFiscal = system.today().year();
        
        if (system.today().month() >= StartMonth){
            AnoFiscal++;
        }
        
        agrup.Ano_fiscal_calculadoag__c = String.valueOf(AnoFiscal);
      
        insert agrup;   
        
        list<Profile> perfiles = [SELECT Id, Name FROM Profile WHERE Name = 'Vendas' LIMIT 1]; 
        
        User usuario;
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', FirstName='FERNANDO',LastName='VALDUJO', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = perfiles[0].Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         insert u2;
            
        try {
            usuario = [SELECT Id, Name, ProfileId FROM User WHERE ProfileId IN: perfiles AND IsActive = true LIMIT 1];
        } catch(Exception e){ }
        
        if(usuario!=null){
            system.runAs(usuario){       
        
                NovaDemandaAlteracaoDA.NovaDemanda(contrato.id);
            }
        }
        
   }
   
    static testMethod void unitTestB() {
        Utils.setMigrationDoneTest(true);   
        String rtContrato = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato');
        String rtAgrup = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        
        UDC__c regional = new UDC__c(      
            CodDefUsuario__c = '1',    
            CodProd__c     = '01',     
            CodUs__c     = '01',    
            Internal_Id__c   = '01-01',      
            RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard')     
        );
        
        insert regional;  
              
        Account acc = new Account(    
            Name = 'Teste',
            Rating = 'Cliente',
            Status__c = 'Cliente cadastrado no JDE',
            CNPJ__c = '48843971000120',
            Regional__c = regional.Id, 
            Segmentation_Type_on_trade__c = 'Restaurante',
            RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade')
        );  
          
        Test.startTest();
        Utils.setMigrationDoneTest(true);   
        insert acc;
        Test.stopTest();
        Utils.setMigrationDoneTest(true);     
        LAT_Contract__c contrato = new LAT_Contract__c(        
            RecordTypeId = rtContrato,
            Account__c = acc.Id,  
            Status__c = 'Em Elaboração',   
            ROI_Comentarios_Negativo__c = 'Teste',    
            StartDate__c = System.today()
        );
        insert contrato;

        
        
        
        Agrupamento_Fiscal_Year__c agrup = new Agrupamento_Fiscal_Year__c( 
            RecordTypeId = rtAgrup,
            LAT_Contract__c = contrato.id,
            Numero_da_D_A__c = 200,
            valor_total__c = 1000
        );
      
        Integer StartMonth = [SELECT FiscalYearStartMonth FROM Organization WHERE id =:Userinfo.getOrganizationId()].FiscalYearStartMonth;
        
        integer AnoFiscal = system.today().year();
        
        if (system.today().month() >= StartMonth){
            AnoFiscal++;
        }
        
        agrup.Ano_fiscal_calculadoag__c = String.valueOf(AnoFiscal);
      
        insert agrup;   
         User admin = [SELECT Id FROM user WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true limit 1];                  
        User usuario; 
       // System.runAs(admin){
        
        list<Profile> perfiles = [SELECT Id, Name FROM Profile WHERE Name = 'LAT_BR2_Vendas' LIMIT 1]; 
        list<Profile> perfiles2 = [SELECT Id, Name FROM Profile WHERE Name = 'LAT_BusinessAdministrator' LIMIT 1]; 
        //User usuario;
        Id profId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');


         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', FirstName='FERNANDO',LastName='VALDUJO', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = perfiles2[0].Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
            //u2.ProfileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator');
         insert u2;
         usuario = new User(Alias = 'newUser2', Email='newuser@testorg2.com', 
         EmailEncodingKey='UTF-8', FirstName='FERNANDO2',LastName='VALDUJO2', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = perfiles[0].Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='Case2AR@mail.com');
         insert usuario;
        //}
        //try {
         //   usuario = [SELECT Id, Name, ProfileId FROM User WHERE ProfileId IN: perfiles AND IsActive = true LIMIT 1];
        //} catch(Exception e){ }
        
        if(usuario!=null){
            system.runAs(usuario){       
        
                NovaDemandaAlteracaoDA.NovaDemanda(contrato.id);
            }
        }
        
   }
}