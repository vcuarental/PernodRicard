/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_SIRAttachController       
 * Test Class:  ASI_CTY_CN_Vendor_SIRAttaControllerTest
 * Description: SIR Approval Email Template Attachment List Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-09-13       Baymax                  Get SIR Document
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_SIRAttachController{
    public String parentID {set;get;}

    public ASI_CTY_CN_Vendor_SIRAttachController() {}

    public ASI_CTY_CN_Vendor_SIRAttachController(String sirID) {
        parentID = sirID;
    }
    
    /*
    * Method Name: getSirs
    * Description: Get SIR Upload Image Accoding To SIR Id
    * Return Type: List<SIRAttachment>
    * Parameter  :  
    */
    public List<SIRAttachment> getSirs(){
        System.debug(LoggingLevel.INFO, '*** parentID: ' + parentID);
        List<SIRAttachment> sirs = new list<SIRAttachment>();
        Id itemGroupId;
        if(parentID != null){
            ASI_MFM_Stock_In_Request__c sir = [SELECT Id, ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_Item_Group__r.Id 
                FROM ASI_MFM_Stock_In_Request__c WHERE Id =: parentID];
            itemGroupId = sir.ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_Item_Group__r.Id;
            String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
            List<ASI_CRM_Product_Warehouse_Photo__c> tmpAttachment = [SELECT Id, ASI_CRM_Photo_Version__c, ASI_File_Name__c FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                        WHERE ASI_CRM_Item_Group__c = : itemGroupId
                                                                        AND ASI_CRM_Photo_Version__c != NULL
                                                                        AND RecordTypeId = : reocrdTypeId
                                                                        ORDER BY ASI_CRM_Photo_Version__c DESC LIMIT 1];
            if (tmpAttachment != null && tmpAttachment.size() > 0) {
                Id contentDocumentId;
                String result;
                set<String> documentIdSet = new set<String>();
                ContentDocumentLink link = [SELECT Id, LinkedEntityId, ContentDocumentId
                   FROM ContentDocumentLink
                   WHERE LinkedEntityId =: tmpAttachment[0].Id LIMIT 1];
                if (link != null) {
                    contentDocumentId = link.ContentDocumentId;
                    ContentVersion cv = [SELECT Id, ContentDocumentId, FileExtension, VersionData
                        FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId =:contentDocumentId];
                    String content = EncodingUtil.base64Encode(cv.VersionData);
                    result = 'data:image/' + cv.FileExtension + ';base64,' + content;
                    sirs.add(new SIRAttachment(tmpAttachment[0].ASI_File_Name__c, result));
                }  
            }
        }
        System.debug(LoggingLevel.INFO, '*** SIRAttachment: ' + sirs);
        return sirs;
    }
  
    public class SIRAttachment{
        public String fileName {set;get;}
        public String content {set;get;}
        public SIRAttachment(String f, String contentBody){
            fileName = f;
            content = contentBody;
        }
    }
}