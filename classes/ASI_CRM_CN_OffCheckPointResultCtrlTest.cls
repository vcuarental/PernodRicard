/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffCheckPointResultCtrlTest 
 * Description: Test class for ASI_CRM_CN_OffCheckPointResultCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-12-31       Keith Yip               Created
 ****************************************************************************************************************************/
 @isTest
public class ASI_CRM_CN_OffCheckPointResultCtrlTest {
    
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
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
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
        /*SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Total PO', ASI_CRM_2nd_Dimension__c='New Contact V0.0 Contract',ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.', ASI_CRM_Operation__c ='Less than or Equal to',
                                                                         Name='Test7',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );   */                                                                                                                                                                                                                                                                                                                 
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2', ASI_CRM_CN_Channel_Group__c =ChannelGroup.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Total Rate', ASI_CRM_2nd_Dimension__c='Theoretical Value',ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract', ASI_CRM_Operation__c ='Less than or Equal to',ASI_CRM_Alignment_Value__c=2,
                                                                         Name='Test7',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract')) );                                                                                                                                                                                                                                                       
        insert SegmentationCriteriaList;
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        insert MethodologyList;
        
        Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1,ASI_CRM_CN_Dolphin_POModi_Threshold__c =10,ASI_CRM_CN_Dolphin_Online_Cont_Threshold__c=1);
        insert CustomSetting ;
        
        //Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
    	list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_BusinessLicenseUploading__c=true, ASI_CRM_CN_Business_License_Expire_date__c=PO_End_Date, ASI_CRM_CN_Business_License_Start_Date__c =PO_Start_Date, ASI_CRM_Channel_Group__c=ChannelGroup.Id));
        insert Customers;
        
        //System.debug([Select Id, ASI_CRM_Channel_Group__c from ASI_CRM_AccountsAdditionalField__c where Id = :Customers[0].Id].ASI_CRM_Channel_Group__c);
        
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
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
        
    	//Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
    	//Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
    	ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        ASI_TH_CRM_Contract__c TestContract = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_RVP_Approval__c = true,
                                                                     OwnerId = userList[0].Id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addYears(1),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addYears(1),
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'ContractTest',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Is_Dolphin__c = true,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert TestContract;
        
        List<ASI_CRM_Methodology__c> MethodologyList2= new List<ASI_CRM_Methodology__c> ();
        MethodologyList2.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Ladder)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList2.add(new ASI_CRM_Methodology__c(Name='Per Incentive Btl',ASI_CRM_CN_KPI_Base__c='Volume base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList2.add(new ASI_CRM_Methodology__c(Name='Rebate%',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 1234',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        
        
        //MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList2.add(new ASI_CRM_Methodology__c(Name='Reach X get Y',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList2.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Tax)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        insert MethodologyList2;
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList2 = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList2.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList2[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList2.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList2[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList2.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList2[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList2.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList2[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList2.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList2[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        //MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        //MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList2;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Display'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=TestContract.Id,ASI_CRM_Line_Type__c = 'BRSF',ASI_CRM_CN_Volume_Value_Base__c = 'Value',ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan',ASI_CRM_CN_Total_Markup__c = customSetting.ASI_CRM_CN_Dolphin_PO_Default_Markup__c));
        ModuleList.add(new ASI_CRM_Module__c(
                ASI_CRM_Line_Type__c = 'PSF',
                ASI_CRM_Contract__c = TestContract.Id,
                ASI_CRM_Created_PO_Version__c = '0.0',
                ASI_CRM_CN_Volume_Value_Base__c = 'Value',
                ASI_CRM_CN_KPI_Base__c = 'Value base',
                ASI_CRM_CN_Minimal_Achievement__c = 0,
                ASI_CRM_Methodology__c = MethodologyList[2].Id,
                ASI_CRM_Volume_Base__c = 'By Total',
                ASI_CRM_Unit__c = 'RMB'));
        ModuleList.add(new ASI_CRM_Module__c(
                ASI_CRM_Line_Type__c = 'PSF',
                ASI_CRM_Contract__c = TestContract.Id,
                ASI_CRM_Created_PO_Version__c = '0.0',
                ASI_CRM_CN_Volume_Value_Base__c = 'Value',
                ASI_CRM_CN_KPI_Base__c = 'Value base',
                ASI_CRM_CN_Minimal_Achievement__c = 0,
                ASI_CRM_Methodology__c = MethodologyList[2].Id,
                ASI_CRM_Volume_Base__c = 'By Total',
                ASI_CRM_Unit__c = 'RMB'
            ));
        insert ModuleList;
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;

        ASI_CRM_Contract_Cost_Setting__c ccs = new ASI_CRM_Contract_Cost_Setting__c(
            ASI_CRM_CN_Promotion_Type__c='TOT/MOT Contract',
            ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
            ASI_CRM_CN_BRSF_Activity_Code_Default__c =true,
            ASI_CRM_PSF_Activity_Code_Default__c = true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,
            ASI_CRM_CN_Variable_Cost_Contract__c=true);
        insert ccs;
        ASI_CRM_CN_Contract_BRSF_Line_Item__c FirstPSFLINE = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c = TestContract.Id,
            ASI_CRM_Module__c = ModuleList[6].id,
            ASI_CRM_CN_Activity_Code__c = ccs.ASI_CRM_CN_Activity_Code__c,
            ASI_CRM_Type__c = 'PSF',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF'),
            ASI_CRM_CN_Contract_Monthly_Qty__c = 0,
            ASI_CRM_CN_Est_Monthly_Qty__c = 0,
            ASI_CRM_Contract_Total_QTY_std_Btl__c = 0,
            ASI_CRM_Est_Total_QTY_std_Btl__c = 0,
            ASI_CRM_CN_Contract_Total_Dummy__c = 100000,
            ASI_CRM_CN_Est_Total_Dummy__c = 100000,
            ASI_CRM_Volume_Base__c = 'Value Base',
            ASI_CRM_CN_Contract_Purchase_Value__c = 440000.11,
            ASI_CRM_CN_Estimate_Purchase_Value__c = 550000.11,
            ASI_CRM_CN_Rebate_Percent__c = 1
        );
        insert FirstPSFLINE;
        
        ASI_CRM_CN_Contract_BRSF_Line_Item__c SecondPSFLINE = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c = TestContract.Id,
            ASI_CRM_Module__c = ModuleList[7].id,
            ASI_CRM_CN_Activity_Code__c = ccs.ASI_CRM_CN_Activity_Code__c,
            ASI_CRM_Type__c = 'PSF',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF'),
            ASI_CRM_CN_Contract_Monthly_Qty__c = 0,
            ASI_CRM_CN_Est_Monthly_Qty__c = 0,
            ASI_CRM_Contract_Total_QTY_std_Btl__c = 0,
            ASI_CRM_Est_Total_QTY_std_Btl__c = 0,
            ASI_CRM_CN_Contract_Total_Dummy__c = 120000,
            ASI_CRM_CN_Est_Total_Dummy__c = 200000,
            ASI_CRM_Volume_Base__c = 'Value Base',
            ASI_CRM_CN_Contract_Purchase_Value__c = 440000.11,
            ASI_CRM_CN_Estimate_Purchase_Value__c = 550000.11,
            ASI_CRM_CN_Rebate_Percent__c = 0.5
        );
        insert SecondPSFLINE;
                   
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
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
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
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
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }                                                                
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=TestContract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=50000,ASI_CRM_CN_Contract_Total_Dummy__c=40000,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }                                                               
                                                                       
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Display',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
                                                                       
                                                                       
        insert ContractLineList;
        
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>(); 
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        insert cos;
                    
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Contract__c = Contract.Id,                                                                                                                                                                 
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
        costs.add(new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = TestContract.Id,       
        ASI_CRM_CN_Estimate_Amount__c = 2,ASI_CRM_CN_Cost_Type__c= 'Fixed',ASI_CRM_CN_Contract_Amount__c=1,ASI_CRM_CN_Contract_Amount_Rate__c = 2.1,ASI_CRM_CN_Estimate_Amount_Rate__c=2.2));
        insert costs;
        
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        test.stopTest();
         
        Date PO_Start_Date2 = date.newinstance(system.today().year(), system.today().month(), 1).addMonths(2);
        Date PO_End_Date2 = PO_Start_Date2.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Archived',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2,
                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,
                                                               ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract2',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;
        
        ASI_TH_CRM_Contract__c Contract3 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Final',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2,
                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract3',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract3;   
        
        ASI_TH_CRM_Contract__c Contract4 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Archived',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2.addMonths(3),
                                                               ASI_CRM_CN_PO_End_Date__c =PO_Start_Date2.addMonths(4)-1 ,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract4',
                                                               ASI_CRM_Last_RBA_Approver__c = UserInfo.getUserId(),
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract4;
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';       
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment2);

        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"Value":0.0,"TradeExpenses":0.0,"SubBrandGSPercentageMap":{},"SubBrandGSMap":{},"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"SubBrandAPMap":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","PSFLineMap":{},"PSFExpensesTotal":0.0,"POStartDate":"2020-11-01","POEndDate":"2020-11-30","OutletSet":[],"OtherExpensesTotal":0.0,"OtherExpensesRate":0,"OtherExpensesMap":{},"NoOfMonths":1,"MarginPerBottle":0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0456778478910660909996678844237795,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0,"DolphinContractPercent":0.0,"DisplayVolumeBase":"","DisplayMethodologyName":"","DisplayExpensesTotal":0.0,"DisplayExpensesRate":0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryVolumeMap":{},"CategoryValueMap":{},"CategoryGSMap":{},"BRSFMethodologyName":"","BrandVolumeMap":{},"BrandValueMap":{},"AddOnString":"{}"}]';
        AttachmentList.add(Attachment3);

        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='PO Modification Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment4.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"Value":0.0,"TradeExpenses":0.0,"SubBrandGSPercentageMap":{},"SubBrandGSMap":{},"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"SubBrandAPMap":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","PSFLineMap":{},"PSFExpensesTotal":0.0,"POStartDate":"2020-11-01","POEndDate":"2020-11-30","OutletSet":[],"OtherExpensesTotal":0.0,"OtherExpensesRate":0,"OtherExpensesMap":{},"NoOfMonths":1,"MarginPerBottle":0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0456778478910660909996678844237795,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0,"DolphinContractPercent":0.0,"DisplayVolumeBase":"","DisplayMethodologyName":"","DisplayExpensesTotal":0.0,"DisplayExpensesRate":0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryVolumeMap":{},"CategoryValueMap":{},"CategoryGSMap":{},"BRSFMethodologyName":"","BrandVolumeMap":{},"BrandValueMap":{},"AddOnString":"{}"}]';
        AttachmentList.add(Attachment4);

        ASI_Attachment__c Attachment5=new ASI_Attachment__c (ASI_CRM_Contract__c=TestContract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment5.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"DolphinContractPercent":0.0,"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment5);

        /*ASI_Attachment__c Attachment6=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment6.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';       
        AttachmentList.add(Attachment6);
        
        ASI_Attachment__c Attachment7=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment7.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment7);*/
        
        /*ASI_Attachment__c Attachment6=new ASI_Attachment__c (ASI_CRM_Contract__c=TestContract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment6.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"DolphinContractPercent":0.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment6);*/
              
       /*ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';       
        AttachmentList.add(Attachment3);
        
        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment4.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment4);*/
        
        /*ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment3);*/
        
        /*ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='PO Modification Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment4.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment4);
        
        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment3);*/
                                    
        insert AttachmentList; 
        
        
        
        
        //test.stopTest();
     }
     
     static testMethod void ASI_CRM_CN_OffCheckPointResultCtrlTest() {	
     	test.startTest();
		ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_OffCheckPointResultCtrl OffCheckPointResultCtrl = new ASI_CRM_CN_OffCheckPointResultCtrl(stdController);	
        OffCheckPointResultCtrl.CancelProcess();
        OffCheckPointResultCtrl.proceed();
        
        Contract.ASI_CRM_CN_PO_Version__c= '0.0';
        Contract.ASI_CRM_CN_PO_Modification__c = true;
        update Contract;
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ASI_CRM_CN_OffCheckPointResultCtrl OffCheckPointResultCtrl2 = new ASI_CRM_CN_OffCheckPointResultCtrl(stdController);	
        OffCheckPointResultCtrl2.proceed(); 
        
        ASI_TH_CRM_Contract__c Contract4 = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c from ASI_TH_CRM_Contract__c where Name = 'Contract4'];  
        ApexPages.currentPage().getParameters().put('id',Contract4.Id);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(Contract4);
        ASI_CRM_CN_OffCheckPointResultCtrl OffCheckPointResultCtrl3 = new ASI_CRM_CN_OffCheckPointResultCtrl(stdController2);	
             
		test.stopTest();
     }

     static testMethod void ASI_CRM_CN_OffCheckPointResultCtrlTest2() {  
        test.startTest();
        ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Modification__c from ASI_TH_CRM_Contract__c where Name = 'ContractTest'];
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_OffCheckPointResultCtrl OffCheckPointResultCtrl = new ASI_CRM_CN_OffCheckPointResultCtrl(stdController); 
        OffCheckPointResultCtrl.CancelProcess();
        OffCheckPointResultCtrl.proceed();
        
        test.stopTest();
     }

}