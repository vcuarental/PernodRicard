@isTest

public class ASI_CRM_CN_HeavyContractTestClassHelper {
    public static void createWholesalerAndOutlet(){
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

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Premium',
                RecordTypeId = rtWS,
                Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.Id
            )
        );
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST2',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
    }
    //****************************************************************************************************************************************************** 
    //***************************************Helper Method*************************************************************************************************
    //****************************************************************************************************************************************************** 

    public static String GeneratingJSonData_CurrentV0VFinalData(){
        //Current V0VFinal Data
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> FinancialIndicatorList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalV00Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator();
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator();

        HistoricalV00Contract=FinancialIndicatorFieldAssignment(HistoricalV00Contract);
        HistoricalVFinalContract=FinancialIndicatorFieldAssignment(HistoricalVFinalContract);

        FinancialIndicatorList.add(HistoricalV00Contract);
        FinancialIndicatorList.add(HistoricalVFinalContract);


        return System.JSON.serialize(FinancialIndicatorList);
    }


    public static String GeneratingJSonData_POModificationData(){
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ReturnList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator POModiContractFI= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator();

        POModiContractFI=FinancialIndicatorFieldAssignment(POModiContractFI);
        ReturnList.add(POModiContractFI);
        return System.JSON.serialize(ReturnList);
    }


    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FinancialIndicatorFieldAssignment(ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator InputFI){
        InputFI.Volumes=10;
        InputFI.GrossSalesTotal=Math.random()*1000;
        InputFI.TradeExpenses=Math.random()*1000;
        InputFI.IntakeCR12=Math.random()*1000;
        InputFI.FixedExpense=Math.random()*1000;
        InputFI.IntakeSTD=Math.random()*1000;
        InputFI.MarginAfterAnP =Math.random()*1000;
        InputFI.CMTotal =Math.random()*1000;
        InputFI.LatestBudgetCMTotal =Math.random()*1000;
        InputFI.AddOnString='{\"TotalHC_IntakeBtl\":31613.60,\"TotalBackCap\":0,\"TotalHC_BC\":31521.97,\"TotalBC_prorate\":31521.9699999999999999999999999999996756,\"Total_IntakeBtl_prorate\":31613.60000000000000000000000000000736,\"TotalBlackCap_prorate\":0,\"VECEstTotal\":0,\"PSFEstTotal\":2264262.00}';


        return InputFI;
    }

    public static ASI_TH_CRM_PaymentRequestLineItem__c PaymentLineFieldAssignment(ASI_TH_CRM_PaymentRequestLineItem__c InputLine){
        InputLine.ASI_CRM_CN_Incentive_BT__c=100;
        InputLine.ASI_CRM_CN_Allow_Changing_Incentive__c=true;
        return InputLine;
    }



    public static list<ASI_TH_CRM_PaymentRequest__c> GeneratePaymentList(){

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
                PaymentLine=PaymentLineFieldAssignment(PaymentLine);
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


        return PaymentRequestList;

    }

    public static ASI_CRM_Subbrand_Volume__c VolumeFieldAssignment(ASI_CRM_Subbrand_Volume__c InputVolume){
        InputVolume.ASI_CRM_Offtake_Std_Billing__c= Math.random()*1000;
        InputVolume.ASI_CRM_Offtake_CR12__c= Math.random()*1000;
        InputVolume.ASI_CRM_T1_Depletion_STD_Billing__c= Math.random()*1000;
        InputVolume.ASI_CRM_T2_Depletion_STD_Billing__c= Math.random()*1000;
        InputVolume.ASI_CRM_PR_Direct_STD_Billing__c= Math.random()*1000;
        InputVolume.ASI_CRM_T1_Depletion_CR12__c= Math.random()*1000;
        InputVolume.ASI_CRM_T2_Depletion_CR12__c= Math.random()*1000;
        InputVolume.ASI_CRM_PR_Direct_CR12__c= Math.random()*1000;
        InputVolume.ASI_CRM_DeductCapWithIssue_StdBill__c= Math.random()*1000;
        InputVolume.ASI_CRM_Deductible_Cap_with_Issues_CR12__c= Math.random()*1000;
        InputVolume.ASI_CRM_DeductCapWithIssue_StdBill__c= Math.random()*1000;
        InputVolume.ASI_CRM_Penalty_Coefficient_Applied__c= Math.random()*1000;
        InputVolume.ASI_CRM_Green_Cap_Std_Billing__c= Math.random()*1000;
        InputVolume.ASI_CRM_Empty_Bottle_Std_Billing__c= Math.random()*1000;
        InputVolume.ASI_CRM_Empty_Bottle_CR12__c= Math.random()*1000;
        InputVolume.ASI_CRM_Green_Cap_CR12__c= Math.random()*1000;
        InputVolume.ASI_CRM_CN_Exclude_From_Payment_Volume__c=false;
        return InputVolume;
    }

    public static ASI_TH_CRM_Contract__c CreateSimpleContract(){
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



        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
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

        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;

        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=1000000,ASI_CRM_Total_Amount_Checking__c=50000);


        insert CustomSetting ;

        return Contract;
    }







    //****************************************************************************************************************************************************** 
    //****************************************************************************************************************************************************** 
    //***************************************Helper Method End*************************************************************************************************
    //****************************************************************************************************************************************************** 
    //****************************************************************************************************************************************************** 



    static testMethod void HeavyPDFRedirectControllerTest1() {
        //Test ASI_CRM_CN_HeavyPDFRedirectController
        ASI_TH_CRM_Contract__c ContractInserted=  ASI_CRM_CN_HeavyContractTestClassHelper.CreateSimpleContract();

        test.startTest();
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(ContractInserted);
        ASI_CRM_CN_HeavyPDFRedirectController con1 = new ASI_CRM_CN_HeavyPDFRedirectController(stdController1);

        ApexPages.CurrentPage().getparameters().put('Type', 'PDF');
        con1.CalculationRedirect();


        ApexPages.CurrentPage().getparameters().put('Type', 'POModificationPDF');
        con1.CalculationRedirect();


        ApexPages.CurrentPage().getparameters().put('Type', 'SubmitApproval');
        con1.CalculationRedirect();

        ApexPages.CurrentPage().getparameters().put('Type', 'ViewCheckPoint');
        con1.CalculationRedirect();

        test.stopTest();
    }



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

        ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(342343);
        test.stopTest();
    }



    static testMethod void HeavyContractGenSelectionTest() {
        //Test ASI_CRM_CN_HeavyContractGenSelectionCtrl

        ASI_TH_CRM_Contract__c ContractInserted=  CreateSimpleContract();
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', ContractInserted.id);
        ASI_CRM_CN_HeavyContractGenSelectionCtrl con = new ASI_CRM_CN_HeavyContractGenSelectionCtrl();

        con.init();
        con.proceed();
        test.stopTest();

    }

    static testMethod void ASI_CRM_CN_ContractTest1() {//ASI_CRM_CN_Contract_Controller
        ASI_TH_CRM_Contract__c ContractInserted=  CreateSimpleContract();

        test.startTest();
        ApexPages.currentPage().getParameters().put('id', ContractInserted.id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);
        ASI_CRM_CN_Contract_Controller con = new ASI_CRM_CN_Contract_Controller(stdController);
        //ASI_CRM_CN_Contract_Controller.withSharingInnerClass con2 = new ASI_CRM_CN_Contract_Controller.withSharingInnerClass ();
        con.getAllNationalGroup();
        con.changeBusinessLicense();
        con.Addall_CoveredOutlet();
        test.stopTest();
    }
























    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_1() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');


        createWholesalerAndOutlet();
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        //Laputa remove  ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //Laputa remove  con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        //Laputa remove  con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();*/
        //Laputa remove  con.changeBusinessLicense();
        //Laputa remove  con.UpdateContractDetailRecord();
        //Laputa remove  con.GoURL();
        //Laputa remove  con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());

        /*con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
                
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_2() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');

        createWholesalerAndOutlet();
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }

        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;
        test.startTest();
        //20160920
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpSPList1 = new List<ASI_CRM_SpecialPromotionTypeSetting__c>();

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'Contract ON'
            , ASI_CRM_New_FY_Promotion_Type__c = TRUE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList2 = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract ON'
            , ASI_CRM_New_FY_Promotion_Type__c = FALSE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        tmpSPList1.add(tmpSPList);
        tmpSPList1.add(tmpSPList2);

        insert tmpSPList1;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        //test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/

        con.ContractOutletListCopy = NULL;
        con.showReturn = FALSE;
        con.Selected = FALSE;
        con.BRSF_Item = NULL;
        con.recordtypeSelected = NULL;
        con.CoveredOutlet_Item = NULL;
        con.SelectOption = NULL;
        con.num = NULL;
        con.SChildCustomersIds = NULL;
        con.isNewFY = TRUE;
        con.DefaultBCRate = NULL;
        con.showSuggestedAmountAndTargetVolume = TRUE;
        con.showCN = TRUE;

        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
        //        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        //20160920
        con.isNewFY = FALSE;
        con.CheckSpecialPromotionType();
        ASI_CRM_CN_Contract_Controller.findCitySObjects('ASI_CRM_City__c');
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_3() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');

        createWholesalerAndOutlet();
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        // list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')
                , ASI_CRM_CN_Outlet__c = a2s[1].id
                , ASI_CRM_CN_Selected_Covered_Outlet__c = TRUE
            ));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());       
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        
        */
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'));

        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        con.changeContractUpload();

        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();

        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');

        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_4() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');


        createWholesalerAndOutlet();
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Draft'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Last_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        //insert ctis;
        insert prs;
        //insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        test.startTest();

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));

        ASI_CRM_CN_Contract_Controller con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        con.restorePO();
        con.CheckSpecialPromotionType();
        con.GoReturn();
        con.calcBRSF_EstTotal();
        con.calcBRSF_ContractTotal();
        con.Addall_CoveredOutlet();

        test.stopTest();
    }
    //-----------------------------------------------------------------------------
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_5() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');


        createWholesalerAndOutlet();
        List<ASI_CRM_AccountsAdditionalField__c> a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Final'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }

        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=cts[1].Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')
            , ASI_CRM_CN_Outlet__c = a2s[2].id
            , ASI_CRM_CN_Selected_Covered_Outlet__c = TRUE
        ));

        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract ON'
        );

        insert tmpSPList;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        //        con.submitApproval();
        //        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        cos[2].ASI_CRM_CN_Selected_Covered_Outlet__c = FALSE;
        con.UpdateContractDetailRecord();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
    //-----------------------------------------------------------------------------

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_6() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');


        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Chi_Name__c = 'd',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'h',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Archived'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Archived'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract ON'
        );

        insert tmpSPList;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        //        con.submitApproval();
        //        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_7() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');


        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON', ASI_CRM_For_Outlet__c = TRUE, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c = channel.id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Chi_Name__c = 'e',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'h',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Submitted'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Submitted'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        //20160920
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpSPList1 = new List<ASI_CRM_SpecialPromotionTypeSetting__c>();

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'Contract ON'
            , ASI_CRM_New_FY_Promotion_Type__c = TRUE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList2 = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract ON'
            , ASI_CRM_New_FY_Promotion_Type__c = FALSE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        tmpSPList1.add(tmpSPList);
        tmpSPList1.add(tmpSPList2);

        insert tmpSPList1;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        //test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/

        //20160920 Ben @ Elufa
        con.ContractOutletListCopy = NULL;
        con.showReturn = FALSE;
        con.Selected = FALSE;
        con.BRSF_Item = NULL;
        con.recordtypeSelected = NULL;
        con.CoveredOutlet_Item = NULL;
        con.SelectOption = NULL;
        con.num = NULL;
        con.SChildCustomersIds = NULL;
        con.isNewFY = TRUE;
        con.DefaultBCRate = NULL;
        con.showSuggestedAmountAndTargetVolume = TRUE;
        con.showCN = TRUE;

        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
        //        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        //20160920
        con.isNewFY = FALSE;
        con.CheckSpecialPromotionType();
        ASI_CRM_CN_Contract_Controller.findCitySObjects('ASI_CRM_City__c');
        con.ContractSelected.ASI_CRM_CN_Outlet_WS__c = a2s[0].id;
        con.setCustomerChannel();
        con.ContractSelected.ASI_CRM_CN_Outlet_WS__c = a2s[1].id;
        con.setCustomerChannel();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void dateToStringTest(){
        System.assertEquals('2018-01-01', ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(Date.newInstance(2018,1,1), 'yyyy-MM-dd'));
    }

    static testMethod void smallFunctionTest(){
        ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(null);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(Date.newInstance(2018,1,1));
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(null, null, null);
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(0, Date.newInstance(2018,1,1), Date.newInstance(2018,1,1));
        ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(10, Date.newInstance(2018,1,1), Date.newInstance(2018,1,1));
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(null);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(1);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(10);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);
        ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(100);

    }


}