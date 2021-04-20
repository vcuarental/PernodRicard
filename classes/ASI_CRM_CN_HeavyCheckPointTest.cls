@isTest


public class ASI_CRM_CN_HeavyCheckPointTest {
    
     
  
    
    static testMethod void HeavyPaymentCheckCtrlTest1() {
        //Test ASI_CRM_CN_HeavyPaymentCheckCtrl
        
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
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
        
        
        
        //Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        //Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        Date TodayDateBefore3= system.today().addMonths(-5);
        
         
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
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
        
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=false,
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
        
        //insert PaymentModuleList;
        
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
        //insert PaymentRequestLineList;
        
        
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1);
        insert CustomSetting ;
        
        List<ASI_CRM_Subbrand_Volume__c> SubbrandVolumeList= new List<ASI_CRM_Subbrand_Volume__c> ();
        
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[1].Id,ASI_CRM_Subbrand__c=subBrand.Id,
                                                                                   ASI_CRM_End_Date__c=PO_Start_Date, 
                                                                                   ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE);
            
            SubbrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
            
        }
        date tempdate = PO_Start_Date.addMonths(1)-1;
        //insert SubbrandVolumeList;
        
        
        
        List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
          
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense (Excl. Fixed Cost)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='Payment Speed%',ASI_CRM_2nd_Dimension__c='Volume Speed%',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Payment_Checkpoint_Criteria')) );
       
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Investment per CR12 eq btl',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
      //  insert SegmentationCriteriaList;
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Payment Data',ASI_CRM_For_Contract_Use__c=true);   
        Attachment4.ASI_CRM_Historical_Financial_Data__c='{"VolumeSpeed":820.33738184039579798364085980597300,"PaymentSpeed":0.35540423498491771943971567661201200,"VariableCostTotal":119.00,"FixedCostTotal":0.00,"PSFBySubBrandAchievementRate":161.924686192468619246861924686192,"MKSSBAR":9999999}';
        AttachmentList.add(Attachment4);
        insert AttachmentList;
        
        test.startTest();
       
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con2 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController2);
        con2.proceed();
        con2.CancelProcess();
        
        test.stopTest(); 
    }
    
    static testMethod void HeavyPaymentCheckCtrlTest2(){
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
        
         List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
          
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,AS_CRM_Predefined_Theoretical_Value__c = 'PRC Guidance',ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense (Excl. Fixed Cost)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='Payment Speed%',ASI_CRM_2nd_Dimension__c='Volume Speed%',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Alignment_Percentage__c = 2,ASI_CRM_Alignment_Value__c=2,ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Investment per CR12 eq btl',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        insert SegmentationCriteriaList;
        
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
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"TotalMBCRate":97.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00, "TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
		insert Attachment1;		
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=false,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert PaymentRequestList;
    	ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData1 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData();
        ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData2 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaList[0]); 
        ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData3 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaList[2]); 
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con2 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController2);
        con2.DataOperationChecking(interimData2);
        con2.ByVolumeFinancialIndicator(SegmentationCriteriaList[1], '2');
        con2.FirstDimensionAssignment(interimData2);
        con2.SecondDimensionAssignment(interimData2);
        con2.SecondDimensionAssignment(interimData3);
        con2.ErrorHandling('ErrorMsg');
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[1]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con1 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController1);
        
    }
    
    static testMethod void HeavyPaymentCheckCtrlTest3(){
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
        
         List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
          
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,AS_CRM_Predefined_Theoretical_Value__c = 'PRC Guidance',ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense (Excl. Fixed Cost)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='Payment Speed%',ASI_CRM_2nd_Dimension__c='Volume Speed%',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Alignment_Percentage__c = 2,ASI_CRM_Alignment_Value__c=2,ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Investment per CR12 eq btl',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        insert SegmentationCriteriaList;
        
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
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Last Payment Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"TotalMBCRate":97.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00, "TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
		insert Attachment1;		
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=false,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert PaymentRequestList;
    	ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData1 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData();
        ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData2 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaList[0]); 
        ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData3 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaList[2]); 
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con2 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController2);
        con2.DataOperationChecking(interimData2);
        con2.ByVolumeFinancialIndicator(SegmentationCriteriaList[1], '2');
        con2.FirstDimensionAssignment(interimData2);
        con2.SecondDimensionAssignment(interimData2);
        con2.SecondDimensionAssignment(interimData3);
        con2.ErrorHandling('ErrorMsg');
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[1]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con1 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController1);
        
    }
    
        static testMethod void HeavyPaymentCheckCtrlTest4(){
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
        
         List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
          
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,AS_CRM_Predefined_Theoretical_Value__c = 'PRC Guidance',ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense (Excl. Fixed Cost)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='Payment Speed%',ASI_CRM_2nd_Dimension__c='Volume Speed%',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Floating_Interval_Up__c=1,ASI_CRM_Floating_Interval_Down__c=1,ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Within',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Alignment_Percentage__c = 2,ASI_CRM_Alignment_Value__c=2,ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Investment per CR12 eq btl',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        insert SegmentationCriteriaList;
        
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
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=false,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            insert PaymentRequestList;
            ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Payment_Request__c=PaymentRequestList[1].Id,ASI_CRM_Type__c='CheckPoint-Success',ASI_CRM_For_Contract_Use__c=true);
            Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"TotalMBCRate":97.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00, "TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
            insert Attachment1;		
            
            ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData1 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData();
            ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData2 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaList[0]); 
            ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData3 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaList[2]); 
            ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData interimData4 = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaList[1]); 

            ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con2 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController2);
        con2.DataOperationChecking(interimData2);
        con2.ByVolumeFinancialIndicator(SegmentationCriteriaList[1], '2');
        con2.FirstDimensionAssignment(interimData2);
        con2.SecondDimensionAssignment(interimData2);
        con2.SecondDimensionAssignment(interimData3);
        con2.DataOperationChecking(interimData4);
        con2.ErrorHandling('ErrorMsg');
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(PaymentRequestList[1]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con1 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController1);
        
    }
  
   
    /*
    static testMethod void HeavyPaymentCheckCtrlTest2() {
        //Test ASI_CRM_CN_HeavyPaymentCheckCtrl
        
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
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
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Martell_BC_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
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
        
        list<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList = new list<ASI_TH_CRM_PaymentRequest__c>();
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,
                                                                ASI_CRM_CN_Payment_Type__c = 'Cash',ASI_CRM_CN_Last_Payment__c=true,
                                                                ASI_CRM_CN_Adjustment__c=80,
                                                                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
                                                                ASI_TH_CRM_Status__c='Draft',
                                                                ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        PaymentRequestList.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Return_Comments__c='Test1',
                                                                ASI_TH_CRM_Status__c='Approved',ASI_CRM_CN_Last_Payment__c=true,
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
        
        
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1);
        //insert CustomSetting ;
        
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"TotalMBCRate":97.00,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalMBCRate":97.00, "TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":693.666684,"VariableExpensesMap":{},"VariableExpense":1018000.00,"TradeExpenses":1887000.00,'+
            '"TotalBCRate":95.00,"TotalMBCRate":97.00,"SubBrandGradeMap":{"3. Ultra Premium 特级高档":506.666676,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":187.000008},'+
            '"SubBrandGradeGrouping":{"Ultra Premium":506.666676,"Prestige":182.000004,"Ultra Prestige":5.000004},"ROIProForma":1.72276737916712241653418124006359,"ROIIntake":1.72,'+
            '"ROIActual":1.72,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":1363862.044488360000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":3250862.044488360000,"InvestmentCR12":87.60,"IntakeSTD":8700,"IntakeCR12":21540.00,"GSId":" ",'+
            '"GrossSalesTotal":4437343.493984880000,"GrossSalesRate":42.53,"FixedExpensesMap":{},"FixedExpenseRate":46.05,"FixedExpense":869000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004YapIAE","CMTotal":3250862.044488360000,"CMId":" ","CategoryMap":{"Whisky":247.333332,"Wine":186.666672,"Champagne":125.000004,"Brandy":130.000008,"Others":4.666668},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":1387.333332,"VariableExpensesMap":{},"VariableExpense":2036000.00,"TradeExpenses":3774000.00,"TotalMBCRate":97.00, "TotalBCRate":95.00,"SubBrandGradeMap":'+
            '{"3. Ultra Premium 特级高档":1013.333328,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":374.000004},"SubBrandGradeGrouping":{"Ultra Premium":1013.333328,"Prestige":364.000008,"Ultra Prestige":9.999996},"ROIProForma":1.72276733288937996820349761526232,"ROIIntake":1.72276733288937996820349761526232,"ROIActual":1.72276733288937996820349761526232,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":2727723.914324520000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":6501723.914324520000,"InvestmentCR12":87.60,"IntakeSTD":17400,"IntakeCR12":43080.00,"GSId":" aA2M0000000BG8cKAG;aA2M0000000BG6iKAG;aA2M0000000BG39KAG;aA2M0000000BG2iKAG;aA2M0000000BG2cKAG;aA2M0000000BG2CKAW;aA2M0000000BG12KAG;aA2M0000000BG4pKAG;","GrossSalesTotal":8874686.744130720000,"GrossSalesRate":42.53,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":869000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":1738000.00,"ContractBottles":0.0}},"FixedExpenseRate":46.05,"FixedExpense":1738000.00,"DebugMap":{},"ContractLineMap":{"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":900,"EstimateTotalFees":27000.00,"EstimateFees":30.00,"EstimateBottles":75,"ContractVolume":1800,"ContractTotalFees":54000.00,"ContractFees":30.00,"ContractBottles":150},"00003百龄坛15年 Ballantines 15YO-B15":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"百龄坛15年 Ballantines 15YO-B15","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":2400,"EstimateTotalFees":72000.00,"EstimateFees":30.00,"EstimateBottles":200,"ContractVolume":4800,"ContractTotalFees":144000.00,"ContractFees":30.00,"ContractBottles":400},"00003玛姆红带特级干型 Mumm Cordon Rouge-MUR":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"玛姆红带特级干型 Mumm Cordon Rouge-MUR","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500'+
            ',"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00003巴黎之花干型 Perrier Jouet Others-PJO":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花干型 Perrier Jouet Others-PJO","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500,"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"'+
            'EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002马爹利XO Martell XO-ML6":{"VFi'+
            'nalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利XO Martell XO-ML6","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10},"00001巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10}},"ContractId":"","CMTotal":6501723.914324520000,"CMId":" aA2M0000000BFrCKAW;aA2M0000000BFkmKAG;aA2M0000000BFjcKAG;aA2M0000000BFnPKAW;aA2M0000000BFljKAG;aA2M0000000BFlIKAW;aA2M0000000BFlCKAW;aA2M0000000BFpIKAW;","CategoryMap":{"Whisky":494.666676,"Wine":373.333332,"Champagne":249.999996,"Brandy":259.999992,"Others":9.333336},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 
        
        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Last Payment Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.00,"TotalMBCRate":97.00,"TotalBCRate":0.0,"SubBrandGradeMap":{"5. Not Specified / 未指定":0.0,"4. Prestige + Ultra Prestige / 奢华档 + 特级奢华档":0.0,"3. Ultra Premium / 特级高档":0.0,"2. Super Premium / 超高档":0.0,"1. Standard + Premium / 标准档 + 高档":0.0},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-26","POEndDate":"2017-11-26","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""}]';
        AttachmentList.add(Attachment3);
        
        
        ASI_Attachment__c Attachment4=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Payment Data',ASI_CRM_For_Contract_Use__c=true);   
        Attachment4.ASI_CRM_Historical_Financial_Data__c='{"VolumeSpeed":820.33738184039579798364085980597300,"PaymentSpeed":0.35540423498491771943971567661201200,"VariableCostTotal":119.00,"FixedCostTotal":0.00,"PSFBySubBrandAchievementRate":161.924686192468619246861924686192,"MKSSBAR":9999999}';
        AttachmentList.add(Attachment4);
        
        insert AttachmentList;
        
        
            
        
        
        List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
          
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Payment Speed: Trade Expense (Excl. Fixed Cost)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='Payment Speed%',ASI_CRM_2nd_Dimension__c='Volume Speed%',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Payment_Checkpoint_Criteria')) );
       
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Investment per CR12 eq btl',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='BC: BC%',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
           
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Fixed Expense %',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Volume: By Grade - Super Premium',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        
         SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Fixed Expense %',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_Alignment_Value__c=99,
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
         SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='BC: BC%',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_Alignment_Percentage__c=0.97,
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Martell BC Rate',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_Alignment_Percentage__c=0.97,
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        
         
         // SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
           //                                                              ASI_CRM_Financial_Indicator__c='Trade Expenses: Fixed Expense %',ASI_CRM_Operation__c='Greater than or Equal to',
             //                                                            ASI_CRM_1st_Dimension__c='Historical Vfinal',ASI_CRM_2nd_Dimension__c='New Contract V Final',
               //                                                          Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
//         SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
  //                                                                       ASI_CRM_Financial_Indicator__c='Trade Expenses: Fixed Expense %',ASI_CRM_Operation__c='Greater than or Equal to',
    //                                                                     ASI_CRM_1st_Dimension__c='Historical Vfinal',ASI_CRM_2nd_Dimension__c='New Contract V Final',
      //                                                                   Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        //
         SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: Fixed Expense %',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='New Contract V Final',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Last_Payment_Checkpoint_Criteria')) );
        
        
        
      //  insert SegmentationCriteriaList;
        
        
        test.startTest();
        
        
        ApexPages.Standardcontroller stdController3 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con3 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController3);
        con3.proceed();
        con3.FixedCostTotal=100;
        con3.proceed();
        con3.CancelProcess();
        
        
        
        CustomSetting.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=999999;
        CustomSetting.ASI_CRM_Total_Amount_Checking__c=999999;
        update CustomSetting;
        con3.ValidationChecking();
        
        PaymentRequestList[0].ASI_CRM_CN_Last_Payment__c = false;
        update PaymentRequestList[0];
        
        
        ApexPages.Standardcontroller stdController4 = new ApexPages.Standardcontroller(PaymentRequestList[0]);  
        ASI_CRM_CN_HeavyPaymentCheckCtrl con4 = new ASI_CRM_CN_HeavyPaymentCheckCtrl(stdController4);
        con4.init();
        
        
        test.stopTest(); 
    }
    */
    /*
    static testMethod void HeavyPaymentCheckCompTest1() {
        //Test ASI_CRM_CN_HeavyPaymentCheckCompCtrl
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
        con2.init();
        
   
        
        
        
        test.stopTest(); 
    }
    
    static testMethod void HeavyContractHeaderPDFTest() {
        //Test ASI_CRM_CN_HeavyContractHeaderPDFCtrl
        ASI_TH_CRM_Contract__c ContractInserted=  ASI_CRM_CN_HeavyContractTestClassHelper.CreateSimpleContract();
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', ContractInserted.id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);  
        ASI_CRM_CN_HeavyContractHeaderPDFCtrl con = new ASI_CRM_CN_HeavyContractHeaderPDFCtrl(stdController);
        
        con.init();
        con.dummyVar=true;
        test.stopTest(); 
    }
    
    static testMethod void CheckPointResultTest1() {
        //Test ASI_CRM_CN_HeavyCheckPointResultCtrl
        ASI_TH_CRM_Contract__c ContractInserted=  ASI_CRM_CN_HeavyContractTestClassHelper.CreateSimpleContract();
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":693.666684,"VariableExpensesMap":{},"VariableExpense":1018000.00,"TradeExpenses":1887000.00,'+
            '"TotalBCRate":95.00,"SubBrandGradeMap":{"3. Ultra Premium 特级高档":506.666676,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":187.000008},'+
            '"SubBrandGradeGrouping":{"Ultra Premium":506.666676,"Prestige":182.000004,"Ultra Prestige":5.000004},"ROIProForma":1.72276737916712241653418124006359,"ROIIntake":1.72,'+
            '"ROIActual":1.72,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":1363862.044488360000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":3250862.044488360000,"InvestmentCR12":87.60,"IntakeSTD":8700,"IntakeCR12":21540.00,"GSId":" ",'+
            '"GrossSalesTotal":4437343.493984880000,"GrossSalesRate":42.53,"FixedExpensesMap":{},"FixedExpenseRate":46.05,"FixedExpense":869000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004YapIAE","CMTotal":3250862.044488360000,"CMId":" ","CategoryMap":{"Whisky":247.333332,"Wine":186.666672,"Champagne":125.000004,"Brandy":130.000008,"Others":4.666668},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":1387.333332,"VariableExpensesMap":{},"VariableExpense":2036000.00,"TradeExpenses":3774000.00,"TotalBCRate":95.00,"SubBrandGradeMap":'+
            '{"3. Ultra Premium 特级高档":1013.333328,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":374.000004},"SubBrandGradeGrouping":{"Ultra Premium":1013.333328,"Prestige":364.000008,"Ultra Prestige":9.999996},"ROIProForma":1.72276733288937996820349761526232,"ROIIntake":1.72276733288937996820349761526232,"ROIActual":1.72276733288937996820349761526232,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":2727723.914324520000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":6501723.914324520000,"InvestmentCR12":87.60,"IntakeSTD":17400,"IntakeCR12":43080.00,"GSId":" aA2M0000000BG8cKAG;aA2M0000000BG6iKAG;aA2M0000000BG39KAG;aA2M0000000BG2iKAG;aA2M0000000BG2cKAG;aA2M0000000BG2CKAW;aA2M0000000BG12KAG;aA2M0000000BG4pKAG;","GrossSalesTotal":8874686.744130720000,"GrossSalesRate":42.53,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":869000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":1738000.00,"ContractBottles":0.0}},"FixedExpenseRate":46.05,"FixedExpense":1738000.00,"DebugMap":{},"ContractLineMap":{"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":900,"EstimateTotalFees":27000.00,"EstimateFees":30.00,"EstimateBottles":75,"ContractVolume":1800,"ContractTotalFees":54000.00,"ContractFees":30.00,"ContractBottles":150},"00003百龄坛15年 Ballantines 15YO-B15":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"百龄坛15年 Ballantines 15YO-B15","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":2400,"EstimateTotalFees":72000.00,"EstimateFees":30.00,"EstimateBottles":200,"ContractVolume":4800,"ContractTotalFees":144000.00,"ContractFees":30.00,"ContractBottles":400},"00003玛姆红带特级干型 Mumm Cordon Rouge-MUR":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"玛姆红带特级干型 Mumm Cordon Rouge-MUR","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500'+
            ',"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00003巴黎之花干型 Perrier Jouet Others-PJO":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花干型 Perrier Jouet Others-PJO","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500,"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"'+
            'EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002马爹利XO Martell XO-ML6":{"VFi'+
            'nalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利XO Martell XO-ML6","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10},"00001巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10}},"ContractId":"","CMTotal":6501723.914324520000,"CMId":" aA2M0000000BFrCKAW;aA2M0000000BFkmKAG;aA2M0000000BFjcKAG;aA2M0000000BFnPKAW;aA2M0000000BFljKAG;aA2M0000000BFlIKAW;aA2M0000000BFlCKAW;aA2M0000000BFpIKAW;","CategoryMap":{"Whisky":494.666676,"Wine":373.333332,"Champagne":249.999996,"Brandy":259.999992,"Others":9.333336},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 
        
       
        // ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='PO Modification Data',ASI_CRM_For_Contract_Use__c=true);    
        //Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":1765.8450,"VariableExpensesMap":{},"VariableExpense":1374870.00,"TradeExpenses":1374870.00,"TotalBCRate":100.01704607395221152988513721098500,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":11.0845356670489392380521777013197,"ROIIntake":11.2660370687821416388553540809792,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-07-01","POEndDate":"2018-12-31","OutletSet":["a8bM00000009DPVIA2"],"NoOfMonths":18,"NetBCRate":100.01704607395221152988513721098500,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":6859586.1973500000,"InvestmentCR12":14.1262983400695674246584973564105,"IntakeSTD":22703.1750,"IntakeCR12":43807.86,"GSId":" ","GrossSalesTotal":10228323.3952500000,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{"00004芝华士·新境12年 CR Extra 12 YO-CHD":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":1.125,"SubBrandName":"芝华士·新境12年 CR Extra 12 YO-CHD","SubBrandGrade":"Super Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00006999":{"VFinalVolume":0,"VFinalTotalFees":0.0,"VFinalFees":0.00,"VFinalBottles":0.0,"SubBrandName":"999","SubBrandGrade":"Standard","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":1800,"VFinalTotalFees":43357.5000,"VFinalFees":50.00,"VFinalBottles":975.54375,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":21600,"VFinalTotalFees":83540.0000,"VFinalFees":20.00,"VFinalBottles":4699.1250,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0}},"ContractId":"a8cM00000004Y7OIAU","CMTotal":6971907.0511526400,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":97.00,"AddOnString":"{\"ActVSEst_Vol\":2648384.2636363636363636363636363694400000,\"v0_actualvol_pom\":9735.08,\"LatestBudgetCMTotal\":6859586.1973500000,\"CMTotal\":6971907.0511526400,\"TotalBC_prorate\":27753.0550,\"Total_IntakeBtl_prorate\":27748.3250,\"TotalBlackCap_prorate\":0,\"Total_IntakeBtl\":5045.15,\"TotalBC\":5046.01,\"TotalBackCap\":0,\"VECEstTotal\":0,\"PSFEstTotal\":1248000.00}"}]';
        //AttachmentList.add(Attachment3);     
        insert AttachmentList;
        
        test.startTest();
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);  
        ASI_CRM_CN_HeavyCheckPointResultCtrl con = new ASI_CRM_CN_HeavyCheckPointResultCtrl(stdController);
        con.init();
         con.CancelProcess();
        con.POModiValidationChecking();
        con.PreSaveRecord();
        con.proceed();
        
        
        test.stopTest(); 
    }
    
    
    static testMethod void CheckPointResultTest2() {
        //Test ASI_CRM_CN_HeavyCheckPointResultCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        
        
        List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,
                                                                         ASI_CRM_Financial_Indicator__c='Volume: Total',ASI_CRM_Operation__c='Greater than',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='Historical V0.0',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria')) );
        
        
        insert SegmentationCriteriaList;
        
        
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        
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
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
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
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c ContractInserted = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                             ASI_CRM_CN_Status__c = 'Final',
                                                                             ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                             ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                             ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                             Name = 'Contract1',
                                                                             ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert ContractInserted;
        
        
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":693.666684,"VariableExpensesMap":{},"VariableExpense":1018000.00,"TradeExpenses":1887000.00,'+
            '"TotalBCRate":95.00,"SubBrandGradeMap":{"3. Ultra Premium 特级高档":506.666676,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":187.000008},'+
            '"SubBrandGradeGrouping":{"Ultra Premium":506.666676,"Prestige":182.000004,"Ultra Prestige":5.000004},"ROIProForma":1.72276737916712241653418124006359,"ROIIntake":1.72,'+
            '"ROIActual":1.72,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":1363862.044488360000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":3250862.044488360000,"InvestmentCR12":87.60,"IntakeSTD":8700,"IntakeCR12":21540.00,"GSId":" ",'+
            '"GrossSalesTotal":4437343.493984880000,"GrossSalesRate":42.53,"FixedExpensesMap":{},"FixedExpenseRate":46.05,"FixedExpense":869000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004YapIAE","CMTotal":3250862.044488360000,"CMId":" ","CategoryMap":{"Whisky":247.333332,"Wine":186.666672,"Champagne":125.000004,"Brandy":130.000008,"Others":4.666668},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":1387.333332,"VariableExpensesMap":{},"VariableExpense":2036000.00,"TradeExpenses":3774000.00,"TotalBCRate":95.00,"SubBrandGradeMap":'+
            '{"3. Ultra Premium 特级高档":1013.333328,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":374.000004},"SubBrandGradeGrouping":{"Ultra Premium":1013.333328,"Prestige":364.000008,"Ultra Prestige":9.999996},"ROIProForma":1.72276733288937996820349761526232,"ROIIntake":1.72276733288937996820349761526232,"ROIActual":1.72276733288937996820349761526232,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":2727723.914324520000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":6501723.914324520000,"InvestmentCR12":87.60,"IntakeSTD":17400,"IntakeCR12":43080.00,"GSId":" aA2M0000000BG8cKAG;aA2M0000000BG6iKAG;aA2M0000000BG39KAG;aA2M0000000BG2iKAG;aA2M0000000BG2cKAG;aA2M0000000BG2CKAW;aA2M0000000BG12KAG;aA2M0000000BG4pKAG;","GrossSalesTotal":8874686.744130720000,"GrossSalesRate":42.53,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":869000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":1738000.00,"ContractBottles":0.0}},"FixedExpenseRate":46.05,"FixedExpense":1738000.00,"DebugMap":{},"ContractLineMap":{"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":900,"EstimateTotalFees":27000.00,"EstimateFees":30.00,"EstimateBottles":75,"ContractVolume":1800,"ContractTotalFees":54000.00,"ContractFees":30.00,"ContractBottles":150},"00003百龄坛15年 Ballantines 15YO-B15":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"百龄坛15年 Ballantines 15YO-B15","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":2400,"EstimateTotalFees":72000.00,"EstimateFees":30.00,"EstimateBottles":200,"ContractVolume":4800,"ContractTotalFees":144000.00,"ContractFees":30.00,"ContractBottles":400},"00003玛姆红带特级干型 Mumm Cordon Rouge-MUR":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"玛姆红带特级干型 Mumm Cordon Rouge-MUR","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500'+
            ',"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00003巴黎之花干型 Perrier Jouet Others-PJO":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花干型 Perrier Jouet Others-PJO","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500,"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"'+
            'EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002马爹利XO Martell XO-ML6":{"VFi'+
            'nalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利XO Martell XO-ML6","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10},"00001巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10}},"ContractId":"","CMTotal":6501723.914324520000,"CMId":" aA2M0000000BFrCKAW;aA2M0000000BFkmKAG;aA2M0000000BFjcKAG;aA2M0000000BFnPKAW;aA2M0000000BFljKAG;aA2M0000000BFlIKAW;aA2M0000000BFlCKAW;aA2M0000000BFpIKAW;","CategoryMap":{"Whisky":494.666676,"Wine":373.333332,"Champagne":249.999996,"Brandy":259.999992,"Others":9.333336},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 
        
        //ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='PO Modification Data',ASI_CRM_For_Contract_Use__c=true);    
        //Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":1765.8450,"VariableExpensesMap":{},"VariableExpense":1374870.00,"TradeExpenses":1374870.00,"TotalBCRate":100.01704607395221152988513721098500,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":11.0845356670489392380521777013197,"ROIIntake":11.2660370687821416388553540809792,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-07-01","POEndDate":"2018-12-31","OutletSet":["a8bM00000009DPVIA2"],"NoOfMonths":18,"NetBCRate":100.01704607395221152988513721098500,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":6859586.1973500000,"InvestmentCR12":14.1262983400695674246584973564105,"IntakeSTD":22703.1750,"IntakeCR12":43807.86,"GSId":" ","GrossSalesTotal":10228323.3952500000,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{"00004芝华士·新境12年 CR Extra 12 YO-CHD":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":1.125,"SubBrandName":"芝华士·新境12年 CR Extra 12 YO-CHD","SubBrandGrade":"Super Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00006999":{"VFinalVolume":0,"VFinalTotalFees":0.0,"VFinalFees":0.00,"VFinalBottles":0.0,"SubBrandName":"999","SubBrandGrade":"Standard","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":1800,"VFinalTotalFees":43357.5000,"VFinalFees":50.00,"VFinalBottles":975.54375,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":21600,"VFinalTotalFees":83540.0000,"VFinalFees":20.00,"VFinalBottles":4699.1250,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0}},"ContractId":"a8cM00000004Y7OIAU","CMTotal":6971907.0511526400,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":97.00,"AddOnString":"{\"ActVSEst_Vol\":2648384.2636363636363636363636363694400000,\"v0_actualvol_pom\":9735.08,\"LatestBudgetCMTotal\":6859586.1973500000,\"CMTotal\":6971907.0511526400,\"TotalBC_prorate\":27753.0550,\"Total_IntakeBtl_prorate\":27748.3250,\"TotalBlackCap_prorate\":0,\"Total_IntakeBtl\":5045.15,\"TotalBC\":5046.01,\"TotalBackCap\":0,\"VECEstTotal\":0,\"PSFEstTotal\":1248000.00}"}]';
        //AttachmentList.add(Attachment3);      
        
        insert AttachmentList;
        
        test.startTest();
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);  
        ASI_CRM_CN_HeavyCheckPointResultCtrl con = new ASI_CRM_CN_HeavyCheckPointResultCtrl(stdController);
        con.init();
       
        
        test.stopTest(); 
    }
     
    
    static testMethod void CheckPointResultTest3() {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        
        
        List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Volume: Total',ASI_CRM_Operation__c='Greater than',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='Historical V0.0',
                                                                         Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Methodology: BRSF Methodology',ASI_CRM_Operation__c='Equal to',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Methodology',
                                                                         Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Methodology: PSF Methodology',ASI_CRM_Operation__c='Equal to',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Methodology',
                                                                         Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Period: PO Start Date',ASI_CRM_Operation__c='Less than',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Methodology',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',ASI_CRM_Alignment_Value__c=-50,
                                                                         Name='Test4',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_Alignment_Percentage__c=0.95,
                                                                         Name='Test5',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='BC: BC%',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_Alignment_Percentage__c=0.95,
                                                                         Name='Test6',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Volume: By Grade - Premium',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='Historical Vfinal',ASI_CRM_2nd_Dimension__c='Historical V0.0',
                                                                         Name='Test7',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Methodology: PSF Volume Base',ASI_CRM_Operation__c='Equal to',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Volume Base',
                                                                         Name='Test8',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contact V0.0 Contract',
                                                                         Name='Test9',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria')) );
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test10',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contract V Final',
                                                                         Name='Test11',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Volume: By Category - Whisky',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='Historical Vfinal',
                                                                         Name='Test11',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
                                                                         ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
                                                                         Name='Test10',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
                                                                         ASI_CRM_Financial_Indicator__c='Period: PO Start Date',ASI_CRM_Operation__c='Less than',AS_CRM_Predefined_Theoretical_Value__c='PO Submit Date',
                                                                         ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',ASI_CRM_Alignment_Value__c=-50,
                                                                         Name='Test11',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        
        insert SegmentationCriteriaList;
        
        
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST1', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        
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
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
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
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c ContractInserted = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                             ASI_CRM_CN_Status__c = 'Final',
                                                                             ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                             ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                             ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                             Name = 'Contract1',
                                                                             ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert ContractInserted;
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1);
        
        
        insert CustomSetting ;
        
        
        ASI_CRM_Contract_Printout_Setting__c PrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c(ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Header_Section_Name__c='Test',ASI_CRM_Content_Section_Name__c='Test1');
        insert PrintoutSetting;
            
         List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
  //      ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
    //    Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":2502.266664,"VariableExpensesMap":{},"VariableExpense":2408940.00,"TradeExpenses":2668940.00,"TotalBCRate":0.0,"SubBrandGradeMap":{"3. Ultra Premium 特级高档":980.933340,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":27.999996,"2. Super Premium 超高档":1493.333328},"SubBrandGradeGrouping":{"Ultra Premium":980.933340,"Prestige":27.999996,"Super Premium":1493.333328},"ROIProForma":1.94,"ROIIntake":2.15,"ROIActual":2.15,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2016-07-01","POEndDate":"2017-06-30","OutletSet":[],"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":95.49,"MarginAfterAnP":3072154.488094360000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":5168682.258424440000,"InvestmentCR12":67.36,"IntakeSTD":32172,"IntakeCR12":39624.00,"GSId":" aA2M0000000BHtUKAW;aA2M0000000BI1sKAG;aA2M0000000BHxmKAG;aA2M0000000BHlIKAW;aA2M0000000BHpaKAG;","GrossSalesTotal":8096665.890713280000,"GrossSalesRate":32.96,"FixedExpensesMap":{},"FixedExpenseRate":9.7416952048378757109564096607642000,"FixedExpense":260000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004XuVIAU","CMTotal":5741094.488094360000,"CMId":" aA2M0000000BHpVKAW;aA2M0000000BHtnKAG;aA2M0000000BI1nKAG;aA2M0000000BHxhKAG;aA2M0000000BHlbKAG;","CategoryMap":{"Whisky":2502.266664},"BRSFMethodologyName":"","BCRate":97.00,"AddOnString":""},{"Volumes":1564.8600000000000000000000000000010020,"VariableExpensesMap":{},"VariableExpense":1375148.08,"TradeExpenses":1545148.08,"TotalBCRate":90.979923903112177788736189170460400,"SubBrandGradeMap":{"1. Standard + Premium 标准档 + 高档":3.8200000000000000000000000000000044,"2. Super Premium 超高档":934.4700000000000000000000000000005208,"3. Ultra Premium 特级高档":608.3800000000000000000000000000004808,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":18.189999999999999999999999999999996},"SubBrandGradeGrouping":{"Premium":3.8200000000000000000000000000000044,"Super Premium":934.4700000000000000000000000000005208,"Ultra Premium":608.3800000000000000000000000000004808,"Standard":0.00,"Prestige":18.189999999999999999999999999999996},"ROIProForma":2.09187280619731928864707905536148,"ROIIntake":2.32402456562785231561754262413477,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2016-07-01","POEndDate":"2017-06-30","OutletSet":["a8bM00000009DPbIAM"],"NoOfMonths":12,"NetBCRate":86.505975703478643856821727083194600,"MarginPerBottle":101.698510346885585237163994062574,"MarginAfterAnP":2045814.0154527100000000000000000000000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":3232253.2501000000000000000000000000000,"InvestmentCR12":62.3424674115305969294133026479091,"IntakeSTD":20116.460000000000000000000000000002404,"IntakeCR12":24784.83999999999999999999999999996,"GSId":" ","GrossSalesTotal":5064642.759275000000000000000000000000,"GrossSalesRate":30.508530481648163591146341504959600,"FixedExpensesMap":{"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":170000.00,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0}},"FixedExpenseRate":11.002181745583892515984616827145800,"FixedExpense":170000.00,"DebugMap":{"HistoricalVFTillEnd":"2017-06-30"},"ContractLineMap":{"00005杰卡斯经典系列 Jacobs Creek Classic-JCW":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"杰卡斯经典系列 Jacobs Creek Classic-JCW","SubBrandGrade":"Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.00,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00004杰卡斯珍藏系列 Jacobs Creek Reserve-JCR":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"杰卡斯珍藏系列 Jacobs Creek Reserve-JCR","SubBrandGrade":"Super Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.00,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003杰卡斯传承系列 Jacobs Creek Heritage-JCH":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"杰卡斯传承系列 Jacobs Creek Heritage-JCH","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.00,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00006维波罗瓦 Wyborowa-WYV":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"维波罗瓦 Wyborowa-WYV","SubBrandGrade":"Standard","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.00,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003巴黎之花干型 Perrier Jouet Others-PJO":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花干型 Perrier Jouet Others-PJO","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.000,"HistoricalFees":0.0,"HistoricalBottles":0.75,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003玛姆红带特级干型 Mumm Cordon Rouge-MUR":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"玛姆红带特级干型 Mumm Cordon Rouge-MUR","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.000,"HistoricalFees":0.0,"HistoricalBottles":0.50,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00005杰卡斯莫斯卡托系列 Jacobs Creek Moscato-JCO":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"杰卡斯莫斯卡托系列 Jacobs Creek Moscato-JCO","SubBrandGrade":"Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.000,"HistoricalFees":0.0,"HistoricalBottles":2.416666666666666666666666666666667,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003芝华士J&J创始纪念版 Chivas J&J-CHU":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士J&J创始纪念版 Chivas J&J-CHU","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.000,"HistoricalFees":0.0,"HistoricalBottles":0.00,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00004百龄坛12年 Ballantines 12YO-B12":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"百龄坛12年 Ballantines 12YO-B12","SubBrandGrade":"Super Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.000,"HistoricalFees":0.0,"HistoricalBottles":1.00,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00005绝对伏特加(原味) Absolut Blue-AB1":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"绝对伏特加(原味) Absolut Blue-AB1","SubBrandGrade":"Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.000,"HistoricalFees":0.0,"HistoricalBottles":1.50,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00006999":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"999","SubBrandGrade":"Standard","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":-5947.91,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":240.0000,"HistoricalFees":40.00,"HistoricalBottles":0.50,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":9720.0000,"HistoricalFees":60.00,"HistoricalBottles":13.5000,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00002马爹利XO Martell XO-ML6":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利XO Martell XO-ML6","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":4320.0000,"HistoricalFees":60.00,"HistoricalBottles":6.00,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":311994.8000,"HistoricalFees":40.00,"HistoricalBottles":649.9891666666666666666666666666666,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0},"00004芝华士12年 Chivas 12YO-CH3":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士12年 Chivas 12YO-CH3","SubBrandGrade":"Super Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":360077.7000,"HistoricalFees":30.00,"HistoricalBottles":1000.2158333333333333333333333333336,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.0,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.0,"ContractBottles":0.0}},"ContractId":"a8cM00000004XmcIAE","CMTotal":3590962.0954527100000000000000000000000,"CMId":" ","CategoryMap":{"Others":2.420000000000000000000000000000004,"Champagne":0.5000000000000000000000000000000004,"Whisky":1558.8500000000000000000000000000009964,"Brandy":0.7500000000000000000000000000000000,"Wine":0.9400000000000000000000000000000008,"Vodka":1.4000000000000000000000000000000004},"BRSFMethodologyName":"","BCRate":97.00,"AddOnString":"{\"TotalHC_IntakeBtl\":20116.46,\"TotalBackCap\":900.00,\"TotalHC_BC\":18301.94,\"TotalBC_prorate\":18301.9400000000000000000000000000052180,\"Total_IntakeBtl_prorate\":20116.460000000000000000000000000002404,\"TotalBlackCap_prorate\":900.00,\"VECEstTotal\":0,\"PSFEstTotal\":752443.00}"}]';
      //  AttachmentList.add(Attachment1);
        
        //ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        //Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":1699.600008,"VariableExpensesMap":{},"VariableExpense":1688160.00,"TradeExpenses":1868160.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":1008.000000,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":19.600008,"3. Ultra Premium 特级高档":672.000000},"SubBrandGradeGrouping":{"Super Premium":1008.000000,"Prestige":19.600008,"Ultra Premium":672.000000},"ROIProForma":1.99990056213906731757451181911614,"ROIIntake":2.00,"ROIActual":2.00,"PSFVolumeBase":"By Sub-Brand(按品牌);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":85.48,"MarginAfterAnP":1867974.234165720000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":3736134.234165720000,"InvestmentCR12":69.19,"IntakeSTD":21852,"IntakeCR12":27000.00,"GSId":" ","GrossSalesTotal":5469704.345265240000,"GrossSalesRate":34.15,"FixedExpensesMap":{},"FixedExpenseRate":9.64,"FixedExpense":180000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004Y9oIAE","CMTotal":3736134.234165720000,"CMId":" ","CategoryMap":{"Whisky":1699.600008},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":1699.600008,"VariableExpensesMap":{},"VariableExpense":1688160.00,"TradeExpenses":1868160.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":1008.000000,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":19.600008,"3. Ultra Premium 特级高档":672.000000},"SubBrandGradeGrouping":{"Super Premium":1008.000000,"Prestige":19.600008,"Ultra Premium":672.000000},"ROIProForma":1.99990056213906731757451181911614,"ROIIntake":1.99990056213906731757451181911614,"ROIActual":1.99990056213906731757451181911614,"PSFVolumeBase":"By Sub-Brand(按品牌);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":85.48,"MarginAfterAnP":1867974.234165720000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":3736134.234165720000,"InvestmentCR12":69.19,"IntakeSTD":21852,"IntakeCR12":27000.00,"GSId":" aA2M0000000BGCQKA4;aA2M0000000BG9cKAG;aA2M0000000BG7kKAG;aA2M0000000BG5SKAW;aA2M0000000BG3hKAG;","GrossSalesTotal":5469704.345265240000,"GrossSalesRate":34.15,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":180000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":180000.00,"ContractBottles":0.0}},"FixedExpenseRate":9.64,"FixedExpense":180000.00,"DebugMap":{},"ContractLineMap":{"00004芝华士·新境12年 CR Extra 12 YO-CHD":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士·新境12年 CR Extra 12 YO-CHD","SubBrandGrade":"Super Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":7200,"EstimateTotalFees":216000.00,"EstimateFees":30.00,"EstimateBottles":600,"ContractVolume":7200,"ContractTotalFees":216000.00,"ContractFees":30.00,"ContractBottles":600},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":180,"EstimateTotalFees":10800.00,"EstimateFees":60.00,"EstimateBottles":15,"ContractVolume":180,"ContractTotalFees":10800.00,"ContractFees":60.00,"ContractBottles":15},"00002马爹利XO Martell XO-ML6":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利XO Martell XO-ML6","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":72,"EstimateTotalFees":4320.00,"EstimateFees":60.00,"EstimateBottles":6,"ContractVolume":72,"ContractTotalFees":4320.00,"ContractFees":60.00,"ContractBottles":6},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":8640,"EstimateTotalFees":345600.00,"EstimateFees":40.00,"EstimateBottles":720,"ContractVolume":8640,"ContractTotalFees":345600.00,"ContractFees":40.00,"ContractBottles":720},"00004芝华士12年 Chivas 12YO-CH3":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士12年 Chivas 12YO-CH3","SubBrandGrade":"Super Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":5760,"EstimateTotalFees":172800.00,"EstimateFees":30.00,"EstimateBottles":480,"ContractVolume":5760,"ContractTotalFees":172800.00,"ContractFees":30.00,"ContractBottles":480}},"ContractId":"","CMTotal":3736134.234165720000,"CMId":" aA2M0000000BFqKKAW;aA2M0000000BFv0KAG;aA2M0000000BFsCKAW;aA2M0000000BFmHKAW;aA2M0000000BFo2KAG;","CategoryMap":{"Whisky":1699.600008},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';
        //AttachmentList.add(Attachment2); 
        
        
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Success');
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RcKOAU"},"Id":"aATM00000006RcKOAU","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":-2,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: ROI(Actual)","ASI_CRM_Chinese_Interpretation__c":"投资回报率：新合同V0.0预估版不得比旧合同最终版少2%","ASI_CRM_English_Interpretation__c":"ROI: New Contract est. >= Historical V Final *98%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":false,"Display2ndResult":"旧合同最终版 = 1.74","Display1stResult":"新合同V0.0预估= 1.72","Dimension2ndResult":1.73760088211606633611224276870796,"Dimension1stResult":1.72},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXLOA2"},"Id":"aATM00000006RXLOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版多15%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. <= Historical V Final*115%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694},{"Type2ndName":"aGmM0000000002BKAQ","Type1stName":"aGmM0000000002BKAQ","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXEOA2"},"Id":"aATM00000006RXEOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: BRSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收费(BRSF)计算方式：进货量与空瓶取小支付","ASI_CRM_English_Interpretation__c":"BRSF Default Methodology: Min (BC, Intake)","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=Min (BC, Intake)(进货量与空瓶取小支付)","Display1stResult":"新合同V0.0预估=Min (BC, Intake)(进货量与空瓶取小支付)","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"aGmM0000000002fKAA","Type1stName":"aGmM0000000002fKAA;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXFOA2"},"Id":"aATM00000006RXFOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)计算方式：若实际空瓶回收率>= V0.0空瓶回收率，进货量支付，反之，空瓶回收数支付","ASI_CRM_English_Interpretation__c":"PSF Default Methodology: BC%>=V0.0 BC%, Intake, otherwise BC","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数)","Display1stResult":"新合同V0.0预估=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数);","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXHOA2"},"Id":"aATM00000006RXHOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":95,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"BC: BC%","ASI_CRM_Chinese_Interpretation__c":"空瓶回收率: 新合同需>=95%","ASI_CRM_English_Interpretation__c":"BC%: New Contract >=95%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 95","Display1stResult":"新合同V0.0预估= 95","Dimension2ndResult":95,"Dimension1stResult":95}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Failed');
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"By Sub Brand and By Grade.","Type1stName":"By Sub-Brand;By Grade;By Category;By Total;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXGOA2"},"Id":"aATM00000006RXGOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Volume Base","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Volume Base","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)销量计算基础：按品牌或按品牌档次","ASI_CRM_English_Interpretation__c":"PSF Default Volume Base: By Sub-brand or By Grade","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算基础=By Sub-Brand (按品牌) or By Grade(按品牌档次).","Display1stResult":"新合同V0.0预估=By Sub-Brand;By Grade;By Category;By Total;","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXIOA2"},"Id":"aATM00000006RXIOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: Fixed Expense %","ASI_CRM_Chinese_Interpretation__c":"固定费用比例：新合同V0.0预估版需 <=15%","ASI_CRM_English_Interpretation__c":"Fixed Expense%: New Contract V0.0 Est. <=15%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 15","Display1stResult":"新合同V0.0预估= 46","Dimension2ndResult":15,"Dimension1stResult":46},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXJOA2"},"Id":"aATM00000006RXJOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Alignment_Value__c":-60.00,"ASI_CRM_Operation__c":"Less than","AS_CRM_Predefined_Theoretical_Value__c":"PO Submit Date","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Predefined Theoretical Value","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Period: PO Start Date","ASI_CRM_Chinese_Interpretation__c":"合同提交日期： 需在合同开始日期60天内提交","ASI_CRM_English_Interpretation__c":"PO Submit Date: compared with PO Start Date, should submit within 60 days","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-07-01","DisplayToUser":true,"Display2ndResult":"PO提交日期=Today (今天)-60 day(s).","Display1stResult":"新合同V0.0预估 = 7/1/2017","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXKOA2"},"Id":"aATM00000006RXKOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than","ASI_CRM_Alignment_Percentage__c":-30,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版少30%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. > Historical V Final*70%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694}]';
        AttachmentList.add(Attachment2);
        
        
        insert AttachmentList;
        
        
        test.startTest();
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);  
        ASI_CRM_CN_HeavyCheckPointResultCtrl con = new ASI_CRM_CN_HeavyCheckPointResultCtrl(stdController);
        con.init();
        con.CancelProcess();
        con.POModiValidationChecking();
        con.PreSaveRecord();
        con.proceed();
        
        
        
        Customers[1].ASI_CRM_CN_BusinessLicenseUploading__c=true;
        Customers[1].ASI_CRM_CN_Busi_License_ExpireDate_Perm__c =TRUE;
        Customers[1].ASI_CRM_CN_Business_License_Start_Date__c=PO_Start_Date;
        update Customers;
        
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(ContractInserted);  
        ASI_CRM_CN_HeavyCheckPointResultCtrl con2 = new ASI_CRM_CN_HeavyCheckPointResultCtrl(stdController2);
        con.init();
        con.proceed();
        
        
        test.stopTest(); 
        
        
        
    }
    
    static testMethod void HeavyCheckPointResultCtrlTest4() {
        //Test ASI_CRM_CN_HeavyCheckPointResultCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c',ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST1', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        
        //ASI_CRM_CN_Parent_Outlet__c
        
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
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
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
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Archived',
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Variable Event Cost'));
        
        insert ModuleList;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        
        
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        insert ContractLineList;
        
        
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=-1,ASI_CRM_Total_Amount_Checking__c=-1);
        insert CustomSetting ;
        
        
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":""},{"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProForma":0.0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2017-11-24","POEndDate":"2017-11-24","OutletSet":[],"NoOfMonths":1,"NetBCRate":0.0,"MarginPerBottle":0.0,"MarginAfterAnP":0.0,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotal":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"AddOnString":"{}"}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Volumes":693.666684,"VariableExpensesMap":{},"VariableExpense":1018000.00,"TradeExpenses":1887000.00,'+
            '"TotalBCRate":95.00,"SubBrandGradeMap":{"3. Ultra Premium 特级高档":506.666676,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":187.000008},'+
            '"SubBrandGradeGrouping":{"Ultra Premium":506.666676,"Prestige":182.000004,"Ultra Prestige":5.000004},"ROIProForma":1.72276737916712241653418124006359,"ROIIntake":1.72,'+
            '"ROIActual":1.72,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":1363862.044488360000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":3250862.044488360000,"InvestmentCR12":87.60,"IntakeSTD":8700,"IntakeCR12":21540.00,"GSId":" ",'+
            '"GrossSalesTotal":4437343.493984880000,"GrossSalesRate":42.53,"FixedExpensesMap":{},"FixedExpenseRate":46.05,"FixedExpense":869000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004YapIAE","CMTotal":3250862.044488360000,"CMId":" ","CategoryMap":{"Whisky":247.333332,"Wine":186.666672,"Champagne":125.000004,"Brandy":130.000008,"Others":4.666668},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":1387.333332,"VariableExpensesMap":{},"VariableExpense":2036000.00,"TradeExpenses":3774000.00,"TotalBCRate":95.00,"SubBrandGradeMap":'+
            '{"3. Ultra Premium 特级高档":1013.333328,"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":374.000004},"SubBrandGradeGrouping":{"Ultra Premium":1013.333328,"Prestige":364.000008,"Ultra Prestige":9.999996},"ROIProForma":1.72276733288937996820349761526232,"ROIIntake":1.72276733288937996820349761526232,"ROIActual":1.72276733288937996820349761526232,"PSFVolumeBase":"By Sub-Brand(按品牌);By Grade(按品牌档次);By Category(按产品类别);By Total(按总销量);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2017-07-01","POEndDate":"2018-06-30","OutletSet":[],'+
            '"NoOfMonths":12,"NetBCRate":0.0,"MarginPerBottle":156.77,"MarginAfterAnP":2727723.914324520000,"LBGSId":" ","LBCMId":" ","LatestBudgetCMTotal":6501723.914324520000,"InvestmentCR12":87.60,"IntakeSTD":17400,"IntakeCR12":43080.00,"GSId":" aA2M0000000BG8cKAG;aA2M0000000BG6iKAG;aA2M0000000BG39KAG;aA2M0000000BG2iKAG;aA2M0000000BG2cKAG;aA2M0000000BG2CKAW;aA2M0000000BG12KAG;aA2M0000000BG4pKAG;","GrossSalesTotal":8874686.744130720000,"GrossSalesRate":42.53,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":0.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":0.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":869000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":1738000.00,"ContractBottles":0.0}},"FixedExpenseRate":46.05,"FixedExpense":1738000.00,"DebugMap":{},"ContractLineMap":{"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":900,"EstimateTotalFees":27000.00,"EstimateFees":30.00,"EstimateBottles":75,"ContractVolume":1800,"ContractTotalFees":54000.00,"ContractFees":30.00,"ContractBottles":150},"00003百龄坛15年 Ballantines 15YO-B15":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"百龄坛15年 Ballantines 15YO-B15","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"'+
            'HistoricalBottles":0.0,"EstimateVolume":2400,"EstimateTotalFees":72000.00,"EstimateFees":30.00,"EstimateBottles":200,"ContractVolume":4800,"ContractTotalFees":144000.00,"ContractFees":30.00,"ContractBottles":400},"00003玛姆红带特级干型 Mumm Cordon Rouge-MUR":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"玛姆红带特级干型 Mumm Cordon Rouge-MUR","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500'+
            ',"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00003巴黎之花干型 Perrier Jouet Others-PJO":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花干型 Perrier Jouet Others-PJO","SubBrandGrade":"Ultra Premium","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1500,"EstimateTotalFees":45000.00,"EstimateFees":30.00,"EstimateBottles":125,"ContractVolume":3000,"ContractTotalFees":90000.00,"ContractFees":30.00,"ContractBottles":250},"00002马爹利蓝带 Martell Cordon Bleu-ML2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利蓝带 Martell Cordon Bleu-ML2","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"'+
            'EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002马爹利XO Martell XO-ML6":{"VFi'+
            'nalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"马爹利XO Martell XO-ML6","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":1140,"EstimateTotalFees":57000.00,"EstimateFees":50.00,"EstimateBottles":95,"ContractVolume":2280,"ContractTotalFees":114000.00,"ContractFees":50.00,"ContractBottles":190},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10},"00001巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"SubBrandName":"巴黎之花美丽时光 Perrier Jouet Belle Epoque-PJB","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"","strSubBrand":"","'+
            'HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"EstimateVolume":60,"EstimateTotalFees":3000.00,"EstimateFees":50.00,"EstimateBottles":5,"ContractVolume":120,"ContractTotalFees":6000.00,"ContractFees":50.00,"ContractBottles":10}},"ContractId":"","CMTotal":6501723.914324520000,"CMId":" aA2M0000000BFrCKAW;aA2M0000000BFkmKAG;aA2M0000000BFjcKAG;aA2M0000000BFnPKAW;aA2M0000000BFljKAG;aA2M0000000BFlIKAW;aA2M0000000BFlCKAW;aA2M0000000BFpIKAW;","CategoryMap":{"Whisky":494.666676,"Wine":373.333332,"Champagne":249.999996,"Brandy":259.999992,"Others":9.333336},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 
        
        insert AttachmentList;
        
        
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('TypeName','SubmitApproval');
        
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_HeavyCheckPointResultCtrl con = new ASI_CRM_CN_HeavyCheckPointResultCtrl(stdController2);
        con.init();
        con.proceed();
        
        
        
        test.stopTest(); 
        
    }

    static testMethod void CheckPointPDFTest() {
        //Test ASI_CRM_CN_HeavyCheckPointPDFController 
        ASI_TH_CRM_Contract__c ContractInserted=  ASI_CRM_CN_HeavyContractTestClassHelper.CreateSimpleContract();
        
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Success');
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RcKOAU"},"Id":"aATM00000006RcKOAU","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":-2,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: ROI(Actual)","ASI_CRM_Chinese_Interpretation__c":"投资回报率：新合同V0.0预估版不得比旧合同最终版少2%","ASI_CRM_English_Interpretation__c":"ROI: New Contract est. >= Historical V Final *98%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":false,"Display2ndResult":"旧合同最终版 = 1.74","Display1stResult":"新合同V0.0预估= 1.72","Dimension2ndResult":1.73760088211606633611224276870796,"Dimension1stResult":1.72},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXLOA2"},"Id":"aATM00000006RXLOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版多15%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. <= Historical V Final*115%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694},{"Type2ndName":"aGmM0000000002BKAQ","Type1stName":"aGmM0000000002BKAQ","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXEOA2"},"Id":"aATM00000006RXEOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: BRSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收费(BRSF)计算方式：进货量与空瓶取小支付","ASI_CRM_English_Interpretation__c":"BRSF Default Methodology: Min (BC, Intake)","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=Min (BC, Intake)(进货量与空瓶取小支付)","Display1stResult":"新合同V0.0预估=Min (BC, Intake)(进货量与空瓶取小支付)","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"aGmM0000000002fKAA","Type1stName":"aGmM0000000002fKAA;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXFOA2"},"Id":"aATM00000006RXFOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)计算方式：若实际空瓶回收率>= V0.0空瓶回收率，进货量支付，反之，空瓶回收数支付","ASI_CRM_English_Interpretation__c":"PSF Default Methodology: BC%>=V0.0 BC%, Intake, otherwise BC","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数)","Display1stResult":"新合同V0.0预估=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数);","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXHOA2"},"Id":"aATM00000006RXHOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":95,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"BC: BC%","ASI_CRM_Chinese_Interpretation__c":"空瓶回收率: 新合同需>=95%","ASI_CRM_English_Interpretation__c":"BC%: New Contract >=95%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 95","Display1stResult":"新合同V0.0预估= 95","Dimension2ndResult":95,"Dimension1stResult":95}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Failed');
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"By Sub Brand and By Grade.","Type1stName":"By Sub-Brand;By Grade;By Category;By Total;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXGOA2"},"Id":"aATM00000006RXGOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Volume Base","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Volume Base","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)销量计算基础：按品牌或按品牌档次","ASI_CRM_English_Interpretation__c":"PSF Default Volume Base: By Sub-brand or By Grade","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算基础=By Sub-Brand (按品牌) or By Grade(按品牌档次).","Display1stResult":"新合同V0.0预估=By Sub-Brand;By Grade;By Category;By Total;","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXIOA2"},"Id":"aATM00000006RXIOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: Fixed Expense %","ASI_CRM_Chinese_Interpretation__c":"固定费用比例：新合同V0.0预估版需 <=15%","ASI_CRM_English_Interpretation__c":"Fixed Expense%: New Contract V0.0 Est. <=15%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 15","Display1stResult":"新合同V0.0预估= 46","Dimension2ndResult":15,"Dimension1stResult":46},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXJOA2"},"Id":"aATM00000006RXJOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Alignment_Value__c":-60.00,"ASI_CRM_Operation__c":"Less than","AS_CRM_Predefined_Theoretical_Value__c":"PO Submit Date","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Predefined Theoretical Value","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Period: PO Start Date","ASI_CRM_Chinese_Interpretation__c":"合同提交日期： 需在合同开始日期60天内提交","ASI_CRM_English_Interpretation__c":"PO Submit Date: compared with PO Start Date, should submit within 60 days","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-07-01","DisplayToUser":true,"Display2ndResult":"PO提交日期=Today (今天)-60 day(s).","Display1stResult":"新合同V0.0预估 = 7/1/2017","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXKOA2"},"Id":"aATM00000006RXKOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than","ASI_CRM_Alignment_Percentage__c":-30,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版少30%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. > Historical V Final*70%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694}]';
        AttachmentList.add(Attachment2);
        
        
        insert AttachmentList;
        
        test.startTest();
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);  
        ASI_CRM_CN_HeavyCheckPointPDFController con = new ASI_CRM_CN_HeavyCheckPointPDFController(stdController);
        
        con.currentHeaderId= ContractInserted.id;  
        boolean testBoolean =con.init();
        
        
        test.stopTest(); 
    }
    */
}