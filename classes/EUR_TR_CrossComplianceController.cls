/**
 * Created by osman on 30.12.2020.
 */

public with sharing class EUR_TR_CrossComplianceController {

    public class EUR_TR_CrossComplianceControllerException extends Exception {

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getCrossComplianceByAccountIdFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_CrossComplianceControllerException('Müşteri bilgisi boş bırakılamaz');
            }

            EUR_TR_Account__c account = (EUR_TR_Account__c) JSON.deserialize(requestBody, EUR_TR_Account__c.class);

            if (String.isBlank(account.Id)) {
                throw new EUR_TR_CrossComplianceControllerException('Müşteri bilgisi boş bırakılamaz');
            }

            List<EUR_TR_Account__c> foundAccount = [SELECT Id FROM EUR_TR_Account__c WHERE Id = :account.Id];
            if (foundAccount.isEmpty()) {
                throw new EUR_TR_CrossComplianceControllerException('Müşteri bulunamadı.');
            }

            List<EUR_TR_CrossCompliance__c> listOfCrossCompliance = [
                    Select Id,EUR_TR_RelatedAccount__r.Name,
                            EUR_TR_CR12JD__c,
                            EUR_TR_BFWJWRL__c,
                            EUR_TR_PassBells__c,
                            EUR_TR_WyboCross__c,
                            EUR_TR_AbsCross__c
                    FROM EUR_TR_CrossCompliance__c
                    WHERE EUR_TR_RelatedAccount__c = :account.Id
                    AND (EUR_TR_CR12JD__c = TRUE OR EUR_TR_BFWJWRL__c = TRUE OR EUR_TR_PassBells__c = TRUE OR EUR_TR_WyboCross__c = TRUE OR EUR_TR_AbsCross__c = TRUE)
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            serviceResponse.ExtensionData = listOfCrossCompliance;

        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }


}