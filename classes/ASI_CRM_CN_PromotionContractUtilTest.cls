/***************************************************************************************************************************
* Name:        ASI_CRM_CN_PromotionContractUtilClass 
* Description: Test class for ASI_CRM_CN_OffContractUtilitiesClass
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-08-19       Canter Duan             Created
****************************************************************************************************************************/
@isTest
public class ASI_CRM_CN_PromotionContractUtilTest {
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
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='TOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;

        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1,ASI_CRM_CN_Payment_Page_Number__c = 1);
        insert CustomSetting ;
        
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
        
        //Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        Date PO_Start_Date = date.newinstance(system.today().addMonths(-2).year(), system.today().addMonths(-2).month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='Outlet Promotion',
                                                                     ASI_CRM_CN_Data_Source__c = 'Min(WS Intake, Outlet Intake)',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Expected_Display_Est_Total__c =1000,
                                                                     ASI_CRM_PO_Channel__c = channel.Id,
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Display'));
        
        insert ModuleList;
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost1);
        insert ContractCostList;
        
        
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

        //2020/08/12
        ASI_MFM_Sub_brand__c brand = new ASI_MFM_Sub_brand__c (Name='TESTONE',ASI_MFM_Brand__c=BrandList[0].Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grades[0].Id,ASI_CRM_SG_Competitor__c=false,ASI_MFM_Active_for_CRM__c=true);
        insert brand;
        ASI_CRM_SegmentationCriteria__c segmentation = new ASI_CRM_SegmentationCriteria__c(Name='TestOne',ASI_CRM_Channel__c=channel.Id,ASI_CRM_CN_PO_Type__c=Contract.ASI_TH_CRM_Promotion_Type__c,ASI_CRM_Region__c=region.Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria_Promotion'));
        insert segmentation;

        ASI_CRM_Sub_Brand_Assignment__c brandAssignment = new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Segmentation_Criteria__c=segmentation.Id,ASI_CRM_Sub_Brand__c=brand.Id);
        insert brandAssignment;


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
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>(); 
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                 ASI_CRM_CN_Outlet__c=Customers[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        insert cos;
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           ASI_CRM_CN_Sub_Brand_Package__c='Test1',
                                                                           ASI_CRM_CN_Contract_Purchase_Value__c = 10,
                                                                           ASI_CRM_CN_Total_Volume_Std_btl__c = 14,
                                                                           ASI_CRM_CN_Total_Volume_9L__c = 1,
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
                                                                           ASI_CRM_CN_Sub_Brand_Package__c='Test2',
                                                                           ASI_CRM_CN_Contract_Purchase_Value__c = 11,
                                                                           ASI_CRM_CN_Total_Volume_Std_btl__c = 15,
                                                                           ASI_CRM_CN_Total_Volume_9L__c = 1,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }                                                                
        
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c='Test3',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 12,
                                                                       ASI_CRM_CN_Total_Volume_Std_btl__c = 16,
                                                                       ASI_CRM_CN_Total_Volume_9L__c = 1,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Display',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c='Test4',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 13,
                                                                       ASI_CRM_CN_Total_Volume_Std_btl__c = 17,
                                                                       ASI_CRM_CN_Total_Volume_9L__c = 1,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Visibility',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       ASI_CRM_CN_Sub_Brand_Package__c='Test4',
                                                                       ASI_CRM_CN_Contract_Purchase_Value__c = 13,
                                                                       ASI_CRM_CN_Total_Volume_Std_btl__c = 17,
                                                                       ASI_CRM_CN_Total_Volume_9L__c = 1,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        
        insert ContractLineList;
        
        
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Contract__c = Contract.Id,                                                                                                                                                                 
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE,
                                                                                   recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Subbrand_Volume__cASI_CRM_CN_WS_Outlet_Sub_brand_Volume')
                                                                                  );
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }
        insert SubbrandVolumeList;
        
        List<ASI_CRM_CM_GS__c> CMGSList= new List<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_CM_GS__c TempVolume = new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c = subBrand.Id,
                                                               ASI_CRM_Region__c = region.Id,
                                                               ASI_CRM_TYPE__c ='YTD CM',
                                                               ASI_CRM_CN_Month__c =6,
                                                               ASI_CRM_YEAR__c ='2020',
                                                               ASI_CRM_CM_GS_per_9L__c = 100);
            CMGSList.add(TempVolume);   
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_CM_GS__c TempVolume = new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c = subBrand.Id,
                                                               ASI_CRM_Region__c = region.Id,
                                                               ASI_CRM_TYPE__c ='YTD GS',
                                                               ASI_CRM_CN_Month__c =6,
                                                               ASI_CRM_YEAR__c ='2020',
                                                               ASI_CRM_CM_GS_per_9L__c = 100);
            CMGSList.add(TempVolume);   
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_CM_GS__c TempVolume = new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c = subBrand.Id,
                                                               ASI_CRM_Region__c = region.Id,
                                                               ASI_CRM_TYPE__c ='Budget GS',
                                                               ASI_CRM_CN_Month__c =6,
                                                               ASI_CRM_YEAR__c ='2020',
                                                               ASI_CRM_CM_GS_per_9L__c = 100);
            CMGSList.add(TempVolume);   
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_CM_GS__c TempVolume = new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c = subBrand.Id,
                                                               ASI_CRM_Region__c = region.Id,
                                                               ASI_CRM_TYPE__c ='Budget CM',
                                                               ASI_CRM_CN_Month__c =6,
                                                               ASI_CRM_YEAR__c ='2020',
                                                               ASI_CRM_CM_GS_per_9L__c = 100);
            CMGSList.add(TempVolume);   
        }
        
        insert CMGSList;
        
        test.stopTest();
        
        Date PO_Start_Date2 = date.newinstance(system.today().year(), system.today().month(), 1).addMonths(-3);
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
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_V0_0_PO_version__c=Contract.Id,ASI_CRM_CN_Last_PO_version__c=Contract.Id,
                                                                      ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract3',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract3; 
        
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
                                                                      ASI_CRM_CN_Status__c = 'Archived',
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2.addMonths(3),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_Start_Date2.addMonths(4)-1 ,ASI_CRM_CN_V0_0_PO_version__c=Contract.Id,ASI_CRM_CN_Last_PO_version__c=Contract.Id,
                                                                      ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
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
        
		List<ASI_TH_CRM_PaymentRequest__c> lstPR = new List<ASI_TH_CRM_PaymentRequest__c>();  
        Id recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        lstPR.add(new ASI_TH_CRM_PaymentRequest__c(Name='100', ASI_CRM_CN_OutletWS__c=Customers[0].id,ASI_CRM_CN_Last_Payment__c=true,recordTypeId=recordTypeID,ASI_TH_CRM_Status__c='Submitted',
                                                   ASI_TH_CRM_Contract__c=Contract.Id));
        insert lstPR; 

        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = lstPR[0].Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c=ContractLineList[0].Id,
                                                                                                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Outlet_WS'),
                                                                                                        ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,
                                                                                                        ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                                                        ASI_CRM_CN_WS_Intake_9L__c=1,ASI_CRM_CN_Outlet_Intake_9L__c=1,ASI_CRM_CTD_Actual_Vol__c=1,
                                                                                                        ASI_CRM_CN_WS_Intake_Std__c = 0,
                                                                                                        ASI_CRM_Module__c = ModuleList[0].Id,ASI_CRM_CN_Wholesaler__c = Customers[0].Id ,ASI_CRM_Customer__c = Customers[0].Id);
        paymentLineItems.add(paymentLineItem);
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem2 = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = lstPR[0].Id,ASI_CRM_CN_Contract_BRSF_Line_Item__c=ContractLineList[0].Id,
                                                                                                         RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Outlet_WS'),
                                                                                                         ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,
                                                                                                         ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                                                         ASI_CRM_CN_WS_Intake_9L__c=1,ASI_CRM_CN_Outlet_Intake_9L__c=1,ASI_CRM_CTD_Actual_Vol__c=1,
                                                                                                         ASI_CRM_CN_WS_Intake_Std__c = 0,
                                                                                                         ASI_CRM_Module__c = ModuleList[0].Id,ASI_CRM_CN_Wholesaler__c = Customers[0].Id ,ASI_CRM_Customer__c = Customers[0].Id);
        paymentLineItems.add(paymentLineItem2);
        insert paymentLineItems;

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
        
        
    }
    
     static testMethod void ASI_CRM_CN_PromotionContractUtilClassTest1() {		
        test.startTest();
        ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_Copied_From__c,ASI_TH_CRM_Promotion_Type__c,
                                           ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                                           ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_Display_Est_Total__c,ASI_CRM_CN_Expected_Visibility_Est_Total__c,ASI_CRM_CN_PO_Start_Date__c,
                                           ASI_CRM_CN_PO_End_Date__c
                                           from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ASI_TH_CRM_Contract__c Contract3 = [Select Id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Name = 'Contract3'];
        ASI_TH_CRM_Contract__c Contract4 = [Select Id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Name = 'Contract4'];
        ASI_TH_CRM_PaymentRequest__c Payment = [Select Id,ASI_CRM_CN_Total_Free_Goods_Amount__c,Name From ASI_TH_CRM_PaymentRequest__c Where Name='100'];
        
        List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary> PaySumList = new List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary>();
        PaySumList = ASI_CRM_CN_PromotionContractUtilClass.PaymentSummaryTable(Contract,Payment);
        PaySumList = ASI_CRM_CN_PromotionContractUtilClass.PaymentSummaryTable(Contract);
		ASI_TH_CRM_Contract__c asic = ASI_CRM_CN_PromotionContractUtilClass.ArchivePO(Contract);      
        ASI_CRM_CN_PromotionContractUtilClass.CloneModules(Contract.id,Contract.id,true);
        ASI_CRM_CN_PromotionContractUtilClass.CloneCoveredOutlet(Contract.id,Contract3.id);
        List<ASI_CRM_CN_Covered_Outlet__c> CovOutcc =new List<ASI_CRM_CN_Covered_Outlet__c>([Select Id,ASI_CRM_CN_Contract__c from ASI_CRM_CN_Covered_Outlet__c]);
        Map<Id, ASI_CRM_CN_Covered_Outlet__c> CoveOut = new Map<Id, ASI_CRM_CN_Covered_Outlet__c>();
        CoveOut.put(CovOutcc[0].Id, CovOutcc[0]);
        ASI_CRM_CN_PromotionContractUtilClass.calVisbilityAmt(CoveOut);
        List<ASI_TH_CRM_Contract__c> conList = ASI_CRM_CN_PromotionContractUtilClass.getAvailableGroupPO(Contract);
        ASI_CRM_CN_PromotionContractUtilClass.getDefaultTradeMargin(Contract.id,Contract.id,'Outlet Promotion');
        List<ASI_CRM_Module__c> moduleListss = new List<ASI_CRM_Module__c>([Select Id From ASI_CRM_Module__c]);
        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLineItem = ASI_CRM_CN_PromotionContractUtilClass.createBRSFLine('PSF',
                                                                                                                  Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF'),
                                                                                                                 Contract.id,
                                                                                                                 moduleListss[0].Id);
        ASI_CRM_CN_PromotionContractUtilClass.GeneratingVolumeValueTargetLine(Contract);

        String testLine = ASI_CRM_CN_PromotionContractUtilClass.getCategoryNameFromContractLine(BRSFLineItem);

         test.stopTest();
     }
    
    static testMethod void ASI_CRM_CN_PromotionContractUtilClassTest2() {		
        test.startTest();
        ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_Copied_From__c,ASI_TH_CRM_Promotion_Type__c,
                                           ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                                           ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_Display_Est_Total__c,ASI_CRM_CN_Expected_Visibility_Est_Total__c,ASI_CRM_CN_PO_Start_Date__c,
                                           ASI_CRM_CN_PO_End_Date__c
                                           from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ASI_TH_CRM_Contract__c Contract3 = [Select Id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Name = 'Contract3'];
        ASI_TH_CRM_Contract__c Contract4 = [Select Id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Name = 'Contract4'];
        ASI_TH_CRM_PaymentRequest__c Payment = [Select Id,ASI_CRM_CN_Total_Free_Goods_Amount__c From ASI_TH_CRM_PaymentRequest__c Where Name='100'];
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c>();
        ContractList.add(Contract);
        ContractList.add(Contract3);
        ContractList.add(Contract4);
        
        ASI_CRM_CN_PromotionContractUtilClass.RestructureCurrentFinancialIndicatorData(Contract);
        ASI_CRM_CN_PromotionContractUtilClass.getContractOverThreshold(ContractList);
        ASI_CRM_CN_PromotionContractUtilClass.RestructureHistoricalFinancialIndicatorData(Contract4);
        
        Date CutoffDateFromPayment = Date.today();
        ASI_CRM_CN_PromotionContractUtilClass.ReconstructCurrentPOModiFIData(Contract,CutoffDateFromPayment);
        
        ASI_CRM_CN_PromotionContractUtilClass.RestructureCurrentFIData(Contract);
        
        ASI_CRM_CN_PromotionContractUtilClass.calculateGroupFI(Contract.Id,Contract.Id);
        ASI_CRM_CN_PromotionContractUtilClass.checkApprover(Contract.Id);
        ASI_CRM_CN_PromotionContractUtilClass.checkUserID();
        
        List<ASI_CRM_Module__c> ModuleList = [Select Id from ASI_CRM_Module__c];
        List<Id> ModuleIdList = new List<Id>();
        ModuleIdList.add(ModuleList[0].Id);
        ModuleIdList.add(ModuleList[1].Id);
        ModuleIdList.add(ModuleList[2].Id);
        
        ASI_CRM_CN_PromotionContractUtilClass.getModuleContractTotalByTax(ModuleIdList);
        ASI_CRM_CN_PromotionContractUtilClass.getModuleContractTotalByTax(ModuleList[0].Id);
        
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_PromotionContractUtilClassTest3() {       
        test.startTest();
        ASI_TH_CRM_Contract__c Contract = [Select Id, ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_Copied_From__c,ASI_TH_CRM_Promotion_Type__c,
                                           ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                                           ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_Display_Est_Total__c,ASI_CRM_CN_Expected_Visibility_Est_Total__c,ASI_CRM_CN_PO_Start_Date__c,
                                           ASI_CRM_CN_PO_End_Date__c 
                                           from ASI_TH_CRM_Contract__c where Name = 'Contract1'];
        ASI_TH_CRM_Contract__c Contract3 = [Select Id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Name = 'Contract3'];
        ASI_TH_CRM_Contract__c Contract4 = [Select Id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Name = 'Contract4'];
        
        ASI_CRM_CN_PromotionContractUtilClass.getCoveredOutlets(Contract.Id ,'ASI_CRM_Outlet_CN');
        
        ASI_CRM_CN_PromotionContractUtilClass.NameSortingDESC(123);
        
        test.stopTest();
    }
    
}