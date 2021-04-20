//Testing objects:      ASI_eForm_Home_Appliance__c
//Testing triggers:     ASI_eForm_KR_HA_beforeInsert
//Testing calsses:      ASI_eForm_KR_HA_PDFController, ASI_eForm_KR_HA_Header_Controller, ASI_eForm_KR_AutoFillIn
//Included pages:       ASI_eForm_KR_HA_PDF, ASI_eForm_KR_HA_Detail
//Included components:  ASI_eForm_KR_HA_pdf, ASI_eForm_KR_MassCreateandUpdate
@isTest
private class ASI_eForm_KR_HA_Test
{
    //common data
    //create and insert some temp MDM info
    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
        ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
        ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
        ASI_eForm_Employee_Work_Email__c='123.345@email.com');
    
    //create and insert a temp home appliance form
    private static ASI_eForm_Home_Appliance__c tempHA = new ASI_eForm_Home_Appliance__c(ASI_eForm_Currency__c='KRW', ASI_eForm_Reason_for_Request__c='none', 
        ASI_eForm_Status__c='Draft');
    
    //temp user
    Private static User tempU = [select id from user where id = :userInfo.getUserId()];
    
    //Test for ASI_eForm_KR_HA_PDFController
    static testMethod void Test_HA_PDFController()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        insert tempMDM;
        
        insert tempHA;
        
        tempHA.ASI_eForm_Reason_for_Request__c = 'none1';
        update tempHA;
        
        //create and insert a temp home appliance deails form
        ASI_eForm_HA_Detail__c tempHAD = new ASI_eForm_HA_Detail__c(ASI_eForm_Home_Appliance__c=tempHA.id, ASI_eForm_Item_Name__c='none', ASI_eForm_Model_No__c='none', 
            ASI_eForm_Price__c=100000);
        insert tempHAD;
        
        tempHAD.ASI_eForm_Model_No__c = 'none1';
        update tempHAD;
        
        //set the temp PDF page
        Test.setCurrentPage(Page.ASI_eForm_KR_HA_PDF);
        //set the temp HA for the current page
        Apexpages.currentPage().getParameters().put('id', tempHA.id);
        //create the temp HA object
        ASI_eForm_Home_Appliance__c HA = new ASI_eForm_Home_Appliance__c();
        //get the temp HA controller
        Apexpages.standardController sc = new apexpages.standardController(HA);
        //for test the constructor
        ASI_eForm_KR_HA_PDFController cxnull = new ASI_eForm_KR_HA_PDFController();
        //for test the constructor
        ASI_eForm_KR_HA_PDFController cx = new ASI_eForm_KR_HA_PDFController(sc);
        //for trigger "currentHeaderID" statement
        cx.currentHeaderID = tempHA.id;
        //for trigger the getHeader method
        cx.getHeader();
        //for trigger the getDetails method
        cx.getDetails();
        
        Test.stopTest();
    }//end Test_HA_PDFController*/
    
    //Test for ASI_eForm_KR_HA_Header_Controller
    static testMethod void Test_HA_HeaderController()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        insert tempMDM;
        
        insert tempHA;
        
        //create and insert a temp home appliance deails form
        ASI_eForm_HA_Detail__c tempHAD = new ASI_eForm_HA_Detail__c(ASI_eForm_Home_Appliance__c=tempHA.id, ASI_eForm_Item_Name__c='none', ASI_eForm_Model_No__c='none', 
            ASI_eForm_Price__c=100000);
        insert tempHAD;
        
        //set the temp PDF page
        Test.setCurrentPage(Page.ASI_eForm_KR_HA_Detail);
        //set the temp HA for the current page
        Apexpages.currentPage().getParameters().put('id', tempHA.id);
        //create the temp HA object
        ASI_eForm_Home_Appliance__c HA = new ASI_eForm_Home_Appliance__c();
        //get the temp HA controller
        Apexpages.StandardController sc = new Apexpages.StandardController(HA);
        //for test the constructor
        ASI_eForm_KR_HA_Header_Controller cx = new ASI_eForm_KR_HA_Header_Controller(sc);

        //just for testing
        cx.thisController = cx;
        cx.dynamicAttributeFieldsPixels = 'trigger';
        //for trigger the method
        String language = cx.getUserLanguage();
        //for trigger the method
        List<ASI_TnE_KR_MassCreateAndUpdateController.PageBlockActionBtn> tempObj1 = cx.mcau_initPageBlockActionButtonList();
        //create temp controller
        ASI_TnE_KR_MassCreateAndUpdateController tempCon1 = new ASI_TnE_KR_MassCreateAndUpdateController();
        //create temp dat for testing
        String tempKey1 = 'A';
        sObject tempSO = new ASI_eForm_Home_Appliance__c();
        //for trigger the method
        PageReference tempObj2 = cx.mcau_triggerPageBlockAction(tempCon1, tempKey1);
        cx.mcau_triggerActionForSObject(tempCon1,tempKey1,tempSO);
        //create temp dat for testing
        String tempKey2 = 'DEFAULT';
        //for trigger the method
        ASI_TnE_ComponentInterface tempObj4 = cx.getComponentController();
        ASI_TnE_ComponentInterface tempObj5 = cx.getComponentController(tempKey2);
        cx.setComponentController(tempObj4);
        cx.setComponentController(tempKey2,tempObj4);
        
        Test.stopTest();
    }//end Test_HA_HeaderController*/
    
    
}