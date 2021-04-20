@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_UploadIGCCtl
****************************************/
public class ASI_CRM_MY_UploadIGCCtl_TEST{
    static testMethod void ASI_CRM_MY_UploadIGCCtl_TEST() {
        ASI_CRM_MY_UploadIGCCtl ctl = new ASI_CRM_MY_UploadIGCCtl();
        
        ctl.ReadFile();
        ctl.getuploadedsite();
        
        String myString = 'SKU Code,Effective Date,IGC\r\n';
        myString += 'ABE300,30/11/2019,3000\r\n';
        Blob b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();
        
    }
}