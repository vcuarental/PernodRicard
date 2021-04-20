@istest(seeAllDAta=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do controlador opportunityProductEntry.cls
* NAME: opportunityProductEntryTests.CLS
* AUTHOR:                                                DATE: 
*
* MAINTENANCE: ESTRUTURADO CÓDIGO DA CLASSE DE TESTE E 100% COBERTO O CÓDIGO
* opportunityProductEntry. 
* AUTHOR: CARLOS CARVALHO                                DATE: 05/06/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 11/01/2013 
********************************************************************************/
private class OpportunityProductEntryExtensionTest {
	/*
    static testMethod void OpportunityProductEntryExtensionTest(){
     //Declaração de variáveis.
     Account acc                                   = null;
     UDC__c regional, bandeira, cidade, deposito   = null;
     Profile perfil                       = null;
     Opportunity opp                      = null;
     OpportunityLineItem oli,oli3         = null;
     User usuario                         = null;
     Product2 produto                     = null;
     Pricebook2 pricebook, standardPB     = null;
     PricebookEntry pbe, pbe2             = null;
     List<RecordType> listRecType         = null;
     List<String> developerName           = null;
     Map<String, String> mapRecType       = null;
     String idAccount                     = null;
     String idOpportunity                 = null; 
     Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
     
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
      
      //Recupera o ID do perfil desejado.
      String[] profileNames = LAT_GeneralConfigDao.getValueAsStringArray('LAT_SYSADMIN_PROFILES', ' , ');
      perfil = [Select Id From Profile Where  Name IN :profileNames LIMIT 1];

      //Cria novo usuario.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
        
    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '1234';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      //Cria nova UDC.
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '1236';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      
      //Cria nova UDC.
      deposito = new UDC__c();
      deposito.CodDefUsuario__c = '887';
      deposito.CodProd__c     = 'CRM';
      deposito.CodUs__c     = 'DF';
      deposito.Internal_Id__c   = '876';
      deposito.RecordTypeId = idRecTypeUDC;
      insert deposito;
      
      //Cria novo Account
      acc = new Account();
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
      acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      acc.Customer_Flag__c = bandeira.Id;
      acc.Carriers_Numbers__c = '123';
      acc.Business_Unit__c = deposito.Id;
      
      insert acc;
      
      //Recupera um produto no ambiente.
      //produto = new Product2();//[Select Id, Name, Sku__c From Product2 Where Sku__c = '6343' limit 1];
      produto = new Product2();
      produto.Name = 'Cloud2b';
      produto.IsActive = true;
      produto.CD_Unit__c = 'UN';
      produto.Internal_id__c = '444';
      produto.QT_lead_time__c = 5;
      produto.SKU__c = '5666';
      produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
      insert produto;
      
      standardPB = [Select Id From Pricebook2 Where isStandard = true];
      
      pbe2 = new PricebookEntry();
      pbe2.Product2Id = produto.Id;
      pbe2.UnitPrice = 12;
      pbe2.Pricebook2Id = standardPB.Id;
      pbe2.IsActive =true;
      pbe2.UseStandardPrice = false;
      
      insert pbe2;
      
      //Recupera os IDS de tipo de registro.
      idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_0portunidade');
     
      //Cria novo pricebook.
      pricebook = new Pricebook2();
      pricebook.Name = '1';
      pricebook.Description = '1';
      
      insert pricebook;
      
      //Cria novo pricebookEntry
      pbe = new PricebookEntry();
      pbe.Product2Id = produto.Id;
      pbe.UnitPrice = 12;
      pbe.Pricebook2Id = pricebook.Id;
      pbe.IsActive =true;
      pbe.UseStandardPrice = false;
      
      insert pbe;
      
      //Cria nova oportunidade.
      opp = new Opportunity();
      opp.Name = 'Opp TESTE COTA';
      opp.closeDate = System.today()+1;
      opp.RecordTypeId = idOpportunity;
      opp.AccountId = acc.Id;
      opp.StageName = 'Novo Pedido';
      opp.RecordTypeId = RecordTypeForTest.getRecType('Opportunity', 'Nova_oportunidade');
      insert opp;
       
      oli = new OpportunityLineItem();
      oli.PricebookEntryId = pbe.Id;
      oli.OpportunityId =opp.Id;
      oli.UnitPrice = 12;
      oli.Quantity = 12;
      
      insert oli;


      ////////////////////////////////////////
      //  test opportunityProductEntry
      ////////////////////////////////////////
        
      // load the page       
      PageReference pageRef = Page.opportunityProductEntry;
      pageRef.getParameters().put('Id',opp.Id);
      Test.setCurrentPageReference(pageRef);
      
      // load the extension
      //opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(oli.Opportunity));
      opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(opp));
      
      // test 'getChosenCurrency' method
      if(UserInfo.isMultiCurrencyOrganization())
          System.assert(oPEE.getChosenCurrency()!='');
      else
          System.assertEquals(oPEE.getChosenCurrency(),'');

      // we know that there is at least one line item, so we confirm
      Integer startCount = oPEE.ShoppingCart.size();
      //system.assert(startCount>0);

      //test search functionality without finding anything
      oPEE.searchString = 'cloud2b consultoria';
      oPEE.varPaymentVal = 'Todas';
      oPEE.paymentValues();
      //oPEE.updateAvailableList();
      oPEE.updateAvailableListCheck();
      oPEE.getItemX();
      
      String idOli = oli.Id;
      String idOli2 = '';
      //oli3 = oPEE.getItemX();//tItemOpp(idOli);
      oPEE.getItemX();
      //try{
      // oli3 = oPEE.getItemOpp(idOli2);
      //}
      //catch(Exception e)
      //{
      //  System.debug(e.getMessage());
      //}
        
      oPEE.showPopup();
      oPEE.closePopup();
      List<Selectoption> listSelectOption = new List<Selectoption>();
      listSelectOption = oPEE.getCondicao();
      oPEE.priceBookCheck();
      oPEE.onMsg();
      oPEE.onCancel();
      oPEE.changePricebook();
      oPEE.showCampoFormatado();
      oPEE.AddMsgError('ERRO');
              
      //system.assert(oPEE.AvailableProducts.size()==0);
      
      //test remove from shopping cart
      oPEE.toUnselect = oli.PricebookEntryId;
      oPEE.removeFromShoppingCart();
      //system.assert(oPEE.shoppingCart.size()==startCount-1);
      
      //test save and reload extension
      oPEE.onSave();
      oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(opp));
      //system.assert(oPEE.shoppingCart.size()==startCount-1);
      
      // test search again, this time we will find something
      oPEE.searchString = pbe.Name;//oli.PricebookEntry.Name;
      oPEE.updateAvailableListCheck();
      //system.assert(oPEE.AvailableProducts.size()>0);       

      // test add to Shopping Cart function
      //oPEE.toSelect = oPEE.AvailableProducts[0].Id;
      //oPEE.addToShoppingCart();
      //system.assert(oPEE.shoppingCart.size()==startCount);

      opportunityProductEntryExtension.productWrapper pwTeste = new opportunityProductEntryExtension.productWrapper(pbe2);
      pwTeste.isSelected = true;
      oPEE.AvailableProducts.add(pbe2);
      oPEE.lstWProducts.add(pwTeste);
      oPEE.addItensToShoppingCart();
                
      // test save method - WITHOUT quanitities and amounts entered and confirm that error message is displayed
      oPEE.onSave();
      //system.assert(ApexPages.getMessages().size()>0);
       
      // add required info and try save again
      for(OpportunityLineItem o : oPEE.ShoppingCart){
          o.quantity = 5;
          o.unitprice = 300;
      }
      oPEE.onSave();
      oPEE.onSaveRefresh();
      
      // query line items to confirm that the save worked
      //opportunityLineItem[] oli2 = [select Id from opportunityLineItem where OpportunityId = :oli.OpportunityId];
      //system.assert(oli2.size()==startCount);
      // test on new Opp (no pricebook selected) to make sure redirect is happening
      //Opportunity newOpp = new Opportunity(Name='New Opp',RecordTypeId = idOpportunity,stageName='Novo Pedido',Amount=10,closeDate=System.Today()+30,AccountId=opp.AccountId);
      //insert(newOpp);
      //oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(newOpp));
      //System.assert(oPEE.priceBookCheck()!=null);
      
      // final quick check of cancel button
      //System.assert(oPEE.onCancel()!=null);
      
      
      ////////////////////////////////////////
      //  test redirect page
      ////////////////////////////////////////
      
      // load the page
      //pageRef = Page.opportunityProductRedirect;
      //pageRef.getParameters().put('Id',oli.Id);
      //Test.setCurrentPageReference(pageRef);
      // load the extension and confirm that redirect function returns something
      //opportunityProductRedirectExtension oPRE = new opportunityProductRedirectExtension(new ApexPages.StandardController(oli));
      //System.assert(oPRE.redirect()!=null);
     
  }
  */
}