public with sharing class LAT_BridgeGS1_Order {
    public static final String QUERY_OPP_BR = ' SELECT id, LAT_Account__r.Business_Unit__r.CodDefUsuario__c, OwnerId,LAT_Integration__c, LAT_SentToJDE__c,      LAT_Account__r.Regional__c, LAT_Account__r.Sub_Channel__c,'+
                       'LAT_Account__r.Sub_Channel_Rating__c,LAT_Account__r.Customer_Flag__c, LAT_CDAction__c, LAT_Account__r.Owner.C_digo_JDE__c, LAT_DTDelivery__c,'+
                       'LAT_Account__r.Business_Unit__c, LAT_Freight__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_CloseDate__c, LAT_Account__r.Client_code_AN8__c, LAT_Account__r.Parent.Client_code_AN8__c, CreatedDate,'+
                       'LAT_Type__c, LAT_NROrderJDE__c, LAT_CDOrderStatus__c, LAT_NRCustomerOrder__c, Aquila_Id__c, LAT_OrderOrigin__c, RecordTypeId,'+
                       'LAT_ItemsTotalQuantity__c, LAT_CancelOrder__c, LAT_StageName__c, LAT_IsFlex__c, LAT_FlexManagerApprove__c, LAT_FlexApproved__c, LAT_Country__c, LAT_Account__r.ParentId,'+
                       '(SELECT LAT_CDAction__c, LAT_SkuText__c, LAT_PaymentCondition__c, LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Quantity__c, LAT_UnitCode__c, LAT_PercentualBonus__c,'+
                       ' LAT_PcDiscount__c, LAT_CdLineStatus__c, LAT_AR_Discount__c, LAT_Remover__c, LAT_CDUnit__c, LAT_Sku__c FROM OpportunityLineItems__r '+
                       'WHERE LAT_CdLineStatus__c<>\'999\') '+
                       'FROM LAT_Opportunity__c WHERE Id = \'XXX_oppId_XXX\' LIMIT 1';
    public static final String QUERY_OPP_AR = 'SELECT id, LAT_CDAction__c, LAT_Account__r.Owner.C_digo_JDE__c, LAT_DTDelivery__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, LAT_Account__r.Business_Unit_AR__c,'+
                               'LAT_Freight__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_CloseDate__c, LAT_Account__r.Client_code_AN8__c, CreatedDate, '+
                               'LAT_Type__c, LAT_NROrderJDE__c, LAT_CDOrderStatus__c, LAT_NRCustomerOrder__c, LAT_OrderOrigin__c, RecordTypeId,'+
                               'RecordType.Name, LAT_StageName__c, LAT_Account__r.ParentId, LAT_Country__c, LAT_AR_CreditLimitBalance__c, LAT_LeadSource__c,'+
                               '(SELECT LAT_CDAction__c, LAT_SkuText__c, LAT_PaymentCondition__c, LAT_Sku__c,'+
                               'LAT_NROrder_Item__c, LAT_QTBonus__c, LAT_Quantity__c, LAT_CdUnitBonification__c, LAT_UnitCode__c, LAT_PercentualBonus__c, '+
                               'LAT_PcDiscount__c, LAT_CdLineStatus__c, LAT_AR_UOM__c, LAT_AR_Discount__c, LAT_AR_SentToApproveDiscount__c,'+
                               'LAT_Remover__c, LAT_FormatField__c, LAT_AR_MaxDiscount__c, LAT_NROrderLine__c, LAT_JDETotalDiscount__c '+
                               'FROM OpportunityLineItems__r WHERE LAT_CdLineStatus__c<>\'999\') '+
                               'FROM LAT_Opportunity__c WHERE Id = \'XXX_oppId_XXX\' LIMIT 1';
    public static final String QUERY_OPP_MX = 'SELECT Id, LAT_ClientCodeAN8__c, Aquila_Id__c, LAT_NROrderJDE__c, LAT_NRCustomerOrder__c, LAT_CloseDate__c, LAT_EstimatedDeliveryDate__c, LAT_Type__c, RecordTypeId,'+
                       'LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_CDReturn__c, LAT_Account__r.Payment_Condition__r.CodDefUsuario__c, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_MX_PurchaseOrderSince__c, LAT_MX_PurchaseOrderUntil__c, '+
                       'LAT_MX_RetentionReason__c, LAT_JDEIntegrationReturn__c, LAT_Country__c, LAT_Account__r.Owner.C_digo_JDE__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, '+
                       'LAT_MX_OppCancellationReason__c, LAT_Freight__c, LAT_Account__r.Client_code_AN8__c, LAT_Account__r.Parent.Client_code_AN8__c,LAT_Account__r.ParentId,LAT_StageName__c, LAT_OrderOrigin__c, LAT_DTDelivery__c'+
                       ',createddate, (SELECT Id, LAT_NROrderLine__c, LAT_Sku__c, LAT_Quantity__c, LAT_PaymentCondition__c, LAT_CDUnit__c, LAT_Remover__c, LAT_MX_CancellationReason__c FROM OpportunityLineItems__r) '+
                       'FROM LAT_Opportunity__c '+
                       'WHERE Id = \'XXX_oppId_XXX\' LIMIT 1';


    public static final String QUERY_OPP_UY = '';

    public static final String eanucc   = 'urn:ean.ucc:2';
    public static final String xsi      = 'http://www.w3.org/2001/XMLSchema-instance';
    public static final String sh       = 'http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader';
    public static final String order      = 'urn:ean.ucc:order:2';

    private static String actionCode;
    private static String nroIdentificador;

    public LAT_BridgeGS1_Order() {
        
    }

    public static String getStringCountry(String oppId){
        LAT_Opportunity__c opp = [SELECT Id, LAT_Country__c FROM LAT_Opportunity__c WHERE Id = :oppId];
        System.debug('%%% opp.LAT_Country__c : ' + opp.LAT_Country__c);
        switch on String.valueOf(opp.LAT_Country__c) {
            when '1' {       
                return 'Brasil';
            }   
            when '5' {       
                return 'Uruguay';
            }  
            when '6' {       
                return 'Argentina';
            }  
            when '12' {       
                return 'México';
            } 
        }
        return 'NOT_FOUND';

    } 

    public static String getQueryString(String country, String oppId){
        
        switch on country {
            when 'Brasil' {       
                return QUERY_OPP_BR.replace('XXX_oppId_XXX', oppId);
            }   
            when 'Uruguay' {       
                return QUERY_OPP_AR.replace('XXX_oppId_XXX', oppId);
            }  
            when 'Argentina' {       
                return QUERY_OPP_AR.replace('XXX_oppId_XXX', oppId);
            }  
            when 'México' {       
                return QUERY_OPP_MX.replace('XXX_oppId_XXX', oppId);
            } 
        }

        return 'NOT_FOUND';
    }

    public static LAT_Opportunity__c getOpportunity(String country, String oppId){
        String query = getQueryString(country, oppId);
        System.debug('%%%% query : '+ query);
        LAT_Opportunity__c opp = Database.query(query);
        return opp;
    }

    public static void setActionCode(LAT_Opportunity__c opp, String country){

        actionCode ='A';
        for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r){
            if(country == 'Brasil') {
                if(oli.LAT_CDAction__c == 'C'){
                    actionCode ='C';
                    break;
                }
            } else {
                if(oli.LAT_Remover__c){
                    actionCode ='C';
                    break;
                }
            }
            
        }
    }

    public static void setNroIdentificador(LAT_Opportunity__c opp){
        nroIdentificador = opp.LAT_OrderOrigin__c=='EDI'? opp.LAT_NRCustomerOrder__c :opp.Id;
        System.Debug('nroIdentificador : ' + nroIdentificador);
    }
    public static Integer execute(String idSalesforce){


        String country = getStringCountry(idSalesforce);
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        LAT_Opportunity__c opp = getOpportunity(country, idSalesforce);
        setNroIdentificador(opp);
        setActionCode(opp, country);
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode standardBusinessDocumentNode = getStandardBusinessDocument(doc);
        setStandardBusinessDocumentHeader(standardBusinessDocumentNode, cred, opp);
        DOM.XmlNode message = getMessageNode(standardBusinessDocumentNode, opp);
        DOM.XmlNode transactio = getTransactionNode(message, opp);
        DOM.XmlNode command = getCommandNode(transactio, opp, cred, true, country);
       
        System.debug('%%%% doc : ' + doc.toXmlString());
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        req.setEndpoint(cred.LAT_NewSalesOrderHandlerEndpoint__c);
        System.debug('URL a la cual viaja: ' + cred.LAT_NewSalesOrderHandlerEndpoint__c);
        req.setHeader('Content-Type', 'text/xml');

        //Blob headerValue = Blob.valueOf('pr-eu/eurs1appbiztalk' + ':' + 'Password56');
        Blob headerValue = Blob.valueOf(cred.Bridge_Username__c + ':' + cred.Bridge_Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('ApiKey', '5f79ce38-b4c2-4121-999c-c3a7d0d2252f');
        req.setHeader('ApiKey', cred.Bridge_API_Key__c);
        
        System.debug('Doc generado: ' + doc.toXmlString());

        req.setBodyDocument(doc);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return 0;

    }

    public static Integer executeEDI_SORIN(String idSalesforce, Boolean releaseOrder){


        String country = getStringCountry(idSalesforce);
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        LAT_Opportunity__c opp = getOpportunity(country, idSalesforce);
        actionCode ='C'; //Action code para modificación.
        setNroIdentificador(opp);
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode standardBusinessDocumentNode = getStandardBusinessDocument(doc);
        setStandardBusinessDocumentHeader(standardBusinessDocumentNode, cred, opp);
        DOM.XmlNode message = getMessageNode(standardBusinessDocumentNode, opp);
        DOM.XmlNode transactio = getTransactionNode(message, opp);
        DOM.XmlNode command = getCommandNode(transactio, opp, cred, releaseOrder, country);

        System.debug('%%%% doc : ' + doc.toXmlString());
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        req.setEndpoint(cred.LAT_NewSalesOrderHandlerEndpoint__c);
        System.debug('URL a la cual viaja: ' + cred.LAT_NewSalesOrderHandlerEndpoint__c);
        req.setHeader('Content-Type', 'text/xml');

        //Blob headerValue = Blob.valueOf('pr-eu/eurs1appbiztalk' + ':' + 'Password56');
        Blob headerValue = Blob.valueOf(cred.Bridge_Username__c + ':' + cred.Bridge_Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('ApiKey', '5f79ce38-b4c2-4121-999c-c3a7d0d2252f');
        req.setHeader('ApiKey', cred.Bridge_API_Key__c);
        
        System.debug('Doc generado: ' + doc.toXmlString());

        req.setBodyDocument(doc);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return 0;

    }

    public static DOM.XmlNode getStandardBusinessDocument(DOM.Document doc){
        Dom.XmlNode envelope = doc.createRootElement('StandardBusinessDocument', sh, 'sh');
        envelope.setNamespace('xsi', xsi);
        envelope.setNamespace('eanucc', eanucc);
        return envelope;
    }
    
    public static DOM.XmlNode getStandardBusinessDocument_SORDRSP(DOM.Document doc){
        Dom.XmlNode envelope = doc.createRootElement('StandardBusinessDocument', sh, 'sh');
        envelope.setNamespace('eanucc', eanucc);
        envelope.setNamespace('order', order);
        return envelope;
    }
    
    public static Integer executeEDI_SORDRSP(String idSalesforce, String paramCod){


        String country = getStringCountry(idSalesforce);
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        LAT_Opportunity__c opp = getOpportunity(country, idSalesforce);
        nroIdentificador = opp.LAT_NROrderJDE__c;
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode standardBusinessDocumentNode = getStandardBusinessDocument_SORDRSP(doc);
        setStandardBusinessDocumentHeader_SORDRSP(standardBusinessDocumentNode, cred, opp);
        DOM.XmlNode message = getMessageNode_SORDRSP(standardBusinessDocumentNode, opp);
        DOM.XmlNode transactio = getTransactionNode_SORDRSP(message, opp);
        DOM.XmlNode command = getCommandNode_SORDRSP(transactio, opp, cred, paramCod);

        System.debug('%%%% doc : ' + doc.toXmlString());
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        req.setEndpoint(cred.LAT_NewSalesOrderHandlerEndpoint__c);
        System.debug('URL a la cual viaja: ' + cred.LAT_NewSalesOrderHandlerEndpoint__c);
        req.setHeader('Content-Type', 'text/xml');

        //Blob headerValue = Blob.valueOf('pr-eu/eurs1appbiztalk' + ':' + 'Password56');
        Blob headerValue = Blob.valueOf(cred.Bridge_Username__c + ':' + cred.Bridge_Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('ApiKey', '5f79ce38-b4c2-4121-999c-c3a7d0d2252f');
        req.setHeader('ApiKey', cred.Bridge_API_Key__c);
        
        System.debug('Doc generado: ' + doc.toXmlString());

        req.setBodyDocument(doc);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return 0;

    }
    public static DOM.XmlNode setStandardBusinessDocumentHeader(DOM.XmlNode standardBusinessDocumentNode, CS001_JDEInterfaceCredentials__c cred, LAT_Opportunity__c opp){
        String processCompanyCode = cred.PriceCalcCompanyParam__c;
        Dom.XmlNode node
            = standardBusinessDocumentNode.addChildElement('sh:StandardBusinessDocumentHeader', null, null);
        
        node.addChildElement('sh:HeaderVersion', null, null).
           addTextNode('1.0');
        node.addChildElement('sh:Sender', null, null).
            addChildElement('sh:Identifier', null, null).
                addTextNode('SalesForce');
        //Set  <ns0:Identifier><processCompanyCode></ns0:Identifier>
        Dom.XmlNode processCompanyCodeNode = 
        node.addChildElement('sh:Receiver', null, null).
             addChildElement('sh:Identifier', null, null).
                addTextNode(processCompanyCode);

        Dom.XmlNode documentIdentification = node.addChildElement('sh:DocumentIdentification', null, null);
        documentIdentification.addChildElement('sh:Standard', null, null).
                addTextNode('EAN.UCC');
        documentIdentification.addChildElement('sh:TypeVersion', null, null).
                addTextNode('2.6');
        //Set <ns0:InstanceIdentifier><headerOrderNumberForeign></ns0:InstanceIdentifier>
        documentIdentification.addChildElement('sh:InstanceIdentifier', null, null).
                addTextNode(opp.LAT_OrderOrigin__c=='EDI'? opp.LAT_NRCustomerOrder__c :opp.Id);
        documentIdentification.addChildElement('sh:Type', null, null).
                addTextNode('multiShipmentOrder');
        documentIdentification.addChildElement('sh:MultipleType', null, null).
                addTextNode('false');
        //Set  <ns0:CreationDateAndTime><headerInvoiceDate></ns0:CreationDateAndTime>
        documentIdentification.addChildElement('sh:CreationDateAndTime', null, null).
                addTextNode(String.valueOf(opp.LAT_CloseDate__c) + 'T00:00:00');
        return node;
    }

    public static DOM.XmlNode setStandardBusinessDocumentHeader_SORDRSP(DOM.XmlNode standardBusinessDocumentNode, CS001_JDEInterfaceCredentials__c cred, LAT_Opportunity__c opp){
        String processCompanyCode = cred.PriceCalcCompanyParam__c;
        Dom.XmlNode node
            = standardBusinessDocumentNode.addChildElement('sh:StandardBusinessDocumentHeader', null, null);
        
        node.addChildElement('sh:HeaderVersion', null, null).
           addTextNode('1.0');
        node.addChildElement('sh:Sender', null, null).
            addChildElement('sh:Identifier', null, null).
                addTextNode('SalesForce');
        //Set  <ns0:Identifier><processCompanyCode></ns0:Identifier>
        Dom.XmlNode processCompanyCodeNode = 
        node.addChildElement('sh:Receiver', null, null).
             addChildElement('sh:Identifier', null, null).
                addTextNode('7891050000019');

        Dom.XmlNode documentIdentification = node.addChildElement('sh:DocumentIdentification', null, null);
        documentIdentification.addChildElement('sh:Standard', null, null).
                addTextNode('EAN.UCC');
        documentIdentification.addChildElement('sh:TypeVersion', null, null).
                addTextNode('2.5');
        //Set <ns0:InstanceIdentifier><headerOrderNumberForeign></ns0:InstanceIdentifier>
        documentIdentification.addChildElement('sh:InstanceIdentifier', null, null).
                addTextNode(nroIdentificador);
        documentIdentification.addChildElement('sh:Type', null, null).
                addTextNode('OrderResponse');
        documentIdentification.addChildElement('sh:MultipleType', null, null).
                addTextNode('false');
        //Set  <ns0:CreationDateAndTime><headerInvoiceDate></ns0:CreationDateAndTime>
        documentIdentification.addChildElement('sh:CreationDateAndTime', null, null).
                addTextNode(String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss')));
        return node;
    }

    public static DOM.XmlNode getMessageNode(DOM.XmlNode standardBusinessDocumentNode, LAT_Opportunity__c opp) {
        Dom.XmlNode message = standardBusinessDocumentNode.addChildElement('eanucc:message', null, null);
        Dom.XmlNode messageEntityIdentification = message.addChildElement('entityIdentification', null, null);
        
        messageEntityIdentification.addChildElement('uniqueCreatorIdentification', null, null).
                addTextNode('MSG-'+nroIdentificador);
        return message;
    }

    public static DOM.XmlNode getMessageNode_SORDRSP(DOM.XmlNode standardBusinessDocumentNode, LAT_Opportunity__c opp) {
        Dom.XmlNode message = standardBusinessDocumentNode.addChildElement('eanucc:message', null, null);
        Dom.XmlNode messageEntityIdentification = message.addChildElement('entityIdentification', null, null);
        messageEntityIdentification.addChildElement('uniqueCreatorIdentification', null, null).
                addTextNode('MSG-'+nroIdentificador);
        return message;
    }
 
    public static DOM.XmlNode getTransactionNode(DOM.XmlNode message, LAT_Opportunity__c opp) {
        Dom.XmlNode transactio = message.addChildElement('eanucc:transaction', null, null);
        transactio.addChildElement('entityIdentification', null, null).addChildElement('uniqueCreatorIdentification', null, null).
                addTextNode('TRA-'+nroIdentificador);

        return transactio;
        
    }
    public static DOM.XmlNode getTransactionNode_SORDRSP(DOM.XmlNode message, LAT_Opportunity__c opp) {
        Dom.XmlNode transactio = message.addChildElement('eanucc:transaction', null, null);
        transactio.addChildElement('entityIdentification', null, null).addChildElement('uniqueCreatorIdentification', null, null).
                addTextNode('TRA-'+nroIdentificador);

        return transactio;
        
    }

    public static DOM.XmlNode getCommandNode(DOM.XmlNode transactio, LAT_Opportunity__c opp, CS001_JDEInterfaceCredentials__c cred, Boolean releaseOrder, String country) {
        String strAN8 = null;

        if(country == 'México') {
            strAN8 = opp.LAT_Account__r.ParentId == null? opp.LAT_Account__r.Client_code_AN8__c : opp.LAT_Account__r.Parent.Client_code_AN8__c;
        } else {
            strAN8 = opp.LAT_Account__r.Client_code_AN8__c;
        }

        Dom.XmlNode command = transactio.addChildElement('command', null, null).addChildElement('eanucc:documentCommand', null, null);
        setDocumentCommandHeader(command, opp);
        Dom.XmlNode documentCommandOperand = command.addChildElement('documentCommandOperand', null, null);
        Dom.XmlNode orderMultiShipmentOrder = getOrderMultiShipmentOrder(documentCommandOperand, opp);
        setOrderIdentificationr(orderMultiShipmentOrder, opp);
        setOrderPartyInformation(orderMultiShipmentOrder, opp, cred, strAN8);
        setOrderLogisticalInformation(orderMultiShipmentOrder, opp);
        setmultiShipmentOrderLineItems(orderMultiShipmentOrder, opp);
        setAdditionalOrderInstruction(orderMultiShipmentOrder, opp);
        if(country == 'México') {
            setPaymentTerms(orderMultiShipmentOrder, opp);
        }
        setExtension(orderMultiShipmentOrder, opp, releaseOrder);

        return command;
    }

    public static DOM.XmlNode getCommandNode_SORDRSP(DOM.XmlNode transactio, LAT_Opportunity__c opp, CS001_JDEInterfaceCredentials__c cred, String paramCod) {
        Dom.XmlNode command = transactio.addChildElement('command', null, null).addChildElement('eanucc:documentCommand', null, null);
        setDocumentCommandHeader_SORDRSP(command, opp);
        Dom.XmlNode documentCommandOperand = command.addChildElement('documentCommandOperand', null, null);
        Dom.XmlNode orderResponse = getOrderResponse_SORDRSP(documentCommandOperand, opp, paramCod);
        setResponseIdentification(orderResponse, opp);
        setResponseToOriginalDocument(orderResponse, opp);
        setSeller(orderResponse, opp);
        setBuyer(orderResponse, opp);

        return command;
    }

    public static void setDocumentCommandHeader(DOM.XmlNode command, LAT_Opportunity__c opp){
        Dom.XmlNode documentCommandHeader = command.addChildElement('documentCommandHeader', null, null);
        documentCommandHeader.setAttribute('type',actionCode);

        Dom.XmlNode documentCommandHeaderEntityIdentification = documentCommandHeader.addChildElement('entityIdentification', null, null);
        documentCommandHeaderEntityIdentification.addChildElement('uniqueCreatorIdentification', null, null).
                addTextNode('CMD-'+nroIdentificador);
    }
    
    public static void setDocumentCommandHeader_SORDRSP(DOM.XmlNode command, LAT_Opportunity__c opp){
        Dom.XmlNode documentCommandHeader = command.addChildElement('documentCommandHeader', null, null);
        documentCommandHeader.setAttribute('type','ADD');
        Dom.XmlNode documentCommandHeaderEntityIdentification = documentCommandHeader.addChildElement('entityIdentification', null, null);
        documentCommandHeaderEntityIdentification.addChildElement('uniqueCreatorIdentification', null, null).
                addTextNode('CMD-'+nroIdentificador);
    }

    public static DOM.XmlNode getOrderMultiShipmentOrder(DOM.XmlNode documentCommandOperand, LAT_Opportunity__c opp){
        Dom.XmlNode orderMultiShipmentOrder = documentCommandOperand.addChildElement('order:multiShipmentOrder', null, null);
        orderMultiShipmentOrder.setAttribute('creationDateTime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        //StartDT.format(’yyyy-MM-dd\’T\‘HH:mm:ss’,‘America/New_York’);
        orderMultiShipmentOrder.setAttribute('documentStatus', 'ORIGINAL');
        orderMultiShipmentOrder.setNamespace('order', 'urn:ean.ucc:order:2');
        return orderMultiShipmentOrder;
    }
    
    public static DOM.XmlNode getOrderResponse(DOM.XmlNode documentCommandOperand, LAT_Opportunity__c opp){
        Dom.XmlNode orderResponse = documentCommandOperand.addChildElement('order:orderResponse', null, null);
        orderResponse.setAttribute('creationDateTime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        //StartDT.format(’yyyy-MM-dd\’T\‘HH:mm:ss’,‘America/New_York’);
        orderResponse.setAttribute('documentStatus', 'ORIGINAL');
        return orderResponse;
    }
    
    public static DOM.XmlNode getOrderResponse_SORDRSP(DOM.XmlNode documentCommandOperand, LAT_Opportunity__c opp, String paramCod){
        Dom.XmlNode orderResponse = documentCommandOperand.addChildElement('order:orderResponse', null, null);
        orderResponse.setAttribute('creationDateTime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        //StartDT.format(’yyyy-MM-dd\’T\‘HH:mm:ss’,‘America/New_York’);
        orderResponse.setAttribute('documentStatus', 'REJECTED');
        orderResponse.setAttribute('responseStatusType', paramCod);

        return orderResponse;
    }
    public static void setResponseIdentification(DOM.XmlNode orderResponse, LAT_Opportunity__c opp){

        Dom.XmlNode responseIdentification = orderResponse.addChildElement('responseIdentification', null, null);
        Dom.XmlNode uniqueCreatorIdentification = responseIdentification.addChildElement('uniqueCreatorIdentification', null, null);
        Dom.XmlNode contentOwner = responseIdentification.addChildElement('contentOwner', null, null);
        contentOwner.addChildElement('gln', null, null).
                addTextNode('0000000000000');
        Dom.XmlNode additionalPartyIdentification = contentOwner.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(opp.LAT_Account__r.Client_code_AN8__c);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }
    
    public static void setResponseToOriginalDocument(DOM.XmlNode orderResponse, LAT_Opportunity__c opp){

        Dom.XmlNode responseToOriginalDocument = orderResponse.addChildElement('responseToOriginalDocument', null, null);
        responseToOriginalDocument.setAttribute('referenceDocumentType','3');
        String key = nroIdentificador + '|SO';
        responseToOriginalDocument.setAttribute('referenceIdentification', key );
        responseToOriginalDocument.setAttribute('referenceDateTime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
    }

    public static void setSeller(DOM.XmlNode orderResponse, LAT_Opportunity__c opp){

        Dom.XmlNode seller = orderResponse.addChildElement('seller', null, null);
        seller.addChildElement('gln', null, null).
                addTextNode('0000000000000');
        Dom.XmlNode additionalPartyIdentification = seller.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode('00200');
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }
    
    public static void setBuyer(DOM.XmlNode orderResponse, LAT_Opportunity__c opp){
        Dom.XmlNode buyer = orderResponse.addChildElement('buyer', null, null);
        buyer.addChildElement('gln', null, null).
                addTextNode('0000000000000');
        Dom.XmlNode additionalPartyIdentification = buyer.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(opp.LAT_Account__r.Client_code_AN8__c);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }
    

    public static void setOrderIdentificationr(DOM.XmlNode orderMultiShipmentOrder, LAT_Opportunity__c opp){

        Dom.XmlNode orderIdentification = orderMultiShipmentOrder.addChildElement('orderIdentification', null, null);
        Dom.XmlNode uniqueCreatorIdentification = orderIdentification.addChildElement('uniqueCreatorIdentification', null, null);
        //if(opp.LAT_NRCustomerOrder__c != null)
            //uniqueCreatorIdentification.addTextNode(opp.LAT_NRCustomerOrder__c);
        String uniqueCreatorIdentificationCode = actionCode == 'C' ? opp.LAT_OrderOrigin__c=='EDI'? nroIdentificador : opp.LAT_NROrderJDE__c : opp.Id;
        uniqueCreatorIdentification.addTextNode(uniqueCreatorIdentificationCode);
        Dom.XmlNode contentOwner = orderIdentification.addChildElement('contentOwner', null, null);
        contentOwner.addChildElement('gln', null, null).
                addTextNode('0000000000000');
        Dom.XmlNode additionalPartyIdentification = contentOwner.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(opp.LAT_Account__r.Client_code_AN8__c);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }

    public static void setOrderPartyInformation(DOM.XmlNode orderMultiShipmentOrder, LAT_Opportunity__c opp, CS001_JDEInterfaceCredentials__c cred, String strAN8){
        String processCompanyCode = cred.PriceCalcCompanyParam__c;
        Dom.XmlNode orderPartyInformation = orderMultiShipmentOrder.addChildElement('orderPartyInformation', null, null);

        Dom.XmlNode seller = orderPartyInformation.addChildElement('seller', null, null);
        seller.addChildElement('gln', null, null).
                addTextNode('0000000000000');   
        Dom.XmlNode sellerAdditionalPartyIdentification = seller.addChildElement('additionalPartyIdentification', null, null);
        sellerAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(processCompanyCode);
        sellerAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');

        Dom.XmlNode buyer = orderPartyInformation.addChildElement('buyer', null, null);
        buyer.addChildElement('gln', null, null).
                addTextNode('0000000000000');   
        Dom.XmlNode buyerAdditionalPartyIdentification = buyer.addChildElement('additionalPartyIdentification', null, null);


        buyerAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(strAN8);//16556          

        buyerAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }   

    public static void setOrderLogisticalInformation(DOM.XmlNode orderMultiShipmentOrder, LAT_Opportunity__c opp){
        
        Dom.XmlNode orderLogisticalInformation = orderMultiShipmentOrder.addChildElement('orderLogisticalInformation', null, null);     
        Dom.XmlNode shipToLogistics = orderLogisticalInformation.addChildElement('shipToLogistics', null, null);   
        Dom.XmlNode shipTo = shipToLogistics.addChildElement('shipTo', null, null);  
        shipTo.addChildElement('gln', null, null).
                addTextNode('0000000000000');  
        Dom.XmlNode shipToAdditionalPartyIdentification = shipTo.addChildElement('additionalPartyIdentification', null, null);
        shipToAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(opp.LAT_Account__r.Client_code_AN8__c);
        shipToAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');

        Dom.XmlNode shipFrom = shipToLogistics.addChildElement('shipFrom', null, null);  
        shipFrom.addChildElement('gln', null, null).
                addTextNode('0000000000000');  
        String businesUnit;
        if(opp.LAT_Country__c == 1){
                businesUnit = opp.LAT_Account__r.Business_Unit__r.CodDefUsuario__c;
            } else {
                businesUnit = opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c;
            }
        Dom.XmlNode shipFromAdditionalPartyIdentification = shipFrom.addChildElement('additionalPartyIdentification', null, null);
        shipFromAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(businesUnit);
        shipFromAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');

        Dom.XmlNode orderLogisticalDateGroup = orderLogisticalInformation.addChildElement('orderLogisticalDateGroup', null, null);   
        Dom.XmlNode requestedDeliveryDate = orderLogisticalDateGroup.addChildElement('requestedDeliveryDate', null, null).
            addChildElement('date', null, null).   
            addTextNode(String.valueOf(Date.valueOf(opp.LAT_CloseDate__c))+'T00:00:00');
        Date purchaseOrderUntil = Date.today();
        if(opp.LAT_Country__c == 12 && opp.LAT_MX_PurchaseOrderUntil__c != null){
            purchaseOrderUntil = opp.LAT_MX_PurchaseOrderUntil__c;
        }
        Dom.XmlNode requestedDeliveryDateRange = orderLogisticalDateGroup.addChildElement('requestedDeliveryDateRange', null, null).
        addChildElement('latest', null, null).   
        addTextNode(String.valueOf(Date.valueOf(purchaseOrderUntil))+'T00:00:00');
    }

    public static void setMultiShipmentOrderLineItems(DOM.XmlNode orderMultiShipmentOrder, LAT_Opportunity__c opp){
        Integer i = 0;
        Integer nroLinea = 0;
        for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r){  
            Boolean oliIsCancel = false;
            Boolean oliIsEdit = false;
            if(opp.LAT_OrderOrigin__c == 'EDI'){
                oliIsEdit = true;
            }
            if(opp.LAT_Country__c == 1){
                if(oli.LAT_CDAction__c == 'C'){
                    oliIsCancel = true;
                    oli.LAT_Remover__c = true;
                }
                    
            } else {
                oliIsCancel = oli.LAT_Remover__c;
            }
            if(actionCode =='A' || (actionCode =='C' && oliIsCancel) || oliIsEdit){
                i++;
                Dom.XmlNode multiShipmentOrderLineItem = orderMultiShipmentOrder.addChildElement('multiShipmentOrderLineItem', null, null); 
                if(actionCode !='A'){
                    nroLinea = Integer.valueOf(oli.LAT_NROrderLine__c) / 1000;
                }
                
                multiShipmentOrderLineItem.setAttribute('number', actionCode =='A'? String.valueOf(i) : String.valueOf(nroLinea));

                Dom.XmlNode requestedQuantity = multiShipmentOrderLineItem.addChildElement('requestedQuantity', null, null);
                requestedQuantity.addChildElement('value', null, null).
                        addTextNode(String.valueOf(oli.LAT_Quantity__c));
                String unitOfMeasure;
                if(opp.LAT_Country__c == 1 || opp.LAT_Country__c == 12) {
                    unitOfMeasure = oli.LAT_CDUnit__c;
                } else {
                    unitOfMeasure = oli.LAT_AR_UOM__c;
                }
                requestedQuantity.addChildElement('unitOfMeasure', null, null).
                        addChildElement('measurementUnitCodeValue', null, null).
                            addTextNode(unitOfMeasure);
                Dom.XmlNode netPrice = multiShipmentOrderLineItem.addChildElement('netPrice', null, null).
                        addChildElement('amount', null, null).
                            addChildElement('monetaryAmount', null, null);

                Dom.XmlNode tradeItemIdentification = multiShipmentOrderLineItem.addChildElement('tradeItemIdentification', null, null);
                tradeItemIdentification.addChildElement('gtin', null, null).
                        addTextNode('00000000000000');
                Dom.XmlNode additionalTradeItemIdentification = tradeItemIdentification.addChildElement('additionalTradeItemIdentification', null, null);
                additionalTradeItemIdentification.addChildElement('additionalTradeItemIdentificationValue', null, null).
                            addTextNode(oli.LAT_Sku__c);
                additionalTradeItemIdentification.addChildElement('additionalTradeItemIdentificationType', null, null).
                            addTextNode('SUPPLIER_ASSIGNED');
                String oliActionCode = oli.LAT_Remover__c ? 'D' : oliIsEdit? 'C' : 'A';
                Dom.XmlNode lineItemActionCode = multiShipmentOrderLineItem.addChildElement('lineItemActionCode', null, null).
                        addTextNode(oliActionCode);

                Dom.XmlNode allowanceCharge = multiShipmentOrderLineItem.addChildElement('allowanceCharge', null, null); 
                allowanceCharge.setAttribute('allowanceChargeType', 'ALLOWANCE_GLOBAL');
                allowanceCharge.setAttribute('allowanceOrChargeType', 'ALLOWANCE');
                allowanceCharge.setAttribute('settlementType', 'CHARGE_TO_BE_PAID_BY_VENDOR');
                allowanceCharge.setAttribute('effectiveDateType', 'EFFECTIVE_DATE');
                allowanceCharge.addChildElement('allowanceChargePriceBracket', null, null).
                        addChildElement('bracketIdentifier', null, null).
                            addTextNode('DiscountPercentage');
                Dom.XmlNode percentage = allowanceCharge.addChildElement('monetaryAmountOrPercentage', null, null).
                        addChildElement('percentage', null, null);
                if(opp.LAT_Country__c != 12 && oli.LAT_AR_Discount__c!=null)
                            percentage.addTextNode(String.valueOf(oli.LAT_AR_Discount__c));

            }
            
        }
    }

    public static void setAdditionalOrderInstruction(DOM.XmlNode orderMultiShipmentOrder, LAT_Opportunity__c opp){
        String message = '';
        if(opp.LAT_DSMessage1__c != null) message += opp.LAT_DSMessage1__c + ' ';
        if(opp.LAT_DSMessage2__c != null) message += opp.LAT_DSMessage2__c;
        orderMultiShipmentOrder.addChildElement('additionalOrderInstruction', null, null).
                    addChildElement('longText', null, null).
                        addTextNode(message);
    }

    public static void setPaymentTerms(DOM.XmlNode orderMultiShipmentOrder, LAT_Opportunity__c opp){
        String paymentTermCode = opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c == null ? opp.LAT_Account__r.Payment_Condition__r.CodDefUsuario__c : opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c;

        Dom.XmlNode paymentTerms = orderMultiShipmentOrder.addChildElement('paymentTerms', null, null);
        paymentTerms.addTextNode('');
        paymentTerms.setAttribute('paymentTermsType', paymentTermCode);
    }

    public static void setExtension(DOM.XmlNode orderMultiShipmentOrder, LAT_Opportunity__c opp, Boolean releaseOrder){
        Dom.XmlNode extension = orderMultiShipmentOrder.addChildElement('extension', null, null); 
        extension.addChildElement('orderCreationDate', null, null).
            addTextNode(String.valueOf(opp.LAT_CloseDate__c)); 
        extension.addChildElement('externalOrderReference', null, null).
            addTextNode(opp.Id); 
        if(opp.Aquila_Id__c != null || opp.LAT_NRCustomerOrder__c != null) {
            extension.addChildElement('additionalReferenceNumber', null, null).
            addTextNode(opp.Aquila_Id__c != null? opp.Aquila_Id__c : opp.LAT_NRCustomerOrder__c); 
        } 
        
        extension.addChildElement('orderTypeCode', null, null).
             addTextNode(opp.LAT_Type__c!=null? opp.LAT_Type__c.substring(0, 2) : '');
    
        extension.addChildElement('deliveryInstructions', null, null);
        extension.addChildElement('shippingInstructions', null, null);
        if(!releaseOrder){
            extension.addChildElement('orderStatus', null, null).
                addTextNode('REJECTED');
        }
    }

    public static void sendRequest(String endpoint)
    {

        /*
        dom.XmlNode body
            = envelope.addChildElement('Body', soapNS, null);
        
        body.addChildElement('echo', serviceNS, 'req').
           addChildElement('category', serviceNS, null).  
           addTextNode('classifieds');
        
        System.debug(doc.toXmlString());
        
        // Send the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/xml');

        Blob headerValue = Blob.valueOf('pr-eu/eurs1appbiztalk' + ':' + 'Password56');
        //Blob headerValue = Blob.valueOf(cred.Bridge_Username__c + ':' + cred.Bridge_Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('ApiKey', '5f79ce38-b4c2-4121-999c-c3a7d0d2252f');

        req.setBodyDocument(doc);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        /*
        System.assertEquals(200, res.getStatusCode());
        
        dom.Document resDoc = res.getBodyDocument();
        
        envelope = resDoc.getRootElement();
        
        String wsa = 'http://schemas.xmlsoap.org/ws/2004/08/addressing';
        
        dom.XmlNode header = envelope.getChildElement('Header', soapNS);
        System.assert(header != null);
        
        String messageId
            = header.getChildElement('MessageID', wsa).getText();
        
        System.debug(messageId);
        System.debug(resDoc.toXmlString());
        System.debug(resDoc);
        System.debug(header);
        
        System.assertEquals(
         'http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous',
         header.getChildElement(
           'ReplyTo', wsa).getChildElement('Address', wsa).getText());
        
        
        System.assertEquals(
          envelope.getChildElement('Body', soapNS).
              getChildElement('echo', serviceNS).
              getChildElement('something', 'http://something.else').
              getChildElement(
                'whatever', serviceNS).getAttribute('bb', null),
                'cc');
        
        System.assertEquals('classifieds',
          envelope.getChildElement('Body', soapNS).
              getChildElement('echo', serviceNS).
              getChildElement('category', serviceNS).getText());
        */
    }

    @future(callout=true)
    public static void integrateEdiOrder(String oppId){
        try{
            LAT_Opportunity__c opp = [SELECT Id, LAT_OrderOrigin__c, (SELECT Id, LAT_IsOKEDI__c FROM OpportunityLineItems__r) FROM LAT_Opportunity__c WHERE Id = :oppId];
            Boolean releaseOrder = true;
            for(LAT_OpportunityLineItem__c line: opp.OpportunityLineItems__r){
                if(!line.LAT_IsOKEDI__c) {
                    releaseOrder = false;
                    break;
                }
                    
            }
            if(opp.LAT_OrderOrigin__c == 'EDI'){
                executeEDI_SORIN(oppId, releaseOrder);
                executeEDI_SORDRSP(oppId, 'FI');
                
                opp.LAT_StageName__c = 'Pedido EDI Enviado Para JDE'; 
                opp.LAT_EDI_NeedsToAdvanceStatus__c = releaseOrder;
                update opp;
            } else {
                System.debug('%%%%% No se envía el pedido por no ser EDI, ID:' + oppId);
            }
        } catch(Exception e){
            System.debug('%%%%% Error al enviar pedido EDI a JDE : '+ e);
        }
         
        
    }

    public static void sendRequest2(String endpoint)
    {
        // Create the request envelope
        DOM.Document doc = new Dom.Document();
        doc.load(getExampleXML());

        
        // Send the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/xml');
        Blob headerValue = Blob.valueOf('pr-eu/eurs1appbiztalk' + ':' + 'Password56');
        //Blob headerValue = Blob.valueOf(cred.Bridge_Username__c + ':' + cred.Bridge_Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('ApiKey', '5f79ce38-b4c2-4121-999c-c3a7d0d2252f');

        req.setBodyDocument(doc);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        /*
        System.assertEquals(200, res.getStatusCode());
        
        dom.Document resDoc = res.getBodyDocument();
        
        envelope = resDoc.getRootElement();
        
        String wsa = 'http://schemas.xmlsoap.org/ws/2004/08/addressing';
        
        dom.XmlNode header = envelope.getChildElement('Header', soapNS);
        System.assert(header != null);
        
        String messageId
            = header.getChildElement('MessageID', wsa).getText();
        
        System.debug(messageId);
        System.debug(resDoc.toXmlString());
        System.debug(resDoc);
        System.debug(header);
        
        System.assertEquals(
         'http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous',
         header.getChildElement(
           'ReplyTo', wsa).getChildElement('Address', wsa).getText());
        
        
        System.assertEquals(
          envelope.getChildElement('Body', soapNS).
              getChildElement('echo', serviceNS).
              getChildElement('something', 'http://something.else').
              getChildElement(
                'whatever', serviceNS).getAttribute('bb', null),
                'cc');
        
        System.assertEquals('classifieds',
          envelope.getChildElement('Body', soapNS).
              getChildElement('echo', serviceNS).
              getChildElement('category', serviceNS).getText());
        */
    }


    public static string getExampleGetOrderDetail(){
        return '<soapenv:Envelope '+
        '   xmlns:orac="http://oracle.e1.bssv.JP56LA11/" '+
        '   xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'+
        '   <soap:Header '+
        '      xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
        '      <Security '+
        '         soap:mustUnderstand="1" '+
        '         xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" '+
        '         xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'+
        '         <UsernameToken>'+
        '            <Username>ARCRM</Username>'+
        '            <Password '+
        '               Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">CONNECTAR</Password>'+
        '         </UsernameToken>'+
        '      </Security>'+
        '   </soap:Header>'+
        '   <soapenv:Body>'+
        '      <orac:getSalesOrder>'+
        '         <actionCode>2</actionCode>'+
        '         <documentOrderNo>31150|SM|00100</documentOrderNo>'+
        '         <ediTransactionType>56LASOMM</ediTransactionType>'+
        '         <orderCompany>00100</orderCompany>'+
        '         <orderType/>'+
        '      </orac:getSalesOrder>'+
        '   </soapenv:Body>'+
        '</soapenv:Envelope>';
    }

    public static string getExampleXML(){
        return '<sh:StandardBusinessDocument xmlns:sh="http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader" xmlns:eanucc="urn:ean.ucc:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
        ' <sh:StandardBusinessDocumentHeader>'+
        '<sh:HeaderVersion>1.0</sh:HeaderVersion>'+
        '<sh:Sender>'+
        '   <sh:Identifier>3015060500992</sh:Identifier>'+
        '</sh:Sender>'+
        '<sh:Receiver>'+
        '   <sh:Identifier>7702614000010</sh:Identifier>'+
        '</sh:Receiver>'+
        '<sh:DocumentIdentification>'+
        '   <sh:Standard>EAN.UCC</sh:Standard>'+
        '   <sh:TypeVersion>2.5</sh:TypeVersion>'+
        '   <sh:InstanceIdentifier>26000005</sh:InstanceIdentifier>'+
        '   <sh:Type>multiShipmentOrder</sh:Type>'+
        '   <sh:MultipleType>false</sh:MultipleType>'+
        '   <sh:CreationDateAndTime>2018-06-07T01:16:18</sh:CreationDateAndTime>'+
        '</sh:DocumentIdentification>'+
        '   </sh:StandardBusinessDocumentHeader>'+
        '   <eanucc:message>'+
        '<entityIdentification>'+
        '   <uniqueCreatorIdentification>MSG_26000005</uniqueCreatorIdentification>'+
        '   <contentOwner>'+
        '       <gln>3015060500992</gln>'+
        '   </contentOwner>'+
        '</entityIdentification>'+
        '<eanucc:transaction>'+
        '   <entityIdentification>'+
        '       <uniqueCreatorIdentification>TRA_26000005</uniqueCreatorIdentification>'+
        '       <contentOwner>'+
        '           <gln>3015060500992</gln>'+
        '       </contentOwner>'+
        '   </entityIdentification>'+
        '   <command>'+
        '       <eanucc:documentCommand>'+
        '           <documentCommandHeader type="ADD">'+
        '               <entityIdentification>'+
        '                   <uniqueCreatorIdentification>CMD_26000005</uniqueCreatorIdentification>'+
        '                   <contentOwner>'+
        '                       <gln>3015060500992</gln>'+
        '                   </contentOwner>'+
        '               </entityIdentification>'+
        '           </documentCommandHeader>'+
        '           <documentCommandOperand>'+
        '               <order:multiShipmentOrder xmlns:order="urn:ean.ucc:order:2" creationDateTime="2018-06-07T01:16:18" documentStatus="ORIGINAL">'+
        '                   <orderIdentification>'+
        '                       <uniqueCreatorIdentification>26000005</uniqueCreatorIdentification>'+
        '                       <contentOwner>'+
        '                           <gln>7702614000010</gln>'+
        '                           <additionalPartyIdentification>'+
        '                               <additionalPartyIdentificationValue>C0030</additionalPartyIdentificationValue>'+
        '                               <additionalPartyIdentificationType>BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY</additionalPartyIdentificationType>'+
        '                           </additionalPartyIdentification>'+
        '                       </contentOwner>'+
        '                   </orderIdentification>'+
        '                   <orderPartyInformation>'+
        '                       <seller>'+
        '                           <gln>5000299000007</gln>'+
        '                           <additionalPartyIdentification>'+
        '                               <additionalPartyIdentificationValue>C0003</additionalPartyIdentificationValue>'+
        '                               <additionalPartyIdentificationType>BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY</additionalPartyIdentificationType>'+
        '                               <!-- Could be SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY code if you have PR code-->'+
        '                           </additionalPartyIdentification>'+
        '                       </seller>'+
        '                       <buyer>'+
        '                           <gln>7702614000010</gln>'+
        '                           <additionalPartyIdentification>'+
        '                               <additionalPartyIdentificationValue>C0030</additionalPartyIdentificationValue>'+
        '                               <additionalPartyIdentificationType>BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY</additionalPartyIdentificationType>'+
        '                               <!-- Could be SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY code if you have PR code-->'+
        '                           </additionalPartyIdentification>'+
        '                       </buyer>'+
        '                       <orderContact>'+
        '                           <personOrDepartmentName>'+
        '                               <description>'+
        '                                   <language>'+
        '                                       <languageISOCode>EN</languageISOCode>'+
        '                                   </language>'+
        '                                   <text>Victor Villalba</text>'+
        '                               </description>'+
        '                           </personOrDepartmentName>'+
        '                       </orderContact>'+
        '                   </orderPartyInformation>'+
        '                   <orderLogisticalInformation>'+
        '                       <shipToLogistics>'+
        '                           <shipTo>'+
        '                               <gln>0000000000000</gln>'+
        '                               <additionalPartyIdentification>'+
        '                                   <additionalPartyIdentificationValue>4980</additionalPartyIdentificationValue>'+
        '                                   <additionalPartyIdentificationType>BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY</additionalPartyIdentificationType>'+
        '                                   <!-- Could be SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY code if you have PR code-->'+
        '                               </additionalPartyIdentification>'+
        '                           </shipTo>'+
        '                           <shipFrom>'+
        '                               <gln>0000000000000</gln>'+
        '                               <additionalPartyIdentification>'+
        '                                   <additionalPartyIdentificationValue>W0074</additionalPartyIdentificationValue>'+
        '                                   <additionalPartyIdentificationType>BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY</additionalPartyIdentificationType>'+
        '                                   <!-- Could be SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY code if you have PR code-->'+
        '                               </additionalPartyIdentification>'+
        '                           </shipFrom>'+
        '                           <ultimateConsignee>'+
        '                               <gln>0000000000000</gln>'+
        '                               <additionalPartyIdentification>'+
        '                                   <additionalPartyIdentificationValue>W0074</additionalPartyIdentificationValue>'+
        '                                   <additionalPartyIdentificationType>BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY</additionalPartyIdentificationType>'+
        '                                   <!-- Could be SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY code if you have PR code-->'+
        '                               </additionalPartyIdentification>'+
        '                           </ultimateConsignee>'+
        '                       </shipToLogistics>'+
        '                       <orderLogisticalDateGroup>'+
        '                           <requestedDeliveryDate>'+
        '                               <date>2018-08-23</date>'+
        '                           </requestedDeliveryDate>'+
        '                       </orderLogisticalDateGroup>'+
        '                   </orderLogisticalInformation>'+
        '                   <multiShipmentOrderLineItem number="1">'+
        '                       <requestedQuantity>'+
        '                           <value>1120</value>'+
        '                           <unitOfMeasure>'+
        '                               <measurementUnitCodeValue>CA</measurementUnitCodeValue>'+
        '                           </unitOfMeasure>'+
        '                       </requestedQuantity>'+
        '                       <netPrice>'+
        '                           <amount>'+
        '                               <monetaryAmount>12916</monetaryAmount>'+
        '                           </amount>'+
        '                       </netPrice>'+
        '                       <tradeItemIdentification>'+
        '                           <gtin>10080432402785</gtin>'+
        '                           <additionalTradeItemIdentification>'+
        '                               <additionalTradeItemIdentificationValue>11</additionalTradeItemIdentificationValue>'+
        '                               <additionalTradeItemIdentificationType>BUYER_ASSIGNED</additionalTradeItemIdentificationType>'+
        '                               <!-- Will be decoded --> '+
        '                           </additionalTradeItemIdentification>'+
        '                           <additionalTradeItemIdentification>'+
        '                               <additionalTradeItemIdentificationValue>SS50006/01</additionalTradeItemIdentificationValue>'+
        '                               <additionalTradeItemIdentificationType>SUPPLIER_ASSIGNED</additionalTradeItemIdentificationType>'+
        '                               <!-- If it\'s PR code, decode will be skipped -->'+
        '                           </additionalTradeItemIdentification>'+
        '                       </tradeItemIdentification>'+
        '                       <lineItemActionCode>ADDITION</lineItemActionCode>'+
        '                       <allowanceCharge allowanceChargeType="CHARGE_GLOBAL" allowanceOrChargeType="CHARGE" settlementType="CHARGE_TO_BE_PAID_BY_CUSTOMER" effectiveDateType="EFFECTIVE_DATE">'+
        '                           <allowanceChargePriceBracket>'+
        '                               <bracketIdentifier>ExciseTax</bracketIdentifier>'+
        '                           </allowanceChargePriceBracket>'+
        '                           <monetaryAmountOrPercentage>'+
        '                               <amount>'+
        '                                   <currencyCode>'+
        '                                       <currencyISOCode>USD</currencyISOCode>'+
        '                                   </currencyCode>'+
        '                                   <monetaryAmount>9234</monetaryAmount>'+
        '                               </amount>'+
        '                           </monetaryAmountOrPercentage>'+
        '                       </allowanceCharge>'+
        '                       <shipmentDetail>'+
        '                           <requestedQuantity>'+
        '                               <value>1</value>'+
        '                           </requestedQuantity>'+
        '                           <shipTo>'+
        '                               <gln>7701001452203</gln>'+
        '                           </shipTo>'+
        '                           <shipmentTransportationInformation transportationMethodType="AIR" />'+
        '                       </shipmentDetail>'+
        '                   </multiShipmentOrderLineItem>'+
        '                   <multiShipmentOrderLineItem number="2">'+
        '                       <requestedQuantity>'+
        '                           <value>225</value>'+
        '                           <unitOfMeasure>'+
        '                               <measurementUnitCodeValue>CA</measurementUnitCodeValue>'+
        '                           </unitOfMeasure>'+
        '                       </requestedQuantity>'+
        '                       <netPrice>'+
        '                           <amount>'+
        '                               <monetaryAmount>12916</monetaryAmount>'+
        '                           </amount>'+
        '                       </netPrice>'+
        '                       <tradeItemIdentification>'+
        '                           <gtin>05000299211267</gtin>'+
        '                           <additionalTradeItemIdentification>'+
        '                               <additionalTradeItemIdentificationValue>131</additionalTradeItemIdentificationValue>'+
        '                               <additionalTradeItemIdentificationType>BUYER_ASSIGNED</additionalTradeItemIdentificationType>'+
        '                           </additionalTradeItemIdentification>'+
        '                           <additionalTradeItemIdentification>'+
        '                               <additionalTradeItemIdentificationValue>0609904/01</additionalTradeItemIdentificationValue>'+
        '                               <additionalTradeItemIdentificationType>SUPPLIER_ASSIGNED</additionalTradeItemIdentificationType>'+
        '                           </additionalTradeItemIdentification>'+
        '                       </tradeItemIdentification>'+
        '                       <lineItemActionCode>ADDITION</lineItemActionCode>'+
        '                       <allowanceCharge allowanceChargeType="CHARGE_GLOBAL" allowanceOrChargeType="CHARGE" settlementType="CHARGE_TO_BE_PAID_BY_CUSTOMER" effectiveDateType="EFFECTIVE_DATE">'+
        '                           <allowanceChargePriceBracket>'+
        '                               <bracketIdentifier>ExciseTax</bracketIdentifier>'+
        '                           </allowanceChargePriceBracket>'+
        '                           <monetaryAmountOrPercentage>'+
        '                               <amount>'+
        '                                   <currencyCode>'+
        '                                       <currencyISOCode>USD</currencyISOCode>'+
        '                                   </currencyCode>'+
        '                                   <monetaryAmount>9234</monetaryAmount>'+
        '                               </amount>'+
        '                           </monetaryAmountOrPercentage>'+
        '                       </allowanceCharge>'+
        '                       <shipmentDetail>'+
        '                           <requestedQuantity>'+
        '                               <value>1</value>'+
        '                           </requestedQuantity>'+
        '                           <shipTo>'+
        '                               <gln>7701001452203</gln>'+
        '                           </shipTo>'+
        '                           <shipmentTransportationInformation transportationMethodType="AIR" />'+
        '                       </shipmentDetail>'+
        '                   </multiShipmentOrderLineItem>'+
        '                   <additionalOrderInstruction>'+
        '                       <longText/>'+
        '                   </additionalOrderInstruction>'+
        '                   <extension>'+
        '                       <orderCreationDate>2018-06-06</orderCreationDate>'+
        '                       <requestedShipDate/>'+
        '                       <promisedDeliveryDate/>'+
        '                       <additionalReferenceNumber/>'+
        '                       <orderCancellDate/>'+
        '                       <deliveryInstructions/>'+
        '                       <shippingInstructions/>'+
        '                   </extension>'+
        '               </order:multiShipmentOrder>'+
        '           </documentCommandOperand>'+
        '       </eanucc:documentCommand>'+
        '   </command>'+
        '</eanucc:transaction>'+
        '   </eanucc:message>'+
        ' </sh:StandardBusinessDocument>';
    }

}