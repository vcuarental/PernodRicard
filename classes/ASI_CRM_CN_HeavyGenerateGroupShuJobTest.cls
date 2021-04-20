/**
 * @File Name          : ASI_CRM_CN_HeavyGenerateGroupShuJobTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/19/2020, 10:08:45 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/18/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_CN_HeavyGenerateGroupShuJobTest {
    static testMethod void ASI_CRM_CN_HeavyGenerateGroupShuJobTest1() {
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='grades CN Name Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='grades CN Name Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='grades CN Name Test3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        
        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') );
        insert KAAccount;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        List<ASI_TH_CRM_Contract__c> GroupContractList = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c GroupContract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                           ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                           ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),
                                                                           Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                           ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract0);
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract);
        insert GroupContractList;
        
        
        
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList;
        
        
        
        
        
        
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
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        //contract cost Line 
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
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
        // ASI_CRM_CN_HeavyGenerateGroupShuttleJob acchg = new ASI_CRM_CN_HeavyGenerateGroupShuttleJob();
        // acchg.msg = '';
        // acchg.ContractId = GroupContractList[0].Id;
        // acchg.PreviousContractId = '';
        // acchg.SubmitApproval = true;
        // acchg.is2ndFunction = true;
        String BatchId = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[0].Id,'',false,true),1);
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_HeavyGenerateGroupShuJobTest5() {
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='grades CN Name Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='grades CN Name Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='grades CN Name Test3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        
        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') );
        insert KAAccount;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        List<ASI_TH_CRM_Contract__c> GroupContractList = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c GroupContract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                           ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                           ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),
                                                                           Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                           ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract0);
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract);
        insert GroupContractList;
        
        
        
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList;
        
        
        
        
        
        
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
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        //contract cost Line 
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
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
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_TH_CRM_Contract__c ContractTest = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-3),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-1).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal',
                                                                     ASI_CRM_CN_V0_0_PO_version__c = Contract0.Id,
                                                                     ASI_CRM_CN_Last_PO_version__c = Contract0.Id);
        Insert ContractTest;
        // ASI_CRM_CN_HeavyGenerateGroupShuttleJob acchg = new ASI_CRM_CN_HeavyGenerateGroupShuttleJob();
        // acchg.msg = '';
        // acchg.ContractId = GroupContractList[0].Id;
        // acchg.PreviousContractId = '';
        // acchg.SubmitApproval = true;
        // acchg.is2ndFunction = true;
        String BatchId = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[0].Id,'',false,true),1);
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_HeavyGenerateGroupShuJobTest6() {
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='grades CN Name Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='grades CN Name Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='grades CN Name Test3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        
        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') );
        insert KAAccount;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        List<ASI_TH_CRM_Contract__c> GroupContractList = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c GroupContract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                           ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                           ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),
                                                                           Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                           ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract0);
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract);
        insert GroupContractList;
        
        
        
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList;
        
        
        
        
        
        
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
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        //contract cost Line 
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
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
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_TH_CRM_Contract__c ContractTest = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-3),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-1).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal',
                                                                     ASI_CRM_CN_V0_0_PO_version__c = Contract0.Id,
                                                                     ASI_CRM_CN_Last_PO_version__c = Contract0.Id);
        Insert ContractTest;
        // ASI_CRM_CN_HeavyGenerateGroupShuttleJob acchg = new ASI_CRM_CN_HeavyGenerateGroupShuttleJob();
        // acchg.msg = '';
        // acchg.ContractId = GroupContractList[0].Id;
        // acchg.PreviousContractId = '';
        // acchg.SubmitApproval = true;
        // acchg.is2ndFunction = true;
        String BatchId = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[0].Id,'',false,true),1);
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_HeavyGenerateGroupShuJobTest2() {
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='grades CN Name Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='grades CN Name Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='grades CN Name Test3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        
        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') );
        insert KAAccount;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        List<ASI_TH_CRM_Contract__c> GroupContractList = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c GroupContract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                           ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                           ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),
                                                                           Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                           ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,
                                                                           ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
                                                                           ASI_CRM_CN_Status__c='Draft');
        GroupContractList.add(GroupContract0);
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract);
        insert GroupContractList;
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList; 


        
        
        
        
        
        
        
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
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        //contract cost Line 
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
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

        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractList[1].Id,ASI_CRM_Type__c='Group Contract',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""},{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractList[1].Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37,"ROIActual":3.37,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{},"ContractId":"aBt3N000000CahySAC","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""},{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37405803901500866574965612104539,"ROIActual":3.37405803901500866574965612104539,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{"00001皇家礼炮62响 Royal Salute 62 Gun Salute-ROI":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮62响 Royal Salute 62 Gun Salute-ROI","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":300,"EstimateTotalFees":12000.00,"EstimateFees":40.00,"EstimateBottles":100,"ContractVolume":300,"ContractTotalFees":12000.00,"ContractFees":40.00,"ContractBottles":100},"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":48000.00,"EstimateFees":40.00,"EstimateBottles":400,"ContractVolume":1200,"ContractTotalFees":48000.00,"ContractFees":40.00,"ContractBottles":400},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":600,"EstimateTotalFees":54000.00,"EstimateFees":90.00,"EstimateBottles":200,"ContractVolume":600,"ContractTotalFees":54000.00,"ContractFees":90.00,"ContractBottles":200},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"干邑","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":900,"EstimateTotalFees":90000.00,"EstimateFees":100.00,"EstimateBottles":300,"ContractVolume":900,"ContractTotalFees":90000.00,"ContractFees":100.00,"ContractBottles":300}},"ContractId":"","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 
        
        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=GroupContractList[0].Id,ASI_CRM_Type__c='Group Contract',ASI_CRM_For_Contract_Use__c=true,ownerid=currentUser.id);    
        Attachment3.ASI_CRM_Comments__c=GroupContractList[0].Id;
        AttachmentList.add(Attachment3); 
        insert AttachmentList;

        test.startTest();
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_TH_CRM_Contract__c ContractTest = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-3),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-1).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal',
                                                                     ASI_CRM_CN_V0_0_PO_version__c = Contract.Id,
                                                                     ASI_CRM_CN_Last_PO_version__c = Contract.Id);
        Insert ContractTest;
        // ASI_CRM_CN_HeavyGenerateGroupShuttleJob acchg = new ASI_CRM_CN_HeavyGenerateGroupShuttleJob();
        // acchg.msg = '';
        // acchg.ContractId = GroupContractList[0].Id;
        // acchg.PreviousContractId = '';
        // acchg.SubmitApproval = true;
        // acchg.is2ndFunction = true; 
        String BatchId = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[1].Id,'',false,false),1);
        // String BatchId2 = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[1].Id,GroupContractList[0].Id,false,false),1);
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_HeavyGenerateGroupShuJobTest4() {
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='grades CN Name Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='grades CN Name Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='grades CN Name Test3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        
        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') );
        insert KAAccount;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        List<ASI_TH_CRM_Contract__c> GroupContractList = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c GroupContract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                           ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                           ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),
                                                                           Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                           ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,
                                                                           ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
                                                                           ASI_CRM_CN_Status__c='Draft');
        GroupContractList.add(GroupContract0);
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract);
        insert GroupContractList;
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList; 


        
        
        
        
        
        
        
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
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        //contract cost Line 
        
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
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
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

        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractList[1].Id,ASI_CRM_Type__c='Group Contract',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""},{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractList[1].Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37,"ROIActual":3.37,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{},"ContractId":"aBt3N000000CahySAC","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""},{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37405803901500866574965612104539,"ROIActual":3.37405803901500866574965612104539,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{"00001皇家礼炮62响 Royal Salute 62 Gun Salute-ROI":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮62响 Royal Salute 62 Gun Salute-ROI","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":300,"EstimateTotalFees":12000.00,"EstimateFees":40.00,"EstimateBottles":100,"ContractVolume":300,"ContractTotalFees":12000.00,"ContractFees":40.00,"ContractBottles":100},"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":48000.00,"EstimateFees":40.00,"EstimateBottles":400,"ContractVolume":1200,"ContractTotalFees":48000.00,"ContractFees":40.00,"ContractBottles":400},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":600,"EstimateTotalFees":54000.00,"EstimateFees":90.00,"EstimateBottles":200,"ContractVolume":600,"ContractTotalFees":54000.00,"ContractFees":90.00,"ContractBottles":200},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"干邑","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":900,"EstimateTotalFees":90000.00,"EstimateFees":100.00,"EstimateBottles":300,"ContractVolume":900,"ContractTotalFees":90000.00,"ContractFees":100.00,"ContractBottles":300}},"ContractId":"","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 
        
        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=GroupContractList[0].Id,ASI_CRM_Type__c='Group Contract',ASI_CRM_For_Contract_Use__c=true,ownerid=currentUser.id);    
        Attachment3.ASI_CRM_Comments__c=GroupContractList[0].Id;
        AttachmentList.add(Attachment3); 
        insert AttachmentList;

        test.startTest();
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;
        ASI_TH_CRM_Contract__c ContractTest = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-3),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-1).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal',
                                                                     ASI_CRM_CN_V0_0_PO_version__c = Contract0.Id,
                                                                     ASI_CRM_CN_Last_PO_version__c = Contract0.Id);
        Insert ContractTest;
        // ASI_CRM_CN_HeavyGenerateGroupShuttleJob acchg = new ASI_CRM_CN_HeavyGenerateGroupShuttleJob();
        // acchg.msg = '';
        // acchg.ContractId = GroupContractList[0].Id;
        // acchg.PreviousContractId = '';
        // acchg.SubmitApproval = true;
        // acchg.is2ndFunction = true; 
        String BatchId = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[0].Id,'',false,false),1);
        // String BatchId2 = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[1].Id,GroupContractList[0].Id,false,false),1);
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_HeavyGenerateGroupShuJobTest3() {
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
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
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
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='grades CN Name Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',ASI_CRM_Chinese_Name__c='grades CN Name Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',ASI_CRM_Chinese_Name__c='grades CN Name Test3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
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
        
        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group') );
        insert KAAccount;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        List<ASI_TH_CRM_Contract__c> GroupContractList = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c GroupContract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                           ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                           ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),
                                                                           Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                           ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,
                                                                           ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
                                                                           ASI_CRM_CN_Status__c='Draft');
        GroupContractList.add(GroupContract0);
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,ASI_CRM_Last_RBA_Approver__c= currentUser.Id,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        GroupContractList.add(GroupContract);
        insert GroupContractList;
        
        
        
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        // ASI_TH_CRM_Contract__c Contract0 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
        //                                                               ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract0.Id,
        //                                                               ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-5),
        //                                                               ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-3).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
        //                                                               ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
        //                                                               Name = 'Contract1',
        //                                                               ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        // ContractList.add(Contract0);
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Archived',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        insert ContractList; 

        
        
        
        
        
        
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
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        //contract cost Line 
        
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
            // ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract0.Id,
            //                                                                ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
            //                                                                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            //                                                                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
            //                                                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
            //                                                                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
            //                                                                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            
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
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractList[0].Id,ASI_CRM_Type__c='Group Contract',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""},{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractList[0].Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37,"ROIActual":3.37,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{},"ContractId":"aBt3N000000CahySAC","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""},{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37405803901500866574965612104539,"ROIActual":3.37405803901500866574965612104539,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{"00001皇家礼炮62响 Royal Salute 62 Gun Salute-ROI":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮62响 Royal Salute 62 Gun Salute-ROI","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":300,"EstimateTotalFees":12000.00,"EstimateFees":40.00,"EstimateBottles":100,"ContractVolume":300,"ContractTotalFees":12000.00,"ContractFees":40.00,"ContractBottles":100},"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":48000.00,"EstimateFees":40.00,"EstimateBottles":400,"ContractVolume":1200,"ContractTotalFees":48000.00,"ContractFees":40.00,"ContractBottles":400},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":600,"EstimateTotalFees":54000.00,"EstimateFees":90.00,"EstimateBottles":200,"ContractVolume":600,"ContractTotalFees":54000.00,"ContractFees":90.00,"ContractBottles":200},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"干邑","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":900,"EstimateTotalFees":90000.00,"EstimateFees":100.00,"EstimateBottles":300,"ContractVolume":900,"ContractTotalFees":90000.00,"ContractFees":100.00,"ContractBottles":300}},"ContractId":"","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 
        
        insert AttachmentList;
        test.startTest();
        
        currentUser = [SELECT id, name,Email, Managerid, ASI_CRM_CN_Prefix__c,BypassTriggers__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        currentUser.Email= 'test@test.com';
        update currentUser;

        ASI_TH_CRM_Contract__c ContractTest = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addMonths(-3),
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addMonths(-1).toStartOfMonth().addDays(-1),ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal',
                                                                     ASI_CRM_CN_V0_0_PO_version__c = Contract.Id,
                                                                     ASI_CRM_CN_Last_PO_version__c = Contract.Id);
        Insert ContractTest;
        // ASI_CRM_CN_HeavyGenerateGroupShuttleJob acchg = new ASI_CRM_CN_HeavyGenerateGroupShuttleJob();
        // acchg.msg = '';
        // acchg.ContractId = GroupContractList[0].Id;
        // acchg.PreviousContractId = '';
        // acchg.SubmitApproval = true;
        // acchg.is2ndFunction = true; 
        // String BatchId = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[0].Id,'',false,false),1);
        String BatchId2 = Database.executeBatch(new ASI_CRM_CN_HeavyGenerateGroupShuttleJob(GroupContractList[1].Id,GroupContractList[0].Id,false,false),1);
        //System.abortJob(BatchId2);
        test.stopTest();
    }
}