/**
* @author: zimmic (hello@zimmic.com)
* @descp: Class to handle all calls to Stock Availibity in JDE (It references calls to SOA)
* @date: 5/5/16 
**/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

global class LAT_StockAvailabilityInterface {

    
    private static LAT_Log__c logAsRegistry;
    private static LAT_DebugUtil debug;
    public static Map<String,Integer> countryCodes = new Map<String,Integer>{'ARS'=>6,'UYU'=>5,'MXN'=>12,'BRL'=>1};


    /*
    * @descp: method as interfacte to call getStock WS (SOA)
    * @param: It will recieve a list of Opportunity Line Items and Opp Id
    * @return: It will return an empty string if everything went ok, otherwise will return error message. 
    */
    public static String stockAvailibity(List<OpportunityLineItem> listOlis,String oppId){

        debug = new LAT_DebugUtil();
        debug.setOrigin('StockAvailabilityInterface');
        try{
            Opportunity opp = [SELECT Id, Pricebook2Id, Pricebook2.Name, RecordType.Name, 
                                    Account.RecordTypeId,
                                    AccountId, Account.Payment_Condition__r.Internal_Id__c, 
                                    RecordType.DeveloperName, 
                                    Account.LAT_MX_AvailableCreditLimit__c, Account.Client_country_AN8__c,
                                    Account.Business_Unit__r.CodDefUsuario__c, Account.Business_Unit_AR__r.CodDefUsuario__c
                               FROM Opportunity 
                               WHERE Id =: oppId];

            String countryText = LAT_WS_CustomerHandlerInterface.getCountryInfo(opp.Account.RecordTypeId);
            system.debug('contry text: ' + countryText);
            Integer codPais ;

            if(countryText == 'Brasil') 
            codPais = countryCodes.get('BRL');
            else if (countryText == 'Argentina')
            codPais = countryCodes.get('ARS');
            else if (countryText == 'México')
            codPais = countryCodes.get('MXN');
            else 
            codPais = countryCodes.get('UYU');
            system.debug('codPais: ' + codPais);

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
             for(OpportunityLineItem oli : listOlis){

                itemType = new Lat_GetStockTypes.ItemType();
                itemType.sku = oli.LAT_SkuText__c;
                itemType.businessUnit = countryText == 'Brasil' ? opp.Account.Business_Unit__r.CodDefUsuario__c : opp.Account.Business_Unit_AR__r.CodDefUsuario__c; 
                itemType.unitOfMeasure = oli.UOM_AR__c != null ? oli.UOM_AR__c : 'CA';
                itemType.idType = 'itemProduct'; //hardcoded value

                stockKeys.add(codPais+'-'+itemType.sku+'-'+itemType.businessUnit);
                productsExtIds.add(codPais+'-'+itemType.sku);
                listOfItems.add(itemType);

                debug.addSubTitle('SKU');
                debug.addData('unitOfMeasure', itemType.unitOfMeasure);
                debug.addData('sku', itemType.sku);
                debug.addData('businessUnit', itemType.businessUnit);
             }

             for(Product2 prod : [Select Id,
                                    Internal_Id__c 
                                    From Product2 
                                    where Internal_Id__c in :productsExtIds]){
                                    mapProducts.put(prod.Internal_id__c,prod.Id);
             }

             Lat_GetStockTypes.ItemListType itemList = new Lat_GetStockTypes.ItemListType();
             itemList.item = listOfItems;
            if(!Test.isRunningTest()){
                response = request.getStockOperation(getConnectionParameter(countryText),itemList);
            }else{ 
                response = LAT_StockAvailabilityInterfaceTest.getResponse();

            }
             List<LAT_Stock__c> listOfStockToUpsert = new List<LAT_Stock__c>();
             Map<String,LAT_Stock__c> mapKeyStock = new Map<String,LAT_Stock__c>();

             //Get list of existing Lat_Stock records to upsert based on the List recieved
             List<Lat_stock__c> lsList = [Select Id,
                                                 LAT_Branch__c,
                                                 LAT_Stock__c,
                                                 Product__r.Internal_Id__c,
                                                 LAT_Unit__c,
                                                 LAT_ExternalId__c 
                                         From Lat_Stock__c 
                                         Where LAT_ExternalId__c IN :stockKeys];
             
             if(lsList != null){
                for(Lat_Stock__c ls : lsList){
                    if(ls.Product__r.Internal_Id__c != null){
                        mapKeyStock.put(ls.Product__r.Internal_Id__c+'-'+ls.LAT_Branch__c,ls);
                    }
                }
             }

             String keyStock = '';
             Set<String> keyOfStocks = new Set<String>();
             debug.addTitle('Response');
             debug.addData('mapItems', String.ValueOf(response.itemResponse));
             for(Lat_GetStockTypes.ItemResponseType respItem : response.itemResponse){

                if(respItem.sku.trim() != null && respItem.businessUnit.trim() != null && respItem.response != null){
                    
                        //String responseValue = respItem.response;
                        //check if response it's an error
                        keyStock = codPais+'-'+respItem.sku.trim()+'-'+respItem.businessUnit.trim();
                        String jdeErrorMessage = respItem.errorJDE != null ? respItem.errorJDE : null;
                        if(jdeErrorMessage != null && jdeErrorMessage != ''){
                            if(mapKeyStock.get(keyStock) != null){
                                Lat_stock__c ls = mapKeyStock.get(keyStock);
                                ls.LAT_JDE_Error__c = jdeErrorMessage;
                                ls.Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                listOfStockToUpsert.add(ls);
                            }else{
                                Lat_Stock__c latS = new Lat_stock__c();
                                latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get(countryText).getRecordTypeId();
                                latS.LAT_Branch__c = respItem.businessUnit.trim();
                                latS.Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                latS.LAT_JDE_Error__c = jdeErrorMessage;
                                latS.LAT_ExternalId__c = keyStock;
                                mapKeyStock.get(keyStock);
                                listOfStockToUpsert.add(latS);
                            }
                        }else{
                             //Quantity for e/product
                             Integer responseNumber = Integer.valueOf(Decimal.valueOf(respItem.response));
                             if(mapKeyStock.get(keyStock) != null){
                                    Lat_stock__c ls = mapKeyStock.get(keyStock);
                                    ls.LAT_Stock__c = responseNumber;
                                    ls.LAT_Last_Update__c = Datetime.now();
                                    listOfStockToUpsert.add(ls);

                             }else{
                                    //Create Lat_stock if not exists
                                    Lat_Stock__c latS = new Lat_stock__c();
                                    latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get(countryText).getRecordTypeId();
                                    latS.LAT_Stock__c = responseNumber;
                                    latS.LAT_Branch__c = respItem.businessUnit.trim();
                                    latS.Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                    latS.LAT_Last_Update__c = Datetime.now();
                                    latS.LAT_ExternalId__c = keyStock;
                                    mapKeyStock.get(keyStock);
                                    listOfStockToUpsert.add(latS);
                             }
                        }
                    }
                 }

                 upsert listOfStockToUpsert LAT_ExternalId__c;
                 return '';

         }catch(Exception e){
            system.debug('Error Expection  -----> ' + e.getMessage());
            debug.addTitle('Unexpected Error');
            debug.addData('Error', e.getMessage());
            if(debug.getDebugInfo().Id == null)debug.insertDebug();
                 
            return e.getMessage();
         }

    }
    //MIGRATED 07/11/2016
    public static String stockAvailibity(List<LAT_OpportunityLineItem__c> listOlis,String oppId){

        debug = new LAT_DebugUtil();
        debug.setOrigin('StockAvailabilityInterface');
        try{
            LAT_Opportunity__c opp = [SELECT Id, RecordType.Name, 
                                    LAT_Account__r.RecordTypeId,
                                    LAT_Account__c, LAT_Account__r.Payment_Condition__r.Internal_Id__c, 
                                    RecordType.DeveloperName, 
                                    LAT_Account__r.LAT_MX_AvailableCreditLimit__c, LAT_Account__r.Client_country_AN8__c,
                                    LAT_Account__r.Business_Unit__r.CodDefUsuario__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c
                               FROM LAT_Opportunity__c 
                               WHERE Id =: oppId];

            String countryText = LAT_WS_CustomerHandlerInterface.getCountryInfo(opp.LAT_Account__r.RecordTypeId);
            system.debug('contry text: ' + countryText);
            Integer codPais ;

            if(countryText == 'Brasil') 
            codPais = countryCodes.get('BRL');
            else if (countryText == 'Argentina')
            codPais = countryCodes.get('ARS');
            else if (countryText == 'México')
            codPais = countryCodes.get('MXN');
            else 
            codPais = countryCodes.get('UYU');
            system.debug('codPais: ' + codPais);

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
             for(LAT_OpportunityLineItem__c oli : listOlis){

                itemType = new Lat_GetStockTypes.ItemType();
                itemType.sku = oli.LAT_SkuText__c;
                itemType.businessUnit = countryText == 'Brasil' ? opp.LAT_Account__r.Business_Unit__r.CodDefUsuario__c : opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c; 
                itemType.unitOfMeasure = oli.LAT_AR_UOM__c != null ? oli.LAT_AR_UOM__c : 'CA';
                itemType.idType = 'itemProduct'; //hardcoded value

                stockKeys.add(codPais+'-'+itemType.sku+'-'+itemType.businessUnit);
                productsExtIds.add(codPais+'-'+itemType.sku);
                listOfItems.add(itemType);

                debug.addSubTitle('SKU');
                debug.addData('unitOfMeasure', itemType.unitOfMeasure);
                debug.addData('sku', itemType.sku);
                debug.addData('businessUnit', itemType.businessUnit);
                System.debug('businessUnit'+ itemType.businessUnit);
             }

             for(LAT_Product__c prod : [Select Id,
                                    LAT_ExternalID__c 
                                    From LAT_Product__c 
                                    where LAT_ExternalID__c in :productsExtIds]){
                                    mapProducts.put(prod.LAT_ExternalID__c,prod.Id);
             }

             Lat_GetStockTypes.ItemListType itemList = new Lat_GetStockTypes.ItemListType();
             itemList.item = listOfItems;
            if(!Test.isRunningTest()){
                response = request.getStockOperation(getConnectionParameter(countryText),itemList);
            }else{ 
                response = LAT_StockAvailabilityInterfaceTest.getResponse();

            }
             List<LAT_Stock__c> listOfStockToUpsert = new List<LAT_Stock__c>();
             Map<String,LAT_Stock__c> mapKeyStock = new Map<String,LAT_Stock__c>();

             //Get list of existing Lat_Stock records to upsert based on the List recieved
             List<Lat_stock__c> lsList = [Select Id,
                                                 LAT_Branch__c,
                                                 LAT_Stock__c,
                                                 LAT_Product__r.LAT_ExternalID__c,
                                                 LAT_Unit__c,
                                                 LAT_ExternalId__c 
                                         From Lat_Stock__c 
                                         Where LAT_ExternalId__c IN :stockKeys];
             
             if(lsList != null){
                for(Lat_Stock__c ls : lsList){
                    if(ls.LAT_Product__r.LAT_ExternalID__c != null){
                        mapKeyStock.put(ls.LAT_Product__r.LAT_ExternalID__c+'-'+ls.LAT_Branch__c,ls);
                    }
                }
             }

             String keyStock = '';
             Set<String> keyOfStocks = new Set<String>();
             debug.addTitle('Response');
             debug.addData('mapItems', String.ValueOf(response.itemResponse));
             for(Lat_GetStockTypes.ItemResponseType respItem : response.itemResponse){

                if(respItem.sku.trim() != null && respItem.businessUnit.trim() != null && respItem.response != null){
                    
                        //String responseValue = respItem.response;
                        //check if response it's an error
                        keyStock = codPais+'-'+respItem.sku.trim()+'-'+respItem.businessUnit.trim();
                        String jdeErrorMessage = respItem.errorJDE != null ? respItem.errorJDE : null;
                        if(jdeErrorMessage != null && jdeErrorMessage != ''){
                            if(mapKeyStock.get(keyStock) != null){
                                Lat_stock__c ls = mapKeyStock.get(keyStock);
                                ls.LAT_JDE_Error__c = jdeErrorMessage;
                                ls.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                listOfStockToUpsert.add(ls);
                            }else{
                                Lat_Stock__c latS = new Lat_stock__c();
                                latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get(countryText).getRecordTypeId();
                                latS.LAT_Branch__c = respItem.businessUnit.trim();
                                latS.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                latS.LAT_JDE_Error__c = jdeErrorMessage;
                                latS.LAT_ExternalId__c = keyStock;
                                mapKeyStock.get(keyStock);
                                listOfStockToUpsert.add(latS);
                            }
                        }else{
                             //Quantity for e/product
                             Integer responseNumber = Integer.valueOf(Decimal.valueOf(respItem.response));
                             if(mapKeyStock.get(keyStock) != null){
                                    Lat_stock__c ls = mapKeyStock.get(keyStock);
                                    ls.LAT_Stock__c = responseNumber;
                                    ls.LAT_Last_Update__c = Datetime.now();
                                    listOfStockToUpsert.add(ls);

                             }else{
                                    //Create Lat_stock if not exists
                                    Lat_Stock__c latS = new Lat_stock__c();
                                    latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get(countryText).getRecordTypeId();
                                    latS.LAT_Stock__c = responseNumber;
                                    latS.LAT_Branch__c = respItem.businessUnit.trim();
                                    latS.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                    latS.LAT_Last_Update__c = Datetime.now();
                                    latS.LAT_ExternalId__c = keyStock;
                                    mapKeyStock.get(keyStock);
                                    listOfStockToUpsert.add(latS);
                             }
                        }
                    }
                 }

                 upsert listOfStockToUpsert LAT_ExternalId__c;
                 return '';

         }catch(Exception e){
            system.debug('Error Expection  -----> ' + e.getMessage());
            debug.addTitle('Unexpected Error');
            debug.addData('Error', e.getMessage());
            if(debug.getDebugInfo().Id == null)debug.insertDebug();
                 
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

    public Static List<Lat_Stock__c> getStockBatch(String countryText, String businessUnit, String unitOfMeasure, List<LAT_Product__c> prods) {
        
        try{
            

            system.debug('contry text: ' + countryText);
            Integer codPais ;

            if(countryText == 'Brasil') 
            codPais = countryCodes.get('BRL');
            else if (countryText == 'Argentina')
            codPais = countryCodes.get('ARS');
            else if (countryText == 'México')
            codPais = countryCodes.get('MXN');
            else 
            codPais = countryCodes.get('UYU');
            system.debug('codPais: ' + codPais);

            
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
             for(LAT_Product__c prod : prods){

                itemType = new Lat_GetStockTypes.ItemType();
                itemType.sku = prod.LAT_Sku__c;
                itemType.businessUnit = businessUnit; 
                itemType.unitOfMeasure = unitOfMeasure;
                itemType.idType = 'itemProduct'; //hardcoded value

                stockKeys.add(codPais+'-'+itemType.sku+'-'+itemType.businessUnit);
                productsExtIds.add(codPais+'-'+itemType.sku);
                listOfItems.add(itemType);

                System.debug('businessUnit'+ itemType.businessUnit + ' || sku :' +itemType.sku+ ' || unitOfMeasure : '+itemType.unitOfMeasure);
             }

             for(LAT_Product__c prod : [Select Id,
                                    LAT_ExternalID__c 
                                    From LAT_Product__c 
                                    where LAT_ExternalID__c in :productsExtIds]){
                                    mapProducts.put(prod.LAT_ExternalID__c,prod.Id);
             }

             Lat_GetStockTypes.ItemListType itemList = new Lat_GetStockTypes.ItemListType();
             itemList.item = listOfItems;

            if(!Test.isRunningTest()){
                response = request.getStockOperation(getConnectionParameter(countryText),itemList);
            }else{ 
                response = LAT_StockAvailabilityInterfaceTest.getResponse();

            }
            System.debug('%%%%% response : ' + response);
             List<LAT_Stock__c> listOfStockToUpsert = new List<LAT_Stock__c>();
             Map<String,LAT_Stock__c> mapKeyStock = new Map<String,LAT_Stock__c>();

             //Get list of existing Lat_Stock records to upsert based on the List recieved
             List<Lat_stock__c> lsList = [Select Id,
                                                 LAT_Branch__c,
                                                 LAT_Stock__c,
                                                 LAT_Product__r.LAT_ExternalID__c,
                                                 LAT_Unit__c,
                                                 LAT_ExternalId__c 
                                         From Lat_Stock__c 
                                         Where LAT_ExternalId__c IN :stockKeys];
             
             if(lsList != null){
                for(Lat_Stock__c ls : lsList){
                    if(ls.LAT_Product__r.LAT_ExternalID__c != null){
                        mapKeyStock.put(ls.LAT_Product__r.LAT_ExternalID__c+'-'+ls.LAT_Branch__c,ls);
                    }
                }
             }

             String keyStock = '';
             Set<String> keyOfStocks = new Set<String>();
             for(Lat_GetStockTypes.ItemResponseType respItem : response.itemResponse){
                System.debug('%%%% respItem : '+ respItem);
                if(respItem.sku.trim() != null && respItem.businessUnit.trim() != null && respItem.response != null){
                    
                        //String responseValue = respItem.response;
                        //check if response it's an error
                        keyStock = codPais+'-'+respItem.sku.trim()+'-'+respItem.businessUnit.trim();
                        String jdeErrorMessage = respItem.errorJDE != null ? respItem.errorJDE : null;
                        if(jdeErrorMessage != null && jdeErrorMessage != ''){
                            if(mapKeyStock.get(keyStock) != null){
                                Lat_stock__c ls = mapKeyStock.get(keyStock);
                                ls.LAT_JDE_Error__c = jdeErrorMessage.abbreviate(254);
                                ls.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                listOfStockToUpsert.add(ls);
                            }else{
                                Lat_Stock__c latS = new Lat_stock__c();
                                latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get(countryText).getRecordTypeId();
                                latS.LAT_Branch__c = respItem.businessUnit.trim();
                                latS.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                latS.LAT_JDE_Error__c = jdeErrorMessage.abbreviate(254);
                                latS.LAT_ExternalId__c = keyStock;
                                mapKeyStock.put(keyStock, latS);
                                listOfStockToUpsert.add(latS);
                            }
                        }else{
                             //Quantity for e/product
                             Integer responseNumber = Integer.valueOf(Decimal.valueOf(respItem.response));
                             if(mapKeyStock.get(keyStock) != null){
                                    Lat_stock__c ls = mapKeyStock.get(keyStock);
                                    ls.LAT_Stock__c = responseNumber;
                                    ls.LAT_Last_Update__c = Datetime.now();
                                    listOfStockToUpsert.add(ls);

                             }else{
                                    //Create Lat_stock if not exists
                                    Lat_Stock__c latS = new Lat_stock__c();
                                    latS.RecordTypeId = Schema.SObjectType.Lat_Stock__c.getRecordTypeInfosByName().get(countryText).getRecordTypeId();
                                    latS.LAT_Stock__c = responseNumber;
                                    latS.LAT_Branch__c = respItem.businessUnit.trim();
                                    latS.LAT_Product__c = mapProducts.get(codPais+'-'+respItem.sku.trim());
                                    latS.LAT_Last_Update__c = Datetime.now();
                                    latS.LAT_ExternalId__c = keyStock;
                                    mapKeyStock.get(keyStock);
                                    listOfStockToUpsert.add(latS);
                             }
                        }
                    }
                 }
                System.debug('Termino de ejecutar en LAT_StockAvailabilityInterface');
                return listOfStockToUpsert;
                 
                

         }catch(Exception e){
           
            System.debug('Error en LAT_StockAvailabilityInterfaceTest.getStockBatch : ' + e.getMessage());
            System.debug('Error en LAT_StockAvailabilityInterfaceTest.getStockBatch linea : ' + e.getLineNumber()); 
            System.debug('Error en LAT_StockAvailabilityInterfaceTest.getStockBatch trace : ' + e.getStackTraceString()); 
            return null;
         }
    }
}