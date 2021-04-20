@isTest
private class ASI_eForm_KR_Test
{
    //create and insert some temp MDM info
    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
    	ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none',
    	ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
        ASI_eForm_Employee_Work_Email__c='123.345@email.com');
    
    //temp user
    Private static User tempU = [select id from user where id = :userInfo.getUserId()];
    
    //Test for ASI_eForm_KR_MDM_SendeMail
    static testMethod void Test_MDM_SendeMail()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        insert tempMDM;
        
        Test.setCurrentPage(Page.ASI_eForm_KR_MDM_SendeMail);
        Apexpages.currentPage().getParameters().put('id', tempMDM.id);
        ASI_eForm_HR_MDM__c MDMobj = new ASI_eForm_HR_MDM__c();
        Apexpages.standardController sc = new apexpages.standardController(MDMobj);
        ASI_eForm_KR_MDM_SendeMail sm = new ASI_eForm_KR_MDM_SendeMail(sc);
        sm.ASI_eForm_KR_MDM_SendeMail();
        Test.stopTest();
    }//end Test_MDM_SendeMail*/
    
    //Test for ASI_eForm_KR_LE_settingExternalID
    static testMethod void Test_externalID()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        insert tempMDM;
        
        ASI_eForm_KR_Leave_EE__c tempEE = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDM.id,ASI_eform_Year__c='2015');
        insert tempEE;
        ASI_eForm_KR_Leave_EE__c tempEE2 = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDM.id,ASI_eform_Year__c='null');
        insert tempEE2;
        
        Test.stopTest();
    }//end Test_externalID*/
    
    //Test for ASI_eForm_KR_CheckAttachemnt
    static testMethod void checkAttachment()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
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
        
		Attachment a = new Attachment();
        Attachment b = new Attachment();
        Attachment c = new Attachment();
        
        ASI_eForm_CC_Request__c tempCC = new ASI_eForm_CC_Request__c(ASI_eForm_Rice_Wreath__c=True, ASI_eForm_Currency__c='KRW', ASI_eForm_Time__c=Datetime.now(), 
        ASI_eForm_Replacement__c='100000원', ASI_eForm_Summary_Date_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(3), 
        ASI_eForm_Leave_Sub_Type__c='본인 형제/자매 결혼 ,300000원+1일', ASI_eForm_Leave_Type__c='Congratulatory Leave', ASI_eForm_Mobile_Phone__c='82-10-3774-1207', 
        ASI_eForm_Days__c=2.0, ASI_eForm_Payment__c=100000, ASI_eForm_Place__c='none', ASI_eForm_Status__c='Draft', 
        ASI_eForm_Amount__c=200000, ASI_eForm_Support_Type__c='Leave+Money', ASI_eForm_Telephone_No__c='82-10-3774-1207');
        insert tempCC;
        a.parentID = tempCC.id;
        a.Name = 'test.txt';
        String bodyCon = 'nobody';
        a.Body = Blob.valueOf(bodyCon);
        insert a;
        update tempCC;
        
        ASI_eForm_Tuition__c tempCTE = new ASI_eForm_Tuition__c(ASI_eForm_Currency__c='KRW', ASI_eForm_Status__c='Draft');  
        insert tempCTE;
        tempCTE.ASI_eForm_Status__c='Submitted';
        update tempCTE;

        ASI_eForm_KR_Leave_EE__c tempEE = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDM.id,ASI_eform_Year__c='2015', ASI_eForm_Total_Special_Leave__c = 4);
        insert tempEE;
        
        ASI_eForm_Leave_Request__c tempLR = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
        ASI_eForm_Status__c='Draft', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=100);  
        insert tempLR;
        
        list<ASI_eForm_Leave_Request_Line_Item__c> tempLRDs = new list<ASI_eForm_Leave_Request_Line_Item__c>();
        tempLRDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLR.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(3), ASI_eForm_Leave_Type__c='병가 휴가 Sick Leave', ASI_eForm_Reason__c='none', ASI_eForm_No_of_Days__c=3));
        tempLRDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLR.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(3), ASI_eForm_Leave_Type__c='예비군 훈련 Reserve forces training', ASI_eForm_Reason__c='none', ASI_eForm_No_of_Days__c=3));
        tempLRDs.add(new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLR.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(3), ASI_eForm_Leave_Type__c='병가휴직 Sick Leave of Absence', ASI_eForm_Reason__c='none', ASI_eForm_No_of_Days__c=3));
        insert tempLRDs;
        
        c.parentID = tempLR.id;
        c.Name = 'test.txt';
        c.Body = Blob.valueOf(bodyCon);
        insert c;
        update tempLR;
        
        Test.stopTest();
	}//end checkAttachment*/
    
    //Test for ASI_eForm_KR_approverMatching
    static testMethod void Test_approverMatching()
    {
        Test.startTest();
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        update tempU;
        
        insert tempMDM;
        
        ASI_eForm_Approval_Routing__c tempAR = new ASI_eForm_Approval_Routing__c(ASI_eForm_Branch_Code__c = '300-Management', 
            ASI_eForm_Approver_1__c = UserInfo.getUserId(), ASI_eForm_Approver_2__c = UserInfo.getUserId(), 
            ASI_eForm_Approver_3__c = UserInfo.getUserId(), ASI_eForm_MC_Approver__c = UserInfo.getUserId(), ASI_eForm_Form_Type__c = 'Recruitment Request');
        insert tempAR;
        
        ASI_eForm_Approval_Routing__c tempAR2 = new ASI_eForm_Approval_Routing__c(ASI_eForm_Branch_Code__c = '300-Management', 
            ASI_eForm_Approver_1__c = UserInfo.getUserId(), ASI_eForm_Approver_2__c = UserInfo.getUserId(), 
            ASI_eForm_Approver_3__c = UserInfo.getUserId(), ASI_eForm_MC_Approver__c = UserInfo.getUserId(), ASI_eForm_Form_Type__c = 'Leave Request');
        insert tempAR2;
        
        ASI_eForm_Recruitment__c tempRR = new ASI_eForm_Recruitment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Recruitment__cASI_eForm_KR_Recruitment'), 
        ASI_eForm_Employee_Group__c='Temporary', ASI_eForm_Job_Type__c='Non-Sales', ASI_eForm_Employment_Status__c='Part-Time', 
        ASI_eForm_School_Level__c ='High School', ASI_eForm_Major__c='testText', ASI_eForm_Expected_Start_Date__c=Date.today().addDays(3), 
        ASI_eForm_Budget_Status__c= True , ASI_eForm_Budget_Status_reason__c='none', ASI_eForm_Report_Line__c=Userinfo.getUserId(),
        ASI_eForm_Key_Competencies__c='none', ASI_eForm_Other_Reason__c='none', ASI_eForm_Period_of_Employment_From__c=Date.today().addDays(7),
        ASI_eForm_Period_of_Employment_To__c=Date.today().addYears(1), ASI_eForm_new_Position__c='none', ASI_eForm_Reason__c='none', 
        ASI_eForm_Perferred__c='none', ASI_eForm_YOS__c='<1', ASI_eForm_Work_Hour__c='1', ASI_eForm_Work_Period_From__c='7:00 AM', 
		ASI_eForm_Work_Period_To__c='7:30 PM', ASI_eForm_Dept_new__c='Finance', ASI_eForm_Department__c='Management', ASI_eForm_Status__c = 'Draft');
        insert tempRR;
        
        tempRR.ASI_eForm_Status__c = 'Submitted';
        update tempRR;
        
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
        
        ASI_eForm_KR_Leave_EE__c tempEE = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDM.id,ASI_eform_Year__c='2015', ASI_eForm_Total_Special_Leave__c = 4);
        insert tempEE;
        
        ASI_eForm_Leave_Request__c tempLR = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
        ASI_eForm_Status__c='Draft', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=100);  
        insert tempLR;
        
        ASI_eForm_Leave_Request_Line_Item__c tempLRD =new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLR.id, ASI_eForm_Date_From__c=Date.today(), 
        ASI_eForm_Date_To__c=Date.today().addDays(2), ASI_eForm_Leave_Type__c='보건휴가 Menstruation Leave', 
        ASI_eForm_No_of_Days__c=2);
        insert tempLRD;
        
        tempLR.ASI_eForm_Status__c = 'Submitted';
        
        Test.stopTest();
    }//end Test_approverMatching*/
}