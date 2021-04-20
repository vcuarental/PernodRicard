@RestResource(urlMapping='/LAT_RestCheckStockAvailability/*')

//06/07/2017
global with sharing class LAT_RestCheckStockAvailability {
	
	private static LAT_Log__c logAsRegistry;
    private static LAT_DebugUtil debug;
    public static Map<String,Integer> countryCodes = new Map<String,Integer>{'ARS'=>6,'UYU'=>5,'MXN'=>12,'BRL'=>1};

	@HttpPost  
	global static void post(String[] skus, String accId, String unitOfMeasure ) {

		String resultado = stockAvailibity(skus, accId, unitOfMeasure);
		RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "id" : "'+skus[0]+'", "success": "'+false+'", "message": '+resultado+'  }');

	}

    
    public static String stockAvailibity(List<String> skus, String accId, String unitOfMeasure) {

        debug = new LAT_DebugUtil();
        debug.setOrigin( 'LAT_RestCheckStockAvailability' );
        try {
            Account acc = [SELECT Id, RecordTypeId, Payment_Condition__r.Internal_Id__c, LAT_MX_AvailableCreditLimit__c, 
            			  Client_country_AN8__c, Business_Unit__r.CodDefUsuario__c, Business_Unit_AR__r.CodDefUsuario__c
		                  FROM Account WHERE Id =: accId];

            String countryText = LAT_WS_CustomerHandlerInterface.getCountryInfo(acc.RecordTypeId);
            system.debug( 'contry text: ' + countryText );
            Integer codPais ;

            if (countryText == 'Brasil') {
            	codPais = countryCodes.get('BRL');
            } else if (countryText == 'Argentina') {
            		codPais = countryCodes.get('ARS');
            	} else if (countryText == 'México') {
           		 		codPais = countryCodes.get('MXN');
           			} else { 
	            		codPais = countryCodes.get('UYU');
	            	}
            system.debug( 'codPais: ' + codPais );

            //THIS IS to check if exists a Bussines Unit of the account, if not we should show a message error and not integrate
            //if(opp.Account.Business_Unit__r.CodDefUsuario__c == null || opp.Account.Business_Unit_AR__r.CodDefUsuario__c == null){

            //}
            //Get Request - Port
            LAT_GetStock.port request = new LAT_GetStock.port();
            request.timeout_x = 120000;
            Lat_GetStockTypes.ItemListResponseType response;
            Map<String,String> mapProducts = new Map<String,String>();

            // List of itemtype which correspond to each Product being selected to calculate price
            List<Lat_GetStockTypes.ItemType> listOfItems = new List<Lat_GetStockTypes.ItemType>(); 
            Lat_GetStockTypes.ItemType itemType;
            Set<String> stockKeys = new Set<String>();
            Set<String> productsExtIds = new Set<String>();
            debug.addTitle('List of Sku');
            for (String sku : skus) {

                itemType = new Lat_GetStockTypes.ItemType();
                itemType.sku = sku;
                itemType.businessUnit = countryText == 'Brasil' ? acc.Business_Unit__r.CodDefUsuario__c : acc.Business_Unit_AR__r.CodDefUsuario__c; 
                itemType.unitOfMeasure = unitOfMeasure != null ? unitOfMeasure : 'CA';
                itemType.idType = 'itemProduct'; //hardcoded value

                stockKeys.add( codPais + '-' + itemType.sku + '-' + itemType.businessUnit );
                productsExtIds.add( codPais + '-' + itemType.sku );
                listOfItems.add(itemType);

                debug.addSubTitle( 'SKU' );
                debug.addData( 'unitOfMeasure', itemType.unitOfMeasure);
                debug.addData( 'sku', itemType.sku);
                debug.addData( 'businessUnit', itemType.businessUnit);
                System.debug( 'businessUnit' + itemType.businessUnit);
            }

            for (LAT_Product__c prod : [SELECT Id, LAT_ExternalID__c FROM LAT_Product__c WHERE LAT_ExternalID__c in :productsExtIds]) {
                mapProducts.put(prod.LAT_ExternalID__c,prod.Id);
            }

            Lat_GetStockTypes.ItemListType itemList = new Lat_GetStockTypes.ItemListType();
            itemList.item = listOfItems;
            if ( !Test.isRunningTest() ) {
                response = request.getStockOperation( getConnectionParameter( countryText ), itemList);
            } else { 
                response = LAT_RestCheckStockAvailability_Test.getResponse();

            }
            System.debug('%%%% response : '+response);
	        List<LAT_Stock__c> listOfStockToUpsert = new List<LAT_Stock__c>();
	        Map<String,LAT_Stock__c> mapKeyStock = new Map<String,LAT_Stock__c>();

	        //Get list of existing Lat_Stock records to upsert based on the List recieved
	        List<Lat_stock__c> lsList = [SELECT Id, LAT_Branch__c, LAT_Stock__c, LAT_Product__r.LAT_ExternalID__c, LAT_Unit__c, LAT_ExternalId__c
                                         FROM Lat_Stock__c 
                                         WHERE LAT_ExternalId__c IN :stockKeys];
             
            if ( lsList != null ) {
                for ( Lat_Stock__c ls : lsList ) {
                    if(ls.LAT_Product__r.LAT_ExternalID__c != null){
                        mapKeyStock.put( ls.LAT_Product__r.LAT_ExternalID__c + '-' + ls.LAT_Branch__c, ls);
                    }
                }
            }

            String keyStock = '';
            Set<String> keyOfStocks = new Set<String>();
            debug.addTitle('Response');
            debug.addData('mapItems', String.ValueOf(response.itemResponse));
            for ( Lat_GetStockTypes.ItemResponseType respItem : response.itemResponse ) {

                if (respItem.sku.trim() != null && respItem.businessUnit.trim() != null && respItem.response != null ) {
                    
                        //String responseValue = respItem.response;
                        //check if response it's an error
                        keyStock = codPais+'-'+respItem.sku.trim()+'-'+respItem.businessUnit.trim();
                        String jdeErrorMessage = respItem.errorJDE != null ? respItem.errorJDE : null;
                        if ( jdeErrorMessage != null && jdeErrorMessage != '' ) {
                            if ( mapKeyStock.get( keyStock ) != null ) {
                                Lat_stock__c ls = mapKeyStock.get( keyStock );
                                ls.LAT_JDE_Error__c = jdeErrorMessage;
                                ls.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                listOfStockToUpsert.add(ls);
                            } else {
                                Lat_Stock__c latS = new Lat_stock__c();
                                latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get(countryText).getRecordTypeId();
                                latS.LAT_Branch__c = respItem.businessUnit.trim();
                                latS.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                latS.LAT_JDE_Error__c = jdeErrorMessage;
                                latS.LAT_ExternalId__c = keyStock;
                                mapKeyStock.get(keyStock);
                                listOfStockToUpsert.add(latS);
                            }
                        } else {
                            //Quantity for e/product
                            Integer responseNumber = Integer.valueOf(Decimal.valueOf(respItem.response));
                            if ( mapKeyStock.get(keyStock) != null ) {
                                Lat_stock__c ls = mapKeyStock.get(keyStock);
                                ls.LAT_Stock__c = responseNumber;
                                ls.LAT_Last_Update__c = Datetime.now();
                                listOfStockToUpsert.add(ls);

                            } else {
                                //Create Lat_stock if not exists
                                Lat_Stock__c latS = new Lat_stock__c();
                                latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get( countryText ).getRecordTypeId();
                                latS.LAT_Stock__c = responseNumber;
                                latS.LAT_Branch__c = respItem.businessUnit.trim();
                                latS.LAT_Product__c = mapProducts.get( codPais + '-' + respItem.sku.trim() );
                                latS.LAT_Last_Update__c = Datetime.now();
                                latS.LAT_ExternalId__c = keyStock;
                                mapKeyStock.get(keyStock);
                                listOfStockToUpsert.add(latS);
                            }
                        }
                    }
                 }


                 upsert listOfStockToUpsert LAT_ExternalId__c;
                 return createJsonResponse (listOfStockToUpsert);

         } catch (Exception e) {
            system.debug('Error Expection  -----> ' + e.getMessage());
            debug.addTitle('Unexpected Error');
            debug.addData('Error', e.getMessage());
            if (debug.getDebugInfo().Id == null) debug.insertDebug();
                 
            return e.getMessage();
         }

    }


    public static LAT_GetStockTypes.ClientInfoType getConnectionParameter(String country){
        LAT_GetStockTypes.ClientInfoType connParms = new LAT_GetStockTypes.ClientInfoType();
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        if(cred!=null){
            connParms.country = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x=Datetime.now();
        }
        return connParms;
    }

    private static String createJsonResponse(List<LAT_Stock__c> listOfStockToUpsert) {
        String retorno = '[';
        Boolean primer = true;
        for (LAT_Stock__c stk : listOfStockToUpsert) {

            if (!primer) {
                retorno = retorno + ',';
            }
            retorno = retorno + '{"'+ stk.LAT_ExternalId__c.split('-')[1] + '" : "' + stk.LAT_Stock__c + '"}' ; 
            primer = false;
        }

        retorno = retorno + ']';
        return retorno;
    }
}