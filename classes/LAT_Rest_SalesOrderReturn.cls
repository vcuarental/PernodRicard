@RestResource(urlMapping='/LAT_Rest_SalesOrderReturn/*')
global with sharing class  LAT_Rest_SalesOrderReturn {

	@HttpPost
    global static void POST() {
    	RestRequest req = RestContext.request;
        System.debug('%%%%%% req.requestBody.toString() : ' + req.requestBody.toString());
    	SOR_Body incomingRequestBody = (SOR_Body)System.JSON.deserialize(req.requestBody.toString(), SOR_Body.class);
        System.debug('%%%%%% incomingRequestBody : ' + incomingRequestBody);
        System.debug('%%%%%%  incomingRequestBody.NR_order_JDE : ' + incomingRequestBody.orderNumber);
        System.debug('%%%%%%  incomingRequestBody.orderType : ' + incomingRequestBody.orderType);
        System.debug('%%%%%%  incomingRequestBody.companyCode : ' + incomingRequestBody.companyCode);
        
        String sendToSORbyONF_Result =send_SORbyONF_Request(incomingRequestBody.orderType, incomingRequestBody.orderNumber, incomingRequestBody.companyCode);

		//LAT_JSONGetSalesOrderHandler.GetSalesOrderResponse order = LAT_GetOrderDetailHandler.getOrderDetailsFromJDE(String.valueof(incomingRequestBody.orderNumber), incomingRequestBody.orderType, incomingRequestBody.companyCode).body.getSalesOrderResponse;
        Integer returnCode = 0;
        String returnMessage = '';
        incomingRequestBody.priceComponents = 'TEST TEST';
        //generatePriceComponentTable(incomingRequestBody);
		//TODO: ver que pasa con los campos puestos duros:NR_customer_order, note1, note2, cd_order_status (viene un string ('ED') y esperamos un Int), salesOrderSource, retentionReason (puede ser que sea el orderStatus ya que el string coincide)
        //TODO: ver que pasa con los campos null : DT_Delivery, InoviceDate, purchaseOrderUntil 
        //System.debug('order en el SOR : ' + String.valueOf(order));
        /*Integer respuestaSOR = SalesOrderReturn.ETL_SalesOrderLoadMigrated(getCountryNumber(order.orderCompany), null, order.externalOrderNumber, order.orderNumber, order.shipTo.entityInfo.entityId, order.shipTo.entityInfo.entityId, 'NR_customer_order', order.orderCompany, 'note1', 'note2', null, order.freightHandlingCode, order.dateOrder, null, order.orderType, null /*order.orderStatus* /, String.valueOf(order.businessUnit), 'E', incomingRequestBody.priceComponents, returnCode, returnMessage, null, 'ED', order.paymentTermsCode, incomingRequestBody.listaItem);
        System.debug('%%%%%% respuestaSOR: ' + respuestaSOR);
        */
        assignJDE_Order_Number(incomingRequestBody.orderNumberForeign, String.valueOf(incomingRequestBody.orderNumber));
        ServiceResponse res = new ServiceResponse(JSON.serialize(incomingRequestBody));
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(incomingRequestBody));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        } 

    }

    public static void assignJDE_Order_Number(String orderNumberForeign, String orderNumber){
        List<LAT_Opportunity__c> opps = [SELECT Id FROM LAT_Opportunity__c WHERE Id = :orderNumberForeign];
        if(opps.size() >0){
            LAT_Opportunity__c toUpdate = opps[0];
            toUpdate.LAT_NROrderJDE__c = orderNumber;
            update toUpdate;
        }
    }

    public static String send_SORbyONF_Request(String orderType, Integer orderNumber, String companyCode){
        CS001_JDEInterfaceCredentials__c cred = getCS001JDECredentials(companyCode);
        DOM.Document doc = getSORyONF_Document(orderType, orderNumber, companyCode, cred);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        //String url = 'https://z-bin.herokuapp.com/1hp7t211';
        //String url = 'http://soaqa.pramericas.com/soa-infra/services/Core-CRM/SORByONFV3/salesorderloadbpelp_client?wsdl';
        String url = cred.Endpoint_SORbyONF__c;

        req.setEndpoint(url);
        System.debug('URL a la cual viaja: ' + url);
        req.setHeader('Content-Type', 'text/xml');

        System.debug('Doc generado: ' + doc.toXmlString());

        req.setBodyDocument(doc);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return 'ok';
    }

    public static DOM.Document getSORyONF_Document(String orderType, Integer orderNumber, String country, CS001_JDEInterfaceCredentials__c cred){
        
        String ns1 = 'http://www.pernod-ricard.com/soa/crm/salesorder/load/types';
        DOM.Document doc = new DOM.Document();
        Dom.XmlNode envelope = doc.createRootElement('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/', 'soap');
        Dom.XmlNode body = envelope.addChildElement('soap:Body', null, null);
        Dom.XmlNode salesOrderLoadRequest = body.addChildElement('salesOrderLoadRequest', ns1, 'ns1');
        salesOrderLoadRequest.addChildElement('ns1:CountryCode', null, null).
                addTextNode(cred.Country__c);
        salesOrderLoadRequest.addChildElement('ns1:CompanyCode', null, null).
                addTextNode(cred.PriceCalcCompanyParam__c);
        salesOrderLoadRequest.addChildElement('ns1:OrderNumber', null, null).
                addTextNode(String.valueOf(orderNumber));
        salesOrderLoadRequest.addChildElement('ns1:OrderType', null, null).
                addTextNode(orderType);
        salesOrderLoadRequest.addChildElement('ns1:apiVersion', null, null).
                addTextNode('2');
        return doc;
    }       

    public static CS001_JDEInterfaceCredentials__c getCS001JDECredentials(String companyCode){
        System.debug('%%% companyCode: ' + companyCode);
        switch on companyCode {
            when '00200' {       
                return CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
            }   
            when '00500'{       
                return CS001_JDEInterfaceCredentials__c.getInstance('Uruguay');
            }  
            when '00100' {       
                return CS001_JDEInterfaceCredentials__c.getInstance('Argentina');
            }  
            when '00902' {       
                return CS001_JDEInterfaceCredentials__c.getInstance('México');
            } 
        }
        return null;

    } 
    public class SOR_Body{
    	public Integer  country 									{get;set;}//
    	public String   cd_salesman 								{get;set;}
    	public String   orderNumberForeign 					        {get;set;}//
    	public Integer  orderNumber								    {get;set;}//
    	public Integer  customerCode 							    {get;set;}//
    	public Integer  customerShippingCode 					    {get;set;}//
    	public String   customerBuyOrder					        {get;set;}//
    	public String   companyCode 					            {get;set;}//
        public String   note1 								        {get;set;}//
        public String   note2								        {get;set;}//
        public String   promisedDate								{get;set;}//
        public String   freightType									{get;set;}//
        public String   orderRequestDate							{get;set;}//
        public String   invoiceDate							        {get;set;}//
        public String   orderType								    {get;set;}//
        public Integer  cd_order_status							    {get;set;}
        public String   businessUnit								{get;set;}//
        public String   salesOrderSource							{get;set;}//
        public String   priceComponents							    {get;set;}
        public Integer  returnCode								    {get;set;}
        public String   returnMessage								{get;set;}
        public String   purchaseOrderUntil						    {get;set;}//
        public String   orderOnHold							        {get;set;}//
        public String   paymentTerm								    {get;set;}//

        public List<SalesOrderReturn.SalesOrderItem> listaItem	{get;set;}
    }
    /*
	public static Integer getCountryNumber(String companyCode){
		Integer retorno = 0;
		if(companyCode!= null){
			if(companyCode.contains('100')) retorno = 6;
			if(companyCode.contains('200')) retorno = 1;
			if(companyCode.contains('500')) retorno = 5;
			if(companyCode.contains('902')) retorno = 12;
		}
		System.debug('%%%%% getCountryNumber :' + retorno);
		return retorno;
	}*/ 

    public class ServiceResponse {

        public ServiceResponse(LAT_OpportunityHandlerJSON pedido) {
            success = true;
            message = JSON.serialize(pedido);
        }
        /*
		public ServiceResponse(LAT_JSONGetSalesOrderHandler.GetSalesOrderResponse pedido) {
            success = true;
            message = JSON.serialize(pedido);
        }
*/
        public ServiceResponse(String pedido) {
            success = true;
            Id = pedido;
        }

        public ServiceResponse(String msg, Boolean bool) {
            success = bool;
            message = msg;
        }

        public ServiceResponse(String msg, String error, Boolean bool) {
            success = bool;
            message = msg;
            errorCode = error;
        }
        public String Id;
        public Boolean success;
        public String message;
        public String errorCode;
    }

    /*
    public static void generatePriceComponentTable(SOR_Body body){
        System.debug('%%%%%% generatePriceComponentTable ');
        Map<String, SalesOrderReturn.priceComponent> mapHeaderComponentsByName = new Map<String, SalesOrderReturn.priceComponent>();
        for(SalesOrderReturn.SalesOrderItem  item : body.listaItem){
            System.debug('%%%%%% generatePriceComponentTable 2');
            
            Map<String, SalesOrderReturn.priceComponent> mapComponentsByName = new Map<String, SalesOrderReturn.priceComponent>();
            System.debug('%%%%%% item.priceComponentList != null:' );
            System.debug('%%%%%% item.priceComponentList != null:' + item.priceComponentsList != null);
            System.debug('%%%%%% body.Country == 1:' + (body.Country == 1));
            if(item.priceComponentsList != null){

                System.debug('%%%%%% generatePriceComponentTable 3');
                for(SalesOrderReturn.priceComponent comp : item.priceComponentsList){
                    comp.quantity = item.billedTotalQuantity;
                    mapComponentsByName.put(comp.compName, comp);
                }
                switch on body.Country {
                    when 1 {       
                        procesBrasilLine(item, mapComponentsByName, mapHeaderComponentsByName);
                    }   
                    when 12 {       
                        procesMexicoLine(item, mapComponentsByName, mapHeaderComponentsByName);
                    }  
                    when 6 {       
                        procesArgentinaLine(item, mapComponentsByName, mapHeaderComponentsByName);
                    }  
                    when 5 {       
                        procesUruguayLine(item, mapComponentsByName, mapHeaderComponentsByName);
                    } 
                } 
                
                
            }

        }
        if(mapHeaderComponentsByName.size() > 0){
            switch on body.Country {
                when 1 {       
                    procesBrasiHeader(body, mapHeaderComponentsByName);
                }   
                when 12 {       
                    procesMexicoHeader(body, mapHeaderComponentsByName);
                }  
                when 6 {       
                    procesArgentinaHeader(body, mapHeaderComponentsByName);
                }  
                when 5 {       
                    procesUruguayHeader(body, mapHeaderComponentsByName);
                } 
            } 
            
        }


    }

    public static void procesBrasilLine(SalesOrderReturn.SalesOrderItem item, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName, Map<String, SalesOrderReturn.priceComponent> mapHeaderComponentsByName){
        String linePriceComponentes  = '';
        Decimal pBase;
        Decimal pNbase3;
        Decimal pSbst;
        Decimal pIpi;
        if(mapComponentsByName.get('PBASE') != null){
            System.debug('%%% mapComponentsByName.get(\'PBASE\').compUnitPrice: ' + mapComponentsByName.get('PBASE').compUnitPrice);
            System.debug('%%% mapComponentsByName.get(\'PBASE\').quantity: ' + mapComponentsByName.get('PBASE').quantity);
            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            linePriceComponentes += 'Preço Base|1|100,00|' + pBase.setScale(2) + '|' + (pBase * mapComponentsByName.get('PBASE').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('PBASE') == null){
                mapHeaderComponentsByName.put('PBASE', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('PBASE');
            headerItem.compName = 'PBASE';
            headerItem.compUnitPrice += pBase;
            headerItem.compHeaderTotalPrice += pBase * mapComponentsByName.get('PBASE').quantity;

        }
        if(mapComponentsByName.get('FLEX') != null){
            Decimal pFlex = mapComponentsByName.get('FLEX').compUnitPrice;
            linePriceComponentes += 'Flex|1|' + (pFlex*100/pBase).setScale(2) +'|' + pFlex.setScale(2) + '|' + (pFlex * mapComponentsByName.get('FLEX').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('FLEX') == null){
                mapHeaderComponentsByName.put('FLEX', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('FLEX');
            headerItem.compName = 'FLEX';
            headerItem.compUnitPrice += pFlex;
            headerItem.compHeaderTotalPrice += pFlex * mapComponentsByName.get('FLEX').quantity;
        }
        linePriceComponentes += 'Condição Cash|1|0,00|0,00|0,00#';
        if(mapComponentsByName.get('ICMSGS') != null){
            Decimal pIcms = mapComponentsByName.get('ICMSGS').compUnitPrice;
            linePriceComponentes += 'ICMS Gross Sales|1|' + (pIcms*100/pBase).setScale(2) +'|' + pIcms.setScale(2) + '|' + (pIcms * mapComponentsByName.get('ICMSGS').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('ICMSGS') == null){
                mapHeaderComponentsByName.put('ICMSGS', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('ICMSGS');
            headerItem.compName = 'ICMSGS';
            headerItem.compUnitPrice += pIcms;
            headerItem.compHeaderTotalPrice += pIcms * mapComponentsByName.get('ICMSGS').quantity;
        }
        if(mapComponentsByName.get('CANAL') != null){
            Decimal pCanal = mapComponentsByName.get('CANAL').compUnitPrice;
            linePriceComponentes += 'Desconto Canal|1|' + (pCanal*100/pBase).setScale(2) +'|' + pCanal.setScale(2) + '|' + (pCanal * mapComponentsByName.get('CANAL').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('CANAL') == null){
                mapHeaderComponentsByName.put('CANAL', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('CANAL');
            headerItem.compName = 'CANAL';
            headerItem.compUnitPrice += pCanal;
            headerItem.compHeaderTotalPrice += pCanal * mapComponentsByName.get('CANAL').quantity;
        }
        if(mapComponentsByName.get('NBASE3') != null){
            pNbase3 = mapComponentsByName.get('NBASE3').compUnitPrice;
            linePriceComponentes += 'Valor Mercadoria|1|' + (pNbase3*100/pBase).setScale(2) +'|' + pNbase3.setScale(2) + '|' + (pNbase3 * mapComponentsByName.get('NBASE3').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('NBASE3') == null){
                mapHeaderComponentsByName.put('NBASE3', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('NBASE3');
            headerItem.compName = 'NBASE3';
            headerItem.compUnitPrice += pNbase3;
            headerItem.compHeaderTotalPrice += pNbase3 * mapComponentsByName.get('NBASE3').quantity;
        }
        if(mapComponentsByName.get('ICMS') != null){
            Decimal pIcms = mapComponentsByName.get('ICMS').compUnitPrice;
            linePriceComponentes += 'ICMS|1|' + (pIcms*100/pBase).setScale(2) +'|' + pIcms.setScale(2) + '|' + (pIcms * mapComponentsByName.get('ICMS').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('ICMS') == null){
                mapHeaderComponentsByName.put('ICMS', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('ICMS');
            headerItem.compName = 'ICMS';
            headerItem.compUnitPrice += pIcms;
            headerItem.compHeaderTotalPrice += pIcms * mapComponentsByName.get('ICMS').quantity;
        }
        if(mapComponentsByName.get('PIS') != null){
            Decimal pPis = mapComponentsByName.get('PIS').compUnitPrice;
            linePriceComponentes += 'PIS|1|' + (pPis*100/pBase).setScale(2) +'|' + pPis.setScale(2) + '|' + (pPis * mapComponentsByName.get('PIS').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('PIS') == null){
                mapHeaderComponentsByName.put('PIS', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('PIS');
            headerItem.compName = 'PIS';
            headerItem.compUnitPrice += pPis;
            headerItem.compHeaderTotalPrice += pPis * mapComponentsByName.get('PIS').quantity;
        }
        if(mapComponentsByName.get('COFINS') != null){
            Decimal pCofins = mapComponentsByName.get('COFINS').compUnitPrice;
            linePriceComponentes += 'COFINS|1|' + (pCofins*100/pBase).setScale(2) +'|' + pCofins.setScale(2) + '|' + (pCofins * mapComponentsByName.get('COFINS').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('COFINS') == null){
                mapHeaderComponentsByName.put('COFINS', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('COFINS');
            headerItem.compName = 'COFINS';
            headerItem.compUnitPrice += pCofins;
            headerItem.compHeaderTotalPrice += pCofins * mapComponentsByName.get('COFINS').quantity;
        }
        if(mapComponentsByName.get('IPI') != null){
            pIpi = mapComponentsByName.get('IPI').compUnitPrice;
            linePriceComponentes += 'IPI|1|' + (pIpi*100/pBase).setScale(2) +'|' + pIpi.setScale(2) + '|' + (pIpi * mapComponentsByName.get('IPI').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('IPI') == null){
                mapHeaderComponentsByName.put('IPI', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('IPI');
            headerItem.compName = 'IPI';
            headerItem.compUnitPrice += pIpi;
            headerItem.compHeaderTotalPrice += pIpi * mapComponentsByName.get('IPI').quantity;
        }
        if(mapComponentsByName.get('SBST') != null){
            pSbst = mapComponentsByName.get('SBST').compUnitPrice;
            linePriceComponentes += 'Substitução Tributaria|1|' + (pSbst*100/pBase).setScale(2) +'|' + pSbst.setScale(2) + '|' + (pSbst * mapComponentsByName.get('SBST').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('SBST') == null){
                mapHeaderComponentsByName.put('SBST', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('SBST');
            headerItem.compName = 'SBST';
            headerItem.compUnitPrice += pSbst;
            headerItem.compHeaderTotalPrice += pSbst * mapComponentsByName.get('SBST').quantity;
        }
        if(mapComponentsByName.get('NBASE3') != null){
            pNbase3 = mapComponentsByName.get('NBASE3').compUnitPrice;
            linePriceComponentes += 'NBASE3|1|' + (pNbase3*100/pBase).setScale(2) +'|' + pNbase3.setScale(2) + '|' + (pNbase3 * mapComponentsByName.get('NBASE3').quantity).setScale(2) + '#';
        }

        linePriceComponentes += 'Valor Total NF|1|' + ((pNbase3+pSbst+pIpi)*100/pBase).setScale(2) +'|' + (pNbase3+pSbst+pIpi).setScale(2) + '|' + ((pNbase3+pSbst+pIpi) * mapComponentsByName.get('NBASE3').quantity).setScale(2) + '';
        System.debug('%%%%%% item.priceComponents antes: '+ linePriceComponentes);
        linePriceComponentes = linePriceComponentes.replace('.', ',');
        System.debug('%%%%%% item.priceComponents despues: '+ linePriceComponentes);
        item.priceComponents = linePriceComponentes;
        
    }

    public static void procesBrasiHeader(SOR_Body body, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName){
        String headerPriceComponentes = '';
        Decimal pBase;
        Decimal pNbase3;
        Decimal pHeaderNbase3;
        Decimal pSbst;
        Decimal pHeaderSbst;
        Decimal pIpi;
        Decimal pHeaderIpi;
        if(mapComponentsByName.get('PBASE') != null){

            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            headerPriceComponentes += 'Preço Base|1|100,00|' + pBase.setScale(2) + '|' + mapComponentsByName.get('PBASE').compHeaderTotalPrice.setScale(2) + '#';

        }
        if(mapComponentsByName.get('FLEX') != null){
            Decimal pFlex = mapComponentsByName.get('FLEX').compUnitPrice;
            headerPriceComponentes += 'Flex|1|' + (pFlex*100/pBase).setScale(2) +'|' + pFlex.setScale(2) + '|' + mapComponentsByName.get('FLEX').compHeaderTotalPrice.setScale(2) + '#';
            
        }
        headerPriceComponentes += 'Condição Cash|1|0,00|0,00|0,00#';
        if(mapComponentsByName.get('ICMSGS') != null){
            Decimal pIcms = mapComponentsByName.get('ICMSGS').compUnitPrice;
            headerPriceComponentes += 'ICMS Gross Sales|1|' + (pIcms*100/pBase).setScale(2) +'|' + pIcms.setScale(2) + '|' + mapComponentsByName.get('ICMSGS').compHeaderTotalPrice.setScale(2) + '#';
        }
        if(mapComponentsByName.get('CANAL') != null){
            Decimal pCanal = mapComponentsByName.get('CANAL').compUnitPrice;
            headerPriceComponentes += 'Desconto Canal|1|' + (pCanal*100/pBase).setScale(2) +'|' + pCanal.setScale(2) + '|' + mapComponentsByName.get('CANAL').compHeaderTotalPrice.setScale(2) + '#';
        }
        if(mapComponentsByName.get('NBASE3') != null){
            pNbase3 = mapComponentsByName.get('NBASE3').compUnitPrice;
            headerPriceComponentes += 'Valor Mercadoria|1|' + (pNbase3*100/pBase).setScale(2) +'|' + pNbase3.setScale(2) + '|' + mapComponentsByName.get('NBASE3').compHeaderTotalPrice.setScale(2) + '#';
        }
        if(mapComponentsByName.get('ICMS') != null){
            Decimal pIcms = mapComponentsByName.get('ICMS').compUnitPrice;
            headerPriceComponentes += 'ICMS|1|' + (pIcms*100/pBase).setScale(2) +'|' + pIcms.setScale(2) + '|' + mapComponentsByName.get('ICMS').compHeaderTotalPrice.setScale(2) + '#';
            
        }
        if(mapComponentsByName.get('PIS') != null){
            Decimal pPis = mapComponentsByName.get('PIS').compUnitPrice;
            headerPriceComponentes += 'PIS|1|' + (pPis*100/pBase).setScale(2) +'|' + pPis.setScale(2) + '|' + mapComponentsByName.get('PIS').compHeaderTotalPrice.setScale(2) + '#';
            
        }
        if(mapComponentsByName.get('COFINS') != null){
            Decimal pCofins = mapComponentsByName.get('COFINS').compUnitPrice;
            headerPriceComponentes += 'COFINS|1|' + (pCofins*100/pBase).setScale(2) +'|' + pCofins.setScale(2) + '|' + mapComponentsByName.get('COFINS').compHeaderTotalPrice.setScale(2) + '#';

        }
        if(mapComponentsByName.get('IPI') != null){
            pIpi = mapComponentsByName.get('IPI').compUnitPrice;
            pHeaderIpi = mapComponentsByName.get('IPI').compHeaderTotalPrice;
            headerPriceComponentes += 'IPI|1|' + (pIpi*100/pBase).setScale(2) +'|' + pIpi.setScale(2) + '|' + mapComponentsByName.get('IPI').compHeaderTotalPrice.setScale(2) + '#';
           
        }
        if(mapComponentsByName.get('SBST') != null){
            pSbst = mapComponentsByName.get('SBST').compUnitPrice;
            pHeaderSbst = mapComponentsByName.get('SBST').compHeaderTotalPrice;
            headerPriceComponentes += 'Substitução Tributaria|1|' + (pSbst*100/pBase).setScale(2) +'|' + pSbst.setScale(2) + '|' + mapComponentsByName.get('SBST').compHeaderTotalPrice.setScale(2) + '#';

        }
        if(mapComponentsByName.get('NBASE3') != null){
            pNbase3 = mapComponentsByName.get('NBASE3').compUnitPrice;
            pHeaderNbase3 = mapComponentsByName.get('NBASE3').compHeaderTotalPrice;
            headerPriceComponentes += 'NBASE3|1|' + (pNbase3*100/pBase).setScale(2) +'|' + pNbase3.setScale(2) + '|' + mapComponentsByName.get('NBASE3').compHeaderTotalPrice.setScale(2) + '#';
        }

        headerPriceComponentes += 'Valor Total NF|1|' + ((pNbase3+pSbst+pIpi)*100/pBase).setScale(2) +'|' + (pNbase3+pSbst+pIpi).setScale(2) + '|' + (pHeaderNbase3+pHeaderSbst+pHeaderIpi).setScale(2) + '';
        System.debug('%%%%%% item.priceComponents antes: '+ headerPriceComponentes);
        headerPriceComponentes = headerPriceComponentes.replace('.', ',');
        System.debug('%%%%%% item.priceComponents despues: '+ headerPriceComponentes);
        body.priceComponents = headerPriceComponentes;
        
    }

    public static void procesMexicoLine(SalesOrderReturn.SalesOrderItem item, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName, Map<String, SalesOrderReturn.priceComponent> mapHeaderComponentsByName){
        String linePriceComponentes = '';
        Decimal pBase;
        Decimal pCanal2;
        Decimal pIva;
        Decimal pIeps;
        if(mapComponentsByName.get('PBASE') != null){
            System.debug('%%% mapComponentsByName.get(\'PBASE\').compUnitPrice: ' + mapComponentsByName.get('PBASE').compUnitPrice);
            System.debug('%%% mapComponentsByName.get(\'PBASE\').quantity: ' + mapComponentsByName.get('PBASE').quantity);
            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            linePriceComponentes += 'Precio de Lista|1|100,00|' + pBase.setScale(2) + '|' + (pBase * mapComponentsByName.get('PBASE').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('PBASE') == null){
                mapHeaderComponentsByName.put('PBASE', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('PBASE');
            headerItem.compName = 'PBASE';
            headerItem.compUnitPrice += pBase;
            headerItem.compHeaderTotalPrice += pBase * mapComponentsByName.get('PBASE').quantity;

        }
        if(mapComponentsByName.get('CANAL2') != null){
            pCanal2 = mapComponentsByName.get('CANAL2').compUnitPrice;
            linePriceComponentes += 'Descuento de Canal 2|1|' + (pCanal2*100/pBase).setScale(2) +'|' + pCanal2.setScale(2) + '|' + (pCanal2 * mapComponentsByName.get('CANAL2').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('CANAL2') == null){
                mapHeaderComponentsByName.put('CANAL2', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('CANAL2');
            headerItem.compName = 'CANAL2';
            headerItem.compUnitPrice += pCanal2;
            headerItem.compHeaderTotalPrice += pCanal2 * mapComponentsByName.get('CANAL2').quantity;
        }
        linePriceComponentes += 'Distribución Horizontal RTDs|1|0,00|0,00|0,00#';
        linePriceComponentes += 'Descuento Cruce de Anden Cte|1|0,00|0,00|0,00#';
        linePriceComponentes += 'Descuento Extraordinario Temporal|1|0,00|0,00|0,00#';
        linePriceComponentes += 'Sub Total|1|' + ((pBase+pCanal2)*100/pBase).setScale(2) +'|' + (pBase+pCanal2).setScale(2) + '|' + ((pBase+pCanal2) * mapComponentsByName.get('PBASE').quantity).setScale(2) + '#';

        if(mapComponentsByName.get('IEPS') != null){
            pIeps = mapComponentsByName.get('IEPS').compUnitPrice;
            linePriceComponentes += 'IEPS|1|' + (pIeps*100/pBase).setScale(2) +'|' + pIeps.setScale(2) + '|' + (pIeps * mapComponentsByName.get('IEPS').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('IEPS') == null){
                mapHeaderComponentsByName.put('IEPS', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('IEPS');
            headerItem.compName = 'IEPS';
            headerItem.compUnitPrice += pIeps;
            headerItem.compHeaderTotalPrice += pIeps * mapComponentsByName.get('IEPS').quantity;
        }
        if(mapComponentsByName.get('IVA') != null){
            pIva = mapComponentsByName.get('IVA').compUnitPrice;
            linePriceComponentes += 'IVA|1|' + (pIva*100/pBase).setScale(2) +'|' + pIva.setScale(2) + '|' + (pIva * mapComponentsByName.get('IVA').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('IVA') == null){
                mapHeaderComponentsByName.put('IVA', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('IVA');
            headerItem.compName = 'IVA';
            headerItem.compUnitPrice += pIva;
            headerItem.compHeaderTotalPrice += pIva * mapComponentsByName.get('IVA').quantity;
        }

        linePriceComponentes += 'Importe Total|1|' + ((pBase+pCanal2+pIva+pIeps)*100/pBase).setScale(2) +'|' + (pBase+pCanal2+pIva+pIeps).setScale(2) + '|' + ((pBase+pCanal2+pIva+pIeps) * mapComponentsByName.get('PBASE').quantity).setScale(2) + '';
        System.debug('%%%%%% item.priceComponents antes: '+ linePriceComponentes);
        linePriceComponentes = linePriceComponentes.replace('.', ',');
        System.debug('%%%%%% item.priceComponents despues: '+ linePriceComponentes);
        item.priceComponents = linePriceComponentes;
        
    }

    public static void procesMexicoHeader(SOR_Body body, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName){
        String headerPriceComponentes = '';
        Decimal pBase;
        Decimal pHeaderBase;
        Decimal pCanal2;
        Decimal pHeaderCanal2;
        Decimal pIva;
        Decimal pHeaderIva;
        Decimal pIeps;
        Decimal pHeaderIeps;
        if(mapComponentsByName.get('PBASE') != null){
            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            pHeaderBase = mapComponentsByName.get('PBASE').compHeaderTotalPrice;
            headerPriceComponentes += 'Precio de Lista|1|100,00|' + pBase.setScale(2) + '|' + pHeaderBase.setScale(2) + '#';

        }
        if(mapComponentsByName.get('CANAL2') != null){
            pCanal2 = mapComponentsByName.get('CANAL2').compUnitPrice;
            pHeaderCanal2 = mapComponentsByName.get('CANAL2').compHeaderTotalPrice;
            headerPriceComponentes += 'Descuento de Canal 2|1|' + (pCanal2*100/pBase).setScale(2) +'|' + pCanal2.setScale(2) + '|' + pHeaderCanal2.setScale(2) + '#';
            
        }
        headerPriceComponentes += 'Distribución Horizontal RTDs|1|0,00|0,00|0,00#';
        headerPriceComponentes += 'Descuento Cruce de Anden Cte|1|0,00|0,00|0,00#';
        headerPriceComponentes += 'Descuento Extraordinario Temporal|1|0,00|0,00|0,00#';
        headerPriceComponentes += 'Sub Total|1|' + ((pBase+pCanal2)*100/pBase).setScale(2) +'|' + (pBase+pCanal2).setScale(2) + '|' + (pHeaderBase + pHeaderCanal2).setScale(2) + '#';
    
        if(mapComponentsByName.get('IEPS') != null){
            pIeps = mapComponentsByName.get('IEPS').compUnitPrice;
            pHeaderIeps = mapComponentsByName.get('IEPS').compHeaderTotalPrice;
            headerPriceComponentes += 'IEPS|1|' + (pIeps*100/pBase).setScale(2) +'|' + pIeps.setScale(2) + '|' + pHeaderIeps.setScale(2) + '#';
            
        }    
        if(mapComponentsByName.get('IVA') != null){
            pIva = mapComponentsByName.get('IVA').compUnitPrice;
            pHeaderIva = mapComponentsByName.get('IVA').compHeaderTotalPrice;
            headerPriceComponentes += 'IVA|1|' + (pIva*100/pBase).setScale(2) +'|' + pIva.setScale(2) + '|' + pHeaderIva.setScale(2) + '#';
            
        }
        headerPriceComponentes += 'Importe Total|1|' + ((pBase+pCanal2+pIva+pIeps)*100/pBase).setScale(2) +'|' + (pBase+pCanal2+pIva+pIeps).setScale(2) + '|' + (pBase+pCanal2+pHeaderIva+pHeaderIeps).setScale(2) + '';
        System.debug('%%%%%% item.priceComponents antes: '+ headerPriceComponentes);
        headerPriceComponentes = headerPriceComponentes.replace('.', ',');
        System.debug('%%%%%% item.priceComponents despues: '+ headerPriceComponentes);
        body.priceComponents = headerPriceComponentes;
        
    }

    public static void procesArgentinaLine(SalesOrderReturn.SalesOrderItem item, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName, Map<String, SalesOrderReturn.priceComponent> mapHeaderComponentsByName){
        String linePriceComponentes = '';
        Decimal pBase;
        Decimal pCanal2 = 0;
        Decimal pBonif = 0;
        Decimal pFreegood = 0;
        Decimal pLista = 0;
        Decimal pSfa = 0;
        if(mapComponentsByName.get('PBASE') != null){

            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            linePriceComponentes += 'Precio de Lista|1|100,00|' + pBase.setScale(2) + '|' + (pBase * mapComponentsByName.get('PBASE').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('PBASE') == null){
                mapHeaderComponentsByName.put('PBASE', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('PBASE');
            headerItem.compName = 'PBASE';
            headerItem.compUnitPrice += pBase;
            headerItem.compHeaderTotalPrice += pBase * mapComponentsByName.get('PBASE').quantity;

        }
        if(mapComponentsByName.get('BASE') != null){
            pCanal2 = mapComponentsByName.get('BASE').compUnitPrice;
            linePriceComponentes += 'Bonificación|1|' + (pCanal2*100/pBase).setScale(2) +'|' + pCanal2.setScale(2) + '|' + (pCanal2 * mapComponentsByName.get('BASE').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('BASE') == null){
                mapHeaderComponentsByName.put('BASE', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('BASE');
            headerItem.compName = 'BASE';
            headerItem.compUnitPrice += pCanal2;
            headerItem.compHeaderTotalPrice += pCanal2 * mapComponentsByName.get('BASE').quantity;
        }
        if(mapComponentsByName.get('BONIF') != null){
            pBonif =  mapComponentsByName.get('BONIF').compUnitPrice;
        }
        if(mapComponentsByName.get('FREEGOOD') != null){
            pFreegood =  mapComponentsByName.get('FREEGOOD').compUnitPrice;
        }

        Decimal bonifFreegood = pBonif+pFreegood;
        linePriceComponentes += 'Bonificación Merc Gratis|1|' + (bonifFreegood*100/pBase).setScale(2) +'|' +bonifFreegood.setScale(2) + '|' + (bonifFreegood * mapComponentsByName.get('BASE').quantity).setScale(2) + '#';
        if(mapHeaderComponentsByName.get('BONIF_FREEGOOD') == null){
            mapHeaderComponentsByName.put('BONIF_FREEGOOD', getNewPriceComponent());
        }
        SalesOrderReturn.priceComponent headerItemB = mapHeaderComponentsByName.get('BONIF_FREEGOOD');
        headerItemB.compName = 'BONIF_FREEGOOD';
        headerItemB.compUnitPrice += bonifFreegood;
        headerItemB.compHeaderTotalPrice += bonifFreegood * mapComponentsByName.get('BASE').quantity;

        if(mapComponentsByName.get('LISTA') != null){
            pLista = mapComponentsByName.get('LISTA').compUnitPrice;
            linePriceComponentes += 'Ajuste lista de precios|1|' + (pLista*100/pBase).setScale(2) +'|' + pLista.setScale(2) + '|' + (pLista * mapComponentsByName.get('LISTA').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('LISTA') == null){
                mapHeaderComponentsByName.put('LISTA', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('LISTA');
            headerItem.compName = 'LISTA';
            headerItem.compUnitPrice += pLista;
            headerItem.compHeaderTotalPrice += pLista * mapComponentsByName.get('LISTA').quantity;
        } else {
            linePriceComponentes += 'Ajuste lista de precios|1|-0,00|-0,00|-0,00#';
        }
        if(mapComponentsByName.get('SFA') != null){
            pSfa = mapComponentsByName.get('SFA').compUnitPrice;
            linePriceComponentes += 'Bonificación Adicional|1|' + (pSfa*100/pBase).setScale(2) +'|' + pSfa.setScale(2) + '|' + (pSfa * mapComponentsByName.get('SFA').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('SFA') == null){
                mapHeaderComponentsByName.put('SFA', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('SFA');
            headerItem.compName = 'SFA';
            headerItem.compUnitPrice += pSfa;
            headerItem.compHeaderTotalPrice += pSfa * mapComponentsByName.get('SFA').quantity;
        }

        Decimal valorNeto = pBase+pCanal2+pBonif+pFreegood+pLista+pSfa;
        linePriceComponentes += 'Valor Neto|1|' + (valorNeto*100/pBase).setScale(2) +'|' + (valorNeto).setScale(2) + '|' + (valorNeto * mapComponentsByName.get('PBASE').quantity).setScale(2) + '#';
        linePriceComponentes += 'Impuestos Internos|1|-0,00|-0,00|-0,00#';
        linePriceComponentes += 'Importe Total|1|' + (valorNeto*100/pBase).setScale(2) +'|' + (valorNeto).setScale(2) + '|' + (valorNeto * mapComponentsByName.get('PBASE').quantity).setScale(2) + '';

        linePriceComponentes = linePriceComponentes.replace('.', ',');
        System.debug('%%%%%% item.priceComponents despues: '+ linePriceComponentes);
        item.priceComponents = linePriceComponentes;
        
    }

    public static void procesArgentinaHeader(SOR_Body body, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName){
        String linePriceComponentes = '';
        Decimal pBase;
        Decimal pBaseHeader;
        Decimal pCanal2 = 0;
        Decimal pCanal2Header = 0;
        Decimal pBonifFreeGood = 0;
        Decimal pBonifFreeGoodHeader = 0;
        Decimal pLista = 0;
        Decimal pListaHeader = 0;
        Decimal pSfa = 0;
        Decimal pSfaHeader = 0;
        if(mapComponentsByName.get('PBASE') != null){

            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            pBaseHeader = mapComponentsByName.get('PBASE').compHeaderTotalPrice;
            linePriceComponentes += 'Precio de Lista|1|100,00|' + pBase.setScale(2) + '|' + pBaseHeader.setScale(2) + '#';

        }
        if(mapComponentsByName.get('BASE') != null){
            pCanal2 = mapComponentsByName.get('BASE').compUnitPrice;
            pCanal2Header = mapComponentsByName.get('BASE').compHeaderTotalPrice;
            linePriceComponentes += 'Bonificación|1|' + (pCanal2*100/pBase).setScale(2) +'|' + pCanal2.setScale(2) + '|' + pCanal2Header.setScale(2) + '#';
        
        }
        if(mapComponentsByName.get('BONIF_FREEGOOD') != null){
            pBonifFreeGood =  mapComponentsByName.get('BONIF_FREEGOOD').compUnitPrice;
            pBonifFreeGoodHeader =  mapComponentsByName.get('BONIF_FREEGOOD').compHeaderTotalPrice;
            linePriceComponentes += 'Bonificación Merc Gratis|1|' + (pBonifFreeGood*100/pBase).setScale(2) +'|' + pBonifFreeGood.setScale(2) + '|' + pBonifFreeGoodHeader.setScale(2) + '#';

        }
        
        if(mapComponentsByName.get('LISTA') != null){
            pLista = mapComponentsByName.get('LISTA').compUnitPrice;
            pListaHeader = mapComponentsByName.get('LISTA').compHeaderTotalPrice;
            linePriceComponentes += 'Ajuste lista de precios|1|' + (pLista*100/pBase).setScale(2) +'|' + pLista.setScale(2) + '|' + pListaHeader.setScale(2) + '#';
            
        } else {
            linePriceComponentes += 'Ajuste lista de precios|1|-0,00|-0,00|-0,00#';
        }
        if(mapComponentsByName.get('SFA') != null){
            pSfa = mapComponentsByName.get('SFA').compUnitPrice;
            pSfaHeader = mapComponentsByName.get('SFA').compHeaderTotalPrice;
            linePriceComponentes += 'Bonificación Adicional|1|' + (pSfa*100/pBase).setScale(2) +'|' + pSfa.setScale(2) + '|' + pSfaHeader.setScale(2) + '#';
            
        }

        Decimal valorNeto = pBase+pCanal2+pBonifFreeGood+pLista+pSfa;
        Decimal valorNetoHeader = pBaseHeader+pCanal2Header+pBonifFreeGoodHeader+pListaHeader+pSfaHeader;
        linePriceComponentes += 'Valor Neto|1|' + (valorNeto*100/pBase).setScale(2) +'|' + (valorNeto).setScale(2) + '|' + valorNetoHeader.setScale(2) + '#';
        linePriceComponentes += 'Impuestos Internos|1|-0,00|-0,00|-0,00#';
        linePriceComponentes += 'Importe Total|1|' + (valorNeto*100/pBase).setScale(2) +'|' + (valorNeto).setScale(2) + '|' + valorNetoHeader.setScale(2) + '';

        linePriceComponentes = linePriceComponentes.replace('.', ',');
        System.debug('%%%%%% headder.priceComponents despues: '+ linePriceComponentes);
        body.priceComponents = linePriceComponentes;
        
    }

    public static void procesUruguayLine(SalesOrderReturn.SalesOrderItem item, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName, Map<String, SalesOrderReturn.priceComponent> mapHeaderComponentsByName){
        String linePriceComponentes = '';
        Decimal pBase;
        Decimal pBonus = 0;
        Decimal pCanal = 0;
        Decimal pCliente = 0;
        Decimal pManual = 0;
        Decimal pSfa = 0;
        Decimal pIva = 0;
        Decimal pImesi = 0;
        Decimal pImesi1 = 0;
        if(mapComponentsByName.get('PBASE') != null){

            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            linePriceComponentes += 'Precio de Lista|1|100,00|' + pBase.setScale(2) + '|' + (pBase * mapComponentsByName.get('PBASE').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('PBASE') == null){
                mapHeaderComponentsByName.put('PBASE', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('PBASE');
            headerItem.compName = 'PBASE';
            headerItem.compUnitPrice += pBase;
            headerItem.compHeaderTotalPrice += pBase * mapComponentsByName.get('PBASE').quantity;

        }
        if(mapComponentsByName.get('BONUS') != null){
            pBonus = mapComponentsByName.get('BONUS').compUnitPrice;
            linePriceComponentes += 'Producto Bonificado|1|' + (pBonus*100/pBase).setScale(2) +'|' + pBonus.setScale(2) + '|' + (pBonus * mapComponentsByName.get('BONUS').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('BONUS') == null){
                mapHeaderComponentsByName.put('BONUS', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('BONUS');
            headerItem.compName = 'BONUS';
            headerItem.compUnitPrice += pBonus;
            headerItem.compHeaderTotalPrice += pBonus * mapComponentsByName.get('BONUS').quantity;
        } else {
            linePriceComponentes += 'Producto Bonificado|1|0,00|0,00|0,00#';

        }
        if(mapComponentsByName.get('CANAL') != null){
            pCanal = mapComponentsByName.get('CANAL').compUnitPrice;
            linePriceComponentes += 'Descuento Canal|1|' + (pCanal*100/pBase).setScale(2) +'|' + pCanal.setScale(2) + '|' + (pCanal * mapComponentsByName.get('CANAL').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('CANAL') == null){
                mapHeaderComponentsByName.put('CANAL', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('CANAL');
            headerItem.compName = 'CANAL';
            headerItem.compUnitPrice += pCanal;
            headerItem.compHeaderTotalPrice += pCanal * mapComponentsByName.get('CANAL').quantity;
        } 

        if(mapComponentsByName.get('CLIENTE') != null){
            pCliente = mapComponentsByName.get('CLIENTE').compUnitPrice;
            linePriceComponentes += 'Descuento Cliente|1|' + (pCliente*100/pBase).setScale(2) +'|' + pCliente.setScale(2) + '|' + (pCliente * mapComponentsByName.get('CLIENTE').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('CLIENTE') == null){
                mapHeaderComponentsByName.put('CLIENTE', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('CLIENTE');
            headerItem.compName = 'CLIENTE';
            headerItem.compUnitPrice += pCliente;
            headerItem.compHeaderTotalPrice += pCliente * mapComponentsByName.get('CLIENTE').quantity;
        } else {
            linePriceComponentes += 'Descuento Cliente|1|0,00|0,00|0,00#';

        }
        if(mapComponentsByName.get('MANUAL') != null){
            pManual = mapComponentsByName.get('MANUAL').compUnitPrice;
            linePriceComponentes += 'Descuento Manual|1|' + (pManual*100/pBase).setScale(2) +'|' + pManual.setScale(2) + '|' + (pManual * mapComponentsByName.get('MANUAL').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('MANUAL') == null){
                mapHeaderComponentsByName.put('MANUAL', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('MANUAL');
            headerItem.compName = 'MANUAL';
            headerItem.compUnitPrice += pManual;
            headerItem.compHeaderTotalPrice += pManual * mapComponentsByName.get('MANUAL').quantity;
        }
        if(mapComponentsByName.get('SFA') != null){
            pSfa = mapComponentsByName.get('SFA').compUnitPrice;
            linePriceComponentes += 'Descuento Adicional|1|' + (pSfa*100/pBase).setScale(2) +'|' + pSfa.setScale(2) + '|' + (pSfa * mapComponentsByName.get('SFA').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('SFA') == null){
                mapHeaderComponentsByName.put('SFA', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('SFA');
            headerItem.compName = 'SFA';
            headerItem.compUnitPrice += pSfa;
            headerItem.compHeaderTotalPrice += pSfa * mapComponentsByName.get('SFA').quantity;
        }

        Decimal valorNeto = pBase+pBonus+pCanal+pCliente+pManual+pSfa;
        linePriceComponentes += 'Valor Neto|1|' + (valorNeto*100/pBase).setScale(2) +'|' + (valorNeto).setScale(2) + '|' + (valorNeto * mapComponentsByName.get('PBASE').quantity).setScale(2) + '#';
        
        if(mapComponentsByName.get('IVA') != null){
            pIva = mapComponentsByName.get('IVA').compUnitPrice;
            linePriceComponentes += 'Impuesto IVA|1|' + (pIva*100/pBase).setScale(2) +'|' + pIva.setScale(2) + '|' + (pIva * mapComponentsByName.get('IVA').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('IVA') == null){
                mapHeaderComponentsByName.put('IVA', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('IVA');
            headerItem.compName = 'IVA';
            headerItem.compUnitPrice += pIva;
            headerItem.compHeaderTotalPrice += pIva * mapComponentsByName.get('IVA').quantity;
        }        
        if(mapComponentsByName.get('IMESI') != null){
            pImesi = mapComponentsByName.get('IMESI').compUnitPrice;
            linePriceComponentes += 'Impuesto IMESI|1|' + (pImesi*100/pBase).setScale(2) +'|' + pImesi.setScale(2) + '|' + (pImesi * mapComponentsByName.get('IMESI').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('IMESI') == null){
                mapHeaderComponentsByName.put('IMESI', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('IMESI');
            headerItem.compName = 'IMESI';
            headerItem.compUnitPrice += pImesi;
            headerItem.compHeaderTotalPrice += pImesi * mapComponentsByName.get('IMESI').quantity;
        }       
        if(mapComponentsByName.get('IMESI1') != null){
            pImesi1 = mapComponentsByName.get('IMESI1').compUnitPrice;
            linePriceComponentes += 'Impuesto IMESI 1|1|' + (pImesi1*100/pBase).setScale(2) +'|' + pImesi1.setScale(2) + '|' + (pImesi1 * mapComponentsByName.get('IMESI1').quantity).setScale(2) + '#';
            if(mapHeaderComponentsByName.get('IMESI1') == null){
                mapHeaderComponentsByName.put('IMESI1', getNewPriceComponent());
            }
            SalesOrderReturn.priceComponent headerItem = mapHeaderComponentsByName.get('IMESI1');
            headerItem.compName = 'IMESI1';
            headerItem.compUnitPrice += pImesi1;
            headerItem.compHeaderTotalPrice += pImesi1 * mapComponentsByName.get('IMESI1').quantity;
        }
        Decimal valorTotal = valorNeto+pIva+pImesi+pImesi1;
        linePriceComponentes += 'Total Factura|1|' + (valorTotal*100/pBase).setScale(2) +'|' + (valorTotal).setScale(2) + '|' + (valorTotal * mapComponentsByName.get('PBASE').quantity).setScale(2) + '';
        
        linePriceComponentes = linePriceComponentes.replace('.', ',');
        System.debug('%%%%%% item.priceComponents despues: '+ linePriceComponentes);
        item.priceComponents = linePriceComponentes;
        
    }

    public static void procesUruguayHeader(SOR_Body body, Map<String, SalesOrderReturn.priceComponent> mapComponentsByName){
        String linePriceComponentes = '';
        Decimal pBase;
        Decimal pBonus = 0;
        Decimal pCanal = 0;
        Decimal pCliente = 0;
        Decimal pManual = 0;
        Decimal pSfa = 0;
        Decimal pIva = 0;
        Decimal pImesi = 0;
        Decimal pImesi1 = 0;
        Decimal pBaseHeader;
        Decimal pBonusHeader = 0;
        Decimal pCanalHeader = 0;
        Decimal pClienteHeader = 0;
        Decimal pManualHeader = 0;
        Decimal pSfaHeader = 0;
        Decimal pIvaHeader = 0;
        Decimal pImesiHeader = 0;
        Decimal pImesi1Header = 0;
        if(mapComponentsByName.get('PBASE') != null){

            pBase = mapComponentsByName.get('PBASE').compUnitPrice;
            pBaseHeader = mapComponentsByName.get('PBASE').compHeaderTotalPrice;
            linePriceComponentes += 'Precio de Lista|1|100,00|' + pBase.setScale(2) + '|' + pBaseHeader.setScale(2) + '#';

        }
        if(mapComponentsByName.get('BONUS') != null){
            pBonus = mapComponentsByName.get('BONUS').compUnitPrice;
            pBonusHeader = mapComponentsByName.get('BONUS').compHeaderTotalPrice;
            linePriceComponentes += 'Producto Bonificado|1|' + (pBonus*100/pBase).setScale(2) +'|' + pBonus.setScale(2) + '|' + pBonusHeader.setScale(2) + '#';
            
        } else {
            linePriceComponentes += 'Producto Bonificado|1|0,00|0,00|0,00#';

        }
        if(mapComponentsByName.get('CANAL') != null){
            pCanal = mapComponentsByName.get('CANAL').compUnitPrice;
            pCanalHeader = mapComponentsByName.get('CANAL').compHeaderTotalPrice;
            linePriceComponentes += 'Descuento Canal|1|' + (pCanal*100/pBase).setScale(2) +'|' + pCanal.setScale(2) + '|' + pCanalHeader.setScale(2) + '#';
            
        } 

        if(mapComponentsByName.get('CLIENTE') != null){
            pCliente = mapComponentsByName.get('CLIENTE').compUnitPrice;
            pClienteHeader = mapComponentsByName.get('CLIENTE').compHeaderTotalPrice;
            linePriceComponentes += 'Descuento Cliente|1|' + (pCliente*100/pBase).setScale(2) +'|' + pCliente.setScale(2) + '|' + pClienteHeader.setScale(2) + '#';
            
        } else {
            linePriceComponentes += 'Descuento Cliente|1|0,00|0,00|0,00#';

        }
        if(mapComponentsByName.get('MANUAL') != null){
            pManual = mapComponentsByName.get('MANUAL').compUnitPrice;
            pManualHeader = mapComponentsByName.get('MANUAL').compHeaderTotalPrice;
            linePriceComponentes += 'Descuento Manual|1|' + (pManual*100/pBase).setScale(2) +'|' + pManual.setScale(2) + '|' + pManualHeader.setScale(2) + '#';
            
        }
        if(mapComponentsByName.get('SFA') != null){
            pSfa = mapComponentsByName.get('SFA').compUnitPrice;
            pSfaHeader = mapComponentsByName.get('SFA').compHeaderTotalPrice;
            linePriceComponentes += 'Descuento Adicional|1|' + (pSfa*100/pBase).setScale(2) +'|' + pSfa.setScale(2) + '|' + pSfaHeader.setScale(2) + '#';
           
        }

        Decimal valorNeto = pBase+pBonus+pCanal+pCliente+pManual+pSfa;
        Decimal valorNetoHeader = pBaseHeader+pBonusHeader+pCanalHeader+pClienteHeader+pManualHeader+pSfaHeader;
        linePriceComponentes += 'Valor Neto|1|' + (valorNeto*100/pBase).setScale(2) +'|' + (valorNeto).setScale(2) + '|' + valorNetoHeader.setScale(2) + '#';
        
        if(mapComponentsByName.get('IVA') != null){
            pIva = mapComponentsByName.get('IVA').compUnitPrice;
            pIvaHeader = mapComponentsByName.get('IVA').compHeaderTotalPrice;
            linePriceComponentes += 'Impuesto IVA|1|' + (pIva*100/pBase).setScale(2) +'|' + pIva.setScale(2) + '|' + pIvaHeader.setScale(2) + '#';
            
        }        
        if(mapComponentsByName.get('IMESI') != null){
            pImesi = mapComponentsByName.get('IMESI').compUnitPrice;
            pImesiHeader = mapComponentsByName.get('IMESI').compHeaderTotalPrice;
            linePriceComponentes += 'Impuesto IMESI|1|' + (pImesi*100/pBase).setScale(2) +'|' + pImesi.setScale(2) + '|' + pImesiHeader.setScale(2) + '#';
            
        }       
        if(mapComponentsByName.get('IMESI1') != null){
            pImesi1 = mapComponentsByName.get('IMESI1').compUnitPrice;
            pImesi1Header = mapComponentsByName.get('IMESI1').compHeaderTotalPrice;
            linePriceComponentes += 'Impuesto IMESI 1|1|' + (pImesi1*100/pBase).setScale(2) +'|' + pImesi1.setScale(2) + '|' + pImesi1Header.setScale(2) + '#';
            
        }
        Decimal valorTotal = valorNeto+pIva+pImesi+pImesi1;
        Decimal valorTotalHeader = valorNetoHeader+pIvaHeader+pImesiHeader+pImesi1Header;
        linePriceComponentes += 'Total Factura|1|' + (valorTotal*100/pBase).setScale(2) +'|' + (valorTotal).setScale(2) + '|' + valorTotalHeader.setScale(2) + '';
        
        linePriceComponentes = linePriceComponentes.replace('.', ',');
        System.debug('%%%%%% body.priceComponents despues: '+ linePriceComponentes);
        body.priceComponents = linePriceComponentes;
        
    }


    public static SalesOrderReturn.priceComponent getNewPriceComponent(){
        SalesOrderReturn.priceComponent nuevo = new SalesOrderReturn.priceComponent();
        nuevo.compUnitPrice = 0;
        nuevo.compHeaderTotalPrice = 0;
        return nuevo;
    }
    */
}