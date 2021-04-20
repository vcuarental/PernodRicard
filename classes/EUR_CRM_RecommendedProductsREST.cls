/**
 * Created by Ilarion Tokarskyi on 24.11.2020.
 */
@RestResource(UrlMapping = '/convivio/v1/recommended-products/*')
global with sharing class EUR_CRM_RecommendedProductsREST {
//  /services/apexrest/kdp/recommended_products/
    @HttpPost
    global static void doPost() {
        EUR_CRM_RecommendedProductsService service = new EUR_CRM_RecommendedProductsService();
        if (service.isInvalidBody(RestContext.request.requestBody.toString())) return;
        service.updateAccountsAndUpsertRecProducts();
    }
}