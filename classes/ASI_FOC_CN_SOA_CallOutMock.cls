global class ASI_FOC_CN_SOA_CallOutMock implements WebServiceMock {
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
        ASI_FOC_CN_SOA_FOCIntegrationProcess.processResponse_element response_x = new ASI_FOC_CN_SOA_FOCIntegrationProcess.processResponse_element();
        
        // end
        response.put('response_x', response_x); 
   }
}