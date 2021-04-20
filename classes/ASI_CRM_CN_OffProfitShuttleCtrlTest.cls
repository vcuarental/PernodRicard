/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffProfitShuttleCtrlTest 
 * Description: Test class for ASI_CRM_CN_OffProfitShuttleCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-12-19       Keith Yip               Created
 ****************************************************************************************************************************/
@isTest
public with sharing class ASI_CRM_CN_OffProfitShuttleCtrlTest {
	
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
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test');
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE,ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        //Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
    	list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id,ASI_CRM_Channel_Group__c=ChannelGroup.Id));
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
        
    	Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
    	ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        //MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Ladder)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Per Incentive Btl',ASI_CRM_CN_KPI_Base__c='Volume base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Reach X get Y',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Rebate%(By Tax)',ASI_CRM_CN_KPI_Base__c='Value base', ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology_TOT_MOT_Contract')));
        insert MethodologyList;
        
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
        
        List<ASI_CRM_Subbrand_Volume__c> SubBrandVolumeList= new  List<ASI_CRM_Subbrand_Volume__c>();
        //Date TodayDateBefore3= system.today().addMonths(-5);
        
        ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrands[0].Id,
                                                                               ASI_CRM_End_Date__c=PO_End_Date,
                                                                               ASI_CRM_Month__c=string.valueOf(PO_End_Date.month()),
                                                                               ASI_CRM_Year__c=string.valueOf(PO_End_Date.year()));
        SubBrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
        insert SubBrandVolumeList;
        
         List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Display'));
        
        insert ModuleList;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
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
        
        test.stopTest();
        
        Date PO_Start_Date2 = date.newinstance(system.today().year(), system.today().month(), 1).addMonths(-3);
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
                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_V0_0_PO_version__c=Contract.Id,ASI_CRM_CN_Last_PO_version__c=Contract.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract3',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract3; 
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
                
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Group Contract Data',ASI_CRM_For_Contract_Use__c=true);
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract3.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);   
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"Value":0.0,"TradeExpenses":0.0,"SubBrandGSPercentageMap":{},"SubBrandGSMap":{},"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"SubBrandAPMap":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","PSFLineMap":{},"PSFExpensesTotal":0.0,"POStartDate":"2020-10-26","POEndDate":"2020-10-26","OutletSet":[],"OtherExpensesTotal":0.0,"OtherExpensesRate":0,"OtherExpensesMap":{},"NoOfMonths":1,"MarginPerBottle":0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0,"DisplayVolumeBase":"","DisplayMethodologyName":"","DisplayExpensesTotal":0.0,"DisplayExpensesRate":0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryVolumeMap":{},"CategoryValueMap":{},"CategoryGSMap":{},"BRSFMethodologyName":"","BrandVolumeMap":{},"BrandValueMap":{},"AddOnString":""},{"Volumes":0.0,"Value":0.0,"TradeExpenses":0.0,"SubBrandGSPercentageMap":{},"SubBrandGSMap":{},"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"SubBrandAPMap":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","PSFLineMap":{},"PSFExpensesTotal":0.0,"POStartDate":"2020-10-26","POEndDate":"2020-10-26","OutletSet":[],"OtherExpensesTotal":0.0,"OtherExpensesRate":0,"OtherExpensesMap":{},"NoOfMonths":1,"MarginPerBottle":0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0,"DisplayVolumeBase":"","DisplayMethodologyName":"","DisplayExpensesTotal":0.0,"DisplayExpensesRate":0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryVolumeMap":{},"CategoryValueMap":{},"CategoryGSMap":{},"BRSFMethodologyName":"","BrandVolumeMap":{},"BrandValueMap":{},"AddOnString":"{}"}]';
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":2380.000002,"Value":3191.66,"TradeExpenses":2060.00,"SubBrandGSPercentageMap":{},"SubBrandGSMap":{"a7FM00000008S5DMAU":0.000000,"a7FM00000008XqNMAU":0.000000},"SubBrandGradeMap":{"1. Standard + Premium 标准档 + 高档":46.200000,"3. Ultra Premium 特级高档":2333.800002},"SubBrandGradeGrouping":{"Standard":46.200000,"Ultra Premium":2333.800002},"SubBrandAPMap":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","PSFLineMap":{},"PSFExpensesTotal":0.0,"POStartDate":"2019-07-01","POEndDate":"2019-12-31","OutletSet":[],"OtherExpensesTotal":2060.00,"OtherExpensesRate":100.00,"OtherExpensesMap":{},"NoOfMonths":6,"MarginPerBottle":-0.07,"MarginAfterAnP":-2060.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.07,"IntakeSTD":30600,"IntakeCR12":30303.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRate":0,"DisplayVolumeBase":"","DisplayMethodologyName":"","DisplayExpensesTotal":0.0,"DisplayExpensesRate":0.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000005mVLIAY","CMTotal":0.0,"CMId":" ","CategoryVolumeMap":{"Whisky":46.200000,"Brandy":2333.800002},"CategoryValueMap":{"Whisky":58.46,"Brandy":3133.20},"CategoryGSMap":{"Whisky":0,"Brandy":0},"BRSFMethodologyName":"","BrandVolumeMap":{"Chivas Regal-CHI":46.200000,"Martell-MAR":2333.800002},"BrandValueMap":{"Chivas Regal-CHI":58.46,"Martell-MAR":3133.20},"AddOnString":""},{"Volumes":2380.000002,"Value":3191.66,"TradeExpenses":1060.00,"SubBrandGSPercentageMap":{},"SubBrandGSMap":{"a7FM00000008S5DMAU":0.000000,"a7FM00000008XqNMAU":0.000000},"SubBrandGradeMap":{"1. Standard + Premium 标准档 + 高档":46.200000,"3. Ultra Premium 特级高档":2333.800002},"SubBrandGradeGrouping":{"Standard":46.200000,"Ultra Premium":2333.800002},"SubBrandAPMap":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","PSFLineMap":{},"PSFExpensesTotal":0.0,"POStartDate":"2019-07-01","POEndDate":"2019-12-31","OutletSet":[],"OtherExpensesTotal":1060.00,"OtherExpensesRate":100.00,"OtherExpensesMap":{"PRC - Festival/Anniversary 节庆店庆费":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":200.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":200.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":1500.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":500.00,"ContractBottles":0.0},"PRC - Data Sharing 数据分享扣点":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":10.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":10.00,"ContractBottles":0.0},"PRC - Other Fixed Cost 其他固定费用":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":50.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":50.00,"ContractBottles":0.0},"PRC - Supply Chain-Others 物流费":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":50.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":50.00,"ContractBottles":0.0},"PRC - DM/Secondary Display Fee 海报/二次陈列费":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":150.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":150.00,"ContractBottles":0.0},"PRC - Variable event cost - On Premise 常规陈列费":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":0.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":0.00,"ContractBottles":0.0},"PRC - Promoter Store Mgt Fee 促销员进场管理费":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","strBrand":"","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateValue":0.0,"EstimateTotalFees":0.0,"EstimatePSFFees":0.0,"EstimateFees":100.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractValue":0.0,"ContractTotalFees":0.0,"ContractPSFFees":0.0,"ContractFees":100.00,"ContractBottles":0.0}},"NoOfMonths":6,"MarginPerBottle":-0.03,"MarginAfterAnP":-1060.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.03,"IntakeSTD":30600,"IntakeCR12":30303.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRate":0,"DisplayVolumeBase":"","DisplayMethodologyName":"","DisplayExpensesTotal":0.0,"DisplayExpensesRate":0.00,"DebugMap":{},"ContractLineMap":{"00006芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Standard","SubBrandCategory":"Whisky","strSubBrand":"a7FM00000008S5DMAU","strBrand":"a7EM00000008RX7MAM","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":594,"EstimateValue":58.46,"EstimateTotalFees":0.00,"EstimatePSFFees":0.0,"EstimateFees":0.00,"EstimateBottles":99,"ContractVolume":594,"ContractValue":58.46,"ContractTotalFees":0.00,"ContractPSFFees":0.0,"ContractFees":0.00,"ContractBottles":99},"00003马爹利鼎盛 Martell Distinction-ML8":{"VFinalVolume":0.0,"VFinalValue":0.0,"VFinalTotalFees":0.0,"VFinalPSFFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"马爹利鼎盛 Martell Distinction-ML8","SubBrandGrade":"Ultra Premium","SubBrandCategory":"Brandy","strSubBrand":"a7FM00000008XqNMAU","strBrand":"a7EM00000008RVoMAM","HistoricalVolume":0.0,"HistoricalValue":0.0,"HistoricalTotalFees":0.0,"HistoricalPSFFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":30006,"EstimateValue":3133.20,"EstimateTotalFees":0.00,"EstimatePSFFees":0.0,"EstimateFees":0.00,"EstimateBottles":5001,"ContractVolume":30006,"ContractValue":3133.20,"ContractTotalFees":0.00,"ContractPSFFees":0.0,"ContractFees":0.00,"ContractBottles":5001}},"ContractId":"a8cM00000005mVLIAY","CMTotal":0.0,"CMId":" ","CategoryVolumeMap":{"Whisky":46.200000,"Brandy":2333.800002},"CategoryValueMap":{"Whisky":58.46,"Brandy":3133.20},"CategoryGSMap":{"Whisky":0,"Brandy":0},"BRSFMethodologyName":"","BrandVolumeMap":{"Chivas Regal-CHI":46.200000,"Martell-MAR":2333.800002},"BrandValueMap":{"Chivas Regal-CHI":58.46,"Martell-MAR":3133.20},"AddOnString":""}]';
        Attachment1.ASI_CRM_Historical_Financial_Data__c='{}';
        AttachmentList.add(Attachment1);
        AttachmentList.add(Attachment2);
        AttachmentList.add(Attachment3);       
        
        insert AttachmentList;

        List<ASI_CRM_Module__c> ModuleList2 = new List<ASI_CRM_Module__c>();
        ModuleList2.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract3.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList2.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract3.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList2.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract3.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList2.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract3.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList2.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract3.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Display'));
        
        insert ModuleList2; 
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList2 = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList2.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract3.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList2[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList2.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract3.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList2[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }                                                                
                                                                       
                                                                       
        ContractLineList2.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract3.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList2[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList2.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract3.Id,ASI_CRM_Type__c='Display',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList2[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
                                                                       
                                                                       
        insert ContractLineList2;
        
        ASI_TH_CRM_Contract__c Contract4 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Final',
                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2.addMonths(3),
                                                               ASI_CRM_CN_PO_End_Date__c =PO_Start_Date2.addMonths(4)-1 ,ASI_CRM_CN_V0_0_PO_version__c=Contract.Id,ASI_CRM_CN_Last_PO_version__c=Contract.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                               Name = 'Contract4',
                                                               ASI_CRM_Last_RBA_Approver__c = UserInfo.getUserId(),
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract4; 
        
        List<ASI_CRM_Module__c> ModuleList3 = new List<ASI_CRM_Module__c>();
        ModuleList3.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract4.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList3.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract4.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList3.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract4.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList3.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract4.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList3.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract4.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Display'));
        
        insert ModuleList3;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList3 = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList3.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract4.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList3[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList3.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract4.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList3[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }                                                                
                                                                       
                                                                       
        ContractLineList3.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract4.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList3[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList3.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract4.Id,ASI_CRM_Type__c='Display',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList3[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
                                                                       
                                                                       
        insert ContractLineList3;
        
        
		//test.stopTest();
	}
	
	static testMethod void ASI_CRM_CN_OffProfitShuttleCtrlTest() {
		
		ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract1'];    
		ASI_TH_CRM_Contract__c Contract4 = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract4'];             
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_OffProfitShuttleCtrl OffProfitShuttleCtrl = new ASI_CRM_CN_OffProfitShuttleCtrl(stdController);
        OffProfitShuttleCtrl.strPDF = '1';
        boolean initTest = OffProfitShuttleCtrl.init();
        
        ApexPages.currentPage().getParameters().put('id',Contract4.Id);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(Contract4);  
        ASI_CRM_CN_OffProfitShuttleCtrl OffProfitShuttleCtrl2 = new ASI_CRM_CN_OffProfitShuttleCtrl(stdController2);
        OffProfitShuttleCtrl.strPDF = '2';
        boolean initTest2 = OffProfitShuttleCtrl2.init();
        OffProfitShuttleCtrl2.checkApprover();
        OffProfitShuttleCtrl2.checkLastRBAID();
        OffProfitShuttleCtrl2.DecimalRounding(1.1);
        OffProfitShuttleCtrl.strPDF = '3';
        boolean initTest3 = OffProfitShuttleCtrl2.init();
	}

    static testMethod void ASI_CRM_CN_OffProfitShuttleCtrlTest2() {
        
        ASI_TH_CRM_Contract__c Contract2 = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract2'];    
        ASI_TH_CRM_Contract__c Contract3 = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract3'];             
        ApexPages.currentPage().getParameters().put('id',Contract2.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract2);  
        ASI_CRM_CN_OffProfitShuttleCtrl OffProfitShuttleCtrl = new ASI_CRM_CN_OffProfitShuttleCtrl(stdController);
        OffProfitShuttleCtrl.strPDF = '1';
        boolean initTest = OffProfitShuttleCtrl.init();
        
        ApexPages.currentPage().getParameters().put('id',Contract3.Id);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(Contract3);  
        ASI_CRM_CN_OffProfitShuttleCtrl OffProfitShuttleCtrl2 = new ASI_CRM_CN_OffProfitShuttleCtrl(stdController2);
        OffProfitShuttleCtrl.strPDF = '2';
        boolean initTest2 = OffProfitShuttleCtrl2.init();
        OffProfitShuttleCtrl2.checkApprover();
        OffProfitShuttleCtrl2.checkLastRBAID();
        OffProfitShuttleCtrl2.DecimalRounding(1.1);
        OffProfitShuttleCtrl2.strPDF = '3';
        boolean initTest3 = OffProfitShuttleCtrl2.init();
    }
    
}