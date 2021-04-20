@RestResource(urlMapping='/LAT_Rest_Docusign/*')
global without sharing class LAT_REST_Docusign {    
    @HttpPost
    global static String doPOST() {
        RestRequest objRequest = null;
        String strDocusignId = null;
        String strResult = null;

        System.debug('LAT_REST_Docusign.doPOST[] ->');

        objRequest = RestContext.request;
        System.debug('LAT_REST_Docusign.doPOST[objRequest.requestURI : ' + objRequest.requestURI + ']');
        strDocusignId = objRequest.requestURI.substringAfterLast('/');
        System.debug('LAT_REST_Docusign.doPOST[strDocusignId : ' + strDocusignId + ']');
        
        strResult = LAT_Docusign_Utils.requestResendButton(strDocusignId);

        System.debug('LAT_REST_Docusign.doPOST[' + strResult + '] <-');
        return strResult;
    }
}