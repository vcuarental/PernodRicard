@isTest
public with sharing class ASI_MFM_WebServiceMock implements WebServiceMock {
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, 
    	String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        ASI_MFM_DWInterface.WSResult resp = new ASI_MFM_DWInterface.WSResult();
        resp.Succeed = 1;
        resp.Message = 'Mock response';    		
        response.put('response_x', resp); 
    }
}