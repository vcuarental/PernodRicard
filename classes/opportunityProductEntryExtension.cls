/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe controladora da pagina opportunityProductEntry, onde o usuário pode 
* adicionar varios itens em um 'carrinho de compras' antes de efetivar a compra
* NAME: opportunityProductEntryExtension.cls
* AUTHOR:                                           DATE: 
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: MARCOS DOBROWOLSKI                        DATE: 18/12/2012
* DESC: Possibilidade de selecionar mais de um item
*
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
*
* AUTHOR: ROGERIO ALVARENGA                         DATE: 11/01/2013
* DESC: Otimização de consultas
*******************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/
public with sharing class opportunityProductEntryExtension {
    
    public String searchString {get;set;}
    public opportunityLineItem[] shoppingCart {get;set;}  
    public Pricebook2 theBook {get;set;}
    public String idOppOli {get; set;}
    public String toUnselect {get; set;} 
    public Boolean overLimit {get;set;}
    public Boolean multipleCurrencies {get; set;} 
    public boolean displayPopup {get; set;}
    public PageReference PaymentValues {get;set;}
    public List<OpportunityLineItem> itemOpp{get; private set;}
    public String erroSave {get; set;}
    public boolean isStandardPricebook {get;set;}
    public List<productWrapper> lstWProducts {get; set;}

    //VARIABLES MIGRACION LICENCIAS
    public LAT_OpportunityLineItem__c[] LAT_shoppingCart {get;set;}  
    public LAT_Product__c LAT_theBook {get;set;}
    public List<LAT_OpportunityLineItem__c> LAT_itemOpp{get; private set;}
    private LAT_Opportunity__c LAT_theOpp;
    private transient map <id, LAT_Product__c> LAT_pricebookEntriesByProduct;
    private LAT_Product__c LAT_stdPriceBook; 
    private Id LAT_idRecTypeProd = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
    private LAT_OpportunityLineItem__c[] LAT_forDeletion = new LAT_OpportunityLineItem__c[]{};

    //Classe para ter os produtos selecionados
    public class productWrapper {
        public Boolean isSelected {get; set;}
        public LAT_Account_product_payment__c app {get; set;} 
        //Construtor com o objeto dentro
        public productWrapper (LAT_Account_product_payment__c appParam) {
            app = appParam;
            isSelected = false;
        }
    }
    
    private Opportunity theOpp;
    private List<LAT_Account_product_payment__c> AvailableProducts;
    private transient map <id, PricebookEntry> pricebookEntriesByProduct; //Product id, pricebook entry
    
    Datetime d;
    private static final Integer QTDE_REGISTROS = 101;
    private static final String COND_PAGTO_AVISTA = 'V00';
    private Account accountData;
    private Pricebook2 stdPriceBook;
    private String idAccount;
    private String varCondicaoDefault;
    private String grupoPreco;
    private Boolean forcePricebookSelection = false;
    private boolean oppAVista = false;
    private Id idRecTypeProd = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
    private opportunityLineItem[] forDeletion = new opportunityLineItem[]{};
    
    private  Boolean IsForDelete(OpportunityLineItem item){
        return item.cd_line_status__c!=null && item.cd_line_status__c.trim()!='';
    }
    //MIGRATED 07/11/2016
    private  Boolean IsForDelete(LAT_OpportunityLineItem__c item){
        return item.LAT_CdLineStatus__c!=null && item.LAT_CdLineStatus__c.trim()!='';
    }
    
    //CONSTRUCTOR
    public opportunityProductEntryExtension(ApexPages.StandardController controller) {
        if(!Utils.wasMigrationDone('1')) {
            // Instancia a lista de objetos Wrapper
            lstWProducts = new List<productWrapper>();
            isStandardPricebook = true;
            // Need to know if org has multiple currencies enabled
            erroSave = 'SEM ERRO';
            multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
           
            // Get information about the Opportunity being worked on
            theOpp = [SELECT Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode, Grupo_de_precos__c, Campo_de_formatacao__c, AccountId, Account.Payment_Condition__c, Account.Price_Group__c FROM Opportunity WHERE Id =: controller.getRecord().Id];

            pricebookEntriesByProduct = new map <id, PricebookEntry>();
            List <PricebookEntry> pbeList = [SELECT Id, Product2Id, Product2.Id, Product2.bottles_per_box__c, Product2.ProductCode FROM PricebookEntry WHERE Product2.LAT_IsRefactorProduct__c = 'Y' AND Product2.IsActive = true AND Pricebook2.isStandard = true AND CurrencyIsoCode =: theOpp.CurrencyIsoCode];
            for (PricebookEntry pbe : pbeList) {
                pricebookEntriesByProduct.put(pbe.Product2Id, pbe);
            }
            
            //If products were previously selected need to put them in the "selected products" section to start with
            loadShoppingCart();
             
            idAccount = theOpp.AccountId;
            accountData = [SELECT Id, Client_code_AN8__c FROM Account WHERE Id =: idAccount];
            varCondicaoDefault = Utils.getCodeFromUDC(theOpp.Account.Payment_Condition__c);
            grupoPreco = theOpp.Account.Price_Group__c;
            
            try {stdPriceBook = [SELECT Id,Name FROM Pricebook2 WHERE isActive = true AND isStandard = true];} catch (Exception e) {}
            
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
                
            }else{
                Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, 'O pedido deve ser recriado.'));
                isStandardPricebook = false;
                return;
            
            }
        }
        //MIGRATED 07/11/2016
        else {
            // Instancia a lista de objetos Wrapper
            lstWProducts = new List<productWrapper>();
            isStandardPricebook = true;
            // Need to know if org has multiple currencies enabled
            erroSave = 'SEM ERRO';
            multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
           
            // Get information about the Opportunity being worked on
            LAT_theOpp = [SELECT Id, CurrencyIsoCode, LAT_AccountPriceBook__c, LAT_FormatField__c, LAT_Account__c, LAT_Account__r.Payment_Condition__c, LAT_Account__r.Price_Group__c, LAT_Account__r.Client_code_AN8__c, 
                        LAT_DTDelivery__c, LAT_NROrderJDE__c, LAT_Country__c, LAT_Freight__c, LAT_Account__r.Business_Unit__c, LAT_Type__c, LAT_JDEIntegrationReturn__c FROM LAT_Opportunity__c WHERE Id =: controller.getRecord().Id];
            LAT_pricebookEntriesByProduct = new map <id, LAT_Product__c>();
            List <LAT_Product__c> pbeList = [SELECT Id, Name, LAT_BottlesPerPallet__c, LAT_ProductCode__c FROM LAT_Product__c WHERE LAT_IsRefactorProduct__c = 'Y' AND LAT_IsActive__c = true AND CurrencyIsoCode =: LAT_theOpp.CurrencyIsoCode];
            for (LAT_Product__c pbe : pbeList) {
                LAT_pricebookEntriesByProduct.put(pbe.Id, pbe);
            }
            
            //If products were previously selected need to put them in the "selected products" section to start with
            loadShoppingCart();
             
            idAccount = LAT_theOpp.LAT_Account__c;
            accountData = [SELECT Id, Client_code_AN8__c FROM Account WHERE Id =: idAccount];
            varCondicaoDefault = Utils.getCodeFromUDC(LAT_theOpp.LAT_Account__r.Payment_Condition__c);
            grupoPreco = LAT_theOpp.LAT_Account__r.Price_Group__c;
                          
            updateAvailableListCheck();
            return;         
                        
        }
    }
    
    private void loadShoppingCart(){
        //JPC: query changed to use new non formula fields
        //PC_Bonus__c --> LAT_PercentualBonus__c
        //cd_payment_term__c --> PaymentCondition__c
        //ds_payment_term__c --> PaymentConditionDescription__c
        //QT_multiple__c --> LAT_MultipleQuantity__c
        //Sku__c --> SkuText__c
        //CD_unit__c --> UnitCode__c
        //bottles_per_box__c -- BottlesPerBox__c
        //unit_weight__c --> UnitWeight__c
        if(!Utils.wasMigrationDone('1')) {  
            shoppingCart = [ SELECT Id, Remover__c, cd_line_status__c, Percentual_de_bonus__c, 
                LAT_MultipleQuantity__c, LAT_PaymentConditionDescription__c, Campo_de_formatacao__c, NR_order_line__c, LAT_SkuText__c, 
                LAT_PaymentCondition__c, LAT_UnitCode__c, qt_bonus__c, LAT_PercentualBonus__c, pc_discount__c, Quantity, 
                TotalPrice, Preco_total__c, preco_garrafa__c, UnitPrice, Description, PriceBookEntryId, 
                PriceBookEntry.Name, PriceBookEntry.IsActive, PriceBookEntry.Product2Id, 
                PriceBookEntry.Product2.Name, PriceBookEntry.PriceBook2Id, PriceBookEntry.Product2.Sku__c, 
                UnitWeight__c, BottlesPerBox__c, 
                PriceBookEntry.UnitPrice, qt_total__c, Descricao_do_status__c
                FROM OpportunityLineItem WHERE OpportunityId =: theOpp.Id ];
                
            if ( shoppingCart.size() > 0 ) oppAVista = shoppingCart[ 0 ].LAT_PaymentCondition__c == COND_PAGTO_AVISTA;
            
            for(opportunityLineItem itemLine : shoppingCart){
                if ((itemLine.Quantity==null) || (itemLine.Quantity==0)){
                    itemLine.Quantity = 1;
                }
            }
        }
        //MIGRATED 07/11/2016
        else {
            LAT_shoppingCart = [ SELECT Id, LAT_Remover__c, LAT_CdLineStatus__c, LAT_PercentualOfBonus__c, 
                LAT_MultipleQuantity__c, LAT_PaymentConditionDescription__c, LAT_FormatField__c, LAT_NROrderLine__c, LAT_SkuText__c, 
                LAT_PaymentCondition__c, LAT_UnitCode__c, LAT_QTBonus__c, LAT_PercentualBonus__c, LAT_PcDiscount__c, LAT_Quantity__c, 
                LAT_TotalPrice__c, LAT_PriceTotal__c, LAT_BottlePrice__c, LAT_UnitPrice__c, LAT_Description__c, 
                LAT_Product__c, LAT_UnitWeight__c,
                LAT_Product__r.Name,  LAT_Product__r.LAT_Sku__c, 
                LAT_Unit_Weight__c, LAT_BottlesPerBox__c, 
                LAT_QTTotal__c, LAT_StatusDescription__c, LAT_Pallet_Total_Quantity__c, LAT_FreightPercent__c, LAT_Discount__c
                FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: LAT_theOpp.Id ];
                
            if ( LAT_shoppingCart.size() > 0 ) oppAVista = LAT_shoppingCart[ 0 ].LAT_PaymentCondition__c == COND_PAGTO_AVISTA;
            
            for(LAT_OpportunityLineItem__c itemLine : LAT_shoppingCart){
                if ((itemLine.LAT_Quantity__c==null) || (itemLine.LAT_Quantity__c==0)){
                    itemLine.LAT_Quantity__c = 1;
                }
            }            
        }
    }

    public String varPaymentVal {
        get{
            if(varPaymentVal == null){
                varPaymentVal = varCondicaoDefault;
            }
            return varPaymentVal;
        }
        set;
    }

    //Aciona a atualização dos itens da condição de pagamento.
    public PageReference paymentValues() {
        updateAvailableListCheck();
        return null;
    }

    //Preenche a variavel do popup.  
    public void getItemX(){  
        if(!Utils.wasMigrationDone('1')) {
            itemOpp= [Select Id, Campo_de_formatacao__c from OpportunityLineItem where Id=:idOppOli   limit 1];
        }
        //MIGRATED 07/11/2016
        else {
            LAT_itemOpp= [Select Id, LAT_FormatField__c from LAT_OpportunityLineItem__c where Id=:idOppOli   limit 1];
        }
    }  
    
    //Fecha o popup.
    public void closePopup(){
        displayPopup = false;
    }
    
    //Abre o popup.
    public void showPopup() {
        getItemX();
        displayPopup = true;
    }
    
    public void initAction(){
        if(!Utils.wasMigrationDone('1')) {        
            if (thebook != stdPriceBook) {
                List<PricebookEntry> lstPbeInsert = new List<PricebookEntry>();
                for (PricebookEntry pbe : pricebookEntriesByProduct.values()) {
                    PricebookEntry pbeStd = new PricebookEntry();
                    pbeStd.CurrencyIsoCode = theOpp.CurrencyIsoCode;
                    pbeStd.IsActive = true;
                    pbeStd.Pricebook2Id = theBook.Id;
                    pbeStd.Product2Id = pbe.Product2Id;
                    pbeStd.UnitPrice = 0;
                    lstPbeInsert.add(pbeStd);
                }
                try {
                    Database.upsert(lstPbeInsert, false);
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
        //MIGRATED 07/11/2016
        else {
 
            updateAvailableListCheck();

            List<LAT_Product__c> updatedPBE = [SELECT Id, LAT_BottlesPerBox__c, LAT_ProductCode__c FROM LAT_Product__c WHERE LAT_IsRefactorProduct__c = 'Y'];
            for (LAT_Product__c pbe : updatedPBE) {
                if (pbe.Id != null) {
                    LAT_pricebookEntriesByProduct.put(pbe.id, pbe);
                }
            }    
        }
    }
    
    //JPC: method modified to use the new product schema
    public List<Selectoption> getCondicao(){
        if(!Utils.wasMigrationDone('1')) { 
            //Declaração de variaveis.                       
            List<Selectoption> options = new List<Selectoption>();
            List<Product2> listcondicao = new List<Product2>();
            Set<String> setCodPagamento = new Set<String>();
            
            //Instância Lista de Selectoptions.
            options = new List<Selectoption>();
            options.add(new SelectOption('Todas','Todas'));
            
            //Recupera as condições de pagamentos disponiveis para o cliente, 
            //utilizando o grupo de preço cadastrado no cliente.
            List<AggregateResult> groupedResults = [SELECT PaymentCondition__c, PaymentConditionDescription__c 
                                                    FROM LAT_Account_product_payment__c
                                                    WHERE Account__c =: idAccount
                                                    GROUP BY PaymentCondition__c, PaymentConditionDescription__c
                                                    ORDER BY PaymentConditionDescription__c];
            
            for(AggregateResult ar : groupedResults){
                if(ar.get('PaymentCondition__c') != null && ar.get('PaymentConditionDescription__c') != null){
                    options.add(new SelectOption(String.valueOf(ar.get('PaymentCondition__c')), String.valueOf(ar.get('PaymentConditionDescription__c'))));
                }
            }
            return options;
        } 
        //MIGRATED 07/11/2016
        else {
            //Declaração de variaveis.                       
            List<Selectoption> options = new List<Selectoption>();
            List<LAT_Product__c> listcondicao = new List<LAT_Product__c>();
            Set<String> setCodPagamento = new Set<String>();
            
            //Instância Lista de Selectoptions.
            options = new List<Selectoption>();
            options.add(new SelectOption('Todas','Todas'));
            
            //Recupera as condições de pagamentos disponiveis para o cliente, 
            //utilizando o grupo de preço cadastrado no cliente.
            List<AggregateResult> groupedResults = [SELECT PaymentCondition__c, PaymentConditionDescription__c 
                                                    FROM LAT_Account_product_payment__c
                                                    WHERE Account__c =: idAccount
                                                    GROUP BY PaymentCondition__c, PaymentConditionDescription__c
                                                    ORDER BY PaymentConditionDescription__c];
            
            for(AggregateResult ar : groupedResults){
                if(ar.get('PaymentCondition__c') != null && ar.get('PaymentConditionDescription__c') != null){
                    options.add(new SelectOption(String.valueOf(ar.get('PaymentCondition__c')), String.valueOf(ar.get('PaymentConditionDescription__c'))));
                }
            }
            return options;            
        }  
    }
    
    // this is the 'action' method on the page
    public PageReference priceBookCheck(){
        if(!Utils.wasMigrationDone('1')) {         
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
        }
        //MIGRATED 07/11/2016
        else {
            try{
                update(LAT_theOpp);
                }
                catch(Exception e){
                        ApexPages.addMessages(e);
                }
                
            return null;
                        
        }
    }
       
    public String getChosenCurrency(){
        if(!Utils.wasMigrationDone('1')) {
            if(multipleCurrencies)
                return (String)theOpp.get('CurrencyIsoCode');
            else
                return '';
        }
        //MIGRATED 07/11/2016
        else {
            if(multipleCurrencies)
                return (String)LAT_theOpp.get('CurrencyIsoCode');
            else
                return '';            
        }
    } 
    
    //Atualiza lista de produtos disponíveis.
    //JPC: method modified to use the new product schema, available products now are queried from LAT_Account_product_payment__c
    public void updateAvailableListCheck() {
        if(!Utils.wasMigrationDone('1')) {
            // We dynamically build a query string and exclude items already in the shopping cart
            String qString = 'SELECT Id, Product__c, Product__r.LAT_IsRefactorProduct__c, PaymentCondition__c, PaymentConditionDescription__c, Product__r.Sku__c, MultipleQuantity__c, Product__r.unit_weight__c, Product__r.bottles_per_box__c, Product__r.cd_unit__c, PercentualBonus__c, Product__r.Name, Product__r.Family, Product__r.IsActive, Product__r.Description, Product__r.ProductCode, Account__r.Client_code_AN8__c FROM LAT_Account_product_payment__c WHERE Account__c =: idAccount AND Product__r.IsActive = true';
            
            // note that we are looking for the search string entered by the user in the name OR description
            // modify this to search other fields if desired
            if(searchString != null){
                qString+= ' AND (Product__r.Name like \'%' + searchString + '%\' or Product__r.Description like \'%' + searchString + '%\')';
            }
            if(varPaymentVal != 'Todas'){
                qString += ' AND PaymentCondition__c like \'%' + varPaymentVal+ '%\'';
            }
            
            Set<string> selectedEntries = new Set<string>();
            for(opportunityLineItem d:shoppingCart){
                if(d.Remover__c == false) {
                    selectedEntries.add(accountData.Client_code_AN8__c + d.LAT_SkuText__c + d.LAT_PaymentCondition__c);
                }
            }
            
            qString+= ' order by Product__r.Name';
            qString+= ' limit ' + QTDE_REGISTROS;
            
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
        //MIGRATED 07/11/2016
        else {
            //String searchQuery = 'FIND \'' + searchString +'\' IN ALL FIELDS RETURNING LAT_Product__c(LAT_Description__c,id)';
            List<String> productFindedByDescription = new List<String>();
            if(searchString!= null&&searchString!='' && searchString.length() >= 2){
                String auxSearch = searchString+'*';
                List<LAT_Product__c> prodsWithSearchStringInDescription = new List<LAT_Product__c>();
                prodsWithSearchStringInDescription =  (List<LAT_Product__c>)[FIND :auxSearch IN ALL FIELDS RETURNING LAT_Product__c(LAT_Description__c,id)][0]; 
                if (prodsWithSearchStringInDescription.size()>0) {
                    for(LAT_Product__c p:prodsWithSearchStringInDescription){

                    System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%% producto encontrado '+p.Id);
                    productFindedByDescription.add(p.Id);
                    }
                } else {

                    System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%% producto no encontrado ');
                }
            }
            // We dynamically build a query string and exclude items already in the shopping cart
            String qString = 'SELECT Id, LAT_Product__c, LAT_Product__r.LAT_IsRefactorProduct__c, PaymentCondition__c, PaymentConditionDescription__c, LAT_Product__r.LAT_Sku__c, MultipleQuantity__c, LAT_Product__r.LAT_UnitWeight__c, LAT_Product__r.LAT_BottlesPerBox__c, LAT_Product__r.LAT_CDUnit__c, PercentualBonus__c, LAT_Product__r.Name, LAT_Product__r.LAT_Family__c, LAT_Product__r.LAT_IsActive__c, LAT_Product__r.LAT_Description__c, LAT_Product__r.LAT_ProductCode__c, Account__r.Client_code_AN8__c FROM LAT_Account_product_payment__c WHERE Account__c =: idAccount AND LAT_Product__r.LAT_IsActive__c = true';
            
            // note that we are looking for the search string entered by the user in the name OR description
            // modify this to search other fields if desired
            if(searchString != null){
                qString+= ' AND (LAT_Product__r.Name like \'%' + searchString + '%\' )';
            }
            if(varPaymentVal != 'Todas'){
                qString += ' AND PaymentCondition__c like \'%' + varPaymentVal+ '%\'';
            }
            
            Set<string> selectedEntries = new Set<string>();
            for(LAT_OpportunityLineItem__c d:LAT_shoppingCart){
                if(d.LAT_Remover__c == false) {
                    selectedEntries.add(accountData.Client_code_AN8__c + d.LAT_SkuText__c + d.LAT_PaymentCondition__c);
                }
            }
            
            qString+= ' order by LAT_Product__r.Name';
            qString+= ' limit ' + QTDE_REGISTROS;
            
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%% query '+qString);
            AvailableProducts = database.query(qString);
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%% query '+AvailableProducts);
            

            
            //query pricebookentries to check if the product has the current opp currency
            List <LAT_Product__c> pbeList = [SELECT Id FROM LAT_Product__c WHERE LAT_IsRefactorProduct__c = 'Y' AND CurrencyIsoCode =: LAT_theOpp.CurrencyIsoCode];
            Set <Id> product2Set = new Set <Id>();
            for (LAT_Product__c pbe : pbeList) {
                product2Set.add(pbe.Id);
            }
            
            // Carrega os produtos na lista de ProductWrapper
            lstWProducts.clear();
            for (LAT_Account_product_payment__c app : AvailableProducts){
                string currentKey = app.Account__r.Client_code_AN8__c + app.LAT_Product__r.LAT_Sku__c + app.PaymentCondition__c;
                if (!selectedEntries.contains(currentKey) && product2Set.contains(app.LAT_Product__c) && app.LAT_Product__r.LAT_IsRefactorProduct__c == 'Y') {
                    lstWProducts.add(new productWrapper(app));
                }
            }
                        // We only display up to X results... if there are more than we let the user know (see vf page)
            if(lstWProducts.size()==QTDE_REGISTROS){
                lstWProducts.remove(QTDE_REGISTROS-1);
                overLimit = true;
            }
            else{
                overLimit=false;
            }           
        }
    }
    
    // Pega os valores da lista de wrapper
    public List<productWrapper> getlstWProducts(){
        return lstWProducts;
    }
    
    public Pagereference addItensToShoppingCart () {
        if(!Utils.wasMigrationDone('1')) {
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
            for (productWrapper pw : lstWProducts){
                if (pw.isSelected) {
                    if ( lLen == 0 ) {
                        oppAVista = pw.app.PaymentCondition__c == COND_PAGTO_AVISTA; lLen++;
                    }else if ( ( oppAVista && pw.app.PaymentCondition__c != COND_PAGTO_AVISTA ) || ( !oppAVista && pw.app.PaymentCondition__c == COND_PAGTO_AVISTA ) ){
                        AddMsgError('Não foi possível gravar o pedido. Não é possível misturar condição de pagamento à vista com outras formas de pagamento.');
                        return null;
                    }
                    // Coloca no shoppingCart os itens selecionados
                    OpportunityLineItem newOli = new opportunityLineItem(
                        OpportunityId = theOpp.Id, 
                        PriceBookEntry = pricebookEntriesByProduct.get(pw.app.Product__c), 
                        PriceBookEntryId = pricebookEntriesByProduct.get(pw.app.Product__c).Id, 
                        UnitPrice = 0, 
                        LAT_PaymentCondition__c = pw.app.PaymentCondition__c, 
                        LAT_PaymentConditionDescription__c = pw.app.PaymentConditionDescription__c, 
                        LAT_SkuText__c = pw.app.Product__r.Sku__c, 
                        LAT_UnitCode__c = pw.app.Product__r.CD_Unit__c, 
                        BottlesPerBox__c = pw.app.Product__r.bottles_per_box__c, 
                        UnitWeight__c = pw.app.Product__r.unit_weight__c, 
                        LAT_MultipleQuantity__c = pw.app.MultipleQuantity__c, 
                        LAT_PercentualBonus__c = pw.app.PercentualBonus__c
                    );
                    shoppingCart.add(newOli);
                    lIndex.add(i);
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
        //MIGRATED 07/11/2016
        else {
            List<Integer> lIndex = new List<Integer>();
            Integer i = 0; 
            Integer lLen = LAT_shoppingCart.size();
            //JPC: query para usar como transient el mapa
            List<id> productIds = new List<id>();
            for (productWrapper pw : lstWProducts) {
                productIds.add(pw.app.LAT_Product__c);
            }        
            LAT_pricebookEntriesByProduct = new map <id, LAT_Product__c>();
            List <LAT_Product__c> pbeList = [SELECT Id, LAT_BottlesPerBox__c, LAT_ProductCode__c FROM LAT_Product__c WHERE LAT_IsRefactorProduct__c = 'Y' AND LAT_IsActive__c = true  AND CurrencyIsoCode =: LAT_theOpp.CurrencyIsoCode AND Id IN: productIds];
            for (LAT_Product__c pbe : pbeList) {
                LAT_pricebookEntriesByProduct.put(pbe.Id, pbe);
            }
            //JPC: fin de modificaciones para mapa transient
            for (productWrapper pw : lstWProducts){
                if (pw.isSelected) {
                    if ( lLen == 0 ) {
                        oppAVista = pw.app.PaymentCondition__c == COND_PAGTO_AVISTA; lLen++;
                    }else if ( ( oppAVista && pw.app.PaymentCondition__c != COND_PAGTO_AVISTA ) || ( !oppAVista && pw.app.PaymentCondition__c == COND_PAGTO_AVISTA ) ){
                        AddMsgError('Não foi possível gravar o pedido. Não é possível misturar condição de pagamento à vista com outras formas de pagamento.');
                        return null;
                    }
                    // Coloca no shoppingCart os itens selecionados
                    
                    LAT_OpportunityLineItem__c newOli = new LAT_OpportunityLineItem__c(
                        LAT_Opportunity__r = LAT_theOpp, 
                        LAT_Opportunity__c = LAT_theOpp.Id,
                        LAT_Product__r = pw.app.LAT_Product__r,
                        LAT_Product__c = pw.app.LAT_Product__c,
                        LAT_UnitPrice__c = 0, 
                        LAT_PaymentCondition__c = pw.app.PaymentCondition__c, 
                        LAT_PaymentConditionDescription__c = pw.app.PaymentConditionDescription__c, 
                        LAT_SkuText__c = pw.app.LAT_Product__r.LAT_Sku__c, 
                        LAT_UnitCode__c = pw.app.LAT_Product__r.LAT_CDUnit__c, 
                        LAT_BottlesPerBox__c = pw.app.LAT_Product__r.LAT_BottlesPerBox__c, 
                        LAT_UnitWeight__c = pw.app.LAT_Product__r.LAT_UnitWeight__c, 
                        LAT_MultipleQuantity__c = pw.app.MultipleQuantity__c, 
                        LAT_PercentualBonus__c = pw.app.PercentualBonus__c
                    );
                    LAT_shoppingCart.add(newOli);
                    lIndex.add(i);
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
    }
    
    public PageReference onMsg(){
        AddMsgError('Você não pode deletar este item.');
        return null;
    }
    
    
    public PageReference removeFromShoppingCart(){     
        if(!Utils.wasMigrationDone('1')) {         
            // This function runs when a user hits "remove" on an item in the "Selected Products" section
            Integer count = 0;
            for(OpportunityLineItem d : shoppingCart){
                if((String)d.PriceBookEntryId==toUnselect){
                    if (IsForDelete(d)) {
                         AddMsgError(d.PriceBookEntry.Product2.Name+ ': Item já enviado ao JDE. Não poderá ser removido.');
                         return null;                
                    }
                }
            }
        
            for(OpportunityLineItem d : shoppingCart){
                if((String)d.PriceBookEntryId==toUnselect){               
                    if(d.Id!=null){
                        forDeletion.add(d);
                    }
                    shoppingCart.remove(count);
                    break;
                }
                count++;
            }
            updateAvailableListCheck();
            return null;
        }
        //MIGRATED 07/11/2016
        else {
            // This function runs when a user hits "remove" on an item in the "Selected Products" section
            Integer count = 0;
            for(LAT_OpportunityLineItem__c d : LAT_shoppingCart){
                if((String)d.LAT_Product__c==toUnselect){
                    if (IsForDelete(d)) {
                         AddMsgError(d.LAT_Product__r.Name+ ': Item já enviado ao JDE. Não poderá ser removido.');
                         return null;                
                    }
                }
            }
        
            for(LAT_OpportunityLineItem__c d : LAT_shoppingCart){
                if((String)d.LAT_Product__c==toUnselect){               
                    if(d.Id!=null){
                        LAT_forDeletion.add(d);
                    }
                    LAT_shoppingCart.remove(count);
                    break;
                }
                count++;
            }
            updateAvailableListCheck();
            return null;            
        }
    }
    
    public PageReference onSaveRefresh(){
        return internalSave( true );

    }

    public PageReference PriceCalculation2(){
        System.debug('%%%%%%%% estoy en opportunityProductEntryExtension');
        PriceCalculationInterface.LAT_PriceCalculation(null, LAT_theOpp, LAT_shoppingCart);
        
        return null;

    }
    
    public PageReference onSave(){
        return internalSave( false );
    }
    
    private PageReference internalSave( boolean aRefresh ){
        if(!Utils.wasMigrationDone('1')) {
            // If previously selected products are now removed, we need to delete them
            if(forDeletion.size()>0){
                delete(forDeletion);
                if ( aRefresh ) forDeletion = new opportunityLineItem[]{};
            }
            // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
            try{
               upsert(shoppingCart);
            }catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }
            // After save return the user to the Opportunity
            if ( aRefresh ){
                loadShoppingCart();
                erroSave = '';
                return null;
            }else{
                return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
            }
        }
        //MIGRATED 07/11/2016
        else {
            // If previously selected products are now removed, we need to delete them
            if(LAT_forDeletion.size()>0){
                delete(LAT_forDeletion);
                if ( aRefresh ) LAT_forDeletion = new LAT_OpportunityLineItem__c[]{};
            }
            // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
            try{
               upsert(LAT_shoppingCart);
            }catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }
            // After save return the user to the Opportunity
            if ( aRefresh ){
                loadShoppingCart();
                erroSave = '';
                return null;
            }else{
                return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
            }            
        }
    }
    
    public PageReference onCancel(){
        // If user hits cancel we commit no changes and return them to the Opportunity   
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    public PageReference changePricebook(){
        if(!Utils.wasMigrationDone('1')) {
            // This simply returns a PageReference to the standard Pricebook selection screen
            // Note that is uses retURL parameter to make sure the user is sent back after they choose
            PageReference ref = new PageReference('/oppitm/choosepricebook.jsp');
            ref.getParameters().put('id',theOpp.Id);
            ref.getParameters().put('retURL','/apex/opportunityProductEntry?id=' + theOpp.Id);
            return ref;
        } else {
            return new PageReference('/' + ApexPages.currentPage());
        }
    }
    
    public PageReference showCampoFormatado(){
        if(!Utils.wasMigrationDone('1')) {        
            PageReference pf = new PageReference('/apex/VisualizaComposicaoPrecoOppLineItem?id=' + shoppingCart[0].Id);
            pf.setRedirect(true);
            return pf; 
        }
        //MIGRATED 07/11/2016            
        else {
            PageReference pf = new PageReference('/apex/VisualizaComposicaoPrecoOppLineItem?id=' + LAT_shoppingCart[0].Id);
            pf.setRedirect(true);
            return pf;             
        }
    }
    
    public void AddMsgError(String aMsg){
        ApexPages.addMessage(new ApexPages.Message( ApexPages.severity.ERROR,aMsg));
    }
    
}