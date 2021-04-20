@RestResource(urlMapping='/LAT_Rest_ValidateFlexApprovals/*')
global with sharing class LAT_Rest_ValidateFlexApprovals {


    public static Map<String, List<LAT_Rest_OpportunityFlex.SyncParam>> mapParamsByBrand;
    public static Map<Integer, List<LAT_Rest_OpportunityFlex.SyncParam>> mapParamsByAccountId;
    public static Map<String, List<LAT_Rest_OpportunityFlex.SyncParam>> mapParamsByChannel;
    public static Map<String, List<LAT_Rest_OpportunityFlex.SyncParam>> mapParamsByRegion;
    public static List<LAT_Rest_OpportunityFlex.SyncParam> defaultParams;
    public static Map<Id, LAT_Product__c> mapProdById;
    public static Account acc;

    @HttpPost
    global static void process() {

        RestRequest req = RestContext.request;
        LAT_OpportunityHandlerJSON pedido = (LAT_OpportunityHandlerJSON)System.JSON.deserialize(req.requestBody.toString(), LAT_OpportunityHandlerJSON.class);
        System.debug('Pedido : ' + pedido);
        System.debug('Pedido.account : ' + pedido.header.account);
        LAT_Rest_OpportunityFlex.ServiceResponse res = calculateApprovals(pedido);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
    }

    public static LAT_Rest_OpportunityFlex.ServiceResponse calculateApprovals(LAT_OpportunityHandlerJSON pedido) {

        acc = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c, Payment_Condition__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, LAT_Account__r.LAT_JDEZone__c FROM Account WHERE Id =:pedido.header.account LIMIT 1];
        
        Set<Id> setProdIds = new Set<Id>();
        Boolean integrateToIMM = false;

        for(LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
        System.debug('%%%%%% oppItem.isFlex : ' + oppItem.isFlex);
            if(oppItem.isFlex) {
                setProdIds.add(oppItem.product);
            }
            
        }      

        loadParamsMaps();
        pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = pedido.header.flexApproveRegionalManager = pedido.header.flexApproveCommercialDirector = false;
        mapProdById = new Map<Id, LAT_Product__c>([SELECT Id, Name,LAT_ScheduleC__r.KeyBrand__r.key__c FROM LAT_Product__c WHERE Id IN:setProdIds]);
        String errores = 'OK';
        for(LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) { 
            if(oppItem.isFlex && oppItem.discount < 0) {
                    
                if(!pedido.header.flexApproveCommercialDirector) {
                    LAT_Rest_OpportunityFlex.SyncParam param = getParam(oppItem);
                    if(param == null) {
                        param = LAT_Rest_OpportunityFlex.defaultParams[0];
                    }
                    System.debug('%%%%% param : ' + param);
                    System.debug('%%%%% oppItem.finalFlexDiscount*(-1) : ' + oppItem.finalFlexDiscount*(-1));
                    System.debug('%%%%% oppItem.finalFlexDiscount : ' + oppItem.finalFlexDiscount);
                    if(param != null) {
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentCommercialDirector) {
                            System.debug('%%%%% entro 1  ');
                            pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = pedido.header.flexApproveRegionalManager = pedido.header.flexApproveCommercialDirector = true;
                            continue;
                        }
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentRegionalManager) {
                            System.debug('%%%%% entro 2  ');
                            pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = pedido.header.flexApproveRegionalManager = true;
                            continue;
                        }
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentManager) {
                            System.debug('%%%%% entro 3  ');
                            pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = true;
                            continue;
                        }   
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentExecutive) {
                            System.debug('%%%%% entro 4  ');
                            pedido.header.flexApproveManager = true;
                            continue;
                        }                 
                    } else {
                        errores += 'Nenhum parâmetro encontrado para o Produto ' + mapProdById.get(oppItem.product).Name + ' (SKU:'+oppItem.productSKU+'), Marca: ' + mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c + '  e Executivo: ' + acc.LAT_Account__r.LAT_JDEZone__c + '.\n'; 
 
                    }
                }       
            }
        }
        if(pedido.header.flexApproveCommercialDirector) {
                        System.debug('%%%%% entro 10  ');
            errores = 'Seu pedido será enviado para aprovação em função do(s) %(s) de desconto aplicado(s).';
        } else if (pedido.header.flexApproveRegionalManager) {
                        System.debug('%%%%% entro 20  ');
            errores = 'Seu pedido será enviado para aprovação em função do(s) %(s) de desconto aplicado(s).';
        } else if (pedido.header.flexApproveAreaManager) {
                        System.debug('%%%%% entro 30  ');
            errores = 'Seu pedido será enviado para aprovação em função do(s) %(s) de desconto aplicado(s).';
        } else if (pedido.header.flexApproveManager) {
                        System.debug('%%%%% entro 40  ');
            errores ='Seu pedido será enviado para aprovação em função do(s) %(s) de desconto aplicado(s).';
        }
        return  new LAT_Rest_OpportunityFlex.ServiceResponse(errores, errores == 'OK'); 
    }

    public static void loadParamsMaps() {
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(LAT_Rest_OpportunityFlex.SYNC_PARAMS_METHOD);
        HttpResponse resp = LAT_Rest_PriceFlex_SyncParams.sentRequestGenericCaller(null, operation, '?where[salesStrucCode]='+acc.LAT_Account__r.LAT_JDEZone__c);
        system.debug('response loadParamsMaps:' + String.valueOf(resp.getBody()));
        List<LAT_Rest_OpportunityFlex.SyncParam> paramsResp = (List<LAT_Rest_OpportunityFlex.SyncParam>)System.JSON.deserialize(resp.getBody(), List<LAT_Rest_OpportunityFlex.SyncParam>.class);

        mapParamsByBrand = mapParamsByChannel = mapParamsByRegion = new  Map<String, List<LAT_Rest_OpportunityFlex.SyncParam>>();
        defaultParams  = new List<LAT_Rest_OpportunityFlex.SyncParam>();
        mapParamsByAccountId = new Map<Integer, List<LAT_Rest_OpportunityFlex.SyncParam>>();

        for(LAT_Rest_OpportunityFlex.SyncParam sp : paramsResp) {
            if(sp.regionCode != null && sp.regionCode != '') {
                if(mapParamsByRegion.get(sp.regionCode) == null) {
                    mapParamsByRegion.put(sp.regionCode, new List<LAT_Rest_OpportunityFlex.SyncParam>());
                }
                mapParamsByRegion.get(sp.regionCode).add(sp);
            }
            if(sp.channelCode != null && sp.channelCode != '') {
                if(mapParamsByChannel.get(sp.channelCode) == null) {
                    mapParamsByChannel.put(sp.channelCode, new List<LAT_Rest_OpportunityFlex.SyncParam>());
                }
                mapParamsByChannel.get(sp.channelCode).add(sp);
            }
            if(sp.accountId != null) {
                if(mapParamsByAccountId.get(sp.accountId) == null) {
                    mapParamsByAccountId.put(sp.accountId, new List<LAT_Rest_OpportunityFlex.SyncParam>());
                }
                mapParamsByAccountId.get(sp.accountId).add(sp);
            }
            if(sp.brandCode != null && sp.brandCode != '') {
                if(mapParamsByBrand.get(sp.brandCode) == null) {
                    mapParamsByBrand.put(sp.brandCode, new List<LAT_Rest_OpportunityFlex.SyncParam>());
                }
                mapParamsByBrand.get(sp.brandCode).add(sp);
            }

            if((sp.executiveCode == null || sp.executiveCode == '') && (sp.brandCode == null || sp.brandCode == '') && (sp.accountId == null) 
                    && (sp.channelCode == null || sp.channelCode == '') && (sp.regionCode == null || sp.regionCode == '')) {
                defaultParams.add(sp);
            }
        }
    }

    public static LAT_Rest_OpportunityFlex.SyncParam getParam(LAT_OpportunityHandlerJSON.Detail oppItem) {
        LAT_Rest_OpportunityFlex.SyncParam param;
        if(mapParamsByAccountId.get(Integer.valueOf(acc.Client_code_AN8__c)) != null) {
            for(LAT_Rest_OpportunityFlex.SyncParam p : mapParamsByAccountId.get(Integer.valueOf(acc.Client_code_AN8__c))) {
                if(p.brandCode == mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.key__c) {
                    return p;
                }
            }
            for(LAT_Rest_OpportunityFlex.SyncParam p : mapParamsByAccountId.get(Integer.valueOf(acc.Client_code_AN8__c))) {
                if(p.brandCode == null) {
                    return p;
                }
            }
        }
        if(mapParamsByRegion.get(acc.Regional__r.CodDefUsuario__c) != null) {
            for(LAT_Rest_OpportunityFlex.SyncParam p : mapParamsByRegion.get(acc.Regional__r.CodDefUsuario__c)) {
                if(p.brandCode == mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.key__c) {
                    return p;
                }
            }
            for(LAT_Rest_OpportunityFlex.SyncParam p : mapParamsByRegion.get(acc.Regional__r.CodDefUsuario__c)) {
                if(p.brandCode == null) {
                    return p;
                }
            }
        }
        if(mapParamsByChannel.get(acc.Client_code_AN8__c) != null) {
            for(LAT_Rest_OpportunityFlex.SyncParam p : mapParamsByChannel.get(acc.Client_code_AN8__c)) {
                if(p.brandCode == mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.key__c) {
                    return p;
                }
            }
            for(LAT_Rest_OpportunityFlex.SyncParam p : mapParamsByChannel.get(acc.Client_code_AN8__c)) {
                if(p.brandCode == null) {
                    return p;
                }
            }
        }
        if(mapParamsByBrand.get(mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c) != null) {
            for(LAT_Rest_OpportunityFlex.SyncParam p : mapParamsByBrand.get(mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c)) {
                if((p.brandCode == null  || p.brandCode == '') && (p.regionCode == null || p.regionCode == '') && (p.channelCode == null || p.channelCode == '') &&(p.accountId == null)) {
                    return p;
                }
            }
        }
        if(defaultParams.size() > 0) {
            return defaultParams[0];
        } else {
            return null;
        }
    }
    
    public static String mockResponse() {
        String json = '{';
        json += '  \"header\": {';
        json += '    \"id\": \"58e7c7f4\",';
        json += '    \"owner\": null,';
        json += '    \"name\": \"B2W COMPANHIA GLOBAL DO VAREJO - 17/10/2018\",';
        json += '    \"account\": \"001D0000015iAB7IAM\",';
        json += '    \"customerOrderNr\": \"PRueba Javi #3 18/10.\",';
        json += '    \"accountAN8\": \"172811\",';
        json += '    \"businessUnit\": \"17\",';
        json += '    \"freighpetTy\": null,';
        json += '    \"message1\": null,';
        json += '    \"message2\": null,';
        json += '    \"flexJustification\": null,';
        json += '    \"lastItemModifiedDate\": \"2018-10-17T19:57:42.705Z\",';
        json += '    \"creationDateTime\": \"2018-10-17T19:57:42.705Z\",';
        json += '    \"jdeOrderNumber\": null,';
        json += '    \"source\": null,';
        json += '    \"type\": \"SO\",';
        json += '    \"type_Z\": \"SO\",';
        json += '    \"stage\": \"Mobile Order\",';
        json += '    \"closeDate\": \"2018-10-17T19:55:32.962Z\",';
        json += '    \"deliveryDate\": \"2018-10-17T03:00:00.000Z\",';
        json += '    \"sugestedDeliveryDate\": \"\",';
        json += '    \"totalAmmount\": 31881.360000000004,';
        json += '    \"totalBoxes\": null,';
        json += '    \"recordType\": null,';
        json += '    \"hasBackorder\": null,';
        json += '    \"creditLimitBalance\": null,';
        json += '    \"parentAccount\": null,';
        json += '    \"actionCode\": null,';
        json += '    \"LastModifiedDate\": null,';
        json += '    \"mxPaymentCondition\": \"a4yD0000000Ce63IAC\",';
        json += '    \"mxPurchaseOrderSince\": \"\",';
        json += '    \"mxPurchaseOrderUntil\": \"\",';
        json += '    \"mxCreditCollectionsStatus\": null,';
        json += '    \"mxLogisticsStatus\": null,';
        json += '    \"currency\": \"BRL\",';
        json += '    \"totalFreightPercent\": 3.0,';
        json += '    \"totalPalletQuantity\": 0.01,';
        json += '    \"marginalContribution\": null,';
        json += '    \"isFlex\": false';
        json += '  },';
        json += '  \"detail\": [';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": true';
        json += '    }';
        json += '  ]';
        json += '}';
        return json;
    }
}