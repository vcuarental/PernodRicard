@isTest
public class ASI_eForm_KR_Test2
{
    //temp profile
    private static Profile tempP = [SELECT Id FROM Profile WHERE Name='Standard User'];
    //temp manager user
    private static User tempManagerU689 = new User(Alias = '689', Email='standarduser689@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='689', LanguageLocaleKey='en_US', 
                                                   LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser689@testorg.com');
    //temp test user
    private static User tempTestU666 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='666', LanguageLocaleKey='en_US', 
                                                LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser666a@testorg.com', ASI_KOR_Commission_Code__c='1234567', ManagerId = tempManagerU689.id,
                                                CompanyName = 'testUserCompanyName', Country = 'Korea');
    
    //Test for ASI_eForm_KR_checkUpdateDelete
    static testMethod void Test_checkUpdateDelete()
    {
        
        System.runAs(tempTestU666)
        {
            //create and insert some custom setting for testing
            List<ASI_eForm_KR_LR__c> settings = new List<ASI_eForm_KR_LR__c>();
            settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='병가 휴가 Sick Leave',name ='Sick Leave',ASI_eForm_KR_LR_LeavePerYorM__c=7));
            settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='보건휴가 Menstruation Leave',name ='Menstruation Leave',ASI_eForm_KR_LR_LeavePerYorM__c=1));
            settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='특별휴가 Special Leave',name ='Special Leave',ASI_eForm_KR_LR_LeavePerYorM__c=4));
            settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='결혼기념일 휴가 Wedding Anniversary',name ='Wedding Anniversary',ASI_eForm_KR_LR_LeavePerYorM__c=1));
            insert settings;
            
            //create and insert some temp MDM info
            ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name=tempTestU666.ASI_KOR_Commission_Code__c, ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                                  ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
                                                                  ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                                  ASI_eForm_Employee_Work_Email__c='123.345@email.com');
            insert tempMDM;
            
            ASI_eForm_Recruitment__c tempRR = new ASI_eForm_Recruitment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Recruitment__cASI_eForm_KR_Recruitment'), 
                                                                           ASI_eForm_Employee_Group__c='Temporary', ASI_eForm_Job_Type__c='Non-Sales', ASI_eForm_Employment_Status__c='Part-Time', 
                                                                           ASI_eForm_School_Level__c ='High School', ASI_eForm_Major__c='testText', ASI_eForm_Expected_Start_Date__c=Date.today().addDays(3), 
                                                                           ASI_eForm_Budget_Status__c= True , ASI_eForm_Budget_Status_reason__c='none', ASI_eForm_Report_Line__c=Userinfo.getUserId(),
                                                                           ASI_eForm_Key_Competencies__c='none', ASI_eForm_Other_Reason__c='none', ASI_eForm_Period_of_Employment_From__c=Date.today().addDays(7),
                                                                           ASI_eForm_Period_of_Employment_To__c=Date.today().addYears(1), ASI_eForm_new_Position__c='none', ASI_eForm_Reason__c='none', 
                                                                           ASI_eForm_Perferred__c='none', ASI_eForm_YOS__c='<1', ASI_eForm_Work_Hour__c='1', ASI_eForm_Work_Period_From__c='7:00 AM', 
                                                                           ASI_eForm_Work_Period_To__c='7:30 PM', ASI_eForm_Dept_new__c='Finance', ASI_eForm_Department__c='Management', ASI_eForm_Status__c = 'Approved');
            insert tempRR;
            update tempRR;
            delete tempRR;
            
            ASI_eForm_Home_Appliance__c tempHA = new ASI_eForm_Home_Appliance__c(ASI_eForm_Currency__c='KRW', ASI_eForm_Reason_for_Request__c='none', 
                                                                                 ASI_eForm_Status__c='Approved');
            insert tempHA;
            ASI_eForm_HA_Detail__c tempHAD = new ASI_eForm_HA_Detail__c(ASI_eForm_Home_Appliance__c=tempHA.id, ASI_eForm_Item_Name__c='none', ASI_eForm_Model_No__c='none', 
                                                                        ASI_eForm_Price__c=100000);
            insert tempHAD;
            update tempHA;
            update tempHAD;
            delete tempHAD;
            delete tempHA;
            
            Test.startTest();
            System.debug(Limits.getDMLRows());
            
            ASI_eForm_Tuition__c tempCT = new ASI_eForm_Tuition__c(ASI_eForm_Currency__c='KRW', ASI_eForm_Status__c='Approved');
            insert tempCT;
            ASI_eForm_Tuition_Detail__c tempCTD = new ASI_eForm_Tuition_Detail__c(ASI_eForm_Tuition__c=tempCT.id, ASI_eForm_Education_Level__c='유치원 Kindergarten', 
                                                                                  ASI_eForm_Fee__c=100000, ASI_eForm_Fee_Type__c='수업료 Education Fee', ASI_eForm_Grade__c='1', ASI_eForm_Name_of_Child__c='none', 
                                                                                  ASI_eForm_School_Name__c='none');
            insert tempCTD;
            update tempCT;
            update tempCTD;
            delete tempCTD;
            delete tempCT;
            
            ASI_eForm_KR_Leave_EE__c tempEE = new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDM.id,
                                                                           ASI_eform_Year__c='2015', ASI_eForm_Total_Special_Leave__c = 4);
            insert tempEE;
            ASI_eForm_Leave_Request__c tempLR = new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(7), 
                                                                               ASI_eForm_Status__c='Approved', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False, ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=100);
            insert tempLR;
            ASI_eForm_Leave_Request_Line_Item__c tempLRD =new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLR.id, ASI_eForm_Date_From__c=Date.today(), 
                                                                                                   ASI_eForm_Date_To__c=Date.today().addDays(1), ASI_eForm_Leave_Type__c='보건휴가 Menstruation Leave', 
                                                                                                   ASI_eForm_No_of_Days__c=1);
            insert tempLRD;
            update tempLR;
            update tempLRD;
            delete tempLRD;
            delete tempLR;
            
            ASI_eForm_CC_Request__c tempCC = new ASI_eForm_CC_Request__c(ASI_eForm_Rice_Wreath__c=True, ASI_eForm_Currency__c='KRW', ASI_eForm_Time__c=Datetime.now(), 
                                                                         ASI_eForm_Replacement__c='100000원', ASI_eForm_Summary_Date_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(3), 
                                                                         ASI_eForm_Leave_Sub_Type__c='본인 형제/자매 결혼 ,300000원+1일', ASI_eForm_Leave_Type__c='Congratulatory Leave', ASI_eForm_Mobile_Phone__c='82-10-3774-1207', 
                                                                         ASI_eForm_Days__c=2.0, ASI_eForm_Payment__c=100000, ASI_eForm_Place__c='none', ASI_eForm_Status__c='Approved', 
                                                                         ASI_eForm_Amount__c=200000, ASI_eForm_Support_Type__c='Leave+Money', ASI_eForm_Telephone_No__c='82-10-3774-1207');
            insert tempCC;
            update tempCC;
            delete tempCC;
            Test.stopTest();
        }
    }//end method: Test_checkUpdateDelete*/
    
    static testMethod void Test_SchdAndBatch()
    {
        List<User> tempUsers = ASI_TnE_KR_TestClassHelper.createTestUser(); //user list
        List<ASI_eForm_HR_MDM__c> tempMDMs = ASI_TnE_KR_TestClassHelper.createMDMRecords(); //MDM list
        
        List<ASI_eForm_KR_LR__c> settings = new List<ASI_eForm_KR_LR__c>();
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='병가 휴가 Sick Leave',name ='Sick Leave',ASI_eForm_KR_LR_LeavePerYorM__c=7));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='보건휴가 Menstruation Leave',name ='Menstruation Leave',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='특별휴가 Special Leave',name ='Special Leave',ASI_eForm_KR_LR_LeavePerYorM__c=4));
        settings.add(new ASI_eForm_KR_LR__c(ASI_eForm_KR_LR_Leave_Type__c='결혼기념일 휴가 Wedding Anniversary',name ='Wedding Anniversary',ASI_eForm_KR_LR_LeavePerYorM__c=1));
        insert settings;
        
        List<ASI_KR_Schd_Setting__c> schdSettings = new List<ASI_KR_Schd_Setting__c>();
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For LR Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_LRSchd'));
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For CC Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_CCSchd'));
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For CT Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_CTSchd'));
        insert schdSettings;
        
        ASI_eForm_KR_Leave_EE__c tempEE = 
            new ASI_eForm_KR_Leave_EE__c(ASI_eForm_Employee_Record__c=tempMDMs[3].id,
                                         ASI_eform_Year__c='2015', ASI_eForm_Total_Special_Leave__c = 4);
        insert tempEE;
        
        ASI_eForm_Leave_Request__c tempLR;
        ASI_eForm_CC_Request__c tempCC;
        ASI_eForm_Tuition__c tempCT;
        System.runAs(tempTestU666)
        {
            tempLR = 
                new ASI_eForm_Leave_Request__c(ASI_eForm_Summary_Date_Leave_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(1),
                                               ASI_eForm_Status__c='Draft', ASI_eForm_Leave_of_Absence__c=False, ASI_eForm_LR_Maternity_Leave__c=False,
                                               ASI_eForm_LR_Sick_Leave__c=False, Sum_of_Annual_Leave__c=0);
            insert tempLR;
            
            ASI_eForm_Leave_Request_Line_Item__c tempLRD =
                new ASI_eForm_Leave_Request_Line_Item__c(ASI_eForm_Leave_Reuest__c=tempLR.id, ASI_eForm_Date_From__c=Date.today(), 
                                                         ASI_eForm_Date_To__c=Date.today().addDays(1), ASI_eForm_Leave_Type__c='Home Leave', 
                                                         ASI_eForm_No_of_Days__c=1);
            insert tempLRD;
            
            tempCC = 
                new ASI_eForm_CC_Request__c(ASI_eForm_Rice_Wreath__c=True, ASI_eForm_Currency__c='KRW', ASI_eForm_Time__c=Datetime.now(),
                                            ASI_eForm_Replacement__c='100000원', ASI_eForm_Summary_Date_From__c=Date.today(), ASI_eForm_Summary_Date_To__c=Date.today().addDays(3),
                                            ASI_eForm_Leave_Sub_Type__c='본인 형제/자매 결혼 ,300000원+1일', ASI_eForm_Leave_Type__c='Congratulatory Leave', ASI_eForm_Mobile_Phone__c='82-10-3774-1207',
                                            ASI_eForm_Days__c=2.0, ASI_eForm_Payment__c=100000, ASI_eForm_Place__c='none', ASI_eForm_Status__c='Draft',
                                            ASI_eForm_Amount__c=200000, ASI_eForm_Support_Type__c='Leave+Money', ASI_eForm_Telephone_No__c='82-10-3774-1207');
            insert tempCC;
            Attachment attCC = new Attachment();
            attCC.parentID = tempCC.id;
            attCC.Name = 'test.txt';
            String bodyCon = 'nobody';
            attCC.Body = Blob.valueOf(bodyCon);
            insert attCC;
            update tempCC;
            
            tempCT = new ASI_eForm_Tuition__c(ASI_eForm_Currency__c='KRW', ASI_eForm_Status__c='Draft');
            insert tempCT;
            ASI_eForm_Tuition_Detail__c tempCTD = 
                new ASI_eForm_Tuition_Detail__c(ASI_eForm_Tuition__c=tempCT.id, ASI_eForm_Education_Level__c='유치원 Kindergarten',
                                                ASI_eForm_Fee__c=100000, ASI_eForm_Fee_Type__c='수업료 Education Fee', ASI_eForm_Grade__c='1', ASI_eForm_Name_of_Child__c='none', 
                                                ASI_eForm_School_Name__c='none');
            insert tempCTD;
            Attachment attCT = new Attachment();
            attCT.parentID = tempCT.id;
            attCT.Name = 'test.txt';
            String bodyCon1 = 'nobody';
            attCT.Body = Blob.valueOf(bodyCon1);
            insert attCT;
            update tempCT;
        }//end system run as
        
        Test.startTest();
        
        ASI_eForm_KR_LRSchd schdJobLR = new ASI_eForm_KR_LRSchd();
        String sch = '0 0 23 * * ?';
        System.schedule('Test LR', sch, schdJobLR);
        System.debug(Limits.getDMLRows());
        
        
        ASI_eForm_KR_CCSchd schdJobCC = new ASI_eForm_KR_CCSchd();
        System.debug(Limits.getDMLRows());
        //---------------------------------------------------------------------------------------//

        
        ASI_eForm_KR_CTSchd schdJobCT = new ASI_eForm_KR_CTSchd();
        System.debug(Limits.getDMLRows());
        System.schedule('Test CT', sch, schdJobCT);
        Test.stopTest();
    }
    
}