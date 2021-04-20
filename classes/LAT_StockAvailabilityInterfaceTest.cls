/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 13/5/2016            \  
*------------------------------------------------------------------------------/
*   Clase utilizada para test de LAT_StockAvailabilityInterfaceTest                  \
*******************************************************************************/
//http://cawlkl01.pramericas.com:8011/JDE9/Inventory/GetStock
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 11/11/2016
*
********************************************************************************/
@isTest(seeAllData=true)
public class LAT_StockAvailabilityInterfaceTest {
 
@isTest static void stockAvailibityTest(){

    Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest());
    
    Utils.setMigrationDoneTest(false);
    User admin = [SELECT Id FROM User WHERE isActive=True AND ProfileId=:LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') LIMIT 1];
       
    //User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    //insert usuario; 
    
    //insertCred();
    System.runAs(admin) {

        Account acc = insertAcc(admin);
        Test.startTest();     
        Utils.setMigrationDoneTest(false);
        Opportunity opp = insertOpp(acc);
        Product2 prod = insertProd();
        PricebookEntry priceE = insertPricebookEntry(prod);
        OpportunityLineItem oppLine = insertOppLine(opp,priceE);
        List<OpportunityLineItem> oppLineList = new List<OpportunityLineItem>();
        oppLineList.add(oppLine);
        Lat_stock__c stock = insertStock(prod);

            LAT_StockAvailabilityInterface.stockAvailibity(oppLineList,opp.id);
    }
    Test.stopTest();

}

@isTest static void stockAvailibityTestb(){

    Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest());
    Utils.setMigrationDoneTest(true);
    User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    //insert usuario; 
    
    //insertCred();

    Account acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
    acc.Client_code_AN8__c = '557798';
    acc.SaveDuplicatedFiscalID_AR__c = true;
    insert acc;
    Test.startTest();     
    Utils.setMigrationDoneTest(true);
    Opportunity opp = insertOpp(acc);
    Product2 prod = insertProd();
    PricebookEntry priceE = insertPricebookEntry(prod);
    OpportunityLineItem oppLine = insertOppLine(opp,priceE);
    List<OpportunityLineItem> oppLineList = new List<OpportunityLineItem>();
    oppLineList.add(oppLine);
    Lat_stock__c stock = insertStock(prod);

        LAT_StockAvailabilityInterface.stockAvailibity(oppLineList,opp.id);

    Test.stopTest();

}

@isTest static void stockAvailibityTest2(){
        User admin = [SELECT Id FROM User WHERE  isActive=True AND ProfileId=:LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') LIMIT 1];
        system.runas(admin){ 

            Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest());
            Utils.setMigrationDoneTest(true);
            //User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            //insert usuario; 
            
            //insertCred();
            Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
            UDC__c deposito = new UDC__c();
            deposito.CodDefUsuario__c = '05';
            deposito.CodProd__c     = 'CRM';
            deposito.CodUs__c     = 'DF';
            deposito.Internal_Id__c   = 'CRM-DF876';
            deposito.RecordTypeId = idRecTypeUdc;
            insert deposito;

            Account acc = insertAcc(admin,deposito);

            Test.startTest(); 
            LAT_BR_CS003_OppLimitTime__c cs = new LAT_BR_CS003_OppLimitTime__c();
            cs.LAT_BR_HH__c    = 08;
            cs.LAT_BR_MM__c    = 00;
            //insert cs;
            
            Utils.setMigrationDoneTest(true);
            LAT_Opportunity__c opp = LAT_insertOpp(acc);
            LAT_Product__c prod = LAT_insertProd();
            LAT_OpportunityLineItem__c oppLine = LAT_insertOppLine(opp,prod);
            List<LAT_OpportunityLineItem__c> oppLineList = new List<LAT_OpportunityLineItem__c>();
            oppLineList.add(oppLine);
            Lat_stock__c stock = insertStock(prod);

            LAT_StockAvailabilityInterface.stockAvailibity(oppLineList,opp.id);

            Test.stopTest();
        }
}

@isTest static void stockAvailibityTest3(){

    Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest());
    Utils.setMigrationDoneTest(true);
    User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    //insert usuario; 
    
    //insertCred();
    Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
    UDC__c deposito = new UDC__c();
    deposito.CodDefUsuario__c = '05';
    deposito.CodProd__c     = 'CRM';
    deposito.CodUs__c     = 'DF';
    deposito.Internal_Id__c   = 'CRM-DF876';
    deposito.RecordTypeId = idRecTypeUdc;
    insert deposito;

    Account acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
    acc.Client_code_AN8__c = '557798';
    acc.SaveDuplicatedFiscalID_AR__c = true;
    insert acc;
    Test.startTest();
    Utils.setMigrationDoneTest(true);

    LAT_Opportunity__c opp = LAT_insertOpp(acc);
    LAT_Product__c prod = LAT_insertProd();
    LAT_OpportunityLineItem__c oppLine = LAT_insertOppLine(opp,prod);
    List<LAT_OpportunityLineItem__c> oppLineList = new List<LAT_OpportunityLineItem__c>();
    oppLineList.add(oppLine);
    Lat_stock__c stock = insertStock(prod);

    LAT_StockAvailabilityInterface.stockAvailibity(oppLineList,opp.id);
    LAT_StockAvailabilityInterface.getConnectionParameter('Brasil');
    LAT_StockAvailabilityInterface.getStockBatch('Brasil', 'BT', 'CA', new List<LAT_Product__c>());
    LAT_StockAvailabilityInterface.getStockBatch('Argentina', 'BT', 'CA', new List<LAT_Product__c>{prod});
        
    Test.stopTest();

}

public static PricebookEntry insertPricebookEntry(Product2 produto){
    PricebookEntry pbe1 = new PricebookEntry(Product2Id = produto.Id, UnitPrice = 12, Pricebook2Id = Test.getStandardPricebookId(), IsActive =true, UseStandardPrice = false);
    insert pbe1;
    return pbe1;
}
  

public static Opportunity insertOpp(Account acc){
    Opportunity opp = new Opportunity();
    opp.Name = 'Opp TESTE COTA';
    opp.closeDate = System.today()+1;
    String idOpportunity = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade');
    opp.RecordTypeId = idOpportunity;
    opp.AccountId = acc.Id;
    opp.StageName = 'Novo Pedido';
      
    insert opp;
    return opp;
}

public static LAT_Opportunity__c LAT_insertOpp(Account acc){
    LAT_Opportunity__c opp = new LAT_Opportunity__c();
    opp.Name = 'Opp TESTE COTA';
    opp.LAT_CloseDate__c = System.today()+1;
    String idOpportunity = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade');
    opp.RecordTypeId = idOpportunity;
    opp.LAT_Account__c = acc.Id;
    opp.LAT_StageName__c = 'Novo Pedido';
      
    insert opp;
    return opp;
}

public static OpportunityLineItem insertOppLine(Opportunity opp,PricebookEntry entradaCatalogoPreco){
      
    OpportunityLineItem  oli = new OpportunityLineItem();
    oli.PricebookEntryId = entradaCatalogoPreco.Id;
    oli.OpportunityId    = opp.Id;
    oli.UnitPrice        = 12;
    oli.LAT_SkuText__c = '444';
    oli.Quantity         = 12;
    insert oli;
    return oli;
}

public static LAT_OpportunityLineItem__c LAT_insertOppLine(LAT_Opportunity__c opp,LAT_Product__c entradaCatalogoPreco){
      
    LAT_OpportunityLineItem__c  oli = new LAT_OpportunityLineItem__c();
    oli.LAT_Product__c        = entradaCatalogoPreco.Id;
    oli.LAT_Opportunity__c    = opp.Id;
    oli.LAT_UnitPrice__c      = 12;
    oli.LAT_SkuText__c        = '444';
    oli.LAT_Quantity__c       = 12;
    insert oli;
    return oli;
}

public static Product2 insertProd(){
    Product2  produto = new Product2();
    produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
    produto.IsActive = true;
    produto.CD_Unit__c = 'CA';
    produto.Internal_id__c = '1-444-05';
    produto.QT_lead_time__c = 5;
    produto.SKU__c = '444';
    insert produto;
    return produto;
}

public static LAT_Product__c LAT_insertProd(){
    LAT_Product__c  produto = new LAT_Product__c();
    produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
    produto.LAT_IsActive__c = true;
    produto.LAT_CDUnit__c = 'CA';
    produto.LAT_ExternalId__c = '1-444-05';
    produto.LAT_QTLeadTime__c = 5;
    produto.LAT_Sku__c = '444';
    insert produto;
    return produto;
}

public static Account insertAcc(User u, UDC__c deposito){
    Account acc = new Account();
    acc.OwnerId = u.Id;
    acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
    acc.CNPJ__c = '48843971000120';
    acc.Type = 'Outros';
    acc.Status__c = 'Cliente cadastrado no JDE';
    acc.Agency__c = '000';
    acc.Checking_account__c = '000';
    acc.Current_account__c = '0';
    acc.Corporate_Name__c = 'Teste';
    acc.Channel__c = 'Off Trade';
    acc.Frequency_of_Visits__c = 'Semanal';
    acc.Client_code_AN8__c = '557798';
    acc.Business_Unit__c = deposito.Id;
    acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
      
    insert acc;
    return acc;
      
}

public static Account insertAcc(User u ){
    Account acc = new Account();
    acc.OwnerId = u.Id;
    acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
    acc.CNPJ__c = '48843971000120';
    acc.Type = 'Outros';
    acc.Status__c = 'Cliente cadastrado no JDE';
    acc.Agency__c = '000';
    acc.Checking_account__c = '000';
    acc.Current_account__c = '0';
    acc.Corporate_Name__c = 'Teste';
    acc.Channel__c = 'Off Trade';
    acc.Frequency_of_Visits__c = 'Semanal';
    acc.Client_code_AN8__c = '557798';
    acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
      
    insert acc;
    return acc;
      
}
public static Lat_stock__c insertStock(Product2 p){
    Lat_stock__c lStock = new Lat_stock__c();
    lstock.Product__c = p.id;
    lStock.LAT_Branch__c = 'DHCJ';
    lStock.LAT_Unit__c = 'C9';
    lstock.LAT_Stock__c = 500;
    lStock.LAT_ExternalId__c = '1-444';
    insert lStock;
    return lStock;
}

public static Lat_stock__c insertStock(LAT_Product__c p){
    Lat_stock__c lStock = new Lat_stock__c();
    lstock.LAT_Product__c = p.id;
    lStock.LAT_Branch__c = 'DHCJ';
    lStock.LAT_Unit__c = 'C9';
    lstock.LAT_Stock__c = 500;
    lStock.LAT_ExternalId__c = '1-444';
    insert lStock;
    return lStock;
}

public static void insertCred() {
    CS001_JDEInterfaceCredentials__c cred = new CS001_JDEInterfaceCredentials__c(
        Name = 'Brasil',
        Country__c = '1',
        EndPoint_BalanceCheck__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/BalanceCheck/BalanceCheckProxy',
        EndPoint_ContractManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/ContractManager/ContractManagerProxy',
        EndPoint_CustomerHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerHandlerReq',
        EndPoint_CustomerVerify__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerVerifyReq',
        EndPoint_PaymentManager__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/PaymentManager/PaymentManagerProxy',
        EndPoint_PriceCalculation__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Price/PriceCalculationReq',
        EndPoint_RVManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/RVManager/RVManagerProxy',
        EndPoint_SalesOrderHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/SalesOrder/AsyncSalesOrderHandlerReq',
        EndPoint_ReceiptHandeler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Collection/CollectionManagerSFDCReq',
        EndPoint_GetStock__c = 'http://crm.test.pernod-ricard.com.br/SFDC/test',
        RemoteHostIP__c = '200.200.10.10',
        System__c = 'X',
        SystemUserID__c = 'cloud2b'
    );
    insert cred;

}

public static Lat_GetStockTypes.ItemListResponseType getResponse(){
    Lat_GetStockTypes.ItemListResponseType response = new Lat_GetStockTypes.ItemListResponseType();
    response.itemResponse = new List<Lat_GetStockTypes.ItemResponseType>();

    Lat_GetStockTypes.ItemResponseType responseType = new Lat_GetStockTypes.ItemResponseType();
    responseType.businessUnit = 'null';
    responseType.sku = '444';
    responseType.response = '1200.76';
    response.itemResponse.add(responseType);

    responseType = new Lat_GetStockTypes.ItemResponseType();
    responseType.businessUnit = 'null';
    responseType.response = '0';
     responseType.sku = '3333';
    responseType.errorJDE = 'Error';
    response.itemResponse.add(responseType);
    
    return response;
}


}