/***************************************************************************************************************************
* Name:        ASI_CRM_CN_PromotionCheckPointResultTest 
* Description: Test class for ASI_CRM_CN_PromotionCheckPointResultCtrl
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-08-16       Canter Duan             Created
****************************************************************************************************************************/
@isTest
public class ASI_CRM_CN_PromotionCheckPointResultTest {
    @testSetup static void setup(){
        test.startTest();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        
        //ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Region__c=region.Id, ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract'));
        //insert SegmentationCriteria;
        
        List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Pro-forma)', ASI_CRM_2nd_Dimension__c='Theoretical Value', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'Approved Promotion Plan', ASI_CRM_Max_Value__c =100, ASI_CRM_Min_Value__c =1, ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_Promotion')) );
        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Period: PO Start Date', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PO Submit Date',ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',ASI_CRM_Alignment_Value__c = 99,
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_Promotion')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Other Cost%', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract')) );      
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Display', ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         ASI_CRM_Alignment_Value__c = 99,ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'Approved Promotion Plan',
                                                                         Name='Test4',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );                                                         
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: Total GS%', ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'Approved Promotion Plan',ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test5',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );   
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: GS% by Subbrand', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test6',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_Promotion')) );        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Volume: Total', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test7',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_Promotion')) );                                                                                                                                                                                                                                                                                                                    
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='TestOne ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense', ASI_CRM_2nd_Dimension__c='Purchase Value Speed%', ASI_CRM_Operation__c ='Less than or Equal to', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test8',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Payment_Checkpoint_Criteria_Promotion')) );  

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='TestOne ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense', ASI_CRM_2nd_Dimension__c='Purchase Value Speed%', ASI_CRM_Operation__c ='Less than or Equal to', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test9',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria_Promotion')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='TestTwo ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense (Excl. Fixed Cost)', ASI_CRM_2nd_Dimension__c='Purchase Value Speed%', ASI_CRM_Operation__c ='Less than or Equal to', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',
                                                                         Name='Test10',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria_Promotion')) );  

        insert SegmentationCriteriaList;
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Ladder)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Price Promotion',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_Promotion')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Per Incentive Btl',ASI_CRM_CN_KPI_Base__c='Volume base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Price Promotion',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_Promotion')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 1234',ASI_CRM_Type__c='Price Promotion',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_Promotion')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Reach X get Y',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Price Promotion', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_Promotion')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Tax)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Price Promotion', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_Promotion')));
        insert MethodologyList;
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',
                                                                            ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id,ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',ASI_CRM_CN_Volume_Value_Base__c='By Sub-Brand;By Brand Group'));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',
                                                                            ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id,ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',ASI_CRM_CN_Volume_Value_Base__c='By Sub-Brand;By Brand Group'));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',
                                                                            ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id,ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',ASI_CRM_CN_Volume_Value_Base__c='By Sub-Brand;By Brand Group'));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',
                                                                            ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id,ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',ASI_CRM_CN_Volume_Value_Base__c='By Sub-Brand;By Brand Group'));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',
                                                                            ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id,ASI_CRM_CN_PO_Type__c='Wholesaler Promotion',ASI_CRM_CN_Volume_Value_Base__c='By Sub-Brand;By Brand Group'));
        
        insert MethodologyAssignmentList;
        
        Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1);
        insert CustomSetting ;
        
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_BusinessLicenseUploading__c=true, ASI_CRM_CN_Business_License_Expire_date__c=PO_End_Date, ASI_CRM_CN_Business_License_Start_Date__c =PO_Start_Date,ASI_CRM_Channel_Group__c=ChannelGroup.Id));
        insert Customers;
        
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        Profile p = [SELECT Id FROM Profile where name = '系统管理员' or name = 'System Administrator']; 
        List<User> LUser = new List<User>();
        LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ManagerId=userInfo.getUserId(),
                           LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
        insert LUser[0];
        
        List<User> userList= new List<User> ();
        userList.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, ManagerID = LUser[0].id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c3@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        insert userList;
        
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Draft',
                                                                      ownerId = userList[0].id,
                                                                      ASI_CRM_System_Debug__c=true,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',
                                                                      ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
                                                                      ASI_CRM_PO_Channel__c = channel.Id,
                                                                      Name = 'Contract0',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                      ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                      ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract0;	
        ASI_TH_CRM_Contract__c Contract1 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Draft',
                                                                      ownerId = userList[0].id,
                                                                      ASI_CRM_System_Debug__c=true,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '1.0',
                                                                      ASI_CRM_CN_V0_0_PO_version__c = Contract0.Id,
                                                                      ASI_TH_CRM_Promotion_Type__c='Consumer Promotion',
                                                                      ASI_CRM_PO_Channel__c = channel.Id,
                                                                      ASI_CRM_Copied_From__c = Contract0.Id,
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                      ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                      ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract1;
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract0.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';       
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract0.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment2);
        
        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract0.Id,ASI_CRM_Type__c='PO Modification Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment3);
        
        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract1.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment4.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment4);
        
        List<ASI_TH_CRM_PaymentRequest__c> lstPR = new List<ASI_TH_CRM_PaymentRequest__c>();  
        Id recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        lstPR.add(new ASI_TH_CRM_PaymentRequest__c(Name='PR1', ASI_CRM_CN_OutletWS__c=Customers[0].id,ASI_CRM_CN_Last_Payment__c=true,recordTypeId=recordTypeID,ASI_TH_CRM_Status__c='Submitted',
                                                   ASI_TH_CRM_Contract__c=Contract0.Id));
        insert lstPR;
        
        insert AttachmentList; 
    }
    
    static testMethod void ASI_CRM_CN_PromotionCheckPointResultTest1() {	
        test.startTest();
        ASI_TH_CRM_Contract__c Contract0 = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c,
                                            ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c 
                                            from ASI_TH_CRM_Contract__c 
                                            where Name = 'Contract0'];
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract0);  
        ApexPages.currentPage().getParameters().put('id',Contract0.Id);
        ASI_CRM_CN_PromotionCheckPointResultCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionCheckPointResultCtrl();
        ASI_CRM_SegmentationCriteria__c SemCri = [Select id,ASI_CRM_1st_Dimension__c,ASI_CRM_2nd_Dimension__c,AS_CRM_Predefined_Theoretical_Value__c,
                                                  ASI_CRM_Alignment_Percentage__c,ASI_CRM_Alignment_Value__c,ASI_CRM_Operation__c,
                                                  ASI_CRM_Floating_Interval_Percent_Down__c,ASI_CRM_Floating_Interval_Up__c,ASI_CRM_Floating_Interval_Percent_Up__c,
                                                  ASI_CRM_Floating_Interval_Down__c,ASI_CRM_Financial_Indicator__c,ASI_CRM_Min_Value__c,ASI_CRM_Max_Value__c
                                                  from ASI_CRM_SegmentationCriteria__c 
                                                  where name = 'Test1']; 
        ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData ins = new ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData(); 
        ins.SegmentationCriteria = SemCri;
        PromotionContractCtrl.generateD2NumberForPTV(ins);
        Decimal numb = ASI_CRM_CN_PromotionCheckPointResultCtrl.generateDimension2Number(ins,1);
        ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData inDat = PromotionContractCtrl.DataOperationChecking(ins);
        ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData inDat2 = PromotionContractCtrl.setDimensionResult(ins,'1');
        ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator fac = PromotionContractCtrl.FinancialIndicatorMasterData(SemCri,'1');
        PromotionContractCtrl.CancelProcess();
        PromotionContractCtrl.ValidationChecking();
        PromotionContractCtrl.checkUserID();
        PromotionContractCtrl.POModiValidationChecking();
        PromotionContractCtrl.upsertCheckpointAttachments();
        PromotionContractCtrl.proceed();
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionCheckPointResultTest2() {	
        test.startTest();
        ASI_TH_CRM_Contract__c Contract1 = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c,
                                            ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c 
                                            from ASI_TH_CRM_Contract__c 
                                            where Name = 'Contract1'];
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract1);  
        ApexPages.currentPage().getParameters().put('id',Contract1.Id);
        ASI_CRM_CN_PromotionCheckPointResultCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionCheckPointResultCtrl();
        
        ASI_CRM_SegmentationCriteria__c SemCri = [Select id,ASI_CRM_1st_Dimension__c,ASI_CRM_2nd_Dimension__c,AS_CRM_Predefined_Theoretical_Value__c,
                                                  ASI_CRM_Alignment_Percentage__c,ASI_CRM_Alignment_Value__c,ASI_CRM_Operation__c,
                                                  ASI_CRM_Floating_Interval_Percent_Down__c,ASI_CRM_Floating_Interval_Up__c,ASI_CRM_Floating_Interval_Percent_Up__c,
                                                  ASI_CRM_Floating_Interval_Down__c,ASI_CRM_Financial_Indicator__c
                                                  from ASI_CRM_SegmentationCriteria__c 
                                                  where name = 'Test2']; 
        ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData ins = new ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData(); 
        ins.SegmentationCriteria = SemCri;
        PromotionContractCtrl.generateD2NumberForPTV(ins);
        ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData inDat = PromotionContractCtrl.DataOperationChecking(ins);
        
         ASI_CRM_SegmentationCriteria__c SemCri5 = [Select id,ASI_CRM_1st_Dimension__c,ASI_CRM_2nd_Dimension__c,AS_CRM_Predefined_Theoretical_Value__c,
                                                  ASI_CRM_Alignment_Percentage__c,ASI_CRM_Alignment_Value__c,ASI_CRM_Operation__c,
                                                  ASI_CRM_Floating_Interval_Percent_Down__c,ASI_CRM_Floating_Interval_Up__c,ASI_CRM_Floating_Interval_Percent_Up__c,
                                                  ASI_CRM_Floating_Interval_Down__c,ASI_CRM_Financial_Indicator__c
                                                  from ASI_CRM_SegmentationCriteria__c 
                                                  where name = 'Test5']; 
        ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData ins2 = new ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData(); 
        ins2.SegmentationCriteria = SemCri5;
        PromotionContractCtrl.generateD2NumberForPTV(ins2);
        ASI_CRM_CN_PromotionCheckPointResultCtrl.interimData inDat2 = PromotionContractCtrl.setDimensionResult(ins2,'1');
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionCheckPointResultTest3() {	
        test.startTest();
        ASI_TH_CRM_PaymentRequest__c pauReq1 = [Select Id, ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Last_Payment__c,
                                                ASI_TH_CRM_Status__c,ASI_TH_CRM_Contract__c 
                                                from ASI_TH_CRM_PaymentRequest__c 
                                                where Name='PR1'];
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(pauReq1);  
        ApexPages.currentPage().getParameters().put('id',pauReq1.Id);
        ASI_CRM_CN_PromotionCheckPointResultCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionCheckPointResultCtrl();
        test.stopTest();
    }
}