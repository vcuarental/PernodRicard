@isTest
public class ASI_MFM_PO_Attchment_ZipControllerTest {

    static testMethod void testMethod1() {
        
        Test.StartTest();
        
        ASI_OCR_Archived_Document__c doc = new ASI_OCR_Archived_Document__c(ASI_OCR_PO_Number__c='poN',ASI_OCR_SO_Number__c='soN', recordTypeId = Global_RecordTypeCache.getRtId('ASI_OCR_Archived_Document__cASI_OCR_HK_Archived_Document'));
        insert doc;
        
        Attachment att=new Attachment();    
        att.Name='Unit Test Attachment';
        att.body=Blob.valueOf('Unit Test Attachment Body');
        att.parentId=doc.id;
        insert att;
              
        ASI_MFM_PO_Attchment_ZipController testZip = new ASI_MFM_PO_Attchment_ZipController();
        testZip.poName='poN';
        testZip.soName='soN';
        testZip.searchRecord();
        
        List<Attachment> listAtt=testZip.getPoFileList() ;
        listAtt=testZip.getSoFileList() ;
        
        ASI_MFM_PO_Attchment_ZipController.getAttachment(att.Id);
        
        Test.StopTest();
    }

}