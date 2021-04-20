/**********************************************************************************************************************************

    Developer: Francisco Orzabal
    Created Date: 06/06/2014

    Description:

    Last Modified Date:
    Last Developer:

    Versión:
    V1.0 - 06/06/2014 - Initial version [FO]

/**********************************************************************************************************************************/

global class LAT_Utils {
    public static Map<String,Integer> CountryCodes = new Map<String,Integer>{ 'ARS' => 6, 'UYU' => 5, 'MXN' => 12, 'BRL' => 1 };

    static final String beginTable = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00002_AR+'</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
    static final String beginTableWithDiscount = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00004_AR+ '</center></b></td><td width="280px"><b><center>' + System.Label.VF_VTS_00002_AR+'</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
    static final String beginTableHeader = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
    static final String endTable = '</font></table>';
    private static Map<string, string> mapFIeldsIds;
    public static Boolean migro;
    public static boolean testOn;
    webservice static string getFieldId (string objectApiName, string fieldApiName) {

        if (mapFIeldsIds == null) {

            mapFIeldsIds = new Map<string, string>();

            List<CS002_FIeldsIds__c> listFIeldsIds = [SELECT Id, FieldApiName__c, FieldId__c, ObjectApiName__c
                                                    FROM CS002_FIeldsIds__c];

            for (CS002_FIeldsIds__c fi : listFIeldsIds) {
                mapFIeldsIds.put(fi.ObjectApiName__c + fi.FieldApiName__c, fi.FieldId__c);
            }

        }

        if (mapFIeldsIds.containsKey(objectApiName + fieldApiName)) {

            return mapFIeldsIds.get(objectApiName + fieldApiName);

        } else {

            string fieldId = getFieldIdWS(objectApiName, fieldApiName);

            CS002_FIeldsIds__c fi = new CS002_FIeldsIds__c(Name = fieldApiName + '-' + objectApiName,
                                                            ObjectApiName__c = objectApiName,
                                                            FieldApiName__c = fieldApiName,
                                                            FieldId__c = fieldId);

            DataBase.insert(fi);

            return fieldId;

        }

        return null;

    }

    webservice static Id getRtId(String SobjectTypeDevName){
        return Global_RecordTypeCache.getRtId(SobjectTypeDevName);
    }
    webservice static boolean wasMigrationDone(string countryCode){
        return  Utils.wasMigrationDone(countryCode);
    
    }
    webservice static string getFieldId2 (string objectApiName, string fieldApiName) {

        if (mapFIeldsIds == null) {

            mapFIeldsIds = new Map<string, string>();

            List<CS002_FIeldsIds__c> listFIeldsIds = [SELECT Id, FieldApiName__c, FieldId__c, ObjectApiName__c
                                                    FROM CS002_FIeldsIds__c];

            for (CS002_FIeldsIds__c fi : listFIeldsIds) {
                mapFIeldsIds.put(fi.ObjectApiName__c + fi.FieldApiName__c, fi.FieldId__c);
            }

        }

        if (mapFIeldsIds.containsKey(objectApiName + fieldApiName)) {

            return mapFIeldsIds.get(objectApiName + fieldApiName);

        } else {

            string fieldId = getFieldIdWS(objectApiName, fieldApiName);

            CS002_FIeldsIds__c fi = new CS002_FIeldsIds__c(Name = fieldApiName + '-' + objectApiName,
                                                            ObjectApiName__c = objectApiName,
                                                            FieldApiName__c = fieldApiName,
                                                            FieldId__c = fieldId);

            DataBase.insert(fi);

            return fieldId;

        }

        return null;

    }

    //Get ids of fields
    private static String getFieldIdWS (String theObject, String theField) {

        String toolingendpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v37.0/tooling/';
        string idOrNameOfObject;
        // Get Id of Custom Sobject

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(theObject);
        DescribeSobjectResult descr = targetType.getDescribe();

        // Si el objeto es custom, obtenemos su id.
        if(descr.isCustom()) {
            HttpRequest reqo = new HttpRequest();
            reqo.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            reqo.setHeader('Content-Type', 'application/json');

            String queryObject = 'query/?q=select+Id,DeveloperName,NamespacePrefix+from+CustomObject+where+DeveloperName+=+\''+theObject.removeEnd('__c')+'\'+LIMIT+10';
            reqo.setEndpoint(toolingendpoint + queryObject);
            reqo.setMethod('GET');

            Http ho = new Http();
            if(!Test.isRunningTest()) {
                HttpResponse reso = ho.send(reqo);
                idOrNameOfObject = reso.getBody().substringBetween('"Id":"','"');
            }
        // Si el objeto es estandar directamente utilizamos el nombre que nos pasaron por parametro.
        } else {

            idOrNameOfObject = theObject;

        }

        // Get field Id of Sobject
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');

        String queryField = 'query/?q=select+id,DeveloperName,FullName,Metadata,TableEnumOrId+from+CustomField+where+TableEnumOrId+=+\''+idOrNameOfObject+'\'+AND+DeveloperName+=+\''+theField.removeEnd('__c')+'\'+limit+10';
        system.debug('queryField: ' + queryField);
        req.setEndpoint(toolingendpoint + queryField);
        req.setMethod('GET');

        Http h = new Http();
        if(!Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            system.debug('res: ' + res);
            string idOfField = res.getBody().substringBetween('"Id":"','"');
            return idOfField;
        } else {
            return idOrNameOfObject;
        }


    }

    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List <List <String>> allFields = new List<List<String>>();

        System.debug('111111111111111' + contents);
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');

        System.debug('22222222222222222' + contents);
        contents = contents.replaceAll('""','DBLQT');

        System.debug('33333333333333333' + contents);
        List <String> lines = new List<String>();
        try {
            lines = contents.split('\n');

        System.debug('444444444444444444' + lines);
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
          System.debug('line' + line);
            // check for blank CSV lines (only commas)
            //if (line.replaceAll(',','').trim().length() == 0) continue;
            if (line.replaceAll(';','').trim().length() == 0) continue;

            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields a: ' + line);
            List <String> fields = line.split(';');
            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields b: ' + fields);
            //if (fields.size() == 1) {
            //    fields = line.split(';');
            //}

            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields c: ' + fields);
            List <String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                    System.debug('$$$$$$$$$$$$$$$$$$ in 1' + field);
                } else if (field.startsWith('"')) {
                      makeCompositeField = true;
                      compositeField = field;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 2' + field);
                } else if (field.endsWith('"')) {
                      compositeField += ',' + field;
                      cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                      makeCompositeField = false;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 3' + field);
                } else if (makeCompositeField) {
                      compositeField +=  ',' + field;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 4' + field);
                } else {
                      cleanFields.add(field.trim());
                      System.debug('$$$$$$$$$$$$$$$$$$ in 5' + field);
                }
            }
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;
    }

    webservice static String getObjectId(String objectName){
        if (mapFIeldsIds == null) {

            mapFIeldsIds = new Map<string, string>();

            List<CS002_FIeldsIds__c> listFIeldsIds = [SELECT Id, FieldApiName__c, FieldId__c, ObjectApiName__c
                                                    FROM CS002_FIeldsIds__c];

            for (CS002_FIeldsIds__c fi : listFIeldsIds) {
                mapFIeldsIds.put(fi.ObjectApiName__c + fi.FieldApiName__c, fi.FieldId__c);
            }

        }

        if (mapFIeldsIds.containsKey(objectName + 'Id')) {

            return mapFIeldsIds.get(objectName + 'Id');

        } else {

            string fieldId = getObjectIdWS(objectName);

            CS002_FIeldsIds__c fi = new CS002_FIeldsIds__c(Name = 'Id' + '-' + objectName,
                                                            ObjectApiName__c = objectName,
                                                            FieldApiName__c = 'Id',
                                                            FieldId__c = fieldId);

            DataBase.insert(fi);

            return fieldId;

        }

        return null;


    }

    webservice static String getObjectIdWS(String objectName){

        //Get ids of fields
        String toolingendpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v37.0/tooling/';
        string idOrNameOfObject;
        // Get Id of Custom Sobject

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        DescribeSobjectResult descr = targetType.getDescribe();

        // Si el objeto es custom, obtenemos su id.
        if(descr.isCustom()) {
            HttpRequest reqo = new HttpRequest();
            reqo.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            reqo.setHeader('Content-Type', 'application/json');

            String queryObject = 'query/?q=select+Id,DeveloperName,NamespacePrefix+from+CustomObject+where+DeveloperName+=+\''+objectName.removeEnd('__c')+'\'+LIMIT+10';
            reqo.setEndpoint(toolingendpoint + queryObject);
            reqo.setMethod('GET');

            Http ho = new Http();
            if(!Test.isRunningTest()) {
                HttpResponse reso = ho.send(reqo);
                idOrNameOfObject = reso.getBody().substringBetween('"Id":"','"');
            }
           

        // Si el objeto es estandar directamente utilizamos el nombre que nos pasaron por parametro.
        } else {
            idOrNameOfObject = objectName;
        }
        return idOrNameOfObject;


    }

    public static Boolean isRunningTest(){
        if(testOn==null){
            testOn=false;
        }
        return Test.isRunningTest() && testOn;
    }
    
    /**
     * Get a Map of Lat_Accounts by their parent account
     * @param objs - accounts to get the ids from (its a Sobject to be used from the lat_triggers)
     * @return Map of <parentAccountId, LatAccount__c>
     */
    public static Map<Id, Lat_Account__c> getLatAccountMapByAccId(List<Sobject> objs){
        system.debug('accId++' + objs);
        Set<Id> accsId = new Set<Id>();
        for (Sobject obj:objs){
            accsId.add(obj.Id);
            system.debug('accId++' + obj.Id);
        }
        Map<Id, Lat_Account__c> retMap = new Map<Id, Lat_Account__c> ();
        List<Lat_Account__c> latAccs = [SELECT Id, Name, LAT_Owner_Changed__c, Client_type_revert__c, Obtained_POLiTICA_DE_PRECO_Udc_revert__c,
                                        	Sub_channel_revert__c, TBCI_revert__c, channel_revert__c, Beneficio_Fiscal_revert__c,
                                            Politica_Preco_Origin_revert__c, Estrategia_comercial_revert__c, FORMATO_revert__c,
                                            Perfil_revert__c, PRIOR_DE_INVESTIMENTO_revert__c, Segment_revert__c,
        									Lat_DirectSale__c, LAT_BR_Segmentation__r.Client_type__c, Lat_AccountId__c, 
                                        	LAT_Rating_Before_Approval__c, LAT_Status_Before_Approval__c, LAT_Approval_Revert_RecordType__c,
        									LAT_RtId_Before_Approval__c, LAT_BR_StatusDueDiligence__c, 
                                            LAT_BR_DataDueDiligence__c, LAT_BR_PurchaseForecast__c, LAT_BR_Comments__c
								        FROM Lat_Account__c WHERE Lat_AccountId__c IN :accsId];
        System.debug('+++adds+'+ latAccs);
        for (Lat_Account__c latAcc : latAccs){
            System.debug('+++add+'+ latAcc);
            retMap.put(latAcc.Lat_AccountId__c, latAcc);
        }
        System.debug('+++BEFORERET+'+ retMap);
        return retMap;
    }

    /**
     * Generate a html table to save in the OpptyLineItem__c
     * @param lineItem - Wrapper Object that comes is parse from the soap callout
     * @return - generated table
     */
    public static String generatePriceTableForLineItem(LAT_MX_PriceCalculation.PriceCatalogueDetailsOutput lineItem){

        system.debug('generatingTable+++' + lineItem);
        String table = '';
        String discountsTotal = '';
        // Informacion basica
        String rowCanal2Descuento = '';
        String descuentos = '';
        String impuestos = '';
        String rowSubtotal = '';
        String rowPrecioLista = '';
        String rowTotales = '';
        Decimal unitTotal = 0;
        Decimal total = 0;
        Decimal ivaPerUnit = (lineItem.amountTax / lineItem.quantityOrdered).setScale(2);
        Decimal IEPSPerUnit = (lineItem.amountExcise / lineItem.quantityOrdered).setScale(2);
        // Line 1 - Precio de Lista
        rowPrecioLista = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00032 + '</td> <td align="right" width="120px">' + formatNumber(lineItem.unitPriceExclusiveDiscountsAndCharges.setScale(2))+ '</td> <td align="right" width="120px">' +formatNumber(lineItem.amountExclusiveDiscountsAndCharges.setScale(2))+ '</td></tr>';
        unitTotal = lineItem.unitPriceExclusiveDiscountsAndCharges.setScale(2);
        total = lineItem.amountExclusiveDiscountsAndCharges.setScale(2);
        //Line 2 - Descuento Canal 2
        rowSubtotal =  '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00033 + '</td> <td align="right" width="120px">' + formatNumber(lineItem.unitPrice.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber(lineItem.amountTaxable.setScale(2))+ '</td></tr>';
        String rowIVA = '<tr><td width="250px">'+ 'IVA' + '</td> <td align="right" width="120px">' + formatNumber(ivaPerUnit) + '</td> <td align="right" width="120px">' +formatNumber( lineItem.amountTax.setScale(2))+ '</td></tr>';
            
        String rowIEPS = '<tr><td width="250px">'+ 'IEPS' + '</td> <td align="right" width="120px">' + formatNumber(IEPSPerUnit) + '</td> <td align="right" width="120px">' + formatNumber(lineItem.amountExcise.setScale(2)) + '</td></tr>';
        if (lineItem.discountAndChargeDetails != null) {    
            for (LAT_MX_PriceCalculation.discountAndChargeDetailsOutput discount: lineItem.discountAndChargeDetails ) {
                if (discount.discountOrChargeType.trim().equals('D')){
                    descuentos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                    unitTotal += discount.unitDiscountOrCharge.setScale(2);
                    total += discount.amountDiscountOrCharge.setScale(2);
                } else if (discount.discountOrChargeType.trim().equals('C')) {
                        //impuestos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                        //unitTotal += discount.unitDiscountOrCharge.setScale(2);
                        //total += discount.amountDiscountOrCharge.setScale(2);
                } else if (discount.discountOrChargeType.trim().equals('O')) {
                        //otros += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                }
            }
        }
        impuestos = rowIVA + rowIEPS;
        total += (lineItem.amountExcise + lineItem.amountTax).setScale(2);
        // FALTA EL ROW TOTALES
        rowTotales = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00034 + '</td> <td align="right" width="120px">' + formatNumber( (total/lineItem.quantityOrdered).setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( total.setScale(2) )+ '</td></tr>';
         
        discountsTotal = rowPrecioLista + descuentos + rowSubtotal + impuestos + rowTotales;  

        // Hay que ver si no va con header
        table = beginTable + discountsTotal + endTable;
        System.debug('Salimos de generatePriceTableForLineItem MX con Tabla : '+ table);
        return table;
    }
    /**
     * Generate a html table to save in the OpptyLineItem__c
     * @param lineItem - Wrapper Object that comes is parse from the soap callout
     * @return - generated table
     */
    public static String generatePriceTableForLineItem(LAT_BR_PriceCalculation.PriceCatalogueDetailsOutput lineItem, String country){

        system.debug('generatingTable+++' + lineItem);
        String headerProduct = '';
        String table = '';
        String discountsTotal = '';
        // Informacion basica
        String descuentos = '';
        String impuestos = '';
        String otros = '';
        String rowSubtotal = '';
        String rowPrecioLista = '';
        String rowTotales = '';
        Decimal unitTotal = 0;
        Decimal total = 0;
        Decimal ivaPerUnit = (lineItem.amountTax / lineItem.quantityOrdered).setScale(2);
        Decimal IEPSPerUnit = (lineItem.amountExcise / lineItem.quantityOrdered).setScale(2);

        //Nuevos totales para ARG
        Decimal percentageTotal = 0;
        Decimal unitDiscountTotal = 0;
        Decimal totalDiscountTotal = 0;
        
        // Header con el nombre del Producto
        headerProduct = '<tr><td width="490px"><b> '+ lineItem.description1 +'</b></td></tr>';
        
        // Line 1 - Precio de Lista
        if(country == '6' || country == '5'){
            rowPrecioLista = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00032 + '</td> <td align="right" width="140px">' + '100%' + '</td> <td align="right" width="140px">' + formatNumber(lineItem.unitPriceExclusiveDiscountsAndCharges.setScale(2))+ '</td> <td align="right" width="120px">' +formatNumber(lineItem.amountExclusiveDiscountsAndCharges.setScale(2))+ '</td></tr>';
        }else{
            rowPrecioLista = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00032 + '</td> <td align="right" width="120px">' + formatNumber(lineItem.unitPriceExclusiveDiscountsAndCharges.setScale(2))+ '</td> <td align="right" width="120px">' +formatNumber(lineItem.amountExclusiveDiscountsAndCharges.setScale(2))+ '</td></tr>';
        }
        
        unitTotal = lineItem.unitPriceExclusiveDiscountsAndCharges.setScale(2);
        total = lineItem.amountExclusiveDiscountsAndCharges.setScale(2);
        
        //Line 2 - Descuento Canal 2
        if(country == '6' || country == '5'){
            rowSubtotal =  '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00033 + '</td> <td align="right" width="140px">' + '</td> <td align="right" width="120px">' + formatNumber(lineItem.unitPrice.setScale(2) )+ '</td> <td align="right" width="140px">' +formatNumber(lineItem.amountTaxable.setScale(2))+ '</td></tr>';
        }else{
            rowSubtotal =  '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00033 + '</td> <td align="right" width="120px">' + formatNumber(lineItem.unitPrice.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber(lineItem.amountTaxable.setScale(2))+ '</td></tr>';
        }
        
        if (lineItem.discountAndChargeDetails != null) {    
            for (LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discount: lineItem.discountAndChargeDetails ) {
                  //generate basic infor unit price, subtotal etc
                if (discount.discountOrChargeType.trim().equals('D')){

                    if(country == '6' || country == '5'){

                        Decimal percentage = (discount.unitDiscountOrCharge/lineItem.unitPriceExclusiveDiscountsAndCharges)*-100;

                        descuentos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="200px">'+ percentage.round() + '%' + '</td> <td align="right" width="140px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                        percentageTotal += percentage;
                        unitDiscountTotal += discount.unitDiscountOrCharge;
                        totalDiscountTotal += discount.amountDiscountOrCharge;

                    }else{
                        descuentos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                    }
                                        
                    unitTotal += discount.unitDiscountOrCharge.setScale(2);
                    total += discount.amountDiscountOrCharge.setScale(2);

                } else if (discount.discountOrChargeType.trim().equals('C')) {

                    if(country == '6' || country == '5'){
                        Decimal percentage = (discount.unitDiscountOrCharge/lineItem.unitPriceExclusiveDiscountsAndCharges)*-100;

                        impuestos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="200px">'+ percentage.round() + '%' + '</td> <td align="right" width="140px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                        percentageTotal += percentage;
                        unitDiscountTotal += discount.unitDiscountOrCharge;
                        totalDiscountTotal += discount.amountDiscountOrCharge;
                        
                    }else{
                        impuestos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                    }
                        
                    unitTotal += discount.unitDiscountOrCharge.setScale(2);
                    total += discount.amountDiscountOrCharge.setScale(2);

                } else if (discount.discountOrChargeType.trim().equals('O')) {

                    if(country == '6' || country == '5'){
                        Decimal percentage = (discount.unitDiscountOrCharge/lineItem.unitPriceExclusiveDiscountsAndCharges)*-100;

                        otros += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="200px">'+ percentage.round() + '%' + '</td> <td align="right" width="120px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                        percentageTotal += percentage;
                        unitDiscountTotal += discount.unitDiscountOrCharge;
                        totalDiscountTotal += discount.amountDiscountOrCharge;

                    }else{
                        otros += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                    }
                        
                }
            }
        }         
        unitTotal += ivaPerUnit + IEPSPerUnit;
        total += (lineItem.amountExcise + lineItem.amountTax).setScale(2);
        // FALTA EL ROW TOTALES
        if(country == '6' || country == '5'){
            rowTotales = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00034 + '</td> <td align="right" width="120px">' + '</td> <td align="right" width="120px">' + formatNumber( unitTotal.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( total.setScale(2) )+ '</td></tr>';                
        }else{
            rowTotales = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00034 + '</td> <td align="right" width="120px">' + formatNumber( unitTotal.setScale(2) )+ '</td> <td align="right" width="120px">' +formatNumber( total.setScale(2) )+ '</td></tr>';                
        }
        
        
        // Hay que ver si no va con header
        if (country == '1') {
            discountsTotal =  otros + descuentos + rowSubtotal + impuestos + rowTotales; 
            table = headerProduct + beginTable +  discountsTotal + endTable;
        } else if(country == '6' || country == '5'){

            impuestos += '<tr><td width="250px">'+ 'Impuestos ' + '</td> <td align="right" width="120px">' + '</td> <td align="right" width="120px">' + formatNumber( lineItem.amountTax.setScale(2)/lineItem.quantityOrdered )+ '</td> <td align="right" width="120px">' +formatNumber( lineItem.amountTax.setScale(2) )+ '</td></tr>';
            
            String totalDescuentos = '<tr class="trBorder"><td width="250px" >'+ 'Total Descuentos ' + '</td> <td align="right" width="120px">' + percentageTotal.round() +'%'+ '</td> <td align="right" width="120px">' + formatNumber(unitDiscountTotal.setScale(2)) + '</td> <td align="right" width="120px">' + formatNumber(totalDiscountTotal.setScale(2)) + '</td> </tr>';

            discountsTotal =  otros + descuentos + totalDescuentos + rowSubtotal + impuestos + rowTotales;
            table = headerProduct + beginTableWithDiscount + rowPrecioLista +  discountsTotal + endTable;
   
            //table = headerProduct + beginTable + rowPrecioLista +  discountsTotal + endTable;
        }else{
            impuestos = '<tr><td width="250px">'+ 'Impuestos ' + '</td> <td align="right" width="120px">' + formatNumber( lineItem.amountTax.setScale(2)/lineItem.quantityOrdered )+ '</td> <td align="right" width="120px">' +formatNumber( lineItem.amountTax.setScale(2) )+ '</td></tr>';
                    
            discountsTotal =  otros + descuentos + rowSubtotal + impuestos + rowTotales;
            table = headerProduct + beginTable + rowPrecioLista +  discountsTotal + endTable;
        }
        System.debug('Salimos de generatePriceTableForLineItem Generico con Tabla : '+ table);
        return table;
    }

    public static Decimal getTotalDiscount(LAT_BR_PriceCalculation.PriceCatalogueDetailsOutput lineItem){

        Decimal percentageTotal = 0;
        
        if (lineItem.discountAndChargeDetails != null) {    
            for (LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discount: lineItem.discountAndChargeDetails ) {
                  //generate basic infor unit price, subtotal etc
                if (discount.discountOrChargeType.trim().equals('D')){

                        Decimal percentage = (discount.unitDiscountOrCharge/lineItem.unitPriceExclusiveDiscountsAndCharges)*-100;

                        percentageTotal += percentage;
                        
                } else if (discount.discountOrChargeType.trim().equals('C')) {

                        Decimal percentage = (discount.unitDiscountOrCharge/lineItem.unitPriceExclusiveDiscountsAndCharges)*-100;

                        percentageTotal += percentage;
                       
                } else if (discount.discountOrChargeType.trim().equals('O')) {

                        Decimal percentage = (discount.unitDiscountOrCharge/lineItem.unitPriceExclusiveDiscountsAndCharges)*-100;

                        percentageTotal += percentage;
                }
            }
        }

        return percentageTotal;
    }


    public static String formatNumber(Decimal aValue){
        aValue.setScale(2);
        return aValue.format();
        //return formatNumber(String.valueOf(aValue));
    }

    public static Map<String, String> retrieveMapProfilePrefix() {
        Map<String, String> mapProfilePrefix = null;
        System.debug('retrieveMapProfilePrefix [] ->');
        
        mapProfilePrefix = new Map<String, String>();
        mapProfilePrefix.put('ARGENTINA', 'LAT_AR2');
        mapProfilePrefix.put('BRASIL', 'LAT_BR2');
        mapProfilePrefix.put('MEXICO', 'LAT_MX2');
        mapProfilePrefix.put('URUGUAY', 'LAT_UY2');
        
        System.debug('retrieveMapProfilePrefix [' + mapProfilePrefix + '] <-');        
        return mapProfilePrefix;
    } 
     
    public static List<User> retrieveUsersInGroup(String strGroupId) {
        List<User> lstUsers = null;
        System.debug('retrieveUsersInGroup [strGroup : ' + strGroupId + '] ->');

        lstUsers = [SELECT Id, Name, Email, isActive, Profile.Name, UserRole.Name, UserType 
                    FROM User 
                    WHERE Id IN (SELECT UserorGroupId  
                                 FROM GroupMember 
                                 WHERE GroupId = :strGroupId) 
                    AND IsActive = TRUE]; 

        System.debug('retrieveUsersInGroup [' + lstUsers + '] <-');
        return lstUsers;
    }
                     
    public static List<User> retrieveUsersByCountry(String strCountry) {
        List<User> lstUser = null;
        Map<String, String> mapUserProfilePrefix = null;
        String strProfilePrefix = null;
        
        System.debug('retrieveUser [strCountry : ' + strCountry + '] ->');
        if(String.isNotBlank(strCountry)) {
            mapUserProfilePrefix = retrieveMapProfilePrefix();
            if(mapUserProfilePrefix.containsKey(strCountry.toUpperCase())) {
                strProfilePrefix = mapUserProfilePrefix.get(strCountry.toUpperCase()) + '%';
                
                lstUser = [SELECT Id 
                           FROM User
                           WHERE Profile.Name LIKE :strProfilePrefix
                           AND IsActive = TRUE];
            } else {
                handleException('retrieveUser', 'No se encontró el país para obtener los perfiles');
            }
        }            

        System.debug('retrieveUser [' + lstUser + '] <-');
        return lstUser;
    }

    public static LAT_GeneralConfig__c createSettings(String strName, String strValue, String strDescription) {
        LAT_GeneralConfig__c objSetting = null;

        System.debug('createSettings [strName : ' + strName + ' - strValue : ' + strValue + ' - strDescription : ' + strDescription + '] ->');

        objSetting = new LAT_GeneralConfig__c();
        objSetting.Name = strName;
        objSetting.LAT_Value__c = strValue;
        objSetting.LAT_Description__c = strDescription;
        insert objSetting;

        System.debug('createSettings [' + objSetting + '] <-');

        return objSetting;
    } 
    
    public static Boolean isJDEUp() {
        Boolean boolIsUp = false;
        String strCountryText = null;
        LAT_Opportunity__c objOpportunity = null;
        List<LAT_GetStockTypes.ItemType> lstItems = null;
        LAT_GetStockTypes.ItemListType objItemList = null;
        LAT_GetStock.port objRequest = null;
        LAT_GetStockTypes.ClientInfoType objClientInfoType = null;
        LAT_GetStockTypes.ItemListResponseType objResponse = null;

        System.debug('isJDEUp [] ->');

        try {
            objOpportunity = retrieveJDEOpportunity();
            strCountryText = LAT_WS_CustomerHandlerInterface.getCountryInfo(objOpportunity.LAT_Account__r.RecordTypeId);
            lstItems = retrieveItemsToCheck(strCountryText, objOpportunity);

            objItemList = new Lat_GetStockTypes.ItemListType();
            objItemList.item = lstItems;
            
            objRequest = new LAT_GetStock.port();
            objRequest.timeout_x = 120000;

            if(!Test.isRunningTest()){
                objClientInfoType = getConnectionParameter(strCountryText);
                System.debug('isJDEUp [objClientInfoType : ' + objClientInfoType + ']');
                objResponse = objRequest.getStockOperation(objClientInfoType, objItemList);
            } else { 
                objResponse = LAT_StockAvailabilityInterfaceTest.getResponse();
            }

            System.debug('isJDEUp [objResponse : ' + objResponse + ']');

            if(objResponse != NULL && objResponse.itemResponse != NULL && objResponse.itemResponse.size() > 0) {
                boolIsUp = true;                 
                System.debug('isJDEUp [Is UP!]');
            }

        } catch(Exception Ex){
            boolIsUp = false;
            handleException('isJDEUp', Ex.getMessage());
        } 

        System.debug('isJDEUp [' + boolIsUp + '] <-');
        return boolIsUp;
    } 
    
    private static LAT_GetStockTypes.ClientInfoType getConnectionParameter(String strCountry){
        LAT_GetStockTypes.ClientInfoType objClientInfoType = null;
        CS001_JDEInterfaceCredentials__c objCredentials = null;

        System.debug('getConnectionParameter [strCountry : ' + strCountry + '] ->');
        objClientInfoType = new LAT_GetStockTypes.ClientInfoType();
        objCredentials = CS001_JDEInterfaceCredentials__c.getInstance(strCountry);
        
        if( objCredentials != null ) {
            objClientInfoType.country = objCredentials.Country__c;
            objClientInfoType.remoteHostIP = objCredentials.RemoteHostIP__c;
            objClientInfoType.system_x = objCredentials.System__c;
            objClientInfoType.systemUserID = objCredentials.SystemUserID__c;
            objClientInfoType.time_x = Datetime.now();
        }

        System.debug('getConnectionParameter [' + objClientInfoType + '] <-');

        return objClientInfoType;
    }

    private static LAT_Opportunity__c retrieveJDEOpportunity() {
        LAT_Opportunity__c objOpportunity = null;
        
        System.debug('retrieveJDEOpportunity [] ->');

        objOpportunity = [  SELECT Id, RecordType.Name, 
                                LAT_Account__r.RecordTypeId,
                                LAT_Account__c, 
                                LAT_Account__r.Payment_Condition__r.Internal_Id__c, 
                                RecordType.DeveloperName, 
                                LAT_Account__r.LAT_MX_AvailableCreditLimit__c, 
                                LAT_Account__r.Client_country_AN8__c,
                                LAT_Account__r.Business_Unit__r.CodDefUsuario__c, 
                                LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c,
                                (
                                    SELECT LAT_SkuText__c,
                                        LAT_AR_UOM__c,
                                        LAT_Opportunity__r.LAT_Account__r.Business_Unit__r.CodDefUsuario__c,
                                        LAT_Opportunity__r.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c
                                    FROM OpportunityLineItems__r
                                    LIMIT 1
                                )
                            FROM LAT_Opportunity__c
                            WHERE LAT_LeadSource__c = 'B2B' 
                            AND LAT_StageName__c != 'Novo Pedido'
                            LIMIT 1];

        System.debug('retrieveJDEOpportunity [' + objOpportunity + '] <-');

        return objOpportunity;
    }

    private static List<LAT_GetStockTypes.ItemType> retrieveItemsToCheck(String strCountryText, LAT_Opportunity__c objOpportunity) {
        List<LAT_GetStockTypes.ItemType> lstOfItems = NULL;
        LAT_GetStockTypes.ItemType objOpportunityLineItemType = NULL;

        System.debug('retrieveItemsToCheck [strCountryText : ' + strCountryText + ' - objOpportunity : ' + objOpportunity + '] ->');

        if(objOpportunity != NULL && objOpportunity.OpportunityLineItems__r != NULL  && objOpportunity.OpportunityLineItems__r.size() > 0) {
            lstOfItems = new List<LAT_GetStockTypes.ItemType>();
            for(LAT_OpportunityLineItem__c objOpportunityLineItem : objOpportunity.OpportunityLineItems__r) {
                objOpportunityLineItemType = new Lat_GetStockTypes.ItemType();
                objOpportunityLineItemType.sku = objOpportunityLineItem.LAT_SkuText__c;
                objOpportunityLineItemType.businessUnit = strCountryText == 'Brasil' ? objOpportunityLineItem.LAT_Opportunity__r.LAT_Account__r.Business_Unit__r.CodDefUsuario__c : objOpportunityLineItem.LAT_Opportunity__r.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c; 
                objOpportunityLineItemType.unitOfMeasure = objOpportunityLineItem.LAT_AR_UOM__c != null ? objOpportunityLineItem.LAT_AR_UOM__c : 'CA';
                objOpportunityLineItemType.idType = 'itemProduct'; //hardcoded value

                lstOfItems.add(objOpportunityLineItemType);
            }
        }

        System.debug('retrieveItemsToCheck [' + lstOfItems + '] <-');

        return lstOfItems;
    }

    public static void handleException(String strMethod, String strMessage) {
        System.debug(String.format('method : {0} - strMessage : {1}',new String[] {strMethod , strMessage}));
    }

    public static void handleException(String strMethod, Exception Ex) {
        System.debug(String.format('method : {0} - strMessage : {1}',new String[] {strMethod , Ex.getMessage()}));
    }

    public static Id retrieveEmailTemplate(String strTemplateName) {
        List<EmailTemplate> lstEmailTemplate = null;
        Id objEmailTemplateId = null;
        
        lstEmailTemplate = [SELECT Id 
                            FROM EmailTemplate 
                            WHERE Name =: strTemplateName];
        
        if(!lstEmailTemplate.isEmpty()) {
            objEmailTemplateId = lstEmailTemplate[0].Id; 
        }
        
        return objEmailTemplateId;
    }

    public static void sendEmail(String strFromDisplay, String strTo, String strSubject, String strBody) {
        sendEmail(null, strFromDisplay, new String[] {strTo}, null, strSubject, strBody, null, null);
    }    

    public static void sendEmail(String strTemplateId, String strFromDisplay, List<String> lstTo, List<String> lstCC, String strSubject, String strBody, List<Attachment> lstAttachments, String strWhoId) {
        Messaging.SingleEmailMessage objSingleEmailMessage = null;
        List<Messaging.EmailFileAttachment> lstFileAttachments = null;
        Messaging.EmailFileAttachment objEmailFileAttachment = null;
        try {            
            if(lstTo != NULL && lstTO.size() > 0 && String.isNotBlank(strFromDisplay)) {
                objSingleEmailMessage = new Messaging.SingleEmailMessage();
                
                if(String.isNotBlank(strTemplateId)) {
                    objSingleEmailMessage.setTemplateId(strTemplateId);
                    objSingleEmailMessage.setTargetObjectId(UserInfo.getUserId());                    
                }
                
                objSingleEmailMessage.setToAddresses(lstTo);
                if(lstCC != NULL && !lstCC.IsEmpty()) {
                    objSingleEmailMessage.setCcAddresses(lstCC);
                }
                objSingleEmailMessage.setSenderDisplayName(strFromDisplay);
                if(String.isNotBlank(strSubject)) { 
                    objSingleEmailMessage.setSubject(strSubject);
                }
                if(String.isNotBlank(strWhoId)) {
                    objSingleEmailMessage.setTargetObjectId(strWhoId);
                }
                objSingleEmailMessage.setBccSender(false);
                objSingleEmailMessage.setUseSignature(true);
                objSingleEmailMessage.setSaveAsActivity(false);
                //objSingleEmailMessage.setPlainTextBody(strBody);
                if(String.isNotBlank(strBody)) {
                    objSingleEmailMessage.setHtmlBody(strBody);
                }
                
                if(lstAttachments != NULL && lstAttachments.size() > 0) {
                    lstFileAttachments = new  List<Messaging.EmailFileAttachment>();
                    for (Attachment objAttachment : lstAttachments){
                        objEmailFileAttachment = new Messaging.EmailFileAttachment();
                        objEmailFileAttachment.setFileName(objAttachment.Name);
                        objEmailFileAttachment.setBody(objAttachment.Body);
                        lstFileAttachments.add(objEmailFileAttachment);
                    }  
                    
                    objSingleEmailMessage.setFileAttachments(lstFileAttachments);
                }
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objSingleEmailMessage });                                
            }
        } catch(Exception Ex) {
            handleException('sendEmail', Ex);            
        }
    }
    
    public static void sendNotificationEmail(Id objSObjectId, String strEmailTemplate) { 
        OrgWideEmailAddress objOrgWideAddress = NULL;
        EmailTemplate objEmailTemplate = NULL;
        List<Messaging.SingleEmailMessage> lstEmailMessage = NULL;
        Messaging.SingleEmailMessage objEmailMessage = NULL;
        
        if(!Test.isRunningTest()) {
            objOrgWideAddress = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress LIMIT 1];
        }
        objEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:strEmailTemplate ];

        lstEmailMessage = new List<Messaging.SingleEmailMessage>();
        objEmailMessage = new Messaging.SingleEmailMessage();
        objEmailMessage.setTargetObjectId(objSObjectId);
        objEmailMessage.setTemplateID(objEmailTemplate.Id); 
        objEmailMessage.setSaveAsActivity(true);
        if(objOrgWideAddress != NULL) {
            objEmailMessage.setOrgWideEmailAddressId(objOrgWideAddress.id);
        }
        lstEmailMessage.add(objEmailMessage);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(lstEmailMessage,false);
        }
    }
    
}