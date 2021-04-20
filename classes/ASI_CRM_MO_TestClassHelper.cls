/*********************************************************************************
 * Name:ASI_CRM_MO_TestClassHelper
 * Description: For generating test data for ASI CRM MY
 *
 * ref : ASI_CRM_JP_TestClassHelper
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/04/2015       Daniel WONG          Created
*********************************************************************************/
@isTest
public class ASI_CRM_MO_TestClassHelper {
    
    //Create custom settings: ASI_CRM_MO_Settings__c
    public static void createMOSetting(){
        List<ASI_CRM_MO_Settings__c> lstMOSetting = new List<ASI_CRM_MO_Settings__c>();
        lstMOSetting.add(new ASI_CRM_MO_Settings__c(ASI_CRM_MO_Field_ID_Exchange_Rate__c = '00NM0000000u4WG'));
        insert lstMOSetting;
    }
    
    //Create Running numbers
    public static void createRunningNumbers(){
        Id RTID_MORUNNINGNUMBER = Global_RecordTypeCache.getRTId('ASI_CRM_Running_Number__cASI_CRM_MO_Running_Number');
        
        List<ASI_CRM_Running_Number__c> lstRuningNumber = new List<ASI_CRM_Running_Number__c>();
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'Account', ASI_CRM_Prefix__c = 'MC', ASI_CRM_Number_of_Digit__c = 4, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'for MO CRM Account On/Off Trade', RecordTypeId = RTID_MORUNNINGNUMBER));
        lstRuningNumber.add(new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'Contract', ASI_CRM_Prefix__c = '0', ASI_CRM_Number_of_Digit__c = 3, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'for MO CRM Contract', RecordTypeId = RTID_MORUNNINGNUMBER));
        insert lstRuningNumber;
    }
    
    //Create User
    public static User createUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testing@introv.com');
        insert u1;
        return u1;
    }
    
    //Create User with parameter
    public static User createUser(String userId){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u1 = new User(Alias = 'standt', Email='systemAdmin@introv.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= userId + '@introv.com');
        insert u1;
        return u1;
    }
    
    //Create Outlet Type
    public static ASI_TH_CRM_OutletType__c createOutletType(){
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_MO_Outlet_Type'));
        
        insert outletType;
        return outletType;
    }
    

    //Create Outlet Image
    public static ASI_TH_CRM_OutletImage__c createOutletImage(){
        ASI_TH_CRM_OutletImage__c outletImage = new ASI_TH_CRM_OutletImage__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletImage__cASI_CRM_MO_Outlet_Image'));
        
        insert outletImage;
        return outletImage;
    }

    
    //Create Account
    public static Account createAccount(String strName){
        Account acc = 
            new Account(
                Name = strName,
                ASI_HK_CRM_Local_Channel__c = 'local_Channel',
                ASI_HK_CRM_District__c = 'Taipa 氹仔',
                ASI_HK_CRM_Location__c = '#_MACDPLOC',
                ASI_HK_CRM_Channel__c = 'On Trade',
                RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet')
            );
        insert acc;
        update acc;
        return acc;
    }
    
    //Create SKU
    public static ASI_MFM_SKU_Code__c createSKU(String strName){
        //ASI_MFM_Sub_brand__c subBrand = createSubBrand();
        //ASI_HK_CRM_Product_Category__c productCategory = createProductCategory();
        
        ASI_MFM_SKU_Code__c sku = 
            new ASI_MFM_SKU_Code__c(
                Name = strName,
                ASI_MFM_SKU_Description__c = 'skuDescription',
                //ASI_MFM_Sub_brand__c = subBrand.id,
                //ASI_HK_CRM_Product_Brand__c = subBrand.ASI_MFM_Brand__r.id,
                //ASI_HK_CRM_Product_Category__c = productCategory.id,
                ASI_MFM_SKU_Code__c = 'VSM800',
                ASI_HK_CRM_Std_Bottle_Size__c = 3.00,
                ASI_HK_CRM_Packaging_Size__c = 288,
                ASI_CRM_Std_Bottle_Size__c = 3,
                ASI_HK_CRM_Pack_Factor__c = '288 X 3 CL',
                ASI_HK_CRM_Active__c = TRUE,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MO_SKU')
            );
        insert sku;
        return sku;
    }
    
    //Create ASI_CRM_Investment_Payment__c
    public static ASI_CRM_Investment_Payment__c createInvestmentPayment(){
        ASI_CRM_Investment_Payment__c ip = 
            new ASI_CRM_Investment_Payment__c(
                Name = 'F-Display rental/Allowance 陳列費',
                ASI_CRM_Payment_Type__c = 'Fixed',
                ASI_CRM_Marketing_Approval__c = True,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Investment_Payment__cASI_CRM_MO_Investment_Payment')
            );
        insert ip;
        return ip;
    }

    
}