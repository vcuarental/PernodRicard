@istest(seeAllDAta=true)
/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 16/11/2016
*
********************************************************************************/

public with sharing class VFC12_CreditLimitFrameExtension_AR_TEST {

  static testMethod void unitTest() {
      
      Utils.setMigrationDoneTest(false);
 

      Id idAccount = Global_RecordTypeCache.getRtId('AccountOff_Trade');

       User usuario = [SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' Limit 1];
       //usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
       //insert usuario;

      Account acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      //acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      //acc.Customer_Flag__c = bandeira.Id;
      acc.Carriers_Numbers__c = '123';
      //acc.Business_Unit__c = deposito.Id;
      acc.Credit_line__c = 100;
      
      insert acc;
      Product2 produto = new Product2();
      produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
      produto.IsActive = true;
      produto.CD_Unit__c = 'UN';
      produto.Internal_id__c = '123';
      //produto.QT_lead_time__c = 5;
      produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
      //insert produto;
      try{insert produto;}catch(Exception e){}

     

      Opportunity opp = new Opportunity();
      opp.Name = 'Opp TESTE COTA';
      opp.closeDate = System.today()+1;
      opp.AccountId = acc.Id;
      opp.StageName = 'Novo Pedido';
      opp.RecordTypeId = Global_RecordTypeCache.getRtId('OpportunityOPP_1_NewOrder_ARG');
      insert opp;
      List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];
            
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            //insert entradaCatalogoPreco;
            try{insert entradaCatalogoPreco;}catch(Exception e){}

      OpportunityLineItem lItem = new OpportunityLineItem();
      lItem.OpportunityId = opp.Id;
      lItem.PricebookEntryId = entradaCatalogoPreco.Id;
      lItem.Quantity = 1;
      lItem.UnitPrice = 1000.00;
      lItem.cd_line_status__c = '400';
      //insert lItem;
      try{insert lItem;}catch(Exception e){}
        
      Id tituloRecordTypeTest = Global_RecordTypeCache.getRtId( 'Titulos__cStandard_AR' );
        
      ApexPages.Standardcontroller oppController = new ApexPages.Standardcontroller(opp);
      VFC12_CreditLimitFrameExtension_AR t = new VFC12_CreditLimitFrameExtension_AR(oppController);
      t.calculateCreditLimit();
    }
    
  static testMethod void unitTest2() {
      
      Utils.setMigrationDoneTest(true);
    

      Id idAccount = Global_RecordTypeCache.getRtId('AccountOff_Trade');
      User usuario = [SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' Limit 1];
      
      Account acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      //acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      //acc.Customer_Flag__c = bandeira.Id;
      acc.Carriers_Numbers__c = '123';
      //acc.Business_Unit__c = deposito.Id;
      acc.Credit_line__c = 100;
      
      insert acc;

      Test.startTest();
      
      LAT_Product__c produto = new LAT_Product__c();
      produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
      produto.LAT_IsActive__c = true;
      produto.LAT_CDUnit__c = 'UN';
      produto.LAT_ExternalId__c = '123';
      //produto.QT_lead_time__c = 5;
      produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
      //insert produto;
      try{insert produto;}catch(Exception e){}


      
      LAT_Opportunity__c opp = new LAT_Opportunity__c();
      opp.Name = 'Opp TESTE COTA';
      opp.LAT_CloseDate__c = System.today()+1;
      opp.LAT_Account__c = acc.Id;
      opp.LAT_StageName__c = 'Novo Pedido';
      opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__cOPP_1_NewOrder_ARG');
      insert opp;
        
      LAT_OpportunityLineItem__c lItem = new LAT_OpportunityLineItem__c();
      lItem.LAT_Opportunity__c = opp.Id;
      lItem.LAT_Product__c = produto.Id;
      lItem.LAT_Quantity__c = 1;
      lItem.LAT_UnitPrice__c = 1000.00;
      lItem.LAT_CdLineStatus__c = '400';
      //insert lItem;
      try{insert lItem;}catch(Exception e){}
      Id tituloRecordTypeTest = Global_RecordTypeCache.getRtId( 'Titulos__cStandard_AR' );
        
      ApexPages.Standardcontroller oppController = new ApexPages.Standardcontroller(opp);
      VFC12_CreditLimitFrameExtension_AR t = new VFC12_CreditLimitFrameExtension_AR(oppController);
      t.calculateCreditLimit();
      Test.stopTest();
    }
}