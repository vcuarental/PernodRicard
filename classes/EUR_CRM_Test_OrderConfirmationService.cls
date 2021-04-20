@isTest
public class EUR_CRM_Test_OrderConfirmationService {
    /* Make sure that account and order rec type evaluate
     * to existing email template indentifier (devname)
     * in the form of 
     * EUR_CRM_{REGION_CODE}_{ORDER_TYPE}_Order_template 
     * 
     * in this case EUR_CRM_IDL_Indirect_Order_template
     */

    private static final String ORDER_SEND_EMAIL_STATUS = 'Instant validation';
    private static final String ORDER_NO_SEND_EMAIL_STATUS = 'On hold';

    /*  Account EUR_CRM_Country_Code__c is formula field and depends on account RecordType.DeveloperName:
       EUR_SE_On_Trade = > SE
    */
    private static final String SE_ON_TRADE_ACCOUNT_RECTYPE = 'EUR_SE_On_Trade';
    private static final String NL_ON_TRADE_ACCOUNT_RECTYPE = 'EUR_NL_On_Trade';

    /*
      EUR_CRM_Outlet_to_Supplier_Mapping__c.EUR_CRM_Supplier_Account__c must have WHOLESALLER in recort type devName
    */
    private static final String SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING = 'EUR_SE_Wholesaler';
    private static final String NL_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING = 'EUR_NL_Wholesaler';

    private static final String SUPPLIER_ACCOUNT_EMAIL = 'supplier_account@test.com';
    private static final String CONTACT_EMAIL = 'contact@test.com';
    private static final String ORDER_EMAIL = 'order@test.com';


    private static final String ORDER_INDIRECT_RECORD_TYPE = 'EUR_Indirect';
    private static final String ORDER_DIRECT_RECORD_TYPE = 'EUR_Direct';

    private static final String ACCOUNT_FIELD_NAME = 'EUR_CRM_Supplier__r.EUR_CRM_Supplier_Account__r.EUR_CRM_Email__c';
    private static final String SALES_REP_FIELD_NAME = 'EUR_CRM_SalesRep__r.Email';
    private static final String CONTACT_FIELD_NAME = 'EUR_CRM_Contact_Person__r.Email';
    private static final String ORDER_FIELD_NAME = 'EUR_CRM_Email__c';

    private static final String EMAIL_TEMPLATE_NAMING = 'EUR_CRM_{0}_{1}_order_template'; //example: EUR_CRM_SE_Indirect_order_template
    private static final String CUSTOMER_SERVICE_EMAIL = 'custservice@email.com';


    /* ====================================
    *  Test methods for one record
    *  ====================================*/
    @isTest
    private static void oneOrderSendEmailToAllFieldsSpecifiedInCustomMetadataAfterInsertTest() {
        EUR_CRM_CT_Order_Email_Setup__mdt cmtDirectSE = makeCustomMetadata('SE', ORDER_DIRECT_RECORD_TYPE, ACCOUNT_FIELD_NAME + ',' + CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        EUR_CRM_CT_Order_Email_Setup__mdt cmtIndirectRU = makeCustomMetadata('RU', ORDER_INDIRECT_RECORD_TYPE, CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        List<EUR_CRM_CT_Order_Email_Setup__mdt> mockEmailSetups = new List<EUR_CRM_CT_Order_Email_Setup__mdt>{cmtDirectSE, cmtIndirectRU};
        setCustomMetadataForTest(mockEmailSetups);

        Contact cont = createContact();
        EUR_CRM_Account__c accForOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>{accForOrder,accForOutletMapping};
        insert accountsToInsert;
        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMapping = makeOutletToSupplierMapping(accForOutletMapping.Id);
        insert supplierMapping;

        EUR_CRM_Sales_Order__c orderToInsert = makeOrder(accForOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        orderToInsert.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;
        orderToInsert.EUR_CRM_Supplier__c = supplierMapping.Id;
        orderToInsert.EUR_CRM_Contact_Person__c = cont.Id;

        Test.startTest();
        insert orderToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> orders = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Set<Id>{orderToInsert.Id});
        Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(orders);
        List<EUR_CRM_Sales_Order__c> selectedOrders = EUR_CRM_OrderConfirmationService.selectOrdersOnQuery(emailSetupByDevNameByCountryCode, new Map<Id, EUR_CRM_Sales_Order__c>(orders).keySet());

        System.assertEquals('SE', orders[0].EUR_CRM_Country_Code__c);
        System.assertEquals(ORDER_DIRECT_RECORD_TYPE, orders[0].RecordType.DeveloperName);
        System.assertEquals(new List<String>{ACCOUNT_FIELD_NAME, CONTACT_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).mailToEmailFields);

        System.assertEquals(new List<String>{ORDER_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToEmailFields);

        System.assertEquals(CUSTOMER_SERVICE_EMAIL,
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToCustomerServiceEmails[0]);

        System.assertEquals('EUR_CRM_SE_Direct_order_template',
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).emailTemplateDevName);
    }

    @isTest
    private static void oneOrderSendEmailToAllFieldsSpecifiedInCustomMetadataAfterUpdateTest() {
        EUR_CRM_CT_Order_Email_Setup__mdt cmtDirectSE = makeCustomMetadata('SE', ORDER_DIRECT_RECORD_TYPE, ACCOUNT_FIELD_NAME + ',' + CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        EUR_CRM_CT_Order_Email_Setup__mdt cmtIndirectRU = makeCustomMetadata('RU', ORDER_INDIRECT_RECORD_TYPE, CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        List<EUR_CRM_CT_Order_Email_Setup__mdt> mockEmailSetups = new List<EUR_CRM_CT_Order_Email_Setup__mdt>{cmtDirectSE, cmtIndirectRU};
        setCustomMetadataForTest(mockEmailSetups);

        Contact cont = createContact();
        EUR_CRM_Account__c accForOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>{accForOrder,accForOutletMapping};
        insert accountsToInsert;
        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMapping = makeOutletToSupplierMapping(accForOutletMapping.Id);
        insert supplierMapping;

        EUR_CRM_Sales_Order__c orderToInsert = makeOrder(accForOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        orderToInsert.EUR_CRM_Supplier__c = supplierMapping.Id;
        orderToInsert.EUR_CRM_Contact_Person__c = cont.Id;
        orderToInsert.EUR_CRM_Status__c = ORDER_NO_SEND_EMAIL_STATUS;

        Test.startTest();
        insert orderToInsert;
        System.assertEquals(0,Limits.getFutureCalls());

        orderToInsert.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;
        update orderToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> orders = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Set<Id>{orderToInsert.Id});
        Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(orders);
        List<EUR_CRM_Sales_Order__c> selectedOrders = EUR_CRM_OrderConfirmationService.selectOrdersOnQuery(emailSetupByDevNameByCountryCode, new Map<Id, EUR_CRM_Sales_Order__c>(orders).keySet());

        System.assertEquals('SE', orders[0].EUR_CRM_Country_Code__c);
        System.assertEquals(ORDER_DIRECT_RECORD_TYPE, orders[0].RecordType.DeveloperName);
        System.assertEquals(new List<String>{ACCOUNT_FIELD_NAME, CONTACT_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).mailToEmailFields);

        System.assertEquals(new List<String>{ORDER_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToEmailFields);

        System.assertEquals(CUSTOMER_SERVICE_EMAIL,
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToCustomerServiceEmails[0]);

        System.assertEquals('EUR_CRM_SE_Direct_order_template',
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).emailTemplateDevName);
    }

    @isTest
    private static void oneOrderNoSendEmailBecauseNoSuitableCustomMetadataAfterInsertTest() {
        setCustomMetadataForTest(makeEmptyCustomMetadata());

        Contact cont = createContact();
        EUR_CRM_Account__c accForOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>{accForOrder,accForOutletMapping};
        insert accountsToInsert;

        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMapping = makeOutletToSupplierMapping(accForOutletMapping.Id);
        insert supplierMapping;

        EUR_CRM_Sales_Order__c orderToInsert = makeOrder(accForOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        orderToInsert.EUR_CRM_Supplier__c = supplierMapping.Id;
        orderToInsert.EUR_CRM_Contact_Person__c = cont.Id;
        orderToInsert.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;

        Test.startTest();
        insert orderToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> orders = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Set<Id>{orderToInsert.Id});

        System.assertEquals('SE', orders[0].EUR_CRM_Country_Code__c);
        System.assertEquals(ORDER_DIRECT_RECORD_TYPE, orders[0].RecordType.DeveloperName);
        System.assertEquals(new Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>>(),
            new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(orders));
    }

    @isTest
    private static void oneOrderNoSendEmailBecauseNoSuitableCustomMetadataAfterUpdateTest() {
        setCustomMetadataForTest(makeEmptyCustomMetadata());

        Contact cont = createContact();
        EUR_CRM_Account__c accForOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>{accForOrder,accForOutletMapping};
        insert accountsToInsert;
        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMapping = makeOutletToSupplierMapping(accForOutletMapping.Id);
        insert supplierMapping;

        EUR_CRM_Sales_Order__c orderToInsert = makeOrder(accForOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        orderToInsert.EUR_CRM_Supplier__c = supplierMapping.Id;
        orderToInsert.EUR_CRM_Contact_Person__c = cont.Id;
        orderToInsert.EUR_CRM_Status__c = ORDER_NO_SEND_EMAIL_STATUS;

        Test.startTest();
        insert orderToInsert;
        System.assertEquals(0, Limits.getFutureCalls());

        orderToInsert.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;
        update orderToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> ordersToGetEmailSetups = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Set<Id>{orderToInsert.Id});
        Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(ordersToGetEmailSetups);
        List<EUR_CRM_Sales_Order__c> selectedOrders = EUR_CRM_OrderConfirmationService.selectOrdersOnQuery(emailSetupByDevNameByCountryCode, new Map<Id, EUR_CRM_Sales_Order__c>(ordersToGetEmailSetups).keySet());

        System.assertEquals(new Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>>(), emailSetupByDevNameByCountryCode);

        System.assertEquals(new List<EUR_CRM_Sales_Order__c>(),selectedOrders);
    }


    /* ====================================
   *    Test methods for two records
   *  ====================================*/
    @isTest
    private static void twoOrdersSendEmailsToAllFieldsSpecifiedInCustomMetadataAfterInsertTest() {
        EUR_CRM_CT_Order_Email_Setup__mdt cmtDirectSE = makeCustomMetadata('SE', ORDER_DIRECT_RECORD_TYPE, ACCOUNT_FIELD_NAME + ',' + CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        EUR_CRM_CT_Order_Email_Setup__mdt cmtIndirectNL = makeCustomMetadata('NL', ORDER_INDIRECT_RECORD_TYPE, CONTACT_FIELD_NAME, '', '');
        List<EUR_CRM_CT_Order_Email_Setup__mdt> mockEmailSetups = new List<EUR_CRM_CT_Order_Email_Setup__mdt>{cmtDirectSE, cmtIndirectNL};
        setCustomMetadataForTest(mockEmailSetups);

        Contact ordersContact = createContact();

        EUR_CRM_Account__c accForSEOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForSEOrderOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        EUR_CRM_Account__c accForNLOrder = makeAccount(NL_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForNLOrderOutletMapping = makeAccount(NL_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>{accForSEOrder,accForNLOrder,accForSEOrderOutletMapping,accForNLOrderOutletMapping};
        insert accountsToInsert;

        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMappingForSEOrder = makeOutletToSupplierMapping(accForSEOrderOutletMapping.Id);
        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMappingForNLOrder = makeOutletToSupplierMapping(accForNLOrderOutletMapping.Id);
        List<EUR_CRM_Outlet_to_Supplier_Mapping__c> supplierMappingsToInsert = new List<EUR_CRM_Outlet_to_Supplier_Mapping__c>{supplierMappingForSEOrder, supplierMappingForNLOrder};
        insert supplierMappingsToInsert;

        EUR_CRM_Sales_Order__c oderSEDirect = makeOrder(accForSEOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        oderSEDirect.EUR_CRM_Supplier__c = supplierMappingForSEOrder.Id;
        oderSEDirect.EUR_CRM_Contact_Person__c = ordersContact.Id;
        oderSEDirect.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;

        EUR_CRM_Sales_Order__c orderNLDirect = makeOrder(accForNLOrder.Id, ORDER_INDIRECT_RECORD_TYPE);
        orderNLDirect.EUR_CRM_Supplier__c = supplierMappingForNLOrder.Id;
        orderNLDirect.EUR_CRM_Contact_Person__c = ordersContact.Id;
        orderNLDirect.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;

        List<EUR_CRM_Sales_Order__c> ordersToInsert = new List<EUR_CRM_Sales_Order__c>{oderSEDirect, orderNLDirect};

        Test.startTest();

        insert ordersToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> ordersToGetEmailSetups = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Map<Id,EUR_CRM_Sales_Order__c>(ordersToInsert).keySet());
        Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(ordersToGetEmailSetups);
        List<EUR_CRM_Sales_Order__c> selectedOrders = EUR_CRM_OrderConfirmationService.selectOrdersOnQuery(emailSetupByDevNameByCountryCode, new Map<Id, EUR_CRM_Sales_Order__c>(ordersToGetEmailSetups).keySet());
        System.debug('selectedOrders = > ' + JSON.serializePretty(selectedOrders));


        System.assertEquals('NL', selectedOrders[0].EUR_CRM_Country_Code__c);
        System.assertEquals('SE', selectedOrders[1].EUR_CRM_Country_Code__c);
        System.assertEquals(ORDER_INDIRECT_RECORD_TYPE, selectedOrders[0].RecordType.DeveloperName);
        System.assertEquals(ORDER_DIRECT_RECORD_TYPE, selectedOrders[1].RecordType.DeveloperName);
        System.assertEquals(new List<String>{CONTACT_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).mailToEmailFields);

        System.assertEquals(new List<String>(),
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToEmailFields);

        System.assertEquals(new List<String>(),
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToCustomerServiceEmails);

        System.assertEquals('EUR_CRM_NL_Indirect_order_template',
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).emailTemplateDevName);

        System.assertEquals(new List<String>{ACCOUNT_FIELD_NAME,CONTACT_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).mailToEmailFields);

        System.assertEquals(new List<String>{ORDER_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).copyToEmailFields);

        System.assertEquals(new List<String>{CUSTOMER_SERVICE_EMAIL},
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).copyToCustomerServiceEmails);

        System.assertEquals('EUR_CRM_SE_Direct_order_template',
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).emailTemplateDevName);
    }

    @isTest
    private static void twoOrdersSendEmailsToAllFieldsSpecifiedInCustomMetadataAfterUpdateTest() {
        EUR_CRM_CT_Order_Email_Setup__mdt cmtDirectSE = makeCustomMetadata('SE', ORDER_DIRECT_RECORD_TYPE, ACCOUNT_FIELD_NAME + ',' + CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        EUR_CRM_CT_Order_Email_Setup__mdt cmtIndirectNL = makeCustomMetadata('NL', ORDER_INDIRECT_RECORD_TYPE, CONTACT_FIELD_NAME, '', '');
        List<EUR_CRM_CT_Order_Email_Setup__mdt> mockEmailSetups = new List<EUR_CRM_CT_Order_Email_Setup__mdt>{cmtDirectSE, cmtIndirectNL};
        setCustomMetadataForTest(mockEmailSetups);

        Contact ordersContact = createContact();

        EUR_CRM_Account__c accForSEOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForSEOrderOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        EUR_CRM_Account__c accForNLOrder = makeAccount(NL_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForNLOrderOutletMapping = makeAccount(NL_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>{accForSEOrder,accForNLOrder,accForSEOrderOutletMapping,accForNLOrderOutletMapping};
        insert accountsToInsert;

        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMappingForSEOrder = makeOutletToSupplierMapping(accForSEOrderOutletMapping.Id);
        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMappingForNLOrder = makeOutletToSupplierMapping(accForNLOrderOutletMapping.Id);
        List<EUR_CRM_Outlet_to_Supplier_Mapping__c> supplierMappingsToInsert = new List<EUR_CRM_Outlet_to_Supplier_Mapping__c>{supplierMappingForSEOrder, supplierMappingForNLOrder};
        insert supplierMappingsToInsert;

        EUR_CRM_Sales_Order__c orderSEDirect = makeOrder(accForSEOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        orderSEDirect.EUR_CRM_Supplier__c = supplierMappingForSEOrder.Id;
        orderSEDirect.EUR_CRM_Contact_Person__c = ordersContact.Id;
        orderSEDirect.EUR_CRM_Status__c = ORDER_NO_SEND_EMAIL_STATUS;

        EUR_CRM_Sales_Order__c orderNLDirect = makeOrder(accForNLOrder.Id, ORDER_INDIRECT_RECORD_TYPE);
        orderNLDirect.EUR_CRM_Supplier__c = supplierMappingForNLOrder.Id;
        orderNLDirect.EUR_CRM_Contact_Person__c = ordersContact.Id;
        orderNLDirect.EUR_CRM_Status__c = ORDER_NO_SEND_EMAIL_STATUS;

        List<EUR_CRM_Sales_Order__c> ordersToInsert = new List<EUR_CRM_Sales_Order__c>{orderSEDirect, orderNLDirect};
        insert ordersToInsert;

        Test.startTest();
        orderSEDirect.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;
        orderNLDirect.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;
        update ordersToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> ordersToGetEmailSetups = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Map<Id,EUR_CRM_Sales_Order__c>(ordersToInsert).keySet());
        Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(ordersToGetEmailSetups);
        List<EUR_CRM_Sales_Order__c> selectedOrders = EUR_CRM_OrderConfirmationService.selectOrdersOnQuery(emailSetupByDevNameByCountryCode, new Map<Id, EUR_CRM_Sales_Order__c>(ordersToGetEmailSetups).keySet());
        System.debug('selectedOrders = > ' + JSON.serializePretty(selectedOrders));


        System.assertEquals('NL', selectedOrders[0].EUR_CRM_Country_Code__c);
        System.assertEquals('SE', selectedOrders[1].EUR_CRM_Country_Code__c);
        System.assertEquals(ORDER_INDIRECT_RECORD_TYPE, selectedOrders[0].RecordType.DeveloperName);
        System.assertEquals(ORDER_DIRECT_RECORD_TYPE, selectedOrders[1].RecordType.DeveloperName);
        System.assertEquals(new List<String>{CONTACT_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).mailToEmailFields);

        System.assertEquals(new List<String>(),
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToEmailFields);

        System.assertEquals(new List<String>(),
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToCustomerServiceEmails);

        System.assertEquals('EUR_CRM_NL_Indirect_order_template',
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).emailTemplateDevName);

        System.assertEquals(new List<String>{ACCOUNT_FIELD_NAME,CONTACT_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).mailToEmailFields);

        System.assertEquals(new List<String>{ORDER_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).copyToEmailFields);

        System.assertEquals(new List<String>{CUSTOMER_SERVICE_EMAIL},
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).copyToCustomerServiceEmails);

        System.assertEquals('EUR_CRM_SE_Direct_order_template',
            emailSetupByDevNameByCountryCode.get(selectedOrders[1].EUR_CRM_Country_Code__c).get(selectedOrders[1].RecordType.DeveloperName).emailTemplateDevName);
    }

    @isTest
    private static void twoOrdersAndNoSendEmailBecauseNoSuitableCustomMetadataAfterInsertTest() {
        EUR_CRM_CT_Order_Email_Setup__mdt cmtDirectRU = makeCustomMetadata('RU', ORDER_DIRECT_RECORD_TYPE, ACCOUNT_FIELD_NAME + ',' + CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        EUR_CRM_CT_Order_Email_Setup__mdt cmtIndirectIDL = makeCustomMetadata('IDL', ORDER_INDIRECT_RECORD_TYPE, CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        List<EUR_CRM_CT_Order_Email_Setup__mdt> mockEmailSetups = new List<EUR_CRM_CT_Order_Email_Setup__mdt>{cmtDirectRU, cmtIndirectIDL};
        setCustomMetadataForTest(mockEmailSetups);

        Contact ordersContact = createContact();

        EUR_CRM_Account__c accForSEOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForSEOrderOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        EUR_CRM_Account__c accForNLOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        EUR_CRM_Account__c accForNLOrderOutletMapping = makeAccount(SE_RECORD_TYPE_SUPPLIER_ACCOUNT_FOR_OUTLET_MAPPING, SUPPLIER_ACCOUNT_EMAIL);
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>{accForSEOrder,accForNLOrder,accForSEOrderOutletMapping,accForNLOrderOutletMapping};
        insert accountsToInsert;

        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMappingForSEOrder = makeOutletToSupplierMapping(accForSEOrderOutletMapping.Id);
        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMappingForNLOrder = makeOutletToSupplierMapping(accForNLOrderOutletMapping.Id);
        List<EUR_CRM_Outlet_to_Supplier_Mapping__c> supplierMappingsToInsert = new List<EUR_CRM_Outlet_to_Supplier_Mapping__c>{supplierMappingForSEOrder, supplierMappingForNLOrder};
        insert supplierMappingsToInsert;

        EUR_CRM_Sales_Order__c oderSEDirect = makeOrder(accForSEOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        oderSEDirect.EUR_CRM_Supplier__c = supplierMappingForSEOrder.Id;
        oderSEDirect.EUR_CRM_Contact_Person__c = ordersContact.Id;
        oderSEDirect.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;

        EUR_CRM_Sales_Order__c orderNLDirect = makeOrder(accForNLOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        orderNLDirect.EUR_CRM_Supplier__c = supplierMappingForNLOrder.Id;
        orderNLDirect.EUR_CRM_Contact_Person__c = ordersContact.Id;
        orderNLDirect.EUR_CRM_Status__c = ORDER_NO_SEND_EMAIL_STATUS;

        List<EUR_CRM_Sales_Order__c> ordersToInsert = new List<EUR_CRM_Sales_Order__c>{oderSEDirect, orderNLDirect};

        Test.startTest();

        insert ordersToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> ordersToGetEmailSetups = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Map<Id,EUR_CRM_Sales_Order__c>(ordersToInsert).keySet());
        Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(ordersToGetEmailSetups);
        List<EUR_CRM_Sales_Order__c> selectedOrders = EUR_CRM_OrderConfirmationService.selectOrdersOnQuery(emailSetupByDevNameByCountryCode, new Map<Id, EUR_CRM_Sales_Order__c>(ordersToGetEmailSetups).keySet());

        System.assertEquals(new Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>>(), emailSetupByDevNameByCountryCode);

        System.assertEquals(new List<EUR_CRM_Sales_Order__c>(),selectedOrders);
    }


    /* ====================================
    *  Test methods for testing empty email fields on order record
    *  ====================================*/
    @isTest
    private static void oneOrderSendEmailExceptionBecauseOrderFieldIsEmptyAfterInsertTest() {
        EUR_CRM_CT_Order_Email_Setup__mdt cmtDirectSE = makeCustomMetadata('SE', ORDER_DIRECT_RECORD_TYPE, '', ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        EUR_CRM_CT_Order_Email_Setup__mdt cmtIndirectNL = makeCustomMetadata('NL', ORDER_INDIRECT_RECORD_TYPE, CONTACT_FIELD_NAME, ORDER_FIELD_NAME, CUSTOMER_SERVICE_EMAIL);
        List<EUR_CRM_CT_Order_Email_Setup__mdt> mockEmailSetups = new List<EUR_CRM_CT_Order_Email_Setup__mdt>{cmtDirectSE, cmtIndirectNL};
        setCustomMetadataForTest(mockEmailSetups);

        Contact cont = createContact();
        EUR_CRM_Account__c accForOrder = makeAccount(SE_ON_TRADE_ACCOUNT_RECTYPE, '');
        insert accForOrder;

        EUR_CRM_Sales_Order__c orderToInsert = makeOrder(accForOrder.Id, ORDER_DIRECT_RECORD_TYPE);
        orderToInsert.EUR_CRM_Status__c = ORDER_SEND_EMAIL_STATUS;
        orderToInsert.EUR_CRM_Contact_Person__c = cont.Id;

        Test.startTest();
        insert orderToInsert;
        System.assertEquals(1, Limits.getFutureCalls());
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> orders = EUR_CRM_OrderConfirmationService.selectOrdersWhereIds(new Set<Id>{orderToInsert.Id});
        Map<String, Map<String, EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new EUR_CRM_OrderConfirmationService.OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(orders);
        List<EUR_CRM_Sales_Order__c> selectedOrders = EUR_CRM_OrderConfirmationService.selectOrdersOnQuery(emailSetupByDevNameByCountryCode, new Map<Id, EUR_CRM_Sales_Order__c>(orders).keySet());

        System.assertEquals('SE', selectedOrders[0].EUR_CRM_Country_Code__c);

        System.assertEquals(new List<String>(),
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).mailToEmailFields);

        System.assertEquals(new List<String>(),EUR_CRM_OrderConfirmationService.extractFieldValues(
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).mailToEmailFields,selectedOrders[0]));

        System.assertEquals(new List<String>{ORDER_FIELD_NAME},
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToEmailFields);

        System.assertEquals(new List<String>{ORDER_EMAIL},EUR_CRM_OrderConfirmationService.extractFieldValues(
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToEmailFields,selectedOrders[0]));

        System.assertEquals(CUSTOMER_SERVICE_EMAIL,
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).copyToCustomerServiceEmails[0]);

        System.assertEquals('EUR_CRM_SE_Direct_order_template',
            emailSetupByDevNameByCountryCode.get(selectedOrders[0].EUR_CRM_Country_Code__c).get(selectedOrders[0].RecordType.DeveloperName).emailTemplateDevName);
    }


    /* ====================================
    *  High level helpers
    *  ====================================*/
    private static void setCustomMetadataForTest(List<EUR_CRM_CT_Order_Email_Setup__mdt> mockCustomMetadata) {
        EUR_CRM_OrderConfirmationService.emailSetupsForTest.addAll(mockCustomMetadata);
    }


    /* ====================================
    *  Makers
    *  ====================================*/
    private static List<EUR_CRM_CT_Order_Email_Setup__mdt> makeEmptyCustomMetadata() {
        return new List<EUR_CRM_CT_Order_Email_Setup__mdt>();
    }

    private static EUR_CRM_CT_Order_Email_Setup__mdt makeCustomMetadata(String countryCode, String orderRTDevName, String mailToFields, String copyToFields, String custServEmails) {
        EUR_CRM_CT_Order_Email_Setup__mdt cmt = (EUR_CRM_CT_Order_Email_Setup__mdt) JSON.deserialize('{' +
            '"EUR_CRM_Country_Code__c" : "' + countryCode + '" ,' +
            '"EUR_CRM_Order_Record_Type_Dev_Name__c" : "' + orderRTDevName + '" ,' +
            '"EUR_CRM_Mail_To_Email_Fields__c" : "' + (mailToFields == null ? '' : mailToFields) + '" ,' +
            '"EUR_CRM_Copy_To_Email_Fields__c" : "' + (copyToFields == null ? '' : copyToFields) + '" ,' +
            '"EUR_CRM_Copy_To_Customer_Service_Email__c" : "' + (custServEmails == null ? '' : custServEmails) + '" ,' +
            '"EUR_CRM_Email_Template_Dev_Name__c" : "' + String.format(EMAIL_TEMPLATE_NAMING, new List<String>{
            countryCode, orderRTDevName.substringAfter('EUR_')}) + '"' +
            '}', EUR_CRM_CT_Order_Email_Setup__mdt.class);
        return cmt;
    }

    /*Method use 44 api*/
//    private static EUR_CRM_CT_Order_Email_Setup__mdt makeCustomMetadata(String countryCode, String orderRTDevName, String mailToFields, String copyToFields, String custServEmails) {
//        EUR_CRM_CT_Order_Email_Setup__mdt cmt = new EUR_CRM_CT_Order_Email_Setup__mdt();
//        cmt.EUR_CRM_Country_Code__c = countryCode;
//        cmt.EUR_CRM_Order_Record_Type_Dev_Name__c = orderRTDevName;
//        cmt.EUR_CRM_Mail_To_Email_Fields__c = mailToFields == null ? '' : mailToFields;
//        cmt.EUR_CRM_Copy_To_Email_Fields__c = copyToFields == null ? '' : copyToFields;
//        cmt.EUR_CRM_Copy_To_Customer_Service_Email__c = custServEmails == null ? '' : custServEmails;
//        cmt.EUR_CRM_Email_Template_Dev_Name__c = String.format(EMAIL_TEMPLATE_NAMING, new List<String>{
//            countryCode, orderRTDevName.substringAfter('EUR_')});
//        return cmt;
//    }

    private static EUR_CRM_Sales_Order__c makeOrder(Id accId, String recTypeDevName) {
        EUR_CRM_Sales_Order__c order = new EUR_CRM_Sales_Order__c();
        order.RecordTypeId = EUR_CRM_Sales_Order__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
        order.EUR_CRM_Account__c = accId;
        order.EUR_CRM_Email__c = ORDER_EMAIL;
        return order;
    }

    private static EUR_CRM_Outlet_to_Supplier_Mapping__c makeOutletToSupplierMapping(Id supplierAccountId) {
        EUR_CRM_Outlet_to_Supplier_Mapping__c supplierMapping = new EUR_CRM_Outlet_to_Supplier_Mapping__c();
        supplierMapping.EUR_CRM_Supplier_Account__c = supplierAccountId;
        supplierMapping.EUR_CRM_Outlet_Account__c = supplierAccountId;
        return supplierMapping;
    }

    private static EUR_CRM_Account__c makeAccount(String recTypeDevName, String email) {
        EUR_CRM_Account__c account = new EUR_CRM_Account__c();
        account.Name = 'Test';
        account.RecordTypeId = EUR_CRM_Account__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
        account.EUR_CRM_Email__c = email;
        account.EUR_CRM_Postal_Code__c = '11111';
        return account;
    }

    private static Contact createContact() {
        Contact cont = new Contact();
        cont.LastName = 'Test';
        cont.Email = CONTACT_EMAIL;
        insert cont;
        return cont;
    }


    /* ====================================
    *  SOQL Selectors
    *  ====================================*/
    private static List<EUR_CRM_Sales_Order__c> selectOrders() {
        return [
            SELECT Id
                , EUR_CRM_Supplier__r.EUR_CRM_Supplier_Account__r.EUR_CRM_Email__c
                , EUR_CRM_SalesRep__r.Email
                , EUR_CRM_Contact_Person__r.Email
                , EUR_CRM_Email__c
            FROM EUR_CRM_Sales_Order__c
        ];
    }


}