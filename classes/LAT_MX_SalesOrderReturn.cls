/************************************************************************************
*                           Company: ValueNet                                       *
*-----------------------------------------------------------------------------------*
*   Metodo de interfaz para generacion de pedidos para Mexico                       *
************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_SalesOrderReturn {

    
    public static integer LAT_ETL_SalesOrderLoad(Integer Country, String cd_salesman, String NR_order_crm, Integer NR_order_JDE, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String companyCode, String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderReturn.SalesOrderItem> listaItem){
        
        //Validacion del cliente
        Set<Id> setRTAccMX = Global_RecordTypeCache.getRtIdSet('Account', new set<string>{'LAT_MX_ACC_OffTrade', 'LAT_MX_ACC_OnTrade'});
        Account account;
        system.debug('aaaaa ' + country+'-'+customer_AN8);
        system.debug('bbbbb ' + setRTAccMX);

        try{account = [SELECT Id, Price_Group__c, CurrencyIsoCode, OwnerId, Owner.isActive
                       FROM Account
                       WHERE Client_country_AN8__c =: (country+'-'+customer_AN8) AND RecordTypeId IN : setRTAccMX LIMIT 1];}catch(Exception e){}

        CS001_JDEInterfaceCredentials__c credentials = CS001_JDEInterfaceCredentials__c.getInstance('México');
        User us = null;
        if(credentials != null && credentials.UserName__c != null){
            us = [SELECT Id, isActive FROM User WHERE UserName =: credentials.UserName__c];
        }
        
        //Si el cliente no existe se devuelve error
        if(account == null){
            return SalesOrderReturn.notFound_client;
        }
        
        String JDEOrderKey;
        if(country != null && CD_Order_Type != null && NR_order_JDE != null && companyCode != null){
            JDEOrderKey = country+'-'+CD_Order_Type.trim()+'-'+NR_order_JDE+'-'+companyCode.trim();
        }
        
        Set<Id> setRTOppMX = Global_RecordTypeCache.getRtIdSet('Opportunity', new set<string>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
        Opportunity opp;
        try{opp = [SELECT OwnerId, Owner.isActive, Account.Client_code_AN8__c, NR_customer_order__c, DS_Message1__c, DS_Message2__c, DT_delivery__c, 
                          Freight__c, CloseDate, type, CD_order_status__c, Account.Business_Unit__c, NR_order_JDE__c, Account.Regional__r.Id, 
                          Account.Channel__c, Account.Sub_Channel__c, Account.Customer_Flag__r.Id, AccountId, RecordType.Name, Grupo_de_precos__c, 
                          Pricebook2id, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_MX_OrderPaymentPeriodReference__c
                   FROM Opportunity
                   WHERE (Id =: string.valueOf(NR_order_crm.trim()) OR (LAT_JDEOrderKey__c =: JDEOrderKey)) AND RecordTypeId IN : setRTOppMX LIMIT 1];}catch(Exception e){}
        
        if(SalesOrder_Source != null){
            SalesOrder_Source = SalesOrder_Source.trim().toUpperCase();
        }
        
        if(SalesOrder_Source == 'C'){
            //Pedidos originados en SF (SalesOrder_Source = C)
            if(opp == null){
                return SalesOrderReturn.notFound_opportunity;
            }
        }else{
            //Pedidos no originados en SF
            if(opp == null){
                opp = new Opportunity();
            }
        }
        
        //si el owner del pedido esta inactivo lo reasigno al del cliente o al del custom setting. si ninguno esta activo se devuelve el return code
        if(!opp.owner.isActive){
            if(account.Owner.isActive){
                opp.OwnerId = account.OwnerId;
            }else if(us != null && us.isActive){
                opp.OwnerId = us.Id;
            }else{
                return SalesOrderReturn.inactiveClientOwner;
            }
        }
        
        //Mapeo del pedido
        opp.Origem_do_pedido__c          = (SalesOrder_Source == 'C')?('CRM'):((SalesOrder_Source == 'E')?('EDI'):('JDE'));
        opp.CloseDate                    = SalesOrderReturn.convertToDate(DT_Order);
        opp.Campo_de_formatacao__c       = Utils.decodeString(priceComponents, true);
        opp.LAT_MX_PurchaseOrderUntil__c = SalesOrderReturn.convertToDate(purchaseOrderUntil);
        opp.Name                         = string.valueOf(NR_order_JDE);
        opp.NR_order_JDE__c              = string.ValueOf(NR_order_JDE);
        opp.CurrencyIsoCode              = account.CurrencyIsoCode;
        opp.NR_customer_order__c         = NR_customer_order;
        opp.LAT_MX_RetentionReason__c    = retentionReason;
        //opp.OwnerId                      = account.OwnerId;
        opp.Type                         = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
        opp.Integracao_Retorno_JDE__c    = returnMessage;
        opp.DS_Message1__c               = DS_message1;
        opp.DS_Message2__c               = DS_message2;
        opp.LAT_CompanyCode__c           = companyCode;
        opp.Accountid                    = account.id;
        opp.Freight__c                   = freight;
        opp.Pais__c                      = country;
        opp.Integracao__c                = true;
        
        if(SalesOrder_Source != 'C'){
            if(paymentTerm != null && paymentTerm != ''){
                List<UDC__c> udc = [SELECT Id, CodDefUsuario__c, RecordTypeId FROM UDC__c WHERE CodDefUsuario__c =: paymentTerm AND RecordTypeId =: Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard') LIMIT 1];
                if(!udc.isEmpty()){
                    opp.LAT_MX_OrderPaymentPeriodReference__c = udc[0].Id;    
                }
            }
        }
        
        if(opp.StageName != 'Pedido cancelado no JDE'){
            opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'LAT_MX_OPP_HeaderBlocked');
            opp.StageName    = 'Pedido processado no JDE';
        }
        
        // Si "returnCode != 0" ocurrio un error en JDE
        if(returnCode != 0){
            opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'LAT_MX_OPP_HeaderBlocked');
            opp.StageName    = 'Pedido com erro no JDE';
            upsert opp;
            return SalesOrderReturn.success;
        }
        
        //Construimos el internal id para buscar los productos en SF
        map<string, List<SalesOrderReturn.SalesOrderItem>> mapInternalIdItem = new map<string, List<SalesOrderReturn.SalesOrderItem>>();
        map<String, SalesOrderReturn.SalesOrderItem> mapNrJDEItem = new map<string, SalesOrderReturn.SalesOrderItem>();
        for(SalesOrderReturn.SalesOrderItem item : listaItem){
            if(mapInternalIdItem.containsKey(getlProdCode(country,item.Cd_product))){
                mapInternalIdItem.get(getlProdCode(country,item.Cd_product)).add(item);
            }else{
                mapInternalIdItem.put(getlProdCode(country,item.Cd_product), new List<SalesOrderReturn.SalesOrderItem>{item});
            }
            if(item.NR_order_line_jde != null){
                mapNrJDEItem.put(string.valueOf(item.NR_order_line_jde).trim(), item);
            }
        }
        
        //Se buscan en SF los productos enviados por la llamada
        map<String,PricebookEntry> mapInternalIdPBE = new map<String,PricebookEntry>();
        List<PricebookEntry> listPBEtoActivate = new List<PricebookEntry>(); 
        for(PricebookEntry pbe: [SELECT Id, Product2Id, Product2.Internal_id__c, isActive FROM PricebookEntry WHERE Product2.Internal_id__c IN: mapInternalIdItem.keySet() AND CurrencyIsoCode =: 'MXN']){
            mapInternalIdPBE.put(pbe.Product2.Internal_id__c, pbe);
            if (!pbe.isActive) { 
                listPBEtoActivate.add(pbe);
            }
        }
        system.debug('mapInternalIdPBE ' + mapInternalIdPBE.size() );
        system.debug('mapInternalIdItem ' + mapInternalIdItem.size() );
                //Verifico que se hayan encontrado todos los productos
        if(mapInternalIdPBE.size() != mapInternalIdItem.size()){
            return SalesOrderReturn.notFound_product;
        }
        
        List<OpportunityLineItem> listOLIsToUpsert = new List<OpportunityLineItem>();
        
        if(!listPBEtoActivate.isEmpty()){
            SalesOrderReturn.activatesPricebookEntrys(listPBEtoActivate);
        }
        
        //set que se usa para controlar los Nro de order JDE que ya se usaron
        Set<String> setNROrderOlis = new Set<String>();
        
        //Actualizo los que ya estan en SF
        for(OpportunityLineItem oli : [SELECT id, PricebookEntryId, PricebookEntry.Product2.Internal_id__c, Integracao__c, Remover__c, Quantity, NR_order_line__c, QT_Bonus__c, Discount, Discount_AR__c, cd_line_status__c, Descricao_do_status__c, UnitPrice, OpportunityId, Campo_de_formatacao__c, LAT_SkuText__c FROM OpportunityLineItem WHERE OpportunityId =: opp.id ]){
            //me fijo si hay algun item que tenga el mismo NR_order_line__c del item
            if(mapNrJDEItem.containsKey(oli.NR_order_line__c)){
                mappingOLI(oli, mapNrJDEItem.get(oli.NR_order_line__c));
                listOLIsToUpsert.add(oli);
                setNROrderOlis.add(oli.NR_order_line__c);
            //si no lo encontro por NR_order_line__c lo busco por Internal_id__c        
            }else if(mapInternalIdItem.containsKey(oli.PricebookEntry.Product2.Internal_id__c) && mapInternalIdItem.get(oli.PricebookEntry.Product2.Internal_id__c).size() > 0){
                SalesOrderReturn.SalesOrderItem item = mapInternalIdItem.get(oli.PricebookEntry.Product2.Internal_id__c)[0];
                if(!setNROrderOlis.contains(string.valueOf(item.NR_order_line_jde).trim())){
                    mappingOLI(oli, item);
                    listOLIsToUpsert.add(oli);
                    setNROrderOlis.add(oli.NR_order_line__c);               
                }
            } 
        }
                         
        //Salvo la oportunidad y sus items
        upsert opp;
        
        //Creo los nuevos que pueden llegar a venir
        for(string idItem : mapInternalIdItem.keySet()){
            for(SalesOrderReturn.SalesOrderItem item: mapInternalIdItem.get(idItem)){
                if(!setNROrderOlis.contains(string.valueOf(item.NR_order_line_jde).trim())){
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = opp.Id;
                    oli.PricebookEntryId = mapInternalIdPBE.get(idItem).Id;
                    mappingOLI(oli, item);
                    listOLIsToUpsert.add(oli);
                }
            }
        }
                
        upsert listOLIsToUpsert;
        
        return SalesOrderReturn.success;
    }
    
    //MIGRATED 07/11/2016 
    public static integer LAT_ETL_SalesOrderLoadMigrated(Integer Country, String cd_salesman, String NR_order_crm, Integer NR_order_JDE, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String companyCode, String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderReturn.SalesOrderItem> listaItem){
        Set<Id> setRTAccMX = Global_RecordTypeCache.getRtIdSet('Account', new set<string>{'LAT_MX_ACC_OffTrade', 'LAT_MX_ACC_OnTrade'});
        Account account;
        

        try{account = [SELECT Id, Price_Group__c, CurrencyIsoCode, OwnerId, Owner.isActive
                       FROM Account
                       WHERE Client_country_AN8__c =: (country+'-'+customer_AN8) AND RecordTypeId IN : setRTAccMX LIMIT 1];}catch(Exception e){}

        CS001_JDEInterfaceCredentials__c credentials = CS001_JDEInterfaceCredentials__c.getInstance('México');
        User us = null;
        if(credentials != null && credentials.UserName__c != null){
            us = [SELECT Id, isActive FROM User WHERE UserName =: credentials.UserName__c];
        }
        
        //Si el cliente no existe se devuelve error
        if(account == null){
            return SalesOrderReturn.notFound_client;
        }
        
        String JDEOrderKey;
        if(country != null && CD_Order_Type != null && NR_order_JDE != null && companyCode != null){
            JDEOrderKey = country+'-'+CD_Order_Type.trim()+'-'+NR_order_JDE+'-'+companyCode.trim();
        }
        
        Set<Id> setRTOppMX = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c', new set<string>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
        LAT_Opportunity__c opp;
        try{opp = [SELECT OwnerId, Owner.isActive, LAT_Account__r.Client_code_AN8__c, LAT_NRCustomerOrder__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_DTDelivery__c, 
                          LAT_Freight__c, LAT_CloseDate__c, LAT_Type__c, LAT_CDOrderStatus__c, LAT_Account__r.Business_Unit__c, LAT_NROrderJDE__c, LAT_Account__r.Regional__r.Id, 
                          LAT_Account__r.Channel__c, LAT_Account__r.Sub_Channel__c, LAT_Account__r.Customer_Flag__r.Id, LAT_Account__c, RecordType.Name, LAT_AccountPriceBook__c, 
                          LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_MX_OrderPaymentPeriodReference__c, LAT_OrderOrigin__c
                   FROM LAT_Opportunity__c
                   WHERE (Id =: string.valueOf(NR_order_crm.trim()) OR (LAT_JDEOrderKey__c =: JDEOrderKey)) AND RecordTypeId IN : setRTOppMX LIMIT 1];}catch(Exception e){}
        
        if(SalesOrder_Source != null){
            SalesOrder_Source = SalesOrder_Source.trim().toUpperCase();
        }
        
        if(SalesOrder_Source == 'C' && !String.valueOf(NR_order_crm.trim()).startsWith('006')){
            //Pedidos originados en SF (SalesOrder_Source = C)
            if(opp == null){
                return SalesOrderReturn.notFound_opportunity;
            }
        }else{
            //Pedidos no originados en SF
            if(opp == null){
                opp = new LAT_Opportunity__c();
            }
        }
        
        //si el owner del pedido esta inactivo lo reasigno al del cliente o al del custom setting. si ninguno esta activo se devuelve el return code
        if(!opp.owner.isActive){
            if(account.Owner.isActive){
                opp.OwnerId = account.OwnerId;
            }else if(us != null && us.isActive){
                opp.OwnerId = us.Id;
            }else{
                return SalesOrderReturn.inactiveClientOwner;
            }
        }
        
        //Mapeo del pedido
        System.debug('%%%%%%% SalesOrder_Source en MX.LAT_ETL_SalesOrderLoadMigrated : ' + SalesOrder_Source);
        if (opp.LAT_OrderOrigin__c != 'APP') {
            opp.LAT_OrderOrigin__c  = (SalesOrder_Source == 'C')?('CRM'):((SalesOrder_Source == 'E')?('EDI'):('JDE'));
        }
        opp.LAT_CloseDate__c                    = SalesOrderReturn.convertToDate(DT_Order);
        opp.LAT_FormatField__c       = Utils.decodeString(priceComponents, true);
        opp.LAT_RawPriceComponents__c = priceComponents;
        opp.LAT_MX_PurchaseOrderUntil__c = SalesOrderReturn.convertToDate(purchaseOrderUntil);
        opp.Name                         = string.valueOf(NR_order_JDE);
        opp.LAT_NROrderJDE__c              = string.ValueOf(NR_order_JDE);
        opp.CurrencyIsoCode              = account.CurrencyIsoCode;
        opp.LAT_NRCustomerOrder__c         = NR_customer_order;
        opp.LAT_MX_RetentionReason__c    = retentionReason;
        //opp.OwnerId                      = account.OwnerId;
        opp.LAT_Type__c                         = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
        opp.LAT_JDEIntegrationReturn__c    = returnMessage;
        opp.LAT_DSMessage1__c               = DS_message1;
        opp.LAT_DSMessage2__c               = DS_message2;
        opp.LAT_CompanyCode__c           = companyCode;
        opp.LAT_Account__c               = account.id;
        opp.LAT_Freight__c                   = freight;
        opp.LAT_Country__c                      = country;
        opp.LAT_Integration__c                = true;
        
        if(SalesOrder_Source != 'C'){
            if(paymentTerm != null && paymentTerm != ''){
                List<UDC__c> udc = [SELECT Id, CodDefUsuario__c, RecordTypeId FROM UDC__c WHERE CodDefUsuario__c =: paymentTerm AND RecordTypeId =: Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard') LIMIT 1];
                if(!udc.isEmpty()){
                    opp.LAT_MX_OrderPaymentPeriodReference__c = udc[0].Id;    
                }
            }
        }
        
        if(opp.LAT_StageName__c != 'Pedido cancelado no JDE'){
            opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'LAT_MX_OPP_HeaderBlocked');
            opp.LAT_StageName__c    = 'Pedido processado no JDE';
        }
        
        // Si "returnCode != 0" ocurrio un error en JDE
        if(returnCode != 0){
            opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'LAT_MX_OPP_HeaderBlocked');
            opp.LAT_StageName__c    = 'Pedido com erro no JDE';
            upsert opp;
            return SalesOrderReturn.success;
        }
        
        //Construimos el internal id para buscar los productos en SF
        map<string, List<SalesOrderReturn.SalesOrderItem>> mapInternalIdItem = new map<string, List<SalesOrderReturn.SalesOrderItem>>();
        map<String, SalesOrderReturn.SalesOrderItem> mapNrJDEItem = new map<string, SalesOrderReturn.SalesOrderItem>();
        for(SalesOrderReturn.SalesOrderItem item : listaItem){
            if(mapInternalIdItem.containsKey(getlProdCode(country,item.Cd_product))){
                mapInternalIdItem.get(getlProdCode(country,item.Cd_product)).add(item);
            }else{
                mapInternalIdItem.put(getlProdCode(country,item.Cd_product), new List<SalesOrderReturn.SalesOrderItem>{item});
            }
            if(item.NR_order_line_jde != null){
                mapNrJDEItem.put(string.valueOf(item.NR_order_line_jde).trim(), item);
            }
        }
        
        //Se buscan en SF los productos enviados por la llamada
        map<String,LAT_Product__c> mapInternalIdPBE = new map<String,LAT_Product__c>();
        for(LAT_Product__c pbe: [SELECT Id, LAT_ExternalID__c, LAT_IsActive__c FROM LAT_Product__c WHERE LAT_ExternalID__c IN: mapInternalIdItem.keySet() AND CurrencyIsoCode =: 'MXN']){
            mapInternalIdPBE.put(pbe.LAT_ExternalID__c, pbe);
            
        }
        system.debug('LAT mapInternalIdPBE ' + mapInternalIdPBE.size() );
        system.debug('LAT mapInternalIdItem ' + mapInternalIdItem.keySet()  );
                //Verifico que se hayan encontrado todos los productos
        if(mapInternalIdPBE.size() != mapInternalIdItem.size()){
            return SalesOrderReturn.notFound_product;
        }
        
        List<LAT_OpportunityLineItem__c> listOLIsToUpsert = new List<LAT_OpportunityLineItem__c>();
        
        
        //set que se usa para controlar los Nro de order JDE que ya se usaron
        Set<String> setNROrderOlis = new Set<String>();
        
        //Actualizo los que ya estan en SF
        for(LAT_OpportunityLineItem__c oli : [SELECT id, LAT_Product__r.LAT_ExternalID__c, LAT_Integration__c, LAT_Remover__c, LAT_Quantity__c, LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Discount__c, LAT_AR_Discount__c, LAT_CdLineStatus__c, LAT_StatusDescription__c, LAT_UnitPrice__c, LAT_Opportunity__c, LAT_FormatField__c, LAT_SkuText__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: opp.id ]){
            //me fijo si hay algun item que tenga el mismo NR_order_line__c del item
            if(mapNrJDEItem.containsKey(oli.LAT_NROrderLine__c)){
                mappingLATOLI(oli, mapNrJDEItem.get(oli.LAT_NROrderLine__c));
                listOLIsToUpsert.add(oli);
                setNROrderOlis.add(oli.LAT_NROrderLine__c);
            //si no lo encontro por NR_order_line__c lo busco por Internal_id__c        
            }else if(mapInternalIdItem.containsKey(oli.LAT_Product__r.LAT_ExternalID__c) && mapInternalIdItem.get(oli.LAT_Product__r.LAT_ExternalID__c).size() > 0){
                SalesOrderReturn.SalesOrderItem item = mapInternalIdItem.get(oli.LAT_Product__r.LAT_ExternalID__c)[0];
                if(!setNROrderOlis.contains(string.valueOf(item.NR_order_line_jde).trim())){
                    mappingLATOLI(oli, item);
                    listOLIsToUpsert.add(oli);
                    setNROrderOlis.add(oli.LAT_NROrderLine__c);               
                }
            } 
            oli.CurrencyIsoCode = opp.CurrencyIsoCode;
        }
        
        system.debug('aaaaa ' + opp.ownerId);
        //Salvo la oportunidad y sus items
        upsert opp;
        
        //Creo los nuevos que pueden llegar a venir
        for(string idItem : mapInternalIdItem.keySet()){
            for(SalesOrderReturn.SalesOrderItem item: mapInternalIdItem.get(idItem)){
                if(!setNROrderOlis.contains(string.valueOf(item.NR_order_line_jde).trim())){
                    LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
                    oli.LAT_Opportunity__c = opp.Id;
                    oli.LAT_Product__c = mapInternalIdPBE.get(idItem).Id;
                    mappingLATOLI(oli, item);
                    listOLIsToUpsert.add(oli);
                    oli.CurrencyIsoCode = opp.CurrencyIsoCode;
                }
            }
        }
                
        upsert listOLIsToUpsert;
        
        return SalesOrderReturn.success;
            
    }

    
    /************************************************
    *               METODOS PRIVADOS                *
    ************************************************/

    private static String getlProdCode( integer aCountry, String aProduct ){
        String lProdCode = string.valueOf(aCountry) + '-' + string.valueOf(aProduct).trim();
        return lProdCode;    
    }


    private static void mappingOLI(OpportunityLineItem oli, SalesOrderReturn.SalesOrderItem item){
        //Mapeo de los productos del pedido
        oli.Campo_de_formatacao__c          = Utils.decodeString(item.priceComponents, false);
        oli.NR_order_line__c                = string.ValueOf(item.NR_order_line_jde);
        oli.NR_Order_Item__c                = item.NR_order_line_jde;
        oli.Descricao_do_status__c          = item.orderLineStatusDescription;
        oli.LAT_MX_EstimatedDeliveryDate__c = SalesOrderReturn.convertToDate(item.estimatedDeliveryDate);
        oli.LAT_MX_LogisticsPromisedDate__c = SalesOrderReturn.convertToDate(item.logisticsPromisedDate);
        oli.LAT_MX_CDLineStatusFrom__c      = item.cd_line_last_status;
        oli.LAT_MX_SignedDatedReceipt__c    = item.signedDatedReceipt;
        oli.LAT_MX_CancellationReason__c    = item.cancellationReason;
        oli.LAT_MX_RealDeliveryDate__c      = SalesOrderReturn.convertToDate(item.realDeliveryDate);
        oli.cd_line_status__c               = item.cd_line_status;
        oli.LAT_MX_KAMPromisedDate__c       = SalesOrderReturn.convertToDate(item.promisedDate);
        oli.Quantity                        = item.QT_sales;
        oli.UnitPrice                       = item.Vl_Valor;
        oli.Integracao__c                   = true;
        oli.LAT_SkuText__c                  = item.Cd_product.trim();
        if(item.holdOrderCode != null){
            oli.Description                 = item.holdOrderCode.replace('-',' ');
        }
    }

    //MIGRATED 07/11/2016 
    private static void mappingLATOLI(LAT_OpportunityLineItem__c oli, SalesOrderReturn.SalesOrderItem item){
        //Mapeo de los productos del pedido
        oli.LAT_FormatField__c          = Utils.decodeString(item.priceComponents, false);
        oli.LAT_RawLinePriceComponents__c          = item.priceComponents;
        oli.LAT_NROrderLine__c                = string.ValueOf(item.NR_order_line_jde);
        oli.LAT_NROrder_Item__c                = item.NR_order_line_jde;
        oli.LAT_StatusDescription__c          = item.orderLineStatusDescription;
        oli.LAT_MX_EstimatedDeliveryDate__c = SalesOrderReturn.convertToDate(item.estimatedDeliveryDate);
        oli.LAT_MX_LogisticsPromisedDate__c = SalesOrderReturn.convertToDate(item.logisticsPromisedDate);
        oli.LAT_MX_CDLineStatusFrom__c      = item.cd_line_last_status;
        oli.LAT_MX_SignedDatedReceipt__c    = item.signedDatedReceipt;
        oli.LAT_MX_CancellationReason__c    = item.cancellationReason;
        oli.LAT_MX_RealDeliveryDate__c      = SalesOrderReturn.convertToDate(item.realDeliveryDate);
        oli.LAT_CdLineStatus__c               = item.cd_line_status;
        oli.LAT_MX_KAMPromisedDate__c       = SalesOrderReturn.convertToDate(item.promisedDate);
        oli.LAT_Quantity__c                        = item.QT_sales;
        oli.LAT_UnitPrice__c                       = item.Vl_Valor;
        oli.LAT_Integration__c                   = true;
        oli.LAT_SkuText__c                  = item.Cd_product.trim();
        if(item.holdOrderCode != null){
            oli.LAT_Description__c                 = item.holdOrderCode.replace('-',' ');
        }
    }
}