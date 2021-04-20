@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_UploadSegmentationCtl
****************************************/
public class ASI_CRM_MY_Upload_TEST{
 
    static testMethod void Upload_Segmentation_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        date myDate = date.today();
        
        integer y = myDate.year();
        integer m = myDate.month();
        
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        
        ApexPages.StandardController standardCtl = new ApexPages.StandardController(customer1);
        ApexPages.currentpage().getparameters().put('id', customer1.id);
        ASI_CRM_MY_UploadSegmentationCtl ctl = new ASI_CRM_MY_UploadSegmentationCtl(standardCtl);
        
        ctl.ReadFile();
        ctl.getuploadedsite();
        
        String myString = 'ID,Segmentation Channel,Grade,Rank,Outlet strategy ,Outlet Image,Volume,Contracted Brand,GMA,Counterfeit,Market share ,Market Responsibility\r\n';
        myString += '500003,KTV,,,Testing,Mainstream,,PRM,YES,YES,Low,\r\n';
        Blob b = Blob.valueof(myString); 
        
        ctl.contentFile = b;
        ctl.ReadFile();
    }
}