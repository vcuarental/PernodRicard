/*********************************************************************************
 * Name: ASI_CRM_SG_CreditNote_TriggerClass_Test
 * Description: Test Class for ASI_CRM_SG_Submit_Credit_Note_ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/12/2020       Wilken Lee              [WL 1.0] Add code coverage for ASI_CRM_SG_Submit_Credit_Note_ctrl
*/
@isTest
public class ASI_CRM_SG_CreditNote_TriggerClass_Test {
    @testSetup
    public static void testSetupData(){
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        Account testAccount = new Account(Name = 'TestWholesaler', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'));
        insert testAccount;
        
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData customerD = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(false, 'TestCustomer');
        customerD.customer.ASI_CRM_Active__c = true;
        customerD.customer.ASI_CRM_CN_JDE_Code__c   = '505145';
        insert customerD.customer;
        ASI_CRM_Group_Outlet_Type__c groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
            ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
            ASI_CRM_SG_Name__c='High Energy Bar'
            
        );
        insert groupOutletType;
        ASI_CRM_AccountsAdditionalField__c  outlet = new ASI_CRM_AccountsAdditionalField__c (
            name = 'customer Test',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
            ASI_CRM_IsParentAccount__c = true,
            ASI_CRM_MY_CustomerCode__c = '123test',
            ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
            ASI_CRM_CN_Parent_Outlet__c  = customerD.customer.Id,
            //ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber),
            ASI_CRM_Active__c = true
        );
        insert outlet;
        Id soHistoryRecTypeId = Schema.SObjectType.ASI_HK_CRM_Sales_Order_History__c
            .getRecordTypeInfosByName()
            .get('SG CRM Sales Order History').getRecordTypeId();
        ASI_MFM_Item_Group__c tmpItemGroup = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_SG_Item_Group')
                                                                       , Name = 'TestItemGroup'
                                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                       , ASI_CRM_CN_Not_In_Use__c = FALSE
                                                                       , ASI_CRM_CN_Gift_Set_C__c = FALSE
                                                                       , ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
                                                                       , OwnerID = UserInfo.getUserId()
                                                                      );
        insert tmpItemGroup;
        ASI_MFM_Item_Group__c tmpItemGroup2 = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_SG_Item_Group')
                                                                        , Name = 'TestItemGroup2'
                                                                        , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode2'
                                                                        , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup2'
                                                                        , ASI_CRM_CN_Not_In_Use__c = FALSE
                                                                        , ASI_CRM_CN_Gift_Set_C__c = FALSE
                                                                        , ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
                                                                        , OwnerID = UserInfo.getUserId()
                                                                       );
        insert tmpItemGroup2;
        List<ASI_CRM_Price_And_Discount__c> tmpPnDList = new List<ASI_CRM_Price_And_Discount__c>();
        
        ASI_CRM_Price_And_Discount__c tmpPnDBottle = new ASI_CRM_Price_And_Discount__c(OwnerId =  UserInfo.getUserId()
                                                                                       , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_SG_Bottle_Rebate')
                                                                                       , ASI_CRM_Customer__c = customerD.customer.id
                                                                                       , ASI_CRM_Status__c = 'Open'
                                                                                       , ASI_CRM_SG_Product_Grouping__c =  tmpItemGroup.Id                              
                                                                                      );
        tmpPnDList.add(tmpPnDBottle);
        ASI_CRM_Price_And_Discount__c tmpPnDPortfolio = new ASI_CRM_Price_And_Discount__c(OwnerId =  UserInfo.getUserId()
                                                                                          , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_SG_Bottle_Rebate')
                                                                                          , ASI_CRM_Customer__c = customerD.customer.id
                                                                                          , ASI_CRM_Status__c = 'Open'
                                                                                          , ASI_CRM_SG_Product_Grouping__c =  tmpItemGroup.Id
                                                                                          ,ASI_CRM_SGComplimentary_Product_Grouping__c = tmpItemGroup2.Id                                 
                                                                                         );
        tmpPnDList.add(tmpPnDPortfolio);
        ASI_CRM_Price_And_Discount__c tmpPnDFWO = new ASI_CRM_Price_And_Discount__c(OwnerId =  UserInfo.getUserId()
                                                                                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_SG_First_Week_Order_Rebate')
                                                                                    , ASI_CRM_Customer__c = customerD.customer.id
                                                                                    , ASI_CRM_Status__c = 'Open'
                                                                                    , ASI_CRM_SG_Product_Grouping__c =  tmpItemGroup.Id                              
                                                                                   );
        tmpPnDList.add(tmpPnDFWO);
        
        ASI_CRM_Price_And_Discount__c tmpPnDOOM = new ASI_CRM_Price_And_Discount__c(OwnerId =  UserInfo.getUserId()
                                                                                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_SG_Open_Outlet_Marketing_Fund')
                                                                                    , ASI_CRM_Customer__c = customerD.customer.id
                                                                                    , ASI_CRM_Status__c = 'Open'
                                                                                    , ASI_CRM_SG_Product_Grouping__c =  tmpItemGroup.Id                              
                                                                                   );
        tmpPnDList.add(tmpPnDOOM);
        insert tmpPnDList;
        /*       ASI_CRM_Price_And_Discount_Detail__c detail = new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD.id 
, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
, ASI_CRM_Item_Group_Description__c = tmpItemGroup.Id
, ASI_CRM_Total_Estimated_Vol_BT__c = 1
, ASI_CRM_New_Price_BT_with_VAT__c = 1
, ASI_CRM_Current_T1_Price_BT_with_VAT__c = 3

);
insert detail;
*/
        ASI_HK_CRM_Sales_Order_History__c history = new ASI_HK_CRM_Sales_Order_History__c(
            RecordTypeId = soHistoryRecTypeId,
            ASI_HK_CRM_Account_PA__c = testAccount.Id,
            ASI_CRM_Sold_To__c = customerD.customer.Id,
            ASI_CRM_AccountAdditionalField__c = outlet.Id,
            ASI_HK_CRM_Order_Type__c = 'Singapore DF & DP Sales Order - SO',
            ASI_HK_CRM_Order_No__c = '123456789',
            ASI_HK_CRM_JDE_Invoice_No__c = '123456789',
            ASI_CRM_G_L_Date__c = Date.newInstance(2020, 08, 10)
        );
        insert history;
        
        Id soHistoryDetailRecTypeId = Schema.SObjectType.ASI_HK_CRM_Sales_Order_History_Detail__c
            .getRecordTypeInfosByName()
            .get('SG CRM Sales Order History Detail').getRecordTypeId();
        
        List<ASI_HK_CRM_Sales_Order_History_Detail__c> historyDetailList = new List<ASI_HK_CRM_Sales_Order_History_Detail__c>();
        
        ASI_HK_CRM_Sales_Order_History_Detail__c historyDetail1 = new ASI_HK_CRM_Sales_Order_History_Detail__c(
            ASI_HK_CRM_Sales_Order_History__c = history.Id,
            ASI_HK_CRM_Product_SKU__c = skuList.get(0).Id,
            ASI_CRM_SG_Credit_Note_Status__c = 'Required',
            ASI_HK_CRM_Quantity_in_Bottles__c = 20.0,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail'),
            ASI_CRM_SG_FWO_Rebate__c = tmpPnDFWO.Id,ASI_CRM_SG_Bottle_Rebate__c = tmpPnDBottle.Id, ASI_CRM_SG_Portfolio_Rebate__c = tmpPnDPortfolio.Id
            
            
        );
        historyDetailList.add(historyDetail1);
        
        ASI_HK_CRM_Sales_Order_History_Detail__c historyDetail2 = new ASI_HK_CRM_Sales_Order_History_Detail__c(
            ASI_HK_CRM_Sales_Order_History__c = history.Id,
            ASI_HK_CRM_Product_SKU__c = skuList.get(1).Id,
            ASI_CRM_SG_Credit_Note_Status__c = 'Required',
            ASI_HK_CRM_Quantity_in_Bottles__c = 20.0,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail'),
            ASI_CRM_SG_FWO_Rebate__c = tmpPnDFWO.Id,ASI_CRM_SG_Bottle_Rebate__c = tmpPnDBottle.Id, ASI_CRM_SG_Portfolio_Rebate__c = tmpPnDPortfolio.Id                                                       
        );
        historyDetailList.add(historyDetail2);
        
        
        insert historyDetailList;
        
        historyDetail1.ASI_HK_CRM_Quantity_in_Bottles__c = 20;
        update historyDetail1;
        
    }
    public static testMethod void testCreditFWO(){
        String FWORtypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_FWO_Period').getRecordTypeId();
        test.startTest();
       ASI_CRM_Credit_Debit_Note__c creditNote = new ASI_CRM_Credit_Debit_Note__c(ASI_CRM_SG_FWO_Start_Date__c = Date.newInstance(2020, 08, 01), ASI_CRM_SG_FWO_End_Date__c = Date.newInstance(2020, 08, 30) ,ASI_CRM_SG_Rebate_Type__c = 'FWO', RecordTypeId =FWORtypeId );
       insert creditNote;
        try{
            insert new ASI_CRM_Credit_Debit_Note__c(ASI_CRM_SG_FWO_Start_Date__c = Date.newInstance(2020, 09, 01), ASI_CRM_SG_FWO_End_Date__c = Date.newInstance(2020, 09, 30) ,ASI_CRM_SG_Rebate_Type__c = 'FWO', RecordTypeId =FWORtypeId );
        }Catch(Exception e){
            
        }
         ASI_CRM_SG_CreditNote_ButtonController.deleteFWO(creditNote.Id);
        test.stopTest();
    }
    
    public static testMethod void testCreditBottle(){
        String FWORtypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_FWO_Period').getRecordTypeId();
        test.startTest();
        ASI_CRM_Credit_Debit_Note__c creditNote =  new ASI_CRM_Credit_Debit_Note__c(ASI_CRM_SG_FWO_Start_Date__c = Date.newInstance(2020, 08, 01), ASI_CRM_SG_FWO_End_Date__c = Date.newInstance(2020, 08, 30) ,ASI_CRM_SG_Rebate_Type__c = 'Bottle', RecordTypeId =FWORtypeId );
        insert creditNote;
        ASI_CRM_SG_CreditNote_ButtonController.deleteFWO(creditNote.Id);
        test.stopTest();
    }
    public static testMethod void testCreditPortfolio(){
        String FWORtypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_FWO_Period').getRecordTypeId();
        test.startTest();
        insert new ASI_CRM_Credit_Debit_Note__c(ASI_CRM_SG_FWO_Start_Date__c = Date.newInstance(2020, 08, 01), ASI_CRM_SG_FWO_End_Date__c = Date.newInstance(2020, 08, 30) ,ASI_CRM_SG_Rebate_Type__c = 'Portfolio', RecordTypeId =FWORtypeId );
        test.stopTest();
    }
    
     public static testMethod void testRecalculateAndSubmit(){
        String FWORtypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_FWO_Period').getRecordTypeId();
        test.startTest();
        ASI_CRM_Credit_Debit_Note__c creditNote =  new ASI_CRM_Credit_Debit_Note__c(ASI_CRM_SG_FWO_Start_Date__c = Date.newInstance(2020, 08, 01), ASI_CRM_SG_FWO_End_Date__c = Date.newInstance(2020, 08, 30) ,ASI_CRM_SG_Rebate_Type__c = 'Portfolio', RecordTypeId =FWORtypeId );
        insert creditNote;
		
		/*[WL 1.0] BEGIN*/
		String ManualRtypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Manual_Credit_Note').getRecordTypeId();
		ASI_CRM_Credit_Debit_Note__c manualCreditNote =  new ASI_CRM_Credit_Debit_Note__c(RecordTypeId = ManualRtypeId);
        try {
			insert manualCreditNote;
			ASI_CRM_SG_Submit_Credit_Note_ctrl.validateSubmit(manualCreditNote.Id);
		}
		catch(Exception e){}
		/*[WL 1.0] END*/
		
         ASI_CRM_SG_CreditNote_ButtonController.reCalculate([Select Id from ASI_CRM_Credit_Debit_Note__c where recordType.developerName = 'ASI_CRM_SG_Wholesaler_Credit_Note' limit 1].Id);
        ASI_CRM_Credit_Debit_Note__c creditNoteWS = [Select Id from ASI_CRM_Credit_Debit_Note__c where recordType.developerName = 'ASI_CRM_SG_Wholesaler_Credit_Note' limit 1];
         ASI_CRM_SG_Submit_Credit_Note_ctrl.validateSubmit(creditNoteWS.Id);
         ContentVersion cv = new ContentVersion();
        cv.Title = 'Test_ContentVersion';
        cv.PathOnClient = 'Test_ContentVersion';
        cv.VersionData = Blob.valueOf('Test_ContentVersion');
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = creditNoteWS.Id;
        cdl.ShareType= 'V';
        insert cdl;
        ASI_CRM_SG_Submit_Credit_Note_ctrl.validateSubmit(creditNoteWS.Id);  
         ASI_CRM_SG_Submit_Credit_Note_ctrl.validateSubmit(creditNote.Id);  
         test.stopTest();
    }
    
    public static testMethod void deleteRebate(){
        String FWORtypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_FWO_Period').getRecordTypeId();
        test.startTest();
        ASI_CRM_Credit_Debit_Note__c creditNote =  new ASI_CRM_Credit_Debit_Note__c(ASI_CRM_SG_FWO_Start_Date__c = Date.newInstance(2020, 08, 01), ASI_CRM_SG_FWO_End_Date__c = Date.newInstance(2020, 08, 30) ,ASI_CRM_SG_Rebate_Type__c = 'Portfolio', RecordTypeId =FWORtypeId );
        insert creditNote;
      /*  List<ASI_HK_CRM_Sales_Order_History_Detail__c> sohDetailList = [Select Id,ASI_CRM_SG_Credit_Note_Status__c from ASI_HK_CRM_Sales_Order_History_Detail__c];
        for(ASI_HK_CRM_Sales_Order_History_Detail__c sohDetail : sohDetailList){
            sohDetail.ASI_CRM_SG_Credit_Note_Status__c = 'Issued';
        }
        update sohDetailList;*/
         ASI_CRM_SG_CreditNote_ButtonController.deleteFWO(creditNote.Id);
         test.stopTest();
    }
    
    public static testMethod void testOOM(){
        
        ASI_CRM_AccountsAdditionalField__c wholeSaler = [Select Id from ASI_CRM_AccountsAdditionalField__c where recordType.DeveloperName = 'ASI_CRM_SG_Wholesaler' limit 1];
        
        ASI_CRM_Wine_Spirits__c wineSpirit = new ASI_CRM_Wine_Spirits__c();
        wineSpirit.RecordTypeId = Schema.SObjectType.ASI_CRM_Wine_Spirits__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wine_Spirit').getRecordTypeId();
        wineSpirit.ASI_CRM_SG_Wine_Spirits_Code__c = 'Test1';
        insert wineSpirit;
        ASI_HK_CRM_Product_Category__c ProductCategory = new ASI_HK_CRM_Product_Category__c();
        ProductCategory.RecordTypeId = Schema.SObjectType.ASI_HK_CRM_Product_Category__c.getRecordTypeInfosByDeveloperName().get('ASI_SG_CRM_Product_Category').getRecordTypeId();
        ProductCategory.ASI_CRM_SG_Wine_Spirits__c = wineSpirit.Id;
        ProductCategory.ASI_HK_CRM_Product_Category__c= 'ExtId1';
        insert ProductCategory;
        ASI_TH_CRM_Category__c category = new ASI_TH_CRM_Category__c();
        category.ASI_TH_CRM_Category_External_ID__c = 'ExtId1';
        insert category;
        ASI_TH_CRM_Sub_category__c subCategory = new ASI_TH_CRM_Sub_category__c();
        subCategory.ASI_TH_CRM_Category__c = category.Id;
        subCategory.ASI_CRM_CN_Product_Category__c = ProductCategory.Id;
        subCategory.ASI_TH_CRM_Sub_category_EXID__c = 'ExtId1';
        ASI_CRM_CN_Brand_Group__c brandGroup = new ASI_CRM_CN_Brand_Group__c();
        brandGroup.Name = 'Test Brand Group';
        insert brandGroup;
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c();
        brand.RecordTypeId = Schema.SObjectType.ASI_MFM_Brand__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Brand').getRecordTypeId();
        brand.Name = 'Test Brand';
        brand.ASI_CRM_CN_Brand_Group_c__c= brandGroup.Id;
        brand.ASI_HK_CRM_Product_Category__c = ProductCategory.Id;
        brand.ASI_TH_CRM_Sub_category__c = subCategory.Id;
        insert brand;
        ASI_CRM_Sub_Brand_Grade__c subBrandGrade = new ASI_CRM_Sub_Brand_Grade__c();
        subBrandGrade.Name = 'Test Brand Grade';
        insert subBrandGrade;
        ASI_CRM_Sub_Brand_Group__c subBrandGroup = new ASI_CRM_Sub_Brand_Group__c();
        subBrandGroup.Name = 'Test Brand Group';
        insert subBrandGroup;
        
        ASI_MFM_Sub_brand__c subBrand =  new ASI_MFM_Sub_brand__c (
            Name = 'Test Sub Brand name',
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c= 1,
            ASI_CRM_CN_Sub_brand_Grade__c=subBrandGrade.Id,
            ASI_CRM_CN_SubBrand_Group_c__c=subBrandGroup.Id,
            RecordTypeId = Schema.SObjectType.ASI_MFM_Sub_brand__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Sub_brand').getRecordTypeId());
        insert subBrand;
        List<ASI_MFM_SKU_Code__c> skus = [Select Id from ASI_MFM_SKU_Code__c];
        for(ASI_MFM_SKU_Code__c sku : skus){
            sku.ASI_MFM_Sub_brand__c = subBrand.Id;
        }
        update skus;
        ASI_TH_CRM_Actual_Offtake__c offs = new ASI_TH_CRM_Actual_Offtake__c();
        offs.ASI_CRM_Latest_Vintage__c=skus[1].Id;
        offs.ASI_TH_CRM_Sub_brand__c = subBrand.Id;
        Date myDate = Date.newInstance(2015, 1, 1);
        offs.ASI_CRM_FromWS__c = wholeSaler.Id;
        offs.ASI_CRM_SKU__c = skus[1].Id;
        offs.ASI_TH_CRM_Quantity__c = 24;
        offs.ASI_TH_CRM_Offtake_G_L_Date__c = Date.newInstance(2020, 08, 10);
        offs.ASI_CRM_SG_Credit_Note_Status__c = 'Required';
        offs.ASI_CRM_SG_OOM_Rebate__c  = [Select Id from ASI_CRM_Price_And_Discount__c where recordType.developerName = 'ASI_CRM_SG_Open_Outlet_Marketing_Fund' limit 1].Id;
        
        offs.ASI_TH_CRM_Actual_Offtake_External_ID__c = String.ValueOf(myDate) + '_' + wholeSaler.Id + '_' + skus[1].Id;
        insert offs;
        
        String FWORtypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_FWO_Period').getRecordTypeId();
        test.startTest();
        insert new ASI_CRM_Credit_Debit_Note__c(ASI_CRM_SG_FWO_Start_Date__c = Date.newInstance(2020, 08, 01), ASI_CRM_SG_FWO_End_Date__c = Date.newInstance(2020, 08, 30) ,ASI_CRM_SG_Rebate_Type__c = 'OOM', RecordTypeId =FWORtypeId );
        ASI_CRM_SG_CreditNote_ButtonController.deleteFWO([Select Id from ASI_CRM_Credit_Debit_Note__c where recordType.developerName = 'ASI_CRM_SG_Wholesaler_FWO_Period' limit 1].Id);
        test.stopTest();
    }
}