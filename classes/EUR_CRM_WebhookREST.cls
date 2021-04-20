/**
 * Created by Ilarion Tokarskyi on 22.12.2020.
 */
@RestResource(urlMapping='/webhooks/*')
global class EUR_CRM_WebhookREST {

    @HttpPost
    global static void handlePost() {
        new EUR_CRM_WebhookREST_Service().handleRequestBody(RestContext.request.requestBody.toString());
    }
}