/**
 * Created by Ilarion Tokarskyi on 22.12.2020.
 */

public with sharing class EUR_CRM_WebhookREST_Service {
    private static final String INVALID_BODY_FORMAT = 'The message has an invalid format.\n';
    private static final String SUCCESS_BODY = 'The Webhook Successfully handled.\n';
    private static WebhookParser parser;
    private static List<ValidateParser> validateParser;

    public void handleRequestBody(String body) {
        try {
            validateParser = (List<ValidateParser>) JSON.deserialize(body, List<ValidateParser>.class);
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ValidateResponse(validateParser[0].data.ValidationCode)));
            System.debug('Successfully validate Webhook\n');
            System.debug('Validation code - ' + validateParser[0].data.ValidationCode);
            System.debug(RestContext.response.responseBody.toString());
            return;
        } catch (JSONException ex) {
            System.debug('Can`t validate Webhook with following body\n');
            System.debug('Body - ' + body);
        }
        try {
            parser = (WebhookParser) JSON.deserialize(body, WebhookParser.class);
        } catch (JSONException ex) {
            System.debug('Webhook parsing error\n');
            System.debug('Body - ' + body);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(INVALID_BODY_FORMAT);
            sendEmailNotification('EUR_CRM_WebhookREST_Service Error', 'Cant parse ' +
                    'request body: \n' + body);
            return;
        }
        insertNewWebhook(body);
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(SUCCESS_BODY);
        System.debug(SUCCESS_BODY);
    }

    private void insertNewWebhook(String body) {
        insert createWebhook(parser.data.SourceSystem, parser.data.Affiliate, parser.data.EntityTypeName, body);
    }

    private EUR_CRM_Webhook__c createWebhook(String sourceSystem, String affiliate, String entity, String body) {
        return new EUR_CRM_Webhook__c(
                EUR_CRM_Source_System__c = sourceSystem,
                EUR_CRM_Affiliate__c = affiliate,
                EUR_CRM_Entity__c = entity,
                EUR_CRM_Status__c = 'Received',
                EUR_CRM_Payload__c = body
        );
    }

    public static void sendEmailNotification(String title, String textMessage) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new List<String> { UserInfo.getUserEmail() });
        message.setSubject(title);
        message.setPlainTextBody(textMessage);
    }

    public class WebhookParser {
        public Data data;
    }
    public class Data {
        public String SourceSystem;
        public String Affiliate;
        public String EntityTypeName;
        public String ValidationCode;
    }

    public class ValidateParser {
        public Data data;
    }

    public class ValidateResponse {
        public String validationResponse;

        public ValidateResponse(String validationResponse) {
            this.validationResponse = validationResponse;
        }
    }
}