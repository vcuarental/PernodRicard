//Testing objects:		ASI_eForm_Recruitment__c
//Testing triggers:		ASI_eForm_KR_RR_beforeInsert
//Testing calsses:		ASI_eForm_KR_RR_PDFController, ASI_eForm_KR_AutoFillIn
//Included pages:		ASI_eForm_KR_RR_PDF
//Included components:	ASI_eForm_KR_RR_PDF
@isTest
private class ASI_eForm_KR_RR_Test
{
    //common data
    //create and insert some temp MDM info
    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
    	ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
    	 ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
        ASI_eForm_Employee_Work_Email__c='123.345@email.com');
    
    //create and insert a temp recruitment form
    private static ASI_eForm_Recruitment__c tempRR = new ASI_eForm_Recruitment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Recruitment__cASI_eForm_KR_Recruitment'), 
        ASI_eForm_Employee_Group__c='Temporary', ASI_eForm_Job_Type__c='Non-Sales', ASI_eForm_Employment_Status__c='Part-Time', 
        ASI_eForm_School_Level__c ='High School', ASI_eForm_Major__c='testText', ASI_eForm_Expected_Start_Date__c=Date.today().addDays(3), 
        ASI_eForm_Budget_Status__c= True , ASI_eForm_Budget_Status_reason__c='none', ASI_eForm_Report_Line__c=Userinfo.getUserId(),
        ASI_eForm_Key_Competencies__c='none', ASI_eForm_Other_Reason__c='none', ASI_eForm_Period_of_Employment_From__c=Date.today().addDays(7),
        ASI_eForm_Period_of_Employment_To__c=Date.today().addYears(1), ASI_eForm_new_Position__c='none', ASI_eForm_Reason__c='none', 
        ASI_eForm_Perferred__c='none', ASI_eForm_YOS__c='<1', ASI_eForm_Work_Hour__c='1', ASI_eForm_Work_Period_From__c='7:00 AM', 
		ASI_eForm_Work_Period_To__c='7:30 PM', ASI_eForm_Dept_new__c='Finance', ASI_eForm_Department__c='Management', ASI_eForm_Status__c = 'Draft');
    
    //temp user
    Private static User tempU = [select id from user where id = :userInfo.getUserId()];
    
    
    
    
    //Test for ASI_eForm_KR_RR_PDFController
    static testMethod void Test_RR_PDFController()
    {
        Test.startTest();
        
        //insert tempU;
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        insert tempMDM;
        
        insert tempRR;
        
        //set the temp PDF page
        Test.setCurrentPage(Page.ASI_eForm_KR_RR_PDF);
        //set the temp RR for the current page
        Apexpages.currentPage().getParameters().put('id', tempRR.id);
        //create the temp RR object
        ASI_eForm_Recruitment__c RR = new ASI_eForm_Recruitment__c();
        //get the temp RR controller
        Apexpages.standardController sc = new apexpages.standardController(RR);
        //for test the constructor
        ASI_eForm_KR_RR_PDFController cxnull = new ASI_eForm_KR_RR_PDFController();
        //for test the constructor
        ASI_eForm_KR_RR_PDFController cx = new ASI_eForm_KR_RR_PDFController(sc);
        //for trigger "currentHeaderID" statement
        cx.currentHeaderID = tempRR.id;
        //for trigger the getHeader method
        cx.getHeader();
        
        Test.stopTest();
    }//end Test_RR_PDFController*/
}