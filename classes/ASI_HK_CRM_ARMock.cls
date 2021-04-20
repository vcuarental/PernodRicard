@isTest
global with sharing class ASI_HK_CRM_ARMock implements WebServiceMock{

    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            
        if (endpoint.contains('/CustomBssvManager')){ 
            if (request instanceof ASI_HK_CRM_ARCreditWSTypes.N56ARCR_Input) {
                ASI_HK_CRM_ARCreditWSTypes.N56ARCR_Output responseObj = new ASI_HK_CRM_ARCreditWSTypes.N56ARCR_Output();
                responseObj.currencyCodeFrom = 'HKD';
                responseObj.amountUserDefined = 1114739.6;  // Total exposure on SalesOrder
                responseObj.addressNumber = 1300347;
                //responseObj.addressNumberParent = addressNumberParent;
                responseObj.amountAgingCategories4 = 253140.4;
                //responseObj.asofDate = asofDate;
                responseObj.amountAgingCategories8 = 513496.4;
                responseObj.paymentTermsCode = 'M60';
                responseObj.company = '32104';
                responseObj.amountAgingCategories3 = 348102.8;
                responseObj.amountCreditLimit = 1352000;
                responseObj.amountAgingCategories1 = 0;
                responseObj.creditCheckLevel = 'P';
                responseObj.descriptionPaymentTerms = '60 Days (ME)';
                responseObj.amountAgingCategories2 = 0;
                responseObj.amountDue = 1114739.6; 
                
                response.put('response_x', responseObj);
            }       
        }   
    }
    
}