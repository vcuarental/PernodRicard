/********************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_MX_VFP04_ProductSelection
* Descripcion: extencion de la pagina LAT_MX_VFP04_ProductSelection
* Fecha: 08/11/2013 
*********************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 11/11/2016
*
********************************************************************************/



public with sharing class LAT_MX_VFP04_ProductSelectionExtension{

    public List<productWrapper> listAvailableProductsWrapper {get; set;}
    public Map<String,String> mapCanReasonAlternText {get; set;}
    public List<OpportunityLineItem> itemOpp {get; private set;}
    public List<OpportunityLineItem> shoppingCart {get; set;}
    public Decimal originalAvailableCreditLimit {get; set;}
    public String measurementUnit {get; set;}
    public Boolean displayPopup {get; set;}
    public Boolean showColumns {get; set;}
    public Boolean prevDisable {get;set;}
    public Boolean nextDisable {get;set;}
    public Opportunity theOpp {get; set;}
    public String toUnselect {get; set;}
    public Boolean allowEdit {get; set;}
    public String searchProd {get;set;}
    public Id idOliPbe {get; set;}
    public String restringido {get; set;}
    public String libre {get; set;}
    public String font1 {get; set;}
    public String fyi {get; set;}
    
    private String rtProduct = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard');
    private Map<Id,OpportunityLineItem> mapShoppingCartOriginal;
    private Map<String,LAT_MX_QTA_Quota__c> mapIdProdQuota;
    private Map<Id, productWrapper> mapIdPBEProductWrapper;
    private Set<String> setProdNotAvailable;
    private String isoCodeMXN = 'MXN';
    private Integer pageSize = 200;
    private PagerGeneral pager;

    public Boolean showStockValues {get;set;}
    public Boolean checkedStockValues {get;set;}

    //VARIABLES MIGRACION LICENCIAS
    public List<LAT_OpportunityLineItem__c> LAT_itemOpp {get; private set;}
    public List<LAT_OpportunityLineItem__c> LAT_shoppingCart {get; set;}
    public LAT_Opportunity__c LAT_theOpp {get; set;}
    private String LAT_rtProduct = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard');
    private Map<Id,LAT_OpportunityLineItem__c> LAT_mapShoppingCartOriginal;
      
    public class productWrapper{
        public PricebookEntry priceBook {get; set;}
        public OpportunityLineItem oli {get; set;}
        public LAT_Product__c LAT_priceBook {get; set;}
        public LAT_OpportunityLineItem__c LAT_oli {get; set;}
        public integer quota {get; set;}
        public String inventarioPRM {get; set;}

        public productWrapper(PricebookEntry priceBookParam){
            oli = new OpportunityLineItem();
            priceBook = priceBookParam;
        }
        //MIGRATED 11/11/2016    
        public productWrapper(LAT_Product__c priceBookParam){
            LAT_oli = new LAT_OpportunityLineItem__c();
            LAT_priceBook = priceBookParam;
        }
    }
        
    public LAT_MX_VFP04_ProductSelectionExtension(ApexPages.StandardController controller){
        if(!Utils.wasMigrationDone('12')) {
            checkedStockValues = false;
            if (!Test.isRunningTest()){
                 controller.addFields(new List<String>{'AccountId'});
            }
            
            theOpp = (Opportunity)controller.getRecord();
            
            //Cargo los productos que no se van a poder seleccionar
            mapIdProdQuota = new Map<String,LAT_MX_QTA_Quota__c>();
            setProdNotAvailable = new Set<String>();
            for(LAT_MX_QTA_Quota__c quota: [SELECT Id, LAT_MX_QuotaBalance__c, LAT_MX_Product__c, LAT_MX_ValidityUntil__c FROM LAT_MX_QTA_Quota__c WHERE LAT_MX_Client__c =: theOpp.AccountId AND LAT_MX_ValidityUntil__c >=: date.Today() AND LAT_MX_ValiditySince__c <=: date.Today()]){
                mapIdProdQuota.put(quota.LAT_MX_Product__c, quota);
                if(quota.LAT_MX_QuotaBalance__c != null && quota.LAT_MX_QuotaBalance__c <= 0){
                    setProdNotAvailable.add(quota.LAT_MX_Product__c);
                }
            }
             
            init();
            
            originalAvailableCreditLimit = theOpp.Account.LAT_MX_AvailableCreditLimit__c;
            
            //Bloquea los botones si es necesario
            allowEdit = (!theOpp.RecordType.DeveloperName.contains('OrderBlocked') && theOpp.stageName != 'Pedido enviado para o JDE');
            //Oculta columnas con datos que van a estar completos una vez que vuelve de JDE
            showColumns = (!theOpp.RecordType.DeveloperName.contains('NewOrder'));
            //Todos los productos de MX tiene Unidad de medida 'CA'
            measurementUnit = 'CA';
            //Guardo en una variable los OLIs originales antes de entrar en la pagina
            mapShoppingCartOriginal = new Map<Id, OpportunityLineItem>(shoppingCart.clone());

            try{

                String[] stringBoolean = LAT_GeneralConfigDao.getValueAsStringArray('ALLOW_STOCK_VALUES', ' ');

                if(stringBoolean != null && stringBoolean.size()>0){
                        showStockValues = Boolean.valueOf(stringBoolean[0]);
                } else {
                        showStockValues = false;
                }
            }catch(Exception e){
                showStockValues = false;//               
            }
        }
        //MIGRATED 11/11/2016
        else {
            font1 = 'font1';
            fyi   = 'fyi';
            libre = 'Libre';
            restringido = 'Restringido';
            checkedStockValues = false;
            if (!Test.isRunningTest()){
                 controller.addFields(new List<String>{'LAT_Account__c'});
            }
            
            LAT_theOpp = (LAT_Opportunity__c)controller.getRecord();
            
            //Cargo los productos que no se van a poder seleccionar
            mapIdProdQuota = new Map<String,LAT_MX_QTA_Quota__c>();
            setProdNotAvailable = new Set<String>();
            for(LAT_MX_QTA_Quota__c quota: [SELECT Id, LAT_MX_QuotaBalance__c, LAT_Product__c, LAT_MX_ValidityUntil__c FROM LAT_MX_QTA_Quota__c WHERE LAT_MX_Client__c =: LAT_theOpp.LAT_Account__c AND LAT_MX_ValidityUntil__c >=: date.Today() AND LAT_MX_ValiditySince__c <=: date.Today()]){
                mapIdProdQuota.put(quota.LAT_Product__c, quota);
                if(quota.LAT_MX_QuotaBalance__c != null && quota.LAT_MX_QuotaBalance__c <= 0){
                    setProdNotAvailable.add(quota.LAT_Product__c);
                }
            }
             
            init();
            
            originalAvailableCreditLimit = LAT_theOpp.LAT_Account__r.LAT_MX_AvailableCreditLimit__c;
            
            //Bloquea los botones si es necesario
            allowEdit = (!LAT_theOpp.RecordType.DeveloperName.contains('OrderBlocked') && LAT_theOpp.LAT_StageName__c != 'Pedido enviado para o JDE');
            //Oculta columnas con datos que van a estar completos una vez que vuelve de JDE
            showColumns = (!LAT_theOpp.RecordType.DeveloperName.contains('NewOrder'));
            //Todos los productos de MX tiene Unidad de medida 'CA'
            measurementUnit = 'CA';
            //Guardo en una variable los OLIs originales antes de entrar en la pagina
            LAT_mapShoppingCartOriginal = new Map<Id, LAT_OpportunityLineItem__c>(LAT_shoppingCart.clone());

            try{

                String[] stringBoolean = LAT_GeneralConfigDao.getValueAsStringArray('ALLOW_STOCK_VALUES', ' ');

                if(stringBoolean != null && stringBoolean.size()>0){
                        showStockValues = Boolean.valueOf(stringBoolean[0]);
                } else {
                        showStockValues = false;
                }
            }catch(Exception e){
                showStockValues = false;
            }            
        }
    }
    
    private void init(){
        if(!Utils.wasMigrationDone('12')) {        
            theOpp = [SELECT Id, Pricebook2Id, Account.Business_Unit_AR__r.CodDefUsuario__c, Pricebook2.Name, CurrencyIsoCode, Grupo_de_precos__c, Campo_de_formatacao__c, RecordType.Name, 
                      AccountId, Account.Payment_Condition__r.Internal_Id__c, Account.Price_Group__c, /*CreditLimitBalance_AR__c,*/ Valor_total__c, StageName,
                      RecordType.DeveloperName, LAT_MX_OrderPaymentPeriodReference__r.Internal_Id__c, Account.LAT_MX_AvailableCreditLimit__c, Account.Client_country_AN8__c
                      FROM Opportunity WHERE Id =: theOpp.Id];
            
            shoppingCart = [SELECT Id, PriceBookEntry.Product2Id,Sku__c, LAT_SkuText__c, UOM_AR__c, Quantity, UnitPrice, TotalPrice, bottles_per_box__c, Descricao_do_status__c, 
                            Description, Backorder__c,LAT_UNitCode__c, PriceBookEntryId, cd_line_status__c, Campo_de_formatacao__c, Remover__c, PriceBookEntry.Product2.Name,PriceBookEntry.Product2.SKU__c, LAT_MX_SignedDatedReceipt__c,
                            LAT_MX_EstimatedDeliveryDate__c, LAT_C9Quantity__c, LAT_MX_LogisticsPromisedDate__c, LAT_MX_RealDeliveryDate__c, LAT_MX_CancellationReason__c
                            FROM OpportunityLineItem WHERE OpportunityId =: theOpp.Id ORDER BY NR_Order_Item__c, PricebookEntry.Product2.Name];
            
            loadInventario(shoppingCart);

            listAvailableProductsWrapper = new List<productWrapper>();
            mapIdPBEProductWrapper = new Map<Id, productWrapper>();
            reloadAvailableProducts();
            if(listAvailableProductsWrapper.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, label.LAT_MX_VFP04_00027));
                //LAT_MX_VFP04_00027: No existen productos para el plazo de pago del pedido.
            }
            cancellationReason();
        }
        //MIGRATED 11/11/2016
        else {
            LAT_theOpp = [SELECT Id, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, CurrencyIsoCode, LAT_AccountPriceBook__c, LAT_FormatField__c, RecordType.Name, 
                      LAT_Account__c, LAT_Account__r.Payment_Condition__r.Internal_Id__c, LAT_Account__r.Price_Group__c, /*CreditLimitBalance_AR__c,*/ LAT_TotalValue__c, LAT_StageName__c,
                      RecordType.DeveloperName, LAT_MX_OrderPaymentPeriodReference__r.Internal_Id__c, LAT_Account__r.LAT_MX_AvailableCreditLimit__c, LAT_Account__r.Client_country_AN8__c
                      FROM LAT_Opportunity__c WHERE Id =: LAT_theOpp.Id];
            
            LAT_shoppingCart = [SELECT Id, LAT_Product__c , LAT_Sku__c, LAT_SkuText__c, LAT_AR_UOM__c, LAT_Quantity__c, LAT_UnitPrice__c, LAT_TotalPrice__c, LAT_BottlesPerBoxFormula__c, LAT_StatusDescription__c, 
                            LAT_Description__c, LAT_Backorder__c, LAT_UnitCode__c, LAT_CdLineStatus__c, LAT_FormatField__c, LAT_Remover__c, LAT_Product__r.Name, LAT_Product__r.LAT_Sku__c, LAT_MX_SignedDatedReceipt__c,
                            LAT_MX_EstimatedDeliveryDate__c, LAT_C9Quantity__c, LAT_MX_LogisticsPromisedDate__c, LAT_MX_RealDeliveryDate__c, LAT_MX_CancellationReason__c, LAT_Product__r.LAT_RestrictionEnd__c
                            FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: LAT_theOpp.Id ORDER BY LAT_NROrder_Item__c, LAT_Product__r.Name];
            
            loadInventario(LAT_shoppingCart);

            listAvailableProductsWrapper = new List<productWrapper>();
            mapIdPBEProductWrapper = new Map<Id, productWrapper>();
            reloadAvailableProducts();
            if(listAvailableProductsWrapper.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, label.LAT_MX_VFP04_00027));
                //LAT_MX_VFP04_00027: No existen productos para el plazo de pago del pedido.
            }
            cancellationReason();            
        }
    }

    private void loadInventario(List<OpportunityLineItem> shCart){
        List<String> lstProd = new List<String>();
        List<String> prIds = new List<String>();
        for(OpportunityLineItem oli: shCart){
            lstProd.add('12-' + oli.Sku__c + '-' + theOpp.Account.Business_Unit_AR__r.CodDefUsuario__c);
            prIds.add(oli.PriceBookEntry.Product2Id);
        }
        Map<String, Product2> stocks = new Map<String, Product2>();
        for(Product2 st: [Select id, name, (Select id,Product__c,LAT_Stock__c,tolabel(LAT_StockLevel__c) from Lat_Stocks__r where LAT_ExternalId__c in: lstProd) from product2 where id in:prIds]){
            stocks.put(st.id, st);
        }
        for(OpportunityLineItem oli: shCart){
            if(stocks.get(oli.PriceBookEntry.Product2Id) != null){
                oli.PriceBookEntry.Product2 = stocks.get(oli.PriceBookEntry.Product2Id);
                system.debug('111111 ' + oli.PriceBookEntry.Product2.Lat_Stocks__r);
            }
        }

    }
    //MIGRATED 11/11/2016
    private void loadInventario(List<LAT_OpportunityLineItem__c> shCart){
        List<String> lstProd = new List<String>();
        List<String> prIds = new List<String>();
        for(LAT_OpportunityLineItem__c oli: shCart){
            lstProd.add('12-' + oli.LAT_Sku__c + '-' + LAT_theOpp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c);
            prIds.add(oli.LAT_Product__c);
        }
        Map<String, LAT_Product__c> stocks = new Map<String, LAT_Product__c>();
        for(LAT_Product__c st: [Select id, name, LAT_RestrictionEnd__c, (Select id,LAT_Product__c,LAT_Stock__c,tolabel(LAT_StockLevel__c) from Lat_StocksList__r where LAT_ExternalId__c in: lstProd) from LAT_Product__c where id in:prIds]){
            stocks.put(st.id, st);
        }
        for(LAT_OpportunityLineItem__c oli: shCart){
            if(stocks.get(oli.LAT_Product__c) != null){
                oli.LAT_Product__r = stocks.get(oli.LAT_Product__c);
                system.debug('LAT 111111 ' + oli.LAT_Product__r.Lat_StocksList__r);
            }
        }

    }
    
    //metodo que carga en un mapa las Cancellation Reason de los productos del shoppingCart y sus correspondientes alternative text que extrae de UDC
    private void cancellationReason(){
        if(!Utils.wasMigrationDone('12')) {
            Set<String> setCancellationReason = new Set<String>();
            mapCanReasonAlternText = new Map<String,String>();
            for(OpportunityLineItem oli: shoppingCart){
                if(oli.LAT_MX_CancellationReason__c != null){
                  setCancellationReason.add(oli.LAT_MX_CancellationReason__c);
                  mapCanReasonAlternText.put(oli.LAT_MX_CancellationReason__c, '');
                }
            }
            String UDCrtMX = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
            List<UDC__c> listUDC = [SELECT Id, Name, CodDefUsuario__c FROM UDC__c WHERE CodProd__c = '42' AND CodUs__c = 'RR' AND RecordTypeId =: UDCrtMX AND CodDefUsuario__c IN: setCancellationReason];              
            for(UDC__c udc: listUDC){
                mapCanReasonAlternText.put(udc.CodDefUsuario__c, udc.Name);
            }
        }
        //MIGRATED 11/11/2016
        else {
            Set<String> setCancellationReason = new Set<String>();
            mapCanReasonAlternText = new Map<String,String>();
            for(LAT_OpportunityLineItem__c oli: LAT_shoppingCart){
                if(oli.LAT_MX_CancellationReason__c != null){
                  setCancellationReason.add(oli.LAT_MX_CancellationReason__c);
                  mapCanReasonAlternText.put(oli.LAT_MX_CancellationReason__c, '');
                }
            }
            String UDCrtMX = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
            List<UDC__c> listUDC = [SELECT Id, Name, CodDefUsuario__c FROM UDC__c WHERE CodProd__c = '42' AND CodUs__c = 'RR' AND RecordTypeId =: UDCrtMX AND CodDefUsuario__c IN: setCancellationReason];              
            for(UDC__c udc: listUDC){
                mapCanReasonAlternText.put(udc.CodDefUsuario__c, udc.Name);
            }            
        }
    }
    
    //metodo que actualiza la lista de productos disponibles con todos los productos del RT de MX, salvo aquellos que estan en la shoppingCart
    private void reloadAvailableProducts(){
        if(!Utils.wasMigrationDone('12')) {        
            Set<Id> setPbeIdsOfSchoppingCart = new Set<Id>();
            for(OpportunityLineItem oli: shoppingCart){
               setPbeIdsOfSchoppingCart.add(oli.PriceBookEntry.Product2Id);
            }
            
            String query = '';
            query += 'SELECT Id, Product__c, Product__r.Name ';
            query += 'FROM LAT_Account_product_payment__c ';
            query += 'WHERE ';
            query += 'CustomerCountryAN8Code__c = \'' + theOpp.Account.Client_country_AN8__c + '\' AND ';      
            if(theOpp.LAT_MX_OrderPaymentPeriodReference__c != null || theOpp.Account.Payment_Condition__c != null){
                query += 'PaymentConditionExternalId__c = \'' + (theOpp.LAT_MX_OrderPaymentPeriodReference__c != null ? theOpp.LAT_MX_OrderPaymentPeriodReference__r.Internal_Id__c : theOpp.Account.Payment_Condition__r.Internal_Id__c) + '\' AND ';
            }
            query += 'Product__r.IsActive = true AND ';
            query += 'Product__c NOT IN: setPbeIdsOfSchoppingCart AND ';
            query += 'Product__c NOT IN: setProdNotAvailable ';  
            if(searchProd != null && searchProd != ''){
                query += 'AND (Product__r.Name LIKE \'%'+searchProd+'%\' OR Product__r.Description like \'%'+searchProd+'%\') ';
            }
            query += 'ORDER BY Product__r.Name';
            
            pager = new PagerGeneral(Database.getQueryLocator(query), pageSize);
            
            if(pager.getRecords().isEmpty()){        
                query = '';
                query += 'SELECT Id, Product__c, Product__r.Name ';
                query += 'FROM LAT_Account_product_payment__c ';
                query += 'WHERE ';
                query += 'CustomerCountryAN8Code__c = \'12-00000000\' AND ';    
                query += 'PaymentConditionExternalId__c = \'12-000\' AND ';
                query += 'Product__r.IsActive = true AND ';
                query += 'Product__c NOT IN: setPbeIdsOfSchoppingCart AND ';
                query += 'Product__c NOT IN: setProdNotAvailable ';  
                if(searchProd != null && searchProd != ''){
                    query += 'AND (Product__r.Name LIKE \'%'+searchProd+'%\' OR Product__r.Description like \'%'+searchProd+'%\') ';
                }
                query += 'ORDER BY Product__r.Name';
                pager = new PagerGeneral(Database.getQueryLocator(query), pageSize);
            }
                 
            loadPager();
        } 
        //MIGRATED 11/11/2016
        else {
            Set<Id> setPbeIdsOfSchoppingCart = new Set<Id>();
            for(LAT_OpportunityLineItem__c oli: LAT_shoppingCart){
               setPbeIdsOfSchoppingCart.add(oli.LAT_Product__c);
            }
            
            String query = '';
            query += 'SELECT Id, LAT_Product__c, LAT_Product__r.Name ';
            query += 'FROM LAT_Account_product_payment__c ';
            query += 'WHERE ';
            query += 'CustomerCountryAN8Code__c = \'' + LAT_theOpp.LAT_Account__r.Client_country_AN8__c + '\' AND ';      
            if(LAT_theOpp.LAT_MX_OrderPaymentPeriodReference__c != null || LAT_theOpp.LAT_Account__r.Payment_Condition__c != null){
                query += 'PaymentConditionExternalId__c = \'' + (LAT_theOpp.LAT_MX_OrderPaymentPeriodReference__c != null ? LAT_theOpp.LAT_MX_OrderPaymentPeriodReference__r.Internal_Id__c : LAT_theOpp.LAT_Account__r.Payment_Condition__r.Internal_Id__c) + '\' AND ';
            }
            query += 'LAT_Product__r.LAT_IsActive__c = true AND ';
            query += 'LAT_Product__c NOT IN: setPbeIdsOfSchoppingCart AND ';
            query += 'LAT_Product__c NOT IN: setProdNotAvailable ';  
            if(searchProd != null && searchProd != ''){
                query += 'AND (LAT_Product__r.Name LIKE \'%'+searchProd+'%\' OR LAT_Product__r.LAT_Description__c like \'%'+searchProd+'%\') ';
            }
            query += 'ORDER BY LAT_Product__r.Name';
            
            pager = new PagerGeneral(Database.getQueryLocator(query), pageSize);
            
            if(pager.getRecords().isEmpty()){        
                query = '';
                query += 'SELECT Id, LAT_Product__c, LAT_Product__r.Name ';
                query += 'FROM LAT_Account_product_payment__c ';
                query += 'WHERE ';
                query += 'CustomerCountryAN8Code__c = \'12-00000000\' AND ';    
                query += 'PaymentConditionExternalId__c = \'12-000\' AND ';
                query += 'LAT_Product__r.LAT_IsActive__c = true AND ';
                query += 'LAT_Product__c NOT IN: setPbeIdsOfSchoppingCart AND ';
                query += 'LAT_Product__c NOT IN: setProdNotAvailable ';  
                if(searchProd != null && searchProd != ''){
                    query += 'AND (LAT_Product__r.Name LIKE \'%'+searchProd+'%\' OR LAT_Product__r.LAT_Description__c like \'%'+searchProd+'%\') ';
                }
                query += 'ORDER BY LAT_Product__r.Name';
                pager = new PagerGeneral(Database.getQueryLocator(query), pageSize);
            }
                 
            loadPager();            
        }
    }
    
    private void loadPager(){
        if(pager!=null){
            if(!Utils.wasMigrationDone('12')) {
                loadMapPBEQuantity();
                listAvailableProductsWrapper = new List<productWrapper>();
                
                set<Id> setProdsInPager = new set<Id>();
                for(LAT_Account_product_payment__c app: (List<LAT_Account_product_payment__c>)pager.getRecords()){
                    setProdsInPager.add(app.Product__c);
                }
                
                List<String> lstProd = new List<String>();
                for(PricebookEntry pbe : [SELECT Id, Product2Id, Pricebook2Id, Product2.Name, Product2.SKU__c, Product2.LAT_MX_StockPRM__c, Product2.LAT_MX_ClientStock__c, Name, IsActive FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Pricebook2.IsActive = true AND IsActive = true AND Product2Id IN: setProdsInPager AND CurrencyIsoCode =: isoCodeMXN ORDER BY Product2.Name]){
                    lstProd.add('12-' + pbe.Product2.SKU__c + '-' + theOpp.Account.Business_Unit_AR__r.CodDefUsuario__c);
                    productWrapper pw = new productWrapper(pbe);
                    if(mapIdProdQuota.containsKey(pbe.Product2Id)){
                       pw.quota = Integer.valueOf(mapIdProdQuota.get(pbe.Product2Id).LAT_MX_QuotaBalance__c);
                    }
                    if(mapIdPBEProductWrapper.containsKey(pbe.Id)){
                        pw.oli.quantity = mapIdPBEProductWrapper.get(pbe.Id).oli.quantity;
                    }
                    listAvailableProductsWrapper.add(pw);
                }

                Map<String, LAT_Stock__c> stocks = new Map<String, LAT_Stock__c>();
                for(LAT_Stock__c st: [Select id,Product__c,LAT_Stock__c,tolabel(LAT_StockLevel__c) from LAT_Stock__c where LAT_ExternalId__c in: lstProd]){
                    stocks.put(st.Product__c, st);

                }
                for(productWrapper pw: listAvailableProductsWrapper){
                    if(stocks.get(pw.priceBook.Product2Id) != null){
                        pw.inventarioPRM = stocks.get(pw.priceBook.Product2Id).LAT_StockLevel__c + '(' + String.valueOf(stocks.get(pw.priceBook.Product2Id).LAT_Stock__c.format()) + ')';
                    }
                }
                prevDisable = false;
                if(!pager.hasPrevious){prevDisable = true;}
                nextDisable = false;
                if(!pager.hasNext){nextDisable = true;}
            }
            //MIGRATED 11/11/2016
            else {
                loadMapPBEQuantity();
                listAvailableProductsWrapper = new List<productWrapper>();
                
                set<Id> setProdsInPager = new set<Id>();
                for(LAT_Account_product_payment__c app: (List<LAT_Account_product_payment__c>)pager.getRecords()){
                    setProdsInPager.add(app.LAT_Product__c);
                }
                
                List<String> lstProd = new List<String>();
                for(LAT_Product__c pbe : [SELECT Id, Name, LAT_Sku__c, LAT_MX_StockPRM__c, LAT_MX_ClientStock__c, LAT_IsActive__c, LAT_RestrictionEnd__c FROM LAT_Product__c WHERE LAT_IsActive__c = true AND Id IN: setProdsInPager AND CurrencyIsoCode =: isoCodeMXN ORDER BY Name]){
                    lstProd.add('12-' + pbe.LAT_Sku__c + '-' + LAT_theOpp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c);
                    productWrapper pw = new productWrapper(pbe);
                    if(mapIdProdQuota.containsKey(pbe.Id)){
                       pw.quota = Integer.valueOf(mapIdProdQuota.get(pbe.Id).LAT_MX_QuotaBalance__c);
                    }
                    if(mapIdPBEProductWrapper.containsKey(pbe.Id)){
                        pw.LAT_oli.LAT_Quantity__c = mapIdPBEProductWrapper.get(pbe.Id).LAT_oli.LAT_Quantity__c;
                    }
                    listAvailableProductsWrapper.add(pw);
                }

                Map<String, LAT_Stock__c> stocks = new Map<String, LAT_Stock__c>();
                for(LAT_Stock__c st: [Select id, LAT_Product__c,LAT_Stock__c,tolabel(LAT_StockLevel__c) from LAT_Stock__c where LAT_ExternalId__c in: lstProd]){
                    stocks.put(st.LAT_Product__c, st);

                }
                for(productWrapper pw: listAvailableProductsWrapper){
                    if(stocks.get(pw.LAT_priceBook.Id) != null){
                        pw.inventarioPRM = stocks.get(pw.LAT_priceBook.Id).LAT_StockLevel__c + '(' + String.valueOf(stocks.get(pw.LAT_priceBook.Id).LAT_Stock__c.format()) + ')';
                    }
                }
                prevDisable = false;
                if(!pager.hasPrevious){prevDisable = true;}
                nextDisable = false;
                if(!pager.hasNext){nextDisable = true;}                
            }
        }
    }
    
    public void doPrevious() {
        pager.previous();
        loadPager();
    }
    
    public void doNext(){
        pager.next();
        loadPager();
    }
    
    private void loadMapPBEQuantity(){
        if(!Utils.wasMigrationDone('12')) {        
            for(productWrapper pw: listAvailableProductsWrapper){
                mapIdPBEProductWrapper.put(pw.priceBook.Id, pw);
            }
            for(String idPBE: mapIdPBEProductWrapper.keySet()){
                if(mapIdPBEProductWrapper.get(idPBE).oli.quantity == null){
                    mapIdPBEProductWrapper.remove(idPBE);
                }
            }
        }
        // MIGRATED 11/11/2016
        else {
            for(productWrapper pw: listAvailableProductsWrapper){
                mapIdPBEProductWrapper.put(pw.LAT_priceBook.Id, pw);
            }
            for(String idPBE: mapIdPBEProductWrapper.keySet()){
                if(mapIdPBEProductWrapper.get(idPBE).LAT_oli.LAT_Quantity__c == null){
                    mapIdPBEProductWrapper.remove(idPBE);
                }
            }            
        }    

    }
    
    public PageReference doSearchProducts(){
        reloadAvailableProducts();
        return null;
    }
    
    //metodo que se ejecuta con el boton 'Agregar'. Agrega al shoppingCart los productos de la tabla inferior a los que se le coloco cantidad
    //creando los nuevos productos de oportunidad, actualiza la lista de productos disponibles removiendo los productos que se agregaron
    //y calcula los precios
    public Pagereference doAddItemsToShoppingCart(){
        if(!Utils.wasMigrationDone('12')) {     
            checkedStockValues = false;   
            loadMapPBEQuantity();
            
            //Se verifican errores en las cantidades ingresadas
            for(productWrapper pw : mapIdPBEProductWrapper.values()){
                if(pw.oli.Quantity <= 0){
                    addMsgError(label.LAT_MX_VFP04_00015);
                    //LAT_MX_VFP04_00015: La cantidad ingresada para los productos debe ser mayor a 0.
                    return null;
                }
                if(pw.oli.Quantity > 0 && mapIdProdQuota.containsKey(pw.priceBook.Product2Id) && mapIdProdQuota.get(pw.priceBook.Product2Id).LAT_MX_QuotaBalance__c < pw.oli.Quantity){
                   addMsgError(label.LAT_MX_VFP04_00016);
                   //LAT_MX_VFP04_00016: Existen productos con cuota excedida, por favor revise el pedido.
                   return null;
                }
            }
           
           //guardo una copia del shoppingCart por si falla PriceCalculationInterface
           List<OpportunityLineItem> BackUpShoppingCart = shoppingCart.clone();
            
            //Se agrega al shoppingCart
            for(productWrapper pw : mapIdPBEProductWrapper.values()){
                OpportunityLineItem newOli = new opportunityLineItem(
                    NR_order_line__c = pw.oli.NR_order_line__c,
                    PriceBookEntry = pw.priceBook,
                    PriceBookEntryId = pw.priceBook.Id,
                    Quantity = pw.oli.Quantity,
                    Remover__c = false,
                    UOM_AR__c = measurementUnit,
                    LAT_SkuText__c = pw.priceBook.Product2.SKU__c,
                    OpportunityId = theOpp.Id               
                );
                shoppingCart.add(newOli);
            }
            
            shoppingCart.sort();
            
            //Llamado a la interface de precios
            String errorPriceCalculation = LAT_MX_WS02_PriceCalculateInterface.execute(theOpp.Id, shoppingCart);
            if(errorPriceCalculation != ''){
                addMsgError(label.LAT_MX_VFP04_00020 + ' ' + errorPriceCalculation);
                //LAT_MX_VFP04_00020: Error al intentar obtener precios:
                shoppingCart = BackUpShoppingCart;
                return null;
            }
            
            mapIdPBEProductWrapper.clear();
            reloadAvailableProducts();
            calculateFormulas();
            
            return null;
        }
        //MIGRATED 11/11/2016
        else {
            checkedStockValues = false;
            loadMapPBEQuantity();
            
            //Se verifican errores en las cantidades ingresadas
            for(productWrapper pw : mapIdPBEProductWrapper.values()){
                if(pw.LAT_oli.LAT_Quantity__c <= 0){
                    addMsgError(label.LAT_MX_VFP04_00015);
                    //LAT_MX_VFP04_00015: La cantidad ingresada para los productos debe ser mayor a 0.
                    return null;
                }
                if(pw.LAT_oli.LAT_Quantity__c > 0 && mapIdProdQuota.containsKey(pw.LAT_priceBook.Id) && mapIdProdQuota.get(pw.LAT_priceBook.Id).LAT_MX_QuotaBalance__c < pw.LAT_oli.LAT_Quantity__c){
                   addMsgError(label.LAT_MX_VFP04_00016);
                   //LAT_MX_VFP04_00016: Existen productos con cuota excedida, por favor revise el pedido.
                   return null;
                }
            }
           
           //guardo una copia del shoppingCart por si falla PriceCalculationInterface
           List<LAT_OpportunityLineItem__c> BackUpShoppingCart = LAT_shoppingCart.clone();
            
            //Se agrega al shoppingCart
            for(productWrapper pw : mapIdPBEProductWrapper.values()){
                LAT_OpportunityLineItem__c newOli = new LAT_OpportunityLineItem__c(
                    LAT_NROrderLine__c = pw.LAT_oli.LAT_NROrderLine__c,
                    LAT_Product__r = pw.LAT_priceBook,
                    LAT_Product__c = pw.LAT_priceBook.Id, 
                    LAT_Quantity__c = pw.LAT_oli.LAT_Quantity__c,
                    LAT_Remover__c = false,
                    LAT_AR_UOM__c = measurementUnit,
                    LAT_SkuText__c = pw.LAT_priceBook.LAT_Sku__c,
                    LAT_Opportunity__c = LAT_theOpp.Id               
                );
                LAT_shoppingCart.add(newOli);
            }
            
            LAT_shoppingCart.sort();
            
            //Llamado a la interface de precios
            String errorPriceCalculation = LAT_MX_WS02_PriceCalculateInterface.execute(LAT_theOpp.Id, LAT_shoppingCart);
            if(errorPriceCalculation != ''){
                addMsgError(label.LAT_MX_VFP04_00020 + ' ' + errorPriceCalculation);
                //LAT_MX_VFP04_00020: Error al intentar obtener precios:
                LAT_shoppingCart = BackUpShoppingCart;
                return null;
            }
            
            mapIdPBEProductWrapper.clear();
            reloadAvailableProducts();
            calculateFormulas();
            
            return null;            
        }
    }
    
    //metodo que se ejectuta con el boton 'Remover' que saca del shoppingCart el producto de oportunidad, llama a los metodos que actualiza 
    //la lista de productos disponibles y al que actualiza las formulas
    public PageReference doRemoveFromShoppingCart(){
        if(!Utils.wasMigrationDone('12')) {        
            Integer count = 0;
            for(OpportunityLineItem d : shoppingCart){
                if((String)d.PriceBookEntryId == toUnselect){
                    shoppingCart.remove(count);
                    break;
                }
                count++;
            }
            reloadAvailableProducts();
            calculateFormulas();
            return null;
        }
        //MIGRATED 11/11/2016
        else {
            Integer count = 0;
            for(LAT_OpportunityLineItem__c d : LAT_shoppingCart){
                if((String)d.LAT_Product__c == toUnselect){
                    LAT_shoppingCart.remove(count);
                    break;
                }
                count++;
            }
            reloadAvailableProducts();
            calculateFormulas();
            return null;            
        }
    }
    
    public void doShowPopup(){
        if(!Utils.wasMigrationDone('12')) { 
            itemOpp = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : shoppingCart){
                if(idOliPbe == oli.PriceBookEntryId){
                    itemOpp.add(oli);
                    break;
                }
            }
            displayPopup = true;
        }
        //MIGRATED 11/11/2016
        else {
            LAT_itemOpp = new List<LAT_OpportunityLineItem__c>();
            for(LAT_OpportunityLineItem__c oli : LAT_shoppingCart){
                if(idOliPbe == oli.LAT_Product__c){
                    LAT_itemOpp.add(oli);
                    break;
                }
            }
            displayPopup = true;            
        }
    }
    
    public void doClosePopup(){
        displayPopup = false;
    }
    
    public PageReference doSave(){
        if(!Utils.wasMigrationDone('12')) {
            String addMsgErrorCuotas = '';
            if(!shoppingCart.isEmpty()){
                for(OpportunityLineItem oli: shoppingCart){
                    if(mapIdProdQuota.containsKey(oli.PriceBookEntry.Product2Id) && oli.Quantity > mapIdProdQuota.get(oli.PriceBookEntry.Product2Id).LAT_MX_QuotaBalance__c && oli.Remover__c != true && oli.cd_line_status__c == null){
                        addMsgErrorCuotas += '\n' + label.LAT_MX_VFP04_00018 + ' ' + oli.PriceBookEntry.Product2.Name + ' - ' + label.LAT_MX_VFP04_00019 + ' ' + mapIdProdQuota.get(oli.PriceBookEntry.Product2Id).LAT_MX_QuotaBalance__c; 
                        //LAT_MX_VFP04_00018: Producto:
                        //LAT_MX_VFP04_00019: Valor Cuota:
                    }
                }
            }
            if(addMsgErrorCuotas != ''){
                addMsgError(label.LAT_MX_VFP04_00017 + ' ' + addMsgErrorCuotas);
                //LAT_MX_VFP04_00017: Los siguientes productos superan la cuota disponible:
                return null;
            }
            try{
                delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: theOpp.Id];            
                if(!shoppingCart.isEmpty()){
                    for(OpportunityLineItem oli: shoppingCart){
                        oli.totalPrice = null;
                        oli.Id = null;
                        oli.OpportunityId = theOpp.Id;
                    }            
                    insert shoppingCart;
                }
            }catch(DMLException e){
                ApexPages.addMessages(e);
                return null;
            }   
            return new PageReference('/' + theOpp.Id);
        }
        //MIGRATED 11/11/2016
        else {
            String addMsgErrorCuotas = '';
            if(!LAT_shoppingCart.isEmpty()){
                for(LAT_OpportunityLineItem__c oli: LAT_shoppingCart){
                    if(mapIdProdQuota.containsKey(oli.LAT_Product__c) && oli.LAT_Quantity__c > mapIdProdQuota.get(oli.LAT_Product__c).LAT_MX_QuotaBalance__c && oli.LAT_Remover__c != true && oli.LAT_CdLineStatus__c == null){
                        addMsgErrorCuotas += '\n' + label.LAT_MX_VFP04_00018 + ' ' + oli.LAT_Product__r.Name + ' - ' + label.LAT_MX_VFP04_00019 + ' ' + mapIdProdQuota.get(oli.LAT_Product__c).LAT_MX_QuotaBalance__c; 
                        //LAT_MX_VFP04_00018: Producto:
                        //LAT_MX_VFP04_00019: Valor Cuota:
                    }
                }
            }
            if(addMsgErrorCuotas != ''){
                addMsgError(label.LAT_MX_VFP04_00017 + ' ' + addMsgErrorCuotas);
                //LAT_MX_VFP04_00017: Los siguientes productos superan la cuota disponible:
                return null;
            }
            try{
                delete [SELECT Id FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: LAT_theOpp.Id];            
                if(!LAT_shoppingCart.isEmpty()){
                    for(LAT_OpportunityLineItem__c oli: LAT_shoppingCart){
                        //oli.LAT_Quantity__c = null;
                        oli.Id = null;
                        oli.LAT_Opportunity__c = LAT_theOpp.Id;
                    }            
                    insert LAT_shoppingCart;
                }
            }catch(DMLException e){
                ApexPages.addMessages(e);
                return null;
            }   
            return new PageReference('/' + LAT_theOpp.Id);            
        }    

    }
    
    public PageReference doCancel(){
        if(!Utils.wasMigrationDone('12')) {
            return new PageReference('/' + theOpp.Id);
        }
        //MIGRATED 26/12/2016
        else {
            return new PageReference('/' + LAT_theOpp.Id);
        }
    }
    
    private void calculateFormulas(){
        if(!Utils.wasMigrationDone('12')) {
            if(shoppingCart.isEmpty()){
                return;
            }
            
            Savepoint sp = Database.setSavepoint();
            try{
                delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: theOpp.Id];
                for(OpportunityLineItem oli: shoppingCart){
                    oli.totalPrice = null;
                    oli.Id = null;
                    oli.OpportunityId = theOpp.Id;
                }
                insert shoppingCart;
                init();
            }catch(DMLException e){
                system.debug('ERROR: ' + e);
            }
            Database.rollback(sp);
        }
        //MIGRATED 11/11/2016
        else {
            if(LAT_shoppingCart.isEmpty()){
                return;
            }
            
            Savepoint sp = Database.setSavepoint();
            try{
                delete [SELECT Id FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: LAT_theOpp.Id];
                for(LAT_OpportunityLineItem__c oli: LAT_shoppingCart){
                    //oli.LAT_Quantity__c = null;
                    oli.Id = null;
                    oli.LAT_Opportunity__c = LAT_theOpp.Id;

                }
                insert LAT_shoppingCart;
                init();
            }catch(DMLException e){
                system.debug('ERROR: ' + e);
            }
            Database.rollback(sp);
        }
    }
    
    private void addMsgError(String aMsg){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, aMsg));
    }

    public String stockLevelLabel(){
        return null;
    }

    public PageReference doCheckAvailability (){
        if(!Utils.wasMigrationDone('12')) {
            checkedStockValues = true;

            String response = LAT_StockAvailabilityInterface.stockAvailibity(shoppingCart,theOpp.Id);

            if(response != ''){
                  addMsgError(response);
            }else{
                 mapIdPBEProductWrapper.clear();
                reloadAvailableProducts();
                calculateFormulas();
            }
            
            return null;
        }
        //MIGRATED 11/11/2016
        else {
            checkedStockValues = true;

            String response = LAT_StockAvailabilityInterface.stockAvailibity(LAT_shoppingCart,LAT_theOpp.Id);

            if(response != ''){
                  addMsgError(response);
            }else{
                 mapIdPBEProductWrapper.clear();
                reloadAvailableProducts();
                calculateFormulas();
            }
            
            return null;            
        }
    }
}