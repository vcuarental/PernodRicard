/*********************************************************************************
 * Name:ASI_CRM_JP_CallPlanPdfAttachController
 * Description: Future Call for Attach Pdf in Call Plan for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 1/12/2014       Laputa: Hank          Created
*********************************************************************************/
global class ASI_CRM_JP_CallPlanPdfAttachController{
 
    @Future(callout=true)
    public static void addPDFAttach(string sessionId, list<id> planIdList){
       HttpRequest req = new HttpRequest();
       req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/apexrest/addPDFtoRecord/');
       req.setMethod('POST');
       req.setBody('{"planIdList":'+JSON.serialize(planIdList)+'}');
       req.setHeader('Authorization', 'Bearer '+ sessionId);
       req.setHeader('Content-Type', 'application/json');
       Http http = new Http();
       if(!test.isRunningTest()){
           HTTPResponse res = http.send(req);
       }
    }
}