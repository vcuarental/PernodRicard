/***************************************************************************************************************************
* Name:        ASI_CRM_CN_PromotionPaymentCtrlTest 
* Description: Test class for ASI_CRM_CN_PromotionPaymentCtrl
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-08-16       Canter Duan             Created
****************************************************************************************************************************/
@isTest
public class ASI_CRM_CN_PromotionPaymentCtrlTest {
    //准备基础数据区域
    @testSetup static void setup() {
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
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Guidance', ASI_CRM_Max_Value__c =100, ASI_CRM_Min_Value__c =1, 
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract')) );
        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Other Cost', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PO Submit Date',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Display', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract')) );      
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Period: PO Start Date', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         ASI_CRM_Alignment_Value__c = 99,
                                                                         //AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test4',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );                                                         
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: GS Total', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test5',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: Total GS%', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test5',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );   
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: GS% by Subbrand', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test6',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Volume: Total', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test7',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );                                                                                                                                                                                                                                                                                                                    
        
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
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1,ASI_CRM_CN_Payment_Page_Number__c = 1);
        insert CustomSetting ;
        
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST',ASI_CRM_CN_CRM_Code__c = 'OFCDU13691', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_BusinessLicenseUploading__c=true, ASI_CRM_CN_Business_License_Expire_date__c=PO_End_Date, ASI_CRM_CN_Business_License_Start_Date__c =PO_Start_Date,ASI_CRM_Channel_Group__c=ChannelGroup.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
                                                             RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                                                             Name='TEST',ASI_CRM_CN_CRM_Code__c = 'OFCDU13691', 
                                                             ASI_CRM_CN_Image__c='Iconic',
                                                             ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id, 
                                                             ASI_CRM_CN_BusinessLicenseUploading__c=true, ASI_CRM_CN_Business_License_Expire_date__c=PO_End_Date, 
                                                             ASI_CRM_CN_Business_License_Start_Date__c =PO_Start_Date,ASI_CRM_Channel_Group__c=ChannelGroup.Id));
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));

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
        insert LUser;
        
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
                                                                      ASI_TH_CRM_Contract_Status__c = 'Final',
                                                                      ASI_CRM_System_Debug__c=true,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',
                                                                      ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
                                                                      ASI_CRM_PO_Channel__c = channel.Id,
                                                                      ASI_CRM_CN_Data_Source__c = 'Outlet Intake',
                                                                      Name = 'Contract0',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                      ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                      ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract0;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_TH_CRM_Contract_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='Outlet Promotion',
                                                                     ASI_CRM_PO_Channel__c = channel.Id,
                                                                     ASI_CRM_Copied_From__c = Contract0.Id,
                                                                     ASI_CRM_CN_Data_Source__c = 'Min(WS Intake, Outlet Intake)',
                                                                     ASI_CRM_CN_V0_0_PO_version__c = Contract0.Id,
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        ASI_CN_Trade_Margin__c Asmt1 = new ASI_CN_Trade_Margin__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_CN_Trade_Margin__cASI_CRM_CN_Trade_Margin_Promotion'),
                                                                  Type__c = 'T1 to T2',
                                                                  ASI_CRM_CN_Region__c = region.Id,
                                                                  ASI_CRM_Channel__c = channel.Id,
                                                                  ASI_CRM_CN_Visibility_Threshold__c = 1,
                                                                  ASI_CRM_CN_Free_Goods_GWP_Threshold__c = 1,
                                                                  ASI_CRM_Other_Cost_Threshold__c = 1,
                                                                  ASI_CRM_Other_Cost_Threshold_for_Remark__c = 1);
        insert Asmt1;
        
        List<ASI_TH_CRM_PaymentRequest__c> lstPR = new List<ASI_TH_CRM_PaymentRequest__c>();  
        Id recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        lstPR.add(new ASI_TH_CRM_PaymentRequest__c(Name='100', ASI_CRM_CN_OutletWS__c=Customers[0].id,ASI_CRM_CN_Last_Payment__c=true,recordTypeId=recordTypeID,
                                                   ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Payment_Type__c = 'Discount',
                                                   ASI_TH_CRM_Contract__c=Contract.Id));
        insert lstPR;       
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Payment_Request__c=lstPR[0].Id,ASI_CRM_Methodology__c =MethodologyList[0].Id,ASI_CRM_CN_Total_Markup__c=100, ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Payment_Request__c=lstPR[0].Id,ASI_CRM_Methodology__c =MethodologyList[0].Id,ASI_CRM_CN_Total_Markup__c=100, ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Payment_Request__c=lstPR[0].Id,ASI_CRM_Methodology__c =MethodologyList[0].Id,ASI_CRM_CN_Total_Markup__c=100, ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Methodology__c =MethodologyList[0].Id,ASI_CRM_CN_Total_Markup__c=100, ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        insert ModuleList;
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        ASI_CRM_Contract_Cost_Setting__c ccs = new ASI_CRM_Contract_Cost_Setting__c(
            ASI_CRM_CN_Promotion_Type__c='Outlet Promotion',
            ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
            ASI_CRM_CN_BRSF_Activity_Code_Default__c =true,
            ASI_CRM_PSF_Activity_Code_Default__c = false,
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,
            ASI_CRM_CN_Variable_Cost_Contract__c=true);
        insert ccs;
        ASI_CRM_Contract_Cost_Setting__c ccs2 = new ASI_CRM_Contract_Cost_Setting__c(
            ASI_CRM_CN_Promotion_Type__c='Wholesaler Promotion',
            ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
            ASI_CRM_CN_BRSF_Activity_Code_Default__c =true,
            ASI_CRM_PSF_Activity_Code_Default__c = true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,
            ASI_CRM_CN_Variable_Cost_Contract__c=true);
        insert ccs2;
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,ASI_CRM_CN_9L_Conversion_Factor__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,ASI_CRM_CN_9L_Conversion_Factor__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,ASI_CRM_CN_9L_Conversion_Factor__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1', ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2', ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3', ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_HK_CRM_Product_Category__c =ProductCategoryList[0].Id, ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_HK_CRM_Product_Category__c =ProductCategoryList[1].Id, ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_HK_CRM_Product_Category__c =ProductCategoryList[2].Id, ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Sub_brand_Code__c = '996',ASI_MFM_Active_for_CRM__c = true));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '997', ASI_MFM_Active_for_CRM__c = true,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '998' ,ASI_MFM_Active_for_CRM__c = true,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        list<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new list<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                               ASI_CRM_CN_New_Channel__c =channel.Id       		                                                    
                                                              )
                                );
        }           
        insert SubBrandLineList;
        
        list<ASI_MFM_Item_Group__c> itemGroupList = new list<ASI_MFM_Item_Group__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            itemGroupList.add(new ASI_MFM_Item_Group__c(ASI_MFM_Sub_brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Drop_In__c=true,
                                                               ASI_CRM_CN_Exclusion__c = true,
                                                               ASI_CRM_CN_BT_Size_C__c = '70.0000'
                                                        		
                                                              )
                                );
        }           
        insert itemGroupList;
        
        Map<Id ,Id> itemGroupMap = new Map<Id ,Id>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            for(ASI_MFM_Item_Group__c mfm : itemGroupList)
            {
                if(subBrand.Id == mfm.ASI_MFM_Sub_brand__c) 
                {
                    itemGroupMap.put(subBrand.Id ,mfm.Id);
                    break;
                }
            }
        } 
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           ASI_CRM_CN_Sub_Brand_Package__c = 'Test1',
                                                                           ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                           ASI_CRM_CN_Date__c=date.today(),
                                                                           ASI_CRM_CN_Drop_In__c = true ,
                                                                       	   ASI_CRM_CN_Pack_Size__c = '75; ',
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                          ));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           ASI_CRM_CN_Sub_Brand_Package__c = 'Test2',
                                                                           ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                           ASI_CRM_CN_Date__c=Date.today(),
                                                                           ASI_CRM_CN_Drop_In__c = true ,
                                                                       	   ASI_CRM_CN_Pack_Size__c = '75; ',
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));

            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           ASI_CRM_CN_Sub_Brand_Package__c = 'Test2',
                                                                           ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                           ASI_CRM_CN_Date__c=Date.today(),
                                                                           ASI_CRM_CN_Drop_In__c = true ,
                                                                           ASI_CRM_CN_Pack_Size__c = '75; ',
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }   
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Brand Group',
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c = 'Test3',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                       ASI_CRM_CN_Date__c=Date.today(),
                                                                       ASI_CRM_CN_Drop_In__c = true ,
                                                                       ASI_CRM_CN_Pack_Size__c = '75; ',
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                       ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c = 'Test4',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                       ASI_CRM_CN_Date__c=Date.today(),
                                                                       ASI_CRM_CN_Drop_In__c = true ,
                                                                       ASI_CRM_CN_Pack_Size__c = '75; ',
                                                                       ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Display',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c = 'Test6',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                       ASI_CRM_CN_Date__c=Date.today(),
                                                                       ASI_CRM_CN_Drop_In__c = true ,
                                                                       ASI_CRM_CN_Pack_Size__c = '75; ',
                                                                       ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Category',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           ASI_CRM_CN_Sub_Brand_Package__c = 'Test7',
                                                                           ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                           ASI_CRM_CN_Date__c=Date.today(),
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }                                                                          
        
        
        insert ContractLineList;
        
        //System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        test.stopTest();
        
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>(); 
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                 ASI_CRM_CN_Outlet__c=Customers[0].Id,
                                                 recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                 ASI_CRM_CN_Outlet__c=Customers[1].Id,
                                                 recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        insert cos;
        
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Contract__c = Contract.Id, 
                                                                                   ASI_CRM_POS_9L__c = 1,
                                                                                   ASI_CRM_POS_GS__c = 1,
                                                                                   ASI_CRM_Year__c = String.valueof(PO_Start_Date.Year()),    
                                                                                   ASI_CRM_Month__c =String.valueof(PO_Start_Date.month()),   
                                                                                   recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Subbrand_Volume__cASI_CRM_CN_WS_Outlet_Sub_brand_Volume'),
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }
        insert SubbrandVolumeList;

        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = lstPR[0].Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c=ContractLineList[0].Id,
                                                                                                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Outlet_WS'),
                                                                                                        ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,
                                                                                                        ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                                                        ASI_CRM_CN_WS_Intake_9L__c=1,ASI_CRM_CN_Outlet_Intake_9L__c=1,ASI_CRM_CTD_Actual_Vol__c=1,
                                                                                                        ASI_CRM_CN_WS_Intake_Std__c = 0,ASI_CRM_CN_Outlet_Intake_Std__c=0,ASI_CRM_CTD_Actual_Retail_Value__c=0,ASI_CRM_CTD_Actual_Purchase_Value__c=0,
                                                                                                        ASI_CRM_Module__c = ModuleList[0].Id,ASI_CRM_CN_Wholesaler__c = Customers[0].Id ,ASI_CRM_Customer__c = Customers[0].Id);
        paymentLineItems.add(paymentLineItem);
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem2 = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = lstPR[0].Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c=ContractLineList[0].Id,
                                                                                                         RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Outlet_WS'),
                                                                                                         ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,
                                                                                                         ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                                                         ASI_CRM_CN_WS_Intake_9L__c=1,ASI_CRM_CN_Outlet_Intake_9L__c=1,ASI_CRM_CTD_Actual_Vol__c=1,
                                                                                                         ASI_CRM_CN_WS_Intake_Std__c = 0,ASI_CRM_CN_Outlet_Intake_Std__c=0,ASI_CRM_CTD_Actual_Retail_Value__c=0,ASI_CRM_CTD_Actual_Purchase_Value__c=0,
                                                                                                         ASI_CRM_Module__c = ModuleList[0].Id,ASI_CRM_CN_Wholesaler__c = Customers[0].Id ,ASI_CRM_Customer__c = Customers[0].Id);
        paymentLineItems.add(paymentLineItem2);

        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem3 = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = lstPR[0].Id,
                                                                                                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),
                                                                                                        ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,
                                                                                                        ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'BRSF',
                                                                                                        ASI_CRM_CN_WS_Intake_9L__c=1,ASI_CRM_CN_Outlet_Intake_9L__c=1,ASI_CRM_CTD_Actual_Vol__c=1,
                                                                                                        ASI_CRM_CN_WS_Intake_Std__c = 0,ASI_CRM_CN_Outlet_Intake_Std__c=0,ASI_CRM_CTD_Actual_Retail_Value__c=0,ASI_CRM_CTD_Actual_Purchase_Value__c=0,
                                                                                                        ASI_CRM_Module__c = ModuleList[0].Id,ASI_CRM_CN_Wholesaler__c = Customers[0].Id);
        paymentLineItems.add(paymentLineItem3);
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem4 = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = lstPR[0].Id,
                                                                                                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                                                                                                        ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,
                                                                                                        ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'PSF',
                                                                                                        ASI_CRM_CN_WS_Intake_9L__c=1,ASI_CRM_CN_Outlet_Intake_9L__c=1,ASI_CRM_CTD_Actual_Vol__c=1,
                                                                                                        ASI_CRM_CN_WS_Intake_Std__c = 0,ASI_CRM_CN_Outlet_Intake_Std__c=0,ASI_CRM_CTD_Actual_Retail_Value__c=0,ASI_CRM_CTD_Actual_Purchase_Value__c=0,
                                                                                                        ASI_CRM_Module__c = ModuleList[1].Id,ASI_CRM_CN_Wholesaler__c = Customers[0].Id);
        paymentLineItems.add(paymentLineItem4);
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem5 = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = lstPR[0].Id,
                                                                                                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Display'),
                                                                                                        ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,
                                                                                                        ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'Display',
                                                                                                        ASI_CRM_CN_WS_Intake_9L__c=1,ASI_CRM_CN_Outlet_Intake_9L__c=1,ASI_CRM_CTD_Actual_Vol__c=1,
                                                                                                        ASI_CRM_CN_WS_Intake_Std__c = 0,ASI_CRM_CN_Outlet_Intake_Std__c=0,ASI_CRM_CTD_Actual_Retail_Value__c=0,ASI_CRM_CTD_Actual_Purchase_Value__c=0,
                                                                                                        ASI_CRM_Module__c = ModuleList[2].Id,ASI_CRM_CN_Wholesaler__c = Customers[0].Id);
        paymentLineItems.add(paymentLineItem5);
        insert paymentLineItems;
        
        List<ASI_CRM_Volume_Aggregation_Breakdown__c> subBrandVolList = new List<ASI_CRM_Volume_Aggregation_Breakdown__c>();
        subBrandVolList.add(new ASI_CRM_Volume_Aggregation_Breakdown__c(ASI_CRM_Outlet_Sub_brand_Volume__c=SubbrandVolumeList[0].Id,ASI_CRM_Account__c=Customers[0].Id,
                                                                        ASI_CRM_Sub_brand_Volume__c=SubbrandVolumeList[0].Id,ASI_CRM_Depletion__c=1,ASI_CRM_Depletion_GS__c=1,                                                                        
                                                                        ASI_CRM_Depletion_GS_T1_Price__c=1,ASI_CRM_Depletion_STD__c=1));
        insert subBrandVolList;
        
        List<ASI_CRM_CN_PH_Payee_Line_Item__c> PLIlst = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        ASI_CRM_CN_PH_Payee_Line_Item__c pLI = new ASI_CRM_CN_PH_Payee_Line_Item__c();
        pLI.CurrencyIsoCode='CNY';
        pLI.ASI_CRM_CN_Type__c = 'Discount';
        pLI.ASI_CRM_CN_Payment_Request__c=lstPR[0].Id;
        PLIlst.add(pLI);
        insert PLIlst;
        
        List<ASI_CRM_Effective_supplier__c> suppList = new List<ASI_CRM_Effective_supplier__c>();
        suppList.add(new ASI_CRM_Effective_supplier__c(ASI_CRM_Account__c = Customers[0].Id,ASI_CRM_Supplier__c=Customers[0].Id,ASI_CRM_Last_tran_date__c=Date.today()));
        insert suppList;
        
        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands)
        {
            excludeItemList.add(new ASI_CRM_Exclude_Item_Group_Volume__c(ASI_CRM_Account__c = Customers[0].Id ,ASI_CRM_Outlet__c = Customers[0].Id ,ASI_CRM_Sub_Brand__c = subBrand.Id ,
                                                                         ASI_CRM_End_Date__c = Date.today().toStartOfMonth().addDays(-2),
                                                                          ASI_CRM_CN_Intake_GS_T1_price__c = 20,
                                                                         ASI_CRM_POS_9L__c = 20 ,ASI_CRM_POS_GS__c = 20,
                                                                        ASI_CRM_CN_Item_Group__c = itemGroupMap.get(subBrand.Id),
                                                                        ASI_CRM_Depletion__c = 20 ,ASI_CRM_Depletion_GS_T1_Price__c = 20
                                                                        ));
            
        }
        insert excludeItemList;
        //test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionPaymentCtrlTest1() {	
        ASI_TH_CRM_PaymentRequest__c PayReq = [select id,ASI_TH_CRM_Contract__c,ASI_CRM_Auto_PO_Modification__c from ASI_TH_CRM_PaymentRequest__c where name= '100'];
        ASI_TH_CRM_Contract__c contract = [select id,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Contract_Status__c,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_V0_0_PO_version__c 
                                           from ASI_TH_CRM_Contract__c where name = 'Contract1'];
        ApexPages.StandardController stdController = new ApexPages.StandardController(PayReq);  
        ApexPages.currentPage().getParameters().put('isEdit','1');
        ApexPages.currentPage().getParameters().put('isEditHeader','1');
        ASI_CRM_CN_PromotionPaymentCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionPaymentCtrl(stdController);
        PromotionContractCtrl.endDate = Date.today().toStartOfMonth().addDays(-1);
        PromotionContractCtrl.ContractSelected = contract;
        PromotionContractCtrl.isView = true;
        PromotionContractCtrl.Calculation();
        PromotionContractCtrl.init();
        String freeGoodsJSON = '{"WSCDE001OFCSH0011":{"paymentRequestLines":[],"paymentRequestLineOutletWS":{"attributes":{"type":"ASI_TH_CRM_PaymentRequestLineItem__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_TH_CRM_PaymentRequestLineItem__c/aC29E0000004aj8SAA"},"ASI_CRM_CN_Actual_Vol__c":0,"ASI_CRM_CN_Allow_Changing_Incentive__c":false,"ASI_CRM_Customer__c":"aBpD00000008n69KAA","'+
            'ASI_CRM_CN_Rebate_Percent__c":0.00,"ASI_CRM_CN_Total_Payable__c":0.00,"ASI_CRM_CN_Wholesaler__c":"aBpD00000008pSkKAI","ASI_CRM_CTD_Actual_Purchase_Value__c":11933243.16,"ASI_CRM_CTD_Actual_Vol__c":'+
            '140.0300000000000001,"ASI_TH_CRM_Payment_Request__c":"aC39E0000004H5cSAE","ASI_CRM_CN_WS_Intake_9L__c":1546.82000000000003,"ASI_CRM_CN_Outlet_Intake_9L__c":140.0300000000000001,"'+
            'ASI_CRM_CN_POS_Volume__c":0.00,"ASI_CRM_CN_POS_Value__c":0.00,"ASI_CRM_CTD_Actual_Retail_Value__c":1008109.86,"ASI_CRM_Actual_Value_Base__c":1008109.86,"Id":"aC29E0000004aj8SAA","RecordTypeId":"'+
            '0129E000000XBWgQAO","ASI_CRM_CN_CRM_Code__c":"WSCDE001OFCSH0011","CurrencyIsoCode":"JPY","ASI_CRM_Customer__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/'+
            'sobjects/ASI_CRM_AccountsAdditionalField__c/aBpD00000008n69KAA"},"ASI_CRM_CN_CRM_Code__c":"OFCSH0011","Name":"长沙携手酒业营销有限公司(OFCSH0011)","Id":"aBpD00000008n69KAA","RecordTypeId":"'+
            '012D00000007NLPIA2","CurrencyIsoCode":"HKD"},"ASI_CRM_CN_Wholesaler__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_CRM_AccountsAdditionalField__c/aBpD00000008pSkKAI"},"ASI_CRM_CN_CRM_Code__c":"WSCDE001","Name":"湖南星城一品(WSCDE001)","Id":"aBpD00000008pSkKAI","RecordTypeId":"012D00000007NLOIA2","CurrencyIsoCode'+
            '":"HKD"},"ASI_TH_CRM_Payment_Request__r":{"attributes":{"type":"ASI_TH_CRM_PaymentRequest__c","url":"/services/data/v46.0/sobjects/ASI_TH_CRM_PaymentRequest__c/aC39E0000004H5cSAE"},"'+
            'ASI_CRM_CN_Promotion_Type__c":"Outlet Promotion","Id":"aC39E0000004H5cSAE","RecordTypeId":"012D00000007NMIIA2","CurrencyIsoCode":"JPY"},"RecordType":{"attributes":{"type":"RecordType","url":"/services'+
            '/data/v46.0/sobjects/RecordType/0129E000000XBWgQAO"},"DeveloperName":"ASI_CRM_CN_Payment_Request_Detail_Outlet_WS","Id":"0129E000000XBWgQAO"}},"moduleWrappers":[],"module":{"attributes":{"type":"'+
            'ASI_CRM_Module__c"}},"ASI_CRM_Application_Payment_Amount":null}}';
        ApexPages.currentPage().getParameters().put('freeGoodsJSON',freeGoodsJSON);
        ApexPages.currentPage().getParameters().put('pricePromotionJSON',freeGoodsJSON);
        PromotionContractCtrl.NextPage();
        List<String> stringList1 = PromotionContractCtrl.getColHeaders('Outlet Promotion','South Region');
        List<String> stringList2 = PromotionContractCtrl.getColHeaders('Wholesaler Promotion','South Region');
        List<String> stringList3 = PromotionContractCtrl.getColHeaders('Outlet Promotion','Test');
        List<String> stringList4 = PromotionContractCtrl.getColHeaders('Consumer Promotion','South Region');
        System.debug(LoggingLevel.INFO, '*** Limits.getLimitQueries1(): ' + Limits.getLimitQueries());
        PromotionContractCtrl.GoEditHeader();
        PromotionContractCtrl.GoToCheckPoint();
        PromotionContractCtrl.ErrorHandling('message');
        PromotionContractCtrl.AutoPOModification();
        PromotionContractCtrl.GoEditDetailPage();
        System.debug(LoggingLevel.INFO, '*** Limits.getLimitQueries2: ' + Limits.getLimitQueries());
        test.startTest();
        System.debug(LoggingLevel.INFO, '*** Limits.getLimitQueries4: ' + Limits.getLimitQueries());
        PromotionContractCtrl.GoEditPayee();
        PromotionContractCtrl.saveItems();
        PromotionContractCtrl.CancelProcess();
        PromotionContractCtrl.refreshPricePromotionVolume();


        Decimal numbers = ASI_CRM_CN_PromotionPaymentCtrl.denullify(null,1);
        ASI_CRM_Module__c modu = [select id,ASI_CRM_Volume_Base__c,ASI_CRM_Line_Type__c,ASI_CRM_Methodology__c from ASI_CRM_Module__c where ASI_CRM_Line_Type__c='BRSF'];
        ASI_CRM_Module__c module1 = PromotionContractCtrl.createModule(modu);
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> payReqItem = new List<ASI_TH_CRM_PaymentRequestLineItem__c>([select id,ASI_CRM_Module__c,ASI_CRM_Volume_Base__c,ASI_CRM_CN_Sub_Brand__c,
                                                                                                                ASI_CRM_Line_Long_Name__c,ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c,
                                                                                                                ASI_CRM_CN_Outlet_Intake_9L__c,ASI_CRM_CTD_Actual_Retail_Value__c,ASI_CRM_CN_Wholesaler__c,
                                                                                                                ASI_CRM_CTD_Actual_Purchase_Value__c,ASI_CRM_CN_WS_Intake_9L__c,ASI_CRM_CTD_Actual_Vol__c,
                                                                                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Total_Payable__c,
                                                                                                                ASI_TH_CRM_Payment_Request__c ,
                                                                                                                ASI_TH_CRM_Subbrand__c ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Pack_Size__c ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Drop_In__c ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate__c,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__c ,
                                                ASI_CRM_CN_WS_Intake_9L_Original__c ,                                                
                                                ASI_CRM_CN_WS_Intake_9L_Exclude__c ,
                                                ASI_CRM_CN_Outlet_Intake_9L_Exclude__c ,
                                                ASI_CRM_CN_Outlet_Intake_9L_Original__c ,
                                                ASI_CRM_Actual_Purchase_Value_Original__c ,
                                                ASI_CRM_Actual_Purchase_Value_Exclude__c ,                                                
                                                ASI_CRM_CN_POS_Volume_9L_Original__c ,
                                                ASI_CRM_CN_POS_Volume_9L_Exclude__c ,                                                
                                                ASI_CRM_CN_POS_Value_Original__c ,
                                                ASI_CRM_CN_POS_Value_Exclude__c ,
                                                ASI_CRM_CTD_Actual_Retail_Value_Original__c ,
                                                ASI_CRM_CTD_Actual_Retail_Value_Exclude__c ,                                                
                                                ASI_CRM_CN_Actual_Value_Base_Original__c ,
                                                ASI_CRM_CN_Outlet_Intake_Std__c from ASI_TH_CRM_PaymentRequestLineItem__c]);
        
        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = [select Id ,ASI_CRM_CN_Pack_Size__c ,
                                                                                        ASI_CRM_CN_Intake_GS_T1_price__c ,
                                                                                        ASI_CRM_POS_9L__c ,
                                                                                        ASI_CRM_POS_GS__c ,
                                                                                        ASI_CRM_Actual_Vol_9L__c ,
                                                                                        ASI_CRM_PR_Direct__c ,
                                                                                        ASI_CRM_T2_Depletion__c ,
                                                                                        ASI_CRM_Depletion_GS_T1_Price__c ,
                                                                                        ASI_CRM_Depletion__c,
                                                                                        ASI_CRM_Account__c ,
                                                                                        ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
                                                                                        ASI_CRM_Sub_Brand__c ,
                                                                                        ASI_CRM_CN_Item_Group__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c
                                                                                    from ASI_CRM_Exclude_Item_Group_Volume__c ];
        Id PRDORecordTypeId = ASI_TH_CRM_PaymentRequestLineItem__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Payment_Request_Detail_Outlet_WS').getRecordTypeId();
        //ASI_TH_CRM_PaymentRequestLineItem__c reqItem2 = PromotionContractCtrl.CountExcludeItemGroupAndPaymentItem(payReqItem[0] ,excludeItemList[0]);
        ASI_TH_CRM_PaymentRequestLineItem__c reqItem = PromotionContractCtrl.createPaymentRequestLineItem(payReqItem[0].ASI_TH_CRM_Payment_Request__c,payReqItem[0].ASI_CRM_Module__c,payReqItem[0].ASI_CRM_Volume_Base__c,PRDORecordTypeId);
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>([select id,ASI_CRM_CN_Sub_Brand__c,
                                                                                                                ASI_CRM_Line_Long_Name__c,ASI_CRM_CN_Rebate_Percent__c
                                                                                                                from ASI_CRM_CN_Contract_BRSF_Line_Item__c]);
        List<ASI_TH_CRM_PaymentRequestLineItem__c> payItemList = PromotionContractCtrl.createPaymentRequestLineFromContractLines(BRSFList);
        List<ASI_CRM_Volume_Aggregation_Breakdown__c> BreakList = new List<ASI_CRM_Volume_Aggregation_Breakdown__c>([select id,ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Subbrand__c,
                                                                                                                     ASI_CRM_Sub_brand_Volume__r.ASI_CRM_End_Date__c,
                                                                                                                     ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c,
                                                                                                                     ASI_CRM_Depletion__c,ASI_CRM_Depletion_GS_T1_Price__c ,
                                                                                                                     ASI_CRM_Depletion_STD__c
                                                                                                                     from ASI_CRM_Volume_Aggregation_Breakdown__c]);
        //ASI_TH_CRM_PaymentRequestLineItem__c PyaLineItem = PromotionContractCtrl.calculateSubBrandVolumesByBreakdowns(BreakList,payReqItem,'Outlet Promotion','date','By Sub-Brand','Rebate%(By Month)',false);
      
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> PyaLineItemList = PromotionContractCtrl.calculateSubBrandVolumesByBreakdowns(BreakList,payReqItem,'Outlet Promotion','date', 'By Sub-Brand','Rebate%(By Mon)',false);
        
        List<ASI_CRM_Subbrand_Volume__c> volList = new List<ASI_CRM_Subbrand_Volume__c>([select id,ASI_CRM_Actual_Vol_9L__c,ASI_CRM_POS_9L__c,ASI_CRM_Subbrand__c,ASI_CRM_End_Date__c,(select ASI_CRM_Account__c,
                        ASI_CRM_Depletion__c,
                        ASI_CRM_Depletion_GS__c,
                        ASI_CRM_Depletion_GS_T1_Price__c,
                        ASI_CRM_Depletion_STD__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__r.Name,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Actual_Vol_9L__c,
                        ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_T2_Depletion_GS__c from Sub_brand_Volume_Aggregation_Breakdown__r),
                                                                                         ASI_CRM_Account__c,ASI_CRM_T1_Depletion__c,ASI_CRM_CN_WS_Tier__c,ASI_CRM_CN_Intake_GS_T1_price__c,ASI_CRM_CN_Volume_Out_GS_Price__c
                                                                                         from ASI_CRM_Subbrand_Volume__c]);
        ASI_TH_CRM_PaymentRequestLineItem__c CrmPay = PromotionContractCtrl.calculateSubBrandVolumes(volList,payReqItem[0],'Wholesaler Promotion','Outlet Intakes','By Sub-Brand','Rebate%(By Month)');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> CrmPayList1 = PromotionContractCtrl.calculateSubBrandVolumes(volList,payReqItem,'Wholesaler Promotion','Outlet Intake','By Sub-Brand','Rebate%(By Month)');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> CrmPayList2 = PromotionContractCtrl.calculateSubBrandVolumes(volList,payReqItem,'Wholesaler Promotion','Outlet Intak','By Sub','Rebate%(By Month)');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> CrmPayList3 = PromotionContractCtrl.calculateSubBrandVolumes(volList,payReqItem,'Wholesaler Promotion','Outlet','By Sub','Rebate%(By Month)');
        //List<ASI_TH_CRM_PaymentRequestLineItem__c> CrmPayList4 = PromotionContractCtrl.calculateSubBrandVolumes(volList,payReqItem[0],'Outlet Promotion','Outlet','By Sub','Rebate%(By Month)');
        System.debug(LoggingLevel.INFO, '*** Limits.getLimitQueries3()(): ' + Limits.getLimitQueries());
        ASI_TH_CRM_PaymentRequestLineItem__c CRMreq = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(payReqItem[0],'WS Intake');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> CRMreqList1 = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(payReqItem,'Min(WS Intake, Outlet Intake)');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> CRMreqList2 = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(payReqItem,'WS Intake');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> CRMreqList3 = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(payReqItem,'Outlet Intake');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> CRMreqList4 = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(payReqItem,'POS');
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> ASICRMPayList = ASI_CRM_CN_PromotionPaymentCtrl.calculatePerIncentiveBottle(payReqItem);
        List<ASI_TH_CRM_PaymentRequestLineItem__c> ASICRList = ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercentByPackage(payReqItem,'By Sub-Brand');
        List<ASI_TH_CRM_PaymentRequestLineItem__c> ASICRList2 = ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercentByLadder(payReqItem);
        List<ASI_TH_CRM_PaymentRequestLineItem__c> ASICRList3 = ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercent(payReqItem);
        test.stopTest();
    }
      static testMethod void ASI_CRM_CN_PromotionPaymentCtrlTest4() {   
        test.startTest();
        ASI_TH_CRM_PaymentRequest__c PayReq = [select id,ASI_TH_CRM_Contract__c,ASI_CRM_Auto_PO_Modification__c from ASI_TH_CRM_PaymentRequest__c where name= '100'];
        ApexPages.StandardController stdController = new ApexPages.StandardController(PayReq);  
        ApexPages.currentPage().getParameters().put('isEdit','1');
        ApexPages.currentPage().getParameters().put('isEditHeader','1');
        ASI_CRM_CN_PromotionPaymentCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionPaymentCtrl(stdController);
        PromotionContractCtrl.endDate = Date.today().toStartOfMonth().addDays(-1);
        // PromotionContractCtrl.ContractSelected = contract;
        PromotionContractCtrl.isView = true;
        PromotionContractCtrl.init();
        String freeGoodsJSON = '{"WSCDE001OFCSH0011":{"paymentRequestLines":[],"paymentRequestLineOutletWS":{"attributes":{"type":"ASI_TH_CRM_PaymentRequestLineItem__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_TH_CRM_PaymentRequestLineItem__c/aC29E0000004aj8SAA"},"ASI_CRM_CN_Actual_Vol__c":0,"ASI_CRM_CN_Allow_Changing_Incentive__c":false,"ASI_CRM_Customer__c":"aBpD00000008n69KAA","'+
            'ASI_CRM_CN_Rebate_Percent__c":0.00,"ASI_CRM_CN_Total_Payable__c":0.00,"ASI_CRM_CN_Wholesaler__c":"aBpD00000008pSkKAI","ASI_CRM_CTD_Actual_Purchase_Value__c":11933243.16,"ASI_CRM_CTD_Actual_Vol__c":'+
            '140.0300000000000001,"ASI_TH_CRM_Payment_Request__c":"aC39E0000004H5cSAE","ASI_CRM_CN_WS_Intake_9L__c":1546.82000000000003,"ASI_CRM_CN_Outlet_Intake_9L__c":140.0300000000000001,"'+
            'ASI_CRM_CN_POS_Volume__c":0.00,"ASI_CRM_CN_POS_Value__c":0.00,"ASI_CRM_CTD_Actual_Retail_Value__c":1008109.86,"ASI_CRM_Actual_Value_Base__c":1008109.86,"Id":"aC29E0000004aj8SAA","RecordTypeId":"'+
            '0129E000000XBWgQAO","ASI_CRM_CN_CRM_Code__c":"WSCDE001OFCSH0011","CurrencyIsoCode":"JPY","ASI_CRM_Customer__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/'+
            'sobjects/ASI_CRM_AccountsAdditionalField__c/aBpD00000008n69KAA"},"ASI_CRM_CN_CRM_Code__c":"OFCSH0011","Name":"长沙携手酒业营销有限公司(OFCSH0011)","Id":"aBpD00000008n69KAA","RecordTypeId":"'+
            '012D00000007NLPIA2","CurrencyIsoCode":"HKD"},"ASI_CRM_CN_Wholesaler__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_CRM_AccountsAdditionalField__c/aBpD00000008pSkKAI"},"ASI_CRM_CN_CRM_Code__c":"WSCDE001","Name":"湖南星城一品(WSCDE001)","Id":"aBpD00000008pSkKAI","RecordTypeId":"012D00000007NLOIA2","CurrencyIsoCode'+
            '":"HKD"},"ASI_TH_CRM_Payment_Request__r":{"attributes":{"type":"ASI_TH_CRM_PaymentRequest__c","url":"/services/data/v46.0/sobjects/ASI_TH_CRM_PaymentRequest__c/aC39E0000004H5cSAE"},"'+
            'ASI_CRM_CN_Promotion_Type__c":"Outlet Promotion","Id":"aC39E0000004H5cSAE","RecordTypeId":"012D00000007NMIIA2","CurrencyIsoCode":"JPY"},"RecordType":{"attributes":{"type":"RecordType","url":"/services'+
            '/data/v46.0/sobjects/RecordType/0129E000000XBWgQAO"},"DeveloperName":"ASI_CRM_CN_Payment_Request_Detail_Outlet_WS","Id":"0129E000000XBWgQAO"}},"moduleWrappers":[],"module":{"attributes":{"type":"'+
            'ASI_CRM_Module__c"}},"ASI_CRM_Application_Payment_Amount":null}}';
        ApexPages.currentPage().getParameters().put('freeGoodsJSON',freeGoodsJSON);
        ApexPages.currentPage().getParameters().put('pricePromotionJSON',freeGoodsJSON);
        ASI_CRM_CN_PromotionPaymentCtrl.DELETEBATCH_ROW_QTY = 0;
        ASI_CRM_CN_PromotionPaymentCtrl.BATCH_OUTLET_QTY = 0;
        Integer deleteLines = [SELECT count() FROM ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c =: PromotionContractCtrl.PH.Id
                        and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                        OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Promotion')];
        System.debug(LoggingLevel.INFO, '*** deleteLines: ' + deleteLines);
        PromotionContractCtrl.refreshPricePromotionVolume();
       PromotionContractCtrl.refreshPricePromotionVolume();

        test.stopTest();
    }  
      static testMethod void ASI_CRM_CN_PromotionPaymentCtrlTest5() {   
        test.startTest();
        ASI_TH_CRM_PaymentRequest__c PayReq = [select id,ASI_TH_CRM_Contract__c,ASI_CRM_Auto_PO_Modification__c from ASI_TH_CRM_PaymentRequest__c where name= '100'];
        ApexPages.StandardController stdController = new ApexPages.StandardController(PayReq);  
        ApexPages.currentPage().getParameters().put('isEdit','1');
        ApexPages.currentPage().getParameters().put('isEditHeader','1');
        ASI_CRM_CN_PromotionPaymentCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionPaymentCtrl(stdController);
        PromotionContractCtrl.endDate = Date.today().toStartOfMonth().addDays(-1);
        // PromotionContractCtrl.ContractSelected = contract;
        PromotionContractCtrl.isView = true;
        PromotionContractCtrl.init();
        String freeGoodsJSON = '{"WSCDE001OFCSH0011":{"paymentRequestLines":[],"paymentRequestLineOutletWS":{"attributes":{"type":"ASI_TH_CRM_PaymentRequestLineItem__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_TH_CRM_PaymentRequestLineItem__c/aC29E0000004aj8SAA"},"ASI_CRM_CN_Actual_Vol__c":0,"ASI_CRM_CN_Allow_Changing_Incentive__c":false,"ASI_CRM_Customer__c":"aBpD00000008n69KAA","'+
            'ASI_CRM_CN_Rebate_Percent__c":0.00,"ASI_CRM_CN_Total_Payable__c":0.00,"ASI_CRM_CN_Wholesaler__c":"aBpD00000008pSkKAI","ASI_CRM_CTD_Actual_Purchase_Value__c":11933243.16,"ASI_CRM_CTD_Actual_Vol__c":'+
            '140.0300000000000001,"ASI_TH_CRM_Payment_Request__c":"aC39E0000004H5cSAE","ASI_CRM_CN_WS_Intake_9L__c":1546.82000000000003,"ASI_CRM_CN_Outlet_Intake_9L__c":140.0300000000000001,"'+
            'ASI_CRM_CN_POS_Volume__c":0.00,"ASI_CRM_CN_POS_Value__c":0.00,"ASI_CRM_CTD_Actual_Retail_Value__c":1008109.86,"ASI_CRM_Actual_Value_Base__c":1008109.86,"Id":"aC29E0000004aj8SAA","RecordTypeId":"'+
            '0129E000000XBWgQAO","ASI_CRM_CN_CRM_Code__c":"WSCDE001OFCSH0011","CurrencyIsoCode":"JPY","ASI_CRM_Customer__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/'+
            'sobjects/ASI_CRM_AccountsAdditionalField__c/aBpD00000008n69KAA"},"ASI_CRM_CN_CRM_Code__c":"OFCSH0011","Name":"长沙携手酒业营销有限公司(OFCSH0011)","Id":"aBpD00000008n69KAA","RecordTypeId":"'+
            '012D00000007NLPIA2","CurrencyIsoCode":"HKD"},"ASI_CRM_CN_Wholesaler__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_CRM_AccountsAdditionalField__c/aBpD00000008pSkKAI"},"ASI_CRM_CN_CRM_Code__c":"WSCDE001","Name":"湖南星城一品(WSCDE001)","Id":"aBpD00000008pSkKAI","RecordTypeId":"012D00000007NLOIA2","CurrencyIsoCode'+
            '":"HKD"},"ASI_TH_CRM_Payment_Request__r":{"attributes":{"type":"ASI_TH_CRM_PaymentRequest__c","url":"/services/data/v46.0/sobjects/ASI_TH_CRM_PaymentRequest__c/aC39E0000004H5cSAE"},"'+
            'ASI_CRM_CN_Promotion_Type__c":"Outlet Promotion","Id":"aC39E0000004H5cSAE","RecordTypeId":"012D00000007NMIIA2","CurrencyIsoCode":"JPY"},"RecordType":{"attributes":{"type":"RecordType","url":"/services'+
            '/data/v46.0/sobjects/RecordType/0129E000000XBWgQAO"},"DeveloperName":"ASI_CRM_CN_Payment_Request_Detail_Outlet_WS","Id":"0129E000000XBWgQAO"}},"moduleWrappers":[],"module":{"attributes":{"type":"'+
            'ASI_CRM_Module__c"}},"ASI_CRM_Application_Payment_Amount":null}}';
        ApexPages.currentPage().getParameters().put('freeGoodsJSON',freeGoodsJSON);
        ApexPages.currentPage().getParameters().put('pricePromotionJSON',freeGoodsJSON);
        ASI_CRM_CN_PromotionPaymentCtrl.DELETEBATCH_ROW_QTY = 0;
        ASI_CRM_CN_PromotionPaymentCtrl.BATCH_OUTLET_QTY = 0;
        Integer deleteLines = [SELECT count() FROM ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c =: PromotionContractCtrl.PH.Id
                        and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                        OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Promotion')];
        System.debug(LoggingLevel.INFO, '*** deleteLines: ' + deleteLines);
        // PromotionContractCtrl.refreshPricePromotionVolume();
        delete [SELECT id FROM ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c =:PromotionContractCtrl.PH.Id
                        and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                        OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Promotion')];

       PromotionContractCtrl.refreshPricePromotionVolume();
        test.stopTest();
    } 

    static testMethod void ASI_CRM_CN_PromotionPaymentCtrlTest2() {	
        test.startTest();
        ASI_TH_CRM_PaymentRequest__c PayReq = [select id,ASI_TH_CRM_Contract__c,ASI_CRM_Auto_PO_Modification__c from ASI_TH_CRM_PaymentRequest__c where name= '100'];
        ASI_TH_CRM_Contract__c contract = [select id,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Contract_Status__c,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_V0_0_PO_version__c 
                                           from ASI_TH_CRM_Contract__c where name = 'Contract0'];
        		       
        String idd = PayReq.Id;       
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(PayReq);  
        ApexPages.currentPage().getParameters().put('isEdit','1');
        ApexPages.currentPage().getParameters().put('isEditHeader','1');
        ASI_CRM_CN_PromotionPaymentCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionPaymentCtrl(stdController);
        PromotionContractCtrl.endDate = Date.today().toStartOfMonth().addDays(-1);
        PromotionContractCtrl.ContractSelected = contract;
        PromotionContractCtrl.isView = true;
        PromotionContractCtrl.Calculation();
        PromotionContractCtrl.init();
        PromotionContractCtrl.GoEditPayee();
        PromotionContractCtrl.startOrStopActionPoller();
        PromotionContractCtrl.initProgressBarStatus();

       PromotionContractCtrl.refreshPricePromotionVolume();
       List<SObject> sobj =  ASI_CRM_CN_PromotionPaymentCtrl.retrieveFreeGoods('ASI_MFM_Item_Group__c',null);
       PromotionContractCtrl.endDate = Date.today().addYears(1);
       PromotionContractCtrl.saveItems();
       PromotionContractCtrl.refreshPricePromotionVolume();
        PromotionContractCtrl.GoReturn();

        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionPaymentCtrlTest3() {	
        test.startTest();
        ASI_TH_CRM_PaymentRequest__c PayReq = [select id,ASI_TH_CRM_Contract__c,ASI_CRM_Auto_PO_Modification__c from ASI_TH_CRM_PaymentRequest__c where name= '100'];
        ASI_TH_CRM_Contract__c contract = [select id,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Contract_Status__c,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_V0_0_PO_version__c 
                                           from ASI_TH_CRM_Contract__c where name = 'Contract0'];
        contract.ASI_TH_CRM_Promotion_Type__c = 'Wholesaler Promotion';
        contract.ASI_CRM_CN_Data_Source__c = 'Min(WS Intake, Outlet Intake)';
        update contract;
        PayReq.ASI_TH_CRM_Contract__c = contract.Id;
        update PayReq;
		       
        String idd = PayReq.Id;       
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(PayReq);  
        ApexPages.currentPage().getParameters().put('isEdit','1');
        ApexPages.currentPage().getParameters().put('isEditHeader','1');
        ASI_CRM_CN_PromotionPaymentCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionPaymentCtrl(stdController);
        PromotionContractCtrl.endDate = Date.today().toStartOfMonth().addDays(-1);
        PromotionContractCtrl.ContractSelected = contract;
        PromotionContractCtrl.isView = true;
        PromotionContractCtrl.Calculation();
        PromotionContractCtrl.init();
        PromotionContractCtrl.GoEditPayee();
        PromotionContractCtrl.refreshPricePromotionVolume();
        List<SObject> sobj =  ASI_CRM_CN_PromotionPaymentCtrl.retrieveFreeGoods('ASI_MFM_Item_Group__c',null);
        PromotionContractCtrl.endDate = Date.today().addYears(1);
        PromotionContractCtrl.saveItems();
        PromotionContractCtrl.refreshPricePromotionVolume();
        test.stopTest();
    }
}