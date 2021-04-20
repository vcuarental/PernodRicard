@RestResource(urlMapping='/LAT_Rest_OpportunityFlexEDI/*')
global with sharing class LAT_Rest_OpportunityFlexEDI {


    public static final String SYNC_BALANCE_METHOD = 'initialSyncBalance';
    public static final String SYNC_PARAMS_METHOD = 'initialSyncParams';
    public static boolean shouldhaveException;
    public static Account acc;
    public static String politicaDePrecios;
    public static Set<Id> setProdIds;

    @HttpPost
    global static void processPost() {
        RestRequest req = RestContext.request;
        LAT_OpportunityHandlerJSON pedido = (LAT_OpportunityHandlerJSON)System.JSON.deserialize(req.requestBody.toString(), LAT_OpportunityHandlerJSON.class);
        System.debug('Pedido : ' + JSON.serialize(pedido));
        System.debug('Pedido.account : ' + pedido.header.account);
        LAT_Rest_OpportunityFlex.ServiceResponse res;
        try{   
            res = processOpportunity(pedido);
        } catch(Exception e){
            res = new LAT_Rest_OpportunityFlex.ServiceResponse(e.getMessage(), 'FLEX_EDI_Error', false);
            if(pedido.header.aquilaId != null && pedido.header.aquilaId != ''){
                LAT_IMM_Logs__c log = new LAT_IMM_Logs__c(); 
                Map<Id, LAT_Product__c> mapProdById = new Map<Id, LAT_Product__c>([SELECT Id, Name,LAT_ScheduleC__r.KeyBrand__r.Key__c FROM LAT_Product__c WHERE Id IN:setProdIds]);    
                LAT_Rest_OpportunityFlex.acc = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c, Payment_Condition__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, LAT_Account__r.LAT_JDEZone__c FROM Account WHERE Id =:pedido.header.account LIMIT 1];
                
                LAT_Rest_OpportunityFlex.mapProdById = mapProdById;  
                String mesasge = LAT_Rest_OpportunityFlex.sendTransactionToAquila(pedido, mapProdById, log, true);
            }
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
        
        
    }

    public static LAT_Rest_OpportunityFlex.ServiceResponse processOpportunity(LAT_OpportunityHandlerJSON pedido){
        System.System.debug('Es un Update, ID Opp : '+ pedido.header.Id);
        if(LAT_GeneralConfig__c.getInstance('LAT_BR_FlexEDI_Enabled').LAT_Value__c != 'true') {
            return  new LAT_Rest_OpportunityFlex.ServiceResponse('Pedido EDI não pode ser liberado nesse momento. Em caso de dúvidas consultar Adm Vendas.', 'FlexEDINotEnabled', false);
        }
        Map<Id, LAT_OpportunityLineItem__c> mapOlisById = new Map<Id, LAT_OpportunityLineItem__c>([SELECT Id, LAT_NROrderLine__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =:pedido.header.Id]);
        setProdIds = new Set<Id>();
        Boolean integrateToIMM = false;
        for(LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
            oppItem.lineNumberJDE = mapOlisById.get(oppItem.Id).LAT_NROrderLine__c;
            if(oppItem.isFlex) {
                pedido.header.isFlex = true;
                integrateToIMM = true;
                setProdIds.add(oppItem.product);
            }
        }
        pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = pedido.header.flexApproveRegionalManager = pedido.header.flexApproveCommercialDirector = false; 
        if(integrateToIMM) {       
            LAT_IMM_Logs__c log = new LAT_IMM_Logs__c(); 
            Map<Id, LAT_Product__c> mapProdById = new Map<Id, LAT_Product__c>([SELECT Id, Name,LAT_ScheduleC__r.KeyBrand__r.Key__c FROM LAT_Product__c WHERE Id IN:setProdIds]);    
            LAT_Rest_OpportunityFlex.acc = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c, Payment_Condition__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, LAT_Account__r.LAT_JDEZone__c FROM Account WHERE Id =:pedido.header.account LIMIT 1];
             
            LAT_Rest_OpportunityFlex.mapProdById = mapProdById;  
            String mesasge = LAT_Rest_OpportunityFlex.sendTransactionToAquila(pedido, mapProdById, log);
            
            if(mesasge == 'OK'){
                LAT_Rest_OpportunityFlex.calculateApprovals(pedido);
                
                insert log;
            } else {
                insert log;
                return  new LAT_Rest_OpportunityFlex.ServiceResponse(mesasge, 'flex3Error', false);
            }
        }

        User usuario = [SELECT Id, ManagerId, Gerente_de_area__c, Gerente_regional__c FROM User WHERE Id = :UserInfo.getUserId()];
        LAT_Opportunity__c opp = new LAT_Opportunity__c();
        opp.Id = pedido.header.Id;
        opp.LAT_ManagerApprover__c                  = usuario.ManagerId;
        opp.LAT_DSMessage1__c                       = pedido.header.message1;
        opp.LAT_DSMessage2__c                       = pedido.header.message2;
        opp.LAT_FlexJustification__c		        = pedido.header.flexJustification;
        opp.LAT_FlexManagerApprove__c               = pedido.header.flexApproveManager;
        opp.LAT_FlexAreaManagerApprove__c      	    = pedido.header.flexApproveAreaManager;
        opp.LAT_FlexRegionalManagerApprove__c       = pedido.header.flexApproveRegionalManager;
        opp.LAT_FlexCommercialDirectorApprove__c    = pedido.header.flexApproveCommercialDirector;
        opp.LAT_IsFlex__c          	  = true;
        opp.Aquila_Id__c        = pedido.header.aquilaId;
        if(opp.LAT_FlexManagerApprove__c) {
            opp.LAT_Integration__c = true;
            opp.LAT_StageName__c = 'EDI Em Aprovação';
        }
        update opp;
        Set<Id> prodIds = new Set<Id>();
        for (LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
            prodIds.add(oppItem.product);
        }   
        
        Map<Id, LAT_Product__c> prods = new Map<Id, LAT_Product__c>([SELECT Id, LAT_ScheduleC__c FROM LAT_Product__c WHERE Id IN :prodIds]);
        List<LAT_FlexMaxDiscount__c> maxDiscounts = [SELECT LAT_MaxDiscount__c, LAT_ScheduleC__c FROM LAT_FlexMaxDiscount__c WHERE LAT_PricePolicy__c = :politicaDePrecios];
        Map<String, Decimal> maxDiscountsMap = new Map<String, Decimal>();
        for(LAT_FlexMaxDiscount__c d: maxDiscounts){
            maxDiscountsMap.put(d.LAT_ScheduleC__c, d.LAT_MaxDiscount__c);
        }

        List<LAT_OpportunityLineItem__c> lines = new List<LAT_OpportunityLineItem__c>();
        Boolean mustApprove = false;
        for (LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
            System.debug('%%%%% oppItem.actionCode : ' + oppItem.actionCode);
            LAT_OpportunityLineItem__c line = new LAT_OpportunityLineItem__c();
            line.Id                             = oppItem.Id;
            line.LAT_AR_Discount__c             = oppItem.discount;
            line.LAT_Quantity__c                = oppItem.quantity;
            line.LAT_PercentualOfBonus__c       = oppItem.percentualBonus;
            line.LAT_OriginalFlexAmount__c      = oppItem.flexAmount;
            line.LAT_OriginalNisAmount__c       = oppItem.baseNisAmount;
            line.LAT_FlexAmount__c              = oppItem.flexAmount;
            line.LAT_IdIMM__c					= oppItem.idImm;
            line.LAT_FlexFinalDiscount__c       = oppItem.finalFlexDiscount;
            line.LAT_IsFlex__c                  = oppItem.isFlex;
            line.LAT_IsOkEDI__c                 = oppItem.isOkEDI;
            line.LAT_FlexEDIProcessed__c        = true;
            if(prods.get(oppItem.product) != null){
                if(maxDiscountsMap.get(prods.get(oppItem.product).LAT_ScheduleC__c) != null){
                    line.LAT_FlexMaxDiscount__c = maxDiscountsMap.get(prods.get(oppItem.product).LAT_ScheduleC__c);
                }
            }
            if(line.LAT_OriginalNisAmount__c != null && line.LAT_Quantity__c != null && line.LAT_Quantity__c != 0 )
                line.LAT_OriginalUnitNisAmount__c   = line.LAT_OriginalNisAmount__c / line.LAT_Quantity__c;
            if(oppItem.actionCode == 'C'){
                line.LAT_CDAction__c                = oppItem.actionCode;
                line.LAT_Remover__c                 = true;
            } 
            if(oppItem.isOkEDI){
                //todo hacer que sea remove. (si no está cubierto en paso anterior)
            }
            lines.add(line);
        } 

        if(lines.size() > 0) {
            update lines;
        }

        if(opp.LAT_FlexManagerApprove__c){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(opp.id);
            Approval.ProcessResult result = Approval.process(req1);
        } else{
            LAT_BridgeGS1_Order.integrateEdiOrder(opp.id);
        }
        
        return  new LAT_Rest_OpportunityFlex.ServiceResponse(opp.Id);
    }

}