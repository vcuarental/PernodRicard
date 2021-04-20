@RestResource(urlMapping='/LAT_Rest_Opportunities/*')
global with sharing class LAT_Rest_Opportunities {
    
    @HttpPost
    global static void POST() {
    	LAT_Opportunity__c opp = new LAT_Opportunity__c();
    	RestRequest req = RestContext.request;
        LAT_OpportunityHandlerJSON pedido = (LAT_OpportunityHandlerJSON)System.JSON.deserialize(req.requestBody.toString(), LAT_OpportunityHandlerJSON.class);
        System.debug('Pedido : ' + pedido);
        System.debug('Pedido.account : ' + pedido.header.account);

        String response = insertOpportunity(pedido, opp);

        ServiceResponse res = new ServiceResponse(opp.Id, response, response =='');

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
    }

    @HttpPut
    global static void PUT() {
    	
    	RestRequest req = RestContext.request;
        LAT_OpportunityHandlerJSON pedido = (LAT_OpportunityHandlerJSON)System.JSON.deserialize(req.requestBody.toString(), LAT_OpportunityHandlerJSON.class);
        System.debug('Pedido : ' + pedido);
        System.debug('Pedido.ID : ' + pedido.header.Id);
        LAT_Opportunity__c opp = [SELECT Id, LAT_Account__c FROM LAT_Opportunity__c Where Id =:pedido.header.Id];
        Boolean isCancel = false;
        String response;

        pedido.header.account = opp.LAT_Account__c;

        for (LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
        	System.debug('oppItem.actionCode  : ' + oppItem.actionCode);
        	if(pedido.header.actionCode == 'C'){
        		oppItem.actionCode = 'C';
        	}
        	if(oppItem.actionCode != null){
        		if(oppItem.actionCode == 'C'){
        			isCancel = true;
        		}
        	}
        }
        if(isCancel){
        	response = cancelOpportunity(pedido);
        } else {
        	response = updateOpportunity(pedido, opp);
        }
        

        ServiceResponse res = new ServiceResponse(opp.Id, response, response =='');

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
    }

    public static String insertOpportunity(LAT_OpportunityHandlerJSON pedido, LAT_Opportunity__c opp) {
    	String retorno = '';
    	String accId = pedido.header.account;
    	System.debug('%%% accId : ' + accId);
 		Account acc = [SELECT Id, CurrencyIsoCode, Client_country_An8__c FROM Account WHERE Id = :accId];
 		if(acc == null) {
 			return 'Cliente no encontrado.';
 		}
 		try{
	        opp.Name                            = pedido.header.name;
	        opp.CurrencyIsoCode                 = acc.CurrencyIsoCode;
	        opp.LAT_Account__c                  = pedido.header.account;
	        opp.LAT_NRCustomerOrder__c          = pedido.header.customerOrderNr;
	        opp.LAT_DSMessage1__c               = pedido.header.message1;
	        opp.LAT_DSMessage2__c               = pedido.header.message2;
	        opp.LAT_OrderOrigin__c              = 'APP';
	        
	        if(pedido.header.type_Z.equalsIgnoreCase('SJ')){
				opp.LAT_Type__c = 'SJ - Ofrecidos de Ventas por Acuerdos';
			} else  if(pedido.header.type_Z.equalsIgnoreCase('SH')) {
				opp.LAT_Type__c = 'SH - Ofrecidos de Ventas por Acuerdos Comerciales';
			} else {
				opp.LAT_Type__c = pedido.header.type_Z;
			}

	        //opp.LAT_Type__c                     = pedido.header.type_Z;

	        if(pedido.header.stage != null)
	        	opp.LAT_StageName__c                = pedido.header.stage;
	        opp.LAT_CloseDate__c                = Date.valueOf(pedido.header.closeDate);
	        
	        
	        if(pedido.header.deliveryDate != null && pedido.header.deliveryDate != '') {
	            opp.LAT_DTDelivery__c               = Date.valueOf(pedido.header.deliveryDate);
	            if(acc.Client_country_An8__c.startsWith('1-'))
	            	opp.LAT_EstimatedDeliveryDate__c    = Date.valueOf(pedido.header.deliveryDate);
	        }

	        if(acc.Client_country_An8__c.startsWith('1-')){
	        	opp.LAT_FreightFormulaDisplay__c    	  = pedido.header.totalFreightPercent;
	        	opp.LAT_Pallet_Quantity__c          	  = pedido.header.totalPalletQuantity;
	        }
	        if(acc.Client_country_An8__c.startsWith('12-')){
                if(pedido.header.mxPurchaseOrderSince != null && pedido.header.mxPurchaseOrderSince != '')
	        	opp.LAT_MX_PurchaseOrderSince__c = Date.valueOf(pedido.header.mxPurchaseOrderSince);
                if(pedido.header.mxPurchaseOrderUntil != null && pedido.header.mxPurchaseOrderUntil != '')
	        	opp.LAT_MX_PurchaseOrderUntil__c = Date.valueOf(pedido.header.mxPurchaseOrderUntil);
	        	opp.LAT_MX_OrderPaymentPeriodReference__c = pedido.header.mxPaymentCondition;
	        }
	        insert opp;

			List<LAT_OpportunityLineItem__c> lines = new List<LAT_OpportunityLineItem__c>();
	        for (LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
	            LAT_OpportunityLineItem__c line = new LAT_OpportunityLineItem__c();
	            if(acc.Client_country_An8__c.startsWith('1-')){
	            	line.LAT_PaymentCondition__c        = oppItem.paymentCondition;
	            	line.LAT_UnitCode__c                = oppItem.measurementUnit;
	            	if(oppItem.quantityBonus != null) {
	            		if(oppItem.quantityBonus > 0)line.LAT_QTBonus__c	= oppItem.quantityBonus;
	            	}
	            	if(oppItem.sendDicountToApproval != null)
	            		line.LAT_AR_SentToApproveDiscount__c= oppItem.sendDicountToApproval;
	            	line.LAT_FreightPercent__c          = oppItem.skuFreightPercent;
	            	line.LAT_Pallet_Total_Quantity__c   = oppItem.skuPalletQuantity;
	            }
	            if(acc.Client_country_An8__c.startsWith('12-')){
	            	line.LAT_AR_UOM__c					= oppItem.measurementUnit;
	            }
	            if(acc.Client_country_An8__c.startsWith('6-') || acc.Client_country_An8__c.startsWith('5-')){
	            	line.LAT_PaymentCondition__c        = oppItem.paymentCondition;
	            	line.LAT_AR_UOM__c					= oppItem.measurementUnit;
	            	if(oppItem.sendDicountToApproval != null)
	            		line.LAT_AR_SentToApproveDiscount__c= oppItem.sendDicountToApproval;
	            }
	            line.LAT_AR_Discount__c             = oppItem.discount;
	            line.LAT_Quantity__c                = oppItem.quantity;
	            line.LAT_UnitPrice__c               = oppItem.unitPrice;
				line.LAT_Product__c                 = oppItem.PriceBookEntryId;            
				line.LAT_SkuText__c					= oppItem.productSKU;
				
				//line.LAT_NROrderLine__c = String.valueOf(lines.size()); //DEBEN SER VALORES INCREMENTALES
	            if(oppItem.percentualBonus != null) {
	            	if(oppItem.percentualBonus > 0)	line.LAT_PercentualOfBonus__c = oppItem.percentualBonus;
	            }
	            line.LAT_Opportunity__c             = opp.Id;
				lines.add(line);
				
	        } 
	        if(lines.size() > 0) {
	            insert lines;
	        }
	    } catch (Exception e) {
			System.debug('EXCEPCION : ---->' + e.getStackTraceString() + '<-----');
	    	retorno = e.getMessage();
	    }
    	return retorno;
    }

    public static String updateOpportunity(LAT_OpportunityHandlerJSON pedido, LAT_Opportunity__c opp) {
    	String retorno = '';
    	String accId = pedido.header.account;
    	System.debug('%%% accId : ' + accId);
    	
 		Account acc = [SELECT Id, CurrencyIsoCode, Client_country_An8__c FROM Account WHERE Id = :accId];

 		if(acc == null) {
 			return 'Cliente no encontrado.';
 		}
 		try{
	        opp.Name                            = pedido.header.name;
	        opp.CurrencyIsoCode                 = acc.CurrencyIsoCode;
	        opp.LAT_Account__c                  = pedido.header.account;
	        opp.LAT_NRCustomerOrder__c          = pedido.header.customerOrderNr;
	        opp.LAT_DSMessage1__c               = pedido.header.message1;
	        opp.LAT_DSMessage2__c               = pedido.header.message2;
	        opp.LAT_OrderOrigin__c              = 'APP';
	        opp.LAT_Type__c                     = pedido.header.type_Z;
	        if(pedido.header.stage != null)
	        	opp.LAT_StageName__c                = pedido.header.stage;

	        if(pedido.header.closeDate != null)
	        opp.LAT_CloseDate__c                = Date.valueOf(pedido.header.closeDate);
	        
	        
	        if(pedido.header.deliveryDate != null) {
	            opp.LAT_DTDelivery__c               = Date.valueOf(pedido.header.deliveryDate);
	            if(acc.Client_country_An8__c.startsWith('1-'))
	            	opp.LAT_EstimatedDeliveryDate__c    = Date.valueOf(pedido.header.deliveryDate);
	        }

	        if(acc.Client_country_An8__c.startsWith('1-')){
	        	opp.LAT_FreightFormulaDisplay__c    	  = pedido.header.totalFreightPercent;
	        	opp.LAT_Pallet_Quantity__c          	  = pedido.header.totalPalletQuantity;
	        }
	        if(acc.Client_country_An8__c.startsWith('12-')){
	        	opp.LAT_MX_PurchaseOrderSince__c = Date.valueOf(pedido.header.mxPurchaseOrderSince);
	        	opp.LAT_MX_PurchaseOrderUntil__c = Date.valueOf(pedido.header.mxPurchaseOrderUntil);
	        	opp.LAT_MX_OrderPaymentPeriodReference__c = pedido.header.mxPaymentCondition;
	        }
	        update opp;

	        List<LAT_OpportunityLineItem__c> lines = new List<LAT_OpportunityLineItem__c>();
	        for (LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
	            LAT_OpportunityLineItem__c line = new LAT_OpportunityLineItem__c();
	            if(oppItem.Id.startsWith('aPV')) {
	            	line.Id 	= oppItem.id;
	            } else {
	            	line.LAT_Opportunity__c = opp.Id;
	            }
	            if(acc.Client_country_An8__c.startsWith('1-')){
	            	line.LAT_PaymentCondition__c        = oppItem.paymentCondition;
	            	line.LAT_UnitCode__c                = oppItem.measurementUnit;
	            	if(oppItem.quantityBonus != null) {
	            		if(oppItem.quantityBonus > 0)line.LAT_QTBonus__c	= oppItem.quantityBonus;
	            	}
	            	if(oppItem.sendDicountToApproval != null)
	            		line.LAT_AR_SentToApproveDiscount__c= oppItem.sendDicountToApproval;
	            	line.LAT_FreightPercent__c          = oppItem.skuFreightPercent;
	            	line.LAT_Pallet_Total_Quantity__c   = oppItem.skuPalletQuantity;
	            }
	            if(acc.Client_country_An8__c.startsWith('12-')){
	            	line.LAT_AR_UOM__c					= oppItem.measurementUnit;
	            }

	            if(acc.Client_country_An8__c.startsWith('6-') || acc.Client_country_An8__c.startsWith('5-')){
	            
	            	line.LAT_PaymentCondition__c        = oppItem.paymentCondition;
	            	line.LAT_AR_UOM__c					= oppItem.measurementUnit;
	            	if(oppItem.sendDicountToApproval != null)
	            		line.LAT_AR_SentToApproveDiscount__c= oppItem.sendDicountToApproval;
	            }

	            line.LAT_AR_Discount__c             = oppItem.discount;
	            line.LAT_Quantity__c                = oppItem.quantity;
	            line.LAT_UnitPrice__c               = oppItem.unitPrice;
				line.LAT_Product__c                 = oppItem.PriceBookEntryId;            
	            
	            if(oppItem.percentualBonus != null) {
	            	if(oppItem.percentualBonus > 0)	line.LAT_PercentualOfBonus__c = oppItem.percentualBonus;
	            }
	            
	            lines.add(line);
	        } 
	        if(lines.size() > 0) {
	            upsert lines;
	        }
	    } catch (Exception e) {
	    	retorno = e.getMessage();
	    }
    	return retorno;
    }

    public static String cancelOpportunity(LAT_OpportunityHandlerJSON pedido){
    	String retorno = '';
    	try{
    		List<LAT_OpportunityLineItem__c> toUpdate = new List<LAT_OpportunityLineItem__c>();
	    	for(LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
	    		if(oppItem.Id.startsWith('aPV')) {
	    			if(oppItem.actionCode == 'C') {
	    				LAT_OpportunityLineItem__c nuevo = new LAT_OpportunityLineItem__c();
						nuevo.Id = oppItem.Id;
						nuevo.LAT_CDAction__c = oppItem.actionCode;
						nuevo.LAT_Remover__c = true;
						toUpdate.add(nuevo);
	    			}
					 

	    		}
	    		 
	    	}
	    	if(toUpdate.size() > 0) {
	    		LAT_Opportunity__c opp = [SELECT Id,LAT_Country__c FROM LAT_Opportunity__c WHERE Id=:pedido.header.Id ];
	    		//update opp;
	    		update toUpdate;
	    		if(opp.LAT_Country__c == 1){
					SalesOrderHandlerInterface.LAT_SalesOrderInterfaceFuture(pedido.header.Id);
				} else if(opp.LAT_Country__c == 5 || opp.LAT_Country__c == 6){
					WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(pedido.header.Id);
				}
	    		

	    	}
    	} catch (Exception e) {
	    	retorno = e.getMessage();
	    }
	    return retorno;
    }

    public class ServiceResponse {
        
        public String Id;
        public Boolean success;
        public String message;
        public String errorCode;

        public ServiceResponse(String idOpp, String msg, Boolean bool) {
            success = bool;
            message = msg;
            Id = idOpp;
        }
    }
}