@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MO_WSOfftakeUploadCtl
****************************************/
public class ASI_CRM_MO_WSOfftakeUploadCtl_TEST{
    static testMethod void ASI_CRM_MO_WSOfftakeUploadCtl_TEST() {
        ASI_CRM_MO_TestClassHelper.createRunningNumbers();
        Account acc = 
            new Account(
                Name = 'SEAPOWERX22',
                ASI_HK_CRM_Local_Channel__c = 'local_Channel',
                ASI_HK_CRM_District__c = 'Taipa 氹仔',
                ASI_HK_CRM_Location__c = '1#_MACDPLOC',
                ASI_HK_CRM_Channel__c = 'On Trade',
                ASI_KOR_Customer_Code__c = '5500002',
                RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet')
            );
        insert acc;
        
        ASI_CRM_MO_WSOfftakeUploadCtl ctl = new ASI_CRM_MO_WSOfftakeUploadCtl();
        
        ctl.ReadFile();
        ctl.getuploadedsite();
        
        String myString = 'Seapower code,Outlet code,Outlet name,Sell out date,PR SKU Code,Seapower SKU Code,SKU Description,Qty in bt\r\n';
        myString += '5500002,ONMC0004,,9/9/2015,LL1309,,,300';
        Blob b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();
        
    }
}