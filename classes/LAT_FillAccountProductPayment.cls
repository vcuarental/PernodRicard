/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/

public with sharing class LAT_FillAccountProductPayment {

    public static void fillProductPayment(List<LAT_Account_product_payment__c> params){
        List <String> lstPaisMigra = new List<string>();
        Set <string> countryAN8List = new Set <string>();
        Set <string> paymentConditionList = new Set <string>();
        Set <string> ProductExternalIdList = new Set <string>();
        for (Sobject sob : params) {
            LAT_Account_product_payment__c app = (LAT_Account_product_payment__c)sob;
            if (app.CustomerCountryAN8Code__c != null && app.CustomerCountryAN8Code__c != ''){
                countryAN8List.add(app.CustomerCountryAN8Code__c);
                lstPaisMigra.add(app.CustomerCountryAN8Code__c);
            }
            if (app.PaymentConditionExternalId__c != null && app.PaymentConditionExternalId__c != '')  paymentConditionList.add(app.PaymentConditionExternalId__c);
            if (app.ProductExternalId__c != null && app.ProductExternalId__c != '')  ProductExternalIdList.add(app.ProductExternalId__c);
        }
        String paisMigra = lstPaisMigra.get(0).substringBefore('-');
        if(!Utils.wasMigrationDone(paisMigra)) { 
            List <Account> accounts = [SELECT Id, Client_country_AN8__c FROM Account WHERE Client_country_AN8__c IN: countryAN8List];
            List <UDC__c> paymentConditions = [SELECT Id, Internal_Id__c, CodDefUsuario__c, Name FROM UDC__c WHERE Internal_Id__c IN: paymentConditionList];
            List <Product2> products = [SELECT Id, Internal_id__c FROM Product2 WHERE LAT_IsRefactorProduct__c = 'Y' AND Internal_id__c IN: ProductExternalIdList];
            map <string, Account> accountByExternalIdMap = new map <string, Account>();
            map <string, UDC__c> udcByExternalIdMap = new map <string, UDC__c>();
            map <string, Product2> productByExternalIdMap = new map <string, Product2>();
            
            for (Account acc : accounts) {
                accountByExternalIdMap.put(acc.Client_country_AN8__c, acc);
            }
            for (UDC__c udc : paymentConditions) {
                udcByExternalIdMap.put(udc.Internal_Id__c, udc);
            }
            for (Product2 p : products) {
                productByExternalIdMap.put(p.Internal_id__c, p);
            }
            for (Sobject sob : params) {
                LAT_Account_product_payment__c app = (LAT_Account_product_payment__c)sob;
                if (accountByExternalIdMap.containsKey(app.CustomerCountryAN8Code__c)) {
                    app.Account__c = accountByExternalIdMap.get(app.CustomerCountryAN8Code__c).Id;
                }
                if (udcByExternalIdMap.containsKey(app.PaymentConditionExternalId__c)) {
                    app.Payment__c = udcByExternalIdMap.get(app.PaymentConditionExternalId__c).Id;
                    app.PaymentCondition__c = udcByExternalIdMap.get(app.PaymentConditionExternalId__c).CodDefUsuario__c;
                    app.PaymentConditionDescription__c = udcByExternalIdMap.get(app.PaymentConditionExternalId__c).Name;
                }
                if (productByExternalIdMap.containsKey(app.ProductExternalId__c)) {
                    app.Product__c = productByExternalIdMap.get(app.ProductExternalId__c).Id;
                }
                app.ExternalUniqueKey__c = app.CustomerCountryAN8Code__c + '-' + app.ProductExternalId__c + '-' + app.PaymentConditionExternalId__c; 
            }
        }
        //MIGRATED 17/11/2016
        else {
            /*Set <string> countryAN8List = new Set <string>();
            Set <string> paymentConditionList = new Set <string>();
            Set <string> ProductExternalIdList = new Set <string>();
            for (Sobject sob : trigger.new) {
                LAT_Account_product_payment__c app = (LAT_Account_product_payment__c)sob;
                if (app.CustomerCountryAN8Code__c != null && app.CustomerCountryAN8Code__c != '') countryAN8List.add(app.CustomerCountryAN8Code__c);
                if (app.PaymentConditionExternalId__c != null && app.PaymentConditionExternalId__c != '')  paymentConditionList.add(app.PaymentConditionExternalId__c);
                if (app.ProductExternalId__c != null && app.ProductExternalId__c != '')  ProductExternalIdList.add(app.ProductExternalId__c);
            }*/
            List <Account> accounts = [SELECT Id, Client_country_AN8__c FROM Account WHERE Client_country_AN8__c IN: countryAN8List];
            List <UDC__c> paymentConditions = [SELECT Id, Internal_Id__c, CodDefUsuario__c, Name FROM UDC__c WHERE Internal_Id__c IN: paymentConditionList];
            List <LAT_Product__c> products = [SELECT Id, LAT_ExternalId__c FROM LAT_Product__c WHERE LAT_IsRefactorProduct__c = 'Y' AND LAT_ExternalId__c IN: ProductExternalIdList];
            map <string, Account> accountByExternalIdMap = new map <string, Account>();
            map <string, UDC__c> udcByExternalIdMap = new map <string, UDC__c>();
            map <string, LAT_Product__c> productByExternalIdMap = new map <string, LAT_Product__c>();
            
            for (Account acc : accounts) {
                accountByExternalIdMap.put(acc.Client_country_AN8__c, acc);
            }
            for (UDC__c udc : paymentConditions) {
                udcByExternalIdMap.put(udc.Internal_Id__c, udc);
            }
            for (LAT_Product__c p : products) {
                productByExternalIdMap.put(p.LAT_ExternalId__c, p);
            }
            for (Sobject sob : params) {
                LAT_Account_product_payment__c app = (LAT_Account_product_payment__c)sob;
                if (accountByExternalIdMap.containsKey(app.CustomerCountryAN8Code__c)) {
                    app.Account__c = accountByExternalIdMap.get(app.CustomerCountryAN8Code__c).Id;
                }
                if (udcByExternalIdMap.containsKey(app.PaymentConditionExternalId__c)) {
                    app.Payment__c = udcByExternalIdMap.get(app.PaymentConditionExternalId__c).Id;
                    app.PaymentCondition__c = udcByExternalIdMap.get(app.PaymentConditionExternalId__c).CodDefUsuario__c;
                    app.PaymentConditionDescription__c = udcByExternalIdMap.get(app.PaymentConditionExternalId__c).Name;
                }
                if (productByExternalIdMap.containsKey(app.ProductExternalId__c)) {
                    app.LAT_Product__c = productByExternalIdMap.get(app.ProductExternalId__c).Id;
                }
                app.ExternalUniqueKey__c = app.CustomerCountryAN8Code__c + '-' + app.ProductExternalId__c + '-' + app.PaymentConditionExternalId__c; 

            }
        }
        Integer a = 10;
        Integer a1 = 10;
        Integer a2 = 10;
        Integer a3 = 110;
        Integer a4 = 10;
        Integer a5 = 10;
        Integer a6 = 10;

    }

    
}