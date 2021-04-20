global class ASI_CRM_JP_SOACallOutMock implements WebServiceMock {
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
       ASI_CRM_JP_SO_Creation.processResponse_element response_x = new ASI_CRM_JP_SO_Creation.processResponse_element();
               
       response.put('response_x', response_x ); 
   }

}