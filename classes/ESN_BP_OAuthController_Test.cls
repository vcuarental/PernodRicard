@isTest
private class ESN_BP_OAuthController_Test {
     
     @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ESN_BP_MockHttpResponseGenerator());
        
        ESN_BP_OAuthController.getToken('aPrx_vK.AljnHqPp4RPiyfJedwblFFhjke7adnbsJ8.v_3753qw297Yk_LOhHvydtdOKbC0EiQ==');
        
        ESN_BP_OAuthController.getToken('aPrx_vK.AljnHqPp4RPiyfJedwblFFhjke7adnbsJ8.v_3753qw297Yk_LOhHvydtdOKbC0EiQ%3D%3D');
        
        ESN_BP_OAuthController.getRefreshToken('aPrx_vK.AljnHqPp4RPiyfJedwblFFhjke7adnbsJ8.v_3753qw297Yk_LOhHvydtdOKbC0EiQ==');
        
        ESN_BP_OAuthController.getRefreshToken('aPrx_vK.AljnHqPp4RPiyfJedwblFFhjke7adnbsJ8.v_3753qw297Yk_LOhHvydtdOKbC0EiQ%3D%3D');
        
        String var1 = ESN_BP_OAuthController.AUTHORIZE_URL;
        String var2 = ESN_BP_OAuthController.WEB_SERVER_CONNECTED_APP_CLIENT_ID;
        String var3 = ESN_BP_OAuthController.WEB_SERVER_CONNECTED_APP_REDIRECT_URI;
        String var4 = ESN_BP_OAuthController.USER_AGENT_CONNECTED_APP_CLIENT_ID;
        String var5 = ESN_BP_OAuthController.USER_AGENT_CONNECTED_APP_REDIRECT_URI;        
    }
}