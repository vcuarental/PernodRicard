public with sharing class LAT_BridgeGS1_Customer {
    public class BridgeException extends Exception {}

    public static final String QUERY_OPP_BR = '';
    public static final String QUERY_OPP_AR = '';
    public static final String QUERY_OPP_MX = 'SELECT Id, Accept_applications_Incompleted__c, Accept_Backorder__c, Accept_line_incompleted__c, '+
                                                'AccountNumber, AddressLine1_AR__c, Billing_Priority__c, Business_Unit__r.CodDefUsuario__c, '+
                                                'Business_Unit_AR__r.CodDefUsuario__c, Channel__c, Client_code_AN8__c, Client_country_AN8__c, '+
                                                'CNPJ__c, Corporate_Name__c, Credit_line__c, CurrencyISOCode, Customer_GL__r.CodDefUsuario__c, Customer_GL__c, '+
                                                'Is_interface_Process_AR__c, LAT_MX_ABCCode__r.CodDefUsuario__c, LAT_MX_AmountReceiptCopies__c, LAT_MX_BatchProcess__c, '+
                                                'LAT_MX_BatchProcess__r.CodDefUsuario__c, LAT_MX_BreakDownIEPS__c, LAT_MX_CableCodeS__c, '+
                                                'LAT_MX_Chain__r.CodDefUsuario__c, LAT_MX_City__c, LAT_MX_County__c, LAT_MX_CreditVersionLevel__c, '+
                                                'LAT_MX_CRMClientCode__c, LAT_MX_FiscalEntityType__c, LAT_MX_FiscalRate__r.CodDefUsuario__c, '+
                                                'LAT_MX_Group__r.CodDefUsuario__c, LAT_MX_Language__c, LAT_MX_Market__c, LAT_MX_Neighbourhood__c, '+
                                                'LAT_MX_PostalCode__r.Name,  LAT_MX_CreditAndCollectionsExecutive__r.Name, LAT_MX_CreditAndCollectionsExecutive__r.C_digo_JDE__c, LAT_MX_RelatedAddressAN8__c, LAT_MX_RouteCode__r.CodDefUsuario__c, '+
                                                'LAT_MX_State__c, LAT_MX_ZoneNumber__r.CodDefUsuario__c, Name, Owner.C_digo_JDE__c, Owner.Email, '+
                                                'Owner.Name, ParentId, Parent.Client_code_AN8__c, Payment_Condition__r.CodDefUsuario__c, '+
                                                'Payment_instrument__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, Return_JDE_Integration__c, '+
                                                'Revenue_Country__c, Revenue_Number__c, Segmentation_Type_on_trade__c, Status__c, Phone, Fax, Website, LAT_MX_BetweenStreets__c '+
                                                'FROM Account '+
                                                'WHERE Id = \'XXX_accId_XXX\' LIMIT 1';


    public static final String QUERY_OPP_UY = '';

    public static final String eanucc   = 'urn:ean.ucc:2';
    public static final String xsi      = 'http://www.w3.org/2001/XMLSchema-instance';
    public static final String sh       = 'http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader';
    public static final String gdsn      = 'urn:ean.ucc:gdsn:2';

    private static String actionCode;
    private static String nroIdentificador;

    private static String country;
    private static String countryCode;
    private static String countryShort;
    private static String countryLanguage;
        
    public LAT_BridgeGS1_Customer() {
        
    }

    public static String setCountry(String accId){
        Account acc = [SELECT Id, RecordType.Developername, Client_Code_An8__c FROM Account WHERE Id = :accId];
        System.debug('%%% acc.RecordType.Developername : ' + acc.RecordType.Developername);
        if(acc.RecordType.Developername == 'LAT_MX_ACC_OffTrade'){   
            country = 'México';
            countryCode = '00902';
            countryShort = 'MX';
            countryLanguage = 'S';
            
           
        } 
        actionCode = acc.Client_Code_An8__c != '' && acc.Client_Code_An8__c != null ? 'C' : 'A';
        return 'NOT_FOUND';

    } 

    public static String getQueryString(String country, String accId){
        
        switch on country {
            when 'Brasil' {       
                return QUERY_OPP_BR.replace('XXX_accId_XXX', accId);
            }   
            when 'Uruguay' {       
                return QUERY_OPP_AR.replace('XXX_accId_XXX', accId);
            }  
            when 'Argentina' {       
                return QUERY_OPP_AR.replace('XXX_accId_XXX', accId);
            }  
            when 'México' {       
                return QUERY_OPP_MX.replace('XXX_accId_XXX', accId);
            } 
        }

        return 'NOT_FOUND';
    }

    public static Account getAccount(String country, String accId){
        String query = getQueryString(country, accId);
        System.debug('%%%% query : '+ query);
        Account acc = Database.query(query);
        return acc;
    }

    public static Integer execute(String idSalesforce, LAT_DebugUtil debugUtil){
        setCountry(idSalesforce);
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        Account acc = getAccount(country, idSalesforce);

        System.debug('acc.Client_Code_AN8__c : ' + acc.Client_Code_AN8__c);

        DOM.Document doc = new DOM.Document();
        DOM.XmlNode standardBusinessDocumentNode = getStandardBusinessDocument(doc);
        setStandardBusinessDocumentHeader(standardBusinessDocumentNode, cred, acc);
        DOM.XmlNode message = getMessageNode(standardBusinessDocumentNode, acc);
        DOM.XmlNode transactio = getTransactionNode(message, acc);
        DOM.XmlNode command = getCommandNode(transactio, acc, cred);


        System.debug('%%%% doc : ' + doc.toXmlString());
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        req.setEndpoint(cred.LAT_NewSalesOrderHandlerEndpoint__c);
        //req.setEndpoint('https://z-bin.herokuapp.com/xo09mgxo');
        System.debug('URL a la cual viaja: ' + cred.LAT_NewSalesOrderHandlerEndpoint__c);
        req.setHeader('Content-Type', 'text/xml');

        //Blob headerValue = Blob.valueOf('pr-eu/eurs1appbiztalk' + ':' + 'Password56');
        Blob headerValue = Blob.valueOf(cred.Bridge_Username__c + ':' + cred.Bridge_Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('ApiKey', '5f79ce38-b4c2-4121-999c-c3a7d0d2252f');
        req.setHeader('ApiKey', cred.Bridge_API_Key__c);
        
        System.debug('Doc generado: ' + doc.toXmlString());
        
        if(debugUtil == null) {
            debugUtil = new LAT_DebugUtil();
        }

        debugUtil.addTitle('Request Start');
        debugUtil.addData(LAT_WS_CustomerHandlerInterface.BREAK_LINE + 'Endpoint: ' + cred.LAT_NewSalesOrderHandlerEndpoint__c + LAT_WS_CustomerHandlerInterface.BREAK_LINE + LAT_WS_CustomerHandlerInterface.BREAK_LINE);
        debugUtil.addData(LAT_WS_CustomerHandlerInterface.BREAK_LINE + 'Payload: ' + doc.toXmlString());
        debugUtil.addTitle('Request END');

        req.setBodyDocument(doc);
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        debugUtil.addTitle('Response Start');
        debugUtil.addData(LAT_WS_CustomerHandlerInterface.BREAK_LINE+ 'Response Body: ' + res.getBody() + LAT_WS_CustomerHandlerInterface.BREAK_LINE);
        debugUtil.addData(LAT_WS_CustomerHandlerInterface.BREAK_LINE+ 'Response Status: ' + res.getStatusCode() + LAT_WS_CustomerHandlerInterface.BREAK_LINE);
        debugUtil.addTitle('Response END');

        // Save debug info and update customer
        debugUtil.setOrigin('LAT_BridgeGS1_Customer');
        debugUtil.insertDebug();
    
        return 0;

    }

    public static DOM.XmlNode getStandardBusinessDocument(DOM.Document doc){
        Dom.XmlNode envelope = doc.createRootElement('StandardBusinessDocument', sh, 'sh');
        envelope.setNamespace('xsi', xsi);
        envelope.setNamespace('eanucc', eanucc);
        envelope.setNamespace('gdsn', gdsn);
        return envelope;
    }
    
    public static DOM.XmlNode setStandardBusinessDocumentHeader(DOM.XmlNode standardBusinessDocumentNode, CS001_JDEInterfaceCredentials__c cred, Account acc){
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
                addTextNode('2.7');
        documentIdentification.addChildElement('sh:InstanceIdentifier', null, null).
                addTextNode(acc.Id);
        documentIdentification.addChildElement('sh:Type', null, null).
                addTextNode('basicPartyRegistration');
        documentIdentification.addChildElement('sh:MultipleType', null, null).
                addTextNode('false');
        documentIdentification.addChildElement('sh:CreationDateAndTime', null, null).addTextNode('2006-01-10T12:00:01.000-05:00');
                //addTextNode(String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:sssZ')));
        return node;
    }

    public static DOM.XmlNode getMessageNode(DOM.XmlNode standardBusinessDocumentNode, Account acc) {
        Dom.XmlNode message = standardBusinessDocumentNode.addChildElement('eanucc:message', null, null);
        Dom.XmlNode messageEntityIdentification = message.addChildElement('entityIdentification', null, null);
        
        messageEntityIdentification.addChildElement('uniqueCreatorIdentification', null, null).
            addTextNode(acc.Id);
        messageEntityIdentification.addChildElement('contentOwner', null, null).
            addChildElement('gln', null, null).
                addTextNode('0000000000000');
        return message;
    }
 
    public static DOM.XmlNode getTransactionNode(DOM.XmlNode message, Account acc) {
        Dom.XmlNode transactio = message.addChildElement('eanucc:transaction', null, null);
        Dom.XmlNode transactionEntityIdentificator = transactio.addChildElement('entityIdentification', null, null);
        transactionEntityIdentificator.addChildElement('uniqueCreatorIdentification', null, null).
            addTextNode(acc.Id);
        transactionEntityIdentificator.addChildElement('contentOwner', null, null).
            addChildElement('gln', null, null).
                addTextNode('0000000000000');

        return transactio;
        
    }

    public static DOM.XmlNode getCommandNode(DOM.XmlNode transactio, Account acc, CS001_JDEInterfaceCredentials__c cred) {
        Dom.XmlNode command = transactio.addChildElement('command', null, null).addChildElement('eanucc:documentCommand', null, null);
        setDocumentCommandHeader(command, acc);
        Dom.XmlNode documentCommandOperand = command.addChildElement('documentCommandOperand', null, null);
        Dom.XmlNode basicPartyRegistration = getBasicPartyRegistration(documentCommandOperand, acc);
        setPartyIdentification(basicPartyRegistration, acc);
        setContentVersionAndStructure(basicPartyRegistration, acc);
        setProcessCapabilityInformation(basicPartyRegistration, acc);
        
        Dom.XmlNode registryParty = basicPartyRegistration.addChildElement('registryParty', null, null);
        setInformationProviderOfParty(registryParty);
        setIsPartyActive(registryParty);

        Dom.XmlNode registryPartyInformation = registryParty.addChildElement('registryPartyInformation', null, null);
        setPartyRoleInformation(registryPartyInformation);
        setRegistryPartyNameAndAddress(registryPartyInformation, acc);
        setContact(registryPartyInformation, acc);
        
        setExtension(basicPartyRegistration, acc);

        return command;
    }

    public static void setDocumentCommandHeader(DOM.XmlNode command, Account acc){
        Dom.XmlNode documentCommandHeader = command.addChildElement('documentCommandHeader', null, null);
        documentCommandHeader.setAttribute('type',actionCode);

        Dom.XmlNode documentCommandHeaderEntityIdentification = documentCommandHeader.addChildElement('entityIdentification', null, null);
        documentCommandHeaderEntityIdentification.addChildElement('uniqueCreatorIdentification', null, null).
                addTextNode(acc.Id);
        
        documentCommandHeaderEntityIdentification.addChildElement('contentOwner', null, null).
            addChildElement('gln', null, null).
                addTextNode('0000000000000');
    }

    public static DOM.XmlNode getBasicPartyRegistration(DOM.XmlNode documentCommandOperand, Account acc){
        Dom.XmlNode basicPartyRegistration = documentCommandOperand.addChildElement('gdsn:basicPartyRegistration', null, null);
        //basicPartyRegistration.setAttribute('creationDateTime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:sssZ'));
        basicPartyRegistration.setAttribute('creationDateTime', '2006-01-10T12:00:01.000-05:00');
        basicPartyRegistration.setAttribute('documentStatus', 'ORIGINAL');
        return basicPartyRegistration;
    }

    public static void setPartyIdentification(DOM.XmlNode basicPartyRegistration, Account acc){

        Dom.XmlNode partyIdentification = basicPartyRegistration.addChildElement('basicPartyRegistrationIdentification', null, null);
        Dom.XmlNode uniqueCreatorIdentification = partyIdentification.addChildElement('uniqueCreatorIdentification', null, null);
        uniqueCreatorIdentification.addTextNode(acc.Id);
        Dom.XmlNode contentOwner = partyIdentification.addChildElement('contentOwner', null, null);
        contentOwner.addChildElement('gln', null, null).
                addTextNode('0000000000000');
        Dom.XmlNode additionalPartyIdentification = contentOwner.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(countryCode);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
                addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }

    public static void setContentVersionAndStructure(DOM.XmlNode basicPartyRegistration, Account acc){

        basicPartyRegistration.addChildElement('contentVersion', null, null).
            addChildElement('versionIdentification', null, null).
                addTextNode('2.7');
        basicPartyRegistration.addChildElement('documentStructureVersion', null, null).
            addChildElement('versionIdentification', null, null).
                addTextNode('2.7');
    }

    public static void setProcessCapabilityInformation(DOM.XmlNode basicPartyRegistration, Account acc){

        DOM.XmlNode processCapabilityInformation = basicPartyRegistration.addChildElement('processCapabilityInformation', null, null);
        processCapabilityInformation.addChildElement('processCapabilityCode', null, null).
            addTextNode('DATA_SYNCHRONISATION');
        processCapabilityInformation.addChildElement('processCapabilityEffectiveStartDateTime', null, null).
            addTextNode('2007-05-17T10:00:00.000-05:00');
        processCapabilityInformation.addChildElement('processCapabilityEffectiveEndDateTime', null, null).
            addTextNode('2008-05-17T10:00:00.000-05:00');
    }
    
    public static void setInformationProviderOfParty(DOM.XmlNode registryParty){

        Dom.XmlNode informationProviderOfParty = registryParty.addChildElement('informationProviderOfParty', null, null);
        informationProviderOfParty.addChildElement('gln', null, null).
            addTextNode('0000000000000');
        Dom.XmlNode additionalPartyIdentification = informationProviderOfParty.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
            addTextNode(countryCode);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
            addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }

    public static void setIsPartyActive(DOM.XmlNode registryParty){
        registryParty.addChildElement('isPartyActive', null, null).
                addTextNode('TRUE');
    }

    public static void setPartyRoleInformation(DOM.XmlNode registryPartyInformation){
        DOM.XmlNode partyRoleInformation = registryPartyInformation.addChildElement('partyRoleInformation', null, null);
        partyRoleInformation.addChildElement('partyOrDepartmentName', null, null).
            addTextNode('Customer');
        partyRoleInformation.addChildElement('partyRole', null, null).
            addTextNode('BUYER');
    }
    
    public static void setRegistryPartyNameAndAddress(DOM.XmlNode registryPartyInformation, Account acc){
        DOM.XmlNode registryPartyNameAndAddress = registryPartyInformation.addChildElement('registryPartyNameAndAddress', null, null);
        registryPartyNameAndAddress.addChildElement('city', null, null).
            addTextNode(acc.LAT_MX_City__c!=null?acc.LAT_MX_City__c:'');
        registryPartyNameAndAddress.addChildElement('countryCode', null, null).
            addChildElement('countryISOCode', null, null).
                addTextNode(countryShort);
        registryPartyNameAndAddress.addChildElement('name', null, null).
            addTextNode(acc.Corporate_Name__c);
        registryPartyNameAndAddress.addChildElement('associatedLanguage', null, null).
            addChildElement('languageISOCode', null, null).
                addTextNode(countryLanguage);
        registryPartyNameAndAddress.addChildElement('postalCode', null, null).
            addTextNode(acc.LAT_MX_PostalCode__r.Name);
        registryPartyNameAndAddress.addChildElement('streetAddressOne', null, null).
            addTextNode(acc.AddressLine1_AR__c + ' '+  acc.Revenue_Number__c);

        registryPartyNameAndAddress.addChildElement('streetAddressTwo', null, null).
            addTextNode(acc.AddressLine1_AR__c + ' '+  acc.Revenue_Number__c);

        /** 
         * SE ENVIA IDE
        registryPartyNameAndAddress.addChildElement('streetAddressTwo', null, null).
            addTextNode(acc.LAT_MX_BetweenStreets__c !=null ? acc.LAT_MX_BetweenStreets__c : '');
        **/
    }

    public static void setContact(DOM.XmlNode registryPartyInformation, Account acc){
        DOM.XmlNode contact = registryPartyInformation.addChildElement('contact', null, null);
        Dom.XmlNode communicationChannelTel = contact.addChildElement('communicationChannel', null, null);
        communicationChannelTel.setAttribute('TELEPHONE', acc.Phone);
        Dom.XmlNode communicationChannelTel2 = contact.addChildElement('communicationChannel', null, null);
        communicationChannelTel2.setAttribute('EMAIL', '');
        Dom.XmlNode communicationChannelTel3 = contact.addChildElement('communicationChannel', null, null);
        communicationChannelTel3.setAttribute('TELEFAX', acc.Fax !=null ? acc.Fax : '');
        Dom.XmlNode communicationChannelTel4 = contact.addChildElement('communicationChannel', null, null);
        communicationChannelTel4.setAttribute('WEBSITE', acc.Website !=null ? acc.Website : '');

    }

    public static void setExtension(DOM.XmlNode basicPartyRegistration, Account acc){
        Dom.XmlNode extension = basicPartyRegistration.addChildElement('extension', null, null); 
        Dom.XmlNode partyInformation = setPartyInformation(extension, acc);
        String strCreditLimit = null;
        List<UDC__C> lstCollectionManager = null;
        UDC__C objCollectionManager = null;
        
        if(countryShort == 'MX' && acc.LAT_MX_CreditAndCollectionsExecutive__c != NULL ) {
            lstCollectionManager = [SELECT ID, CodDefUsuario__c FROM UDC__C WHERE CodUs__c = 'CM' AND CodProd__c = '01' AND Name =: acc.LAT_MX_CreditAndCollectionsExecutive__r.Name];
            if(!lstCollectionManager.IsEmpty()) {
                objCollectionManager = lstCollectionManager[0]; 
            }
        }
        
        strCreditLimit = (acc.Credit_line__c != null && acc.Credit_line__c > 0) ? String.valueOf(Long.valueOf(String.valueOf(acc.Credit_line__c))) : '';

        setPayer(partyInformation, acc);
        partyInformation.addChildElement('shipmentMethod', null, null).
            addTextNode('GEOGRAPHIC_RECEIVING');
        partyInformation.addChildElement('creditLimit', null, null).
            addTextNode( strCreditLimit );
        partyInformation.addChildElement('name2', null, null).
            addTextNode(acc.Name);
        partyInformation.addChildElement('salespersonCode', null, null);
        partyInformation.addChildElement('taxFreeReasonCode', null, null);
        partyInformation.addChildElement('customerTaxGroupCode', null, null);
        setPaymentTerms(partyInformation, acc);
        setSalesRepresentative(partyInformation, acc);
        partyInformation.addChildElement('subChannel', null, null).
            addTextNode(acc.Channel__c);
        partyInformation.addChildElement('class', null, null).
            addTextNode(acc.LAT_MX_Group__r.CodDefUsuario__c);
        partyInformation.addChildElement('taxRateArea', null, null).
            addTextNode(acc.LAT_MX_FiscalRate__r.CodDefUsuario__c);
        partyInformation.addChildElement('currencyISOCode', null, null).
            addTextNode(acc.CurrencyISOCode);
        partyInformation.addChildElement('salesRegion', null, null).
            addTextNode(acc.Regional__r.CodDefUsuario__c);
        partyInformation.addChildElement('stateISOCode', null, null).
            addTextNode(acc.LAT_MX_State__c);
        partyInformation.addChildElement('destinatedMarketArea', null, null).
            addTextNode(acc.lat_mx_market__c);
        partyInformation.addChildElement('channel', null, null).
            addTextNode(acc.Segmentation_Type_on_trade__c);
            partyInformation.addChildElement('group', null, null).
            addTextNode(acc.LAT_MX_Chain__r.CodDefUsuario__c);
        partyInformation.addChildElement('accountsReceivableAccountType', null, null).
            addTextNode(acc.Customer_GL__c != null? acc.Customer_GL__r.CodDefUsuario__c : '');
        partyInformation.addChildElement('taxRegistrationNumber', null, null).
            addTextNode(acc.CNPJ__c);
        partyInformation.addChildElement('deliveryRoute', null, null).
            addTextNode(acc.LAT_MX_RouteCode__r.CodDefUsuario__c);
        partyInformation.addChildElement('deliveryZone', null, null).
            addTextNode(acc.LAT_MX_ZoneNumber__r.CodDefUsuario__c);
        partyInformation.addChildElement('numberOfInvoiceCopies', null, null).
            addTextNode(acc.LAT_MX_AmountReceiptCopies__c!= null? acc.LAT_MX_AmountReceiptCopies__c : '');
        partyInformation.addChildElement('fiscalPreference', null, null).
            addTextNode(acc.LAT_MX_BatchProcess__c!= null? acc.LAT_MX_BatchProcess__r.CodDefUsuario__c : '');
        partyInformation.addChildElement('taxExplanationCode', null, null).
            addTextNode('V+');
        partyInformation.addChildElement('discountGroup', null, null).
            addTextNode(acc.Billing_Priority__c != null? 'G0' + acc.Billing_Priority__c : '');


        if(objCollectionManager != null && objCollectionManager.CodDefUsuario__c != null ) {
            partyInformation.addChildElement('collectionManagerCode', null, null).
                addTextNode(objCollectionManager.CodDefUsuario__c);
        } else {
            partyInformation.addChildElement('collectionManagerCode', null, null).
            addTextNode('');
        }

        partyInformation.addChildElement('creditCheckLevelCode', null, null).
            addTextNode(acc.LAT_MX_CreditVersionLevel__c!= null? acc.LAT_MX_CreditVersionLevel__c : '');
        partyInformation.addChildElement('abcMarginCustomerGroup', null, null).
            addTextNode(acc.LAT_MX_ABCCode__c!= null? acc.LAT_MX_ABCCode__r.CodDefUsuario__c : '');
        partyInformation.addChildElement('legalStatus', null, null).
            addTextNode(acc.LAT_MX_FiscalEntityType__c!= null? ((acc.LAT_MX_FiscalEntityType__c == 'Company')?'1':'2') : '');
    }

    public static Dom.XmlNode setPartyInformation(DOM.XmlNode extension, Account acc){
        Dom.XmlNode partyInformation = extension.addChildElement('partyInformation', null, null);
        //NO ENVIAR EL GLN
        //partyInformation.addChildElement('gln', null, null).
        //    addTextNode('0000000000000');
        //
        Dom.XmlNode partyInformationAdditionalPartyIdentification = partyInformation.addChildElement('additionalPartyIdentification', null, null);
        partyInformationAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
                addTextNode(actionCode=='C' ? acc.Client_Code_An8__c :acc.Id);
        partyInformationAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
            addTextNode(actionCode=='C' ? 'SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY' : 'BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
        Dom.XmlNode shipTo = partyInformation.addChildElement('shipTo', null, null);
        shipTo.addChildElement('gln', null, null).
            addTextNode('0000000000000');
        Dom.XmlNode shipToAdditionalPartyIdentification = shipTo.addChildElement('additionalPartyIdentification', null, null);
        shipToAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
            addTextNode('');
        shipToAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
            addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
        Dom.XmlNode shipFrom = partyInformation.addChildElement('shipFrom', null, null);
        shipFrom.addChildElement('gln', null, null).
            addTextNode('0000000000000');
        Dom.XmlNode shipFromAdditionalPartyIdentification = shipFrom.addChildElement('additionalPartyIdentification', null, null);
        shipFromAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
            addTextNode(acc.Business_Unit_AR__r.CodDefUsuario__c);
        shipFromAdditionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
            addTextNode('BUYER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
        return partyInformation;
    
    }

    public static void setPaymentTerms(DOM.XmlNode extension, Account acc){
        Dom.XmlNode paymentTerms = extension.addChildElement('paymentTerms', null, null);
        paymentTerms.setAttribute('paymentTermsType', acc.Payment_Condition__r.CodDefUsuario__c);
        paymentTerms.addChildElement('paymentMethod', null, null).
            addChildElement('paymentMethodType', null, null).
                addTextNode(acc.Payment_instrument__r.CodDefUsuario__c);
    }

    public static void setPayer(DOM.XmlNode partyInformation, Account acc){
        Dom.XmlNode payer = partyInformation.addChildElement('payer', null, null);
        Dom.XmlNode additionalPartyIdentification = payer.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
            addTextNode(acc.ParentId != null ? acc.Parent.Client_code_AN8__c : '');
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
            addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }

    public static void setSalesRepresentative(DOM.XmlNode extension, Account acc){
        Dom.XmlNode salesRepresentative = extension.addChildElement('salesRepresentative', null, null);
        Dom.XmlNode additionalPartyIdentification = salesRepresentative.addChildElement('additionalPartyIdentification', null, null);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationValue', null, null).
            addTextNode(acc.Owner.C_digo_JDE__c);
        additionalPartyIdentification.addChildElement('additionalPartyIdentificationType', null, null).
            addTextNode('SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY');
    }

    public static void setExtendedProperties(DOM.XmlNode extension, Account acc){
        Dom.XmlNode shortcutProperty1 = extension.addChildElement('shortcutProperty1', null, null);
        Dom.XmlNode shortcutProperty2 = extension.addChildElement('shortcutProperty2', null, null);
        Dom.XmlNode shortcutProperty3 = extension.addChildElement('shortcutProperty3', null, null);
        Dom.XmlNode shortcutProperty4 = extension.addChildElement('shortcutProperty4', null, null);
        Dom.XmlNode shortcutProperty5 = extension.addChildElement('shortcutProperty5', null, null);
        Dom.XmlNode shortcutProperty6 = extension.addChildElement('shortcutProperty6', null, null);
        Dom.XmlNode shortcutProperty7 = extension.addChildElement('shortcutProperty7', null, null);
        Dom.XmlNode shortcutProperty8 = extension.addChildElement('shortcutProperty8', null, null);
        Dom.XmlNode shortcutProperty9 = extension.addChildElement('shortcutProperty9', null, null);
        Dom.XmlNode shortcutProperty10 = extension.addChildElement('shortcutProperty10', null, null);
    }

}