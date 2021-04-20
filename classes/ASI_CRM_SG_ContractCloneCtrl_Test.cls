/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneCtrl_Test
 * Created : DC @12/30/2015 3:54 PM
 * 
 * Revision History:
 * 1.   2018-02-28		Wilken Lee		[WL 1.0] Add Business Registration Number to outlet test data
 **********************************************************************************/
@isTest
public class ASI_CRM_SG_ContractCloneCtrl_Test{
    private static User sgStandardUser;
    private static List<ASI_TH_CRM_Actual_Offtake__c> offtakes = new List<ASI_TH_CRM_Actual_Offtake__c>();
    private static List<ASI_MFM_SKU_Code__c> skus = new List<ASI_MFM_SKU_Code__c>();
    private static List<ASI_TH_CRM_Contract__c> contracts = new List<ASI_TH_CRM_Contract__c>();
    private static List<ASI_CRM_AccountsAdditionalField__c> customers = new List<ASI_CRM_AccountsAdditionalField__c>();
    private static List<ASI_CRM_AccountsAdditionalField__c> customersChild = new List<ASI_CRM_AccountsAdditionalField__c>();
    private static List<ASI_CRM_SG_Wine_Category__c> wineCategories = new List<ASI_CRM_SG_Wine_Category__c>();
    private static List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = new List<ASI_CRM_MY_SKUPriceCost__c>();
    private static List<ASI_TH_CRM_Category__c> categoryList = new List<ASI_TH_CRM_Category__c>();
    private static List<ASI_TH_CRM_Sub_category__c> subCategories = new List<ASI_TH_CRM_Sub_category__c>();
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    private static Map<String,Map<Id,Schema.RecordTypeInfo>> recordTypesById = new Map<String,Map<Id,Schema.RecordTypeInfo>>();
    private static List<ASI_CRM_Wine_Spirits__c> wineSpiritsList = new List<ASI_CRM_Wine_Spirits__c>();
    private static List<ASI_MFM_Brand__c> brandList = new List<ASI_MFM_Brand__c>();
    private static list<ASI_MFM_Sub_brand__c> subBrandList = new list<ASI_MFM_Sub_brand__c>();
    private static  List<ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeList = new List<ASI_CRM_Sub_Brand_Grade__c>();
    private static List<ASI_CRM_Sub_Brand_Group__c> subBrandGroupList = new List<ASI_CRM_Sub_Brand_Group__c>();
    private static List<ASI_HK_CRM_Product_Category__c> productCategoryList = new List<ASI_HK_CRM_Product_Category__c>();
    private static List<ASI_CRM_CN_Brand_Group__c> brandGroupList = new List<ASI_CRM_CN_Brand_Group__c>();
    private static List<ASI_CRM_Group_Outlet_Type__c> groupOutLetTypes = new List<ASI_CRM_Group_Outlet_Type__c>();
    private static ASI_CRM_Group_Outlet_Type__c groupOutletType = new ASI_CRM_Group_Outlet_Type__c();
    private static ASI_CRM_Image_Level__c imageLevel = new ASI_CRM_Image_Level__c();
    private static ASI_CRM_Outlet_Type__c outletType = new ASI_CRM_Outlet_Type__c();

    private static void createWineCategories(Integer recordSize){
        for(Integer i=0; i<recordSize; i++){
            ASI_CRM_SG_Wine_Category__c wine = new ASI_CRM_SG_Wine_Category__c(name='category'+i);
            wineCategories.add(wine);
        }
        insert wineCategories;
    }

    static void createSKU(String name,String skuCode, String devname, Integer bottleSize, Integer packSize, Integer availableQuantity,String UOM,Boolean isActive, Id subBrandId, Id wineCatId){

        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c (
                                                                name=name,
                                                                ASI_MFM_SKU_Code__c = skuCode,
                                                                recordtypeid = Global_RecordTypeCache.getRTId(devname),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = bottleSize,
                                                                ASI_HK_CRM_Packaging_Size__c = packSize,
                                                                ASI_HK_CRM_Available_Quantity__c = availableQuantity,
                                                                ASI_HK_CRM_UOM1__c = UOM,
                                                                ASI_HK_CRM_Active__c = isActive,
                                                                ASI_MFM_Sub_brand__c = subBrandId,
                                                                ASI_CRM_SG_Wine_Category__c = wineCatId
                                                            );    
        skus.add(sku);
    }

    static void createPriceCost(String devname,Integer cost, Integer price,Id skuId){
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost = new ASI_CRM_MY_SKUPriceCost__c    (
                                                                                        ASI_CRM_EffectiveDate__c = date.today(),
                                                                                        recordtypeid = Global_RecordTypeCache.getRTId(devname),
                                                                                        ASI_CRM_Cost__c = cost,
                                                                                        ASI_CRM_Price__c = price,
                                                                                        ASI_CRM_SKU__c = skuId
                                                                                    );
        skuPriceCosts.add(skuPriceCost);
    }

    //CREATE Wine/Spirits
    public static void createWineSpirits(integer numberofWineSpirits, String recordTypeDeveloperName){
        
        Id recordtypeId = getRecordTypeId('ASI_CRM_Wine_Spirits__c', recordTypeDeveloperName);
        
        for(integer i = 0;i < numberofWineSpirits;i++){
            ASI_CRM_Wine_Spirits__c wineSpirit = new ASI_CRM_Wine_Spirits__c();
            wineSpirit.RecordTypeId = recordtypeId;
            wineSpirit.ASI_CRM_SG_Wine_Spirits_Code__c = 'Test'+i;
            wineSpiritsList.add(wineSpirit);
        }
        insert wineSpiritsList;
    }

    //CREATE Brand
    public static void createBrand(integer numberofBrand, String recordTypeDeveloperName, String brandName, Id groupId, Id productCategoryId,Id subCategoryId){
        
        Id recordtypeId = getRecordTypeId('ASI_MFM_Brand__c', recordTypeDeveloperName);
        for(integer i = 0;i < numberofBrand;i++){
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c();
            brand.RecordTypeId = recordtypeId;
            brand.Name = brandName;
            brand.ASI_CRM_CN_Brand_Group_c__c= groupId;
            brand.ASI_HK_CRM_Product_Category__c = productCategoryId;
            brand.ASI_TH_CRM_Sub_category__c = subCategoryId;
            brandList.add(brand);
        }
        insert brandList;
    }

    // Create Sub Brand 
    //CREATE Brand
    public static void createSubBrand(Integer numberofBrand, String recordTypeDeveloperName, String SubbrandName, Id brandId, Integer factor, Id gradeId, Id groupId){
        
        Id recordtypeId = getRecordTypeId('ASI_MFM_Sub_brand__c', recordTypeDeveloperName);
        for(integer i = 0;i < numberofBrand;i++){
            ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c();
            subBrandList.add(new ASI_MFM_Sub_brand__c (
                    Name=SubbrandName,
                    ASI_MFM_Brand__c=brandId,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=factor,
                    ASI_CRM_CN_Sub_brand_Grade__c=gradeId,
                    ASI_CRM_CN_SubBrand_Group_c__c=groupId,
                    RecordTypeId = recordtypeId));
        }
        insert subBrandList;
    }

    //CREATE SubBrand Grades
    public static void createSubBrandGrades(integer numberofBrand,String brandName){
        
        for(integer i = 0;i < numberofBrand;i++){
            ASI_CRM_Sub_Brand_Grade__c subBrandGrade = new ASI_CRM_Sub_Brand_Grade__c();
            subBrandGrade.Name = brandName+i;
            SubBrandGradeList.add(subBrandGrade);
        }
        insert SubBrandGradeList;
    }

    //CREATE Brand Groups
    public static void createBrandGroups(integer numberofBrand,String brandName){
        
        for(integer i = 0;i < numberofBrand;i++){
            ASI_CRM_CN_Brand_Group__c brandGroup = new ASI_CRM_CN_Brand_Group__c();
            brandGroup.Name = brandName+i;
            brandGroupList.add(brandGroup);
        }
        insert brandGroupList;
    }

    //CREATE SubBrand Groups
    public static void createSubBrandGroups(integer numberofBrand,String brandName){
        for(integer i = 0;i < numberofBrand;i++){
            ASI_CRM_Sub_Brand_Group__c subBrandGroup = new ASI_CRM_Sub_Brand_Group__c();
            subBrandGroup.Name = brandName+i;
            subBrandGroupList.add(subBrandGroup);
        }
        insert subBrandGroupList;
    }
 
    //CREATE Product Category
    public static void createProductCategory(integer numberofCategory, String recordTypeDeveloperName, Id wineSpirit,String extId){
        
        Id recordtypeId = getRecordTypeId('ASI_HK_CRM_Product_Category__c', recordTypeDeveloperName);
        for(integer i = 0;i < numberofCategory;i++){
            ASI_HK_CRM_Product_Category__c category = new ASI_HK_CRM_Product_Category__c();
            category.RecordTypeId = recordtypeId;
            category.ASI_CRM_SG_Wine_Spirits__c = wineSpirit;
            category.ASI_HK_CRM_Product_Category__c=extId+i;
            productCategoryList.add(category);
        }
        insert productCategoryList;
    }
    
    //CREATE SubCategory
    public static void createSubCategory(integer numberofCategory,Id categoryId, Id productCategoryId, String externalId){
        
        for(integer i = 0;i < numberofCategory;i++){
            ASI_TH_CRM_Sub_category__c subCategory = new ASI_TH_CRM_Sub_category__c();
            subCategory.ASI_TH_CRM_Category__c = categoryId;
            subCategory.ASI_CRM_CN_Product_Category__c = productCategoryId;
            subCategory.ASI_TH_CRM_Sub_category_EXID__c = externalId+i;
            subCategories.add(subCategory);
        }
        insert subCategories;
    }
    
    //CREATE Category
    public static void createCategory(integer numberofCategory, String externalId){
        
        for(integer i = 0;i < numberofCategory;i++){
            ASI_TH_CRM_Category__c category = new ASI_TH_CRM_Category__c();
            category.ASI_TH_CRM_Category_External_ID__c = externalId+i;
            categoryList.add(category);
        }
        insert categoryList;
    }
    
    public static ASI_TH_CRM_Contract__c contract {get;set;}
    
    public static void contractData(boolean isCommit) { 
        contract = new ASI_TH_CRM_Contract__c (
                                                  name='test',
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract'),
                                                  ASI_CRM_CN_Outlet_WS__c = customer.id,
                                                  ASI_TH_CRM_Contract_Status__c = 'Draft',
                                                  ASI_TH_CRM_Start_Date__c = date.today().adddays(-1),
                                                  ASI_TH_CRM_End_Date__c = date.today().adddays(7)
                                              );
        
        if(isCommit) {                                      
            insert contract;
        }
    }
    
    public static ASI_CRM_Contract_Outlets__c contractOutlet {get;set;}
    public static List<ASI_CRM_Contract_Outlets__c> contractOutlets {get;set;}
    
    public static void contractOutletData(boolean isCommit) { 
        customersChild = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c customerTemp1 = new ASI_CRM_AccountsAdditionalField__c (
                                                                name = 'customer Test Child 1',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                ASI_CRM_IsParentAccount__c = false,
                                                                ASI_CRM_MY_CustomerCode__c = '123testchild1',
                                                                ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id,
                                                                ASI_CRM_SG_Image_Level__c  = imageLevel.id,
                                                                ASI_CRM_CN_Parent_Outlet__c = customer.id,
                                                                ASI_CRM_Business_Registration_Number__c = '012345678'
                                                          );
        customersChild.add(customerTemp1);

        ASI_CRM_AccountsAdditionalField__c customerTemp2 = new ASI_CRM_AccountsAdditionalField__c (
                                                                name = 'customer Test Child 2',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                ASI_CRM_IsParentAccount__c = false,
                                                                ASI_CRM_MY_CustomerCode__c = '123testchild2',
                                                                ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id,
                                                                ASI_CRM_SG_Image_Level__c  = imageLevel.id,
                                                                ASI_CRM_CN_Parent_Outlet__c = customer.id,
                                                                ASI_CRM_Business_Registration_Number__c = '123456789'
                                                          );
        customersChild.add(customerTemp2);
        
        if(isCommit) {                                      
            insert customersChild;
        }
        
        contractOutlets = new List<ASI_CRM_Contract_Outlets__c>();
        ASI_CRM_Contract_Outlets__c contractOutletTemp1 = new ASI_CRM_Contract_Outlets__c (
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet'),
                                                  ASI_CRM_SG_Customer__c = customersChild.get(0).id,
                                                  ASI_CRM_SG_Contract__c = contract.id
                                              );
        contractOutlets.add(contractOutletTemp1);
        
        ASI_CRM_Contract_Outlets__c contractOutletTemp2 = new ASI_CRM_Contract_Outlets__c (
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet'),
                                                  ASI_CRM_SG_Customer__c = customersChild.get(1).id,
                                                  ASI_CRM_SG_Contract__c = contract.id
                                              );
        contractOutlets.add(contractOutletTemp2);
        
        if(isCommit) {                                      
            insert contractOutlets;
        }
    }

    
    public static ASI_CRM_Payment_Schedule__c paymentSchedule {get;set;}
    public static List<ASI_CRM_Payment_Schedule__c> paymentSchedules {get;set;}
    
    public static void paymentScheduleData(boolean isCommit) { 
        
        paymentSchedules = new List<ASI_CRM_Payment_Schedule__c>();
        ASI_CRM_Payment_Schedule__c paymentSchedule1 = new ASI_CRM_Payment_Schedule__c (
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'),
                                                  ASI_CRM_Percentof_achieved_Sales_Target__c = '0',
                                                    ASI_CRM_Sponsorship__c = 100,
                                                    ASI_CRM_Type__c = 'Cash Sponsorship',
                                                  ASI_CRM_Contract__c = contract.id
                                              );
        paymentSchedules.add(paymentSchedule1);
        
        ASI_CRM_Payment_Schedule__c paymentSchedule2 = new ASI_CRM_Payment_Schedule__c (
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'),
                                                  ASI_CRM_Percentof_achieved_Sales_Target__c = '50',
                                                    ASI_CRM_Sponsorship__c = 500,
                                                    ASI_CRM_Type__c = 'Cash Sponsorship',
                                                  ASI_CRM_Contract__c = contract.id
                                              );
        paymentSchedules.add(paymentSchedule2);
        
        ASI_CRM_Payment_Schedule__c paymentSchedule3 = new ASI_CRM_Payment_Schedule__c (
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'),
                                                  ASI_CRM_Percentof_achieved_Sales_Target__c = '100',
                                                    ASI_CRM_Sponsorship__c = 1000,
                                                    ASI_CRM_Type__c = 'Cash Sponsorship',
                                                  ASI_CRM_Contract__c = contract.id
                                              );
        paymentSchedules.add(paymentSchedule3);
        
        if(isCommit) {                                      
            insert paymentSchedules;
        }
    }
    
    public static ASI_CRM_SG_AdhocOther__c ASI_CRM_SG_AdhocOther {get;set;}
    public static List<ASI_CRM_SG_AdhocOther__c> ASI_CRM_SG_AdhocOthers {get;set;}
    
    public static void ASI_CRM_SG_AdhocOtherData(boolean isCommit) { 
        
        ASI_CRM_SG_AdhocOthers = new List<ASI_CRM_SG_AdhocOther__c>();
        ASI_CRM_SG_AdhocOther__c ASI_CRM_SG_AdhocOther1 = new ASI_CRM_SG_AdhocOther__c (
                                                  Name = 'ASI_CRM_SG_AdhocOther1',
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_SG_AdhocOther__cASI_CRM_SG_AdHocOther'),
                                                  ASI_CRM_SG_Contract_Target__c = contractTargets.get(0).id,
                                                    ASI_CRM_SG_Amount__c = 100,
                                                    ASI_CRM_SG_SKU__c = skus[1].Id
                                              );
        ASI_CRM_SG_AdhocOthers.add(ASI_CRM_SG_AdhocOther1);
        
        if(isCommit) {                                      
            insert ASI_CRM_SG_AdhocOthers;
        }
    }
    
    public static ASI_CRM_AccountsAdditionalField__c customer {get;set;}
    public static ASI_CRM_AccountsAdditionalField__c wholeSaler {get;set;}
    public static void customerData(boolean isCommit) {
        customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                name = 'customer Test',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                ASI_CRM_IsParentAccount__c = true,
                                                                ASI_CRM_MY_CustomerCode__c = '123test',
                                                                ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id,
                                                                ASI_CRM_SG_Image_Level__c  = imageLevel.id,
																/*[WL 1.0] BEGIN*/
                                                                ASI_CRM_Business_Registration_Number__c = String.ValueOf(DateTime.now().millisecond()) + '123456'
																/*[WL 1.0] END*/
                                                          );
        
        if(isCommit) {                               
            insert customer;
        }
    }
    
    public static void WhoSalerData(boolean isCommit) {
            wholeSaler = new ASI_CRM_AccountsAdditionalField__c (
                                                                name = 'customer Test',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Wholesaler'),
                                                                ASI_CRM_IsParentAccount__c = true,
                                                                ASI_CRM_MY_CustomerCode__c = '123test'
                                                                //ASI_CRM_Business_Registration_Number__c = '345678901'
                                                          );
        
        if(isCommit) {                               
            insert wholeSaler;
        }
    }
    
    public static ASI_CRM_ContractTarget__c contractTarget {get;set;}
    public static List<ASI_CRM_ContractTarget__c> contractTargets {get;set;}
        
    public static void contractTargetData(boolean isCommit, ASI_TH_CRM_Contract__c c, Id skuId,Id subBrandId,Integer si) {
        
        contractTarget = new ASI_CRM_ContractTarget__c (
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                                  ASI_CRM_Contract__c = c.id,
                                                  ASI_CRM_SKU__c = skuId,
                                                  ASI_CRM_SG_FOC_Calculation__c = '--None--',
                                                  ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 10,
                                                  ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
                                                  ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
                                                  ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
                                                  ASI_CRM_SG_Btls_Per_Case__c = 3,
                                                  ASI_CRM_SG_Size_cl__c = 4,
                                                  ASI_CRM_Subbrand__c = subBrandId,
                                                  ASI_CRM_SG_Sales_Incentive__c = si
                                              );
        
        contractTargets = new List<ASI_CRM_ContractTarget__c>();
        contractTargets.add(contractTarget);
        
        if(isCommit) {                                      
            insert contractTargets;
        }
    }
        
    public static void createOfftakes(){
        ASI_TH_CRM_Actual_Offtake__c offs = new ASI_TH_CRM_Actual_Offtake__c();
        offs.ASI_CRM_Latest_Vintage__c=skus[1].Id;
        offs.ASI_TH_CRM_Sub_brand__c = subBrandList[0].Id;
        offs.ASI_CRM_SG_Customer__c = customer.Id;
        Date myDate = Date.newInstance(2015, 1, 1);
        offs.ASI_TH_CRM_Offtake_G_L_Date__c = myDate;
        offs.ASI_CRM_FromWS__c = wholeSaler.Id;
        offs.ASI_CRM_SKU__c = skus[1].Id;
        offs.ASI_TH_CRM_Quantity__c = 24;
        offs.ASI_CRM_Contract__c = contract.Id;
        offtakes.add(offs);

        ASI_TH_CRM_Actual_Offtake__c offs2 = new ASI_TH_CRM_Actual_Offtake__c();
        offs2.ASI_CRM_Latest_Vintage__c=skus[1].Id;
        offs2.ASI_TH_CRM_Sub_brand__c = subBrandList[0].Id;
        offs2.ASI_CRM_SG_Customer__c = customer.Id;
        Date myDate2 = Date.newInstance(2015, 1, 1);
        offs2.ASI_TH_CRM_Offtake_G_L_Date__c = myDate2;
        offs2.ASI_CRM_FromWS__c = wholeSaler.Id;
        offs2.ASI_CRM_SKU__c = skus[1].Id;
        offs2.ASI_TH_CRM_Quantity__c = 24;
        offs2.ASI_CRM_Contract__c = contract.Id;
        offtakes.add(offs2);

        insert offtakes;
    }

    @TestSetup
    public static void initData() {
    }
    
    static void createTestData(){
        // create Wine Categories
        createWineCategories(5);
        createSubBrandGrades(2,'test Sub Brand Grade');
        createSubBrandGroups(2,'test Sub Brand Groups');
        createWineSpirits(2,'ASI CRM SG Wine/Spirit');
        createCategory(2,'tstExtId');
        createProductCategory(1,'ASI SG CRM Product Category',wineSpiritsList[0].Id,'ExtId');
        createSubCategory(2,categoryList[0].Id,productCategoryList[0].Id,'extId');
        createBrandGroups(2,'test Brand Groups');
        createBrand(2, 'SG Brand', 'Test brand name', brandGroupList[0].Id, productCategoryList[0].Id,subCategories[0].Id);
        
        createSubBrand(5, 'GF Sub-brand', 'Test Sub Brand name', brandList[0].Id, 2, SubBrandGradeList[0].Id, subBrandGroupList[0].Id);
        // Create SKU's
        createSKU('Test Sku 1','test1','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',3,6,10,'UOM1',true,subBrandList.get(0).id,wineCategories[0].id);
        createSKU('Test Sku 2','test2','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',4,6,10,'UOM2',true,subBrandList.get(1).id,wineCategories[0].id);
        createSKU('Test Sku 3','test3','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',8,6,10,'UOM3',true,subBrandList.get(2).id,wineCategories[0].id);
        createSKU('Test Sku 4','test4','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',4,12,10,'UOM4',true,subBrandList.get(3).id,wineCategories[0].id);
        createSKU('Test Sku 5','test5','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',1,12,10,'UOM5',true,subBrandList.get(4).id,wineCategories[0].id);
        insert skus;

        // Create Price Costs
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC',40,50,skus.get(2).id);
        insert skuPriceCosts;
        
        customerData(true);
        //WhoSalerData(true);
        contractData(true);
        contractOutletData(true);
        paymentScheduleData(true);
        //createOfftakes();
        contractTargetData(true,contract,skus[1].Id,subBrandList[0].Id,3);
        contractTargetData(true,contract,skus[1].Id,subBrandList[0].Id,3);
        ASI_CRM_SG_AdhocOtherData(true);
    }

    
    static void createUser(String userId){
        Profile p = [SELECT Id FROM Profile WHERE Name='ASI SG Standard User'];
        
        sgStandardUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= userId + '@laputa.com');
            
        insert sgStandardUser;
    }

    static testMethod void test1(){
            test.startTest();
                createDataSettings();
                createTestData();
            
            
                PageReference pageRef = Page.ASI_CRM_SG_ContractClonePage;
            System.debug('##Contract id: '+contract.id);
               pageRef.getParameters().put('id',contract.id);
               pageRef.getParameters().put('copy', '1');
                Test.setCurrentPage(pageRef);
               ApexPages.StandardController sc = new ApexPages.standardController(contract);
               ASI_CRM_SG_ContractCloneController  controller = new ASI_CRM_SG_ContractCloneController(sc);
                //controller.headerId = ApexPages.currentPage().getParameters().get('id');
                //controller.checkCopy = Integer.valueOf(ApexPages.currentPage().getParameters().get('copy'));
               System.assertNotEquals(null,controller.cloneContracts());
        
                
            test.stopTest();
    }
    
    static testMethod void test0(){
            test.startTest();
                createDataSettings();
                createTestData();
            
            
                PageReference pageRef = Page.ASI_CRM_SG_ContractClonePage;
            System.debug('##Contract id: '+contract.id);
               pageRef.getParameters().put('id',contract.id);
               pageRef.getParameters().put('copy', '0');
                Test.setCurrentPage(pageRef);
               ApexPages.StandardController sc = new ApexPages.standardController(contract);
               ASI_CRM_SG_ContractCloneController  controller = new ASI_CRM_SG_ContractCloneController(sc);
                //controller.headerId = ApexPages.currentPage().getParameters().get('id');
                //controller.checkCopy = Integer.valueOf(ApexPages.currentPage().getParameters().get('copy'));
               System.assertNotEquals(null,controller.cloneContracts());
        
                
            test.stopTest();
    }
    
    public static Id getRecordTypeId(String objectName, String recordTypeName) {
    /*------------------------------------------------------------
    Description:   Gives record type id from a given sObject and record type label
    Inputs:        objectName - The sObject
                   recordTypeName - The name of the record type (NOT the API Name)
    Returns:       The specified record types id value
    ------------------------------------------------------------*/
        // make sure we have this object's record types mapped
        if (!recordTypesByName.containsKey(objectName)) 
            fillMapsForRecordTypeObject(objectName);

        // now grab and return the requested id 
        Map<String,Schema.RecordTypeInfo> rtMap = recordTypesByName.get(objectName);
        System.debug('##RTMAP: '+rtMap);
        Id rtId = null;
        if (rtMap != null && rtMap.containsKey(recordTypeName)) {
            return rtMap.get(recordTypeName).getRecordTypeId();
        } else {
            List<Recordtype> tempRecordTypes = Global_RecordTypeCache.getRtList(objectName);
            Map<String,Id> tempRecordTypesMap = new Map<String,Id>();
                
            for(Recordtype rt : tempRecordTypes ){
               if(rt.developername ==  recordTypeName){
                   rtId = rt.id;
                   break;
               }
            }
            return rtId;
        }
        
    }

    private static void fillMapsForRecordTypeObject(string objectName) {
    /*------------------------------------------------------------
    Description:   Function to fill record type map for objects not in cache
    Inputs:        objectName - The name of the sObject
    Returns:       Nothing
    ------------------------------------------------------------*/
        // get the object map the first time
        if (gd==null) gd = Schema.getGlobalDescribe();

        // get the object description
        if (gd.containsKey(objectName)) {
            Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
            recordTypesByName.put(objectName, d.getRecordTypeInfosByName());
            recordTypesById.put(objectName, d.getRecordTypeInfosById());
        }
    }

    public static void createDataSettings(){
    
        List<ASI_HK_CRM_Running_Number__c> runingNumberList = new List<ASI_HK_CRM_Running_Number__c>();
       
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(
                                                                ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Contract_No', 
                                                                ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2, 
                                                                ASI_HK_CRM_Format__c = 'PRS-{YY}-{0000}', 
                                                                ASI_HK_CRM_Running_Number__c = 2
                                                             ));
        
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(
                                                                ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Payment_Request_No', 
                                                                ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2, 
                                                                ASI_HK_CRM_Format__c = '{YY}{MM}{00000}', 
                                                                ASI_HK_CRM_Running_Number__c = 2
                                                              ));
        insert runingNumberList;

        groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
                                                                                        ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                                                                                        ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                        );
        insert groupOutletType;
        
        imageLevel = new ASI_CRM_Image_Level__c(ASI_CRM_SG_Name__c = 'Mainstream',
                                                                        ASI_CRM_SG_Group_Outlet_Type__c=groupOutletType.id
                                                                        );
        insert imageLevel;
        
      
    }   

   
                 
}