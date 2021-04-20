@isTest
public class EUR_CRM_DE_Test_InvoiceTrackerExt{
    private static String mechanicTypeName1 = 'Pouring Refund';
    private static String mechanicTypeName2 = 'POS WKZ';
    private static String mechanicTypeName3 = 'POS Material';
    private static String mechanicTypeName4 = 'Others';
    private static String mechanicTypeName5 = 'Drinks Menu';
    private static String mechanicTypeName6 = 'WKZ Fix Amount';
    private static String mechanicTypeName7 = 'Visibility/ Branding';
    private static String mechanicTypeName8 = 'Napkins';

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Contract_Focus_Brand__c contractFocusBrand;
    private static EUR_CRM_Quality__c brandQuality;
    
    private static EUR_CRM_Mechanic_Type__c mechType1;
    private static EUR_CRM_Mechanic_Type__c mechType2;
    private static EUR_CRM_Mechanic_Type__c mechType3;
    private static EUR_CRM_Mechanic_Type__c mechType4;
    private static EUR_CRM_Mechanic_Type__c mechType5;
    private static EUR_CRM_Mechanic_Type__c mechType6;
    private static EUR_CRM_Mechanic_Type__c mechType7;
    private static EUR_CRM_Mechanic_Type__c mechType8;
    
    private static EUR_CRM_Contract_Activity_Item__c contractActivity1;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity2;
    
    private static EUR_CRM_Contract_Product_Item__c productItem1;
    private static EUR_CRM_Contract_Product_Item__c productItem2;
    
    // Edited By Jay 20160927 >>
    // 
    private static EUR_CRM_Contract_Activity_Item__c contractActivity3;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity4;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity5;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity6;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity7;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity8;
    
    private static EUR_CRM_Contract_Product_Item__c productItem3;
    private static EUR_CRM_Contract_Product_Item__c productItem4;
    private static EUR_CRM_Contract_Product_Item__c productItem5;
    private static EUR_CRM_Contract_Product_Item__c productItem6;
    private static EUR_CRM_Contract_Product_Item__c productItem7;
    private static EUR_CRM_Contract_Product_Item__c productItem8;
    
    // Edited By Jay 20160927 <<
    
    
    private static EUR_CRM_CIR_Contract_Activity_Line_Item__c cirLine;
    private static EUR_CRM_CIR_Invoice_Entry__c CIREntry;
    
    public static void dataInsert1(){
        //Create Wine Spirit
        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, EUR_CRM_DE_TestClassUtilityHelper.DE_WINE_SPIRIT_RECORD_TYPE, 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);
    
        //Create category
        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CATEGORY_RECORD_TYPE, 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);
            
        //Create Brand
        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);
            
        //Create BQ
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'Cocktail', 'TEST-0001', brand.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);
            
        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();
        //Create Mechanic Type
        mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName1)[0];
        mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType1.EUR_CRM_Has_Lump_Sum__c = false;
        mechType1.EUR_CRM_Has_Per_BQ__c = true;
        mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
        mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
        mechType1.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName1;
        mechTypeList.add(mechType1);
        
        //Create Mechanic Type
        mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(2, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName2)[0];
        mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType2.EUR_CRM_Has_Lump_Sum__c = true;
        mechType2.EUR_CRM_Has_Per_BQ__c = true;
        mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType2.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName2;
        mechTypeList.add(mechType2);

          mechType3 = EUR_CRM_TestClassUtilityHelper.createMechType(3, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName3)[0];
        mechType3.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType3.EUR_CRM_Has_Lump_Sum__c = true;
        mechType3.EUR_CRM_Has_Per_BQ__c = true;
        mechType3.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType3.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType3.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType3.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName3;
        mechTypeList.add(mechType3);

          mechType4 = EUR_CRM_TestClassUtilityHelper.createMechType(4, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName4)[0];
        mechType4.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType4.EUR_CRM_Has_Lump_Sum__c = true;
        mechType4.EUR_CRM_Has_Per_BQ__c = true;
        mechType4.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType4.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType4.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType4.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName4;
        mechTypeList.add(mechType4);

          mechType5 = EUR_CRM_TestClassUtilityHelper.createMechType(5, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName5)[0];
        mechType5.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType5.EUR_CRM_Has_Lump_Sum__c = true;
        mechType5.EUR_CRM_Has_Per_BQ__c = true;
        mechType5.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType5.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType5.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType5.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName5;
        mechTypeList.add(mechType5);

          mechType6 = EUR_CRM_TestClassUtilityHelper.createMechType(6, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName6)[0];
        mechType6.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType6.EUR_CRM_Has_Lump_Sum__c = true;
        mechType6.EUR_CRM_Has_Per_BQ__c = true;
        mechType6.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType6.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType6.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType6.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName6;
        mechTypeList.add(mechType6);

          mechType7 = EUR_CRM_TestClassUtilityHelper.createMechType(7, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName7)[0];
        mechType7.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType7.EUR_CRM_Has_Lump_Sum__c = true;
        mechType7.EUR_CRM_Has_Per_BQ__c = true;
        mechType7.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType7.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType7.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType7.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName7;
        mechTypeList.add(mechType7);

          mechType8 = EUR_CRM_TestClassUtilityHelper.createMechType(8, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName8)[0];
        mechType8.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType8.EUR_CRM_Has_Lump_Sum__c = true;
        mechType8.EUR_CRM_Has_Per_BQ__c = true;
        mechType8.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType8.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType8.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType8.EUR_CRM_Mechanic_Type_Name_English__c = mechanicTypeName8;
        mechTypeList.add(mechType8);
        insert mechTypeList;

        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract;

         // Create contract Focus Brand
        contractFocusBrand  = EUR_CRM_DE_TestClassUtilityHelper.createContractFocusBrandItem(EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_FOCUS_BRAND_RECORD_TYPE, contract.Id, brand.Id);
        
        //Create Contract Activity1
        contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
        contractActivity1.EUR_CRM_Name__c = 'Test1';
        insert contractActivity1;
        
        //Create Contract Activity 2
        contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
        contractActivity2.EUR_CRM_Name__c = 'Test2';
        insert contractActivity2;
        /*
        contractActivity3 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType3.Id);
        contractActivity3.EUR_CRM_Name__c = 'Test3';
        insert contractActivity3;
        
        contractActivity4 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType4.Id);
        contractActivity4.EUR_CRM_Name__c = 'Test4';
        insert contractActivity4;
        
        contractActivity5 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType5.Id);
        contractActivity5.EUR_CRM_Name__c = 'Test5';
        insert contractActivity5;
        
        contractActivity6 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType6.Id);
        contractActivity6.EUR_CRM_Name__c = 'Test6';
        insert contractActivity6;
        
        contractActivity7 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType7.Id);
        contractActivity7.EUR_CRM_Name__c = 'Test2';
        insert contractActivity7;
        
        contractActivity8 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType8.Id);
        contractActivity8.EUR_CRM_Name__c = 'Test8';
        insert contractActivity8;*/
        
        //Create Contract Product Item
        productItem1 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity1.Id, brand); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        productItem2 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity2.Id, brandQuality); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        
        insert productItem1;
        insert productItem2;
        
        //Edited By Jay 20160927
        //
        /*productItem3 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity3.Id, brand); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        productItem4 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity4.Id, brandQuality); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        productItem5 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity5.Id, brand); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        productItem6 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity6.Id, brandQuality); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        productItem7 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity7.Id, brand); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        productItem8 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity8.Id, brandQuality); //Edited By Jay 20160927 : Switch betweenm two line 1 & 2
        
        insert productItem3;
        insert productItem4;
        insert productItem5;
        insert productItem6;
        insert productItem7;
        insert productItem8;*/
        //Edited By Jay 20160927
        
        
        // Create CIR-Contract Activity Line Items
        cirLine = new EUR_CRM_CIR_Contract_Activity_Line_Item__c();
        cirLine.EUR_CRM_Brand__c =  brand.Id;
        cirLine.EUR_CRM_Brand_Quality__c =  brandQuality.Id;
        cirLine.EUR_CRM_Contract_Activity_Item__c = contractActivity1.id;
        cirLine.EUR_CRM_Contract_Product_Item__c =  productItem2.Id;
        cirLine.EUR_CRM_Status__c = 'Open';
        insert cirLine;

        // EUR_CRM_CIR_Invoice_Entry__c
        CIREntry = new EUR_CRM_CIR_Invoice_Entry__c();
        CIREntry.EUR_CRM_Amount__c = 10;
        CIREntry.EUR_CRM_CIR_Contract_Activity_Line_Item__c = cirLine.Id;
        insert CIREntry;
    }
    
    static testMethod void test1(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            test.startTest();
            //Create account
            EUR_CRM_DE_TestClassUtilityHelper.initData();
            accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
            test.stopTest();
            
            
            dataInsert1();
            
            ApexPages.CurrentPage().getParameters().put('rowIndex','1');

            
            ApexPages.StandardController stdController = new ApexPages.StandardController(contract);
            EUR_CRM_DE_InvoiceTrackerExt contractCtrl = new EUR_CRM_DE_InvoiceTrackerExt(stdController);
            
            
            
            contractCtrl.createCIRSHeaders();
            contractCtrl.cirActivityId = cirLine.Id;
            contractCtrl.addNewInvoice();
            contractCtrl.save();
            contractCtrl.cancel();
            contractCtrl.retValue();
            contractCtrl.removeInvoice();
            contractCtrl.isFocusBrand = true;
            contractCtrl.isPouring= true;
            contractCtrl.isPouringRefund= true;
            contractCtrl.isWKZFixAmount= true;
            contractCtrl.isDrinksMenu= true;
            contractCtrl.isEvent= true;
            contractCtrl.isVisilibility= true;
            contractCtrl.isPOSMaterial= true;
            contractCtrl.isPOSWKZ= true;
            contractCtrl.isNapkins= true;
            contractCtrl.isTraining= true;
            contractCtrl.isOthers= true;
            contractCtrl.wkzFixAmountCIRActivity = cirLine;
            contractCtrl.drinksMenuCIRActivity= cirLine;
            contractCtrl.posMaterialCIRActivity= cirLine;
            contractCtrl.posWKZCIRActivity= cirLine;
            contractCtrl.othersCIRActivity = cirLine;
            contractCtrl.visibilityBrandingCIRActivity= cirLine;
            contractCtrl.productId = '';
            contractCtrl.pouringRefundId='';
            contractCtrl.rowIndex='';
            contractCtrl.napkinsCIRActivity = cirLine;
            String a = contractCtrl.EVENTS;
            contractCtrl.populateContractActivityCIRWrapperList();
        }
    }
}