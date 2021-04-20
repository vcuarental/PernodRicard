@isTest
private class ASI_CRM_CN_EditHeavyPaymentDetail2ndTest {
    @testSetup
    public static void setup(){
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
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,ASI_HK_CRM_Category_Code__c='COG',recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',ASI_CRM_CN_Sequence__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_CN_Sequence__c=2,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_CN_Sequence__c=3,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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

        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost1',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)1', ASI_MFM_A_C_Code__c='5275.040001',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost2',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)2', ASI_MFM_A_C_Code__c='5275.040002',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost3',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)3', ASI_MFM_A_C_Code__c='5275.040003',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
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

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        
        
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        // Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(6)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;

        System.debug('after contract insert SOQL: ' + Limits.getQueries());

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

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[5].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[5]));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[6].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[6]));


        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[7].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[7]));
        
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

        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Fixed',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_CN_Activity_Code__r=ACCodeList[5],ASI_CRM_CN_Activity_Code__c=ACCodeList[5].Id,
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[7].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Fixed',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_CN_Activity_Code__r=ACCodeList[6],ASI_CRM_CN_Activity_Code__c=ACCodeList[6].Id,
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[8].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Fixed',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_CN_Activity_Code__r=ACCodeList[7],ASI_CRM_CN_Activity_Code__c=ACCodeList[7].Id,
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[9].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        insert ContractLineList;



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
        System.debug('after PaymentRequestList insert SOQL: ' + Limits.getQueries());

        test.startTest();

        List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
        for(ASI_CRM_Module__c ModuleTemp:ModuleList){
            PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
                                                        ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
                                                        ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
        }
        
        insert PaymentModuleList;
        System.debug('after PaymentModuleList insert SOQL: ' + Limits.getQueries());

        List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList= new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
            ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=PaymentRequestList[0].Id);
            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[0].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
                PaymentLine=ASI_CRM_CN_HeavyContractTestClassHelper.PaymentLineFieldAssignment(PaymentLine);
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
                PaymentLine.ASI_CRM_Non_Contract_Line__c=true;
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
            }
            if (ContractLine.ASI_CRM_Type__c == 'Fixed') {
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[6].Id;
                    PaymentLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                }
                
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Grade'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[7].Id;
                    PaymentLine.ASI_CRM_Sub_Brand_Grade__c= ContractLine.ASI_CRM_Sub_Brand_Grade__c;
                }
                
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Category'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[8].Id;
                    PaymentLine.ASI_CRM_Product_Category__c= ContractLine.ASI_CRM_Product_Category__c;
                }
                
                if(ContractLine.ASI_CRM_Volume_Base__c=='By Total'){
                    PaymentLine.ASI_CRM_Module__c=PaymentModuleList[9].Id;
                }
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other');
            }
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        
        Integer subIndex = 0;
        Id tempGradeId;
        Id tempCategroyId;
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            if (subIndex == 0 ) {
                tempGradeId = subBrand.ASI_CRM_CN_Sub_brand_Grade__c;
                tempCategroyId = subBrand.ASI_MFM_Brand__c;
            }
            if (subBrand.ASI_CRM_CN_Sub_brand_Grade__c != tempGradeId && subBrand.ASI_MFM_Brand__c != tempCategroyId) {
                ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                    ASI_CRM_End_Date__c=PO_Start_Date, 
                    ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
                SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            }
            subIndex++;
            
        }

        insert SubbrandVolumeList;

        test.stopTest();
    }
    static testMethod void EditHeavyPaymentDetailCtrlTest1() {
        //Test ASI_CRM_CN_EditHeavyPaymentDetailCtrl
        ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash'];
        List<ASI_CRM_Module__c> PaymentModuleList = [SELECT ASI_CRM_End_Date__c,ASI_CRM_Line_Type__c,ASI_CRM_Parent_Module__c FROM ASI_CRM_Module__c WHERE ASI_CRM_Payment_Request__c =: paymentrequest.Id];
        Date TodayDateBefore3= Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);

        
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(paymentrequest);
        test.startTest();
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con1 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController1);
        
        con1.saveItems();
        
        con1.GenerateBRSFVol();
        con1.GeneratePSFVol();
        con1.GenerateVECVol();
        con1.saveItems();
        con1.CancelProcess();
        
        // for(ASI_CRM_Module__c ModuleTemp:PaymentModuleList){
        //     ModuleTemp.ASI_CRM_End_Date__c=PO_Start_Date.addMonths(1)-1;
        // }
        // update PaymentModuleList;

        List<ASI_CRM_Module__c> psfModules = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_Module__c> fcModules = new List<ASI_CRM_Module__c>();
        for (ASI_CRM_Module__c module : PaymentModuleList) {
            if (module.ASI_CRM_Line_Type__c == 'PSF') {
                psfModules.add(module);
            }
            if (module.ASI_CRM_Line_Type__c == 'Fixed') {
                fcModules.add(module);
            }
        }
        
        // ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        // ASI_CRM_CN_EditHeavyPaymentDetailCtrl con2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);
        // con2.saveItems();
        

        
        // con2.GenerateBRSFVol();
        // ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[0].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();
        
        // ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[1].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();
        
        // ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[2].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();
        
        // ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[3].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();

        ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[0].ASI_CRM_Parent_Module__c);
        con1.GenerateFixedVol();

        ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[1].ASI_CRM_Parent_Module__c);
        con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[2].ASI_CRM_Parent_Module__c);
        
        // con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[3].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();
       
        // ASI_TH_CRM_PaymentRequestLineItem__c tempLine = new ASI_TH_CRM_PaymentRequestLineItem__c();
        // tempLine.ASI_CRM_CN_Actual_Vol__c = 20;
        // tempLine.ASI_CRM_CN_Bottle_Collected__c = 15;
        // con1.MethodologyDecision('M03',tempLine);
        // ASI_CRM_Module__c tempModule = new ASI_CRM_Module__c();
        // ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData tempData = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData(true);
        // ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData tempData2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData(tempModule,true);
        
        // ASI_CRM_CN_EditHeavyPaymentDetailCtrl.PaymentLineObject apTempObj = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl.PaymentLineObject();

        // // System.debug('after test.startTest con2.GeneratePSFVol SOQL: ' + Limits.getQueries());

        // // con2.GenerateVECVol();
        // // con2.ErrorHandling('测试');
        test.stopTest(); 
    }

    static testMethod void EditHeavyPaymentDetailCtrlTest6() {
        //Test ASI_CRM_CN_EditHeavyPaymentDetailCtrl
        ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash'];
        List<ASI_CRM_Module__c> PaymentModuleList = [SELECT ASI_CRM_End_Date__c,ASI_CRM_Line_Type__c,ASI_CRM_Parent_Module__c FROM ASI_CRM_Module__c WHERE ASI_CRM_Payment_Request__c =: paymentrequest.Id];
        Date TodayDateBefore3= Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);

        
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(paymentrequest);
        test.startTest();
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con1 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController1);
        
        List<ASI_CRM_Module__c> fcModules = new List<ASI_CRM_Module__c>();
        for (ASI_CRM_Module__c module : PaymentModuleList) {
            if (module.ASI_CRM_Line_Type__c == 'Fixed') {
                fcModules.add(module);
            }
        }
        
        ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[2].ASI_CRM_Parent_Module__c);
        
        con1.GenerateFixedVol();

        ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[3].ASI_CRM_Parent_Module__c);
        con1.GenerateFixedVol();
       
        ASI_TH_CRM_PaymentRequestLineItem__c tempLine = new ASI_TH_CRM_PaymentRequestLineItem__c();
        tempLine.ASI_CRM_CN_Actual_Vol__c = 20;
        tempLine.ASI_CRM_CN_Bottle_Collected__c = 15;
        con1.MethodologyDecision('M03',tempLine);
        ASI_CRM_Module__c tempModule = new ASI_CRM_Module__c();
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData tempData = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData(true);
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData tempData2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl.interimData(tempModule,true);
        
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl.PaymentLineObject apTempObj = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl.PaymentLineObject();

        // System.debug('after test.startTest con2.GeneratePSFVol SOQL: ' + Limits.getQueries());

        // con2.GenerateVECVol();
        // con2.ErrorHandling('测试');
        test.stopTest(); 
    }

    static testMethod void EditHeavyPaymentDetailCtrlTest3() {
        //Test ASI_CRM_CN_EditHeavyPaymentDetailCtrl
        ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash'];
        List<ASI_CRM_Module__c> PaymentModuleList = [SELECT ASI_CRM_End_Date__c,ASI_CRM_Line_Type__c,ASI_CRM_Parent_Module__c FROM ASI_CRM_Module__c WHERE ASI_CRM_Payment_Request__c =: paymentrequest.Id];
        Date TodayDateBefore3= Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        
        for(ASI_CRM_Module__c ModuleTemp:PaymentModuleList){
            ModuleTemp.ASI_CRM_End_Date__c=PO_Start_Date.addMonths(1)-1;
        }
        update PaymentModuleList;

        List<ASI_CRM_Module__c> psfModules = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_Module__c> fcModules = new List<ASI_CRM_Module__c>();
        for (ASI_CRM_Module__c module : PaymentModuleList) {
            if (module.ASI_CRM_Line_Type__c == 'PSF') {
                psfModules.add(module);
            }
            if (module.ASI_CRM_Line_Type__c == 'Fixed') {
                fcModules.add(module);
            }
        }
        
        test.startTest();
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);
        con2.saveItems();
        

        
        con2.GenerateBRSFVol();
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[0].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[1].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[2].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[3].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[0].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[1].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[2].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[3].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        System.debug('after test.startTest con2.GeneratePSFVol SOQL: ' + Limits.getQueries());

        con2.GenerateVECVol();
        con2.ErrorHandling('测试');
        test.stopTest(); 
    }

    static testMethod void EditHeavyPaymentDetailCtrlTest4() {
        //Test ASI_CRM_CN_EditHeavyPaymentDetailCtrl
        ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash'];
        List<ASI_CRM_Module__c> PaymentModuleList = [SELECT ASI_CRM_End_Date__c,ASI_CRM_Line_Type__c,ASI_CRM_Parent_Module__c FROM ASI_CRM_Module__c WHERE ASI_CRM_Payment_Request__c =: paymentrequest.Id];
        Date TodayDateBefore3= Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        
        for(ASI_CRM_Module__c ModuleTemp:PaymentModuleList){
            ModuleTemp.ASI_CRM_End_Date__c=PO_Start_Date.addMonths(1)-1;
        }
        test.startTest();
        update PaymentModuleList;

        List<ASI_CRM_Module__c> psfModules = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_Module__c> fcModules = new List<ASI_CRM_Module__c>();
        for (ASI_CRM_Module__c module : PaymentModuleList) {
            if (module.ASI_CRM_Line_Type__c == 'PSF') {
                psfModules.add(module);
            }
            if (module.ASI_CRM_Line_Type__c == 'Fixed') {
                fcModules.add(module);
            }
        }
        
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= [SELECT Id,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                                                     ASI_CRM_Subbrand__r.ASI_MFM_Brand__c FROM ASI_CRM_Subbrand_Volume__c];

        Integer subIndex = 0;
        Id tempGradeId;
        Id tempCategroyId;
        List<Id> deletevolumes = new List<Id>();
        for (ASI_CRM_Subbrand_Volume__c volume : SubbrandVolumeList) {
            if (subIndex == 0 ) {
                tempGradeId = volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                tempCategroyId = volume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c;
            }
            if (volume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c == tempGradeId || volume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c == tempCategroyId) {
                deletevolumes.add(volume.Id);
            }
            subIndex++;
        }

        Database.delete(deletevolumes);

        List<ASI_TH_CRM_PaymentRequestLineItem__c> items = [SELECT Id,ASI_CRM_Non_Contract_Line__c, ASI_CRM_Module__r.ASI_CRM_Line_Type__c, ASI_TH_CRM_Payment_Request__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__c =: paymentrequest.Id];
        for (ASI_TH_CRM_PaymentRequestLineItem__c item : items) {
            if (item.ASI_CRM_Module__r.ASI_CRM_Line_Type__c == 'Variable Event Cost') {
                item.ASI_CRM_Non_Contract_Line__c = false;
            } else {
                item.ASI_CRM_Non_Contract_Line__c = true;
            }
        }
        update items;
        
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);
        con2.saveItems();
        

        
        con2.GenerateBRSFVol();
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[0].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[1].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[2].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[3].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[0].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[1].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[2].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        // ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[3].ASI_CRM_Parent_Module__c);
        // con1.GenerateFixedVol();

        System.debug('after test.startTest con2.GeneratePSFVol SOQL: ' + Limits.getQueries());

        con2.GenerateVECVol();
        con2.ErrorHandling('测试');
        test.stopTest(); 
    }

    static testMethod void EditHeavyPaymentDetailCtrlTest2() {
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.BypassTriggers__c = 'ASI_CRM_CN_Contract_TriggerClass';
        update currentUser;
        test.startTest();
        ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash'];
        List<ASI_CRM_Module__c> PaymentModuleList = [SELECT ASI_CRM_End_Date__c, ASI_CRM_Volume_Base__c ,ASI_CRM_Line_Type__c,ASI_CRM_Parent_Module__c, ASI_CRM_Parent_Module__r.ASI_CRM_Contract__c FROM ASI_CRM_Module__c WHERE ASI_CRM_Payment_Request__c =: paymentrequest.Id];
        List<ASI_CRM_Module__c> psfModules = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_Module__c> fcModules = new List<ASI_CRM_Module__c>();
        ASI_CRM_Module__c vecModule = new ASI_CRM_Module__c();
        for (ASI_CRM_Module__c module : PaymentModuleList) {
            if (module.ASI_CRM_Line_Type__c == 'PSF') {
                psfModules.add(module);
            }
            if (module.ASI_CRM_Line_Type__c == 'Fixed') {
                fcModules.add(module);
            }
            if (module.ASI_CRM_Line_Type__c == 'Variable Event Cost') {
                vecModule = module;
            }
        }
        ASI_CRM_Module__c vecConModule = new ASI_CRM_Module__c(Id = vecModule.ASI_CRM_Parent_Module__c);
        // DELETE [SELECT Id FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_Module__c =: vecConModule.Id];
        // DELETE [SELECT Id FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_CRM_Module__c =: vecModule.Id];

        vecConModule.ASI_CRM_Volume_Base__c = 'By Grade';
        vecModule.ASI_CRM_Volume_Base__c = 'By Grade';
        update vecConModule;
        update vecModule;
        
        ASI_CRM_Sub_Brand_Grade__c grade = [SELECT Id FROM ASI_CRM_Sub_Brand_Grade__c LIMIT 1];
        ASI_HK_CRM_Product_Category__c category = [SELECT Id FROM ASI_HK_CRM_Product_Category__c LIMIT 1];

        ASI_CRM_CN_Contract_BRSF_Line_Item__c vecGradeLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=vecModule.ASI_CRM_Parent_Module__r.ASI_CRM_Contract__c,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=vecConModule.Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grade.Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') );
        insert vecGradeLine;
        ASI_TH_CRM_PaymentRequestLineItem__c vecGradePaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=paymentrequest.Id,ASI_CRM_Non_Contract_Line__c=true,ASI_CRM_Module__c=vecModule.Id,recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC'),ASI_CRM_Sub_Brand_Grade__c=grade.Id);

        insert vecGradePaymentLine;
        
        // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c());
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);
        con2.ResetVECDetails();
        con2.GenerateVECVol();
        con2.ResetBRSFDetails();
        ApexPages.CurrentPage().getparameters().put('PARAMID', psfModules[0].ASI_CRM_Parent_Module__c);
        con2.ResetPSFDetails();
        ApexPages.currentPage().getParameters().put('PARAMIDF', fcModules[0].ASI_CRM_Parent_Module__c);
        con2.ResetFixedDetails();

        DELETE vecGradeLine;
        DELETE vecGradePaymentLine;

        vecConModule.ASI_CRM_Volume_Base__c = 'By Category';
        vecModule.ASI_CRM_Volume_Base__c = 'By Category';
        update vecConModule;
        update vecModule;

        

        ASI_CRM_CN_Contract_BRSF_Line_Item__c vecCategroyLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=vecModule.ASI_CRM_Parent_Module__r.ASI_CRM_Contract__c,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=vecConModule.Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=category.Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') );
        insert vecCategroyLine;

        ASI_TH_CRM_PaymentRequestLineItem__c vecCategroyPaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=paymentrequest.Id,ASI_CRM_Non_Contract_Line__c=true,ASI_CRM_Module__c=vecModule.Id,recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC'),ASI_CRM_Product_Category__c=category.Id);
        insert vecCategroyPaymentLine;

        // ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con3 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);
        // con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c='By Category';
        con3.GenerateVECVol();
        
        // DELETE vecCategroyLine;
        // DELETE vecCategroyPaymentLine;

        // vecConModule.ASI_CRM_Volume_Base__c = 'By Total';
        // vecModule.ASI_CRM_Volume_Base__c = 'By Total';
        // update vecConModule;
        // update vecModule;

        

        // ASI_CRM_CN_Contract_BRSF_Line_Item__c vecTotalLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=vecModule.ASI_CRM_Parent_Module__r.ASI_CRM_Contract__c,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
        //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=vecConModule.Id,
        //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=4,
        //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
        //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
        //                                                                ASI_CRM_CN_Sub_Brand__c=null,
        //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') );
        // insert vecTotalLine;

        // ASI_TH_CRM_PaymentRequestLineItem__c vecTotalPaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=paymentrequest.Id,ASI_CRM_Non_Contract_Line__c=true,ASI_CRM_Module__c=vecModule.Id,recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC'));
        // insert vecTotalPaymentLine;

        // ASI_CRM_CN_EditHeavyPaymentDetailCtrl con4 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);

        // con4.GenerateVECVol();

        test.stopTest();
    }

    static testMethod void EditHeavyPaymentDetailCtrlTest5() {
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.BypassTriggers__c = 'ASI_CRM_CN_Contract_TriggerClass';
        update currentUser;
        test.startTest();
        ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash'];
        List<ASI_CRM_Module__c> PaymentModuleList = [SELECT ASI_CRM_End_Date__c, ASI_CRM_Volume_Base__c ,ASI_CRM_Line_Type__c,ASI_CRM_Parent_Module__c, ASI_CRM_Parent_Module__r.ASI_CRM_Contract__c FROM ASI_CRM_Module__c WHERE ASI_CRM_Payment_Request__c =: paymentrequest.Id];
        List<ASI_CRM_Module__c> psfModules = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_Module__c> fcModules = new List<ASI_CRM_Module__c>();
        ASI_CRM_Module__c vecModule = new ASI_CRM_Module__c();
        for (ASI_CRM_Module__c module : PaymentModuleList) {
            if (module.ASI_CRM_Line_Type__c == 'PSF') {
                psfModules.add(module);
            }
            if (module.ASI_CRM_Line_Type__c == 'Fixed') {
                fcModules.add(module);
            }
            if (module.ASI_CRM_Line_Type__c == 'Variable Event Cost') {
                vecModule = module;
            }
        }
        ASI_CRM_Module__c vecConModule = new ASI_CRM_Module__c(Id = vecModule.ASI_CRM_Parent_Module__c);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        vecConModule.ASI_CRM_Volume_Base__c = 'By Total';
        vecModule.ASI_CRM_Volume_Base__c = 'By Total';
        update vecConModule;
        update vecModule;

        

        ASI_CRM_CN_Contract_BRSF_Line_Item__c vecTotalLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=vecModule.ASI_CRM_Parent_Module__r.ASI_CRM_Contract__c,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=vecConModule.Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') );
        insert vecTotalLine;

        ASI_TH_CRM_PaymentRequestLineItem__c vecTotalPaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=paymentrequest.Id,ASI_CRM_Non_Contract_Line__c=true,ASI_CRM_Module__c=vecModule.Id,recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC'));
        insert vecTotalPaymentLine;

        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con4 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);

        con4.GenerateVECVol();

        test.stopTest();
    }
}