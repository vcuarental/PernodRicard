@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_UploadStockinTradeCtl
****************************************/
public class ASI_CRM_MY_UploadStockinTradeCtl_TEST{
    static testMethod void ASI_CRM_MY_UploadStockinTradeCtl_TEST() {
        
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        
        customer1.ASI_CRM_MY_CustomerCode__c = '500005';
        update customer1;
        
        ASI_CRM_MY_UploadStockinTradeCtl ctl = new ASI_CRM_MY_UploadStockinTradeCtl();
        
        ctl.ReadFile();
        ctl.getuploadedsite();
        
        String myString = 'Wholesaler,Sell out date,PR SKU Code,SKU Description,Beginning Stock,Total Offtake (Final)\r\n';
        myString += '500005,15/03/2015,AB1100,,20,100\r\n';
        myString += '500005,15/03/2015,AB1300,,20,100\r\n';
        Blob b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();

        ctl.contentFile = b;
        ctl.ReadFile();
        
        myString = 'Wholesaler,Sell out date,PR SKU Code,SKU Description,Beginning Stock,Total Offtake (Final)\n';
        b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();
    }
}