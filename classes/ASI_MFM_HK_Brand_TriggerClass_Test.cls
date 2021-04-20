@isTest
public class ASI_MFM_HK_Brand_TriggerClass_Test {

    static testMethod void HK_Brand_SubBrand_ItemGroup_SKU_Deactive_Test(){
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (Name='Test1',ASI_TH_CRM_Active__c=true,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_HK_CRM_Brand'));
        insert brand;
        
        ASI_MFM_Sub_brand__c subbrand = new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Inactive__c=false,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'),
                                                    ASI_MFM_Brand__c=brand.id);
        insert subbrand;
        
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c (Name='Test3',ASI_CRM_Active__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_HK_CRM_Item_Group'),
                                                    ASI_MFM_Sub_brand__c =subbrand.id);        
        insert itemGroup;
        
        ASI_MFM_SKU_Code__c sku1 =new ASI_MFM_SKU_Code__c (Name='Test4',ASI_HK_CRM_Active__c =true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU'),
                                                    ASI_MFM_Sub_brand__c =subbrand.id,ASI_MFM_Item_Group__c=itemGroup.id);   
        ASI_MFM_SKU_Code__c sku2 =new ASI_MFM_SKU_Code__c (Name='Test5',ASI_HK_CRM_Active__c =true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU'),
                                                    ASI_MFM_Sub_brand__c =subbrand.id); 
        ASI_MFM_SKU_Code__c sku3 =new ASI_MFM_SKU_Code__c (Name='Test6',ASI_HK_CRM_Active__c =true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU'),
                                                    ASI_MFM_Item_Group__c=itemGroup.id); 
        insert sku1;
        insert sku2;
        insert sku3;
        
        brand.ASI_TH_CRM_Active__c =false;
        update brand;
        
        
    }
}