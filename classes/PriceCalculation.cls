//Generated by wsdl2apex

public class PriceCalculation {
    public class port {
        //public String endpoint_x = 'http://205.207.154.84/CRM/PriceCalculation/PriceCalculationProxy';
        public String endpoint_x;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://pernod-ricard.com/soa/sb/crm/salesorder/PriceCalculation', 'PriceCalculation', 'http://www.pernod-ricard.com/soa/crm/salesorder/pricecalculation/types', 'PriceCalculationTypes'};
        
       
        public PriceCalculationTypes.PriceCalculationResponseType operation(PriceCalculationTypes.ClientInfoType client,PriceCalculationTypes.PriceCalculationHeaderRequestType header,PriceCalculationTypes.PriceCalculationItemRequestType[] item) {
            PriceCalculationTypes.PriceCalculationRequestType request_x = new PriceCalculationTypes.PriceCalculationRequestType();
            PriceCalculationTypes.PriceCalculationResponseType response_x;
            request_x.client = client;
            request_x.header = header;
            request_x.item = item;

            CS001_JDEInterfaceCredentials__c cred = LAT_WS_Utils.getHeaderKey(client.country);

            this.inputHttpHeaders_x = new Map <String, String>();
            this.inputHttpHeaders_x.put('api_key',cred.MASHERY_HEADER_KEY__c);
            
            Map<String, PriceCalculationTypes.PriceCalculationResponseType> response_map_x = new Map<String, PriceCalculationTypes.PriceCalculationResponseType>();
            response_map_x.put('response_x', response_x);
            
            //EndPoint parameterizable
	        try{endpoint_x = cred.EndPoint_PriceCalculation__c;}catch(exception e){}
            system.debug('aaaaaa '  + endpoint_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://pernod-ricard.com/soa/sb/crm/salesorder/PriceCalculation/operation',
              'http://www.pernod-ricard.com/soa/crm/salesorder/pricecalculation/types',
              'priceCalculationRequest',
              'http://www.pernod-ricard.com/soa/crm/salesorder/pricecalculation/types',
              'priceCalculationResponse',
              'PriceCalculationTypes.PriceCalculationResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}