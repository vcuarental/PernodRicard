public class LAT_UY_SalesApp {

    public LAT_UY_SalesApp() {}

    @RemoteAction
    public static Response remoteRequest(Request request) {
        Response response = new Response();
        try {
            response.result = executeAction(request);
        } catch (Exception e) {
            response.success = false;
            response.error = e.getMessage();
        }
        return response;
    }

    private static Object executeAction(Request request) {
        System.debug(request);
        if (request.methodName == 'getProducts') {
            return getProducts();
        }
        if (request.methodName == 'getClients') {
            return getClients();
        }
        if (request.methodName == 'getNewClients') {
            return getNewClients();
        }
        if (request.methodName == 'getFavoritesClients') {
            return getFavoritesClients();
        }
        if (request.methodName == 'getAllOrders') {
            return getAllOrders();
        }
        if (request.methodName == 'editOrder') {
            return editOrder(request.params);
        }
        if (request.methodName == 'saveOrder') {
            return saveOrder(request.params);
        }
        if (request.methodName == 'deleteOrder') {
            deleteOrder(request.params);
        }
        if (request.methodName == 'getPrice') {
            return getPrice(request.params);
        }
        if (request.methodName == 'saveOpp') {
            return saveOpp(request.params);
        }
        if (request.methodName == 'sendToJDE') {
            return sendToJDE(request.params);
        }
        return null;
    }

    private static List<LAT_Product__c> getProducts() {
        return [
            SELECT Id, Name, LAT_BottlesPerPallet__c, LAT_UnitWeight__c, LAT_Sku__c, LAT_ProductCode__c
            FROM LAT_Product__c
            WHERE LAT_IsRefactorProduct__c = 'Y'
                AND LAT_IsActive__c = true
                AND LAT_ExternalId__c LIKE '5-%'
            ORDER BY Name
        ];
    }

    private static List<LatAccountWrapper> getClients() {
        Map<Id, LatAccountWrapper> clientsByAccountId = new Map<Id, LatAccountWrapper>();
        Set<String> accountsIds = new Set<String>();

        for (LAT_Account__c latAccount : getLatAccounts()) {
            clientsByAccountId.put(latAccount.LAT_Accountid__c, new LatAccountWrapper(latAccount));
            accountsIds.add(latAccount.LAT_Accountid__c);
        }

        for (LAT_Account_product_payment__c accountPayment : getAccountPaymentsForClients(accountsIds)) {
            LatAccountWrapper acc = clientsByAccountId.get(accountPayment.Account__c);
            acc.addPaymentCondition(accountPayment);
        }
        return clientsByAccountId.values();
    }

    private static List<LatAccountWrapper> getNewClients() {
        // @TODO Implements newClients;
        return getClients();
    }

    private static List<LatAccountWrapper> getFavoritesClients() {
        // @TODO Implements getFavoritesClients;
        return getClients();
    }

    private static List<LAT_Account__c> getLatAccounts() {
        LAT_Uy_SalesAppWithSaring innerCls = new LAT_Uy_SalesAppWithSaring(); 
        
        return  innerCls.getClientsWithSharing();
    }

    private static List<LAT_Account_product_payment__c> getAccountPaymentsForClients(Set<String> accountsIds) {
        return [
            SELECT Id, Name, Account__c, PaymentCondition__c, PaymentConditionDescription__c, PercentualBonus__c, MultipleQuantity__c ,
                LAT_Product__r.Id,  LAT_Product__r.Name,  LAT_Product__r.LAT_BottlesPerBox__c,  LAT_Product__r.LAT_UnitWeight__c,
                LAT_Product__r.LAT_Sku__c,  LAT_Product__r.LAT_ProductCode__c, LAT_Product__r.LAT_CDUnit__c
            FROM LAT_Account_product_payment__c
            WHERE account__c IN :accountsIds
                AND LAT_Product__r.LAT_IsRefactorProduct__c = 'Y'
                AND LAT_Product__r.LAT_IsActive__c = true
                AND LAT_Product__r.LAT_ExternalId__c LIKE '5-%'
                AND LAT_Product__r.Lastmodifieddate >= LAST_N_DAYS:60
            ORDER BY LAT_Product__r.Name
        ];
    }

    private static List<LAT_Opportunity__c> getAllOrders() {
        LAT_Uy_SalesAppWithSaring innerCls = new LAT_Uy_SalesAppWithSaring(); 
        
        return  innerCls.getAllOrdersWithSharing();
        /*
        return [ SELECT Id, Name,LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_StageName__c, LAT_Account__c, LAT_ClientCodeAN8__c, LAT_SentToJDE__c, LAT_TotalValue__c, LAT_JDEOrderKey__c, CurrencyIsoCode,
                    LAT_Type__c, LAT_CloseDate__c, LAT_EstimatedDeliveryDate__c, LAT_CreationDateTime__c, LAT_NRCustomerOrder__c, LAT_NROrderJDE__c, LAT_OrderOrigin__c,
                    CreatedBy.Name, LAT_Account__r.Corporate_Name__c,
                    (SELECT id, LAT_QTTotal__c, LAT_QTBonus__c,  LAT_StatusDescription__c, LAT_PaymentCondition__c, LAT_PaymentConditionDescription__c , LAT_UnitCode__c, LAT_PercentualBonus__c , LAT_UnitPrice__c,
                        LAT_PriceTotal__c, LAT_CdLineStatus__c, LAT_Product__r.Name, LAT_Product__r.LAT_Sku__c, LAT_PcDiscount__c, LAT_Quantity__c, LAT_BottlesPerBox__c
                        FROM  OpportunityLineItems__r
                        ORDER BY LAT_Product__r.Name)
                FROM LAT_Opportunity__c
                WHERE (LAT_Opportunity__c.CurrencyIsoCode = 'USD'
                    OR LAT_Opportunity__c.CurrencyIsoCode = 'UYU')
                    AND Createddate >= LAST_N_MONTHS:3
                ORDER BY createdDate DESC
        ];*/
    }

    private static Object sendToJDE(String oppId) {
        System.debug('%%%%% oppId : ' + oppId);
        System.debug('%%%%% lineas : ' + [SELECT id, LAT_Product__r.Name from LAT_OpportunityLineItem__c where LAT_Opportunity__c = :oppId]);
        return WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(oppId);
    }

    private static Object saveOrder(String orderStr) {

        OrderWrapper order = new OrderWrapper(orderStr);
        LAT_Opportunity__c opp = order.getOpportunity();
        upsert opp;

        List<LAT_OpportunityLineItem__c> oppLineItems = order.getOpportunityLineItems(opp.Id);
        upsert oppLineItems;

        return opp.Id;
    }

    /*
    * editOrder(orderValues)
    * Request handler to save the orders. getOpportunityOnEdit(), set the new values to the OpportunityLine, then
    * we delete all the lineItems and insert the new values.
    */
    private static Object editOrder(String orderStr) {

        OrderWrapper order = new OrderWrapper(orderStr);
        LAT_Opportunity__c opp = order.getOpportunityOnEdit();
        system.debug(opp);
        update opp;

        //Clean the Line Items
        deleteLineItems(opp.Id);
        
        List<LAT_OpportunityLineItem__c> oppLineItems = order.getOpportunityLineItems(opp.Id);
        insert oppLineItems;

        return opp.Id;
    }
    
     private static void deleteOrder(String oppId){
        system.debug('>>>>>>>>>>' + oppId);
        List<LAT_Opportunity__c> opp = [Select Id from LAT_Opportunity__c where Id =: oppId ];
        delete opp;
    }

    private static void deleteLineItems(String oppId){
        List<LAT_OpportunityLineItem__c> oppLineItems = [Select Id from LAT_OpportunityLineItem__c where LAT_Opportunity__c =: oppId ];
        delete oppLineItems;
    }

     private static Object saveOpp(String orderStr) {

        OrderWrapper order = new OrderWrapper(orderStr);
        LAT_Opportunity__c opp = order.getOpportunity();
        opp.id = null;
        insert opp;

        return opp.Id;
    }

    private static Object getPrice(String orderStr) {

        Map<String, Object> orderObject = (Map<String, Object>) JSON.deserializeUntyped(orderStr);
        Boolean shouldDeleteOpp = orderObject.get('shouldDeleteOpp') != null ? Boolean.valueOf(orderObject.get('shouldDeleteOpp')) : false;
        System.debug('=========> shouldDeleteOpp!:' + shouldDeleteOpp);
        OrderWrapper order = new OrderWrapper(orderStr);
        LAT_Opportunity__c opp = order.getOpportunity();
       
        List<LAT_OpportunityLineItem__c> oppLineItems = order.getOpportunityLineItems(opp.Id);

        PriceCalculationInterface.debug = new LAT_DebugUtil();
        System.debug('ID OPP = ' + opp.Id);
         String message = '';
        //String message = PriceCalculationInterface.LAT_BR_NewPriceCalculation(opp.Id, oppLineItems, false);
        try {
            message = WS04_PriceCalculationInterface_AR.LAT_PriceCalculation2(opp.Id, oppLineItems);

        } catch (Exception e) {
            System.debug('JDE Error!:' + e.getMessage());
        }



        if (shouldDeleteOpp) {
            delete opp;
        } else {
            //upsert oppLineItems;
        }
         System.debug('=========> oppLineItems!:' + oppLineItems);
        return new PriceResponse(oppLineItems, message);
    }

    public class Request {

        public String methodName;
        public String params;
    }

    public class ProductWrapper {
        Public LAT_Product__c record;
        Public String Name;
        public Double maxDiscount;

        public ProductWrapper(LAT_Account_product_payment__c accountPayment) {
            this.record = accountPayment.LAT_Product__r;
            this.maxDiscount = accountPayment.PercentualBonus__c;
            this.Name = accountPayment.LAT_Product__r.Name;
        }
    }

    public class Response {

        public String error;
        public Boolean success = true;
        public Object result;
    }

    public class LatAccountWrapper {

        public LAT_Account__c account;
        public String Name;
        public String CurrencyIsoCode;
        public List<PaymentCondition> productsPayments;
        public Map<String, List<ProductWrapper>> productsByPaymentCondition;

        public LatAccountWrapper(LAT_Account__c latAccount) {
            this.account = latAccount;
            this.Name = latAccount.LAT_Accountid__r.Name;
            this.productsByPaymentCondition = new Map<String, List<ProductWrapper>>();
            this.productsPayments = new List<PaymentCondition>();
            this.CurrencyIsoCode = latAccount.LAT_Accountid__r.CurrencyIsoCode;
        }

        public void addPaymentCondition( LAT_Account_product_payment__c accountPayment) {
            if (productsByPaymentCondition.get(accountPayment.PaymentCondition__c) == null) {
                productsByPaymentCondition.put(accountPayment.PaymentCondition__c, new List<ProductWrapper>{new ProductWrapper(accountPayment)});
                productsPayments.add(new PaymentCondition(accountPayment));
            } else {
                productsByPaymentCondition.get(accountPayment.PaymentCondition__c).add(new ProductWrapper(accountPayment));
            }
        }
    }

    public class PaymentCondition {

        public String paymentCondition;
        public String paymentDescription;
        public Double percentualBonus;
        public Double multipleQuantity;

        public PaymentCondition(LAT_Account_product_payment__c accountPayment) {
           this.paymentCondition = accountPayment.PaymentCondition__c;
           this.paymentDescription = accountPayment.PaymentConditionDescription__c;
           this.percentualBonus = accountPayment.PercentualBonus__c;
           this.multipleQuantity = accountPayment.MultipleQuantity__c;
           String t = 'Si';
           String t2 = 'Si';
           String t3 = 'Si';
        }
    }

    public class PriceResponse {

        public String message;
        public Map<String, LAT_OpportunityLineItem__c> opportunitiesBySku;

        public PriceResponse(List<LAT_OpportunityLineItem__c> opportunitiesItems, String message) {
            this.message = message;
            this.opportunitiesBySku = new Map<String, LAT_OpportunityLineItem__c>();
            for (LAT_OpportunityLineItem__c opp : opportunitiesItems) {
                opportunitiesBySku.put(opp.LAT_SkuText__c, opp);
            }
        }

    }

    public class OrderWrapper {

        Map<String, Object> orderObject;
        Map<String, Object> clientData;
        Map<String, Object> accountData;
        Map<String, Object> paymentConditionData;
        Map<String, Object> typeData;
        String oppId;

        public OrderWrapper(String jsonData) {
            orderObject = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
            clientData = (Map<String, Object>) orderObject.get('client');
            accountData = (Map<String, Object>) clientData.get('account');
            paymentConditionData = (Map<String, Object> ) orderObject.get('paymentCondition');
            typeData = (Map<String, Object> ) orderObject.get('type');
            oppId = String.valueOf(orderObject.get('id'));
        }

        public LAT_Opportunity__c getOpportunity() {
            LAT_Opportunity__c opp = new LAT_Opportunity__c();

            opp.Name = String.valueOf(clientData.get('Name'));
            opp.LAT_Type__c = 'SO - Standard Order';
            opp.LAT_Account__c = String.valueOf(accountData.get('LAT_Accountid__c'));
            Map<String, Object> masterAccount = (Map<String, Object>) accountData.get('LAT_Accountid__r');
            opp.CurrencyIsoCode = String.valueOf(masterAccount.get('CurrencyIsoCode'));
            opp.LAT_DSMessage1__c =String.valueOf(orderObject.get('message1'));
            opp.LAT_DSMessage2__c =String.valueOf(orderObject.get('message2'));
            opp.LAT_CloseDate__c = Date.today();
            opp.LAT_LeadSource__c = 'Salesforce_APP';
            opp.LAT_StageName__c = 'Novo Pedido';
            opp.LAT_Country__c = 5;
            opp.Id = oppId != '' ? oppId : null;

            return opp;
        }

         public LAT_Opportunity__c getOpportunityOnEdit() {
            LAT_Opportunity__c opp = new LAT_Opportunity__c();
            opp.Name = String.valueOf(clientData.get('Name'));
            opp.LAT_Type__c = String.valueOf(typeData.get('value'));
            opp.LAT_Account__c = String.valueOf(accountData.get('LAT_Accountid__c'));
            Map<String, Object> masterAccount = (Map<String, Object>) accountData.get('LAT_Accountid__r');
            opp.CurrencyIsoCode = String.valueOf(masterAccount.get('CurrencyIsoCode'));
            opp.LAT_DSMessage1__c =String.valueOf(orderObject.get('message1'));
            opp.LAT_DSMessage2__c =String.valueOf(orderObject.get('message2'));
            //opp.PaymentCondition__c = String.valueOf(paymentConditionData.get('paymentCondition')) ;
            opp.LAT_Country__c = 5;
            opp.Id = oppId != '' ? oppId : null;

            return opp;
        }

        public List<LAT_OpportunityLineItem__c> getOpportunityLineItems(Id oppId) {
            List<Object> products = (List<Object>) orderObject.get('products');
            List<LAT_OpportunityLineItem__c> items = new List<LAT_OpportunityLineItem__c>();

            for (Object p : products) {
                Map<String, Object> product = (Map<String, Object>) p;
                System.debug(product);
                items.add(createOpportunityLineItem(product, oppId));
            }

            return items;
        }
        @TestVisible
        private LAT_OpportunityLineItem__c createOpportunityLineItem( Map<String, Object> product, Id oppId) {
            Map<String, Object> paymentCondition = (Map<String, Object>) orderObject.get('paymentCondition');
            Map<String, Object> info = (Map<String, Object>) product.get('info');
            Map<String, Object> record = (Map<String, Object>) info.get('record');
            LAT_OpportunityLineItem__c oppItem = new LAT_OpportunityLineItem__c();
            // where is the id to update?
            
            oppItem.LAT_UnitPrice__c = Double.valueOf(product.get('price'));
            oppItem.LAT_PercentualBonus__c = Double.valueOf(product.get('discounts'));
            oppItem.LAT_AR_Discount__c = Double.valueOf(product.get('discounts'));
            oppItem.LAT_Product__c = String.valueOf(record.get('Id'));
            oppItem.LAT_Quantity__c = Double.valueOf(product.get('quantity'));
            oppItem.LAT_Opportunity__c = oppId != null ? oppId : null;
            oppItem.LAT_AR_UOM__c='BT'; //TODO Dinamic;
            oppItem.LAT_AR_MaxDiscount__c = Double.valueOf(paymentCondition.get('percentualBonus'));
            oppItem.LAT_PaymentCondition__c = String.valueOf(paymentCondition.get('paymentCondition'));
            oppItem.LAT_PaymentConditionDescription__c = String.valueOf(paymentCondition.get('paymentDescription'));
            oppItem.LAT_SkuText__c = String.valueOf(record.get('LAT_Sku__c'));
            oppItem.LAT_Product__c = String.valueOf(record.get('Id'));
            oppItem.LAT_UnitCode__c = String.valueOf(record.get('LAT_CDUnit__c'));
            oppItem.LAT_BottlesPerBox__c = Double.valueOf(record.get('LAT_BottlesPerBox__c'));
            oppItem.LAT_UnitWeight__c = Double.valueOf(record.get('LAT_UnitWeight__c'));
            oppItem.CurrencyIsoCode =  String.valueOf(record.get('CurrencyIsoCode'));
            oppItem.LAT_MultipleQuantity__c = Double.valueOf(paymentCondition.get('multipleQuantity'));

            return oppItem;
        }
    }

    public with sharing class LAT_Uy_SalesAppWithSaring {

        public  LAT_Uy_SalesAppWithSaring(){

        }

        public  List<LAT_Account__c> getClientsWithSharing() {

            return [
                SELECT Id, Name, LAT_Accountid__r.CurrencyIsoCode, LAT_Accountid__c, LAT_Accountid__r.Name, LAT_Accountid__r.Client_code_AN8__c 
                FROM LAT_Account__c
                WHERE LAT_Accountid__r.Client_country_an8__c LIKE '5-%'
                AND LAT_Accountid__r.RecordType.DeveloperName = 'ACC_2_OffTrade_URU'
                ORDER BY LAT_Accountid__r.Name
            ];
        }

        private  List<LAT_Opportunity__c> getAllOrdersWithSharing() {
            return [ SELECT Id, Name,LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_StageName__c, LAT_Account__c, LAT_ClientCodeAN8__c, LAT_SentToJDE__c, LAT_TotalValue__c, LAT_JDEOrderKey__c, CurrencyIsoCode,
                        LAT_Type__c, LAT_CloseDate__c, LAT_EstimatedDeliveryDate__c, LAT_CreationDateTime__c, LAT_NRCustomerOrder__c, LAT_NROrderJDE__c, LAT_OrderOrigin__c,
                        CreatedBy.Name, LAT_Account__r.Corporate_Name__c,
                        (SELECT id, LAT_QTTotal__c, LAT_QTBonus__c,  LAT_StatusDescription__c, LAT_PaymentCondition__c, LAT_PaymentConditionDescription__c , LAT_UnitCode__c, LAT_PercentualBonus__c , LAT_UnitPrice__c,
                            LAT_PriceTotal__c, LAT_CdLineStatus__c, LAT_Product__r.Name, LAT_Product__r.LAT_Sku__c, LAT_PcDiscount__c, LAT_Quantity__c, LAT_BottlesPerBox__c
                            FROM  OpportunityLineItems__r
                            ORDER BY LAT_Product__r.Name)
                    FROM LAT_Opportunity__c
                    WHERE (LAT_Opportunity__c.CurrencyIsoCode = 'USD'
                        OR LAT_Opportunity__c.CurrencyIsoCode = 'UYU')
                    ORDER BY createdDate DESC LIMIT 120
            ];
        }

    }
}