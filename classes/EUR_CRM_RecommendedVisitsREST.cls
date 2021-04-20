/**
 * Created by Ilarion Tokarskyi on 05.11.2020.
 */
@RestResource(UrlMapping = '/convivio/v1/recommended-accounts/*')
global with sharing class EUR_CRM_RecommendedVisitsREST {
//  /services/apexrest/kdp/recommended_visits/
    @HttpPost
    global static void doPost() {
        EUR_CRM_RecommendedVisitsService service = new EUR_CRM_RecommendedVisitsService();
        if (service.isInvalidBody(RestContext.request.requestBody.toString())) return;
        service.insertRecommendedObjects();
    }
}