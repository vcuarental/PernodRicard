@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_UploadWSTargetCtl
****************************************/
public class ASI_CRM_MY_UploadWSTargetCtl_TEST{
    static testMethod void ASI_CRM_MY_UploadWSTargetCtl_TEST() {
        ASI_CRM_MY_UploadWSTargetCtl ctl = new ASI_CRM_MY_UploadWSTargetCtl();
        
        ctl.ReadFile();
        ctl.getuploadedsite();
        
        String myString = 'WS Code,SKU Code,Target Date,JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC\r\n';
        myString += '504861,ABA100,2014,1,2,3,4,5,6,7,8,9,10,11,12\r\n';
        Blob b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();
        
    }
}