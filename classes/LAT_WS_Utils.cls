public class LAT_WS_Utils {

    public static CS001_JDEInterfaceCredentials__c integrationCred{get;set;}

    public LAT_WS_Utils() {

    }

    public static String getAuthorizationHeader() {
        final LAT_Info__c li = [SELECT Auth_User__c, Auth_Password__c
                            FROM LAT_Info__c
                            WHERE Name =: 'Settings'];
        final Blob headerValue = Blob.valueOf(li.Auth_User__c + ':' + li.Auth_Password__c);
        final String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        return authorizationHeader;
    }

    public static CS001_JDEInterfaceCredentials__c getHeaderKey(String country) {
        if(integrationCred == null){
          try{
            integrationCred = [SELECT EndPoint_PaymentProductManager__c,
                                     Country__c,
                                     EndPoint_PriceCalculation__c,
                                     EndPoint_NewPriceCalculation__c,
                                     EndPoint_SalesOrderHandler__c, 
                                     EndPoint_PaymentManager__c, 
                                     MASHERY_HEADER_KEY__c,
                                     EndPoint_GetStock__c,
                                     EndPoint_Customer_Credit_Status__c,
                                     EndPoint_ReceiptHandeler__c,
                                     EndPointPaymentApproveReproveDA__c, 
                                     EndPointPaymentCancelDA__c, 
                                     EndPointPaymentCreateDA__c, 
                                     Endpont_PaymentMoneyStatusME__c, 
                                     Endpont_PaymentProductStatusME__c,
                                     RemoteHostIP__c,
                                     System__c,
                                     SystemUserID__c,
                                     PriceCalcProcessingVersionParam__c,
                                     PriceCalcCurrencyParam__c, 
                                     Exec_new_Price_Calc__c,
                                     PriceCalcCompanyParam__c,
                                     Bridge_Password__c,
                                     Bridge_Username__c,
                                     LAT_JDE_Password__c,
                                     LAT_JDE_Username__c
                                    FROM CS001_JDEInterfaceCredentials__c WHERE Country__c=:country];
          }catch(exception e) {
            integrationCred = new CS001_JDEInterfaceCredentials__c();
          }
        }
        return integrationCred;
    }  

    /**
     * Returns the Processing version for the Price Catalogue Service by Country and Order Type
     * @param country
     * @param orderType
     */
    public static String getProcessingVersions(String country, String orderType) {
        String ret = 'NOT_FOUND';
        System.debug('En LAT_WS_Utils --> Country : '+ country + ', orderType : '+orderType);
        LAT_PriceCalculationProcessingVersion__c cs = [SELECT Processing_Version__c FROM LAT_PriceCalculationProcessingVersion__c 
                                                            WHERE Country__c =:country AND Order_Type__c =:orderType LIMIT 1];
        if (cs != null) {
            ret = cs.Processing_Version__c;
        }
        return ret;
    }

    public static String getWSEndpoint(String country) {
        String reqEndpoint = '';
        try {
          reqEndpoint = [SELECT EndPoint_CustomerHandler__c
                            FROM CS001_JDEInterfaceCredentials__c
                            WHERE Country__c =: country].EndPoint_CustomerHandler__c;
        } catch(exception e) {
          String logInfo = 'Exception:' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause();
          LAT_DebugUtil.insertDebug('LAT_WS_Utils', logInfo, '');
          System.debug(logInfo);
          System.debug(e);
        }
        return reqEndpoint;
    }

    public static String getWSEndpointMXOnTradeNotify() {
        String reqEndpoint = '';
        try {
          reqEndpoint = [SELECT Account_Notify__c
                            FROM CS001_JDEInterfaceCredentials__c
                            WHERE Country__c =: '12'].Account_Notify__c;

        } catch(exception e) {
          String logInfo = 'Exception:' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause();
          LAT_DebugUtil.insertDebug('LAT_WS_Utils', logInfo, '');
          System.debug(logInfo);
          System.debug(e);
        }
        return reqEndpoint;
    }

}