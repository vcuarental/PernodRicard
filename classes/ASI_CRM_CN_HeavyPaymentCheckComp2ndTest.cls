/**
 * @File Name          : ASI_CRM_CN_HeavyPaymentCheckComp2ndTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/17/2020, 2:27:53 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/17/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_CN_HeavyPaymentCheckComp2ndTest {
    static testMethod void HeavyPaymentCheckCompTest1() {
        //Test ASI_CRM_CN_HeavyPaymentCheckCompCtrl

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
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST1', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST2', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
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
        
        
        
        Date PO_Start_Date = ASI_CRM_CN_HeavyPaymentUtilitiesClass.getFiscalYearStart(System.today());//  date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(3)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Automated, Do not Change',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
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
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost2);
        
        insert ContractCostList;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
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
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        
        test.startTest();
        
        
        
        
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert PaymentRequestList;
        
        List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
        for(ASI_CRM_Module__c ModuleTemp:ModuleList){
            PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
                                                        ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
                                                        ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
        }
        
        insert PaymentModuleList;
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList= new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
            ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=PaymentRequestList[0].Id);
            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[0].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
                PaymentLine= ASI_CRM_CN_HeavyContractTestClassHelper.PaymentLineFieldAssignment(PaymentLine);
            }
            if(ContractLine.ASI_CRM_Type__c=='PSF'){
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[1].Id;
                    PaymentLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                }
                
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Grade'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[2].Id;
                    PaymentLine.ASI_CRM_Sub_Brand_Grade__c= ContractLine.ASI_CRM_Sub_Brand_Grade__c;
                }
                
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Category'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[3].Id;
                    PaymentLine.ASI_CRM_Product_Category__c= ContractLine.ASI_CRM_Product_Category__c;
                }
                
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Total'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[4].Id;
                }
            }
            
            if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
            }
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        

        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Payment_Request__c =PaymentRequestList[0].Id,ASI_CRM_Type__c='CheckPoint-Success');
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RcKOAU"},"Id":"aATM00000006RcKOAU","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":-2,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: ROI(Actual)","ASI_CRM_Chinese_Interpretation__c":"投资回报率：新合同V0.0预估版不得比旧合同最终版少2%","ASI_CRM_English_Interpretation__c":"ROI: New Contract est. >= Historical V Final *98%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":false,"Display2ndResult":"旧合同最终版 = 1.74","Display1stResult":"新合同V0.0预估= 1.72","Dimension2ndResult":1.73760088211606633611224276870796,"Dimension1stResult":1.72},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXLOA2"},"Id":"aATM00000006RXLOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版多15%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. <= Historical V Final*115%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694},{"Type2ndName":"aGmM0000000002BKAQ","Type1stName":"aGmM0000000002BKAQ","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXEOA2"},"Id":"aATM00000006RXEOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: BRSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收费(BRSF)计算方式：进货量与空瓶取小支付","ASI_CRM_English_Interpretation__c":"BRSF Default Methodology: Min (BC, Intake)","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=Min (BC, Intake)(进货量与空瓶取小支付)","Display1stResult":"新合同V0.0预估=Min (BC, Intake)(进货量与空瓶取小支付)","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"aGmM0000000002fKAA","Type1stName":"aGmM0000000002fKAA;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXFOA2"},"Id":"aATM00000006RXFOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)计算方式：若实际空瓶回收率>= V0.0空瓶回收率，进货量支付，反之，空瓶回收数支付","ASI_CRM_English_Interpretation__c":"PSF Default Methodology: BC%>=V0.0 BC%, Intake, otherwise BC","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数)","Display1stResult":"新合同V0.0预估=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数);","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXHOA2"},"Id":"aATM00000006RXHOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":95,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"BC: BC%","ASI_CRM_Chinese_Interpretation__c":"空瓶回收率: 新合同需>=95%","ASI_CRM_English_Interpretation__c":"BC%: New Contract >=95%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 95","Display1stResult":"新合同V0.0预估= 95","Dimension2ndResult":95,"Dimension1stResult":95}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Payment_Request__c =PaymentRequestList[0].Id,ASI_CRM_Type__c='CheckPoint-Failed');
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"By Sub Brand and By Grade.","Type1stName":"By Sub-Brand;By Grade;By Category;By Total;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXGOA2"},"Id":"aATM00000006RXGOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Volume Base","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Volume Base","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)销量计算基础：按品牌或按品牌档次","ASI_CRM_English_Interpretation__c":"PSF Default Volume Base: By Sub-brand or By Grade","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算基础=By Sub-Brand (按品牌) or By Grade(按品牌档次).","Display1stResult":"新合同V0.0预估=By Sub-Brand;By Grade;By Category;By Total;","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXIOA2"},"Id":"aATM00000006RXIOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: Fixed Expense %","ASI_CRM_Chinese_Interpretation__c":"固定费用比例：新合同V0.0预估版需 <=15%","ASI_CRM_English_Interpretation__c":"Fixed Expense%: New Contract V0.0 Est. <=15%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 15","Display1stResult":"新合同V0.0预估= 46","Dimension2ndResult":15,"Dimension1stResult":46},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXJOA2"},"Id":"aATM00000006RXJOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Alignment_Value__c":-60.00,"ASI_CRM_Operation__c":"Less than","AS_CRM_Predefined_Theoretical_Value__c":"PO Submit Date","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Predefined Theoretical Value","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Period: PO Start Date","ASI_CRM_Chinese_Interpretation__c":"合同提交日期： 需在合同开始日期60天内提交","ASI_CRM_English_Interpretation__c":"PO Submit Date: compared with PO Start Date, should submit within 60 days","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-07-01","DisplayToUser":true,"Display2ndResult":"PO提交日期=Today (今天)-60 day(s).","Display1stResult":"新合同V0.0预估 = 7/1/2017","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXKOA2"},"Id":"aATM00000006RXKOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than","ASI_CRM_Alignment_Percentage__c":-30,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版少30%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. > Historical V Final*70%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694}]';
        AttachmentList.add(Attachment2);
        
        
        insert AttachmentList;
       
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCompCtrl con2 = new ASI_CRM_CN_HeavyPaymentCheckCompCtrl(stdController2);
        con2.PageId=PaymentRequestList[0].Id;
        con2.strPDF = '0';
        //con2.init();
        con2.initPage();
   
        con2.PageId=PaymentRequestList[0].Id;
        con2.strPDF = '2';
        //con2.init();
        con2.initPage();

        //2020/08/09
        Contract.ASI_CRM_CN_Is_2nd_KPI_PO__c = true;
        update Contract;
        ApexPages.Standardcontroller stdController3 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCompCtrl con3 = new ASI_CRM_CN_HeavyPaymentCheckCompCtrl(stdController3);
        con2.PageId=PaymentRequestList[0].Id;
        con3.strPDF = '0';
        con3.initPage();
        
   
        con3.PageId=PaymentRequestList[0].Id;
        con3.strPDF = '2';
        con3.initPage();       

        test.stopTest(); 
    }
}