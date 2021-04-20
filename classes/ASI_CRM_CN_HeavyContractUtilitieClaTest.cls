/**
 * @File Name          : ASI_CRM_CN_HeavyContractUtilitieClaTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/26/2020, 12:52:25 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/25/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_CN_HeavyContractUtilitieClaTest {
    static testMethod void HeavyContractUtilitiesClassTest1() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;




        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;



        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
            ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        insert ContractList;



        test.startTest();
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12345);


        Boolean TempBoolean = false;
        Date TempDate = date.newinstance(system.today().year(), system.today().month(), 1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.DateOperationChecking('Equal to',TempDate,TempDate+2);
        ASI_CRM_CN_HeavyContractUtilitiesClass.DateOperationChecking('Greater than',TempDate,TempDate+2);
        ASI_CRM_CN_HeavyContractUtilitiesClass.DateOperationChecking('Greater than or Equal to',TempDate,TempDate+2);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking('Equal to',2,3,4);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking('Greater than',2,3,4);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking('Greater than or Equal to',2,3,4);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking('Less than',2,3,4);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking('Less than or Equal to',2,3,4);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking('Within',2,3,4);

        ASI_CRM_CN_HeavyContractUtilitiesClass.DateOperationChecking('Less than',TempDate+2,TempDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('True');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('FALSE');

        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('colspan4');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan1');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan2');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan3');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan4');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan5');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan6');

        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable(Contract);
        test.stopTest();
    }
    static testMethod void HeavyContractUtilitiesClassTest2() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;



        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
            ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        insert ContractList;
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;
        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
       		SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
       		                                                   ASI_CRM_CN_Incentive_for_PSF__c=100,
       		                                                   ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
       		                                                   ASI_CRM_CN_Rebate_Percent__c =10,
       		                                                   ASI_CRM_CN_Max_Rebate_Percent__c =5,
       		                                                   ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'      		                                                    
       		                                                   )
       		                     );
        }           
        insert SubBrandLineList;
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        insert cos;

        test.startTest();
        
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
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
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

        List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_TH_CRM_Contract__c cloneCon = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        contract.Name = 'TestContract002';
        contract.ASI_CRM_CN_Last_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_V0_0_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_PO_Version__c = '0.1';
        Contract.ASI_CRM_Copied_From__c=cloneCon.Id;

        Contract.ASI_CRM_CN_Status__c = 'Draft';
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_CN_Contract_Upload__c=true;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c=null;
        Contract.ASI_CRM_Auto_PO_Modification__c=false;

        Contract.ASI_CRM_CN_PO_Modification__c = true;
        Contract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = Date.today();
        update Contract;

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        // //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // // subBrandData.put('Test', newitem);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'Test');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void HeavyContractUtilitiesClassTest3() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;



        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
            ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        insert ContractList;
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;
        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        insert cos;

        test.startTest();
        
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
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
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

        List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_TH_CRM_Contract__c cloneCon = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        contract.Name = 'TestContract002';
        contract.ASI_CRM_CN_Last_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_V0_0_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_PO_Version__c = '0.1';
        Contract.ASI_CRM_Copied_From__c=cloneCon.Id;

        Contract.ASI_CRM_CN_Status__c = 'Draft';
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_CN_Contract_Upload__c=true;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c=null;
        Contract.ASI_CRM_Auto_PO_Modification__c=false;

        Contract.ASI_CRM_CN_PO_Modification__c = true;
        Contract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = Date.today();
        update Contract;

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        // //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // // subBrandData.put('Test', newitem);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'Test');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void HeavyContractUtilitiesClassTest4() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[0].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[1].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[2].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));

        Insert BrandList;




        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;


        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;



        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
            ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        test.startTest();
        insert ContractList;
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;


        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        


        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;


        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        
        insert cos;

        
        
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
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
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

        List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_TH_CRM_Contract__c cloneCon = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        contract.Name = 'TestContract002';
        contract.ASI_CRM_CN_Last_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_V0_0_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_PO_Version__c = '0.1';
        Contract.ASI_CRM_Copied_From__c=cloneCon.Id;

        Contract.ASI_CRM_CN_Status__c = 'Draft';
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_CN_Contract_Upload__c=true;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c=null;
        Contract.ASI_CRM_Auto_PO_Modification__c=false;

        Contract.ASI_CRM_CN_PO_Modification__c = true;
        Contract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = Date.today();
        update Contract;

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        // //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // // subBrandData.put('Test', newitem);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'Test');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }


    static testMethod void HeavyContractUtilitiesClassTest5() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[0].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[1].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[2].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));

        Insert BrandList;




        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;


        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;



        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        ASI_TH_CRM_Contract__c v00Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract3',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');

        insert v00Contract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_CN_Last_PO_version__c=v00Contract.Id,ASI_CRM_CN_V0_0_PO_version__c=v00Contract.Id,ASI_CRM_Copied_From__c=v00Contract.Id,ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
            ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract2',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        
        insert ContractList;
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');

        test.startTest();
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;


        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        


        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;


        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        
        insert cos;

        
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
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

        List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        // //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // // subBrandData.put('Test', newitem);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'Test');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void HeavyContractUtilitiesClassTest6() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;



        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        ASI_TH_CRM_Contract__c v00Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract3',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');

        insert v00Contract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_CN_Last_PO_version__c=v00Contract.Id,ASI_CRM_CN_V0_0_PO_version__c=v00Contract.Id,ASI_CRM_Copied_From__c=v00Contract.Id,ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);

        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
            ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract2',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        
        insert ContractList;
        Contract = [SELECT ASI_CRM_CN_No_of_Months__c,recordtypeid,ASI_CRM_CN_Status__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Copied_From__c,ASI_CRM_CN_PO_Modification__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Promotion_Type__c,Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_Contract__c WHERE Id =: Contract.Id];
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');

        test.startTest();
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;


        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        


        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;


        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        
        insert cos;

        
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
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

        List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // subBrandData.put('Test', newitem);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'Test');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void HeavyContractUtilitiesClassTest61() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;



        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        ASI_TH_CRM_Contract__c v00Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract3',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');

        insert v00Contract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_CN_Last_PO_version__c=v00Contract.Id,ASI_CRM_CN_V0_0_PO_version__c=v00Contract.Id,ASI_CRM_Copied_From__c=v00Contract.Id,ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);

        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
            ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract2',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        
        insert ContractList;
        Contract = [SELECT ASI_CRM_CN_No_of_Months__c,recordtypeid,ASI_CRM_CN_Status__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Copied_From__c,ASI_CRM_CN_PO_Modification__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Promotion_Type__c,Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_Contract__c WHERE Id =: Contract.Id];
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');

        test.startTest();
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;


        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        


        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;


        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        
        insert cos;

        
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
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

        List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // subBrandData.put('Test', newitem);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'Test');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void HeavyContractUtilitiesClassTest7() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;


        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);
        insert GroupContract;

        ASI_TH_CRM_Contract__c v00Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract3',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        // test.startTest();
        insert v00Contract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_CN_Last_PO_version__c=v00Contract.Id,ASI_CRM_CN_V0_0_PO_version__c=v00Contract.Id,ASI_CRM_Copied_From__c=v00Contract.Id,ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);

        // ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
        //     ASI_CRM_CN_Status__c = 'Draft',
        //     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
        //     ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
        //     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
        //     Name = 'Contract2',
        //     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        // ContractList.add(Contract2);
        

        
        insert ContractList;
        test.startTest();
        Contract = [SELECT ASI_CRM_CN_No_of_Months__c,recordtypeid,ASI_CRM_CN_Status__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Copied_From__c,ASI_CRM_CN_PO_Modification__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Promotion_Type__c,Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_Volume_Option__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Fixed_Cost_Total__c FROM ASI_TH_CRM_Contract__c WHERE Id =: Contract.Id];
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');

        
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;


        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        


        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;


        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        
        insert cos;

        
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
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

        List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        // //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // // subBrandData.put('Test', newitem);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'SELECT Id FROM ASI_CRM_SegmentationCriteria__c');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void HeavyContractUtilitiesClassTest8() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        //
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));

        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;


        
        // ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
        //     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
        //     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
        //     Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
        //     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);

        // insert GroupContract;

        ASI_TH_CRM_Contract__c v00Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Archived',
            // ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract3',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');

        insert v00Contract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            // ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_CN_Last_PO_version__c=v00Contract.Id,ASI_CRM_CN_V0_0_PO_version__c=v00Contract.Id,ASI_CRM_Copied_From__c=v00Contract.Id,ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);

        // ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
        //     ASI_CRM_CN_Status__c = 'Draft',
        //     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
        //     ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
        //     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
        //     Name = 'Contract2',
        //     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        // ContractList.add(Contract2);
        

        
        insert ContractList;
        
        test.startTest();
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');

        
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;


        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        


        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;


        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        
        insert cos;

        
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
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

        // List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

        Contract = [SELECT ASI_CRM_CN_No_of_Months__c,recordtypeid,ASI_CRM_CN_Status__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Copied_From__c,ASI_CRM_CN_PO_Modification__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Promotion_Type__c,Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_Volume_Option__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Fixed_Cost_Total__c FROM ASI_TH_CRM_Contract__c WHERE Id =: Contract.Id];
        

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        // //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // // subBrandData.put('Test', newitem);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'SELECT Id FROM ASI_CRM_SegmentationCriteria__c');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');


        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        // PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void HeavyContractUtilitiesClassTest9() {
        //Test class for ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine
        //
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

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
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }

        insert subBrands;


        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;


        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
            ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;




        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));

        insert MethodologyList;


        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;





        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') ,
            ASI_CRM_BRSF_Methodology__c=MethodologyList[0].Id,
            ASI_CRM_PSF_Meth_Mod1__c=MethodologyList[1].Id, ASI_CRM_PSF_Unit_Mod1__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod1__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod2__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod2__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod2__c='By Sub-Brand',
            ASI_CRM_PSF_Meth_Mod3__c=MethodologyList[1].Id,ASI_CRM_PSF_Unit_Mod3__c='Std. Btl.',ASI_CRM_PSF_Volume_Base_Mod3__c='By Sub-Brand',
            ASI_CRM_VEC_Methodology__c=MethodologyList[2].Id,ASI_CRM_VEC_Unit__c='Std. Btl.',ASI_CRM_VEC_Volume_Base__c='By Sub-Brand'
        );
        insert KAAccount;


        test.startTest();
        // ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
        //     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,ASI_CRM_Active_Dummy_PO__c=true ,
        //     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
        //     Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
        //     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id);

        // insert GroupContract;

        ASI_TH_CRM_Contract__c v00Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Archived',
            // ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract3',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');

        insert v00Contract;

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            // ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_CN_Last_PO_version__c=v00Contract.Id,ASI_CRM_CN_V0_0_PO_version__c=v00Contract.Id,ASI_CRM_Copied_From__c=v00Contract.Id,ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);

        // ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
        //     ASI_CRM_CN_Status__c = 'Draft',
        //     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(5),
        //     ASI_CRM_CN_PO_End_Date__c =PO_Start_Date.addMonths(9)-1,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
        //     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
        //     Name = 'Contract2',
        //     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        // ContractList.add(Contract2);
        

        
        insert ContractList;
        
        ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = Contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');

        
        insert paymentRequest;

        Date OriginalStartDate = Date.valueof('2018-09-30');
        Date OriginalEndDate = Date.valueof('2018-09-01');

        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;

        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        // crmcmg.ASI_CRM_CN_Monh__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        // crmcmg.ASI_CRM_CN_Month_End_Date__c = Date.valueof('2018-09-01');
        Insert crmcmg;
        Set<Id> subbrandSet = new Set<Id>{subBrands[0].Id};
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        // insert MethodologyList;
        ASI_CRM_Module__c acm = new ASI_CRM_Module__c();
        acm.ASI_CRM_Contract__c=Contract.Id;
        acm.ASI_CRM_Unit__c = 'Std. Btl.';
        acm.ASI_CRM_Volume_Base__c='By Sub-Brand';
        acm.ASI_CRM_Line_Type__c='BRSF';
        acm.ASI_CRM_Methodology__c=MethodologyList[0].Id;


        Insert acm;

        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Parent_Module__c = acm.Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        


        insert ModuleList;
        Set<Id> ParentModuleSet = new Set<Id>{ModuleList[1].Id};
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmenMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();
        SegmenMap.put('Test', SegmentationCriteria);
        List<ASI_CRM_Sub_Brand_Line__c> SubBrandLineList = new List<ASI_CRM_Sub_Brand_Line__c>();        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            SubBrandLineList.add(new ASI_CRM_Sub_Brand_Line__c(ASI_CRM_Sub_Brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Incentive_for_PSF__c=100,
                                                               ASI_CRM_CN_Max_Incentive_for_PSF__c =100,
                                                               ASI_CRM_CN_Rebate_Percent__c =10,
                                                               ASI_CRM_CN_Max_Rebate_Percent__c =5,
                                                               ASI_CRM_CN_Region__c='Central Region',
                                                                  ASI_CRM_CN_New_Channel__c =channel.Id,
                                                                  ASI_CRM_Commercial_Team__c = 'Premium'                                                                
                                                               )
                                 );
        }           
        insert SubBrandLineList;


        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
       
        AttachmentList.add(Attachment1);
        INSERT AttachmentList;

        String ASI_CRM_Historical_Financial_Data='[{"Volumes":0.0,"TotalMBCRate":97.00,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":79.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        //cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_CN_Outlet__c=Customers[0].Id));
        
        insert cos;

        
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')
                                                                           ));
        }
        
        //for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           //ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        //}                                                                
                                                                       
        /*ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));*/
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=v00Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
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

        // List<String> linList = new List<String>{'BRSF','PSF','Display'};
       
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(ASI_CRM_Historical_Financial_Data,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
        // ASI_CRM_CN_HeavyProfitShuttleCtrl2nd acc = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract= acc.DataRounding(HistoricalContractList[0]);
        // List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> FinancialIndicator2ndList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);
        // FinancialIndicator2ndList.add(HistoricalV00Contract);

        // ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        // newitem.period = 2;//This fiscal year's month number
        // newitem.SubBrandId = subBrands[0].Id;
        // newitem.TotalVolume = 0;
        // newitem.TotalEstVolume = 0;
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

        Contract = [SELECT ASI_CRM_CN_No_of_Months__c,recordtypeid,ASI_CRM_CN_Status__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Copied_From__c,ASI_CRM_CN_PO_Modification__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Promotion_Type__c,Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_Volume_Option__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Fixed_Cost_Total__c FROM ASI_TH_CRM_Contract__c WHERE Id =: Contract.Id];
        

        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(Contract,HistoricalV00Contract,HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(paymentRequest,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand(Contract,'contract','PO Open');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Modi');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.constructTradeExpenseBySubBrand2nd(Contract,'contract','PO Open');
        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> bysubbrandtempMap = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
        //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        // //     new List<String>{'historical' ,'estimate', 'contract'},FinancialIndicator2ndList);
        // // Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> subBrandData = new Map <String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // // subBrandData.put('Test', newitem);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract,new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalV00Contract},subBrandData);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.updateCMGSInTradeExpenseBySubBrand2nd(HistoricalV00Contract,FinancialIndicator2ndList,subBrandData);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands2nd(HistoricalV00Contract);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds2nd();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandIds();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandCode();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,true);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveBRSFLines(Contract,linList,false);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveModulesAndLines(Contract,linList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.retrieveSubBrandVolumes(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'std');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getVolume(volume,'stdOther');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.projectVolume(2,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertAttachment2nd(Contract.Id,ASI_CRM_Historical_Financial_Data,'Historical Modi Data');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(ParentModuleSet,'TEST','Central Region');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MAX');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(OriginalEndDate,OriginalStartDate,'MIN');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkFYDayPeriod(OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(paymentRequest,Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine2nd(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('5');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration('10');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(Contract,'ASI_CRM_CN_Contract');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.SQLSegmentationCriteria(SegmenMap,'SELECT Id FROM ASI_CRM_SegmentationCriteria__c');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(OriginalStartDate,'yyyy-MM-dd');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(2,OriginalEndDate,OriginalStartDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(8);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1000);
        // // ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(Decimal.valueOf(null));
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleSet,paymentRequest.Id);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(subbrandSet,Contract.Id,ModuleList);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade('CommercialTeam','CommercialTeam');
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget('KTV','Central Region','Test','Test',OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingDomesticTarget(OriginalEndDate,subbrandSet);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,4,OriginalStartDate,OriginalEndDate);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveTotalPaidAmount(paymentRequest);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract);
        // ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine(Contract2);

        ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateNationalContractOption(KAAccount.Id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KAAccountQueryNewestContract(KAAccount.Id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract.Id,'ASI_CRM_CRM_CN_Contract_Heavy_BRSF', ' ');

        ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown tebObj = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown();
        ASI_CRM_Subbrand_Volume__c tempVolume = new ASI_CRM_Subbrand_Volume__c();
        ASI_TH_CRM_PaymentRequestLineItem__c tempPay = new ASI_TH_CRM_PaymentRequestLineItem__c();
        ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown tebObj1 = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown(tempVolume);
        ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd teb2ndObj1 = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd(tempVolume);
        ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd teb2ndObj2 = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd(tempPay);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(12);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(122);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(1333);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(14444);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(123456);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(0);
        ASI_CRM_CN_HeavyContractUtilitiesClass.KeyNameSortingASC(Null);

        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(123);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(1234);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSortingASC(12345);


        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(12);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(123);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1234);       ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('New Contract V Final');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Speed%');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Predefined Theoretical Value');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Guidance');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PO Submit Date');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Methodology');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('PRC Default Volume Base');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Min Key Strategy Achievement Rate');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Total Volume Achievement Rate');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Purchase Value Speed%');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Payment Amount');
        ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Suggested Payment Amount');
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Sub-Brand');
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Grade');
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Category');
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeBaseTranslation('Total');
        ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle(Contract.id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SendGroupContractShuttle2nd(Contract.id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2,0.2);
        ASI_CRM_CN_HeavyContractUtilitiesClass.denullify(0.2);
        ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(Contract.id);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean('TEST');
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingPromotionTypes('a');

        test.stopTest();
    }

    static testMethod void ReconstructCurrentPOModiFIData2ndTest1() {
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        /*
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        
        
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
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_HK_CRM_Product_Category__c=SubCategoryList[0].ASI_CRM_CN_Product_Category__c,ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_HK_CRM_Product_Category__c=SubCategoryList[1].ASI_CRM_CN_Product_Category__c,ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_HK_CRM_Product_Category__c=SubCategoryList[2].ASI_CRM_CN_Product_Category__c,ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
        SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;
        */

        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;

        /*
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
        ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
        ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
        ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
        ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;
        /*
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        */
        Date TodayDateBefore10= system.today().addMonths(-10);
        
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        Date PO_End_Date2 = date.newinstance(TodayDateBefore10.year(), TodayDateBefore10.month(), 1).addMonths(4)-1;
        system.debug('PO_Start_Date: '+PO_Start_Date);
        // Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(6)-1;
        
        
        List<ASI_TH_CRM_Contract__c> ContractArchivedList= new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c ContractArchivedH = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                              ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                              ASI_CRM_CN_PO_Start_Date__c =  date.newinstance(TodayDateBefore10.year(), TodayDateBefore10.month(), 1),
                                                                              ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,
                                                                              ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                              Name = 'Contract1',
                                                                              ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractArchivedList.add(ContractArchivedH);
        ASI_TH_CRM_Contract__c ContractArchived = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                             ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                             ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                             ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                             ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                             Name = 'Contract2',
                                                                             ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractArchivedList.add(ContractArchived);
        insert ContractArchivedList;
        
        
        List<ASI_TH_CRM_Contract__c> ContractList= new List<ASI_TH_CRM_Contract__c>();
        
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Final',
                                                                      ASI_CRM_CN_PO_Start_Date__c = date.newinstance(TodayDateBefore10.year(), TodayDateBefore10.month(), 1),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract3',ASI_CRM_CN_V0_0_PO_version__c=ContractArchivedH.Id,ASI_CRM_CN_Last_PO_version__c=ContractArchivedH.Id,
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract4',ASI_CRM_CN_V0_0_PO_version__c=ContractArchived.Id,ASI_CRM_CN_Last_PO_version__c=ContractArchived.Id,
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M02',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M04',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M05',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        /*

        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

        insert MethodologyAssignmentList ;


        */
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = ContractList[1].id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Variable',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Variable',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost1);
        ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost2);
        ASI_CRM_Contract_Cost__c contractCost3 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = ContractArchived.id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost3);
        
        insert ContractCostList;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractArchived.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));  
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractArchived.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractArchived.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractArchived.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractArchived.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        
        
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=ContractArchived.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c = Customers[0].Id,
                ASI_CRM_Subbrand__c = subBrand.Id,
                ASI_CRM_End_Date__c = PO_Start_Date,
                ASI_CRM_CN_Exclude_From_Payment_Volume__c = false
            );
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }
        date tempdate = PO_Start_Date.addMonths(1)-1;
        insert SubbrandVolumeList;
        
        
        //CM GS Data
        List<ASI_CRM_CM_GS__c> CMGSDataList= new List<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
        }
        insert CMGSDataList;
        /*
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data');   
        Attachment4.ASI_CRM_Historical_Financial_Data__c='{"VolumeSpeed":820.33738184039579798364085980597300,"PaymentSpeed":0.35540423498491771943971567661201200,"VariableCostTotal":119.00,"FixedCostTotal":0.00,"PSFBySubBrandAchievementRate":161.924686192468619246861924686192,"MKSSBAR":9999999}';
        AttachmentList.add(Attachment4);
        insert AttachmentList;
        */
        test.startTest();
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(Contract); 
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(Contract); 
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFIData2nd(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract); 
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine cl = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();
        ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data sbd = new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
        //ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd teb = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown(SubbrandVolumeList[0]);
        ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd teb1 = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd(ContractLineList[0]);
        ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd teb2 = new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd();

        test.stopTest();
    }

    static testMethod void RestructureCurrentFinancialIndicatorData2ndTest1() {
        //Test RestructureCurrentFinancialIndicatorData
        //
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        /*
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        
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
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[0].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[1].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[2].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;

        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;

        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
        SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }

        insert SubBrandAssignmentList;
        */

        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        insert ACCodeList;

        /*
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
        ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
        ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
        ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
        ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        insert ContractCostSettingList;

        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;

        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;

        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        */
        Date TodayDateBefore10= system.today().addMonths(-10);
        
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        Date PO_End_Date2 = date.newinstance(TodayDateBefore10.year(), TodayDateBefore10.month(), 1).addMonths(4)-1;
        system.debug('PO_Start_Date: '+PO_Start_Date);
        // Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(6)-1;
        
        
        List<ASI_TH_CRM_Contract__c> ContractList= new List<ASI_TH_CRM_Contract__c>();
        
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Final',
                                                                      ASI_CRM_CN_PO_Start_Date__c = date.newinstance(TodayDateBefore10.year(), TodayDateBefore10.month(), 1),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Archived',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M02',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M04',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M05',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        


        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost1);
        ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Variable',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost2);
        
        insert ContractCostList;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;

        /*
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
        ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(
        ASI_CRM_Account__c = Customers[0].Id,
        ASI_CRM_Subbrand__c = subBrand.Id,
        ASI_CRM_End_Date__c = PO_Start_Date,
        ASI_CRM_CN_Exclude_From_Payment_Volume__c = false
        );

        SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));

        }
        date tempdate = PO_Start_Date.addMonths(1)-1;
        insert SubbrandVolumeList;
        */
        
        //CM GS Data
        List<ASI_CRM_CM_GS__c> CMGSDataList= new List<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
        }
        insert CMGSDataList;
    
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Modi Data');   
        Attachment4.ASI_CRM_Historical_Financial_Data__c='{"VolumeSpeed":820.33738184039579798364085980597300,"PaymentSpeed":0.35540423498491771943971567661201200,"VariableCostTotal":119.00,"FixedCostTotal":0.00,"PSFBySubBrandAchievementRate":161.924686192468619246861924686192,"MKSSBAR":9999999}';
        AttachmentList.add(Attachment4);
        insert AttachmentList;
        
        test.startTest();
        
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(Contract); 
        test.stopTest(); 
    }

    static testMethod void RestructureCurrentFinancialIndicatorData2ndTest2() {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        ASI_CRM_KA_Account__c kaaccount = new ASI_CRM_KA_Account__c();
        
        insert kaaccount;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        
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
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[0].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[1].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,ASI_HK_CRM_Product_Category__c=SubCategoryList[2].ASI_CRM_CN_Product_Category__c,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;

        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;


        Date TodayDateBefore10= system.today().addMonths(-10);
        
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        Date PO_End_Date2 = date.newinstance(TodayDateBefore10.year(), TodayDateBefore10.month(), 1).addMonths(4)-1;
        
        List<ASI_TH_CRM_Contract__c> ContractList= new List<ASI_TH_CRM_Contract__c>();
        
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Final',
                                                                      ASI_CRM_CN_PO_Start_Date__c = date.newinstance(TodayDateBefore10.year(), TodayDateBefore10.month(), 1),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date2,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',ASI_CRM_New_FY_PO__c = true,
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Archived',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_NationalGroup__c = kaaccount.id,
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M02',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M04',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M05',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost1);
        ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Variable',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost2);
        insert ContractCostList;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;

        //CM GS Data
        List<ASI_CRM_CM_GS__c> CMGSDataList= new List<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));

            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1)));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year())));
        }
        insert CMGSDataList;
    
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Group Contract');   
        Attachment4.ASI_CRM_Historical_Financial_Data__c='{"VolumeSpeed":820.33738184039579798364085980597300,"PaymentSpeed":0.35540423498491771943971567661201200,"VariableCostTotal":119.00,"FixedCostTotal":0.00,"PSFBySubBrandAchievementRate":161.924686192468619246861924686192,"MKSSBAR":9999999}';
        AttachmentList.add(Attachment4);
        insert AttachmentList;
        
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_OutletWS__c=Customers[0].Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',ASI_CRM_CN_OutletWS__c=Customers[0].Id,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert PaymentRequestList;
        
        test.startTest();
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpdateAttachmentContractData(String.valueOf(Contract.Id),String.valueOf(Contract.Id),String.valueOf(Contract.Id));
        ASI_CRM_CN_HeavyContractUtilitiesClass.UpdateAttachmentHistoricalData(String.valueOf(Contract.Id), '');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(Contract,7,System.today(),system.today()+30);
        //ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateContractList(Contract,)
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.Today(), orgFiscalMonth);
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(1.00);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(99.00);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(999.00);
        ASI_CRM_CN_HeavyContractUtilitiesClass.SBGradeSorting(9999.00);
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.checkApprover(String.valueOf(Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('colspan4');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('colspan3');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan1');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan2');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan3');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan4');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan5');
        ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler('rowspan6');
        
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(PaymentRequestList[0],Contract);
        ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(Contract);
        test.stopTest(); 
    }

    
}