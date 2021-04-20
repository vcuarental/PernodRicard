public with sharing class EUR_NIM_JDEHandler  implements EUR_NIM_ERPHandler
{
    String soapenv = 'http://schemas.xmlsoap.org/soap/envelope/';
    String m = 'http://oracle.e1.bssv.JP56LA10/';
    String passwordType = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText';
    String wsse = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
    String wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd';
    String orac = 'http://oracle.e1.bssv.JP410000/';
    String encodingType = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary';

    public EUR_NIM_JDEHandler()
    {

    }

    public EUR_NIM_Service.RequestResponseWrapper calculatePrice(EUR_CRM_Account__c account, String urlPath, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        orac = 'http://oracle.e1.bssv.JP56LA10/';
        EUR_NIM_Service.RequestResponseWrapper pr = new EUR_NIM_Service.RequestResponseWrapper();
        List<EUR_NIM_Service.Lines> linesList = new List<EUR_NIM_Service.Lines>();

        String namedCredential = EUR_COMMON_Utils.getNamedCredential(account.EUR_CRM_Country_Code__c, EUR_COMMON_Utils.PRICE_SERVICE);
        Map<String, Object> unitTypeMappings =  EUR_COMMON_Utils.getUnitTypeMapping(account.EUR_CRM_Country_Code__c);
        Map<String, Object> fieldMappings =  EUR_COMMON_Utils.getJDEPriceMapping(account.EUR_CRM_Country_Code__c);
        
        // loop through items
        system.debug('size / ' + salesOrderLineItemList.size());
        for(EUR_NIM_Service.LineItemWrapper lineItemWrapper : salesOrderLineItemList)
        {
            DOM.Document doc = new DOM.Document();
            dom.XmlNode body = buildEnvelope(doc);

            dom.XmlNode getPriceCatalogue = body.addChildElement('orac:getPriceCatalogue', null, null);
            getPriceCatalogue.addChildElement('businessUnit', null, null).addTextNode((String)fieldMappings.get('businessUnit'));
            getPriceCatalogue.addChildElement('company', null, null).addTextNode((String)fieldMappings.get('company'));
            getPriceCatalogue.addChildElement('currencyCode', null, null).addTextNode(account.CurrencyIsocode);
            getPriceCatalogue.addChildElement('ediTransactionType', null, null).addTextNode('');
            getPriceCatalogue.addChildElement('paymentTerms', null, null).addTextNode('');

            dom.XmlNode priceCatalogueDetails = getPriceCatalogue.addChildElement('priceCatalogueDetails', null, null);
            //priceCatalogueDetails.addChildElement('paymentTerms', null, null).addTextNode('10');
            //priceCatalogueDetails.addChildElement('quantityFree', null, null).addTextNode('10');
            priceCatalogueDetails.addChildElement('quantityOrdered', null, null).addTextNode(String.valueOf(lineItemWrapper.quantity));
            priceCatalogueDetails.addChildElement('secondItemNumber', null, null).addTextNode(lineItemWrapper.productCode);
            //priceCatalogueDetails.addChildElement('ratePercentCashDiscount', null, null).addTextNode('10');
//            priceCatalogueDetails.addChildElement('unitOfMeasure', null, null).addTextNode((String)unitTypeMappings.get(lineItemWrapper.productUnitType));
            // Hardcoded value since, we agreed to remove the mapping for unit type
            priceCatalogueDetails.addChildElement('unitOfMeasure', null, null).addTextNode('BT');



            getPriceCatalogue.addChildElement('priceEffectiveDate', null, null).addTextNode(datetime.now().format('yyyy-MM-dd'));
            getPriceCatalogue.addChildElement('processingVersion', null, null).addTextNode((String)fieldMappings.get('processingVersion'));
            getPriceCatalogue.addChildElement('shipTo', null, null).addTextNode(account.EUR_CRM_Customer_Ship_To_No_ERP__c);
            getPriceCatalogue.addChildElement('soldTo', null, null).addTextNode((account.EUR_CRM_ERPSoldToAccount__r != null ? account.EUR_CRM_ERPSoldToAccount__r.EUR_CRM_Customer_No_ERP__c: ''));
            getPriceCatalogue.addChildElement('taxEffectiveDate', null, null).addTextNode(datetime.now().format('yyyy-MM-dd'));

            System.debug(LoggingLevel.ERROR, doc.toXmlString());

            HttpRequest request = EUR_NIM_HttpClientService.generateRequest('POST', namedCredential,
                    'text/xml; charset="utf-8"', doc.toXmlString());
            System.debug(request);

            HttpResponse response = EUR_NIM_HttpClientService.getResponse(request);

            if (response.getStatusCode() == 200)
            {
                system.debug('response.getBody(): ' + response.getBody());
                EUR_NIM_Service.Lines currentItem = getLineItem(response.getBody());
                if (currentItem != null && currentItem.netPrice != null)
                {
                    currentItem.quantity = String.valueOf(lineItemWrapper.quantity);
                    currentItem.itemTotalPrice = String.valueOf((Integer.valueOf(currentItem.quantity) * Decimal.valueOf(currentItem.netPrice)).setScale(2));
                    linesList.add(currentItem);
                    system.debug(currentItem);
                }
            }
        }
        pr.lines = linesList;
        return pr;
    }

    private EUR_NIM_Service.Lines getLineItem(String responseBody)
    {
        System.debug(responseBody);
        Dom.Document respDoc = new Dom.Document();
        EUR_NIM_Service.Lines l = new EUR_NIM_Service.Lines();

        respDoc.load(responseBody);
        EUR_COMMON_XPath xp = new EUR_COMMON_XPath(respDoc);
        List<Dom.XmlNode> responseNodes = xp.find('/S:Envelope/S:Body/ns0:getPriceCatalogueResponse');
        if (!responseNodes.isEmpty()) {
            Dom.XmlNode n = responseNodes.get(0);
            Map<String,String> elements = new Map<String,String>();
            for (Dom.XmlNode c : n.getChildElements())
            {
                if (c.getName() == 'priceCatalogueDetails')
                {
                    //system.debug('c.getName()' + c.getName());
                    Map<String,String> details = new Map<String,String>();
                    for (Dom.XmlNode cc : c.getChildElements())
                    {
                        details.put(cc.getName(), cc.getText());
                        //  system.debug('cc ' + cc.getName() + '/' + cc.getText());
                    }

                    l.material = details.get('secondItemNumber').trim();
                    l.netPrice=String.valueOf(Decimal.valueOf(details.get('unitPrice')).setScale(2));

                }
                else
                {
                    elements.put(c.getName(), c.getText());
                }
            }
        }
        else
        {
            return null;
        }
        return l;
    }

    public List<EUR_NIM_Service.LineItemWrapper> calculateInventory(EUR_CRM_Account__c account, String urlPath, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        Map<String, Object> fieldMappings =  EUR_COMMON_Utils.getJDEInventoryMapping(account.EUR_CRM_Country_Code__c);
        Map<String, Object> unitTypeMappings =  EUR_COMMON_Utils.getUnitTypeMapping(account.EUR_CRM_Country_Code__c);
        String namedCredential = EUR_COMMON_Utils.getNamedCredential(account.EUR_CRM_Country_Code__c, EUR_COMMON_Utils.INVENTORY_SERVICE);
        // loop through Items
        for (EUR_NIM_Service.LineItemWrapper e : salesOrderLineItemList)
        {
            DOM.Document doc = new DOM.Document();
            dom.XmlNode body = buildEnvelope(doc);

            dom.XmlNode getCalculatedAvailability = body.addChildElement('orac:getCalculatedAvailability', null, null);
            dom.XmlNode branchPlantList = getCalculatedAvailability.addChildElement('branchPlantList', null, null);
            branchPlantList.addTextNode((String)fieldMappings.get('branchPlantList'));
            dom.XmlNode itemSecond = getCalculatedAvailability.addChildElement('itemSecond', null, null);
            itemSecond.addTextNode(e.productCode);
            dom.XmlNode omitZeroQty = getCalculatedAvailability.addChildElement('omitZeroQty', null, null);
            omitZeroQty.addTextNode(String.valueOf(1));
            dom.XmlNode unitOfMeasure = getCalculatedAvailability.addChildElement('unitOfMeasure', null, null);
            //unitOfMeasure.addTextNode((String)unitTypeMappings.get(e.productUnitType));
            // Hardcoded value since, we agreed to remove the mapping for unit type
            unitOfMeasure.addTextNode('BT');
            //System.debug(LoggingLevel.ERROR, doc.toXmlString());

            HttpRequest request = EUR_NIM_HttpClientService.generateRequest('POST', namedCredential,
                    'text/xml; charset="utf-8"', doc.toXmlString());
            System.debug('calculateInventory : ' + request);

            HttpResponse response = EUR_NIM_HttpClientService.getResponse(request);

            if (response.getStatusCode() == 200)
            {
                e.productStockInfo = getFreeAmount(response.getBody());
                //System.debug('ddd ' + e.productStockInfo);
            }
            else
            {
                e.productStockInfo = response.getStatus();
            }
            system.debug(response.getBody());
        }

        return salesOrderLineItemList;
    }

    public String generateNounce()
    {
        Long randomLong = Crypto.getRandomLong();
        return EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
    }

    private dom.XmlNode buildEnvelope(DOM.Document doc)
    {
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapenv, 'soapenv');
        envelope.setNamespace('orac',orac);
        dom.XmlNode header = envelope.addChildElement('soapenv:Header', null, null);
        dom.XmlNode security = header.addChildElement('wsse:Security', null, null);
        security.setAttribute('soapenv:mustUnderstand','1');
        security.setNamespace('wsse', wsse);
        security.setNamespace('wsu', wsu);
        dom.XmlNode usernameToken = security.addChildElement('wsse:UsernameToken', null, null);
        usernameToken.setAttribute('wsu:Id','UsernameToken-'+generateNounce());
        usernameToken.addChildElement('wsse:Username', null, null).addTextNode('{!HTMLENCODE($Credential.Username)}');
        dom.XmlNode password = usernameToken.addChildElement('wsse:Password', null, null);
        password.setAttribute('Type', passwordType);
        password.addTextNode('{!HTMLENCODE($Credential.Password)}');
        dom.XmlNode nonce = usernameToken.addChildElement('wsse:Nonce', null, null);
        nonce.setAttribute('EncodingType', encodingType);
        nonce.addTextNode(generateNounce());
        dom.XmlNode created = usernameToken.addChildElement('wsu:Created', null, null);
        created.addTextNode(datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'));

        return envelope.addChildElement('Body', soapenv, null);
    }

    private String getFreeAmount(String responseBody)
    {

        System.debug(responseBody);


        Dom.Document respDoc = new Dom.Document();
        respDoc.load(responseBody);

        EUR_COMMON_XPath xp = new EUR_COMMON_XPath(respDoc);
        List<Dom.XmlNode> responseNodes = xp.find('/S:Envelope/S:Body/ns0:getCalculatedAvailabilityResponse/showCalculatedAvailability');
        if (!responseNodes.isEmpty())
        {
            Dom.XmlNode n = responseNodes.get(0);
            for (Dom.XmlNode c : n.getChildElements())
            {
                System.debug(c);
                if (c.getName() == 'availabilityDetails')
                {
                    String amount;
                    for (Dom.XmlNode cc : c.getChildElements())
                    {System.debug('cc :' + cc.getName());
                        //System.debug(cc.getName());
                        if (cc.getName() == 'availableQuantity')
                        {
                            for (Dom.XmlNode ccc : cc.getChildElements())
                            {System.debug('ccc :' + ccc.getName() );
                                if (ccc.getName() == 'value')
                                {
                                    amount =  ccc.getText();
                                }
                            }
                        }
                        if (cc.getName() == 'location' && cc.getText().Trim() == 'FREE')
                        {
                            system.debug(cc.getText() + '/' + amount);
                            return amount;
                        }
                        // m.put(cc.getName(), cc.getText());
                    }

                }

            }
        }
        return 'Error';
    }
}