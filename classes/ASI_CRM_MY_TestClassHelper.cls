/*********************************************************************************
 * Name:ASI_CRM_MY_TestClassHelper
 * Description: For generating test data for ASI CRM MY
 *
 * ref : ASI_CRM_JP_TestClassHelper
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/2/2015       DW          Created
*********************************************************************************/
@isTest
public class ASI_CRM_MY_TestClassHelper {
    
    //Create custom settings: ASI_CRM_MY_Settings__c
    public static void createMYSetting(){
        List<ASI_CRM_MY_Settings__c> lstMYSetting = new List<ASI_CRM_MY_Settings__c>();
        lstMYSetting.add(new ASI_CRM_MY_Settings__c(ASI_CRM_MY_GST_Rate__c = 6.00, ASI_CRM_MY_Offtake_Cutoff_Day__c = 26, ASI_CRM_MY_Salesman_Commission__c = 0.01, ASI_CRM_MY_Visitation_Plan_Outlet_Limit__c = 5000, ASI_CRM_MY_Google_API_KEY__c = 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8'));
        insert lstMYSetting;
    }
     
    //Create Running numbers
    public static void createRunningNumbers(){
        Id RTID_MYRUNNINGNUMBER = Global_RecordTypeCache.getRTId('ASI_CRM_Running_Number__cASI_CRM_MY_Running_Number');
        
        List<ASI_CRM_Running_Number__c> lstRuningNumber = new List<ASI_CRM_Running_Number__c>();
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'Outlet', ASI_CRM_Prefix__c = '6', ASI_CRM_Number_of_Digit__c = 5, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'Outlet (CO+NCO)', RecordTypeId = RTID_MYRUNNINGNUMBER));
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'Contract', ASI_CRM_Prefix__c = '0', ASI_CRM_Number_of_Digit__c = 7, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'Contract - All', RecordTypeId = RTID_MYRUNNINGNUMBER));
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'Payment Request', ASI_CRM_Prefix__c = 'P', ASI_CRM_Number_of_Digit__c = 7, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'Payment Request', RecordTypeId = RTID_MYRUNNINGNUMBER));
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'FIS', ASI_CRM_Prefix__c = 'FIS', ASI_CRM_Number_of_Digit__c = 8, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'FIS', RecordTypeId = RTID_MYRUNNINGNUMBER));
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'Outlet-Depletion', ASI_CRM_Prefix__c = '1', ASI_CRM_Number_of_Digit__c = 7, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'For Depletion', RecordTypeId = RTID_MYRUNNINGNUMBER));
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'Outlet-ColdCall', ASI_CRM_Prefix__c = '9', ASI_CRM_Number_of_Digit__c = 5, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'For Outlet Cold Call', RecordTypeId = RTID_MYRUNNINGNUMBER));
        insert lstRuningNumber;
    }
    
    public static void testing_debug(){
        
    }
    
    //Create User
    public static User createUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='one.testing@introv.com');
        insert u1;
        return u1;
    }
	
    
    //Create User with parameter
    public static User createUser(String userId){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= userId + '@introv.com');
        insert u1;
        return u1;
    }
    
    //Create Outlet Type
    public static ASI_TH_CRM_OutletType__c createOutletType(String OTName){
        ASI_MFM_Sub_Channel__c subC = createSubChannel();
    
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = OTName, ASI_CRM_Sub_Channel__c = subC.id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_MY_Outlet_Type'));
        insert outletType;
        return outletType ;
    }
    
    //Create Province
    public static ASI_CRM_Province__c createProvince(String strBranch, String strRegion){
        ASI_CRM_Province__c province = new ASI_CRM_Province__c(ASI_CRM_MY_Branch__c = strBranch, ASI_CRM_MY_Region__c = strRegion, RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Province__cASI_CRM_MY_Province'));
        insert province;
        return province;
    }
    
    //Create City
    public static ASI_CRM_City__c createCity(String strBranch, String strRegion){
        ASI_CRM_Province__c province = ASI_CRM_MY_TestClassHelper.createProvince(strBranch, strRegion);
    
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_Province__c = province.id, RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_City__cASI_CRM_MY_City'));
        insert city;
        return city;
    }
    
    //Create Channel
    public static ASI_CRM_CN_Channel__c createChannel(){
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_MY_Channel'));
    
        insert channel;
        return channel;
    }
    
    //Create sub-Channel
    public static ASI_MFM_Sub_Channel__c createSubChannel(){
        ASI_CRM_CN_Channel__c C = createChannel();
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c = C.id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_MY_Sub_Channel'));
        
        insert subChannel;
        return subChannel;
    }
    
    //Create Outlet Image
    public static ASI_TH_CRM_OutletImage__c createOutletImage(){
        ASI_TH_CRM_OutletImage__c outletImage = new ASI_TH_CRM_OutletImage__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletImage__cASI_CRM_MY_Outlet_Image'));
        
        insert outletImage;
        return outletImage;
    }

    //Create Segmentation Criteria
    public static ASI_CRM_SegmentationCriteria__c createSegmentCacheCriteria(){
        ASI_CRM_CN_Channel__c C = createChannel();
        ASI_TH_CRM_OutletImage__c OI = createOutletImage();
    
        ASI_CRM_SegmentationCriteria__c SC = new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Channel__c = C.id, ASI_CRM_Outlet_Image__c = OI.id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_MY_Segmentation_Criteria'));
        
        insert SC;
        return SC;
    }
    
    //Create Customer
    public static ASI_CRM_AccountsAdditionalField__c createCustomer(String strName, String strRecordType){
        ASI_CRM_City__c city = createCity('B1', 'R1');
        ASI_TH_CRM_OutletType__c outletType = createOutletType('OT1');
    
        ASI_CRM_AccountsAdditionalField__c customer = 
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Eng_Name__c = strName,
                ASI_CRM_CN_Legal_Name__c = strName,
                ASI_CRM_MY_City__c = city.id,
                ASI_TH_CRM_OutletType__c = outletType.id,
                RecordTypeId = Global_RecordTypeCache.getRtId(strRecordType)
            );
        insert customer;
        return customer;
    }
    
    //Create Parent Customer
    public static ASI_CRM_AccountsAdditionalField__c createParentCustomer(String strName, String strRecordType){
        ASI_CRM_City__c city = createCity('B1', 'R1');
        ASI_TH_CRM_OutletType__c outletType = createOutletType('OT1');
    
        ASI_CRM_AccountsAdditionalField__c customer = 
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Eng_Name__c = strName,
                ASI_CRM_CN_Legal_Name__c = strName,
                ASI_CRM_MY_City__c = city.id,
                ASI_TH_CRM_OutletType__c = outletType.id,
                ASI_CRM_IsParentAccount__c = true,
                RecordTypeId = Global_RecordTypeCache.getRtId(strRecordType)
            );
        insert customer;
        return customer;
    }
    
    //Create Children Customer
    public static ASI_CRM_AccountsAdditionalField__c createChildrenCustomer(String strName, String strRecordType, ASI_CRM_AccountsAdditionalField__c customerParent){
        ASI_CRM_City__c city = createCity('B1', 'R1');
        ASI_TH_CRM_OutletType__c outletType = createOutletType('OT1');
    
        ASI_CRM_AccountsAdditionalField__c customer = 
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Eng_Name__c = strName,
                ASI_CRM_CN_Legal_Name__c = strName,
                ASI_CRM_MY_City__c = city.id,
                ASI_TH_CRM_OutletType__c = outletType.id,
                ASI_CRM_CN_Parent_Outlet__c = customerParent.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId(strRecordType)
            );
        insert customer;
        return customer;
    }
    
    //Create Brand
    public static ASI_MFM_Brand__c createBrand(){
        ASI_MFM_Brand__c brand = 
            new ASI_MFM_Brand__c(
                Name = 'BrandTEST',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_MY_Brand')
            );
        insert brand;
        return brand;
    }
    
    //Create Sub-brand
    public static ASI_MFM_Sub_brand__c createSubBrand(){
        ASI_MFM_Brand__c brand = createBrand();
        
        ASI_MFM_Sub_brand__c subBrand = 
            new ASI_MFM_Sub_brand__c(
                Name = 'subBrandTEST',
                ASI_MFM_Brand__c = brand.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand')
            );
        insert subBrand;
        return subBrand;
    }
    
    //Create Product Category
    public static ASI_HK_CRM_Product_Category__c createProductCategory(){
        ASI_HK_CRM_Product_Category__c pc = 
            new ASI_HK_CRM_Product_Category__c(
                Name = 'pcTEST',
                ASI_HK_CRM_Category_Code__c = 'cateCode',
                ASI_HK_CRM_English_Name__c = 'pcTEST',
                ASI_HK_CRM_Product_Category__c = 'MYPC',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MY_CRM_Product_Category')
            );
        insert pc;
        return pc;
    }
    
    //Create SKU
    public static ASI_MFM_SKU_Code__c createSKU(String strName){
        ASI_MFM_Sub_brand__c subBrand = createSubBrand();
        ASI_HK_CRM_Product_Category__c productCategory = createProductCategory();
        
        ASI_MFM_SKU_Code__c sku = 
            new ASI_MFM_SKU_Code__c(
                Name = strName,
                ASI_MFM_SKU_Description__c = 'skuDescription',
                ASI_MFM_Sub_brand__c = subBrand.id,
                ASI_HK_CRM_Product_Brand__c = subBrand.ASI_MFM_Brand__r.id,
                ASI_HK_CRM_Product_Category__c = productCategory.id,
                ASI_MFM_SKU_Code__c = 'BLE130',
                ASI_HK_CRM_Std_Bottle_Size__c = 300,
                ASI_HK_CRM_Packaging_Size__c = 4,
                ASI_HK_CRM_Pack_Factor__c = '4 X 300 CL 3LITR',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')
            );
        insert sku;
        return sku;
    }
    
    //Create SKU
    public static ASI_MFM_SKU_Code__c createSKU(String strName, ASI_HK_CRM_Product_Category__c productCategory){
        ASI_MFM_Sub_brand__c subBrand = createSubBrand();
        //ASI_HK_CRM_Product_Category__c productCategory = createProductCategory();
        
        ASI_MFM_SKU_Code__c sku = 
            new ASI_MFM_SKU_Code__c(
                Name = strName,
                ASI_MFM_SKU_Description__c = 'skuDescription',
                ASI_MFM_Sub_brand__c = subBrand.id,
                ASI_HK_CRM_Product_Brand__c = subBrand.ASI_MFM_Brand__r.id,
                ASI_HK_CRM_Product_Category__c = productCategory.id,
                ASI_MFM_SKU_Code__c = 'BLE130',
                ASI_HK_CRM_Std_Bottle_Size__c = 300,
                ASI_HK_CRM_Packaging_Size__c = 4,
                ASI_HK_CRM_Pack_Factor__c = '4 X 300 CL 3LITR',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')
            );
        insert sku;
        return sku;
    }
    

	//Create SKU Group
    public static ASI_CRM_SKU_Group__c createSKUGroup(ASI_MFM_SKU_Code__c sku){
        ASI_CRM_SKU_Group__c skuGroup = new ASI_CRM_SKU_Group__c ();
        skuGroup.Name = 'BLE130';
        skuGroup.ASI_CRM_Effective_SKU__c  = sku.Id;
        skuGroup.ASI_CRM_Related_SKU_Codes__c  = 'BLE130';
        skuGroup.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SKU_Group__cASI_CRM_MY_SKU_Group');
        insert skuGroup;
        return skuGroup;
    }
	    
    
    // Create contract target 
    public static ASI_CRM_ContractTarget__c createContractTarget(ASI_TH_CRM_Contract__c con, ASI_MFM_SKU_Code__c sku, Decimal targetCase){
        ASI_CRM_ContractTarget__c ct = new ASI_CRM_ContractTarget__c();
        ct.ASI_CRM_TargetCase__c = targetCase;
        ct.ASI_CRM_MinSPCase__c = 891;
        ct.ASI_CRM_Contract__c = con.id;
        ct.ASI_CRM_SKU__c = sku.id;
        ct.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget');
       	
        insert ct;
        return ct;
    }
    
	    
    // Create contract volume incentive 
    public static ASI_CRM_ContractVolumeIncentive__c createContractVolumeIncentive(ASI_TH_CRM_Contract__c con, ASI_MFM_SKU_Code__c sku){
        ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c();
        vi.ASI_CRM_Contract__c = con.id;
        vi.ASI_CRM_SKU__c = sku.id;
        vi.ASI_CRM_Description__c = 'VOL INC';
        //vi.ASI_CRM_FOC__c = 11;
        vi.ASI_CRM_SetupCode__c = 'VOLC';
        vi.ASI_CRM_MinSPBtl__c = 258;
        vi.ASI_CRM_CashInc__c = 6241;
        vi.ASI_CRM_Total__c = 6241;
        vi.ASI_CRM_JDECOA__c = '5275.';
        vi.ASI_CRM_AchievedBtl__c = 300;
        vi.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MY_VolumeIncentive');
        
        insert vi;
        return vi;
    }
    
    
    // Create Contract Sales & Staff Incentive
    public static ASI_CRM_ContractSalesStaffIncentive__c createContractSalesStaffIncentive(ASI_TH_CRM_Contract__c con, ASI_MFM_SKU_Code__c sku){
        ASI_CRM_ContractSalesStaffIncentive__c  ss = new ASI_CRM_ContractSalesStaffIncentive__c();
        ss.ASI_CRM_Contract__c = con.id;
        ss.ASI_CRM_SKU__c = sku.id;
        ss.ASI_CRM_AchievedBtl__c = 6;
        ss.ASI_CRM_FOCPRM__c = 0;
        ss.ASI_CRM_FOCWS__c = 1.5;
        ss.ASI_CRM_SetupCode__c = 'SAVR';
        ss.ASI_CRM_MinSPBtl__c = 67;
        ss.ASI_CRM_JDECOA__c = '5210.SAVR';
        ss.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_MY_SalesStaffIncentive');
        
        insert ss;
        return ss;
    }
    
    
    // Create Contract Other Incentive
    public static ASI_CRM_ContractOtherIncentive__c createContractOtherIncentive(ASI_TH_CRM_Contract__c con, ASI_MFM_SKU_Code__c sku){
        ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c();
        oi.ASI_CRM_Contract__c = con.id;
        oi.ASI_CRM_SKU__c = sku.id;
        oi.ASI_CRM_Description__c = 'OPENING';
        oi.ASI_CRM_FOC__c = 10;
        oi.ASI_CRM_SetupCode__c = 'SPON';
        oi.ASI_CRM_Type__c = 'Official Opening';
        oi.ASI_CRM_MinSPBtl__c = 265;
        oi.ASI_CRM_Total__c = 2650;
        oi.ASI_CRM_JDECOA__c = '5210.SPON';
        oi.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive');
        
        insert oi;
        return oi;
    }
    
    
    // Create Contract Other Incentive
    public static ASI_CRM_ContractOtherIncentive__c createContractOtherVolumeIncentive(ASI_TH_CRM_Contract__c con, ASI_MFM_SKU_Code__c sku){
        ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c();
        oi.ASI_CRM_Contract__c = con.id;
        oi.ASI_CRM_SKU__c = sku.id;
        oi.ASI_CRM_Description__c = 'SPONSORSHIP';
        oi.ASI_CRM_SetupCode__c = 'SSEC';
        oi.ASI_CRM_Type__c = 'Events Sponsors';
        oi.ASI_CRM_MinSPBtl__c = 624;
        oi.ASI_CRM_Total__c = 1000;
        oi.ASI_CRM_JDECOA__c = '5558.';
        oi.ASI_CRM_CashInc__c = 1000;
        oi.ASI_CRM_AchievedBtl__c = 120;
        oi.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive');
        
        insert oi;
        return oi;
    }
    
    // Create Contract Other Incentive
    public static ASI_CRM_ContractOtherIncentive__c createContractOtherVolumeIncentive(ASI_TH_CRM_Contract__c con, ASI_MFM_SKU_Code__c sku, String type){
        ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c();
        oi.ASI_CRM_Contract__c = con.id;
        oi.ASI_CRM_SKU__c = sku.id;
        oi.ASI_CRM_Description__c = 'EVENT';
        oi.ASI_CRM_SetupCode__c = 'SSEC';
        oi.ASI_CRM_Type__c = type;
        oi.ASI_CRM_MinSPBtl__c = 624;
        oi.ASI_CRM_Total__c = 1000;
        oi.ASI_CRM_JDECOA__c = '5558.';
        oi.ASI_CRM_CashInc__c = 1000;
        oi.ASI_CRM_AchievedBtl__c = 120;
        oi.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive');
        
        insert oi;
        return oi;
    }
    
    
    // Create Actual Offtake Header
    public static ASI_CRM_ActualOfftakeHeader__c createActualOfftakeHeader(ASI_CRM_AccountsAdditionalField__c customer, date myDate){
        
        integer y = myDate.year();
        integer m = myDate.month();
        integer d = myDate.day();
        
        ASI_CRM_ActualOfftakeHeader__c Offtake_H = new ASI_CRM_ActualOfftakeHeader__c();
        Offtake_H.ASI_CRM_ToOutlet__c = customer.id; 
        Offtake_H.ASI_CRM_OfftakeDate__c= date.newinstance(y,m,d);
        Offtake_H.ASI_CRM_Status__c = 'Draft';
        Offtake_H.ASI_CRM_Calculated_Payment_Status__c = 'Draft';
        Offtake_H.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
        insert Offtake_H;
        return Offtake_H;
    }
    
    // Create Actual Offtake Header
    public static ASI_CRM_ActualOfftakeHeader__c createActualOfftakeHeader2(ASI_CRM_AccountsAdditionalField__c customer, date myDate){
        
        integer y = myDate.year();
        integer m = myDate.month();
        
        ASI_CRM_ActualOfftakeHeader__c Offtake_H = new ASI_CRM_ActualOfftakeHeader__c();
        Offtake_H.ASI_CRM_ToOutlet__c = customer.id; 
        Offtake_H.ASI_CRM_OfftakeDate__c= date.newinstance(y,m,1);
        Offtake_H.ASI_CRM_Status__c = 'Draft';
        Offtake_H.ASI_CRM_Calculated_Payment_Status__c = 'Draft';
        Offtake_H.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
        insert Offtake_H;
        return Offtake_H;
    }
    
    
    // Create Actual Offtake
    public static ASI_TH_CRM_Actual_Offtake__c createActualOfftake(ASI_CRM_ActualOfftakeHeader__c Offtake_H, ASI_MFM_SKU_Code__c sku, ASI_CRM_AccountsAdditionalField__c customer, date myDate, String InvoiceNumber, Double quantity){
        integer y = myDate.year();
        integer m = myDate.month();
        ASI_TH_CRM_Actual_Offtake__c Offtake_L = new ASI_TH_CRM_Actual_Offtake__c();
        Offtake_L.ASI_CRM_ActualOfftakeHeader__c = Offtake_H.id;
        Offtake_L.ASI_CRM_SKU__c = sku.id;
        Offtake_L.ASI_CRM_FromWS__c = customer.id;
        Offtake_L.ASI_TH_CRM_Quantity__c = quantity;
        Offtake_L.ASI_CRM_Price__c = 200; 
        Offtake_L.ASI_CRM_InvoiceDate__c = date.newinstance(y,m,1);
        Offtake_L.ASI_CRM_InvoiceNumber__c = InvoiceNumber;
        Offtake_L.recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake');
        insert Offtake_L;
        return Offtake_L;
    }
    
    
    //Create AC code - ContractSetup
    public static ASI_MFM_A_C_Code__c createContractSetupCode(){
        ASI_MFM_A_C_Code__c contractSetupCode = 
            new ASI_MFM_A_C_Code__c(
                ASI_CRM_ContractSetupCode__c = 'VOLC',
                ASI_MFM_A_C_Code__c = '5275.',
                ASI_MFM_A_C_Description__c = 'Sales Incentive-cash/kind',
                ASI_MFM_GL_Class__c = 'VOLC',
                RecordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_MY_A_C_Code')
            );
        
        insert contractSetupCode;
        return contractSetupCode;
        
    }
    
    
    //Create AC code - ContractSetup
    
    public static ASI_MFM_A_C_Code__c createContractSAVRSetupCode(){
        ASI_MFM_A_C_Code__c contractSetupCode = 
            new ASI_MFM_A_C_Code__c(
                ASI_CRM_ContractSetupCode__c = 'SAVR',
                ASI_MFM_A_C_Code__c = '5210.',
                ASI_MFM_A_C_Description__c = 'Sales Incentive-cash/kind',
                ASI_MFM_GL_Class__c = 'SAVR',
                RecordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_MY_A_C_Code')
            );
        
        insert contractSetupCode;
        return contractSetupCode;
        
    }
    
    public static ASI_CRM_Calculated_FOC__c createCalculatedFOC(ASI_CRM_AccountsAdditionalField__c customer, ASI_TH_CRM_Contract__c con, String year, String month, User owner){
        ASI_CRM_Calculated_FOC__c foc = new ASI_CRM_Calculated_FOC__c();
        foc.ASI_CRM_Customer__c = customer.Id;
        foc.ASI_CRM_Contract__c = con.Id; 
        foc.ASI_CRM_Year__c = year;
        foc.ASI_CRM_Month__c = month;
        foc.OwnerId = owner.Id;
        foc.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Calculated_FOC__cASI_CRM_MY_Calculated_FOC');
            
        insert foc;
        return foc;
    }
    
    
    public static ASI_CRM_Calculated_FOC_Line__c createCalculatedFOCLine(ASI_CRM_Calculated_FOC__c foc, ASI_MFM_SKU_Code__c sku){
        ASI_CRM_Calculated_FOC_Line__c focLine = new ASI_CRM_Calculated_FOC_Line__c();
        focLine.ASI_CRM_Calculated_FOC__c = foc.Id;
        focLine.ASI_CRM_Actual_Purchase__c  = 200;
        focLine.ASI_CRM_SKU__c = sku.Id;
        focLine.ASI_CRM_FOC__c = 18;
        focLine.ASI_CRM_FOC_WS__c = 18;
        focLine.ASI_CRM_Remain__c = 0;
        focLine.ASI_CRM_SetupCode__c = 'SAVR';
        focLine.ASI_CRM_JDECOA__c = '5210.SAVR';
        focLine.ASI_CRM_Original_SKU__c = sku.Id;
        focLine.ASI_CRM_Pervious_Remain_PRM__c = 0;
        focLine.ASI_CRM_ExcessQuantity__c = false; 
        focLine.CurrencyIsoCode = 'MYR';
        focLine.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Calculated_FOC_Line__cASI_CRM_MY_Calculated_FOC_Item');
            
        insert focLine;
        return focLine;
    }
    
    public static ASI_CRM_Calculated_Payment__c createCalculatedPayment(ASI_CRM_AccountsAdditionalField__c customer, ASI_TH_CRM_Contract__c con, String year, String month, User owner, String incentive_type){
        ASI_CRM_Calculated_Payment__c calPayment = new ASI_CRM_Calculated_Payment__c();
        calPayment.ASI_CRM_Customer__c = customer.Id;
        calPayment.ASI_CRM_Contract__c = con.Id; 
        calPayment.ASI_CRM_Year__c = year;
        calPayment.ASI_CRM_Month__c = month;
        calPayment.ASI_CRM_Incentive_Type__c = incentive_type;
        calPayment.OwnerId = owner.Id;
        calPayment.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Calculated_Payment__cASI_CRM_MY_Calculated_FOC_Payment_Type');
            
        insert calPayment;
        return calPayment;
    }
    
    
    public static ASI_CRM_Calculated_Payment_Item__c  createCalculatedPaymentLine(ASI_CRM_Calculated_Payment__c calPayment, ASI_MFM_SKU_Code__c sku){
        ASI_CRM_Calculated_Payment_Item__c calPaymentLine = new ASI_CRM_Calculated_Payment_Item__c();
        calPaymentLine.ASI_CRM_Calculated_Payment__c = calPayment.Id;
        calPaymentLine.ASI_CRM_SKU__c = sku.Id;
        calPaymentLine.ASI_CRM_Cash__c = 400;
        calPaymentLine.ASI_CRM_Actual_Volume__c = 100;        
        calPaymentLine.ASI_CRM_SetupCode__c = 'SSEC';
        calPaymentLine.ASI_CRM_Brought_Forward__c = 0;
        calPaymentLine.ASI_CRM_Carried_Forward__c  = 4;
        calPaymentLine.ASI_CRM_ExcessQuantity__c = false; 
        calPaymentLine.CurrencyIsoCode = 'MYR';
        calPaymentLine.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Calculated_Payment_Item__cASI_CRM_Calculated_Payment_Item_Type');
            
        insert calPaymentLine;
        return calPaymentLine;
    }
    
    public static ASI_TH_CRM_Contract__c createContract(ASI_CRM_AccountsAdditionalField__c customer, date myDate){
        
        integer y = myDate.year();
        integer m = myDate.month();
        
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
        contract.Name = 'Auto-generated Number';
        contract.ASI_TH_CRM_Start_Date__c = date.newinstance(y - 1, m, 1);
        contract.ASI_TH_CRM_End_Date__c = date.newinstance(y + 1, m, 1);
        contract.ASI_TH_CRM_Contract_Status__c = 'Draft';
        contract.ASI_TH_CRM_Promotion_Type__c = 'Contract';
        contract.ASI_CRM_CN_Outlet_WS__c = customer.id;
        contract.ASI_CRM_Version__c = '1';
        contract.ASI_CRM_Obsolete_Version__c = FALSE;
        contract.ASI_CRM_MY_IsAutoRequest__c = true;
        contract.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
        insert contract;
        return contract;
    }
    
    
    public static ASI_TH_CRM_Contract__c createContract(ASI_CRM_AccountsAdditionalField__c customer, date myDate, boolean isParentContract){
        
        integer y = myDate.year();
        integer m = myDate.month();
        
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
        contract.Name = 'Auto-generated Number';
        contract.ASI_TH_CRM_Start_Date__c = date.newinstance(y - 1, m, 1);
        contract.ASI_TH_CRM_End_Date__c = date.newinstance(y + 1, m, 1);
        contract.ASI_TH_CRM_Contract_Status__c = 'Draft';
        contract.ASI_TH_CRM_Promotion_Type__c = 'Contract';
        contract.ASI_CRM_CN_Outlet_WS__c = customer.id;
        contract.ASI_CRM_Version__c = '1';
        contract.ASI_CRM_Obsolete_Version__c = FALSE;
        contract.ASI_CRM_MY_IsAutoRequest__c = true;
        contract.ASI_CRM_IsParentContract__c = isParentContract;
        contract.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
        insert contract;
        return contract;
    }
    
    
    // Create Promoter Placement
    public static ASI_CRM_PromoterPlacement__c createPromoterPlacement(ASI_TH_CRM_Contract__c con, ASI_MFM_SKU_Code__c sku){
        ASI_CRM_PromoterPlacement__c pp = new ASI_CRM_PromoterPlacement__c();
        pp.ASI_CRM_Contract__c = con.id;
        pp.ASI_CRM_SKU__c = sku.id;
        pp.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PromoterPlacement__cASI_CRM_MY_PromoterPlacement');
        insert pp;
        return pp;
    }
    
    
    // Create Free Goods Request
    public static ASI_FOC_Free_Goods_Request__c createFreeGoodsRequest(ASI_TH_CRM_Contract__c con, ASI_CRM_AccountsAdditionalField__c customer, Date myDate){
        
        Integer daysInMonth = date.daysInMonth(myDate.year(), myDate.month());
        ASI_FOC_Free_Goods_Request__c fgr = new ASI_FOC_Free_Goods_Request__c();
        fgr.ASI_CRM_Outlet__c = customer.Id;
        fgr.ASI_CRM_Contract__c = con.Id;
        fgr.ASI_CRM_Status__c = 'Draft';
        fgr.ASI_CRM_Date_From__c = date.newinstance(myDate.year(), myDate.month(), 1);
        fgr.ASI_CRM_Date_To__c = date.newinstance(myDate.year(), myDate.month(), daysInMonth);
        fgr.ASI_CRM_Auto_Generation__c = true;
        fgr.ASI_FOC_Description__c = 'FOC Auto Generation';
        fgr.ASI_CRM_AP_Type__c = true;
        fgr.recordTypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_MY_FreeGoodsRequest');
        insert fgr;
        return fgr;
    }
    
    
    // Create Payment Request
    public static ASI_TH_CRM_PaymentRequest__c createPaymentRequest(ASI_TH_CRM_Contract__c con, ASI_CRM_AccountsAdditionalField__c customer, Date myDate){
        
        Integer daysInMonth = date.daysInMonth(myDate.year(), myDate.month());
        ASI_TH_CRM_PaymentRequest__c pr = new ASI_TH_CRM_PaymentRequest__c();
        pr.ASI_CRM_CN_OutletWS__c = customer.Id;
        pr.ASI_TH_CRM_Contract__c = con.Id;
        pr.ASI_TH_CRM_Status__c = 'Draft';
        pr.ASI_CRM_Date_From__c = date.newinstance(myDate.year(), myDate.month(), 1);
        pr.ASI_CRM_Date_To__c = date.newinstance(myDate.year(), myDate.month(), daysInMonth);
        pr.ASI_CRM_Auto_Generate__c = true;
        pr.ASI_CRM_CN_Description__c = 'Payment Auto Generation';
        pr.ASI_CRM_Incentive_Type__c = 'Other Incentive';
        pr.ASI_CRM_A_P_Type__c = true;
        pr.ASI_CRM_GST__c = true;
        pr.recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request');
        insert pr;
        return pr;
    }
    
    
}