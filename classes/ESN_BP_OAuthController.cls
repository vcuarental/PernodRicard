global without sharing class ESN_BP_OAuthController {

    public static String AUTHORIZE_URL { get { return ESN_BP_Statics.AUTHORIZE_URL; } set; }
    public static String WEB_SERVER_CONNECTED_APP_CLIENT_ID { get { return ESN_BP_Statics.WEB_SERVER_CONNECTED_APP_CLIENT_ID; } set; }
    public static String WEB_SERVER_CONNECTED_APP_REDIRECT_URI { get { return ESN_BP_Statics.WEB_SERVER_CONNECTED_APP_REDIRECT_URI; } set; }
    public static String USER_AGENT_CONNECTED_APP_CLIENT_ID { get { return ESN_BP_Statics.USER_AGENT_CONNECTED_APP_CLIENT_ID; } set; }
    public static String USER_AGENT_CONNECTED_APP_REDIRECT_URI { get { return ESN_BP_Statics.USER_AGENT_CONNECTED_APP_REDIRECT_URI; } set; }
    public static String IE8_VERSION_URL { get { return ESN_BP_Statics.IE8_VERSION_URL; } set; }
    
    @RemoteAction
    global static String getRefreshToken(String refreshToken) {
    
        Http h = new Http();
        
        String CLIENT_ID = ESN_BP_Statics.USER_AGENT_CONNECTED_APP_CLIENT_ID;
        String CLIENT_SECRET = ESN_BP_Statics.USER_AGENT_CONNECTED_APP_CLIENT_SECRET;
        String body = 'grant_type=refresh_token&refresh_token=' + refreshToken + '&client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET;
        
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ESN_BP_Statics.TOKEN_URL);
            req.setMethod('POST');
            req.setBody(body);
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
            
            JSONParser parser = JSON.createParser(res.getBody());
            String accessToken;
            String instanceUrl;
            String error;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'access_token')) {
                    
                    parser.nextToken();
                    accessToken = parser.getText();
                } else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'instance_url')) {
                    
                    parser.nextToken();
                    instanceUrl = parser.getText();
                } else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'error')) {
                    
                    parser.nextToken();
                    error = parser.getText();
                    break;
                }
            }
            system.debug(accessToken);
            system.debug(instanceUrl);
            system.debug(error);
            return error != null ? 'error : ' + error : accessToken + '|' + instanceUrl;
        } catch (Exception e) {
            return 'error : ' + e.getMessage();
        }
    }
    
    @RemoteAction
    global static String getToken(String code) {
        
        Http h = new Http();
        
        String CLIENT_ID = ESN_BP_Statics.WEB_SERVER_CONNECTED_APP_CLIENT_ID;
        String CLIENT_SECRET = ESN_BP_Statics.WEB_SERVER_CONNECTED_APP_CLIENT_SECRET;
        String REDIRECT_URL = ESN_BP_Statics.WEB_SERVER_CONNECTED_APP_REDIRECT_URI;
        String body = 'grant_type=authorization_code&code=' + code + '&client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET + '&redirect_uri=' + REDIRECT_URL;
        
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ESN_BP_Statics.TOKEN_URL);
            req.setMethod('POST');
            req.setBody(body);
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
            
            JSONParser parser = JSON.createParser(res.getBody());
            String accessToken;
            String instanceUrl;
            String error;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'access_token')) {
                    
                    parser.nextToken();
                    accessToken = parser.getText();
                } else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'instance_url')) {
                    
                    parser.nextToken();
                    instanceUrl = parser.getText();
                } else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'error')) {
                    
                    parser.nextToken();
                    error = parser.getText();
                    break;
                }
            }
            system.debug(accessToken);
            system.debug(instanceUrl);
            system.debug(error);
            return error != null ? 'error : ' + error : accessToken + '|' + instanceUrl;
        } catch (Exception e) {
            return 'error : ' + e.getMessage();
        }
    }
}