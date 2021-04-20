/************************************************************************************************
 Dev: Juan Pablo Cubo       Version: 1
 This class is a copy of PriceCalculationInterface.
 It sets the values for the price calculation interface according to the data filled by the user
 for the Argentina/Uruguay version of the product page.
************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 16/11/2016
*
********************************************************************************/


global class WS04_PriceCalculationInterface_AR{
    
    private static LAT_Log__c logAsRegistry;//
    private static LAT_DebugUtil debug;
  
    Webservice static String PriceCalculation(String idSalesforce){
        Opportunity opp;
        logAsRegistry = new LAT_Log__c();
        String debugStr = '';
        
        logAsRegistry.LAT_Origin__c = 'WS04_PriceCalculationInterface_AR';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();
        
        Set<Id> setRecTypeOpp = new Set<Id>();
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_1_NewOrder_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_2_NewOrder_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_3_HeaderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_4_HeaderBlocked_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_5_OrderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_6_OrderBlocked_URU'));
        try{
            List<Opportunity> oppL = [SELECT Id, Owner.C_digo_JDE__c, DT_delivery__c, Freight__c, 
                                      Account.Client_code_AN8__c, Integracao_Retorno_JDE__c, Account.Business_Unit_AR__c,
                                      RecordType.Name, Type,  Account.ParentId, Pais__c, AccountId, NR_order_JDE__c
                                      FROM Opportunity WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];
          
            if(oppL.size() == 0) return '';
            opp = oppL[ 0 ];
            PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
            
            string country = '';
            if(opp.RecordType.Name.endsWith('ARG')){
                country = 'Argentina';
            }else if(opp.RecordType.Name.endsWith('URU')){
                country = 'Uruguay';
            }
          
            header.salesman = '0';
            header.customerCode = Integer.valueOf(opp.Account.Client_code_AN8__c);
            
            List<Account> accListParent = [SELECT Client_code_AN8__c FROM Account 
                                           WHERE Id =:opp.Account.Parentid limit 1 ];
            if(accListParent.size() > 0 && opp.Pais__c == 6)
            header.customerCode = Integer.valueOf( accListParent[ 0 ].Client_code_AN8__c);
            
            header.promisedDate = opp.DT_delivery__c < date.today() ? date.today() : opp.DT_delivery__c;
            
            if(opp.Freight__c != null && opp.Freight__c.equalsIgnoreCase('FOB'))
                header.freightType = 'F';
            else
                header.freightType = '';
            if(opp.Account.Business_Unit_AR__c != null){
                List <UDC__c> udc = [SELECT CodDefUsuario__c FROM UDC__c WHERE Id=:opp.Account.Business_Unit_AR__c];
                header.businessUnit = udc[0].CodDefUsuario__c;
            }else{
                header.businessUnit = '';
            }
            string oppType = opp.Type;
            if(oppType != null && oppType.length() > 2){
                header.orderType = oppType.substring(0,2);
            }else{
                header.orderType = oppType;
            }
          
            debugStr = 'salesman: ' + header.salesman +' | customerCode: ' +header.customerCode+' | promisedDate: '+header.promisedDate+' | freightType: '+header.freightType+' | businessUnit: '+header.businessUnit + ' | orderType: ' + header.orderType; 
            Map<String,OpportunityLineItem> mapItems = new Map<String,OpportunityLineItem>();
            
            PriceCalculationTypes.PriceCalculationItemRequestType item;
            List<OpportunityLineItem> listaItens = [SELECT Quantity, LAT_PercentualBonus__c, QT_Bonus__c, LAT_UnitCode__c, cd_unit_bonif__c, 
                                                    LAT_PaymentCondition__c, Discount_AR__c, LAT_SkuText__c, UOM_AR__c
                                                    FROM OpportunityLineItem WHERE OpportunityId=:idSalesforce AND cd_line_status__c<>'999' ];
            
            List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List< PriceCalculationTypes.PriceCalculationItemRequestType >();
            if(listaItens.size() == 0) return 'El pedido no contiene productos';
            for(OpportunityLineItem oppItem : listaItens){   
                item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                item.billedTotalQuantity = oppItem.Quantity;
                item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
                item.bonusQuantity = 0;//Integer.valueOf( oppItem.QT_Bonus__c );
                item.paymentTerm = oppItem.LAT_PaymentCondition__c;
                if(oppItem.Discount_AR__c != null){
                    item.percentualDiscount = oppItem.Discount_AR__c;
                }else{
                    item.percentualDiscount = 0;
                }
                if(oppItem.UOM_AR__c != null){
                    item.bonusUnit = oppItem.UOM_AR__c;
                }else{
                    item.bonusUnit = '';
                }
                if(oppItem.UOM_AR__c != null){
                    item.salesUOM = oppItem.UOM_AR__c;
                }else{
                    item.salesUOM = '';
                } 
                item.sku = oppItem.LAT_SkuText__c;
                items.add(item);
                mapItems.put( oppItem.LAT_SkuText__c, oppItem );
                
                debugStr +='=ITEM= | billedTotalQuantity: '+item.billedTotalQuantity+' | bonusPercentual: '+item.bonusPercentual+' | bonusQuantity: '+item.bonusQuantity+' | bonusUnit: '+item.bonusUnit
                +' | paymentTerm: '+ item.paymentTerm+' | percentualDiscount: '+item.percentualDiscount+' | salesUOM: '+item.salesUOM+' | item: '+item.sku + '\n';
            }
            
            PriceCalculation.port request = new PriceCalculation.port();
            request.timeout_x = 120000;
            PriceCalculationTypes.PriceCalculationResponseType response;
            response = request.operation( getConnectionParameter(country), header, items );
            
            //creates a registry log
            logAsRegistry.LAT_Account__c = opp.AccountId;
            logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
            logAsRegistry.LAT_Opportunity__c = opp.Id;
            logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c);
            logAsRegistry.LAT_ReturnTime__c = system.now();     
            try{insert logAsRegistry;}catch(Exception e){}
            
            if( response == null ) return 'Error inesperado en el envio a JDE. Contacte a su administrador de sistema';
          
            //opp.Account.Client_code_AN8__c = String.valueOf( response.header.customerCode );
            update opp;
            
            for(PriceCalculationTypes.PriceCalculationItemResponseType respItem : response.item){
                OpportunityLineItem oppItem = mapItems.get(String.valueOf(respItem.sku).trim());
                oppItem.Campo_de_formatacao__c = utils.decodeStringWithDiscount(respItem.priceComponents, false);
                oppItem.UnitPrice = respItem.salesPriceValue;
            }
          
            update listaItens;
          
        }catch(Exception e){
            if(opp != null){ 
                 
                //creates a registry log
                logAsRegistry.LAT_Account__c = opp.AccountId;
                logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();     
                try{insert logAsRegistry;}catch(Exception e1){}
                
                opp.Integracao_Retorno_JDE__c = debugStr+e.getMessage();
                update opp;
            }
        } finally{
        }
        return '';
    }
    //MIGRATED 16/11/2016
    Webservice static String LAT_PriceCalculation(String idSalesforce){
        LAT_Opportunity__c opp;
        logAsRegistry = new LAT_Log__c();
        String debugStr = '';
        
        logAsRegistry.LAT_Origin__c = 'WS04_PriceCalculationInterface_AR';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();
        
        Set<Id> setRecTypeOpp = new Set<Id>();
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_2_NewOrder_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_3_HeaderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_4_HeaderBlocked_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_5_OrderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_6_OrderBlocked_URU'));
        try{
            
            List<LAT_Opportunity__c> oppL = [SELECT Id, LAT_Account__r.Owner.C_digo_JDE__c, LAT_DTDelivery__c, LAT_Freight__c, LAT_Account__r.Client_code_AN8__c,
                                      LAT_JDEIntegrationReturn__c, LAT_Account__r.Business_Unit_AR__c,
                                      RecordType.Name, LAT_Type__c, LAT_Account__r.ParentId, LAT_Account__c,LAT_Country__c, LAT_NROrderJDE__c
                                      FROM LAT_Opportunity__c WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];

            if(oppL.size() == 0) return '';
            opp = oppL[ 0 ];
            
            string country = '';
            if(opp.RecordType.Name.endsWith('ARG')){
                country = 'Argentina';
            }else if(opp.RecordType.Name.endsWith('URU')){
                country = 'Uruguay';
            }

            
            List<Account> accListParent = [SELECT Client_code_AN8__c FROM Account 
                                           WHERE Id =:opp.LAT_Account__r.Parentid limit 1 ];
            List<LAT_OpportunityLineItem__c> listaItens = [SELECT LAT_Quantity__c, LAT_PercentualBonus__c, LAT_QTBonus__c, LAT_UnitCode__c, LAT_CdUnitBonification__c, 
                                        LAT_PaymentCondition__c, LAT_AR_Discount__c, LAT_SkuText__c, LAT_AR_UOM__c
                                        FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c=:idSalesforce AND LAT_CdLineStatus__c<>'999' ];

            if (isNewPriceCalculation(country)) {
                //NEW
                logAsRegistry = new LAT_Log__c();
                debug = new LAT_DebugUtil();
                PriceCalculationInterface.logAsRegistry = logAsRegistry;
                PriceCalculationInterface.debug = debug;
                String result = PriceCalculationInterface.LAT_BR_NewPriceCalculation(idSalesforce,listaItens, true);
                return result;   
            } 
            //OLD
            else {
                PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();          
                header.salesman = '0';
                header.customerCode = Integer.valueOf(opp.LAT_Account__r.Client_code_AN8__c);
                if(accListParent.size() > 0 && opp.LAT_Country__c == 6)
                header.customerCode = Integer.valueOf( accListParent[ 0 ].Client_code_AN8__c);
                
                header.promisedDate = opp.LAT_DTDelivery__c < date.today() ? date.today() : opp.LAT_DTDelivery__c;
                
                if(opp.LAT_Freight__c != null && opp.LAT_Freight__c.equalsIgnoreCase('FOB'))
                    header.freightType = 'F';
                else
                    header.freightType = '';
                if(opp.LAT_Account__r.Business_Unit_AR__c != null){
                    List <UDC__c> udc = [SELECT CodDefUsuario__c FROM UDC__c WHERE Id=:opp.LAT_Account__r.Business_Unit_AR__c];
                    header.businessUnit = udc[0].CodDefUsuario__c;
                }else{
                    header.businessUnit = '';
                }
                string oppType = opp.LAT_Type__c;
                if(oppType != null && oppType.length() > 2){
                    header.orderType = oppType.substring(0,2);
                }else{
                    header.orderType = oppType;
                }
              
                debugStr = 'salesman: ' + header.salesman +' | customerCode: ' +header.customerCode+' | promisedDate: '+header.promisedDate+' | freightType: '+header.freightType+' | businessUnit: '+header.businessUnit + ' | orderType: ' + header.orderType; 
                Map<String,LAT_OpportunityLineItem__c> mapItems = new Map<String,LAT_OpportunityLineItem__c>();
                
                PriceCalculationTypes.PriceCalculationItemRequestType item;
                
                List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List< PriceCalculationTypes.PriceCalculationItemRequestType >();
                if(listaItens.size() == 0) return 'El pedido no contiene productos';
                for(LAT_OpportunityLineItem__c oppItem : listaItens){   
                    item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                    item.billedTotalQuantity = oppItem.LAT_Quantity__c;
                    item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
                    item.bonusQuantity = 0;//Integer.valueOf( oppItem.QT_Bonus__c );
                    item.paymentTerm = oppItem.LAT_PaymentCondition__c;
                    if(oppItem.LAT_AR_Discount__c != null){
                        item.percentualDiscount = oppItem.LAT_AR_Discount__c;
                    }else{
                        item.percentualDiscount = 0;
                    }
                    if(oppItem.LAT_AR_UOM__c != null){
                        item.bonusUnit = oppItem.LAT_AR_UOM__c;
                    }else{
                        item.bonusUnit = '';
                    }
                    if(oppItem.LAT_AR_UOM__c != null){
                        item.salesUOM = oppItem.LAT_AR_UOM__c;
                    }else{
                        item.salesUOM = '';
                    } 
                    item.sku = oppItem.LAT_SkuText__c;
                    items.add(item);
                    mapItems.put( oppItem.LAT_SkuText__c, oppItem );
                    
                    debugStr +='=ITEM= | billedTotalQuantity: '+item.billedTotalQuantity+' | bonusPercentual: '+item.bonusPercentual+' | bonusQuantity: '+item.bonusQuantity+' | bonusUnit: '+item.bonusUnit
                    +' | paymentTerm: '+ item.paymentTerm+' | percentualDiscount: '+item.percentualDiscount+' | salesUOM: '+item.salesUOM+' | item: '+item.sku + '\n';
                }
                
                PriceCalculation.port request = new PriceCalculation.port();
                request.timeout_x = 120000;
                PriceCalculationTypes.PriceCalculationResponseType response;
                response = request.operation( getConnectionParameter(country), header, items );
                
                //creates a registry log
                logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Opportunity__c = opp.Id;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();     
                try{insert logAsRegistry;}catch(Exception e){}
                
                if( response == null ) return 'Error inesperado en el envio a JDE. Contacte a su administrador de sistema';
              
                //opp.Account.Client_code_AN8__c = String.valueOf( response.header.customerCode );
                update opp;
                
                for(PriceCalculationTypes.PriceCalculationItemResponseType respItem : response.item){
                    LAT_OpportunityLineItem__c oppItem = mapItems.get(String.valueOf(respItem.sku).trim());
                    oppItem.LAT_FormatField__c = utils.decodeStringWithDiscount(respItem.priceComponents, false);
                    oppItem.LAT_UnitPrice__c = respItem.salesPriceValue;
                }
              
                update listaItens;
            }
            
          
        }catch(Exception e){
            if(opp != null){ 
                 
                //creates a registry log
                logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();     
                try{insert logAsRegistry;}catch(Exception e1){}
                
                opp.LAT_JDEIntegrationReturn__c = debugStr+e.getMessage();
                update opp;
            }
        } finally{
        }
        return '';
    }
  
    Webservice static String PriceCalculation2(String idSalesforce, List<OpportunityLineItem> oppItems){
        Opportunity opp;
        logAsRegistry = new LAT_Log__c();
        String debugStr = '';
        
        logAsRegistry.LAT_Origin__c = 'WS04_PriceCalculationInterface_AR';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();
        
        Set<Id> setRecTypeOpp = new Set< Id >();
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_1_NewOrder_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_2_NewOrder_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_3_HeaderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_4_HeaderBlocked_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_5_OrderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_6_OrderBlocked_URU'));

        try{
            List<Opportunity> oppL = [SELECT Id, Owner.C_digo_JDE__c, DT_delivery__c, Freight__c, Account.Client_code_AN8__c,
                                      Integracao_Retorno_JDE__c, Account.Business_Unit_AR__c,
                                      RecordType.Name, Type, Account.ParentId, Pais__c, NR_order_JDE__c
                                      FROM Opportunity WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];
            
            if(oppL.size() == 0) return '';
            opp = oppL[0];
            PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
            
            string country = '';
            if(opp.RecordType.Name.endsWith('ARG')){
                country = 'Argentina';
            }else if (opp.RecordType.Name.endsWith('URU')){
                country = 'Uruguay';
            }
            
            header.salesman = '0';
            header.customerCode = Integer.valueOf(opp.Account.Client_code_AN8__c);
            
            List<Account> accListParent = [SELECT Client_code_AN8__c FROM Account 
                                           WHERE Id =:opp.Account.Parentid limit 1];
            if(accListParent.size() > 0 && opp.Pais__c == 6)
                header.customerCode = Integer.valueOf(accListParent[0].Client_code_AN8__c);
                
            header.promisedDate = opp.DT_delivery__c < date.today() ? date.today() : opp.DT_delivery__c;
            
            if(opp.Freight__c != null && opp.Freight__c.equalsIgnoreCase('FOB'))
                header.freightType = 'F';
            else
                header.freightType = '';
            if(opp.Account.Business_Unit_AR__c != null){
                List <UDC__c> udc = [SELECT CodDefUsuario__c FROM UDC__c WHERE Id=:opp.Account.Business_Unit_AR__c];
                header.businessUnit = udc[0].CodDefUsuario__c;
            }else{
                header.businessUnit = '';
            }
            string oppType = opp.Type;
            if(oppType != null && oppType.length() > 2){
                header.orderType = oppType.substring(0,2);
            }else{
                header.orderType = oppType;
            }
            
            debugStr = 'salesman: ' + header.salesman +' | customerCode: ' +header.customerCode+' | promisedDate: '+header.promisedDate+' | freightType: '+header.freightType+' | businessUnit: '+header.businessUnit + ' | orderType: ' + header.orderType; 
            Map<String,OpportunityLineItem> mapItems = new Map<String,OpportunityLineItem>();
            
            PriceCalculationTypes.PriceCalculationItemRequestType item;
            
            List<OpportunityLineItem> listaItens = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : oppItems){
                if(oli.cd_line_status__c != '999') {
                    listaItens.add(oli);
                }
            }
            List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List<PriceCalculationTypes.PriceCalculationItemRequestType>();
            if(listaItens.size() == 0) return 'El pedido no contiene productos';
            for(OpportunityLineItem oppItem : listaItens){   
                item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                item.billedTotalQuantity = oppItem.Quantity;
                item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
                item.bonusQuantity = 0;//Integer.valueOf( oppItem.QT_Bonus__c );
                item.paymentTerm = oppItem.LAT_PaymentCondition__c;
                
                if(oppItem.Discount_AR__c != null){
                    item.percentualDiscount = oppItem.Discount_AR__c;
                }else{
                    item.percentualDiscount = 0;
                }
                if(oppItem.UOM_AR__c != null){
                    item.bonusUnit = oppItem.UOM_AR__c;
                }else{
                    item.bonusUnit = '';
                }
                if(oppItem.UOM_AR__c != null){
                    item.salesUOM = oppItem.UOM_AR__c;
                }else{
                    item.salesUOM = '';
                } 
                item.sku = oppItem.LAT_SkuText__c; //JPC: cambio de la fórmula al campo real
                items.add(item);
                mapItems.put(oppItem.LAT_SkuText__c, oppItem);
                
                debugStr +='=ITEM= | billedTotalQuantity: '+item.billedTotalQuantity+' | bonusPercentual: '+item.bonusPercentual+' | bonusQuantity: '+item.bonusQuantity+' | bonusUnit: '+item.bonusUnit
                +' | paymentTerm: '+ item.paymentTerm+' | percentualDiscount: '+item.percentualDiscount+' | salesUOM: '+item.salesUOM+' | item: '+item.sku + '\n';
            }
            
            PriceCalculation.port request = new PriceCalculation.port();
            request.timeout_x = 120000;
            PriceCalculationTypes.PriceCalculationResponseType response;
            response = request.operation(getConnectionParameter(country), header, items);
            
            //creates a registry log
            logAsRegistry.LAT_Account__c = opp.AccountId;
            logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
            logAsRegistry.LAT_Opportunity__c = opp.Id;
            logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c);
            logAsRegistry.LAT_ReturnTime__c = system.now();      
            //try{insert logAsRegistry;}catch(Exception e){}
            
            if(response == null) return 'Error inesperado en el envio a JDE. Contacte a su administrador de sistema';
            
            //opp.Account.Client_code_AN8__c = String.valueOf( response.header.customerCode );
            //update opp;
            for(PriceCalculationTypes.PriceCalculationItemResponseType respItem : response.item){
                OpportunityLineItem oppItem = mapItems.get(String.valueOf(respItem.sku ).trim());
                oppItem.Campo_de_formatacao__c = utils.decodeStringWithDiscount(respItem.priceComponents, false);
                oppItem.UnitPrice = respItem.salesPriceValue;
                System.debug(loggingLevel.ERROR, 'oppItem.Campo_de_formatacao__c: ' + oppItem.Campo_de_formatacao__c);
                System.debug(loggingLevel.ERROR, 'oppItem.UnitPrice: ' + oppItem.UnitPrice);
            }

      //update listaItens;
        }catch(Exception e){
            System.debug('Exception: ' + e);
            if(opp != null){
            //creates a registry log
            logAsRegistry.LAT_Account__c = opp.AccountId;
            logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
            logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c);
            logAsRegistry.LAT_ReturnTime__c = system.now();      
            try{insert logAsRegistry;}catch(Exception e1){}
            
            opp.Integracao_Retorno_JDE__c = debugStr+e.getMessage();
            update opp;
        }
        } finally{
        }
        return '';
    }


    //MIGRATED 16/11/2016
    Webservice static String LAT_PriceCalculation2(String idSalesforce, List<LAT_OpportunityLineItem__c> oppItems){
        System.debug('%%%%%%%%% idSalesforce : '+ idSalesforce + ', cantidad items : '+oppItems.size());
        System.debug('%%%%%%%%% oppItems : ' + oppItems);
        LAT_Opportunity__c opp;
        logAsRegistry = new LAT_Log__c();
        String debugStr = '';
        
        logAsRegistry.LAT_Origin__c = 'WS04_PriceCalculationInterface_AR';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();
        
        Set<Id> setRecTypeOpp = new Set< Id >();
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_2_NewOrder_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_3_HeaderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_4_HeaderBlocked_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_5_OrderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_6_OrderBlocked_URU'));

        try
        {
            List<LAT_Opportunity__c> oppL = [SELECT Id, LAT_Account__r.Owner.C_digo_JDE__c, LAT_DTDelivery__c, LAT_Freight__c, LAT_Account__r.Client_code_AN8__c,
                                      LAT_JDEIntegrationReturn__c, LAT_Account__r.Business_Unit_AR__c,
                                      RecordType.Name, LAT_Type__c, LAT_Account__r.ParentId, LAT_Country__c, LAT_NROrderJDE__c
                                      FROM LAT_Opportunity__c WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];
            
            System.debug('%%%%%%%%% oppL : '+ oppL + ', size : '+oppL.size());
            if(oppL.size() == 0) return '';
            opp = oppL[0];
            
            string country = '';
            if(opp.RecordType.Name.endsWith('ARG')){
                country = 'Argentina';
            }else if (opp.RecordType.Name.endsWith('URU')){
                country = 'Uruguay';
            }

            if (isNewPriceCalculation(country)) {
                //NEW
                logAsRegistry = new LAT_Log__c();
                debug = new LAT_DebugUtil();
                PriceCalculationInterface.logAsRegistry = logAsRegistry;
                PriceCalculationInterface.debug = debug;
                String result = PriceCalculationInterface.LAT_BR_NewPriceCalculation(idSalesforce, oppItems, true);
                return result;   
            } 
            //OLD
            else {

                PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
                header.salesman = '0';
                header.customerCode = Integer.valueOf(opp.LAT_Account__r.Client_code_AN8__c);
                
                List<Account> accListParent = [SELECT Client_code_AN8__c FROM Account 
                                               WHERE Id =:opp.LAT_Account__r.Parentid limit 1];
                if(accListParent.size() > 0 && opp.LAT_Country__c == 6)
                    header.customerCode = Integer.valueOf(accListParent[0].Client_code_AN8__c);
                    
                header.promisedDate = opp.LAT_DTDelivery__c < date.today() ? date.today() : opp.LAT_DTDelivery__c;
                
                if(opp.LAT_Freight__c != null && opp.LAT_Freight__c.equalsIgnoreCase('FOB'))
                    header.freightType = 'F';
                else
                    header.freightType = '';
                if (opp.LAT_Account__r.Business_Unit_AR__c != null) {
                    List <UDC__c> udc = [SELECT CodDefUsuario__c FROM UDC__c WHERE Id=:opp.LAT_Account__r.Business_Unit_AR__c];
                    header.businessUnit = udc[0].CodDefUsuario__c;
                } else {
                    header.businessUnit = '';
                }
                string oppType = opp.LAT_Type__c;
                if(oppType != null && oppType.length() > 2){
                    header.orderType = oppType.substring(0,2);
                }else{
                    header.orderType = oppType;
                }
                
                debugStr = 'salesman: ' + header.salesman +' | customerCode: ' +header.customerCode+' | promisedDate: '+header.promisedDate+' | freightType: '+header.freightType+' | businessUnit: '+header.businessUnit + ' | orderType: ' + header.orderType; 
                System.debug('%%%%%%%%%%% debugStr : '+ debugStr);
                Map<String,LAT_OpportunityLineItem__c> mapItems = new Map<String,LAT_OpportunityLineItem__c>();
                
                PriceCalculationTypes.PriceCalculationItemRequestType item;
                
                List<LAT_OpportunityLineItem__c> listaItens = new List<LAT_OpportunityLineItem__c>();
                for(LAT_OpportunityLineItem__c oli : oppItems){
                    if(oli.LAT_CdLineStatus__c != '999') {
                        listaItens.add(oli);
                    }
                }
                List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List<PriceCalculationTypes.PriceCalculationItemRequestType>();
                System.debug('%%%%%%%%%%% listaItens : '+ listaItens);
                if(listaItens.size() == 0) return 'El pedido no contiene productos';
                for(LAT_OpportunityLineItem__c oppItem : listaItens){   
                    item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                    item.billedTotalQuantity = oppItem.LAT_Quantity__c;
                    item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
                    item.bonusQuantity = 0;//Integer.valueOf( oppItem.QT_Bonus__c );
                    item.paymentTerm = oppItem.LAT_PaymentCondition__c;
                    
                    if(oppItem.LAT_AR_Discount__c != null){
                        item.percentualDiscount = oppItem.LAT_AR_Discount__c;
                    }else{
                        item.percentualDiscount = 0;
                    }
                    if(oppItem.LAT_AR_UOM__c != null){
                        item.bonusUnit = oppItem.LAT_AR_UOM__c;
                    }else{
                        item.bonusUnit = '';
                    }
                    if(oppItem.LAT_AR_UOM__c != null){
                        item.salesUOM = oppItem.LAT_AR_UOM__c;
                    }else{
                        item.salesUOM = '';
                    } 
                    item.sku = oppItem.LAT_SkuText__c; //JPC: cambio de la fórmula al campo real
                    items.add(item);
                    mapItems.put(oppItem.LAT_SkuText__c, oppItem);
                    
                    debugStr +='=ITEM= | billedTotalQuantity: '+item.billedTotalQuantity+' | bonusPercentual: '+item.bonusPercentual+' | bonusQuantity: '+item.bonusQuantity+' | bonusUnit: '+item.bonusUnit
                    +' | paymentTerm: '+ item.paymentTerm+' | percentualDiscount: '+item.percentualDiscount+' | salesUOM: '+item.salesUOM+' | item: '+item.sku + '\n';
                }
                
                PriceCalculation.port request = new PriceCalculation.port();
                request.timeout_x = 120000;
                PriceCalculationTypes.PriceCalculationResponseType response;
                response = request.operation(getConnectionParameter(country), header, items);
                
                //creates a registry log
                logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Opportunity__c = opp.Id;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();      
                //try{insert logAsRegistry;}catch(Exception e){}
                //insert logAsRegistry;
                if(response == null) return 'Error inesperado en el envio a JDE. Contacte a su administrador de sistema';
                
                //opp.LAT_Account__r.Client_code_AN8__c = String.valueOf( response.header.customerCode );
                //update opp;
                for(PriceCalculationTypes.PriceCalculationItemResponseType respItem : response.item){
                    LAT_OpportunityLineItem__c oppItem = mapItems.get(String.valueOf(respItem.sku ).trim());
                    oppItem.LAT_FormatField__c = utils.decodeStringWithDiscount(respItem.priceComponents, false);
                    oppItem.LAT_UnitPrice__c = respItem.salesPriceValue;
                    System.debug(loggingLevel.ERROR, 'oppItem.LAT_FormatField__c: ' + oppItem.LAT_FormatField__c);
                    System.debug(loggingLevel.ERROR, 'oppItem.LAT_UnitPrice__c: ' + oppItem.LAT_UnitPrice__c);
                }
            }
                //update listaItens;
        } catch (Exception e) {
                System.debug('Exception.getStackTraceString: ' + e.getStackTraceString());
                System.debug('Exception.getMessage: ' + e.getMessage());
                if(opp != null){
                    //creates a registry log
                    logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                    logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                    logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                    logAsRegistry.LAT_ReturnTime__c = system.now();      
                    try{insert logAsRegistry;}catch(Exception e1){}
                    
                    opp.LAT_JDEIntegrationReturn__c = debugStr+e.getMessage();
                    update opp;
                }
        } finally{
            
        }
        return '';
    }

    /**
     * Service from use before the order handler, (this means to avoid DML executions on the code)
     *
     */
      Webservice static String LAT_PriceCalculationFromOrderHandler(String idSalesforce, List<LAT_OpportunityLineItem__c> oppItems){
        System.debug('%%%%%%%%% idSalesforce : '+ idSalesforce + ', cantidad items : '+oppItems.size());
        System.debug('%%%%%%%%% oppItems : ' + oppItems);
        LAT_Opportunity__c opp;
        logAsRegistry = new LAT_Log__c();
        String debugStr = '';
        
        logAsRegistry.LAT_Origin__c = 'WS04_PriceCalculationInterface_AR';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();
        
        Set<Id> setRecTypeOpp = new Set< Id >();
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_2_NewOrder_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_3_HeaderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_4_HeaderBlocked_URU'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_5_OrderBlocked_ARG'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_6_OrderBlocked_URU'));

        try
        {
            List<LAT_Opportunity__c> oppL = [SELECT Id, LAT_Account__r.Owner.C_digo_JDE__c, LAT_DTDelivery__c, LAT_Freight__c, LAT_Account__r.Client_code_AN8__c,
                                      LAT_JDEIntegrationReturn__c, LAT_Account__r.Business_Unit_AR__c,
                                      RecordType.Name, LAT_Type__c, LAT_Account__r.ParentId, LAT_Country__c, LAT_NROrderJDE__c
                                      FROM LAT_Opportunity__c WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];
            
            System.debug('%%%%%%%%% oppL : '+ oppL + ', size : '+oppL.size());
            if(oppL.size() == 0) return '';
            opp = oppL[0];
            
            string country = '';
            if(opp.RecordType.Name.endsWith('ARG')){
                country = 'Argentina';
            }else if (opp.RecordType.Name.endsWith('URU')){
                country = 'Uruguay';
            }

            if (isNewPriceCalculation(country)) {
                //NEW
                logAsRegistry = new LAT_Log__c();
                debug = new LAT_DebugUtil();
                PriceCalculationInterface.logAsRegistry = logAsRegistry;
                PriceCalculationInterface.debug = debug;
                String result = PriceCalculationInterface.LAT_BR_NewPriceCalculation(idSalesforce, oppItems, false);
                return result;   
            } 
            //OLD
            else {

                PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
                header.salesman = '0';
                header.customerCode = Integer.valueOf(opp.LAT_Account__r.Client_code_AN8__c);
                
                List<Account> accListParent = [SELECT Client_code_AN8__c FROM Account 
                                               WHERE Id =:opp.LAT_Account__r.Parentid limit 1];
                if(accListParent.size() > 0 && opp.LAT_Country__c == 6)
                    header.customerCode = Integer.valueOf(accListParent[0].Client_code_AN8__c);
                    
                header.promisedDate = opp.LAT_DTDelivery__c < date.today() ? date.today() : opp.LAT_DTDelivery__c;
                
                if(opp.LAT_Freight__c != null && opp.LAT_Freight__c.equalsIgnoreCase('FOB'))
                    header.freightType = 'F';
                else
                    header.freightType = '';
                if (opp.LAT_Account__r.Business_Unit_AR__c != null) {
                    List <UDC__c> udc = [SELECT CodDefUsuario__c FROM UDC__c WHERE Id=:opp.LAT_Account__r.Business_Unit_AR__c];
                    header.businessUnit = udc[0].CodDefUsuario__c;
                } else {
                    header.businessUnit = '';
                }
                string oppType = opp.LAT_Type__c;
                if(oppType != null && oppType.length() > 2){
                    header.orderType = oppType.substring(0,2);
                }else{
                    header.orderType = oppType;
                }
                
                debugStr = 'salesman: ' + header.salesman +' | customerCode: ' +header.customerCode+' | promisedDate: '+header.promisedDate+' | freightType: '+header.freightType+' | businessUnit: '+header.businessUnit + ' | orderType: ' + header.orderType; 
                System.debug('%%%%%%%%%%% debugStr : '+ debugStr);
                Map<String,LAT_OpportunityLineItem__c> mapItems = new Map<String,LAT_OpportunityLineItem__c>();
                
                PriceCalculationTypes.PriceCalculationItemRequestType item;
                
                List<LAT_OpportunityLineItem__c> listaItens = new List<LAT_OpportunityLineItem__c>();
                for(LAT_OpportunityLineItem__c oli : oppItems){
                    if(oli.LAT_CdLineStatus__c != '999') {
                        listaItens.add(oli);
                    }
                }
                List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List<PriceCalculationTypes.PriceCalculationItemRequestType>();
                System.debug('%%%%%%%%%%% listaItens : '+ listaItens);
                if(listaItens.size() == 0) return 'El pedido no contiene productos';
                for(LAT_OpportunityLineItem__c oppItem : listaItens){   
                    item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                    item.billedTotalQuantity = oppItem.LAT_Quantity__c;
                    item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
                    item.bonusQuantity = 0;//Integer.valueOf( oppItem.QT_Bonus__c );
                    item.paymentTerm = oppItem.LAT_PaymentCondition__c;
                    
                    if(oppItem.LAT_AR_Discount__c != null){
                        item.percentualDiscount = oppItem.LAT_AR_Discount__c;
                    }else{
                        item.percentualDiscount = 0;
                    }
                    if(oppItem.LAT_AR_UOM__c != null){
                        item.bonusUnit = oppItem.LAT_AR_UOM__c;
                    }else{
                        item.bonusUnit = '';
                    }
                    if(oppItem.LAT_AR_UOM__c != null){
                        item.salesUOM = oppItem.LAT_AR_UOM__c;
                    }else{
                        item.salesUOM = '';
                    } 
                    item.sku = oppItem.LAT_SkuText__c; //JPC: cambio de la fórmula al campo real
                    items.add(item);
                    mapItems.put(oppItem.LAT_SkuText__c, oppItem);
                    
                    debugStr +='=ITEM= | billedTotalQuantity: '+item.billedTotalQuantity+' | bonusPercentual: '+item.bonusPercentual+' | bonusQuantity: '+item.bonusQuantity+' | bonusUnit: '+item.bonusUnit
                    +' | paymentTerm: '+ item.paymentTerm+' | percentualDiscount: '+item.percentualDiscount+' | salesUOM: '+item.salesUOM+' | item: '+item.sku + '\n';
                }
                
                PriceCalculation.port request = new PriceCalculation.port();
                request.timeout_x = 120000;
                PriceCalculationTypes.PriceCalculationResponseType response;
                response = request.operation(getConnectionParameter(country), header, items);
                
                //creates a registry log
                logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Opportunity__c = opp.Id;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();      
                //try{insert logAsRegistry;}catch(Exception e){}
                //insert logAsRegistry;
                if(response == null) return 'Error inesperado en el envio a JDE. Contacte a su administrador de sistema';
                
                //opp.LAT_Account__r.Client_code_AN8__c = String.valueOf( response.header.customerCode );
                //update opp;
                for(PriceCalculationTypes.PriceCalculationItemResponseType respItem : response.item){
                    LAT_OpportunityLineItem__c oppItem = mapItems.get(String.valueOf(respItem.sku ).trim());
                    oppItem.LAT_FormatField__c = utils.decodeStringWithDiscount(respItem.priceComponents, false);
                    oppItem.LAT_UnitPrice__c = respItem.salesPriceValue;
                    System.debug(loggingLevel.ERROR, 'oppItem.LAT_FormatField__c: ' + oppItem.LAT_FormatField__c);
                    System.debug(loggingLevel.ERROR, 'oppItem.LAT_UnitPrice__c: ' + oppItem.LAT_UnitPrice__c);
                }
            }
                //update listaItens;
        } catch (Exception e) {
                System.debug('Exception.getStackTraceString: ' + e.getStackTraceString());
                System.debug('Exception.getMessage: ' + e.getMessage());
                if(opp != null){
                    //creates a registry log
                    logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                    logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                    logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                    logAsRegistry.LAT_ReturnTime__c = system.now();      
                    try{insert logAsRegistry;}catch(Exception e1){}
                    
                    opp.LAT_JDEIntegrationReturn__c = debugStr+e.getMessage();
                    update opp;
                }
        } finally{
            
        }
        return '';
    }


    public static Boolean isNewPriceCalculation(String country) {
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        return cred.Exec_new_Price_Calc__c;
    }
  
    public static PriceCalculationTypes.ClientInfoType getConnectionParameter(string country){
        PriceCalculationTypes.ClientInfoType connParms = new PriceCalculationTypes.ClientInfoType();
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        if(cred != null){
            connParms.country = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x = Datetime.now();
        }
        return connParms;
    }
    
}