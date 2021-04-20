@isTest
private class ASI_CRM_CN_HeavyProfitShuttleCtrl2ndTst {
    static testMethod void HeavyProfitShuttleCtrlTest1() {//Test ASI_CRM_CN_HeavyProfitShuttleCtrl2nd
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
  
  
        /*list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
              ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
              insert ChildCustomers;
              */
        
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium ??? + ??',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        insert sptm;*/
        
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_Martell_BC_Rate__c=0.95,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_Martell_BC_Rate__c=0.95,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
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
        
        /*
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='????',
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
        */
        
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
        
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        string str = '[{"Volumes":398.666664,"VariableExpensesMap":{},"VariableExpense":43700.00,"TradeExpenses":53700.00,"TradeExpenseBySubBrand":[{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.1322,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":90.9000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":90.9000,"actualPayment":0.00}],"totalTradeExpense":12606.9000,"subBrandName":"百龄坛特醇","subBrandId":"a7FM00000008eKoMAI","subBrandCode":"BAF","ROI":0.0000,"PSFTradeExpense":340.9000,"PSFGap":0,"PSFAmount":340.9000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.1818,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.2979,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":12766.0000,"subBrandName":"绝对伏特加(原味)","subBrandId":"a7FM00000008eKDMAY","subBrandCode":"AB1","ROI":0.0000,"PSFTradeExpense":500.0000,"PSFGap":0,"PSFAmount":500.0000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.5000,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":3.5583,"tradeExpenseByPSFModule":[{"tradeExpense":500.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":500.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":3416.0000,"subBrandName":"维波罗瓦","subBrandId":"a7FM00000008eJZMAY","subBrandCode":"WYV","ROI":0.0000,"PSFTradeExpense":750.0000,"PSFGap":0,"PSFAmount":750.0000,"propByTotal":0.1333,"propByGrade":1.0000,"propByCategory":0.5000,"propByBRSFAmt":0.000000,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Standard","gradeId":"a9tM00000008ONBIA2","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":0.0000,"BRSFIncentive":0.00,"BRSFGap":0,"BRSFAmount":0.0000},{"volumeSTD":960,"volumeCR12":960.0000,"volume9L":74.6667,"VECTradeExpense":2667.0000,"VECGap":0,"VECAmount":2667.0000,"tradeExpensePerBottle":25.9771,"tradeExpenseByPSFModule":[{"tradeExpense":222.2000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":222.2000,"actualPayment":0.00},{"tradeExpense":181.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":181.8000,"actualPayment":0.00}],"totalTradeExpense":24938.0000,"subBrandName":"格兰威特单一麦芽创始人甄选","subBrandId":"a7FM00000000B8ZMAU","subBrandCode":"TGN","ROI":0.0000,"PSFTradeExpense":404.0000,"PSFGap":0,"PSFAmount":404.0000,"propByTotal":0.2667,"propByGrade":0.4444,"propByCategory":0.3636,"propByBRSFAmt":0.307692,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":2667.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":19200.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":19200.0000},{"volumeSTD":1200,"volumeCR12":1200.0000,"volume9L":93.3333,"VECTradeExpense":3333.0000,"VECGap":0,"VECAmount":3333.0000,"tradeExpensePerBottle":25.9759,"tradeExpenseByPSFModule":[{"tradeExpense":277.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":277.8000,"actualPayment":0.00},{"tradeExpense":227.2500,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":227.2500,"actualPayment":0.00}],"totalTradeExpense":31171.0500,"subBrandName":"格兰威特12年","subBrandId":"a7FM00000008eKhMAI","subBrandCode":"GL5","ROI":0.0000,"PSFTradeExpense":505.0500,"PSFGap":0,"PSFAmount":505.0500,"propByTotal":0.3333,"propByGrade":0.5556,"propByCategory":0.4545,"propByBRSFAmt":0.384615,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":3333.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":24000.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":24000.0000}],"TotalMBCRate":97.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":174.666672,"1. Standard + Premium 标准档 + 高档":223.999992},"SubBrandGradeGrouping":{"Super Premium":174.666672,"Standard":74.666664,"Premium":149.333328},"ROIProFormaExcl":0,"ROIProForma":0.0,"ROIIntakeExcl":0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"By Grade(按品牌档次);By Category(按产品类别);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2018-07-01","POEndDate":"2020-06-30","OutletSet":[],"NoOfMonths":24,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottle":-10.65,"MarginAfterAnP":-53700.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":14.92,"IntakeSTD":5040,"IntakeCR12":3600.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRateExcl":0,"GrossSalesRate":0.0,"CMNSRateProForma":0.0, "DomesticContractIndexProForma":85,"CMNSRate":0.0,"DomesticContractIndex":100,"RegionalTargetIndex":100,"RegionalTargetIndexProForma":98,"VsRegionalAverageIndex":75,"VsRegionalAverageIndexProForma":98, "GrossSalesRateProForma":0.0,"FixedExpensesMap":{},"FixedExpenseRate":18.62,"FixedExpense":10000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004bZaIAI","CMTotal":0.0,"CMId":" ","CategoryMap":{"Whisky":249.333336,"White Spirit":149.333328},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":398.666664,"VariableExpensesMap":{},"VariableExpense":43700.00,"TradeExpenses":53700.00,"TradeExpenseBySubBrand":[{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.1322,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":90.9000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":90.9000,"actualPayment":0.00}],"totalTradeExpense":12606.9000,"subBrandName":"百龄坛特醇","subBrandId":"a7FM00000008eKoMAI","subBrandCode":"BAF","ROI":0.0000,"PSFTradeExpense":340.9000,"PSFGap":0,"PSFAmount":340.9000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.1818,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.2979,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":12766.0000,"subBrandName":"绝对伏特加(原味)","subBrandId":"a7FM00000008eKDMAY","subBrandCode":"AB1","ROI":0.0000,"PSFTradeExpense":500.0000,"PSFGap":0,"PSFAmount":500.0000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.5000,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":3.5583,"tradeExpenseByPSFModule":[{"tradeExpense":500.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":500.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":3416.0000,"subBrandName":"维波罗瓦","subBrandId":"a7FM00000008eJZMAY","subBrandCode":"WYV","ROI":0.0000,"PSFTradeExpense":750.0000,"PSFGap":0,"PSFAmount":750.0000,"propByTotal":0.1333,"propByGrade":1.0000,"propByCategory":0.5000,"propByBRSFAmt":0.000000,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Standard","gradeId":"a9tM00000008ONBIA2","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":0.0000,"BRSFIncentive":0.00,"BRSFGap":0,"BRSFAmount":0.0000},{"volumeSTD":960,"volumeCR12":960.0000,"volume9L":74.6667,"VECTradeExpense":2667.0000,"VECGap":0,"VECAmount":2667.0000,"tradeExpensePerBottle":25.9771,"tradeExpenseByPSFModule":[{"tradeExpense":222.2000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":222.2000,"actualPayment":0.00},{"tradeExpense":181.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":181.8000,"actualPayment":0.00}],"totalTradeExpense":24938.0000,"subBrandName":"格兰威特单一麦芽创始人甄选","subBrandId":"a7FM00000000B8ZMAU","subBrandCode":"TGN","ROI":0.0000,"PSFTradeExpense":404.0000,"PSFGap":0,"PSFAmount":404.0000,"propByTotal":0.2667,"propByGrade":0.4444,"propByCategory":0.3636,"propByBRSFAmt":0.307692,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":2667.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":19200.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":19200.0000},{"volumeSTD":1200,"volumeCR12":1200.0000,"volume9L":93.3333,"VECTradeExpense":3333.0000,"VECGap":0,"VECAmount":3333.0000,"tradeExpensePerBottle":25.9759,"tradeExpenseByPSFModule":[{"tradeExpense":277.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":277.8000,"actualPayment":0.00},{"tradeExpense":227.2500,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":227.2500,"actualPayment":0.00}],"totalTradeExpense":31171.0500,"subBrandName":"格兰威特12年","subBrandId":"a7FM00000008eKhMAI","subBrandCode":"GL5","ROI":0.0000,"PSFTradeExpense":505.0500,"PSFGap":0,"PSFAmount":505.0500,"propByTotal":0.3333,"propByGrade":0.5556,"propByCategory":0.4545,"propByBRSFAmt":0.384615,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":3333.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":24000.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":24000.0000}],"TotalMBCRate":97.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":174.666672,"1. Standard + Premium 标准档 + 高档":223.999992},"SubBrandGradeGrouping":{"Super Premium":174.666672,"Standard":74.666664,"Premium":149.333328},"ROIProFormaExcl":0,"ROIProForma":0.0,"ROIIntakeExcl":0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"By Grade(按品牌档次);By Category(按产品类别);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2018-07-01","POEndDate":"2020-06-30","OutletSet":[],"NoOfMonths":24,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottle":-10.65,"MarginAfterAnP":-53700.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":14.92,"IntakeSTD":5040,"IntakeCR12":3600.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRateExcl":0,"GrossSalesRate":0.0,"DomesticContractIndexProForma":85,"DomesticContractIndex":100,"RegionalTargetIndex":98,"RegionalTargetIndexProForma":75,"VsRegionalAverageIndex":30,"VsRegionalAverageIndexProForma":48,"CMNSRateProForma":0.0,"CMNSRate":0.0,"GrossSalesRateProForma":0.0,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":5000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":5000.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":5000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":5000.00,"ContractBottles":0.0}},"FixedExpenseRate":18.62,"FixedExpense":10000.00,"DebugMap":{},"ContractLineMap":{"00004格兰威特12年 The Glenlivet 12YO-GL5":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"格兰威特12年 The Glenlivet 12YO-GL5","SubBrandGrade":"Super Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":24000.00,"EstimateFees":20.00,"EstimateBottles":50,"ContractVolume":1200,"ContractTotalFees":24000.00,"ContractFees":20.00,"ContractBottles":50},"00004TGL Founders Reserve-TGN":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"TGL Founders Reserve-TGN","SubBrandGrade":"Super Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":19200.00,"EstimateFees":20.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":19200.00,"ContractFees":20.00,"ContractBottles":40},"00006维波罗瓦 Wyborowa-WYV":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"维波罗瓦 Wyborowa-WYV","SubBrandGrade":"Standard","SubBrandCategory":"White Spirit","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":0.00,"EstimateFees":0.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":0.00,"ContractFees":0.00,"ContractBottles":40},"00005绝对伏特加(原味) Absolut Blue-AB1":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"绝对伏特加(原味) Absolut Blue-AB1","SubBrandGrade":"Premium","SubBrandCategory":"White Spirit","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":9600.00,"EstimateFees":10.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":9600.00,"ContractFees":10.00,"ContractBottles":40},"00005百龄坛特醇 Ballantines Finest-BAF":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"百龄坛特醇 Ballantines Finest-BAF","SubBrandGrade":"Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":9600.00,"EstimateFees":10.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":9600.00,"ContractFees":10.00,"ContractBottles":40}},"ContractId":"a8cM00000004bZaIAI","CMTotal":0.0,"CMId":" ","CategoryMap":{"Whisky":249.333336,"White Spirit":149.333328},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';

        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c=str;
       
         AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        
        Attachment2.ASI_CRM_Historical_Financial_Data__c= str;
            
                    AttachmentList.add(Attachment2); 
        insert AttachmentList;
        
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        //ASI_CRM_CN_HeavyProfitShuttleCtrl2nd con = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd(stdController);
        ASI_CRM_CN_HeavyProfitShuttleCtrl con = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController);
        String str1 = '{"a8G3N0000004D84UAE":{"contract":{"volumeSTD":20,"volumeCR12":90.0000,"volume9L":1.5556,"VECTradeExpense":2000.0000,"VECPerTradeExpense":100.0000,"VECGap":0,"VECAmount":2000.0000,"tradeExpensePerBottle2nd":329.5000,"tradeExpensePerBottle":329.5000,"tradeExpenseByPSFModule":[{"tradeExpense":1600.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECPSA2","incentivePerCR12":0.0000,"incentivePer":80.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":1600.0000,"actualPayment":0.00},{"tradeExpense":100.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECQSA2","incentivePerCR12":1.1111,"incentivePer":5.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":100.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":400.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECcSAM","incentivePerCR12":0.0000,"incentivePer":20.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":400.0000,"actualPayment":0.00},{"tradeExpense":90.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004EChSAM","incentivePerCR12":0.0000,"incentivePer":4.5000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":90.0000,"actualPayment":0.00}],"totalTradeExpense":6590.0000,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":1.6545,"RegionalTargetIndex":49.4043,"RegionalAverageInvestment":1000.000000,"RegionalAverageIndex":88.00,"RegionalAverageAfterSpending":6396.646180,"PSFTradeExpense":1700.0000,"PSFPerTradeExpense":85.0000,"PSFGap":0,"PSFAmount":1700.0000,"propByTotal":0.45000000,"propByStdTotal":0.25000000,"propByGrade":1.00000000,"propByCategory":0.52941176,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":10,"monthlyVolumeCR12":45.0000,"monthlyVolume9L":0.7778,"MarginPerBottle":245.7947,"latestBudgetCMTotal":11506.2228,"GSTotal":17680.2772,"GSPercent":37.2732,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":251.7222,"GapWithRegionalAverageIndex":-38.5957,"GapWithDomesticInvestment":244.2556,"GapWithDomesticIndexTarget":-49.8430,"fixCostTradeExpense":490.0000,"fixCostPerTradeExpense":24.5000,"factor9L":0.7,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":50.1570,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":10903.1805,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":2400.0000,"BRSFPerTradeExpense":120.00,"BRSFIncentive":120.00,"BRSFGap":0,"BRSFAmount":2400.0000},"estimate":{"volumeSTD":60,"volumeCR12":270.0000,"volume9L":4.6667,"VECTradeExpense":6000.0000,"VECPerTradeExpense":100.0000,"VECGap":0,"VECAmount":6000.0000,"tradeExpensePerBottle2nd":329.5000,"tradeExpensePerBottle":329.5000,"tradeExpenseByPSFModule":[{"tradeExpense":4800.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECPSA2","incentivePerCR12":0.0000,"incentivePer":80.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":4800.0000,"actualPayment":0.00},{"tradeExpense":300.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECQSA2","incentivePerCR12":1.1111,"incentivePer":5.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":300.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":1200.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECcSAM","incentivePerCR12":0.0000,"incentivePer":20.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":1200.0000,"actualPayment":0.00},{"tradeExpense":270.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004EChSAM","incentivePerCR12":0.0000,"incentivePer":4.5000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":270.0000,"actualPayment":0.00}],"totalTradeExpense":19770.0000,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":1.6545,"RegionalTargetIndex":49.4043,"RegionalAverageInvestment":1000.000000,"RegionalAverageIndex":88.00,"RegionalAverageAfterSpending":6396.646180,"PSFTradeExpense":5100.0000,"PSFPerTradeExpense":85.0000,"PSFGap":0,"PSFAmount":5100.0000,"propByTotal":0.71052632,"propByStdTotal":0.50000000,"propByGrade":1.00000000,"propByCategory":0.77142857,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":30,"monthlyVolumeCR12":135.0000,"monthlyVolume9L":2.3333,"MarginPerBottle":245.7947,"latestBudgetCMTotal":34517.9287,"GSTotal":53039.6951,"GSPercent":37.2740,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":251.7222,"GapWithRegionalAverageIndex":-38.5957,"GapWithDomesticInvestment":244.2556,"GapWithDomesticIndexTarget":-49.8430,"fixCostTradeExpense":1470.0000,"fixCostPerTradeExpense":24.5000,"factor9L":0.7,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":50.1570,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":32708.8406,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":7200.0000,"BRSFPerTradeExpense":120.00,"BRSFIncentive":120.00,"BRSFGap":0,"BRSFAmount":7200.0000},"historical":{"volumeSTD":0,"volumeCR12":0.0000,"volume9L":0.0000,"VECTradeExpense":0.0000,"VECPerTradeExpense":0,"VECGap":0,"VECAmount":0,"tradeExpensePerBottle2nd":0.0000,"tradeExpensePerBottle":0,"tradeExpenseByPSFModule":[],"tradeExpenseByFXModule":[],"totalTradeExpense":0.0000,"subBrandName":null,"subBrandId":null,"subBrandCode":"","ROI":0,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":0.0000,"PSFPerTradeExpense":0,"PSFGap":0,"PSFAmount":0.0000,"propByTotal":1,"propByStdTotal":0,"propByGrade":1,"propByCategory":1,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":0,"monthlyVolumeCR12":0.0000,"monthlyVolume9L":0.0000,"MarginPerBottle":0.0,"latestBudgetCMTotal":0,"GSTotal":0,"GSPercent":0,"gradeName":null,"gradeId":null,"GapWithRegionalAverageInvestment":0.0,"GapWithRegionalAverageIndex":null,"GapWithDomesticInvestment":0.0,"GapWithDomesticIndexTarget":null,"fixCostTradeExpense":0,"fixCostPerTradeExpense":0,"factor9L":1,"DomesticInvestment":0.0,"DomesticIndexTarget":0.0,"DomesticContractIndex":0.0,"DomesticCMAfterSpending":0.0,"cr12Factor":1,"CMTotal":0,"CMBeforeSpending":0.0,"categoryName":null,"categoryId":null,"BRSFTradeExpense":0.0000,"BRSFPerTradeExpense":0,"BRSFIncentive":0,"BRSFGap":0,"BRSFAmount":0}},"a8G3N0000004CrmUAE":{"contract":{"volumeSTD":40,"volumeCR12":80.0000,"volume9L":3.1111,"VECTradeExpense":600.0000,"VECPerTradeExpense":15.0000,"VECGap":0,"VECAmount":600.0000,"tradeExpensePerBottle2nd":86.8182,"tradeExpensePerBottle":86.8182,"tradeExpenseByPSFModule":[{"tradeExpense":800.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECPSA2","incentivePerCR12":0.0000,"incentivePer":20.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":800.0000,"actualPayment":0.00},{"tradeExpense":72.7273,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECQSA2","incentivePerCR12":0.9091,"incentivePer":1.8182,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":72.7273,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":480.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECcSAM","incentivePerCR12":0.0000,"incentivePer":12.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":480.0000,"actualPayment":0.00},{"tradeExpense":80.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004EChSAM","incentivePerCR12":0.0000,"incentivePer":2.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":80.0000,"actualPayment":0.00}],"totalTradeExpense":3472.7273,"subBrandName":"格兰威特15年","subBrandId":"a8G3N0000004CrmUAE","subBrandCode":"GLF","ROI":3.9542,"RegionalTargetIndex":99.4880,"RegionalAverageInvestment":1100.000000,"RegionalAverageIndex":95.00,"RegionalAverageAfterSpending":3170.434606,"PSFTradeExpense":872.7273,"PSFPerTradeExpense":21.8182,"PSFGap":0,"PSFAmount":872.7273,"propByTotal":0.40000000,"propByStdTotal":0.50000000,"propByGrade":0.72727273,"propByCategory":0.47058824,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":20,"monthlyVolumeCR12":40.0000,"monthlyVolume9L":1.5556,"MarginPerBottle":245.3267,"latestBudgetCMTotal":13285.7491,"GSTotal":16354.3029,"GSPercent":21.2343,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":1.2626,"GapWithRegionalAverageIndex":4.4880,"GapWithDomesticInvestment":1.2626,"GapWithDomesticIndexTarget":-0.5120,"fixCostTradeExpense":560.0000,"fixCostPerTradeExpense":14.0000,"factor9L":0.7,"DomesticInvestment":1100.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":99.4880,"DomesticCMAfterSpending":3170.434606,"cr12Factor":2.00,"CMTotal":13731.9960,"CMBeforeSpending":4270.434606,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":1440.0000,"BRSFPerTradeExpense":36.00,"BRSFIncentive":36.00,"BRSFGap":0,"BRSFAmount":1440.0000},"estimate":{"volumeSTD":40,"volumeCR12":80.0000,"volume9L":3.1111,"VECTradeExpense":600.0000,"VECPerTradeExpense":15.0000,"VECGap":0,"VECAmount":600.0000,"tradeExpensePerBottle2nd":86.8182,"tradeExpensePerBottle":86.8182,"tradeExpenseByPSFModule":[{"tradeExpense":800.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECPSA2","incentivePerCR12":0.0000,"incentivePer":20.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":800.0000,"actualPayment":0.00},{"tradeExpense":72.7273,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECQSA2","incentivePerCR12":0.9091,"incentivePer":1.8182,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":72.7273,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":480.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECcSAM","incentivePerCR12":0.0000,"incentivePer":12.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":480.0000,"actualPayment":0.00},{"tradeExpense":80.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004EChSAM","incentivePerCR12":0.0000,"incentivePer":2.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":80.0000,"actualPayment":0.00}],"totalTradeExpense":3472.7273,"subBrandName":"格兰威特15年","subBrandId":"a8G3N0000004CrmUAE","subBrandCode":"GLF","ROI":3.9542,"RegionalTargetIndex":99.4880,"RegionalAverageInvestment":1100.000000,"RegionalAverageIndex":95.00,"RegionalAverageAfterSpending":3170.434606,"PSFTradeExpense":872.7273,"PSFPerTradeExpense":21.8182,"PSFGap":0,"PSFAmount":872.7273,"propByTotal":0.21052632,"propByStdTotal":0.33333333,"propByGrade":0.72727273,"propByCategory":0.22857143,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":20,"monthlyVolumeCR12":40.0000,"monthlyVolume9L":1.5556,"MarginPerBottle":245.3267,"latestBudgetCMTotal":13285.7491,"GSTotal":16354.3029,"GSPercent":21.2343,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":1.2626,"GapWithRegionalAverageIndex":4.4880,"GapWithDomesticInvestment":1.2626,"GapWithDomesticIndexTarget":-0.5120,"fixCostTradeExpense":560.0000,"fixCostPerTradeExpense":14.0000,"factor9L":0.7,"DomesticInvestment":1100.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":99.4880,"DomesticCMAfterSpending":3170.434606,"cr12Factor":2.00,"CMTotal":13731.9960,"CMBeforeSpending":4270.434606,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":1440.0000,"BRSFPerTradeExpense":36.00,"BRSFIncentive":36.00,"BRSFGap":0,"BRSFAmount":1440.0000},"historical":{"volumeSTD":0,"volumeCR12":0.0000,"volume9L":0.0000,"VECTradeExpense":0.0000,"VECPerTradeExpense":0,"VECGap":0,"VECAmount":0,"tradeExpensePerBottle2nd":0.0000,"tradeExpensePerBottle":0,"tradeExpenseByPSFModule":[],"tradeExpenseByFXModule":[],"totalTradeExpense":0.0000,"subBrandName":null,"subBrandId":null,"subBrandCode":"","ROI":0,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":0.0000,"PSFPerTradeExpense":0,"PSFGap":0,"PSFAmount":0.0000,"propByTotal":1,"propByStdTotal":0,"propByGrade":1,"propByCategory":1,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":0,"monthlyVolumeCR12":0.0000,"monthlyVolume9L":0.0000,"MarginPerBottle":0.0,"latestBudgetCMTotal":0,"GSTotal":0,"GSPercent":0,"gradeName":null,"gradeId":null,"GapWithRegionalAverageInvestment":0.0,"GapWithRegionalAverageIndex":null,"GapWithDomesticInvestment":0.0,"GapWithDomesticIndexTarget":null,"fixCostTradeExpense":0,"fixCostPerTradeExpense":0,"factor9L":1,"DomesticInvestment":0.0,"DomesticIndexTarget":0.0,"DomesticContractIndex":0.0,"DomesticCMAfterSpending":0.0,"cr12Factor":1,"CMTotal":0,"CMBeforeSpending":0.0,"categoryName":null,"categoryId":null,"BRSFTradeExpense":0.0000,"BRSFPerTradeExpense":0,"BRSFIncentive":0,"BRSFGap":0,"BRSFAmount":0}},"a8G3N0000004D8mUAE":{"contract":{"volumeSTD":20,"volumeCR12":30.0000,"volume9L":1.5556,"VECTradeExpense":1200.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":1200.0000,"tradeExpensePerBottle2nd":222.8636,"tradeExpensePerBottle":222.8636,"tradeExpenseByPSFModule":[{"tradeExpense":1000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECPSA2","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":1000.0000,"actualPayment":0.00},{"tradeExpense":27.2727,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECQSA2","incentivePerCR12":0.9091,"incentivePer":1.3636,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27.2727,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":200.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECcSAM","incentivePerCR12":0.0000,"incentivePer":10.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":200.0000,"actualPayment":0.00},{"tradeExpense":30.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004EChSAM","incentivePerCR12":0.0000,"incentivePer":1.5000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":30.0000,"actualPayment":0.00}],"totalTradeExpense":4457.2727,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.3339,"RegionalTargetIndex":23.0913,"RegionalAverageInvestment":380.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3218.610000,"PSFTradeExpense":1027.2727,"PSFPerTradeExpense":51.3636,"PSFGap":0,"PSFAmount":1027.2727,"propByTotal":0.15000000,"propByStdTotal":0.25000000,"propByGrade":0.27272727,"propByCategory":1.00000000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":10,"monthlyVolumeCR12":15.0000,"monthlyVolume9L":0.7778,"MarginPerBottle":57.8058,"latestBudgetCMTotal":5613.5488,"GSTotal":8255.2048,"GSPercent":53.9935,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":193.3080,"GapWithRegionalAverageIndex":-61.9087,"GapWithDomesticInvestment":190.2747,"GapWithDomesticIndexTarget":-75.2288,"fixCostTradeExpense":230.0000,"fixCostPerTradeExpense":11.5000,"factor9L":0.7,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":24.7712,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":5945.7675,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":2000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":2000.0000},"estimate":{"volumeSTD":20,"volumeCR12":30.0000,"volume9L":1.5556,"VECTradeExpense":1200.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":1200.0000,"tradeExpensePerBottle2nd":222.8636,"tradeExpensePerBottle":222.8636,"tradeExpenseByPSFModule":[{"tradeExpense":1000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECPSA2","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":1000.0000,"actualPayment":0.00},{"tradeExpense":27.2727,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECQSA2","incentivePerCR12":0.9091,"incentivePer":1.3636,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27.2727,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":200.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004ECcSAM","incentivePerCR12":0.0000,"incentivePer":10.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":200.0000,"actualPayment":0.00},{"tradeExpense":30.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004EChSAM","incentivePerCR12":0.0000,"incentivePer":1.5000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":30.0000,"actualPayment":0.00}],"totalTradeExpense":4457.2727,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.3339,"RegionalTargetIndex":23.0913,"RegionalAverageInvestment":380.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3218.610000,"PSFTradeExpense":1027.2727,"PSFPerTradeExpense":51.3636,"PSFGap":0,"PSFAmount":1027.2727,"propByTotal":0.07894737,"propByStdTotal":0.16666667,"propByGrade":0.27272727,"propByCategory":1.00000000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":10,"monthlyVolumeCR12":15.0000,"monthlyVolume9L":0.7778,"MarginPerBottle":57.8058,"latestBudgetCMTotal":5613.5488,"GSTotal":8255.2048,"GSPercent":53.9935,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":193.3080,"GapWithRegionalAverageIndex":-61.9087,"GapWithDomesticInvestment":190.2747,"GapWithDomesticIndexTarget":-75.2288,"fixCostTradeExpense":230.0000,"fixCostPerTradeExpense":11.5000,"factor9L":0.7,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":24.7712,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":5945.7675,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":2000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":2000.0000},"historical":{"volumeSTD":0,"volumeCR12":0.0000,"volume9L":0.0000,"VECTradeExpense":0.0000,"VECPerTradeExpense":0,"VECGap":0,"VECAmount":0,"tradeExpensePerBottle2nd":0.0000,"tradeExpensePerBottle":0,"tradeExpenseByPSFModule":[],"tradeExpenseByFXModule":[],"totalTradeExpense":0.0000,"subBrandName":null,"subBrandId":null,"subBrandCode":"","ROI":0,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":0.0000,"PSFPerTradeExpense":0,"PSFGap":0,"PSFAmount":0.0000,"propByTotal":1,"propByStdTotal":0,"propByGrade":1,"propByCategory":1,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":0,"monthlyVolumeCR12":0.0000,"monthlyVolume9L":0.0000,"MarginPerBottle":0.0,"latestBudgetCMTotal":0,"GSTotal":0,"GSPercent":0,"gradeName":null,"gradeId":null,"GapWithRegionalAverageInvestment":0.0,"GapWithRegionalAverageIndex":null,"GapWithDomesticInvestment":0.0,"GapWithDomesticIndexTarget":null,"fixCostTradeExpense":0,"fixCostPerTradeExpense":0,"factor9L":1,"DomesticInvestment":0.0,"DomesticIndexTarget":0.0,"DomesticContractIndex":0.0,"DomesticCMAfterSpending":0.0,"cr12Factor":1,"CMTotal":0,"CMBeforeSpending":0.0,"categoryName":null,"categoryId":null,"BRSFTradeExpense":0.0000,"BRSFPerTradeExpense":0,"BRSFIncentive":0,"BRSFGap":0,"BRSFAmount":0}}}';
        
        //Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> objMap = (Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>)JSON.deserialize(str1, Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>.class);
        Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown>> objMap = (Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown>>)JSON.deserialize(str1, Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown>>.class);

        con.strPDF='1';
        con.investmentBySubBrandByContractBySubBrand = objMap;
        //con.init();
        con.initPage();
        
        con.checkApprover2nd(new Set<Id>{currentUser.Id});
        con.checkLastRBAID2nd();
        con.checkLastRBAID();
        con.checkUserID();
        con.checkApprover();
        con.SplitLineIntoRow('测试测试', 2);
        List<ASI_CRM_Approval_Comment__c> ApprovalCommentList= new List<ASI_CRM_Approval_Comment__c>();
        ApprovalCommentList.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        ApprovalCommentList.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        
        
        insert ApprovalCommentList;
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(Contract);  
        //ASI_CRM_CN_HeavyProfitShuttleCtrl2nd con2 = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd(stdController2);
        ASI_CRM_CN_HeavyProfitShuttleCtrl con2 = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController2);
        con2.strPDF='3';
        //con2.init();
        con2.initPage();
        

        con2.checkApprover2nd(new Set<Id>{currentUser.Id});
        con2.checkLastRBAID2nd();
        
        test.stopTest(); 
        
    }


    static testMethod void HeavyProfitShuttleCtrlTest2() {//Test ASI_CRM_CN_HeavyProfitShuttleCtrl2nd
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
          insert channel;
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
            insert subChannel;

            ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
            insert newChannel;

            list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
            Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
            Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
            insert Customers;
  
  
            /*list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
            ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
            insert ChildCustomers;
            */
        
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium ??? + ??',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        insert sptm;*/
        
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_Martell_BC_Rate__c=0.95,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_Martell_BC_Rate__c=0.95,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
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
        
        /*
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='????',
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
        */
        
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
        
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        string str = '[{"Volumes":398.666664,"VariableExpensesMap":{},"VariableExpense":43700.00,"TradeExpenses":53700.00,"TradeExpenseBySubBrand":[{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.1322,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":90.9000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":90.9000,"actualPayment":0.00}],"totalTradeExpense":12606.9000,"subBrandName":"百龄坛特醇","subBrandId":"a7FM00000008eKoMAI","subBrandCode":"BAF","ROI":0.0000,"PSFTradeExpense":340.9000,"PSFGap":0,"PSFAmount":340.9000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.1818,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.2979,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":12766.0000,"subBrandName":"绝对伏特加(原味)","subBrandId":"a7FM00000008eKDMAY","subBrandCode":"AB1","ROI":0.0000,"PSFTradeExpense":500.0000,"PSFGap":0,"PSFAmount":500.0000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.5000,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":3.5583,"tradeExpenseByPSFModule":[{"tradeExpense":500.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":500.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":3416.0000,"subBrandName":"维波罗瓦","subBrandId":"a7FM00000008eJZMAY","subBrandCode":"WYV","ROI":0.0000,"PSFTradeExpense":750.0000,"PSFGap":0,"PSFAmount":750.0000,"propByTotal":0.1333,"propByGrade":1.0000,"propByCategory":0.5000,"propByBRSFAmt":0.000000,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Standard","gradeId":"a9tM00000008ONBIA2","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":0.0000,"BRSFIncentive":0.00,"BRSFGap":0,"BRSFAmount":0.0000},{"volumeSTD":960,"volumeCR12":960.0000,"volume9L":74.6667,"VECTradeExpense":2667.0000,"VECGap":0,"VECAmount":2667.0000,"tradeExpensePerBottle":25.9771,"tradeExpenseByPSFModule":[{"tradeExpense":222.2000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":222.2000,"actualPayment":0.00},{"tradeExpense":181.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":181.8000,"actualPayment":0.00}],"totalTradeExpense":24938.0000,"subBrandName":"格兰威特单一麦芽创始人甄选","subBrandId":"a7FM00000000B8ZMAU","subBrandCode":"TGN","ROI":0.0000,"PSFTradeExpense":404.0000,"PSFGap":0,"PSFAmount":404.0000,"propByTotal":0.2667,"propByGrade":0.4444,"propByCategory":0.3636,"propByBRSFAmt":0.307692,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":2667.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":19200.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":19200.0000},{"volumeSTD":1200,"volumeCR12":1200.0000,"volume9L":93.3333,"VECTradeExpense":3333.0000,"VECGap":0,"VECAmount":3333.0000,"tradeExpensePerBottle":25.9759,"tradeExpenseByPSFModule":[{"tradeExpense":277.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":277.8000,"actualPayment":0.00},{"tradeExpense":227.2500,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":227.2500,"actualPayment":0.00}],"totalTradeExpense":31171.0500,"subBrandName":"格兰威特12年","subBrandId":"a7FM00000008eKhMAI","subBrandCode":"GL5","ROI":0.0000,"PSFTradeExpense":505.0500,"PSFGap":0,"PSFAmount":505.0500,"propByTotal":0.3333,"propByGrade":0.5556,"propByCategory":0.4545,"propByBRSFAmt":0.384615,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":3333.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":24000.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":24000.0000}],"TotalMBCRate":97.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":174.666672,"1. Standard + Premium 标准档 + 高档":223.999992},"SubBrandGradeGrouping":{"Super Premium":174.666672,"Standard":74.666664,"Premium":149.333328},"ROIProFormaExcl":0,"ROIProForma":0.0,"ROIIntakeExcl":0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"By Grade(按品牌档次);By Category(按产品类别);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2018-07-01","POEndDate":"2020-06-30","OutletSet":[],"NoOfMonths":24,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottle":-10.65,"MarginAfterAnP":-53700.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":14.92,"IntakeSTD":5040,"IntakeCR12":3600.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRateExcl":0,"GrossSalesRate":0.0,"DomesticContractIndex":100,"RegionalTargetIndex":56,"RegionalTargetIndexProForma":98,"VsRegionalAverageIndex":78,"VsRegionalAverageIndexProForma":95,"DomesticContractIndexProForma":85,"CMNSRateProForma":0.0,"CMNSRate":0.0,"GrossSalesRateProForma":0.0,"FixedExpensesMap":{},"FixedExpenseRate":18.62,"FixedExpense":10000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004bZaIAI","CMTotal":0.0,"CMId":" ","CategoryMap":{"Whisky":249.333336,"White Spirit":149.333328},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":398.666664,"VariableExpensesMap":{},"VariableExpense":43700.00,"TradeExpenses":53700.00,"TradeExpenseBySubBrand":[{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.1322,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":90.9000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":90.9000,"actualPayment":0.00}],"totalTradeExpense":12606.9000,"subBrandName":"百龄坛特醇","subBrandId":"a7FM00000008eKoMAI","subBrandCode":"BAF","ROI":0.0000,"PSFTradeExpense":340.9000,"PSFGap":0,"PSFAmount":340.9000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.1818,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.2979,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":12766.0000,"subBrandName":"绝对伏特加(原味)","subBrandId":"a7FM00000008eKDMAY","subBrandCode":"AB1","ROI":0.0000,"PSFTradeExpense":500.0000,"PSFGap":0,"PSFAmount":500.0000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.5000,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":3.5583,"tradeExpenseByPSFModule":[{"tradeExpense":500.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":500.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":3416.0000,"subBrandName":"维波罗瓦","subBrandId":"a7FM00000008eJZMAY","subBrandCode":"WYV","ROI":0.0000,"PSFTradeExpense":750.0000,"PSFGap":0,"PSFAmount":750.0000,"propByTotal":0.1333,"propByGrade":1.0000,"propByCategory":0.5000,"propByBRSFAmt":0.000000,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Standard","gradeId":"a9tM00000008ONBIA2","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":0.0000,"BRSFIncentive":0.00,"BRSFGap":0,"BRSFAmount":0.0000},{"volumeSTD":960,"volumeCR12":960.0000,"volume9L":74.6667,"VECTradeExpense":2667.0000,"VECGap":0,"VECAmount":2667.0000,"tradeExpensePerBottle":25.9771,"tradeExpenseByPSFModule":[{"tradeExpense":222.2000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":222.2000,"actualPayment":0.00},{"tradeExpense":181.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":181.8000,"actualPayment":0.00}],"totalTradeExpense":24938.0000,"subBrandName":"格兰威特单一麦芽创始人甄选","subBrandId":"a7FM00000000B8ZMAU","subBrandCode":"TGN","ROI":0.0000,"PSFTradeExpense":404.0000,"PSFGap":0,"PSFAmount":404.0000,"propByTotal":0.2667,"propByGrade":0.4444,"propByCategory":0.3636,"propByBRSFAmt":0.307692,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":2667.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":19200.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":19200.0000},{"volumeSTD":1200,"volumeCR12":1200.0000,"volume9L":93.3333,"VECTradeExpense":3333.0000,"VECGap":0,"VECAmount":3333.0000,"tradeExpensePerBottle":25.9759,"tradeExpenseByPSFModule":[{"tradeExpense":277.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":277.8000,"actualPayment":0.00},{"tradeExpense":227.2500,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":227.2500,"actualPayment":0.00}],"totalTradeExpense":31171.0500,"subBrandName":"格兰威特12年","subBrandId":"a7FM00000008eKhMAI","subBrandCode":"GL5","ROI":0.0000,"PSFTradeExpense":505.0500,"PSFGap":0,"PSFAmount":505.0500,"propByTotal":0.3333,"propByGrade":0.5556,"propByCategory":0.4545,"propByBRSFAmt":0.384615,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":3333.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":24000.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":24000.0000}],"TotalMBCRate":97.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":174.666672,"1. Standard + Premium 标准档 + 高档":223.999992},"SubBrandGradeGrouping":{"Super Premium":174.666672,"Standard":74.666664,"Premium":149.333328},"ROIProFormaExcl":0,"ROIProForma":0.0,"ROIIntakeExcl":0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"By Grade(按品牌档次);By Category(按产品类别);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2018-07-01","POEndDate":"2020-06-30","OutletSet":[],"NoOfMonths":24,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottle":-10.65,"MarginAfterAnP":-53700.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":14.92,"IntakeSTD":5040,"IntakeCR12":3600.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRateExcl":0,"GrossSalesRate":0.0,"DomesticContractIndex":100,"RegionalTargetIndex":65,"RegionalTargetIndexProForma":40,"VsRegionalAverageIndex":49,"VsRegionalAverageIndexProForma":49,"DomesticContractIndexProForma":85,"CMNSRateProForma":0.0,"CMNSRate":0.0,"GrossSalesRateProForma":0.0,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":5000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":5000.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":5000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":5000.00,"ContractBottles":0.0}},"FixedExpenseRate":18.62,"FixedExpense":10000.00,"DebugMap":{},"ContractLineMap":{"00004格兰威特12年 The Glenlivet 12YO-GL5":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"格兰威特12年 The Glenlivet 12YO-GL5","SubBrandGrade":"Super Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":24000.00,"EstimateFees":20.00,"EstimateBottles":50,"ContractVolume":1200,"ContractTotalFees":24000.00,"ContractFees":20.00,"ContractBottles":50},"00004TGL Founders Reserve-TGN":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"TGL Founders Reserve-TGN","SubBrandGrade":"Super Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":19200.00,"EstimateFees":20.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":19200.00,"ContractFees":20.00,"ContractBottles":40},"00006维波罗瓦 Wyborowa-WYV":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"维波罗瓦 Wyborowa-WYV","SubBrandGrade":"Standard","SubBrandCategory":"White Spirit","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":0.00,"EstimateFees":0.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":0.00,"ContractFees":0.00,"ContractBottles":40},"00005绝对伏特加(原味) Absolut Blue-AB1":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"绝对伏特加(原味) Absolut Blue-AB1","SubBrandGrade":"Premium","SubBrandCategory":"White Spirit","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":9600.00,"EstimateFees":10.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":9600.00,"ContractFees":10.00,"ContractBottles":40},"00005百龄坛特醇 Ballantines Finest-BAF":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"百龄坛特醇 Ballantines Finest-BAF","SubBrandGrade":"Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":9600.00,"EstimateFees":10.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":9600.00,"ContractFees":10.00,"ContractBottles":40}},"ContractId":"a8cM00000004bZaIAI","CMTotal":0.0,"CMId":" ","CategoryMap":{"Whisky":249.333336,"White Spirit":149.333328},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';

        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c=str;
       
         AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        
        Attachment2.ASI_CRM_Historical_Financial_Data__c= str;
            
                    AttachmentList.add(Attachment2); 
        insert AttachmentList;
        
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        //ASI_CRM_CN_HeavyProfitShuttleCtrl2nd con = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd(stdController);
        ASI_CRM_CN_HeavyProfitShuttleCtrl con = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController);
        con.strPDF='0';
        //con.init();
        con.initPage();
        
        con.checkApprover2nd(new Set<Id>{currentUser.Id});
        con.checkLastRBAID2nd();
        con.checkLastRBAID();
        con.checkUserID();
        con.checkApprover();
        con.SplitLineIntoRow('Test', 2);
        List<ASI_CRM_Approval_Comment__c> ApprovalCommentList= new List<ASI_CRM_Approval_Comment__c>();
        ApprovalCommentList.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        ApprovalCommentList.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        
        
        insert ApprovalCommentList;
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(Contract);  
        //ASI_CRM_CN_HeavyProfitShuttleCtrl2nd con2 = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd(stdController2);
        ASI_CRM_CN_HeavyProfitShuttleCtrl con2 = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController2);

        con2.strPDF='2';
        //con2.init();
        con2.initPage();
        con2.checkApprover2nd(new Set<Id>{currentUser.Id});
        con2.checkLastRBAID2nd();
        


        //2020/08/05新增
        Contract.ASI_CRM_CN_Is_2nd_KPI_PO__c = true;
        update Contract;

        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController3 = new ApexPages.Standardcontroller(Contract);  
        //ASI_CRM_CN_HeavyProfitShuttleCtrl2nd con = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd(stdController);
        ASI_CRM_CN_HeavyProfitShuttleCtrl con3 = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController3);
        con3.strPDF='0';
        //con.init();
        con3.initPage();
        
        con3.checkApprover2nd(new Set<Id>{currentUser.Id});
        con3.checkLastRBAID2nd();
        con3.checkLastRBAID();
        con3.checkUserID();
        con3.checkApprover();
        con3.SplitLineIntoRow('Test', 2);
        List<ASI_CRM_Approval_Comment__c> ApprovalCommentList3= new List<ASI_CRM_Approval_Comment__c>();
        ApprovalCommentList3.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        ApprovalCommentList3.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        
        
        insert ApprovalCommentList3;
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController4 = new ApexPages.Standardcontroller(Contract);  
        //ASI_CRM_CN_HeavyProfitShuttleCtrl2nd con2 = new ASI_CRM_CN_HeavyProfitShuttleCtrl2nd(stdController2);
        ASI_CRM_CN_HeavyProfitShuttleCtrl con4 = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController4);

        con4.strPDF='3';
        //con2.init();
        con4.initPage();
        con4.checkApprover2nd(new Set<Id>{currentUser.Id});
        con4.checkLastRBAID2nd();

        test.stopTest(); 
        
    }

}