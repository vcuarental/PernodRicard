@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_UploadMSPCtl
****************************************/
public class ASI_CRM_MY_UploadMSPCtl_TEST{
    static testMethod void ASI_CRM_MY_UploadMSPCtl_TEST() {
        ASI_CRM_MY_UploadMSPCtl ctl = new ASI_CRM_MY_UploadMSPCtl();
        
        ctl.ReadFile();
        ctl.getuploadedsite();
        
        String myString = 'SKU Code,Effective Date,Price,Customer Category Code2\r\n';
        myString += 'REG302,01/07/2011,3000, LP\r\n';
        Blob b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();
        
    }
}