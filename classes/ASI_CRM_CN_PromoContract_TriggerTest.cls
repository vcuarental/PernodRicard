/***************************************************************************************************************************
* Name:        ASI_CRM_CN_PromoContract_TriggerTest 
* Description: Test class for ASI_CRM_CN_PromoContract_TriggerClass
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-08-15       Canter Duan             Created
****************************************************************************************************************************/
@isTest
public class ASI_CRM_CN_PromoContract_TriggerTest {
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
        insert LUser;
        
        List<User> userList= new List<User> ();
        userList.add(new User(Alias = 'standtss', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, ManagerID = LUser[0].id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c3@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        insert userList;
        User DMLUser2 = [ select Id from User where Alias = 'standtss' limit 1 ];
        
        System.runAs(DMLUser2) {
            ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                          ASI_CRM_CN_Status__c = 'Draft',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '1.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='TOT/MOT Group PO',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          ASI_CRM_CN_Return_Flag__c = true,
                                                                          ASI_CRM_RVP_Approval__c = true,
                                                                          ASI_CRM_CN_PO_No__c = 'TestId',
                                                                          Name = 'Contract0',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract0;
            
            ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                         ASI_CRM_CN_Status__c = 'Submitted',
                                                                         ownerId = userList[0].id,
                                                                         ASI_CRM_System_Debug__c=true,
                                                                         ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                         ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                         ASI_CRM_CN_PO_Version__c = '1.0',
                                                                         ASI_TH_CRM_Promotion_Type__c='TOT/MOT Group PO',
                                                                         ASI_CRM_PO_Channel__c = channel.Id,
                                                                         ASI_CRM_CN_Return_Flag__c = true,
                                                                          ASI_CRM_RVP_Approval__c = false,
                                                                         ASI_CRM_Copied_From__c = Contract0.Id,
                                                                         Name = 'Contract1',
                                                                         ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                         ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                         ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract;
            ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                          ASI_CRM_CN_Status__c = 'Archived',
                                                                          ASI_CRM_CN_PO_No__c = 'TestId',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '1.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='TOT/MOT Group PO',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          ASI_CRM_Copied_From__c = Contract0.Id,
                                                                          Name = 'Contract2',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract2;
        }
        
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
        
        User DMLUser = [ select Id from User where Alias = 'standt' limit 1 ];
        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Contract',ASI_CRM_Approval_Limit__c=0,
                                                               ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_User__c = DMLUser.Id));
        insert LDynApproval ;
        
        Id currentUserId = UserInfo.getUserId(); 
        List<ASI_CRM_Fix_Approval_Route__c> listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Approver_2__c=currentUserId, ASI_CRM_CN_Approver_3__c=currentUserId, ASI_CRM_CN_Approver_4__c=currentUserId,
                                                           ASI_CRM_CN_Approver_5__c=currentUserId, ASI_CRM_CN_Approver_6__c=currentUserId, ASI_CRM_CN_Approver_7__c=currentUserId,ASI_CRM_CN_Approver_8__c=currentUserId,
                                                           ASI_CRM_CN_Approver_9__c=currentUserId,ASI_CRM_CN_Approval_Limit_1__c=-99999999,ASI_CRM_CN_Approval_Limit_2__c=-99999999,ASI_CRM_CN_Approval_Limit_3__c=-99999999,
                                                           ASI_CRM_CN_Approval_Limit_4__c=-99999999,ASI_CRM_CN_Approval_Limit_5__c=-99999999,ASI_CRM_CN_Approval_Limit_6__c=-99999999,ASI_CRM_CN_Approval_Limit_7__c=-99999999,
                                                           ASI_CRM_CN_Approval_Limit_8__c=-99999999,ASI_CRM_CN_Approval_Limit_9__c=-99999999,ASI_CRM_CN_Approval_Limit_10__c=-99999999,ASI_CRM_RVP__c = currentUserId,
                                                           ASI_CRM_CN_Type__c='TOT/MOT Group Contract', ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-99999999,
                                                           ownerid=currentUserId));
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId,ASI_CRM_CN_Approver_2__c=currentUserId, ASI_CRM_CN_Approver_3__c=currentUserId, ASI_CRM_CN_Approver_4__c=currentUserId,ASI_CRM_CN_Entry_Limit__c=-99999999,
                                                           ASI_CRM_CN_Approver_5__c=currentUserId, ASI_CRM_CN_Approver_6__c=currentUserId, ASI_CRM_CN_Approver_7__c=currentUserId,ASI_CRM_CN_Approver_8__c=currentUserId,ASI_CRM_RVP__c = null,
                                                           ASI_CRM_CN_Approver_9__c=currentUserId,ASI_CRM_CN_Approval_Limit_1__c=-99999999,ASI_CRM_CN_Approval_Limit_2__c=-99999999,ASI_CRM_CN_Approval_Limit_3__c=-99999999,
                                                           ASI_CRM_CN_Approval_Limit_4__c=-99999999,ASI_CRM_CN_Approval_Limit_5__c=-99999999,ASI_CRM_CN_Approval_Limit_6__c=-99999999,ASI_CRM_CN_Approval_Limit_7__c=-99999999,
                                                           ASI_CRM_CN_Approval_Limit_8__c=-99999999,ASI_CRM_CN_Approval_Limit_9__c=-99999999,ASI_CRM_CN_Approval_Limit_10__c=-99999999, ASI_CRM_CN_Type__c='TOT/MOT Group Contract', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        insert listFixRoute;
        
        
    }
    
    static testMethod void ASI_CRM_CN_PromoContract_TriggerTest1(){
        User DMLUser = [ select Id from User where Alias = 'standtss' limit 1 ];
        System.runAs(DMLUser) {
            String message = ASI_CRM_CN_PromoContract_TriggerClass.findSOAid();
            //查询合同
            List<ASI_TH_CRM_Contract__c> AsiContractList1 = new List<ASI_TH_CRM_Contract__c>([Select Id,ASI_CRM_CN_Status__c,ASI_CRM_CN_Return_Comments__c,
                                                                                              ASI_CRM_Reject_Return_Comments__c,ASI_CRM_CN_Contract_Upload__c,
                                                                                              ASI_CRM_CN_BA_Final_Approver__c,ASI_TH_CRM_Promotion_Type__c,
                                                                                              ASI_CRM_CN_Outlet_WS__c
                                                                                              From ASI_TH_CRM_Contract__c where name = 'Contract0']);
            List<ASI_TH_CRM_Contract__c> AsiContractList2 = new List<ASI_TH_CRM_Contract__c>([Select Id,ASI_CRM_CN_Status__c,ASI_CRM_CN_Return_Comments__c,
                                                                                              ASI_CRM_Reject_Return_Comments__c,ASI_CRM_CN_Contract_Upload__c,
                                                                                              ASI_CRM_CN_BA_Final_Approver__c,ASI_TH_CRM_Promotion_Type__c,
                                                                                              ASI_CRM_CN_IsClone__c
                                                                                              From ASI_TH_CRM_Contract__c where name = 'Contract1']);
            map<id, ASI_TH_CRM_Contract__c> trigger_oldMap = new map<id, ASI_TH_CRM_Contract__c>();
            trigger_oldMap.put(AsiContractList1[0].id, AsiContractList2[0]);
            ASI_CRM_CN_PromoContract_TriggerClass.routineAfterUpdate(AsiContractList1,trigger_oldMap);
            ASI_CRM_CN_PromoContract_TriggerClass.routineBeforeUpdate(AsiContractList1,trigger_oldMap);
            ASI_CRM_CN_PromoContract_TriggerClass.routineBeforeUpsert(AsiContractList1,trigger_oldMap);
            ASI_TH_CRM_Contract__c asicon = [Select Id,Name,ASI_CRM_CN_PO_Version__c From ASI_TH_CRM_Contract__c where name = 'Contract1'];
            String NuId = ASI_CRM_CN_PromoContract_TriggerClass.update_contractNo(asicon);
            ASI_CRM_CN_PromoContract_TriggerClass.routineAfterInsert(AsiContractList1);
            ASI_CRM_Contract_Cost_Setting__c asiCostSet = [select Id,ASI_CRM_CN_Activity_Code__c,Name,
                                                           ASI_CRM_CN_Fixed_Cost_Contract__c,
                                                           ASI_CRM_CN_Chinese_Description__c,
                                                           ASI_CRM_CN_Sequence__c,
                                                           ASI_CRM_CN_Other_Cost_Payment_Request__c
                                                           From ASI_CRM_Contract_Cost_Setting__c where ASI_CRM_CN_Promotion_Type__c='Outlet Promotion'];
            ASI_CRM_Contract_Cost__c asic = ASI_CRM_CN_PromoContract_TriggerClass.CreateContractCostObjByContract(asicon,asiCostSet);
            ASI_CRM_CN_PromoContract_TriggerClass.checkOverlap(AsiContractList1,trigger_oldMap);
            Date LastConStartDate = Date.today();
            Date LastConEndDate = Date.today();
            Date ThisConStartDate = Date.today().addDays(-10);
            Date ThisConEndDate = Date.today().addDays(-10);
            ASI_CRM_CN_PromoContract_TriggerClass.isOverlap(LastConStartDate,LastConEndDate,ThisConStartDate,ThisConEndDate);
            ASI_TH_CRM_Contract__c AsiCrmCon = [select Id,ASI_CRM_CN_Owner_Manager_ID__c,ASI_CRM_CN_Sys_Approver_1__c,ASI_CRM_CN_Sys_Approver_2__c,ASI_CRM_CN_Sys_Approver_3__c,ASI_CRM_CN_Sys_Approver_4__c,ASI_CRM_CN_Sys_Approver_5__c,
                                                ASI_CRM_CN_Sys_Approver_6__c,ASI_CRM_CN_Sys_Approver_7__c,ASI_CRM_CN_Sys_Approver_8__c,ASI_CRM_CN_Sys_Approver_9__c,ASI_CRM_CN_Sys_Approver_10__c,
                                                ASI_CRM_CN_Sys_Approver_11__c from ASI_TH_CRM_Contract__c where name = 'Contract0'];
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,0,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,1,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,2,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,3,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,4,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,5,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,6,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,7,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,8,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,9,DMLUser.Id); 
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverByCount(AsiCrmCon,10,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,0,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,1,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,2,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,3,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,4,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,5,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,6,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,7,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,8,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,9,DMLUser.Id);
            ASI_CRM_CN_PromoContract_TriggerClass.setReturnApproverByCount(AsiCrmCon,10,DMLUser.Id);
            
            ASI_CRM_CN_PromoContract_TriggerClass.setApproverToNull(AsiCrmCon);

        }
    }
    
    static testMethod void ASI_CRM_CN_PromoContract_TriggerTest2(){
        User DMLUser = [ select Id,ASI_CRM_Sales_Team__c from User where Alias = 'standtss' limit 1 ];
        System.runAs(DMLUser) {
            ASI_TH_CRM_Contract__c AsiContract1 = [Select Id,ownerId,ASI_CRM_CN_Status__c,ASI_CRM_CN_Owner_Manager_ID__c,ASI_CRM_CN_Return_Comments__c,ASI_CRM_Last_RBA_Approver__c,
                                                   ASI_CRM_Reject_Return_Comments__c,ASI_CRM_CN_Contract_Upload__c,ASI_CRM_SG_Total_Contract_Margin__c,ASI_CRM_Approval_Route_Id__c,
                                                   ASI_CRM_CN_BA_Final_Approver__c,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_PO_No__c,ASI_CRM_Commercial_Team__c,
                                                   ASI_CRM_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Fixed_Cost_Total__c,ASI_CRM_CN_Return_Flag__c,
                                                   ASI_CRM_CN_Outlet_WS__c
                                                   From ASI_TH_CRM_Contract__c where name = 'Contract0'];
            List<ASI_CRM_Dynamic_Approval_Route__c> asiAppRou =new list<ASI_CRM_Dynamic_Approval_Route__c>([select id,ASI_CRM_Manager_ID__c,
                                                                                                            ASI_CRM_User__c,ASI_CRM_End_of_Dynamic_Route__c,ASI_CRM_Approval_Limit__c
                                                                                                            from ASI_CRM_Dynamic_Approval_Route__c]);
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            MAppRoute.put(AsiContract1.ASI_CRM_CN_Owner_Manager_ID__c, asiAppRou[0]);
            Map<id, User> MUser = new Map<id, User>();
            MUser.put(AsiContract1.ownerId,DMLUser);
            ASI_CRM_Fix_Approval_Route__c asiRout =[select id,ASI_CRM_CN_Regional_BA__c,ASI_CRM_CN_Entry_Limit__c,
                                                                                                  ASI_CRM_RVP__c,ASI_CRM_CN_Approver_1__c,ASI_CRM_CN_Approver_2__c,ASI_CRM_CN_Approver_3__c,
                                                                                                  ASI_CRM_CN_Approver_4__c,ASI_CRM_CN_Approver_5__c,ASI_CRM_CN_Approver_6__c,ASI_CRM_CN_Approver_7__c,
                                                                                                  ASI_CRM_CN_Approver_8__c,ASI_CRM_CN_Approver_9__c, ASI_CRM_CN_Approver_10__c,ASI_CRM_CN_Approval_Limit_1__c,
                                                                                                  ASI_CRM_CN_Approval_Limit_2__c,ASI_CRM_CN_Approval_Limit_3__c,ASI_CRM_CN_Approval_Limit_4__c,ASI_CRM_CN_Approval_Limit_5__c,
                                                                                                  ASI_CRM_CN_Approval_Limit_6__c,ASI_CRM_CN_Approval_Limit_7__c,ASI_CRM_CN_Approval_Limit_8__c,ASI_CRM_CN_Approval_Limit_9__c
                                                                                                  from ASI_CRM_Fix_Approval_Route__c where ASI_CRM_RVP__c !=null];
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix =new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            MAppLastRouteFix.put(MUser.get(AsiContract1.OwnerId).ASI_CRM_Sales_Team__c + AsiContract1.ASI_CRM_Commercial_Team__c,asiRout);
            Map<String, boolean> MPromotionType = new Map<String, boolean>();
            ASI_CRM_CN_PromoContract_TriggerClass.setApprovers(AsiContract1,MAppRouteFix,MAppRoute,MAppLastRouteFix,true,MUser,MPromotionType);
            
            ASI_TH_CRM_Contract__c AsiContract2 = [Select Id,ownerId,ASI_CRM_CN_Status__c,ASI_CRM_CN_Owner_Manager_ID__c,ASI_CRM_CN_Return_Comments__c,ASI_CRM_Last_RBA_Approver__c,
                                                   ASI_CRM_Reject_Return_Comments__c,ASI_CRM_CN_Contract_Upload__c,ASI_CRM_SG_Total_Contract_Margin__c,ASI_CRM_Approval_Route_Id__c,
                                                   ASI_CRM_CN_BA_Final_Approver__c,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_PO_No__c,ASI_CRM_Commercial_Team__c,
                                                   ASI_CRM_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Fixed_Cost_Total__c,ASI_CRM_CN_Return_Flag__c,
                                                   ASI_CRM_CN_Outlet_WS__c
                                                   From ASI_TH_CRM_Contract__c where name = 'Contract1'];
             MAppRoute.put(AsiContract2.ASI_CRM_CN_Owner_Manager_ID__c, asiAppRou[0]);
            MUser.put(AsiContract2.ownerId,DMLUser);
            ASI_CRM_Fix_Approval_Route__c asiRout1 =[select id,ASI_CRM_CN_Regional_BA__c,ASI_CRM_CN_Entry_Limit__c,
                                                                                                  ASI_CRM_RVP__c,ASI_CRM_CN_Approver_1__c,ASI_CRM_CN_Approver_2__c,ASI_CRM_CN_Approver_3__c,
                                                                                                  ASI_CRM_CN_Approver_4__c,ASI_CRM_CN_Approver_5__c,ASI_CRM_CN_Approver_6__c,ASI_CRM_CN_Approver_7__c,
                                                                                                  ASI_CRM_CN_Approver_8__c,ASI_CRM_CN_Approver_9__c, ASI_CRM_CN_Approver_10__c,ASI_CRM_CN_Approval_Limit_1__c,
                                                                                                  ASI_CRM_CN_Approval_Limit_2__c,ASI_CRM_CN_Approval_Limit_3__c,ASI_CRM_CN_Approval_Limit_4__c,ASI_CRM_CN_Approval_Limit_5__c,
                                                                                                  ASI_CRM_CN_Approval_Limit_6__c,ASI_CRM_CN_Approval_Limit_7__c,ASI_CRM_CN_Approval_Limit_8__c,ASI_CRM_CN_Approval_Limit_9__c
                                                                                                  from ASI_CRM_Fix_Approval_Route__c where ASI_CRM_RVP__c = null];
            MAppLastRouteFix.put(MUser.get(AsiContract2.OwnerId).ASI_CRM_Sales_Team__c + AsiContract1.ASI_CRM_Commercial_Team__c,asiRout1);
            ASI_CRM_CN_PromoContract_TriggerClass.setApprovers(AsiContract2,MAppRouteFix,MAppRoute,MAppLastRouteFix,true,MUser,MPromotionType);
        }
    }
}