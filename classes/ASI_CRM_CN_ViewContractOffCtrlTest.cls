/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_ViewContractOffCtrlTest
 * Description: Test class for ASI_CRM_CN_ViewContractOffCtrl and ASI_CRM_CN_HeavyContractOff_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-12-17       Keith Yip               Created
 ****************************************************************************************************************************/
@isTest
public class ASI_CRM_CN_ViewContractOffCtrlTest {
	
    @testSetup static void setup() {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(
            Name = 'OFF MOT',
            ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Code__c = 'CN_OFF MOT',
            ASI_CRM_External_ID__c = 'CN_OFF MOT',
            ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
    	List<ASI_CRM_AccountsAdditionalField__c> Customers = new List<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Premium',
                RecordTypeId = rtOutlet, Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = channel.Id,
                ASI_CRM_Channel_Group__c = ChannelGroup.Id
                )
        );
        Customers.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Premium',
                RecordTypeId = rtWS, Name = 'TEST-2',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = channel.Id,
                ASI_CRM_Channel_Group__c = ChannelGroup.Id
                )
        );
        insert Customers;
        
        User currentUser = [SELECT Id, Name, ManagerId, ASI_CRM_CN_Prefix__c FROM User WHERE Id =:UserInfo.getUserId()];
            
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1,ASI_CRM_CN_Dolphin_Online_Cont_Threshold__c=100000,ASI_CRM_CN_Dolphin_POModi_Threshold__c=120,ASI_CRM_CN_Dolphin_PO_Default_Markup__c=2,ASI_CRM_CN_Dolphin_PO_Default_Guideline__c=2);
        insert CustomSetting ;

        List<ASI_HK_CRM_Running_Number__c> rns = new List<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> LUser = new List<User>();
        LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ManagerId=UserInfo.getUserId(),
                           LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',
                           TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
        insert LUser[0];
        
        List<User> userList= new List<User> ();
        userList.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, ManagerId = LUser[0].Id,
                           TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c3@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        insert userList;

        List<ASI_CRM_Contract_Cost_Setting__c> contractCostSettings = new List<ASI_CRM_Contract_Cost_Setting__c>();
        ASI_CRM_Contract_Cost_Setting__c PSFContractCostSetting = new ASI_CRM_Contract_Cost_Setting__c(
            Name = 'PRC - PSF & Trading term incentives',
            ASI_CRM_CN_Chinese_Description__c = '空瓶回收费',
            ASI_CRM_CN_Promotion_Type__c = 'TOT/MOT Contract',
            ASI_CRM_CN_Channel__c = 'OFF MOT',
            ASI_CRM_CN_Sequence__c = 1,
            ASI_CRM_PSF_Activity_Code_Default__c = true
        );
        ASI_CRM_Contract_Cost_Setting__c OtherContractCostSetting = new ASI_CRM_Contract_Cost_Setting__c(
            Name = 'PRC - Data Sharing',
            ASI_CRM_CN_Chinese_Description__c = '数据分享扣点',
            ASI_CRM_CN_Promotion_Type__c = 'TOT/MOT Contract',
            ASI_CRM_CN_Channel__c = 'OFF MOT',
            ASI_CRM_CN_Sequence__c = 9,
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            ASI_CRM_CN_Fixed_Cost_Contract__c = true
        );

        contractCostSettings.add(PSFContractCostSetting);
        contractCostSettings.add(OtherContractCostSetting);
        insert contractCostSettings;

        List<ASI_CRM_Fix_Approval_Route__c> approvalRoutes = new List<ASI_CRM_Fix_Approval_Route__c>();
        approvalRoutes.add(new ASI_CRM_Fix_Approval_Route__c(
            ASI_CRM_Sales_Team__c = 'a',
            ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_6__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_7__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_8__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_9__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_10__c = userList[1].Id,
            ASI_CRM_RVP__c= userList[1].Id,
            ASI_CRM_CN_Regional_BA__c= UserInfo.getUserId(),
            ASI_CRM_CN_Approval_Limit_1__c = -999999,
            ASI_CRM_CN_Approval_Limit_2__c = -999999,
            ASI_CRM_CN_Approval_Limit_3__c = -999999,
            ASI_CRM_CN_Approval_Limit_4__c = -999999,
            ASI_CRM_CN_Approval_Limit_5__c = -999999,
            ASI_CRM_CN_Approval_Limit_6__c = -999999,
            ASI_CRM_CN_Approval_Limit_7__c = -999999,
            ASI_CRM_CN_Approval_Limit_8__c = -999999,
            ASI_CRM_CN_Approval_Limit_9__c = -999999,
            ASI_CRM_CN_Approval_Limit_10__c = -999999,
            ASI_CRM_CN_Type__c = 'TOT/MOT Contract',
            ASI_CRM_CN_Entry_Limit__c=-999999
        )
        );
        insert approvalRoutes;


        Date PO_Start_Date = Date.newInstance(System.today().year(), System.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
    	ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_RVP_Approval__c = true,
                                                                     OwnerId = userList[0].Id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;

        ASI_TH_CRM_Contract__c ContractFalse =  new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_RVP_Approval__c = false,
                                                                     OwnerId = userList[0].Id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addYears(-2),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addYears(-2),
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'Contractfalse',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert ContractFalse;

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

        ASI_TH_CRM_Contract__c TestContract3 = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_RVP_Approval__c = true,
                                                                     OwnerId = userList[0].Id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addYears(2),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addYears(2),
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'ContractTest3',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Is_Dolphin__c = true,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert TestContract3;

        ASI_TH_CRM_Contract__c TestContract2 = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_RVP_Approval__c = true,
                                                                     OwnerId = userList[0].Id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addYears(3),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addYears(3),
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'ContractTest2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Is_Dolphin__c = true,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert TestContract2;

        Attachment cAtt = new Attachment();
        cAtt.ParentId = Contract.Id; 
        cAtt.name = 'Teste';
        cAtt.Body = Blob.valueof( 'asdasd' );
        insert cAtt;

        ASI_CRM_Contract_Cost__c cost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = TestContract.Id,       
        ASI_CRM_CN_Estimate_Amount__c = 2,ASI_CRM_CN_Cost_Type__c= 'Fixed',ASI_CRM_CN_Contract_Amount__c=1,ASI_CRM_CN_Contract_Amount_Rate__c = 2.1,ASI_CRM_CN_Estimate_Amount_Rate__c=2.2);
        insert cost;
        System.debug('Limits.getQueries() ' + Limits.getQueries());

        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Ladder)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Per Incentive Btl',ASI_CRM_CN_KPI_Base__c='Volume base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 1234',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        
        
        //MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Reach X get Y',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Tax)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        insert MethodologyList;
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id,ASI_CRM_CN_New_Channel__c=channel.Id));
        //MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        //MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Display'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='RMB',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='Display'));
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
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=TestContract3.Id,ASI_CRM_Line_Type__c = 'BRSF',ASI_CRM_CN_Volume_Value_Base__c = 'Value',ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan',ASI_CRM_CN_Total_Markup__c = customSetting.ASI_CRM_CN_Dolphin_PO_Default_Markup__c,ASI_CRM_Remark__c='Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Module__cASI_CRM_CN_Contract')));
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
        /*ASI_CRM_Contract_Cost_Setting__c ccs2 = new ASI_CRM_Contract_Cost_Setting__c(
            ASI_CRM_CN_Promotion_Type__c='TOT/MOT Dolphin Contract',
            ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
            ASI_CRM_CN_BRSF_Activity_Code_Default__c =true,
            ASI_CRM_PSF_Activity_Code_Default__c = true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,
            ASI_CRM_CN_Variable_Cost_Contract__c=true);
        insert ccs2;
        ASI_TH_CRM_Contract__c TestContract5 = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_RVP_Approval__c = true,
                                                                     OwnerId = userList[0].Id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addYears(5),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addYears(5),
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'ContractTest5',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_CN_Is_Dolphin__c = true,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert TestContract5;*/
        ASI_CRM_CN_Contract_BRSF_Line_Item__c FirstPSFLINE = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c = TestContract.Id,
            ASI_CRM_Module__c = ModuleList[8].id,
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
            ASI_CRM_Module__c = ModuleList[9].id,
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
        
        //Sub Brand Grade
        List<ASI_CRM_Sub_Brand_Grade__c> grades = new List<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        List<ASI_MFM_Sub_brand__c> subBrands = new List<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> cos = new List<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
                ASI_CRM_CN_Contract__c=Contract.Id,
                ASI_CRM_CN_Outlet__c=Customers[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = Contract.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c = 1, ASI_CRM_Module__c = ModuleList[1].Id,
                ASI_CRM_CN_Contract_Monthly_Qty__c = 1, ASI_CRM_Volume_Base__c = 'By Sub-Brand',
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 10, ASI_CRM_Type__c = 'PSF',
                ASI_CRM_CN_Est_Total_Dummy__c = 100, ASI_CRM_CN_Contract_Total_Dummy__c = 100,
                ASI_CRM_CN_Sub_Brand__c = subBrand.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=TestContract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[7].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=50000,ASI_CRM_CN_Contract_Total_Dummy__c=40000,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=TestContract3.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[10].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=50000,ASI_CRM_CN_Contract_Total_Dummy__c=40000,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,ASI_CRM_Contract_Total_QTY_std_Btl__c = 0,
                                                                           ASI_CRM_Est_Total_QTY_std_Btl__c = 0,ASI_CRM_Sub_Brand_Grade__c=grades[0].id,
                                                                           ASI_CRM_CN_Activity_Code__c=ccs.ASI_CRM_CN_Activity_Code__c,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = Contract.Id, ASI_CRM_Type__c = 'PSF', ASI_CRM_Volume_Base__c = 'By Total',
            ASI_CRM_CN_Est_Monthly_Qty__c = 1, ASI_CRM_Module__c = ModuleList[3].Id,
            ASI_CRM_CN_Contract_Monthly_Qty__c = 1, ASI_CRM_CN_Est_Total_Dummy__c = 100, ASI_CRM_CN_Contract_Total_Dummy__c = 100,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 10,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 10,
            ASI_CRM_CN_Sub_Brand__c = null,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = Contract.Id, ASI_CRM_Type__c = 'Display', ASI_CRM_Volume_Base__c = 'By Total',
            ASI_CRM_CN_Est_Monthly_Qty__c = 1, ASI_CRM_Module__c = ModuleList[4].Id,
            ASI_CRM_CN_Contract_Monthly_Qty__c = 1, ASI_CRM_CN_Est_Total_Dummy__c = 100, ASI_CRM_CN_Contract_Total_Dummy__c = 100,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 10,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 10,
            ASI_CRM_CN_Sub_Brand__c = null,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
                                                                       
                                                                       
        insert ContractLineList;

        Date PO_Start_Date2 = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(2);
        Date PO_End_Date2 = PO_Start_Date2.addMonths(1)-1;

        Test.startTest();
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Archived',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2,
                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,
                                                               ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract2',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;

        List<ASI_TH_CRM_Contract__c> contracts = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c Contract3 = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Draft',
                                                                ASI_CRM_RVP_Approval__c = false,
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2,
                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract3',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        contracts.add(Contract3);
        
        ASI_TH_CRM_Contract__c Contract4 = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Final',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2.addMonths(3),
                                                               ASI_CRM_CN_PO_End_Date__c =PO_Start_Date2.addMonths(4)-1 ,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract4',
                                                               ASI_CRM_Last_RBA_Approver__c = UserInfo.getUserId(),
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        contracts.add(Contract4);
        insert contracts;

        List<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new List<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract4.Id,
                                                                ASI_CRM_CN_OutletWS__c=Customers[0].Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=System.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=System.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Submitted',
                                                                ASI_CRM_CN_Return_Comments__c='a', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract4.Id,
                                                                ASI_CRM_CN_OutletWS__c=Customers[0].Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=false,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=System.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=System.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Submitted',
                                                                ASI_CRM_CN_Return_Comments__c='a', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert PaymentRequestList;

        Test.stopTest();

    }
    
    static testMethod void ASI_CRM_CN_ViewContractOffCtrlTest() {
        Test.startTest();

        ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(Contract);
        ASI_CRM_CN_ViewContractOffCtrl ViewContractOffCtrl = new ASI_CRM_CN_ViewContractOffCtrl(stdController);


    	ViewContractOffCtrl.GoEditHeaderPage();
    	ViewContractOffCtrl.submitForApproval();
    	ViewContractOffCtrl.GoCheckPointPage();
    	ViewContractOffCtrl.ViewCheckPointPage();
    	ViewContractOffCtrl.GoEditDetailPage();
    	ViewContractOffCtrl.GoUploadPage();
    	Integer TestNumberOfCoveredOutlets = ViewContractOffCtrl.getNumberOfCoveredOutlets();
    	
    	ViewContractOffCtrl.GoPayment();
    	ViewContractOffCtrl.UploadCompletion();
    	ViewContractOffCtrl.UncheckContractUploading();
    	ViewContractOffCtrl.SetToDraft();
        
    	ViewContractOffCtrl.SetToFinal();
        
    	ViewContractOffCtrl.GoReturn();
    	ViewContractOffCtrl.ErrorHandling('Test');
    	ViewContractOffCtrl.newCounterCreatorLine();
        ViewContractOffCtrl.CancelProcess();
        


        //For Final Status Contract
        //For payment request
        ViewContractOffCtrl.ContractSelected = [Select Id, 
    	                                               ASI_CRM_CN_Status__c,
    	                                               OwnerId,
    	                                               ASI_CRM_System_Debug__c,
    	                                               ASI_CRM_CN_PO_Start_Date__c,
    	                                               ASI_CRM_CN_PO_End_Date__c,
    	                                               ASI_CRM_CN_PO_Version__c,
    	                                               ASI_TH_CRM_Promotion_Type__c,
    	                                               Name,
    	                                               ASI_CRM_CN_Outlet_WS__c,
    	                                               ASI_CRM_Volume_Option__c,
    	                                               LastModifiedDate,
    	                                               ASI_CRM_CN_Last_PO_version__c,
                                                       (SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
            												   ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
                                                        FROM ASI_TH_CRM_PaymentRequests_Contract__r)
    	                                        From  ASI_TH_CRM_Contract__c
    	                                        where Name = 'Contract4'];
        ViewContractOffCtrl.POModification();
        ViewContractOffCtrl.GoPayment();
        
        for(ASI_TH_CRM_PaymentRequest__c paymentrequest:ViewContractOffCtrl.ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {
            paymentrequest.ASI_CRM_CN_Last_Payment__c = false;
        }
        ViewContractOffCtrl.GoPayment();
                      
        
        Test.stopTest();
        
    }

    static testMethod void testContractModiDraft() {
        Test.startTest();

        ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract3'];
        ApexPages.currentPage().getParameters().put('id', Contract.Id);
        ASI_CRM_CN_ViewContractOffCtrl ViewContractOffCtrl = new ASI_CRM_CN_ViewContractOffCtrl(new ApexPages.StandardController(Contract));

        ViewContractOffCtrl.restorePO();
        ViewContractOffCtrl.POModification();

        //Run if ASI_CRM_System_Debug__c = true
        ViewContractOffCtrl.ContractSelected.ASI_CRM_System_Debug__c = true;
        ViewContractOffCtrl.Calculation();
        Test.stopTest();
    }

    static testMethod void ASI_CRM_CN_ViewContractOffCtrlTest2() {
        Test.startTest();

        ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract4'];             
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(Contract);
        ASI_CRM_CN_ViewContractOffCtrl ViewContractOffCtrl = new ASI_CRM_CN_ViewContractOffCtrl(stdController); 
        
        //For no payment request Contract

        ViewContractOffCtrl.POModification();
        ViewContractOffCtrl.restorePO();
        ViewContractOffCtrl.SetToFinal();
        ViewContractOffCtrl.UploadCompletion();
        ViewContractOffCtrl.ContractSelected.ASI_CRM_CN_PO_Version__c ='0.1';
        ViewContractOffCtrl.Calculation();

        Test.stopTest();
    }

    static testMethod void ASI_CRM_CN_HeavyContractOff_TriggerClassTest(){
        Test.startTest();

        List<ASI_TH_CRM_Contract__c> contracts = [SELECT Id, ASI_CRM_CN_Status__c, ASI_CRM_RVP_Approval__c, ASI_CRM_CN_Return_Flag__c from ASI_TH_CRM_Contract__c WHERE Name = 'Contract1'];

        contracts[0].ASI_CRM_CN_Status__c = 'Draft';
        contracts[0].ASI_CRM_RVP_Approval__c = false;
        contracts[0].ASI_CRM_CN_Return_Flag__c = false;

        System.debug('ASI_CRM_CN_HeavyContractOff_TriggerClassTest going to update!');

        update contracts[0];


        for (Integer i = 0; i <= 10; i++) {
            ASI_CRM_CN_HeavyContractOff_TriggerClass.setReturnApproverByCount(contracts[0], i, UserInfo.getUserId());
        }
        Test.stopTest();

    }

    static testMethod void ASI_CRM_CN_HeavyContractOff_TriggerClassTest2(){
        Test.startTest();

        List<ASI_TH_CRM_Contract__c> contracts = [SELECT Id, ASI_CRM_CN_Status__c, ASI_CRM_RVP_Approval__c, ASI_CRM_CN_Return_Flag__c from ASI_TH_CRM_Contract__c WHERE Name = 'ContractFalse'];

        contracts[0].ASI_CRM_CN_Status__c = 'Draft';
        contracts[0].ASI_CRM_RVP_Approval__c = true;

        System.debug('ASI_CRM_CN_HeavyContractOff_TriggerClassTest2 going to update!');


        update contracts[0];


        Test.stopTest();
    }

    static testMethod void ASI_CRM_CN_ContractOffUtilClassTest(){
        ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'ContractTest2'];
        ASI_CRM_CN_ContractOffUtilClass.calculateRebatePercentByLadder(0, 1000, 200, 8, true, 1000);
        ASI_CRM_CN_ContractOffUtilClass.calculateRebatePercentByLadder(500, 1000, 200, 8, true, 1000);

        Map<String, Decimal> a = new Map<String, Decimal>{'a' => 1, 'b' =>2, 'c' =>3, 'd' =>4};
        Map<String, Decimal> b = new Map<String, Decimal>{'a' => 1, 'b' =>3, 'c' =>2};
        ASI_CRM_CN_ContractOffUtilClass.compareMap(a, b, 'Equal to');
        ASI_CRM_CN_ContractOffUtilClass.compareMap(a, b, 'Greater than');
        ASI_CRM_CN_ContractOffUtilClass.compareMap(a, b, 'Greater than or Equal to');
        ASI_CRM_CN_ContractOffUtilClass.compareMap(a, b, 'Less than');
        ASI_CRM_CN_ContractOffUtilClass.compareMap(a, b, 'Less than or Equal to');
        ASI_CRM_CN_ContractOffUtilClass.compareMap(a, a, 'Equal to');
        test.startTest();
        insert ASI_CRM_CN_ContractOffUtilClass.GeneratingVolumeValueTargetLine(Contract);
        test.stopTest();
    }
    static testMethod void ASI_CRM_CN_ContractOffUtilClassGroupPOTest(){
        ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'ContractTest2'];
        ASI_TH_CRM_Contract__c Contract1 = [Select Id from ASI_TH_CRM_Contract__c where Name = 'ContractTest3'];
        test.startTest();
        Contract.ASI_CRM_CN_Group_Contract__c = Contract1.Id;
        update Contract;
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lineItemList = ASI_CRM_CN_ContractOffUtilClass.GeneratingVolumeValueTargetLine(Contract);
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : lineItemList){
            System.debug(LoggingLevel.INFO, '*** Global_RecordTypeCache: ');
            System.debug(LoggingLevel.INFO, '*** lineItemList.recordTypeid: ' + lineItem.recordTypeid);
            System.debug(LoggingLevel.INFO, '*** Global_RecordTypeCache.getRt(lineItemList.recordTypeid): ' + Global_RecordTypeCache.getRt(lineItem.recordTypeid));
        }
        //insert ASI_CRM_CN_ContractOffUtilClass.GeneratingVolumeValueTargetLine(Contract);
        insert lineItemList;
        test.stopTest();
    }


    static testMethod void ASI_CRM_CN_ViewDolphinContractOffCtrlTest() {
        Test.startTest();
        ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'ContractTest'];
        Contract.ASI_CRM_CN_Is_Dolphin__c = true;
        update Contract;
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(Contract);
        ASI_CRM_CN_ViewContractOffCtrl ViewContractOffCtrl = new ASI_CRM_CN_ViewContractOffCtrl(stdController);
        //ViewContractOffCtrl.GoToContractGenerationPage();
        Test.stopTest();
    }
}