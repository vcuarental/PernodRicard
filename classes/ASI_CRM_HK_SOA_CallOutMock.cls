global class ASI_CRM_HK_SOA_CallOutMock implements WebServiceMock {
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
        // start - specify the response you want to send
        ASI_CRM_HK_SOA_SOIntegration.processResponse_element response_x = new ASI_CRM_HK_SOA_SOIntegration.processResponse_element();
        
        // end
        response.put('response_x', response_x); 
   }
}