@isTest 
public class ASI_CRM_MY_CloneAllRSP_Test 
{
    static testMethod void CloneAllRSPTest() 
    {
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user1 = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='one.testing@introv.com');
        insert user1;
        
    
    
        //ASI_CRM_City__c city = createCity('B1', 'R1');
        //ASI_TH_CRM_OutletType__c outletType = createOutletType('OT1');
    
        ASI_CRM_AccountsAdditionalField__c customer1 = 
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Eng_Name__c = 'Company Ltd',
                ASI_CRM_CN_Legal_Name__c = 'Company Ltd',
                //ASI_CRM_MY_City__c = city.id,
                //ASI_TH_CRM_OutletType__c = outletType.id,
                OwnerId=user1.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet')
            );
        insert customer1;
        
        
        ASI_MFM_Brand__c brand = 
            new ASI_MFM_Brand__c(
                Name = 'BrandTEST',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_MY_Brand')
            );
        insert brand;
        
        
       ASI_MFM_Sub_brand__c subBrand = 
            new ASI_MFM_Sub_brand__c(
                Name = 'subBrandTEST',
                ASI_MFM_Brand__c = brand.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand')
            );
        insert subBrand;
        
        
        ASI_MFM_SKU_Code__c sku1 = 
            new ASI_MFM_SKU_Code__c(
                Name = 'sku1',
                ASI_MFM_SKU_Description__c = 'skuDescription',
                ASI_MFM_Sub_brand__c = subBrand.id,
                ASI_HK_CRM_Product_Brand__c = subBrand.ASI_MFM_Brand__r.id,
                //ASI_HK_CRM_Product_Category__c = productCategory.id,
                ASI_MFM_SKU_Code__c = 'BLE130',
                ASI_HK_CRM_Std_Bottle_Size__c = 300,
                ASI_HK_CRM_Packaging_Size__c = 4,
                ASI_HK_CRM_Pack_Factor__c = '4 X 300 CL 3LITR',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')
            );
        insert sku1;
        
        
        
        ASI_CRM_RSPHeader__c RSP_H = new ASI_CRM_RSPHeader__c(ASI_CRM_Customer__c = customer1.id, ASI_CRM_Date__c = date.newinstance(2015,1,1), recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader'));
        insert RSP_H; 
            
        ASI_TH_CRM_RSP__c RSP_L = new ASI_TH_CRM_RSP__c(ASI_CRM_RSPHeader__c = RSP_H.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Price_to_Consumer__c = 200, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP'));
        insert RSP_L;
        
        Test.startTest();

        ASI_CRM_MY_CloneAllRSPScheduler sh1 = new ASI_CRM_MY_CloneAllRSPScheduler();
        String sch = '0 0 0 1 * ?'; 
        system.schedule('Clone All MY RSP Header Scheduler Check', sch, sh1); 
            
        Test.stopTest();
    }
}