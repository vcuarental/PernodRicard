@RestResource(urlMapping='/LAT_Rest_PriceCalculation/*')
global with sharing class LAT_Rest_PriceCalculation {
	
	@HttpPost
    global static void getPrice(List<LineaPedido> lines, String businessUnit, 
    						String ediTransactionType, String paymentTerms, DateTime priceEffectiveDate, Integer shipTo,Integer soldTo,DateTime taxEffectiveDate,String countryCode) {
    	System.debug('%%% Lineas : ' + lines);
		System.debug('%%% shipTo|soldTo : ' + shipTo +'|'+soldTo);

    	List<LAT_JDE_PriceCalculation.priceCatalogueDetailsInput> priceCatalogueDetails = new List<LAT_JDE_PriceCalculation.priceCatalogueDetailsInput>();

		for (LineaPedido linea : lines) {
			LAT_JDE_PriceCalculation.priceCatalogueDetailsInput item = new LAT_JDE_PriceCalculation.priceCatalogueDetailsInput();
			item.secondItemNumber       = linea.sku;
			item.unitOfMeasure          = linea.unitOfMeasure;
			item.paymentTerms           = paymentTerms;
			item.ratePercentCashDiscount = linea.ratePercentCashDiscount;
			item.quantityOrdered        = linea.quantityOrdered;
			item.quantityFree			= linea.quantityBonus;
			priceCatalogueDetails.add(item);
		}
		
		LAT_JDE_PriceCalculation.PriceCatalogueManagerPort calloutClient = new LAT_JDE_PriceCalculation.PriceCatalogueManagerPort();
		System.debug('Antes');
		System.debug('priceCatalogueDetails : ' + priceCatalogueDetails);
		LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput response = calloutClient.getPriceCatalogue(businessUnit,null,paymentTerms,priceCatalogueDetails,DateTime.now(),shipTo,soldTo,DateTime.now(),countryCode);
		System.debug('Respuesta : ' + response);

		RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.responseBody 	= Blob.valueOf(JSON.serialize(response));
		RestContext.response.statusCode 	= 200;
    }


    global class LineaPedido {
        global String 	sku;
        global String 	unitOfMeasure;
        global Decimal 	ratePercentCashDiscount;
        global Integer 	quantityOrdered;
        global Integer 	quantityBonus;
        global Decimal  percentualBonus;
    }

    /*
	
	List<LAT_JDE_PriceCalculation.priceCatalogueDetailsInput> priceCatalogueDetails = new List<LAT_JDE_PriceCalculation.priceCatalogueDetailsInput>();
	LAT_JDE_PriceCalculation.priceCatalogueDetailsInput item = new LAT_JDE_PriceCalculation.priceCatalogueDetailsInput();
	item.secondItemNumber       = '14973';
	item.unitOfMeasure          = 'CA';
	item.paymentTerms           = '030';
	item.ratePercentCashDiscount           = 5;
	item.quantityOrdered        = 5;

	priceCatalogueDetails.add(item);
	LAT_JDE_PriceCalculation.PriceCatalogueManagerPort calloutClient = new LAT_JDE_PriceCalculation.PriceCatalogueManagerPort();
	System.debug('Antes');
	LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput response = calloutClient.getPriceCatalogue('01',null,'030',priceCatalogueDetails,DateTime.now(),2120361,2120361,DateTime.now(),'6');
	System.debug('Despues');
	system.debug('%%%%%%%  response : ' + response);

    */


}