@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_UploadDepletionCtl
****************************************/
public class ASI_CRM_MY_UploadDepletionCtl_TEST{
    static testMethod void ASI_CRM_MY_UploadDepletionCtl_TEST() {
        ASI_CRM_MY_UploadDepletionCtl ctl = new ASI_CRM_MY_UploadDepletionCtl();
        
        ctl.ReadFile();
        ctl.getuploadedsite();
        
        String myString = 'Wholesaler,Customer,SKU,Shipment Date,Depletion Volume\r\n';
        myString += '504861,503997,ABA100,2/1/2014,400\r\n';
        Blob b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();
        
    }
}