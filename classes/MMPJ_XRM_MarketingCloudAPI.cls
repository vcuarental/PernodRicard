public class MMPJ_XRM_MarketingCloudAPI {

    public static String getToken(){
        MMPJ_XRM_Marketing_API__c cs = MMPJ_XRM_Marketing_API__c.getOrgDefaults();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Test.isRunningTest()?'http://test-niji-marketing.com/v2/token':'callout:MMPJ_XRM_Marketing_cloud_api');
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setBody('{"grant_type": "client_credentials","client_id" : "'+cs.MMPJ_XRM_Client_id__c+'", "client_secret" : "'+cs.MMPJ_XRM_Client_secret__c+'"}');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('### '+res.getBody());
        Object respObj = res.getBody();
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        String token = (String)respMap.get('access_token');
        return token;
    }


    public static String createSMSDefinition(String token,String message,String definitionKey){
        
        MMPJ_XRM_Marketing_API__c cs = MMPJ_XRM_Marketing_API__c.getOrgDefaults();
        message+='%%=char(10)=%%'+ cs.MMPJ_XRM_Footer_SMS__c;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Test.isRunningTest()?'http://test-niji-marketing.com/messaging/v1/sms/definitions':'callout:MMPJ_XRM_Marketing_cloud_api_rest/messaging/v1/sms/definitions');
        System.debug('### '+req.getEndpoint());
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+token);
        String messageKey = cs.MMPJ_XRM_Prefixe_nom_message__c+ String.valueOf(cs.MMPJ_XRM_Numero_definition_message__c);
        System.debug('### MessageKey '+messageKey);
        req.setBody('{"definitionKey": "'+messageKey+'",'+
            '"name" : "'+messageKey+'",'+
            '"description": "Généré depuis Salesforce",'+
            '"content": {'+
                '"message": "'+message+'"'+
            '},'+
            '"subscriptions": {'+
                '"shortCode": "'+cs.MMPJ_XRM_ShortCode__c+'",'+
                '"countryCode": "FR",'+
                '"keyword": "'+cs.MMPJ_XRM_Keyword_Marketing__c+'"'+
            '}'+
        '}');
        System.debug('### body '+req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('### '+res.getBody());
        
        Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        if(respMap.containsKey('errorcode') && respMap.containsKey('message')){
            System.debug('### erreur création message');
            cs.MMPJ_XRM_Numero_definition_message__c++;
            update cs;
            if((Integer)respMap.get('errorcode')==30004){
                return 'Une erreur s\'est produite lors de la création du message';
            }
            return String.valueOf((Integer) respMap.get('errorcode')) +' : '+ (String) respMap.get('message');
        }
        return '';
    }


    public static String sendSMS(String token,List<Contact> contacts,String definitionKey, Id campaignId,String message){
        MMPJ_XRM_Marketing_API__c cs = MMPJ_XRM_Marketing_API__c.getOrgDefaults();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Test.isRunningTest()?'http://test-niji-marketing.com/messaging/v1/sms/messages':'callout:MMPJ_XRM_Marketing_cloud_api_rest/messaging/v1/sms/messages');
        System.debug('### '+req.getEndpoint());
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+token);
        // '{"definitionKey":"account-rest","recipients":[{"contactKey":"Astro25","to":"33670500364","attributes":{"FirstName":"David","LastName":"Salmon"}}],"attributes":{"RequestTrackingAttribute":"2"}}';
        String messageKey = cs.MMPJ_XRM_Prefixe_nom_message__c+String.valueOf(cs.MMPJ_XRM_Numero_definition_message__c);
        System.debug('### MessageKey '+messageKey);
        String body = '{"definitionKey":"'+messageKey+'","recipients":[';
        Boolean firstContact=true;
        for(Contact contact : contacts){
            if(!firstContact){
                body+=',';
                
            }else{
                firstContact=false;
            }
            body+='{"contactKey":"'+contact.Id+'","to":"'+contact.MMPJ_Ext_Vign_Telephone_portable_perso__c+'"}';
        }
        body+=',{"contactKey":"testErreur","to":"0"}';
        body+='],"attributes":{"RequestTrackingAttribute":"2"}}';
        System.debug('### body sendSMS '+body);
        req.setBody(body);

        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        cs.MMPJ_XRM_Numero_definition_message__c++;
        update cs;
        System.debug('### '+res.getBody());
        Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        if(respMap.containsKey('errorcode') && respMap.containsKey('message') && (Integer) respMap.get('errorcode')!=109001){
            return String.valueOf((Integer) respMap.get('errorcode')) +' : '+ (String) respMap.get('message');
        }

        if((Integer) respMap.get('errorcode') == 0 || (Integer) respMap.get('errorcode')==109001){
            MMPJ_XRM_SMS_Envoye__c smsEnvoye = new MMPJ_XRM_SMS_Envoye__c(
                MMPJ_XRM_Contenu__c = message,
                MMPJ_XRM_Date_envoi__c = DateTime.now(),
                MMPJ_XRM_Nb_destinataires__c = contacts.size(),
                MMPJ_XRM_Campaign__c = campaignId,
                Name = definitionKey,
                MMPJ_XRM_Initiateur_de_l_envoi__c= UserInfo.getUserId(),
                CurrencyIsoCode = 'EUR'
                
            );
            insert smsEnvoye;

            

            List<Object> responses =(List<Object>) respMap.get('responses');
            List<MMPJ_XRM_SMS__c> smsList = new List<MMPJ_XRM_SMS__c>();
            for(Object response : responses){
                System.debug('### response '+response);
                Map<String, Object> mapResponse = (Map<String,Object> ) response;
                smsList.add(new MMPJ_XRM_SMS__c(
                    MMPJ_XRM_SMS_Message_Key__c=(String)mapResponse.get('messageKey'),
                    MMPJ_XRM_SMS_Envoye__c = smsEnvoye.Id,
                    MMPJ_XRM_Date_envoi__c = Date.today(),
                    MMPJ_XRM_Message__c = mapResponse.containsKey('errorcode')?(String)mapResponse.get('message'):null
                    
                ));

            }
            if(smsList.size()!=0){
                insert smsList;
            }
        }
        return '';

    }

    public static Map<String,Object> getSMSStatus(String token, String messageKey){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Test.isRunningTest()?'http://test-niji-marketing.com/messaging/v1/sms/messages/'+messageKey:'callout:MMPJ_XRM_Marketing_cloud_api_rest/messaging/v1/sms/messages/'+messageKey);
        System.debug('### '+req.getEndpoint());
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+token);
        HttpResponse resp= new Http().send(req);

        String respContent = resp.getBody();
        if(respContent != null && respContent.contains('eventCategoryType')){
            Map<String,Object> mapResp = (Map<String,Object>) JSON.deserializeUntyped(respContent);
            return mapResp;
        }
        return new Map<String,Object>();

    }
}