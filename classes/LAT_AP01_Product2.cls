/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Product2
*******************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/

public with sharing class LAT_AP01_Product2 {
  
   /*****************************************************************************************
    * Nombre del metodo: createsPriceBookEntry
    * Descripcion: Metodo que crear los Price Book Entrys
    * Desarrollador: Juan Pablo Cubo
    * Fecha: 19/11/2013
    * Modo: after insert
    *****************************************************************************************/
    public static void createsPriceBookEntry(List<Product2> triggerNew){
        /*
        //select the standard pricebook
        Pricebook2 stdPriceBook;
        try{stdPriceBook = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];}catch(Exception e){}
        List<PricebookEntry> lstPbeInsert = new List<PricebookEntry>();
        List<String> lstCurrencyType = new List<String>{'ARS','UYU','MXN','BRL','USD','EUR'}; 
        for(Product2 prod: triggerNew){
            if(prod.LAT_IsRefactorProduct__c == 'Y'){
                for(String ct : lstCurrencyType){
                    //insert standard pricebook
                    if(stdPriceBook != null){
                        lstPbeInsert.add(new PricebookEntry(CurrencyIsoCode = ct, IsActive = true, Pricebook2Id = stdPriceBook.Id, Product2Id = prod.Id, UnitPrice = 0));
                    }
                }
            }
        }
        if(!lstPbeInsert.isEmpty()){
            insert lstPbeInsert;
        }
        */
    }
    
   /*****************************************************************************************
    * Nombre del metodo: activatesProduct2
    * Descripcion: Metodo que activa el producto cuando se inserta
    * Desarrollador: Elena Schwarzböck
    * Fecha: 26/02/2014
    * Modo: before insert
    *****************************************************************************************/
    public static void activatesProduct2(List<Product2> triggerNew){
        /*
        for(Product2 prod: triggerNew){
            prod.IsActive = true;
        }
        */
    }  
    //MIGRATED 17/11/2016
    public static void activatesProduct2(List<LAT_Product__c> triggerNew){
        for(LAT_Product__c prod: triggerNew){
            prod.LAT_IsActive__c = true;
        }
    }  
    
    /*********************************************************************************************************
    * Nombre del metodo: updatesPPCKey
    * Descripcion: Method that calls the method that updates the field Produto_Concorr_ncia__c.LAT_Key__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 07/05/2013
    * Modo: after update
    ********************************************************************************************************/
    public static void updatesPPCKey(List<Product2> triggerNew, Map<Id,Product2> oldMap){
     /*   
        Set<Id> setIds = new Set<Id>();
        for(Product2 prod: triggerNew){
            if(prod.LAT_BR_BrandGrouping__c != oldMap.get(prod.Id).LAT_BR_BrandGrouping__c && prod.RecordTypeId == Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard')){
                setIds.add(prod.Id);          
            }
        }
        
        Map<Id,Produto_Concorr_ncia__c> mapPPC = new Map<Id,Produto_Concorr_ncia__c>([SELECT Id FROM Produto_Concorr_ncia__c WHERE Produto_PERNOD__c IN: setIds AND Checklist_de_visita__r.LAT_BR_ValidOnTradeChecklist__c = true]);
        
        if(!mapPPC.isEmpty()){
            LAT_BR_UpdatesKeyOfPPC.updatesKeyOfPPC(mapPPC.keySet());     
        }  
        */
    }  
    
    /*****************************************************************************************
    * Nombre del metodo: updateIndexMargin
    * Descripcion: Metodo que carga el valor del Index Margin para el producto.
    * Desarrollador: Javier Fagian
    * Fecha: 3/03/2018
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void updateIndexMargin(List<LAT_Product__c> triggerNew, String rType){
        
        System.debug('%%%%% rType : '+rType);
        List<LAT_BrandIndex__c> lstIndexMarcas = [SELECT Codigo__c, Index__c FROM LAT_BrandIndex__c WHERE RecordType.DeveloperName = :rType];
        LAT_GeneralConfig__c cs = [SELECT Name, id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'MX_DEFAULT_INDEX_MARGIN'];
        Map<String, Decimal> mapIndexMarcas = new Map<String, Decimal>();
        List<LAT_Product__c> productsToPostInChetter = new List<LAT_Product__c>();
        for (LAT_BrandIndex__c bi : lstIndexMarcas) {
            mapIndexMarcas.put(bi.Codigo__c, bi.Index__c);
        }

        for (LAT_Product__c p : triggerNew) {
            System.debug('%%%%% mapIndexMarcas.keySet() : '+mapIndexMarcas.keySet());
            System.debug('%%%%% p.LAT_Scheduler__c : '+p.LAT_Scheduler__c);
            if (mapIndexMarcas.get(p.LAT_Scheduler__c) != null) {
                p.LAT_IndexMarca__c = mapIndexMarcas.get(p.LAT_Scheduler__c);
            } else {
                p.LAT_IndexMarca__c = Decimal.valueOf(cs.LAT_Value__c);
                productsToPostInChetter.add(p);
            }
        }
        if (productsToPostInChetter.size() > 0) {
            postToChatter(productsToPostInChetter);
        }
        
    }

    public static void postToChatter(List<LAT_Product__c> triggerNew) {

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        LAT_CHATTER_POST_BODY__c cs = [SELECT Body__c FROM LAT_CHATTER_POST_BODY__c WHERE Name = 'LAT_MX_ProductoSinIndexMarca'];
        String body = cs.Body__c;
        LAT_GeneralConfig__c gc = [SELECT Name, id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'MX_IndexMarca_Notification_Users'];
        List<String> usersOnCopy = gc.LAT_Value__c.split(',');
               
        String productList = '';                    
        for (LAT_Product__c p : triggerNew) {
            productList = productList + ' - ' +  p.Name  + ' (Código : ' +p.LAT_Scheduler__c + '). \n';
        }   
        body = body.replace('xx_PRODUCT_LIST_xx', productList);

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = body;
        System.debug('%%%% textSegmentInput.text : '+textSegmentInput.text);
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        for (String uOnCopy : usersOnCopy ) {
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = uOnCopy;
            messageBodyInput.messageSegments.add(mentionSegment);
        }
        
        System.debug('%%%% messageBodyInput : '+messageBodyInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = usersOnCopy.get(0);
      

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        batchInputs.add(batchInput);         
        if (batchInputs.size() > 0) {
            if (!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        } 
                
    }

    /*****************************************************************************************
    * Nombre del metodo: updateRestriction
    * Descripcion: Metodo que borra los valores de Restricción si se sobrepasa la fecha de fin.
    * Desarrollador: Javier Fagian
    * Fecha: 3/03/2018
    * Modo: before update
    *****************************************************************************************/
    public static void updateRestriction(List<LAT_Product__c> triggerNew){
        
        for (LAT_Product__c p : triggerNew) {
            if (p.LAT_RestrictionEnd__c != null) {
                if (p.LAT_RestrictionEnd__c < Date.today()) {
                    p.LAT_RestrictionEnd__c = null;
                    p.LAT_RestrictionInit__c = null;
                    p.LAT_RestrictionDescription__c = null;
                }
            }
        }
        
    }

    /*****************************************************************************************
    * Nombre del metodo: validateKeyBrandIsNotEmpty
    * Descripcion: Metodo que valdia que todos los productos de Brasil tengan Schedule C, y que éste a su 
    vez tenga Key Brand, ya que es necesario para Price Flexibility.
    * Desarrollador: Javier Fagian
    * Fecha: 19/02/2012
    * Modo: after insert, after update
    *****************************************************************************************/
    public static void validateKeyBrandIsNotEmpty(List<LAT_Product__c> triggerNew){
        Set<Id> schedulCIds = new Set<Id>();
        String message = '';
        for(LAT_Product__c prod : triggerNew){
            if(prod.LAT_IsActive__c) {
                if(prod.LAT_ScheduleC__c != null){
                    schedulCIds.add(prod.LAT_ScheduleC__c);
                } else{
                    message += '<br> - El producto ' + prod.Name + ' (SKU: ' + prod.LAT_Sku__c + ') no tiene Schedule C, por favor revíselo. Id: '+prod.Id; 
                }
            }
        }

        if(schedulCIds.size() > 0) {
            Map<Id, LAT_ScheduleC__c> scheduleCs = new Map<Id, LAT_ScheduleC__c>([SELECT Id, Name, KeyBrand__c, KeyBrand__r.Key__c, KeyBrand__r.Name FROM LAT_ScheduleC__c WHERE Id IN :schedulCIds]);
            for(LAT_Product__c prod : triggerNew){
                if(prod.LAT_ScheduleC__c == null || !prod.LAT_IsActive__c) continue;
                if(scheduleCs.get(prod.LAT_ScheduleC__c).KeyBrand__c != null){
                    if(scheduleCs.get(prod.LAT_ScheduleC__c).KeyBrand__r.Key__c == null || scheduleCs.get(prod.LAT_ScheduleC__c).KeyBrand__r.Key__c == '') {
                        message += '<br> - El Key Brand ' + scheduleCs.get(prod.LAT_ScheduleC__c).KeyBrand__r.Name + ' no tiene Key válida, por favor revíselo. Id: '+scheduleCs.get(prod.LAT_ScheduleC__c).KeyBrand__c; 
                    }
                } else {
                    message += '<br> - El ScheduleC ' + scheduleCs.get(prod.LAT_ScheduleC__c).Name + ' no tiene Key Brand, por favor revíselo. Id: '+prod.LAT_ScheduleC__c; 
                }
            }
        }

        if(message != '') {
            String html = '';
            String subject = 'Hay Productos Activos de Brasil que necesitan su atención.';
            html += 'Los siguientes productos de Brasil tienen errores que necesitan su atención: <br> <br>';

            html += message;
            
            html += '<br><br>Muchas gracias! <br><br>Equipo CRM ';


            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(LAT_RecordIntegrationVerifications.getAdminEmails());
            email.setSaveAsActivity(false);
            email.setHtmlBody(html);
            email.setBccSender(false);
            email.setSubject(subject);
            email.setUseSignature(false);
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
            
        }
    }
}