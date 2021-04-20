global class LAT_B2B_PriceCalc_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful {
	
	public static final String PAYMENT_CONDITION = '045';
	
	String query;
	LAT_B2B_Price_Configs__c subChannelCS;
	String errores;
	Integer productosEjecutados; 
	Account acc;
	Datetime inicio;
	

	
	global LAT_B2B_PriceCalc_Batch(String subChannel) {
		productosEjecutados  = 0;
		errores = '';
		subChannelCS = [SELECT Name, LAT_Account__c, LAT_InternalId__c, LAT_LastExecution__c FROM LAT_B2B_Price_Configs__c WHERE LAT_InternalId__c= :subChannel LIMIT 1];
		System.debug('%%% subChannelCS : ' + subChannelCS);
		acc = [SELECT Id, Sub_Channel__c, Business_Unit_AR__r.CodDefUsuario__c, Client_code_an8__c FROM Account WHERE Client_code_an8__c = :subChannelCS.LAT_Account__c ];
		query = 'SELECT Id, Name, LAT_SKU__c, LAT_B2B_Visibility__c FROM LAT_Product__c WHERE RecordType.Developername = \'Standard_AR\' AND LAT_Country__c =6 AND LAT_IsActive__C = true';
		inicio = Datetime.now();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('START B2B Price Calculation BATCH');
		System.debug('subChannelCS : ' + subChannelCS);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Map<Integer, LAT_Product__c> mapProds = new Map<Integer, LAT_Product__c>();
		List<LAT_Product__c> products = (List<LAT_Product__c>)scope;
		productosEjecutados += products.size();
		for(LAT_Product__c p : products){
			mapProds.put(Integer.valueOf(p.LAT_SKU__c), p);
		}
		
		LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput respuesta = getPrices(products);
		List<LAT_AR_B2B_ProductPricesByChannel__c> toInsert = new List<LAT_AR_B2B_ProductPricesByChannel__c>();

		System.debug('%%%% respuesta.errorRecords Antes : ' + respuesta.errorRecords);

		if (respuesta.errorRecords <> null) {
			System.debug('%%%% respuesta.errorRecords despues : ' + respuesta.errorRecords);
			System.debug('%%%% respuesta.errorRecords.size() : ' + respuesta.errorRecords.size());
			if (respuesta.errorRecords.size() > 0) {
				System.debug('%%%% respuesta.errorRecords[0].errorCode : ' + respuesta.errorRecords[0].errorCode);
				System.debug('%%%% respuesta.errorRecords[0].errorDescription : ' + respuesta.errorRecords[0].errorDescription);
				System.debug('%%%% mapProds.keySet() : ' + mapProds.keySet());
				if(products[0].LAT_B2B_Visibility__c != 'Oculto'){
					//Hay un error de Negocio, lo logueo y envío un mail.
					errores += '<br>Se obtuvo el siguiente error de retorno al ejecutar el cálculo de precios : ';
					errores += '<br><b>Código de Error</b>: ' + respuesta.errorRecords[0].errorCode;
					errores += '<br><b>Mensaje</b>: ' + respuesta.errorRecords[0].errorDescription;
					errores += '<br><b>Productos utilizados</b>: ' + JSON.serialize(mapProds.keySet());
				}
			}
		} else {
			for (LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput detalle : respuesta.priceCatalogueDetails){
				System.debug('%%% detalle:'+detalle);
				System.debug('%%% mapProds.keySet:'+mapProds.keySet());
				LAT_AR_B2B_ProductPricesByChannel__c nuevo = new LAT_AR_B2B_ProductPricesByChannel__c();
				nuevo.CurrencyIsoCode = 'ARS';
				nuevo.LAT_Channel__c = subChannelCS.LAT_InternalId__c;
				nuevo.LAT_Product__c = mapProds.get(detalle.itemNumberShort).Id;
				nuevo.LAT_TimeStamp__c = Datetime.now();
				nuevo.LAT_AR_UOM__c = detalle.unitofMeasure;
				nuevo.LAT_Price__c  = detalle.unitPrice;
				nuevo.LAT_Iva__c  = detalle.amountTax;
				nuevo.LAT_Iibb__c  = detalle.amountExcise;
				if(detalle.discountAndChargeDetails != null){
					for(LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput descuento:  detalle.discountAndChargeDetails) {
					System.debug('descuento.discountOrChargeGroup: '+descuento.discountOrChargeGroup);
					if(descuento.discountOrChargeGroup.contains('B2B')){
						nuevo.LAT_PriceWithoutOffer__c = detalle.unitPrice + (descuento.unitDiscountOrCharge *(-1));
						if(nuevo.LAT_Iva__c != null && nuevo.LAT_Price__c != null)
							nuevo.LAT_OfferIva__c = nuevo.LAT_PriceWithoutOffer__c * nuevo.LAT_Iva__c/nuevo.LAT_Price__c;
						if(nuevo.LAT_Iva__c != null && nuevo.LAT_Price__c != null)
							nuevo.LAT_OfferIibb__c = nuevo.LAT_PriceWithoutOffer__c * nuevo.LAT_Iibb__c/nuevo.LAT_Price__c;
					}
				}
				}
				
				if(nuevo.LAT_PriceWithoutOffer__c == null){
					nuevo.LAT_PriceWithoutOffer__c = nuevo.LAT_Price__c;
				}
				toInsert.add(nuevo);
			}	

			if(toInsert.size() > 0) insert toInsert;

		}
		



	}
	
	global void finish(Database.BatchableContext BC) {
		
		//delete old prices
		delete [SELECT Id FROM LAT_AR_B2B_ProductPricesByChannel__c WHERE LAT_Channel__c =:subChannelCS.LAT_InternalId__c AND  LAT_TimeStamp__c <:inicio];
		//Log the execution information.
		LAT_DebugUtil debug = new LAT_DebugUtil();
		debug.setOrigin( 'LAT_B2B_PriceCalc_Batch' );
		debug.addTitle('Ejecucion de Batch de cálculo de precios para SubChannel <b>' +subChannelCS.Name + '</b> (AN8 Patrón : ' +subChannelCS.LAT_Account__c +')');
		debug.addData('Productos Ejecutados', '' + productosEjecutados);
		debug.addTitle('Errores');
        debug.addData('Errores:', errores);
        debug.insertDebug();

		if(errores != ''){
			sendEmail(errores);
		}


	}
	
	@testVisible
	private LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput getPrices(List<LAT_Product__c> prods){
		
		List<LAT_JDE_PriceCalculation.priceCatalogueDetailsInput> priceCatalogueDetails = new List<LAT_JDE_PriceCalculation.priceCatalogueDetailsInput>();
		for (LAT_Product__c p : prods) {
			LAT_JDE_PriceCalculation.priceCatalogueDetailsInput item = new LAT_JDE_PriceCalculation.priceCatalogueDetailsInput();
			item.secondItemNumber       = p.LAT_Sku__c;
			item.paymentTerms           = PAYMENT_CONDITION;
			item.quantityOrdered        = 1;
			item.unitOfMeasure          = 'CA';
			priceCatalogueDetails.add(item);

			LAT_JDE_PriceCalculation.priceCatalogueDetailsInput item2 = new LAT_JDE_PriceCalculation.priceCatalogueDetailsInput();
			item2.secondItemNumber       = p.LAT_Sku__c;
			item2.paymentTerms           = PAYMENT_CONDITION;
			item2.quantityOrdered        = 1;
			item2.unitOfMeasure          = 'BT';
			priceCatalogueDetails.add(item2);
		}
		
		LAT_JDE_PriceCalculation.PriceCatalogueManagerPort calloutClient = new LAT_JDE_PriceCalculation.PriceCatalogueManagerPort();
		System.debug('Antes');
		System.debug('priceCatalogueDetails : ' + priceCatalogueDetails);
		LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput response;
		if(!Test.isRunningTest()){
			response = calloutClient.getPriceCatalogue(acc.Business_Unit_AR__r.CodDefUsuario__c, null, PAYMENT_CONDITION, priceCatalogueDetails, DateTime.now(), Integer.valueOf(acc.Client_code_An8__c), Integer.valueOf(acc.Client_code_An8__c), DateTime.now(), '6');
			System.debug('Respuesta : ' + response);
		} else {
			response = LAT_AR_B2B_PriceCalc_Test.getRespuesta();
		}
		return response;
	}

	public void sendEmail(String errores){
		
		String emailSubject = 'Se encontraron errores al Ejecutar el cálculo de precios B2B para el Canal ' + subChannelCS.Name;
		String emailSoporteTienda = LAT_GeneralConfig__c.getInstance('AR_B2B_EmailSoporte').LAT_Value__c;
		String emailBody = 'Estimado, </br>Se encontraron los siguientes erres al ejecutar el batch de cálculo de precios para la Community B2B para el canal <b>' +subChannelCS.Name + '</b> (AN8 Patrón : ' +subChannelCS.LAT_Account__c +'): </br></br>';
		emailBody += errores + '</br></br>Gracias, </br>Equipo CRM';
		AP01_Case_AR.enviarEmail(emailBody, emailSubject, new List<String> {'crm-latam@pernod-ricard.com', emailSoporteTienda});
	}


}