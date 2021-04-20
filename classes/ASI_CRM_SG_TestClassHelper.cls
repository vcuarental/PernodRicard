/*********************************************************************************
 * Name:ASI_CRM_SG_TestClassHelper
 * Description: For generating test data for ASI CRM SG
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/02/2015         Laputa: Conrad        Created
 * 10/07/2017         Wilken Lee            [WL 1.0] Updated test data default Customer Name record type to Outlet SG
 * 04/01/2018         Wilken Lee            [WL 2.0] Update WS Sales Order test data creation
 * 2018-02-28         Wilken Lee            [WL 3.0] Increase Build Contract Controller coverage
 * 2018-06-20         Vincent Lam           [VL 1.0] Build gift voucher
 * 2020-09-24         Wilken Lee            [WL 4.0] Comment createDataSettings() in customerData method to avoid duplicate execution
*********************************************************************************/
@isTest
public class ASI_CRM_SG_TestClassHelper {

    public static Integer businessRegistrationNumber = 123456789;
    
    public static ASI_CRM_Group_Outlet_Type__c groupOutletType;

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
                                                                ASI_HK_CRM_Format__c = 'P{YY}{00000}', 
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
                                                                                        ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                                                                                        ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                        );
        insert groupOutletType;
        
        ASI_CRM_Image_Level__c imageLevel = new ASI_CRM_Image_Level__c(ASI_CRM_SG_Name__c = 'Mainstream',
                                                                        ASI_CRM_SG_Group_Outlet_Type__c=groupOutletType.id
                                                                        );
        insert imageLevel;
        
        ASI_CRM_Outlet_Type__c outletType = new ASI_CRM_Outlet_Type__c(
                                                                        ASI_CRM_SG_Active__c = true,
                                                                        ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
                                                                        ASI_CRM_SG_Name__c='Asian TOT'
                                                                        );
        insert outletType;
        
        ASI_CRM_Contract_Pros_Benchmark__c contractProsBenchmarks = new ASI_CRM_Contract_Pros_Benchmark__c(
                                                                                                            ASI_CRM_SG_Image__c = imageLevel.id,
                                                                                                            ASI_CRM_SG_Matrix__c = 'Maintain',
                                                                                                            ASI_CRM_SG_Outlet_Type__c = outletType.id,
                                                                                                            ASI_CRM_SG_Pros_Type__c = 'High Energy Bar',
                                                                                                            ASI_CRM_SG_PRS_Benchmark__c = 20
                                                                                                         );        
        insert contractProsBenchmarks;
      
    }
    
    /* [VL 1.0] BEGIN */
    public static List<ASI_MFM_SKU_Code__c> createGiftVoucher() {
    
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_MFM_SKU_Code__c sku1 = new ASI_MFM_SKU_Code__c (
                                                                name='Gift Voucher - $100',
                                                                ASI_CRM_Standard_Cost__c = 100,
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_Gift_Voucher'),
                                                                ASI_HK_CRM_Active__c = true
                                                            );
        ASI_MFM_SKU_Code__c sku2 = new ASI_MFM_SKU_Code__c (
                                                                name='Gift Voucher - $50',
                                                                ASI_CRM_Standard_Cost__c = 50,
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_Gift_Voucher'),
                                                                ASI_HK_CRM_Active__c = true
                                                            );
        skuList.add(sku1);
        skuList.add(sku2);
        insert skuList;
        return skuList;
    }
    /* [VL 1.0] END */
    
    public static List<ASI_MFM_SKU_Code__c> createSKUandPRiceData() {
    
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCostList = new List<ASI_CRM_MY_SKUPriceCost__c>();
        
        /*[WL 3.0] BEGIN*/
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c (
                                                                      name='TestSubBrand 1',
                                                                      ASI_MFM_Sub_brand_Code__c = 'T01',
                                                                      ASI_CRM_Prompt_Payment_Rate__c = 2,
                                                                      ASI_CRM_Allow_Prompt_Payment__c = true,
                                                                      ASI_CRM_Wine_Category_Group__c = 'Wine',
                                                                      recordtypeid =  Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand') 
                                                                  );
        insert subBrand1;
        /*[WL 3.0] END*/
        
        ASI_MFM_SKU_Code__c sku1 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 1',
                                                                ASI_MFM_SKU_Code__c = 'test1',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 3,
                                                                ASI_HK_CRM_Packaging_Size__c = 4,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true,
                                                                ASI_CRM_Preset__c = true,
                                                                ASI_MFM_Sub_brand__c = subBrand1.Id
                                                            );
        skuList.add(sku1);
        
        ASI_MFM_SKU_Code__c sku2 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 2',
                                                                ASI_MFM_SKU_Code__c = 'test2',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 4,
                                                                ASI_HK_CRM_Packaging_Size__c = 6,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true
                                                            );
        skuList.add(sku2);
        
        ASI_MFM_SKU_Code__c sku3 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 3',
                                                                ASI_MFM_SKU_Code__c = 'test3',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 8,
                                                                ASI_HK_CRM_Packaging_Size__c = 9,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true
                                                            );
        skuList.add(sku3);
        
        ASI_MFM_SKU_Code__c sku4 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 3',
                                                                ASI_MFM_SKU_Code__c = 'test3',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_CA'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 8,
                                                                ASI_HK_CRM_Packaging_Size__c = 9,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true
                                                            );
        skuList.add(sku4);
        
        ASI_MFM_SKU_Code__c sku5 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 5',
                                                                ASI_MFM_SKU_Code__c = 'test5',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 8,
                                                                ASI_HK_CRM_Packaging_Size__c = 9,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true,
                                                                ASI_HK_CRM_IsPOSProduct__c = false
                                                            );
        skuList.add(sku5);
        
        insert skuList;
        
        /*[WL 3.0] BEGIN*/
        subBrand1.ASI_CRM_Representative_SKU__c = sku1.Id;
        update subBrand1;
        /*[WL 3.0] END*/
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost1 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost2 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost3 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost4 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost5 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost6 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost7 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost8 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost9 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost10 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Open_Outlet_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost11 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 10,
                                                                                      ASI_CRM_Price__c = 29,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost12 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Quarterly_Promo_Price'),
                                                                                      ASI_CRM_Cost__c = 5,
                                                                                      ASI_CRM_Price__c = 28,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        // add 7 sku price only because sku should have excalty 7 price
        skuPriceCostList.add(skuPriceCost1);
        skuPriceCostList.add(skuPriceCost2);
        skuPriceCostList.add(skuPriceCost3);
        skuPriceCostList.add(skuPriceCost4);
        skuPriceCostList.add(skuPriceCost5);
        skuPriceCostList.add(skuPriceCost6);
        skuPriceCostList.add(skuPriceCost7);
        skuPriceCostList.add(skuPriceCost8);
        skuPriceCostList.add(skuPriceCost9);
        skuPriceCostList.add(skuPriceCost10);
        skuPriceCostList.add(skuPriceCost11);
        skuPriceCostList.add(skuPriceCost12);

        insert skuPriceCostList;
        
        return skuList;
    
    }
    
    public static List<ASI_MFM_SKU_Code__c> createSKUwithSubrand(List<ASI_MFM_Sub_brand__c> subBrandList) {
    
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCostList = new List<ASI_CRM_MY_SKUPriceCost__c>();
        
        ASI_MFM_SKU_Code__c sku1 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 1',
                                                                ASI_MFM_SKU_Code__c = 'test1',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 3,
                                                                ASI_HK_CRM_Packaging_Size__c = 4,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true,
                                                                ASI_MFM_Sub_brand__c = subBrandList.get(0).id
                                                            );
        skuList.add(sku1);
        
        ASI_MFM_SKU_Code__c sku2 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 2',
                                                                ASI_MFM_SKU_Code__c = 'test2',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 4,
                                                                ASI_HK_CRM_Packaging_Size__c = 6,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true,
                                                                ASI_MFM_Sub_brand__c = subBrandList.get(1).id
                                                            );
        skuList.add(sku2);
        
        ASI_MFM_SKU_Code__c sku3 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 3',
                                                                ASI_MFM_SKU_Code__c = 'test3',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 8,
                                                                ASI_HK_CRM_Packaging_Size__c = 9,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true,
                                                                ASI_MFM_Sub_brand__c = subBrandList.get(2).id
                                                            );
        skuList.add(sku3);
        insert skuList;
        
        /*[WL 3.0] BEGIN*/
        ASI_MFM_Sub_brand__c sb = subBrandList.get(0);
        sb.ASI_CRM_Representative_SKU__c = sku1.Id;
        update sb;
        /*[WL 3.0] END*/
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost1 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        skuPriceCostList.add(skuPriceCost1);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost2 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        skuPriceCostList.add(skuPriceCost2);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost3 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        
        skuPriceCostList.add(skuPriceCost3);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost4 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-7),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        
        skuPriceCostList.add(skuPriceCost4);
        
        insert skuPriceCostList;
        
        return skuList;
    
    }
    
     public static  List<ASI_MFM_SKU_Code__c> createSKUwith7PriceData() {
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCostList = new List<ASI_CRM_MY_SKUPriceCost__c>();
        
        ASI_MFM_SKU_Code__c sku1 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 1',
                                                                ASI_MFM_SKU_Code__c = 'test1',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 3,
                                                                ASI_HK_CRM_Packaging_Size__c = 4,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true,
                                                                ASI_CRM_Preset__c = true
                                                            );
        skuList.add(sku1);
        insert skuList;
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost1 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost2 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Open_Outlet_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost3 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today(),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );


        ASI_CRM_MY_SKUPriceCost__c skuPriceCost4 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost5 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost6 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost7 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 29,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost10 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Open_Outlet_Price_Per_Bottle'),
                                                                                      ASI_CRM_Cost__c = 20,
                                                                                      ASI_CRM_Price__c = 30,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost12 = new ASI_CRM_MY_SKUPriceCost__c (
                                                                                      ASI_CRM_EffectiveDate__c = date.today().adddays(-1),
                                                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Quarterly_Promo_Price'),
                                                                                      ASI_CRM_Cost__c = 5,
                                                                                      ASI_CRM_Price__c = 28,
                                                                                      ASI_CRM_SKU__c = sku1.id
                                                                                  );
        // add 7 sku price only because sku should have excalty 7 price
        skuPriceCostList.add(skuPriceCost1);
        skuPriceCostList.add(skuPriceCost2);
        skuPriceCostList.add(skuPriceCost3);
        skuPriceCostList.add(skuPriceCost4);
        skuPriceCostList.add(skuPriceCost5);
        skuPriceCostList.add(skuPriceCost6);
        skuPriceCostList.add(skuPriceCost7);
        skuPriceCostList.add(skuPriceCost10);
        skuPriceCostList.add(skuPriceCost12);

        insert skuPriceCostList;
        
        return skuList;
    
    }
    
    public static List<ASI_CRM_SG_SO_FOC_Rules__c> createFOCRule(List<ASI_MFM_SKU_Code__c> skuList, Id customerId) {
        List<ASI_CRM_SG_SO_FOC_Rules__c> focRuleList = new List<ASI_CRM_SG_SO_FOC_Rules__c>();
        
        ASI_CRM_SG_SO_FOC_Rules__c focRule1 = new ASI_CRM_SG_SO_FOC_Rules__c(
                                                                                ASI_CRM_SG_Buy__c = 10,
                                                                                ASI_CRM_SG_Get_Free_Bottle__c = 1,
                                                                                ASI_CRM_Effective_Date__c = date.today().adddays(-7),
                                                                                ASI_CRM_SG_Wholesaler__c = customerId,
                                                                                ASI_CRM_SKU_First_5_Digits__c = ((String)skuList.get(0).Name).substring(0,5),
                                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_SG_SO_FOC_Rules__cASI_CRM_SG_SO_FOC_Rule_Wholesaler')
                                                                            );
        focRuleList.add(focRule1);
        
        insert focRuleList;
        
        return focRuleList;
    }
    
    public static List<ASI_MFM_Sub_brand__c> createSubBrandData() {
    
        List<ASI_MFM_Sub_brand__c> subBrandList = new List<ASI_MFM_Sub_brand__c>();
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c (
                                                                      name='TestSubBrand 1',
                                                                      ASI_MFM_Sub_brand_Code__c = 'T01',
                                                                      ASI_CRM_Prompt_Payment_Rate__c = 2,
                                                                      ASI_CRM_Allow_Prompt_Payment__c = true,
                                                                      ASI_CRM_Wine_Category_Group__c = 'Wine',
                                                                      recordtypeid =  Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand') 
                                                                  );
        subBrandList.add(subBrand1);
        
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c (
                                                                      name='TestSubBrand 2',
                                                                      ASI_MFM_Sub_brand_Code__c = 'T02',
                                                                      ASI_CRM_Prompt_Payment_Rate__c = 2,
                                                                      ASI_CRM_Allow_Prompt_Payment__c = true,
                                                                      ASI_CRM_Wine_Category_Group__c = 'Wine',
                                                                      recordtypeid =  Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand') 
                                                                  );
        subBrandList.add(subBrand2);
        
        ASI_MFM_Sub_brand__c subBrand3 = new ASI_MFM_Sub_brand__c (
                                                                      name='TestSubBrand 3',
                                                                      ASI_MFM_Sub_brand_Code__c = 'T03',
                                                                      ASI_CRM_Prompt_Payment_Rate__c = 2,
                                                                      ASI_CRM_Allow_Prompt_Payment__c = true,
                                                                      ASI_CRM_Wine_Category_Group__c = 'Wine',
                                                                      recordtypeid =  Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand') 
                                                                  );
        subBrandList.add(subBrand3);
        insert subBrandList;
        
        return subBrandList;
    }
    
    public static List<ASI_CRM_Payment_Schedule__c> createPaymentSchedule(ASI_TH_CRM_Contract__c contract) {
        
        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
        
        string paymentRTid =  Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'); 
        
        ASI_CRM_Payment_Schedule__c paymentSchedule1 = new ASI_CRM_Payment_Schedule__c (
                                                                                               ASI_CRM_Percentof_achieved_Sales_Target__c = '20',
                                                                                               ASI_CRM_Contract__c = contract.Id,
                                                                                               ASI_CRM_Type__c = 'Cash Sponsorship',
                                                                                               ASI_CRM_Sponsorship__c = 10,
                                                                                                recordtypeid = paymentRTid
                                                                                       );
        paymentScheduleList.add(paymentSchedule1);
        
        ASI_CRM_Payment_Schedule__c paymentSchedule2 = new ASI_CRM_Payment_Schedule__c (
                                                                                               ASI_CRM_Percentof_achieved_Sales_Target__c = '50',
                                                                                               ASI_CRM_Contract__c = contract.Id,
                                                                                               ASI_CRM_Type__c = 'Cash Sponsorship',
                                                                                               ASI_CRM_Sponsorship__c = 10,
                                                                                                recordtypeid = paymentRTid
                                                                                       );
        paymentScheduleList.add(paymentSchedule2);
        
        ASI_CRM_Payment_Schedule__c paymentSchedule3 = new ASI_CRM_Payment_Schedule__c (
                                                                                               ASI_CRM_Schedule_Date__c = date.today(),
                                                                                               ASI_CRM_Contract__c = contract.Id,
                                                                                               ASI_CRM_Type__c = 'Cash Sponsorship',
                                                                                               ASI_CRM_Sponsorship__c = 10,
                                                                                                recordtypeid = paymentRTid
                                                                                       );
        paymentScheduleList.add(paymentSchedule3);
        insert paymentScheduleList;
        
        return paymentScheduleList;
    }
    
    //Create User
    public static User createUser(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
            
        insert u1;
        return u1;
    }
    
    //Create User with parameter
    public static User createUser(String userId){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= userId + '@laputa.com');
            
        insert u1;
        return u1;
    }
    
    public class customerData {
        public ASI_CRM_AccountsAdditionalField__c customer {get;set;}
        
        public customerData(boolean isCommit) {
        //createDataSettings(); ///WL 4.0
            /* insert group outlet type when preparing data (at the beginning)
            ASI_CRM_Group_Outlet_Type__c groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
                                                                                            ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                                                                                            ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                            );
            insert groupOutletType;
            */
            customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = 'customer Test',
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                    ASI_CRM_IsParentAccount__c = true,
                                                                    ASI_CRM_MY_CustomerCode__c = '123test',
                                                                    ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
                                                                    ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber),
                                                                    ASI_CRM_Active__c = true
                                                              );
            
            businessRegistrationNumber += 1;

            if(isCommit) {                               
                insert customer;
            }
        }
        
        public customerData(boolean isCommit, ID recordTypeOutlet) {
        
            /* insert group outlet type when preparing data (at the beginning)
            ASI_CRM_Group_Outlet_Type__c groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
                                                                                            ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                                                                                            ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                            );
            insert groupOutletType;
            */
            customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = 'customer Test',
                                                                    recordtypeid = recordTypeOutlet,
                                                                    ASI_CRM_IsParentAccount__c = true,
                                                                    ASI_CRM_MY_CustomerCode__c = '123test',
                                                                    ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
                                                                    ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber),
                                                                    ASI_CRM_Active__c = true
                                                              );
            
            businessRegistrationNumber += 1;

            if(isCommit) {                               
                insert customer;
            }
        }
        
        public customerData(boolean isCommit, String customName) {
        
            /* insert group outlet type when preparing data (at the beginning)
            ASI_CRM_Group_Outlet_Type__c groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
                                                                                            ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                                                                                            ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                            );
            insert groupOutletType;
            */
            customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = customName,
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                    ASI_CRM_IsParentAccount__c = true,
                                                                    ASI_CRM_MY_CustomerCode__c = '123testTest',
                                                                    //ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
                                                                    ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber),
                                                                    ASI_CRM_Active__c = true
                                                              );
            
            businessRegistrationNumber += 1;

            if(isCommit) {                               
                insert customer;
            }
        }
        
        public customerData(boolean isCommit, ASI_CRM_AccountsAdditionalField__c parentCustomer) {
        
            /* insert group outlet type when preparing data (at the beginning)
            ASI_CRM_Group_Outlet_Type__c groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
                                                                                            ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                                                                                            ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                            );
            insert groupOutletType;
            */
            customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = 'customer Test',
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                    ASI_CRM_CN_Parent_Outlet__c = parentCustomer.id,
                                                                    ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
                                                                    ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber),
                                                                    ASI_CRM_Active__c = true
                                                              );
            
            businessRegistrationNumber += 1;

            if(isCommit) {                               
                insert customer;
            }
        }
        
    }
    
    public class wholesalesCustomerData {
        public ASI_CRM_AccountsAdditionalField__c customer {get;set;}
        
        public wholesalesCustomerData(boolean isCommit) {
            customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = 'customer Test',
                                                                    /*[WL 1.0 BEGIN]*/
                                                                    // Vincent Lam: why change our code? this method is to create wholesaler...
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Wholesaler'),
                                                                    //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                    /*[WL 1.0 END*/
                                                                    ASI_CRM_IsParentAccount__c = true,
                                                                    ASI_CRM_MY_CustomerCode__c = '123testTest'
                                                              );
            
            if(isCommit) {                               
                insert customer;
            }
        }
        
        public wholesalesCustomerData(boolean isCommit, String customerName) {
            customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = customerName,
                                                                    /*[WL 1.0 BEGIN]*/
                                                                    // Vincent Lam: why change our code? this method is to create wholesaler...
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Wholesaler'),
                                                                    //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                    /*[WL 1.0 END*/
                                                                    ASI_CRM_IsParentAccount__c = true,
                                                                    ASI_CRM_MY_CustomerCode__c = '123testTest'
                                                              );
            
            if(isCommit) {                               
                insert customer;
            }
        }
        
    }
    
    public class contractData {
        public ASI_TH_CRM_Contract__c contract {get;set;}
        
        public contractData(boolean isCommit) {
        
            customerData customerC = new customerData(true);
            
            contract = new ASI_TH_CRM_Contract__c (
                                                      name='test',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract'),
                                                      ASI_CRM_CN_Outlet_WS__c = customerC.customer.id,
                                                      ASI_TH_CRM_Contract_Status__c = 'Draft',
                                                      ASI_TH_CRM_Start_Date__c = date.today().adddays(-1),
                                                      ASI_TH_CRM_End_Date__c = date.today().adddays(7),
                                                      ASI_CRM_Type__c = 'Key Account'
                                                  );
            
            if(isCommit) {                                      
                insert contract;
            }
        }
        
        public contractData(boolean isCommit, String status) {
        
            customerData customerC = new customerData(true);
            
            contract = new ASI_TH_CRM_Contract__c (
                                                      name='test',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract'),
                                                      ASI_CRM_CN_Outlet_WS__c = customerC.customer.id,
                                                      ASI_TH_CRM_Contract_Status__c = status,
                                                      ASI_TH_CRM_Start_Date__c = date.today().adddays(-1),
                                                      ASI_TH_CRM_End_Date__c = date.today().adddays(7),
                                                      ASI_CRM_Type__c = 'Key Account'
                                                  );
            
            if(isCommit) {                                      
                insert contract;
            }
        }
        
        public contractData(boolean isCommit, ASI_CRM_AccountsAdditionalField__c customerC) {
            
            contract = new ASI_TH_CRM_Contract__c (
                                                      name='PRS-TTT-0000-test',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract'),
                                                      ASI_CRM_CN_Outlet_WS__c = customerC.id,
                                                      ASI_TH_CRM_Contract_Status__c = 'Draft',
                                                      ASI_TH_CRM_Start_Date__c = date.today().adddays(-1),
                                                      ASI_TH_CRM_End_Date__c = date.today().adddays(7),
                                                      ASI_CRM_Type__c = 'Key Account'
                                                  );
            
            if(isCommit) {                                      
                insert contract;
            }
        }
        
        public contractData(boolean isCommit, ASI_CRM_AccountsAdditionalField__c customerC, string isApproved) {
            
            contract = new ASI_TH_CRM_Contract__c (
                                                      name='PRS-TTT-0000-test',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'),
                                                      ASI_CRM_CN_Outlet_WS__c = customerC.id,
                                                      ASI_TH_CRM_Contract_Status__c = 'Contract Approved',
                                                      ASI_TH_CRM_Start_Date__c = date.today().adddays(-1),
                                                      ASI_TH_CRM_End_Date__c = date.today().adddays(7),
                                                      ASI_CRM_Type__c = 'Key Account'
                                                  );
            
            if(isCommit) {                                      
                insert contract;
            }
        }
        
    }
    
    public class contractTargetData {
        public ASI_CRM_ContractTarget__c contractTarget {get;set;}
        
        public contractTargetData(boolean isCommit, ASI_TH_CRM_Contract__c contract, ASI_MFM_SKU_Code__c SKU) {
            
            contractTarget = new ASI_CRM_ContractTarget__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                                      ASI_CRM_Contract__c = contract.id,
                                                      ASI_CRM_SKU__c = SKU.id,
                                                      ASI_CRM_SG_FOC_Calculation__c = '--None--',
                                                      ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 10,
                                                      ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
                                                      ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
                                                      ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
                                                      ASI_CRM_SG_Btls_Per_Case__c = 3,
                                                      ASI_CRM_SG_Size_cl__c = 4,
                                                        ASI_CRM_Bottle_Incentive__c = 1
                                                  );
            
            if(isCommit) {                                      
                insert contractTarget;
            }
        }
        
        public contractTargetData(boolean isCommit, ASI_TH_CRM_Contract__c contract, ASI_MFM_SKU_Code__c SKU, Integer cash) {
            
            contractTarget = new ASI_CRM_ContractTarget__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                                      ASI_CRM_Contract__c = contract.id,
                                                      ASI_CRM_SKU__c = SKU.id,
                                                      ASI_CRM_SG_FOC_Calculation__c = '--None--',
                                                      ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 10,
                                                      ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
                                                      ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
                                                      ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
                                                      ASI_CRM_SG_Btls_Per_Case__c = 3,
                                                      ASI_CRM_SG_Size_cl__c = 4,
                                                      ASI_CRM_SG_Cash__c = cash,
                                                        ASI_CRM_Bottle_Incentive__c = 1
                                                  );
            
            if(isCommit) {                                      
                insert contractTarget;
            }
        }
        
        public contractTargetData(boolean isCommit, ASI_TH_CRM_Contract__c contract, ASI_MFM_SKU_Code__c SKU, Integer cpo, Integer wsMargin) {
            
            contractTarget = new ASI_CRM_ContractTarget__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                                      ASI_CRM_Contract__c = contract.id,
                                                      ASI_CRM_SKU__c = SKU.id,
                                                      ASI_CRM_SG_FOC_Calculation__c = '--None--',
                                                      ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 10,
                                                      ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
                                                      ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
                                                      ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
                                                      ASI_CRM_SG_Btls_Per_Case__c = 3,
                                                      ASI_CRM_SG_Size_cl__c = 4,
                                                        ASI_CRM_Bottle_Incentive__c = 1,
                                                        ASI_CRM_SG_Consumer_Price_Offer__c = cpo,
                                                        ASI_CRM_SG_Wholesaler_Margin__c = wsMargin
                                                  );
            
            if(isCommit) {                                      
                insert contractTarget;
            }
        }
    }
    
    public class paymentData {
        public ASI_TH_CRM_PaymentRequest__c payment {get;set;}
        
        public paymentData(boolean isCommit) {
        
            contractData contractP = new contractData(true, 'Contract Approved');
            
            payment = new ASI_TH_CRM_PaymentRequest__c (
                                                      name='P10001',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'),
                                                      ASI_TH_CRM_Contract__c = contractP.contract.id,
                                                      ASI_CRM_CN_OutletWS__c = contractP.contract.ASI_CRM_CN_Outlet_WS__c 
                                                  );
            
            if(isCommit) {                                      
                insert payment;
            }
        }
        
        public paymentData(boolean isCommit, contractData contractP) {
            
            payment = new ASI_TH_CRM_PaymentRequest__c (
                                                      name='P10001',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'),
                                                      ASI_TH_CRM_Contract__c = contractP.contract.id,
                                                      ASI_CRM_CN_OutletWS__c = contractP.contract.ASI_CRM_CN_Outlet_WS__c 
                                                  );
            
            if(isCommit) {                                      
                insert payment;
            }
        }
        
        public paymentData(boolean isCommit, ASI_CRM_AccountsAdditionalField__c outletData) {
        
            contractData contractP = new contractData(true, 'Contract Approved');
            
            payment = new ASI_TH_CRM_PaymentRequest__c (
                                                      name='P10001',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'),
                                                      ASI_TH_CRM_Contract__c = contractP.contract.id,
                                                      ASI_CRM_CN_OutletWS__c = outletData.id
                                                  );
            
            if(isCommit) {                                      
                insert payment;
            }
        }
        
        public paymentData(boolean isCommit, ASI_CRM_AccountsAdditionalField__c outletData, ASI_CRM_AccountsAdditionalField__c vendorData) {
        
            contractData contractP = new contractData(true, outletData, 'Contract Approved');
            
            payment = new ASI_TH_CRM_PaymentRequest__c (
                                                      name='P10001',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'),
                                                      ASI_TH_CRM_Contract__c = contractP.contract.id,
                                                      ASI_CRM_CN_OutletWS__c = outletData.id,
                                                      ASI_CRM_Vendor__c = vendorData.id
                                                  );
            
            if(isCommit) {                                      
                insert payment;
            }
        }
        
    }
    
    public class paymentItemData {
        public ASI_TH_CRM_PaymentRequestLineItem__c paymentItem {get;set;}
        
        public paymentItemData(boolean isCommit, ASI_TH_CRM_PaymentRequest__c payment) {
        
            contractData contractP = new contractData(true, 'Contract Approved');
            
            paymentItem = new ASI_TH_CRM_PaymentRequestLineItem__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
                                                      ASI_TH_CRM_Payment_Request__c = payment.id
                                                  );
            
            if(isCommit) {                                      
                insert paymentItem;
            }
        }
        
        public paymentItemData(boolean isCommit, ASI_TH_CRM_PaymentRequest__c payment, string type) {
        
            contractData contractP = new contractData(true, 'Contract Approved');
            
            paymentItem = new ASI_TH_CRM_PaymentRequestLineItem__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
                                                      ASI_TH_CRM_Payment_Request__c = payment.id,
                                                      ASI_CRM_SG_Type__c = type,
                                                      ASI_TH_CRM_Amount__c = 1
                                                  );
            
            if(isCommit) {                                      
                insert paymentItem;
            }
        }
        
        public paymentItemData(boolean isCommit, ASI_TH_CRM_PaymentRequest__c payment, ASI_MFM_Sub_brand__c subBrand, string type) {
        
            contractData contractP = new contractData(true, 'Contract Approved');
            
            paymentItem = new ASI_TH_CRM_PaymentRequestLineItem__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
                                                      ASI_CRM_SG_Sub_brand__c = subBrand.Id,
                                                      ASI_TH_CRM_Payment_Request__c = payment.id,
                                                      ASI_CRM_SG_Type__c = type,
                                                      ASI_TH_CRM_Amount__c = 1
                                                  );
            
            if(isCommit) {                                      
                insert paymentItem;
            }
        }

    }
    
    public class freeGoodsData {
        
        public ASI_FOC_Free_Goods_Request__c freeGoods {get;set;}
        
        public freeGoodsData(boolean isCommit, String customRecordtype) {
        
           contractData contractP = new contractData(true, 'Contract Approved');
           
           freeGoods = new ASI_FOC_Free_Goods_Request__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__c'+customRecordtype),
                           ASI_CRM_Contract__c = contractP.contract.id,
                           ASI_CRM_SG_Order_Date__c = date.today(),
                           ASI_CRM_Outlet__c = contractP.contract.ASI_CRM_CN_Outlet_WS__c
                       );
            
            if(isCommit) {                                      
                insert freeGoods;
            }
        }
        
        public freeGoodsData(boolean isCommit, ASI_TH_CRM_Contract__c contract, String customRecordtype) {
        
           freeGoods = new ASI_FOC_Free_Goods_Request__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__c'+customRecordtype),
                           ASI_CRM_Contract__c = contract.id,
                           ASI_CRM_SG_Order_Date__c = date.today(),
                           ASI_CRM_Outlet__c = contract.ASI_CRM_CN_Outlet_WS__c
                       );
            
            if(isCommit) {                                      
                insert freeGoods;
            }
        }
        
        public freeGoodsData(boolean isCommit, String customRecordtype, string customStatus) {
        
           contractData contractP = new contractData(true, 'Contract Approved');
           
           freeGoods = new ASI_FOC_Free_Goods_Request__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__c'+customRecordtype),
                           ASI_CRM_Contract__c = contractP.contract.id,
                           ASI_CRM_SG_Order_Date__c = date.today(),
                           ASI_CRM_Outlet__c = contractP.contract.ASI_CRM_CN_Outlet_WS__c,
                           ASI_FOC_Request_Status__c = customStatus
                       );
            
            if(isCommit) {                                      
                insert freeGoods;
            }
        }
        
        public freeGoodsData(boolean isCommit, ASI_TH_CRM_Contract__c contract, String customRecordtype, string customStatus) {
        
           freeGoods = new ASI_FOC_Free_Goods_Request__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__c'+customRecordtype),
                           ASI_CRM_Contract__c = contract.id,
                           ASI_CRM_SG_Order_Date__c = date.today(),
                           ASI_CRM_Outlet__c = contract.ASI_CRM_CN_Outlet_WS__c,
                           ASI_FOC_Request_Status__c = customStatus
                       );
            
            if(isCommit) {                                      
                insert freeGoods;
            }
        }
    }
    
    public class freeGoodsItemData {
        
        public ASI_FOC_Request_Item__c freeGoodsItem {get;set;}
        
        public freeGoodsItemData(boolean isCommit, ASI_FOC_Free_Goods_Request__c freeP) {
           
           freeGoodsItem = new ASI_FOC_Request_Item__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                           ASI_FOC_Request_Order__c = freeP.id
                       );
            
            if(isCommit) {                                      
                insert freeGoodsItem;
            }
        }
        
        public freeGoodsItemData(boolean isCommit, ASI_FOC_Free_Goods_Request__c freeP, ASI_MFM_SKU_Code__c skuCode) {
           
           freeGoodsItem = new ASI_FOC_Request_Item__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                           ASI_FOC_Request_Order__c = freeP.id,
                           ASI_FOC_SKU__c = skuCode.id
                       );
            
            if(isCommit) {                                      
                insert freeGoodsItem;
            }
        }
        
        public freeGoodsItemData(boolean isCommit, ASI_FOC_Free_Goods_Request__c freeP, ASI_MFM_SKU_Code__c skuCode, string type) {
           
           freeGoodsItem = new ASI_FOC_Request_Item__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                           ASI_FOC_Request_Order__c = freeP.id,
                           ASI_FOC_SKU__c = skuCode.id,
                           ASI_CRM_SG_FOC_Type__c = type,
                           ASI_FOC_Request_Quantity_Bottle__c = 1,
                           ASI_FOC_Actual_Quantity_Bottle__c = 2,
                           ASI_CRM_Adjustment_Remarks__c = 'testingAdjustmentRemark8CharactersMin',
                           ASI_CRM_Selling_Price_Btl_PRS_WS__c = 1,
                           ASI_CRM_Duty_Per_Bottle__c = 1,
                           ASI_CRM_FOB_Per_Bottle__c = 1,
                           ASI_CRM_Handling_Cost_Per_Bottle__c = 1,
                           ASI_CRM_IGC_Cost_Per_case__c = 1,
                           ASI_CRM_SG_Unit_Price__c = 1
                       );
            
            if(isCommit) {                                      
                insert freeGoodsItem;
            }
        }
        
        public freeGoodsItemData(boolean isCommit, ASI_FOC_Free_Goods_Request__c freeP, ASI_MFM_SKU_Code__c skuCode, string type, integer quantity) {
           
           freeGoodsItem = new ASI_FOC_Request_Item__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                           ASI_FOC_Request_Order__c = freeP.id,
                           ASI_FOC_SKU__c = skuCode.id,
                           ASI_CRM_SG_FOC_Type__c = type,
                           ASI_FOC_Request_Quantity_Bottle__c = quantity,
                           ASI_FOC_Actual_Quantity_Bottle__c = quantity+1,
                           ASI_CRM_Adjustment_Remarks__c = 'testingAdjustmentRemark8CharactersMin',
                           ASI_CRM_Selling_Price_Btl_PRS_WS__c = 1,
                           ASI_CRM_Duty_Per_Bottle__c = 1,
                           ASI_CRM_FOB_Per_Bottle__c = 1,
                           ASI_CRM_Handling_Cost_Per_Bottle__c = 1,
                           ASI_CRM_IGC_Cost_Per_case__c = 1,
                           ASI_CRM_SG_Unit_Price__c = 1
                       );
            
            if(isCommit) {                                      
                insert freeGoodsItem;
            }
        }
        
    }
    
    public class offtakeData {
        
        public ASI_TH_CRM_Actual_Offtake__c offtake {get;set;}
        
        public offtakeData (boolean isCommit, String customRecordtype, ID contractID, ID customerID, ID skuID) {
            
            offtake = new ASI_TH_CRM_Actual_Offtake__c(
                         recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__c'+customRecordtype),
                         ASI_TH_CRM_Quantity__c = 100,
                         ASI_TH_CRM_Offtake_G_L_Date__c = date.today(),
                         ASI_CRM_SG_Customer__c = customerID,
                         ASI_CRM_Contract__c = contractID,
                         ASI_CRM_SKU__c = skuID,
                         ASI_TH_CRM_Actual_Offtake_External_ID__c = String.valueOf(businessRegistrationNumber)
            
                    );
                    
            businessRegistrationNumber += 1;
                    
            if(isCommit) {
                insert offtake;
            }
        }
    }
    
    public class salesOrderData {
        
        public ASI_KOR_Sales_Order_Request__c salesOrder {get;set;}
        
        /*[WL 2.0] BEGIN*/
        public salesOrderData (boolean isCommit, String customRecordtype, ASI_CRM_AccountsAdditionalField__c customer) {
            
            salesOrder = new ASI_KOR_Sales_Order_Request__c(
                         recordtypeid = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Request__c'+customRecordtype),
                         ASI_CRM_SG_Order_Date__c = date.today(),
                         ASI_CRM_SG_Customer__c = customer.Id,
                         ASI_CRM_SG_Ship_To__c = customer.Id
                    );
                    
            if(isCommit) {
                insert salesOrder;
            }            
        }
        /*[WL 2.0] END*/
        
        public salesOrderData (boolean isCommit, String customRecordtype) {
            
            salesOrder = new ASI_KOR_Sales_Order_Request__c(
                         recordtypeid = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Request__c'+customRecordtype),
                         ASI_CRM_SG_Order_Date__c = date.today()
                    );
                    
            if(isCommit) {
                insert salesOrder;
            }            
        }
        
    }
    
    public class salesOrderItemData {
        
        public ASI_KOR_Sales_Order_Transaction__c salesOrderItem {get;set;}
        
        public salesOrderItemData (boolean isCommit, String customRecordtype, ASI_KOR_Sales_Order_Request__c salesOrderP) {
            
            salesOrderItem = new ASI_KOR_Sales_Order_Transaction__c(
                         recordtypeid = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__c'+customRecordtype),
                         ASI_KOR_Sales_Order_Request__c = salesOrderP.id, 
                         ASI_CRM_SG_Request_Quantity_Bottle__c = 1
                    );
                    
            if(isCommit) {
                insert salesOrderItem;
            }
            
        }
        
        public salesOrderItemData (boolean isCommit, String customRecordtype, ASI_KOR_Sales_Order_Request__c salesOrderP, Id skuId) {
            
            salesOrderItem = new ASI_KOR_Sales_Order_Transaction__c(
                         recordtypeid = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__c'+customRecordtype),
                         ASI_KOR_Sales_Order_Request__c = salesOrderP.id, 
                         ASI_CRM_SG_SKU__c = skuId,
                         ASI_CRM_SG_Request_Quantity_Bottle__c = 1
                    );
                    
            if(isCommit) {
                insert salesOrderItem;
            }
            
        }
        
    }
    
    
    public class invoiceData {
        public ASI_CRM_Invoice__c invoice {get;set;}
        
        public invoiceData(boolean isCommit, ASI_CRM_AccountsAdditionalField__c customerC) {
            
            invoice = new ASI_CRM_Invoice__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Invoice__cASI_CRM_SG_Invoice'),
                                                      ASI_CRM_Customer__c = customerC.id,
                                                      ASI_CRM_G_L_Date__c = date.today().adddays(-1),
                                                      ASI_CRM_Invoice_Date__c = date.today().adddays(-7)
                                                  );
            
            if(isCommit) {                                      
                insert invoice;
            }
        }
        
    }
    
    public class invoiceLineItemData {
        public ASI_CRM_Invoice_Line_Item__c invoiceLineItem {get;set;}
        
        public invoiceLineItemData(boolean isCommit, ASI_CRM_Invoice__c invoice) {
            
            invoiceLineItem = new ASI_CRM_Invoice_Line_Item__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Invoice_Line_Item__cASI_CRM_SG_CRM_Invoice_Line_Item'),
                                                      ASI_CRM_Invoice__c = invoice.id,
                                                      ASI_CRM_Amount__c = 1000,
                                                      ASI_CRM_Account_Number__c = '7771PT01SG.3010'
                                                  );
            
            if(isCommit) {                                      
                insert invoiceLineItem;
            }
        }
        
    }
    
    public class receiptData {
        public ASI_CRM_Receipt__c receipt {get;set;}
        
        public receiptData(boolean isCommit, ASI_CRM_AccountsAdditionalField__c customerC) {
            
            receipt = new ASI_CRM_Receipt__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Receipt__cASI_CRM_SG_Receipt'),
                                                      ASI_CRM_Customer__c = customerC.id,
                                                      ASI_CRM_G_L_Date__c = date.today().adddays(-1),
                                                      ASI_CRM_Receipt_Date__c = date.today().adddays(-1)
                                                  );
            
            if(isCommit) {                                      
                insert receipt;
            }
        }
        
    }
    
    public class receiptLineItemData {
        public ASI_CRM_Receipt_Line_Item__c receiptLineItem {get;set;}
        
        public receiptLineItemData(boolean isCommit, ASI_CRM_Receipt__c receipt, ASI_CRM_Invoice__c invoice) {
            
            receiptLineItem = new ASI_CRM_Receipt_Line_Item__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Receipt_Line_Item__cASI_CRM_SG_Receipt_Line_Item'),
                                                      ASI_CRM_Receipt__c = receipt.id,
                                                      ASI_CRM_Invoice__c = invoice.id,
                                                      ASI_CRM_Amount__c = -1000
                                                  );
            
            if(isCommit) {                                      
                insert receiptLineItem;
            }
        }
        
    }
    
    public class creditDebitNoteData {
        public ASI_CRM_Credit_Debit_Note__c creditDebitNote {get;set;}
        
        public creditDebitNoteData(boolean isCommit, ASI_TH_CRM_Contract__c contract, ASI_CRM_AccountsAdditionalField__c customerC, ASI_CRM_AccountsAdditionalField__c wholesaler) {
            
            creditDebitNote = new ASI_CRM_Credit_Debit_Note__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Prompt_Payment_Credit_Note'),
                                                      //ASI_CRM_Contract__c = contract.id,
                                                      //ASI_CRM_Outlet__c = customerC.id,
                                                      ASI_CRM_Wholesaler__c = wholesaler.id
                                                  );
            
            if(isCommit) {                                      
                insert creditDebitNote;
            }
        }
        
    }
    
    public class creditDebitNoteLineItemData {
        public ASI_CRM_Credit_Debit_Note_Line_Item__c creditDebitNoteLineItem {get;set;}
        
        public creditDebitNoteLineItemData(boolean isCommit, ASI_CRM_Credit_Debit_Note__c creditDebitNote, ASI_MFM_Sub_brand__c subBrand) {
            
            creditDebitNoteLineItem = new ASI_CRM_Credit_Debit_Note_Line_Item__c (
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note_Line_Item__cASI_CRM_SG_Prompt_Payment_Credit_Note_Line_Item'),
                                                      ASI_CRM_Credit_Debit_Note__c = creditDebitNote.id,
                                                      ASI_CRM_Sub_brand__c = subBrand.id,
                                                      ASI_CRM_Type__c = 'Prompt Payment',
                                                      ASI_CRM_Amount__c = 1000,
                                                      ASI_CRM_Actual_Amount__c = 1000
                                                  );
            
            if(isCommit) {                                      
                insert creditDebitNoteLineItem;
            }
        }
        
    }
    

}