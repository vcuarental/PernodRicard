public without sharing class EUR_CRM_POSM_CalloutHelper {
    // Label holding the end point URL 
    @TestVisible private static final String STR_ENDPOINT = Label.EUR_CRM_ZA_SO_Callout_Endpoint;
    private final Integer MAX_RETRIES = 3;
    private Integer no_of_retries = 0;

    //EUR_CRM_POSM_XmlWriter Instance
    EUR_CRM_POSM_XmlWriter writer = new EUR_CRM_POSM_XmlWriter();
    String strXmlBody;

    //Method to make Web Service Callout where
    //POSM and POSM Item information is being passed
    public void callService(Id posmOrderId){
    
        if(!String.isBlank(posmOrderId)){
            
            //Get the XML String
            strXmlBody = writer.generateXmlForPOSMOrder(posmOrderId);
            if(!String.isBlank(strXmlBody)){
                
                //Make an HTTP Callout
                HttpRequest request = new HttpRequest();
                request.setEndpoint(STR_ENDPOINT);
                request.setMethod('POST');
                // Set the Header for the HTTP request               
                request.setHeader('AS2-To', 'BRIDGE-ALL-DEV');
                request.setHeader('AS2-Version', '1.2');
                request.setHeader('EDIINT-Features', 'multiple-attachments');
                request.setHeader('Content-Description', 'body');
                request.setHeader('AS2-From', 'SFDC-DEV');
                request.setHeader('Message-ID', datetime.now().format('ddMMyyyySSDDD'));
                // Append the xml file to the body
                request.setBody(strXmlBody);

                System.debug(request);
                System.debug('Message-ID =: ' + request.getHeader('Message-ID'));
                System.debug(strXmlBody);

                // Http initialization
                Http httpInstance = new Http();
                HttpResponse response;
                EUR_CRM_POSM_Order__c order = [SELECT Id, EUR_CRM_Endpoint_Sync_Status__c, EUR_CRM_Endpoint_Response_Message__c FROM EUR_CRM_POSM_Order__c Where Id = :posmOrderId];
                // Request sending
                try{
                    // Retry many times as specified by MAX_RETRIES
                    while(no_of_retries < MAX_RETRIES){
                        // Send the http request
                        response = httpInstance.send(request);
                        System.debug('response: ' + response);
                        if(response.getStatusCode() == 200)
                            break;
                        no_of_retries++;
                    }
                    // Set the end point status according to response status
                    if(response.getStatusCode() == 200){
                       order.EUR_CRM_Endpoint_Sync_Status__c = 'Successful';
                    } else {
                        order.EUR_CRM_Endpoint_Sync_Status__c = 'Failed';
                    }         
                }
                catch(Exception ex){
                    System.debug(ex);
                    // failed to sync if exception occured
                    order.EUR_CRM_Endpoint_Sync_Status__c = 'Failed';
                }
                // Save the result of the response into the order object and update
                finally {
                    order.EUR_CRM_Endpoint_Response_Message__c = String.valueOf(response);
                    update order;
                }
            }
        }
    }
}