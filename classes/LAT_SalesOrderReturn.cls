/************************************************************************************
*                           Company: ValueNet                                       *
*-----------------------------------------------------------------------------------*
*   Metodo de interfaz para generacion de pedidos para Brasil, Argentina y Uruguay  *
************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public class LAT_SalesOrderReturn {
    
    private static  Set< Id > setRecTypeAcc = Global_RecordTypeCache.getRtIdSet('Account', new set<String>{'On_Trade', 
                                                                     'Off_Trade', 
                                                                     'Eventos',
                                                                    'LAT_Distribucao_Com_Faturamento',
                                                                    'LAT_Off_Trade_Sem_Faturamento',
                                                                    'LAT_Off_Trade_Faturamento',
                                                                    'LAT_On_Line_Com_Faturamento',
                                                                    'LAT_On_Trade_Venda_Directa',
                                                                    'LAT_On_Trade_Sem_Pagamento',
                                                                    'LAT_On_Trade_Com_Pagamento',
                                                                    'LAT_Eventos_VendaDirecta',
                                                                    'LAT_Eventos_com_pagamento',
                                                                    'LAT_Eventos_sem_pagamento', 'ACC_1_OffTrade_ARG', 'ACC_2_OffTrade_URU', 'ACC_3_OnTrade_ARG', 'ACC_4_OnTrade_URU', 'ACC_5_Events_ARG', 'ACC_6_Events_URU'});
    private static final Set< Id > setRecTypeOpp = Global_RecordTypeCache.getRtIdSet('Opportunity', new set<String>{'Bloqueia_alteracao','Bloqueia_alteracao_do_cabecalho','Bloqueia_alteracao_do_cabecalho','Nova_oportunidade','OPP_1_NewOrder_ARG','OPP_2_NewOrder_URU','OPP_3_HeaderBlocked_ARG','OPP_4_HeaderBlocked_URU','OPP_5_OrderBlocked_ARG','OPP_6_OrderBlocked_URU'});
    private static final Set< Id > setRecTypePro = Global_RecordTypeCache.getRtIdSet('Product2', new set<String>{'BRA_Standard','Standard_UY','Standard_AR'});

    private static final Set< Id > setRecTypeOppLAT = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c', new set<String>{'Bloqueia_alteracao','Bloqueia_alteracao_do_cabecalho','Bloqueia_alteracao_do_cabecalho','Nova_oportunidade','OPP_1_NewOrder_ARG','OPP_2_NewOrder_URU','OPP_3_HeaderBlocked_ARG','OPP_4_HeaderBlocked_URU','OPP_5_OrderBlocked_ARG','OPP_6_OrderBlocked_URU'});
    private static final Set< Id > setRecTypeProLAT = Global_RecordTypeCache.getRtIdSet('LAT_Product__c', new set<String>{'BRA_Standard','Standard_UY','Standard_AR'});


    private static map<String, Id> mapPriceBookIdProdIdPriceBookEntry;
    private static map<String, Id> maplProdCode;
    
    private static map< String, Cota_regional__c > fCotasRegionaisUpdate;
    private static CotasRegionaisConsulta fCotaRegional;
    private static map<String, String> fMapSKUs;
    public static boolean shouldhaveException;

    //Variable in memory to hanlde recursive errores, and avoid 101 SOQL Limit at context execution. 
    public static Boolean isFirstContextCall = true;
 
    //MIGRATED 07/11/2016 
    public static Integer LAT_ETL_SalesOrderLoad(Integer Country, String cd_salesman, String NR_order_crm, Integer NR_order_JDE, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String companyCode, 
        String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, 
        String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderReturn.SalesOrderItem> listaItem){
        customer_AN8 = customer_AN8_entrega;
        String ClientCodeAN8 = Country+'-'+customer_AN8;
        System.debug('%%%%%%%%%%%%%%%%%%% query Client_country_AN8__c = '+ ClientCodeAN8+ ' AND RecordTypeId = ' +  setRecTypeAcc );
        List<Account> accList = [SELECT Id, Price_Group__c, CurrencyIsoCode, OwnerId, Owner.isActive FROM Account WHERE Client_country_AN8__c =: ClientCodeAN8 AND RecordTypeId =: setRecTypeAcc limit 1];
       
        String countryName = '';
        
        if(Country == 1){
            countryName = 'Brasil';
        }else if(Country == 5){
            countryName = 'Uruguay';
        }else if(Country == 6){
            countryName = 'Argentina';
        }  
               
        CS001_JDEInterfaceCredentials__c credentials = CS001_JDEInterfaceCredentials__c.getInstance(countryName); 
        
        User us = null;
        if(credentials != null && credentials.UserName__c != null){
            us = [SELECT Id, isActive FROM User WHERE UserName =: credentials.UserName__c];
        }    
        
        if(accList.isEmpty()){
            return SalesOrderReturn.notFound_client;
        }
        
        //to bypass the validation rule on items with status <= 540
        SalesOrderReturn.transactionOrigin = 'JDE';
      
        Savepoint sp = Database.setSavepoint();
        map< String, OpportunityLineItem > lItemMap = new map< String, OpportunityLineItem >();
        Opportunity opp;
        
        String JDEOrderKey;
        if(country != null && CD_Order_Type != null && NR_order_JDE != null && companyCode != null){
            JDEOrderKey = country+'-'+CD_Order_Type.trim()+'-'+NR_order_JDE+'-'+companyCode.trim();
        }
        
        String NR_order_JDE_Str;
        if(NR_order_JDE != null){
            NR_order_JDE_Str = String.valueOf(NR_order_JDE);
        }
        System.debug('%%%%%%%%%%%%%%%%% SalesOrder_Source '+ SalesOrder_Source + ' trim = true? '+SalesOrder_Source.trim().equalsIgnoreCase( 'C' ));
        if(!SalesOrder_Source.trim().equalsIgnoreCase( 'C' )){
            
            // Pedido não originário no Salesforce
            List<Opportunity> oppL = [SELECT OwnerId, Owner.isActive, Account.Client_code_AN8__c, NR_customer_order__c, DS_Message1__c, DS_Message2__c, DT_delivery__c, 
                                             Freight__c, CloseDate, type, CD_order_status__c, Account.Business_Unit__c, NR_order_JDE__c, Account.Regional__r.Id, 
                                             Account.Channel__c, Account.Sub_Channel__c, Account.Customer_Flag__r.Id, AccountId, Grupo_de_precos__c, pricebook2id
                                      FROM Opportunity
                                      WHERE LAT_JDEOrderKey__c =: JDEOrderKey AND RecordTypeId =: setRecTypeOpp LIMIT 1];
           
            if(oppL.isEmpty()){
                opp = new Opportunity();
                opp.Name = NR_order_JDE_Str;
                opp.StageName = 'Pedido com erro no JDE';
                opp.CloseDate = SalesOrderReturn.convertToDate(DT_Order);
                opp.NR_customer_order__c = NR_customer_order;
                opp.DS_Message1__c = DS_message1;
                opp.DS_Message2__c = DS_message2;
            }else{
                opp = oppL[0];
                List <OpportunityLineItem> oldItems = [SELECT id, PricebookEntryId, Integracao__c, Remover__c, Quantity, NR_order_line__c, QT_Bonus__c, Discount, Discount_AR__c, cd_line_status__c, Descricao_do_status__c, UnitPrice, OpportunityId, Campo_de_formatacao__c, LAT_SkuText__c FROM OpportunityLineItem WHERE OpportunityId=:opp.id];
                if(!oldItems.isEmpty()){
                    for(OpportunityLineItem lItem : oldItems){
                        lItemMap.put( lItem.NR_order_line__c, lItem);
                    }
                }
            }
            
            opp.Accountid = accList[0].id;
                    
            opp.CurrencyIsoCode = accList[0].CurrencyIsoCode;
                        
            if(cd_salesman != null && cd_salesman.trim().length() > 0){
                opp.Owner.C_digo_JDE__c = cd_salesman;
            }
              
            if(SalesOrder_Source.trim().equalsIgnoreCase('E')){
                opp.Origem_do_pedido__c = 'EDI';
            }else{
                opp.Origem_do_pedido__c = 'JDE';
            }
            
            opp.Integracao__c = true;
        }else{   
            
            List<Opportunity> oppL = [SELECT OwnerId, Owner.isActive, Account.Client_code_AN8__c, NR_customer_order__c, DS_Message1__c, DS_Message2__c, DT_delivery__c, 
                                             Freight__c, CloseDate, type, CD_order_status__c, Account.Business_Unit__c, NR_order_JDE__c, 
                                             Account.Regional__r.Id, Account.Channel__c, Account.Sub_Channel__c, Account.Customer_Flag__r.Id, 
                                             AccountId, RecordType.Name, Grupo_de_precos__c, pricebook2id
                                      FROM Opportunity
                                      WHERE Id =: String.valueOf(NR_order_crm.trim()) AND RecordTypeId =: setRecTypeOpp LIMIT 1];
            
            if(oppL.isEmpty()) {
                Database.rollback(sp);
                return SalesOrderReturn.notFound_opportunity;
            }
            
            opp = oppL[0];
            opp.Integracao__c = true;
            opp.Integracao_Retorno_JDE__c = returnMessage;
            
            if(returnCode != 0){
                opp.StageName = 'Pedido com erro no JDE';
                
                if(opp.RecordType.Name.endsWith('ARG')) {
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_3_HeaderBlocked_ARG' );
                }else if(opp.RecordType.Name.endsWith('URU')) {
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_4_HeaderBlocked_URU' );
                }else{
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'Bloqueia_alteracao_do_cabecalho' );
                }
                upsert opp;
                return SalesOrderReturn.success;
            }
            
            List<OpportunityLineItem> oldItems = [SELECT id, PricebookEntryId, Integracao__c, Remover__c, Quantity, NR_order_line__c, QT_Bonus__c, Discount, Discount_AR__c, cd_line_status__c, Descricao_do_status__c, UnitPrice, OpportunityId, Campo_de_formatacao__c, LAT_SkuText__c FROM OpportunityLineItem WHERE OpportunityId=:opp.id];
            //loadData( oldItems );
            
            if(oldItems.size() > 0){
                for( opportunityLineItem itemLine : oldItems ){
                    if ( itemLine.NR_order_line__c == null ){
                        lItemMap.put( itemLine.LAT_SkuText__c, itemLine );
                    }else{
                        lItemMap.put( itemLine.NR_order_line__c, itemLine );
                    }
                }
            }
            if (opp.Origem_do_pedido__c != 'APP'){
                opp.Origem_do_pedido__c = 'CRM';
            }
        }
        
        //si el owner del pedido esta inactivo lo reasigno al del cliente o al del custom setting. si ninguno esta activo se devuelve el return code
        if(!opp.owner.isActive){
            if(accList[0].Owner.isActive){
                opp.OwnerId = accList[0].OwnerId;
            }else if(us != null && us.isActive){
                opp.OwnerId = us.Id;
            }else{
                return SalesOrderReturn.inactiveClientOwner;
            }
        }
      
        opp.NR_order_JDE__c = NR_order_JDE_Str;
        opp.AccountId = accList[ 0 ].id;
        opp.NR_customer_order__c = NR_customer_order;
        opp.DS_Message1__c = DS_message1;
        opp.DS_Message2__c = DS_message2;
        opp.DT_delivery__c = SalesOrderReturn.convertToDate( DT_delivery );
        opp.Freight__c = Freight;
        opp.CloseDate = SalesOrderReturn.convertToDate( DT_Order );
        opp.Pais__c = Country;
        opp.Campo_de_formatacao__c = utils.decodeString( priceComponents, true );

        opp.LAT_RawPriceComponents__c = priceComponents;
        opp.LAT_CompanyCode__c = companyCode;
        
        //Brasil
        if (Country == 1) {
            opp.CD_order_status__c = cd_order_status;
        }
        
        List< OpportunityLineItem > listItem = new List< OpportunityLineItem >();
      
        Boolean lItemAberto = false;
        Boolean isOppCanceledAR = true;
        Boolean isBackorderAR = false;
        
        Map<String,String> mapCdPaymentTerm = new Map<String,String>();
        set<String> setlProdCode = new set<String>();
        String InternalIdUDC1;
        for(SalesOrderReturn.SalesOrderItem item : listaItem){
            setlProdCode.add(getlProdCode(String.valueOf(Country), accList[0].Price_Group__c, String.valueOf(item.Cd_product).trim(), item.cd_payment_term ));
            InternalIdUDC1 = country + '-' + item.cd_payment_term + '-CRM-PT';
            mapCdPaymentTerm.put(InternalIdUDC1, null);
        }
        
        if(!mapCdPaymentTerm.isEmpty()){           
            List<UDC__c> listUDC = [SELECT Id, CodDefUsuario__c, Internal_Id__c, Name, RecordTypeId FROM UDC__c WHERE Internal_Id__c IN: mapCdPaymentTerm.keySet()];
            if(!listUDC.isEmpty()){
                for(UDC__c udc: listUDC){
                    if(mapCdPaymentTerm.containsKey(udc.Internal_Id__c)){
                        mapCdPaymentTerm.put(udc.Internal_Id__c, udc.Name);
                    }
                }
            }
        }
        
        set<Id> setProductIds = new set<Id>();
        maplProdCode = new map<String, Id>();
        
        for(Product2 prodL: [SELECT id, Internal_id__c FROM Product2 WHERE Internal_id__c IN: setlProdCode AND RecordTypeId =: getRTId(String.valueOf(Country))]){
            maplProdCode.put(prodL.Internal_id__c, prodL.Id);
            setProductIds.add(prodL.Id);
        }


        Id priceBookId;
        List< Pricebook2 > priceL = [select id from Pricebook2 where isStandard = true];
        if(!priceL.isEmpty()){
            priceBookId = priceL[0].Id;
        }
      
        mapPriceBookIdProdIdPriceBookEntry = new map<String, Id>();
        //JPC: added a list of PriceBookEntry to enable if neccesary to insert a new opportunity from JDE and disable after the insert.
        List<PricebookEntry> listPBEtoActivate = new List<PricebookEntry>(); 
        for(PricebookEntry entryL: [Select Id, Pricebook2Id, Product2Id, UnitPrice, isActive from PricebookEntry where Pricebook2Id=:priceBookId and Product2Id IN:setProductIds AND CurrencyIsoCode =: accList[0].CurrencyIsoCode]){
            mapPriceBookIdProdIdPriceBookEntry.put(entryL.Pricebook2Id+'-'+entryL.Product2Id, entryL.Id);
            if (!entryL.isActive) { 
                listPBEtoActivate.add(entryL);
            }
        }

        Integer contCancel = 0;
        Integer contFacturado = 0;
        Integer contAprobacion = 0;
        Integer contDelivered = 0;
       
        for(SalesOrderReturn.SalesOrderItem item : listaItem){
            boolean lIsNew = false;
            OpportunityLineItem newItem  = lItemMap.remove( String.valueOf( item.NR_order_line_jde ) );
            if(newItem == null) newItem = lItemMap.remove( String.valueOf( item.Cd_product ).trim() );
            if ( newItem == null ){
                newItem = new OpportunityLineItem();
                lIsNew = true;
            }
            
            Id produto = maplProdCode.get(getlProdCode(String.valueOf(Country), accList[0].Price_Group__c, String.valueOf(item.Cd_product).trim(), item.cd_payment_term ));
            system.debug('####' + produto);
            if ( produto != null ){
                
                if (item.realDeliveryDate != null) {
                  newItem.LAT_MX_RealDeliveryDate__c = SalesOrderReturn.convertToDate(item.realDeliveryDate);
                }

                if(priceBookId == null){
                    Database.rollback(sp);
                    return SalesOrderReturn.notFound_priceBook;
                }
                
                Id entry = mapPriceBookIdProdIdPriceBookEntry.get(priceBookId+'-'+produto);
                if(entry == null){
                    Database.rollback(sp);
                    return SalesOrderReturn.notFound_priceBookEntry;
                }
        
                if ( lIsNew ){
                    newItem.PricebookEntryId = entry;
                    newItem.OpportunityId = opp.id;
                }
                newItem.NR_order_line__c = String.valueOf( item.NR_order_line_jde );
                newItem.Quantity = item.QT_sales;
                newItem.QT_Bonus__c = item.QT_Bonus;
                
                String InternalIdUDC2 = country + '-' + item.cd_payment_term + '-CRM-PT';
                if(mapCdPaymentTerm.containsKey(InternalIdUDC2)){
                    newItem.LAT_PaymentConditionDescription__c = mapCdPaymentTerm.get(InternalIdUDC2);  
                }
                
                //Brasil
                if (Country == 1) {
                    newItem.Discount = item.pc_discount / 1000;                    
                    if(item.orderLineStatusDescription != null && item.orderLineStatusDescription != ''){
                        if(item.orderLineStatusDescription.startsWithIgnoreCase('Cancelado')){
                            contCancel++;
                        }else if(item.orderLineStatusDescription.startsWithIgnoreCase('Faturado') 
                                || item.orderLineStatusDescription.startsWithIgnoreCase('Facturado') 
                                || item.orderLineStatusDescription.startsWithIgnoreCase('Contabilizado')){
                            contFacturado++;
                        }else if(item.orderLineStatusDescription.contains('Aprovação')) {
                            contAprobacion++;
                        }
                    }
                    if (item.realDeliveryDate != null && item.realDeliveryDate != '') {
                        contDelivered++;
                    } 
                }else if (country == 5 || country == 6){
                    //Uruguay, Argentina
                    newItem.Discount_AR__c = item.pc_discount / 1000;
                }else{
                    //Otros
                    newItem.Discount = item.pc_discount / 1000;
                }
                
                newItem.cd_line_status__c = item.cd_line_status;
                newItem.Descricao_do_status__c = item.orderLineStatusDescription; 
                newItem.UnitPrice = item.Vl_Valor;
                newItem.LAT_SkuText__c = item.Cd_product.trim();
                
                if (item.orderLineStatusDescription.startsWith('Cancelado')){newItem.UnitPrice = 0;}
                newItem.Campo_de_formatacao__c = ' ';
                
                 //Brasil
                if (Country == 1) {
                    newItem.Campo_de_formatacao__c = Utils.decodeString( item.priceComponents, false );
                    newItem.LAT_RawLinePriceComponents__c = item.priceComponents;
                } else if (country == 5 || country == 6) {
                    //Uruguay, Argentina
                    newItem.Campo_de_formatacao__c = Utils.decodeStringWithDiscount( item.priceComponents, false );
                    newItem.LAT_RawLinePriceComponents__c = item.priceComponents;
                }
                newItem.Integracao__c = true;
                listItem.add( newItem );
                
                //Brasil
                if (Country == 1) {
                    if(!lItemAberto){
                        lItemAberto = item.cd_line_status <> '999';
                    }
                }else if(country == 5 || country == 6){
                    //Uruguay, Argentina
                    if (!item.orderLineStatusDescription.startsWith('Cancelado')) {
                        isOppCanceledAR = false;
                    }
                    
                    newItem.UOM_AR__c = item.CD_unit;
                    if (item.holdOrderCode != null) {
                        newItem.Description = item.holdOrderCode.replace('-',' ');
                        
                        if (item.holdOrderCode != '') {
                            isBackorderAR = true;
                        }
                    }
                    
                    if ( !lItemAberto ) {
                        try {
                            integer intStatus = Integer.valueOf(item.cd_line_status);
                            lItemAberto = (intStatus <= 540);
                        } catch (Exception ex) {
                            System.debug('%%% Error en LAT_SalesOrderReturn : ' + ex);
                        }
                    }
                }
            }else{
                if(!item.orderLineStatusDescription.startsWith('Cancelado')){
                    Database.rollback(sp);
                    return SalesOrderReturn.notFound_product;
                }
            }
        }
        
        if(!listPBEtoActivate.isEmpty()){
            SalesOrderReturn.activatesPricebookEntrys(listPBEtoActivate);
        }
        
        if (country == 5 || country == 6) {
            if(isBackorderAR){
                opp.CD_order_status__c = 1;
                opp.CD_order_status_country__c = 5; //5 is for the workflow in spanish: Retained order AR
            }else{
                opp.CD_order_status__c = 0;
                opp.CD_order_status_country__c = null;  
            }
        }
        opp.StageName = 'Pedido processado no JDE';
        opp.Integracao__c = true;
        
        //Brasil
        if (Country == 1) {
            if (lItemAberto && SalesOrder_Source.trim().equalsIgnoreCase( 'C' ) )  {
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'Bloqueia_alteracao_do_cabecalho' );
            }else{
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'Bloqueia_alteracao' );
                opp.Type = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
            }

            if(contFacturado != 0 && contFacturado != listaItem.size()){
               opp.StageName = 'Partially billed';
               opp.Probability = 90;
            } else if(contFacturado == listaItem.size()){
               opp.StageName = 'Totally billed';
               opp.Probability = 100;
            } else if(contCancel == listaItem.size()){
               opp.StageName = 'Pedido cancelado no JDE';
               opp.Probability = 0;
            } else if(contAprobacion == listaItem.size()){
               opp.StageName = 'Pedido em Aprovação';
            }
            system.debug('6666666 '+ contDelivered +listaItem.size() );
            if (contDelivered > 0) {
                if (contDelivered == listaItem.size()) {
                    opp.StageName = 'Totally Delivered';
                } else {
                    opp.StageName = 'Partially Delivered';
                }
            }
            
            system.debug('listaItem: ' + listaItem.size());
        }else if (country == 5) {
            //Uruguay
            if (isOppCanceledAR) {
                opp.StageName = 'Pedido cancelado no JDE';
            }
            
            opp.Type = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
            
            
            if(lItemAberto){
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_4_HeaderBlocked_URU' );
            }else{
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_6_OrderBlocked_URU' );
            }
        }else if(country == 6) {
            //Argentina
            if (isOppCanceledAR) {
                opp.StageName = 'Pedido cancelado no JDE';
            }
            
            opp.Type = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
            
            if(lItemAberto){
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_3_HeaderBlocked_ARG' );
            }else{
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_5_OrderBlocked_ARG' );
            }
        }
        
        if (opp.id != null && country == 1) {
            for(OpportunityLineItem oli: listItem){
                if(oli.OpportunityId == null){
                    oli.OpportunityId = opp.id;
                }
            }
            upsert listItem;
            isFirstContextCall = true;
            upsert opp;
        } else {
            upsert opp;
    
            for(OpportunityLineItem oli: listItem){
                if(oli.OpportunityId == null){
                    oli.OpportunityId = opp.id;
            }
            }
            upsert listItem; 
        }

        try{
            if(Country == 1){
                isFirstContextCall = false;
                LAT_Cota.consumeReturn(listItem);
            }
        }catch (Exception ex) {
            LAT_DebugUtil debugUtil = new LAT_DebugUtil();
            debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
            System.debug('%%%%%% Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());

            debugUtil.setOrigin('Consumo Cotas');
            debugUtil.insertDebug();
        }

        
        
        return SalesOrderReturn.success;
        
    }


public static Integer LAT_ETL_SalesOrderLoadMigrated(Integer Country, String cd_salesman, String NR_order_crm, Integer NR_order_JDE, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String companyCode, 
        String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, 
        String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderReturn.SalesOrderItem> listaItem){        


        customer_AN8 = customer_AN8_entrega;
        String ClientCodeAN8 = Country+'-'+customer_AN8;
        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   1.');
        List<Account> accList = [SELECT Id, Price_Group__c, CurrencyIsoCode, OwnerId, Owner.isActive FROM Account WHERE Client_country_AN8__c =: ClientCodeAN8 AND RecordTypeId =: setRecTypeAcc limit 1];
       
        String countryName = '';
        
        if(Country == 1){
            countryName = 'Brasil';
        }else if(Country == 5){
            countryName = 'Uruguay';
        }else if(Country == 6){
            countryName = 'Argentina';
        }  
               
        CS001_JDEInterfaceCredentials__c credentials = CS001_JDEInterfaceCredentials__c.getInstance(countryName); 
        
        User us = null;
        if(credentials != null && credentials.UserName__c != null){
            us = [SELECT Id, isActive FROM User WHERE UserName =: credentials.UserName__c];
        }    
        
        if(accList.isEmpty()){
            return SalesOrderReturn.notFound_client;
        }
        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   2.');
        
        //to bypass the validation rule on items with status <= 540
        SalesOrderReturn.transactionOrigin = 'JDE';
      
        //Savepoint sp = Database.setSavepoint();
        map< String, LAT_OpportunityLineItem__c > lItemMap = new map< String, LAT_OpportunityLineItem__c >();
        LAT_Opportunity__c opp;
        
        String JDEOrderKey;
        if(country != null && CD_Order_Type != null && NR_order_JDE != null && companyCode != null){
            JDEOrderKey = country+'-'+CD_Order_Type.trim()+'-'+NR_order_JDE+'-'+companyCode.trim();
        }
        
        String NR_order_JDE_Str;
        if(NR_order_JDE != null){
            NR_order_JDE_Str = String.valueOf(NR_order_JDE);
        }
        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   3.');
        
        if(!SalesOrder_Source.trim().equalsIgnoreCase( 'C' ) || String.valueOf(NR_order_crm.trim()).startsWith('006')){
            
            // Pedido não originário no Salesforce
            List<LAT_Opportunity__c> oppL = [SELECT Owner.Id, Owner.isActive, LAT_Account__r.Client_code_AN8__c, LAT_NRCustomerOrder__c, LAT_DSMessage1__c, LAT_DSMessage2__c,                                          LAT_DTDelivery__c, LAT_EDI_NeedsToAdvanceStatus__c,
                                             LAT_Freight__c, LAT_CloseDate__c, LAT_Type__c, LAT_CDOrderStatus__c, LAT_Account__r.Business_Unit__c, LAT_NROrderJDE__c, LAT_Account__r.Regional__r.Id, 
                                             LAT_Account__r.Channel__c, LAT_Account__r.Sub_Channel__c, LAT_Account__r.Customer_Flag__r.Id, LAT_Account__c, LAT_AccountPriceBook__c
                                      FROM LAT_Opportunity__c
                                      WHERE LAT_JDEOrderKey__c =: JDEOrderKey AND RecordTypeId =: setRecTypeOppLAT LIMIT 1];
            
            System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   4.');
            if(oppL.isEmpty()){
                opp = new LAT_Opportunity__c();
                opp.Name = NR_order_JDE_Str;
                opp.LAT_StageName__c = 'Pedido com erro no JDE';
                opp.LAT_CloseDate__c = SalesOrderReturn.convertToDate(DT_Order);
                opp.LAT_NRCustomerOrder__c = NR_customer_order;
                opp.LAT_DSMessage1__c = DS_message1;
                opp.LAT_DSMessage2__c = DS_message2;
                opp.LAT_Type__c = CD_Order_Type;
            }else{
                opp = oppL[0];
                List <LAT_OpportunityLineItem__c> oldItems = [SELECT id, LAT_Integration__c, LAT_Remover__c, LAT_Quantity__c, LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Discount__c, LAT_AR_Discount__c, LAT_CdLineStatus__c, LAT_StatusDescription__c, LAT_UnitPrice__c, LAT_Opportunity__c, LAT_FormatField__c, LAT_SkuText__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c=:opp.id];
                if(!oldItems.isEmpty()){
                    for(LAT_OpportunityLineItem__c lItem : oldItems){
                        lItemMap.put( lItem.LAT_NROrderLine__c, lItem);
                    }
                }
            }
            
            opp.LAT_Account__c = accList[0].id;                        
            opp.CurrencyIsoCode = accList[0].CurrencyIsoCode;
                        
            if(cd_salesman != null && cd_salesman.trim().length() > 0){
                User uOwner = (User)opp.Owner;
                uOwner.C_digo_JDE__c = cd_salesman;
            }
              
            if(SalesOrder_Source.trim().equalsIgnoreCase('E')){
                opp.LAT_OrderOrigin__c = 'EDI';
                System.debug('%%%%% retentionReason : ' + retentionReason);
                if(LAT_GeneralConfig__c.getInstance('LAT_BR_FlexEDI_Enabled').LAT_Value__c == 'true'){
                    opp.LAT_IsOnHoldEDI__c = retentionReason == 'FI';
                    //Si el pedido está marcado como para avanzar status, me fijo que no tenga código de retencion y que todas las lineas estén en 535,
                    //si están todas en 535, envio a Bridge el request para avanzar el status a 540.
                    if(opp.LAT_EDI_NeedsToAdvanceStatus__c){
                        if(retentionReason == null) retentionReason = '';
                        if(retentionReason.trim() == ''){

                            Boolean is535 = true;
                            for(SalesOrderReturn.SalesOrderItem item : listaItem){
                                System.debug('%%%%% item.cd_line_status || item.nextStatus : ' + item.cd_line_status + ' || '+ item.nextStatus);
                                if(item.cd_line_status==null) 
                                    item.cd_line_status = item.nextStatus ;
                                if(item.cd_line_status != '535')
                                    is535 = false;
                            }

                            if(is535) {
                                LAT_BridgeGS1_Order.executeEDI_SORDRSP(opp.Id, '540');
                                opp.LAT_EDI_NeedsToAdvanceStatus__c = false;
                            }
                            System.debug('%%%%% is535 : ' + is535);
                        }
                    }
                }
                
            } else if(SalesOrder_Source.trim().equalsIgnoreCase('C')){
                opp.LAT_OrderOrigin__c = 'CRM';
            }else{
                opp.LAT_OrderOrigin__c = 'JDE';
            }
            
            opp.LAT_Integration__c = true;
        }else{   
            
            List<LAT_Opportunity__c> oppL = [SELECT OwnerId,CurrencyIsoCode, Owner.isActive, LAT_Account__r.Client_code_AN8__c, LAT_NRCustomerOrder__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_DTDelivery__c, 
                                             LAT_Freight__c, LAT_CloseDate__c, LAT_Type__c, LAT_CDOrderStatus__c, LAT_Account__r.Business_Unit__c, LAT_NROrderJDE__c, 
                                             LAT_Account__r.Regional__r.Id, LAT_Account__r.Channel__c, LAT_Account__r.Sub_Channel__c, LAT_Account__r.Customer_Flag__r.Id, 
                                             LAT_Account__c, RecordType.Name, LAT_AccountPriceBook__c 
                                      FROM LAT_Opportunity__c
                                      WHERE Id =: String.valueOf(NR_order_crm.trim()) AND RecordTypeId =: setRecTypeOppLAT LIMIT 1];
            
            System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   5.');
            if(oppL.isEmpty()) {
                //Database.rollback(sp);
                return SalesOrderReturn.notFound_opportunity;
            }
            
            opp = oppL[0];
            opp.LAT_Integration__c = true;
            opp.LAT_JDEIntegrationReturn__c = returnMessage;
            
            if(returnCode != 0){
                opp.LAT_StageName__c = 'Pedido com erro no JDE';
                
                if(opp.RecordType.Name.endsWith('ARG')) {
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_3_HeaderBlocked_ARG' );
                }else if(opp.RecordType.Name.endsWith('URU')) {
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_4_HeaderBlocked_URU' );
                }else{
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'Bloqueia_alteracao_do_cabecalho' );
                }
                upsert opp;
                return SalesOrderReturn.success;
            }
            
            List<LAT_OpportunityLineItem__c> oldItems = [SELECT id, LAT_Integration__c, LAT_Remover__c, LAT_Quantity__c, LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Discount__c, LAT_AR_Discount__c, LAT_CdLineStatus__c, LAT_StatusDescription__c, LAT_UnitPrice__c, LAT_Opportunity__c, LAT_FormatField__c, LAT_SkuText__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c=:opp.id];
            //loadData( oldItems );
            
            if(oldItems.size() > 0){
                for( LAT_OpportunityLineItem__c itemLine : oldItems ){
                    if ( itemLine.LAT_NROrderLine__c == null ){
                        lItemMap.put( itemLine.LAT_SkuText__c, itemLine );
                    }else{
                        lItemMap.put( itemLine.LAT_NROrderLine__c, itemLine );
                    }
                }
            }
            //if (opp.LAT_OrderOrigin__c != 'APP'){
              //  opp.LAT_OrderOrigin__c = 'CRM';
            //}
        }
        
        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   6.');
        //si el owner del pedido esta inactivo lo reasigno al del cliente o al del custom setting. si ninguno esta activo se devuelve el return code
        if(!opp.Owner.isActive){
            if(accList[0].Owner.isActive){
                opp.OwnerId = accList[0].OwnerId;
            }else if(us != null && us.isActive){
                opp.OwnerId = us.Id;
            }else{
                return SalesOrderReturn.inactiveClientOwner;
            }
        }
      
        opp.LAT_NROrderJDE__c = NR_order_JDE_Str;
        opp.LAT_Account__c = accList[ 0 ].id;
        opp.LAT_NRCustomerOrder__c = NR_customer_order;
        opp.LAT_DSMessage1__c = DS_message1;
        opp.LAT_DSMessage2__c = DS_message2;
        opp.LAT_DTDelivery__c = SalesOrderReturn.convertToDate( DT_delivery );
        opp.LAT_Freight__c = Freight;
        opp.LAT_CloseDate__c = SalesOrderReturn.convertToDate( DT_Order );
        opp.LAT_Country__c = Country;
        opp.LAT_FormatField__c = utils.decodeString( priceComponents, true );
        opp.LAT_RawPriceComponents__c = priceComponents;
        opp.LAT_CompanyCode__c = companyCode;
        
        //Brasil
        if (Country == 1) {
            opp.LAT_CDOrderStatus__c = cd_order_status;
        }
        
        List< LAT_OpportunityLineItem__c > listItem = new List< LAT_OpportunityLineItem__c >();
      
        Boolean lItemAberto = false;
        Boolean isOppCanceledAR = true;
        Boolean isBackorderAR = false;
        
        Map<String,String> mapCdPaymentTerm = new Map<String,String>();
        set<String> setlProdCode = new set<String>();
        String InternalIdUDC1;
        for(SalesOrderReturn.SalesOrderItem item : listaItem){
            if(item.NR_order_line_jde==null) item.NR_order_line_jde = item.lineNumber ;
            if(item.Cd_product==null) item.Cd_product = item.sku ;
            if(item.QT_sales==null) item.QT_sales = item.billedTotalQuantity ;
            if(item.QT_Bonus==null) item.QT_Bonus = item.bonusQuantity ;
            if(item.Vl_Valor ==null) item.Vl_Valor = item.totalCost ;
            if(item.cd_payment_term==null) item.cd_payment_term = item.paymentTerm ;
            if(item.CD_unit==null) item.CD_unit = item.salesUOM ;
            if(item.cd_line_status==null) item.cd_line_status = item.nextStatus ;
            if(item.holdOrderCode==null) item.holdOrderCode = item.backOrder ;
            if(item.cd_line_last_status==null) item.cd_line_last_status = item.lastStatus ;


            setlProdCode.add(getlProdCode(String.valueOf(Country), accList[0].Price_Group__c, String.valueOf(item.Cd_product).trim(), item.cd_payment_term ));
            InternalIdUDC1 = country + '-' + item.cd_payment_term + '-CRM-PT';
            mapCdPaymentTerm.put(InternalIdUDC1, null);
        }
        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   7.');
        
        if(!mapCdPaymentTerm.isEmpty()){           
            List<UDC__c> listUDC = [SELECT Id, CodDefUsuario__c, Internal_Id__c, Name, RecordTypeId FROM UDC__c WHERE Internal_Id__c IN: mapCdPaymentTerm.keySet()];
            if(!listUDC.isEmpty()){
                for(UDC__c udc: listUDC){
                    if(mapCdPaymentTerm.containsKey(udc.Internal_Id__c)){
                        mapCdPaymentTerm.put(udc.Internal_Id__c, udc.Name);
                    }
                }
            }
        }
        
        set<Id> setProductIds = new set<Id>();
        maplProdCode = new map<String, Id>();
        
        for(LAT_Product__c prodL: [SELECT id, LAT_ExternalID__c FROM LAT_Product__c WHERE LAT_ExternalID__c IN: setlProdCode AND RecordTypeId =: getRTIdLAT(String.valueOf(Country))]){
            maplProdCode.put(prodL.LAT_ExternalID__c, prodL.Id);
            setProductIds.add(prodL.Id);
        }


       

        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated  8.');
        Integer contCancel = 0;
        Integer contFacturado = 0;
        Integer contAprobacion = 0;
        Integer contDelivered = 0;
        
        LAT_OpportunityHandlerJSON pedidoJSON = new LAT_OpportunityHandlerJSON();
        pedidoJSON.detail = new List<LAT_OpportunityHandlerJSON.Detail>();
        LAT_OpportunityHandlerJSON.Header head = new LAT_OpportunityHandlerJSON.Header();
        head.isFlex = false;
        pedidoJSON.Header = head;
        
        for(SalesOrderReturn.SalesOrderItem item : listaItem){
            if(item.NR_order_line_jde==null) item.NR_order_line_jde = item.lineNumber ;
            if(item.Cd_product==null) item.Cd_product = item.sku ;
            if(item.QT_sales==null) item.QT_sales = item.billedTotalQuantity ;
            if(item.QT_Bonus==null) item.QT_Bonus = item.bonusQuantity ;
            if(item.Vl_Valor ==null) item.Vl_Valor = item.totalCost ;
            if(item.cd_payment_term==null) item.cd_payment_term = item.paymentTerm ;
            if(item.CD_unit==null) item.CD_unit = item.salesUOM ;
            if(item.cd_line_status==null) item.cd_line_status = item.nextStatus ;
            if(item.holdOrderCode==null) item.holdOrderCode = item.backOrder ;
            if(item.cd_line_last_status==null) item.cd_line_last_status = item.lastStatus ;

            if(item.cd_line_status < '535'){
                if(opp.LAT_IsOnHoldEDI__c){
                    opp.LAT_IsOnHoldEDI__c = false;
                }
            } 
            boolean lIsNew = false;
            LAT_OpportunityLineItem__c newItem  = lItemMap.remove( String.valueOf( item.NR_order_line_jde ) );
            if(newItem == null) newItem = lItemMap.remove( String.valueOf( item.Cd_product ).trim() );
            if ( newItem == null ){
                newItem = new LAT_OpportunityLineItem__c();
                lIsNew = true;
            }
            
            Id produto = maplProdCode.get(getlProdCode(String.valueOf(Country), accList[0].Price_Group__c, String.valueOf(item.Cd_product).trim(), item.cd_payment_term ));
            system.debug('####' + produto);
            if(produto != null){
                
                if (item.realDeliveryDate != null) {
                  newItem.LAT_MX_RealDeliveryDate__c = SalesOrderReturn.convertToDate(item.realDeliveryDate);
                }

               
                System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   9.');
               

                if( lIsNew ){
                    System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   9. IS NEW');
                    newItem.LAT_Opportunity__c = opp.id;
                    newItem.LAT_Product__c = produto;
                    newItem.LAT_CreatedFromJDE__c = true;
                    newItem.LAT_UnitCode__c = item.CD_unit;
                    newItem.LAT_PaymentCondition__c  = item.cd_payment_term;
                }
                newItem.CurrencyIsoCode = opp.CurrencyIsoCode;
                newItem.LAT_NROrderLine__c = String.valueOf( item.NR_order_line_jde );
                newItem.LAT_Quantity__c = item.QT_sales;
                newItem.LAT_QTBonus__c = item.QT_Bonus;
                
                String InternalIdUDC2 = country + '-' + item.cd_payment_term + '-CRM-PT';
                if(mapCdPaymentTerm.containsKey(InternalIdUDC2)){
                    newItem.LAT_PaymentConditionDescription__c = mapCdPaymentTerm.get(InternalIdUDC2);  
                }
                
                //Brasil
                if (Country == 1) {
                    System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   10.'); 
                    System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   10. item.pc_discount : ' + item.pc_discount); 
                    System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   10. item.percentualDiscount : ' + item.percentualDiscount);    
                    if(item.pc_discount != null) newItem.LAT_Discount__c = item.pc_discount / 1000;   

                    if(opp.LAT_OrderOrigin__c == 'EDI'){
                        if(newItem.LAT_AR_Discount__c == null || newItem.LAT_AR_Discount__c == 0){
                            newItem.LAT_AR_Discount__c = Utils.getFlexEdiDiscount(item.priceComponents);
                            
                        }

                    }
                    //if(item.percentualDiscount != null) newItem.LAT_AR_Discount__c = item.percentualDiscount / 100;
                    newItem.LAT_PriceEdi__c = item.customerPrice;//precio cliente EDI BRASIL
                    if((lIsNew || !newItem.LAT_JDEFlexReviewed__c) && newItem.LAT_AR_Discount__c != null && newItem.LAT_AR_Discount__c != 0) {
                        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   10. Se crea nueva linea flex a calcular el precio.'); 
                        newItem.LAT_IsFlex__c = true;
                        newItem.LAT_JDEFlexReviewed__c = true;
                        newItem.LAT_FlexNeedsValidation__c = true;
                        pedidoJSON.Header.isFlex = true;
                        LAT_OpportunityHandlerJSON.Detail nuevaLineaFlexToProcess = new LAT_OpportunityHandlerJSON.Detail();
                        nuevaLineaFlexToProcess.ID = String.valueOf( item.NR_order_line_jde );
                        nuevaLineaFlexToProcess.quantity = item.QT_sales;
                        nuevaLineaFlexToProcess.productSKU = item.Cd_product;
                        nuevaLineaFlexToProcess.paymentCondition = item.cd_payment_term;
                        nuevaLineaFlexToProcess.isFlex = true;
                        pedidoJSON.Detail.add(nuevaLineaFlexToProcess);
                    }   

                    if(item.orderLineStatusDescription != null && item.orderLineStatusDescription != ''){
                        if(item.orderLineStatusDescription.startsWithIgnoreCase('Cancelado')){
                            contCancel++;
                        }else if(item.orderLineStatusDescription.startsWithIgnoreCase('Faturado') 
                                || item.orderLineStatusDescription.startsWithIgnoreCase('Facturado') 
                                || item.orderLineStatusDescription.startsWithIgnoreCase('Contabilizado')){
                            contFacturado++;
                        }else if(item.orderLineStatusDescription.contains('Aprovação')) {
                            contAprobacion++;
                        }
                    }
                    if (item.realDeliveryDate != null && item.realDeliveryDate != '') {
                        contDelivered++;
                    } 
                }else if (country == 5 || country == 6){
                    //Uruguay, Argentina
                    newItem.LAT_AR_MaxDiscount__c = item.pc_discount / 1000;
                }else{
                    //Otros
                    newItem.LAT_Discount__c = item.pc_discount / 1000;
                }
                
                newItem.LAT_CdLineStatus__c = item.cd_line_status;
                newItem.LAT_StatusDescription__c = item.orderLineStatusDescription; 
                newItem.LAT_UnitPrice__c = item.Vl_Valor;
                newItem.LAT_SkuText__c = item.Cd_product.trim();
                
                if (item.orderLineStatusDescription.startsWith('Cancelado')){newItem.LAT_UnitPrice__c = 0;}
                newItem.LAT_FormatField__c = ' ';
                
                 //Brasil
                if (Country == 1) { 
                    newItem.LAT_FormatField__c = Utils.decodeString( item.priceComponents, false );
                    newItem.LAT_RawLinePriceComponents__c = item.priceComponents;

                    try {
                        Decimal amountNIS = Utils.getFlexAmount(item.priceComponents);
                        newItem.LAT_NisAmount__c = amountNIS;
                        System.debug('%%%%% amountFlex en LAT_SOR : ' + amountNIS);
                    } catch (Exception e) {
                        System.debug('%%% Error en LAT_SalesOrderReturn : ' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause());
                    }
                } else if (country == 5 || country == 6) {
                    //Uruguay, Argentina
                    newItem.LAT_FormatField__c = Utils.decodeStringWithDiscount( item.priceComponents, false );
                    newItem.LAT_RawLinePriceComponents__c = item.priceComponents;
                }
                newItem.LAT_Integration__c = true;
                listItem.add( newItem );
                
                //Brasil
                if (Country == 1) {
                    System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   11.');
                    if(!lItemAberto){
                        lItemAberto = item.cd_line_status <> '999';
                    }
                    newItem.LAT_EdiRetentionCode__c = item.holdOrderCode;
                } else if(country == 5 || country == 6){
                    //Uruguay, Argentina
                    if (!item.orderLineStatusDescription.startsWith('Cancelado')) {
                        isOppCanceledAR = false;
                    }
                    
                    newItem.LAT_AR_UOM__c = item.CD_unit;
                    if (item.holdOrderCode != null) {
                        newItem.LAT_Description__c = item.holdOrderCode.replace('-',' ');
                        
                        if (item.holdOrderCode != '') {
                            isBackorderAR = true;
                        }
                    }
                    
                    if ( !lItemAberto ) {
                        try {
                            integer intStatus = Integer.valueOf(item.cd_line_status);
                            lItemAberto = (intStatus <= 540);
                        } catch (Exception ex) {
                            System.debug('%%% Error en LAT_SalesOrderReturn : ' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
                        }
                    }
                }
            } else {
                if(!item.orderLineStatusDescription.startsWith('Cancelado')){
                    //Database.rollback(sp);
                    return SalesOrderReturn.notFound_product;
                }
            }
        }
        
      
        
        System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   12.');
        if (country == 5 || country == 6) {
            if(isBackorderAR){
                opp.LAT_CDOrderStatus__c = 1;
                opp.LAT_CDOrderStatusCountry__c = 5; //5 is for the workflow in spanish: Retained order AR
            }else{
                opp.LAT_CDOrderStatus__c = 0;
                opp.LAT_CDOrderStatusCountry__c = null;  
            }
        }
        opp.LAT_StageName__c = 'Pedido processado no JDE';
        opp.LAT_Integration__c = true;
        
        //Brasil
        if (Country == 1) {
            
            System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   13.');
            if (lItemAberto && SalesOrder_Source.trim().equalsIgnoreCase( 'C' ) )  {
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'Bloqueia_alteracao_do_cabecalho' );
            }else{
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'Bloqueia_alteracao' );
                opp.LAT_Type__c = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
            }

            if(contFacturado != 0 && contFacturado != listaItem.size()){
               opp.LAT_StageName__c = 'Partially billed';
               opp.LAT_Probability__c = 90;
            } else if(contFacturado == listaItem.size()){
               opp.LAT_StageName__c = 'Totally billed';
               opp.LAT_Probability__c = 100;
            } else if(contCancel == listaItem.size()){
               opp.LAT_StageName__c = 'Pedido cancelado no JDE';
               opp.LAT_Probability__c = 0;
            } else if(contAprobacion == listaItem.size()){
               opp.LAT_StageName__c = 'Pedido em Aprovação';
            }
            system.debug('6666666 '+ contDelivered +listaItem.size() );
            if (contDelivered > 0) {
                if (contDelivered == listaItem.size()) {
                    opp.LAT_StageName__c = 'Totally Delivered';
                } else {
                    opp.LAT_StageName__c = 'Partially Delivered';
                }
            }   

            //Si hay nuevas lineas creadas en JDE con Descuento, les calculo el Original Nis Amount.
            System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   13. pedidoJSON : ' + pedidoJSON);
            try{
                if(pedidoJSON.Header.isFlex) {
                    System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   13. entro porque es FLEX : ');
                    pedidoJSON.Header.deliveryDate = String.valueOf(Date.today());
                    pedidoJSON.header.account = opp.LAT_Account__c;
                    pedidoJSON.header.type_Z = CD_Order_Type;
                    // Sacamos este cálculo ya que de ahora en más esto se hace en Aquila.
                    //calcularOriginalNisAmountNewJDELine(pedidoJSON, listItem);
                }
            }catch(Exception e){
                System.debug('%%%% Exception 13. : '+e);
                System.debug('%%%% Exception 13. : '+e.getCause());
                System.debug('%%%% Exception 13. : '+e.getMessage());
                System.debug('%%%% Exception 13. : '+e.getStackTraceString());
            }
            
            
            system.debug('listaItem: ' + listaItem.size());
        }else if (country == 5) {
            //Uruguay
            if (isOppCanceledAR) {
                opp.LAT_StageName__c = 'Pedido cancelado no JDE';
            }
            
            opp.LAT_Type__c = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
            
            
            if(lItemAberto){
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_4_HeaderBlocked_URU' );
            }else{
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_6_OrderBlocked_URU' );
            }
        }else if(country == 6) {
            //Argentina
            if (isOppCanceledAR) {
                opp.LAT_StageName__c = 'Pedido cancelado no JDE';
            }
            
            opp.LAT_Type__c = SalesOrderReturn.getOrderType(Country, CD_Order_Type);
            
            if(lItemAberto){
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_3_HeaderBlocked_ARG' );
            }else{
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_5_OrderBlocked_ARG' );
            }
        }

        
        if (opp.id != null && country == 1) {
            for(LAT_OpportunityLineItem__c oli: listItem){
                if(oli.LAT_Opportunity__c == null){
                    oli.LAT_Opportunity__c = opp.id;
                }
            }
            upsert listItem;
            isFirstContextCall = true;
            upsert opp;
        } else {
            upsert opp;

            for(LAT_OpportunityLineItem__c oli: listItem){
                if(oli.LAT_Opportunity__c == null){
                    oli.LAT_Opportunity__c = opp.id;
            }
            }
            upsert listItem; 
        }

        try{
            if(Country == 1){
                isFirstContextCall = false;
                LAT_Cota.consumeReturn(listItem);
            }
        }catch (Exception ex) {
            System.debug('%%%%%%% en LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated   14.Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
            LAT_DebugUtil debugUtil = new LAT_DebugUtil();
            debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
            debugUtil.setOrigin('Consumo Cotas');
            debugUtil.insertDebug();
        }            
        
        return SalesOrderReturn.success;
    }


    
    
   

    private static Id getRTId( String aCountry){
        Id idRecTypeProd = Global_RecordTypeCache.getRtId(  'Product2'+'BRA_Standard' );
        if(aCountry == '5') {
            idRecTypeProd = Global_RecordTypeCache.getRtId( 'Product2'+'Standard_UY' );
        }else if (aCountry == '6') {
            idRecTypeProd = Global_RecordTypeCache.getRtId( 'Product2'+'Standard_AR' );
        }
        return idRecTypeProd;    
    }

    //MIGRATED 07/11/2016 
    private static Id getRTIdLAT( String aCountry){
        Id idRecTypeProd = Global_RecordTypeCache.getRtId(  'LAT_Product__c'+'BRA_Standard' );
        if(aCountry == '5') {
            idRecTypeProd = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_UY' );
        }else if (aCountry == '6') {
            idRecTypeProd = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_AR' );
        }
        return idRecTypeProd;    
    }
    
    private static String getlProdCode( String aCountry, String aGroup, String aProduct, String aPayTerm ){
        return getlProdCode(aCountry, aProduct);    
    }

    private static String getlProdCode( String aCountry, String aProduct){
        String lProdCode = aCountry +'-'+ aProduct;
        return lProdCode;    
    }
    
    public static void loadData(List < OpportunityLineItem > aItems){
        /*
        fMapSKUs = CotasRegionaisConsulta.getPriceEntryXSKU( aItems );
        fCotaRegional = new CotasRegionaisConsulta( fMapSKUs.values() );
        fCotasRegionaisUpdate = new map< String, Cota_regional__c >();
        */
    }
    
    public static void devolverCota( Opportunity aOpp, OpportunityLineItem aItem ){
    /*
      Cota_regional__c lCotaR = fCotaRegional.getCota( fMapSKUs.get( aItem.PricebookEntryId ), aOpp );
      if(lCotaR == null){
          return;
      }
      if(!fCotasRegionaisUpdate.containsKey( lCotaR.id ) ) fCotasRegionaisUpdate.put( lCotaR.id, lCotaR );
      */
    }
    
    public static void usarCota(Opportunity aOpp, OpportunityLineItem aItem){
        Account acc                           = null;
        UDC__c regional, bandeira, cidade, deposito     = null;
        Profile perfil                        = null;
        SKU__c sku                            = null;
        Criterio_nacional_de_cota__c critN    = null;
        Cota_nacional__c cotaN                = null;
        Cota_regional__c cotaR                = null;
        LAT_Opportunity__c opp                       = null;
        LAT_OpportunityLineItem__c oli               = null;
        User usuario                          = null;
        LAT_Product__c produto                      = null;
        List<RecordType> listRecType          = null;
        List<String> developerName            = null;
        Map<String, String> mapRecType        = null;
        String idAccount                      = null;
        String idOpportunity                  = null;
        /*
        Cota_regional__c lCotaR = fCotaRegional.getCota( fMapSKUs.get( aItem.PricebookEntryId ), aOpp );
        if(lCotaR == null){
            return;
        }
        if(lCotaR.Cota_utilizada__c == null ) lCotaR.Cota_utilizada__c = 0;
        if(!fCotasRegionaisUpdate.containsKey( lCotaR.id ) ) fCotasRegionaisUpdate.put( lCotaR.id, lCotaR);
        */
    }


    public static void calcularOriginalNisAmountNewJDELine(LAT_OpportunityHandlerJSON pedido, List<LAT_OpportunityLineItem__c> lineItems){

        Map<String, String> mapPriceCalculationResponse = LAT_BR_NewPriceCalculation(pedido, false);
        for(LAT_OpportunityLineItem__c oli : lineItems) {
            System.debug('%%%% en calcularOriginalNisAmountNewJDELine oli : ' + oli);
            if(oli.Id == null) {
                if(oli.LAT_IsFlex__c) {
                    System.debug('%%%% en calcularOriginalNisAmountNewJDELine es FLex');
                    oli.LAT_OriginalFlexAmount__c = 0;
                    System.debug('%%%% en calcularOriginalNisAmountNewJDELine oli.LAT_SkuText__c  -  oli.LAT_Quantity__ : ' + oli.LAT_SkuText__c + '-' + oli.LAT_Quantity__c);
                    System.debug('%%%% en calcularOriginalNisAmountNewJDELine mapPriceCalculationResponse : ' + mapPriceCalculationResponse);
                    
                    oli.LAT_OriginalNisAmount__c  = Decimal.valueOf(mapPriceCalculationResponse.get(oli.LAT_SkuText__c + '-' + oli.LAT_Quantity__c));
                    oli.LAT_OriginalUnitNisAmount__c = oli.LAT_OriginalNisAmount__c/oli.LAT_Quantity__c;
                    System.debug('%%%% en calcularOriginalNisAmountNewJDELine LAT_OriginalNisAmount__c : ' + oli.LAT_OriginalNisAmount__c);
                }
            }
            
        }

    }

    public static Map<String, String> LAT_BR_NewPriceCalculation(LAT_OpportunityHandlerJSON pedido, Boolean isFlex){

        LAT_DebugUtil debug = new LAT_DebugUtil();
        Map<String, String> returnMap = new Map<String, String>();
        String resp = '';
        
        Account acc = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c, Payment_Condition__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, LAT_Account__r.LAT_JDEZone__c FROM Account WHERE Id =:pedido.header.account LIMIT 1];
        if(acc == null) {
            returnMap.put('ERROR', 'Not Found Account.');
            return returnMap;
        }

        debug.addTitle('Header');
        debug.setOrigin('LAT_Rest_OpportunityFlex');
        debug.addData('Account.Client_code_AN8__c', String.ValueOf(acc.Client_code_AN8__c));        
        debug.addData('Account.Business_Unit_AR__r.CodDefUsuario__c', String.ValueOf(acc.Business_Unit_AR__r.CodDefUsuario__c));
        debug.addData('Type', String.ValueOf((pedido.header.type_Z != null && pedido.header.type_Z.length() > 2) ? pedido.header.type_Z.substring(0,2) : pedido.header.type_Z));

        //Mapeo de Header de pedido
        //PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
        LAT_BR_PriceCalculation.priceCatalogueHeaderInput header = new LAT_BR_PriceCalculation.priceCatalogueHeaderInput();
        Date delDate    = Date.valueOf(pedido.header.deliveryDate);
 
        String businessUnit                     = acc.Business_Unit_AR__r.CodDefUsuario__c;
        String ediTransactionType               = '';
        Datetime priceEffectiveDate             = delDate < date.today() ? date.today() : delDate;
        String paymentTerm                      = pedido.detail.get(0).paymentCondition;
        String countryCode                      = '1';
        Integer shipTo                          = Integer.valueOf(acc.Client_code_AN8__c);
        Integer soldTo                          = Integer.valueOf(acc.Client_code_AN8__c);
        Datetime taxEffectiveDate               = delDate < date.today() ? date.today() : delDate;
        String orderType                        = String.ValueOf((pedido.header.type_Z != null && pedido.header.type_Z.length() > 2) ? pedido.header.type_Z.substring(0,2) : pedido.header.type_Z);
        //Mapeo de los productos del pedido
        
        List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput> priceCatalogueDetails = new List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput>();
        for (LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
            if(oppItem.isFlex || !isFlex) {
                LAT_BR_PriceCalculation.priceCatalogueDetailsInput item = new LAT_BR_PriceCalculation.priceCatalogueDetailsInput();

                debug.addSubTitle('Item');
                debug.addData('productSKU', String.ValueOf(oppItem.productSKU));
                debug.addData('Quantity', String.ValueOf(oppItem.quantity));
                debug.addData('paymentCondition', String.ValueOf(oppItem.paymentCondition));
                item.secondItemNumber           = oppItem.productSKU;

                if (oppItem.measurementUnit == null || oppItem.measurementUnit.equalsIgnoreCase('')) {
                      item.unitOfMeasure        = 'CA';
                }
                else {
                      item.unitOfMeasure        = String.valueOf(oppItem.measurementUnit);
                }
                if(isFlex) {
                    item.ratePercentCashDiscount    = oppItem.discount;
                }
                
                item.quantityOrdered            = oppItem.quantity;
                item.paymentTerms               = oppItem.paymentCondition;
                priceCatalogueDetails.add(item);
            }
            
        }
        LAT_BR_PriceCalculation.priceCatalogueHeaderOutput response;
        try {

            system.debug('isRunningTest +++' + Test.isRunningTest());
            system.debug('exception +++' + shouldhaveException);
            if (Test.isRunningTest() && shouldhaveException != null && shouldhaveException){
                response = LAT_SalesOrderReturn_TEST.getMockResponse();
            } else {
                LAT_BR_PriceCalculation.PriceCatalogueManagerPort calloutClient = new LAT_BR_PriceCalculation.PriceCatalogueManagerPort();
                response = calloutClient.getPriceCatalogue(
                                                orderType,
                                                businessUnit,
                                                ediTransactionType,
                                                paymentTerm,
                                                priceCatalogueDetails,
                                                priceEffectiveDate,
                                                shipTo,
                                                soldTo,
                                                taxEffectiveDate,
                                                countryCode);
            }

            system.debug('Ernesto+++Answer+++++' + response);
            resp = String.valueOf(response);
        } catch(Exception e) {
            LAT_Log__c logAsRegistry = new LAT_Log__c();
            system.debug('%%%%%% Ernesto+++ Exception1' + e.getCause() + e.getStackTraceString());
            logAsRegistry.LAT_Account__c = pedido.header.account;
            logAsRegistry.LAT_OrderNumber__c = null;
            logAsRegistry.LAT_Opportunity2__c = null;
            logAsRegistry.LAT_Country__c = '1';
            logAsRegistry.LAT_ReturnTime__c = system.now();
            try {
                if(!Test.isRunningTest()) {
                    //insert logAsRegistry;
                }
                
            } catch(Exception e1) {
                system.debug(' %%%%% Ernesto+++ Exception1' + e.getCause() + e.getStackTraceString());
            }

            debug.addTitle('Unexpected Error');
            debug.addData('Error', e.getMessage());
            debug.setResult(label.LAT_MX_WS02_00003);
            if(!Test.isRunningTest()) {
                debug.insertDebug();
            }
            returnMap.put('ERROR', label.LAT_MX_WS02_00003);
            //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            return returnMap;
        }

        if (response == null) {
            system.debug('Ernesto+++ Exception23123');
            debug.setResult(label.LAT_MX_WS02_00003);
            if(!Test.isRunningTest()) {
                debug.insertDebug();
            }
            returnMap.put('ERROR', label.LAT_MX_WS02_00003);
            //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            return returnMap;
        }

        system.debug('Sigue+++');
        // Chequeo si se el retorno contiene un error, en caso afirmativo hay que loguear el error y retornar.
        if (response.errorRecords != null && response.errorRecords.size() > 0) {
            system.debug('Ernesto+++ Error de Negocio');
            debug.addTitle('Business Error');
            String retorno = '';
            for (LAT_BR_PriceCalculation.errorRecords e : response.errorRecords) {

                debug.addData('Error Code ', e.errorCode);
                debug.addData('Description ', e.errorDescription);
                retorno =  e.errorDescription;

            }
            if(!Test.isRunningTest()) {
                //debug.insertDebug();
            }
            returnMap.put('ERROR', retorno);
            //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            return returnMap;

        }

        Map<String, String> mapFlexAmountsBySku = new Map<String, String>();
  
        
        for (LAT_BR_PriceCalculation.priceCatalogueDetailsOutput respItem : response.priceCatalogueDetails) {
            Map<String, Decimal> mapAmountByPriceComponentName = new Map<String, Decimal>();
            for (LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discount: respItem.discountAndChargeDetails ) {
                Decimal aux = discount.amountDiscountOrCharge;
                String auxstr = discount.discountOrChargeGroup.trim();
                mapAmountByPriceComponentName.put(discount.discountOrChargeGroup.trim(), discount.amountDiscountOrCharge);
            }
            Decimal amountNis, amountNBASE3, amountICMS, amountPIS, amountCOFINS  = 0;

            if(mapAmountByPriceComponentName.get('NBASE3') != null) {
                amountNBASE3 = mapAmountByPriceComponentName.get('NBASE3');
            }

            if(mapAmountByPriceComponentName.get('ICMS') != null) {
                amountICMS = mapAmountByPriceComponentName.get('ICMS');
            }

            if(mapAmountByPriceComponentName.get('PIS') != null) {
                amountPIS = mapAmountByPriceComponentName.get('PIS');
            }

            if(mapAmountByPriceComponentName.get('COFINS') != null) {
                amountCOFINS = mapAmountByPriceComponentName.get('COFINS');
            }
            //NIS = NBASE3 – ICMS – PIS – COFINs
            //obtener los valores de los distintos componentes 
            if(amountNBASE3 != null) {
                amountNis = amountNBASE3;
                if(amountICMS != null){
                    amountNis -= amountICMS;
                }
                if(amountPIS != null){
                    amountNis -= amountPIS;
                } 
                if(amountCOFINS != null) {
                    amountNis -= amountCOFINS;
                }
            } 
            
            System.debug('%%%% SKU : ' + String.ValueOf(respItem.secondItemNumber).trim() + ' || NIS : ' + amountNis );
            System.debug('%%%% NBASE3 : ' + amountNBASE3 +' || ICMS : ' + amountICMS +' || PIS : ' + amountPIS +' COFIN : ' + amountCOFINS);

            String key = String.ValueOf(respItem.secondItemNumber).trim() + '-'  + respItem.quantityOrdered.setScale(0);
            System.debug('%%%%% key : ' + key);

            mapFlexAmountsBySku.put(key, String.valueOf(amountNis));
        }

        debug.addTitle('Response');
        system.debug('mapFlexAmountsBySku+++' + mapFlexAmountsBySku);

        return mapFlexAmountsBySku;
    }
}