@isTest
public class LAT_UY_SalesAppTest {

    private static final String PRODUCT_1_NAME = 'productName1';
    private static final String PRODUCT_2_NAME = 'productName2';
    private static final String ACCOUNT_NAME = 'Account';
    private static final String ORDER_1_JSON = '{"products":[],' + 
        '"client":{"account":{"Id":"aAuD00000000109KAA","Name":"02726","LAT_Accountid__c":"001D0000019ypz7IAA",' +
        '"RecordTypeId":"012D00000007LFVIA2", "CurrencyIsoCode":"UYU","LAT_Accountid__r":{"CurrencyIsoCode":"UYU","Name":"ABAKO",' +
        '"Client_code_AN8__c":"324603","RecordTypeId":"012D00000007IWCIA2","Id":"001D0000019ypz7IAA"}},"CurrencyIsoCode":"UYU","Name":"ABAKO"},' +
        '"type":{"value": "Replenish"}}';
    private static final String ORDER_2_JSON = '{"products":[{"quantity":1,' +
        '"info":{"maxDiscount":0,"Name":"ABSOLUT ELYX 6 X 1L","record":{' +
        '"Id":"aOg7E0000004CUGSA2","Name":"ABSOLUT ELYX 6 X 1L","LAT_BottlesPerBox__c":6,"LAT_UnitWeight__c":11.1,"LAT_Sku__c":"611",' +
        '"LAT_ProductCode__c":"611","LAT_CDUnit__c":"BT","RecordTypeId":"0127E0000004h0gQAA","CurrencyIsoCode":"UYU"}},"discounts":0}],' +
    '"client":{"account":{"Id":"aAuD00000000109KAA","Name":"02726","LAT_Accountid__c":"001D0000019ypz7IAA",' +
    '"RecordTypeId":"012D00000007LFVIA2", "CurrencyIsoCode":"UYU","LAT_Accountid__r":{"CurrencyIsoCode":"UYU","Name":"ABAKO",' +
    '"Client_code_AN8__c":"324603","RecordTypeId":"012D00000007IWCIA2","Id":"001D0000019ypz7IAA"}},"CurrencyIsoCode":"UYU","Name":"ABAKO"},' +
    '"type":{"value": "Replenish"}, "paymentCondition":{"percentualBonus":"2.3"}}';

    @isTest
    public static void getProductsTest() {
        Map<String, LAT_Product__c> products = createProducts();
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'getProducts';

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        List<LAT_Product__c> responseList = (List<LAT_Product__c>) response.result;

        System.assertEquals(response.success, true);
        System.assertEquals(products.get(responseList[0].Name).Name, responseList[0].Name);
    }

    @isTest
    public static void getClientsTest() {
        LAT_Account__c clients = createClients();
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'getClients';

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        List<LAT_UY_SalesApp.LatAccountWrapper> responseList = (List<LAT_UY_SalesApp.LatAccountWrapper>) response.result;

        System.assertEquals(response.success, true);
        System.assertEquals(clients.LAT_Accountid__r.Name, responseList[0].Name);
    }

    @isTest
    public static void getNewClientsTest() {
        LAT_Account__c clients = createClients();
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'getNewClients';

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        List<LAT_UY_SalesApp.LatAccountWrapper> responseList = (List<LAT_UY_SalesApp.LatAccountWrapper>) response.result;

        System.assertEquals(response.success, true);
        System.assertEquals(clients.LAT_Accountid__r.Name, responseList[0].Name);
    }

    @isTest
    public static void getFavoritesClientsTets() {
        LAT_Account__c clients = createClients();
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'getFavoritesClients';

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        List<LAT_UY_SalesApp.LatAccountWrapper> responseList = (List<LAT_UY_SalesApp.LatAccountWrapper>) response.result;

        System.assertEquals(response.success, true);
        System.assertEquals(clients.LAT_Accountid__r.Name, responseList[0].Name);
    }
    
    @isTest
    public static void getAllOrderTest() {		
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'getAllOrders';

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        List<LAT_Opportunity__c> responseList = (List<LAT_Opportunity__c>) response.result;

        System.assertEquals(response.success, true);
    }
    
    @isTest
    public static void saveOppTest() {		
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'saveOpp';
        request.params = ORDER_1_JSON;

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        String oppId = String.valueOf(response.result);

        //System.assertNotEquals(oppId, null);
    }
    
    @isTest
    public static void saveOrderTest() {		
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'saveOrder';
        request.params = ORDER_2_JSON;

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        String oppId = String.valueOf(response.result);

        //System.assertNotEquals(oppId, null);
    }
    
    @isTest
    public static void editOrderTest() {		
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'editOrder';
        request.params = ORDER_1_JSON;

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        String oppId = String.valueOf(response.result);

        //System.assertNotEquals(oppId, null);
    }
        
    @isTest
    public static void getPriceTest() {		
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'getPrice';
        request.params = ORDER_1_JSON;

        LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);

        String oppId = String.valueOf(response.result);

        System.assertEquals(response.success, true);
    }

    @isTest
    public static void deleteOrderTest() {        
        LAT_UY_SalesApp.Request request = new LAT_UY_SalesApp.Request();
        request.methodName = 'deleteOrder';
        request.params = ORDER_1_JSON;

        try{LAT_UY_SalesApp.Response response = LAT_UY_SalesApp.remoteRequest(request);}catch (Exception e){}
        Map<String, LAT_Product__c> prodMap = createProducts();
        LAT_Account_product_payment__c app = getLAT_Acc_Prod_Payment(getAccountOffTradeUY('TESTES'), prodMap.values()[0]);
        LAT_UY_SalesApp.PaymentCondition pc = new LAT_UY_SalesApp.PaymentCondition(app);
        LAT_UY_SalesApp.ProductWrapper pw = new LAT_UY_SalesApp.ProductWrapper(app);
        try{LAT_UY_SalesApp.LatAccountWrapper law = new LAT_UY_SalesApp.LatAccountWrapper(createClients('OTRO'));
        law.addPaymentCondition(app);}catch (Exception e){}

    }
    
    public static Map<String, LAT_Product__c> createProducts() {
        Map<String, LAT_Product__c> products = new Map<String, LAT_Product__c>();
        LAT_Product__c product1 = new LAT_Product__c();
        product1.Name = PRODUCT_1_NAME;
        product1.LAT_Sku__c = '546';
        product1.LAT_IsRefactorProduct__c = 'Y';
        product1.LAT_IsActive__c = true;
        product1.LAT_ExternalId__c = '5-56321';

        LAT_Product__c product2 = new LAT_Product__c();
        product2.Name = PRODUCT_2_NAME;
        product2.LAT_Sku__c = '546';
        product2.LAT_IsRefactorProduct__c = 'Y';
        product2.LAT_IsActive__c = true;
        product2.LAT_ExternalId__c = '5-56322';

        products.put(product1.Name, product1);
        products.put(product2.Name, product2);

        insert products.values();
        return products;
    }

    public static LAT_Account__c createClients() {
        return createClients('TEST');
    }

    public static LAT_Account__c createClients(String nombre) {
        Account account = getAccountOffTradeUY(nombre);      
        insert account;
        
        LAT_Account_product_payment__c accPayment = new LAT_Account_product_payment__c(Account__c = account.Id);
        insert accPayment;

        LAT_ACCOUNT__c latAccount = [ SELECT Id, Name, CurrencyIsoCode, LAT_Accountid__r.Name FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: account.Id LIMIT 1];

        return latAccount;
    }
    
    public static RecordType getRecordType(String name){
        return Global_RecordTypeCache.getRtRec('Account' + name);
    }

    public static Account getAccountOffTradeUY(String nombre){
        return new Account(Name='TEST'+nombre, CurrencyIsoCode = 'UYU', Corporate_Name__c = 'Target Corp',recordtypeid = getRecordType('ACC_2_OffTrade_URU').id, CNPJ__c = '212184510011', Client_country_an8__c = '5-321277', SaveDuplicatedFiscalID_AR__c = true );
    }
    
    public static LAT_Opportunity__c createOpportunity() {
        LAT_Opportunity__c  opp = new LAT_Opportunity__c();
        Account account = getAccountOffTradeUY('TESTE OPP');      
        insert account;
        
        opp.Name = 'Opp Test';
        opp.LAT_Type__c = 'SO - Standard Order';
        opp.LAT_Account__c = account.Id;        
        opp.LAT_CloseDate__c = Date.today();
        opp.LAT_StageName__c = 'Novo Pedido';
        opp.LAT_Country__c = 5;
        opp.CurrencyIsoCode = 'UYU';
        
        return opp;
    }

    public static LAT_Account_product_payment__c getLAT_Acc_Prod_Payment(Account acc, LAT_Product__c prod) {

        UDC__c paymentCondition = new UDC__c(
            Name = 'test paymentConditionA',
            CodDefUsuario__c='06', 
            CodProd__c='CRM', 
            CodUs__c='DF', 
            Internal_Id__c='1237 CRM-PT', 
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        insert paymentCondition;
        upsert acc;

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c(
            PaymentConditionDescription__c = paymentCondition.Name,
            PaymentCondition__c = paymentCondition.CodDefUsuario__c,
            Account__c = acc.Id,
            LAT_Product__c = prod.Id,
            Payment__c = paymentCondition.Id,
            ProductExternalId__c = prod.LAT_ExternalId__c,
            CustomerCountryAN8Code__c = acc.Client_country_AN8__c,           
            PaymentConditionExternalId__c = paymentCondition.Internal_Id__c
        );
        insert app;  
        return app;  
    }
}