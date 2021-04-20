/********************************************************************
* Company: Valuenet 
* Desarrollador: Denis Aranda, Waldemar Mayo
* Nombre del pagina: LAT_BR_VFP05_PriceSimulate
* Descripcion: extencion de la pagina LAT_BR_VFP05_PriceSimulate.page
* Fecha: 16/12/2013 
*********************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_VFC05_PriceSimulateCtrl {
    
    //Variables publicas
    public List<productWrapper> listAvailableProductsWrapper {get;set;}
    public List<Selectoption> paymentConditionPickList {get;set;}
    public List<OpportunityLineItem> itemPopUp {get;private set;}
    public List<productShoppingCart> shoppingCart {get;set;}
    public String paymentCondition {get;set;}
    public Boolean displayResumo {get;set;}
    public Boolean displayPopup {get;set;}
    public Boolean prevDisable {get;set;}
    public Boolean nextDisable {get;set;}
    public Opportunity theOpp {get;set;}
    public String searchProd {get;set;}
    public Blob resumoTotal {get;set;}
    public String sOlis {get;set;}
    public String accId {get;set;}
    //Variables privadas
    private String rtProduct = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
    private map<Id, LAT_Account_product_payment__c> mapProdsInPager;
    private map<Id, PricebookEntry> mapProdIdPBE;
    private map<String, String> mapPaymentCondition;
    private Integer pageSize = 200;
    private PagerGeneral pager;

    //Variables Migracion Licencias
    public List<LAT_OpportunityLineItem__c> LAT_itemPopUp {get;private set;}
    public LAT_Opportunity__c LAT_theOpp {get;set;}
    private String LAT_rtProduct = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
    private map<Id, LAT_Product__c> LAT_mapProdIdPBE;
    
    //Clase para manejar los produtos seleccionados
    //MIGRATED 03/11/2016 
    public class productShoppingCart{
        public Boolean notApply {get;set;}
        public OpportunityLineItem oli {get;set;}
        //Variables Migracion Licencias
        public LAT_OpportunityLineItem__c LAT_oli {get;set;}
        
        public productShoppingCart(OpportunityLineItem oliParam){
            oli = oliParam;
            notApply = false;
        }
        
        //MIGRATED 03/11/2016 
        public productShoppingCart(LAT_OpportunityLineItem__c oliParam){
            LAT_oli = oliParam;
            notApply = false;
        }
    }
    
    //Clase para traer los produtos seleccionables
    public class productWrapper{
        public Boolean isSelected {get;set;}
        public LAT_Account_product_payment__c app {get;set;}
        public productWrapper(LAT_Account_product_payment__c appParam){
            app = appParam;
            isSelected = false;
        }
    }
    
    //Constructor
    public LAT_BR_VFC05_PriceSimulateCtrl(){
        accId = ApexPages.currentPage().getparameters().get('idAcc');
        Account acc = [SELECT id, Name, Client_code_AN8__c, Payment_Condition__r.Name, Business_Unit__c FROM Account WHERE id =: accId];
        
        if(!Utils.wasMigrationDone('1')){
            theOpp = new Opportunity();
            theOpp.Account = acc;
            theOpp.AccountId = acc.Id;
            theOpp.Name = acc.Name;
            theOpp.CloseDate = date.today();
            theOpp.CurrencyIsoCode = 'BRL';
            theOpp.Origem_do_pedido__c = 'CRM';
            theOpp.StageName = 'Novo Pedido';
            theOpp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'Nova_oportunidade');
            
            //Carga de picklist de Condicion de pagamento
            List<AggregateResult> groupedResults = [SELECT PaymentConditionDescription__c, PaymentCondition__c
                                                    FROM LAT_Account_product_payment__c
                                                    WHERE Account__c =: accId
                                                    GROUP BY PaymentCondition__c, PaymentConditionDescription__c
                                                    ORDER BY PaymentConditionDescription__c];
            paymentConditionPickList = new List<Selectoption>();
            mapPaymentCondition = new map<String, String>();
            system.debug('groupedResults'+groupedResults);
            for(AggregateResult ar : groupedResults){
                system.debug('PaymentConditionDescription__c'+ ar.get('PaymentConditionDescription__c'));
                system.debug('PaymentCondition__c'+ar.get('PaymentCondition__c'));
                if(ar.get('PaymentConditionDescription__c') != null && ar.get('PaymentCondition__c') != null){
                    String payCondDes = String.valueOf(ar.get('PaymentConditionDescription__c'));
                    String payCond = String.valueOf(ar.get('PaymentCondition__c'));
                    paymentConditionPickList.add(new SelectOption(payCondDes, payCondDes));
                    mapPaymentCondition.put(payCondDes, payCond);
                }
            }
            paymentCondition = acc.Payment_Condition__r.Name;
            
            mapProdsInPager = new map<Id, LAT_Account_product_payment__c>();
            listAvailableProductsWrapper = new List<productWrapper>();
            shoppingCart = new List<productShoppingCart>();
            mapProdIdPBE = new map<Id, PricebookEntry>();
            reloadAvailableProducts();
            displayResumo = false;
            sOlis = '';
        } 
        //MIGRATED 03/11/2016 
        else {
            LAT_theOpp = new LAT_Opportunity__c();
            LAT_theOpp.LAT_Account__r = acc;
            LAT_theOpp.LAT_Account__c = acc.Id;
            LAT_theOpp.Name = acc.Name;
            LAT_theOpp.LAT_CloseDate__c = date.today();
            LAT_theOpp.CurrencyIsoCode = 'BRL';
            LAT_theOpp.LAT_OrderOrigin__c = 'CRM';
            LAT_theOpp.LAT_StageName__c = 'Novo Pedido';
            LAT_theOpp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'Nova_oportunidade');
            
            //Carga de picklist de Condicion de pagamento
            List<AggregateResult> groupedResults = [SELECT PaymentConditionDescription__c, PaymentCondition__c
                                                    FROM LAT_Account_product_payment__c
                                                    WHERE Account__c =: accId
                                                    GROUP BY PaymentCondition__c, PaymentConditionDescription__c
                                                    ORDER BY PaymentConditionDescription__c];
            paymentConditionPickList = new List<Selectoption>();
            mapPaymentCondition = new map<String, String>();
            system.debug('groupedResults'+groupedResults);
            for(AggregateResult ar : groupedResults){
                system.debug('PaymentConditionDescription__c'+ ar.get('PaymentConditionDescription__c'));
                system.debug('PaymentCondition__c'+ar.get('PaymentCondition__c'));
                if(ar.get('PaymentConditionDescription__c') != null && ar.get('PaymentCondition__c') != null){
                    String payCondDes = String.valueOf(ar.get('PaymentConditionDescription__c'));
                    String payCond = String.valueOf(ar.get('PaymentCondition__c'));
                    paymentConditionPickList.add(new SelectOption(payCondDes, payCondDes));
                    mapPaymentCondition.put(payCondDes, payCond);
                }
            }
            paymentCondition = acc.Payment_Condition__r.Name;
            
            mapProdsInPager = new map<Id, LAT_Account_product_payment__c>();
            listAvailableProductsWrapper = new List<productWrapper>();
            shoppingCart = new List<productShoppingCart>();
            LAT_mapProdIdPBE = new map<Id, LAT_Product__c>();
            reloadAvailableProducts();
            displayResumo = false;
            sOlis = '';
        }
    }
    
    //metodo que actualiza la lista de productos disponibles con todos los productos del RT de MX, salvo aquellos que estan en la shoppingCart
    private void reloadAvailableProducts(){
        if (!Utils.wasMigrationDone('1')){
            Set<Id> setProductIdsOnShoppingCart = new Set<Id>();
            for(productShoppingCart psc: shoppingCart){
               setProductIdsOnShoppingCart.add(psc.oli.PricebookEntry.Product2Id);
            }
            
            String query = '';
            query += 'SELECT Id, Account__c, Product__c, Product__r.Name, Product__r.Sku__c, Product__r.CD_Unit__c, Product__r.bottles_per_box__c, Product__r.unit_weight__c, Payment__c, CustomerCountryAN8Code__c, ExternalUniqueKey__c, MultipleQuantity__c, PaymentCondition__c, PaymentConditionDescription__c, PaymentConditionExternalId__c, PercentualBonus__c, ProductExternalId__c, TimeStamp__c, WarehouseCode__c ';
            query += 'FROM LAT_Account_product_payment__c ';
            query += 'WHERE ';
            query += 'Account__c = \''+theOpp.AccountId+'\' AND ';
            query += 'Product__r.RecordTypeId =\''+rtProduct+'\' AND ';
            query += 'Product__r.IsActive = true AND ';
            query += 'Payment__r.Name =\''+paymentCondition+'\' AND ';
            query += '(Product__r.LAT_IsRefactorProduct__c = \'Y\' OR Product__r.LAT_IsRefactorProduct__c = \'y\') AND ';
            query += 'Product__c NOT IN: setProductIdsOnShoppingCart ';
            
            if(searchProd != null && searchProd != ''){
                query += 'AND (Product__r.Name LIKE \'%'+searchProd+'%\' OR Product__r.Description like \'%'+searchProd+'%\') ';
            }
            query += 'ORDER BY Product__r.Name';
            System.debug('%%%%%%%%%%%%%%%%%%%% setProductIdsOnShoppingCart : '+setProductIdsOnShoppingCart);
            System.debug('%%%%%%%%%%%%%%%%%%%% paymentCondition : '+paymentCondition);
            pager = new PagerGeneral(Database.getQueryLocator(query), pageSize);
            listAvailableProductsWrapper = new List<productWrapper>();
            mapProdsInPager.clear();
            loadPager();
        }
        //MIGRATED 03/11/2016 
        else {
            Set<Id> setProductIdsOnShoppingCart = new Set<Id>();
            for(productShoppingCart psc: shoppingCart){
               setProductIdsOnShoppingCart.add(psc.LAT_oli.LAT_Product__c);               
            }
            
            String query = '';
            query += 'SELECT Id, Account__c, LAT_Product__c, LAT_Product__r.Name, LAT_Product__r.LAT_Sku__c, LAT_Product__r.LAT_CDUnit__c, LAT_Product__r.LAT_BottlesPerBox__c, LAT_Product__r.LAT_UnitWeight__c, Payment__c, CustomerCountryAN8Code__c, ExternalUniqueKey__c, MultipleQuantity__c, PaymentCondition__c, PaymentConditionDescription__c, PaymentConditionExternalId__c, PercentualBonus__c, ProductExternalId__c, TimeStamp__c, WarehouseCode__c ';
            query += 'FROM LAT_Account_product_payment__c ';
            query += 'WHERE ';
            query += 'Account__c = \''+LAT_theOpp.LAT_Account__c+'\' AND ';
            query += 'LAT_Product__r.RecordTypeId =\''+LAT_rtProduct+'\' AND ';
            query += 'LAT_Product__r.LAT_IsActive__c = true AND ';
            query += 'Payment__r.Name =\''+paymentCondition+'\' AND ';
            query += '(LAT_Product__r.LAT_IsRefactorProduct__c = \'Y\' OR LAT_Product__r.LAT_IsRefactorProduct__c = \'y\') AND ';
            query += 'LAT_Product__c NOT IN: setProductIdsOnShoppingCart ';
            System.debug('%%%%%%%%%%%%%%%%%%%% LATsetProductIdsOnShoppingCart : '+setProductIdsOnShoppingCart);
            System.debug('%%%%%%%%%%%%%%%%%%%% LATpaymentCondition : '+paymentCondition);
            if(searchProd != null && searchProd != ''){
                query += 'AND (LAT_Product__r.Name LIKE \'%'+searchProd+'%\' OR LAT_Product__r.LAT_Description__c like \'%'+searchProd+'%\') ';
            }
            query += 'ORDER BY LAT_Product__r.Name';
            
            system.debug('##################### query '+query);
            pager = new PagerGeneral(Database.getQueryLocator(query), pageSize);
            listAvailableProductsWrapper = new List<productWrapper>();
            mapProdsInPager.clear();
            loadPager();
        }
    }
    
    public void loadPagerTest(List<LAT_Account_product_payment__c> listaApp){
        if(Test.isRunningTest()){
            set<Id> setProdsInPager = new set<Id>();
            if (!Utils.wasMigrationDone('1')){            
                for(LAT_Account_product_payment__c app: listaApp){
                    setProdsInPager.add(app.Product__c);
                }
                for(PricebookEntry pbe: [SELECT Id, Product2Id, Pricebook2Id, Product2.Name, Product2.QT_multiple__c, Product2.CD_Unit__c, Product2.SKU__c, Product2.LAT_MX_StockPRM__c, Product2.LAT_MX_ClientStock__c, Name, IsActive FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Pricebook2.IsActive = true AND IsActive = true AND Product2Id IN: setProdsInPager AND CurrencyIsoCode =: 'BRL' ORDER BY Product2.Name]){
                    mapProdIdPBE.put(pbe.Product2Id, pbe);
                }
                for(LAT_Account_product_payment__c app: listaApp){
                    if(mapProdIdPBE.containsKey(app.Product__c)){productWrapper pw = new productWrapper(app);
                        if(mapProdsInPager.containsKey(app.Product__c)){ pw.isSelected = true;}
                        listAvailableProductsWrapper.add(pw);
                    }
                }
            }

            else {
                for(LAT_Account_product_payment__c app: listaApp){
                    setProdsInPager.add(app.LAT_Product__c);
                }
                

                for(LAT_Account_product_payment__c app: listaApp){
                        LAT_mapProdIdPBE.put(app.LAT_Product__r.Id,app.LAT_Product__r);
                        productWrapper pw = new productWrapper(app);
                        pw.isSelected = true;
                        productWrapper pw2 = new productWrapper(app);
                        pw2.isSelected = false;
                        listAvailableProductsWrapper.add(pw);
                        listAvailableProductsWrapper.add(pw2);
                }            
            }
        }

    }

    private void loadPager(){
        if(pager != null){

            if(!Utils.wasMigrationDone('1')) {
                loadMapProductsInPager();
                listAvailableProductsWrapper = new List<productWrapper>();
                
                set<Id> setProdsInPager = new set<Id>();
                for(LAT_Account_product_payment__c app: (List<LAT_Account_product_payment__c>)pager.getRecords()){
                    setProdsInPager.add(app.Product__c);
                }
                
                for(PricebookEntry pbe: [SELECT Id, Product2Id, Pricebook2Id, Product2.Name, Product2.QT_multiple__c, Product2.CD_Unit__c, Product2.SKU__c, Product2.LAT_MX_StockPRM__c, Product2.LAT_MX_ClientStock__c, Name, IsActive FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Pricebook2.IsActive = true AND IsActive = true AND Product2Id IN: setProdsInPager AND CurrencyIsoCode =: 'BRL' ORDER BY Product2.Name]){
                    mapProdIdPBE.put(pbe.Product2Id, pbe);
                }
                
                for(LAT_Account_product_payment__c app: (List<LAT_Account_product_payment__c>)pager.getRecords()){
                    if(mapProdIdPBE.containsKey(app.Product__c)){productWrapper pw = new productWrapper(app);
                        if(mapProdsInPager.containsKey(app.Product__c)){ pw.isSelected = true;}
                        listAvailableProductsWrapper.add(pw);
                    }
                }
                
                prevDisable = false;
                if(!pager.hasPrevious){prevDisable = true;}
                nextDisable = false;
                if(!pager.hasNext){nextDisable = true;}
            } 
            //MIGRATED 03/11/2016             
            else {
                loadMapProductsInPager();
                listAvailableProductsWrapper = new List<productWrapper>();
                
                set<Id> setProdsInPager = new set<Id>();
                for(LAT_Account_product_payment__c app: (List<LAT_Account_product_payment__c>)pager.getRecords()){
                    setProdsInPager.add(app.LAT_Product__c);
                }
                system.debug('##################### setProdsInPager '+setProdsInPager);
                for(LAT_Product__c pbe: [SELECT Id, Name, LAT_QTMultiple__c, LAT_CDUnit__c, LAT_Sku__c, LAT_MX_StockPRM__c, LAT_MX_ClientStock__c, LAT_IsActive__c 
                    FROM LAT_Product__c WHERE  LAT_IsActive__c = true AND Id IN: setProdsInPager  ORDER BY Name]){
                    LAT_mapProdIdPBE.put(pbe.Id, pbe);//AND CurrencyIsoCode =: 'BRL' 
                }
                
                for(LAT_Account_product_payment__c app: (List<LAT_Account_product_payment__c>)pager.getRecords()){
                    if(LAT_mapProdIdPBE.containsKey(app.LAT_Product__c)){
                        productWrapper pw = new productWrapper(app);
                        if(mapProdsInPager.containsKey(app.LAT_Product__c)){ pw.isSelected = true;}
                        listAvailableProductsWrapper.add(pw);
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
    
    public void doAllResumed () {
        if(!Utils.wasMigrationDone('1')) {
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();    
            for(productShoppingCart sc : shoppingCart){            
                if(!sc.notApply){
                    olis.add(sc.oli);
                }            
            }
            sOlis = JSON.serialize(olis);
        } 
        //MIGRATED 03/11/2016 
        else {
            List<LAT_OpportunityLineItem__c> LAT_olis = new List<LAT_OpportunityLineItem__c>();    
            for(productShoppingCart sc : shoppingCart){            
                if(!sc.notApply){
                    LAT_olis.add(sc.LAT_oli);
                }            
            }

            sOlis = JSON.serialize(LAT_olis);            
        }                          
    }
    
    private void loadMapProductsInPager(){
        if(!Utils.wasMigrationDone('1')) {
            for(productWrapper pw: listAvailableProductsWrapper){
                if(pw.isSelected){
                    mapProdsInPager.put(pw.app.Product__c, pw.app);
                }else if(mapProdsInPager.containsKey(pw.app.Product__c) && pw.app.PaymentConditionDescription__c == paymentCondition){
                    mapProdsInPager.remove(pw.app.Product__c);
                }
            }
        } 
        //MIGRATED 03/11/2016
        else {
            for(productWrapper pw: listAvailableProductsWrapper){
                if(pw.isSelected){
                    mapProdsInPager.put(pw.app.LAT_Product__c, pw.app);
                }else if(mapProdsInPager.containsKey(pw.app.LAT_Product__c) && pw.app.PaymentConditionDescription__c == paymentCondition){
                    mapProdsInPager.remove(pw.app.LAT_Product__c);
                }
            }
        }    

    }
    
    public PageReference doSearchProducts(){
        reloadAvailableProducts();
        return null;
    }
    
    //metodo que se ejecuta con el boton 'Agregar'. Agrega los productos seleccionads al ShoppingCart
    public Pagereference doAddItemsToShoppingCart(){
        
        loadMapProductsInPager();
        if(!Utils.wasMigrationDone('1')) {
            for(LAT_Account_product_payment__c app : mapProdsInPager.values()){
                OpportunityLineItem newOli = new OpportunityLineItem(
                    PricebookEntry = mapProdIdPBE.get(app.Product__c),
                    PriceBookEntryId = mapProdIdPBE.get(app.Product__c).Id,
                    UnitPrice = 0,
                    LAT_PaymentCondition__c = app.PaymentCondition__c,
                    LAT_PaymentConditionDescription__c = app.PaymentConditionDescription__c,
                    LAT_PercentualBonus__c = app.PercentualBonus__c,
                    LAT_SkuText__c = app.Product__r.Sku__c,
                    LAT_UnitCode__c = app.Product__r.CD_Unit__c,
                    BottlesPerBox__c = app.Product__r.bottles_per_box__c,
                    UnitWeight__c = app.Product__r.unit_weight__c,
                    LAT_MultipleQuantity__c = app.MultipleQuantity__c
                );
                shoppingCart.add(new productShoppingCart(newOli));
            }
            doChangePaymentCondition();
            reloadAvailableProducts();
            return null;
        }
        //MIGRATED 03/11/2016 
        else {
            for(LAT_Account_product_payment__c app : mapProdsInPager.values()){
                System.debug('%%%%%%%%%%%%%%%%%%%% appEn doAddItemsToShoppingCart : '+app);
                System.debug('%%%%%%%%%%%%%%%%%%%% prod en app en doAddItemsToShoppingCart : '+app.LAT_Product__r.Name + ' | '+app.LAT_Product__c);

                LAT_OpportunityLineItem__c newOli = new LAT_OpportunityLineItem__c(
                    LAT_Product__r = app.LAT_Product__r,
                    LAT_Product__c = app.LAT_Product__c,
                    LAT_UnitPrice__c = 0,
                    LAT_PaymentCondition__c = app.PaymentCondition__c,
                    LAT_PaymentConditionDescription__c = app.PaymentConditionDescription__c,
                    LAT_PercentualBonus__c = app.PercentualBonus__c,
                    LAT_SkuText__c = app.LAT_Product__r.LAT_Sku__c,
                    LAT_UnitCode__c = app.LAT_Product__r.LAT_CDUnit__c,
                    LAT_BottlesPerBox__c = app.LAT_Product__r.LAT_BottlesPerBox__c,
                    LAT_UnitWeight__c = app.LAT_Product__r.LAT_UnitWeight__c,
                    LAT_MultipleQuantity__c = app.MultipleQuantity__c
                );
                System.debug('aaaaaaaaa '+app.LAT_Product__r.name);
                System.debug('aaaaaaaaa '+app.LAT_Product__c);
                System.debug('aaaaaaaaa '+app.LAT_Product__r.LAT_BottlesPerBox__c);
                shoppingCart.add(new productShoppingCart(newOli));
            }
            doChangePaymentCondition();
            reloadAvailableProducts();
            return null;            
        }
    }
    
    //metodo que se ejectuta con el boton 'Remover'. Quita del shoppingCart el producto requerido
    public PageReference doRemoveFromShoppingCart(){
        if(!Utils.wasMigrationDone('1')){
            id idProdParam = Apexpages.currentPage().getParameters().get('idProdParam');
            Integer indexToRomeve;
            for(Integer i=0; i<shoppingCart.size(); i++){
                if(idProdParam == shoppingCart[i].oli.PriceBookEntry.Product2Id){
                    indexToRomeve = i;
                    break;
                }
            }
            if(indexToRomeve != null){
                shoppingCart.remove(indexToRomeve);
            }
            
            reloadAvailableProducts();
            return null;
        } 
        //MIGRATED 03/11/2016 
        else {
            id idProdParam = Apexpages.currentPage().getParameters().get('idProdParam');
            Integer indexToRomeve;
            for(Integer i=0; i<shoppingCart.size(); i++){
                if(idProdParam == shoppingCart[i].LAT_oli.LAT_Product__c){
                    indexToRomeve = i;
                    break;
                }
            }
            if(indexToRomeve != null){
                shoppingCart.remove(indexToRomeve);
            }
            
            reloadAvailableProducts();
            return null;            
        }
    }
    
    public PageReference doSave(){
        if(!Utils.wasMigrationDone('1')) {
            if(shoppingCart.isEmpty()){
                return null;
            }
            
            for(productShoppingCart psc: shoppingCart){
                if(psc.oli.quantity == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFP05_00024));
                    //Label.LAT_BR_VFP05_00024 = 'The quantity entered for the product must be greater than 0.'
                    return null;
                }
            }
            
            for(productShoppingCart psc: shoppingCart){
            
                if(psc.oli.QT_Bonus__c != null && psc.oli.Percentual_de_bonus__c != null){
                    psc.oli.QT_Bonus__c = psc.oli.QT_Bonus__c;
                    psc.oli.Percentual_de_bonus__c = psc.oli.Percentual_de_bonus__c;           
                }else if(psc.oli.QT_Bonus__c != null && psc.oli.Percentual_de_bonus__c == null){
                    psc.oli.QT_Bonus__c = psc.oli.QT_Bonus__c;
                    psc.oli.Percentual_de_bonus__c = ((psc.oli.QT_Bonus__c / psc.oli.Quantity) * 100);
                }else if(psc.oli.QT_Bonus__c == null && psc.oli.Percentual_de_bonus__c != null){
                    psc.oli.Percentual_de_bonus__c = psc.oli.Percentual_de_bonus__c;   
                    psc.oli.QT_Bonus__c = ((psc.oli.Quantity * psc.oli.Percentual_de_bonus__c) / 100);
                }
                          
                psc.oli = new OpportunityLineItem(
                    PricebookEntry = psc.oli.PricebookEntry,
                    PriceBookEntryId = psc.oli.PricebookEntryId,
                    UnitPrice = 0,
                    LAT_PaymentCondition__c = psc.oli.LAT_PaymentCondition__c,
                    LAT_PaymentConditionDescription__c = psc.oli.LAT_PaymentConditionDescription__c,
                    LAT_SkuText__c = psc.oli.LAT_SkuText__c,
                    LAT_PercentualBonus__c = psc.oli.LAT_PercentualBonus__c,
                    LAT_UnitCode__c = psc.oli.LAT_UnitCode__c,
                    BottlesPerBox__c = psc.oli.BottlesPerBox__c,
                    UnitWeight__c = psc.oli.UnitWeight__c,
                    LAT_MultipleQuantity__c = psc.oli.LAT_MultipleQuantity__c,
                    Quantity = psc.oli.Quantity,
                    QT_Bonus__c = psc.oli.QT_Bonus__c,
                    Percentual_de_bonus__c = psc.oli.Percentual_de_bonus__c  
                );
                            
            }
            
            String errorSave;
            Savepoint sp = Database.setSavepoint();
            try{
                insert theOpp;
            }catch(DMLException e){
                errorSave = e.getMessage();
            }
            
            List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
            for(productShoppingCart psc: shoppingCart){
                if(!psc.notApply){
                    psc.oli.OpportunityId = theOpp.Id;
                    olisToInsert.add(psc.oli);
                }
            }
            
            try{
                insert olisToInsert;
            }catch(DMLException e){
                errorSave = e.getMessage();
            }
            
            if(errorSave != null){
                Database.rollback(sp);
                theOpp = theOpp.clone(false);
                for(productShoppingCart psc: shoppingCart){
                    psc.oli = psc.oli.clone(false);
                }
            }else{
                return new PageReference('/'+theOpp.Id);
            }
            
            return null;
        }
        //MIGRATED 03/11/2016
        else {
            if(shoppingCart.isEmpty()){
                return null;
            }
            
            for(productShoppingCart psc: shoppingCart){
                if(psc.LAT_oli.LAT_Quantity__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFP05_00024));
                    //Label.LAT_BR_VFP05_00024 = 'The quantity entered for the product must be greater than 0.'
                    return null;
                }
            }
            
            for(productShoppingCart psc: shoppingCart){
            
                if(psc.LAT_oli.LAT_QTBonus__c != null && psc.LAT_oli.LAT_PercentualOfBonus__c != null){
                    psc.LAT_oli.LAT_QTBonus__c = psc.LAT_oli.LAT_QTBonus__c;
                    psc.LAT_oli.LAT_PercentualOfBonus__c = psc.LAT_oli.LAT_PercentualOfBonus__c;           
                }else if(psc.LAT_oli.LAT_QTBonus__c != null && psc.LAT_oli.LAT_PercentualOfBonus__c == null){
                    psc.LAT_oli.LAT_QTBonus__c = psc.LAT_oli.LAT_QTBonus__c;
                    psc.LAT_oli.LAT_PercentualOfBonus__c = ((psc.LAT_oli.LAT_QTBonus__c / psc.LAT_oli.LAT_Quantity__c) * 100);
                }else if(psc.LAT_oli.LAT_QTBonus__c == null && psc.LAT_oli.LAT_PercentualOfBonus__c != null){
                    psc.LAT_oli.LAT_PercentualOfBonus__c = psc.LAT_oli.LAT_PercentualOfBonus__c;   
                    psc.LAT_oli.LAT_QTBonus__c = ((psc.LAT_oli.LAT_Quantity__c * psc.LAT_oli.LAT_PercentualOfBonus__c) / 100);
                }
                          
                psc.LAT_oli = new LAT_OpportunityLineItem__c(
                    LAT_Product__c = psc.LAT_oli.LAT_Product__c,
                    LAT_UnitPrice__c = 0,
                    LAT_PaymentCondition__c = psc.LAT_oli.LAT_PaymentCondition__c,
                    LAT_PaymentConditionDescription__c = psc.LAT_oli.LAT_PaymentConditionDescription__c,
                    LAT_SkuText__c = psc.LAT_oli.LAT_SkuText__c,
                    LAT_PercentualBonus__c = psc.LAT_oli.LAT_PercentualBonus__c,
                    LAT_UnitCode__c = psc.LAT_oli.LAT_UnitCode__c,
                    LAT_BottlesPerBox__c = psc.LAT_oli.LAT_BottlesPerBox__c,
                    LAT_UnitWeight__c = psc.LAT_oli.LAT_UnitWeight__c,
                    LAT_MultipleQuantity__c = psc.LAT_oli.LAT_MultipleQuantity__c,
                    LAT_Quantity__c = psc.LAT_oli.LAT_Quantity__c,
                    LAT_QTBonus__c = psc.LAT_oli.LAT_QTBonus__c,
                    LAT_PercentualOfBonus__c = psc.LAT_oli.LAT_PercentualOfBonus__c  
                );
                            
            }
            
            String errorSave;
            Savepoint sp = Database.setSavepoint();
            try{
                insert LAT_theOpp;
            }catch(DMLException e){
                errorSave = e.getMessage();
            }
            
            List<LAT_OpportunityLineItem__c> olisToInsert = new List<LAT_OpportunityLineItem__c>();
            for(productShoppingCart psc: shoppingCart){
                if(!psc.notApply){
                    psc.LAT_oli.LAT_Opportunity__c = LAT_theOpp.Id;
                    olisToInsert.add(psc.LAT_oli);
                }
            }
            
            try{
                insert olisToInsert;
            }catch(DMLException e){
                errorSave = e.getMessage();
            }
            
            if(errorSave != null){
                Database.rollback(sp);
                LAT_theOpp = LAT_theOpp.clone(false);
                for(productShoppingCart psc: shoppingCart){
                    psc.LAT_oli = psc.LAT_oli.clone(false);
                }
            }else{
                return new PageReference('/'+LAT_theOpp.Id);
            }
            
            return null;
        }

    }
    
    public void doCalculatePrice(){
        
        if(shoppingCart.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFP05_00026));
            //Label.LAT_BR_VFP05_00026 = 'Favor selecionar produtos para a simulação de preços.'
            return;
        }
        
        if(!Utils.wasMigrationDone('1')) {
            theOpp.Integracao_Retorno_JDE__c = null;
            
            List<OpportunityLineItem> oliShoppingCart = new List<OpportunityLineItem>();
            for(productShoppingCart psc: shoppingCart){
                if(psc.oli.quantity == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFP05_00024));
                    //Label.LAT_BR_VFP05_00024 = 'The quantity entered for the product must be greater than 0.'
                    return;
                }
                if(!psc.notApply){
                    psc.oli.UnitPrice = 0;
                    psc.oli.Campo_de_formatacao__c = null;
                    oliShoppingCart.add(psc.oli);
                }
            }
            
            //Ejecuto la interfaz de precios
            String returnInterface = PriceCalculationInterface.PriceCalculation(null, theOpp, oliShoppingCart);
            if(returnInterface != ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, returnInterface));
            }
            
            Savepoint sp = Database.setSavepoint();
            try{
                insert theOpp;
                for(OpportunityLineItem oli: oliShoppingCart){
                    oli.OpportunityId = theOpp.Id;
                }
                insert oliShoppingCart;
            }catch(DMLException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFP05_00025));
                //Label.Label.LAT_BR_VFP05_00024 = 'Ocorreu um erro ao calcular os preços. Por favor tente novamente em alguns minutos. Se o problema persistir, contate o Help Desk.'
            }
            
            map<Id, OpportunityLineItem> mapOlis = new map<Id, OpportunityLineItem>();
            for(OpportunityLineItem oli: [SELECT PriceBookEntry.Product2Id, PricebookEntry.Product2.Name, PricebookEntry.Product2.CD_Unit__c, LAT_MultipleQuantity__c, LAT_PercentualBonus__c, Quantity, QT_Bonus__c, Percentual_de_bonus__c, Qt_total__c, LAT_PaymentConditionDescription__c, UnitPrice, Preco_total__c, BottlesPerBox__c, preco_garrafa__c, UnitWeight__c, Campo_de_formatacao__c, PricebookEntryId, LAT_PaymentCondition__c, LAT_SkuText__c, LAT_UnitCode__c FROM OpportunityLineItem WHERE OpportunityId =: theOpp.Id]){
                mapOlis.put(oli.Id, oli);
            }
            
            theOpp = theOpp.clone(false);
            for(productShoppingCart psc: shoppingCart){
                if(mapOlis.containsKey(psc.oli.Id)){
                    psc.oli = mapOlis.get(psc.oli.Id).clone(false);
                }
            }
            Database.rollback(sp);

        }

        //MIGRATED 03/11/2016 
        else {        
            LAT_theOpp.LAT_JDEIntegrationReturn__c = null;
            
            List<LAT_OpportunityLineItem__c> oliShoppingCart = new List<LAT_OpportunityLineItem__c>();
            for(productShoppingCart psc: shoppingCart){
                if(psc.LAT_oli.LAT_Quantity__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFP05_00024));
                    //Label.LAT_BR_VFP05_00024 = 'The quantity entered for the product must be greater than 0.'
                    return;
                }
                if(!psc.notApply){
                    psc.LAT_oli.LAT_UnitPrice__c = 0;
                    psc.LAT_oli.LAT_FormatField__c = null;
                    oliShoppingCart.add(psc.LAT_oli);
                }
            }
            
            //Ejecuto la interfaz de precios
            String returnInterface = PriceCalculationInterface.LAT_PriceCalculation(null, LAT_theOpp, oliShoppingCart);
            if(returnInterface != ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, returnInterface));
            }
            
            Savepoint sp = Database.setSavepoint();
            try{
                insert LAT_theOpp;
                for(LAT_OpportunityLineItem__c oli: oliShoppingCart){
                    oli.LAT_Opportunity__c = LAT_theOpp.Id;
                }
                insert oliShoppingCart;
            }catch(DMLException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFP05_00025));
                //Label.Label.LAT_BR_VFP05_00024 = 'Ocorreu um erro ao calcular os preços. Por favor tente novamente em alguns minutos. Se o problema persistir, contate o Help Desk.'
            }
            
            map<Id, LAT_OpportunityLineItem__c> mapOlis = new map<Id, LAT_OpportunityLineItem__c>();
            for(LAT_OpportunityLineItem__c oli: [SELECT LAT_Product__c, LAT_Product__r.Name, LAT_Product__r.LAT_CDUnit__c, LAT_MultipleQuantity__c, LAT_PercentualBonus__c, LAT_Quantity__c, LAT_QTBonus__c, LAT_PercentualOfBonus__c, LAT_QTTotal__c, LAT_PaymentConditionDescription__c, LAT_UnitPrice__c, LAT_PriceTotal__c, LAT_BottlesPerBox__c, LAT_BottlePrice__c, LAT_UnitWeight__c, LAT_FormatField__c, LAT_PaymentCondition__c, LAT_SkuText__c, LAT_UnitCode__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: LAT_theOpp.Id]){
                mapOlis.put(oli.Id, oli);
            }
            
            LAT_theOpp = LAT_theOpp.clone(false);
            for(productShoppingCart psc: shoppingCart){
                if(mapOlis.containsKey(psc.LAT_oli.Id)){
                    psc.LAT_oli = mapOlis.get(psc.LAT_oli.Id).clone(false);
                }
            }
            Database.rollback(sp);
        } 

    }
    
    public void doClean(){
        shoppingCart.clear();
        reloadAvailableProducts();
    }
    
    public void doChangePaymentCondition(){
        if (!Utils.wasMigrationDone('1')) {
            set<Id> setProdInShoppingCart = new set<Id>();
            for(productShoppingCart psc: shoppingCart){
                setProdInShoppingCart.add(psc.oli.PricebookEntry.Product2Id);
            }
            
            map<Id, LAT_Account_product_payment__c> mapAvailableProds = new map<Id, LAT_Account_product_payment__c>();
            for(LAT_Account_product_payment__c app: [SELECT Id, Account__c, Product__c, Product__r.Name, Product__r.CD_Unit__c, Payment__c, PaymentCondition__c, PaymentConditionDescription__c, PercentualBonus__c FROM LAT_Account_product_payment__c WHERE Account__c =: theOpp.AccountId AND Product__c IN: setProdInShoppingCart AND Payment__r.Name =: paymentCondition]){
                mapAvailableProds.put(app.Product__c, app);
            }
            
            for(productShoppingCart psc: shoppingCart){
                
                psc.oli = new OpportunityLineItem(
                    PricebookEntry = psc.oli.PricebookEntry,
                    PriceBookEntryId = psc.oli.PricebookEntryId,
                    UnitPrice = 0,
                    LAT_PaymentCondition__c = mapPaymentCondition.get(paymentCondition),
                    LAT_PaymentConditionDescription__c = paymentCondition,
                    LAT_SkuText__c = psc.oli.LAT_SkuText__c,
                    LAT_UnitCode__c = psc.oli.LAT_UnitCode__c,
                    BottlesPerBox__c = psc.oli.BottlesPerBox__c,
                    UnitWeight__c = psc.oli.UnitWeight__c,
                    LAT_MultipleQuantity__c = psc.oli.LAT_MultipleQuantity__c,
                    Quantity = psc.oli.Quantity
                );
                
                if(!mapAvailableProds.containsKey(psc.oli.PricebookEntry.Product2Id)){
                    psc.notApply = true;
                }else{
                    psc.notApply = false;
                    psc.oli.LAT_PercentualBonus__c = mapAvailableProds.get(psc.oli.PricebookEntry.Product2Id).PercentualBonus__c;
                }
            }
            reloadAvailableProducts();
        }
        //MIGRATED 03/11/2016 
        else {
            set<Id> setProdInShoppingCart = new set<Id>();
            for(productShoppingCart psc: shoppingCart){
                setProdInShoppingCart.add(psc.LAT_oli.LAT_Product__c);
            }
            System.debug('%%%%%%%%%%%%%%%%%%%% en DoChangePayCond LATsetProductIdsOnShoppingCart : '+setProdInShoppingCart);
            
            
            map<Id, LAT_Account_product_payment__c> mapAvailableProds = new map<Id, LAT_Account_product_payment__c>();
            for(LAT_Account_product_payment__c app: [SELECT Id, Account__c, LAT_Product__c, LAT_Product__r.Name, LAT_Product__r.LAT_CDUnit__c, Payment__c, PaymentCondition__c, PaymentConditionDescription__c, PercentualBonus__c FROM LAT_Account_product_payment__c WHERE Account__c =: LAT_theOpp.LAT_Account__c AND LAT_Product__c IN: setProdInShoppingCart AND Payment__r.Name =: paymentCondition]){
                mapAvailableProds.put(app.LAT_Product__c, app);
                System.debug('%%%%%%%%%%%%%%%%%%%% en DoChangePayCond resSelect : '+app);
            }
            
            for(productShoppingCart psc: shoppingCart){
                
                psc.LAT_oli = new LAT_OpportunityLineItem__c(
                    LAT_Product__c = psc.LAT_oli.LAT_Product__c,
                    LAT_Product__r = psc.LAT_oli.LAT_Product__r,
                    LAT_UnitPrice__c = 0,
                    LAT_PaymentCondition__c = mapPaymentCondition.get(paymentCondition),
                    LAT_PaymentConditionDescription__c = paymentCondition,
                    LAT_SkuText__c = psc.LAT_oli.LAT_SkuText__c,
                    LAT_UnitCode__c = psc.LAT_oli.LAT_UnitCode__c,
                    LAT_BottlesPerBox__c = psc.LAT_oli.LAT_BottlesPerBox__c,
                    LAT_UnitWeight__c = psc.LAT_oli.LAT_UnitWeight__c,
                    LAT_MultipleQuantity__c = psc.LAT_oli.LAT_MultipleQuantity__c,
                    LAT_Quantity__c = psc.LAT_oli.LAT_Quantity__c
                );
                
                if(!mapAvailableProds.containsKey(psc.LAT_oli.LAT_Product__c)){
                    psc.notApply = true;
                }else{
                    psc.notApply = false;
                    psc.LAT_oli.LAT_PercentualBonus__c = mapAvailableProds.get(psc.LAT_oli.LAT_Product__c).PercentualBonus__c;
                }
            }
            reloadAvailableProducts();            
        }
    }
    
    public void doShowPopup(){
        if(!Utils.wasMigrationDone('1')){
            itemPopUp = new List<OpportunityLineItem>();
            id idProdParam = Apexpages.currentPage().getParameters().get('idProdParam');
            for(productShoppingCart psc: shoppingCart){
                if(idProdParam == psc.oli.PriceBookEntry.Product2Id){
                    itemPopUp.add(psc.oli);
                    break;
                }
            }
            displayPopup = true;
        }
        //MIGRATED 03/11/2016 
        else {
            LAT_itemPopUp = new List<LAT_OpportunityLineItem__c>();
            id idProdParam = Apexpages.currentPage().getParameters().get('idProdParam');
            for(productShoppingCart psc: shoppingCart){
                if(idProdParam == psc.LAT_oli.LAT_Product__c){
                    LAT_itemPopUp.add(psc.LAT_oli);
                    break;
                }
            }
            displayPopup = true;            
        }
    }
    
    public void doClosePopup(){
        displayPopup = false;
    }
    
    public PageReference doCancel(){
        return new PageReference('/001/o');
    }
}