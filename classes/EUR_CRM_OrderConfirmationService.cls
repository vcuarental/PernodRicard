public without sharing class EUR_CRM_OrderConfirmationService {

    @TestVisible
    private static List<EUR_CRM_CT_Order_Email_Setup__mdt> emailSetupsForTest = new List<EUR_CRM_CT_Order_Email_Setup__mdt>();

    private static final String ORDER_STATUS_TO_SEND = 'Instant validation';

    private static final String EMAIL_TEMPLATE_NAMING = 'EUR_CRM_%_%_order_template';

    private final static Map<String,EmailTemplate> EMAIL_TEMPLATE_BY_DEVELOPER_NAME {
        private get{
            if(EMAIL_TEMPLATE_BY_DEVELOPER_NAME == null){
                EMAIL_TEMPLATE_BY_DEVELOPER_NAME = new Map<String,EmailTemplate>();

                List<EmailTemplate> ets = new List<EmailTemplate>([
                    SELECT Id
                        ,DeveloperName
                    FROM EmailTemplate
                    WHERE DeveloperName LIKE :EMAIL_TEMPLATE_NAMING
                ]);

                for(EmailTemplate et :ets){
                    EMAIL_TEMPLATE_BY_DEVELOPER_NAME.put(et.DeveloperName,et);
                }
            }
            return EMAIL_TEMPLATE_BY_DEVELOPER_NAME;
        }
        private set;
    }


    /*=================================
   *   Interface
   * =================================*/
    public static void sendOrderConfirmations(List<sObject> orders, Map<Id, sObject> oldOrdersMap){
        List<EUR_CRM_Sales_Order__c> filteredOrders = filterOrders((List<EUR_CRM_Sales_Order__c>)orders, oldOrdersMap);
        System.debug('\n filteredOrders.size() => ' + filteredOrders.size() + '\n');
        System.debug('\n filteredOrders => ' + JSON.serializePretty(filteredOrders) + '\n');
        if (filteredOrders.isEmpty()) { return; }
        sendEmailFuture(new Map<Id, EUR_CRM_Sales_Order__c>(filteredOrders).keySet());
    }


    /*=================================
    *   High level helpers
    * =================================*/
    @future(callout=true)
    private static void sendEmailFuture(Set<Id> salesOrdersIds) {
        List<EUR_CRM_Sales_Order__c> ordersWithCountryCodesAndDevNamesOnly = selectOrdersWhereIds(salesOrdersIds);
        Map<String, Map<String, OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new OrderEmailSetupCMTWrapper().getEmailSetupByDevNameByCountryCode(ordersWithCountryCodesAndDevNamesOnly);
        System.debug('\n emailSetupByDevNameByCountryCode.size() => ' + emailSetupByDevNameByCountryCode.size() + '\n');
        System.debug('\n emailSetupByDevNameByCountryCode => ' + JSON.serializePretty(emailSetupByDevNameByCountryCode) + '\n');
        if (emailSetupByDevNameByCountryCode.isEmpty()) { return; }

        List<EUR_CRM_Sales_Order__c> ordersToSendEmail = selectOrdersOnQuery(emailSetupByDevNameByCountryCode, salesOrdersIds);
        System.debug('\n ordersToSendEmail.size() => ' + ordersToSendEmail.size() + '\n');
        System.debug('\n ordersToSendEmail => ' + JSON.serializePretty(ordersToSendEmail) + '\n');
        if (ordersToSendEmail.isEmpty()) { return; }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (EUR_CRM_Sales_Order__c order : ordersToSendEmail) {
            if ( ! isEmailSetupContainsOrderCountryCodeAndRT(emailSetupByDevNameByCountryCode, order)) { continue; }

            OrderEmailSetupCMTWrapper emailSetup = emailSetupByDevNameByCountryCode.get(order.EUR_CRM_Country_Code__c).get(order.RecordType.DeveloperName);

            List<String> mailToAddresses = extractFieldValues(emailSetup.mailToEmailFields, order);
            List<String> copyToAddresses = extractFieldValues(emailSetup.copyToEmailFields, order);
            List<String> copyToCustomerServiceAddresses = new List<String>(emailSetup.copyToCustomerServiceEmails);
            copyToAddresses.addAll(copyToCustomerServiceAddresses);

            EmailTemplate emailTemplate = EMAIL_TEMPLATE_BY_DEVELOPER_NAME.get(emailSetup.emailTemplateDevName);
            Messaging.SingleEmailMessage email = createEmail(mailToAddresses, copyToAddresses, emailTemplate.Id, order);
            emails.add(email);
        }

        if ( ! Test.isRunningTest()) {
            Messaging.sendEmail(emails, false);
        }
    }

    private static List<EUR_CRM_Sales_Order__c > filterOrders(List<EUR_CRM_Sales_Order__c > orders, Map<Id, sObject> oldOrdersMap) {
        if (oldOrdersMap == null) { return filterOrders(orders); }

        List<EUR_CRM_Sales_Order__c > changedOrders = new List<EUR_CRM_Sales_Order__c >();
        for (EUR_CRM_Sales_Order__c order : (List<EUR_CRM_Sales_Order__c >) orders) {
            EUR_CRM_Sales_Order__c oldOrder = (EUR_CRM_Sales_Order__c) oldOrdersMap.get(order.Id);
            if (order.EUR_CRM_Status__c != oldOrder.EUR_CRM_Status__c) {
                changedOrders.add(order);
            }
        }
        return filterOrders(changedOrders);
    }

    private static List<EUR_CRM_Sales_Order__c> filterOrders(List<EUR_CRM_Sales_Order__c> orders) {
        List<EUR_CRM_Sales_Order__c> ordersToSendEmail = new List<EUR_CRM_Sales_Order__c>();
        for (EUR_CRM_Sales_Order__c order : (List<EUR_CRM_Sales_Order__c>)orders) {
            if (order.EUR_CRM_Status__c == ORDER_STATUS_TO_SEND && String.isNotBlank(order.EUR_CRM_Country_Code__c)) {
                ordersToSendEmail.add(order);
            }
        }
        return ordersToSendEmail;
    }


    /*=================================
    *   Middle level helpers
    * =================================*/
    private static Messaging.SingleEmailMessage createEmail(List<String> toAddresses, List<String> copyToAddresses, Id templateId, EUR_CRM_Sales_Order__c order) {
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null, order.Id);
        email.setUseSignature(false);
        email.setSaveAsActivity(false);
        if ( ! toAddresses.isEmpty()) {
            email.setToAddresses(toAddresses);
        }
        if ( ! copyToAddresses.isEmpty()) {
            email.setBccAddresses(copyToAddresses);
        }
        email.setSenderDisplayName(order.EUR_CRM_Sales_Rep_Name__c);

        return email;
    }
    @TestVisible
    private static List<String> extractFieldValues(List<String> fieldsToExtract, EUR_CRM_Sales_Order__c order) {
        List<String> fieldValues = new List<String>();
        for (String field : fieldsToExtract) {
            String fieldValue = extractFieldValueRecursive(field, order);
            if (String.isNotBlank(fieldValue)){
                fieldValues.add(fieldValue);
            }
        }
        return fieldValues;
    }

    public static String extractFieldValueRecursive(String fieldToExtract, SObject obj) {
        if (fieldToExtract.contains('.')) {
            SObject tmpSObject = obj.getSObject(fieldToExtract.split('\\.')[0]);
            String fieldNew = fieldToExtract.substringAfter('.');
            if (tmpSObject == null) { return ''; }
            return extractFieldValueRecursive(fieldNew,tmpSObject);
        }

        return (String)obj.get(fieldToExtract);
    }

    @TestVisible
    private static List<EUR_CRM_Sales_Order__c> selectOrdersOnQuery(Map<String, Map<String, OrderEmailSetupCMTWrapper>> emailSetupCMTWrapperByDevNameByCountryCode, Set<Id> salesOrdersIds) {
        Set<String> fieldNames = extractFieldNames(emailSetupCMTWrapperByDevNameByCountryCode);
        if (fieldNames.isEmpty()) { return new List<EUR_CRM_Sales_Order__c>(); }

        return selectOrdersOnQuery(buildOrdersQuery(fieldNames),salesOrdersIds);
    }

    private static List<EUR_CRM_Sales_Order__c> selectOrdersOnQuery(String query, Set<Id> salesOrdersIds) {
        System.debug('query => ' + query);
        return (List<EUR_CRM_Sales_Order__c>) Database.query(query);
    }

    /*=================================
    *   Low level helpers
    * =================================*/
    private static Set<String> extractFieldNames(Map<String, Map<String, OrderEmailSetupCMTWrapper>> orderEmailSetupCMTWrapperByDevNameByCountryCode) {
        Set<String> fieldNames = new Set<String>();
        for (Map<String, OrderEmailSetupCMTWrapper> emailSetupCMTWrapperByDevName : orderEmailSetupCMTWrapperByDevNameByCountryCode.values()) {
            for (OrderEmailSetupCMTWrapper emailSetupCMTWrapper : emailSetupCMTWrapperByDevName .values()) {
                fieldNames.addAll(emailSetupCMTWrapper.mailToEmailFields);
                fieldNames.addAll(emailSetupCMTWrapper.copyToEmailFields);
            }
        }
        if (fieldNames.isEmpty()) { return new Set<String>(); }
        return fieldNames;
    }

    private static String buildOrdersQuery(Set<String> fieldsForQuery) {

        String query = 'SELECT Id, ';
        for (String field : fieldsForQuery) {
            query += field + ',';
        }
        query += 'EUR_CRM_Country_Code__c, ';
        query += 'EUR_CRM_Sales_Rep_Name__c, ';
        query += 'RecordTypeId, RecordType.DeveloperName ';
        query += ' FROM EUR_CRM_Sales_Order__c';
        query += ' WHERE Id IN :salesOrdersIds ';
        query += ' ORDER BY EUR_CRM_Country_Code__c';
        return query;
    }

    private static Boolean isEmailSetupContainsOrderCountryCodeAndRT(Map<String, Map<String, OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode, EUR_CRM_Sales_Order__c order) {
        return emailSetupByDevNameByCountryCode.containsKey(order.EUR_CRM_Country_Code__c)
            && emailSetupByDevNameByCountryCode.get(order.EUR_CRM_Country_Code__c).containsKey(order.RecordType.DeveloperName);

    }


    /*=================================
    *   SOQL Selectors
    * =================================*/
    @TestVisible
    private static List<EUR_CRM_Sales_Order__c> selectOrdersWhereIds(Set<Id> orderIds) {
        return [
            SELECT Id
                , EUR_CRM_Country_Code__c
                , RecordType.DeveloperName
                , EUR_CRM_Status__c
            FROM EUR_CRM_Sales_Order__c
            WHERE Id IN :orderIds
        ];
    }

    /*=================================
    *   Wrappers
    * =================================*/
    @TestVisible
    private class OrderEmailSetupCMTWrapper {
        private String countryCode;
        private String orderRecordTypeDevName;
        @TestVisible
        private String emailTemplateDevName;
        @TestVisible
        private List<String> mailToEmailFields;
        @TestVisible
        private List<String> copyToEmailFields;
        @TestVisible
        private List<String> copyToCustomerServiceEmails;

        @TestVisible
        private OrderEmailSetupCMTWrapper(){

        }

        private OrderEmailSetupCMTWrapper(EUR_CRM_CT_Order_Email_Setup__mdt emailSetup) {
            this.countryCode = emailSetup.EUR_CRM_Country_Code__c;
            this.emailTemplateDevName = emailSetup.EUR_CRM_Email_Template_Dev_Name__c;
            this.orderRecordTypeDevName = emailSetup.EUR_CRM_Order_Record_Type_Dev_Name__c;
            this.mailToEmailFields = this.getSplittedEmailSetupFieldValue(emailSetup.EUR_CRM_Mail_To_Email_Fields__c);
            this.copyToEmailFields = this.getSplittedEmailSetupFieldValue(emailSetup.EUR_CRM_Copy_To_Email_Fields__c);
            this.copyToCustomerServiceEmails = this.getSplittedEmailSetupFieldValue(emailSetup.EUR_CRM_Copy_To_Customer_Service_Email__c);
        }
        @TestVisible
        private Map<String, Map<String, OrderEmailSetupCMTWrapper>> getEmailSetupByDevNameByCountryCode(List<EUR_CRM_Sales_Order__c> orders) {
            Set<String> countryCodes = this.extractCountryCodes(orders);
            Set<String> developerNames = this.extractDeveloperNames(orders);
            return this.getEmailSetupByDevNameByCountryCode(countryCodes, developerNames);
        }

        private Map<String, Map<String, OrderEmailSetupCMTWrapper>> getEmailSetupByDevNameByCountryCode(Set<String> countryCodes, Set<String> developerNames) {
            List<EUR_CRM_CT_Order_Email_Setup__mdt> emailSetupsCMT = this.selectOrdersEmailSetup(countryCodes, developerNames);

            if (emailSetupsCMT.isEmpty()) { return new Map<String, Map<String, OrderEmailSetupCMTWrapper>>(); }

            return getEmailSetupByDevNameByCountryCode(emailSetupsCMT);
        }

        private Map<String, Map<String,OrderEmailSetupCMTWrapper>> getEmailSetupByDevNameByCountryCode(List<EUR_CRM_CT_Order_Email_Setup__mdt> emailSetups) {
            Map<String, Map<String,OrderEmailSetupCMTWrapper>> emailSetupByDevNameByCountryCode = new Map<String, Map<String,OrderEmailSetupCMTWrapper>>();
            for (EUR_CRM_CT_Order_Email_Setup__mdt emailSetup : emailSetups) {
                if (emailSetupByDevNameByCountryCode.containsKey(emailSetup.EUR_CRM_Country_Code__c)) {
                    emailSetupByDevNameByCountryCode.get(emailSetup.EUR_CRM_Country_Code__c).put(emailSetup.EUR_CRM_Order_Record_Type_Dev_Name__c, new OrderEmailSetupCMTWrapper(emailSetup));
                } else {
                    emailSetupByDevNameByCountryCode.put(emailSetup.EUR_CRM_Country_Code__c, new Map<String, OrderEmailSetupCMTWrapper>{emailSetup.EUR_CRM_Order_Record_Type_Dev_Name__c => new OrderEmailSetupCMTWrapper(emailSetup)});
                }
            }
            return emailSetupByDevNameByCountryCode;
        }

        private Set<String> extractCountryCodes(List<EUR_CRM_Sales_Order__c> orders) {
            Set<String> countryCodes = new Set<String>();
            for (EUR_CRM_Sales_Order__c order : orders) {
                countryCodes.add(order.EUR_CRM_Country_Code__c);
            }
            return countryCodes;
        }

        private Set<String> extractDeveloperNames(List<EUR_CRM_Sales_Order__c> orders) {
            Map<Id, RecordTypeInfo> orderRecordTypeInfoById = this.getOrderRecordTypeInfoById();
            Set<String> developerNames = new Set<String>();
            for (EUR_CRM_Sales_Order__c order : orders) {
                developerNames.add(orderRecordTypeInfoById.get(order.RecordTypeId).getDeveloperName());
            }
            return developerNames;
        }

        private Map<Id, RecordTypeInfo> getOrderRecordTypeInfoById() {
            return Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosById();
        }

        private List<String> getSplittedEmailSetupFieldValue(String field) {
            if (String.isBlank(field)) { return new List<String>(); }

            Set<String> fields = new Set<String>();
            fields.addAll(field.deleteWhitespace().split(','));
            return new List<String>(fields);
        }

        private List<EUR_CRM_CT_Order_Email_Setup__mdt> selectOrdersEmailSetup(Set<String> countryCodes, Set<String> developerNames) {
            if (Test.isRunningTest()) {
                return this.selectFilteredEmailSetupsForTest(countryCodes,developerNames);
            }
            return [
                SELECT EUR_CRM_Country_Code__c,
                    EUR_CRM_Mail_To_Email_Fields__c,
                    EUR_CRM_Copy_To_Email_Fields__c,
                    EUR_CRM_Copy_To_Customer_Service_Email__c,
                    EUR_CRM_Email_Template_Dev_Name__c,
                    EUR_CRM_Order_Record_Type_Dev_Name__c
                FROM EUR_CRM_CT_Order_Email_Setup__mdt
                WHERE EUR_CRM_Country_Code__c IN :countryCodes
                AND EUR_CRM_Order_Record_Type_Dev_Name__c IN :developerNames
            ];
        }

        private List<EUR_CRM_CT_Order_Email_Setup__mdt> selectFilteredEmailSetupsForTest(Set<String> countryCodes, Set<String> developerNames) {
            List<EUR_CRM_CT_Order_Email_Setup__mdt> emailSetupsFiltered = new List<EUR_CRM_CT_Order_Email_Setup__mdt>();
            for (EUR_CRM_CT_Order_Email_Setup__mdt emailSetup : emailSetupsForTest) {
                if (countryCodes.contains(emailSetup.EUR_CRM_Country_Code__c) && developerNames.contains(emailSetup.EUR_CRM_Order_Record_Type_Dev_Name__c)){
                    emailSetupsFiltered.add(emailSetup);
                }
            }
            return emailSetupsFiltered;
        }
    }
}