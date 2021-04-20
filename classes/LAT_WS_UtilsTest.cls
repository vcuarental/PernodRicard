@isTest
private class LAT_WS_UtilsTest {
    
    @isTest static void getAuthorizationHeaderTest() {
        latInfoCreator();
        generalConficCreator();
        LAT_WS_Utils.getAuthorizationHeader();
    }


    @isTest static void getWSEndpointTest() {
    
        generalConficCreator();
        LAT_WS_Utils.getWSEndpoint('1');
    }
    
    @isTest static void getWSEndpointMXOnTradeNotify() {
    
        generalConficCreator();
        LAT_WS_Utils.getWSEndpointMXOnTradeNotify();
    }
    
    static void generalConficCreator() {
        // Insert an email to deliver
        LAT_GeneralConfig__c gc = new LAT_GeneralConfig__c(
            LAT_Value__c = 'http://test', name = 'WS_ENDPOINT_ON_TRADE_NOTIFY',
            LAT_Description__c = 'WS_ENDPOINT_ON_TRADE_NOTIFY');

        insert gc;
    }
    static void latInfoCreator() {
        LAT_Info__c info = new LAT_Info__c(name = 'Settings', Auth_Password__c = 'abc' , Auth_User__c = 'def');
        insert info;
    }

}