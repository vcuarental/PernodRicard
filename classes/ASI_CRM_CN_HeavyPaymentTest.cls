@isTest
public class ASI_CRM_CN_HeavyPaymentTest {
    
    
    static testMethod void HeavyPSFFormControllerTest1() {
        
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
        Id rnsRecordId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number');
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = rnsRecordId));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = rnsRecordId));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = rnsRecordId));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = rnsRecordId));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = rnsRecordId));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        Id ProductCategoryId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category');
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = ProductCategoryId));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = ProductCategoryId));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = ProductCategoryId));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        Id SubCategoryId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category');
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = SubCategoryId));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = SubCategoryId));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = SubCategoryId));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        Id BrandId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand');
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = BrandId));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = BrandId));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = BrandId));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        Id gradesId = Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade');
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId = gradesId));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='Test1', RecordTypeId = gradesId));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='Test1',RecordTypeId = gradesId));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        Id subBrandsId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=subBrandsId,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=subBrandsId,
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=subBrandsId,
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=subBrandsId,
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
        Id ACCodeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = ACCodeId ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = ACCodeId ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = ACCodeId ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = ACCodeId ));
        
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
        
        
        Date TodayDateBefore3= system.today().addMonths(-5); 
        
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        //Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        system.debug('PO_Start_Date: '+PO_Start_Date);
        // Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(6)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
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
        Id ContractCostId = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost');
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = ContractCostId );
        ContractCostList.add(contractCost1);
        ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = ContractCostId );
        ContractCostList.add(contractCost2);
        
        insert ContractCostList;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        Id contractListId = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = contractListId ));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = contractListId));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = contractListId ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = contractListId ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = contractListId ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = contractListId));
        }
        
        insert ContractLineList;
        test.startTest();

        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        Id PaymentRequestId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_OutletWS__c=Customers[0].Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = PaymentRequestId));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',ASI_CRM_CN_OutletWS__c=Customers[0].Id,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = PaymentRequestId));
        insert PaymentRequestList;
        
        List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
        for(ASI_CRM_Module__c ModuleTemp:ModuleList){
            PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
                                                        ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
                                                        ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
        }
        
        insert PaymentModuleList;
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList= new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        Id paymentRequestBRSF = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        Id paymentRequestPSF = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
        Id paymentRequestVEC = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
            ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=PaymentRequestList[0].Id);
            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                PaymentLine.ASI_CRM_CN_Sub_Brand__c=ContractLine.ASI_CRM_CN_Sub_Brand__c;
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[0].Id;
                PaymentLine.recordtypeid = paymentRequestBRSF;
                PaymentLine=ASI_CRM_CN_HeavyContractTestClassHelper.PaymentLineFieldAssignment(PaymentLine);
            }
            if(ContractLine.ASI_CRM_Type__c=='PSF'){
                PaymentLine.ASI_CRM_Volume_Base__c=ContractLine.ASI_CRM_Volume_Base__c;
                PaymentLine.ASI_CRM_CN_Incentive_BT__c=100;
                PaymentLine.recordtypeid = paymentRequestPSF;
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
                PaymentLine.recordtypeid = paymentRequestVEC;
            }
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        
        
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }
        insert SubbrandVolumeList;
      
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[0]);
        ASI_CRM_CN_HeavyPSFFormController con1 = new ASI_CRM_CN_HeavyPSFFormController(stdController1);
        con1.PageId=PaymentRequestList[0].Id;
        con1.dummyVar=true;
        con1.init();
        con1.SBGradeSorting(3);
        con1.SBGradeSorting(32);
        con1.SBGradeSorting(333);
        con1.SBGradeSorting(3444);
        con1.KeyNameSortingASC(33);
        con1.KeyNameSortingASC(333);
        con1.KeyNameSortingASC(3333);
        
        test.stopTest(); 
    }
    
    
    
    
    
    
    static testMethod void ASI_CRM_CN_HeavyBRSFFormTest1() {
        
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='Test1',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='Test1',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        
        
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        system.debug('PO_Start_Date: '+PO_Start_Date);
        // Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(6)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
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
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,ASI_CRM_CN_Est_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        test.startTest();

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
                PaymentLine.ASI_CRM_CN_Sub_Brand__c=ContractLine.ASI_CRM_CN_Sub_Brand__c;
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
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        
        
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }

        insert SubbrandVolumeList;
      
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[0]);
        ASI_CRM_CN_HeavyBRSFFormCtrl con1 = new ASI_CRM_CN_HeavyBRSFFormCtrl(stdController1);
        con1.PageId=PaymentRequestList[0].Id;
        con1.init();
        con1.SBGradeSorting(3);
        con1.SBGradeSorting(32);
        con1.SBGradeSorting(333);
        con1.SBGradeSorting(3444);
        test.stopTest(); 
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    static testMethod void EditHeavyPaymentDetailCtrlTest1() {
        //Test ASI_CRM_CN_EditHeavyPaymentDetailCtrl
        
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
        
        
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        
        // Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(6)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
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
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }

        insert SubbrandVolumeList;


        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[0]);
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con1 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController1);
        con1.saveItems();
        
        con1.GenerateBRSFVol();
        con1.GeneratePSFVol();
        con1.GenerateVECVol();
        con1.saveItems();
        con1.CancelProcess();

        for(ASI_CRM_Module__c ModuleTemp:PaymentModuleList){
            ModuleTemp.ASI_CRM_End_Date__c=PO_Start_Date.addMonths(1)-1;
        }
        update PaymentModuleList;
        
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);
        con2.saveItems();
        
        con2.GenerateBRSFVol();
        ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[1].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[2].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[3].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();
        
        ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[4].ASI_CRM_Parent_Module__c);
        con2.GeneratePSFVol();

        System.debug('after test.startTest con2.GeneratePSFVol SOQL: ' + Limits.getQueries());

        con2.GenerateVECVol();
        
        // con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c='By Grade';
        // con2.GenerateVECVol();
        
        // con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c='By Category';
        // con2.GenerateVECVol();
        
        // con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c='By Total';
        // con2.GenerateVECVol();

        // System.debug('after test.startTest con2.GenerateVECVol SOQL: ' + Limits.getQueries());
        // // con2.saveItems();
        // // con2.CancelProcess();
        
        
        // con2.ResetBRSFDetails();
        // con2.ResetPSFDetails();
        // con2.ResetVECDetails();
        
        
        test.stopTest(); 
    }

    static testMethod void EditHeavyPaymentDetailCtrlTest2() {
        //Test ASI_CRM_CN_EditHeavyPaymentDetailCtrl
        
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
        
        
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        
        // Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(6)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
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
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[0].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }

        insert SubbrandVolumeList;


        // ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[0]);
        // ASI_CRM_CN_EditHeavyPaymentDetailCtrl con1 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController1);
        // con1.saveItems();
        
        // con1.GenerateBRSFVol();
        // con1.GeneratePSFVol();
        // con1.GenerateVECVol();
        // con1.saveItems();
        // con1.CancelProcess();

        for(ASI_CRM_Module__c ModuleTemp:PaymentModuleList){
            ModuleTemp.ASI_CRM_End_Date__c=PO_Start_Date.addMonths(1)-1;
        }
        update PaymentModuleList;
        
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_EditHeavyPaymentDetailCtrl con2 = new ASI_CRM_CN_EditHeavyPaymentDetailCtrl(stdController2);
        con2.saveItems();
        
        // con2.GenerateBRSFVol();
        // ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[1].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();
        
        // ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[2].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();
        
        // ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[3].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();
        
        // ApexPages.CurrentPage().getparameters().put('PARAMID', PaymentModuleList[4].ASI_CRM_Parent_Module__c);
        // con2.GeneratePSFVol();

        // System.debug('after test.startTest con2.GeneratePSFVol SOQL: ' + Limits.getQueries());

        // con2.GenerateVECVol();
        
        con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c='By Grade';
        con2.GenerateVECVol();
        
        con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c='By Category';
        con2.GenerateVECVol();
        
        con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c='By Total';
        con2.GenerateVECVol();

        System.debug('after test.startTest con2.GenerateVECVol SOQL: ' + Limits.getQueries());
        // con2.saveItems();
        // con2.CancelProcess();
        
        
        con2.ResetBRSFDetails();
        con2.ResetPSFDetails();
        con2.ResetVECDetails();
        
        
        test.stopTest(); 
    }
    
    
    
    
    
    
    static testMethod void EditHeavyPaymentHeaderTest1() {
        //Test ASI_CRM_CN_EditHeavyPaymentHeaderCtrl
        
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
        
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
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
                                                                ASI_CRM_CN_Adjustment__c=80,ASI_CRM_CN_Description__c='test',
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
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
            }
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        
        

        
        
        ApexPages.Standardcontroller stdController0 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_EditHeavyPaymentHeaderCtrl con0 = new ASI_CRM_CN_EditHeavyPaymentHeaderCtrl(stdController0);
        con0.UpdateRecord();
        
        
        ApexPages.CurrentPage().getparameters().put('contractid', Contract.id);
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_EditHeavyPaymentHeaderCtrl con1 = new ASI_CRM_CN_EditHeavyPaymentHeaderCtrl(stdController1);
        con1.PH.ASI_TH_CRM_Contract__c=Contract.id;
        con1.PH.ASI_CRM_CN_OutletWS__c=Customers[0].Id;
        con1.PH.ASI_CRM_CN_Payment_Type__c = 'Cash';
        con1.PH.ASI_CRM_CN_Description__c='test1';
        con1.UpdateRecord();
        con1.doCancel();
        
        
        ApexPages.CurrentPage().getparameters().put('id', PaymentRequestList[0].id);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_EditHeavyPaymentHeaderCtrl con2 = new ASI_CRM_CN_EditHeavyPaymentHeaderCtrl(stdController2);
        con2.UpdateRecord();
        
        test.stopTest(); 
    }
    
    
    static testMethod void Heavy_PR_TriggerClsTest1() {
        
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
        
        update new User(Id=LUser[0].id, BypassTriggers__c='');
        //update new User(Id=UserInfo.getUserId(), BypassTriggers__c='');
        map<String, Id> mapObjTypeDevNameId = new map<String, Id>();
        map<Id, RecordType> mapIdRt = new map<Id, RecordType>([SELECT Id, DeveloperName, Description, Name, IsActive, SystemModstamp, SobjectType, NamespacePrefix, LastModifiedDate,LastModifiedById, IsPersonType, CreatedDate, CreatedById, BusinessProcessId FROM RecordType]);
        for(RecordType rt: mapIdRt.values()){
            mapObjTypeDevNameId.put(rt.SobjectType+rt.DeveloperName, rt.Id);
            
        }        
        List<ASI_CRM_Dynamic_Approval_Route__c> DynamicApprovalRouteList = new List<ASI_CRM_Dynamic_Approval_Route__c>();
        ASI_CRM_Dynamic_Approval_Route__c dar = new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Contract',ASI_CRM_Approval_Limit__c=1,ASI_CRM_User__c=LUser[0].id);
        DynamicApprovalRouteList.add(dar);
        ASI_CRM_Dynamic_Approval_Route__c dar2 = new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Contract',ASI_CRM_Approval_Limit__c=1,ASI_CRM_User__c=userInfo.getUserId(),ASI_CRM_End_of_Dynamic_Route__c=true);
        DynamicApprovalRouteList.add(dar2);
        
        insert DynamicApprovalRouteList;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c( ASI_CRM_Sales_Team__c = 'a', ASI_CRM_CN_Approver_1__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_2__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_3__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_4__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_5__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_6__c = userInfo.getUserId(), ASI_CRM_CN_Approver_7__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_8__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_9__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_10__c = userList[1].Id
                                                   ,ASI_CRM_RVP__c= userList[1].Id,ASI_CRM_CN_Regional_BA__c= userInfo.getUserId()
                                                   , ASI_CRM_CN_Approval_Limit_1__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_2__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_3__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_4__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_5__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_6__c = -999999, ASI_CRM_CN_Approval_Limit_7__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_8__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_9__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_10__c = -999999
                                                   ,ASI_CRM_CN_Type__c = 'Heavy Contract On Payment',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-999999));
        fars.add(new ASI_CRM_Fix_Approval_Route__c( ASI_CRM_Sales_Team__c = 'a', ASI_CRM_CN_Approver_1__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_2__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_3__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_4__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_5__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_6__c = userInfo.getUserId(), ASI_CRM_CN_Approver_7__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_8__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_9__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_10__c = userList[1].Id
                                                   ,ASI_CRM_RVP__c= userList[1].Id,ASI_CRM_CN_Regional_BA__c= userInfo.getUserId()
                                                   , ASI_CRM_CN_Approval_Limit_1__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_2__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_3__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_4__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_5__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_6__c = -999999, ASI_CRM_CN_Approval_Limit_7__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_8__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_9__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_10__c = -999999
                                                   ,ASI_CRM_CN_Type__c = 'Heavy Contract On Last Payment',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-999999));
        insert fars;
        
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = mapObjTypeDevNameId.get('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=mapObjTypeDevNameId.get('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=mapObjTypeDevNameId.get('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        
        Id rtOutlet = mapObjTypeDevNameId.get('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        Id rnsId = mapObjTypeDevNameId.get('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number');
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = rnsId));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = rnsId));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = rnsId));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = rnsId));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = rnsId));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        Id ProductCategoryId = mapObjTypeDevNameId.get('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category');
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = ProductCategoryId));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = ProductCategoryId));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = ProductCategoryId));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        Id subCategoryId = mapObjTypeDevNameId.get('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category');
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = subCategoryId));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = subCategoryId));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = subCategoryId));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        Id brandId = mapObjTypeDevNameId.get('ASI_MFM_Brand__cASI_FOC_CN_Brand');
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = brandId));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = brandId));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = brandId));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        Id gradesId = mapObjTypeDevNameId.get('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade');
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId= gradesId));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=gradesId));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=gradesId));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        Id subBrandsId = mapObjTypeDevNameId.get('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=subBrandsId,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=subBrandsId,
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=subBrandsId,
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=subBrandsId,
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        
        
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        Id accodeId = mapObjTypeDevNameId.get('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = accodeId ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = accodeId ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = accodeId ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = accodeId ));
        
        insert ACCodeList;
        
        
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=mapObjTypeDevNameId.get('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = mapObjTypeDevNameId.get('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = mapObjTypeDevNameId.get('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M02',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M04',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M05',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        Id ContractCostId = mapObjTypeDevNameId.get('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost');
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = ContractCostId );
        ContractCostList.add(contractCost1);
        ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = ContractCostId );
        ContractCostList.add(contractCost2);
        
        insert ContractCostList;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        Id outletId = mapObjTypeDevNameId.get('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = outletId));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = outletId));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = outletId ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = outletId ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = outletId ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = outletId));
        }
        
        insert ContractLineList;
        
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        Id PaymentReuestId = mapObjTypeDevNameId.get('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ownerId = userList[0].id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Is_Dolphin_Auto_Payment__c = true,
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = PaymentReuestId));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',ownerId = userList[0].id,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_Is_Dolphin_Auto_Payment__c = true,
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = PaymentReuestId));
        insert PaymentRequestList;
        
        
        test.startTest();
        //test ASI_CRM_CN_Heavy_PR_TriggerCls
        ASI_CRM_CN_Heavy_PR_TriggerCls.setApproverByCount(PaymentRequestList[0],7,userList[0].Id);
        ASI_CRM_CN_Heavy_PR_TriggerCls.setApproverByCount(PaymentRequestList[0],8,userList[0].Id);
        ASI_CRM_CN_Heavy_PR_TriggerCls.setApproverByCount(PaymentRequestList[0],9,userList[0].Id); 
        ASI_CRM_CN_Heavy_PR_TriggerCls.setApproverByCount(PaymentRequestList[0],10,userList[0].Id);
         ASI_CRM_CN_Heavy_PR_TriggerCls.setReturnApproverByCount(PaymentRequestList[0],7,userList[0].Id);
        ASI_CRM_CN_Heavy_PR_TriggerCls.setReturnApproverByCount(PaymentRequestList[0],8,userList[0].Id);
        ASI_CRM_CN_Heavy_PR_TriggerCls.setReturnApproverByCount(PaymentRequestList[0],9,userList[0].Id);
        ASI_CRM_CN_Heavy_PR_TriggerCls.setReturnApproverByCount(PaymentRequestList[0],10,userList[0].Id);
        ASI_CRM_CN_Heavy_PR_TriggerCls.generatesendEmailAlert(Contract, userInfo.getUserId());
        ASI_TH_CRM_PaymentRequest__c p1 = PaymentRequestList[0];

        p1.ASI_CRM_CN_Return_Flag__c=true;
        p1.ASI_CRM_RVP_Approval__c=true;
        update PaymentRequestList;
        
        
        // PaymentRequestList[0].ASI_CRM_RVP_Approval__c=true;
        // update PaymentRequestList;
        
        // PaymentRequestList[0].ASI_CRM_CN_Return_Flag__c=false;
        // update PaymentRequestList;
        
        // delete PaymentRequestList[0];
        
        test.stopTest(); 
    }
    
    
    
    
    
    
    static testMethod void HeavyPaymentTest1() {
        //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
        //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();
        

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
        
        
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Automated, Do not Change',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
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
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
            }
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;
        

        

        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(stdController2);
        
        con2.AutoPOModification();
        test.stopTest(); 
    }
    
    
    
    static testMethod void HeavyPaymentTest2() { //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
        //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();
        
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
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert new List<ASI_CRM_SpecialPromotionTypeSetting__c>{oldspts,newspts};
        
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
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
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

        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        insert PaymentRequestList;

        List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
        for(ASI_CRM_Module__c ModuleTemp:ModuleList){
            PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
                                                        ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
                                                        ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
        }
        
        insert PaymentModuleList;
        test.startTest();

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
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
            }
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;

        ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(new ApexPages.StandardController(PaymentRequestList[0]));
        
        
         
        
        System.debug(Limits.getDMLRows());

        con2.Calculation();
        con2.GoEditPayee();
        con2.GoEditHeader();
        
        
        
        test.stopTest();
    }
    static testMethod void HeavyPaymentTest3() { //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
        //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();

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
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert new List<ASI_CRM_SpecialPromotionTypeSetting__c>{oldspts,newspts};

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
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
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

        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

        insert PaymentRequestList;

        List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
        for(ASI_CRM_Module__c ModuleTemp:ModuleList){
            PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
                                                        ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
                                                        ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
        }

        insert PaymentModuleList;
        test.startTest();

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
                PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
                PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
            }
            PaymentRequestLineList.add(PaymentLine);
        }
        insert PaymentRequestLineList;

        ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(new ApexPages.StandardController(PaymentRequestList[0]));


        // comment 20180209
        con2.GoToCheckPoint();

        con2.GoReturn();
        con2.GoEditDetailPage();

        //test case
        con2.NameSortingASC(99);
        con2.NameSortingASC(999);
        con2.NameSortingASC(9999);

        con2.MethodologyRoute('M01',1,2,3);
        con2.MethodologyRoute('M01',3,2,3);
        con2.MethodologyRoute('M01',null,null,3);
        con2.MethodologyRoute('M02',1,null,3);
        con2.MethodologyRoute('M02',1,0.0002,3);
        con2.MethodologyRoute('M02',1,2,3);

        con2.MethodologyRoute('M03',999,2,3);
        con2.MethodologyRoute('M03',1,2,3);
        con2.MethodologyRoute('M04',1,2,3);
        con2.MethodologyRoute('M05',1,2,3);
        con2.GeneratingIncentive('Premium','BRSFIncentive');
        con2.GeneratingIncentive('Premium','PSFMax');


        PaymentRequestList[0].ASI_TH_CRM_Status__c = 'Submitted';
        update PaymentRequestList;
        con2.GoReturn();


        test.stopTest();
    }

    
    
    
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST1() {
        //ASI_CRM_CN_HeavyContractTestClassHelper.createWholesalerAndOutlet();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c channelGroup = new ASI_CRM_CN_Channel_Group__c(ASI_CRM_Channel_Group_Code__c='CN_WS Channel');
        insert channelGroup;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(
            ASI_CRM_For_Outlet__c = true,
            Name = 'Restaurant',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
            ASI_CRM_CN_Channel_Group__c = channelGroup.Id,
            ASI_CRM_CN_On_Off__c = 'OFF'
        );
        insert newChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2ss = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2ss.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Prestige',
                RecordTypeId = rtWS,
                Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.Id
            )
        );
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST2',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2ss;
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];

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
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
        );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Sub_Brand__c=null,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
        ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_CRM_CN_Payment_Type__c = 'Cash',
                                                 ASI_CRM_CN_Adjustment__c=80,
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                 ASI_TH_CRM_Status__c='Submitted',
                                                 ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_TH_CRM_Status__c='Approved',
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        test.startTest();
        ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_PaymentRequest__c());
        ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
        con.refresh();
        con.updateRecord();
        con.BRSFReport();
        /*
        ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
        sc = new ApexPages.standardController(prs[0]);
        con = new ASI_CRM_CN_Payment_Header_Controller(sc);
        con.GoReturn();
        con.CancelBRSFChange();
        con.cancel();
        con.digit_formatting(3,19999999);
        con.digit_formatting(3,1);
        con.saveDate();
        con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(10);
        con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addDays(10);
        con.saveDate();
        con.PSFReport();
        con.BRSFReport();
        con.doCancel();
        con.GoURL();
        con.GoEditHeader();
        con.GoEditDetail();
        con.GoEditPayee();

        con.updatePOVersion();
        con.updateRecord();
        con.regenerateBRSFVol();
        con.updatePayeeRecord();
        con.submitApproval();
        con.refresh();
        con.updateDetailRecord();

        con.addNew_Cash();
        con.addNew_Discount();
        con.addNew_CD(); 
        con.updatePayeeRecord();

        con.addNew_Cash();
        con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
        con.clone_Cash();
        for(integer i : con.Payee_Item_Map_CASH.keyset()){
        con.rowidCASH = i;
        con.RemoveRow_Cash();
        }

        con.addNew_Discount();
        con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
        con.clone_Discount();
        for(integer i : con.Payee_Item_Map_Discount.keyset()){
        con.rowidDiscount = i;
        con.RemoveRow_Discount();
        }

        con.addNew_CD();            
        con.rowidCD = con.Payee_Item_Map_CD.size()-1;
        con.clone_CD();
        for(integer i : con.Payee_Item_Map_CD.keyset()){
        con.rowidCD = i;
        con.RemoveRow_CD();
        }
        con.updatePayeeRecord();


        con.addNew_PSF();
        con.updatePSF();
        con.rowidPSF = con.PSF_Item_Map.size()-1;
        con.clone_PSF();
        for(integer i : con.PSF_Item_Map.keyset()){
        con.rowidPSF = i;
        con.removeRow_PSF();
        }            
        con.updatePSF();
        */
        ASI_CRM_CN_Payment_Header_Controller.findCashPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        ASI_CRM_CN_Payment_Header_Controller.findDiscountPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();   
    }
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST2() {
        //ASI_CRM_CN_HeavyContractTestClassHelper.createWholesalerAndOutlet();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c channelGroup = new ASI_CRM_CN_Channel_Group__c(ASI_CRM_Channel_Group_Code__c='CN_WS Channel');
        insert channelGroup;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(
            ASI_CRM_For_Outlet__c = true,
            Name = 'Restaurant',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
            ASI_CRM_CN_Channel_Group__c = channelGroup.Id,
            ASI_CRM_CN_On_Off__c = 'OFF'
        );
        insert newChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2ss = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2ss.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Prestige',
                RecordTypeId = rtWS,
                Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.Id
            )
        );
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST2',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2ss;
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];
        
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
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id
        );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Sub_Brand__c=null,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
        ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_CRM_CN_Payment_Type__c = 'Cash',
                                                 ASI_CRM_CN_Adjustment__c=80,
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_TH_CRM_Status__c='Approved',
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        test.startTest();
        ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST3() {
        //ASI_CRM_CN_HeavyContractTestClassHelper.createWholesalerAndOutlet();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c channelGroup = new ASI_CRM_CN_Channel_Group__c(ASI_CRM_Channel_Group_Code__c='CN_WS Channel');
        insert channelGroup;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(
            ASI_CRM_For_Outlet__c = true,
            Name = 'Restaurant',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
            ASI_CRM_CN_Channel_Group__c = channelGroup.Id,
            ASI_CRM_CN_On_Off__c = 'OFF'
        );
        insert newChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2ss = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2ss.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Prestige',
                RecordTypeId = rtWS,
                Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.Id
            )
        );
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST2',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2ss;
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        ASI_CRM_SpecialPromotionTypeSetting__c specialPromotion = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_New_FY_Promotion_Type__c = true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert specialPromotion;
        
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
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addMonths(-6),
            ASI_CRM_CN_PO_End_Date__c = system.today().addMonths(1),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
        );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Sub_Brand__c=null,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
        ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_CRM_CN_Payment_Type__c = 'Cash',
                                                 ASI_CRM_CN_Adjustment__c=80,
                                                 ASI_CRM_CN_Overpayment_Reason__c='其他－需填写具体原因',
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addMonths(-5),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addMonths(-2),
                                                 ASI_TH_CRM_Status__c='Submitted',
                                                 ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_TH_CRM_Status__c='Approved',
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_PaymentRequest__c());
        ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
        con.othertype = null;
        con.payableAmount = null;
        con.OverPaymentReason = null;
        con.OtherReason = null;
        con.division = null;
        con.BRSF_Item_Map = null;
        con.Save_BRSF_Item = null;
        con.OTP_Item_Map = null;
        con.Save_OTP_Item = null;
        
        con.refresh();
        con.updateRecord();
        con.BRSFReport();
        
        ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
        sc = new ApexPages.standardController(prs[0]);
        con = new ASI_CRM_CN_Payment_Header_Controller(sc);
        //con.GoReturn();
        con.CancelBRSFChange();
        //con.cancel();
        con.digit_formatting(3,19999999);
        con.digit_formatting(3,1);
        con.saveDate();
        con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addMonths(-8);
        con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addMonths(1);
        con.saveDate();
        //con.PSFReport();
        //con.BRSFReport();
        //con.doCancel();
        //con.GoURL();
        con.GoEditHeader();
        con.GoEditDetail();
        con.GoEditPayee();
        
        con.updatePOVersion();
        con.updateRecord();
        con.regenerateBRSFVol();
        con.updatePayeeRecord();
        
        /*
        con.refresh();
        con.updateDetailRecord();

        con.addNew_Cash();
        con.addNew_Discount();
        con.addNew_CD(); 
        con.updatePayeeRecord();

        con.addNew_Cash();
        con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
        con.clone_Cash();
        for(integer i : con.Payee_Item_Map_CASH.keyset()){
        con.rowidCASH = i;
        con.RemoveRow_Cash();
        }

        con.addNew_Discount();
        con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
        con.clone_Discount();
        for(integer i : con.Payee_Item_Map_Discount.keyset()){
        con.rowidDiscount = i;
        con.RemoveRow_Discount();
        }

        con.addNew_CD();            
        con.rowidCD = con.Payee_Item_Map_CD.size()-1;
        con.clone_CD();
        for(integer i : con.Payee_Item_Map_CD.keyset()){
        con.rowidCD = i;
        con.RemoveRow_CD();
        }
        con.updatePayeeRecord();


        con.addNew_PSF();
        con.updatePSF();
        con.rowidPSF = con.PSF_Item_Map.size()-1;
        con.clone_PSF();
        for(integer i : con.PSF_Item_Map.keyset()){
        con.rowidPSF = i;
        con.removeRow_PSF();
        }            
        con.updatePSF();

        */
        test.stopTest();   
    }
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST4() {
        //ASI_CRM_CN_HeavyContractTestClassHelper.createWholesalerAndOutlet();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c channelGroup = new ASI_CRM_CN_Channel_Group__c(ASI_CRM_Channel_Group_Code__c='CN_WS Channel');
        insert channelGroup;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(
            ASI_CRM_For_Outlet__c = true,
            Name = 'Restaurant',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
            ASI_CRM_CN_Channel_Group__c = channelGroup.Id,
            ASI_CRM_CN_On_Off__c = 'OFF'
        );
        insert newChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2ss = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2ss.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Prestige',
                RecordTypeId = rtWS,
                Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.Id
            )
        );
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST2',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2ss;
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];
        
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
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
        );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Sub_Brand__c=null,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
        ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_CRM_CN_Payment_Type__c = 'Cash',
                                                 ASI_CRM_CN_Adjustment__c=80,
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                 ASI_TH_CRM_Status__c='Submitted',
                                                 ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_TH_CRM_Status__c='Approved',
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        test.startTest();
        
        ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
        ApexPages.StandardController  sc = new ApexPages.standardController(prs[0]);
        ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
        con.GoReturn();
        con.CancelBRSFChange();
        con.cancel();
        con.digit_formatting(3,19999999);
        con.digit_formatting(3,1);
        con.saveDate();
        con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(10);
        con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addDays(10);
        con.saveDate();
        con.PSFReport();
        con.BRSFReport();
        con.doCancel();
        con.GoURL();
        con.GoEditHeader();
        con.GoEditDetail();
        con.GoEditPayee();
        
        con.updatePOVersion();
        con.updateRecord();
        con.regenerateBRSFVol();
        con.updatePayeeRecord();
        con.submitApproval();
        con.refresh();
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
        con.updateDetailRecord();
        
        /*con.addNew_Cash();
        con.addNew_Discount();
        con.addNew_CD(); 
        con.updatePayeeRecord();
        
        con.addNew_Cash();
        con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
        con.clone_Cash();
        for(integer i : con.Payee_Item_Map_CASH.keyset()){
            con.rowidCASH = i;
            con.RemoveRow_Cash();
        }
        
        con.addNew_Discount();
        con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
        con.clone_Discount();
        for(integer i : con.Payee_Item_Map_Discount.keyset()){
            con.rowidDiscount = i;
            con.RemoveRow_Discount();
        }
        
        con.addNew_CD();            
        con.rowidCD = con.Payee_Item_Map_CD.size()-1;
        con.clone_CD();
        for(integer i : con.Payee_Item_Map_CD.keyset()){
            con.rowidCD = i;
            con.RemoveRow_CD();
        }
        con.updatePayeeRecord();
        
        
        con.addNew_PSF();
        con.updatePSF();
        con.rowidPSF = con.PSF_Item_Map.size()-1;
        con.clone_PSF();
        for(integer i : con.PSF_Item_Map.keyset()){
            con.rowidPSF = i;
            con.removeRow_PSF();
        }            
        con.updatePSF();*/
        
        //ASI_CRM_CN_Payment_Header_Controller.findCashPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //ASI_CRM_CN_Payment_Header_Controller.findDiscountPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //
        //
        //ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        
        //ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();   
    }

    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST5() {
        //ASI_CRM_CN_HeavyContractTestClassHelper.createWholesalerAndOutlet();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c channelGroup = new ASI_CRM_CN_Channel_Group__c(ASI_CRM_Channel_Group_Code__c='CN_WS Channel');
        insert channelGroup;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(
            ASI_CRM_For_Outlet__c = true,
            Name = 'Restaurant',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
            ASI_CRM_CN_Channel_Group__c = channelGroup.Id,
            ASI_CRM_CN_On_Off__c = 'OFF'
        );
        insert newChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2ss = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2ss.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Prestige',
                RecordTypeId = rtWS,
                Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.Id
            )
        );
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2ss.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST2',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2ss;
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];
        
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
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
        );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
            ASI_CRM_CN_Sub_Brand__c=null,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
        ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_CRM_CN_Payment_Type__c = 'Cash',
                                                 ASI_CRM_CN_Adjustment__c=80,
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                 ASI_TH_CRM_Status__c='Submitted',
                                                 ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                 ASI_TH_CRM_Status__c='Approved',
                                                 ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                 ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        test.startTest();
        
        ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
        ApexPages.StandardController  sc = new ApexPages.standardController(prs[0]);
        ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
        con.GoReturn();
        con.CancelBRSFChange();
        con.cancel();
        con.digit_formatting(3,19999999);
        con.digit_formatting(3,1);
        con.saveDate();
        con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(10);
        con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addDays(10);
        con.saveDate();
        /*con.PSFReport();
        con.BRSFReport();
        con.doCancel();
        con.GoURL();
        con.GoEditHeader();
        con.GoEditDetail();
        con.GoEditPayee();
        
        con.updatePOVersion();
        con.updateRecord();
        con.regenerateBRSFVol();
        con.updatePayeeRecord();
        con.submitApproval();
        con.refresh();
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
        con.updateDetailRecord();*/
        
        con.addNew_Cash();
        con.addNew_Discount();
        con.addNew_CD(); 
        con.updatePayeeRecord();
        
        con.addNew_Cash();
        con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
        con.clone_Cash();
        for(integer i : con.Payee_Item_Map_CASH.keyset()){
            con.rowidCASH = i;
            con.RemoveRow_Cash();
        }
        
        con.addNew_Discount();
        con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
        con.clone_Discount();
        for(integer i : con.Payee_Item_Map_Discount.keyset()){
            con.rowidDiscount = i;
            con.RemoveRow_Discount();
        }
        
        con.addNew_CD();            
        con.rowidCD = con.Payee_Item_Map_CD.size()-1;
        con.clone_CD();
        for(integer i : con.Payee_Item_Map_CD.keyset()){
            con.rowidCD = i;
            con.RemoveRow_CD();
        }
        con.updatePayeeRecord();
        
        
        con.addNew_PSF();
        con.updatePSF();
        con.rowidPSF = con.PSF_Item_Map.size()-1;
        con.clone_PSF();
        for(integer i : con.PSF_Item_Map.keyset()){
            con.rowidPSF = i;
            con.removeRow_PSF();
        }            
        con.updatePSF();
        
        //ASI_CRM_CN_Payment_Header_Controller.findCashPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //ASI_CRM_CN_Payment_Header_Controller.findDiscountPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //
        //
        //ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        
        //ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        //ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();   
    }

    static testMethod void interimDataTest() {
        ASI_CRM_Module__c module = new ASI_CRM_Module__c();

        ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData d1 = new ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData();
        ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData d2 = new ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData(false);
        ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData d3 = new ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData(module);
        ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData d4 = new ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData(module, false);
    }

    static testMethod void splitLineIntoRowTest() {
        System.assertEquals('', ASI_CRM_CN_HeavyPaymentUtilitiesClass.SplitLineIntoRow(null, 0));
        System.assertEquals('abc', ASI_CRM_CN_HeavyPaymentUtilitiesClass.SplitLineIntoRow('abc', 0));
        System.assertEquals('自由民<br/>主', ASI_CRM_CN_HeavyPaymentUtilitiesClass.SplitLineIntoRow('自由民主', 3));
    }

    // @TestSetup
    // public static void setupData() {
    //     ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
    //     insert region;
        
    //     ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
    //     insert division;
        
    //     ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
    //     insert area;
        
    //     ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
    //     insert city;
        
    //     ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
    //     insert channel;
        
        
    //     ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
    //     INSERT SegmentationCriteria;
        
        
    //     Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
    //     list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        
    //     Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
    //     insert Customers;
        
    //     //Covered_Outlet
    //     list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
    //     ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
    //     insert ChildCustomers;
        
    //     User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
    //     currentUser.LanguageLocaleKey='zh_CN';
    //     update currentUser;
        
    //     list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
    //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
    //         rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     else{
    //         rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //         rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     }
    //     insert rns;
        
        
        
        
        
    //     List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
    //     ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
    //     ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
    //     ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
    //     insert ProductCategoryList;
        
        
        
        
    //     List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
    //     SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
    //     SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
    //     SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
    //     insert SubCategoryList;
        
        
    //     List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
    //     BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
    //     BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
    //     BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
    //     Insert BrandList;
        
        
        
        
    //     //Sub Brand Grade
    //     list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
    //     grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     insert grades;
        
        
    //     list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
    //     for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
    //         subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //                                                 ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
    //         subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //                                                 ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
    //                                                 ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
    //         subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //                                                 ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
    //                                                 ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
    //         subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //                                                 ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
    //                                                 ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
    //     }
        
    //     insert subBrands;
        
        
    //     List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
    //     for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
    //         SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
    //     }
        
    //     insert SubBrandAssignmentList;
        
        
    //     List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost1',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)1', ASI_MFM_A_C_Code__c='5275.040001',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost2',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)2', ASI_MFM_A_C_Code__c='5275.040002',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

    //     ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost3',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)3', ASI_MFM_A_C_Code__c='5275.040003',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
    //     insert ACCodeList;

    //     ASI_CRM_CN_FixedMappingSetting__c setting = new ASI_CRM_CN_FixedMappingSetting__c();
    //     setting.ASI_CRM_CN_Activity_CodeId__c = ACCodeList[4].Id;
    //     setting.ASI_CRM_CN_Contract_Mapping_Field__c = 'ASI_CRM_CN_Fixed_Module_Est_Amount1__c';
    //     setting.Name = ACCodeList[4].Id;
    //     insert setting;
        
        
    //     List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
    //     ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
    //                                                                      ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
    //     ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //                                                                      ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
    //     ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //                                                                      ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
    //     ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //                                                                      ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
    //     ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
    //                                                                      ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));
    //     insert ContractCostSettingList;
        
    //     ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
    //     insert oldspts;
        
    //     ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
    //     insert newspts;
        
    //     ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
    //     insert sptm;
        
        
    //     Date today = Date.newInstance(2020, 5, 25);
    //     Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
    //     Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
    //     // Date PO_Start_Date = ASI_CRM_CN_HeavyPaymentUtilitiesClass.getFiscalYearStart(System.today());//  date.newinstance(system.today().year(), system.today().month(), 1);
    //     // Date PO_End_Date = PO_Start_Date.addMonths(3)-1;
        
        
        
    //     ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
    //                                                                  ASI_CRM_CN_Status__c = 'Final',
    //                                                                  ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
    //                                                                  ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
    //                                                                  ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
    //                                                                  Name = 'Automated, Do not Change',
    //                                                                  ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
    //     insert Contract;
        
        
    //     List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
    //     MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
    //     MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M02',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
    //     MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));
        
        
    //     MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
    //     MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M04',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
    //     MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M05',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
    //     insert MethodologyList;
        
        
    //     //Methodology Assignment
    //     List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
    //     MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
    //     insert MethodologyAssignmentList ;
        
        
        
        
    //     List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));

    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[5].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[5]));

    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[6].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[6]));


    //     ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[7].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[7]));
    //     insert ModuleList;
        
        
        
    //     List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
    //     ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
    //                                                                           ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
    //                                                                           ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
    //                                                                           ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
    //                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
    //     ContractCostList.add(contractCost1);
    //     ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
    //                                                                           ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
    //                                                                           ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
    //                                                                           ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
    //                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
    //     ContractCostList.add(contractCost2);
        
    //     insert ContractCostList;
        
    //     list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
    //     list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
    //     for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //         ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //                                                                        ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
    //                                                                        ASI_CRM_CN_Contract_Monthly_Qty__c=1,
    //                                                                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
    //                                                                        ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //                                                                        recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     }
        
    //     for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //         ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //                                                                        ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
    //                                                                        ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
    //                                                                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
    //                                                                        ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //                                                                        recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     }
        
    //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
    //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
    //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
    //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Sub_Brand__c=null,
    //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
    //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
    //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
    //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Sub_Brand__c=null,
    //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
    //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
    //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Sub_Brand__c=null,
    //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //         ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //                                                                        ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
    //                                                                        ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
    //                                                                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
    //                                                                        ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //                                                                        recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     }
        
    //     for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //         ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //                                                                        ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
    //                                                                        ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
    //                                                                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
    //                                                                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
    //                                                                        ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //                                                                        recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     }

    //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Fixed',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_CN_Activity_Code__r=ACCodeList[5],ASI_CRM_CN_Activity_Code__c=ACCodeList[5].Id,
    //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[7].Id,
    //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
    //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Sub_Brand__c=null,
    //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Fixed',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_CN_Activity_Code__r=ACCodeList[6],ASI_CRM_CN_Activity_Code__c=ACCodeList[6].Id,
    //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[8].Id,
    //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
    //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Sub_Brand__c=null,
    //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Fixed',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_CN_Activity_Code__r=ACCodeList[7],ASI_CRM_CN_Activity_Code__c=ACCodeList[7].Id,
    //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[9].Id,
    //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //                                                                    ASI_CRM_CN_Sub_Brand__c=null,
    //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     insert ContractLineList;
        
        
        
        
    //     test.startTest();
        
        
    //     list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
    //     PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
    //                                                             ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
    //                                                             ASI_CRM_CN_Adjustment__c=80,
    //                                                             ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
    //                                                             ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
    //                                                             ASI_TH_CRM_Status__c='Draft',
    //                                                             ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

        
    //     PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
    //                                                             ASI_TH_CRM_Status__c='Approved',
    //                                                             ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
    //                                                             ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

    //     PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
    //                                                             ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
    //                                                             ASI_CRM_CN_Adjustment__c=80,
    //                                                             ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
    //                                                             ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
    //                                                             ASI_TH_CRM_Status__c='Paid',
    //                                                             ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
    //     insert PaymentRequestList;
        
    //     List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
    //     for(ASI_CRM_Module__c ModuleTemp:ModuleList){
    //         PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
    //                                                     ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
    //                                                     ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
    //     }
        
    //     insert PaymentModuleList;
        
    //     List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList= new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
    //     for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
    //         ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=PaymentRequestList[0].Id);
    //         if(ContractLine.ASI_CRM_Type__c=='BRSF'){
    //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[0].Id;
    //             PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
    //             PaymentLine=ASI_CRM_CN_HeavyContractTestClassHelper.PaymentLineFieldAssignment(PaymentLine);
    //         }
    //         if(ContractLine.ASI_CRM_Type__c=='PSF'){
    //             PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[1].Id;
    //                 PaymentLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
    //             }
                
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Grade'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[2].Id;
    //                 PaymentLine.ASI_CRM_Sub_Brand_Grade__c= ContractLine.ASI_CRM_Sub_Brand_Grade__c;
    //             }
                
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Category'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[3].Id;
    //                 PaymentLine.ASI_CRM_Product_Category__c= ContractLine.ASI_CRM_Product_Category__c;
    //             }
                
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Total'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[4].Id;
    //             }
    //         }
            
    //         if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
    //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
    //             PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
    //         }
    //         if (ContractLine.ASI_CRM_Type__c == 'Fixed') {
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[6].Id;
    //                 PaymentLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
    //             }
                
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Grade'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[7].Id;
    //                 PaymentLine.ASI_CRM_Sub_Brand_Grade__c= ContractLine.ASI_CRM_Sub_Brand_Grade__c;
    //             }
                
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Category'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[8].Id;
    //                 PaymentLine.ASI_CRM_Product_Category__c= ContractLine.ASI_CRM_Product_Category__c;
    //             }
                
    //             if(ContractLine.ASI_CRM_Volume_Base__c=='By Total'){
    //                 PaymentLine.ASI_CRM_Module__c=PaymentModuleList[9].Id;
    //             }
    //             PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other');
    //         }
    //         PaymentRequestLineList.add(PaymentLine);
    //     }
    //     insert PaymentRequestLineList;
    //     test.stopTest(); 
    // }

    // static testMethod void HeavyPaymentTest11() {
        
    //     //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
    //     //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();
    //     ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id,ASI_TH_CRM_Status__c,ASI_CRM_CN_Last_Payment__c FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash' AND ASI_TH_CRM_Status__c = 'Paid' AND ASI_CRM_CN_Last_Payment__c = true];
    //     // paymentrequest.ASI_TH_CRM_Status__c = 'Paid';
    //     // paymentrequest.ASI_CRM_CN_Last_Payment__c = true;
    //     // update paymentrequest;
    //     ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        
         
    //     ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(stdController2);
    //     test.startTest();
    //     con2.AutoPOModification();
        
    //     con2.ErrorHandling('测试');
    //     test.stopTest(); 
    //     // con2.Calculation();
    // }

    // static testMethod void HeavyPaymentTest5() {
        
    //     //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
    //     //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();
    //     ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id,ASI_TH_CRM_Status__c,ASI_TH_CRM_Contract__c,ASI_CRM_CN_Last_Payment__c FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash' AND ASI_TH_CRM_Status__c = 'Paid' AND ASI_CRM_CN_Last_Payment__c = true];
    //     // paymentrequest.ASI_TH_CRM_Status__c = 'Paid';
    //     // paymentrequest.ASI_CRM_CN_Last_Payment__c = true;
    //     // update paymentrequest;
        
    //     test.startTest();
    //     ASI_TH_CRM_Contract__c Contract = [select id,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c WHERE Id=: paymentrequest.ASI_TH_CRM_Contract__c];
    //     ASI_TH_CRM_Contract__c cloneContract = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(Contract);
        
    //     contract.ASI_CRM_CN_PO_Version__c = '0.1';
    //     contract.ASI_CRM_CN_V0_0_PO_version__c = cloneContract.Id;
    //     contract.ASI_CRM_Auto_PO_Modification__c = true;

    //     update contract;

    //     ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        
         
    //     ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(stdController2);
    //     // con2.AutoPOModification();
    //     con2.Calculation();
    //     test.stopTest(); 
        
    // }
    
    
    // static testMethod void HeavyPaymentTest4() {
        
    //     //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
    //     //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();
    //     ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id,ASI_TH_CRM_Status__c,ASI_CRM_CN_Last_Payment__c FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash' AND ASI_TH_CRM_Status__c = 'Paid' AND ASI_CRM_CN_Last_Payment__c = true];
    //     // paymentrequest.ASI_TH_CRM_Status__c = 'Paid';
    //     // paymentrequest.ASI_CRM_CN_Last_Payment__c = true;
    //     // update paymentrequest;
        
    //     test.startTest();
    //     List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentList = [SELECT ASI_CRM_Non_Contract_Line__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__c =: paymentrequest.Id];
    //     for (ASI_TH_CRM_PaymentRequestLineItem__c item : paymentList) {
    //         item.ASI_CRM_Non_Contract_Line__c = true;
    //     }
    //     update paymentList;
    //     ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentrequest);  
        
         
    //     ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(stdController2);
    //     con2.CalculateBCRate(20, 5);
    //     ASI_CRM_Module__c tempModule = new ASI_CRM_Module__c();
    //     ASI_CRM_CN_HeavyPaymentHeader_Controller.interimData tempData = new ASI_CRM_CN_HeavyPaymentHeader_Controller.interimData(true);
    //     ASI_CRM_CN_HeavyPaymentHeader_Controller.interimData tempData2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller.interimData(tempModule,true);
    //     test.stopTest(); 
    // }
    
    
    // static testMethod void HeavyPaymentTest22() {
        
    //     //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
    //     //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();
        
    //     // ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
    //     // insert region;
        
    //     // ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
    //     // insert division;
        
    //     // ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
    //     // insert area;
        
    //     // ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
    //     // insert city;
        
    //     // ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
    //     // insert channel;
        
        
    //     // ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
    //     // INSERT SegmentationCriteria;
        
        
    //     // Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
    //     // list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        
    //     // Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
    //     // insert Customers;
        
    //     // //Covered_Outlet
    //     // list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
    //     // ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
    //     // insert ChildCustomers;
        
    //     // User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
    //     // currentUser.LanguageLocaleKey='zh_CN';
    //     // update currentUser;
        
    //     // list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
    //     // rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
    //     //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // else{
    //     //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // }
    //     // insert rns;
        
        
        
        
        
    //     // List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
    //     // ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
    //     // ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
    //     // ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
    //     // insert ProductCategoryList;
        
        
        
        
    //     // List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
    //     // SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
    //     // SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
    //     // SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
    //     // insert SubCategoryList;
        
        
    //     // List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
    //     // BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
    //     // BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
    //     // BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
    //     // Insert BrandList;
        
        
        
        
    //     // //Sub Brand Grade
    //     // list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
    //     // grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     // grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     // grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     // insert grades;
        
        
    //     // list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
    //     // for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
    //     // }
        
    //     // insert subBrands;
        
        
    //     // List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
    //     // for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
    //     //     SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
    //     // }
        
    //     // insert SubBrandAssignmentList;
        
        
    //     // List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
    //     // insert ACCodeList;
        
        
    //     // List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
    //     // insert ContractCostSettingList;
        
    //     // ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
    //     // ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
    //     // insert new List<ASI_CRM_SpecialPromotionTypeSetting__c>{oldspts,newspts};
        
    //     // ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
    //     // insert sptm;
        
        
        
    //     // Date PO_Start_Date = ASI_CRM_CN_HeavyPaymentUtilitiesClass.getFiscalYearStart(System.today());//  date.newinstance(system.today().year(), system.today().month(), 1);
    //     // Date PO_End_Date = PO_Start_Date.addMonths(3)-1;
        
        
        
    //     // ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
    //     //                                                              ASI_CRM_CN_Status__c = 'Final',
    //     //                                                              ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
    //     //                                                              ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
    //     //                                                              ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
    //     //                                                              Name = 'Automated, Do not Change',
    //     //                                                              ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
    //     // insert Contract;
        
        
    //     // List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M02',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));
        
        
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M04',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M05',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
    //     // insert MethodologyList;
        
        
    //     // //Methodology Assignment
    //     // List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
    //     // insert MethodologyAssignmentList ;
        
        
        
        
    //     // List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
    //     // insert ModuleList;
        
        
        
    //     // List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
    //     // ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
    //     //                                                                       ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
    //     //                                                                       ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
    //     //                                                                       ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
    //     //                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
    //     // ContractCostList.add(contractCost1);
    //     // ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
    //     //                                                                       ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
    //     //                                                                       ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
    //     //                                                                       ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
    //     //                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
    //     // ContractCostList.add(contractCost2);
        
    //     // insert ContractCostList;
        
    //     // list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
    //     // list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
    //     // for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //     //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //     //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
    //     //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
    //     //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
    //     //                                                                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //     //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     // }
        
    //     // for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //     //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //     //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
    //     //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
    //     //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
    //     //                                                                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //     //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     // }
        
    //     // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
    //     //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
    //     //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
    //     //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Sub_Brand__c=null,
    //     //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
    //     //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
    //     //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
    //     //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Sub_Brand__c=null,
    //     //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
    //     //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
    //     //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Sub_Brand__c=null,
    //     //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     // for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //     //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //     //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
    //     //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
    //     //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
    //     //                                                                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //     //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     // }
        
    //     // insert ContractLineList;

    //     // list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
    //     // PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
    //     //                                                         ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
    //     //                                                         ASI_CRM_CN_Adjustment__c=80,
    //     //                                                         ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
    //     //                                                         ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
    //     //                                                         ASI_TH_CRM_Status__c='Draft',
    //     //                                                         ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
    //     // insert PaymentRequestList;

    //     // List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
    //     // for(ASI_CRM_Module__c ModuleTemp:ModuleList){
    //     //     PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
    //     //                                                 ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
    //     //                                                 ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
    //     // }
        
    //     // insert PaymentModuleList;
    //     // test.startTest();

    //     // List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList= new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
    //     // for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
    //     //     ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=PaymentRequestList[0].Id);
    //     //     if(ContractLine.ASI_CRM_Type__c=='BRSF'){
    //     //         PaymentLine.ASI_CRM_Module__c=PaymentModuleList[0].Id;
    //     //         PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
    //     //         PaymentLine=ASI_CRM_CN_HeavyContractTestClassHelper.PaymentLineFieldAssignment(PaymentLine);
    //     //     }
    //     //     if(ContractLine.ASI_CRM_Type__c=='PSF'){
    //     //         PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[1].Id;
    //     //             PaymentLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
    //     //         }
                
    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Grade'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[2].Id;
    //     //             PaymentLine.ASI_CRM_Sub_Brand_Grade__c= ContractLine.ASI_CRM_Sub_Brand_Grade__c;
    //     //         }
                
    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Category'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[3].Id;
    //     //             PaymentLine.ASI_CRM_Product_Category__c= ContractLine.ASI_CRM_Product_Category__c;
    //     //         }
                
    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Total'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[4].Id;
    //     //         }
    //     //     }
            
    //     //     if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
    //     //         PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
    //     //         PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
    //     //     }
    //     //     PaymentRequestLineList.add(PaymentLine);
    //     // }
    //     // insert PaymentRequestLineList;
    //     TEST.startTest();
    //     ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash' AND ASI_TH_CRM_Status__c = 'Draft'];
    //     ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(new ApexPages.StandardController(paymentrequest));
        
        
         
        
    //     System.debug(Limits.getDMLRows());

    //     con2.Calculation();
    //     con2.GoEditPayee();
    //     con2.GoEditHeader();
        
        
        
    //     test.stopTest();
    // }
    // static testMethod void HeavyPaymentTest33() {
        
    //  //Test ASI_CRM_CN_HeavyPaymentHeader_Controller
    //     //list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = ASI_CRM_CN_HeavyContractTestClassHelper.GeneratePaymentList();

    //     // ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
    //     // insert region;

    //     // ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
    //     // insert division;

    //     // ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
    //     // insert area;

    //     // ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
    //     // insert city;

    //     // ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
    //     // insert channel;


    //     // ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
    //     // INSERT SegmentationCriteria;


    //     // Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

    //     // list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();

    //     // Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
    //     // insert Customers;

    //     // //Covered_Outlet
    //     // list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
    //     // ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
    //     // insert ChildCustomers;

    //     // User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
    //     // currentUser.LanguageLocaleKey='zh_CN';
    //     // update currentUser;

    //     // list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
    //     // rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
    //     //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // else{
    //     //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     //     rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
    //     // }
    //     // insert rns;





    //     // List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
    //     // ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
    //     // ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
    //     // ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));

    //     // insert ProductCategoryList;




    //     // List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
    //     // SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
    //     // SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
    //     // SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));

    //     // insert SubCategoryList;


    //     // List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
    //     // BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
    //     // BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
    //     // BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));

    //     // Insert BrandList;




    //     // //Sub Brand Grade
    //     // list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
    //     // grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     // grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     // grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
    //     // insert grades;


    //     // list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
    //     // for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
    //     //     subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
    //     //                                             ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
    //     //                                             ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
    //     // }

    //     // insert subBrands;


    //     // List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
    //     // for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
    //     //     SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
    //     // }

    //     // insert SubBrandAssignmentList;


    //     // List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
    //     // ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

    //     // insert ACCodeList;


    //     // List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));

    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));

    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));

    //     // ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
    //     //                                                                  ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

    //     // insert ContractCostSettingList;

    //     // ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
    //     // ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
    //     // insert new List<ASI_CRM_SpecialPromotionTypeSetting__c>{oldspts,newspts};

    //     // ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
    //     // insert sptm;



    //     // Date PO_Start_Date = ASI_CRM_CN_HeavyPaymentUtilitiesClass.getFiscalYearStart(System.today());//  date.newinstance(system.today().year(), system.today().month(), 1);
    //     // Date PO_End_Date = PO_Start_Date.addMonths(3)-1;



    //     // ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
    //     //                                                              ASI_CRM_CN_Status__c = 'Final',
    //     //                                                              ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
    //     //                                                              ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
    //     //                                                              ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
    //     //                                                              Name = 'Automated, Do not Change',
    //     //                                                              ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
    //     // insert Contract;


    //     // List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M02',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));


    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='M03',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='M04',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
    //     // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='M05',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
    //     // insert MethodologyList;


    //     // //Methodology Assignment
    //     // List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
    //     // MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));

    //     // insert MethodologyAssignmentList ;




    //     // List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
    //     // ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));

    //     // insert ModuleList;



    //     // List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
    //     // ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
    //     //                                                                       ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
    //     //                                                                       ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
    //     //                                                                       ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
    //     //                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
    //     // ContractCostList.add(contractCost1);
    //     // ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
    //     //                                                                       ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
    //     //                                                                       ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
    //     //                                                                       ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
    //     //                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
    //     // ContractCostList.add(contractCost2);

    //     // insert ContractCostList;

    //     // list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
    //     // list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
    //     // for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //     //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //     //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
    //     //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
    //     //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
    //     //                                                                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //     //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     // }

    //     // for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //     //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //     //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
    //     //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
    //     //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
    //     //                                                                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //     //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     // }

    //     // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
    //     //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
    //     //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
    //     //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Sub_Brand__c=null,
    //     //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
    //     //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
    //     //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
    //     //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Sub_Brand__c=null,
    //     //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
    //     //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
    //     //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
    //     //                                                                ASI_CRM_CN_Sub_Brand__c=null,
    //     //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
    //     // for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
    //     //     ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
    //     //                                                                    ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
    //     //                                                                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
    //     //                                                                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
    //     //                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
    //     //                                                                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
    //     //                                                                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
    //     // }

    //     // insert ContractLineList;

    //     // list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
    //     // PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
    //     //                                                         ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
    //     //                                                         ASI_CRM_CN_Adjustment__c=80,
    //     //                                                         ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
    //     //                                                         ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
    //     //                                                         ASI_TH_CRM_Status__c='Draft',
    //     //                                                         ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

    //     // insert PaymentRequestList;

    //     // List<ASI_CRM_Module__c> PaymentModuleList = new List<ASI_CRM_Module__c>();
    //     // for(ASI_CRM_Module__c ModuleTemp:ModuleList){
    //     //     PaymentModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Parent_Module__c=ModuleTemp.Id,ASI_CRM_Volume_Base__c=ModuleTemp.ASI_CRM_Volume_Base__c,
    //     //                                                 ASI_CRM_Line_Type__c=ModuleTemp.ASI_CRM_Line_Type__c,
    //     //                                                 ASI_CRM_Payment_Request__c=PaymentRequestList[0].Id,ASI_CRM_Contract__c=ModuleTemp.ASI_CRM_Contract__c,ASI_CRM_End_Date__c=PO_End_Date));
    //     // }

    //     // insert PaymentModuleList;
    //     // test.startTest();

    //     // List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList= new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

    //     // for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
    //     //     ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c=PaymentRequestList[0].Id);
    //     //     if(ContractLine.ASI_CRM_Type__c=='BRSF'){
    //     //         PaymentLine.ASI_CRM_Module__c=PaymentModuleList[0].Id;
    //     //         PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
    //     //         PaymentLine=ASI_CRM_CN_HeavyContractTestClassHelper.PaymentLineFieldAssignment(PaymentLine);
    //     //     }
    //     //     if(ContractLine.ASI_CRM_Type__c=='PSF'){
    //     //         PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[1].Id;
    //     //             PaymentLine.ASI_CRM_CN_Sub_Brand__c = ContractLine.ASI_CRM_CN_Sub_Brand__c;
    //     //         }

    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Grade'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[2].Id;
    //     //             PaymentLine.ASI_CRM_Sub_Brand_Grade__c= ContractLine.ASI_CRM_Sub_Brand_Grade__c;
    //     //         }

    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Category'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[3].Id;
    //     //             PaymentLine.ASI_CRM_Product_Category__c= ContractLine.ASI_CRM_Product_Category__c;
    //     //         }

    //     //         if(ContractLine.ASI_CRM_Volume_Base__c=='By Total'){
    //     //             PaymentLine.ASI_CRM_Module__c=PaymentModuleList[4].Id;
    //     //         }
    //     //     }

    //     //     if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
    //     //         PaymentLine.ASI_CRM_Module__c=PaymentModuleList[5].Id;
    //     //         PaymentLine.recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC');
    //     //     }
    //     //     PaymentRequestLineList.add(PaymentLine);
    //     // }
    //     // insert PaymentRequestLineList;
    //     test.startTest();
    //     ASI_TH_CRM_PaymentRequest__c paymentrequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Payment_Type__c = 'Cash' AND ASI_TH_CRM_Status__c = 'Draft'];
    //     ASI_CRM_CN_HeavyPaymentHeader_Controller con2 = new ASI_CRM_CN_HeavyPaymentHeader_Controller(new ApexPages.StandardController(paymentrequest));


    //     // comment 20180209
    //     con2.GoToCheckPoint();

    //     con2.GoReturn();
    //     con2.GoEditDetailPage();
    //     con2.GoSubmitApproval();

    //     //test case
    //     con2.NameSortingASC(99);
    //     con2.NameSortingASC(999);
    //     con2.NameSortingASC(9999);

    //     con2.MethodologyRoute('M01',1,2,3);
    //     con2.MethodologyRoute('M01',3,2,3);
    //     con2.MethodologyRoute('M01',null,null,3);
    //     con2.MethodologyRoute('M02',1,null,3);
    //     con2.MethodologyRoute('M02',1,0.0002,3);
    //     con2.MethodologyRoute('M02',1,2,3);

    //     con2.MethodologyRoute('M03',999,2,3);
    //     con2.MethodologyRoute('M03',1,2,3);
    //     con2.MethodologyRoute('M04',1,2,3);
    //     con2.MethodologyRoute('M05',1,2,3);
    //     con2.GeneratingIncentive('Premium','BRSFIncentive');
    //     con2.GeneratingIncentive('Premium','PSFMax');


    //     paymentrequest.ASI_TH_CRM_Status__c = 'Submitted';
    //     update paymentrequest;
    //     con2.GoReturn();


    //     test.stopTest();
    // }

}