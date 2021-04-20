/*********************************************************************************
 * Name:ASI_CRM_SG_FOCComputeControllerTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/03/2018         Wilken        		[WL 1.0] Test coverage for contract margin regeneration
 * 17/06/2018         Wilken        		[WL 2.0] Add coverage for WS Back Rebate and Promotion
*********************************************************************************/
@isTest
public class ASI_CRM_SG_FOCComputeControllerTest{
    public static Integer businessRegistrationNumber = 123456789;
    
    private static User sgStandardUser;
    private static List<ASI_TH_CRM_Actual_Offtake__c> offtakes = new List<ASI_TH_CRM_Actual_Offtake__c>();
    private static List<ASI_MFM_SKU_Code__c> skus = new List<ASI_MFM_SKU_Code__c>();
    private static List<ASI_TH_CRM_Contract__c> contracts = new List<ASI_TH_CRM_Contract__c>();
    private static List<ASI_CRM_AccountsAdditionalField__c> customers = new List<ASI_CRM_AccountsAdditionalField__c>();
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

    static void createWineCategories(Integer recordSize){
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
                                                                                        ASI_CRM_EffectiveDate__c = date.today().adddays(-100),
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
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'),
                                                  ASI_CRM_CN_Outlet_WS__c = customer.id,
                                                  ASI_TH_CRM_Contract_Status__c = 'Contract Approved',
												  ASI_CRM_Type__c = 'Key Account',
                                                  ASI_TH_CRM_Start_Date__c = date.today().adddays(-1),
                                                  ASI_TH_CRM_End_Date__c = date.today().adddays(7),
												  ASI_CRM_Contract_Exist_Before_RTM__c = true
                                              );
        
        if(isCommit) {                                      
            insert contract;
        }
    }

    public static ASI_CRM_AccountsAdditionalField__c customer {get;set;}
    public static ASI_CRM_AccountsAdditionalField__c wholeSaler {get;set;}
    public static void customerData(boolean isCommit) {
        customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                name = 'customer Test123456',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                ASI_CRM_IsParentAccount__c = true,
                                                                ASI_CRM_MY_CustomerCode__c = '123test',
                                                                ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id,
                                                                ASI_CRM_SG_Image_Level__c  = imageLevel.id,
                                                                ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber)
                                                          );
        businessRegistrationNumber += 1;
        
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
                                                  ASI_CRM_SG_Sales_Incentive__c = si,
												  ASI_CRM_SG_Wholesaler_Margin__c = 2
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
		offs.ASI_TH_CRM_Actual_Offtake_External_ID__c = String.ValueOf(myDate) + '_' + wholeSaler.Id + '_' + customer.Id + '_' + skus[1].Id;
        offtakes.add(offs);

        ASI_TH_CRM_Actual_Offtake__c offs2 = new ASI_TH_CRM_Actual_Offtake__c();
        offs2.ASI_CRM_Latest_Vintage__c=skus[1].Id;
        offs2.ASI_TH_CRM_Sub_brand__c = subBrandList[0].Id;
        offs2.ASI_CRM_SG_Customer__c = customer.Id;
        Date myDate2 = Date.newInstance(2015, 1, 2);
        offs2.ASI_TH_CRM_Offtake_G_L_Date__c = myDate2;
        offs2.ASI_CRM_FromWS__c = wholeSaler.Id;
        offs2.ASI_CRM_SKU__c = skus[1].Id;
        offs2.ASI_TH_CRM_Quantity__c = 24;
        offs2.ASI_CRM_Contract__c = contract.Id;
		offs2.ASI_TH_CRM_Actual_Offtake_External_ID__c = String.ValueOf(myDate2) + '_' +  wholeSaler.Id + '_' + customer.Id + '_' +  skus[1].Id;
        offtakes.add(offs2);

		system.debug('Offtake Data: ' + offtakes);
		
        insert offtakes;		
    }

    static void createTestData1(){
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
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',40,50,skus.get(2).id);
        insert skuPriceCosts;
        
        customerData(true);
        WhoSalerData(true);
        contractData(true);
        createOfftakes();
        contractTargetData(true,contract,skus[1].Id,subBrandList[0].Id,3);
        contractTargetData(true,contract,skus[1].Id,subBrandList[0].Id,3);
    }

    static void createTestData2(){
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
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',40,50,skus.get(2).id);
        insert skuPriceCosts;
        
        customerData(true);
        WhoSalerData(true);
        contractData(true);
        createOfftakes();
        contractTargetData(true,contract,skus[1].Id,null,2);   
    }

    static void createTestData3(){
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
        /* Patched by Vincent 13 Jan 2016 BEGIN
         * Change the subbrand and wine cat for SKU 2 to test if the offtake only match with contract target's subbrand
        createSKU('Test Sku 1','test1','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',3,6,10,'UOM1',true,subBrandList.get(0).id,wineCategories[1].id);
        createSKU('Test Sku 2','test2','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',4,6,10,'UOM2',true,subBrandList.get(1).id,wineCategories[0].id);
        createSKU('Test Sku 3','test3','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',8,6,10,'UOM3',true,subBrandList.get(2).id,wineCategories[0].id);
        createSKU('Test Sku 4','test4','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',4,12,10,'UOM4',true,subBrandList.get(3).id,wineCategories[0].id);
        createSKU('Test Sku 5','test5','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',1,12,10,'UOM5',true,subBrandList.get(4).id,wineCategories[0].id);
        */
        createSKU('Test Sku 1','test1','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',3,6,10,'UOM1',true,subBrandList.get(0).id,wineCategories[0].id);
        createSKU('Test Sku 2','test2','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',4,6,10,'UOM2',true,subBrandList.get(0).id,wineCategories[1].id);
        createSKU('Test Sku 3','test3','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',8,6,10,'UOM3',true,subBrandList.get(2).id,wineCategories[0].id);
        createSKU('Test Sku 4','test4','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',4,12,10,'UOM4',true,subBrandList.get(3).id,wineCategories[0].id);
        createSKU('Test Sku 5','test5','ASI_MFM_SKU_Code__cASI_CRM_SG_SKU',1,12,10,'UOM5',true,subBrandList.get(4).id,wineCategories[0].id);
        /* Patched by Vincent 13 Jan 2016 END */
        insert skus;

        // Create Price Costs
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',40,50,skus.get(2).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',20,30,skus.get(0).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',30,40,skus.get(1).id);
        createPriceCost('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',40,50,skus.get(2).id);
        insert skuPriceCosts;
        
        customerData(true);
        WhoSalerData(true);
        contractData(true);
        createOfftakes();
        /* Patched by Vincent 13 Jan 2016 BEGIN
         * Since set null to SKU in contract target makes the test fail, fill in it and test the above scenario
        contractTargetData(true,contract,null,subBrandList[0].Id,3);
        */
        contractTargetData(true,contract,skus[2].Id,subBrandList[0].Id,3);
        /* Patched by Vincent 13 Jan 2016 END */
    }
    static void createUser(String userId){
        Profile p = [SELECT Id FROM Profile WHERE Name='ASI SG Standard User'];
        
        sgStandardUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= userId + '@laputa.com');
            
        insert sgStandardUser;
    }

    @TestSetup
    public static void setupTestData() {
        createUser('standardUser101');
    }

    static testMethod void test1(){
        User standardUser = [SELECT Id FROM USER WHERE UserName = 'standardUser101@laputa.com' LIMIT 1];
        System.runAs(standardUser){
            test.startTest();
                createDataSettings();

                createTestData1();
                ASI_CRM_SG_FOCComputeController.computeFOC('1','2015');
            
                ASI_CRM_SG_FOCComputeController.checkCurrentFOCComputation('1','2015');
                ASI_CRM_SG_FOCComputeController.checkCurrentFOCComputation('1','2015');
                ASI_CRM_SG_FOCComputeController.deleteFOCComputationAndFOCRequest('1','2015');
            
				/*[WL 1.0] BEGIN*/
            	ASI_CRM_SG_FOCComputeController.computeContractMargin('1','2015');
            	ASI_CRM_SG_FOCComputeController.deleteContractMargin('1','2015');
			
				ASI_CRM_SG_FOCComputeController.computeContractMargin('1','2015');
				ASI_CRM_SG_FOCComputeController.checkBeforeDeleteCM('1','2015',contract.Name);
				ASI_CRM_SG_FOCComputeController.recomputeCM('1','2015',contract.Name);
				/*[WL 1.0] END*/
				
			test.stopTest();
        }
    }
    
    static testMethod void test2(){
        User standardUser = [SELECT Id FROM USER WHERE UserName = 'standardUser101@laputa.com' LIMIT 1];
        System.runAs(standardUser){
            test.startTest();
                createDataSettings();
                createTestData2();
                ASI_CRM_SG_FOCComputeController.computeFOC('1','2015');
            test.stopTest();
        }
    }

    static testMethod void test3(){
        User standardUser = [SELECT Id FROM USER WHERE UserName = 'standardUser101@laputa.com' LIMIT 1];
        System.runAs(standardUser){
            test.startTest();
                createDataSettings();
                createTestData3();
                ASI_CRM_SG_FOCComputeController.computeFOC('1','2015');
            test.stopTest();
        }
    }
    
    static testMethod void test4() {
        User standardUser = [SELECT Id FROM USER WHERE UserName = 'standardUser101@laputa.com' LIMIT 1];
        System.runAs(standardUser){
            test.startTest();
                createDataSettings();
                createTestData1();
                ASI_CRM_SG_FOCComputeController.computeFOC('1','2015');
            test.stopTest();
            
            contract = [SELECT Name FROM ASI_TH_CRM_Contract__c LIMIT 1];
            ASI_CRM_SG_FOCComputeController.checkBeforeDeleteFOC('1','2015', contract.Name);
            ASI_CRM_SG_FOCComputeController.recomputeFOC('1','2015', contract.Name);
            
            
            ASI_CRM_SG_FOCComputeController.checkBeforeDeleteFOC('1','2015', 'Empty Contract');
            ASI_CRM_SG_FOCComputeController.recomputeFOC('1','2015', 'Empty Contract');
        }
    }
    
    static testMethod void test5() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_Sub_brand__c> subBrand = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();

        ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        for(integer i = 0 ; i < 2 ; i++) {
        	ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(false, customerData.customer);
        	contractData.contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
            contractList.add(contractData.contract);
        }
        insert contractList;
        
        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        for(ASI_TH_CRM_Contract__c tempContract : contractList) {
            for(ASI_MFM_SKU_Code__c sku : skuList) {
                ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, tempContract, sku);
                contractTargetData.contractTarget.ASI_CRM_Subbrand__c = subBrand[0].Id;
                contractTargetList.add(contractTargetData.contractTarget);
            }
        }
        insert contractTargetList;

        ASI_CRM_SG_TestClassHelper.offtakeData offtakeData = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractList[0].Id, customerData.customer.Id, skuList[0].Id);
        offtakeData.offtake.ASI_CRM_FromWS__c = customerData.customer.Id;
        offtakeData.offtake.ASI_TH_CRM_Sub_brand__c = subBrand[0].Id;
        insert offtakeData.offtake;
        
        Date todayDate = Date.today();

		String fromMonth = String.valueOf(todayDate.month());
		String fromYear  = String.valueOf(todayDate.year());
		String toMonth   = String.valueOf(todayDate.month());
		String toYear    = String.valueOf(todayDate.year());
        
        Test.startTest();
        	ASI_CRM_SG_FOCComputeController.computeBottleIncentive(fromMonth, fromYear, toMonth, toYear);
			
			/*[WL 1.0] BEGIN*/
			Integer fromYearInt = Integer.valueOf(todayDate.year());
			Integer fromMonthInt = Integer.valueOf(todayDate.month());
			Integer toYearInt = Integer.valueOf(todayDate.year());
			Integer toMonthInt = Integer.valueOf(todayDate.month());

			Integer toDayInt = Date.daysInMonth(toYearInt, toMonthInt);

			Date fromDate = Date.newInstance(fromYearInt, fromMonthInt, 1);
			Date toDate = Date.newInstance(toYearInt, toMonthInt, toDayInt);
			
			ASI_TH_CRM_PaymentRequest__c pay = new ASI_TH_CRM_PaymentRequest__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'), ASI_CRM_Generation_From_Date__c = fromDate,
																			ASI_CRM_Generation_To_Date__c = toDate);
			insert pay;
			ASI_CRM_SG_FOCComputeController.computeBottleIncentive(fromMonth, fromYear, toMonth, toYear);
			/*[WL 1.0] END*/
																 
        Test.stopTest();
        
        ASI_CRM_SG_FOCComputeController.deleteBottleIncentive(fromMonth, fromYear, toMonth, toYear);
    }
    
    static testMethod void test6() {
    	/*
        ASI_CRM_Credit_Debit_Note__c tempC = new ASI_CRM_Credit_Debit_Note__c(
        	ASI_CRM_Receipt_End_Date__c = system.today(),
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Prompt_Payment_Credit_Note')
        );
        insert tempC;
		*/
        
        ASI_CRM_SG_FOCComputeController controller = new ASI_CRM_SG_FOCComputeController();
        Boolean canGenPromptPayment = controller.canGenPromptPayment;
        String lastPromptPaymentReceiptDate = controller.lastPromptPaymentReceiptDate;
        
        test.startTest();
        	createDataSettings();
        	createTestData1();
        test.stopTest();
        ASI_CRM_SG_FOCComputeController.computePromptPayment('2015-01-01','2015-01-31');
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

		runingNumberList.add(new ASI_HK_CRM_Running_Number__c(
                                                                ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Credit_Debit_Note_No', 
                                                                ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2, 
                                                                ASI_HK_CRM_Format__c = '{YY}{00000}', 
                                                                ASI_HK_CRM_Running_Number__c = 2
                                                              ));
															  
        insert runingNumberList;

        groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
                                                                                        ASI_CRM_SG_Group_Outlet_Name__c='High Energy Bar',
                                                                                        ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                        );
        insert groupOutletType;
        
        imageLevel = new ASI_CRM_Image_Level__c(ASI_CRM_SG_Name__c = 'Mainstream',
                                                                        ASI_CRM_SG_Group_Outlet_Type__c=groupOutletType.id
                                                                        );
        insert imageLevel;
        
      
    }   

	/*[WL 2.0] BEGIN*/
	static testMethod void test_Promotion() {
		//customerData(true);
		ASI_CRM_SG_TestClassHelper.createDataSettings();
		List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        List<ASI_MFM_SKU_Code__c> giftVoucherList = ASI_CRM_SG_TestClassHelper.createGiftVoucher();
		ASI_CRM_SG_TestClassHelper.wholesalesCustomerData wholesaler = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
		ASI_CRM_SG_TestClassHelper.customerData outlet = new ASI_CRM_SG_TestClassHelper.customerData(false);
		outlet.customer.ASI_CRM_CN_Parent_Outlet__c = wholesaler.customer.id;
		insert outlet.customer;

		List<ASI_CRM_Promotion_Plan__c> list_promotionPlan = new List<ASI_CRM_Promotion_Plan__c>();
		
        ASI_CRM_Promotion_Plan__c promotionPlanW = new ASI_CRM_Promotion_Plan__c(
            Name = 'testPromotionPlanW',
            ASI_CRM_Start_Date__c = Date.today().addmonths(-1).toStartOfMonth(),
            ASI_CRM_End_Date__c = Date.today().addMonths(2).toStartOfMonth().addDays(-1),
            ASI_CRM_Enrollment_Cut_off_Date__c = Date.today().addDays(15),
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Plan__cASI_CRM_SG_Wholesaler_Promotion_Plan_Final_Approved'),
            ownerid = UserInfo.getUserId()
        );
        ASI_CRM_Promotion_Plan__c promotionPlanO = new ASI_CRM_Promotion_Plan__c(
            Name = 'testPromotionPlanO',
            ASI_CRM_Start_Date__c = Date.today().addmonths(-1).toStartOfMonth(),
            ASI_CRM_End_Date__c = Date.today().addMonths(2).toStartOfMonth().addDays(-1),
            ASI_CRM_Enrollment_Cut_off_Date__c = Date.today().addDays(15),
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Plan__cASI_CRM_SG_Outlet_Promotion_Plan_Final_Approved'),
            ownerid = UserInfo.getUserId()
        );
		list_promotionPlan.add(promotionPlanW);
		list_promotionPlan.add(promotionPlanO);
        insert list_promotionPlan;
		
		for(ASI_CRM_Promotion_Plan__c plan : list_promotionPlan){
			list<ASI_CRM_Promotion_Mechanic__c> list_mechanics = new list<ASI_CRM_Promotion_Mechanic__c>();
			
			for(ASI_MFM_SKU_Code__c sku : skuList){
				ASI_CRM_Promotion_Mechanic__c m = new ASI_CRM_Promotion_Mechanic__c(
				  RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Mechanic__cASI_CRM_SG_Promotion_Mechanic'),
					ASI_CRM_Promotion_Plan__c = plan.id,
					ASI_CRM_Promotional_SKU__c = sku.id,
					ASI_CRM_Additional_SKU_POSM__c = sku.id,
					ASI_CRM_Additional_SKU_Bottle_Qty__c = 1,
					ASI_CRM_Bottle_Size_Additional__c = 70,
					ASI_CRM_Bottle_Size_Promotional__c = 70,
					ASI_CRM_Buy_Qty__c = 10,
					ASI_CRM_Buy_Unit__c = 'Bottle',
					ASI_CRM_Ad_hoc_Cash__c = 10,
					ASI_CRM_Gift_Voucher__c = giftVoucherList[0].id,
					ASI_CRM_Gift_Voucher_Value_Cash__c = 100,
					ASI_CRM_IGC_Cost_Case_Promotional__c = 200,
					ASI_CRM_Other_in_Kind_Cash__c = 0.5,
					ASI_CRM_Packaging_Size_Additional__c = 12,
					ASI_CRM_Packaging_Size_Promotional__c = 12,
					ASI_CRM_RTM_WS_Price_Bottle_Additional__c = 100,
					ASI_CRM_RTM_WS_Price_Bottle_Promotional__c = 100,
					ASI_CRM_Target_Qty_Bottle__c = 1000,
					ASI_CRM_Trade_Deal_Bottle_Qty__c = 1
				);
				list_mechanics.add(m);
			}
			insert list_mechanics;
			
			ASI_HK_CRM_Promotion__c p1 = new ASI_HK_CRM_Promotion__c(
			  recordtypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_CRM_SG_Ad_hoc_Trade_Promotion'),
				ASI_CRM_Promotion_Plan__c = plan.id,
				ownerid = UserInfo.getUserId(),
				ASI_HK_CRM_Status__c = 'Final Approved'
			);
			insert p1;
						
			List<ASI_HK_CRM_Promotion_Detail__c> list_pd = new List<ASI_HK_CRM_Promotion_Detail__c>();
			for(ASI_CRM_Promotion_Mechanic__c m : list_mechanics){
				ASI_HK_CRM_Promotion_Detail__c pd1 = new ASI_HK_CRM_Promotion_Detail__c(
				    recordtypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion_Detail__cASI_CRM_SG_Customer'),
					ASI_HK_CRM_Promotion__c = p1.id,
					ASI_CRM_Promotion_Mechanic__c = m.id,
					ASI_CRM_SG_Customer__c = outlet.customer.id,
					ASI_CRM_Target_Qty_Bottle__c = 1
				);
				ASI_HK_CRM_Promotion_Detail__c pd2 = new ASI_HK_CRM_Promotion_Detail__c(
				    recordtypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion_Detail__cASI_CRM_SG_Customer'),
					ASI_HK_CRM_Promotion__c = p1.id,
					ASI_CRM_Promotion_Mechanic__c = m.id,
					ASI_CRM_SG_Customer__c = wholesaler.customer.id,
					ASI_CRM_Target_Qty_Bottle__c = 1
				);
				list_pd.add(pd1);
				list_pd.add(pd2);
			}
			insert list_pd;
			
			list<ASI_CRM_Promotion_Detail_Achievement__c> list_achieve = new list<ASI_CRM_Promotion_Detail_Achievement__c>();
			for(ASI_HK_CRM_Promotion_Detail__c pd : list_pd){
				ASI_CRM_Promotion_Detail_Achievement__c a = new ASI_CRM_Promotion_Detail_Achievement__c(
					RecordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Detail_Achievement__cASI_CRM_SG_Promotion_Detail_Achievement'),
					ASI_CRM_Promotion_Detail__c = pd.Id,
					ASI_CRM_ActualConsumption_9L__c = 10,
					ASI_CRM_Actual_Consumption_Value__c = 10,
					ASI_CRM_Achievement_Date__c = system.today()
				);
				list_achieve.add(a);
			}
			insert list_achieve;
		}
        
		ASI_CRM_SG_FOCComputeController.computePromotion(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()));
		ASI_CRM_SG_FOCComputeController.deletePromotion(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()));
		ASI_CRM_SG_FOCComputeController.computePromotionReGen(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()),'customer Test');
		ASI_CRM_SG_FOCComputeController.checkBeforePromotionReGen(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()),'customer Test');
		
		
		//Negative case for reGen
		ASI_TH_CRM_PaymentRequest__c payment = new ASI_TH_CRM_PaymentRequest__c(
													recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'),
													ASI_CRM_System_Remark__c = 'SG Promotion',
													ASI_CRM_Generation_From_Date__c = Date.Today(),
													ASI_TH_CRM_Status__c = 'Approved');
		insert payment;
		
		ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c(
													recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC'),
													ASI_CRM_System_Remark__c = 'SG Promotion',
													ASI_CRM_SG_Month__c = String.ValueOf(Date.Today().Month()),
													ASI_CRM_SG_Year__c = String.ValueOf(Date.Today().Year()),
													ASI_CRM_Outlet__c = outlet.customer.Id,
													ASI_FOC_Request_Status__c = 'Final');
		insert foc;		
		
		ASI_CRM_SG_FOCComputeController.checkBeforePromotionReGen(String.ValueOf(Date.Today().month()),String.ValueOf(Date.Today().year()),'customer Test');
		
		//Negative case for delete 
		ASI_CRM_SG_FOCComputeController.deletePromotion(String.ValueOf(Date.Today().month()),String.ValueOf(Date.Today().year()));
		
		//Negative case for reGen
		ASI_CRM_SG_FOCComputeController.checkBeforePromotionReGen(String.ValueOf(Date.Today().month()),String.ValueOf(Date.Today().year()),'customer Test');
	}
	
	static testMethod void test_WSBackRebate() {
		//customerData(true);
		//WhoSalerData(true);
		ASI_CRM_SG_TestClassHelper.createDataSettings();
		List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
		ASI_CRM_SG_TestClassHelper.customerData outlet = new ASI_CRM_SG_TestClassHelper.customerData(false);
		outlet.customer.ASI_CRM_Outlet_Type__c = 'Open Outlet';
		insert outlet.customer;
		ASI_CRM_SG_TestClassHelper.wholesalesCustomerData wholesaler = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
		
		List<ASI_TH_CRM_Actual_Offtake__c> list_a = new List<ASI_TH_CRM_Actual_Offtake__c>();
		for(ASI_MFM_SKU_Code__c sku : skuList){
			ASI_TH_CRM_Actual_Offtake__c a = new ASI_TH_CRM_Actual_Offtake__c(
			    RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'),
				ASI_CRM_SKU__c = sku.id,
				ASI_CRM_SG_Customer__c = outlet.customer.id,
				ASI_CRM_FromWS__c = wholesaler.customer.id,
				ASI_TH_CRM_Offtake_G_L_Date__c = system.today(),
				ASI_CRM_Open_Outlet_Price__c = 100,
				ASI_CRM_Special_Incentive_Price__c = 50,
				ASI_TH_CRM_Quantity__c = 10
			);
			list_a.add(a);
		}
		insert list_a;
		
		
		ASI_CRM_SG_FOCComputeController.computeWSBackRebate(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()),'Payment Request');
		ASI_CRM_SG_FOCComputeController.computeWSBackRebate(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()),'Credit Note');
		
		ASI_CRM_SG_FOCComputeController focCON = new ASI_CRM_SG_FOCComputeController();
		Boolean flag = focCON.canGenWSBackRebate;
		
		//Delete Case
		ASI_CRM_SG_FOCComputeController.deleteWSBackRebate(String.ValueOf(Date.Today().month()), String.ValueOf(Date.Today().year()));
		
		ASI_CRM_Credit_Debit_Note__c cNote = new ASI_CRM_Credit_Debit_Note__c(
													recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Back_Rebate_Credit_Note'),
													ASI_CRM_Year__c = String.ValueOf(Date.Today().year()),
													ASI_CRM_Month__c = String.ValueOf(Date.Today().month()),
													ASI_CRM_SYS_System_Generated__c = true,
													ASI_CRM_Status__c = 'Approved');
		insert cNote;
		
			//Negative case for normal generation
			ASI_CRM_SG_FOCComputeController.computeWSBackRebate(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()),'Payment Request');
			//
			
		system.debug('cNote ID: ' + cNote.Id + ' Year: ' + cNote.ASI_CRM_Year__c + ' Month: ' + cNote.ASI_CRM_Month__c);
		ASI_CRM_SG_FOCComputeController.deleteWSBackRebate(String.ValueOf(Date.Today().month()), String.ValueOf(Date.Today().year()));
		
		cNote.ASI_CRM_Status__c = 'Draft';
		update cNote;
		delete cNote;
		
		ASI_TH_CRM_PaymentRequest__c payment = new ASI_TH_CRM_PaymentRequest__c(
													recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'),
													ASI_CRM_System_Remark__c = 'Wholesaler Back Rebate Payment',
													ASI_CRM_Generation_From_Date__c = Date.Today(),
													ASI_TH_CRM_Status__c = 'Approved');
		insert payment;
			
			//Negative case for normal generation
			ASI_CRM_SG_FOCComputeController.computeWSBackRebate(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()),'Payment Request');
			//
		
		ASI_CRM_SG_FOCComputeController.deleteWSBackRebate(String.ValueOf(Date.Today().month()), String.ValueOf(Date.Today().year()));
		
		//Regen Case
		ASI_CRM_SG_FOCComputeController.computeWSBackRebateReGen(String.ValueOf(Date.Today().year()),String.ValueOf(Date.Today().month()),'Payment Request','customer Test');
		
	}
    /*[WL 2.0] END*/             
}