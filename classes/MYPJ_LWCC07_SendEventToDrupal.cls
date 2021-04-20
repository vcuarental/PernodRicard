public with sharing class MYPJ_LWCC07_SendEventToDrupal {
    
    @AuraEnabled
    public static returnValuesClass sendToDrupal(String recordId){
        Map<String,String> fieldsToJson = initCustomMedataTypeFields();
        Map<String,String> JsonType = initCustomMedataTypeFieldsType();
        Campaign campaign = queryCampaign(recordId, fieldsToJson);
        
        // if(campaign.MMPJ_XRM_Synchro_Drupal__c != '1' && campaign.MMPJ_XRM_Synchro_Drupal__c != '3')
        // {
            JSONGenerator jg = prepareJSON(campaign,fieldsToJson,JsonType);
            returnValuesClass returnValue = sendJSON(jg);

            String updateMessage = updateCampaign(recordId, returnValue.statusCode);
            if(String.isNotBlank(updateMessage))
            {
                returnValue.message = System.Label.MYPJ_LWC07_SFDC_update_Error + updateMessage;
            }
            return returnValue;
        // } else {
        //     returnValuesClass returnValue = new returnValuesClass(true,null,System.Label.MMPJ_XRM_Already_Sent_To_GRT);
        //     return returnValue;
        // }
    }
    

    public static Map<String,String> initCustomMedataTypeFields()
    {
        Map<String,String> fieldsToJson = new Map<String,String>();
        for (MMPJ_XRM_Salesforce_Event_Drupal__mdt mdt : [SELECT Salesforce_Field__c, Drupal_JSON_Field__c FROM MMPJ_XRM_Salesforce_Event_Drupal__mdt])
        {
            fieldsToJson.put(mdt.Salesforce_Field__c,mdt.Drupal_JSON_Field__c);
        }

        return fieldsToJson;
            
    }

    public static Map<String,String> initCustomMedataTypeFieldsType()
    {
        Map<String,String> JsonType = new Map<String,String>();
        for (MMPJ_XRM_Salesforce_Event_Drupal__mdt mdt : [SELECT Drupal_JSON_Field__c, Drupal_JSON_Field_Type__c FROM MMPJ_XRM_Salesforce_Event_Drupal__mdt])
        {
            JsonType.put(mdt.Drupal_JSON_Field__c,mdt.Drupal_JSON_Field_Type__c);
        }

        return JsonType;
            
    }

    public static Campaign queryCampaign(String recordId, Map<String,String> fieldsToJson)
    {
        List<String> fields=new List<String>();
        fields.addAll(fieldsToJson.KeySet());
        String queryString = 'SELECT MMPJ_XRM_Synchro_Drupal__c, ' + String.join(fields,',') + ' FROM Campaign WHERE Id = \'' + recordId + '\'';
        List<Campaign> campaigns = Database.query(queryString);
        return campaigns[0];
    }

    public static JSONGenerator prepareJSON(Campaign campaign, Map<String,String> fieldsToJson, Map<String,String> JsonType)
    {
        Map<String, Schema.SObjectField> campaignDescribe = Schema.SObjectType.Campaign.fields.getMap();


        JSONGenerator jg = JSON.createGenerator(false);
        jg.writeStartObject();
        jg.writeStringField('langcode', 'ja-jp');
        for(String field:fieldsToJson.KeySet())
        {
            Schema.DisplayType fieldType = campaignDescribe.get(field).getDescribe().getType();

            if(JsonType.get(fieldsToJson.get(field)).toUpperCase() == 'STRING')
            {
                String fieldValue = '';
                if(campaign.get(field) != null)
                {
                    if(fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Integer)
                    {
                        fieldValue = String.valueOf(campaign.get(field));
                    } else if(fieldType == Schema.DisplayType.Date) {
                        Date dt = (Date)campaign.get(field);
                        fieldValue = dt.year() + '-' + String.valueOf(dt.month()).leftPad(2,'0') + '-' + String.valueOf(dt.day()).leftPad(2,'0');
                    } else if(fieldType == Schema.DisplayType.DateTime) {
                        DateTime dt = (DateTime)campaign.get(field);
                        // DateTime dtInGMT = dt;//.dateGmt();
                        TimeZone tz = UserInfo.getTimeZone();
                        dt = dt.addSeconds(-1 * tz.getOffset(dt)/1000);
                        fieldValue = dt.formatGmt('YYYY-MM-dd HH:mm:ss').replace(' ','T');
                        // fieldValue = dt.year() + '-' + String.valueOf(dt.month()).leftPad(2,'0') + '-' + String.valueOf(dt.day()).leftPad(2,'0') + 'T' + String.valueOf(dt.hour()).leftPad(2,'0') + ':' + String.valueOf(dt.minute()).leftPad(2,'0') + ':' + String.valueOf(dt.second()).leftPad(2,'0');// + '.000Z';
                    } else if(fieldType == Schema.DisplayType.Boolean) {
                        fieldValue = ('' + (Boolean)campaign.get(field));
                    } else {
                        fieldValue = (String)campaign.get(field);
                    }
                }

                jg.writeStringField(fieldsToJson.get(field), fieldValue);
            } else if(JsonType.get(fieldsToJson.get(field)).toUpperCase() == 'NUMBER')
            {
                Decimal fieldValue = 0;
                if(campaign.get(field) != null)
                {
                    if(fieldType == Schema.DisplayType.String)
                    {
                        fieldValue = Decimal.valueOf((String)campaign.get(field));
                    } else {
                        fieldValue = (Decimal)campaign.get(field);
                    }
                }
                jg.writeNumberField(fieldsToJson.get(field), fieldValue);
            } else if(JsonType.get(fieldsToJson.get(field)).toUpperCase() == 'BOOLEAN')
            {
                jg.writeBooleanField(fieldsToJson.get(field), (Boolean)campaign.get(field));
            }
        }
        jg.writeEndObject();

        System.debug(jg.getAsString());

        return jg;
    }

    public static returnValuesClass sendJSON(JSONGenerator jg)
    {
        Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        HttpRequest req = new HttpRequest();

        req.setEndpoint((org.IsSandbox) ? 'callout:Drupal_Event_Credentials_RECETTE' : 'callout:Drupal_Event_Credentials_PROD');
        
        // req.setHeader('ApiKey','{!$Credential.Password}');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        // req.setHeader('x-ids-type-identite', 'EXT');
        req.setMethod('POST');
        req.setTimeout(20000);
        req.setBody(jg.getAsString());
        try {
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('retour : ' + res.getStatus());

            returnValuesClass returnValue = new returnValuesClass(true, res.getStatusCode(), '');
            if(res.getStatusCode() == 200
                || res.getStatusCode() == 201
                || res.getStatusCode() == 208
                )
            {
                System.debug('#### res.getBody() : ' + res.getBody());
                returnValue.isError = false;
                returnValue.message = 'Envoi à Drupal réussi';
            } else {
                returnValue.isError = true;
                returnValue.message = (String.isNotBlank(res.getBody())) ? res.getBody().stripHtmlTags() : res.getStatus();
            }
            return returnValue;
        } catch(Exception ex)
        {
            returnValuesClass returnValue = new returnValuesClass(true, 0 , ex.getMessage());
            return returnValue;
        }
    }

    public static String updateCampaign(String recordId, Integer StatusCode)
    {
        try {
            Campaign campaign = new Campaign(Id=recordId);
            campaign.MMPJ_XRM_Synchro_Drupal__c = (StatusCode == 200 || StatusCode == 201 || StatusCode == 208) ? '1' : '2';
            //This field will contain the username of the user who sent the campaign in Drupal (if possible), 
            //the date and time of sending on the same template as the "Created by" and "Last modified by" fields. 
            campaign.Drupal_event_creation__c = UserInfo.getName() + ' ' + Datetime.now();
            update campaign;

            return '';
        } catch(Exception ex)
        {
            return ex.getMessage();
        }
    }

    public class returnValuesClass{
        @AuraEnabled public Boolean isError{get;set;}
        @AuraEnabled public Integer statusCode{get;set;}
        @AuraEnabled public String message{get;set;}
        public returnValuesClass(Boolean isError,Integer statusCode, String message)
        {
            this.isError = isError;
            this.statusCode = statusCode;
            this.message = message;
        }
    }
}