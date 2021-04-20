@isTest(seeAllData=true)
private class CotasRegionaisConsultaTest {

  static testMethod void myUnitTest() {
    Utils.setMigrationDoneTest(false);
    Id idRecTypeProd = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
    Id idRecTypeOpp = RecordTypeForTest.getRecType( 'Opportunity' , 'Nova_oportunidade' );
    Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
    Id idRecTypeCritR = RecordTypeForTest.getRecType('Criterio_de_cota_regional__c', 'BRA_Standard');

    //Cria Regional
    UDC__c regional = new UDC__c(
      CodDefUsuario__c = '2',
      CodProd__c     = '01',
      CodUs__c     = '01',
      Internal_Id__c   = '1234',
      RecordTypeId = idRecTypeUdc
    );
    insert regional;
    
    //Cria novo Account. 
    Account acc = new Account(
      Name = 'Conta teste Trigger',
      CNPJ__c = '48843971000120',
      Type = 'Outros',
      Status__c = 'Cliente cadastrado no JDE',
      Agency__c = '000',
      Checking_account__c = '000',
      Current_account__c = '0',
      Corporate_Name__c = 'Teste',
      //Regional__c = regional.id,
      Channel_Type__c = 'Indireto',
      Price_Group__c = 'x',
      Client_code_AN8__c = '123456',
      RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
    );
    insert acc;   
   
    Product2 produto = new Product2(
      Name = 'Cloud2b - Produto',
      IsActive = true,
      CD_Unit__c = 'UN',
      Internal_id__c = '123',
      //QT_lead_time__c = 5,
      sku__c = 'x', 
      RecordTypeId = idRecTypeProd
    );
    insert produto;
  
    List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1];
  
    PricebookEntry entradaCatalogoPreco = new PricebookEntry(
      Pricebook2Id = catalogoPreco[0].Id,  
      Product2Id = produto.Id,
      UnitPrice = 1000.00,
      IsActive = true,
      UseStandardPrice = false
    );
    insert entradaCatalogoPreco;
   
    Opportunity oportunidade = new Opportunity(
      Name = 'Cloud2b - Oportunidade',
      AccountId = acc.Id,
      CloseDate = Date.today()+1,
      StageName = 'Novo pedido',
      RecordTypeId = idRecTypeOpp
    );
    insert oportunidade;
      
    OpportunityLineItem produtosOportunidade = new OpportunityLineItem(
      OpportunityId = oportunidade.Id,
      PricebookEntryId = entradaCatalogoPreco.Id,
      Quantity = 1,
      UnitPrice = 1000.00
    );
    insert produtosOportunidade;
      
      
      
    List< OpportunityLineItem > listOli = [Select Id, PricebookEntry.Product2.Sku__c From OpportunityLineItem limit 1];
    SKU__c lProd = new SKU__c();
    lProd.Name = produto.Id;
    lProd.Nome_do_produto__c = produto.Name;
    lProd.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c', 'BRA_Standard' );
    insert lProd; 
    
    List< String > lSku = new List< String >();
    
    for( OpportunityLineItem oli : listOli ){
      lSku.add( oli.PricebookEntry.Product2.Sku__c );
    }

//Cria nova UDC.
      UDC__c regional2 = new UDC__c();
      regional2.CodDefUsuario__c = '4546';
      regional2.CodProd__c     = '01';
      regional2.CodUs__c     = '01';
      regional2.Internal_Id__c   = '1233';
      regional2.RecordTypeId = idRecTypeUDC;
      insert regional2;
      
      //Cria nova UDC.
      UDC__c bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '1236';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      

    //Cria novo sku.
      SKU__c sku = new SKU__c();
      sku.Name = produto.Sku__c ;
      sku.Nome_do_produto__c = 'TESTE';
      sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
      insert sku;
      
      //Cria novo critério nacional.
      Criterio_nacional_de_cota__c critN = new Criterio_nacional_de_cota__c();
      critN.SKU__c = sku.Id;
      critN.Cota__c = 500;
      critN.Canal__c = true;
      critN.Bandeira__c = true;
      critN.Regional__c = true;
      critN.Subcanal__c = true;
      critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard');
      insert critN;
      
      //Cria nova cota nacional.
      Cota_nacional__c cotaN = new Cota_nacional__c();
      cotaN.Cota__c = 100;
      cotaN.Canal__c = 'On Trade';
      cotaN.Sub_canal__c = 'Atacadista';
      cotaN.Regional__c = regional.Id;
      cotaN.Bandeira__c = bandeira.Id;
      cotaN.Criterio_nacional_de_cota__c = critN.Id;
      cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
      insert cotaN;
      
      Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
      Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
      
      List< Criterio_de_cota_regional__c > lCritList = [ SELECT id , SKU__c
                                          FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                          AND RecordTypeId =: idRecTypeCCR limit 1 ];
      
      lCritList[0].Cliente__c = true;
      update lCritList[0];
      system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%' + lCritList[0].SKU__c);      
      Cota_regional__c cotaR = new Cota_regional__c();
      cotaR.Cliente__c = acc.id;
      cotaR.Cota__c = 80;
      cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
      COTAr.RecordTypeId = idRecTypeCr;
      insert cotaR;

      String idSku = String.valueOf(sku.name) ;
    lSku.add(idSku);
    CotasRegionaisConsulta cotasR = new CotasRegionaisConsulta( lSku );
    CotasRegionaisConsulta.getPriceEntryXSKU( listOli );
    
    Cota_regional__c cota = cotasR.getCota( produto.SKU__c, oportunidade);
  }

  static testMethod void myUnitTest2() {
    Utils.setMigrationDoneTest(true);
    Id idRecTypeProd = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
    Id idRecTypeOpp = RecordTypeForTest.getRecType( 'LAT_Opportunity__c' , 'Nova_oportunidade' );
    Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
    Id idRecTypeCritR = RecordTypeForTest.getRecType('Criterio_de_cota_regional__c', 'BRA_Standard');

    //Cria Regional
    UDC__c regional = new UDC__c(
      CodDefUsuario__c = '2',
      CodProd__c     = '01',
      CodUs__c     = '01',
      Internal_Id__c   = '1234',
      RecordTypeId = idRecTypeUdc
    );
    insert regional;
    
    //Cria novo Account. 
    Account acc = new Account(
      Name = 'Conta teste Trigger',
      CNPJ__c = '48843971000120',
      Type = 'Outros',
      Status__c = 'Cliente cadastrado no JDE',
      Agency__c = '000',
      Checking_account__c = '000',
      Current_account__c = '0',
      Corporate_Name__c = 'Teste',
      //Regional__c = regional.id,
      Channel_Type__c = 'Indireto',
      Price_Group__c = 'x',
      Client_code_AN8__c = '123456',
      RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
    );
    insert acc;   
   
    LAT_Product__c produto = new LAT_Product__c(
      Name = 'Cloud2b - LAT Produto',
      LAT_IsActive__c = true,
      LAT_CDUnit__c = 'UN',
      LAT_ExternalID__c = '123',
      //QT_lead_time__c = 5,
      LAT_Sku__c = 'x', 
      RecordTypeId = idRecTypeProd
    );
    insert produto;
  
    
   
    LAT_Opportunity__c oportunidade = new LAT_Opportunity__c(
      Name = 'Cloud2b - LAT_Oportunidade',
      LAT_Account__c = acc.Id,
      LAT_CloseDate__c = Date.today()+1,
      LAT_StageName__c = 'Novo pedido',
      RecordTypeId = idRecTypeOpp
    );
    insert oportunidade;
      
    LAT_OpportunityLineItem__c produtosOportunidade = new LAT_OpportunityLineItem__c(
      LAT_Opportunity__c = oportunidade.Id,
      LAT_Product__c = produto.Id,
      LAT_Quantity__c = 1,
      LAT_UnitPrice__c = 1000.00
    );
    insert produtosOportunidade;
      
      
      
    List< LAT_OpportunityLineItem__c > listOli = [Select Id, LAT_Product__r.LAT_Sku__c From LAT_OpportunityLineItem__c limit 1];
    
    List< String > lSku = new List< String >();
    
    for( LAT_OpportunityLineItem__c oli : listOli ){
      lSku.add( oli.LAT_Product__r.LAT_Sku__c );
    }

      //Cria nova UDC.
      UDC__c regional2 = new UDC__c();
      regional2.CodDefUsuario__c = '4546';
      regional2.CodProd__c     = '01';
      regional2.CodUs__c     = '01';
      regional2.Internal_Id__c   = '1233';
      regional2.RecordTypeId = idRecTypeUDC;
      insert regional2;
      
      //Cria nova UDC.
      UDC__c bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '1236';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      

    //Cria novo sku.
      SKU__c sku = new SKU__c();
      sku.Name = produto.LAT_Sku__c ;
      sku.Nome_do_produto__c = 'TESTE';
      sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
      insert sku;
      
      //Cria novo critério nacional.
      Criterio_nacional_de_cota__c critN = new Criterio_nacional_de_cota__c();
      critN.SKU__c = sku.Id;
      critN.Cota__c = 500;
      critN.Canal__c = true;
      critN.Bandeira__c = true;
      critN.Regional__c = true;
      critN.Subcanal__c = true;
      critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard');
      insert critN;
      
      //Cria nova cota nacional.
      Cota_nacional__c cotaN = new Cota_nacional__c();
      cotaN.Cota__c = 100;
      cotaN.Canal__c = 'On Trade';
      cotaN.Sub_canal__c = 'Atacadista';
      cotaN.Regional__c = regional.Id;
      cotaN.Bandeira__c = bandeira.Id;
      cotaN.Criterio_nacional_de_cota__c = critN.Id;
      cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
      insert cotaN;
      
      Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
      Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
      
      List< Criterio_de_cota_regional__c > lCritList = [ SELECT id , SKU__c
                                          FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                          AND RecordTypeId =: idRecTypeCCR limit 1 ];
      
      lCritList[0].Cliente__c = true;
      update lCritList[0];
      system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%' + lCritList[0].SKU__c);      
      Cota_regional__c cotaR = new Cota_regional__c();
      cotaR.Cliente__c = acc.id;
      cotaR.Cota__c = 80;
      cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
      COTAr.RecordTypeId = idRecTypeCr;
      insert cotaR;

    String idSku = String.valueOf(sku.name) ;
    lSku.add(idSku);
    CotasRegionaisConsulta cotasR = new CotasRegionaisConsulta( lSku );
    CotasRegionaisConsulta.getPriceEntryXSKU( listOli );
    //Cota_regional__c cota1 =cotasR.getCota( crit, oportunidade, produto.LAT_Sku__c, 'test' );
    
    Cota_regional__c cota = cotasR.getCota( produto.LAT_Sku__c, oportunidade);
  }
}