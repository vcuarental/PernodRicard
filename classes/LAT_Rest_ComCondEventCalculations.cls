@RestResource(urlMapping='/LAT_Rest_ComCondEventCalculations/*')
global without sharing class LAT_Rest_ComCondEventCalculations {
    private static final String CONTRACT_NOT_FOUND = 'Contrato n�o encontrado';
    private static final String PRODUCT_NOT_FOUND = 'Produto n�o encontrado';
    private static final String ACCOUNT_NOT_FOUND = 'Conta n�o encontrada';
    private static final Integer HTTP_SUCCESS_CODE = 200;
    private static final Integer HTTP_ERROR_CODE_NOT_FOUND = 404;
    private static final Integer HTTP_ERROR_CODE = 400;

    @HttpPut
    global static void PUT(){
    	
        RestRequest req = RestContext.request;
        System.debug('Antes de todo ');
        System.debug('Body : ' + req.requestBody.toString());
        LAT_ContractHandlerJSON.Payment payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(req.requestBody.toString(), LAT_ContractHandlerJSON.Payment.class);
    	System.debug('%%%% pagamento : ' +payment);
    	List<Account> accs = [SELECT Id, Revenue_UF__c FROM Account WHERE Id =:payment.distribuitorId];
        if(accs.size() > 0) {
            Account acc = accs[0];
            System.debug('%%%% Account : ' + acc);
            List<LAT_ReferenceProduct__c> prods = [SELECT Id, LAT_Product__r.LAT_BottlesPerBox__c FROM LAT_ReferenceProduct__c WHERE ReferenceGrouping__c= :payment.productGroup LIMIT 1];
            if(prods.size() > 0){

                
                
                if(prods[0].LAT_Product__r.LAT_BottlesPerBox__c > 0){
                    setTotalValue(payment, acc.Revenue_UF__c, prods[0].LAT_Product__r.LAT_BottlesPerBox__c);
                    setProductValue(payment, acc.Revenue_UF__c, prods[0].LAT_Product__r.LAT_BottlesPerBox__c);
                    setCashValue(payment);
                }

                ServiceResponse response = new ServiceResponse(payment);
                RestContext.response.addHeader('Content-Type', 'application/json');
                System.debug('Respuesta : ' + JSON.serialize(response));
                RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));
                RestContext.response.statusCode     = 200;
            } else {
                 //NOT FOUND PRODUCT
            }
            
        } else {
            //NOT FOUND ACCOUNT
        }
        
        
    }

    public class ServiceResponse {

		public LAT_ContractHandlerJSON.Payment result;

		public ServiceResponse(LAT_ContractHandlerJSON.Payment res) {
			result = res;
		}	

	}

    public static void setTotalValue(LAT_ContractHandlerJSON.Payment payment, String uf, Decimal bottlesPerBox){
        Map<Id, Double> productGroupMapCondComercial = new Map<Id, Double> ();
        productGroupMapCondComercial.put(payment.productGroup, payment.volumen/bottlesPerBox);
        LAT_ContractsCalculations cont = new LAT_ContractsCalculations();
        LAT_ContractsCalculations.TotalProductsCalculationEvent calculationsCondComercial =  cont.totalProductsCalculationEvents(productGroupMapCondComercial, uf, payment.distribuitorId, false);
        payment.valorEventoTotal = calculationsCondComercial.productsPerceivedValue;
    }

    public static void setProductValue(LAT_ContractHandlerJSON.Payment payment, String uf, Decimal bottlesPerBox){
        Map<Id, Double> productGroupMapCondComercial = new Map<Id, Double> ();
        Double volumenEnCajas = Math.floor(payment.volumen/bottlesPerBox);
        System.debug('%%% volumenEnCajas : ' + volumenEnCajas);
        productGroupMapCondComercial.put(payment.productGroup, volumenEnCajas);
        LAT_ContractsCalculations cont = new LAT_ContractsCalculations();
        LAT_ContractsCalculations.TotalProductsCalculationEvent calculationsCondComercial =  cont.totalProductsCalculationEvents(productGroupMapCondComercial, uf, payment.distribuitorId, false);

        payment.valorEventoProuto = calculationsCondComercial.productsPerceivedValue;
        payment.cajasProduto = volumenEnCajas;
    }
    public static void setCashValue(LAT_ContractHandlerJSON.Payment payment){
        if( payment.valorEventoTotal!=null && payment.valorEventoProuto!= null)
            payment.valorEventoCash = payment.valorEventoTotal - payment.valorEventoProuto;
    }

    /*
    @HttpPut
    global static void PUT() {
        RestRequest req = null;
        String response= null;
        Integer statusCode = null;
        LAT_ContractHandlerJSON.Payment payment = null;
        ServiceResponse serviceResponse = null;
        List<LAT_Contract2__c> contracts = null;

        System.debug('LAT_Rest_ComCondEventCalculations.PUT [] ->');

        req = RestContext.request;
        System.debug('LAT_Rest_ComCondEventCalculations.PUT [req : ' + req.requestBody+ ']');

        payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(req.requestBody.toString(), LAT_ContractHandlerJSON.Payment.class);
        RestContext.response.addHeader('Content-Type', 'application/json');
        serviceResponse = new ServiceResponse(payment);
        response = JSON.serialize(serviceResponse);
        statusCode = HTTP_SUCCESS_CODE;

        contracts = new LAT_ContractRepository().findByIds(new List<Id>{payment.contract});
        System.debug('LAT_Rest_ComCondEventCalculations.PUT [contracts : ' + contracts + ']');
        if(contracts.isEmpty()) {            
            ErrorResponse errorResponse = new ErrorResponse(CONTRACT_NOT_FOUND);
            setResponse(JSON.serialize(errorResponse), HTTP_ERROR_CODE_NOT_FOUND);
            return;             
        }

        LAT_Contract2__c contract = contracts.get(0);
        List<Account> accounts = new LAT_AccountRepository().findByIds(new List<Id>{payment.distribuitorId});
 
 
        System.debug('LAT_Rest_ComCondEventCalculations.PUT [accounts : ' + accounts + ']');
        if(accounts.isEmpty()) {
            
            ErrorResponse errorResponse = new ErrorResponse(ACCOUNT_NOT_FOUND);
            setResponse(JSON.serialize(errorResponse), HTTP_ERROR_CODE_NOT_FOUND);
            
            return;            
        }

        Account account = accounts[0];
        String uf = account.Revenue_UF__c;

        List<LAT_ReferenceProduct__c> referenceProducts = new LAT_ReferenceProductRepository().findByReferenceGrouping(new List<Id>{payment.productGroup});

        System.debug('LAT_Rest_ComCondEventCalculations.PUT [referenceProducts : ' + referenceProducts + ']');

        if(referenceProducts.isEmpty()) { 

            ErrorResponse errorResponse = new ErrorResponse(PRODUCT_NOT_FOUND);
            setResponse(JSON.serialize(errorResponse), HTTP_ERROR_CODE_NOT_FOUND);

            return;             
        }

        LAT_ReferenceProduct__c referenceProduct = referenceProducts.get(0);
        Decimal bottlesPerBox = referenceProduct.LAT_Product__r.LAT_BottlesPerBox__c;

        System.debug('LAT_Rest_ComCondEventCalculations.PUT [bottlesPerBox : ' + bottlesPerBox + ']');

        if(bottlesPerBox > 0) {
            try {                        
                doCalc(payment, uf, bottlesPerBox, contract);
                        
                serviceResponse = new ServiceResponse(payment);
                response = JSON.serialize(serviceResponse);
                setResponse(response, statusCode);
                return;
            } catch (Exception ex) {
                System.debug('LAT_Rest_ComCondEventCalculations.PUT [Ex : ' + Ex + ']');
                System.debug('LAT_Rest_ComCondEventCalculations.PUT [Ex : ' + Ex.getStackTraceString()+ ']');

                response = ex.getMessage();
                statusCode = HTTP_ERROR_CODE;
            }
        }
    
        setResponse(JSON.serialize(response), statusCode);
    }

    public static void doCalc(LAT_ContractHandlerJSON.Payment payment, String uf, Decimal bottlesPerBox, LAT_Contract2__c contract) {
        System.debug('LAT_Rest_ComCondEventCalculations.doCalc [payment : ' + payment + ' - uf : ' + uf + ' - : bottlesPerBox : ' + bottlesPerBox + ' - contract : ' + contract + '] ->');

        setTotalValue(payment, uf, bottlesPerBox, contract);
        setProductValue(payment, uf, bottlesPerBox, contract);
        setCashValue(payment);        

        System.debug('LAT_Rest_ComCondEventCalculations.doCalc [payment : ' + payment + ']');
        System.debug('LAT_Rest_ComCondEventCalculations.doCalc [] <-');
    }

    public static void setTotalValue(LAT_ContractHandlerJSON.Payment payment, String uf, Decimal bottlesPerBox, LAT_Contract2__c contract) {
        System.debug('LAT_Rest_ComCondEventCalculations.PsetTotalValueUT [payment : ' + payment + ' - uf : ' + uf + ' - : bottlesPerBox : ' + bottlesPerBox + ' - contract : ' + contract + '] ->');

        Map<Id, Double> productGroupMapCondComercial = new Map<Id, Double> ();
        // productGroupMapCondComercial.put(payment.productGroup, payment.volumen/bottlesPerBox);
        productGroupMapCondComercial.put(payment.productGroup, payment.bonusQuantity);

        LAT_ContractsCalculations.TotalProductsCalculationEvent calculationsProducer = new LAT_ContractCalculationsBuilder(contract, payment)
                                                                                            .forProducerCost(productGroupMapCondComercial)
                                                                                            .build();
                                    
        payment.valorEventoTotal = calculationsProducer.productsProducerCost;

        System.debug('LAT_Rest_ComCondEventCalculations.setTotalValue [payment.valorEventoTotal : ' + payment.valorEventoTotal + ']');
        System.debug('LAT_Rest_ComCondEventCalculations.setTotalValue [] <-');
    }

    public static void setProductValue(LAT_ContractHandlerJSON.Payment payment, String uf, Decimal bottlesPerBox, LAT_Contract2__c contract) {
        Map<Id, Double> productGroupMapCondComercial = new Map<Id, Double> ();        

        Double volumenEnCajas = Math.floor(payment.volumen/bottlesPerBox);
        productGroupMapCondComercial.put(payment.productGroup, volumenEnCajas);

        LAT_ContractsCalculations.TotalProductsCalculationEvent calculationsProducer = new LAT_ContractCalculationsBuilder(contract, payment)
                                                                                            .forProducerCost(productGroupMapCondComercial)
                                                                                            .build();

        payment.valorEventoProuto = calculationsProducer.productsProducerCost;
        payment.cajasProduto = volumenEnCajas;
    }

    public static void setCashValue(LAT_ContractHandlerJSON.Payment payment) {
        if( payment.valorEventoTotal != null && payment.valorEventoProuto != null)
            payment.valorEventoCash = payment.valorEventoTotal - payment.valorEventoProuto;
    }

    public class ServiceResponse {
		public LAT_ContractHandlerJSON.Payment result;

		public ServiceResponse(LAT_ContractHandlerJSON.Payment res) {
			result = res;
		}	
    }

    @testVisible
    private static void setResponse(String responseBody, Integer statusCode) {
        RestContext.response.responseBody = Blob.valueOf(responseBody);
        RestContext.response.statusCode = statusCode;      
    }

    public class ErrorResponse {
        private String message;
        private String errorCode;
        private String code;
        private String stacktrace;
        private String label_message;

        public ErrorResponse(String errorMsg) {
            this.message = errorMsg;
            this.errorCode = '';
            this.code = '';
            this.stacktrace = '';
            this.label_message = '';
        }        
    }
    */
}