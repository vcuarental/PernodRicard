/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromotionContractCtrlTest 
 * Description: Test class for ASI_CRM_CN_PromotionContractCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-08-08       Canter Duan             Created
 ****************************************************************************************************************************/
 @isTest
public class ASI_CRM_CN_PromotionContractCtrlTest {
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
                                                                                  
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', 
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Pro-forma)', ASI_CRM_2nd_Dimension__c='Theoretical Value', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Guidance', ASI_CRM_Max_Value__c =100, ASI_CRM_Min_Value__c =1, 
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract')) );
       
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', 
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Other Cost', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PO Submit Date',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', 
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Display', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract')) );      
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Period: PO Start Date', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         ASI_CRM_Alignment_Value__c = 99,
                                                                         //AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test4',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );                                                         
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', 
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: GS Total', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test5',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );
                                                                                    
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: Total GS%', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test5',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );   
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='GS: GS% by Subbrand', ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Within', ASI_CRM_Floating_Interval_Up__c=10, ASI_CRM_Floating_Interval_Down__c=1, 
                                                                         AS_CRM_Predefined_Theoretical_Value__c = 'PRC Default Methodology',
                                                                         Name='Test6',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', 
                                                                         ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
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
        
        Profile p = [SELECT Id FROM Profile where name = '系统管理员' or name = 'System Administrator' limit 1]; 
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
        
    	ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
                                                                     ASI_CRM_PO_Channel__c = channel.Id,
                                                                     ASI_CRM_Copied_From__c = Contract0.Id,
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        ASI_TH_CRM_Contract__c Contract03 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'final',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=false,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '1.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='Outlet Promotion',
                                                                     ASI_CRM_PO_Channel__c = channel.Id,
                                                                     ASI_CRM_Copied_From__c = Contract0.Id,
                                                                     ASI_CRM_CN_V0_0_PO_version__c=Contract.Id,
                                                                     Name = 'Contract03',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract03;
        
        ASI_CN_Trade_Margin__c Asmt1 = new ASI_CN_Trade_Margin__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_CN_Trade_Margin__cASI_CRM_CN_Trade_Margin_Promotion'),
                                                                 Type__c = 'T1 to T2',
                                                                 ASI_CRM_CN_Region__c = region.Id,
                                                                 ASI_CRM_Channel__c = channel.Id,
                                                                 ASI_CRM_CN_Visibility_Threshold__c = 1,
                                                                 ASI_CRM_CN_Free_Goods_GWP_Threshold__c = 1,
                                                                 ASI_CRM_Other_Cost_Threshold__c = 1,
                                                                 ASI_CRM_Other_Cost_Threshold_for_Remark__c = 1);
        insert Asmt1;
        
        ASI_CN_Trade_Margin__c Asmt2 = new ASI_CN_Trade_Margin__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_CN_Trade_Margin__cASI_CRM_CN_Trade_Margin_Promotion'),
                                                                 Type__c = 'T1 to Outlet',
                                                                 ASI_CRM_CN_Region__c = region.Id,
                                                                 ASI_CRM_Channel__c = channel.Id,
                                                                 ASI_CRM_CN_Visibility_Threshold__c = 1,
                                                                 ASI_CRM_CN_Free_Goods_GWP_Threshold__c = 1,
                                                                 ASI_CRM_Other_Cost_Threshold__c = 1,
                                                                 ASI_CRM_Other_Cost_Threshold_for_Remark__c = 1);
        insert Asmt2;
        
        List<ASI_TH_CRM_PaymentRequest__c> lstPR = new List<ASI_TH_CRM_PaymentRequest__c>();  
        Id recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        lstPR.add(new ASI_TH_CRM_PaymentRequest__c(Name='PR1', ASI_CRM_CN_OutletWS__c=Customers[0].id,ASI_CRM_CN_Last_Payment__c=true,recordTypeId=recordTypeID,ASI_TH_CRM_Status__c='Submitted',ASI_TH_CRM_Contract__c=Contract03.Id));
        insert lstPR;       
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Methodology__c =MethodologyList[0].Id, ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Methodology__c =MethodologyList[0].Id, ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_CN_KPI_Base__c='Volume base'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Methodology__c =MethodologyList[1].Id, ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_CN_KPI_Base__c='Volume base'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Methodology__c =MethodologyList[2].Id, ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Display',ASI_CRM_CN_KPI_Base__c='Volume base'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Methodology__c =MethodologyList[3].Id, ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_CN_KPI_Base__c='Volume base'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract03.Id,ASI_CRM_Methodology__c =MethodologyList[3].Id, ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_CN_KPI_Base__c='Volume base'));
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
        
        //Sub Brand Grade
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
        
        //System.debug([Select Id, ASI_CRM_CN_Region__c, ASI_CRM_CN_New_Channel__c from ASI_CRM_Sub_Brand_Line__c where id=:SubBrandLineList[0].Id].ASI_CRM_CN_Region__c);
        //System.debug([Select Id, ASI_CRM_CN_Region__c, ASI_CRM_CN_New_Channel__c from ASI_CRM_Sub_Brand_Line__c where id=:SubBrandLineList[0].Id].ASI_CRM_CN_New_Channel__c);
        
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
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }   
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Brand Group',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Sub_Brand_Package__c = 'Test3',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
                                                                                                                                                                                                                  
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c = 'Test4',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                       ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract03.Id,ASI_CRM_Type__c='Visibility',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c = 'Test5',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                       ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Display',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c = 'Test6',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
                                                                       ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Category',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c = 'Test7',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 1,
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
        insert cos;
                    
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Contract__c = Contract.Id, 
                                                                                   ASI_CRM_Year__c = String.valueof(PO_Start_Date.Year()),    
                                                                                   ASI_CRM_Month__c =String.valueof(PO_Start_Date.month()),   
                                                                                   recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Subbrand_Volume__cASI_CRM_CN_WS_Outlet_Sub_brand_Volume'),
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }
        insert SubbrandVolumeList;
        
        
        List<ASI_CRM_CM_GS__c> CMGSList= new List<ASI_CRM_CM_GS__c>();
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ASI_CRM_CM_GS__c TempVolume = new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c = subBrand.Id,
                                                    		    ASI_CRM_Region__c = region.Id,
                                                    			ASI_CRM_TYPE__c ='Budget GS',
                                                                ASI_CRM_CN_Month__c =9,
                                                                ASI_CRM_YEAR__c ='2018',
                                                   			    ASI_CRM_CM_GS_per_9L__c = 100);
        CMGSList.add(TempVolume);   
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ASI_CRM_CM_GS__c TempVolume = new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c = subBrand.Id,
                                                    		    ASI_CRM_Region__c = region.Id,
                                                    			ASI_CRM_TYPE__c ='Budget CM',
                                                                ASI_CRM_CN_Month__c =9,
                                                                ASI_CRM_YEAR__c ='2018',
                                                   			    ASI_CRM_CM_GS_per_9L__c = 100);
        CMGSList.add(TempVolume);   
        }
        
        insert CMGSList;
        
        list<ASI_CRM_Contract_Cost__c> costs = new list<ASI_CRM_Contract_Cost__c>();
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=Contract.Id,
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Estimate_Amount__c=1));
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=Contract.Id,
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Estimate_Amount__c=1));
        insert costs;
                            
        
        Date PO_Start_Date2 = date.newinstance(system.today().year(), system.today().month(), 1).addMonths(2);
        Date PO_End_Date2 = PO_Start_Date2.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Archived',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2,
                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,
                                                               ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                               Name = 'Contract2',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;
        
        ASI_TH_CRM_Contract__c Contract3 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Final',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2,
                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                               Name = 'Contract3',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract3;   
        
        ASI_TH_CRM_Contract__c Contract4 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Draft',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2.addMonths(3),
                                                               ASI_CRM_CN_PO_End_Date__c =PO_Start_Date2.addMonths(4)-1 ,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                               Name = 'Contract4',
                                                               ASI_CRM_Last_RBA_Approver__c = UserInfo.getUserId(),
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract4;
        ASI_TH_CRM_Contract__c Contract5 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Draft',
                                                               ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                               ASI_CRM_CN_Group_Contract__c=Contract4.id,
                                                               Name = 'Contract5',
                                                               ASI_CRM_Last_RBA_Approver__c = UserInfo.getUserId(),
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract5;
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';       
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment2);
                   
        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment3);
                                    
        insert AttachmentList; 
                                     
        //test.stopTest();
    }

    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest1() {	
     	test.startTest();
     	ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ApexPages.currentPage().getParameters().put('IsHeaderEdit','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        PromotionContractCtrl.Calculation();
        PromotionContractCtrl.init();
        PromotionContractCtrl.ValidationChecking();
        PromotionContractCtrl.GenPSFMultiTableMap();
        PromotionContractCtrl.calVisibilityAmt();
        PromotionContractCtrl.HeaderValidationChecking();
        PromotionContractCtrl.ByTotalAmountGenerating('PSF');
        PromotionContractCtrl.calculateAdjustment(Contract);
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLine = [Select Id,ASI_CRM_Module__c from ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                                                where ASI_CRM_CN_Contract__c = :Contract.Id 
                                                                and ASI_CRM_Type__c='PSF'
                                                                and ASI_CRM_Volume_Base__c='By Sub-Brand'];
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID',BRSFLine[0].ASI_CRM_Module__c);
        ApexPages.currentPage().getParameters().put('ModuleType','PSF');
        PromotionContractCtrl.refreshModule(); 
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLine2 = [Select Id,ASI_CRM_Module__c from ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                                                where ASI_CRM_CN_Contract__c = :Contract.Id 
                                                                and ASI_CRM_Type__c='PSF'
                                                                and ASI_CRM_Volume_Base__c='By Brand Group'];
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID',BRSFLine[0].ASI_CRM_Module__c);
        ApexPages.currentPage().getParameters().put('ModuleType','PPT');
        PromotionContractCtrl.refreshModule(); 
        PromotionContractCtrl.GenPSFLadderAmountMap();
        PromotionContractCtrl.refreshMonthModule();
        ASI_CRM_CN_Contract_BRSF_Line_Item__c AsiCn = [select id,ASI_CRM_Module__c from ASI_CRM_CN_Contract_BRSF_Line_Item__c where ASI_CRM_CN_Sub_Brand_Package__c = 'Test6' and ASI_CRM_Type__c='Display'];
        ApexPages.currentPage().getParameters().put('itemKey',AsiCn.ASI_CRM_Module__c);
        PromotionContractCtrl.onDisplayMethodologyChange();
     	test.stopTest();
     }
    
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest2() {
        test.startTest();
		ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        PromotionContractCtrl.createModule('PSF');
        PromotionContractCtrl.createModule('Display');
        List<ASI_CRM_Module__c> ModuleList = [Select Id,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name from ASI_CRM_Module__c where ASI_CRM_Contract__c = :Contract.Id];
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID',ModuleList[1].Id);  
        ApexPages.currentPage().getParameters().put('itemKey',ModuleList[1].Id);    
        PromotionContractCtrl.onPSFMethodologyChange();
        PromotionContractCtrl.onPSFVolumeBaseChange();
        ApexPages.currentPage().getParameters().put('ModuleType','PSF');
        PromotionContractCtrl.resetModule();
        ApexPages.currentPage().getParameters().put('PARAMID',ModuleList[1].Id); 
        PromotionContractCtrl.DeletePSFModule();
        PromotionContractCtrl.BySubBrandRefresh(ModuleList[1]);
        List<ASI_MFM_Sub_brand__c> AsiBrandList = new list<ASI_MFM_Sub_brand__c>([select Id FRom ASI_MFM_Sub_brand__c]);
        ASI_CRM_CN_PromotionContractCtrl.interimData ins = new ASI_CRM_CN_PromotionContractCtrl.interimData();
        ins.moduleReadOnly = false;
        PromotionContractCtrl.CreatePSFYearMonthLine(ins,null,null);    
        PromotionContractCtrl.CreateRebateLine(ins,'By Sub-Brand');
        PromotionContractCtrl.CreateRebateLine(ins,'By Total');
        PromotionContractCtrl.CreateRebateLine(ins,'By Brand Group');

        ASI_CRM_CN_PromotionContractCtrl.interimData ins2 = new ASI_CRM_CN_PromotionContractCtrl.interimData(true);

        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest3() {
        test.startTest();
		ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        ApexPages.currentPage().getParameters().put('PSF_Item_MapJSON',PromotionContractCtrl.PSF_Item_MapJSON);
        ApexPages.currentPage().getParameters().put('ModuleType','PSF');
        PromotionContractCtrl.PSFAddModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID','z0');        
        ApexPages.currentPage().getParameters().put('PSF_Item_MapJSON',PromotionContractCtrl.PSF_Item_MapJSON);
        ApexPages.currentPage().getParameters().put('deletedLinesJSON','[]');
        ApexPages.currentPage().getParameters().put('isQuickSave','true');
        ApexPages.currentPage().getParameters().put('DisplayListing_Item_MapJSON',PromotionContractCtrl.PSF_Item_MapJSON);
        PromotionContractCtrl.saveItems();
        ASI_CRM_CN_Contract_BRSF_Line_Item__c asis = [select Id From ASI_CRM_CN_Contract_BRSF_Line_Item__c where ASI_CRM_Type__c='Display'];
        ApexPages.currentPage().getParameters().put('itemKey',asis.Id);
        //PromotionContractCtrl.onDisplayMethodologyChange();
        PromotionContractCtrl.GoPayment();
        //PromotionContractCtrl.restorePO();
        PromotionContractCtrl.GoReturn();
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest4() {	
     	test.startTest();
     	ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c,ASI_CRM_PO_Channel__c, ASI_CRM_CN_PO_Modification__c,
                                           ASI_CRM_Copied_From__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c 
                                           from ASI_TH_CRM_Contract__c where Name = 'Contract03'];
        ApexPages.currentPage().getParameters().put('IsPOModiPage','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        PromotionContractCtrl.Calculation();
        PromotionContractCtrl.init();
        PromotionContractCtrl.calculateAdjustment(Contract);
        List<ASI_CRM_AccountsAdditionalField__c> Customers = new List<ASI_CRM_AccountsAdditionalField__c>([Select Id From ASI_CRM_AccountsAdditionalField__c ]);
        String outId = null;
        ApexPages.currentPage().getParameters().put('ITEMKEY',Customers[0].Id);
        ApexPages.currentPage().getParameters().put('OutletLineType',outId);
        PromotionContractCtrl.OutletLineChange();
        ApexPages.currentPage().getParameters().put('PSF_Item_MapJSON',PromotionContractCtrl.PSF_Item_MapJSON);
        ApexPages.currentPage().getParameters().put('ModuleType','TOT');
        PromotionContractCtrl.PSFAddModule();
        PromotionContractCtrl.GoPayment();
        system.debug('ASI_CRM_Region__c:'+Contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c+';ASI_CRM_PO_Channel__c:'+Contract.ASI_CRM_PO_Channel__c);
        PromotionContractCtrl.ValidationChecking();
    	test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest5() {	
     	test.startTest();
     	ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c from ASI_TH_CRM_Contract__c where Name = 'Contract03'];
        ApexPages.currentPage().getParameters().put('IsDetailEdit','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        PromotionContractCtrl.Calculation();
        PromotionContractCtrl.init();
        List<ASI_CRM_AccountsAdditionalField__c> Customers = new List<ASI_CRM_AccountsAdditionalField__c>([Select Id From ASI_CRM_AccountsAdditionalField__c ]);
        PromotionContractCtrl.checkOutlet(Customers[0].Id);
        String outId = null;
        PromotionContractCtrl.checkOutlet(outId);
        ApexPages.currentPage().getParameters().put('ITEMKEY',Customers[0].Id);
        ApexPages.currentPage().getParameters().put('OutletLineType','Covered');
        PromotionContractCtrl.OutletLineChange();
        PromotionContractCtrl.POModification();
        PromotionContractCtrl.saveHeader();
        PromotionContractCtrl.refreshMonthModule();
    	test.stopTest();
    }
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest6() {	
     	test.startTest();
     	ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c from ASI_TH_CRM_Contract__c 
                                           where Name = 'Contract2'];
        ApexPages.currentPage().getParameters().put('IsDetailEdit','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        
        PromotionContractCtrl.Calculation();

        PromotionContractCtrl.GoView();
        PromotionContractCtrl.GoCheckPointPage();
        PromotionContractCtrl.ViewCheckPointPage();
        PromotionContractCtrl.GoCoveredUploadPage();
        PromotionContractCtrl.GoWSUploadPage();
        PromotionContractCtrl.POModification();
        PromotionContractCtrl.GoPayment();
        PromotionContractCtrl.redirectToPage('/apex/ASI_CRM_CN_CoveredOutletUploadPage',Contract.Id);
        //PromotionContractCtrl.GoEditHeader();
        //PromotionContractCtrl.GoEditDetail();
        PromotionContractCtrl.AddNew_CoveredWS();
        PromotionContractCtrl.AddAllChildOutlets();
        PromotionContractCtrl.AddNew_CoveredOutlet();
    	test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest7() {
        test.startTest();
        ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, 
                                           ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c ,
                                           ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                           ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                                           ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, 
                                           ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c
                                           from ASI_TH_CRM_Contract__c 
                                           where Name = 'Contract4'];
        ApexPages.currentPage().getParameters().put('IsHeaderEdit','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        //------
        PromotionContractCtrl.restorePO();
        String strStartBGDate = String.valueOf(Date.today().addDays(-100));
        String strEndBGDate = String.valueOf(Date.today());
        String strStartBGDate2 = String.valueOf(Date.today().addDays(-100));
        String strEndBGDate2 = String.valueOf(Date.today());
        
        ASI_CRM_CN_PromotionContractCtrl.FindSubBrandList('ASI_MFM_Sub_brand__c', 
                                                              ' WHERE RecordType.DeveloperName = \'ASI_FOC_CN_Sub_brand\'  and ASI_CRM_CN_Sub_brand_Grade__c !=null and  ASI_MFM_Brand__r.ASI_CRM_CN_Competitor__c =FALSE and ASI_MFM_Active_for_CRM__c=TRUE  and ASI_MFM_Sub_brand_Code__c != \'999\'  ', 
                                                  			  Contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                                              Contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, 
                                                              Contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                                              Contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                                                              strStartBGDate,strEndBGDate,strStartBGDate2,strEndBGDate2);

        List<ASI_CRM_CN_Covered_Outlet__c> asiList = new List<ASI_CRM_CN_Covered_Outlet__c>([SELECT 
                                                                                             Id,ASI_CRM_CN_Suggested_Amount__c,
                                                                                             ASI_CRM_CN_Outlet__c 
                                                                                             FROM ASI_CRM_CN_Covered_Outlet__c]);
        PromotionContractCtrl.CoveredOutletValdationChecking(asiList);
        Contract.ASI_CRM_CN_PO_Start_Date__c = null;
        Contract.ASI_CRM_CN_PO_End_Date__c = null;
        update Contract;
        PromotionContractCtrl.HeaderValidationChecking();
        PromotionContractCtrl.getNumberOfCoveredWS();
        PageReference pageRef = new Pagereference('/apex/ASI_CRM_CN_PromotionContractPage');
        Test.setCurrentPage(pageRef);
        PromotionContractCtrl.GoEditHeader();
        PromotionContractCtrl.GoEditDetail();
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest9() {
        test.startTest();
        ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, 
                                           ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c ,
                                           ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                           ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                                           ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c
                                           from ASI_TH_CRM_Contract__c 
                                           where Name = 'Contract4'];
        ApexPages.currentPage().getParameters().put('IsHeaderEdit','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        List<ASI_MFM_Sub_brand__c> subBrandList = [select Id from ASI_MFM_Sub_brand__c];
        String subBrandId = subBrandList[0].Id;

        ASI_MFM_Item_Group__c itemTest = new ASI_MFM_Item_Group__c(Name='TESTONE',ASI_CRM_CN_BT_Size_C__c='10',ASI_MFM_Sub_brand__c=subBrandId);
        insert itemTest;

        ASI_CRM_CN_PromotionContractCtrl.GetPackSizeBySubbrand(subBrandId);
        test.stopTest();
    }
    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest10() {
        test.startTest();

        ASI_TH_CRM_Contract__c Contract = [Select Id,ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        Contract.ASI_TH_CRM_Promotion_Type__c = 'Consumer Promotion';
        update Contract;
        ApexPages.currentPage().getParameters().put('IsHeaderEdit','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        PromotionContractCtrl.Calculation();
        PromotionContractCtrl.init();
        PromotionContractCtrl.ValidationChecking();

        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_PromotionContractCtrlTest11() {
        test.startTest();

        ASI_TH_CRM_Contract__c Contract1 = [Select Id,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ASI_TH_CRM_Contract__c Contract2= [Select Id,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c,ASI_CRM_Copied_From__c from ASI_TH_CRM_Contract__c where Name = 'Contract2'];

        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1).addMonths(2);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        Contract2.ASI_CRM_CN_Group_Contract__c = Contract1.Id;
        update Contract2;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        List<ASI_CRM_AccountsAdditionalField__c> CustomerList = new List<ASI_CRM_AccountsAdditionalField__c>([Select Id,ASI_CRM_CN_CCity__c,ASI_CRM_CN_NewChannel__c,ASI_CRM_Channel_Group__c From ASI_CRM_AccountsAdditionalField__c]);

        ASI_CRM_AccountsAdditionalField__c Customers = new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtOutlet,Name='TESTONE', ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=CustomerList[0].ASI_CRM_CN_CCity__c,ASI_CRM_CN_NewChannel__c=CustomerList[0].ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_BusinessLicenseUploading__c=true, 
            ASI_CRM_CN_Business_License_Expire_date__c=PO_End_Date, ASI_CRM_CN_Business_License_Start_Date__c =PO_Start_Date,ASI_CRM_Channel_Group__c=CustomerList[0].ASI_CRM_Channel_Group__c);
        insert Customers;

        ApexPages.currentPage().getParameters().put('IsHeaderEdit','1');
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract2);  
        ASI_CRM_CN_PromotionContractCtrl PromotionContractCtrl = new ASI_CRM_CN_PromotionContractCtrl(stdController);
        PromotionContractCtrl.HeaderValidationChecking();
        //PromotionContractCtrl.UpdateBRSFItemMap();
        PromotionContractCtrl.checkOutlet(Customers.Id);

        test.stopTest();
    }
}