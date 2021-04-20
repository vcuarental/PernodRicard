//Testing objects:      ASI_eForm_Leave_Request__c
//Testing triggers:     ASI_eForm_KR_LR_beforeInsert, ASI_eForm_KR_LR_beforeUpdate
//Testing calsses:      ASI_eForm_KR_Leave_PDFController, ASI_eForm_KR_Leave_Header_Controller, ASI_eForm_KR_LR_CheckLeave, ASI_eForm_KR_helpForApproval, ASI_eForm_KR_AutoFillIn
//Included pages:       ASI_eForm_KR_Leave_PDF, ASI_eForm_KR_Leave_Detail
//Included components:  ASI_eForm_KR_Leave_PDF, ASI_eForm_KR_MassCreateandUpdate
@isTest
public class ASI_eForm_KR_LR_Test
{
    //common data
    //create and insert some temp MDM info
    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
        ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
        ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
        ASI_eForm_Employee_Work_Email__c='123.345@email.com');
    
    //temp user
    Private static User tempU = [select id from user where id = :userInfo.getUserId()];
    
    static testMethod void Test_Leave_PDFController()
    {        
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        //create and insert some custom setting for testing
        List<ASI_eForm_KR_LR__c> settings = new List<ASI_eForm_KR_LR__c>();
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='육아휴직 Child-care unpaid leave of Absence',name ='Child-care unpaid leave of Absence',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='기타휴직 Other leave of Absence',name ='Other leave of Absence',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='병가휴직 Sick Leave of Absence',name ='Sick Leave of Absence',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='병가 휴가 Sick Leave',name ='Sick Leave',ASI_eForm_KR_LR_LeavePerYorM__c=7));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='동원훈련 Maternity Leave',name ='Maternity Leave',ASI_eForm_KR_LR_LeavePerYorM__c=2));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='보건휴가 Menstruation Leave',name ='Menstruation Leave',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='특별휴가 Special Leave',name ='Special Leave',ASI_eForm_KR_LR_LeavePerYorM__c=4));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='결혼기념일 휴가 Wedding Anniversary',name ='Wedding Anniversary',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        insert settings;
        
        insert tempMDM;
        
        ASI_eForm_KR_Leave_EE__c tempEE = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDM.id,ASI_eform_Year__c='2015', ASI_eForm_Total_Special_Leave__c = 4,
                                                                       ASI_eForm_Leave_Entitlement__c = 30, ASI_eForm_Used_Annual_Leave__c = 0, ASI_eForm_Used_Special_Leave__c = 0);
        insert tempEE;
               
        //create and insert a temp leave request form
        ASI_eForm_Leave_Request__c tempLeave = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
        ASI_eForm_Status__c='Draft', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=100);  
        insert tempLeave;
        
        //create and insert a temp leave request deails form
        list<ASI_eForm_Leave_Request_Line_Item__c> tempLeaveDs = new list<ASI_eForm_Leave_Request_Line_Item__c>();
        tempLeaveDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(1), ASI_eForm_Leave_Type__c='휴직(병가휴직,육아휴직,기타휴직) Leave of Absence', 
        ASI_eForm_No_of_Days__c=3));
        tempLeaveDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(8), ASI_eForm_Leave_Type__c='병가 휴가 Sick Leave', 
        ASI_eForm_No_of_Days__c=8, ASI_eForm_Reason__c='none'));
        tempLeaveDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(3), ASI_eForm_Leave_Type__c='동원훈련 Maternity Leave', 
        ASI_eForm_No_of_Days__c=3));
        tempLeaveDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(1), ASI_eForm_Leave_Type__c='연차 휴가 Annual Leave Full', 
        ASI_eForm_No_of_Days__c=1));
        tempLeaveDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(5), ASI_eForm_Leave_Type__c='특별휴가 Special Leave', 
        ASI_eForm_No_of_Days__c=5));
        tempLeaveDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='결혼기념일 휴가 Wedding Anniversary', 
        ASI_eForm_No_of_Days__c=2));
        tempLeaveDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='보건휴가 Menstruation Leave', 
        ASI_eForm_No_of_Days__c=2));
        insert tempLeaveDs;
        update tempLeaveDs;
        
        //---------------------------------Test 2 Data-------------------------------//
        ASI_eForm_HR_MDM__c tempMDMLe1 = new ASI_eForm_HR_MDM__c(name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222',
        ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none');
        insert tempMDMLe1;
        
        ASI_eForm_Leave_Request__c tempLeave1 = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
        ASI_eForm_Status__c='Draft', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=100, 
        ASI_eForm_Requester_Record__c=tempMDMLe1.id);  
        insert tempLeave1;
        //---------------------------------Test 2 Data-------------------------------//
        //---------------------------------Test 3 Data-------------------------------//
        ASI_eForm_HR_MDM__c tempMDMLe2 = new ASI_eForm_HR_MDM__c(name='12345678', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222',
        ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
         ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='F');
        insert tempMDMLe2;
        
        ASI_eForm_KR_Leave_EE__c tempEE1 = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDMLe2.id,ASI_eform_Year__c='2018', ASI_eForm_Total_Special_Leave__c = 4,
                                                                       ASI_eForm_Leave_Entitlement__c = 30, ASI_eForm_Used_Annual_Leave__c = 0, ASI_eForm_Used_Special_Leave__c = 0);
        insert tempEE1;
        
        Test.startTest();
        ASI_eForm_Leave_Request__c tempLeave2 = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
        ASI_eForm_Status__c='Draft', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=100, 
        ASI_eForm_Requester_Record__c=tempMDMLe2.id);  
        insert tempLeave2;
        
        ASI_eForm_Leave_Request_Line_Item__c tempLeaveD2 =new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave2.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='보건휴가 Menstruation Leave', 
        ASI_eForm_No_of_Days__c=2);
        insert tempLeaveD2;
        //---------------------------------Test 3 Data-------------------------------//
        //---------------------------------Test 4 Data-------------------------------//
        ASI_eForm_Leave_Request__c tempLeave3 = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
        ASI_eForm_Status__c='Approved', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=8);  
        insert tempLeave3;
        ASI_eForm_Leave_Request_Line_Item__c tempLeaveD3 =new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave3.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='연차 휴가 Annual Leave Full', 
        ASI_eForm_No_of_Days__c=2);
        insert tempLeaveD3;
        ASI_eForm_Leave_Request_Line_Item__c tempLeaveD3a =new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave3.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='연차 휴가 Annual Leave Full', 
        ASI_eForm_No_of_Days__c=2);
        insert tempLeaveD3a;
        ASI_eForm_Leave_Request_Line_Item__c tempLeaveD4 =new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave3.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='특별휴가 Special Leave', 
        ASI_eForm_No_of_Days__c=2);
        insert tempLeaveD4;
        ASI_eForm_Leave_Request_Line_Item__c tempLeaveD4a =new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave3.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='특별휴가 Special Leave', 
        ASI_eForm_No_of_Days__c=2);
        insert tempLeaveD4a;
        //---------------------------------Test 4 Data-------------------------------//
        
        //set the temp PDF page
        Test.setCurrentPage(Page.ASI_eForm_KR_Leave_PDF);
        //set the temp Leave for the current page
        Apexpages.currentPage().getParameters().put('id', tempLeave.id);
        //create the temp Leave object
        ASI_eForm_Leave_Request__c Leave_list = new ASI_eForm_Leave_Request__c();
        //get the temp Leave controller
        Apexpages.standardController sc = new apexpages.standardController(tempLeave);
        //for test the constructor
        ASI_eForm_KR_Leave_PDFController cxnull = new ASI_eForm_KR_Leave_PDFController();
        //for test the constructor
        ASI_eForm_KR_Leave_PDFController cx = new ASI_eForm_KR_Leave_PDFController(sc);
        //for trigger "currentHeaderID" statement
        cx.currentHeaderID = tempLeave.id;
        //for trigger the getHeader method
        cx.getHeader();
        //for trigger the getDetails method
        cx.getDetails();
        cx.getPrintObj();
        //-----------------------------------------Test 2---------------------------------//
        Test.setCurrentPage(Page.ASI_eForm_KR_Leave_PDF);
        Apexpages.currentPage().getParameters().put('id', tempLeave1.id);
        ASI_eForm_Leave_Request__c Leave_list1 = new ASI_eForm_Leave_Request__c();
        Apexpages.standardController sc1 = new apexpages.standardController(Leave_list1);
        ASI_eForm_KR_Leave_PDFController cx1 = new ASI_eForm_KR_Leave_PDFController(sc1);
        //-----------------------------------------Test 2---------------------------------//
        //-----------------------------------------Test 3---------------------------------//
        Test.setCurrentPage(Page.ASI_eForm_KR_Leave_PDF);
        Apexpages.currentPage().getParameters().put('id', tempLeave2.id);
        ASI_eForm_Leave_Request__c Leave_list2 = new ASI_eForm_Leave_Request__c();
        Apexpages.standardController sc2 = new apexpages.standardController(Leave_list2);
        ASI_eForm_KR_Leave_PDFController cx2 = new ASI_eForm_KR_Leave_PDFController(sc2);
        //for trigger "currentHeaderID" statement
        cx2.currentHeaderID = tempLeave2.id;
        //for trigger the getHeader method
        cx2.getHeader();
        //for trigger the getDetails method
        cx2.getDetails();
        cx2.getPrintObj();
        //-----------------------------------------Test 3---------------------------------//
        
        Test.stopTest();
    }//end ASI_eForm_KR_Leave_PDFController*/
    
    //Test for ASI_eForm_KR_Leave_Header_Controller
    static testMethod void Test_Leave_HeaderController()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        //create and insert some custom setting for testing
        List<ASI_eForm_KR_LR__c> settings = new List<ASI_eForm_KR_LR__c>();
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='육아휴직 Child-care unpaid leave of Absence',name ='Child-care unpaid leave of Absence',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='기타휴직 Other leave of Absence',name ='Other leave of Absence',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='병가휴직 Sick Leave of Absence',name ='Sick Leave of Absence',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='병가 휴가 Sick Leave',name ='Sick Leave',ASI_eForm_KR_LR_LeavePerYorM__c=7));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='동원훈련 Maternity Leave',name ='Maternity Leave',ASI_eForm_KR_LR_LeavePerYorM__c=2));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='보건휴가 Menstruation Leave',name ='Menstruation Leave',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='특별휴가 Special Leave',name ='Special Leave',ASI_eForm_KR_LR_LeavePerYorM__c=4));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='결혼기념일 휴가 Wedding Anniversary',name ='Wedding Anniversary',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        insert settings;
        
        insert tempMDM;
        
        ASI_eForm_KR_Leave_EE__c tempEE = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDM.id,ASI_eform_Year__c='2015', ASI_eForm_Total_Special_Leave__c = 4);
        insert tempEE;
               
        //create and insert a temp leave request form
        ASI_eForm_Leave_Request__c tempLeave = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
        ASI_eForm_Status__c='Draft', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, 
        Sum_of_Annual_Leave__c=100);  
        insert tempLeave;
        
        //create and insert a temp leave request deails form
        ASI_eForm_Leave_Request_Line_Item__c tempLeaveD = new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLeave.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(7), ASI_eForm_Leave_Type__c='특별휴가 Special Leave', ASI_eForm_No_of_Days__c=7, ASI_eForm_Reason__c='none');  
        insert tempLeaveD;
        
        //set the temp PDF page
        Test.setCurrentPage(Page.ASI_eForm_KR_Leave_Detail);
        //set the temp Leave for the current page
        Apexpages.currentPage().getParameters().put('id', tempLeave.id);
        //create the temp Leave object
        ASI_eForm_Leave_Request__c Leave_list = new ASI_eForm_Leave_Request__c();
        //get the temp Leave controller
        Apexpages.standardController sc = new apexpages.standardController(Leave_list);
        //for test the constructor
        ASI_eForm_KR_Leave_Header_Controller cx = new ASI_eForm_KR_Leave_Header_Controller(sc);
        
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
        sObject tempSO = new ASI_eForm_Leave_Request__c();
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
        
        delete tempLeaveD;
        delete tempLeave;
        Test.stopTest();
    }//end Test_Leave_HeaderController*/
}