//Testing objects:		ASI_eForm_CC_Request__c
//Testing triggers:		ASI_eForm_KR_CC_beforeInsert, ASI_eForm_KR_CC_beforeUpdate
//Testing calsses:		ASI_eForm_KR_CC_PDFController, ASI_eForm_KR_AutoFillIn
//Included pages:		ASI_eForm_KR_CC_PDF
//Included components:	ASI_eForm_KR_CC_PDF, ASI_eForm_KR_MassCreateandUpdate
@isTest
public class ASI_eForm_KR_CC_Test
{
    //create and insert some temp MDM info
    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
    	ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
    	 ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
        ASI_eForm_Employee_Work_Email__c='123.345@email.com');
    
    //temp user
    Private static User tempU = [select id from user where id = :userInfo.getUserId()];
    
    //Test for ASI_eForm_KR_CC_PDFController
    static testMethod void Test_CC_PDFController()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;

        insert tempMDM;
               
        //create and insert a temp CC form
        ASI_eForm_CC_Request__c tempCC = new ASI_eForm_CC_Request__c(ASI_eForm_Rice_Wreath__c=True, ASI_eForm_Currency__c='KRW', ASI_eForm_Time__c=Datetime.now(), 
        ASI_eForm_Replacement__c='100000원', ASI_eForm_Summary_Date_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(3), 
        ASI_eForm_Leave_Sub_Type__c='본인 형제/자매 결혼 ,300000원+1일', ASI_eForm_Leave_Type__c='Congratulatory Leave', ASI_eForm_Mobile_Phone__c='82-10-3774-1207', 
        ASI_eForm_Days__c=2.0, ASI_eForm_Payment__c=100000, ASI_eForm_Place__c='none', ASI_eForm_Status__c='Draft', 
        ASI_eForm_Amount__c=200000, ASI_eForm_Support_Type__c='Leave+Money', ASI_eForm_Telephone_No__c='82-10-3774-1207');
        insert tempCC;
        
        
        ASI_eForm_HR_MDM__c tempMDMCC1 = new ASI_eForm_HR_MDM__c(ASI_eForm_MDM_Department__c='tempHR', ASI_eForm_Employee_Company_Code__c = '222',
        ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none');
        insert tempMDMCC1;
        
        ASI_eForm_CC_Request__c tempCC1 = new ASI_eForm_CC_Request__c(ASI_eForm_Rice_Wreath__c=True, ASI_eForm_Currency__c='KRW', ASI_eForm_Time__c=Datetime.now(), 
        ASI_eForm_Replacement__c='화환', ASI_eForm_Summary_Date_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(3), 
        ASI_eForm_Leave_Sub_Type__c='자녀결혼 (1일)', ASI_eForm_Leave_Type__c='Condolatory Leave', ASI_eForm_Mobile_Phone__c='82-10-3774-1207', 
        ASI_eForm_Days__c=2.0, ASI_eForm_Payment__c=100000, ASI_eForm_Place__c='none', ASI_eForm_Status__c='Draft', ASI_eForm_Requester_Record__c=tempMDMCC1.id, 
        ASI_eForm_Amount__c=200000, ASI_eForm_Support_Type__c='Leave', ASI_eForm_Telephone_No__c='82-10-3774-1207');
        insert tempCC1;
        
        //set the temp PDF page
        Test.setCurrentPage(Page.ASI_eForm_KR_CC_PDF);
        //set the temp CC for the current page
        Apexpages.currentPage().getParameters().put('id', tempCC.id);
        //create the temp CC object
        //list<ASI_eForm_CC_Request__c> CC_list = new list<ASI_eForm_CC_Request__c>();
        ASI_eForm_CC_Request__c CC_list = new ASI_eForm_CC_Request__c();
        //get the temp CC controller
        //Apexpages.standardSetController sc = new apexpages.standardSetController(CC_list);
        Apexpages.standardController sc = new apexpages.standardController(CC_list);
        //for test the constructor
        ASI_eForm_KR_CC_PDFController cxnull = new ASI_eForm_KR_CC_PDFController();
        //for test the constructor
        ASI_eForm_KR_CC_PDFController cx = new ASI_eForm_KR_CC_PDFController(sc);
        //for trigger "currentHeaderID" statement
        cx.currentHeaderID = tempCC.id;
        //for trigger the getHeader method
        cx.getHeader();
        //-----------------------------------------Test 2---------------------------------//
        Test.setCurrentPage(Page.ASI_eForm_KR_CC_PDF);
        Apexpages.currentPage().getParameters().put('id', tempCC1.id);
        ASI_eForm_CC_Request__c CC_list1 = new ASI_eForm_CC_Request__c();
        Apexpages.standardController sc1 = new apexpages.standardController(CC_list1);
        ASI_eForm_KR_CC_PDFController cx1 = new ASI_eForm_KR_CC_PDFController(sc1);
        //-----------------------------------------Test 2---------------------------------//
        Test.stopTest();
    }//end Test_CC_PDFController*/
    
    
}