public with sharing class ESN_chatterDAM_DamApiCallout {

    public static String ENDPOINT = Label.ESN_chatterDAM_Endpoint;
    public static String ENDPOINT_AUTH = ENDPOINT + 'auth';
    public static String ENDPOINT_ASSETS = ENDPOINT + 'assets/';
    
    public static String USERNAME = Label.ESN_chatterDAM_Username;
    public static String PASSWORD = Label.ESN_chatterDAM_Password;
    
    /**
    * Get DAM authentication.
    * 
    * @return the session and the token.
    */
    public static List<String> authentication() {
        // Build the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(ENDPOINT_AUTH);
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"username":"' + USERNAME + '","password":"' + PASSWORD + '"}');
        req.setTimeout(120000);
             
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(Logginglevel.WARN, 'Response body: ' + res.getBody());
        
        // Get the cookie
        String cookie = res.getHeader('Set-Cookie');
        System.debug(Logginglevel.WARN, 'Set-Cookie: ' + cookie );
        
        // Get the index of the beginning of the JSESSIONID (after 'JSESSIONID=')
        Integer indexSession = cookie.indexOf('JSESSIONID=')+11;
        String cookieSession = cookie.substring(indexSession);
        Integer indexEndSession = cookieSession.indexOf(';');
        String jSessionId = cookieSession.substring(0,indexEndSession);
        
        // Get the index of the beginning of the JSESSIONID (after 'formToken=')
        Integer indexToken = cookie.indexOf('formToken=')+10;
        String cookieToken = cookie.substring(indexToken);
        Integer indexEndToken= cookieToken.indexOf(';');
        String token = cookieToken.substring(0, indexEndToken);
        
        System.debug(Logginglevel.WARN, 'JSESSIONID: ' + jSessionId + ' - X-XSRF-TOKEN: ' + token);
        
        // Add the session and token to a list to return
        List<String> session = new List<String>();
        session.add(jSessionId);
        session.add(token);
        System.debug(Logginglevel.WARN, session[0] + session[1]);
             
        return session;
    }
    
    /**
    * Get asset data.
    *
    * @param asset_Id.
    * @param session. 
    * @return asset data.
    */
    public static List<String> getAssetData(String asset_Id, List<String> session) {
        if (session == null || session.size() != 2) {
            session = authentication();
        }
        String jSessionId = session[0];
        String token = session[1];
            
        // Build the request
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(ENDPOINT_ASSETS + asset_Id);
        req.setTimeout(120000);
        req.setHeader('JSESSIONID',jSessionId);
        req.setHeader('X-XSRF-TOKEN',token);
        req.setHeader('Cookie','JSESSIONID='+jSessionId+'; formToken='+token);
        req.setTimeout(120000);
            
        Http http = new Http();
        HTTPResponse res = null;
        List<String> assetMetadata = new List<string>();
        try {
            res = http.send(req);
            ESN_chatterDAM_JSONAsset2Apex damAsset = ESN_chatterDAM_JSONAsset2Apex.parse(res.getBody().replace('-','_'));
            assetMetadata.add(damAsset.name);
            assetMetadata.add(damAsset.derivedFiles.thumbnail.url);	
            assetMetadata.add(damAsset.derivedFiles.bamAssetPreview.url);
        } catch (System.CalloutException e) {
            System.debug('ERROR:' + e);
        }
        
        return assetMetadata;
    }
    
    /**
    * Get asset data.
    *
    * @param asset_MidRes_Url.
    * @param session. 
    * @return blob image.
    */
    public static blob encodeAsset_MidRes(String asset_MidRes_Url, List<String> session) { 
        if (session == null || session.size() != 2) {
            session = authentication();
        }
        String jSessionId = session[0];
        String token = session[1];
        
        // Build the request
        HttpRequest req = new HttpRequest();
        asset_MidRes_Url = asset_MidRes_Url.replace(' ', '%20');
        req.setMethod('GET');
        req.setEndpoint(asset_MidRes_Url);
        req.setHeader('Content-Type', 'image/jpg');
        req.setHeader('JSESSIONID',jSessionId);
        req.setHeader('X-XSRF-TOKEN',token);
        req.setHeader('Cookie','JSESSIONID='+jSessionId+'; formToken='+token);
        req.setCompressed(true);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = null;
        try {
            res = http.send(req);
        } catch (System.CalloutException e){
            System.debug('ERROR:' + e);
        }
        return res.getBodyAsBlob();
    }
}