/*********************************************************************************
 * Name: ASI_TnE_EmailAttachmentController
 * Description: Controller class for ASI T&E Email to show the links of T&E's attachments
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/1/2017        William Keung           Created          
*/

public with sharing class ASI_TnE_EmailAttachmentController {
    public String currentHeaderId {get;set;}
    public Map<String,String> urlMap;
        
    public Map<String, String> getUrlMap() {         
        if(currentHeaderId != null) {
            List<Attachment> attach = [SELECT id,name FROM Attachment WHERE Parentid=:currentHeaderId];
            
            if(attach.size() > 0) {
                urlMap = new Map<String, String>();
            }
            
            for(Attachment atta:attach) {
                String urls = URL.getSalesforceBaseURL().toExternalForm() + '/servlet/servlet.FileDownload?file=' + atta.Id;
                urlMap.put(urls,atta.Name);
            }
        }
        
        return urlMap;
    }
}