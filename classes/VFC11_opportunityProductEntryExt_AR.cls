/*************************************************************************************************
 Dev: Juan Pablo Cubo       Version: 1
 Controller for the opportunity product page, copy of opportunityProductEntryExtension, customized
 for the Argentina/Uruguay version.
**************************************************************************************************/

public with sharing class VFC11_opportunityProductEntryExt_AR {

    public transient List<OpportunityLineItem> itemOpp{get; private set;}   
    public map <string, string> errorMessagesDiscount {get; set;} 
    public transient OpportunityLineItem[] shoppingCart {get;set;}
    public List<productWrapper> lstWProducts {get; set;}// Seleção de itens por checkbox e envio para o carrinho de compras
    public PageReference PaymentValues {get;set;}
    public boolean displayPopup {get; set;}
    public string measurementUnit {get; set;}
    public String searchString {get;set;}
    public String toUnselect {get; set;}
    public transient Pricebook2 theBook {get;set;}
    public Boolean overLimit {get;set;}
    public String idOppOli {get; set;}
    public String erroSave {get; set;}
    public Boolean allowEdit {get; set;}
    public transient Opportunity theOpp {get; set;}
    public Map<Id, String> stockByProductId {get; set;}
    
    private transient map <string, OpportunityLineItem> shoppingCartProxies; //product id, proxy oli 
    private transient map <id, PricebookEntry> pricebookEntriesByProduct; //Product id, pricebook entry
    private List<LAT_Account_product_payment__c> AvailableProducts;
    private transient Boolean multipleCurrencies;
    private static String country;
    private static String countryName;

    public Boolean showStockValues {get;set;}
    public Boolean checkStockValues {get;set;}

    //VARIABLES MIGRACION LICENCIAS
    public List<LAT_OpportunityLineItem__c> LAT_itemOpp{get; private set;}      
    public LAT_OpportunityLineItem__c[] LAT_shoppingCart {get;set;}
    public LAT_Opportunity__c LAT_theOpp {get; set;}
    private map <string, LAT_OpportunityLineItem__c> LAT_shoppingCartProxies; //product id, proxy oli 
    private transient Map<id, LAT_Product__c> LAT_pricebookEntriesByProduct {get; private set;} //Product id, product
    private LAT_OpportunityLineItem__c[] LAT_forDeletion = new LAT_OpportunityLineItem__c[]{};
    private map<Id, LAT_OpportunityLineItem__c> LAT_shoppingCartOriginal {get;set;}
    
    // Classe para ter os produtos selecionados
    public class productWrapper {
      public Boolean isSelected {get; set;}
      public LAT_Account_product_payment__c app {get; set;} 
      
      // Construtor com o objeto dentro
      public productWrapper (LAT_Account_product_payment__c appParam) {
        app = appParam;
        isSelected = false;
      }
    }
    
    Datetime d;
    private opportunityLineItem[] forDeletion = new opportunityLineItem[]{};
    private map <Id, boolean> wasProductCanceled = new map <Id, boolean>();
    private static final String COND_PAGTO_AVISTA = 'V00';
    private static final Integer QTDE_REGISTROS = 301;
    private Boolean forcePricebookSelection = false;
    private String varCondicaoDefault;
    private boolean oppAVista = false;
    private String grupoPreco;
    private String idAccount;
    private Account accountData;
    private Pricebook2 stdPriceBook;   
    private map<Id, OpportunityLineItem> shoppingCartOriginal {get;set;}  
    private ApexPages.StandardController controller;
    
    public VFC11_opportunityProductEntryExt_AR(ApexPages.StandardController controller) {
        /*if(!Utils.wasMigrationDone('6')) {   
            this.controller = controller;
            multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
            // Get information about the Opportunity being worked on
            //if(multipleCurrencies) {
                theOpp = [SELECT Id, Valor_total__c , RecordType.Name, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode, Grupo_de_precos__c, Campo_de_formatacao__c, AccountId, Account.Payment_Condition__c, Account.Price_Group__c, CreditLimitBalance_AR__c, NR_order_JDE__c, Amount FROM Opportunity WHERE Id =: controller.getRecord().Id];
            //} else {
            //    theOpp = [SELECT Id, Valor_total__c , RecordType.Name, Pricebook2Id, PriceBook2.Name, Grupo_de_precos__c, Campo_de_formatacao__c, AccountId, Account.Payment_Condition__c, Account.Price_Group__c, CreditLimitBalance_AR__c, NR_order_JDE__c, Amount FROM Opportunity WHERE Id = :controller.getRecord().Id LIMIT 1];
            //}
            pricebookEntriesByProduct = new map <id, PricebookEntry>();
            List <PricebookEntry> pbeList = [SELECT Id, Product2Id, Product2.Id, Product2.bottles_per_box__c, Product2.ProductCode FROM PricebookEntry WHERE Product2.LAT_IsRefactorProduct__c = 'Y' AND Product2.IsActive = true AND Pricebook2.isStandard = true AND CurrencyIsoCode =: theOpp.CurrencyIsoCode];
            for (PricebookEntry pbe : pbeList) {
                pricebookEntriesByProduct.put(pbe.Product2Id, pbe);
            }
            init();
            shoppingCartOriginal = new map<Id, OpportunityLineItem>(shoppingCart.clone());
        }
        //MIGRATED 8/11/2016
        else {*/
            this.controller = controller;
            multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
            // Get information about the Opportunity being worked on
            //if(multipleCurrencies) {
            LAT_theOpp = [SELECT Id, LAT_TotalValue__c , RecordType.Name, CurrencyIsoCode, LAT_AccountPriceBook__c, LAT_FormatField__c, LAT_Account__c, LAT_Account__r.Payment_Condition__c, LAT_Account__r.Client_country_an8__c, LAT_Account__r.Price_Group__c, LAT_AR_CreditLimitBalance__c, LAT_NROrderJDE__c, LAT_Amount__c FROM LAT_Opportunity__c WHERE Id =: controller.getRecord().Id];
            //} else {
            //    theOpp = [SELECT Id, Valor_total__c , RecordType.Name, Pricebook2Id, PriceBook2.Name, Grupo_de_precos__c, Campo_de_formatacao__c, AccountId, Account.Payment_Condition__c, Account.Price_Group__c, CreditLimitBalance_AR__c, NR_order_JDE__c, Amount FROM Opportunity WHERE Id = :controller.getRecord().Id LIMIT 1];
            //}
           
            
            init();
            LAT_shoppingCartOriginal = new map<Id, LAT_OpportunityLineItem__c>(LAT_shoppingCart.clone());            
        //}
    }
    
    private void loadProductsMap() {
        LAT_pricebookEntriesByProduct = new map <id, LAT_Product__c>();
        stockByProductId              = new Map<Id, String>();
        country = '6';
        if (LAT_theOpp.RecordType.Name.endsWith('URU')) { 
            country = '5';
        }
        String externalId = country + '-%';
        System.debug('%%%%% externalId : ' + externalId);
        Set<id> shoppingCartProdIds = new Set<Id>();
        for (LAT_OpportunityLineItem__c oli : LAT_ShoppingCart) {
            shoppingCartProdIds.add(oli.LAT_Product__c);
        }
        List <LAT_Product__c> pbeList = [SELECT Id, LAT_BottlesPerBox__c, LAT_ProductCode__c, Name, (SELECT Id, LAT_Product__c, LAT_Stock__c, tolabel(LAT_StockLevel__c) FROM Lat_StocksList__r WHERE LAT_Branch__c =: accountData.Business_Unit_AR__r.CodDefUsuario__c) FROM LAT_Product__c WHERE (LAT_IsActive__c = true AND LAT_ExternalID__c LIKE :externalId) OR Id IN :shoppingCartProdIds /* AND CurrencyIsoCode =: LAT_theOpp.CurrencyIsoCode*/];
        System.debug('%%% pbeList.size() : ' + pbeList.size());
        for (LAT_Product__c pbe : pbeList) {
            System.debug('%%%%% pbeID : ' + pbe.Id);
            LAT_pricebookEntriesByProduct.put(pbe.Id, pbe);
            if (pbe.Lat_StocksList__r.size() > 0) {
                stockByProductId.put(pbe.Id, String.valueOf(pbe.Lat_StocksList__r[0].LAT_Stock__c));
            } else {
                stockByProductId.put(pbe.Id, '');
            }
            
        }
    }

    private void init(){
        /*if(!Utils.wasMigrationDone('6')) {
            // Instancia a lista de objetos Wrapper
            shoppingCartProxies = new map <string, OpportunityLineItem>(); 
            lstWProducts = new List<productWrapper>();
            if (errorMessagesDiscount == null) {
                errorMessagesDiscount = new map <string, string>();
            }
            // Need to know if org has multiple currencies enabled
            erroSave = 'SEM ERRO';
            
            idAccount = theOpp.AccountId;
            accountData = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c FROM Account WHERE Id =: idAccount];
            varCondicaoDefault = Utils.getCodeFromUDC(theOpp.Account.Payment_Condition__c);
            grupoPreco = theOpp.Account.Price_Group__c;
            if (theOpp.RecordType.Name.endsWith('ARG')) {
                measurementUnit = 'CA';
            } else if (theOpp.RecordType.Name.endsWith('URU')) { 
                measurementUnit = 'BT';
            }
            allowEdit = (!theOpp.RecordType.Name.contains('Order Blocked'));
            //If products were previously selected need to put them in the "selected products" section to start with
            loadShoppingCart();
                
            for (OpportunityLineItem oli : ShoppingCart) {
                wasProductCanceled.put (oli.Id, oli.Remover__c);
                OpportunityLineItem proxyOli = new OpportunityLineItem();
                proxyOli.Campo_de_formatacao__c = oli.Campo_de_formatacao__c;
                shoppingCartProxies.put(oli.PriceBookEntry.Product2Id, proxyOli);
            }
            
            
            try {
                stdPriceBook = [SELECT Id,Name FROM Pricebook2 WHERE isActive = true AND isStandard = true];
            } catch (Exception e) {

            }
                
            if(theOpp.Pricebook2Id == null){
                if (stdPriceBook != null) {
                    theBook = stdPriceBook;
                } else {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, 'The standard pricebook is not active.'));
                    return;
                }
            } else {
                theBook = theOpp.Pricebook2;
            }
            
            if (thebook == stdPriceBook) {
                updateAvailableListCheck();
            }
        }
        //MIGRATED 8/11/2016
        else {*/
            // Instancia a lista de objetos Wrapper
            country = '6';
            if (LAT_theOpp.RecordType.Name.endsWith('ARG')) {
                measurementUnit = 'CA';
                countryName = 'Argentina';
            } else if (LAT_theOpp.RecordType.Name.endsWith('URU')) { 
                measurementUnit = 'BT';
                country = '5';
                countryName = 'Uruguay';
            }
            if (errorMessagesDiscount == null) {
                errorMessagesDiscount = new map <string, string>();
            }
            idAccount = LAT_theOpp.LAT_Account__c;
            accountData = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c FROM Account WHERE Id =: idAccount];
            loadShoppingCart();
            loadProductsMap();
            LAT_shoppingCartProxies = new map <string, LAT_OpportunityLineItem__c>(); 
            lstWProducts = new List<productWrapper>();
            
            // Need to know if org has multiple currencies enabled
            erroSave = 'SEM ERRO';
            
            varCondicaoDefault = Utils.getCodeFromUDC(LAT_theOpp.LAT_Account__r.Payment_Condition__c);
            grupoPreco = LAT_theOpp.LAT_Account__r.Price_Group__c;
            

            //checkStockValues = [SELECT LAT_CheckStock__c FROM CS001_JDEInterfaceCredentials__c WHERE Country__c =: country].LAT_CheckStock__c;
            checkStockValues = CS001_JDEInterfaceCredentials__c.getInstance(countryName).LAT_CheckStock__c;
            if (checkStockValues) {
                System.debug('%%%% countryName + '+countryName);
                System.debug('%%%% LAT_GeneralConfig__c.getInstance(countryName+\'_StockBusinessUnitsToCheck\').LAT_Value__c + '+LAT_GeneralConfig__c.getInstance(countryName+'_StockBusinessUnitsToCheck').LAT_Value__c);
                if (!LAT_GeneralConfig__c.getInstance(countryName+'_StockBusinessUnitsToCheck').LAT_Value__c.contains(accountData.Business_Unit_AR__r.CodDefUsuario__c)) {
                    checkStockValues = false;
                } 
            }
            allowEdit = (!LAT_theOpp.RecordType.Name.contains('Order Blocked'));
            //If products were previously selected need to put them in the "selected products" section to start with
                
            for (LAT_OpportunityLineItem__c oli : LAT_ShoppingCart) {
                wasProductCanceled.put (oli.Id, oli.LAT_Remover__c);
                LAT_OpportunityLineItem__c proxyOli = new LAT_OpportunityLineItem__c();
                proxyOli.LAT_FormatField__c = oli.LAT_FormatField__c;
                LAT_shoppingCartProxies.put(oli.LAT_Product__c, proxyOli);
            }
            
            updateAvailableListCheck();
                       
        //}

    }
    
    public void initAction(){
        /*if(!Utils.wasMigrationDone('6')) {        
            if (thebook != stdPriceBook) {
                List<PricebookEntry> lstPbeInsert = new List<PricebookEntry>();
                for (PricebookEntry pbe : pricebookEntriesByProduct.values()) {
                    PricebookEntry pbeStd = new PricebookEntry();
                    pbeStd.CurrencyIsoCode = theOpp.CurrencyIsoCode;
                    pbeStd.IsActive = true;
                    pbeStd.Pricebook2Id = theBook.Id;
                    pbeStd.Product2Id = pbe.Product2Id;
                    //pbeStd.UseStandardPrice = true;
                    pbeStd.UnitPrice = 0;
                    lstPbeInsert.add(pbeStd);
                }
                try {
                    Database.upsert(lstPbeInsert, false);
                    //insert lstPbeInsert;
                    updateAvailableListCheck();
                } catch (Exception e) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, 'new process error: ' + e.getMessage()));
                }
                List<PricebookEntry> updatedPBE = [SELECT Id, Product2Id, Product2.Id, Product2.bottles_per_box__c, Product2.ProductCode FROM PricebookEntry WHERE Product2.LAT_IsRefactorProduct__c = 'Y' AND Product2.IsActive = true AND Pricebook2Id =: theBook.Id];
                for (PricebookEntry pbe : updatedPBE) {
                    if (pbe.Id != null) {
                        pricebookEntriesByProduct.put(pbe.Product2Id, pbe);
                    }
                }
            }
        } 
        //MIGRATED 8/11/2016
        else {*/
            try {
                updateAvailableListCheck();
            } catch (Exception e) {
                     Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, 'new process error: ' + e.getMessage()));
            }      
        //}
    }
    
    private void loadShoppingCart()
    {
        //JPC: query changed to use new non formula fields in opportunityLineItem
        //PC_Bonus__c --> PercentualBonus__c
        //cd_payment_term__c --> PaymentCondition__c
        //ds_payment_term__c --> PaymentConditionDescription__c
        //QT_multiple__c --> LAT_MultipleQuantity__c
        //Sku__c --> SkuText__c
        //CD_unit__c --> UnitCode__c
        //bottles_per_box__c -- BottlesPerBox__c
        //unit_weight__c --> UnitWeight__c
       /*if(!Utils.wasMigrationDone('6')) {        
            shoppingCart = [ SELECT Id, Remover__c, cd_line_status__c, Percentual_de_bonus__c, 
                LAT_MultipleQuantity__c, LAT_PaymentConditionDescription__c, Campo_de_formatacao__c, NR_order_line__c, 
                LAT_PaymentCondition__c, LAT_UnitCode__c, LAT_PercentualBonus__c, pc_discount__c, Quantity, 
                TotalPrice, Preco_total__c, preco_garrafa__c, UnitPrice, Description, PriceBookEntryId, 
                LAT_SkuText__c, PriceBookEntry.Product2Id, 
                PriceBookEntry.Product2.Name, PriceBookEntry.PriceBook2Id, PriceBookEntry.Product2.Sku__c, 
                UnitWeight__c, BottlesPerBox__c, 
                PriceBookEntry.UnitPrice, qt_total__c, Descricao_do_status__c,
                PriceBookEntry.Product2.ProductCode, UOM_AR__c, MaxDiscount_AR__c, Discount, Discount_AR__c,
                SenttoApproveDiscount_AR__c, Backorder__c
                FROM OpportunityLineItem WHERE OpportunityId =: theOpp.Id ];
                
            if ( shoppingCart.size() > 0 ) oppAVista = shoppingCart[ 0 ].LAT_PaymentCondition__c == COND_PAGTO_AVISTA;
            
            for(opportunityLineItem itemLine : shoppingCart){
                if ((itemLine.Quantity==null) || (itemLine.Quantity==0))
                  itemLine.Quantity = 1;
                if (!errorMessagesDiscount.containsKey(itemLine.PriceBookEntry.Product2.Id)) {
                    errorMessagesDiscount.put(itemLine.PriceBookEntry.Product2.Id, '');
                }
            }
        }
        //MIGRATED 8/11/2016
        else {*/
            LAT_shoppingCart = [ SELECT Id, LAT_Remover__c, LAT_CdLineStatus__c, LAT_PercentualOfBonus__c, 
            LAT_MultipleQuantity__c, LAT_PaymentConditionDescription__c, LAT_FormatField__c, LAT_NROrderLine__c, 
            LAT_PaymentCondition__c, LAT_UnitCode__c, LAT_PercentualBonus__c, LAT_PcDiscount__c, LAT_Quantity__c, 
            LAT_TotalPrice__c, LAT_PriceTotal__c, LAT_BottlePrice__c, LAT_UnitPrice__c, LAT_Description__c,
            LAT_SkuText__c, LAT_Product__c,
            LAT_Product__r.Name, LAT_Product__r.LAT_Sku__c, 
            LAT_UnitWeight__c, LAT_BottlesPerBox__c, 
            LAT_QTTotal__c, LAT_StatusDescription__c,
            LAT_Product__r.LAT_ProductCode__c, LAT_AR_UOM__c, LAT_AR_MaxDiscount__c, LAT_Discount__c, LAT_AR_Discount__c,
            LAT_AR_SentToApproveDiscount__c, LAT_Backorder__c, LAT_JDETotalDiscount__c, LAT_AR_Total_Descuentos__c 
            FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: LAT_theOpp.Id ];
            
            if ( LAT_shoppingCart.size() > 0 ) oppAVista = LAT_shoppingCart[ 0 ].LAT_PaymentCondition__c == COND_PAGTO_AVISTA;
            
            for(LAT_OpportunityLineItem__c itemLine : LAT_shoppingCart){
                if ((itemLine.LAT_Quantity__c==null) || (itemLine.LAT_Quantity__c==0)) {
                  itemLine.LAT_Quantity__c = 1;
                } 

                if (!errorMessagesDiscount.containsKey(itemLine.LAT_Product__r.Id)) {
                    errorMessagesDiscount.put(itemLine.LAT_Product__r.Id, '');
                }
            }
        //}
    }
    
    /*private  Boolean IsForDelete(OpportunityLineItem item) { 
        return item.cd_line_status__c!=null && item.cd_line_status__c.trim()!='';
    }*/

    @testVisible
    private  Boolean IsForDelete(LAT_OpportunityLineItem__c item) { 
        return item.LAT_CdLineStatus__c!=null && item.LAT_CdLineStatus__c.trim()!='';
    }
    
    public String varPaymentVal {
        get { 
            if(varPaymentVal == null)
                varPaymentVal = varCondicaoDefault;
                return varPaymentVal;
        }set;
    }
    
    //Aciona a atualização dos itens da condição de pagamento.
    public PageReference paymentValues() {
        updateAvailableListCheck();
        return null;
    }

    //Preenche a variavel do popup.  
    public void getItemX()   
    {
        /*if(!Utils.wasMigrationDone('6')) {
            //itemOpp= [Select Id, Campo_de_formatacao__c from OpportunityLineItem where Id=:idOppOli   limit 1];
            for (string prodId : shoppingCartProxies.keyset()) {
                if (idOppOli == prodId) {
                    itemOpp = new OpportunityLineItem[]{shoppingCartProxies.get(prodId)};
                    break;
                }
            }
        }
        //MIGRATED 15/11/2016
        else {*/
            System.debug('%%%%%%%%%   idOppOli : '+ idOppOli);
            
            System.debug('%%%%%%%%%   LAT_shoppingCartProxies : '+ LAT_shoppingCartProxies);
            //itemOpp= [Select Id, Campo_de_formatacao__c from OpportunityLineItem where Id=:idOppOli   limit 1];
            for (string prodId : LAT_shoppingCartProxies.keyset()) {
                if (idOppOli == prodId) {
                    LAT_itemOpp = new LAT_OpportunityLineItem__c[]{LAT_shoppingCartProxies.get(prodId)};
                    break;
                }
            }            
        //}    

    }
    
    //Fecha o popup.
    public void closePopup() {
        displayPopup = false;
    }
    
    //Abre o popup.
    public void showPopup() {
        System.debug('%%%%%%%%%   idOppOli : ');
            
        System.debug('%%%%%%%%%   idOppOli : '+ idOppOli);
            
        getItemX();        
        displayPopup = true;
    }
    
    //JPC: method modified to use the new product schema
    public List<Selectoption> getCondicao() 
    {
        /*if(!Utils.wasMigrationDone('6')) {         
            //Declaração de variaveis.                       
            List<Selectoption> options = new List<Selectoption>();
            List<Product2> listcondicao = new List<Product2>();
            Set<String> setCodPagamento = new Set<String>();
            
            
            //Instância Lista de Selectoptions.
            options = new List<Selectoption>();
            options.add(new SelectOption('Todas','Todas'));
            
            //Recupera as condições de pagamentos disponiveis para o cliente, 
            //utilizando o grupo de preço cadastrado no cliente.
            
            List <AggregateResult> groupedResults = [ SELECT PaymentCondition__c, PaymentConditionDescription__c 
                FROM LAT_Account_product_payment__c
                WHERE Account__c =: idAccount
                GROUP BY PaymentCondition__c, PaymentConditionDescription__c
                ORDER BY PaymentConditionDescription__c];
            for (AggregateResult ar : groupedResults)  {
                if (ar.get('PaymentCondition__c') != null) {
                    options.add(new SelectOption(String.valueOf(ar.get('PaymentCondition__c')),String.valueOf(ar.get('PaymentConditionDescription__c'))));
                }
            }
            return options;   
        }
        //MIGRATED 8/11/2016
        else {*/
            //Declaração de variaveis.                       
            List<Selectoption> options = new List<Selectoption>();
            List<LAT_Product__c> listcondicao = new List<LAT_Product__c>();
            Set<String> setCodPagamento = new Set<String>();
            
            
            //Instância Lista de Selectoptions.
            options = new List<Selectoption>();
            options.add(new SelectOption('Todas','Todas'));
            
            //Recupera as condições de pagamentos disponiveis para o cliente, 
            //utilizando o grupo de preço cadastrado no cliente.
            
            List <AggregateResult> groupedResults = [ SELECT PaymentCondition__c, PaymentConditionDescription__c 
                FROM LAT_Account_product_payment__c
                WHERE Account__c =: idAccount
                GROUP BY PaymentCondition__c, PaymentConditionDescription__c
                ORDER BY PaymentConditionDescription__c];
            for (AggregateResult ar : groupedResults)  {
                if (ar.get('PaymentCondition__c') != null) {
                    options.add(new SelectOption(String.valueOf(ar.get('PaymentCondition__c')),String.valueOf(ar.get('PaymentConditionDescription__c'))));
                }
            }
            return options;              
        //} 
    }
    
    // this is the 'action' method on the page
    /*public PageReference priceBookCheck(){
    
        // if the user needs to select a pricebook before we proceed we send them to standard pricebook selection screen
        if(forcePricebookSelection){        
            return changePricebook();
        }
        else{
         
            //if there is only one active pricebook we go with it and save the opp
            if(theOpp.pricebook2Id != theBook.Id){
                try{
                    theOpp.Pricebook2Id = theBook.Id;
                    update(theOpp);
                }
                catch(Exception e){
                    ApexPages.addMessages(e);
                }
            }
            
            return null;
        }
    }*/
       
    public String getChosenCurrency(){
        /*if(!Utils.wasMigrationDone('6')) {  
            if(multipleCurrencies)
                return (String)theOpp.get('CurrencyIsoCode');
            else
                return '';
        }
        //MIGRATED 15/11/2016
        else {*/
            if(multipleCurrencies)
                return (String)LAT_theOpp.get('CurrencyIsoCode');
            else
                return '';            
        //}
    } 
    
    //Atualiza lista de produtos disponíveis.
    //JPC: method modified to use the new product schema, available products now are queried from LAT_Account_product_payment__c
    public void updateAvailableListCheck() {
        /*if(!Utils.wasMigrationDone('6')) {         
            // We dynamically build a query string and exclude items already in the shopping cart
            String qString = 'SELECT Id, Product__c, Product__r.LAT_IsRefactorProduct__c, PaymentCondition__c, PaymentConditionDescription__c, Product__r.Sku__c, MultipleQuantity__c, Product__r.unit_weight__c, Product__r.bottles_per_box__c, Product__r.cd_unit__c, PercentualBonus__c, Product__r.Name, Product__r.Family, Product__r.IsActive, Product__r.Description, Product__r.ProductCode, Account__r.Client_code_AN8__c FROM LAT_Account_product_payment__c WHERE Account__c =: idAccount AND Product__r.IsActive = true';
            //if(multipleCurrencies)
                //qstring += ' AND CurrencyIsoCode = \'' + theOpp.get('currencyIsoCode') + '\'';
            
            
            // note that we are looking for the search string entered by the user in the name OR description
            // modify this to search other fields if desired
            
            if(searchString != null)
            {
                qString+= ' AND (Product__r.Name like \'%' + searchString + '%\' or Product__r.Description like \'%' + searchString + '%\')';
            }
            if(varPaymentVal != 'Todas')
            {
                qString += ' AND PaymentCondition__c like \'%' + varPaymentVal+ '%\'';
            }
            
            Set<string> selectedEntries = new Set<string>();
            for(opportunityLineItem d:shoppingCart){
                if(d.Remover__c == false) {
                    selectedEntries.add(accountData.Client_code_AN8__c + d.LAT_SkuText__c + d.LAT_PaymentCondition__c);
                }
            }
            
            qString+= ' ORDER BY Product__r.Name';
            qString+= ' LIMIT ' + QTDE_REGISTROS;
            System.debug('%%%%%%%%%%%%%%%%%%%%% queri app '+qString);
            AvailableProducts = database.query(qString);
            // We only display up to X results... if there are more than we let the user know (see vf page)
            if(AvailableProducts.size()==QTDE_REGISTROS){
                AvailableProducts.remove(QTDE_REGISTROS-1);
                overLimit = true;
            }
            else{
                overLimit=false;
            }
            
            //query pricebookentries to check if the product has the current opp currency
            List <PricebookEntry> pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2.LAT_IsRefactorProduct__c = 'Y' AND CurrencyIsoCode =: theOpp.CurrencyIsoCode AND Pricebook2Id =: theBook.Id];
            Set <Id> product2Set = new Set <Id>();
            for (PricebookEntry pbe : pbeList) {
                product2Set.add(pbe.Product2Id);
            }
            // Carrega os produtos na lista de ProductWrapper
            lstWProducts.clear();
            for (LAT_Account_product_payment__c app : AvailableProducts){
                string currentKey = app.Account__r.Client_code_AN8__c + app.Product__r.Sku__c + app.PaymentCondition__c;
                if (!selectedEntries.contains(currentKey) && product2Set.contains(app.Product__c) && app.Product__r.LAT_IsRefactorProduct__c == 'Y') {
                    lstWProducts.add(new productWrapper(app));
                }
            }
        } 
        //MIGRATED 8/11/2016
        else {*/
            // We dynamically build a query string and exclude items already in the shopping cart
            String qString = 'SELECT Id, LAT_Product__c, LAT_Product__r.LAT_IsRefactorProduct__c, PaymentCondition__c, PaymentConditionDescription__c, LAT_Product__r.LAT_Sku__c, MultipleQuantity__c, LAT_Product__r.LAT_UnitWeight__c, LAT_Product__r.LAT_BottlesPerBox__c, LAT_Product__r.LAT_CDUnit__c, PercentualBonus__c, LAT_Product__r.Name, LAT_Product__r.LAT_Description__c, LAT_Product__r.LAT_ProductCode__c, Account__r.Client_code_AN8__c FROM LAT_Account_product_payment__c WHERE Account__c =: idAccount AND LAT_Product__r.LAT_IsActive__c = true';
            //if(multipleCurrencies)
                //qstring += ' AND CurrencyIsoCode = \'' + theOpp.get('currencyIsoCode') + '\'';
            
            
            // note that we are looking for the search string entered by the user in the name OR description
            // modify this to search other fields if desired
            
            if(searchString != null)
            {
                qString+= ' AND (LAT_Product__r.Name like \'%' + searchString + '%\' or LAT_Product__r.LAT_Description__c like \'%' + searchString + '%\')';
            }
            if(varPaymentVal != 'Todas')
            {
                qString += ' AND PaymentCondition__c like \'%' + varPaymentVal+ '%\'';
            }
            
            Set<string> selectedEntries = new Set<string>();
            for(LAT_OpportunityLineItem__c d:LAT_shoppingCart){
                if(d.LAT_Remover__c == false) {
                    selectedEntries.add(accountData.Client_code_AN8__c + d.LAT_SkuText__c + d.LAT_PaymentCondition__c);
                }
            }
            
            qString+= ' ORDER BY LAT_Product__r.Name';
            qString+= ' LIMIT ' + QTDE_REGISTROS;

            System.debug('%%%%%%%%%%%%%%%%%%%%% queri app en LAT '+qString);
            AvailableProducts = database.query(qString);
            // We only display up to X results... if there are more than we let the user know (see vf page)
            if(AvailableProducts.size()==QTDE_REGISTROS){
                AvailableProducts.remove(QTDE_REGISTROS-1);
                overLimit = true;
            }
            else{
                overLimit=false;
            }

            // Carrega os produtos na lista de ProductWrapper
            lstWProducts.clear();
            for (LAT_Account_product_payment__c app : AvailableProducts){
                        
                    string currentKey = app.Account__r.Client_code_AN8__c + app.LAT_Product__r.LAT_Sku__c + app.PaymentCondition__c;
                    if (!selectedEntries.contains(currentKey)) {
                        lstWProducts.add(new productWrapper(app));
                    }

            }           
        //}
    }
    
    // Pega os valores da lista de wrapper
    public List<productWrapper> getlstWProducts () {
      return lstWProducts;
    }
    
    public Pagereference addItensToShoppingCart () {
        /*if(!Utils.wasMigrationDone('6')) {          
            List<Integer> lIndex = new List<Integer>();
            Integer i = 0; 
            Integer lLen = shoppingCart.size();
            //JPC: query para usar como transient el mapa
            List<id> productIds = new List<id>();
            for (productWrapper pw : lstWProducts) {
                productIds.add(pw.app.Product__c);
            }
            
            pricebookEntriesByProduct = new map <id, PricebookEntry>();
            List <PricebookEntry> pbeList = [SELECT Id, Product2Id, Product2.Id, Product2.bottles_per_box__c, Product2.ProductCode FROM PricebookEntry WHERE Product2.LAT_IsRefactorProduct__c = 'Y' AND Product2.IsActive = true AND Pricebook2.isStandard = true AND CurrencyIsoCode =: theOpp.CurrencyIsoCode AND Product2.Id IN: productIds];
            for (PricebookEntry pbe : pbeList) {
                pricebookEntriesByProduct.put(pbe.Product2Id, pbe);
            }
            //JPC: fin de modificaciones para mapa transient
            for (productWrapper pw : lstWProducts) {
                if (pw.isSelected) {
                    if ( lLen == 0 ) { oppAVista = pw.app.PaymentCondition__c == COND_PAGTO_AVISTA; lLen++; }
                 else 
                 if ( ( oppAVista && pw.app.PaymentCondition__c != COND_PAGTO_AVISTA )
                   || ( !oppAVista && pw.app.PaymentCondition__c == COND_PAGTO_AVISTA ) )
                    {
                  AddMsgError(System.Label.VFC11_00001_AR);
                  return null;
                 }

              // Coloca no shoppingCart os itens selecionados
              System.debug('%%%%%%%%%%%%%%%%%%%%% theOpp '+theOpp+', pricebookEntriesByProduct '+ pricebookEntriesByProduct.get(pw.app.Product__c)
                + ' pw '+ pw.app + ' ; ' + pw.isSelected);
              /*OpportunityLineItem newOli = new opportunityLineItem(OpportunityId=theOpp.Id, 
                                                                      PriceBookEntry=pricebookEntriesByProduct.get(pw.app.Product__c), 
                                                                      PriceBookEntryId=pricebookEntriesByProduct.get(pw.app.Product__c).Id, 
                                                                      UnitPrice=0, UOM_AR__c=measurementUnit, MaxDiscount_AR__c = pw.app.PercentualBonus__c, 
                                                                      LAT_PaymentCondition__c = pw.app.PaymentCondition__c, 
                                                                      LAT_PaymentConditionDescription__c = pw.app.PaymentConditionDescription__c, 
                                                                      LAT_SkuText__c = pw.app.Product__r.Sku__c, LAT_UnitCode__c = pw.app.Product__r.cd_unit__c, 
                                                                      BottlesPerBox__c = pw.app.Product__r.bottles_per_box__c, UnitWeight__c = pw.app.Product__r.unit_weight__c, 
                                                                      LAT_MultipleQuantity__c = pw.app.MultipleQuantity__c);
                                                                      */
                /*                                              
                OpportunityLineItem newOli = new opportunityLineItem();
                newOli.OpportunityId=theOpp.Id; 
                newOli.PriceBookEntry=pricebookEntriesByProduct.get(pw.app.Product__c); 
                newOli.PriceBookEntryId=newOli.PriceBookEntry.Id;
                newOli.UnitPrice=0; 
                newOli.UOM_AR__c=measurementUnit; 
                newOli.MaxDiscount_AR__c = pw.app.PercentualBonus__c; 
                newOli.LAT_PaymentCondition__c = pw.app.PaymentCondition__c; 
                newOli.LAT_PaymentConditionDescription__c = pw.app.PaymentConditionDescription__c; 
                newOli.LAT_SkuText__c = pw.app.Product__r.Sku__c; 
                newOli.LAT_UnitCode__c = pw.app.Product__r.cd_unit__c; 
                newOli.BottlesPerBox__c = pw.app.Product__r.bottles_per_box__c; 
                newOli.UnitWeight__c = pw.app.Product__r.unit_weight__c; 
                newOli.LAT_MultipleQuantity__c = pw.app.MultipleQuantity__c;        
              shoppingCart.add(newOli);
              errorMessagesDiscount.put(pw.app.Product__c, '');
              lIndex.add(i);
              OpportunityLineItem proxyOli = new OpportunityLineItem();
              shoppingCartProxies.put(pw.app.Product__c, proxyOli);          
            }
            i++;
          }
          // Percorre inversamente a lista de indices selecionados, para removê-los
          // Está invertido por questão de reordenação da lista ao remover um elemento
          for (Integer j = lIndex.size()-1; j >= 0; j--){
            AvailableProducts.remove(j);
          }
          
          updateAvailableListCheck();
          return null;
        }
        //MIGRATED 8/11/2016
        else {*/
            List<Integer> lIndex = new List<Integer>();
            Integer i = 0; 
            Integer lLen = LAT_shoppingCart.size();
            //JPC: query para usar como transient el mapa
            List<id> productIds = new List<id>();
            for (productWrapper pw : lstWProducts) {
                productIds.add(pw.app.LAT_Product__c);
            }
            
            //JPC: fin de modificaciones para mapa transient
            for (productWrapper pw : lstWProducts) {
                if (pw.isSelected) {
                    if ( lLen == 0 ) { oppAVista = pw.app.PaymentCondition__c == COND_PAGTO_AVISTA; lLen++; }
                 else 
                 if ( ( oppAVista && pw.app.PaymentCondition__c != COND_PAGTO_AVISTA )
                   || ( !oppAVista && pw.app.PaymentCondition__c == COND_PAGTO_AVISTA ) )
                    {
                  AddMsgError(System.Label.VFC11_00001_AR);
                  return null;
                 }

              // Coloca no shoppingCart os itens selecionados
              //System.debug('%%%%%%%%%%%%%%%%%%%%% LAT_theOpp '+LAT_theOpp+', LAT_pricebookEntriesByProduct '+ LAT_pricebookEntriesByProduct.get(pw.app.LAT_Product__c)
                //+ ' pw '+ pw.app + ' ; ' + pw.isSelected);              
                LAT_OpportunityLineItem__c newOli = new LAT_OpportunityLineItem__c(LAT_Opportunity__c=LAT_theOpp.Id,
                                                                      LAT_Opportunity__r = LAT_theOpp,
                                                                      LAT_UnitPrice__c=0, LAT_AR_UOM__c=measurementUnit, 
                                                                      LAT_AR_MaxDiscount__c = pw.app.PercentualBonus__c, 
                                                                      LAT_PaymentCondition__c = pw.app.PaymentCondition__c, 
                                                                      LAT_PaymentConditionDescription__c = pw.app.PaymentConditionDescription__c, 
                                                                      LAT_SkuText__c = pw.app.LAT_Product__r.LAT_Sku__c,
                                                                      LAT_Product__r = pw.app.LAT_Product__r,
                                                                      LAT_Product__c = pw.app.LAT_Product__c, 
                                                                      LAT_UnitCode__c = pw.app.LAT_Product__r.LAT_CDUnit__c, 
                                                                      LAT_BottlesPerBox__c = pw.app.LAT_Product__r.LAT_BottlesPerBox__c, 
                                                                      LAT_UnitWeight__c = pw.app.LAT_Product__r.LAT_UnitWeight__c, 
                                                                      LAT_MultipleQuantity__c = pw.app.MultipleQuantity__c);
              newOli.CurrencyIsoCode = LAT_theOpp.CurrencyIsoCode;
              LAT_shoppingCart.add(newOli);
              errorMessagesDiscount.put(pw.app.LAT_Product__c, '');
              lIndex.add(i);
              LAT_OpportunityLineItem__c proxyOli = newOli;
              LAT_shoppingCartProxies.put(pw.app.LAT_Product__c, proxyOli);          
            }
            i++;
          }
          // Percorre inversamente a lista de indices selecionados, para removê-los
          // Está invertido por questão de reordenação da lista ao remover um elemento
          for (Integer j = lIndex.size()-1; j >= 0; j--){
            AvailableProducts.remove(j);
          }
          
          updateAvailableListCheck();
          return null;            
        //}
    }
    
    public PageReference removeFromShoppingCart(){
        /*if(!Utils.wasMigrationDone('6')) {           
            // This function runs when a user hits "remove" on an item in the "Selected Products" section
            //validate quantity to avoid a full page error
            for(OpportunityLineItem d : shoppingCart){
                if(d.Quantity==null || d.Quantity < 1){
                     AddMsgError(System.Label.VFP11_00028_AR);
                     return null;                
                }
            }
            
            Integer count = 0;
            for(OpportunityLineItem d : shoppingCart){
                if((String)d.PriceBookEntryId==toUnselect){
                    if (IsForDelete(d)) {
                         AddMsgError(d.PriceBookEntry.Product2.Name+ ': ' + System.Label.VFC11_00002_AR);
                         return null;                
                    }
                }
            }
        
            for(OpportunityLineItem d : shoppingCart){
                if((String)d.PriceBookEntryId==toUnselect){               
                    if(d.Id!=null)
                        forDeletion.add(d);
                
                    shoppingCart.remove(count);
                    break;
                }
                
                count++;
            }
            
            updateAvailableListCheck();
            calcularFormulas();
            
            return null;
        }
        //MIGRATED 8/11/2016  
        else {*/
            // This function runs when a user hits "remove" on an item in the "Selected Products" section
            //validate quantity to avoid a full page error
            for(LAT_OpportunityLineItem__c d : LAT_shoppingCart){
                if(d.LAT_Quantity__c==null || d.LAT_Quantity__c < 1){
                     AddMsgError(System.Label.VFP11_00028_AR);
                     return null;                
                }
            }
            
            Integer count = 0;
            System.debug('%%%%%%%%%%%%%%%%%%%  to toUnselect '+toUnselect);
            for(LAT_OpportunityLineItem__c d : LAT_shoppingCart){
                if((String)d.LAT_Product__c==toUnselect){
                    if (IsForDelete(d)) {
                         AddMsgError(d.LAT_Product__r.Name+ ': ' + System.Label.VFC11_00002_AR);
                         return null;                
                    }
                }
            }    
            for(LAT_OpportunityLineItem__c d : LAT_shoppingCart){
                if((String)d.LAT_Product__c==toUnselect){               
                    if(d.Id!=null)
                        LAT_forDeletion.add(d);
                
                    LAT_shoppingCart.remove(count);
                    break;
                }
                
                count++;
            }
            
            updateAvailableListCheck();
            calcularFormulas();
            
            return null;            
        //}
    }
    
    public PageReference onSaveRefresh(){
        /*if(!Utils.wasMigrationDone('6')) { 
            for (OpportunityLineItem oli : shoppingCart) {
                if (oli.Quantity <= 0) {
                    AddMsgError(System.Label.VFC11_00003_AR);
                    return null;
                }
            }
            
            configTotalPrice();
            PageReference pr = internalSave( true );
            if(pr==null){calcularFormulas();}
            return pr;
        }
        //MIGRATED 8/11/2016
        else {*/
            for (LAT_OpportunityLineItem__c oli : LAT_shoppingCart) {
                if (oli.LAT_Quantity__c <= 0) {
                    AddMsgError(System.Label.VFC11_00003_AR);
                    return null;
                }
            }
            
            configTotalPrice();
            PageReference pr = internalSave( true );
            if(pr==null){calcularFormulas();}
            return pr;           
        //}
    }
    
    public PageReference onSave(){
        /*if(!Utils.wasMigrationDone('6')) {         
            for (OpportunityLineItem oli : shoppingCart) {
                if(oli.Discount_AR__c < 0 || oli.Discount_AR__c > 100){
                    AddMsgError(System.Label.LAT_AR_VFP11_00029);
                    return null;
                }
            }
            configTotalPrice();
            PageReference pr = internalSave( false );
            if(pr==null){calcularFormulas();}
            return pr;
        }
        //MIGRATED 8/11/2016 
        else {*/
            for (LAT_OpportunityLineItem__c oli : LAT_shoppingCart) {
                if(oli.LAT_AR_Discount__c < 0 || oli.LAT_AR_Discount__c > 100){
                    AddMsgError(System.Label.LAT_AR_VFP11_00029);
                    return null;
                }
            }
            configTotalPrice();
            PageReference pr = internalSave( false );
            if(pr==null){calcularFormulas();}
            return pr;           
        //}
    }
    
    private PageReference internalSave( boolean aRefresh ){
        /*if(!Utils.wasMigrationDone('6')) {    
            //validate quantity here to avoid an ugly default error message
            for (OpportunityLineItem oli : shoppingCart) {
                if (oli.Quantity <= 0) {
                    AddMsgError(System.Label.VFC11_00003_AR);
                    return null;
                }
            }
        
            //validate canceled items without sending to JDE
            if (theOpp.NR_order_JDE__c == null) {
                for (OpportunityLineItem oli : shoppingCart) {
                    if (oli.Remover__c) {
                        AddMsgError(System.Label.VFC11_00004_AR);
                        return null;
                    }
                }
            } else { //validate status for canceled items, only items with status smaller or equal to 540 can be canceled
                for (OpportunityLineItem oli : shoppingCart) {
                    if (wasProductCanceled.get(oli.Id) != null && wasProductCanceled.get(oli.Id) != oli.Remover__c && oli.Remover__c) {
                        try {
                            integer intStatus = Integer.valueOf(oli.cd_line_status__c);
                            if (intStatus > 540) {
                                AddMsgError(System.Label.VFP11_00027_AR);
                                return null;
                            }
                        } catch (Exception e) {
                            AddMsgError(System.Label.VFP11_00027_AR); //status is not a number, most probably is empty
                            return null;
                        }
                    }
                 }
            }
            //validate max discount
            boolean discountError = false;
            for (OpportunityLineItem oli : shoppingCart) {
                //decode JDE discount if available
                decimal jdeDiscount = 0;
                if (oli.Campo_de_formatacao__c != null && oli.Campo_de_formatacao__c != '') {
                    Pattern myPattern = Pattern.compile('(?<=>.?Bonificaci.?.?n.?.?</td>).*?</td>');
                    Matcher myMatcher = myPattern.matcher(oli.Campo_de_formatacao__c);
                    string htmlFiltrado = '';
                    if (myMatcher.find()) {
                        htmlFiltrado = myMatcher.group();
                    }
                    htmlFiltrado = htmlFiltrado.replaceAll('<.*?>','');
                    if (htmlFiltrado != '') {
                        jdeDiscount = Decimal.valueOf(htmlFiltrado.replace('.', '').replace(',','.').trim());
                    }
                }
                if (oli.Discount_AR__c == null) {
                    oli.Discount_AR__c = 0;
                }
                if (!oli.SenttoApproveDiscount_AR__c && oli.MaxDiscount_AR__c != null && oli.MaxDiscount_AR__c < (oli.Discount_AR__c + jdeDiscount.abs()) ) {
                    errorMessagesDiscount.put(oli.PriceBookEntry.Product2.Id, System.Label.VFC11_00006_AR);
                    discountError = true;
                }
            }
            if (discountError) {
                AddMsgError(System.Label.VFC11_00007_AR);
                return null;
            }
            
            // If previously selected products are now removed, we need to delete them
            if(forDeletion.size()>0)
            {
                List<OpportunityLineItem> olisToDelete = [SELECT Id FROM OpportunityLineItem WHERE Id IN: forDeletion];
                delete(olisToDelete);
                if ( aRefresh ) forDeletion = new opportunityLineItem[]{};
            }
                    
            // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
            Savepoint sp = Database.setSavepoint();
            List<OpportunityLineItem> ShoppingCartAux = shoppingCart.deepClone(true);
            List<DataBase.UpsertResult> results = DataBase.upsert(shoppingCart, false);
            Boolean isError = false;
            for(DataBase.UpsertResult result: results){
                if(!result.isSuccess()){
                    isError = true;
                    for(Database.Error error: result.getErrors()){
                        if(error.getMessage().contains('duplicate value found')){
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, Label.LAT_AR_VFP11_00028));
                        }else{
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, error.getMessage()));
                        }
                    }
                }
            }
            if(isError){
                shoppingCart = ShoppingCartAux;
                Database.rollback(sp);
                return null;
            }
            
            // After save return the user to the Opportunity
            if ( aRefresh )
            {
                loadShoppingCart();
              erroSave = '';
              return null;
            }
            else return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
        }
        //MIGRATED 8/11/2016 
        else {*/
            //validate quantity here to avoid an ugly default error message
            Boolean hayErrorStock = false;
            for (LAT_OpportunityLineItem__c oli : LAT_shoppingCart) {
                if (oli.LAT_Quantity__c <= 0) {
                    AddMsgError(System.Label.VFC11_00003_AR);
                    return null;
                }
                if (checkStockValues) {
                    if (oli.LAT_Quantity__c > Decimal.valueOf(stockByProductId.get(oli.LAT_Product__c))) {
                        errorMessagesDiscount.put(oli.LAT_Product__r.Id, 'Stock Insuficiente.');
                        hayErrorStock = true;
                    }
                }
                
            }
            //validate canceled items without sending to JDE
            if (LAT_theOpp.LAT_NROrderJDE__c == null) {
                for (LAT_OpportunityLineItem__c oli : LAT_shoppingCart) {
                    if (oli.LAT_Remover__c) {
                        AddMsgError(System.Label.VFC11_00004_AR);
                        return null;
                    }
                }
            } else { //validate status for canceled items, only items with status smaller or equal to 540 can be canceled
                for (LAT_OpportunityLineItem__c oli : LAT_shoppingCart) {
                    if (wasProductCanceled.get(oli.Id) != null && wasProductCanceled.get(oli.Id) != oli.LAT_Remover__c && oli.LAT_Remover__c) {
                        try {
                            integer intStatus = Integer.valueOf(oli.LAT_CdLineStatus__c);
                            if (intStatus > 540) {
                                AddMsgError(System.Label.VFP11_00027_AR);
                                return null;
                            }
                        } catch (Exception e) {
                            AddMsgError(System.Label.VFP11_00027_AR); //status is not a number, most probably is empty
                            return null;
                        }
                    }
                 }
            }
            //validate max discount
            boolean discountError = false;
            for (LAT_OpportunityLineItem__c oli : LAT_shoppingCart) {
                decimal jdeDiscount = 0;
                String country = 'Argentina';
                if (LAT_theOpp.LAT_Account__r.Client_country_an8__c.startsWith('5-')) {
                    country = 'Uruguay';
                }
                //Hago la consulta de si estoy en el price calculation viejo o nuevo.
                if (WS04_PriceCalculationInterface_AR.isNewPriceCalculation(country)) {
                    System.debug('%%%%%%%%%%% oli.LAT_JDETotalDiscount__c : '+ oli.LAT_JDETotalDiscount__c + ' || oli.LAT_AR_MaxDiscount__c : '+ oli.LAT_AR_MaxDiscount__c);
                    //NEW
                    if (oli.LAT_JDETotalDiscount__c != null) {
                        jdeDiscount = oli.LAT_JDETotalDiscount__c;
                    }
                    if (oli.LAT_AR_Discount__c == null) {
                        oli.LAT_AR_Discount__c = 0;
                    }
                    if (!oli.LAT_AR_SentToApproveDiscount__c && oli.LAT_AR_MaxDiscount__c != null && oli.LAT_AR_MaxDiscount__c < oli.LAT_AR_Discount__c ) {
                        errorMessagesDiscount.put(oli.LAT_Product__r.Id, System.Label.VFC11_00006_AR);
                        discountError = true;
                    }
                
                } else {
                    //OLD  
                    //decode JDE discount if available
                    if (oli.LAT_FormatField__c != null && oli.LAT_FormatField__c != '') {
                        Pattern myPattern = Pattern.compile('(?<=>.?Bonificaci.?.?n.?.?</td>).*?</td>');
                        Matcher myMatcher = myPattern.matcher(oli.LAT_FormatField__c);
                        string htmlFiltrado = '';
                        if (myMatcher.find()) {
                            htmlFiltrado = myMatcher.group();
                        }
                        htmlFiltrado = htmlFiltrado.replaceAll('<.*?>','');
                        if (htmlFiltrado != '') {
                            jdeDiscount = Decimal.valueOf(htmlFiltrado.replace('.', '').replace(',','.').trim());
                        }
                    }
                    if (oli.LAT_AR_Discount__c == null) {
                        oli.LAT_AR_Discount__c = 0;
                    }
                    if (!oli.LAT_AR_SentToApproveDiscount__c && oli.LAT_AR_MaxDiscount__c != null && oli.LAT_AR_MaxDiscount__c < oli.LAT_AR_Discount__c  ) {
                        errorMessagesDiscount.put(oli.LAT_Product__r.Id, System.Label.VFC11_00006_AR);
                        discountError = true;
                    }
                }
            }
            if (discountError || hayErrorStock) {
                String errorMsg = '';
                if (discountError) {
                    errorMsg = System.Label.VFC11_00007_AR;
                }
                if (hayErrorStock) {
                    if (discountError) errorMsg += '<br>';
                    errorMsg += 'Hay productos para los que el stock en JDE no es suficiente para surtir el pedido.';
                }
                AddMsgError(errorMsg);
                return null;
            }
            
            // If previously selected products are now removed, we need to delete them
            if(LAT_forDeletion.size()>0)
            {
                List<LAT_OpportunityLineItem__c> olisToDelete = [SELECT Id FROM LAT_OpportunityLineItem__c WHERE Id IN: LAT_forDeletion];
                delete(olisToDelete);
                if ( aRefresh ) LAT_forDeletion = new LAT_OpportunityLineItem__c[]{};
            }
                    
            // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
            Savepoint sp = Database.setSavepoint();
            List<LAT_OpportunityLineItem__c> ShoppingCartAux = LAT_shoppingCart.deepClone(true);
            List<DataBase.UpsertResult> results = DataBase.upsert(LAT_shoppingCart, false);
            Boolean isError = false;
            for(DataBase.UpsertResult result: results){
                if(!result.isSuccess()){
                    isError = true;
                    for(Database.Error error: result.getErrors()){
                        if(error.getMessage().contains('duplicate value found')){
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, Label.LAT_AR_VFP11_00028));
                        }else{
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, error.getMessage()));
                        }
                    }
                }
            }
            if(isError){
                LAT_shoppingCart = ShoppingCartAux;
                Database.rollback(sp);
                return null;
            }
            
            // After save return the user to the Opportunity
            if ( aRefresh )
            {
              loadShoppingCart();
              erroSave = '';
              return null;
            }
            else return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));            
        //}
    }
    
    public PageReference onCancel(){
        // If user hits cancel we commit no changes and return them to the Opportunity   
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    public PageReference changePricebook(){
        // This simply returns a PageReference to the standard Pricebook selection screen
        // Note that is uses retURL parameter to make sure the user is sent back after they choose
        /*if(!Utils.wasMigrationDone('6')) {  
            PageReference ref = new PageReference('/oppitm/choosepricebook.jsp');
            ref.getParameters().put('id',theOpp.Id);
            ref.getParameters().put('retURL','/apex/opportunityProductEntry?id=' + theOpp.Id);
            
            return ref;
        }
        //MIGRATED 15/11/2016
        else {*/
            return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
        //}
    }
    
    public PageReference showCampoFormatado()
    {
        /*if(!Utils.wasMigrationDone('6')) { 
            PageReference pf = new PageReference('/apex/VisualizaComposicaoPrecoOppLineItem?id=' + shoppingCart[0].Id);
            pf.setRedirect(true);
            
            return pf; 
        } 
        //MIGRATED 15/11/2016
        else {*/
            PageReference pf = new PageReference('/apex/LAT_VisualizaComposicaoPrecoOppLineItem?id=' + LAT_shoppingCart[0].Id);
            pf.setRedirect(true);
            
            return pf; 
        //}
    }
    public void AddMsgError(String aMsg){
        ApexPages.addMessage(new ApexPages.Message( ApexPages.severity.ERROR,aMsg));
    }
    
    public Pagereference calculaPrecios2() {
        //WS04_PriceCalculationInterface_AR.PriceCalculation2(theOpp.Id, shoppingCart);
        //calcularFormulas();
        return null;
    }

    //MIGRATED 24/11/2016
    public Pagereference LAT_calculaPrecios2() {
        ApexPages.getMessages().clear();
        String result = WS04_PriceCalculationInterface_AR.LAT_PriceCalculation2(LAT_theOpp.Id, LAT_ShoppingCart);
        calcularFormulas();
        if (result != '' && result !=null) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, 'Error encontrado en JDE al calcular el Precio : ' + result));
        }
        return null;
    }
    
    private void calcularFormulas(){
        /*if(!Utils.wasMigrationDone('6')) { 
            if(ShoppingCart.isEmpty()){return;}
            
            //Guardo los olis nuevos
            set<Id> olisNew = new set<Id>();
            set<Id> oliIds = new set<Id>();
            for(OpportunityLineItem oli : ShoppingCart){
                if(oli.Id==null){
                    olisNew.add(oli.PriceBookEntryId);
                }else{
                    oliIds.add(oli.Id);
                }
            }
            configTotalPrice();
            
            //Guardo como quedarian los valores de la oportunidad con los productos actuales
            Savepoint sp = Database.setSavepoint();
            try {
                delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: theOpp.Id AND Id NOT IN: oliIds];
                database.upsert(ShoppingCart, OpportunityLineItem.Fields.Id, false);
                init();
            } catch (Exception e) {
                
            }
            Database.rollback(sp);
            
            //Borro el id de los productos que son nuevos y actualizo el proxy
            shoppingCartProxies.clear();
            for (OpportunityLineItem oli : ShoppingCart) {
                if(olisNew.contains(oli.PriceBookEntryId)){
                    oli.Id = null;
                    oli.opportunityId = theOpp.Id;
                }
                OpportunityLineItem proxyOli = new OpportunityLineItem();
                proxyOli.Campo_de_formatacao__c = oli.Campo_de_formatacao__c;
                shoppingCartProxies.put(oli.PriceBookEntry.Product2Id, proxyOli);
            }
        }
        //MIGRATED 8/11/2016
        else {*/
            if(LAT_ShoppingCart.isEmpty()){return;}
            
            //Guardo los olis nuevos
            set<Id> olisNew = new set<Id>();
            set<Id> oliIds = new set<Id>();
            for(LAT_OpportunityLineItem__c oli : LAT_ShoppingCart){
                if(oli.Id==null){
                    olisNew.add(oli.LAT_Product__c);
                }else{
                    oliIds.add(oli.Id);
                }
            }
            configTotalPrice();
            
            //Guardo como quedarian los valores de la oportunidad con los productos actuales
            Savepoint sp = Database.setSavepoint();
            try {
                delete [SELECT Id FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: LAT_theOpp.Id AND Id NOT IN: oliIds];
                database.upsert(LAT_ShoppingCart, LAT_OpportunityLineItem__c.Fields.Id, false);
                init();
            } catch (Exception e) {
                System.debug('%%%%%%% error en savepoint');
            }
            Database.rollback(sp);

            System.debug('%%%%%%%%%%%%% LAT_ShoppingCart antes: '+LAT_ShoppingCart);
            
            //Borro el id de los productos que son nuevos y actualizo el proxy
            LAT_shoppingCartProxies.clear();
            for (LAT_OpportunityLineItem__c oli : LAT_ShoppingCart) {
                if(olisNew.contains(oli.LAT_Product__c)){
                    oli.Id = null;
                    oli.LAT_Opportunity__c = LAT_theOpp.Id;
                }
                LAT_OpportunityLineItem__c proxyOli = oli;
                proxyOli.LAT_FormatField__c = oli.LAT_FormatField__c;
                LAT_shoppingCartProxies.put(oli.LAT_Product__c, proxyOli);
            }            
        //}
    }
    
    private void configTotalPrice(){
        /*if(!Utils.wasMigrationDone('6')) {         
            for(OpportunityLineItem oli : ShoppingCart){
                if(oli.Id==null){
                    oli.totalPrice = null;
                }else{
                    if(shoppingCartOriginal.containsKey(oli.Id)){
                        oli.TotalPrice = shoppingCartOriginal.get(oli.Id).TotalPrice;
                    } 
                }
            }
        }
        //MIGRATED 8/11/2016
        else {*/
            for(LAT_OpportunityLineItem__c oli : LAT_ShoppingCart){
                if(oli.Id==null){
                    System.debug('%%%%%%%%%% oli.Id = null');
                    //oli.LAT_UnitPrice__c = null;
                }else{
                    if(LAT_shoppingCartOriginal.containsKey(oli.Id)){
                        oli.LAT_UnitPrice__c = LAT_shoppingCartOriginal.get(oli.Id).LAT_UnitPrice__c;
                        oli.LAT_Quantity__c = LAT_shoppingCartOriginal.get(oli.Id).LAT_Quantity__c;

                    } 
                }
            }
        //}
    }

    public PageReference doCheckAvailability (){
        String response = LAT_StockAvailabilityInterface.stockAvailibity(LAT_shoppingCart,LAT_theOpp.Id);

        if(response != ''){
            addMsgError(response);
        }else{
            loadProductsMap();
            //mapIdPBEProductWrapper.clear();
            //loadShoppingCart();
            //calcularFormulas();
        }
        
        return null;            
    }
    

    
}